"""
R-Multiple Tracker - Van Tharp Methodology
EA_SCALPER_XAUUSD - Risk Module

Measures trading performance in units of initial risk (R).
Essential for system quality assessment and position sizing.

Reference: "Trade Your Way to Financial Freedom" - Van Tharp
"""
import numpy as np
import pandas as pd
from dataclasses import dataclass, field
from typing import List, Dict, Optional
from datetime import datetime


@dataclass
class Trade:
    """Single trade record with R-multiple calculation."""
    entry_time: datetime
    exit_time: datetime
    direction: str  # 'long' or 'short'
    entry_price: float
    exit_price: float
    stop_loss: float
    size: float = 1.0
    comment: str = ''
    
    @property
    def initial_risk(self) -> float:
        """Initial risk in price points."""
        return abs(self.entry_price - self.stop_loss)
    
    @property
    def pnl(self) -> float:
        """Profit/Loss in price points."""
        if self.direction == 'long':
            return self.exit_price - self.entry_price
        return self.entry_price - self.exit_price
    
    @property
    def r_multiple(self) -> float:
        """PnL expressed as multiple of initial risk."""
        if self.initial_risk == 0:
            return 0
        return self.pnl / self.initial_risk
    
    @property
    def is_winner(self) -> bool:
        return self.pnl > 0
    
    @property
    def holding_time(self) -> float:
        """Holding time in hours."""
        return (self.exit_time - self.entry_time).total_seconds() / 3600


@dataclass
class RMultipleStats:
    """Comprehensive R-Multiple statistics."""
    total_trades: int
    winning_trades: int
    losing_trades: int
    expectancy: float          # Average R per trade
    sqn: float                 # System Quality Number
    profit_factor: float       # Sum(wins) / |Sum(losses)|
    win_rate: float            # Percentage of winners
    avg_win_r: float           # Average winner in R
    avg_loss_r: float          # Average loser in R (negative)
    max_r: float               # Best trade
    min_r: float               # Worst trade
    std_r: float               # Standard deviation of R
    all_r_multiples: List[float]
    sqn_rating: str            # Quality classification
    
    # Additional metrics
    expectunity: float = 0     # Expectancy × Trade Frequency
    max_consecutive_wins: int = 0
    max_consecutive_losses: int = 0
    avg_holding_time: float = 0  # In hours
    

class RMultipleTracker:
    """
    R-Multiple Tracker based on Van Tharp methodology.
    
    Key Concepts:
    - R = Initial Risk (distance to stop loss)
    - Every trade is measured in R-multiples
    - Enables comparison across different position sizes
    - Essential for calculating system quality
    
    Van Tharp's SQN Rating:
    - < 1.6: Poor
    - 1.6 - 2.0: Average
    - 2.0 - 3.0: Good
    - 3.0 - 5.0: Excellent
    - 5.0 - 7.0: Superb
    - > 7.0: Holy Grail
    """
    
    def __init__(self):
        self.trades: List[Trade] = []
    
    def record_trade(
        self,
        entry_time: datetime,
        exit_time: datetime,
        direction: str,
        entry_price: float,
        exit_price: float,
        stop_loss: float,
        size: float = 1.0,
        comment: str = ''
    ) -> float:
        """
        Record a completed trade.
        
        Returns:
            R-multiple of the trade
        """
        trade = Trade(
            entry_time=entry_time,
            exit_time=exit_time,
            direction=direction.lower(),
            entry_price=entry_price,
            exit_price=exit_price,
            stop_loss=stop_loss,
            size=size,
            comment=comment
        )
        self.trades.append(trade)
        return trade.r_multiple
    
    def record_from_dict(self, trade_dict: dict) -> float:
        """Record trade from dictionary."""
        return self.record_trade(
            entry_time=trade_dict.get('entry_time', datetime.now()),
            exit_time=trade_dict.get('exit_time', datetime.now()),
            direction=trade_dict.get('direction', 'long'),
            entry_price=trade_dict.get('entry_price', 0),
            exit_price=trade_dict.get('exit_price', 0),
            stop_loss=trade_dict.get('stop_loss', 0),
            size=trade_dict.get('size', 1.0),
            comment=trade_dict.get('comment', '')
        )
    
    def get_stats(self) -> RMultipleStats:
        """Calculate comprehensive R-multiple statistics."""
        if not self.trades:
            return self._empty_stats()
        
        r_multiples = [t.r_multiple for t in self.trades]
        winners = [r for r in r_multiples if r > 0]
        losers = [r for r in r_multiples if r < 0]
        
        n = len(r_multiples)
        expectancy = np.mean(r_multiples)
        std_r = np.std(r_multiples, ddof=1) if n > 1 else 0
        
        # SQN = (Expectancy × sqrt(N)) / StdDev
        sqn = (expectancy * np.sqrt(n)) / std_r if std_r > 0 else 0
        
        # Profit Factor
        sum_winners = sum(winners) if winners else 0
        sum_losers = abs(sum(losers)) if losers else 0.001
        profit_factor = sum_winners / sum_losers
        
        # Consecutive wins/losses
        max_cons_wins, max_cons_losses = self._calculate_streaks()
        
        # Average holding time
        holding_times = [t.holding_time for t in self.trades]
        avg_holding = np.mean(holding_times) if holding_times else 0
        
        return RMultipleStats(
            total_trades=n,
            winning_trades=len(winners),
            losing_trades=len(losers),
            expectancy=expectancy,
            sqn=sqn,
            profit_factor=profit_factor,
            win_rate=len(winners) / n if n > 0 else 0,
            avg_win_r=np.mean(winners) if winners else 0,
            avg_loss_r=np.mean(losers) if losers else 0,
            max_r=max(r_multiples),
            min_r=min(r_multiples),
            std_r=std_r,
            all_r_multiples=r_multiples,
            sqn_rating=self._get_sqn_rating(sqn),
            max_consecutive_wins=max_cons_wins,
            max_consecutive_losses=max_cons_losses,
            avg_holding_time=avg_holding
        )
    
    def _calculate_streaks(self) -> tuple:
        """Calculate max consecutive wins and losses."""
        if not self.trades:
            return 0, 0
        
        max_wins = 0
        max_losses = 0
        current_wins = 0
        current_losses = 0
        
        for trade in self.trades:
            if trade.is_winner:
                current_wins += 1
                current_losses = 0
                max_wins = max(max_wins, current_wins)
            else:
                current_losses += 1
                current_wins = 0
                max_losses = max(max_losses, current_losses)
        
        return max_wins, max_losses
    
    def _get_sqn_rating(self, sqn: float) -> str:
        """Get Van Tharp SQN rating."""
        if sqn < 1.6:
            return 'Poor'
        elif sqn < 2.0:
            return 'Average'
        elif sqn < 3.0:
            return 'Good'
        elif sqn < 5.0:
            return 'Excellent'
        elif sqn < 7.0:
            return 'Superb'
        else:
            return 'Holy Grail'
    
    def _empty_stats(self) -> RMultipleStats:
        """Return empty stats when no trades."""
        return RMultipleStats(
            total_trades=0,
            winning_trades=0,
            losing_trades=0,
            expectancy=0,
            sqn=0,
            profit_factor=0,
            win_rate=0,
            avg_win_r=0,
            avg_loss_r=0,
            max_r=0,
            min_r=0,
            std_r=0,
            all_r_multiples=[],
            sqn_rating='No Data'
        )
    
    def get_rolling_stats(self, window: int = 50) -> Dict[str, List[float]]:
        """
        Calculate rolling statistics to detect system degradation.
        
        Useful for detecting if system is breaking down.
        """
        if len(self.trades) < window:
            return {'expectancy': [], 'sqn': [], 'win_rate': []}
        
        r_multiples = [t.r_multiple for t in self.trades]
        
        rolling_exp = []
        rolling_sqn = []
        rolling_wr = []
        
        for i in range(window, len(r_multiples) + 1):
            window_data = r_multiples[i-window:i]
            exp = np.mean(window_data)
            std = np.std(window_data, ddof=1)
            sqn = (exp * np.sqrt(window)) / std if std > 0 else 0
            wr = len([r for r in window_data if r > 0]) / window
            
            rolling_exp.append(exp)
            rolling_sqn.append(sqn)
            rolling_wr.append(wr)
        
        return {
            'expectancy': rolling_exp,
            'sqn': rolling_sqn,
            'win_rate': rolling_wr
        }
    
    def should_reduce_risk(
        self, 
        min_sqn: float = 1.6, 
        window: int = 30
    ) -> bool:
        """
        Recommend reducing risk if recent SQN falls below threshold.
        """
        if len(self.trades) < window:
            return False
        
        recent_r = [t.r_multiple for t in self.trades[-window:]]
        exp = np.mean(recent_r)
        std = np.std(recent_r, ddof=1)
        recent_sqn = (exp * np.sqrt(window)) / std if std > 0 else 0
        
        return recent_sqn < min_sqn
    
    def calculate_optimal_risk(
        self, 
        target_sqn: float = 2.0,
        current_risk_pct: float = 0.01
    ) -> float:
        """
        Calculate optimal risk percentage to achieve target SQN.
        
        Note: This is theoretical - actual results vary.
        """
        stats = self.get_stats()
        
        if stats.sqn <= 0:
            return current_risk_pct / 2  # Cut risk if system is bad
        
        # SQN improves with more trades, not higher risk
        # But we can adjust based on system quality
        
        if stats.sqn >= target_sqn:
            return current_risk_pct  # Keep current
        
        # Reduce risk proportionally
        adjustment = stats.sqn / target_sqn
        return current_risk_pct * adjustment
    
    def to_dataframe(self) -> pd.DataFrame:
        """Export trades as DataFrame."""
        return pd.DataFrame([
            {
                'entry_time': t.entry_time,
                'exit_time': t.exit_time,
                'direction': t.direction,
                'entry_price': t.entry_price,
                'exit_price': t.exit_price,
                'stop_loss': t.stop_loss,
                'size': t.size,
                'initial_risk': t.initial_risk,
                'pnl': t.pnl,
                'r_multiple': t.r_multiple,
                'is_winner': t.is_winner,
                'holding_time_hours': t.holding_time,
                'comment': t.comment
            }
            for t in self.trades
        ])
    
    def print_report(self):
        """Print formatted report."""
        stats = self.get_stats()
        
        print("\n" + "=" * 60)
        print("R-MULTIPLE ANALYSIS REPORT (Van Tharp Method)")
        print("=" * 60)
        
        print(f"\n--- Performance Overview ---")
        print(f"Total Trades:       {stats.total_trades}")
        print(f"Winning Trades:     {stats.winning_trades} ({stats.win_rate*100:.1f}%)")
        print(f"Losing Trades:      {stats.losing_trades}")
        print(f"Max Consecutive W:  {stats.max_consecutive_wins}")
        print(f"Max Consecutive L:  {stats.max_consecutive_losses}")
        
        print(f"\n--- R-Multiple Metrics ---")
        print(f"Expectancy:         {stats.expectancy:+.3f}R per trade")
        print(f"SQN:                {stats.sqn:.2f} ({stats.sqn_rating})")
        print(f"Profit Factor:      {stats.profit_factor:.2f}")
        
        print(f"\n--- Distribution ---")
        print(f"Average Winner:     +{stats.avg_win_r:.2f}R")
        print(f"Average Loser:      {stats.avg_loss_r:.2f}R")
        print(f"Best Trade:         +{stats.max_r:.2f}R")
        print(f"Worst Trade:        {stats.min_r:.2f}R")
        print(f"Std Deviation:      {stats.std_r:.2f}R")
        
        print(f"\n--- Time Analysis ---")
        print(f"Avg Holding Time:   {stats.avg_holding_time:.1f} hours")
        
        print(f"\n--- Interpretation ---")
        if stats.expectancy > 0.5:
            print("Positive expectancy - system has edge")
        elif stats.expectancy > 0:
            print("Marginal positive expectancy - monitor closely")
        else:
            print("NEGATIVE expectancy - DO NOT TRADE!")
        
        if stats.sqn >= 2.0:
            print(f"SQN {stats.sqn:.1f} indicates a {stats.sqn_rating.lower()} trading system")
        else:
            print(f"SQN {stats.sqn:.1f} is below optimal - consider improvements")
        
        print("=" * 60)


if __name__ == '__main__':
    # Test with sample trades
    tracker = RMultipleTracker()
    
    # Simulate trades
    base_time = datetime(2024, 1, 1, 10, 0)
    
    sample_trades = [
        # Winners
        {'entry_price': 2000, 'exit_price': 2020, 'stop_loss': 1990, 'direction': 'long'},   # +2R
        {'entry_price': 2030, 'exit_price': 2050, 'stop_loss': 2020, 'direction': 'long'},   # +2R
        {'entry_price': 2060, 'exit_price': 2040, 'stop_loss': 2070, 'direction': 'short'},  # +2R
        {'entry_price': 2035, 'exit_price': 2055, 'stop_loss': 2025, 'direction': 'long'},   # +2R
        {'entry_price': 2050, 'exit_price': 2075, 'stop_loss': 2040, 'direction': 'long'},   # +2.5R
        # Losers
        {'entry_price': 2070, 'exit_price': 2060, 'stop_loss': 2080, 'direction': 'long'},   # -1R
        {'entry_price': 2055, 'exit_price': 2048, 'stop_loss': 2065, 'direction': 'long'},   # -0.7R
        {'entry_price': 2040, 'exit_price': 2050, 'stop_loss': 2030, 'direction': 'short'},  # -1R
        # More winners
        {'entry_price': 2055, 'exit_price': 2085, 'stop_loss': 2045, 'direction': 'long'},   # +3R
        {'entry_price': 2080, 'exit_price': 2060, 'stop_loss': 2090, 'direction': 'short'},  # +2R
    ]
    
    from datetime import timedelta
    
    for i, trade in enumerate(sample_trades):
        entry_time = base_time + timedelta(days=i, hours=2)
        exit_time = entry_time + timedelta(hours=4)
        
        r = tracker.record_trade(
            entry_time=entry_time,
            exit_time=exit_time,
            **trade
        )
        print(f"Trade {i+1}: {r:+.2f}R")
    
    tracker.print_report()
    
    # Export to DataFrame
    df = tracker.to_dataframe()
    print("\nTrades DataFrame:")
    print(df[['entry_price', 'exit_price', 'stop_loss', 'pnl', 'r_multiple']].to_string())
