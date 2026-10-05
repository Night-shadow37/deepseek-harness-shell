# Fix Start Menu and Desktop shortcuts to use the launcher EXE with embedded icon

$ErrorActionPreference = 'Stop'

$launcherPath = 'D:\dsh\harness-shell\launcher\DeepSeek Harness Launcher.exe'
$startMenuPath = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
$desktopPath = 'C:\Users\xingg\Desktop\DeepSeek Harness.lnk'

# Verify launcher exists
if (-not (Test-Path $launcherPath)) {
    Write-Host "ERROR: Launcher not found: $launcherPath" -ForegroundColor Red
    exit 1
}

Write-Host "Launcher found: $launcherPath"
Write-Host "Launcher size: $((Get-Item $launcherPath).Length) bytes"

# Verify launcher has valid icon
try {
    Add-Type -AssemblyName System.Drawing
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($launcherPath)
    Write-Host "Launcher icon size: $($icon.Width)x$($icon.Height)" -ForegroundColor Green
    $icon.Dispose()
} catch {
    Write-Host "WARNING: Could not extract icon from launcher: $_" -ForegroundColor Yellow
}

# Create/update shortcuts
$sh = New-Object -ComObject WScript.Shell

# Start Menu shortcut
if (Test-Path $startMenuPath) {
    Remove-Item $startMenuPath -Force
}
$s = $sh.CreateShortcut($startMenuPath)
$s.TargetPath = $launcherPath
$s.Arguments = '"D:\dsh\harness-shell"'
$s.WorkingDirectory = 'D:\dsh\harness-shell'
$s.IconLocation = "$launcherPath,0"
$s.Description = 'DeepSeek Harness'
$s.Save()
Write-Host "Created Start Menu shortcut: $startMenuPath" -ForegroundColor Green

# Desktop shortcut
if (Test-Path $desktopPath) {
    Remove-Item $desktopPath -Force
}
$s = $sh.CreateShortcut($desktopPath)
$s.TargetPath = $launcherPath
$s.Arguments = '"D:\dsh\harness-shell"'
$s.WorkingDirectory = 'D:\dsh\harness-shell'
$s.IconLocation = "$launcherPath,0"
$s.Description = 'DeepSeek Harness'
$s.Save()
Write-Host "Created Desktop shortcut: $desktopPath" -ForegroundColor Green

# Verify shortcuts
$s = $sh.CreateShortcut($startMenuPath)
Write-Host "`nStart Menu shortcut verification:" -ForegroundColor Cyan
Write-Host "  Target: $($s.TargetPath)"
Write-Host "  Icon: $($s.IconLocation)"
Write-Host "  WorkingDir: $($s.WorkingDirectory)"

$s = $sh.CreateShortcut($desktopPath)
Write-Host "`nDesktop shortcut verification:" -ForegroundColor Cyan
Write-Host "  Target: $($s.TargetPath)"
Write-Host "  Icon: $($s.IconLocation)"
Write-Host "  WorkingDir: $($s.WorkingDirectory)"

# Clear icon cache
Write-Host "`nClearing icon cache..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer.exe
Write-Host "Icon cache cleared. Explorer restarted." -ForegroundColor Green

Write-Host "`nShortcuts updated successfully!" -ForegroundColor Green
Write-Host "Please check the Start Menu and Desktop for the DeepSeek Harness icon." -ForegroundColor Cyan
Write-Host "If the icon is not visible immediately, try logging out and back in, or restarting Windows." -ForegroundColor Yellow
