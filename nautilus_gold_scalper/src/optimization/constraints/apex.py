"""
Apex compliance constraint checker.

Validates that backtest results meet Apex prop firm requirements:
- Trailing DD < 5% (we use 4.5% as buffer)
- Daily profit < 30% (we use 29% as buffer)
- No overnight positions
- No time gate violations
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from src.optimization.search.base import TrialResult


@dataclass(frozen=True, slots=True)
class ApexViolation:
    """Single Apex compliance violation."""

    rule: str
    threshold: float
    actual: float
    message: str


@dataclass(frozen=True, slots=True)
class ApexComplianceResult:
    """Result of Apex compliance check."""

    compliant: bool
    violations: list[ApexViolation]
    score_penalty: float  # Multiplicative penalty [0, 1]

    def get_violation_summary(self) -> str:
        """Get human-readable violation summary."""
        if self.compliant:
            return "APEX COMPLIANT"
        return "; ".join(v.message for v in self.violations)


class ApexConstraintChecker:
    """
    Checker for Apex prop firm compliance.

    Validates:
    - Trailing DD from HWM < 5% (buffer: 4.5%)
    - Daily profit < 30% (buffer: 29%)
    - No overnight positions
    - No time gate violations

    Reference: CLAUDE.md apex_non_negotiables section
    """

    def __init__(
        self,
        trailing_dd_max: float = 4.5,
        daily_profit_max: float = 29.0,
        overnight_positions_max: int = 0,
        time_gate_violations_max: int = 0,
    ) -> None:
        """
        Initialize Apex constraint checker.

        Args:
            trailing_dd_max: Maximum allowed trailing DD % (default 4.5, Apex limit is 5.0)
            daily_profit_max: Maximum daily profit % (default 29, Apex limit is 30)
            overnight_positions_max: Maximum overnight positions (must be 0)
            time_gate_violations_max: Maximum time gate violations (must be 0)
        """
        self.trailing_dd_max = trailing_dd_max
        self.daily_profit_max = daily_profit_max
        self.overnight_positions_max = overnight_positions_max
        self.time_gate_violations_max = time_gate_violations_max

    def check(self, result: "TrialResult") -> ApexComplianceResult:
        """
        Check if trial result is Apex-compliant.

        Args:
            result: Trial result with metrics

        Returns:
            ApexComplianceResult with violations list
        """
        violations: list[ApexViolation] = []

        # Trailing DD check
        # Formula: trailing_dd_pct = (hwm - current_equity) / hwm * 100
        # Example: hwm=52000, equity=50000 → (52000-50000)/52000*100 = 3.85%
        if result.trailing_dd >= self.trailing_dd_max:
            violations.append(
                ApexViolation(
                    rule="TRAILING_DD",
                    threshold=self.trailing_dd_max,
                    actual=result.trailing_dd,
                    message=f"Trailing DD {result.trailing_dd:.2f}% >= {self.trailing_dd_max}% limit",
                )
            )

        # Daily profit consistency check
        # Apex requires no single day to exceed 30% of total profit
        if result.daily_profit_max >= self.daily_profit_max:
            violations.append(
                ApexViolation(
                    rule="DAILY_PROFIT",
                    threshold=self.daily_profit_max,
                    actual=result.daily_profit_max,
                    message=f"Daily profit {result.daily_profit_max:.1f}% >= {self.daily_profit_max}% limit",
                )
            )

        # Time gate violations (no trades after 4:30 PM ET)
        if result.time_gate_violations > self.time_gate_violations_max:
            violations.append(
                ApexViolation(
                    rule="TIME_GATE",
                    threshold=float(self.time_gate_violations_max),
                    actual=float(result.time_gate_violations),
                    message=f"{result.time_gate_violations} trades after time gate",
                )
            )

        # Overnight positions (must close all by 4:59 PM ET)
        if result.overnight_positions > self.overnight_positions_max:
            violations.append(
                ApexViolation(
                    rule="OVERNIGHT",
                    threshold=float(self.overnight_positions_max),
                    actual=float(result.overnight_positions),
                    message=f"{result.overnight_positions} overnight positions",
                )
            )

        compliant = len(violations) == 0

        # Calculate penalty (used for soft constraints in objective)
        # Hard violations get 0.0 penalty (reject)
        # Near-violations get reduced penalty
        score_penalty = self._calculate_penalty(result, violations)

        return ApexComplianceResult(
            compliant=compliant,
            violations=violations,
            score_penalty=score_penalty,
        )

    def _calculate_penalty(
        self,
        result: "TrialResult",
        violations: list[ApexViolation],
    ) -> float:
        """
        Calculate score penalty based on proximity to limits.

        Returns:
            Penalty factor in [0, 1] where 1.0 = no penalty
        """
        if violations:
            return 0.0  # Hard violation = reject

        penalty = 1.0

        # Soft penalty for trailing DD approaching limit
        # Formula: penalty = 1 - (dd - buffer_start) / (limit - buffer_start)
        # Example: dd=4.0%, buffer_start=3.0%, limit=4.5%
        #          penalty = 1 - (4.0 - 3.0) / (4.5 - 3.0) = 1 - 1.0/1.5 = 0.33
        buffer_start = 3.0  # Start penalizing above 3%
        if result.trailing_dd > buffer_start:
            dd_penalty = 1.0 - (result.trailing_dd - buffer_start) / (
                self.trailing_dd_max - buffer_start
            )
            penalty *= max(0.0, dd_penalty)

        # Soft penalty for daily profit approaching limit
        daily_buffer_start = 20.0  # Start penalizing above 20%
        if result.daily_profit_max > daily_buffer_start:
            daily_penalty = 1.0 - (result.daily_profit_max - daily_buffer_start) / (
                self.daily_profit_max - daily_buffer_start
            )
            penalty *= max(0.0, daily_penalty)

        return penalty

    def get_constraint_values(self, result: "TrialResult") -> list[float]:
        """
        Get constraint violation values for Optuna constraint function.

        Returns list of values where <= 0 means constraint satisfied.

        Returns:
            List of constraint values (negative = satisfied, positive = violated)
        """
        return [
            result.trailing_dd - self.trailing_dd_max,
            result.daily_profit_max - self.daily_profit_max,
            float(result.time_gate_violations - self.time_gate_violations_max),
            float(result.overnight_positions - self.overnight_positions_max),
        ]


def check_apex_compliance(
    trailing_dd: float,
    daily_profit_max: float,
    time_gate_violations: int = 0,
    overnight_positions: int = 0,
    trailing_dd_limit: float = 4.5,
    daily_profit_limit: float = 29.0,
) -> tuple[bool, list[str]]:
    """
    Quick Apex compliance check (utility function).

    Args:
        trailing_dd: Trailing DD percentage from HWM
        daily_profit_max: Maximum daily profit percentage
        time_gate_violations: Number of trades after time gate
        overnight_positions: Number of overnight positions
        trailing_dd_limit: Limit for trailing DD (default 4.5%)
        daily_profit_limit: Limit for daily profit (default 29%)

    Returns:
        Tuple of (is_compliant, list of violation messages)
    """
    violations: list[str] = []

    if trailing_dd >= trailing_dd_limit:
        violations.append(f"TRAILING_DD: {trailing_dd:.2f}% >= {trailing_dd_limit}%")

    if daily_profit_max >= daily_profit_limit:
        violations.append(f"DAILY_PROFIT: {daily_profit_max:.1f}% >= {daily_profit_limit}%")

    if time_gate_violations > 0:
        violations.append(f"TIME_GATE: {time_gate_violations} violations")

    if overnight_positions > 0:
        violations.append(f"OVERNIGHT: {overnight_positions} positions")

    return len(violations) == 0, violations
