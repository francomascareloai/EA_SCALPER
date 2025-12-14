#!/usr/bin/env python3
"""
P1 Enhancement Comparison Test
==============================
Runs backtest with and without P1 modules to measure impact.

P1 Modules:
- FibonacciAnalyzer: Golden Pocket detection, Extension TPs
- AdaptiveKelly: DD-responsive position sizing
- SpreadAnalyzer: Smart spread awareness

Author: FORGE v3.1
Date: 2025-12-02
"""

import sys
import numpy as np
import pandas as pd
from pathlib import Path
from datetime import datetime, timedelta
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple
import warnings
warnings.filterwarnings('ignore')

# Add project paths
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
sys.path.insert(0, str(Path(__file__).parent / "strategies"))

# P1 Modules
from fibonacci_analyzer import FibonacciAnalyzer, FibAnalysisResult
from adaptive_kelly import AdaptiveKelly, KellySizingResult, KellyMode
from spread_analyzer import SpreadAnalyzer, SpreadAnalysisResult


@dataclass
class BacktestResult:
    """Backtest result summary."""
    name: str
    total_trades: int
    wins: int
    losses: int
    win_rate: float
    total_pnl: float
    max_dd: float
    profit_factor: float
    avg_win: float
    avg_loss: float
    expectancy: float
    sharpe: float
    trades_blocked: int = 0
    blocked_reason: str = ""


class SimpleBacktestEngine:
    """
    Simplified backtest engine for P1 comparison.
    Uses pre-computed signals to focus on P1 impact.
    """
    
    def __init__(self, initial_balance: float = 100_000.0, use_p1: bool = False):
        self.initial_balance = initial_balance
        self.balance = initial_balance
        self.peak_balance = initial_balance
        self.use_p1 = use_p1
        
        # P1 Components (only used when use_p1=True)
        if use_p1:
            self.fib_analyzer = FibonacciAnalyzer()
            self.kelly = AdaptiveKelly(
                mode=KellyMode.ADAPTIVE,
                min_trades_for_kelly=30,
                use_uncertainty=True,
                use_dd_adjustment=True,
                use_streak_adjustment=True
            )
            self.spread_analyzer = SpreadAnalyzer(
                history_size=1000,
                spike_threshold=1.5,
                max_allowed_spread=80,
                gmt_offset=0
            )
        
        # Trade tracking
        self.trades: List[Dict] = []
        self.equity_curve: List[float] = [initial_balance]
        self.max_dd = 0.0
        self.blocked_by_spread = 0
        self.blocked_by_dd = 0
    
    def _get_session(self, hour: int) -> str:
        """Get trading session from hour."""
        if 7 <= hour < 12:
            return 'LONDON'
        elif 12 <= hour < 17:
            return 'NEW_YORK'
        elif 2 <= hour < 7 or 17 <= hour < 20:
            return 'ASIAN'
        else:
            return 'OFF_HOURS'
    
    def _calculate_dd(self) -> float:
        """Calculate current drawdown %."""
        if self.peak_balance <= 0:
            return 0.0
        return (self.peak_balance - self.balance) / self.peak_balance * 100
    
    def run_trade(self, 
                  timestamp: datetime,
                  direction: str,  # 'BUY' or 'SELL'
                  entry_price: float,
                  sl_points: float,
                  tp_points: float,
                  atr: float,
                  spread: float,
                  highs: np.ndarray,
                  lows: np.ndarray,
                  outcome: str,  # 'WIN' or 'LOSS'
                  outcome_rr: float = 1.5) -> Optional[Dict]:
        """
        Process a single trade opportunity.
        Returns trade result or None if blocked.
        """
        
        # P1 Gate Checks
        if self.use_p1:
            # 1. Spread Check
            session = self._get_session(timestamp.hour)
            spread_result = self.spread_analyzer.analyze(spread, timestamp, sl_points)
            
            if not spread_result.allow_entry:
                self.blocked_by_spread += 1
                return None
            
            # 2. DD-Adaptive Position Sizing
            self.kelly.update_balance(self.balance)
            
            sizing = self.kelly.calculate_position_size(sl_points)
            
            if not sizing.is_trading_allowed:
                self.blocked_by_dd += 1
                return None
            
            risk_pct = sizing.risk_percent / 100.0 if sizing.risk_percent > 0 else 0.005
            
            # 3. Fibonacci TP Enhancement
            fib_result = self.fib_analyzer.analyze(highs, lows, entry_price, atr)
            
            # Use Fib extensions if in golden pocket
            if fib_result.in_golden_pocket and fib_result.tp1_fib > 0:
                if direction == 'BUY':
                    tp_enhanced = fib_result.tp1_fib - entry_price
                    if tp_enhanced > tp_points:
                        tp_points = tp_enhanced * 0.8  # 80% of 127.2% ext
                else:
                    tp_enhanced = entry_price - fib_result.tp1_fib
                    if tp_enhanced > tp_points:
                        tp_points = tp_enhanced * 0.8
        else:
            # Non-P1: Fixed 0.5% risk
            risk_pct = 0.005
        
        # Calculate position and P&L
        risk_amount = self.balance * risk_pct
        point_value = 1.0  # XAUUSD: $1 per point per lot
        lots = risk_amount / (sl_points * point_value * 100)  # Standard lot = 100 oz
        lots = min(lots, 5.0)  # Cap at 5 lots
        
        # Determine outcome
        if outcome == 'WIN':
            pnl = lots * tp_points * point_value * 100 * outcome_rr / 1.5  # Adjust for actual RR
        else:
            pnl = -lots * sl_points * point_value * 100
        
        # Update balance
        self.balance += pnl
        self.equity_curve.append(self.balance)
        
        if self.balance > self.peak_balance:
            self.peak_balance = self.balance
        
        current_dd = self._calculate_dd()
        if current_dd > self.max_dd:
            self.max_dd = current_dd
        
        trade = {
            'timestamp': timestamp,
            'direction': direction,
            'entry': entry_price,
            'sl_points': sl_points,
            'tp_points': tp_points,
            'lots': lots,
            'pnl': pnl,
            'outcome': outcome,
            'balance': self.balance,
            'dd': current_dd,
            'risk_pct': risk_pct * 100
        }
        
        self.trades.append(trade)
        
        # Update Kelly stats
        if self.use_p1:
            # Record as R-multiple (pnl / risk_amount)
            r_multiple = pnl / risk_amount if risk_amount > 0 else 0
            self.kelly.record_trade(r_multiple)
        
        return trade
    
    def get_results(self) -> BacktestResult:
        """Calculate final results."""
        if not self.trades:
            return BacktestResult(
                name="P1 ON" if self.use_p1 else "BASELINE",
                total_trades=0,
                wins=0,
                losses=0,
                win_rate=0,
                total_pnl=0,
                max_dd=0,
                profit_factor=0,
                avg_win=0,
                avg_loss=0,
                expectancy=0,
                sharpe=0
            )
        
        wins = [t for t in self.trades if t['pnl'] > 0]
        losses = [t for t in self.trades if t['pnl'] <= 0]
        
        total_win = sum(t['pnl'] for t in wins)
        total_loss = abs(sum(t['pnl'] for t in losses))
        
        avg_win = total_win / len(wins) if wins else 0
        avg_loss = total_loss / len(losses) if losses else 0
        
        win_rate = len(wins) / len(self.trades) * 100
        profit_factor = total_win / total_loss if total_loss > 0 else float('inf')
        
        # Expectancy in R
        expectancy = 0
        if losses:
            avg_r = avg_loss  # 1R = average loss
            expectancy = ((win_rate/100) * (avg_win/avg_r if avg_r > 0 else 0) - 
                         (1 - win_rate/100))
        
        # Sharpe (simplified)
        returns = [t['pnl'] / self.initial_balance for t in self.trades]
        sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252) if np.std(returns) > 0 else 0
        
        return BacktestResult(
            name="P1 ON" if self.use_p1 else "BASELINE",
            total_trades=len(self.trades),
            wins=len(wins),
            losses=len(losses),
            win_rate=win_rate,
            total_pnl=self.balance - self.initial_balance,
            max_dd=self.max_dd,
            profit_factor=profit_factor,
            avg_win=avg_win,
            avg_loss=avg_loss,
            expectancy=expectancy,
            sharpe=sharpe,
            trades_blocked=self.blocked_by_spread + self.blocked_by_dd,
            blocked_reason=f"Spread: {self.blocked_by_spread}, DD: {self.blocked_by_dd}"
        )


def generate_synthetic_trades(n_trades: int = 200, seed: int = 42) -> List[Dict]:
    """
    Generate synthetic trade scenarios for comparison.
    Based on typical XAUUSD scalping patterns.
    """
    np.random.seed(seed)
    
    trades = []
    base_price = 2650.0
    base_time = datetime(2025, 6, 1, 8, 0)  # Start at London open
    
    # Realistic win rate ~55%
    outcomes = np.random.choice(['WIN', 'LOSS'], size=n_trades, p=[0.55, 0.45])
    
    for i in range(n_trades):
        # Random hour (bias towards active sessions)
        hour = np.random.choice(
            list(range(24)),
            p=[0.01, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10, 0.10, 
               0.08, 0.07, 0.08, 0.07, 0.06, 0.05, 0.03, 0.02, 0.01, 0.01,
               0.01, 0.005, 0.005, 0.01]
        )
        
        timestamp = base_time + timedelta(hours=i*2, minutes=np.random.randint(0, 60))
        timestamp = timestamp.replace(hour=hour)
        
        # Price drift
        price = base_price + np.random.normal(0, 50) + np.sin(i/20) * 30
        
        # Direction
        direction = np.random.choice(['BUY', 'SELL'])
        
        # ATR typically 10-20 points for XAUUSD M5
        atr = np.random.uniform(10, 20)
        
        # SL/TP based on ATR
        sl_points = atr * np.random.uniform(1.5, 2.5)
        tp_points = sl_points * np.random.uniform(1.3, 2.0)  # 1.3-2.0 RR
        
        # Spread varies by session
        session_spread = {
            'LONDON': np.random.uniform(15, 35),
            'NEW_YORK': np.random.uniform(20, 40),
            'ASIAN': np.random.uniform(35, 60),
            'OFF_HOURS': np.random.uniform(50, 90)
        }
        
        if 7 <= hour < 12:
            session = 'LONDON'
        elif 12 <= hour < 17:
            session = 'NEW_YORK'
        elif 2 <= hour < 7 or 17 <= hour < 20:
            session = 'ASIAN'
        else:
            session = 'OFF_HOURS'
        
        spread = session_spread[session]
        
        # Generate fake swing data for Fibonacci
        swing_range = np.random.uniform(30, 80)
        swing_low = price - swing_range * np.random.uniform(0.3, 0.7)
        swing_high = price + swing_range * np.random.uniform(0.3, 0.7)
        
        highs = np.array([swing_high, swing_high * 0.998, swing_high * 0.995, 
                         price * 1.01, price * 1.005])
        lows = np.array([swing_low, swing_low * 1.002, swing_low * 1.005,
                        price * 0.99, price * 0.995])
        
        # Outcome RR (actual profit if win)
        outcome_rr = np.random.uniform(1.0, 2.0) if outcomes[i] == 'WIN' else 1.0
        
        trades.append({
            'timestamp': timestamp,
            'direction': direction,
            'entry_price': price,
            'sl_points': sl_points,
            'tp_points': tp_points,
            'atr': atr,
            'spread': spread,
            'highs': highs,
            'lows': lows,
            'outcome': outcomes[i],
            'outcome_rr': outcome_rr
        })
    
    return trades


def run_comparison(n_trades: int = 200, seed: int = 42):
    """Run comparison between baseline and P1-enhanced."""
    
    print("\n" + "=" * 70)
    print("    P1 ENHANCEMENT COMPARISON TEST")
    print("=" * 70)
    
    # Generate same trade scenarios
    print(f"\nGenerating {n_trades} synthetic trade scenarios...")
    trade_scenarios = generate_synthetic_trades(n_trades, seed)
    
    # Run baseline (no P1)
    print("\n[1/2] Running BASELINE (no P1)...")
    baseline = SimpleBacktestEngine(use_p1=False)
    
    for t in trade_scenarios:
        baseline.run_trade(
            timestamp=t['timestamp'],
            direction=t['direction'],
            entry_price=t['entry_price'],
            sl_points=t['sl_points'],
            tp_points=t['tp_points'],
            atr=t['atr'],
            spread=t['spread'],
            highs=t['highs'],
            lows=t['lows'],
            outcome=t['outcome'],
            outcome_rr=t['outcome_rr']
        )
    
    baseline_results = baseline.get_results()
    
    # Run with P1
    print("[2/2] Running WITH P1 (Fib + Kelly + Spread)...")
    p1_engine = SimpleBacktestEngine(use_p1=True)
    
    for t in trade_scenarios:
        p1_engine.run_trade(
            timestamp=t['timestamp'],
            direction=t['direction'],
            entry_price=t['entry_price'],
            sl_points=t['sl_points'],
            tp_points=t['tp_points'],
            atr=t['atr'],
            spread=t['spread'],
            highs=t['highs'],
            lows=t['lows'],
            outcome=t['outcome'],
            outcome_rr=t['outcome_rr']
        )
    
    p1_results = p1_engine.get_results()
    
    # Print comparison
    print("\n" + "=" * 70)
    print("    COMPARISON RESULTS")
    print("=" * 70)
    
    print(f"\n{'Metric':<25} {'BASELINE':>15} {'P1 ON':>15} {'DELTA':>15}")
    print("-" * 70)
    
    metrics = [
        ('Total Trades', baseline_results.total_trades, p1_results.total_trades, 
         p1_results.total_trades - baseline_results.total_trades),
        ('Wins', baseline_results.wins, p1_results.wins, 
         p1_results.wins - baseline_results.wins),
        ('Win Rate %', f"{baseline_results.win_rate:.1f}", f"{p1_results.win_rate:.1f}",
         f"{p1_results.win_rate - baseline_results.win_rate:+.1f}"),
        ('Total P&L $', f"{baseline_results.total_pnl:,.0f}", f"{p1_results.total_pnl:,.0f}",
         f"{p1_results.total_pnl - baseline_results.total_pnl:+,.0f}"),
        ('Max DD %', f"{baseline_results.max_dd:.1f}", f"{p1_results.max_dd:.1f}",
         f"{p1_results.max_dd - baseline_results.max_dd:+.1f}"),
        ('Profit Factor', f"{baseline_results.profit_factor:.2f}", f"{p1_results.profit_factor:.2f}",
         f"{p1_results.profit_factor - baseline_results.profit_factor:+.2f}"),
        ('Avg Win $', f"{baseline_results.avg_win:,.0f}", f"{p1_results.avg_win:,.0f}",
         f"{p1_results.avg_win - baseline_results.avg_win:+,.0f}"),
        ('Avg Loss $', f"{baseline_results.avg_loss:,.0f}", f"{p1_results.avg_loss:,.0f}",
         f"{baseline_results.avg_loss - p1_results.avg_loss:+,.0f}"),  # Lower is better
        ('Expectancy R', f"{baseline_results.expectancy:.2f}", f"{p1_results.expectancy:.2f}",
         f"{p1_results.expectancy - baseline_results.expectancy:+.2f}"),
        ('Sharpe', f"{baseline_results.sharpe:.2f}", f"{p1_results.sharpe:.2f}",
         f"{p1_results.sharpe - baseline_results.sharpe:+.2f}"),
    ]
    
    for metric, base_val, p1_val, delta in metrics:
        print(f"{metric:<25} {str(base_val):>15} {str(p1_val):>15} {str(delta):>15}")
    
    # P1 specific stats
    print("\n" + "-" * 70)
    print("P1 FILTER STATISTICS:")
    print(f"  Trades blocked by P1: {p1_results.trades_blocked}")
    print(f"  Breakdown: {p1_results.blocked_reason}")
    
    # Summary
    print("\n" + "=" * 70)
    pnl_improvement = p1_results.total_pnl - baseline_results.total_pnl
    dd_improvement = baseline_results.max_dd - p1_results.max_dd
    
    if pnl_improvement > 0 and dd_improvement >= 0:
        verdict = "P1 IMPROVES PERFORMANCE"
        emoji = "[OK]"
    elif pnl_improvement > 0 and dd_improvement < 0:
        verdict = "P1 INCREASES PROFIT BUT ALSO RISK"
        emoji = "[!]"
    elif pnl_improvement <= 0 and dd_improvement > 0:
        verdict = "P1 REDUCES RISK BUT ALSO PROFIT"
        emoji = "[?]"
    else:
        verdict = "P1 NEEDS ADJUSTMENT"
        emoji = "[X]"
    
    print(f"VERDICT: {emoji} {verdict}")
    print(f"  P&L Change: ${pnl_improvement:+,.0f}")
    print(f"  DD Change: {-dd_improvement:+.1f}% (negative is better)")
    print("=" * 70)
    
    return baseline_results, p1_results


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description='P1 Enhancement Comparison Test')
    parser.add_argument('--trades', type=int, default=200, help='Number of synthetic trades')
    parser.add_argument('--seed', type=int, default=42, help='Random seed')
    
    args = parser.parse_args()
    
    baseline, p1 = run_comparison(n_trades=args.trades, seed=args.seed)
    
    return 0 if p1.total_pnl >= baseline.total_pnl else 1


if __name__ == "__main__":
    sys.exit(main())
