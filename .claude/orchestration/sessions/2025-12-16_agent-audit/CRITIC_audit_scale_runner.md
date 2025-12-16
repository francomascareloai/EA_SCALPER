# CRITIC ADVERSARIAL AUDIT: SCALE-RUNNER v1.0

**Artifact**: `.claude/agents/scale-runner.md`
**Type**: Agent Specification
**Reviewer**: CRITIC v1.1
**CLAUDE.md Version**: v3.10.9
**Date**: 2025-12-16

---

## VERDICT: ISSUES_FOUND

The spec provides a solid foundation for massive backtest orchestration but has critical gaps in safety limits, Apex compliance integration, and CLAUDE.md protocol adherence. **Not recommended for production use without revisions.**

---

## CRITICAL ISSUES (must fix)

### CRIT-1: No Grid Size Limit - Combinatorial Explosion Risk

**Location**: Section "Parameter Grid Generation" and "Safety Gates"
**Impact**: User could specify 10 params x 10 values = 10^10 combinations, causing OOM or weeks of compute time with no warning.

**Current State**:
```python
def generate_parameter_grid(params: dict) -> list[dict]:
    """Generate all combinations for parameter sweep."""
    # No limit check!
    return [dict(zip(keys, combo)) for combo in product(*values)]
```

**Fix**: Add explicit limits and warnings:
```python
MAX_GRID_SIZE = 10_000  # Configurable

def generate_parameter_grid(params: dict, max_size: int = MAX_GRID_SIZE) -> list[dict]:
    # Calculate size before generating
    total = reduce(lambda x, y: x * len(y), params.values(), 1)
    if total > max_size:
        raise ValueError(f"Grid too large: {total} > {max_size}. Use random sampling or reduce space.")
    ...
```

---

### CRIT-2: Missing Apex-Specific Metrics in Optimization

**Location**: "Output Artifacts" and "Validation Thresholds"
**Impact**: Configs optimized without Apex constraints could pass SQN/Sharpe but fail Apex rules in live trading.

**Missing Metrics**:
1. **Trailing DD from HWM** (not just max_dd) - Apex uses HWM including unrealized
2. **30% Consistency Rule** - max profit per day must be tracked
3. **Time Gate Compliance** - 4:30 PM block, 4:55 PM force-close simulation
4. **Buffer Compliance** - 4% trailing / 4.5% total buffers

**Fix**: Add Apex-specific columns to results_df:
```python
results_df.columns = [
    ...
    "trailing_dd_from_hwm",  # Critical for Apex
    "max_daily_profit_pct",   # For 30% rule
    "time_gate_violations",   # Count of 4:30/4:55 PM issues
    "apex_buffer_breaches",   # Count of 4%/4.5% breaches
]
```

---

### CRIT-3: Parallel Execution Code Has No Timeout/Exception Handling

**Location**: "Parallel Execution Strategy" code example
**Impact**: A hanging backtest blocks forever; first exception crashes entire batch.

**Current State**:
```python
for future in futures:
    results.append(future.result())  # No timeout, no try/except!
```

**Fix**:
```python
from concurrent.futures import as_completed, TimeoutError

BACKTEST_TIMEOUT = 3600  # 1 hour per config

def run_parallel_backtests(...):
    results = []
    failed = []
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        future_to_cfg = {executor.submit(runner_fn, cfg): cfg for cfg in configs}
        for future in as_completed(future_to_cfg, timeout=BACKTEST_TIMEOUT * len(configs)):
            cfg = future_to_cfg[future]
            try:
                results.append(future.result(timeout=BACKTEST_TIMEOUT))
            except TimeoutError:
                failed.append({"config": cfg, "error": "Timeout"})
            except Exception as e:
                failed.append({"config": cfg, "error": str(e)})
    return results, failed
```

---

## HIGH ISSUES

### HIGH-1: No Structured Handoff Format per CLAUDE.md

**Location**: "Handoffs" and "Integration with ORACLE"
**Impact**: Context lost between SCALE-RUNNER and ORACLE; ORACLE doesn't know search space or rejection reasons.

**Current State**:
```
Handoff -> ORACLE for WFA + Monte Carlo
```

**CLAUDE.md Requirement**:
```markdown
## HANDOFF: SCALE-RUNNER -> ORACLE

### Context
- Task: Parameter sweep for SMC strategy
- Grid Size: 256 configurations
- Execution Time: 2h 15m

### Decisions Made
- Primary metric: SQN (rationale: most robust to outliers)
- Rejected 180 configs with SQN < 1.5

### Assumptions
- Backtest data representative of future regime mix
- No look-ahead bias in feature calculation

### Risks Identified
- Top 3 configs cluster around fast_period=10 (low diversity)
- Parameter cliff detected at atr_multiplier=1.5

### Open Questions
- Should ORACLE run regime-stratified WFA?

### Next Agent Should
- Run WFA on top 5 configs
- Check trailing DD from HWM specifically
- Validate 30% consistency rule
```

**Fix**: Add structured handoff template to spec and mandate its use.

---

### HIGH-2: Missing Version Reporting in Output

**Location**: Entire spec
**Impact**: Non-compliance with CLAUDE.md v3.10.9 version_reporting protocol.

**CLAUDE.md Requirement**:
```
## Agent Output Header
AGENT: SCALE-RUNNER
VERSION: v1.0
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE/PARTIAL/FAILED
```

**Fix**: Add output header format to "Output Artifacts" section.

---

### HIGH-3: No Checkpointing/Resume for Long-Running Optimizations

**Location**: "Phase 2: Execution"
**Impact**: If interrupted at batch 3/4, all progress lost.

**Current State**: Mentions "progress tracking" but no implementation.

**Fix**: Add checkpoint protocol:
```python
CHECKPOINT_DIR = ".scale_runner_checkpoints/"

def checkpoint_results(batch_id: int, results: list):
    with open(f"{CHECKPOINT_DIR}/batch_{batch_id}.json", "w") as f:
        json.dump(results, f)

def resume_from_checkpoint() -> int:
    """Return last completed batch number."""
    ...
```

---

### HIGH-4: No Parameter Constraint Validation

**Location**: "Parameter Grid Generation"
**Impact**: Invalid combinations (e.g., fast_period > slow_period) waste compute.

**Fix**: Add constraint specification:
```python
def generate_parameter_grid(
    params: dict,
    constraints: list[Callable[[dict], bool]] = None,
) -> list[dict]:
    """Generate valid combinations only."""
    all_combos = [dict(zip(params.keys(), combo)) for combo in product(*params.values())]
    if constraints:
        return [c for c in all_combos if all(fn(c) for fn in constraints)]
    return all_combos

# Usage
constraints = [
    lambda c: c["fast_period"] < c["slow_period"],
    lambda c: c["atr_multiplier"] >= 1.0,
]
```

---

### HIGH-5: Boundary Between SCALE-RUNNER and ORACLE Unclear

**Location**: "Workflow" and "Integration with ORACLE"
**Impact**: Confusion about who does what; potential duplication or gaps.

**Current State**:
- SCALE-RUNNER: "analyze -> report"
- ORACLE: "WFA, Monte Carlo, PSR/DSR"

**Ambiguity**:
- Who computes SQN - SCALE-RUNNER (for ranking) or ORACLE (for validation)?
- Who decides if a config "passes" - SCALE-RUNNER or ORACLE?

**Fix**: Add explicit boundary definition:
```
SCALE-RUNNER (Exploration):
- Generate grid
- Run backtests (simple metrics: trades, PnL, max_dd)
- Rank by primary metric
- Filter by minimum thresholds
- Output: top N candidates + search metadata

ORACLE (Validation):
- Walk-Forward Analysis
- Monte Carlo simulation
- PSR/DSR/PBO calculation
- Regime stratification
- GO/NO-GO decision
```

---

## MEDIUM ISSUES

### MED-1: No Regime-Stratified Search

**Impact**: Grid search on mixed regimes hides regime-specific failures.

**Fix**: Add regime tagging and stratified evaluation option.

---

### MED-2: Commands Table Misleading

**Location**: "Commands" section
**Impact**: Users may try `/grid`, `/run` etc. which are not real slash commands.

**Fix**: Either:
1. Create actual slash commands in `.claude/commands/`
2. Rename to "Internal Functions" and clarify these are conceptual

---

### MED-3: No Diversity-Aware Top-N Selection

**Impact**: Top 5 configs could be nearly identical (e.g., fast_period in 9-11 range).

**Fix**: Add correlation/diversity filter to top-N selection.

---

### MED-4: Memory Estimation Algorithm Missing

**Location**: "Resource Management"
**Impact**: "Batch size based on available RAM" is vague.

**Fix**: Add formula:
```python
def estimate_memory_per_backtest(data_size_mb: float, strategy_complexity: str) -> float:
    """Return estimated RAM in MB per backtest."""
    base = data_size_mb * 2  # Data + working copy
    multiplier = {"simple": 1.5, "moderate": 2.5, "complex": 4.0}
    return base * multiplier.get(strategy_complexity, 2.5)

def calculate_batch_size(available_ram_mb: float, per_backtest_mb: float, workers: int) -> int:
    """Return safe batch size."""
    parallel_ram = per_backtest_mb * workers
    return max(1, int(available_ram_mb / parallel_ram))
```

---

### MED-5: No Alternative Search Strategies

**Impact**: Grid search is inefficient for high-dimensional spaces.

**Fix**: Add alternatives:
- Random search (Bergstra & Bengio 2012)
- Bayesian optimization (Optuna integration)
- Successive Halving / Hyperband

---

### MED-6: Inconsistent Thinking Protocol

**Location**: "Mandatory Thinking Protocol" and "CRITIC Self-Review Protocol"
**Impact**: Spec says 8-12 thoughts; CRITIC says 12-15 for critical reviews.

**Fix**: Clarify:
- Standard operation: 8-12 thoughts
- Self-review (adversarial): 12-15 thoughts

---

## LOW ISSUES

### LOW-1: Example Session Is Illustrative Only

The example session shows progress bars but no actual implementation.

### LOW-2: No Deduplication in Grid Generation

If user accidentally includes duplicates, they run twice.

### LOW-3: Hardcoded catalog_path

`catalog_path="catalog"` should be configurable.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Grid search is sufficient | Random search often finds good params faster (Bergstra & Bengio 2012) | Add alternative strategies |
| Top N by single metric is good | Ignores multi-objective tradeoffs (Sharpe vs DD) | Add Pareto frontier or weighted scoring |
| Parallel backtests are isolated | They share filesystem/memory; corruption possible | Document isolation requirements |
| Results are reproducible | No seed specified for random components | Add reproducibility protocol |
| ORACLE will validate properly | Handoff lacks context about search space | Use structured handoff format |

---

## EDGE CASES TESTED

| Scenario | Current Handling | Recommendation |
|----------|------------------|----------------|
| Empty parameter grid (`params = {}`) | Returns `[{}]` - 1 empty config | Raise ValueError |
| Single-value params (grid of 1) | Runs pointlessly | Warn user |
| 0 trades in backtest | Division by zero in metrics | Handle gracefully, filter out |
| All configs fail validation | Not explicitly handled | Report "no valid configs" |
| fast_period > slow_period | Runs invalid config | Add constraint validation |
| 50% of backtests fail | First exception stops all | Use exception handling per future |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| Grid size 10,000+ | No warning, OOM likely |
| 4 parallel backtests x 4GB each | 16GB RAM, no estimation |
| Single backtest hangs | Blocks forever |
| Interrupted at batch 3/4 | All progress lost |
| 256 results x 100MB each | 25GB disk, no monitoring |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify BacktestNode configuration matches current NautilusTrader API
- [ ] Confirm `data_cls="nautilus_trader.model.data.QuoteTick"` is correct import path
- [ ] Test ProcessPoolExecutor behavior with NautilusTrader (some frameworks don't parallelize well)
- [ ] Validate memory estimates on actual hardware

---

## CONFIDENCE: MEDIUM

**Reason**: The spec is well-structured and demonstrates understanding of the domain, but critical safety mechanisms are missing. Code examples are illustrative but not production-ready. Integration with CLAUDE.md protocols needs work.

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Grid explosion + OOM crash during large optimization, losing all progress with no checkpoint.

**Second most likely**: Config passes SCALE-RUNNER ranking but fails Apex due to trailing DD from HWM (metric not tracked).

**Mitigation**:
1. Add grid size limits with explicit rejection
2. Add Apex-specific metrics to results
3. Implement checkpointing before any production use

---

## RECOMMENDATIONS FOR REVISION

### Priority 1 (CRITICAL - Block Production)
1. Add MAX_GRID_SIZE limit with clear error message
2. Add timeout and exception handling to parallel execution
3. Add Apex-specific metrics (trailing DD from HWM, 30% consistency, time gates)

### Priority 2 (HIGH - Block Handoff)
1. Implement structured handoff format per CLAUDE.md
2. Add version reporting header
3. Add checkpointing for long-running optimizations
4. Add parameter constraint validation
5. Clarify SCALE-RUNNER vs ORACLE boundary

### Priority 3 (MEDIUM - Quality)
1. Add regime-stratified search option
2. Fix misleading commands table
3. Add memory estimation formula
4. Add alternative search strategies
5. Harmonize thinking protocol (8-12 vs 12-15)

### Priority 4 (LOW - Nice to Have)
1. Add deduplication
2. Make catalog_path configurable
3. Add actual progress reporting implementation

---

*CRITIC v1.1 - Adversarial Quality Guardian*
*"Every bug found now is a loss prevented later."*
