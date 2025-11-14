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
  echo "📝 기본 init.vim 설정 생성 중..."
  mkdir -p ~/.config/nvim

  cat <<EOF > ~/.config/nvim/init.vim
call plug#begin('~/.vim/plugged')

" 기본 플러그인 예시
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'

call plug#end()

" :PluginInstall 명령도 가능하게 설정
command! PluginInstall PlugInstall
EOF
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

echo "✅ Neovim 설치 완료: $(nvim --version | head -n 1)"
echo "💡 Neovim 실행 후 ':PluginInstall' 을 입력하여 플러그인을 설치하세요."
