<#
.SYNOPSIS
Verify the DeepSeek Harness icon fix
#>
$ErrorActionPreference = 'Stop'

Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'DeepSeek Harness Icon Verification' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

# Check 1: Launcher EXE icon
Write-Host '[1] Checking launcher EXE icon...' -ForegroundColor Yellow
$launcher = 'D:\dsh\harness-shell\launcher\DeepSeek Harness Launcher.exe'
if (Test-Path $launcher) {
    try {
        Add-Type -AssemblyName System.Drawing
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($launcher)
        if ($icon) {
            Write-Host "  SUCCESS: Icon found in launcher" -ForegroundColor Green
            Write-Host "  Size: $($icon.Width)x$($icon.Height)"
            $bitmap = $icon.ToBitmap()
            Write-Host "  Bitmap size: $($bitmap.Width)x$($bitmap.Height)"
            $icon.Dispose()
            $bitmap.Dispose()
        } else {
            Write-Host "  FAIL: No icon in launcher" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  Launcher not found: $launcher" -ForegroundColor Red
}

# Check 2: Start Menu shortcut
Write-Host ''
Write-Host '[2] Checking Start Menu shortcut...' -ForegroundColor Yellow
$startMenuLnk = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
if (Test-Path $startMenuLnk) {
    $sh = New-Object -ComObject WScript.Shell
    $lnk = $sh.CreateShortcut($startMenuLnk)
    Write-Host "  Target: $($lnk.TargetPath)"
    Write-Host "  Icon: $($lnk.IconLocation)"
    if ($lnk.TargetPath -like '*Launcher.exe*') {
        Write-Host "  SUCCESS: Shortcut points to launcher" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Shortcut does not point to launcher" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Shortcut not found: $startMenuLnk" -ForegroundColor Red
}

# Check 3: Desktop shortcut
Write-Host ''
Write-Host '[3] Checking desktop shortcut...' -ForegroundColor Yellow
$desktopLnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'DeepSeek Harness.lnk'
if (Test-Path $desktopLnk) {
    $sh = New-Object -ComObject WScript.Shell
    $lnk = $sh.CreateShortcut($desktopLnk)
    Write-Host "  Target: $($lnk.TargetPath)"
    Write-Host "  Icon: $($lnk.IconLocation)"
    if ($lnk.TargetPath -like '*Launcher.exe*') {
        Write-Host "  SUCCESS: Shortcut points to launcher" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Shortcut does not point to launcher" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Shortcut not found: $desktopLnk" -ForegroundColor Red
}

# Check 4: Icon files
Write-Host ''
Write-Host '[4] Icon files available:' -ForegroundColor Yellow
$iconFiles = Get-ChildItem 'D:\dsh\harness-shell\assets' -Filter 'icon*.ico' -ErrorAction SilentlyContinue
if ($iconFiles) {
    foreach ($file in $iconFiles) {
        Write-Host "  $($file.Name) ($($file.Length) bytes)"
    }
} else {
    Write-Host "  No icon files found" -ForegroundColor Red
}

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'Verification complete' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'If the icon is still not showing in Start Menu:' -ForegroundColor Yellow
Write-Host '1. Try logging out and back in' -ForegroundColor White
Write-Host '2. Try restarting Windows Explorer' -ForegroundColor White
Write-Host '3. Check that the launcher EXE has the icon embedded' -ForegroundColor White
Write-Host ''
