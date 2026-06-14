# Inventory & Reconciliation reference

Detailed commands and decision rules for `dotfiles-install` Phases 0–1. Run from the repo root (`~/.config/dotfiles`).

## Phase 0 — Inventory commands

### OS / package manager
```bash
uname -s                                   # Darwin | Linux
[ -f /etc/os-release ] && . /etc/os-release && echo "$ID"   # ubuntu|debian|fedora|arch|...
```

### Installed tools (idempotency map)
```bash
for t in git-crypt lsd bat nvim tmux starship uv lazygit claude-notify; do
  command -v "$t" >/dev/null 2>&1 && echo "✓ $t" || echo "✗ $t"
done
[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git" ] && echo "✓ zinit" || echo "✗ zinit"
```

### Symlink target classification
For each `(target, source)` pair, classify:
```bash
classify() { # $1=target $2=expected_source
  if [ -L "$1" ]; then
    [ "$(readlink "$1")" = "$2" ] && echo "✓ correct symlink" || echo "⮕ symlink elsewhere: $(readlink "$1")"
  elif [ -e "$1" ]; then echo "⚠ real file/dir (will back up)"
  else echo "· missing (will create)"; fi
}
```
Run it for every row in the SKILL.md symlink table. Expand `dotfiles` → `$HOME/.config/dotfiles`.

### settings.json divergence (highest-value check)
```bash
# top-level keys on each side
python3 - <<'PY'
import json,os
live=os.path.expanduser("~/.claude/settings.json")
repo=os.path.expanduser("~/.config/dotfiles/claude/settings.json")
def load(p):
    try: return json.load(open(p))
    except Exception as e: return {"__error__":str(e)}
L,R=load(live),load(repo)
lk,rk=set(L),set(R)
print("live-only keys :", sorted(lk-rk))   # would be LOST by a naive symlink
print("repo-only keys :", sorted(rk-lk))
print("shared keys    :", sorted(lk&rk))
print("leaf conflicts :", sorted(k for k in lk&rk if L[k]!=R[k]))
PY
```

### git-crypt lock state
```bash
f=claude/secrets.env
if [ -f "$f" ] && head -c 9 "$f" 2>/dev/null | grep -q GITCRYPT; then
  echo "🔒 locked (encrypted in working tree)"
else echo "🔓 unlocked (plaintext) or absent"; fi
[ -f ~/dotfiles-gitcrypt.key ] && echo "✓ master key present" || echo "✗ no master key (~/dotfiles-gitcrypt.key)"
```

## Phase 1 — Reconciliation rules

### Rule A — real file where symlink expected
Safe default, no prompt needed:
```bash
ts=$(date +%Y%m%d_%H%M%S)
mv "$TARGET" "$TARGET.backup.$ts"
ln -s "$SOURCE" "$TARGET"
```

### Rule B — settings.json: generate, don't symlink (the core "절충안")
`~/.claude/settings.json` is **generated** by `claude/gen-claude-settings.py`, not symlinked. The generator = committed non-secret base (`claude/settings.json`) **+** an `env` block parsed from the decrypted `claude/secrets.env`. This gives tokens "global Claude env var" status without committing them to the public repo.

The reconciliation concern is **base drift**: the live `~/.claude/settings.json` may have non-secret changes (e.g. plugins toggled in-app) that aren't yet in the repo base. Before regenerating:

1. Compare the live file's **non-secret keys** (everything except `env`) against the repo base.
2. For any drift, **ask** the user whether to capture it back into `claude/settings.json` (so the source of truth stays current). Never copy the live `env` block into the committed base — that would leak secrets.
3. Run the generator:
   ```bash
   python3 ~/.config/dotfiles/claude/gen-claude-settings.py
   ```
   It backs up any existing `~/.claude/settings.json`, writes a mode-600 real file, and injects the `env` block only if `secrets.env` is unlocked (otherwise base-only + warning).

Drift check (live non-secret keys vs repo base — `env` excluded):
```bash
python3 - <<'PY'
import json,os
def noenv(d): return {k:v for k,v in d.items() if k!="env"}
live=noenv(json.load(open(os.path.expanduser("~/.claude/settings.json"))))
repo=noenv(json.load(open(os.path.expanduser("~/.config/dotfiles/claude/settings.json"))))
lk,rk=set(live),set(repo)
print("live-only keys (drift to capture?):", sorted(lk-rk))
print("leaf diffs                        :", sorted(k for k in lk&rk if live[k]!=repo[k]))
PY
```
Review with the user before editing the committed base. The committed base must never contain secrets.

### Rule C — secrets unlock
```bash
# preferred: key already on disk
[ -f ~/dotfiles-gitcrypt.key ] && git-crypt unlock ~/dotfiles-gitcrypt.key
# fallback without key: manual template
[ ! -f claude/secrets.env ] && cp claude/secrets.env.example claude/secrets.env
```
If neither, tell the user to retrieve the key from their password manager (it was exported once via `git-crypt export-key ~/dotfiles-gitcrypt.key`). Do not block other phases.

### Rule D — already correct
Report ✓ and skip. No mutation.

## Safety checklist before any commit
```bash
git-crypt status -e | grep secrets.env        # must say: encrypted
git diff --cached --name-only                 # confirm no plaintext secret slipped in
```
Only commit/push when the user explicitly asks.
