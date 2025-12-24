## CRUCIBLE Output

AGENT: CRUCIBLE
VERSION: 4.2
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

# Mean Revert Research (Phase 04-01)

### Summary
Phase 04 decision is already **IMPLEMENT** (see `.planning/phases/09-strategy-activation/orchestration/PHASE_04_DECISION.md:5-12`). This document captures the repo-backed rationale, the concrete implementation shape already present in code, and the realism/validation gates required before we treat Mean Revert as a portfolio leg.

### Repo Evidence: What “Mean Revert” is in this codebase
- A dedicated, lightweight, backtest-safe Mean Revert signal generator exists: it produces deterministic candidates using **Bollinger Bands (SMA ± k·STD)** and **RSI (Wilder)**, explicitly stating “No look-ahead” and “current closed bar” as design goals (`nautilus_gold_scalper/src/signals/mean_revert.py:1-12`, `nautilus_gold_scalper/src/signals/mean_revert.py:96`).
- Candidate generation is gated by minimum history and basic safety defaults (e.g., `min_bars` and tick_size fallback) (`nautilus_gold_scalper/src/signals/mean_revert.py:98-104`).
- The current Mean Revert implementation is **opt-in** at strategy config level: `enable_mean_revert` defaults to `False` (`nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:125-133`).
- Mean Revert candidates are only generated when **both** the toggle is enabled and the StrategySelector chooses `STRATEGY_MEAN_REVERT` (`nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1583-1589`, `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1584`). This addresses the prior “misleading enum” risk noted in the decision record (`.planning/phases/09-strategy-activation/orchestration/PHASE_04_DECISION.md:15-16`).
- Mean Revert is treated as a first-class “arm” in the Adaptive router (for tracking/selection), and the router itself is explicitly “no look-ahead” by updating on realized trade close (`nautilus_gold_scalper/src/strategies/adaptive_router.py:1-10`, `nautilus_gold_scalper/src/strategies/adaptive_router.py:21-26`).

### XAUUSD Suitability (why Mean Revert is defensible)
XAUUSD can trend hard, but the codebase already treats mean reversion as a **regime-conditioned behavior**, not an always-on signal.
- Regime thresholds for “mean reverting” are explicitly modeled with Hurst < 0.45 (`nautilus_gold_scalper/src/validation/phases/phase_2.py:83-86`).
- Strategy selection routes to `STRATEGY_MEAN_REVERT` only when the context is classified as reverting; random-walk regimes are explicitly “no trade” (`nautilus_gold_scalper/src/strategies/strategy_selector.py:441-446`, `nautilus_gold_scalper/src/strategies/strategy_selector.py:468-472`).
- Session behavior is acknowledged: Asian session is blocked by default, with a narrow exception that allows Asian trading only for “prime reverting” (and with reduced size) (`nautilus_gold_scalper/src/strategies/strategy_selector.py:404-416`, `nautilus_gold_scalper/src/strategies/strategy_selector.py:408-410`).

### Implementation Shape (already encoded)
Current Mean Revert logic is intentionally minimal to reduce overfit surface:
- Entry triggers: price touching/overshooting BB extremes plus RSI oversold/overbought, with an ATR percentile ceiling acting as a “don’t fade volatility expansion” filter (`nautilus_gold_scalper/src/signals/mean_revert.py:86-95`, `nautilus_gold_scalper/src/signals/mean_revert.py:134-137`, `nautilus_gold_scalper/src/signals/mean_revert.py:166-169`).
- Risk primitive: the generator returns an `sl_distance` (computed from recent high/low and BB), allowing downstream execution to size/validate risk consistently (`nautilus_gold_scalper/src/signals/mean_revert.py:137-141`, `nautilus_gold_scalper/src/signals/mean_revert.py:169-172`).
- Integration: `GoldScalperStrategy` builds inputs from recent LTF bars, calls `generate_mean_revert_candidates(...)`, and may route Mean Revert through deterministic selection or the AdaptiveEVRouter (`nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1531-1539`, `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1586-1600`, `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1642-1666`).

### Realism / Bias Checklist (must pass; realism over results)
These are the non-negotiable realism constraints to treat backtests as meaningful:
- Dataset must remain the single canonical file for tests (`CLAUDE.md:61-64`).
- Apex constraints must be enforced in validation: trailing DD = 5% from HWM (includes unrealized), hard flat by 4:59 PM ET, block new trades after 4:30 PM ET, emergency close from 4:55 PM ET (`CLAUDE.md:66-70`).
- Anti-hallucination rule for this phase: don’t claim anything without command output; Phase 04 explicitly requires this deliverable + the decision record (`.planning/phases/09-strategy-activation/00-EXECUTION-GUIDE.md:20-31`, `.planning/phases/09-strategy-activation/00-EXECUTION-GUIDE.md:375-383`).
- Temporal correctness: Mean Revert generator claims “no look-ahead” by using the latest closed bar (`nautilus_gold_scalper/src/signals/mean_revert.py:8-11`). This is only valid if the bar feed itself is on-close; treat this as a verification gate (Execution Guide mandates showing actual verification outputs, not assumptions) (`.planning/phases/09-strategy-activation/00-EXECUTION-GUIDE.md:20-31`).
- Execution realism risk (XAUUSD): mean reversion performance is highly sensitive to spread-widening and stop distance. Before any “GO”, enforce an SL-vs-spread buffer (CRITICAL for MR) and avoid Asia except the explicit selector exception above (`nautilus_gold_scalper/src/strategies/strategy_selector.py:404-416`).

### Falsification-First (fast disproof tests specific to Mean Revert)
Adopt the same “kill bad ideas fast” posture already formalized in Phase 00 falsification guidance (`.planning/phases/09-strategy-activation/05-FALSIFICATION_TESTS.md:7-10`).
1) **Shifted Thresholds Test (Mean Revert)**: jitter BB/RSI thresholds (e.g., bb_k, rsi levels) and require performance + trade frequency to remain stable; if it collapses, precision is likely illusory.
2) **Ghost Test (Component Attribution)**: replace `generate_mean_revert_candidates` with a null/random candidate generator while keeping selector/session/risk gates identical; if results remain similar, the “signal” adds no edge and should be simplified/removed (pattern rationale: `.planning/phases/09-strategy-activation/05-FALSIFICATION_TESTS.md:27-31`).

### Recommendations (Decision already IMPLEMENT)
1. **CRITICAL:** Treat Mean Revert as a regime-conditioned leg only (already encoded by selector gating) and keep `enable_mean_revert=false` by default until ORACLE+SENTINEL validations clear (`nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:125-133`, `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1584`).
2. **HIGH:** Validate with the Phase 04 action plan: unit tests for deterministic series exist; run `mypy --strict`, `pytest -q`, and a 1-week quick backtest per decision record (`.planning/phases/09-strategy-activation/orchestration/PHASE_04_DECISION.md:8-13`, `nautilus_gold_scalper/tests/test_signals/test_mean_revert.py:12-47`).
3. **HIGH:** Enforce a spread-aware minimum stop distance for Mean Revert in evaluation (MR dies in realistic spread widening); treat this as a realism gate, not an optimization.

### Required Handoffs
| Agent | Purpose | Priority |
|-------|---------|----------|
| ORACLE | OOS + WFA + Monte Carlo; confirm MR adds edge beyond selector/session filters | HIGH |
| SENTINEL | Verify Apex time gates + trailing DD/HWM semantics remain safe when MR is enabled | HIGH |

### IMPORTANT
This is a PRELIMINARY assessment of implementation readiness and realism risks. Final GO/NO-GO (for trading) requires ORACLE + SENTINEL.
