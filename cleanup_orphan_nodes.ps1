# Script de limpeza PROFUNDA de processos node.exe órfãos
# Mata TODOS os node.exe (inclusive droids ativos)
# Use ao final do dia ou quando quiser cleanup completo

Write-Host ""
Write-Host "=== LIMPEZA PROFUNDA NODE.EXE ===" -ForegroundColor Yellow
Write-Host ""

# Contar processos antes
$nodeBefore = (Get-Process node -ErrorAction SilentlyContinue).Count
$droidBefore = (Get-Process droid -ErrorAction SilentlyContinue).Count

Write-Host "Estado ATUAL:" -ForegroundColor Cyan
Write-Host "  node.exe: $nodeBefore processos"
Write-Host "  droid.exe: $droidBefore processos"
Write-Host ""

# Calcular RAM atual
$os = Get-CimInstance Win32_OperatingSystem
$totalRAM = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
$freeRAM = [math]::Round($os.FreePhysicalMemory/1MB, 2)
$usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
$usedPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 1)

Write-Host "RAM ATUAL:" -ForegroundColor Cyan
Write-Host "  Total: $totalRAM GB"
Write-Host "  Usado: $usedRAM GB ($usedPercent%)"
Write-Host "  Livre: $freeRAM GB"
Write-Host ""

Write-Host "AVISO: Este script vai:" -ForegroundColor Red
Write-Host "  1. Fechar TODOS os 6 droids ativos" -ForegroundColor Red
Write-Host "  2. Fechar TODOS os MCPs (node.exe)" -ForegroundColor Red
Write-Host "  3. Limpar processos órfãos acumulados" -ForegroundColor Red
Write-Host ""
Write-Host "Mantem: VSCode, Chrome, outros apps" -ForegroundColor Green
Write-Host ""
Write-Host "Voce vai precisar reabrir os droids depois!" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Continuar com cleanup? (S/N)"

if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host ""
    Write-Host "Cancelado pelo usuario." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Executando cleanup em 3 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Matar todos os node.exe
Write-Host ""
Write-Host "[1/2] Matando processos node.exe..." -ForegroundColor Cyan
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Matar todos os droid.exe (para garantir que nenhum tente recriar MCPs)
Write-Host "[2/2] Matando processos droid.exe..." -ForegroundColor Cyan
Get-Process droid -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Contar depois
$nodeAfter = (Get-Process node -ErrorAction SilentlyContinue).Count
$droidAfter = (Get-Process droid -ErrorAction SilentlyContinue).Count

# Calcular RAM depois
$osAfter = Get-CimInstance Win32_OperatingSystem
$freeRAMAfter = [math]::Round($osAfter.FreePhysicalMemory/1MB, 2)
$usedRAMAfter = [math]::Round($totalRAM - $freeRAMAfter, 2)
$usedPercentAfter = [math]::Round(($usedRAMAfter / $totalRAM) * 100, 1)

$ramFreed = [math]::Round($freeRAMAfter - $freeRAM, 2)

Write-Host ""
Write-Host "=== RESULTADO ===" -ForegroundColor Green
Write-Host ""
Write-Host "PROCESSOS:" -ForegroundColor Cyan
Write-Host "  node.exe: $nodeBefore -> $nodeAfter (eliminados: $($nodeBefore - $nodeAfter))"
Write-Host "  droid.exe: $droidBefore -> $droidAfter (fechados: $($droidBefore - $droidAfter))"
Write-Host ""
Write-Host "RAM:" -ForegroundColor Cyan
Write-Host "  Antes: $usedRAM GB usado ($usedPercent%)"
Write-Host "  Depois: $usedRAMAfter GB usado ($usedPercentAfter%)"
Write-Host "  Liberado: +$ramFreed GB RAM livre" -ForegroundColor Green
Write-Host ""
Write-Host "Cleanup concluido!" -ForegroundColor Green
Write-Host "Agora reabra seus droids/terminais conforme necessario." -ForegroundColor Yellow
Write-Host ""
