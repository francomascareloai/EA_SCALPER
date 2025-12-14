#!/usr/bin/env python3
"""
Test strategy across different periods to identify when it works
"""
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)

DATA_DIR = PROJECT_ROOT / "data" / "processed"

def test_period(data_path: str, max_ticks: int, description: str):
    """Test a specific period"""
    print(f"\n{'='*60}")
    print(f"  {description}")
    print(f"{'='*60}")
    
    config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_regime_filter=False,
        use_session_filter=True,
        session_start_hour=7,
        session_end_hour=21,
        use_ea_logic=False,
        bar_timeframe='5min',
        debug=False
    )
    
    try:
        bt = TickBacktester(config)
        raw_results = bt.run(str(data_path), max_ticks=max_ticks)
        metrics = raw_results.get('metrics', raw_results)
        
        n_trades = len(bt.trades) if bt.trades else 0
        pf = metrics.get('profit_factor', 0)
        wr = metrics.get('win_rate', 0)
        dd = metrics.get('max_drawdown', 0)
        ret = metrics.get('total_return', 0)
        
        print(f"\n  RESULT: {n_trades} trades, PF={pf:.2f}, WR={wr*100:.1f}%, DD={dd*100:.1f}%, Return={ret*100:.1f}%")
        
        # Show date range
        if bt.trades:
            first_trade = bt.trades[0].entry_time
            last_trade = bt.trades[-1].entry_time
            print(f"  Period: {first_trade} to {last_trade}")
            
        return {'trades': n_trades, 'pf': pf, 'wr': wr, 'dd': dd, 'return': ret}
    except Exception as e:
        print(f"  ERROR: {e}")
        return None


def main():
    print("="*70)
    print("  PERIOD COMPARISON TEST")
    print("="*70)
    
    data_2024 = DATA_DIR / "ticks_2024.parquet"
    
    # Test 1: 3M ticks (what previous session used - should match)
    test_period(str(data_2024), 3_000_000, "2024 - 3M ticks (end of year)")
    
    # Test 2: 5M ticks  
    test_period(str(data_2024), 5_000_000, "2024 - 5M ticks")
    
    # Test 3: 10M ticks
    test_period(str(data_2024), 10_000_000, "2024 - 10M ticks")
    
    # Test 4: 15M ticks (current full validation)
    test_period(str(data_2024), 15_000_000, "2024 - 15M ticks (full)")
    
    print("\n" + "="*70)
    print("  CONCLUSION: Strategy may only work in specific periods")
    print("="*70)


if __name__ == "__main__":
    main()
