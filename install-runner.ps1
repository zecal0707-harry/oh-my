# GitHub Self-hosted Runner 자동 설치 스크립트
# 관리자 권한으로 실행하세요

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "GitHub Self-hosted Runner 설치 스크립트" -ForegroundColor Cyan
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

# 필수 프로그램 체크
Write-Host "필수 프로그램 확인 중..." -ForegroundColor Yellow
$hasGit = Get-Command git -ErrorAction SilentlyContinue
$hasNode = Get-Command node -ErrorAction SilentlyContinue
$hasPython = Get-Command python -ErrorAction SilentlyContinue

if ($hasGit) {
    $gitVersion = git --version
    Write-Host "✅ Git: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "⚠️  Git이 설치되지 않았습니다: https://git-scm.com/download/win" -ForegroundColor Yellow
}

if ($hasNode) {
    $nodeVersion = node -v
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "⚠️  Node.js가 설치되지 않았습니다: https://nodejs.org/" -ForegroundColor Yellow
}

if ($hasPython) {
    $pythonVersion = python --version
    Write-Host "✅ Python: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "⚠️  Python이 설치되지 않았습니다: https://www.python.org/downloads/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "계속하려면 아무 키나 누르세요..." -ForegroundColor Cyan
pause
Write-Host ""

# 설치 디렉토리 생성
$runnerDir = "C:\actions-runner"
Write-Host "Runner 설치 디렉토리: $runnerDir" -ForegroundColor Cyan

if (Test-Path $runnerDir) {
    Write-Host "⚠️  디렉토리가 이미 존재합니다." -ForegroundColor Yellow
    $overwrite = Read-Host "덮어쓰시겠습니까? (y/n)"
    if ($overwrite -ne 'y') {
        Write-Host "설치를 취소합니다." -ForegroundColor Red
        exit 1
    }
} else {
    New-Item -ItemType Directory -Path $runnerDir -Force | Out-Null
    Write-Host "✅ 디렉토리 생성 완료" -ForegroundColor Green
}

Set-Location $runnerDir
Write-Host ""

# Runner 다운로드
Write-Host "Runner 다운로드 중..." -ForegroundColor Yellow
$zipFile = "$runnerDir\actions-runner-win-x64.zip"

try {
    Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/latest/download/actions-runner-win-x64-latest.zip" -OutFile $zipFile
    Write-Host "✅ 다운로드 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ 다운로드 실패: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 압축 해제
Write-Host "압축 해제 중..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $runnerDir)
    Remove-Item $zipFile -Force
    Write-Host "✅ 압축 해제 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ 압축 해제 실패: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "GitHub에서 토큰을 받아야 합니다" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "다음 단계를 진행하세요:" -ForegroundColor Yellow
Write-Host "1. 웹브라우저로 GitHub 레포지토리 열기" -ForegroundColor Yellow
Write-Host "2. Settings → Actions → Runners 클릭" -ForegroundColor Yellow
Write-Host "3. 'New self-hosted runner' 버튼 클릭" -ForegroundColor Yellow
Write-Host "4. OS: Windows, Architecture: x64 선택" -ForegroundColor Yellow
Write-Host "5. 'Configure' 섹션의 명령어 확인" -ForegroundColor Yellow
Write-Host ""
Write-Host "예시:" -ForegroundColor Gray
Write-Host ".\config.cmd --url https://github.com/사용자명/레포명 --token ABCD1234..." -ForegroundColor Gray
Write-Host ""

# GitHub URL 입력
$repoUrl = Read-Host "GitHub 레포지토리 URL을 입력하세요 (예: https://github.com/username/repo)"
if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "❌ URL이 입력되지 않았습니다." -ForegroundColor Red
    exit 1
}

# 토큰 입력
$token = Read-Host "GitHub 토큰을 입력하세요 (GitHub 화면에서 복사)"
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "❌ 토큰이 입력되지 않았습니다." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Runner 설정
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
    & "$runnerDir\config.cmd" --url $repoUrl --token $token
    if ($LASTEXITCODE -ne 0) {
        throw "config.cmd 실행 실패"
    }
    Write-Host "✅ Runner 설정 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ Runner 설정 실패: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "다시 시도하려면:" -ForegroundColor Yellow
    Write-Host "cd C:\actions-runner" -ForegroundColor Yellow
    Write-Host ".\config.cmd --url $repoUrl --token YOUR_NEW_TOKEN" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 서비스 설치
Write-Host "Windows 서비스로 설치 중..." -ForegroundColor Yellow
try {
    & "$runnerDir\svc.cmd" install
    if ($LASTEXITCODE -ne 0) {
        throw "svc install 실패"
    }
    Write-Host "✅ 서비스 설치 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ 서비스 설치 실패: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 서비스 시작
Write-Host "서비스 시작 중..." -ForegroundColor Yellow
try {
    & "$runnerDir\svc.cmd" start
    if ($LASTEXITCODE -ne 0) {
        throw "svc start 실패"
    }
    Write-Host "✅ 서비스 시작 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ 서비스 시작 실패: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 상태 확인
Write-Host "서비스 상태 확인 중..." -ForegroundColor Yellow
& "$runnerDir\svc.cmd" status

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "설치 완료!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host "1. GitHub → Settings → Actions → Runners에서 확인" -ForegroundColor Yellow
Write-Host "   - Runner 상태가 'Online'이어야 함" -ForegroundColor Yellow
Write-Host "   - Labels에 'home-desktop'이 포함되어야 함" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. GitHub Secrets에 GEMINI_API_KEY 등록" -ForegroundColor Yellow
Write-Host "   - Settings → Secrets and variables → Actions" -ForegroundColor Yellow
Write-Host "   - New repository secret 클릭" -ForegroundColor Yellow
Write-Host "   - Name: GEMINI_API_KEY" -ForegroundColor Yellow
Write-Host "   - Secret: (Google AI Studio에서 발급받은 키)" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. 테스트 이슈 생성 후 '/oc' 코멘트 작성" -ForegroundColor Yellow
Write-Host ""
Write-Host "문제가 있다면:" -ForegroundColor Cyan
Write-Host "cd C:\actions-runner" -ForegroundColor Gray
Write-Host ".\svc.cmd status     # 상태 확인" -ForegroundColor Gray
Write-Host ".\svc.cmd stop       # 중지" -ForegroundColor Gray
Write-Host ".\svc.cmd start      # 시작" -ForegroundColor Gray
Write-Host ""
pause
