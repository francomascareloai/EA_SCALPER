#!/usr/bin/env python3
"""
Diagnose EA Logic v2 - Deep confluence analysis
================================================
"""

import sys
from pathlib import Path

project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

import numpy as np
import pandas as pd
import pyarrow.parquet as pq
import pyarrow as pa
from datetime import datetime
from collections import defaultdict

from scripts.backtest.strategies.ea_logic_python import (
    EALogic, EAConfig, MarketRegime, SignalType,
    RegimeDetectorPython, SessionFilterPython, ConfluenceScorerPython,
    detect_order_blocks, detect_fvg, _swing_bias, liquidity_sweep, amd_phase
)

def diagnose_confluence():
    """Diagnose why confluence blocks trades."""
    
    # Load data
    data_path = project_root / "data" / "processed" / "ticks_2024.parquet"
    print(f"Loading: {data_path}")
    
    pf = pq.ParquetFile(str(data_path))
    tables = [pf.read_row_group(rg) for rg in range(max(0, pf.num_row_groups - 10), pf.num_row_groups)]
    df = pa.concat_tables(tables).to_pandas()
    print(f"  Loaded {len(df):,} ticks")
    
    df['datetime'] = pd.to_datetime(df['timestamp'])
    df.set_index('datetime', inplace=True)
    df.sort_index(inplace=True)
    
    if 'mid' not in df.columns:
        df['mid'] = (df['bid'] + df['ask']) / 2
    
    bars = df['mid'].resample('15min').ohlc()
    bars.columns = ['open', 'high', 'low', 'close']
    if 'spread' in df.columns:
        bars['spread'] = df['spread'].resample('15min').mean()
    else:
        bars['spread'] = 30.0
    bars = bars.dropna()
    
    print(f"\n[Data]")
    print(f"  M15 Bars: {len(bars):,}")
    
    # Components
    cfg = EAConfig(
        execution_threshold=40.0,  # Very relaxed
        confluence_min_score=40.0,
        min_rr=0.8,
        max_spread_points=150.0,
        use_ml=False,
        use_fib_filter=False,
        ob_displacement_mult=1.5,  # Relaxed
        fvg_min_gap=0.2,  # Relaxed
    )
    regime_detector = RegimeDetectorPython(cfg)
    session_filter = SessionFilterPython(cfg)
    scorer = ConfluenceScorerPython()
    
    # Track scores
    scores = {
        'structure': [],
        'regime_conf': [],
        'sweep': [],
        'amd': [],
        'ob': [],
        'fvg': [],
        'zone': [],
        'mtf': [],
        'fp': [],
        'fib': [],
        'total': [],
    }
    
    valid_count = 0
    invalid_reasons = defaultdict(int)
    
    print(f"\n[Analyzing confluence scores on {min(len(bars), 2000)} bars...]")
    
    sample_size = min(len(bars), 2000)
    sample_indices = np.linspace(300, len(bars)-1, sample_size, dtype=int)
    
    for i in sample_indices:
        timestamp = bars.index[i]
        
        # Build window
        start = max(0, i - 400)
        ltf_df = bars.iloc[start:i+1].copy()
        
        if len(ltf_df) < 220:
            continue
        
        # Spread check
        spread_points = ltf_df['spread'].iloc[-1]
        if spread_points < 5:
            spread_points = spread_points / 0.01
        if spread_points > cfg.max_spread_points:
            continue
        
        # Session check
        session_ok, session_name = session_filter.is_allowed(timestamp)
        if not session_ok:
            continue
        
        # Regime
        regime = regime_detector.analyze(ltf_df['close'].values)
        if regime.regime in (MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN):
            continue
        
        # Calculate all confluence factors
        ltf_df["tr"] = (ltf_df["high"] - ltf_df["low"]).combine(
            ltf_df["high"]-ltf_df["close"].shift(1), max
        ).combine(ltf_df["low"]-ltf_df["close"].shift(1), lambda a,b: max(abs(a),abs(b)))
        ltf_df["atr"] = ltf_df["tr"].rolling(14, min_periods=1).mean()
        atr = float(ltf_df["atr"].iloc[-1])
        price = float(ltf_df["close"].iloc[-1])
        
        # Structure (swing bias)
        bias, structure_score = _swing_bias(ltf_df["high"].values, ltf_df["low"].values, 3)
        if bias == "NEUTRAL":
            structure_score = 50.0
        
        # Order blocks
        obs = detect_order_blocks(ltf_df, cfg.ob_displacement_mult)
        ob_score = 0.0
        if obs:
            for ob in reversed(obs):
                from scripts.backtest.strategies.ea_logic_python import proximity_score
                ps = proximity_score(price, ob["bottom"], ob["top"], atr)
                ob_score = max(ob_score, ps)
                if ps > 0:
                    break
        
        # FVG
        fvgs = detect_fvg(ltf_df, cfg.fvg_min_gap)
        fvg_score = 0.0
        if fvgs:
            for f in reversed(fvgs):
                from scripts.backtest.strategies.ea_logic_python import proximity_score
                ps = proximity_score(price, f["bottom"], f["top"], atr)
                fvg_score = max(fvg_score, ps)
                if ps > 0:
                    break
        
        # Sweep
        has_sweep, sweep_dir = liquidity_sweep(ltf_df, 20, 0.1)
        sweep_score = 80.0 if has_sweep else 40.0
        
        # AMD
        amd_name, amd_score = amd_phase(ltf_df)
        
        # Zone (premium/discount)
        range_high = float(ltf_df["high"].rolling(50, min_periods=5).max().iloc[-1])
        range_low = float(ltf_df["low"].rolling(50, min_periods=5).min().iloc[-1])
        eq = (range_high + range_low)/2
        in_discount = price < eq
        zone_score = 80.0 if (in_discount and bias=="BULL") or ((not in_discount) and bias=="BEAR") else 50.0
        
        # MTF alignment (simplified)
        mtf_score = 60.0  # neutral
        
        # Footprint (neutral)
        fp_score = 50.0
        
        # Fib (disabled)
        fib_score = 50.0
        
        # Direction
        direction = SignalType.NONE
        if bias == "BULL":
            direction = SignalType.BUY
        elif bias == "BEAR":
            direction = SignalType.SELL
        
        # Score
        result = scorer.score(
            session_name, regime, structure_score, sweep_score, amd_score,
            ob_score, fvg_score, zone_score, mtf_score, fp_score, fib_score, direction
        )
        
        # Track
        scores['structure'].append(structure_score)
        scores['regime_conf'].append(regime.confidence)
        scores['sweep'].append(sweep_score)
        scores['amd'].append(amd_score)
        scores['ob'].append(ob_score)
        scores['fvg'].append(fvg_score)
        scores['zone'].append(zone_score)
        scores['mtf'].append(mtf_score)
        scores['fp'].append(fp_score)
        scores['fib'].append(fib_score)
        scores['total'].append(result.total_score)
        
        if result.is_valid:
            valid_count += 1
        else:
            if result.total_score < 70:
                invalid_reasons['score<70'] += 1
            if result.total_confluences < 3:
                invalid_reasons['<3 confluences'] += 1
            if direction == SignalType.NONE:
                invalid_reasons['no direction'] += 1
    
    # Report
    print(f"\n{'='*70}")
    print("              CONFLUENCE SCORE ANALYSIS")
    print(f"{'='*70}")
    
    print(f"\n[FACTOR SCORE STATISTICS]")
    print(f"{'Factor':<15} {'Min':>8} {'Max':>8} {'Mean':>8} {'Median':>8} {'>=60%':>8}")
    print("-"*70)
    
    for factor, vals in scores.items():
        if vals:
            arr = np.array(vals)
            pct_good = (arr >= 60).sum() / len(arr) * 100
            print(f"{factor:<15} {arr.min():>8.1f} {arr.max():>8.1f} {arr.mean():>8.1f} {np.median(arr):>8.1f} {pct_good:>7.1f}%")
    
    print(f"\n[INVALID REASONS]")
    for reason, count in sorted(invalid_reasons.items(), key=lambda x: -x[1]):
        print(f"  {reason}: {count}")
    
    print(f"\n[SUMMARY]")
    analyzed = len(scores['total'])
    print(f"  Bars analyzed:    {analyzed:,}")
    print(f"  Valid signals:    {valid_count:,} ({valid_count/analyzed*100:.2f}%)")
    
    # Threshold analysis
    print(f"\n[THRESHOLD ANALYSIS - How many signals at different thresholds?]")
    for threshold in [40, 50, 60, 70, 80]:
        count = sum(1 for s in scores['total'] if s >= threshold)
        print(f"  Score >= {threshold}: {count:,} ({count/analyzed*100:.2f}%)")
    
    return scores


if __name__ == "__main__":
    diagnose_confluence()
