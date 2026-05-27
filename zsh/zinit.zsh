# ==============================================================================
# Zinit 초기화
# ==============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Zinit가 없으면 자동 설치
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ==============================================================================
# 자동완성 즉시 초기화 (turbo 이전에 실행 → 첫 탭부터 바로 동작)
# ==============================================================================
autoload -Uz compinit
compinit -C

# ==============================================================================
# 플러그인 — Turbo mode (프롬프트 표시 후 비동기 로드 → 빠른 시작)
# ==============================================================================

# fzf-tab: tab 자동완성을 fzf UI로 (다른 completion 플러그인보다 먼저 로드)
# fzf 필요: brew install fzf
zinit wait lucid for \
    Aloxaf/fzf-tab

# Completion + Syntax highlighting + Autosuggestions
zinit wait lucid for \
    blockf \
        zsh-users/zsh-completions \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions

# 히스토리 부분 검색 (↑↓ 키로 현재 입력과 일치하는 히스토리 탐색)
zinit wait lucid for \
    zsh-users/zsh-history-substring-search

# Oh My Zsh 플러그인 (git alias)
# OMZP::macos 제외: zinit snippet 방식에서 music/spotify 서브파일 누락 오류 발생
zinit wait lucid for \
    OMZP::git

# ==============================================================================
# 키 바인딩
# ==============================================================================

# 히스토리 부분 검색
bindkey '^[[A' history-substring-search-up    # ↑
bindkey '^[[B' history-substring-search-down  # ↓
bindkey '^[OA' history-substring-search-up    # ↑ (tmux)
bindkey '^[OB' history-substring-search-down  # ↓ (tmux)

# Autosuggestions: →키로 수락
bindkey '^ ' autosuggest-accept   # Ctrl+Space

# ==============================================================================
# Zsh 옵션
# ==============================================================================
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
HISTSIZE=10000
SAVEHIST=10000

# ==============================================================================
# Starship 프롬프트 초기화
# ==============================================================================
eval "$(starship init zsh)"
