"""
Drawdown Tracker for Nautilus Gold Scalper.

Tracks daily and total drawdowns, streaks, and recovery metrics
for prop-firm style risk controls and analytics.
"""
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from enum import IntEnum

from ..core.definitions import (
    DEFAULT_MAX_DAILY_LOSS,
    DEFAULT_MAX_TOTAL_LOSS,
)


class DrawdownSeverity(IntEnum):
    """Severity buckets for current drawdown."""
    NONE = 0
    MINOR = 1       # < 2%
    MODERATE = 2    # 2-5%
    SIGNIFICANT = 3 # 5-8%
    SEVERE = 4      # 8-10%
    CRITICAL = 5    # >10%


@dataclass
class DrawdownSnapshot:
    """Snapshot of drawdown state at a point in time."""
    timestamp: datetime
    equity: float
    peak_equity: float
    daily_dd: float
    daily_dd_pct: float
    total_dd: float
    total_dd_pct: float
    high_water_mark: float
    daily_start: float
    is_in_drawdown: bool
    severity: DrawdownSeverity


@dataclass
class DrawdownAnalysis:
    """Aggregated analysis returned by update()."""
    is_in_drawdown: bool
    current_drawdown_abs: float
    current_drawdown_pct: float
    max_drawdown_abs: float
    max_drawdown_pct: float
    peak_equity: float
    drawdown_events_count: int
    current_winning_streak: int
    current_losing_streak: int
    max_winning_streak: int
    max_losing_streak: int
    severity: DrawdownSeverity
    recovery_factor: float


class DrawdownTracker:
    """
    Drawdown tracker with severity buckets, streak tracking, and recovery stats.
    API aligned with tests in tests/test_risk/test_drawdown_tracker.py
    """

    def __init__(
        self,
        initial_equity: float = 100_000.0,
        max_daily: float = DEFAULT_MAX_DAILY_LOSS,
        max_total: float = DEFAULT_MAX_TOTAL_LOSS,
        alert_thresholds: list[float] | None = None,
    ):
        if initial_equity <= 0:
            raise ValueError(f"Invalid initial_equity: {initial_equity}")
        if not (0 < max_daily <= 1.0):
            raise ValueError(f"Invalid max_daily: {max_daily}")
        if not (0 < max_total <= 1.0):
            raise ValueError(f"Invalid max_total: {max_total}")

        self._max_daily = max_daily
        self._max_total = max_total
        self._alert_thresholds = alert_thresholds or [0.5, 0.75, 0.9]

        self._current_equity = initial_equity
        self._daily_start_equity = initial_equity
        self._high_water_mark = initial_equity
        self._peak_equity = initial_equity

        self._daily_drawdown = 0.0
        self._daily_drawdown_pct = 0.0
        self._total_drawdown = 0.0
        self._total_drawdown_pct = 0.0

        # Streak tracking
        self._current_wins = 0
        self._current_losses = 0
        self._max_wins = 0
        self._max_losses = 0

        # Drawdown tracking
        self._is_in_drawdown = False
        self._max_drawdown_abs = 0.0
        self._max_drawdown_pct = 0.0
        self._drawdown_events = 0
        self._last_was_drawdown = False
        self._peak_at_max_dd = initial_equity

        # History
        self._history: list[DrawdownSnapshot] = []
        self._max_history_size = 10000
        self._alerts_triggered: list[tuple[datetime, str]] = []

        self._last_update = datetime.now(timezone.utc)
        self._last_day_check = self._last_update

    # ------------------------------------------------------------------ API
    def update(self, current_equity: float, pnl: float | None = None, now: datetime | None = None) -> DrawdownAnalysis:
        """Update tracker with current equity and optional trade PnL."""
        if current_equity <= 0:
            return self.get_analysis()

        self._check_new_day(now)

        # Streak handling
        if pnl is not None:
            if pnl > 0:
                self._current_wins += 1
                self._current_losses = 0
            elif pnl < 0:
                self._current_losses += 1
                self._current_wins = 0
            # zero pnl leaves streaks unchanged
            self._max_wins = max(self._max_wins, self._current_wins)
            self._max_losses = max(self._max_losses, self._current_losses)

        self._current_equity = current_equity
        # Always prefer explicit timestamp for backtest accuracy
        # Use datetime.now() only as fallback for live trading
        if now is None:
            now = datetime.now(timezone.utc)
        self._last_update = now

        # Peak/high-water updates
        if current_equity > self._peak_equity:
            self._peak_equity = current_equity
        if current_equity > self._high_water_mark:
            self._high_water_mark = current_equity

        # Daily drawdown
        self._daily_drawdown = max(0.0, self._daily_start_equity - current_equity)
        if self._daily_start_equity > 0:
            self._daily_drawdown_pct = (self._daily_drawdown / self._daily_start_equity) * 100.0

        # Total drawdown from high water
        self._total_drawdown = max(0.0, self._high_water_mark - current_equity)
        if self._high_water_mark > 0:
            self._total_drawdown_pct = (self._total_drawdown / self._high_water_mark) * 100.0

        # Drawdown state machine
        self._is_in_drawdown = current_equity < self._peak_equity
        if self._is_in_drawdown:
            current_dd_abs = self._peak_equity - current_equity
            current_dd_pct = (current_dd_abs / self._peak_equity) * 100.0 if self._peak_equity else 0.0
            if current_dd_pct > self._max_drawdown_pct:
                self._max_drawdown_pct = current_dd_pct
                self._max_drawdown_abs = current_dd_abs
                self._peak_at_max_dd = self._peak_equity
            if not self._last_was_drawdown:
                self._drawdown_events += 1
            self._last_was_drawdown = True
        else:
            self._last_was_drawdown = False
            # If new equity exceeds peak, we consider recovery complete
            self._peak_equity = current_equity

        severity = self._classify_severity(self._current_drawdown_pct())
        analysis = DrawdownAnalysis(
            is_in_drawdown=self._is_in_drawdown,
            current_drawdown_abs=self._current_drawdown_abs(),
            current_drawdown_pct=self._current_drawdown_pct(),
            max_drawdown_abs=self._max_drawdown_abs,
            max_drawdown_pct=self._max_drawdown_pct,
            peak_equity=self._peak_equity,
            drawdown_events_count=self._drawdown_events,
            current_winning_streak=self._current_wins,
            current_losing_streak=self._current_losses,
            max_winning_streak=self._max_wins,
            max_losing_streak=self._max_losses,
            severity=severity,
            recovery_factor=self._recovery_factor(),
        )

        self._save_snapshot(severity)
        self._check_alerts()
        return analysis

    def reset_daily(self) -> None:
        """Reset daily counters (use on new trading day)."""
        self._daily_start_equity = self._current_equity
        self._daily_drawdown = 0.0
        self._daily_drawdown_pct = 0.0
        # Use last_update timestamp instead of wall-clock for backtest accuracy
        self._last_day_check = self._last_update

    def should_reduce_size(self, threshold_streak: int = 3) -> bool:
        """Return True when losing streak exceeds threshold."""
        return self._current_losses >= threshold_streak

    def get_size_reduction_factor(self) -> float:
        """Return suggested multiplier based on losing streak."""
        if self._current_losses >= 4:
            return 0.40
        if self._current_losses >= 3:
            return 0.55
        if self._current_losses >= 2:
            return 0.85
        return 1.0

    def get_underwater_stats(self) -> dict[str, float]:
        """Return stats about drawdown periods."""
        events = []
        depths = []
        durations = []
        in_dd = False
        start_time: datetime | None = None
        local_peak = 0.0

        for snap in self._history:
            if snap.is_in_drawdown:
                if not in_dd:
                    in_dd = True
                    start_time = snap.timestamp
                    local_peak = snap.peak_equity
                depth = (local_peak - snap.equity) / local_peak * 100 if local_peak else 0.0
                depths.append(depth)
            else:
                if in_dd and start_time:
                    duration = (snap.timestamp - start_time).total_seconds() / 60.0
                    durations.append(duration)
                    events.append(1)
                in_dd = False

        total_events = len(durations)
        avg_duration = sum(durations) / total_events if total_events else 0.0
        avg_depth = sum(depths) / len(depths) if depths else 0.0
        return {
            "total_events": total_events,
            "avg_duration_bars": avg_duration,
            "avg_depth_pct": avg_depth,
        }

    def get_equity_curve(self) -> list[float]:
        """Return equity history as simple list of equity values."""
        return [h.equity for h in self._history]

    def get_history(self, last_n: int | None = None) -> list[DrawdownSnapshot]:
        if last_n is None:
            return self._history.copy()
        return self._history[-last_n:].copy()

    def get_analysis(self) -> DrawdownAnalysis:
        """Return latest analysis without updating."""
        severity = self._classify_severity(self._current_drawdown_pct())
        return DrawdownAnalysis(
            is_in_drawdown=self._is_in_drawdown,
            current_drawdown_abs=self._current_drawdown_abs(),
            current_drawdown_pct=self._current_drawdown_pct(),
            max_drawdown_abs=self._max_drawdown_abs,
            max_drawdown_pct=self._max_drawdown_pct,
            peak_equity=self._peak_equity,
            drawdown_events_count=self._drawdown_events,
            current_winning_streak=self._current_wins,
            current_losing_streak=self._current_losses,
            max_winning_streak=self._max_wins,
            max_losing_streak=self._max_losses,
            severity=severity,
            recovery_factor=self._recovery_factor(),
        )

    def get_daily_drawdown_pct(self) -> float:
        """Return current daily drawdown percentage (vs start of day)."""
        return self._daily_drawdown_pct

    def get_total_drawdown_pct(self) -> float:
        """Return current peak-to-valley drawdown percentage."""
        return self._total_drawdown_pct

    # ----------------------------------------------------------------- helpers
    def _current_drawdown_abs(self) -> float:
        if self._is_in_drawdown:
            return self._peak_equity - self._current_equity
        return 0.0

    def _current_drawdown_pct(self) -> float:
        dd_abs = self._current_drawdown_abs()
        return (dd_abs / self._peak_equity) * 100.0 if self._peak_equity else 0.0

    def _classify_severity(self, dd_pct: float) -> DrawdownSeverity:
        if dd_pct <= 0.0:
            return DrawdownSeverity.NONE
        if dd_pct < 2.0:
            return DrawdownSeverity.MINOR
        if dd_pct < 5.0:
            return DrawdownSeverity.MODERATE
        if dd_pct < 8.0:
            return DrawdownSeverity.SIGNIFICANT
        if dd_pct < 10.0:
            return DrawdownSeverity.SEVERE
        return DrawdownSeverity.CRITICAL

    def _recovery_factor(self) -> float:
        """Profit recovered vs max historical drawdown."""
        if self._max_drawdown_abs <= 0:
            return 0.0
        return max(0.0, (self._current_equity - (self._peak_at_max_dd - self._max_drawdown_abs)) / self._max_drawdown_abs)

    def _check_new_day(self, now: datetime | None = None) -> None:
        """Check if new trading day and reset if needed. Uses backtest timestamp if provided."""
        if now is None:
            now = datetime.now(timezone.utc)
        if now.date() != self._last_day_check.date():
            self.reset_daily()
        # Update check timestamp to provided time for backtest accuracy
        self._last_day_check = now

    def _check_alerts(self) -> None:
        daily_pct = self._daily_drawdown_pct / (self._max_daily * 100) * 100 if self._max_daily else 0
        total_pct = self._total_drawdown_pct / (self._max_total * 100) * 100 if self._max_total else 0
        max_pct = max(daily_pct, total_pct)
        for thr in self._alert_thresholds:
            thr_pct = thr * 100
            if max_pct >= thr_pct:
                msg = f"Drawdown alert {thr_pct:.0f}% | daily {self._daily_drawdown_pct:.2f}% total {self._total_drawdown_pct:.2f}%"
                # Use last_update timestamp instead of wall-clock for backtest accuracy
                self._alerts_triggered.append((self._last_update, msg))

    def _save_snapshot(self, severity: DrawdownSeverity) -> None:
        snap = DrawdownSnapshot(
            # Use last_update timestamp instead of wall-clock for backtest accuracy
            timestamp=self._last_update,
            equity=self._current_equity,
            peak_equity=self._peak_equity,
            daily_dd=self._daily_drawdown,
            daily_dd_pct=self._daily_drawdown_pct,
            total_dd=self._total_drawdown,
            total_dd_pct=self._total_drawdown_pct,
            high_water_mark=self._high_water_mark,
            daily_start=self._daily_start_equity,
            is_in_drawdown=self._is_in_drawdown,
            severity=severity,
        )
        self._history.append(snap)
        if len(self._history) > self._max_history_size:
            self._history = self._history[-self._max_history_size:]
