@echo off
echo Compilando EA_FTMO_SCALPER_ELITE_v10.mq5...
"C:\Program Files\FTMO MetaTrader 5\MetaEditor64.exe" /compile:"Source\EAs\FTMO_Ready\EA_FTMO_SCALPER_ELITE_v10.mq5" /log:"compilation_log_v10_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
echo Compilacao concluida.
echo Verificando arquivo .ex5...
dir "Source\EAs\FTMO_Ready\*.ex5"
pause