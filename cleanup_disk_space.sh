#!/bin/bash
# Script de limpeza interativa

PROJECT_ROOT="$HOME/projetos/EA_SCALPER_XAUUSD"

echo "╔════════════════════════════════════════════════════════╗"
echo "║     LIMPEZA DE ESPAÇO WSL - EA_SCALPER_XAUUSD         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "ANÁLISE ENCONTRADA:"
echo ""
echo "📊 Total usado: 119GB"
echo ""
echo "🔥 MAIORES CONSUMIDORES:"
echo "   1. Python_Agent_Hub/ml_pipeline/data/  - 29GB"
echo "   2. data/catalog_native_sessions/       - 22GB"
echo "   3. data/catalog_native/                - 22GB"
echo "   4. data/session_csvs/                  - 14GB"
echo "   5. tools/g3/                           - 4.7GB"
echo "   6. logs/telemetry.jsonl                - 2.8GB"
echo "   7. Backups .bundle                     - 2.4GB"
echo "   8. nautilus_gold_scalper/              - 2.4GB"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "OPÇÕES DE LIMPEZA RÁPIDA (seguras):"
echo ""
read -p "1. Limpar logs/telemetry.jsonl (2.8GB)? (s/N): " opt1
if [[ "$opt1" =~ ^[sS] ]]; then
    rm -f "$PROJECT_ROOT/logs/telemetry.jsonl"
    echo "✓ Telemetry limpo (2.8GB)"
fi

read -p "2. Limpar backups .bundle (2.4GB)? (s/N): " opt2
if [[ "$opt2" =~ ^[sS] ]]; then
    rm -f "$PROJECT_ROOT"/EA_SCALPER_XAUUSD_backup_*.bundle
    echo "✓ Backups limpos (2.4GB)"
fi

read -p "3. Limpar temp_CLIPROXYAPIPlus* (116MB)? (s/N): " opt3
if [[ "$opt3" =~ ^[sS] ]]; then
    rm -rf "$PROJECT_ROOT/temp_CLIPROXYAPIPlus" "$PROJECT_ROOT/temp_CLIPROXYAPIPlus_new"
    echo "✓ Temp CLIPROXY limpo (116MB)"
fi

read -p "4. Limpar __pycache__ (5MB)? (s/N): " opt4
if [[ "$opt4" =~ ^[sS] ]]; then
    find "$PROJECT_ROOT" -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
    echo "✓ __pycache__ limpo (5MB)"
fi

read -p "5. Limpar logs de grid_search (10MB)? (s/N): " opt5
if [[ "$opt5" =~ ^[sS] ]]; then
    find "$PROJECT_ROOT/logs" -name 'grid_search_*' -type f -delete
    echo "✓ Grid search logs limpos (10MB)"
fi

read -p "6. Limpar tools/g3 (4.7GB)? (s/N): " opt6
if [[ "$opt6" =~ ^[sS] ]]; then
    rm -rf "$PROJECT_ROOT/tools/g3"
    echo "✓ tools/g3 limpo (4.7GB)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  OPÇÕES AVANÇADAS (CUIDADO!):"
echo ""

read -p "7. Ver detalhes de ml_pipeline/data (29GB)? (s/N): " opt7
if [[ "$opt7" =~ ^[sS] ]]; then
    echo ""
    echo "Conteúdo de ml_pipeline/data/:"
    du -sh "$PROJECT_ROOT/Python_Agent_Hub/ml_pipeline/data/"* 2>/dev/null | sort -rh | head -15
    echo ""
    read -p "   Deletar TUDO em ml_pipeline/data? Digite 'DELETE' para confirmar: " confirm
    if [ "$confirm" = "DELETE" ]; then
        rm -rf "$PROJECT_ROOT/Python_Agent_Hub/ml_pipeline/data/"*
        echo "   ✓ ml_pipeline/data limpo (29GB)"
    else
        echo "   Cancelado"
    fi
fi

read -p "8. Ver detalhes de catálogos data/ (58GB)? (s/N): " opt8
if [[ "$opt8" =~ ^[sS] ]]; then
    echo ""
    echo "Catálogos encontrados:"
    echo "  - catalog_native:          $(du -sh "$PROJECT_ROOT/data/catalog_native" 2>/dev/null | cut -f1)"
    echo "  - catalog_native_sessions: $(du -sh "$PROJECT_ROOT/data/catalog_native_sessions" 2>/dev/null | cut -f1)"
    echo "  - session_csvs:            $(du -sh "$PROJECT_ROOT/data/session_csvs" 2>/dev/null | cut -f1)"
    echo ""
    echo "Opções:"
    echo "  a) Deletar catalog_native_sessions + session_csvs (36GB)"
    echo "  b) Deletar catalog_native + catalog_native_sessions (44GB)"
    echo "  c) Deletar TODOS (58GB - PERIGOSO!)"
    echo "  n) Cancelar"
    read -p "Escolha (a/b/c/n): " catalog_opt
    case $catalog_opt in
        a|A)
            rm -rf "$PROJECT_ROOT/data/catalog_native_sessions" "$PROJECT_ROOT/data/session_csvs"
            echo "✓ 36GB liberados (mantido catalog_native)"
            ;;
        b|B)
            rm -rf "$PROJECT_ROOT/data/catalog_native" "$PROJECT_ROOT/data/catalog_native_sessions"
            echo "✓ 44GB liberados (mantido session_csvs)"
            ;;
        c|C)
            read -p "TEM CERTEZA? Digite 'DELETE_ALL': " confirm_all
            if [ "$confirm_all" = "DELETE_ALL" ]; then
                rm -rf "$PROJECT_ROOT/data/catalog_native" "$PROJECT_ROOT/data/catalog_native_sessions" "$PROJECT_ROOT/data/session_csvs"
                echo "✓ 58GB liberados"
            else
                echo "Cancelado"
            fi
            ;;
        *)
            echo "Cancelado"
            ;;
    esac
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                  LIMPEZA CONCLUÍDA                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Espaço atual:"
df -h / | tail -1
echo ""
echo "Tamanho do projeto:"
du -sh "$PROJECT_ROOT"
echo ""
