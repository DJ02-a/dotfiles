#!/bin/bash

# OS별 입력 소스 확인
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    input=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null)

    if echo "$input" | grep -q 'ABC'; then
        echo "A"
    elif echo "$input" | grep -q 'Korean.2SetKorean'; then
        echo "가"
    else
        echo "?"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - iBus 체크
    if command -v ibus &> /dev/null; then
        engine=$(ibus engine 2>/dev/null)
        if echo "$engine" | grep -qi 'hangul\|korean'; then
            echo "가"
        else
            echo "A"
        fi
    # fcitx 체크
    elif command -v fcitx-remote &> /dev/null || command -v fcitx5-remote &> /dev/null; then
        fcitx_cmd=$(command -v fcitx5-remote &> /dev/null && echo "fcitx5-remote" || echo "fcitx-remote")
        state=$($fcitx_cmd 2>/dev/null)
        if [[ "$state" == "2" ]]; then
            echo "가"
        else
            echo "A"
        fi
    else
        # 입력기 없으면 빈 문자열
        echo ""
    fi
else
    echo "?"
fi
