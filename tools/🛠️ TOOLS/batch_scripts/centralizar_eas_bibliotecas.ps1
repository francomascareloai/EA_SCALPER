# 🎯 SCRIPT DE CENTRALIZAÇÃO - EAs PRINCIPAIS E BIBLIOTECAS MQH
# Agente Organizador - Centralização Inteligente

Write-Host "🚀 INICIANDO CENTRALIZAÇÃO DE EAs E BIBLIOTECAS..." -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

# Configurações
$baseDir = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
Set-Location $baseDir

# FASE 1: CENTRALIZAR BIBLIOTECAS .MQH
Write-Host "`n📚 FASE 1: CENTRALIZANDO BIBLIOTECAS .MQH" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

# Criar pasta centralizada para bibliotecas
$mqhCentralPath = "📚 LIBRARY\MQH_INCLUDES"
if (!(Test-Path $mqhCentralPath)) {
    New-Item -ItemType Directory -Path $mqhCentralPath -Force | Out-Null
    Write-Host "✅ Pasta criada: $mqhCentralPath" -ForegroundColor Green
}

# Buscar e mover todas as bibliotecas .mqh
$mqhFiles = Get-ChildItem -Recurse -Filter "*.mqh" -ErrorAction SilentlyContinue
$movedMqh = 0

foreach ($mqh in $mqhFiles) {
    # Evitar mover se já estiver na pasta centralizada
    if ($mqh.DirectoryName -notlike "*MQH_INCLUDES*") {
        $destFile = "$mqhCentralPath\$($mqh.Name)"
        
        try {
            # Verificar se já existe (evitar duplicatas)
            if (Test-Path $destFile) {
                Write-Host "⚠️ Já existe: $($mqh.Name) - ignorando" -ForegroundColor Yellow
            } else {
                Copy-Item -Path $mqh.FullName -Destination $destFile -Force
                Write-Host "✅ Centralizado: $($mqh.Name)" -ForegroundColor Green
                $movedMqh++
            }
        }
        catch {
            Write-Host "❌ Erro ao centralizar: $($mqh.Name)" -ForegroundColor Red
        }
    }
}

Write-Host "📊 BIBLIOTECAS .MQH CENTRALIZADAS: $movedMqh" -ForegroundColor Cyan

# FASE 2: MOVER EAs PRINCIPAIS
Write-Host "`n🎯 FASE 2: MOVENDO EAs PRINCIPAIS" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

# Padrões para EAs principais (mais específicos)
$mainEAPatterns = @{
    "PRODUCTION" = @(
        "*FTMO*Scalper*Elite*v2.1*.mq5",
        "*FTMO*Scalper*Elite*v2.0*.mq5",
        "*AUTONOMOUS*XAUUSD*ELITE*v2*.mq5"
    )
    "DEVELOPMENT" = @(
        "*FTMO*Scalper*Elite*debug*.mq5",
        "*FTMO*Scalper*Elite*test*.mq5",
        "*AUTONOMOUS*XAUUSD*FIXED*.mq5"
    )
    "TESTING" = @(
        "*FTMO*Scalper*Elite*beta*.mq5",
        "*AUTONOMOUS*XAUUSD*v1*.mq5"
    )
}

$totalEAsMoved = 0

foreach ($category in $mainEAPatterns.Keys) {
    $destPath = "🚀 MAIN_EAS\$category"
    
    Write-Host "`n📁 PROCESSANDO CATEGORIA: $category" -ForegroundColor Magenta
    
    foreach ($pattern in $mainEAPatterns[$category]) {
        $files = Get-ChildItem -Recurse -Filter $pattern -ErrorAction SilentlyContinue
        
        foreach ($file in $files) {
            # Filtrar arquivos válidos
            if ($file.Name -notmatch 'backup|old|meta|dup\d+|copy' -and 
                $file.Extension -match '\.(mq4|mq5)$' -and
                $file.DirectoryName -notlike "*MAIN_EAS*") {
                
                $destFile = "$destPath\$($file.Name)"
                
                try {
                    if (!(Test-Path $destPath)) {
                        New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                    }
                    
                    if (Test-Path $destFile) {
                        Write-Host "⚠️ Já existe em $category`: $($file.Name)" -ForegroundColor Yellow
                    } else {
                        Copy-Item -Path $file.FullName -Destination $destFile -Force
                        Write-Host "✅ Movido para $category`: $($file.Name)" -ForegroundColor Green
                        $totalEAsMoved++
                    }
                }
                catch {
                    Write-Host "❌ Erro ao mover: $($file.Name)" -ForegroundColor Red
                }
            }
        }
    }
}

# FASE 3: BUSCAR OUTROS EAs CRÍTICOS
Write-Host "`n🔍 FASE 3: BUSCANDO OUTROS EAs CRÍTICOS" -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Yellow

$otherCriticalPatterns = @(
    "*XAUUSDScalperPro*.mq5",
    "*XAUUSD*M5*SUPER*SCALPER*.mq4"
)

foreach ($pattern in $otherCriticalPatterns) {
    $files = Get-ChildItem -Recurse -Filter $pattern -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        if ($file.Name -notmatch 'backup|old|meta|dup\d+|copy' -and 
            $file.DirectoryName -notlike "*MAIN_EAS*" -and
            $file.DirectoryName -notlike "*LIMPEZA_FINAL*") {
            
            $destPath = "🚀 MAIN_EAS\PRODUCTION"
            $destFile = "$destPath\$($file.Name)"
            
            try {
                if (!(Test-Path $destFile)) {
                    Copy-Item -Path $file.FullName -Destination $destFile -Force
                    Write-Host "✅ EA Crítico adicionado: $($file.Name)" -ForegroundColor Green
                    $totalEAsMoved++
                }
            }
            catch {
                Write-Host "❌ Erro ao adicionar: $($file.Name)" -ForegroundColor Red
            }
        }
    }
}

# FASE 4: CRIAR ÍNDICE DOS EAs MOVIDOS
Write-Host "`n📊 FASE 4: CRIANDO ÍNDICE DOS EAs PRINCIPAIS" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow

$indexContent = @"
# 🚀 ÍNDICE DOS EAs PRINCIPAIS - MAIN_EAS

## 📊 Estatísticas
- **Data de Atualização**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **Total de EAs Principais**: $totalEAsMoved
- **Bibliotecas .MQH Centralizadas**: $movedMqh

## 📁 PRODUCTION (EAs Prontos)
"@

$productionEAs = Get-ChildItem -Path "🚀 MAIN_EAS\PRODUCTION" -Filter "*.mq*" -ErrorAction SilentlyContinue
foreach ($ea in $productionEAs) {
    $indexContent += "`n- ✅ **$($ea.Name)** - Pronto para uso"
}

$indexContent += "`n`n## 🔧 DEVELOPMENT (EAs em Desenvolvimento)"
$developmentEAs = Get-ChildItem -Path "🚀 MAIN_EAS\DEVELOPMENT" -Filter "*.mq*" -ErrorAction SilentlyContinue
foreach ($ea in $developmentEAs) {
    $indexContent += "`n- 🔄 **$($ea.Name)** - Em desenvolvimento"
}

$indexContent += "`n`n## 🧪 TESTING (EAs em Teste)"
$testingEAs = Get-ChildItem -Path "🚀 MAIN_EAS\TESTING" -Filter "*.mq*" -ErrorAction SilentlyContinue
foreach ($ea in $testingEAs) {
    $indexContent += "`n- 🧪 **$($ea.Name)** - Em fase de testes"
}

$indexContent += "`n`n## 📚 Bibliotecas .MQH Disponíveis"
$centralizedMqh = Get-ChildItem -Path "📚 LIBRARY\MQH_INCLUDES" -Filter "*.mqh" -ErrorAction SilentlyContinue
foreach ($mqh in $centralizedMqh) {
    $indexContent += "`n- 📄 **$($mqh.Name)**"
}

$indexContent | Out-File -FilePath "🚀 MAIN_EAS\INDEX_EAS_PRINCIPAIS.md" -Encoding UTF8

Write-Host "`n🏆 RELATÓRIO FINAL DE CENTRALIZAÇÃO" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host "✅ Bibliotecas .MQH centralizadas: $movedMqh" -ForegroundColor Green
Write-Host "✅ EAs principais movidos: $totalEAsMoved" -ForegroundColor Green
Write-Host "✅ Índice criado: 🚀 MAIN_EAS\INDEX_EAS_PRINCIPAIS.md" -ForegroundColor Green

# Verificar conteúdo final
Write-Host "`n📋 VERIFICAÇÃO FINAL:" -ForegroundColor Cyan
$finalEAs = Get-ChildItem -Path "🚀 MAIN_EAS" -Recurse -Filter "*.mq*" -ErrorAction SilentlyContinue
$finalMqh = Get-ChildItem -Path "📚 LIBRARY\MQH_INCLUDES" -Filter "*.mqh" -ErrorAction SilentlyContinue

Write-Host "🎯 Total final de EAs em MAIN_EAS: $($finalEAs.Count)" -ForegroundColor Green
Write-Host "📚 Total final de .MQH centralizados: $($finalMqh.Count)" -ForegroundColor Green

Write-Host "`n🎉 CENTRALIZAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
