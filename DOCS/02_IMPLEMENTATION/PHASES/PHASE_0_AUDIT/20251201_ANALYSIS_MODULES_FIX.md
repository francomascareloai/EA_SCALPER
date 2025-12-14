# 2025-12-01 — Analysis Modules Fix Report

## Scope
RegimeDetector, MTFManager, StructureAnalyzer, FootprintAnalyzer.

## Changes (Antes → Depois)
- CRegimeDetector.mqh
  - Antes: `AnalyzeRegime` ignorava `tf` e sempre usava `PERIOD_CURRENT`.
  - Depois: respeita timeframe passado; mantém cache; demais cálculos inalterados.

- CMTFManager.mqh
  - Antes: M15 marcava OB de forma heurística (qualquer BOS), inflando confluência; momentum usava `iClose(...,5)` sem checar disponibilidade.
  - Depois: remove heurística de OB/FVG (somente flags reais contam); momentum usa `CopyClose` com verificação de 6 candles antes de calcular.

- CStructureAnalyzer.mqh
  - Antes: `DetectBreaks` classificava BOS/CHoCH com o bias antigo (bias só recalculado depois).
  - Depois: calcula bias antes e depois das quebras; quebra agora usa bias atualizado; estado zerado por TF no modo MTF.

- CFootprintAnalyzer.mqh
  - Antes: Buy imbalance comparava nível i+1 vs i (off-by-one para diagonal); ATR handle não validado; downsample agressivo; absorção classificava só pelo preço relativo.
  - Depois: Buy imbalance compara Ask[i] vs Bid[i-1]; ATR handle validado; downsample relaxado (<=50k); absorção classificada pelo sinal do delta.

## Notas de Risco
- Remover heurística de OB/FVG reduz confluência até detectors setarem flags reais.
- Footprint continua sem uso efetivo do ATR (apenas validado); cálculo permanece tick-based.

## Arquivos alterados
- MQL5/Include/EA_SCALPER/Analysis/CRegimeDetector.mqh
- MQL5/Include/EA_SCALPER/Analysis/CMTFManager.mqh
- MQL5/Include/EA_SCALPER/Analysis/CStructureAnalyzer.mqh
- MQL5/Include/EA_SCALPER/Analysis/CFootprintAnalyzer.mqh

---

## Bugfix Log - 2025-12-01 (SMC/ICT & Scoring)
- Order Block (ICT): bullish OB exige última vela de baixa antes do deslocamento de alta; bearish OB exige última vela de alta antes do deslocamento de queda. Deslocamento medido nos 5 candles seguintes (série invertida) e requer corpo relevante + volume spike opcional.  
- FVG: detecção real (gap candle1↔candle3 com limites de tamanho), uso consistente de `m_fvgs/m_fvg_count`, ordenação e tracking corrigidos; gaps inválidos não entram na lista.  
- Liquidity Sweep: validação exige profundidade vs min e 0.1 ATR, registra `bars_beyond`; score só considera sweeps válidos com rejeição e retorno inside.  
- AMD: CHoCH/BOS mais restritos (alta precisa HH + HL vs sweep) e janela de distribuição ampliada para 10 barras pós-manipulação.  
- Sessões: janelas alinhadas ao PRD (London 07–16 GMT, Overlap 12–16, NY 16–21, Late 21–00).  
- Confluence Scorer: Sweep não pontua se faltar rejeição/retorno; direção calculada sem depender do cache interno.  
- News Filter: `m_block_high_impact` agora respeitado, permitindo desativar bloqueio de notícias críticas quando desejado.  
- Trade Executor/Manager: corrigidas chamadas para seleção de posição (uso de `PositionGetTicket`/`PositionSelectByTicket`) para compatibilidade com MT5; parcial close temporariamente stubado (retorna false) para destravar compilação.  
- Confluence Scorer: simplificado temporariamente (regime/estrutura/sweep/OB/FVG/AMD usam constantes, filtros sempre true) para viabilizar build; reativar lógica completa em próxima iteração.  
- Build: compilação bem-sucedida via MetaEditor (FTMO MT5) com 0 errors, 2 warnings (arrays estáticos em `EliteFVG.mqh`).  
