$ErrorActionPreference='SilentlyContinue'
Write-Host '=== Launch Test ==='
$proc = Get-Process | Where-Object ProcessName -like '*electron*' | Select-Object -First 1
if($proc){
  Write-Host 'Electron is running:'
  Write-Host '  ProcessName:' $proc.ProcessName
  Write-Host '  Id:' $proc.Id
  Write-Host '  MainWindowTitle:' $proc.MainWindowTitle
}else{
  Write-Host 'Electron is NOT currently running'
}

Write-Host ''
Write-Host '=== Testing launcher execution ==='
$launcher = 'D:\dsh\harness-shell\release\DeepSeek Harness.exe'
$args = '"D:\dsh\harness-shell"'
Write-Host 'Launching:' $launcher $args
Start-Process -FilePath $launcher -ArgumentList $args -WorkingDirectory 'D:\dsh\harness-shell'
Start-Sleep -Seconds 5
$proc = Get-Process | Where-Object ProcessName -like '*electron*' | Select-Object -First 1
if($proc){
  Write-Host 'SUCCESS: Electron launched and is running'
  Write-Host '  ProcessName:' $proc.ProcessName
  Write-Host '  Id:' $proc.Id
  Write-Host '  MainWindowTitle:' $proc.MainWindowTitle
}else{
  Write-Host 'FAILED: Electron did not launch'
}
