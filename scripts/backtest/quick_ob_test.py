#!/usr/bin/env python3
"""
Quick Order Block Test - Verify the promising PF 1.42 result
"""

import numpy as np
import pandas as pd
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')


def load_data(filepath: str) -> pd.DataFrame:
    df = pd.read_csv(filepath)
    df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'])
    df.set_index('datetime', inplace=True)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].copy()
    df.columns = ['open', 'high', 'low', 'close', 'volume']
    return df


def add_indicators(df: pd.DataFrame) -> pd.DataFrame:
    """Add ATR and Order Block detection"""
    df = df.copy()
    
    # ATR
    df['tr'] = np.maximum(
        df['high'] - df['low'],
        np.maximum(
            abs(df['high'] - df['close'].shift(1)),
            abs(df['low'] - df['close'].shift(1))
        )
    )
    df['atr'] = df['tr'].rolling(14).mean()
    
    # Simple Order Block Detection
    # Bullish OB: Bearish candle followed by strong bullish move
    df['is_bearish'] = df['close'] < df['open']
    df['is_bullish'] = df['close'] > df['open']
    
    # Displacement (strong move after)
    df['up_displacement'] = df['high'].shift(-1) - df['close'] > df['atr'] * 1.5
    df['down_displacement'] = df['close'] - df['low'].shift(-1) > df['atr'] * 1.5
    
    # Order Block formation
    df['bullish_ob'] = df['is_bearish'] & df['up_displacement'].shift(1).fillna(False)
    df['bearish_ob'] = df['is_bullish'] & df['down_displacement'].shift(1).fillna(False)
    
    # OB zones (forward filled)
    df['ob_bull_top'] = np.where(df['bullish_ob'], df['open'], np.nan)
    df['ob_bull_bot'] = np.where(df['bullish_ob'], df['low'], np.nan)
    df['ob_bear_top'] = np.where(df['bearish_ob'], df['high'], np.nan)
    df['ob_bear_bot'] = np.where(df['bearish_ob'], df['open'], np.nan)
    
    df['ob_bull_top'] = df['ob_bull_top'].ffill()
    df['ob_bull_bot'] = df['ob_bull_bot'].ffill()
    df['ob_bear_top'] = df['ob_bear_top'].ffill()
    df['ob_bear_bot'] = df['ob_bear_bot'].ffill()
    
    # Price in OB zone
    df['in_bull_ob'] = (df['low'] <= df['ob_bull_top']) & (df['close'] >= df['ob_bull_bot'])
    df['in_bear_ob'] = (df['high'] >= df['ob_bear_bot']) & (df['close'] <= df['ob_bear_top'])
    
    # Simple bias from price vs MA200
    df['ma200'] = df['close'].rolling(200).mean()
    df['bullish_bias'] = df['close'] > df['ma200']
    df['bearish_bias'] = df['close'] < df['ma200']
    
    return df.dropna()


def backtest(df: pd.DataFrame) -> dict:
    """Run backtest"""
    initial = 100000
    balance = initial
    peak = initial
    risk_per_trade = 0.005
    spread = 0.45  # Pessimistic
    
    position = None
    trades = []
    
    for idx, row in df.iterrows():
        # DD check
        dd = (peak - balance) / peak if peak > 0 else 0
        if dd >= 0.10:
            if position:
                pnl = close_trade(position, row, spread)
                trades.append(pnl)
                balance += pnl
            break
        
        # Manage position
        if position:
            # Check SL/TP
            if position['dir'] == 'BUY':
                if row['low'] <= position['sl']:
                    pnl = (position['sl'] - position['entry']) * position['lots'] * 100
                    trades.append(pnl)
                    balance += pnl
                    if balance > peak: peak = balance
                    position = None
                elif row['high'] >= position['tp']:
                    pnl = (position['tp'] - position['entry']) * position['lots'] * 100
                    trades.append(pnl)
                    balance += pnl
                    if balance > peak: peak = balance
                    position = None
            else:
                if row['high'] >= position['sl']:
                    pnl = (position['entry'] - position['sl']) * position['lots'] * 100
                    trades.append(pnl)
                    balance += pnl
                    if balance > peak: peak = balance
                    position = None
                elif row['low'] <= position['tp']:
                    pnl = (position['entry'] - position['tp']) * position['lots'] * 100
                    trades.append(pnl)
                    balance += pnl
                    if balance > peak: peak = balance
                    position = None
        
        # Entry signals
        if position is None:
            atr = row['atr']
            if pd.isna(atr) or atr <= 0:
                continue
            
            # Buy at bullish OB in bullish bias
            if row['in_bull_ob'] and row['bullish_bias']:
                entry = row['close'] + spread/2
                sl = entry - atr * 2.0
                tp = entry + atr * 3.0
                lots = (balance * risk_per_trade) / ((entry - sl) * 100)
                lots = max(0.01, min(lots, 10.0))
                position = {'dir': 'BUY', 'entry': entry, 'sl': sl, 'tp': tp, 'lots': lots}
            
            # Sell at bearish OB in bearish bias
            elif row['in_bear_ob'] and row['bearish_bias']:
                entry = row['close'] - spread/2
                sl = entry + atr * 2.0
                tp = entry - atr * 3.0
                lots = (balance * risk_per_trade) / ((sl - entry) * 100)
                lots = max(0.01, min(lots, 10.0))
                position = {'dir': 'SELL', 'entry': entry, 'sl': sl, 'tp': tp, 'lots': lots}
    
    # Close remaining
    if position:
        pnl = close_trade(position, df.iloc[-1], spread)
        trades.append(pnl)
        balance += pnl
    
    # Metrics
    return calculate_metrics(trades, initial, balance, peak)


def close_trade(pos, row, spread):
    if pos['dir'] == 'BUY':
        exit_p = row['close'] - spread/2
        return (exit_p - pos['entry']) * pos['lots'] * 100
    else:
        exit_p = row['close'] + spread/2
        return (pos['entry'] - exit_p) * pos['lots'] * 100


def calculate_metrics(trades, initial, final, peak):
    if not trades:
        return {'error': 'No trades'}
    
    wins = [t for t in trades if t > 0]
    losses = [t for t in trades if t < 0]
    
    n = len(trades)
    wr = len(wins) / n if n > 0 else 0
    gp = sum(wins) if wins else 0
    gl = abs(sum(losses)) if losses else 1
    pf = gp / gl if gl > 0 else 0
    
    # Max DD
    eq = [initial]
    for t in trades:
        eq.append(eq[-1] + t)
    eq = np.array(eq)
    pk = np.maximum.accumulate(eq)
    dd = ((pk - eq) / pk).max()
    
    ret = (final - initial) / initial
    
    return {
        'total_trades': n,
        'win_rate': wr,
        'profit_factor': pf,
        'max_drawdown': dd,
        'total_return': ret,
        'net_profit': final - initial,
        'wins': len(wins),
        'losses': len(losses)
    }


def main():
    print("=" * 70)
    print("         ORDER BLOCK STRATEGY - DETAILED TEST")
    print("=" * 70)
    
    # Load data
    path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
    print(f"\nLoading data...")
    df = load_data(path)
    print(f"Loaded {len(df):,} bars")
    
    # Add indicators
    print("Adding indicators...")
    df = add_indicators(df)
    
    # Count signals
    bull_obs = df['bullish_ob'].sum()
    bear_obs = df['bearish_ob'].sum()
    in_bull = df['in_bull_ob'].sum()
    in_bear = df['in_bear_ob'].sum()
    
    print(f"\nOrder Blocks detected:")
    print(f"  Bullish OBs: {bull_obs:,}")
    print(f"  Bearish OBs: {bear_obs:,}")
    print(f"  Bars in Bullish OB zone: {in_bull:,}")
    print(f"  Bars in Bearish OB zone: {in_bear:,}")
    
    # Run backtest
    print("\nRunning backtest...")
    metrics = backtest(df)
    
    # Print results
    print("\n" + "=" * 70)
    print("                        RESULTS")
    print("=" * 70)
    
    if 'error' in metrics:
        print(f"ERROR: {metrics['error']}")
        return
    
    print(f"\nTotal Trades:    {metrics['total_trades']:,}")
    print(f"  Wins:          {metrics['wins']:,}")
    print(f"  Losses:        {metrics['losses']:,}")
    print(f"Win Rate:        {metrics['win_rate']:.1%}")
    print(f"Profit Factor:   {metrics['profit_factor']:.2f}")
    print(f"Max Drawdown:    {metrics['max_drawdown']:.2%}")
    print(f"Total Return:    {metrics['total_return']:.2%}")
    print(f"Net Profit:      ${metrics['net_profit']:,.2f}")
    
    # Assessment
    print("\n" + "-" * 40)
    print("FTMO ASSESSMENT:")
    
    if metrics['profit_factor'] >= 1.5:
        print("  [GREAT] PF >= 1.5")
    elif metrics['profit_factor'] >= 1.3:
        print("  [GOOD] PF >= 1.3")
    elif metrics['profit_factor'] >= 1.0:
        print("  [OK] PF >= 1.0")
    else:
        print("  [FAIL] PF < 1.0")
    
    if metrics['max_drawdown'] < 0.05:
        print("  [GREAT] DD < 5%")
    elif metrics['max_drawdown'] < 0.08:
        print("  [GOOD] DD < 8%")
    elif metrics['max_drawdown'] < 0.10:
        print("  [OK] DD < 10%")
    else:
        print("  [FAIL] DD >= 10%")
    
    if metrics['profit_factor'] >= 1.3 and metrics['max_drawdown'] < 0.08:
        print("\n✅ READY FOR ORACLE VALIDATION")
    else:
        print("\n⚠️ NEEDS MORE OPTIMIZATION")
    
    print("=" * 70)
    
    return metrics


if __name__ == "__main__":
    main()
