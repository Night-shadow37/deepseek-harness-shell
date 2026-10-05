function Get-IcoInfo($p){
  try{
    $b=[System.IO.File]::ReadAllBytes($p)
    if($b.Length -lt 6){return 'too small'}
    $r=[BitConverter]::ToUInt16($b,0)
    if($r -ne 0){return 'not ICONDIR'}
    $r=[BitConverter]::ToUInt16($b,2)
    if($r -lt 1){return 'no images'}
    $r=[BitConverter]::ToUInt16($b,4)
    $ents=[Math]::Min($r,10)
    $out=@()
    for($i=0;$i -lt $ents;$i++){
      $off=6+$i*16
      $w=$b[$off]
      $h=$b[$off+1]
      $colors=$b[$off+2]
      $out+=("{0}x{1} colors={2}" -f $w,$h,$colors)
    }
    return ($out -join ', ')
  }catch{
    return $_.Exception.Message
  }
}
$files = @(
  'D:\dsh\harness-shell\assets\icon.ico',
  'D:\dsh\harness-shell\assets\icon-final.ico',
  'D:\dsh\harness-shell\assets\icon-validated.ico',
  'D:\dsh\harness-shell\assets\icon-pillow.ico',
  'D:\dsh\harness-shell\assets\icon-dotnet.ico',
  'D:\dsh\harness-shell\assets\icon-multi.ico'
)
foreach($f in $files){
  Write-Host $f '->' (Get-IcoInfo $f)
}
