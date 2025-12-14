@echo off
echo Iniciando o MCP MetaTrader5 Server...
cd /d "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\mcp-metatrader5-server"
"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\.venv\Scripts\python.exe" run.py dev --host 127.0.0.1 --port 8000
pause
