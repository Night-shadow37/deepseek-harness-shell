$ErrorActionPreference='Stop'
$startMenu = 'C:\Users\xingg\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepSeek Harness.lnk'
$desktop = 'C:\Users\xingg\Desktop\DeepSeek Harness.lnk'
$target = 'C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe'
$args = '"D:\dsh\harness-shell"'
$icon = 'D:\dsh\harness-shell\assets\icon-pillow-new.ico,0'
$workdir = 'D:\dsh\harness-shell'

$sh = New-Object -ComObject WScript.Shell

# Start Menu
$s = $sh.CreateShortcut($startMenu)
$s.TargetPath = $target
$s.Arguments = $args
$s.IconLocation = $icon
$s.WorkingDirectory = $workdir
$s.Description = 'DeepSeek Harness'
$s.Save()

# Desktop
$s = $sh.CreateShortcut($desktop)
$s.TargetPath = $target
$s.Arguments = $args
$s.IconLocation = $icon
$s.WorkingDirectory = $workdir
$s.Description = 'DeepSeek Harness'
$s.Save()

Write-Host 'Shortcuts updated with new Pillow-generated ICO and direct electron.exe target'
