---
name: clear-system-cache
description: 시스템 캐시 진단 및 정리 (Docker, pip, uv, poetry, conda/miniconda, npm, venv, huggingface 등)
disable-model-invocation: true
allowed-tools: Bash(*), AskUserQuestion
argument-hint: "[옵션]"
---

# 시스템 캐시 정리 Skill

시스템의 다양한 캐시를 진단하고 선택적으로 정리합니다.

## 실행 흐름

### 1단계: 진단 (자동 실행)

아래 모든 항목을 순차적으로 진단하여 현재 상태를 테이블로 보여줍니다:

| 번호 | 항목 | 진단 명령어 | 정리 명령어 |
|------|------|-------------|-------------|
| 1 | docker-dangling | `docker images -f "dangling=true"` | `docker rmi $(docker images -f "dangling=true" -q)` |
| 2 | docker-build | `docker system df` (Build Cache) | `docker builder prune -af` |
| 3 | docker-containers | `docker ps -a --filter status=exited` | `docker container prune -f` |
| 4 | docker-all | `docker system df` | `docker system prune -af` |
| 5 | pip | `pip cache info` | `pip cache purge` |
| 6 | uv | `du -sh $(uv cache dir)` | `uv cache clean` |
| 7 | poetry | `du -sh ~/.cache/pypoetry` | `rm -rf ~/.cache/pypoetry` |
| 8 | conda | `du -sh ~/anaconda3 ~/miniconda3 2>/dev/null` (디렉토리 직접 확인) | `conda clean --all -y` 또는 `rm -rf ~/anaconda3/pkgs ~/miniconda3/pkgs` |
| 9 | npm | `du -sh ~/.npm/_cacache` | `npm cache clean --force` |
| 10 | venv | `find ~ -maxdepth 5 -type d -name ".venv"` | 개별 삭제 (확인 후) |
| 11 | huggingface | `du -sh ~/.cache/huggingface` | `rm -rf ~/.cache/huggingface` |

### 2단계: 사용자 선택

진단 결과를 보여준 후, AskUserQuestion 도구를 사용하여 사용자에게 질문합니다:

**질문**: "어떤 캐시를 정리하시겠습니까?"

**옵션 (multiSelect: true)**:
- `all` - 전체 정리 (huggingface, venv 제외) **(기본값으로 권장)**
- `docker-dangling` - Docker <none> 이미지만
- `docker-build` - Docker 빌드 캐시만
- `docker-containers` - 중지된 컨테이너만
- `docker-all` - Docker 전체 (images, containers, build cache)
- `pip` - pip 캐시
- `uv` - uv 캐시
- `poetry` - poetry 캐시
- `conda` - conda/miniconda 패키지 캐시
- `npm` - npm 캐시
- `venv` - .venv 디렉토리들 (개별 확인)
- `huggingface` - HuggingFace 모델 캐시 (주의: 재다운로드 필요)

### 3단계: 정리 실행

선택된 항목들을 순차적으로 정리하고 결과를 보고합니다.

## 진단 출력 형식

```
============================================
       시스템 캐시 진단 결과
============================================

[Docker]
  - Dangling Images (<none>): 12개, 316GB
  - Build Cache: 366GB
  - 중지된 Containers: 5개, 16GB

[Python]
  - pip cache: 21GB
  - uv cache: 18GB
  - poetry cache: 9.3GB
  - conda/miniconda cache: N/A (미설치)

[기타]
  - npm cache: 201MB
  - .venv 디렉토리: 5개 발견
  - huggingface: 60GB

--------------------------------------------
총 회수 가능 용량 (추정): ~750GB
============================================
```

## 주의사항

- `huggingface` 캐시 삭제 시 모델을 다시 다운로드해야 합니다
- `venv` 삭제 시 각 프로젝트의 가상환경을 다시 생성해야 합니다
- `docker-all`은 사용 중이지 않은 모든 Docker 리소스를 제거합니다
- `all` 옵션은 안전을 위해 `huggingface`와 `venv`를 제외합니다

## 인자 사용

`$ARGUMENTS`가 제공되면 진단 단계를 건너뛰고 해당 항목을 바로 정리합니다:
- `/clear-system-cache docker-dangling` - Docker dangling 이미지만 바로 정리
- `/clear-system-cache all` - 진단 없이 전체 정리 (huggingface, venv 제외)
