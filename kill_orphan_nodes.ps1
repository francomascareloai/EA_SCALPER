# Script para matar processos node.exe órfãos (exceto processos ativos do droid/VSCode)
# NÃO executar se você tem trabalho não salvo!

Write-Host "=== MATANDO PROCESSOS NODE.EXE ÓRFÃOS ===" -ForegroundColor Yellow
Write-Host ""

# Count current
$before = (Get-Process node -ErrorAction SilentlyContinue).Count
Write-Host "Processos node.exe ANTES: $before" -ForegroundColor Cyan

# Aviso de segurança
Write-Host ""
Write-Host "AVISO: Isso vai fechar TODOS os processos node.exe!" -ForegroundColor Red
Write-Host "- Salve todo trabalho em ferramentas AI (Cursor, VSCode, etc)" -ForegroundColor Red
Write-Host "- Feche todos os terminais droid manualmente primeiro" -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "Continuar? (S/N)"

if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Cancelado pelo usuário." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Matando processos em 3 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Kill all node.exe processes
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force

# Wait for cleanup
Start-Sleep -Seconds 2

# Count after
$after = (Get-Process node -ErrorAction SilentlyContinue).Count
$freed = $before - $after

Write-Host ""
Write-Host "=== RESULTADO ===" -ForegroundColor Green
Write-Host "Processos node.exe ANTES: $before" -ForegroundColor Cyan
Write-Host "Processos node.exe DEPOIS: $after" -ForegroundColor Cyan
Write-Host "Processos eliminados: $freed" -ForegroundColor Green
Write-Host ""
Write-Host "Agora abra novamente seus terminais droid/VSCode!" -ForegroundColor Yellow
