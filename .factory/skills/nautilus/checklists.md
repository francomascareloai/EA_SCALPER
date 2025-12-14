# NAUTILUS Checklists

## Migration Checklist (MQL5 → Nautilus)

### STEP 1: LOAD MQL5 SOURCE
- [ ] Read `MQL5/Include/EA_SCALPER/[module].mqh`
- [ ] Identify: class name, methods, state, dependencies
- [ ] Note: What does it NEED (inputs)?
- [ ] Note: What does it PRODUCE (outputs)?
- [ ] Document performance requirements

### STEP 2: CHECK EXISTING MIGRATION
- [ ] Read `NAUTILUS_MIGRATION_MASTER_PLAN.md`
- [ ] Is this module in a stream? Which one?
- [ ] Are dependencies already migrated?
- [ ] Read existing migrated modules for patterns

### STEP 3: DESIGN PYTHON CLASS
- [ ] NOT a Nautilus Indicator (use plain class)
- [ ] Define `__init__` with typed parameters
- [ ] Define main method (analyze, calculate, etc.)
- [ ] Define return type (use dataclass from `data_types.py`)
- [ ] Plan: numpy for calculations

### STEP 4: IMPLEMENT
- [ ] Create file: `nautilus_gold_scalper/src/[category]/[module].py`
- [ ] Add docstring: "Migrated from: MQL5/..."
- [ ] Implement class with type hints EVERYWHERE
- [ ] Handle errors: raise `InsufficientDataError`, etc.
- [ ] Add unit test in `tests/test_[category]/`

### STEP 5: VALIDATE
- [ ] Compare outputs: MQL5 vs Python
- [ ] Performance benchmark (< 1ms for analyze())
- [ ] Update MASTER_PLAN status
- [ ] → ORACLE for statistical validation if trading logic

---

## Strategy Creation Checklist

### Pre-Implementation
- [ ] Define clear trading logic
- [ ] Identify required indicators/modules
- [ ] Define config parameters with Pydantic
- [ ] Plan event handlers needed

### Implementation
- [ ] Create `StrategyConfig` with typed fields
- [ ] Create Strategy class extending `Strategy`
- [ ] Call `super().__init__(config)` first!
- [ ] Implement `on_start()` with subscriptions
- [ ] Implement `on_stop()` with cleanup
- [ ] Implement `on_bar()` with trading logic
- [ ] Add type hints to ALL methods

### Testing
- [ ] Unit tests for signal generation
- [ ] Backtest with realistic data
- [ ] Performance profiling (< 1ms for handlers)
- [ ] Edge cases: no data, partial fills

---

## Backtest Setup Checklist

### Data Preparation
- [ ] ParquetDataCatalog exists at correct path
- [ ] Instruments available: `catalog.instruments()`
- [ ] Data range covers test period
- [ ] Quote ticks or bars available

### Configuration
- [ ] `BacktestRunConfig` created
- [ ] Strategy config with all required params
- [ ] Venue config (APEX, NETTING, MARGIN)
- [ ] Starting balance appropriate
- [ ] Fill model configured (slippage, prob_fill)

### Execution
- [ ] `BacktestNode` instantiated
- [ ] Run with `node.run()`
- [ ] Generate reports
- [ ] Extract key metrics

### Validation (→ ORACLE)
- [ ] Sharpe ratio reasonable
- [ ] Max drawdown within limits
- [ ] Trade count sufficient for statistics
- [ ] No look-ahead bias
- [ ] Request WFA + Monte Carlo

---

## Code Review Checklist

### Type Safety
- [ ] All function parameters typed
- [ ] All return types specified
- [ ] No `Any` types (except when necessary)
- [ ] Dataclasses for complex returns

### Performance
- [ ] Handlers under latency targets
- [ ] numpy used for calculations
- [ ] No unnecessary object creation
- [ ] Pre-allocated arrays where possible

### Event-Driven
- [ ] State accessed via cache
- [ ] No global variables
- [ ] Events handled appropriately
- [ ] MessageBus used for communication

### Safety
- [ ] Error handling present
- [ ] OrderRejected/Denied handled
- [ ] Position limits checked
- [ ] No hardcoded values

---

## Pre-Live Checklist

### Strategy Validation
- [ ] Backtest passed with good metrics
- [ ] WFA shows robustness (WFE >= 0.6)
- [ ] Monte Carlo 95th percentile DD acceptable
- [ ] Paper trading successful

### Risk Configuration
- [ ] Apex trailing DD rules implemented
- [ ] Position sizing correct
- [ ] Max positions limit set
- [ ] Session filter active

### Infrastructure
- [ ] Broker adapter configured
- [ ] Data feeds connected
- [ ] Logging enabled
- [ ] Monitoring in place

### Final Checks
- [ ] No TODO/FIXME in production code
- [ ] All tests passing
- [ ] Documentation updated
- [ ] → SENTINEL for final risk approval
