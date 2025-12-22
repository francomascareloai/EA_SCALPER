#!/bin/bash
# Limpeza rápida - apenas itens 100% seguros

PROJECT_ROOT="$HOME/projetos/EA_SCALPER_XAUUSD"

echo "╔════════════════════════════════════════════════════════╗"
echo "║        LIMPEZA RÁPIDA (100% SEGURA) - WSL             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "Espaço ANTES da limpeza:"
df -h / | tail -1
du -sh "$PROJECT_ROOT"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Telemetry
if [ -f "$PROJECT_ROOT/logs/telemetry.jsonl" ]; then
    SIZE=$(du -sh "$PROJECT_ROOT/logs/telemetry.jsonl" | cut -f1)
    echo "✓ Limpando logs/telemetry.jsonl ($SIZE)..."
    rm -f "$PROJECT_ROOT/logs/telemetry.jsonl"
fi

# 2. Backups bundle
if ls "$PROJECT_ROOT"/EA_SCALPER_XAUUSD_backup_*.bundle 1> /dev/null 2>&1; then
    SIZE=$(du -sh "$PROJECT_ROOT"/EA_SCALPER_XAUUSD_backup_*.bundle 2>/dev/null | awk '{s+=$1} END {print s"M"}')
    echo "✓ Limpando backups .bundle ($SIZE)..."
    rm -f "$PROJECT_ROOT"/EA_SCALPER_XAUUSD_backup_*.bundle
fi

# 3. Temp CLIPROXY
if [ -d "$PROJECT_ROOT/temp_CLIPROXYAPIPlus" ] || [ -d "$PROJECT_ROOT/temp_CLIPROXYAPIPlus_new" ]; then
    echo "✓ Limpando temp_CLIPROXYAPIPlus..."
    rm -rf "$PROJECT_ROOT/temp_CLIPROXYAPIPlus" "$PROJECT_ROOT/temp_CLIPROXYAPIPlus_new"
fi

# 4. __pycache__
echo "✓ Limpando __pycache__..."
find "$PROJECT_ROOT" -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true

# 5. Grid search logs
if ls "$PROJECT_ROOT/logs/grid_search_"* 1> /dev/null 2>&1; then
    echo "✓ Limpando logs grid_search..."
    find "$PROJECT_ROOT/logs" -name 'grid_search_*' -type f -delete 2>/dev/null || true
fi

# 6. Logs grandes (>10MB)
echo "✓ Limpando logs grandes (>10MB)..."
find "$PROJECT_ROOT/logs" -name '*.log' -type f -size +10M -delete 2>/dev/null || true

# 7. Debug logs
if [ -f "$PROJECT_ROOT/logs/debug_run.log" ]; then
    SIZE=$(du -sh "$PROJECT_ROOT/logs/debug_run.log" | cut -f1)
    if [ "$SIZE" != "0" ]; then
        echo "✓ Limpando debug_run.log ($SIZE)..."
        > "$PROJECT_ROOT/logs/debug_run.log"
    fi
fi

# 8. Combined log
if [ -f "$PROJECT_ROOT/logs/combined.log" ]; then
    SIZE=$(du -sh "$PROJECT_ROOT/logs/combined.log" | cut -f1)
    if [ "$SIZE" != "0" ]; then
        echo "✓ Limpando combined.log ($SIZE)..."
        > "$PROJECT_ROOT/logs/combined.log"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ LIMPEZA CONCLUÍDA!"
echo ""

echo "Espaço DEPOIS da limpeza:"
df -h / | tail -1
du -sh "$PROJECT_ROOT"
echo ""

echo "💡 PRÓXIMOS PASSOS:"
echo ""
echo "1. Se quiser limpar mais (29GB ML data, 58GB catálogos):"
echo "   ./cleanup_disk_space.sh"
echo ""
echo "2. Para liberar espaço no Windows C:\, compactar VHDX:"
echo "   - Abra PowerShell como Administrador no Windows"
echo "   - Execute: cd C:\Users\franco\projetos\EA_SCALPER_XAUUSD"
echo "   - Execute: .\compact-wsl-vhdx.ps1"
echo ""
