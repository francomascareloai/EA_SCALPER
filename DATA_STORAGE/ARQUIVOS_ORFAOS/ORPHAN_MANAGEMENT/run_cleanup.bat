@echo off
echo EA_SCALPER_XAUUSD Directory Cleanup Tool
echo ========================================
echo.
echo Running directory cleanup script...
echo.
python "%~dp0cleanup_unused_directories.py"
echo.
echo Cleanup script completed.
pause