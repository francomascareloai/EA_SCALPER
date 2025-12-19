CRITIC ADVERSARIAL REVIEW
==========================
Artifact: Phase 01 findings + core strategy architecture notes
Type: plan/strategy/code-review
Reviewer: CRITIC v1.2
Mode: EXTERNAL-CRITIC

VERDICT: NO-GO (for proceeding to Phase 02 R2 *as-if-unblocked*)

Rationale (blocking): Phase 01 correctly flags Apex-critical + temporal risks. Phase 02 R1 indicates OB/FVG modules are BLOCKED (look-ahead). Proceeding to R2 is only acceptable if R2’s explicit goal is to remediate/verify these blockers. Otherwise you are compounding architectural debt and can generate misleading backtest validation.

CRITICAL ISSUES (must fix)
--------------------------
1. Apex HWM price-basis violation in base mark-to-market
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:690
   Impact: MID pricing inflates/deflates unrealized PnL vs executable exit (BID/ASK). Inflated HWM ratchets trailing floor upward → account termination risk.
   Fix: Use conservative pricing (LONG=BID, SHORT=ASK) or delegate to position.unrealized_pnl at conservative price.

HIGH ISSUES
-----------
1. “Midnight ET” daily reset is not ET-anchored
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:156
   Evidence: clock.set_timer(interval=1 day) does not specify wall-clock alignment/timezone.
   Impact: Daily counters/DD protection resets can drift and mis-enforce Apex buffers.
   Fix: Use an ET-anchored scheduler (America/New_York) or compute next ET midnight/market-open boundary explicitly.

2. Session detection uses UTC-now hour buckets (DST + nondeterministic backtests)
   Location: /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py:268
   Impact: Wrong session gating around DST; backtests depend on wall-clock run time.
   Fix: Derive session from event timestamps (bar.ts_event / tick.ts_event) and convert to America/New_York or explicit venue timezone.

3. OB/FVG modules are BLOCKED for look-ahead; strategy consumption lacks explicit confirmation lag
   Evidence: /home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_B_FINDINGS.md:403
   Impact: Non-causal zone confirmation contaminates backtests; live trading cannot replicate.
   Fix: Either redesign indicators to be causal, or enforce N-bar lag at strategy layer and only act on zones whose detection_time <= current_time - N*bar_interval.

FALSE POSITIVES / NEEDS EVIDENCE
--------------------------------
- Phase 01 claim that drawdown tracker is “fed MID equity even though child override exists” needs proof of non-virtual dispatch. In Python, BaseGoldStrategy.on_quote_tick calling self._compute_equity_from_tick should dispatch to GoldScalperStrategy override if present. The base method is still a CRITICAL hazard for other subclasses/future refactors.

TEMPORAL CORRECTNESS CHECK
--------------------------
[ ] Data access points verified: base_strategy._compute_equity_from_tick (tick bid/ask), base_strategy.on_start timer, strategy_selector._update_session_info
[ ] Timestamp ordering confirmed: PARTIAL (prop firm/time manager internals not reviewed)
[ ] Look-ahead indicators: FOUND (OB/FVG per Phase 02 R1_B)
[ ] Bar completion verified: PARTIAL (Phase 01 indicates bar.ts_event use, but confirmation lag not enforced)
Overall: FAIL (unresolved look-ahead in OB/FVG + unverified time-manager ET conversions)

MANUAL VERIFICATION NEEDED
--------------------------
[ ] Verify TimeConstraintManager converts ts_event to America/New_York and enforces 4:30/4:55/4:59 ET across DST.
[ ] Verify prop-firm module uses HWM=max(HWM, equity including unrealized at conservative exit prices) and floor=HWM*0.95.

CONFIDENCE: HIGH
Reason: Direct code evidence for MID pricing + timer design + UTC-now sessions; strong Phase 02 R1_B evidence for OB/FVG look-ahead risk.

PRE-MORTEM SUMMARY
------------------
Most likely failure mode: Backtests “pass” due to OB/FVG future-confirmation and/or optimistic HWM mark-to-market; live trading hits Apex trailing floor after a reversal.
Second most likely: DST/timezone bug misses the 4:59 ET flat requirement.
Mitigation: Make all time gates event-timestamp-driven in ET; enforce conservative mark-to-market; remove look-ahead by design.
