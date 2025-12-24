# ORACLE3: Mean Revert Signal Quality Improvements

## ORACLE Output

AGENT: ORACLE-BACKTEST-COMMANDER
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE

---

## Executive Summary

This document analyzes and designs four key improvements for the Mean Revert (MR) signal generator to increase trade frequency from ~5/month to 10+/month while maintaining or improving signal quality.

**Current State (6-month backtest)**:
- 29 trades (~5/month)
- Win rate: 79.3%
- Threshold: 65 (default 70 produced 0 trades)
- One catastrophic loss: $1,239 (7x avg winner)

**Target**: 10+ trades/month with >= 75% win rate and reduced max loss.

---

## 1. Session Guard Enhancement (IMP-04)

### Current Implementation Analysis

From `strategy_selector.py:404-416`:
- Asian session blocked unless `is_reverting AND hurst < 0.40`
- When allowed: `size_multiplier = 0.5`, `score_adjustment -= 5`

This is at the **selector level**, not the signal generator level.

### Proposed Enhancement: Session-Specific Signal Thresholds

Add session awareness directly to MR signal generation:

```python
# Session-specific MR thresholds (in mean_revert.py or config)
@dataclass(frozen=True, slots=True)
class SessionMRThresholds:
    """Session-specific thresholds for Mean Revert signals."""
    min_score: float
    rsi_oversold: float
    rsi_overbought: float
    bb_k: float
    size_multiplier: float


SESSION_MR_CONFIG = {
    "asian": SessionMRThresholds(
        min_score=75.0,        # +10 vs default (stricter)
        rsi_oversold=25.0,     # -5 vs default (stricter)
        rsi_overbought=75.0,   # +5 vs default (stricter)
        bb_k=2.2,              # Wider bands (more extreme required)
        size_multiplier=0.5,
    ),
    "london": SessionMRThresholds(
        min_score=65.0,
        rsi_oversold=30.0,
        rsi_overbought=70.0,
        bb_k=2.0,
        size_multiplier=1.0,
    ),
    "newyork": SessionMRThresholds(
        min_score=65.0,
        rsi_oversold=30.0,
        rsi_overbought=70.0,
        bb_k=2.0,
        size_multiplier=1.0,
    ),
    "overlap": SessionMRThresholds(
        min_score=60.0,        # -5 vs default (most permissive)
        rsi_oversold=32.0,     # +2 vs default (relaxed)
        rsi_overbought=68.0,   # -2 vs default (relaxed)
        bb_k=1.9,              # Tighter bands (easier entry)
        size_multiplier=1.0,
    ),
}
```

### Implementation Approach

**Option A: Modify signal generator function signature**
```python
def generate_mean_revert_candidates(
    *,
    closes: NDArray[np.floating[Any]],
    # ... existing params ...
    session: str = "default",  # "asian", "london", "newyork", "overlap"
) -> list[MeanRevertCandidate]:

    # Override thresholds based on session
    if session in SESSION_MR_CONFIG:
        cfg = SESSION_MR_CONFIG[session]
        min_score = cfg.min_score
        rsi_oversold = cfg.rsi_oversold
        rsi_overbought = cfg.rsi_overbought
        bb_k = cfg.bb_k
```

**Option B: Post-filter at strategy level (simpler, less invasive)**
```python
# In GoldScalperStrategy._handle_mean_revert_candidates()
def _filter_by_session(
    self,
    candidates: list[MeanRevertCandidate],
    session: str,
) -> list[MeanRevertCandidate]:
    """Filter MR candidates based on session-specific rules."""
    thresholds = SESSION_MR_CONFIG.get(session, SESSION_MR_CONFIG["london"])

    return [
        c for c in candidates
        if c.score >= thresholds.min_score
        and c.meta["rsi"] <= thresholds.rsi_overbought  # for shorts
        # ... etc
    ]
```

### Expected Impact

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Trade Count | ~5/month | ~4.5/month | -10% |
| Win Rate | 79.3% | ~84% | +5% |
| Asian Losses | ~20% of total | ~5% of total | -75% |
| Max DD | 1.51% | ~1.3% | -0.2% |

**Rationale**: Asian session in XAUUSD has lower liquidity and wider spreads. Stricter entry requirements reduce noise trades.

---

## 2. Threshold Optimization (IMP-05)

### Current Score Formula Analysis

From `mean_revert.py:144-146`:
```python
score = 60.0 + min(20.0, max(0.0, band_excess) * 6.0) + min(15.0, max(0.0, rsi_strength) * 30.0)
score -= min(10.0, max(0.0, atr_p - 40.0) * 0.25)
score = float(max(0.0, min(99.0, score)))
```

**Score Components**:
- Base: 60
- Band excess bonus: 0-20 (how far beyond BB)
- RSI strength bonus: 0-15 (how extreme RSI is)
- ATR penalty: 0-10 (high volatility penalty)

**Score Range**: 50-95 (theoretical), 60-85 (typical)

### Threshold Sensitivity Analysis

| Threshold | Expected Trades/Month | Win Rate Est. | Notes |
|-----------|----------------------|---------------|-------|
| 70 | 0-2 | ~85% | Too restrictive (0 trades in backtest) |
| 68 | 2-4 | ~82% | Very selective |
| 65 | 4-6 | ~79% | Current (29 trades/6mo) |
| 62 | 6-9 | ~76% | Moderate increase |
| 60 | 8-12 | ~73% | Significant increase |
| 58 | 12-18 | ~68% | High volume, lower quality |

### Recommended Configuration

**For 10+ trades/month target**:
- Primary: `threshold = 60` with trend filter active
- Alternative: `threshold = 62` without trend filter

**Expected outcome with threshold 60**:
- +60-80% trade increase (from 5 to 8-10/month)
- -3-5% win rate decrease (from 79% to 74-76%)
- Net expectancy: likely positive if trend filter catches bad trades

### Code Change

```python
# In run_backtest.py or config
config = {
    "execution": {
        "mean_revert_min_score": 60.0,  # Lowered from 65
    }
}
```

Or modify the generator default:
```python
def generate_mean_revert_candidates(
    *,
    # ...
    min_score: float = 60.0,  # Changed from 65.0
) -> list[MeanRevertCandidate]:
```

---

## 3. Trend Filter Design (IMP-06)

### Problem Statement

The $1,239 catastrophic loss (7x avg winner) was likely a counter-trend MR trade:
- MR signal triggered during strong trend
- Price continued trending instead of reverting
- Stop hit at maximum loss

### Proposed Solution: EMA-Based Trend Filter

**Design Spec**:
```python
def _ema(values: NDArray[np.floating[Any]], period: int) -> float:
    """Calculate EMA for the last element."""
    if period <= 0 or values.size < period:
        return float("nan")

    alpha = 2.0 / (period + 1)
    ema = float(values[0])
    for i in range(1, values.size):
        ema = alpha * float(values[i]) + (1 - alpha) * ema
    return ema


def generate_mean_revert_candidates(
    *,
    closes: NDArray[np.floating[Any]],
    # ... existing params ...
    # NEW: Trend filter params
    ema_short_period: int = 50,
    ema_long_period: int = 200,
    use_trend_filter: bool = True,
) -> list[MeanRevertCandidate]:
    """Produce zero or more MeanRevert candidates for the latest closed bar."""

    # Existing min_bars logic
    min_bars = max(int(bb_period) + 2, int(rsi_period) + 2, 50)
    if use_trend_filter:
        min_bars = max(min_bars, int(ema_long_period) + 1)

    if closes.size < min_bars:
        return []

    # ... existing BB/RSI calculations ...

    # NEW: Trend detection
    strong_downtrend = False
    strong_uptrend = False

    if use_trend_filter and closes.size >= ema_long_period:
        ema_short = _ema(c, int(ema_short_period))
        ema_long = _ema(c, int(ema_long_period))

        if np.isfinite(ema_short) and np.isfinite(ema_long):
            # Strong downtrend: EMA50 < EMA200 AND price < EMA200
            strong_downtrend = (ema_short < ema_long) and (last_close < ema_long)

            # Strong uptrend: EMA50 > EMA200 AND price > EMA200
            strong_uptrend = (ema_short > ema_long) and (last_close > ema_long)

    candidates: list[MeanRevertCandidate] = []

    # Long: oversold + price near/below lower band
    # NEW: Block if strong downtrend
    if not strong_downtrend:  # Added condition
        if (atr_p <= float(max_atr_percentile)) and (rsi <= float(rsi_oversold)):
            if last_low <= lower + touch_dist:
                # ... existing long candidate logic ...

    # Short: overbought + price near/above upper band
    # NEW: Block if strong uptrend
    if not strong_uptrend:  # Added condition
        if (atr_p <= float(max_atr_percentile)) and (rsi >= float(rsi_overbought)):
            if last_high >= upper - touch_dist:
                # ... existing short candidate logic ...

    return candidates
```

### Alternative: Hurst-Based Filter (Already Available)

The strategy selector already uses Hurst:
- `is_trending`: Hurst > 0.55 -> STRATEGY_TREND_FOLLOW (not MR)
- `is_reverting`: Hurst < 0.45 -> STRATEGY_MEAN_REVERT allowed

**Enhancement**: Add Hurst check directly in MR generator as defense-in-depth:
```python
def generate_mean_revert_candidates(
    *,
    # ... existing params ...
    hurst: float = 0.5,  # Pass from caller
    max_hurst: float = 0.50,  # Block if trending
) -> list[MeanRevertCandidate]:

    if hurst > max_hurst:
        return []  # Block MR in trending conditions
```

### Recommendation

Use **BOTH** filters:
1. **Hurst filter at selector level** (already exists) - macro regime
2. **EMA filter at signal level** (new) - micro trend protection

### Expected Impact

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Trade Count | ~5/month | ~4/month | -20% |
| Win Rate | 79.3% | ~86% | +7% |
| Max Loss | $1,239 | ~$600 | -50% |
| Max DD | 1.51% | ~1.0% | -0.5% |

**Key Insight**: The $1,239 loss was ~78% of total profits. Preventing even one such loss massively improves risk-adjusted returns.

---

## 4. BB Period Optimization (IMP-08)

### Period Analysis for 5-Minute XAUUSD Bars

| BB Period | Time Coverage | Sensitivity | Expected Trades | Win Rate Est. |
|-----------|---------------|-------------|-----------------|---------------|
| 15 | 75 min | High | +40-50% vs baseline | -3% |
| 20 | 100 min | Medium (current) | Baseline | Baseline |
| 25 | 125 min | Low | -30% vs baseline | +2% |
| 30 | 150 min | Very Low | -50% vs baseline | +4% |

### Statistical Considerations

**Shorter Period (15)**:
- Pro: More responsive to price changes
- Pro: Catches shorter-term reversals
- Con: More false signals (noise)
- Con: Bands are "tighter" relative to price, easier to touch

**Longer Period (25)**:
- Pro: Smoother bands, fewer false signals
- Pro: Higher quality signals when triggered
- Con: Slower to adapt to regime changes
- Con: May miss valid reversion opportunities

### Recommended Configuration

**Keep BB Period = 20** for the following reasons:
1. Already a widely-used standard for BB
2. 100 minutes (~1.67 hours) is appropriate for intraday scalping
3. Combined with threshold 60, already provides sufficient trades
4. Lower period would compound the effect of lower threshold

### Test Matrix for Validation

```python
# Parameter sweep for BB optimization
BB_TEST_MATRIX = [
    {"bb_period": 15, "min_score": 65, "name": "fast_selective"},
    {"bb_period": 15, "min_score": 60, "name": "fast_loose"},
    {"bb_period": 20, "min_score": 65, "name": "standard_selective"},
    {"bb_period": 20, "min_score": 60, "name": "standard_loose"},  # Recommended
    {"bb_period": 25, "min_score": 65, "name": "slow_selective"},
    {"bb_period": 25, "min_score": 60, "name": "slow_loose"},
]
```

### Code Snippet for Testing

```python
# In run_backtest.py
@click.option("--bb-period", type=int, default=20, help="BB period for MR")
def main(bb_period: int, ...):
    config = {
        "signals": {
            "mean_revert": {
                "bb_period": bb_period,
            }
        }
    }
```

---

## Combined Recommendation

### Optimal Configuration for 10+ Trades/Month

```python
MR_OPTIMAL_CONFIG = {
    # Core parameters
    "bb_period": 20,           # Keep standard
    "bb_k": 2.0,               # Keep standard
    "rsi_period": 14,          # Keep standard
    "rsi_oversold": 30.0,      # Keep standard
    "rsi_overbought": 70.0,    # Keep standard

    # Threshold (lowered)
    "min_score": 60.0,         # Lowered from 65 (+60% trades)

    # NEW: Trend filter
    "use_trend_filter": True,
    "ema_short_period": 50,
    "ema_long_period": 200,

    # Session-specific overrides
    "session_overrides": {
        "asian": {"min_score": 75.0},  # Stricter in Asian
        "overlap": {"min_score": 55.0},  # Relaxed in overlap
    },
}
```

### Expected Combined Impact

| Metric | Before | After All Improvements | Change |
|--------|--------|----------------------|--------|
| Trade Count | ~5/month | ~7-9/month | +40-80% |
| Win Rate | 79.3% | ~82-85% | +3-6% |
| Max Loss | $1,239 | ~$500 | -60% |
| Max DD | 1.51% | ~1.0% | -33% |
| Expectancy | $54.73/trade | ~$70/trade | +28% |

### Implementation Priority

1. **P1: Trend Filter** (IMP-06) - Highest impact on risk reduction
2. **P1: Threshold 60** (IMP-05) - Immediate trade increase
3. **P1: Session Guard** (IMP-04) - Quality improvement
4. **P2: BB Period** (IMP-08) - Optional, test after above

---

## Validation Requirements

Before deploying any changes:

1. **Extended Backtest**: 2+ years (2023-2024) with new configuration
2. **Sample Size**: Target 100+ trades minimum
3. **Walk-Forward Analysis**: Verify WFE >= 0.60
4. **Monte Carlo**: Verify MC95DD <= 4.0%
5. **Overfitting Check**: DSR > 0, PBO < 25%

---

## Next Steps

1. **FORGE**: Implement trend filter in `mean_revert.py`
2. **FORGE**: Add session parameter to signal generator
3. **ORACLE1**: Run extended 2-year backtest with new config
4. **SENTINEL**: Validate Apex compliance with new parameters

---

## Files Referenced

- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/mean_revert.py` - MR signal generator
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py` - Session/regime selection
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/09-strategy-activation/12-PHASE-00C-MR-EVALUATION-SUMMARY.md` - Baseline results

---

*End of ORACLE3 Signal Quality Analysis*
