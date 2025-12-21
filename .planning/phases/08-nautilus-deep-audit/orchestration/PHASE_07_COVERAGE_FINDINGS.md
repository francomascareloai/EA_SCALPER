# Phase 07 - Test Coverage Analysis Findings

## Scope
- Test suite: `nautilus_gold_scalper/tests/`
- Coverage command (branch + JSON):
  - `pytest -q --cov=nautilus_gold_scalper --cov-branch --cov-report=json:.tmp/phase07_coverage.json nautilus_gold_scalper/tests/`

> Note: `test_integration/test_tick_backtest_e2e.py` is **conditionally skipped** when local tick data is not present, so coverage metrics primarily reflect unit/integration tests which do not depend on external datasets.

---

## Executive Summary

**Coverage baseline (from `.tmp/phase07_coverage.json`):**
- **Line coverage:** **52.68%** (8869 / 16835 statements)
- **Branch coverage:** **28.66%** (1301 / 4540 branches)
- **Combined:** 47.58%

**Verdict:** **BLOCK** (fails minimum coverage + critical-path coverage).
- Targets: 85% line / 75% branch
- Minimums: 70% line / 60% branch
- Current baseline fails both minimums, and **critical-path strategy coverage is not 100%**.

---

## Coverage Breakdown (Source: `nautilus_gold_scalper/src/`)

| Package | Line % | Branch % | Notes |
|---|---:|---:|---|
| `src_total` | 48.64% | 30.48% | Large uncovered surface in strategy + validation modules |
| `risk/` | 77.10% | 59.95% | Near branch minimum; many Apex-critical paths covered |
| `execution/` | 68.77% | 43.78% | Line slightly below minimum; branches well below minimum |
| `indicators/` | 71.98% | 50.95% | Line above minimum; branches below minimum |
| `signals/` | 42.73% | 17.35% | Major gaps (news + scoring) |
| `strategies/` | 27.99% | 5.56% | **Critical gap: core strategy is largely untested** |
| `ml/` | 40.58% | 23.53% | Major gaps; validation of ML pipeline not exercised |

### Key modules (coverage summary)
- `src/risk/dd_protection.py`: **95.71%** line (good)
- `src/risk/drawdown_tracker.py`: **89.08%** line (good)
- `src/risk/prop_firm_manager.py`: **81.13%** line (good)
- `src/risk/time_constraint_manager.py`: **77.39%** line (OK; needs more branch tests)
- `src/execution/trade_manager.py`: **88.57%** line (good)

Major low-coverage blockers:
- `src/strategies/gold_scalper_strategy.py`: **15.20%** line (847 missing lines)
- `src/strategies/base_strategy.py`: **11.65%** line (419 missing lines)
- `src/signals/news_trader.py`: **0.00%** line (260 missing lines)
- `src/signals/news_calendar.py`: **21.03%** line (171 missing lines)
- `src/signals/confluence_scorer.py`: **43.18%** line (216 missing lines)
- `src/validation/core/*` + `src/validation/phases/*`: **0.00%** line across multiple files

---

## Test Suite Audit

### 1) Disabled / skipped tests
- Found conditional skipping only in `nautilus_gold_scalper/tests/test_integration/test_tick_backtest_e2e.py`:
  - skips when `Python_Agent_Hub` tick data directory is missing
  - skips when no tick data files are found

**Impact:** E2E coverage is not reliably included in the default suite, so "system-level" validation remains weak.

### 2) Apex / ET time semantics
Evidence of ET-aware testing exists:
- `ZoneInfo("America/New_York")` usage appears in `test_apex_compliance.py` and risk tests.
- Time gates are explicitly tested (e.g., block new entries after 4:30 PM ET, force-close after 4:55 PM ET, hard block at 4:59 PM ET).

**Status:** Present, but the enforcement at the full-strategy orchestration level is not covered (strategy module itself is mostly untested).

### 3) HWM / drawdown semantics
Evidence of drawdown/HWM testing exists:
- Tests cover HWM updating and DD% calculations (including the project safety buffer behavior).

**Status:** Core math has coverage; integration with strategy decision-making is not proven by tests.

### 4) Mock realism (execution microstructure)
Observed strengths:
- Spread handling is tested (`SpreadMonitor` tests + entry optimizer spread block test).
- `TradeManager` has extensive lifecycle-style tests (partial closes, trailing logic).

Observed gaps:
- No clear test coverage for **order-level lifecycle realism**: rejects, partial fills at the broker, latency effects, out-of-sequence events.
- Branch coverage in `execution/` is well below minimum (43.78%), indicating many conditional paths are untested.

### 5) Temporal correctness / no-lookahead in tests
Positive signals:
- Many tests use deterministic timestamps and explicit time zone handling.

Main limitation:
- The suite does not currently enforce anti-lookahead invariants at the **Phase 06 script** boundary (EA parity HTF slicing / compat MTF alignment), because those scripts are outside `nautilus_gold_scalper/tests/` and are not exercised here.

---

## Findings (Issues)

### P07-001 (CRITICAL) Coverage below minimum thresholds
- Line 52.68% < 70% minimum
- Branch 28.66% < 60% minimum

### P07-002 (CRITICAL) Core strategy orchestration is largely untested
- `src/strategies/gold_scalper_strategy.py` at 15.20% line
- `src/strategies/base_strategy.py` at 11.65% line

### P07-003 (HIGH) News filtering path is effectively untested
- `src/signals/news_trader.py` at 0% line
- `src/signals/news_calendar.py` at 21.03% line

### P07-004 (HIGH) Validation framework is untested
- `src/validation/core/*` and `src/validation/phases/*` at 0% line

### P07-005 (HIGH) Scoring/confluence coverage is incomplete despite known Phase 04 risks
- `src/signals/confluence_scorer.py` at 43.18% line
- Phase 04 identified correctness risks in scoring/news; Phase 07 indicates regression coverage is not comprehensive.

### P07-006 (MEDIUM) E2E tick backtest is not hermetic
- `test_tick_backtest_e2e.py` skips when local data is missing → likely not exercised in CI or by new devs.

### P07-007 (MEDIUM) Test imports appear inconsistent across package paths
- Tests use both `src.*` and `nautilus_gold_scalper.src.*` import styles.
- Risk: packaging drift can go unnoticed; integration tests may pass locally but fail under different import layouts.

---

## Issue Summary (Phase 07)
- **CRITICAL: 2**
- **HIGH: 3**
- **MEDIUM: 2**
- **LOW: 0**

---

## Recommended Next Actions

1) Add targeted tests for `GoldScalperStrategy` covering:
   - time-gate enforcement (4:30/4:55/4:59 ET)
   - validate_trade gating (prop firm + drawdown)
   - signal → entry → trade lifecycle integration
2) Add tests for news path (`NewsTrader` / `NewsCalendar`) and ensure time zone handling is validated.
3) Raise branch coverage in `execution/` (reject/partial/timeout branches) or explicitly document which branches are non-critical/unreachable.
4) Make E2E tick backtest test hermetic (small fixture dataset or synthetic ticks) so it runs reliably in CI.
5) Normalize import style in tests to a single canonical package path to reduce environment-dependent behavior.
