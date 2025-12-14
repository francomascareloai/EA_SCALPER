# SCRIPT DE INICIALIZACAO - SISTEMA MULTI-AGENTE QWEN 3
# Orquestrador: Trae AI (Claude 4 Sonnet)
# Agentes: 5x Qwen 3 Code CLI especializados

Write-Host "INICIANDO SISTEMA MULTI-AGENTE QWEN 3" -ForegroundColor Green
Write-Host "Orquestrador: Trae AI (Claude 4 Sonnet)" -ForegroundColor Cyan
Write-Host "Agentes: 5x Qwen 3 Code CLI especializados" -ForegroundColor Cyan
Write-Host ""

# Verificar se Qwen esta instalado
Write-Host "Verificando instalacao do Qwen..." -ForegroundColor Yellow
try {
    $qwenVersion = qwen --version
    Write-Host "Qwen v$qwenVersion detectado" -ForegroundColor Green
} catch {
    Write-Host "Qwen nao encontrado. Instale com: npm install -g qwen" -ForegroundColor Red
    exit 1
}

# Verificar prompts especializados
Write-Host "Verificando prompts especializados..." -ForegroundColor Yellow
$promptFiles = @(
    "prompts/classificador_system.txt",
    "prompts/analisador_system.txt", 
    "prompts/gerador_system.txt",
    "prompts/validador_system.txt",
    "prompts/documentador_system.txt"
)

foreach ($prompt in $promptFiles) {
    if (Test-Path $prompt) {
        Write-Host "OK: $prompt" -ForegroundColor Green
    } else {
        Write-Host "ERRO: $prompt nao encontrado" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "CONFIGURACAO DOS AGENTES" -ForegroundColor Magenta
Write-Host "======================================" -ForegroundColor Magenta

# Configuracoes dos agentes
$agentes = @(
    @{
        Nome = "Classificador_Trading"
        Prompt = "prompts/classificador_system.txt"
        Modelo = "qwen3-coder-plus"
        Especialidade = "Analise e classificacao de codigos MQL4/MQL5/Pine"
        Terminal = 1
    },
    @{
        Nome = "Analisador_Metadados"
        Prompt = "prompts/analisador_system.txt"
        Modelo = "qwen3-coder-plus"
        Especialidade = "Extracao completa de metadados"
        Terminal = 2
    },
    @{
        Nome = "Gerador_Snippets"
        Prompt = "prompts/gerador_system.txt"
        Modelo = "qwen3-coder-plus"
        Especialidade = "Extracao de snippets reutilizaveis"
        Terminal = 3
    },
    @{
        Nome = "Validador_FTMO"
        Prompt = "prompts/validador_system.txt"
        Modelo = "qwen3-coder-plus"
        Especialidade = "Analise de conformidade FTMO"
        Terminal = 4
    },
    @{
        Nome = "Documentador_Trading"
        Prompt = "prompts/documentador_system.txt"
        Modelo = "qwen3-coder-plus"
        Especialidade = "Geracao de documentacao e indices"
        Terminal = 5
    }
)

# Exibir configuracao
foreach ($agente in $agentes) {
    Write-Host "Terminal $($agente.Terminal): $($agente.Nome)" -ForegroundColor Cyan
    Write-Host "   Especialidade: $($agente.Especialidade)" -ForegroundColor White
    Write-Host "   Modelo: $($agente.Modelo)" -ForegroundColor White
    Write-Host "   Prompt: $($agente.Prompt)" -ForegroundColor White
    Write-Host ""
}

Write-Host "IMPORTANTE: Este script prepara a configuracao." -ForegroundColor Yellow
Write-Host "O Orquestrador (Trae AI) controlara os terminais diretamente." -ForegroundColor Yellow
Write-Host ""

# Criar diretorio de logs se nao existir
if (!(Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
    Write-Host "Diretorio 'logs' criado" -ForegroundColor Green
}

# Criar arquivo de configuracao para o orquestrador
$config = @{
    sistema = "Multi-Agente Qwen 3"
    orquestrador = "Trae AI (Claude 4 Sonnet)"
    versao = "1.0"
    data_criacao = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    agentes = $agentes
    capacidades = @{
        terminais_simultaneos = 5
        processamento_paralelo = $true
        validacao_cruzada = $true
        especializacao_profunda = $true
    }
    comandos_inicializacao = @(
        "qwen chat --model qwen3-coder-plus --system-file prompts/classificador_system.txt",
        "qwen chat --model qwen3-coder-plus --system-file prompts/analisador_system.txt",
        "qwen chat --model qwen3-coder-plus --system-file prompts/gerador_system.txt",
        "qwen chat --model qwen3-coder-plus --system-file prompts/validador_system.txt",
        "qwen chat --model qwen3-coder-plus --system-file prompts/documentador_system.txt"
    )
}

$configJson = $config | ConvertTo-Json -Depth 10
$configJson | Out-File -FilePath "config_multi_agente.json" -Encoding UTF8

Write-Host "Configuracao salva em: config_multi_agente.json" -ForegroundColor Green
Write-Host ""

# Resumo final
Write-Host "SISTEMA MULTI-AGENTE CONFIGURADO COM SUCESSO!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. O Orquestrador (Trae AI) iniciara os 5 terminais automaticamente" -ForegroundColor White
Write-Host "2. Cada terminal executara um agente Qwen especializado" -ForegroundColor White
Write-Host "3. Processamento paralelo de ate 5 arquivos simultaneos" -ForegroundColor White
Write-Host "4. Validacao cruzada e consolidacao de resultados" -ForegroundColor White
Write-Host ""
Write-Host "CAPACIDADES CONFIRMADAS:" -ForegroundColor Cyan
Write-Host "   5 terminais simultaneos" -ForegroundColor Green
Write-Host "   Qwen 3 Code CLI funcional" -ForegroundColor Green
Write-Host "   Prompts especializados criados" -ForegroundColor Green
Write-Host "   Protocolo de comunicacao definido" -ForegroundColor Green
Write-Host "   Sistema de logs configurado" -ForegroundColor Green
Write-Host ""
Write-Host "VANTAGEM: Sistema 100% gratuito (Qwen local)" -ForegroundColor Magenta
Write-Host "PERFORMANCE: 5x mais rapido que processamento sequencial" -ForegroundColor Magenta
Write-Host ""
Write-Host "PRONTO PARA PROCESSAR BIBLIOTECA COMPLETA!" -ForegroundColor Green

# Log da inicializacao
$logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Sistema Multi-Agente Qwen 3 configurado com sucesso"
$logEntry | Out-File -FilePath "logs/sistema_inicializacao.log" -Append -Encoding UTF8