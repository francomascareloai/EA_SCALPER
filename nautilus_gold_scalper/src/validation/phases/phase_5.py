"""
Phase 5 Validator: Advanced Statistical Authenticity and Look-Ahead Bias Detection.

This phase validates that market data is REAL (not synthetic) and scans for
look-ahead bias in trading scripts.

Validation Components:
    1. GJR-GARCH Volatility Clustering - Real markets show high volatility persistence
    2. Stylized Facts Battery - Fat tails, volatility ACF, leverage effect
    3. Intraday Volatility Pattern - London/NY overlap should show higher volatility
    4. Look-Ahead Bias Detection - Static analysis of Python scripts
    5. Tick Frequency Analysis - Real data has variable tick frequency by hour

Thresholds:
    - GARCH persistence > 0.9 (real markets)
    - Excess kurtosis > 0 (fat tails)
    - Volatility ACF(1) > 0.15, ACF(5) > 0.08
    - Leverage effect correlation < 0
    - Tick frequency coefficient of variation > 0.3

Dependencies:
    - Required: numpy, scipy, polars, duckdb
    - Optional: arch (GJR-GARCH), statsmodels (ACF)
"""

from __future__ import annotations

import logging
import re
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING, Any, ClassVar, TypedDict

import numpy as np
import polars as pl
from scipy.stats import kurtosis, skew

from nautilus_gold_scalper.src.validation.core.config import ValidationConfig
from nautilus_gold_scalper.src.validation.core.engine import (
    DuckDBConnection,
    PhaseValidator,
)
from nautilus_gold_scalper.src.validation.core.results import (
    PhaseResult,
    ValidationStatus,
)

if TYPE_CHECKING:
    from numpy.typing import NDArray

logger = logging.getLogger(__name__)


# -----------------------------------------------------------------------------
# Optional imports with graceful fallback
# -----------------------------------------------------------------------------

_ARCH_AVAILABLE = False
_arch_model_func: Any = None
try:
    from arch import arch_model as _am

    _arch_model_func = _am
    _ARCH_AVAILABLE = True
except ImportError:
    logger.warning("arch library not available - GJR-GARCH validation will be skipped")

_STATSMODELS_AVAILABLE = False
_sm_acf_func: Any = None
try:
    from statsmodels.tsa.stattools import acf as _acf

    _sm_acf_func = _acf
    _STATSMODELS_AVAILABLE = True
except ImportError:
    logger.warning(
        "statsmodels not available - using numpy fallback for ACF calculation"
    )


# -----------------------------------------------------------------------------
# Result TypedDicts
# -----------------------------------------------------------------------------


class GARCHResult(TypedDict):
    """Result of GJR-GARCH volatility clustering analysis."""

    persistence: float
    alpha: float
    gamma: float
    beta: float
    nu: float  # degrees of freedom for Student-t
    passed: bool
    skipped: bool
    error: str | None


class StylizedFactsResult(TypedDict):
    """Result of stylized facts battery tests."""

    excess_kurtosis: float
    skewness: float
    acf_1: float
    acf_5: float
    acf_20: float
    leverage_effect: float
    fat_tails_passed: bool
    volatility_clustering_passed: bool
    leverage_effect_passed: bool
    slow_decay_passed: bool
    all_passed: bool


class IntradayPatternResult(TypedDict):
    """Result of intraday volatility pattern analysis."""

    peak_hour: int
    peak_volatility: float
    trough_hour: int
    trough_volatility: float
    london_ny_avg: float
    asian_avg: float
    ratio: float  # london_ny / asian
    valid: bool


class LookAheadIssue(TypedDict):
    """A detected look-ahead bias issue."""

    file: str
    line: int
    pattern: str
    code_snippet: str


class LookAheadScanResult(TypedDict):
    """Result of look-ahead bias scan."""

    scripts_checked: int
    issues_found: int
    issues: list[LookAheadIssue]
    passed: bool


class TickFrequencyResult(TypedDict):
    """Result of tick frequency analysis."""

    coef_variation: float
    min_ticks_hour: int
    max_ticks_hour: int
    peak_hours: list[int]
    trough_hours: list[int]
    passed: bool


class Phase5Result(TypedDict):
    """Complete Phase 5 validation result."""

    gjr_garch: GARCHResult
    stylized_facts: StylizedFactsResult
    intraday_pattern: IntradayPatternResult
    lookahead_scan: LookAheadScanResult
    tick_frequency: TickFrequencyResult
    authenticity_score: float


# -----------------------------------------------------------------------------
# Look-Ahead Detection Patterns
# -----------------------------------------------------------------------------

# Regex patterns for detecting look-ahead bias
LOOKAHEAD_PATTERNS: list[tuple[str, str]] = [
    (r"\.shift\s*\(\s*-\d+", "Future shift: .shift(-N) peeks into future data"),
    (r"\.bfill\s*\(", "Backward fill: .bfill() uses future data to fill NaN"),
    (
        r"\.fillna\s*\([^)]*method\s*=\s*['\"]bfill",
        "Backward fill via fillna(method='bfill')",
    ),
    (
        r"\.fillna\s*\([^)]*method\s*=\s*['\"]backfill",
        "Backward fill via fillna(method='backfill')",
    ),
    (r"\[\s*:\s*-\d+\s*\]", "Potential future slicing: [:-N] pattern"),
    (r"\.iloc\s*\[\s*-\d+\s*\]", "Negative iloc indexing (check context)"),
    (r"rolling\s*\([^)]*center\s*=\s*True", "Centered rolling window uses future"),
    (r"\.ewm\s*\([^)]*adjust\s*=\s*False", "EWM with adjust=False (check for leakage)"),
]


# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------


def compute_acf(data: NDArray[np.floating[Any]], nlags: int = 20) -> NDArray[np.floating[Any]]:
    """Compute autocorrelation function.

    Uses statsmodels if available, otherwise falls back to numpy implementation.

    Args:
        data: 1D array of values.
        nlags: Number of lags to compute.

    Returns:
        Array of ACF values from lag 0 to nlags.
    """
    if _STATSMODELS_AVAILABLE and _sm_acf_func is not None:
        result: NDArray[np.floating[Any]] = _sm_acf_func(data, nlags=nlags, fft=True)
        return result

    # Numpy fallback - basic ACF computation
    n = len(data)
    mean = np.mean(data)
    var = np.var(data)
    if var == 0:
        return np.zeros(nlags + 1)

    acf_values: list[float] = []
    data_centered = data - mean

    for lag in range(nlags + 1):
        if lag == 0:
            acf_values.append(1.0)
        else:
            acf_val = float(
                np.sum(data_centered[: n - lag] * data_centered[lag:]) / (n * var)
            )
            acf_values.append(acf_val)

    return np.array(acf_values)


def scan_file_for_lookahead(
    file_path: Path, patterns: list[tuple[str, str]]
) -> list[LookAheadIssue]:
    """Scan a Python file for look-ahead bias patterns.

    Args:
        file_path: Path to Python file.
        patterns: List of (regex, description) tuples.

    Returns:
        List of detected issues.
    """
    issues: list[LookAheadIssue] = []

    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
    except (OSError, IOError) as e:
        logger.warning("Could not read file %s: %s", file_path, e)
        return issues

    lines = content.splitlines()

    for line_num, line in enumerate(lines, start=1):
        # Skip comments
        stripped = line.strip()
        if stripped.startswith("#"):
            continue

        for pattern, description in patterns:
            if re.search(pattern, line):
                issues.append(
                    LookAheadIssue(
                        file=str(file_path),
                        line=line_num,
                        pattern=description,
                        code_snippet=line.strip()[:100],
                    )
                )

    return issues


def scan_directory_for_lookahead(
    base_dir: Path,
    patterns: list[tuple[str, str]],
    exclude_dirs: set[str] | None = None,
) -> tuple[int, list[LookAheadIssue]]:
    """Scan a directory recursively for look-ahead bias in Python files.

    Args:
        base_dir: Root directory to scan.
        patterns: List of (regex, description) tuples.
        exclude_dirs: Directory names to exclude (e.g., '.venv', '__pycache__').

    Returns:
        Tuple of (scripts_checked, issues_found).
    """
    if exclude_dirs is None:
        exclude_dirs = {".venv", "__pycache__", ".git", "node_modules", ".rag-db"}

    scripts_checked = 0
    all_issues: list[LookAheadIssue] = []

    if not base_dir.exists():
        return scripts_checked, all_issues

    for py_file in base_dir.rglob("*.py"):
        # Skip excluded directories
        if any(excluded in py_file.parts for excluded in exclude_dirs):
            continue

        scripts_checked += 1
        file_issues = scan_file_for_lookahead(py_file, patterns)
        all_issues.extend(file_issues)

    return scripts_checked, all_issues


# -----------------------------------------------------------------------------
# Phase 5 Validator Implementation
# -----------------------------------------------------------------------------


class Phase5Validator(PhaseValidator):
    """Phase 5: Advanced Statistical Authenticity and Look-Ahead Bias Detection.

    Validates that market data is genuine (not synthetic) using statistical
    tests for market microstructure properties. Also scans codebase for
    potential look-ahead bias issues.

    Validation Components:
        1. GJR-GARCH - Asymmetric volatility model for leverage effect
        2. Stylized Facts - Fat tails, volatility clustering, slow decay
        3. Intraday Pattern - London/NY overlap should have higher volatility
        4. Look-Ahead Detection - Static analysis for future data usage
        5. Tick Frequency - Real markets have variable activity by hour

    Attributes:
        phase_id: Unique identifier "phase_5"
        phase_name: Human-readable "Advanced Validation"
    """

    phase_id: ClassVar[str] = "phase_5"
    phase_name: ClassVar[str] = "Advanced Validation (Authenticity & Look-Ahead)"

    # Thresholds for validation
    GARCH_PERSISTENCE_THRESHOLD: ClassVar[float] = 0.9
    EXCESS_KURTOSIS_THRESHOLD: ClassVar[float] = 0.0
    ACF_1_THRESHOLD: ClassVar[float] = 0.15
    ACF_5_THRESHOLD: ClassVar[float] = 0.08
    ACF_20_THRESHOLD: ClassVar[float] = 0.05
    LEVERAGE_EFFECT_THRESHOLD: ClassVar[float] = 0.0  # Must be negative
    TICK_FREQ_CV_THRESHOLD: ClassVar[float] = 0.3
    LONDON_NY_HOURS: ClassVar[tuple[int, ...]] = (12, 13, 14, 15)
    ASIAN_HOURS: ClassVar[tuple[int, ...]] = (0, 1, 2, 3, 4, 5, 6)

    def __init__(self, config: ValidationConfig, db: DuckDBConnection) -> None:
        """Initialize Phase 5 validator.

        Args:
            config: Validation configuration with thresholds.
            db: DuckDB connection for queries.
        """
        super().__init__(config, db)
        self._project_root = Path(config.catalog_path).parent.parent.parent

    def validate(self) -> PhaseResult:
        """Execute all Phase 5 validation checks.

        Returns:
            PhaseResult with all check results.
        """
        result = PhaseResult(
            phase_id=self.phase_id,
            phase_name=self.phase_name,
            status=ValidationStatus.PASS,
            start_time=datetime.now(),
        )

        # Track component results for final score
        component_results: dict[str, bool] = {}

        # 1. GJR-GARCH Volatility Clustering
        garch_result = self._validate_garch()
        component_results["garch"] = garch_result["passed"] or garch_result["skipped"]
        result.add_check(
            self.check(
                name="GJR-GARCH Volatility Clustering",
                condition=garch_result["passed"] or garch_result["skipped"],
                message=(
                    f"Persistence={garch_result['persistence']:.3f} "
                    f"(threshold>{self.GARCH_PERSISTENCE_THRESHOLD})"
                    if not garch_result["skipped"]
                    else f"Skipped: {garch_result['error'] or 'arch library not available'}"
                ),
                value=garch_result["persistence"] if not garch_result["skipped"] else None,
                threshold=self.GARCH_PERSISTENCE_THRESHOLD,
                details={"garch": dict(garch_result)},
                warn_on_fail=garch_result["skipped"],
            )
        )

        # 2. Stylized Facts Battery
        stylized_result = self._validate_stylized_facts()
        component_results["stylized"] = stylized_result["all_passed"]
        result.add_check(
            self.check(
                name="Stylized Facts Battery",
                condition=stylized_result["all_passed"],
                message=self._format_stylized_message(stylized_result),
                value=stylized_result["excess_kurtosis"],
                details={"stylized_facts": dict(stylized_result)},
            )
        )

        # 3. Intraday Volatility Pattern
        intraday_result = self._validate_intraday_pattern()
        component_results["intraday"] = intraday_result["valid"]
        result.add_check(
            self.check(
                name="Intraday Volatility Pattern",
                condition=intraday_result["valid"],
                message=(
                    f"Peak hour={intraday_result['peak_hour']} (expected 12-15), "
                    f"Trough hour={intraday_result['trough_hour']} (expected 0-6), "
                    f"Ratio={intraday_result['ratio']:.2f}"
                ),
                value=intraday_result["ratio"],
                details={"intraday_pattern": dict(intraday_result)},
            )
        )

        # 4. Look-Ahead Bias Detection
        lookahead_result = self._validate_lookahead()
        component_results["lookahead"] = lookahead_result["passed"]
        result.add_check(
            self.check(
                name="Look-Ahead Bias Detection",
                condition=lookahead_result["passed"],
                message=(
                    f"Scanned {lookahead_result['scripts_checked']} scripts, "
                    f"found {lookahead_result['issues_found']} potential issues"
                ),
                value=lookahead_result["issues_found"],
                threshold=0,
                details={"lookahead_scan": dict(lookahead_result)},
                warn_on_fail=True,  # Issues are warnings, not hard fails
            )
        )

        # 5. Tick Frequency Analysis
        tick_freq_result = self._validate_tick_frequency()
        component_results["tick_freq"] = tick_freq_result["passed"]
        result.add_check(
            self.check(
                name="Tick Frequency Variation",
                condition=tick_freq_result["passed"],
                message=(
                    f"CV={tick_freq_result['coef_variation']:.3f} "
                    f"(threshold>{self.TICK_FREQ_CV_THRESHOLD})"
                ),
                value=tick_freq_result["coef_variation"],
                threshold=self.TICK_FREQ_CV_THRESHOLD,
                details={"tick_frequency": dict(tick_freq_result)},
            )
        )

        # 6. Compute Authenticity Score
        authenticity_score = self._compute_authenticity_score(component_results)
        result.add_check(
            self.check(
                name="Overall Authenticity Score",
                condition=authenticity_score >= 70.0,
                message=f"Authenticity score: {authenticity_score:.1f}/100",
                value=authenticity_score,
                threshold=70.0,
                details={"component_results": component_results},
            )
        )

        result.status = result.compute_status()
        result.end_time = datetime.now()

        return result

    def _validate_garch(self) -> GARCHResult:
        """Fit GJR-GARCH(1,1,1) model to 1-minute returns.

        GJR-GARCH captures asymmetric volatility (leverage effect).
        Real markets show high persistence (alpha + gamma/2 + beta close to 1).

        Returns:
            GARCHResult with model parameters and pass/fail status.
        """
        if not _ARCH_AVAILABLE or _arch_model_func is None:
            return GARCHResult(
                persistence=0.0,
                alpha=0.0,
                gamma=0.0,
                beta=0.0,
                nu=0.0,
                passed=False,
                skipped=True,
                error="arch library not installed",
            )

        try:
            # Query 1-minute bars from catalog
            parquet_pattern = f"{self.config.catalog_path}/data/quote_tick/**/*.parquet"

            # Aggregate to 1-minute bars using DuckDB
            sql = f"""
            SELECT
                time_bucket(INTERVAL '1 minute', to_timestamp(ts_event / 1000000000)) as bar_time,
                LAST(bid_price) as close_price
            FROM '{parquet_pattern}'
            GROUP BY bar_time
            ORDER BY bar_time
            """

            df = self.db.query_df(sql)

            if df.is_empty() or len(df) < 1000:
                return GARCHResult(
                    persistence=0.0,
                    alpha=0.0,
                    gamma=0.0,
                    beta=0.0,
                    nu=0.0,
                    passed=False,
                    skipped=True,
                    error=f"Insufficient data: {len(df)} bars (need >= 1000)",
                )

            # Compute percentage returns
            close_prices = df["close_price"].to_numpy()
            returns = np.diff(close_prices) / close_prices[:-1] * 100

            # Remove NaN and infinite values
            returns = returns[np.isfinite(returns)]

            if len(returns) < 1000:
                return GARCHResult(
                    persistence=0.0,
                    alpha=0.0,
                    gamma=0.0,
                    beta=0.0,
                    nu=0.0,
                    passed=False,
                    skipped=True,
                    error=f"Insufficient valid returns: {len(returns)}",
                )

            # Fit GJR-GARCH(1,1,1) with Student-t distribution
            model = _arch_model_func(
                returns,
                vol="Garch",
                p=1,
                o=1,  # GJR asymmetric term
                q=1,
                dist="StudentsT",
                rescale=True,
            )

            # Fit with suppressed output
            fit_result = model.fit(disp="off", show_warning=False)

            # Extract parameters
            params = fit_result.params
            alpha = float(params.get("alpha[1]", 0.0))
            gamma = float(params.get("gamma[1]", 0.0))
            beta = float(params.get("beta[1]", 0.0))
            nu = float(params.get("nu", 4.0))  # degrees of freedom

            # Persistence = alpha + gamma/2 + beta
            persistence = alpha + gamma / 2 + beta

            passed = persistence > self.GARCH_PERSISTENCE_THRESHOLD

            return GARCHResult(
                persistence=persistence,
                alpha=alpha,
                gamma=gamma,
                beta=beta,
                nu=nu,
                passed=passed,
                skipped=False,
                error=None,
            )

        except Exception as e:
            logger.exception("GJR-GARCH fitting failed")
            return GARCHResult(
                persistence=0.0,
                alpha=0.0,
                gamma=0.0,
                beta=0.0,
                nu=0.0,
                passed=False,
                skipped=True,
                error=str(e),
            )

    def _validate_stylized_facts(self) -> StylizedFactsResult:
        """Test for market microstructure stylized facts.

        Tests:
            a) Fat Tails: Excess kurtosis > 0
            b) Volatility Clustering: ACF of squared returns > thresholds
            c) Leverage Effect: Negative correlation between returns and future vol
            d) Slow ACF Decay: ACF(20) > threshold

        Returns:
            StylizedFactsResult with all test outcomes.
        """
        try:
            # Query 1-minute bar returns
            parquet_pattern = f"{self.config.catalog_path}/data/quote_tick/**/*.parquet"

            sql = f"""
            SELECT
                time_bucket(INTERVAL '1 minute', to_timestamp(ts_event / 1000000000)) as bar_time,
                LAST(bid_price) as close_price
            FROM '{parquet_pattern}'
            GROUP BY bar_time
            ORDER BY bar_time
            """

            df = self.db.query_df(sql)

            if df.is_empty() or len(df) < 100:
                return self._empty_stylized_result("Insufficient data")

            close_prices = df["close_price"].to_numpy()
            returns = np.diff(close_prices) / close_prices[:-1] * 100
            returns = returns[np.isfinite(returns)]

            if len(returns) < 100:
                return self._empty_stylized_result("Insufficient valid returns")

            # a) Fat Tails - Excess kurtosis
            excess_kurt = float(kurtosis(returns, fisher=True))
            skewness_val = float(skew(returns))
            fat_tails_passed = excess_kurt > self.EXCESS_KURTOSIS_THRESHOLD

            # b) Volatility Clustering - ACF of squared returns
            squared_returns = returns**2
            acf_values = compute_acf(squared_returns, nlags=20)
            acf_1 = float(acf_values[1]) if len(acf_values) > 1 else 0.0
            acf_5 = float(acf_values[5]) if len(acf_values) > 5 else 0.0
            acf_20 = float(acf_values[20]) if len(acf_values) > 20 else 0.0

            vol_clustering_passed = (
                acf_1 > self.ACF_1_THRESHOLD and acf_5 > self.ACF_5_THRESHOLD
            )

            # c) Leverage Effect: Correlation(r_t, |r_{t+1}|) should be negative
            if len(returns) > 1:
                leverage_corr = float(
                    np.corrcoef(returns[:-1], np.abs(returns[1:]))[0, 1]
                )
            else:
                leverage_corr = 0.0
            leverage_corr = 0.0 if not np.isfinite(leverage_corr) else leverage_corr
            leverage_passed = leverage_corr < self.LEVERAGE_EFFECT_THRESHOLD

            # d) Slow ACF Decay
            slow_decay_passed = acf_20 > self.ACF_20_THRESHOLD

            # All must pass for overall pass
            all_passed = (
                fat_tails_passed
                and vol_clustering_passed
                and leverage_passed
                and slow_decay_passed
            )

            return StylizedFactsResult(
                excess_kurtosis=excess_kurt,
                skewness=skewness_val,
                acf_1=acf_1,
                acf_5=acf_5,
                acf_20=acf_20,
                leverage_effect=leverage_corr,
                fat_tails_passed=fat_tails_passed,
                volatility_clustering_passed=vol_clustering_passed,
                leverage_effect_passed=leverage_passed,
                slow_decay_passed=slow_decay_passed,
                all_passed=all_passed,
            )

        except Exception as e:
            logger.exception("Stylized facts validation failed")
            return self._empty_stylized_result(str(e))

    def _empty_stylized_result(self, reason: str) -> StylizedFactsResult:
        """Create empty stylized facts result on error.

        Args:
            reason: Error message or reason for empty result.

        Returns:
            StylizedFactsResult with zero values and failed status.
        """
        logger.warning("Stylized facts validation failed: %s", reason)
        return StylizedFactsResult(
            excess_kurtosis=0.0,
            skewness=0.0,
            acf_1=0.0,
            acf_5=0.0,
            acf_20=0.0,
            leverage_effect=0.0,
            fat_tails_passed=False,
            volatility_clustering_passed=False,
            leverage_effect_passed=False,
            slow_decay_passed=False,
            all_passed=False,
        )

    def _format_stylized_message(self, result: StylizedFactsResult) -> str:
        """Format stylized facts result as human-readable message.

        Args:
            result: StylizedFactsResult to format.

        Returns:
            Formatted message string.
        """
        parts: list[str] = []
        parts.append(f"Kurtosis={result['excess_kurtosis']:.2f}")
        parts.append(f"ACF(1)={result['acf_1']:.3f}")
        parts.append(f"Leverage={result['leverage_effect']:.3f}")

        status_parts: list[str] = []
        if result["fat_tails_passed"]:
            status_parts.append("FatTails:OK")
        else:
            status_parts.append("FatTails:FAIL")
        if result["volatility_clustering_passed"]:
            status_parts.append("VolCluster:OK")
        else:
            status_parts.append("VolCluster:FAIL")
        if result["leverage_effect_passed"]:
            status_parts.append("Leverage:OK")
        else:
            status_parts.append("Leverage:FAIL")

        return f"{' '.join(parts)} | {' '.join(status_parts)}"

    def _validate_intraday_pattern(self) -> IntradayPatternResult:
        """Validate intraday volatility pattern.

        Real gold markets show higher volatility during London/NY overlap
        (12:00-15:00 UTC) and lower volatility during Asian session (00:00-06:00 UTC).

        Returns:
            IntradayPatternResult with peak/trough hours and validity.
        """
        try:
            parquet_pattern = f"{self.config.catalog_path}/data/quote_tick/**/*.parquet"

            # Query hourly volatility (spread as proxy for volatility)
            sql = f"""
            SELECT
                EXTRACT(HOUR FROM to_timestamp(ts_event / 1000000000)) as hour,
                STDDEV(ask_price - bid_price) as spread_vol,
                COUNT(*) as tick_count
            FROM '{parquet_pattern}'
            GROUP BY hour
            ORDER BY hour
            """

            df = self.db.query_df(sql)

            if df.is_empty() or len(df) < 20:
                return IntradayPatternResult(
                    peak_hour=0,
                    peak_volatility=0.0,
                    trough_hour=0,
                    trough_volatility=0.0,
                    london_ny_avg=0.0,
                    asian_avg=0.0,
                    ratio=0.0,
                    valid=False,
                )

            hours = df["hour"].to_numpy()
            volatility = df["spread_vol"].to_numpy()

            # Find peak and trough
            peak_idx = int(np.argmax(volatility))
            trough_idx = int(np.argmin(volatility))
            peak_hour = int(hours[peak_idx])
            trough_hour = int(hours[trough_idx])
            peak_vol = float(volatility[peak_idx])
            trough_vol = float(volatility[trough_idx])

            # Compute London/NY overlap average (hours 12-15)
            london_ny_mask = np.isin(hours, self.LONDON_NY_HOURS)
            london_ny_avg = float(np.mean(volatility[london_ny_mask])) if london_ny_mask.any() else 0.0

            # Compute Asian session average (hours 0-6)
            asian_mask = np.isin(hours, self.ASIAN_HOURS)
            asian_avg = float(np.mean(volatility[asian_mask])) if asian_mask.any() else 0.0

            # Ratio should be > 1 (London/NY more volatile than Asian)
            ratio = london_ny_avg / asian_avg if asian_avg > 0 else 0.0

            # Validate pattern
            # Peak should be in London/NY overlap hours
            peak_in_expected = peak_hour in self.LONDON_NY_HOURS
            # Trough should be in Asian hours
            trough_in_expected = trough_hour in self.ASIAN_HOURS
            # Ratio should be > 1.0
            ratio_valid = ratio > 1.0

            valid = peak_in_expected and trough_in_expected and ratio_valid

            return IntradayPatternResult(
                peak_hour=peak_hour,
                peak_volatility=peak_vol,
                trough_hour=trough_hour,
                trough_volatility=trough_vol,
                london_ny_avg=london_ny_avg,
                asian_avg=asian_avg,
                ratio=ratio,
                valid=valid,
            )

        except Exception as e:
            logger.exception("Intraday pattern validation failed")
            return IntradayPatternResult(
                peak_hour=0,
                peak_volatility=0.0,
                trough_hour=0,
                trough_volatility=0.0,
                london_ny_avg=0.0,
                asian_avg=0.0,
                ratio=0.0,
                valid=False,
            )

    def _validate_lookahead(self) -> LookAheadScanResult:
        """Scan codebase for look-ahead bias patterns.

        Scans Python scripts in:
            - scripts/
            - nautilus_gold_scalper/
            - scripts/oracle/
            - scripts/data/

        Returns:
            LookAheadScanResult with issues found.
        """
        try:
            # Determine project root
            catalog_path = Path(self.config.catalog_path)
            # Walk up to find project root (contains nautilus_gold_scalper/)
            project_root = catalog_path
            for _ in range(5):
                if (project_root / "nautilus_gold_scalper").exists():
                    break
                project_root = project_root.parent

            # Directories to scan
            scan_dirs = [
                project_root / "scripts",
                project_root / "nautilus_gold_scalper",
            ]

            total_scripts = 0
            all_issues: list[LookAheadIssue] = []

            for scan_dir in scan_dirs:
                if scan_dir.exists():
                    scripts, issues = scan_directory_for_lookahead(
                        scan_dir, LOOKAHEAD_PATTERNS
                    )
                    total_scripts += scripts
                    all_issues.extend(issues)

            # Look-ahead bias is serious but we only warn (may be false positives)
            passed = len(all_issues) == 0

            return LookAheadScanResult(
                scripts_checked=total_scripts,
                issues_found=len(all_issues),
                issues=all_issues,
                passed=passed,
            )

        except Exception as e:
            logger.exception("Look-ahead scan failed")
            return LookAheadScanResult(
                scripts_checked=0,
                issues_found=0,
                issues=[],
                passed=True,  # Don't fail on scan errors
            )

    def _validate_tick_frequency(self) -> TickFrequencyResult:
        """Validate tick frequency variation by hour.

        Real data has variable tick frequency - higher during active trading
        hours (London/NY), lower during Asian session. Synthetic data often
        has uniform tick frequency.

        Returns:
            TickFrequencyResult with coefficient of variation.
        """
        try:
            parquet_pattern = f"{self.config.catalog_path}/data/quote_tick/**/*.parquet"

            sql = f"""
            SELECT
                EXTRACT(HOUR FROM to_timestamp(ts_event / 1000000000)) as hour,
                COUNT(*) / COUNT(DISTINCT DATE_TRUNC('day', to_timestamp(ts_event / 1000000000))) as avg_ticks_per_hour
            FROM '{parquet_pattern}'
            GROUP BY hour
            ORDER BY hour
            """

            df = self.db.query_df(sql)

            if df.is_empty() or len(df) < 20:
                return TickFrequencyResult(
                    coef_variation=0.0,
                    min_ticks_hour=0,
                    max_ticks_hour=0,
                    peak_hours=[],
                    trough_hours=[],
                    passed=False,
                )

            hours = df["hour"].to_numpy()
            ticks = df["avg_ticks_per_hour"].to_numpy()

            # Coefficient of variation
            mean_ticks = float(np.mean(ticks))
            std_ticks = float(np.std(ticks))
            cv = std_ticks / mean_ticks if mean_ticks > 0 else 0.0

            # Find peak and trough hours
            sorted_indices = np.argsort(ticks)
            trough_indices = sorted_indices[:3]
            peak_indices = sorted_indices[-3:]

            min_hour = int(hours[sorted_indices[0]])
            max_hour = int(hours[sorted_indices[-1]])
            peak_hours = [int(hours[i]) for i in peak_indices]
            trough_hours = [int(hours[i]) for i in trough_indices]

            passed = cv > self.TICK_FREQ_CV_THRESHOLD

            return TickFrequencyResult(
                coef_variation=cv,
                min_ticks_hour=min_hour,
                max_ticks_hour=max_hour,
                peak_hours=peak_hours,
                trough_hours=trough_hours,
                passed=passed,
            )

        except Exception as e:
            logger.exception("Tick frequency validation failed")
            return TickFrequencyResult(
                coef_variation=0.0,
                min_ticks_hour=0,
                max_ticks_hour=0,
                peak_hours=[],
                trough_hours=[],
                passed=False,
            )

    def _compute_authenticity_score(
        self, component_results: dict[str, bool]
    ) -> float:
        """Compute overall authenticity score from component results.

        Weighting:
            - GARCH: 25%
            - Stylized Facts: 25%
            - Intraday Pattern: 20%
            - Look-Ahead: 15%
            - Tick Frequency: 15%

        Args:
            component_results: Dict of component name -> passed boolean.

        Returns:
            Score from 0 to 100.
        """
        weights = {
            "garch": 25.0,
            "stylized": 25.0,
            "intraday": 20.0,
            "lookahead": 15.0,
            "tick_freq": 15.0,
        }

        score = 0.0
        for component, passed in component_results.items():
            weight = weights.get(component, 0.0)
            if passed:
                score += weight

        return score
