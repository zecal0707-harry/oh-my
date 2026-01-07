# GitHub Actions Runner 현재 상태

## 확인된 사항

### ✅ 설치 완료
- Runner 설치 위치: `C:\actions-runner`
- Runner 다운로드 완료
- 필수 프로그램 설치됨:
  - Git: 2.52.0
  - Node.js: 24.12.0
  - Python: 3.14.2

### ⚠️ 설정 상태
- Runner가 다른 레포지토리에 연결됨: `scanner-project`
- 현재 작업 레포지토리: `oh-my` (다름!)
- Runner 서비스 미설치 (Windows 서비스로 등록 안됨)

---

## 선택 사항

현재 레포지토리(`oh-my`)에서 OpenCode 워크플로우를 사용하려면 두 가지 방법이 있습니다:

### 옵션 1: scanner-project 레포지토리에서 사용
- scanner-project 레포지토리에 `.github/workflows/opencode.yml` 복사
- 이미 설정된 Runner 사용
- 장점: 추가 설정 불필요

### 옵션 2: oh-my 레포지토리용으로 Runner 재설정 (권장)
- 기존 Runner 제거 후 oh-my 레포지토리용으로 재설정
- `home-desktop` 라벨 추가
- Windows 서비스로 등록하여 상시 실행

---

## 권장 사항: oh-my 레포지토리용으로 재설정

현재 작업 중인 레포지토리가 `oh-my`이므로, Runner를 이 레포지토리용으로 재설정하는 것을 권장합니다.

### 필요한 작업 (수동 진행 필요)

#### 1단계: GitHub에서 토큰 받기

1. 웹브라우저로 https://github.com/사용자명/oh-my 접속
2. Settings → Actions → Runners 클릭
3. New self-hosted runner 클릭
4. OS: Windows, Architecture: x64 선택
5. 토큰이 포함된 config 명령 확인 (복사하지 말고 다음 단계 참고)

#### 2단계: 기존 Runner 재설정

**관리자 PowerShell**에서 실행:

```powershell
# C:\actions-runner 폴더로 이동
cd C:\actions-runner

# 기존 설정 제거 (GitHub에서 받은 제거 토큰 필요)
.\config.cmd remove --token YOUR_REMOVAL_TOKEN

# 새 설정 적용 (GitHub에서 받은 새 토큰 사용)
.\config.cmd --url https://github.com/사용자명/oh-my --token YOUR_NEW_TOKEN
```

설정 질문 답변:
- runner group: [Enter]
- runner name: [Enter] 또는 원하는 이름
- **labels: home-desktop** ← 중요!
- work folder: [Enter]

#### 3단계: Windows 서비스로 설치

```powershell
# 관리자 PowerShell에서
cd C:\actions-runner
.\svc.cmd install
.\svc.cmd start
```

#### 4단계: 확인

- GitHub → Settings → Actions → Runners
- Runner 상태: Online
- Labels에 "home-desktop" 포함 확인

---

## 또는 자동 스크립트 사용

이 폴더에 있는 `install-runner.ps1` 스크립트를 사용할 수도 있습니다.
기존 설정을 덮어쓰고 새로 설치합니다.

```powershell
# 관리자 PowerShell
cd D:\github\oh-my
.\install-runner.ps1
```

---

## 다음 단계

Runner 설정 완료 후:
1. GitHub Secrets에 GEMINI_API_KEY 등록
2. 테스트 이슈 생성 후 `/oc` 코멘트로 테스트

상세 가이드: `SETUP_GUIDE.md` 또는 `QUICK_START.md` 참고
