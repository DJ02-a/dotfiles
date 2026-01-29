#!/bin/bash

# ==========================================
# Neovim Dotfiles Sync Script
# ==========================================
# This script syncs nvim dotfiles from the git repo
# to the actual Neovim configuration directory
# ==========================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory (where dotfiles are)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_NVIM="$SCRIPT_DIR"
TARGET_NVIM="$HOME/.config/nvim"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Neovim Dotfiles Sync Script         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_NVIM" ]; then
    echo -e "${RED}❌ Error: Dotfiles directory not found: $DOTFILES_NVIM${NC}"
    exit 1
fi

# Create backup of current config
BACKUP_DIR="$TARGET_NVIM/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

if [ -d "$TARGET_NVIM" ]; then
    echo -e "${YELLOW}📦 Creating backup...${NC}"
    mkdir -p "$BACKUP_DIR"

    # Backup only important files, not plugged directory
    mkdir -p "$BACKUP_PATH"

    if [ -f "$TARGET_NVIM/init.vim" ]; then
        cp "$TARGET_NVIM/init.vim" "$BACKUP_PATH/"
        echo -e "${GREEN}   ✓ Backed up init.vim${NC}"
    fi

    if [ -d "$TARGET_NVIM/lua" ]; then
        cp -r "$TARGET_NVIM/lua" "$BACKUP_PATH/"
        echo -e "${GREEN}   ✓ Backed up lua/ directory${NC}"
    fi

    echo -e "${GREEN}   ✓ Backup created at: $BACKUP_PATH${NC}"
    echo ""
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_NVIM"
mkdir -p "$TARGET_NVIM/lua/config"

# Sync files
echo -e "${BLUE}🔄 Syncing files...${NC}"

# Sync init.vim
if [ -f "$DOTFILES_NVIM/init.vim" ]; then
    cp "$DOTFILES_NVIM/init.vim" "$TARGET_NVIM/init.vim"
    echo -e "${GREEN}   ✓ Synced init.vim${NC}"
fi

# Sync lua config files
if [ -d "$DOTFILES_NVIM/lua" ]; then
    cp -r "$DOTFILES_NVIM/lua/"* "$TARGET_NVIM/lua/" 2>/dev/null || true
    echo -e "${GREEN}   ✓ Synced lua/ directory${NC}"
fi

# Verify sync
echo ""
echo -e "${BLUE}🔍 Verifying sync...${NC}"

ERRORS=0

if diff -q "$DOTFILES_NVIM/init.vim" "$TARGET_NVIM/init.vim" > /dev/null 2>&1; then
    echo -e "${GREEN}   ✓ init.vim synced correctly${NC}"
else
    echo -e "${RED}   ✗ init.vim sync failed${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "$DOTFILES_NVIM/lua/config/dashboard.lua" ] && [ -f "$TARGET_NVIM/lua/config/dashboard.lua" ]; then
    if diff -q "$DOTFILES_NVIM/lua/config/dashboard.lua" "$TARGET_NVIM/lua/config/dashboard.lua" > /dev/null 2>&1; then
        echo -e "${GREEN}   ✓ dashboard.lua synced correctly${NC}"
    else
        echo -e "${RED}   ✗ dashboard.lua sync failed${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi

if [ -f "$DOTFILES_NVIM/lua/config/neotree.lua" ] && [ -f "$TARGET_NVIM/lua/config/neotree.lua" ]; then
    if diff -q "$DOTFILES_NVIM/lua/config/neotree.lua" "$TARGET_NVIM/lua/config/neotree.lua" > /dev/null 2>&1; then
        echo -e "${GREEN}   ✓ neotree.lua synced correctly${NC}"
    else
        echo -e "${RED}   ✗ neotree.lua sync failed${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi

echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ Sync completed successfully!      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}💡 Please restart Neovim to apply changes${NC}"
    echo ""

    # Show backup location
    echo -e "${BLUE}📁 Backup location:${NC}"
    echo -e "   $BACKUP_PATH"
    echo ""

    # Cleanup old backups (keep last 5)
    echo -e "${BLUE}🧹 Cleaning up old backups (keeping last 5)...${NC}"
    cd "$BACKUP_DIR"
    ls -t | tail -n +6 | xargs -r rm -rf
    BACKUP_COUNT=$(ls -1 | wc -l)
    echo -e "${GREEN}   ✓ Total backups: $BACKUP_COUNT${NC}"

    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ❌ Sync completed with errors        ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Please check the errors above${NC}"
    exit 1
fi
