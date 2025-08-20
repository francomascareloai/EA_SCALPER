@echo off
echo ========================================
echo  VERIFICACAO DE ARQUIVOS DO EA
echo ========================================
echo.

set "EA_FILE=MQL5_Source\EA_FTMO_Scalper_Elite.mq5"

echo Verificando arquivo principal...
if exist "%EA_FILE%" (
    echo [OK] %EA_FILE%
) else (
    echo [ERRO] %EA_FILE% nao encontrado!
    goto :end
)

echo.
echo Verificando arquivos Core:
if exist "MQL5_Source\Source\Core\DataStructures.mqh" (
    echo [OK] DataStructures.mqh
) else (
    echo [ERRO] DataStructures.mqh
)

if exist "MQL5_Source\Source\Core\Interfaces.mqh" (
    echo [OK] Interfaces.mqh
) else (
    echo [ERRO] Interfaces.mqh
)

if exist "MQL5_Source\Source\Core\Logger.mqh" (
    echo [OK] Logger.mqh
) else (
    echo [ERRO] Logger.mqh
)

if exist "MQL5_Source\Source\Core\ConfigManager.mqh" (
    echo [OK] ConfigManager.mqh
) else (
    echo [ERRO] ConfigManager.mqh
)

if exist "MQL5_Source\Source\Core\CacheManager.mqh" (
    echo [OK] CacheManager.mqh
) else (
    echo [ERRO] CacheManager.mqh
)

if exist "MQL5_Source\Source\Core\PerformanceAnalyzer.mqh" (
    echo [OK] PerformanceAnalyzer.mqh
) else (
    echo [ERRO] PerformanceAnalyzer.mqh
)

echo.
echo Verificando arquivos ICT/SMC:
if exist "MQL5_Source\Source\Strategies\ICT\OrderBlockDetector.mqh" (
    echo [OK] OrderBlockDetector.mqh
) else (
    echo [ERRO] OrderBlockDetector.mqh
)

if exist "MQL5_Source\Source\Strategies\ICT\FVGDetector.mqh" (
    echo [OK] FVGDetector.mqh
) else (
    echo [ERRO] FVGDetector.mqh
)

if exist "MQL5_Source\Source\Strategies\ICT\LiquidityDetector.mqh" (
    echo [OK] LiquidityDetector.mqh
) else (
    echo [ERRO] LiquidityDetector.mqh
)

if exist "MQL5_Source\Source\Strategies\ICT\MarketStructureAnalyzer.mqh" (
    echo [OK] MarketStructureAnalyzer.mqh
) else (
    echo [ERRO] MarketStructureAnalyzer.mqh
)

echo.
echo ========================================
echo  INSTRUCOES PARA COMPILACAO MANUAL
echo ========================================
echo.
echo 1. Instale o MetaTrader 5 se nao estiver instalado
echo 2. Abra o MetaEditor
echo 3. Abra o arquivo: %EA_FILE%
echo 4. Pressione F7 ou clique em Compile
echo 5. Verifique se nao ha erros na aba Errors
echo.

:end
pause