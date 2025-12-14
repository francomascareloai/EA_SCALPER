#!/usr/bin/env python3
"""
XAUUSD Strategy Backtester v1.0
================================
Fast Python backtesting for strategy validation before MT5.

Uses vectorized operations for speed.
Outputs trades.csv compatible with Oracle validation pipeline.

Author: ORACLE + FORGE
Date: 2025-12-01
"""

import pandas as pd
import numpy as np
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, List, Tuple
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')


@dataclass
class BacktestConfig:
    """Backtest configuration"""
    # Risk
    initial_balance: float = 100000.0
    risk_per_trade: float = 0.005  # 0.5%
    max_daily_dd: float = 0.05     # 5% FTMO
    max_total_dd: float = 0.10     # 10% FTMO
    
    # Execution
    spread_points: float = 30.0    # Average spread
    slippage_points: float = 5.0   # Average slippage
    point_value: float = 0.01     # XAUUSD point value
    
    # Strategy
    atr_period: int = 14
    atr_sl_mult: float = 2.0      # SL = ATR * mult
    atr_tp_mult: float = 3.0      # TP = ATR * mult (1.5 RR)
    
    # Session filter (GMT hours)
    session_start: int = 8        # London open
    session_end: int = 20         # NY close
    
    # Regime filter
    use_regime_filter: bool = False
    hurst_period: int = 100
    hurst_threshold: float = 0.55  # > 0.55 = trending
    
    # Signal
    use_ma_cross: bool = True
    fast_ma: int = 20
    slow_ma: int = 50


@dataclass
class Trade:
    """Single trade record"""
    entry_time: datetime
    exit_time: datetime
    direction: str  # 'BUY' or 'SELL'
    entry_price: float
    exit_price: float
    sl_price: float
    tp_price: float
    lots: float
    pnl: float
    pnl_pct: float
    exit_reason: str  # 'TP', 'SL', 'SIGNAL', 'EOD'
    balance_after: float


class XAUUSDBacktester:
    """Fast vectorized backtester for XAUUSD"""
    
    def __init__(self, config: BacktestConfig = None):
        self.config = config or BacktestConfig()
        self.trades: List[Trade] = []
        self.equity_curve: List[float] = []
        
    def load_data(self, filepath: Path, timeframe: str = 'M5', 
                  start_date: str = None, end_date: str = None,
                  max_rows: int = None) -> pd.DataFrame:
        """Load and prepare OHLC data"""
        print(f"Loading data from {filepath}...")
        
        # Check file type
        file_size_gb = filepath.stat().st_size / (1024**3)
        print(f"File size: {file_size_gb:.2f} GB")
        
        # For large tick files, we need to resample to OHLC
        if file_size_gb > 1:
            print("Large file - loading from TAIL only (recent data)...")
            df = self._load_tick_tail(filepath, max_rows or 5_000_000)
            df = self._resample_to_ohlc(df, timeframe)
        else:
            df = pd.read_csv(filepath)
            
        # Filter date range
        if start_date:
            df = df[df['datetime'] >= pd.to_datetime(start_date)]
        if end_date:
            df = df[df['datetime'] <= pd.to_datetime(end_date)]
            
        print(f"Loaded {len(df):,} bars from {df['datetime'].min()} to {df['datetime'].max()}")
        return df
    
    def _load_tick_tail(self, filepath: Path, max_rows: int) -> pd.DataFrame:
        """Load only the tail (recent data) from large tick file"""
        print(f"  Reading last {max_rows:,} ticks from file...")
        
        file_size = filepath.stat().st_size
        # Estimate bytes to read (avg ~35 bytes per line for tick data)
        bytes_to_read = min(max_rows * 40, file_size)
        
        tail_lines = []
        with open(filepath, 'rb') as f:
            f.seek(max(0, file_size - bytes_to_read))
            f.readline()  # Skip partial line
            content = f.read().decode('utf-8', errors='ignore')
            lines = content.strip().split('\n')
            tail_lines = lines[-max_rows:]
        
        print(f"  Got {len(tail_lines):,} lines from tail")
        
        # Parse to DataFrame
        data = []
        for line in tail_lines:
            parts = line.split(',')
            if len(parts) >= 3:
                data.append(parts[:3])
        
        df = pd.DataFrame(data, columns=['datetime', 'bid', 'ask'])
        
        # Parse datetime and prices
        df['datetime'] = pd.to_datetime(df['datetime'], format='%Y.%m.%d %H:%M:%S.%f', errors='coerce')
        df['bid'] = pd.to_numeric(df['bid'], errors='coerce')
        df['ask'] = pd.to_numeric(df['ask'], errors='coerce')
        df = df.dropna()
        
        # Calculate mid price
        df['price'] = (df['bid'] + df['ask']) / 2
        
        # Sort by datetime
        df = df.sort_values('datetime').reset_index(drop=True)
        
        print(f"  Loaded {len(df):,} ticks from {df['datetime'].min()} to {df['datetime'].max()}")
        return df
    
    def _resample_to_ohlc(self, tick_df: pd.DataFrame, timeframe: str) -> pd.DataFrame:
        """Resample tick data to OHLC bars"""
        print(f"  Resampling to {timeframe}...")
        
        tick_df = tick_df.set_index('datetime').sort_index()
        
        # Map timeframe to pandas resample rule
        tf_map = {
            'M1': '1T', 'M5': '5T', 'M15': '15T', 'M30': '30T',
            'H1': '1H', 'H4': '4H', 'D1': '1D'
        }
        rule = tf_map.get(timeframe, '5T')
        
        ohlc = tick_df['price'].resample(rule).ohlc()
        ohlc.columns = ['open', 'high', 'low', 'close']
        ohlc = ohlc.dropna()
        ohlc = ohlc.reset_index()
        
        print(f"  Created {len(ohlc):,} {timeframe} bars")
        return ohlc
    
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """Calculate all required indicators"""
        print("Calculating indicators...")
        
        # ATR
        high_low = df['high'] - df['low']
        high_close = np.abs(df['high'] - df['close'].shift(1))
        low_close = np.abs(df['low'] - df['close'].shift(1))
        tr = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
        df['atr'] = tr.rolling(window=self.config.atr_period).mean()
        
        # Moving averages
        if self.config.use_ma_cross:
            df['ma_fast'] = df['close'].rolling(window=self.config.fast_ma).mean()
            df['ma_slow'] = df['close'].rolling(window=self.config.slow_ma).mean()
        
        # Hurst exponent (simplified - using returns autocorrelation)
        if self.config.use_regime_filter:
            df['hurst'] = self._calculate_hurst_rolling(df['close'], self.config.hurst_period)
        
        # Session (hour of day)
        df['hour'] = df['datetime'].dt.hour
        
        return df.dropna()
    
    def _calculate_hurst_rolling(self, prices: pd.Series, window: int) -> pd.Series:
        """Simplified Hurst exponent using R/S method"""
        def hurst(ts):
            if len(ts) < 20:
                return 0.5
            returns = np.diff(np.log(ts))
            mean_r = np.mean(returns)
            std_r = np.std(returns)
            if std_r == 0:
                return 0.5
            cumdev = np.cumsum(returns - mean_r)
            R = np.max(cumdev) - np.min(cumdev)
            S = std_r
            RS = R / S if S > 0 else 0
            n = len(returns)
            if RS > 0 and n > 1:
                H = np.log(RS) / np.log(n)
                return np.clip(H, 0, 1)
            return 0.5
        
        return prices.rolling(window=window).apply(hurst, raw=True)
    
    def generate_signals(self, df: pd.DataFrame) -> pd.DataFrame:
        """Generate trading signals"""
        print("Generating signals...")
        
        df['signal'] = 0
        
        # MA Cross signals
        if self.config.use_ma_cross:
            # Buy: fast MA crosses above slow MA
            df.loc[(df['ma_fast'] > df['ma_slow']) & 
                   (df['ma_fast'].shift(1) <= df['ma_slow'].shift(1)), 'signal'] = 1
            # Sell: fast MA crosses below slow MA
            df.loc[(df['ma_fast'] < df['ma_slow']) & 
                   (df['ma_fast'].shift(1) >= df['ma_slow'].shift(1)), 'signal'] = -1
        
        # Session filter
        session_mask = (df['hour'] >= self.config.session_start) & \
                       (df['hour'] < self.config.session_end)
        df.loc[~session_mask, 'signal'] = 0
        
        # Regime filter
        if self.config.use_regime_filter:
            # Only trade when trending (Hurst > threshold)
            df.loc[df['hurst'] < self.config.hurst_threshold, 'signal'] = 0
        
        buy_signals = (df['signal'] == 1).sum()
        sell_signals = (df['signal'] == -1).sum()
        print(f"  Generated {buy_signals} BUY signals, {sell_signals} SELL signals")
        
        return df
    
    def run_backtest(self, df: pd.DataFrame) -> List[Trade]:
        """Run the backtest simulation"""
        print("Running backtest...")
        
        balance = self.config.initial_balance
        peak_balance = balance
        daily_start_balance = balance
        current_date = None
        
        position = None  # Current position
        self.trades = []
        self.equity_curve = [balance]
        
        for i in range(len(df)):
            row = df.iloc[i]
            
            # Daily reset check
            trade_date = row['datetime'].date()
            if current_date != trade_date:
                daily_start_balance = balance
                current_date = trade_date
            
            # Check daily DD limit
            daily_dd = (daily_start_balance - balance) / daily_start_balance
            if daily_dd >= self.config.max_daily_dd:
                if position:
                    # Force close
                    trade = self._close_position(position, row, 'DAILY_DD', balance)
                    balance += trade.pnl
                    self.trades.append(trade)
                    position = None
                continue
            
            # Check total DD limit
            total_dd = (peak_balance - balance) / peak_balance
            if total_dd >= self.config.max_total_dd:
                if position:
                    trade = self._close_position(position, row, 'TOTAL_DD', balance)
                    balance += trade.pnl
                    self.trades.append(trade)
                    position = None
                continue
            
            # Manage existing position
            if position:
                # Check SL
                if position['direction'] == 'BUY':
                    if row['low'] <= position['sl']:
                        trade = self._close_position(position, row, 'SL', balance, exit_price=position['sl'])
                        balance += trade.pnl
                        self.trades.append(trade)
                        position = None
                    elif row['high'] >= position['tp']:
                        trade = self._close_position(position, row, 'TP', balance, exit_price=position['tp'])
                        balance += trade.pnl
                        self.trades.append(trade)
                        position = None
                else:  # SELL
                    if row['high'] >= position['sl']:
                        trade = self._close_position(position, row, 'SL', balance, exit_price=position['sl'])
                        balance += trade.pnl
                        self.trades.append(trade)
                        position = None
                    elif row['low'] <= position['tp']:
                        trade = self._close_position(position, row, 'TP', balance, exit_price=position['tp'])
                        balance += trade.pnl
                        self.trades.append(trade)
                        position = None
            
            # Open new position on signal (if no position)
            if position is None and row['signal'] != 0:
                atr = row['atr']
                sl_dist = atr * self.config.atr_sl_mult
                tp_dist = atr * self.config.atr_tp_mult
                
                # Add spread/slippage
                spread_cost = (self.config.spread_points + self.config.slippage_points) * self.config.point_value
                
                if row['signal'] == 1:  # BUY
                    entry = row['close'] + spread_cost / 2
                    sl = entry - sl_dist
                    tp = entry + tp_dist
                    direction = 'BUY'
                else:  # SELL
                    entry = row['close'] - spread_cost / 2
                    sl = entry + sl_dist
                    tp = entry - tp_dist
                    direction = 'SELL'
                
                # Position sizing (risk-based)
                risk_amount = balance * self.config.risk_per_trade
                lots = risk_amount / (sl_dist / self.config.point_value * 100)  # Simplified lot calc
                lots = max(0.01, min(lots, 10.0))  # Clamp
                
                position = {
                    'entry_time': row['datetime'],
                    'direction': direction,
                    'entry_price': entry,
                    'sl': sl,
                    'tp': tp,
                    'lots': lots
                }
            
            # Update equity curve
            self.equity_curve.append(balance)
            peak_balance = max(peak_balance, balance)
        
        # Close any remaining position at end
        if position:
            trade = self._close_position(position, df.iloc[-1], 'EOD', balance)
            balance += trade.pnl
            self.trades.append(trade)
        
        print(f"  Completed: {len(self.trades)} trades")
        return self.trades
    
    def _close_position(self, position: dict, row: pd.Series, 
                        reason: str, balance: float, 
                        exit_price: float = None) -> Trade:
        """Close a position and create trade record"""
        if exit_price is None:
            exit_price = row['close']
        
        if position['direction'] == 'BUY':
            pnl_points = (exit_price - position['entry_price']) / self.config.point_value
        else:
            pnl_points = (position['entry_price'] - exit_price) / self.config.point_value
        
        pnl = pnl_points * position['lots'] * 100  # Simplified P&L calc
        pnl_pct = pnl / balance if balance > 0 else 0
        
        return Trade(
            entry_time=position['entry_time'],
            exit_time=row['datetime'],
            direction=position['direction'],
            entry_price=position['entry_price'],
            exit_price=exit_price,
            sl_price=position['sl'],
            tp_price=position['tp'],
            lots=position['lots'],
            pnl=pnl,
            pnl_pct=pnl_pct,
            exit_reason=reason,
            balance_after=balance + pnl
        )
    
    def calculate_metrics(self) -> dict:
        """Calculate performance metrics"""
        if not self.trades:
            return {'error': 'No trades'}
        
        pnls = [t.pnl for t in self.trades]
        pnl_pcts = [t.pnl_pct for t in self.trades]
        
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        # Basic metrics
        total_pnl = sum(pnls)
        win_rate = len(wins) / len(pnls) if pnls else 0
        avg_win = np.mean(wins) if wins else 0
        avg_loss = abs(np.mean(losses)) if losses else 0
        profit_factor = sum(wins) / abs(sum(losses)) if losses else float('inf')
        
        # Drawdown
        equity = np.array(self.equity_curve)
        peak = np.maximum.accumulate(equity)
        dd = (peak - equity) / peak
        max_dd = np.max(dd)
        
        # Sharpe (annualized, assuming 5min bars = 252*24*12 bars/year)
        returns = np.diff(equity) / equity[:-1]
        sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252 * 24 * 12) if np.std(returns) > 0 else 0
        
        # SQN (System Quality Number)
        sqn = np.mean(pnls) / np.std(pnls) * np.sqrt(len(pnls)) if np.std(pnls) > 0 else 0
        
        return {
            'total_trades': len(self.trades),
            'total_pnl': total_pnl,
            'total_pnl_pct': total_pnl / self.config.initial_balance * 100,
            'win_rate': win_rate * 100,
            'profit_factor': profit_factor,
            'avg_win': avg_win,
            'avg_loss': avg_loss,
            'max_drawdown': max_dd * 100,
            'sharpe': sharpe,
            'sqn': sqn,
            'wins': len(wins),
            'losses': len(losses)
        }
    
    def export_trades(self, filepath: Path):
        """Export trades to CSV for Oracle validation"""
        if not self.trades:
            print("No trades to export")
            return
        
        data = []
        for t in self.trades:
            data.append({
                'entry_time': t.entry_time,
                'exit_time': t.exit_time,
                'direction': t.direction,
                'entry_price': t.entry_price,
                'exit_price': t.exit_price,
                'sl_price': t.sl_price,
                'tp_price': t.tp_price,
                'lots': t.lots,
                'pnl': t.pnl,
                'pnl_pct': t.pnl_pct,
                'exit_reason': t.exit_reason,
                'balance_after': t.balance_after
            })
        
        df = pd.DataFrame(data)
        df.to_csv(filepath, index=False)
        print(f"Exported {len(self.trades)} trades to {filepath}")
    
    def print_report(self, metrics: dict):
        """Print backtest report"""
        print("\n" + "="*60)
        print("BACKTEST REPORT")
        print("="*60)
        
        if 'error' in metrics:
            print(f"ERROR: {metrics['error']}")
            print("="*60)
            return
        
        print(f"Total Trades:    {metrics['total_trades']}")
        print(f"Total P&L:       ${metrics['total_pnl']:,.2f} ({metrics['total_pnl_pct']:.2f}%)")
        print(f"Win Rate:        {metrics['win_rate']:.1f}% ({metrics['wins']}W / {metrics['losses']}L)")
        print(f"Profit Factor:   {metrics['profit_factor']:.2f}")
        print(f"Avg Win:         ${metrics['avg_win']:,.2f}")
        print(f"Avg Loss:        ${metrics['avg_loss']:,.2f}")
        print(f"Max Drawdown:    {metrics['max_drawdown']:.2f}%")
        print(f"Sharpe Ratio:    {metrics['sharpe']:.2f}")
        print(f"SQN:             {metrics['sqn']:.2f}")
        print("="*60)
        
        # Quick assessment
        print("\nQUICK ASSESSMENT:")
        if metrics['total_trades'] < 100:
            print("⚠️  Insufficient trades for statistical significance")
        if metrics['sharpe'] > 3:
            print("⚠️  Sharpe > 3 - Possible overfitting")
        if metrics['max_drawdown'] > 10:
            print("⚠️  Max DD > 10% - Risk too high for FTMO")
        if metrics['profit_factor'] < 1.5:
            print("⚠️  PF < 1.5 - Edge may be too weak")
        if metrics['win_rate'] > 70:
            print("⚠️  Win Rate > 70% - Unusual, verify")
        
        if (metrics['total_trades'] >= 100 and 
            metrics['sharpe'] >= 1.5 and metrics['sharpe'] <= 3 and
            metrics['max_drawdown'] <= 10 and
            metrics['profit_factor'] >= 1.5):
            print("✅ BASELINE LOOKS PROMISING - Run Oracle GO/NO-GO")
        else:
            print("❌ NEEDS WORK - Adjust strategy parameters")


def main():
    """Run backtest"""
    import argparse
    
    parser = argparse.ArgumentParser(description='XAUUSD Strategy Backtester')
    parser.add_argument('--data', type=str, 
                        default='Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv',
                        help='Path to data file')
    parser.add_argument('--timeframe', type=str, default='M5', help='Timeframe')
    parser.add_argument('--start', type=str, default=None, help='Start date (optional)')
    parser.add_argument('--end', type=str, default=None, help='End date (optional)')
    parser.add_argument('--output', type=str, default='trades.csv', help='Output file')
    parser.add_argument('--max-rows', type=int, default=2000000, help='Max rows to load')
    
    args = parser.parse_args()
    
    # Config
    config = BacktestConfig(
        initial_balance=100000,
        risk_per_trade=0.005,
        use_regime_filter=False,  # Start simple
        use_ma_cross=True,
        fast_ma=20,
        slow_ma=50
    )
    
    # Run
    bt = XAUUSDBacktester(config)
    
    data_path = Path(args.data)
    if not data_path.is_absolute():
        data_path = Path.cwd() / data_path
    
    df = bt.load_data(data_path, args.timeframe, args.start, args.end, args.max_rows)
    df = bt.calculate_indicators(df)
    df = bt.generate_signals(df)
    trades = bt.run_backtest(df)
    
    metrics = bt.calculate_metrics()
    bt.print_report(metrics)
    
    # Export
    output_path = Path(args.output)
    if not output_path.is_absolute():
        output_path = Path.cwd() / output_path
    bt.export_trades(output_path)
    
    return metrics


if __name__ == '__main__':
    main()
