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

# linked symbol
ln -s ~/.config/dotfiles/nvim ~/.config
ln -s ~/.config/dotfiles/neofetch ~/.config
ln -s ~/.config/dotfiles/claude/settings.json ~/.claude/settings.json
ln -s ~/.config/dotfiles/claude/commands ~/.claude/commands

echo "Github Copilot 설정 필요"

