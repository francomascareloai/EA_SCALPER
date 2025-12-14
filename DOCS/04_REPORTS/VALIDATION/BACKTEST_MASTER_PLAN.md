# BACKTEST MASTER PLAN - EA_SCALPER_XAUUSD

**Version**: 1.0  
**Date**: 2025-12-01  
**Author**: ORACLE + FORGE  
**Status**: ACTIVE

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Validar a estratégia EA_SCALPER_XAUUSD com rigor institucional antes de FTMO Challenge $100k.

### 1.2 Princípios Fundamentais

| Princípio | Descrição |
|-----------|-----------|
| **Tick Data First** | Sempre usar dados de tick para máxima precisão |
| **Event-Driven** | Simular execução realista, não vetorizada |
| **Out-of-Sample** | Nunca validar nos mesmos dados de otimização |
| **Custos Realistas** | Spread, slippage, latência, rejeições |
| **Statistical Rigor** | WFA, Monte Carlo, PSR/DSR para evitar overfitting |

### 1.3 Critérios de Aprovação (GO/NO-GO)

```
┌─────────────────────────────────────────────────────────────┐
│                    THRESHOLDS FTMO $100k                    │
├─────────────────────────────────────────────────────────────┤
│  Walk-Forward Efficiency (WFE)      >= 0.60                 │
│  OOS Windows Positivos              >= 70%                  │
│  Monte Carlo 95th DD                < 8%                    │
│  Probabilistic Sharpe Ratio (PSR)   >= 0.90                 │
│  Risk of Ruin (10% DD)              < 5%                    │
│  P(Daily DD Breach)                 < 5%                    │
│  P(Total DD Breach)                 < 2%                    │
│  Minimum Trades                     >= 100                  │
│  Profit Factor                      >= 1.3                  │
│  Realized Max DD                    < 8%                    │
├─────────────────────────────────────────────────────────────┤
│  STRONG_GO: Todos passam + WFE > 0.75 + PF > 1.5           │
│  GO: Todos passam                                           │
│  INVESTIGATE: 1-2 falhas marginais                          │
│  NO_GO: Qualquer falha crítica                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. DADOS

### 2.1 Fonte de Dados

| Dataset | Path | Tamanho | Período |
|---------|------|---------|---------|
| **Tick Data Principal** | `Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv` | 24.3 GB | 2003-2025 |
| Tick 2020 (backup) | `XAUUSD_ftmo_2020_ticks_dukascopy.csv` | ~2 GB | 2020 |
| M5 Bars (referência) | `Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv` | 22 MB | 2020-2025 |

### 2.2 Formato Tick Data
```
datetime,bid,ask
2025.11.28 21:43:59.978,2637.45,2637.86
```

### 2.3 Carregamento Eficiente (File Seeking)
```python
# Carregar últimos N ticks via file seek (não PowerShell tail)
def load_tick_data(filepath, max_rows=5_000_000):
    file_size = os.path.getsize(filepath)
    bytes_to_read = min(max_rows * 40, file_size)
    
    with open(filepath, 'rb') as f:
        f.seek(max(0, file_size - bytes_to_read))
        f.readline()  # Skip partial line
        # Parse remaining...
```

### 2.4 Períodos de Teste

| Período | Uso | Dados |
|---------|-----|-------|
| **In-Sample (IS)** | Otimização de parâmetros | 2020-01 a 2023-12 (4 anos) |
| **Out-of-Sample (OOS)** | Validação primária | 2024-01 a 2024-12 (1 ano) |
| **Forward Test** | Validação final | 2025-01 a presente |

### 2.5 Divisão para Walk-Forward

```
IS/OOS Ratio: 4:1 (80% IS, 20% OOS por janela)
Purge Gap: 5 dias (evita data leakage)
Janelas Rolling: 12 (1 ano cada, shift 3 meses)
```

---

## 3. ARQUITETURA DO BACKTESTER

### 3.1 Por que Event-Driven > Vectorized?

| Aspecto | Vectorized | Event-Driven |
|---------|------------|--------------|
| Velocidade | ⚡ Muito rápido | 🐢 Mais lento |
| Precisão | ⚠️ Aproximada | ✅ Exata |
| Look-ahead bias | ⚠️ Possível | ✅ Impossível |
| Execução realista | ❌ Não | ✅ Sim |
| Slippage dinâmico | ❌ Não | ✅ Sim |
| Posições parciais | ❌ Difícil | ✅ Fácil |
| **Uso recomendado** | Screening rápido | Validação final |

### 3.2 Estrutura do Event-Driven Backtester

```
┌─────────────────────────────────────────────────────────────┐
│                    EVENT-DRIVEN ENGINE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ DATA FEED   │───>│   STRATEGY  │───>│  EXECUTION  │     │
│  │ (Tick/Bar)  │    │   (Signals) │    │  (Orders)   │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                  │                  │             │
│         v                  v                  v             │
│  ┌─────────────────────────────────────────────────┐       │
│  │              PORTFOLIO / RISK MANAGER            │       │
│  │  - Position sizing (Kelly, Fixed Frac)          │       │
│  │  - DD monitoring (Daily, Total)                 │       │
│  │  - Circuit breakers                             │       │
│  └─────────────────────────────────────────────────┘       │
│         │                                                   │
│         v                                                   │
│  ┌─────────────────────────────────────────────────┐       │
│  │              EXECUTION SIMULATOR                 │       │
│  │  - Dynamic spread (session, news)               │       │
│  │  - Slippage (market conditions)                 │       │
│  │  - Latency (with spikes)                        │       │
│  │  - Order rejections                             │       │
│  └─────────────────────────────────────────────────┘       │
│         │                                                   │
│         v                                                   │
│  ┌─────────────────────────────────────────────────┐       │
│  │              TRADE LOGGER                        │       │
│  │  → trades.csv (Oracle-compatible)               │       │
│  └─────────────────────────────────────────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.3 Formato Output (Oracle-Compatible)

```csv
entry_time,exit_time,direction,entry_price,exit_price,sl,tp,lots,pnl,exit_reason
2024-01-15 14:30:00,2024-01-15 15:45:00,BUY,2045.50,2048.20,2042.00,2051.00,0.5,135.00,TP
```

---

## 4. PIPELINE DE VALIDAÇÃO

### 4.1 Fases do Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                     VALIDATION PIPELINE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  FASE 1: BASELINE BACKTEST                                  │
│  ├── Carregar tick data (5-10M ticks)                       │
│  ├── Resample para M5/M1                                    │
│  ├── Executar estratégia base                               │
│  ├── Gerar trades.csv                                       │
│  └── Métricas básicas (WR, PF, DD, Sharpe)                 │
│                                                             │
│  FASE 2: WALK-FORWARD ANALYSIS                              │
│  ├── Dividir em janelas IS/OOS                              │
│  ├── "Otimizar" em IS (ou usar params fixos)               │
│  ├── Validar em OOS                                         │
│  ├── Calcular WFE (OOS_return / IS_return)                 │
│  └── Threshold: WFE >= 0.60, OOS+ >= 70%                   │
│                                                             │
│  FASE 3: MONTE CARLO BLOCK BOOTSTRAP                        │
│  ├── 5000+ simulações                                       │
│  ├── Block size = sqrt(n_trades)                           │
│  ├── Distribuição de DD e Profit                           │
│  ├── VaR 95%, CVaR 95%                                     │
│  └── Threshold: 95th DD < 8%, RoR < 5%                     │
│                                                             │
│  FASE 4: DEFLATED SHARPE ANALYSIS                           │
│  ├── PSR - Probabilistic Sharpe Ratio                       │
│  ├── DSR - Deflated (ajustado por trials)                  │
│  ├── MinTRL - Track record mínimo                          │
│  └── Threshold: PSR >= 0.90                                │
│                                                             │
│  FASE 5: EXECUTION COST STRESS TEST                         │
│  ├── Modo PESSIMISTIC (spread 2x, slippage 3x)             │
│  ├── Modo STRESS (spread 3x, slippage 5x)                  │
│  ├── Recalcular métricas                                    │
│  └── Verificar se ainda é lucrativo                        │
│                                                             │
│  FASE 6: PROP FIRM VALIDATION (FTMO)                        │
│  ├── Simular regras específicas FTMO                        │
│  ├── P(Daily DD > 5%) < 5%                                 │
│  ├── P(Total DD > 10%) < 2%                                │
│  ├── Profit target viável                                   │
│  └── Time limits                                            │
│                                                             │
│  FASE 7: GO/NO-GO DECISION                                  │
│  ├── Agregar todos os resultados                            │
│  ├── Calcular confidence score (0-100)                      │
│  ├── Emitir decisão: STRONG_GO / GO / INVESTIGATE / NO_GO  │
│  └── Gerar relatório final                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Scripts Oracle Disponíveis

| Script | Função | Comando |
|--------|--------|---------|
| `walk_forward.py` | WFA Rolling/Anchored | `python -m scripts.oracle.walk_forward --input trades.csv` |
| `monte_carlo.py` | Block Bootstrap MC | `python -m scripts.oracle.monte_carlo --input trades.csv --block` |
| `deflated_sharpe.py` | PSR/DSR/PBO | `python -m scripts.oracle.deflated_sharpe --input trades.csv` |
| `execution_simulator.py` | Custos realistas | `python -m scripts.oracle.execution_simulator --input trades.csv --mode pessimistic` |
| `prop_firm_validator.py` | Validação FTMO | `python -m scripts.oracle.prop_firm_validator --input trades.csv --firm ftmo` |
| `go_nogo_validator.py` | Pipeline completo | `python -m scripts.oracle.go_nogo_validator --input trades.csv` |

---

## 5. ESTRATÉGIA DE TESTE

### 5.1 Níveis de Complexidade

```
NÍVEL 1: BASELINE (Diagnóstico)
├── Estratégia: MA Cross simples (20/50)
├── Filtros: Nenhum
├── Objetivo: Verificar infraestrutura funciona
└── Expectativa: Provavelmente perdedor (PF < 1.0)

NÍVEL 2: FILTERED BASELINE
├── Estratégia: MA Cross + Regime Filter
├── Filtros: Hurst > 0.55 (trending only)
├── Objetivo: Testar se regime ajuda
└── Expectativa: Melhor que baseline

NÍVEL 3: SESSION FILTERED
├── Estratégia: MA Cross + Regime + Session
├── Filtros: London/NY overlap only
├── Objetivo: Testar timing de sessão
└── Expectativa: Menos trades, melhor qualidade

NÍVEL 4: CONFLUENCE SCORING
├── Estratégia: Full EA logic (simplificada)
├── Filtros: Score >= 50 (relaxado)
├── Objetivo: Testar sistema de confluência
└── Expectativa: Trade-off quantity vs quality

NÍVEL 5: PRODUCTION READY
├── Estratégia: Full EA logic
├── Filtros: Score >= 70, MTF, todos gates
├── Objetivo: Validação final
└── Expectativa: GO ou STRONG_GO
```

### 5.2 Matriz de Testes

| Teste | Dados | Período | Objetivo |
|-------|-------|---------|----------|
| T1 | Tick (5M) | Nov 2025 | Quick validation |
| T2 | Tick (50M) | 2025 | Full year forward |
| T3 | Tick (full) | 2024 | OOS validation |
| T4 | Tick (full) | 2020-2023 | IS optimization |
| T5 | WFA | 2020-2025 | Walk-forward |

---

## 6. IMPLEMENTAÇÃO

### 6.1 Estrutura de Arquivos

```
scripts/
├── backtest/
│   ├── __init__.py
│   ├── tick_loader.py          # Carregamento eficiente de ticks
│   ├── event_engine.py         # Motor event-driven
│   ├── strategy_base.py        # Classe base para estratégias
│   ├── strategies/
│   │   ├── ma_cross.py         # MA Cross baseline
│   │   ├── regime_filtered.py  # + Regime filter
│   │   └── full_ea.py          # Lógica completa do EA
│   ├── execution_model.py      # Slippage, spread, latência
│   ├── risk_manager.py         # Position sizing, DD
│   └── reporter.py             # Geração de relatórios
│
├── oracle/                     # [JÁ EXISTE]
│   ├── walk_forward.py
│   ├── monte_carlo.py
│   ├── deflated_sharpe.py
│   ├── execution_simulator.py
│   ├── prop_firm_validator.py
│   └── go_nogo_validator.py
│
└── run_validation.py           # Script principal
```

### 6.2 Comando de Execução Completa

```bash
# 1. Rodar backtest com tick data
python scripts/backtest/run_backtest.py \
    --data "Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv" \
    --strategy full_ea \
    --ticks 50000000 \
    --output data/trades_full.csv

# 2. Executar validação Oracle completa
python -m scripts.oracle.go_nogo_validator \
    --input data/trades_full.csv \
    --n-trials 10 \
    --mc-sims 5000 \
    --output DOCS/04_REPORTS/VALIDATION/GO_NOGO_REPORT.md
```

---

## 7. CHECKLIST DE EXECUÇÃO

### 7.1 Pré-Backtest

- [ ] Verificar integridade do tick data
- [ ] Confirmar período de dados disponível
- [ ] Definir parâmetros da estratégia
- [ ] Configurar custos de execução

### 7.2 Durante Backtest

- [ ] Monitorar uso de memória
- [ ] Verificar trades sendo gerados
- [ ] Conferir datas estão corretas
- [ ] Salvar checkpoints

### 7.3 Pós-Backtest

- [ ] Exportar trades.csv
- [ ] Verificar formato Oracle-compatible
- [ ] Executar WFA
- [ ] Executar Monte Carlo
- [ ] Executar Deflated Sharpe
- [ ] Executar Prop Firm Validation
- [ ] Gerar relatório GO/NO-GO
- [ ] Documentar resultados em DOCS/04_REPORTS/

### 7.4 Decisão

- [ ] Revisar todos os thresholds
- [ ] Verificar falhas críticas
- [ ] Emitir decisão final
- [ ] Se NO_GO: identificar problema e iterar

---

## 8. TROUBLESHOOTING

### 8.1 Problemas Comuns

| Problema | Causa | Solução |
|----------|-------|---------|
| Zero trades | Filtros muito restritivos | Relaxar thresholds |
| Memory error | Muitos ticks | Reduzir max_rows |
| Timeout loading | PowerShell tail lento | Usar file seek |
| Look-ahead bias | Indicadores com futuro | Usar shift(1) |
| PF < 1.0 | Estratégia ruim | Adicionar filtros |
| DD > 10% | Risk muito alto | Reduzir risk_per_trade |

### 8.2 Debugging

```python
# Ativar modo debug
CONFIG['debug'] = True
CONFIG['debug_interval'] = 100  # Log a cada 100 trades

# Verificar sinais
print(f"Signals: {df['signal_buy'].sum()} buy, {df['signal_sell'].sum()} sell")

# Verificar filtros
print(f"After regime filter: {df[df['regime_ok']].shape[0]} bars")
print(f"After session filter: {df[df['session_ok']].shape[0]} bars")
```

---

## 9. PRÓXIMOS PASSOS

### Imediato (Hoje)
1. ✅ Criar plano de backtest
2. 🔄 Implementar event-driven backtester
3. 🔄 Rodar baseline com tick data
4. 🔄 Integrar com Oracle pipeline

### Curto Prazo (Esta Semana)
5. Adicionar regime filter
6. Adicionar session filter
7. Testar diferentes níveis de filtro
8. Executar WFA completo

### Médio Prazo (Próximas 2 Semanas)
9. Monte Carlo 5000+ simulações
10. Deflated Sharpe analysis
11. Stress test com custos pessimistas
12. GO/NO-GO final

### Antes do FTMO
13. Demo trading (1-2 semanas)
14. Ajustes finais baseados em demo
15. Challenge ready

---

## 10. REFERÊNCIAS

- Lopez de Prado (2018) - Advances in Financial Machine Learning
- Bailey & Lopez de Prado (2014) - The Deflated Sharpe Ratio
- Politis & Romano (1994) - The Stationary Bootstrap
- FTMO Rules: https://ftmo.com/en/trading-rules/

---

*Este plano deve ser seguido rigorosamente. Não pular fases.*
*Documentar TODOS os resultados em DOCS/04_REPORTS/VALIDATION/*
