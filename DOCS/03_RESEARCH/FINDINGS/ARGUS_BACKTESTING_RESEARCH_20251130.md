# ARGUS Research: Backtesting Realista para Sistema Hibrido MQL5+Python

**ID**: ARGUS-20251130-001
**Confianca**: VERY_HIGH (3/3 triangulacao)
**Data**: 2025-11-30
**Query**: Melhor forma de backtesting realista para EA hibrido MQL5+Python+ONNX

---

## TL;DR

Para o EA_SCALPER_XAUUSD, a estrategia otima de backtesting combina:
1. **MT5 Strategy Tester** para backtest primario (ticks reais, slippage nativo)
2. **VectorBT/VectorBT PRO** para WFA e Monte Carlo em Python
3. **Abordagem hibrida**: Exportar trades do MT5 → Validar em Python → Decisao GO/NO-GO

O projeto **JA TEM** infraestrutura solida (`CBacktestRealism.mqh`), mas falta o **pipeline de validacao Python completo**.

---

## 1. ANALISE DO PROJETO ATUAL

### 1.1 O Que Ja Existe (Excelente!)

| Componente | Arquivo | Status |
|------------|---------|--------|
| **Backtest Realism MQL5** | `MQL5/Include/EA_SCALPER/Backtest/CBacktestRealism.mqh` | ✅ COMPLETO |
| **Baseline Python** | `scripts/baseline_backtest.py` | ✅ FUNCIONAL |
| **EA Principal** | `MQL5/Experts/EA_SCALPER_XAUUSD.mq5` | ✅ v3.30 |
| **Modelo ONNX** | `MQL5/Models/direction_model.onnx` | ✅ TREINADO |
| **Python Hub** | `Python_Agent_Hub/` | ✅ FastAPI |

### 1.2 O Que Falta (Gaps Criticos)

| Gap | Prioridade | Impacto |
|-----|------------|---------|
| **Walk-Forward Analysis Python** | P1 CRITICO | Validacao de robustez |
| **Monte Carlo Block Bootstrap** | P1 CRITICO | Distribuicao de DD |
| **Pipeline MT5→Python automatizado** | P2 ALTO | Velocidade de iteracao |
| **Deflated Sharpe Ratio** | P3 MEDIO | Deteccao de overfitting |

---

## 2. BIBLIOTECAS PYTHON RECOMENDADAS

### 2.1 Ranking por Caso de Uso

| Biblioteca | Uso Principal | Velocidade | Complexidade | Recomendado |
|------------|---------------|------------|--------------|-------------|
| **VectorBT PRO** | WFA + Monte Carlo + Bulk | ⭐⭐⭐⭐⭐ | Media | **#1 ESCOLHA** |
| **VectorBT (free)** | WFA basico | ⭐⭐⭐⭐⭐ | Media | Alternativa |
| **Backtesting.py** | Prototipos rapidos | ⭐⭐⭐⭐ | Baixa | Complementar |
| **Backtrader** | Event-driven | ⭐⭐⭐ | Alta | Nao necessario |
| **Zipline** | Live trading | ⭐⭐⭐ | Alta | Nao necessario |

### 2.2 Justificativa: Por Que VectorBT?

**Triangulacao**:
- **Academico**: Suporta Purged K-Fold CV (Lopez de Prado)
- **Pratico**: 1000+ repos no GitHub usando
- **Empirico**: Comunidade ativa, bem documentado

**Para o projeto especificamente**:
```
VectorBT alinha com arquitetura existente:
├── Pandas/NumPy (ja usado no Python Hub)
├── Vetorizado (rapido para 1000+ simulacoes)
├── WFA nativo (nao precisa implementar do zero)
├── Bootstrap methods (Block Bootstrap incluido)
└── Integracao com ONNX inference possivel
```

### 2.3 Instalacao Recomendada

```bash
# requirements.txt - ADICIONAR
vectorbt>=0.26.0          # Backtesting vetorizado
scipy>=1.11.0             # Ja instalado (Monte Carlo)
numba>=0.58.0             # Aceleracao
plotly>=5.18.0            # Visualizacao
```

---

## 3. ESTRATEGIA DE BACKTESTING HIBRIDA

### 3.1 Arquitetura Proposta

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PIPELINE DE BACKTESTING v2.0                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  FASE 1: BACKTEST PRIMARIO (MT5)                                   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ MT5 Strategy Tester                                          │   │
│  │ ├── Modo: Every tick based on real ticks                    │   │
│  │ ├── CBacktestRealism: SIM_PESSIMISTIC                       │   │
│  │ ├── Periodo: 3+ anos (2020-2024 IS, 2025 OOS)              │   │
│  │ └── Output: trades.csv (cada trade com features)            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ↓                                      │
│  FASE 2: VALIDACAO PYTHON                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ scripts/advanced_backtest.py                                 │   │
│  │ ├── Carregar trades.csv                                      │   │
│  │ ├── Walk-Forward Analysis (10-20 janelas)                   │   │
│  │ ├── Monte Carlo Block Bootstrap (5000 sim)                  │   │
│  │ ├── Deflated Sharpe Ratio                                   │   │
│  │ └── Output: validation_report.json                          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              ↓                                      │
│  FASE 3: GO/NO-GO DECISION                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Criterios FTMO                                               │   │
│  │ ├── WFE >= 0.6                                              │   │
│  │ ├── Monte Carlo 95th DD < 8%                                │   │
│  │ ├── Deflated Sharpe > 0                                     │   │
│  │ ├── Min 200 trades                                          │   │
│  │ └── Profit Factor > 1.5                                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Por Que Esta Abordagem?

| Aspecto | MT5 Puro | Python Puro | **Hibrido** |
|---------|----------|-------------|-------------|
| Realismo de execucao | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| WFA sofisticado | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Monte Carlo | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Velocidade total | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| ONNX integrado | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Conclusao**: Hibrido captura o MELHOR de ambos mundos.

---

## 4. IMPLEMENTACAO RECOMENDADA

### 4.1 Walk-Forward Analysis (WFA)

```python
# scripts/walk_forward_analysis.py

import numpy as np
import pandas as pd
from dataclasses import dataclass
from typing import List, Tuple

@dataclass
class WFAConfig:
    n_windows: int = 10           # Numero de janelas
    is_ratio: float = 0.7         # In-Sample ratio (70%)
    min_trades_per_window: int = 20
    overlap_ratio: float = 0.25   # 25% overlap entre janelas

@dataclass
class WFAResult:
    is_sharpe: List[float]        # Sharpe por janela IS
    oos_sharpe: List[float]       # Sharpe por janela OOS
    is_returns: List[float]       # Return por janela IS
    oos_returns: List[float]      # Return por janela OOS
    wfe: float                    # Walk-Forward Efficiency
    is_stable: bool               # Parametros estaveis?

def run_wfa(trades_df: pd.DataFrame, config: WFAConfig) -> WFAResult:
    """
    Walk-Forward Analysis para trades exportados do MT5
    
    WFE = mean(OOS_Sharpe) / mean(IS_Sharpe)
    WFE >= 0.6 = APROVADO
    WFE < 0.5 = OVERFIT DETECTADO
    """
    n = len(trades_df)
    window_size = n // config.n_windows
    
    is_sharpes, oos_sharpes = [], []
    is_returns, oos_returns = [], []
    
    for i in range(config.n_windows):
        # Calcular indices com overlap
        is_start = int(i * window_size * (1 - config.overlap_ratio))
        is_end = is_start + int(window_size * config.is_ratio)
        oos_start = is_end
        oos_end = min(is_start + window_size, n)
        
        # Extrair dados
        is_trades = trades_df.iloc[is_start:is_end]
        oos_trades = trades_df.iloc[oos_start:oos_end]
        
        if len(is_trades) < config.min_trades_per_window:
            continue
        if len(oos_trades) < config.min_trades_per_window // 2:
            continue
        
        # Calcular metricas
        is_sharpes.append(calculate_sharpe(is_trades['pnl']))
        oos_sharpes.append(calculate_sharpe(oos_trades['pnl']))
        is_returns.append(is_trades['pnl'].sum())
        oos_returns.append(oos_trades['pnl'].sum())
    
    # Walk-Forward Efficiency
    mean_is_sharpe = np.mean(is_sharpes) if is_sharpes else 0
    mean_oos_sharpe = np.mean(oos_sharpes) if oos_sharpes else 0
    wfe = mean_oos_sharpe / mean_is_sharpe if mean_is_sharpe > 0 else 0
    
    # Estabilidade
    sharpe_std = np.std(oos_sharpes) if oos_sharpes else float('inf')
    is_stable = sharpe_std < 0.5 * abs(mean_oos_sharpe)
    
    return WFAResult(
        is_sharpe=is_sharpes,
        oos_sharpe=oos_sharpes,
        is_returns=is_returns,
        oos_returns=oos_returns,
        wfe=wfe,
        is_stable=is_stable
    )

def calculate_sharpe(returns: pd.Series, risk_free=0, annualization=252) -> float:
    """Sharpe Ratio anualizado"""
    if len(returns) < 2 or returns.std() == 0:
        return 0
    excess = returns - risk_free / annualization
    return np.sqrt(annualization) * excess.mean() / returns.std()
```

### 4.2 Monte Carlo Block Bootstrap

```python
# scripts/monte_carlo_backtest.py

import numpy as np
from dataclasses import dataclass
from typing import Dict

@dataclass
class MonteCarloConfig:
    n_simulations: int = 5000     # Numero de simulacoes
    block_size: int = 7           # Tamanho do bloco (preserva autocorrelacao)
    confidence_levels: list = None
    initial_balance: float = 100000
    
    def __post_init__(self):
        if self.confidence_levels is None:
            self.confidence_levels = [0.05, 0.25, 0.50, 0.75, 0.95, 0.99]

@dataclass
class MonteCarloResult:
    dd_distribution: Dict[str, float]  # DD por percentil
    final_equity_distribution: Dict[str, float]
    ruin_probability: float            # P(DD > 10%)
    expected_max_dd: float
    expected_final_equity: float
    is_robust: bool

def monte_carlo_block_bootstrap(
    trades: np.ndarray,  # Array de P&L por trade
    config: MonteCarloConfig
) -> MonteCarloResult:
    """
    Block Bootstrap Monte Carlo
    
    Preserva autocorrelacao temporal usando blocos
    Mais realista que shuffle simples de trades
    """
    n_trades = len(trades)
    n_blocks = n_trades // config.block_size
    
    if n_blocks < 5:
        raise ValueError(f"Insufficient trades for block bootstrap. Need at least {5 * config.block_size}")
    
    max_dds = []
    final_equities = []
    
    for _ in range(config.n_simulations):
        # Resample blocks (com reposicao)
        block_indices = np.random.randint(0, n_blocks, size=n_blocks)
        
        sim_trades = []
        for idx in block_indices:
            start = idx * config.block_size
            end = min(start + config.block_size, n_trades)
            sim_trades.extend(trades[start:end])
        
        # Simular equity curve
        equity = config.initial_balance + np.cumsum(sim_trades)
        
        # Calcular max drawdown
        peak = np.maximum.accumulate(equity)
        dd_pct = (peak - equity) / peak * 100
        max_dd = dd_pct.max()
        
        max_dds.append(max_dd)
        final_equities.append(equity[-1])
    
    max_dds = np.array(max_dds)
    final_equities = np.array(final_equities)
    
    # Distribuicoes por percentil
    dd_dist = {
        f"dd_{int(p*100)}th": np.percentile(max_dds, p*100) 
        for p in config.confidence_levels
    }
    
    equity_dist = {
        f"equity_{int(p*100)}th": np.percentile(final_equities, p*100)
        for p in config.confidence_levels
    }
    
    # Probabilidade de ruina (DD > 10% = FTMO violation)
    ruin_prob = (max_dds > 10).mean()
    
    # Criterio de robustez
    # 95th percentile DD < 8% (buffer FTMO)
    is_robust = dd_dist['dd_95th'] < 8.0
    
    return MonteCarloResult(
        dd_distribution=dd_dist,
        final_equity_distribution=equity_dist,
        ruin_probability=ruin_prob,
        expected_max_dd=max_dds.mean(),
        expected_final_equity=final_equities.mean(),
        is_robust=is_robust
    )
```

### 4.3 Deflated Sharpe Ratio (Lopez de Prado)

```python
# scripts/deflated_sharpe.py

import numpy as np
from scipy import stats

def deflated_sharpe_ratio(
    observed_sharpe: float,
    n_trials: int,           # Numero de estrategias/parametros testados
    n_observations: int,     # Numero de observacoes (trades ou barras)
    skewness: float = 0,     # Skewness dos retornos
    kurtosis: float = 3      # Kurtosis dos retornos
) -> dict:
    """
    Deflated Sharpe Ratio (DSR) - Lopez de Prado (2014)
    
    Ajusta o Sharpe Ratio pelo numero de tentativas (multiple testing bias)
    
    Se DSR > 0 → Sharpe provavelmente e real
    Se DSR < 0 → Sharpe provavelmente e sorte/overfitting
    """
    # Expected maximum Sharpe under null hypothesis
    # E[max(SR)] when all strategies have zero true Sharpe
    euler_mascheroni = 0.5772156649
    
    # Approximate expected max Sharpe
    if n_trials > 1:
        expected_max_sr = np.sqrt(2 * np.log(n_trials)) - \
                         (euler_mascheroni + np.log(np.log(n_trials))) / \
                         (2 * np.sqrt(2 * np.log(n_trials)))
    else:
        expected_max_sr = 0
    
    # Standard error of Sharpe Ratio
    # Accounting for non-normality (skewness and kurtosis)
    se_sr = np.sqrt((1 + 0.5 * observed_sharpe**2 - 
                     skewness * observed_sharpe + 
                     ((kurtosis - 3) / 4) * observed_sharpe**2) / 
                    (n_observations - 1))
    
    # Deflated Sharpe Ratio
    dsr = (observed_sharpe - expected_max_sr) / se_sr
    
    # P-value (one-tailed test)
    p_value = 1 - stats.norm.cdf(dsr)
    
    return {
        'observed_sharpe': observed_sharpe,
        'expected_max_sharpe': expected_max_sr,
        'deflated_sharpe': dsr,
        'p_value': p_value,
        'is_significant': p_value < 0.05,
        'interpretation': 'REAL' if dsr > 0 else 'LIKELY_OVERFIT'
    }
```

---

## 5. CHECKLIST DE VALIDACAO COMPLETA

### 5.1 Criterios GO/NO-GO para FTMO

```python
# scripts/go_nogo_criteria.py

@dataclass
class FTMOValidationCriteria:
    """Criterios para aprovar estrategia para FTMO $100k"""
    
    # Walk-Forward Analysis
    min_wfe: float = 0.6              # Walk-Forward Efficiency
    min_oos_windows_profitable: float = 0.7  # 70% das janelas OOS positivas
    
    # Monte Carlo
    max_dd_95th: float = 8.0          # 95th percentile DD < 8%
    max_ruin_probability: float = 0.05  # P(DD>10%) < 5%
    
    # Statistical Significance
    min_deflated_sharpe: float = 0.0  # DSR > 0 (nao overfit)
    min_p_value: float = 0.05         # p < 0.05
    
    # Sample Size
    min_trades: int = 200             # Minimo de trades
    min_months: int = 24              # Minimo de meses
    
    # Performance
    min_profit_factor: float = 1.5
    min_win_rate: float = 0.55        # 55%
    max_max_dd: float = 10.0          # FTMO hard limit
    
    # Robustness
    max_sharpe_variance: float = 0.5  # Sharpe nao deve variar muito

def validate_for_ftmo(
    wfa_result: WFAResult,
    mc_result: MonteCarloResult,
    dsr_result: dict,
    basic_metrics: dict
) -> dict:
    """Validacao completa para FTMO"""
    
    criteria = FTMOValidationCriteria()
    checks = []
    
    # WFA Checks
    checks.append({
        'name': 'WFE >= 0.6',
        'value': wfa_result.wfe,
        'threshold': criteria.min_wfe,
        'passed': wfa_result.wfe >= criteria.min_wfe
    })
    
    # Monte Carlo Checks
    checks.append({
        'name': 'MC 95th DD < 8%',
        'value': mc_result.dd_distribution['dd_95th'],
        'threshold': criteria.max_dd_95th,
        'passed': mc_result.dd_distribution['dd_95th'] < criteria.max_dd_95th
    })
    
    checks.append({
        'name': 'Ruin Probability < 5%',
        'value': mc_result.ruin_probability * 100,
        'threshold': criteria.max_ruin_probability * 100,
        'passed': mc_result.ruin_probability < criteria.max_ruin_probability
    })
    
    # DSR Checks
    checks.append({
        'name': 'Deflated Sharpe > 0',
        'value': dsr_result['deflated_sharpe'],
        'threshold': criteria.min_deflated_sharpe,
        'passed': dsr_result['deflated_sharpe'] > criteria.min_deflated_sharpe
    })
    
    # Basic Metrics
    checks.append({
        'name': 'Profit Factor >= 1.5',
        'value': basic_metrics.get('profit_factor', 0),
        'threshold': criteria.min_profit_factor,
        'passed': basic_metrics.get('profit_factor', 0) >= criteria.min_profit_factor
    })
    
    checks.append({
        'name': 'Min 200 trades',
        'value': basic_metrics.get('total_trades', 0),
        'threshold': criteria.min_trades,
        'passed': basic_metrics.get('total_trades', 0) >= criteria.min_trades
    })
    
    # Final Decision
    all_passed = all(c['passed'] for c in checks)
    critical_passed = sum(1 for c in checks if c['passed'])
    
    return {
        'checks': checks,
        'all_passed': all_passed,
        'critical_passed': f"{critical_passed}/{len(checks)}",
        'decision': 'GO' if all_passed else 'NO-GO',
        'recommendation': get_recommendation(checks)
    }
```

---

## 6. COMPARACAO: MT5 vs PYTHON BACKTEST

### 6.1 Quando Usar Cada Um

| Cenario | MT5 Strategy Tester | Python (VectorBT) |
|---------|---------------------|-------------------|
| **Primeiro backtest** | ✅ Usar | - |
| **Validacao WFA** | - | ✅ Usar |
| **Monte Carlo** | - | ✅ Usar |
| **Otimizacao parametros** | ✅ Usar (cloud) | Opcional |
| **Teste do ONNX** | ✅ Obrigatorio | - |
| **Analise estatistica** | - | ✅ Usar |
| **Demo final** | ✅ Obrigatorio | - |

### 6.2 Realismo: O Que Simular

| Elemento | CBacktestRealism (MT5) | Python |
|----------|------------------------|--------|
| Slippage | ✅ SIM_PESSIMISTIC | Aplicar aos resultados |
| Spread variavel | ✅ Multipliers por condicao | Pode estimar |
| Latencia | ✅ Simulada | N/A (analise pos-hoc) |
| Rejeicoes | ✅ % configural | Pode estimar |
| Ticks reais | ✅ Every tick | N/A (usa trades) |

---

## 7. ACTIONABLE ITEMS

| # | Prioridade | Acao | Agente | Esforco |
|---|------------|------|--------|---------|
| 1 | **P1** | Criar `scripts/walk_forward_analysis.py` | FORGE | 2h |
| 2 | **P1** | Criar `scripts/monte_carlo_backtest.py` | FORGE | 2h |
| 3 | **P1** | Criar `scripts/deflated_sharpe.py` | FORGE | 1h |
| 4 | **P1** | Criar `scripts/go_nogo_validator.py` | FORGE | 1h |
| 5 | **P2** | Adicionar VectorBT ao requirements.txt | FORGE | 5min |
| 6 | **P2** | Script de export de trades do MT5 | FORGE | 1h |
| 7 | **P3** | Dashboard de visualizacao (Plotly) | FORGE | 3h |

---

## 8. FONTES TRIANGULADAS

### 8.1 Academicas
- Lopez de Prado - "Advances in Financial Machine Learning" (Deflated Sharpe)
- Jansen - "Machine Learning for Algorithmic Trading" (WFA)
- Van Tharp - "Trade Your Way to Financial Freedom" (R-Multiple, SQN)

### 8.2 Praticas (Codigo)
- VectorBT PRO: https://vectorbt.pro/
- backtesting.py: https://kernc.github.io/backtesting.py/
- Walk-Forward WFO repo: https://github.com/ChadThackray/WFO-backtesting

### 8.3 Empiricas (Comunidade)
- Forex Factory: Validacao de backtests XAUUSD
- Reddit r/algotrading: Experiencias com overfitting
- MQL5 Forum: Limitacoes do Strategy Tester

---

## 9. CONCLUSAO E VEREDICTO

### Veredicto: **USAR ABORDAGEM HIBRIDA**

**Justificativa**:
1. MT5 Strategy Tester para backtest PRIMARIO (unico que testa ONNX corretamente)
2. Python para validacao SECUNDARIA (WFA, Monte Carlo, DSR)
3. Combinacao garante REALISMO + ROBUSTEZ ESTATISTICA

**Proximos Passos Imediatos**:
1. Executar backtest no MT5 com `SIM_PESSIMISTIC`
2. Exportar trades para CSV
3. Rodar WFA + Monte Carlo em Python
4. Aplicar criterios GO/NO-GO

**Confianca na Recomendacao**: VERY_HIGH (3/3 triangulacao)

---

*Gerado por ARGUS - The All-Seeing Research Analyst*
*"A verdade esta la fora. Eu encontrei."*
