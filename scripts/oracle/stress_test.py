#!/usr/bin/env python3
"""
STRESS TEST - Reality Check with Adverse Conditions
====================================================
Tests strategy under realistic and worst-case scenarios:

1. HIGH SLIPPAGE: 2-5 pips per trade (realistic for scalping)
2. WIDE SPREADS: 1.5-3x normal (news/low liquidity)
3. DEGRADED WIN RATE: Simulate 10-20% worse execution
4. RANDOM SIGNAL NOISE: 10% of signals randomly flipped
5. CORRELATION WITH LOSING STREAKS: Simulate market regimes

A strategy that survives stress test is more likely to work live.

Author: ORACLE (Genius Mode)
Date: 2025-12-02
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

import numpy as np
import pandas as pd
from datetime import datetime, timezone
from dataclasses import dataclass
from typing import List, Dict, Optional
from scipy import stats
import warnings
warnings.filterwarnings('ignore')


@dataclass
class StressConfig:
    """Stress test configuration"""
    # Slippage scenarios
    slippage_normal_pips: float = 1.0      # Normal conditions
    slippage_stress_pips: float = 3.0      # Stress conditions (news)
    slippage_extreme_pips: float = 5.0     # Extreme (flash crash)
    
    # Spread scenarios
    spread_mult_normal: float = 1.0        # Normal
    spread_mult_stress: float = 2.0        # High volatility
    spread_mult_extreme: float = 3.0       # Crisis
    
    # Execution degradation
    signal_noise_rate: float = 0.10        # 10% of signals randomly wrong
    execution_failure_rate: float = 0.05   # 5% of trades fail to execute
    adverse_fill_rate: float = 0.20        # 20% of fills are adverse
    
    # Loss streaks
    max_consecutive_losses: int = 10       # Force losing streak
    losing_streak_every_n: int = 50        # Every N trades
    
    # Reality check
    min_realistic_wr: float = 0.55         # Max realistic WR for scalping
    max_realistic_sharpe: float = 3.0      # Max realistic Sharpe


class StressTester:
    """Stress test with adverse conditions"""
    
    def __init__(self, config: StressConfig = None):
        self.config = config or StressConfig()
    
    def degrade_trades(self, trades: List[Dict], scenario: str = 'normal') -> List[Dict]:
        """
        Degrade trades to simulate real-world conditions.
        
        Scenarios:
        - 'normal': Moderate degradation
        - 'stress': High degradation
        - 'extreme': Maximum adversity
        """
        if not trades:
            return []
        
        # Select parameters based on scenario
        if scenario == 'extreme':
            slippage = self.config.slippage_extreme_pips
            spread_mult = self.config.spread_mult_extreme
            noise_rate = self.config.signal_noise_rate * 2
            adverse_rate = self.config.adverse_fill_rate * 2
        elif scenario == 'stress':
            slippage = self.config.slippage_stress_pips
            spread_mult = self.config.spread_mult_stress
            noise_rate = self.config.signal_noise_rate * 1.5
            adverse_rate = self.config.adverse_fill_rate * 1.5
        else:  # normal
            slippage = self.config.slippage_normal_pips
            spread_mult = self.config.spread_mult_normal
            noise_rate = self.config.signal_noise_rate
            adverse_rate = self.config.adverse_fill_rate
        
        degraded = []
        
        for i, trade in enumerate(trades):
            new_trade = trade.copy()
            pnl = trade['pnl']
            
            # 1. Add random slippage (always negative impact)
            slippage_impact = slippage * np.random.uniform(0.5, 1.5) * 0.01 * 100  # Convert to $
            pnl -= slippage_impact
            
            # 2. Spread widening impact
            spread_cost = (spread_mult - 1.0) * 0.5 * 100  # Extra spread cost
            pnl -= spread_cost
            
            # 3. Random signal noise (flip some winners to losers)
            if np.random.random() < noise_rate:
                if pnl > 0:
                    pnl = -abs(pnl) * np.random.uniform(0.5, 1.0)  # Flip to loss
            
            # 4. Adverse fills on winners
            if pnl > 0 and np.random.random() < adverse_rate:
                pnl *= np.random.uniform(0.5, 0.8)  # Reduce winner
            
            # 5. Worse fills on losers
            if pnl < 0 and np.random.random() < adverse_rate:
                pnl *= np.random.uniform(1.1, 1.3)  # Increase loss
            
            # 6. Force losing streaks periodically
            if (i + 1) % self.config.losing_streak_every_n == 0:
                # Start a losing streak
                streak_trades = trades[i:i+self.config.max_consecutive_losses]
                for j, st in enumerate(streak_trades):
                    if j < len(degraded) - i:
                        continue
                    if st['pnl'] > 0:
                        degraded[-1]['pnl'] = -abs(st['pnl']) * np.random.uniform(0.8, 1.2)
            
            new_trade['pnl'] = pnl
            degraded.append(new_trade)
        
        return degraded
    
    def calculate_metrics(self, trades: List[Dict]) -> Dict:
        """Calculate metrics from degraded trades"""
        if not trades:
            return {'error': 'No trades'}
        
        pnls = [t['pnl'] for t in trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        total_trades = len(trades)
        win_rate = len(wins) / total_trades if total_trades > 0 else 0
        
        gross_profit = sum(wins) if wins else 0
        gross_loss = abs(sum(losses)) if losses else 1
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else 0
        
        # Daily returns for Sharpe
        daily_pnls = {}
        for t in trades:
            day = t.get('exit_time', datetime.now())
            if hasattr(day, 'date'):
                day = day.date()
            if day not in daily_pnls:
                daily_pnls[day] = 0
            daily_pnls[day] += t['pnl']
        
        daily_returns = np.array(list(daily_pnls.values())) / 100000
        sharpe = 0
        if len(daily_returns) > 1 and np.std(daily_returns) > 0:
            sharpe = np.mean(daily_returns) / np.std(daily_returns) * np.sqrt(252)
        
        # Max DD
        cumsum = np.cumsum(pnls)
        running_max = np.maximum.accumulate(cumsum)
        dd = running_max - cumsum
        max_dd = np.max(dd) / 100000 if len(dd) > 0 else 0
        
        # Total return
        final_balance = 100000 + sum(pnls)
        total_return = (final_balance - 100000) / 100000
        
        return {
            'total_trades': total_trades,
            'win_rate': win_rate,
            'profit_factor': profit_factor,
            'sharpe': sharpe,
            'max_dd': max_dd,
            'total_return': total_return,
            'final_balance': final_balance,
            'avg_win': np.mean(wins) if wins else 0,
            'avg_loss': np.mean(losses) if losses else 0
        }
    
    def reality_check(self, metrics: Dict) -> List[str]:
        """Check if metrics are realistic"""
        issues = []
        
        if metrics.get('win_rate', 0) > self.config.min_realistic_wr:
            issues.append(f"Win rate {metrics['win_rate']*100:.1f}% too high (max realistic: {self.config.min_realistic_wr*100:.0f}%)")
        
        if metrics.get('sharpe', 0) > self.config.max_realistic_sharpe:
            issues.append(f"Sharpe {metrics['sharpe']:.2f} too high (max realistic: {self.config.max_realistic_sharpe})")
        
        if metrics.get('profit_factor', 0) > 3.0:
            issues.append(f"PF {metrics['profit_factor']:.2f} too high (max realistic: 3.0)")
        
        return issues


def run_stress_test(data_path: str, max_ticks: int = 50_000_000) -> Dict:
    """Run complete stress test suite"""
    from scripts.backtest.tick_backtester import TickDataLoader, OHLCResampler
    from scripts.oracle.rigorous_validator import NoLookAheadBacktester, ValidationConfig
    
    print("="*70)
    print("       STRESS TEST - Reality Check")
    print("="*70)
    
    # Load data
    print("\n[1/4] Loading data...")
    ticks = TickDataLoader.load(data_path, max_ticks)
    bars = OHLCResampler.resample(ticks, '15min')
    print(f"  Bars: {len(bars)}")
    
    # Run baseline backtest
    print("\n[2/4] Running baseline backtest...")
    bt = NoLookAheadBacktester(ValidationConfig())
    baseline = bt.run(bars, {'threshold': 50})
    baseline_metrics = {
        'total_trades': baseline['total_trades'],
        'win_rate': baseline['win_rate'],
        'profit_factor': baseline['profit_factor'],
        'sharpe': baseline['sharpe'],
        'max_dd': baseline['max_dd'],
        'total_return': baseline['total_return']
    }
    print(f"  Baseline: {baseline['total_trades']} trades, WR {baseline['win_rate']*100:.1f}%, PF {baseline['profit_factor']:.2f}")
    
    # Stress test
    print("\n[3/4] Running stress scenarios...")
    stress = StressTester(StressConfig())
    
    scenarios = {
        'normal': stress.degrade_trades(baseline['trades'], 'normal'),
        'stress': stress.degrade_trades(baseline['trades'], 'stress'),
        'extreme': stress.degrade_trades(baseline['trades'], 'extreme')
    }
    
    results = {'baseline': baseline_metrics}
    
    for name, degraded in scenarios.items():
        metrics = stress.calculate_metrics(degraded)
        results[name] = metrics
        print(f"  {name.upper()}: WR {metrics['win_rate']*100:.1f}%, PF {metrics['profit_factor']:.2f}, Sharpe {metrics['sharpe']:.2f}, Return {metrics['total_return']*100:.1f}%")
    
    # Reality check
    print("\n[4/4] Reality Check...")
    for name in ['baseline', 'normal', 'stress', 'extreme']:
        issues = stress.reality_check(results[name])
        if issues:
            print(f"  {name.upper()} Issues:")
            for issue in issues:
                print(f"    - {issue}")
        else:
            print(f"  {name.upper()}: REALISTIC")
    
    # Summary
    print("\n" + "="*70)
    print("       STRESS TEST SUMMARY")
    print("="*70)
    
    print(f"\n{'Scenario':<12} {'Trades':<8} {'WR':<8} {'PF':<8} {'Sharpe':<8} {'Max DD':<10} {'Return':<10}")
    print("-"*70)
    for name in ['baseline', 'normal', 'stress', 'extreme']:
        m = results[name]
        print(f"{name:<12} {m['total_trades']:<8} {m['win_rate']*100:<8.1f}% {m['profit_factor']:<8.2f} {m['sharpe']:<8.2f} {m['max_dd']*100:<10.2f}% {m['total_return']*100:<10.1f}%")
    
    # GO/NO-GO
    print("\n" + "-"*70)
    
    # Strategy passes if it's profitable even in extreme scenario
    extreme = results['extreme']
    if extreme['profit_factor'] > 1.0 and extreme['total_return'] > 0:
        # Additional check: realistic metrics in stress scenario
        stress_issues = stress.reality_check(results['stress'])
        if len(stress_issues) <= 1:  # Allow 1 minor issue
            print("VERDICT: [CONDITIONAL GO] - Profitable under stress but metrics may be optimistic")
        else:
            print("VERDICT: [CAUTION] - Profitable but unrealistic metrics suggest overfitting")
    else:
        print("VERDICT: [NO-GO] - Strategy fails under extreme conditions")
    
    print("="*70)
    
    return results


if __name__ == "__main__":
    results = run_stress_test(
        'data/processed/ticks_2024.parquet',
        max_ticks=56_000_000
    )
