# Cleanup imediato - SEM confirmacao
Write-Host ""
Write-Host "=== LIMPEZA PROFUNDA NODE.EXE ===" -ForegroundColor Yellow
Write-Host ""

# Contar antes
$nodeBefore = (Get-Process node -ErrorAction SilentlyContinue).Count
$droidBefore = (Get-Process droid -ErrorAction SilentlyContinue).Count

Write-Host "ANTES:" -ForegroundColor Cyan
Write-Host "  node.exe: $nodeBefore processos"
Write-Host "  droid.exe: $droidBefore processos"

# RAM antes
$os = Get-CimInstance Win32_OperatingSystem
$totalRAM = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
$freeRAM = [math]::Round($os.FreePhysicalMemory/1MB, 2)
$usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
$usedPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 1)

Write-Host "  RAM usado: $usedRAM GB ($usedPercent%)"
Write-Host "  RAM livre: $freeRAM GB"
Write-Host ""

# Executar cleanup
Write-Host "Executando cleanup..." -ForegroundColor Yellow
Write-Host ""

Write-Host "[1/2] Matando node.exe..."
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "[2/2] Matando droid.exe..."
Get-Process droid -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Contar depois
$nodeAfter = (Get-Process node -ErrorAction SilentlyContinue).Count
$droidAfter = (Get-Process droid -ErrorAction SilentlyContinue).Count

# RAM depois
$osAfter = Get-CimInstance Win32_OperatingSystem
$freeRAMAfter = [math]::Round($osAfter.FreePhysicalMemory/1MB, 2)
$usedRAMAfter = [math]::Round($totalRAM - $freeRAMAfter, 2)
$usedPercentAfter = [math]::Round(($usedRAMAfter / $totalRAM) * 100, 1)

$ramFreed = [math]::Round($freeRAMAfter - $freeRAM, 2)

Write-Host ""
Write-Host "=== RESULTADO ===" -ForegroundColor Green
Write-Host ""
Write-Host "PROCESSOS ELIMINADOS:" -ForegroundColor Cyan
Write-Host "  node.exe: $nodeBefore -> $nodeAfter (eliminados: $($nodeBefore - $nodeAfter))"
Write-Host "  droid.exe: $droidBefore -> $droidAfter (fechados: $($droidBefore - $droidAfter))"
Write-Host ""
Write-Host "RAM LIBERADA:" -ForegroundColor Cyan
Write-Host "  Antes: $usedRAM GB usado ($usedPercent%)"
Write-Host "  Depois: $usedRAMAfter GB usado ($usedPercentAfter%)"
Write-Host "  Liberado: +$ramFreed GB" -ForegroundColor Green
Write-Host ""
Write-Host "Cleanup concluido!" -ForegroundColor Green
