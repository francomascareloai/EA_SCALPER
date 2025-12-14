# Script para matar APENAS processos calculator-mcp órfãos
# Seguro - não afeta outros MCPs ou droids

Write-Host "=== MATANDO PROCESSOS CALCULATOR-MCP ÓRFÃOS ===" -ForegroundColor Yellow
Write-Host ""

# Get calculator processes
$calcProcs = Get-CimInstance Win32_Process | Where-Object { 
    $_.CommandLine -like '*calculator-mcp*' 
}

if ($calcProcs.Count -eq 0) {
    Write-Host "Nenhum processo calculator-mcp encontrado!" -ForegroundColor Green
    exit
}

Write-Host "Encontrados $($calcProcs.Count) processos calculator-mcp:" -ForegroundColor Cyan
$calcProcs | ForEach-Object {
    $created = [Management.ManagementDateTimeConverter]::ToDateTime($_.CreationDate)
    Write-Host "  PID $($_.ProcessId) - Criado: $created"
}

Write-Host ""
$confirm = Read-Host "Matar todos esses processos? (S/N)"

if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Cancelado pelo usuário." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Matando processos calculator-mcp..." -ForegroundColor Yellow

$killed = 0
foreach ($proc in $calcProcs) {
    try {
        Stop-Process -Id $proc.ProcessId -Force -ErrorAction Stop
        $killed++
    } catch {
        Write-Host "Erro ao matar PID $($proc.ProcessId): $_" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "=== RESULTADO ===" -ForegroundColor Green
Write-Host "Processos calculator-mcp eliminados: $killed" -ForegroundColor Green
Write-Host ""

# Verify cleanup
$remaining = (Get-CimInstance Win32_Process | Where-Object { 
    $_.CommandLine -like '*calculator-mcp*' 
}).Count

if ($remaining -eq 0) {
    Write-Host "Cleanup completo! Nenhum calculator-mcp rodando." -ForegroundColor Green
} else {
    Write-Host "Ainda restam $remaining processos calculator-mcp" -ForegroundColor Yellow
}
