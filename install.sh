# ==============================================================================
# 필수 환경 체크 및 설정
# ==============================================================================
echo "Starting dotfiles setup..."

# Node.js 버전 체크 및 설정 (nvim Copilot 등을 위해 필요)
cd install
bash node_setup.sh
cd ..

# ==============================================================================
# 각 도구별 설치
# ==============================================================================
cd terminal-tools
bash setting.bash
cd ../zsh
bash python_dev_install_script.sh
cd ../nvim
bash nvim_install.sh
cd ../tmux
bash tmux_setup_script.sh
cd ../container-tools
bash install.sh
cd ../claude
bash install.sh
cd ..

# ==============================================================================
# Zinit 설치
# ==============================================================================
echo "Installing Zinit..."
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    echo "  ✓ Zinit installed"
else
    echo "  ✓ Zinit already installed"
fi

# ==============================================================================
# Starship 설치
# ==============================================================================
echo "Installing Starship..."
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    echo "  ✓ Starship installed"
else
    echo "  ✓ Starship already installed ($(starship --version))"
fi

# ==============================================================================
# 심볼릭 링크 생성
# ==============================================================================

# 기존 심볼릭 링크 함수
link() {
    local src="$1"
    local dst="$2"
    if [ -L "$dst" ]; then
        echo "  ✓ Already linked: $dst"
    elif [ -e "$dst" ]; then
        mv "$dst" "${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  ⚠ Backed up existing: $dst"
        ln -s "$src" "$dst"
        echo "  ✓ Linked: $dst"
    else
        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
        echo "  ✓ Linked: $dst"
    fi
}

link ~/.config/dotfiles/nvim ~/.config/nvim
link ~/.config/dotfiles/neofetch ~/.config/neofetch
link ~/.config/dotfiles/claude/settings.json ~/.claude/settings.json
link ~/.config/dotfiles/claude/skills ~/.claude/skills

# zshrc 심볼릭 링크
link ~/.config/dotfiles/zsh/.zshrc ~/.zshrc

# Starship 설정 심볼릭 링크
mkdir -p ~/.config
link ~/.config/dotfiles/terminal-tools/starship.toml ~/.config/starship.toml

echo ""
echo "✅ dotfiles setup complete!"
echo ""
echo "⚠️  Github Copilot 설정 필요"
echo ""
echo "레거시 정리가 필요하다면:"
echo "  bash ~/.config/dotfiles/zsh/migrate-legacy.sh"
