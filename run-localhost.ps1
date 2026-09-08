$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$MobileRoot = Join-Path $ProjectRoot 'mobile'
$BackendRoot = Join-Path $ProjectRoot 'backend'
$BackendPython = Join-Path $BackendRoot 'venv\Scripts\python.exe'
$Python = (Get-Command python -ErrorAction Stop).Source

Write-Host 'Building Flutter web preview...' -ForegroundColor Cyan
Push-Location $MobileRoot
try {
    flutter pub get
    flutter build web --release --pwa-strategy=none

    Write-Host 'Building Android debug APK...' -ForegroundColor Cyan
    # A previous interrupted Gradle run can leave Kotlin incremental caches
    # locked. Stop the project daemon and clear only generated cache files.
    $JdkRoot = 'D:\\android sdk\\jbr'
    $Gradle = Join-Path $MobileRoot 'android\\gradlew.bat'
    if (Test-Path $Gradle) {
        $env:JAVA_HOME = $JdkRoot
        & $Gradle --stop | Out-Host
    }
    Remove-Item -LiteralPath (Join-Path $MobileRoot 'build\\video_player_android\\kotlin') -Recurse -Force -ErrorAction SilentlyContinue
    flutter build apk --debug
}
finally {
    Pop-Location
}

$ApkPath = Join-Path $MobileRoot 'build\\app\\outputs\\flutter-apk\\app-debug.apk'
if (-not (Test-Path $ApkPath)) {
    throw "APK build completed without producing $ApkPath"
}

# Replace only listeners owned by prior local preview runs.
$Ports = @(8000, 8087)
$OldPids = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in $Ports } |
    Select-Object -ExpandProperty OwningProcess -Unique
foreach ($OldPid in $OldPids) {
    Stop-Process -Id $OldPid -Force -ErrorAction SilentlyContinue
}

Write-Host 'Starting FastAPI on http://127.0.0.1:8000 ...' -ForegroundColor Cyan
Start-Process -WindowStyle Hidden -FilePath $BackendPython `
    -ArgumentList '-m', 'uvicorn', 'app.main:app', '--host', '127.0.0.1', '--port', '8000' `
    -WorkingDirectory $BackendRoot

Write-Host 'Starting Flutter web preview on http://127.0.0.1:8087 ...' -ForegroundColor Cyan
$WebRoot = Join-Path $MobileRoot 'build\web'
Start-Process -WindowStyle Hidden -FilePath $Python `
    -ArgumentList '-m', 'http.server', '8087', '--bind', '127.0.0.1' `
    -WorkingDirectory $WebRoot

Write-Host ''
Write-Host 'GauRakshak is ready.' -ForegroundColor Green
Write-Host 'Web:    http://127.0.0.1:8087/'
Write-Host 'API:    http://127.0.0.1:8000/docs'
Write-Host "APK:    $ApkPath"
