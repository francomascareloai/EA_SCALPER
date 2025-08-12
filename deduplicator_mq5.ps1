# Script PowerShell para Deduplicação de Arquivos MQ5
# Versão: 1.0
# Autor: Classificador Trading

param(
    [string]$SourcePath = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL5_Source\All_MQ5",
    [switch]$DryRun = $true
)

# Função para calcular hash MD5
function Get-FileHashMD5 {
    param([string]$FilePath)
    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm MD5
        return $hash.Hash
    }
    catch {
        Write-Warning "Erro ao calcular hash para: $FilePath"
        return $null
    }
}

# Função para determinar prioridade do arquivo
function Get-FilePriority {
    param([System.IO.FileInfo]$File)
    
    $name = $File.Name.ToLower()
    $score = 0
    
    # Penaliza nomes com caracteres especiais
    if ($name -match '[()\[\]{}@#$%^&*+=~`]') { $score += 10 }
    
    # Penaliza nomes muito longos
    if ($name.Length -gt 50) { $score += 5 }
    
    # Penaliza nomes com números no final (versões)
    if ($name -match '\d+\.mq5$') { $score += 3 }
    
    # Penaliza nomes com "copy", "backup", etc.
    if ($name -match '(copy|backup|bak|old|temp|test)') { $score += 15 }
    
    # Prioriza nomes mais limpos
    if ($name -match '^[a-z0-9_\s-]+\.mq5$') { $score -= 5 }
    
    return $score
}

# Função principal
function Start-Deduplication {
    param(
        [string]$Path,
        [bool]$IsDryRun
    )
    
    Write-Host "=== DEDUPLICADOR MQ5 ===" -ForegroundColor Cyan
    Write-Host "Pasta: $Path" -ForegroundColor Yellow
    Write-Host "Modo: $(if($IsDryRun){'SIMULACAO'}else{'EXECUCAO'})" -ForegroundColor $(if($IsDryRun){'Yellow'}else{'Red'})
    Write-Host ""
    
    if (-not (Test-Path $Path)) {
        Write-Error "Pasta não encontrada: $Path"
        return
    }
    
    # Busca todos os arquivos .mq5
    Write-Host "Buscando arquivos .mq5..." -ForegroundColor Green
    $files = Get-ChildItem -Path $Path -Filter "*.mq5" -File
    Write-Host "Encontrados: $($files.Count) arquivos" -ForegroundColor Green
    
    if ($files.Count -eq 0) {
        Write-Host "Nenhum arquivo .mq5 encontrado!" -ForegroundColor Yellow
        return
    }
    
    # Agrupa por hash
    Write-Host "Calculando hashes..." -ForegroundColor Green
    $hashGroups = @{}
    $processedCount = 0
    
    foreach ($file in $files) {
        $processedCount++
        Write-Progress -Activity "Calculando hashes" -Status "$processedCount de $($files.Count)" -PercentComplete (($processedCount / $files.Count) * 100)
        
        $hash = Get-FileHashMD5 -FilePath $file.FullName
        if ($hash) {
            if (-not $hashGroups.ContainsKey($hash)) {
                $hashGroups[$hash] = @()
            }
            $hashGroups[$hash] += $file
        }
    }
    
    Write-Progress -Activity "Calculando hashes" -Completed
    
    # Identifica duplicatas
    $duplicateGroups = $hashGroups.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
    $totalDuplicates = ($duplicateGroups | ForEach-Object { $_.Value.Count - 1 } | Measure-Object -Sum).Sum
    
    Write-Host "" 
    Write-Host "=== RESULTADOS ===" -ForegroundColor Cyan
    Write-Host "Arquivos únicos: $($hashGroups.Count)" -ForegroundColor Green
    Write-Host "Grupos com duplicatas: $($duplicateGroups.Count)" -ForegroundColor Yellow
    Write-Host "Total de duplicatas: $totalDuplicates" -ForegroundColor Red
    Write-Host ""
    
    if ($duplicateGroups.Count -eq 0) {
        Write-Host "Nenhuma duplicata encontrada!" -ForegroundColor Green
        return
    }
    
    # Prepara pasta para duplicatas
    $duplicatesDir = Join-Path (Split-Path $Path -Parent) "Duplicates_Removed"
    if (-not $IsDryRun -and -not (Test-Path $duplicatesDir)) {
        New-Item -ItemType Directory -Path $duplicatesDir -Force | Out-Null
    }
    
    # Processa duplicatas
    $logEntries = @()
    $logEntries += "=== LOG DE DEDUPLICACAO ==="
    $logEntries += "Data: $(Get-Date)"
    $logEntries += "Pasta: $Path"
    $logEntries += "Modo: $(if($IsDryRun){'SIMULACAO'}else{'EXECUCAO'})"
    $logEntries += ""
    
    $totalRemoved = 0
    $groupNumber = 0
    
    foreach ($group in $duplicateGroups) {
        $groupNumber++
        $files = $group.Value
        
        Write-Host "Grupo $groupNumber - Hash: $($group.Key.Substring(0,8))..." -ForegroundColor Cyan
        
        # Ordena por prioridade (menor score = melhor)
        $sortedFiles = $files | Sort-Object { Get-FilePriority $_ }, Name
        $keepFile = $sortedFiles[0]
        $removeFiles = $sortedFiles[1..($sortedFiles.Count-1)]
        
        Write-Host "  MANTER: $($keepFile.Name)" -ForegroundColor Green
        $logEntries += "Grupo $groupNumber (Hash: $($group.Key)):"
        $logEntries += "  MANTER: $($keepFile.Name)"
        $logEntries += "  REMOVER:"
        
        foreach ($fileToRemove in $removeFiles) {
            $fileSize = [math]::Round($fileToRemove.Length / 1KB, 2)
            Write-Host "  REMOVER: $($fileToRemove.Name) ($fileSize KB)" -ForegroundColor Red
            $logEntries += "    - $($fileToRemove.Name) ($fileSize KB)"
            
            if (-not $IsDryRun) {
                # Move arquivo para pasta de duplicatas
                $counter = 1
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileToRemove.Name)
                $extension = [System.IO.Path]::GetExtension($fileToRemove.Name)
                $destPath = Join-Path $duplicatesDir ($baseName + "_dup" + $counter + $extension)
                
                while (Test-Path $destPath) {
                    $counter++
                    $destPath = Join-Path $duplicatesDir ($baseName + "_dup" + $counter + $extension)
                }
                
                try {
                    Move-Item -Path $fileToRemove.FullName -Destination $destPath -Force
                    $totalRemoved++
                }
                catch {
                    Write-Warning "Erro ao mover: $($fileToRemove.Name)"
                }
            }
        }
        
        $logEntries += ""
        Write-Host ""
    }
    
    # Salva log
    $logEntries += "=== RESUMO ==="
    $logEntries += "Total de grupos processados: $groupNumber"
    $logEntries += "Total de arquivos removidos: $(if($IsDryRun){'(SIMULACAO) ' + $totalDuplicates}else{$totalRemoved})"
    $logEntries += "Pasta de duplicatas: $(if(-not $IsDryRun){$duplicatesDir}else{'N/A (simulacao)'})"
    
    $logPath = Join-Path (Split-Path $Path -Parent) "deduplication_log.txt"
    $logEntries | Out-File -FilePath $logPath -Encoding UTF8
    
    Write-Host "=== RESUMO FINAL ===" -ForegroundColor Cyan
    Write-Host "Grupos processados: $groupNumber" -ForegroundColor Yellow
    Write-Host "Arquivos $(if($IsDryRun){'que seriam removidos'}else{'removidos'}): $(if($IsDryRun){$totalDuplicates}else{$totalRemoved})" -ForegroundColor $(if($IsDryRun){'Yellow'}else{'Red'})
    Write-Host "Log salvo em: $logPath" -ForegroundColor Green
    
    if ($IsDryRun) {
        Write-Host "" 
        Write-Host "Para executar a remoção real, execute:" -ForegroundColor Yellow
        Write-Host "powershell -ExecutionPolicy Bypass -File deduplicator_mq5.ps1 -DryRun:`$false" -ForegroundColor White
    }
    else {
        Write-Host "Duplicatas movidas para: $duplicatesDir" -ForegroundColor Green
    }
}

# Executa
Start-Deduplication -Path $SourcePath -IsDryRun $DryRun

Write-Host ""
Write-Host "Processo concluido!" -ForegroundColor Green
Read-Host "Pressione Enter para sair"