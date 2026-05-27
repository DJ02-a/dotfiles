#!/bin/bash
# ==============================================================================
# Oh My Zsh + Powerlevel10k → Zinit + Starship 레거시 정리 스크립트
# ==============================================================================
# 실행 전: 새 환경(Zinit + Starship)이 정상 동작하는지 먼저 확인하세요.
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1"; }

confirm() {
    read -p "$(echo -e "${YELLOW}$1 [y/N]:${NC} ")" -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

BACKUP_DIR="$HOME/.legacy-shell-backup-$(date +%Y%m%d_%H%M%S)"

echo ""
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}  Oh My Zsh + Powerlevel10k 레거시 정리${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""
print_warning "이 스크립트는 아래 항목을 제거합니다:"
echo "  • Oh My Zsh  (~/.oh-my-zsh)"
echo "  • Powerlevel10k  (~/powerlevel10k)"
echo "  • p10k 설정  (~/.p10k.zsh)"
echo "  • ~/.zshrc.pre-oh-my-zsh (OMZ가 생성한 백업 파일)"
echo ""
print_warning "삭제 전 '$BACKUP_DIR' 에 백업합니다."
echo ""

if ! confirm "계속 진행하시겠습니까?"; then
    print_info "취소되었습니다."
    exit 0
fi

mkdir -p "$BACKUP_DIR"
print_info "백업 디렉토리 생성: $BACKUP_DIR"
echo ""

# ==============================================================================
# 1. 새 환경 동작 확인
# ==============================================================================
print_info "새 환경 확인 중..."

if ! command -v zinit >/dev/null 2>&1 && [ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git" ]; then
    print_error "Zinit이 설치되지 않았습니다. 먼저 install.sh를 실행하세요."
    exit 1
fi

if ! command -v starship >/dev/null 2>&1; then
    print_error "Starship이 설치되지 않았습니다. 먼저 install.sh를 실행하세요."
    exit 1
fi

if [ ! -L "$HOME/.zshrc" ] || [ "$(readlink "$HOME/.zshrc")" != "$HOME/.config/dotfiles/zsh/.zshrc" ]; then
    print_error "~/.zshrc가 dotfiles로 심볼릭 링크되지 않았습니다."
    print_info "먼저 install.sh를 실행하세요."
    exit 1
fi

print_success "Zinit: 설치됨"
print_success "Starship: $(starship --version)"
print_success "~/.zshrc: dotfiles 링크 확인됨"
echo ""

# ==============================================================================
# 2. Oh My Zsh 제거
# ==============================================================================
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_info "Oh My Zsh 백업 중..."
    # 플러그인 목록만 백업 (전체는 너무 큼)
    ls "$HOME/.oh-my-zsh/custom/plugins/" > "$BACKUP_DIR/omz-custom-plugins.txt" 2>/dev/null || true
    ls "$HOME/.oh-my-zsh/custom/themes/"  > "$BACKUP_DIR/omz-custom-themes.txt"  2>/dev/null || true

    if confirm "Oh My Zsh (~/.oh-my-zsh) 를 삭제하시겠습니까?"; then
        rm -rf "$HOME/.oh-my-zsh"
        print_success "Oh My Zsh 삭제 완료"
    else
        print_warning "Oh My Zsh 건너뜀"
    fi
else
    print_info "Oh My Zsh가 없습니다. 건너뜁니다."
fi

# ==============================================================================
# 3. Powerlevel10k 제거
# ==============================================================================
if [ -d "$HOME/powerlevel10k" ]; then
    if confirm "Powerlevel10k (~/powerlevel10k) 를 삭제하시겠습니까?"; then
        rm -rf "$HOME/powerlevel10k"
        print_success "Powerlevel10k 삭제 완료"
    else
        print_warning "Powerlevel10k 건너뜀"
    fi
else
    print_info "~/powerlevel10k 가 없습니다. 건너뜁니다."
fi

# ==============================================================================
# 4. p10k 설정 파일 제거
# ==============================================================================
if [ -f "$HOME/.p10k.zsh" ]; then
    cp "$HOME/.p10k.zsh" "$BACKUP_DIR/.p10k.zsh"
    print_info "~/.p10k.zsh → 백업 완료"

    if confirm "~/.p10k.zsh 를 삭제하시겠습니까?"; then
        rm "$HOME/.p10k.zsh"
        print_success "~/.p10k.zsh 삭제 완료"
    else
        print_warning "~/.p10k.zsh 건너뜀"
    fi
else
    print_info "~/.p10k.zsh 가 없습니다. 건너뜁니다."
fi

# ==============================================================================
# 5. OMZ가 생성한 zshrc 백업 파일 제거
# ==============================================================================
if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
    cp "$HOME/.zshrc.pre-oh-my-zsh" "$BACKUP_DIR/.zshrc.pre-oh-my-zsh"
    print_info "~/.zshrc.pre-oh-my-zsh → 백업 완료"

    if confirm "~/.zshrc.pre-oh-my-zsh 를 삭제하시겠습니까?"; then
        rm "$HOME/.zshrc.pre-oh-my-zsh"
        print_success "~/.zshrc.pre-oh-my-zsh 삭제 완료"
    else
        print_warning "건너뜀"
    fi
fi

# ==============================================================================
# 6. p10k 캐시 정리
# ==============================================================================
P10K_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USER}.zsh"
if [ -f "$P10K_CACHE" ]; then
    rm -f "$P10K_CACHE"
    print_success "p10k 캐시 삭제 완료"
fi

# ==============================================================================
# 완료
# ==============================================================================
echo ""
echo -e "${GREEN}================================================================${NC}"
print_success "레거시 정리 완료!"
echo -e "${GREEN}================================================================${NC}"
echo ""
print_info "백업 위치: $BACKUP_DIR"
echo ""
print_info "새 터미널을 열거나 아래 명령어로 적용하세요:"
echo "  exec zsh"
echo ""
