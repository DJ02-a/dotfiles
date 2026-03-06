#!/bin/bash

# =============================================================================
# SuperClaude Uninstaller
# =============================================================================
# Removes SuperClaude Framework and all related files
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "============================================================================="
echo "  SuperClaude Uninstaller"
echo "============================================================================="
echo ""

# 1. Remove SuperClaude virtual environment
if [[ -d "$HOME/.superclaude-env" ]]; then
    print_info "Removing SuperClaude virtual environment..."
    rm -rf "$HOME/.superclaude-env"
    print_success "Removed ~/.superclaude-env"
else
    print_warning "~/.superclaude-env not found, skipping"
fi

# 2. Uninstall SuperClaude pip package (user install)
if python3 -c "import SuperClaude" 2>/dev/null; then
    print_info "Uninstalling SuperClaude pip package..."
    python3 -m pip uninstall -y SuperClaude 2>/dev/null || true
    print_success "SuperClaude pip package removed"
else
    print_warning "SuperClaude pip package not found, skipping"
fi

# 3. Remove SuperClaude config files
superclaude_config_dirs=(
    "$HOME/.superclaude"
    "$HOME/.config/superclaude"
    "$HOME/.config/SuperClaude"
)

for dir in "${superclaude_config_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        print_info "Removing config directory: $dir"
        rm -rf "$dir"
        print_success "Removed $dir"
    fi
done

# 4. Remove SuperClaude commands from Claude config
claude_config_dir="$HOME/.claude"
if [[ -d "$claude_config_dir" ]]; then
    # Remove any SuperClaude-generated command files
    find "$claude_config_dir" -name "*superclaude*" -o -name "*SuperClaude*" -o -name "*sc:*" 2>/dev/null | while read -r f; do
        print_info "Removing: $f"
        rm -rf "$f"
        print_success "Removed $f"
    done
fi

# 5. Remove SuperClaude command directories
superclaude_command_dirs=(
    "$HOME/.claude/commands/deploy"
    "$HOME/.claude/commands/dev"
    "$HOME/.claude/commands/docs"
    "$HOME/.claude/commands/performance"
    "$HOME/.claude/commands/project"
    "$HOME/.claude/commands/security"
    "$HOME/.claude/commands/setup"
    "$HOME/.claude/commands/simulation"
    "$HOME/.claude/commands/sync"
    "$HOME/.claude/commands/team"
    "$HOME/.claude/commands/test"
    "$HOME/.claude/commands/README.md"
)

for item in "${superclaude_command_dirs[@]}"; do
    if [[ -e "$item" ]]; then
        print_info "Removing: $item"
        rm -rf "$item"
        print_success "Removed $item"
    fi
done

# 6. Remove sc-help alias from shell configs
for shell_config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [[ -f "$shell_config" ]]; then
        if grep -q "sc-help\|superclaude\|SuperClaude" "$shell_config" 2>/dev/null; then
            print_info "Cleaning SuperClaude references from $shell_config"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' '/sc-help/d' "$shell_config" 2>/dev/null || true
                sed -i '' '/superclaude/Id' "$shell_config" 2>/dev/null || true
            else
                sed -i '/sc-help/d' "$shell_config" 2>/dev/null || true
                sed -i '/superclaude/Id' "$shell_config" 2>/dev/null || true
            fi
            print_success "Cleaned $shell_config"
        fi
    fi
done

echo ""
echo "============================================================================="
print_success "SuperClaude has been completely removed."
echo "============================================================================="
echo ""
print_info "Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
