#!/bin/bash
# MQL5 Build All Script - Compile EA, Indicators, and Test Scripts
# Usage: ./scripts/mql5_build_all.sh
#
# Compiles in dependency order:
# 1. EA_SCALPER_XAUUSD.mq5 (main EA)
# 2. Indicators (SMC_Visual, TradingDashboard)
# 3. Test Scripts (DDTracker, TimeHandler, WallClock, GapCooldown)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "MQL5 Build All - Phase 13 Validation"
echo "=========================================="
echo ""

# Sync first
echo "Syncing files to MT5..."
bash "$SCRIPT_DIR/mql5_sync.sh" | tail -3
echo ""

WIN_METAEDITOR="C:\\Program Files\\FTMO MetaTrader 5\\MetaEditor64.exe"
POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
MT5_ROOT="/mnt/c/Program Files/FTMO MetaTrader 5/MQL5"

# Function to compile a single file
compile_file() {
    local FILE_TYPE="$1"  # Experts, Indicators, Scripts
    local FILE_NAME="$2"
    local WIN_PATH="C:\\Program Files\\FTMO MetaTrader 5\\MQL5\\${FILE_TYPE}\\${FILE_NAME}.mq5"
    local LOG_PATH="${MT5_ROOT}/${FILE_TYPE}/${FILE_NAME}.log"

    printf "  %-40s " "$FILE_NAME"

    # Run MetaEditor
    "$POWERSHELL" -NoProfile -Command "
        \$process = Start-Process -FilePath '$WIN_METAEDITOR' \`
            -ArgumentList '/compile:\"$WIN_PATH\"', '/log' \`
            -Wait -NoNewWindow -PassThru
        exit \$process.ExitCode
    " 2>/dev/null || true

    sleep 1

    if [[ -f "$LOG_PATH" ]]; then
        LOG_CONTENT=$(iconv -f UTF-16LE -t UTF-8 "$LOG_PATH" 2>/dev/null | tr -d '\r')
        ERRORS=$(echo "$LOG_CONTENT" | grep -c ": error" || true)
        ERRORS=${ERRORS:-0}

        if [[ "$ERRORS" -gt 0 ]]; then
            echo "❌ ($ERRORS errors)"
            return 1
        else
            echo "✅"
            return 0
        fi
    else
        echo "⚠️  (no log)"
        return 1
    fi
}

FAILED=0
TOTAL=0

# 1. Main EA
echo "Building Main EA..."
((++TOTAL))
compile_file "Experts" "EA_SCALPER_XAUUSD" || ((++FAILED))
echo ""

# 2. Indicators
echo "Building Indicators..."
for ind in "SMC_Visual" "TradingDashboard"; do
    if [[ -f "${MT5_ROOT}/Indicators/${ind}.mq5" ]]; then
        ((++TOTAL))
        compile_file "Indicators" "$ind" || ((++FAILED))
    fi
done
echo ""

# 3. Test Scripts
echo "Building Test Scripts..."
for script in "Tests/Test_DDTracker" "Tests/Test_TimeHandler" "Tests/Test_WallClock" "TestGapCooldown"; do
    SCRIPT_NAME=$(basename "$script")
    SCRIPT_DIR_PATH=$(dirname "$script")

    if [[ -f "${MT5_ROOT}/Scripts/${script}.mq5" ]]; then
        ((++TOTAL))
        compile_file "Scripts" "${script}" || ((++FAILED))
    fi
done
echo ""

# Summary
echo "=========================================="
if [[ "$FAILED" -eq 0 ]]; then
    echo "✅ ALL BUILDS PASSED: ${TOTAL}/${TOTAL}"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Open MT5 and run test scripts (Scripts > Tests/)"
    echo "2. Attach EA to XAUUSD chart with Demo mode ON"
    echo "3. Verify HUD shows correctly"
    echo "4. Run backtest per BACKTEST_GUIDE.md"
    exit 0
else
    echo "❌ BUILDS FAILED: $FAILED of $TOTAL"
    echo "=========================================="
    echo ""
    echo "Check individual .log files in MQL5/ directories"
    exit 1
fi
