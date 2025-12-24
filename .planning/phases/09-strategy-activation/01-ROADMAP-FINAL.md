# ROADMAP FINAL: Strategy Activation & Validation

**Document:** 01-ROADMAP-FINAL.md
**Version:** 2.0 (ARGUS-Integrated)
**Created:** 2025-12-23
**Last Updated:** 2025-12-23
**Status:** READY FOR EXECUTION
**Philosophy:** FIX FIRST + ARGUS VALIDATED + FALSIFICATION-FIRST

---

## Executive Summary

This is the **definitive** Phase 09 planning document, incorporating:
- **FIX FIRST** philosophy from v1/v2 synthesis
- **ALL ARGUS research findings** from 6 research documents
- **47 failure modes** from prop firm analysis
- **17 look-ahead patterns** from bias detection research
- **PBO/DSR metrics** as new GO/NO-GO criteria
- **DAEMON's economic concerns** addressed with baseline validation gate

> "Better to have a war machine than a weak little pistol."
> "But a war machine must be validated before battle."

---

## ARGUS Research Integration

### Research Documents Analyzed

| Document | Key Findings | Integration |
|----------|--------------|-------------|
| ARGUS_BACKTESTING_DEEP_DIVE | Latency modeling, Shadow Exchange | Phase 06 MC simulation |
| ARGUS_BACKTESTING_RESEARCH_20251130 | WFA/MC specs, DSR formula | Phase 02/06 validation |
| ARGUS_PROP_FIRM_FAILURES | 47 failure modes, automation ban | All phases, Phase 07 |
| ARGUS_LOOKAHEAD_DETECTION | 17 patterns, NautilusTrader config | Phase 02 audit |
| RESEARCH_GAP_ANALYSIS | 5 critical gaps | Phases 02, 05, 06 |
| DAEMON_FUNDAMENTAL_REVIEW | Economic concerns, baseline test | Phase 00-A (NEW) |

### Critical Findings Integrated

**TIER 1 - FUNDAMENTAL:**
- [x] Automation prohibition on PA/Live accounts
- [x] HWM tracks unrealized peaks (trap awareness)
- [x] PBO/DSR metrics added to GO/NO-GO

**TIER 2 - COMPLIANCE:**
- [x] 30% per-trade loss limit
- [x] 5:1 R:R enforcement
- [x] NautilusTrader bar configuration requirements

**TIER 3 - VALIDATION:**
- [x] 17 look-ahead pattern checklist
- [x] 47 failure mode matrix
- [x] WFA/Monte Carlo specifications

---

## Philosophy: FIX FIRST, VALIDATE SECOND

| Previous Approach | This Approach |
|-------------------|---------------|
| Observe 8/9 factors scoring 0 | Recognize this as a BUG SYMPTOM |
| Conclude "system is over-engineered" | Investigate root cause FIRST |
| Pre-decide to simplify to 3-4 factors | Fix bugs, THEN validate full system |
| Archive complexity before testing | DISABLE components, don't archive |
| No baseline comparison | **EMA baseline test FIRST** (from DAEMON) |
| Assume implementation will work | **Falsification-first** approach |

### Core Principle (Updated)

1. **Run baseline validation** (Phase 00-A) - Let data decide
2. **FIX the bugs** (semantic collision, clustering, paths)
3. **RUN the FIXED system** with all 9 factors
4. **VALIDATE** with enhanced metrics (WFE, SQN, PSR, **DSR, PBO**)
5. **IF YES**: Keep the complexity - we have a war machine
6. **IF NO**: THEN consider simplification as Plan B

---

## Decision Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **OB/FVG Timeframe** | M15 (MTF) | SMC philosophy - structural zones on M15, entry on M5 |
| **9 Confluence Factors** | KEEP ALL | Fix bugs first, validate before removing |
| **AdaptiveEVRouter** | DISABLE (not archive) | Preserve optionality for when trade frequency increases |
| **StrategySelector** | KEEP | Validate gates work before simplifying |
| **TREND_FOLLOW Strategy** | KEEP | Validate after SMC_SCALPER |
| **MEAN_REVERT Strategy** | VALIDATE FIRST | Research says gold doesn't mean-revert, test empirically |
| **Simplification** | PLAN B | Only if fixed system fails validation |
| **Execution Mode** | AUTO + SIGNAL_ONLY | Support both for PA/Live compliance (**NEW**) |
| **Baseline Test** | RUN FIRST | From DAEMON - let data decide (**NEW**) |

---

## Phase Overview (Revised)

| Phase | Focus | Duration | GO/NO-GO Gate |
|-------|-------|----------|---------------|
| **00-A** | **BASELINE VALIDATION (NEW)** | 2-4 hours | SMC > EMA by 20%+ |
| **00-B** | Critical Bug Fixes | 1 week | All 9 factors score > 0 |
| **00-C** | **PORTFOLIO STRATEGY REVIEW (NEW)** | 1 day | Portfolio decision + falsification plan locked |
| **01** | Cleanup & Consolidation | 3 days | Dead code archived, architecture documented |
| **02** | SMC_SCALPER Deep Audit | 2 weeks | **+17 look-ahead checks, NautilusTrader config** |
| **03** | TREND_FOLLOW Activation | 1 week | Strategy enabled with edge verified |
| **04** | MEAN_REVERT Decision | 3 days | User decision: implement/remove/defer |
| **05** | Framework Integration | 1 week | **+30% limit, 5:1 R:R, execution modes** |
| **06** | Multi-Strategy Backtest | 1 week | **+PBO/DSR, failure mode matrix** |
| **07** | Paper Trading | 2 weeks | **+AUTO and SIGNAL_ONLY testing** |
| **08** | Production Readiness | 1 week | SENTINEL sign-off |

**Total Timeline:** 10-11 weeks (unchanged)

---

## Phase 00-A: BASELINE VALIDATION (NEW - From DAEMON)

### Objective
Validate the core SMC thesis BEFORE spending weeks on fixes. Let data decide.

### 00-A-01: Create Simple EMA Baseline (2 hours)

**Baseline Strategy:**
```python
class EMABaseline:
    """Simple EMA crossover for comparison."""

    # EMA 20/50 crossover
    # Same session filter as SMC
    # Same risk management as SMC
    # Same Apex compliance

    def generate_signal(self, bars):
        ema_fast = ema(bars.close, 20)
        ema_slow = ema(bars.close, 50)

        if ema_fast[-1] > ema_slow[-1] and ema_fast[-2] <= ema_slow[-2]:
            return Signal.BUY
        elif ema_fast[-1] < ema_slow[-1] and ema_fast[-2] >= ema_slow[-2]:
            return Signal.SELL
        return None
```

### 00-A-02: Run Identical Backtest (1 hour)

**Configuration:**
- Dataset: `xauusd_2003_2025_stride20_full.parquet`
- Period: 2024-01-01 to 2024-06-30 (same as current)
- Same sessions, same risk limits

### 00-A-03: Comparison Analysis (1 hour)

| Metric | SMC (Current) | EMA Baseline | Delta | Verdict |
|--------|---------------|--------------|-------|---------|
| Total Trades | 7 | ? | ? | ? |
| Win Rate | 42.9% | ? | ? | ? |
| Net PnL | +$319 | ? | ? | ? |
| Sharpe | ? | ? | ? | ? |
| Profit Factor | ? | ? | ? | ? |

### Phase 00-A GO/NO-GO Gate

```
IF SMC < EMA (Sharpe/PF): STOP IMMEDIATELY
   The philosophical foundation is broken.
   Consider: Higher timeframe (H4/D1), different market, or simpler approach.

IF SMC > EMA by < 20%: CAUTION
   Complexity may not be justified.
   Proceed but with heightened scrutiny.

IF SMC > EMA by >= 20%: PROCEED
   Core thesis validated. Continue with FIX FIRST.
```

**Owner:** ORACLE (opus)
**Effort:** 2-4 hours

---

## Phase 00-B: Critical Bug Fixes (1 week)

### Objective
Fix all known bugs that prevent the 9-factor system from functioning correctly.

### 00-B-01: Semantic Collision Fix (Priority 0) - Day 1-2

**Problem:** Variable `_mtf_order_blocks` is overwritten by LTF detection.

**User Decision:** Use M15 for OB/FVG (Option A)

**Fix:**
```python
# BEFORE (ambiguous - gets overwritten)
self._mtf_order_blocks: list[OrderBlock] = []
self._mtf_fvgs: list[FairValueGap] = []

# AFTER (explicit by timeframe)
self._htf_order_blocks: list[OrderBlock] = []   # H1 - direction
self._mtf_order_blocks: list[OrderBlock] = []   # M15 - structure
self._ltf_order_blocks: list[OrderBlock] = []   # M5 - entry

self._htf_fvgs: list[FairValueGap] = []
self._mtf_fvgs: list[FairValueGap] = []
self._ltf_fvgs: list[FairValueGap] = []
```

**Files to Modify:**
| File | Change |
|------|--------|
| `gold_scalper_strategy.py` | Rename variables, fix detection logic |
| `signals/mtf_manager.py` | Populate correct lists by timeframe |
| `signals/confluence_scorer.py` | Receive M15 data for OB/FVG scoring |

**Validation:**
1. Run 1-week backtest with diagnostic logging
2. Verify OB and FVG factors score > 0
3. Compare before/after trade count

**Owner:** FORGE (opus)
**Effort:** 4-6 hours

### 00-B-02: File Path Fixes - Day 2

**Corrected Paths:**
| Planned Path | Actual Path | Action |
|--------------|-------------|--------|
| `src/indicators/mtf_manager.py` | `nautilus_gold_scalper/src/indicators/mtf_manager.py` | Deprecation warning |
| `src/signals/mtf_manager.py` | `nautilus_gold_scalper/src/signals/mtf_manager.py` | Production version |
| `tests/test_signals/test_mtf_manager.py` | Does not exist | CREATE |

**Owner:** FORGE (opus)
**Effort:** 3-4 hours

### 00-B-03: Known Bug Fixes - Day 3-4

**Already Fixed:**
- [x] Score=0.0 session adjustment (commit 58b84178)

**Still Open:**
| Bug | Description | Investigation |
|-----|-------------|---------------|
| Trade Clustering | All 7 trades Jan 2-10, ZERO after | Check state reset, memory leaks, MTF bar accumulation |
| bracket_sl_canceled | Failsafe triggers repeatedly | Investigate bracket order rejection |
| Temporal Integrity | MC/WFA scripts use leaky EA parity | Use main strategy backtest |

**Owner:** FORGE (opus)
**Effort:** 6-8 hours

### 00-B-04: Diagnostic Logging - Day 4-5

```python
# In confluence_scorer.py, add verbose logging
logger.info(f"Factor breakdown:")
logger.info(f"  structure={structure_score:.2f}")
logger.info(f"  regime={regime_score:.2f}")
logger.info(f"  ob={ob_score:.2f} (count={len(order_blocks)})")
logger.info(f"  fvg={fvg_score:.2f} (count={len(fvgs)})")
logger.info(f"  sweep={sweep_score:.2f}")
logger.info(f"  amd={amd_score:.2f}")
logger.info(f"  fib={fib_score:.2f}")
logger.info(f"  mtf={mtf_score:.2f}")
logger.info(f"  footprint={footprint_score:.2f}")
```

**Owner:** FORGE (opus)
**Effort:** 2 hours

### Phase 00-B GO/NO-GO Gate

**Criteria:**
- [ ] All 9 factors can score > 0 (verify with diagnostic logs)
- [ ] No division by zero or null handling errors
- [ ] Test suite passes (`mypy --strict`, `pytest -q`)
- [ ] File paths corrected and documented

---

## Phase 00-C: PORTFOLIO STRATEGY REVIEW (NEW - From CRUCIBLE)

### Objective
Lock the **portfolio-level thesis** (what strategies we run, which are redundant, and which are worth validating) before investing further in strategy-specific tuning.

This phase is intentionally **decision + falsification-first**, not code-first.

### Inputs (existing docs)
- Portfolio review + improvement ideas: `nautilus_gold_scalper/FUTURE_IMPROVEMENTS.md` (CRUCIBLE 2025-12-24 section)
- Falsification test suite (ghost/shifted-levels/HWM survival): `05-FALSIFICATION_TESTS.md`

### Decisions to lock (portfolio)
- **Redundancy:** consolidate `SMC_SCALPER` + `SCALPER` into one microstructure scalper (zones + confirmation + strict spread/news/session gates) OR keep separate (only if proven non-correlated).
- **Additions (max 2, conditional):**
  - Volatility Expansion Breakout (range → impulse)
  - Anchored VWAP mean-reversion
- **Apex/HWM constraints:** mandatory de-risk in profit + time-based exits near 4:55–4:59 PM ET.

### Deliverable
- `orchestration/PHASE_00C_PORTFOLIO_REVIEW.md`:
  - What we keep / consolidate / defer
  - Which falsification tests are required next and what would change our mind

### Phase 00-C GO/NO-GO Gate
- [ ] Portfolio decision documented (keep/consolidate/defer) with rationale tied to Apex risk
- [ ] Falsification tests to run next are enumerated with explicit thresholds (pass/fail)

---

## Phase 01: Diagnostic & Baseline (3 days)

*Detailed plan in `02-PHASE-01-PLAN.md`*

### Summary
- Run FIXED system with all 9 factors
- Threshold sensitivity analysis (35, 30, 25, 20)
- Compare to EMA baseline (reference only)
- Capture factor activation report

### Phase 01 GO/NO-GO Gate

| Outcome | Action |
|---------|--------|
| 50+ trades, 4+ factors | PROCEED to Phase 02 with full 9-factor system |
| 50+ trades, < 4 factors | PROCEED but flag for ablation study |
| < 50 trades | TRIGGER Plan B (Simplification) |

---

## Phase 02: SMC Deep Audit (2 weeks) - ENHANCED

*Detailed plan in `03-PHASE-02-PLAN.md`*

### Additional Tasks (From ARGUS)

#### 02-NEW-01: Look-Ahead Pattern Verification

**17 patterns to check (from ARGUS_LOOKAHEAD_DETECTION):**

| # | Pattern | Grep Command | Status |
|---|---------|--------------|--------|
| 1 | Future bar access | `rg -n "close\[-1\]" src/` | [ ] |
| 2 | Unshifted iloc | `rg -n "\.iloc\[-1\]" src/` | [ ] |
| 3 | Future-indexed arrays | `rg -n "\[i\+1\]" src/` | [ ] |
| 4 | ta library defaults | `rg -n "ta\." src/` | [ ] |
| 5 | Missing shift() | `rg -n "\.ewm\(|\.rolling\(" src/` | [ ] |
| 6 | Full series indicators | `rg -n "def calculate.*bars\)" src/` | [ ] |
| 7 | Current bar in rolling | `rg -n "window.*min_periods" src/` | [ ] |
| 8 | EMA on unshifted | `rg -n "ema.*close\)" src/` | [ ] |
| 9 | ATR with current bar | `rg -n "atr.*high.*low" src/` | [ ] |
| 10 | Same-bar entry signal | `rg -n "signal.*close\[-0\]" src/` | [ ] |
| 11 | Exit on entry bar | `rg -n "exit.*entry" src/` | [ ] |
| 12 | TP/SL entry bar hit | `rg -n "tp_hit.*entry\|sl_hit.*entry" src/` | [ ] |
| 13 | Bar open fill assumption | `rg -n "fill.*open" src/` | [ ] |
| 14 | Bar timestamp interpret | `rg -n "ts_event\|ts_init" src/` | [ ] |
| 15 | Close vs open execution | `rg -n "execute.*close" src/` | [ ] |
| 16 | Tick aggregation timing | `rg -n "aggregate.*tick" src/` | [ ] |
| 17 | Quote vs trade timestamp | `rg -n "quote.*timestamp" src/` | [ ] |

**Deliverable:** `orchestration/LOOKAHEAD_CHECKLIST.md`

#### 02-NEW-02: NautilusTrader Bar Configuration Audit

**Required Settings (from ARGUS):**
```python
config = BacktestRunConfig(
    engine=BacktestEngineConfig(
        # CRITICAL: Bar timestamp at CLOSE, not open
        bars_timestamp_on_close=True,

        # CRITICAL: Delay signal until next bar
        ts_init_delta=bar_interval_ns,  # 300_000_000_000 for M5

        # Execute on bar (not tick)
        bar_execution=True,

        # Realistic high/low ordering
        bar_adaptive_high_low_ordering=True,
    ),
)
```

**Verification:**
```bash
rg -n "bars_timestamp_on_close|ts_init_delta|bar_execution|bar_adaptive" src/
```

**Deliverable:** `orchestration/NAUTILUS_CONFIG_AUDIT.md`

#### 02-NEW-03: HWM Protection Logic Design

**Problem:** Unrealized profit raises HWM permanently.

**Solution:** Scale-out on winners.

```python
def calculate_scale_out_levels(
    entry_price: float,
    take_profit: float,
    risk_amount: float
) -> list[ScaleOutLevel]:
    """
    Scale out to protect HWM.

    Returns:
    - 50% at +1R (protect breakeven)
    - 25% at +2R (lock profit)
    - 25% at full TP (maximize)
    """
    one_r = risk_amount
    return [
        ScaleOutLevel(pct=0.50, trigger=one_r),
        ScaleOutLevel(pct=0.25, trigger=one_r * 2),
        ScaleOutLevel(pct=0.25, trigger=take_profit),
    ]
```

**Deliverable:** Design spec in `orchestration/HWM_PROTECTION_DESIGN.md`

### Phase 02 GO/NO-GO Gate (Updated)

**Criteria (ALL must pass):**
- [ ] WFE >= 0.6
- [ ] SQN >= 2.0
- [ ] PSR >= 0.85
- [ ] MC95DD < 4%
- [ ] **17 look-ahead patterns verified PASS** (NEW)
- [ ] **NautilusTrader config verified** (NEW)
- [ ] Holdout WFE >= 0.5

---

## Phase 03-04: Strategy Validation

*Detailed plans in `04-PHASE-03-PLAN.md` and `05-PHASE-04-PLAN.md`*

### Summary
- SMC_SCALPER deep audit (factor contribution)
- TREND_FOLLOW validation
- MEAN_REVERT research and decision

---

## Phase 05: Framework Integration - ENHANCED

*Detailed plan in `06-PHASE-05-PLAN.md`*

### Additional Tasks (From ARGUS)

#### 05-NEW-01: 30% Per-Trade Loss Limit

**Requirement (from ARGUS_PROP_FIRM_FAILURES):**
Single trade cannot lose > 30% of daily profit target.

```python
def validate_trade_risk(
    stop_loss_pips: float,
    lot_size: float,
    daily_target: float,
    max_loss_pct: float = 0.30
) -> bool:
    """
    Validate trade doesn't exceed 30% of daily target.

    For $100k account:
    - Daily target: ~$333/day (10% in 30 days)
    - 30% of daily target: ~$100 max loss per trade
    """
    pip_value = 10.0 * lot_size  # XAUUSD pip value per lot
    potential_loss = stop_loss_pips * pip_value
    max_allowed_loss = daily_target * max_loss_pct

    return potential_loss <= max_allowed_loss
```

**Integration:** Add to StrategySelector Gate 2 (FTMO)

#### 05-NEW-02: 5:1 R:R Enforcement

**Requirement (from ARGUS):**
Risk must be <= 1/5 of reward OR <= 5% of evaluation daily target.

```python
def validate_rr_ratio(
    stop_loss_pips: float,
    take_profit_pips: float,
    lot_size: float,
    daily_target: float,
    min_rr: float = 5.0,
    max_risk_pct: float = 0.05
) -> bool:
    """
    Validate R:R ratio meets Apex requirements.
    """
    rr_ratio = take_profit_pips / stop_loss_pips

    pip_value = 10.0 * lot_size
    risk_amount = stop_loss_pips * pip_value
    max_risk = daily_target * max_risk_pct

    # Either R:R >= 5:1 OR risk <= 5% of daily target
    return rr_ratio >= min_rr or risk_amount <= max_risk
```

**Integration:** Add to position_sizer.py

#### 05-NEW-03: Execution Mode Configuration

**Requirement (from ARGUS_PROP_FIRM_FAILURES):**
PA/Live accounts prohibit automation. Must support signal-only mode.

```python
class ExecutionMode(Enum):
    AUTO = "auto"           # Full automation (eval/backtest)
    SIGNAL_ONLY = "signal"  # Generate alerts, no OrderSubmit (PA/Live)

@dataclass
class StrategyConfig:
    execution_mode: ExecutionMode = ExecutionMode.AUTO

def on_signal(self, signal: Signal):
    if self.config.execution_mode == ExecutionMode.SIGNAL_ONLY:
        self.send_alert(signal)  # Push notification, no execution
        return

    # Full automation
    self.submit_order(signal)
```

**Integration:** Add to gold_scalper_strategy.py config

### Phase 05 GO/NO-GO Gate (Updated)

**Criteria:**
- [ ] All 6 selector gates work correctly
- [ ] Static allocation functions properly
- [ ] Router code compiles (for future use)
- [ ] **30% per-trade limit validated** (NEW)
- [ ] **5:1 R:R enforcement working** (NEW)
- [ ] **Both execution modes tested** (NEW)

---

## Phase 06: Multi-Strategy Backtest - ENHANCED

*Detailed plan in `07-PHASE-06-PLAN.md`*

### Additional Tasks (From ARGUS)

#### 06-NEW-01: PBO Implementation

**Probability of Backtest Overfitting (from ARGUS):**

```python
from scipy.stats import spearmanr, norm

def calculate_pbo(
    in_sample_returns: list[float],
    out_sample_returns: list[float]
) -> float:
    """
    Calculate Probability of Backtest Overfitting.

    Args:
        in_sample_returns: IS returns for each strategy variant
        out_sample_returns: OOS returns for corresponding variants

    Returns:
        PBO value between 0 and 1. Target: < 0.25
    """
    rho, _ = spearmanr(in_sample_returns, out_sample_returns)
    n = len(in_sample_returns)
    omega_hat = (1 - rho) / 2
    pbo = norm.cdf(omega_hat * np.sqrt(n))

    return pbo
```

#### 06-NEW-02: DSR Implementation

**Deflated Sharpe Ratio (from ARGUS):**

```python
from scipy.stats import skew, kurtosis

def calculate_dsr(
    returns: np.ndarray,
    num_trials: int
) -> float:
    """
    Calculate Deflated Sharpe Ratio.

    Args:
        returns: Strategy returns
        num_trials: Number of strategy variants tested

    Returns:
        DSR value. Target: > 0
    """
    sr = returns.mean() / returns.std() * np.sqrt(252)

    # Haircut for multiple testing
    T = len(returns)
    gamma = 0.5772  # Euler-Mascheroni
    sr_star = np.sqrt(2 * np.log(num_trials)) * (1 - gamma / np.log(num_trials))

    # Standard error of SR
    sr_se = np.sqrt((1 + 0.5 * sr**2 - skew(returns) * sr +
                     (kurtosis(returns) - 3) / 4 * sr**2) / T)

    dsr = (sr - sr_star) / sr_se

    return dsr
```

**Integration:** Add to src/backtesting/validation_metrics.py

#### 06-NEW-03: Failure Mode Matrix Verification

**47 failure modes from ARGUS_PROP_FIRM_FAILURES:**

| Category | Count | Key Modes |
|----------|-------|-----------|
| Trail DD | 4 | DD-01 to DD-04 |
| Time Gates | 4 | TG-01 to TG-04 |
| Risk | 4 | RK-01 to RK-04 |
| Technical | 4 | TC-01 to TC-04 |
| Automation | 4 | AU-01 to AU-04 |
| Consistency | 4 | CN-01 to CN-04 |
| Capital | 4 | CP-01 to CP-04 |
| + 19 more | 19 | Various |

**Deliverable:** `orchestration/FAILURE_MODE_MATRIX.md`

### Phase 06 GO/NO-GO Gate (Updated)

**Criteria (ALL must pass):**
| Metric | Threshold | Source |
|--------|-----------|--------|
| WFE | >= 0.6 | CLAUDE.md |
| SQN | >= 2.0 | CLAUDE.md |
| PSR | >= 0.85 | CLAUDE.md |
| **DSR** | **> 0** | **ARGUS (NEW)** |
| **PBO** | **< 25%** | **ARGUS (NEW)** |
| MC95DD | < 4% | CLAUDE.md (Apex) |
| Min Trades | >= 200 | ARGUS + CLAUDE.md |

---

## Phase 07: Paper Trading - ENHANCED

### Duration
Minimum 2 weeks with live data feed, no real money.

### Additional Testing (From ARGUS)

#### 07-NEW-01: Execution Mode Testing

**Test Both Modes:**
| Mode | Test | Expected |
|------|------|----------|
| AUTO | Full execution flow | Orders submitted |
| SIGNAL_ONLY | Alert generation only | No OrderSubmit calls |

**Verification:**
```python
# Week 1: AUTO mode
config.execution_mode = ExecutionMode.AUTO
# Verify orders are submitted correctly

# Week 2: SIGNAL_ONLY mode
config.execution_mode = ExecutionMode.SIGNAL_ONLY
# Verify only alerts are generated
```

#### 07-NEW-02: Time Gate Live Verification

| Test | Criterion |
|------|-----------|
| 4:30 PM ET block | New trades blocked |
| 4:55 PM ET emergency | Close initiated |
| 4:59 PM ET deadline | Position flat |
| DST transition | Correct offset |
| Clock drift | < 1 second |

#### 07-NEW-03: HWM Tracking Verification

| Check | Expected |
|-------|----------|
| Uses BID for longs | Conservative unrealized |
| Uses ASK for shorts | Conservative unrealized |
| Never uses MID | Prevents artificial HWM inflation |
| Tick-by-tick updates | HWM never decreases |

### Phase 07 GO/NO-GO Gate (Updated)

**Criteria:**
- [ ] No critical issues in 2 weeks
- [ ] All time gates verified
- [ ] HWM calculation verified (BID/ASK)
- [ ] Latency within budget (< 50ms)
- [ ] **Both execution modes work** (NEW)
- [ ] **47 failure mode checks pass** (NEW)

---

## Phase 08: Production Readiness (1 week)

### 08-01: External CRITIC Review
- Fresh context, no prior bias
- Review all validation artifacts
- Catch blind spots

### 08-02: SENTINEL Final Approval

**Apex Compliance Checklist:**
- [ ] Trailing DD < 5% from HWM
- [ ] Daily DD < 3% halt
- [ ] Close all by 4:59 PM ET
- [ ] Block new trades after 4:30 PM ET
- [ ] Emergency close from 4:55 PM ET
- [ ] HWM uses BID/ASK (not MID)
- [ ] Broker-side SL as backup
- [ ] **30% per-trade limit enforced** (NEW)
- [ ] **5:1 R:R verified** (NEW)
- [ ] **Automation prohibition understood** (NEW)

### Phase 08 GO/NO-GO (FINAL GATE)

| Check | Status |
|-------|--------|
| CRITIC review: No critical issues | [ ] |
| SENTINEL approval obtained | [ ] |
| All validation metrics GREEN | [ ] |
| Paper trading PASSED | [ ] |
| Deployment checklist COMPLETE | [ ] |

---

## Success Metrics (Updated - ARGUS Integrated)

| Metric | Threshold | Source | Status |
|--------|-----------|--------|--------|
| WFE | >= 0.6 | CLAUDE.md | Original |
| SQN | >= 2.0 | CLAUDE.md | Original |
| PSR | >= 0.85 | CLAUDE.md | Original |
| **DSR** | **> 0** | **ARGUS** | **NEW** |
| **PBO** | **< 25%** | **ARGUS** | **NEW** |
| MC95DD | < 4% | CLAUDE.md | Original (Apex) |
| Min Trades | >= 200 | ARGUS + CLAUDE.md | Original |
| Min Years | >= 5 | ARGUS | Original |
| Holdout | Positive | CLAUDE.md | Original |

---

## Hard Exit Criteria (Updated)

| Gate | Condition | Action |
|------|-----------|--------|
| **Phase 00-A** | **EMA > SMC by any margin** | **STOP or PIVOT** (NEW) |
| Phase 00-B | Bugs cannot be fixed after 2 weeks | STOP or PIVOT |
| Phase 01 | < 50 trades after fix | Trigger Plan B |
| Phase 02 | WFE < 0.3 on development set | STOP |
| Holdout | Negative return on 2021-2025 | STOP |
| Any | Engineering hours > 400 with no progress | HARD PAUSE |
| Any | Franco loses interest | STOP |

**Fallback Options (from DAEMON):**
1. Higher timeframe SMC (H4/D1 where ICT designed it)
2. Different market (NQ/ES futures)
3. Simple trend following
4. Manual discretionary trading (14 signals/year is manageable)
5. Buy existing EA ($100-$500)

---

## What We're KEEPING

| Component | Status | Rationale |
|-----------|--------|-----------|
| All 9 confluence factors | ENABLED | Fix bugs first |
| AdaptiveEVRouter | DISABLED (not archived) | Preserve optionality |
| StrategySelector | ENABLED | Validate gates |
| TREND_FOLLOW | TO VALIDATE | Diversification |
| MEAN_REVERT | TO VALIDATE | Test empirically |
| All SMC indicators | ENABLED | Core to strategy |
| **Execution modes** | **BOTH** | **PA/Live compliance** (NEW) |

---

## Simplification is PLAN B

**Trigger Conditions:**
| Gate | Condition | Action |
|------|-----------|--------|
| Phase 00-A | SMC < EMA | STOP or reconsider |
| Phase 00-B | < 5 factors fire after fix | Investigate, then Plan B |
| Phase 01 | < 50 trades after fix | Trigger Plan B |
| Phase 02 | WFE < 0.5 | Trigger Plan B |
| Phase 02 | Holdout WFE < 0.3 | Trigger Plan B |
| Any | SMC < EMA baseline by 20%+ | Trigger Plan B |

**Plan B Steps (from 08-SIMPLIFICATION_PLAN.md):**
1. Reduce factors from 9 to 3-4
2. Set non-contributing factors to weight 0
3. Lower threshold to 50
4. Archive AdaptiveEVRouter
5. Simplify StrategySelector to 2 gates

---

## New Deliverables (ARGUS-Driven)

| Phase | Deliverable | Content |
|-------|-------------|---------|
| 02 | `LOOKAHEAD_CHECKLIST.md` | 17 patterns with grep commands |
| 02 | `NAUTILUS_CONFIG_AUDIT.md` | Bar config verification |
| 02 | `HWM_PROTECTION_DESIGN.md` | Scale-out logic |
| 06 | `FAILURE_MODE_MATRIX.md` | 47 failure modes mapped |
| 06 | `validation_metrics.py` | PBO/DSR implementation |
| 07 | `EXECUTION_MODE_TEST.md` | AUTO vs SIGNAL_ONLY results |

---

## Agent Responsibilities

| Phase | Lead Agent | Support Agents |
|-------|------------|----------------|
| 00-A | ORACLE | DAEMON |
| 00-B | FORGE | - |
| 01 | ORACLE | FORGE |
| 02 | ORACLE | CRUCIBLE, **ARGUS** |
| 03 | CRUCIBLE | ORACLE, FORGE |
| 04 | FORGE | SENTINEL |
| 05 | ORACLE | CRUCIBLE |
| 06 | FORGE | SENTINEL, **ARGUS** |
| 07 | SENTINEL | CRITIC |

---

## Risk Mitigation (Updated)

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Semantic fix doesn't restore OB/FVG | MEDIUM | HIGH | Diagnostic logging |
| Trade clustering unsolvable | LOW | HIGH | State management investigation |
| Fixed system < 50 trades | MEDIUM | HIGH | Plan B (simplification) |
| SMC fundamentally flawed | LOW | HIGH | **Baseline comparison FIRST** |
| Timeline > 11 weeks | MEDIUM | MEDIUM | 50% buffer |
| **Look-ahead bias undetected** | MEDIUM | **CRITICAL** | **17-pattern checklist** (NEW) |
| **PA/Live automation ban** | **HIGH** | **MEDIUM** | **Execution modes** (NEW) |

---

## Appendix: ARGUS Research Summary

### From ARGUS_PROP_FIRM_FAILURES
- 47 failure modes identified
- Automation prohibited on PA/Live
- 30% per-trade loss limit
- 5:1 R:R enforcement
- HWM tracks unrealized peaks

### From ARGUS_LOOKAHEAD_DETECTION
- 17 look-ahead patterns cataloged
- NautilusTrader config requirements
- PBO < 25% and DSR > 0 thresholds

### From DAEMON_FUNDAMENTAL_REVIEW
- Economic ROI concerns addressed with baseline test
- SMC crowding acknowledged
- Hard exit criteria added

---

## Appendix: DAEMON Economic Concerns

DAEMON raised:
- Expected value: ~$11.67/hour at 300 hours invested
- SMC crowding: patterns widely known
- Opportunity cost: alternatives may have better ROI

**Resolution:**
- Added Phase 00-A baseline test to validate thesis
- If SMC < EMA: STOP immediately
- User aware of opportunity cost, proceeding for learning value
- Hard exit gate at 400 hours

---

*"A 9-factor confluence system where 8 factors score zero is BROKEN, not sophisticated. Fix the foundation before deciding to remove floors. But verify the foundation is worth fixing FIRST."*

---

**AGENT:** FORGE-NAUTILUS (acting as MASTER PLANNER)
**VERSION:** 2.0 (ARGUS-Integrated)
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE - READY FOR EXECUTION

---

*End of Roadmap*
