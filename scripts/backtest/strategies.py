#!/usr/bin/env python3
"""
Trading Strategies Module
=========================
Multiple strategies for backtesting comparison.

Strategies:
1. MA Cross - Simple moving average crossover
2. Mean Reversion - RSI oversold/overbought
3. Breakout - Donchian channel breakout
4. Trend Following - ADX + EMA
5. EA Logic - Simplified confluence scoring (real EA)

Author: ORACLE + FORGE
Date: 2025-12-01
"""

import numpy as np
import pandas as pd
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional, Tuple
from enum import Enum


class Signal(Enum):
    NONE = 0
    BUY = 1
    SELL = -1


@dataclass
class StrategyConfig:
    """Base strategy configuration"""
    atr_period: int = 14
    atr_sl_mult: float = 2.0
    atr_tp_mult: float = 3.0


# =============================================================================
# BASE STRATEGY
# =============================================================================

class BaseStrategy(ABC):
    """Abstract base class for all strategies"""
    
    def __init__(self, config: StrategyConfig = None):
        self.config = config or StrategyConfig()
        self.name = "BaseStrategy"
    
    @abstractmethod
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        """Add strategy-specific indicators to dataframe"""
        pass
    
    @abstractmethod
    def generate_signal(self, row: pd.Series) -> Signal:
        """Generate trading signal for current bar"""
        pass
    
    def calculate_sl_tp(self, entry_price: float, atr: float, 
                        direction: Signal) -> Tuple[float, float]:
        """Calculate SL and TP based on ATR"""
        if direction == Signal.BUY:
            sl = entry_price - atr * self.config.atr_sl_mult
            tp = entry_price + atr * self.config.atr_tp_mult
        else:
            sl = entry_price + atr * self.config.atr_sl_mult
            tp = entry_price - atr * self.config.atr_tp_mult
        return sl, tp


# =============================================================================
# STRATEGY 1: MA CROSS
# =============================================================================

@dataclass
class MACrossConfig(StrategyConfig):
    fast_period: int = 20
    slow_period: int = 50


class MACrossStrategy(BaseStrategy):
    """Simple Moving Average Crossover Strategy"""
    
    def __init__(self, config: MACrossConfig = None):
        super().__init__(config or MACrossConfig())
        self.name = "MA Cross (20/50)"
    
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        cfg = self.config
        
        # ATR
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(cfg.atr_period).mean()
        
        # Moving Averages
        df['ma_fast'] = df['close'].rolling(cfg.fast_period).mean()
        df['ma_slow'] = df['close'].rolling(cfg.slow_period).mean()
        
        # Signals
        df['ma_cross_up'] = (df['ma_fast'] > df['ma_slow']) & (df['ma_fast'].shift(1) <= df['ma_slow'].shift(1))
        df['ma_cross_down'] = (df['ma_fast'] < df['ma_slow']) & (df['ma_fast'].shift(1) >= df['ma_slow'].shift(1))
        
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        if row.get('ma_cross_up', False):
            return Signal.BUY
        elif row.get('ma_cross_down', False):
            return Signal.SELL
        return Signal.NONE


# =============================================================================
# STRATEGY 2: MEAN REVERSION (RSI)
# =============================================================================

@dataclass
class MeanReversionConfig(StrategyConfig):
    rsi_period: int = 14
    rsi_oversold: float = 30
    rsi_overbought: float = 70
    require_trend: bool = True
    trend_ma_period: int = 200


class MeanReversionStrategy(BaseStrategy):
    """Mean Reversion using RSI oversold/overbought"""
    
    def __init__(self, config: MeanReversionConfig = None):
        super().__init__(config or MeanReversionConfig())
        self.name = "Mean Reversion (RSI)"
    
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        cfg = self.config
        
        # ATR
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(cfg.atr_period).mean()
        
        # RSI
        delta = df['close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=cfg.rsi_period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=cfg.rsi_period).mean()
        rs = gain / loss
        df['rsi'] = 100 - (100 / (1 + rs))
        
        # Trend MA (for filtering)
        df['ma_trend'] = df['close'].rolling(cfg.trend_ma_period).mean()
        df['uptrend'] = df['close'] > df['ma_trend']
        
        # Signals: Buy oversold in uptrend, Sell overbought in downtrend
        df['rsi_oversold'] = (df['rsi'] < cfg.rsi_oversold) & (df['rsi'].shift(1) >= cfg.rsi_oversold)
        df['rsi_overbought'] = (df['rsi'] > cfg.rsi_overbought) & (df['rsi'].shift(1) <= cfg.rsi_overbought)
        
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        cfg = self.config
        
        if cfg.require_trend:
            # Buy oversold only in uptrend
            if row.get('rsi_oversold', False) and row.get('uptrend', False):
                return Signal.BUY
            # Sell overbought only in downtrend
            if row.get('rsi_overbought', False) and not row.get('uptrend', True):
                return Signal.SELL
        else:
            if row.get('rsi_oversold', False):
                return Signal.BUY
            if row.get('rsi_overbought', False):
                return Signal.SELL
        
        return Signal.NONE


# =============================================================================
# STRATEGY 3: BREAKOUT (DONCHIAN)
# =============================================================================

@dataclass
class BreakoutConfig(StrategyConfig):
    channel_period: int = 20
    atr_filter: bool = True
    min_atr_mult: float = 1.0  # Minimum ATR for volatility filter


class BreakoutStrategy(BaseStrategy):
    """Donchian Channel Breakout Strategy"""
    
    def __init__(self, config: BreakoutConfig = None):
        super().__init__(config or BreakoutConfig())
        self.name = "Breakout (Donchian)"
    
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        cfg = self.config
        
        # ATR
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(cfg.atr_period).mean()
        df['atr_avg'] = df['atr'].rolling(50).mean()
        
        # Donchian Channel
        df['dc_high'] = df['high'].rolling(cfg.channel_period).max()
        df['dc_low'] = df['low'].rolling(cfg.channel_period).min()
        
        # Breakout signals
        df['break_up'] = df['close'] > df['dc_high'].shift(1)
        df['break_down'] = df['close'] < df['dc_low'].shift(1)
        
        # ATR filter (only trade when volatility is above average)
        df['vol_ok'] = df['atr'] > df['atr_avg'] * cfg.min_atr_mult
        
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        cfg = self.config
        
        if cfg.atr_filter and not row.get('vol_ok', True):
            return Signal.NONE
        
        if row.get('break_up', False):
            return Signal.BUY
        if row.get('break_down', False):
            return Signal.SELL
        
        return Signal.NONE


# =============================================================================
# STRATEGY 4: TREND FOLLOWING (ADX + EMA)
# =============================================================================

@dataclass
class TrendFollowingConfig(StrategyConfig):
    adx_period: int = 14
    adx_threshold: float = 25
    ema_fast: int = 12
    ema_slow: int = 26


class TrendFollowingStrategy(BaseStrategy):
    """Trend Following with ADX filter and EMA crossover"""
    
    def __init__(self, config: TrendFollowingConfig = None):
        super().__init__(config or TrendFollowingConfig())
        self.name = "Trend Following (ADX+EMA)"
    
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        cfg = self.config
        
        # ATR
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(cfg.atr_period).mean()
        
        # ADX calculation
        df['up_move'] = df['high'] - df['high'].shift(1)
        df['down_move'] = df['low'].shift(1) - df['low']
        
        df['+dm'] = np.where((df['up_move'] > df['down_move']) & (df['up_move'] > 0), df['up_move'], 0)
        df['-dm'] = np.where((df['down_move'] > df['up_move']) & (df['down_move'] > 0), df['down_move'], 0)
        
        df['+di'] = 100 * (df['+dm'].ewm(span=cfg.adx_period).mean() / df['atr'])
        df['-di'] = 100 * (df['-dm'].ewm(span=cfg.adx_period).mean() / df['atr'])
        
        df['dx'] = 100 * abs(df['+di'] - df['-di']) / (df['+di'] + df['-di'])
        df['adx'] = df['dx'].ewm(span=cfg.adx_period).mean()
        
        # EMAs
        df['ema_fast'] = df['close'].ewm(span=cfg.ema_fast).mean()
        df['ema_slow'] = df['close'].ewm(span=cfg.ema_slow).mean()
        
        # Signals
        df['ema_cross_up'] = (df['ema_fast'] > df['ema_slow']) & (df['ema_fast'].shift(1) <= df['ema_slow'].shift(1))
        df['ema_cross_down'] = (df['ema_fast'] < df['ema_slow']) & (df['ema_fast'].shift(1) >= df['ema_slow'].shift(1))
        df['trending'] = df['adx'] > cfg.adx_threshold
        
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        if not row.get('trending', False):
            return Signal.NONE
        
        if row.get('ema_cross_up', False):
            return Signal.BUY
        if row.get('ema_cross_down', False):
            return Signal.SELL
        
        return Signal.NONE


# =============================================================================
# STRATEGY 5: EA LOGIC (CONFLUENCE SCORING)
# =============================================================================

@dataclass
class EALogicConfig(StrategyConfig):
    # Confluence thresholds
    min_score: int = 60
    
    # Regime
    hurst_period: int = 100
    hurst_trending: float = 0.55
    
    # Structure
    structure_lookback: int = 50
    
    # Session (GMT hours)
    session_start: int = 8
    session_end: int = 20
    
    # Momentum
    rsi_period: int = 14
    rsi_bull: float = 50
    rsi_bear: float = 50
    
    # Volatility
    bb_period: int = 20
    bb_std: float = 2.0


class EALogicStrategy(BaseStrategy):
    """
    Simplified EA Confluence Scoring Strategy
    
    Score components (max 100):
    - Trend alignment (MA): 20 pts
    - Momentum (RSI): 20 pts
    - Volatility (BB): 15 pts
    - Structure (HH/LL): 20 pts
    - Session: 15 pts
    - Regime (Hurst): 10 pts
    """
    
    def __init__(self, config: EALogicConfig = None):
        super().__init__(config or EALogicConfig())
        self.name = f"EA Logic (Score>={self.config.min_score})"
    
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        cfg = self.config
        
        # ATR
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(cfg.atr_period).mean()
        
        # 1. Trend (MAs)
        df['ema_20'] = df['close'].ewm(span=20).mean()
        df['ema_50'] = df['close'].ewm(span=50).mean()
        df['ema_200'] = df['close'].ewm(span=200).mean()
        
        df['trend_bull'] = (df['ema_20'] > df['ema_50']) & (df['ema_50'] > df['ema_200'])
        df['trend_bear'] = (df['ema_20'] < df['ema_50']) & (df['ema_50'] < df['ema_200'])
        
        # 2. Momentum (RSI)
        delta = df['close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=cfg.rsi_period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=cfg.rsi_period).mean()
        rs = gain / loss
        df['rsi'] = 100 - (100 / (1 + rs))
        
        # 3. Volatility (Bollinger Bands)
        df['bb_mid'] = df['close'].rolling(cfg.bb_period).mean()
        df['bb_std'] = df['close'].rolling(cfg.bb_period).std()
        df['bb_upper'] = df['bb_mid'] + cfg.bb_std * df['bb_std']
        df['bb_lower'] = df['bb_mid'] - cfg.bb_std * df['bb_std']
        df['bb_pct'] = (df['close'] - df['bb_lower']) / (df['bb_upper'] - df['bb_lower'])
        
        # 4. Structure (Higher Highs / Lower Lows)
        df['highest'] = df['high'].rolling(cfg.structure_lookback).max()
        df['lowest'] = df['low'].rolling(cfg.structure_lookback).min()
        df['structure_bull'] = df['close'] > df['highest'].shift(1)
        df['structure_bear'] = df['close'] < df['lowest'].shift(1)
        
        # 5. Session
        df['hour'] = df.index.hour
        df['in_session'] = (df['hour'] >= cfg.session_start) & (df['hour'] < cfg.session_end)
        
        # 6. Regime (simplified Hurst)
        df['hurst'] = self._rolling_hurst(df['close'], cfg.hurst_period)
        df['trending_regime'] = df['hurst'] > cfg.hurst_trending
        
        # Calculate confluence scores
        df['score_buy'] = self._calculate_buy_score(df)
        df['score_sell'] = self._calculate_sell_score(df)
        
        return df.dropna()
    
    def _rolling_hurst(self, series: pd.Series, window: int) -> pd.Series:
        """Simplified Hurst exponent"""
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
    
    def _calculate_buy_score(self, df: pd.DataFrame) -> pd.Series:
        """Calculate buy confluence score"""
        cfg = self.config
        score = pd.Series(0, index=df.index, dtype=float)
        
        # Trend alignment (20 pts)
        score += df['trend_bull'].astype(int) * 20
        
        # Momentum - RSI > 50 for bulls (20 pts)
        score += (df['rsi'] > cfg.rsi_bull).astype(int) * 20
        
        # Volatility - price near lower BB = good buy (15 pts)
        score += (df['bb_pct'] < 0.3).astype(int) * 15
        
        # Structure - new high (20 pts)
        score += df['structure_bull'].astype(int) * 20
        
        # Session (15 pts)
        score += df['in_session'].astype(int) * 15
        
        # Regime - trending (10 pts)
        score += df['trending_regime'].astype(int) * 10
        
        return score
    
    def _calculate_sell_score(self, df: pd.DataFrame) -> pd.Series:
        """Calculate sell confluence score"""
        cfg = self.config
        score = pd.Series(0, index=df.index, dtype=float)
        
        # Trend alignment (20 pts)
        score += df['trend_bear'].astype(int) * 20
        
        # Momentum - RSI < 50 for bears (20 pts)
        score += (df['rsi'] < cfg.rsi_bear).astype(int) * 20
        
        # Volatility - price near upper BB = good sell (15 pts)
        score += (df['bb_pct'] > 0.7).astype(int) * 15
        
        # Structure - new low (20 pts)
        score += df['structure_bear'].astype(int) * 20
        
        # Session (15 pts)
        score += df['in_session'].astype(int) * 15
        
        # Regime - trending (10 pts)
        score += df['trending_regime'].astype(int) * 10
        
        return score
    
    def generate_signal(self, row: pd.Series) -> Signal:
        cfg = self.config
        
        buy_score = row.get('score_buy', 0)
        sell_score = row.get('score_sell', 0)
        
        # Need minimum score and buy must be higher than sell
        if buy_score >= cfg.min_score and buy_score > sell_score:
            return Signal.BUY
        
        if sell_score >= cfg.min_score and sell_score > buy_score:
            return Signal.SELL
        
        return Signal.NONE


# =============================================================================
# STRATEGY 6: MOMENTUM SCALPER
# =============================================================================

@dataclass 
class MomentumScalperConfig(StrategyConfig):
    ema_fast: int = 8
    ema_slow: int = 21
    rsi_period: int = 7
    rsi_entry_bull: float = 60
    rsi_entry_bear: float = 40
    volume_mult: float = 1.5  # Volume must be 1.5x average
    atr_sl_mult: float = 1.5  # Tighter SL for scalping
    atr_tp_mult: float = 2.0  # 1.33 RR


class MomentumScalperStrategy(BaseStrategy):
    """Momentum Scalper - Quick entries on momentum bursts"""
    
    def __init__(self, config: MomentumScalperConfig = None):
        super().__init__(config or MomentumScalperConfig())
        self.name = "Momentum Scalper"
    
    def calculate_indicators(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        cfg = self.config
        
        # ATR
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(cfg.atr_period).mean()
        
        # EMAs
        df['ema_fast'] = df['close'].ewm(span=cfg.ema_fast).mean()
        df['ema_slow'] = df['close'].ewm(span=cfg.ema_slow).mean()
        
        # RSI
        delta = df['close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=cfg.rsi_period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=cfg.rsi_period).mean()
        rs = gain / loss
        df['rsi'] = 100 - (100 / (1 + rs))
        
        # Volume
        df['vol_avg'] = df['volume'].rolling(20).mean()
        df['vol_spike'] = df['volume'] > df['vol_avg'] * cfg.volume_mult
        
        # Momentum signals
        df['bull_momentum'] = (
            (df['ema_fast'] > df['ema_slow']) & 
            (df['rsi'] > cfg.rsi_entry_bull) &
            (df['close'] > df['close'].shift(1))
        )
        df['bear_momentum'] = (
            (df['ema_fast'] < df['ema_slow']) & 
            (df['rsi'] < cfg.rsi_entry_bear) &
            (df['close'] < df['close'].shift(1))
        )
        
        return df.dropna()
    
    def generate_signal(self, row: pd.Series) -> Signal:
        # Require volume spike
        if not row.get('vol_spike', False):
            return Signal.NONE
        
        if row.get('bull_momentum', False):
            return Signal.BUY
        if row.get('bear_momentum', False):
            return Signal.SELL
        
        return Signal.NONE


# =============================================================================
# FACTORY
# =============================================================================

def get_all_strategies() -> list:
    """Return list of all available strategies"""
    return [
        MACrossStrategy(),
        MeanReversionStrategy(),
        BreakoutStrategy(),
        TrendFollowingStrategy(),
        EALogicStrategy(EALogicConfig(min_score=50)),
        EALogicStrategy(EALogicConfig(min_score=60)),
        EALogicStrategy(EALogicConfig(min_score=70)),
        MomentumScalperStrategy(),
    ]


def get_strategy_by_name(name: str) -> BaseStrategy:
    """Get strategy by name"""
    strategies = {
        'ma_cross': MACrossStrategy(),
        'mean_reversion': MeanReversionStrategy(),
        'breakout': BreakoutStrategy(),
        'trend_following': TrendFollowingStrategy(),
        'ea_logic_50': EALogicStrategy(EALogicConfig(min_score=50)),
        'ea_logic_60': EALogicStrategy(EALogicConfig(min_score=60)),
        'ea_logic_70': EALogicStrategy(EALogicConfig(min_score=70)),
        'momentum_scalper': MomentumScalperStrategy(),
    }
    return strategies.get(name.lower())
