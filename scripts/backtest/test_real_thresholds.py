#!/usr/bin/env python3
"""Quick test with FULL EA logic - with detailed diagnostic"""
import sys
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode, USE_FULL_EA_LOGIC
import numpy as np
import random

print("=" * 80)
print("BACKTEST WITH FULL EA LOGIC")
print("=" * 80)
print("USE_FULL_EA_LOGIC:", USE_FULL_EA_LOGIC)

data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"

config = BacktestConfig(
    execution_mode=ExecutionMode.PESSIMISTIC,
    initial_balance=100_000,
    use_ea_logic=True,
    bar_timeframe='5min',
    base_slippage_points=5.0,
    debug=True,  # Enable debug
)

random.seed(42)
np.random.seed(42)

bt = TickBacktester(config)
result = bt.run(data_path, max_ticks=2_000_000)
m = result['metrics']

print()
print("=" * 80)
print("RESULTS")
print("=" * 80)
print("  Trades:", m['total_trades'])

if m['total_trades'] > 0:
    print("  Win Rate:", f"{m['win_rate']:.1%}")
    print("  Profit Factor:", f"{m['profit_factor']:.2f}")
    print("  Max DD:", f"{m['max_drawdown']:.2%}")
    print("  Return:", f"{m['total_return']:.2%}")
else:
    print("  [!] NO TRADES")

# Gate blocks
if hasattr(bt.ea, 'ea_full'):
    gates = bt.ea.ea_full.get_gate_stats()
    print("\n  Gate blocks:")
    for gate, count in sorted(gates.items()):
        if count > 0:
            print(f"    {gate}: {count}")
    
    # Check thresholds
    ea = bt.ea.ea_full
    print("\n  EA Config:")
    print(f"    execution_threshold: {ea.execution_threshold}")
    print(f"    min_rr: {ea.min_rr}")
    print(f"    relaxed_mtf_gate: {ea.relaxed_mtf_gate}")
    print(f"    session allow_asian: {ea.session_filter.allow_asian}")
    print(f"    session allow_late_ny: {ea.session_filter.allow_late_ny}")

print("=" * 80)

# Run detailed diagnostic on a subset
print("\n" + "=" * 80)
print("DETAILED DIAGNOSTIC - First 500 bars")
print("=" * 80)

from scripts.backtest.tick_backtester import TickDataLoader, OHLCResampler, Indicators
from scripts.backtest.strategies.ea_logic_full import EALogicFull, SignalType

# Load and prepare data
ticks = TickDataLoader.load(data_path, max_ticks=500_000)
bars = OHLCResampler.resample(ticks, '5min')
htf = OHLCResampler.resample(ticks, '1h')
bars = Indicators.add_all(bars, config)

# Create fresh EA with same config
ea = EALogicFull(
    gmt_offset=0,
    allow_asian=True,
    allow_late_ny=True,
    relaxed_mtf_gate=True,
    require_ltf_confirm=False,
)
ea.execution_threshold = 65
ea.min_rr = 1.5

# Track reasons for rejection
rejection_reasons = {
    'total_evaluated': 0,
    'valid_signals': 0,
    'direction_none': 0,
    'score_low': 0,
    'rr_low': 0,
    'amd_low': 0,
    'other': 0,
}

# Calculate ATR for H1
htf['tr'] = (htf['high'] - htf['low']).combine(
    (htf['high'] - htf['close'].shift(1)).abs(), max
).combine(
    (htf['low'] - htf['close'].shift(1)).abs(), max
)
htf['atr'] = htf['tr'].rolling(14, min_periods=1).mean()

# Calculate RSI for bars
delta = bars['close'].diff()
gain = delta.where(delta > 0, 0).rolling(14, min_periods=1).mean()
loss = (-delta.where(delta < 0, 0)).rolling(14, min_periods=1).mean()
rs = gain / loss.replace(0, 1e-10)
bars['rsi'] = 100 - (100 / (1 + rs))

# Evaluate a sample of bars
sample_results = []
for idx in range(50, min(len(bars), 500)):
    timestamp = bars.index[idx]
    ltf_window = bars.iloc[max(0, idx-400):idx+1]
    htf_window = htf[htf.index <= timestamp]
    
    if len(htf_window) < 50:
        continue
    
    h1_closes = htf_window['close'].values
    h1_atr = float(htf_window['atr'].iloc[-1])
    m5_closes = ltf_window['close'].values
    m15_closes = m5_closes[::3]
    m15_highs = ltf_window['high'].values[::3]
    m15_lows = ltf_window['low'].values[::3]
    m5_rsi = float(ltf_window['rsi'].iloc[-1])
    price = float(ltf_window['close'].iloc[-1])
    spread = 30
    
    result = ea.analyze(
        h1_closes=h1_closes,
        m15_closes=m15_closes,
        m5_closes=m5_closes,
        m15_highs=m15_highs,
        m15_lows=m15_lows,
        h1_atr=h1_atr,
        m15_atr=h1_atr * 0.4,
        m5_rsi=m5_rsi,
        timestamp=timestamp,
        current_price=price,
        spread_points=spread,
        max_spread=100,
        balance=100_000,
        ltf_df=ltf_window,
    )
    
    rejection_reasons['total_evaluated'] += 1
    
    if result.is_valid and result.direction != SignalType.NONE:
        rejection_reasons['valid_signals'] += 1
        sample_results.append({
            'ts': timestamp,
            'dir': result.direction.name,
            'score': result.total_score,
            'rr': result.risk_reward,
        })
    else:
        if result.direction == SignalType.NONE:
            rejection_reasons['direction_none'] += 1
        elif result.total_score < 65:
            rejection_reasons['score_low'] += 1
        elif result.risk_reward < 1.5:
            rejection_reasons['rr_low'] += 1
        elif result.amd_score < 60:
            rejection_reasons['amd_low'] += 1
        else:
            rejection_reasons['other'] += 1

print("\nRejection Reasons:")
for reason, count in rejection_reasons.items():
    pct = 100 * count / max(1, rejection_reasons['total_evaluated'])
    print(f"  {reason}: {count} ({pct:.1f}%)")

print(f"\nGate Stats after eval:")
for gate, count in sorted(ea.get_gate_stats().items()):
    if count > 0:
        print(f"  {gate}: {count}")

if sample_results:
    print(f"\nSample valid signals ({len(sample_results)}):")
    for s in sample_results[:10]:
        print(f"  {s['ts']}: {s['dir']} score={s['score']:.1f} R:R={s['rr']:.2f}")

print("=" * 80)
