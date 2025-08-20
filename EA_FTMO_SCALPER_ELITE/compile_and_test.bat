@echo off
echo ========================================
echo  EA FTMO SCALPER ELITE - COMPILACAO
echo ========================================
echo.

REM Definir caminhos possíveis do MetaTrader 5
set "MT5_PATH1=C:\Program Files\MetaTrader 5"
set "MT5_PATH2=C:\Program Files (x86)\MetaTrader 5"
set "MT5_PATH3=%APPDATA%\MetaQuotes\Terminal"
set "MT5_PATH4=C:\Users\%USERNAME%\AppData\Roaming\MetaQuotes\Terminal"

set "METAEDITOR="
set "EA_FILE=%~dp0MQL5_Source\EA_FTMO_Scalper_Elite.mq5"
set "LOG_FILE=%~dp0compilation_log.txt"

echo [%date% %time%] Iniciando verificacao de compilacao do EA... > "%LOG_FILE%"
echo.

REM Procurar MetaEditor em diferentes locais
if exist "%MT5_PATH1%\metaeditor64.exe" (
    set "METAEDITOR=%MT5_PATH1%\metaeditor64.exe"
    echo MetaEditor encontrado em: %MT5_PATH1%
) else if exist "%MT5_PATH2%\metaeditor64.exe" (
    set "METAEDITOR=%MT5_PATH2%\metaeditor64.exe"
    echo MetaEditor encontrado em: %MT5_PATH2%
) else if exist "%MT5_PATH1%\metaeditor.exe" (
    set "METAEDITOR=%MT5_PATH1%\metaeditor.exe"
    echo MetaEditor encontrado em: %MT5_PATH1% (versao 32-bit)
) else if exist "%MT5_PATH2%\metaeditor.exe" (
    set "METAEDITOR=%MT5_PATH2%\metaeditor.exe"
    echo MetaEditor encontrado em: %MT5_PATH2% (versao 32-bit)
) else (
    echo.
    echo ========================================
    echo  METAEDITOR NAO ENCONTRADO
    echo ========================================
    echo.
    echo O MetaEditor nao foi encontrado nos caminhos padrao:
    echo - %MT5_PATH1%
    echo - %MT5_PATH2%
    echo.
    echo INSTRUCOES PARA COMPILACAO MANUAL:
    echo.
    echo 1. Abra o MetaEditor (MetaTrader 5)
    echo 2. Abra o arquivo: %EA_FILE%
    echo 3. Pressione F7 ou clique em "Compile"
    echo 4. Verifique se nao ha erros na aba "Errors"
    echo 5. Se compilado com sucesso, o arquivo .ex5 sera gerado
    echo.
    echo ========================================
    echo  VERIFICACAO DE SINTAXE
    echo ========================================
    echo.
    echo Verificando estrutura dos arquivos...
    
    REM Verificar se arquivo EA existe
    if exist "%EA_FILE%" (
        echo [OK] Arquivo principal encontrado: EA_FTMO_Scalper_Elite.mq5
    ) else (
        echo [ERRO] Arquivo principal nao encontrado!
        goto :end
    )
    
    REM Verificar arquivos de include
    echo.
    echo Verificando arquivos de include:
    
    if exist "%~dp0MQL5_Source\Source\Core\DataStructures.mqh" (
        echo [OK] DataStructures.mqh
    ) else (
        echo [ERRO] DataStructures.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Core\Interfaces.mqh" (
        echo [OK] Interfaces.mqh
    ) else (
        echo [ERRO] Interfaces.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Core\Logger.mqh" (
        echo [OK] Logger.mqh
    ) else (
        echo [ERRO] Logger.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Core\ConfigManager.mqh" (
        echo [OK] ConfigManager.mqh
    ) else (
        echo [ERRO] ConfigManager.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Core\CacheManager.mqh" (
        echo [OK] CacheManager.mqh
    ) else (
        echo [ERRO] CacheManager.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Core\PerformanceAnalyzer.mqh" (
        echo [OK] PerformanceAnalyzer.mqh
    ) else (
        echo [ERRO] PerformanceAnalyzer.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Strategies\ICT\OrderBlockDetector.mqh" (
        echo [OK] OrderBlockDetector.mqh
    ) else (
        echo [ERRO] OrderBlockDetector.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Strategies\ICT\FVGDetector.mqh" (
        echo [OK] FVGDetector.mqh
    ) else (
        echo [ERRO] FVGDetector.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Strategies\ICT\LiquidityDetector.mqh" (
        echo [OK] LiquidityDetector.mqh
    ) else (
        echo [ERRO] LiquidityDetector.mqh nao encontrado!
    )
    
    if exist "%~dp0MQL5_Source\Source\Strategies\ICT\MarketStructureAnalyzer.mqh" (
        echo [OK] MarketStructureAnalyzer.mqh
    ) else (
        echo [ERRO] MarketStructureAnalyzer.mqh nao encontrado!
    )
    
    echo.
    echo ========================================
    echo  PROXIMOS PASSOS
    echo ========================================
    echo.
    echo 1. Instale o MetaTrader 5 se nao estiver instalado
    echo 2. Compile manualmente usando as instrucoes acima
    echo 3. Execute os testes no Strategy Tester
    echo.
    echo [%date% %time%] Verificacao concluida - MetaEditor nao encontrado >> "%LOG_FILE%"
    goto :end
)

REM Verificar se arquivo EA existe
if not exist "%EA_FILE%" (
    echo ERRO: Arquivo EA nao encontrado: %EA_FILE%
    echo [%date% %time%] ERRO: Arquivo EA nao encontrado >> "%LOG_FILE%"
    goto :end
)

echo Compilando EA: %EA_FILE%
echo.

REM Compilar o EA
"%METAEDITOR%" /compile:"%EA_FILE%" /log:"%LOG_FILE%" /inc:"%~dp0MQL5_Source"

REM Verificar resultado da compilacao
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  COMPILACAO CONCLUIDA COM SUCESSO!
    echo ========================================
    echo [%date% %time%] Compilacao bem-sucedida >> "%LOG_FILE%"
    echo.
    echo Arquivo .ex5 gerado com sucesso.
    echo Verifique a pasta Experts do MetaTrader 5.
) else (
    echo.
    echo ========================================
    echo  ERRO NA COMPILACAO!
    echo ========================================
    echo [%date% %time%] Erro na compilacao - Codigo: %ERRORLEVEL% >> "%LOG_FILE%"
    echo.
    echo Verifique o log de compilacao: %LOG_FILE%
    echo Abra o MetaEditor para ver detalhes dos erros.
)

:end
echo.
echo Pressione qualquer tecla para continuar...
pause > nul