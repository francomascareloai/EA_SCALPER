#!/bin/bash
# MQL5 Build Script - Full workflow: sync → compile → report
# Usage: ./scripts/mql5_build.sh [EA_NAME]
# Example: ./scripts/mql5_build.sh EA_SCALPER_XAUUSD

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EA_NAME="${1:-EA_SCALPER_XAUUSD}"

echo "=========================================="
echo "MQL5 Build: $EA_NAME"
echo "=========================================="
echo ""

# Step 1: Sync
echo "Step 1/3: Syncing files to MT5..."
bash "$SCRIPT_DIR/mql5_sync.sh" | tail -5
echo ""

# Step 2: Compile
echo "Step 2/3: Compiling..."
# We need to trigger compilation on Windows side
# The simplest way is to use PowerShell

WIN_METAEDITOR="C:\\Program Files\\FTMO MetaTrader 5\\MetaEditor64.exe"
WIN_EA="C:\\Program Files\\FTMO MetaTrader 5\\MQL5\\Experts\\${EA_NAME}.mq5"
WIN_INCLUDE="C:\\Program Files\\FTMO MetaTrader 5\\MQL5\\Include"

# Run MetaEditor via PowerShell
POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
"$POWERSHELL" -NoProfile -Command "
    \$process = Start-Process -FilePath '$WIN_METAEDITOR' \`
        -ArgumentList '/compile:\"$WIN_EA\"', '/inc:\"$WIN_INCLUDE\"', '/log' \`
        -Wait -NoNewWindow -PassThru
    exit \$process.ExitCode
" 2>/dev/null || echo "(PowerShell warning ignored)"

# Wait for log to be written
sleep 2

# Step 3: Report
echo "Step 3/3: Reading results..."
echo ""

LOG_FILE="/mnt/c/Program Files/FTMO MetaTrader 5/MQL5/Experts/${EA_NAME}.log"

if [[ -f "$LOG_FILE" ]]; then
    ERRORS=$(iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -c ": error" || echo 0)
    WARNINGS=$(iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -c ": warning" || echo 0)

    echo "=========================================="
    if [[ "$ERRORS" -gt 0 ]]; then
        echo "❌ BUILD FAILED: $ERRORS error(s), $WARNINGS warning(s)"
        echo "=========================================="
        echo ""
        echo "ERRORS:"
        iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep ": error" | while read line; do
            # Extract file:line and message
            echo "  $line" | sed 's/C:\\[^:]*\\//'
        done
        echo ""
        if [[ "$WARNINGS" -gt 0 ]]; then
            echo "WARNINGS:"
            iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep ": warning" | head -5 | while read line; do
                echo "  $line" | sed 's/C:\\[^:]*\\//'
            done
        fi
        exit 1
    else
        echo "✅ BUILD SUCCESSFUL: 0 errors, $WARNINGS warning(s)"
        echo "=========================================="
        if [[ "$WARNINGS" -gt 0 ]]; then
            echo ""
            echo "WARNINGS:"
            iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep ": warning" | while read line; do
                echo "  $line" | sed 's/C:\\[^:]*\\//'
            done
        fi
        echo ""
        echo "Output: /mnt/c/Program Files/FTMO MetaTrader 5/MQL5/Experts/${EA_NAME}.ex5"
        exit 0
    fi
else
    echo "⚠️  Log file not found. Compilation may not have run."
    echo "Make sure MetaTrader 5 is not blocking MetaEditor."
    exit 1
fi
