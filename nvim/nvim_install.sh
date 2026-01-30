#!/bin/bash
set -e

echo "🌍 운영체제 감지 중..."
OS="$(uname -s)"

# 최소 요구 버전 (telescope.nvim 등 플러그인 요구사항)
MIN_NVIM_VERSION="0.10.4"

# 버전 비교 함수 (version1 >= version2 이면 0 반환)
version_gte() {
  [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# 현재 설치된 nvim 버전 확인
get_current_nvim_version() {
  if command -v nvim &>/dev/null; then
    nvim --version | head -n1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+'
  else
    echo ""
  fi
}

# AppImage로 nvim 설치 (Linux 전용)
install_nvim_appimage() {
  echo "⬇️ Neovim AppImage 다운로드 중..."

  # 최신 릴리스 버전 확인
  LATEST_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -oP '"tag_name": "v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  echo "📦 최신 버전: v${LATEST_VERSION}"

  # 아키텍처 확인
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    APPIMAGE_NAME="nvim-linux-x86_64.appimage"
  elif [ "$ARCH" = "aarch64" ]; then
    APPIMAGE_NAME="nvim-linux-arm64.appimage"
  else
    echo "❌ 지원하지 않는 아키텍처입니다: $ARCH"
    exit 1
  fi

  # 다운로드
  curl -fLO "https://github.com/neovim/neovim/releases/download/v${LATEST_VERSION}/${APPIMAGE_NAME}"
  chmod u+x "$APPIMAGE_NAME"

  # 설치 (sudo 가능하면 /usr/local/bin, 아니면 ~/.local/bin)
  mkdir -p ~/.local/bin
  mv "$APPIMAGE_NAME" ~/.local/bin/nvim

  # PATH에 ~/.local/bin 추가 확인
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "⚠️  ~/.local/bin이 PATH에 없습니다. 쉘 설정에 추가해주세요."
  fi

  # PATH에 즉시 추가 (현재 세션에서 사용 가능하도록)
  export PATH="$HOME/.local/bin:$PATH"

  echo "✅ Neovim v${LATEST_VERSION} 설치 완료 (~/.local/bin/nvim)"
}

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

  CURRENT_VERSION=$(get_current_nvim_version)

  if [ -n "$CURRENT_VERSION" ]; then
    echo "📦 현재 설치된 버전: v${CURRENT_VERSION}"
    echo "📦 최소 요구 버전: v${MIN_NVIM_VERSION}"

    if version_gte "$CURRENT_VERSION" "$MIN_NVIM_VERSION"; then
      echo "✅ 현재 버전이 요구사항을 충족합니다. 설치를 건너뜁니다."
    else
      echo "⚠️  현재 버전이 너무 오래되었습니다. 업그레이드합니다..."
      brew upgrade neovim
    fi
  else
    echo "⬇️ Homebrew로 Neovim 설치 중..."
    brew install neovim
  fi

elif [[ "$OS" == "Linux" ]]; then
  echo "🐧 Linux 환경입니다."

  CURRENT_VERSION=$(get_current_nvim_version)

  if [ -n "$CURRENT_VERSION" ]; then
    echo "📦 현재 설치된 버전: v${CURRENT_VERSION}"
    echo "📦 최소 요구 버전: v${MIN_NVIM_VERSION}"

    if version_gte "$CURRENT_VERSION" "$MIN_NVIM_VERSION"; then
      echo "✅ 현재 버전이 요구사항을 충족합니다. 설치를 건너뜁니다."
    else
      echo "⚠️  현재 버전이 너무 오래되었습니다. AppImage로 업그레이드합니다..."
      install_nvim_appimage
    fi
  else
    echo "📦 Neovim이 설치되어 있지 않습니다."
    install_nvim_appimage
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
