#!/bin/bash
# MQL5 Build Script - Full workflow: sync → compile → report
# Usage: ./scripts/mql5_build.sh [NAME_WITHOUT_EXT]
# Examples:
#   ./scripts/mql5_build.sh EA_SCALPER_XAUUSD
#   ./scripts/mql5_build.sh SMC_Visual

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="${1:-EA_SCALPER_XAUUSD}"

MT5_ROOT="/mnt/c/Program Files/FTMO MetaTrader 5/MQL5"
WIN_MT5_ROOT="C:\\Program Files\\FTMO MetaTrader 5\\MQL5"
WIN_METAEDITOR="C:\\Program Files\\FTMO MetaTrader 5\\MetaEditor64.exe"

CMD_EXE="/mnt/c/Windows/System32/cmd.exe"

echo "=========================================="
echo "MQL5 Build: $NAME"
echo "=========================================="
echo ""

# Step 1: Sync
echo "Step 1/3: Syncing files to MT5..."
bash "$SCRIPT_DIR/mql5_sync.sh" | tail -5
echo ""

# Resolve target location (Experts vs Indicators)
SUBDIR=""
if [[ -f "$MT5_ROOT/Experts/${NAME}.mq5" ]]; then
  SUBDIR="Experts"
elif [[ -f "$MT5_ROOT/Indicators/${NAME}.mq5" ]]; then
  SUBDIR="Indicators"
elif [[ -f "$MT5_ROOT/Scripts/${NAME}.mq5" ]]; then
  SUBDIR="Scripts"
else
  echo "❌ Source not found under MT5 MQL5 folders: ${NAME}.mq5"
  echo "Checked: $MT5_ROOT/Experts, $MT5_ROOT/Indicators, $MT5_ROOT/Scripts"
  exit 1
fi

WIN_SRC="$WIN_MT5_ROOT\\${SUBDIR}\\${NAME}.mq5"
LOG_FILE="$MT5_ROOT/${SUBDIR}/${NAME}.log"
EX5_FILE="$MT5_ROOT/${SUBDIR}/${NAME}.ex5"

# Step 2: Compile
echo "Step 2/3: Compiling..."

# MetaEditor CLI invocation from WSL can fail due to UNC working dir issues.
# Workaround: run a tiny .bat from a Windows-local path and parse the generated .log.
WIN_USER_MNT="/mnt/c/Users/Admin"
if [[ ! -d "$WIN_USER_MNT" ]]; then
  # Fallback: pick first user folder (best-effort)
  WIN_USER_MNT="$(ls -d /mnt/c/Users/* 2>/dev/null | head -1 || true)"
fi

if [[ -z "${WIN_USER_MNT:-}" || ! -d "$WIN_USER_MNT" ]]; then
  echo "❌ Could not locate a Windows user directory under /mnt/c/Users"
  exit 1
fi

BAT_MNT="$WIN_USER_MNT/.mql5_compile_${NAME}.bat"
BAT_WIN="$(echo "$BAT_MNT" | sed 's|^/mnt/c/|C:\\|' | sed 's|/|\\\\|g')"

# Write batch content (no dependency on cmd quoting)
cat > "/tmp/.mql5_compile_${NAME}.bat" <<EOF
@echo off
cd /d "C:\\Program Files\\FTMO MetaTrader 5"
MetaEditor64.exe /compile:"$WIN_SRC" /log
exit /b %errorlevel%
EOF

cp "/tmp/.mql5_compile_${NAME}.bat" "$BAT_MNT"

# Run compilation (MetaEditor may return non-zero even on success; rely on log)
"$CMD_EXE" /c "$BAT_WIN" >/dev/null 2>&1 || true

# Wait for log to be written and include Result line
for i in $(seq 1 25); do
  if [[ -f "$LOG_FILE" ]]; then
    if iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | tr -d '\r' | grep -q "^Result:"; then
      break
    fi
  fi
  sleep 0.4
done

# Step 3: Report
echo "Step 3/3: Reading results..."
echo ""

if [[ -f "$LOG_FILE" ]]; then
  LOG_CONTENT=$(iconv -f UTF-16LE -t UTF-8 "$LOG_FILE" 2>/dev/null | tr -d '\r')
  ERRORS=$(echo "$LOG_CONTENT" | grep -c ": error" || true)
  WARNINGS=$(echo "$LOG_CONTENT" | grep -c ": warning" || true)
  ERRORS=${ERRORS:-0}
  WARNINGS=${WARNINGS:-0}

  echo "=========================================="
  if [[ "$ERRORS" -gt 0 ]]; then
    echo "❌ BUILD FAILED: $ERRORS error(s), $WARNINGS warning(s)"
    echo "=========================================="
    echo ""
    echo "ERRORS:"
    echo "$LOG_CONTENT" | grep ": error" | head -50
    echo ""
    if [[ "$WARNINGS" -gt 0 ]]; then
      echo "WARNINGS:"
      echo "$LOG_CONTENT" | grep ": warning" | head -20
      echo ""
    fi
    exit 1
  fi

  echo "✅ BUILD SUCCESSFUL: 0 errors, $WARNINGS warning(s)"
  echo "=========================================="
  if [[ "$WARNINGS" -gt 0 ]]; then
    echo ""
    echo "WARNINGS:"
    echo "$LOG_CONTENT" | grep ": warning" | head -50
  fi
  echo ""
  if [[ -f "$EX5_FILE" ]]; then
    echo "Output: $EX5_FILE"
  else
    echo "⚠️  Output .ex5 not found at: $EX5_FILE"
  fi

  exit 0
else
  echo "⚠️  Log file not found: $LOG_FILE"
  echo "Compilation may not have run (or MetaEditor is blocked)."
  exit 1
fi
