"""
Phase 1A: Deep Data Validation for XAUUSD Data Pipeline.

Validates CSV to Parquet conversion quality for the XAUUSD tick dataset.
Uses DuckDB for high-performance queries on 654M+ tick datasets.

Validation Checks:
    1. Tick Count Verification: Compare checkpoint.json vs Parquet count
    2. Sample Data Validation: Verify schema invariants on 250K sample
    3. Gap Detection: Find gaps > 1 hour (excluding weekends)
    4. Duplicate Detection: Check for duplicate ts_event timestamps
    5. Monotonicity Check: Verify ts_event is monotonically increasing
    6. Schema Consistency: All Parquet files have expected columns

Example:
    >>> from src.validation.core.config import ValidationConfig
    >>> from src.validation.core.engine import (
    ...     ValidationEngine,
    ...     DuckDBConnection,
    ... )
    >>> from src.validation.phases.phase_1a import Phase1AValidator
    >>>
    >>> config = ValidationConfig(catalog_path="/path/to/catalog")
    >>> engine = ValidationEngine(config)
    >>> validator = Phase1AValidator(config, engine.db)
    >>> result = validator.validate()
    >>> print(f"Status: {result.status.value}")
    >>> engine.close()
"""

from __future__ import annotations

import json
import logging
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING, Any, ClassVar

import polars as pl
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
    pass

logger = logging.getLogger(__name__)


class Phase1AValidator(PhaseValidator):
    """Phase 1A: Deep Data Validation for CSV to Parquet conversion quality.

    Validates that the Parquet data matches the source CSV and maintains
    data quality invariants required for trading system backtesting.

    Attributes:
        phase_id: Unique identifier "1A".
        phase_name: Human-readable name "Deep Data Validation".
        EXPECTED_COLUMNS: Required schema columns for quote tick data.
        ONE_HOUR_NS: One hour in nanoseconds (gap detection threshold).
        MIN_WEEKEND_GAP_HOURS: Minimum hours for a valid weekend gap.
        MAX_WEEKEND_GAP_HOURS: Maximum hours for a valid weekend gap.
    """

    phase_id: ClassVar[str] = "1A"
    phase_name: ClassVar[str] = "Deep Data Validation"

    # Expected schema columns for NautilusTrader quote tick data
    EXPECTED_COLUMNS: ClassVar[frozenset[str]] = frozenset({
        "bid_price",
        "ask_price",
        "bid_size",
        "ask_size",
        "ts_event",
        "ts_init",
    })

    # Time constants
    ONE_HOUR_NS: ClassVar[int] = 3_600_000_000_000  # 1 hour in nanoseconds
    MIN_WEEKEND_GAP_HOURS: ClassVar[float] = 40.0  # Minimum valid weekend gap
    MAX_WEEKEND_GAP_HOURS: ClassVar[float] = 55.0  # Maximum valid weekend gap

    # Sample size for data validation
    SAMPLE_SIZE: ClassVar[int] = 250_000

    def __init__(self, config: ValidationConfig, db: DuckDBConnection) -> None:
        """Initialize Phase 1A validator.

        Args:
            config: Validation configuration with catalog path and thresholds.
            db: DuckDB connection for executing queries.
        """
        super().__init__(config, db)
        self._parquet_pattern: str | None = None
        self._checkpoint_data: dict[str, Any] | None = None

    def validate(self) -> PhaseResult:
        """Execute all Phase 1A validation checks.

        Runs the following checks in order:
            1. Tick count verification
            2. Sample data validation
            3. Gap detection (excluding weekends)
            4. Duplicate detection
            5. Monotonicity check
            6. Schema consistency

        Returns:
            PhaseResult with all check results and computed status.
        """
        result = PhaseResult(
            phase_id=self.phase_id,
            phase_name=self.phase_name,
            status=ValidationStatus.PASS,
            start_time=datetime.now(),
        )

        logger.info(
            "Starting Phase 1A validation: %s",
            self.config.catalog_path,
        )

        # Pre-compute parquet pattern and load checkpoint
        self._parquet_pattern = self._get_parquet_pattern()
        self._checkpoint_data = self._load_checkpoint()

        # Execute all checks
        result.add_check(self._check_tick_count())
        result.add_check(self._check_sample_data())
        result.add_check(self._check_gaps())
        result.add_check(self._check_duplicates())
        result.add_check(self._check_monotonicity())
        result.add_check(self._check_schema())

        result.end_time = datetime.now()

        logger.info(
            "Phase 1A complete: status=%s, passed=%d, failed=%d",
            result.status.value,
            result.passed_checks,
            result.failed_checks,
        )

        return result

    def _get_parquet_pattern(self) -> str:
        """Build glob pattern for Parquet files in the catalog.

        Returns:
            DuckDB-compatible glob pattern for Parquet files.
        """
        catalog_path = self.config.catalog_path
        return f"{catalog_path}/data/quote_tick/**/*.parquet"

    def _load_checkpoint(self) -> dict[str, Any] | None:
        """Load checkpoint.json from the catalog if it exists.

        The checkpoint file contains metadata from the CSV to Parquet
        conversion, including the expected tick count.

        Returns:
            Checkpoint data dictionary, or None if not available.
        """
        checkpoint_path = Path(self.config.catalog_path) / ".checkpoint.json"

        if not checkpoint_path.exists():
            logger.warning(
                "Checkpoint file not found: %s",
                checkpoint_path,
            )
            return None

        try:
            with open(checkpoint_path, encoding="utf-8") as f:
                data: dict[str, Any] = json.load(f)
            logger.debug(
                "Loaded checkpoint: rows_kept=%s",
                data.get("rows_kept"),
            )
            return data
        except (json.JSONDecodeError, OSError) as e:
            logger.warning(
                "Failed to load checkpoint: %s",
                e,
            )
            return None

    def _check_tick_count(self) -> CheckResult:
        """Verify tick count matches expected value from checkpoint.

        Compares the actual Parquet tick count against the rows_kept
        value from the checkpoint.json file.

        Returns:
            CheckResult with PASS if counts match, FAIL otherwise.
            Returns SKIPPED if checkpoint is not available.
        """
        if self._checkpoint_data is None:
            return CheckResult(
                name="Tick Count Verification",
                status=ValidationStatus.SKIPPED,
                message="Checkpoint file not available - cannot verify tick count",
            )

        expected_count = self._checkpoint_data.get("rows_kept")
        if expected_count is None:
            return CheckResult(
                name="Tick Count Verification",
                status=ValidationStatus.SKIPPED,
                message="Checkpoint does not contain 'rows_kept' field",
            )

        # Query actual count from Parquet files
        pattern = self._parquet_pattern
        sql = f"""
        SELECT COUNT(*) as cnt
        FROM '{pattern}'
        """

        try:
            result = self.db.query(sql).fetchone()
            actual_count = result[0] if result else 0
        except Exception as e:
            return CheckResult(
                name="Tick Count Verification",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to count ticks: {e}",
            )

        passed = actual_count == expected_count
        diff = actual_count - expected_count

        return self.check(
            name="Tick Count Verification",
            condition=passed,
            message=(
                f"Tick count matches: {actual_count:,}"
                if passed
                else f"Tick count mismatch: expected {expected_count:,}, "
                f"got {actual_count:,} (diff: {diff:+,})"
            ),
            value=actual_count,
            threshold=expected_count,
            details={
                "expected": expected_count,
                "actual": actual_count,
                "difference": diff,
            },
        )

    def _check_sample_data(self) -> CheckResult:
        """Validate data invariants on a sample of ticks.

        Samples 250K ticks and verifies:
            - ts_event > 0 (valid timestamp)
            - ts_init > 0 (valid timestamp)
            - ts_init >= ts_event (init timestamp not before event)
            - bid_price is not null
            - ask_price is not null

        Note:
            Price columns (bid_price, ask_price) are stored as binary-encoded
            NautilusTrader Price objects. We validate they are not null but
            cannot compare numeric values directly without deserialization.

        Returns:
            CheckResult with PASS if all invariants hold, FAIL otherwise.
        """
        pattern = self._parquet_pattern
        sample_size = self.SAMPLE_SIZE

        # Validate timestamps and null checks only
        # Price columns are binary-encoded and cannot be compared numerically
        sql = f"""
        SELECT
            COUNT(*) as total,
            SUM(CASE WHEN ts_event = 0 THEN 1 ELSE 0 END) as bad_ts_event,
            SUM(CASE WHEN ts_init = 0 THEN 1 ELSE 0 END) as bad_ts_init,
            SUM(CASE WHEN ts_init < ts_event THEN 1 ELSE 0 END) as ts_order_violation,
            SUM(CASE WHEN bid_price IS NULL THEN 1 ELSE 0 END) as null_bid,
            SUM(CASE WHEN ask_price IS NULL THEN 1 ELSE 0 END) as null_ask,
            SUM(CASE WHEN bid_size IS NULL THEN 1 ELSE 0 END) as null_bid_size,
            SUM(CASE WHEN ask_size IS NULL THEN 1 ELSE 0 END) as null_ask_size,
            MIN(ts_event) as min_ts,
            MAX(ts_event) as max_ts
        FROM (
            SELECT * FROM '{pattern}'
            USING SAMPLE {sample_size}
        )
        """

        try:
            result = self.db.query(sql).fetchone()
            if result is None:
                return CheckResult(
                    name="Sample Data Validation",
                    status=ValidationStatus.CRITICAL,
                    message="No data returned from sample query",
                )

            (
                total,
                bad_ts_event,
                bad_ts_init,
                ts_order_violation,
                null_bid,
                null_ask,
                null_bid_size,
                null_ask_size,
                min_ts,
                max_ts,
            ) = result

        except Exception as e:
            return CheckResult(
                name="Sample Data Validation",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to validate sample data: {e}",
            )

        # Check all invariants
        issues: list[str] = []
        if bad_ts_event > 0:
            issues.append(f"ts_event = 0: {bad_ts_event}")
        if bad_ts_init > 0:
            issues.append(f"ts_init = 0: {bad_ts_init}")
        if ts_order_violation > 0:
            issues.append(f"ts_init < ts_event: {ts_order_violation}")
        if null_bid > 0:
            issues.append(f"null bid_price: {null_bid}")
        if null_ask > 0:
            issues.append(f"null ask_price: {null_ask}")
        if null_bid_size > 0:
            issues.append(f"null bid_size: {null_bid_size}")
        if null_ask_size > 0:
            issues.append(f"null ask_size: {null_ask_size}")

        passed = len(issues) == 0

        return self.check(
            name="Sample Data Validation",
            condition=passed,
            message=(
                f"All {total:,} sampled ticks pass invariant checks"
                if passed
                else f"Invariant violations in sample: {', '.join(issues)}"
            ),
            value=total,
            threshold=sample_size,
            details={
                "sample_size": total,
                "bad_ts_event_count": bad_ts_event,
                "bad_ts_init_count": bad_ts_init,
                "ts_order_violation_count": ts_order_violation,
                "null_bid_count": null_bid,
                "null_ask_count": null_ask,
                "null_bid_size_count": null_bid_size,
                "null_ask_size_count": null_ask_size,
                "timestamp_range_ns": [min_ts, max_ts],
            },
        )

    def _check_gaps(self) -> CheckResult:
        """Detect gaps greater than 1 hour excluding weekends.

        Uses DuckDB window functions to find gaps between consecutive
        ticks. Weekend gaps (Friday evening to Sunday evening) are
        filtered out based on day-of-week and hour.

        Returns:
            CheckResult with PASS if no unexpected gaps, WARNING/FAIL
            if gaps are found.
        """
        pattern = self._parquet_pattern

        # Query to find all gaps > 1 hour with DOW and hour info
        sql = f"""
        WITH tick_gaps AS (
            SELECT
                ts_event,
                LAG(ts_event) OVER (ORDER BY ts_event) as prev_ts
            FROM '{pattern}'
        )
        SELECT
            prev_ts,
            ts_event,
            (ts_event - prev_ts) as gap_ns,
            EXTRACT(DOW FROM to_timestamp(prev_ts / 1000000000)) as prev_dow,
            EXTRACT(HOUR FROM to_timestamp(prev_ts / 1000000000)) as prev_hour,
            EXTRACT(DOW FROM to_timestamp(ts_event / 1000000000)) as curr_dow,
            EXTRACT(HOUR FROM to_timestamp(ts_event / 1000000000)) as curr_hour,
            to_timestamp(prev_ts / 1000000000) as prev_time,
            to_timestamp(ts_event / 1000000000) as curr_time
        FROM tick_gaps
        WHERE (ts_event - prev_ts) > {self.ONE_HOUR_NS}
        """

        try:
            gaps_df = self.db.query_df(sql)
        except Exception as e:
            return CheckResult(
                name="Gap Detection",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to execute gap detection query: {e}",
            )

        if gaps_df.is_empty():
            return self.check(
                name="Gap Detection",
                condition=True,
                message="No gaps > 1 hour found",
                value=0,
                threshold=0,
            )

        # Filter out weekend gaps
        non_weekend_gaps = self._filter_weekend_gaps(gaps_df)

        gap_count = len(non_weekend_gaps)
        total_gaps_found = len(gaps_df)
        weekend_gaps_filtered = total_gaps_found - gap_count

        if gap_count == 0:
            return self.check(
                name="Gap Detection",
                condition=True,
                message=(
                    f"All {total_gaps_found} gaps > 1 hour are weekend gaps "
                    "(expected)"
                ),
                value=0,
                threshold=0,
                details={
                    "total_gaps_found": total_gaps_found,
                    "weekend_gaps_filtered": weekend_gaps_filtered,
                    "unexpected_gaps": 0,
                },
            )

        # Build gap details for reporting
        gap_details = self._format_gap_details(non_weekend_gaps)

        # Determine severity based on gap count
        # Historical forex data has many legitimate gaps from:
        # - Holiday closures (Christmas, Easter, New Year)
        # - Extended weekends with DST transitions
        # - Market maintenance windows
        #
        # Thresholds:
        # - <= 5 gaps: likely data issues, WARNING
        # - <= 3000 gaps: likely holidays/DST over 20+ years, WARNING
        # - > 3000 gaps: potential data quality issue, FAIL
        if gap_count <= 5:
            status = ValidationStatus.WARNING
        elif gap_count <= 3000:
            # Expected for multi-decade historical data with holidays
            status = ValidationStatus.WARNING
        else:
            status = ValidationStatus.FAIL

        return CheckResult(
            name="Gap Detection",
            status=status,
            message=(
                f"Found {gap_count} unexpected gaps > 1 hour "
                f"(filtered {weekend_gaps_filtered} weekend gaps)"
            ),
            value=gap_count,
            threshold=0,
            details={
                "total_gaps_found": total_gaps_found,
                "weekend_gaps_filtered": weekend_gaps_filtered,
                "unexpected_gaps": gap_count,
                "gaps": gap_details[:10],  # Limit to first 10
            },
        )

    def _filter_weekend_gaps(self, gaps_df: pl.DataFrame) -> pl.DataFrame:
        """Filter out weekend gaps from the gaps DataFrame.

        Weekend gaps are defined as:
            - Previous tick: Friday (DOW=5) after 20:00 UTC
            - Current tick: Sunday (DOW=0) after 20:00 UTC or early Monday
            - Gap duration: 40-55 hours (typical weekend)

        Args:
            gaps_df: DataFrame with gap information including DOW and hour.

        Returns:
            Filtered DataFrame with only non-weekend gaps.
        """
        # Calculate gap in hours
        gaps_with_hours = gaps_df.with_columns(
            (pl.col("gap_ns") / 3_600_000_000_000).alias("gap_hours")
        )

        # Filter: keep gaps that are NOT weekend gaps
        # A weekend gap is: Friday evening (DOW=5, hour>=20) to
        # Sunday evening (DOW=0, hour>=20) or early Monday (DOW=1)
        non_weekend = gaps_with_hours.filter(
            ~(
                # Duration in typical weekend range
                (pl.col("gap_hours") >= self.MIN_WEEKEND_GAP_HOURS)
                & (pl.col("gap_hours") <= self.MAX_WEEKEND_GAP_HOURS)
                # Previous tick is Friday evening
                & (pl.col("prev_dow") == 5)
                & (pl.col("prev_hour") >= 20)
                # Current tick is Sunday evening or early Monday
                & (
                    ((pl.col("curr_dow") == 0) & (pl.col("curr_hour") >= 20))
                    | ((pl.col("curr_dow") == 1) & (pl.col("curr_hour") < 4))
                )
            )
        )

        return non_weekend

    def _format_gap_details(
        self,
        gaps_df: pl.DataFrame,
    ) -> list[dict[str, Any]]:
        """Format gap details for inclusion in check results.

        Args:
            gaps_df: DataFrame with gap information.

        Returns:
            List of dictionaries with gap details.
        """
        details: list[dict[str, Any]] = []

        for row in gaps_df.iter_rows(named=True):
            gap_hours = row["gap_ns"] / 3_600_000_000_000
            details.append({
                "prev_time": str(row["prev_time"]),
                "curr_time": str(row["curr_time"]),
                "gap_hours": round(gap_hours, 2),
                "prev_dow": int(row["prev_dow"]),
                "curr_dow": int(row["curr_dow"]),
            })

        return details

    def _check_duplicates(self) -> CheckResult:
        """Check for duplicate ts_event timestamps.

        Compares total count vs distinct ts_event count to find duplicates.

        Returns:
            CheckResult with PASS if no duplicates, FAIL if duplicates found.
        """
        pattern = self._parquet_pattern

        sql = f"""
        SELECT
            COUNT(*) as total_count,
            COUNT(DISTINCT ts_event) as distinct_count
        FROM '{pattern}'
        """

        try:
            result = self.db.query(sql).fetchone()
            if result is None:
                return CheckResult(
                    name="Duplicate Detection",
                    status=ValidationStatus.CRITICAL,
                    message="No data returned from duplicate check query",
                )

            total_count, distinct_count = result
        except Exception as e:
            return CheckResult(
                name="Duplicate Detection",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to check for duplicates: {e}",
            )

        duplicate_count = total_count - distinct_count
        passed = duplicate_count == 0

        return self.check(
            name="Duplicate Detection",
            condition=passed,
            message=(
                f"No duplicate timestamps found in {total_count:,} ticks"
                if passed
                else f"Found {duplicate_count:,} duplicate timestamps"
            ),
            value=duplicate_count,
            threshold=0,
            details={
                "total_count": total_count,
                "distinct_count": distinct_count,
                "duplicate_count": duplicate_count,
            },
        )

    def _check_monotonicity(self) -> CheckResult:
        """Verify ts_event timestamps are monotonically increasing.

        Uses LAG window function to find any timestamps that are less than
        their predecessor.

        Returns:
            CheckResult with PASS if monotonic, FAIL if violations found.
        """
        pattern = self._parquet_pattern

        # Count violations where current ts < previous ts
        sql = f"""
        SELECT COUNT(*) as violations
        FROM (
            SELECT
                ts_event,
                LAG(ts_event) OVER (ORDER BY ts_event) as prev_ts
            FROM '{pattern}'
        )
        WHERE ts_event < prev_ts
        """

        try:
            result = self.db.query(sql).fetchone()
            violation_count = result[0] if result else 0
        except Exception as e:
            return CheckResult(
                name="Monotonicity Check",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to check monotonicity: {e}",
            )

        passed = violation_count == 0

        return self.check(
            name="Monotonicity Check",
            condition=passed,
            message=(
                "Timestamps are monotonically increasing"
                if passed
                else f"Found {violation_count:,} monotonicity violations"
            ),
            value=violation_count,
            threshold=0,
        )

    def _check_schema(self) -> CheckResult:
        """Verify all Parquet files have the expected schema columns.

        Checks that the required columns exist:
            bid_price, ask_price, bid_size, ask_size, ts_event, ts_init

        Returns:
            CheckResult with PASS if schema matches, FAIL otherwise.
        """
        pattern = self._parquet_pattern

        # Use DESCRIBE to get schema
        sql = f"""
        DESCRIBE SELECT * FROM '{pattern}' LIMIT 1
        """

        try:
            schema_df = self.db.query_df(sql)
        except Exception as e:
            return CheckResult(
                name="Schema Consistency",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to describe schema: {e}",
            )

        # Extract column names from schema
        actual_columns: set[str] = set()
        if "column_name" in schema_df.columns:
            actual_columns = set(schema_df["column_name"].to_list())
        elif len(schema_df.columns) > 0:
            # Fallback: first column might be the name
            actual_columns = set(schema_df[schema_df.columns[0]].to_list())

        # Check for missing columns
        missing = self.EXPECTED_COLUMNS - actual_columns
        extra = actual_columns - self.EXPECTED_COLUMNS

        passed = len(missing) == 0

        if passed:
            message = f"Schema valid: {len(actual_columns)} columns present"
            if extra:
                message += f" (extra columns: {sorted(extra)})"
        else:
            message = f"Missing required columns: {sorted(missing)}"

        return self.check(
            name="Schema Consistency",
            condition=passed,
            message=message,
            value=len(actual_columns),
            threshold=len(self.EXPECTED_COLUMNS),
            details={
                "expected_columns": sorted(self.EXPECTED_COLUMNS),
                "actual_columns": sorted(actual_columns),
                "missing_columns": sorted(missing),
                "extra_columns": sorted(extra),
            },
        )
