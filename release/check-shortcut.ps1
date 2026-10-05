$s = New-Object -ComObject WScript.Shell
$lnk = $s.CreateShortcut('C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk')
Write-Host "Target: $($lnk.TargetPath)"
Write-Host "Icon: $($lnk.IconLocation)"
Write-Host "WorkingDir: $($lnk.WorkingDirectory)"
