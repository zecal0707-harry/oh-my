# GitHub Self-hosted Runner 재설정 스크립트 (oh-my 레포지토리용)
# 관리자 권한으로 실행하세요

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "GitHub Runner 재설정 (oh-my 레포지토리용)" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 관리자 권한 체크
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ 오류: 이 스크립트는 관리자 권한으로 실행해야 합니다." -ForegroundColor Red
    Write-Host ""
    Write-Host "해결 방법:" -ForegroundColor Yellow
    Write-Host "1. PowerShell을 마우스 오른쪽 클릭" -ForegroundColor Yellow
    Write-Host "2. '관리자 권한으로 실행' 선택" -ForegroundColor Yellow
    Write-Host "3. 이 스크립트 다시 실행" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ 관리자 권한 확인 완료" -ForegroundColor Green
Write-Host ""

# Runner 디렉토리 확인
$runnerDir = "C:\actions-runner"
if (-not (Test-Path $runnerDir)) {
    Write-Host "❌ Runner 디렉토리가 없습니다: $runnerDir" -ForegroundColor Red
    Write-Host "먼저 install-runner.ps1을 실행하세요." -ForegroundColor Yellow
    pause
    exit 1
}

Set-Location $runnerDir
Write-Host "✅ Runner 디렉토리 확인: $runnerDir" -ForegroundColor Green
Write-Host ""

# 기존 설정 확인
if (Test-Path ".runner") {
    Write-Host "기존 Runner 설정 발견:" -ForegroundColor Yellow
    $runnerConfig = Get-Content ".runner" | ConvertFrom-Json
    Write-Host "  - GitHub URL: $($runnerConfig.gitHubUrl)" -ForegroundColor Gray
    Write-Host "  - Runner Name: $($runnerConfig.agentName)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "1단계: GitHub에서 토큰 받기" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "아래 단계를 따라 GitHub에서 토큰을 받으세요:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 웹브라우저로 GitHub 레포지토리 열기" -ForegroundColor White
Write-Host "   https://github.com/사용자명/oh-my" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Settings 클릭" -ForegroundColor White
Write-Host ""
Write-Host "3. 왼쪽 메뉴에서 Actions → Runners 클릭" -ForegroundColor White
Write-Host ""
Write-Host "4-1. 기존 Runner 제거 토큰 받기:" -ForegroundColor White
Write-Host "   - 현재 등록된 Runner 찾기 (scanner-project용)" -ForegroundColor Gray
Write-Host "   - Runner 이름 클릭" -ForegroundColor Gray
Write-Host "   - Remove 버튼 클릭하면 제거 토큰 표시" -ForegroundColor Gray
Write-Host "   - 토큰 복사" -ForegroundColor Gray
Write-Host ""
Write-Host "4-2. 새 Runner 등록 토큰 받기:" -ForegroundColor White
Write-Host "   - 'New self-hosted runner' 버튼 클릭" -ForegroundColor Gray
Write-Host "   - OS: Windows, Architecture: x64 선택" -ForegroundColor Gray
Write-Host "   - Configure 섹션의 토큰 확인" -ForegroundColor Gray
Write-Host ""
pause
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "2단계: 기존 Runner 제거" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 제거 토큰 입력
$removeToken = Read-Host "GitHub에서 받은 제거 토큰을 입력하세요 (또는 Enter로 건너뛰기)"

if (-not [string]::IsNullOrWhiteSpace($removeToken)) {
    Write-Host "기존 Runner 제거 중..." -ForegroundColor Yellow
    try {
        & "$runnerDir\config.cmd" remove --token $removeToken
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 기존 Runner 제거 완료" -ForegroundColor Green
        } else {
            Write-Host "⚠️  제거 실패 또는 이미 제거됨. 계속 진행합니다." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  제거 중 오류 발생. 계속 진행합니다." -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  제거 건너뜀. 설정이 덮어쓰기 됩니다." -ForegroundColor Yellow
}

Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "3단계: 새 Runner 설정 (oh-my 레포지토리용)" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 레포지토리 URL 입력
Write-Host "oh-my 레포지토리 URL을 입력하세요" -ForegroundColor Yellow
Write-Host "예시: https://github.com/username/oh-my" -ForegroundColor Gray
$repoUrl = Read-Host "URL"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "❌ URL이 입력되지 않았습니다." -ForegroundColor Red
    pause
    exit 1
}

# 등록 토큰 입력
Write-Host ""
Write-Host "GitHub에서 받은 새 등록 토큰을 입력하세요" -ForegroundColor Yellow
Write-Host "(New self-hosted runner 화면의 Configure 섹션)" -ForegroundColor Gray
$configToken = Read-Host "토큰"

if ([string]::IsNullOrWhiteSpace($configToken)) {
    Write-Host "❌ 토큰이 입력되지 않았습니다." -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "Runner 설정 중..." -ForegroundColor Yellow
Write-Host ""
Write-Host "다음 질문들에 답해주세요:" -ForegroundColor Cyan
Write-Host "- runner group: [Enter]" -ForegroundColor Gray
Write-Host "- runner name: [Enter]" -ForegroundColor Gray
Write-Host "- labels: home-desktop ← 반드시 입력!" -ForegroundColor Red
Write-Host "- work folder: [Enter]" -ForegroundColor Gray
Write-Host ""
pause

try {
    & "$runnerDir\config.cmd" --url $repoUrl --token $configToken
    if ($LASTEXITCODE -ne 0) {
        throw "config.cmd 실행 실패"
    }
    Write-Host "✅ Runner 설정 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ Runner 설정 실패: $_" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "4단계: Windows 서비스로 설치" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 서비스 설치
Write-Host "Windows 서비스로 설치 중..." -ForegroundColor Yellow
try {
    & "$runnerDir\svc.cmd" install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  서비스 설치 실패 또는 이미 설치됨" -ForegroundColor Yellow
    } else {
        Write-Host "✅ 서비스 설치 완료" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  서비스 설치 중 오류: $_" -ForegroundColor Yellow
}

Write-Host ""

# 서비스 시작
Write-Host "서비스 시작 중..." -ForegroundColor Yellow
try {
    & "$runnerDir\svc.cmd" start
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  서비스 시작 실패" -ForegroundColor Yellow
    } else {
        Write-Host "✅ 서비스 시작 완료" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  서비스 시작 중 오류: $_" -ForegroundColor Yellow
}

Write-Host ""

# 상태 확인
Write-Host "서비스 상태 확인 중..." -ForegroundColor Yellow
& "$runnerDir\svc.cmd" status

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "재설정 완료!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. GitHub 확인" -ForegroundColor White
Write-Host "   https://github.com/사용자명/oh-my" -ForegroundColor Gray
Write-Host "   → Settings → Actions → Runners" -ForegroundColor Gray
Write-Host "   - Runner 상태가 'Online'이어야 함" -ForegroundColor Gray
Write-Host "   - Labels에 'home-desktop'이 포함되어야 함" -ForegroundColor Gray
Write-Host ""
Write-Host "2. GitHub Secrets에 GEMINI_API_KEY 등록" -ForegroundColor White
Write-Host "   → Settings → Secrets and variables → Actions" -ForegroundColor Gray
Write-Host "   → New repository secret" -ForegroundColor Gray
Write-Host "   - Name: GEMINI_API_KEY" -ForegroundColor Gray
Write-Host "   - Secret: (Google AI Studio에서 발급)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 테스트" -ForegroundColor White
Write-Host "   - 이슈 생성" -ForegroundColor Gray
Write-Host "   - 코멘트에 '/oc 테스트' 작성" -ForegroundColor Gray
Write-Host ""
pause
