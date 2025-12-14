#!/usr/bin/env python3
"""
Diagnose EA Logic - Find what's blocking trades
===============================================
"""

import sys
from pathlib import Path

project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

import numpy as np
import pandas as pd
import pyarrow.parquet as pq
from datetime import datetime
from collections import defaultdict

from scripts.backtest.strategies.ea_logic_python import (
    EALogic, EAConfig, MarketRegime, SignalType
)

def diagnose():
    """Diagnose why EA generates no trades."""
    
    # Load data - only last few row groups to avoid memory issues
    data_path = project_root / "data" / "processed" / "ticks_2024.parquet"
    print(f"Loading: {data_path}")
    
    # Load last 10 row groups for sufficient H1 bars (need 220+)
    pf = pq.ParquetFile(str(data_path))
    tables = []
    for rg in range(max(0, pf.num_row_groups - 10), pf.num_row_groups):
        tables.append(pf.read_row_group(rg))
    import pyarrow as pa
    df = pa.concat_tables(tables).to_pandas()
    print(f"  Loaded {len(df):,} ticks from {pf.num_row_groups - 10} to {pf.num_row_groups} row groups")
    if 'timestamp' in df.columns:
        df['datetime'] = pd.to_datetime(df['timestamp'])
        df.set_index('datetime', inplace=True)
    df.sort_index(inplace=True)
    
    # Compute mid price if needed
    if 'mid' not in df.columns and 'bid' in df.columns and 'ask' in df.columns:
        df['mid'] = (df['bid'] + df['ask']) / 2
    if 'spread' not in df.columns and 'bid' in df.columns and 'ask' in df.columns:
        df['spread'] = df['ask'] - df['bid']
    
    # Resample to M15
    price_col = 'mid' if 'mid' in df.columns else ('close' if 'close' in df.columns else df.columns[0])
    bars = df[price_col].resample('15min').ohlc()
    bars.columns = ['open', 'high', 'low', 'close']
    if 'spread' in df.columns:
        bars['spread'] = df['spread'].resample('15min').mean()
    else:
        bars['spread'] = 0.30
    bars = bars.dropna()
    
    # H1 bars
    h1_bars = df[price_col].resample('1h').ohlc()
    h1_bars.columns = ['open', 'high', 'low', 'close']
    h1_bars = h1_bars.dropna()
    
    print(f"\n[Data]")
    print(f"  M15 Bars: {len(bars):,}")
    print(f"  H1 Bars:  {len(h1_bars):,}")
    print(f"  Period:   {bars.index[0]} to {bars.index[-1]}")
    
    # Initialize EA with relaxed config
    cfg = EAConfig(
        execution_threshold=50.0,  # Relaxed from 70
        confluence_min_score=50.0,  # Relaxed from 70
        min_rr=1.0,  # Relaxed from 1.5
        max_spread_points=100.0,  # Relaxed
        use_ml=False,
        use_fib_filter=False,  # Disable extra filter
    )
    ea = EALogic(cfg)
    
    # Track blocks
    blocks = defaultdict(int)
    regimes = defaultdict(int)
    sessions = defaultdict(int)
    signals_found = 0
    
    print(f"\n[Running diagnostic on {min(len(bars), 5000)} bars...]")
    
    # Check each bar (sample to save time)
    sample_size = min(len(bars), 5000)
    sample_indices = np.linspace(220, len(bars)-1, sample_size, dtype=int)
    
    for i in sample_indices:
        timestamp = bars.index[i]
        
        # Build LTF window
        start = max(0, i - 400)
        ltf_df = bars.iloc[start:i+1].copy()
        
        # Check spread (spread column is already in points in our parquet)
        spread_points = ltf_df['spread'].iloc[-1]
        # If spread seems to be in dollars (< 5), convert to points
        if spread_points < 5:
            spread_points = spread_points / 0.01
        if spread_points > cfg.max_spread_points:
            blocks['SPREAD'] += 1
            continue
        
        # Check risk manager
        if not ea.risk.can_open(timestamp):
            blocks['RISK_MANAGER'] += 1
            continue
        
        # Check session
        session_ok, session_name = ea.session.is_allowed(timestamp)
        sessions[session_name] += 1
        if not session_ok:
            blocks['SESSION'] += 1
            continue
        
        # Check news (empty in backtest)
        if not ea.news.is_allowed(timestamp):
            blocks['NEWS'] += 1
            continue
        
        # Check regime
        regime = ea.regime.analyze(ltf_df['close'].values)
        regimes[regime.regime.name] += 1
        
        if regime.regime in (MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN):
            blocks['REGIME'] += 1
            continue
        
        # If we get here, basic filters passed - try full evaluation
        try:
            setup = ea.evaluate_from_df(ltf_df, h1_bars, timestamp)
            if setup is None:
                blocks['CONFLUENCE_OR_ENTRY'] += 1
            else:
                signals_found += 1
        except Exception as e:
            blocks[f'ERROR: {str(e)[:50]}'] += 1
    
    # Report
    print(f"\n{'='*60}")
    print("              EA LOGIC DIAGNOSTIC REPORT")
    print(f"{'='*60}")
    
    print(f"\n[REGIME DISTRIBUTION]")
    total_regime = sum(regimes.values())
    for r, count in sorted(regimes.items(), key=lambda x: -x[1]):
        pct = count / total_regime * 100 if total_regime > 0 else 0
        bar = '#' * int(pct / 2)
        print(f"  {r:<20} {count:>6} ({pct:>5.1f}%) {bar}")
    
    print(f"\n[SESSION DISTRIBUTION]")
    total_session = sum(sessions.values())
    for s, count in sorted(sessions.items(), key=lambda x: -x[1]):
        pct = count / total_session * 100 if total_session > 0 else 0
        bar = '#' * int(pct / 2)
        print(f"  {s:<20} {count:>6} ({pct:>5.1f}%) {bar}")
    
    print(f"\n[BLOCKING REASONS]")
    total_blocks = sum(blocks.values())
    for reason, count in sorted(blocks.items(), key=lambda x: -x[1]):
        pct = count / sample_size * 100
        bar = '#' * int(pct / 2)
        print(f"  {reason:<25} {count:>6} ({pct:>5.1f}%) {bar}")
    
    print(f"\n[SUMMARY]")
    print(f"  Total bars checked:    {sample_size:,}")
    print(f"  Total blocked:         {total_blocks:,} ({total_blocks/sample_size*100:.1f}%)")
    print(f"  Signals generated:     {signals_found:,} ({signals_found/sample_size*100:.2f}%)")
    
    # Recommendation
    print(f"\n[RECOMMENDATION]")
    if blocks.get('REGIME', 0) > sample_size * 0.5:
        print("  [!] REGIME is the main blocker. Market is mostly RANDOM_WALK.")
        print("     Options:")
        print("     1. Relax regime filter (allow NOISY regimes)")
        print("     2. Use different time period with trending market")
        print("     3. Switch to MA crossover baseline for validation")
    
    if blocks.get('SESSION', 0) > sample_size * 0.3:
        print("  [!] SESSION filter is blocking many bars.")
        print("     Consider: Allow Asian or Late NY sessions")
    
    if blocks.get('CONFLUENCE_OR_ENTRY', 0) > sample_size * 0.3:
        print("  [!] Confluence/Entry optimizer blocking signals.")
        print("     Consider: Lower execution_threshold or min_rr")
    
    if signals_found > 0:
        print(f"  [OK] EA CAN generate signals with current filters!")
        print(f"     Found {signals_found} potential entries.")
    
    return {
        'blocks': dict(blocks),
        'regimes': dict(regimes),
        'sessions': dict(sessions),
        'signals': signals_found
    }


if __name__ == "__main__":
    diagnose()
