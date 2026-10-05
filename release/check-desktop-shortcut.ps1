$s = New-Object -ComObject WScript.Shell
$lnk = $s.CreateShortcut('C:\Users\xingg\Desktop\DeepSeek Harness.lnk')
Write-Host "Target: $($lnk.TargetPath)"
Write-Host "Icon: $($lnk.IconLocation)"
Write-Host "WorkingDir: $($lnk.WorkingDirectory)"
