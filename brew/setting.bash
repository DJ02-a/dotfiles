brew install lsd bat


# .zshrc 파일 경로
ZSHRC_FILE="$HOME/.zshrc"

# 추가할 내용
ALIASES='
# ===============================================
# Custom Aliases - Enhanced Terminal Tools
# ===============================================

alias ls="lsd --no-symlink"
alias ll="lsd -l --no-symlink"
alias lt="lsd --tree --no-symlink"

# ===============================================
'


# alias 추가
echo "$ALIASES" >> "$ZSHRC_FILE"
# .zshrc 파일에 변경 사항 적용
