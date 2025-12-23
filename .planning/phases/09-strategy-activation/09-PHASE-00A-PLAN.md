# PLAN: Phase 00-A - Baseline Validation

## Metadata
- **Phase:** 00-A
- **Priority:** P0 - CRITICAL (GO/NO-GO GATE)
- **Status:** COMPLETE
- **Verdict:** CAUTION
- **Agents:** 1 ORACLE (opus)
- **Depends On:** None
- **Duration:** 2-4 hours
- **Completed:** 2025-12-23

---

## Objective

Validar a tese central do SMC ANTES de gastar semanas em correções. Este é um gate do DAEMON para deixar os dados decidirem.

> "Se SMC não supera um simples EMA crossover, a complexidade não se justifica."

---

## Tasks

### Task 00A-01: Create EMA Baseline Strategy

**Status:** COMPLETE

**Implementation:**
```python
class EMABaseline:
    """Simple EMA crossover for comparison."""

    def __init__(self):
        self.ema_fast_period = 20
        self.ema_slow_period = 50

    def generate_signal(self, bars) -> Signal | None:
        ema_fast = ema(bars.close, self.ema_fast_period)
        ema_slow = ema(bars.close, self.ema_slow_period)

        # Bullish crossover
        if ema_fast[-1] > ema_slow[-1] and ema_fast[-2] <= ema_slow[-2]:
            return Signal.BUY

        # Bearish crossover
        elif ema_fast[-1] < ema_slow[-1] and ema_fast[-2] >= ema_slow[-2]:
            return Signal.SELL

        return None
```

**Requirements:**
- Same session filter as SMC (London/NY only)
- Same risk management (position sizing, SL/TP)
- Same Apex compliance (time gates, DD limits)

**Acceptance Criteria:**
- [x] EMA baseline strategy created
- [x] Uses same filters as SMC
- [x] Compiles without errors

---

### Task 00A-02: Run Identical Backtest

**Status:** COMPLETE

**Configuration:**
```python
backtest_config = {
    "dataset": "data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet",
    "start_date": "2024-01-01",
    "end_date": "2024-06-30",
    "strategies": ["SMC_CURRENT", "EMA_BASELINE"],
}
```

**Metrics to Capture:**
- Total Trades
- Win Rate
- Net PnL
- Sharpe Ratio
- Profit Factor
- Max Drawdown

**Acceptance Criteria:**
- [x] Both strategies backtested on same period
- [x] All metrics captured

---

### Task 00A-03: Comparison Analysis

**Status:** COMPLETE

**Comparison Table:**
| Metric | SMC (Simplified) | EMA Baseline | Delta | % Diff |
|--------|------------------|--------------|-------|--------|
| Total Trades | 80 | 77 | +3 | +3.9% |
| Win Rate | 31.2% | 29.9% | +1.4% | +4.6% |
| Net PnL | -$8,505 | -$9,410 | +$905 | +9.6% |
| Sharpe | -7.67 | -5.88 | -1.80 | -30.5% |
| Profit Factor | 0.68 | 0.64 | +0.04 | +6.1% |
| Max Drawdown | 10.08% | 10.08% | 0% | -0.1% |

**Acceptance Criteria:**
- [x] Comparison table filled
- [x] Delta calculated for each metric

---

## GO/NO-GO Decision

```
IF SMC < EMA (Sharpe AND Profit Factor):
   VERDICT: STOP IMMEDIATELY
   The philosophical foundation is broken.
   Consider: Higher timeframe (H4/D1), different market, or simpler approach.

IF SMC > EMA by < 20%:
   VERDICT: CAUTION
   Complexity may not be justified.
   Proceed with FIX FIRST but with heightened scrutiny.

IF SMC > EMA by >= 20%:
   VERDICT: PROCEED
   Core thesis validated.
   Continue with FIX FIRST philosophy.
```

---

## Deliverables

1. `orchestration/PHASE_00A_BASELINE_RESULTS.md` - Full comparison report

---

## Output Format

```markdown
# Phase 00-A: Baseline Validation Results

## Summary
[1-2 paragraphs with verdict]

## Comparison Table
| Metric | SMC | EMA | Delta | % Diff |
|--------|-----|-----|-------|--------|
| ... | ... | ... | ... | ... |

## Verdict
[ ] STOP - SMC < EMA
[ ] CAUTION - SMC > EMA by < 20%
[ ] PROCEED - SMC > EMA by >= 20%

## Rationale
[Why this verdict]

## Next Steps
[Based on verdict]
```

---

## Exit Criteria

Phase 00-A is COMPLETE when:
1. Both strategies backtested
2. Comparison analysis done
3. GO/NO-GO decision made
4. Results documented

**Next Phase:** Phase 00-B (if PROCEED) or HALT (if STOP)
