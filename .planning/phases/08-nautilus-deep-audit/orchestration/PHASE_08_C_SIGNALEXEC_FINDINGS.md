# PHASE 08C — Signal ↔ Execution Integration Findings

AGENT: NAUTILUS
VERSION: 3.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

## Scope
Trace Signal → Execution integration across:
- `ConfluenceScorer` → `GoldScalperStrategy` (signal scoring + gating)
- `GoldScalperStrategy` → `BaseGoldStrategy` (order submission + bracket attachment)
- `BaseGoldStrategy` → `ExecutionModel` (slippage + commission cost modeling)
- `TradeManager` (intended lifecycle manager) integration status

Focus checks (per plan):
- Score threshold correctness and configuration semantics
- Spread checks and spread-aware sizing/score adjustments
- Execution costs: whether incorporated into *pre-trade* R:R and risk gating
- Position sizing via `PositionSizer`
- Order lifecycle: submit → ack/fill/reject/cancel, partial fills
- SL/TP attachment guarantees and recovery (reject, cancel, reconnect)

## Primary Files Reviewed
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/confluence_scorer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/execution_model.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/trade_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/spread_monitor.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/configs/strategy_config.yaml`

## Sequential Thinking Trace (12 steps)
1. Identify the *only* entry decision point: `GoldScalperStrategy._check_for_signal()`.
2. Trace score creation: `_calculate_confluence()` → `ConfluenceScorer.calculate_score()`.
3. Verify score gating order and threshold sources (scorer vs strategy).
4. Trace spread gating and how it affects score and size.
5. Trace sizing: `GoldScalperStrategy._calculate_position_size()` → `PositionSizer.calculate_lot()`.
6. Trace order submission: `_enter_long/_enter_short` in `BaseGoldStrategy`.
7. Trace bracket creation/attachment: `_pending_sl/_pending_tp` → `on_position_opened()` → `_submit_bracket_orders()`.
8. Trace cost modeling: `on_position_opened/on_position_closed` → `_calculate_execution_cost()` → `ExecutionModel`.
9. Check if execution costs feed back into *pre-trade* R:R or risk gating (they do not).
10. Check lifecycle events handled: `on_position_*` exist; `on_order_*` handlers do not.
11. Pre-mortem: identify states where strategy can be left naked / inconsistent (reject/cancel/partial).
12. Conclude gaps + define validation and FORGE handoff tasks.

## Integration Topology (As Implemented)

### Component diagram
```
Bars/Ticks
   │
   ▼
GoldScalperStrategy._check_for_signal
   │  (score threshold + spread/news/risk/time gates)
   ▼
BaseGoldStrategy._enter_long/_enter_short
   │  submit_order(MARKET, IOC)
   ▼
Nautilus order/position events
   │
   ├─ PositionOpened → BaseGoldStrategy.on_position_opened
   │                 ├─ _submit_bracket_orders()  (STOP + LIMIT, reduce_only)
   │                 └─ _calculate_execution_cost() → ExecutionModel
   │
   └─ PositionClosed → BaseGoldStrategy.on_position_closed
                     └─ _calculate_execution_cost() → ExecutionModel

TradeManager (execution/trailing/partial TP)
   └─ Present in codebase, NOT wired into the strategy.
```

### Event flow (high-signal)
1. `Bar(LTF)` → `GoldScalperStrategy._check_for_signal(bar)`
2. `ConfluenceScorer.calculate_score(...)` → `ConfluenceResult(total_score, direction, quality)`
3. Strategy gates:
   - spread snapshot gate (`SpreadSnapshot.can_trade`)
   - absolute spread cap (`_current_spread > max_spread_points`)
   - score gate (`selected_score >= execution_threshold`)
4. Strategy computes SL/TP from `sl_distance` and `target_rr_ratio`.
5. Strategy calls `BaseGoldStrategy._enter_long/_enter_short(quantity, sl_price, tp_price)`
6. `submit_order(MARKET, IOC)` then stores `_pending_sl/_pending_tp`.
7. `PositionOpened` → submit SL/TP reduce-only orders.
8. `PositionOpened/Closed` → apply slippage+commission costs to `_equity_base/_daily_pnl`.

## Key Integration Checks

### 1) Score threshold enforcement
**Implemented:**
- `GoldScalperStrategy` instantiates `ConfluenceScorer(min_score_to_trade=float(config.execution_threshold))`.
- Strategy applies an explicit gate: `if selected_score < execution_threshold: return`.

**Config drift hazard:**
- `ConfluenceScorer` also has a config-based gate `confluence_min_score` accessed via `self.config`, but `self.config` defaults to `None` and is never set by the strategy. That enforcement path is effectively dead.

### 2) Spread checks and spread-aware adjustments
**Implemented:**
- Hard block: if `SpreadSnapshot.can_trade` is false → reject signal.
- Hard block: if `_current_spread > max_spread_points` → reject.
- Soft effects:
  - `spread_score_adj` adjusts effective score.
  - `spread_mult` scales risk% (hence size) via `_calculate_position_size()`.

**Integration caveat:**
- `SpreadMonitor.update()` rate-limits using wall-clock time; in fast backtests the snapshot can be stale (Phase 08D). This directly impacts signal gating and the partial-fill simulation’s spread_ratio.

### 3) Execution costs vs R:R (pre-trade vs realized)
**Implemented:**
- `ExecutionModel` costs are applied *after fills* as a cash adjustment:
  - Entry cost deducted in `on_position_opened`.
  - Exit cost deducted in `on_position_closed`.

**Not implemented:**
- No pre-trade adjustment to `SL/TP` or `target_rr_ratio` to preserve net R:R.
- No min-RR gate that uses expected costs (spread + slippage + commission).
- `PropFirmManager.validate_trade(risk_amount=...)` uses `sl_distance * qty * point_value` only; it does not include expected execution costs (so true worst-case loss is under-estimated).

### 4) Position sizing via PositionSizer
**Implemented:**
- Strategy uses `PositionSizer.calculate_lot(...)` and then converts lots → quantity units.

**Critical integration miss:**
- Strategy does not pass `current_drawdown_pct`, so drawdown-based risk throttling inside `PositionSizer` is inactive (it defaults to 0.0).

### 5) Order lifecycle: submit/ack/fill/reject + partial fills
**Implemented:**
- Entry uses market order with `TimeInForce.IOC`.
- Strategy handles only `on_position_opened`, `on_position_changed`, `on_position_closed`.

**Missing:**
- No `on_order_accepted`, `on_order_rejected`, `on_order_canceled`, `on_order_filled`, etc.
- Partial fills are *simulated pre-submit* by shrinking `quantity` (and can return zero to simulate “reject”). This does not cover real broker partial fill sequences.

### 6) SL/TP attachment guarantees + recovery
**Current pattern:**
- Entry order submitted first.
- `_pending_sl/_pending_tp` stored after submission.
- Brackets submitted only after `PositionOpened`.

**Failure modes (see CRITICAL findings):**
- If IOC order is canceled/rejected with no position opened, pending SL/TP remain and may be incorrectly applied to a later position.
- If bracket orders are rejected, pending is cleared anyway; position can remain unprotected.

## Findings (by Severity)

### CRITICAL
1. **Bracket attachment is not fail-safe (naked position risk).**
   - Brackets are submitted after `PositionOpened` with no order-event verification or retry.
   - If bracket submission fails/rejects, `_pending_sl/_pending_tp` are cleared regardless → position may be left without SL.

2. **No order-event state machine → stale pending SL/TP and broken execution invariants.**
   - Entry uses `IOC`. If order is canceled/rejected (no `PositionOpened`), `_pending_sl/_pending_tp` persist.
   - Next position opened can receive stale bracket prices from a previous signal.
   - There is no handler to clear pending on `OrderRejected/OrderCanceled`.

### HIGH
3. **Execution costs are not incorporated into pre-trade R:R or risk gating.**
   - Costs are applied post-fill to PnL only; `target_rr_ratio` is computed on raw distances.
   - `validate_trade` ignores expected costs/spread, under-estimating worst-case loss.

4. **TradeManager is not integrated.**
   - The requested pipeline component (`TradeManager`) exists but is not used by the strategy.
   - Therefore partial TP / trailing logic described in that module is not active.

5. **PositionSizer drawdown throttle is bypassed.**
   - `current_drawdown_pct` not passed into `PositionSizer.calculate_lot()`.

### MEDIUM
6. **ConfluenceScorer config threshold path is dead.**
   - `confluence_min_score` is read from `ConfluenceScorer.config`, but strategy never sets it.

7. **Spread snapshot semantics can be stale in backtest (wall-clock rate limiting).**
   - A stale snapshot directly affects: spread gating, score adjustment, sizing multiplier, and partial-fill simulation.

8. **Randomness in partial-fill simulation is not seeded (reproducibility risk).**
   - Backtest repeatability and validation comparisons can drift.

### LOW
9. **Duplicate threshold enforcement (scorer + strategy) increases config complexity.**
10. **ExecutionModel volatility parameter is unused in the strategy cost path.**

## Validation Criteria (must be proven)
- [ ] If entry order is **canceled/rejected** (no position opened), `_pending_sl/_pending_tp` are cleared and never applied to later trades.
- [ ] If bracket order is **rejected**, system either retries, or force-closes the position immediately (fail-safe).
- [ ] Live-like partial fills: bracket sizing stays correct if position size changes after initial open.
- [ ] Net R:R after expected costs remains acceptable (if a min-RR gate is introduced).
- [ ] Backtest determinism: spread snapshot + partial-fill model produce stable results under fixed seed.

## Handoff to FORGE (implementation tasks)
1. Implement an order/position state machine: clear pending on order reject/cancel; verify bracket placement; fail-safe close if unprotected.
2. Add `on_order_*` handlers (accepted/rejected/canceled/filled/partially_filled) or an equivalent lifecycle adapter.
3. Integrate execution costs into pre-trade gating (RR/risk) or explicitly document why excluded.
4. Feed `current_drawdown_pct` into `PositionSizer.calculate_lot()`.
5. Either integrate `TradeManager` into strategy execution (trailing/partials) or remove it to avoid false architecture assumptions.
