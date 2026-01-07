# OpenCode 자동화 설정 가이드

## 현재 완료된 작업
- ✅ `.github/workflows/opencode.yml` 워크플로우 파일 생성
- ✅ GEMINI_API_KEY 활성화

## 필수 설정 작업 (Windows PC에서 수행)

### 1단계: Windows PC에 필수 프로그램 설치

다음 프로그램들을 설치하세요:

```powershell
# 설치 확인
git --version
node -v
npm -v
python --version
```

필수 설치 목록:
- Git for Windows: https://git-scm.com/download/win
- Node.js LTS: https://nodejs.org/
- Python 3.11: https://www.python.org/downloads/

---

### 2단계: GitHub Self-hosted Runner 설치

#### 2-1. GitHub에서 Runner 등록 화면 열기

1. GitHub 레포지토리 페이지로 이동
2. `Settings` → `Actions` → `Runners` 클릭
3. `New self-hosted runner` 버튼 클릭
4. OS: `Windows` 선택
5. Architecture: `x64` 선택

#### 2-2. PowerShell에서 Runner 설치

GitHub 화면에 표시되는 명령어를 복사하여 실행:

```powershell
# 권장 설치 경로
mkdir C:\actions-runner
cd C:\actions-runner

# GitHub에서 제공하는 다운로드 명령 실행 (예시)
# Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.xxx.x/actions-runner-win-x64-2.xxx.x.zip -OutFile actions-runner-win-x64-2.xxx.x.zip
# Add-Type -AssemblyName System.IO.Compression.FileSystem
# [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.xxx.x.zip", "$PWD")
```

#### 2-3. Runner 설정 (라벨 추가 필수)

```powershell
# GitHub에서 제공하는 config 명령 실행
.\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN

# 설정 중 라벨 추가 질문에서 반드시 다음 라벨 추가:
# home-desktop
```

**중요**: 라벨에 `home-desktop`을 반드시 추가해야 합니다. 이 라벨이 없으면 워크플로우가 실행되지 않습니다.

#### 2-4. Runner를 Windows 서비스로 설치 (상시 실행)

```powershell
# 관리자 권한 PowerShell에서 실행
cd C:\actions-runner
.\svc.cmd install
.\svc.cmd start
```

이제 PC가 재부팅되어도 Runner가 자동으로 시작됩니다.

#### 2-5. Runner 상태 확인

GitHub 레포지토리 → Settings → Actions → Runners에서:
- Runner가 `Online` 또는 `Idle` 상태로 표시되면 성공

---

### 3단계: GitHub Secrets에 API 키 등록

#### 3-1. Gemini API 키 발급

1. Google AI Studio 방문: https://aistudio.google.com/
2. API 키 생성
3. 발급받은 키 복사

#### 3-2. GitHub Repository Secrets 등록

1. GitHub 레포지토리 페이지로 이동
2. `Settings` → `Secrets and variables` → `Actions` 클릭
3. `New repository secret` 버튼 클릭
4. Name: `GEMINI_API_KEY`
5. Secret: (발급받은 Gemini API 키 붙여넣기)
6. `Add secret` 버튼 클릭

---

## 사용 방법

### 이슈에서 OpenCode 실행

1. **이슈 생성**: GitHub 레포지토리에서 새 이슈 생성

2. **코멘트로 실행**: 이슈 코멘트에 다음과 같이 작성

```
/oc
재현 방법:
- .venv\Scripts\python -m pytest -q

목표:
- 실패하는 테스트 수정
- 변경사항 최소화

완료 조건:
- pytest 전체 통과
- opencode_report.md에 변경 요약/테스트 결과 기록
```

3. **자동 실행**: 집 PC의 Self-hosted Runner가 작업 실행
   - 자동으로 브랜치 생성
   - 코드 변경 및 커밋
   - PR 생성
   - 이슈에 PR 링크 + 리포트 코멘트 작성

4. **결과 확인**:
   - Actions 탭에서 실행 로그 확인
   - 생성된 PR 검토
   - 이슈에 자동 작성된 리포트 확인

---

## 주의사항

### 보안
- ✅ OWNER/MEMBER/COLLABORATOR만 실행 가능 (설정 완료)
- ✅ API 키는 GitHub Secrets로만 관리 (코드에 하드코딩 금지)
- ⚠️ Self-hosted Runner는 집 PC 권한으로 코드 실행
- ⚠️ 최종 merge는 PR 리뷰 후 수동으로 진행 권장

### 실행 권한
현재 워크플로우는 다음 사용자만 `/oc` 명령 실행 가능:
- Repository OWNER
- Repository MEMBER
- Repository COLLABORATOR

---

## 테스트

모든 설정이 완료되면:

1. 테스트용 이슈 생성
2. 코멘트에 `/oc 간단한 테스트를 실행해줘` 작성
3. Actions 탭에서 워크플로우 실행 확인
4. Runner가 정상 동작하는지 확인

---

## 문제 해결

### Runner가 Offline 상태
```powershell
# Runner 서비스 재시작
cd C:\actions-runner
.\svc.cmd stop
.\svc.cmd start
```

### 워크플로우가 실행되지 않음
- Runner에 `home-desktop` 라벨이 있는지 확인
- Runner가 Online 상태인지 확인
- 코멘트 작성자가 OWNER/MEMBER/COLLABORATOR인지 확인
- 코멘트에 `/oc`가 포함되어 있는지 확인
- 이슈(Issue)인지 확인 (PR 코멘트는 실행 안됨)

### API 키 오류
- GitHub Secrets에 `GEMINI_API_KEY`가 정확히 등록되었는지 확인
- API 키가 유효한지 확인 (Google AI Studio에서 확인)

---

## 완료 체크리스트

- [ ] Git, Node.js, Python 설치 완료
- [ ] Self-hosted Runner 설치 및 등록
- [ ] Runner에 `home-desktop` 라벨 추가
- [ ] Runner를 Windows 서비스로 설치
- [ ] Runner가 Online 상태
- [ ] Gemini API 키 발급
- [ ] GitHub Secrets에 `GEMINI_API_KEY` 등록
- [ ] 테스트 이슈로 동작 확인

모든 항목이 체크되면 설정 완료입니다!
