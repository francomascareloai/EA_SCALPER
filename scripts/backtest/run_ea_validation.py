#!/usr/bin/env python3
"""Quick EA validation with tick backtester"""
import sys
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode

# Test configurations
configs = [
    ("BASELINE", False, False),
    ("REGIME_ONLY", True, False),
    ("SESSION_ONLY", False, True),
    ("REG+SESSION", True, True),
]

print("=" * 80)
print("           EA PARITY TICK BACKTESTER - FILTER COMPARISON")
print("=" * 80)

results = []
for name, use_regime, use_session in configs:
    print(f"\nTesting: {name}")
    
    config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_regime_filter=use_regime,
        hurst_threshold=0.55,
        use_session_filter=use_session,
        session_start_hour=8,
        session_end_hour=20,
        bar_timeframe='5min',
        debug=False
    )
    
    bt = TickBacktester(config)
    result = bt.run('C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet', 
                    max_ticks=10000000)
    
    m = result['metrics']
    results.append((name, m))

# Summary
print("\n" + "=" * 100)
print("                              SUMMARY")
print("=" * 100)
print(f"{'Config':<15} {'Trades':>8} {'WR':>8} {'PF':>8} {'Sharpe':>10} {'MaxDD':>8} {'Return':>10}")
print("-" * 100)

for name, m in results:
    print(f"{name:<15} {m['total_trades']:>8} {m['win_rate']:>7.1%} "
          f"{m['profit_factor']:>8.2f} {m['sharpe_ratio']:>10.2f} "
          f"{m['max_drawdown']:>7.2%} {m['total_return']:>9.2%}")

print("=" * 100)
