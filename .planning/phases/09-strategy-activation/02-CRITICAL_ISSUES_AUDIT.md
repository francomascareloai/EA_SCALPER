# CRITICAL ISSUES AUDIT - Phase 09 Pre-Activation

## Changelog
- v1.0 (2025-12-23): Initial audit based on Phase 08 findings + MTF deep analysis

## Purpose
Document ALL critical issues that must be resolved before strategy activation.
This complements `01-ROADMAP.md` with detailed technical audits.

---

## Executive Summary

**Status**: NO-GO for activation
**Critical Blockers**: 34 CRITICAL issues remain open
**High Priority**: 48 HIGH issues
**Test Coverage**: 52.68% line / 28.66% branch (below minimums)

**Key Findings**:
1. MTF Manager duplication (tests vs production mismatch)
2. Semantic collision in OB/FVG storage (LTF overwrites MTF data)
3. Temporal integrity partially fixed (WP3) but validation scripts still have leakage
4. Execution safety improved (WP0-WP5) but gaps remain
5. Coverage gaps hide potential bugs

---

## Category 1: MTF Manager Duplication (P04-A-016 + P08-021)

### Problem Description
Two completely different MTF Manager implementations exist:

| Implementation | Location | Used By | Features |
|---------------|----------|---------|----------|
| **Legacy** | `src/indicators/mtf_manager.py` (672 lines) | `tests/test_indicators/` | EMA-based (20/50), RSI, ATR, standalone |
| **Production** | `src/signals/mtf_manager.py` (417 lines) | `gold_scalper_strategy.py` | SMC-based, StructureAnalyzer + RegimeDetector |

### Impact
- **Tests validate LEGACY code** (not used in production)
- **Production code UNTESTED** (signals/mtf_manager has no direct tests)
- Different algorithms, different outputs → no confidence in test suite

### Root Cause
- `indicators/mtf_manager.py` was created during MQL5 migration (EMA-based)
- `signals/mtf_manager.py` was created later for SMC integration
- Old tests never migrated to new implementation

### Fix Plan

**Phase A: Consolidation** (3-4 hours)
1. Add deprecation warning to `src/indicators/mtf_manager.py`
2. Create `tests/test_signals/test_mtf_manager.py` with comprehensive tests:
   - Bullish/bearish/ranging alignment detection
   - Premium/discount zone logic
   - BOS/CHoCH integration
   - Regime blocking (random walk)
3. Validate production strategy still works
4. Archive `src/indicators/mtf_manager.py` to `_archive/`

**Phase B: Validation** (2 hours)
1. Run full test suite (expect deprecation warnings)
2. Run backtest before/after (compare metrics)
3. Verify coverage increased for `signals/mtf_manager.py`

**Dependencies**: None (can start immediately)
**Blocking**: Phase 02 SMC audit should wait for this

**Agent**: 1 FORGE (opus) for implementation + tests

---

## Category 2: Semantic Collision - OB/FVG Storage (P08-003)

### Problem Description
Variables `_mtf_order_blocks` and `_mtf_fvgs` are ambiguous and get overwritten by different timeframe detections.

**Code Evidence**:
```python
# Line 364-365: Declaration
self._mtf_order_blocks: list[OrderBlock] = []  # Name says "MTF" but...
self._mtf_fvgs: list[FairValueGap] = []

# Line 1042-1044: First detection (timeframe unclear)
self._mtf_order_blocks = self._ob_detector.detect(opens, highs, lows, closes, volumes)

# Line 1925: OVERWRITES with LTF data!
opens = np.array([b.open.as_double() for b in self._ltf_bars[-200:]])  # ← LTF!
self._mtf_order_blocks = self._ob_detector.detect(opens, highs, lows, closes, volumes)

# Line 1963-1964: Scorer receives LTF data thinking it's MTF!
result = self._confluence_scorer.calculate_score(
    order_blocks=self._mtf_order_blocks,  # ← Actually contains LTF data!
    fvgs=self._mtf_fvgs,
    ...
)
```

### Impact
- **Confluence scorer receives WRONG timeframe data**
- Variable named "MTF" contains "LTF" data
- Inconsistent signals (scorer thinks it's scoring MTF structural zones but it's LTF entry zones)
- **This may be causing poor backtest results!**

### SMC Philosophy Violation
According to SMC:
- **H1 (HTF)**: Direction and bias
- **M15 (MTF)**: Structure and **ORDER BLOCKS** ← Should use this!
- **M5 (LTF)**: Entry timing and execution

**Current bug**: Passing M5 (LTF) Order Blocks to scorer when it should be M15 (MTF).

### Fix Plan

**Phase A: Rename Variables** (2 hours)
```python
# BEFORE (ambiguous)
self._mtf_order_blocks: list[OrderBlock] = []
self._mtf_fvgs: list[FairValueGap] = []

# AFTER (explicit)
self._htf_order_blocks: list[OrderBlock] = []   # H1
self._mtf_order_blocks: list[OrderBlock] = []   # M15
self._ltf_order_blocks: list[OrderBlock] = []   # M5

self._htf_fvgs: list[FairValueGap] = []
self._mtf_fvgs: list[FairValueGap] = []
self._ltf_fvgs: list[FairValueGap] = []
```

**Phase B: Fix Detection Logic** (2 hours)
```python
# Detect OBs on M15 (MTF) for structural zones
if self._mtf_bars and len(self._mtf_bars) >= 200:
    mtf_data = self._prepare_data_from_bars(self._mtf_bars[-200:])
    self._mtf_order_blocks = self._ob_detector.detect(...)
    self._mtf_fvgs = self._fvg_detector.detect(...)

# Detect OBs on M5 (LTF) for precise entry (if needed)
if self._ltf_bars and len(self._ltf_bars) >= 200:
    ltf_data = self._prepare_data_from_bars(self._ltf_bars[-200:])
    self._ltf_order_blocks = self._ob_detector.detect(...)
    self._ltf_fvgs = self._fvg_detector.detect(...)
```

**Phase C: Update Scorer Call** (1 hour)
```python
# Pass MTF (M15) structural zones to scorer
result = self._confluence_scorer.calculate_score(
    order_blocks=self._mtf_order_blocks,  # M15 structural
    fvgs=self._mtf_fvgs,                   # M15 structural
    ...
)
```

**Phase D: Validation** (2 hours)
1. Run backtest BEFORE fix (baseline metrics)
2. Apply fix
3. Run backtest AFTER fix (compare metrics)
4. **Expected**: Improvement in WFE/SQN (signals should be more accurate)

**Decision Required**:
- **Option A (Recommended)**: Use MTF (M15) OBs in scorer (SMC philosophy)
- **Option B**: Use LTF (M5) OBs in scorer (precise entry timing)
- **Option C**: Pass BOTH and let scorer use proximity logic

**Dependencies**: None
**Blocking**: Should fix BEFORE ablation study (current results may be misleading)

**Agent**: 1 FORGE (opus) for fix + validation

---

## Category 3: Remaining Temporal Integrity Issues (P06)

### Fixed in WP3 (2025-12-22)
✅ P06-R1-A-001: HTF look-ahead in EA parity (as-of slicing added)
✅ P06-R2-E-001: MTF alignment uses full-series (causal filtering added)
✅ P04.5-C-ML-001: KFold → TimeSeriesSplit
✅ P04.5-H-ML-001: Scaler train-test split

### Still Open (CRITICAL)

**P06-R2-D-P06-R2D-001**: Monte Carlo script uses leaky EA parity path
- **File**: `scripts/backtest/validation/monte_carlo_stress.py`
- **Issue**: Runs `TickBacktester` with `use_ea_logic=True` which has look-ahead
- **Fix**: Use main strategy backtest, not EA parity path
- **Effort**: 1 hour (change config)

**P06-R2-D-P06-R2D-007**: WFA script uses forward-confirmed SMC structures
- **File**: `scripts/backtest/validation/walk_forward_analysis.py`
- **Issue**: `SMCAblationBacktester` precomputes OB/FVG using future bars
- **Fix**: Use main strategy backtest with proper as-of slicing
- **Effort**: 1 hour (change config)

**P06-R2-P06-R2D-001**: Same as above (duplicate ID)
**P06-R2-P06-R2E-001**: Same as P06-R2-E-001 (already fixed)

### Fix Plan
**Don't use leaky validation scripts until fixed. Use ORACLE backtest instead.**

**Phase A: Short-term Workaround** (0 hours)
- Skip MC/WFA scripts for now
- Use main strategy backtest for validation
- ORACLE has correct as-of slicing (WP3 fixes)

**Phase B: Long-term Fix** (3-4 hours)
- Refactor MC/WFA to use main strategy backtest
- Remove EA parity path entirely (already deprecated)
- Add temporal integrity tests to prevent regression

**Dependencies**: WP3 fixes (already done)
**Blocking**: Can validate strategies without MC/WFA for now

**Agent**: 1 FORGE (opus) to refactor validation scripts

---

## Category 4: Test Coverage Gaps (P07-001, P07-002)

### Current Coverage
- **Line Coverage**: 52.68% (target: ≥70%)
- **Branch Coverage**: 28.66% (target: ≥50%)
- **Strategy Orchestration**: ~15% (CRITICAL GAP!)

### High-Risk Untested Code

**P07-002**: Strategy orchestration (`gold_scalper_strategy.py`)
- **Lines**: 2,652 total, only ~400 covered (~15%)
- **Risk**: Core trading logic mostly untested
- **Critical paths untested**:
  - Time gate enforcement (4:30 PM block, 4:55 PM emergency, 4:59 PM flatten)
  - DD breach flatten logic
  - Bracket order failure handling
  - Multi-timeframe bar subscriptions
  - Confluence scoring flow

**P07-003**: News filtering (`news_trader.py` - 0% coverage)
- **Risk**: If news filter fails, trades during high-impact events
- **Impact**: High slippage, stop hunting

**P07-004**: Validation framework (`src/validation/*` - 0% coverage)
- **Risk**: Validation scripts may have bugs

**P07-005**: Confluence scorer coverage incomplete
- **File**: `confluence_scorer.py` (1,055 lines)
- **Known Phase 04 risks**: ICT at_poi bug (now fixed but not regression-tested)

### Fix Plan

**Phase A: Critical Path Tests** (8-12 hours)
Focus on highest-risk, lowest-coverage areas:

1. **Time Gates** (2 hours)
   - Test 4:30 PM block (new trades blocked)
   - Test 4:55 PM emergency close (all positions flattened)
   - Test 4:59 PM hard flatten (failsafe)
   - Test timezone handling (ET vs UTC)

2. **DD Breach Flatten** (2 hours)
   - Test trailing DD 4.5% triggers flatten
   - Test daily DD 3.0% triggers halt
   - Test HWM tracking with unrealized PnL
   - Test failsafe latch (can't trade after trigger)

3. **Execution Failsafe** (2 hours)
   - Test bracket rejection leaves naked position → watchdog flattens
   - Test order lifecycle tracking
   - Test emergency close cancels orders first

4. **Confluence Scoring Flow** (3 hours)
   - Test all 9 factors contribute correctly
   - Test ICT 7-step sequence (regression test for at_poi fix)
   - Test session-specific weights
   - Test Phase 1 multipliers (alignment, freshness, divergence)

5. **MTF Integration** (3 hours)
   - Test HTF/MTF/LTF bar subscriptions
   - Test alignment detection
   - Test regime blocking
   - Test premium/discount logic

**Phase B: Raise General Coverage** (4-6 hours)
- Add missing unit tests for indicators
- Add integration tests for signal generators
- Add E2E test for full trade lifecycle

**Target**: 70% line / 50% branch minimum

**Dependencies**: MTF duplication fix (Phase A above)
**Blocking**: Should complete before final validation

**Agent**: 2 FORGE (opus) in parallel (split test areas)

---

## Category 5: Execution Safety Gaps (P05-B, P08)

### Fixed in WP0/WP5 (2025-12-22)
✅ P08-004: Bracket failure → watchdog + emergency flatten
✅ P08-005: Order state machine + lifecycle tracking
✅ P08-023: Emergency close → cancel_all THEN close_all
✅ P05-B-B-001: ExecutionRealism dataclass (latency, reject, partial fill)

### Still Open (CRITICAL)

**P05-B-B-003**: MT5/Ninja adapters are stubs (fail-open)
- **File**: `src/adapters/mt5_adapter.py`, `ninjatrader_adapter.py`
- **Issue**: `connect()` returns success even if broker unreachable
- **Risk**: In live, think we're connected but we're not
- **Fix**: Implement real connection check OR remove adapters if not used
- **Effort**: 2 hours (add connection validation)

**P08-013**: TradeManager exists but not integrated
- **File**: `src/execution/trade_manager.py` (partial TP, trailing logic)
- **Issue**: Strategy doesn't use TradeManager (manual bracket logic instead)
- **Risk**: Missing partial TP / trailing stop functionality
- **Decision Required**: Integrate TradeManager OR remove it
- **Effort**: 4-6 hours (integrate) OR 1 hour (remove)

**P05-B-B-005**: Adapter interface lacks ack/fill/reject lifecycle
- **Issue**: Can't distinguish between "order sent" vs "order filled"
- **Risk**: Timing bugs, double-fills
- **Fix**: Implement proper lifecycle events
- **Effort**: 3-4 hours

### Fix Plan

**Phase A: Adapter Decision** (User Input Required)
- **Question**: Are we using MT5/Ninja adapters in production?
- **If YES**: Fix connection validation + lifecycle events (6-8 hours)
- **If NO**: Archive adapters, document "Nautilus native execution only" (1 hour)

**Phase B: TradeManager Decision** (User Input Required)
- **Question**: Do we want partial TP / trailing stops?
- **If YES**: Integrate TradeManager into strategy (4-6 hours)
- **If NO**: Archive TradeManager (1 hour)

**Dependencies**: User decisions
**Blocking**: Not critical for initial activation (Nautilus execution works)

**Agent**: 1 FORGE (opus) after decisions made

---

## Category 6: Apex Compliance Gaps (P06-R1-A, P08)

### Fixed in WP1/WP2/WP4 (2025-12-22)
✅ P08-006: Wall-clock time gates (set_timer_ns enforcement)
✅ P08-007: Guaranteed flat by 4:59 PM ET (on_timer callback)
✅ P08-001: DD breach forces flatten (not just entry block)
✅ P08-002: DD systems unified (all gates fail-closed)
✅ P04-A-007/008: Wall-clock usage in entry expiry (current_time param)
✅ P04-B-001/006: Naive datetime → timezone-aware

### Still Open (CRITICAL)

**P06-R1-A-002 / P06-R1-A-A-002**: Missing Apex ET time gates in backtest scripts
- **Files**: EA parity scripts (ea_logic_*.py)
- **Issue**: Backtest scripts don't enforce 4:30/4:55/4:59 PM ET gates
- **Risk**: Backtest results unrealistic (trades after 4:30 PM won't happen in live)
- **Fix**: Add time gates to backtest configs OR deprecate EA parity scripts
- **Effort**: 1 hour (config) OR 2 hours (implementation)

**P06-R1-A-003 / P06-R1-A-A-003**: Risk model uses realized balance (not Apex trailing DD from HWM)
- **Files**: EA parity `RiskManager` classes
- **Issue**: DD calculated from realized balance, not HWM + unrealized
- **Risk**: Backtest won't catch HWM trap (unrealized profit raises floor)
- **Fix**: Use main strategy (already has correct HWM tracking via PropFirmManager)
- **Effort**: 0 hours (just use main strategy, not EA parity)

**P08-014**: Mixed daily boundary logic (ET vs UTC)
- **Issue**: Some modules use ET, some use UTC for daily reset
- **Risk**: Consistency cap / daily DD may reset at wrong time
- **Fix**: Standardize on ET (America/New_York) everywhere
- **Effort**: 2-3 hours (audit + fix all modules)

**P08-016**: ET ZoneInfo availability inconsistent
- **Issue**: Some modules fail-hard if `America/New_York` unavailable, some fail-safe
- **Risk**: Strategy halts vs continues with wrong timezone
- **Fix**: Standardize on fail-safe with degraded mode times (4:20 PM block, 4:45 PM close)
- **Effort**: 1-2 hours

### Fix Plan

**Phase A: Deprecate EA Parity Scripts** (Recommended)
- EA parity scripts have multiple issues (temporal, Apex, execution)
- Main strategy has all fixes (WP0-WP5)
- **Action**: Mark EA scripts as deprecated, use main strategy for all validation
- **Effort**: 1 hour (add warnings + docs)

**Phase B: Timezone Standardization** (2-3 hours)
- Audit all modules for ET vs UTC usage
- Standardize on `America/New_York` with fail-safe degraded mode
- Add unit tests for timezone edge cases (DST transitions)

**Dependencies**: None
**Blocking**: Should fix before final validation

**Agent**: 1 SENTINEL (opus) for Apex compliance verification

---

## Category 7: Ablation Study (CRUCIAL for Phase 02)

### Purpose
Before activating SMC_SCALPER, need to know which of the 9 confluence factors actually contribute to edge.

### Current Factors (GENIUS v4.2)
1. **Structure** (BOS/CHoCH) - 15pts weight
2. **Regime** (Hurst/Entropy) - 10pts
3. **Order Blocks** - 15pts
4. **FVG** - 10pts
5. **Liquidity Sweep** - 10pts
6. **AMD Cycle** - 10pts
7. **Fibonacci** - 5pts
8. **MTF Alignment** - 15pts
9. **Footprint** - 10pts

### Hypothesis (CRUCIBLE Insight)
80% of edge comes from:
- **NOT trading in random walk** (regime filter)
- **NOT trading in bad sessions** (Asian block)
- **Proper position sizing + DD throttle**
- **Active trade management** (partial TP, trailing)

Only 20% (or less) from SMC signals themselves.

### Ablation Plan

**Methodology**:
1. Run baseline backtest with all 9 factors enabled
2. For each factor, run backtest with that factor DISABLED
3. Measure impact: ΔWFEBloqueadores**, ΔSQN, ΔPF, Δtrade_count
4. Statistical significance test (p < 0.05)

**Configs to Test** (10 total):
- Baseline (all enabled)
- Disable Structure
- Disable Regime
- Disable OB
- Disable FVG
- Disable Sweep
- Disable AMD
- Disable Fib
- Disable MTF
- Disable Footprint

**Metrics to Track**:
| Config | Trades | WFE | SQN | PF | MaxDD | Notes |
|--------|--------|-----|-----|----|----|-------|
| Baseline | | | | | | |
| -Structure | | | | | | |
| ... | | | | | | |

**Expected Outcome**:
- Some factors will show NO significant impact → **REMOVE THEM**
- Some factors will show NEGATIVE impact (make it worse) → **DEFINITELY REMOVE**
- A few factors will show STRONG positive impact → **KEEP ONLY THESE**

**Simplification Target**:
- Reduce from 9 factors → 3-5 factors (evidence-based only)
- Reduce from 50+ parameters → <10 parameters
- Less overfitting = more robust live performance

### Fix Plan

**Phase A: Run Ablation Study** (6-8 hours)
1. Create 10 config variants
2. Run ORACLE backtest for each (parallel if possible)
3. Collect metrics in spreadsheet
4. Statistical analysis (t-test for WFE/SQN differences)

**Phase B: Simplification** (4-6 hours)
1. Remove non-contributing factors from confluence_scorer.py
2. Update documentation
3. Re-run baseline backtest (should improve or stay same)

**Phase C: Validation** (2 hours)
1. Compare simplified vs original
2. Verify WFE/SQN maintained or improved
3. Verify fewer trades (good - more selective)

**Dependencies**: MTF semantic collision fix (to ensure correct data)
**Blocking**: MUST complete before Phase 02 GO/NO-GO decision

**Agent**: 1 CRUCIBLE (opus) to design study + 1 ORACLE (opus) to run backtests

---

## Category 8: Documentation \u0026 Architecture

### Missing Documentation

**ARCHITECTURE.md** (Phase 01-04 deliverable)
- Strategy hierarchy (BaseGoldStrategy → GoldScalperStrategy)
- StrategySelector decision tree (6 gates)
- AdaptiveEVRouter arms (SMC, TrendFollow, MeanRevert)
- Signal generation flow
- Risk management layers (PropFirm, DD, CircuitBreaker, Consistency)

**MULTI_STRATEGY_COMPARISON.md** (Phase 06-04 deliverable)
- Individual strategy performance
- Combined performance (selector only)
- Combined performance (router active)
- Diversification benefit analysis

**MTF_CONSOLIDATION.md** (New)
- Document indicators vs signals MTF manager differences
- Migration path
- Test coverage improvement

### Fix Plan

**Phase A: Create ARCHITECTURE.md** (3-4 hours)
- Diagram strategy hierarchy
- Document selector gates with examples
- Document router Thompson sampling
- Document risk management layers

**Phase B: Auto-generate from code** (2 hours)
- Use LSP to extract class hierarchy
- Generate mermaid diagrams
- Keep synchronized with code

**Dependencies**: Phase 01 cleanup
**Blocking**: Needed for Phase 02+ understanding

**Agent**: 1 DOCUMENTER or FORGE (opus)

---

## Execution Priority Matrix

| Category | Priority | Blocking | Effort | Agent |
|----------|----------|----------|--------|-------|
| **1. MTF Duplication** | P0 | Phase 02 | 5-6h | FORGE |
| **2. Semantic Collision** | P0 | Ablation | 7h | FORGE |
| **3. Temporal Integrity** | P1 | Validation | 4h | FORGE |
| **4. Test Coverage** | P0 | Phase 02 | 12-18h | 2x FORGE |
| **5. Execution Safety** | P2 | - | TBD (user decisions) | FORGE |
| **6. Apex Compliance** | P1 | Validation | 3-4h | SENTINEL |
| **7. Ablation Study** | P0 | Phase 02 GO/NO-GO | 12-16h | CRUCIBLE + ORACLE |
| **8. Documentation** | P1 | Phase 02 | 5-6h | DOCUMENTER |

---

## Recommended Execution Sequence

### Week 1: Foundations (Critical Blockers)

**Day 1-2: MTF \u0026 Semantic Collision**
1. Fix MTF duplication (Category 1) - 6h
2. Fix semantic collision (Category 2) - 7h
3. **Checkpoint**: Verify strategy still works, coverage increased

**Day 3-4: Test Coverage**
1. Add critical path tests (Category 4) - 12-18h
2. **Checkpoint**: Coverage ≥70% line / 50% branch

**Day 5: Apex \u0026 Temporal**
1. Timezone standardization (Category 6) - 3h
2. Deprecate EA parity scripts (Category 6) - 1h
3. **Checkpoint**: All Apex gates validated

### Week 2: Validation (Edge Discovery)

**Day 6-8: Ablation Study**
1. Design ablation configs (Category 7) - 2h
2. Run 10 backtest variants (Category 7) - 8h (parallel)
3. Statistical analysis (Category 7) - 3h
4. Simplify confluence scorer (Category 7) - 6h
5. **Checkpoint**: Evidence-based factor list (3-5 factors)

**Day 9-10: Documentation \u0026 Final Prep**
1. Create ARCHITECTURE.md (Category 8) - 4h
2. Update ROADMAP with findings - 2h
3. **Checkpoint**: Ready for Phase 02 SMC Deep Audit

---

## GO/NO-GO Criteria (Before Phase 02)

| Criterion | Target | Status |
|-----------|--------|--------|
| MTF duplication resolved | Yes | ❌ Not started |
| Semantic collision fixed | Yes | ❌ Not started |
| Test coverage ≥70% line | Yes | ❌ 52.68% |
| Test coverage ≥50% branch | Yes | ❌ 28.66% |
| Apex compliance verified | Yes | ⚠️ Partial (WP1-WP4) |
| Ablation study complete | Yes | ❌ Not started |
| CRITICAL issues ≤10 | Yes | ❌ 34 open |

**Current Verdict**: **NO-GO**
**Reason**: Too many critical blockers, insufficient test coverage, edge hypothesis unproven

**Next Steps**: Execute Week 1-2 plan above, then reassess.

---

## User Decisions Required

Before starting, Franco needs to decide:

### Decision 1: MTF Semantic Collision
**Question**: Which timeframe should confluence scorer use for Order Blocks?
- **Option A (Recommended)**: MTF (M15) - SMC structural zones
- **Option B**: LTF (M5) - Precise entry timing
- **Option C**: Both (combined list)

### Decision 2: Execution Adapters
**Question**: Are we using MT5/Ninja adapters in production?
- **If YES**: Fix them (6-8 hours)
- **If NO**: Archive them (1 hour)

### Decision 3: TradeManager
**Question**: Do we want partial TP / trailing stops?
- **If YES**: Integrate TradeManager (4-6 hours)
- **If NO**: Archive TradeManager (1 hour)

### Decision 4: Mean Revert Strategy
**Question**: Implement, remove, or defer STRATEGY_MEAN_REVERT?
- **Implement**: Create mean_revert.py (8-12 hours)
- **Remove**: Delete enum (1 hour)
- **Defer**: Return SMC when selected (0 hours)

---

## Empirical Observations from Backtests (2025-12-23)

### Session Context
These observations come from debugging the Score=0.0 issue and running 6-month backtests (2024-01-01 to 2024-06-30).

### Score=0.0 Bug (FIXED in commit 58b84178)

**Root Cause Identified:**
- Session adjustment was killing weighted base scores
- Example flow: `base=3.65` (structure) + `adj=-5` (LOW session) = `-1.35` → clamped to 0

**Fixes Applied:**
1. `session_filter.py:154-161`: Upgrade quality from BLOCKED to LOW when `allow_asian=True`
2. `confluence_scorer.py:642-646`: Don't apply -5 adjustment when `is_trading_allowed=True`

**Validation Results:**
- Before fix: Score=0.0 during Asian sessions (BLOCKED)
- After fix: Scores of 16-22 during Asian (now tradeable)

### Component-Level Breakdown (CRITICAL INSIGHT)

During Asian session analysis, only 1 of 9 factors fires:

```
structure=15.0, regime=0.0, ob=0.0, fvg=0.0, sweep=0.0, amd=0.0, fib=0.0, mtf=0.0, footprint=0.0
```

**Implications:**
- OB/FVG detectors may require more data or higher volatility
- MTF alignment score=0 suggests no clear alignment (expected in Asian)
- **This strongly supports Category 7 (Ablation Study)** - only structure is contributing

### Score Ranges by Session

| Session | Score Range | Threshold (35) | Result |
|---------|-------------|----------------|--------|
| Asian | 16-22 | Below | No trades (expected) |
| London Open | 30-40 | Borderline | Some trades |
| Overlap (Prime) | 44-52 | Above | Trades execute |
| NY Session | 35-48 | Above | Trades execute |

**Insight:** Threshold 35 effectively filters Asian (good) but may be too aggressive for London open.

### Trade Clustering Phenomenon

**Observation:** All 7 trades in 6-month period clustered in Jan 2-10, 2024

Possible explanations:
1. Market conditions in early Jan 2024 were favorable for SMC patterns
2. After Jan 10, no signals reached 35 threshold
3. Data quality issue in later months (unlikely - validated)
4. **Semantic collision (Category 2) may cause pattern misdetection**

**Action Item:** After fixing semantic collision, re-run 6-month backtest to compare trade distribution.

### FAILSAFE Behavior Observation

```
[FAILSAFE] Reason=bracket_sl_canceled: CRITICAL - no SL on position → on_timer: _failsafe_triggered=True, HALT
...
[DEBUG] DAILY_RESET cleared failsafe latch
```

**Observation:** FAILSAFE triggers on each trade but DAILY_RESET clears it next day.

**Impact:**
- Strategy correctly detects bracket issues
- Daily reset allows recovery (good for testing, verify for production)
- Need to investigate WHY bracket_sl_canceled happens repeatedly

### Backtest Results Summary (6 months, 2024-01-01 to 2024-06-30)

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Total Trades | 7 | ≥200 | ❌ FAR below |
| Win Rate | 42.9% (3W/4L) | - | - |
| Net PnL | +$319 | - | ✅ Positive |
| Trade Frequency | ~1.2/month | - | ❌ Very low |

**Key Insight:** Strategy has SOME edge (positive PnL) but trade frequency is unacceptable. Root cause is likely:
1. Threshold too high (35)
2. Semantic collision causing OB/FVG score=0
3. Missing MTF data alignment

### Recommendations Based on Observations

1. **Fix Semantic Collision FIRST (Category 2)**
   - Currently OB/FVG detectors receive LTF data, score=0 in many cases
   - This alone may explain low trade frequency

2. **Lower Threshold to 25-30 for Testing**
   - After semantic collision fix, test with lower threshold
   - Current 35 filters out too many opportunities

3. **Run Extended Backtest After Fixes**
   - Full 2003-2025 dataset to see trade distribution
   - Expect more trades with semantic collision fixed

4. **Investigate bracket_sl_canceled**
   - Why does bracket order fail repeatedly?
   - May be data quality issue or timing issue

5. **Ablation Study Priority Order**
   - structure: Only one firing → validate it works correctly
   - ob/fvg: Score=0 always → likely broken (semantic collision)
   - mtf: Score=0 always → validate alignment logic

---

## Summary \u0026 Next Steps

**Situation**: 34 CRITICAL issues block activation. Key problems:
1. Tests don't match production code (MTF duplication)
2. Wrong data passed to scorer (semantic collision) ← **Backtest confirms this**
3. Coverage too low to trust code
4. Edge hypothesis unproven (need ablation study) ← **Backtest shows only 1 of 9 factors fires**

**Empirical Evidence Added:**
- Score=0.0 bug now FIXED
- Only structure (1/9 factors) contributes during most sessions
- 7 trades in 6 months is way below target (need ≥200)
- Positive PnL (+$319) suggests SOME edge exists

**Plan**: 2-week sprint to resolve blockers → ablation study → Phase 02 GO/NO-GO

**First Action**: Get Franco's decisions on 4 questions above, then start Week 1 execution.

**Success Metric**: All GO/NO-GO criteria GREEN before Phase 02.

---

*End of Critical Issues Audit*
