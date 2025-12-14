# Script para inicializar o MCP MetaTrader5 Server para uso com Trae
# Execute este script para iniciar o servidor MCP

Write-Host "=== MCP MetaTrader5 Server para Trae ===" -ForegroundColor Green
Write-Host "Iniciando servidor..." -ForegroundColor Yellow

# Navegar para o diretório do projeto
Set-Location "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\mcp-metatrader5-server"

# Verificar se o ambiente virtual existe
$venvPath = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\.venv\Scripts\python.exe"
if (-not (Test-Path $venvPath)) {
    Write-Host "ERRO: Ambiente virtual não encontrado em: $venvPath" -ForegroundColor Red
    exit 1
}

# Iniciar o servidor
Write-Host "Servidor será iniciado em: http://127.0.0.1:8000" -ForegroundColor Cyan
Write-Host "Configure o Trae com o arquivo: trae_mcp_config_mt5.json" -ForegroundColor Magenta
Write-Host "Para parar o servidor, pressione Ctrl+C" -ForegroundColor Yellow
Write-Host ""

& $venvPath run.py dev --host 127.0.0.1 --port 8000
