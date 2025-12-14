# Kill calculator-mcp orphaned processes
Write-Host "Matando processos calculator-mcp..."

$procs = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*calculator-mcp*' }

if ($procs.Count -eq 0) {
    Write-Host "Nenhum processo encontrado."
    exit
}

Write-Host "Encontrados: $($procs.Count) processos"

foreach ($p in $procs) {
    Stop-Process -Id $p.ProcessId -Force
}

Start-Sleep -Seconds 2

$after = (Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*calculator-mcp*' }).Count
Write-Host "Restantes: $after processos"
