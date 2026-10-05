# DeepSeek Harness - Start Menu Icon Fix Verification
# This script verifies that the AppUserModelID fix is properly applied

$ErrorActionPreference = 'Stop'

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "DSH Start Menu Icon Fix - Verification" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check shortcut exists
$lnkPath = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
if (-not (Test-Path $lnkPath)) {
    Write-Host "[FAIL] Shortcut not found: $lnkPath" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Shortcut exists: $lnkPath" -ForegroundColor Green

# 2. Check shortcut properties
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($lnkPath)
Write-Host "[OK] Target: $($shortcut.TargetPath)" -ForegroundColor Green
Write-Host "[OK] Icon: $($shortcut.IconLocation)" -ForegroundColor Green
Write-Host "[OK] WorkingDir: $($shortcut.WorkingDirectory)" -ForegroundColor Green
Write-Host "[OK] Args: $($shortcut.Arguments)" -ForegroundColor Green

# 3. Verify AppUserModelID using Python
Write-Host ""
Write-Host "Verifying AppUserModelID property..." -ForegroundColor Cyan
$result = cmd /c "python D:\dsh\harness-shell\verify-appid.py"
Write-Host $result

# 4. Check main.js has AppUserModelID
Write-Host ""
Write-Host "Checking main.js for AppUserModelID..." -ForegroundColor Cyan
$mainJs = Get-Content 'D:\dsh\harness-shell\main.js' -Raw
if ($mainJs -match "setUserModelId\('com\.deepseek\.harness'\)") {
    Write-Host "[OK] main.js contains app.setUserModelId('com.deepseek.harness')" -ForegroundColor Green
} else {
    Write-Host "[FAIL] main.js does not contain AppUserModelID setting" -ForegroundColor Red
}

# 5. Check icon file exists
Write-Host ""
Write-Host "Checking icon file..." -ForegroundColor Cyan
$iconPath = 'D:\dsh\harness-shell\assets\icon.ico'
if (Test-Path $iconPath) {
    $iconSize = (Get-Item $iconPath).Length
    Write-Host "[OK] Icon exists: $iconPath ($iconSize bytes)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Icon not found: $iconPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Verification Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To test the fix:" -ForegroundColor Yellow
Write-Host "1. Close any running DSH instances" -ForegroundColor Yellow
Write-Host "2. Launch DSH from the Start Menu shortcut" -ForegroundColor Yellow
Write-Host "3. Check if the icon appears correctly in Start Menu" -ForegroundColor Yellow
Write-Host "4. If not, try: ie4uinit.exe -show && taskkill /f /im explorer.exe && start explorer.exe" -ForegroundColor Yellow
