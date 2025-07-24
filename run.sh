# installation
cd brew
bash setting.bash
cd ../zsh
bash python_dev_install_script.sh
cd ../nvim
bash nvim_install.sh
cd ../tmux
bash tmux_setup_script.sh
cd ../container-toolsi
bash install.sh
cd ../claude
bash install.sh

# linked symbol
ln -s ~/.config/dotfiles/nvim ~/.config
ln -s ~/.config/dotfiles/neofetch ~/.config
ln -s ~/.config/dotfiles/claude/settings.json ~/.claude/settings.json
ln -s ~/.config/dotfiles/claude/commands ~/.claude/commands

echo "Github Copilot 설정 필요"

