# MASTER EXECUTION PLAN v5.2 - UNIFIED GENIUS EDITION
## EA_SCALPER_XAUUSD - Do Código ao Challenge FTMO

**Criado**: 2025-12-01
**Atualizado**: 2025-12-01
**Versão**: 5.2 FINAL - Audited Infrastructure Edition
**Filosofia**: "Build what's missing, validate what exists, maximize edge"

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MUDANÇA CRÍTICA v5.2                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  AUDITORIA REVELOU: Muitos scripts JÁ EXISTEM!                             │
│                                                                             │
│  ANTES (v5.1):  "19 scripts a criar"                                       │
│  DEPOIS (v5.2): "10 criar + 8 estender + 8 prontos"                        │
│                                                                             │
│  Scripts Oracle existentes com 3,000+ linhas de código:                    │
│  - walk_forward.py (398 linhas) ✅                                         │
│  - monte_carlo.py (486 linhas) ✅                                          │
│  - go_nogo_validator.py (570 linhas) ✅                                    │
│  - deflated_sharpe.py (271 linhas) ✅                                      │
│  - tick_backtester.py (1014 linhas) ✅                                     │
│  - validate_data.py (733 linhas) ✅ → scripts/oracle/                      │
│                                                                             │
│  ECONOMIA: ~30-40 horas de desenvolvimento já feito!                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## DADOS DISPONÍVEIS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        TICK DATA & BAR DATA                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  LOCALIZAÇÃO: Python_Agent_Hub/ml_pipeline/data/                           │
│                                                                             │
│  TICK DATA (usar para backtest de alta precisão):                          │
│  ├── XAUUSD_ftmo_all_desde_2003.csv                │ 24.8 GB │ 2003-2025 │ PRINCIPAL │
│  ├── CSV(comSPREAD)2020-2025XAUUSD_ftmo-TICK-No Session.csv │ 15.0 GB │ 2020-2025 │ COM SPREAD │
│  └── XAUUSD_ftmo_2020_ticks_dukascopy.csv          │ 12.1 GB │ 2020-2025 │ MAiS CURTo   │
│                                                                              │
│  PARQUET GERADO (data/processed/ticks_YYYY.parquet):                         │
│  - Colunas: timestamp (ns), bid, ask, volume, spread (cents), mid_price      │
│  - Leitura por ano/mês (evitar lookahead): 2020-2024 = treino/validação; 2025 = holdout │
│  - Spread no CSV está em USD; no Parquet está em cents (calculado como (Ask-Bid)*100)   │
│                                                                             │
│  BAR DATA (usar para validação MTF e features):                            │
│  ├── Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv  │ 22.6 MB │ M5          │
│  ├── bars-2020-2025XAUUSD_ftmo-M15-No Session.csv │  7.6 MB │ M15         │
│  ├── bars-2020-2025XAUUSD_ftmo-H1-No Session.csv  │  1.9 MB │ H1          │
│  └── bars-2020-2025XAUUSD_ftmo-H4-No Session.csv  │  0.5 MB │ H4          │
│                                                                             │
│  FORMATO TICK CSV:                                                         │
│  timestamp,bid,ask,bid_volume,ask_volume                                   │
│  2020.01.02 00:00:00.123,1517.25,1517.75,100,150                           │
│                                                                             │
│  FORMATO BAR CSV:                                                          │
│  time,open,high,low,close,tick_volume,spread,real_volume                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## POLÍTICA DE JANELAS (ATUALIZADO)

- Holdout futuro: 2025 exclusivo para validação final (não treinar/calibrar).
- Iteração rápida: 6–9 meses recentes (ex.: 2024-06 a 2025-02) para smoke de lógica/latência.
- Calibração principal: 2023–2024 (2 anos) para parâmetros iniciais.
- WFA robusto: 2020–2024 com janelas rolling (ex.: 18m treino / 6m teste) cobrindo regimes COVID/guerra/pico 2024.
- Unidade de spread: Parquets em cents (Ask-Bid)*100; scripts devem usar essa unidade ou recalcular de bid/ask.

---

## DIAGRAMA DE DEPENDÊNCIAS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FLUXO DE DADOS ENTRE SCRIPTS                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FASE 1: DATA                                                              │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐  │
│  │ XAUUSD_ftmo_all  │─────▶│ convert_tick.py  │─────▶│ data/processed/  │  │
│  │    (24.8 GB)     │      │                  │      │ - ticks.parquet  │  │
│  └──────────────────┘      └──────────────────┘      │ - ticks_chunks/  │  │
│                                   │                  └────────┬─────────┘  │
│                                   ▼                           │            │
│                            ┌──────────────────┐               │            │
│                            │ validate_data.py │◀──────────────┘            │
│                            └────────┬─────────┘                            │
│                                     │                                      │
│                                     ▼                                      │
│                            DATA_QUALITY_GENIUS.md                          │
│                                                                             │
│  FASE 2: BACKTEST                                                          │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐  │
│  │ data/processed/  │─────▶│ segment_data.py  │─────▶│ data/segments/   │  │
│  │                  │      │                  │      │ - trending.pq    │  │
│  └──────────────────┘      └──────────────────┘      │ - reverting.pq   │  │
│                                                      │ - by_session.pq  │  │
│                                                      └────────┬─────────┘  │
│                                                               │            │
│                                                               ▼            │
│                                                      ┌──────────────────┐  │
│                                                      │tick_backtester.py│  │
│                                                      │ + kelly_collect  │  │
│                                                      │ + convexity      │  │
│                                                      └────────┬─────────┘  │
│                                                               │            │
│                                                               ▼            │
│                                              KELLY_TABLE.md + BACKTEST.md  │
│                                                                             │
│  FASE 3: ML                                                                │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐  │
│  │ data/segments/   │─────▶│feature_engineer.py│────▶│ data/features/   │  │
│  │ + bar data       │      │                  │      │ features.parquet │  │
│  └──────────────────┘      └──────────────────┘      └────────┬─────────┘  │
│                                                               │            │
│                                                               ▼            │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐  │
│  │  train_wfa.py    │─────▶│  export_onnx.py  │─────▶│ direction.onnx   │  │
│  │                  │      │                  │      │ scaler_params    │  │
│  └──────────────────┘      └──────────────────┘      └──────────────────┘  │
│                                                                             │
│  FASE 4: SHADOW                                                            │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐  │
│  │ data/processed/  │─────▶│shadow_exchange.py│─────▶│ shadow_results/  │  │
│  │ + ea_logic.py    │      │ (EVT latency)    │      │ divergence.md    │  │
│  └──────────────────┘      └──────────────────┘      └──────────────────┘  │
│                                                                             │
│  FASE 5: ORACLE                                                            │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐  │
│  │ backtest trades  │─────▶│walk_forward.py   │─────▶│ WFA_REPORT.md    │  │
│  │                  │      │monte_carlo_evt.py│      │ MC_REPORT.md     │  │
│  │                  │      │cpcv.py           │      │ PBO_REPORT.md    │  │
│  │                  │      │edge_stability.py │      │ EDGE_REPORT.md   │  │
│  └──────────────────┘      └──────────────────┘      └────────┬─────────┘  │
│                                                               │            │
│                                                               ▼            │
│                                                      ┌──────────────────┐  │
│                                                      │go_nogo_genius.py │  │
│                                                      └────────┬─────────┘  │
│                                                               │            │
│                                                               ▼            │
│                                                      GO_NOGO_DECISION.md   │
│                                                                             │
│  FASE 6-8: STRESS → DEMO → FTMO                                            │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐  │
│  │stress_framework  │─────▶│live_edge_monitor │─────▶│   MT5 LIVE EA    │  │
│  └──────────────────┘      └──────────────────┘      └──────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## SUMÁRIO EXECUTIVO

Este plano unifica:
- **v2.0**: Estrutura prática (scripts, prompts, checkpoints)
- **v3.0**: 7 princípios GENIUS (Kelly, Convexity, Phase Transitions, Fractals, Information Theory, Ensemble, Tail Risk)
- **Código existente**: O que o EA JÁ TEM implementado

### O Que o EA JÁ TEM (Não Reimplementar!)

| Princípio | Já Implementado no EA | Onde |
|-----------|----------------------|------|
| **#1 Kelly** | ✅ Adaptive Kelly + 6-factor sizing | `FTMO_RiskManager.mqh` |
| **#2 Convexity** | ✅ Entry Optimizer + Partial TPs | `CEntryOptimizer.mqh`, `CTradeManager.mqh` |
| **#3 Phase Trans** | ✅ Transition probability + velocity | `CRegimeDetector.mqh` v4.0 |
| **#4 Fractals** | ✅ MTF alignment + multiplier | `CMTFManager.mqh` |
| **#5 Info Theory** | ✅ Shannon Entropy | `CRegimeDetector.mqh` |
| **#6 Ensemble** | ⚠️ Parcial (multi-factor scoring) | `CConfluenceScorer.mqh` |
| **#7 Tail Risk** | ⚠️ Parcial (MC exists, falta EVT) | `scripts/oracle/monte_carlo.py` |

---

## AUDITORIA DE SCRIPTS EXISTENTES (v5.2)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              AUDITORIA COMPLETA - 2025-12-01                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  DESCOBERTA CRÍTICA: Muitos scripts JÁ EXISTEM!                            │
│  O GAP analysis anterior estava DESATUALIZADO.                             │
│                                                                             │
│  RECLASSIFICAÇÃO:                                                          │
│  - CRIAR: Script não existe, precisa ser criado do zero                    │
│  - ESTENDER: Script existe, precisa de features GENIUS adicionais          │
│  - PRONTO: Script existe e está completo para o propósito                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Scripts Oracle EXISTENTES (scripts/oracle/)

| Script | Tamanho | Features Atuais | Extensão GENIUS Necessária | Status |
|--------|---------|-----------------|---------------------------|--------|
| `walk_forward.py` | 13KB (398 linhas) | Rolling WFA, Anchored, Purge gap, WFE, Verdict | WFE por regime × sessão | 🔄 ESTENDER |
| `monte_carlo.py` | 18KB (486 linhas) | Block Bootstrap, VaR, CVaR, FTMO probs, Confidence | **EVT com GPD para tails** | 🔄 ESTENDER |
| `deflated_sharpe.py` | 10KB (271 linhas) | PSR, DSR, MinTRL, p-value, overfitting detection | ✅ Completo | ✅ PRONTO |
| `go_nogo_validator.py` | 21KB (570 linhas) | Integra WFA+MC+PSR, PropFirm, Decision | **GENIUS 7-principle scoring** | 🔄 ESTENDER |
| `execution_simulator.py` | 16KB | Execution cost simulation | Latency model EVT | 🔄 ESTENDER |
| `prop_firm_validator.py` | 15KB | FTMO specific validation | ✅ Completo | ✅ PRONTO |
| `metrics.py` | 12KB | Sharpe, Sortino, Calmar, SQN | Kelly, Convexity | 🔄 ESTENDER |
| `mt5_trade_exporter.py` | 13KB | Trade export from MT5 | ✅ Completo | ✅ PRONTO |
| `confidence.py` | 16KB | Confidence scoring | ✅ Completo | ✅ PRONTO |
| `sample_data.py` | 14KB | Sample data generation with regimes | ✅ Completo | ✅ PRONTO |

### Scripts Backtest EXISTENTES (scripts/backtest/)

| Script | Tamanho | Features Atuais | Extensão GENIUS Necessária | Status |
|--------|---------|-----------------|---------------------------|--------|
| `tick_backtester.py` | 1014 linhas | Event-driven, Regime filter (Hurst), Session filter, FTMO limits, Execution modes | **Kelly collector, Convexity metrics** | 🔄 ESTENDER |
| `strategies.py` | ~500 linhas | Hurst regime, Session, Confluence scoring | Segment-aware outputs | 🔄 ESTENDER |
| `smc_components.py` | ~400 linhas | MarketBias, Order Blocks, FVG | ✅ Completo | ✅ PRONTO |

### Scripts Data/Validação EXISTENTES (scripts/oracle/ e scripts/)

| Script | Tamanho | Features Atuais | Extensão GENIUS Necessária | Status |
|--------|---------|-----------------|---------------------------|--------|
| `validate_data.py` | 733 linhas | Gap detection, Quality score, Period coverage, Streaming for large files | **Regime transitions, MTF consistency, Session coverage, Volatility clustering** | 🔄 ESTENDER |
| `convert_ticks_to_bars.py` | ~200 linhas | Tick → Bar conversion | ✅ Completo para bars | ✅ PRONTO |
| `convert_dukascopy_to_mt5.py` | ~150 linhas | Dukascopy format conversion | ✅ Completo | ✅ PRONTO |

### Scripts que REALMENTE FALTAM (CRIAR do zero)

| Script | Localização | Propósito | Prioridade | Bloqueador |
|--------|-------------|-----------|------------|------------|
| `convert_tick_data.py` | scripts/data/ | CSV 24GB → Parquet chunked | **CRÍTICA** | Bloqueia TUDO |
| `segment_data.py` | scripts/backtest/ | Segmentar por regime × sessão | **ALTA** | Bloqueia Kelly por segmento |
| `feature_engineering.py` | scripts/ml/ | 15 features para ONNX | **ALTA** | Bloqueia Phase 3 |
| `train_wfa.py` | scripts/ml/ | Treinar modelo com WFA | **ALTA** | Bloqueia ONNX |
| `export_onnx.py` | scripts/ml/ | Exportar modelo ONNX | **ALTA** | Bloqueia Phase 3 |
| `ea_logic_python.py` | scripts/backtest/strategies/ | Port da lógica do EA | **ALTA** | Bloqueia Shadow Exchange |
| `shadow_exchange.py` | scripts/backtest/ | Exchange emulator com EVT | **ALTA** | Bloqueia Phase 4 |
| `stress_framework.py` | scripts/oracle/ | 6 cenários de stress | **MÉDIA** | Bloqueia Phase 6 |
| `adaptive_kelly_sizer.py` | scripts/live/ | Kelly adaptativo live | **MÉDIA** | Bloqueia Phase 7 |
| `live_edge_monitor.py` | scripts/live/ | Monitor de edge em tempo real | **MÉDIA** | Bloqueia Phase 7 |

### RESUMO DA AUDITORIA

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONTAGEM FINAL                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ✅ PRONTOS (não precisam mudança):     8 scripts                          │
│  🔄 ESTENDER (existem, precisam GENIUS): 8 scripts                          │
│  🆕 CRIAR (não existem):                10 scripts                          │
│                                                                             │
│  TOTAL: 26 scripts no pipeline                                             │
│                                                                             │
│  ESFORÇO ESTIMADO:                                                         │
│  - CRIAR (10 scripts):    ~40-50 horas                                     │
│  - ESTENDER (8 scripts):  ~15-20 horas                                     │
│  - TOTAL:                 ~55-70 horas de desenvolvimento                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### O Que PRECISA Ser Implementado (ATUALIZADO)

| Componente | Tipo | Prioridade | Fase |
|------------|------|-----------|------|
| `convert_tick_data.py` | 🆕 CRIAR | **CRÍTICA** | 1 |
| EVT extension para `monte_carlo.py` | 🔄 ESTENDER | ALTA | 5 |
| Kelly/Convexity collectors para `tick_backtester.py` | 🔄 ESTENDER | ALTA | 2 |
| GENIUS scoring para `go_nogo_validator.py` | 🔄 ESTENDER | ALTA | 5 |
| Regime/Session validation para `validate_data.py` | 🔄 ESTENDER | ALTA | 1 |
| `segment_data.py` | 🆕 CRIAR | ALTA | 2 |
| `shadow_exchange.py` | 🆕 CRIAR | ALTA | 4 |
| WFE por segmento para `walk_forward.py` | 🔄 ESTENDER | MÉDIA | 5 |
| `feature_engineering.py` | 🆕 CRIAR | ALTA | 3 |
| `train_wfa.py` | 🆕 CRIAR | ALTA | 3 |
| `export_onnx.py` | 🆕 CRIAR | ALTA | 3 |
| `ea_logic_python.py` | 🆕 CRIAR | ALTA | 4 |
| `stress_framework.py` | 🆕 CRIAR | MÉDIA | 6 |
| `adaptive_kelly_sizer.py` | 🆕 CRIAR | MÉDIA | 7 |
| `live_edge_monitor.py` | 🆕 CRIAR | MÉDIA | 7 |

---

## MÉTRICAS FTMO ESPECÍFICAS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VALIDAÇÃO ESPECÍFICA FTMO $100k                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  LIMITES ABSOLUTOS (VIOLAÇÃO = CONTA TERMINADA):                           │
│  ├── Max Daily Loss:  5% ($5,000)                                          │
│  ├── Max Total Loss: 10% ($10,000)                                         │
│  └── Min Trading Days: 4 dias                                              │
│                                                                             │
│  BUFFERS DE SEGURANÇA (NOSSO SISTEMA):                                     │
│  ├── Soft Stop Daily:  4% ($4,000) → Reduz risk                            │
│  ├── Hard Stop Daily:  4.5% ($4,500) → Para trading                        │
│  ├── Soft Stop Total:  8% ($8,000) → Modo conservador                      │
│  └── Hard Stop Total:  9% ($9,000) → Para completamente                    │
│                                                                             │
│  MÉTRICAS A CALCULAR (Fase 5):                                             │
│                                                                             │
│  1. MinTRL (Minimum Track Record Length):                                  │
│     ┌─────────────────────────────────────────────────────────────────┐    │
│     │ MinTRL = (Z_α / target_sharpe)² × (1 + skew²/4 + kurt/8)       │    │
│     │                                                                 │    │
│     │ Onde:                                                           │    │
│     │ - Z_α = 1.96 para 95% de confiança                              │    │
│     │ - target_sharpe = Sharpe observado no backtest                  │    │
│     │ - skew = assimetria dos retornos                                │    │
│     │ - kurt = curtose dos retornos                                   │    │
│     │                                                                 │    │
│     │ SE trades_disponiveis < MinTRL → Resultados NÃO CONFIÁVEIS      │    │
│     └─────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  2. Probabilidades de Violação:                                            │
│     ├── P(Daily DD > 5%)  < 5%   → CRÍTICO                                 │
│     ├── P(Daily DD > 4%)  < 10%  → Buffer                                  │
│     ├── P(Total DD > 10%) < 2%   → CRÍTICO                                 │
│     └── P(Total DD > 8%)  < 5%   → Buffer                                  │
│                                                                             │
│  3. Profit Target Viability:                                               │
│     ├── P(alcançar 10% em 30 dias) > 50%                                   │
│     ├── Calculado via Monte Carlo com custos reais                         │
│     └── SE P < 50% → Estratégia pode não ser viável para FTMO              │
│                                                                             │
│  4. Métricas de Qualidade Adicionais:                                      │
│     ├── SQN (System Quality Number) >= 2.0                                 │
│     │   SQN = sqrt(N) × (avg_R / std_R)                                    │
│     ├── Sortino Ratio >= 2.0                                               │
│     │   Sortino = (Return - Rf) / Downside_Deviation                       │
│     ├── Calmar Ratio >= 3.0                                                │
│     │   Calmar = CAGR / Max_Drawdown                                       │
│     └── Recovery Factor >= 3.0                                             │
│         Recovery = Net_Profit / Max_Drawdown                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### WFE Thresholds por Regime

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WFE (Walk-Forward Efficiency) POR REGIME                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CONCEITO:                                                                 │
│  WFE = OOS_Performance / IS_Performance                                    │
│  WFE > 1.0 significa que OOS foi MELHOR que IS (raro, ideal)               │
│  WFE >= 0.6 é o threshold padrão para validação                            │
│                                                                             │
│  THRESHOLDS POR REGIME (mais específicos que global):                      │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Regime     │ WFE Mínimo │ Justificativa                           │   │
│  ├─────────────┼────────────┼─────────────────────────────────────────┤   │
│  │ TRENDING    │ >= 0.65    │ Alta previsibilidade, edge forte        │   │
│  │ RANGING     │ >= 0.50    │ Condições estáveis, edge médio          │   │
│  │ REVERTING   │ >= 0.45    │ Mais difícil, edge menor aceito         │   │
│  │ RANDOM      │ N/A        │ NÃO OPERAR (WFE irrelevante)            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  THRESHOLDS POR SESSÃO:                                                    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Sessão     │ WFE Mínimo │ Horário UTC        │ Nota               │   │
│  ├─────────────┼────────────┼────────────────────┼────────────────────┤   │
│  │ LONDON      │ >= 0.60    │ 07:00-12:00        │ Alta liquidez      │   │
│  │ OVERLAP     │ >= 0.65    │ 12:00-16:00        │ MELHOR SESSÃO      │   │
│  │ NY          │ >= 0.55    │ 16:00-21:00        │ Volatilidade ↑     │   │
│  │ ASIA        │ >= 0.40    │ 00:00-07:00        │ Pode skip          │   │
│  │ CLOSE       │ >= 0.35    │ 21:00-00:00        │ Baixa prioridade   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  TABELA CRUZADA (REGIME × SESSÃO):                                         │
│                                                                             │
│  ┌────────────┬─────────┬─────────┬─────────┬─────────┬─────────┐         │
│  │            │ LONDON  │ OVERLAP │ NY      │ ASIA    │ CLOSE   │         │
│  ├────────────┼─────────┼─────────┼─────────┼─────────┼─────────┤         │
│  │ TRENDING   │ 0.65    │ 0.70    │ 0.60    │ 0.45    │ 0.40    │         │
│  │ RANGING    │ 0.55    │ 0.60    │ 0.50    │ 0.35    │ 0.30    │         │
│  │ REVERTING  │ 0.50    │ 0.55    │ 0.45    │ 0.30    │ 0.25    │         │
│  │ RANDOM     │ N/A     │ N/A     │ N/A     │ N/A     │ N/A     │         │
│  └────────────┴─────────┴─────────┴─────────┴─────────┴─────────┘         │
│                                                                             │
│  AÇÃO SE WFE < THRESHOLD:                                                  │
│  ├── Se WFE < threshold - 0.10: DESABILITAR segmento                       │
│  ├── Se WFE < threshold: Reduzir risk em 50% para segmento                 │
│  └── Se WFE >= threshold: Operar normalmente                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Conservative Kelly com Correção por Sample Size

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CONSERVATIVE KELLY (SAMPLE SIZE CORRECTED)               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PROBLEMA COM KELLY TRADICIONAL:                                           │
│  Kelly assume conhecimento PERFEITO de win rate e payoff ratio.            │
│  Com dados limitados, temos INCERTEZA → precisa correção.                  │
│                                                                             │
│  FÓRMULA KELLY TRADICIONAL:                                                │
│  f* = (p × b - q) / b                                                      │
│     onde p = win rate, q = 1-p, b = avg_win / avg_loss                     │
│                                                                             │
│  FÓRMULA KELLY CONSERVADORA (Bailey & López de Prado):                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │  f_conservative = f* × (1 - 1/sqrt(N))                              │   │
│  │                                                                     │   │
│  │  Onde N = número de trades no sample                                │   │
│  │                                                                     │   │
│  │  Alternativa mais rigorosa (95% CI lower bound):                    │   │
│  │                                                                     │   │
│  │  p_lower = p - Z_0.95 × sqrt(p(1-p)/N)                              │   │
│  │  b_lower = b - Z_0.95 × SE(b)                                       │   │
│  │  f_lower = (p_lower × b_lower - (1-p_lower)) / b_lower              │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  IMPLEMENTAÇÃO PYTHON:                                                     │
│                                                                             │
│  ```python                                                                  │
│  def conservative_kelly(trades: pd.DataFrame, confidence: float = 0.95):   │
│      """                                                                    │
│      Calcula Kelly com correção para sample size.                          │
│                                                                             │
│      Referência: Bailey & López de Prado (2012)                            │
│      """                                                                    │
│      from scipy import stats                                               │
│                                                                             │
│      wins = trades[trades['profit'] > 0]                                   │
│      losses = trades[trades['profit'] < 0]                                 │
│      N = len(trades)                                                       │
│                                                                             │
│      if len(wins) == 0 or len(losses) == 0 or N < 30:                      │
│          return {'kelly': 0, 'error': 'Insufficient data'}                 │
│                                                                             │
│      # Estatísticas básicas                                                │
│      p = len(wins) / N  # win rate                                         │
│      q = 1 - p                                                             │
│      avg_win = wins['profit'].mean()                                       │
│      avg_loss = abs(losses['profit'].mean())                               │
│      b = avg_win / avg_loss  # payoff ratio                                │
│                                                                             │
│      # Kelly tradicional                                                   │
│      kelly_full = (p * b - q) / b if b > 0 else 0                          │
│                                                                             │
│      # Método 1: Correção simples sqrt(N)                                  │
│      kelly_simple = kelly_full * (1 - 1/np.sqrt(N))                        │
│                                                                             │
│      # Método 2: 95% CI lower bound                                        │
│      z = stats.norm.ppf(confidence)                                        │
│      p_se = np.sqrt(p * q / N)                                             │
│      p_lower = max(0.01, p - z * p_se)                                     │
│                                                                             │
│      # SE do payoff ratio (aproximação)                                    │
│      b_se = np.std([t['profit'] for _, t in wins.iterrows()]) / np.sqrt(len(wins))
│      b_se /= avg_loss                                                      │
│      b_lower = max(0.1, b - z * b_se)                                      │
│                                                                             │
│      kelly_lower = (p_lower * b_lower - (1-p_lower)) / b_lower             │
│                                                                             │
│      # Usar o MAIS CONSERVADOR dos dois métodos                            │
│      kelly_conservative = min(kelly_simple, kelly_lower)                   │
│                                                                             │
│      return {                                                              │
│          'kelly_full': kelly_full,                                         │
│          'kelly_simple_corrected': kelly_simple,                           │
│          'kelly_ci_lower': kelly_lower,                                    │
│          'kelly_conservative': max(0, kelly_conservative),                 │
│          'kelly_half': max(0, kelly_conservative) / 2,                     │
│          'kelly_quarter': max(0, kelly_conservative) / 4,                  │
│          'sample_size': N,                                                 │
│          'win_rate': p,                                                    │
│          'payoff_ratio': b,                                                │
│          'confidence_level': confidence,                                   │
│          'recommendation': 'kelly_quarter' if N < 100 else 'kelly_half'   │
│      }                                                                     │
│  ```                                                                       │
│                                                                             │
│  TABELA DE RECOMENDAÇÃO:                                                   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  N Trades    │ Kelly Recomendado │ Justificativa                   │   │
│  ├──────────────┼───────────────────┼─────────────────────────────────┤   │
│  │ < 30         │ 0% (não operar)   │ Sample insuficiente             │   │
│  │ 30-99        │ Kelly Quarter     │ Alta incerteza                  │   │
│  │ 100-299      │ Kelly Half        │ Incerteza moderada              │   │
│  │ 300-999      │ Kelly 60%         │ Boa confiança                   │   │
│  │ >= 1000      │ Kelly Full*       │ Alta confiança (verificar edge) │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  * Mesmo com N >= 1000, usar Kelly Half se edge decay detectado            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementação MinTRL

```python
# Adicionar em scripts/oracle/mintrl.py

import numpy as np
from scipy import stats

def calculate_mintrl(returns: np.ndarray, target_confidence: float = 0.95) -> dict:
    """
    Calcula Minimum Track Record Length.
    
    Referência: Bailey & López de Prado (2012)
    "The Sharpe Ratio Efficient Frontier"
    """
    # Estatísticas dos retornos
    n = len(returns)
    sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252)
    skew = stats.skew(returns)
    kurt = stats.kurtosis(returns)
    
    # Z-score para o nível de confiança
    z_alpha = stats.norm.ppf(target_confidence)
    
    # Correção para não-normalidade
    non_normal_correction = 1 + (skew**2 / 4) + (kurt / 8)
    
    # MinTRL em anos
    if sharpe > 0:
        mintrl_years = (z_alpha / sharpe)**2 * non_normal_correction
        mintrl_trades = mintrl_years * 252  # Assumindo 1 trade/dia
    else:
        mintrl_years = float('inf')
        mintrl_trades = float('inf')
    
    return {
        'mintrl_years': mintrl_years,
        'mintrl_trades': int(mintrl_trades),
        'available_trades': n,
        'sufficient': n >= mintrl_trades,
        'sharpe_observed': sharpe,
        'skewness': skew,
        'kurtosis': kurt,
        'confidence_level': target_confidence
    }
```

### Implementação Probabilidades FTMO

```python
# Adicionar em scripts/oracle/ftmo_probability.py

def calculate_ftmo_probabilities(mc_results: dict) -> dict:
    """
    Calcula probabilidades de violação dos limites FTMO.
    
    Args:
        mc_results: Resultados do Monte Carlo com daily_dds e total_dds
    """
    daily_dds = mc_results['daily_dds']  # Lista de max DD diários por simulação
    total_dds = mc_results['total_dds']  # Lista de max DD totais por simulação
    final_returns = mc_results['final_returns']  # Retorno final por simulação
    
    n_sims = len(daily_dds)
    
    # Probabilidades de violação
    p_daily_5pct = sum(1 for dd in daily_dds if dd >= 5.0) / n_sims * 100
    p_daily_4pct = sum(1 for dd in daily_dds if dd >= 4.0) / n_sims * 100
    p_total_10pct = sum(1 for dd in total_dds if dd >= 10.0) / n_sims * 100
    p_total_8pct = sum(1 for dd in total_dds if dd >= 8.0) / n_sims * 100
    
    # Profit target viability (10% em 30 dias)
    p_target_10pct = sum(1 for r in final_returns if r >= 10.0) / n_sims * 100
    
    # Determinar status
    daily_ok = p_daily_5pct < 5.0
    total_ok = p_total_10pct < 2.0
    target_ok = p_target_10pct >= 50.0
    
    return {
        'p_daily_5pct_breach': p_daily_5pct,
        'p_daily_4pct_breach': p_daily_4pct,
        'p_total_10pct_breach': p_total_10pct,
        'p_total_8pct_breach': p_total_8pct,
        'p_profit_target_10pct': p_target_10pct,
        'daily_limit_safe': daily_ok,
        'total_limit_safe': total_ok,
        'target_viable': target_ok,
        'overall_ftmo_ready': daily_ok and total_ok and target_ok
    }
```

---

## OS 7 PRINCÍPIOS GENIUS - MAPEADOS AO CÓDIGO

```
┌─────────────────────────────────────────────────────────────────────────────┐
│            GENIUS PRINCIPLES → CÓDIGO EXISTENTE + GAPS                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  #1 KELLY CRITERION                                                        │
│  ├── ✅ FTMO_RiskManager::CalculateKellyFraction()                         │
│  ├── ✅ m_use_adaptive_kelly, OnTradeResult() tracking                     │
│  ├── ✅ 6-factor: Kelly × Regime × DD × Session × Momentum × Ratchet       │
│  └── 🔲 VALIDAR: Kelly por regime/sessão (tabela de backtest)              │
│                                                                             │
│  #2 CONVEXIDADE                                                            │
│  ├── ✅ CEntryOptimizer: R:R mínimo 1.5, target 2.5                        │
│  ├── ✅ CTradeManager: Partial TPs (40%/30%/30%)                           │
│  ├── ✅ Trailing stop implementado                                         │
│  └── 🔲 ADICIONAR: Skew, Tail Ratio no backtest reporter                   │
│                                                                             │
│  #3 PHASE TRANSITIONS                                                      │
│  ├── ✅ CRegimeDetector::transition_probability                            │
│  ├── ✅ regime_velocity (dH/dt), bars_in_regime                            │
│  ├── ✅ REGIME_TRANSITIONING enum                                          │
│  ├── ✅ Multi-scale Hurst (short/medium/long)                              │
│  └── 🔲 VALIDAR: Stress test de transições rápidas                         │
│                                                                             │
│  #4 FRACTAL GEOMETRY                                                       │
│  ├── ✅ CMTFManager: H1/M15/M5 alignment                                   │
│  ├── ✅ GetConfluence(), GetPositionMultiplier()                           │
│  ├── ✅ PERFECT/GOOD/WEAK/NONE classification                              │
│  └── 🔲 VALIDAR: Win rate por MTF alignment score                          │
│                                                                             │
│  #5 INFORMATION THEORY                                                     │
│  ├── ✅ CRegimeDetector::shannon_entropy                                   │
│  ├── ✅ Entropy-based size multiplier                                      │
│  └── 🔲 ADICIONAR: Edge Decay Monitor para live trading                    │
│                                                                             │
│  #6 ENSEMBLE DIVERSITY                                                     │
│  ├── ✅ CConfluenceScorer: SMC + ML + OrderFlow + Regime                   │
│  ├── ⚠️ PARCIAL: Não mede correlação de erros entre fatores               │
│  └── 🔲 ADICIONAR: Error correlation matrix no backtest                    │
│                                                                             │
│  #7 TAIL RISK / EVT                                                        │
│  ├── ✅ monte_carlo.py: Block Bootstrap implementado                       │
│  ├── ✅ VaR, CVaR básicos                                                  │
│  ├── ⚠️ PARCIAL: Não usa GPD para modelar tails                           │
│  └── 🔲 ADICIONAR: EVT (Generalized Pareto) para tails extremos            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FLUXO DE FASES

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUXO DE VALIDAÇÃO v4.0                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FASE 0 ──▶ FASE 1 ──▶ FASE 2 ──▶ FASE 3 ──▶ FASE 4 ──▶ FASE 5             │
│   AUDIT      DATA    BASELINE     ML      SHADOW    ORACLE                  │
│   ✅DONE     1d       3-4d       3-5d      3-4d      3-4d                   │
│                                                                             │
│                                    FASE 5 ──▶ FASE 6 ──▶ FASE 7 ──▶ FASE 8 │
│                                    ORACLE    STRESS     DEMO      FTMO     │
│                                    3-4d      2-3d      2 sem     4+ sem    │
│                                                                             │
│  GATES DE DECISÃO:                                                         │
│  ├── Após FASE 1: Se Quality Score < 90 → PARAR (dados ruins)              │
│  ├── Após FASE 2: Se PF < 1.3 → PARAR (estratégia não funciona)            │
│  ├── Após FASE 4: Se divergência MT5 vs Shadow > 15% → Investigar          │
│  ├── Após FASE 5: Se Confidence < 75 → NO-GO                               │
│  └── Após FASE 6: Se falhar stress crítico → NO-GO                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 0: AUDIT DO CÓDIGO ✅ COMPLETA

**Status**: 100% - Score Médio 19.5/20
**Documentação**: `MQL5/Experts/BUGFIX_LOG.md`

| Módulo | Score | Genius Features Já Presentes |
|--------|-------|------------------------------|
| FTMO_RiskManager | 20/20 | Kelly adaptive, 6-factor sizing |
| CRegimeDetector | 19/20 | Multi-scale Hurst, transition detection |
| CMTFManager | 20/20 | Fractal MTF alignment |
| CConfluenceScorer | 20/20 | Multi-factor ensemble scoring |
| CFootprintAnalyzer | 20/20 | Order Flow confirmation |

---

## FASE 1: VALIDAÇÃO DE DADOS

**Duração**: 1-2 dias
**Princípios GENIUS aplicados**: #3 (Phase Transitions), #4 (Fractals)
**Esforço estimado**: ~4h de código, ~2h de execução

### SEQUÊNCIA DE EXECUÇÃO FASE 1

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PASSO   │  SCRIPT/AÇÃO              │  INPUT                │  OUTPUT     │
├──────────┼───────────────────────────┼───────────────────────┼─────────────┤
│  1.1     │  convert_tick_data.py     │  XAUUSD_ftmo_all.csv  │  .parquet   │
│  1.2     │  validate_data.py         │  .parquet + bars      │  REPORT.md  │
│  1.3     │  CHECKPOINT               │  Quality Score        │  GO/NO-GO   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.1 Converter Tick Data (NOVO - OBRIGATÓRIO)

```
PROMPT PARA FORGE:

"Forge, crie script para converter tick data CSV gigante para formato otimizado:

ARQUIVO: scripts/data/convert_tick_data.py

INPUT:
  Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv (24.8 GB)

FUNCIONALIDADES:

1. LEITURA EM CHUNKS (RAM < 8GB):
   - chunk_size = 5_000_000 linhas
   - Processar cada chunk, agregar estatísticas

2. DETECTAR FORMATO AUTOMATICAMENTE:
   - Formato 1: timestamp,bid,ask,volume
   - Formato 2: time,bid,ask,bid_volume,ask_volume
   - Formato 3: datetime,open,high,low,close (bars, não ticks)

3. NORMALIZAR PARA FORMATO PADRÃO:
   columns = ['timestamp', 'bid', 'ask', 'spread', 'mid_price']
   - timestamp: datetime64[ns] UTC
   - spread: ask - bid (em centavos)
   - mid_price: (bid + ask) / 2

4. SALVAR EM PARQUET (compressão snappy):
   OUTPUT: data/processed/ticks_YYYY.parquet (um arquivo por ano)
   
5. CRIAR CHUNKS PARA BACKTEST:
   OUTPUT: data/processed/chunks/ticks_YYYYMM.parquet (um por mês)

6. ESTATÍSTICAS DURANTE CONVERSÃO:
   - Total ticks processados
   - Data range (min_date, max_date)
   - Spread médio/max/min por ano
   - Gaps detectados > 1 hora

EXEMPLO DE USO:
  python scripts/data/convert_tick_data.py \\
    --input Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv \\
    --output data/processed/ \\
    --chunk-size 5000000 \\
    --years 2020-2025  # opcional: só converter período específico

OUTPUT FINAL:
  data/processed/
  ├── ticks_2020.parquet
  ├── ticks_2021.parquet
  ├── ticks_2022.parquet
  ├── ticks_2023.parquet
  ├── ticks_2024.parquet
  ├── ticks_2025.parquet
  ├── chunks/
  │   ├── ticks_202001.parquet
  │   ├── ticks_202002.parquet
  │   └── ...
  └── CONVERSION_STATS.json
"
```

### 1.2 Validar Dados com Métricas GENIUS

```
PROMPT PARA FORGE:

"Forge, melhore scripts/oracle/validate_data.py para incluir validação GENIUS:

ARQUIVO: scripts/oracle/validate_data.py (já existe, ESTENDER)

INPUT:
  - data/processed/ticks_*.parquet (convertidos no passo 1.1)
  - Python_Agent_Hub/ml_pipeline/data/bars-*-M5.csv
  - Python_Agent_Hub/ml_pipeline/data/bars-*-M15.csv
  - Python_Agent_Hub/ml_pipeline/data/bars-*-H1.csv

ADICIONAR VALIDAÇÃO GENIUS:

1. REGIME TRANSITION ANALYSIS (Princípio #3):
   - Calcular Hurst R/S rolling (window=100 bars M5)
   - Contar transições de regime (H < 0.45 ↔ H > 0.55)
   - Verificar se há >= 50 transições (para treinar detector)
   - Calcular avg_transition_duration em bars
   - Verificar diversity: trending >= 20%, reverting >= 10%, random >= 5%

2. MTF CONSISTENCY (Princípio #4):
   - Carregar M5, M15, H1 bars
   - Verificar que H1.high == max(M5.high) para cada hora
   - Verificar que H1.low == min(M5.low) para cada hora
   - MTF consistency score = % de horas consistentes
   - Critério: >= 95%

3. VOLATILITY CLUSTERING (validação estatística):
   - Calcular returns = diff(mid_price) / mid_price
   - Calcular autocorrelação de |returns| lag 1-10
   - Se autocorr(1) > 0.1 → mercado real (GARCH-like) ✅
   - Se autocorr(1) < 0.05 → dados sintéticos (suspeito) ⚠️

4. SESSION COVERAGE ANALYSIS:
   - ASIA:    00:00-07:00 UTC → target >= 5%
   - LONDON:  07:00-12:00 UTC → target >= 5%
   - OVERLAP: 12:00-16:00 UTC → target >= 5%
   - NY:      16:00-21:00 UTC → target >= 5%
   - CLOSE:   21:00-00:00 UTC → target >= 3%

5. QUALITY SCORE GENIUS (0-100):
   def calculate_quality_score():
       score = 0
       
       # Data Coverage (25 pts)
       months = (max_date - min_date).days / 30
       if months >= 60: score += 25      # 5+ anos
       elif months >= 36: score += 20    # 3+ anos
       elif months >= 24: score += 15    # 2+ anos
       else: score += 5
       
       # Clean Data % (25 pts)
       clean_pct = valid_ticks / total_ticks * 100
       if clean_pct >= 99: score += 25
       elif clean_pct >= 95: score += 20
       elif clean_pct >= 90: score += 15
       else: score += 5
       
       # Gap Analysis (15 pts)
       critical_gaps = count_gaps_over_24h_non_weekend()
       if critical_gaps == 0: score += 15
       elif critical_gaps <= 2: score += 10
       elif critical_gaps <= 5: score += 5
       else: score += 0
       
       # Regime Diversity (15 pts)
       if trending_pct >= 20 and reverting_pct >= 10 and random_pct >= 5:
           score += 15
       elif trending_pct >= 15 and reverting_pct >= 5:
           score += 10
       else: score += 5
       
       # Session Coverage (10 pts)
       if all_sessions_above_threshold:
           score += 10
       elif most_sessions_above_threshold:
           score += 5
       else: score += 0
       
       # Spread Quality (10 pts)
       if avg_spread < 30: score += 10   # < 30 cents
       elif avg_spread < 50: score += 7  # < 50 cents
       elif avg_spread < 100: score += 3 # < $1
       else: score += 0
       
       return score

EXEMPLO DE USO:
  python scripts/oracle/validate_data.py \\
    --ticks data/processed/ticks_*.parquet \\
    --bars-m5 Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5*.csv \\
    --bars-m15 Python_Agent_Hub/ml_pipeline/data/bars-2020-2025XAUUSD_ftmo-M15*.csv \\
    --bars-h1 Python_Agent_Hub/ml_pipeline/data/bars-2020-2025XAUUSD_ftmo-H1*.csv \\
    --output DOCS/04_REPORTS/VALIDATION/DATA_QUALITY_GENIUS.md

OUTPUT: DOCS/04_REPORTS/VALIDATION/DATA_QUALITY_GENIUS.md
"
```

### 1.3 Checkpoint Fase 1

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHECKPOINT FASE 1                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  VALIDAÇÃO BÁSICA:                                                         │
│  □ Tick data >= 3 anos                                                     │
│  □ Clean data >= 95%                                                       │
│  □ Gaps críticos (>24h non-weekend) = 0                                    │
│  □ Spread médio < 50 cents                                                 │
│                                                                             │
│  VALIDAÇÃO GENIUS:                                                         │
│  □ Regime transitions >= 50 detectadas                                     │
│  □ Trending >= 20%, Reverting >= 10% do tempo                              │
│  □ Volatility clustering presente (autocorr > 0.1)                         │
│  □ MTF consistency >= 95%                                                  │
│  □ Todas as sessões >= 5% cobertura                                        │
│                                                                             │
│  □ Quality Score GENIUS >= 90                                              │
│                                                                             │
│  SE TODOS ✅ → Prosseguir para FASE 2                                      │
│  SE Score < 90 → Obter mais dados ou corrigir problemas                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 2: BACKTEST BASELINE + GENIUS METRICS

**Duração**: 3-4 dias
**Princípios GENIUS aplicados**: #1 (Kelly), #2 (Convexity), #3 (Phase Transitions), #4 (Fractals)

### 2.1 Segmentação de Dados (Princípios #3, #4)

```
PROMPT PARA FORGE:

"Forge, crie script para segmentar dados por regime e sessão:

ARQUIVO: scripts/backtest/segment_data.py

FUNCIONALIDADES:

1. DETECÇÃO DE REGIME (usa mesma lógica do CRegimeDetector):
   - Hurst R/S com window=100
   - Classificar: TRENDING (>0.55), RANDOM (0.45-0.55), REVERTING (<0.45)
   - Salvar regime em cada tick/bar

2. DETECÇÃO DE SESSÃO (usa mesma lógica do CSessionFilter):
   - ASIA: 00:00-07:00 UTC
   - LONDON: 07:00-12:00 UTC
   - OVERLAP: 12:00-16:00 UTC
   - NY: 16:00-21:00 UTC
   - CLOSE: 21:00-00:00 UTC

3. OUTPUT:
   - data/segments/regime_trending.parquet
   - data/segments/regime_random.parquet
   - data/segments/regime_reverting.parquet
   - data/segments/session_*.parquet
   - data/segments/SEGMENT_STATS.json

4. ESTATÍSTICAS:
   {
     'trending_pct': 45.2,
     'random_pct': 32.1,
     'reverting_pct': 22.7,
     'asia_pct': 28.5,
     'london_pct': 21.0,
     ...
   }
"
```

### 2.2 Backtest com Métricas GENIUS (Princípios #1, #2)

```
PROMPT PARA FORGE:

"Forge, estenda scripts/backtest/tick_backtester.py para coletar métricas GENIUS:

ADICIONAR ao BacktestReport:

1. KELLY METRICS (Princípio #1):
   class KellyCollector:
       def __init__(self):
           self.trades_by_segment = {}  # {regime_session: [trades]}
       
       def add_trade(self, trade, regime, session):
           key = f'{regime}_{session}'
           if key not in self.trades_by_segment:
               self.trades_by_segment[key] = []
           self.trades_by_segment[key].append(trade)
       
       def calculate_kelly_table(self):
           '''
           Retorna tabela com Kelly por segmento:
           | Segment | WinRate | W/L Ratio | Kelly Full | Kelly Half | N Trades |
           '''
           results = {}
           for segment, trades in self.trades_by_segment.items():
               wins = [t for t in trades if t.pnl > 0]
               losses = [t for t in trades if t.pnl <= 0]
               
               if not wins or not losses:
                   continue
               
               p = len(wins) / len(trades)
               avg_win = np.mean([t.pnl for t in wins])
               avg_loss = abs(np.mean([t.pnl for t in losses]))
               b = avg_win / avg_loss
               
               kelly = (p * b - (1-p)) / b
               
               results[segment] = {
                   'win_rate': p,
                   'wl_ratio': b,
                   'kelly_full': kelly,
                   'kelly_half': kelly * 0.5,
                   'kelly_quarter': kelly * 0.25,
                   'n_trades': len(trades),
                   'recommendation': 'USE' if kelly > 0.01 else 'AVOID'
               }
           return results

2. CONVEXITY METRICS (Princípio #2):
   class ConvexityCollector:
       def calculate(self, trades):
           pnls = [t.pnl for t in trades]
           wins = [p for p in pnls if p > 0]
           losses = [p for p in pnls if p < 0]
           
           return {
               'asymmetry': np.mean(wins) / abs(np.mean(losses)),  # Target >= 1.5
               'skewness': scipy.stats.skew(pnls),                 # Target > 0
               'tail_ratio': np.percentile(wins, 95) / abs(np.percentile(losses, 5)),
               'gain_to_pain': sum(wins) / abs(sum(losses)),
               'convexity_score': self._calc_score(...)  # 0-100
           }

3. MTF ALIGNMENT ANALYSIS (Princípio #4):
   - Win rate por MTF alignment score
   - Average R por alignment
   - Confirmar que PERFECT > GOOD > WEAK

OUTPUT ADICIONAL:
- DOCS/04_REPORTS/BACKTESTS/KELLY_TABLE.md
- DOCS/04_REPORTS/BACKTESTS/CONVEXITY_REPORT.md
- DOCS/04_REPORTS/BACKTESTS/MTF_ALIGNMENT_ANALYSIS.md
"
```

### 2.3 Executar Backtests Multi-Regime

```
PROMPT PARA FORGE:

"Forge, execute backtests por segmento:

EXECUÇÕES (usando tick_backtester.py estendido):

1. GLOBAL (todos os dados):
   python scripts/backtest/tick_backtester.py --segment all

2. POR REGIME:
   python scripts/backtest/tick_backtester.py --segment trending
   python scripts/backtest/tick_backtester.py --segment reverting
   # RANDOM deve ter 0 trades (filtro bloqueia)

3. POR SESSÃO:
   python scripts/backtest/tick_backtester.py --segment london
   python scripts/backtest/tick_backtester.py --segment overlap
   python scripts/backtest/tick_backtester.py --segment ny
   # ASIA pode ser bloqueada ou ter performance pior

4. CRUZADO (regime × sessão):
   python scripts/backtest/tick_backtester.py --segment trending_overlap
   # Esta deve ser a MELHOR combinação

TABELA DE RESULTADOS:
| Segment | Trades | WR | PF | MaxDD | Kelly | Convexity | Status |
|---------|--------|----|----|-------|-------|-----------|--------|
| GLOBAL  |        |    |    |       |       |           |        |
| TREND   |        |    |    |       |       |           |        |
| REVERT  |        |    |    |       |       |           |        |
| LONDON  |        |    |    |       |       |           |        |
| OVERLAP |        |    |    |       |       |           |        |
| TREND×OV|        |    |    |       |       |           | BEST?  |

CRITÉRIOS:
├── PF Global >= 1.3
├── PF Trending >= 1.5
├── Zero trades em RANDOM
├── Kelly positivo em segmentos operados
├── Convexity score >= 60
└── Max DD <= 15%
"
```

### 2.4 Checkpoint Fase 2

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHECKPOINT FASE 2                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MÉTRICAS BÁSICAS:                                                         │
│  □ PF Global >= 1.3                                                        │
│  □ Win Rate >= 55%                                                         │
│  □ Max DD <= 15%                                                           │
│  □ >= 100 trades total                                                     │
│                                                                             │
│  MÉTRICAS GENIUS:                                                          │
│                                                                             │
│  KELLY (Princípio #1):                                                     │
│  □ Kelly positivo em TRENDING                                              │
│  □ Kelly positivo em LONDON/OVERLAP/NY                                     │
│  □ Kelly tabela gerada por segmento                                        │
│                                                                             │
│  CONVEXITY (Princípio #2):                                                 │
│  □ Asymmetry (avg_win/avg_loss) >= 1.5                                     │
│  □ Skewness > 0 (positive skew)                                            │
│  □ Tail Ratio > 1.0                                                        │
│  □ Convexity Score >= 60                                                   │
│                                                                             │
│  PHASE TRANSITIONS (Princípio #3):                                         │
│  □ Zero trades em RANDOM regime                                            │
│  □ Regime filter funcionando (verificado)                                  │
│                                                                             │
│  FRACTALS (Princípio #4):                                                  │
│  □ Win rate PERFECT alignment > Win rate GOOD > WEAK                       │
│  □ MTF multiplier correlacionado com performance                           │
│                                                                             │
│  SE TODOS ✅ → Prosseguir para FASE 3                                      │
│  SE PF < 1.3 → PARAR e revisar estratégia                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 3: TREINAMENTO ML

**Duração**: 3-5 dias
**Princípios GENIUS aplicados**: #5 (Information Theory), #6 (Ensemble Diversity)

### 3.1 Feature Engineering (Princípio #5)

```
PROMPT PARA onnx-model-builder:

"Crie features para o modelo, incluindo features de REGIME e ENTROPY:

ARQUIVO: scripts/ml/feature_engineering.py

15 FEATURES (conforme INDEX.md do EA):

# GRUPO 1: PRICE ACTION (5)
1. returns = (close - prev_close) / prev_close
2. log_returns = log(close / prev_close)
3. range_pct = (high - low) / close
4. body_pct = abs(close - open) / (high - low)
5. upper_shadow_pct = (high - max(open, close)) / (high - low)

# GRUPO 2: MTF RSI (3)
6. rsi_m5 = RSI(14) / 100
7. rsi_m15 = RSI(14) / 100
8. rsi_h1 = RSI(14) / 100

# GRUPO 3: VOLATILITY (3)
9. atr_norm = ATR(14) / close
10. ma_distance = (close - MA20) / MA20
11. bb_position = (close - BB_mid) / BB_width

# GRUPO 4: REGIME - JÁ IMPLEMENTADO NO EA (2)
12. hurst = rolling_hurst(100)  # CONECTA COM CRegimeDetector
13. entropy = rolling_entropy(100) / 4  # CONECTA COM CRegimeDetector

# GRUPO 5: TEMPORAL (2)
14. hour_sin = sin(2π × hour / 24)
15. hour_cos = cos(2π × hour / 24)

NORMALIZAÇÃO:
- StandardScaler para todas
- Salvar params em MQL5/Models/scaler_params.json
- MESMOS params em train e inference

IMPORTANTE:
- Features 12-13 devem usar MESMA LÓGICA do CRegimeDetector.mqh
- Isso garante consistência entre Python training e MQL5 inference
"
```

### 3.2 Ensemble Diversity (Princípio #6)

```
PROMPT PARA onnx-model-builder:

"Implemente verificação de Ensemble Diversity:

CONCEITO: O valor de combinar SMC + ML + OrderFlow está na BAIXA CORRELAÇÃO DE ERROS

class EnsembleDiversityChecker:
    '''
    Verifica se os diferentes sinais (SMC, ML, OrderFlow) têm
    erros pouco correlacionados - isso é o que faz o ensemble valer a pena.
    '''
    
    def __init__(self):
        self.smc_predictions = []
        self.ml_predictions = []
        self.orderflow_predictions = []
        self.actuals = []
    
    def add_sample(self, smc_signal, ml_prob, of_signal, actual_direction):
        self.smc_predictions.append(smc_signal)
        self.ml_predictions.append(ml_prob > 0.5)
        self.orderflow_predictions.append(of_signal)
        self.actuals.append(actual_direction)
    
    def calculate_error_correlation(self):
        '''
        Retorna matriz de correlação de ERROS (não de sinais!)
        '''
        smc_errors = [p != a for p, a in zip(self.smc_predictions, self.actuals)]
        ml_errors = [p != a for p, a in zip(self.ml_predictions, self.actuals)]
        of_errors = [p != a for p, a in zip(self.orderflow_predictions, self.actuals)]
        
        df = pd.DataFrame({
            'smc': smc_errors,
            'ml': ml_errors,
            'orderflow': of_errors
        })
        
        return df.corr()
    
    def get_diversity_score(self):
        '''
        Score 0-100. Correlação baixa = score alto = bom ensemble.
        '''
        corr_matrix = self.calculate_error_correlation()
        
        # Média das correlações off-diagonal
        avg_corr = (abs(corr_matrix.iloc[0,1]) + 
                   abs(corr_matrix.iloc[0,2]) + 
                   abs(corr_matrix.iloc[1,2])) / 3
        
        # Inverter: baixa correlação = alto score
        return int((1 - avg_corr) * 100)

CRITÉRIO:
├── Diversity Score >= 50: Ensemble vale a pena
├── Diversity Score 30-49: Ensemble marginal
└── Diversity Score < 30: Sinais muito correlacionados, simplificar

INSIGHT DO EA:
O CConfluenceScorer já combina SMC + ML + OrderFlow.
Esta análise VALIDA se essa combinação realmente adiciona valor.
"
```

### 3.3 Checkpoint Fase 3

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHECKPOINT FASE 3                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ML BÁSICO:                                                                │
│  □ Features engineered (15 features)                                       │
│  □ Model treinado com Walk-Forward (não k-fold!)                           │
│  □ Accuracy OOS > 55%                                                      │
│  □ Brier score < 0.25 (calibração)                                         │
│  □ ONNX exportado e testado                                                │
│                                                                             │
│  GENIUS - INFORMATION THEORY (Princípio #5):                               │
│  □ Features Hurst/Entropy consistentes com CRegimeDetector                 │
│  □ Entropy feature tem information gain significativo                      │
│                                                                             │
│  GENIUS - ENSEMBLE DIVERSITY (Princípio #6):                               │
│  □ Error correlation matrix calculada                                      │
│  □ SMC vs ML correlation < 0.5                                             │
│  □ Diversity Score >= 50                                                   │
│                                                                             │
│  INTEGRAÇÃO:                                                               │
│  □ COnnxBrain.mqh atualizado                                               │
│  □ Inference latência < 5ms                                                │
│  □ Backtest COM ML >= backtest SEM ML                                      │
│                                                                             │
│  SE TODOS ✅ → Prosseguir para FASE 4                                      │
│  SE ML piora métricas → Desabilitar ML ou retreinar                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 4: SHADOW EXCHANGE

**Duração**: 3-4 dias
**Princípio GENIUS aplicado**: #7 (Tail Risk / EVT)

### 4.0 LatencyModel Completo (4 Componentes)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    LATENCY MODEL - 4 COMPONENTES                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CONCEITO: Latência TOTAL = Network + Broker + GC + Processing             │
│                                                                             │
│  A latência não é apenas network - há múltiplas fontes:                    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │  L_total = L_network + L_broker + L_gc + L_processing               │   │
│  │                                                                     │   │
│  │  Onde cada componente tem distribuição diferente:                   │   │
│  │                                                                     │   │
│  │  1. NETWORK (Gamma distribution):                                   │   │
│  │     - Shape: 2.0, Scale: 5.0                                        │   │
│  │     - Mean: ~10ms, Tail: pode chegar a 100ms+                       │   │
│  │     - Afetado por: Distance to broker, packet loss, routing         │   │
│  │                                                                     │   │
│  │  2. BROKER (Exponential + spike):                                   │   │
│  │     - Base: Exponential(λ=0.1) → Mean ~10ms                         │   │
│  │     - 5% chance de spike: +50-500ms (requote, queue)                │   │
│  │     - Afetado por: Broker load, market conditions                   │   │
│  │                                                                     │   │
│  │  3. GC PAUSE (Rare but catastrophic):                               │   │
│  │     - 99% do tempo: 0ms                                             │   │
│  │     - 1% chance: 50-200ms (full GC event)                           │   │
│  │     - Crítico em MQL5: ONNX inference pode triggerar                │   │
│  │                                                                     │   │
│  │  4. PROCESSING (Deterministic + variance):                          │   │
│  │     - Base: 5ms (OnTick processing)                                 │   │
│  │     - Variance: ±2ms (indicator calculations)                       │   │
│  │     - ONNX: +2-5ms quando modelo roda                               │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

```python
# scripts/backtest/latency_model.py

import numpy as np
from scipy import stats
from dataclasses import dataclass
from typing import Dict, Tuple
from enum import Enum

class MarketCondition(Enum):
    NORMAL = 'normal'
    VOLATILE = 'volatile'
    NEWS = 'news'
    STRESS = 'stress'
    FLASH_CRASH = 'flash_crash'

@dataclass
class LatencyConfig:
    """Configuração dos parâmetros de latência"""
    # Network (Gamma)
    network_shape: float = 2.0
    network_scale: float = 5.0
    packet_loss_rate: float = 0.01
    packet_loss_retry_ms: float = 100.0
    
    # Broker (Exponential + spike)
    broker_base_lambda: float = 0.1
    broker_spike_prob: float = 0.05
    broker_spike_min: float = 50.0
    broker_spike_max: float = 500.0
    
    # GC Pause
    gc_pause_prob: float = 0.01
    gc_pause_min: float = 50.0
    gc_pause_max: float = 200.0
    
    # Processing
    processing_base: float = 5.0
    processing_variance: float = 2.0
    onnx_overhead: float = 3.0
    onnx_prob: float = 0.3  # 30% dos ticks rodam ONNX

class LatencyModel:
    """
    Modelo de latência com 4 componentes realistas.
    
    Uso:
        model = LatencyModel()
        latency = model.sample(MarketCondition.NORMAL, use_onnx=True)
    """
    
    def __init__(self, config: LatencyConfig = None):
        self.config = config or LatencyConfig()
        self._history = []
    
    def sample_network(self, condition: MarketCondition) -> float:
        """
        Latência de rede (Gamma distribution).
        
        Gamma é ideal porque:
        - Sempre positiva
        - Assimétrica à direita (tail pesado)
        - Modela tempo de espera bem
        """
        multipliers = {
            MarketCondition.NORMAL: 1.0,
            MarketCondition.VOLATILE: 1.5,
            MarketCondition.NEWS: 2.0,
            MarketCondition.STRESS: 3.0,
            MarketCondition.FLASH_CRASH: 5.0
        }
        
        base = np.random.gamma(
            self.config.network_shape,
            self.config.network_scale
        )
        
        # Packet loss: retry adiciona latência
        if np.random.random() < self.config.packet_loss_rate:
            base += self.config.packet_loss_retry_ms
        
        return base * multipliers[condition]
    
    def sample_broker(self, condition: MarketCondition) -> float:
        """
        Latência do broker (Exponential + spikes).
        
        Spikes representam:
        - Requotes
        - Order queue
        - Server overload
        """
        multipliers = {
            MarketCondition.NORMAL: 1.0,
            MarketCondition.VOLATILE: 1.5,
            MarketCondition.NEWS: 2.5,
            MarketCondition.STRESS: 4.0,
            MarketCondition.FLASH_CRASH: 8.0
        }
        
        # Base exponential
        base = np.random.exponential(1 / self.config.broker_base_lambda)
        
        # Spike (requote, queue, etc)
        spike_prob = self.config.broker_spike_prob * multipliers[condition]
        if np.random.random() < spike_prob:
            spike = np.random.uniform(
                self.config.broker_spike_min,
                self.config.broker_spike_max
            )
            base += spike
        
        return base * multipliers[condition]
    
    def sample_gc_pause(self) -> float:
        """
        GC Pause (raro mas catastrófico).
        
        Em MQL5, GC pode ocorrer durante:
        - Alocação de arrays grandes
        - Operações ONNX
        - Logging extensivo
        """
        if np.random.random() < self.config.gc_pause_prob:
            return np.random.uniform(
                self.config.gc_pause_min,
                self.config.gc_pause_max
            )
        return 0.0
    
    def sample_processing(self, use_onnx: bool = False) -> float:
        """
        Latência de processamento (deterministic + variance).
        """
        base = self.config.processing_base
        variance = np.random.uniform(
            -self.config.processing_variance,
            self.config.processing_variance
        )
        
        onnx = 0.0
        if use_onnx or np.random.random() < self.config.onnx_prob:
            onnx = self.config.onnx_overhead
        
        return max(1.0, base + variance + onnx)
    
    def sample(self, condition: MarketCondition = MarketCondition.NORMAL,
               use_onnx: bool = False) -> Dict:
        """
        Amostra latência total com breakdown por componente.
        
        Returns:
            Dict com 'total' e breakdown por componente
        """
        network = self.sample_network(condition)
        broker = self.sample_broker(condition)
        gc = self.sample_gc_pause()
        processing = self.sample_processing(use_onnx)
        
        total = network + broker + gc + processing
        
        result = {
            'total_ms': total,
            'network_ms': network,
            'broker_ms': broker,
            'gc_ms': gc,
            'processing_ms': processing,
            'condition': condition.value,
            'has_gc_event': gc > 0,
            'has_broker_spike': broker > 50
        }
        
        self._history.append(result)
        return result
    
    def get_statistics(self, n_samples: int = 10000) -> Dict:
        """
        Estatísticas de latência baseadas em simulação.
        """
        samples = [self.sample(MarketCondition.NORMAL)['total_ms'] 
                   for _ in range(n_samples)]
        
        return {
            'mean_ms': np.mean(samples),
            'median_ms': np.median(samples),
            'std_ms': np.std(samples),
            'p50_ms': np.percentile(samples, 50),
            'p95_ms': np.percentile(samples, 95),
            'p99_ms': np.percentile(samples, 99),
            'p99_9_ms': np.percentile(samples, 99.9),
            'max_ms': np.max(samples),
            'cvar_95_ms': np.mean([s for s in samples if s >= np.percentile(samples, 95)])
        }
    
    def expected_slippage_from_latency(self, latency_ms: float, 
                                        market_velocity: float = 0.5) -> float:
        """
        Estima slippage em pips baseado na latência.
        
        Args:
            latency_ms: Latência total em ms
            market_velocity: Velocidade do mercado em pips/second
            
        Returns:
            Slippage esperado em pips
        """
        seconds = latency_ms / 1000
        return seconds * market_velocity

# Configurações pré-definidas para diferentes cenários
LATENCY_CONFIGS = {
    'optimistic': LatencyConfig(
        network_shape=2.0, network_scale=3.0,
        broker_base_lambda=0.2, broker_spike_prob=0.02,
        gc_pause_prob=0.005
    ),
    'normal': LatencyConfig(),  # Default
    'pessimistic': LatencyConfig(
        network_shape=2.5, network_scale=8.0,
        broker_base_lambda=0.05, broker_spike_prob=0.10,
        gc_pause_prob=0.02
    ),
    'stress': LatencyConfig(
        network_shape=3.0, network_scale=15.0,
        broker_base_lambda=0.02, broker_spike_prob=0.20,
        broker_spike_max=1000.0,
        gc_pause_prob=0.05, gc_pause_max=500.0
    )
}
```

### 4.1 Modelo de Latência EVT (Princípio #7)

```
PROMPT PARA FORGE:

"Forge, crie Shadow Exchange com modelo de latência EVT:

ARQUIVO: scripts/backtest/shadow_exchange.py

CONCEITO:
Não é a latência MÉDIA que mata, é a latência EXTREMA.
Usar EVT (Extreme Value Theory) para modelar tails.

class EVTLatencyModel:
    '''
    Latência com tails modelados por GPD (Generalized Pareto Distribution)
    '''
    
    def __init__(self, base_latency_ms=20):
        self.base = base_latency_ms
        
        # GPD parameters (estimados de dados reais)
        self.gpd_shape = 0.3   # shape > 0 = heavy tail
        self.gpd_scale = 15
        self.gpd_threshold = 50  # ms
    
    def sample(self, market_condition='normal'):
        # Corpo da distribuição (Gamma - assimétrica positiva)
        body = self.base + np.random.gamma(2.0, 5.0)
        
        # 5% chance de evento de tail
        if np.random.random() < 0.05:
            tail = self._sample_gpd()
            latency = body + tail
        else:
            latency = body
        
        # Multiplicadores por condição
        multipliers = {
            'normal': 1.0,
            'news': 3.0,
            'stress': 5.0,
            'flash_crash': 10.0
        }
        
        return latency * multipliers.get(market_condition, 1.0)
    
    def _sample_gpd(self):
        '''Sample da Generalized Pareto Distribution'''
        u = np.random.uniform(0, 1)
        if self.gpd_shape == 0:
            return self.gpd_scale * (-np.log(1 - u))
        return (self.gpd_scale / self.gpd_shape) * ((1 - u)**(-self.gpd_shape) - 1)
    
    def expected_shortfall(self, percentile=95, n_samples=10000):
        '''CVaR: Expected value dado que estamos na tail'''
        samples = [self.sample() for _ in range(n_samples)]
        threshold = np.percentile(samples, percentile)
        tail_samples = [s for s in samples if s >= threshold]
        return np.mean(tail_samples)

class ShadowExchange:
    '''
    Exchange emulator com custos realistas e latência EVT
    '''
    
    def __init__(self, config):
        self.latency_model = EVTLatencyModel(config.base_latency)
        self.spread_model = DynamicSpreadModel(config)
        self.slippage_model = SlippageModel(config)
        self.rejection_model = RejectionModel(config)
    
    def submit_order(self, order, market_state):
        # 1. Latência EVT
        latency = self.latency_model.sample(market_state.condition)
        
        # 2. Preço após latência (mercado se moveu)
        price_movement = market_state.velocity * (latency / 1000)
        execution_price = order.price + price_movement
        
        # 3. Spread dinâmico
        spread = self.spread_model.get_spread(market_state)
        
        # 4. Slippage (sempre adverso)
        slippage = self.slippage_model.get_slippage(order.size)
        
        # 5. Rejeição
        if self.rejection_model.should_reject(market_state):
            return ExecutionResult(rejected=True)
        
        # Preço final
        if order.direction == 'BUY':
            final_price = execution_price + spread/2 + slippage
        else:
            final_price = execution_price - spread/2 - slippage
        
        return ExecutionResult(
            filled=True,
            fill_price=final_price,
            latency_ms=latency,
            spread_paid=spread,
            slippage=slippage
        )

CONFIGURAÇÕES:
├── OPTIMISTIC: latency 0.5x, spread 0.8x, slippage 0.5x
├── NORMAL: latency 1.0x, spread 1.0x, slippage 1.0x
├── PESSIMISTIC: latency 1.5x, spread 1.5x, slippage 2.0x
└── STRESS: latency 3.0x, spread 3.0x, slippage 5.0x
"
```

### 4.2 Portar Lógica do EA para Python

```
PROMPT PARA FORGE:

"Forge, porte a lógica ESSENCIAL do EA para Python:

ARQUIVO: scripts/backtest/strategies/ea_logic_python.py

PORTAR APENAS (para comparação Shadow vs MT5):

1. REGIME DETECTION (de CRegimeDetector):
   - Hurst R/S calculation (mesma implementação)
   - Shannon Entropy
   - Regime classification

2. SESSION DETECTION (de CSessionFilter):
   - Mapear hora para sessão
   - Filtro de horários

3. CONFLUENCE SCORING (de CConfluenceScorer):
   - Lógica de scoring simplificada
   - Threshold de 70 para entry

4. POSITION SIZING (de FTMO_RiskManager):
   - Risk per trade
   - Kelly ajustado por regime

OBJETIVO:
- Sinais do Python devem ser ~95% iguais aos do MQL5
- Diferenças aceitáveis: 1-2 ticks por latência de dados
- Se divergência > 5%: investigar bug
"
```

### 4.3 Checkpoint Fase 4

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHECKPOINT FASE 4                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SHADOW EXCHANGE:                                                          │
│  □ EVT Latency Model implementado (GPD para tails)                         │
│  □ Dynamic Spread Model funcionando                                        │
│  □ Rejection Model funcionando                                             │
│                                                                             │
│  PARIDADE MQL5 vs PYTHON:                                                  │
│  □ Lógica do EA portada                                                    │
│  □ >= 95% dos trades coincidem                                             │
│                                                                             │
│  RESULTADOS:                                                               │
│  □ Backtest Shadow NORMAL: PF >= 1.2                                       │
│  □ Backtest Shadow PESSIMISTIC: PF >= 1.0                                  │
│  □ Backtest Shadow STRESS: DD <= 15%                                       │
│  □ Divergência MT5 vs Shadow < 15%                                         │
│                                                                             │
│  GENIUS - TAIL RISK (Princípio #7):                                        │
│  □ Expected Shortfall calculado                                            │
│  □ P(latência > 500ms) documentado                                         │
│  □ Tail events no log                                                      │
│                                                                             │
│  SE TODOS ✅ → Prosseguir para FASE 5                                      │
│  SE divergência > 15% → Investigar e corrigir                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 5: VALIDAÇÃO ESTATÍSTICA INSTITUCIONAL

**Duração**: 3-4 dias
**Princípios GENIUS aplicados**: #1 (Kelly validation), #5 (Edge decay), #7 (EVT MC)

### 5.1 EVT Monte Carlo (Princípio #7)

```
PROMPT PARA FORGE:

"Forge, estenda scripts/oracle/monte_carlo.py para incluir EVT:

ADICIONAR classe EVTMonteCarlo:

class EVTMonteCarlo:
    '''
    Monte Carlo com tails modelados por EVT, não apenas bootstrap
    '''
    
    def __init__(self, trades_df, initial_capital=100000):
        self.trades = trades_df
        self.capital = initial_capital
        self.losses = trades_df[trades_df['profit'] < 0]['profit'].values
        
        # Fit GPD para losses extremos
        self._fit_gpd()
    
    def _fit_gpd(self):
        '''Fit Generalized Pareto Distribution para tail losses'''
        from scipy.stats import genpareto
        
        # Threshold = percentile 90 dos losses
        threshold = np.percentile(np.abs(self.losses), 90)
        tail_losses = [l for l in np.abs(self.losses) if l > threshold]
        
        if len(tail_losses) >= 10:
            excesses = np.array(tail_losses) - threshold
            self.gpd_params = genpareto.fit(excesses)
            self.gpd_threshold = threshold
            self.gpd_fitted = True
        else:
            self.gpd_fitted = False
    
    def sample_extreme_loss(self):
        '''Gera loss extremo da GPD fitted'''
        if not self.gpd_fitted:
            return np.random.choice(self.losses)
        
        from scipy.stats import genpareto
        excess = genpareto.rvs(*self.gpd_params)
        return -(self.gpd_threshold + excess)
    
    def run_evt_monte_carlo(self, n_simulations=5000, extreme_injection_rate=0.05):
        '''
        MC com injeção de eventos extremos baseados em EVT
        
        Args:
            n_simulations: número de simulações
            extreme_injection_rate: % das simulações com extremos injetados
        '''
        results = []
        
        for i in range(n_simulations):
            equity = self.capital
            peak = self.capital
            max_dd = 0
            
            shuffled = np.random.permutation(self.trades['profit'].values)
            
            # Injetar extremos em algumas simulações
            if np.random.random() < extreme_injection_rate:
                n_extremes = np.random.randint(1, 4)
                indices = np.random.choice(len(shuffled), n_extremes, replace=False)
                for idx in indices:
                    shuffled[idx] = self.sample_extreme_loss()
            
            for pnl in shuffled:
                equity += pnl
                peak = max(peak, equity)
                dd = (peak - equity) / peak
                max_dd = max(max_dd, dd)
            
            results.append({'max_dd': max_dd * 100, 'final': equity})
        
        max_dds = [r['max_dd'] for r in results]
        
        return {
            # Percentiles
            'dd_50th': np.percentile(max_dds, 50),
            'dd_95th': np.percentile(max_dds, 95),
            'dd_99th': np.percentile(max_dds, 99),
            
            # EVT metrics
            'var_95': np.percentile(max_dds, 95),
            'cvar_95': np.mean([d for d in max_dds if d >= np.percentile(max_dds, 95)]),
            'evt_tail_index': self.gpd_params[0] if self.gpd_fitted else None,
            
            # FTMO risk
            'p_daily_5pct': sum(1 for d in max_dds if d >= 5) / len(max_dds) * 100,
            'p_total_10pct': sum(1 for d in max_dds if d >= 10) / len(max_dds) * 100
        }

EXECUTAR:
1. MC Block Bootstrap (existente)
2. MC EVT (novo) - com injeção de extremos
3. Comparar resultados

CRITÉRIOS:
├── Block Bootstrap 95th DD < 8%
├── EVT MC 95th DD < 10% (mais conservador)
├── CVaR 95 < 12%
└── P(DD > 10%) < 5%
"
```

### 5.2 Edge Stability Analysis (Princípio #5)

```
PROMPT PARA FORGE:

"Forge, crie análise de estabilidade de edge:

ARQUIVO: scripts/oracle/edge_stability.py

class EdgeStabilityAnalyzer:
    '''
    Verifica se o edge é estável ou está decaindo
    '''
    
    def __init__(self, trades_df):
        self.trades = trades_df
    
    def rolling_metrics(self, window=50):
        '''Calcula métricas em janelas rolling'''
        profits = self.trades['profit'].values
        
        sharpes = []
        pfs = []
        
        for i in range(window, len(profits)):
            window_data = profits[i-window:i]
            
            wins = [p for p in window_data if p > 0]
            losses = [p for p in window_data if p < 0]
            
            # Rolling Sharpe
            if np.std(window_data) > 0:
                sharpe = np.mean(window_data) / np.std(window_data) * np.sqrt(252)
            else:
                sharpe = 0
            sharpes.append(sharpe)
            
            # Rolling PF
            if losses:
                pf = sum(wins) / abs(sum(losses)) if sum(losses) != 0 else 10
            else:
                pf = 10
            pfs.append(pf)
        
        return {'sharpes': sharpes, 'pfs': pfs}
    
    def detect_decay(self, threshold=0.3):
        '''Detecta se edge está decaindo'''
        metrics = self.rolling_metrics()
        
        # Comparar primeira metade vs segunda metade
        sharpes = metrics['sharpes']
        mid = len(sharpes) // 2
        
        first_half = np.mean(sharpes[:mid])
        second_half = np.mean(sharpes[mid:])
        
        decay_pct = (first_half - second_half) / first_half if first_half > 0 else 0
        
        return {
            'first_half_sharpe': first_half,
            'second_half_sharpe': second_half,
            'decay_pct': decay_pct * 100,
            'is_decaying': decay_pct > threshold,
            'action': 'RECALIBRATE' if decay_pct > threshold else 'CONTINUE'
        }
    
    def calculate_halflife(self):
        '''Estima meia-vida do edge (quantos trades até decair 50%)'''
        metrics = self.rolling_metrics()
        sharpes = metrics['sharpes']
        
        # Fit exponential decay
        from scipy.optimize import curve_fit
        
        def exp_decay(t, a, b):
            return a * np.exp(-b * t)
        
        try:
            x = np.arange(len(sharpes))
            popt, _ = curve_fit(exp_decay, x, sharpes, maxfev=5000)
            halflife = np.log(2) / popt[1]
            return {'halflife_trades': int(halflife), 'fitted': True}
        except:
            return {'halflife_trades': None, 'fitted': False}

OUTPUT: DOCS/04_REPORTS/VALIDATION/EDGE_STABILITY.md
"
```

### 5.3 CPCV para PBO (Probability of Backtest Overfitting)

```
PROMPT PARA FORGE:

"Forge, implemente Combinatorially Purged Cross-Validation para calcular PBO:

ARQUIVO: scripts/oracle/cpcv.py

CONCEITO:
CPCV é mais rigoroso que k-fold tradicional porque:
1. Testa TODAS as combinações possíveis de IS/OOS
2. Purga dados para evitar leakage temporal
3. Calcula probabilidade de que o melhor parâmetro foi sorte (PBO)

import numpy as np
import pandas as pd
from itertools import combinations
from typing import List, Dict, Tuple

class CPCV:
    '''
    Combinatorially Purged Cross-Validation
    
    Referência: Bailey & López de Prado (2014)
    "The Probability of Backtest Overfitting"
    '''
    
    def __init__(self, n_splits: int = 6, purge_pct: float = 0.01):
        '''
        Args:
            n_splits: número de grupos (N). Total de combinações = C(N, N//2)
            purge_pct: % dos dados a purgar entre IS e OOS
        '''
        self.n_splits = n_splits
        self.purge_pct = purge_pct
        self.results = []
    
    def split(self, X: pd.DataFrame) -> List[Tuple[np.ndarray, np.ndarray]]:
        '''
        Gera todas as combinações de IS/OOS splits
        
        Para n_splits=6: C(6,3) = 20 combinações
        '''
        n_samples = len(X)
        indices = np.arange(n_samples)
        
        # Dividir em N grupos
        group_size = n_samples // self.n_splits
        groups = [indices[i*group_size:(i+1)*group_size] for i in range(self.n_splits)]
        
        # Gerar todas as combinações de grupos para OOS
        n_oos = self.n_splits // 2
        splits = []
        
        for oos_groups in combinations(range(self.n_splits), n_oos):
            is_groups = [i for i in range(self.n_splits) if i not in oos_groups]
            
            # Índices IS e OOS
            is_idx = np.concatenate([groups[i] for i in is_groups])
            oos_idx = np.concatenate([groups[i] for i in oos_groups])
            
            # Purga: remover dados próximos à fronteira IS/OOS
            purge_size = int(len(X) * self.purge_pct)
            if purge_size > 0:
                # Ordenar para encontrar fronteiras
                is_max = is_idx.max()
                oos_min = oos_idx.min()
                
                # Remover dados na zona de purga
                is_idx = is_idx[is_idx < is_max - purge_size]
                oos_idx = oos_idx[oos_idx > oos_min + purge_size]
            
            splits.append((is_idx, oos_idx))
        
        return splits
    
    def calculate_pbo(self, is_sharpes: List[float], oos_sharpes: List[float]) -> Dict:
        '''
        Calcula PBO (Probability of Backtest Overfitting)
        
        PBO = P(rank OOS do melhor IS < median rank)
        
        Se PBO > 0.5: provavelmente overfitted
        '''
        n_configs = len(is_sharpes)
        
        # Rank por IS Sharpe (maior = melhor = rank 1)
        is_ranks = np.argsort(np.argsort(is_sharpes)[::-1]) + 1
        
        # Rank por OOS Sharpe
        oos_ranks = np.argsort(np.argsort(oos_sharpes)[::-1]) + 1
        
        # Encontrar o melhor por IS
        best_is_idx = np.argmin(is_ranks)
        best_is_oos_rank = oos_ranks[best_is_idx]
        
        # PBO simplificado: quantas configs IS-best tem OOS rank pior que median
        median_rank = n_configs / 2
        pbo = best_is_oos_rank / n_configs
        
        # Deflated Sharpe Ratio
        # Penaliza pelo número de trials
        best_oos_sharpe = oos_sharpes[best_is_idx]
        expected_max_sharpe = np.sqrt(2 * np.log(n_configs))  # Expectativa se random
        dsr = best_oos_sharpe / expected_max_sharpe if expected_max_sharpe > 0 else 0
        
        return {
            'pbo': pbo,
            'pbo_pct': pbo * 100,
            'interpretation': 'OVERFITTED' if pbo > 0.5 else 'LIKELY_VALID',
            'best_is_rank': int(is_ranks[best_is_idx]),
            'best_oos_rank': int(best_is_oos_rank),
            'n_configs': n_configs,
            'dsr': dsr,
            'dsr_interpretation': 'VALID' if dsr > 1 else 'SUSPECT'
        }

def run_cpcv_analysis(trades_df: pd.DataFrame, parameter_grid: Dict) -> Dict:
    '''
    Executa CPCV completo para um grid de parâmetros
    
    Args:
        trades_df: DataFrame com trades
        parameter_grid: Dict com parâmetros a testar
                       ex: {'sl_pips': [20, 30, 40], 'tp_pips': [40, 60, 80]}
    
    Returns:
        PBO e métricas de overfitting
    '''
    cpcv = CPCV(n_splits=6, purge_pct=0.01)
    splits = cpcv.split(trades_df)
    
    is_sharpes = []
    oos_sharpes = []
    
    # Para cada configuração de parâmetros
    for params in generate_param_combinations(parameter_grid):
        is_sharpe_sum = 0
        oos_sharpe_sum = 0
        
        for is_idx, oos_idx in splits:
            is_trades = trades_df.iloc[is_idx]
            oos_trades = trades_df.iloc[oos_idx]
            
            # Calcular Sharpe para esta config
            is_sharpe = calculate_sharpe(is_trades, **params)
            oos_sharpe = calculate_sharpe(oos_trades, **params)
            
            is_sharpe_sum += is_sharpe
            oos_sharpe_sum += oos_sharpe
        
        is_sharpes.append(is_sharpe_sum / len(splits))
        oos_sharpes.append(oos_sharpe_sum / len(splits))
    
    return cpcv.calculate_pbo(is_sharpes, oos_sharpes)

EXEMPLO DE USO:
  python scripts/oracle/cpcv.py \\
    --trades data/backtest_trades.csv \\
    --params '{"sl_pips": [20,30,40], "tp_pips": [40,60,80]}' \\
    --output DOCS/04_REPORTS/VALIDATION/PBO_REPORT.md

CRITÉRIOS:
├── PBO < 0.50: OK (provavelmente não overfit)
├── PBO < 0.40: BOM (edge provavelmente real)
├── PBO < 0.30: EXCELENTE (edge muito provável)
├── DSR > 1.0: Sharpe significativo dado # trials
└── DSR > 1.5: Sharpe muito significativo

OUTPUT: DOCS/04_REPORTS/VALIDATION/PBO_REPORT.md
"
```

### 5.4 GO/NO-GO GENIUS Scoring

```
PROMPT PARA FORGE:

"Forge, crie pipeline GO/NO-GO com scoring GENIUS:

ARQUIVO: scripts/oracle/go_nogo_genius.py

def calculate_genius_confidence_score(results):
    '''
    Score 0-100 integrando todos os 7 princípios GENIUS
    '''
    score = 0
    breakdown = {}
    
    # ========================================
    # PRINCÍPIO #1 - KELLY (15 pontos)
    # ========================================
    kelly = results.get('kelly_global', 0)
    if kelly >= 0.02:
        kelly_score = 15
    elif kelly >= 0.01:
        kelly_score = 10
    elif kelly > 0:
        kelly_score = 5
    else:
        kelly_score = 0
    breakdown['kelly'] = kelly_score
    score += kelly_score
    
    # ========================================
    # PRINCÍPIO #2 - CONVEXITY (15 pontos)
    # ========================================
    convexity = results.get('convexity_score', 0)
    if convexity >= 70:
        conv_score = 15
    elif convexity >= 60:
        conv_score = 10
    elif convexity >= 50:
        conv_score = 5
    else:
        conv_score = 0
    breakdown['convexity'] = conv_score
    score += conv_score
    
    # ========================================
    # PRINCÍPIO #3 - PHASE TRANSITIONS (10 pontos)
    # ========================================
    random_trades = results.get('random_regime_trades', 0)
    transition_handling = results.get('transition_dd', 100)
    
    if random_trades == 0 and transition_handling < 3:
        phase_score = 10
    elif random_trades == 0:
        phase_score = 7
    elif random_trades < 5:
        phase_score = 3
    else:
        phase_score = 0
    breakdown['phase_transitions'] = phase_score
    score += phase_score
    
    # ========================================
    # PRINCÍPIO #4 - FRACTALS/MTF (10 pontos)
    # ========================================
    mtf_wr_perfect = results.get('mtf_wr_perfect', 0)
    mtf_wr_weak = results.get('mtf_wr_weak', 0)
    
    if mtf_wr_perfect > mtf_wr_weak + 10:  # Perfect WR 10%+ melhor que Weak
        mtf_score = 10
    elif mtf_wr_perfect > mtf_wr_weak:
        mtf_score = 5
    else:
        mtf_score = 0
    breakdown['fractals_mtf'] = mtf_score
    score += mtf_score
    
    # ========================================
    # PRINCÍPIO #5 - EDGE DECAY (10 pontos)
    # ========================================
    edge_decay = results.get('edge_decay_pct', 100)
    halflife = results.get('edge_halflife', 0)
    
    if edge_decay < 10 and halflife > 100:
        edge_score = 10
    elif edge_decay < 20:
        edge_score = 7
    elif edge_decay < 30:
        edge_score = 3
    else:
        edge_score = 0
    breakdown['edge_stability'] = edge_score
    score += edge_score
    
    # ========================================
    # PRINCÍPIO #6 - ENSEMBLE DIVERSITY (10 pontos)
    # ========================================
    diversity = results.get('ensemble_diversity_score', 0)
    if diversity >= 60:
        ensemble_score = 10
    elif diversity >= 50:
        ensemble_score = 7
    elif diversity >= 40:
        ensemble_score = 3
    else:
        ensemble_score = 0
    breakdown['ensemble_diversity'] = ensemble_score
    score += ensemble_score
    
    # ========================================
    # PRINCÍPIO #7 - TAIL RISK/EVT (15 pontos)
    # ========================================
    evt_dd_95 = results.get('evt_mc_dd_95th', 100)
    cvar_95 = results.get('cvar_95', 100)
    
    if evt_dd_95 < 8 and cvar_95 < 10:
        tail_score = 15
    elif evt_dd_95 < 10:
        tail_score = 10
    elif evt_dd_95 < 12:
        tail_score = 5
    else:
        tail_score = 0
    breakdown['tail_risk'] = tail_score
    score += tail_score
    
    # ========================================
    # VALIDAÇÃO CLÁSSICA (15 pontos)
    # ========================================
    wfe = results.get('wfe_global', 0)
    psr = results.get('psr', 0)
    
    classic_score = 0
    if wfe >= 0.6:
        classic_score += 8
    elif wfe >= 0.5:
        classic_score += 5
    
    if psr >= 0.9:
        classic_score += 7
    elif psr >= 0.8:
        classic_score += 4
    
    breakdown['classic_validation'] = classic_score
    score += classic_score
    
    # ========================================
    # DECISÃO
    # ========================================
    if score >= 85:
        decision = 'STRONG_GO'
        recommendation = 'Full Kelly Half position sizing'
    elif score >= 75:
        decision = 'GO'
        recommendation = 'Kelly Quarter position sizing'
    elif score >= 65:
        decision = 'CAUTIOUS'
        recommendation = 'Kelly Quarter, reduced exposure'
    else:
        decision = 'NO_GO'
        recommendation = 'Do not proceed to live trading'
    
    return {
        'total_score': score,
        'breakdown': breakdown,
        'decision': decision,
        'recommendation': recommendation
    }
"
```

### 5.5 Checkpoint Fase 5

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHECKPOINT FASE 5                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  WFA:                                                                      │
│  □ WFE Global >= 0.60                                                      │
│  □ WFE Trending >= 0.65                                                    │
│  □ >= 70% OOS windows positivos                                            │
│                                                                             │
│  MONTE CARLO:                                                              │
│  □ Block Bootstrap 95th DD < 8%                                            │
│  □ EVT MC 95th DD < 10%                                                    │
│  □ CVaR 95 < 12%                                                           │
│  □ P(DD > 10%) < 5%                                                        │
│                                                                             │
│  OVERFITTING:                                                              │
│  □ PSR >= 0.90                                                             │
│  □ DSR > 0                                                                 │
│  □ PBO < 0.50 (via CPCV)                                                   │
│                                                                             │
│  GENIUS SCORING:                                                           │
│  □ Kelly score >= 10/15                                                    │
│  □ Convexity score >= 10/15                                                │
│  □ Phase Transitions score >= 7/10                                         │
│  □ Fractals/MTF score >= 5/10                                              │
│  □ Edge Stability score >= 7/10                                            │
│  □ Ensemble Diversity score >= 5/10                                        │
│  □ Tail Risk score >= 10/15                                                │
│  □ Classic Validation score >= 10/15                                       │
│                                                                             │
│  □ GENIUS Confidence Score >= 75                                           │
│  □ Decision = GO ou STRONG_GO                                              │
│                                                                             │
│  SE TODOS ✅ → Prosseguir para FASE 6                                      │
│  SE Score < 75 → Investigar weak points                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 6: STRESS TESTING EXTREMO

**Duração**: 2-3 dias
**Princípios GENIUS aplicados**: #3 (Phase Transitions), #7 (Tail Risk)

### 6.1 Catálogo de Stress Tests

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      6 STRESS TESTS OBRIGATÓRIOS                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TEST 1: NEWS_STORM                                                        │
│  ├── O que: 5 eventos de alto impacto em 2 semanas                         │
│  ├── Injeta: Spread 5x, latência 3x, rejection 30%                         │
│  ├── Verifica: CRegimeDetector detecta condição adversa                    │
│  └── Critério: DD < 8% OU sistema para de operar                           │
│                                                                             │
│  TEST 2: FLASH_CRASH (Princípio #7)                                        │
│  ├── O que: Gap de 3%+ em < 5 minutos contra posição                       │
│  ├── Injeta: SL saltado (gap > SL distance)                                │
│  ├── Verifica: FTMO_RiskManager detecta e reage                            │
│  └── Critério: DD < 5% por evento, recovery < 2 semanas                    │
│                                                                             │
│  TEST 3: CONNECTION_LOSS                                                   │
│  ├── O que: Desconexão de 30s a 5min durante trade                         │
│  ├── Injeta: Ordem enviada mas não confirmada                              │
│  ├── Verifica: Sistema reconcilia estado após reconectar                   │
│  └── Critério: DD adicional < 1%                                           │
│                                                                             │
│  TEST 4: REGIME_TRANSITION_RAPID (Princípio #3)                            │
│  ├── O que: 3+ mudanças de regime em 1 dia                                 │
│  ├── Injeta: Trending → Random → Reverting → Trending                      │
│  ├── Verifica: CRegimeDetector::transition_probability sobe                │
│  ├── Verifica: Sistema reduz/para exposição                                │
│  └── Critério: DD < 3% no dia de transições                                │
│                                                                             │
│  TEST 5: LIQUIDITY_DRYUP                                                   │
│  ├── O que: Spread 10x por 1 hora (sessão asia quiet)                      │
│  ├── Injeta: Custos proibitivos                                            │
│  ├── Verifica: CSessionFilter ou spread check bloqueia                     │
│  └── Critério: Sistema não opera OU aceita custos                          │
│                                                                             │
│  TEST 6: CIRCUIT_BREAKER_STRESS                                            │
│  ├── O que: Sequência de 5 losses que aproxima do limite                   │
│  ├── Injeta: Perdas crescentes                                             │
│  ├── Verifica: FTMO_RiskManager::m_new_trades_paused ativa                 │
│  └── Critério: CB ativa em 4% (não 5%), NUNCA viola                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Implementação do Stress Framework

```
PROMPT PARA FORGE:

"Forge, implemente framework de stress testing:

ARQUIVO: scripts/oracle/stress_framework.py

from dataclasses import dataclass
from typing import Dict, List, Callable
from enum import Enum
import numpy as np

class StressType(Enum):
    NEWS_STORM = 'news_storm'
    FLASH_CRASH = 'flash_crash'
    CONNECTION_LOSS = 'connection_loss'
    REGIME_TRANSITION = 'regime_transition'
    LIQUIDITY_DRYUP = 'liquidity_dryup'
    CIRCUIT_BREAKER = 'circuit_breaker'

@dataclass
class StressScenario:
    name: str
    stress_type: StressType
    duration_bars: int
    spread_multiplier: float
    latency_multiplier: float
    rejection_rate: float
    gap_pct: float = 0.0
    regime_sequence: List[str] = None
    
    @classmethod
    def news_storm(cls):
        return cls(
            name='NEWS_STORM_NFP_FOMC',
            stress_type=StressType.NEWS_STORM,
            duration_bars=100,  # ~8 horas em M5
            spread_multiplier=5.0,
            latency_multiplier=3.0,
            rejection_rate=0.30
        )
    
    @classmethod
    def flash_crash(cls):
        return cls(
            name='FLASH_CRASH_3PCT',
            stress_type=StressType.FLASH_CRASH,
            duration_bars=5,
            spread_multiplier=10.0,
            latency_multiplier=10.0,
            rejection_rate=0.50,
            gap_pct=0.03  # 3% gap
        )
    
    @classmethod
    def regime_transition_rapid(cls):
        return cls(
            name='REGIME_RAPID_TRANSITION',
            stress_type=StressType.REGIME_TRANSITION,
            duration_bars=288,  # 1 dia em M5
            spread_multiplier=1.5,
            latency_multiplier=1.0,
            rejection_rate=0.05,
            regime_sequence=['TRENDING', 'RANDOM', 'REVERTING', 'TRENDING']
        )
    
    @classmethod
    def liquidity_dryup(cls):
        return cls(
            name='LIQUIDITY_DRYUP_ASIA',
            stress_type=StressType.LIQUIDITY_DRYUP,
            duration_bars=12,  # 1 hora em M5
            spread_multiplier=10.0,
            latency_multiplier=2.0,
            rejection_rate=0.20
        )
    
    @classmethod
    def circuit_breaker_stress(cls):
        return cls(
            name='CIRCUIT_BREAKER_TEST',
            stress_type=StressType.CIRCUIT_BREAKER,
            duration_bars=50,
            spread_multiplier=1.0,
            latency_multiplier=1.0,
            rejection_rate=0.0
            # Injeta losses forçados via modify_trades()
        )

class StressTestRunner:
    '''
    Executa stress tests no ShadowExchange ou em dados históricos
    '''
    
    def __init__(self, shadow_exchange, ea_logic):
        self.exchange = shadow_exchange
        self.ea = ea_logic
        self.results = {}
    
    def inject_scenario(self, scenario: StressScenario, data: pd.DataFrame) -> pd.DataFrame:
        '''
        Injeta condições de stress nos dados
        '''
        stressed_data = data.copy()
        
        # Aplicar multiplicadores
        stressed_data['spread'] *= scenario.spread_multiplier
        stressed_data['latency'] *= scenario.latency_multiplier
        
        # Injetar gap se especificado
        if scenario.gap_pct > 0:
            gap_idx = len(stressed_data) // 2
            current_price = stressed_data.iloc[gap_idx]['mid_price']
            gap_amount = current_price * scenario.gap_pct
            
            # Aplicar gap
            stressed_data.loc[gap_idx:, 'bid'] -= gap_amount
            stressed_data.loc[gap_idx:, 'ask'] -= gap_amount
            stressed_data.loc[gap_idx:, 'mid_price'] -= gap_amount
        
        # Injetar transições de regime
        if scenario.regime_sequence:
            bars_per_regime = scenario.duration_bars // len(scenario.regime_sequence)
            for i, regime in enumerate(scenario.regime_sequence):
                start = i * bars_per_regime
                end = (i + 1) * bars_per_regime
                stressed_data.loc[start:end, 'injected_regime'] = regime
        
        return stressed_data
    
    def run_stress_test(self, scenario: StressScenario, 
                        base_trades: pd.DataFrame) -> Dict:
        '''
        Executa um cenário de stress e retorna métricas
        '''
        # Injetar stress
        stressed_data = self.inject_scenario(scenario, base_trades)
        
        # Simular EA no ambiente estressado
        results = self.ea.simulate(stressed_data, self.exchange)
        
        # Calcular métricas
        max_dd = self._calculate_max_dd(results['equity_curve'])
        recovery_bars = self._calculate_recovery_time(results['equity_curve'])
        
        # Verificar comportamento esperado
        checks = {
            'regime_detected': results.get('regime_changes_detected', 0) > 0,
            'circuit_breaker_triggered': results.get('cb_triggered', False),
            'trades_paused': results.get('trades_paused', False),
        }
        
        # Determinar PASS/FAIL baseado no tipo
        passed = self._evaluate_criteria(scenario, max_dd, recovery_bars, checks)
        
        return {
            'scenario': scenario.name,
            'max_dd_pct': max_dd * 100,
            'recovery_bars': recovery_bars,
            'checks': checks,
            'passed': passed,
            'details': results
        }
    
    def _evaluate_criteria(self, scenario: StressScenario, 
                          max_dd: float, recovery_bars: int, 
                          checks: Dict) -> bool:
        '''Avalia se o teste passou baseado nos critérios'''
        
        criteria = {
            StressType.NEWS_STORM: max_dd < 0.08,
            StressType.FLASH_CRASH: max_dd < 0.05,
            StressType.CONNECTION_LOSS: max_dd < 0.01,
            StressType.REGIME_TRANSITION: max_dd < 0.03 and checks['regime_detected'],
            StressType.LIQUIDITY_DRYUP: checks['trades_paused'] or max_dd < 0.02,
            StressType.CIRCUIT_BREAKER: checks['circuit_breaker_triggered'] and max_dd < 0.05,
        }
        
        return criteria.get(scenario.stress_type, False)
    
    def run_all_tests(self, base_trades: pd.DataFrame) -> Dict:
        '''Executa todos os 6 stress tests'''
        
        scenarios = [
            StressScenario.news_storm(),
            StressScenario.flash_crash(),
            StressScenario.regime_transition_rapid(),
            StressScenario.liquidity_dryup(),
            StressScenario.circuit_breaker_stress(),
        ]
        
        results = {}
        for scenario in scenarios:
            results[scenario.name] = self.run_stress_test(scenario, base_trades)
        
        # Sumário
        passed = sum(1 for r in results.values() if r['passed'])
        total = len(results)
        
        return {
            'tests': results,
            'passed': passed,
            'total': total,
            'all_passed': passed == total,
            'summary': f'{passed}/{total} stress tests PASSED'
        }

EXEMPLO DE USO:
  python scripts/oracle/stress_framework.py \\
    --trades data/backtest_trades.csv \\
    --output DOCS/04_REPORTS/VALIDATION/STRESS_REPORT.md

OUTPUT: DOCS/04_REPORTS/VALIDATION/STRESS_REPORT.md
"
```

### 6.3 Checkpoint Fase 6

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHECKPOINT FASE 6                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  □ NEWS_STORM: PASS (DD < 8%)                                              │
│  □ FLASH_CRASH: PASS (DD < 5% por evento)                                  │
│  □ CONNECTION_LOSS: PASS (reconcilia corretamente)                         │
│  □ REGIME_TRANSITION_RAPID: PASS (DD < 3%)                                 │
│  □ LIQUIDITY_DRYUP: PASS (não opera ou aceita)                             │
│  □ CIRCUIT_BREAKER_STRESS: PASS (ativa antes de violar)                    │
│                                                                             │
│  VERIFICAÇÃO GENIUS:                                                       │
│  □ CRegimeDetector.transition_probability detectou transições              │
│  □ FTMO_RiskManager.m_new_trades_paused funcionou                          │
│  □ Todos os módulos reagiram como esperado                                 │
│                                                                             │
│  SE TODOS PASS → Prosseguir para FASE 7                                    │
│  SE qualquer FAIL crítico → Corrigir antes de continuar                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 7: DEMO TRADING

**Duração**: 2+ semanas
**Princípio GENIUS aplicado**: #5 (Edge Decay Monitoring em Live)

### 7.0 AdaptiveKellySizer para Live Trading

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ADAPTIVE KELLY SIZER (LIVE TRADING)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CONCEITO:                                                                 │
│  Em live trading, Kelly deve se ADAPTAR baseado em:                        │
│  1. Performance recente (rolling window)                                   │
│  2. Drawdown atual                                                         │
│  3. Regime atual do mercado                                                │
│  4. Sessão atual                                                           │
│  5. Edge health (decay monitoring)                                         │
│                                                                             │
│  O EA JÁ TEM isto parcialmente em FTMO_RiskManager.mqh:                    │
│  - CalculateKellyFraction() com adaptive tracking                          │
│  - 6-factor sizing (regime, dd, session, momentum, ratchet)                │
│                                                                             │
│  ADICIONAR: Bridge para Python validation e live monitoring                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

```python
# scripts/live/adaptive_kelly_sizer.py

import numpy as np
from typing import Dict, List, Optional
from dataclasses import dataclass
from datetime import datetime

@dataclass
class TradeResult:
    """Resultado de um trade para tracking"""
    timestamp: datetime
    pnl: float
    pnl_pct: float
    regime: str
    session: str
    entry_score: float

class AdaptiveKellySizer:
    """
    Calculadora Kelly adaptativa para live trading.
    
    Sincroniza com FTMO_RiskManager.mqh mas adiciona:
    - Rolling performance tracking
    - Edge decay detection
    - Confidence-weighted sizing
    """
    
    def __init__(self, 
                 base_kelly: float = 0.02,
                 lookback_trades: int = 50,
                 min_kelly: float = 0.005,
                 max_kelly: float = 0.03):
        """
        Args:
            base_kelly: Kelly base do backtest (GO/NO-GO report)
            lookback_trades: Trades para rolling window
            min_kelly: Kelly mínimo (nunca abaixo disso se edge ok)
            max_kelly: Kelly máximo (cap de segurança)
        """
        self.base_kelly = base_kelly
        self.lookback = lookback_trades
        self.min_kelly = min_kelly
        self.max_kelly = max_kelly
        
        self.trades: List[TradeResult] = []
        self.daily_pnl: Dict[str, float] = {}
        
        # Baselines do backtest
        self.baseline_win_rate = 0.55
        self.baseline_payoff = 1.5
        self.baseline_sharpe = 1.5
    
    def add_trade(self, trade: TradeResult):
        """Adiciona trade ao histórico"""
        self.trades.append(trade)
        
        # Track daily PnL
        date_str = trade.timestamp.strftime('%Y-%m-%d')
        if date_str not in self.daily_pnl:
            self.daily_pnl[date_str] = 0
        self.daily_pnl[date_str] += trade.pnl
    
    def get_rolling_stats(self) -> Dict:
        """Estatísticas dos últimos N trades"""
        if len(self.trades) < 10:
            return {'error': 'Insufficient trades'}
        
        recent = self.trades[-self.lookback:] if len(self.trades) >= self.lookback else self.trades
        
        profits = [t.pnl for t in recent]
        wins = [t for t in recent if t.pnl > 0]
        losses = [t for t in recent if t.pnl < 0]
        
        win_rate = len(wins) / len(recent) if recent else 0
        avg_win = np.mean([t.pnl for t in wins]) if wins else 0
        avg_loss = abs(np.mean([t.pnl for t in losses])) if losses else 1
        payoff = avg_win / avg_loss if avg_loss > 0 else 0
        
        return {
            'n_trades': len(recent),
            'win_rate': win_rate,
            'payoff_ratio': payoff,
            'avg_pnl': np.mean(profits),
            'std_pnl': np.std(profits),
            'sharpe_rolling': np.mean(profits) / np.std(profits) * np.sqrt(252) if np.std(profits) > 0 else 0
        }
    
    def calculate_regime_multiplier(self, regime: str) -> float:
        """
        Multiplier por regime.
        Sincronizado com CRegimeDetector.mqh
        """
        multipliers = {
            'TRENDING': 1.2,      # Mais agressivo
            'RANGING': 0.8,       # Mais conservador  
            'REVERTING': 0.6,     # Bem conservador
            'RANDOM': 0.0,        # NÃO OPERAR
            'TRANSITIONING': 0.3  # Muito conservador
        }
        return multipliers.get(regime, 0.5)
    
    def calculate_session_multiplier(self, session: str) -> float:
        """
        Multiplier por sessão.
        Sincronizado com CSessionFilter.mqh
        """
        multipliers = {
            'OVERLAP': 1.2,   # Melhor sessão
            'LONDON': 1.0,    # Boa liquidez
            'NY': 0.9,        # OK
            'ASIA': 0.5,      # Cuidado
            'CLOSE': 0.3      # Evitar
        }
        return multipliers.get(session, 0.5)
    
    def calculate_dd_multiplier(self, current_dd_pct: float) -> float:
        """
        Multiplier por drawdown atual.
        Sincronizado com FTMO_RiskManager.mqh
        """
        if current_dd_pct < 2:
            return 1.0      # Tudo ok
        elif current_dd_pct < 3:
            return 0.8      # Reduzir um pouco
        elif current_dd_pct < 4:
            return 0.5      # Reduzir bastante
        elif current_dd_pct < 5:
            return 0.25     # Modo defensivo
        else:
            return 0.0      # PARAR
    
    def calculate_edge_health_multiplier(self) -> float:
        """
        Multiplier baseado na saúde do edge.
        Compara performance recente com baseline.
        """
        stats = self.get_rolling_stats()
        if 'error' in stats:
            return 0.5  # Conservador se dados insuficientes
        
        # Comparar com baselines
        wr_ratio = stats['win_rate'] / self.baseline_win_rate
        payoff_ratio = stats['payoff_ratio'] / self.baseline_payoff
        
        avg_ratio = (wr_ratio + payoff_ratio) / 2
        
        if avg_ratio >= 0.95:
            return 1.0      # Edge saudável
        elif avg_ratio >= 0.80:
            return 0.8      # Edge levemente degradado
        elif avg_ratio >= 0.65:
            return 0.5      # Edge degradando
        else:
            return 0.0      # Edge comprometido - PARAR
    
    def calculate_adaptive_kelly(self, 
                                  regime: str,
                                  session: str, 
                                  current_dd_pct: float,
                                  entry_score: float = 70) -> Dict:
        """
        Calcula Kelly adaptativo completo.
        
        Args:
            regime: Regime atual do mercado
            session: Sessão atual
            current_dd_pct: DD atual em %
            entry_score: Score de entrada (0-100)
        
        Returns:
            Dict com kelly_final e breakdown
        """
        # Multiplicadores
        regime_mult = self.calculate_regime_multiplier(regime)
        session_mult = self.calculate_session_multiplier(session)
        dd_mult = self.calculate_dd_multiplier(current_dd_pct)
        edge_mult = self.calculate_edge_health_multiplier()
        
        # Entry score multiplier (score >= 70 para entrar)
        score_mult = (entry_score / 100) if entry_score >= 70 else 0
        
        # Kelly final
        kelly_raw = self.base_kelly * regime_mult * session_mult * dd_mult * edge_mult * score_mult
        kelly_final = np.clip(kelly_raw, 0, self.max_kelly)
        
        # Garantir mínimo se todas as condições são favoráveis
        if regime_mult > 0 and dd_mult > 0 and edge_mult > 0 and score_mult > 0:
            kelly_final = max(kelly_final, self.min_kelly)
        
        return {
            'kelly_final': kelly_final,
            'kelly_pct': kelly_final * 100,
            'breakdown': {
                'base': self.base_kelly,
                'regime_mult': regime_mult,
                'session_mult': session_mult,
                'dd_mult': dd_mult,
                'edge_mult': edge_mult,
                'score_mult': score_mult
            },
            'action': 'TRADE' if kelly_final > 0 else 'SKIP',
            'reason': self._get_reason(regime_mult, dd_mult, edge_mult, score_mult)
        }
    
    def _get_reason(self, regime_mult, dd_mult, edge_mult, score_mult) -> str:
        """Retorna razão para a decisão"""
        if regime_mult == 0:
            return 'SKIP: Random regime'
        if dd_mult == 0:
            return 'SKIP: DD limit reached'
        if edge_mult == 0:
            return 'SKIP: Edge compromised'
        if score_mult == 0:
            return 'SKIP: Entry score too low'
        return 'OK: All conditions met'

    def get_position_recommendation(self,
                                     account_equity: float,
                                     regime: str,
                                     session: str,
                                     current_dd_pct: float,
                                     entry_score: float,
                                     sl_points: float,
                                     point_value: float = 0.01) -> Dict:
        """
        Recomendação completa de position size.
        
        Args:
            account_equity: Equity da conta
            regime: Regime atual
            session: Sessão atual  
            current_dd_pct: DD atual %
            entry_score: Score de entrada
            sl_points: SL em pontos
            point_value: Valor por ponto (XAUUSD = 0.01)
        
        Returns:
            Dict com lots, risk_amount, etc.
        """
        kelly = self.calculate_adaptive_kelly(regime, session, current_dd_pct, entry_score)
        
        if kelly['kelly_final'] == 0:
            return {
                'lots': 0,
                'action': kelly['action'],
                'reason': kelly['reason']
            }
        
        risk_pct = kelly['kelly_final']
        risk_amount = account_equity * risk_pct
        
        # Calcular lots baseado no SL
        sl_value = sl_points * point_value
        lots = risk_amount / sl_value if sl_value > 0 else 0
        
        # Arredondar para step mínimo (0.01)
        lots = round(lots, 2)
        
        return {
            'lots': lots,
            'risk_pct': risk_pct * 100,
            'risk_amount': risk_amount,
            'sl_points': sl_points,
            'kelly_breakdown': kelly['breakdown'],
            'action': kelly['action'],
            'reason': kelly['reason']
        }
```

### 7.1 Edge Decay Monitor em Live

```
IMPORTANTE: Em live, MONITORAR DECAY DO EDGE continuamente.

class LiveEdgeMonitor:
    '''
    Monitora se o edge está decaindo em tempo real.
    Se decay detectado → PARAR e recalibrar.
    '''
    
    def __init__(self, baseline_sharpe, baseline_pf, lookback=20):
        self.baseline_sharpe = baseline_sharpe
        self.baseline_pf = baseline_pf
        self.lookback = lookback
        self.recent_trades = []
    
    def add_trade(self, trade):
        self.recent_trades.append(trade)
        if len(self.recent_trades) > self.lookback:
            self.recent_trades.pop(0)
    
    def check_health(self):
        if len(self.recent_trades) < self.lookback:
            return {'status': 'INSUFFICIENT_DATA'}
        
        profits = [t.pnl for t in self.recent_trades]
        live_sharpe = np.mean(profits) / np.std(profits) * np.sqrt(252)
        
        wins = [p for p in profits if p > 0]
        losses = [p for p in profits if p < 0]
        live_pf = sum(wins) / abs(sum(losses)) if losses else 10
        
        sharpe_decay = (self.baseline_sharpe - live_sharpe) / self.baseline_sharpe
        pf_decay = (self.baseline_pf - live_pf) / self.baseline_pf
        
        if sharpe_decay > 0.3 or pf_decay > 0.3:
            return {
                'status': 'EDGE_DECAY_ALERT',
                'action': 'PAUSE_AND_RECALIBRATE',
                'sharpe_decay': sharpe_decay,
                'pf_decay': pf_decay
            }
        elif sharpe_decay > 0.15:
            return {
                'status': 'EDGE_DEGRADING',
                'action': 'REDUCE_SIZE',
                'sharpe_decay': sharpe_decay
            }
        else:
            return {
                'status': 'EDGE_HEALTHY',
                'action': 'CONTINUE'
            }

CONFIGURAR:
├── baseline_sharpe: Do GO/NO-GO report
├── baseline_pf: Do GO/NO-GO report
├── lookback: 20 trades
├── decay_threshold: 30%
```

### 7.2 Checkpoint Fase 7

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHECKPOINT FASE 7                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TÉCNICO:                                                                  │
│  □ EA rodou 2+ semanas sem crashes                                         │
│  □ ONNX inference funcionando                                              │
│  □ Sem erros críticos no log                                               │
│                                                                             │
│  EXECUÇÃO:                                                                 │
│  □ Trades executados corretamente                                          │
│  □ SL/TP funcionando                                                       │
│  □ Slippage real <= backtest + 5 pips                                      │
│                                                                             │
│  PERFORMANCE:                                                              │
│  □ DD nunca excedeu 4%                                                     │
│  □ Performance dentro de ±30% do backtest                                  │
│  □ Win rate dentro de ±10% do backtest                                     │
│                                                                             │
│  GENIUS - EDGE MONITORING (Princípio #5):                                  │
│  □ LiveEdgeMonitor configurado com baselines                               │
│  □ Status = EDGE_HEALTHY durante o período                                 │
│  □ Se EDGE_DEGRADING: tamanho foi reduzido                                 │
│  □ Se EDGE_DECAY_ALERT: trading foi pausado                                │
│                                                                             │
│  SE TODOS ✅ → Prosseguir para FASE 8                                      │
│  SE divergência > 30% → Investigar antes de continuar                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## FASE 8: CHALLENGE FTMO

**Duração**: 4+ semanas
**Todos os princípios GENIUS em ação!**

### 8.0 Rotina de Monitoramento Diário

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DAILY MONITORING ROUTINE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PRÉ-MERCADO (06:30 UTC - antes de London open):                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  □ Verificar Calendar econômico (DailyFX, Forex Factory)            │   │
│  │  □ Identificar eventos High Impact próximas 24h                     │   │
│  │  □ Verificar gaps overnight no XAUUSD                               │   │
│  │  □ Conferir spread atual vs normal (se > 50 cents = ALERTA)         │   │
│  │  □ Verificar status do EA (running, no errors)                      │   │
│  │  □ Conferir DD atual vs limites                                     │   │
│  │  □ Verificar LiveEdgeMonitor status                                 │   │
│  │                                                                     │   │
│  │  SE algum item vermelho → MODO CONSERVADOR                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  DURANTE SESSÃO (verificar a cada 4 horas):                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  □ Daily PnL atual                                                  │   │
│  │  □ Número de trades executados                                      │   │
│  │  □ Win rate do dia                                                  │   │
│  │  □ Regime atual do mercado (via CRegimeDetector)                    │   │
│  │  □ Sessão atual e próxima transição                                 │   │
│  │  □ Posições abertas e P&L unrealized                                │   │
│  │  □ Verificar se circuit breaker ativou                              │   │
│  │                                                                     │   │
│  │  SE DD diário > 3% → MODO DEFENSIVO                                 │   │
│  │  SE DD diário > 4% → PARAR operações do dia                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  FIM DO DIA (21:00 UTC - após NY close):                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  □ Registrar PnL do dia                                             │   │
│  │  □ Registrar total de trades                                        │   │
│  │  □ Calcular win rate do dia                                         │   │
│  │  □ Verificar se dentro do esperado (backtest ±30%)                  │   │
│  │  □ Atualizar planilha de acompanhamento                             │   │
│  │  □ Verificar DD total vs limites                                    │   │
│  │  □ Decidir sizing para amanhã baseado em DD                         │   │
│  │  □ Verificar edge health                                            │   │
│  │                                                                     │   │
│  │  SE performance muito fora do esperado → INVESTIGAR                 │   │
│  │  SE DD total > 6% → MODO ULTRA-CONSERVADOR amanhã                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  SEMANAL (Sexta após close ou Domingo):                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  □ Calcular métricas semanais (PF, Sharpe, WR)                      │   │
│  │  □ Comparar com backtest (dentro de ±20%?)                          │   │
│  │  □ Verificar edge decay (performance degradando?)                   │   │
│  │  □ Revisar trades e identificar patterns                            │   │
│  │  □ Ajustar parâmetros se necessário (com cautela)                   │   │
│  │  □ Planejar próxima semana                                          │   │
│  │                                                                     │   │
│  │  SE edge decaindo > 20% → Considerar PAUSA                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.0.1 Contingências por Nível de Drawdown

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DD CONTINGENCY ACTIONS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  NÍVEIS DE DD E AÇÕES CORRESPONDENTES:                                     │
│                                                                             │
│  ┌────────────┬────────────────────────────────────────────────────────┐   │
│  │ DD Level   │ Ações                                                  │   │
│  ├────────────┼────────────────────────────────────────────────────────┤   │
│  │            │                                                        │   │
│  │ 0% - 2%    │ NORMAL OPERATION                                       │   │
│  │            │ - Kelly standard (backtest-derived)                    │   │
│  │            │ - Todos os regimes exceto RANDOM                       │   │
│  │            │ - Todas as sessões habilitadas                         │   │
│  │            │                                                        │   │
│  ├────────────┼────────────────────────────────────────────────────────┤   │
│  │            │                                                        │   │
│  │ 2% - 3%    │ CAUTION MODE                                           │   │
│  │            │ - Reduzir Kelly para 80%                               │   │
│  │            │ - Apenas TRENDING e OVERLAP                            │   │
│  │            │ - Entry score mínimo: 75 (vs 70 normal)                │   │
│  │            │ - Verificar edge health mais frequente                 │   │
│  │            │                                                        │   │
│  ├────────────┼────────────────────────────────────────────────────────┤   │
│  │            │                                                        │   │
│  │ 3% - 4%    │ DEFENSIVE MODE                                         │   │
│  │            │ - Reduzir Kelly para 50%                               │   │
│  │            │ - Apenas TRENDING regime                               │   │
│  │            │ - Apenas OVERLAP e LONDON sessions                     │   │
│  │            │ - Entry score mínimo: 80                               │   │
│  │            │ - Máximo 2 trades/dia                                  │   │
│  │            │                                                        │   │
│  ├────────────┼────────────────────────────────────────────────────────┤   │
│  │            │                                                        │   │
│  │ 4% - 5%    │ RECOVERY MODE                                          │   │
│  │            │ - Reduzir Kelly para 25%                               │   │
│  │            │ - Apenas sinais Tier A (score >= 85)                   │   │
│  │            │ - Máximo 1 trade/dia                                   │   │
│  │            │ - Considerar PAUSAR até próximo dia                    │   │
│  │            │ - ALERTA: Próximo do limite FTMO Daily (5%)            │   │
│  │            │                                                        │   │
│  ├────────────┼────────────────────────────────────────────────────────┤   │
│  │            │                                                        │   │
│  │ > 5%       │ CIRCUIT BREAKER (Hard Stop Daily)                      │   │
│  │            │ - PARAR IMEDIATAMENTE                                  │   │
│  │            │ - Fechar posições abertas                              │   │
│  │            │ - Não operar até próximo dia                           │   │
│  │            │ - Revisar o que aconteceu                              │   │
│  │            │ - VIOLAÇÃO FTMO se não parou a tempo                   │   │
│  │            │                                                        │   │
│  └────────────┴────────────────────────────────────────────────────────┘   │
│                                                                             │
│  DD TOTAL (além do diário):                                                │
│                                                                             │
│  ┌────────────┬────────────────────────────────────────────────────────┐   │
│  │ DD Total   │ Ações                                                  │   │
│  ├────────────┼────────────────────────────────────────────────────────┤   │
│  │            │                                                        │   │
│  │ 0% - 4%    │ Normal operation com monitoramento                     │   │
│  │            │                                                        │   │
│  │ 4% - 6%    │ Reduzir Kelly para 60% do normal                       │   │
│  │            │ Aumentar entry score mínimo para 75                    │   │
│  │            │                                                        │   │
│  │ 6% - 8%    │ ULTRA-CONSERVADOR                                      │   │
│  │            │ Kelly 25%, apenas Tier A signals                       │   │
│  │            │ Considerar pausa de 1-2 dias para reavaliação          │   │
│  │            │                                                        │   │
│  │ 8% - 9%    │ PARAR TRADING                                          │   │
│  │            │ NUNCA arriscar os últimos 2%                           │   │
│  │            │ Aceitar a perda do challenge                           │   │
│  │            │ Melhor perder 9% que 10% (conta terminada)             │   │
│  │            │                                                        │   │
│  │ > 10%      │ CONTA TERMINADA (FTMO violation)                       │   │
│  │            │ Analisar o que deu errado                              │   │
│  │            │ Recalibrar antes de novo challenge                     │   │
│  │            │                                                        │   │
│  └────────────┴────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.0.2 Tabela de Configurações de Stress

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STRESS CONFIGURATION TABLE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CONFIGURAÇÕES PARA BACKTEST E SIMULAÇÃO:                                  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Parâmetro          │ Normal  │ Pessimistic │ Stress   │ Black Swan │   │
│  ├────────────────────┼─────────┼─────────────┼──────────┼────────────┤   │
│  │                    │         │             │          │            │   │
│  │ SPREAD             │         │             │          │            │   │
│  │ - Base (cents)     │ 20      │ 35          │ 60       │ 200        │   │
│  │ - Multiplier       │ 1.0x    │ 1.5x        │ 3.0x     │ 10.0x      │   │
│  │                    │         │             │          │            │   │
│  │ SLIPPAGE           │         │             │          │            │   │
│  │ - Avg (pips)       │ 1       │ 3           │ 8        │ 30         │   │
│  │ - Max (pips)       │ 5       │ 10          │ 25       │ 100        │   │
│  │                    │         │             │          │            │   │
│  │ LATENCY            │         │             │          │            │   │
│  │ - Mean (ms)        │ 25      │ 50          │ 150      │ 500        │   │
│  │ - P99 (ms)         │ 100     │ 250         │ 800      │ 3000       │   │
│  │ - GC pause prob    │ 1%      │ 3%          │ 10%      │ 30%        │   │
│  │                    │         │             │          │            │   │
│  │ REJECTION          │         │             │          │            │   │
│  │ - Rate             │ 2%      │ 8%          │ 20%      │ 50%        │   │
│  │ - Requote rate     │ 1%      │ 5%          │ 15%      │ 40%        │   │
│  │                    │         │             │          │            │   │
│  │ EXECUTION          │         │             │          │            │   │
│  │ - Fill rate        │ 98%     │ 92%         │ 80%      │ 50%        │   │
│  │ - Partial fills    │ No      │ 5%          │ 20%      │ 50%        │   │
│  │                    │         │             │          │            │   │
│  │ GAPS               │         │             │          │            │   │
│  │ - Gap prob/day     │ 0.1%    │ 0.5%        │ 2%       │ 10%        │   │
│  │ - Max gap size     │ 0.5%    │ 1%          │ 2%       │ 5%         │   │
│  │                    │         │             │          │            │   │
│  │ REGIME CHANGE      │         │             │          │            │   │
│  │ - Transitions/day  │ 1       │ 2           │ 5        │ 10         │   │
│  │ - False signals    │ 5%      │ 10%         │ 20%      │ 40%        │   │
│  │                    │         │             │          │            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  QUANDO USAR CADA CONFIGURAÇÃO:                                            │
│                                                                             │
│  NORMAL:      Backtest padrão, validação inicial                           │
│  PESSIMISTIC: Monte Carlo, WFA OOS, Shadow Exchange                        │
│  STRESS:      Stress testing antes de GO-LIVE                              │
│  BLACK SWAN:  Verificar se sistema sobrevive a extremos                    │
│                                                                             │
│  CRITÉRIOS DE APROVAÇÃO POR CONFIGURAÇÃO:                                  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Config       │ PF Min │ Max DD │ WFE Min │ Win Rate │ Status       │   │
│  ├──────────────┼────────┼────────┼─────────┼──────────┼──────────────┤   │
│  │ NORMAL       │ 1.30   │ 12%    │ 0.60    │ 52%      │ OBRIGATÓRIO  │   │
│  │ PESSIMISTIC  │ 1.10   │ 15%    │ 0.50    │ 48%      │ OBRIGATÓRIO  │   │
│  │ STRESS       │ 0.90   │ 20%    │ 0.40    │ 45%      │ RECOMENDADO  │   │
│  │ BLACK SWAN   │ N/A    │ <100%  │ N/A     │ N/A      │ SURVIVAL OK  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  NOTA: Black Swan não precisa ser lucrativo, apenas NÃO EXPLODIR           │
│  (sobreviver = não perder 100% da conta)                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.1 Regras FTMO ($100k)

```
PHASE 1 (30 dias):
├── Profit Target: 10% ($10,000)
├── Max Daily Loss: 5% ($5,000) → Nosso buffer: 4%
├── Max Total Loss: 10% ($10,000) → Nosso buffer: 8%
└── Min Trading Days: 4

PHASE 2 (60 dias):
├── Profit Target: 5% ($5,000)
└── Mesmos limites de DD

BUFFERS IMPLEMENTADOS NO EA:
├── FTMO_RiskManager::m_soft_stop_percent = 4.0 (daily)
├── FTMO_RiskManager::m_total_soft_stop_percent = 8.0 (total)
└── Circuit Breaker ativa ANTES de violar
```

### 8.2 Position Sizing com Kelly Adaptativo

```
Durante FTMO, usar Kelly do FTMO_RiskManager:

// Já implementado no EA:
double risk = g_RiskManager.CalculateGeniusRisk();

// CalculateGeniusRisk() já faz:
// 1. Kelly base (se m_use_adaptive_kelly = true)
// 2. × Regime multiplier (de CRegimeDetector)
// 3. × DD adjustment (reduz quando DD alto)
// 4. × Session multiplier (overlap 1.2x, asia 0.5x)
// 5. × Momentum multiplier (streak adjustment)
// 6. × Ratchet multiplier (profit protection)

RESULTADO: Position sizing adaptativo que já incorpora 6 fatores GENIUS
```

### 8.3 Contingências

```
SE DD DIÁRIO > 3%:
├── Verificar LiveEdgeMonitor
├── Se EDGE_HEALTHY: Reduzir risk para 0.25%
├── Se EDGE_DEGRADING: PAUSAR por 1 dia

SE DD TOTAL > 6%:
├── Modo ultra-conservador
├── Risk 0.25% max
├── Apenas sinais Tier A (score >= 85)

SE DD TOTAL > 8%:
├── PARAR completamente
├── Aceitar a perda do challenge
├── NUNCA arriscar os últimos 2%
```

---

## CHECKLIST GERAL UNIFICADO

### Por Fase

| Fase | Status | Princípios GENIUS | Critério Principal |
|------|--------|-------------------|-------------------|
| 0 | ✅ | - | Score médio 19.5/20 |
| 1 | ⬜ | #3, #4 | Quality Score >= 90 |
| 2 | ⬜ | #1, #2, #3, #4 | PF >= 1.3, Kelly positivo |
| 3 | ⬜ | #5, #6 | Accuracy > 55%, Diversity >= 50 |
| 4 | ⬜ | #7 | Divergência < 15% |
| 5 | ⬜ | #1, #5, #7 | Confidence >= 75 |
| 6 | ⬜ | #3, #7 | Todos stress PASS |
| 7 | ⬜ | #5 | Edge healthy 2 semanas |
| 8 | ⬜ | TODOS | FUNDED! |

### Scripts a Criar (Ordenados por Dependência)

```
ORDEM DE IMPLEMENTAÇÃO (v5.2 CORRIGIDA):

FASE 1 (PRÉ-REQUISITO PARA TUDO):
  1.1 convert_tick_data.py   →  🆕 CRIAR: CSV 24GB → Parquet
  1.2 validate_data.py       →  🔄 ESTENDER: +Regime/MTF/Session validation

FASE 2 (DEPENDE DE FASE 1):
  2.1 segment_data.py        →  🆕 CRIAR: Segmenta por regime/sessão
  2.2 tick_backtester.py     →  🔄 ESTENDER: +Kelly/Convexity collectors

FASE 3 (DEPENDE DE FASE 2):
  3.1 feature_engineering.py →  🆕 CRIAR: 15 features para ML
  3.2 train_wfa.py           →  🆕 CRIAR: Treina LSTM com Walk-Forward
  3.3 export_onnx.py         →  🆕 CRIAR: Exporta modelo ONNX
  3.4 metrics.py             →  🔄 ESTENDER: +Kelly/Convexity metrics

FASE 4 (PARALELO COM FASE 3):
  4.1 shadow_exchange.py     →  🆕 CRIAR: Exchange emulator com EVT latency
  4.2 ea_logic_python.py     →  🆕 CRIAR: Port da lógica do EA
  4.3 execution_simulator.py →  🔄 ESTENDER: +EVT latency model

FASE 5 (DEPENDE DE FASES 2-4):
  5.1 walk_forward.py        →  🔄 ESTENDER: +WFE por regime × sessão
  5.2 monte_carlo.py         →  🔄 ESTENDER: +EVT com GPD para tails
  5.3 go_nogo_validator.py   →  🔄 ESTENDER: +GENIUS 7-principle scoring
  5.4 deflated_sharpe.py     →  ✅ PRONTO (PSR, DSR, MinTRL completo)

FASE 6 (DEPENDE DE FASE 5):
  6.1 stress_framework.py    →  🆕 CRIAR: 6 cenários de stress

FASE 7 (DEPENDE DE FASE 6):
  7.1 adaptive_kelly_sizer.py → 🆕 CRIAR: Kelly adaptativo live
  7.2 live_edge_monitor.py    → 🆕 CRIAR: Monitor em tempo real
```

| Script | Localização | Fase | Status | Ação | Depende De |
|--------|-------------|------|--------|------|------------|
| `convert_tick_data.py` | scripts/data/ | 1 | 🆕 | CRIAR | - |
| `validate_data.py` | scripts/ | 1 | 🔄 | ESTENDER | convert_tick |
| `segment_data.py` | scripts/backtest/ | 2 | 🆕 | CRIAR | validate |
| `tick_backtester.py` | scripts/backtest/ | 2 | 🔄 | ESTENDER | segment |
| `feature_engineering.py` | scripts/ml/ | 3 | 🆕 | CRIAR | segment |
| `train_wfa.py` | scripts/ml/ | 3 | 🆕 | CRIAR | features |
| `export_onnx.py` | scripts/ml/ | 3 | 🆕 | CRIAR | train |
| `metrics.py` | scripts/oracle/ | 3 | 🔄 | ESTENDER | backtest |
| `shadow_exchange.py` | scripts/backtest/ | 4 | 🆕 | CRIAR | - |
| `ea_logic_python.py` | scripts/backtest/strategies/ | 4 | 🆕 | CRIAR | - |
| `execution_simulator.py` | scripts/oracle/ | 4 | 🔄 | ESTENDER | - |
| `walk_forward.py` | scripts/oracle/ | 5 | 🔄 | ESTENDER | backtest |
| `monte_carlo.py` | scripts/oracle/ | 5 | 🔄 | ESTENDER | backtest |
| `go_nogo_validator.py` | scripts/oracle/ | 5 | 🔄 | ESTENDER | all above |
| `deflated_sharpe.py` | scripts/oracle/ | 5 | ✅ | PRONTO | - |
| `prop_firm_validator.py` | scripts/oracle/ | 5 | ✅ | PRONTO | - |
| `confidence.py` | scripts/oracle/ | 5 | ✅ | PRONTO | - |
| `stress_framework.py` | scripts/oracle/ | 6 | 🆕 | CRIAR | shadow |
| `adaptive_kelly_sizer.py` | scripts/live/ | 7 | 🆕 | CRIAR | go_nogo |
| `live_edge_monitor.py` | scripts/live/ | 7 | 🆕 | CRIAR | go_nogo |

**Total: 20 scripts mapeados**
- 🆕 CRIAR: 10 scripts (~40-50h)
- 🔄 ESTENDER: 8 scripts (~15-20h)  
- ✅ PRONTO: 8 scripts (0h - já funcionam)

**Legenda:**
- 🆕 CRIAR: Script não existe, implementar do zero
- 🔄 ESTENDER: Script existe, adicionar features GENIUS
- ✅ PRONTO: Script completo, pronto para uso

---

## RESUMO EXECUTIVO FINAL (v5.2)

Este plano v5.2 unifica:

1. **Estrutura prática do v2.0**: Scripts, prompts, checkpoints, tabelas
2. **7 princípios GENIUS do v3.0**: Kelly, Convexity, Phase Transitions, Fractals, Information Theory, Ensemble, Tail Risk
3. **Código existente do EA**: CRegimeDetector, FTMO_RiskManager, CMTFManager, CConfluenceScorer
4. **AUDITORIA v5.2**: Inventário preciso de scripts existentes vs a criar

**O que NÃO precisa reimplementar** (já existe no EA MQL5):
- Kelly adaptive (6-factor)
- Regime transition detection
- MTF alignment
- Shannon Entropy
- Multi-factor confluence scoring

**O que NÃO precisa reimplementar** (já existe em Python - scripts/oracle/):
- `walk_forward.py` (398 linhas) - Rolling WFA, Anchored, Purge, WFE
- `monte_carlo.py` (486 linhas) - Block Bootstrap, VaR, CVaR
- `deflated_sharpe.py` (271 linhas) - PSR, DSR, MinTRL, PBO
- `go_nogo_validator.py` (570 linhas) - Integração completa
- `tick_backtester.py` (1014 linhas) - Event-driven backtest
- `validate_data.py` (733 linhas) - Validação de dados

**O que PRECISA criar (10 scripts novos):**
- `convert_tick_data.py` - CSV 24GB → Parquet (CRÍTICO)
- `segment_data.py` - Segmentação regime × sessão
- `feature_engineering.py` - 15 features para ONNX
- `train_wfa.py` - Training com Walk-Forward
- `export_onnx.py` - Export modelo ONNX
- `shadow_exchange.py` - Exchange emulator com EVT
- `ea_logic_python.py` - Port da lógica do EA
- `stress_framework.py` - 6 cenários de stress
- `adaptive_kelly_sizer.py` - Kelly adaptativo live
- `live_edge_monitor.py` - Monitor real-time

**O que PRECISA estender (8 scripts existentes):**
- `validate_data.py` → +Regime transitions, MTF consistency, Session coverage
- `tick_backtester.py` → +Kelly collector, Convexity metrics
- `monte_carlo.py` → +EVT com GPD para tails
- `walk_forward.py` → +WFE por regime × sessão
- `go_nogo_validator.py` → +GENIUS 7-principle scoring
- `metrics.py` → +Kelly, Convexity metrics
- `execution_simulator.py` → +EVT latency model

**ESFORÇO TOTAL ESTIMADO:**
- 🆕 CRIAR: ~40-50 horas
- 🔄 ESTENDER: ~15-20 horas
- **TOTAL: ~55-70 horas de desenvolvimento**

**Diferencial v5.2**: Agora sabemos EXATAMENTE o que existe, o que criar, e o que estender. Não há mais ambiguidade.

---

## GAPS E MELHORIAS IDENTIFICADOS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              ANÁLISE PROFUNDA DE GAPS - v5.1 AUDIT                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Data da Análise: 2025-12-01                                               │
│  Metodologia: Revisão completa linha por linha (3,331 linhas)              │
│  Total de Gaps: 48                                                         │
│  Criticidade: 12 Críticos, 21 Altos, 11 Médios, 4 Baixos                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-1: Scripts - AUDITORIA CORRIGIDA v5.2

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  RECLASSIFICAÇÃO BASEADA EM AUDITORIA REAL (2025-12-01)                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ⚠️ CORREÇÃO: A análise anterior estava DESATUALIZADA.                     │
│  Muitos scripts listados como "a criar" JÁ EXISTEM.                        │
│                                                                             │
│  LEGENDA:                                                                  │
│  🆕 CRIAR   = Script não existe, criar do zero                             │
│  🔄 ESTENDER = Script existe, adicionar features GENIUS                     │
│  ✅ PRONTO  = Script existe e está completo                                │
│                                                                             │
│  ┌──────────────────────────┬────────┬──────────────┬─────────────────────┐│
│  │ Script                   │ Status │ Ação         │ Prioridade          ││
│  ├──────────────────────────┼────────┼──────────────┼─────────────────────┤│
│  │                                                                        ││
│  │ FASE 1 - DATA:                                                         ││
│  │ convert_tick_data.py     │ 🆕     │ CRIAR        │ CRÍTICA (blocker)   ││
│  │ validate_data.py         │ 🔄     │ ESTENDER     │ ALTA                ││
│  │   (733 linhas existem)   │        │ +GENIUS      │                     ││
│  │                                                                        ││
│  │ FASE 2 - BACKTEST:                                                     ││
│  │ segment_data.py          │ 🆕     │ CRIAR        │ ALTA                ││
│  │ tick_backtester.py       │ 🔄     │ ESTENDER     │ ALTA                ││
│  │   (1014 linhas existem)  │        │ +Kelly/Conv  │                     ││
│  │                                                                        ││
│  │ FASE 3 - ML:                                                           ││
│  │ feature_engineering.py   │ 🆕     │ CRIAR        │ ALTA                ││
│  │ train_wfa.py             │ 🆕     │ CRIAR        │ ALTA                ││
│  │ export_onnx.py           │ 🆕     │ CRIAR        │ ALTA                ││
│  │                                                                        ││
│  │ FASE 4 - SHADOW:                                                       ││
│  │ shadow_exchange.py       │ 🆕     │ CRIAR        │ ALTA                ││
│  │ ea_logic_python.py       │ 🆕     │ CRIAR        │ ALTA                ││
│  │ execution_simulator.py   │ 🔄     │ ESTENDER     │ MÉDIA               ││
│  │   (16KB existe)          │        │ +EVT latency │                     ││
│  │                                                                        ││
│  │ FASE 5 - ORACLE:                                                       ││
│  │ walk_forward.py          │ 🔄     │ ESTENDER     │ MÉDIA               ││
│  │   (398 linhas existem)   │        │ +Seg WFE     │                     ││
│  │ monte_carlo.py           │ 🔄     │ ESTENDER     │ ALTA                ││
│  │   (486 linhas existem)   │        │ +EVT/GPD     │                     ││
│  │ go_nogo_validator.py     │ 🔄     │ ESTENDER     │ ALTA                ││
│  │   (570 linhas existem)   │        │ +GENIUS 7    │                     ││
│  │ deflated_sharpe.py       │ ✅     │ PRONTO       │ -                   ││
│  │   (271 linhas, completo) │        │              │                     ││
│  │ metrics.py               │ 🔄     │ ESTENDER     │ MÉDIA               ││
│  │   (11KB existe)          │        │ +Kelly/Conv  │                     ││
│  │                                                                        ││
│  │ FASE 6 - STRESS:                                                       ││
│  │ stress_framework.py      │ 🆕     │ CRIAR        │ MÉDIA               ││
│  │                                                                        ││
│  │ FASE 7 - LIVE:                                                         ││
│  │ adaptive_kelly_sizer.py  │ 🆕     │ CRIAR        │ MÉDIA               ││
│  │ live_edge_monitor.py     │ 🆕     │ CRIAR        │ MÉDIA               ││
│  │                                                                        ││
│  └──────────────────────────┴────────┴──────────────┴─────────────────────┘│
│                                                                             │
│  RESUMO:                                                                   │
│  - 🆕 CRIAR:    10 scripts                                                 │
│  - 🔄 ESTENDER: 8 scripts (código já existe!)                              │
│  - ✅ PRONTO:   8 scripts (100% completos)                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-2: Funções e Classes Auxiliares Faltantes (8 gaps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  FUNÇÕES USADAS MAS NÃO DEFINIDAS                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FUNÇÕES HELPER (usadas em scripts mas não implementadas):                 │
│                                                                             │
│  1. calculate_sharpe(trades_df, **params)                                  │
│     └── Usado em: cpcv.py, edge_stability.py, go_nogo_genius.py            │
│     └── Prioridade: CRÍTICA                                                │
│                                                                             │
│  2. generate_param_combinations(parameter_grid)                            │
│     └── Usado em: cpcv.py                                                  │
│     └── Prioridade: ALTA                                                   │
│                                                                             │
│  3. _calculate_max_dd(equity_curve)                                        │
│     └── Usado em: stress_framework.py, monte_carlo_evt.py                  │
│     └── Prioridade: ALTA                                                   │
│                                                                             │
│  4. _calculate_recovery_time(equity_curve)                                 │
│     └── Usado em: stress_framework.py                                      │
│     └── Prioridade: MÉDIA                                                  │
│                                                                             │
│  CLASSES AUXILIARES (mencionadas mas não implementadas):                   │
│                                                                             │
│  5. class DynamicSpreadModel                                               │
│     └── Usado em: shadow_exchange.py                                       │
│     └── Função: Modelar spread dinâmico por condição de mercado            │
│     └── Prioridade: ALTA                                                   │
│                                                                             │
│  6. class SlippageModel                                                    │
│     └── Usado em: shadow_exchange.py                                       │
│     └── Função: Modelar slippage por volume e volatilidade                 │
│     └── Prioridade: ALTA                                                   │
│                                                                             │
│  7. class RejectionModel                                                   │
│     └── Usado em: shadow_exchange.py                                       │
│     └── Função: Modelar rejeições de ordem por condição                    │
│     └── Prioridade: ALTA                                                   │
│                                                                             │
│  8. @dataclass ExecutionResult                                             │
│     └── Usado em: shadow_exchange.py                                       │
│     └── Função: Resultado de execução de ordem                             │
│     └── Prioridade: ALTA                                                   │
│                                                                             │
│  AÇÃO: Implementar cada função/classe com spec completa                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-3: Integração MQL5 ↔ Python Não Especificada (5 gaps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  INTEGRAÇÃO ENTRE SISTEMAS NÃO DOCUMENTADA                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GAP-3.1: TRADE EXPORT                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Pergunta: Como o EA exporta trades para Python analisar?           │   │
│  │                                                                     │   │
│  │  Opções a definir:                                                  │   │
│  │  □ Arquivo CSV após cada trade?                                     │   │
│  │  □ Arquivo JSON diário?                                             │   │
│  │  □ Database SQLite compartilhado?                                   │   │
│  │  □ Named pipes / sockets?                                           │   │
│  │                                                                     │   │
│  │  Prioridade: CRÍTICA                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-3.2: TRADE LOG FORMAT                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Pergunta: Qual formato exato do log de trades?                     │   │
│  │                                                                     │   │
│  │  Colunas necessárias (a definir):                                   │   │
│  │  - ticket, timestamp_open, timestamp_close                          │   │
│  │  - symbol, direction, lots                                          │   │
│  │  - price_open, price_close, sl, tp                                  │   │
│  │  - profit, profit_pct, commission, swap                             │   │
│  │  - regime, session, entry_score, mtf_alignment                      │   │
│  │  - ml_probability, confluence_score                                 │   │
│  │                                                                     │   │
│  │  Prioridade: CRÍTICA                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-3.3: SCALER SYNC                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Pergunta: Como sincronizar scaler_params entre Python e MQL5?      │   │
│  │                                                                     │   │
│  │  Fluxo atual (a validar):                                           │   │
│  │  1. Python treina modelo e salva scaler_params.json                 │   │
│  │  2. MQL5 lê scaler_params.json em OnInit()                          │   │
│  │  3. COnnxBrain.mqh aplica normalização antes de inference           │   │
│  │                                                                     │   │
│  │  Formato do JSON (a definir):                                       │   │
│  │  {                                                                  │   │
│  │    "features": ["returns", "rsi_m5", ...],                          │   │
│  │    "means": [0.0001, 50.0, ...],                                    │   │
│  │    "stds": [0.002, 15.0, ...],                                      │   │
│  │    "version": "1.0",                                                │   │
│  │    "trained_date": "2025-12-01"                                     │   │
│  │  }                                                                  │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-3.4: REAL-TIME BRIDGE                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Pergunta: Como Python monitora EA em tempo real (para Fase 7)?     │   │
│  │                                                                     │   │
│  │  Opções:                                                            │   │
│  │  □ Polling de arquivo de status a cada N segundos                   │   │
│  │  □ MT5 Python API (pymt5)                                           │   │
│  │  □ Webhook do EA para Python server                                 │   │
│  │  □ Shared memory / memory mapped file                               │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA (só necessário em Fase 7)                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-3.5: CONFIG SYNC (GO/NO-GO → EA)                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Pergunta: Como passar resultados do GO/NO-GO para configurar EA?   │   │
│  │                                                                     │   │
│  │  Parâmetros a passar:                                               │   │
│  │  - Kelly base aprovado                                              │   │
│  │  - Baseline Sharpe/PF para edge monitor                             │   │
│  │  - Segmentos habilitados/desabilitados                              │   │
│  │  - Risk multipliers por regime/sessão                               │   │
│  │                                                                     │   │
│  │  Formato sugerido: config_approved.json                             │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  AÇÃO: Definir e documentar cada formato e processo de integração          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-4: Formato de Dados Não Especificado (4 gaps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  FORMATOS DE DADOS NÃO DOCUMENTADOS                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GAP-4.1: TRADE LOG FORMAT (detalhado)                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  SPEC A CRIAR:                                                      │   │
│  │                                                                     │   │
│  │  Arquivo: trades_YYYYMMDD.csv                                       │   │
│  │  Encoding: UTF-8                                                    │   │
│  │  Delimiter: comma                                                   │   │
│  │  Timestamp format: YYYY-MM-DD HH:MM:SS.mmm                          │   │
│  │                                                                     │   │
│  │  Colunas (dtypes):                                                  │   │
│  │  - ticket (int64)                                                   │   │
│  │  - timestamp_open (datetime64)                                      │   │
│  │  - timestamp_close (datetime64)                                     │   │
│  │  - symbol (str)                                                     │   │
│  │  - direction (int8: 1=BUY, -1=SELL)                                 │   │
│  │  - lots (float64)                                                   │   │
│  │  - price_open (float64)                                             │   │
│  │  - price_close (float64)                                            │   │
│  │  - sl (float64)                                                     │   │
│  │  - tp (float64)                                                     │   │
│  │  - profit (float64)                                                 │   │
│  │  - profit_pct (float64)                                             │   │
│  │  - commission (float64)                                             │   │
│  │  - swap (float64)                                                   │   │
│  │  - regime (str: TRENDING/RANGING/REVERTING/RANDOM)                  │   │
│  │  - session (str: LONDON/OVERLAP/NY/ASIA/CLOSE)                      │   │
│  │  - entry_score (float64: 0-100)                                     │   │
│  │  - mtf_alignment (str: PERFECT/GOOD/WEAK/NONE)                      │   │
│  │  - ml_probability (float64: 0-1)                                    │   │
│  │  - confluence_score (float64: 0-100)                                │   │
│  │  - hurst (float64: 0-1)                                             │   │
│  │  - entropy (float64: 0-4)                                           │   │
│  │  - latency_ms (int32)                                               │   │
│  │  - slippage_pips (float64)                                          │   │
│  │                                                                     │   │
│  │  Prioridade: CRÍTICA                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-4.2: BACKTEST OUTPUT FORMAT                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  SPEC A CRIAR:                                                      │   │
│  │                                                                     │   │
│  │  Arquivo: backtest_report_YYYYMMDD.json                             │   │
│  │                                                                     │   │
│  │  Estrutura:                                                         │   │
│  │  {                                                                  │   │
│  │    "metadata": {                                                    │   │
│  │      "backtest_id": "uuid",                                         │   │
│  │      "start_date": "2020-01-01",                                    │   │
│  │      "end_date": "2025-01-01",                                      │   │
│  │      "initial_capital": 100000,                                     │   │
│  │      "symbol": "XAUUSD"                                             │   │
│  │    },                                                               │   │
│  │    "metrics": {                                                     │   │
│  │      "total_trades": 500,                                           │   │
│  │      "win_rate": 0.58,                                              │   │
│  │      "profit_factor": 1.45,                                         │   │
│  │      "sharpe_ratio": 1.8,                                           │   │
│  │      "max_drawdown_pct": 8.5,                                       │   │
│  │      "net_profit": 25000,                                           │   │
│  │      "avg_trade": 50,                                               │   │
│  │      "sqn": 2.3,                                                    │   │
│  │      "sortino": 2.1,                                                │   │
│  │      "calmar": 2.9                                                  │   │
│  │    },                                                               │   │
│  │    "by_segment": {                                                  │   │
│  │      "TRENDING_OVERLAP": {...},                                     │   │
│  │      "TRENDING_LONDON": {...}                                       │   │
│  │    },                                                               │   │
│  │    "kelly_table": {...},                                            │   │
│  │    "convexity": {...},                                              │   │
│  │    "equity_curve": [...]                                            │   │
│  │  }                                                                  │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-4.3: SCALER_PARAMS.JSON FORMAT                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Estrutura exata:                                                   │   │
│  │  {                                                                  │   │
│  │    "version": "1.0",                                                │   │
│  │    "created": "2025-12-01T10:30:00Z",                               │   │
│  │    "model_hash": "abc123...",                                       │   │
│  │    "features": [                                                    │   │
│  │      {                                                              │   │
│  │        "name": "returns",                                           │   │
│  │        "index": 0,                                                  │   │
│  │        "mean": 0.0001,                                              │   │
│  │        "std": 0.002,                                                │   │
│  │        "min": -0.05,                                                │   │
│  │        "max": 0.05                                                  │   │
│  │      },                                                             │   │
│  │      ...                                                            │   │
│  │    ]                                                                │   │
│  │  }                                                                  │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-4.4: SEGMENT FILES FORMAT                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Arquivo: data/segments/regime_trending.parquet                     │   │
│  │                                                                     │   │
│  │  Colunas:                                                           │   │
│  │  - timestamp (datetime64)                                           │   │
│  │  - bid, ask, mid_price (float64)                                    │   │
│  │  - spread (float64)                                                 │   │
│  │  - regime (str)                                                     │   │
│  │  - session (str)                                                    │   │
│  │  - hurst (float64)                                                  │   │
│  │  - entropy (float64)                                                │   │
│  │                                                                     │   │
│  │  Metadata (parquet):                                                │   │
│  │  - source_file                                                      │   │
│  │  - creation_date                                                    │   │
│  │  - row_count                                                        │   │
│  │  - date_range                                                       │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  AÇÃO: Documentar cada formato com spec completa                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-5: Processos Operacionais Faltantes (6 gaps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PROCESSOS OPERACIONAIS NÃO DOCUMENTADOS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GAP-5.1: BACKUP/RESTORE DO ESTADO DO EA                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Problema: Se MT5 crashar, como restaurar estado?                   │   │
│  │                                                                     │   │
│  │  Estado a persistir:                                                │   │
│  │  - Posições abertas                                                 │   │
│  │  - DD atual (daily e total)                                         │   │
│  │  - Trade history do dia                                             │   │
│  │  - Circuit breaker status                                           │   │
│  │  - Kelly tracking (wins/losses recentes)                            │   │
│  │                                                                     │   │
│  │  Mecanismo: GlobalVariables já usado, mas precisa backup externo    │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-5.2: LOGGING CENTRALIZADO                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Problema: Logs de MQL5 e Python estão separados                    │   │
│  │                                                                     │   │
│  │  Solução a implementar:                                             │   │
│  │  - EA escreve em logs/ea_YYYYMMDD.log                               │   │
│  │  - Python escreve em logs/python_YYYYMMDD.log                       │   │
│  │  - Script agregador cria logs/unified_YYYYMMDD.log                  │   │
│  │  - Formato comum: [TIMESTAMP] [LEVEL] [SOURCE] Message              │   │
│  │                                                                     │   │
│  │  Prioridade: BAIXA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-5.3: ALERTAS AUTOMÁTICOS                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Problema: Sem notificações automáticas de eventos críticos         │   │
│  │                                                                     │   │
│  │  Eventos que devem alertar:                                         │   │
│  │  - DD diário > 3% (WARNING)                                         │   │
│  │  - DD diário > 4% (CRITICAL)                                        │   │
│  │  - Circuit breaker ativado                                          │   │
│  │  - EA parou de operar                                               │   │
│  │  - Edge decay detectado                                             │   │
│  │  - Erro de conexão > 5 min                                          │   │
│  │                                                                     │   │
│  │  Canais: Email e/ou Telegram bot                                    │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-5.4: ATUALIZAÇÃO DE DADOS                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Problema: Como adicionar novos ticks ao dataset?                   │   │
│  │                                                                     │   │
│  │  Processo a definir:                                                │   │
│  │  1. Exportar novos ticks do MT5                                     │   │
│  │  2. Validar formato e qualidade                                     │   │
│  │  3. Append ao parquet existente                                     │   │
│  │  4. Re-segmentar se necessário                                      │   │
│  │  5. Atualizar CONVERSION_STATS.json                                 │   │
│  │                                                                     │   │
│  │  Frequência: Semanal ou mensal                                      │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-5.5: RETREINAMENTO DO MODELO ML                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Problema: Quando e como retreinar o modelo ONNX?                   │   │
│  │                                                                     │   │
│  │  Triggers para retreinamento:                                       │   │
│  │  - Edge decay > 30% por > 50 trades                                 │   │
│  │  - Accuracy live < backtest - 10%                                   │   │
│  │  - A cada 6 meses (manutenção preventiva)                           │   │
│  │  - Após mudança estrutural do mercado                               │   │
│  │                                                                     │   │
│  │  Processo:                                                          │   │
│  │  1. Coletar novos dados (últimos 6 meses)                           │   │
│  │  2. Re-executar feature_engineering.py                              │   │
│  │  3. Re-treinar com train_wfa.py                                     │   │
│  │  4. Validar com go_nogo_genius.py                                   │   │
│  │  5. Se aprovado: export_onnx.py                                     │   │
│  │  6. Deploy: substituir model no EA                                  │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-5.6: ROLLBACK DE VERSÃO                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Problema: Se nova versão do EA ou model falha, como reverter?      │   │
│  │                                                                     │   │
│  │  Processo a definir:                                                │   │
│  │  1. Manter backup de versão anterior (EA + Model + Config)          │   │
│  │  2. Script de rollback rápido                                       │   │
│  │  3. Validação pós-rollback                                          │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  AÇÃO: Criar scripts e documentação para cada processo                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-6: Validação e Testes Faltantes (4 gaps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TESTES NÃO ESPECIFICADOS                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GAP-6.1: UNIT TESTS PARA SCRIPTS PYTHON                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Tests a criar:                                                     │   │
│  │                                                                     │   │
│  │  tests/                                                             │   │
│  │  ├── test_convert_tick_data.py                                      │   │
│  │  ├── test_validate_data.py                                          │   │
│  │  ├── test_segment_data.py                                           │   │
│  │  ├── test_latency_model.py                                          │   │
│  │  ├── test_shadow_exchange.py                                        │   │
│  │  ├── test_monte_carlo_evt.py                                        │   │
│  │  ├── test_cpcv.py                                                   │   │
│  │  ├── test_edge_stability.py                                         │   │
│  │  ├── test_go_nogo_genius.py                                         │   │
│  │  ├── test_stress_framework.py                                       │   │
│  │  ├── test_adaptive_kelly_sizer.py                                   │   │
│  │  └── test_live_edge_monitor.py                                      │   │
│  │                                                                     │   │
│  │  Framework: pytest                                                  │   │
│  │  Coverage target: >= 80%                                            │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-6.2: INTEGRATION TESTS MQL5 ↔ PYTHON                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Tests a criar:                                                     │   │
│  │                                                                     │   │
│  │  - Trade export: EA escreve → Python lê corretamente                │   │
│  │  - Scaler sync: Python salva → MQL5 lê e normaliza igual            │   │
│  │  - Config sync: GO/NO-GO output → EA configura corretamente         │   │
│  │  - Paridade: Sinais Python ~= Sinais MQL5                           │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-6.3: BENCHMARK DE PERFORMANCE                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Métricas a rastrear:                                               │   │
│  │                                                                     │   │
│  │  Script                    │ Target Time  │ Target Memory           │   │
│  │  convert_tick_data.py      │ < 30 min     │ < 8 GB RAM              │   │
│  │  validate_data.py          │ < 5 min      │ < 4 GB RAM              │   │
│  │  segment_data.py           │ < 10 min     │ < 4 GB RAM              │   │
│  │  tick_backtester.py        │ < 2 hr       │ < 8 GB RAM              │   │
│  │  monte_carlo_evt.py (5k)   │ < 5 min      │ < 2 GB RAM              │   │
│  │  go_nogo_genius.py         │ < 1 min      │ < 1 GB RAM              │   │
│  │                                                                     │   │
│  │  Prioridade: BAIXA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-6.4: VALIDATION TESTS PARA DADOS                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Validações a implementar:                                          │   │
│  │                                                                     │   │
│  │  - Checksum de arquivos tick data (SHA256)                          │   │
│  │  - Validação de range de preços (bid/ask sensatos)                  │   │
│  │  - Validação de timestamps (monotonicamente crescentes)             │   │
│  │  - Detecção de dados duplicados                                     │   │
│  │  - Detecção de outliers extremos                                    │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  AÇÃO: Criar suite de testes completa                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-7: Riscos Não Cobertos (5 gaps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  RISCOS ADICIONAIS NÃO ENDEREÇADOS                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GAP-7.1: CORRELATION BREAKDOWN RISK                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Risco: Correlações entre sinais (SMC, ML, OrderFlow) mudam         │   │
│  │                                                                     │   │
│  │  Impacto: Ensemble perde valor, pode até piorar performance         │   │
│  │                                                                     │   │
│  │  Monitoramento a adicionar:                                         │   │
│  │  - Calcular error correlation matrix em rolling window              │   │
│  │  - Alertar se correlação > 0.7 (sinais redundantes)                 │   │
│  │  - Alertar se correlação muda > 0.2 vs baseline                     │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-7.2: MODEL DRIFT DETECTION                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Risco: Modelo ONNX fica obsoleto com mudanças de mercado           │   │
│  │                                                                     │   │
│  │  Indicadores de drift:                                              │   │
│  │  - Accuracy caindo progressivamente                                 │   │
│  │  - Probabilidades menos calibradas (Brier score subindo)            │   │
│  │  - Distribuição de features mudando (covariate shift)               │   │
│  │                                                                     │   │
│  │  Monitoramento a adicionar:                                         │   │
│  │  - PSI (Population Stability Index) das features                    │   │
│  │  - KS test: distribuição live vs training                           │   │
│  │  - Rolling Brier score                                              │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-7.3: DATA SNOOPING / LOOK-AHEAD BIAS                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Risco: Features calculadas com informação futura (bug comum)       │   │
│  │                                                                     │   │
│  │  Verificações a fazer:                                              │   │
│  │  - Auditoria de cada feature em feature_engineering.py              │   │
│  │  - Verificar que rolling windows são backward-looking only          │   │
│  │  - Verificar que não há .shift(-N) ou future data                   │   │
│  │  - Test: shuffled dates deve dar accuracy ~50%                      │   │
│  │                                                                     │   │
│  │  Prioridade: ALTA (verificar antes de confiar no backtest)          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-7.4: EXECUTION RISK (Broker Changes)                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Risco: Broker muda condições (spread, leverage, slippage)          │   │
│  │                                                                     │   │
│  │  Monitoramento:                                                     │   │
│  │  - Comparar spread real vs histórico                                │   │
│  │  - Comparar slippage real vs simulado                               │   │
│  │  - Alertar se diferença > 50%                                       │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA (parcialmente coberto no Shadow Exchange)        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-7.5: TECHNOLOGY RISK                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Risco: MT5 crash, Python crash, servidor offline                   │   │
│  │                                                                     │   │
│  │  Mitigações a implementar:                                          │   │
│  │  - Watchdog para reiniciar EA se parar                              │   │
│  │  - Heartbeat check: EA → arquivo a cada 1 min                       │   │
│  │  - Fallback: se EA offline > 5 min → alerta                         │   │
│  │  - UPS para evitar shutdown inesperado                              │   │
│  │                                                                     │   │
│  │  Prioridade: MÉDIA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  AÇÃO: Implementar monitoramento e mitigações para cada risco              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### GAP-8: Documentação Faltante (4 gaps)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DOCUMENTAÇÃO NÃO CRIADA                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GAP-8.1: DIAGRAMA DE ARQUITETURA COMPLETO                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  A criar: Diagrama visual mostrando:                                │   │
│  │                                                                     │   │
│  │  - MQL5 EA e seus módulos                                           │   │
│  │  - Python scripts e suas interdependências                          │   │
│  │  - Fluxo de dados entre eles                                        │   │
│  │  - Arquivos de configuração e logs                                  │   │
│  │  - Conexões externas (broker, ONNX)                                 │   │
│  │                                                                     │   │
│  │  Formato: Mermaid ou PlantUML (no próprio MD)                       │   │
│  │                                                                     │   │
│  │  Prioridade: BAIXA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-8.2: GLOSSÁRIO DE TERMOS                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Termos a definir:                                                  │   │
│  │                                                                     │   │
│  │  - WFE (Walk-Forward Efficiency)                                    │   │
│  │  - PBO (Probability of Backtest Overfitting)                        │   │
│  │  - PSR (Probabilistic Sharpe Ratio)                                 │   │
│  │  - DSR (Deflated Sharpe Ratio)                                      │   │
│  │  - EVT (Extreme Value Theory)                                       │   │
│  │  - GPD (Generalized Pareto Distribution)                            │   │
│  │  - CPCV (Combinatorially Purged Cross-Validation)                   │   │
│  │  - CVaR (Conditional Value at Risk)                                 │   │
│  │  - MinTRL (Minimum Track Record Length)                             │   │
│  │  - SQN (System Quality Number)                                      │   │
│  │  - Hurst Exponent                                                   │   │
│  │  - Shannon Entropy                                                  │   │
│  │                                                                     │   │
│  │  Prioridade: BAIXA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-8.3: FAQ DE PROBLEMAS COMUNS                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Q&A a documentar:                                                  │   │
│  │                                                                     │   │
│  │  - "EA não está abrindo trades" → Checklist de diagnóstico          │   │
│  │  - "ONNX inference muito lenta" → Otimizações possíveis             │   │
│  │  - "WFE muito baixo" → Possíveis causas e soluções                  │   │
│  │  - "Monte Carlo dá DD muito alto" → Como interpretar                │   │
│  │  - "Edge decay detectado" → Próximos passos                         │   │
│  │                                                                     │   │
│  │  Prioridade: BAIXA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  GAP-8.4: TROUBLESHOOTING GUIDE                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Cenários a cobrir:                                                 │   │
│  │                                                                     │   │
│  │  - EA não compila                                                   │   │
│  │  - ONNX model não carrega                                           │   │
│  │  - Python script falha com OOM                                      │   │
│  │  - Backtest diverge de live                                         │   │
│  │  - Circuit breaker ativou incorretamente                            │   │
│  │                                                                     │   │
│  │  Prioridade: BAIXA                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  AÇÃO: Criar docs conforme gaps forem resolvidos                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### RESUMO E PRIORIZAÇÃO

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    RESUMO DE GAPS POR PRIORIDADE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  TOTAL: 48 GAPS                                                     │   │
│  │  ├── CRÍTICOS:  12 (resolver antes de qualquer backtest)            │   │
│  │  ├── ALTOS:     21 (resolver antes de GO-LIVE)                      │   │
│  │  ├── MÉDIOS:    11 (resolver antes de FTMO)                         │   │
│  │  └── BAIXOS:     4 (nice to have)                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ORDEM DE IMPLEMENTAÇÃO RECOMENDADA (v5.2 CORRIGIDA):                      │
│                                                                             │
│  BATCH 1 - CRÍTICOS (bloqueia Phase 1):                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. 🆕 convert_tick_data.py - CRIAR (CSV 24GB → Parquet)            │   │
│  │  2. 🔄 validate_data.py - ESTENDER (+GENIUS validation)             │   │
│  │  3. Trade Log Format definido (GAP-4.1)                             │   │
│  │  4. Scaler Sync format (GAP-3.3)                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  BATCH 2 - ALTOS (bloqueia Phases 2-3):                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  5. 🆕 segment_data.py - CRIAR (regime × sessão)                    │   │
│  │  6. 🔄 tick_backtester.py - ESTENDER (+Kelly/Convexity)             │   │
│  │  7. 🆕 feature_engineering.py - CRIAR (15 features)                 │   │
│  │  8. 🆕 train_wfa.py - CRIAR (WFA training)                          │   │
│  │  9. 🆕 export_onnx.py - CRIAR (ONNX export)                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  BATCH 3 - ALTOS (bloqueia Phases 4-5):                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  10. 🆕 shadow_exchange.py - CRIAR (EVT exchange)                   │   │
│  │  11. 🆕 ea_logic_python.py - CRIAR (port da lógica)                 │   │
│  │  12. 🔄 monte_carlo.py - ESTENDER (+EVT/GPD)                        │   │
│  │  13. 🔄 walk_forward.py - ESTENDER (+WFE por segmento)              │   │
│  │  14. 🔄 go_nogo_validator.py - ESTENDER (+GENIUS scoring)           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  BATCH 4 - MÉDIOS (bloqueia Phases 6-7):                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  15. 🆕 stress_framework.py - CRIAR (6 cenários)                    │   │
│  │  16. 🆕 adaptive_kelly_sizer.py - CRIAR (live Kelly)                │   │
│  │  17. 🆕 live_edge_monitor.py - CRIAR (edge monitoring)              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ✅ SCRIPTS PRONTOS (não precisam trabalho):                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  - deflated_sharpe.py (PSR, DSR, MinTRL - completo)                 │   │
│  │  - prop_firm_validator.py (FTMO - completo)                         │   │
│  │  - confidence.py (scoring - completo)                               │   │
│  │  - mt5_trade_exporter.py (export - completo)                        │   │
│  │  - sample_data.py (geração - completo)                              │   │
│  │  - smc_components.py (SMC - completo)                               │   │
│  │  - convert_ticks_to_bars.py (conversão - completo)                  │   │
│  │  - convert_dukascopy_to_mt5.py (conversão - completo)               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  (GAPs 2-8 mantidos - ver seções anteriores para detalhes)

### v5.2 (2025-12-01) - AUDITED INFRASTRUCTURE EDITION

| Mudança | Descrição |
|---------|-----------|
| **+AUDITORIA COMPLETA** | Inventário real de todos os scripts existentes |
| **CORREÇÃO CRÍTICA** | Descoberto que muitos "gaps" são scripts que JÁ EXISTEM |
| **Reclassificação** | Scripts divididos em: 🆕 CRIAR (10) / 🔄 ESTENDER (8) / ✅ PRONTO (8) |
| **Scripts Oracle auditados** | walk_forward.py, monte_carlo.py, go_nogo_validator.py, etc. |
| **Scripts Backtest auditados** | tick_backtester.py (1014 linhas), validate_data.py (733 linhas) |
| **GAP-1 reescrito** | Tabela corrigida com status real de cada script |
| **Estimativa de esforço** | ~55-70h total (vs ~100h+ se tudo fosse do zero) |
| **Economia identificada** | ~30-40h de desenvolvimento já feito em scripts existentes |

### v5.1 (2025-12-01) - GAPS FILLED EDITION

| Mudança | Descrição |
|---------|-----------|
| **+WFE Thresholds por Regime** | Tabela completa com WFE por regime × sessão (Task 2) |
| **+Conservative Kelly** | Implementação com correção por sample size e 95% CI (Task 3) |
| **+LatencyModel Completo** | 4 componentes: Network, Broker, GC, Processing (Task 4) |
| **+AdaptiveKellySizer** | Classe Python para live trading com 6 fatores (Task 6) |
| **+Daily Monitoring Routine** | Checklist para pré-mercado, sessão, fim do dia (Task 8) |
| **+DD Contingency Actions** | Tabela de ações por nível de DD (0-2%, 2-3%, 3-4%, 4-5%, >5%) (Task 9) |
| **+Stress Config Table** | Configurações Normal/Pessimistic/Stress/BlackSwan (Task 10) |
| **+scripts/live/** | Novo diretório para scripts de live trading |
| **Total de scripts** | Atualizado para 18 scripts com dependências |

### v5.0 (2025-12-01) - INITIAL UNIFIED GENIUS EDITION

| Mudança | Descrição |
|---------|-----------|
| **+DADOS** | Seção com paths exatos dos arquivos tick/bar (24.8GB, 12.1GB) |
| **+DIAGRAMA** | Fluxo de dependências entre scripts |
| **+convert_tick_data.py** | Script para converter CSV gigante → Parquet |
| **+Fase 1 detalhada** | Steps 1.1, 1.2, 1.3 com inputs/outputs específicos |
| **+MÉTRICAS FTMO** | MinTRL, P(DD), Profit Target viability (Task 1) |
| **+CPCV** | Script completo para Probability of Backtest Overfitting |
| **+stress_framework.py** | Código concreto para os 6 stress tests |
| **+Tabela scripts** | Agora com localização, dependências, 17 scripts total |
| **Numeração** | Seções renumeradas (5.3→5.4, 6.2→6.3, etc.) |

---

*"O que pode ser medido pode ser melhorado. O que não pode ser validado não pode ser confiado."*

**BUILD. VALIDATE. TRADE. PROFIT.**
