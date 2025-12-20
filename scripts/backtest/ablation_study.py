#!/usr/bin/env python3
"""
SMC Ablation Study - Filter Impact Analysis
============================================
Tests each filter's contribution to the SMC strategy.

Configurations:
1. BASELINE: SMC strategy pure (OB + FVG + Liquidity)
2. +REGIME: Baseline + Hurst regime filter
3. +SESSION: Baseline + London/NY overlap filter
4. +MTF: Baseline + M5/H1 alignment
5. +CONFLUENCE: Baseline + confluence score >= 70
6. ALL_FILTERS: All filters combined

Author: ORACLE + FORGE
Date: 2025-12-01
"""

import numpy as np
import pandas as pd
import pyarrow.parquet as pq
import pyarrow as pa
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from datetime import datetime, time
from enum import Enum
import warnings
warnings.filterwarnings('ignore')

# Ensure project root on path for imports when run as script
import sys, pathlib
ROOT = pathlib.Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

# Optional EA parity backtester (TickBacktester)
try:
    from scripts.backtest.tick_backtester import BacktestConfig, TickBacktester, ExecutionMode
    HAVE_EA_PARITY = True
except Exception:
    HAVE_EA_PARITY = False

# Footprint Analyzer
try:
    from scripts.backtest.footprint_analyzer import FootprintAnalyzer, FootprintConfig, load_and_analyze_ticks
    HAVE_FOOTPRINT = True
except Exception as e:
    print(f"[Warning] Footprint analyzer not available: {e}")
    HAVE_FOOTPRINT = False


# =============================================================================
# CONFIGURATION
# =============================================================================

@dataclass
class AblationConfig:
    """Configuration for ablation study"""
    # Capital
    initial_balance: float = 100_000.0
    risk_per_trade: float = 0.005  # 0.5%
    
    # FTMO Limits
    max_daily_dd: float = 0.05  # 5%
    max_total_dd: float = 0.10  # 10%
    
    # Execution
    spread_points: float = 0.45  # Avg XAUUSD spread
    slippage_points: float = 0.05
    
    # Strategy parameters
    ob_displacement_mult: float = 2.0
    fvg_min_gap: float = 0.3
    sl_atr_mult: float = 2.0
    tp_atr_mult: float = 3.0
    
    # Filters (toggleable)
    use_regime_filter: bool = False
    hurst_threshold: float = 0.55  # > 0.55 = trending
    
    use_session_filter: bool = False
    session_start_utc: int = 8   # London open
    session_end_utc: int = 17    # NY close
    
    use_mtf_filter: bool = False
    htf_ma_period: int = 50
    
    use_confluence_filter: bool = False
    min_confluence_score: int = 70
    
    # Footprint filter (NEW)
    use_footprint_filter: bool = False
    min_footprint_score: int = 55   # Bullish if > 55, Bearish if < 45
    
    # Timeframes
    ltf: str = '5min'   # M5 for entries
    htf: str = '1h'     # H1 for bias


class MarketBias(Enum):
    BULLISH = 1
    BEARISH = -1
    NEUTRAL = 0


# =============================================================================
# DATA LOADING
# =============================================================================

def load_parquet_ticks(filepath: str, max_rows: int = None) -> pd.DataFrame:
    """Load tick data from Parquet file (tail only if max_rows set, row-group aware)."""
    print(f"[DataLoader] Loading {filepath}...")

    if max_rows is None:
        table = pq.read_table(filepath)
    else:
        pf = pq.ParquetFile(filepath)
        tables = []
        rows = 0
        for rg in reversed(range(pf.num_row_groups)):
            t = pf.read_row_group(rg)
            tables.append(t)
            rows += t.num_rows
            if rows >= max_rows:
                break
        tables.reverse()
        table = pa.concat_tables(tables)
        if table.num_rows > max_rows:
            start = table.num_rows - max_rows
            table = table.slice(start, max_rows)

    df = table.to_pandas()

    # Ensure timestamp is datetime
    if 'timestamp' in df.columns and not pd.api.types.is_datetime64_any_dtype(df['timestamp']):
        df['timestamp'] = pd.to_datetime(df['timestamp'])
    elif 'datetime' in df.columns and not pd.api.types.is_datetime64_any_dtype(df['datetime']):
        df['timestamp'] = pd.to_datetime(df['datetime'])

    if 'timestamp' in df.columns:
        df.set_index('timestamp', inplace=True)
    else:
        df.index = pd.to_datetime(df.index)

    df.sort_index(inplace=True)

    print(f"[DataLoader] Loaded {len(df):,} ticks")
    print(f"[DataLoader] Period: {df.index[0]} to {df.index[-1]}")

    return df


def resample_to_ohlc(ticks: pd.DataFrame, timeframe: str) -> pd.DataFrame:
    """Resample ticks to OHLC bars"""
    ohlc = ticks['mid_price'].resample(timeframe).ohlc()
    ohlc.columns = ['open', 'high', 'low', 'close']
    ohlc['volume'] = ticks['volume'].resample(timeframe).sum()
    ohlc['spread'] = ticks['spread'].resample(timeframe).mean()
    ohlc['tick_count'] = ticks['mid_price'].resample(timeframe).count()
    return ohlc.dropna()


# =============================================================================
# INDICATORS
# =============================================================================

def add_indicators(df: pd.DataFrame, config: AblationConfig) -> pd.DataFrame:
    """Add all required indicators"""
    # ATR
    df['tr'] = np.maximum(
        df['high'] - df['low'],
        np.maximum(
            abs(df['high'] - df['close'].shift(1)),
            abs(df['low'] - df['close'].shift(1))
        )
    )
    df['atr'] = df['tr'].rolling(14).mean()
    
    # Moving averages
    df['ma20'] = df['close'].rolling(20).mean()
    df['ma50'] = df['close'].rolling(50).mean()
    df['ma200'] = df['close'].rolling(200).mean()
    
    # Session (UTC based)
    df['hour'] = df.index.hour
    
    return df


def calculate_hurst(series: pd.Series, window: int = 100) -> pd.Series:
    """Calculate rolling Hurst exponent for regime detection"""
    def hurst_rs(ts):
        if len(ts) < 20:
            return 0.5
        try:
            lags = range(2, min(20, len(ts) // 2))
            tau = [np.std(np.subtract(ts[lag:], ts[:-lag])) for lag in lags]
            if any(t == 0 for t in tau):
                return 0.5
            reg = np.polyfit(np.log(list(lags)), np.log(tau), 1)
            return reg[0]
        except:
            return 0.5
    
    return series.rolling(window).apply(hurst_rs, raw=True)


# =============================================================================
# SMC COMPONENTS
# =============================================================================

@dataclass
class OrderBlock:
    idx: int
    time: datetime
    ob_type: str  # 'BULL' or 'BEAR'
    top: float
    bottom: float
    strength: float
    confirm_idx: int
    used: bool = False


@dataclass
class FVG:
    idx: int
    time: datetime
    fvg_type: str  # 'BULL' or 'BEAR'
    top: float
    bottom: float
    filled: bool = False


def detect_order_blocks(df: pd.DataFrame, displacement_mult: float = 2.0) -> List[OrderBlock]:
    """Detect Order Blocks (WP3 causal: confirmation lag enforced)."""
    obs: List[OrderBlock] = []
    atr = df['atr'].values

    # Confirmation uses up to the next 3 candles; a block at i becomes usable only at (i + 3).
    confirm_lag = 3

    for i in range(5, len(df) - confirm_lag):
        if pd.isna(atr[i]) or atr[i] <= 0:
            continue

        o, h, l, c = df['open'].iloc[i], df['high'].iloc[i], df['low'].iloc[i], df['close'].iloc[i]
        confirm_idx = i + confirm_lag

        # Bullish OB: bearish candle before bullish displacement
        if c < o:  # bearish candle
            disp = df['high'].iloc[i + 1:confirm_idx + 1].max() - c
            if disp >= atr[i] * displacement_mult:
                obs.append(OrderBlock(i, df.index[i], 'BULL', o, l, disp / atr[i], confirm_idx))

        # Bearish OB: bullish candle before bearish displacement
        if c > o:  # bullish candle
            disp = c - df['low'].iloc[i + 1:confirm_idx + 1].min()
            if disp >= atr[i] * displacement_mult:
                obs.append(OrderBlock(i, df.index[i], 'BEAR', h, o, disp / atr[i], confirm_idx))

    return obs


def detect_fvgs(df: pd.DataFrame, min_gap: float = 0.3) -> List[FVG]:
    """Detect Fair Value Gaps (WP3 causal: confirm at third candle)."""
    fvgs: List[FVG] = []

    for i in range(2, len(df)):
        # Bullish FVG: gap up (candle 1 high < candle 3 low)
        c1_high = df['high'].iloc[i - 2]
        c3_low = df['low'].iloc[i]

        if c3_low > c1_high:
            gap = c3_low - c1_high
            if gap >= min_gap:
                # Confirmed at candle 3 (index i), not at i-1.
                fvgs.append(FVG(i, df.index[i], 'BULL', c3_low, c1_high))

        # Bearish FVG: gap down (candle 1 low > candle 3 high)
        c1_low = df['low'].iloc[i - 2]
        c3_high = df['high'].iloc[i]

        if c1_low > c3_high:
            gap = c1_low - c3_high
            if gap >= min_gap:
                fvgs.append(FVG(i, df.index[i], 'BEAR', c1_low, c3_high))

    return fvgs


def calculate_confluence(row: pd.Series, direction: str, in_ob: bool, in_fvg: bool,
                        sweep: bool, in_discount: bool) -> int:
    """Calculate confluence score (0-100)"""
    score = 0
    
    if direction == 'BUY':
        # Structure alignment (MA trend)
        if row.get('close', 0) > row.get('ma200', 0):
            score += 20
        if row.get('ma20', 0) > row.get('ma50', 0):
            score += 15
        
        # In bullish OB
        if in_ob:
            score += 20
        
        # In bullish FVG
        if in_fvg:
            score += 15
        
        # SSL sweep (liquidity taken)
        if sweep:
            score += 15
        
        # In discount zone
        if in_discount:
            score += 15
    
    else:  # SELL
        # Structure alignment
        if row.get('close', 0) < row.get('ma200', 0):
            score += 20
        if row.get('ma20', 0) < row.get('ma50', 0):
            score += 15
        
        if in_ob:
            score += 20
        if in_fvg:
            score += 15
        if sweep:
            score += 15
        if not in_discount:  # in premium
            score += 15
    
    return min(100, score)


# =============================================================================
# BACKTESTER
# =============================================================================

class SMCAblationBacktester:
    """Backtester for ablation study"""
    
    def __init__(self, config: AblationConfig):
        self.config = config
        self.trades = []
        self.equity_curve = []
    
    def run(self, ltf_bars: pd.DataFrame, htf_bars: pd.DataFrame = None, 
            fp_df: pd.DataFrame = None) -> Dict:
        """Run backtest with current configuration
        
        Args:
            ltf_bars: M5 OHLC bars
            htf_bars: H1 OHLC bars (optional)
            fp_df: Footprint metrics DataFrame (optional)
        """
        cfg = self.config
        balance = cfg.initial_balance
        peak = balance
        daily_start = balance
        current_date = None
        position = None
        self.trades = []
        self.equity_curve = []
        
        # Merge footprint data if available
        if fp_df is not None and cfg.use_footprint_filter:
            # WP3: Footprint bars are grouped by bar start (floor). Metrics are only known once the bar closes.
            # Align footprint timestamps to bar close time so we never use future ticks.
            fp_aligned = fp_df.copy()
            fp_aligned.index = pd.to_datetime(fp_aligned.index)
            try:
                fp_tf = pd.Timedelta(cfg.ltf)
            except Exception:
                fp_tf = pd.Timedelta('5min')
            fp_aligned.index = fp_aligned.index + fp_tf

            ltf_bars = ltf_bars.merge(
                fp_aligned[['fp_score', 'delta', 'stacked_imbal', 'absorption']],
                left_index=True, right_index=True, how='left'
            )
            ltf_bars['fp_score'] = ltf_bars['fp_score'].fillna(50)  # Neutral default
        else:
            ltf_bars['fp_score'] = 50  # Neutral if no footprint
        
        # Detect SMC components
        obs = detect_order_blocks(ltf_bars, cfg.ob_displacement_mult)
        fvgs = detect_fvgs(ltf_bars, cfg.fvg_min_gap)
        
        # Calculate regime if needed
        if cfg.use_regime_filter:
            ltf_bars['hurst'] = calculate_hurst(ltf_bars['close'], 100)
            ltf_bars['is_trending'] = ltf_bars['hurst'] > cfg.hurst_threshold
        else:
            ltf_bars['is_trending'] = True
        
        # HTF bias
        if cfg.use_mtf_filter and htf_bars is not None:
            htf_bars['ma_htf'] = htf_bars['close'].rolling(cfg.htf_ma_period).mean()
            htf_bias = htf_bars['close'] > htf_bars['ma_htf']

            # WP3: Pandas resample labels bars by period start. HTF bias should only be usable after the HTF bar closes.
            # Make the bias available at (bar_start + HTF_tf) by shifting the index forward.
            htf_bias_available = htf_bias.copy()
            htf_bias_available.index = pd.to_datetime(htf_bias_available.index) + pd.Timedelta(cfg.htf)

            ltf_bars['htf_bullish'] = htf_bias_available.reindex(ltf_bars.index, method='ffill')
        else:
            ltf_bars['htf_bullish'] = True
        
        # Premium/Discount zones
        lookback = 50
        ltf_bars['range_high'] = ltf_bars['high'].rolling(lookback).max()
        ltf_bars['range_low'] = ltf_bars['low'].rolling(lookback).min()
        ltf_bars['equilibrium'] = (ltf_bars['range_high'] + ltf_bars['range_low']) / 2
        ltf_bars['in_discount'] = ltf_bars['close'] < ltf_bars['equilibrium']
        
        used_obs = set()
        
        for i, (idx, row) in enumerate(ltf_bars.iterrows()):
            if i < 200:
                continue
            
            # Daily reset
            bar_date = idx.date()
            if current_date != bar_date:
                current_date = bar_date
                daily_start = balance
            
            # Check FTMO limits
            daily_dd = (daily_start - balance) / cfg.initial_balance
            total_dd = (peak - balance) / peak if peak > 0 else 0
            
            if daily_dd >= cfg.max_daily_dd or total_dd >= cfg.max_total_dd:
                if position:
                    pnl = self._close_position(position, row)
                    balance += pnl
                    self.trades.append({'pnl': pnl, 'reason': 'DD_LIMIT', 'time': idx})
                break
            
            # Manage existing position
            if position:
                result = self._check_exit(position, row)
                if result:
                    balance += result['pnl']
                    result['time'] = idx
                    self.trades.append(result)
                    if balance > peak:
                        peak = balance
                    position = None
            
            # Check for new entry
            if position is None:
                atr = row['atr']
                if pd.isna(atr) or atr <= 0:
                    continue
                
                # Apply filters
                if cfg.use_regime_filter and not row.get('is_trending', True):
                    continue
                
                if cfg.use_session_filter:
                    hour = row['hour']
                    if not (cfg.session_start_utc <= hour < cfg.session_end_utc):
                        continue
                
                # Check OBs for entry
                for ob in obs:
                    # WP3: OB is only usable after its confirmation lag.
                    if ob.idx in used_obs or i < ob.confirm_idx:
                        continue
                    
                    # Bullish OB entry
                    if ob.ob_type == 'BULL':
                        if row['low'] <= ob.top and row['close'] >= ob.bottom:
                            # MTF filter
                            if cfg.use_mtf_filter and not row.get('htf_bullish', True):
                                continue
                            
                            # Footprint filter (NEW)
                            if cfg.use_footprint_filter:
                                fp_score = row.get('fp_score', 50)
                                # For BUY: require bullish footprint (score > threshold)
                                if fp_score < cfg.min_footprint_score:
                                    continue
                            
                            # Check if in FVG
                            in_fvg = any(f.fvg_type == 'BULL' and 
                                        row['low'] <= f.top and row['high'] >= f.bottom
                                        for f in fvgs if f.idx < i)
                            
                            # Confluence filter
                            if cfg.use_confluence_filter:
                                score = calculate_confluence(
                                    row, 'BUY', True, in_fvg, False, row.get('in_discount', True))
                                if score < cfg.min_confluence_score:
                                    continue
                            
                            used_obs.add(ob.idx)
                            entry = row['close'] + cfg.spread_points/2 + cfg.slippage_points
                            sl = entry - atr * cfg.sl_atr_mult
                            tp = entry + atr * cfg.tp_atr_mult
                            
                            sl_dist = entry - sl
                            risk_amount = cfg.initial_balance * cfg.risk_per_trade
                            lots = risk_amount / (sl_dist * 100) if sl_dist > 0 else 0.01
                            lots = max(0.01, min(lots, 10.0))
                            
                            position = {
                                'dir': 'BUY', 'entry': entry, 'sl': sl, 'tp': tp,
                                'lots': lots, 'entry_time': idx, 'session': row['hour']
                            }
                            break
                    
                    # Bearish OB entry
                    elif ob.ob_type == 'BEAR':
                        if row['high'] >= ob.bottom and row['close'] <= ob.top:
                            if cfg.use_mtf_filter and row.get('htf_bullish', False):
                                continue
                            
                            # Footprint filter (NEW)
                            if cfg.use_footprint_filter:
                                fp_score = row.get('fp_score', 50)
                                # For SELL: require bearish footprint (score < threshold)
                                if fp_score > (100 - cfg.min_footprint_score):
                                    continue
                            
                            in_fvg = any(f.fvg_type == 'BEAR' and
                                        row['high'] >= f.bottom and row['low'] <= f.top
                                        for f in fvgs if f.idx < i)
                            
                            if cfg.use_confluence_filter:
                                score = calculate_confluence(
                                    row, 'SELL', True, in_fvg, False, row.get('in_discount', True))
                                if score < cfg.min_confluence_score:
                                    continue
                            
                            used_obs.add(ob.idx)
                            entry = row['close'] - cfg.spread_points/2 - cfg.slippage_points
                            sl = entry + atr * cfg.sl_atr_mult
                            tp = entry - atr * cfg.tp_atr_mult
                            
                            sl_dist = sl - entry
                            risk_amount = cfg.initial_balance * cfg.risk_per_trade
                            lots = risk_amount / (sl_dist * 100) if sl_dist > 0 else 0.01
                            lots = max(0.01, min(lots, 10.0))
                            
                            position = {
                                'dir': 'SELL', 'entry': entry, 'sl': sl, 'tp': tp,
                                'lots': lots, 'entry_time': idx, 'session': row['hour']
                            }
                            break
            
            # Record equity
            self.equity_curve.append({'time': idx, 'balance': balance, 'dd': (peak - balance) / peak})
        
        # Close remaining position
        if position:
            pnl = self._close_position(position, ltf_bars.iloc[-1])
            balance += pnl
            self.trades.append({'pnl': pnl, 'reason': 'END', 'time': ltf_bars.index[-1]})
        
        return self._calculate_metrics(balance, peak, len(obs))
    
    def _check_exit(self, pos: Dict, row: pd.Series) -> Optional[Dict]:
        """Check SL/TP exit"""
        if pos['dir'] == 'BUY':
            if row['low'] <= pos['sl']:
                pnl = (pos['sl'] - pos['entry']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'SL', 'duration': None}
            if row['high'] >= pos['tp']:
                pnl = (pos['tp'] - pos['entry']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'TP', 'duration': None}
        else:
            if row['high'] >= pos['sl']:
                pnl = (pos['entry'] - pos['sl']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'SL', 'duration': None}
            if row['low'] <= pos['tp']:
                pnl = (pos['entry'] - pos['tp']) * pos['lots'] * 100
                return {'pnl': pnl, 'reason': 'TP', 'duration': None}
        return None
    
    def _close_position(self, pos: Dict, row: pd.Series) -> float:
        """Close position at current price"""
        if pos['dir'] == 'BUY':
            exit_p = row['close'] - self.config.spread_points/2
            return (exit_p - pos['entry']) * pos['lots'] * 100
        else:
            exit_p = row['close'] + self.config.spread_points/2
            return (pos['entry'] - exit_p) * pos['lots'] * 100
    
    def _calculate_metrics(self, final_balance: float, peak: float, total_obs: int) -> Dict:
        """Calculate performance metrics"""
        if not self.trades:
            return {'error': 'No trades', 'total_trades': 0}
        
        pnls = [t['pnl'] for t in self.trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]
        
        n = len(self.trades)
        win_rate = len(wins) / n if n > 0 else 0
        
        gross_profit = sum(wins) if wins else 0
        gross_loss = abs(sum(losses)) if losses else 1
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else 0
        
        # Drawdown
        equity = [self.config.initial_balance]
        for p in pnls:
            equity.append(equity[-1] + p)
        eq = np.array(equity)
        running_max = np.maximum.accumulate(eq)
        drawdowns = running_max - eq
        max_dd = drawdowns.max()
        max_dd_pct = max_dd / self.config.initial_balance
        
        # Sharpe
        if len(pnls) > 1 and np.std(pnls) > 0:
            returns = np.array(pnls) / self.config.initial_balance
            sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252 * 288)  # Annualized
        else:
            sharpe = 0
        
        # Exit reasons
        reasons = {}
        for t in self.trades:
            r = t['reason']
            reasons[r] = reasons.get(r, 0) + 1
        
        # Session breakdown
        sessions = {'asian': 0, 'london': 0, 'ny': 0, 'other': 0}
        for t in self.trades:
            h = t.get('session', 12) if 'session' in t else 12
            # Simplified session detection
            if 0 <= h < 8:
                sessions['asian'] += 1
            elif 8 <= h < 13:
                sessions['london'] += 1
            elif 13 <= h < 20:
                sessions['ny'] += 1
            else:
                sessions['other'] += 1
        
        return {
            'total_trades': n,
            'win_rate': win_rate,
            'profit_factor': profit_factor,
            'sharpe_ratio': sharpe,
            'max_drawdown_pct': max_dd_pct,
            'max_drawdown': max_dd,
            'total_return': (final_balance - self.config.initial_balance) / self.config.initial_balance,
            'net_profit': final_balance - self.config.initial_balance,
            'final_balance': final_balance,
            'avg_win': np.mean(wins) if wins else 0,
            'avg_loss': np.mean(losses) if losses else 0,
            'exit_reasons': reasons,
            'sessions': sessions,
            'total_obs': total_obs
        }

# =============================================================================
# EA PARITY BACKTEST (using TickBacktester)
# =============================================================================

def run_ea_parity_backtest(tick_path: str, max_ticks: int = None) -> Dict:
    """Run a quick EA-parity backtest using TickBacktester."""
    if not HAVE_EA_PARITY:
        return {'error': 'EA parity not available'}
    
    cfg = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        use_ea_logic=True,
        bar_timeframe='5min',
        eval_window_bars=400,
        fp_score=60.0,
        ml_prob=None,
    )
    bt = TickBacktester(cfg)
    results = bt.run(tick_path, max_ticks=max_ticks or 2_000_000)
    metrics = results.get('metrics', {})
    # Normalize field names to match ablation table keys
    if 'max_drawdown' in metrics:
        metrics['max_drawdown_pct'] = metrics['max_drawdown']
    if 'total_return' not in metrics and 'final_balance' in metrics:
        metrics['total_return'] = (metrics['final_balance'] - cfg.initial_balance) / cfg.initial_balance if hasattr(cfg, 'initial_balance') else 0
    return metrics


# =============================================================================
# ABLATION STUDY RUNNER
# =============================================================================

def run_ablation_study(data_path: str, output_path: str = None, use_ea_logic: bool = False, max_ticks: int = None, ea_only: bool = False):
    """Run complete ablation study.
    
    If use_ea_logic is True and TickBacktester is available, also run a parity backtest
    using the EA logic on tick data (5min). This produces a separate metrics block.
    """
    # Fast path: EA-only parity run (skip SMC pipeline and heavy parquet load)
    if ea_only and use_ea_logic and HAVE_EA_PARITY:
        print("[EA PARITY] EA-only mode enabled; skipping SMC loops.")
        ea_metrics = run_ea_parity_backtest(data_path, max_ticks=max_ticks)
        return [{'name': 'EA_PARITY', **ea_metrics, 'delta_sharpe': 0}]

    print("=" * 80)
    print("              SMC ABLATION STUDY - FILTER IMPACT ANALYSIS")
    print("=" * 80)
    
    # Load data
    print("\n[1/7] Loading tick data...")
    ticks = load_parquet_ticks(data_path, max_rows=max_ticks)
    
    # Resample to bars
    print("\n[2/7] Resampling to M5 and H1 bars...")
    ltf_bars = resample_to_ohlc(ticks, '5min')
    htf_bars = resample_to_ohlc(ticks, '1h')
    print(f"  M5 bars: {len(ltf_bars):,}")
    print(f"  H1 bars: {len(htf_bars):,}")
    
    # Add indicators
    print("\n[3/7] Calculating indicators...")
    ltf_bars = add_indicators(ltf_bars, AblationConfig())
    htf_bars = add_indicators(htf_bars, AblationConfig())
    
    # Generate footprint data if available
    fp_df = None
    if HAVE_FOOTPRINT:
        print("\n[3.5/7] Generating footprint metrics from ticks...")
        try:
            fp_config = FootprintConfig(
                tick_size=0.01,
                imbalance_ratio=3.0,
                stacked_min_levels=3,
                bar_timeframe='5min'
            )
            analyzer = FootprintAnalyzer(fp_config)
            fp_df = analyzer.analyze_ticks(ticks)
            print(f"  Footprint bars: {len(fp_df):,}")
        except Exception as e:
            print(f"  [Warning] Footprint generation failed: {e}")
            fp_df = None
    
    # Define configurations
    configs = [
        {
            'name': 'BASELINE',
            'desc': 'SMC pure (OB + FVG)',
            'use_regime_filter': False,
            'use_session_filter': False,
            'use_mtf_filter': False,
            'use_confluence_filter': False,
            'use_footprint_filter': False,
        },
        {
            'name': '+REGIME',
            'desc': 'Baseline + Hurst regime filter',
            'use_regime_filter': True,
            'use_session_filter': False,
            'use_mtf_filter': False,
            'use_confluence_filter': False,
            'use_footprint_filter': False,
        },
        {
            'name': '+SESSION',
            'desc': 'Baseline + London/NY session filter',
            'use_regime_filter': False,
            'use_session_filter': True,
            'use_mtf_filter': False,
            'use_confluence_filter': False,
            'use_footprint_filter': False,
        },
        {
            'name': '+MTF',
            'desc': 'Baseline + M5/H1 alignment',
            'use_regime_filter': False,
            'use_session_filter': False,
            'use_mtf_filter': True,
            'use_confluence_filter': False,
            'use_footprint_filter': False,
        },
        {
            'name': '+CONFLUENCE',
            'desc': 'Baseline + confluence >= 70',
            'use_regime_filter': False,
            'use_session_filter': False,
            'use_mtf_filter': False,
            'use_confluence_filter': True,
            'use_footprint_filter': False,
        },
        {
            'name': '+FOOTPRINT',
            'desc': 'Baseline + footprint order flow filter',
            'use_regime_filter': False,
            'use_session_filter': False,
            'use_mtf_filter': False,
            'use_confluence_filter': False,
            'use_footprint_filter': True,
        },
        {
            'name': 'ALL_FILTERS',
            'desc': 'All filters combined',
            'use_regime_filter': True,
            'use_session_filter': True,
            'use_mtf_filter': True,
            'use_confluence_filter': True,
            'use_footprint_filter': True,
        },
    ]
    
    results = []
    baseline_sharpe = None

    if not ea_only:
        # Run original SMC configs
        print("\n[4/7] Running backtest configurations...")
        for i, cfg_dict in enumerate(configs):
            print(f"\n  [{i+1}/6] Testing {cfg_dict['name']}: {cfg_dict['desc']}")
            
            config = AblationConfig(
                use_regime_filter=cfg_dict.get('use_regime_filter', False),
                use_session_filter=cfg_dict.get('use_session_filter', False),
                use_mtf_filter=cfg_dict.get('use_mtf_filter', False),
                use_confluence_filter=cfg_dict.get('use_confluence_filter', False),
                use_footprint_filter=cfg_dict.get('use_footprint_filter', False),
            )
            
            bt = SMCAblationBacktester(config)
            metrics = bt.run(ltf_bars.copy(), htf_bars.copy(), fp_df=fp_df)
            
            metrics['name'] = cfg_dict['name']
            metrics['desc'] = cfg_dict['desc']
            
            if cfg_dict['name'] == 'BASELINE':
                baseline_sharpe = metrics.get('sharpe_ratio', 0)
            
            # Calculate delta vs baseline
            if baseline_sharpe and baseline_sharpe != 0:
                metrics['delta_sharpe'] = (metrics.get('sharpe_ratio', 0) - baseline_sharpe) / abs(baseline_sharpe) * 100
            else:
                metrics['delta_sharpe'] = 0
            
            results.append(metrics)
            
            if 'error' not in metrics:
                print(f"      Trades: {metrics['total_trades']}, WR: {metrics['win_rate']:.1%}, "
                      f"PF: {metrics['profit_factor']:.2f}, Sharpe: {metrics['sharpe_ratio']:.2f}, "
                      f"MaxDD: {metrics['max_drawdown_pct']:.2%}")
    
    if results:
        print("\n" + "=" * 100)
        print("                              ABLATION STUDY RESULTS")
        print("=" * 100)
        print(f"{'Config':<15} {'Trades':>8} {'WR%':>8} {'PF':>8} {'Sharpe':>8} {'MaxDD%':>8} {'Return%':>10} {'Delta%':>10}")
        print("-" * 100)
        
        for r in results:
            if 'error' in r:
                print(f"{r['name']:<15} {'ERROR':>8} {'-':>8} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {'-':>10}")
            else:
                delta_str = f"{r.get('delta_sharpe',0):+.1f}" if r['name'] != 'BASELINE' else "0 (base)"
                maxddpct = r.get('max_drawdown_pct', 0)
                print(f"{r['name']:<15} {r['total_trades']:>8} {r['win_rate']*100:>7.1f}% "
                      f"{r['profit_factor']:>8.2f} {r['sharpe_ratio']:>8.2f} "
                      f"{maxddpct*100:>7.2f}% {r['total_return']*100:>9.2f}% {delta_str:>10}")
        
        print("=" * 100)
    
    # Ranking
    print("\n[5/7] FILTER RANKING (by Sharpe improvement vs baseline):")
    ranked = sorted([r for r in results if 'error' not in r and r['name'] != 'BASELINE'],
                   key=lambda x: x['sharpe_ratio'], reverse=True)
    
    for i, r in enumerate(ranked, 1):
        delta = r['delta_sharpe']
        impact = "POSITIVE" if delta > 5 else "NEGATIVE" if delta < -5 else "NEUTRAL"
        print(f"  {i}. {r['name']:<15} Sharpe: {r['sharpe_ratio']:.2f} ({delta:+.1f}% vs baseline) [{impact}]")
    
    # Recommendations
    print("\n[6/7] RECOMMENDATIONS:")
    
    baseline = next((r for r in results if r['name'] == 'BASELINE'), None)
    all_filters = next((r for r in results if r['name'] == 'ALL_FILTERS'), None)
    
    if baseline and all_filters and 'error' not in baseline and 'error' not in all_filters:
        if all_filters['sharpe_ratio'] > baseline['sharpe_ratio'] * 1.1:
            print("  [OK] ALL_FILTERS improves Sharpe by >10% - Use combined filters")
        elif all_filters['sharpe_ratio'] > baseline['sharpe_ratio']:
            print("  [OK] ALL_FILTERS slightly improves performance - Consider using")
        else:
            print("  [WARN] ALL_FILTERS doesn't improve over baseline - Review filters")
    
    # Identify best single filter
    single_filters = [r for r in results if r['name'].startswith('+') and 'error' not in r]
    if single_filters:
        best_single = max(single_filters, key=lambda x: x['sharpe_ratio'])
        print(f"  [INFO] Best single filter: {best_single['name']} (Sharpe: {best_single['sharpe_ratio']:.2f})")
    
    # Filters to keep/discard
    keep = [r['name'] for r in single_filters if r['delta_sharpe'] > 0]
    discard = [r['name'] for r in single_filters if r['delta_sharpe'] < -5]
    
    if keep:
        print(f"  [KEEP] Filters that add value: {', '.join(keep)}")
    if discard:
        print(f"  [DISCARD] Filters that hurt: {', '.join(discard)}")
    
    # Generate report
    print("\n[7/7] Generating report...")
    report = generate_report(results, baseline, all_filters)
    
    if output_path is None:
        output_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/DOCS/04_REPORTS/BACKTESTS/ABLATION_STUDY.md"
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"  Report saved to: {output_path}")
    print("\n" + "=" * 80)
    print("                         ABLATION STUDY COMPLETE")
    print("=" * 80)

    # Optional EA parity run (TickBacktester with EA logic)
    if use_ea_logic:
        if HAVE_EA_PARITY:
            print("\n[EA PARITY] Running TickBacktester (EA logic)...")
            ea_metrics = run_ea_parity_backtest(data_path, max_ticks=max_ticks)
            print("[EA PARITY] Metrics:", ea_metrics)
            results.append({'name': 'EA_PARITY', **ea_metrics, 'delta_sharpe': 0})
        else:
            print("[EA PARITY] TickBacktester not available in this environment.")
    
    return results


def generate_report(results: List[Dict], baseline: Dict, all_filters: Dict) -> str:
    """Generate Markdown report"""
    now = datetime.now().strftime('%Y-%m-%d %H:%M')
    
    report = f"""# SMC Ablation Study - Filter Impact Analysis

**Generated:** {now}
**Data:** ticks_2024.parquet
**Strategy:** SMC (Order Blocks + FVG + Liquidity Sweeps)

---

## Executive Summary

This ablation study tests the individual contribution of each filter to the SMC trading strategy.

## Results Table

| Config | Trades | WR% | PF | Sharpe | MaxDD% | Return% | Delta vs Baseline |
|--------|--------|-----|----|----|------|---------|-------------------|
"""
    
    for r in results:
        if 'error' in r:
            report += f"| {r['name']} | ERROR | - | - | - | - | - | - |\n"
        else:
            delta = f"{r['delta_sharpe']:+.1f}%" if r['name'] != 'BASELINE' else "0 (base)"
            report += f"| {r['name']} | {r['total_trades']} | {r['win_rate']*100:.1f}% | {r['profit_factor']:.2f} | {r['sharpe_ratio']:.2f} | {r['max_drawdown_pct']*100:.2f}% | {r['total_return']*100:.2f}% | {delta} |\n"
    
    report += """
## Filter Ranking (by Sharpe improvement)

"""
    ranked = sorted([r for r in results if 'error' not in r and r['name'] != 'BASELINE'],
                   key=lambda x: x['sharpe_ratio'], reverse=True)
    
    for i, r in enumerate(ranked, 1):
        delta = r['delta_sharpe']
        impact = "POSITIVE" if delta > 5 else "NEGATIVE" if delta < -5 else "NEUTRAL"
        report += f"{i}. **{r['name']}** - Sharpe: {r['sharpe_ratio']:.2f} ({delta:+.1f}% vs baseline) - {impact}\n"
    
    report += """
## Recommendations

"""
    
    if baseline and all_filters and 'error' not in baseline and 'error' not in all_filters:
        if all_filters['sharpe_ratio'] > baseline['sharpe_ratio'] * 1.1:
            report += "- **ALL_FILTERS** significantly improves performance (>10% Sharpe improvement)\n"
            report += "- **Recommendation:** Use all filters in production\n"
        elif all_filters['sharpe_ratio'] > baseline['sharpe_ratio']:
            report += "- **ALL_FILTERS** shows marginal improvement\n"
            report += "- **Recommendation:** Consider using selective filters\n"
        else:
            report += "- **ALL_FILTERS** does NOT improve over baseline\n"
            report += "- **Recommendation:** Review filter logic or use baseline strategy\n"
    
    single_filters = [r for r in results if r['name'].startswith('+') and 'error' not in r]
    keep = [r['name'] for r in single_filters if r['delta_sharpe'] > 0]
    discard = [r['name'] for r in single_filters if r['delta_sharpe'] < -5]
    
    if keep:
        report += f"\n### Filters to KEEP\n{', '.join(keep)}\n"
    if discard:
        report += f"\n### Filters to DISCARD\n{', '.join(discard)}\n"
    
    report += """
## Session Breakdown (ALL_FILTERS)

"""
    if all_filters and 'sessions' in all_filters:
        sessions = all_filters['sessions']
        total = sum(sessions.values())
        for s, count in sessions.items():
            pct = count / total * 100 if total > 0 else 0
            report += f"- {s.upper()}: {count} trades ({pct:.1f}%)\n"
    
    report += """
---

## Methodology

1. **BASELINE**: Pure SMC strategy with Order Blocks and FVG detection
2. **+REGIME**: Added Hurst exponent filter (H > 0.55 = trending)
3. **+SESSION**: Added London/NY session filter (08:00-17:00 UTC)
4. **+MTF**: Added H1 trend alignment filter
5. **+CONFLUENCE**: Added minimum confluence score >= 70
6. **ALL_FILTERS**: Combined all filters

## Notes

- Data: 2024 tick data from XAUUSD
- Risk: 0.5% per trade (FTMO compliant)
- SL/TP: 2.0 ATR / 3.0 ATR
- Execution: PESSIMISTIC mode (0.45 spread, 0.05 slippage)

---
*Generated by ORACLE v2.2 - Statistical Truth-Seeker*
"""
    
    return report


# =============================================================================
# MAIN
# =============================================================================

def main():
    import sys
    
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    output_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/DOCS/04_REPORTS/BACKTESTS/ABLATION_STUDY.md"
    use_ea_logic = False
    ea_only = False
    max_ticks = None
    
    # Args: data_path [output_path] [--ea] [--ea-only] [--max N]
    args = sys.argv[1:]
    if len(args) > 0:
        data_path = args[0]
    if len(args) > 1 and not args[1].startswith('--'):
        output_path = args[1]
        args = args[2:]
    else:
        args = args[1:]
    for i, a in enumerate(args):
        if a == '--ea':
            use_ea_logic = True
        if a == '--ea-only':
            use_ea_logic = True
            ea_only = True
        if a == '--max' and i + 1 < len(args):
            try:
                max_ticks = int(args[i + 1])
            except:
                pass
    
    run_ablation_study(data_path, output_path, use_ea_logic=use_ea_logic, max_ticks=max_ticks, ea_only=ea_only)


if __name__ == "__main__":
    main()
