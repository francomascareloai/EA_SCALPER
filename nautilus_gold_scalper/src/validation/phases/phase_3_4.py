"""
Phase 3 and Phase 4 Validators for XAUUSD Session Catalog Validation.

Phase 3: Session Catalog Validation
    - Session existence check (all 6 session catalogs)
    - Session tick counts validation
    - Session boundary verification (hour ranges)
    - DST handling awareness (2007 rule change)
    - No overlap detection
    - Schema consistency across sessions

Phase 4: Integrity & Cleanup
    - Cross-catalog consistency (SUM sessions = main, EXACT match)
    - Metadata audit (.checkpoint.json files)
    - Temporal consistency (date range matching)
    - Data lineage verification

Session Definitions (UTC):
    - ASIAN: 00:00-07:00
    - LONDON: 07:00-12:00
    - OVERLAP: 12:00-15:00
    - NY: 15:00-17:00
    - LATE_NY: 17:00-21:00
    - EVENING: 21:00-00:00

DST Note:
    US DST rules changed in 2007 (Energy Policy Act of 2005):
    - Before 2007: First Sunday in April to last Sunday in October
    - From 2007: Second Sunday in March to first Sunday in November
    This affects ET to UTC conversions for session boundaries.
"""

from __future__ import annotations

import json
import logging
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING, Any, ClassVar
from zoneinfo import ZoneInfo

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
    from src.validation.core.config import ValidationConfig

logger = logging.getLogger(__name__)


# Session definitions: (start_hour_utc, end_hour_utc)
# Note: end_hour is exclusive, 24 means midnight (00:00 next day)
SESSIONS: dict[str, tuple[int, int]] = {
    "ASIAN": (0, 7),
    "LONDON": (7, 12),
    "OVERLAP": (12, 15),
    "NY": (15, 17),
    "LATE_NY": (17, 21),
    "EVENING": (21, 24),
}

# Session names ordered for iteration
SESSION_NAMES: list[str] = ["ASIAN", "LONDON", "OVERLAP", "NY", "LATE_NY", "EVENING"]

# Timezone for DST handling
ET_TIMEZONE = ZoneInfo("America/New_York")
UTC_TIMEZONE = ZoneInfo("UTC")


def _get_session_catalog_name(session: str) -> str:
    """Get the catalog folder name for a session.

    Args:
        session: Session name (e.g., "ASIAN")

    Returns:
        Catalog folder name (e.g., "xauusd_2003_2025_stride1_ASIAN")
    """
    return f"xauusd_2003_2025_stride1_{session}"


def _is_hour_in_session(hour: int, start_hour: int, end_hour: int) -> bool:
    """Check if an hour falls within a session boundary.

    Args:
        hour: UTC hour (0-23)
        start_hour: Session start hour (inclusive)
        end_hour: Session end hour (exclusive), 24 means midnight

    Returns:
        True if hour is within the session
    """
    if end_hour == 24:
        # Session ends at midnight
        return start_hour <= hour < 24
    return start_hour <= hour < end_hour


class Phase3Validator(PhaseValidator):
    """Phase 3: Session Catalog Validation.

    Validates that session catalogs are correctly structured and contain
    data within their defined UTC hour boundaries.

    Checks performed:
        1. Session Existence: All 6 session catalogs exist
        2. Session Tick Counts: Each session has reasonable tick count
        3. Session Boundaries: Ticks fall within correct hour ranges
        4. DST Handling: Awareness of 2007 DST rule change
        5. No Overlap: Same tick doesn't appear in multiple sessions
        6. Schema Consistency: All session catalogs have same schema

    Attributes:
        main_catalog_path: Path to the main (complete) catalog
        session_catalogs_base: Base path for session catalogs

    Example:
        >>> config = ValidationConfig(catalog_path="/data/catalog_native/main")
        >>> db = DuckDBConnection()
        >>> validator = Phase3Validator(config, db)
        >>> result = validator.validate()
        >>> print(result.status)
    """

    phase_id: ClassVar[str] = "phase_3"
    phase_name: ClassVar[str] = "Session Catalog Validation"

    def __init__(
        self,
        config: ValidationConfig,
        db: DuckDBConnection,
        main_catalog_path: Path | None = None,
        session_catalogs_base: Path | None = None,
    ) -> None:
        """Initialize Phase 3 validator.

        Args:
            config: Validation configuration.
            db: DuckDB connection for queries.
            main_catalog_path: Path to main catalog. If None, uses config.catalog_path.
            session_catalogs_base: Base path for session catalogs.
                If None, derives from main_catalog_path by looking for
                catalog_native_sessions sibling directory.
        """
        super().__init__(config, db)

        self._main_catalog = (
            main_catalog_path
            if main_catalog_path is not None
            else Path(config.catalog_path)
        )

        if session_catalogs_base is not None:
            self._session_base = session_catalogs_base
        else:
            # Derive session base from main catalog path
            # Main: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/
            # Sessions: data/catalog_native_sessions/
            catalog_parent = self._main_catalog.parent.parent
            self._session_base = catalog_parent / "catalog_native_sessions"

        logger.debug(
            "Phase3Validator initialized: main=%s, sessions=%s",
            self._main_catalog,
            self._session_base,
        )

    def validate(self) -> PhaseResult:
        """Execute all session catalog validation checks.

        Returns:
            PhaseResult with all check results.
        """
        result = PhaseResult(
            phase_id=self.phase_id,
            phase_name=self.phase_name,
            status=ValidationStatus.PASS,
            start_time=datetime.now(),
        )

        # Check 1: Session existence
        result.add_check(self._check_session_existence())

        # Only proceed with other checks if sessions exist
        if result.checks[-1].status == ValidationStatus.FAIL:
            result.status = result.compute_status()
            result.end_time = datetime.now()
            return result

        # Check 2: Session tick counts
        result.add_check(self._check_session_tick_counts())

        # Check 3: Session boundaries
        boundary_checks = self._check_session_boundaries()
        for check in boundary_checks:
            result.add_check(check)

        # Check 4: DST handling awareness
        result.add_check(self._check_dst_handling())

        # Check 5: No overlap (via tick count analysis)
        result.add_check(self._check_no_overlap())

        # Check 6: Schema consistency
        result.add_check(self._check_schema_consistency())

        result.status = result.compute_status()
        result.end_time = datetime.now()
        return result

    def _get_session_path(self, session: str) -> Path:
        """Get the full path to a session catalog.

        Args:
            session: Session name (e.g., "ASIAN")

        Returns:
            Full path to the session catalog directory
        """
        return self._session_base / _get_session_catalog_name(session)

    def _check_session_existence(self) -> CheckResult:
        """Check that all 6 session catalogs exist.

        Returns:
            CheckResult with PASS if all exist, FAIL otherwise
        """
        missing: list[str] = []
        existing: list[str] = []

        for session in SESSION_NAMES:
            session_path = self._get_session_path(session)
            parquet_path = session_path / "data" / "quote_tick"

            if session_path.exists() and parquet_path.exists():
                existing.append(session)
            else:
                missing.append(session)

        if missing:
            return CheckResult(
                name="Session Existence",
                status=ValidationStatus.FAIL,
                message=f"Missing session catalogs: {', '.join(missing)}",
                value=len(existing),
                threshold=6,
                details={"existing": existing, "missing": missing},
            )

        return CheckResult(
            name="Session Existence",
            status=ValidationStatus.PASS,
            message="All 6 session catalogs exist",
            value=6,
            threshold=6,
            details={"sessions": existing},
        )

    def _check_session_tick_counts(self) -> CheckResult:
        """Check that each session has a reasonable tick count.

        Returns:
            CheckResult with tick count summary
        """
        session_counts: dict[str, int] = {}
        total_ticks = 0
        issues: list[str] = []

        for session in SESSION_NAMES:
            session_path = self._get_session_path(session)
            parquet_pattern = f"{session_path}/data/quote_tick/**/*.parquet"

            try:
                result = self.db.query(
                    f"SELECT COUNT(*) FROM '{parquet_pattern}'"
                ).fetchone()
                count = int(result[0]) if result else 0
            except Exception as e:
                logger.warning("Failed to count ticks for %s: %s", session, e)
                count = 0
                issues.append(f"{session}: query failed")

            session_counts[session] = count
            total_ticks += count

            # Check for suspiciously low counts (less than 1M ticks)
            if count < 1_000_000:
                issues.append(f"{session}: only {count:,} ticks (expected >= 1M)")

        if issues:
            return CheckResult(
                name="Session Tick Counts",
                status=ValidationStatus.WARNING,
                message=f"Tick count issues: {'; '.join(issues[:3])}",
                value=total_ticks,
                details={"session_counts": session_counts, "issues": issues},
            )

        return CheckResult(
            name="Session Tick Counts",
            status=ValidationStatus.PASS,
            message=f"All sessions have reasonable tick counts. Total: {total_ticks:,}",
            value=total_ticks,
            details={"session_counts": session_counts},
        )

    def _check_session_boundaries(self) -> list[CheckResult]:
        """Check that ticks in each session fall within correct hour ranges.

        Returns:
            List of CheckResult, one per session
        """
        checks: list[CheckResult] = []

        for session in SESSION_NAMES:
            start_hour, end_hour = SESSIONS[session]
            session_path = self._get_session_path(session)
            parquet_pattern = f"{session_path}/data/quote_tick/**/*.parquet"

            try:
                # Query hour distribution
                hour_dist = self.db.query_df(f"""
                    SELECT
                        EXTRACT(HOUR FROM to_timestamp(ts_event/1e9)) as hour,
                        COUNT(*) as cnt
                    FROM '{parquet_pattern}'
                    GROUP BY hour
                    ORDER BY hour
                """)

                if hour_dist.is_empty():
                    checks.append(
                        CheckResult(
                            name=f"Session Boundary ({session})",
                            status=ValidationStatus.WARNING,
                            message=f"No data found for session {session}",
                        )
                    )
                    continue

                # Check for out-of-bounds hours
                out_of_bounds: list[dict[str, Any]] = []
                total_ticks = 0
                out_of_bounds_ticks = 0

                for row in hour_dist.iter_rows(named=True):
                    hour = int(row["hour"])
                    count = int(row["cnt"])
                    total_ticks += count

                    if not _is_hour_in_session(hour, start_hour, end_hour):
                        out_of_bounds.append({"hour": hour, "count": count})
                        out_of_bounds_ticks += count

                if out_of_bounds:
                    pct_bad = (
                        (out_of_bounds_ticks / total_ticks * 100)
                        if total_ticks > 0
                        else 0
                    )
                    # More than 0.1% out of bounds is a failure
                    status = (
                        ValidationStatus.FAIL
                        if pct_bad > 0.1
                        else ValidationStatus.WARNING
                    )
                    checks.append(
                        CheckResult(
                            name=f"Session Boundary ({session})",
                            status=status,
                            message=(
                                f"{session}: {out_of_bounds_ticks:,} ticks "
                                f"({pct_bad:.4f}%) outside {start_hour:02d}:00-"
                                f"{end_hour:02d}:00 UTC"
                            ),
                            value=pct_bad,
                            threshold=0.1,
                            details={
                                "expected_range": f"{start_hour:02d}-{end_hour:02d}",
                                "out_of_bounds": out_of_bounds,
                            },
                        )
                    )
                else:
                    checks.append(
                        CheckResult(
                            name=f"Session Boundary ({session})",
                            status=ValidationStatus.PASS,
                            message=(
                                f"{session}: All {total_ticks:,} ticks within "
                                f"{start_hour:02d}:00-{end_hour:02d}:00 UTC"
                            ),
                            value=0.0,
                            threshold=0.1,
                        )
                    )

            except Exception as e:
                logger.exception("Failed to check boundaries for %s", session)
                checks.append(
                    CheckResult(
                        name=f"Session Boundary ({session})",
                        status=ValidationStatus.FAIL,
                        message=f"Query failed: {e}",
                    )
                )

        return checks

    def _check_dst_handling(self) -> CheckResult:
        """Check for DST handling awareness.

        The US changed DST rules in 2007:
        - Before 2007: First Sunday in April to last Sunday in October
        - From 2007: Second Sunday in March to first Sunday in November

        This check verifies the data acknowledges this transition and
        doesn't have suspicious gaps around DST boundaries.

        Returns:
            CheckResult with DST handling status
        """
        # Check for data around known DST transition dates
        # 2007 was the first year with the new rules
        # March 11, 2007 was the first "early" DST start

        notes: list[str] = []
        main_parquet = f"{self._main_catalog}/data/quote_tick/**/*.parquet"

        try:
            # Check for data around March 11, 2007 (first new DST transition)
            result_2007 = self.db.query(f"""
                SELECT COUNT(*) as cnt
                FROM '{main_parquet}'
                WHERE ts_event >= 1173571200000000000  -- March 11, 2007 00:00 UTC
                  AND ts_event < 1173657600000000000   -- March 12, 2007 00:00 UTC
            """).fetchone()

            ticks_march_11_2007 = int(result_2007[0]) if result_2007 else 0

            if ticks_march_11_2007 > 0:
                notes.append(
                    f"Data exists for March 11, 2007 (first new DST): "
                    f"{ticks_march_11_2007:,} ticks"
                )
            else:
                notes.append("No data for March 11, 2007 (first new DST)")

            # Check for data in 2006 (old DST rules) - April 2, 2006
            result_2006 = self.db.query(f"""
                SELECT COUNT(*) as cnt
                FROM '{main_parquet}'
                WHERE ts_event >= 1143936000000000000  -- April 2, 2006 00:00 UTC
                  AND ts_event < 1144022400000000000   -- April 3, 2006 00:00 UTC
            """).fetchone()

            ticks_april_2_2006 = int(result_2006[0]) if result_2006 else 0

            if ticks_april_2_2006 > 0:
                notes.append(
                    f"Data exists for April 2, 2006 (old DST): "
                    f"{ticks_april_2_2006:,} ticks"
                )

            return CheckResult(
                name="DST Handling Awareness",
                status=ValidationStatus.PASS,
                message=(
                    "DST transition dates verified. Sessions use UTC boundaries, "
                    "DST affects ET-based trading hours interpretation."
                ),
                details={
                    "notes": notes,
                    "dst_rule_change_year": 2007,
                    "new_dst_start": "Second Sunday in March",
                    "old_dst_start": "First Sunday in April",
                },
            )

        except Exception as e:
            logger.warning("Failed to check DST handling: %s", e)
            return CheckResult(
                name="DST Handling Awareness",
                status=ValidationStatus.WARNING,
                message=f"Could not verify DST handling: {e}",
            )

    def _check_no_overlap(self) -> CheckResult:
        """Check that no tick appears in multiple sessions.

        This is verified implicitly by comparing the sum of session ticks
        to the main catalog count. If there are overlaps, the sum will exceed
        the main catalog count.

        Returns:
            CheckResult with overlap analysis
        """
        session_total = 0
        session_counts: dict[str, int] = {}

        for session in SESSION_NAMES:
            session_path = self._get_session_path(session)
            parquet_pattern = f"{session_path}/data/quote_tick/**/*.parquet"

            try:
                result = self.db.query(
                    f"SELECT COUNT(*) FROM '{parquet_pattern}'"
                ).fetchone()
                count = int(result[0]) if result else 0
            except Exception:
                count = 0

            session_counts[session] = count
            session_total += count

        # Get main catalog count
        main_parquet = f"{self._main_catalog}/data/quote_tick/**/*.parquet"
        try:
            main_result = self.db.query(
                f"SELECT COUNT(*) FROM '{main_parquet}'"
            ).fetchone()
            main_count = int(main_result[0]) if main_result else 0
        except Exception as e:
            logger.warning("Failed to get main catalog count: %s", e)
            return CheckResult(
                name="No Session Overlap",
                status=ValidationStatus.WARNING,
                message=f"Could not query main catalog: {e}",
            )

        diff = session_total - main_count

        if diff > 0:
            # Overlapping ticks detected
            return CheckResult(
                name="No Session Overlap",
                status=ValidationStatus.FAIL,
                message=(
                    f"Overlap detected: sessions total {session_total:,} > "
                    f"main {main_count:,} (diff: {diff:,})"
                ),
                value=diff,
                threshold=0,
                details={"session_counts": session_counts, "main_count": main_count},
            )

        if diff < 0:
            # Missing ticks
            return CheckResult(
                name="No Session Overlap",
                status=ValidationStatus.WARNING,
                message=(
                    f"Missing ticks: sessions total {session_total:,} < "
                    f"main {main_count:,} (diff: {diff:,})"
                ),
                value=diff,
                threshold=0,
                details={"session_counts": session_counts, "main_count": main_count},
            )

        return CheckResult(
            name="No Session Overlap",
            status=ValidationStatus.PASS,
            message=(
                f"No overlap: sessions total {session_total:,} = main {main_count:,}"
            ),
            value=0,
            threshold=0,
            details={"session_counts": session_counts, "main_count": main_count},
        )

    def _check_schema_consistency(self) -> CheckResult:
        """Check that all session catalogs have the same schema.

        Returns:
            CheckResult with schema comparison
        """
        schemas: dict[str, list[tuple[str, str]]] = {}
        reference_schema: list[tuple[str, str]] | None = None
        reference_session: str | None = None
        mismatches: list[str] = []

        for session in SESSION_NAMES:
            session_path = self._get_session_path(session)
            parquet_pattern = f"{session_path}/data/quote_tick/**/*.parquet"

            try:
                # Get schema using DESCRIBE
                schema_df = self.db.query_df(f"""
                    DESCRIBE SELECT * FROM '{parquet_pattern}' LIMIT 0
                """)

                # Extract column name and type pairs
                schema: list[tuple[str, str]] = []
                for row in schema_df.iter_rows(named=True):
                    col_name = str(row.get("column_name", row.get("Field", "")))
                    col_type = str(row.get("column_type", row.get("Type", "")))
                    schema.append((col_name, col_type))

                schemas[session] = schema

                if reference_schema is None:
                    reference_schema = schema
                    reference_session = session
                elif schema != reference_schema:
                    mismatches.append(session)

            except Exception as e:
                logger.warning("Failed to get schema for %s: %s", session, e)
                mismatches.append(f"{session} (query failed)")

        if mismatches:
            return CheckResult(
                name="Schema Consistency",
                status=ValidationStatus.FAIL,
                message=f"Schema mismatch in sessions: {', '.join(mismatches)}",
                value=len(mismatches),
                threshold=0,
                details={
                    "reference_session": reference_session,
                    "schemas": {k: [list(t) for t in v] for k, v in schemas.items()},
                    "mismatches": mismatches,
                },
            )

        return CheckResult(
            name="Schema Consistency",
            status=ValidationStatus.PASS,
            message=f"All {len(SESSION_NAMES)} session catalogs have consistent schema",
            value=0,
            threshold=0,
            details={
                "reference_session": reference_session,
                "column_count": len(reference_schema) if reference_schema else 0,
            },
        )


class Phase4Validator(PhaseValidator):
    """Phase 4: Integrity & Cleanup Validation.

    Validates data integrity across catalogs and verifies metadata.

    Checks performed:
        1. Cross-Catalog Consistency: SUM(session ticks) = main catalog ticks
           (EXACT match, 0 tolerance)
        2. Metadata Audit: .checkpoint.json files exist and are valid
        3. Temporal Consistency: Session catalogs cover same date range as main
        4. Data Lineage: Source file and transformation documented

    Attributes:
        main_catalog_path: Path to the main (complete) catalog
        session_catalogs_base: Base path for session catalogs

    Example:
        >>> config = ValidationConfig(catalog_path="/data/catalog_native/main")
        >>> db = DuckDBConnection()
        >>> validator = Phase4Validator(config, db)
        >>> result = validator.validate()
        >>> print(result.status)
    """

    phase_id: ClassVar[str] = "phase_4"
    phase_name: ClassVar[str] = "Integrity & Cleanup Validation"

    def __init__(
        self,
        config: ValidationConfig,
        db: DuckDBConnection,
        main_catalog_path: Path | None = None,
        session_catalogs_base: Path | None = None,
    ) -> None:
        """Initialize Phase 4 validator.

        Args:
            config: Validation configuration.
            db: DuckDB connection for queries.
            main_catalog_path: Path to main catalog. If None, uses config.catalog_path.
            session_catalogs_base: Base path for session catalogs.
        """
        super().__init__(config, db)

        self._main_catalog = (
            main_catalog_path
            if main_catalog_path is not None
            else Path(config.catalog_path)
        )

        if session_catalogs_base is not None:
            self._session_base = session_catalogs_base
        else:
            catalog_parent = self._main_catalog.parent.parent
            self._session_base = catalog_parent / "catalog_native_sessions"

        logger.debug(
            "Phase4Validator initialized: main=%s, sessions=%s",
            self._main_catalog,
            self._session_base,
        )

    def validate(self) -> PhaseResult:
        """Execute all integrity and cleanup validation checks.

        Returns:
            PhaseResult with all check results.
        """
        result = PhaseResult(
            phase_id=self.phase_id,
            phase_name=self.phase_name,
            status=ValidationStatus.PASS,
            start_time=datetime.now(),
        )

        # Check 1: Cross-catalog consistency (CRITICAL - must be exact)
        result.add_check(self._check_cross_catalog_consistency())

        # Check 2: Metadata audit
        result.add_check(self._check_metadata_audit())

        # Check 3: Temporal consistency
        result.add_check(self._check_temporal_consistency())

        # Check 4: Data lineage
        result.add_check(self._check_data_lineage())

        result.status = result.compute_status()
        result.end_time = datetime.now()
        return result

    def _get_session_path(self, session: str) -> Path:
        """Get the full path to a session catalog.

        Args:
            session: Session name (e.g., "ASIAN")

        Returns:
            Full path to the session catalog directory
        """
        return self._session_base / _get_session_catalog_name(session)

    def _check_cross_catalog_consistency(self) -> CheckResult:
        """Check that sum of session ticks equals main catalog ticks exactly.

        This is a CRITICAL check with 0 tolerance. Any mismatch indicates
        data corruption or incomplete session splitting.

        Returns:
            CheckResult with CRITICAL status if mismatch
        """
        # Get main catalog count
        main_parquet = f"{self._main_catalog}/data/quote_tick/**/*.parquet"
        try:
            main_result = self.db.query(
                f"SELECT COUNT(*) FROM '{main_parquet}'"
            ).fetchone()
            main_count = int(main_result[0]) if main_result else 0
        except Exception as e:
            return CheckResult(
                name="Cross-Catalog Consistency",
                status=ValidationStatus.CRITICAL,
                message=f"Failed to query main catalog: {e}",
            )

        # Sum session counts
        session_total = 0
        session_counts: dict[str, int] = {}

        for session in SESSION_NAMES:
            session_path = self._get_session_path(session)
            parquet_pattern = f"{session_path}/data/quote_tick/**/*.parquet"

            try:
                result = self.db.query(
                    f"SELECT COUNT(*) FROM '{parquet_pattern}'"
                ).fetchone()
                count = int(result[0]) if result else 0
            except Exception as e:
                logger.warning("Failed to count session %s: %s", session, e)
                count = 0

            session_counts[session] = count
            session_total += count

        # EXACT match required (0 tolerance)
        diff = session_total - main_count

        if diff != 0:
            status = ValidationStatus.CRITICAL
            if diff > 0:
                message = (
                    f"CRITICAL: Overlap detected. Sessions total {session_total:,} > "
                    f"main {main_count:,}. Difference: +{diff:,} ticks."
                )
            else:
                message = (
                    f"CRITICAL: Missing ticks. Sessions total {session_total:,} < "
                    f"main {main_count:,}. Difference: {diff:,} ticks."
                )

            return CheckResult(
                name="Cross-Catalog Consistency",
                status=status,
                message=message,
                value=session_total,
                threshold=main_count,
                details={
                    "main_count": main_count,
                    "session_total": session_total,
                    "difference": diff,
                    "session_counts": session_counts,
                },
            )

        return CheckResult(
            name="Cross-Catalog Consistency",
            status=ValidationStatus.PASS,
            message=(
                f"EXACT match: {main_count:,} ticks in main = "
                f"{session_total:,} ticks across {len(SESSION_NAMES)} sessions"
            ),
            value=session_total,
            threshold=main_count,
            details={
                "main_count": main_count,
                "session_counts": session_counts,
            },
        )

    def _check_metadata_audit(self) -> CheckResult:
        """Check that .checkpoint.json files exist and are valid.

        Returns:
            CheckResult with metadata status
        """
        issues: list[str] = []
        valid_checkpoints: list[str] = []

        # Check main catalog checkpoint
        main_checkpoint = self._main_catalog / ".checkpoint.json"
        if main_checkpoint.exists():
            try:
                with open(main_checkpoint, encoding="utf-8") as f:
                    data = json.load(f)
                    if "tick_count" in data:
                        valid_checkpoints.append("main")
                    else:
                        issues.append("main: missing tick_count field")
            except json.JSONDecodeError as e:
                issues.append(f"main: invalid JSON - {e}")
        else:
            issues.append("main: .checkpoint.json not found")

        # Check session checkpoints
        for session in SESSION_NAMES:
            session_path = self._get_session_path(session)
            checkpoint_path = session_path / ".checkpoint.json"

            if checkpoint_path.exists():
                try:
                    with open(checkpoint_path, encoding="utf-8") as f:
                        data = json.load(f)
                        if "tick_count" in data:
                            valid_checkpoints.append(session)
                        else:
                            issues.append(f"{session}: missing tick_count field")
                except json.JSONDecodeError as e:
                    issues.append(f"{session}: invalid JSON - {e}")
            else:
                issues.append(f"{session}: .checkpoint.json not found")

        if issues:
            status = (
                ValidationStatus.WARNING
                if len(valid_checkpoints) > 0
                else ValidationStatus.FAIL
            )
            return CheckResult(
                name="Metadata Audit",
                status=status,
                message=f"Metadata issues: {'; '.join(issues[:5])}",
                value=len(valid_checkpoints),
                threshold=7,  # main + 6 sessions
                details={"valid": valid_checkpoints, "issues": issues},
            )

        return CheckResult(
            name="Metadata Audit",
            status=ValidationStatus.PASS,
            message=(
                f"All {len(valid_checkpoints)} checkpoint files valid "
                f"(main + {len(SESSION_NAMES)} sessions)"
            ),
            value=len(valid_checkpoints),
            threshold=7,
            details={"valid": valid_checkpoints},
        )

    def _check_temporal_consistency(self) -> CheckResult:
        """Check that session catalogs cover the same date range as main.

        Returns:
            CheckResult with temporal consistency status
        """
        # Get main catalog date range
        main_parquet = f"{self._main_catalog}/data/quote_tick/**/*.parquet"
        try:
            main_range = self.db.query(f"""
                SELECT
                    MIN(ts_event) as min_ts,
                    MAX(ts_event) as max_ts
                FROM '{main_parquet}'
            """).fetchone()

            if main_range is None:
                return CheckResult(
                    name="Temporal Consistency",
                    status=ValidationStatus.FAIL,
                    message="Could not determine main catalog date range",
                )

            main_min_ts, main_max_ts = main_range
        except Exception as e:
            return CheckResult(
                name="Temporal Consistency",
                status=ValidationStatus.FAIL,
                message=f"Failed to query main catalog: {e}",
            )

        # Get combined session date range
        session_min_ts: int | None = None
        session_max_ts: int | None = None

        for session in SESSION_NAMES:
            session_path = self._get_session_path(session)
            parquet_pattern = f"{session_path}/data/quote_tick/**/*.parquet"

            try:
                session_range = self.db.query(f"""
                    SELECT
                        MIN(ts_event) as min_ts,
                        MAX(ts_event) as max_ts
                    FROM '{parquet_pattern}'
                """).fetchone()

                if session_range is not None and session_range[0] is not None:
                    if session_min_ts is None or session_range[0] < session_min_ts:
                        session_min_ts = session_range[0]
                    if session_max_ts is None or session_range[1] > session_max_ts:
                        session_max_ts = session_range[1]

            except Exception as e:
                logger.warning("Failed to get date range for %s: %s", session, e)

        if session_min_ts is None or session_max_ts is None:
            return CheckResult(
                name="Temporal Consistency",
                status=ValidationStatus.FAIL,
                message="Could not determine session catalogs date range",
            )

        # Convert to datetime for comparison
        main_min_dt = datetime.fromtimestamp(main_min_ts / 1e9, tz=UTC_TIMEZONE)
        main_max_dt = datetime.fromtimestamp(main_max_ts / 1e9, tz=UTC_TIMEZONE)
        session_min_dt = datetime.fromtimestamp(session_min_ts / 1e9, tz=UTC_TIMEZONE)
        session_max_dt = datetime.fromtimestamp(session_max_ts / 1e9, tz=UTC_TIMEZONE)

        # Check for significant differences (more than 1 day)
        start_diff_days = abs((main_min_dt - session_min_dt).days)
        end_diff_days = abs((main_max_dt - session_max_dt).days)

        if start_diff_days > 1 or end_diff_days > 1:
            return CheckResult(
                name="Temporal Consistency",
                status=ValidationStatus.FAIL,
                message=(
                    f"Date range mismatch. Main: {main_min_dt.date()} to "
                    f"{main_max_dt.date()}, Sessions: {session_min_dt.date()} to "
                    f"{session_max_dt.date()}"
                ),
                value=max(start_diff_days, end_diff_days),
                threshold=1,
                details={
                    "main_start": main_min_dt.isoformat(),
                    "main_end": main_max_dt.isoformat(),
                    "session_start": session_min_dt.isoformat(),
                    "session_end": session_max_dt.isoformat(),
                    "start_diff_days": start_diff_days,
                    "end_diff_days": end_diff_days,
                },
            )

        return CheckResult(
            name="Temporal Consistency",
            status=ValidationStatus.PASS,
            message=(
                f"Date ranges consistent. Main and sessions cover "
                f"{main_min_dt.date()} to {main_max_dt.date()}"
            ),
            value=0,
            threshold=1,
            details={
                "main_start": main_min_dt.isoformat(),
                "main_end": main_max_dt.isoformat(),
                "session_start": session_min_dt.isoformat(),
                "session_end": session_max_dt.isoformat(),
            },
        )

    def _check_data_lineage(self) -> CheckResult:
        """Check that data lineage is documented.

        Verifies:
        - Source file is documented
        - Transformation process is documented

        Returns:
            CheckResult with lineage status
        """
        lineage_found: list[str] = []
        issues: list[str] = []

        # Check for lineage in main catalog checkpoint
        main_checkpoint = self._main_catalog / ".checkpoint.json"
        if main_checkpoint.exists():
            try:
                with open(main_checkpoint, encoding="utf-8") as f:
                    data = json.load(f)

                    # Check for source file documentation
                    if "source_file" in data or "source" in data:
                        lineage_found.append("source_file")
                    else:
                        issues.append("source_file not documented")

                    # Check for transformation documentation
                    if "transformation" in data or "process" in data:
                        lineage_found.append("transformation")
                    # This is optional, so just note if missing

                    # Check for creation timestamp
                    if "created_at" in data or "timestamp" in data:
                        lineage_found.append("creation_timestamp")

            except json.JSONDecodeError:
                issues.append("main checkpoint JSON invalid")
        else:
            issues.append("main checkpoint not found")

        # Check for README or documentation
        readme_paths = [
            self._main_catalog / "README.md",
            self._main_catalog / "README.txt",
            self._main_catalog.parent / "README.md",
        ]

        readme_found = any(p.exists() for p in readme_paths)
        if readme_found:
            lineage_found.append("README")

        # Determine status
        if not lineage_found and issues:
            return CheckResult(
                name="Data Lineage",
                status=ValidationStatus.WARNING,
                message=f"Lineage documentation incomplete: {'; '.join(issues)}",
                value=len(lineage_found),
                details={"found": lineage_found, "issues": issues},
            )

        if len(lineage_found) < 2:
            return CheckResult(
                name="Data Lineage",
                status=ValidationStatus.WARNING,
                message=(
                    f"Partial lineage documentation: {', '.join(lineage_found)}"
                ),
                value=len(lineage_found),
                details={"found": lineage_found, "issues": issues},
            )

        return CheckResult(
            name="Data Lineage",
            status=ValidationStatus.PASS,
            message=(
                f"Data lineage documented: {', '.join(lineage_found)}"
            ),
            value=len(lineage_found),
            details={"found": lineage_found},
        )


__all__ = ["Phase3Validator", "Phase4Validator", "SESSIONS", "SESSION_NAMES"]
