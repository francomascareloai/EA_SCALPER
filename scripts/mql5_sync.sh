#!/bin/bash
# MQL5 Sync Script - Syncs MQL5 files from WSL project to MT5 installation
# Usage: ./scripts/mql5_sync.sh [--dry-run]
#
# Source: MQL5/ (WSL project - source of truth)
# Target: /mnt/c/Program Files/FTMO MetaTrader 5/MQL5/ (appears in MetaEditor)

set -e

# Configuration
WSL_MQL5="/home/franco/projetos/EA_SCALPER_XAUUSD/MQL5"
MT5_MQL5="/mnt/c/Program Files/FTMO MetaTrader 5/MQL5"

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "=== DRY RUN MODE ==="
fi

echo "=========================================="
echo "MQL5 Sync: WSL → MT5 FTMO"
echo "=========================================="
echo "Source: $WSL_MQL5"
echo "Target: $MT5_MQL5"
echo ""

# Function to sync a directory
sync_dir() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [[ ! -d "$src" ]]; then
        echo "⚠️  Skip $name (source not found)"
        return
    fi

    # Count files
    local count=$(find "$src" -type f \( -name "*.mq5" -o -name "*.mqh" \) | wc -l)

    if $DRY_RUN; then
        echo "📁 Would sync $name ($count files)"
        echo "   From: $src"
        echo "   To:   $dst"
    else
        echo "📁 Syncing $name ($count files)..."
        mkdir -p "$dst"
        # Note: NO --delete flag to preserve other MT5 files
        rsync -av \
            --include='*.mq5' \
            --include='*.mqh' \
            --include='*.md' \
            --include='*/' \
            --exclude='*.ex5' \
            --exclude='*.log' \
            "$src/" "$dst/"
    fi
}

# Sync Experts
sync_dir "$WSL_MQL5/Experts" "$MT5_MQL5/Experts" "Experts"

# Sync Indicators
sync_dir "$WSL_MQL5/Indicators" "$MT5_MQL5/Indicators" "Indicators"

# Sync Scripts
sync_dir "$WSL_MQL5/Scripts" "$MT5_MQL5/Scripts" "Scripts"

# Sync Include/EA_SCALPER (our custom includes)
sync_dir "$WSL_MQL5/Include/EA_SCALPER" "$MT5_MQL5/Include/EA_SCALPER" "Include/EA_SCALPER"

# Sync Models (ONNX)
if [[ -d "$WSL_MQL5/Models" ]]; then
    if $DRY_RUN; then
        echo "📁 Would sync Models"
    else
        echo "📁 Syncing Models..."
        mkdir -p "$MT5_MQL5/Models"
        rsync -av "$WSL_MQL5/Models/" "$MT5_MQL5/Models/"
    fi
fi

echo ""
echo "=========================================="
if $DRY_RUN; then
    echo "DRY RUN complete. Run without --dry-run to sync."
else
    echo "✅ Sync complete!"
    echo ""
    echo "Files are now visible in MetaEditor."
    echo "Press F5 in MetaEditor to refresh Navigator."
fi
echo "=========================================="
