#!/bin/bash

# ==============================================================================
# Cross-Platform Terminal Tools Installation Script
# ==============================================================================
# Installs: lsd, bat, neofetch, lazygit, uv
# Supports: macOS (Homebrew), Linux (apt/dnf/pacman)
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Detect Linux distribution
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif command_exists lsb_release; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

# Install tools on macOS
install_macos() {
    print_info "Installing tools for macOS..."

    # Check if Homebrew is installed
    if ! command_exists brew; then
        print_error "Homebrew is not installed!"
        print_info "Install Homebrew first: https://brew.sh"
        print_info "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi

    print_info "Updating Homebrew..."
    brew update

    print_info "Installing terminal tools..."
    brew install lsd bat neofetch lazygit

    print_success "macOS tools installed successfully"
}

# Install tools on Ubuntu/Debian
install_ubuntu_debian() {
    print_info "Installing tools for Ubuntu/Debian..."

    print_info "Updating package lists..."
    sudo apt update

    # lsd (via cargo - preferred over snap due to sandbox restrictions)
    if ! command_exists lsd; then
        if command_exists cargo; then
            print_info "Installing lsd via cargo..."
            cargo install lsd
        else
            print_warning "cargo not available"
            print_info "Install Rust first: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
            print_warning "lsd installation skipped"
        fi
    else
        print_success "lsd already installed"
    fi

    # bat
    if ! command_exists bat && ! command_exists batcat; then
        print_info "Installing bat..."
        sudo apt install -y bat
        # Ubuntu installs as 'batcat' due to name conflict
        if command_exists batcat && ! command_exists bat; then
            mkdir -p ~/.local/bin
            ln -sf /usr/bin/batcat ~/.local/bin/bat
        fi
    else
        print_success "bat already installed"
    fi

    # neofetch
    if ! command_exists neofetch; then
        print_info "Installing neofetch..."
        sudo apt install -y neofetch
    else
        print_success "neofetch already installed"
    fi

    # lazygit
    if ! command_exists lazygit; then
        print_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    else
        print_success "lazygit already installed"
    fi

    print_success "Ubuntu/Debian tools installed successfully"
}

# Install tools on Fedora/RHEL
install_fedora() {
    print_info "Installing tools for Fedora/RHEL..."

    print_info "Installing terminal tools..."
    sudo dnf install -y bat neofetch

    # lsd
    if ! command_exists lsd; then
        if command_exists cargo; then
            print_info "Installing lsd via cargo..."
            cargo install lsd
        else
            print_warning "lsd installation skipped (cargo not available)"
        fi
    else
        print_success "lsd already installed"
    fi

    # lazygit
    if ! command_exists lazygit; then
        print_info "Installing lazygit..."
        sudo dnf copr enable atim/lazygit -y
        sudo dnf install -y lazygit
    else
        print_success "lazygit already installed"
    fi

    print_success "Fedora/RHEL tools installed successfully"
}

# Install tools on Arch/Manjaro
install_arch() {
    print_info "Installing tools for Arch/Manjaro..."

    print_info "Installing terminal tools..."
    sudo pacman -Sy --noconfirm lsd bat neofetch lazygit

    print_success "Arch/Manjaro tools installed successfully"
}

# Install uv (Python package manager)
install_uv() {
    print_info "Installing uv (Python package manager)..."

    if command_exists uv; then
        print_success "uv is already installed"
        uv --version
        return 0
    fi

    print_info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Add to PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Verify installation
    if command_exists uv; then
        print_success "uv installed successfully"
        uv --version
    else
        print_warning "uv installation may have failed"
    fi
}

# Setup lsd configuration
setup_lsd_config() {
    print_info "Setting up lsd configuration..."

    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local LSD_CONFIG_DIR="$HOME/.config/lsd"

    # Create lsd config directory
    mkdir -p "$LSD_CONFIG_DIR"

    # Symlink config files
    if [[ -f "$SCRIPT_DIR/lsd/config.yaml" ]]; then
        ln -sf "$SCRIPT_DIR/lsd/config.yaml" "$LSD_CONFIG_DIR/config.yaml"
        print_success "Linked lsd config.yaml"
    fi

    if [[ -f "$SCRIPT_DIR/lsd/colors.yaml" ]]; then
        ln -sf "$SCRIPT_DIR/lsd/colors.yaml" "$LSD_CONFIG_DIR/colors.yaml"
        print_success "Linked lsd colors.yaml (Dracula theme)"
    fi
}

# Setup shell aliases
setup_aliases() {
    print_info "Setting up shell aliases..."

    # Determine shell configuration file
    local shell_config=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi

    # Check if aliases already exist
    if grep -q "# Custom Aliases - Enhanced Terminal Tools" "$shell_config" 2>/dev/null; then
        print_warning "Aliases already exist in $shell_config"
        return 0
    fi

    # Add aliases
    local ALIASES='
# ===============================================
# Custom Aliases - Enhanced Terminal Tools
# ===============================================

# Remove background color for other-writable directories
export LS_COLORS="ow=01;34:tw=01;34:st=01;34"

alias ls="lsd --no-symlink"
alias ll="lsd -l --no-symlink"
alias la="lsd -la --no-symlink"
alias lt="lsd --tree --no-symlink"
alias cat="bat"

# ===============================================
'

    echo "$ALIASES" >> "$shell_config"
    print_success "Aliases added to $shell_config"
    print_info "Run 'source $shell_config' to apply changes"
}

# Main installation function
main() {
    echo "============================================================================="
    echo "  Terminal Tools Installation"
    echo "  Installing: lsd, bat, neofetch, lazygit, uv"
    echo "============================================================================="
    echo ""

    local os=$(detect_os)
    print_info "Detected OS: $os"

    if [[ "$os" == "macos" ]]; then
        install_macos
    elif [[ "$os" == "linux" ]]; then
        local distro=$(detect_linux_distro)
        print_info "Detected Linux distribution: $distro"

        case $distro in
            ubuntu|debian|pop)
                install_ubuntu_debian
                ;;
            fedora|centos|rhel)
                install_fedora
                ;;
            arch|manjaro)
                install_arch
                ;;
            *)
                print_error "Unsupported Linux distribution: $distro"
                print_info "Please install tools manually:"
                echo "  - lsd: https://github.com/lsd-rs/lsd"
                echo "  - bat: https://github.com/sharkdp/bat"
                echo "  - neofetch: https://github.com/dylanaraps/neofetch"
                echo "  - lazygit: https://github.com/jesseduffield/lazygit"
                exit 1
                ;;
        esac
    else
        print_error "Unsupported operating system: $os"
        exit 1
    fi

    echo ""
    install_uv

    echo ""
    setup_lsd_config

    echo ""
    setup_aliases

    echo ""
    echo "============================================================================="
    print_success "Installation completed successfully!"
    echo "============================================================================="
    echo ""
    print_info "Installed tools:"
    command_exists lsd && echo "  ✓ lsd $(lsd --version 2>/dev/null | head -1)"
    command_exists bat && echo "  ✓ bat $(bat --version 2>/dev/null)"
    command_exists batcat && echo "  ✓ bat (as batcat)"
    command_exists neofetch && echo "  ✓ neofetch"
    command_exists lazygit && echo "  ✓ lazygit"
    command_exists uv && echo "  ✓ uv $(uv --version 2>/dev/null)"
    echo ""
    print_info "Restart your terminal or run: source ~/.zshrc (or ~/.bashrc)"
}

# Run main function
main "$@"
