$ErrorActionPreference='SilentlyContinue'
Write-Host 'Stopping explorer...'
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$iconCachePaths = @(
  "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*",
  "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache*"
)
foreach($p in $iconCachePaths){
  Remove-Item $p -Force -ErrorAction SilentlyContinue
}
Write-Host 'Icon cache cleared'

Write-Host 'Restarting explorer...'
Start-Process explorer.exe
Write-Host 'Explorer restarted'
