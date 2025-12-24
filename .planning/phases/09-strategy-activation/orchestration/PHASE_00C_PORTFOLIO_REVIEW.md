# Phase 00-C: Portfolio Strategy Review (Retrofit)

**Date:** 2025-12-24
**Status:** READY (retrofit after Phase 03 execution)
**Purpose:** Lock portfolio decisions + falsification thresholds before deeper tuning / Phase 04+.

---

## 1) Context
- Franco reports Phase 03 already executed.
- Phase 00-C was added after-the-fact to prevent wasted effort optimizing redundant/correlated strategies.

**Rule:** Phase 00-C does **not** require re-running Phase 01–03. It gates what we do next.

---

## 2) Portfolio Diagnosis
### 2.1 Redundancy / Correlation Risk
- **High overlap expected:** `SMC_SCALPER` vs any “pure scalper” logic.
  - Both live in the same microstructure regime where spread/slippage dominate.
  - Maintaining two versions tends to double down on the same risk.

### 2.2 Regime Coverage Gaps
- We want clear coverage for:
  - **Trend regime** → Trend-follow
  - **Range regime** → Mean-reversion (only if survives validation)
  - **Expansion / breakout regime** → dedicated breakout logic (optional)

### 2.3 Apex / HWM Trap Exposure
- Biggest systemic risk is **HWM trailing DD including unrealized**.
- Strategies that “let winners run” without de-risk can blow accounts even with small final drawdown.

---

## 3) Decisions to Lock (Keep / Consolidate / Defer)
### Decision D1 — Consolidation
**Decision:** CONSOLIDATE (default)
- Consolidate `SMC_SCALPER + SCALPER` into a single **microstructure scalper** profile.
- Keep it **zone-based + confirmation-based** (avoid precision theater) with strict gates.

**What would change our mind:** evidence that two implementations are **non-correlated** and both pass survival/robustness gates.

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
**Claim being tested:** “SMC signal adds directional edge.”

**Design:** replace signal generation with baseline/random; keep all filters/gates identical.

**Pass/Fail thresholds (fast):**
- If `Perf(Ghost)` ≈ `Perf(Full)` (within noise / not materially worse) → **signals are not the edge** → simplify or delete complex signal logic.
- If `Perf(Full)` materially outperforms Ghost (and survives bootstrap significance, p < 0.05) → **signal contributes** → keep, then run precision tests.

### Test T2 — Shifted Levels (SMC precision)
**Claim:** “OB/FVG exact levels matter.”

**Design:** jitter levels (bounded).

**Pass/Fail:**
- If `Perf(Exact)` ≈ `Perf(Shifted)` → precision is likely illusion → convert to zones/bands/anchors.
- If `Perf(Exact)` materially > shifted (p < 0.05) → precision matters → keep and harden.

### Test T3 — Apex HWM Survival (Monte Carlo survival)
**Claim:** “Current profile survives Apex trailing DD including unrealized.”

**Design:** MC survival under hostile slippage/spread.

**Gate:** prefer survival distributions; require **MC95DD < 4%** (buffer before 5%).

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
