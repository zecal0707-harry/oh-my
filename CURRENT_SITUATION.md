# 현재 상황 및 다음 작업

## 자동 설정 제한 사항

현재 제가 할 수 있는 범위에 제한이 있습니다:

### ✅ 완료된 작업
1. `.github/workflows/opencode.yml` 워크플로우 파일 생성
2. GEMINI_API_KEY 활성화
3. `home-desktop` 라벨 설정 확인 (이미 설정됨)
4. 설치/설정 가이드 문서 작성
5. 자동 설정 스크립트 작성

### ⚠️ 제한 사항
다음 작업들은 **관리자 권한**과 **GitHub 토큰**이 필요하여 수동으로 진행해야 합니다:

1. **Windows 서비스 설치** - 관리자 권한 필요
2. **Runner 레포지토리 변경** - GitHub 토큰 필요
3. **GitHub Secrets 등록** - GitHub 웹 인터페이스 필요

---

## 현재 Runner 상태

```
설치 위치: C:\actions-runner
연결된 레포: scanner-project
필요한 레포: oh-my (현재 작업 레포)
Labels: home-desktop ✅
서비스 설치: 미확인
```

---

## 선택 방안

### 옵션 A: 간단한 방법 - scanner-project에서 사용

**장점**: 추가 설정 불필요, 즉시 사용 가능

**작업**:
1. scanner-project 레포에 워크플로우 파일 복사
2. scanner-project에 GEMINI_API_KEY 등록
3. scanner-project에서 이슈 생성 후 `/oc` 테스트

---

### 옵션 B: oh-my 레포용으로 재설정 (권장)

**장점**: 현재 작업 레포에서 직접 사용

**필요한 작업**:

#### 1단계: 관리자 PowerShell 실행

```powershell
cd D:\github\oh-my
.\reconfigure-runner.ps1
```

#### 2단계: GitHub에서 토큰 받기

**제거 토큰** (scanner-project):
- https://github.com/사용자명/scanner-project
- Settings → Actions → Runners
- Runner 클릭 → Remove → 토큰 복사

**등록 토큰** (oh-my):
- https://github.com/사용자명/oh-my
- Settings → Actions → Runners
- New self-hosted runner → 토큰 복사

#### 3단계: 스크립트에 토큰 입력
- 제거 토큰 입력
- oh-my 레포 URL 입력
- 등록 토큰 입력
- **Labels: home-desktop** 입력

#### 4단계: GEMINI_API_KEY 등록

- https://aistudio.google.com/ 에서 API 키 발급
- https://github.com/사용자명/oh-my
- Settings → Secrets and variables → Actions
- New repository secret
  - Name: `GEMINI_API_KEY`
  - Secret: (발급받은 키)

#### 5단계: 테스트

- oh-my 레포에서 이슈 생성
- 코멘트: `/oc 간단한 테스트`

---

## 빠른 실행 명령

### 옵션 A 선택 시
1. scanner-project에 `.github/workflows/opencode.yml` 복사
2. GEMINI_API_KEY 등록
3. 테스트

### 옵션 B 선택 시
```powershell
# 관리자 PowerShell에서
cd D:\github\oh-my
.\reconfigure-runner.ps1
```

---

## 도움말 파일

- `reconfigure-runner.ps1` - 자동 재설정 스크립트
- `STEP_BY_STEP.md` - 상세 단계별 가이드
- `QUICK_START.md` - 빠른 시작 가이드
- `install-runner.ps1` - 새 설치 스크립트

---

## 추천

**옵션 B (재설정)** 를 추천합니다:

1. 관리자 PowerShell을 열고
2. `cd D:\github\oh-my`
3. `.\reconfigure-runner.ps1` 실행
4. 화면 안내에 따라 GitHub 토큰 입력

모든 작업은 스크립트가 자동으로 처리합니다!
