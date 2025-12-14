# Script de Classificação Automática MQL4
# Classificador_Trading - Batch Processing

$sourceDir = "c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source\All_MQ4"
$logFile = "c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\classification_log.txt"

# Contadores
$processedCount = 0
$eaCount = 0
$indicatorCount = 0
$scriptCount = 0
$errorCount = 0

# Função para detectar tipo de arquivo
function Get-FileType {
    param($filePath)
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue
        
        if ($content -match "OnTick\(\)|OrderSend\(\)") {
            return "EA"
        }
        elseif ($content -match "OnCalculate\(\)|SetIndexBuffer\(\)") {
            return "Indicator"
        }
        elseif ($content -match "OnStart\(\)") {
            return "Script"
        }
    }
    return "Unknown"
}

# Função para detectar estratégia
function Get-Strategy {
    param($content)
    
    if ($content -match "scalp|M1|M5") { return "Scalping" }
    if ($content -match "grid|martingale|recovery") { return "Grid_Martingale" }
    if ($content -match "order_block|liquidity|institutional|SMC|ICT") { return "SMC_ICT" }
    if ($content -match "trend|momentum|MA") { return "Trend" }
    if ($content -match "volume|OBV|flow") { return "Volume" }
    return "Custom"
}

# Função para detectar mercado
function Get-Market {
    param($content, $fileName)
    
    if ($content -match "XAUUSD|GOLD" -or $fileName -match "XAUUSD|GOLD") { return "XAUUSD" }
    if ($content -match "EURUSD" -or $fileName -match "EURUSD") { return "EURUSD" }
    if ($content -match "GBPUSD" -or $fileName -match "GBPUSD") { return "GBPUSD" }
    return "MULTI"
}

# Iniciar log
"=== CLASSIFICAÇÃO MQL4 INICIADA EM $(Get-Date) ===" | Out-File $logFile

# Processar arquivos .mq4
Get-ChildItem -Path $sourceDir -Filter "*.mq4" -Recurse | ForEach-Object {
    $file = $_
    $processedCount++
    
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        $fileType = Get-FileType $file.FullName
        $strategy = Get-Strategy $content
        $market = Get-Market $content $file.Name
        
        # Gerar novo nome
        $baseName = $file.BaseName -replace "[^a-zA-Z0-9_]", "_"
        $baseName = $baseName.Substring(0, [Math]::Min($baseName.Length, 30))
        
        switch ($fileType) {
            "EA" {
                $destDir = "c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source\EAs\$strategy"
                $newName = "EA_${baseName}_v1.0_${market}.mq4"
                $eaCount++
            }
            "Indicator" {
                $destDir = "c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source\Indicators\$strategy"
                $newName = "IND_${baseName}_v1.0_${market}.mq4"
                $indicatorCount++
            }
            "Script" {
                $destDir = "c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source\Scripts\Utilities"
                $newName = "SCR_${baseName}_v1.0_${market}.mq4"
                $scriptCount++
            }
            default {
                $destDir = "c:\Users\Admin\Documents\EA_SCALPER_XAUUSD\CODIGO_FONTE_LIBRARY\MQL4_Source\EAs\Misc"
                $newName = "MISC_${baseName}_v1.0_${market}.mq4"
            }
        }
        
        # Criar diretório se não existir
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # Verificar se arquivo de destino já existe
        $destPath = Join-Path $destDir $newName
        $counter = 1
        while (Test-Path $destPath) {
            $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($newName)
            $destPath = Join-Path $destDir "${nameWithoutExt}_${counter}.mq4"
            $counter++
        }
        
        # Mover arquivo
        Move-Item -Path $file.FullName -Destination $destPath -Force
        
        $logEntry = "PROCESSADO: $($file.Name) -> $([System.IO.Path]::GetFileName($destPath)) [$fileType/$strategy/$market]"
        Write-Host $logEntry
        $logEntry | Out-File $logFile -Append
        
    }
    catch {
        $errorCount++
        $errorMsg = "ERRO: $($file.Name) - $($_.Exception.Message)"
        Write-Host $errorMsg -ForegroundColor Red
        $errorMsg | Out-File $logFile -Append
    }
}

# Relatório final
$summary = @"

=== RELATÓRIO FINAL ===
Arquivos Processados: $processedCount
EAs: $eaCount
Indicators: $indicatorCount
Scripts: $scriptCount
Erros: $errorCount
Concluído em: $(Get-Date)
"@

Write-Host $summary
$summary | Out-File $logFile -Append

Write-Host "\nClassificação concluída! Verifique o log em: $logFile" -ForegroundColor Green