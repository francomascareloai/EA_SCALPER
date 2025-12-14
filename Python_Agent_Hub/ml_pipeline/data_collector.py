"""
Data Collector for ML Pipeline
Extracts XAUUSD data from MetaTrader 5
EA_SCALPER_XAUUSD - Singularity Edition
"""
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Tuple
import json

try:
    import MetaTrader5 as mt5
    MT5_AVAILABLE = True
except ImportError:
    MT5_AVAILABLE = False
    print("Warning: MetaTrader5 package not installed. Run: pip install MetaTrader5")

from .config import DATA_DIR, SYMBOL, TIMEFRAME


class MT5DataCollector:
    """Collects historical data from MetaTrader 5"""
    
    TIMEFRAME_MAP = {
        "M1": mt5.TIMEFRAME_M1 if MT5_AVAILABLE else 1,
        "M5": mt5.TIMEFRAME_M5 if MT5_AVAILABLE else 5,
        "M15": mt5.TIMEFRAME_M15 if MT5_AVAILABLE else 15,
        "M30": mt5.TIMEFRAME_M30 if MT5_AVAILABLE else 30,
        "H1": mt5.TIMEFRAME_H1 if MT5_AVAILABLE else 60,
        "H4": mt5.TIMEFRAME_H4 if MT5_AVAILABLE else 240,
        "D1": mt5.TIMEFRAME_D1 if MT5_AVAILABLE else 1440,
    }
    
    def __init__(self, symbol: str = SYMBOL):
        self.symbol = symbol
        self.connected = False
        
    def connect(self) -> bool:
        """Connect to MT5 terminal"""
        if not MT5_AVAILABLE:
            print("MetaTrader5 package not available")
            return False
            
        if not mt5.initialize():
            print(f"MT5 initialization failed: {mt5.last_error()}")
            return False
            
        self.connected = True
        print(f"Connected to MT5: {mt5.terminal_info().name}")
        return True
        
    def disconnect(self):
        """Disconnect from MT5"""
        if MT5_AVAILABLE and self.connected:
            mt5.shutdown()
            self.connected = False
            
    def get_rates(
        self, 
        timeframe: str = TIMEFRAME,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        bars: int = 50000
    ) -> Optional[pd.DataFrame]:
        """
        Get historical rates from MT5
        
        Args:
            timeframe: Timeframe string (M1, M5, M15, H1, H4, D1)
            start_date: Start date (if None, uses bars count from end_date)
            end_date: End date (if None, uses current time)
            bars: Number of bars to fetch (used if start_date is None)
            
        Returns:
            DataFrame with OHLCV data
        """
        if not self.connected:
            if not self.connect():
                return None
                
        tf = self.TIMEFRAME_MAP.get(timeframe, mt5.TIMEFRAME_M15)
        
        if end_date is None:
            end_date = datetime.now()
            
        if start_date is None:
            # Fetch by bar count
            rates = mt5.copy_rates_from(self.symbol, tf, end_date, bars)
        else:
            # Fetch by date range
            rates = mt5.copy_rates_range(self.symbol, tf, start_date, end_date)
            
        if rates is None or len(rates) == 0:
            print(f"Failed to get rates: {mt5.last_error()}")
            return None
            
        df = pd.DataFrame(rates)
        df['time'] = pd.to_datetime(df['time'], unit='s')
        df.set_index('time', inplace=True)
        df.columns = ['open', 'high', 'low', 'close', 'tick_volume', 'spread', 'real_volume']
        
        print(f"Loaded {len(df)} bars from {df.index[0]} to {df.index[-1]}")
        return df
        
    def get_multi_timeframe_data(
        self,
        timeframes: list = ["M5", "M15", "H1", "H4"],
        bars: int = 50000
    ) -> dict:
        """Get data for multiple timeframes"""
        data = {}
        for tf in timeframes:
            df = self.get_rates(timeframe=tf, bars=bars)
            if df is not None:
                data[tf] = df
        return data
        
    def save_data(self, df: pd.DataFrame, filename: str):
        """Save data to CSV"""
        path = DATA_DIR / filename
        df.to_csv(path)
        print(f"Data saved to {path}")
        
    def load_data(self, filename: str) -> Optional[pd.DataFrame]:
        """Load data from CSV"""
        path = DATA_DIR / filename
        if not path.exists():
            print(f"File not found: {path}")
            return None
        df = pd.read_csv(path, index_col=0, parse_dates=True)
        print(f"Loaded {len(df)} rows from {path}")
        return df


class CSVDataLoader:
    """Load data from CSV files (alternative to MT5)"""
    
    def __init__(self, data_dir: Path = DATA_DIR):
        self.data_dir = data_dir
        
    def load(self, filename: str) -> Optional[pd.DataFrame]:
        """Load OHLCV data from CSV"""
        path = self.data_dir / filename
        if not path.exists():
            print(f"File not found: {path}")
            return None
            
        df = pd.read_csv(path)
        
        # Try to identify and parse datetime column
        time_cols = ['time', 'datetime', 'date', 'timestamp', 'Time', 'Date']
        for col in time_cols:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col])
                df.set_index(col, inplace=True)
                break
                
        # Standardize column names
        col_map = {
            'Open': 'open', 'High': 'high', 'Low': 'low', 
            'Close': 'close', 'Volume': 'tick_volume'
        }
        df.rename(columns=col_map, inplace=True)
        
        return df
        
    def list_files(self) -> list:
        """List available CSV files"""
        return list(self.data_dir.glob("*.csv"))


def collect_training_data(
    days: int = 365,
    timeframes: list = ["M15"],
    output_prefix: str = "xauusd"
) -> dict:
    """
    Collect training data from MT5
    
    Args:
        days: Number of days of historical data
        timeframes: List of timeframes to collect
        output_prefix: Prefix for output files
        
    Returns:
        Dictionary of DataFrames by timeframe
    """
    collector = MT5DataCollector()
    
    if not collector.connect():
        print("Failed to connect to MT5. Please ensure MT5 is running.")
        return {}
        
    try:
        data = {}
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        for tf in timeframes:
            df = collector.get_rates(
                timeframe=tf,
                start_date=start_date,
                end_date=end_date
            )
            
            if df is not None:
                filename = f"{output_prefix}_{tf}_{days}d.csv"
                collector.save_data(df, filename)
                data[tf] = df
                
        return data
        
    finally:
        collector.disconnect()


if __name__ == "__main__":
    # Example usage
    print("Collecting XAUUSD data from MT5...")
    data = collect_training_data(days=365, timeframes=["M15", "H1"])
    
    if data:
        print(f"\nCollected data for timeframes: {list(data.keys())}")
        for tf, df in data.items():
            print(f"{tf}: {len(df)} bars, {df.index[0]} to {df.index[-1]}")
    else:
        print("No data collected. Make sure MT5 is running and logged in.")
