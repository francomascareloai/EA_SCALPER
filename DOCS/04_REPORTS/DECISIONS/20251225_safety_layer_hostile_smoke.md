# Safety Layer Hostile Execution Smoke — 11-04

**Objective**: Quick hostile-execution smoke (latency/slippage) to look for immediate failure modes.

## Artifacts (local)
- Feb 2024 (ticks, stride20 parquet)
  - `lat0_s0`: `/tmp/hostile_feb_ticks_lat0_s0`
  - `lat50_s1`: `/tmp/hostile_feb_ticks_lat50_s1`
  - `lat150_s3`: `/tmp/hostile_feb_ticks_lat150_s3`
  - `lat250_s5`: `/tmp/hostile_feb_ticks_lat250_s5`

## Summary (from `metrics.jsonl`)
| Run | Latency (ms) | Slippage (ticks) | Fills | PnL (USD) | Final balance | Commission est | Out dir |
|---|---:|---:|---:|---:|---:|---:|---|
| lat0_s0 | 0 | 0 | 46 | -709.74 | 99290.26 | 16.72 | `/tmp/hostile_feb_ticks_lat0_s0` |
| lat50_s1 | 50 | 1 | 72 | -671.72 | 99328.28 | 22.42 | `/tmp/hostile_feb_ticks_lat50_s1` |
| lat150_s3 | 150 | 3 | 68 | -718.92 | 99281.08 | 21.77 | `/tmp/hostile_feb_ticks_lat150_s3` |
| lat250_s5 | 250 | 5 | 74 | -745.19 | 99254.81 | 27.10 | `/tmp/hostile_feb_ticks_lat250_s5` |

## Interpretation
- PnL degradation is present but **not monotonic** with (latency, slippage), largely because fill counts differ across settings.
- This smoke **does not** establish survival probability or Apex compliance under stress; it is only a quick “does it explode immediately?” check.

## Critical Execution Notes
- FAILSAFE events were observed (e.g., `position_opened_without_protective_orders`, `CRITICAL_CLOSE_TIMEOUT`), which are **Apex-critical** and should be addressed before interpreting marginal hostile-execution deltas.

---
*Generated: 2025-12-26*
