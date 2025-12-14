#!/usr/bin/env python3
"""
Debug OB Test - Find the calculation bug
"""

import numpy as np
import pandas as pd


def load_data():
    path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
    df = pd.read_csv(path)
    df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'])
    df.set_index('datetime', inplace=True)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].copy()
    df.columns = ['open', 'high', 'low', 'close', 'volume']
    return df


def simple_backtest():
    """Ultra-simple backtest to verify math"""
    
    print("="*60)
    print("DEBUG ORDER BLOCK TEST")
    print("="*60)
    
    df = load_data()
    print(f"Loaded {len(df):,} bars")
    
    # Add ATR
    df['tr'] = np.maximum(
        df['high'] - df['low'],
        np.maximum(abs(df['high'] - df['close'].shift(1)),
                  abs(df['low'] - df['close'].shift(1))))
    df['atr'] = df['tr'].rolling(14).mean()
    df['ma200'] = df['close'].rolling(200).mean()
    
    print(f"\nATR stats:")
    print(f"  Mean: {df['atr'].mean():.2f}")
    print(f"  Min: {df['atr'].min():.2f}")
    print(f"  Max: {df['atr'].max():.2f}")
    
    # Config
    INITIAL = 100000
    RISK_PCT = 0.005
    RISK_AMT = INITIAL * RISK_PCT  # $500
    SL_MULT = 2.0
    TP_MULT = 3.0
    SPREAD = 0.45
    
    print(f"\nConfig:")
    print(f"  Risk amount: ${RISK_AMT}")
    print(f"  SL mult: {SL_MULT}x ATR")
    print(f"  TP mult: {TP_MULT}x ATR")
    
    # Simple OB detection - just look for bearish/bullish candles with displacement
    balance = INITIAL
    position = None
    trades = []
    
    for i in range(250, len(df)):
        row = df.iloc[i]
        prev = df.iloc[i-1]
        
        atr = row['atr']
        if pd.isna(atr) or atr <= 0:
            continue
        
        # Check position
        if position:
            if position['dir'] == 'BUY':
                if row['low'] <= position['sl']:
                    pnl = (position['sl'] - position['entry']) * position['lots'] * 100
                    trades.append({'pnl': pnl, 'lots': position['lots'], 'sl_dist': position['entry']-position['sl']})
                    balance += pnl
                    position = None
                elif row['high'] >= position['tp']:
                    pnl = (position['tp'] - position['entry']) * position['lots'] * 100
                    trades.append({'pnl': pnl, 'lots': position['lots'], 'tp_dist': position['tp']-position['entry']})
                    balance += pnl
                    position = None
            else:
                if row['high'] >= position['sl']:
                    pnl = (position['entry'] - position['sl']) * position['lots'] * 100
                    trades.append({'pnl': pnl, 'lots': position['lots'], 'sl_dist': position['sl']-position['entry']})
                    balance += pnl
                    position = None
                elif row['low'] <= position['tp']:
                    pnl = (position['entry'] - position['tp']) * position['lots'] * 100
                    trades.append({'pnl': pnl, 'lots': position['lots'], 'tp_dist': position['entry']-position['tp']})
                    balance += pnl
                    position = None
        
        # Simple entry - every 500 bars, alternate buy/sell
        if position is None and i % 500 == 0:
            direction = 'BUY' if (i // 500) % 2 == 0 else 'SELL'
            
            sl_dist = atr * SL_MULT
            tp_dist = atr * TP_MULT
            
            # Lot calculation (CRITICAL)
            lots = RISK_AMT / (sl_dist * 100)
            lots = max(0.01, min(lots, 10.0))
            
            if direction == 'BUY':
                entry = row['close'] + SPREAD/2
                sl = entry - sl_dist
                tp = entry + tp_dist
            else:
                entry = row['close'] - SPREAD/2
                sl = entry + sl_dist
                tp = entry - tp_dist
            
            position = {'dir': direction, 'entry': entry, 'sl': sl, 'tp': tp, 'lots': lots}
            
            # Debug first few trades
            if len(trades) < 5:
                print(f"\n  Trade {len(trades)+1}: {direction}")
                print(f"    Entry: ${entry:.2f}")
                print(f"    SL: ${sl:.2f} (dist: ${sl_dist:.2f})")
                print(f"    TP: ${tp:.2f} (dist: ${tp_dist:.2f})")
                print(f"    ATR: ${atr:.2f}")
                print(f"    Lots: {lots:.4f}")
                print(f"    Expected SL loss: ${sl_dist * lots * 100:.2f}")
                print(f"    Expected TP win: ${tp_dist * lots * 100:.2f}")
    
    # Results
    if trades:
        pnls = [t['pnl'] for t in trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        print(f"\n{'='*60}")
        print("RESULTS")
        print(f"{'='*60}")
        print(f"Total trades: {len(trades)}")
        print(f"Wins: {len(wins)}, Losses: {len(losses)}")
        print(f"Win rate: {len(wins)/len(trades):.1%}")
        
        if wins:
            print(f"Avg win: ${np.mean(wins):.2f}")
        if losses:
            print(f"Avg loss: ${np.mean(losses):.2f}")
        
        gp = sum(wins) if wins else 0
        gl = abs(sum(losses)) if losses else 1
        pf = gp / gl
        print(f"Profit Factor: {pf:.2f}")
        print(f"Net profit: ${balance - INITIAL:.2f}")
        
        # Check lot sizes
        print(f"\nLot size stats:")
        lot_sizes = [t['lots'] for t in trades]
        print(f"  Mean: {np.mean(lot_sizes):.4f}")
        print(f"  Min: {np.min(lot_sizes):.4f}")
        print(f"  Max: {np.max(lot_sizes):.4f}")


if __name__ == "__main__":
    simple_backtest()
