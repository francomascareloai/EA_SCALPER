#!/usr/bin/env python3
"""Test EA logic on a single sample from tick_backtester data."""

import sys
from pathlib import Path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

import numpy as np
import pandas as pd
import pyarrow.parquet as pq
import pyarrow as pa
from datetime import datetime

from scripts.backtest.strategies.ea_logic_python import (
    EALogic, EAConfig, MarketRegime
)

# Load same way as tick_backtester
data_path = project_root / "data" / "processed" / "ticks_2024.parquet"
pf = pq.ParquetFile(str(data_path))

# Read last row groups
tables = []
max_ticks = 10_000_000
rows = 0
for rg in reversed(range(pf.num_row_groups)):
    t = pf.read_row_group(rg)
    tables.append(t)
    rows += t.num_rows
    if rows >= max_ticks:
        break
tables.reverse()
table = pa.concat_tables(tables)
if table.num_rows > max_ticks:
    start = table.num_rows - max_ticks
    table = table.slice(start, max_ticks)
df = table.to_pandas()

# Process same as tick_backtester
df['datetime'] = pd.to_datetime(df['timestamp'])
df['mid'] = (df['bid'] + df['ask']) / 2
df['spread'] = df['ask'] - df['bid']
df.set_index('datetime', inplace=True)
df.sort_index(inplace=True)

# Resample
bars = df['mid'].resample('15min').ohlc()
bars.columns = ['open', 'high', 'low', 'close']
bars['spread'] = df['spread'].resample('15min').mean()
bars = bars.dropna()

h1_bars = df['mid'].resample('1h').ohlc()
h1_bars.columns = ['open', 'high', 'low', 'close']
h1_bars = h1_bars.dropna()

print(f"M15 bars: {len(bars)}")
print(f"H1 bars: {len(h1_bars)}")

# Create EA with relaxed config (same as tick_backtester)
ea_cfg = EAConfig(
    execution_threshold=50.0,
    confluence_min_score=50.0,
    min_rr=1.0,
    max_spread_points=120.0,
    use_ml=False,
    use_fib_filter=False,
    ob_displacement_mult=1.5,
    fvg_min_gap=0.2,
)
ea = EALogic(ea_cfg, initial_balance=100000)

# Test on bar 2000 (should have 501 bars history)
idx = 2000
eval_window = 500

start = max(0, idx - eval_window)
ltf_window = bars.iloc[start:idx+1].copy()
timestamp = bars.index[idx]

print(f"\nTest at bar {idx}:")
print(f"  Timestamp: {timestamp}")
print(f"  Window bars: {len(ltf_window)}")
print(f"  Spread: {ltf_window['spread'].iloc[-1]:.4f}")

# Step-by-step debugging
print(f"\n[Checking filters...]")

# 1. Spread
raw_spread = float(ltf_window['spread'].iloc[-1])
spread_points = raw_spread if raw_spread > 5 else raw_spread / 0.01
print(f"  Spread points: {spread_points:.1f} (max: {ea_cfg.max_spread_points})")
if spread_points > ea_cfg.max_spread_points:
    print("  BLOCKED BY: Spread")
else:
    print("  Spread: OK")

# 2. Risk manager
if not ea.risk.can_open(timestamp):
    print("  BLOCKED BY: Risk Manager")
else:
    print("  Risk: OK")

# 3. Session
session_ok, session_name = ea.session.is_allowed(timestamp)
print(f"  Session: {session_name}, allowed={session_ok}")

# 4. News (empty in backtest)
print("  News: OK (no events)")

# 5. Regime
regime = ea.regime.analyze(ltf_window['close'].values)
print(f"  Regime: {regime.regime.name} (conf={regime.confidence:.1f})")
if regime.regime in (MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN):
    print("  BLOCKED BY: Regime")
else:
    print("  Regime: OK")

# 6. Manual confluence calculation to see scores
print(f"\n[Manual confluence calculation...]")
from scripts.backtest.strategies.ea_logic_python import (
    _swing_bias, detect_order_blocks, detect_fvg, liquidity_sweep, amd_phase,
    proximity_score, SignalType
)

ltf_df = ltf_window.copy()
ltf_df["tr"] = (ltf_df["high"] - ltf_df["low"]).combine(
    ltf_df["high"]-ltf_df["close"].shift(1), max
).combine(ltf_df["low"]-ltf_df["close"].shift(1), lambda a,b: max(abs(a),abs(b)))
ltf_df["atr"] = ltf_df["tr"].rolling(14, min_periods=1).mean()
atr = float(ltf_df["atr"].iloc[-1])
price = float(ltf_df["close"].iloc[-1])

bias, structure_score = _swing_bias(ltf_df["high"].values, ltf_df["low"].values, 3)
print(f"  Bias: {bias}, Structure: {structure_score:.1f}")

obs = detect_order_blocks(ltf_df, ea_cfg.ob_displacement_mult)
ob_score = 0.0
if obs:
    for ob in reversed(obs):
        ps = proximity_score(price, ob["bottom"], ob["top"], atr)
        ob_score = max(ob_score, ps)
        if ps > 0: break
print(f"  OB Score: {ob_score:.1f} (found {len(obs)} OBs)")

fvgs = detect_fvg(ltf_df, ea_cfg.fvg_min_gap)
fvg_score = 0.0
if fvgs:
    for f in reversed(fvgs):
        ps = proximity_score(price, f["bottom"], f["top"], atr)
        fvg_score = max(fvg_score, ps)
        if ps > 0: break
print(f"  FVG Score: {fvg_score:.1f} (found {len(fvgs)} FVGs)")

has_sweep, sweep_dir = liquidity_sweep(ltf_df, 20, 0.1)
sweep_score = 80.0 if has_sweep else 40.0
print(f"  Sweep: {sweep_score:.1f} (has_sweep={has_sweep})")

amd_name, amd_score = amd_phase(ltf_df)
print(f"  AMD: {amd_score:.1f} ({amd_name})")

range_high = float(ltf_df["high"].rolling(50, min_periods=5).max().iloc[-1])
range_low = float(ltf_df["low"].rolling(50, min_periods=5).min().iloc[-1])
eq = (range_high + range_low)/2
in_discount = price < eq
zone_score = 80.0 if (in_discount and bias=="BULL") or ((not in_discount) and bias=="BEAR") else 50.0
print(f"  Zone: {zone_score:.1f} (price={price:.2f}, eq={eq:.2f})")

print(f"  Regime conf: {regime.confidence:.1f}")
print(f"  Regime score_adj: {regime.score_adjustment}")
print(f"  Regime strategy: {regime.strategy}")
if regime.strategy:
    print(f"    tp1_r: {regime.strategy.tp1_r}, sl_atr_mult: {regime.strategy.sl_atr_mult}, min_rr: {regime.strategy.min_rr}")

# Direction
direction = SignalType.NONE
if bias == "BULL": direction = SignalType.BUY
elif bias == "BEAR": direction = SignalType.SELL
print(f"  Direction: {direction.name}")

# Calculate weighted score manually
print(f"\n[Calculated total score...]")
factors = [structure_score, regime.confidence, sweep_score, amd_score, ob_score, fvg_score, zone_score, 60.0, 50.0, 50.0]
weights = (0.17,0.13,0.13,0.09,0.09,0.07,0.04,0.13,0.06,0.09)  # OVERLAP session
total = sum(f*w for f,w in zip(factors, weights)) / sum(weights)
total += regime.score_adjustment
print(f"  Weighted score (before adj): {sum(f*w for f,w in zip(factors, weights))/sum(weights):.1f}")
print(f"  Score adjustment: {regime.score_adjustment}")
print(f"  Final score: {total:.1f}")

confs = sum(1 for f in factors if f >= 60)
print(f"  Confluences >= 60: {confs}")
print(f"  Valid: score>={ea_cfg.execution_threshold} and confs>=2 and dir!=NONE")
valid = total >= ea_cfg.execution_threshold and confs >= 2 and direction != SignalType.NONE
print(f"  Would be valid: {valid}")

# Check Entry Optimizer
print(f"\n[Entry Optimizer test...]")
from scripts.backtest.strategies.ea_logic_python import EntryOptimizerPython

optimizer = EntryOptimizerPython(ea_cfg)

# Get zones
ob_zone = (0.0, 0.0)
for ob in reversed(obs):
    ps = proximity_score(price, ob["bottom"], ob["top"], atr)
    if ps > 0:
        ob_zone = (ob["bottom"], ob["top"])
        break

fvg_zone = (0.0, 0.0)
for f in reversed(fvgs):
    ps = proximity_score(price, f["bottom"], f["top"], atr)
    if ps > 0:
        fvg_zone = (f["bottom"], f["top"])
        break

print(f"  OB Zone: {ob_zone}")
print(f"  FVG Zone: {fvg_zone}")
print(f"  Price: {price:.2f}, ATR: {atr:.2f}")

ok, entry, sl, tp1, tp2, tp3, rr = optimizer.build_entry(
    direction, price, atr, fvg_zone, ob_zone, None, regime.strategy
)
print(f"  Entry OK: {ok}")
print(f"  Entry: {entry:.2f}, SL: {sl:.2f}, TP1: {tp1:.2f}")
print(f"  R:R: {rr:.2f} (min: {ea_cfg.min_rr})")

# 7. Try full evaluation
print(f"\n[Full evaluation...]")
setup = ea.evaluate_from_df(ltf_window, h1_bars, timestamp)
if setup is None:
    print("  Result: None (blocked)")
else:
    print(f"  Result: {setup.direction.name} @ {setup.entry:.2f}")
    print(f"  SL: {setup.sl:.2f}, TP1: {setup.tp1:.2f}")
    print(f"  R:R: {setup.risk_reward:.2f}, Lot: {setup.lot:.2f}")
    print(f"  Score: {setup.confluence.total_score:.1f}")

# Try multiple bars
print(f"\n[Testing bars 500-3000, every 100...]")
found = 0
for test_idx in range(500, min(len(bars), 3000), 100):
    start = max(0, test_idx - eval_window)
    ltf_window = bars.iloc[start:test_idx+1].copy()
    ts = bars.index[test_idx]
    setup = ea.evaluate_from_df(ltf_window, h1_bars, ts)
    if setup:
        found += 1
        print(f"  Bar {test_idx}: SIGNAL {setup.direction.name} @ {setup.entry:.2f}, Score={setup.confluence.total_score:.1f}")

print(f"\nTotal signals found: {found}")
