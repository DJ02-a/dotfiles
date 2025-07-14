#!/bin/bash

# 현재 입력 소스 확인
input=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null)

if echo "$input" | grep -q 'ABC'; then
  echo "A"
elif echo "$input" | grep -q 'Korean.2SetKorean'; then
  echo "가"
else
  echo "?"
fi
