#!/bin/bash
# MQL5 Compile Script - Compiles MQL5 files via Windows MetaEditor from WSL
# Usage: ./scripts/mql5_compile.sh [EA_NAME]
# Example: ./scripts/mql5_compile.sh EA_SCALPER_XAUUSD

set -e

# Configuration
METAEDITOR="/mnt/c/Program Files/FTMO MetaTrader 5/MetaEditor64.exe"
WIN_PROJECT="C:\\Users\\Admin\\Documents\\EA_SCALPER_XAUUSD\\MQL5"
WIN_STDLIB="C:\\Program Files\\FTMO MetaTrader 5\\MQL5"
WSL_PROJECT="/mnt/c/Users/Admin/Documents/EA_SCALPER_XAUUSD/MQL5"

# Default EA
EA_NAME="${1:-EA_SCALPER_XAUUSD}"
EA_FILE="${WIN_PROJECT}\\Experts\\${EA_NAME}.mq5"
LOG_FILE="${WSL_PROJECT}/Experts/${EA_NAME}.log"

echo "=========================================="
echo "MQL5 Compiler - ${EA_NAME}"
echo "=========================================="

# Check if MetaEditor exists
if [[ ! -f "$METAEDITOR" ]]; then
    echo "ERROR: MetaEditor not found at: $METAEDITOR"
    exit 1
fi

# Check if source file exists
if [[ ! -f "${WSL_PROJECT}/Experts/${EA_NAME}.mq5" ]]; then
    echo "ERROR: Source file not found: ${WSL_PROJECT}/Experts/${EA_NAME}.mq5"
    echo "Available EAs:"
    ls "${WSL_PROJECT}/Experts/"*.mq5 2>/dev/null | xargs -n1 basename | sed 's/.mq5//'
    exit 1
fi

# Remove old log
rm -f "$LOG_FILE" 2>/dev/null || true

echo "Compiling: ${EA_NAME}.mq5..."
echo ""

# Compile via PowerShell (WSL interop)
powershell.exe -NoProfile -Command "
    Start-Process -FilePath '${METAEDITOR//\//\\}' \`
        -ArgumentList '/compile:\"${EA_FILE}\"', '/inc:\"${WIN_PROJECT}\\Include\"', '/inc:\"${WIN_STDLIB}\\Include\"', '/log' \`
        -Wait -NoNewWindow
" 2>/dev/null || {
    # Fallback: direct execution via cmd
    echo "PowerShell failed, trying direct execution..."
    cmd.exe /c "\"${METAEDITOR//\//\\}\" /compile:\"${EA_FILE}\" /inc:\"${WIN_PROJECT}\\Include\" /inc:\"${WIN_STDLIB}\\Include\" /log" 2>/dev/null
}

# Wait for log file
sleep 1

# Check if log exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "WARNING: Log file not created. Compilation may have failed."
    exit 1
fi

# Parse and display log (convert from UTF-16LE)
echo "=========================================="
echo "COMPILATION RESULTS"
echo "=========================================="

# Count errors and warnings
ERRORS=$(iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -c ": error" || echo 0)
WARNINGS=$(iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -c ": warning" || echo 0)

# Show summary
if [[ "$ERRORS" -gt 0 ]]; then
    echo "❌ COMPILATION FAILED: $ERRORS error(s), $WARNINGS warning(s)"
    echo ""
    echo "ERRORS:"
    iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep ": error" | sed 's/^/  /'
else
    echo "✅ COMPILATION SUCCESSFUL: 0 errors, $WARNINGS warning(s)"
fi

if [[ "$WARNINGS" -gt 0 ]]; then
    echo ""
    echo "WARNINGS:"
    iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep ": warning" | sed 's/^/  /'
fi

# Show result line
echo ""
echo "RESULT:"
iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -E "Result|error|compiled" | tail -5 | sed 's/^/  /'

echo ""
echo "=========================================="
echo "Full log: $LOG_FILE"
echo "=========================================="

# Exit with error code if compilation failed
[[ "$ERRORS" -eq 0 ]]
