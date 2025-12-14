"""
Monte Carlo Simulation for Trading Strategies
==============================================

Implements:
- Traditional Bootstrap Monte Carlo
- Block Bootstrap Monte Carlo (preserves autocorrelation)

Based on: Politis & Romano (1994), Lopez de Prado (2018)
For: EA_SCALPER_XAUUSD - ORACLE Validation

Usage:
    python -m scripts.oracle.monte_carlo --input trades.csv --block
    
    # Or as module:
    from scripts.oracle.monte_carlo import BlockBootstrapMC
    mc = BlockBootstrapMC()
    result = mc.run(trades_df, n_simulations=5000)
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass
from typing import Optional, List, Tuple
import argparse


@dataclass
class MCResult:
    """Results from Monte Carlo simulation"""
    simulations: int
    method: str  # 'traditional' or 'block_bootstrap'
    block_size: Optional[int]
    
    # Drawdown distribution
    dd_5th: float
    dd_25th: float
    dd_50th: float
    dd_75th: float
    dd_95th: float
    dd_99th: float
    
    # Profit distribution
    profit_5th: float
    profit_50th: float
    profit_95th: float
    
    # Risk metrics - VaR and CVaR (FASE 3)
    var_95: float              # Value at Risk 95%
    cvar_95: float             # Conditional VaR (Expected Shortfall)
    risk_of_ruin_5pct: float   # P(hitting 5% DD)
    risk_of_ruin_10pct: float  # P(hitting 10% DD)
    prob_profit: float         # P(profit > 0)
    
    # Streak analysis (for block bootstrap)
    avg_streak_length: float
    max_win_streak: int
    max_loss_streak: int
    
    # FTMO specific
    ftmo_daily_violation_prob: float
    ftmo_total_violation_prob: float
    ftmo_verdict: str
    
    # Confidence Score (FASE 3) - 0 to 100
    confidence_score: int
    confidence_breakdown: dict


class BlockBootstrapMC:
    """
    Block Bootstrap Monte Carlo simulation.
    
    Preserves autocorrelation by sampling blocks of consecutive trades,
    providing more realistic risk estimates than traditional bootstrap.
    """
    
    def __init__(
        self,
        n_simulations: int = 5000,
        initial_capital: float = 100000,
        ftmo_daily_limit: float = 0.05,
        ftmo_total_limit: float = 0.10,
        trades_per_day: int = 0  # 0 = auto-detect or use timestamps
    ):
        self.n_simulations = n_simulations
        self.initial_capital = initial_capital
        self.ftmo_daily_limit = ftmo_daily_limit
        self.ftmo_total_limit = ftmo_total_limit
        self.trades_per_day = trades_per_day  # Configurable trades per day
    
    def optimal_block_size(self, n_trades: int, autocorr: Optional[float] = None) -> int:
        """
        Calculate optimal block size using Politis-Romano method.
        Rule of thumb: block_size = n^(1/3) for stationary series
        """
        base_size = int(np.ceil(n_trades ** (1/3)))
        
        if autocorr is not None and autocorr > 0.1:
            adjustment = 1 + (autocorr * 2)
            return int(np.ceil(base_size * adjustment))
        
        return max(5, min(base_size, 20))  # Clamp between 5-20
    
    def _calculate_autocorrelation(self, profits: np.ndarray) -> float:
        """Calculate first-order autocorrelation of win/loss series"""
        if len(profits) < 10:
            return 0
        returns = np.sign(profits)
        return np.corrcoef(returns[:-1], returns[1:])[0, 1]
    
    def _estimate_trades_per_day(self, trades: pd.DataFrame) -> int:
        """Estimate average trades per day from timestamps if available."""
        datetime_cols = ['datetime', 'time', 'date', 'timestamp', 'open_time', 'close_time']
        
        for col in datetime_cols:
            if col in trades.columns:
                try:
                    dates = pd.to_datetime(trades[col])
                    unique_days = dates.dt.date.nunique()
                    if unique_days > 0:
                        return max(1, len(trades) // unique_days)
                except:
                    continue
        
        # Default: assume 10 trades per day for scalping
        return 10
    
    def run(
        self,
        trades: pd.DataFrame,
        block_size: Optional[int] = None,
        use_block: bool = True
    ) -> MCResult:
        """
        Run Monte Carlo simulation.
        
        Args:
            trades: DataFrame with 'profit' column (in currency or pips)
            block_size: Size of blocks (auto-calculated if None)
            use_block: Use block bootstrap (True) or traditional (False)
        
        Returns:
            MCResult with distribution metrics
        """
        profits = trades['profit'].values
        n_trades = len(profits)
        
        # Determine trades per day for daily DD calculation
        if self.trades_per_day > 0:
            trades_per_day = self.trades_per_day
        else:
            trades_per_day = self._estimate_trades_per_day(trades)
        
        # Calculate autocorrelation
        autocorr = self._calculate_autocorrelation(profits)
        
        # Determine block size
        if use_block:
            if block_size is None:
                block_size = self.optimal_block_size(n_trades, autocorr)
            method = 'block_bootstrap'
        else:
            block_size = 1
            method = 'traditional'
        
        # Storage for results
        max_drawdowns = []
        final_profits = []
        daily_violations = 0
        total_violations = 0
        all_win_streaks = []
        all_loss_streaks = []
        
        n_blocks = n_trades // block_size
        
        for _ in range(self.n_simulations):
            if use_block and n_blocks > 0:
                # Block bootstrap
                block_indices = np.random.randint(0, n_blocks, size=n_blocks)
                simulated_profits = []
                for block_idx in block_indices:
                    start = block_idx * block_size
                    end = start + block_size
                    simulated_profits.extend(profits[start:end])
            else:
                # Traditional bootstrap
                simulated_profits = np.random.choice(profits, size=n_trades, replace=True)
            
            # Calculate equity curve
            equity = [self.initial_capital]
            peak = self.initial_capital
            max_dd = 0
            daily_pnl = 0
            daily_trades = 0
            daily_violation = False
            
            for pnl in simulated_profits:
                new_equity = equity[-1] + pnl
                equity.append(new_equity)
                
                # Track peak and drawdown
                if new_equity > peak:
                    peak = new_equity
                dd = (peak - new_equity) / peak
                max_dd = max(max_dd, dd)
                
                # Daily tracking (reset based on trades_per_day)
                daily_pnl += pnl
                daily_trades += 1
                if daily_trades >= trades_per_day:
                    # Calculate daily DD based on equity-style (FTMO uses equity, not balance)
                    daily_dd = -daily_pnl / self.initial_capital
                    if daily_dd >= self.ftmo_daily_limit:
                        daily_violation = True
                    daily_pnl = 0
                    daily_trades = 0
            
            max_drawdowns.append(max_dd * 100)
            final_profits.append(equity[-1] - self.initial_capital)
            
            if daily_violation:
                daily_violations += 1
            if max_dd >= self.ftmo_total_limit:
                total_violations += 1
            
            # Track streaks
            self._track_streaks(simulated_profits, all_win_streaks, all_loss_streaks)
        
        # Calculate percentiles
        dd_percentiles = np.percentile(max_drawdowns, [5, 25, 50, 75, 95, 99])
        profit_percentiles = np.percentile(final_profits, [5, 50, 95])
        
        # VaR and CVaR (FASE 3)
        var_95 = dd_percentiles[4]  # 95th percentile DD
        # CVaR = average of all DDs worse than VaR
        tail_dds = [dd for dd in max_drawdowns if dd >= var_95]
        cvar_95 = np.mean(tail_dds) if tail_dds else var_95
        
        # FTMO verdict
        ftmo_daily_prob = daily_violations / self.n_simulations * 100
        ftmo_total_prob = total_violations / self.n_simulations * 100
        
        if dd_percentiles[4] < 8:  # 95th percentile < 8%
            ftmo_verdict = "APPROVED for FTMO"
        elif dd_percentiles[4] < 10:
            ftmo_verdict = "MARGINAL - reduce position size"
        else:
            ftmo_verdict = "REJECTED - too risky for FTMO"
        
        # Confidence Score (FASE 3)
        confidence_score, confidence_breakdown = self._calculate_confidence_score(
            dd_95=dd_percentiles[4],
            ftmo_fail_prob=ftmo_total_prob,
            sharpe=self._estimate_sharpe(final_profits),
            total_return=np.mean(final_profits) / self.initial_capital * 100
        )
        
        return MCResult(
            simulations=self.n_simulations,
            method=method,
            block_size=block_size if use_block else None,
            dd_5th=dd_percentiles[0],
            dd_25th=dd_percentiles[1],
            dd_50th=dd_percentiles[2],
            dd_75th=dd_percentiles[3],
            dd_95th=dd_percentiles[4],
            dd_99th=dd_percentiles[5],
            profit_5th=profit_percentiles[0],
            profit_50th=profit_percentiles[1],
            profit_95th=profit_percentiles[2],
            var_95=var_95,
            cvar_95=cvar_95,
            risk_of_ruin_5pct=ftmo_daily_prob,
            risk_of_ruin_10pct=ftmo_total_prob,
            prob_profit=sum(1 for p in final_profits if p > 0) / self.n_simulations * 100,
            avg_streak_length=np.mean(all_win_streaks + all_loss_streaks) if all_win_streaks else 0,
            max_win_streak=max(all_win_streaks) if all_win_streaks else 0,
            max_loss_streak=max(all_loss_streaks) if all_loss_streaks else 0,
            ftmo_daily_violation_prob=ftmo_daily_prob,
            ftmo_total_violation_prob=ftmo_total_prob,
            ftmo_verdict=ftmo_verdict,
            confidence_score=confidence_score,
            confidence_breakdown=confidence_breakdown
        )
    
    def _track_streaks(self, profits: list, win_streaks: list, loss_streaks: list):
        """Track winning and losing streaks"""
        current_streak = 0
        is_winning = None
        
        for pnl in profits:
            if is_winning is None:
                is_winning = pnl > 0
                current_streak = 1
            elif (pnl > 0) == is_winning:
                current_streak += 1
            else:
                if is_winning:
                    win_streaks.append(current_streak)
                else:
                    loss_streaks.append(current_streak)
                is_winning = pnl > 0
                current_streak = 1
    
    def _estimate_sharpe(self, final_profits: list) -> float:
        """Estimate Sharpe from MC results"""
        if len(final_profits) < 2:
            return 0
        returns = np.array(final_profits) / self.initial_capital
        if returns.std() == 0:
            return 0
        return returns.mean() / returns.std() * np.sqrt(252)
    
    def _calculate_confidence_score(
        self, dd_95: float, ftmo_fail_prob: float, sharpe: float, total_return: float
    ) -> Tuple[int, dict]:
        """
        Calculate confidence score 0-100 for FTMO readiness.
        
        Breakdown:
        - DD 95th (40 points): Lower is better
        - P(FTMO fail) (30 points): Lower is better
        - Sharpe (20 points): Higher is better
        - Return (10 points): Higher is better
        """
        breakdown = {}
        
        # DD 95th score (40 points max)
        # 0% = 40pts, 5% = 30pts, 8% = 20pts, 10% = 10pts, >12% = 0pts
        if dd_95 <= 5:
            dd_score = 40
        elif dd_95 <= 8:
            dd_score = 40 - (dd_95 - 5) * (20 / 3)
        elif dd_95 <= 10:
            dd_score = 20 - (dd_95 - 8) * 5
        elif dd_95 <= 12:
            dd_score = 10 - (dd_95 - 10) * 5
        else:
            dd_score = 0
        breakdown['dd_95'] = int(dd_score)
        
        # FTMO fail probability (30 points max)
        # 0% = 30pts, 5% = 20pts, 10% = 10pts, >15% = 0pts
        if ftmo_fail_prob <= 2:
            ftmo_score = 30
        elif ftmo_fail_prob <= 5:
            ftmo_score = 30 - (ftmo_fail_prob - 2) * (10 / 3)
        elif ftmo_fail_prob <= 10:
            ftmo_score = 20 - (ftmo_fail_prob - 5) * 2
        elif ftmo_fail_prob <= 15:
            ftmo_score = 10 - (ftmo_fail_prob - 10) * 2
        else:
            ftmo_score = 0
        breakdown['ftmo_fail'] = int(ftmo_score)
        
        # Sharpe score (20 points max)
        # <1 = 0pts, 1.5 = 10pts, 2.0 = 15pts, 2.5+ = 20pts
        if sharpe >= 2.5:
            sharpe_score = 20
        elif sharpe >= 2.0:
            sharpe_score = 15 + (sharpe - 2.0) * 10
        elif sharpe >= 1.5:
            sharpe_score = 10 + (sharpe - 1.5) * 10
        elif sharpe >= 1.0:
            sharpe_score = (sharpe - 1.0) * 20
        else:
            sharpe_score = 0
        breakdown['sharpe'] = int(sharpe_score)
        
        # Return score (10 points max)
        # <0% = 0pts, 10% = 5pts, 20%+ = 10pts
        if total_return >= 20:
            return_score = 10
        elif total_return >= 10:
            return_score = 5 + (total_return - 10) * 0.5
        elif total_return > 0:
            return_score = total_return * 0.5
        else:
            return_score = 0
        breakdown['return'] = int(return_score)
        
        total_score = int(dd_score + ftmo_score + sharpe_score + return_score)
        return min(100, max(0, total_score)), breakdown
    
    def generate_report(self, result: MCResult) -> str:
        """Generate text report"""
        lines = [
            "=" * 70,
            f"MONTE CARLO SIMULATION REPORT ({result.method.upper()})",
            "=" * 70,
            f"Simulations: {result.simulations:,}",
        ]
        
        if result.block_size:
            lines.append(f"Block Size: {result.block_size} trades (preserves autocorrelation)")
        
        lines.extend([
            "-" * 70,
            "DRAWDOWN DISTRIBUTION:",
            f"   5th percentile:  {result.dd_5th:.1f}% (best case)",
            f"  25th percentile:  {result.dd_25th:.1f}%",
            f"  50th percentile:  {result.dd_50th:.1f}% (median)",
            f"  75th percentile:  {result.dd_75th:.1f}%",
            f"  95th percentile:  {result.dd_95th:.1f}% (worst likely)",
            f"  99th percentile:  {result.dd_99th:.1f}% (extreme)",
            "-" * 70,
            "PROFIT DISTRIBUTION:",
            f"   5th percentile:  ${result.profit_5th:,.0f}",
            f"  50th percentile:  ${result.profit_50th:,.0f}",
            f"  95th percentile:  ${result.profit_95th:,.0f}",
            "-" * 70,
            "RISK METRICS (VaR/CVaR):",
            f"  VaR 95%:            {result.var_95:.1f}% (worst likely DD)",
            f"  CVaR 95%:           {result.cvar_95:.1f}% (expected shortfall)",
            f"  P(Daily DD >= 5%):  {result.risk_of_ruin_5pct:.1f}%",
            f"  P(Total DD >= 10%): {result.risk_of_ruin_10pct:.1f}%",
            f"  P(Profit > 0):      {result.prob_profit:.1f}%",
            "-" * 70,
        ])
        
        if result.method == 'block_bootstrap':
            lines.extend([
                "STREAK ANALYSIS (preserved autocorrelation):",
                f"  Avg streak length: {result.avg_streak_length:.1f}",
                f"  Max win streak:    {result.max_win_streak}",
                f"  Max loss streak:   {result.max_loss_streak}",
                "-" * 70,
            ])
        
        lines.extend([
            "FTMO ASSESSMENT:",
            f"  P(violating 5% daily):  {result.ftmo_daily_violation_prob:.1f}%",
            f"  P(violating 10% total): {result.ftmo_total_violation_prob:.1f}%",
            f"  VERDICT: {result.ftmo_verdict}",
            "-" * 70,
            "CONFIDENCE SCORE:",
            f"  Total: {result.confidence_score}/100",
            f"  Breakdown:",
            f"    DD 95th:     {result.confidence_breakdown.get('dd_95', 0)}/40",
            f"    FTMO Risk:   {result.confidence_breakdown.get('ftmo_fail', 0)}/30",
            f"    Sharpe:      {result.confidence_breakdown.get('sharpe', 0)}/20",
            f"    Return:      {result.confidence_breakdown.get('return', 0)}/10",
            "=" * 70,
        ])
        
        return "\n".join(lines)


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='Monte Carlo Simulation')
    parser.add_argument('--input', '-i', required=True, help='CSV file with profit column')
    parser.add_argument('--simulations', '-n', type=int, default=5000, help='Number of simulations')
    parser.add_argument('--block', action='store_true', help='Use block bootstrap')
    parser.add_argument('--block-size', type=int, default=None, help='Block size (auto if not set)')
    parser.add_argument('--capital', type=float, default=100000, help='Initial capital')
    parser.add_argument('--column', '-c', default='profit', help='Column name for profit')
    
    args = parser.parse_args()
    
    # Load data
    df = pd.read_csv(args.input)
    if args.column not in df.columns:
        for col in ['profit', 'pnl', 'pl', 'return']:
            if col in df.columns:
                args.column = col
                break
        else:
            print(f"Error: Column '{args.column}' not found. Available: {list(df.columns)}")
            return
    
    # Run Monte Carlo
    mc = BlockBootstrapMC(
        n_simulations=args.simulations,
        initial_capital=args.capital
    )
    result = mc.run(df, block_size=args.block_size, use_block=args.block)
    
    # Print report
    print(mc.generate_report(result))


if __name__ == '__main__':
    main()
