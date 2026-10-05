Add-Type -AssemblyName System.Drawing
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon('D:\dsh\harness-shell\launcher\DeepSeek Harness Launcher.exe')
Write-Host "Icon size: $($icon.Width)x$($icon.Height)"
$icon.Dispose()
