#!/usr/bin/env python3
"""
Diagnose EA confluence scores to understand why trades are not generated.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
from datetime import datetime, timezone

from scripts.backtest.tick_backtester import TickDataLoader, OHLCResampler, Indicators, BacktestConfig
from scripts.backtest.strategies.ea_logic_python import EAConfig, EALogic, SignalType

def main():
    print("Loading data...")
    
    # Load sample data
    config = BacktestConfig(
        use_ea_logic=True,
        bar_timeframe='15min',
        eval_window_bars=500
    )
    
    ticks = TickDataLoader.load('data/processed/ticks_2024.parquet', max_ticks=10_000_000)
    
    bars = OHLCResampler.resample(ticks, '15min')
    bars = Indicators.add_all(bars, config)
    
    htf_bars = OHLCResampler.resample(ticks, '1h')
    
    print(f"\nTotal bars: {len(bars)}")
    print(f"HTF bars: {len(htf_bars)}")
    
    # Create EA with DEFAULT config (relaxed)
    ea_default = EALogic(EAConfig(), initial_balance=100_000.0)
    
    # Create EA with STRICT config
    strict_config = EAConfig(
        execution_threshold=60.0,
        confluence_min_score=60.0,
        min_rr=1.5
    )
    ea_strict = EALogic(strict_config, initial_balance=100_000.0)
    
    # Sample some bars and check scores
    print("\n" + "="*80)
    print("CONFLUENCE SCORE ANALYSIS")
    print("="*80)
    
    scores_default = []
    scores_strict = []
    
    # Test every 100th bar
    test_indices = range(500, len(bars), 100)
    
    for idx in list(test_indices)[:50]:  # First 50 samples
        timestamp = bars.index[idx]
        if not isinstance(timestamp, datetime):
            timestamp = pd.Timestamp(timestamp).to_pydatetime().replace(tzinfo=timezone.utc)
        else:
            timestamp = timestamp.replace(tzinfo=timezone.utc)
        
        start = max(0, idx - 500)
        ltf_window = bars.iloc[start:idx+1].copy()
        
        # Ensure spread exists
        if 'spread' not in ltf_window.columns:
            ltf_window['spread'] = 0.4
        
        # Get signal from default EA
        setup_default = ea_default.evaluate_from_df(
            ltf_window, htf_bars, timestamp, fp_score=50.0
        )
        
        # Get signal from strict EA  
        setup_strict = ea_strict.evaluate_from_df(
            ltf_window, htf_bars, timestamp, fp_score=50.0
        )
        
        if setup_default:
            score = setup_default.confluence.total_score
            scores_default.append(score)
        
        if setup_strict:
            score = setup_strict.confluence.total_score
            scores_strict.append(score)
    
    print(f"\nDefault EA (threshold 50):")
    print(f"  Signals generated: {len(scores_default)}/50")
    if scores_default:
        print(f"  Score range: {min(scores_default):.1f} - {max(scores_default):.1f}")
        print(f"  Score mean: {np.mean(scores_default):.1f}")
        print(f"  Scores >= 60: {sum(1 for s in scores_default if s >= 60)}")
        print(f"  Scores >= 65: {sum(1 for s in scores_default if s >= 65)}")
        print(f"  Scores >= 70: {sum(1 for s in scores_default if s >= 70)}")
    
    print(f"\nStrict EA (threshold 60):")
    print(f"  Signals generated: {len(scores_strict)}/50")
    if scores_strict:
        print(f"  Score range: {min(scores_strict):.1f} - {max(scores_strict):.1f}")
        print(f"  Score mean: {np.mean(scores_strict):.1f}")
    
    # Deeper analysis - what's blocking signals?
    print("\n" + "="*80)
    print("FILTER BLOCKING ANALYSIS")
    print("="*80)
    
    blocks = {
        'spread': 0,
        'risk': 0,
        'session': 0,
        'news': 0,
        'regime': 0,
        'confluence_invalid': 0,
        'threshold': 0,
        'rr': 0,
        'passed': 0
    }
    
    ea_debug = EALogic(EAConfig(execution_threshold=50.0), initial_balance=100_000.0)
    
    for idx in list(test_indices)[:100]:
        timestamp = bars.index[idx]
        if not isinstance(timestamp, datetime):
            timestamp = pd.Timestamp(timestamp).to_pydatetime().replace(tzinfo=timezone.utc)
        else:
            timestamp = timestamp.replace(tzinfo=timezone.utc)
        
        start = max(0, idx - 500)
        ltf_window = bars.iloc[start:idx+1].copy()
        if 'spread' not in ltf_window.columns:
            ltf_window['spread'] = 0.4
        
        # Manual filter check
        raw_spread = float(ltf_window['spread'].iloc[-1])
        spread_points = raw_spread if raw_spread > 5 else raw_spread / 0.01
        
        if spread_points > 80:
            blocks['spread'] += 1
            continue
        
        session_ok, session_name = ea_debug.session.is_allowed(timestamp)
        if not session_ok:
            blocks['session'] += 1
            continue
        
        regime = ea_debug.regime.analyze(ltf_window['close'].values)
        from scripts.backtest.strategies.ea_logic_python import MarketRegime
        if regime.regime in (MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN):
            blocks['regime'] += 1
            continue
        
        # If we get here, check confluence
        setup = ea_debug.evaluate_from_df(ltf_window, htf_bars, timestamp, fp_score=50.0)
        if setup:
            blocks['passed'] += 1
        else:
            # Must be confluence or RR that blocked
            blocks['confluence_invalid'] += 1
    
    print("\nFilter blocking breakdown (100 samples):")
    for name, count in blocks.items():
        print(f"  {name}: {count}")
    
    # Check regime distribution
    print("\n" + "="*80)
    print("REGIME DISTRIBUTION")
    print("="*80)
    
    regimes = {}
    for idx in list(test_indices)[:100]:
        start = max(0, idx - 500)
        ltf_window = bars.iloc[start:idx+1].copy()
        regime = ea_debug.regime.analyze(ltf_window['close'].values)
        name = regime.regime.name
        regimes[name] = regimes.get(name, 0) + 1
    
    for name, count in sorted(regimes.items(), key=lambda x: -x[1]):
        print(f"  {name}: {count}")

if __name__ == "__main__":
    main()
