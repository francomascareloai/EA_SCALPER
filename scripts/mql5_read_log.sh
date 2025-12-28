#!/bin/bash
# MQL5 Log Reader - Reads and parses MQL5 compile logs
# Usage: ./scripts/mql5_read_log.sh [NAME_WITHOUT_EXT] [--errors|--warnings|--summary|--all]

set -euo pipefail

NAME="${1:-EA_SCALPER_XAUUSD}"
FILTER="${2:---errors}"

MT5_MQL5="/mnt/c/Program Files/FTMO MetaTrader 5/MQL5"

# Detect where the mq5 lives (Experts/Indicators/Scripts) and use matching .log
LOG_FILE=""
for subdir in Experts Indicators Scripts; do
  if [[ -f "$MT5_MQL5/$subdir/${NAME}.mq5" || -f "$MT5_MQL5/$subdir/${NAME}.log" ]]; then
    LOG_FILE="$MT5_MQL5/$subdir/${NAME}.log"
    break
  fi
done

if [[ -z "$LOG_FILE" || ! -f "$LOG_FILE" ]]; then
  echo "Log file not found for: $NAME"
  echo "Checked: $MT5_MQL5/{Experts,Indicators,Scripts}/${NAME}.log"
  exit 1
fi

# Convert UTF-16LE to UTF-8 and strip CR
LOG_UTF8() {
  iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | tr -d '\r'
}

case "$FILTER" in
  --errors)
    LOG_UTF8 | grep -E ": error" || true
    ;;
  --warnings)
    LOG_UTF8 | grep -E ": warning" || true
    ;;
  --summary)
    ERRORS=$(LOG_UTF8 | grep -c ": error" || true)
    WARNINGS=$(LOG_UTF8 | grep -c ": warning" || true)
    ERRORS=${ERRORS:-0}
    WARNINGS=${WARNINGS:-0}
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    LOG_UTF8 | grep -E "^Result:|: error|: warning" | tail -20
    ;;
  --all|*)
    LOG_UTF8
    ;;
esac
