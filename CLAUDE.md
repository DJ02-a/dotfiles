# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed via symlinks. Each tool lives in its own directory with a self-contained install script. `install.sh` at the root orchestrates the full setup; `uninstall.sh` provides selective removal with backups.

## Setup & Teardown

```bash
# Full install (run from repo root)
bash install.sh

# Selective uninstall (interactive menu)
bash uninstall.sh

# Individual component install
bash terminal-tools/setting.bash   # lsd, bat, neofetch, lazygit, uv, fzf
bash nvim/nvim_install.sh          # Neovim + vim-plug + plugins
bash tmux/tmux_setup_script.sh     # tmux + TPM + plugins
bash claude/install.sh             # Claudia GUI + claude-notify
```

## Architecture

### Symlink Strategy
`install.sh` deploys configs by symlinking into expected system locations — configs live in this repo and are referenced in-place:

| Symlink target | Points to |
|---|---|
| `~/.config/nvim` | `dotfiles/nvim/` |
| `~/.config/neofetch` | `dotfiles/neofetch/` |
| `~/.config/lsd/` | `dotfiles/terminal-tools/lsd/` |
| `~/.tmux.conf` | `dotfiles/tmux/.tmux.conf` |
| `~/.claude/settings.json` | `dotfiles/claude/settings.json` |
| `~/.claude/skills/` | `dotfiles/claude/skills/` |

Editing files in this repo immediately affects the live config.

### Directory Responsibilities

- **`terminal-tools/`** — Cross-platform install for lsd, bat, neofetch, lazygit, uv, fzf (latest binary; distro fzf is too old for the `--height=~40%` syntax in `zsh/zinit.zsh`). Adds shell aliases (`ls`→`lsd`, `cat`→`bat`). Handles macOS/Ubuntu/Fedora/Arch differences.
- **`nvim/`** — Neovim config. Uses vim-plug (`init.vim`) with Lua modules in `nvim/lua/`. Minimum version: 0.10.4. Linux installs via AppImage; macOS via Homebrew.
- **`tmux/`** — TPM-based tmux config. Theme: Kanagawa Wave (`Nybkox/tmux-kanagawa`). Prefix remapped to `C-a`. Integrates with nvim via `christoomey/vim-tmux-navigator` (C-h/j/k/l navigation across panes).
- **`zsh/`** — Python dev environment setup (pyenv, poetry, common tools). Not symlinked — appends to `~/.zshrc` directly.
- **`claude/`** — Installs Claudia (Tauri GUI for Claude Code, requires Rust + Bun). Installs `claude-notify` for system notifications. Manages `~/.claude/` symlinks.
- **`ssh/`** — Mutagen plugin for remote development sync.
- **`install/`** — Node.js version check/setup helper called by root `install.sh`.

### Shell Configuration
Current setup: **Oh My Zsh + Powerlevel10k** (migration to Zinit + Starship in progress).

Active custom aliases in `~/.zshrc`:
```zsh
ls → lsd --no-symlink
ll → lsd -l
la → lsd -la
lt → lsd --tree
cat → bat
lzd → lazydocker
k9 → k9s
```

### Nvim Plugin Management
- Plugin manager: vim-plug (auto-installed by `nvim_install.sh`)
- Plugin directory: `nvim/plugged/` (large — already gitignored? check `.gitignore`)
- Lua configs live in `nvim/lua/`

### Claude Skills
Custom Claude Code skills in `claude/skills/` are symlinked to `~/.claude/skills/`. Current skills: `add-gateway-client`, `add-triton-to-rayworker`, `add-worker-model`, `clear-system-cache`, `research-to-lib`.

## Key Conventions

- Each install script is idempotent — checks if tools already exist before installing.
- The `uninstall.sh` always backs up before removing (backup dir: `~/.dotfiles-backup-<timestamp>`).
- Shell config mutations (alias/env additions) use unique comment markers for later targeted removal (e.g., `# Custom Aliases - Enhanced Terminal Tools`).
- tmux prefix is `C-a` (not the default `C-b`). Reload config: `prefix + r`.
