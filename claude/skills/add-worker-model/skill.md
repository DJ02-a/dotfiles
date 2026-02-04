# add-worker-model

kuberay_worker의 모델을 kuberay_head에 등록하고 테스트 클라이언트를 생성하는 skill입니다.

## 워크플로우

### Phase 1: 준비 및 모델 선택

1. **Submodule 업데이트**
   ```bash
   git submodule update --init --recursive
   ```

2. **미등록 모델 리스트 확인**
   - `submodules/Toonkit-Ray-Worker/src/kuberay_worker/models/` 폴더의 모델 목록 조회
   - `src/kuberay_head/configs.py`의 `REGISTERED_MODELS`에 이미 등록된 모델 제외
   - 미등록 모델만 사용자에게 표시하고 선택받기

3. **스키마 파일 확인**
   - `submodules/Toonkit-Ray-Worker/src/kuberay_worker/schemas/{model_name}.py` 파일 읽기
   - Input/Output 스펙 파악

### Phase 2: 참고 코드 탐색

4. **Triton 테스트 코드 탐색** (선택적)
   - `submodules/Toonkit-Ray-Worker/submodules/Toonkit-Triton-*/` 디렉토리 확인
   - 해당 모델의 테스트 코드가 있으면 참고할지 사용자에게 질문
   - 참고할 파일 선택

5. **Worker 테스트 코드 탐색**
   - `submodules/Toonkit-Ray-Worker/tests/` 폴더에서 동일 모델 테스트 코드 확인
   - 기본 입력값 및 파라미터 참고

### Phase 3: 작업 계획 수립

6. **작업 계획 생성**
   - 수집한 정보를 바탕으로 구체적인 작업 계획 작성
   - 사용자에게 다음 사항 확인:
     - 리소스 타입 선택 (`worker_heavy` / `worker_light` / `worker_medium`)
     - `serve_config.yaml` 활성화 여부 (활성화 / 주석처리)
     - 기타 커스터마이징 옵션
   - 계획 승인 받기

### Phase 4: 코드 작성

7. **configs.py 수정**
   - `src/kuberay_head/configs.py`의 `REGISTERED_MODELS`에 ModelConfig 추가
   ```python
   ModelConfig(
       model_name="{model_name}",
       app_name="{model_name}_app",
       deployment_name="{ModelName}Deployment",
   ),
   ```

8. **serve_config.yaml 수정**
   - 기존 모델 설정 패턴 참고하여 새 애플리케이션 블록 추가
   - 사용자 선택에 따라 활성화 또는 주석처리

9. **kuberay_client.py 메서드 추가**
   - `client/kuberay_client.py`에 새 모델용 convenience method 추가
   - 스키마 파일의 Input 스펙 기반으로 파라미터 정의

10. **테스트 클라이언트 생성**
    - `client/test_{model_name}.py` 파일 생성
    - 기존 테스트 클라이언트 패턴 (`test_zimage.py`, `test_fluxkleini2i.py`) 참고
    - Triton/Worker 테스트 코드의 기본값 적용

### Phase 5: 문서화 및 완료

11. **문서 작성**
    - `docs/{YYMMDD}-add-{model_name}-model.md` 파일 생성
    - 작업 내용, 설정 정보, 사용 예시 포함

12. **완료 확인**
    - 변경된 파일 목록 출력
    - 커밋 여부 사용자에게 질문 (선택적)

## 파일 구조

```
Toonkit-Ray-Head/
├── src/kuberay_head/
│   └── configs.py              # ModelConfig 추가
├── serve_config.yaml           # 애플리케이션 설정 추가
├── client/
│   ├── kuberay_client.py       # 클라이언트 메서드 추가
│   └── test_{model_name}.py    # 테스트 클라이언트 생성
└── docs/
    └── {YYMMDD}-add-{model_name}-model.md  # 문서 생성

submodules/Toonkit-Ray-Worker/
├── src/kuberay_worker/
│   ├── models/{model_name}.py      # 참고: deployment 코드
│   └── schemas/{model_name}.py     # 참고: Input/Output 스키마
├── tests/                          # 참고: 테스트 코드
└── submodules/Toonkit-Triton-*/    # 참고: Triton 테스트 코드
```

## 사용 예시

```
/add-worker-model
```

## 주의사항

- 모델 이름은 소문자 사용 (예: `fluxkleini2i`, `zimage`)
- Deployment 이름은 PascalCase 사용 (예: `FluxKleinI2iDeployment`)
- App 이름은 `{model_name}_app` 형식 사용
- 스키마 파일의 필수/선택 필드를 정확히 반영할 것
