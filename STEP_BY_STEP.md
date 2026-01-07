# Runner 재설정 단계별 가이드 (oh-my 레포지토리용)

현재 Runner가 `scanner-project`에 연결되어 있으므로, `oh-my` 레포지토리용으로 재설정합니다.

---

## 방법 1: 자동 스크립트 사용 (추천)

### 1단계: 관리자 PowerShell 열기

1. 시작 메뉴에서 "PowerShell" 검색
2. **Windows PowerShell** 마우스 오른쪽 클릭
3. **관리자 권한으로 실행** 선택

### 2단계: 스크립트 실행

```powershell
cd D:\github\oh-my
.\reconfigure-runner.ps1
```

### 3단계: 스크립트 안내 따라하기

스크립트가 다음을 안내합니다:

#### A. GitHub에서 토큰 받기

**기존 Runner 제거 토큰:**
1. https://github.com/사용자명/scanner-project (기존 레포)
2. Settings → Actions → Runners
3. 현재 등록된 Runner 클릭
4. "Remove" 버튼 클릭
5. 표시되는 제거 토큰 복사

**새 Runner 등록 토큰:**
1. https://github.com/사용자명/oh-my (새 레포)
2. Settings → Actions → Runners
3. "New self-hosted runner" 클릭
4. OS: Windows, Architecture: x64 선택
5. Configure 섹션의 토큰 확인

#### B. 토큰 입력

스크립트가 물어보면:
- 제거 토큰 입력
- 새 레포 URL 입력: `https://github.com/사용자명/oh-my`
- 등록 토큰 입력

#### C. 설정 질문 답변

- runner group: **[Enter]**
- runner name: **[Enter]**
- labels: **home-desktop** ← 반드시 입력!
- work folder: **[Enter]**

완료!

---

## 방법 2: 수동 설정

자동 스크립트를 사용하지 않고 수동으로 진행하려면:

### 1단계: GitHub에서 토큰 받기

#### 제거 토큰 (scanner-project에서)

1. https://github.com/사용자명/scanner-project
2. Settings → Actions → Runners
3. 등록된 Runner 클릭 → Remove
4. 제거 토큰 복사

#### 등록 토큰 (oh-my에서)

1. https://github.com/사용자명/oh-my
2. Settings → Actions → Runners
3. New self-hosted runner
4. Windows / x64 선택
5. Configure 섹션의 토큰 확인

### 2단계: 관리자 PowerShell에서 실행

```powershell
# Runner 폴더로 이동
cd C:\actions-runner

# 기존 설정 제거
.\config.cmd remove --token YOUR_REMOVAL_TOKEN

# 새 설정 적용
.\config.cmd --url https://github.com/사용자명/oh-my --token YOUR_NEW_TOKEN

# 질문 답변:
# - runner group: [Enter]
# - runner name: [Enter]
# - labels: home-desktop  ← 중요!
# - work folder: [Enter]

# Windows 서비스로 설치
.\svc.cmd install

# 서비스 시작
.\svc.cmd start

# 상태 확인
.\svc.cmd status
```

---

## 확인 사항

### GitHub에서 확인

1. https://github.com/사용자명/oh-my
2. Settings → Actions → Runners
3. 확인:
   - ✅ Runner 상태: **Online** 또는 **Idle**
   - ✅ Labels: **home-desktop** 포함
   - ✅ Status: **Active**

### PC에서 확인

```powershell
cd C:\actions-runner
.\svc.cmd status
```

"Running" 메시지 표시되면 성공!

---

## 다음 단계

Runner 재설정 완료 후:

### 1. GitHub Secrets에 API 키 등록

1. https://github.com/사용자명/oh-my
2. Settings → Secrets and variables → Actions
3. New repository secret 클릭
4. Name: `GEMINI_API_KEY`
5. Secret: (Google AI Studio에서 발급받은 키)
6. Add secret 클릭

**Google AI Studio:** https://aistudio.google.com/

### 2. 테스트 실행

1. oh-my 레포지토리에서 이슈 생성
2. 이슈 코멘트에 작성:

```
/oc 간단한 테스트를 실행해줘
```

3. Actions 탭에서 워크플로우 실행 확인
4. 몇 분 후 PR 생성 및 이슈 코멘트 확인

---

## 문제 해결

### Runner가 Online 안됨

```powershell
cd C:\actions-runner
.\svc.cmd stop
.\svc.cmd start
.\svc.cmd status
```

### Labels에 home-desktop 없음

1. Runner 제거
2. 재설정 시 labels 질문에 `home-desktop` 입력

### 토큰 만료

- GitHub에서 새 토큰 생성
- 다시 config 실행

---

## 요약

1. **관리자 PowerShell** 열기
2. `.\reconfigure-runner.ps1` 실행
3. GitHub에서 토큰 받기
4. 스크립트 안내 따라하기
5. Labels에 `home-desktop` 입력
6. GitHub에서 Online 확인
7. GEMINI_API_KEY 등록
8. 테스트 이슈로 `/oc` 실행

완료!
