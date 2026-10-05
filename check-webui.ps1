try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8082' -Method HEAD -TimeoutSec 3 -UseBasicParsing
    Write-Host "Status: $($r.StatusCode)"
} catch {
    Write-Host "Not running or not reachable"
}
