# Phase 06 - Backtest Scripts Audit Findings (Consolidated)

## Scope

### 06 R1 (Core Strategies)
- `scripts/backtest/strategies/ea_logic_full.py`
- `scripts/backtest/strategies/ea_logic_python.py`
- `scripts/backtest/strategies/adaptive_kelly.py`
- `scripts/backtest/strategies/ea_logic_compat.py`
- `scripts/backtest/strategies/fibonacci_analyzer.py`
- `scripts/backtest/strategies/spread_analyzer.py`

### 06 R2 (Validation Scripts)
- `scripts/backtest/monte_carlo_degradation.py`
- `scripts/backtest/wfa_filter_study.py`
- `scripts/backtest/realistic_backtester.py`
- `scripts/backtest/stress_test_degradation.py`
- `scripts/backtest/multi_year_backtest.py`

Source reports:
- `PHASE_06_R1_A_EALOGIC_FINDINGS.md`
- `PHASE_06_R1_B_ALTSTRAT_FINDINGS.md`
- `PHASE_06_R1_C_ANALYSIS_FINDINGS.md`
- `PHASE_06_R2_D_STATVALID_FINDINGS.md`
- `PHASE_06_R2_E_BACKTESTER_FINDINGS.md`

---

## Executive Summary

**Total issues (Phase 06, sum across all 5 reports):**
- **CRITICAL: 12**
- **HIGH: 21**
- **MEDIUM: 19**
- **LOW: 8**

**Verdict:** **BLOCKED for Apex-labeled evaluation / GO-NOGO.**

Multiple scripts and harnesses contain **confirmed temporal leakage** and/or **material execution optimism**, and most do not enforce the project’s Apex invariants (ET time gates + trailing DD from HWM incl. unrealized).

---

## Critical Blockers (must-fix before trusting any Phase 06 metrics)

### 1) Confirmed look-ahead leakage in EA parity path (HTF “as-of” contract missing)
- Root: `TickBacktester` passes full-range H1 bars into EA logic without slicing to the evaluation timestamp.
- Evidence: `PHASE_06_R1_A_EALOGIC_FINDINGS.md` (A-001).

### 2) Confirmed look-ahead leakage in “compat” MTF alignment (full-series `.iloc[-1]`)
- Root: `MTFAnalyzer.calculate_alignment()` ignores `current_idx` and uses the end of full-series rolling MAs.
- Evidence: `PHASE_06_R2_E_BACKTESTER_FINDINGS.md` (P06-R2E-001).

### 3) Apex invariants missing across backtest scripts
- Missing ET gates (4:30 PM ET entry cutoff, 4:55 PM ET emergency close, 4:59 PM ET hard flatten).
- Risk/DD semantics not Apex (FTMO-like limits; realized-only equity; no unrealized-inclusive HWM).
- Evidence: `PHASE_06_R1_A_EALOGIC_FINDINGS.md` (A-002/A-003), `PHASE_06_R1_B_ALTSTRAT_FINDINGS.md` (B-001/B-004), `PHASE_06_R2_E_BACKTESTER_FINDINGS.md` (P06-R2E-002).

### 4) Execution realism gaps that can materially inflate results
- Decide+fill at same bar close, no bid/ask microstructure, missing slippage/latency/commission integration.
- “Free limit fills” (entry better than market) without an order/fill simulator.
- Evidence: `PHASE_06_R1_A_EALOGIC_FINDINGS.md` (A-004), `PHASE_06_R1_B_ALTSTRAT_FINDINGS.md` (B-002), `PHASE_06_R2_E_BACKTESTER_FINDINGS.md` (P06-R2E-003/P06-R2E-004).

### 5) Validation scripts are not currently valid for robustness claims
- “Monte Carlo” script is not an ensemble Monte Carlo (single seeded draw per level, no CI/percentiles) and inherits a leaky baseline by running EA parity.
- WFA window construction leaves a large portion of the dataset unused under defaults and relies on SMC structures with forward-bar confirmation via dependency.
- Evidence: `PHASE_06_R2_D_STATVALID_FINDINGS.md` (P06-R2D-001/P06-R2D-002/P06-R2D-008).

### 6) Analysis helpers contain correctness defects + weak temporal contracts
- FibonacciAnalyzer: fallback indexing bug + “most recent swing” bug.
- API shape makes accidental full-series leakage easy (arrays-only, no as-of contract).
- Evidence: `PHASE_06_R1_C_ANALYSIS_FINDINGS.md` (P06-C-001..P06-C-004).

### 7) Reproducibility + safety hazards in scripts
- Hardcoded Windows paths + `sys.path.insert(...)` import injection appears in multiple scripts.
- Evidence: `PHASE_06_R2_D_STATVALID_FINDINGS.md` (P06-R2D-005/P06-R2D-012), `PHASE_06_R2_E_BACKTESTER_FINDINGS.md` (P06-R2E-006/P06-R2E-007).

---

## Cross-Module Synthesis (why Phase 06 results currently cannot be trusted)

- **Even if the core strategy and risk modules are correct in isolation (Phase 03),** Phase 06 scripts can still produce false positives by leaking future bars and/or using optimistic fill assumptions.
- **Phase 04 blockers amplify this risk:** score inflation + news tz mismatch can materially change trade frequency and timing, invalidating comparisons if Phase 06 scripts depend on those modules.
- **Phase 05 blockers (execution lifecycle not production-ready)** mean Phase 06 “execution realism” is necessarily approximate; until a real order lifecycle + protectives + reject/partial handling exists, backtest realism remains limited.

---

## Roll-up (by source report)

| Report | Verdict | CRITICAL | HIGH | MEDIUM | LOW |
|--------|---------|----------|------|--------|-----|
| `PHASE_06_R1_A_EALOGIC_FINDINGS.md` | BLOCK | 4 | 4 | 4 | 1 |
| `PHASE_06_R1_B_ALTSTRAT_FINDINGS.md` | CHANGES_REQUIRED | 4 | 4 | 3 | 1 |
| `PHASE_06_R1_C_ANALYSIS_FINDINGS.md` | CHANGES_REQUIRED | 0 | 4 | 4 | 2 |
| `PHASE_06_R2_D_STATVALID_FINDINGS.md` | BLOCK | 2 | 4 | 5 | 2 |
| `PHASE_06_R2_E_BACKTESTER_FINDINGS.md` | BLOCK | 2 | 5 | 3 | 2 |

---

## Handoff / Next Actions

1) Fix the two **confirmed** leakage roots first (EA parity HTF slicing; compat MTF alignment slicing) and add guardrail tests that fail on one future bar.
2) Gate Phase 06 scripts explicitly as **Apex-compliant vs non-Apex**; do not allow “Apex/realistic” labels without ET gates + unrealized-inclusive HWM trailing DD.
3) Enforce decision/execution timeline explicitly (decide on bar close, execute next tick/next bar open) and apply bid/ask + slippage + commission consistently.
4) Rebuild WFA/MC to be methodologically correct (coverage across full dataset, minimum OOS trade gates, true ensemble MC with percentiles).
5) After fixes, rerun Phase 06 validation scripts and update this consolidation + MANIFEST counts.
