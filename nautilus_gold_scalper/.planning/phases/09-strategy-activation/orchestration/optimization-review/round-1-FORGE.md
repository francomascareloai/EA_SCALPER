# FORGE Round 1 - Optimization Script Analysis

```
AGENT: FORGE-NAUTILUS
VERSION: 1.1
CLAUDE_MD_VERSION: 3.10.22
STATUS: COMPLETE
```

**Files Analyzed:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/scripts/optimize.py` (789 lines)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/config.py` (523 lines)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/optimizer.py` (371 lines)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/search/base.py` (103 lines)

---

## Executive Summary

- **Critical**: Missing signal handlers for graceful shutdown - long-running optimizations cannot be safely interrupted
- **Critical**: Global mutable state pattern for BacktestRunner creates thread-safety issues
- **Important**: `run_optimization()` function is 135 lines with 10+ responsibilities - violates single responsibility
- **Important**: Incomplete type annotations on key functions (`estimate_grid_size`, extraction helpers)
- **Important**: No CLI validation for critical parameters (trials > 0, valid dates, parallelism range)

---

## Code Quality Issues

### Critical

#### 1. Missing Signal Handlers for Graceful Shutdown

**Location:** `scripts/optimize.py` - entire script

**Problem:** No SIGTERM/SIGINT handlers. Long-running optimization (hours/days) cannot be gracefully stopped without data loss.

**Risk:**
- Kubernetes/systemd termination kills process immediately
- Partial results may be corrupted or lost
- Open file handles not properly closed

**Before:**
```python
def main() -> int:
    args = parse_args()
    # ... runs optimization with no signal handling
```

**After:**
```python
import signal
from contextlib import contextmanager
from typing import Generator

_shutdown_requested = False

def _signal_handler(signum: int, frame: Any) -> None:
    global _shutdown_requested
    _shutdown_requested = True
    logger.warning(f"Received signal {signum}, initiating graceful shutdown...")

@contextmanager
def graceful_shutdown() -> Generator[None, None, None]:
    """Context manager for graceful signal handling."""
    original_sigterm = signal.signal(signal.SIGTERM, _signal_handler)
    original_sigint = signal.signal(signal.SIGINT, _signal_handler)
    try:
        yield
    finally:
        signal.signal(signal.SIGTERM, original_sigterm)
        signal.signal(signal.SIGINT, original_sigint)

def is_shutdown_requested() -> bool:
    return _shutdown_requested
```

---

#### 2. Global Mutable State for Lazy Import

**Location:** `scripts/optimize.py:58-67`

**Problem:** Global `BacktestRunner = None` with mutation creates race conditions if script is imported as library.

**Before:**
```python
BacktestRunner = None

def get_backtest_runner():
    global BacktestRunner
    if BacktestRunner is None:
        from scripts.backtest.run_backtest import BacktestRunner as BR
        BacktestRunner = BR
    return BacktestRunner
```

**After:**
```python
from functools import lru_cache
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from scripts.backtest.run_backtest import BacktestRunner as BacktestRunnerType

@lru_cache(maxsize=1)
def get_backtest_runner() -> type["BacktestRunnerType"]:
    """Thread-safe lazy import of BacktestRunner."""
    from scripts.backtest.run_backtest import BacktestRunner
    return BacktestRunner
```

---

#### 3. Non-Atomic File Writes

**Location:** `scripts/optimize.py:717-760` (`_save_results`)

**Problem:** Multiple sequential file writes without atomicity. Crash mid-write leaves inconsistent state.

**Risk:** Corrupted results files, incomplete CSV/JSON that breaks analysis tools.

**Before:**
```python
def _save_results(output_dir: Path, results: list[TrialResult], summary: OptimizationResult) -> None:
    summary_path = output_dir / "summary.json"
    with open(summary_path, "w") as f:
        json.dump(asdict(summary), f, indent=2, default=str)
    # ... more files
```

**After:**
```python
import tempfile
import shutil

def _atomic_write(path: Path, content: str) -> None:
    """Write file atomically using temp file + rename."""
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=path.parent, suffix=".tmp")
    try:
        with os.fdopen(fd, "w") as f:
            f.write(content)
        shutil.move(tmp_path, path)
    except Exception:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        raise

def _save_results(output_dir: Path, results: list[TrialResult], summary: OptimizationResult) -> None:
    summary_path = output_dir / "summary.json"
    _atomic_write(summary_path, json.dumps(asdict(summary), indent=2, default=str))
    # ... use _atomic_write for all files
```

---

### Important

#### 4. Incomplete Type Annotations

**Locations:**
- `scripts/optimize.py:271` - `estimate_grid_size(parameters: list)` should be `list[ParameterSpec]`
- `scripts/optimize.py:348` - `_extract_trades_df(runner)` missing type for runner
- `scripts/optimize.py:401` - `_extract_equity_series(runner, ...)` missing type for runner

**Before:**
```python
def estimate_grid_size(parameters: list) -> int:
    """Estimate total grid size from parameters."""
    size = 1
    for p in parameters:
        if p.range and p.step:
            # ...
```

**After:**
```python
from src.optimization.config import ParameterSpec

def estimate_grid_size(parameters: list[ParameterSpec]) -> int:
    """Estimate total grid size from parameter specifications.

    Formula: product of values per parameter
    Example: 3 params with [5, 10, 4] values -> 5 * 10 * 4 = 200
    """
    size = 1
    for p in parameters:
        if p.range is not None and p.step is not None:
            n = int((p.range[1] - p.range[0]) / p.step) + 1
            size *= n
        elif p.choices is not None:
            size *= len(p.choices)
    return size
```

---

#### 5. `run_optimization()` Function Too Large (SRP Violation)

**Location:** `scripts/optimize.py:579-714` (135 lines)

**Problem:** Single function handles: config loading, CLI override, output dir creation, logging setup, seed setting, backtest fn creation, optimizer creation, config snapshot, optimization run, result processing, file saving, summary printing.

**Recommended Split:**

```python
def run_optimization(args: argparse.Namespace) -> int:
    """Main orchestration function - delegates to specialized functions."""
    config = _load_and_validate_config(args)
    if config is None:
        return 1

    context = _setup_optimization_context(args, config)

    with graceful_shutdown():
        results = _execute_optimization(context)

    if results is None:
        return 1

    _save_and_report_results(context, results)
    return 0

@dataclass
class OptimizationContext:
    """Runtime context for optimization run."""
    config: OptimizationConfig
    output_dir: Path
    seed: int
    backtest_fn: Callable
    log_file: Path

def _load_and_validate_config(args: argparse.Namespace) -> OptimizationConfig | None:
    """Load config from YAML and apply CLI overrides."""
    # ...

def _setup_optimization_context(args: argparse.Namespace, config: OptimizationConfig) -> OptimizationContext:
    """Create output directory, setup logging, prepare backtest function."""
    # ...

def _execute_optimization(context: OptimizationContext) -> list[TrialResult] | None:
    """Run the optimizer and handle interrupts."""
    # ...

def _save_and_report_results(context: OptimizationContext, results: list[TrialResult]) -> None:
    """Save results to files and print summary."""
    # ...
```

---

#### 6. Missing CLI Validation

**Location:** `scripts/optimize.py:105-268`

**Problem:** No validation of argument values, only types.

**Before:**
```python
parser.add_argument(
    "--trials",
    type=int,
    default=None,
    help="Number of trials (overrides config)",
)
```

**After:**
```python
def positive_int(value: str) -> int:
    """Validate positive integer argument."""
    ivalue = int(value)
    if ivalue <= 0:
        raise argparse.ArgumentTypeError(f"Must be positive, got {value}")
    return ivalue

def valid_date(value: str) -> str:
    """Validate date format YYYY-MM-DD."""
    try:
        datetime.strptime(value, "%Y-%m-%d")
        return value
    except ValueError:
        raise argparse.ArgumentTypeError(f"Invalid date format: {value}, expected YYYY-MM-DD")

parser.add_argument(
    "--trials",
    type=positive_int,
    default=None,
    help="Number of trials (must be > 0, overrides config)",
)

parser.add_argument(
    "--start-date",
    type=valid_date,
    default=None,
    help="Training start date YYYY-MM-DD (overrides config)",
)
```

---

#### 7. Magic Numbers Throughout

**Locations:** Multiple

**Before:**
```python
# Line 239
default=100_000.0,

# Line 249
default=5,

# Line 324
seed=args.seed or config.search.seed or 42,
```

**After:**
```python
# At module level, after imports
# =============================================================================
# CONSTANTS
# =============================================================================

DEFAULT_INITIAL_BALANCE: float = 100_000.0
DEFAULT_LTF_MINUTES: int = 5
DEFAULT_SEED: int = 42
DEFAULT_SAMPLE_RATE: float = 1.0

LOG_FORMAT: str = "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
DATE_FORMAT: str = "%Y-%m-%d %H:%M:%S"
SESSION_ID_FORMAT: str = "%Y%m%d_%H%M%S"

# Then use constants:
parser.add_argument("--initial-balance", type=float, default=DEFAULT_INITIAL_BALANCE, ...)
seed = args.seed or config.search.seed or DEFAULT_SEED
```

---

#### 8. Accessing Private Attribute on Interrupt

**Location:** `scripts/optimize.py:654-655`

**Problem:** `optimizer._results` accesses private attribute when interrupted.

**Before:**
```python
except KeyboardInterrupt:
    logger.warning("Optimization interrupted by user")
    results = optimizer._results  # Private attribute access
```

**After (in optimizer.py):**
```python
class ApexOptimizer:
    def get_partial_results(self) -> list[TrialResult]:
        """Get results collected so far (safe for interrupt recovery)."""
        return list(self._results)  # Return copy to prevent mutation
```

Then in optimize.py:
```python
except KeyboardInterrupt:
    logger.warning("Optimization interrupted by user")
    results = optimizer.get_partial_results()
```

---

### Minor

#### 9. Emoji in Terminal Output

**Location:** `scripts/optimize.py:472`

```python
print(f"  ⚠️  WARNING: Exceeds max_grid_size={config.search.max_grid_size}")
```

**Problem:** Emoji may not render correctly on all terminals (especially Windows cmd, CI logs).

**Fix:** Use ASCII alternatives or check terminal capabilities.

```python
WARNING_PREFIX = "[!]" if not _supports_unicode() else "\u26a0\ufe0f"
```

---

#### 10. Import Inside Function

**Location:** `scripts/optimize.py:631`

```python
import yaml
with open(config_snapshot, "w") as f:
```

**Fix:** Move to top of file with other imports.

---

## Recommended Improvements

### Priority Order

| # | Issue | Severity | Effort | Impact |
|---|-------|----------|--------|--------|
| 1 | Add signal handlers | CRITICAL | 2h | Prevents data loss on termination |
| 2 | Fix global mutable state | CRITICAL | 30m | Thread safety |
| 3 | Add atomic file writes | CRITICAL | 1h | Data integrity |
| 4 | Complete type annotations | IMPORTANT | 1h | Maintainability, IDE support |
| 5 | Split run_optimization | IMPORTANT | 2h | Testability, readability |
| 6 | Add CLI validation | IMPORTANT | 1h | User experience, fail-fast |
| 7 | Extract constants | IMPORTANT | 30m | Maintainability |
| 8 | Add public accessor for results | IMPORTANT | 15m | Clean API |
| 9 | Fix emoji output | MINOR | 15m | Compatibility |
| 10 | Move import to top | MINOR | 5m | Style |

---

## Genius-Level Enhancements

These are patterns used by top-tier hedge funds and institutional trading systems:

### 1. Observability Layer (OpenTelemetry)

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider

tracer = trace.get_tracer(__name__)

def run_optimization(args: argparse.Namespace) -> int:
    with tracer.start_as_current_span("optimization_run") as span:
        span.set_attribute("config.mode", config.search.mode)
        span.set_attribute("config.trials", config.search.trials)
        # ... enables distributed tracing across optimization runs
```

### 2. Reproducibility Manifest

```python
@dataclass
class ReproducibilityManifest:
    """Full environment capture for exact reproduction."""
    command_line: list[str]
    git_hash: str
    git_dirty: bool
    python_version: str
    package_versions: dict[str, str]
    config_hash: str  # SHA256 of config file
    data_hash: str    # SHA256 of first 1MB of data file
    timestamp_utc: str

    @classmethod
    def capture(cls) -> "ReproducibilityManifest":
        import subprocess
        import hashlib
        import pkg_resources

        return cls(
            command_line=sys.argv,
            git_hash=subprocess.check_output(
                ["git", "rev-parse", "HEAD"], text=True
            ).strip(),
            # ... capture all environment
        )
```

### 3. Circuit Breaker for Repeated Failures

```python
class TrialCircuitBreaker:
    """Stops optimization if too many trials fail consecutively."""

    def __init__(self, max_failures: int = 10, reset_after: int = 5):
        self._consecutive_failures = 0
        self._max_failures = max_failures
        self._reset_after = reset_after
        self._successes_since_failure = 0
        self._is_open = False

    def record_success(self) -> None:
        self._consecutive_failures = 0
        self._successes_since_failure += 1
        if self._successes_since_failure >= self._reset_after:
            self._is_open = False

    def record_failure(self) -> None:
        self._consecutive_failures += 1
        self._successes_since_failure = 0
        if self._consecutive_failures >= self._max_failures:
            self._is_open = True
            raise CircuitBreakerOpenError(
                f"Circuit breaker opened after {self._max_failures} consecutive failures"
            )

    def is_open(self) -> bool:
        return self._is_open
```

### 4. Structured JSON Logging with Correlation IDs

```python
import uuid
import structlog

def setup_structured_logging(run_id: str | None = None) -> str:
    """Configure structured logging with correlation ID."""
    run_id = run_id or str(uuid.uuid4())[:8]

    structlog.configure(
        processors=[
            structlog.stdlib.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer(),
        ],
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
    )

    # Bind run_id to all subsequent logs
    structlog.contextvars.bind_contextvars(run_id=run_id)
    return run_id

# Usage:
logger = structlog.get_logger()
logger.info("trial_complete", trial_id=42, score=0.85, duration_ms=1234)
# Output: {"event": "trial_complete", "run_id": "a1b2c3d4", "trial_id": 42, ...}
```

### 5. Resource-Aware Execution

```python
import psutil
import resource

class ResourceGuard:
    """Monitor and limit resource usage during optimization."""

    def __init__(
        self,
        max_memory_gb: float = 32.0,
        max_disk_usage_pct: float = 90.0,
    ):
        self._max_memory_bytes = int(max_memory_gb * 1024**3)
        self._max_disk_usage_pct = max_disk_usage_pct

    def check_memory(self) -> None:
        """Raise if memory usage exceeds limit."""
        mem = psutil.Process().memory_info().rss
        if mem > self._max_memory_bytes:
            raise ResourceExhaustedError(
                f"Memory usage {mem / 1024**3:.1f}GB exceeds limit {self._max_memory_bytes / 1024**3:.1f}GB"
            )

    def check_disk(self, path: Path) -> None:
        """Raise if disk is nearly full."""
        usage = psutil.disk_usage(str(path))
        if usage.percent > self._max_disk_usage_pct:
            raise ResourceExhaustedError(
                f"Disk usage {usage.percent}% exceeds limit {self._max_disk_usage_pct}%"
            )

    def set_memory_limit(self) -> None:
        """Set soft memory limit via rlimit."""
        resource.setrlimit(
            resource.RLIMIT_AS,
            (self._max_memory_bytes, self._max_memory_bytes)
        )
```

---

## Implementation Priority

1. **Phase 1 - Critical Safety (Day 1)**
   - Add signal handlers
   - Fix global mutable state
   - Add atomic file writes

2. **Phase 2 - Type Safety and Validation (Day 2)**
   - Complete all type annotations
   - Add CLI argument validation
   - Add config cross-field validation

3. **Phase 3 - Refactoring (Day 3)**
   - Split `run_optimization()` into phases
   - Extract constants
   - Add public accessor for partial results

4. **Phase 4 - Institutional Grade (Day 4-5)**
   - Add structured logging
   - Add reproducibility manifest
   - Add resource guards
   - Add circuit breaker

---

## Next Steps

1. **REVIEWER** should validate these findings and prioritize
2. Implementation should start with Phase 1 (Critical Safety)
3. Consider adding automated tests for signal handling and file atomicity
4. Update `mypy.ini` to enforce stricter type checking

---

*Generated by FORGE-NAUTILUS v1.1 | 2024-12-24*
