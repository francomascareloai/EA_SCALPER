# Phase 12 CRITIC Review

**Date:** 2025-12-25
**Reviewer:** CRITIC Agent (Adversarial)
**Verdict:** NO-GO (requires fixes before execution)

---

## CRITICAL ISSUES (must fix before execution)

### 1. Selection Bias in 12-01 Invalidates the Gate
**File:** `12-01-PLAN.md`

`12-01-PLAN.md` runs stride 1 only for "TOP 10 configs" chosen after stride 5/10. That makes Spearman `rho(stride5,stride1)` artificially optimistic and the p-values meaningless.

**FIX:** Run stride 1 on the same full random sample used for correlation (or design a two-phase unbiased estimator).

---

### 2. Correlation Gate Uses PnL Ranking, but Pipeline Optimizes Other Metrics
**Files:** `00-MASTER.md`, `12-03-PLAN.md`

Pipeline ranks by `pnl` / `profit_factor` / `mc95_dd`. Validating rank preservation only for PnL does not prove preservation for DD/PF (which are the real Apex survival constraints).

**FIX:** Compute correlation for multiple metrics: PnL, maxDD, PF, trade_count.

---

### 3. Regime Evidence is Incomplete and Already Contradicts Core Claim
**File:** `00-MASTER.md`

In stride comparison, stride 5 is missing for P2 ("—"), and P3 shows stride 5 at +40% error vs stride 1. Claiming "stride 5 best proxy" on one week (P1) is not a safe foundation.

**FIX:** Run stride 5 for ALL periods. Expand to more than 3 weeks.

---

### 4. No Explicit "Train vs Test" Separation → Selection-on-Test Leakage
**Files:** `12-01-PLAN.md`, `12-03-PLAN.md`

Plans treat P1/P2/P3 as "validation periods" but also use them to *select* finalists. That is optimization on the evaluation set (classic overfitting).

**FIX:** Separate train periods (for ranking/filtering) from holdout periods (for final validation).

---

### 5. Sensitivity Score Definition is Mathematically Unstable
**File:** `12-02-PLAN.md`

Uses `%` deltas with denominators like `pnl_fine` and `trades_fine` (can be 0 or near 0; PnL can be negative). Creates divide-by-zero and sign/pathology issues.

**FIX:** Use symmetric measures: `abs(a-b)/max(eps, abs(a), abs(b))`. Handle trades=0 explicitly.

---

### 6. Apex Kill-Switch Not Enforced as Hard Gate at Each Stage
**Files:** `00-MASTER.md`, `12-03-PLAN.md`

Plans do not specify "reject if trailing DD (HWM incl unrealized) ≥ 4.0% OR daily DD ≥ 3.0%" as a first-class elimination criterion.

**FIX:** Add absolute floor gates at EVERY stage: max trailing DD, max daily DD, min trades.

---

### 7. Pessimistic Execution Model is Underspecified
**File:** `12-04-PLAN.md`

Assumes "both SL and TP could have been hit in the bar" logic, but backtest is event/tick driven (Nautilus). If engine knows the path, this becomes double-counting.

**FIX:** Clarify whether stride sampling affects signal generation or just fill timing. Document data model.

---

### 8. 10,000-Config Stress Case Not Engineered
**Files:** `12-01-PLAN.md`, `12-03-PLAN.md`

With 10k configs: process overhead, disk IO, and RAM will explode unless batching/caching/resumption semantics are defined.

**FIX:** Add explicit resource controls: process pooling, batched persistence, compression.

---

## HIGH PRIORITY IMPROVEMENTS

1. **Redesign 12-01:** Run stride 1/5/10 for the *same* random sample, not conditioned on winners. Compute rho for multiple metrics.

2. **Add absolute floor gates:** Minimum trade count, maximum trailing DD buffer, maximum daily DD, and "no-trade configs are disqualified".

3. **Define Apex semantics in metrics:** Compute trailing DD from HWM including unrealized using conservative bid/ask pricing.

4. **Clarify data fidelity semantics:** Stride sampling affects *signal generation*, not just fills.

5. **Stress-proof persistence:** Explicit limits, compression, partitioning for 10k+ configs.

---

## MEDIUM PRIORITY SUGGESTIONS

1. Make sensitivity scoring robust to sign/zeros with symmetric measures
2. Expand regime coverage beyond 3 weeks (include volatility events)
3. Be explicit about Monte Carlo: specify sample size, perturbation model, compute budget

---

## ASSUMPTIONS TO VALIDATE

- [ ] Stride 5 preserves ranking OOS (rho stable across regimes and metrics)
- [ ] Coarse stride filtering doesn't bias toward Apex-risky configs
- [ ] Pessimistic fill adjustments consistent with tick-based data model
- [ ] Scale behavior at 10k configs is acceptable

---

## VERDICT: NO-GO

The concept (tournament + ranking preservation) is reasonable, but:

1. **Fatal statistical design flaw** (12-01 selection bias)
2. **Missing Apex-hard gating** at each stage
3. Unclear execution-model semantics
4. Poor stress readiness

If run as-is, high probability of building a pipeline that promotes artifacts and selects configs that blow up under stride 1 / live Apex rules.

---

## RECOMMENDED ACTION

Before executing Phase 12:

1. Fix 12-01 design to avoid selection bias
2. Add Apex DD gates to 12-03
3. Fix 12-02 math to handle edge cases
4. Clarify 12-04 data model
5. Add resource controls to 12-03

Then re-run CRITIC review for GO approval.
