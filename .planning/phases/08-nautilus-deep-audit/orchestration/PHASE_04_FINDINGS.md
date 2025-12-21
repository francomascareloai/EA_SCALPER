# Phase 04 - Signal Generators Audit Findings (Consolidated)

## Scope
- **04-A (Scoring/Entry/MTF):**
  - `nautilus_gold_scalper/src/signals/confluence_scorer.py`
  - `nautilus_gold_scalper/src/signals/entry_optimizer.py`
  - `nautilus_gold_scalper/src/signals/mtf_manager.py`
- **04-B (News modules):**
  - `nautilus_gold_scalper/src/signals/news_calendar.py`
  - `nautilus_gold_scalper/src/signals/news_trader.py`

Source reports:
- `PHASE_04_A_SCORING_FINDINGS.md`
- `PHASE_04_B_NEWS_FINDINGS.md`

---

## Executive Summary

**Total issues (Phase 04):**
- **CRITICAL: 3**
- **HIGH: 6**
- **MEDIUM: 10**
- **LOW: 5**

**Primary blockers (must-fix before trusting Phase 06 backtest validation):**
1. **ICT Step 5 (`at_poi`) is logically wrong** (inflates 7-step sequence bonus; amplified by `SCORE_SCALE_FACTOR=5.0`).
2. **Signals MTF manager appears untested** (tests exist for a different `MTFManager` module path; temporal alignment risk remains unverified).
3. **News filtering can crash or silently fail** due to tz-aware vs naive datetime mismatch in `news_trader.py`.

---

## Cross-Module Synthesis (What breaks downstream)

### 1) Score inflation cascades into position sizing / risk
- If `at_poi` is effectively “true whenever any OB/FVG exists”, then the ICT sequence score becomes structurally biased upward.
- Because the sequence bonus is later scaled and potentially multiplied by alignment/freshness/divergence multipliers, this can:
  - push marginal setups over the execution threshold,
  - increase trade frequency,
  - amplify exposure to Apex trailing DD (HWM trap) through more trades.

### 2) Backtest temporal integrity risks (time sources)
- `entry_optimizer.py` uses **wall-clock time** (`datetime.now(timezone.utc)`) for expiry in backtests, which can decouple setup expiry from bar progression.
- `news_trader.py` uses **naive UTC** (`datetime.utcnow()`), while event times are tz-aware UTC — raising runtime errors on comparisons.

### 3) MTF alignment contract is implicit
- `signals/mtf_manager.py` accepts arrays + a single `current_price` passed to all timeframe analyzers. If callers pass a LTF tick as `current_price` while HTF bars are not closed, it creates cross-time leakage risk.

---

## Findings Roll-up

### 04-A Roll-up (Scoring/Entry/MTF)
- **CRITICAL: 2 | HIGH: 4 | MEDIUM: 7 | LOW: 3**

Key items:
- **CRITICAL:** `at_poi` sequence bug (P04-A-001)
- **CRITICAL:** MTF test coverage mismatch (P04-A-016)
- **HIGH:** wall-clock expiry for backtests (P04-A-007, P04-A-008)
- **HIGH:** alignment multiplier threshold mismatch (P04-A-002)

### 04-B Roll-up (News)
- **CRITICAL: 1 | HIGH: 2 | MEDIUM: 3 | LOW: 2**

Key items:
- **CRITICAL:** tz-aware vs naive datetime mismatch in `news_trader.py` (P04-B-006)
- **HIGH:** naive event times assumed UTC (P04-B-001)
- **HIGH:** hardcoded/limited calendar coverage leads to “no events → allow trading” behavior (P04-B-002)

---

## Handoff to Phase 05 / Phase 06

**Mandatory before trusting Phase 06 results:**
- Fix `at_poi` computation and add a focused regression test.
- Fix tz-handling in `news_trader.py` (tz-aware UTC everywhere) and decide live/backtest calendar policy.
- Unify or explicitly test the `signals/mtf_manager.py` path used by the strategy.

**If deferred:**
- Phase 06 backtests may overestimate performance (false positives) due to score inflation + incorrect expiry + news filter not functioning.
