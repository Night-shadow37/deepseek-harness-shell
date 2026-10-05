$ErrorActionPreference='Stop'
$launcher = 'D:\dsh\harness-shell\release\DeepSeek Harness.exe'
$icon = 'D:\dsh\harness-shell\assets\icon-pillow-new.ico'
$rcedit = 'D:\open-design\node_modules\.pnpm\electron-winstaller@5.4.0\node_modules\electron-winstaller\vendor\rcedit.exe'

Write-Host "Setting icon on $launcher ..."
& $rcedit $launcher --set-icon $icon
if($LASTEXITCODE -ne 0){ throw "rcedit failed" }

Write-Host 'Icon set successfully'
