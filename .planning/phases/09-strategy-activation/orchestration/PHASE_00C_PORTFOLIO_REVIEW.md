# Phase 00-C: Portfolio Strategy Review (Retrofit)

**Date:** 2025-12-24
**Status:** COMPLETE (code analysis done, decisions locked)
**Purpose:** Lock portfolio decisions + falsification thresholds before deeper tuning / Phase 04+.

---

## 1) Context
- Franco reports Phase 03 already executed.
- Phase 00-C was added after-the-fact to prevent wasted effort optimizing redundant/correlated strategies.

**Rule:** Phase 00-C does **not** require re-running Phase 01–03. It gates what we do next.

---

## 2) Portfolio Diagnosis

### 2.1 Code Analysis Findings (2025-12-24)

**CRITICAL FINDING:** The original question "Are SMC_SCALPER and SCALPER functionally distinct?" is **MOOT**.

**Evidence from code:**
- `strategy_selector.py` → `StrategyType` enum contains:
  ```python
  STRATEGY_NONE = 0
  STRATEGY_TREND_FOLLOW = 2
  STRATEGY_MEAN_REVERT = 3
  STRATEGY_SMC_SCALPER = 4  # This is the ONLY scalper
  STRATEGY_SAFE_MODE = 5
  ```
- There is **NO separate "SCALPER"** strategy - only `SMC_SCALPER` exists.
- The plan's question was based on outdated terminology; consolidation is already done.

**Regime-to-Strategy Mapping (from `select_strategy()`):**
| Hurst Exponent | Strategy Selected |
|----------------|-------------------|
| H > 0.55 | TREND_FOLLOW |
| H < 0.40 | MEAN_REVERT |
| else | SMC_SCALPER (fallback) |

**Signal Routing (from `gold_scalper_strategy.py`):**
- `RouterArm.SMC` → SMC-based signals (OB/FVG/sweep)
- `RouterArm.TREND_PULLBACK` → Trend pullback entries
- `RouterArm.TREND_BREAKOUT` → Trend breakout entries
- `RouterArm.MEAN_REVERT` → Mean reversion entries

**Confluence Scoring (from `confluence_scorer.py`):**
- 9-factor system: structure, regime, session, OB, FVG, sweep, AMD, fib, MTF, footprint
- Session-specific weight profiles (ASIAN, LONDON, NY_OVERLAP, NY)
- OB/FVG scoring uses exact bounds: `ob.low_price <= price <= ob.high_price`

### 2.2 Redundancy / Correlation Risk
- ~~**High overlap expected:** `SMC_SCALPER` vs any "pure scalper" logic.~~ **RESOLVED**
- **No redundancy exists** - only one scalper implementation (SMC_SCALPER)
- Current risk: SMC_SCALPER is the fallback for undefined regimes (Hurst 0.40-0.55)

### 2.3 Regime Coverage Gaps
- We want clear coverage for:
  - **Trend regime** (H > 0.55) → TREND_FOLLOW ✓
  - **Range regime** (H < 0.40) → MEAN_REVERT ✓ (pending validation)
  - **Transition regime** (0.40 ≤ H ≤ 0.55) → SMC_SCALPER (fallback)
  - **Expansion / breakout regime** → NOT IMPLEMENTED (defer)

### 2.4 Apex / HWM Trap Exposure
- Biggest systemic risk is **HWM trailing DD including unrealized**.
- Strategies that "let winners run" without de-risk can blow accounts even with small final drawdown.

---

## 3) Decisions to Lock (Keep / Consolidate / Defer)

### Decision D1 — Consolidation
**Decision:** ALREADY CONSOLIDATED ✓
- Code analysis confirms: only `SMC_SCALPER` exists (no separate SCALPER)
- Current implementation is zone-based (OB/FVG bounds) with 9-factor confluence scoring
- **No action required** - consolidation was already done in codebase

**Status:** LOCKED (no change needed)

### Decision D2 — Additions (max 2, conditional)
**Decision:** DEFER (conditional)
- **Volatility Expansion Breakout**: defer until after Ghost Test + survival metrics.
- **Anchored VWAP mean-reversion**: defer; only add if we need a more robust MR anchor than SMC levels.

**What would change our mind:** if Phase 06 shows regime gaps (trend/range/expansion) where current strategies have poor coverage but an additive strategy improves portfolio survival with acceptable MC95DD.

### Decision D3 — Mean Reversion Strategy
**Decision:** VALIDATE FIRST (no commitment)
- Mean reversion stays as a candidate pending Phase 04 decision and Phase 06 metrics.

### Decision D4 — Apex/HWM Hard Requirements
**Decision:** NON-NEGOTIABLE
- Mandatory **de-risk in profit** (scale-out / tighten stops) and **time-based exits** near `4:55–4:59 PM ET`.

---

## 4) Falsification-First Tests (Required Next)
These are **cheap disproof tests**. If they fail, we simplify/pivot.

### Test T1 — Ghost Test (Null Signal)
**Claim being tested:** "SMC signal adds directional edge."

**Design:** Replace signal generation with random baseline; keep all filters/gates identical.

**Implementation (minimal code):**
```python
# In GoldScalperConfig, add:
enable_ghost_test: bool = False  # When True, replace signals with random

# In _check_for_signal(), modify signal generation:
if self.config.enable_ghost_test:
    # Ghost test: random direction, ignore confluence
    direction = random.choice([1, -1])  # 1=LONG, -1=SHORT
else:
    # Normal: use SMC/confluence signals
    direction = self._compute_signal_direction()
```

**Pass/Fail thresholds:**
| Metric | Ghost | Full | Verdict |
|--------|-------|------|---------|
| Sharpe | ≈ Full (Δ < 0.2) | - | Signals NOT adding edge → simplify |
| Sharpe | < Full (Δ > 0.3, p < 0.05) | - | Signals ADD edge → keep |
| Win Rate | ≈ Full (Δ < 5%) | - | Signals NOT adding edge |
| Win Rate | < Full (Δ > 10%) | - | Signals ADD edge |

**Fast disproof run:** 1 month data slice, 100 MC paths, target: 1 hour runtime.

### Test T2 — Shifted Levels (SMC precision)
**Claim:** "OB/FVG exact levels matter."

**Design:** Jitter OB/FVG levels by bounded random offset.

**Implementation (minimal code):**
```python
# In ConfluenceScorer, add:
level_jitter_pips: float = 0.0  # Default 0 (exact), set to 2.0 for shifted test

# In _score_order_blocks(), modify bounds check:
jitter = random.uniform(-self.level_jitter_pips, self.level_jitter_pips)
if (ob.low_price + jitter) <= current_price <= (ob.high_price + jitter):
    # score the OB
```

**Pass/Fail thresholds:**
| Jitter | Perf vs Exact | Verdict |
|--------|---------------|---------|
| ±$2 | ≈ Exact (Δ < 5%) | Precision is ILLUSION → use zones/bands |
| ±$2 | < Exact (Δ > 10%, p < 0.05) | Precision MATTERS → keep exact levels |

**Fast disproof run:** 2 weeks data, compare exact vs jittered, target: 30 min runtime.

### Test T3 — Apex HWM Survival (Monte Carlo survival)
**Claim:** "Current profile survives Apex trailing DD including unrealized."

**Design:** MC survival simulation under hostile slippage/spread conditions.

**Implementation:** Use existing `run_backtest.py` with Monte Carlo enabled.
```bash
python -m nautilus_gold_scalper.scripts.backtest.run_backtest \
  --monte-carlo-runs 1000 \
  --slippage-pips 0.5 \
  --spread-multiplier 1.5
```

**Gate thresholds:**
| Metric | Threshold | Status |
|--------|-----------|--------|
| MC95DD | < 4.0% | PASS (buffer before 5% Apex limit) |
| MC99DD | < 4.5% | PASS (extreme tail) |
| Survival Rate | > 95% | PASS (across 1000 paths) |
| Max Single Path DD | < 5.0% | PASS (no blown accounts) |

**CRITICAL:** Use conservative price basis (BID for LONG exit, ASK for SHORT exit) per CLAUDE.md HWM rules.

---

## 5) Next Steps (No re-run required)
1. Continue from Phase 03 state; do **not** re-run Phase 01–03.
2. Use this document to drive Phase 04 decisions (mean revert) and Phase 06 combined validation.
3. Run T1/T2/T3 before implementing new strategies or heavy refactors.

---

## 6) Summary Verdict
**Action:** Run Phase 00-C now (retrofit) and proceed.
- No rollback.
- No re-running earlier phases.
- Tighten decisions + thresholds before spending cycles.
