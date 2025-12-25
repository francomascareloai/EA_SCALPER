# FORGE Round 2 - Optimization Script Analysis

```
AGENT: FORGE-NAUTILUS
VERSION: 1.1
CLAUDE_MD_VERSION: 3.10.22
STATUS: COMPLETE
```

**Files Analyzed:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/scripts/optimize.py` (1038 lines)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/config.py` (523 lines)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/optimizer.py` (371 lines)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/search/grid.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/search/random.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/search/bayesian.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/streaming/persistence.py`

---

## Executive Summary

Round 2 analyzed the remaining HIGH (H2-H5) and MEDIUM (MED-2 through MED-5) issues from Round 1. Key findings:

| Fixed in Round 1 | Still Outstanding |
|------------------|-------------------|
| H2: Memory exhaustion (max_results_in_ram=500 default) | H3: --resume flag is dead code |
| H4: File handle leaks (atomic writes) | H5: Parallel RNG not isolated |
| MED-4: Data path resolution (PROJECT_ROOT anchor) | MED-2: CLI `or` pattern bugs |
| | MED-3: Config validation fails late |
| | MED-5: Indicator warmup not handled |

**New Issues Discovered:**
- NEW-1: Overly broad exception catching (MEDIUM)
- NEW-2: Missing type annotations on extraction functions (LOW)
- NEW-4: Empty DataFrame as error indicator (MEDIUM)
- NEW-5: No per-trial timeout in grid/random search (HIGH)
- NEW-7: No checkpoint persistence for long runs (MEDIUM)

---

## Status of Round 1 Issues

### H2: Memory Exhaustion on Large Grid Search - FIXED

**Status**: Already implemented via `max_results_in_ram` default.

**Evidence**:
- `config.py:265`: `max_results_in_ram: int | None = 500` (default)
- `optimizer.py:128,142,158`: Passes `max_results_in_ram` to grid/random/successive_halving searchers
- `streaming/persistence.py`: Full streaming implementation with Parquet sink

**No action required.**

---

### H3: --resume Flag Unimplemented - UNADDRESSED

**Location**: `scripts/optimize.py:386-391`

**Problem**: The `--resume` argument is defined but never used anywhere in the codebase.

```python
parser.add_argument(
    "--resume",
    type=str,
    default=None,
    help="Path to checkpoint file to resume from",
)
```

**Impact**:
- Dead code confuses users expecting resume functionality
- Long-running optimizations (hours/days) cannot recover from crashes
- Wasted compute if optimization fails mid-run

**Recommended Actions**:
1. **Option A**: Implement checkpoint/resume (4h effort)
   - Save checkpoint every N trials to `output_dir/checkpoint.json`
   - On resume, load checkpoint and skip completed trials
   - Requires idempotent trial execution (see G-1 below)

2. **Option B**: Remove dead code (5m effort)
   - Delete lines 386-391
   - Add TODO comment: "Resume functionality planned for v2"

**Severity**: HIGH (user expectation mismatch + operational risk)

---

### H4: File Handle Leaks - FIXED

**Status**: Already implemented via atomic write pattern.

**Evidence**:
- Lines 86-130: `_atomic_write()` and `_atomic_write_csv()` functions
- Lines 99-110, 121-130: Proper cleanup in except blocks
- Line 884: Uses `_atomic_write(config_snapshot, ...)`

**No action required.**

---

### H5: Parallel RNG Not Isolated - UNADDRESSED

**Location**: `scripts/optimize.py:856-858`

**Problem**: Global RNG state is set, but not isolated per worker/trial.

```python
seed = config.search.seed or 42
random.seed(seed)
np.random.seed(seed)
```

**Impact**:
- All parallel workers share the same RNG seed initially
- Results become non-reproducible when parallelism changes
- Latin Hypercube Sampling produces correlated samples across workers
- Monte Carlo stress tests may have hidden correlations

**Fix - Option A (Quick)**: Per-trial seeding

```python
def _get_trial_rng(base_seed: int, trial_id: int) -> np.random.Generator:
    """Create isolated RNG for a trial."""
    return np.random.default_rng(base_seed + trial_id)
```

**Fix - Option B (Robust)**: SeedSequence for spawn-safe seeding

```python
from numpy.random import SeedSequence, default_rng

def create_worker_rngs(base_seed: int, n_workers: int) -> list[np.random.Generator]:
    """Create independent RNGs for parallel workers."""
    ss = SeedSequence(base_seed)
    child_seeds = ss.spawn(n_workers)
    return [default_rng(s) for s in child_seeds]
```

**Severity**: HIGH (affects reproducibility and statistical validity)

---

## Status of MEDIUM Issues

### MED-2: CLI Override Uses `or` Pattern - UNADDRESSED

**Locations**: Lines 449, 673-675, 780-784, 791-792

**Problem**: The `or` operator treats `0`, empty string, and `None` as falsy.

```python
# Line 673
trials = args.trials or config.search.trials
# If user passes --trials 0, this falls back to config!

# Line 675
seed = args.seed or config.search.seed
# If user passes --seed 0, this falls back to config!
```

**Impact**:
- `--trials 0` silently falls back to config (probably intended to error)
- `--seed 0` silently falls back to config (valid seed!)
- `--parallelism 0` silently falls back (could be valid for serial mode)

**Fix**: Use explicit `None` check

```python
# Before
trials = args.trials or config.search.trials

# After
trials = args.trials if args.trials is not None else config.search.trials

# Or use a helper:
def coalesce(*values: T | None) -> T | None:
    """Return first non-None value (like SQL COALESCE)."""
    for v in values:
        if v is not None:
            return v
    return None

trials = coalesce(args.trials, config.search.trials)
```

**Severity**: MEDIUM (semantic bug, but edge case)

---

### MED-3: Config Validation Fails Late - UNADDRESSED

**Location**: `src/optimization/config.py:286-296`

**Problem**: `OptimizationConfig.from_yaml()` loads data but doesn't validate cross-field constraints.

Missing validations:
- `train_end > train_start` (date ordering)
- `test_start > train_end` (no data leakage)
- `successive_halving.window_days` length matches `wfa_windows` length
- Grid mode size check vs `max_grid_size`

**Impact**: Invalid configs fail deep in execution, wasting setup time.

**Fix**: Add `validate()` method called at end of `from_yaml()`

```python
def validate(self) -> None:
    """Cross-field validation. Raises ValueError on invalid config."""
    from datetime import datetime

    # Date ordering
    train_start = datetime.strptime(self.data.train_start, "%Y-%m-%d")
    train_end = datetime.strptime(self.data.train_end, "%Y-%m-%d")
    if train_end <= train_start:
        raise ValueError(
            f"train_end ({self.data.train_end}) must be after "
            f"train_start ({self.data.train_start})"
        )

    # Test/train ordering
    test_start = datetime.strptime(self.data.test_start, "%Y-%m-%d")
    if test_start <= train_end:
        raise ValueError(
            f"test_start ({self.data.test_start}) must be after "
            f"train_end ({self.data.train_end}) to prevent data leakage"
        )

    # Successive halving consistency
    sh = self.search.successive_halving
    if len(sh.window_days) != len(sh.wfa_windows):
        raise ValueError(
            f"window_days length ({len(sh.window_days)}) must match "
            f"wfa_windows length ({len(sh.wfa_windows)})"
        )

@classmethod
def from_yaml(cls, path: str | Path) -> "OptimizationConfig":
    # ... existing loading code ...
    config = cls._from_dict(raw)
    config.validate()  # Add this line
    return config
```

**Severity**: MEDIUM (fails late, wastes time)

---

### MED-4: Fragile Data Path Resolution - FIXED

**Status**: Already implemented correctly.

**Evidence**:
- Line 57: `PROJECT_ROOT = Path(__file__).parent.parent` (anchored to script location)
- Lines 422-423: Relative paths resolved against PROJECT_ROOT

```python
if not Path(data_path).is_absolute():
    data_path = str(PROJECT_ROOT / data_path)
```

**No action required.**

---

### MED-5: Indicator Warmup Period Not Handled - UNADDRESSED

**Problem**: Indicators require N bars of history before producing valid signals.

**Evidence from codebase**:
- `order_block_detector.py:51`: `lookback_bars: int = 50`
- `liquidity_sweep.py:52`: `lookback_bars: int = 20`
- `mtf_manager.py:97-99`: `htf_lookback_bars: int = 100`, `mtf_lookback_bars: int = 100`, `ltf_lookback_bars: int = 50`
- `reports/signal_flow_diagnosis.md:82`: "First ~200 bars have insufficient data" (documented as expected)

**Current handling**:
- `order_block_detector.py:99-100`: Raises `InsufficientDataError` if less than `lookback_bars`
- Other indicators return empty results until sufficient data

**Impact**:
- First ~200 bars of signals may be invalid/garbage
- These invalid signals may bias optimization metrics (especially if early trades are counted)
- Wastes compute evaluating warmup period

**Fix**: Add warmup period to config and data loading

```python
# In DataConfig:
warmup_bars: int = 200  # Extra bars to load before train_start

# In BacktestRunner or data loading:
def load_data_with_warmup(path: str, train_start: str, warmup_bars: int):
    warmup_start = compute_warmup_start(train_start, warmup_bars)
    data = load_data(path, warmup_start, train_end)
    return data, warmup_start, train_start  # Mark warmup boundary

# In metric computation:
def compute_metrics(trades_df, warmup_end: datetime):
    valid_trades = trades_df[trades_df["entry_time"] >= warmup_end]
    return calculate_sqn(valid_trades)  # Only count post-warmup trades
```

**Severity**: MEDIUM (may bias metrics, but usually minor impact)

---

## New Findings

### NEW-1: Overly Broad Exception Catching - MEDIUM

**Locations**: Lines 106, 127, 581, 656, 828, 897, 1027

**Problem**: Catching bare `Exception` hides specific error types.

```python
# Line 897
except Exception as e:
    logger.error(f"Optimization failed: {e}")
    import traceback
    traceback.print_exc()
    return 1
```

**Issues**:
- Catches programming errors (AttributeError, TypeError, KeyError)
- Makes debugging harder (same handling for all errors)
- May mask recoverable vs non-recoverable failures

**Fix**: Use specific exception types

```python
except (FileNotFoundError, yaml.YAMLError) as e:
    logger.error(f"Config loading failed: {e}")
    return 1
except KeyboardInterrupt:
    logger.info("User interrupted")
    return 130
except Exception as e:
    # Only for truly unexpected errors
    logger.exception(f"Unexpected error: {e}")
    return 1
```

**Severity**: MEDIUM (debugging friction)

---

### NEW-2: Missing Type Annotations on Extraction Functions - LOW

**Locations**:
- Line 586: `def _extract_equity_series(runner, initial_balance: float)` - missing type for `runner`
- `_extract_trades_df(runner)` - missing type for `runner`

**Fix**:

```python
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from scripts.backtest.run_backtest import BacktestRunner

def _extract_equity_series(
    runner: "BacktestRunner",
    initial_balance: float
) -> pd.Series:
    ...

def _extract_trades_df(runner: "BacktestRunner") -> pd.DataFrame:
    ...
```

**Severity**: LOW (type checker and IDE support)

---

### NEW-4: Empty DataFrame as Error Indicator - MEDIUM

**Location**: Line 583

```python
except Exception as e:
    logger.warning(f"Failed to extract trades: {e}")
    return pd.DataFrame()
```

**Problem**: Callers must check for empty DataFrame to detect errors. This is fragile:
- Empty DataFrame is also valid (strategy with 0 trades)
- No way to distinguish "no trades" from "extraction failed"

**Fix - Option A**: Return Optional with explicit None

```python
def _extract_trades_df(runner: "BacktestRunner") -> pd.DataFrame | None:
    try:
        ...
        return trades_df
    except Exception as e:
        logger.warning(f"Failed to extract trades: {e}")
        return None  # Explicit failure indicator
```

**Fix - Option B**: Use Result type (institutional pattern)

```python
from dataclasses import dataclass
from typing import TypeVar, Generic

T = TypeVar("T")

@dataclass
class Result(Generic[T]):
    value: T | None
    error: str | None = None

    @property
    def ok(self) -> bool:
        return self.error is None

    @classmethod
    def success(cls, value: T) -> "Result[T]":
        return cls(value=value)

    @classmethod
    def failure(cls, error: str) -> "Result[T]":
        return cls(value=None, error=error)

def _extract_trades_df(runner: "BacktestRunner") -> Result[pd.DataFrame]:
    try:
        ...
        return Result.success(trades_df)
    except Exception as e:
        return Result.failure(f"Failed to extract trades: {e}")
```

**Severity**: MEDIUM (ambiguous error handling)

---

### NEW-5: No Per-Trial Timeout in Grid/Random Search - HIGH

**Location**: `config.py:81` defines `timeout_per_trial: int = 300`

**Problem**: This config is UNUSED in grid/random search modes.

**Evidence**:
- `bayesian.py:131`: Uses `timeout = timeout_per_trial * trials` (TOTAL timeout, not per-trial)
- `grid.py`: No timeout handling at all (grep returned no matches)
- `random.py`: No timeout handling at all (grep returned no matches)

**Impact**: A single stuck trial blocks the entire optimization indefinitely.

**Fix**: Add per-trial timeout wrapper

```python
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FuturesTimeoutError
import functools

def with_timeout(
    fn: Callable[..., T],
    timeout_seconds: int,
    default: T | None = None,
) -> Callable[..., T | None]:
    """Wrap function with timeout. Returns default if timeout exceeded."""
    @functools.wraps(fn)
    def wrapper(*args, **kwargs) -> T | None:
        with ThreadPoolExecutor(max_workers=1) as executor:
            future = executor.submit(fn, *args, **kwargs)
            try:
                return future.result(timeout=timeout_seconds)
            except FuturesTimeoutError:
                logger.warning(f"Trial timed out after {timeout_seconds}s")
                return default
    return wrapper

# Usage in GridSearch.search():
timeout = self.config.search.timeout_per_trial
objective_with_timeout = with_timeout(objective_fn, timeout, default=self._empty_result())
```

**Severity**: HIGH (can hang indefinitely)

---

### NEW-7: No Checkpoint Persistence for Long Runs - MEDIUM

**Related to**: H3 (--resume unimplemented)

**Problem**: If optimization runs for hours and crashes, all progress is lost (except streaming parquet).

**Impact**:
- Hours of compute wasted on crash
- No ability to pause/resume overnight runs
- No incremental progress visibility

**Fix**: Implement checkpoint system

```python
@dataclass
class OptimizationCheckpoint:
    run_id: str
    completed_trial_ids: set[int]
    best_results: list[TrialResult]  # Top N
    last_checkpoint_time: datetime
    config_hash: str

    def save(self, path: Path) -> None:
        _atomic_write(path, json.dumps(asdict(self), default=str))

    @classmethod
    def load(cls, path: Path) -> "OptimizationCheckpoint":
        with open(path) as f:
            data = json.load(f)
        return cls(**data)

class CheckpointingOptimizer:
    def __init__(self, optimizer: ApexOptimizer, checkpoint_path: Path):
        self._optimizer = optimizer
        self._checkpoint_path = checkpoint_path
        self._checkpoint_interval = 10  # trials

    def run(self) -> list[TrialResult]:
        checkpoint = self._load_or_create_checkpoint()

        for trial in self._optimizer.iter_trials():
            if trial.id in checkpoint.completed_trial_ids:
                continue  # Skip already-completed

            result = self._optimizer.run_single_trial(trial)
            checkpoint.completed_trial_ids.add(trial.id)

            if len(checkpoint.completed_trial_ids) % self._checkpoint_interval == 0:
                checkpoint.save(self._checkpoint_path)

        return self._optimizer.get_results()
```

**Severity**: MEDIUM (operational risk for long runs)

---

## Genius-Level Recommendations (Institutional Grade)

### G-1: Idempotent Trial Execution

Make each trial deterministic and idempotent for reproducibility and caching:

```python
import hashlib

@dataclass(frozen=True)
class TrialSpec:
    """Immutable specification for a single trial."""
    trial_id: int
    params: frozenset[tuple[str, Any]]
    seed: int  # Derived from base_seed + trial_id

    def to_hashable(self) -> str:
        """Generate deterministic hash for caching/dedup."""
        content = json.dumps(
            {"trial_id": self.trial_id, "params": sorted(self.params), "seed": self.seed},
            sort_keys=True
        )
        return hashlib.sha256(content.encode()).hexdigest()[:16]

class TrialCache:
    """Cache trial results by spec hash."""

    def __init__(self, cache_dir: Path):
        self._cache_dir = cache_dir
        self._cache_dir.mkdir(parents=True, exist_ok=True)

    def get(self, spec: TrialSpec) -> TrialResult | None:
        path = self._cache_dir / f"{spec.to_hashable()}.json"
        if path.exists():
            return TrialResult.from_json(path.read_text())
        return None

    def put(self, spec: TrialSpec, result: TrialResult) -> None:
        path = self._cache_dir / f"{spec.to_hashable()}.json"
        _atomic_write(path, result.to_json())
```

**Benefits**:
- Exact reproducibility across runs
- Skip already-computed trials (cache hit)
- Parallel execution without RNG conflicts

---

### G-2: Trial Result Versioning

Add schema versioning for forward compatibility:

```python
@dataclass
class TrialResultV2:
    schema_version: int = 2
    trial_hash: str  # From TrialSpec.to_hashable()
    # ... existing fields ...

    @classmethod
    def from_v1(cls, v1: TrialResult) -> "TrialResultV2":
        """Migrate from v1 schema."""
        return cls(
            schema_version=2,
            trial_hash="migrated_" + str(v1.trial_id),
            **{k: v for k, v in asdict(v1).items() if k != "trial_id"}
        )
```

**Benefits**:
- Compare results across optimization runs
- Safe schema evolution without breaking existing data

---

### G-3: Distributed Execution Ready

Abstract execution backend for horizontal scaling:

```python
from typing import Protocol
from concurrent.futures import Future

class TrialExecutor(Protocol):
    def submit(self, spec: TrialSpec) -> Future[TrialResult]: ...
    def shutdown(self, wait: bool = True) -> None: ...

class LocalExecutor(TrialExecutor):
    """Single-machine multiprocessing."""
    def __init__(self, max_workers: int):
        self._pool = ProcessPoolExecutor(max_workers)

    def submit(self, spec: TrialSpec) -> Future[TrialResult]:
        return self._pool.submit(run_trial, spec)

    def shutdown(self, wait: bool = True) -> None:
        self._pool.shutdown(wait=wait)

class DaskExecutor(TrialExecutor):
    """Distributed execution via Dask."""
    def __init__(self, cluster_address: str):
        from dask.distributed import Client
        self._client = Client(cluster_address)

    def submit(self, spec: TrialSpec) -> Future[TrialResult]:
        return self._client.submit(run_trial, spec)

class RayExecutor(TrialExecutor):
    """Distributed execution via Ray."""
    def __init__(self, ray_address: str):
        import ray
        ray.init(address=ray_address)

    def submit(self, spec: TrialSpec) -> Future[TrialResult]:
        return ray.remote(run_trial).remote(spec)
```

**Benefits**:
- Unit test with LocalExecutor
- Scale to cloud clusters without code changes
- Swap backends via config

---

### G-4: Metric Store with Lineage

Track all optimization runs with full lineage:

```python
class MetricStore:
    """Persistent store for optimization results with lineage tracking."""

    def record_trial(
        self,
        trial_id: int,
        result: TrialResult,
        lineage: dict
    ) -> None:
        """Record trial with environment lineage.

        lineage includes:
        - git_hash: Current commit
        - config_hash: SHA256 of config file
        - data_hash: SHA256 of first 1MB of data file
        - python_version: sys.version
        - package_versions: {package: version}
        """
        ...

    def query_best(
        self,
        filter_fn: Callable[[TrialResult], bool],
        n: int = 10
    ) -> list[TrialResult]:
        """Query historical results across all runs."""
        ...

    def compare_runs(self, run_id_a: str, run_id_b: str) -> dict:
        """A/B comparison between optimization runs."""
        ...
```

**Benefits**:
- Full audit trail for regulatory compliance
- Compare results across environments/versions
- Debug regression when results change

---

## Priority Implementation Plan

### Phase 1 - Critical Fixes (Day 1, 4h)

| # | Issue | Effort | Impact |
|---|-------|--------|--------|
| 1 | H5: Fix parallel RNG isolation | 2h | Reproducibility |
| 2 | NEW-5: Add per-trial timeout | 2h | Prevents hangs |

### Phase 2 - Correctness Fixes (Day 2, 4h)

| # | Issue | Effort | Impact |
|---|-------|--------|--------|
| 3 | MED-2: Fix CLI `or` pattern | 1h | Semantic correctness |
| 4 | MED-3: Add config validation | 2h | Fail-fast |
| 5 | NEW-1: Specific exception types | 1h | Debuggability |

### Phase 3 - Quality Improvements (Day 3, 4h)

| # | Issue | Effort | Impact |
|---|-------|--------|--------|
| 6 | MED-5: Add warmup handling | 2h | Metric accuracy |
| 7 | NEW-2: Complete type annotations | 30m | IDE/type checker |
| 8 | NEW-4: Fix error indicators | 1h | Error handling |

### Phase 4 - Resume/Checkpoint (Day 4-5, 8h)

| # | Issue | Effort | Impact |
|---|-------|--------|--------|
| 9 | H3: Implement checkpoint/resume | 4h | Crash recovery |
| 10 | NEW-7: Progress persistence | 4h | Long run safety |

### Phase 5 - Institutional Grade (Week 2)

- G-1: Idempotent trial execution
- G-2: Result versioning
- G-3: Distributed execution abstraction
- G-4: Metric store with lineage

---

## Summary Table

| ID | Issue | Severity | Status | Effort |
|----|-------|----------|--------|--------|
| H2 | Memory exhaustion | HIGH | FIXED | - |
| H3 | --resume unimplemented | HIGH | UNADDRESSED | 4h |
| H4 | File handle leaks | HIGH | FIXED | - |
| H5 | Parallel RNG not isolated | HIGH | UNADDRESSED | 2h |
| MED-2 | CLI `or` pattern | MEDIUM | UNADDRESSED | 1h |
| MED-3 | Config validation late | MEDIUM | UNADDRESSED | 2h |
| MED-4 | Fragile data paths | MEDIUM | FIXED | - |
| MED-5 | Indicator warmup | MEDIUM | UNADDRESSED | 2h |
| NEW-1 | Broad exception catching | MEDIUM | NEW | 1h |
| NEW-2 | Missing type annotations | LOW | NEW | 30m |
| NEW-4 | Empty DataFrame as error | MEDIUM | NEW | 1h |
| NEW-5 | No per-trial timeout | HIGH | NEW | 2h |
| NEW-7 | No checkpoint persistence | MEDIUM | NEW | 4h |

**Total Effort Estimate**: ~20h for all fixes (excluding institutional-grade enhancements)

---

## Next Steps

1. **REVIEWER** should validate these findings and confirm priority
2. Implementation should start with Phase 1 (H5 + NEW-5) - highest impact
3. Consider adding automated tests for RNG isolation and timeout handling
4. Update CHANGELOG.md when fixes are applied

---

*Generated by FORGE-NAUTILUS v1.1 | 2024-12-24*
