# DeepSeek Harness Shell - Setup Script
# Creates Start Menu and Desktop shortcuts

param(
    [string]$InstallDir = "D:\dsh\harness-shell",
    [switch]$DesktopOnly
)

$ErrorActionPreference = "Stop"

function New-Shortcut {
    param(
        [string]$Path,
        [string]$Target,
        [string]$WorkingDirectory,
        [string]$Icon,
        [string]$Arguments = ""
    )
    
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Path)
    $Shortcut.TargetPath = $Target
    $Shortcut.WorkingDirectory = $WorkingDirectory
    $Shortcut.IconLocation = $Icon
    if ($Arguments) {
        $Shortcut.Arguments = $Arguments
    }
    $Shortcut.Save()
    Write-Host "[OK] Created: $Path" -ForegroundColor Green
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "DeepSeek Harness Shell - Shortcut Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$TargetPath = Join-Path $InstallDir "launcher\DeepSeek Harness Launcher.exe"
$WorkingDir = $InstallDir
$IconPath = Join-Path $InstallDir "assets\icon.ico"

if (-not (Test-Path $TargetPath)) {
    Write-Host "[ERROR] Launcher not found: $TargetPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $IconPath)) {
    Write-Host "[WARN] Icon not found: $IconPath" -ForegroundColor Yellow
    $IconPath = "shell32.dll,14"
}

# Desktop shortcut
$DesktopPath = Join-Path ([Environment]::GetFolderPath('Desktop')) "DeepSeek Harness.lnk"
if (Test-Path $DesktopPath) {
    Remove-Item $DesktopPath -Force
}
New-Shortcut -Path $DesktopPath -Target $TargetPath -WorkingDirectory $WorkingDir -Icon $IconPath

if (-not $DesktopOnly) {
    # Start Menu shortcut
    $StartMenuPath = Join-Path ([Environment]::GetFolderPath('Programs')) "DeepSeek Harness.lnk"
    if (Test-Path $StartMenuPath) {
        Remove-Item $StartMenuPath -Force
    }
    New-Shortcut -Path $StartMenuPath -Target $TargetPath -WorkingDirectory $WorkingDir -Icon $IconPath
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
