# Phase 02 Round 1 Agent B Findings

**AGENT**: FORGE-NAUTILUS
**VERSION**: 1.1
**CLAUDE_MD_VERSION**: 3.10.14
**STATUS**: COMPLETE

---

## Executive Summary

This analysis covers temporal integrity and SMC correctness for two indicators:
- **OrderBlockDetector** (`order_block_detector.py`, 627 lines)
- **FVGDetector** (`fvg_detector.py`, 566 lines)

**CRITICAL FINDING**: Both indicators exhibit **LOOK-AHEAD BIAS** via forward-looking displacement calculations that use future bar data to confirm pattern validity at the time of pattern detection.

---

## ARGUS Dangerous Pattern Checks (Step 0)

### Pattern 1: Forward-looking shift(-N)
**Result**: NO MATCHES - CLEAN

### Pattern 2: Forward-looking rolling + shift
**Result**: NO MATCHES - CLEAN

### Pattern 3: Full-sample statistics (.mean(), .std(), etc.)
**Order Block Detector**:
- Line 112: `avg_volume = float(np.mean(volumes))` - Uses full sample. **MEDIUM** - Review context.
- Line 409: `np.mean(bodies)` - Uses historical slice `[start:end]` where `end = index`. **CLEAN** - backward-looking only.

**FVG Detector**:
- Line 107: `avg_volume = float(np.mean(volumes))` - Uses full sample. **MEDIUM** - Review context.

### Pattern 4: Close-based decisions
**Order Block Detector**:
- Lines 117, 127: Pattern function calls - reviewed below
- Lines 183, 222: Bounds checks on closes array length
- Lines 194, 233: **CRITICAL** - Forward-looking close access `closes[j]` where `j > index`

**FVG Detector**:
- No direct close-based if statements found - CLEAN

### Pattern 5: Nautilus timestamp configuration
**Result**: NO MATCHES - Neither indicator references Nautilus-specific timestamp configuration. These are pure computation modules that receive arrays, not Actors.

---

## Temporal Verification Protocol

### Order Block Detector

#### Step 1: Data Access Points Identified

| Line | Access Pattern | Purpose |
|------|----------------|---------|
| 106 | `closes[-1]` | Default current_price if not provided |
| 115 | `range(5, n - 5)` | Main scan loop |
| 146-148 | `highs[-1]`, `lows[-1]` | Fallback synthetic OB creation |
| 155 | `highs[-1] - lows[-1]` | Fallback displacement |
| 187-189 | `closes[index]`, `opens[index]` | Body calculation |
| 193-196 | `closes[j]`, `highs[index]` where `j = index+1..index+5` | **FUTURE DATA ACCESS** |
| 202-203 | `highs[index]`, `lows[index]` | Range calculation |
| 207-209 | `closes[start:end]`, `opens[start:end]` where `end = index` | Historical body average |
| 232-235 | `closes[j]`, `lows[index]` where `j = index+1..index+5` | **FUTURE DATA ACCESS** |
| 373-380 | `closes[i]` where `i = index+1..index+5` | **FUTURE DATA ACCESS** |

**Total**: 11 significant access points identified
**Violations Found**: 3 (all forward-looking displacement checks)

#### Step 2: Access Verification

| Access Pattern | Valid? | Explanation |
|----------------|--------|-------------|
| `closes[-1]` at line 106 | CONDITIONAL | Only used as default if current_price not provided. If detect() is called mid-bar, this could be forming bar close. |
| `closes[index]` at pattern checks | YES | Index is in scan range `[5, n-5)`, always completed bars |
| `closes[j]` where `j > index` at lines 193-196, 232-235, 373-380 | **NO - VIOLATION** | Uses future bars to confirm OB validity |
| `highs[-1]`, `lows[-1]` at lines 146-148 | CONDITIONAL | Fallback logic - depends on when detect() is called |

#### Step 3: Timestamp Trace (3 Random Examples)

**Timestamp 1**: Bar index 10 in a 50-bar array
- At bar 10, OB pattern is evaluated
- Code checks `closes[11..15]` to verify displacement (lines 193-196)
- At bar 10 timestamp, bars 11-15 DO NOT EXIST YET
- **VERDICT**: LOOK-AHEAD BIAS

**Timestamp 2**: Bar index 25 in a 50-bar array
- At bar 25, bearish OB pattern check
- Code accesses `closes[26..30]` for displacement confirmation
- This is future data
- **VERDICT**: LOOK-AHEAD BIAS

**Timestamp 3**: Bar index 44 in a 50-bar array
- At bar 44, scan loop terminates (n-5 = 45)
- Edge case handled correctly by loop bounds
- **VERDICT**: CLEAN (not evaluated due to loop bounds)

#### Step 4: Findings Summary - Order Block Detector

```
## Temporal Integrity: OrderBlockDetector
- Data access points: 11 identified
- Violations found: 3 (CRITICAL)
- Details:
  - Lines 193-196: Forward displacement check in _is_bullish_ob_pattern() - VIOLATION
  - Lines 232-235: Forward displacement check in _is_bearish_ob_pattern() - VIOLATION
  - Lines 373-380: Forward displacement calculation in _calculate_displacement() - VIOLATION
```

---

### FVG Detector

#### Step 1: Data Access Points Identified

| Line | Access Pattern | Purpose |
|------|----------------|---------|
| 101 | `closes[-1]` | Default current_price if not provided |
| 110 | `range(1, max(2, n - 1))` | Main scan loop |
| 132 | `timestamps[-1]` | Current timestamp for state update |
| 139 | Index 1 access | Fallback FVG creation |
| 162-163 | `highs[index - 1]`, `lows[index + 1]` | **FUTURE DATA ACCESS** for bullish FVG |
| 190-191 | `lows[index - 1]`, `highs[index + 1]` | **FUTURE DATA ACCESS** for bearish FVG |
| 221-222 | `highs[index - 1]`, `lows[index + 1]` | **FUTURE DATA ACCESS** in creation |
| 278-279 | `lows[index - 1]`, `highs[index + 1]` | **FUTURE DATA ACCESS** in creation |
| 340-344 | `closes[i]` where `i = index+1..index+5` | **FUTURE DATA ACCESS** |

**Total**: 9 significant access points identified
**Violations Found**: 5 (forward-looking FVG detection and displacement)

#### Step 2: Access Verification

| Access Pattern | Valid? | Explanation |
|----------------|--------|-------------|
| `closes[-1]` at line 101 | CONDITIONAL | Same as OB detector |
| `highs[index - 1]` | YES | Past bar, always completed |
| `lows[index + 1]` at lines 163, 222 | **NO - VIOLATION** | Future bar access |
| `highs[index + 1]` at lines 191, 279 | **NO - VIOLATION** | Future bar access |
| `closes[i]` where `i > index` at lines 340-344 | **NO - VIOLATION** | Future bar displacement |

#### Step 3: Timestamp Trace (3 Random Examples)

**Timestamp 1**: Bar index 5 in a 30-bar array
- At bar 5 (middle candle of potential FVG), code checks `lows[6]`
- At bar 5 timestamp, bar 6 DOES NOT EXIST YET
- **VERDICT**: LOOK-AHEAD BIAS

**Timestamp 2**: Bar index 15 in a 30-bar array
- Bearish FVG check at index 15
- Code accesses `highs[16]` for gap boundary
- This is future data
- **VERDICT**: LOOK-AHEAD BIAS

**Timestamp 3**: Bar index 28 in a 30-bar array
- Loop bound is `max(2, n - 1) = 29`
- At index 28, code would access index 29 (lows[29] or highs[29])
- Bounds check at line 158 catches this: `index >= len(highs) - 1` returns False
- **VERDICT**: CLEAN (bounds check prevents access but pattern is fundamentally flawed)

#### Step 4: Findings Summary - FVG Detector

```
## Temporal Integrity: FVGDetector
- Data access points: 9 identified
- Violations found: 5 (CRITICAL)
- Details:
  - Lines 162-163: Future bar access in _is_bullish_fvg_pattern() - VIOLATION
  - Lines 190-191: Future bar access in _is_bearish_fvg_pattern() - VIOLATION
  - Lines 221-222: Future bar access in _create_bullish_fvg() - VIOLATION
  - Lines 278-279: Future bar access in _create_bearish_fvg() - VIOLATION
  - Lines 340-344: Forward displacement calculation - VIOLATION
```

---

## Specific Questions Answered

### Order Block Detector

**1. How is "imbalance" measured?**
- Imbalance is measured by displacement: the price movement AFTER the OB candle
- Bullish OB: `closes[j] - highs[index]` where `j > index` (lines 193-196)
- Bearish OB: `lows[index] - closes[j]` where `j > index` (lines 232-235)
- Requires `displacement >= displacement_threshold` (default 20 pips converted to price)

**2. What defines OB validity?**
- Must be opposite-colored candle (bearish for bullish OB, bullish for bearish OB)
- Body must be >= 50% of total range (line 203)
- Body must be >= 1.5x average body size of previous 10 bars (lines 207-209)
- Displacement after OB must exceed threshold
- Strength >= 60.0 (line 354)
- Probability score >= 70.0 (line 356)
- Quality >= MEDIUM (line 358)

**3. How long does OB stay valid?**
- No explicit expiration mechanism
- OB becomes MITIGATED when price closes beyond its zone (lines 512-529)
- OB becomes TESTED when price enters the zone (lines 516-520, 526-530)
- `is_fresh` flag is set to False on any touch

**4. Mitigation detection correct?**
- Partially correct: checks if `current_price < ob.low_price` (bullish) or `current_price > ob.high_price` (bearish)
- Issue: Uses `current_price` parameter which defaults to `closes[-1]` - may be forming bar
- Does not track if mitigation was a "close below" vs just a wick

**5. Breaker block transformation logic?**
- Breaker blocks are mentioned in docstring (line 8) but **NOT IMPLEMENTED**
- No code transforms mitigated OB into breaker block
- `OrderBlockType` enum has `OB_BREAKER_BULLISH` and `OB_BREAKER_BEARISH` but unused

### FVG Detector

**1. Gap threshold configuration?**
- `min_gap_size`: default 1.0 pip (converted to price)
- `max_gap_size`: default 40.0 pips (converted to price)
- Configured in constructor (lines 36-37)

**2. Partial fill handling?**
- Yes, implemented via `fill_percentage` tracking (lines 442-449)
- State transitions: OPEN -> PARTIAL (>= 50% filled) -> FILLED (>= 100% filled)
- Fill calculation differs by direction (bullish: from lower, bearish: from upper)

**3. Expiration mechanism?**
- Yes, `expiry_hours` parameter (default 24 hours)
- State becomes EXPIRED if open and hours elapsed > expiry_hours (lines 458-461)
- Time decay factor calculated: `1.0 - (hours_elapsed / expiry_hours)`, min 0.1 (line 464)

**4. IFVG (Inverted FVG) detection?**
- **NOT IMPLEMENTED**
- Standard FVGs only: 3-candle imbalance patterns
- No inversion or consequent encroachment detection

---

## NautilusTrader-Specific Checks

| Check | Status | Notes |
|-------|--------|-------|
| `Bar.is_complete` usage | N/A | These are pure Python modules, not Actors |
| `on_bar()` handler | N/A | No Nautilus lifecycle methods |
| `on_quote_tick()` handler | N/A | No Nautilus lifecycle methods |
| Actor lifecycle | N/A | Not Actors |
| Historical warmup | N/A | Not Actors |

**Note**: These indicators receive numpy arrays from the caller. The temporal integrity violation occurs because the **design assumes all data is historical** when in practice the caller may pass arrays that include forming bars.

---

## CRITIC Checklist

### Order Block Detector

| Check | Status | Notes |
|-------|--------|-------|
| Uses only completed bars | **FAIL** | Forward-looking displacement |
| Temporal Verification Protocol applied | YES | 3 violations found |
| Bar indexing documented | YES | Scan range [5, n-5) |
| Edge cases handled | PARTIAL | Array bounds checked, but gap handling missing |
| Performance < 0.5ms per call | LIKELY | O(n) scan, no heavy computation |
| State reset mechanism | YES | `_order_blocks = []` at start of detect() |
| Dependencies clear | YES | Only numpy, internal types |
| Unit tests exist AND pass | UNKNOWN | Not verified in this analysis |

### FVG Detector

| Check | Status | Notes |
|-------|--------|-------|
| Uses only completed bars | **FAIL** | Inherently requires future bar (candle 3) |
| Temporal Verification Protocol applied | YES | 5 violations found |
| Bar indexing documented | YES | Scan range [1, n-1) |
| Edge cases handled | PARTIAL | Bounds checked, but first bar edge case unclear |
| Performance < 0.5ms per call | LIKELY | O(n) scan, no heavy computation |
| State reset mechanism | YES | `_fvgs = []` at start of detect() |
| Dependencies clear | YES | Only numpy, internal types |
| Unit tests exist AND pass | UNKNOWN | Not verified in this analysis |

---

## CRITIC Self-Review (12+ Thoughts)

### Thought 1: INVERSION - What if the look-ahead is intentional?
The FVG pattern fundamentally requires 3 candles. The "middle" candle at time T can only be confirmed as an FVG when we see candle T+1. This is not a bug but a fundamental SMC concept. However, the **signal should be delayed by 1 bar** in the strategy layer.

### Thought 2: PRE-MORTEM - How would this fail in production?
In live trading, calling `detect()` with current bar arrays would identify FVGs that haven't actually formed yet (candle 3 is incomplete). This leads to entering trades before the pattern is confirmed.

### Thought 3: STRESS TEST - High volatility scenario
If price gaps significantly, the displacement calculations would show artificially high values. The `max_gap_size` constraint (40 pips) provides some protection for FVG but OB has no upper bound on displacement.

### Thought 4: REGIME SHIFT - Low liquidity period
Both indicators use volume ratios. If volume drops significantly (holiday, Asian session for XAUUSD), `avg_volume` calculated over full sample would be inflated, causing volume_spike checks to fail consistently.

### Thought 5: APEX TRAP - How does this affect HWM?
Premature entry from look-ahead bias could cause entries at worse prices. If the trade initially goes profit then reverses, HWM is raised prematurely, tightening the trailing DD floor.

### Thought 6: EDGE CASE - First bars after warmup
OB detector requires 50 bars minimum (`lookback_bars`). FVG requires only 3. If called with exactly minimum bars, the synthetic fallback OB (lines 143-159) uses `highs[-1]`, `lows[-1]` which may be forming.

### Thought 7: ASSUMPTION AUDIT - "All arrays contain completed bars"
This is the core assumption that breaks. The indicators assume they receive only completed bar data, but nothing in the API enforces this.

### Thought 8: Pattern correctness vs temporal correctness
ICT methodology defines FVG as the gap between candle 1 high and candle 3 low. The implementation is SMC-correct but temporally incorrect for live trading.

### Thought 9: Displacement validation timing
The displacement check (5 bars forward) means an OB at bar 10 is only validated at bar 15. In backtesting this works; in live trading this is impossible.

### Thought 10: Mitigation state update timing
`_update_ob_states()` uses `current_price` which defaults to `closes[-1]`. If this is a forming bar, mitigation detection is premature.

### Thought 11: Full-sample volume average concern
Using `np.mean(volumes)` over the entire array biases the average toward recent volumes. Rolling mean would be more appropriate for detecting spikes relative to local conditions.

### Thought 12: Breaker block missing implementation
The docstring mentions breaker blocks but they're not implemented. This is a documentation vs code mismatch.

### Thought 13: IFVG not implemented
Inverted FVGs (price moves through FVG and back) are a key ICT concept for identifying potential reversals. Missing implementation.

### Thought 14: Bounds check in FVG prevents access but logic is still flawed
Line 158 `index >= len(highs) - 1` prevents index+1 access at array end, but the fundamental design of accessing [index+1] is the issue.

---

## Assumptions Challenged

1. **Assumption**: "detect() is only called with completed bar arrays"
   - **Challenge**: Nothing in the API prevents calling with forming bars
   - **Mitigation**: Add docstring warning; ideally add `is_complete` validation

2. **Assumption**: "Full-sample volume average is representative"
   - **Challenge**: Older bars may have different volume profiles (regime change)
   - **Mitigation**: Use rolling 20-bar average instead

3. **Assumption**: "Displacement confirms pattern validity"
   - **Challenge**: This requires seeing future bars - fundamentally impossible in live trading
   - **Mitigation**: Delay signal by displacement lookback period (5 bars)

---

## Severity Summary

| Severity | Count | Details |
|----------|-------|---------|
| CRITICAL | 2 | Look-ahead bias in OB detector, Look-ahead bias in FVG detector |
| HIGH | 2 | Breaker block not implemented (doc mismatch), IFVG not implemented |
| MEDIUM | 2 | Full-sample volume average, Synthetic fallback OB uses last bar |
| LOW | 1 | No explicit warmup period validation |

---

## Recommended Fixes

### CRITICAL: Look-Ahead Bias Fix

**Order Block Detector**:
```python
# Current (WRONG):
for j in range(index + 1, min(index + 6, len(closes))):
    if closes[j] > highs[index]:

# Fixed approach 1: Delay signal by 5 bars
# Only detect OBs at index where index + 5 < current_bar_index
# This means OB is confirmed 5 bars after formation

# Fixed approach 2: Detect pattern without displacement confirmation
# Add displacement confirmation as post-filter in strategy layer
```

**FVG Detector**:
```python
# Current (WRONG):
low3 = lows[index + 1]  # Future bar!

# Fixed approach: Redefine index semantics
# index points to the THIRD candle (confirmation candle)
# So index-2 is candle 1, index-1 is middle, index is candle 3
# All three are completed when we're at index
```

### Strategy Layer Integration

The correct approach is to:
1. Have indicators identify potential zones
2. Delay acting on zones by the confirmation period
3. In `on_bar()`, only use zones that were confirmed N bars ago

---

## Files Analyzed

| File | Path | Lines |
|------|------|-------|
| OrderBlockDetector | `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/order_block_detector.py` | 627 |
| FVGDetector | `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/fvg_detector.py` | 566 |

---

## Verdict

**STATUS**: BLOCKED

Both indicators contain CRITICAL look-ahead bias that must be fixed before production use. The fundamental design of using future bars for confirmation is incompatible with live trading.

---

*Word Count: ~2,400 words*
