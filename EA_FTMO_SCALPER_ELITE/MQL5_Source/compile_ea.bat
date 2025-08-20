@echo off
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOGFILE=compilation_log_v2.11_%TIMESTAMP%.txt

echo ========================================== > %LOGFILE%
echo FTMO Scalper Elite v2.11 Compilation Log >> %LOGFILE%
echo Date: %date% %time% >> %LOGFILE%
echo ========================================== >> %LOGFILE%
echo. >> %LOGFILE%

echo Starting compilation... >> %LOGFILE%
"C:\Program Files\FTMO MetaTrader 5\MetaEditor64.exe" /compile:"EA_FTMO_Scalper_Elite.mq5" /log >> %LOGFILE% 2>&1

echo. >> %LOGFILE%
echo Compilation finished at %time% >> %LOGFILE%

if exist "EA_FTMO_Scalper_Elite.ex5" (
    echo SUCCESS: EA_FTMO_Scalper_Elite.ex5 compiled successfully! >> %LOGFILE%
    echo File size: >> %LOGFILE%
    dir "EA_FTMO_Scalper_Elite.ex5" >> %LOGFILE%
) else (
    echo ERROR: Compilation failed - .ex5 file not found >> %LOGFILE%
)

echo. >> %LOGFILE%
echo ========================================== >> %LOGFILE%
echo Log saved as: %LOGFILE% >> %LOGFILE%
echo ========================================== >> %LOGFILE%

type %LOGFILE%
pause