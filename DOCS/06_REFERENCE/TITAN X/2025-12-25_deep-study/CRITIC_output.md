CRITIC ADVERSARIAL REVIEW
==========================
Artifact: Titan_X.md
Type: plan/strategy reference (grid/cost-averaging system)
Reviewer: CRITIC v1.3
Mode: EXTERNAL-CRITIC

VERDICT: BLOCKED

KEY_CLAIM
- “Risk controls” (EP/Yoga/Lipo/Amp/Managers/News/Schedule) make a cost-averaging ladder viable for prop firm rules.

NULL_HYPOTHESIS
- Most of the apparent edge is mean-reversion + simulation artifacts; tail risk is not capped, only deferred, and will fail under hostile execution + Apex trailing DD from HWM.

FASTEST_DISPROOF_TEST
- Run a minimal grid-like baseline on our XAUUSD dataset with hostile execution + Apex trailing DD (HWM includes unrealized). If survival collapses (MC95DD > 4% or frequent termination), the “risk-control” narrative is false.

CRITICAL ISSUES (must fix before adopting any idea)
--------------------------
1) Negative convexity: cost averaging + lot multipliers
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/Titan_X.md:27-35
   Impact: In sustained trends, exposure grows as price moves against you; losses accelerate nonlinearly.
   Fix: For our system, forbid averaging into losers (or cap to 1 re-entry max) and enforce per-trade/position hard loss caps.

2) “Hedge” that can itself cost-average (TT Type=CA)
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/Titan_X.md:429-437
   Impact: A purported hedge can become another ladder; TT SL can be ignored; worst-case doubles down into tail events.
   Fix: Any hedge must have a hard, independent stop and bounded size; no averaging in hedge leg.

3) News protection can delete TP/SL around events
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/Titan_X.md:500-503
   Impact: Removing TP/SL near news concentrates risk exactly when gaps/slippage/spreads peak; calendar/GMT errors can shift the unsafe window.
   Fix: Never remove protective exits in high-uncertainty windows; instead: block new trades + flatten exposure earlier.

HIGH ISSUES
-----------
1) Psychological trap: “breathing room/runway” framing
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/Titan_X.md:319-340
   Impact: Normalizes holding losers and increasing exposure; creates escalation-of-commitment bias.
   Fix: Reframe as a hard risk budget with fail-closed halts.

2) Overfitting surface area: too many knobs
   Location: Multiple sections (Basic/Entry/DD Mgmt/News/Schedule)
   Impact: Parameter search can always find a set-file that worked on a slice (selection bias).
   Fix: Enforce minimal DOF: ≤5 tunables; use walk-forward + permutation/shift tests.

3) Backtest artifact admission (pair ordering sensitivity)
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/Titan_X.md:101-103, 525-528
   Impact: Indicates simulation instability; “Ghost Trades” results may be tester-sequencing noise.
   Fix: Treat as non-evidence; require independent, event-driven simulation.

STRESS TEST (what breaks first)
-------------------
- Volatile trend: tight initial spacing + lagging ATR step → rapid level accumulation before “dynamic” adapts.
- Gap/news spike: spread 3x + slippage 5x + calendar offset errors → forced liquidation at worst prices.
- Low liquidity/widening spreads: spread filter skips new entries while trapped in existing exposure; exits degrade.
- Whipsaw: bidirectional ladders can have both sides in DD if volatility expands around a drifting mean.

DO RISK CONTROLS CAP TAIL RISK?
-------------------------------
No. Most controls are threshold-triggered liquidation or “manage longer” (Yoga) rather than true bounding of worst-case loss. Gap-through and HWM-based trailing DD mean a single adverse event can exceed buffers regardless of the number of “managers”.

FALSIFICATION-FIRST TEST PLAN (on our data)
------------------------------------------
1) ghost_test (attribution): Replace entry logic with random entries, keep all “risk controls”. If performance/survival similar → entries are placebo.
2) monte_carlo_survival: Inject spread×{2,3}, slippage×{3,5}, latency×{5,10}; compute survival rate under Apex trailing DD + MC95DD. PASS requires MC95DD < 4% and termination probability ~0.
3) shifted_levels: Randomly offset pip-step/TP levels (bounded). If metrics unchanged → precision claims are illusory.
4) Regime slices: 2008, 2020, 2022 volatile windows vs quiet ranges; require stability across regimes.

DISCOVERY MODE: 2 credible alternatives
--------------------------------------
A) Bounded-loss scalper (single entry + hard SL + time gate + spread block). Upside: true tail cap; Apex-aligned. Risk: lower win rate. Fast falsification: 1-year slice net expectancy after hostile costs.
B) Pyramiding-only (scale in only when in profit). Upside: avoids averaging into losers. Risk: chop sensitivity. Fast falsification: range-regime DD frequency > 3% ⇒ reject.

MANUAL VERIFICATION NEEDED
--------------------------
[ ] Confirm how our Nautilus execution model treats spread/slippage at news (worst-case fills).
[ ] Define exact Apex trailing DD/HWM computation with conservative bid/ask marking.

CONFIDENCE: HIGH
Reason: The doc’s core mechanism is negative convexity (averaging down) and multiple sections explicitly trade off safety for “recovery”, which is incompatible with strict HWM-based trailing DD.
