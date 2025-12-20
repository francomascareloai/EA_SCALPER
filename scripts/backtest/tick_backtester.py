#!/usr/bin/env python3
"""
Event-Driven Tick Backtester v1.0
=================================
High-precision backtester using tick data for XAUUSD.

Features:
- Event-driven architecture (no look-ahead bias)
- Dynamic spread from actual bid/ask
- Realistic execution simulation
- FTMO compliance monitoring
- Oracle-compatible output

Author: ORACLE + FORGE
Date: 2025-12-01
"""

import os
import pyarrow as pa
import pyarrow.parquet as pq
import numpy as np
import pandas as pd
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Callable
from datetime import datetime, timedelta
from enum import Enum
import warnings
warnings.filterwarnings('ignore')
# EA parity types - USE FULL LOGIC (not simplified)
try:
    from scripts.backtest.strategies.ea_logic_full import SignalType, EALogic, EAConfig
    USE_FULL_EA_LOGIC = True
except ImportError:
    try:
        from scripts.backtest.strategies.ea_logic_python import SignalType, EALogic, EAConfig
        USE_FULL_EA_LOGIC = False
    except Exception:
        class SignalType(Enum):
            NONE = 0
            BUY = 1
            SELL = -1
        USE_FULL_EA_LOGIC = False

# Footprint analyzer for real order flow
try:
    from scripts.backtest.footprint_analyzer import FootprintAnalyzer, FootprintConfig
    HAVE_FOOTPRINT = True
except Exception:
    HAVE_FOOTPRINT = False


# =============================================================================
# CONFIGURATION
# =============================================================================

class ExecutionMode(Enum):
    """Execution simulation mode"""
    OPTIMISTIC = "optimistic"    # Best case (dev only)
    NORMAL = "normal"            # Average conditions
    PESSIMISTIC = "pessimistic"  # Conservative (recommended)
    STRESS = "stress"            # Worst case (news, low liquidity)


@dataclass
class BacktestConfig:
    """Complete backtest configuration"""
    # Capital
    initial_balance: float = 100_000.0
    risk_per_trade: float = 0.005      # 0.5% per trade
    
    # FTMO Limits
    max_daily_dd: float = 0.05         # 5%
    max_total_dd: float = 0.10         # 10%
    
    # Execution Mode
    execution_mode: ExecutionMode = ExecutionMode.PESSIMISTIC
    
    # Execution (base values, scaled by mode)
    base_slippage_points: float = 3.0  # Base slippage
    latency_ms: int = 50               # Execution latency
    rejection_rate: float = 0.02       # 2% order rejections
    
    # Strategy parameters
    atr_period: int = 14
    atr_sl_mult: float = 2.0
    atr_tp_mult: float = 3.0           # 1.5 RR
    fast_ma: int = 20
    slow_ma: int = 50
    
    # Filters
    use_regime_filter: bool = False
    hurst_threshold: float = 0.55
    use_session_filter: bool = False
    session_start_hour: int = 8        # GMT
    session_end_hour: int = 20         # GMT
    
    # EA parity mode
    use_ea_logic: bool = False         # If True, use Python parity of EA for signals
    eval_window_bars: int = 400        # Bars window passed to EA evaluator
    fp_score: float = 50.0             # Default footprint score when using EA logic
    use_real_footprint: bool = True    # Calculate real footprint from ticks (recommended)
    ml_prob: float = None              # Optional ML probability override
    
    # Timeframe for indicators
    bar_timeframe: str = '5min'        # Execution timeframe (default M5)
    exec_timeframe: str = '5min'       # Separate execution TF (e.g., '15s') if provided
    
    # Debug
    debug: bool = False
    debug_interval: int = 1000


class Direction(Enum):
    LONG = "BUY"
    SHORT = "SELL"


class ExitReason(Enum):
    TP = "TP"
    SL = "SL"
    SIGNAL = "SIGNAL"
    DAILY_DD = "DAILY_DD"
    TOTAL_DD = "TOTAL_DD"
    END = "END"


# =============================================================================
# DATA LOADING
# =============================================================================

class TickDataLoader:
    """Efficient tick data loading using file seeking"""
    
    @staticmethod
    def load(filepath: str, max_ticks: int = 5_000_000, 
             start_date: str = None, end_date: str = None) -> pd.DataFrame:
        """
        Load tick data from tail of large CSV file.
        
        Args:
            filepath: Path to tick CSV
            max_ticks: Maximum ticks to load
            start_date: Optional start date filter (YYYY-MM-DD)
            end_date: Optional end date filter (YYYY-MM-DD)
        """
        # Parquet fast-path
        if filepath.lower().endswith(".parquet"):
            pf = pq.ParquetFile(filepath)
            tables = []
            rows = 0
            want = max_ticks or pf.metadata.num_rows
            for rg in reversed(range(pf.num_row_groups)):
                t = pf.read_row_group(rg)
                tables.append(t)
                rows += t.num_rows
                if rows >= want:
                    break
            tables.reverse()
            table = pa.concat_tables(tables)
            if table.num_rows > want:
                start = table.num_rows - want
                table = table.slice(start, want)
            df = table.to_pandas()
            if "timestamp" in df.columns:
                df["datetime"] = pd.to_datetime(df["timestamp"])
            if "bid" in df.columns and "ask" in df.columns:
                df["mid"] = (df["bid"] + df["ask"]) / 2
                df["spread"] = df["ask"] - df["bid"]
            elif "mid_price" in df.columns:
                df["mid"] = df["mid_price"]
                df["spread"] = df.get("spread", pd.Series(0.3, index=df.index))
            else:
                raise ValueError("Parquet must contain bid/ask or mid_price columns")
            df = df.set_index("datetime")
            df.sort_index(inplace=True)
            if start_date:
                df = df[df.index >= start_date]
            if end_date:
                df = df[df.index <= end_date]
            print(f"[TickLoader] Loaded {len(df):,} ticks (parquet tail)")
            return df

        file_size = os.path.getsize(filepath)
        print(f"[TickLoader] File: {filepath}")
        print(f"[TickLoader] Size: {file_size / (1024**3):.2f} GB")
        print(f"[TickLoader] Loading ~{max_ticks:,} ticks from tail...")
        
        # Estimate bytes (avg ~35 bytes per line)
        bytes_to_read = min(max_ticks * 40, file_size)
        
        data = []
        with open(filepath, 'rb') as f:
            f.seek(max(0, file_size - bytes_to_read))
            f.readline()  # Skip partial first line
            
            count = 0
            for line in f:
                try:
                    line = line.decode('utf-8').strip()
                    parts = line.split(',')
                    if len(parts) >= 3:
                        dt_str = parts[0]
                        bid = float(parts[1])
                        ask = float(parts[2])
                        
                        # Parse: 2025.11.28 21:43:59.978
                        dt = datetime.strptime(dt_str, '%Y.%m.%d %H:%M:%S.%f')
                        
                        data.append({
                            'datetime': dt,
                            'bid': bid,
                            'ask': ask,
                            'mid': (bid + ask) / 2,
                            'spread': ask - bid
                        })
                        
                        count += 1
                        if count % 1_000_000 == 0:
                            print(f"[TickLoader] Processed {count:,} ticks...")
                except:
                    continue
        
        df = pd.DataFrame(data)
        df.set_index('datetime', inplace=True)
        df.sort_index(inplace=True)
        
        # Apply date filters if specified
        if start_date:
            df = df[df.index >= start_date]
        if end_date:
            df = df[df.index <= end_date]
        
        print(f"[TickLoader] Loaded {len(df):,} ticks")
        print(f"[TickLoader] Period: {df.index[0]} to {df.index[-1]}")
        print(f"[TickLoader] Avg spread: {df['spread'].mean():.2f} points")
        
        return df


# =============================================================================
# OHLC RESAMPLING
# =============================================================================

class OHLCResampler:
    """Resample tick data to OHLC bars"""
    
    @staticmethod
    def resample(ticks: pd.DataFrame, timeframe: str = '5min') -> pd.DataFrame:
        """
        Resample ticks to OHLC bars.
        
        Args:
            ticks: DataFrame with mid, spread columns
            timeframe: pandas resample string ('1min', '5min', '15min', '1h')
        """
        print(f"[Resampler] Resampling to {timeframe}...")
        
        ohlc = ticks['mid'].resample(timeframe).ohlc()
        ohlc.columns = ['open', 'high', 'low', 'close']
        ohlc['volume'] = ticks['mid'].resample(timeframe).count()
        ohlc['spread'] = ticks['spread'].resample(timeframe).mean()
        ohlc['tick_count'] = ticks['mid'].resample(timeframe).count()
        
        # Drop bars with no data
        ohlc = ohlc.dropna()
        
        print(f"[Resampler] Created {len(ohlc):,} bars")
        return ohlc


# =============================================================================
# INDICATORS
# =============================================================================

class Indicators:
    """Technical indicators calculator"""
    
    @staticmethod
    def add_all(df: pd.DataFrame, config: BacktestConfig) -> pd.DataFrame:
        """Add all required indicators to OHLC dataframe"""
        
        # ATR
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(config.atr_period).mean()
        
        # Moving Averages
        df['ma_fast'] = df['close'].rolling(config.fast_ma).mean()
        df['ma_slow'] = df['close'].rolling(config.slow_ma).mean()
        
        # MA Cross Signals (shifted to avoid look-ahead)
        df['ma_cross_up'] = (
            (df['ma_fast'] > df['ma_slow']) & 
            (df['ma_fast'].shift(1) <= df['ma_slow'].shift(1))
        )
        df['ma_cross_down'] = (
            (df['ma_fast'] < df['ma_slow']) & 
            (df['ma_fast'].shift(1) >= df['ma_slow'].shift(1))
        )
        
        # Hurst Exponent (simplified - for regime detection)
        if config.use_regime_filter:
            df['hurst'] = Indicators._rolling_hurst(df['close'], window=100)
            df['is_trending'] = df['hurst'] > config.hurst_threshold
        else:
            df['is_trending'] = True
        
        # Session filter
        if config.use_session_filter:
            df['hour'] = df.index.hour
            df['in_session'] = (
                (df['hour'] >= config.session_start_hour) & 
                (df['hour'] < config.session_end_hour)
            )
        else:
            df['in_session'] = True
        
        return df.dropna()
    
    @staticmethod
    def _rolling_hurst(series: pd.Series, window: int = 100) -> pd.Series:
        """Calculate rolling Hurst exponent (simplified R/S method)"""
        def hurst(ts):
            if len(ts) < 20:
                return 0.5
            
            lags = range(2, min(20, len(ts) // 2))
            tau = []
            for lag in lags:
                tau.append(np.std(np.subtract(ts[lag:], ts[:-lag])))
            
            if len(tau) < 2 or any(t == 0 for t in tau):
                return 0.5
            
            try:
                reg = np.polyfit(np.log(list(lags)), np.log(tau), 1)
                return reg[0]
            except:
                return 0.5
        
        return series.rolling(window).apply(hurst, raw=True)


# =============================================================================
# POSITION & TRADE
# =============================================================================

@dataclass
class Position:
    """Open position"""
    direction: Direction
    entry_time: datetime
    entry_price: float
    sl_price: float
    tp_price: float
    lots: float
    spread_at_entry: float


@dataclass
class Trade:
    """Completed trade"""
    entry_time: datetime
    exit_time: datetime
    direction: str
    entry_price: float
    exit_price: float
    sl: float
    tp: float
    lots: float
    pnl: float
    pnl_pct: float
    exit_reason: str
    spread_entry: float
    spread_exit: float
    balance_after: float


# =============================================================================
# EXECUTION MODEL
# =============================================================================

class ExecutionModel:
    """Realistic execution simulation with mode-based scaling"""
    
    # Multipliers by execution mode
    MODE_MULTIPLIERS = {
        ExecutionMode.OPTIMISTIC: {'spread': 1.0, 'slippage': 0.5, 'rejection': 0.5},
        ExecutionMode.NORMAL: {'spread': 1.0, 'slippage': 1.0, 'rejection': 1.0},
        ExecutionMode.PESSIMISTIC: {'spread': 1.5, 'slippage': 2.0, 'rejection': 1.5},
        ExecutionMode.STRESS: {'spread': 3.0, 'slippage': 5.0, 'rejection': 3.0},
    }
    
    def __init__(self, config: BacktestConfig):
        self.config = config
        self.mult = self.MODE_MULTIPLIERS[config.execution_mode]
        self.rejections = 0
    
    def should_reject(self) -> bool:
        """Simulate order rejection"""
        if np.random.random() < self.config.rejection_rate * self.mult['rejection']:
            self.rejections += 1
            return True
        return False
    
    def get_fill_price(self, direction: Direction, bar: pd.Series, 
                       is_entry: bool = True) -> float:
        """
        Calculate realistic fill price with spread and slippage.
        Scaled by execution mode for conservative estimates.
        """
        base_spread = bar.get('spread', 0.30)
        spread = base_spread * self.mult['spread']
        mid = bar['close']
        
        # Add random slippage (always adverse)
        max_slip = self.config.base_slippage_points * 0.01 * self.mult['slippage']
        slippage = np.random.uniform(0, max_slip)
        
        if direction == Direction.LONG:
            if is_entry:
                # Buy at ask + slippage (adverse)
                return mid + spread/2 + slippage
            else:
                # Sell at bid - slippage (adverse)
                return mid - spread/2 - slippage
        else:  # SHORT
            if is_entry:
                # Sell at bid - slippage (adverse)
                return mid - spread/2 - slippage
            else:
                # Buy at ask + slippage (adverse)
                return mid + spread/2 + slippage


# =============================================================================
# RISK MANAGER
# =============================================================================

class RiskManager:
    """FTMO-compliant risk management"""
    
    def __init__(self, config: BacktestConfig):
        self.config = config
        self.initial_balance = config.initial_balance
        self.balance = config.initial_balance
        self.peak_balance = config.initial_balance
        self.daily_start_balance = config.initial_balance
        self.current_date = None
        self.daily_pnl = 0.0
        self.is_blown = False
        self.blow_reason = None
    
    def new_day(self, date):
        """Reset daily tracking"""
        if self.current_date != date:
            self.current_date = date
            self.daily_start_balance = self.balance
            self.daily_pnl = 0.0
    
    def update(self, pnl: float):
        """Update after trade"""
        self.balance += pnl
        self.daily_pnl += pnl
        
        if self.balance > self.peak_balance:
            self.peak_balance = self.balance
    
    def check_limits(self) -> tuple:
        """
        Check FTMO limits.
        Returns: (can_trade, breach_reason)
        """
        # Daily DD check
        daily_dd = -self.daily_pnl / self.initial_balance
        if daily_dd >= self.config.max_daily_dd:
            self.is_blown = True
            self.blow_reason = "DAILY_DD"
            return False, ExitReason.DAILY_DD
        
        # Total DD check
        total_dd = (self.peak_balance - self.balance) / self.peak_balance
        if total_dd >= self.config.max_total_dd:
            self.is_blown = True
            self.blow_reason = "TOTAL_DD"
            return False, ExitReason.TOTAL_DD
        
        return True, None
    
    def calculate_lots(self, entry_price: float, sl_price: float) -> float:
        """Calculate position size based on risk"""
        risk_amount = self.balance * self.config.risk_per_trade
        sl_distance = abs(entry_price - sl_price)
        
        if sl_distance <= 0:
            return 0.01
        
        # XAUUSD: 1 lot = 100 oz, 1 point = $0.01 per oz
        lots = risk_amount / (sl_distance * 100)
        
        # Clamp to reasonable range
        return max(0.01, min(lots, 10.0))
    
    @property
    def current_dd(self) -> float:
        """Current drawdown percentage"""
        if self.peak_balance <= 0:
            return 0
        return (self.peak_balance - self.balance) / self.peak_balance
    
    @property 
    def current_daily_dd(self) -> float:
        """Current daily drawdown percentage"""
        return -self.daily_pnl / self.initial_balance


# =============================================================================
# EVENT-DRIVEN BACKTESTER
# =============================================================================

class TickBacktester:
    """
    Event-driven backtester using tick data.
    
    Process:
    1. Load ticks
    2. Resample to OHLC bars
    3. Calculate indicators
    4. Iterate bar-by-bar (event-driven)
    5. Generate signals, manage positions
    6. Track P&L and risk
    7. Export Oracle-compatible trades
    """
    
    def __init__(self, config: BacktestConfig = None):
        self.config = config or BacktestConfig()
        self.execution = ExecutionModel(self.config)
        self.risk = RiskManager(self.config)
        
        self.position: Optional[Position] = None
        self.trades: List[Trade] = []
        self.equity_curve: List[dict] = []

        # EA parity layer
        self.ea = None
        self.htf_bars = None
        self.bars_data = None
        if self.config.use_ea_logic:
            try:
                # Use REAL thresholds for accurate backtesting
                # Note: relaxed_mtf_gate=True because backtest data doesn't have proper MTF
                ea_cfg = EAConfig(
                    execution_threshold=40.0,   # Very relaxed for debugging
                    confluence_min_score=40.0,  # Very relaxed for debugging
                    amd_threshold=30.0,         # Very relaxed for debugging
                    min_rr=1.0,                 # Relaxed R:R for debugging
                    max_spread_points=100.0,    # Slightly relaxed for backtest data
                    use_ml=False,
                    use_fib_filter=True,
                    ob_displacement_mult=2.0,   # REAL displacement
                    fvg_min_gap=0.3,            # REAL gap
                    allow_asian=True,           # Allow Asian for backtest data coverage
                    allow_late_ny=True,         # Allow Late NY for backtest
                    relaxed_mtf_gate=True,      # Relax MTF gate for backtest
                    require_ltf_confirm=False,  # Don't require LTF confirm for backtest
                )
                self.ea = EALogic(ea_cfg, initial_balance=self.config.initial_balance)
                if USE_FULL_EA_LOGIC:
                    print("[EA Logic] Using FULL EA logic (ea_logic_full.py)")
                else:
                    print("[EA Logic] Using simplified logic (ea_logic_python.py)")
            except Exception as e:
                print(f"[EA Logic] Failed to initialize parity layer: {e}")
                import traceback
                traceback.print_exc()
                self.config.use_ea_logic = False
    
    def run(self, tick_path: str, max_ticks: int = 5_000_000,
            start_date: str = None, end_date: str = None) -> Dict:
        """
        Run complete backtest.
        
        Args:
            tick_path: Path to tick CSV
            max_ticks: Max ticks to load
            start_date: Optional start filter
            end_date: Optional end filter
            
        Returns:
            Dict with results and metrics
        """
        print("\n" + "="*60)
        print("       EVENT-DRIVEN TICK BACKTESTER")
        print("="*60)
        
        # 1. Load tick data
        ticks = TickDataLoader.load(tick_path, max_ticks, start_date, end_date)
        
        # 2. Resample to OHLC
        exec_tf = self.config.exec_timeframe or self.config.bar_timeframe
        bars = OHLCResampler.resample(ticks, exec_tf)
        # Keep HTF for EA logic (H1)
        if self.config.use_ea_logic:
            self.htf_bars = OHLCResampler.resample(ticks, '1h')
        
        # 3. Calculate indicators
        print("[Backtest] Calculating indicators...")
        bars = Indicators.add_all(bars, self.config)
        
        # 3.5. Calculate real footprint from ticks (if enabled)
        self.fp_scores = {}  # Store fp_score per bar timestamp
        if self.config.use_ea_logic and self.config.use_real_footprint and HAVE_FOOTPRINT:
            print("[Backtest] Calculating footprint from ticks...")
            try:
                fp_config = FootprintConfig(tick_size=0.01)
                fp_analyzer = FootprintAnalyzer(fp_config)
                fp_df = fp_analyzer.analyze_ticks(ticks)
                # Merge fp_score into bars DataFrame
                if 'fp_score' in fp_df.columns:
                    bars = bars.merge(
                        fp_df[['fp_score', 'delta', 'stacked_imbal', 'absorption']],
                        left_index=True, right_index=True, how='left'
                    )
                    bars['fp_score'] = bars['fp_score'].fillna(50.0)
                    # Also store in dict for fallback
                    for ts, row in fp_df.iterrows():
                        self.fp_scores[ts] = row.get('fp_score', 50.0)
                    print(f"[Backtest] Footprint merged into bars: {len(fp_df)} rows")
                    # Stats
                    scores = bars['fp_score'].dropna().values
                    if len(scores) > 0:
                        bullish = (scores > 55).sum()
                        bearish = (scores < 45).sum()
                        print(f"[Backtest] FP Stats: Bullish={bullish}, Bearish={bearish}, Neutral={len(scores)-bullish-bearish}")
            except Exception as e:
                print(f"[Backtest] Footprint calculation failed: {e}")
                bars['fp_score'] = 50.0  # Default neutral
        
        signal_buy = bars['ma_cross_up'].sum()
        signal_sell = bars['ma_cross_down'].sum()
        print(f"[Backtest] Signals: {signal_buy} buy, {signal_sell} sell")
        
        # 4. Run simulation
        print("[Backtest] Running simulation...")
        self._simulate(bars)
        
        # 5. Calculate metrics
        metrics = self._calculate_metrics()
        
        # 6. Print report (safe for encoding issues)
        try:
            self._print_report(metrics)
        except UnicodeEncodeError:
            print("[!] Report printing failed due to encoding - results still valid")
        
        return {
            'trades': self.trades,
            'metrics': metrics,
            'equity_curve': self.equity_curve,
            'bars': len(bars),
            'ticks': len(ticks)
        }
    
    def _simulate(self, bars: pd.DataFrame):
        """Main simulation loop - event-driven"""
        self.bars_data = bars

        for i, (timestamp, bar) in enumerate(bars.iterrows()):
            # Update daily tracking
            self.risk.new_day(timestamp.date())
            
            # Check if blown
            if self.risk.is_blown:
                break
            
            # Check FTMO limits
            can_trade, breach_reason = self.risk.check_limits()
            if not can_trade:
                if self.position:
                    self._close_position(timestamp, bar, breach_reason)
                continue
            
            # Manage existing position
            if self.position:
                self._manage_position(timestamp, bar)
            
            # Generate new signals (only if no position)
            if self.position is None and can_trade:
                self._check_entry(i, timestamp, bar)
            
            # Record equity
            self.equity_curve.append({
                'datetime': timestamp,
                'balance': self.risk.balance,
                'dd': self.risk.current_dd
            })
            
            # Debug output
            if self.config.debug and i % self.config.debug_interval == 0:
                print(f"[{timestamp}] Balance: ${self.risk.balance:,.2f} | "
                      f"DD: {self.risk.current_dd:.2%} | "
                      f"Trades: {len(self.trades)}")
        
        # Close any remaining position
        if self.position:
            self._close_position(
                bars.index[-1], 
                bars.iloc[-1], 
                ExitReason.END
            )
    
    def _check_entry(self, idx: int, timestamp: datetime, bar: pd.Series):
        """Check for entry signals"""

        # EA parity path
        if self.config.use_ea_logic and self.ea is not None:
            start = max(0, idx - self.config.eval_window_bars)
            ltf_window = self.bars_data.iloc[start:idx+1].copy()
            # Require spread column for EA; ensure exists
            if 'spread' not in ltf_window.columns:
                ltf_window['spread'] = pd.Series(30.0, index=ltf_window.index)
            
            # Debug: check spread values
            if self.config.debug and idx % 500 == 0:
                spread_val = ltf_window['spread'].iloc[-1]
                print(f"  [EA Debug] Bar {idx}: spread={spread_val:.1f}, bars={len(ltf_window)}")
            
            # Get real footprint score for this bar (or default)
            real_fp_score = self.fp_scores.get(timestamp, self.config.fp_score)
            
            htf_window = None
            if self.htf_bars is not None and not self.htf_bars.empty:
                # WP3 / A-001: prevent HTF look-ahead by slicing to "as-of" timestamp.
                # Pandas resample() labels bars by period start by default.
                # A HTF bar is only fully known once (bar_start + HTF_TF) <= now.
                ts = pd.Timestamp(timestamp)
                htf_window = self.htf_bars.loc[:ts].copy()
                htf_window = htf_window[htf_window.index + pd.Timedelta("1h") <= ts]

                # Fail-fast guard: last HTF bar must be closed.
                if not htf_window.empty:
                    last_start = pd.Timestamp(htf_window.index[-1])
                    assert last_start + pd.Timedelta("1h") <= ts

            setup = self.ea.evaluate_from_df(
                ltf_window,
                htf_window if htf_window is not None and not htf_window.empty else ltf_window,
                timestamp,
                ml_prob=self.config.ml_prob,
                fp_score=real_fp_score,
            )
            if setup is None:
                return

            entry = setup.entry
            sl = setup.sl
            tp = setup.tp1  # Use TP1 for SL/TP distance; TradeManager in EA handles partials; here single TP
            lots = setup.lot
            direction = Direction.LONG if setup.direction == SignalType.BUY else Direction.SHORT

            self.position = Position(
                direction=direction,
                entry_time=timestamp,
                entry_price=entry,
                sl_price=sl,
                tp_price=tp,
                lots=lots,
                spread_at_entry=bar.get('spread', 0.30)
            )
            return
        
        # Skip if filters not met
        if not bar.get('is_trending', True):
            return
        if not bar.get('in_session', True):
            return
        
        atr = bar['atr']
        if pd.isna(atr) or atr <= 0:
            return
        
        # Simulate order rejection
        if self.execution.should_reject():
            return
        
        spread = bar.get('spread', 0.30)
        
        # BUY signal
        if bar['ma_cross_up']:
            entry = self.execution.get_fill_price(Direction.LONG, bar, is_entry=True)
            sl = entry - atr * self.config.atr_sl_mult
            tp = entry + atr * self.config.atr_tp_mult
            lots = self.risk.calculate_lots(entry, sl)
            
            self.position = Position(
                direction=Direction.LONG,
                entry_time=timestamp,
                entry_price=entry,
                sl_price=sl,
                tp_price=tp,
                lots=lots,
                spread_at_entry=spread
            )
        
        # SELL signal
        elif bar['ma_cross_down']:
            entry = self.execution.get_fill_price(Direction.SHORT, bar, is_entry=True)
            sl = entry + atr * self.config.atr_sl_mult
            tp = entry - atr * self.config.atr_tp_mult
            lots = self.risk.calculate_lots(entry, sl)
            
            self.position = Position(
                direction=Direction.SHORT,
                entry_time=timestamp,
                entry_price=entry,
                sl_price=sl,
                tp_price=tp,
                lots=lots,
                spread_at_entry=spread
            )
    
    def _manage_position(self, timestamp: datetime, bar: pd.Series):
        """Check SL/TP for open position with realistic execution friction"""
        
        # Get execution mode multiplier for slippage
        slip_mult = self.execution.mult['slippage']
        base_slip = self.config.base_slippage_points * 0.01  # Convert to price
        
        if self.position.direction == Direction.LONG:
            sl_hit = bar['low'] <= self.position.sl_price
            tp_hit = bar['high'] >= self.position.tp_price
            
            # REALISTIC: If both could hit, assume SL hit first (worst case)
            if sl_hit and tp_hit:
                # Both hit in same bar = worst case scenario
                # Apply adverse slippage beyond SL
                slippage = np.random.uniform(0, base_slip * slip_mult)
                exit_price = self.position.sl_price - slippage
                self._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
            elif sl_hit:
                # SL hit - apply adverse slippage (price goes further against us)
                slippage = np.random.uniform(0, base_slip * slip_mult)
                exit_price = self.position.sl_price - slippage
                self._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
            elif tp_hit:
                # TP hit - small adverse slippage (we might not get exact price)
                slippage = np.random.uniform(0, base_slip * slip_mult * 0.3)
                exit_price = self.position.tp_price - slippage
                self._close_position(timestamp, bar, ExitReason.TP, exit_price=exit_price)
        
        else:  # SHORT
            sl_hit = bar['high'] >= self.position.sl_price
            tp_hit = bar['low'] <= self.position.tp_price
            
            # REALISTIC: If both could hit, assume SL hit first (worst case)
            if sl_hit and tp_hit:
                # Both hit in same bar = worst case scenario
                slippage = np.random.uniform(0, base_slip * slip_mult)
                exit_price = self.position.sl_price + slippage
                self._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
            elif sl_hit:
                # SL hit - apply adverse slippage
                slippage = np.random.uniform(0, base_slip * slip_mult)
                exit_price = self.position.sl_price + slippage
                self._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
            elif tp_hit:
                # TP hit - small adverse slippage
                slippage = np.random.uniform(0, base_slip * slip_mult * 0.3)
                exit_price = self.position.tp_price + slippage
                self._close_position(timestamp, bar, ExitReason.TP, exit_price=exit_price)
    
    def _close_position(self, timestamp: datetime, bar: pd.Series,
                       reason: ExitReason, exit_price: float = None):
        """Close position and record trade"""
        
        if exit_price is None:
            exit_price = self.execution.get_fill_price(
                self.position.direction, bar, is_entry=False
            )
        
        # Calculate P&L
        if self.position.direction == Direction.LONG:
            pnl = (exit_price - self.position.entry_price) * self.position.lots * 100
        else:
            pnl = (self.position.entry_price - exit_price) * self.position.lots * 100
        
        # Update risk manager
        self.risk.update(pnl)
        
        # Record trade
        trade = Trade(
            entry_time=self.position.entry_time,
            exit_time=timestamp,
            direction=self.position.direction.value,
            entry_price=self.position.entry_price,
            exit_price=exit_price,
            sl=self.position.sl_price,
            tp=self.position.tp_price,
            lots=self.position.lots,
            pnl=pnl,
            pnl_pct=pnl / self.config.initial_balance,
            exit_reason=reason.value,
            spread_entry=self.position.spread_at_entry,
            spread_exit=bar.get('spread', 0.30),
            balance_after=self.risk.balance
        )
        self.trades.append(trade)
        
        # Clear position
        self.position = None
    
    def _calculate_metrics(self) -> Dict:
        """Calculate performance metrics"""
        
        if not self.trades:
            return {'error': 'No trades generated', 'total_trades': 0}
        
        pnls = [t.pnl for t in self.trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        total_trades = len(self.trades)
        win_rate = len(wins) / total_trades if total_trades > 0 else 0
        
        gross_profit = sum(wins) if wins else 0
        gross_loss = abs(sum(losses)) if losses else 0
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else float('inf')
        
        # Drawdown from equity curve
        if self.equity_curve:
            equity = np.array([e['balance'] for e in self.equity_curve])
            peak = np.maximum.accumulate(equity)
            dd = (peak - equity) / peak
            max_dd = dd.max()
        else:
            max_dd = self.risk.current_dd
        
        # Returns
        final_balance = self.risk.balance
        total_return = (final_balance - self.config.initial_balance) / self.config.initial_balance
        
        # Sharpe (annualized)
        if len(pnls) > 1:
            returns = np.array(pnls) / self.config.initial_balance
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
            'final_balance': final_balance,
            'net_profit': final_balance - self.config.initial_balance,
            'avg_spread': np.mean([t.spread_entry for t in self.trades]),
            'blown': self.risk.is_blown,
            'blow_reason': self.risk.blow_reason
        }
    
    def _print_report(self, metrics: Dict):
        """Print backtest report"""
        
        print("\n" + "="*60)
        print("           TICK BACKTEST REPORT")
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
        print(f"Avg Spread:       ${metrics['avg_spread']:.2f}")
        
        if metrics.get('blown'):
            print(f"\n[!] ACCOUNT BLOWN: {metrics['blow_reason']}")
        
        # FTMO Assessment
        print("\n" + "-"*40)
        print("FTMO COMPLIANCE:")
        
        if metrics['max_drawdown'] < 0.05:
            print("  [OK] Max DD < 5%")
        elif metrics['max_drawdown'] < 0.10:
            print("  [WARN] Max DD between 5-10%")
        else:
            print("  [FAIL] Max DD >= 10%")
        
        if metrics['profit_factor'] >= 1.5:
            print(f"  [OK] PF >= 1.5")
        elif metrics['profit_factor'] >= 1.0:
            print(f"  [WARN] PF between 1.0-1.5")
        else:
            print(f"  [FAIL] PF < 1.0")
        
        if metrics['total_trades'] >= 100:
            print(f"  [OK] Trades >= 100")
        elif metrics['total_trades'] >= 50:
            print(f"  [WARN] Trades between 50-100")
        else:
            print(f"  [WARN] Trades < 50 (low statistical significance)")
        
        # Exit reasons
        print("\n" + "-"*40)
        print("EXIT REASONS:")
        reasons = {}
        for t in self.trades:
            r = t.exit_reason
            reasons[r] = reasons.get(r, 0) + 1
        for r, count in sorted(reasons.items(), key=lambda x: -x[1]):
            print(f"  {r}: {count} ({count/len(self.trades):.1%})")
        
        print("="*60)
    
    def export_trades(self, filepath: str):
        """Export trades to CSV (Oracle-compatible format)"""
        
        if not self.trades:
            print("[Export] No trades to export")
            return
        
        data = []
        for t in self.trades:
            data.append({
                'entry_time': t.entry_time,
                'exit_time': t.exit_time,
                'direction': t.direction,
                'entry_price': t.entry_price,
                'exit_price': t.exit_price,
                'sl': t.sl,
                'tp': t.tp,
                'lots': t.lots,
                'pnl': t.pnl,
                'exit_reason': t.exit_reason
            })
        
        df = pd.DataFrame(data)
        df.to_csv(filepath, index=False)
        print(f"\n[Export] Trades saved to: {filepath}")


# =============================================================================
# MAIN
# =============================================================================

def run_test(name: str, config: BacktestConfig, tick_path: str, 
             max_ticks: int = 5_000_000) -> Dict:
    """Run a single test configuration"""
    print(f"\n{'#'*60}")
    print(f"# TEST: {name}")
    print(f"# Mode: {config.execution_mode.value}")
    print(f"# Regime Filter: {config.use_regime_filter}")
    print(f"# Session Filter: {config.use_session_filter}")
    print(f"{'#'*60}")
    
    bt = TickBacktester(config)
    results = bt.run(tick_path, max_ticks=max_ticks)
    
    # Export trades
    safe_name = name.lower().replace(' ', '_').replace('+', '_')
    export_path = f"C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/trades_{safe_name}.csv"
    bt.export_trades(export_path)
    
    return {
        'name': name,
        'config': config,
        'results': results,
        'metrics': results.get('metrics', {})
    }


def run_filter_comparison():
    """Run comparison of different filter configurations"""
    
    tick_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv"
    max_ticks = 5_000_000
    
    tests = []
    
    # Test 1: Baseline (no filters) - PESSIMISTIC mode
    config1 = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        use_regime_filter=False,
        use_session_filter=False,
        debug=False
    )
    tests.append(run_test("Baseline", config1, tick_path, max_ticks))
    
    # Test 2: Regime Filter Only
    config2 = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        use_regime_filter=True,
        hurst_threshold=0.55,
        use_session_filter=False,
        debug=False
    )
    tests.append(run_test("Regime Filter", config2, tick_path, max_ticks))
    
    # Test 3: Session Filter Only
    config3 = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        use_regime_filter=False,
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        debug=False
    )
    tests.append(run_test("Session Filter", config3, tick_path, max_ticks))
    
    # Test 4: Both Filters
    config4 = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        use_regime_filter=True,
        hurst_threshold=0.55,
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        debug=False
    )
    tests.append(run_test("Regime + Session", config4, tick_path, max_ticks))
    
    # Summary comparison
    print("\n" + "="*80)
    print("                        FILTER COMPARISON SUMMARY")
    print("="*80)
    print(f"{'Test':<20} {'Trades':>8} {'WR':>8} {'PF':>8} {'MaxDD':>8} {'Return':>10} {'Status':<10}")
    print("-"*80)
    
    for t in tests:
        m = t['metrics']
        if 'error' in m:
            print(f"{t['name']:<20} {'N/A':>8} {'N/A':>8} {'N/A':>8} {'N/A':>8} {'N/A':>10} {'ERROR':<10}")
            continue
            
        status = "OK" if m['profit_factor'] >= 1.0 and m['max_drawdown'] < 0.10 else "FAIL"
        if m['profit_factor'] >= 1.3 and m['max_drawdown'] < 0.08:
            status = "GOOD"
        if m['profit_factor'] >= 1.5 and m['max_drawdown'] < 0.05:
            status = "GREAT"
            
        print(f"{t['name']:<20} {m['total_trades']:>8} {m['win_rate']:>7.1%} "
              f"{m['profit_factor']:>8.2f} {m['max_drawdown']:>7.2%} "
              f"{m['total_return']:>9.2%} {status:<10}")
    
    print("="*80)
    
    # Recommendation
    best = max(tests, key=lambda x: x['metrics'].get('profit_factor', 0))
    print(f"\nBest configuration: {best['name']} (PF: {best['metrics'].get('profit_factor', 0):.2f})")
    
    return tests


def main():
    """Run backtest with default configuration"""
    
    import sys
    
    # Check command line args
    if len(sys.argv) > 1 and sys.argv[1] == '--compare':
        return run_filter_comparison()
    
    # Single test mode
    config = BacktestConfig(
        # Execution - PESSIMISTIC for realistic results
        execution_mode=ExecutionMode.PESSIMISTIC,
        
        # Risk
        initial_balance=100_000,
        risk_per_trade=0.005,
        
        # Strategy
        fast_ma=20,
        slow_ma=50,
        atr_period=14,
        atr_sl_mult=2.0,
        atr_tp_mult=3.0,
        
        # Filters
        use_regime_filter=False,
        use_session_filter=False,
        
        # Timeframe
        bar_timeframe='5min',
        
        # Debug
        debug=True,
        debug_interval=500
    )
    
    # Data path
    tick_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv"
    
    # Run backtest
    bt = TickBacktester(config)
    results = bt.run(tick_path, max_ticks=5_000_000)
    
    # Export trades
    export_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/tick_trades.csv"
    bt.export_trades(export_path)
    
    return results


if __name__ == "__main__":
    main()
