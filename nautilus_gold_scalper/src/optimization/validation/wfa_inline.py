"""
Inline Walk-Forward Analysis for optimization pipeline.

Runs a simplified WFA during the search phase to validate robustness
without the full overhead of post-hoc validation. Enables early pruning
of configs that show poor out-of-sample performance.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import TYPE_CHECKING, Any

import numpy as np
import pandas as pd

if TYPE_CHECKING:
    pass


@dataclass(frozen=True, slots=True)
class WFAWindow:
    """Single walk-forward analysis window."""

    window_id: int
    is_start: datetime
    is_end: datetime
    oos_start: datetime
    oos_end: datetime
    is_trades: int
    oos_trades: int
    is_pnl: float
    oos_pnl: float
    is_sqn: float
    oos_sqn: float
    wfe: float  # OOS/IS performance ratio


@dataclass(frozen=True, slots=True)
class WFAResult:
    """Result of inline walk-forward analysis."""

    windows: list[WFAWindow]
    wfe: float  # Mean WFE across windows
    wfe_std: float  # Std of WFE (stability indicator)
    total_trades: int
    total_pnl: float
    sqn: float
    sharpe: float
    sortino: float
    profit_factor: float
    win_rate: float
    max_drawdown_pct: float

    # Apex-relevant metrics
    trailing_dd: float
    daily_profit_max: float
    positive_days_ratio: float
    time_gate_violations: int
    overnight_positions: int

    # Regime scores (if computed)
    regime_scores: dict[str, float]

    def is_valid(self, min_wfe: float = 0.5, min_trades: int = 50) -> bool:
        """Check if WFA result meets minimum thresholds."""
        return self.wfe >= min_wfe and self.total_trades >= min_trades


class InlineWFA:
    """
    Inline Walk-Forward Analysis during optimization.

    Uses rolling windows to validate out-of-sample performance:
    1. Split data into N windows
    2. For each window: train on IS period, validate on OOS period
    3. Compute WFE = mean(OOS_perf) / mean(IS_perf)

    Key difference from full WFA: uses a single backtest per config
    with internal windowing, rather than N separate backtests.
    """

    def __init__(
        self,
        windows: int = 5,
        is_ratio: float = 0.8,
        purge_days: int = 5,
        embargo_days: int = 2,
    ) -> None:
        """
        Initialize inline WFA.

        Args:
            windows: Number of rolling windows
            is_ratio: In-sample ratio per window (0.8 = 80% IS, 20% OOS)
            purge_days: Gap between IS and OOS to prevent leakage
            embargo_days: Gap at end of OOS for additional safety
        """
        self.windows = windows
        self.is_ratio = is_ratio
        self.purge_days = purge_days
        self.embargo_days = embargo_days

    def compute_window_splits(
        self,
        start_date: str,
        end_date: str,
    ) -> list[tuple[datetime, datetime, datetime, datetime]]:
        """
        Compute IS/OOS date splits for each window.

        Returns:
            List of (is_start, is_end, oos_start, oos_end) tuples
        """
        start = pd.Timestamp(start_date)
        end = pd.Timestamp(end_date)
        total_days = (end - start).days

        # Each window covers total_days / windows
        window_days = total_days // self.windows

        splits: list[tuple[datetime, datetime, datetime, datetime]] = []

        for i in range(self.windows):
            window_start = start + timedelta(days=i * window_days)
            window_end = window_start + timedelta(days=window_days)

            # IS period
            is_days = int(window_days * self.is_ratio)
            is_start = window_start
            is_end = window_start + timedelta(days=is_days)

            # Purge gap
            oos_start = is_end + timedelta(days=self.purge_days)

            # OOS period (remaining minus embargo)
            oos_end = window_end - timedelta(days=self.embargo_days)

            if oos_end > oos_start:
                splits.append(
                    (
                        is_start.to_pydatetime(),
                        is_end.to_pydatetime(),
                        oos_start.to_pydatetime(),
                        oos_end.to_pydatetime(),
                    )
                )

        return splits

    def analyze_trade_series(
        self,
        trades_df: pd.DataFrame,
        splits: list[tuple[datetime, datetime, datetime, datetime]],
    ) -> list[WFAWindow]:
        """
        Analyze trade series across WFA windows.

        Args:
            trades_df: DataFrame with columns [timestamp, pnl, ...]
            splits: List of (is_start, is_end, oos_start, oos_end) tuples

        Returns:
            List of WFAWindow results
        """
        windows: list[WFAWindow] = []

        if trades_df.empty or "timestamp" not in trades_df.columns:
            return windows

        # Ensure timestamp is datetime
        trades_df = trades_df.copy()
        if not pd.api.types.is_datetime64_any_dtype(trades_df["timestamp"]):
            trades_df["timestamp"] = pd.to_datetime(trades_df["timestamp"], utc=True)

        for i, (is_start, is_end, oos_start, oos_end) in enumerate(splits):
            # Filter trades for IS and OOS periods
            is_mask = (trades_df["timestamp"] >= is_start) & (
                trades_df["timestamp"] < is_end
            )
            oos_mask = (trades_df["timestamp"] >= oos_start) & (
                trades_df["timestamp"] < oos_end
            )

            is_trades = trades_df[is_mask]
            oos_trades = trades_df[oos_mask]

            is_count = len(is_trades)
            oos_count = len(oos_trades)

            is_pnl = float(is_trades["pnl"].sum()) if is_count > 0 else 0.0
            oos_pnl = float(oos_trades["pnl"].sum()) if oos_count > 0 else 0.0

            is_sqn = self._compute_sqn(is_trades["pnl"]) if is_count > 0 else 0.0
            oos_sqn = self._compute_sqn(oos_trades["pnl"]) if oos_count > 0 else 0.0

            # WFE = OOS SQN / IS SQN (or OOS PnL / IS PnL if using simple metric)
            # Using SQN ratio as it's more robust
            if is_sqn > 0:
                wfe = oos_sqn / is_sqn
            elif is_pnl > 0:
                wfe = oos_pnl / is_pnl
            else:
                wfe = 0.0

            # Clamp WFE to reasonable range
            wfe = max(0.0, min(2.0, wfe))

            windows.append(
                WFAWindow(
                    window_id=i,
                    is_start=is_start,
                    is_end=is_end,
                    oos_start=oos_start,
                    oos_end=oos_end,
                    is_trades=is_count,
                    oos_trades=oos_count,
                    is_pnl=is_pnl,
                    oos_pnl=oos_pnl,
                    is_sqn=is_sqn,
                    oos_sqn=oos_sqn,
                    wfe=wfe,
                )
            )

        return windows

    def compute_wfa_metrics(
        self,
        windows: list[WFAWindow],
        full_trades_df: pd.DataFrame,
        equity_series: pd.Series | None = None,
    ) -> WFAResult:
        """
        Compute aggregate WFA metrics from windows.

        Args:
            windows: List of WFA window results
            full_trades_df: Complete trades DataFrame
            equity_series: Optional equity curve for DD calculation

        Returns:
            WFAResult with aggregate metrics
        """
        if not windows:
            return self._empty_result()

        # Aggregate WFE
        wfes = [w.wfe for w in windows if w.is_trades > 0 and w.oos_trades > 0]
        wfe = float(np.mean(wfes)) if wfes else 0.0
        wfe_std = float(np.std(wfes)) if len(wfes) > 1 else 0.0

        # Total trades and PnL
        total_trades = len(full_trades_df) if not full_trades_df.empty else 0
        total_pnl = (
            float(full_trades_df["pnl"].sum())
            if not full_trades_df.empty
            else 0.0
        )

        # Performance metrics
        pnl_series = full_trades_df["pnl"] if not full_trades_df.empty else pd.Series([])
        sqn = self._compute_sqn(pnl_series)
        sharpe = self._compute_sharpe(pnl_series)
        sortino = self._compute_sortino(pnl_series)
        profit_factor = self._compute_profit_factor(pnl_series)
        win_rate = self._compute_win_rate(pnl_series)

        # Drawdown
        max_dd = self._compute_max_drawdown(equity_series) if equity_series is not None else 0.0

        # Apex metrics
        trailing_dd = max_dd  # Approximation
        daily_pnl = self._compute_daily_pnl(full_trades_df)
        daily_profit_max = self._compute_daily_profit_max(daily_pnl, total_pnl)
        positive_days_ratio = self._compute_positive_days_ratio(daily_pnl)

        return WFAResult(
            windows=windows,
            wfe=wfe,
            wfe_std=wfe_std,
            total_trades=total_trades,
            total_pnl=total_pnl,
            sqn=sqn,
            sharpe=sharpe,
            sortino=sortino,
            profit_factor=profit_factor,
            win_rate=win_rate,
            max_drawdown_pct=max_dd,
            trailing_dd=trailing_dd,
            daily_profit_max=daily_profit_max,
            positive_days_ratio=positive_days_ratio,
            time_gate_violations=0,  # Computed separately
            overnight_positions=0,  # Computed separately
            regime_scores={},  # Computed in Layer 3 if needed
        )

    def _empty_result(self) -> WFAResult:
        """Return empty WFA result."""
        return WFAResult(
            windows=[],
            wfe=0.0,
            wfe_std=0.0,
            total_trades=0,
            total_pnl=0.0,
            sqn=0.0,
            sharpe=0.0,
            sortino=0.0,
            profit_factor=0.0,
            win_rate=0.0,
            max_drawdown_pct=0.0,
            trailing_dd=0.0,
            daily_profit_max=0.0,
            positive_days_ratio=0.0,
            time_gate_violations=0,
            overnight_positions=0,
            regime_scores={},
        )

    def _compute_sqn(self, pnl_series: pd.Series) -> float:
        """
        Compute System Quality Number.

        Formula: SQN = mean(pnl) / std(pnl) * sqrt(n)
        Example: mean=100, std=200, n=100 → 100/200 * 10 = 5.0
        """
        if len(pnl_series) < 2:
            return 0.0
        mean_pnl = float(pnl_series.mean())
        std_pnl = float(pnl_series.std())
        if std_pnl == 0:
            return 0.0
        sqn = mean_pnl / std_pnl * np.sqrt(len(pnl_series))
        return float(sqn)

    def _compute_sharpe(self, pnl_series: pd.Series, periods_per_year: int = 252) -> float:
        """
        Compute annualized Sharpe ratio.

        Formula: Sharpe = mean(returns) / std(returns) * sqrt(periods_per_year)
        """
        if len(pnl_series) < 2:
            return 0.0
        mean_ret = float(pnl_series.mean())
        std_ret = float(pnl_series.std())
        if std_ret == 0:
            return 0.0
        return float(mean_ret / std_ret * np.sqrt(periods_per_year))

    def _compute_sortino(self, pnl_series: pd.Series, periods_per_year: int = 252) -> float:
        """
        Compute annualized Sortino ratio (downside deviation only).

        Formula: Sortino = mean(returns) / downside_std * sqrt(periods_per_year)
        """
        if len(pnl_series) < 2:
            return 0.0
        mean_ret = float(pnl_series.mean())
        downside = pnl_series[pnl_series < 0]
        if len(downside) == 0:
            return 10.0  # No downside = very good
        downside_std = float(downside.std())
        if downside_std == 0:
            return 10.0
        return float(mean_ret / downside_std * np.sqrt(periods_per_year))

    def _compute_profit_factor(self, pnl_series: pd.Series) -> float:
        """
        Compute profit factor.

        Formula: PF = sum(wins) / abs(sum(losses))
        Example: wins=5000, losses=-2000 → 5000/2000 = 2.5
        """
        wins = pnl_series[pnl_series > 0].sum()
        losses = abs(pnl_series[pnl_series < 0].sum())
        if losses == 0:
            return 10.0 if wins > 0 else 0.0
        return float(wins / losses)

    def _compute_win_rate(self, pnl_series: pd.Series) -> float:
        """
        Compute win rate.

        Formula: win_rate = count(wins) / total_trades
        """
        if len(pnl_series) == 0:
            return 0.0
        wins = (pnl_series > 0).sum()
        return float(wins / len(pnl_series))

    def _compute_max_drawdown(self, equity_series: pd.Series) -> float:
        """
        Compute maximum drawdown percentage.

        Formula: DD% = (peak - trough) / peak * 100
        """
        if equity_series is None or len(equity_series) < 2:
            return 0.0
        running_max = equity_series.cummax()
        drawdown = (running_max - equity_series) / running_max * 100
        return float(drawdown.max())

    def _compute_daily_pnl(self, trades_df: pd.DataFrame) -> pd.Series:
        """Aggregate PnL by day."""
        if trades_df.empty or "timestamp" not in trades_df.columns:
            return pd.Series([], dtype=float)

        df = trades_df.copy()
        df["date"] = pd.to_datetime(df["timestamp"]).dt.date
        return df.groupby("date")["pnl"].sum()

    def _compute_daily_profit_max(self, daily_pnl: pd.Series, total_pnl: float) -> float:
        """
        Compute maximum daily profit as percentage of total.

        Formula: daily_max_pct = max(daily_pnl) / total_pnl * 100
        Example: max_day=1000, total=5000 → 1000/5000 * 100 = 20%
        """
        if daily_pnl.empty or total_pnl <= 0:
            return 0.0
        max_daily = daily_pnl.max()
        if max_daily <= 0:
            return 0.0
        return float(max_daily / total_pnl * 100)

    def _compute_positive_days_ratio(self, daily_pnl: pd.Series) -> float:
        """
        Compute ratio of positive days.

        Formula: positive_ratio = count(daily_pnl > 0) / total_days
        """
        if daily_pnl.empty:
            return 0.0
        positive_days = (daily_pnl > 0).sum()
        return float(positive_days / len(daily_pnl))


def quick_wfa_check(
    trades_df: pd.DataFrame,
    start_date: str,
    end_date: str,
    windows: int = 5,
    is_ratio: float = 0.8,
    min_wfe: float = 0.5,
) -> tuple[bool, float, str]:
    """
    Quick WFA validation check (utility function).

    Args:
        trades_df: DataFrame with timestamp and pnl columns
        start_date: Start date string
        end_date: End date string
        windows: Number of WFA windows
        is_ratio: In-sample ratio
        min_wfe: Minimum WFE threshold

    Returns:
        Tuple of (passes, wfe_value, message)
    """
    wfa = InlineWFA(windows=windows, is_ratio=is_ratio)
    splits = wfa.compute_window_splits(start_date, end_date)
    window_results = wfa.analyze_trade_series(trades_df, splits)
    result = wfa.compute_wfa_metrics(window_results, trades_df)

    if result.wfe >= min_wfe:
        return True, result.wfe, f"WFE {result.wfe:.3f} >= {min_wfe}"
    return False, result.wfe, f"WFE {result.wfe:.3f} < {min_wfe} (PRUNE)"
