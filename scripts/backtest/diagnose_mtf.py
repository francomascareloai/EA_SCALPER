"""
Diagnose MTF Gate failures in ea_logic_full.py
"""
import sys
import numpy as np
import pandas as pd
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from scripts.backtest.strategies.ea_logic_full import (
    MTFManager, MTFAlignment, MTFTrend, SignalType
)

def main():
    print("=" * 60)
    print("MTF GATE DIAGNOSTIC")
    print("=" * 60)
    
    # Load tick data
    from scripts.backtest.tick_backtester import TickDataLoader, OHLCResampler
    tick_path = "data/ticks/xauusd_2024_sample_norm2.csv"
    ticks = TickDataLoader.load(tick_path, max_ticks=2_000_000)
    
    # Resample to OHLC
    m5_bars = OHLCResampler.resample(ticks, '5min')
    h1_bars = OHLCResampler.resample(ticks, '1h')
    
    print(f"\nData:")
    print(f"  M5 bars: {len(m5_bars)}")
    print(f"  H1 bars: {len(h1_bars)}")
    
    # Calculate ATR
    def calc_atr(df, period=14):
        tr = pd.concat([
            df['high'] - df['low'],
            (df['high'] - df['close'].shift(1)).abs(),
            (df['low'] - df['close'].shift(1)).abs()
        ], axis=1).max(axis=1)
        return tr.rolling(period, min_periods=1).mean()
    
    h1_bars['atr'] = calc_atr(h1_bars)
    m5_bars['atr'] = calc_atr(m5_bars)
    
    # Calculate RSI
    def calc_rsi(closes, period=14):
        delta = closes.diff()
        gain = delta.where(delta > 0, 0).rolling(period, min_periods=1).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(period, min_periods=1).mean()
        rs = gain / loss.replace(0, 1e-10)
        return 100 - (100 / (1 + rs))
    
    m5_bars['rsi'] = calc_rsi(m5_bars['close'])
    
    # Create MTF Manager
    mtf = MTFManager(gmt_offset=0)
    
    # Test at different points
    print("\n" + "-" * 60)
    print("Testing MTF analysis at 5 different points")
    print("-" * 60)
    
    test_indices = [200, 500, 1000, 1500, 2000]
    
    for idx in test_indices:
        if idx >= len(m5_bars):
            continue
            
        # Get window up to this point
        m5_window = m5_bars.iloc[:idx+1]
        h1_window = h1_bars[h1_bars.index <= m5_bars.index[idx]]
        
        if len(h1_window) < 50:
            print(f"\n[Idx {idx}] Skipping - only {len(h1_window)} H1 bars (need 50)")
            continue
        
        h1_closes = h1_window['close'].values
        h1_atr = float(h1_window['atr'].iloc[-1])
        m15_closes = m5_window['close'].values[::3]
        m5_closes = m5_window['close'].values
        m5_rsi = float(m5_window['rsi'].iloc[-1])
        
        timestamp = m5_bars.index[idx]
        
        # Run MTF analysis
        mtf.analyze_htf(h1_closes, h1_atr)
        mtf.analyze_mtf(m15_closes, has_ob=True, has_fvg=True)  # Assume we have OB/FVG
        mtf.analyze_ltf(m5_closes, m5_rsi)
        confluence = mtf.get_confluence(timestamp)
        
        print(f"\n[Bar {idx}] {timestamp}")
        print(f"  H1 data: {len(h1_closes)} bars, ATR={h1_atr:.2f}")
        print(f"  HTF Trend: {mtf.htf_trend.name}, Strength: {mtf.htf_trend_strength:.1f}")
        print(f"  HTF Trending: {mtf.htf_is_trending}, Hurst: {mtf.htf_hurst:.3f}")
        print(f"  MTF Trend: {mtf.mtf_trend.name}, Structure: {mtf.mtf_has_structure}")
        print(f"  LTF Trend: {mtf.ltf_trend.name}, Confirmed: {mtf.ltf_has_confirmation}")
        print(f"  Confluence:")
        print(f"    - htf_aligned: {confluence.htf_aligned}")
        print(f"    - mtf_structure: {confluence.mtf_structure}")
        print(f"    - ltf_confirmed: {confluence.ltf_confirmed}")
        print(f"    - Alignment: {confluence.alignment.name}")
        print(f"    - Signal: {confluence.signal.name}")
        
        # Would this pass relaxed gate?
        if confluence.alignment >= MTFAlignment.WEAK:
            print(f"  [PASS] Would pass relaxed MTF gate")
        else:
            print(f"  [BLOCK] Would be blocked by MTF gate")
    
    # Full scan - how many pass vs fail
    print("\n" + "=" * 60)
    print("FULL SCAN: How many bars pass MTF gate?")
    print("=" * 60)
    
    pass_weak = 0
    pass_good = 0
    pass_perfect = 0
    total = 0
    
    htf_bullish = 0
    htf_bearish = 0
    htf_neutral = 0
    
    for idx in range(50, len(m5_bars), 10):  # Sample every 10 bars
        m5_window = m5_bars.iloc[:idx+1]
        h1_window = h1_bars[h1_bars.index <= m5_bars.index[idx]]
        
        if len(h1_window) < 50:
            continue
        
        h1_closes = h1_window['close'].values
        h1_atr = float(h1_window['atr'].iloc[-1])
        m15_closes = m5_window['close'].values[::3]
        m5_closes = m5_window['close'].values
        m5_rsi = float(m5_window['rsi'].iloc[-1])
        timestamp = m5_bars.index[idx]
        
        mtf.analyze_htf(h1_closes, h1_atr)
        mtf.analyze_mtf(m15_closes, has_ob=True, has_fvg=True)
        mtf.analyze_ltf(m5_closes, m5_rsi)
        confluence = mtf.get_confluence(timestamp)
        
        total += 1
        
        if mtf.htf_trend == MTFTrend.BULLISH:
            htf_bullish += 1
        elif mtf.htf_trend == MTFTrend.BEARISH:
            htf_bearish += 1
        else:
            htf_neutral += 1
        
        if confluence.alignment >= MTFAlignment.PERFECT:
            pass_perfect += 1
            pass_good += 1
            pass_weak += 1
        elif confluence.alignment >= MTFAlignment.GOOD:
            pass_good += 1
            pass_weak += 1
        elif confluence.alignment >= MTFAlignment.WEAK:
            pass_weak += 1
    
    print(f"\nTotal samples: {total}")
    print(f"\nHTF Trend distribution:")
    print(f"  Bullish: {htf_bullish} ({100*htf_bullish/total:.1f}%)")
    print(f"  Bearish: {htf_bearish} ({100*htf_bearish/total:.1f}%)")
    print(f"  Neutral: {htf_neutral} ({100*htf_neutral/total:.1f}%)")
    print(f"\nMTF Gate pass rates:")
    print(f"  >= WEAK (relaxed):   {pass_weak} ({100*pass_weak/total:.1f}%)")
    print(f"  >= GOOD (standard):  {pass_good} ({100*pass_good/total:.1f}%)")
    print(f"  >= PERFECT (strict): {pass_perfect} ({100*pass_perfect/total:.1f}%)")
    
    # Problem identified - check why HTF is neutral
    print("\n" + "=" * 60)
    print("DEBUG: Why is HTF Trend mostly NEUTRAL?")
    print("=" * 60)
    
    # Check trend determination logic
    h1_window = h1_bars.iloc[-100:]
    h1_closes = h1_window['close'].values
    h1_atr = float(h1_window['atr'].iloc[-1])
    
    # Calculate MAs
    ma_fast = np.mean(h1_closes[-20:])
    ma_slow = np.mean(h1_closes[-50:])
    price = h1_closes[-1]
    threshold = h1_atr * 0.3
    
    print(f"\nLast 100 H1 bars:")
    print(f"  Price: {price:.2f}")
    print(f"  MA_fast (20): {ma_fast:.2f}")
    print(f"  MA_slow (50): {ma_slow:.2f}")
    print(f"  H1 ATR: {h1_atr:.2f}")
    print(f"  Threshold (ATR*0.3): {threshold:.2f}")
    print(f"  MA_fast - MA_slow: {ma_fast - ma_slow:.2f}")
    
    print(f"\nBullish conditions:")
    print(f"  price > ma_fast: {price > ma_fast}")
    print(f"  ma_fast > ma_slow: {ma_fast > ma_slow}")
    print(f"  (ma_fast - ma_slow) > threshold: {(ma_fast - ma_slow) > threshold}")
    
    print(f"\nBearish conditions:")
    print(f"  price < ma_fast: {price < ma_fast}")
    print(f"  ma_fast < ma_slow: {ma_fast < ma_slow}")
    print(f"  (ma_slow - ma_fast) > threshold: {(ma_slow - ma_fast) > threshold}")
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()
