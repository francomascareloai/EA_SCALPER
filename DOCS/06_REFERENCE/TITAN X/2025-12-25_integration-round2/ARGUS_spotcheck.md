AGENT: ARGUS
VERSION: 2.4
CLAUDE_MD_VERSION: 3.10.10
STATUS: COMPLETE

1) Risk properties of martingale/grid under fat tails + slippage
- Claim: Titan-style ladders (pip-step grid + lot multipliers + breakeven TP), even with ATR “Dynamic Pip Step”, spread filters, and DD “managers”, can be made acceptably safe.
- Verdict: LOW / NO-GO for Apex.
- Evidence (local): Vendor manual is built around lot-multiplier ladders and implies drawdown can be managed via spacing/filters (`/home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/Titan_X.md`). Project analysis flags this as negative convexity and explicitly Apex-incompatible (`/home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/SYNTHESIS_round2.md`).
- Fastest disproof test: Monte Carlo survival with heavy-tailed jumps + stochastic spread/slippage. Simulate a minimal ladder (pip-step, TP at breakeven+X, lot multiplier), and terminate if `equity < 0.95*hwm` with unrealized marked BID/ASK. Any non-trivial termination rate falsifies “safe enough”.
- Applicability to XAUUSD/Apex: XAUUSD has volatility clustering and jump risk; spread blowouts/slippage widen effective adverse excursion and reduce retracement odds. Lot multipliers amplify exposure exactly when tails arrive.

2) Best practices for prop-firm trailing DD from HWM
- Claim: Daily/weekly equity protectors + VPS-local-time schedules (incl. manual GMT offsets) are sufficient for trailing-HWM prop rules.
- Verdict: MEDIUM for principles (hard gates), NOT for time/offset approach.
- Evidence (local): Apex rules are path-dependent: HWM includes unrealized; winners raise the floor; strict ET gates required (`/home/franco/projetos/EA_SCALPER_XAUUSD/CLAUDE.md`, `/home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/SENTINEL_round2.md`).
- Fastest disproof test: Recompute HWM-based trailing floor on any equity path and count terminations that occur despite profitable endpoints; if >0 in volatile regimes, “protectors alone” is insufficient.
- Applicability to XAUUSD/Apex: Must be flat by 4:59 PM ET, block entries after 4:30 PM ET, force-close from 4:55 PM ET, and keep exits always allowed; anchor time to `America/New_York` with drift-aware degraded mode.

Next handoff: ARGUS → SENTINEL (define MC survival parameters + acceptance thresholds).
