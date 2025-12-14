#!/usr/bin/env python3
"""
stress_framework.py - Stress testing framework for EA validation.

BATCH 5: Tests EA performance under extreme market conditions.

Stress Scenarios:
1. Flash Crash (sudden 5% drop)
2. Volatility Spike (3x normal ATR)
3. Liquidity Crisis (10x spread)
4. Trend Reversal (sudden direction change)
5. Gap Event (weekend gap > 1%)
6. News Spike (extreme volume + volatility)

Usage:
    python scripts/oracle/stress_framework.py \
        --trades data/trades.csv \
        --output DOCS/04_REPORTS/VALIDATION/STRESS_REPORT.md
"""

import argparse
import json
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np
import pandas as pd


@dataclass
class StressScenario:
    """Stress test scenario definition."""
    name: str
    description: str
    price_shock: float  # % price change
    volatility_mult: float  # Volatility multiplier
    spread_mult: float  # Spread multiplier
    duration_bars: int  # Duration in bars


class StressFramework:
    """
    Stress testing framework for trading strategies.
    """
    
    # Predefined scenarios
    SCENARIOS = {
        'flash_crash': StressScenario(
            name='Flash Crash',
            description='Sudden 5% price drop in minutes',
            price_shock=-5.0,
            volatility_mult=5.0,
            spread_mult=10.0,
            duration_bars=5
        ),
        'volatility_spike': StressScenario(
            name='Volatility Spike',
            description='3x normal volatility',
            price_shock=0,
            volatility_mult=3.0,
            spread_mult=3.0,
            duration_bars=50
        ),
        'liquidity_crisis': StressScenario(
            name='Liquidity Crisis',
            description='10x spread, no fills',
            price_shock=0,
            volatility_mult=2.0,
            spread_mult=10.0,
            duration_bars=20
        ),
        'trend_reversal': StressScenario(
            name='Trend Reversal',
            description='V-shaped reversal',
            price_shock=-3.0,
            volatility_mult=2.0,
            spread_mult=2.0,
            duration_bars=30
        ),
        'gap_event': StressScenario(
            name='Gap Event',
            description='Weekend gap > 1%',
            price_shock=-1.5,
            volatility_mult=1.5,
            spread_mult=5.0,
            duration_bars=1
        ),
        'news_spike': StressScenario(
            name='News Spike',
            description='NFP/FOMC level event',
            price_shock=2.0,
            volatility_mult=4.0,
            spread_mult=8.0,
            duration_bars=10
        )
    }
    
    def __init__(self):
        self.results: Dict[str, Dict] = {}
    
    def run_scenario(self, scenario_name: str, trades: pd.DataFrame,
                     account_balance: float = 100000) -> Dict:
        """
        Run a stress scenario against historical trades.
        
        Args:
            scenario_name: Name of scenario to run
            trades: DataFrame with trade history
            account_balance: Starting account balance
        
        Returns:
            Dict with scenario results
        """
        if scenario_name not in self.SCENARIOS:
            raise ValueError(f"Unknown scenario: {scenario_name}")
        
        scenario = self.SCENARIOS[scenario_name]
        
        # Simulate scenario impact on trades
        modified_trades = self._apply_scenario(trades, scenario)
        
        # Calculate metrics under stress
        metrics = self._calculate_stress_metrics(modified_trades, account_balance)
        
        result = {
            'scenario': scenario.name,
            'description': scenario.description,
            'price_shock': scenario.price_shock,
            'volatility_mult': scenario.volatility_mult,
            'spread_mult': scenario.spread_mult,
            'metrics': metrics,
            'passed': self._check_thresholds(metrics)
        }
        
        self.results[scenario_name] = result
        return result
    
    def _apply_scenario(self, trades: pd.DataFrame, 
                        scenario: StressScenario) -> pd.DataFrame:
        """Apply stress scenario to trades."""
        df = trades.copy()
        
        # Randomly select trades to be affected
        n_affected = max(1, int(len(df) * 0.1))  # 10% of trades
        affected_idx = np.random.choice(df.index, n_affected, replace=False)
        
        # Apply price shock
        if scenario.price_shock != 0:
            if 'pnl' in df.columns:
                shock_impact = scenario.price_shock / 100 * df.loc[affected_idx, 'lot_size'].fillna(1) * 1000
                df.loc[affected_idx, 'pnl'] -= shock_impact
        
        # Apply volatility/spread impact (increase losses, decrease wins)
        if scenario.spread_mult > 1:
            slippage_cost = (scenario.spread_mult - 1) * 0.5 * df.loc[affected_idx, 'lot_size'].fillna(1) * 10
            df.loc[affected_idx, 'pnl'] -= slippage_cost
        
        return df
    
    def _calculate_stress_metrics(self, trades: pd.DataFrame,
                                   account_balance: float) -> Dict:
        """Calculate key metrics under stress."""
        if trades.empty or 'pnl' not in trades.columns:
            return {'error': 'Invalid trades data'}
        
        pnls = trades['pnl'].values
        
        # Cumulative PnL
        cum_pnl = np.cumsum(pnls)
        equity_curve = account_balance + cum_pnl
        
        # Max drawdown
        running_max = np.maximum.accumulate(equity_curve)
        drawdowns = (running_max - equity_curve) / running_max * 100
        max_dd = np.max(drawdowns)
        
        # Daily drawdown (simulate)
        daily_chunks = np.array_split(pnls, max(1, len(pnls) // 20))
        daily_dds = []
        for chunk in daily_chunks:
            if len(chunk) > 0:
                chunk_cum = np.cumsum(chunk)
                chunk_max = np.maximum.accumulate(account_balance + chunk_cum)
                chunk_dd = (chunk_max - (account_balance + chunk_cum)) / chunk_max * 100
                daily_dds.append(np.max(chunk_dd))
        
        max_daily_dd = max(daily_dds) if daily_dds else 0
        
        return {
            'total_pnl': float(np.sum(pnls)),
            'max_dd_pct': float(max_dd),
            'max_daily_dd_pct': float(max_daily_dd),
            'win_rate': float(np.sum(pnls > 0) / len(pnls) * 100) if len(pnls) > 0 else 0,
            'profit_factor': float(np.sum(pnls[pnls > 0]) / abs(np.sum(pnls[pnls < 0]))) if np.sum(pnls[pnls < 0]) != 0 else 0,
            'final_equity': float(equity_curve[-1]) if len(equity_curve) > 0 else account_balance,
            'worst_trade': float(np.min(pnls)) if len(pnls) > 0 else 0
        }
    
    def _check_thresholds(self, metrics: Dict) -> bool:
        """Check if metrics pass stress thresholds."""
        # FTMO limits with safety buffer
        if metrics.get('max_daily_dd_pct', 100) > 4.5:  # 4.5% buffer for 5% limit
            return False
        if metrics.get('max_dd_pct', 100) > 9.0:  # 9% buffer for 10% limit
            return False
        if metrics.get('profit_factor', 0) < 0.8:  # Should stay profitable
            return False
        
        return True
    
    def run_all_scenarios(self, trades: pd.DataFrame,
                          account_balance: float = 100000) -> Dict:
        """Run all stress scenarios."""
        results = {}
        
        for scenario_name in self.SCENARIOS:
            results[scenario_name] = self.run_scenario(
                scenario_name, trades, account_balance
            )
        
        # Overall assessment
        all_passed = all(r['passed'] for r in results.values())
        critical_failures = [name for name, r in results.items() 
                            if not r['passed'] and name in ['flash_crash', 'liquidity_crisis']]
        
        return {
            'scenarios': results,
            'all_passed': all_passed,
            'critical_failures': critical_failures,
            'stress_ready': len(critical_failures) == 0
        }
    
    def generate_report(self, output_path: str):
        """Generate markdown stress test report."""
        lines = [
            "# STRESS TEST REPORT",
            f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "\n## Summary",
            ""
        ]
        
        all_passed = all(r.get('passed', False) for r in self.results.values())
        lines.append(f"**Overall Status**: {'PASSED' if all_passed else 'FAILED'}")
        lines.append("")
        
        lines.append("## Scenario Results")
        lines.append("")
        lines.append("| Scenario | Max DD | Daily DD | PF | Status |")
        lines.append("|----------|--------|----------|-----|--------|")
        
        for name, result in self.results.items():
            metrics = result.get('metrics', {})
            status = "PASS" if result.get('passed', False) else "FAIL"
            
            lines.append(f"| {result.get('scenario', name)} | "
                        f"{metrics.get('max_dd_pct', 0):.1f}% | "
                        f"{metrics.get('max_daily_dd_pct', 0):.1f}% | "
                        f"{metrics.get('profit_factor', 0):.2f} | "
                        f"{status} |")
        
        lines.append("")
        lines.append("## Thresholds")
        lines.append("")
        lines.append("- Max Daily DD: < 4.5% (FTMO 5% limit)")
        lines.append("- Max Total DD: < 9.0% (FTMO 10% limit)")
        lines.append("- Profit Factor: >= 0.8")
        
        report = "\n".join(lines)
        
        if output_path:
            Path(output_path).parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w') as f:
                f.write(report)
        
        return report


def main():
    parser = argparse.ArgumentParser(
        description='Stress testing framework for EA validation'
    )
    parser.add_argument('--trades', '-t', required=True,
                        help='Path to trades CSV')
    parser.add_argument('--output', '-o',
                        default='DOCS/04_REPORTS/VALIDATION/STRESS_REPORT.md',
                        help='Output report path')
    parser.add_argument('--balance', '-b', type=float, default=100000,
                        help='Account balance')
    
    args = parser.parse_args()
    
    # Load trades
    print(f"\nLoading trades from: {args.trades}")
    trades = pd.read_csv(args.trades)
    print(f"  Loaded {len(trades):,} trades")
    
    # Run stress tests
    framework = StressFramework()
    results = framework.run_all_scenarios(trades, args.balance)
    
    # Print summary
    print(f"\n{'='*50}")
    print("STRESS TEST SUMMARY")
    print(f"{'='*50}")
    print(f"All Passed: {results['all_passed']}")
    print(f"Critical Failures: {results['critical_failures']}")
    print(f"Stress Ready: {results['stress_ready']}")
    
    # Generate report
    report = framework.generate_report(args.output)
    print(f"\nReport saved to: {args.output}")
    
    return 0 if results['stress_ready'] else 1


if __name__ == '__main__':
    sys.exit(main())
