# EA_SCALPER_XAUUSD Build Script
# Automatiza a compilação dos módulos MQL5

param(
    [switch]$SyncOnly,      # Só sincroniza, não compila
    [switch]$CompileOnly,   # Só compila, não sincroniza
    [switch]$Verbose
)

# Configurações
$MetaEditor = "C:\Program Files\FTMO MetaTrader 5\MetaEditor64.exe"
$TerminalMQL5 = "C:\Users\Admin\AppData\Roaming\MetaQuotes\Terminal\49CDDEAA95A409ED22BD2287BB67CB9C\MQL5"
$ProjectRoot = "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
$ProjectMQL5 = "$ProjectRoot\MQL5"

# Cores para output
function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  EA_SCALPER_XAUUSD Build System" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Verificar MetaEditor
if (-not (Test-Path $MetaEditor)) {
    Write-Err "MetaEditor não encontrado em: $MetaEditor"
    exit 1
}
Write-Success "MetaEditor encontrado"

# Verificar Terminal MQL5
if (-not (Test-Path $TerminalMQL5)) {
    Write-Err "Pasta MQL5 do terminal não encontrada: $TerminalMQL5"
    exit 1
}
Write-Success "Terminal MQL5 encontrado"

# === SYNC: Copiar arquivos do projeto para o terminal ===
if (-not $CompileOnly) {
    Write-Info "Sincronizando arquivos..."
    
    # Criar diretório de includes se não existir
    $TargetIncludes = "$TerminalMQL5\Include\EA_SCALPER"
    if (-not (Test-Path $TargetIncludes)) {
        New-Item -ItemType Directory -Path $TargetIncludes -Force | Out-Null
        Write-Info "Criado: $TargetIncludes"
    }
    
    # Copiar estrutura de includes
    $SourceIncludes = "$ProjectMQL5\Include\EA_SCALPER"
    if (Test-Path $SourceIncludes) {
        Copy-Item -Path "$SourceIncludes\*" -Destination $TargetIncludes -Recurse -Force
        Write-Success "Includes sincronizados"
    }
    
    # Copiar EA principal
    $SourceEA = "$ProjectMQL5\Experts\EA_SCALPER_XAUUSD.mq5"
    $TargetEA = "$TerminalMQL5\Experts\EA_SCALPER_XAUUSD.mq5"
    if (Test-Path $SourceEA) {
        Copy-Item -Path $SourceEA -Destination $TargetEA -Force
        Write-Success "EA principal sincronizado"
    }
    
    # Copiar Models (ONNX)
    $SourceModels = "$ProjectMQL5\Models"
    $TargetModels = "$TerminalMQL5\Files\Models"
    if (Test-Path $SourceModels) {
        if (-not (Test-Path $TargetModels)) {
            New-Item -ItemType Directory -Path $TargetModels -Force | Out-Null
        }
        Copy-Item -Path "$SourceModels\*" -Destination $TargetModels -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "Models sincronizados"
    }
}

if ($SyncOnly) {
    Write-Host ""
    Write-Success "Sincronização concluída!"
    exit 0
}

# === COMPILE: Compilar arquivos ===
Write-Host ""
Write-Info "Iniciando compilação..."

$LogFile = "$ProjectRoot\logs\compile_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$LogDir = Split-Path $LogFile
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Compilar EA principal
$EAPath = "$TerminalMQL5\Experts\EA_SCALPER_XAUUSD.mq5"
if (Test-Path $EAPath) {
    Write-Info "Compilando EA_SCALPER_XAUUSD.mq5..."
    
    $process = Start-Process -FilePath $MetaEditor `
        -ArgumentList "/compile:`"$EAPath`" /log:`"$LogFile`" /inc:`"$TerminalMQL5`"" `
        -Wait -PassThru -NoNewWindow
    
    # Verificar resultado
    if (Test-Path $LogFile) {
        $logContent = Get-Content $LogFile -Raw
        
        if ($logContent -match "(\d+) error") {
            $errors = $matches[1]
            if ([int]$errors -gt 0) {
                Write-Err "Compilação falhou com $errors erro(s)"
                Write-Host ""
                Write-Host "=== LOG DE ERROS ===" -ForegroundColor Red
                Get-Content $LogFile | Where-Object { $_ -match "error|warning" } | ForEach-Object {
                    if ($_ -match "error") {
                        Write-Host $_ -ForegroundColor Red
                    } else {
                        Write-Host $_ -ForegroundColor Yellow
                    }
                }
                exit 1
            }
        }
        
        if ($logContent -match "(\d+) warning") {
            $warnings = $matches[1]
            if ([int]$warnings -gt 0) {
                Write-Warn "Compilação com $warnings warning(s)"
            }
        }
        
        Write-Success "Compilação bem-sucedida!"
        
        # Mostrar log se verbose
        if ($Verbose) {
            Write-Host ""
            Write-Host "=== LOG COMPLETO ===" -ForegroundColor Cyan
            Get-Content $LogFile
        }
    }
} else {
    Write-Warn "EA principal não encontrado: $EAPath"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  Build concluído!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Log salvo em: $LogFile"
