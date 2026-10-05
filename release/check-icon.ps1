Add-Type -AssemblyName System.Drawing
$ico = [System.Drawing.Icon]::ExtractAssociatedIcon('D:\dsh\harness-shell\assets\icon.ico')
Write-Host "Icon size: $($ico.Width)x$($ico.Height)"
$ico.Dispose()

$bmp = [System.Drawing.Image]::FromFile('D:\dsh\harness-shell\assets\icon.png')
Write-Host "PNG size: $($bmp.Width)x$($bmp.Height)"
$bmp.Dispose()
