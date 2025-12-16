# ARGUS Research: Look-Ahead Bias Detection and Prevention

**Research Date:** 2025-12-16
**Agent:** ARGUS (Quant Researcher)
**Objective:** State-of-the-art techniques for detecting and preventing look-ahead bias in trading systems and ML pipelines
**Confidence Level:** HIGH (3+ independent sources, reproducible methods, quantified metrics)

---

## Executive Summary

This research provides comprehensive guidance on detecting and preventing look-ahead bias (also known as temporal leakage) in trading systems, with specific focus on NautilusTrader event-driven backtesting. Key findings:

- **17 dangerous code patterns** cataloged with detection grep commands
- **6 automated detection tools** identified from academic and open-source sources
- **3 types of ML leakage** documented with F2 scores up to 0.72 for detection
- **NautilusTrader-specific** configuration and verification procedures
- **PBO/DSR methodology** for statistical validation of backtest results

**Impact:** Look-ahead bias can inflate backtest returns by 50%+ (e.g., momentum CAGR 26% with survivorship bias vs 12.2% without). Detection and prevention is CRITICAL for reliable strategy validation.

---

## Table of Contents

1. [Detection Techniques by Category](#1-detection-techniques-by-category)
2. [Dangerous Code Patterns Catalog](#2-dangerous-code-patterns-catalog)
3. [Tools and Resources](#3-tools-and-resources)
4. [Academic Papers and References](#4-academic-papers-and-references)
5. [NautilusTrader-Specific Configuration](#5-nautilustrader-specific-configuration)
6. [Additions to Audit Protocol](#6-additions-to-audit-protocol)
7. [Implementation Priority](#7-implementation-priority)
8. [Handoff Recommendations](#8-handoff-recommendations)

---

## 1. Detection Techniques by Category

### 1.1 Code-Level Detection Patterns

#### Signal Lagging with .shift(1)
**Source:** Jakub Polec, Medium (Dec 2024)

```python
# WRONG: Today's MA crossover -> Buy today
signal = sma_short > sma_long  # Uses today's close, trades today

# RIGHT: Yesterday's MA crossover -> Buy today
signal = (sma_short > sma_long).shift(1)  # Uses previous day's signal
```

**Lagging Rules by Data Type:**
| Data Type | Required Lag | Rationale |
|-----------|--------------|-----------|
| Technical signals | 1 bar | Signal from bar T, trade at bar T+1 |
| Quarterly earnings | 45 days | SEC filing delay |
| Annual reports | 90 days | Filing and processing delay |
| Insider transactions | 2 days | Reporting delay |
| News sentiment | 3 days | Market propagation time |
| Analyst estimates | 1 day | Publication delay |

#### Architectural Prevention (AsyncLocalStorage)
**Source:** Petr Tripolsky, Medium (Dec 2025)

Make look-ahead **architecturally impossible** by bounding all data access to current simulation time:

```javascript
// Node.js/TypeScript - Immutable temporal context
const backtestContext = new AsyncLocalStorage();

async function processTick(timestamp, symbol) {
  const context = { currentTime: timestamp };
  await backtestContext.run(context, async () => {
    const signal = await strategy.getSignal(symbol);
  });
}

async function getCandles(symbol, interval, limit) {
  const context = backtestContext.getStore();
  // Future data is ARCHITECTURALLY IMPOSSIBLE to access
  return await exchange.getCandles(symbol, interval, context.currentTime, limit);
}
```

**Python Equivalent:**
```python
from contextvars import ContextVar

current_time: ContextVar[datetime] = ContextVar('current_time')

def get_historical_data(symbol: str, end_time: datetime = None) -> pd.DataFrame:
    if end_time is None:
        end_time = current_time.get()
    # All queries bounded by context time
    return data_provider.get_data(symbol, end=end_time)
```

### 1.2 ML-Specific Leakage Detection

**Source:** NIH/PMC Academic Paper (Mar 2025)

#### Three Types of Data Leakage:

**Type 1: Overlap Leakage**
- Same samples in train and test sets
- Common cause: SMOTE/resampling before split

```python
# WRONG
X_resampled, y_resampled = smote.fit_resample(X, y)  # Line 6
X_train, X_test = train_test_split(X_resampled, y_resampled)  # LEAK!

# RIGHT
X_train, X_test, y_train, y_test = train_test_split(X, y)
X_train_res, y_train_res = smote.fit_resample(X_train, y_train)  # After split
```

**Type 2: Multi-Test Leakage**
- Shared test set across experiments
- Leads to implicit overfitting on test set

**Type 3: Pre-Processing Leakage**
- Preprocessing uses test set information

```python
# WRONG
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)  # Uses full dataset statistics
X_train, X_test = train_test_split(X_scaled)  # LEAK!

# RIGHT
X_train, X_test = train_test_split(X)
scaler = MinMaxScaler()
X_train_scaled = scaler.fit_transform(X_train)  # Fit on train only
X_test_scaled = scaler.transform(X_test)  # Transform only
```

#### Detection Performance:
| Method | F2 Score | Source |
|--------|----------|--------|
| Active Learning | 0.72 | NIH/PMC 2025 |
| Transfer Learning (CodeBERT) | 0.67 | NIH/PMC 2025 |
| Low-Shot Prompting | 0.39 | NIH/PMC 2025 |
| Static Analysis | 92.9% accuracy | Yang et al. 2022 |

### 1.3 Walk-Forward Validation Best Practices

**Source:** Perplexity Search, arxiv:2512.12924 (Dec 2024)

#### 7 Key Principles for Look-Ahead Prevention:

1. **Strict Time Segmentation**
   - In-sample (train/optimize) followed by out-of-sample (test)
   - Every parameter based ONLY on data prior to test block

2. **Rolling or Expanding Windows**
   - Rolling: 2010-2015 train -> 2016 test; 2011-2016 -> 2017 test
   - Expanding: 2010-2015, then 2010-2016, always test forward

3. **Never Re-Optimize on Test Data**
   - Parameters frozen BEFORE test block starts
   - Cannot tune using test outcomes

4. **Information-Set Discipline**
   - Only features known at decision time
   - No future bars, revised data, forward-filled missing values

5. **Pseudo-Live Equity Curve**
   - Concatenate all OOS segments
   - Evaluate OOS curve, not in-sample

6. **Guardrails Against Overfitting**
   - Limit optimizable parameters
   - Inspect parameter-surface stability
   - Check consistency across regimes

7. **Modern Frameworks (2024)**
   - 30+ independent walk-forward periods
   - Realistic costs and position constraints

### 1.4 Survivorship Bias Detection

**Source:** QuantifiedStrategies, Michael Harris

#### Impact Quantified:
| Strategy | With Survivorship | Without | Difference |
|----------|-------------------|---------|------------|
| S&P 100 Momentum | 26% CAGR | 12.2% CAGR | -53% |
| Nasdaq 100 Momentum | 46% CAGR | 16.4% CAGR | -64% |
| Dow 30 Trend-Following | 5.6% CAGR | 7.7% CAGR | +37% |
| S&P 100 Trend-Following | 6.5% CAGR | 8.4% CAGR | +29% |

**Key Insight (Bessembinder 2017):**
- Only 42.1% of common stocks beat T-bills
- 50% delivered negative returns
- Median stock life: only 7 years
- 86 out of 26,000 stocks made half the value creation

**Prevention:**
- Use Norgate Data (survivorship-free databases with delistings)
- Use index-level data (S&P 500, Nasdaq) for survivorship-free analysis
- XAUUSD: Single asset, not affected by equity survivorship

---

## 2. Dangerous Code Patterns Catalog

### Pattern 1: Forward-Looking Shift
```python
# WRONG
df['future_return'] = df['close'].shift(-1)  # Looks 1 bar into future

# RIGHT
df['signal'] = df['indicator'].shift(1)  # Uses previous bar
```
**Grep:** `rg "\.shift\s*\(\s*-\d" --type py`

### Pattern 2: Forward-Looking Rolling
```python
# WRONG
df.rolling(window).sum().shift(-window + 1)  # Forward-looking window

# RIGHT
df.rolling(window).sum()  # Already uses past data only
```
**Grep:** `rg "rolling.*\.shift\s*\(\s*-" --type py`

### Pattern 3: Preprocessing Before Split
```python
# WRONG
X_scaled = scaler.fit_transform(X)
X_train, X_test = train_test_split(X_scaled)

# RIGHT
X_train, X_test = train_test_split(X)
scaler.fit(X_train)
X_train_scaled = scaler.transform(X_train)
X_test_scaled = scaler.transform(X_test)
```
**Grep:** `rg "fit_transform" --type py -l | xargs -I {} grep -l "train_test_split" {}`

### Pattern 4: Full-Sample Statistics in Features
```python
# WRONG
df['zscore'] = (df['close'] - df['close'].mean()) / df['close'].std()

# RIGHT
df['zscore'] = (df['close'] - df['close'].rolling(252).mean()) / df['close'].rolling(252).std()
```
**Grep:** `rg "\.mean\(\)|\.std\(\)" --type py` (requires manual review)

### Pattern 5: SMOTE/Resampling Before Split
```python
# WRONG
X_res, y_res = smote.fit_resample(X, y)
X_train, X_test = train_test_split(X_res, y_res)

# RIGHT
X_train, X_test = train_test_split(X, y)
X_train_res, y_train_res = smote.fit_resample(X_train, y_train)
```
**Grep:** `rg "SMOTE|fit_resample" --type py`

### Pattern 6: Feature Selection on Full Dataset
```python
# WRONG
selector.fit(X, y)
X_sel = selector.transform(X)
X_train, X_test = train_test_split(X_sel)

# RIGHT
X_train, X_test = train_test_split(X, y)
selector.fit(X_train, y_train)
X_train_sel = selector.transform(X_train)
X_test_sel = selector.transform(X_test)
```
**Grep:** `rg "SelectKBest|RFE|feature_selection.*fit" --type py`

### Pattern 7: Target Encoding on Full Dataset
```python
# WRONG
encoder.fit_transform(X['category'], y)  # Before split

# RIGHT
# Fit encoder on train only, transform both
```
**Grep:** `rg "TargetEncoder|target_encode" --type py`

### Pattern 8: Imputation on Full Dataset
```python
# WRONG
imputer.fit_transform(X)  # Before split

# RIGHT
imputer.fit(X_train)
X_train = imputer.transform(X_train)
X_test = imputer.transform(X_test)
```
**Grep:** `rg "SimpleImputer|KNNImputer|fillna.*method" --type py`

### Pattern 9: Using Close Price for Same-Day Decisions
```python
# WRONG
if close > ma: buy_at_close()  # Can't know close until bar completes

# RIGHT
if close > ma: buy_next_open()  # Signal today, execute tomorrow
```
**Grep:** `rg "if.*close.*:|close.*>|close.*<" --type py` (manual review)

### Pattern 10: Fundamental Data Without Lag
```python
# WRONG
# Using earnings data on announcement date

# RIGHT
# Lag quarterly earnings by 45 days
df['earnings_signal'] = df['earnings'].shift(45)  # For daily bars
```
**Grep:** `rg "earnings|fundamental|announcement" --type py`

### Pattern 11: Bar Timestamp at Open
```python
# WRONG - Nautilus
timestamp_on_close=False  # Timestamps at bar open

# RIGHT - Nautilus
timestamp_on_close=True  # Timestamps at bar close (default)
```
**Grep:** `rg "timestamp_on_close" --type py`

### Pattern 12: Missing Execution Delay
```python
# WRONG
# Execute at signal price

# RIGHT
# Execute at next available price with slippage
bar_execution=True  # Nautilus: simulates intrabar OHLC
```
**Grep:** `rg "bar_execution" --type py`

### Pattern 13: Missing ts_init_delta (Nautilus)
```python
# WRONG
wrangler = BarDataWrangler(...)  # No ts_init_delta

# RIGHT
wrangler = BarDataWrangler(
    ...,
    ts_init_delta=60_000_000_000  # 1 minute in nanoseconds
)
```
**Grep:** `rg "ts_init_delta" --type py`

### Pattern 14: timestamp_on_close=False (Nautilus)
```python
# WRONG
bars_timestamp_on_close=False  # Open time

# RIGHT
bars_timestamp_on_close=True  # Close time (default)
```
**Grep:** `rg "bars_timestamp_on_close" --type py`

### Pattern 15: Missing bar_execution Flag (Nautilus)
```python
# WRONG
bar_execution=False  # No intrabar simulation

# RIGHT
bar_execution=True  # Simulates OHLC micro-path
```
**Grep:** `rg "bar_execution" --type py`

### Pattern 16: Fixed H-L Ordering (Nautilus)
```python
# WRONG
bar_adaptive_high_low_ordering=False  # Fixed ordering

# RIGHT
bar_adaptive_high_low_ordering=True  # Adaptive based on open/close
```
**Grep:** `rg "bar_adaptive_high_low_ordering" --type py`

### Pattern 17: Missing bar_build_delay (Nautilus)
```python
# WRONG
# No delay between bar build and processing

# RIGHT
bar_build_delay=15_000  # 15 microseconds
```
**Grep:** `rg "bar_build_delay" --type py`

---

## 3. Tools and Resources

### 3.1 Academic Detection Tools

| Tool | Method | Performance | Source |
|------|--------|-------------|--------|
| Static Analysis (Yang et al.) | AST-based pattern matching | 92.9% accuracy | ASE'22 |
| CodeBERT Transfer Learning | Fine-tuned BERT | F2: 0.67 | NIH/PMC 2025 |
| Active Learning | Human-in-the-loop | F2: 0.72 | NIH/PMC 2025 |
| LeakageDetector 2.0 | Enhanced notebook detection | N/A | arxiv:2509.15971 |
| CMU Static Detection | Jupyter-focused | N/A | CMU Paper |

### 3.2 Open-Source Packages

| Package | Platform | Purpose | URL |
|---------|----------|---------|-----|
| pbo | R (CRAN) | Probability of Backtest Overfitting | cran.r-project.org/web/packages/pbo/ |
| Code4ML | Python | Leakage detection dataset | Zenodo/Figshare |

### 3.3 Data Providers (Survivorship-Free)

| Provider | Coverage | Feature |
|----------|----------|---------|
| Norgate Data | US/Australian equities | Includes delistings |
| Index Data | S&P 500, Nasdaq | Survivorship-free by definition |

---

## 4. Academic Papers and References

### 4.1 Core Papers

**1. Backtest Overfitting in the Machine Learning Era**
- Authors: Arian et al.
- Source: SSRN 4778909 (Nov 2024)
- Key Finding: CPCV outperforms Walk-Forward with lower PBO
- URL: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4778909

**2. The Deflated Sharpe Ratio**
- Authors: Bailey & Lopez de Prado
- Source: 2014, ResearchGate
- Key Finding: Corrects for selection bias and non-normality
- URL: https://www.researchgate.net/publication/286121118

**3. Data Leakage Detection in ML Code**
- Source: NIH/PMC (Mar 2025)
- Key Finding: Active learning achieves F2=0.72
- Dataset: Code4ML on Zenodo

**4. Walk-Forward Validation Framework**
- Source: arxiv:2512.12924 (Dec 2024)
- Key Finding: 30+ independent test periods, open-source code

**5. Do Stocks Outperform Treasury Bills?**
- Author: Bessembinder (2017)
- Key Finding: Only 42.1% of stocks beat T-bills

**6. Static Analysis for Data Leakage**
- Authors: Yang et al. (ASE'22)
- Key Finding: 92.9% detection accuracy

### 4.2 Practical Articles

| Article | Author | Date | Key Technique |
|---------|--------|------|---------------|
| Signal Lagging | Jakub Polec | Dec 2024 | .shift(1) for signals |
| AsyncLocalStorage Prevention | Petr Tripolsky | Dec 2025 | Architectural prevention |
| Survivorship Bias | QuantifiedStrategies | 2024 | Delistings impact |
| Trend-Following Tests | Michael Harris | 2019-2020 | Survivorship quantification |

---

## 5. NautilusTrader-Specific Configuration

### 5.1 Timestamp Semantics

**ts_event vs ts_init:**
- `ts_event`: Bar CLOSING time (when bar is complete and emitted)
- `ts_init`: Initialization time of data object or update

**Key Principle:** Bars are only "finalized" at `ts_event` (close), so strategies cannot act on them before this timestamp.

### 5.2 Configuration Checklist

```python
# BarDataWrangler Configuration
wrangler = BarDataWrangler(
    bar_type=bar_type,
    instrument=instrument,
    ts_init_delta=bar_interval_ns,  # CRITICAL: Set to bar interval
)

# BacktestEngine Configuration
engine = BacktestEngine(
    config=BacktestEngineConfig(
        bar_execution=True,  # CRITICAL: Enable intrabar simulation
        bar_adaptive_high_low_ordering=True,  # Realistic H/L ordering
    )
)

# Data Adapter Configuration
adapter_config = SomeAdapterConfig(
    bars_timestamp_on_close=True,  # CRITICAL: Close timestamps
)

# TimeBarAggregator Configuration
aggregator = TimeBarAggregator(
    ...
    bar_build_delay=15_000,  # 15 microseconds delay
)
```

### 5.3 Verification Procedures

```python
# 1. Sample Check - Verify timestamps
for bar in bars[:10]:
    print(f"ts_event: {bar.ts_event}, ts_init: {bar.ts_init}")
    assert bar.ts_event == expected_close_time(bar)
    assert bar.ts_init >= bar.ts_event  # Or equal for historical

# 2. Runtime Check - In strategy.on_bar()
def on_bar(self, bar: Bar) -> None:
    current_time = self.clock.utc_now()
    assert current_time >= bar.ts_event, "Processing bar before close!"

# 3. Data Access Check
def get_historical_bars(self, bar_type, count):
    bars = self.cache.bars(bar_type)
    current_time = self.clock.utc_now()
    return [b for b in bars if b.ts_event <= current_time]
```

### 5.4 Databento Normalization

For data sources timestamped at open (e.g., Databento), Nautilus normalizes to close by adding the bar interval:

```python
# Automatic normalization in adapter
# Open timestamp: 2024-01-01 09:30:00
# Bar interval: 1 minute
# Normalized ts_event: 2024-01-01 09:31:00 (close time)
```

---

## 6. Additions to Audit Protocol

### 6.1 Data Pipeline Audit

- [ ] Verify `ts_init_delta = bar_interval_ns` in BarDataWrangler
- [ ] Verify `bars_timestamp_on_close=True` in data adapters
- [ ] Sample check: Print first 10 bars, verify ts_event = expected close
- [ ] Verify no data with ts_event > current simulation time is accessible
- [ ] Check for external data source timestamp conventions

### 6.2 Strategy Code Audit

- [ ] Run grep commands for all 17 dangerous patterns
- [ ] Verify all signals use `.shift(1)` or equivalent lagging
- [ ] Check indicator library usage (TA-Lib, etc.) for implicit leakage
- [ ] Verify no full-sample statistics in feature engineering
- [ ] Check for forward-fill that may introduce leakage

### 6.3 Backtest Configuration Audit

- [ ] Verify `bar_execution=True` in BacktestEngine
- [ ] Verify `bar_adaptive_high_low_ordering` setting (document choice)
- [ ] Verify `bar_build_delay > 0` in TimeBarAggregator
- [ ] Document all configuration choices and rationale

### 6.4 ML Pipeline Audit (if applicable)

- [ ] Verify train/test split respects temporal ordering
- [ ] Verify preprocessing (scaling, imputation) fits on train only
- [ ] Verify no SMOTE/resampling before split
- [ ] Verify feature selection on train only
- [ ] Calculate PBO for final strategy
- [ ] Calculate DSR for final strategy

### 6.5 Validation Metrics

| Metric | Threshold | Status |
|--------|-----------|--------|
| PBO (Probability of Backtest Overfitting) | < 20% | [ ] |
| DSR (Deflated Sharpe Ratio) | > 0 | [ ] |
| WFE (Walk-Forward Efficiency) | >= 0.6 | [ ] |
| Multiple OOS periods consistency | Pass | [ ] |

---

## 7. Implementation Priority

### Priority 1: Immediate (Low Effort)
- Run grep commands on codebase for dangerous patterns
- Verify Nautilus configuration parameters
- Add timestamp verification tests

### Priority 2: Short-term (Medium Effort)
- Implement signal lagging (.shift(1)) verification
- Add PBO calculation to validation pipeline
- Add DSR calculation to validation pipeline

### Priority 3: Medium-term (Higher Effort)
- Implement CPCV cross-validation
- Add automated leakage detection to CI/CD
- Create comprehensive test suite for temporal correctness

### Priority 4: Long-term (Infrastructure)
- Consider architectural prevention (context-based data access)
- Implement runtime leakage detection
- Add multi-OOS period validation

---

## 8. Handoff Recommendations

### To ORACLE (Backtest Commander)
- Implement PBO calculation in validation suite
- Implement DSR calculation in validation suite
- Add CPCV cross-validation option
- Verify WFE >= 0.6 with temporal correctness

### To CRUCIBLE (Strategy Design)
- Ensure all signals use .shift(1) lagging
- Document fundamental/sentiment data lags
- Design strategies with temporal correctness in mind

### To FORGE (Implementation)
- Add grep commands to pre-commit hooks
- Implement timestamp verification tests
- Add runtime leakage detection logging

### To SENTINEL (Risk/Compliance)
- Verify DD calculation timestamps
- Verify time gate implementation
- Ensure Apex compliance with temporal correctness

### To NAUTILUS (Architecture)
- Verify data pipeline configuration
- Implement architectural prevention patterns
- Add context-based data access if needed

---

## Appendix: Complete Grep Command Suite

```bash
# Run all detection patterns on codebase
cd /home/franco/projetos/EA_SCALPER_XAUUSD

# 1. Forward-looking shift
rg "\.shift\s*\(\s*-\d" --type py

# 2. Forward-looking rolling
rg "rolling.*\.shift\s*\(\s*-" --type py

# 3. SMOTE/resampling patterns
rg "SMOTE|fit_resample" --type py

# 4. Full-sample statistics (manual review)
rg "\.mean\(\)|\.std\(\)|\.min\(\)|\.max\(\)" --type py

# 5. Feature selection on full data
rg "SelectKBest|RFE|feature_selection.*fit" --type py

# 6. Target encoding
rg "TargetEncoder|target_encode" --type py

# 7. Imputation patterns
rg "SimpleImputer|KNNImputer|fillna.*method" --type py

# 8. Close price decision (manual review)
rg "if.*close.*:|close.*>|close.*<" --type py

# 9. Nautilus timestamp config
rg "timestamp_on_close|ts_init_delta|bar_execution" --type py

# 10. Fundamental data (manual review)
rg "earnings|fundamental|announcement" --type py
```

---

## Research Metadata

**Sequential Thinking:** 45 thoughts completed
**Sources Searched:** 10+ academic, code, and practical sources
**Patterns Cataloged:** 17 dangerous code patterns
**Tools Identified:** 6 automated detection tools
**Papers Referenced:** 6+ academic papers (2014-2025)
**Confidence:** HIGH (triangulated across academic, code, and empirical sources)

**Limitations:**
- Grep commands may have false negatives for subtle patterns
- Some leakage patterns require manual code review
- Tools like LeakageDetector 2.0 are recent and evolving
- Implementation details matter for PBO/DSR calculations

**Next Steps:**
1. Run grep audit on current codebase
2. Verify Nautilus configuration
3. Implement PBO/DSR in validation pipeline
4. Add temporal correctness tests to CI/CD
