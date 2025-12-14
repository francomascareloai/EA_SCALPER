# References - ORACLE v2.2

## Scripts Python - APIs Detalhadas

### scripts/oracle/walk_forward.py

**Classes**: `WalkForwardAnalyzer`, `WFAWindow`, `WFAResult`, `WFAType`

```python
from scripts.oracle.walk_forward import WalkForwardAnalyzer, WFAType

# Configuracao
analyzer = WalkForwardAnalyzer(
    wfa_type=WFAType.ROLLING,  # ou ANCHORED
    n_windows=15,              # Numero de janelas
    is_ratio=0.75,             # 75% In-Sample
    overlap=0.20,              # 20% overlap entre janelas
    purge_gap=0.02,            # 2% gap para evitar leakage
    embargo_pct=0.01,          # 1% embargo pos-teste
    min_trades_per_window=30,  # Minimo trades por janela
    min_wfe=0.6                # WFE minimo para PASS
)

# Executar
result = analyzer.run(trades_df)  # DataFrame com datetime, pnl, direction

# Outputs
result.wfe                    # WFE agregado
result.windows                # Lista de WFAWindow
result.is_robust             # Bool: passou criterios?
result.mean_is_sharpe        # Sharpe medio IS
result.mean_oos_sharpe       # Sharpe medio OOS
result.oos_positive_ratio    # % windows OOS positivas
```

**CLI**:
```bash
python -m scripts.oracle.walk_forward --input trades.csv --windows 15 --mode rolling --output wfa_report.md
```

---

### scripts/oracle/monte_carlo.py

**Classes**: `MonteCarloBlockBootstrap`, `MonteCarloConfig`, `MonteCarloResult`

```python
from scripts.oracle.monte_carlo import MonteCarloBlockBootstrap, MonteCarloConfig

# Configuracao
config = MonteCarloConfig(
    n_simulations=5000,        # Numero de simulacoes
    block_size=0,              # 0 = auto (n^1/3)
    initial_balance=100000,    # Balance inicial
    confidence_levels=[0.05, 0.25, 0.50, 0.75, 0.95, 0.99]
)

mc = MonteCarloBlockBootstrap(config)

# Executar (pnl = array de P&L por trade)
result = mc.run(pnl_array)

# Outputs
result.dd_distribution        # Dict com percentis de DD
result.equity_distribution    # Dict com percentis de equity final
result.probability_of_ruin    # P(DD > 10%)
result.probability_of_ftmo_fail  # P(DD > 8%)
result.expected_max_dd        # E[MaxDD]
result.var_95                 # Value at Risk 95%
result.cvar_95                # Conditional VaR 95%
result.is_robust              # Bool: passou criterios?
result.confidence_score       # Score parcial 0-40
```

**CLI**:
```bash
python -m scripts.oracle.monte_carlo --input trades.csv --runs 5000 --block-size auto --output mc_report.md
```

---

### scripts/oracle/deflated_sharpe.py

**Classes**: `SharpeAnalyzer`, `SharpeAnalysisResult`

```python
from scripts.oracle.deflated_sharpe import SharpeAnalyzer

analyzer = SharpeAnalyzer()

# Executar (returns = array de retornos diarios)
result = analyzer.analyze(
    returns=returns_array,
    n_trials=100,              # Quantos backtests/parametros testados
    benchmark_sharpe=0.0,      # Sharpe de referencia
    confidence_level=0.95,     # Nivel de confianca
    annualization=252          # Fator de anualizacao
)

# Outputs
result.observed_sharpe        # Sharpe observado
result.probabilistic_sharpe   # PSR (Probabilistic Sharpe Ratio)
result.deflated_sharpe        # DSR (Deflated Sharpe Ratio)
result.expected_max_sharpe    # E[max(SR)] dado N trials
result.p_value                # P-value do teste
result.min_track_record_length  # MinTRL (trades minimos necessarios)
result.is_significant         # Bool: estatisticamente significante?
result.interpretation         # String com interpretacao
```

**PBO Calculation**:
```python
from scripts.oracle.deflated_sharpe import calculate_pbo

pbo = calculate_pbo(
    is_performance=is_sharpes,   # Array Sharpe IS por combinacao
    oos_performance=oos_sharpes  # Array Sharpe OOS por combinacao
)
# pbo < 0.25 = baixo risco de overfit
```

**CLI**:
```bash
python -m scripts.oracle.deflated_sharpe --input returns.csv --trials 100 --output sharpe_report.md
```

---

### scripts/oracle/execution_simulator.py

**Classes**: `ExecutionSimulator`, `ExecutionConfig`, `ExecutionResult`, `MarketCondition`

```python
from scripts.oracle.execution_simulator import ExecutionSimulator, ExecutionConfig, MarketCondition

# Configuracao PESSIMISTIC (recomendado para FTMO)
config = ExecutionConfig(
    base_slippage=5.0,         # 5 points base
    slippage_news_mult=10.0,   # 10x durante news
    slippage_volatile_mult=3.0, # 3x em alta volatilidade
    adverse_only=True,         # So slippage contra nos
    base_spread=25.0,          # 2.5 pips base
    spread_news_mult=5.0,      # 5x durante news
    spread_asian_mult=3.0,     # 3x sessao asiatica
    base_latency=100,          # 100ms base
    news_latency=500,          # +500ms em news
    max_latency=1500,          # Maximo 1.5s
    spike_probability=0.15,    # 15% chance de spike
    base_rejection_prob=0.10   # 10% rejeicao base
)

sim = ExecutionSimulator(config)

# Aplicar a DataFrame de trades
trades_with_costs = sim.apply_to_trades(trades_df)

# Outputs adicionados ao DataFrame:
# - exec_price: Preco executado
# - slippage_pts: Slippage em points
# - spread_pts: Spread em points
# - latency_ms: Latencia em ms
# - rejected: Bool se rejeitado
# - total_cost_pts: Custo total em points
```

**CLI**:
```bash
python -m scripts.oracle.execution_simulator --input trades.csv --mode pessimistic --output trades_with_costs.csv
```

---

### scripts/oracle/prop_firm_validator.py

**Classes**: `PropFirmValidator`, `FTMORules`, `PropFirmResult`

```python
from scripts.oracle.prop_firm_validator import PropFirmValidator

validator = PropFirmValidator(
    firm="ftmo",               # ftmo, mff, e8, etc
    account_size=100000,       # Tamanho da conta
    daily_dd_limit=5.0,        # Limite DD diario %
    total_dd_limit=10.0,       # Limite DD total %
    profit_target=10.0         # Target de profit %
)

# Executar validacao
result = validator.validate(trades_df)

# Outputs
result.p_daily_breach         # P(violar DD diario)
result.p_total_breach         # P(violar DD total)
result.p_pass                 # P(passar challenge)
result.dd_95th                # 95th percentile DD
result.max_losing_streak_dd   # DD do pior streak
result.recommended_risk       # Risk % recomendado
result.is_approved            # Bool: aprovado para challenge?
```

**CLI**:
```bash
python -m scripts.oracle.prop_firm_validator --input trades.csv --firm ftmo --account 100000 --output propfirm_report.md
```

---

### scripts/oracle/mt5_trade_exporter.py

**Classes**: `MT5TradeExporter`

```python
from scripts.oracle.mt5_trade_exporter import MT5TradeExporter

exporter = MT5TradeExporter(
    terminal_path=None,        # Caminho do terminal MT5 (opcional)
    login=12345,               # Login (opcional)
    password="***",            # Password (opcional)
    server="RoboForex-Demo"    # Server (opcional)
)

# Conectar
exporter.connect()

# Exportar trades pareados (entry + exit)
trades_df = exporter.export_paired_trades(
    from_date=datetime(2022, 1, 1),
    to_date=datetime(2024, 11, 30),
    symbol="XAUUSD",
    magic=123456               # Magic number do EA
)

# Salvar
exporter.save_to_csv(trades_df, "trades.csv")

# Desconectar
exporter.disconnect()
```

**CLI**:
```bash
python -m scripts.oracle.mt5_trade_exporter --symbol XAUUSD --magic 123456 --from 2022-01-01 --to 2024-11-30 --output trades.csv
```

---

### scripts/oracle/go_nogo_validator.py

**Classes**: `GoNoGoValidator`, `ValidationCriteria`, `ValidationResult`, `Decision`

```python
from scripts.oracle.go_nogo_validator import GoNoGoValidator, ValidationCriteria

# Criterios customizados (opcional)
criteria = ValidationCriteria(
    min_wfe=0.6,
    min_oos_positive=0.7,
    max_95th_dd=8.0,
    max_prob_ruin=0.05,
    min_psr=0.90,
    min_dsr=0.0,
    min_trades=100,
    min_sharpe=0.5,
    max_dd_realized=15.0
)

validator = GoNoGoValidator(criteria=criteria, n_trials=100)

# Executar pipeline completo
result = validator.validate(trades_df)

# Outputs
result.decision               # Decision.GO, Decision.NO_GO, Decision.INVESTIGATE
result.confidence             # Score 0-100
result.wfa_passed             # Bool
result.mc_passed              # Bool
result.sharpe_passed          # Bool
result.reasons                # Lista de razoes para NO-GO
result.warnings               # Lista de warnings
result.wfa_report             # Report WFA em Markdown
result.mc_report              # Report MC em Markdown
result.sharpe_report          # Report Sharpe em Markdown

# Gerar relatorio completo
full_report = validator.generate_full_report(result)
```

**CLI**:
```bash
python -m scripts.oracle.go_nogo_validator --input trades.csv --n-trials 100 --output DOCS/04_REPORTS/VALIDATION/go_nogo_report.md
```

---

## MCPs Utilizados

| MCP | Uso | Agente |
|-----|-----|--------|
| calculator | SQN, Sharpe, Kelly, estatisticas | ORACLE |
| e2b | Executar scripts Python complexos | ORACLE |
| postgres | Trade history, resultados persistidos | ORACLE |
| vega-lite | Equity curves, distribuicoes, graficos | ORACLE |
| mql5-books | Teoria estatistica, WFA, backtesting | ORACLE |

---

## Arquivos do Projeto

| Arquivo | Caminho |
|---------|---------|
| EA Principal | `MQL5/Experts/EA_SCALPER_XAUUSD.mq5` |
| Backtest Realism | `MQL5/Include/EA_SCALPER/Backtest/CBacktestRealism.mqh` |
| Modelo ONNX | `MQL5/Models/direction_model.onnx` |
| Scripts Oracle | `scripts/oracle/` |
| Deep Dive Research | `DOCS/03_RESEARCH/FINDINGS/DEEP_DIVE_BACKTESTING_MASTER.md` |
| Validation Reports | `DOCS/04_REPORTS/VALIDATION/` |

---

## Formulas Matematicas Completas

### Sharpe Ratio (Anualizado)
```
SR = sqrt(252) * mean(returns) / std(returns)

Onde:
- 252 = dias de trading por ano
- returns = retornos diarios (ou por trade)
```

### Sortino Ratio
```
Sortino = (mean(returns) - Rf) / Downside_Deviation

Downside_Deviation = sqrt(mean(min(0, returns - target)^2))
```

### SQN (System Quality Number)
```
SQN = sqrt(N) * (mean(R) / std(R))

Onde R = expectancy por trade

| SQN | Qualidade |
|-----|-----------|
| < 1.6 | Pobre |
| 1.6-2.0 | Abaixo media |
| 2.0-2.5 | Media |
| 2.5-3.0 | Boa |
| 3.0-5.0 | Excelente |
| 5.0-7.0 | Superb |
| > 7.0 | Holy Grail (suspeito!) |
```

### Walk-Forward Efficiency (WFE)
```
WFE = mean(OOS_performance) / mean(IS_performance)

Onde performance pode ser Sharpe, PF, ou Return.

| WFE | Interpretacao |
|-----|---------------|
| >= 0.8 | Excelente (muito robusto) |
| 0.6-0.8 | Bom (robusto) |
| 0.5-0.6 | Aceitavel (marginal) |
| 0.4-0.5 | Fraco (possivel overfit) |
| < 0.4 | Ruim (provavel overfit) |
```

### Probabilistic Sharpe Ratio (PSR)
```
PSR = Φ[(SR_obs - SR*) * sqrt(n-1) / sqrt(1 + 0.5*SR² - γ₃*SR + (γ₄-3)/4 * SR²)]

Onde:
- Φ = CDF da distribuicao normal padrao
- SR_obs = Sharpe observado
- SR* = Sharpe benchmark (geralmente 0)
- n = numero de observacoes
- γ₃ = skewness dos retornos
- γ₄ = kurtosis dos retornos

Interpretacao:
- PSR > 0.95: Sharpe MUITO provavelmente real
- PSR 0.90-0.95: Sharpe provavelmente real
- PSR 0.80-0.90: Incerto, pode ser sorte
- PSR < 0.80: Provavelmente sorte/overfit
```

### Expected Max Sharpe (sob H0)
```
E[max(SR)] ≈ sqrt(2 * ln(N)) - (γ + ln(ln(N))) / (2 * sqrt(2 * ln(N)))

Onde:
- N = numero de trials/estrategias testadas
- γ = 0.5772... (constante de Euler-Mascheroni)

Exemplos:
- N = 10:    E[max(SR)] ≈ 1.2
- N = 100:   E[max(SR)] ≈ 1.9
- N = 1000:  E[max(SR)] ≈ 2.4
- N = 10000: E[max(SR)] ≈ 2.8
```

### Deflated Sharpe Ratio (DSR)
```
DSR = (SR_obs - E[max(SR)]) / SE(SR)

Onde SE(SR) = erro padrao do Sharpe ajustado por skew/kurtosis.

Interpretacao:
- DSR > 0: Sharpe sobrevive ao ajuste por multiplos testes
- DSR < 0: Sharpe e provavelmente sorte/OVERFITTING
```

### Probability of Backtest Overfitting (PBO)
```
PBO = (1 - ρ(rank_IS, rank_OOS)) / 2

Onde ρ = correlacao de Spearman entre rankings IS e OOS.

Interpretacao:
- PBO < 0.25: Baixo risco de overfit
- PBO 0.25-0.50: Risco moderado
- PBO 0.50-0.75: Alto risco
- PBO > 0.75: Muito alto risco (quase certo overfit)
```

### Minimum Track Record Length (MinTRL)
```
MinTRL = z² * (1 + 0.5*SR² - γ₃*SR + (γ₄-3)/4 * SR²) / (SR - SR*)² + 1

Onde z = quantil da normal para o nivel de confianca desejado.

Interpretacao:
- MinTRL indica quantos periodos sao necessarios para ter X% de confianca
- Se N_trades < MinTRL, amostra insuficiente para conclusoes
```

### Value at Risk (VaR)
```
VaR_α = percentile(DD_distribution, α * 100)

Exemplo: VaR_95 = 95th percentile do Max DD
```

### Conditional VaR (CVaR / Expected Shortfall)
```
CVaR_α = E[DD | DD >= VaR_α]

= mean(DD para todas simulacoes onde DD >= VaR)

CVaR e mais conservador que VaR pois considera a cauda.
```

### Optimal Block Size (Politis & White, 2004)
```
block_size = n^(1/3)

Onde n = numero de trades.

Exemplos:
- 200 trades: block_size ≈ 6
- 500 trades: block_size ≈ 8
- 1000 trades: block_size ≈ 10
```

### FTMO Daily DD (Equity-Based)
```
Daily_DD = (Start_of_Day_Balance - Min_Equity_Today) / Initial_Balance * 100

IMPORTANTE:
- Usa EQUITY, nao balance
- Floating losses CONTAM
- Reset: meia-noite Prague Time (CE(S)T)
- Limite: 5% para $100k = $5,000
```

### Confidence Score Calculation
```
Score = WFA_component + MC_component + Sharpe_component + PropFirm_component + Bonus - Warnings

Onde:
- WFA_component: 25 se WFE >= 0.6
- MC_component: 25 se 95th_DD < 8% AND P(ruin) < 5%
- Sharpe_component: 20 se PSR >= 0.90 AND DSR > 0
- PropFirm_component: 20 se P(daily_breach) < 5% AND P(total_breach) < 2%
- Bonus: +10 se Level 4 robustness completo
- Warnings: -5 por warning

Interpretacao:
- 85-100: STRONG GO
- 70-84: GO
- 50-69: INVESTIGATE
- < 50: NO-GO
```

---

## Handoffs

| Para | Quando | Trigger |
|------|--------|---------|
| SENTINEL | Sizing apos GO | "calcular lot", "position sizing", "risk" |
| FORGE | Implementar fixes | "implementar", "corrigir", "fix" |
| CRUCIBLE | Ajustar estrategia | "ajustar parametros", "modificar setup" |
| ARGUS | Pesquisar metodologia | "pesquisar", "papers sobre", "como funciona" |

---

## 6 Tipos de Bias

1. **Survivorship Bias** - So ver winners (ativos que ainda existem)
2. **Look-Ahead Bias** - Usar informacao futura no calculo
3. **Data Mining Bias** - Testar milhares de combinacoes
4. **Overfitting** - Ajustar demais aos dados historicos
5. **Selection Bias** - Cherry-pick periodo favoravel
6. **Publication Bias** - So publicar resultados bons

---

## Onde Salvar Outputs

| Tipo | Pasta |
|------|-------|
| Backtest results | `DOCS/04_REPORTS/BACKTESTS/` |
| WFA/Monte Carlo | `DOCS/04_REPORTS/VALIDATION/` |
| GO/NO-GO decisions | `DOCS/04_REPORTS/DECISIONS/` |
| Progress updates | `DOCS/02_IMPLEMENTATION/PROGRESS.md` |
| Research findings | `DOCS/03_RESEARCH/FINDINGS/` |

---

## Configuration Templates

### WFA Config (Recommended)
```python
WFA_CONFIG = {
    "type": "rolling",
    "n_windows": 15,
    "is_ratio": 0.75,
    "overlap": 0.20,
    "purge_gap": 0.02,
    "embargo_pct": 0.01,
    "min_trades_per_window": 30,
    "min_wfe": 0.6
}
```

### Monte Carlo Config (Recommended)
```python
MC_CONFIG = {
    "n_simulations": 5000,
    "block_size": 0,  # 0 = auto
    "initial_balance": 100000,
    "confidence_levels": [0.05, 0.25, 0.50, 0.75, 0.95, 0.99]
}
```

### Execution Config (PESSIMISTIC - For FTMO)
```python
EXEC_CONFIG = {
    "base_slippage": 5.0,
    "slippage_news_mult": 10.0,
    "slippage_volatile_mult": 3.0,
    "adverse_only": True,
    "base_spread": 25.0,
    "spread_news_mult": 5.0,
    "spread_asian_mult": 3.0,
    "base_latency": 100,
    "news_latency": 500,
    "max_latency": 1500,
    "spike_probability": 0.15,
    "base_rejection_prob": 0.10
}
```

### Validation Criteria (Default)
```python
VALIDATION_CRITERIA = {
    "min_wfe": 0.6,
    "min_oos_positive": 0.7,
    "max_95th_dd": 8.0,
    "max_prob_ruin": 0.05,
    "min_psr": 0.90,
    "min_dsr": 0.0,
    "min_trades": 100,
    "min_sharpe": 0.5,
    "max_dd_realized": 15.0
}
```

---

## Referencias Academicas

### Papers Fundamentais
- **Pardo, R. (2008)** - "The Evaluation and Optimization of Trading Strategies" - BIBLIA do WFA
- **Lopez de Prado, M. (2018)** - "Advances in Financial Machine Learning" - PSR, DSR, CPCV
- **Bailey & Lopez de Prado (2014)** - "The Deflated Sharpe Ratio" - SSRN 2460551
- **Bailey et al. (2014)** - "The Probability of Backtest Overfitting" - SSRN 2326253
- **Politis & White (2004)** - "Automatic Block-Length Selection for the Dependent Bootstrap"

### Implementacoes
- **MLFinLab** - https://github.com/hudson-and-thames/mlfinlab
- **skfolio** - https://skfolio.org
- **PyBroker** - https://github.com/edtechre/pybroker
- **Build Alpha** - https://buildalpha.com/robustness-testing-guide

---

*ORACLE v2.2 References - Institutional-Grade Documentation*
