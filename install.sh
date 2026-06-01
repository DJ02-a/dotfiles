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
if command -v tldr >/dev/null 2>&1; then
    echo "  ✓ tealdeer already installed"
elif command -v brew >/dev/null 2>&1; then
    brew install tealdeer && tldr --update
    echo "  ✓ tealdeer installed (via brew)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux: fetch latest release binary (brew not assumed).
    TLDR_VER=$(curl -fsSL "https://api.github.com/repos/tealdeer-rs/tealdeer/releases/latest" \
        | grep -m1 '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
    TLDR_ARCH=$(uname -m)
    case "$TLDR_ARCH" in
        x86_64)  TLDR_ASSET="linux-x86_64-musl" ;;
        aarch64|arm64) TLDR_ASSET="linux-arm-musleabihf" ;;
        *) TLDR_ASSET="" ;;
    esac
    if [ -n "$TLDR_VER" ] && [ -n "$TLDR_ASSET" ]; then
        mkdir -p "$HOME/.local/bin"
        curl -fsSL "https://github.com/tealdeer-rs/tealdeer/releases/download/v${TLDR_VER}/tealdeer-${TLDR_ASSET}" \
            -o "$HOME/.local/bin/tldr" \
            && chmod +x "$HOME/.local/bin/tldr" \
            && "$HOME/.local/bin/tldr" --update >/dev/null \
            && echo "  ✓ tealdeer ${TLDR_VER} installed (~/.local/bin)" \
            || echo "  ✗ tealdeer install failed — fetch manually"
    else
        echo "  ✗ tealdeer: could not determine version/arch — skipping"
    fi
else
    echo "  ✗ tealdeer: no installer available on this OS — skipping"
fi

# ==============================================================================
# Zinit 설치
# ==============================================================================
echo "Installing Zinit..."
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Verify the *content* not just directory existence — a previous interrupted
# clone can leave an empty .git/ that passes `[ -d ]` but has no zinit.zsh,
# causing "zinit: command not found" on shell startup.
if [ ! -f "$ZINIT_HOME/zinit.zsh" ]; then
    if [ -d "$ZINIT_HOME" ]; then
        echo "  ⚠ Incomplete Zinit clone detected — repairing"
        rm -rf "$ZINIT_HOME"
    fi
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

# Idempotent symlink helper.
# Verifies the symlink's *target* (not just its existence) so stale links from
# previous layouts (e.g. ~/.config/starship.toml → old oh-my-zsh path) and
# broken links get repaired instead of being silently skipped.
link() {
    local src="$1"
    local dst="$2"
    local src_abs
    src_abs=$(readlink -f "$src" 2>/dev/null) || {
        echo "  ✗ Source missing, skipping: $src"
        return 1
    }

    if [ -L "$dst" ]; then
        local cur_abs
        cur_abs=$(readlink -f "$dst" 2>/dev/null || true)
        if [ "$cur_abs" = "$src_abs" ]; then
            echo "  ✓ Already linked: $dst"
            return 0
        fi
        # Symlink points elsewhere or is broken — replace atomically.
        echo "  ⚠ Re-linking $dst (was: $(readlink "$dst"))"
        ln -sfn "$src" "$dst"
        echo "  ✓ Linked: $dst"
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
