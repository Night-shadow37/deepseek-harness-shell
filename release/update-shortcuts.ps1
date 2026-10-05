$ErrorActionPreference='Stop'
$startMenu = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
$desktop = 'C:\Users\xingg\Desktop\DeepSeek Harness.lnk'
$target = 'D:\dsh\harness-shell\release\DeepSeek Harness.exe'
$args = '"D:\dsh\harness-shell"'
$workdir = 'D:\dsh\harness-shell'

$sh = New-Object -ComObject WScript.Shell

# Start Menu
$s = $sh.CreateShortcut($startMenu)
$s.TargetPath = $target
$s.Arguments = $args
$s.IconLocation = "$target,0"
$s.WorkingDirectory = $workdir
$s.Description = 'DeepSeek Harness'
$s.Save()

# Desktop
$s = $sh.CreateShortcut($desktop)
$s.TargetPath = $target
$s.Arguments = $args
$s.IconLocation = "$target,0"
$s.WorkingDirectory = $workdir
$s.Description = 'DeepSeek Harness'
$s.Save()

Write-Host 'Shortcuts updated to use icon-embedded launcher EXE'
