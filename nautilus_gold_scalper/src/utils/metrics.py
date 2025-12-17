"""
Performance Metrics Calculator
Calculates Sharpe, Sortino, Calmar, SQN for backtest validation and GO/NO-GO decisions.
"""
from __future__ import annotations

import math
from dataclasses import dataclass


@dataclass
class PerformanceMetrics:
    """Container for strategy performance metrics."""

    # Core metrics
    sharpe_ratio: float
    sortino_ratio: float
    calmar_ratio: float
    sqn: float  # System Quality Number

    # Supporting metrics
    total_pnl: float
    win_rate: float
    profit_factor: float
    max_drawdown_pct: float
    expectancy: float
    avg_win: float
    avg_loss: float
    num_trades: int
    num_wins: int
    num_losses: int

    # Risk metrics
    avg_return: float
    std_dev: float
    downside_std_dev: float
    cagr: float

    def to_dict(self) -> dict[str, float | int]:
        """Convert to dictionary for telemetry."""
        return {
            'sharpe_ratio': round(self.sharpe_ratio, 3),
            'sortino_ratio': round(self.sortino_ratio, 3),
            'calmar_ratio': round(self.calmar_ratio, 3),
            'sqn': round(self.sqn, 3),
            'total_pnl': round(self.total_pnl, 2),
            'win_rate': round(self.win_rate, 2),
            'profit_factor': round(self.profit_factor, 3),
            'max_drawdown_pct': round(self.max_drawdown_pct, 2),
            'expectancy': round(self.expectancy, 2),
            'avg_win': round(self.avg_win, 2),
            'avg_loss': round(self.avg_loss, 2),
            'num_trades': self.num_trades,
            'num_wins': self.num_wins,
            'num_losses': self.num_losses,
        }


class MetricsCalculator:
    """Calculate performance metrics from trade history."""

    def __init__(self, risk_free_rate: float = 0.05, trading_days_per_year: int = 252):
        """
        Initialize metrics calculator.

        Args:
            risk_free_rate: Annual risk-free rate (default 5% = 0.05)
            trading_days_per_year: Number of trading days per year (default 252)
        """
        self.risk_free_rate = risk_free_rate
        self.trading_days_per_year = trading_days_per_year

    def calculate(
        self,
        pnl_series: list[float],
        initial_balance: float = 100000.0,
        period_days: int | None = None,
    ) -> PerformanceMetrics:
        """
        Calculate all performance metrics from PnL series.

        Args:
            pnl_series: List of trade PnLs (in dollars)
            initial_balance: Starting account balance
            period_days: Number of days in test period (for CAGR calculation)

        Returns:
            PerformanceMetrics object with all calculated metrics
        """
        if not pnl_series or len(pnl_series) == 0:
            return self._empty_metrics()

        # Basic statistics
        num_trades = len(pnl_series)
        total_pnl = sum(pnl_series)
        wins = [p for p in pnl_series if p > 0]
        losses = [p for p in pnl_series if p < 0]
        num_wins = len(wins)
        num_losses = len(losses)

        win_rate = (num_wins / num_trades * 100) if num_trades > 0 else 0.0
        avg_win = (sum(wins) / len(wins)) if wins else 0.0
        avg_loss = (sum(losses) / len(losses)) if losses else 0.0

        # Profit factor
        gross_profit = sum(wins) if wins else 0.0
        gross_loss = abs(sum(losses)) if losses else 0.0
        profit_factor = (gross_profit / gross_loss) if gross_loss > 0 else float('inf')

        # Expectancy
        expectancy = (win_rate / 100.0 * avg_win) + ((1 - win_rate / 100.0) * avg_loss)

        # Returns and standard deviation
        returns = [p / initial_balance for p in pnl_series]
        avg_return = sum(returns) / len(returns) if returns else 0.0

        # Std dev
        if len(returns) > 1:
            variance = sum((r - avg_return) ** 2 for r in returns) / (len(returns) - 1)
            std_dev = math.sqrt(variance)
        else:
            std_dev = 0.0

        # Downside deviation (for Sortino)
        negative_returns = [r for r in returns if r < 0]
        if len(negative_returns) > 1:
            downside_variance = sum(r ** 2 for r in negative_returns) / len(negative_returns)
            downside_std_dev = math.sqrt(downside_variance)
        else:
            downside_std_dev = std_dev if std_dev > 0 else 1e-10

        # Calculate max drawdown
        equity_curve = [initial_balance]
        for pnl in pnl_series:
            equity_curve.append(equity_curve[-1] + pnl)

        max_dd_pct = self._calculate_max_drawdown_pct(equity_curve)

        # CAGR (Compound Annual Growth Rate)
        if period_days and period_days > 0:
            years = period_days / 365.25
            final_balance = equity_curve[-1]
            cagr = ((final_balance / initial_balance) ** (1 / years) - 1) * 100
        else:
            # Fallback: assume each trade is 1 day
            years = num_trades / self.trading_days_per_year
            if years > 0:
                final_balance = equity_curve[-1]
                cagr = ((final_balance / initial_balance) ** (1 / years) - 1) * 100
            else:
                cagr = 0.0

        # Sharpe Ratio
        # Annualized: Sharpe = sqrt(252) * (avg_return - rf) / std_dev
        daily_rf = self.risk_free_rate / self.trading_days_per_year
        if std_dev > 1e-10:  # Avoid division by zero
            sharpe = math.sqrt(self.trading_days_per_year) * (avg_return - daily_rf) / std_dev
        else:
            # Perfect consistency (all trades identical)
            sharpe = float('inf') if avg_return > daily_rf else 0.0

        # Sortino Ratio
        # Annualized: Sortino = sqrt(252) * (avg_return - rf) / downside_std_dev
        if downside_std_dev > 0:
            sortino = math.sqrt(self.trading_days_per_year) * (avg_return - daily_rf) / downside_std_dev
        else:
            sortino = 0.0

        # Calmar Ratio
        # Calmar = CAGR / MaxDD (both in %)
        if max_dd_pct > 0:
            calmar = cagr / max_dd_pct
        else:
            calmar = 0.0

        # System Quality Number (SQN)
        # SQN = sqrt(N) * Expectancy / StdDev(PnL)
        if len(pnl_series) > 1:
            pnl_std = math.sqrt(sum((p - (total_pnl / num_trades)) ** 2 for p in pnl_series) / (num_trades - 1))
            if pnl_std > 1e-10:  # Avoid division by zero
                sqn = math.sqrt(num_trades) * expectancy / pnl_std
            else:
                # Perfect consistency (all trades identical)
                sqn = float('inf') if expectancy > 0 else 0.0
        else:
            sqn = 0.0

        return PerformanceMetrics(
            sharpe_ratio=sharpe,
            sortino_ratio=sortino,
            calmar_ratio=calmar,
            sqn=sqn,
            total_pnl=total_pnl,
            win_rate=win_rate,
            profit_factor=profit_factor,
            max_drawdown_pct=max_dd_pct,
            expectancy=expectancy,
            avg_win=avg_win,
            avg_loss=avg_loss,
            num_trades=num_trades,
            num_wins=num_wins,
            num_losses=num_losses,
            avg_return=avg_return,
            std_dev=std_dev,
            downside_std_dev=downside_std_dev,
            cagr=cagr,
        )

    def _calculate_max_drawdown_pct(self, equity_curve: list[float]) -> float:
        """Calculate maximum drawdown percentage from equity curve."""
        if not equity_curve or len(equity_curve) < 2:
            return 0.0

        max_dd = 0.0
        peak = equity_curve[0]

        for equity in equity_curve:
            if equity > peak:
                peak = equity
            dd_pct = ((peak - equity) / peak) * 100 if peak > 0 else 0.0
            if dd_pct > max_dd:
                max_dd = dd_pct

        return max_dd

    def _empty_metrics(self) -> PerformanceMetrics:
        """Return empty metrics when no trades."""
        return PerformanceMetrics(
            sharpe_ratio=0.0,
            sortino_ratio=0.0,
            calmar_ratio=0.0,
            sqn=0.0,
            total_pnl=0.0,
            win_rate=0.0,
            profit_factor=0.0,
            max_drawdown_pct=0.0,
            expectancy=0.0,
            avg_win=0.0,
            avg_loss=0.0,
            num_trades=0,
            num_wins=0,
            num_losses=0,
            avg_return=0.0,
            std_dev=0.0,
            downside_std_dev=0.0,
            cagr=0.0,
        )


def calculate_metrics_from_trades(
    trades: list[tuple[float, float]],  # List of (entry_price, exit_price) tuples
    position_size: float = 1.0,
    initial_balance: float = 100000.0,
    risk_free_rate: float = 0.05,
) -> PerformanceMetrics:
    """
    Convenience function to calculate metrics from list of trades.

    Args:
        trades: List of (entry_price, exit_price) tuples
        position_size: Size per trade (in units/contracts)
        initial_balance: Starting balance
        risk_free_rate: Annual risk-free rate

    Returns:
        PerformanceMetrics object
    """
    pnl_series = [(exit_price - entry_price) * position_size for entry_price, exit_price in trades]
    calculator = MetricsCalculator(risk_free_rate=risk_free_rate)
    return calculator.calculate(pnl_series, initial_balance=initial_balance)
