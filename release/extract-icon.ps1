Add-Type -AssemblyName System.Drawing
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon('D:\dsh\harness-shell\launcher\DeepSeek Harness Launcher.exe')
$bitmap = $icon.ToBitmap()
$bitmap.Save('D:\dsh\harness-shell\release\extracted_icon.png', [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Icon extracted to extracted_icon.png"
$icon.Dispose()
$bitmap.Dispose()
