# EA_SCALPER_XAUUSD Directory Cleanup Tool
Write-Host "EA_SCALPER_XAUUSD Directory Cleanup Tool" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Running directory cleanup script..." -ForegroundColor Yellow
Write-Host ""

# Run the cleanup script
python "$PSScriptRoot\cleanup_unused_directories.py"

Write-Host ""
Write-Host "Cleanup script completed." -ForegroundColor Green
Write-Host "Press any key to exit..."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")