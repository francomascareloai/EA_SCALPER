# Monte Carlo Simulation Guide

> Para: EA_SCALPER_XAUUSD - ORACLE Validation
> Metodo: Block Bootstrap (Lopez de Prado, 2018)

---

## 1. O Que E Monte Carlo?

Monte Carlo e um **stress test probabilistico** que responde: "O que PODERIA ter acontecido?"

### Conceito

```
1. Pegar trades reais do backtest
2. Embaralhar a ordem aleatoriamente (ou em blocos)
3. Calcular nova equity curve
4. Repetir 5000+ vezes
5. Analisar distribuicao de resultados

Original:    [T1, T2, T3, T4, T5, T6, ...]
Simulacao 1: [T4, T1, T6, T2, T5, T3, ...]
Simulacao 2: [T6, T3, T1, T5, T2, T4, ...]
...
Simulacao 5000: [T2, T5, T4, T6, T1, T3, ...]

Resultado: 5000 equity curves diferentes
```

---

## 2. Block Bootstrap vs Tradicional

### Problema do Bootstrap Tradicional

- Trades amostrados INDEPENDENTEMENTE
- Perde autocorrelacao (win streaks, loss streaks)
- Subestima risk of ruin

### Solucao: Block Bootstrap

- Amostra BLOCOS de trades consecutivos (5-10)
- Preserva autocorrelacao dentro do bloco
- Mais realista para trading

### Tamanho Otimo do Bloco

```
block_size = n^(1/3)   (Politis-Romano rule)

Ajuste por autocorrelacao:
- autocorr > 0.1: aumentar bloco
- autocorr < 0.1: bloco padrao
- Clamp entre 5-20 trades
```

### Quando Usar Cada Metodo

| Cenario | Metodo | Motivo |
|---------|--------|--------|
| Scalping frequente | Block Bootstrap | Alta autocorrelacao |
| Swing trading | Tradicional | Trades independentes |
| Grid/Martingale | Block Bootstrap | Posicoes correlacionadas |
| ML-based entries | Block Bootstrap | Regimes persistem |
| Alta win rate (>70%) | Block Bootstrap | Streaks importam |

---

## 3. Metricas Extraidas

### Distribuicao de Drawdown

| Percentil | Uso |
|-----------|-----|
| 5th | Melhor caso (otimista) |
| 50th | Mediano (esperado) |
| 95th | Pior caso provavel (planejamento) |
| 99th | Extremo (stress test) |

### Risk Metrics

| Metrica | Descricao |
|---------|-----------|
| Risk of Ruin 5% | P(DD >= 5%) - Daily FTMO |
| Risk of Ruin 10% | P(DD >= 10%) - Total FTMO |
| Prob Profit | P(profit > 0) |

### Streak Analysis (Block Bootstrap)

- Avg streak length
- Max win streak
- Max loss streak

---

## 4. Configuracao Recomendada

```
Simulacoes: 5,000+ (minimo para estabilidade)
Block Size: Auto (n^1/3) ou 7 para scalping
Trades minimos: 100+
Capital: $100,000 (FTMO)
```

---

## 5. Interpretacao FTMO

### Limites FTMO

- Daily DD: 5% ($5,000)
- Total DD: 10% ($10,000)

### Criterios de Aprovacao

| 95th DD | Verdict |
|---------|---------|
| < 8% | APPROVED |
| 8-10% | MARGINAL - reduzir tamanho |
| > 10% | REJECTED |

### Recomendacao de Position Size

Se 95th DD = 12%:
```
Reducao necessaria = 12% / 8% = 1.5x
Novo lot = Lot_atual / 1.5
```

---

## 6. Limitacoes

### O Que Monte Carlo NAO Captura

1. **Correlacao Temporal Completa**
   - Mesmo block bootstrap e aproximacao
   - Regimes de mercado podem nao estar bem representados

2. **Posicoes Simultaneas**
   - Simulacao executa trades sequencialmente
   - Se estrategia tem posicoes overlapping, DD pode ser subestimado

3. **Tail Events (Black Swans)**
   - Bootstrapping assume passado representa futuro
   - Black swans podem nao estar na amostra

4. **Mudancas Estruturais**
   - Mercado pode mudar
   - Parametros otimos podem driftar

---

## 7. Implementacao

**Script Python**: `scripts/oracle/monte_carlo.py`

```bash
# Uso via CLI
python -m scripts.oracle.monte_carlo --input trades.csv --block --simulations 5000

# Uso como modulo
from scripts.oracle.monte_carlo import BlockBootstrapMC

mc = BlockBootstrapMC(n_simulations=5000, initial_capital=100000)
result = mc.run(trades_df, use_block=True)
print(mc.generate_report(result))
```

### Output Exemplo

```
======================================================================
MONTE CARLO SIMULATION REPORT (BLOCK_BOOTSTRAP)
======================================================================
Simulations: 5,000
Block Size: 7 trades (preserves autocorrelation)
----------------------------------------------------------------------
DRAWDOWN DISTRIBUTION:
   5th percentile:  3.8% (best case)
  50th percentile:  6.5% (median)
  95th percentile:  11.4% (worst likely)
  99th percentile:  14.1% (extreme)
----------------------------------------------------------------------
FTMO ASSESSMENT:
  P(violating 5% daily):  8.1%
  P(violating 10% total): 12.3%
  VERDICT: MARGINAL - reduce position size
======================================================================
```

---

## 8. Integracao com ORACLE

### Comando

```
/montecarlo [trades] --block
```

### Flags

| Flag | Descricao |
|------|-----------|
| `--block` | Usar Block Bootstrap (recomendado) |
| `--traditional` | Usar Bootstrap tradicional |
| `--simulations N` | Numero de simulacoes (default 5000) |
| `--capital X` | Capital inicial (default 100000) |
