#!/bin/bash
set -e

echo "🌍 운영체제 감지 중..."
OS="$(uname -s)"

install_vimplug() {
  echo "🔌 vim-plug 설치 중..."
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

setup_initvim() {
  echo "📝 init.vim 설정 복사 중..."
  mkdir -p ~/.config/nvim

  # 현재 스크립트의 디렉토리 찾기
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # init.vim 파일이 같은 디렉토리에 있는지 확인
  if [ -f "$SCRIPT_DIR/init.vim" ]; then
    cp "$SCRIPT_DIR/init.vim" ~/.config/nvim/init.vim
    echo "✅ init.vim 복사 완료"
  else
    echo "⚠️  init.vim 파일을 찾을 수 없습니다: $SCRIPT_DIR/init.vim"
    echo "기본 설정을 생성합니다..."
    cat <<'EOF' > ~/.config/nvim/init.vim
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
call plug#end()
EOF
  fi

  # Lua 설정 디렉토리 복사 (있는 경우)
  if [ -d "$SCRIPT_DIR/lua" ]; then
    cp -r "$SCRIPT_DIR/lua" ~/.config/nvim/
    echo "✅ Lua 설정 디렉토리 복사 완료"
  fi
}

install_plugins() {
  echo "🔌 플러그인 설치 중..."
  echo "이 작업은 몇 분 정도 소요될 수 있습니다..."
  nvim --headless "+PlugInstall" "+qall"
  echo "✅ 플러그인 설치 완료"
}

if [[ "$OS" == "Darwin" ]]; then
  echo "🍎 macOS 환경입니다."
  
  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew가 설치되어 있지 않습니다. 먼저 설치해주세요: https://brew.sh"
    exit 1
  fi

  echo "⬇️ Homebrew로 Neovim 설치 중..."
  brew install neovim

elif [[ "$OS" == "Linux" ]]; then
  echo "🐧 Linux 환경입니다."

  # 패키지 매니저별 설치
  if command -v apt-get &>/dev/null; then
    # Debian/Ubuntu
    echo "⬇️ apt-get으로 Neovim 설치 중..."
    sudo apt-get update
    sudo apt-get install -y neovim

  elif command -v dnf &>/dev/null; then
    # Fedora
    echo "⬇️ dnf로 Neovim 설치 중..."
    sudo dnf install -y neovim

  elif command -v yum &>/dev/null; then
    # CentOS/RHEL
    echo "⬇️ yum으로 Neovim 설치 중..."
    sudo yum install -y epel-release
    sudo yum install -y neovim

  elif command -v pacman &>/dev/null; then
    # Arch Linux
    echo "⬇️ pacman으로 Neovim 설치 중..."
    sudo pacman -S --noconfirm neovim

  elif command -v zypper &>/dev/null; then
    # openSUSE
    echo "⬇️ zypper로 Neovim 설치 중..."
    sudo zypper install -y neovim

  else
    # 패키지 매니저가 없으면 AppImage 사용
    echo "⚠️  패키지 매니저를 찾을 수 없습니다. AppImage로 설치합니다..."
    echo "⬇️ Neovim AppImage 다운로드 중..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage

    echo "🛠️ /usr/local/bin/nvim 으로 이동 (sudo 필요)"
    sudo mv nvim.appimage /usr/local/bin/nvim
  fi

else
  echo "❌ 지원하지 않는 운영체제입니다: $OS"
  exit 1
fi

# 공통 설치 작업
install_vimplug
setup_initvim
install_plugins

echo ""
echo "======================================"
echo "✅ Neovim 설치 완료!"
echo "======================================"
echo "📦 Neovim: $(nvim --version | head -n 1)"
echo "🔌 vim-plug: 설치 완료"
echo "📝 init.vim: 설정 완료"
echo "🎨 플러그인: 설치 완료"
echo ""
echo "💡 사용 방법:"
echo "  - Neovim 실행: nvim"
echo "  - 플러그인 업데이트: nvim에서 :PlugUpdate"
echo "  - 설정 파일 위치: ~/.config/nvim/init.vim"
echo "======================================"
