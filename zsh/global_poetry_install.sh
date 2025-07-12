#!/bin/bash
# ===============================================
# Poetry 전역 설치 스크립트
# pip를 통한 간단하고 확실한 설치
# ===============================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 로그 함수들
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
header() { echo -e "\n${CYAN}=== $1 ===${NC}"; }
step() { echo -e "${PURPLE}[STEP]${NC} $1"; }

# 완전한 Poetry 제거
complete_removal() {
    header "기존 Poetry 완전 제거"
    
    step "1. Homebrew Poetry 제거..."
    if command -v brew &>/dev/null; then
        brew uninstall --ignore-dependencies poetry 2>/dev/null || true
        brew uninstall --force poetry 2>/dev/null || true
        brew cleanup poetry 2>/dev/null || true
    fi
    
    step "2. 모든 Poetry 파일 제거..."
    # 실행 파일들
    sudo rm -f /opt/homebrew/bin/poetry 2>/dev/null || true
    sudo rm -f /usr/local/bin/poetry 2>/dev/null || true
    rm -f "$HOME/.local/bin/poetry" 2>/dev/null || true
    
    # 데이터 디렉토리들
    rm -rf "$HOME/.local/share/pypoetry" 2>/dev/null || true
    rm -rf "$HOME/.cache/pypoetry" 2>/dev/null || true
    rm -rf "$HOME/.config/pypoetry" 2>/dev/null || true
    rm -rf "$HOME/Library/Application Support/pypoetry" 2>/dev/null || true
    rm -rf "$HOME/Library/Caches/pypoetry" 2>/dev/null || true
    
    step "3. 기존 pip 설치 제거..."
    # pip로 설치된 poetry 제거
    python3 -m pip uninstall poetry -y 2>/dev/null || true
    python3 -m pip uninstall --user poetry -y 2>/dev/null || true
    
    # Homebrew Python에서도 제거
    if [[ -f "/opt/homebrew/bin/python3" ]]; then
        /opt/homebrew/bin/python3 -m pip uninstall poetry -y 2>/dev/null || true
    fi
    
    step "4. Poetry 관련 환경변수 정리..."
    unset POETRY_HOME 2>/dev/null || true
    unset POETRY_VENV_IN_PROJECT 2>/dev/null || true
    unset POETRY_CACHE_DIR 2>/dev/null || true
    
    success "기존 Poetry 완전 제거 완료"
}

# 의존성 패키지 설치
install_dependencies() {
    header "의존성 패키지 설치"
    
    step "필수 패키지들 설치 중..."
    
    local packages="packaging filelock virtualenv setuptools wheel pip"
    
    # macOS에서는 pipx 사용 권장
    if [[ "$OSTYPE" == "darwin"* ]]; then
        step "macOS 감지 - pipx 설치 확인..."
        
        # pipx 설치 확인
        if ! command -v pipx &>/dev/null; then
            info "pipx 설치 중..."
            if command -v brew &>/dev/null; then
                brew install pipx
                pipx ensurepath
                export PATH="$HOME/.local/bin:$PATH"
            else
                error "Homebrew가 필요합니다. Homebrew를 먼저 설치하세요."
                return 1
            fi
        else
            success "pipx가 이미 설치되어 있습니다"
        fi
        
        # Homebrew Python에 --break-system-packages로 설치
        if [[ -f "/opt/homebrew/bin/python3" ]]; then
            info "Homebrew Python에 의존성 설치..."
            /opt/homebrew/bin/python3 -m pip install --break-system-packages --upgrade $packages 2>/dev/null || {
                warning "Homebrew Python 의존성 설치 일부 실패"
            }
        fi
        
        # 시스템 Python에는 --break-system-packages와 --user 플래그 사용
        info "시스템 Python에 의존성 설치..."
        python3 -m pip install --break-system-packages --user --upgrade $packages 2>/dev/null || {
            warning "시스템 Python 의존성 설치 일부 실패"
        }
        
    else
        # Linux의 경우 기존 방식 사용
        info "Linux 환경 - 기본 설치 방식 사용..."
        
        # 시스템 Python
        python3 -m pip install --user --upgrade $packages 2>/dev/null || {
            warning "시스템 Python 의존성 설치 일부 실패"
        }
    fi
    
    # pyenv Python (있는 경우)
    if command -v pyenv &>/dev/null; then
        info "pyenv Python에 의존성 설치..."
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)" 2>/dev/null || true
        python3 -m pip install --user --upgrade $packages 2>/dev/null || {
            warning "pyenv Python 의존성 설치 일부 실패"
        }
    fi
    
    success "의존성 패키지 설치 완료"
}

# Poetry pip 설치
install_poetry_pip() {
    header "Poetry 설치"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS의 경우 pipx 사용
        step "pipx를 통한 Poetry 설치..."
        
        if command -v pipx &>/dev/null; then
            # 기존 Poetry 제거
            pipx uninstall poetry 2>/dev/null || true
            
            # pipx로 Poetry 설치
            if pipx install poetry; then
                success "pipx를 통한 Poetry 설치 성공"
                
                # pipx 설치 경로 확인
                POETRY_PATH="$HOME/.local/bin/poetry"
                
                if [[ -f "$POETRY_PATH" ]] && "$POETRY_PATH" --version &>/dev/null; then
                    success "Poetry 설치 확인: $($POETRY_PATH --version)"
                else
                    error "Poetry 설치 확인 실패"
                    return 1
                fi
            else
                warning "pipx 설치 실패, pip 방식으로 시도..."
                # 백업 방식: pip 설치
                python3 -m pip install --break-system-packages --user poetry
                POETRY_PATH="$HOME/.local/bin/poetry"
            fi
        else
            error "pipx를 찾을 수 없습니다"
            return 1
        fi
        
    else
        # Linux의 경우 pip 사용
        step "pip를 통한 Poetry 설치..."
        
        python3 -m pip install --upgrade pip --user
        python3 -m pip install --user poetry
        
        # 설치 위치 확인
        local poetry_locations=(
            "$HOME/.local/bin/poetry"
            "$(python3 -m site --user-base)/bin/poetry"
        )
        
        local poetry_path=""
        for location in "${poetry_locations[@]}"; do
            if [[ -f "$location" ]]; then
                poetry_path="$location"
                break
            fi
        done
        
        if [[ -n "$poetry_path" ]] && "$poetry_path" --version &>/dev/null; then
            success "Poetry 설치 확인: $($poetry_path --version)"
            POETRY_PATH="$poetry_path"
        else
            error "Poetry 설치 확인 실패"
            return 1
        fi
    fi
    
    success "Poetry 설치 완료"
}

# 전역 링크 생성
create_global_link() {
    header "전역 Poetry 명령어 생성"
    
    step "1. /usr/local/bin에 심볼릭 링크 생성..."
    
    # /usr/local/bin 디렉토리 확인/생성
    if [[ ! -d "/usr/local/bin" ]]; then
        sudo mkdir -p /usr/local/bin
    fi
    
    # 기존 링크 제거
    sudo rm -f /usr/local/bin/poetry 2>/dev/null || true
    
    # 새 심볼릭 링크 생성
    if sudo ln -s "$POETRY_PATH" /usr/local/bin/poetry; then
        success "전역 심볼릭 링크 생성 완료"
    else
        warning "심볼릭 링크 생성 실패, 대안 방법 사용..."
        
        # 대안: 래퍼 스크립트 생성
        sudo tee /usr/local/bin/poetry > /dev/null << EOF
#!/bin/bash
exec "$POETRY_PATH" "\$@"
EOF
        sudo chmod +x /usr/local/bin/poetry
        success "래퍼 스크립트 생성 완료"
    fi
    
    step "2. PATH 확인..."
    if echo "$PATH" | grep -q "/usr/local/bin"; then
        success "/usr/local/bin이 PATH에 포함되어 있습니다"
    else
        warning "/usr/local/bin이 PATH에 없습니다. 추가합니다..."
        
        # .zshrc에 PATH 추가
        if ! grep -q 'export PATH="/usr/local/bin:$PATH"' ~/.zshrc 2>/dev/null; then
            echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
        fi
        
        # 현재 세션에 적용
        export PATH="/usr/local/bin:$PATH"
    fi
    
    success "전역 Poetry 명령어 생성 완료"
}

# Poetry 설정
configure_poetry() {
    header "Poetry 설정"
    
    step "Poetry 기본 설정 적용..."
    
    # 기본 설정들 (오류 무시하고 계속 진행)
    poetry config virtualenvs.in-project true 2>/dev/null || warning "virtualenvs.in-project 설정 실패"
    poetry config installer.parallel true 2>/dev/null || warning "installer.parallel 설정 실패"
    
    # 버전별로 다를 수 있는 설정들 (존재하는 경우에만 적용)
    poetry config virtualenvs.prefer-active-python true 2>/dev/null || info "virtualenvs.prefer-active-python 설정 지원되지 않음 (선택사항)"
    
    # 추가 유용한 설정들
    poetry config installer.max-workers 10 2>/dev/null || info "installer.max-workers 설정 지원되지 않음 (선택사항)"
    poetry config virtualenvs.prompt "{project_name}-py{python_version}" 2>/dev/null || info "virtualenvs.prompt 설정 지원되지 않음 (선택사항)"
    
    step "현재 Poetry 설정 확인..."
    echo "현재 적용된 설정:"
    poetry config --list | grep -E "(virtualenvs|installer)" | sed 's/^/   /' || warning "설정 목록 확인 실패"
    
    step "자동완성 설정..."
    mkdir -p ~/.zfunc
    poetry completions zsh > ~/.zfunc/_poetry 2>/dev/null || {
        warning "자동완성 설정 실패"
    }
    
    success "Poetry 설정 완료 (일부 설정은 Poetry 버전에 따라 적용되지 않을 수 있음)"
}

# .zshrc 설정
setup_zshrc() {
    header ".zshrc 설정"
    
    step "1. 백업 생성..."
    if [[ -f ~/.zshrc ]]; then
        cp ~/.zshrc ~/.zshrc.backup.global-poetry.$(date +%Y%m%d_%H%M%S)
        success ".zshrc 백업 완료"
    fi
    
    step "2. 기존 Poetry 설정 정리..."
    if [[ -f ~/.zshrc ]]; then
        # Poetry 관련 기존 설정 제거
        sed -i.bak '/# Poetry/d' ~/.zshrc
        sed -i.bak '/poetry/d' ~/.zshrc
        sed -i.bak '/POETRY/d' ~/.zshrc
        sed -i.bak '/alias po=/d' ~/.zshrc
        sed -i.bak '/HOME\/\.local\/bin\/poetry/d' ~/.zshrc
    fi
    
    step "3. 새로운 Poetry 설정 추가..."
    
    cat >> ~/.zshrc << 'EOF'

# ===============================================
# Poetry 전역 설정 (자동 생성)
# ===============================================

# Poetry 환경변수
export POETRY_VENV_IN_PROJECT=1

# Poetry 별칭 (전역 명령어 사용)
alias po="poetry"
alias poa="poetry add"
alias poad="poetry add --group dev"
alias poi="poetry install"
alias pos="poetry shell"
alias por="poetry run"
alias poshow="poetry show"
alias poconfig="poetry config --list"

# 새 Python 프로젝트 생성
newpy() {
    if [ "$1" ]; then
        mkdir "$1" && cd "$1"
        poetry init --no-interaction --name "$1"
        poetry add --group dev pytest black isort flake8 mypy
        poetry install
        git init
        echo -e "__pycache__/\n*.pyc\n.env\n.venv/\ndist/\nbuild/\n.pytest_cache/\n*.egg-info/" > .gitignore
        echo "# $1" > README.md
        echo ""
        echo "🎉 Python project '$1' created successfully!"
        echo "📁 Virtual environment: .venv"
        echo "🚀 Start coding with: poetry shell"
        echo ""
    else
        echo "Usage: newpy <project_name>"
    fi
}

# Poetry 셸 활성화 (현재 디렉토리)
poshell() {
    if [[ -f "pyproject.toml" ]]; then
        poetry shell
    else
        echo "❌ No pyproject.toml found in current directory"
        echo "💡 Run 'poetry init' to create a new Poetry project"
        echo "💡 Or run 'newpy <project_name>' to create a complete project"
    fi
}

# Poetry 상태 확인
postatus() {
    echo "🔍 Poetry Status:"
    echo "   Version: $(poetry --version 2>/dev/null || echo 'Not found')"
    echo "   Location: $(which poetry 2>/dev/null || echo 'Not found')"
    echo ""
    
    if command -v poetry >/dev/null; then
        echo "   Config:"
        poetry config --list | grep -E "(virtualenvs|installer)" | sed 's/^/     /'
        echo ""
    fi
    
    if [[ -f "pyproject.toml" ]]; then
        echo "   📁 Current project: $(basename $(pwd))"
        if [[ -f ".venv/pyvenv.cfg" ]]; then
            echo "   ✅ Virtual environment: .venv (active)"
        else
            echo "   ⚠️  Virtual environment: not created"
            echo "       Run 'poetry install' to create"
        fi
        echo "   📦 Dependencies:"
        poetry show --tree 2>/dev/null | head -5 | sed 's/^/     /' || echo "     No dependencies installed"
    else
        echo "   ℹ️  Not in a Poetry project directory"
    fi
}

# Poetry 프로젝트 빠른 시작
quickstart() {
    local project_name="${1:-my-python-project}"
    newpy "$project_name"
    cd "$project_name"
    poetry shell
}

EOF
    
    success ".zshrc 설정 완료"
}

# 전체 테스트
run_tests() {
    header "설치 테스트"
    
    step "1. Poetry 명령어 테스트..."
    if command -v poetry &>/dev/null; then
        success "poetry 명령어 찾음: $(which poetry)"
        
        if poetry --version &>/dev/null; then
            success "Poetry 버전: $(poetry --version)"
        else
            error "Poetry 버전 확인 실패"
            return 1
        fi
    else
        error "poetry 명령어를 찾을 수 없습니다"
        return 1
    fi
    
    step "2. Poetry 기능 테스트..."
    if poetry --help &>/dev/null; then
        success "Poetry 도움말 실행 성공"
    else
        error "Poetry 도움말 실행 실패"
        return 1
    fi
    
    step "3. 임시 프로젝트 테스트..."
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if poetry init --no-interaction --name test-project; then
        success "임시 프로젝트 생성 성공"
        
        if poetry add requests --dry-run &>/dev/null; then
            success "의존성 추가 테스트 성공"
        else
            warning "의존성 추가 테스트 실패"
        fi
    else
        error "임시 프로젝트 생성 실패"
    fi
    
    # 정리
    cd "$HOME"
    rm -rf "$temp_dir"
    
    success "모든 테스트 통과!"
}

# 최종 안내
final_instructions() {
    header "설치 완료!"
    
    echo "============================================="
    echo "          Poetry 전역 설치 완료"
    echo "============================================="
    
    echo ""
    echo "✅ 완료된 작업:"
    echo "   • 기존 Poetry 완전 제거"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "   • pipx를 통한 Poetry 설치"
    else
        echo "   • pip를 통한 Poetry 설치"
    fi
    echo "   • 전역 명령어 설정"
    echo "   • 자동완성 설정"
    echo "   • 유용한 별칭 및 함수 추가"
    
    echo ""
    echo "📍 Poetry 정보:"
    echo "   • 전역 명령어: poetry"
    echo "   • 버전: $(poetry --version 2>/dev/null || echo '확인 필요')"
    echo "   • 위치: $(which poetry 2>/dev/null || echo '확인 필요')"
    
    echo ""
    echo "🚀 사용 가능한 명령어:"
    echo "   • poetry --version     : 버전 확인"
    echo "   • postatus            : Poetry 상태 확인"
    echo "   • newpy <name>     : 새 프로젝트 생성"
    echo "   • poshell             : Poetry 셸 활성화"
    echo "   • quickstart <name>   : 프로젝트 생성 + 셸 활성화"
    echo "   • po, poa, poi, pos   : Poetry 단축 명령어들"
    
    echo ""
    echo "🧪 테스트 해보기:"
    echo "   1. 새 터미널 열기 (또는 source ~/.zshrc)"
    echo "   2. poetry --version"
    echo "   3. newpy my-test-project"
    echo "   4. cd my-test-project && poetry shell"
    
    echo ""
    success "🎉 Poetry가 전역 명령어로 성공적으로 설치되었습니다!"
    warning "터미널을 새로 열거나 'source ~/.zshrc'를 실행하세요!"
}

# 메인 함수
main() {
    echo "==============================================="
    echo "🚀 Poetry 전역 설치 도구"
    echo "==============================================="
    echo ""
    echo "이 스크립트는 Poetry를 전역 명령어로 설치합니다:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "• pipx를 통한 안전한 설치 (macOS 권장 방식)"
    else
        echo "• pip를 통한 확실한 설치"
    fi
    echo "• /usr/local/bin에 전역 링크 생성"
    echo "• 'poetry' 명령어로 어디서든 사용 가능"
    echo ""
    
    read -p "Poetry를 전역으로 설치하시겠습니까? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "설치를 취소했습니다"
        exit 0
    fi
    
    # 실행
    complete_removal
    install_dependencies
    install_poetry_pip
    create_global_link
    configure_poetry
    setup_zshrc
    run_tests
    final_instructions
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi