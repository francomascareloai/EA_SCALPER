# EA_SCALPER_XAUUSD - Python Backtest Strategies

## Index de Modulos

> **Ultima Atualizacao:** 2025-12-01  
> **Versao:** 3.31 (P1 Enhancements)  
> **Author:** FORGE v3.1

---

## Estrutura de Arquivos

```
scripts/backtest/strategies/
├── __init__.py              # Package exports (ATUALIZADO)
├── INDEX.md                 # Este arquivo (NOVO)
├── ea_logic_full.py         # EA principal - port do MQL5 (2365 linhas)
├── ea_logic_python.py       # Versao simplificada Python
├── ea_logic_compat.py       # Layer de compatibilidade
├── fibonacci_analyzer.py    # P1: Fibonacci analysis (NOVO)
├── adaptive_kelly.py        # P1: Position sizing (NOVO)
└── spread_analyzer.py       # P1: Spread awareness (NOVO)
```

---

## Changelog P1 (2025-12-01)

### Novos Modulos Criados

| Arquivo | Descricao | Linhas | Status |
|---------|-----------|--------|--------|
| `fibonacci_analyzer.py` | Golden Pocket, Extensions, Clusters | ~450 | ✅ NOVO |
| `adaptive_kelly.py` | DD-responsive Kelly position sizing | ~400 | ✅ NOVO |
| `spread_analyzer.py` | Smart spread awareness | ~350 | ✅ NOVO |

### Atualizacoes

| Arquivo | Mudanca | Status |
|---------|---------|--------|
| `__init__.py` | Exports para novos modulos | ✅ ATUALIZADO |

---

## Modulos Detalhados

### 1. fibonacci_analyzer.py (NOVO)

**Baseado em:** ARGUS Research Report (SSRN Paper Shanaev & Gibson 2022)

#### Classes
- `FibonacciAnalyzer` - Classe principal
- `FibonacciLevels` - Niveis calculados
- `FibAnalysisResult` - Resultado da analise
- `FibCluster` - Cluster de Fibs convergentes

#### Features
```python
# Golden Pocket detection (50%-65%)
analyzer.is_in_golden_pocket(price, levels)

# Extension targets para TPs
analyzer.get_fib_targets(entry, sl, is_long)
# -> tp1: 127.2%, tp2: 161.8%, tp3: 200%

# Cluster detection (multiplos fibs convergindo)
clusters = analyzer.find_clusters(highs, lows, num_swings=3)

# Score para confluence (0-100)
score = analyzer.calculate_fib_score(price, levels, atr)
```

#### Niveis Validados (SSRN)
| Nivel | Status | Uso |
|-------|--------|-----|
| 38.2% | ✅ USAR | Shallow pullback |
| 50.0% | ✅ USAR | Psicologico |
| 61.8% | ✅ USAR | Golden Ratio |
| 70.5% | ✅ USAR | Optimal entry |
| 23.6% | ❌ EVITAR | Reduz poder preditivo |
| 76.4% | ❌ EVITAR | Reduz poder preditivo |

---

### 2. adaptive_kelly.py (NOVO)

**Baseado em:** Van Tharp (R-Multiple), Ralph Vince (Optimal f)

#### Classes
- `AdaptiveKelly` - Classe principal
- `KellyMode` - Modo (FULL, HALF, QUARTER, ADAPTIVE)
- `KellySizingResult` - Resultado com lot e diagnosticos
- `TradeStats` - Estatisticas de trades

#### Features
```python
# Calcular Kelly fraction
kelly.calculate_kelly(win_rate, avg_win_r, avg_loss_r)

# Position sizing com todos ajustes
result = kelly.calculate_position_size(
    sl_points=50,
    regime_multiplier=1.0
)
# -> lot_size, risk_percent, adjustments

# Risk of Ruin
ror = kelly.get_risk_of_ruin(risk_percent=0.5)
```

#### Ajustes Aplicados
| Ajuste | Descricao | Impacto |
|--------|-----------|---------|
| DD Adjustment | Reduz em DD alto | 0.25-1.0x |
| Streak Adjustment | Momentum +/- | 0.5-1.3x |
| Uncertainty | Bayesian CI | 0.8-1.0x |
| Regime | Prime/Noisy | 0.0-1.5x |

#### DD Protection
| DD Level | Action |
|----------|--------|
| < 3% | Full size |
| 3-4% | 75% size |
| 4-5% | 50% size |
| 5-8% | 25% size |
| > 8% | STOP TRADING |

---

### 3. spread_analyzer.py (NOVO)

#### Classes
- `SpreadAnalyzer` - Classe principal
- `SpreadCondition` - OPTIMAL/NORMAL/ELEVATED/HIGH/EXTREME
- `SpreadAnalysisResult` - Resultado com recomendacoes
- `SpreadStats` - Stats por sessao

#### Features
```python
# Analise de spread
result = analyzer.analyze(
    current_spread=30,
    timestamp=datetime.now(),
    sl_points=50,
    signal_urgency=0.7
)
# -> allow_entry, wait_for_better, adjustments

# Custo em R
cost = analyzer.calculate_spread_cost(spread, sl_points)

# Melhor sessao
session, spread = analyzer.get_optimal_session()
```

#### Session Spread Multipliers
| Sessao | Multiplicador |
|--------|---------------|
| Asian | 1.4x |
| London | 1.0x (baseline) |
| London/NY Overlap | 0.9x |
| NY | 1.1x |
| Late NY | 1.5x |
| Weekend | 3.0x |

---

## Integracao com EALogicFull

### Uso Basico

```python
from scripts.backtest.strategies import (
    EALogicFull,
    FibonacciAnalyzer,
    AdaptiveKelly,
    SpreadAnalyzer,
    KellyMode,
)

# Criar instancias
ea = EALogicFull(gmt_offset=0)
fib = FibonacciAnalyzer()
kelly = AdaptiveKelly(mode=KellyMode.ADAPTIVE)
spread = SpreadAnalyzer()

# Analise Fibonacci
fib_result = fib.analyze(highs, lows, current_price, atr, is_bullish=True)
if fib_result.in_golden_pocket:
    confluence_bonus += 15

# TPs baseados em Fib Extensions
targets = fib.get_fib_targets(entry, sl, is_long=True)
tp1 = targets['tp1_risk']  # 127.2%
tp2 = targets['tp2_risk']  # 161.8%

# Position sizing adaptativo
kelly.update_balance(balance)
kelly.record_trade(last_r_multiple)
sizing = kelly.calculate_position_size(sl_points, regime_mult)
lot = sizing.lot_size

# Spread check antes de entrar
spread_result = spread.analyze(current_spread, timestamp, sl_points)
if not spread_result.allow_entry:
    return  # Wait for better spread
```

### Exemplo Completo

```python
def enhanced_analyze(ea, fib, kelly, spread, data, timestamp):
    """
    Analise completa com P1 enhancements.
    """
    # 1. Spread check primeiro
    spread_result = spread.analyze(
        data['spread'], timestamp, sl_points=50
    )
    if not spread_result.allow_entry:
        return None
    
    # 2. EA base analysis
    result = ea.analyze(
        h1_closes=data['h1_close'],
        m15_closes=data['m15_close'],
        # ... outros params
    )
    
    if not result.is_valid:
        return None
    
    # 3. Fibonacci enhancement
    fib_result = fib.analyze(
        data['m15_high'], data['m15_low'],
        data['current_price'], data['atr'],
        is_bullish_bias=(result.direction == SignalType.BUY)
    )
    
    # Ajustar score
    result.fib_score = fib_result.fib_score
    if fib_result.in_golden_pocket:
        result.total_score += 10
    
    # Usar Fib TPs
    if result.direction == SignalType.BUY:
        result.take_profit_1 = fib_result.tp1_fib
        result.take_profit_2 = fib_result.tp2_fib
    
    # 4. Adaptive position sizing
    sizing = kelly.calculate_position_size(
        sl_points=abs(result.entry_price - result.stop_loss),
        regime_multiplier=result.position_size_mult
    )
    
    if not sizing.is_trading_allowed:
        return None
    
    result.lot_size = sizing.lot_size
    result.risk_percent = sizing.risk_percent
    
    return result
```

---

## Performance Esperada (P1)

| Metrica | Antes | Depois | Delta |
|---------|-------|--------|-------|
| Win Rate | 55-60% | 58-65% | +3-5% |
| Profit Factor | 1.3-1.5 | 1.5-1.8 | +0.2-0.3 |
| Max DD | 8-12% | 6-10% | -2% |
| Expectancy | 0.3R | 0.4-0.5R | +0.1-0.2R |
| Sharpe | 1.0-1.5 | 1.3-1.8 | +0.3 |

---

## Proximos Passos (P2)

| Feature | Arquivo | Status |
|---------|---------|--------|
| M15 Trend Independente | `ea_logic_full.py` | PLANNED |
| BOS/CHoCH Melhorado | `ea_logic_full.py` | PLANNED |
| Session Gating MTF | `ea_logic_full.py` | PLANNED |
| Fibonacci Clusters UI | `fibonacci_analyzer.py` | PLANNED |
| HMM Regime | `hmm_regime.py` | PLANNED |

---

## Referencias

- **SSRN Paper:** Shanaev & Gibson (2022) - Fibonacci Retracements
- **Van Tharp:** R-Multiple, SQN, Position Sizing
- **Ralph Vince:** Optimal f, Risk of Ruin
- **ARGUS Research:** `DOCS/03_RESEARCH/FINDINGS/FIBONACCI_XAUUSD_RESEARCH.md`

---

*Documentado por FORGE v3.1*
