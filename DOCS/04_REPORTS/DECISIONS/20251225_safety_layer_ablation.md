# Safety Layer Ablation — 11-04

**Objective**: Falsification-first ablation of Safety Layer components (focus: survival / Apex compliance invariants).

## Artifacts (local)
### Jan 2024 (ticks, stride20 parquet)
- Baseline: `/tmp/ablation_jan_ticks_baseline2`
- VirtualGate OFF: `/tmp/ablation_jan_ticks_vg_off`
- Vol spacing OFF: `/tmp/ablation_jan_ticks_volspacing_off`
- Exposure caps OFF: `/tmp/ablation_jan_ticks_exposure_off`

### Feb 2024 (ticks, stride20 parquet)
- Baseline: `/tmp/ablation_feb_ticks_baseline`
- VirtualGate OFF: `/tmp/ablation_feb_ticks_vg_off`
- Vol spacing OFF: `/tmp/ablation_feb_ticks_volspacing_off`
- Exposure caps OFF: `/tmp/ablation_feb_ticks_exposure_off`
- All 3 OFF: `/tmp/ablation_feb_ticks_all_off`

## Metrics Summary (from `metrics.jsonl`)
### Jan 2024
| Run | Fills | PnL (USD) | Final balance | Commission est | Out dir |
|---|---:|---:|---:|---:|---|
| baseline | 78 | -1286.89 | 98713.11 | 30.50 | `/tmp/ablation_jan_ticks_baseline2` |
| vg_off | 78 | -1151.90 | 98848.10 | 28.21 | `/tmp/ablation_jan_ticks_vg_off` |
| volspacing_off | 78 | -1305.81 | 98694.19 | 29.56 | `/tmp/ablation_jan_ticks_volspacing_off` |
| exposure_off | 78 | -1287.79 | 98712.21 | 28.97 | `/tmp/ablation_jan_ticks_exposure_off` |

### Feb 2024
| Run | Fills | PnL (USD) | Final balance | Commission est | Out dir |
|---|---:|---:|---:|---:|---|
| baseline | 72 | -733.25 | 99266.75 | 26.21 | `/tmp/ablation_feb_ticks_baseline` |
| vg_off | 72 | -643.97 | 99356.03 | 26.16 | `/tmp/ablation_feb_ticks_vg_off` |
| volspacing_off | 76 | -239.30 | 99760.70 | 29.36 | `/tmp/ablation_feb_ticks_volspacing_off` |
| exposure_off | 72 | -771.33 | 99228.67 | 27.62 | `/tmp/ablation_feb_ticks_exposure_off` |
| all_off | 72 | -778.90 | 99221.10 | 27.40 | `/tmp/ablation_feb_ticks_all_off` |

## Observations (falsification-first)
- Across these two monthly slices, **VirtualGate OFF is not worse** on PnL (slightly less negative in both Jan/Feb), so these runs do **not** support a claim that VirtualGate improves outcomes.
- **Vol spacing OFF** shows the largest delta (Feb: -239 vs baseline -733), but it also changes fill count (76 vs 72), so this is a *behavioral change*, not a pure “same trades, safer execution” effect.
- **Exposure caps OFF** is flat-to-worse on these slices (no evidence of upside here).

## Critical Execution Notes
- Multiple runs emitted FAILSAFE events such as `position_opened_without_protective_orders` and `CRITICAL_CLOSE_TIMEOUT` (cutoff) during Feb 2024.
- These are **Apex-critical failure modes** and appear independent of the Safety Layer ablation toggles.

## Conclusion (updated)
- On this evidence, the Safety Layer components (as currently configured) **do not demonstrate measurable edge or survival benefit** on the Jan/Feb 2024 tick slices.
- The most actionable finding is that the strategy hits **protective-order and cutoff-close failsafes**, which must be treated as higher priority than marginal component deltas.

---
*Generated: 2025-12-26*
