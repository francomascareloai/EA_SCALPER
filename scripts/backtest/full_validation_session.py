#!/usr/bin/env python3
"""
Full Validation for SESSION_ONLY config
- Backtest with 2024 data
- Monte Carlo 5000 runs
- Cross-year validation (2023 train, 2024 test)
"""
import sys
import numpy as np
import pandas as pd
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode
from scripts.oracle.monte_carlo import BlockBootstrapMC

print("=" * 80)
print("    FULL VALIDATION: SESSION_ONLY CONFIGURATION")
print("=" * 80)

# Configuration - WITH EA PARITY LOGIC
config = BacktestConfig(
    execution_mode=ExecutionMode.PESSIMISTIC,
    initial_balance=100_000,
    risk_per_trade=0.005,
    use_regime_filter=False,
    use_session_filter=True,
    session_start_hour=8,
    session_end_hour=20,
    bar_timeframe='5min',
    use_ea_logic=True,  # CRITICAL: Enable full EA parity
    debug=False
)

# =====================================================
# PHASE 1: BACKTEST 2024
# =====================================================
print("\n" + "=" * 40)
print("[PHASE 1] BACKTEST 2024 DATA")
print("=" * 40)

bt = TickBacktester(config)
result_2024 = bt.run('C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet', 
                     max_ticks=15000000)

m = result_2024['metrics']
print(f"\n2024 Results:")
print(f"  Trades: {m['total_trades']}")
print(f"  Win Rate: {m['win_rate']:.1%}")
print(f"  Profit Factor: {m['profit_factor']:.2f}")
print(f"  Sharpe: {m['sharpe_ratio']:.2f}")
print(f"  Max DD: {m['max_drawdown']:.2%}")
print(f"  Return: {m['total_return']:.2%}")

# =====================================================
# PHASE 2: MONTE CARLO
# =====================================================
print("\n" + "=" * 40)
print("[PHASE 2] MONTE CARLO (5000 runs)")
print("=" * 40)

trades = bt.trades
if trades and len(trades) >= 20:
    # Handle both dict and Trade objects
    if hasattr(trades[0], 'pnl'):
        trades_df = pd.DataFrame([{'profit': t.pnl} for t in trades])
    else:
        trades_df = pd.DataFrame([{'profit': t.get('pnl', 0)} for t in trades])
    
    mc = BlockBootstrapMC(n_simulations=5000, initial_capital=100000)
    mc_result = mc.run(trades_df, use_block=True)
    
    print(f"\nMonte Carlo Results:")
    print(f"  DD 5th percentile: {mc_result.dd_5th:.1f}%")
    print(f"  DD 50th percentile: {mc_result.dd_50th:.1f}%")
    print(f"  DD 95th percentile: {mc_result.dd_95th:.1f}%")
    print(f"  DD 99th percentile: {mc_result.dd_99th:.1f}%")
    print(f"  P(Profit > 0): {mc_result.prob_profit:.1f}%")
    print(f"  P(FTMO Daily Violation): {mc_result.ftmo_daily_violation_prob:.1f}%")
    print(f"  P(FTMO Total Violation): {mc_result.ftmo_total_violation_prob:.1f}%")
    print(f"  Confidence Score: {mc_result.confidence_score}/100")
    print(f"  FTMO Verdict: {mc_result.ftmo_verdict}")
else:
    print("  [SKIP] Not enough trades for Monte Carlo")
    mc_result = None

# =====================================================
# PHASE 3: CROSS-YEAR VALIDATION
# =====================================================
print("\n" + "=" * 40)
print("[PHASE 3] CROSS-YEAR (Train 2023, Test 2024)")
print("=" * 40)

# Train on 2023
print("\nTraining on 2023...")
bt_train = TickBacktester(config)
result_2023 = bt_train.run('C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2023.parquet', 
                           max_ticks=15000000)

# Test on 2024 (already have from Phase 1)
train_return = result_2023['metrics']['total_return']
test_return = m['total_return']

# WFE calculation
if train_return != 0:
    wfe = test_return / train_return
    wfe = np.clip(wfe, -2, 2)
else:
    wfe = 0 if test_return == 0 else 1

print(f"\nCross-Year Results:")
print(f"  2023 Trades: {result_2023['metrics']['total_trades']}")
print(f"  2023 Return: {train_return:.2%}")
print(f"  2023 Sharpe: {result_2023['metrics']['sharpe_ratio']:.2f}")
print(f"  2024 Trades: {m['total_trades']}")
print(f"  2024 Return: {test_return:.2%}")
print(f"  2024 Sharpe: {m['sharpe_ratio']:.2f}")
print(f"  WFE: {wfe:.2f}")

if wfe >= 0.6:
    wfe_status = "APPROVED"
elif wfe >= 0.4:
    wfe_status = "MARGINAL"
else:
    wfe_status = "REJECTED"
print(f"  WFE Status: {wfe_status}")

# =====================================================
# FINAL VERDICT
# =====================================================
print("\n" + "=" * 80)
print("                    FINAL VERDICT")
print("=" * 80)

# Score calculation
score = 0

# Backtest score (40 points)
bt_score = 0
if m['total_trades'] >= 50:
    bt_score += 10
if m['profit_factor'] >= 1.0:
    bt_score += 10
if m['sharpe_ratio'] > 0:
    bt_score += 10
if m['max_drawdown'] < 0.10:
    bt_score += 10
score += bt_score

# Monte Carlo score (30 points)
mc_score = 0
if mc_result:
    if mc_result.dd_95th < 15:
        mc_score += 10
    if mc_result.prob_profit > 50:
        mc_score += 10
    if mc_result.ftmo_total_violation_prob < 30:
        mc_score += 10
score += mc_score

# Cross-year score (30 points)
cy_score = 0
if wfe >= 0.6:
    cy_score = 30
elif wfe >= 0.4:
    cy_score = 20
elif wfe >= 0.2:
    cy_score = 10
score += cy_score

print(f"\nConfiguration: SESSION_ONLY")
print(f"\nScore Breakdown:")
print(f"  Backtest:    {bt_score}/40")
print(f"  Monte Carlo: {mc_score}/30")
print(f"  Cross-Year:  {cy_score}/30")
print(f"  TOTAL:       {score}/100")

if score >= 80:
    verdict = "GO - Ready for live trading"
elif score >= 60:
    verdict = "CONDITIONAL GO - Monitor closely"
elif score >= 40:
    verdict = "NO-GO - Needs optimization"
else:
    verdict = "REJECT - Strategy not viable"

print(f"\nVERDICT: {verdict}")
print("=" * 80)
