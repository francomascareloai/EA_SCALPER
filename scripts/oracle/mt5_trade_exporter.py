"""
MT5 Trade Exporter
==================

Exports trades from MetaTrader 5 to CSV for analysis.
Supports both live account and backtest history.

For: EA_SCALPER_XAUUSD - ORACLE Validation v2.2

Usage:
    python -m scripts.oracle.mt5_trade_exporter --symbol XAUUSD --magic 123456
    
Requirements:
    pip install MetaTrader5
"""

import pandas as pd
from datetime import datetime, timedelta
from pathlib import Path
import json
import argparse
from typing import Optional

try:
    import MetaTrader5 as mt5
    MT5_AVAILABLE = True
except ImportError:
    MT5_AVAILABLE = False
    print("Warning: MetaTrader5 package not installed. Install with: pip install MetaTrader5")


class MT5TradeExporter:
    """
    Exports trades from MT5 terminal to CSV for analysis.
    
    Works with:
    - Demo accounts (live trades)
    - History after running backtest
    """
    
    def __init__(
        self,
        terminal_path: str = None,
        login: int = None,
        password: str = None,
        server: str = None
    ):
        self.terminal_path = terminal_path
        self.login = login
        self.password = password
        self.server = server
        self._connected = False
    
    def connect(self) -> bool:
        """Establish connection to MT5"""
        if not MT5_AVAILABLE:
            print("Error: MetaTrader5 package not available")
            return False
        
        init_kwargs = {}
        if self.terminal_path:
            init_kwargs['path'] = self.terminal_path
        if self.login:
            init_kwargs['login'] = self.login
            init_kwargs['password'] = self.password
            init_kwargs['server'] = self.server
        
        if not mt5.initialize(**init_kwargs):
            error = mt5.last_error()
            print(f"MT5 initialize() failed: {error}")
            return False
        
        self._connected = True
        info = mt5.account_info()
        if info:
            print(f"Connected to MT5: Login={info.login}, Server={info.server}")
        return True
    
    def disconnect(self):
        """Disconnect from MT5"""
        if self._connected and MT5_AVAILABLE:
            mt5.shutdown()
            self._connected = False
    
    def export_deals(
        self,
        from_date: datetime,
        to_date: datetime = None,
        symbol: str = None,
        magic: int = None
    ) -> pd.DataFrame:
        """
        Export deals (closed trades) from history.
        
        Args:
            from_date: Start date
            to_date: End date (default: now)
            symbol: Filter by symbol (e.g., "XAUUSD")
            magic: Filter by magic number
        
        Returns:
            DataFrame with all deals
        """
        if not self._connected:
            raise RuntimeError("Not connected to MT5. Call connect() first.")
        
        to_date = to_date or datetime.now()
        
        # Get deals
        deals = mt5.history_deals_get(from_date, to_date)
        
        if deals is None or len(deals) == 0:
            error = mt5.last_error()
            print(f"No deals found. Error: {error}")
            return pd.DataFrame()
        
        # Convert to DataFrame
        df = pd.DataFrame(list(deals), columns=deals[0]._asdict().keys())
        
        # Filter by symbol
        if symbol:
            df = df[df['symbol'] == symbol]
        
        # Filter by magic number
        if magic:
            df = df[df['magic'] == magic]
        
        # Process timestamps
        df['time'] = pd.to_datetime(df['time'], unit='s')
        if 'time_msc' in df.columns:
            df['time_msc'] = pd.to_datetime(df['time_msc'], unit='ms')
        
        # Map deal types
        deal_types = {
            0: 'BUY',
            1: 'SELL',
            2: 'BALANCE',
            3: 'CREDIT',
            4: 'CHARGE',
            5: 'CORRECTION',
            6: 'BONUS',
            7: 'COMMISSION',
            8: 'COMMISSION_DAILY',
            9: 'COMMISSION_MONTHLY',
            10: 'COMMISSION_AGENT_DAILY',
            11: 'COMMISSION_AGENT_MONTHLY',
            12: 'INTEREST',
        }
        df['type_str'] = df['type'].map(deal_types).fillna('OTHER')
        
        # Entry/Exit
        entry_types = {
            0: 'ENTRY',
            1: 'EXIT',
            2: 'INOUT',
            3: 'OUT_BY',
        }
        df['entry_str'] = df['entry'].map(entry_types).fillna('OTHER')
        
        return df
    
    def export_paired_trades(
        self,
        from_date: datetime,
        to_date: datetime = None,
        symbol: str = "XAUUSD",
        magic: int = None
    ) -> pd.DataFrame:
        """
        Export PAIRED trades (entry + exit as one row).
        
        This is the ideal format for WFA/Monte Carlo analysis.
        
        Args:
            from_date: Start date
            to_date: End date
            symbol: Symbol to filter
            magic: Magic number to filter
        
        Returns:
            DataFrame with paired trades
        """
        deals = self.export_deals(from_date, to_date, symbol, magic)
        
        if deals.empty:
            return pd.DataFrame()
        
        # Filter only trades (not balance, commission, etc)
        trades = deals[deals['type_str'].isin(['BUY', 'SELL'])].copy()
        
        # Separate entries and exits
        entries = trades[trades['entry_str'] == 'ENTRY'].copy()
        exits = trades[trades['entry_str'] == 'EXIT'].copy()
        
        paired = []
        
        for _, entry in entries.iterrows():
            # Find matching exit (same position_id)
            exit_match = exits[exits['position_id'] == entry['position_id']]
            
            if exit_match.empty:
                continue
            
            exit = exit_match.iloc[0]
            
            # Determine direction
            direction = 'LONG' if entry['type_str'] == 'BUY' else 'SHORT'
            
            # Calculate P&L (already includes swap and commission)
            pnl = exit['profit']
            
            # Calculate duration
            duration = (exit['time'] - entry['time']).total_seconds() / 60  # minutes
            
            paired.append({
                'datetime': entry['time'],
                'exit_time': exit['time'],
                'symbol': symbol,
                'direction': direction,
                'volume': entry['volume'],
                'entry_price': entry['price'],
                'exit_price': exit['price'],
                'profit': pnl,
                'pnl_pct': pnl / (entry['price'] * entry['volume'] * 100) * 100 if entry['price'] > 0 else 0,
                'duration_min': duration,
                'commission': entry.get('commission', 0) + exit.get('commission', 0),
                'swap': entry.get('swap', 0) + exit.get('swap', 0),
                'magic': entry['magic'],
                'comment': entry.get('comment', ''),
                'position_id': entry['position_id']
            })
        
        result = pd.DataFrame(paired)
        
        if not result.empty:
            result = result.sort_values('datetime').reset_index(drop=True)
        
        return result
    
    def save_to_csv(
        self,
        df: pd.DataFrame,
        output_path: str,
        include_metadata: bool = True
    ):
        """Save DataFrame to CSV with optional metadata"""
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        df.to_csv(output_path, index=False)
        print(f"Saved {len(df)} trades to {output_path}")
        
        if include_metadata and len(df) > 0:
            meta = {
                'exported_at': datetime.now().isoformat(),
                'n_trades': len(df),
                'date_range': {
                    'start': str(df['datetime'].min()) if 'datetime' in df.columns else None,
                    'end': str(df['datetime'].max()) if 'datetime' in df.columns else None
                },
                'total_pnl': float(df['profit'].sum()) if 'profit' in df.columns else None,
                'win_rate': float((df['profit'] > 0).mean()) if 'profit' in df.columns else None
            }
            
            meta_path = output_path.with_suffix('.meta.json')
            with open(meta_path, 'w') as f:
                json.dump(meta, f, indent=2, default=str)
            print(f"Saved metadata to {meta_path}")


def generate_sample_trades(n_trades: int = 200, symbol: str = "XAUUSD") -> pd.DataFrame:
    """
    Generate sample trades for testing when MT5 is not available.
    
    Creates realistic-looking XAUUSD scalping trades.
    """
    import numpy as np
    
    np.random.seed(42)
    
    # Parameters
    win_rate = 0.55
    avg_win = 50  # $50 average win
    avg_loss = 40  # $40 average loss
    
    trades = []
    base_time = datetime(2023, 1, 1, 8, 0, 0)
    base_price = 1950.0
    
    for i in range(n_trades):
        # Random time increment (15 min to 2 hours)
        time_delta = timedelta(minutes=np.random.randint(15, 120))
        trade_time = base_time + timedelta(hours=i * 2) + time_delta
        
        # Win or loss
        is_win = np.random.random() < win_rate
        
        if is_win:
            pnl = np.random.exponential(avg_win)
            pnl = min(pnl, avg_win * 5)  # Cap extreme wins
        else:
            pnl = -np.random.exponential(avg_loss)
            pnl = max(pnl, -avg_loss * 3)  # Cap extreme losses
        
        # Direction
        direction = np.random.choice(['LONG', 'SHORT'])
        
        # Price (random walk)
        entry_price = base_price + np.random.randn() * 10
        price_move = pnl / 10  # Approximate price move for $10/pip
        exit_price = entry_price + (price_move if direction == 'LONG' else -price_move)
        
        trades.append({
            'datetime': trade_time,
            'exit_time': trade_time + timedelta(minutes=np.random.randint(5, 60)),
            'symbol': symbol,
            'direction': direction,
            'volume': 0.1,
            'entry_price': round(entry_price, 2),
            'exit_price': round(exit_price, 2),
            'profit': round(pnl, 2),
            'pnl_pct': round(pnl / 1000, 4),  # Approximate
            'duration_min': np.random.randint(5, 60),
            'commission': -2.0,
            'swap': 0,
            'magic': 123456,
            'comment': 'Sample trade',
            'position_id': 1000 + i
        })
    
    return pd.DataFrame(trades)


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='MT5 Trade Exporter')
    parser.add_argument('--symbol', '-s', default='XAUUSD', help='Symbol to export')
    parser.add_argument('--magic', '-m', type=int, help='Magic number filter')
    parser.add_argument('--from', dest='from_date', help='Start date (YYYY-MM-DD)')
    parser.add_argument('--to', dest='to_date', help='End date (YYYY-MM-DD)')
    parser.add_argument('--output', '-o', default='trades.csv', help='Output file')
    parser.add_argument('--sample', action='store_true', help='Generate sample data (no MT5 needed)')
    parser.add_argument('--sample-size', type=int, default=200, help='Sample size')
    
    args = parser.parse_args()
    
    if args.sample:
        # Generate sample data
        print(f"Generating {args.sample_size} sample trades...")
        df = generate_sample_trades(args.sample_size, args.symbol)
        
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(output_path, index=False)
        
        print(f"Saved {len(df)} sample trades to {output_path}")
        print(f"Total P&L: ${df['profit'].sum():,.2f}")
        print(f"Win Rate: {(df['profit'] > 0).mean():.1%}")
        return
    
    if not MT5_AVAILABLE:
        print("MetaTrader5 package not available.")
        print("Use --sample to generate sample data for testing.")
        return
    
    # Parse dates
    if args.from_date:
        from_date = datetime.strptime(args.from_date, '%Y-%m-%d')
    else:
        from_date = datetime.now() - timedelta(days=365)
    
    if args.to_date:
        to_date = datetime.strptime(args.to_date, '%Y-%m-%d')
    else:
        to_date = datetime.now()
    
    # Export from MT5
    exporter = MT5TradeExporter()
    
    if exporter.connect():
        try:
            trades = exporter.export_paired_trades(
                from_date=from_date,
                to_date=to_date,
                symbol=args.symbol,
                magic=args.magic
            )
            
            if not trades.empty:
                exporter.save_to_csv(trades, args.output)
                print(f"\nSummary:")
                print(f"  Trades: {len(trades)}")
                print(f"  Period: {trades['datetime'].min()} to {trades['datetime'].max()}")
                print(f"  Total P&L: ${trades['profit'].sum():,.2f}")
                print(f"  Win Rate: {(trades['profit'] > 0).mean():.1%}")
            else:
                print("No trades found matching criteria")
        finally:
            exporter.disconnect()
    else:
        print("Failed to connect to MT5")
        print("Use --sample to generate sample data for testing.")


if __name__ == '__main__':
    main()
