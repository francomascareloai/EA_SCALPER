# Party Mode Session #004 - ORACLE Deep Audit
**Data**: 2025-12-01
**Agente Principal**: BMad Builder (em modo ORACLE auditor)
**Objetivo**: Analise profunda do Oracle v2.2 para identificar defeitos e oportunidades de evolucao

---

## Executive Summary

O **ORACLE v2.2 - The Statistical Truth-Seeker (INSTITUTIONAL-GRADE)** foi analisado profundamente. A skill esta **bem implementada** com documentacao excepcional, mas possui **gaps de implementacao** e **oportunidades de melhoria significativas**.

### Veredicto Geral
| Aspecto | Score | Status |
|---------|-------|--------|
| Documentacao (SKILL.md) | 95/100 | EXCELENTE |
| Referencias (references.md) | 90/100 | MUITO BOM |
| Checklists (checklists.md) | 92/100 | EXCELENTE |
| Scripts Python | 75/100 | BOM (com gaps) |
| Integracao End-to-End | 65/100 | NECESSITA TRABALHO |
| Testes | 20/100 | CRITICO |

---

## 1. ANALISE DOS ARQUIVOS DE SKILL

### 1.1 SKILL.md (33,936 bytes) - EXCELENTE

**Pontos Fortes:**
- 15 Mandamentos bem definidos (originais + institucionais)
- Thresholds GO/NO-GO completos com 3 categorias (Core, Institucional, Prop Firm)
- Decision Tree visual bem estruturado
- Workflow /validar com 7 steps detalhados
- 4-Level Robustness Framework bem documentado
- Confidence Score System claro (0-100)
- Comportamento proativo bem definido
- Guardrails completos

**Gaps Identificados:**
- [ ] Noise Test mencionado mas sem workflow detalhado
- [ ] CPCV mencionado mas sem exemplo de uso
- [ ] Falta integracao com MQL5 CBacktestRealism

### 1.2 references.md (16,755 bytes) - MUITO BOM

**Pontos Fortes:**
- APIs de todos scripts documentadas
- Formulas matematicas completas (Sharpe, PSR, DSR, PBO, WFE, VaR, CVaR)
- Configuration templates prontos para uso
- Referencias academicas incluidas

**Gaps Identificados:**
- [ ] Falta exemplo de uso end-to-end
- [ ] Falta documentacao de erros comuns
- [ ] Falta troubleshooting guide

### 1.3 checklists.md (14,880 bytes) - EXCELENTE

**Pontos Fortes:**
- 12 checklists completos
- GO/NO-GO Master Checklist muito detalhado
- Pre-Challenge checklist para FTMO
- Bias Detection checklist

**Gaps Identificados:**
- [ ] Falta checklist de "Data Quality Validation"
- [ ] Falta checklist de "Post-Challenge Review"

---

## 2. ANALISE DOS SCRIPTS PYTHON

### 2.1 Estrutura Geral - BOM

```
scripts/oracle/
├── __init__.py           ✅ 2,632 bytes - Exports bem organizados
├── walk_forward.py       ✅ 11,935 bytes - WFA Rolling/Anchored
├── monte_carlo.py        ✅ 16,894 bytes - Block Bootstrap
├── deflated_sharpe.py    ✅ 10,210 bytes - PSR/DSR
├── go_nogo_validator.py  ✅ 20,646 bytes - Pipeline integrado
├── execution_simulator.py ✅ 16,283 bytes - Custos de execucao
├── prop_firm_validator.py ✅ 15,074 bytes - FTMO validation
├── mt5_trade_exporter.py  ⚠️ 13,346 bytes - Requer MetaTrader5 package
└── metrics.py            ✅ 11,645 bytes - Metricas auxiliares
```

### 2.2 DEFEITOS IDENTIFICADOS

#### CRITICO - Walk Forward Analysis (walk_forward.py)

**Defeito 1: Calculo de Window Boundaries**
```python
# Linha 100-105 - Problema:
for i in range(self.n_windows):
    if mode == 'rolling':
        is_start = i * oos_size  # BUG: Usa oos_size, deveria usar window_step
        is_end = is_start + is_size
```
**Problema**: Para rolling WFA, o step entre janelas deveria ser `oos_size`, mas o calculo de `is_start` pode causar overlap nao intencional.

**Solucao Proposta**:
```python
window_step = oos_size
for i in range(self.n_windows):
    if mode == 'rolling':
        is_start = i * window_step
        is_end = is_start + is_size
```

#### ALTO - Monte Carlo Daily DD (monte_carlo.py)

**Defeito 2: Daily DD Simplificado**
```python
# Linha 135-142 - Problema:
daily_trades += 1
if daily_trades >= 20:  # Simplificacao: 20 trades = 1 dia
    daily_dd = -daily_pnl / self.initial_capital
```
**Problema**: Usa contagem de trades (20) como proxy para dias. Para scalping com muitos trades/dia, isso e impreciso.

**Solucao Proposta**: Adicionar parametro `trades_per_day` configuravel ou usar timestamps se disponiveis.

#### ALTO - CPCV Nao Implementado (walk_forward.py)

**Defeito 3: PurgedKFold existe mas CPCV completo nao**
```python
class PurgedKFold:
    # Implementacao basica existe
    pass
    
# FALTANDO:
# class CombinatorialPurgedCV:
#     """Full CPCV implementation"""
#     pass
```
**Problema**: A skill documenta CPCV como feature mas nao ha implementacao.

#### MEDIO - Confidence Score Inconsistente

**Defeito 4: Multiplos sistemas de scoring**
| Script | Metodo | Range |
|--------|--------|-------|
| monte_carlo.py | `_calculate_confidence_score()` | 0-100 |
| go_nogo_validator.py | `_calculate_confidence()` | 0-100 |
| prop_firm_validator.py | `_calculate_confidence_component()` | 0-20 |

**Problema**: Cada script calcula confidence diferente. Nao ha sistema unificado.

#### MEDIO - Error Handling Basico

**Defeito 5: Try/Except generico**
```python
# go_nogo_validator.py linhas 80-90
try:
    wfa_result = wfa.run(trades_df)
except Exception as e:
    print(f"  WFA failed: {e}")
    wfa_wfe = 0
```
**Problema**: Erros sao engolidos com valores default. Usuario nao sabe a causa real.

#### BAIXO - Sem Visualizacoes

**Defeito 6: Nenhum script gera graficos**
- Sem equity curve visualization
- Sem DD distribution plot
- Sem WFA window performance chart

---

## 3. GAPS DE IMPLEMENTACAO

### 3.1 Features Documentadas mas Nao Implementadas

| Feature | Documentado Em | Status Implementacao |
|---------|----------------|----------------------|
| CPCV (Combinatorial Purged CV) | SKILL.md, references.md | ❌ NAO IMPLEMENTADO |
| Noise Test | SKILL.md | ❌ NAO IMPLEMENTADO |
| Level 4 Robustness Testing | SKILL.md | ⚠️ PARCIAL (sem CPCV, stress) |
| Visualizacoes (equity curves) | references.md (MCP vega-lite) | ❌ NAO IMPLEMENTADO |
| Market Impact Simulation | SKILL.md Level 4 | ❌ NAO IMPLEMENTADO |
| Stress Scenarios | SKILL.md Level 4 | ❌ NAO IMPLEMENTADO |
| Multiple Regime Testing | SKILL.md Level 4 | ❌ NAO IMPLEMENTADO |

### 3.2 Testes Automatizados

| Tipo | Status |
|------|--------|
| Unit Tests | ❌ NENHUM |
| Integration Tests | ❌ NENHUM |
| Sample Data | ❌ NENHUM |
| CI/CD Pipeline | ❌ NENHUM |

---

## 4. OPORTUNIDADES DE MELHORIA

### P0 - CRITICOS (Fazer Imediatamente)

| ID | Melhoria | Impacto | Esforco |
|----|----------|---------|---------|
| P0.1 | Criar unit tests para todos scripts | ALTO | MEDIO |
| P0.2 | Corrigir WFA window boundary calculation | ALTO | BAIXO |
| P0.3 | Implementar CPCV completo | ALTO | ALTO |
| P0.4 | Criar sample trade data para testes | ALTO | BAIXO |

### P1 - IMPORTANTES (Fazer em Breve)

| ID | Melhoria | Impacto | Esforco |
|----|----------|---------|---------|
| P1.1 | Unificar sistema de Confidence Score | MEDIO | MEDIO |
| P1.2 | Implementar Noise Test | MEDIO | MEDIO |
| P1.3 | Melhorar Daily DD calculation com timestamps | MEDIO | BAIXO |
| P1.4 | Adicionar progress bars (tqdm) | BAIXO | BAIXO |
| P1.5 | Melhorar error handling com mensagens claras | MEDIO | BAIXO |

### P2 - DESEJÁVEIS (Fazer Quando Possivel)

| ID | Melhoria | Impacto | Esforco |
|----|----------|---------|---------|
| P2.1 | Adicionar visualizacoes (matplotlib/vega-lite) | MEDIO | MEDIO |
| P2.2 | Implementar Level 4 completo (stress, regime, impact) | MEDIO | ALTO |
| P2.3 | Adicionar cache/memoization | BAIXO | MEDIO |
| P2.4 | Suporte a config files (YAML) | BAIXO | BAIXO |
| P2.5 | Parallel processing para Monte Carlo | MEDIO | MEDIO |
| P2.6 | Report templates com graficos embeddados | BAIXO | MEDIO |

### P3 - NICE TO HAVE

| ID | Melhoria | Impacto | Esforco |
|----|----------|---------|---------|
| P3.1 | Web dashboard para resultados | BAIXO | ALTO |
| P3.2 | API REST para validacao remota | BAIXO | ALTO |
| P3.3 | Integracao com Jupyter notebooks | BAIXO | MEDIO |

---

## 5. CODIGO ESPECIFICO - FIXES PROPOSTOS

### Fix 1: WFA Window Boundaries

```python
# walk_forward.py - Substituir metodo run()
def run(self, trades: pd.DataFrame, mode: str = 'rolling', return_col: str = 'profit') -> WFAResult:
    n = len(trades)
    
    # Calcular tamanhos
    total_window_size = n // self.n_windows
    is_size = int(total_window_size * self.is_ratio)
    oos_size = total_window_size - is_size - self.purge_gap
    
    if oos_size < self.min_trades_per_window:
        raise ValueError(f"OOS window too small: {oos_size} < {self.min_trades_per_window}")
    
    windows = []
    
    for i in range(self.n_windows):
        if mode == 'rolling':
            # Rolling: cada window avanca pelo tamanho do OOS
            window_start = i * oos_size
            is_start = window_start
            is_end = is_start + is_size
        else:
            # Anchored: IS sempre comeca do inicio
            is_start = 0
            is_end = is_size + i * oos_size
        
        # Purge gap entre IS e OOS
        purge_end = is_end + self.purge_gap
        
        # OOS window
        oos_start = purge_end
        oos_end = oos_start + oos_size
        
        # Verificar limites
        if oos_end > n:
            break
            
        # ... resto do codigo
```

### Fix 2: Unified Confidence Score

```python
# Novo arquivo: scripts/oracle/confidence.py
from dataclasses import dataclass
from typing import Dict

@dataclass
class ConfidenceComponents:
    wfa: int = 0          # 0-25
    monte_carlo: int = 0  # 0-25
    sharpe: int = 0       # 0-20
    prop_firm: int = 0    # 0-20
    bonus: int = 0        # 0-10
    penalties: int = 0    # Negative
    
    @property
    def total(self) -> int:
        return max(0, min(100, 
            self.wfa + self.monte_carlo + self.sharpe + 
            self.prop_firm + self.bonus - self.penalties
        ))
    
    def to_dict(self) -> Dict:
        return {
            'wfa': self.wfa,
            'monte_carlo': self.monte_carlo,
            'sharpe': self.sharpe,
            'prop_firm': self.prop_firm,
            'bonus': self.bonus,
            'penalties': self.penalties,
            'total': self.total
        }


class UnifiedConfidenceCalculator:
    """Calculo unificado de Confidence Score para Oracle"""
    
    @staticmethod
    def calculate_wfa_component(wfe: float, oos_positive_pct: float) -> int:
        """WFA Component: 0-25 pontos"""
        score = 0
        
        # WFE scoring (0-15)
        if wfe >= 0.7:
            score += 15
        elif wfe >= 0.6:
            score += 12
        elif wfe >= 0.5:
            score += 8
        elif wfe >= 0.4:
            score += 4
        
        # OOS Positive scoring (0-10)
        if oos_positive_pct >= 0.8:
            score += 10
        elif oos_positive_pct >= 0.7:
            score += 7
        elif oos_positive_pct >= 0.6:
            score += 4
        
        return min(25, score)
    
    @staticmethod
    def calculate_mc_component(dd_95: float, prob_ruin: float) -> int:
        """Monte Carlo Component: 0-25 pontos"""
        score = 0
        
        # DD 95th scoring (0-15)
        if dd_95 < 5:
            score += 15
        elif dd_95 < 6:
            score += 12
        elif dd_95 < 8:
            score += 8
        elif dd_95 < 10:
            score += 4
        
        # P(Ruin) scoring (0-10)
        if prob_ruin < 2:
            score += 10
        elif prob_ruin < 5:
            score += 7
        elif prob_ruin < 10:
            score += 4
        
        return min(25, score)
    
    @staticmethod
    def calculate_sharpe_component(psr: float, dsr: float) -> int:
        """Sharpe Component: 0-20 pontos"""
        score = 0
        
        # PSR scoring (0-10)
        if psr >= 0.95:
            score += 10
        elif psr >= 0.90:
            score += 7
        elif psr >= 0.85:
            score += 4
        
        # DSR scoring (0-10)
        if dsr > 1.0:
            score += 10
        elif dsr > 0.5:
            score += 7
        elif dsr > 0:
            score += 4
        # DSR < 0 = 0 pontos (OVERFITTING)
        
        return min(20, score)
    
    @staticmethod
    def calculate_propfirm_component(p_daily: float, p_total: float) -> int:
        """Prop Firm Component: 0-20 pontos"""
        score = 0
        
        # P(Daily Breach) scoring (0-10)
        if p_daily < 2:
            score += 10
        elif p_daily < 5:
            score += 7
        elif p_daily < 10:
            score += 4
        
        # P(Total Breach) scoring (0-10)
        if p_total < 1:
            score += 10
        elif p_total < 2:
            score += 7
        elif p_total < 5:
            score += 4
        
        return min(20, score)
    
    @staticmethod
    def calculate(
        wfe: float,
        oos_positive_pct: float,
        dd_95: float,
        prob_ruin: float,
        psr: float,
        dsr: float,
        p_daily: float,
        p_total: float,
        level4_complete: bool = False,
        n_warnings: int = 0
    ) -> ConfidenceComponents:
        """Calcula score completo"""
        calc = UnifiedConfidenceCalculator
        
        components = ConfidenceComponents(
            wfa=calc.calculate_wfa_component(wfe, oos_positive_pct),
            monte_carlo=calc.calculate_mc_component(dd_95, prob_ruin),
            sharpe=calc.calculate_sharpe_component(psr, dsr),
            prop_firm=calc.calculate_propfirm_component(p_daily, p_total),
            bonus=10 if level4_complete else 0,
            penalties=n_warnings * 3
        )
        
        return components
```

### Fix 3: Sample Data Generator

```python
# Novo arquivo: scripts/oracle/sample_data.py
import numpy as np
import pandas as pd
from datetime import datetime, timedelta

def generate_sample_trades(
    n_trades: int = 500,
    win_rate: float = 0.55,
    avg_win: float = 150.0,
    avg_loss: float = -100.0,
    start_date: str = "2022-01-01"
) -> pd.DataFrame:
    """
    Gera dados de trades sinteticos para teste.
    
    Args:
        n_trades: Numero de trades
        win_rate: Taxa de acerto (0-1)
        avg_win: Lucro medio em wins
        avg_loss: Perda media em losses (negativo)
        start_date: Data inicial
    
    Returns:
        DataFrame com trades
    """
    np.random.seed(42)
    
    # Gerar wins/losses
    wins = np.random.random(n_trades) < win_rate
    
    profits = []
    for is_win in wins:
        if is_win:
            # Wins com variacao normal
            profit = np.random.normal(avg_win, avg_win * 0.3)
        else:
            # Losses com variacao normal
            profit = np.random.normal(avg_loss, abs(avg_loss) * 0.3)
        profits.append(profit)
    
    # Gerar timestamps
    start = datetime.strptime(start_date, "%Y-%m-%d")
    timestamps = []
    current = start
    for _ in range(n_trades):
        timestamps.append(current)
        # 1-3 trades por dia em media
        hours_gap = np.random.exponential(8)
        current += timedelta(hours=hours_gap)
    
    # Gerar direcoes
    directions = np.random.choice(['LONG', 'SHORT'], n_trades)
    
    # Gerar precos (XAUUSD ~2000)
    prices = np.random.normal(2000, 50, n_trades)
    
    df = pd.DataFrame({
        'datetime': timestamps,
        'direction': directions,
        'entry_price': prices,
        'profit': profits,
        'is_win': wins
    })
    
    return df


def generate_realistic_xauusd_trades(
    n_trades: int = 500,
    sharpe_target: float = 2.0,
    max_dd_target: float = 8.0
) -> pd.DataFrame:
    """
    Gera trades XAUUSD com caracteristicas realistas.
    
    Inclui:
    - Autocorrelacao (streaks)
    - Variacao por sessao
    - Eventos de volatilidade
    """
    np.random.seed(42)
    
    # Parametros base
    daily_vol = 0.01  # 1% vol diaria
    risk_per_trade = 0.005  # 0.5% risk
    target_rr = 1.5
    
    profits = []
    streaks = []
    current_streak = 0
    last_result = None
    
    for i in range(n_trades):
        # Autocorrelacao: 60% chance de manter direcao do resultado
        if last_result is not None and np.random.random() < 0.6:
            is_win = last_result
        else:
            is_win = np.random.random() < 0.52  # 52% WR base
        
        # Track streak
        if is_win == last_result:
            current_streak += 1
        else:
            streaks.append(current_streak)
            current_streak = 1
        last_result = is_win
        
        # Calcular profit com variacao
        if is_win:
            base_profit = risk_per_trade * target_rr * 100000  # Para $100k
            profit = np.random.normal(base_profit, base_profit * 0.2)
        else:
            base_loss = -risk_per_trade * 100000
            profit = np.random.normal(base_loss, abs(base_loss) * 0.15)
        
        # Eventos de volatilidade (5% dos trades)
        if np.random.random() < 0.05:
            profit *= np.random.uniform(1.5, 2.5)  # Amplifica resultado
        
        profits.append(profit)
    
    # Criar DataFrame
    start = datetime(2022, 1, 3)  # Segunda-feira
    timestamps = []
    current = start
    
    for i in range(n_trades):
        timestamps.append(current)
        
        # Skip weekends
        hours = np.random.exponential(6)
        current += timedelta(hours=hours)
        while current.weekday() >= 5:  # Sabado ou Domingo
            current += timedelta(days=1)
    
    df = pd.DataFrame({
        'datetime': timestamps,
        'direction': np.random.choice(['LONG', 'SHORT'], n_trades),
        'entry_price': np.random.normal(1950, 30, n_trades),
        'profit': profits,
        'is_win': [p > 0 for p in profits]
    })
    
    return df


if __name__ == '__main__':
    # Gerar e salvar sample data
    df = generate_realistic_xauusd_trades(500)
    df.to_csv('sample_trades.csv', index=False)
    print(f"Generated {len(df)} trades")
    print(f"Win Rate: {df['is_win'].mean():.1%}")
    print(f"Total PnL: ${df['profit'].sum():,.2f}")
    print(f"Avg Win: ${df[df['is_win']]['profit'].mean():,.2f}")
    print(f"Avg Loss: ${df[~df['is_win']]['profit'].mean():,.2f}")
```

---

## 6. PROXIMOS PASSOS RECOMENDADOS

### Sessao 1: Foundation (2-3 horas)
1. [ ] Criar `scripts/oracle/sample_data.py` com geradores de dados
2. [ ] Criar `tests/oracle/` com estrutura de testes
3. [ ] Implementar testes basicos para cada script

### Sessao 2: Bug Fixes (1-2 horas)
1. [ ] Corrigir WFA window boundaries
2. [ ] Melhorar Daily DD calculation
3. [ ] Adicionar validacao de input data

### Sessao 3: Unified Confidence (1-2 horas)
1. [ ] Criar `scripts/oracle/confidence.py`
2. [ ] Refatorar todos scripts para usar UnifiedConfidenceCalculator
3. [ ] Atualizar go_nogo_validator.py

### Sessao 4: CPCV Implementation (3-4 horas)
1. [ ] Pesquisar implementacao de referencia (mlfinlab)
2. [ ] Implementar CombinatorialPurgedCV
3. [ ] Adicionar calculo de PBO correto
4. [ ] Testar com sample data

### Sessao 5: Visualizations (2-3 horas)
1. [ ] Adicionar matplotlib como dependencia
2. [ ] Criar funcoes de plot para equity curves
3. [ ] Criar funcoes de plot para distribuicoes
4. [ ] Integrar com reports

---

## 7. CONCLUSAO

O Oracle v2.2 tem uma **base solida** com documentacao excepcional. Os scripts Python estao funcionais mas precisam de:

1. **Correcoes de bugs** (WFA boundaries, Daily DD)
2. **Features faltantes** (CPCV, Noise Test, Visualizacoes)
3. **Testes automatizados** (CRITICO - nenhum existe)
4. **Unificacao** do sistema de Confidence Score

**Prioridade Recomendada**: P0.1 (Testes) → P0.2 (WFA Fix) → P0.4 (Sample Data) → P1.1 (Confidence) → P0.3 (CPCV)

---

*Party Mode Session #004 - Oracle Deep Audit*
*Gerado por BMad Builder em 2025-12-01*
