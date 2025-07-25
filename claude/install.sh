#!/bin/bash

# =============================================================================
# Claude Tools Installation Script - install.bash
# =============================================================================
# This script installs Claudia and SuperClaude Framework
# Supports: Linux, macOS with automated dependency management
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
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

# Check and install system dependencies
install_system_dependencies() {
    print_step "Installing system dependencies..."
    
    local os=$(detect_os)
    
    if [[ "$os" == "linux" ]]; then
        local distro=$(detect_linux_distro)
        
        case $distro in
            ubuntu|debian)
                print_info "Installing dependencies for Ubuntu/Debian..."
                sudo apt update
                sudo apt install -y \
                    curl \
                    wget \
                    git \
                    build-essential \
                    libssl-dev \
                    pkg-config \
                    libwebkit2gtk-4.1-dev \
                    libgtk-3-dev \
                    libayatana-appindicator3-dev \
                    librsvg2-dev \
                    patchelf \
                    file \
                    libxdo-dev \
                    libsoup-3.0-dev \
                    libjavascriptcoregtk-4.1-dev \
                    python3 \
                    python3-pip \
                    python3-venv
                ;;
            arch|manjaro)
                print_info "Installing dependencies for Arch/Manjaro..."
                sudo pacman -Sy --noconfirm \
                    curl \
                    wget \
                    git \
                    base-devel \
                    openssl \
                    pkg-config \
                    webkit2gtk-4.1 \
                    gtk3 \
                    libayatana-appindicator \
                    librsvg \
                    patchelf \
                    file \
                    xdotool \
                    python \
                    python-pip
                ;;
            fedora|centos|rhel)
                print_info "Installing dependencies for Fedora/RHEL..."
                sudo dnf install -y \
                    curl \
                    wget \
                    git \
                    gcc \
                    openssl-devel \
                    pkg-config \
                    webkit2gtk4.1-devel \
                    gtk3-devel \
                    libappindicator-gtk3-devel \
                    librsvg2-devel \
                    patchelf \
                    file \
                    xdotool-devel \
                    python3 \
                    python3-pip
                ;;
            *)
                print_warning "Unknown Linux distribution: $distro"
                print_info "Please install dependencies manually:"
                echo "  - curl, wget, git"
                echo "  - build tools (gcc, make)"
                echo "  - webkit2gtk, gtk3"
                echo "  - python3, python3-pip"
                ;;
        esac
    elif [[ "$os" == "macos" ]]; then
        print_info "Installing dependencies for macOS..."
        
        # Install Xcode Command Line Tools
        if ! xcode-select -p &>/dev/null; then
            print_info "Installing Xcode Command Line Tools..."
            xcode-select --install
        fi
        
        # Install Homebrew if not present
        if ! command_exists brew; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # Install dependencies via Homebrew
        brew install git curl wget python3
    else
        print_error "Unsupported operating system: $os"
        exit 1
    fi
    
    print_success "System dependencies installed"
}

# Install Rust
install_rust() {
    print_step "Installing Rust..."
    
    if command_exists rustc && command_exists cargo; then
        print_warning "Rust is already installed"
        rustc --version
        return 0
    fi
    
    print_info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # Source cargo environment
    source ~/.cargo/env || export PATH="$HOME/.cargo/bin:$PATH"
    
    # Verify installation
    if command_exists rustc && command_exists cargo; then
        print_success "Rust installed successfully"
        rustc --version
    else
        print_error "Rust installation failed"
        return 1
    fi
}

# Install Bun
install_bun() {
    print_step "Installing Bun..."
    
    if command_exists bun; then
        print_warning "Bun is already installed"
        bun --version
        return 0
    fi
    
    print_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    
    # Add to PATH
    export PATH="$HOME/.bun/bin:$PATH"
    
    # Verify installation
    if command_exists bun; then
        print_success "Bun installed successfully"
        bun --version
    else
        print_error "Bun installation failed"
        return 1
    fi
}

# Install UV (Python package manager)
install_uv() {
    print_step "Installing UV (Python package manager)..."
    
    if command_exists uv; then
        print_warning "UV is already installed"
        uv --version
        return 0
    fi
    
    print_info "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add to PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Verify installation
    if command_exists uv; then
        print_success "UV installed successfully"
        uv --version
    else
        print_error "UV installation failed"
        return 1
    fi
}

# Check Claude Code CLI and find working path
check_claude_cli() {
    print_step "Checking Claude Code CLI..."
    
    # Remove any conflicting aliases first
    unalias claude 2>/dev/null || true
    
    # Define possible Claude CLI locations in order of preference
    local claude_paths=(
        "/opt/homebrew/bin/claude"           # Homebrew on Apple Silicon Mac
        "/usr/local/bin/claude"              # Homebrew on Intel Mac / Manual install
        "/usr/bin/claude"                    # System-wide install
        "$(brew --prefix 2>/dev/null)/bin/claude"  # Homebrew auto-detect
        "$HOME/.local/bin/claude"            # User local install
        "/opt/claude/bin/claude"             # Custom install location
    )
    
    local working_claude=""
    
    print_info "Searching for working Claude CLI..."
    
    # Test each possible path
    for path in "${claude_paths[@]}"; do
        if [[ -n "$path" && -f "$path" && -x "$path" ]]; then
            print_info "Testing: $path"
            if "$path" --version &>/dev/null 2>&1; then
                working_claude="$path"
                print_success "✓ Working Claude CLI found at: $path"
                break
            else
                print_warning "⚠ File exists but not working: $path"
            fi
        fi
    done
    
    # If no working Claude found, check if it's aliased incorrectly
    if [[ -z "$working_claude" ]]; then
        if alias claude 2>/dev/null | grep -q "web_search"; then
            print_error "Claude CLI is incorrectly aliased to web_search"
            print_info "Removing incorrect alias..."
            unalias claude
            
            # Remove from shell config files (macOS compatible)
            local os=$(detect_os)
            if [[ "$os" == "macos" ]]; then
                sed -i '' '/alias claude.*web_search/d' ~/.bashrc 2>/dev/null || true
                sed -i '' '/alias claude.*web_search/d' ~/.zshrc 2>/dev/null || true
            else
                sed -i '/alias claude.*web_search/d' ~/.bashrc 2>/dev/null || true
                sed -i '/alias claude.*web_search/d' ~/.zshrc 2>/dev/null || true
            fi
            
            # Try again after removing conflicting alias
            for path in "${claude_paths[@]}"; do
                if [[ -n "$path" && -f "$path" && -x "$path" ]]; then
                    if "$path" --version &>/dev/null 2>&1; then
                        working_claude="$path"
                        print_success "✓ Working Claude CLI found after alias cleanup: $path"
                        break
                    fi
                fi
            done
        fi
    fi
    
    if [[ -n "$working_claude" ]]; then
        # Store the working path for later use
        export CLAUDE_CLI_PATH="$working_claude"
        print_success "Claude Code CLI verified: $working_claude"
        "$working_claude" --version 2>/dev/null || true
        return 0
    else
        print_error "No working Claude Code CLI found"
        print_info "Please install Claude Code CLI from: https://claude.ai/code"
        print_info "Ensure 'claude' command is available in your PATH"
        print_warning "Make sure there are no conflicting aliases for 'claude'"
        return 1
    fi
}

# Install Claudia (GUI for Claude Code)
install_claudia() {
    print_step "Installing Claudia..."
    
    # Check if Claudia is already installed
    if [[ -d "$HOME/claudia" ]]; then
        print_warning "Claudia directory already exists at $HOME/claudia"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping Claudia installation"
            return 0
        fi
        rm -rf "$HOME/claudia"
    fi
    
    print_info "Cloning Claudia repository..."
    git clone https://github.com/getAsterisk/claudia.git "$HOME/claudia"
    
    cd "$HOME/claudia"
    
    print_info "Installing frontend dependencies..."
    bun install
    
    print_info "Building Claudia..."
    bun run tauri build
    
    # Create symlink for easy access
    local os=$(detect_os)
    local executable_path=""
    
    if [[ "$os" == "linux" ]]; then
        executable_path="$HOME/claudia/src-tauri/target/release/claudia"
    elif [[ "$os" == "macos" ]]; then
        executable_path="$HOME/claudia/src-tauri/target/release/claudia"
    fi
    
    if [[ -f "$executable_path" ]]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$executable_path" "$HOME/.local/bin/claudia"
        print_success "Claudia installed successfully"
        print_info "You can run Claudia with: claudia"
    else
        print_error "Claudia build failed - executable not found"
        return 1
    fi
}

# Install SuperClaude Framework
install_superclaude() {
    print_step "Installing SuperClaude Framework..."
    
    # Check if SuperClaude is already installed
    if python3 -c "import SuperClaude" 2>/dev/null; then
        print_warning "SuperClaude is already installed"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping SuperClaude installation"
            return 0
        fi
    fi
    
    print_info "Installing SuperClaude via UV..."
    
    # Create virtual environment if using UV
    if command_exists uv; then
        uv venv ~/.superclaude-env --python python3
        source ~/.superclaude-env/bin/activate
        uv pip install SuperClaude
    else
        # Fallback to pip
        print_warning "UV not available, using pip..."
        python3 -m pip install --user SuperClaude
    fi
    
    print_info "Configuring SuperClaude..."
    
    # Run SuperClaude installer
    if command_exists uv && [[ -f ~/.superclaude-env/bin/activate ]]; then
        source ~/.superclaude-env/bin/activate
        python3 -m SuperClaude install --profile developer
    else
        python3 -m SuperClaude install --profile developer
    fi
    
    print_success "SuperClaude Framework installed successfully"
    print_info "SuperClaude commands are now available in Claude Code"
}

# Setup Claude CLI alias with correct path
setup_claude_alias() {
    print_step "Setting up Claude CLI alias..."
    
    # Determine shell configuration file
    local shell_config=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi
    
    # Remove any existing Claude alias configurations
    local os=$(detect_os)
    if [[ "$os" == "macos" ]]; then
        sed -i '' '/# Override Oh My Zsh web-search claude alias/d' "$shell_config" 2>/dev/null || true
        sed -i '' '/# Claude CLI - Auto-detected/d' "$shell_config" 2>/dev/null || true
        sed -i '' '/unalias claude/d' "$shell_config" 2>/dev/null || true
        sed -i '' '/alias claude=/d' "$shell_config" 2>/dev/null || true
    else
        sed -i '/# Override Oh My Zsh web-search claude alias/d' "$shell_config" 2>/dev/null || true
        sed -i '/# Claude CLI - Auto-detected/d' "$shell_config" 2>/dev/null || true
        sed -i '/unalias claude/d' "$shell_config" 2>/dev/null || true
        sed -i '/alias claude=/d' "$shell_config" 2>/dev/null || true
    fi
    
    # Add correct Claude CLI alias if we found a working path
    if [[ -n "$CLAUDE_CLI_PATH" ]]; then
        {
            echo ""
            echo "# Claude CLI - Auto-detected working path"
            echo "unalias claude 2>/dev/null || true"
            echo "alias claude='$CLAUDE_CLI_PATH'"
        } >> "$shell_config"
        
        # Apply immediately to current session
        unalias claude 2>/dev/null || true
        alias claude="$CLAUDE_CLI_PATH"
        
        print_success "Claude CLI alias configured: $CLAUDE_CLI_PATH"
        
        # Test the alias
        if claude --version &>/dev/null; then
            print_success "✓ Claude CLI alias is working correctly"
        else
            print_warning "⚠ Claude CLI alias may have issues"
        fi
    else
        print_warning "No working Claude CLI path found, skipping alias setup"
    fi
}

# Verify installations
verify_installations() {
    print_step "Verifying installations..."
    
    local failed=0
    
    # Check Claude CLI with the detected path
    if [[ -n "$CLAUDE_CLI_PATH" ]] && [[ -x "$CLAUDE_CLI_PATH" ]]; then
        if "$CLAUDE_CLI_PATH" --version &>/dev/null; then
            print_success "✓ Claude Code CLI is working: $CLAUDE_CLI_PATH"
        else
            print_error "✗ Claude Code CLI found but not working: $CLAUDE_CLI_PATH"
            failed=1
        fi
    elif command_exists claude; then
        if claude --version &>/dev/null; then
            print_success "✓ Claude Code CLI is available via PATH"
        else
            print_error "✗ Claude Code CLI in PATH but not working"
            failed=1
        fi
    else
        print_error "✗ Claude Code CLI not found"
        failed=1
    fi
    
    # Check Claudia
    if [[ -f "$HOME/.local/bin/claudia" ]]; then
        print_success "✓ Claudia is installed"
    else
        print_error "✗ Claudia installation failed"
        failed=1
    fi
    
    # Check SuperClaude
    if python3 -c "import SuperClaude" 2>/dev/null; then
        print_success "✓ SuperClaude Framework is installed"
    else
        print_error "✗ SuperClaude Framework installation failed"
        failed=1
    fi
    
    # Check core dependencies
    if command_exists rustc; then
        print_success "✓ Rust is available"
    else
        print_warning "⚠ Rust not found in PATH"
    fi
    
    if command_exists bun; then
        print_success "✓ Bun is available"
    else
        print_warning "⚠ Bun not found in PATH"
    fi
    
    if command_exists uv; then
        print_success "✓ UV is available"
    else
        print_warning "⚠ UV not found in PATH"
    fi
    
    return $failed
}

# Cleanup function
cleanup_on_error() {
    print_error "Installation failed. Cleaning up..."
    
    # Remove partial installations if they exist
    [[ -d "$HOME/claudia" ]] && rm -rf "$HOME/claudia"
    [[ -d "$HOME/.superclaude-env" ]] && rm -rf "$HOME/.superclaude-env"
    
    print_info "Cleanup completed"
}

# Main installation function
main() {
    echo "============================================================================="
    echo "  Claude Tools Installer"
    echo "  Installing: Claudia + SuperClaude Framework"
    echo "============================================================================="
    echo ""
    
    print_info "Detected OS: $(detect_os)"
    if [[ $(detect_os) == "linux" ]]; then
        print_info "Detected Linux distribution: $(detect_linux_distro)"
    fi
    echo ""
    
    # Set trap for cleanup on error
    trap cleanup_on_error ERR
    
    # Installation steps
    install_system_dependencies
    echo ""
    
    install_rust
    echo ""
    
    install_bun
    echo ""
    
    install_uv
    echo ""
    
    check_claude_cli
    echo ""
    
    install_claudia
    echo ""
    
# Add PATH exports to shell configuration
setup_environment() {
    print_step "Setting up environment..."
    
    # Determine shell configuration file
    local shell_config=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi
    
    # Remove any existing Claude Tools environment setup
    local os=$(detect_os)
    if [[ "$os" == "macos" ]]; then
        sed -i '' '/# Claude Tools Environment/,/^$/d' "$shell_config" 2>/dev/null || true
    else
        sed -i '/# Claude Tools Environment/,/^$/d' "$shell_config" 2>/dev/null || true
    fi
    
    # Add necessary PATH exports
    {
        echo ""
        echo "# Claude Tools Environment - Added by installer"
        echo 'export PATH="$HOME/.cargo/bin:$PATH"'
        echo 'export PATH="$HOME/.bun/bin:$PATH"'
        echo 'export PATH="$HOME/.local/bin:$PATH"'
        echo ""
        echo "# Claude Tools aliases (safe versions)"
        echo "alias claudia-gui='claudia'  # Launch Claudia GUI"
        if [[ -n "$CLAUDE_CLI_PATH" ]]; then
            echo "alias sc-help='$CLAUDE_CLI_PATH /sc:help'  # SuperClaude help"
        else
            echo "# alias sc-help='claude /sc:help'  # SuperClaude help (claude CLI not found)"
        fi
        echo ""
    } >> "$shell_config"
    
    print_success "Environment setup completed"
    print_info "Shell configuration updated: $shell_config"
}
    
    # Verify installation
    if verify_installations; then
        echo ""
        echo "============================================================================="
        print_success "🎉 Installation completed successfully!"
        echo "============================================================================="
        echo ""
        print_info "Installed tools:"
        echo "  • Claudia - GUI for Claude Code"
        echo "  • SuperClaude Framework - Enhanced Claude Code with specialized commands"
        echo ""
        print_info "Next steps:"
        echo "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
        echo "  2. Launch Claudia: claudia"
        echo "  3. Use SuperClaude commands in Claude Code (e.g., /sc:help)"
        if [[ -n "$CLAUDE_CLI_PATH" ]]; then
            echo "  4. Claude CLI is available at: $CLAUDE_CLI_PATH"
        fi
        echo ""
        print_info "Documentation:"
        echo "  • Claudia: https://github.com/getAsterisk/claudia"
        echo "  • SuperClaude: https://github.com/SuperClaude-Org/SuperClaude_Framework"
        echo ""
    else
        print_error "❌ Some installations failed. Please check the error messages above."
        exit 1
    fi
    
    # Remove trap
    trap - ERR
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        echo "Claude Tools Installer"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --verify, -v   Verify installations only"
        echo ""
        echo "This script installs:"
        echo "  • Claudia - GUI application for Claude Code"
        echo "  • SuperClaude Framework - Enhanced commands for Claude Code"
        echo ""
        exit 0
        ;;
    --verify|-v)
        verify_installations
        exit $?
        ;;
    *)
        main "$@"
        ;;
esac
