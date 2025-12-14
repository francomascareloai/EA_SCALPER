# Kill firecrawl processes
Write-Host "Matando processos firecrawl..."

$procs = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*firecrawl*' }

if ($procs.Count -eq 0) {
    Write-Host "Nenhum processo firecrawl encontrado."
    exit
}

Write-Host "Encontrados: $($procs.Count) processos"

foreach ($p in $procs) {
    Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 1

$after = (Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*firecrawl*' }).Count
Write-Host "Restantes: $after processos"
Write-Host "Concluido!"
