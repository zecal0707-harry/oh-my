# Self-hosted Runner 설치 가이드 (1단계)

## 사전 준비

### 필수 프로그램 설치 확인

PowerShell을 열고 다음 명령으로 확인:

```powershell
# 버전 확인
git --version
node -v
python --version
```

모두 버전이 표시되어야 합니다. 설치되지 않았다면:
- Git: https://git-scm.com/download/win
- Node.js: https://nodejs.org/ (LTS 버전)
- Python: https://www.python.org/downloads/ (3.11 권장)

---

## Step 1: GitHub에서 Runner 토큰 받기

1. 웹브라우저로 GitHub 레포지토리 열기
2. 상단 메뉴에서 **Settings** 클릭
3. 왼쪽 메뉴에서 **Actions** → **Runners** 클릭
4. 오른쪽 상단의 **New self-hosted runner** 버튼 클릭
5. OS: **Windows** 선택
6. Architecture: **x64** 선택
7. 화면에 표시되는 명령어들을 확인 (복사하지 마세요, 아래 단계를 따라하세요)

**중요**: 이 화면을 닫지 말고 열어두세요! (토큰이 포함되어 있습니다)

---

## Step 2: Runner 다운로드 및 설치

### 2-1. 관리자 권한으로 PowerShell 열기

1. 시작 메뉴에서 "PowerShell" 검색
2. **Windows PowerShell**을 마우스 오른쪽 클릭
3. **관리자 권한으로 실행** 선택

### 2-2. 설치 디렉토리 생성

```powershell
# Runner 설치 디렉토리 생성
mkdir C:\actions-runner
cd C:\actions-runner
```

### 2-3. Runner 다운로드

GitHub 화면의 "Download" 섹션에 있는 명령을 복사해서 실행하거나,
아래 명령 실행 (최신 버전 자동 다운로드):

```powershell
# 최신 Runner 다운로드
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/latest/download/actions-runner-win-x64-latest.zip -OutFile actions-runner-win-x64.zip

# 압축 해제
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64.zip", "$PWD")
```

---

## Step 3: Runner 설정

### 3-1. GitHub 화면에서 토큰 복사

GitHub의 "Configure" 섹션에 다음과 같은 명령이 있습니다:

```
.\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token ABCDEFG...
```

**이 전체 명령을 복사하세요!** (토큰이 포함되어 있습니다)

### 3-2. PowerShell에서 설정 실행

복사한 명령을 PowerShell에 붙여넣고 실행:

```powershell
.\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN
```

### 3-3. 설정 질문에 답하기

다음과 같은 질문들이 나옵니다:

```
Enter the name of the runner group to add this runner to: [press Enter for Default]
→ 그냥 Enter 누르기

Enter the name of runner: [press Enter for 기본이름]
→ 그냥 Enter 누르기 (또는 원하는 이름 입력)

Enter any additional labels (ex. label-1,label-2): [press Enter to skip]
→ home-desktop 입력 (중요!)

Enter name of work folder: [press Enter for _work]
→ 그냥 Enter 누르기
```

**가장 중요**: "additional labels" 질문에 반드시 `home-desktop` 입력!

---

## Step 4: Runner를 Windows 서비스로 설치

### 4-1. 서비스 설치

관리자 PowerShell에서 계속:

```powershell
# 서비스로 설치
.\svc.cmd install
```

### 4-2. 서비스 시작

```powershell
# 서비스 시작
.\svc.cmd start
```

### 4-3. 상태 확인

```powershell
# 서비스 상태 확인
.\svc.cmd status
```

"Running" 또는 "Started" 메시지가 표시되면 성공!

---

## Step 5: GitHub에서 확인

1. GitHub 레포지토리 → Settings → Actions → Runners
2. 방금 등록한 Runner가 표시되어야 함
3. 상태가 **"Online"** 또는 **"Idle"**로 표시되면 성공!
4. Labels에 **"home-desktop"**이 포함되어 있는지 확인

---

## 문제 해결

### Runner가 Offline 상태

```powershell
# 서비스 재시작
cd C:\actions-runner
.\svc.cmd stop
.\svc.cmd start
.\svc.cmd status
```

### Labels에 home-desktop이 없는 경우

1. Runner 삭제:
```powershell
cd C:\actions-runner
.\svc.cmd stop
.\svc.cmd uninstall
.\config.cmd remove --token YOUR_REMOVAL_TOKEN
```

2. Step 3부터 다시 진행 (labels 질문에 `home-desktop` 입력)

### 토큰이 만료된 경우

- GitHub → Settings → Actions → Runners → New self-hosted runner
- 새 토큰 생성하여 다시 config 실행

---

## 완료 확인

다음이 모두 충족되면 1단계 완료:

- [x] C:\actions-runner 폴더 생성됨
- [x] Runner 설치 완료
- [x] Labels에 "home-desktop" 포함
- [x] GitHub에서 Runner 상태가 "Online"
- [x] Windows 서비스로 등록되어 자동 실행됨

---

## 다음 단계

1단계 완료 후:
- **2단계**: GitHub Secrets에 GEMINI_API_KEY 등록
- **3단계**: 테스트 이슈로 동작 확인

전체 가이드는 `SETUP_GUIDE.md` 참고
