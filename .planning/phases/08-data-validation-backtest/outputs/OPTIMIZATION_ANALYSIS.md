# Grid Search Optimization Analysis

## Date: 2024-12-17

## Problem Statement

Initial backtests showed:
- 4 trades in October 2024 with DEBUG config (allow_overnight=true, cutoff=23:59)
- 42 trades in Sep-Oct 2024 with same DEBUG config
- **0 trades** when using Apex-compliant config (allow_overnight=false, cutoff=16:55 ET)

## Root Cause Analysis

### 1. Session Filter Too Restrictive

The `SessionFilter` defines trading windows in GMT:
- Asian: 00:00-07:00 GMT → **BLOCKED by default**
- London: 07:00-12:00 GMT (03:00-08:00 ET) → ALLOWED
- Overlap: 12:00-15:00 GMT (08:00-11:00 ET) → ALLOWED (PRIME)
- NY: 15:00-17:00 GMT (11:00-01:00 PM ET) → ALLOWED
- Late NY: 17:00-21:00 GMT (01:00-05:00 PM ET) → **BLOCKED by default**

**Problem**: Most US afternoon trading (1 PM - 5 PM ET) falls in "Late NY" session which is blocked.

**Solution**: Disable session filter (`use_session_filter: false`)

### 2. Confluence Threshold Too High

Confluence scores observed in backtest logs:
- Most scores: 15-50
- Peak scores: 47-50
- Original threshold: 70

With threshold at 70, almost no signals passed. Even at 50, only 2 signals in a month.

### 3. Time Cutoff Working Correctly

Apex cutoff at 16:55 ET is properly enforced:
- Trades after cutoff are blocked
- Existing positions are force-closed at cutoff
- Daily reset enables trading next day

## Test Results

| Threshold | Session Filter | Trades (Oct) | Win Rate | Net PnL |
|-----------|---------------|--------------|----------|---------|
| 70 | ON | 0 | N/A | $0.00 |
| 50 | OFF | 1 | 100% | +$0.58 |
| 40 | OFF | 3 | 0% | -$16.24 |

## Findings

### Positive
1. Apex time cutoff works correctly (force-closes at 16:55 ET)
2. Daily reset properly re-enables trading
3. Risk-based position sizing working (0.02-0.35 lots)
4. No overnight positions with proper config

### Negative
1. Win rate drops to 0% at lower thresholds
2. All 3 trades at threshold=40 were stopped out
3. Commission drag significant ($5/round-trip)
4. Confluence scoring may need fundamental review

## Recommended Configuration

```yaml
confluence:
  min_score_to_trade: 40
  execution_threshold: 40

execution:
  use_session_filter: false
  use_selector: false
  allow_overnight: false

time:
  cutoff_et: '16:55'
```

## Next Steps

1. **Strategy Review**: The confluence scoring system needs deeper review - signals at 40-50 are not high-quality enough
2. **Extended Backtest**: Run 3-6 month backtest to get 50+ trades for statistical validity
3. **Parameter Tuning**:
   - Test thresholds 30, 35, 40, 45
   - Review footprint/order block scoring weights
4. **Alternative Approach**: Consider if the strategy fundamentals need adjustment, not just thresholds

## Conclusion

The optimization revealed that the original strategy is too conservative with:
- Session filters that block most US afternoon trading
- Confluence thresholds that rarely trigger

With relaxed settings, we get more trades but poor win rate. This suggests the underlying signal quality at lower thresholds is poor - the strategy may need fundamental improvements beyond parameter tuning.

**Status**: CONDITIONAL NO-GO - Strategy generates signals with Apex compliance but quality is insufficient.
