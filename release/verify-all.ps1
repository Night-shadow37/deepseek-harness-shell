$ErrorActionPreference='SilentlyContinue'
Write-Host '=== Verification Report ==='
Write-Host ''

# 1. Check shortcuts
$startMenu = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
$desktop = 'C:\Users\xingg\Desktop\DeepSeek Harness.lnk'
$sh = New-Object -ComObject WScript.Shell

Write-Host '--- Start Menu Shortcut ---'
$s = $sh.CreateShortcut($startMenu)
Write-Host 'Exists:' (Test-Path $startMenu)
Write-Host 'Target:' $s.TargetPath
Write-Host 'Icon:' $s.IconLocation
Write-Host 'WorkDir:' $s.WorkingDirectory
Write-Host 'Args:' $s.Arguments

Write-Host ''
Write-Host '--- Desktop Shortcut ---'
$s = $sh.CreateShortcut($desktop)
Write-Host 'Exists:' (Test-Path $desktop)
Write-Host 'Target:' $s.TargetPath
Write-Host 'Icon:' $s.IconLocation
Write-Host 'WorkDir:' $s.WorkingDirectory
Write-Host 'Args:' $s.Arguments

Write-Host ''
Write-Host '--- Launcher EXE ---'
$exe = 'D:\dsh\harness-shell\release\DeepSeek Harness.exe'
Write-Host 'Exists:' (Test-Path $exe)
Write-Host 'Size:' (Get-Item $exe).Length

Write-Host ''
Write-Host '--- Icon Cache Status ---'
$cacheFiles = Get-ChildItem $env:LOCALAPPDATA\Microsoft\Windows\Explorer -Filter 'iconcache*' -ErrorAction SilentlyContinue
Write-Host 'Icon cache files:' $cacheFiles.Count
$empty = ($cacheFiles | Where-Object Length -eq 0).Count
Write-Host 'Empty cache files:' $empty

Write-Host ''
Write-Host '=== Verification Complete ==='
