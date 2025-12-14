#!/usr/bin/env python3
"""Detailed debug of EA evaluation to find why substituted EA fails."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
from datetime import datetime, timezone

from scripts.backtest.tick_backtester import TickDataLoader, OHLCResampler, Indicators, BacktestConfig
from scripts.backtest.strategies.ea_logic_python import EAConfig, EALogic, MarketRegime

def main():
    print("Loading data...")
    ticks = TickDataLoader.load('data/processed/ticks_2024.parquet', max_ticks=10_000_000)
    
    config = BacktestConfig(
        use_ea_logic=True,
        bar_timeframe='15min',
        eval_window_bars=500
    )
    
    bars = OHLCResampler.resample(ticks, '15min')
    bars = Indicators.add_all(bars, config)
    htf_bars = OHLCResampler.resample(ticks, '1h')
    
    print(f"Total bars: {len(bars)}")
    
    # Create TWO EAs with identical config
    ea_config = EAConfig(
        risk_per_trade_pct=0.5,
        execution_threshold=50.0,
        confluence_min_score=50.0,
        min_rr=1.5,
        max_spread_points=80.0,
        allow_asian=True,
        allow_late_ny=True,
        use_ml=False,
        use_fib_filter=False,
        ob_displacement_mult=1.5,
        fvg_min_gap=0.2,
        use_mtf=False
    )
    
    ea1 = EALogic(ea_config, initial_balance=100_000.0)
    ea2 = EALogic(ea_config, initial_balance=100_000.0)
    
    print("\nComparing EA configs:")
    print(f"  EA1 execution_threshold: {ea1.cfg.execution_threshold}")
    print(f"  EA2 execution_threshold: {ea2.cfg.execution_threshold}")
    print(f"  EA1 point_value: {ea1.cfg.point_value}")
    print(f"  EA2 point_value: {ea2.cfg.point_value}")
    
    # Test on a few bars
    print("\n" + "="*80)
    print("DETAILED EVALUATION DEBUG")
    print("="*80)
    
    test_indices = [500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000]
    
    for idx in test_indices:
        if idx >= len(bars):
            continue
            
        timestamp = bars.index[idx]
        if hasattr(timestamp, 'to_pydatetime'):
            timestamp = timestamp.to_pydatetime()
        if timestamp.tzinfo is None:
            timestamp = timestamp.replace(tzinfo=timezone.utc)
        
        start = max(0, idx - 500)
        ltf_window = bars.iloc[start:idx+1].copy()
        
        if 'spread' not in ltf_window.columns:
            ltf_window['spread'] = 0.4
        
        # Manual debug
        print(f"\n--- Bar {idx} at {timestamp} ---")
        
        # Check spread
        raw_spread = float(ltf_window['spread'].iloc[-1])
        spread_points = raw_spread if raw_spread > 5 else raw_spread / ea1.cfg.point_value
        print(f"  raw_spread={raw_spread:.2f}, spread_points={spread_points:.1f}, max={ea1.cfg.max_spread_points}")
        
        if spread_points > ea1.cfg.max_spread_points:
            print(f"  -> BLOCKED by spread")
            continue
        
        # Check risk manager
        can_open = ea1.risk.can_open(timestamp)
        print(f"  can_open={can_open}, halted={ea1.risk.halted}, trades_today={ea1.risk.trades_today}")
        
        if not can_open:
            print(f"  -> BLOCKED by risk manager")
            continue
        
        # Check session
        session_ok, session_name = ea1.session.is_allowed(timestamp)
        print(f"  session_ok={session_ok}, session={session_name}")
        
        if not session_ok:
            print(f"  -> BLOCKED by session")
            continue
        
        # Check regime
        regime = ea1.regime.analyze(ltf_window['close'].values)
        print(f"  regime={regime.regime.name}, hurst={regime.hurst:.3f}, conf={regime.confidence:.1f}")
        
        if regime.regime in (MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN):
            print(f"  -> BLOCKED by regime")
            continue
        
        # Try full evaluation
        setup = ea1.evaluate_from_df(ltf_window, htf_bars, timestamp, fp_score=50.0)
        
        if setup:
            print(f"  -> SIGNAL: {setup.direction}, score={setup.confluence.total_score:.1f}, RR={setup.risk_reward:.2f}")
        else:
            print(f"  -> NO SIGNAL (confluence/RR failed)")
    
    # Count signals from bars 500 to end
    print("\n" + "="*80)
    print("FULL SIGNAL COUNT TEST")
    print("="*80)
    
    signals = 0
    blocked_spread = 0
    blocked_risk = 0
    blocked_session = 0
    blocked_regime = 0
    blocked_confluence = 0
    
    # Reset risk manager
    ea1 = EALogic(ea_config, initial_balance=100_000.0)
    
    for idx in range(500, len(bars)):
        timestamp = bars.index[idx]
        if hasattr(timestamp, 'to_pydatetime'):
            timestamp = timestamp.to_pydatetime()
        if timestamp.tzinfo is None:
            timestamp = timestamp.replace(tzinfo=timezone.utc)
        
        start = max(0, idx - 500)
        ltf_window = bars.iloc[start:idx+1].copy()
        
        if 'spread' not in ltf_window.columns:
            ltf_window['spread'] = 0.4
        
        setup = ea1.evaluate_from_df(ltf_window, htf_bars, timestamp, fp_score=50.0)
        
        if setup:
            signals += 1
    
    print(f"\nTotal signals: {signals}")

if __name__ == "__main__":
    main()
