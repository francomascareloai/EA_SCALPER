#!/usr/bin/env python3
"""
Baseline Backtest - MA Cross Strategy on M5 XAUUSD
==================================================
Simple, fast backtester to establish baseline performance.
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime

# Configuration
CONFIG = {
    'initial_balance': 100000,
    'risk_per_trade': 0.005,     # 0.5%
    'atr_period': 14,
    'atr_sl_mult': 2.0,
    'atr_tp_mult': 3.0,          # 1.5 RR
    'fast_ma': 20,
    'slow_ma': 50,
    'spread_points': 30,
    'point_value': 0.01,
    'max_daily_dd': 0.05,        # 5% FTMO
    'max_total_dd': 0.10,        # 10% FTMO
}


def load_m5_data(filepath: str) -> pd.DataFrame:
    """Load M5 OHLC data from MT5 export"""
    print(f"Loading {filepath}...")
    df = pd.read_csv(filepath)
    
    # Combine date and time
    df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'])
    df.set_index('datetime', inplace=True)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].copy()
    df.columns = ['open', 'high', 'low', 'close', 'volume']
    
    print(f"Loaded {len(df):,} bars from {df.index[0]} to {df.index[-1]}")
    return df


def load_tick_data(filepath: str, max_rows: int = 5_000_000) -> pd.DataFrame:
    """Load tick data from tail of large CSV file using file seeking"""
    import os
    
    file_size = os.path.getsize(filepath)
    print(f"File size: {file_size / (1024**3):.2f} GB")
    print(f"Loading last ~{max_rows:,} ticks...")
    
    # Estimate bytes to read (avg ~35 bytes per line)
    bytes_to_read = min(max_rows * 40, file_size)
    
    # Read from end of file
    data = []
    with open(filepath, 'rb') as f:
        # Seek to near end
        f.seek(max(0, file_size - bytes_to_read))
        
        # Skip partial first line
        f.readline()
        
        # Read remaining lines
        print("Reading ticks...")
        line_count = 0
        for line in f:
            try:
                line = line.decode('utf-8').strip()
                parts = line.split(',')
                if len(parts) >= 3:
                    dt_str, bid, ask = parts[0], float(parts[1]), float(parts[2])
                    dt = datetime.strptime(dt_str, '%Y.%m.%d %H:%M:%S.%f')
                    mid = (bid + ask) / 2
                    spread = ask - bid
                    data.append({'datetime': dt, 'bid': bid, 'ask': ask, 'mid': mid, 'spread': spread})
                    line_count += 1
                    if line_count % 1_000_000 == 0:
                        print(f"  Processed {line_count:,} ticks...")
            except:
                continue
    
    print(f"Parsed {len(data):,} ticks")
    
    df = pd.DataFrame(data)
    df.set_index('datetime', inplace=True)
    print(f"Date range: {df.index[0]} to {df.index[-1]}")
    
    # Resample to M5 OHLC
    print("Resampling to M5...")
    ohlc = df['mid'].resample('5min').ohlc()
    ohlc.columns = ['open', 'high', 'low', 'close']
    ohlc['volume'] = df['mid'].resample('5min').count()
    ohlc['spread'] = df['spread'].resample('5min').mean()
    ohlc = ohlc.dropna()
    
    print(f"Resampled to {len(ohlc):,} M5 bars")
    return ohlc


def calculate_indicators(df: pd.DataFrame) -> pd.DataFrame:
    """Calculate MA cross and ATR"""
    # Moving averages
    df['ma_fast'] = df['close'].rolling(CONFIG['fast_ma']).mean()
    df['ma_slow'] = df['close'].rolling(CONFIG['slow_ma']).mean()
    
    # ATR
    df['tr'] = np.maximum(
        df['high'] - df['low'],
        np.maximum(
            abs(df['high'] - df['close'].shift(1)),
            abs(df['low'] - df['close'].shift(1))
        )
    )
    df['atr'] = df['tr'].rolling(CONFIG['atr_period']).mean()
    
    # Signals
    df['ma_cross_up'] = (df['ma_fast'] > df['ma_slow']) & (df['ma_fast'].shift(1) <= df['ma_slow'].shift(1))
    df['ma_cross_down'] = (df['ma_fast'] < df['ma_slow']) & (df['ma_fast'].shift(1) >= df['ma_slow'].shift(1))
    
    return df.dropna()


def run_backtest(df: pd.DataFrame) -> dict:
    """Run vectorized backtest simulation"""
    balance = CONFIG['initial_balance']
    peak_balance = balance
    position = None
    trades = []
    daily_pnl = {}
    
    for idx, row in df.iterrows():
        date_key = idx.date()
        
        # Initialize daily P&L tracking
        if date_key not in daily_pnl:
            daily_pnl[date_key] = 0
            daily_start_balance = balance
        
        # Check FTMO limits
        current_daily_dd = -daily_pnl[date_key] / CONFIG['initial_balance']
        current_total_dd = (peak_balance - balance) / peak_balance if peak_balance > 0 else 0
        
        if current_daily_dd >= CONFIG['max_daily_dd']:
            if position:
                # Force close
                pnl = close_position(position, row['close'], 'DAILY_DD')
                trades.append(pnl)
                balance += pnl['pnl']
                daily_pnl[date_key] += pnl['pnl']
                position = None
            continue
            
        if current_total_dd >= CONFIG['max_total_dd']:
            if position:
                pnl = close_position(position, row['close'], 'TOTAL_DD')
                trades.append(pnl)
                balance += pnl['pnl']
                daily_pnl[date_key] += pnl['pnl']
                position = None
            break  # Stop trading
        
        # Manage existing position
        if position:
            # Check SL/TP
            if position['direction'] == 'BUY':
                if row['low'] <= position['sl']:
                    pnl = close_position(position, position['sl'], 'SL')
                    trades.append(pnl)
                    balance += pnl['pnl']
                    daily_pnl[date_key] += pnl['pnl']
                    position = None
                elif row['high'] >= position['tp']:
                    pnl = close_position(position, position['tp'], 'TP')
                    trades.append(pnl)
                    balance += pnl['pnl']
                    daily_pnl[date_key] += pnl['pnl']
                    position = None
            else:  # SELL
                if row['high'] >= position['sl']:
                    pnl = close_position(position, position['sl'], 'SL')
                    trades.append(pnl)
                    balance += pnl['pnl']
                    daily_pnl[date_key] += pnl['pnl']
                    position = None
                elif row['low'] <= position['tp']:
                    pnl = close_position(position, position['tp'], 'TP')
                    trades.append(pnl)
                    balance += pnl['pnl']
                    daily_pnl[date_key] += pnl['pnl']
                    position = None
        
        # New entry signals (only if no position)
        if position is None:
            atr = row['atr']
            if pd.isna(atr) or atr <= 0:
                continue
                
            spread = CONFIG['spread_points'] * CONFIG['point_value']
            
            if row['ma_cross_up']:
                entry = row['close'] + spread/2
                sl = entry - atr * CONFIG['atr_sl_mult']
                tp = entry + atr * CONFIG['atr_tp_mult']
                risk_amount = balance * CONFIG['risk_per_trade']
                sl_distance = entry - sl
                lots = risk_amount / (sl_distance * 100)  # XAUUSD: 1 lot = 100 oz
                lots = max(0.01, min(lots, 10.0))  # Clamp
                
                position = {
                    'direction': 'BUY',
                    'entry_time': idx,
                    'entry': entry,
                    'sl': sl,
                    'tp': tp,
                    'lots': lots
                }
                
            elif row['ma_cross_down']:
                entry = row['close'] - spread/2
                sl = entry + atr * CONFIG['atr_sl_mult']
                tp = entry - atr * CONFIG['atr_tp_mult']
                risk_amount = balance * CONFIG['risk_per_trade']
                sl_distance = sl - entry
                lots = risk_amount / (sl_distance * 100)
                lots = max(0.01, min(lots, 10.0))
                
                position = {
                    'direction': 'SELL',
                    'entry_time': idx,
                    'entry': entry,
                    'sl': sl,
                    'tp': tp,
                    'lots': lots
                }
        
        # Update peak
        if balance > peak_balance:
            peak_balance = balance
    
    # Close any remaining position
    if position:
        pnl = close_position(position, df.iloc[-1]['close'], 'END')
        trades.append(pnl)
        balance += pnl['pnl']
    
    return {
        'trades': trades,
        'final_balance': balance,
        'peak_balance': peak_balance
    }


def close_position(pos: dict, exit_price: float, reason: str) -> dict:
    """Calculate P&L for closing a position"""
    if pos['direction'] == 'BUY':
        pnl = (exit_price - pos['entry']) * pos['lots'] * 100
    else:
        pnl = (pos['entry'] - exit_price) * pos['lots'] * 100
    
    return {
        'entry_time': pos['entry_time'],
        'direction': pos['direction'],
        'entry': pos['entry'],
        'exit': exit_price,
        'sl': pos['sl'],
        'tp': pos['tp'],
        'lots': pos['lots'],
        'pnl': pnl,
        'reason': reason
    }


def calculate_metrics(trades: list, initial: float, final: float, peak: float) -> dict:
    """Calculate performance metrics"""
    if not trades:
        return {'error': 'No trades generated'}
    
    pnls = [t['pnl'] for t in trades]
    wins = [p for p in pnls if p > 0]
    losses = [p for p in pnls if p < 0]
    
    total_trades = len(trades)
    win_rate = len(wins) / total_trades if total_trades > 0 else 0
    
    gross_profit = sum(wins) if wins else 0
    gross_loss = abs(sum(losses)) if losses else 0
    profit_factor = gross_profit / gross_loss if gross_loss > 0 else float('inf')
    
    # Max drawdown
    equity = [initial]
    for pnl in pnls:
        equity.append(equity[-1] + pnl)
    equity = np.array(equity)
    peak_equity = np.maximum.accumulate(equity)
    drawdown = (peak_equity - equity) / peak_equity
    max_dd = drawdown.max()
    
    # Returns
    total_return = (final - initial) / initial
    
    # Sharpe (annualized, assuming M5 bars)
    if len(pnls) > 1:
        returns = np.array(pnls) / initial
        sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252 * 288) if np.std(returns) > 0 else 0
    else:
        sharpe = 0
    
    # SQN
    sqn = np.sqrt(total_trades) * np.mean(pnls) / np.std(pnls) if np.std(pnls) > 0 else 0
    
    return {
        'total_trades': total_trades,
        'win_rate': win_rate,
        'profit_factor': profit_factor,
        'total_return': total_return,
        'max_drawdown': max_dd,
        'sharpe_ratio': sharpe,
        'sqn': sqn,
        'gross_profit': gross_profit,
        'gross_loss': gross_loss,
        'avg_win': np.mean(wins) if wins else 0,
        'avg_loss': np.mean(losses) if losses else 0,
        'final_balance': final,
        'net_profit': final - initial
    }


def print_report(metrics: dict, trades: list):
    """Print backtest report"""
    print("\n" + "="*60)
    print("           BASELINE BACKTEST REPORT")
    print("="*60)
    
    if 'error' in metrics:
        print(f"\n[ERROR] {metrics['error']}")
        return
    
    print(f"\nTotal Trades:     {metrics['total_trades']}")
    print(f"Win Rate:         {metrics['win_rate']:.1%}")
    print(f"Profit Factor:    {metrics['profit_factor']:.2f}")
    print(f"Sharpe Ratio:     {metrics['sharpe_ratio']:.2f}")
    print(f"SQN:              {metrics['sqn']:.2f}")
    print(f"\nMax Drawdown:     {metrics['max_drawdown']:.2%}")
    print(f"Total Return:     {metrics['total_return']:.2%}")
    print(f"Net Profit:       ${metrics['net_profit']:,.2f}")
    print(f"Final Balance:    ${metrics['final_balance']:,.2f}")
    
    print(f"\nGross Profit:     ${metrics['gross_profit']:,.2f}")
    print(f"Gross Loss:       ${metrics['gross_loss']:,.2f}")
    print(f"Avg Win:          ${metrics['avg_win']:,.2f}")
    print(f"Avg Loss:         ${metrics['avg_loss']:,.2f}")
    
    # FTMO Assessment
    print("\n" + "-"*40)
    print("FTMO COMPLIANCE CHECK:")
    
    if metrics['max_drawdown'] < 0.05:
        print("  [OK] Max DD < 5% daily limit")
    elif metrics['max_drawdown'] < 0.10:
        print("  [WARN] Max DD between 5-10%")
    else:
        print("  [FAIL] Max DD > 10% total limit")
    
    if metrics['profit_factor'] >= 1.5:
        print(f"  [OK] Profit Factor >= 1.5")
    elif metrics['profit_factor'] >= 1.0:
        print(f"  [WARN] Profit Factor between 1.0-1.5")
    else:
        print(f"  [FAIL] Profit Factor < 1.0 (losing strategy)")
    
    if metrics['total_trades'] >= 50:
        print(f"  [OK] Sufficient trades for validation ({metrics['total_trades']})")
    else:
        print(f"  [WARN] Low trade count ({metrics['total_trades']}) - may not be statistically significant")
    
    # Exit reasons
    print("\n" + "-"*40)
    print("EXIT REASONS:")
    reasons = {}
    for t in trades:
        r = t['reason']
        reasons[r] = reasons.get(r, 0) + 1
    for r, count in sorted(reasons.items(), key=lambda x: -x[1]):
        print(f"  {r}: {count} ({count/len(trades):.1%})")
    
    print("="*60)


def export_trades(trades: list, filepath: str):
    """Export trades to CSV for Oracle validation"""
    if not trades:
        return
    
    df = pd.DataFrame(trades)
    df.to_csv(filepath, index=False)
    print(f"\nTrades exported to: {filepath}")


def main():
    # Data path - TICK DATA
    data_path = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv")
    
    # Load tick data (last 5M ticks ~200MB) and resample to M5
    df = load_tick_data(str(data_path), max_rows=5_000_000)
    
    # Calculate indicators
    print("Calculating indicators...")
    df = calculate_indicators(df)
    print(f"Signals: {df['ma_cross_up'].sum()} buy, {df['ma_cross_down'].sum()} sell")
    
    # Run backtest
    print("\nRunning backtest...")
    results = run_backtest(df)
    
    # Calculate metrics
    metrics = calculate_metrics(
        results['trades'],
        CONFIG['initial_balance'],
        results['final_balance'],
        results['peak_balance']
    )
    
    # Print report
    print_report(metrics, results['trades'])
    
    # Export trades
    export_path = Path("C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/baseline_trades.csv")
    export_trades(results['trades'], str(export_path))
    
    return metrics


if __name__ == "__main__":
    main()
