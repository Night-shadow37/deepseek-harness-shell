$ErrorActionPreference='SilentlyContinue'
$startMenu = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
$desktop = 'C:\Users\xingg\Desktop\DeepSeek Harness.lnk'
$sh = New-Object -ComObject WScript.Shell
Write-Host '=== Start Menu ==='
$s = $sh.CreateShortcut($startMenu)
Write-Host 'FullName:' $s.FullName
Write-Host 'TargetPath:' $s.TargetPath
Write-Host 'IconLocation:' $s.IconLocation
Write-Host 'WorkingDirectory:' $s.WorkingDirectory
Write-Host 'Arguments:' $s.Arguments
Write-Host 'Description:' $s.Description
Write-Host 'Hotkey:' $s.Hotkey
Write-Host 'WindowStyle:' $s.WindowStyle

Write-Host ''
Write-Host '=== Desktop ==='
$s = $sh.CreateShortcut($desktop)
Write-Host 'FullName:' $s.FullName
Write-Host 'TargetPath:' $s.TargetPath
Write-Host 'IconLocation:' $s.IconLocation
Write-Host 'WorkingDirectory:' $s.WorkingDirectory
Write-Host 'Arguments:' $s.Arguments
Write-Host 'Description:' $s.Description
Write-Host 'Hotkey:' $s.Hotkey
Write-Host 'WindowStyle:' $s.WindowStyle
