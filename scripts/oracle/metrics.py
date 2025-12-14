"""
Trading Performance Metrics
===========================

Implements all standard trading metrics:
- SQN (System Quality Number)
- Sharpe, Sortino, Calmar ratios
- Profit Factor, Win Rate
- Drawdown metrics
- R-Multiples

For: EA_SCALPER_XAUUSD - ORACLE Validation

Usage:
    from scripts.oracle.metrics import calculate_all_metrics
    metrics = calculate_all_metrics(trades_df, equity_curve)
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass
from typing import Optional, Dict, Any


@dataclass
class TradingMetrics:
    """Complete set of trading metrics"""
    # Returns
    total_return: float
    cagr: float
    monthly_avg: float
    
    # Risk
    max_drawdown: float
    avg_drawdown: float
    volatility: float
    
    # Ratios
    sharpe: float
    sortino: float
    calmar: float
    profit_factor: float
    recovery_factor: float
    
    # Trade stats
    total_trades: int
    win_rate: float
    avg_win: float
    avg_loss: float
    avg_win_loss_ratio: float
    expectancy: float
    max_consecutive_losses: int
    
    # SQN
    sqn: float
    sqn_interpretation: str


def calculate_sqn(trades: pd.DataFrame, risk_per_trade: Optional[float] = None) -> tuple:
    """
    Calculate System Quality Number (Van Tharp).
    
    SQN = sqrt(min(N, 100)) * (Mean_R / StdDev_R)
    
    Args:
        trades: DataFrame with 'profit' column
        risk_per_trade: Fixed risk per trade (for R calculation)
    
    Returns:
        (sqn_value, interpretation)
    """
    profits = trades['profit'].values
    n = len(profits)
    
    if n < 10:
        return 0, "Insufficient trades (<10)"
    
    # If no risk provided, use absolute value of average loss
    if risk_per_trade is None:
        losses = profits[profits < 0]
        risk_per_trade = abs(losses.mean()) if len(losses) > 0 else abs(profits.std())
    
    # Calculate R-multiples
    r_multiples = profits / risk_per_trade if risk_per_trade > 0 else profits
    
    mean_r = r_multiples.mean()
    std_r = r_multiples.std(ddof=1)
    
    if std_r == 0:
        return 0, "Zero variance in trades"
    
    sqn = np.sqrt(min(n, 100)) * mean_r / std_r
    
    # Interpretation
    if sqn < 1.5:
        interp = "Poor - difficult to trade profitably"
    elif sqn < 2.0:
        interp = "Average system"
    elif sqn < 3.0:
        interp = "GOOD system"
    elif sqn < 5.0:
        interp = "EXCELLENT system"
    elif sqn < 7.0:
        interp = "SUPERB system (rare)"
    else:
        interp = "Holy Grail? (SUSPICIOUS - check for bugs)"
    
    return sqn, interp


def calculate_sharpe(returns: np.ndarray, risk_free: float = 0.0, annualization: int = 252) -> float:
    """Calculate annualized Sharpe Ratio"""
    excess = returns - risk_free / annualization
    if excess.std() == 0:
        return 0
    return np.sqrt(annualization) * excess.mean() / excess.std()


def calculate_sortino(returns: np.ndarray, risk_free: float = 0.0, annualization: int = 252) -> float:
    """Calculate Sortino Ratio (downside deviation only)"""
    excess = returns - risk_free / annualization
    downside = returns[returns < 0]
    
    if len(downside) == 0 or downside.std() == 0:
        return 0
    
    downside_dev = np.sqrt(np.mean(downside**2))
    return np.sqrt(annualization) * excess.mean() / downside_dev


def calculate_calmar(returns: np.ndarray, max_dd: float, annualization: int = 252) -> float:
    """Calculate Calmar Ratio (CAGR / MaxDD)"""
    if max_dd == 0:
        return 0
    
    total_return = (1 + returns).prod() - 1
    years = len(returns) / annualization
    cagr = (1 + total_return) ** (1 / years) - 1 if years > 0 else 0
    
    return cagr / max_dd


def calculate_max_drawdown(equity_curve: np.ndarray) -> tuple:
    """
    Calculate maximum drawdown.
    
    Returns:
        (max_dd_pct, max_dd_duration_days, avg_dd_pct)
    """
    peak = np.maximum.accumulate(equity_curve)
    dd = (peak - equity_curve) / peak
    max_dd = dd.max()
    
    # Calculate average DD
    avg_dd = dd[dd > 0].mean() if len(dd[dd > 0]) > 0 else 0
    
    # Calculate max DD duration (simplified)
    in_dd = dd > 0
    if not any(in_dd):
        return max_dd, 0, avg_dd
    
    # Find longest consecutive DD period
    dd_lengths = []
    current_length = 0
    for is_dd in in_dd:
        if is_dd:
            current_length += 1
        else:
            if current_length > 0:
                dd_lengths.append(current_length)
            current_length = 0
    if current_length > 0:
        dd_lengths.append(current_length)
    
    max_duration = max(dd_lengths) if dd_lengths else 0
    
    return max_dd, max_duration, avg_dd


def calculate_max_consecutive_losses(trades: pd.DataFrame) -> int:
    """Calculate maximum consecutive losing trades"""
    profits = trades['profit'].values
    max_consec = 0
    current_consec = 0
    
    for p in profits:
        if p < 0:
            current_consec += 1
            max_consec = max(max_consec, current_consec)
        else:
            current_consec = 0
    
    return max_consec


def calculate_all_metrics(
    trades: pd.DataFrame,
    equity_curve: Optional[np.ndarray] = None,
    initial_capital: float = 100000,
    annualization: int = 252
) -> TradingMetrics:
    """
    Calculate all trading metrics.
    
    Args:
        trades: DataFrame with 'profit' column
        equity_curve: Numpy array of equity values (calculated if None)
        initial_capital: Starting capital
        annualization: Trading days per year
    
    Returns:
        TradingMetrics dataclass
    """
    profits = trades['profit'].values
    n_trades = len(profits)
    
    # Build equity curve if not provided
    if equity_curve is None:
        equity_curve = initial_capital + np.cumsum(profits)
        equity_curve = np.insert(equity_curve, 0, initial_capital)
    
    # Returns
    returns = np.diff(equity_curve) / equity_curve[:-1]
    total_return = (equity_curve[-1] / equity_curve[0]) - 1
    
    # CAGR (assume 252 trading days)
    years = n_trades / annualization
    cagr = (1 + total_return) ** (1 / years) - 1 if years > 0 else 0
    monthly_avg = cagr / 12
    
    # Drawdown
    max_dd, dd_duration, avg_dd = calculate_max_drawdown(equity_curve)
    
    # Volatility
    volatility = returns.std() * np.sqrt(annualization)
    
    # Ratios
    sharpe = calculate_sharpe(returns, annualization=annualization)
    sortino = calculate_sortino(returns, annualization=annualization)
    calmar = calculate_calmar(returns, max_dd, annualization)
    
    # Trade stats
    wins = profits[profits > 0]
    losses = profits[profits < 0]
    
    win_rate = len(wins) / n_trades if n_trades > 0 else 0
    avg_win = wins.mean() if len(wins) > 0 else 0
    avg_loss = abs(losses.mean()) if len(losses) > 0 else 0
    avg_win_loss_ratio = avg_win / avg_loss if avg_loss > 0 else 0
    
    # Profit Factor
    gross_profit = wins.sum() if len(wins) > 0 else 0
    gross_loss = abs(losses.sum()) if len(losses) > 0 else 1
    profit_factor = gross_profit / gross_loss if gross_loss > 0 else 0
    
    # Expectancy
    expectancy = (win_rate * avg_win) - ((1 - win_rate) * avg_loss)
    
    # Recovery Factor
    net_profit = equity_curve[-1] - initial_capital
    recovery_factor = net_profit / (max_dd * initial_capital) if max_dd > 0 else 0
    
    # Max consecutive losses
    max_consec_loss = calculate_max_consecutive_losses(trades)
    
    # SQN
    sqn, sqn_interp = calculate_sqn(trades)
    
    return TradingMetrics(
        total_return=total_return * 100,
        cagr=cagr * 100,
        monthly_avg=monthly_avg * 100,
        max_drawdown=max_dd * 100,
        avg_drawdown=avg_dd * 100,
        volatility=volatility * 100,
        sharpe=sharpe,
        sortino=sortino,
        calmar=calmar,
        profit_factor=profit_factor,
        recovery_factor=recovery_factor,
        total_trades=n_trades,
        win_rate=win_rate * 100,
        avg_win=avg_win,
        avg_loss=avg_loss,
        avg_win_loss_ratio=avg_win_loss_ratio,
        expectancy=expectancy,
        max_consecutive_losses=max_consec_loss,
        sqn=sqn,
        sqn_interpretation=sqn_interp
    )


def generate_metrics_report(metrics: TradingMetrics) -> str:
    """Generate formatted metrics report"""
    lines = [
        "=" * 70,
        "TRADING METRICS REPORT",
        "=" * 70,
        "",
        "RETURNS:",
        f"  Total Return:      {metrics.total_return:.1f}%",
        f"  CAGR:              {metrics.cagr:.1f}%",
        f"  Monthly Average:   {metrics.monthly_avg:.2f}%",
        "",
        "RISK:",
        f"  Max Drawdown:      {metrics.max_drawdown:.1f}%",
        f"  Avg Drawdown:      {metrics.avg_drawdown:.1f}%",
        f"  Volatility:        {metrics.volatility:.1f}%",
        "",
        "RATIOS:",
        f"  Sharpe:            {metrics.sharpe:.2f}",
        f"  Sortino:           {metrics.sortino:.2f}",
        f"  Calmar:            {metrics.calmar:.2f}",
        f"  Profit Factor:     {metrics.profit_factor:.2f}",
        f"  Recovery Factor:   {metrics.recovery_factor:.2f}",
        "",
        "TRADE STATISTICS:",
        f"  Total Trades:      {metrics.total_trades}",
        f"  Win Rate:          {metrics.win_rate:.1f}%",
        f"  Avg Win:           ${metrics.avg_win:.2f}",
        f"  Avg Loss:          ${metrics.avg_loss:.2f}",
        f"  Win/Loss Ratio:    {metrics.avg_win_loss_ratio:.2f}",
        f"  Expectancy:        ${metrics.expectancy:.2f}",
        f"  Max Consec Losses: {metrics.max_consecutive_losses}",
        "",
        "SYSTEM QUALITY:",
        f"  SQN:               {metrics.sqn:.2f}",
        f"  Interpretation:    {metrics.sqn_interpretation}",
        "=" * 70,
    ]
    
    return "\n".join(lines)


# Thresholds for GO/NO-GO decisions
THRESHOLDS = {
    'min_trades': 100,
    'min_sharpe': 1.5,
    'min_sortino': 2.0,
    'min_calmar': 3.0,
    'min_profit_factor': 2.0,
    'max_drawdown': 10.0,
    'min_win_rate': 50.0,
    'min_sqn': 2.0,
    'max_consec_losses': 6,
    'min_expectancy': 0,
}


def evaluate_go_nogo(metrics: TradingMetrics) -> tuple:
    """
    Evaluate GO/NO-GO based on metrics.
    
    Returns:
        (decision: str, passed: list, failed: list)
    """
    passed = []
    failed = []
    
    checks = [
        ('Trades >= 100', metrics.total_trades >= THRESHOLDS['min_trades']),
        ('Sharpe >= 1.5', metrics.sharpe >= THRESHOLDS['min_sharpe']),
        ('Sortino >= 2.0', metrics.sortino >= THRESHOLDS['min_sortino']),
        ('Calmar >= 3.0', metrics.calmar >= THRESHOLDS['min_calmar']),
        ('Profit Factor >= 2.0', metrics.profit_factor >= THRESHOLDS['min_profit_factor']),
        ('Max DD <= 10%', metrics.max_drawdown <= THRESHOLDS['max_drawdown']),
        ('Win Rate >= 50%', metrics.win_rate >= THRESHOLDS['min_win_rate']),
        ('SQN >= 2.0', metrics.sqn >= THRESHOLDS['min_sqn']),
        ('Max Consec Losses <= 6', metrics.max_consecutive_losses <= THRESHOLDS['max_consec_losses']),
        ('Expectancy > 0', metrics.expectancy > THRESHOLDS['min_expectancy']),
    ]
    
    for name, result in checks:
        if result:
            passed.append(name)
        else:
            failed.append(name)
    
    # Decision logic
    critical_fails = [f for f in failed if 'DD' in f or 'Expectancy' in f or 'SQN' in f]
    
    if len(failed) == 0:
        decision = "GO"
    elif len(critical_fails) > 0:
        decision = "NO-GO"
    elif len(failed) <= 2:
        decision = "CONDITIONAL GO"
    else:
        decision = "NO-GO"
    
    return decision, passed, failed
