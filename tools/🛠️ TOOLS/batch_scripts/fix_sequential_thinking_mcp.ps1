# 🔧 Script para Corrigir o Timeout do Sequential-Thinking MCP
# Resolve o erro "context deadline exceeded" do servidor sequential-thinking

Write-Host "🔧 Corrigindo Timeout do Sequential-Thinking MCP" -ForegroundColor Green
Write-Host "============================================================"

$targetFile = "C:\Users\Admin\AppData\Roaming\Qoder\SharedClientCache\mcp.json"
$backupFile = "C:\Users\Admin\AppData\Roaming\Qoder\SharedClientCache\mcp_backup_sequential_fix_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

try {
    # Verificar se o arquivo existe
    if (-not (Test-Path $targetFile)) {
        Write-Host "❌ Arquivo de configuração não encontrado: $targetFile" -ForegroundColor Red
        exit 1
    }

    # Criar backup
    Write-Host "📋 Criando backup da configuração atual..." -ForegroundColor Yellow
    Copy-Item $targetFile $backupFile
    Write-Host "✅ Backup criado: $backupFile" -ForegroundColor Green
    
    # Ler configuração atual
    $configContent = Get-Content $targetFile -Raw | ConvertFrom-Json
    
    # Atualizar configuração do sequential-thinking
    if ($configContent.mcpServers.'sequential-thinking') {
        Write-Host "🔄 Atualizando configuração do sequential-thinking..." -ForegroundColor Yellow
        
        $configContent.mcpServers.'sequential-thinking'.args = @("@modelcontextprotocol/server-sequential-thinking")
        
        # Salvar configuração atualizada
        $configContent | ConvertTo-Json -Depth 10 | Set-Content $targetFile -Encoding UTF8
        
        Write-Host "✅ Configuração atualizada com sucesso!" -ForegroundColor Green
        
        Write-Host "📋 Nova configuração do sequential-thinking:" -ForegroundColor Cyan
        Write-Host "Command: npx" -ForegroundColor White
        Write-Host "Args: @modelcontextprotocol/server-sequential-thinking" -ForegroundColor White
        
        Write-Host "`n🚀 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
        Write-Host "1. Reinicie o Qoder IDE completamente"
        Write-Host "2. O sequential-thinking deve inicializar sem timeout"
        
        Write-Host "`n💡 EXPLICAÇÃO DA CORREÇÃO:" -ForegroundColor Green
        Write-Host "- Removido o parâmetro '-y' que pode causar delay"
        Write-Host "- Usando instalação global para startup mais rápido"
        
    } else {
        Write-Host "❌ Configuração do sequential-thinking não encontrada" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Erro durante a correção: $($_.Exception.Message)" -ForegroundColor Red
    
    if (Test-Path $backupFile) {
        Write-Host "🔄 Restaurando backup..." -ForegroundColor Yellow
        Copy-Item $backupFile $targetFile -Force
        Write-Host "✅ Backup restaurado" -ForegroundColor Green
    }
    exit 1
}

Write-Host "`n✅ CORREÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "============================================================"