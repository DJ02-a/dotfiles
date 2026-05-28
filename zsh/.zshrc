# ==============================================================================
# ~/.zshrc — Zinit + Starship
# Managed by dotfiles: ~/.config/dotfiles/zsh/.zshrc
# ==============================================================================

# ==============================================================================
# PATH — zinit/starship 보다 먼저 설정해야 함
# ==============================================================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Homebrew (Apple Silicon)
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# uv (Python package manager)
. "$HOME/.local/bin/env" 2>/dev/null || true

# ==============================================================================
# Zinit + 플러그인 + Starship (PATH 설정 이후에 실행)
# ==============================================================================
source ~/.config/dotfiles/zsh/zinit.zsh

# ==============================================================================
# 환경 변수
# ==============================================================================
export LS_COLORS="ow=01;34:tw=01;34:st=01;34"

# ==============================================================================
# Man 페이지 — bat으로 렌더링 (syntax highlight + Tokyo Night 색상)
# ==============================================================================
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# ==============================================================================
# Aliases — Terminal Tools
# ==============================================================================
alias ls="lsd --no-symlink"
alias ll="lsd -l --no-symlink"
alias la="lsd -la --no-symlink"
alias lt="lsd --tree --no-symlink"
alias cat="bat"

# ==============================================================================
# Aliases — Apps
# ==============================================================================
alias lzd='lazydocker'
alias k9='k9s'

# ==============================================================================
# bun completions
# ==============================================================================
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ==============================================================================
# uv — .venv 자동 활성화/비활성화
# ==============================================================================
function _uv_venv_auto() {
  local venv="$PWD/.venv"
  if [[ -f "$venv/bin/activate" ]]; then
    if [[ "$VIRTUAL_ENV" != "$venv" ]]; then
      source "$venv/bin/activate"
    fi
  elif [[ -n "$VIRTUAL_ENV" ]]; then
    # .venv 없는 디렉토리로 나오면 비활성화
    local current="$PWD"
    local venv_parent="${VIRTUAL_ENV:h:h}"  # .venv의 부모 디렉토리
    if [[ "$current" != "$venv_parent"* ]]; then
      deactivate
    fi
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _uv_venv_auto
_uv_venv_auto  # 쉘 시작 시 현재 디렉토리에서도 실행
