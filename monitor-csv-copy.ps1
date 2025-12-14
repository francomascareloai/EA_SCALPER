# Monitor CSV Master Copy Progress
# Run: .\monitor-csv-copy.ps1

$destFile = "/root/projetos/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv"
$targetSizeGB = 29

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  MONITOR: Master CSV Copy Progress" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

while ($true) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    # Check if process is still running
    $processCheck = wsl bash -c "ps aux | grep -E 'cp.*CSV' | grep -v grep" 2>$null
    
    if ($processCheck) {
        # Get current file size
        $sizeOutput = wsl bash -c "ls -lh '$destFile' 2>/dev/null | awk '{print `$5}'" 2>$null
        
        if ($sizeOutput) {
            $sizeOutputClean = ($sizeOutput -split "`n")[0].Trim()
            Write-Host "[$timestamp] Copiando... Tamanho atual: $sizeOutputClean / ${targetSizeGB}GB" -ForegroundColor Yellow
        } else {
            Write-Host "[$timestamp] Processo rodando, aguardando arquivo..." -ForegroundColor Gray
        }
    } else {
        # Process finished - check final status
        $finalSize = wsl bash -c "ls -lh '$destFile' 2>/dev/null | awk '{print `$5}'" 2>$null
        
        if ($finalSize) {
            $finalSizeClean = ($finalSize -split "`n")[0].Trim()
            Write-Host "`n[$timestamp] ✅ COPIA CONCLUIDA! Tamanho final: $finalSizeClean" -ForegroundColor Green
            
            # Show log summary
            Write-Host "`nLog completo:" -ForegroundColor Cyan
            wsl cat /tmp/master-csv-copy.log 2>$null
        } else {
            Write-Host "`n[$timestamp] ❌ Processo terminou mas arquivo nao encontrado!" -ForegroundColor Red
        }
        
        break
    }
    
    Start-Sleep -Seconds 10
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
