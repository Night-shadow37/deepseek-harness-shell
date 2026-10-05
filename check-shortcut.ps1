$lnk = New-Object -ComObject WScript.Shell
$shortcut = $lnk.CreateShortcut('C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk')
Write-Host "TargetPath: $($shortcut.TargetPath)"
Write-Host "IconLocation: $($shortcut.IconLocation)"
Write-Host "WorkingDirectory: $($shortcut.WorkingDirectory)"
Write-Host "Arguments: $($shortcut.Arguments)"
