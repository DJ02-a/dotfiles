#!/bin/bash

# tmux 설정 자동 설치 스크립트
# 사용법: ./setup_tmux.sh

set -e  # 에러 발생 시 스크립트 종료

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_status() {
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

# 현재 디렉토리의 .tmux.conf 파일 확인
check_tmux_conf() {
    if [ ! -f ".tmux.conf" ]; then
        print_error "현재 디렉토리에 .tmux.conf 파일이 없습니다."
        exit 1
    fi
    print_success ".tmux.conf 파일을 찾았습니다."
}

# tmux 설치 확인
check_tmux_installed() {
    if ! command -v tmux &> /dev/null; then
        print_warning "tmux가 설치되지 않았습니다. 설치를 진행합니다..."
        if command -v brew &> /dev/null; then
            brew install tmux
        else
            print_error "Homebrew가 설치되지 않았습니다. 수동으로 tmux를 설치해주세요."
            exit 1
        fi
    fi
    print_success "tmux가 설치되어 있습니다."
}

# 기존 설정 파일 백업
backup_existing_config() {
    if [ -f "$HOME/.tmux.conf" ]; then
        if [ -L "$HOME/.tmux.conf" ]; then
            print_warning "기존 심볼릭 링크를 제거합니다: $HOME/.tmux.conf"
            rm "$HOME/.tmux.conf"
        else
            print_warning "기존 .tmux.conf 파일을 백업합니다."
            mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
            print_success "백업 완료: $HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    fi
}

# 심볼릭 링크 생성
create_symlink() {
    local current_dir=$(pwd)
    local source_file="$current_dir/.tmux.conf"
    local target_file="$HOME/.tmux.conf"
    
    print_status "심볼릭 링크 생성 중..."
    ln -sf "$source_file" "$target_file"
    print_success "심볼릭 링크 생성 완료: $target_file -> $source_file"
}

# TPM 설치
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    if [ -d "$tpm_dir" ]; then
        print_warning "TPM이 이미 설치되어 있습니다. 업데이트를 진행합니다..."
        cd "$tpm_dir"
        git pull
        cd - > /dev/null
    else
        print_status "TPM 설치 중..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        print_success "TPM 설치 완료"
    fi
}

# tmux 세션 종료
kill_tmux_sessions() {
    if pgrep -x tmux > /dev/null; then
        print_warning "기존 tmux 세션들을 종료합니다..."
        tmux kill-server 2>/dev/null || true
        sleep 1
    fi
}

# 플러그인 설치
install_plugins() {
    print_status "tmux 플러그인 설치 중..."
    
    # 백그라운드에서 tmux 서버 시작
    tmux new-session -d -s temp_session 2>/dev/null || true
    sleep 2
    
    # 플러그인 설치 스크립트 실행
    "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
    
    # 임시 세션 종료
    tmux kill-session -t temp_session 2>/dev/null || true
    
    print_success "플러그인 설치 완료"
}

# 설정 테스트
test_configuration() {
    print_status "설정 테스트 중..."
    
    # tmux 설정 파일 문법 검사
    if tmux -f "$HOME/.tmux.conf" list-sessions 2>/dev/null; then
        print_success "tmux 설정 파일이 올바릅니다."
    else
        print_error "tmux 설정 파일에 문제가 있습니다."
        return 1
    fi
}

# 최종 정보 출력
print_final_info() {
    print_success "="
    print_success "🎉 tmux 설정 완료!"
    print_success "="
    echo ""
    echo -e "${BLUE}다음 단계:${NC}"
    echo "1. 새로운 터미널 창을 열거나 'tmux' 명령어로 tmux 시작"
    echo "2. 설정이 제대로 로드되었는지 확인"
    echo ""
    echo -e "${BLUE}주요 단축키:${NC}"
    echo "• prefix: Ctrl + a (기본 Ctrl + b에서 변경됨)"
    echo "• 설정 리로드: prefix + r"
    echo "• 세로 분할: prefix + |"
    echo "• 가로 분할: prefix + _"
    echo "• 사이드바: prefix + Tab"
    echo "• fzf 메뉴: Ctrl + f"
    echo ""
    echo -e "${BLUE}플러그인 관리:${NC}"
    echo "• 플러그인 설치: prefix + I"
    echo "• 플러그인 업데이트: prefix + U"
    echo "• 플러그인 삭제: prefix + alt + u"
    echo ""
    echo -e "${YELLOW}문제가 있다면:${NC}"
    echo "• tmux kill-server (모든 세션 종료)"
    echo "• tmux (새로 시작)"
    echo "• prefix + I (플러그인 재설치)"
}

# 메인 실행 부분
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    tmux 설정 자동 설치 스크립트    ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    # 각 단계별 실행
    print_status "1/7 - .tmux.conf 파일 확인 중..."
    check_tmux_conf
    
    print_status "2/7 - tmux 설치 확인 중..."
    check_tmux_installed
    
    print_status "3/7 - 기존 설정 파일 백업 중..."
    backup_existing_config
    
    print_status "4/7 - 심볼릭 링크 생성 중..."
    create_symlink
    
    print_status "5/7 - TPM 설치 중..."
    install_tpm
    
    print_status "6/7 - 기존 tmux 세션 정리 중..."
    kill_tmux_sessions
    
    print_status "7/7 - 플러그인 설치 중..."
    install_plugins
    
    print_status "설정 테스트 중..."
    test_configuration
    
    print_final_info
}

# 인터럽트 처리
trap 'print_error "스크립트가 중단되었습니다."; exit 1' INT

# 스크립트 실행
main "$@"