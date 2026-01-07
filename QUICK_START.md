# OpenCode 자동화 빠른 시작 가이드

## 3단계로 완료하기

### ✅ 1단계: Self-hosted Runner 설치 (5-10분)

**관리자 PowerShell 열기** → 다음 명령 실행:

```powershell
# 1. 디렉토리 생성
mkdir C:\actions-runner
cd C:\actions-runner

# 2. Runner 다운로드
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/latest/download/actions-runner-win-x64-latest.zip -OutFile actions-runner-win-x64.zip
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64.zip", "$PWD")
```

**GitHub에서 토큰 받기**:
- GitHub 레포 → Settings → Actions → Runners → New self-hosted runner
- 표시되는 config 명령 복사 (토큰 포함)

```powershell
# 3. GitHub에서 복사한 명령 실행
.\config.cmd --url https://github.com/사용자명/레포명 --token 토큰값

# 질문에 답하기:
# - runner group: [Enter]
# - runner name: [Enter]
# - labels: home-desktop ← 중요!
# - work folder: [Enter]

# 4. 서비스로 설치 및 시작
.\svc.cmd install
.\svc.cmd start
```

**확인**: GitHub → Settings → Actions → Runners에서 "Online" 상태

---

### ✅ 2단계: API 키 등록 (2분)

**Gemini API 키 발급**:
1. https://aistudio.google.com/ 접속
2. "Get API Key" 클릭
3. API 키 복사

**GitHub Secrets 등록**:
1. GitHub 레포 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. Name: `GEMINI_API_KEY`
4. Secret: (복사한 API 키 붙여넣기)
5. "Add secret" 클릭

---

### ✅ 3단계: 테스트 실행 (1분)

1. GitHub 레포에서 **새 이슈 생성**
2. 이슈 제목: `테스트: OpenCode 자동화`
3. 이슈 본문:
```
OpenCode 자동화 시스템이 제대로 작동하는지 테스트합니다.
```

4. **코멘트 작성**:
```
/oc 간단한 테스트를 실행해줘
```

5. **결과 확인**:
   - Actions 탭 → 워크플로우 실행 확인
   - 몇 분 후 PR 생성 확인
   - 이슈에 자동 코멘트 확인

---

## 실제 사용 예시

### Python 프로젝트에서 테스트 수정

```
/oc
재현 방법:
- .venv\Scripts\python -m pytest tests/test_example.py

문제:
- test_addition 함수가 실패함

목표:
- 테스트를 통과하도록 수정
- 최소한의 변경만 수행

완료 조건:
- pytest 전체 통과
- opencode_report.md에 변경 내역 기록
```

### 버그 수정

```
/oc
버그: 로그인 시 에러 발생

재현:
1. 사용자명 입력
2. 비밀번호 입력
3. 로그인 버튼 클릭
4. "KeyError: 'username'" 발생

목표:
- 에러 수정
- 에러 처리 추가

완료 조건:
- 로그인 정상 동작
- 테스트 통과
```

### 새 기능 추가

```
/oc
새 기능: 사용자 프로필 페이지 추가

요구사항:
- /profile 경로 추가
- 사용자 이름, 이메일 표시
- 기존 코드 스타일 유지

완료 조건:
- 페이지 정상 작동
- 테스트 작성 및 통과
```

---

## 트러블슈팅

### 워크플로우가 실행 안됨
- [ ] Runner가 Online 상태인가? (Settings → Actions → Runners)
- [ ] Labels에 "home-desktop" 있는가?
- [ ] 코멘트에 "/oc" 포함되어 있는가?
- [ ] 이슈(Issue)에 작성했는가? (PR 코멘트는 안됨)
- [ ] OWNER/MEMBER/COLLABORATOR 권한이 있는가?

### Runner가 Offline
```powershell
cd C:\actions-runner
.\svc.cmd stop
.\svc.cmd start
.\svc.cmd status
```

### API 키 오류
- GitHub Secrets에 `GEMINI_API_KEY` 정확히 등록되었는가?
- API 키가 유효한가? (Google AI Studio에서 확인)

---

## 상세 가이드

더 자세한 정보는 다음 파일들을 참고하세요:

- `install-runner.md` - Runner 설치 상세 가이드
- `SETUP_GUIDE.md` - 전체 설정 가이드
- `.github/workflows/opencode.yml` - 워크플로우 설정

---

## 보안 주의사항

- ✅ OWNER/MEMBER/COLLABORATOR만 실행 가능 (설정됨)
- ⚠️ Self-hosted Runner는 집 PC로 실행됨
- ⚠️ PR은 리뷰 후 수동으로 merge 권장
- ⚠️ API 키는 절대 코드에 하드코딩 금지

---

설정 완료! 이제 스마트폰에서도 이슈에 "/oc" 코멘트만 남기면 자동으로 코딩 작업이 진행됩니다.
