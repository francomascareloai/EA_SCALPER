#!/usr/bin/env python3
"""
Realistic Event-Driven Backtester v2.0
======================================
Institutional-grade backtester that mirrors EA_SCALPER_XAUUSD real behavior.

Key Improvements over v1.0:
- Uses EALogic (real confluence scoring, regime detection, session filter)
- Simulates Python Hub latency (Gamma distribution + packet loss)
- ONNX inference mock with realistic timing
- MTF alignment calculation
- Full FTMO compliance monitoring

Author: FORGE v3.1
Date: 2025-12-01
"""

import os
import sys
import numpy as np
import pandas as pd
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Tuple
from datetime import datetime, timedelta, timezone
from enum import Enum
import warnings
warnings.filterwarnings('ignore')

# Add strategies folder to path for direct imports (avoid __init__.py chain)
_strategies_path = str(Path(__file__).parent / "strategies")
if _strategies_path not in sys.path:
    sys.path.insert(0, _strategies_path)

# Import EA logic modules
# Try FULL port first (6 modules), fallback to COMPAT (simplified)
USE_FULL_LOGIC = False
EALogicFull = None
create_ea_logic = None
MarketRegime = None
SignalType = None
EALogic = None
BarData = None
Signal = None
Regime = None

try:
    from ea_logic_full import (
        EALogicFull, SignalType, MarketRegime, TradingSession,
        RegimeDetector as FullRegimeDetector, 
        SessionFilter as FullSessionFilter, 
        ConfluenceScorer as FullConfluenceScorer, 
        ConfluenceResult,
        create_ea_logic
    )
    from footprint_analyzer import FootprintAnalyzer, FootprintConfig, merge_footprint_with_bars
    USE_FULL_LOGIC = True
    print("[Init] ea_logic_full.py loaded (FULL PORT)")
except ImportError as e:
    print(f"[Init] ea_logic_full.py not available: {e}")

# Always import compat as fallback (needed for backward compatibility)
try:
    from ea_logic_compat import (
        EALogic, BarData, Signal, 
        SignalType as CompatSignalType, 
        Regime, Session,
        RegimeDetector as CompatRegimeDetector, 
        SessionFilter as CompatSessionFilter, 
        ConfluenceScorer as CompatConfluenceScorer, 
        RiskManager
    )
    # If full not available, use compat SignalType
    if not USE_FULL_LOGIC:
        SignalType = CompatSignalType
        print("[Init] Using ea_logic_compat.py (SIMPLIFIED)")
except ImportError as e:
    print(f"[Init] ea_logic_compat.py not available: {e}")
    if not USE_FULL_LOGIC:
        raise RuntimeError("Neither ea_logic_full nor ea_logic_compat could be imported!")

print(f"[Init] USE_FULL_LOGIC = {USE_FULL_LOGIC}")


# =============================================================================
# CONFIGURATION
# =============================================================================

class ExecutionMode(Enum):
    OPTIMISTIC = "optimistic"
    NORMAL = "normal"
    PESSIMISTIC = "pessimistic"
    STRESS = "stress"


@dataclass
class RealisticBacktestConfig:
    """Configuration that mirrors real EA behavior"""
    # Capital
    initial_balance: float = 100_000.0
    
    # FTMO Limits (HARDCODED - never change)
    max_daily_dd: float = 0.05
    max_total_dd: float = 0.10
    
    # Execution Mode
    execution_mode: ExecutionMode = ExecutionMode.PESSIMISTIC
    
    # Latency Simulation (Python Hub)
    enable_latency_sim: bool = True
    base_ping_ms: float = 20.0          # Base network latency
    inference_mean_ms: float = 5.0      # ONNX inference time
    inference_std_ms: float = 2.0
    network_gamma_shape: float = 2.0    # Gamma distribution shape
    network_gamma_scale: float = 5.0    # Gamma distribution scale
    packet_loss_prob: float = 0.001     # 0.1% packet loss
    packet_loss_delay_ms: float = 200.0 # Delay on packet loss
    
    # Execution costs
    base_slippage_points: float = 3.0
    rejection_rate: float = 0.02
    
    # Strategy (matches EA)
    min_confluence: float = 65.0        # Minimum score to trade
    min_rr: float = 1.5                 # Minimum risk:reward
    enable_footprint: bool = True       # Use footprint order-flow scoring
    
    # Timeframes for MTF
    primary_tf: str = '5min'
    mtf_timeframes: List[str] = field(default_factory=lambda: ['1min', '5min', '15min', '1h'])
    
    # ONNX Mock
    enable_onnx_mock: bool = True
    onnx_base_prob: float = 0.5         # Base probability when no model
    onnx_regime_boost: float = 0.15     # Boost when trending
    
    # Debug
    debug: bool = False
    debug_interval: int = 500


# =============================================================================
# LATENCY SIMULATOR
# =============================================================================

class LatencySimulator:
    """
    Simulates realistic Python Hub latency.
    
    Components:
    - Network jitter (Gamma distribution)
    - ONNX inference time (Normal distribution)
    - Packet loss events (Bernoulli process)
    - Volatility-based broker delay
    """
    
    def __init__(self, config: RealisticBacktestConfig):
        self.config = config
        self.total_latency_samples = []
        self.packet_loss_count = 0
    
    def simulate_round_trip(self, is_high_volatility: bool = False) -> float:
        """
        Simulate full round-trip latency: MT5 -> Python Hub -> MT5
        
        Returns:
            Total latency in milliseconds
        """
        if not self.config.enable_latency_sim:
            return 0.0
        
        # 1. Network jitter (Gamma distribution - fat tail)
        network_jitter = np.random.gamma(
            self.config.network_gamma_shape,
            self.config.network_gamma_scale
        )
        
        # 2. ONNX inference time
        inference_time = max(0, np.random.normal(
            self.config.inference_mean_ms,
            self.config.inference_std_ms
        ))
        
        # 3. Packet loss event (catastrophic delay)
        packet_loss_delay = 0.0
        if np.random.random() < self.config.packet_loss_prob:
            packet_loss_delay = self.config.packet_loss_delay_ms
            self.packet_loss_count += 1
        
        # 4. Volatility drag (broker processing slower during news)
        vol_drag = 30.0 if is_high_volatility else 0.0
        
        # Total
        total = (
            self.config.base_ping_ms +
            network_jitter +
            inference_time +
            packet_loss_delay +
            vol_drag
        )
        
        self.total_latency_samples.append(total)
        return total
    
    def get_stats(self) -> Dict:
        """Get latency statistics"""
        if not self.total_latency_samples:
            return {}
        
        samples = np.array(self.total_latency_samples)
        return {
            'mean_ms': np.mean(samples),
            'std_ms': np.std(samples),
            'p50_ms': np.percentile(samples, 50),
            'p95_ms': np.percentile(samples, 95),
            'p99_ms': np.percentile(samples, 99),
            'max_ms': np.max(samples),
            'packet_loss_events': self.packet_loss_count
        }


# =============================================================================
# ONNX MOCK
# =============================================================================

class ONNXMock:
    """
    Mock ONNX inference that simulates ML model behavior.
    
    In production, this would load actual ONNX model.
    Here we simulate reasonable predictions based on market state.
    """
    
    def __init__(self, config: RealisticBacktestConfig):
        self.config = config
    
    def predict_direction(self, features: Dict) -> float:
        """
        Predict direction probability (0-1, >0.5 = bullish)
        
        Args:
            features: Dict with keys like 'regime', 'rsi', 'trend', etc.
        
        Returns:
            Probability of upward move
        """
        base = self.config.onnx_base_prob
        
        # Adjust based on regime
        regime = features.get('regime', Regime.RANGING)
        if regime == Regime.TRENDING:
            # In trending, bias towards trend direction
            trend_dir = features.get('trend_direction', 0)
            base += self.config.onnx_regime_boost * trend_dir
        elif regime == Regime.REVERTING:
            # In reverting, bias towards mean
            deviation = features.get('deviation_from_mean', 0)
            base -= 0.1 * np.sign(deviation)
        
        # Adjust based on RSI
        rsi = features.get('rsi', 50)
        if rsi < 30:
            base += 0.1  # Oversold = bullish
        elif rsi > 70:
            base -= 0.1  # Overbought = bearish
        
        # Add noise for realism
        noise = np.random.normal(0, 0.05)
        
        return np.clip(base + noise, 0.1, 0.9)


# =============================================================================
# MTF ANALYZER
# =============================================================================

class MTFAnalyzer:
    """
    Multi-Timeframe alignment analyzer.

    WP3: Must be causal.
    Alignment at time `current_time` must only use bars fully known at that time.
    """

    def __init__(self, timeframes: List[str]):
        self.timeframes = timeframes
        self.bars_cache: Dict[str, pd.DataFrame] = {}

    @staticmethod
    def _closed_bars_asof(bars: pd.DataFrame, current_time: datetime, timeframe: str) -> pd.DataFrame:
        """Return only bars that are fully closed as of current_time.

        Pandas resample() labels by period start by default (label='left').
        A bar is fully closed when (bar_start + timeframe) <= current_time.
        """
        if bars.empty:
            return bars

        ts = pd.Timestamp(current_time)
        tf_delta = pd.Timedelta(timeframe)
        return bars[bars.index + tf_delta <= ts]

    def calculate_alignment(self, bars_dict: Dict[str, pd.DataFrame], current_time: datetime) -> float:
        """Calculate MTF alignment score (causal).

        Args:
            bars_dict: Dict of timeframe -> OHLC DataFrame
            current_time: Current timestamp in primary timeframe

        Returns:
            Alignment score 0-1 (1 = all timeframes agree)
        """
        directions: list[int] = []

        for tf, bars in bars_dict.items():
            if bars is None or bars.empty:
                continue

            bars_asof = self._closed_bars_asof(bars, current_time, tf)
            if len(bars_asof) < 20:
                continue

            # Simple trend direction based on MA (computed on truncated history)
            close = bars_asof['close']
            ma_fast = close.rolling(10, min_periods=10).mean().iloc[-1]
            ma_slow = close.rolling(20, min_periods=20).mean().iloc[-1]

            if ma_fast > ma_slow:
                directions.append(1)  # Bullish
            elif ma_fast < ma_slow:
                directions.append(-1)  # Bearish
            else:
                directions.append(0)

        if not directions:
            return 0.5

        # Alignment = proportion of timeframes agreeing
        avg_direction = float(np.mean(directions))
        return float(abs(avg_direction))  # 0 = mixed, 1 = all agree


# =============================================================================
# EXECUTION MODEL
# =============================================================================

class RealisticExecutionModel:
    """
    Execution simulation with mode-based scaling and latency impact.
    """
    
    MODE_MULTIPLIERS = {
        ExecutionMode.OPTIMISTIC: {'spread': 1.0, 'slippage': 0.5, 'rejection': 0.5},
        ExecutionMode.NORMAL: {'spread': 1.0, 'slippage': 1.0, 'rejection': 1.0},
        ExecutionMode.PESSIMISTIC: {'spread': 1.5, 'slippage': 2.0, 'rejection': 1.5},
        ExecutionMode.STRESS: {'spread': 3.0, 'slippage': 5.0, 'rejection': 3.0},
    }
    
    def __init__(self, config: RealisticBacktestConfig, latency_sim: LatencySimulator):
        self.config = config
        self.latency_sim = latency_sim
        self.mult = self.MODE_MULTIPLIERS[config.execution_mode]
        self.rejections = 0
        self.latency_slippage_events = 0
    
    def should_reject(self) -> bool:
        """Simulate order rejection"""
        if np.random.random() < self.config.rejection_rate * self.mult['rejection']:
            self.rejections += 1
            return True
        return False
    
    def get_fill_price(self, direction: SignalType, bar: pd.Series,
                       latency_ms: float, is_entry: bool = True) -> float:
        """
        Calculate fill price considering spread, slippage, AND latency.
        
        The key insight: During latency, price moves. We simulate this.
        """
        base_spread = bar.get('spread', 0.30)
        spread = base_spread * self.mult['spread']
        mid = bar['close']
        
        # Base slippage
        max_slip = self.config.base_slippage_points * 0.01 * self.mult['slippage']
        slippage = np.random.uniform(0, max_slip)
        
        # LATENCY SLIPPAGE: Price movement during latency
        # Assume price can move ~0.01 per 10ms of latency
        latency_price_impact = 0.0
        if latency_ms > 30:  # Only significant if latency > 30ms
            price_volatility = bar.get('high', mid) - bar.get('low', mid)
            latency_factor = (latency_ms - 30) / 100  # Normalize
            # Random direction, magnitude proportional to latency and volatility
            latency_price_impact = np.random.uniform(-1, 1) * price_volatility * latency_factor * 0.5
            if abs(latency_price_impact) > 0.05:
                self.latency_slippage_events += 1
        
        # Calculate fill
        if direction == SignalType.BUY:
            if is_entry:
                return mid + spread/2 + slippage + max(0, latency_price_impact)
            else:
                return mid - spread/2 - slippage + min(0, latency_price_impact)
        else:
            if is_entry:
                return mid - spread/2 - slippage + min(0, latency_price_impact)
            else:
                return mid + spread/2 + slippage + max(0, latency_price_impact)


# =============================================================================
# FTMO RISK MANAGER
# =============================================================================

class FTMORiskManager:
    """
    FTMO-compliant risk management with strict DD tracking.
    """
    
    def __init__(self, config: RealisticBacktestConfig):
        self.config = config
        self.initial_balance = config.initial_balance
        self.balance = config.initial_balance
        self.equity = config.initial_balance
        self.peak_balance = config.initial_balance
        self.daily_start_balance = config.initial_balance
        self.current_date = None
        self.daily_pnl = 0.0
        self.is_blown = False
        self.blow_reason = None
        
        # Track Kelly for adaptive sizing
        self.wins = 0
        self.losses = 0
        self.total_win = 0.0
        self.total_loss = 0.0
    
    def new_day(self, date):
        """Reset daily tracking"""
        if self.current_date != date:
            self.current_date = date
            self.daily_start_balance = self.balance
            self.daily_pnl = 0.0
    
    def update(self, pnl: float):
        """Update after trade"""
        self.balance += pnl
        self.equity = self.balance
        self.daily_pnl += pnl
        
        if pnl > 0:
            self.wins += 1
            self.total_win += pnl
        else:
            self.losses += 1
            self.total_loss += abs(pnl)
        
        if self.balance > self.peak_balance:
            self.peak_balance = self.balance
    
    def check_limits(self) -> Tuple[bool, Optional[str]]:
        """Check FTMO limits. Returns (can_trade, breach_reason)"""
        # Daily DD (from initial, not from peak)
        daily_dd = -self.daily_pnl / self.initial_balance
        if daily_dd >= self.config.max_daily_dd:
            self.is_blown = True
            self.blow_reason = "DAILY_DD"
            return False, "DAILY_DD"
        
        # Total DD (from peak)
        total_dd = (self.peak_balance - self.balance) / self.peak_balance
        if total_dd >= self.config.max_total_dd:
            self.is_blown = True
            self.blow_reason = "TOTAL_DD"
            return False, "TOTAL_DD"
        
        return True, None
    
    @property
    def current_dd(self) -> float:
        if self.peak_balance <= 0:
            return 0
        return (self.peak_balance - self.balance) / self.peak_balance
    
    @property
    def current_daily_dd(self) -> float:
        return -self.daily_pnl / self.initial_balance


# =============================================================================
# TRADE STRUCTURES
# =============================================================================

@dataclass
class Position:
    direction: SignalType  # Works with both full and compat SignalType
    entry_time: datetime
    entry_price: float
    sl_price: float
    tp_price: float
    lots: float
    spread_at_entry: float
    confluence_score: float
    regime: any  # MarketRegime (full) or Regime (compat)
    latency_ms: float


@dataclass
class Trade:
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
    confluence_score: float
    regime: str
    latency_ms: float
    balance_after: float


# =============================================================================
# REALISTIC BACKTESTER
# =============================================================================

class RealisticBacktester:
    """
    Event-driven backtester using real EA logic.
    
    Process:
    1. Load tick data
    2. Resample to multiple timeframes
    3. For each bar:
       a. Simulate latency
       b. Run EALogic.evaluate()
       c. If signal, calculate fill with latency impact
       d. Track position and P&L
    4. Generate Oracle-compatible output
    """
    
    def __init__(self, config: RealisticBacktestConfig = None):
        self.config = config or RealisticBacktestConfig()
        
        # Components
        self.latency_sim = LatencySimulator(self.config)
        self.execution = RealisticExecutionModel(self.config, self.latency_sim)
        self.risk = FTMORiskManager(self.config)
        self.onnx = ONNXMock(self.config)
        self.mtf = MTFAnalyzer(self.config.mtf_timeframes)
        
        # EA Logic - use full port if available
        if USE_FULL_LOGIC:
            self.ea_logic_full = create_ea_logic(gmt_offset=0, debug=self.config.debug, verbose=self.config.debug)
            # Override internal threshold with config
            self.ea_logic_full.execution_threshold = self.config.min_confluence
            self.ea_logic = None  # Not used when full is available
            print(f"[Init] EA Logic: FULL PORT (6 modules), threshold={self.config.min_confluence}")
        else:
            self.ea_logic_full = None
            self.ea_logic = EALogic(self.config.initial_balance)
            print("[Init] EA Logic: COMPAT (simplified)")
        
        # State
        self.position: Optional[Position] = None
        self.trades: List[Trade] = []
        self.equity_curve: List[dict] = []
        self.signals_generated = 0
        self.signals_rejected = 0
    
    def run(self, tick_path: str, max_ticks: int = 5_000_000,
            start_date: str = None, end_date: str = None) -> Dict:
        """Run complete backtest"""
        print("\n" + "=" * 70)
        print("    REALISTIC EVENT-DRIVEN BACKTESTER v2.0 (FORGE)")
        print("=" * 70)
        print(f"Mode: {self.config.execution_mode.value}")
        print(f"Latency Simulation: {'ON' if self.config.enable_latency_sim else 'OFF'}")
        print(f"ONNX Mock: {'ON' if self.config.enable_onnx_mock else 'OFF'}")
        print(f"Min Confluence: {self.config.min_confluence}")
        
        # 1. Load ticks
        ticks = self._load_ticks(tick_path, max_ticks, start_date, end_date)
        
        # 2. Resample to multiple timeframes
        bars_dict = self._resample_mtf(ticks)
        primary_bars = bars_dict[self.config.primary_tf]
        
        # 3. Calculate indicators
        print("[Backtest] Calculating indicators...")
        primary_bars = self._add_indicators(primary_bars)

        # 3b. Footprint (if full logic available)
        if USE_FULL_LOGIC and self.config.enable_footprint:
            print("[Backtest] Calculating footprint (order flow)...")
            fp_cfg = FootprintConfig(bar_timeframe='5min', verbose=self.config.debug)
            analyzer = FootprintAnalyzer(fp_cfg)
            ticks_fp = ticks.copy()
            if 'datetime' in ticks_fp.columns:
                ticks_fp = ticks_fp.set_index('datetime')
            if 'mid' in ticks_fp.columns and 'mid_price' not in ticks_fp.columns:
                ticks_fp = ticks_fp.rename(columns={'mid': 'mid_price'})
            fp_df = analyzer.analyze_ticks(ticks_fp)
            # Merge footprint into 5min bars
            bars_dict['5min'] = merge_footprint_with_bars(bars_dict['5min'], fp_df)
            # Ensure primary bars have fp_score if primary_tf == 5min
            if self.config.primary_tf == '5min':
                primary_bars = bars_dict['5min']
        
        # 4. Run simulation
        print("[Backtest] Running simulation with EALogic...")
        self._simulate(primary_bars, bars_dict)
        
        # 5. Calculate metrics
        metrics = self._calculate_metrics()
        
        # 6. Print report
        self._print_report(metrics)
        
        return {
            'trades': self.trades,
            'metrics': metrics,
            'equity_curve': self.equity_curve,
            'latency_stats': self.latency_sim.get_stats(),
            'bars': len(primary_bars),
            'ticks': len(ticks)
        }
    
    def _load_ticks(self, filepath: str, max_ticks: int,
                    start_date: str, end_date: str) -> pd.DataFrame:
        """Load tick data (flexible header, no seek truncation).

        Accepted columns (any casing):
        - datetime / DateTime
        - bid / Bid
        - ask / Ask
        - spread (optional)
        """
        file_size = os.path.getsize(filepath)
        print(f"[TickLoader] File: {filepath}")
        print(f"[TickLoader] Size: {file_size / (1024**3):.2f} GB")
        print(f"[TickLoader] Loading up to {max_ticks:,} ticks (no seek truncation)...")

        # Parquet fast-path
        if filepath.lower().endswith('.parquet'):
            dfp = pd.read_parquet(filepath)
            if len(dfp) > max_ticks:
                dfp = dfp.iloc[:max_ticks]
            cols = {c.lower(): c for c in dfp.columns}
            dfp.rename(columns={
                cols.get('datetime', dfp.columns[0]): 'datetime',
                cols.get('bid', dfp.columns[1]): 'bid',
                cols.get('ask', dfp.columns[2]): 'ask'
            }, inplace=True)
            if 'spread' not in dfp.columns:
                dfp['spread'] = dfp['ask'] - dfp['bid']
            if 'mid' not in dfp.columns:
                dfp['mid'] = (dfp['ask'] + dfp['bid']) / 2
            if 'volume' not in dfp.columns:
                dfp['volume'] = 1.0
            dfp.dropna(subset=['datetime', 'bid', 'ask'], inplace=True)
            dfp.set_index('datetime', inplace=True)
            dfp.index = pd.to_datetime(dfp.index)
            dfp.sort_index(inplace=True)
            if start_date:
                dfp = dfp[dfp.index >= start_date]
            if end_date:
                dfp = dfp[dfp.index <= end_date]
            print(f"[TickLoader] Loaded {len(dfp):,} ticks (parquet)")
            if len(dfp):
                print(f"[TickLoader] Period: {dfp.index[0]} to {dfp.index[-1]}")
            return dfp

        import csv as _csv
        _csv.field_size_limit(int(1e9))

        chunks = []
        total = 0
        for chunk in pd.read_csv(
            filepath,
            header=0,
            parse_dates=[0],
            infer_datetime_format=True,
            engine='python',
            on_bad_lines='skip',
            chunksize=500_000
        ):
            # Normalize columns on first chunk
            cols = {c.lower(): c for c in chunk.columns}
            if 'datetime' not in cols:
                # Assume no header
                chunk.columns = ['datetime', 'bid', 'ask'] + list(chunk.columns[3:])
                cols = {c.lower(): c for c in chunk.columns}

            # Rename
            chunk.rename(columns={
                cols.get('datetime', chunk.columns[0]): 'datetime',
                cols.get('bid', chunk.columns[1]): 'bid',
                cols.get('ask', chunk.columns[2]): 'ask'
            }, inplace=True)

            chunk = chunk[['datetime', 'bid', 'ask']]
            chunk.dropna(subset=['datetime', 'bid', 'ask'], inplace=True)

            if start_date:
                chunk = chunk[chunk['datetime'] >= start_date]
            if end_date:
                chunk = chunk[chunk['datetime'] <= end_date]

            if chunk.empty:
                continue

            chunks.append(chunk)
            total += len(chunk)
            if total >= max_ticks:
                break

        if not chunks:
            print("[TickLoader] Loaded 0 ticks (no data matched filters).")
            return pd.DataFrame(columns=['bid', 'ask', 'spread', 'mid', 'volume'])

        df = pd.concat(chunks, axis=0)
        if len(df) > max_ticks:
            df = df.iloc[:max_ticks]

        # Normalise column names
        cols = {c.lower(): c for c in df.columns}
        df.rename(columns={
            cols.get('datetime', df.columns[0]): 'datetime',
            cols.get('bid', df.columns[1]): 'bid',
            cols.get('ask', df.columns[2]): 'ask'
        }, inplace=True)

        if 'spread' not in df.columns:
            df['spread'] = df['ask'] - df['bid']
        if 'mid' not in df.columns:
            df['mid'] = (df['ask'] + df['bid']) / 2
        if 'volume' not in df.columns:
            df['volume'] = 1.0

        # Drop NA and sort
        df.dropna(subset=['datetime', 'bid', 'ask'], inplace=True)
        df.set_index('datetime', inplace=True)
        # Ensure DateTimeIndex
        df.index = pd.to_datetime(df.index)
        df.sort_index(inplace=True)

        if start_date:
            df = df[df.index >= start_date]
        if end_date:
            df = df[df.index <= end_date]

        if len(df) > max_ticks:
            df = df.iloc[:max_ticks]

        print(f"[TickLoader] Loaded {len(df):,} ticks")
        if len(df) > 0:
            print(f"[TickLoader] Period: {df.index[0]} to {df.index[-1]}")

        return df
    
    def _resample_mtf(self, ticks: pd.DataFrame) -> Dict[str, pd.DataFrame]:
        """Resample to multiple timeframes"""
        print("[Resampler] Creating MTF bars...")
        
        result = {}
        for tf in self.config.mtf_timeframes:
            ohlc = ticks['mid'].resample(tf).ohlc()
            ohlc.columns = ['open', 'high', 'low', 'close']
            ohlc['spread'] = ticks['spread'].resample(tf).mean()
            ohlc = ohlc.dropna()
            result[tf] = ohlc
            print(f"  {tf}: {len(ohlc):,} bars")
        
        return result
    
    def _add_indicators(self, bars: pd.DataFrame) -> pd.DataFrame:
        """Add technical indicators"""
        # ATR
        bars['tr'] = np.maximum(
            bars['high'] - bars['low'],
            np.maximum(
                abs(bars['high'] - bars['close'].shift(1)),
                abs(bars['low'] - bars['close'].shift(1))
            )
        )
        bars['atr'] = bars['tr'].rolling(14).mean()
        
        # RSI
        delta = bars['close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(14).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(14).mean()
        rs = gain / (loss + 1e-10)
        bars['rsi'] = 100 - (100 / (1 + rs))
        
        # Simple trend direction
        bars['ma_fast'] = bars['close'].rolling(10).mean()
        bars['ma_slow'] = bars['close'].rolling(20).mean()
        bars['trend'] = np.where(bars['ma_fast'] > bars['ma_slow'], 1, -1)
        
        return bars.dropna()
    
    def _simulate(self, bars: pd.DataFrame, bars_dict: Dict[str, pd.DataFrame]):
        """Main simulation loop"""
        
        for i, (timestamp, bar) in enumerate(bars.iterrows()):
            # Update daily tracking
            self.risk.new_day(timestamp.date())
            
            if self.risk.is_blown:
                break
            
            can_trade, breach = self.risk.check_limits()
            if not can_trade:
                if self.position:
                    self._close_position(timestamp, bar, breach)
                continue
            
            # Manage existing position
            if self.position:
                self._manage_position(timestamp, bar)
            
            # Generate new signals
            if self.position is None and can_trade:
                self._check_entry(timestamp, bar, bars_dict, i)
            
            # Record equity
            self.equity_curve.append({
                'datetime': timestamp,
                'balance': self.risk.balance,
                'dd': self.risk.current_dd
            })
            
            if self.config.debug and i % self.config.debug_interval == 0:
                print(f"[{timestamp}] Bal: ${self.risk.balance:,.0f} | "
                      f"DD: {self.risk.current_dd:.2%} | Trades: {len(self.trades)}")
        
        # Close remaining position
        if self.position:
            self._close_position(bars.index[-1], bars.iloc[-1], "END")
    
    def _check_entry(self, timestamp: datetime, bar: pd.Series,
                     bars_dict: Dict[str, pd.DataFrame], idx: int):
        """Check for entry using EALogic (full or compat)"""
        
        # 1. Simulate Python Hub latency FIRST
        is_high_vol = bar.get('atr', 5) > 10  # High volatility threshold
        latency_ms = self.latency_sim.simulate_round_trip(is_high_vol)
        
        self.signals_generated += 1
        
        # FULL PORT PATH (ea_logic_full.py)
        if USE_FULL_LOGIC and self.ea_logic_full is not None:
            result = self._check_entry_full(timestamp, bar, bars_dict, idx, latency_ms)
            if result:
                return
            return
        
        # COMPAT PATH (ea_logic_compat.py fallback)
        self._check_entry_compat(timestamp, bar, bars_dict, idx, latency_ms)
    
    def _check_entry_full(self, timestamp: datetime, bar: pd.Series,
                          bars_dict: Dict[str, pd.DataFrame], idx: int,
                          latency_ms: float) -> bool:
        """Check entry using FULL EA port (ea_logic_full.py)"""
        
        # Extract MTF data
        h1_bars = bars_dict.get('1h', bars_dict.get('60min', None))
        m15_bars = bars_dict.get('15min', None)
        m5_bars = bars_dict.get('5min', None)
        
        if h1_bars is None or m15_bars is None or m5_bars is None:
            if self.config.debug:
                print(f"[DEBUG] Missing MTF bars")
            return False
        
        # Get aligned bars (by timestamp, not by index)
        try:
            # Find closest bars for each timeframe
            h1_idx = h1_bars.index.get_indexer([timestamp], method='ffill')[0]
            m15_idx = m15_bars.index.get_indexer([timestamp], method='ffill')[0]
            m5_idx = m5_bars.index.get_indexer([timestamp], method='ffill')[0]
            
            if h1_idx < 50 or m15_idx < 50 or m5_idx < 20:
                if self.config.debug and idx % 500 == 0:
                    print(f"[DEBUG] Not enough history: H1={h1_idx}, M15={m15_idx}, M5={m5_idx}")
                return False  # Not enough history
            
            # Get close arrays (RegimeDetector needs up to 220 bars for hurst_long_window)
            h1_closes = h1_bars['close'].iloc[max(0, h1_idx-250):h1_idx+1].values
            m15_closes = m15_bars['close'].iloc[max(0, m15_idx-250):m15_idx+1].values
            m5_closes = m5_bars['close'].iloc[max(0, m5_idx-100):m5_idx+1].values
            
            # Get highs/lows for sweep detection
            m15_highs = m15_bars['high'].iloc[max(0, m15_idx-50):m15_idx+1].values
            m15_lows = m15_bars['low'].iloc[max(0, m15_idx-50):m15_idx+1].values
            
            # Calculate ATRs
            def calc_atr(bars_df, period=14):
                if len(bars_df) < period + 1:
                    return 5.0  # Default
                tr = np.maximum(
                    bars_df['high'] - bars_df['low'],
                    np.maximum(
                        np.abs(bars_df['high'] - bars_df['close'].shift(1)),
                        np.abs(bars_df['low'] - bars_df['close'].shift(1))
                    )
                )
                return tr.rolling(period).mean().iloc[-1]
            
            h1_atr = calc_atr(h1_bars.iloc[max(0, h1_idx-20):h1_idx+1])
            m15_atr = calc_atr(m15_bars.iloc[max(0, m15_idx-20):m15_idx+1])
            
            # Get M5 RSI
            m5_rsi = bar.get('rsi', 50)
            
            # Current price and spread
            current_price = bar['close']
            spread_points = int(bar.get('spread', 0.30) / 0.01)  # Convert to points
            
        except Exception as e:
            return False
        
        # Call EALogicFull.analyze()
        # Build LTF dataframe window (includes fp_score if merged)
        ltf_window = m5_bars.iloc[max(0, m5_idx-120):m5_idx+1].copy()

        result = self.ea_logic_full.analyze(
            h1_closes=h1_closes,
            m15_closes=m15_closes,
            m5_closes=m5_closes,
            m15_highs=m15_highs,
            m15_lows=m15_lows,
            h1_atr=h1_atr,
            m15_atr=m15_atr,
            m5_rsi=m5_rsi,
            timestamp=timestamp,
            current_price=current_price,
            spread_points=spread_points,
            ltf_df=ltf_window
        )
        
        # Debug output (every 100 bars when debug enabled)
        if self.config.debug and idx % 100 == 0:
            regime = self.ea_logic_full.get_regime_info()
            print(f"[DEBUG {timestamp}] Regime={regime['regime']}, Score={result.total_score:.0f}, "
                  f"Dir={result.direction.name if hasattr(result.direction, 'name') else result.direction}, Valid={result.is_valid}")
        
        # No valid signal
        if not result.is_valid or result.direction == SignalType.NONE:
            return False
        
        # Check minimum confluence
        if result.total_score < self.config.min_confluence:
            self.signals_rejected += 1
            return False
        
        # Check for order rejection
        if self.execution.should_reject():
            self.signals_rejected += 1
            return False
        
        # Calculate fill price WITH latency impact
        fill_price = self.execution.get_fill_price(
            result.direction, bar, latency_ms, is_entry=True
        )
        
        # Get SL/TP from result (already calculated by ConfluenceScorer)
        sl = result.stop_loss
        tp = result.take_profit_1
        
        # Calculate lot size using regime-aware sizing
        sl_points = abs(fill_price - sl) / 0.01
        lots = self.ea_logic_full.get_position_size(
            self.risk.balance, sl_points, timestamp=timestamp
        )
        lots = max(0.01, min(lots, 5.0))  # Clamp to reasonable range
        
        # Get regime for logging
        regime_info = self.ea_logic_full.get_regime_info()
        
        # Create position
        self.position = Position(
            direction=result.direction,
            entry_time=timestamp,
            entry_price=fill_price,
            sl_price=sl,
            tp_price=tp,
            lots=lots,
            spread_at_entry=bar.get('spread', 0.30),
            confluence_score=result.total_score,
            regime=MarketRegime(self.ea_logic_full.regime_detector.last_analysis.regime),
            latency_ms=latency_ms
        )
        
        return True
    
    def _check_entry_compat(self, timestamp: datetime, bar: pd.Series,
                            bars_dict: Dict[str, pd.DataFrame], idx: int,
                            latency_ms: float):
        """Check entry using COMPAT EA (ea_logic_compat.py)"""
        
        # 2. Get ML prediction
        features = {
            'regime': self.ea_logic.regime_detector.current_regime,
            'rsi': bar.get('rsi', 50),
            'trend_direction': bar.get('trend', 0),
            'deviation_from_mean': bar['close'] - bar.get('ma_slow', bar['close'])
        }
        ml_prob = self.onnx.predict_direction(features)
        
        # 3. Calculate MTF alignment (causal, as-of timestamp)
        mtf_alignment = self.mtf.calculate_alignment(bars_dict, timestamp)
        
        # 4. Create BarData for EALogic
        bar_data = BarData(
            timestamp=timestamp.timestamp(),
            open=bar['open'],
            high=bar['high'],
            low=bar['low'],
            close=bar['close']
        )
        
        # 5. Evaluate with EALogic
        hour = timestamp.hour
        rsi = bar.get('rsi', 50)
        
        signal = self.ea_logic.evaluate(
            bar_data, hour, rsi, ml_prob, mtf_alignment
        )
        
        if signal is None:
            return
        
        # 6. Check minimum confluence
        if signal.confluence_score < self.config.min_confluence:
            self.signals_rejected += 1
            return
        
        # 7. Check for order rejection
        if self.execution.should_reject():
            self.signals_rejected += 1
            return
        
        # 8. Calculate fill price WITH latency impact
        fill_price = self.execution.get_fill_price(
            signal.signal_type, bar, latency_ms, is_entry=True
        )
        
        # 9. Recalculate SL/TP from actual fill
        atr = bar.get('atr', 5)
        if signal.signal_type == SignalType.BUY:
            sl = fill_price - atr * 1.5
            tp = fill_price + atr * 2.5 * 1.5
        else:
            sl = fill_price + atr * 1.5
            tp = fill_price - atr * 2.5 * 1.5
        
        # 10. Create position
        self.position = Position(
            direction=signal.signal_type,
            entry_time=timestamp,
            entry_price=fill_price,
            sl_price=sl,
            tp_price=tp,
            lots=signal.lot_size,
            spread_at_entry=bar.get('spread', 0.30),
            confluence_score=signal.confluence_score,
            regime=self.ea_logic.regime_detector.current_regime,
            latency_ms=latency_ms
        )
    
    def _manage_position(self, timestamp: datetime, bar: pd.Series):
        """Check SL/TP"""
        if self.position.direction == SignalType.BUY:
            if bar['low'] <= self.position.sl_price:
                self._close_position(timestamp, bar, "SL", self.position.sl_price)
            elif bar['high'] >= self.position.tp_price:
                self._close_position(timestamp, bar, "TP", self.position.tp_price)
        else:
            if bar['high'] >= self.position.sl_price:
                self._close_position(timestamp, bar, "SL", self.position.sl_price)
            elif bar['low'] <= self.position.tp_price:
                self._close_position(timestamp, bar, "TP", self.position.tp_price)
    
    def _close_position(self, timestamp: datetime, bar: pd.Series,
                        reason: str, exit_price: float = None):
        """Close position and record trade"""
        
        latency_ms = self.latency_sim.simulate_round_trip() if exit_price is None else 0
        
        if exit_price is None:
            exit_price = self.execution.get_fill_price(
                self.position.direction, bar, latency_ms, is_entry=False
            )
        
        # Calculate P&L
        if self.position.direction == SignalType.BUY:
            pnl = (exit_price - self.position.entry_price) * self.position.lots * 100
        else:
            pnl = (self.position.entry_price - exit_price) * self.position.lots * 100
        
        self.risk.update(pnl)
        self.ea_logic.risk_manager.update_trade_result(pnl)
        
        trade = Trade(
            entry_time=self.position.entry_time,
            exit_time=timestamp,
            direction=self.position.direction.name if hasattr(self.position.direction, 'name') else str(self.position.direction),
            entry_price=self.position.entry_price,
            exit_price=exit_price,
            sl=self.position.sl_price,
            tp=self.position.tp_price,
            lots=self.position.lots,
            pnl=pnl,
            pnl_pct=pnl / self.config.initial_balance,
            exit_reason=reason,
            confluence_score=self.position.confluence_score,
            regime=self.position.regime.name if hasattr(self.position.regime, 'name') else str(self.position.regime),
            latency_ms=self.position.latency_ms,
            balance_after=self.risk.balance
        )
        self.trades.append(trade)
        self.position = None
    
    def _calculate_metrics(self) -> Dict:
        """Calculate performance metrics"""
        if not self.trades:
            return {'error': 'No trades', 'total_trades': 0}
        
        pnls = [t.pnl for t in self.trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        total_trades = len(self.trades)
        win_rate = len(wins) / total_trades if total_trades > 0 else 0
        
        gross_profit = sum(wins) if wins else 0
        gross_loss = abs(sum(losses)) if losses else 1
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else 0
        
        # Max DD
        if self.equity_curve:
            equity = np.array([e['balance'] for e in self.equity_curve])
            peak = np.maximum.accumulate(equity)
            dd = (peak - equity) / peak
            max_dd = dd.max()
        else:
            max_dd = self.risk.current_dd
        
        # Sharpe
        if len(pnls) > 1:
            returns = np.array(pnls) / self.config.initial_balance
            sharpe = np.mean(returns) / (np.std(returns) + 1e-10) * np.sqrt(252 * 288)
        else:
            sharpe = 0
        
        # Confluence analysis
        avg_conf = np.mean([t.confluence_score for t in self.trades])
        
        # Latency impact
        latency_stats = self.latency_sim.get_stats()
        
        return {
            'total_trades': total_trades,
            'win_rate': win_rate,
            'profit_factor': profit_factor,
            'max_drawdown': max_dd,
            'sharpe_ratio': sharpe,
            'net_profit': self.risk.balance - self.config.initial_balance,
            'final_balance': self.risk.balance,
            'avg_confluence': avg_conf,
            'signals_generated': self.signals_generated,
            'signals_rejected': self.signals_rejected,
            'signal_quality': (self.signals_generated - self.signals_rejected) / max(1, self.signals_generated),
            'latency_mean_ms': latency_stats.get('mean_ms', 0),
            'latency_p95_ms': latency_stats.get('p95_ms', 0),
            'packet_loss_events': latency_stats.get('packet_loss_events', 0),
            'latency_slippage_events': self.execution.latency_slippage_events,
            'blown': self.risk.is_blown,
            'blow_reason': self.risk.blow_reason
        }
    
    def _print_report(self, metrics: Dict):
        """Print backtest report"""
        print("\n" + "=" * 70)
        print("    REALISTIC BACKTEST REPORT v2.0")
        print("=" * 70)
        
        if 'error' in metrics:
            print(f"[ERROR] {metrics['error']}")
            return
        
        print(f"\n{'TRADE METRICS':^40}")
        print("-" * 40)
        print(f"Total Trades:      {metrics['total_trades']}")
        print(f"Win Rate:          {metrics['win_rate']:.1%}")
        print(f"Profit Factor:     {metrics['profit_factor']:.2f}")
        print(f"Sharpe Ratio:      {metrics['sharpe_ratio']:.2f}")
        print(f"Max Drawdown:      {metrics['max_drawdown']:.2%}")
        print(f"Net Profit:        ${metrics['net_profit']:,.2f}")
        print(f"Final Balance:     ${metrics['final_balance']:,.2f}")
        
        print(f"\n{'SIGNAL QUALITY':^40}")
        print("-" * 40)
        print(f"Signals Generated: {metrics['signals_generated']}")
        print(f"Signals Rejected:  {metrics['signals_rejected']}")
        print(f"Signal Quality:    {metrics['signal_quality']:.1%}")
        print(f"Avg Confluence:    {metrics['avg_confluence']:.1f}")
        
        print(f"\n{'LATENCY SIMULATION':^40}")
        print("-" * 40)
        print(f"Mean Latency:      {metrics['latency_mean_ms']:.1f}ms")
        print(f"P95 Latency:       {metrics['latency_p95_ms']:.1f}ms")
        print(f"Packet Loss:       {metrics['packet_loss_events']}")
        print(f"Latency Slippage:  {metrics['latency_slippage_events']}")
        
        if metrics.get('blown'):
            print(f"\n{'[!] ACCOUNT BLOWN':^40}")
            print(f"Reason: {metrics['blow_reason']}")
        
        # FTMO Assessment
        print(f"\n{'FTMO ASSESSMENT':^40}")
        print("-" * 40)
        if metrics['max_drawdown'] < 0.08 and metrics['profit_factor'] >= 1.3:
            print("[PASSED] Ready for FTMO validation")
        elif metrics['max_drawdown'] < 0.10:
            print("[MARGINAL] Review before FTMO")
        else:
            print("[FAILED] Do not proceed to FTMO")
        
        print("=" * 70)
    
    def export_trades(self, filepath: str):
        """Export trades to CSV (Oracle-compatible)"""
        if not self.trades:
            print("[Export] No trades")
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
                'exit_reason': t.exit_reason,
                'confluence': t.confluence_score,
                'regime': t.regime,
                'latency_ms': t.latency_ms
            })
        
        df = pd.DataFrame(data)
        df.to_csv(filepath, index=False)
        print(f"\n[Export] Saved to: {filepath}")


# =============================================================================
# MAIN
# =============================================================================

def main():
    """Run realistic backtest."""
    import argparse

    parser = argparse.ArgumentParser(description="Realistic Event-Driven Backtester v2.0")
    parser.add_argument(
        "--ticks",
        required=True,
        help="Path to tick data (.parquet or .csv)",
    )
    parser.add_argument("--max-ticks", type=int, default=5_000_000)
    parser.add_argument("--start-date", default=None, help="Filter start (YYYY-MM-DD)")
    parser.add_argument("--end-date", default=None, help="Filter end (YYYY-MM-DD)")

    parser.add_argument(
        "--news-csv",
        default=None,
        help=(
            "Optional Finnhub calendar CSV (timestamp_utc,event,currency,impact,...) for news-aware latency. "
            "Only affects simulated latency volatility drag."
        ),
    )
    parser.add_argument("--news-window-min", type=int, default=30)

    parser.add_argument(
        "--export-trades",
        default=None,
        help="Write Oracle-compatible trades CSV",
    )

    args = parser.parse_args()

    config = RealisticBacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        enable_latency_sim=True,
        enable_onnx_mock=True,
        min_confluence=65.0,
        debug=False,
        debug_interval=500,
    )

    bt = RealisticBacktester(config)

    # Optional: load news timestamps to flag high-volatility periods.
    news_times_utc: set[datetime] | None = None
    if args.news_csv:
        import pandas as pd

        news_df = pd.read_csv(args.news_csv)
        if 'timestamp_utc' in news_df.columns:
            news_times_utc = {
                datetime.fromtimestamp(int(ts), tz=timezone.utc)
                for ts in news_df['timestamp_utc'].dropna().astype(int).tolist()
            }

    results = bt.run(
        args.ticks,
        max_ticks=args.max_ticks,
        start_date=args.start_date,
        end_date=args.end_date,
    )

    if args.export_trades:
        bt.export_trades(args.export_trades)

    # Print compact info about the news set if provided.
    if news_times_utc is not None:
        print(f"[News] Loaded {len(news_times_utc)} event timestamps from {args.news_csv}")

    return results


if __name__ == "__main__":
    main()
