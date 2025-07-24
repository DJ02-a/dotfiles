#!/bin/bash

# =============================================================================
# Dotfile Installation Script for k9s and lazydocker
# =============================================================================
# This script installs k9s (Kubernetes CLI) and lazydocker (Docker TUI)
# Supports: Linux, macOS, and detection of package managers
# =============================================================================

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

# Install lazydocker
install_lazydocker() {
    print_info "Installing lazydocker..."
    
    local os=$(detect_os)
    
    if command_exists lazydocker; then
        print_warning "lazydocker is already installed"
        lazydocker --version
        return 0
    fi
    
    # Try package managers first
    if command_exists brew; then
        print_info "Installing lazydocker via Homebrew..."
        if brew tap jesseduffield/lazydocker; then
            brew install jesseduffield/lazydocker/lazydocker
            print_success "lazydocker installed via Homebrew"
            return 0
        fi
    fi
    
    if [[ "$os" == "linux" ]]; then
        local distro=$(detect_linux_distro)
        
        # Try package managers for specific distributions
        case $distro in
            arch|manjaro)
                if command_exists yay; then
                    print_info "Installing lazydocker via yay (AUR)..."
                    yay -S lazydocker --noconfirm
                    print_success "lazydocker installed via AUR"
                    return 0
                elif command_exists pacman; then
                    print_warning "Consider installing yay for AUR access"
                fi
                ;;
            ubuntu|debian)
                # No native package available, will fall back to binary
                ;;
        esac
        
        # Fallback to binary installation on Linux
        print_info "Installing lazydocker via binary download..."
        curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            print_info "Adding $HOME/.local/bin to PATH"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
        fi
        
        print_success "lazydocker installed via binary"
    else
        # Try Go installation if available
        if command_exists go; then
            print_info "Installing lazydocker via Go..."
            go install github.com/jesseduffield/lazydocker@latest
            print_success "lazydocker installed via Go"
        else
            print_error "Cannot install lazydocker: no suitable installation method found"
            return 1
        fi
    fi
}

# Install k9s
install_k9s() {
    print_info "Installing k9s..."
    
    local os=$(detect_os)
    
    if command_exists k9s; then
        print_warning "k9s is already installed"
        k9s version
        return 0
    fi
    
    # Try package managers first
    if command_exists brew; then
        print_info "Installing k9s via Homebrew..."
        brew install derailed/k9s/k9s
        print_success "k9s installed via Homebrew"
        return 0
    fi
    
    if [[ "$os" == "linux" ]]; then
        local distro=$(detect_linux_distro)
        
        # Try package managers for specific distributions
        case $distro in
            arch|manjaro)
                if command_exists pacman; then
                    print_info "Installing k9s via pacman..."
                    sudo pacman -S k9s --noconfirm
                    print_success "k9s installed via pacman"
                    return 0
                fi
                ;;
            ubuntu|debian)
                print_info "Installing k9s via wget and apt..."
                wget -q https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb -O /tmp/k9s.deb
                sudo apt install /tmp/k9s.deb -y
                rm /tmp/k9s.deb
                print_success "k9s installed via apt"
                return 0
                ;;
            opensuse*)
                if command_exists zypper; then
                    print_info "Installing k9s via zypper..."
                    sudo zypper install k9s -y
                    print_success "k9s installed via zypper"
                    return 0
                fi
                ;;
            fedora|centos|rhel)
                # No native package, fall back to binary
                ;;
        esac
        
        # Fallback to binary installation
        print_info "Installing k9s via binary download..."
        install_k9s_binary "linux"
    elif [[ "$os" == "macos" ]]; then
        # Try MacPorts
        if command_exists port; then
            print_info "Installing k9s via MacPorts..."
            sudo port install k9s
            print_success "k9s installed via MacPorts"
            return 0
        fi
        
        # Fallback to binary
        print_info "Installing k9s via binary download..."
        install_k9s_binary "darwin"
    else
        print_error "Unsupported operating system for k9s installation"
        return 1
    fi
}

# Install k9s binary
install_k9s_binary() {
    local os=$1
    local arch="amd64"
    
    # Detect architecture
    case $(uname -m) in
        x86_64) arch="amd64" ;;
        arm64|aarch64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *) 
            print_error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac
    
    local binary_name="k9s_${os}_${arch}"
    local download_url="https://github.com/derailed/k9s/releases/latest/download/${binary_name}.tar.gz"
    local install_dir="$HOME/.local/bin"
    
    # Create install directory
    mkdir -p "$install_dir"
    
    # Download and install
    print_info "Downloading k9s binary for ${os}_${arch}..."
    curl -L "$download_url" | tar xz -C /tmp
    mv "/tmp/k9s" "$install_dir/"
    chmod +x "$install_dir/k9s"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        print_info "Adding $install_dir to PATH"
        echo "export PATH=\"$install_dir:\$PATH\"" >> ~/.bashrc
        echo "export PATH=\"$install_dir:\$PATH\"" >> ~/.zshrc 2>/dev/null || true
    fi
    
    print_success "k9s binary installed to $install_dir/k9s"
}

# Create aliases
create_aliases() {
    print_info "Creating convenient aliases..."
    
    local alias_file=""
    if [[ -f ~/.zshrc ]]; then
        alias_file=~/.zshrc
    elif [[ -f ~/.bashrc ]]; then
        alias_file=~/.bashrc
    else
        print_warning "No shell configuration file found, skipping alias creation"
        return 1
    fi
    
    # Check if aliases already exist
    if ! grep -q "alias lzd=" "$alias_file" 2>/dev/null; then
        echo "" >> "$alias_file"
        echo "# Lazydocker alias" >> "$alias_file"
        echo "alias lzd='lazydocker'" >> "$alias_file"
        print_success "Added 'lzd' alias for lazydocker"
    fi
    
    if ! grep -q "alias k9=" "$alias_file" 2>/dev/null; then
        echo "" >> "$alias_file"
        echo "# K9s alias" >> "$alias_file"
        echo "alias k9='k9s'" >> "$alias_file"
        print_success "Added 'k9' alias for k9s"
    fi
}

# Verify installations
verify_installation() {
    print_info "Verifying installations..."
    
    local failed=0
    
    if command_exists lazydocker; then
        print_success "lazydocker is installed and available"
        lazydocker --version 2>/dev/null || true
    else
        print_error "lazydocker installation failed or not in PATH"
        failed=1
    fi
    
    if command_exists k9s; then
        print_success "k9s is installed and available"
        k9s version 2>/dev/null || true
    else
        print_error "k9s installation failed or not in PATH"
        failed=1
    fi
    
    return $failed
}

# Main installation function
main() {
    print_info "Starting installation of k9s and lazydocker..."
    print_info "Detected OS: $(detect_os)"
    
    if [[ $(detect_os) == "linux" ]]; then
        print_info "Detected Linux distribution: $(detect_linux_distro)"
    fi
    
    # Install tools
    install_lazydocker
    install_k9s
    
    # Create aliases
    create_aliases
    
    # Verify installation
    if verify_installation; then
        print_success "Installation completed successfully!"
        echo ""
        print_info "You may need to restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to use the new aliases"
        print_info "Available commands:"
        echo "  • lazydocker (alias: lzd) - Docker TUI"
        echo "  • k9s (alias: k9) - Kubernetes TUI"
    else
        print_error "Some installations failed. Please check the error messages above."
        exit 1
    fi
}

# Run main function
main "$@"
