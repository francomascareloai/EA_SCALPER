# Script de Classificação em Lote - MQL4 Files
# Classificador_Trading - Automatização

$sourceDir = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source\All_MQ4"
$logFile = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\classification_log.txt"

# Inicializar log
"=== CLASSIFICAÇÃO AUTOMÁTICA MQL4 - $(Get-Date) ===" | Out-File $logFile

# Contadores
$totalFiles = 0
$processedFiles = 0
$skippedFiles = 0

# Função para detectar tipo de arquivo
function Get-FileType {
    param($filePath)
    
    if (!(Test-Path $filePath)) { return "UNKNOWN" }
    
    $content = Get-Content $filePath -First 100 -ErrorAction SilentlyContinue
    if (!$content) { return "UNKNOWN" }
    
    $contentStr = $content -join " "
    
    # Detectar EA
    if ($contentStr -match "OnTick\(\)" -and ($contentStr -match "OrderSend" -or $contentStr -match "trade\.Buy" -or $contentStr -match "trade\.Sell")) {
        # Detectar estratégia
        if ($contentStr -match "scalp|M1|M5" -and !($contentStr -match "grid|martingale")) {
            return "EA_SCALPING"
        }
        elseif ($contentStr -match "grid|martingale|recovery") {
            return "EA_GRID_MARTINGALE"
        }
        elseif ($contentStr -match "trend|momentum|MA") {
            return "EA_TREND_FOLLOWING"
        }
        else {
            return "EA_MISC"
        }
    }
    # Detectar Indicator
    elseif ($contentStr -match "OnCalculate\(\)|SetIndexBuffer") {
        if ($contentStr -match "order_block|liquidity|institutional") {
            return "IND_SMC_ICT"
        }
        elseif ($contentStr -match "volume|OBV|flow") {
            return "IND_VOLUME"
        }
        elseif ($contentStr -match "trend|momentum") {
            return "IND_TREND"
        }
        else {
            return "IND_CUSTOM"
        }
    }
    # Detectar Script
    elseif ($contentStr -match "OnStart\(\)") {
        if ($contentStr -match "risk|lot|money") {
            return "SCR_UTILITIES"
        }
        else {
            return "SCR_ANALYSIS"
        }
    }
    
    return "UNKNOWN"
}

# Função para gerar nome padronizado
function Get-StandardName {
    param($originalName, $fileType)
    
    $cleanName = $originalName -replace "[^a-zA-Z0-9_]", "_"
    $cleanName = $cleanName -replace "_{2,}", "_"
    $cleanName = $cleanName.Trim('_')
    
    switch ($fileType) {
        "EA_SCALPING" { return "EA_${cleanName}_v1.0_MULTI.mq4" }
        "EA_GRID_MARTINGALE" { return "EA_${cleanName}_v1.0_MULTI.mq4" }
        "EA_TREND_FOLLOWING" { return "EA_${cleanName}_v1.0_MULTI.mq4" }
        "EA_MISC" { return "EA_${cleanName}_v1.0_MULTI.mq4" }
        "IND_SMC_ICT" { return "IND_${cleanName}_v1.0_MULTI.mq4" }
        "IND_VOLUME" { return "IND_${cleanName}_v1.0_MULTI.mq4" }
        "IND_TREND" { return "IND_${cleanName}_v1.0_MULTI.mq4" }
        "IND_CUSTOM" { return "IND_${cleanName}_v1.0_MULTI.mq4" }
        "SCR_UTILITIES" { return "SCR_${cleanName}_v1.0_MULTI.mq4" }
        "SCR_ANALYSIS" { return "SCR_${cleanName}_v1.0_MULTI.mq4" }
        default { return "MISC_${cleanName}_v1.0_MULTI.mq4" }
    }
}

# Função para obter pasta de destino
function Get-DestinationFolder {
    param($fileType)
    
    $baseDir = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source"
    
    switch ($fileType) {
        "EA_SCALPING" { return "$baseDir\EAs\Scalping" }
        "EA_GRID_MARTINGALE" { return "$baseDir\EAs\Grid_Martingale" }
        "EA_TREND_FOLLOWING" { return "$baseDir\EAs\Trend_Following" }
        "EA_MISC" { return "$baseDir\EAs\Misc" }
        "IND_SMC_ICT" { return "$baseDir\Indicators\SMC_ICT" }
        "IND_VOLUME" { return "$baseDir\Indicators\Volume" }
        "IND_TREND" { return "$baseDir\Indicators\Trend" }
        "IND_CUSTOM" { return "$baseDir\Indicators\Custom" }
        "SCR_UTILITIES" { return "$baseDir\Scripts\Utilities" }
        "SCR_ANALYSIS" { return "$baseDir\Scripts\Analysis" }
        default { return "$baseDir\Misc" }
    }
}

# Processar arquivos .mq4
Write-Host "Iniciando classificação automática..."

Get-ChildItem $sourceDir -Recurse -Filter "*.mq4" | ForEach-Object {
    $totalFiles++
    $file = $_
    $fileName = $file.BaseName
    
    Write-Host "Processando: $fileName"
    "Processando: $fileName" | Add-Content $logFile
    
    try {
        # Detectar tipo
        $fileType = Get-FileType $file.FullName
        
        if ($fileType -eq "UNKNOWN") {
            Write-Host "  SKIP: Tipo não identificado" -ForegroundColor Yellow
            "  SKIP: Tipo não identificado" | Add-Content $logFile
            $skippedFiles++
            return
        }
        
        # Gerar nome padronizado
        $newName = Get-StandardName $fileName $fileType
        
        # Obter pasta de destino
        $destFolder = Get-DestinationFolder $fileType
        
        # Criar pasta se não existir
        if (!(Test-Path $destFolder)) {
            New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
        }
        
        # Caminho de destino
        $destPath = Join-Path $destFolder $newName
        
        # Verificar se já existe
        if (Test-Path $destPath) {
            $counter = 1
            do {
                $newNameWithCounter = $newName -replace "\.mq4$", "_$counter.mq4"
                $destPath = Join-Path $destFolder $newNameWithCounter
                $counter++
            } while (Test-Path $destPath)
        }
        
        # Copiar arquivo
        Copy-Item $file.FullName $destPath -Force
        
        Write-Host "  OK: $fileType -> $(Split-Path $destPath -Leaf)" -ForegroundColor Green
        "  OK: $fileType -> $(Split-Path $destPath -Leaf)" | Add-Content $logFile
        
        $processedFiles++
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        "  ERROR: $($_.Exception.Message)" | Add-Content $logFile
        $skippedFiles++
    }
}

# Relatório final
Write-Host "`n=== RELATÓRIO FINAL ===" -ForegroundColor Cyan
Write-Host "Total de arquivos: $totalFiles"
Write-Host "Processados: $processedFiles" -ForegroundColor Green
Write-Host "Ignorados: $skippedFiles" -ForegroundColor Yellow

"""
=== RELATÓRIO FINAL ===
Total de arquivos: $totalFiles
Processados: $processedFiles
Ignorados: $skippedFiles
Concluído em: $(Get-Date)
""" | Add-Content $logFile

Write-Host "Log salvo em: $logFile"