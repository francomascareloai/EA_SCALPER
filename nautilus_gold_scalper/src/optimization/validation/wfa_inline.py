"""
Inline Walk-Forward Analysis for optimization pipeline.

Runs a simplified WFA during the search phase to validate robustness
without the full overhead of post-hoc validation. Enables early pruning
of configs that show poor out-of-sample performance.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import TYPE_CHECKING

import numpy as np
import pandas as pd

logger = logging.getLogger(__name__)
_WARNED_WFA_TIME_FALLBACK: bool = False

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
    daily_dd: float
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
        """Compute IS/OOS date splits for each window.

        Returns:
            List of (is_start, is_end, oos_start, oos_end) tuples.

        Notes:
            - Treats `end_date` as inclusive when it's a date-only timestamp.
            - Ensures each window has at least 1 OOS day when possible by shrinking
              the IS portion (never by shrinking purge/embargo).
        """
        start = pd.Timestamp(start_date)
        end = pd.Timestamp(end_date)

        # Ensure timezone awareness matches trades_df timestamps (UTC-aware).
        if start.tz is None:
            start = start.tz_localize("UTC")
        else:
            start = start.tz_convert("UTC")

        if end.tz is None:
            end = end.tz_localize("UTC")
        else:
            end = end.tz_convert("UTC")

        if end < start:
            raise ValueError(f"Invalid date range: end_date {end_date} < start_date {start_date}")

        # Most configs use date-only strings; treat end as inclusive.
        end_exclusive = end
        if end.time() == datetime.min.time():
            end_exclusive = end + timedelta(days=1)

        total_days = int((end_exclusive - start).days)
        if total_days <= 0:
            return []

        # Reduce windows when the span is short (prevents window_days=0).
        windows = max(1, min(int(self.windows), total_days))

        base = total_days // windows
        extra = total_days % windows

        splits: list[tuple[datetime, datetime, datetime, datetime]] = []

        cursor = start
        purge_days = int(self.purge_days)
        embargo_days = int(self.embargo_days)

        for i in range(windows):
            window_len = base + (1 if i < extra else 0)
            window_start = cursor
            window_end = window_start + timedelta(days=window_len)
            cursor = window_end

            # Ensure at least 1 OOS day if possible.
            # OOS days available = window_len - is_days - purge_days - embargo_days
            is_target = int(window_len * float(self.is_ratio))
            max_is_days = window_len - (purge_days + embargo_days + 1)
            if max_is_days < 1:
                continue

            is_days = max(1, min(is_target, max_is_days))
            if is_days != is_target:
                logger.debug(
                    "InlineWFA adjusted IS days in window %d from %d to %d to fit purge/embargo constraints",
                    i,
                    is_target,
                    is_days,
                )

            is_start = window_start
            is_end = window_start + timedelta(days=is_days)

            oos_start = is_end + timedelta(days=purge_days)
            oos_end = window_end - timedelta(days=embargo_days)

            if oos_end <= oos_start:
                continue

            splits.append(
                (
                    is_start.to_pydatetime(),
                    is_end.to_pydatetime(),
                    oos_start.to_pydatetime(),
                    oos_end.to_pydatetime(),
                )
            )

        if not splits:
            logger.warning(
                "InlineWFA produced no valid splits for %s..%s (windows=%d, is_ratio=%.3f, purge=%d, embargo=%d)",
                start_date,
                end_date,
                windows,
                float(self.is_ratio),
                purge_days,
                embargo_days,
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

        if "pnl" not in trades_df.columns:
            logger.warning("InlineWFA: trades_df missing required 'pnl' column; treating as empty")
            return windows

        trades_df = trades_df.copy()

        # CRITICAL: Assign trades to WFA windows based on ENTRY time, not exit time.
        # The entry decision reflects what was known at decision time.
        # Using exit time creates look-ahead bias (trade opened in IS but counted as OOS
        # because it exited later), inflating WFE.
        use_entry_time = "entry_time" in trades_df.columns and trades_df["entry_time"].notna().any()
        time_col = "entry_time" if use_entry_time else "timestamp"
        if not use_entry_time:
            global _WARNED_WFA_TIME_FALLBACK
            if not _WARNED_WFA_TIME_FALLBACK:
                logger.warning(
                    "WFA trade assignment falling back to 'timestamp' because 'entry_time' is missing or empty. "
                    "This may introduce look-ahead bias if 'timestamp' is derived from exit_time."
                )
                _WARNED_WFA_TIME_FALLBACK = True

        # Ensure chosen time column is datetime (UTC-aware)
        if not pd.api.types.is_datetime64_any_dtype(trades_df[time_col]):
            trades_df[time_col] = pd.to_datetime(trades_df[time_col], utc=True, errors="coerce")

        # Fail closed on invalid timestamps to avoid biased window assignment.
        nat_count = int(pd.to_datetime(trades_df[time_col], utc=True, errors="coerce").isna().sum())
        if nat_count > 0:
            logger.warning(
                "InlineWFA: %d trades have invalid %s timestamps; failing closed for this trial",
                nat_count,
                time_col,
            )
            return []

        for i, (is_start, is_end, oos_start, oos_end) in enumerate(splits):
            # Filter trades for IS and OOS periods
            is_mask = (trades_df[time_col] >= is_start) & (trades_df[time_col] < is_end)
            oos_mask = (trades_df[time_col] >= oos_start) & (trades_df[time_col] < oos_end)

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
        if full_trades_df.empty or "pnl" not in full_trades_df.columns:
            if not full_trades_df.empty:
                logger.warning(
                    "InlineWFA: full_trades_df missing required 'pnl' column; treating as empty"
                )
            total_trades = 0
            total_pnl = 0.0
            pnl_series = pd.Series([], dtype=float)
        else:
            total_trades = len(full_trades_df)
            total_pnl = float(full_trades_df["pnl"].sum())
            pnl_series = full_trades_df["pnl"].astype(float)

        # Performance metrics
        sqn = self._compute_sqn(pnl_series)
        sharpe = self._compute_sharpe(pnl_series)
        sortino = self._compute_sortino(pnl_series)
        profit_factor = self._compute_profit_factor(pnl_series)
        win_rate = self._compute_win_rate(pnl_series)

        # Drawdown
        # CRITICAL: If equity_series is None/empty, use worst-case DD (100%)
        # to ensure apex_compliant=False. DD=0% would falsely indicate compliance.
        if equity_series is None or len(equity_series) < 2:
            max_dd = 100.0  # Worst-case: cannot compute, assume total loss
        else:
            max_dd = self._compute_max_drawdown(equity_series)

        # Apex metrics
        trailing_dd = max_dd  # Approximation
        daily_pnl = self._compute_daily_pnl(full_trades_df)
        daily_profit_max = self._compute_daily_profit_max(daily_pnl, total_pnl)
        positive_days_ratio = self._compute_positive_days_ratio(daily_pnl)

        daily_dd = self._compute_daily_dd_max(equity_series)

        time_gate_violations = self._compute_time_gate_violations(full_trades_df)
        overnight_positions = self._compute_overnight_positions(full_trades_df)

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
            daily_dd=daily_dd,
            positive_days_ratio=positive_days_ratio,
            time_gate_violations=time_gate_violations,
            overnight_positions=overnight_positions,
            regime_scores={},  # Computed in Layer 3 if needed
        )

    def _empty_result(self) -> WFAResult:
        """Return empty/invalid WFA result with WORST-CASE values.

        CRITICAL: Empty results must fail Apex compliance checks.
        Setting trailing_dd=100.0 (100%) guarantees apex_compliant=False
        since Apex limit is 5%.

        Formula: trailing_dd=100.0 → 100% > 5% threshold → NOT compliant
        """
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
            max_drawdown_pct=100.0,  # Worst-case: 100% DD
            trailing_dd=100.0,  # Worst-case: ensures apex_compliant=False
            daily_profit_max=0.0,
            daily_dd=100.0,
            positive_days_ratio=0.0,
            time_gate_violations=0,
            overnight_positions=0,
            regime_scores={},
        )

    def _compute_sqn(self, pnl_series: pd.Series) -> float:
        """
        Compute System Quality Number.

        Formula: SQN = mean(pnl) / std(pnl) * sqrt(min(n, 100))
        Example: mean=100, std=200, n=100 → 100/200 * 10 = 5.0
        """
        if len(pnl_series) < 2:
            return 0.0
        mean_pnl = float(pnl_series.mean())
        std_pnl = float(pnl_series.std())
        if std_pnl == 0:
            return 0.0
        sqn = mean_pnl / std_pnl * np.sqrt(min(len(pnl_series), 100))
        return float(sqn)

    def _compute_sharpe(
        self,
        pnl_series: pd.Series,
        initial_capital: float = 100_000.0,
        risk_free_rate: float = 0.05,
        periods_per_year: int = 252,
    ) -> float:
        """Compute annualized Sharpe ratio from returns.

        We convert per-period PnL into simple returns by dividing by `initial_capital`.
        `risk_free_rate` is annualized (e.g., 0.05 = 5%/yr) and converted to a per-period
        rate via `risk_free_rate / periods_per_year`.
        """
        if len(pnl_series) < 2 or initial_capital <= 0 or periods_per_year <= 0:
            return 0.0

        # Formula: sharpe = mean(excess_returns) / std(excess_returns) * sqrt(periods_per_year)
        # Example: initial=100000, pnl=[100,-50], rf=0.05, ppy=252
        #   returns=[0.001,-0.0005], rf_per=0.05/252≈0.0001984
        #   excess≈[0.0008016,-0.0006984]
        returns = pnl_series.astype(float) / float(initial_capital)
        rf_per_period = float(risk_free_rate) / float(periods_per_year)
        excess = returns - rf_per_period

        mean_excess = float(excess.mean())
        std_excess = float(excess.std())
        if std_excess < 1e-10:
            return float("inf") if mean_excess > 0 else 0.0

        sharpe = mean_excess / std_excess * float(np.sqrt(periods_per_year))
        if not np.isfinite(sharpe):
            return 0.0
        return float(sharpe)

    def _compute_sortino(
        self,
        pnl_series: pd.Series,
        initial_capital: float = 100_000.0,
        risk_free_rate: float = 0.05,
        periods_per_year: int = 252,
    ) -> float:
        """Compute annualized Sortino ratio from returns (downside deviation only).

        We convert per-period PnL into simple returns by dividing by `initial_capital`.
        `risk_free_rate` is annualized and converted to a per-period minimum acceptable
        return (MAR) via `risk_free_rate / periods_per_year`.
        """
        if len(pnl_series) < 2 or initial_capital <= 0 or periods_per_year <= 0:
            return 0.0

        # Formula: sortino = mean(excess_returns) / std(excess_returns[<0]) * sqrt(periods_per_year)
        # Example: initial=100000, pnl=[100,-50], rf=0.05, ppy=252
        #   returns=[0.001,-0.0005], rf_per≈0.0001984
        #   excess≈[0.0008016,-0.0006984] → downside≈[-0.0006984]
        returns = pnl_series.astype(float) / float(initial_capital)
        rf_per_period = float(risk_free_rate) / float(periods_per_year)
        excess = returns - rf_per_period

        mean_excess = float(excess.mean())
        downside = excess[excess < 0]
        if len(downside) == 0:
            return float("inf") if mean_excess > 0 else 0.0

        downside_std = float(downside.std())
        if downside_std < 1e-10:
            return float("inf") if mean_excess > 0 else 0.0

        sortino = mean_excess / downside_std * float(np.sqrt(periods_per_year))
        if not np.isfinite(sortino):
            return 0.0
        return float(sortino)

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
        """Compute maximum drawdown percentage.

        Formula: DD% = (peak - trough) / peak * 100
        Example: equity=[100, 90] → DD%=(100-90)/100*100 = 10

        Note: Protect against division by zero when the running max is 0.
        """
        if equity_series is None or len(equity_series) < 2:
            return 100.0

        equity_series = equity_series.astype(float)
        equity_series = equity_series.replace([np.inf, -np.inf], np.nan).dropna()
        if len(equity_series) < 2:
            return 100.0

        running_max = equity_series.cummax()
        with np.errstate(divide="ignore", invalid="ignore"):
            drawdown = ((running_max - equity_series) / running_max).where(
                running_max > 0, np.nan
            ) * 100

        max_dd = float(drawdown.max())
        if not np.isfinite(max_dd):
            # Fail closed: if drawdown cannot be computed reliably, treat as blown.
            return 100.0
        # Sanity: drawdown cannot be negative, cap at 100%.
        return float(max(0.0, min(100.0, max_dd)))

    def _compute_daily_pnl(self, trades_df: pd.DataFrame) -> pd.Series:
        """Aggregate PnL by Apex session-day (17:00 ET boundary).

        - Uses realized timing when available (`exit_time`), otherwise falls back to `timestamp`.
        - Apex session-day boundary is approximated as 17:00 ET (5 PM ET).

        If timestamps are invalid, return empty so caller can fail closed.
        """
        if trades_df.empty:
            return pd.Series([], dtype=float)

        df = trades_df.copy()

        time_col = (
            "exit_time"
            if "exit_time" in df.columns and df["exit_time"].notna().any()
            else "timestamp"
        )
        if time_col not in df.columns:
            return pd.Series([], dtype=float)

        times_utc = pd.to_datetime(df[time_col], utc=True, errors="coerce")
        # Fail closed on any invalid times: dropping them can understate daily concentration.
        if times_utc.isna().any():
            return pd.Series([], dtype=float)

        try:
            from zoneinfo import ZoneInfo

            et_tz = ZoneInfo("America/New_York")
            times_local = times_utc.dt.tz_convert(et_tz)
        except Exception:
            times_local = times_utc

        # Session-day key: subtract 17h so [17:00..23:59] maps to next calendar date.
        df["session_date"] = (times_local - pd.Timedelta(hours=17)).dt.date
        return df.groupby("session_date")["pnl"].sum()

    def _compute_daily_profit_max(self, daily_pnl: pd.Series, total_pnl: float) -> float:
        """
        Compute maximum daily profit as percentage of total.

        Formula: daily_max_pct = max(daily_pnl) / total_pnl * 100
        Example: max_day=1000, total=5000 → 1000/5000 * 100 = 20%
        """
        if total_pnl <= 0:
            return 0.0

        # Fail closed: if we cannot compute daily PnL but total PnL is positive,
        # the timestamp series is unreliable and daily profit concentration is unknown.
        if daily_pnl.empty:
            return 100.0
        max_daily = daily_pnl.max()
        if max_daily <= 0:
            return 0.0
        return float(max_daily / total_pnl * 100)

    def _compute_daily_dd_max(self, equity_series: pd.Series | None) -> float:
        """Compute max daily drawdown percentage (Apex-style) from an equity curve.

        We define daily drawdown as the worst peak-to-trough drop within an ET session-day.

        NOTE: This uses a 17:00 ET boundary approximation (Apex session-day).

        Formula per day d:
            dd_d_pct = (max_equity_d - min_equity_d) / max_equity_d * 100
        Example:
            equity_d = [100000, 101000, 99500]
            dd_d_pct = (101000-99500)/101000*100 = 1.485%

        If equity_series is missing/too short/unreliable, fail closed with 100.0.
        """
        if equity_series is None or len(equity_series) < 2:
            return 100.0

        equity = equity_series.astype(float).replace([np.inf, -np.inf], np.nan).dropna()
        if len(equity) < 2:
            return 100.0

        if not isinstance(equity.index, pd.DatetimeIndex):
            # Cannot safely bucket by day.
            return 100.0

        if equity.index.tz is None:
            equity.index = equity.index.tz_localize("UTC")

        try:
            from zoneinfo import ZoneInfo

            et_tz = ZoneInfo("America/New_York")
            idx_local = equity.index.tz_convert(et_tz)
        except Exception:
            idx_local = equity.index

        df = pd.DataFrame({"equity": equity.values}, index=idx_local)
        # Session-day key: subtract 17h so [17:00..23:59] maps to next calendar date.
        df["session_date"] = (pd.Series(df.index) - pd.Timedelta(hours=17)).dt.date.values

        grouped = df.groupby("session_date")["equity"]
        daily_max = grouped.max()
        daily_min = grouped.min()

        # dd_pct = (max-min)/max*100, guarding max<=0.
        with np.errstate(divide="ignore", invalid="ignore"):
            daily_dd = (daily_max - daily_min) / daily_max * 100.0
            daily_dd = daily_dd.where(daily_max > 0, np.nan)

        max_daily_dd = float(daily_dd.max())
        if not np.isfinite(max_daily_dd):
            return 100.0

        return float(max(0.0, min(100.0, max_daily_dd)))

    def _compute_positive_days_ratio(self, daily_pnl: pd.Series) -> float:
        """
        Compute ratio of positive days.

        Formula: positive_ratio = count(daily_pnl > 0) / total_days
        """
        if daily_pnl.empty:
            return 0.0
        positive_days = (daily_pnl > 0).sum()
        return float(positive_days / len(daily_pnl))

    def _compute_time_gate_violations(self, trades_df: pd.DataFrame) -> int:
        """Count trades opened after 16:30 ET (Apex entry time gate).

        The optimization pipeline extracts trades from `generate_positions_report()` and
        normalizes to a DataFrame with `entry_time`, `exit_time`, and `timestamp`.

        We use `entry_time` when available, otherwise fall back to `timestamp`.
        If ET timezone cannot be loaded, return a conservative non-zero count to
        avoid false Apex compliance.
        """
        if trades_df.empty:
            return 0

        try:
            from zoneinfo import ZoneInfo

            et_tz = ZoneInfo("America/New_York")
        except Exception:
            return int(len(trades_df))

        df = trades_df
        ts_col = "entry_time" if "entry_time" in df.columns else "timestamp"
        times_utc = pd.to_datetime(df[ts_col], utc=True, errors="coerce")
        nat_count = int(times_utc.isna().sum())
        if nat_count > 0:
            logger.warning(
                "%s trades have invalid %s timestamps - treating as time-gate violations",
                nat_count,
                ts_col,
            )
        times_et = times_utc.dt.tz_convert(et_tz)

        cutoff = datetime.min.replace(hour=16, minute=30, second=0, microsecond=0).time()
        violations = int((times_et.dt.time >= cutoff).sum()) + nat_count
        return violations

    def _compute_overnight_positions(self, trades_df: pd.DataFrame) -> int:
        """Count positions held past 16:59 ET close deadline.

        We approximate "overnight" violations as any position which:
        - has `exit_time` (or `timestamp`) after 16:59 ET, OR
        - spans an ET date boundary (exit_date_et > entry_date_et)

        This is intentionally conservative for optimization gating.
        If ET timezone cannot be loaded, return a conservative non-zero count.
        """
        if trades_df.empty:
            return 0

        try:
            from zoneinfo import ZoneInfo

            et_tz = ZoneInfo("America/New_York")
        except Exception:
            return int(len(trades_df))

        df = trades_df

        exit_col = "exit_time" if "exit_time" in df.columns else "timestamp"
        exit_utc = pd.to_datetime(df[exit_col], utc=True, errors="coerce")
        exit_nat = int(exit_utc.isna().sum())
        if exit_nat > 0:
            logger.warning(
                "%s trades have invalid %s timestamps - treating as overnight violations",
                exit_nat,
                exit_col,
            )
        exit_et = exit_utc.dt.tz_convert(et_tz)

        cutoff = datetime.min.replace(hour=16, minute=59, second=0, microsecond=0).time()
        after_cutoff = exit_et.dt.time > cutoff

        nat_union = exit_nat
        if "entry_time" in df.columns:
            entry_utc = pd.to_datetime(df["entry_time"], utc=True, errors="coerce")
            entry_nat = int(entry_utc.isna().sum())
            if entry_nat > 0:
                logger.warning(
                    "%s trades have invalid entry_time timestamps - treating as overnight violations",
                    entry_nat,
                )
            entry_et = entry_utc.dt.tz_convert(et_tz)
            cross_day = exit_et.dt.date > entry_et.dt.date
            nat_union = int((exit_utc.isna() | entry_utc.isna()).sum())
        else:
            cross_day = pd.Series([False] * len(df), index=df.index)

        violations = int((after_cutoff | cross_day).sum()) + nat_union
        return violations


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
