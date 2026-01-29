#!/bin/bash

# ==============================================================================
# Node.js 버전 체크 및 자동 업데이트 스크립트
# ==============================================================================
# 목적: nvim Copilot 등이 요구하는 Node.js 버전(22.x 이상)을 자동으로 체크하고 설정
# ==============================================================================

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Node.js 버전 체크 및 설정${NC}"
echo -e "${BLUE}========================================${NC}"

# 최소 요구 버전 (메이저 버전)
REQUIRED_MAJOR_VERSION=22

# ==============================================================================
# 함수: Node.js 버전 체크
# ==============================================================================
check_node_version() {
    local node_path=$1
    if [[ ! -x "$node_path" ]]; then
        return 1
    fi

    local version=$($node_path --version 2>/dev/null | sed 's/v//')
    local major_version=$(echo $version | cut -d. -f1)

    echo "$major_version"
}

# ==============================================================================
# 함수: nvm에서 최신 버전 찾기
# ==============================================================================
find_latest_nvm_node() {
    local nvm_dir="${NVM_DIR:-$HOME/.nvm}"

    if [[ ! -d "$nvm_dir/versions/node" ]]; then
        echo ""
        return
    fi

    # nvm 버전 디렉토리에서 가장 높은 버전 찾기
    local latest_version=$(ls -1 "$nvm_dir/versions/node" | sort -V | tail -1)

    if [[ -n "$latest_version" ]]; then
        echo "$nvm_dir/versions/node/$latest_version/bin/node"
    else
        echo ""
    fi
}

# ==============================================================================
# 함수: Node.js 심볼릭 링크 업데이트
# ==============================================================================
update_node_symlink() {
    local new_node_path=$1
    local local_bin="$HOME/.local/bin"

    # ~/.local/bin 디렉토리가 없으면 생성
    if [[ ! -d "$local_bin" ]]; then
        echo -e "${YELLOW}Creating $local_bin directory...${NC}"
        mkdir -p "$local_bin"
    fi

    # 기존 node 백업 (심볼릭 링크가 아닌 경우만)
    if [[ -e "$local_bin/node" ]] && [[ ! -L "$local_bin/node" ]]; then
        local backup_name="node.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing node to $backup_name${NC}"
        mv "$local_bin/node" "$local_bin/$backup_name"
    elif [[ -L "$local_bin/node" ]]; then
        echo -e "${YELLOW}Removing old node symlink${NC}"
        rm "$local_bin/node"
    fi

    # 새로운 심볼릭 링크 생성
    echo -e "${GREEN}Creating symlink: $local_bin/node -> $new_node_path${NC}"
    ln -sf "$new_node_path" "$local_bin/node"

    # npm, npx도 같이 업데이트
    local new_node_dir=$(dirname "$new_node_path")

    if [[ -f "$new_node_dir/npm" ]]; then
        if [[ -e "$local_bin/npm" ]]; then
            rm -f "$local_bin/npm"
        fi
        ln -sf "$new_node_dir/npm" "$local_bin/npm"
        echo -e "${GREEN}Updated npm symlink${NC}"
    fi

    if [[ -f "$new_node_dir/npx" ]]; then
        if [[ -e "$local_bin/npx" ]]; then
            rm -f "$local_bin/npx"
        fi
        ln -sf "$new_node_dir/npx" "$local_bin/npx"
        echo -e "${GREEN}Updated npx symlink${NC}"
    fi
}

# ==============================================================================
# 메인 로직
# ==============================================================================

# 1. 현재 사용 중인 Node.js 버전 체크
echo -e "\n${BLUE}[1/4] 현재 Node.js 버전 확인...${NC}"

current_node=$(which node 2>/dev/null || echo "")
if [[ -z "$current_node" ]]; then
    echo -e "${RED}✗ Node.js가 설치되어 있지 않습니다.${NC}"
    current_major=0
else
    current_version=$(node --version)
    current_major=$(check_node_version "$current_node")
    echo -e "${GREEN}✓ 현재 Node.js 버전: $current_version (경로: $current_node)${NC}"
fi

# 2. 버전 체크
echo -e "\n${BLUE}[2/4] 버전 요구사항 체크...${NC}"
echo -e "최소 요구 버전: v${REQUIRED_MAJOR_VERSION}.x"

if [[ $current_major -ge $REQUIRED_MAJOR_VERSION ]]; then
    echo -e "${GREEN}✓ 현재 Node.js 버전이 요구사항을 만족합니다.${NC}"
    echo -e "${GREEN}설정 완료!${NC}"
    exit 0
fi

echo -e "${YELLOW}⚠ Node.js 버전이 낮습니다. (현재: v$current_major.x, 필요: v${REQUIRED_MAJOR_VERSION}.x 이상)${NC}"

# 3. nvm에서 최신 버전 찾기
echo -e "\n${BLUE}[3/4] nvm에서 적합한 버전 검색...${NC}"

latest_nvm_node=$(find_latest_nvm_node)

if [[ -z "$latest_nvm_node" ]]; then
    echo -e "${RED}✗ nvm에 설치된 Node.js를 찾을 수 없습니다.${NC}"
    echo -e "${YELLOW}다음 명령어로 최신 버전을 설치해주세요:${NC}"
    echo -e "  ${BLUE}nvm install --lts${NC}"
    echo -e "  ${BLUE}nvm install node${NC} (최신 버전)"
    exit 1
fi

latest_major=$(check_node_version "$latest_nvm_node")
latest_version=$($latest_nvm_node --version)

echo -e "${GREEN}✓ nvm에서 찾은 버전: $latest_version (메이저: v$latest_major.x)${NC}"

if [[ $latest_major -lt $REQUIRED_MAJOR_VERSION ]]; then
    echo -e "${RED}✗ nvm의 최신 버전($latest_version)도 요구사항(v${REQUIRED_MAJOR_VERSION}.x)을 만족하지 않습니다.${NC}"
    echo -e "${YELLOW}다음 명령어로 더 최신 버전을 설치해주세요:${NC}"
    echo -e "  ${BLUE}nvm install --lts${NC}"
    echo -e "  ${BLUE}nvm install node${NC}"
    exit 1
fi

# 4. 심볼릭 링크 업데이트
echo -e "\n${BLUE}[4/4] Node.js 심볼릭 링크 업데이트...${NC}"
update_node_symlink "$latest_nvm_node"

# 최종 확인
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Node.js 설정 완료!${NC}"
echo -e "${BLUE}========================================${NC}"
final_version=$(node --version)
echo -e "최종 버전: ${GREEN}$final_version${NC}"
echo -e "경로: ${GREEN}$(which node)${NC}"
echo -e "\n${YELLOW}nvim을 재시작하여 Copilot이 정상 작동하는지 확인하세요.${NC}"
