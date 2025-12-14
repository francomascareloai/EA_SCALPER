# Script de Classificacao Automatica MQL5
# Classificador_Trading v1.0 - MQL5 Edition

$sourceDir = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL5_Source\All_MQ5"
$baseDir = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL5_Source"
$logFile = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\classification_mql5_log.txt"

# Limpar log anterior
if (Test-Path $logFile) { Remove-Item $logFile }

# Funcao para detectar tipo de arquivo MQL5
function Get-MQL5FileType {
    param([string]$fileName, [string]$content)
    
    $fileName = $fileName.ToLower()
    
    # Padroes para EAs
    if ($content -match "OnTick|OnTradeTransaction|trade\.|CTrade" -or 
        $fileName -match "ea|expert|robot|bot|advisor") {
        
        # Sub-classificacao de EAs
        if ($content -match "FTMO|ftmo|risk.*management|drawdown.*control|daily.*loss" -or
            $fileName -match "ftmo|funded|prop") {
            return "EA_FTMO_READY"
        }
        elseif ($content -match "scalp|M1|M5|quick|fast|rapid" -or
                $fileName -match "scalp|quick|fast|rapid") {
            return "EA_ADVANCED_SCALPING"
        }
        elseif ($content -match "multi.*symbol|portfolio|basket|correlation" -or
                $fileName -match "multi|portfolio|basket") {
            return "EA_MULTI_SYMBOL"
        }
        else {
            return "EA_OTHERS"
        }
    }
    
    # Padroes para Indicadores
    elseif ($content -match "OnCalculate|SetIndexBuffer|PlotIndexSetInteger" -or
            $fileName -match "indicator|ind|oscillator|signal") {
        
        # Sub-classificacao de Indicadores
        if ($content -match "order.*block|liquidity|institutional|smc|ict|fair.*value.*gap" -or
            $fileName -match "order.*block|liquidity|smc|ict|fvg") {
            return "IND_ORDER_BLOCKS"
        }
        elseif ($content -match "volume.*flow|money.*flow|accumulation|distribution" -or
                $fileName -match "volume.*flow|money.*flow|obv") {
            return "IND_VOLUME_FLOW"
        }
        elseif ($content -match "market.*structure|structure|swing|pivot" -or
                $fileName -match "structure|swing|pivot") {
            return "IND_MARKET_STRUCTURE"
        }
        else {
            return "IND_CUSTOM"
        }
    }
    
    # Padroes para Scripts
    elseif ($content -match "OnStart" -or
            $fileName -match "script|tool|utility|helper") {
        
        if ($content -match "risk|lot.*size|position.*size|money.*management" -or
            $fileName -match "risk|lot|position|money") {
            return "SCR_RISK_TOOLS"
        }
        else {
            return "SCR_ANALYSIS_TOOLS"
        }
    }
    
    return "UNKNOWN"
}

# Funcao para gerar nome padronizado MQL5
function Get-StandardizedName {
    param([string]$originalName, [string]$type)
    
    # Remover extensao e caracteres especiais
    $cleanName = [System.IO.Path]::GetFileNameWithoutExtension($originalName)
    $cleanName = $cleanName -replace '[^a-zA-Z0-9_]', '_'
    $cleanName = $cleanName -replace '_+', '_'
    $cleanName = $cleanName.Trim('_')
    
    # Detectar versao
    $version = "v1.0"
    if ($cleanName -match "v?([0-9]+\.?[0-9]*)") {
        $version = "v$($matches[1])"
    }
    
    # Detectar mercado
    $market = "MULTI"
    if ($cleanName -match "(XAUUSD|GOLD|EUR|USD|GBP|JPY|AUD|CAD|CHF|NZD)") {
        $market = $matches[1].ToUpper()
    }
    
    # Gerar prefixo baseado no tipo
    $prefix = switch ($type) {
        "EA_FTMO_READY" { "EA" }
        "EA_ADVANCED_SCALPING" { "EA" }
        "EA_MULTI_SYMBOL" { "EA" }
        "EA_OTHERS" { "EA" }
        "IND_ORDER_BLOCKS" { "IND" }
        "IND_VOLUME_FLOW" { "IND" }
        "IND_MARKET_STRUCTURE" { "IND" }
        "IND_CUSTOM" { "IND" }
        "SCR_RISK_TOOLS" { "SCR" }
        "SCR_ANALYSIS_TOOLS" { "SCR" }
        default { "UNK" }
    }
    
    return "${prefix}_${cleanName}_${version}_${market}.mq5"
}

# Funcao para determinar pasta destino
function Get-DestinationFolder {
    param([string]$type)
    
    switch ($type) {
        "EA_FTMO_READY" { return "EAs\FTMO_Ready" }
        "EA_ADVANCED_SCALPING" { return "EAs\Advanced_Scalping" }
        "EA_MULTI_SYMBOL" { return "EAs\Multi_Symbol" }
        "EA_OTHERS" { return "EAs\Others" }
        "IND_ORDER_BLOCKS" { return "Indicators\Order_Blocks" }
        "IND_VOLUME_FLOW" { return "Indicators\Volume_Flow" }
        "IND_MARKET_STRUCTURE" { return "Indicators\Market_Structure" }
        "IND_CUSTOM" { return "Indicators\Custom" }
        "SCR_RISK_TOOLS" { return "Scripts\Risk_Tools" }
        "SCR_ANALYSIS_TOOLS" { return "Scripts\Analysis_Tools" }
        default { return "Misc" }
    }
}

# Inicializar contadores
$processedCount = 0
$successCount = 0
$skipCount = 0

Write-Host "=== INICIANDO CLASSIFICACAO MQL5 ===" -ForegroundColor Cyan
Add-Content $logFile "=== CLASSIFICACAO MQL5 INICIADA EM $(Get-Date) ==="

# Processar todos os arquivos
$allFiles = Get-ChildItem $sourceDir -File | Where-Object { $_.Extension -eq ".mq5" -or $_.Extension -eq ".txt" -or $_.Extension -eq ".rar" -or $_.Extension -eq ".zip" }

foreach ($file in $allFiles) {
    $processedCount++
    Write-Progress -Activity "Classificando MQL5" -Status "Processando $($file.Name)" -PercentComplete (($processedCount / $allFiles.Count) * 100)
    
    try {
        # Ler conteudo do arquivo (se possivel)
        $content = ""
        if ($file.Extension -eq ".mq5" -or $file.Extension -eq ".txt") {
            try {
                $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                if ($null -eq $content) { $content = "" }
            }
            catch {
                $content = ""
            }
        }
        
        # Detectar tipo
        $fileType = Get-MQL5FileType -fileName $file.Name -content $content
        
        Add-Content $logFile "Processando: $($file.Name)"
        
        if ($fileType -eq "UNKNOWN") {
            Add-Content $logFile "  SKIP: Tipo nao identificado"
            $skipCount++
            continue
        }
        
        # Gerar nome padronizado
        $newName = Get-StandardizedName -originalName $file.Name -type $fileType
        
        # Determinar pasta destino
        $destFolder = Get-DestinationFolder -type $fileType
        $destPath = Join-Path $baseDir $destFolder
        
        # Criar pasta se nao existir
        if (-not (Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }
        
        # Copiar arquivo
        $destFile = Join-Path $destPath $newName
        
        # Resolver conflitos de nome
        $counter = 1
        $originalDestFile = $destFile
        while (Test-Path $destFile) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($originalDestFile)
            $extension = [System.IO.Path]::GetExtension($originalDestFile)
            $destFile = Join-Path $destPath "${baseName}_${counter}${extension}"
            $counter++
        }
        
        Copy-Item $file.FullName $destFile -Force
        
        Add-Content $logFile "  OK: $fileType -> $newName"
        $successCount++
        
    }
    catch {
        Add-Content $logFile "  ERRO: $($_.Exception.Message)"
    }
}

# Relatorio final
Write-Host ""
Write-Host "=== CLASSIFICACAO MQL5 CONCLUIDA ===" -ForegroundColor Green
Write-Host "Processados: $processedCount" -ForegroundColor White
Write-Host "Classificados: $successCount" -ForegroundColor Green
Write-Host "Ignorados: $skipCount" -ForegroundColor Yellow
Write-Host "Taxa de sucesso: $([math]::Round(($successCount/$processedCount)*100, 2))%" -ForegroundColor Cyan
Write-Host "Log salvo em: $logFile" -ForegroundColor Gray

Add-Content $logFile ""
Add-Content $logFile "=== RELATORIO FINAL ==="
Add-Content $logFile "Processados: $processedCount"
Add-Content $logFile "Classificados: $successCount"
Add-Content $logFile "Ignorados: $skipCount"
Add-Content $logFile "Taxa de sucesso: $([math]::Round(($successCount/$processedCount)*100, 2))%"
Add-Content $logFile "Classificacao concluida em: $(Get-Date)"