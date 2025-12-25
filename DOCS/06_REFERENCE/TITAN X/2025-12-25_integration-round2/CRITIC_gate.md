CRITIC ADVERSARIAL REVIEW
==========================
Artifact: Integration Round 2 (CRUCIBLE/FORGE/SENTINEL/SYNTHESIS)
Type: plan/architecture/risk
Reviewer: CRITIC v1.3
Mode: EXTERNAL-CRITIC

VERDICT: BLOCKED
Reason: The Round 2 artifacts state the right intentions (no grid/martingale, exits never blocked, ET gates) but do not yet define enforceable invariants + temporal contracts + smallest disproof tests. These are the common paths to account-termination bugs.

CRITICAL ISSUES (must fix)
--------------------------
1) Grid/stacking can sneak back in via “volatility spacing/cooldown”
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/FORGE_round2.md
   Impact: “Spacing” can be implemented as “add after adverse move >= X” (grid with different words).
   Required invariant (must be testable):
   - XAUUSD: max concurrent positions = 1 (initially hard-capped).
   - Never open a new position while an existing position in the same symbol is losing.
   - Spacing may only filter independent signals, never trigger re-entry based on drawdown/adverse excursion.

2) Exits-never-blocked is asserted but not protected by an invariant test
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/FORGE_round2.md
   Impact: A unified “RiskPolicy/can_trade” often gates ALL orders; forced close can be blocked during news/time/DD overlap.
   Fix requirement: split control surface into at least:
   - can_open_new (gateable)
   - must_flatten (non-gateable, highest priority)
   And write a regression test that tries to close while entries are blocked.

3) “Profit-lock” is underspecified and can worsen Apex HWM trap
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/CRUCIBLE_round2.md
   Impact: Any mechanism that increases time-in-trade or lets winners run longer can inflate HWM and increase termination risk on reversals.
   Fix requirement: define the exact mechanism (tighten risk / partial scale-out / reduce exposure). Explicitly forbid “target expansion” style profit-lock.

HIGH ISSUES
-----------
1) Look-ahead risk in virtual gate + ATR/vol buckets
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/FORGE_round2.md
   Impact: Using current bar close/ATR for decisions on the same bar produces inflated backtests and live failure.
   Fix requirement: a temporal contract:
   - Decision at time T may only use data with timestamp < T.
   - If decisions occur on bar-close events, prove (via Nautilus semantics) that the event is strictly after bar completion.

2) ET time gates need an explicit “time source uncertainty” behavior
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/SENTINEL_round2.md
   Impact: clock drift/timezone errors can violate 4:59 PM ET flat rule.
   Fix requirement: mandate drift check + degraded earlier gates when drift unknown.

TEMPORAL CORRECTNESS CHECK
--------------------------
Data access points to audit: virtual gate state, ATR/volatility buckets, last_entry_time/price, news window timestamps, ET gate timestamps.
Status: FAIL (missing a written contract + verification of bar completion semantics).

FASTEST DISPROOF TEST PLAN (smallest-possible, do BEFORE coding)
---------------------------------------------------------------
1) Unit-level invariant test (no backtest):
   - Simulate: in_news_window=True + ts>=16:55 ET + trailing_dd_pct>=4.0% (or daily_dd_pct>=3.0%).
   - Assert: flatten/close orders are still emitted (exits never blocked), while new entries are blocked.

2) 1-hour survival-only backtest slice:
   - Choose a volatile intraday window; run with hostile execution multipliers (spread 2x, slippage 5x, latency 10x).
   - Compare baseline vs baseline+ONE guard (ExposureCap=1 OR NewsGuard entry-only OR Time gate enforcement).
   - Pass criteria: forced-flat by 16:59 ET always; trailing_dd never reaches 4.0% buffer; no “blocked exit” events.

3) Ghost test (edge attribution):
   - Randomize entries while keeping all guards.
   - If results are similar: the edge is not the signal; STOP and simplify before adding virtual gate complexity.

DISCOVERY MODE: 2 alternatives (credible)
----------------------------------------
A) Ship only hard safety layers first (time/news/exposure/DD tiers), no virtual gate.
   Upside: low look-ahead/overfit risk. Risk: fewer trades. Fast test: 1-week sample survival + trade count.

B) Replace ATR pacing with pure execution-quality pacing (spread/slippage/rejection based).
   Upside: targets real Apex blow-up modes. Risk: over-blocking. Fast test: news/vol days entry reduction + lower DD.

CONFIDENCE: MEDIUM
Reason: Plans are directionally correct but still missing the specific invariants/tests that prevent regressions into grid behavior or look-ahead bias.
