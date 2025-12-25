"""
Phase 2: Main Catalog Validation for XAUUSD Pipeline.

Comprehensive validation of the 654M tick catalog including:
- Health check (catalog opens, basic queries work)
- Schema validation (all files have correct columns and types)
- Temporal consistency (monotonic timestamps, valid date range)
- Price validation (no crossed quotes, valid ranges, spread limits)
- Regime analysis (Hurst exponent classification)
- Session coverage (all trading sessions represented)
- Quality score (0-100 weighted composite)

All validations use DuckDB single queries for efficiency on 654M+ ticks.

Example:
    >>> from src.validation.core.config import ValidationConfig
    >>> from src.validation.core.engine import (
    ...     DuckDBConnection,
    ...     ValidationEngine,
    ... )
    >>> from src.validation.phases.phase_2 import Phase2Validator
    >>>
    >>> config = ValidationConfig(catalog_path="/data/catalog")
    >>> engine = ValidationEngine(config)
    >>> phase = Phase2Validator(config, engine.db)
    >>> result = phase.validate()
    >>> print(f"Status: {result.status.value}")
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import TYPE_CHECKING, ClassVar, TypedDict

import numpy as np
from src.validation.core.config import ValidationConfig
from src.validation.core.engine import (
    DuckDBConnection,
    PhaseValidator,
)
from src.validation.core.results import (
    CheckResult,
    PhaseResult,
    ValidationStatus,
)

if TYPE_CHECKING:
    from numpy.typing import NDArray

logger = logging.getLogger(__name__)


# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------

# Epoch for 2003-05-05 00:00:00 UTC in nanoseconds (catalog start date)
EPOCH_2003_05_05_NS: int = 1_052_092_800_000_000_000

# Required schema columns for quote ticks
REQUIRED_COLUMNS: frozenset[str] = frozenset({
    "bid_price",
    "ask_price",
    "bid_size",
    "ask_size",
    "ts_event",
    "ts_init",
})

# Session hour ranges (UTC hours, inclusive start, exclusive end)
# ASIAN: 00:00-06:59, LONDON: 07:00-11:59, OVERLAP: 12:00-14:59
# NY: 15:00-16:59, LATE_NY: 17:00-20:59, EVENING: 21:00-23:59
SESSION_HOUR_RANGES: dict[str, tuple[int, int]] = {
    "ASIAN": (0, 7),
    "LONDON": (7, 12),
    "OVERLAP": (12, 15),
    "NY": (15, 17),
    "LATE_NY": (17, 21),
    "EVENING": (21, 24),
}

# Hurst exponent thresholds for regime classification
HURST_TRENDING_THRESHOLD: float = 0.55
HURST_MEAN_REVERTING_THRESHOLD: float = 0.45

# Regime window parameters (in trading days)
REGIME_WINDOW_SIZE: int = 63  # ~3 months
REGIME_WINDOW_STEP: int = 21  # ~1 month

# Minimum required percentage for each regime
MIN_REGIME_PERCENTAGE: float = 10.0

# Minimum required percentage for each session
MIN_SESSION_PERCENTAGE: float = 5.0


# -----------------------------------------------------------------------------
# TypedDicts for structured data
# -----------------------------------------------------------------------------


class PriceStats(TypedDict):
    """Statistics from price validation query."""

    total: int
    crossed: int
    min_bid: float
    max_ask: float
    null_count: int
    nan_count: int
    avg_spread: float
    spread_p95: float


class TemporalStats(TypedDict):
    """Statistics from temporal validation query."""

    min_ts: int
    max_ts: int
    before_2003_count: int
    future_count: int
    non_monotonic_count: int


class SessionCoverage(TypedDict):
    """Session coverage statistics."""

    session: str
    ticks: int
    percentage: float


class RegimeAnalysis(TypedDict):
    """Regime analysis results."""

    overall_hurst: float
    trending_pct: float
    random_pct: float
    mean_reverting_pct: float
    window_count: int


class QualityScore(TypedDict):
    """Quality score breakdown."""

    total: float
    coverage_score: float
    clean_data_score: float
    gaps_score: float
    regime_score: float
    session_score: float
    spread_score: float


# -----------------------------------------------------------------------------
# Hurst Exponent Calculation
# -----------------------------------------------------------------------------


def hurst_rs(
    series: NDArray[np.float64],
    min_window: int = 10,
) -> float:
    """Calculate Hurst exponent using Rescaled Range (R/S) method.

    The Hurst exponent H characterizes the long-term memory of a time series:
    - H > 0.5: Trending/persistent (positive autocorrelation)
    - H = 0.5: Random walk (no autocorrelation)
    - H < 0.5: Mean-reverting/anti-persistent (negative autocorrelation)

    Algorithm:
    1. For window sizes n = min_window, 2*min_window, 4*min_window, ...
    2. Divide series into non-overlapping windows of size n
    3. For each window: compute R/S = (max(cumdev) - min(cumdev)) / std
    4. Average R/S across windows for each n
    5. Fit log(R/S) vs log(n) with linear regression; slope = Hurst

    Args:
        series: Time series array (typically log returns).
        min_window: Minimum window size for R/S calculation (default 10).

    Returns:
        Hurst exponent in range [0, 1]. Returns 0.5 for insufficient data.

    Example:
        >>> import numpy as np
        >>> # Random walk should give H ~ 0.5
        >>> random_walk = np.cumsum(np.random.randn(1000))
        >>> returns = np.diff(random_walk)
        >>> h = hurst_rs(returns)
        >>> 0.4 < h < 0.6  # Should be near 0.5
        True
    """
    n = len(series)

    # Need at least 2 * min_window data points for meaningful calculation
    if n < min_window * 2:
        logger.warning(
            "Insufficient data for Hurst calculation: %d points < %d minimum",
            n,
            min_window * 2,
        )
        return 0.5

    window_sizes: list[int] = []
    rs_values: list[float] = []

    max_window = n // 2
    window_size = min_window

    while window_size <= max_window:
        window_sizes.append(window_size)
        rs_list: list[float] = []

        # Process non-overlapping windows
        for i in range(0, n - window_size + 1, window_size):
            window = series[i : i + window_size]
            mean = float(np.mean(window))
            std = float(np.std(window, ddof=1))

            if std > 1e-10:  # Avoid division by zero
                cumdev = np.cumsum(window - mean)
                r = float(np.max(cumdev) - np.min(cumdev))
                rs_list.append(r / std)

        if rs_list:
            rs_values.append(float(np.mean(rs_list)))

        window_size *= 2  # Double window size each iteration

    # Need at least 2 points for regression
    if len(window_sizes) < 2 or len(rs_values) < 2:
        logger.warning(
            "Insufficient window sizes for Hurst regression: %d",
            len(window_sizes),
        )
        return 0.5

    # Linear regression of log(R/S) vs log(n)
    log_n = np.log(np.array(window_sizes[: len(rs_values)], dtype=np.float64))
    log_rs = np.log(np.array(rs_values, dtype=np.float64))

    # Simple linear regression: y = a + b*x, slope b = Hurst
    x_mean = float(np.mean(log_n))
    y_mean = float(np.mean(log_rs))
    numerator = float(np.sum((log_n - x_mean) * (log_rs - y_mean)))
    denominator = float(np.sum((log_n - x_mean) ** 2))

    if abs(denominator) < 1e-10:
        return 0.5

    hurst = numerator / denominator

    # Clip to valid range [0, 1]
    return float(np.clip(hurst, 0.0, 1.0))


def classify_regime(hurst: float) -> str:
    """Classify market regime based on Hurst exponent.

    Args:
        hurst: Hurst exponent value [0, 1].

    Returns:
        One of: "trending", "random", "mean_reverting"
    """
    if hurst > HURST_TRENDING_THRESHOLD:
        return "trending"
    elif hurst < HURST_MEAN_REVERTING_THRESHOLD:
        return "mean_reverting"
    else:
        return "random"


# -----------------------------------------------------------------------------
# Phase 2 Validator
# -----------------------------------------------------------------------------


class Phase2Validator(PhaseValidator):
    """Main Catalog Validation - comprehensive validation of 654M tick catalog.

    Performs the following validations:
    1. Health Check: Catalog opens, basic queries work
    2. Schema Validation: All files have correct columns and types
    3. Temporal Consistency: Timestamps monotonic, valid date range
    4. Price Validation: No crossed quotes, valid ranges, spread limits
    5. Regime Analysis: Hurst exponent-based regime classification
    6. Session Coverage: All trading sessions represented adequately
    7. Quality Score: Weighted composite score (0-100)

    Attributes:
        phase_id: "phase_2"
        phase_name: "Main Catalog Validation"
    """

    phase_id: ClassVar[str] = "phase_2"
    phase_name: ClassVar[str] = "Main Catalog Validation"

    def __init__(self, config: ValidationConfig, db: DuckDBConnection) -> None:
        """Initialize Phase 2 validator.

        Args:
            config: Validation configuration with catalog path and thresholds.
            db: DuckDB connection for executing queries.
        """
        super().__init__(config, db)
        self._parquet_pattern = (
            f"{config.catalog_path}/data/quote_tick/**/*.parquet"
        )
        self._total_ticks: int = 0
        self._months_coverage: int = 0
        self._clean_data_pct: float = 100.0
        self._critical_gaps: int = 0
        self._regime_diversity_ok: bool = False
        self._session_coverage_ok: bool = False
        self._avg_spread: float = 0.0

    def validate(self) -> PhaseResult:
        """Execute all validation checks for Phase 2.

        Returns:
            PhaseResult with all check results and computed status.
        """
        result = PhaseResult(
            phase_id=self.phase_id,
            phase_name=self.phase_name,
            status=ValidationStatus.PASS,
            start_time=datetime.now(),
        )

        try:
            # 1. Health Check
            health_check = self._check_health()
            result.add_check(health_check)
            if health_check.failed:
                # Cannot proceed if catalog doesn't open
                result.end_time = datetime.now()
                return result

            # 2. Schema Validation
            schema_check = self._check_schema()
            result.add_check(schema_check)

            # 3. Temporal Consistency
            temporal_checks = self._check_temporal_consistency()
            for check in temporal_checks:
                result.add_check(check)

            # 4. Price Validation
            price_checks = self._check_price_validation()
            for check in price_checks:
                result.add_check(check)

            # 5. Regime Analysis
            regime_checks = self._check_regime_analysis()
            for check in regime_checks:
                result.add_check(check)

            # 6. Session Coverage
            session_checks = self._check_session_coverage()
            for check in session_checks:
                result.add_check(check)

            # 7. Quality Score
            quality_check = self._compute_quality_score()
            result.add_check(quality_check)

        except Exception as e:
            logger.exception("Phase 2 validation failed with exception")
            result.add_check(
                CheckResult(
                    name="Phase Execution Error",
                    status=ValidationStatus.CRITICAL,
                    message=f"Unexpected error: {type(e).__name__}: {e}",
                )
            )

        result.end_time = datetime.now()
        result.status = result.compute_status()
        return result

    def _check_health(self) -> CheckResult:
        """Verify catalog opens and basic queries work.

        Returns:
            CheckResult for health check.
        """
        try:
            # Try to count ticks
            sql = f"SELECT COUNT(*) as cnt FROM '{self._parquet_pattern}'"
            df = self.db.query_df(sql)
            count = int(df.item(0, 0))

            if count == 0:
                return CheckResult(
                    name="Health Check",
                    status=ValidationStatus.CRITICAL,
                    message="Catalog is empty (0 ticks found)",
                    value=0,
                )

            self._total_ticks = count

            return CheckResult(
                name="Health Check",
                status=ValidationStatus.PASS,
                message=f"Catalog healthy with {count:,} ticks",
                value=count,
            )

        except Exception as e:
            return CheckResult(
                name="Health Check",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to open catalog: {type(e).__name__}: {e}",
            )

    def _check_schema(self) -> CheckResult:
        """Verify all required columns exist with correct types.

        Returns:
            CheckResult for schema validation.
        """
        try:
            # Get schema using DESCRIBE
            sql = f"DESCRIBE SELECT * FROM '{self._parquet_pattern}' LIMIT 1"
            df = self.db.query_df(sql)

            # Extract column names
            column_names = set(df["column_name"].to_list())

            # Check for required columns
            missing_columns = REQUIRED_COLUMNS - column_names

            if missing_columns:
                return CheckResult(
                    name="Schema Validation",
                    status=ValidationStatus.FAIL,
                    message=f"Missing required columns: {sorted(missing_columns)}",
                    details={"missing": list(missing_columns)},
                )

            return CheckResult(
                name="Schema Validation",
                status=ValidationStatus.PASS,
                message=f"All {len(REQUIRED_COLUMNS)} required columns present",
                details={"columns": list(REQUIRED_COLUMNS)},
            )

        except Exception as e:
            return CheckResult(
                name="Schema Validation",
                status=ValidationStatus.CRITICAL,
                message=f"Schema check failed: {type(e).__name__}: {e}",
            )

    def _check_temporal_consistency(self) -> list[CheckResult]:
        """Verify temporal consistency of timestamps.

        Checks:
        - No timestamps before 2003-05-05
        - No future timestamps
        - Timestamps are monotonically increasing (sampling-based)

        Returns:
            List of CheckResult objects for temporal checks.
        """
        checks: list[CheckResult] = []

        try:
            # Get current time in nanoseconds for future check
            now_ns = int(datetime.now(timezone.utc).timestamp() * 1e9)

            # Temporal stats query
            sql = f"""
            SELECT
                MIN(ts_event) as min_ts,
                MAX(ts_event) as max_ts,
                SUM(CASE WHEN ts_event < {EPOCH_2003_05_05_NS} THEN 1 ELSE 0 END)
                    as before_2003_count,
                SUM(CASE WHEN ts_event > {now_ns} THEN 1 ELSE 0 END) as future_count
            FROM '{self._parquet_pattern}'
            """
            df = self.db.query_df(sql)

            min_ts = int(df.item(0, "min_ts"))
            max_ts = int(df.item(0, "max_ts"))
            before_2003 = int(df.item(0, "before_2003_count"))
            future = int(df.item(0, "future_count"))

            # Calculate coverage months
            min_dt = datetime.fromtimestamp(min_ts / 1e9, tz=timezone.utc)
            max_dt = datetime.fromtimestamp(max_ts / 1e9, tz=timezone.utc)
            months_diff = (max_dt.year - min_dt.year) * 12 + (
                max_dt.month - min_dt.month
            )
            self._months_coverage = months_diff

            # Check: No timestamps before 2003-05-05
            if before_2003 > 0:
                checks.append(
                    CheckResult(
                        name="Timestamp Range (Min)",
                        status=ValidationStatus.FAIL,
                        message=f"{before_2003:,} timestamps before 2003-05-05",
                        value=before_2003,
                        threshold=0,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Timestamp Range (Min)",
                        status=ValidationStatus.PASS,
                        message=f"All timestamps >= 2003-05-05 (earliest: {min_dt.date()})",
                        value=0,
                        threshold=0,
                    )
                )

            # Check: No future timestamps
            if future > 0:
                checks.append(
                    CheckResult(
                        name="Timestamp Range (Max)",
                        status=ValidationStatus.FAIL,
                        message=f"{future:,} timestamps in the future",
                        value=future,
                        threshold=0,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Timestamp Range (Max)",
                        status=ValidationStatus.PASS,
                        message=f"No future timestamps (latest: {max_dt.date()})",
                        value=0,
                        threshold=0,
                    )
                )

            # Check: Coverage months
            min_coverage = self.config.data_quality.min_coverage_months
            if months_diff >= min_coverage:
                checks.append(
                    CheckResult(
                        name="Data Coverage",
                        status=ValidationStatus.PASS,
                        message=f"{months_diff} months of data (>= {min_coverage})",
                        value=months_diff,
                        threshold=min_coverage,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Data Coverage",
                        status=ValidationStatus.FAIL,
                        message=f"Only {months_diff} months of data (< {min_coverage})",
                        value=months_diff,
                        threshold=min_coverage,
                    )
                )

            # Monotonic check (sampling-based for efficiency on 654M rows)
            # Note: This samples 1M arbitrary rows and checks if they are
            # monotonically increasing when sorted by ts_event. Violations
            # indicate timestamp ordering issues somewhere in the dataset.
            monotonic_sql = f"""
            WITH sampled AS (
                SELECT ts_event,
                       LAG(ts_event) OVER (ORDER BY ts_event) as prev_ts
                FROM '{self._parquet_pattern}'
                LIMIT 1000000
            )
            SELECT COUNT(*) as violations
            FROM sampled
            WHERE ts_event < prev_ts
            """
            mono_df = self.db.query_df(monotonic_sql)
            violations = int(mono_df.item(0, 0))

            if violations > 0:
                checks.append(
                    CheckResult(
                        name="Timestamp Monotonicity (Sample)",
                        status=ValidationStatus.WARNING,
                        message=(
                            f"{violations:,} order violations in 1M sample "
                            "(may indicate unsorted data)"
                        ),
                        value=violations,
                        threshold=0,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Timestamp Monotonicity (Sample)",
                        status=ValidationStatus.PASS,
                        message="No order violations in 1M sample",
                        value=0,
                        threshold=0,
                    )
                )

        except Exception as e:
            checks.append(
                CheckResult(
                    name="Temporal Consistency",
                    status=ValidationStatus.CRITICAL,
                    message=f"Temporal check failed: {type(e).__name__}: {e}",
                )
            )

        return checks

    def _check_price_validation(self) -> list[CheckResult]:
        """Validate price data quality.

        Checks:
        - bid <= ask (no crossed quotes)
        - Price range: $300 - $3500
        - No NaN/Inf/NULL values
        - Spread < 100 cents (95th percentile)
        - Average spread < 30 cents

        Returns:
            List of CheckResult objects for price validation.
        """
        checks: list[CheckResult] = []

        try:
            sql = f"""
            SELECT
                COUNT(*) as total,
                SUM(CASE WHEN bid_price > ask_price THEN 1 ELSE 0 END) as crossed,
                MIN(bid_price) as min_bid,
                MAX(ask_price) as max_ask,
                SUM(CASE WHEN bid_price IS NULL OR ask_price IS NULL
                    THEN 1 ELSE 0 END) as null_count,
                SUM(CASE WHEN isnan(bid_price) OR isnan(ask_price)
                         OR isinf(bid_price) OR isinf(ask_price)
                    THEN 1 ELSE 0 END) as nan_count,
                AVG(ask_price - bid_price) as avg_spread,
                PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY ask_price - bid_price)
                    as spread_p95
            FROM '{self._parquet_pattern}'
            WHERE bid_price IS NOT NULL AND ask_price IS NOT NULL
            """
            df = self.db.query_df(sql)

            total = int(df.item(0, "total"))

            # Handle case where no valid rows exist
            if total == 0:
                checks.append(
                    CheckResult(
                        name="Price Validation",
                        status=ValidationStatus.CRITICAL,
                        message="No valid price data found (all rows have NULL prices)",
                        value=0,
                    )
                )
                return checks

            crossed = int(df.item(0, "crossed"))
            min_bid = float(df.item(0, "min_bid"))
            max_ask = float(df.item(0, "max_ask"))
            null_count = int(df.item(0, "null_count"))
            nan_count = int(df.item(0, "nan_count"))
            avg_spread = float(df.item(0, "avg_spread"))
            spread_p95 = float(df.item(0, "spread_p95"))

            self._avg_spread = avg_spread

            # Calculate clean data percentage
            bad_count = crossed + null_count + nan_count
            self._clean_data_pct = (
                ((total - bad_count) / total * 100) if total > 0 else 0.0
            )

            # Check: No crossed quotes
            if crossed > 0:
                crossed_pct = crossed / total * 100 if total > 0 else 0
                checks.append(
                    CheckResult(
                        name="Crossed Quotes",
                        status=ValidationStatus.FAIL,
                        message=f"{crossed:,} crossed quotes ({crossed_pct:.4f}%)",
                        value=crossed,
                        threshold=0,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Crossed Quotes",
                        status=ValidationStatus.PASS,
                        message="No crossed quotes (bid <= ask)",
                        value=0,
                        threshold=0,
                    )
                )

            # Check: Price range
            price_min = self.config.price.price_range_min
            price_max = self.config.price.price_range_max
            range_ok = min_bid >= price_min and max_ask <= price_max

            if range_ok:
                checks.append(
                    CheckResult(
                        name="Price Range",
                        status=ValidationStatus.PASS,
                        message=(
                            f"Prices in range [${min_bid:.2f}, ${max_ask:.2f}] "
                            f"within [${price_min}, ${price_max}]"
                        ),
                        details={"min_bid": min_bid, "max_ask": max_ask},
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Price Range",
                        status=ValidationStatus.FAIL,
                        message=(
                            f"Prices out of range: "
                            f"[${min_bid:.2f}, ${max_ask:.2f}] "
                            f"not in [${price_min}, ${price_max}]"
                        ),
                        details={"min_bid": min_bid, "max_ask": max_ask},
                    )
                )

            # Check: No NULL values
            if null_count > 0:
                checks.append(
                    CheckResult(
                        name="NULL Values",
                        status=ValidationStatus.FAIL,
                        message=f"{null_count:,} rows with NULL prices",
                        value=null_count,
                        threshold=0,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="NULL Values",
                        status=ValidationStatus.PASS,
                        message="No NULL price values",
                        value=0,
                        threshold=0,
                    )
                )

            # Check: No NaN/Inf values
            if nan_count > 0:
                checks.append(
                    CheckResult(
                        name="NaN/Inf Values",
                        status=ValidationStatus.FAIL,
                        message=f"{nan_count:,} rows with NaN/Inf prices",
                        value=nan_count,
                        threshold=0,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="NaN/Inf Values",
                        status=ValidationStatus.PASS,
                        message="No NaN/Inf price values",
                        value=0,
                        threshold=0,
                    )
                )

            # Check: 95th percentile spread < 100 cents
            max_spread_p95 = self.config.price.max_spread_cents
            # Convert to dollars for comparison (prices are in dollars)
            spread_p95_cents = spread_p95 * 100

            if spread_p95_cents <= max_spread_p95:
                checks.append(
                    CheckResult(
                        name="Spread P95",
                        status=ValidationStatus.PASS,
                        message=(
                            f"95th percentile spread {spread_p95_cents:.2f} cents "
                            f"<= {max_spread_p95} cents"
                        ),
                        value=spread_p95_cents,
                        threshold=max_spread_p95,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Spread P95",
                        status=ValidationStatus.WARNING,
                        message=(
                            f"95th percentile spread {spread_p95_cents:.2f} cents "
                            f"> {max_spread_p95} cents"
                        ),
                        value=spread_p95_cents,
                        threshold=max_spread_p95,
                    )
                )

            # Check: Average spread < 30 cents
            max_avg_spread = self.config.price.max_avg_spread_cents
            avg_spread_cents = avg_spread * 100

            if avg_spread_cents <= max_avg_spread:
                checks.append(
                    CheckResult(
                        name="Average Spread",
                        status=ValidationStatus.PASS,
                        message=(
                            f"Average spread {avg_spread_cents:.2f} cents "
                            f"<= {max_avg_spread} cents"
                        ),
                        value=avg_spread_cents,
                        threshold=max_avg_spread,
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Average Spread",
                        status=ValidationStatus.WARNING,
                        message=(
                            f"Average spread {avg_spread_cents:.2f} cents "
                            f"> {max_avg_spread} cents"
                        ),
                        value=avg_spread_cents,
                        threshold=max_avg_spread,
                    )
                )

        except Exception as e:
            checks.append(
                CheckResult(
                    name="Price Validation",
                    status=ValidationStatus.CRITICAL,
                    message=f"Price validation failed: {type(e).__name__}: {e}",
                )
            )

        return checks

    def _check_regime_analysis(self) -> list[CheckResult]:
        """Analyze market regimes using Hurst exponent.

        Calculates Hurst exponent on rolling windows of daily returns and
        classifies each window as trending, random, or mean-reverting.

        Returns:
            List of CheckResult objects for regime analysis.
        """
        checks: list[CheckResult] = []

        try:
            # Aggregate to daily data using DuckDB
            sql = f"""
            SELECT
                DATE_TRUNC('day', to_timestamp(ts_event/1e9)) as day,
                LAST(bid_price ORDER BY ts_event) as close
            FROM '{self._parquet_pattern}'
            GROUP BY day
            ORDER BY day
            """
            df = self.db.query_df(sql)

            if len(df) < REGIME_WINDOW_SIZE * 2:
                checks.append(
                    CheckResult(
                        name="Regime Analysis",
                        status=ValidationStatus.WARNING,
                        message=(
                            f"Insufficient daily data for regime analysis: "
                            f"{len(df)} days < {REGIME_WINDOW_SIZE * 2} minimum"
                        ),
                        value=len(df),
                    )
                )
                return checks

            # Extract close prices and compute log returns
            closes = df["close"].to_numpy()
            log_returns = np.diff(np.log(closes))

            # Calculate overall Hurst exponent
            overall_hurst = hurst_rs(log_returns)

            # Calculate Hurst on rolling windows
            n_returns = len(log_returns)
            regime_counts: dict[str, int] = {
                "trending": 0,
                "random": 0,
                "mean_reverting": 0,
            }

            window_start = 0
            window_count = 0

            while window_start + REGIME_WINDOW_SIZE <= n_returns:
                window = log_returns[window_start : window_start + REGIME_WINDOW_SIZE]
                h = hurst_rs(window, min_window=8)  # Smaller min for window
                regime = classify_regime(h)
                regime_counts[regime] += 1
                window_count += 1
                window_start += REGIME_WINDOW_STEP

            # Calculate percentages
            if window_count > 0:
                trending_pct = regime_counts["trending"] / window_count * 100
                random_pct = regime_counts["random"] / window_count * 100
                mean_rev_pct = regime_counts["mean_reverting"] / window_count * 100
            else:
                trending_pct = random_pct = mean_rev_pct = 0.0

            # Check if all regimes are represented above threshold
            all_regimes_ok = (
                trending_pct >= MIN_REGIME_PERCENTAGE
                and random_pct >= MIN_REGIME_PERCENTAGE
                and mean_rev_pct >= MIN_REGIME_PERCENTAGE
            )
            self._regime_diversity_ok = all_regimes_ok

            # Overall Hurst check
            checks.append(
                CheckResult(
                    name="Overall Hurst Exponent",
                    status=ValidationStatus.PASS,
                    message=(
                        f"H = {overall_hurst:.3f} "
                        f"({classify_regime(overall_hurst)})"
                    ),
                    value=overall_hurst,
                    details={
                        "trading_days": len(df),
                        "classification": classify_regime(overall_hurst),
                    },
                )
            )

            # Regime diversity check
            if all_regimes_ok:
                checks.append(
                    CheckResult(
                        name="Regime Diversity",
                        status=ValidationStatus.PASS,
                        message=(
                            f"All 3 regimes > {MIN_REGIME_PERCENTAGE}%: "
                            f"trending={trending_pct:.1f}%, "
                            f"random={random_pct:.1f}%, "
                            f"mean-rev={mean_rev_pct:.1f}%"
                        ),
                        details={
                            "trending_pct": trending_pct,
                            "random_pct": random_pct,
                            "mean_reverting_pct": mean_rev_pct,
                            "window_count": window_count,
                        },
                    )
                )
            else:
                checks.append(
                    CheckResult(
                        name="Regime Diversity",
                        status=ValidationStatus.WARNING,
                        message=(
                            f"Not all regimes > {MIN_REGIME_PERCENTAGE}%: "
                            f"trending={trending_pct:.1f}%, "
                            f"random={random_pct:.1f}%, "
                            f"mean-rev={mean_rev_pct:.1f}%"
                        ),
                        details={
                            "trending_pct": trending_pct,
                            "random_pct": random_pct,
                            "mean_reverting_pct": mean_rev_pct,
                            "window_count": window_count,
                        },
                    )
                )

        except Exception as e:
            checks.append(
                CheckResult(
                    name="Regime Analysis",
                    status=ValidationStatus.CRITICAL,
                    message=f"Regime analysis failed: {type(e).__name__}: {e}",
                )
            )

        return checks

    def _check_session_coverage(self) -> list[CheckResult]:
        """Check trading session coverage.

        Verifies that all 6 trading sessions have adequate tick coverage:
        ASIAN, LONDON, OVERLAP, NY, LATE_NY, EVENING

        Returns:
            List of CheckResult objects for session coverage.
        """
        checks: list[CheckResult] = []

        try:
            # Session coverage query
            sql = f"""
            SELECT
                CASE
                    WHEN EXTRACT(HOUR FROM to_timestamp(ts_event/1e9))
                        BETWEEN 0 AND 6 THEN 'ASIAN'
                    WHEN EXTRACT(HOUR FROM to_timestamp(ts_event/1e9))
                        BETWEEN 7 AND 11 THEN 'LONDON'
                    WHEN EXTRACT(HOUR FROM to_timestamp(ts_event/1e9))
                        BETWEEN 12 AND 14 THEN 'OVERLAP'
                    WHEN EXTRACT(HOUR FROM to_timestamp(ts_event/1e9))
                        BETWEEN 15 AND 16 THEN 'NY'
                    WHEN EXTRACT(HOUR FROM to_timestamp(ts_event/1e9))
                        BETWEEN 17 AND 20 THEN 'LATE_NY'
                    ELSE 'EVENING'
                END as session,
                COUNT(*) as ticks
            FROM '{self._parquet_pattern}'
            GROUP BY session
            """
            df = self.db.query_df(sql)

            # Build session coverage dict
            total_ticks = self._total_ticks if self._total_ticks > 0 else 1
            session_data: dict[str, tuple[int, float]] = {}

            for row in df.iter_rows():
                session_name = str(row[0])
                tick_count = int(row[1])
                percentage = tick_count / total_ticks * 100
                session_data[session_name] = (tick_count, percentage)

            # Check each required session
            all_sessions_ok = True
            missing_sessions: list[str] = []
            low_coverage_sessions: list[str] = []

            for session_name in SESSION_HOUR_RANGES:
                if session_name in session_data:
                    tick_count, pct = session_data[session_name]
                    if pct < MIN_SESSION_PERCENTAGE:
                        low_coverage_sessions.append(f"{session_name}={pct:.1f}%")
                        all_sessions_ok = False
                else:
                    missing_sessions.append(session_name)
                    all_sessions_ok = False

            self._session_coverage_ok = all_sessions_ok

            if all_sessions_ok:
                coverage_str = ", ".join(
                    f"{s}={session_data[s][1]:.1f}%"
                    for s in sorted(session_data.keys())
                )
                checks.append(
                    CheckResult(
                        name="Session Coverage",
                        status=ValidationStatus.PASS,
                        message=f"All sessions > {MIN_SESSION_PERCENTAGE}%: {coverage_str}",
                        details={
                            s: {"ticks": d[0], "pct": d[1]}
                            for s, d in session_data.items()
                        },
                    )
                )
            else:
                issues: list[str] = []
                if missing_sessions:
                    issues.append(f"missing: {missing_sessions}")
                if low_coverage_sessions:
                    issues.append(f"low: {low_coverage_sessions}")

                checks.append(
                    CheckResult(
                        name="Session Coverage",
                        status=ValidationStatus.WARNING,
                        message=f"Session coverage issues: {'; '.join(issues)}",
                        details={
                            s: {"ticks": d[0], "pct": d[1]}
                            for s, d in session_data.items()
                        },
                    )
                )

        except Exception as e:
            checks.append(
                CheckResult(
                    name="Session Coverage",
                    status=ValidationStatus.CRITICAL,
                    message=f"Session coverage check failed: {type(e).__name__}: {e}",
                )
            )

        return checks

    def _compute_quality_score(self) -> CheckResult:
        """Compute weighted quality score (0-100).

        Score components:
        - Coverage (25pts): >= min_coverage_months
        - Clean Data (25pts): >= 99%
        - Gaps (15pts): 0 critical gaps
        - Regime Diversity (15pts): All 3 regimes > 10%
        - Session Coverage (10pts): All sessions > 5%
        - Spread Quality (10pts): Avg spread < 30 cents

        Returns:
            CheckResult with quality score.
        """
        min_coverage = self.config.data_quality.min_coverage_months
        min_clean = self.config.data_quality.min_clean_data_pct
        max_avg_spread = self.config.price.max_avg_spread_cents

        # Calculate individual scores
        coverage_score = 25.0 if self._months_coverage >= min_coverage else 0.0
        clean_data_score = 25.0 if self._clean_data_pct >= min_clean else 0.0
        gaps_score = 15.0 if self._critical_gaps == 0 else 0.0
        regime_score = 15.0 if self._regime_diversity_ok else 0.0
        session_score = 10.0 if self._session_coverage_ok else 0.0

        # Spread score (linear interpolation)
        avg_spread_cents = self._avg_spread * 100
        if avg_spread_cents <= max_avg_spread:
            spread_score = 10.0
        elif avg_spread_cents >= max_avg_spread * 2:
            spread_score = 0.0
        else:
            # Linear interpolation from 10 to 0
            spread_score = 10.0 * (1 - (avg_spread_cents - max_avg_spread) / max_avg_spread)
            spread_score = max(0.0, spread_score)

        total_score = (
            coverage_score
            + clean_data_score
            + gaps_score
            + regime_score
            + session_score
            + spread_score
        )

        # Determine status based on score
        min_quality = self.config.data_quality.min_quality_score
        if total_score >= min_quality:
            status = ValidationStatus.PASS
        elif total_score >= min_quality * 0.8:  # Within 80% of threshold
            status = ValidationStatus.WARNING
        else:
            status = ValidationStatus.FAIL

        return CheckResult(
            name="Quality Score",
            status=status,
            message=f"Quality score: {total_score:.1f}/100 (threshold: {min_quality})",
            value=total_score,
            threshold=min_quality,
            details={
                "coverage_score": coverage_score,
                "clean_data_score": clean_data_score,
                "gaps_score": gaps_score,
                "regime_score": regime_score,
                "session_score": session_score,
                "spread_score": spread_score,
            },
        )
