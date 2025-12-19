# Phase 01 Findings: Core Strategy Audit

## Executive Summary
Phase 01 audited the core strategy stack for the Nautilus gold scalper with emphasis on: (1) Apex/Tradovate compliance (time gates, trailing DD/HWM), (2) lifecycle safety (`on_stop` cleanup), (3) temporal correctness (no look-ahead), and (4) explicit tracing of how OB/FVG outputs are consumed and whether “bar-closed” semantics / confirmation lag are enforced.

**Net result:** the strategy uses `bar.ts_event` (bar close) consistently for most decision points, but there is **1 CRITICAL Apex compliance violation** in the base class: mark-to-market equity uses **MID** pricing for unrealized PnL, which can artificially inflate HWM and distort trailing DD enforcement.

## Files Analyzed
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`: COMPLETE (targeted reads + grep due to size)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`: COMPLETE
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py`: COMPLETE

## Issues Found

### CRITICAL
1. **Apex HWM price-basis violation (MID mark-to-market) in base strategy drawdown path.**
   - Location: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:690`
   - Evidence: `_compute_equity_from_tick()` computes `mid = (bid+ask)/2` and uses MID for unrealized PnL.
   - Impact: Violates project “HWM trap” defense rules (LONG must use BID, SHORT must use ASK). MID can inflate unrealized PnL → inflate HWM → raise trailing floor → premature Apex termination.
   - Integration: `BaseGoldStrategy.on_quote_tick()` updates `_drawdown_tracker` using `_compute_equity_from_tick` (`base_strategy.py:324` → `base_strategy.py:339`). In `GoldScalperStrategy.on_quote_tick`, `super().on_quote_tick(tick)` runs first (`gold_scalper_strategy.py:1845`), so the drawdown tracker can be fed MID-based equity even though the child strategy defines a conservative `_compute_equity_from_tick` override (`gold_scalper_strategy.py:1956`).

### HIGH
1. **Daily reset semantics claim “midnight ET” but timer is not ET-anchored.**
   - Location: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:156`
   - Impact: Counters for daily DD / daily trades / consistency may drift vs ET trading day.

2. **`StrategySelector` session detection uses UTC hour buckets (DST and broker offset risk).**
   - Location: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py:266`
   - Impact: “Asian/London/NY” gating can be wrong, affecting when trading is permitted.

3. **Time-gate enforcement correctness depends on external manager (not auditable in Phase 01 files).**
   - Locations where enforced: `gold_scalper_strategy.py:981`, `gold_scalper_strategy.py:1853`
   - Impact: 4:55 emergency close behavior and 4:59 must-be-flat cannot be confirmed here.

### MEDIUM
1. **OB/FVG consumed without explicit confirmation lag beyond bar-close semantics.**
   - Production: MTF updates on M15 bar close (`gold_scalper_strategy.py:890` → `gold_scalper_strategy.py:901`, `gold_scalper_strategy.py:908`).
   - Consumption: passed into confluence scorer (`gold_scalper_strategy.py:1592`).
   - Refresh: LTF refresh every 20 bars runs detectors on `self._ltf_bars[-200:]` (`gold_scalper_strategy.py:1559`, `gold_scalper_strategy.py:1568`).
   - Risk: If design expects “wait N bars after detection,” it is not enforced in these files.

2. **Potential optimistic execution if engine fills at bar close while signals use `bar.close`.**
   - Locations: `gold_scalper_strategy.py:927`, `gold_scalper_strategy.py:1603`

3. **Selector DD thresholds appear FTMO-like and may diverge from Apex taxonomy/buffers.**
   - Location: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py:249`

### LOW
1. **Naming drift:** `_mtf_order_blocks` / `_mtf_fvgs` are refreshed from LTF history (confusing intent).
   - Location: `gold_scalper_strategy.py:1559`

2. **Direct `datetime.now(timezone.utc)` usage in selector harms determinism and testability.**
   - Location: `strategy_selector.py:268`

## Checklist Results

### Look-Ahead Bias Patterns
- `bar.close` usage: PASS (bar-close timestamp used widely; e.g. `gold_scalper_strategy.py:932`)
- `bars[-1]` usage: PASS with caveat (relies on finalized bars; `gold_scalper_strategy.py:1735`)
- `.value[0]/.value[-1]` indexing: PASS (no matches found in `gold_scalper_strategy.py`)

### Trailing DD / HWM Verification
- Conservative unrealized pricing: FAIL in base class (CRITICAL), PASS in child override.
- HWM/floor math: NOT VERIFIED here (depends on `DrawdownTracker` / prop-firm manager modules).

### Time Gates
- New-trade block after cutoff: PARTIAL (present via `_time_manager.check(ts_event)`; manager not in scope).
- Emergency close 4:55 + flat by 4:59: PARTIAL (config exists; manager behavior not in scope).

## CRITIC Self-Review Notes

### Verification
- Sequential thinking thoughts used: 12
- MCP sequential-thinking tool invoked: YES
- Techniques applied (>=3): INVERSION, PRE-MORTEM, APEX TRAP, EDGE CASES

### Techniques Applied (with concrete examples)
1. **INVERSION**: Assumed OB/FVG and MTF logic leaks future data; traced all `bar.close` / `bars[-1]` uses. Found `self._ltf_bars[-1].close` in MTF manager call (`gold_scalper_strategy.py:1735`) but it is still bound to the last completed stored bar if Nautilus bar semantics are correct.
2. **PRE-MORTEM**: “Backtests pass but Apex account blows due to HWM trap.” This led directly to auditing tick-level equity computation and finding MID price basis (`base_strategy.py:690`).
3. **APEX TRAP**: Verified whether unrealized PnL is computed at conservative exit prices; child uses BID/ASK (`gold_scalper_strategy.py:1964`), base uses MID (FAIL).
4. **EDGE CASES**: Considered missing instrument, insufficient bars, existing position, spread blocks; these are generally guarded by early returns in `_check_for_signal` (`gold_scalper_strategy.py:941` onward).

### Assumptions Challenged (>=2)
1. Assumption: “Daily reset is midnight ET.” → Challenged by timer design (`base_strategy.py:156`), conclusion: ET anchoring not proven.
2. Assumption: “Session gating aligns with ET sessions.” → Challenged by UTC-only hour windows (`strategy_selector.py:268`), conclusion: DST/offset risk.

### Confidence Level: HIGH
High confidence on the MID/HWM violation and the OB/FVG consumption trace (direct file:line evidence). Medium confidence on exact time-gate enforcement because `TimeConstraintManager` internals are out of scope for Phase 01.

---

## Checkpoint Summary
### Phase: 01
### Status: COMPLETE
### Issues: 1 CRITICAL, 3 HIGH, 3 MEDIUM, 2 LOW
### Blocking: YES (CRITICAL Apex HWM price-basis violation)
### Next Phase Ready: NO (blocked until CRITICAL addressed)

Additional verification note: This findings document intentionally focuses on the three Phase 01 target files only; HWM floor math (HWM*0.95), per-trade loss buffers, and emergency force-close mechanics live in other modules (e.g., `DrawdownTracker`, prop-firm manager, `TimeConstraintManager`) and must be verified in later phases.
