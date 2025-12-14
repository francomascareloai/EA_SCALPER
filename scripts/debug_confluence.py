#!/usr/bin/env python3
"""Debug confluence score calculation in detail."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
from datetime import timezone
from scripts.backtest.tick_backtester import TickDataLoader, OHLCResampler, Indicators, BacktestConfig
from scripts.backtest.strategies.ea_logic_python import EAConfig, EALogic, SignalType, MarketRegime
from scripts.backtest.strategies.ea_logic_python import _swing_bias, detect_order_blocks, detect_fvg, liquidity_sweep, amd_phase, proximity_score

def main():
    print('Loading data...')
    ticks = TickDataLoader.load('data/processed/ticks_2024.parquet', max_ticks=5_000_000)
    
    config = BacktestConfig(use_ea_logic=True, bar_timeframe='15min', eval_window_bars=500)
    bars = OHLCResampler.resample(ticks, '15min')
    bars = Indicators.add_all(bars, config)
    htf_bars = OHLCResampler.resample(ticks, '1h')
    
    ea_config = EAConfig(
        execution_threshold=50.0, confluence_min_score=50.0, min_rr=1.5,
        max_spread_points=80.0, use_fib_filter=False, ob_displacement_mult=1.5, fvg_min_gap=0.2
    )
    
    ea = EALogic(ea_config, initial_balance=100_000.0)
    
    # Analyze one bar in detail
    idx = 700
    timestamp = bars.index[idx]
    if hasattr(timestamp, 'to_pydatetime'):
        timestamp = timestamp.to_pydatetime()
    if timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=timezone.utc)
    
    start = max(0, idx - 500)
    ltf_window = bars.iloc[start:idx+1].copy()
    ltf_window['spread'] = 0.4
    
    # Manual analysis
    print(f'\nAnalyzing bar {idx} at {timestamp}')
    print(f'Window size: {len(ltf_window)}')
    
    # Regime
    regime = ea.regime.analyze(ltf_window['close'].values)
    print(f'\nRegime: {regime.regime.name}')
    print(f'  Hurst: {regime.hurst:.3f}')
    print(f'  Confidence: {regime.confidence:.1f}')
    print(f'  Score adjustment: {regime.score_adjustment}')
    
    # ATR
    ltf_window['tr'] = (ltf_window['high'] - ltf_window['low']).combine(
        ltf_window['high']-ltf_window['close'].shift(1), max).combine(
        ltf_window['low']-ltf_window['close'].shift(1), lambda a,b: max(abs(a),abs(b)))
    ltf_window['atr'] = ltf_window['tr'].rolling(14, min_periods=1).mean()
    atr = float(ltf_window['atr'].iloc[-1])
    price = float(ltf_window['close'].iloc[-1])
    print(f'\nPrice: {price:.2f}, ATR: {atr:.2f}')
    
    # Structure
    bias, structure_score = _swing_bias(ltf_window['high'].values, ltf_window['low'].values, 3)
    print(f'\nSwing Bias: {bias}, Structure Score: {structure_score}')
    
    # Order Blocks
    obs = detect_order_blocks(ltf_window, 1.5)
    print(f'Order Blocks: {len(obs)}')
    ob_score = 0.0
    for ob in reversed(obs[-5:]):
        sc = proximity_score(price, ob['bottom'], ob['top'], atr)
        ob_type = ob['type']
        print(f"  {ob_type}: {ob['bottom']:.2f}-{ob['top']:.2f}, proximity={sc:.1f}")
        ob_score = max(ob_score, sc)
    
    # FVG
    fvgs = detect_fvg(ltf_window, 0.2)
    print(f'FVGs: {len(fvgs)}')
    fvg_score = 0.0
    for f in reversed(fvgs[-5:]):
        sc = proximity_score(price, f['bottom'], f['top'], atr)
        ftype = f['type']
        print(f"  {ftype}: {f['bottom']:.2f}-{f['top']:.2f}, proximity={sc:.1f}")
        fvg_score = max(fvg_score, sc)
    
    # Liquidity Sweep
    has_sweep, sweep_dir = liquidity_sweep(ltf_window, 20, 0.1)
    sweep_score = 80.0 if has_sweep else 40.0
    print(f'\nLiquidity Sweep: {has_sweep}, Direction: {sweep_dir.name}, Score: {sweep_score}')
    
    # AMD
    amd_name, amd_score_val = amd_phase(ltf_window)
    print(f'AMD Phase: {amd_name}, Score: {amd_score_val}')
    
    # MTF
    mtf_score = 50.0
    if not htf_bars.empty:
        htf_ma = htf_bars['close'].rolling(50, min_periods=1).mean().iloc[-1]
        htf_trend_bull = htf_bars['close'].iloc[-1] > htf_ma
        mtf_score = 80.0 if (htf_trend_bull and bias=='BULL') or (not htf_trend_bull and bias=='BEAR') else 40.0
    print(f'MTF Score: {mtf_score}')
    
    # Zone
    range_high = float(ltf_window['high'].rolling(50, min_periods=5).max().iloc[-1])
    range_low = float(ltf_window['low'].rolling(50, min_periods=5).min().iloc[-1])
    eq = (range_high + range_low)/2
    in_discount = price < eq
    zone_score = 80.0 if (in_discount and bias=='BULL') or (not in_discount and bias=='BEAR') else 50.0
    print(f'Zone Score: {zone_score} (in_discount={in_discount}, bias={bias})')
    
    # Direction
    direction = SignalType.NONE
    if bias == 'BULL': direction = SignalType.BUY
    elif bias == 'BEAR': direction = SignalType.SELL
    print(f'\nDirection: {direction.name}')
    
    # Calculate total (simulating ConfluenceScorer.score)
    fp_score = 80.0
    fib_score = 50.0  # default when use_fib_filter=False
    session_name = 'OVERLAP'
    w = ea.scorer.session_weights.get(session_name, ea.scorer.session_weights['DEAD'])
    
    total = (structure_score*w[0] + regime.confidence*w[1] + sweep_score*w[2] + amd_score_val*w[3] +
             ob_score*w[4] + fvg_score*w[5] + zone_score*w[6] + mtf_score*w[7] + fp_score*w[8] + fib_score*w[9])
    weighted_avg = total / sum(w)
    final_score = max(0.0, min(100.0, weighted_avg + regime.score_adjustment))
    
    print(f'\nConfluence weights for {session_name}: {w}')
    print(f'Individual scores:')
    print(f'  structure={structure_score:.1f}, regime_conf={regime.confidence:.1f}, sweep={sweep_score:.1f}')
    print(f'  amd={amd_score_val:.1f}, ob={ob_score:.1f}, fvg={fvg_score:.1f}')
    print(f'  zone={zone_score:.1f}, mtf={mtf_score:.1f}, fp={fp_score:.1f}, fib={fib_score:.1f}')
    print(f'Weighted sum: {total:.1f}')
    print(f'Weighted avg: {weighted_avg:.1f}')
    print(f'Score adjustment: {regime.score_adjustment}')
    print(f'Final score: {final_score:.1f}')
    
    # Confluence minimum check (threshold = 60 in scorer)
    confs = sum(x >= 60 for x in [structure_score, regime.confidence, sweep_score, amd_score_val, ob_score, fvg_score, zone_score, mtf_score, fp_score, fib_score])
    print(f'\nConfluences >= 60: {confs}')
    
    # is_valid check: score >= 50 and confs >= 2 and direction != NONE
    is_valid = final_score >= 50 and confs >= 2 and direction != SignalType.NONE
    print(f'Is valid check: score={final_score:.1f} >= 50 AND confs={confs} >= 2 AND direction={direction.name} != NONE')
    print(f'RESULT: is_valid = {is_valid}')
    
    # What would make it valid?
    print(f'\n--- ANALYSIS ---')
    if direction == SignalType.NONE:
        print('BLOCKED: No direction (NEUTRAL bias)')
    if confs < 2:
        print(f'BLOCKED: Only {confs} confluences >= 60 (need 2)')
        print('  Scores < 60:', [s for s in [structure_score, regime.confidence, sweep_score, amd_score_val, ob_score, fvg_score, zone_score, mtf_score, fp_score, fib_score] if s < 60])
    if final_score < 50:
        print(f'BLOCKED: Score {final_score:.1f} < 50 threshold')

if __name__ == "__main__":
    main()
