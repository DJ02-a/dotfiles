#!/bin/bash

# ==============================================================================
# Dotfiles Uninstall Script
# ==============================================================================
# Selectively removes dotfiles configurations and symlinks
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Backup directory
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

# Confirmation function
confirm() {
    local prompt="$1"
    read -p "$(echo -e ${YELLOW}${prompt}${NC}) [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Create backup directory
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory: $BACKUP_DIR"
    fi
}

# Log function
log_action() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$BACKUP_DIR/uninstall.log"
}

# Backup and remove symlink
remove_symlink() {
    local link_path="$1"
    local description="$2"

    if [[ -L "$link_path" ]]; then
        local target=$(readlink "$link_path")
        rm "$link_path"
        print_success "Removed symlink: $link_path"
        log_action "Removed symlink: $link_path -> $target"
    elif [[ -e "$link_path" ]]; then
        print_warning "$description exists but is not a symlink"
        if confirm "Backup and remove $link_path?"; then
            local basename=$(basename "$link_path")
            cp -r "$link_path" "$BACKUP_DIR/$basename"
            print_success "Backed up to: $BACKUP_DIR/$basename"
            rm -rf "$link_path"
            print_success "Removed: $link_path"
            log_action "Backed up and removed: $link_path"
        fi
    else
        print_info "Not found: $description"
    fi
}

# Remove shell configuration section
remove_shell_section() {
    local config_file="$1"
    local marker="$2"
    local description="$3"

    if [[ -f "$config_file" ]] && grep -q "$marker" "$config_file"; then
        print_step "Removing from $(basename $config_file): $description"

        # Backup
        if [[ ! -f "$BACKUP_DIR/$(basename $config_file).backup" ]]; then
            cp "$config_file" "$BACKUP_DIR/$(basename $config_file).backup"
        fi

        # Remove section
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/$marker/,/^$/d" "$config_file"
        else
            sed -i "/$marker/,/^$/d" "$config_file"
        fi

        print_success "Removed: $description"
        log_action "Removed from $config_file: $marker"
    fi
}

# ==============================================================================
# Component-specific uninstall functions
# ==============================================================================

uninstall_nvim() {
    print_header "Uninstall Neovim Configuration"

    if confirm "Remove Neovim configuration symlink?"; then
        remove_symlink "$HOME/.config/nvim" "Neovim configuration"
        print_warning "Note: Neovim plugins and packages were NOT removed"
        print_info "To fully clean Neovim, also remove:"
        echo "  rm -rf ~/.local/share/nvim"
        echo "  rm -rf ~/.cache/nvim"
    else
        print_info "Skipped Neovim uninstall"
    fi
}

uninstall_neofetch() {
    print_header "Uninstall Neofetch Configuration"

    if confirm "Remove Neofetch configuration symlink?"; then
        remove_symlink "$HOME/.config/neofetch" "Neofetch configuration"
    else
        print_info "Skipped Neofetch uninstall"
    fi
}

uninstall_claude() {
    print_header "Uninstall Claude Code Configuration"

    if confirm "Remove Claude Code configuration?"; then
        remove_symlink "$HOME/.claude/settings.json" "Claude settings"
        remove_symlink "$HOME/.claude/commands" "Claude commands"
        remove_symlink "$HOME/.claude/skills" "Claude skills"

        print_warning "Note: claude-notify package was NOT removed"
        print_info "To remove claude-notify: pip uninstall claude-notify"
    else
        print_info "Skipped Claude Code uninstall"
    fi
}

uninstall_terminal_tools() {
    print_header "Uninstall Terminal Tools Configurations"

    if confirm "Remove terminal tools shell aliases (lsd, bat, etc.)?"; then
        local configs=("$HOME/.zshrc" "$HOME/.bashrc")

        for config in "${configs[@]}"; do
            remove_shell_section "$config" "# Custom Aliases - Enhanced Terminal Tools" "Terminal tools aliases"
        done

        print_warning "Note: Packages (lsd, bat, neofetch, lazygit, uv) were NOT removed"
        print_info "To remove packages:"
        echo "  macOS: brew uninstall lsd bat neofetch lazygit"
        echo "  Linux: sudo apt remove bat neofetch (lsd via snap: sudo snap remove lsd)"
        echo "  uv: curl -LsSf https://astral.sh/uv/uninstall.sh | sh"
    else
        print_info "Skipped terminal tools uninstall"
    fi
}

uninstall_python_env() {
    print_header "Uninstall Python Development Environment"

    if confirm "Remove Python development shell configurations?"; then
        local configs=("$HOME/.zshrc" "$HOME/.bashrc")

        for config in "${configs[@]}"; do
            remove_shell_section "$config" "# Poetry 전역 설정" "Poetry configuration"
            remove_shell_section "$config" "# Python 개발자용 .zshrc 설정" "Python dev settings"
        done

        print_warning "Note: Python packages (black, flake8, isort, etc.) were NOT removed"
        print_info "To remove Python tools:"
        echo "  pip uninstall black flake8 isort mypy pytest ipython"
        echo "  npm uninstall -g pyright"
    else
        print_info "Skipped Python environment uninstall"
    fi
}

uninstall_node_setup() {
    print_header "Uninstall Node.js Setup"

    if confirm "Remove Node.js symlinks?"; then
        if [[ -L "$HOME/.local/bin/node" ]]; then
            print_info "Current Node.js symlink: $(readlink $HOME/.local/bin/node)"
            if confirm "Remove Node.js symlink from ~/.local/bin/?"; then
                rm "$HOME/.local/bin/node"
                print_success "Removed Node.js symlink"

                # Also remove npm and npx if they are symlinks
                [[ -L "$HOME/.local/bin/npm" ]] && rm "$HOME/.local/bin/npm" && print_success "Removed npm symlink"
                [[ -L "$HOME/.local/bin/npx" ]] && rm "$HOME/.local/bin/npx" && print_success "Removed npx symlink"

                log_action "Removed Node.js, npm, npx symlinks"
            fi
        else
            print_info "Node.js symlink not found"
        fi

        print_warning "Note: Node.js and nvm were NOT removed"
        print_info "To remove nvm: rm -rf ~/.nvm"
    else
        print_info "Skipped Node.js uninstall"
    fi
}

uninstall_shell_env() {
    print_header "Uninstall Shell Environment Configurations"

    if confirm "Remove dotfiles-added environment variables?"; then
        local configs=("$HOME/.zshrc" "$HOME/.bashrc")

        for config in "${configs[@]}"; do
            remove_shell_section "$config" "# Claude Tools Environment" "Claude tools environment"
        done

        print_success "Removed environment configurations"
    else
        print_info "Skipped shell environment uninstall"
    fi
}

# ==============================================================================
# Interactive menu
# ==============================================================================

show_menu() {
    print_header "Dotfiles Uninstall - Component Selection"

    echo "Select components to uninstall:"
    echo ""
    echo "  1) Neovim configuration"
    echo "  2) Neofetch configuration"
    echo "  3) Claude Code configuration"
    echo "  4) Terminal tools (lsd, bat aliases)"
    echo "  5) Python development environment"
    echo "  6) Node.js setup (symlinks)"
    echo "  7) Shell environment variables"
    echo ""
    echo "  8) All of the above"
    echo "  9) Custom selection (ask for each)"
    echo "  0) Cancel"
    echo ""
}

# Main uninstall function
main() {
    print_header "Dotfiles Uninstall Script"

    echo "This script will selectively remove dotfiles configurations."
    echo "Installed packages will NOT be automatically removed."
    echo ""

    # Create backup directory first
    create_backup_dir
    log_action "Started uninstall process"

    show_menu

    read -p "$(echo -e ${YELLOW}Enter your choice [0-9]:${NC}) " choice

    case $choice in
        1)
            uninstall_nvim
            ;;
        2)
            uninstall_neofetch
            ;;
        3)
            uninstall_claude
            ;;
        4)
            uninstall_terminal_tools
            ;;
        5)
            uninstall_python_env
            ;;
        6)
            uninstall_node_setup
            ;;
        7)
            uninstall_shell_env
            ;;
        8)
            print_info "Uninstalling all components..."
            uninstall_nvim
            uninstall_neofetch
            uninstall_claude
            uninstall_terminal_tools
            uninstall_python_env
            uninstall_node_setup
            uninstall_shell_env
            ;;
        9)
            print_info "Custom selection mode..."
            uninstall_nvim
            uninstall_neofetch
            uninstall_claude
            uninstall_terminal_tools
            uninstall_python_env
            uninstall_node_setup
            uninstall_shell_env
            ;;
        0)
            print_warning "Uninstall cancelled"
            rm -rf "$BACKUP_DIR"
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    # Summary
    print_header "Uninstall Summary"

    if [[ -f "$BACKUP_DIR/uninstall.log" ]]; then
        echo "Actions taken:"
        cat "$BACKUP_DIR/uninstall.log" | sed 's/^/  /'
        echo ""
    fi

    print_success "Uninstall completed!"
    print_info "Backup location: $BACKUP_DIR"
    echo ""
    print_warning "Installed packages were NOT removed"
    print_info "Restart your terminal to apply changes"

    log_action "Uninstall completed successfully"
}

# Run main function
main "$@"
