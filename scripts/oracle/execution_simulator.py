"""
Execution Cost Simulator
========================

Simulates realistic execution costs for XAUUSD trading:
- Dynamic slippage based on market conditions
- Session-aware spread modeling
- Latency simulation with spikes
- Order rejection probability

For: EA_SCALPER_XAUUSD - ORACLE Validation v2.2

Usage:
    python -m scripts.oracle.execution_simulator --input trades.csv --mode pessimistic
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass, field
from typing import Dict, Tuple, Optional
from enum import Enum
import argparse


class MarketCondition(Enum):
    NORMAL = "normal"
    NEWS = "news"
    VOLATILE = "volatile"
    LOW_LIQUIDITY = "low_liquidity"
    ILLIQUID = "illiquid"


class SimulationMode(Enum):
    DEV = "dev"                # Optimistic - for development
    VALIDATION = "validation"  # Normal - for validation
    PESSIMISTIC = "pessimistic"  # Conservative - for FTMO
    STRESS = "stress"          # Extreme - for stress testing


@dataclass
class ExecutionConfig:
    """Configuration for execution simulation"""
    base_slippage: float = 3.0
    slippage_news_mult: float = 5.0
    slippage_volatile_mult: float = 2.0
    slippage_lowliq_mult: float = 1.5
    adverse_only: bool = False
    
    base_spread: float = 20.0
    spread_news_mult: float = 3.0
    spread_asian_mult: float = 2.0
    spread_volatile_mult: float = 2.0
    
    base_latency: int = 50
    news_latency: int = 200
    max_latency: int = 1000
    spike_probability: float = 0.05
    
    base_rejection_prob: float = 0.02
    news_rejection_mult: float = 3.0


# Predefined configurations
CONFIGS = {
    SimulationMode.DEV: ExecutionConfig(
        base_slippage=2.0,
        slippage_news_mult=3.0,
        adverse_only=False,
        base_spread=15.0,
        base_latency=30,
        spike_probability=0.02,
        base_rejection_prob=0.01
    ),
    SimulationMode.VALIDATION: ExecutionConfig(
        base_slippage=3.0,
        slippage_news_mult=5.0,
        adverse_only=False,
        base_spread=20.0,
        base_latency=50,
        spike_probability=0.05,
        base_rejection_prob=0.03
    ),
    SimulationMode.PESSIMISTIC: ExecutionConfig(
        base_slippage=5.0,
        slippage_news_mult=10.0,
        slippage_volatile_mult=3.0,
        adverse_only=True,
        base_spread=25.0,
        spread_news_mult=5.0,
        spread_asian_mult=3.0,
        base_latency=100,
        news_latency=500,
        max_latency=1500,
        spike_probability=0.15,
        base_rejection_prob=0.10
    ),
    SimulationMode.STRESS: ExecutionConfig(
        base_slippage=10.0,
        slippage_news_mult=20.0,
        slippage_volatile_mult=5.0,
        adverse_only=True,
        base_spread=40.0,
        spread_news_mult=10.0,
        spread_asian_mult=4.0,
        base_latency=200,
        news_latency=1000,
        max_latency=3000,
        spike_probability=0.30,
        base_rejection_prob=0.25
    )
}


@dataclass
class ExecutionResult:
    """Result of a single trade execution simulation"""
    original_price: float
    executed_price: float
    slippage_points: float
    spread_points: float
    latency_ms: int
    rejected: bool
    rejection_reason: str
    total_cost_points: float
    market_condition: str


@dataclass
class SimulationStats:
    """Aggregate statistics from simulation"""
    total_trades: int = 0
    rejected_trades: int = 0
    total_slippage: float = 0.0
    total_spread_cost: float = 0.0
    total_latency: int = 0
    by_condition: Dict = field(default_factory=dict)


class ExecutionSimulator:
    """
    Simulates realistic execution costs for trading strategies.
    
    Features:
    - Dynamic slippage based on market conditions
    - Session-aware spread (Asian, London, NY)
    - Latency with log-normal distribution + spikes
    - Order rejection simulation
    """
    
    def __init__(self, config: ExecutionConfig = None, mode: SimulationMode = None):
        if mode is not None:
            self.config = CONFIGS.get(mode, CONFIGS[SimulationMode.PESSIMISTIC])
        else:
            self.config = config or ExecutionConfig()
        
        self._rng = np.random.default_rng()
        self.stats = SimulationStats()
    
    def reset_stats(self):
        """Reset accumulated statistics"""
        self.stats = SimulationStats()
    
    def simulate_trade(
        self,
        price: float,
        is_buy: bool,
        condition: MarketCondition = MarketCondition.NORMAL,
        hour_utc: int = 12
    ) -> ExecutionResult:
        """
        Simulate execution of a single trade.
        
        Args:
            price: Requested price
            is_buy: True if buy order
            condition: Market condition
            hour_utc: Hour in UTC (for session-aware spread)
        
        Returns:
            ExecutionResult with all costs
        """
        self.stats.total_trades += 1
        
        # 1. Check rejection
        rejected, reason = self._simulate_rejection(condition)
        if rejected:
            self.stats.rejected_trades += 1
            return ExecutionResult(
                original_price=price,
                executed_price=0,
                slippage_points=0,
                spread_points=0,
                latency_ms=0,
                rejected=True,
                rejection_reason=reason,
                total_cost_points=0,
                market_condition=condition.value
            )
        
        # 2. Calculate slippage
        slippage = self._calculate_slippage(condition)
        
        # 3. Calculate spread
        spread = self._calculate_spread(condition, hour_utc)
        
        # 4. Calculate latency
        latency = self._simulate_latency(condition)
        
        # 5. Calculate executed price (slippage in points, 1 point = $0.01)
        if is_buy:
            executed_price = price + slippage * 0.01
        else:
            executed_price = price - slippage * 0.01
        
        # 6. Total cost
        total_cost = abs(slippage) + spread
        
        # Update stats
        self.stats.total_slippage += abs(slippage)
        self.stats.total_spread_cost += spread
        self.stats.total_latency += latency
        
        cond_key = condition.value
        if cond_key not in self.stats.by_condition:
            self.stats.by_condition[cond_key] = {'count': 0, 'cost': 0}
        self.stats.by_condition[cond_key]['count'] += 1
        self.stats.by_condition[cond_key]['cost'] += total_cost
        
        return ExecutionResult(
            original_price=price,
            executed_price=executed_price,
            slippage_points=slippage,
            spread_points=spread,
            latency_ms=latency,
            rejected=False,
            rejection_reason="",
            total_cost_points=total_cost,
            market_condition=condition.value
        )
    
    def _calculate_slippage(self, condition: MarketCondition) -> float:
        """Calculate slippage in points"""
        mult = self._get_condition_multiplier(
            condition,
            self.config.slippage_news_mult,
            self.config.slippage_volatile_mult,
            self.config.slippage_lowliq_mult
        )
        
        base = self.config.base_slippage * mult
        random_factor = self._rng.uniform(0.5, 1.5)
        slippage = base * random_factor
        
        if self.config.adverse_only:
            return slippage
        else:
            if self._rng.random() > 0.3:
                return slippage
            else:
                return -slippage * 0.3
    
    def _calculate_spread(self, condition: MarketCondition, hour_utc: int) -> float:
        """Calculate spread in points"""
        mult = self._get_condition_multiplier(
            condition,
            self.config.spread_news_mult,
            self.config.spread_volatile_mult,
            self.config.spread_asian_mult
        )
        
        # Session adjustment
        session_mult = 1.0
        if 0 <= hour_utc < 8:  # Asian
            session_mult = self.config.spread_asian_mult
        elif 7 <= hour_utc < 9:  # London open
            session_mult = 2.0
        elif 13 <= hour_utc < 14:  # NY open
            session_mult = 1.5
        
        base = self.config.base_spread * max(mult, session_mult)
        random_factor = self._rng.uniform(1.0, 1.3)
        
        return base * random_factor
    
    def _simulate_latency(self, condition: MarketCondition) -> int:
        """Simulate latency in ms"""
        base = self.config.base_latency
        
        if condition == MarketCondition.NEWS:
            base += self.config.news_latency
        
        if self._rng.random() < self.config.spike_probability:
            return int(self._rng.uniform(base * 2, self.config.max_latency))
        
        sigma = 0.4
        mu = np.log(base) - sigma**2 / 2
        latency = self._rng.lognormal(mu, sigma)
        
        return int(min(latency, self.config.max_latency))
    
    def _simulate_rejection(self, condition: MarketCondition) -> Tuple[bool, str]:
        """Simulate order rejection"""
        prob = self.config.base_rejection_prob
        
        if condition == MarketCondition.NEWS:
            prob *= self.config.news_rejection_mult
        elif condition == MarketCondition.ILLIQUID:
            prob *= 5.0
        elif condition == MarketCondition.VOLATILE:
            prob *= 2.0
        
        if self._rng.random() < prob:
            reasons = ["Requote", "Slippage exceeds limit", "Insufficient liquidity", "Timeout"]
            return True, self._rng.choice(reasons)
        
        return False, ""
    
    def _get_condition_multiplier(
        self, condition: MarketCondition, news: float, volatile: float, lowliq: float
    ) -> float:
        """Get multiplier based on market condition"""
        return {
            MarketCondition.NORMAL: 1.0,
            MarketCondition.NEWS: news,
            MarketCondition.VOLATILE: volatile,
            MarketCondition.LOW_LIQUIDITY: lowliq,
            MarketCondition.ILLIQUID: lowliq * 2
        }.get(condition, 1.0)
    
    def apply_to_trades(
        self,
        trades_df: pd.DataFrame,
        price_col: str = 'entry_price',
        direction_col: str = 'direction',
        condition_col: str = None,
        datetime_col: str = 'datetime'
    ) -> pd.DataFrame:
        """
        Apply execution costs to a DataFrame of trades.
        
        Args:
            trades_df: DataFrame with trades
            price_col: Column with entry price
            direction_col: Column with direction (LONG/SHORT or 1/-1)
            condition_col: Column with market condition (optional)
            datetime_col: Column with datetime (for hour extraction)
        
        Returns:
            DataFrame with additional cost columns
        """
        self.reset_stats()
        results = []
        
        for idx, row in trades_df.iterrows():
            price = row.get(price_col, 2000)  # Default XAUUSD price
            
            # Determine direction
            direction = row.get(direction_col, 'LONG')
            is_buy = str(direction).upper() in ['LONG', 'BUY', '1', 1]
            
            # Determine condition
            if condition_col and condition_col in trades_df.columns:
                cond_str = str(row[condition_col]).lower()
                try:
                    condition = MarketCondition(cond_str)
                except ValueError:
                    condition = MarketCondition.NORMAL
            else:
                condition = MarketCondition.NORMAL
            
            # Get hour for session-aware spread
            hour = 12
            if datetime_col in trades_df.columns:
                try:
                    hour = pd.to_datetime(row[datetime_col]).hour
                except:
                    pass
            
            result = self.simulate_trade(price, is_buy, condition, hour)
            
            results.append({
                'exec_price': result.executed_price,
                'slippage_pts': result.slippage_points,
                'spread_pts': result.spread_points,
                'latency_ms': result.latency_ms,
                'rejected': result.rejected,
                'total_cost_pts': result.total_cost_points
            })
        
        result_df = pd.DataFrame(results, index=trades_df.index)
        return pd.concat([trades_df, result_df], axis=1)
    
    def get_statistics(self) -> Dict:
        """Get accumulated statistics"""
        n = self.stats.total_trades
        if n == 0:
            return {}
        
        return {
            'total_trades': n,
            'rejected_trades': self.stats.rejected_trades,
            'rejection_rate': self.stats.rejected_trades / n * 100,
            'avg_slippage': self.stats.total_slippage / n,
            'avg_spread': self.stats.total_spread_cost / n,
            'avg_latency_ms': self.stats.total_latency / n,
            'total_cost_points': self.stats.total_slippage + self.stats.total_spread_cost,
            'avg_cost_per_trade': (self.stats.total_slippage + self.stats.total_spread_cost) / n,
            'by_condition': self.stats.by_condition
        }
    
    def generate_report(self) -> str:
        """Generate text report"""
        stats = self.get_statistics()
        if not stats:
            return "No trades simulated yet."
        
        lines = [
            "=" * 60,
            "EXECUTION COST SIMULATION REPORT",
            "=" * 60,
            f"Total Trades: {stats['total_trades']}",
            f"Rejected: {stats['rejected_trades']} ({stats['rejection_rate']:.1f}%)",
            "-" * 60,
            "AVERAGE COSTS PER TRADE:",
            f"  Slippage: {stats['avg_slippage']:.2f} points",
            f"  Spread: {stats['avg_spread']:.2f} points",
            f"  Total: {stats['avg_cost_per_trade']:.2f} points",
            f"  Latency: {stats['avg_latency_ms']:.0f} ms",
            "-" * 60,
        ]
        
        if stats['by_condition']:
            lines.append("COSTS BY MARKET CONDITION:")
            for cond, data in stats['by_condition'].items():
                avg = data['cost'] / data['count'] if data['count'] > 0 else 0
                lines.append(f"  {cond}: {data['count']} trades, avg {avg:.2f} pts/trade")
        
        lines.append("=" * 60)
        return "\n".join(lines)


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='Execution Cost Simulator')
    parser.add_argument('--input', '-i', required=True, help='CSV file with trades')
    parser.add_argument('--output', '-o', help='Output CSV file')
    parser.add_argument('--mode', '-m', choices=['dev', 'validation', 'pessimistic', 'stress'],
                        default='pessimistic', help='Simulation mode')
    parser.add_argument('--price-col', default='entry_price', help='Price column')
    parser.add_argument('--direction-col', default='direction', help='Direction column')
    
    args = parser.parse_args()
    
    # Load data
    df = pd.read_csv(args.input)
    
    # Create simulator
    mode = SimulationMode(args.mode)
    sim = ExecutionSimulator(mode=mode)
    
    # Apply costs
    result_df = sim.apply_to_trades(
        df,
        price_col=args.price_col,
        direction_col=args.direction_col
    )
    
    # Print report
    print(sim.generate_report())
    
    # Save if output specified
    if args.output:
        result_df.to_csv(args.output, index=False)
        print(f"\nSaved to {args.output}")
    
    # Print impact summary
    if 'profit' in df.columns or 'pnl' in df.columns:
        profit_col = 'profit' if 'profit' in df.columns else 'pnl'
        original_pnl = df[profit_col].sum()
        cost_per_trade = sim.get_statistics()['avg_cost_per_trade']
        # Assuming $10/point for XAUUSD with 1 lot
        total_cost_usd = cost_per_trade * len(df) * 0.1  # Approximate
        
        print(f"\nIMPACT ANALYSIS:")
        print(f"  Original PnL: ${original_pnl:,.2f}")
        print(f"  Estimated Execution Costs: ${total_cost_usd:,.2f}")
        print(f"  Net PnL: ${original_pnl - total_cost_usd:,.2f}")


if __name__ == '__main__':
    main()
