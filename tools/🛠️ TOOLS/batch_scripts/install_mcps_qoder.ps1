# 🤖 Script para Instalar MCPs no Qoder IDE
# Configuração completa para desenvolvimento autônomo de EA XAUUSD

Write-Host "🤖 EA_SCALPER_XAUUSD - Instalação dos MCPs no Qoder IDE" -ForegroundColor Green
Write-Host "=" * 60

$sourceFile = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\qoder_mcp_config_complete.json"
$targetFile = "C:\Users\Admin\AppData\Roaming\Qoder\SharedClientCache\mcp.json"
$backupFile = "C:\Users\Admin\AppData\Roaming\Qoder\SharedClientCache\mcp_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

try {
    # Verificar se o arquivo fonte existe
    if (-not (Test-Path $sourceFile)) {
        Write-Host "❌ Arquivo fonte não encontrado: $sourceFile" -ForegroundColor Red
        exit 1
    }

    # Criar backup da configuração atual
    if (Test-Path $targetFile) {
        Write-Host "📋 Criando backup da configuração atual..." -ForegroundColor Yellow
        Copy-Item $targetFile $backupFile
        Write-Host "✅ Backup criado: $backupFile" -ForegroundColor Green
    }

    # Copiar nova configuração
    Write-Host "📥 Copiando nova configuração dos MCPs..." -ForegroundColor Yellow
    Copy-Item $sourceFile $targetFile -Force
    
    Write-Host "✅ Configuração dos MCPs instalada com sucesso!" -ForegroundColor Green
    
    # Verificar conteúdo
    $config = Get-Content $targetFile | ConvertFrom-Json
    $mcpCount = $config.mcpServers.PSObject.Properties.Count
    
    Write-Host "📊 MCPs Configurados: $mcpCount" -ForegroundColor Cyan
    Write-Host "📋 Lista de MCPs:" -ForegroundColor Cyan
    
    foreach ($mcp in $config.mcpServers.PSObject.Properties.Name) {
        Write-Host "  ✓ $mcp" -ForegroundColor White
    }
    
    Write-Host "`n🚀 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
    Write-Host "1. Reinicie o Qoder IDE"
    Write-Host "2. Os MCPs estarão disponíveis automaticamente"
    Write-Host "3. Use os MCPs para desenvolvimento autônomo do EA"
    
    Write-Host "`n🎯 MCPS ESSENCIAIS PARA EA XAUUSD:" -ForegroundColor Green
    Write-Host "- fetch: Pesquisa web e análise de mercado"
    Write-Host "- github: Versionamento e colaboração"
    Write-Host "- sequential-thinking: Planejamento estruturado"
    Write-Host "- trading_classifier: Análise de códigos de trading"
    Write-Host "- code_analysis: Qualidade e otimização"
    Write-Host "- test_automation: Testes automatizados"
    Write-Host "- metatrader5: Integração direta com MT5"
    
    Write-Host "`n✅ SISTEMA PRONTO PARA DESENVOLVIMENTO AUTÔNOMO!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro durante a instalação: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "=" * 60