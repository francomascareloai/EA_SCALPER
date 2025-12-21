#!/usr/bin/env python3
"""
SMC Optimized Test - Order Blocks with Proper Mitigation
=========================================================
Each OB can only be traded ONCE (mitigated after first touch).
"""

import numpy as np
import pandas as pd
from datetime import datetime
from dataclasses import dataclass
from typing import List, Dict, Optional
import warnings
warnings.filterwarnings('ignore')


@dataclass
class OrderBlock:
    idx: int
    time: datetime
    ob_type: str  # 'BULL' or 'BEAR'
    top: float
    bottom: float
    strength: float
    confirm_idx: int
    mitigated: bool = False
    

def load_data(filepath: str) -> pd.DataFrame:
    df = pd.read_csv(filepath)
    df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'])
    df.set_index('datetime', inplace=True)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].copy()
    df.columns = ['open', 'high', 'low', 'close', 'volume']
    return df


def detect_order_blocks(df: pd.DataFrame, min_displacement: float = 2.0) -> List[OrderBlock]:
    """Detect Order Blocks with displacement validation (WP3 causal)."""
    # Add ATR
    df['tr'] = np.maximum(
        df['high'] - df['low'],
        np.maximum(
            abs(df['high'] - df['close'].shift(1)),
            abs(df['low'] - df['close'].shift(1))
        )
    )
    df['atr'] = df['tr'].rolling(14).mean().fillna(1.0)

    order_blocks: List[OrderBlock] = []
    confirm_lag = 3

    for i in range(5, len(df) - confirm_lag):
        atr = df['atr'].iloc[i]
        confirm_idx = i + confirm_lag

        # Check for Bullish OB: Bearish candle followed by bullish displacement
        if df['close'].iloc[i] < df['open'].iloc[i]:  # Bearish candle
            # Check displacement in next 1-3 candles
            max_high = df['high'].iloc[i + 1:confirm_idx + 1].max()
            displacement = max_high - df['close'].iloc[i]

            if displacement >= atr * min_displacement:
                order_blocks.append(
                    OrderBlock(
                        idx=i,
                        time=df.index[i],
                        ob_type='BULL',
                        top=df['open'].iloc[i],
                        bottom=df['low'].iloc[i],
                        strength=displacement / atr,
                        confirm_idx=confirm_idx,
                    )
                )

        # Check for Bearish OB: Bullish candle followed by bearish displacement
        if df['close'].iloc[i] > df['open'].iloc[i]:  # Bullish candle
            # Check displacement in next 1-3 candles
            min_low = df['low'].iloc[i + 1:confirm_idx + 1].min()
            displacement = df['close'].iloc[i] - min_low

            if displacement >= atr * min_displacement:
                order_blocks.append(
                    OrderBlock(
                        idx=i,
                        time=df.index[i],
                        ob_type='BEAR',
                        top=df['high'].iloc[i],
                        bottom=df['open'].iloc[i],
                        strength=displacement / atr,
                        confirm_idx=confirm_idx,
                    )
                )

    return order_blocks


def backtest_ob_strategy(df: pd.DataFrame, order_blocks: List[OrderBlock],
                         initial: float = 100000, risk: float = 0.005,
                         sl_mult: float = 2.0, tp_mult: float = 3.0,
                         spread: float = 0.45, max_dd: float = 0.10) -> Dict:
    """
    Backtest Order Block strategy with proper mitigation.
    Each OB is only traded ONCE.
    """
    # Add ATR and MA for bias
    df['tr'] = np.maximum(
        df['high'] - df['low'],
        np.maximum(
            abs(df['high'] - df['close'].shift(1)),
            abs(df['low'] - df['close'].shift(1))
        )
    )
    df['atr'] = df['tr'].rolling(14).mean().fillna(1.0)
    df['ma200'] = df['close'].rolling(200).mean()
    
    balance = initial
    peak = initial
    position = None
    trades = []
    
    # Track which OBs have been used
    used_obs = set()
    
    for i, (idx, row) in enumerate(df.iterrows()):
        if i < 200:  # Skip warmup
            continue
            
        # Check DD limit
        dd = (peak - balance) / peak if peak > 0 else 0
        if dd >= max_dd:
            if position:
                pnl = close_position(position, row, spread)
                trades.append({'pnl': pnl, 'reason': 'DD_LIMIT'})
                balance += pnl
            break
        
        # Manage existing position
        if position:
            result = check_exit(position, row)
            if result:
                trades.append(result)
                balance += result['pnl']
                if balance > peak:
                    peak = balance
                position = None
        
        # Look for entry signals at unmitigated OBs
        if position is None:
            atr = row['atr']
            close = row['close']
            ma200 = row['ma200']
            
            if pd.isna(atr) or pd.isna(ma200):
                continue
            
            # Find active unmitigated OBs
            for ob in order_blocks:
                if ob.idx in used_obs:
                    continue
                # WP3: OB only becomes tradable after confirmation lag.
                if i < ob.confirm_idx:
                    continue
                
                # Check if price is at OB zone
                if ob.ob_type == 'BULL':
                    # Buy at bullish OB in uptrend
                    if close > ma200 and row['low'] <= ob.top and row['close'] >= ob.bottom:
                        # Mark as used
                        used_obs.add(ob.idx)
                        
                        # Open long position
                        entry = close + spread/2
                        sl = entry - atr * sl_mult
                        tp = entry + atr * tp_mult
                        lots = (balance * risk) / ((entry - sl) * 100)
                        lots = max(0.01, min(lots, 10.0))
                        
                        position = {
                            'dir': 'BUY',
                            'entry': entry,
                            'sl': sl,
                            'tp': tp,
                            'lots': lots,
                            'ob_strength': ob.strength
                        }
                        break
                
                elif ob.ob_type == 'BEAR':
                    # Sell at bearish OB in downtrend
                    if close < ma200 and row['high'] >= ob.bottom and row['close'] <= ob.top:
                        # Mark as used
                        used_obs.add(ob.idx)
                        
                        # Open short position
                        entry = close - spread/2
                        sl = entry + atr * sl_mult
                        tp = entry - atr * tp_mult
                        lots = (balance * risk) / ((sl - entry) * 100)
                        lots = max(0.01, min(lots, 10.0))
                        
                        position = {
                            'dir': 'SELL',
                            'entry': entry,
                            'sl': sl,
                            'tp': tp,
                            'lots': lots,
                            'ob_strength': ob.strength
                        }
                        break
    
    # Close remaining position
    if position:
        pnl = close_position(position, df.iloc[-1], spread)
        trades.append({'pnl': pnl, 'reason': 'END'})
        balance += pnl
    
    return calculate_metrics(trades, initial, balance, peak, len(order_blocks), len(used_obs))


def check_exit(position: Dict, row: pd.Series) -> Optional[Dict]:
    """Check SL/TP"""
    if position['dir'] == 'BUY':
        if row['low'] <= position['sl']:
            pnl = (position['sl'] - position['entry']) * position['lots'] * 100
            return {'pnl': pnl, 'reason': 'SL'}
        if row['high'] >= position['tp']:
            pnl = (position['tp'] - position['entry']) * position['lots'] * 100
            return {'pnl': pnl, 'reason': 'TP'}
    else:
        if row['high'] >= position['sl']:
            pnl = (position['entry'] - position['sl']) * position['lots'] * 100
            return {'pnl': pnl, 'reason': 'SL'}
        if row['low'] <= position['tp']:
            pnl = (position['entry'] - position['tp']) * position['lots'] * 100
            return {'pnl': pnl, 'reason': 'TP'}
    return None


def close_position(position: Dict, row: pd.Series, spread: float) -> float:
    """Force close position"""
    if position['dir'] == 'BUY':
        exit_price = row['close'] - spread/2
        return (exit_price - position['entry']) * position['lots'] * 100
    else:
        exit_price = row['close'] + spread/2
        return (position['entry'] - exit_price) * position['lots'] * 100


def calculate_metrics(trades: List[Dict], initial: float, final: float, 
                     peak: float, total_obs: int, used_obs: int) -> Dict:
    """Calculate performance metrics"""
    if not trades:
        return {'error': 'No trades', 'total_trades': 0}
    
    pnls = [t['pnl'] for t in trades]
    wins = [p for p in pnls if p > 0]
    losses = [p for p in pnls if p < 0]
    
    n = len(trades)
    wr = len(wins) / n if n > 0 else 0
    gp = sum(wins) if wins else 0
    gl = abs(sum(losses)) if losses else 1
    pf = gp / gl if gl > 0 else 0
    
    # Max DD
    equity = [initial]
    for p in pnls:
        equity.append(equity[-1] + p)
    eq = np.array(equity)
    pk = np.maximum.accumulate(eq)
    dd = ((pk - eq) / pk).max()
    
    # Exit reasons
    reasons = {}
    for t in trades:
        r = t['reason']
        reasons[r] = reasons.get(r, 0) + 1
    
    return {
        'total_trades': n,
        'wins': len(wins),
        'losses': len(losses),
        'win_rate': wr,
        'profit_factor': pf,
        'max_drawdown': dd,
        'total_return': (final - initial) / initial,
        'net_profit': final - initial,
        'final_balance': final,
        'exit_reasons': reasons,
        'total_obs': total_obs,
        'used_obs': used_obs,
        'ob_utilization': used_obs / total_obs if total_obs > 0 else 0
    }


def run_parameter_sweep(df: pd.DataFrame) -> List[Dict]:
    """Test different parameter combinations"""
    results = []
    
    params_to_test = [
        {'displacement': 1.5, 'sl_mult': 1.5, 'tp_mult': 2.25},  # Tighter
        {'displacement': 2.0, 'sl_mult': 2.0, 'tp_mult': 3.0},   # Standard
        {'displacement': 2.5, 'sl_mult': 2.0, 'tp_mult': 4.0},   # Wider TP
        {'displacement': 2.0, 'sl_mult': 1.5, 'tp_mult': 3.0},   # Tighter SL
        {'displacement': 3.0, 'sl_mult': 2.0, 'tp_mult': 3.0},   # Higher displacement
    ]
    
    for p in params_to_test:
        print(f"Testing: displacement={p['displacement']}, SL={p['sl_mult']}x, TP={p['tp_mult']}x...", end=" ")
        
        obs = detect_order_blocks(df.copy(), min_displacement=p['displacement'])
        metrics = backtest_ob_strategy(
            df.copy(), obs,
            sl_mult=p['sl_mult'],
            tp_mult=p['tp_mult']
        )
        
        metrics['params'] = p
        results.append(metrics)
        
        if 'error' not in metrics:
            print(f"Trades: {metrics['total_trades']}, PF: {metrics['profit_factor']:.2f}, DD: {metrics['max_drawdown']:.2%}")
        else:
            print("ERROR")
    
    return results


def main():
    print("=" * 80)
    print("            SMC ORDER BLOCK STRATEGY - OPTIMIZED TEST")
    print("=" * 80)
    
    # Load data
    path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
    print(f"\nLoading data...")
    df = load_data(path)
    print(f"Loaded {len(df):,} bars ({df.index[0].date()} to {df.index[-1].date()})")
    
    # Detect Order Blocks
    print("\nDetecting Order Blocks...")
    obs = detect_order_blocks(df, min_displacement=2.0)
    bull_obs = len([o for o in obs if o.ob_type == 'BULL'])
    bear_obs = len([o for o in obs if o.ob_type == 'BEAR'])
    print(f"Found {len(obs):,} Order Blocks ({bull_obs} bullish, {bear_obs} bearish)")
    
    # Standard backtest
    print("\n" + "-" * 40)
    print("STANDARD PARAMETERS (SL=2x ATR, TP=3x ATR)")
    print("-" * 40)
    
    metrics = backtest_ob_strategy(df.copy(), obs)
    
    if 'error' in metrics:
        print(f"ERROR: {metrics['error']}")
    else:
        print(f"\nTotal Trades:    {metrics['total_trades']}")
        print(f"  Wins:          {metrics['wins']}")
        print(f"  Losses:        {metrics['losses']}")
        print(f"Win Rate:        {metrics['win_rate']:.1%}")
        print(f"Profit Factor:   {metrics['profit_factor']:.2f}")
        print(f"Max Drawdown:    {metrics['max_drawdown']:.2%}")
        print(f"Total Return:    {metrics['total_return']:.2%}")
        print(f"Net Profit:      ${metrics['net_profit']:,.2f}")
        print(f"\nOB Utilization:  {metrics['ob_utilization']:.1%} ({metrics['used_obs']}/{metrics['total_obs']})")
        print(f"\nExit Reasons:")
        for reason, count in sorted(metrics['exit_reasons'].items(), key=lambda x: -x[1]):
            pct = count / metrics['total_trades'] * 100
            print(f"  {reason}: {count} ({pct:.1f}%)")
    
    # Parameter sweep
    print("\n" + "=" * 80)
    print("                    PARAMETER SWEEP")
    print("=" * 80)
    
    results = run_parameter_sweep(df)
    
    # Find best
    valid = [r for r in results if 'error' not in r]
    if valid:
        best = max(valid, key=lambda x: x['profit_factor'])
        
        print("\n" + "-" * 40)
        print("BEST CONFIGURATION:")
        print("-" * 40)
        print(f"Parameters: {best['params']}")
        print(f"Trades:     {best['total_trades']}")
        print(f"Win Rate:   {best['win_rate']:.1%}")
        print(f"PF:         {best['profit_factor']:.2f}")
        print(f"Max DD:     {best['max_drawdown']:.2%}")
        print(f"Return:     {best['total_return']:.2%}")
    
    # Final assessment
    print("\n" + "=" * 80)
    print("                    FINAL ASSESSMENT")
    print("=" * 80)
    
    best_pf = max(r['profit_factor'] for r in valid) if valid else 0
    
    if best_pf >= 1.3:
        print("\n[GOOD] Best PF >= 1.3 - Strategy has potential")
        print("Next: Run Walk-Forward Analysis for robustness")
    elif best_pf >= 1.0:
        print("\n[OK] Best PF >= 1.0 - Marginally profitable")
        print("Need: Add more confluence factors")
    else:
        print("\n[FAIL] Best PF < 1.0 - Strategy is losing")
        print("Need: Fundamental strategy review")
    
    print("=" * 80)
    
    return results


if __name__ == "__main__":
    main()
