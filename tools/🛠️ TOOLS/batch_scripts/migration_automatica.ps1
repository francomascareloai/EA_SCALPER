# 🤖 SCRIPT DE MIGRAÇÃO AUTOMÁTICA - EA_SCALPER_XAUUSD
# Agente Organizador - Migração Inteligente de Arquivos

Write-Host "🚀 INICIANDO MIGRAÇÃO AUTOMÁTICA DE ARQUIVOS..." -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Configurações
$baseDir = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
$logFile = "$baseDir\migration_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Função para log
function Write-Log {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

Write-Log "🎯 FASE 1: MIGRAÇÃO DE SCRIPTS PYTHON" "Yellow"
Write-Log "=====================================" "Yellow"

# Categorias para scripts Python
$pythonCategories = @{
    "file_management" = @("*duplicate*", "*cleanup*", "*organize*", "*metadata*", "*unificar*", "*final_*", "*smart_*")
    "analysis" = @("*analise*", "*quality*", "*process*", "*scan*", "*verificar*", "*diagnostico*")
    "mcp_integration" = @("*mcp*", "*mt5*", "*server*", "*integration*", "*teste_mt5*")
    "monitoring" = @("*monitor*", "*verificar*", "*check*", "*demo_*")
    "utilities" = @("*util*", "*tool*", "*helper*", "*imc_*", "*main*")
}

$pythonScripts = Get-ChildItem -Filter "*.py" -ErrorAction SilentlyContinue
$migratedPython = 0

foreach ($script in $pythonScripts) {
    $categoria = "utilities"  # Default
    
    # Determinar categoria
    foreach ($cat in $pythonCategories.Keys) {
        foreach ($pattern in $pythonCategories[$cat]) {
            if ($script.Name -like $pattern) {
                $categoria = $cat
                break
            }
        }
        if ($categoria -ne "utilities") { break }
    }
    
    $destPath = "🛠️ TOOLS\python_tools\$categoria"
    $destFile = "$destPath\$($script.Name)"
    
    try {
        if (!(Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }
        
        if (Test-Path $script.FullName) {
            Move-Item -Path $script.FullName -Destination $destFile -Force -ErrorAction Stop
            Write-Log "✅ Movido: $($script.Name) → $categoria" "Green"
            $migratedPython++
        }
    }
    catch {
        Write-Log "❌ Erro ao mover: $($script.Name) - $($_.Exception.Message)" "Red"
    }
}

Write-Log "📊 PYTHON MIGRADOS: $migratedPython arquivos" "Cyan"

Write-Log "`n🎯 FASE 2: MIGRAÇÃO DE ARQUIVOS BATCH" "Yellow"
Write-Log "====================================" "Yellow"

$batchFiles = Get-ChildItem -Filter "*.ps1" -ErrorAction SilentlyContinue
$batchFiles += Get-ChildItem -Filter "*.bat" -ErrorAction SilentlyContinue
$migratedBatch = 0

foreach ($batch in $batchFiles) {
    $destPath = "🛠️ TOOLS\batch_scripts"
    $destFile = "$destPath\$($batch.Name)"
    
    try {
        if (!(Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }
        
        if (Test-Path $batch.FullName) {
            Move-Item -Path $batch.FullName -Destination $destFile -Force -ErrorAction Stop
            Write-Log "✅ Movido: $($batch.Name) → batch_scripts" "Green"
            $migratedBatch++
        }
    }
    catch {
        Write-Log "❌ Erro ao mover: $($batch.Name) - $($_.Exception.Message)" "Red"
    }
}

Write-Log "📊 BATCH MIGRADOS: $migratedBatch arquivos" "Cyan"

Write-Log "`n🎯 FASE 3: IDENTIFICAÇÃO DE EAs PRINCIPAIS" "Yellow"
Write-Log "=========================================" "Yellow"

# Padrões para EAs principais
$mainEAPatterns = @(
    "*FTMO*Elite*.mq5", "*FTMO*Elite*.mq4",
    "*AUTONOMOUS*XAUUSD*.mq5", "*AUTONOMOUS*XAUUSD*.mq4", 
    "*Scalper*Elite*.mq5", "*Scalper*Elite*.mq4",
    "*XAUUSD*Scalp*.mq5", "*XAUUSD*Scalp*.mq4"
)

$foundMainEAs = @()
foreach ($pattern in $mainEAPatterns) {
    $files = Get-ChildItem -Recurse -Filter $pattern -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        if ($file.Extension -match '\.(mq4|mq5)$' -and $file.Name -notmatch 'meta|backup|old|test') {
            $foundMainEAs += $file
            Write-Log "🎯 EA Principal identificado: $($file.Name)" "Yellow"
            Write-Log "   📍 Local atual: $($file.Directory)" "Gray"
        }
    }
}

Write-Log "📊 EAs PRINCIPAIS ENCONTRADOS: $($foundMainEAs.Count)" "Cyan"

Write-Log "`n🎯 FASE 4: ORGANIZAÇÃO DE LOGS E RELATÓRIOS" "Yellow"
Write-Log "===========================================" "Yellow"

# Criar pasta para logs se não existir
$logsPath = "📊 DATA\logs_and_reports"
if (!(Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
}

# Mover logs e relatórios
$logFiles = Get-ChildItem -Filter "*.log" -ErrorAction SilentlyContinue
$logFiles += Get-ChildItem -Filter "*report*.json" -ErrorAction SilentlyContinue
$logFiles += Get-ChildItem -Filter "*scan*.json" -ErrorAction SilentlyContinue

$migratedLogs = 0
foreach ($log in $logFiles) {
    $destFile = "$logsPath\$($log.Name)"
    
    try {
        if (Test-Path $log.FullName) {
            Move-Item -Path $log.FullName -Destination $destFile -Force -ErrorAction Stop
            Write-Log "✅ Movido: $($log.Name) → logs_and_reports" "Green"
            $migratedLogs++
        }
    }
    catch {
        Write-Log "❌ Erro ao mover: $($log.Name) - $($_.Exception.Message)" "Red"
    }
}

Write-Log "📊 LOGS MIGRADOS: $migratedLogs arquivos" "Cyan"

Write-Log "`n🎯 RELATÓRIO FINAL DE MIGRAÇÃO" "Green"
Write-Log "==============================" "Green"
Write-Log "✅ Scripts Python migrados: $migratedPython" "Green"
Write-Log "✅ Arquivos Batch migrados: $migratedBatch" "Green"
Write-Log "✅ EAs principais identificados: $($foundMainEAs.Count)" "Green"
Write-Log "✅ Logs e relatórios migrados: $migratedLogs" "Green"
Write-Log "✅ Log salvo em: $logFile" "Green"

$totalMigrated = $migratedPython + $migratedBatch + $migratedLogs
Write-Log "`n🏆 TOTAL DE ARQUIVOS MIGRADOS: $totalMigrated" "Cyan"

Write-Log "`n📋 PRÓXIMOS PASSOS RECOMENDADOS:" "Yellow"
Write-Log "1. Verificar arquivos migrados nas novas pastas" "White"
Write-Log "2. Mover EAs principais para 🚀 MAIN_EAS/" "White"  
Write-Log "3. Organizar códigos MQL4/MQL5 por categoria" "White"
Write-Log "4. Implementar sistema de backup automático" "White"
Write-Log "5. Criar templates padronizados" "White"

Write-Host "`n🎉 MIGRAÇÃO AUTOMÁTICA CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
