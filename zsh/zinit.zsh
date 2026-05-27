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
# 테마 — Tokyo Night 색상 팔레트
# ==============================================================================

# fzf: Tokyo Night 색상 적용
export FZF_DEFAULT_OPTS="
  --color=fg:#c0caf5,bg:#1a1b26,hl:#ff9e64
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#bb9af7
  --color=border:#414868
  --border=rounded
  --height=~40%
  --min-height=10
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
"

# zsh-autosuggestions: Tokyo Night muted 색상 (#565f89)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ==============================================================================
# 플러그인 — Turbo mode (프롬프트 표시 후 비동기 로드 → 빠른 시작)
# ==============================================================================

# fzf-tab: tab 자동완성을 fzf UI로 (다른 completion 플러그인보다 먼저 로드)
# fzf 필요: brew install fzf
zinit wait lucid for \
    Aloxaf/fzf-tab

# Completion + Syntax highlighting + Autosuggestions
# fast-syntax-highlighting: free 테마 (Tokyo Night 터미널 팔레트와 잘 어울림)
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
# fzf-tab 설정 — Tokyo Night 스타일
# ==============================================================================

# FZF_DEFAULT_OPTS 색상 그대로 사용
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# fzf-tab 높이 + Ctrl+/ 로 미리보기 패널 토글
zstyle ':fzf-tab:*' fzf-flags --height=~40% --min-height=10 --bind 'ctrl-/:toggle-preview'

# 자동완성 목록에 LS_COLORS 적용 (파일 타입별 색상)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 그룹 설명 표시 형식
zstyle ':completion:*:descriptions' format '[%d]'

# fzf UI 사용 (기본 메뉴 비활성화)
zstyle ':completion:*' menu no

# 모든 파일/폴더 자동완성에서 미리보기:
#   폴더 → lsd로 내용 목록
#   파일 → bat으로 내용 (최대 50줄)
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [[ -d "$realpath" ]]; then
    lsd -1 --color=always "$realpath"
  elif [[ -f "$realpath" ]]; then
    bat --color=always --line-range=:50 "$realpath" 2>/dev/null || cat "$realpath"
  fi
'

# 그룹 전환 키 (< / >)
zstyle ':fzf-tab:*' switch-group '<' '>'

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
