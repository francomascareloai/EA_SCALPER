# BUGFIX LOG — Analysis Modules

## 2025-12-01
- RegimeDetector: `AnalyzeRegime` agora usa timeframe passado em `tf` (não força `PERIOD_CURRENT`).
- MTFManager: removida heurística de OB/FVG para confluência; momentum M5 agora checa disponibilidade via `CopyClose` antes de calcular.
- StructureAnalyzer: ordem corrigida (bias -> breaks -> bias) para BOS/CHoCH; reset de estado por timeframe em análise MTF.
- FootprintAnalyzer: diagonal buy imbalance corrigida (Ask[i] vs Bid[i-1]); handle ATR validado; downsample relaxado; absorção classificada pelo delta.
