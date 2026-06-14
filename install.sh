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
# tealdeer (tldr) 설치
# ==============================================================================
echo "Installing tealdeer (tldr)..."
if ! command -v tldr >/dev/null 2>&1; then
    brew install tealdeer
    tldr --update
    echo "  ✓ tealdeer installed"
else
    echo "  ✓ tealdeer already installed"
fi

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
# git-crypt 설치 (claude/secrets.env 등 암호화 시크릿 복호화용)
# ==============================================================================
echo "Installing git-crypt..."
if ! command -v git-crypt >/dev/null 2>&1; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git-crypt
    elif command -v apt >/dev/null 2>&1; then
        sudo apt install -y git-crypt
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y git-crypt
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm git-crypt
    else
        echo "  ⚠ git-crypt 자동 설치 실패 — 수동 설치 필요"
    fi
    echo "  ✓ git-crypt installed"
else
    echo "  ✓ git-crypt already installed"
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
link ~/.config/dotfiles/claude/skills ~/.claude/skills
link ~/.config/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md

# ~/.claude/settings.json 은 심링크가 아니라 "생성"합니다:
#   공개 repo의 비-비밀 베이스 + 암호화된 secrets.env의 토큰을 env 블록으로 주입.
# (secrets.env이 아직 잠겨 있으면 베이스만 기록하고 경고 — unlock 후 재실행)
echo "Generating ~/.claude/settings.json (base + encrypted env block)..."
python3 ~/.config/dotfiles/claude/gen-claude-settings.py

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
echo "🔐 시크릿(claude/secrets.env) 복호화 + Claude 전역 env 적용:"
echo "    1) git-crypt unlock /path/to/dotfiles-gitcrypt.key"
echo "       (메인 컴퓨터에서 export한 키를 안전하게 옮긴 뒤 실행)"
echo "    2) python3 ~/.config/dotfiles/claude/gen-claude-settings.py"
echo "       (secrets.env의 토큰을 ~/.claude/settings.json env 블록에 주입 → Claude 전역 적용)"
echo "    3) 새 터미널 열기 + Claude Code 재시작"
echo "    키가 없으면 secrets는 암호화 상태로 남고, env 블록 없이 베이스만 적용됩니다."
echo ""
echo "레거시 정리가 필요하다면:"
echo "  bash ~/.config/dotfiles/zsh/migrate-legacy.sh"
