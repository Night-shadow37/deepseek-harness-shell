@echo off
echo Creating Start Menu shortcut...

powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $ShortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\DeepSeek Harness.lnk'; $Shortcut = $WshShell.CreateShortcut($ShortcutPath); $Shortcut.TargetPath = 'D:\dsh\harness-shell\release\启动 DeepSeek Harness.bat'; $Shortcut.WorkingDirectory = 'D:\dsh\harness-shell'; $Shortcut.IconLocation = 'shell32.dll,14'; $Shortcut.Save(); Write-Host 'Shortcut created successfully'"

echo Done!
pause
