#!/usr/bin/env python3
"""
Phase 00-A: Baseline Validation - EMA vs SMC Comparison
=========================================================

Validates the central thesis: Does SMC outperform a simple EMA crossover?
If not, the complexity isn't justified.

Author: ORACLE (P0 Critical Validation)
Date: 2025-12-23
Version: 1.0.0

GO/NO-GO Decision Logic:
- STOP: SMC < EMA (Sharpe AND Profit Factor) - Philosophy broken
- CAUTION: SMC > EMA by < 20% - Complexity may not be justified
- PROCEED: SMC > EMA by >= 20% - Core thesis validated
"""

import pandas as pd
import numpy as np
from pathlib import Path
from dataclasses import dataclass, field
from typing import Literal
from datetime import datetime, timedelta
import warnings
import json
warnings.filterwarnings('ignore')

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------

@dataclass
class BacktestConfig:
    """Unified backtest configuration for fair comparison."""

    # Risk (same for both strategies)
    initial_balance: float = 100_000.0
    risk_per_trade: float = 0.005  # 0.5% per trade

    # Execution costs (realistic)
    spread_points: float = 30.0    # 30 pips = $3 per lot
    slippage_points: float = 5.0   # 5 pips slippage
    point_value: float = 0.01      # XAUUSD point value

    # ATR-based SL/TP
    atr_period: int = 14
    atr_sl_mult: float = 2.0       # SL = 2 * ATR
    atr_tp_mult: float = 3.0       # TP = 3 * ATR (1.5 RR)

    # Session filter (GMT hours) - SAME for both strategies
    session_start_hour: int = 8     # London open
    session_end_hour: int = 20      # NY close

    # EMA Strategy parameters
    ema_fast_period: int = 20
    ema_slow_period: int = 50

    # SMC Strategy parameters
    swing_strength: int = 3         # Bars to confirm swing
    structure_lookback: int = 50    # Bars to look for structure

    # FTMO/Apex limits
    max_daily_dd: float = 0.05      # 5% daily DD
    max_total_dd: float = 0.10      # 10% total DD


@dataclass
class Trade:
    """Single trade record."""
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
    exit_reason: str
    balance_after: float


@dataclass
class BacktestResult:
    """Backtest result summary."""
    strategy_name: str
    total_trades: int = 0
    wins: int = 0
    losses: int = 0
    win_rate: float = 0.0
    total_pnl: float = 0.0
    profit_factor: float = 0.0
    sharpe_ratio: float = 0.0
    sqn: float = 0.0
    max_drawdown: float = 0.0
    trades: list = field(default_factory=list)


# -----------------------------------------------------------------------------
# DATA LOADING
# -----------------------------------------------------------------------------

def load_tick_data(filepath: Path, start_date: str, end_date: str) -> pd.DataFrame:
    """Load tick data from parquet file and filter by date range."""
    print(f"Loading data from {filepath}...")

    # Read parquet
    df = pd.read_parquet(filepath)
    print(f"  Loaded {len(df):,} total ticks")

    # Identify timestamp column
    ts_col = None
    for col in ['timestamp', 'datetime', 'time', 'date']:
        if col in df.columns:
            ts_col = col
            break

    if ts_col is None:
        # Try first column as timestamp
        ts_col = df.columns[0]

    # Convert to datetime
    if not pd.api.types.is_datetime64_any_dtype(df[ts_col]):
        df[ts_col] = pd.to_datetime(df[ts_col])

    df = df.rename(columns={ts_col: 'timestamp'})

    # Filter by date range
    start = pd.to_datetime(start_date)
    end = pd.to_datetime(end_date)
    df = df[(df['timestamp'] >= start) & (df['timestamp'] <= end)]

    print(f"  Filtered to {len(df):,} ticks ({start_date} to {end_date})")

    # Calculate mid price if bid/ask available
    if 'bid' in df.columns and 'ask' in df.columns:
        df['price'] = (df['bid'] + df['ask']) / 2
    elif 'price' not in df.columns:
        # Try close or first numeric column
        for col in ['close', 'mid']:
            if col in df.columns:
                df['price'] = df[col]
                break

    return df.sort_values('timestamp').reset_index(drop=True)


def resample_to_bars(tick_df: pd.DataFrame, timeframe: str = 'M5') -> pd.DataFrame:
    """Resample tick data to OHLC bars."""
    print(f"Resampling to {timeframe} bars...")

    df = tick_df.set_index('timestamp').sort_index()

    # Map timeframe to pandas resample rule
    tf_map = {
        'M1': '1min', 'M5': '5min', 'M15': '15min', 'M30': '30min',
        'H1': '1h', 'H4': '4h', 'D1': '1D'
    }
    rule = tf_map.get(timeframe, '5min')

    ohlc = df['price'].resample(rule).ohlc()
    ohlc.columns = ['open', 'high', 'low', 'close']
    ohlc = ohlc.dropna()
    ohlc = ohlc.reset_index()
    ohlc = ohlc.rename(columns={'timestamp': 'datetime'})

    print(f"  Created {len(ohlc):,} bars")
    return ohlc


# -----------------------------------------------------------------------------
# INDICATORS
# -----------------------------------------------------------------------------

def calculate_atr(df: pd.DataFrame, period: int = 14) -> pd.Series:
    """Calculate Average True Range."""
    high_low = df['high'] - df['low']
    high_close = np.abs(df['high'] - df['close'].shift(1))
    low_close = np.abs(df['low'] - df['close'].shift(1))
    tr = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
    return tr.rolling(window=period).mean()


def calculate_ema(series: pd.Series, period: int) -> pd.Series:
    """Calculate Exponential Moving Average."""
    return series.ewm(span=period, adjust=False).mean()


def find_swing_highs(df: pd.DataFrame, strength: int = 3) -> pd.Series:
    """
    Find swing highs - points higher than strength bars on both sides.

    LOOK-AHEAD FIX: Uses trailing detection to avoid future data access.
    A swing high at bar i is only confirmed at bar i + strength (when we have
    enough bars AFTER to verify). The signal is marked at the CONFIRMATION bar,
    meaning the strategy can only act on this information at that time.

    This is realistic: you don't know a point is a swing high until you see
    strength bars on each side that are all lower.
    """
    highs = pd.Series(False, index=df.index)
    # We need 2*strength bars of history to confirm a swing high
    # At bar i, we check if bar (i - strength) was a swing high
    for i in range(2 * strength, len(df)):
        candidate_idx = i - strength  # The bar we're checking as a potential swing high
        is_high = True

        # Check strength bars BEFORE the candidate
        for j in range(1, strength + 1):
            before_idx = candidate_idx - j
            if df['high'].iloc[candidate_idx] <= df['high'].iloc[before_idx]:
                is_high = False
                break

        # Check strength bars AFTER the candidate (up to current bar i)
        # These bars are now in the past relative to bar i (confirmation bar)
        if is_high:
            for j in range(1, strength + 1):
                after_idx = candidate_idx + j
                # after_idx <= i (current bar), so this is past data from bar i's perspective
                if df['high'].iloc[candidate_idx] <= df['high'].iloc[after_idx]:
                    is_high = False
                    break

        # CRITIC FIX: Mark at bar i (confirmation bar), not candidate_idx
        # In real-time, we only KNOW about the swing at bar i (after seeing strength bars after)
        # The actual swing price is at candidate_idx = i - strength, which BOS detection must look back for
        if is_high:
            highs.iloc[i] = True  # Mark at CONFIRMATION bar to avoid look-ahead

    return highs


def find_swing_lows(df: pd.DataFrame, strength: int = 3) -> pd.Series:
    """
    Find swing lows - points lower than strength bars on both sides.

    LOOK-AHEAD FIX: Uses trailing detection to avoid future data access.
    A swing low at bar i is only confirmed at bar i + strength (when we have
    enough bars AFTER to verify).
    """
    lows = pd.Series(False, index=df.index)
    # We need 2*strength bars of history to confirm a swing low
    for i in range(2 * strength, len(df)):
        candidate_idx = i - strength  # The bar we're checking as a potential swing low
        is_low = True

        # Check strength bars BEFORE the candidate
        for j in range(1, strength + 1):
            before_idx = candidate_idx - j
            if df['low'].iloc[candidate_idx] >= df['low'].iloc[before_idx]:
                is_low = False
                break

        # Check strength bars AFTER the candidate (up to current bar i)
        if is_low:
            for j in range(1, strength + 1):
                after_idx = candidate_idx + j
                if df['low'].iloc[candidate_idx] >= df['low'].iloc[after_idx]:
                    is_low = False
                    break

        # CRITIC FIX: Mark at bar i (confirmation bar), not candidate_idx
        # In real-time, we only KNOW about the swing at bar i (after seeing strength bars after)
        # The actual swing price is at candidate_idx = i - strength, which BOS detection must look back for
        if is_low:
            lows.iloc[i] = True  # Mark at CONFIRMATION bar to avoid look-ahead

    return lows


# -----------------------------------------------------------------------------
# EMA CROSSOVER STRATEGY
# -----------------------------------------------------------------------------

def run_ema_strategy(df: pd.DataFrame, config: BacktestConfig) -> BacktestResult:
    """
    EMA Crossover Strategy.

    Entry:
    - BUY: Fast EMA crosses above Slow EMA
    - SELL: Fast EMA crosses below Slow EMA

    Filters:
    - Session filter: Only trade during London/NY hours

    Exit:
    - ATR-based SL/TP
    """
    print("\n" + "="*60)
    print("Running EMA CROSSOVER Strategy")
    print("="*60)

    result = BacktestResult(strategy_name="EMA_CROSSOVER")

    # Calculate indicators
    df = df.copy()
    df['atr'] = calculate_atr(df, config.atr_period)
    df['ema_fast'] = calculate_ema(df['close'], config.ema_fast_period)
    df['ema_slow'] = calculate_ema(df['close'], config.ema_slow_period)
    df['hour'] = df['datetime'].dt.hour

    # Generate signals
    df['signal'] = 0

    # Bullish crossover
    df.loc[(df['ema_fast'] > df['ema_slow']) &
           (df['ema_fast'].shift(1) <= df['ema_slow'].shift(1)), 'signal'] = 1

    # Bearish crossover
    df.loc[(df['ema_fast'] < df['ema_slow']) &
           (df['ema_fast'].shift(1) >= df['ema_slow'].shift(1)), 'signal'] = -1

    # Session filter
    session_mask = (df['hour'] >= config.session_start_hour) & (df['hour'] < config.session_end_hour)
    df.loc[~session_mask, 'signal'] = 0

    # Drop NaN rows
    df = df.dropna().reset_index(drop=True)

    buy_signals = (df['signal'] == 1).sum()
    sell_signals = (df['signal'] == -1).sum()
    print(f"  Signals: {buy_signals} BUY, {sell_signals} SELL")

    # Run backtest simulation
    result = _simulate_trades(df, config, result)

    return result


# -----------------------------------------------------------------------------
# SIMPLIFIED SMC STRATEGY
# -----------------------------------------------------------------------------

def run_smc_strategy(df: pd.DataFrame, config: BacktestConfig) -> BacktestResult:
    """
    Simplified SMC Strategy.

    Core SMC Concepts:
    1. Market Structure: Track swing highs/lows
    2. Break of Structure (BOS): Price breaks above swing high (bullish) or below swing low (bearish)
    3. Entry: On pullback after BOS

    Entry Logic:
    - BUY: After bullish BOS, enter on pullback to 50% of the move
    - SELL: After bearish BOS, enter on pullback to 50% of the move

    Filters:
    - Session filter: Only trade during London/NY hours

    This captures the ESSENCE of SMC:
    "Wait for structure break, enter on retrace to key zone"
    """
    print("\n" + "="*60)
    print("Running SIMPLIFIED SMC Strategy")
    print("="*60)

    result = BacktestResult(strategy_name="SMC_SIMPLIFIED")

    # Calculate indicators
    df = df.copy()
    df['atr'] = calculate_atr(df, config.atr_period)
    df['hour'] = df['datetime'].dt.hour

    # Find swing points
    df['swing_high'] = find_swing_highs(df, config.swing_strength)
    df['swing_low'] = find_swing_lows(df, config.swing_strength)

    # Track structure
    # CRITIC FIX: Swings are now marked at confirmation bar (i), but actual swing price
    # is at bar (i - swing_strength). We must look back to get the correct price.
    df['last_swing_high'] = np.nan
    df['last_swing_low'] = np.nan

    last_sh = np.nan
    last_sl = np.nan
    strength = config.swing_strength  # Need this to look back for actual swing price

    for i in range(len(df)):
        if df['swing_high'].iloc[i]:
            # Swing confirmed at bar i, but actual high was at bar (i - strength)
            swing_bar = i - strength
            if swing_bar >= 0:
                last_sh = df['high'].iloc[swing_bar]
        if df['swing_low'].iloc[i]:
            # Swing confirmed at bar i, but actual low was at bar (i - strength)
            swing_bar = i - strength
            if swing_bar >= 0:
                last_sl = df['low'].iloc[swing_bar]
        df.loc[df.index[i], 'last_swing_high'] = last_sh
        df.loc[df.index[i], 'last_swing_low'] = last_sl

    # Detect Break of Structure
    df['bos_bullish'] = df['close'] > df['last_swing_high'].shift(1)
    df['bos_bearish'] = df['close'] < df['last_swing_low'].shift(1)

    # Track BOS state and retrace levels
    df['signal'] = 0

    bos_bullish_active = False
    bos_bearish_active = False
    retrace_level = 0.0
    bos_high = 0.0
    bos_low = 0.0

    for i in range(1, len(df)):
        row = df.iloc[i]
        prev = df.iloc[i-1]

        # Session filter
        if row['hour'] < config.session_start_hour or row['hour'] >= config.session_end_hour:
            continue

        # New bullish BOS
        if row['bos_bullish'] and not pd.isna(prev['last_swing_low']):
            bos_bullish_active = True
            bos_bearish_active = False
            bos_low = prev['last_swing_low']
            bos_high = row['close']
            # Retrace level = 50% of the move
            retrace_level = bos_low + (bos_high - bos_low) * 0.5

        # New bearish BOS
        elif row['bos_bearish'] and not pd.isna(prev['last_swing_high']):
            bos_bearish_active = True
            bos_bullish_active = False
            bos_high = prev['last_swing_high']
            bos_low = row['close']
            # Retrace level = 50% of the move
            retrace_level = bos_high - (bos_high - bos_low) * 0.5

        # Check for entry on retrace
        if bos_bullish_active and row['low'] <= retrace_level < row['high']:
            df.loc[df.index[i], 'signal'] = 1
            bos_bullish_active = False  # Reset after entry

        elif bos_bearish_active and row['low'] <= retrace_level < row['high']:
            df.loc[df.index[i], 'signal'] = -1
            bos_bearish_active = False  # Reset after entry

    # Drop NaN rows
    df = df.dropna().reset_index(drop=True)

    buy_signals = (df['signal'] == 1).sum()
    sell_signals = (df['signal'] == -1).sum()
    print(f"  Signals: {buy_signals} BUY, {sell_signals} SELL")

    # Run backtest simulation
    result = _simulate_trades(df, config, result)

    return result


# -----------------------------------------------------------------------------
# TRADE SIMULATION
# -----------------------------------------------------------------------------

def _simulate_trades(df: pd.DataFrame, config: BacktestConfig, result: BacktestResult) -> BacktestResult:
    """Simulate trades and calculate metrics."""

    balance = config.initial_balance
    peak_balance = balance
    daily_start_balance = balance
    current_date = None

    position = None
    trades = []
    equity_curve = [balance]

    for i in range(len(df)):
        row = df.iloc[i]

        # Daily reset
        trade_date = row['datetime'].date()
        if current_date != trade_date:
            daily_start_balance = balance
            current_date = trade_date

        # Check DD limits
        daily_dd = (daily_start_balance - balance) / daily_start_balance if daily_start_balance > 0 else 0
        total_dd = (peak_balance - balance) / peak_balance if peak_balance > 0 else 0

        if daily_dd >= config.max_daily_dd or total_dd >= config.max_total_dd:
            if position:
                trade = _close_position(position, row, 'DD_LIMIT', balance, config)
                balance += trade.pnl
                trades.append(trade)
                position = None
            continue

        # Manage existing position
        if position:
            if position['direction'] == 'BUY':
                if row['low'] <= position['sl']:
                    trade = _close_position(position, row, 'SL', balance, config, position['sl'])
                    balance += trade.pnl
                    trades.append(trade)
                    position = None
                elif row['high'] >= position['tp']:
                    trade = _close_position(position, row, 'TP', balance, config, position['tp'])
                    balance += trade.pnl
                    trades.append(trade)
                    position = None
            else:  # SELL
                if row['high'] >= position['sl']:
                    trade = _close_position(position, row, 'SL', balance, config, position['sl'])
                    balance += trade.pnl
                    trades.append(trade)
                    position = None
                elif row['low'] <= position['tp']:
                    trade = _close_position(position, row, 'TP', balance, config, position['tp'])
                    balance += trade.pnl
                    trades.append(trade)
                    position = None

        # Open new position on signal
        if position is None and row['signal'] != 0:
            atr = row['atr']
            if pd.isna(atr) or atr <= 0:
                continue

            sl_dist = atr * config.atr_sl_mult
            tp_dist = atr * config.atr_tp_mult

            spread_cost = (config.spread_points + config.slippage_points) * config.point_value

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
            risk_amount = balance * config.risk_per_trade
            # Formula: lots = risk_amount / (sl_distance_in_dollars)
            # For XAUUSD: 1 lot = 100 oz, 1 point = $0.01 per oz = $1 per lot
            lots = risk_amount / (sl_dist / config.point_value)
            lots = max(0.01, min(lots, 10.0))

            position = {
                'entry_time': row['datetime'],
                'direction': direction,
                'entry_price': entry,
                'sl': sl,
                'tp': tp,
                'lots': lots
            }

        equity_curve.append(balance)
        peak_balance = max(peak_balance, balance)

    # Close any remaining position
    if position:
        trade = _close_position(position, df.iloc[-1], 'EOD', balance, config)
        balance += trade.pnl
        trades.append(trade)

    # Calculate metrics
    result.trades = trades
    result.total_trades = len(trades)

    if trades:
        pnls = [t.pnl for t in trades]
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p < 0]

        result.wins = len(wins)
        result.losses = len(losses)
        result.win_rate = len(wins) / len(pnls) * 100 if pnls else 0
        result.total_pnl = sum(pnls)
        result.profit_factor = sum(wins) / abs(sum(losses)) if losses else float('inf')

        # Drawdown
        equity = np.array(equity_curve)
        peak = np.maximum.accumulate(equity)
        dd = (peak - equity) / peak
        result.max_drawdown = np.max(dd) * 100

        # Sharpe (annualized, M5 bars)
        returns = np.diff(equity) / equity[:-1]
        if np.std(returns) > 0:
            result.sharpe_ratio = np.mean(returns) / np.std(returns) * np.sqrt(252 * 24 * 12)

        # SQN
        if np.std(pnls) > 0:
            result.sqn = np.mean(pnls) / np.std(pnls) * np.sqrt(len(pnls))

    print(f"  Trades: {result.total_trades}")
    print(f"  Win Rate: {result.win_rate:.1f}%")
    print(f"  PnL: ${result.total_pnl:,.2f}")
    print(f"  Sharpe: {result.sharpe_ratio:.2f}")
    print(f"  PF: {result.profit_factor:.2f}")
    print(f"  Max DD: {result.max_drawdown:.2f}%")

    return result


def _close_position(position: dict, row, reason: str, balance: float,
                   config: BacktestConfig, exit_price: float = None) -> Trade:
    """Close position and create trade record."""
    if exit_price is None:
        exit_price = row['close']

    if position['direction'] == 'BUY':
        pnl_points = (exit_price - position['entry_price']) / config.point_value
    else:
        pnl_points = (position['entry_price'] - exit_price) / config.point_value

    pnl = pnl_points * position['lots']
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


# -----------------------------------------------------------------------------
# COMPARISON AND VERDICT
# -----------------------------------------------------------------------------

def compare_results(ema_result: BacktestResult, smc_result: BacktestResult) -> dict:
    """Compare results and determine GO/NO-GO verdict."""

    print("\n" + "="*80)
    print("BASELINE VALIDATION COMPARISON")
    print("="*80)

    # Comparison table
    metrics = ['total_trades', 'win_rate', 'total_pnl', 'sharpe_ratio', 'profit_factor', 'max_drawdown']
    labels = ['Total Trades', 'Win Rate (%)', 'Net PnL ($)', 'Sharpe Ratio', 'Profit Factor', 'Max DD (%)']

    comparison = {}

    print(f"\n{'Metric':<20} {'EMA':>15} {'SMC':>15} {'Delta':>15} {'% Diff':>15}")
    print("-" * 80)

    for metric, label in zip(metrics, labels):
        ema_val = getattr(ema_result, metric)
        smc_val = getattr(smc_result, metric)

        delta = smc_val - ema_val
        pct_diff = (delta / abs(ema_val) * 100) if ema_val != 0 else 0

        comparison[metric] = {
            'ema': ema_val,
            'smc': smc_val,
            'delta': delta,
            'pct_diff': pct_diff
        }

        print(f"{label:<20} {ema_val:>15.2f} {smc_val:>15.2f} {delta:>+15.2f} {pct_diff:>+14.1f}%")

    # GO/NO-GO Decision
    print("\n" + "="*80)
    print("GO/NO-GO DECISION")
    print("="*80)

    sharpe_better = smc_result.sharpe_ratio > ema_result.sharpe_ratio
    pf_better = smc_result.profit_factor > ema_result.profit_factor

    # Calculate improvement percentage (average of Sharpe and PF improvement)
    sharpe_pct = comparison['sharpe_ratio']['pct_diff']
    pf_pct = comparison['profit_factor']['pct_diff']
    avg_improvement = (sharpe_pct + pf_pct) / 2

    if not sharpe_better and not pf_better:
        verdict = "STOP"
        rationale = "SMC underperforms EMA on BOTH Sharpe AND Profit Factor. Philosophy broken."
    elif not sharpe_better or not pf_better:
        verdict = "CAUTION"
        rationale = "SMC only partially outperforms EMA. Mixed results."
    elif avg_improvement < 20:
        verdict = "CAUTION"
        rationale = f"SMC outperforms EMA by {avg_improvement:.1f}% (< 20%). Complexity may not be justified."
    else:
        verdict = "PROCEED"
        rationale = f"SMC outperforms EMA by {avg_improvement:.1f}% (>= 20%). Core thesis validated."

    print(f"\nVERDICT: {verdict}")
    print(f"\nRationale: {rationale}")

    print("\nDetails:")
    print(f"  - Sharpe improvement: {sharpe_pct:+.1f}% ({'BETTER' if sharpe_better else 'WORSE'})")
    print(f"  - PF improvement: {pf_pct:+.1f}% ({'BETTER' if pf_better else 'WORSE'})")
    print(f"  - Average improvement: {avg_improvement:+.1f}%")

    return {
        'verdict': verdict,
        'rationale': rationale,
        'comparison': comparison,
        'sharpe_better': sharpe_better,
        'pf_better': pf_better,
        'avg_improvement': avg_improvement,
        'ema_result': {
            'total_trades': ema_result.total_trades,
            'win_rate': ema_result.win_rate,
            'total_pnl': ema_result.total_pnl,
            'sharpe_ratio': ema_result.sharpe_ratio,
            'profit_factor': ema_result.profit_factor,
            'max_drawdown': ema_result.max_drawdown,
        },
        'smc_result': {
            'total_trades': smc_result.total_trades,
            'win_rate': smc_result.win_rate,
            'total_pnl': smc_result.total_pnl,
            'sharpe_ratio': smc_result.sharpe_ratio,
            'profit_factor': smc_result.profit_factor,
            'max_drawdown': smc_result.max_drawdown,
        }
    }


# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

def main():
    """Run baseline comparison."""

    print("="*80)
    print("PHASE 00-A: BASELINE VALIDATION")
    print("EMA Crossover vs SMC Strategy Comparison")
    print("="*80)

    # Configuration
    config = BacktestConfig()

    # Data paths
    data_path = Path("/home/franco/projetos/EA_SCALPER_XAUUSD/data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet")

    # Date range as specified in plan
    start_date = "2024-01-01"
    end_date = "2024-06-30"

    print(f"\nConfiguration:")
    print(f"  Data: {data_path}")
    print(f"  Period: {start_date} to {end_date}")
    print(f"  Session: {config.session_start_hour}:00 - {config.session_end_hour}:00 GMT")
    print(f"  EMA: {config.ema_fast_period}/{config.ema_slow_period}")
    print(f"  Risk per trade: {config.risk_per_trade*100}%")

    # Load and prepare data
    tick_df = load_tick_data(data_path, start_date, end_date)
    bar_df = resample_to_bars(tick_df, 'M5')

    # Run EMA Strategy
    ema_result = run_ema_strategy(bar_df.copy(), config)

    # Run SMC Strategy
    smc_result = run_smc_strategy(bar_df.copy(), config)

    # Compare and get verdict
    verdict_data = compare_results(ema_result, smc_result)

    # Save results to JSON
    output_dir = Path("/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/09-strategy-activation/orchestration")
    output_dir.mkdir(parents=True, exist_ok=True)

    results_file = output_dir / "phase_00a_results.json"
    with open(results_file, 'w') as f:
        json.dump(verdict_data, f, indent=2, default=str)

    print(f"\nResults saved to: {results_file}")

    return verdict_data


if __name__ == '__main__':
    verdict = main()
