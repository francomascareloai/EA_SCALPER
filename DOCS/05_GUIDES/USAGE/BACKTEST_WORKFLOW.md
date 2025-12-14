# BACKTEST WORKFLOW - ORACLE v2.2

```
   "O backtest nao e para provar que funciona.
    E para provar que NAO e overfitting."
    
    - Lopez de Prado
```

---

## WORKFLOW RESUMIDO (TL;DR)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        BACKTEST WORKFLOW (7 STEPS)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. DATA ──► 2. BASELINE ──► 3. WFA ──► 4. MONTE CARLO ──► 5. OVERFITTING  │
│                                                                             │
│                    ──► 6. EXECUTION COSTS ──► 7. GO/NO-GO                  │
│                                                                             │
│  ⚠️ SE FALHAR EM QUALQUER STEP: PARAR E REVISAR ESTRATEGIA                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## STEP 1: DATA PREPARATION

### O que fazer
```bash
# Validar dados ANTES de qualquer backtest
python scripts/oracle/validate_genius_consolidated.py
```

### Criterios de qualidade
- [ ] Gaps criticos (>24h non-weekend): **0**
- [ ] Spread anomalies: **< 0.1%**
- [ ] Cobertura: **>= 2 anos** (idealmente 5+)
- [ ] Regime diversity: Trending, Ranging, Reverting presentes

### Armadilha comum
```
❌ ERRADO: Usar dados de 6 meses e achar que e suficiente
✅ CERTO:  Minimo 2 anos, idealmente com diferentes regimes de mercado
```

---

## STEP 2: BASELINE BACKTEST (MT5)

### O que fazer
1. Abrir MT5 Strategy Tester
2. Configurar:
   - **Symbol:** XAUUSD
   - **Period:** 2020-01-01 a 2024-12-31 (minimo)
   - **Model:** Every tick based on real ticks
   - **Spread:** Current (ou do broker FTMO)
   - **Initial deposit:** $100,000

3. Rodar backtest SEM otimizacao
4. Exportar trades: File → Save as Detailed Report

### Output esperado
```
Trades exportados para: data/backtest_results/trades_YYYYMMDD.csv

Colunas necessarias:
- datetime (ou open_time)
- direction (BUY/SELL)
- profit (em USD)
- entry_price
- exit_price
```

### Armadilha comum
```
❌ ERRADO: Otimizar parametros no MT5 e usar o "melhor" resultado
✅ CERTO:  Usar parametros fixos, otimizacao vem DEPOIS com WFA
```

---

## STEP 3: WALK-FORWARD ANALYSIS

### Por que e OBRIGATORIO
- Detecta se a estrategia **generaliza** ou apenas **decorou** os dados
- Simula o que aconteceria se voce re-otimizasse periodicamente

### Como executar
```bash
# WFA Rolling (recomendado para scalping)
python -m scripts.oracle.walk_forward \
  --input data/backtest_results/trades.csv \
  --mode rolling \
  --windows 10 \
  --is-ratio 0.7 \
  --purge 5
```

### Interpretar resultado
| WFE | Significado | Acao |
|-----|-------------|------|
| >= 0.6 | ✅ Excelente | Prosseguir |
| 0.5-0.6 | ⚠️ Aceitavel | Prosseguir com cautela |
| 0.4-0.5 | ⚠️ Marginal | Simplificar estrategia |
| < 0.4 | ❌ Overfitting | **PARAR. Revisar estrategia.** |

### Armadilha comum
```
❌ ERRADO: Ignorar WFA porque "o backtest ja mostrou profit"
✅ CERTO:  WFA e MAIS importante que o backtest inicial
```

---

## STEP 4: MONTE CARLO SIMULATION

### Por que e OBRIGATORIO
- Uma equity curve e UMA realizacao de infinitas possiveis
- Monte Carlo mostra a **distribuicao** de resultados possiveis

### Como executar
```bash
# Block Bootstrap (preserva autocorrelacao)
python -m scripts.oracle.monte_carlo \
  --input data/backtest_results/trades.csv \
  --simulations 5000 \
  --block \
  --capital 100000
```

### Interpretar resultado
| Metrica | Threshold FTMO | Significado |
|---------|----------------|-------------|
| DD 95th | < 8% | Worst-case provavel |
| DD 99th | < 10% | Worst-case extremo |
| P(DD > 10%) | < 5% | Probabilidade de violar FTMO |
| P(Profit) | > 80% | Chance de lucro |

### Armadilha comum
```
❌ ERRADO: Usar bootstrap tradicional (ignora autocorrelacao de trades)
✅ CERTO:  Usar BLOCK bootstrap (preserva streaks de wins/losses)
```

---

## STEP 5: OVERFITTING DETECTION (PSR/DSR)

### Por que e OBRIGATORIO
- Sharpe Ratio alto pode ser **sorte** ou **overfitting**
- PSR/DSR ajustam para multiplos testes e distribuicao nao-normal

### Como executar
```bash
# Informar quantos parametros/estrategias voce testou
python -m scripts.oracle.deflated_sharpe \
  --input data/backtest_results/trades.csv \
  --trials 50 \
  --column profit
```

### Interpretar resultado
| Metrica | Threshold | Significado |
|---------|-----------|-------------|
| PSR | >= 0.90 | Sharpe estatisticamente significante |
| DSR | > 0 | Sharpe sobrevive ajuste por multiplos testes |
| DSR | < 0 | ❌ **OVERFITTING CONFIRMADO** |
| MinTRL | < N trades | Voce tem dados suficientes |

### Armadilha comum
```
❌ ERRADO: Testar 100 combinacoes e reportar o melhor Sharpe
✅ CERTO:  Ajustar Sharpe pelo numero de testes (DSR)
```

---

## STEP 6: EXECUTION COSTS

### Por que e OBRIGATORIO
- Backtest assume execucao perfeita
- Realidade: slippage, spread variavel, rejeicoes

### Como executar
```bash
# Modo PESSIMISTIC para FTMO (conservador)
python -m scripts.oracle.execution_simulator \
  --input data/backtest_results/trades.csv \
  --mode pessimistic \
  --output data/backtest_results/trades_with_costs.csv
```

### Verificar
```
Pergunta: A estrategia AINDA e lucrativa com custos pessimistas?

SE SIM: Prosseguir
SE NAO: Revisar tamanho de posicao ou frequencia de trades
```

### Armadilha comum
```
❌ ERRADO: Usar spread fixo de 20 points (spread varia por sessao!)
✅ CERTO:  Usar simulador com spread session-aware + slippage adverso
```

---

## STEP 7: GO/NO-GO DECISION

### Como executar
```bash
# Pipeline completo automatizado
python -m scripts.oracle.go_nogo_validator \
  --input data/backtest_results/trades.csv \
  --output DOCS/04_REPORTS/VALIDATION/go_nogo_YYYYMMDD.md
```

### Criterios GO/NO-GO

#### Mandatorios (TODOS devem passar)
| # | Criterio | Threshold |
|---|----------|-----------|
| 1 | Trades | >= 100 |
| 2 | WFE | >= 0.5 |
| 3 | DSR | > 0 |
| 4 | MC 95th DD | < 10% |
| 5 | P(FTMO violation) | < 5% |

#### Qualidade (maioria deve passar)
| # | Criterio | Threshold |
|---|----------|-----------|
| 6 | Sharpe | >= 1.5 |
| 7 | Sortino | >= 2.0 |
| 8 | Win Rate | 40-65% |
| 9 | Profit Factor | >= 1.5 |
| 10 | Confidence Score | >= 70 |

### Decision Matrix
```
╔═══════════════════════════════════════════════════════════════╗
║ Mandatorios  │ Qualidade │ Decisao                            ║
╠═══════════════════════════════════════════════════════════════╣
║ 5/5 PASS     │ >= 4/5    │ ✅ STRONG GO                       ║
║ 5/5 PASS     │ 3/5       │ ✅ GO (com cautela)                ║
║ 5/5 PASS     │ < 3/5     │ ⚠️ INVESTIGATE (revisar)          ║
║ < 5/5 PASS   │ Qualquer  │ ❌ NO-GO (nao prosseguir)         ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## WORKFLOW VISUAL COMPLETO

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌──────────┐                                                              │
│  │  DADOS   │ ─────► Validar qualidade (GENIUS Score >= 80)                │
│  │  TICK    │        ❌ Se falhar: Obter dados melhores                    │
│  └────┬─────┘                                                              │
│       │                                                                     │
│       ▼                                                                     │
│  ┌──────────┐                                                              │
│  │   MT5    │ ─────► Backtest tick-by-tick, spreads reais                  │
│  │ STRATEGY │        Exportar trades para CSV                              │
│  │  TESTER  │        ❌ Se < 100 trades: Periodo maior ou revisar          │
│  └────┬─────┘                                                              │
│       │                                                                     │
│       ▼                                                                     │
│  ┌──────────┐                                                              │
│  │   WFA    │ ─────► WFE >= 0.5?                                           │
│  │ Rolling  │        ❌ Se WFE < 0.5: PARAR. Estrategia overfitted.        │
│  └────┬─────┘                                                              │
│       │ ✅                                                                  │
│       ▼                                                                     │
│  ┌──────────┐                                                              │
│  │  MONTE   │ ─────► 95th DD < 10%? P(ruin) < 5%?                          │
│  │  CARLO   │        ❌ Se falhar: Reduzir risk/trade                      │
│  └────┬─────┘                                                              │
│       │ ✅                                                                  │
│       ▼                                                                     │
│  ┌──────────┐                                                              │
│  │ PSR/DSR  │ ─────► DSR > 0?                                              │
│  │  Check   │        ❌ Se DSR < 0: OVERFITTING. Simplificar.              │
│  └────┬─────┘                                                              │
│       │ ✅                                                                  │
│       ▼                                                                     │
│  ┌──────────┐                                                              │
│  │EXECUTION │ ─────► Ainda lucrativo com custos PESSIMISTIC?               │
│  │  COSTS   │        ❌ Se nao: Reduzir frequencia ou aumentar TP          │
│  └────┬─────┘                                                              │
│       │ ✅                                                                  │
│       ▼                                                                     │
│  ┌──────────┐                                                              │
│  │ GO/NO-GO │ ─────► Confidence Score >= 70?                               │
│  │ DECISION │        ✅ GO: Prosseguir para paper trading                  │
│  └──────────┘        ❌ NO-GO: Voltar ao design da estrategia              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ERROS FATAIS (NUNCA FACA)

### 1. Otimizar e reportar o melhor
```
❌ "Testei 500 combinacoes, a melhor teve Sharpe 4.0!"
✅ "Testei 500 combinacoes, DSR ajustado = -0.3. Overfitting."
```

### 2. Ignorar custos de execucao
```
❌ "Spread fixo de 2 pips, slippage zero"
✅ "Spread variavel por sessao, slippage adverso, rejeicoes"
```

### 3. Confiar em uma unica equity curve
```
❌ "O backtest mostrou 50% de retorno!"
✅ "Monte Carlo 95th percentile: -8% DD. Mediana: +30% retorno."
```

### 4. Pular WFA
```
❌ "WFA demora muito, vou direto pro live"
✅ "WFE 0.65 - estrategia generaliza. Posso confiar."
```

### 5. Usar dados curtos
```
❌ "6 meses de dados, 50 trades"
✅ "5 anos de dados, 500+ trades, multiplos regimes"
```

---

## CHECKLIST RAPIDO

Antes de ir para paper trading, confirme:

```
□ Dados validados (GENIUS >= 80)
□ >= 100 trades no backtest
□ WFE >= 0.5
□ Monte Carlo 95th DD < 10%
□ DSR > 0 (nao overfitted)
□ Lucrativo com custos PESSIMISTIC
□ Confidence Score >= 70
□ Relatorio GO/NO-GO gerado
```

---

## COMANDOS RAPIDOS

```bash
# 1. Validar dados
python scripts/oracle/validate_genius_consolidated.py

# 2. WFA
python -m scripts.oracle.walk_forward -i trades.csv -m rolling -w 10

# 3. Monte Carlo
python -m scripts.oracle.monte_carlo -i trades.csv --block -n 5000

# 4. Overfitting check
python -m scripts.oracle.deflated_sharpe -i trades.csv --trials 50

# 5. Execution costs
python -m scripts.oracle.execution_simulator -i trades.csv -m pessimistic

# 6. GO/NO-GO completo
python -m scripts.oracle.go_nogo_validator -i trades.csv -o report.md
```

---

*"Se nao sobrevive ao processo de validacao, nao sobrevive ao mercado."*

**ORACLE v2.2 - Statistical Truth-Seeker**
