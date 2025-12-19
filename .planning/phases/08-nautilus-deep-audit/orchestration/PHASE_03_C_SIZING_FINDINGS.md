# Phase 03C Findings: Sizing Stack (PositionSizer + SpreadMonitor + VaR)

**Scope:** Lot sizing realism, spread impact, VaR integration, per-trade loss buffers (25%/30%), fail-safe behavior.

**Files Reviewed:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/spread_monitor.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/var_calculator.py`

**Protocols Applied:**
- Protocol 0 (delegation): satisfied (this sub-agent read src files; orchestrator does not)
- Protocol 2 (CRITIC verification notes): included below
- Protocol 8 (Apex verification method): applied where relevant to sizing
- Protocols 11–14 (pattern/temporal/config + Apex prop-firm compliance): applied where relevant

---

## Executive Summary
The sizing stack is **modular and defensively coded at the arithmetic level** (division-by-zero guards, bounds, min/max clamps), but it is **not yet “Apex-realistic”** in three key ways:

1. **No explicit per-trade open-loss cap (Protocol 14C) nor 25% buffer**. This is a practical compliance requirement on Tradovate-style rulesets (e.g., $750 max open loss on a brand-new 50k via 30% × 2,500 threshold, and recommended 25% buffer). Nothing in `PositionSizer` enforces a currency max-loss limit per position.
2. **No VaR integration with sizing** (Protocol 14J / risk realism). VaR exists as a standalone calculator but is not used to adjust risk%/lot, and its failure modes (insufficient data) are not specified as “fail-safe conservative default.”
3. **Spread monitoring has unit inconsistencies and startup fail-open behavior** which can under-block during the very regimes where spread risk matters most (news spikes, illiquidity). Spread calculations appear tuned to match unit tests rather than preserve an unambiguous “points vs pips” contract.

Net effect: even if other modules (PropFirmManager/DD stack) are correct, this stack contains **multiple integration-footguns** where a caller can inadvertently size trades too large, trade during high-spread conditions, or bypass risk constraints via exceptions.

---

## Issue List (with Severity)

### CRITICAL (Blockers)

**C-01 — Missing explicit 30% per-trade open-loss cap (+ 25% buffer)**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- **What:** Sizing is based on `risk_amount = balance * risk_percent` and `lot = risk_amount / (SL_pips * pip_value)`.
- **Why it matters:** Protocol 14C requires enforcing **max open loss per trade**, derived from profit balance (or trailing threshold when profit is zero) and recommended **buffer to 25%**. This is not equivalent to a fixed risk percent.
- **Failure mode:** Strategy can size a trade that respects % risk but violates per-trade open-loss cap under Apex/Tradovate policy interpretations.
- **Status:** NOT IMPLEMENTED in this module.

**C-02 — Drawdown buffer thresholds not enforced at sizing layer (risk of nonzero lot at 4.0% trailing zone)**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- **What:** Drawdown throttling uses `dd_soft=0.03` (halve risk) and `dd_hard=0.05` (quarter risk). There is no “return 0 lot” hard block at 4.0% trailing or 4.5% total buffer.
- **Why it matters:** Project’s core dd_limits and Protocol 14A require **HALT at 4.0% trailing** and **HALT at 4.5%** (safety buffer). If upstream gating is bypassed/miswired, this sizer still returns lots.
- **Status:** NOT ENFORCED here; depends on other modules.

### HIGH

**H-01 — Spread unit conversion is ambiguous and can misclassify conditions**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/spread_monitor.py`
- **What:** Tracks `spread_points = (ask-bid) * pip_factor`, then converts to `current_pips` via conditional heuristics, and returns `average_spread`, `max_spread`, `min_spread` as `*10` scaled values.
- **Why it matters:** Any ambiguous “points vs pips” contract risks under-blocking under news/illiquid spreads (Protocol 14G/J). A max spread threshold (e.g., 50 pips) must be compared against a correctly defined unit.
- **Failure mode:** A 100–200 pip spike could be incorrectly computed as <50 (or vice versa), allowing trades when they should be blocked.

**H-02 — Startup warm-up is fail-open for ~10 samples**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/spread_monitor.py`
- **What:** If `n < 10`, snapshot is `NORMAL`, `can_trade=True`, multiplier 1.0.
- **Why it matters:** On live start/reconnect, the “first trades” are often the most dangerous (spreads unstable). A safety-first system typically treats missing spread history as “unknown → cautious,” not “unknown → full size.”

**H-03 — Rate limiting can return stale snapshot during rapid spread widening**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/spread_monitor.py`
- **What:** If `elapsed < update_interval`, returns cached snapshot.
- **Why it matters:** During news, spread can widen within seconds. If `update_interval` is configured >0, cached “NORMAL” could persist while spread becomes EXTREME.

**H-04 — VaR failure modes are exception-based, not fail-safe conservative defaults**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/var_calculator.py`
- **What:** Raises `InsufficientDataError` if fewer than `min_observations` returns.
- **Why it matters:** Protocol 14 expects risk systems to fail-safe when data missing. A raised exception can become a “silent bypass” if caught incorrectly (e.g., ignore VaR and trade) or a crash.

### MEDIUM

**M-01 — PositionSizer uses `balance` (not equity) and ignores costs (commission/spread/slippage)**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- **Impact:** Unrealized P/L and trading costs change true risk and can influence trailing DD dynamics. Using balance may understate risk mid-session.

**M-02 — Min-lot enforcement can force trading when risk budget implies “skip”**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- **What:** `_normalize_lot` enforces `min_lot` for any positive computed lot. If computed lot is extremely small (e.g., due to huge SL or tiny risk%), it will still trade `min_lot`.
- **Why it matters:** In a strict risk framework, “too small to trade safely” should result in **0** (no trade), not minimum.

**M-03 — VaR quantile selection is coarse (no interpolation) and CVaR tail selection is strict `<`**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/var_calculator.py`
- **Impact:** Can under/overestimate VaR/CVaR slightly depending on sample size; not necessarily a blocker but matters for risk controls.

**M-04 — Parametric VaR confidence mapping uses nearest predefined z-score**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/var_calculator.py`
- **Impact:** For unusual confidence levels, using nearest match can understate risk; should be documented if used.

### LOW

**L-01 — Minor comment inconsistency on drawdown throttle**
- **Where:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- **What:** Comment suggests “75% cut beyond 5% DD” but `dd_hard` defaults to 5% while throttle cuts to 25% of risk (correctly a 75% cut). The wording implies “beyond 5%” whereas 5% is already termination under Apex.

---

## Apex / Tradovate Compliance Mapping (Sizing-Relevant)

### Protocol 14C — 30% Per-Trade Loss Rule
- **Required:** Max open loss = 30% of profit balance, and **buffer to 25%** recommended; special handling for new accounts (use trailing threshold as base).
- **Found in reviewed files:** NOT FOUND.
- **Risk:** A “% risk” model can still violate a “max open loss” policy if profit balance is low.

### Protocol 14J — Slippage Buffer Requirements
- **Required:** Size for 150% of planned SL (or stricter) in normal conditions; larger buffers or no trade around news.
- **Found:** NOT FOUND in sizing formulas.
- **Related:** SpreadMonitor exists but is not tied to sizing and uses ambiguous units.

### Buffer Thresholds (from CLAUDE.md dd_limits)
- **Required:** Trailing DD ≥ 4.0% → HALT; ≥ 4.5% → HALT; 5% → terminated.
- **Found in sizing:** Only soft throttling at 3% and 5% via caller-supplied `current_drawdown_pct`.
- **Verdict:** Sizer alone is insufficient; must rely on gatekeeper.

---

## Fail-Safe / Fail-Open Assessment

### PositionSizer
- **Good:** returns 0 if `balance <= 0` or invalid SL/pip; clamps risk%.
- **Concern:** raises `ValueError` when required args missing; if unhandled, may crash caller.
- **Concern:** min-lot enforcement can force trades.

### SpreadMonitor
- **Good:** absolute block at `max_spread_pips` and extreme ratio block.
- **Concern:** warm-up allows full trading; missing-data is not treated conservatively.
- **Concern:** update_interval caching can stale decisions.
- **Concern:** unit conversion heuristics create correctness risk.

### VaRCalculator
- **Good:** explicit insufficient-data exception; avoids silent garbage.
- **Concern:** without an enforced caller contract (“exception → no trade”), this becomes a bypass/crash risk.

---

## Integration Gaps (Key)
1. **No explicit call chain** connecting `SpreadMonitor.get_size_multiplier()` into `PositionSizer.calculate_lot()`.
2. **No explicit call chain** connecting VaR/CVaR into risk% or lot multipliers.
3. **No unified “risk budget” abstraction** incorporating: SL distance, slippage buffer, spread cost, commission, and per-trade open loss cap.

Given the plan’s Step 2 “Integration verification,” these should be treated as **open questions** until verified in `prop_firm_manager` / strategy code.

---

## Recommendations (Non-code, audit output)
- Treat missing per-trade open loss cap (25%/30%) as a **blocker** for live/Apex compliance until confirmed elsewhere.
- Require an explicit unit contract for spread (define “points” and “pips” for XAUUSD and enforce consistently).
- Require “exceptions → no-trade” semantics in gatekeeper: any error in spread/VaR/sizing must return can_trade False / size 0.

---

## CRITIC Self-Review Notes

### Verification
- Sequential thinking thoughts used: 12
- Adversarial techniques applied: INVERSION, PRE-MORTEM, EDGE CASE STRESS, APEX-TRAP framing

### Techniques Applied (with examples)
1. **INVERSION**: Asked “How could this sizing stack accidentally allow a trade that blows compliance?” → found min-lot forcing + missing hard-halt at 4.0% trailing, and warm-up fail-open in spread gating.
2. **PRE-MORTEM**: Simulated CPI/NFP spread spike while `update_interval` caches snapshot → trade allowed with stale NORMAL status; plus unit conversion ambiguity could misread spread vs max threshold.
3. **EDGE CASE STRESS**:
   - `stop_loss_pips <= 0` → returns 0 (good).
   - Very small computed lot (risk budget tiny) → normalized to min lot (risk of forced trade).
   - VaR with 29 observations → exception; if caller ignores exception and trades, VaR constraint silently absent.
4. **APEX-TRAP framing**: Checked whether sizing honors “buffer before termination” behaviors (4.0%/4.5%) and Tradovate per-trade open loss cap; both not present.

### Issues Found During Self-Review
1. Potential overreach: per-trade loss rule may be enforced elsewhere. Mitigation: report as “NOT FOUND IN THESE FILES” and tag as integration dependency.
2. Spread unit concerns: may be intentionally test-driven. Mitigation: classify as HIGH because compliance depends on correct max-spread interpretation.

### Assumptions Challenged
1. **Assumption:** Upstream gatekeeper blocks trading at 4.0% trailing.
   - **Challenge:** If any direct call to PositionSizer exists, it can still size trades.
   - **Conclusion:** Sizer must not be relied on for hard-halts; integration must be verified.
2. **Assumption:** Spread pips conversion is correct for XAUUSD.
   - **Challenge:** Heuristic conversions and `*10` scaling suggest inconsistency.
   - **Conclusion:** Needs explicit unit contract and verification.

### Confidence Level
MEDIUM — Confident about what is/ isn’t present in these files; integration behavior depends on other modules not reviewed in Phase 03C.
