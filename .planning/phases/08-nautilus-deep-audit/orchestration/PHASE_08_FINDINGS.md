# Phase 08 - Integration Points Audit Findings (Consolidated)

## Scope
Phase 08 validates *integration correctness* across the end-to-end trading system:

- **08-A (Strategy ↔ Risk Integration):**
  - `GoldScalperStrategy` → `PropFirmManager` → (`DDProtectionCalculator`, `ConsistencyTracker`)
  - Strategy base → (`DrawdownTracker`, `CircuitBreaker`, `TimeConstraintManager`, `PositionSizer`)

- **08-B (Indicator ↔ Strategy Integration):**
  - `BaseGoldStrategy.on_bar()` routing (HTF/MTF/LTF)
  - `GoldScalperStrategy._check_for_signal()` → `_calculate_confluence()` → indicators/analyzers

- **08-C (Signal ↔ Execution Integration):**
  - `ConfluenceScorer` → `GoldScalperStrategy` (score gating)
  - Strategy → order submission + bracket attachment
  - `ExecutionModel` cost modeling (slippage + commissions)
  - `TradeManager` integration status

- **08-D (Time Synchronization):**
  - ET timezone and DST handling
  - Daily resets (ET vs UTC)
  - 4:30 / 4:55 / 4:59 ET time gates
  - Single time source vs mixed wall-clock/event-time

Source reports:
- `PHASE_08_A_STRATEGYRISK_FINDINGS.md`
- `PHASE_08_B_INDICATORSTRAT_FINDINGS.md`
- `PHASE_08_C_SIGNALEXEC_FINDINGS.md`
- `PHASE_08_D_TIMESYNC_FINDINGS.md`

---

## Executive Summary

**Verdict:** **BLOCKED (Apex compliance + execution safety).**

Primary blockers:
1) **Open-position safety is not guaranteed at drawdown breach** (risk modules can block entries but do not reliably force-flatten outside time-gate emergency close).
2) **Protective orders (SL/TP) are not fail-safe**: bracket submission occurs post-fill with no verified lifecycle handling; failures can leave positions unprotected.
3) **Time-gate robustness is data-driven** (ts_event/tick arrivals). There is no wall-clock/scheduler fail-safe to guarantee flatten by 16:59 ET under feed stalls.
4) **Indicator/strategy temporal realism gaps**: missing real timestamps passed into OB/FVG/AMD/sweep detectors causes synthetic timelines and decouples time-based logic.
5) **Cross-timeframe semantic collision**: “MTF zones” storage can be overwritten by LTF detections, breaking intended architecture.

---

## Findings Roll-up (by integration area)

### 08-A Strategy ↔ Risk Integration
Key findings (from `PHASE_08_A_STRATEGYRISK_FINDINGS.md`):
- **CRITICAL:** DD breach does not guarantee immediate flatten for open positions; multiple DD systems have inconsistent thresholds/enforcement.
- **HIGH:** PositionSizer drawdown throttle not driven by live drawdown (`current_drawdown_pct` not passed); tick-level equity source divergence risk.

### 08-B Indicator ↔ Strategy Integration
Key findings (from `PHASE_08_B_INDICATORSTRAT_FINDINGS.md`):
- **CRITICAL:** MTF zone state collision: `_mtf_order_blocks/_mtf_fvgs` set from MTF bars then overwritten by LTF detectors.
- **HIGH:** Strategy does not pass real timestamps into detectors; they fall back to synthetic timestamps (time-decay/expiry realism breaks).
- **HIGH:** Backtest config wiring likely omits HTF/MTF bar subscriptions (strategy may run LTF-only despite design intent).
- **MEDIUM:** Warmup gates not harmonized; early-run windows have incomplete MTF/HTF components.

### 08-C Signal ↔ Execution Integration
Key findings (from `PHASE_08_C_SIGNALEXEC_FINDINGS.md`):
- **CRITICAL:** Bracket attachment is not fail-safe; bracket reject/failure can leave a position naked.
- **CRITICAL:** No order-event state machine; stale `_pending_sl/_pending_tp` can persist across rejects/cancels and be applied to later positions.
- **HIGH:** Execution costs not included in pre-trade R:R or risk gating; validate_trade ignores expected costs.
- **HIGH:** TradeManager exists but is not wired to the strategy (trailing/partial TP logic not active).
- **HIGH:** PositionSizer drawdown throttle bypassed (drawdown pct not provided).

### 08-D Time Synchronization
Key findings (from `PHASE_08_D_TIMESYNC_FINDINGS.md`):
- **CRITICAL:** Time gates in live mode are event-driven (no wall-clock/scheduler fail-safe).
- **CRITICAL:** No guaranteed “flat by 16:59 ET” enforcement loop independent of tick arrival.
- **HIGH:** Mixed daily boundary logic (ET vs UTC) across modules risks inconsistent daily limits.
- **HIGH:** Wall-clock usage inside backtest-sensitive modules (SpreadMonitor, EntryOptimizer) breaks determinism.

---

## Systemic Failure Modes (pre-mortem)

1) **Apex trailing DD breach while in-position:**
   - Risk modules block new entries but do not force-flatten; a reversal can blow the account before a time-gate triggers.

2) **Bracket rejected / never placed:**
   - Entry fills, but SL/TP reject or never submit; strategy clears pending anyway → naked position.

3) **Feed stalls near close (16:54→17:00 ET):**
   - Event-driven checks stop firing; no scheduled emergency close.

4) **Temporal drift in backtests:**
   - Wall-clock based logic (spread snapshot rate limiting, signal expiry timestamps) distorts results and reduces reproducibility.

---

## Issue Summary (Phase 08)

Phase 08 issue counts are consolidated as follows:
- **CRITICAL:** 7
- **HIGH:** 10
- **MEDIUM:** 6
- **LOW:** 2

> Note: Counts are a roll-up across the four sub-reports. Phase 08 is **BLOCKED** regardless of exact counts due to multiple independent CRITICAL blockers.

---

## Next Actions (handoff)

1) **Execution safety:** implement an order/position lifecycle guardrail:
   - clear pending SL/TP on rejects/cancels
   - verify protective orders are accepted; if not → immediate emergency close + halt

2) **Risk integration:** unify DD enforcement thresholds and ensure **open positions** are force-flattened on safety-buffer breach.

3) **Time robustness:** add wall-clock/scheduler-driven enforcement for the Apex gates (4:30/4:55/4:59 ET) independent of market event delivery.

4) **Indicator integration:** fix MTF/LTF zone state collision and pass real timestamps into time-aware detectors.

5) **Backtest determinism:** remove/contain wall-clock dependencies (`SpreadMonitor`, `EntryOptimizer`) in backtests.
