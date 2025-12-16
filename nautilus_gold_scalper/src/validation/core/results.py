"""
Validation Results Module for XAUUSD Pipeline.

Provides structured data types for validation outcomes:
- ValidationStatus: Enum for check outcomes (PASS, FAIL, WARNING, SKIPPED, CRITICAL)
- CheckResult: Individual validation check result
- PhaseResult: Aggregated results for a validation phase
- PipelineResult: Complete pipeline validation results with GO/NO-GO decision
- ValidationResult: Alias for backward compatibility

Supports JSON serialization and Markdown report generation.
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any


class ValidationStatus(Enum):
    """Status of a validation check or phase.

    Ordered by severity (CRITICAL > FAIL > WARNING > SKIPPED > PASS).
    """

    PASS = "PASS"
    FAIL = "FAIL"
    WARNING = "WARNING"
    SKIPPED = "SKIPPED"
    CRITICAL = "CRITICAL"

    def __lt__(self, other: object) -> bool:
        """Compare status by severity for aggregation."""
        if not isinstance(other, ValidationStatus):
            return NotImplemented
        severity = {
            ValidationStatus.PASS: 0,
            ValidationStatus.SKIPPED: 1,
            ValidationStatus.WARNING: 2,
            ValidationStatus.FAIL: 3,
            ValidationStatus.CRITICAL: 4,
        }
        return severity[self] < severity[other]

    def __le__(self, other: object) -> bool:
        """Compare status by severity for aggregation."""
        if not isinstance(other, ValidationStatus):
            return NotImplemented
        return self < other or self == other


@dataclass
class CheckResult:
    """Result of a single validation check.

    Attributes:
        name: Human-readable check name (e.g., "Schema Validation")
        status: Pass/Fail/Warning/Skipped/Critical outcome
        message: Descriptive message explaining the result
        value: Actual value observed (for threshold checks)
        threshold: Expected threshold value (for threshold checks)
        details: Additional structured details (key-value pairs)
        duration_ms: Time taken to run this check in milliseconds

    Example:
        >>> check = CheckResult(
        ...     name="Gap Detection",
        ...     status=ValidationStatus.PASS,
        ...     message="No gaps exceeding 5 minutes found",
        ...     value=180,
        ...     threshold=300,
        ...     duration_ms=45.2
        ... )
        >>> check.passed
        True
    """

    name: str
    status: ValidationStatus
    message: str
    value: float | int | str | None = None
    threshold: float | int | str | None = None
    details: dict[str, Any] | None = None
    duration_ms: float = 0.0

    @property
    def passed(self) -> bool:
        """Return True if check passed (PASS or WARNING status)."""
        return self.status in (ValidationStatus.PASS, ValidationStatus.WARNING)

    @property
    def failed(self) -> bool:
        """Return True if check failed (FAIL or CRITICAL status)."""
        return self.status in (ValidationStatus.FAIL, ValidationStatus.CRITICAL)

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        result: dict[str, Any] = {
            "name": self.name,
            "status": self.status.value,
            "message": self.message,
            "duration_ms": self.duration_ms,
        }
        if self.value is not None:
            result["value"] = self.value
        if self.threshold is not None:
            result["threshold"] = self.threshold
        if self.details is not None:
            result["details"] = self.details
        return result

    def to_markdown_row(self) -> str:
        """Generate a markdown table row for this check."""
        status_icon = {
            ValidationStatus.PASS: "PASS",
            ValidationStatus.FAIL: "FAIL",
            ValidationStatus.WARNING: "WARN",
            ValidationStatus.SKIPPED: "SKIP",
            ValidationStatus.CRITICAL: "CRIT",
        }
        icon = status_icon.get(self.status, "?")
        value_str = str(self.value) if self.value is not None else "-"
        threshold_str = str(self.threshold) if self.threshold is not None else "-"
        return f"| {self.name} | {icon} | {value_str} | {threshold_str} | {self.message} |"


@dataclass
class PhaseResult:
    """Aggregated result of a validation phase.

    A phase groups multiple related checks (e.g., "Schema Validation Phase").

    Attributes:
        phase_id: Unique identifier (e.g., "phase_1a")
        phase_name: Human-readable name (e.g., "Deep Data Validation")
        status: Overall phase status (worst of all checks)
        checks: List of individual check results
        start_time: When phase execution started
        end_time: When phase execution completed
        memory_peak_mb: Peak memory usage during phase execution

    Example:
        >>> phase = PhaseResult(
        ...     phase_id="phase_2",
        ...     phase_name="Catalog Validation",
        ...     status=ValidationStatus.PASS
        ... )
        >>> phase.add_check(CheckResult("Schema", ValidationStatus.PASS, "OK"))
        >>> phase.passed_checks
        1
    """

    phase_id: str
    phase_name: str
    status: ValidationStatus
    checks: list[CheckResult] = field(default_factory=list)
    start_time: datetime | None = None
    end_time: datetime | None = None
    memory_peak_mb: float = 0.0

    @property
    def duration_seconds(self) -> float:
        """Calculate phase duration in seconds."""
        if self.start_time is None or self.end_time is None:
            return 0.0
        delta = self.end_time - self.start_time
        return delta.total_seconds()

    @property
    def passed_checks(self) -> int:
        """Count of checks that passed."""
        return sum(1 for c in self.checks if c.passed)

    @property
    def failed_checks(self) -> int:
        """Count of checks that failed."""
        return sum(1 for c in self.checks if c.failed)

    @property
    def warning_checks(self) -> int:
        """Count of checks with warnings."""
        return sum(1 for c in self.checks if c.status == ValidationStatus.WARNING)

    @property
    def skipped_checks(self) -> int:
        """Count of skipped checks."""
        return sum(1 for c in self.checks if c.status == ValidationStatus.SKIPPED)

    @property
    def critical_checks(self) -> int:
        """Count of critical failures."""
        return sum(1 for c in self.checks if c.status == ValidationStatus.CRITICAL)

    def add_check(self, check: CheckResult) -> None:
        """Add a check result and update phase status.

        Phase status is automatically updated to the worst status among all checks.
        """
        self.checks.append(check)
        # Update phase status to worst status
        if check.status > self.status:
            self.status = check.status

    def compute_status(self) -> ValidationStatus:
        """Recompute phase status from all checks.

        Returns:
            Worst status among all checks, or SKIPPED if no checks exist.
        """
        if not self.checks:
            return ValidationStatus.SKIPPED
        return max(c.status for c in self.checks)

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "phase_id": self.phase_id,
            "phase_name": self.phase_name,
            "status": self.status.value,
            "checks": [c.to_dict() for c in self.checks],
            "start_time": (
                self.start_time.isoformat() if self.start_time is not None else None
            ),
            "end_time": (
                self.end_time.isoformat() if self.end_time is not None else None
            ),
            "duration_seconds": self.duration_seconds,
            "memory_peak_mb": self.memory_peak_mb,
            "summary": {
                "total": len(self.checks),
                "passed": self.passed_checks,
                "failed": self.failed_checks,
                "warning": self.warning_checks,
                "skipped": self.skipped_checks,
                "critical": self.critical_checks,
            },
        }

    def to_json(self) -> str:
        """Serialize phase result to JSON string."""
        return json.dumps(self.to_dict(), indent=2)

    def to_markdown(self) -> str:
        """Generate markdown report for this phase."""
        lines: list[str] = []
        lines.append(f"## {self.phase_name} ({self.phase_id})")
        lines.append("")
        lines.append(f"**Status:** {self.status.value}")
        lines.append(
            f"**Duration:** {self.duration_seconds:.2f}s | "
            f"**Memory Peak:** {self.memory_peak_mb:.1f} MB"
        )
        lines.append("")
        lines.append(
            f"**Summary:** {self.passed_checks} passed, {self.failed_checks} failed, "
            f"{self.warning_checks} warnings, {self.skipped_checks} skipped"
        )
        lines.append("")

        if self.checks:
            lines.append("| Check | Status | Value | Threshold | Message |")
            lines.append("|-------|--------|-------|-----------|---------|")
            for check in self.checks:
                lines.append(check.to_markdown_row())
            lines.append("")

        return "\n".join(lines)


@dataclass
class PipelineResult:
    """Complete validation pipeline results.

    Aggregates all phase results and provides GO/NO-GO decision.

    Attributes:
        phases: List of phase results
        config_hash: Hash of validation configuration (for reproducibility)
        data_hash: Hash of input data (for reproducibility)
        pipeline_start: When pipeline execution started
        pipeline_end: When pipeline execution completed

    Example:
        >>> pipeline = PipelineResult()
        >>> pipeline.add_phase(phase1)
        >>> pipeline.add_phase(phase2)
        >>> print(pipeline.go_nogo_decision)  # "GO", "GO-CONDITIONAL", or "NO-GO"
    """

    phases: list[PhaseResult] = field(default_factory=list)
    config_hash: str = ""
    data_hash: str = ""
    pipeline_start: datetime | None = None
    pipeline_end: datetime | None = None

    @property
    def overall_status(self) -> ValidationStatus:
        """Compute overall pipeline status (worst of all phases).

        Returns:
            Worst status among all phases, or SKIPPED if no phases exist.
        """
        if not self.phases:
            return ValidationStatus.SKIPPED
        return max(p.status for p in self.phases)

    @property
    def go_nogo_decision(self) -> str:
        """Determine GO/NO-GO decision based on overall status.

        Returns:
            - "GO": All phases passed (PASS status)
            - "GO-CONDITIONAL": Some warnings but no failures
            - "NO-GO": Any failures or critical issues
        """
        status = self.overall_status
        if status == ValidationStatus.PASS:
            return "GO"
        if status == ValidationStatus.WARNING:
            return "GO-CONDITIONAL"
        if status == ValidationStatus.SKIPPED:
            return "INCOMPLETE"
        return "NO-GO"

    @property
    def total_duration_seconds(self) -> float:
        """Calculate total pipeline duration in seconds."""
        if self.pipeline_start is None or self.pipeline_end is None:
            # Fall back to sum of phase durations
            return sum(p.duration_seconds for p in self.phases)
        delta = self.pipeline_end - self.pipeline_start
        return delta.total_seconds()

    @property
    def total_checks(self) -> int:
        """Total number of checks across all phases."""
        return sum(len(p.checks) for p in self.phases)

    @property
    def total_passed(self) -> int:
        """Total passed checks across all phases."""
        return sum(p.passed_checks for p in self.phases)

    @property
    def total_failed(self) -> int:
        """Total failed checks across all phases."""
        return sum(p.failed_checks for p in self.phases)

    @property
    def total_warnings(self) -> int:
        """Total warning checks across all phases."""
        return sum(p.warning_checks for p in self.phases)

    @property
    def total_critical(self) -> int:
        """Total critical failures across all phases."""
        return sum(p.critical_checks for p in self.phases)

    def add_phase(self, phase: PhaseResult) -> None:
        """Add a completed phase result to the pipeline."""
        self.phases.append(phase)

    def get_phase(self, phase_id: str) -> PhaseResult | None:
        """Get a phase by its ID.

        Args:
            phase_id: The phase identifier to look up

        Returns:
            PhaseResult if found, None otherwise
        """
        for phase in self.phases:
            if phase.phase_id == phase_id:
                return phase
        return None

    def summary(self) -> dict[str, Any]:
        """Generate summary dictionary for quick inspection.

        Returns:
            Dictionary with key metrics and decision.
        """
        return {
            "decision": self.go_nogo_decision,
            "overall_status": self.overall_status.value,
            "phases_total": len(self.phases),
            "phases_passed": sum(
                1 for p in self.phases if p.status == ValidationStatus.PASS
            ),
            "phases_failed": sum(
                1 for p in self.phases if p.status in (
                    ValidationStatus.FAIL, ValidationStatus.CRITICAL
                )
            ),
            "checks_total": self.total_checks,
            "checks_passed": self.total_passed,
            "checks_failed": self.total_failed,
            "checks_warning": self.total_warnings,
            "checks_critical": self.total_critical,
            "duration_seconds": self.total_duration_seconds,
            "config_hash": self.config_hash,
            "data_hash": self.data_hash,
        }

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "summary": self.summary(),
            "pipeline_start": (
                self.pipeline_start.isoformat()
                if self.pipeline_start is not None
                else None
            ),
            "pipeline_end": (
                self.pipeline_end.isoformat()
                if self.pipeline_end is not None
                else None
            ),
            "phases": [p.to_dict() for p in self.phases],
        }

    def to_json(self) -> str:
        """Serialize pipeline result to JSON string."""
        return json.dumps(self.to_dict(), indent=2)

    def save_json(self, path: Path) -> None:
        """Save pipeline results to JSON file.

        Args:
            path: Destination file path

        Raises:
            OSError: If file cannot be written
        """
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(self.to_json(), encoding="utf-8")

    def to_markdown(self) -> str:
        """Generate complete markdown report.

        Returns:
            Full markdown document with executive summary and all phases.
        """
        lines: list[str] = []

        # Header
        lines.append("# Validation Pipeline Report")
        lines.append("")
        timestamp = (
            self.pipeline_end.strftime("%Y-%m-%d %H:%M:%S")
            if self.pipeline_end is not None
            else "N/A"
        )
        lines.append(f"**Generated:** {timestamp}")
        lines.append("")

        # Executive Summary
        lines.append("## Executive Summary")
        lines.append("")
        decision = self.go_nogo_decision
        decision_emoji = {
            "GO": "[PASS]",
            "GO-CONDITIONAL": "[WARN]",
            "NO-GO": "[FAIL]",
            "INCOMPLETE": "[SKIP]",
        }
        lines.append(f"**Decision:** {decision_emoji.get(decision, '')} {decision}")
        lines.append(f"**Overall Status:** {self.overall_status.value}")
        lines.append(f"**Total Duration:** {self.total_duration_seconds:.2f} seconds")
        lines.append("")

        # Summary table
        lines.append("### Check Summary")
        lines.append("")
        lines.append("| Metric | Count |")
        lines.append("|--------|-------|")
        lines.append(f"| Total Checks | {self.total_checks} |")
        lines.append(f"| Passed | {self.total_passed} |")
        lines.append(f"| Failed | {self.total_failed} |")
        lines.append(f"| Warnings | {self.total_warnings} |")
        lines.append(f"| Critical | {self.total_critical} |")
        lines.append("")

        # Phase summary table
        if self.phases:
            lines.append("### Phase Summary")
            lines.append("")
            lines.append("| Phase | Status | Duration | Passed | Failed |")
            lines.append("|-------|--------|----------|--------|--------|")
            for phase in self.phases:
                lines.append(
                    f"| {phase.phase_name} | {phase.status.value} | "
                    f"{phase.duration_seconds:.2f}s | {phase.passed_checks} | "
                    f"{phase.failed_checks} |"
                )
            lines.append("")

        # Hashes for reproducibility
        if self.config_hash or self.data_hash:
            lines.append("### Reproducibility")
            lines.append("")
            if self.config_hash:
                lines.append(f"- **Config Hash:** `{self.config_hash}`")
            if self.data_hash:
                lines.append(f"- **Data Hash:** `{self.data_hash}`")
            lines.append("")

        # Detailed phase reports
        lines.append("---")
        lines.append("")
        lines.append("# Detailed Phase Reports")
        lines.append("")
        for phase in self.phases:
            lines.append(phase.to_markdown())

        return "\n".join(lines)

    def save_markdown(self, path: Path) -> None:
        """Save pipeline results to Markdown file.

        Args:
            path: Destination file path

        Raises:
            OSError: If file cannot be written
        """
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(self.to_markdown(), encoding="utf-8")


# Backward compatibility alias
# The __init__.py imports ValidationResult, so we provide it
ValidationResult = PipelineResult


def load_pipeline_result(path: Path) -> PipelineResult:
    """Load a PipelineResult from a JSON file.

    Args:
        path: Path to JSON file

    Returns:
        Reconstructed PipelineResult

    Raises:
        FileNotFoundError: If file does not exist
        json.JSONDecodeError: If file is not valid JSON
        KeyError: If required fields are missing
    """
    data = json.loads(path.read_text(encoding="utf-8"))

    result = PipelineResult(
        config_hash=data.get("summary", {}).get("config_hash", ""),
        data_hash=data.get("summary", {}).get("data_hash", ""),
    )

    # Parse timestamps
    if data.get("pipeline_start"):
        result.pipeline_start = datetime.fromisoformat(data["pipeline_start"])
    if data.get("pipeline_end"):
        result.pipeline_end = datetime.fromisoformat(data["pipeline_end"])

    # Parse phases
    for phase_data in data.get("phases", []):
        phase = PhaseResult(
            phase_id=phase_data["phase_id"],
            phase_name=phase_data["phase_name"],
            status=ValidationStatus(phase_data["status"]),
            memory_peak_mb=phase_data.get("memory_peak_mb", 0.0),
        )

        # Parse timestamps
        if phase_data.get("start_time"):
            phase.start_time = datetime.fromisoformat(phase_data["start_time"])
        if phase_data.get("end_time"):
            phase.end_time = datetime.fromisoformat(phase_data["end_time"])

        # Parse checks
        for check_data in phase_data.get("checks", []):
            check = CheckResult(
                name=check_data["name"],
                status=ValidationStatus(check_data["status"]),
                message=check_data["message"],
                value=check_data.get("value"),
                threshold=check_data.get("threshold"),
                details=check_data.get("details"),
                duration_ms=check_data.get("duration_ms", 0.0),
            )
            phase.checks.append(check)

        result.add_phase(phase)

    return result
