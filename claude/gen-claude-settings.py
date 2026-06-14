#!/usr/bin/env python3
"""
Generate ~/.claude/settings.json = committed non-secret base  +  an `env` block
injected from the git-crypt-encrypted claude/secrets.env.

Why a generator instead of a symlink?
  ~/.claude/settings.json is symlinked from a PUBLIC repo, so secrets cannot live
  in it directly. Claude Code's `env` block sets environment variables for every
  session INDEPENDENT of the shell (works for GUI/IDE launches too). To get a
  "global Claude env var" that holds a secret, we generate a LOCAL (uncommitted,
  mode 600) settings file by merging the public base with the decrypted tokens.

Token source of truth: claude/secrets.env (also sourced by ~/.zshrc for the shell).
  Every `export KEY=VALUE` line becomes a key in the Claude `env` block.

Safe by design:
  - If secrets.env is still git-crypt LOCKED (or missing), the env block is
    skipped and only the base is written (with a warning) — never garbage.
  - The output is chmod 600 and is NOT the symlinked/committed file.
"""
import json
import os
import re
import sys
from datetime import datetime

REPO = os.path.expanduser("~/.config/dotfiles")
BASE = os.path.join(REPO, "claude", "settings.json")
SECRETS = os.environ.get("CLAUDE_SECRETS_ENV", os.path.join(REPO, "claude", "secrets.env"))
OUT = os.environ.get("CLAUDE_SETTINGS_OUT", os.path.expanduser("~/.claude/settings.json"))

GITCRYPT_MAGIC = b"\x00GITCRYPT"


def lock_state(path):
    """Return 'missing' | 'locked' | 'unlocked'."""
    try:
        with open(path, "rb") as f:
            return "locked" if f.read(9).startswith(GITCRYPT_MAGIC) else "unlocked"
    except FileNotFoundError:
        return "missing"


def parse_exports(path):
    """Extract `export KEY=VALUE` pairs (surrounding quotes stripped)."""
    rx = re.compile(r'^\s*export\s+([A-Za-z_][A-Za-z0-9_]*)=(.*)$')
    env = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = rx.match(line.rstrip("\n"))
            if not m:
                continue
            key, val = m.group(1), m.group(2).strip()
            if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'":
                val = val[1:-1]
            env[key] = val
    return env


def main():
    with open(BASE, encoding="utf-8") as f:
        merged = json.load(f)

    state = lock_state(SECRETS)
    if state == "missing":
        print("·  secrets.env missing — writing base only (no env block)")
    elif state == "locked":
        print("🔒 secrets.env is git-crypt LOCKED — writing base only. "
              "Run `git-crypt unlock ~/dotfiles-gitcrypt.key`, then re-run this script.")
    else:
        secret_env = parse_exports(SECRETS)
        if secret_env:
            merged["env"] = {**merged.get("env", {}), **secret_env}
            print(f"🔓 injected {len(secret_env)} var(s) into Claude env block: "
                  f"{', '.join(secret_env)}")
        else:
            print("🔓 secrets.env unlocked but has no `export` lines — nothing to inject")

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    if os.path.lexists(OUT):
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup = f"{OUT}.backup.{ts}"
        os.rename(OUT, backup)
        print(f"⚠  backed up existing settings.json -> {backup}")

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.chmod(OUT, 0o600)
    print(f"✓  wrote {OUT} (mode 600, keys: {', '.join(merged)})")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # noqa: BLE001
        print(f"✗ failed to generate settings.json: {e}", file=sys.stderr)
        sys.exit(1)
