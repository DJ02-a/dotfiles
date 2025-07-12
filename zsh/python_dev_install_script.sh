#!/bin/bash
# ===============================================
# Python 개발자용 완전 자동 설치 스크립트
# 지원 OS: macOS, Ubuntu/Debian
# 포함: zsh, oh-my-zsh, pyenv, poetry, docker, kubectl, 개발도구
# ===============================================

set -e  # 오류 발생시 스크립트 종료

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

# 전역 변수
OS=""
INSTALL_DIR="$HOME/.python-dev-setup"

# 운영체제 감지
detect_os() {
    header "시스템 환경 확인"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        success "macOS 감지됨"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v apt-get &> /dev/null; then
        OS="ubuntu"
        success "Ubuntu/Debian 감지됨"
    else
        error "지원되지 않는 운영체제입니다. macOS 또는 Ubuntu만 지원합니다."
        exit 1
    fi
    
    info "사용자: $(whoami)"
    info "홈 디렉토리: $HOME"
}

# 명령어 존재 확인
command_exists() {
    command -v "$1" &> /dev/null
}

# 디렉토리 존재 확인
dir_exists() {
    [[ -d "$1" ]]
}

# 설치 디렉토리 생성
create_install_dir() {
    mkdir -p "$INSTALL_DIR"
}

# Homebrew 설치
install_homebrew() {
    header "Homebrew 설치"
    
    if command_exists brew; then
        success "Homebrew가 이미 설치되어 있습니다"
        brew update
        return 0
    fi
    
    step "Homebrew 설치 중..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # PATH 설정
    case $OS in
        "macos")
            if [[ $(uname -m) == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            ;;
        "ubuntu")
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            ;;
    esac
    
    success "Homebrew 설치 완료"
}

# 기본 패키지 설치
install_basic_packages() {
    header "기본 패키지 설치"
    
    case $OS in
        "macos")
            step "Xcode Command Line Tools 확인..."
            if ! xcode-select -p &> /dev/null; then
                xcode-select --install
                info "Xcode Command Line Tools 설치 중... 완료 후 스크립트를 다시 실행하세요."
                read -p "설치가 완료되면 Enter를 누르세요..."
            fi
            success "개발 도구 준비 완료"
            ;;
        "ubuntu")
            step "시스템 패키지 업데이트 및 설치..."
            sudo apt-get update
            sudo apt-get install -y curl git build-essential zsh unzip wget software-properties-common apt-transport-https ca-certificates gnupg lsb-release
            success "기본 패키지 설치 완료"
            ;;
    esac
}

# zsh 설정
setup_zsh() {
    header "zsh 셸 설정"
    
    # zsh 설치 확인
    if ! command_exists zsh; then
        case $OS in
            "macos")
                success "zsh는 macOS에 기본 설치되어 있습니다"
                ;;
            "ubuntu")
                step "zsh 설치 중..."
                sudo apt-get install -y zsh
                ;;
        esac
    else
        success "zsh가 이미 설치되어 있습니다"
    fi
    
    # 기본 셸을 zsh로 변경
    if [[ "$SHELL" != *"zsh"* ]]; then
        step "기본 셸을 zsh로 변경 중..."
        chsh -s "$(which zsh)"
        success "zsh가 기본 셸로 설정되었습니다 (재로그인 후 적용)"
    else
        success "zsh가 이미 기본 셸입니다"
    fi
}

# Oh My Zsh 설치
install_oh_my_zsh() {
    header "Oh My Zsh 설치"
    
    if dir_exists "$HOME/.oh-my-zsh"; then
        success "Oh My Zsh가 이미 설치되어 있습니다"
    else
        step "Oh My Zsh 설치 중..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        success "Oh My Zsh 설치 완료"
    fi
}

# Powerlevel10k 테마 설치
install_p10k() {
    header "Powerlevel10k 테마 설치"
    
    local p10k_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "$p10k_path" ]]; then
        success "Powerlevel10k가 이미 설치되어 있습니다"
    else
        step "Powerlevel10k 설치 중..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_path"
        success "Powerlevel10k 설치 완료"
    fi
}

# 외부 zsh 플러그인 설치
install_external_zsh_plugins() {
    header "외부 zsh 플러그인 설치"
    
    # 플러그인 정보를 개별 배열로 관리
    local plugin_names=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions")
    local plugin_urls=(
        "https://github.com/zsh-users/zsh-autosuggestions"
        "https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "https://github.com/zsh-users/zsh-completions"
    )
    local plugin_descriptions=("명령어 자동 제안" "구문 강조" "추가 자동완성")
    
    # 플러그인 수만큼 반복
    for i in "${!plugin_names[@]}"; do
        local plugin_name="${plugin_names[$i]}"
        local plugin_url="${plugin_urls[$i]}"
        local plugin_desc="${plugin_descriptions[$i]}"
        local plugin_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
        
        if dir_exists "$plugin_path"; then
            success "$plugin_name 이미 설치됨"
        else
            step "$plugin_name ($plugin_desc) 설치 중..."
            git clone "$plugin_url" "$plugin_path"
            success "$plugin_name 설치 완료"
        fi
    done
}

# PyEnv 설치
install_pyenv() {
    header "PyEnv 설치"
    
    if command_exists pyenv; then
        success "PyEnv가 이미 설치되어 있습니다: $(pyenv --version)"
        return 0
    fi
    
    step "PyEnv 설치 중..."
    
    case $OS in
        "macos")
            brew install pyenv pyenv-virtualenv
            ;;
        "ubuntu")
            # 의존성 설치
            sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                libffi-dev liblzma-dev python3-openssl
            
            # PyEnv 설치
            curl https://pyenv.run | bash
            ;;
    esac
    
    success "PyEnv 설치 완료"
}

# Poetry 설치
install_poetry() {
    header "Poetry 설치"
    
    # Poetry 완전 제거 함수
    remove_poetry_completely() {
        info "기존 Poetry 설치를 완전히 제거합니다..."
        
        # Homebrew Poetry 제거
        if command_exists brew; then
            brew uninstall --ignore-dependencies poetry 2>/dev/null || true
            brew uninstall poetry 2>/dev/null || true
        fi
        
        # Poetry 관련 디렉토리 모두 제거
        rm -rf "$HOME/.local/bin/poetry" 2>/dev/null || true
        rm -rf "$HOME/.local/share/pypoetry" 2>/dev/null || true
        rm -rf "$HOME/.cache/pypoetry" 2>/dev/null || true
        rm -rf "$HOME/Library/Application Support/pypoetry" 2>/dev/null || true
        rm -rf "$HOME/.config/pypoetry" 2>/dev/null || true
        
        # Poetry venv 관련 정리
        rm -rf "$HOME/Library/Caches/pypoetry" 2>/dev/null || true
        
        # PATH에서 Homebrew Poetry 제거
        export PATH=$(echo "$PATH" | sed -e 's|/opt/homebrew/bin/poetry||g' -e 's|/usr/local/bin/poetry||g')
        
        success "기존 Poetry 설치 정리 완료"
    }
    
    # Poetry 작동 상태 확인
    if command_exists poetry; then
        if poetry --version &>/dev/null; then
            success "Poetry가 이미 정상적으로 설치되어 있습니다: $(poetry --version)"
            return 0
        else
            warning "Poetry가 손상되었습니다. 재설치를 진행합니다..."
            remove_poetry_completely
        fi
    elif [[ -f "$HOME/.local/bin/poetry" ]]; then
        if "$HOME/.local/bin/poetry" --version &>/dev/null; then
            success "Poetry가 이미 정상적으로 설치되어 있습니다: $($HOME/.local/bin/poetry --version)"
            export PATH="$HOME/.local/bin:$PATH"
            return 0
        else
            warning "Poetry가 손상되었습니다. 재설치를 진행합니다..."
            remove_poetry_completely
        fi
    fi
    
    step "Poetry 설치 중..."
    
    # .local/bin 디렉토리 생성
    mkdir -p "$HOME/.local/bin"
    
    # Poetry 공식 설치 스크립트 사용
    info "Poetry 공식 설치 스크립트를 사용합니다..."
    
    # 환경변수 설정
    export POETRY_HOME="$HOME/.local"
    export PATH="$HOME/.local/bin:$PATH"
    
    # 설치 실행
    if curl -sSL https://install.python-poetry.org | python3 -; then
        success "Poetry 설치 스크립트 실행 완료"
    else
        error "Poetry 설치 스크립트 실행에 실패했습니다"
        
        # 대안: pip으로 설치 시도
        warning "pip를 통한 Poetry 설치를 시도합니다..."
        python3 -m pip install --user poetry
        
        if ! command_exists poetry && ! [[ -f "$HOME/.local/bin/poetry" ]]; then
            error "Poetry 설치에 완전히 실패했습니다"
            return 1
        fi
    fi
    
    # 설치 확인 및 PATH 설정
    export PATH="$HOME/.local/bin:$PATH"
    
    # Poetry 명령어 확인
    local poetry_cmd=""
    if command_exists poetry; then
        poetry_cmd="poetry"
    elif [[ -f "$HOME/.local/bin/poetry" ]]; then
        poetry_cmd="$HOME/.local/bin/poetry"
    else
        error "Poetry 설치를 확인할 수 없습니다"
        return 1
    fi
    
    # 설치 검증
    if $poetry_cmd --version &>/dev/null; then
        success "Poetry 설치 완료: $($poetry_cmd --version)"
    else
        error "Poetry가 설치되었지만 실행할 수 없습니다"
        return 1
    fi
    
    # Poetry 기본 설정
    info "Poetry 기본 설정 중..."
    
    # 가상환경을 프로젝트 내부에 생성하도록 설정
    $poetry_cmd config virtualenvs.in-project true 2>/dev/null || warning "Poetry 설정 실패: virtualenvs.in-project"
    
    # 병렬 설치 활성화
    $poetry_cmd config installer.parallel true 2>/dev/null || warning "Poetry 설정 실패: installer.parallel"
    
    success "Poetry 설정 완료"
}

# Docker 설치
install_docker() {
    header "Docker 설치"
    
    if command_exists docker; then
        success "Docker가 이미 설치되어 있습니다"
        return 0
    fi
    
    read -p "Docker를 설치하시겠습니까? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "Docker 설치를 건너뜁니다"
        return 0
    fi
    
    step "Docker 설치 중..."
    
    case $OS in
        "macos")
            brew install --cask docker
            success "Docker Desktop 설치 완료"
            warning "Docker Desktop을 수동으로 실행해주세요"
            ;;
        "ubuntu")
            # Docker 공식 GPG 키 추가
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            
            # Docker 저장소 추가
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Docker 설치
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            
            # 사용자를 docker 그룹에 추가
            sudo usermod -aG docker "$USER"
            sudo systemctl start docker
            sudo systemctl enable docker
            
            success "Docker 설치 완료 (재로그인 필요)"
            ;;
    esac
}

# kubectl 설치
install_kubectl() {
    header "kubectl 설치"
    
    if command_exists kubectl; then
        success "kubectl이 이미 설치되어 있습니다"
        return 0
    fi
    
    read -p "kubectl을 설치하시겠습니까? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "kubectl 설치를 건너뜁니다"
        return 0
    fi
    
    step "kubectl 설치 중..."
    
    case $OS in
        "macos")
            brew install kubectl
            ;;
        "ubuntu")
            if command_exists brew; then
                brew install kubectl
            else
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                chmod +x kubectl
                sudo mv kubectl /usr/local/bin/
            fi
            ;;
    esac
    
    success "kubectl 설치 완료"
}

# 선택적 도구들 설치
install_optional_tools() {
    header "선택적 도구 설치"
    
    # 기본 도구들 (exa -> eza로 변경)
    local tools=()
    if command_exists brew; then
        tools=("helm" "awscli" "ripgrep" "fd" "bat" "eza" "httpie" "jq" "htop" "tree" "fzf" "starship")
    fi
    
    echo "다음 도구들을 설치할 수 있습니다:"
    echo "1. Helm (Kubernetes 패키지 매니저)"
    echo "2. AWS CLI (AWS 명령행 도구)"
    echo "3. 개발 유틸리티 (ripgrep, fd, bat, eza, httpie, jq, htop, tree)"
    echo "4. fzf (퍼지 파인더)"
    echo "5. Starship (모던 프롬프트)"
    echo ""
    
    read -p "모든 도구를 설치하시겠습니까? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command_exists brew; then
            step "개발 도구들 설치 중..."
            for tool in "${tools[@]}"; do
                if ! command_exists "$tool"; then
                    # exa가 없으면 eza 설치 시도
                    if [[ "$tool" == "exa" ]] && ! command_exists "exa"; then
                        brew install eza &
                    else
                        brew install "$tool" &
                    fi
                fi
            done
            wait
            
            # fzf 설정
            if command_exists fzf; then
                "$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish &>/dev/null || true
            fi
            
            success "모든 도구 설치 완료"
        else
            warning "Homebrew가 없어 일부 도구 설치를 건너뜁니다"
        fi
    else
        warning "선택적 도구 설치를 건너뜁니다"
    fi
}

# Python 환경 설정
setup_python_environment() {
    header "Python 환경 설정"
    
    # 환경변수 임시 설정
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    
    if command_exists pyenv; then
        eval "$(pyenv init -)"
    fi
    
    # Python 3.11.7 설치
    if command_exists pyenv; then
        if pyenv versions 2>/dev/null | grep -q "3.11.7"; then
            success "Python 3.11.7이 이미 설치되어 있습니다"
        else
            step "Python 3.11.7 설치 중... (시간이 걸릴 수 있습니다)"
            pyenv install 3.11.7
            pyenv global 3.11.7
            success "Python 3.11.7 설치 및 전역 설정 완료"
        fi
    else
        warning "PyEnv가 설치되지 않아 Python 설정을 건너뜁니다"
    fi
    
    # Poetry에 필요한 기본 패키지들 먼저 설치
    step "Poetry 의존성 패키지 설치 중..."
    
    # Homebrew Python에 필수 패키지 설치 (macOS의 경우)
    if [[ $OS == "macos" ]] && command_exists brew; then
        /opt/homebrew/bin/python3 -m pip install --break-system-packages packaging filelock virtualenv 2>/dev/null || true
    fi
    
    # 사용자 Python에도 설치
    python3 -m pip install --upgrade pip --user 2>/dev/null || true
    python3 -m pip install --user packaging filelock virtualenv 2>/dev/null || {
        warning "일부 Poetry 의존성 패키지 설치에 실패했습니다"
    }
    
    # 기본 Python 패키지 설치
    step "기본 Python 패키지 설치 중..."
    python3 -m pip install --user ipython jupyter black isort flake8 mypy pytest 2>/dev/null || {
        warning "일부 Python 패키지 설치에 실패했습니다"
    }
    
    # Poetry 자동완성 재설정 (Poetry 설치 후)
    if command_exists poetry; then
        mkdir -p ~/.zfunc
        poetry completions zsh > ~/.zfunc/_poetry 2>/dev/null || {
            warning "Poetry 자동완성 설정에 실패했습니다"
        }
        success "Poetry 자동완성 설정 완료"
    elif [[ -f "$HOME/.local/bin/poetry" ]]; then
        mkdir -p ~/.zfunc
        "$HOME/.local/bin/poetry" completions zsh > ~/.zfunc/_poetry 2>/dev/null || {
            warning "Poetry 자동완성 설정에 실패했습니다"
        }
        success "Poetry 자동완성 설정 완료"
    fi
    
    success "Python 환경 설정 완료"
}

# .zshrc 생성
create_zshrc() {
    header ".zshrc 설정 파일 생성"
    
    # 기존 .zshrc 백업
    if [[ -f ~/.zshrc ]]; then
        backup_name="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp ~/.zshrc "$backup_name"
        success "기존 .zshrc 백업: $backup_name"
    fi
    
    step "새로운 .zshrc 생성 중..."
    
    cat > ~/.zshrc << 'EOF'
# ===============================================
# Python 개발자용 .zshrc 설정
# 자동 생성됨
# ===============================================

# Oh My Zsh 경로
export ZSH="$HOME/.oh-my-zsh"

# 테마 설정
ZSH_THEME="powerlevel10k/powerlevel10k"

# 플러그인 설정
plugins=(
    # === 기본 생산성 플러그인 ===
    git                    # Git 별칭 및 자동완성
    sudo                   # ESC 두 번으로 sudo 추가
    history                # 히스토리 검색 향상
    colored-man-pages      # man 페이지 색상
    command-not-found      # 명령어 제안
    
    # === Python 환경 관리 ===
    python                 # Python 별칭
    pip                    # pip 자동완성
    pyenv                  # PyEnv 통합
    poetry                 # Poetry 자동완성
    virtualenv             # virtualenv 지원
    
    # === 컨테이너 & 오케스트레이션 ===
    docker                 # Docker 자동완성
    docker-compose         # Docker Compose 자동완성
    kubectl                # Kubernetes 자동완성
    helm                   # Helm 자동완성
    
    # === 클라우드 & 인프라 ===
    aws                    # AWS CLI 자동완성
    gcloud                 # Google Cloud CLI 자동완성
    terraform              # Terraform 자동완성
    
    # === 개발 도구 ===
    vscode                 # VS Code 통합
    node                   # Node.js 지원
    npm                    # npm 자동완성
    yarn                   # Yarn 자동완성
    
    # === 향상된 zsh 기능 ===
    zsh-autosuggestions    # 명령어 자동 제안
    zsh-syntax-highlighting # 구문 강조
    zsh-completions        # 추가 자동완성
    
    # === 유틸리티 ===
    extract                # 압축 파일 해제
    web-search             # 웹 검색 명령어
    copypath               # 경로 복사
    copyfile               # 파일 내용 복사
    jsontools              # JSON 유틸리티
)

# Oh My Zsh 로드
source $ZSH/oh-my-zsh.sh

# ===== 환경변수 설정 =====
export EDITOR="vim"
export LANG="en_US.UTF-8"
export PATH="$HOME/.local/bin:$PATH"

# PyEnv 설정
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Poetry 설정
export PATH="$HOME/.local/bin:$PATH"
export POETRY_VENV_IN_PROJECT=1

# fpath for completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
fpath+=~/.zfunc

# ===== 별칭 설정 =====
# 기본 별칭
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."

# 향상된 ls (eza 또는 exa 사용)
if command -v eza >/dev/null; then
    alias ls="eza"
    alias ll="eza -la"
    alias la="eza -a"
    alias tree="eza --tree"
elif command -v exa >/dev/null; then
    alias ls="exa"
    alias ll="exa -la"
    alias la="exa -a"
    alias tree="exa --tree"
fi

# Python 개발
alias py="python3"
alias pip="pip3"
alias ipy="ipython"

# Poetry (절대 경로 사용)
alias po="$HOME/.local/bin/poetry"
alias poa="$HOME/.local/bin/poetry add"
alias poad="$HOME/.local/bin/poetry add --group dev"
alias poi="$HOME/.local/bin/poetry install"
alias pos="$HOME/.local/bin/poetry shell"
alias por="$HOME/.local/bin/poetry run"
alias poshow="$HOME/.local/bin/poetry show"

# Docker
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias di="docker images"

# Kubernetes
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"

# 유틸리티
alias reload="source ~/.zshrc"
alias editrc="vim ~/.zshrc"

# ===== 함수 =====
# 새 Python 프로젝트 생성
newpy() {
    if [ "$1" ]; then
        mkdir "$1" && cd "$1"
        $HOME/.local/bin/poetry init --no-interaction
        $HOME/.local/bin/poetry add --group dev pytest black isort flake8 mypy
        $HOME/.local/bin/poetry install
        git init
        echo -e "__pycache__/\n*.pyc\n.env\n.venv/\ndist/\nbuild/\n.pytest_cache/" > .gitignore
        echo "# $1" > README.md
        echo "Python project '$1' created!"
    else
        echo "Usage: newpy <project_name>"
    fi
}

# 개발 환경 활성화
dev() {
    if [ "$1" ]; then
        case "$1" in
            "poetry")
                $HOME/.local/bin/poetry shell
                ;;
            *)
                if command -v pyenv >/dev/null; then
                    pyenv activate "$1" 2>/dev/null || echo "Environment '$1' not found"
                fi
                ;;
        esac
    else
        echo "Usage: dev <env_name> or dev poetry"
    fi
}

# ===== 선택적 도구 설정 =====
# Starship 프롬프트 (설치된 경우)
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
fi

# fzf 설정 (설치된 경우)
if command -v fzf >/dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# ===== 시작 메시지 =====
echo "🐍 Python Development Environment Ready!"
if command -v python3 >/dev/null; then
    echo "Python: $(python3 --version)"
fi
if command -v poetry >/dev/null; then
    echo "Poetry: $(poetry --version)"
elif [[ -f "$HOME/.local/bin/poetry" ]]; then
    echo "Poetry: $($HOME/.local/bin/poetry --version)"
fi
EOF
    
    success ".zshrc 설정 파일 생성 완료"
}

# 설치 검증
verify_installation() {
    header "설치 검증"
    
    echo "============================================="
    echo "          설치 결과 확인"
    echo "============================================="
    
    # 필수 도구들
    echo -e "\n📋 기본 도구:"
    local basic_tools=("zsh" "git" "curl")
    for tool in "${basic_tools[@]}"; do
        if command_exists "$tool"; then
            success "$tool: 설치됨"
        else
            error "$tool: 설치되지 않음"
        fi
    done
    
    # Python 관련 도구들
    echo -e "\n🐍 Python 도구:"
    local python_tools=("python3" "pip3" "pyenv" "poetry")
    for tool in "${python_tools[@]}"; do
        if command_exists "$tool"; then
            success "$tool: 설치됨"
        else
            warning "$tool: 설치되지 않음"
        fi
    done
    
    # 컨테이너 도구들
    echo -e "\n🐳 컨테이너 도구:"
    local container_tools=("docker" "kubectl")
    for tool in "${container_tools[@]}"; do
        if command_exists "$tool"; then
            success "$tool: 설치됨"
        else
            warning "$tool: 설치되지 않음 (선택사항)"
        fi
    done
    
    # zsh 플러그인들
    echo -e "\n🔌 zsh 플러그인:"
    local plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions")
    for plugin in "${plugins[@]}"; do
        plugin_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
        if dir_exists "$plugin_path"; then
            success "$plugin: 설치됨"
        else
            error "$plugin: 설치되지 않음"
        fi
    done
    
    # 추가 도구들
    echo -e "\n⚡ 추가 도구:"
    local extra_tools=("ripgrep" "fd" "bat" "fzf" "starship" "eza" "rg")
    for tool in "${extra_tools[@]}"; do
        # rg는 ripgrep의 실제 명령어이므로 ripgrep 확인용
        if [[ "$tool" == "rg" ]]; then
            if command_exists "rg"; then
                success "ripgrep: 설치됨"
            else
                warning "ripgrep: 설치되지 않음 (선택사항)"
            fi
        elif [[ "$tool" == "eza" ]]; then
            if command_exists "eza" || command_exists "exa"; then
                success "eza/exa: 설치됨"
            else
                warning "eza/exa: 설치되지 않음 (선택사항)"
            fi
        elif [[ "$tool" != "ripgrep" ]]; then  # ripgrep은 rg로 이미 확인했으므로 제외
            if command_exists "$tool"; then
                success "$tool: 설치됨"
            else
                warning "$tool: 설치되지 않음 (선택사항)"
            fi
        fi
    done
}

# 완료 메시지 및 다음 단계 안내
show_completion_message() {
    header "설치 완료!"
    
    echo ""
    success "🎉 Python 개발 환경 설치가 완료되었습니다!"
    echo ""
    echo "다음 단계:"
    echo "1. 터미널을 재시작하거나 다음 명령어를 실행하세요:"
    echo "   source ~/.zshrc"
    echo ""
    echo "2. Docker를 설치한 경우 시스템을 재로그인하세요"
    echo ""
    echo "3. Powerlevel10k 초기 설정:"
    echo "   p10k configure"
    echo ""
    echo "4. 사용 가능한 명령어들:"
    echo "   • newpy <name>  : 새 Python 프로젝트 생성"
    echo "   • dev <env>     : 개발 환경 활성화"
    echo "   • po            : poetry 별칭"
    echo "   • d, dc         : docker, docker-compose 별칭"
    echo "   • k, kgp, kgs   : kubectl 별칭들"
    echo "   • gs, ga, gc    : git 별칭들"
    echo ""
    echo "5. Python 프로젝트 시작 예시:"
    echo "   newpy my-project"
    echo "   cd my-project"
    echo "   dev poetry"
    echo ""
    warning "변경사항을 적용하려면 터미널을 재시작하세요!"
    
    # 로그 파일 위치 안내
    echo ""
    info "설치 로그는 다음 위치에 저장됩니다: $INSTALL_DIR"
}

# 메인 실행 함수
main() {
    echo "==============================================="
    echo "🚀 Python 개발자용 환경 자동 설치 시작"
    echo "==============================================="
    echo ""
    
    # 설치 확인
    read -p "Python 개발 환경을 설치하시겠습니까? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "설치를 취소했습니다"
        exit 0
    fi
    
    # 설치 디렉토리 생성
    create_install_dir
    
    # 단계별 실행
    detect_os
    install_homebrew
    install_basic_packages
    setup_zsh
    install_oh_my_zsh
    install_p10k
    install_external_zsh_plugins
    install_pyenv
    install_poetry
    install_docker
    install_kubectl
    install_optional_tools
    setup_python_environment
    create_zshrc
    verify_installation
    show_completion_message
}

# 스크립트가 직접 실행될 때만 main 함수 호출
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi