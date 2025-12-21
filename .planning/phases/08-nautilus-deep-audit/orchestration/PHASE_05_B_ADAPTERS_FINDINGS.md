# Phase 05 (Agent B) Findings: Execution Model + Adapters

**Scope:** Execution realism (latency, slippage, partial fills, rejections), adapter interface completeness, failure modes, and alignment with NautilusTrader execution flow.

**Files reviewed (source of truth):**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/execution_model.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/base_adapter.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/mt5_adapter.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/ninjatrader_adapter.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/context/holiday_detector.py`

---

## Executive Verdict (Agent B)

**Execution realism + live adapter readiness: PARTIAL / NOT PRODUCTION-READY → BLOCKED for Phase 06 live/paper execution readiness.**

- `ExecutionModel` currently behaves as a **post-fill cost adjuster** (PnL haircut), not a true fill/latency/rejection simulator.
- `MT5Adapter` / `NinjaTraderAdapter` are **skeletons** and are **not integrated** into NautilusTrader’s order routing / event model.
- Holiday calendar exists but is **not wired** into execution/risk sizing decisions.

---

## 1) Execution realism: `ExecutionModel` (`execution_model.py`)

### What it does
- Computes a slippage-adjusted price using:
  - `base_slippage_cents * slippage_multiplier * vol_factor * jitter`
  - Applies worse price in the correct direction (`buy` adds, otherwise subtracts).
- Computes `commission_per_lot * lots`.

### Critical gaps vs required realism (latency/partial/reject)
- **No latency model** (no `latency_ms`, no time delay, no event-time shift).
- **No partial fill model** (no split quantity, no staged fills).
- **No rejection model** (no base reject probability, no volatility-linked rejects).

### Key realism issue: slippage is applied after the fact
- In current integration, slippage/commission are applied as a **cash/PnL adjustment after Nautilus reports the fill**, via:
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py` (`_calculate_execution_cost`, `on_position_opened`, `on_position_closed`).
- Consequence: slippage **does not affect**:
  - The actual fill price used for bracket placement.
  - Whether stops/targets are hit (gap-through / stop-out realism).
  - Order acceptance / rejection paths.

### Failure modes
- Non-deterministic jitter (`random.uniform`) makes backtests **non-reproducible** unless seeded/controlled.
- `side` is a free-form string; any value other than case-insensitive `"buy"` is treated as sell.

**Severity:** CRITICAL (realism + validation integrity)

---

## 2) Adapter interface and realism: `BaseExecutionAdapter` (`base_adapter.py`)

### What it does
- Offline-first adapter with:
  - File-backed tick streaming via pandas (`read_parquet` / `read_csv`).
  - In-memory order “ledger” (`_orders`), incremental integer IDs.

### Interface completeness vs execution needs
The adapter currently lacks essentials for realistic execution and for safe integration:
- No order status lifecycle beyond `NEW` / `CANCELLED`.
- No acknowledgements, fills, partial fills, rejections, or error codes.
- No position/account state, no reconciliation, no heartbeat.
- `time_in_force` is stored but not enforced (no expiry logic).

### Failure modes / operational hazards
- `connect()` sets `_connected=True` unconditionally; `MT5Adapter`/`NinjaTraderAdapter` inherit this behavior.
  - In any “live wiring” attempt this can create **false-positive connectivity**, leading to **silent non-execution**.
- Tick streaming reads the **entire dataset into memory** (`pd.read_parquet`/`pd.read_csv`) and iterates with `df.iterrows()`.
  - This is not viable for the project’s tick dataset scale and is a performance risk.
- No explicit validation if required columns are missing (will raise at runtime).
- No timestamp monotonicity check or sorting; replay may be temporally incorrect depending on file ordering.

**Severity:** HIGH/CRITICAL depending on whether adapter enters the live path.

---

## 3) `MT5Adapter` and `NinjaTraderAdapter` status

### Implementation status
- Both adapters are **stubs**:
  - Store credentials/host fields.
  - `connect()` just calls `super().connect()`.
  - No transport, no order mapping, no execution events.

### Production relevance
- Project metadata indicates target execution is NinjaTrader; however `NinjaTraderAdapter` has **no OIF/ATI bridge implementation** and no acknowledgement/fill workflow.

**Severity:** CRITICAL (cannot be considered production adapter as-is)

---

## 4) Holiday detector (`context/holiday_detector.py`) integration status

- Module exists at:
  - `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/context/holiday_detector.py`
- Repo search found **no runtime usage** of `HolidayDetector(...)` in `nautilus_gold_scalper/src`.
- It uses `datetime.now(timezone.utc).date()`; for ET-session trading, UTC date boundaries can differ near midnight and could misclassify “today” vs ET.

**Severity:** MEDIUM (missing realism/risk sizing input; timezone boundary risk)

---

## 5) NautilusTrader execution-flow alignment (YES/NO)

**Answer: NO for adapters; PARTIAL for execution costs.**

- `ExecutionModel` is integrated only as a **post-fill accounting adjustment**, not as a Nautilus fill/latency simulator.
- The adapter classes are not used in the Nautilus order submission path (no evidence of `BaseExecutionAdapter.send_order()` being called from strategy execution), and do not emit Nautilus order/fill events.

---

## Findings Table (Phase 05.B)

| ID | Severity | Finding | Evidence | Consequence |
|----|----------|---------|----------|-------------|
| B-001 | CRITICAL | No latency/partial/reject modeling in `ExecutionModel` | `execution_model.py` only computes slippage/commission | Optimistic fills; misses real-world failure modes |
| B-002 | CRITICAL | Slippage applied post-fill, not in fill price/time | `base_strategy.py` applies cost after events | Stops/TP realism compromised; risk underestimation |
| B-003 | CRITICAL | MT5/Ninja adapters are stubs; `connect()` is fail-open | `mt5_adapter.py`, `ninjatrader_adapter.py`, `base_adapter.py` | Silent non-execution if mistakenly used for live |
| B-004 | HIGH | Tick streaming loads full file + iterrows, no monotonic checks | `base_adapter.py:stream_ticks` | Performance/temporal correctness risk |
| B-005 | HIGH | Adapter interface lacks ack/fill/reject lifecycle and error codes | `base_adapter.py` | Trade manager cannot model real execution states |
| B-006 | MEDIUM | Random slippage jitter makes backtests non-reproducible | `execution_model.py` uses `random.uniform` | Results vary between runs |
| B-007 | MEDIUM | Holiday detector exists but is not wired into execution/risk | `holiday_detector.py` + no call sites | Missed liquidity reductions; potential over-sizing |

**Issue counts:** 3 CRITICAL, 2 HIGH, 2 MEDIUM, 0 LOW

---

## Decision (2 options) + Rationale

### Option A (minimal safe): keep as accounting-only
- Keep `ExecutionModel` as PnL adjustment, treat adapters as offline-only.
- Rely on NautilusTrader backtest engine for execution/fills.

### Option B (robust / required for live): implement real execution integration
- Implement a NinjaTrader bridge (OIF/ATI or Add-On transport) which produces acknowledgements/fills/rejects and reconciles positions.
- Move realism (slippage/latency/partial/reject) into a true simulation layer (fill model / execution emulator) so it affects fills and downstream behavior.

**Pick:** Option B. Without it, Phase 06 “live/paper execution readiness” cannot be validated; current path is realism-by-accounting only.

---

## Validation (for future implementation)

- Add deterministic execution simulations (seeded randomness or deterministic slippage model) for backtest reproducibility.
- Add test cases for: rejection paths, partial fills, out-of-order events, gap-through stop, and adapter disconnect/reconnect.

---

## Risks (1st/2nd/3rd-order)

- **1st-order:** Backtests overstate performance due to perfect fills + no rejects.
- **2nd-order:** Risk/time-gate modules may be validated against overly optimistic execution, leading to false safety.
- **3rd-order:** Live deployment could suffer silent non-execution or state divergence if stub adapters are used, creating catastrophic mismatch between assumed vs actual exposure.

---

## Next step

- Confirm intended production execution path (NinjaTrader bridge specifics: OIF vs add-on vs socket) and ensure adapters emit/consume Nautilus order/fill events with explicit failure handling.
