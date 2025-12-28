@echo off
REM Start Chrome with remote debugging enabled
REM Close ALL Chrome windows first!

echo Starting Chrome with debug port 9222...
echo Make sure to close ALL other Chrome windows first!
echo.

start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%USERPROFILE%\AppData\Local\Google\Chrome\User Data"

echo Chrome started. You can now:
echo 1. Log into ChatGPT in this Chrome window
echo 2. Run your automation script
pause
