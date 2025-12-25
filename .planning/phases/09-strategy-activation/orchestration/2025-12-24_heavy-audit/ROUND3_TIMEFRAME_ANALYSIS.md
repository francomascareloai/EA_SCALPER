# ROUND 3: Timeframe Analysis Results

**Date:** 2025-12-24
**Objective:** Test M5, M15, H1 entry timeframes to identify optimal LTF interval

---

## Technical Constraint Discovered

**NautilusTrader BarSpecification Limitation:**
- H1 (60-min) and M30 testing BLOCKED
- Error: `ValueError: Invalid step in bar_type.spec.step: 60 for aggregation=12`
- Root cause: MINUTE aggregation (aggregation=12) doesn't allow step=60
- Fix required: Use HOUR aggregation unit for 60+ minute bars

**Testable Timeframes:** M5, M15, M20 (code change required for H1)

---

## MeanRevert Signal - Timeframe Comparison

### April 2024 (Best Month from Round 2)
| Timeframe | Trades | Win Rate | PnL | Avg/Trade | Verdict |
|-----------|--------|----------|-----|-----------|---------|
| M5 | 11 | 36.4% | +$1,061 | +$96.45 | **POSITIVE** |
| M15 | 9 | **44.4%** | -$45 | -$5.04 | Near breakeven |

**Finding:** M15 has higher win rate (44.4% vs 36.4%) but lower PnL. Fewer signals + smaller edge.

### Q1 2024 (Jan-Mar)
| Timeframe | Trades | Win Rate | PnL | Avg/Trade | Verdict |
|-----------|--------|----------|-----|-----------|---------|
| M15 | 20 | 25.0% | -$1,477 | -$73.86 | Negative |

### H1 2024 (Jan-Jun)
| Timeframe | Trades | Win Rate | PnL | Avg/Trade | Verdict |
|-----------|--------|----------|-----|-----------|---------|
| M5 | 33 | 21.2% | -$1,290 | -$39.11 | Negative |
| M15 | 22 | 22.7% | -$3,929 | -$178.58 | **WORSE** |

**Finding:** M15 has 33% fewer trades but 3x worse PnL. Individual losses are much larger.

### Jul-Oct 2024
| Timeframe | Trades | Win Rate | PnL | Avg/Trade | Verdict |
|-----------|--------|----------|-----|-----------|---------|
| M15 | 7 | **57.1%** | -$2,894 | -$413.44 | Negative |

**Finding:** Highest win rate (57.1%) but worst avg/trade (-$413). Few trades, huge losers.

---

## TrendFollow Signal - Timeframe Comparison

### April 2024
| Timeframe | Trades | Win Rate | PnL | Avg/Trade |
|-----------|--------|----------|-----|-----------|
| M5 | ~20 | 0-15% | Negative | N/A |
| M15 | **0** | N/A | N/A | N/A |

### H1 2024 (Jan-Jun)
| Timeframe | Trades | Win Rate | PnL | Avg/Trade |
|-----------|--------|----------|-----|-----------|
| M15 | **0** | N/A | N/A | N/A |

**VERDICT: TrendFollow generates ZERO signals on M15 timeframe**

Root cause likely: EMA separation threshold (`min_sep_ticks=20`) never reached on M15 bars, or pullback patterns don't form within the lookback window.

---

## Key Discoveries

### 1. M15 INCREASES WIN RATE BUT DECREASES PNL
- Higher timeframe = less noise = better pattern recognition
- BUT: Fewer trades + individual losses are larger
- Net effect: WORSE dollar performance

### 2. TRENDFOLLOW IS TIMEFRAME-INCOMPATIBLE
- TrendFollow logic assumes M5 granularity
- M15 bars don't trigger the EMA separation/pullback conditions
- Would require parameter recalibration for M15

### 3. LOSS MAGNITUDE SCALES WITH TIMEFRAME
| Metric | M5 | M15 |
|--------|-----|-----|
| Avg Winner | ~$100-200 | ~$200-400 |
| Avg Loser | ~$150-300 | ~$500-800 |
| Loss/Win Ratio | ~1.5x | ~2.0x |

M15 stops are likely too wide relative to the win targets.

### 4. H1/H4 TESTING BLOCKED
- Would need code change to use HOUR aggregation
- May reveal different dynamics
- DEFERRED to code fix task

---

## Recommendations

1. **KEEP M5 for MeanRevert** - Better dollar PnL despite lower win rate
2. **ABORT TrendFollow on higher TFs** - Generates no signals
3. **INVESTIGATE stop loss sizing** - M15 losses are disproportionately large
4. **FIX BarSpecification for H1** - Enable proper H1/H4 testing later

---

## Timeframe Decision Matrix

| Signal Type | M5 | M15 | H1 |
|-------------|-----|-----|-----|
| MeanRevert | **USE** | DO NOT USE | BLOCKED |
| TrendFollow | TOXIC | NO SIGNALS | BLOCKED |

**Final Verdict:** M5 remains optimal LTF despite noise. Higher timeframes reduce signal frequency without improving dollar expectancy.

---

*ROUND 3 Complete | 2025-12-24*
