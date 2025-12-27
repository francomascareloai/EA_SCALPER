#!/bin/bash
# MQL5 Log Reader - Reads and parses MQL5 compile logs
# Usage: ./scripts/mql5_read_log.sh [EA_NAME] [--errors|--warnings|--all]

WSL_PROJECT="/mnt/c/Users/Admin/Documents/EA_SCALPER_XAUUSD/MQL5"
EA_NAME="${1:-EA_SCALPER_XAUUSD}"
FILTER="${2:---errors}"
LOG_FILE="${WSL_PROJECT}/Experts/${EA_NAME}.log"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

case "$FILTER" in
    --errors)
        iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -E ": error"
        ;;
    --warnings)
        iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -E ": warning"
        ;;
    --summary)
        ERRORS=$(iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -c ": error" || echo 0)
        WARNINGS=$(iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -c ": warning" || echo 0)
        echo "Errors: $ERRORS"
        echo "Warnings: $WARNINGS"
        iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | grep -E "Result|: error|: warning" | tail -10
        ;;
    --all|*)
        iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null
        ;;
esac
