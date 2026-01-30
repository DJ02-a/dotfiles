---
name: research-to-lib
description: 연구용 파이썬 파일을 일관된 구조의 라이브러리로 변환하고 테스트합니다
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[research_file.py]"
---

# Research to Library Skill

연구용 파이썬 파일을 분석하여 일관된 구조의 라이브러리로 변환합니다.

## 입력

$ARGUMENTS

## 워크플로우

### Step 1: 프로젝트 초기화
- 연구용 파이썬 파일 경로를 확인합니다
- `uv init`으로 새 프로젝트를 초기화합니다 (이미 있으면 스킵)
- pyproject.toml 기본 설정을 확인합니다

### Step 2: 연구 파일 분석 및 라이브러리 설계
- 연구용 파이썬 파일을 읽고 분석합니다
- 주요 기능을 파악합니다 (모델 로딩, 추론 등)
- **사용자에게 질문**: 어떤 함수/클래스를 라이브러리에 포함할지 확인합니다
  - 모델 로딩 함수
  - inference 함수
  - 기타 유틸리티 함수

### Step 3: 일관된 클래스 구조로 라이브러리 생성
- `src/<package_name>/` 디렉토리에 라이브러리 코드 작성
- **중요**: 메인 코드 파일명은 반드시 `main.py`를 사용 (generator.py, core.py 등 사용 금지)
- 기본 구조:
  ```
  src/<package_name>/
  ├── __init__.py      # 메인 클래스 export
  └── main.py          # Generator/Model 클래스 (반드시 main.py 사용)
  ```
- 클래스 구조 패턴:
  ```python
  class <Name>Generator:
      def __init__(self, model_path, device, dtype, config):
          """모델 로딩"""

      def infer(self, prompt, **kwargs) -> Output:
          """추론 실행"""

      def load_lora(self, path, scale):
          """LoRA 로드 (필요시)"""
  ```

### Step 4: 테스트 코드 작성
- `tests/test_<기능명>.py` 형식으로 기능별로 분리하여 생성
  - 예: `test_text_to_image.py`, `test_image_to_image.py`, `test_lora.py`
- **중요**: 입력값은 반드시 연구용 파일과 동일하게 설정
  - 동일한 입력 이미지/데이터 경로
  - 동일한 파라미터 값
  - 동일한 프롬프트/설정
- **체크포인트 다운로드**: 연구 코드에서 모델/체크포인트를 다운로드하는 코드가 있으면 테스트 파일에 포함

### Step 5: 필수 의존성 확인
- **사용자에게 질문**: 테스트 실행 전에 필수 라이브러리가 있는지 확인
  - 사용자 정의 라이브러리 (로컬 패키지, 내부 도구)
  - 특정 버전이 필요한 라이브러리
  - 비공개 저장소의 패키지
- 사용자가 지정한 필수 라이브러리가 있으면 먼저 `uv add`로 추가

### Step 6: 의존성 설치 및 실행
- **중요**: pyproject.toml에 의존성을 미리 추가하지 않음 (필수 라이브러리 제외)
- `uv run python tests/test_<module>.py` 실행
- 에러 발생 시:
  1. 에러 메시지에서 누락된 패키지 확인
  2. `uv add <package>`로 해당 패키지만 추가
  3. 다시 실행
- **핵심 원칙**: 테스트 실행 → 에러 확인 → 필요한 패키지만 추가 (반복)
- **에러 카운터**:
  - `uv add`로 의존성을 추가하는 과정의 에러는 카운트하지 않음
  - 의존성이 모두 추가된 후, 코드 로직 에러만 카운트

### Step 7: 반복 (최대 5회)
- 에러가 없을 때까지 Step 5를 반복합니다
- **5회 이상 에러 발생 시**:
  - 현재 상태와 에러 내용을 정리
  - 사용자에게 보고하고 대기
  - 사용자의 추가 지시를 기다립니다

### Step 8: 문서화
- `docs/` 디렉토리 생성 (없으면)
- `docs/report.md` 작성:
  ```markdown
  # Library Conversion Report

  ## 원본 파일
  - 경로: ...
  - 주요 기능: ...

  ## 생성된 라이브러리
  - 패키지명: ...
  - 주요 클래스/함수: ...

  ## 의존성
  - 추가된 패키지 목록

  ## 테스트 결과
  - 성공/실패 여부
  - 실행 횟수

  ## 설정값 정리
  - 주요 파라미터 설명
  - 기본값과 권장값
  - 사용 시 주의사항

  ## 사용 예시
  ```python
  from <package> import <Class>
  ...
  ```
  ```

## 예시 사용법

```
/research-to-lib sample.py
/research-to-lib /path/to/research_code.py
```

## 주의사항

- 연구 파일의 하드코딩된 경로는 테스트 코드에서도 동일하게 유지
- 모델 체크포인트 경로, 입력 데이터 경로 등 그대로 사용
- uv를 사용하여 가상환경 및 의존성 관리
- **device 설정**: 테스트 시 device는 `cuda`를 직접 사용 (cpu_offload 등 offload 옵션 지양)
