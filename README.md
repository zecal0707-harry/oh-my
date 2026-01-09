# 📱 PocketDev (포켓데브)

> **"Development in your pocket."**
> 핸드폰 댓글 하나로 집 PC의 AI 에이전트를 깨워 코딩을 시키는 원격 자동화 시스템

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-Self--hosted-blue?logo=github-actions)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?logo=python)
![OpenCode](https://img.shields.io/badge/AI_Agent-OpenCode-FF9900)

## 📖 개요 (Overview)

**PocketDev**는 GitHub Issues 코멘트를 트리거로 사용하여, 집에 있는 Windows 데스크탑(Self-hosted Runner)에서 AI 코딩 에이전트를 실행하는 시스템입니다.

외부에서 스마트폰으로 이슈에 `/oc` 명령을 남기면, 집 PC가 깨어나 코드를 수정하고, 테스트를 수행한 뒤, PR(Pull Request)까지 자동으로 생성합니다.

### 핵심 기능
- **📱 모바일 트리거**: GitHub 앱으로 어디서든 개발 명령 하달
- **🏠 로컬 실행**: 집 PC의 강력한 성능과 로컬 환경(GPU, DB 등) 활용 가능
- **🤖 AI 에이전트**: OpenCode AI(Gemini/Claude/OpenAI)가 코드 작성 및 수정
- **✅ 자동 검증**: `pytest` 자동 실행 및 결과 리포팅
- **🔄 CI/CD 통합**: 변경사항 자동 커밋, Push, PR 생성

---

## 🏗️ 아키텍처 (Architecture)

```mermaid
graph TD
    User[📱 User (Mobile/Web)] -->|Comment '/oc ...'| Issue[GitHub Issue]
    Issue -->|Trigger| GHA[GitHub Actions]
    GHA -->|Dispatch| Runner[🏠 Home PC (Self-hosted Runner)]
    
    subgraph "Home PC Environment"
        Runner -->|Exec| Agent[🤖 OpenCode Agent]
        Agent -->|Read/Write| Code[Source Code]
        Agent -->|Run| Test[pytest / Verification]
    end
    
    Runner -->|Git Push| Repo[GitHub Repository]
    Repo -->|Create PR| PR[Pull Request]
    PR -->|Notification| User
```

1. **Trigger**: 사용자가 이슈에 `/oc [지시사항]` 코멘트 작성
2. **Action**: GitHub Actions가 `issue_comment` 이벤트를 감지
3. **Runner**: 등록된 Windows Self-hosted Runner(집 PC)가 작업을 가져감
4. **Agent**: `opencode` CLI가 실행되어 지시사항 분석 및 코드 수정
5. **Report**: 수정 내역과 테스트 결과를 `opencode_report.md`로 저장
6. **PR**: 변경사항이 있는 경우 자동으로 브랜치 생성 및 PR 오픈

---

## 🚀 설치 및 설정 가이드 (Setup Guide)

이 시스템을 구축하기 위해서는 **GitHub 저장소**와 **상시 구동되는 Windows PC**가 필요합니다.

### 1. 필수 요구사항 (Prerequisites)
- **OS**: Windows 10/11 (x64)
- **Tools**:
  - [Git for Windows](https://git-scm.com/download/win)
  - [Node.js](https://nodejs.org/) (LTS 버전, OpenCode 실행용)
  - [Python 3.11+](https://www.python.org/)
- **API Key**: Gemini, Anthropic, 또는 OpenAI API 키

### 2. OpenCode CLI 설치
집 PC의 PowerShell에서 실행:
```powershell
npm install -g opencode-ai
opencode --version
# 로그인 (필요시)
# opencode login
```

### 3. GitHub Self-hosted Runner 설정
1. GitHub 저장소 > **Settings** > **Actions** > **Runners** > **New self-hosted runner**
2. **Windows** 선택 후 제공되는 명령어 순차 실행
3. **서비스 등록** (PC 재부팅 후 자동 실행을 위해 필수):
   ```powershell
   cd C:\actions-runner  # 설치 경로
   .\svc.cmd install
   .\svc.cmd start
   ```
4. Runner 상태가 **"Idle"** (초록불)인지 확인.

### 4. Secrets 설정
GitHub 저장소 > **Settings** > **Secrets and variables** > **Actions** > **New repository secret**:
- `GEMINI_API_KEY`: Google Gemini API 키 (또는 `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`)

### 5. 권한 설정 (중요)
GitHub Actions가 PR을 생성하고 코멘트를 달 수 있도록 권한을 열어줘야 합니다.
1. **Settings** > **Actions** > **General** > **Workflow permissions**
2. **Read and write permissions** 선택
3. **Allow GitHub Actions to create and approve pull requests** 체크
4. Save

---

## 💻 사용 방법 (Usage)

### 1. 이슈 생성
작업하고 싶은 내용을 담은 이슈를 생성합니다. (예: "로그인 페이지 기능 구현")

### 2. 명령어 입력
이슈 코멘트에 다음과 같이 입력합니다.

```text
/oc
로그인 기능을 구현해줘.
ID/PW 입력창과 로그인 버튼이 있어야 해.
flask로 작성하고 간단한 테스트 코드도 포함해줘.
```

### 3. 자동 처리 확인
- GitHub Actions 탭에서 워크플로우 실행 확인 (`OpenCode Agent (Windows self-hosted, Python)`)
- 작업 완료 후 자동으로 PR이 생성됨
- 이슈에 봇이 PR 링크와 요약 리포트를 코멘트로 남김

---

## 🛠️ 개발자 가이드 (Advanced)

### 워크플로우 구조 (`.github/workflows/opencode.yml`)
- **Trigger**: `issue_comment` (created)
- **Condition**: 
  - 본문에 `/oc` 포함
  - PR 코멘트가 아님
  - 작성자가 권한 보유자(Owner/Member)
- **Job Steps**:
  1. `Checkout`: 코드 내려받기
  2. `Env Setup`: Python, Node.js 설정
  3. `Branch`: 작업용 임시 브랜치 생성 (`oc/issue-{number}-{run_id}`)
  4. `Agent Run`: 
     - PowerShell 스크립트로 프롬프트 구성
     - `opencode run "$prompt"` 실행
     - `pytest` 실행 및 결과 캡처
  5. `Git Commit & Push`: 변경사항 반영
  6. `Create PR`: `gh pr create` 명령어로 PR 생성
  7. `Comment`: 이슈에 결과 통보

### 커스터마이징
- **Python 환경**: `.venv`를 사용하도록 설정되어 있습니다. `requirements.txt`가 있다면 자동으로 설치합니다.
- **프롬프트 수정**: 워크플로우 파일 내 `$prompt` 변수를 수정하여 에이전트의 페르소나나 제약조건을 변경할 수 있습니다.

---

## ⚠️ 트러블슈팅

**Q. 워크플로우가 실행되지 않아요.**
- 이슈 코멘트가 아닌 PR 코멘트인지 확인하세요.
- 권한이 없는 계정으로 코멘트를 남겼는지 확인하세요.
- Runner가 Offline인지 확인하세요.

**Q. PR 생성 단계에서 실패해요.**
- `Workflow permissions`에서 `Read and write` 및 `Allow PR creation`이 체크되어 있는지 확인하세요.

**Q. 한글이 깨져요.**
- Windows 콘솔의 인코딩 문제입니다. Python 실행 시 `PYTHONIOENCODING=utf-8` 환경변수를 사용하도록 워크플로우가 구성되어 있습니다.

---

**PocketDev** - 내 손안의 코딩 에이전트.
