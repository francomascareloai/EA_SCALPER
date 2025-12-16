# ARGUS Research: Advanced Validation Methods for XAUUSD Tick Data
## Phase 5: Advanced Statistical Validation

**Date**: 2025-12-16
**Researcher**: ARGUS Quant Researcher
**Context**: 654M XAUUSD ticks (2003-2025), 12GB RAM constraint, NautilusTrader pipeline

---

## Executive Summary

Research identified significant improvements over the current Phase 5 validation approach. Key findings include better volatility models (GJR-GARCH, HAR-RV), comprehensive stylized facts testing for synthetic data detection, and memory-efficient processing with Polars streaming. A critical gap exists in automated look-ahead bias detection tools.

**Confidence Level**: HIGH (10+ sources triangulated across academic papers, code repositories, and library documentation)

---

## 1. Synthetic/Fake Financial Data Detection

### Current Approach
Not explicitly addressed in Phase 5.

### State-of-the-Art Methods

#### 1.1 Stylized Facts Battery Test
The gold standard for validating financial data authenticity is testing for known stylized facts:

| Stylized Fact | Test Method | Expected Result for Real Data |
|---------------|-------------|-------------------------------|
| Volatility Clustering | GARCH Likelihood Ratio Test | Significant GARCH effects |
| Leverage Effect | Correlation(r_t, sigma_{t+1}) | Negative correlation (-0.3 to -0.5) |
| Fat Tails | Hill Estimator, Excess Kurtosis | Tail index 3-5, kurtosis > 3 |
| Mean Reversion | Hurst Exponent | H ~ 0.5 for returns (random walk) |
| Volatility-Volume Correlation | Pearson/Spearman | Positive correlation |
| Slow Volatility Decay | ACF of squared returns | Slow decay, significant at long lags |

**Source**: Portfolio Optimization Book slides, arxiv:2205.15808

#### 1.2 LOB-Bench Framework
For limit order book data, LOB-Bench (arxiv:2502.09172) provides:
- Distributional metrics between real and synthetic data
- Conditional and unconditional statistics comparison
- Multivariate statistical evaluation

#### 1.3 Benford's Law Analysis
**Caution**: Recent research (ScienceDirect, Dec 2025) shows market prices do NOT always follow Benford's Law. Use with care as a secondary test only.

### Recommended Implementation
```python
def validate_data_authenticity(returns: pl.Series) -> dict:
    """Full stylized facts battery for authenticity validation."""
    results = {}

    # 1. Volatility clustering (GARCH LR test)
    from arch import arch_model
    model = arch_model(returns.to_numpy(), vol='GARCH', p=1, q=1)
    res = model.fit(disp='off')
    results['garch_lr_pvalue'] = res.pvalues['alpha[1]']

    # 2. Fat tails - Student-t fit
    from scipy.stats import t
    params = t.fit(returns.to_numpy())
    results['student_t_df'] = params[0]  # Expect 3-6 for real data

    # 3. Leverage effect
    import numpy as np
    sigma = np.abs(returns.to_numpy())
    results['leverage_corr'] = np.corrcoef(
        returns.to_numpy()[:-1],
        sigma[1:]
    )[0, 1]  # Expect negative

    # 4. ACF of squared returns
    from statsmodels.tsa.stattools import acf
    sq_returns = returns.to_numpy() ** 2
    acf_vals = acf(sq_returns, nlags=20)
    results['acf_sq_lag5'] = acf_vals[5]  # Expect > 0.05
    results['acf_sq_lag20'] = acf_vals[20]  # Expect > 0.02

    return results
```

---

## 2. Advanced Volatility Models

### Current Approach
GARCH on 1-min aggregated bars.

### Better Alternatives

#### 2.1 GJR-GARCH (Asymmetric Volatility)
Captures leverage effect where negative returns increase volatility more than positive returns.

```python
from arch import arch_model

# GJR-GARCH(1,1,1) with asymmetric term
model = arch_model(returns, p=1, o=1, q=1)
res = model.fit(disp='off')

# Check asymmetry coefficient (gamma)
gamma = res.params['gamma[1]']  # Expect positive for equities/gold
```

**Source**: arch library documentation, QuantInsti blog

#### 2.2 EGARCH (Exponential GARCH)
- No parameter constraints (can have negative coefficients)
- Log-volatility specification prevents negative variance
- Captures asymmetry differently than GJR

```python
from arch.univariate import EGARCH

model = arch_model(returns, vol='EGARCH', p=1, o=1, q=1)
res = model.fit(disp='off')
```

#### 2.3 HAR-RV (Heterogeneous Autoregressive Realized Volatility)
**Best for high-frequency data.** Decomposes volatility into daily, weekly, and monthly components.

```python
from arch.univariate import HARX, GARCH

# Compute realized volatility from intraday data first
realized_vol = compute_realized_variance(tick_data)  # 5-min sampling

# HAR model with GARCH errors
model = HARX(realized_vol, lags=[1, 5, 22], volatility=GARCH(1, 1, 1))
res = model.fit(disp='off')
```

**Source**: arch documentation, portfoliooptimizer.io, HAR model papers

#### 2.4 Recommendation for XAUUSD
Use **GJR-GARCH** for daily validation (captures gold's asymmetric response to shocks) and **HAR-RV** for high-frequency realized volatility analysis.

---

## 3. Market Microstructure Authenticity Tests

### Current Approach
Intraday volatility patterns by hour.

### Enhanced Tests

#### 3.1 Bid-Ask Spread Distribution
Real tick data should show:
- Spread distribution varies by hour (higher during Asia, lower during London/NY)
- Right-skewed spread distribution
- Minimum spread at tick size or broker-specific minimum

```python
def validate_spread_distribution(quotes: pl.DataFrame) -> dict:
    """Validate bid-ask spread patterns."""
    quotes = quotes.with_columns([
        (pl.col('ask') - pl.col('bid')).alias('spread'),
        pl.col('timestamp').dt.hour().alias('hour')
    ])

    hourly_spread = quotes.group_by('hour').agg([
        pl.col('spread').mean().alias('mean_spread'),
        pl.col('spread').std().alias('std_spread'),
        pl.col('spread').median().alias('median_spread')
    ]).sort('hour')

    return {
        'spread_by_hour': hourly_spread,
        'min_spread': quotes['spread'].min(),
        'spread_skewness': scipy.stats.skew(quotes['spread'].to_numpy())
    }
```

#### 3.2 Tick Arrival Patterns
- Inter-tick time distribution should follow exponential/Weibull
- Clustering of ticks during volatility spikes
- Weekend/holiday gaps

```python
def validate_tick_arrivals(ticks: pl.DataFrame) -> dict:
    """Validate tick arrival time patterns."""
    ticks = ticks.with_columns([
        (pl.col('timestamp').diff().dt.total_microseconds() / 1e6).alias('inter_tick_sec')
    ])

    from scipy.stats import expon, kstest
    inter_tick = ticks['inter_tick_sec'].drop_nulls().to_numpy()

    # Test exponential fit (Poisson arrival)
    ks_stat, ks_pvalue = kstest(inter_tick, 'expon', args=(0, inter_tick.mean()))

    return {
        'mean_inter_tick': inter_tick.mean(),
        'ks_exponential_pvalue': ks_pvalue,
        'tick_clustering': np.corrcoef(inter_tick[:-1], inter_tick[1:])[0,1]
    }
```

#### 3.3 Bid-Ask Bounce Detection
Real data exhibits "bid-ask bounce" - prices alternating between bid and ask levels.

**Source**: Tidy Finance blog, QuantPedia tick data article

---

## 4. Automated Look-Ahead Bias Detection

### Current Approach
Manual audit scripts checking for `.shift(-1)`, `bfill`, etc.

### Critical Finding: GAP IN ECOSYSTEM
**No automated static analysis tools exist for temporal leakage detection in financial code.**

### Recommended Solution: Build Custom Detector

#### 4.1 Regex-Based Scanner (Quick Win)
```python
import re
from pathlib import Path

LOOKAHEAD_PATTERNS = [
    (r'\.shift\s*\(\s*-\d+', 'Negative shift (future data)'),
    (r'\.bfill\s*\(', 'Backward fill (future data)'),
    (r'\.iloc\s*\[\s*-?\d+\s*:\s*\]', 'Potential future slicing'),
    (r'\.loc\s*\[\s*[\'"]?\d{4}-', 'Hardcoded date (check context)'),
    (r'future|tomorrow|next_day', 'Suspicious variable naming'),
    (r'\.rolling\s*\([^)]*\)\.apply\s*\([^)]*shift\s*\(-', 'Rolling with future shift'),
]

def scan_lookahead_bias(file_path: Path) -> list:
    """Scan Python file for potential look-ahead bias patterns."""
    findings = []
    content = file_path.read_text()

    for line_no, line in enumerate(content.splitlines(), 1):
        for pattern, description in LOOKAHEAD_PATTERNS:
            if re.search(pattern, line, re.IGNORECASE):
                findings.append({
                    'file': str(file_path),
                    'line': line_no,
                    'pattern': description,
                    'code': line.strip()
                })

    return findings
```

#### 4.2 AST-Based Analyzer (Comprehensive)
For production, build an AST-based analyzer using Python's `ast` module to:
- Track dataflow of time-indexed variables
- Detect temporal relationships in assignments
- Flag operations that combine future and past data

**Development Estimate**: 2-3 days for basic version

---

## 5. Modern Autocorrelation for High-Frequency Data

### Current Approach
ACF magnitude check (ACF(1) > 0.15, ACF(5) > 0.08).

### Enhanced Methods

#### 5.1 Realized Kernels
Handle microstructure noise in tick data by using kernel-based estimators.

```python
from arch.covariance.kernel import Bartlett, Parzen

# Compute long-run covariance with noise correction
returns_sq = returns ** 2
cov_est = Bartlett(returns_sq.to_numpy().reshape(-1, 1))
long_run_var = cov_est.cov.long_run
```

#### 5.2 Multiscale HAR Components
Test autocorrelation at multiple frequencies:
- Daily lag (lag 1)
- Weekly lag (lag 5)
- Monthly lag (lag 22)

```python
def compute_har_acf(realized_vol: np.ndarray) -> dict:
    """Compute HAR-style multiscale autocorrelation."""
    from statsmodels.tsa.stattools import acf

    acf_vals = acf(realized_vol, nlags=25, fft=True)

    return {
        'acf_daily': acf_vals[1],   # Expect 0.3-0.6
        'acf_weekly': acf_vals[5],  # Expect 0.2-0.4
        'acf_monthly': acf_vals[22] # Expect 0.1-0.3
    }
```

---

## 6. Jump Detection in Tick Data

### Current Approach
Not addressed.

### Recommended Methods

#### 6.1 Lee-Mykland Jump Detection
Python implementation available (GitHub Gist).

```python
def lee_mykland_jumps(log_prices: np.ndarray, window: int = 270) -> np.ndarray:
    """
    Detect jumps using Lee-Mykland (2008) algorithm.

    Returns array of jump statistics (|L| > 4.6 indicates jump at 99.9% level).
    """
    import numpy as np

    n = len(log_prices)
    returns = np.diff(log_prices)

    # Compute bipower variation for local volatility
    bpv = np.zeros(n - 1)
    for i in range(window, n - 1):
        r_window = returns[i-window:i]
        bpv[i] = np.sqrt(np.pi/2) * np.mean(np.abs(r_window[1:]) * np.abs(r_window[:-1]))

    # Jump statistic
    L = returns[window:] / bpv[window:]

    # Critical value adjustment
    c_n = np.sqrt(2 * np.log(n)) - (np.log(np.pi) + np.log(np.log(n))) / (2 * np.sqrt(2 * np.log(n)))
    s_n = 1 / np.sqrt(2 * np.log(n))

    jump_stat = (np.abs(L) - c_n) / s_n

    return jump_stat
```

**Source**: Lee & Mykland (2008), Python Gist by linuskohl

#### 6.2 Bipower Variation Jump Test
```python
def bipower_variation_jump_test(returns: np.ndarray) -> dict:
    """Test for jumps using bipower variation vs realized variance."""
    rv = np.sum(returns ** 2)
    bv = (np.pi / 2) * np.sum(np.abs(returns[1:]) * np.abs(returns[:-1]))

    # Jump contribution
    jump_component = max(0, rv - bv)
    jump_ratio = jump_component / rv

    return {
        'realized_variance': rv,
        'bipower_variation': bv,
        'jump_ratio': jump_ratio,  # > 0.1 suggests significant jumps
        'has_jumps': jump_ratio > 0.1
    }
```

---

## 7. Memory-Efficient GARCH for Large Datasets

### Challenge
654M ticks exceeds 12GB RAM constraint.

### Solution: Aggregate First, Then GARCH

#### 7.1 Polars Streaming Aggregation
```python
import polars as pl

def stream_aggregate_to_bars(parquet_path: str, bar_freq: str = '1m') -> pl.LazyFrame:
    """Stream tick data and aggregate to OHLCV bars."""
    return (
        pl.scan_parquet(parquet_path)
        .sort('timestamp')
        .group_by_dynamic('timestamp', every=bar_freq)
        .agg([
            pl.col('price').first().alias('open'),
            pl.col('price').max().alias('high'),
            pl.col('price').min().alias('low'),
            pl.col('price').last().alias('close'),
            pl.col('volume').sum().alias('volume')
        ])
    )

# Process in chunks
lf = stream_aggregate_to_bars('xauusd_ticks.parquet', '1m')

# Stream collect in batches for GARCH
for batch in lf.collect(streaming=True).iter_slices(n_rows=100_000):
    # Process batch
    pass
```

#### 7.2 Daily Chunked GARCH
Process one day at a time, accumulate sufficient statistics:
```python
def chunked_garch_validation(parquet_path: str) -> dict:
    """Validate GARCH effects using daily chunks."""
    daily_stats = []

    lf = pl.scan_parquet(parquet_path)
    dates = lf.select(pl.col('timestamp').dt.date().unique()).collect()['timestamp']

    for date in dates:
        day_data = (
            lf.filter(pl.col('timestamp').dt.date() == date)
            .collect()
        )

        if len(day_data) > 100:
            returns = day_data['price'].pct_change().drop_nulls()
            daily_stats.append({
                'date': date,
                'mean': returns.mean(),
                'std': returns.std(),
                'kurtosis': scipy.stats.kurtosis(returns.to_numpy())
            })

    # Aggregate daily stats for overall GARCH test
    return aggregate_garch_test(daily_stats)
```

---

## 8. Spread Distribution Analysis for Fraud Detection

### Patterns of Authentic Data
1. **Minimum spread at tick size**: Real data has broker-specific minimum spreads
2. **Time-of-day variation**: Spreads widen during low-liquidity hours (Asia session)
3. **Event spikes**: Spreads spike during news events
4. **Right-skewed distribution**: Most spreads near minimum, long tail

### Patterns of Synthetic/Fake Data
1. **Unrealistic minimum spreads**: Too tight or uniform
2. **No time-of-day variation**: Constant spread throughout
3. **Gaussian distribution**: Symmetric, no tail
4. **Missing gaps**: No weekend/holiday periods

```python
def detect_synthetic_spread_patterns(quotes: pl.DataFrame) -> dict:
    """Detect patterns suggesting synthetic data."""
    spreads = (quotes['ask'] - quotes['bid']).to_numpy()

    red_flags = []

    # Check 1: Minimum spread unrealistic
    min_spread = spreads.min()
    if min_spread < 0.0001:  # Too tight for XAUUSD
        red_flags.append('Unrealistic minimum spread')

    # Check 2: Spread distribution
    skewness = scipy.stats.skew(spreads)
    if skewness < 1.0:  # Should be right-skewed
        red_flags.append('Spread distribution not right-skewed')

    # Check 3: Time-of-day variation
    quotes_with_hour = quotes.with_columns(pl.col('timestamp').dt.hour().alias('hour'))
    hourly_std = quotes_with_hour.group_by('hour').agg(
        pl.col('ask') - pl.col('bid')
    ).std()
    if hourly_std < min_spread * 0.5:  # Should vary by hour
        red_flags.append('No time-of-day spread variation')

    return {
        'is_likely_authentic': len(red_flags) == 0,
        'red_flags': red_flags,
        'min_spread': min_spread,
        'spread_skewness': skewness
    }
```

---

## 9. Key Libraries and Tools

| Tool | Purpose | Python Package | Notes |
|------|---------|---------------|-------|
| arch | GARCH, EGARCH, GJR-GARCH, HAR | `pip install arch` | Primary volatility library |
| statsmodels | ACF, ARIMA, statistical tests | `pip install statsmodels` | Autocorrelation analysis |
| scipy | Distribution fitting, KS tests | `pip install scipy` | Fat tail analysis |
| polars | Memory-efficient data processing | `pip install polars` | Streaming for large datasets |
| highfrequency (R) | Realized measures, jump tests | R package | Port key functions to Python |

### Python Equivalents for R highfrequency
No direct Python equivalent exists. Key functions to port:
- `rCov()` - Realized covariance
- `rKurt()` - Realized kurtosis
- `AJjumpTest()` - Ait-Sahalia-Jacod jump test
- `LM.JumpTest()` - Lee-Mykland jump test (Python gist available)

---

## 10. Academic References

1. **Stylized Facts**: Cont, R. (2001). "Empirical Properties of Asset Returns: Stylized Facts and Statistical Issues"
2. **Realized Variance**: Hansen, P.R. & Lunde, A. (2006). "Realized Variance and Market Microstructure Noise"
3. **HAR Model**: Corsi, F. (2009). "A Simple Approximate Long-Memory Model of Realized Volatility"
4. **Jump Detection**: Lee, S.S. & Mykland, P.A. (2008). "Jumps in Equilibrium Prices and Market Microstructure Noise"
5. **GARCH Variants**: Glosten, L.R., Jagannathan, R., & Runkle, D.E. (1993). "GJR-GARCH"
6. **LOB-Bench**: Nagy, P. et al. (2025). "LOB-Bench: Benchmarking Generative AI for Finance"

---

## 11. Recommendations Summary

### High Priority Improvements
1. **Replace GARCH with GJR-GARCH**: Captures asymmetric volatility in gold
2. **Add Stylized Facts Battery**: Comprehensive authenticity validation
3. **Implement Jump Detection**: Lee-Mykland algorithm for discontinuity detection
4. **Build Look-Ahead Bias Scanner**: Regex-based first, AST-based later

### Medium Priority Improvements
1. **Enhance ACF Analysis**: Use HAR-style multiscale components
2. **Add Spread Distribution Validation**: Time-of-day patterns, skewness
3. **Improve Fat Tail Testing**: Student-t fitting with Hill estimator

### Implementation Order
1. Polars streaming aggregation (unblocks other tests)
2. GJR-GARCH validation
3. Stylized facts battery
4. Look-ahead bias scanner
5. Jump detection
6. Microstructure authenticity tests

---

## 12. Risks and Limitations

| Risk | Mitigation |
|------|------------|
| Polars streaming is experimental | Fall back to daily chunking |
| No Python highfrequency package | Port critical R functions |
| Stylized facts may pass for good GANs | Combine with microstructure tests |
| Look-ahead scanner false positives | Require manual review of findings |
| Memory constraints | Aggregate before analysis |

---

## Next Handoff

**FORGE**: Implement recommended validation functions in `/nautilus_gold_scalper/data_pipeline/`
**ORACLE**: Validate improvements on subset of tick data
**SENTINEL**: Review risk implications of validation findings

---

*Research completed: 2025-12-16*
*Confidence: HIGH (10+ sources, triangulated across academic/code/empirical)*
