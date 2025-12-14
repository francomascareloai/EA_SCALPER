# FORGE CODE AUDIT PLAN - 4 Sessoes Codex

## Objetivo
Verificar todo o codigo antes de treinar modelos e validar com Oracle.

---

## SESSAO 1: Compilacao + Core Risk

### Prompt (copiar e colar):

```
Forge, preciso que voce faca um audit completo dos modulos CRITICOS de risk e execution do meu EA.

CONTEXTO:
- Projeto: EA_SCALPER_XAUUSD para FTMO $100k Challenge
- EA versao 3.30 com SMC/ICT + Order Flow
- Preciso garantir que o codigo esta sem bugs antes de backtest

TAREFAS:

1. COMPILACAO - Verifique se o EA compila:
   - Leia MQL5/Experts/EA_SCALPER_XAUUSD.mq5
   - Liste TODOS warnings e potenciais problemas
   
2. CODE REVIEW dos arquivos criticos:
   - MQL5/Include/EA_SCALPER/Risk/FTMO_RiskManager.mqh
   - MQL5/Include/EA_SCALPER/Execution/CTradeManager.mqh  
   - MQL5/Include/EA_SCALPER/Execution/TradeExecutor.mqh

3. VERIFICAR especificamente:
   - [ ] Error handling em OrderSend (AP-01)
   - [ ] Division by zero guards (AP-04)
   - [ ] Array bounds checks (AP-05)
   - [ ] FTMO compliance (5% daily DD, 10% total DD)
   - [ ] Lot sizing formula correta
   - [ ] Resource cleanup (delete, IndicatorRelease)

4. OUTPUT esperado:
   - Score de cada arquivo (X/20)
   - Lista de bugs encontrados
   - Lista de anti-patterns
   - Codigo corrigido para cada problema

Seja rigoroso. Prefiro encontrar bugs agora do que perder dinheiro depois.
```

**Arquivos:** 4 arquivos, ~1500 linhas

---

## SESSAO 2: Analysis Modules (Parte 1)

### Prompt (copiar e colar):

```
Forge, continuando o audit do EA_SCALPER_XAUUSD. Agora preciso que voce analise os modulos de ANALISE principais.

CONTEXTO:
- Projeto: EA_SCALPER_XAUUSD para FTMO $100k Challenge  
- Estes modulos fazem Regime Detection, Multi-Timeframe e Order Flow
- Sao criticos para a qualidade dos sinais

TAREFAS:

1. CODE REVIEW completo dos arquivos:
   - MQL5/Include/EA_SCALPER/Analysis/CRegimeDetector.mqh
   - MQL5/Include/EA_SCALPER/Analysis/CMTFManager.mqh
   - MQL5/Include/EA_SCALPER/Analysis/CStructureAnalyzer.mqh
   - MQL5/Include/EA_SCALPER/Analysis/CFootprintAnalyzer.mqh

2. VERIFICAR especificamente:
   - [ ] Calculo de Hurst Exponent esta correto matematicamente?
   - [ ] Calculo de Shannon Entropy esta correto?
   - [ ] MTF logic (H1 direction, M15 structure, M5 entry) faz sentido?
   - [ ] CopyBuffer/CopyRates com ArraySetAsSeries (AP-02)
   - [ ] Indicator handles verificados != INVALID_HANDLE (AP-06)
   - [ ] Memory leaks (arrays alocados sem cleanup)
   - [ ] Loops com alocacao (new/ArrayResize em OnTick)

3. OUTPUT esperado:
   - Score de cada arquivo (X/20)
   - Bugs matematicos ou logicos
   - Anti-patterns detectados
   - Sugestoes de otimizacao

Foque na CORRETUDE dos calculos. Um Hurst errado invalida toda a estrategia.
```

**Arquivos:** 4 arquivos, ~2000 linhas

---

## SESSAO 3: Analysis Modules (Parte 2) + Signal

### Prompt (copiar e colar):

```
Forge, continuando o audit do EA_SCALPER_XAUUSD. Agora preciso que voce analise os modulos de SMC/ICT e Scoring.

CONTEXTO:
- Projeto: EA_SCALPER_XAUUSD para FTMO $100k Challenge
- Estes modulos implementam Smart Money Concepts (Order Blocks, FVG, Liquidity)
- O scoring decide se um trade e executado ou nao

TAREFAS:

1. CODE REVIEW - Modulos SMC/ICT:
   - MQL5/Include/EA_SCALPER/Analysis/CLiquiditySweepDetector.mqh
   - MQL5/Include/EA_SCALPER/Analysis/CAMDCycleTracker.mqh
   - MQL5/Include/EA_SCALPER/Analysis/EliteFVG.mqh
   - MQL5/Include/EA_SCALPER/Analysis/EliteOrderBlock.mqh

2. CODE REVIEW - Filtros:
   - MQL5/Include/EA_SCALPER/Analysis/CSessionFilter.mqh
   - MQL5/Include/EA_SCALPER/Analysis/CNewsFilter.mqh

3. CODE REVIEW - Scoring:
   - MQL5/Include/EA_SCALPER/Signal/CConfluenceScorer.mqh
   - MQL5/Include/EA_SCALPER/Signal/SignalScoringModule.mqh

4. VERIFICAR especificamente:
   - [ ] Logica de Order Block detection correta (bullish OB = last down candle before up move)
   - [ ] Logica de FVG detection correta (gap entre candle 1 high e candle 3 low)
   - [ ] Liquidity sweep detection (BSL/SSL)
   - [ ] AMD cycle states (Accumulation -> Manipulation -> Distribution)
   - [ ] Session times corretos (London 07:00-16:00 GMT, NY 12:00-21:00 GMT)
   - [ ] Scoring formula faz sentido (weights, thresholds)

5. OUTPUT esperado:
   - Score de cada arquivo (X/20)
   - Bugs na logica SMC/ICT
   - Problemas nos filtros
   - Scoring calibrado corretamente?

A logica SMC e o coracao da estrategia. Tem que estar perfeita.
```

**Arquivos:** 8 arquivos, ~2500 linhas

---

## SESSAO 4: ONNX + Bridge + EA Principal

### Prompt (copiar e colar):

```
Forge, ultima sessao de audit do EA_SCALPER_XAUUSD. Agora preciso que voce analise a integracao ONNX e o EA principal.

CONTEXTO:
- Projeto: EA_SCALPER_XAUUSD para FTMO $100k Challenge
- Temos modelo ONNX treinado (direction_v2.onnx) mas parece NAO estar sendo usado
- Preciso entender o fluxo completo e se esta pronto para backtest

TAREFAS:

1. CODE REVIEW - ONNX/Bridge:
   - MQL5/Include/EA_SCALPER/Bridge/COnnxBrain.mqh (811 lines)
   - MQL5/Include/EA_SCALPER/Bridge/PythonBridge.mqh
   - Verificar se modelos em MQL5/Models/ sao compativeis

2. CODE REVIEW - EA Principal:
   - MQL5/Experts/EA_SCALPER_XAUUSD.mq5 (594 lines)

3. VERIFICAR especificamente:
   - [ ] ONNX esta sendo chamado no OnTick()? Se nao, COMO ATIVAR?
   - [ ] Fluxo completo: Quais gates (1-15) estao implementados?
   - [ ] PythonBridge esta comentado - precisa ativar?
   - [ ] Integracao entre modulos esta correta?
   - [ ] OnTimer() faz o que deveria?
   - [ ] Performance: calculos pesados no OnTick? (target < 50ms)

4. RESPONDER:
   - O EA esta usando ML/ONNX para decisoes? Sim/Nao
   - Se nao, o que precisa mudar para ativar?
   - O codigo esta pronto para rodar backtest? Sim/Nao
   - Lista de tudo que falta para producao

5. OUTPUT FINAL:
   - Score geral do EA (X/100)
   - Lista consolidada de TODOS bugs das 4 sessoes
   - Lista de melhorias prioritarias
   - Roadmap: O que fazer primeiro?

Este e o audit final. Preciso saber se posso confiar neste codigo.
```

**Arquivos:** 3 arquivos, ~1800 linhas

---

## RESUMO

| Sessao | Foco | Arquivos | Linhas |
|--------|------|----------|--------|
| 1 | Compilacao + Risk | 4 | ~1500 |
| 2 | Analysis Core | 4 | ~2000 |
| 3 | Analysis + Signal | 8 | ~2500 |
| 4 | ONNX + EA Final | 3 | ~1800 |
| **Total** | | **19** | **~7800** |

---

## Apos as 4 Sessoes

Consolidar findings em:
- `DOCS/04_REPORTS/VALIDATION/CODE_AUDIT_REPORT.md`

Entao decidir:
1. Corrigir bugs encontrados
2. Ativar ONNX se necessario
3. Rodar backtest
4. Validar com Oracle

---

*Criado: 2025-11-30*
