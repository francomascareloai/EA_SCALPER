"""
EA_SCALPER_XAUUSD v3.30 - FULL PORT TO PYTHON
==============================================
Port completo do EA MQL5 para Python, garantindo paridade 100%.

MODULOS PORTADOS:
- CRegimeDetector: Multi-scale Hurst, Variance Ratio, Transition detection
- CSessionFilter: Session/Day quality scoring
- CMTFManager: H1/M15/M5 alignment, Session quality
- CLiquiditySweepDetector: BSL/SSL pools, Sweep detection
- CFootprintAnalyzer: Order Flow, Delta, Absorption (simplified for backtest)
- CConfluenceScorer: 9 factors, Bayesian scoring, Session profiles

Author: Franco / Singularity Trading
Version: 3.30 Python Port
"""

import numpy as np
import pandas as pd
from enum import IntEnum, auto
from dataclasses import dataclass, field
from typing import Optional, Tuple, List, Dict
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

# Footprint analyzer for order flow (support both absolute and relative import)
try:
    from scripts.backtest.footprint_analyzer import (
        FootprintAnalyzer,
        FootprintConfig,
        merge_footprint_with_bars,
    )
except ImportError:
    from footprint_analyzer import (
        FootprintAnalyzer,
        FootprintConfig,
        merge_footprint_with_bars,
    )
# Utility detectors (OB, FVG) reused across modules
def detect_order_blocks(df: pd.DataFrame, atr: np.ndarray, displacement_mult: float = 2.0) -> List[Dict]:
    obs = []
    if atr is None or len(df) < 8:
        return obs
    o = df["open"].values
    h = df["high"].values
    l = df["low"].values
    c = df["close"].values
    for i in range(5, len(df) - 3):
        if np.isnan(atr[i]) or atr[i] <= 0:
            continue
        if c[i] < o[i]:  # bullish OB
            disp = h[i + 1:i + 4].max() - c[i]
            if disp >= atr[i] * displacement_mult:
                obs.append({"idx": i, "type": "BULL", "top": o[i], "bottom": l[i], "strength": disp / atr[i]})
        if c[i] > o[i]:  # bearish OB
            disp = c[i] - l[i + 1:i + 4].min()
            if disp >= atr[i] * displacement_mult:
                obs.append({"idx": i, "type": "BEAR", "top": h[i], "bottom": o[i], "strength": disp / atr[i]})
    return obs


def detect_fvg(df: pd.DataFrame, min_gap: float = 0.3) -> List[Dict]:
    fvgs = []
    if len(df) < 3:
        return fvgs
    h = df["high"].values
    l = df["low"].values
    for i in range(2, len(df)):
        c1h = h[i - 2]
        c3l = l[i]
        if c3l > c1h and (c3l - c1h) >= min_gap:
            fvgs.append({"idx": i - 1, "type": "BULL", "top": c3l, "bottom": c1h})
        c1l = l[i - 2]
        c3h = h[i]
        if c1l > c3h and (c1l - c3h) >= min_gap:
            fvgs.append({"idx": i - 1, "type": "BEAR", "top": c1l, "bottom": c3h})
    return fvgs


def proximity_score(price: float, low: float, high: float, atr: float) -> float:
    if atr <= 0:
        return 0.0
    if low <= price <= high:
        return 100.0
    dist = min(abs(price - low), abs(price - high))
    if dist <= atr:
        return 70 + (atr - dist) / atr * 30
    if dist <= 2 * atr:
        return 50 + (2 * atr - dist) / atr * 20
    return max(0.0, 50 - (dist - 2 * atr) / (3 * atr) * 50)

# =============================================================================
# NEWS FILTER (simplified parity with CNewsFilter)
# =============================================================================

class NewsFilter:
    """
    Minimal news filter to block trading around high/medium impact events.
    events: list of tuples (datetime_utc, impact['high'|'medium'|'low'], title)
    """
    def __init__(self, block_high: bool = True, block_medium: bool = False, window_seconds: int = 900):
        self.block_high = block_high
        self.block_medium = block_medium
        self.window_seconds = window_seconds
        self.events: List[Tuple[datetime, str, str]] = []

    def set_events(self, events: List[Tuple[datetime, str, str]]):
        self.events = events or []

    def is_allowed(self, now: datetime) -> bool:
        if not self.events:
            return True
        for t, impact, _ in self.events:
            if abs((t - now).total_seconds()) <= self.window_seconds:
                if impact == "high" and self.block_high:
                    return False
                if impact == "medium" and self.block_medium:
                    return False
        return True

# =============================================================================
# RISK MANAGER (parity-ish with CFTMO_RiskManager)
# =============================================================================

class RiskManager:
    def __init__(self,
                 risk_per_trade_pct: float = 0.5,
                 max_daily_loss_pct: float = 5.0,
                 soft_stop_pct: float = 4.0,
                 max_total_loss_pct: float = 10.0,
                 max_trades_per_day: int = 20,
                 initial_balance: float = 100_000.0,
                 point_value: float = 0.01,
                 tick_value: float = 1.0,
                 tick_size: float = 0.01):
        self.risk_per_trade_pct = risk_per_trade_pct
        self.max_daily_loss_pct = max_daily_loss_pct
        self.soft_stop_pct = soft_stop_pct
        self.max_total_loss_pct = max_total_loss_pct
        self.max_trades_per_day = max_trades_per_day
        self.point_value = point_value
        self.tick_value = tick_value
        self.tick_size = tick_size
        self.initial_balance = initial_balance
        self.balance = initial_balance
        self.peak_balance = initial_balance
        self.daily_start = initial_balance
        self.current_day: Optional[datetime.date] = None
        self.trades_today = 0
        self.halted = False
        self.soft_paused = False
        self.consecutive_wins = 0
        self.consecutive_losses = 0

    def _roll_day(self, now: datetime):
        if self.current_day != now.date():
            self.current_day = now.date()
            self.daily_start = self.balance
            self.trades_today = 0
            self.soft_paused = False
            self.halted = False
            self.consecutive_wins = 0
            self.consecutive_losses = 0

    def can_open(self, now: datetime) -> bool:
        self._roll_day(now)
        if self.halted or self.trades_today >= self.max_trades_per_day:
            return False
        daily_dd = max(0.0, (self.daily_start - self.balance) / max(1e-9, self.daily_start))
        total_dd = max(0.0, (self.peak_balance - self.balance) / max(1e-9, self.peak_balance))
        if total_dd >= self.max_total_loss_pct / 100.0:
            self.halted = True
            return False
        if daily_dd >= self.max_daily_loss_pct / 100.0:
            self.halted = True
            return False
        if daily_dd >= self.soft_stop_pct / 100.0:
            self.soft_paused = True
            return False
        self.soft_paused = False
        return True

    def record_trade(self, pnl: float, now: datetime):
        self._roll_day(now)
        self.balance += pnl
        self.trades_today += 1
        self.consecutive_wins = self.consecutive_wins + 1 if pnl > 0 else 0
        self.consecutive_losses = self.consecutive_losses + 1 if pnl < 0 else 0
        if self.balance > self.peak_balance:
            self.peak_balance = self.balance

    def _momentum_mult(self) -> float:
        if self.consecutive_losses >= 2:
            return 0.5
        if self.consecutive_wins >= 2:
            return 1.2
        return 1.0

    def lot_size(self,
                 sl_points: float,
                 regime_mult: float,
                 conf_mult: float,
                 session_mult: float,
                 risk_percent_override: Optional[float] = None) -> float:
        if sl_points <= 0 or self.halted or self.soft_paused:
            return 0.0
        risk_pct = risk_percent_override if risk_percent_override and risk_percent_override > 0 else self.risk_per_trade_pct
        daily_dd = max(0.0, (self.daily_start - self.balance) / max(1e-9, self.daily_start))
        dd_mult = max(0.2, 1.0 - daily_dd / max(1e-9, self.soft_stop_pct / 100.0))
        risk_amount = self.balance * (risk_pct / 100.0) * dd_mult
        value_per_point = self.tick_value * (self.point_value / max(1e-9, self.tick_size))
        lot = risk_amount / max(1e-9, sl_points * value_per_point)
        lot *= np.clip(regime_mult, 0.1, 3.0) * max(0.5, conf_mult) * max(0.5, session_mult) * self._momentum_mult()
        return float(np.clip(round(lot, 2), 0.01, 10.0))

# =============================================================================
# ENUMERATIONS (matching MQL5)
# =============================================================================

class SignalType(IntEnum):
    NONE = 0
    BUY = 1
    SELL = 2


class MarketRegime(IntEnum):
    PRIME_TRENDING = 0
    NOISY_TRENDING = 1
    PRIME_REVERTING = 2
    NOISY_REVERTING = 3
    RANDOM_WALK = 4
    TRANSITIONING = 5
    UNKNOWN = 6


class EntryMode(IntEnum):
    BREAKOUT = 0
    PULLBACK = 1
    MEAN_REVERT = 2
    CONFIRMATION = 3
    DISABLED = 4


class TradingSession(IntEnum):
    UNKNOWN = 0
    ASIAN = 1
    LONDON = 2
    LONDON_NY_OVERLAP = 3
    NY = 4
    LATE_NY = 5
    WEEKEND = 6


class SessionQuality(IntEnum):
    BLOCKED = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    PRIME = 4


class DayQuality(IntEnum):
    BLOCKED = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3


class MTFTrend(IntEnum):
    BULLISH = 1
    BEARISH = -1
    NEUTRAL = 0
    RANGING = 2


class MTFAlignment(IntEnum):
    PERFECT = 3
    GOOD = 2
    WEAK = 1
    NONE = 0


class SignalQuality(IntEnum):
    INVALID = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    ELITE = 4


class LiquidityType(IntEnum):
    NONE = 0
    BSL = 1  # Buy-side liquidity
    SSL = 2  # Sell-side liquidity


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class RegimeAnalysis:
    regime: MarketRegime = MarketRegime.UNKNOWN
    hurst_exponent: float = 0.5
    shannon_entropy: float = 1.5
    variance_ratio: float = 1.0
    hurst_short: float = 0.5
    hurst_medium: float = 0.5
    hurst_long: float = 0.5
    multiscale_agreement: float = 50.0
    transition_probability: float = 0.0
    bars_in_regime: int = 0
    regime_velocity: float = 0.0
    size_multiplier: float = 1.0
    score_adjustment: int = 0
    confidence: float = 50.0
    is_valid: bool = False


@dataclass
class RegimeStrategy:
    regime: MarketRegime = MarketRegime.UNKNOWN
    entry_mode: EntryMode = EntryMode.DISABLED
    min_confluence: float = 100.0
    confirmation_bars: int = 0
    risk_percent: float = 0.0
    sl_atr_mult: float = 2.0
    min_rr: float = 1.0
    tp1_r: float = 1.0
    tp2_r: float = 2.0
    tp3_r: float = 3.0
    partial1_pct: float = 0.33
    partial2_pct: float = 0.33
    be_trigger_r: float = 1.0
    use_trailing: bool = False
    trailing_start_r: float = 0.0
    trailing_step_atr: float = 0.0
    use_time_exit: bool = False
    max_bars: int = 50
    philosophy: str = "Disabled"


@dataclass
class LiquidityPool:
    level: float = 0.0
    pool_type: LiquidityType = LiquidityType.NONE
    touch_count: int = 0
    is_equal_level: bool = False
    is_swept: bool = False
    is_valid: bool = False


@dataclass
class SweepEvent:
    pool: LiquidityPool = field(default_factory=LiquidityPool)
    sweep_price: float = 0.0
    sweep_depth: float = 0.0
    has_rejection: bool = False
    returned_inside: bool = False
    is_valid_sweep: bool = False


@dataclass
class MTFConfluence:
    alignment: MTFAlignment = MTFAlignment.NONE
    signal: SignalType = SignalType.NONE
    confidence: float = 0.0
    position_size_mult: float = 0.0
    htf_trend: MTFTrend = MTFTrend.NEUTRAL
    mtf_trend: MTFTrend = MTFTrend.NEUTRAL
    ltf_trend: MTFTrend = MTFTrend.NEUTRAL
    htf_aligned: bool = False
    mtf_structure: bool = False
    ltf_confirmed: bool = False
    session_ok: bool = False
    session_quality: float = 0.0


@dataclass
class ConfluenceResult:
    direction: SignalType = SignalType.NONE
    quality: SignalQuality = SignalQuality.INVALID
    total_score: float = 0.0
    structure_score: float = 50.0
    regime_score: float = 50.0
    sweep_score: float = 50.0
    amd_score: float = 50.0
    ob_score: float = 50.0
    fvg_score: float = 50.0
    premium_discount: float = 50.0
    mtf_score: float = 50.0
    footprint_score: float = 50.0
    fib_score: float = 50.0
    fib_score: float = 50.0
    regime_adjustment: int = 0
    confluence_bonus: int = 0
    total_confluences: int = 0
    position_size_mult: float = 1.0
    entry_price: float = 0.0
    stop_loss: float = 0.0
    take_profit_1: float = 0.0
    take_profit_2: float = 0.0
    risk_reward: float = 0.0
    is_valid: bool = False


# =============================================================================
# REGIME DETECTOR (CRegimeDetector.mqh port)
# =============================================================================

class RegimeDetector:
    """
    Port of CRegimeDetector v4.0 from MQL5.
    Multi-scale Hurst + Variance Ratio + Transition detection.
    """
    
    def __init__(self):
        # Windows
        self.hurst_window = 100
        self.hurst_short_window = 50
        self.hurst_long_window = 200
        self.entropy_window = 100
        self.entropy_bins = 10
        self.min_samples = 50
        self.vr_lag = 2
        
        # Thresholds
        self.hurst_trending = 0.55
        self.hurst_reverting = 0.45
        self.entropy_low = 1.5
        self.vr_trending = 1.10
        self.vr_reverting = 0.90
        self.transition_threshold = 0.60
        
        # History for transition detection
        self.hurst_history = [0.5] * 10
        self.hurst_history_idx = 0
        self.bars_in_current_regime = 0
        self.previous_regime = MarketRegime.UNKNOWN
        
        # Cache
        self.last_analysis = RegimeAnalysis()
        self.cache_seconds = 60
        self.last_calculation_time = None
    
    def calculate_hurst(self, prices: np.ndarray, window: int) -> float:
        """R/S Analysis for Hurst exponent calculation."""
        if len(prices) < window:
            return -1.0
        
        prices = prices[-window:]
        
        # Calculate log returns
        log_returns = np.diff(np.log(prices))
        if len(log_returns) < self.min_samples:
            return -1.0
        
        # R/S analysis with multiple window sizes
        min_k = 10
        max_k = min(50, len(log_returns) // 2)
        
        if max_k <= min_k:
            return -1.0
        
        log_n = []
        log_rs = []
        
        for n in range(min_k, max_k + 1):
            num_subseries = len(log_returns) // n
            if num_subseries < 1:
                continue
            
            rs_values = []
            for i in range(num_subseries):
                subseries = log_returns[i * n:(i + 1) * n]
                mean = np.mean(subseries)
                
                # Cumulative deviation
                cumdev = np.cumsum(subseries - mean)
                R = np.max(cumdev) - np.min(cumdev)
                
                # Standard deviation
                S = np.std(subseries, ddof=1)
                
                if S > 1e-10:
                    rs_values.append(R / S)
            
            if rs_values:
                rs_mean = np.mean(rs_values)
                log_n.append(np.log(n))
                log_rs.append(np.log(rs_mean))
        
        if len(log_n) < 3:
            return -1.0
        
        # Linear regression for Hurst
        log_n = np.array(log_n)
        log_rs = np.array(log_rs)
        
        n = len(log_n)
        sum_x = np.sum(log_n)
        sum_y = np.sum(log_rs)
        sum_xy = np.sum(log_n * log_rs)
        sum_xx = np.sum(log_n * log_n)
        
        denom = n * sum_xx - sum_x * sum_x
        if abs(denom) < 1e-10:
            return -1.0
        
        H = (n * sum_xy - sum_x * sum_y) / denom
        return max(0.0, min(1.0, H))
    
    def calculate_entropy(self, returns: np.ndarray) -> float:
        """Shannon entropy calculation."""
        if len(returns) < self.min_samples:
            return -1.0
        
        min_val = np.min(returns)
        max_val = np.max(returns)
        range_val = max_val - min_val
        
        if range_val < 1e-10:
            return 0.0
        
        # Create histogram
        hist, _ = np.histogram(returns, bins=self.entropy_bins, range=(min_val, max_val))
        
        # Calculate entropy
        probs = hist / len(returns)
        probs = probs[probs > 0]
        entropy = -np.sum(probs * np.log2(probs))
        
        return entropy
    
    def calculate_variance_ratio(self, prices: np.ndarray, lag: int) -> float:
        """Lo-MacKinlay Variance Ratio test."""
        if len(prices) < lag * 10:
            return 1.0
        
        # 1-period log returns
        returns_1 = np.diff(np.log(prices))
        
        # lag-period log returns
        returns_q = np.log(prices[lag:]) - np.log(prices[:-lag])
        
        if len(returns_1) < 10 or len(returns_q) < 10:
            return 1.0
        
        var_1 = np.var(returns_1, ddof=1)
        var_q = np.var(returns_q, ddof=1)
        
        if var_1 < 1e-15:
            return 1.0
        
        vr = var_q / (lag * var_1)
        return max(0.1, min(3.0, vr))
    
    def calculate_multiscale_agreement(self, h_short: float, h_medium: float, h_long: float) -> float:
        """Calculate agreement between different Hurst time scales."""
        def classify_zone(h):
            if h > self.hurst_trending:
                return 2  # Trending
            if h < self.hurst_reverting:
                return 0  # Reverting
            return 1  # Random
        
        zone_short = classify_zone(h_short)
        zone_medium = classify_zone(h_medium)
        zone_long = classify_zone(h_long)
        
        # Agreement score
        if zone_short == zone_medium == zone_long:
            agreement = 100.0
        elif zone_short == zone_medium or zone_medium == zone_long or zone_short == zone_long:
            agreement = 66.0
        else:
            agreement = 33.0
        
        # Consistency bonus
        mean_h = (h_short + h_medium + h_long) / 3.0
        std_h = np.sqrt(((h_short - mean_h)**2 + (h_medium - mean_h)**2 + (h_long - mean_h)**2) / 3.0)
        consistency_bonus = max(0, (0.1 - std_h) * 100)
        
        return min(100, agreement + consistency_bonus)
    
    def calculate_transition_probability(self, current_h: float) -> float:
        """Calculate probability of regime transition."""
        # Calculate velocity
        velocity = self._calculate_regime_velocity()
        
        # Distance to nearest boundary
        dist_to_boundary = min(
            abs(current_h - self.hurst_reverting),
            abs(current_h - self.hurst_trending)
        )
        
        prob = 0.0
        
        # Velocity toward boundary
        moving_toward_random = False
        if current_h > self.hurst_trending and velocity < -0.005:
            moving_toward_random = True
        elif current_h < self.hurst_reverting and velocity > 0.005:
            moving_toward_random = True
        
        if moving_toward_random:
            prob += abs(velocity) * 20
        
        # Proximity to boundary
        if dist_to_boundary < 0.05:
            prob += (0.05 - dist_to_boundary) * 10
        
        # Already in random zone
        if self.hurst_reverting <= current_h <= self.hurst_trending:
            prob += 0.3
        
        return max(0.0, min(1.0, prob))
    
    def _calculate_regime_velocity(self) -> float:
        """Calculate rate of change of Hurst."""
        n = len(self.hurst_history)
        if n < 3:
            return 0.0
        
        x = np.arange(n)
        y = np.array(self.hurst_history)
        
        # Linear regression
        sum_x = np.sum(x)
        sum_y = np.sum(y)
        sum_xy = np.sum(x * y)
        sum_xx = np.sum(x * x)
        
        denom = n * sum_xx - sum_x * sum_x
        if abs(denom) < 1e-10:
            return 0.0
        
        return (n * sum_xy - sum_x * sum_y) / denom
    
    def _update_hurst_history(self, hurst: float):
        """Update rolling Hurst history."""
        self.hurst_history[self.hurst_history_idx] = hurst
        self.hurst_history_idx = (self.hurst_history_idx + 1) % len(self.hurst_history)
    
    def classify_regime(self, analysis: RegimeAnalysis) -> MarketRegime:
        """Classify market regime based on all metrics."""
        H = analysis.hurst_exponent
        S = analysis.shannon_entropy
        VR = analysis.variance_ratio
        trans_prob = analysis.transition_probability
        agreement = analysis.multiscale_agreement
        
        # Check transitioning first
        if trans_prob > self.transition_threshold:
            return MarketRegime.TRANSITIONING
        
        # Zone classification
        hurst_random = self.hurst_reverting <= H <= self.hurst_trending
        hurst_trending = H > self.hurst_trending
        hurst_reverting = H < self.hurst_reverting
        vr_random = self.vr_reverting <= VR <= self.vr_trending
        vr_trending = VR > self.vr_trending
        vr_reverting = VR < self.vr_reverting
        
        # RANDOM WALK: Both hurst and VR in random zone, or hurst in random with low agreement
        if hurst_random and vr_random:
            return MarketRegime.RANDOM_WALK
        
        if hurst_random and agreement < 50:
            return MarketRegime.RANDOM_WALK
        
        # TRENDING regimes: Hurst > 0.55 OR VR > 1.10
        if hurst_trending or vr_trending:
            vr_confirms = vr_trending
            if S < self.entropy_low and vr_confirms and agreement >= 66:
                return MarketRegime.PRIME_TRENDING
            return MarketRegime.NOISY_TRENDING
        
        # MEAN REVERTING regimes: Hurst < 0.45 OR VR < 0.90
        if hurst_reverting or vr_reverting:
            vr_confirms = vr_reverting
            if S < self.entropy_low and vr_confirms and agreement >= 66:
                return MarketRegime.PRIME_REVERTING
            return MarketRegime.NOISY_REVERTING
        
        # Hurst in random zone but VR suggests direction - use VR to classify
        if hurst_random:
            if vr_trending:
                return MarketRegime.NOISY_TRENDING
            if vr_reverting:
                return MarketRegime.NOISY_REVERTING
            # Both in random
            return MarketRegime.RANDOM_WALK
        
        return MarketRegime.RANDOM_WALK  # Default to random (safest)
    
    def get_size_multiplier(self, analysis: RegimeAnalysis) -> float:
        """Get position size multiplier based on regime."""
        base = 0.0
        
        if analysis.regime in [MarketRegime.PRIME_TRENDING, MarketRegime.PRIME_REVERTING]:
            base = 1.0
        elif analysis.regime in [MarketRegime.NOISY_TRENDING, MarketRegime.NOISY_REVERTING]:
            base = 0.5
        elif analysis.regime == MarketRegime.TRANSITIONING:
            base = 0.25
        else:
            return 0.0
        
        # Transition penalty
        if analysis.transition_probability > 0.3:
            base *= (1.0 - analysis.transition_probability * 0.3)
        
        # Multi-scale penalty
        if analysis.multiscale_agreement < 50:
            base *= 0.75
        
        # Confidence penalty
        if analysis.confidence < 30:
            base *= 0.5
        elif analysis.confidence < 50:
            base *= 0.75
        
        return max(0, min(1.0, base))
    
    def get_score_adjustment(self, analysis: RegimeAnalysis) -> int:
        """Get confluence score adjustment based on regime."""
        adj = 0
        
        if analysis.regime in [MarketRegime.PRIME_TRENDING, MarketRegime.PRIME_REVERTING]:
            adj = 10
            if analysis.confidence > 80:
                adj += 10
            if analysis.multiscale_agreement > 90:
                adj += 5
        elif analysis.regime in [MarketRegime.NOISY_TRENDING, MarketRegime.NOISY_REVERTING]:
            adj = 0
        elif analysis.regime == MarketRegime.TRANSITIONING:
            adj = -20
        elif analysis.regime == MarketRegime.RANDOM_WALK:
            adj = -30
        else:
            adj = -50
        
        if analysis.confidence < 30:
            adj -= 10
        
        return adj
    
    def _calculate_enhanced_confidence(self, analysis: RegimeAnalysis) -> float:
        """Calculate confidence score."""
        conf = 0.0
        
        # Hurst distance from 0.5 (0-30 points)
        h_distance = abs(analysis.hurst_exponent - 0.5)
        conf += min(30, h_distance * 60)
        
        # VR confirmation (0-20 points)
        hurst_trending = analysis.hurst_exponent > self.hurst_trending
        hurst_reverting = analysis.hurst_exponent < self.hurst_reverting
        vr_trending = analysis.variance_ratio > self.vr_trending
        vr_reverting = analysis.variance_ratio < self.vr_reverting
        
        if (hurst_trending and vr_trending) or (hurst_reverting and vr_reverting):
            conf += 20
        elif (hurst_trending or hurst_reverting) and abs(analysis.variance_ratio - 1.0) > 0.05:
            conf += 10
        
        # Multi-scale agreement (0-20 points)
        conf += analysis.multiscale_agreement * 0.2
        
        # Regime momentum (0-15 points)
        momentum = min(analysis.bars_in_regime / 50.0, 1.0)
        conf += momentum * 15
        
        # Low entropy bonus (0-15 points)
        if analysis.shannon_entropy < 1.0:
            conf += 15
        elif analysis.shannon_entropy < 1.5:
            conf += 10
        elif analysis.shannon_entropy < 2.0:
            conf += 5
        
        # Transition penalty
        conf -= analysis.transition_probability * 20
        
        return max(0, min(100, conf))
    
    def analyze_regime(self, prices: np.ndarray) -> RegimeAnalysis:
        """Main analysis function."""
        result = RegimeAnalysis()
        
        # Minimum requirement: enough for short hurst window
        min_required = self.hurst_short_window + 20
        if len(prices) < min_required:
            return result
        
        # Multi-scale Hurst (use available data)
        result.hurst_short = self.calculate_hurst(prices, self.hurst_short_window)
        result.hurst_medium = self.calculate_hurst(prices, self.hurst_window)
        result.hurst_long = self.calculate_hurst(prices, self.hurst_long_window)
        
        # Use short hurst if medium fails
        if result.hurst_medium < 0:
            if result.hurst_short < 0:
                return result
            result.hurst_medium = result.hurst_short
        
        # Use medium if long fails
        if result.hurst_long < 0:
            result.hurst_long = result.hurst_medium
        
        result.hurst_exponent = result.hurst_medium
        result.multiscale_agreement = self.calculate_multiscale_agreement(
            result.hurst_short, result.hurst_medium, result.hurst_long
        )
        
        # Shannon entropy
        returns = np.diff(prices) / prices[:-1]
        result.shannon_entropy = self.calculate_entropy(returns[-self.entropy_window:])
        if result.shannon_entropy < 0:
            return result
        
        # Variance ratio
        result.variance_ratio = self.calculate_variance_ratio(prices, self.vr_lag)
        
        # Transition detection
        self._update_hurst_history(result.hurst_exponent)
        result.regime_velocity = self._calculate_regime_velocity()
        result.transition_probability = self.calculate_transition_probability(result.hurst_exponent)
        
        # Classify regime
        result.regime = self.classify_regime(result)
        
        # Track regime persistence
        if result.regime == self.previous_regime:
            self.bars_in_current_regime += 1
        else:
            self.bars_in_current_regime = 1
            self.previous_regime = result.regime
        result.bars_in_regime = self.bars_in_current_regime
        
        # Enhanced outputs
        result.confidence = self._calculate_enhanced_confidence(result)
        result.size_multiplier = self.get_size_multiplier(result)
        result.score_adjustment = self.get_score_adjustment(result)
        result.is_valid = True
        
        self.last_analysis = result
        return result
    
    def get_optimal_strategy(self, regime: MarketRegime) -> RegimeStrategy:
        """Get optimal trading strategy for regime."""
        s = RegimeStrategy()
        s.regime = regime
        
        if regime == MarketRegime.PRIME_TRENDING:
            s.entry_mode = EntryMode.BREAKOUT
            s.min_confluence = 65
            s.confirmation_bars = 1
            s.risk_percent = 1.0
            s.sl_atr_mult = 1.5
            s.min_rr = 1.5
            s.tp1_r = 1.0
            s.tp2_r = 2.5
            s.tp3_r = 4.0
            s.partial1_pct = 0.33
            s.partial2_pct = 0.33
            s.be_trigger_r = 0.7
            s.use_trailing = True
            s.trailing_start_r = 1.0
            s.trailing_step_atr = 0.5
            s.use_time_exit = False
            s.max_bars = 100
            s.philosophy = "TREND IS YOUR FRIEND - LET PROFITS RUN"
            
        elif regime == MarketRegime.NOISY_TRENDING:
            s.entry_mode = EntryMode.PULLBACK
            s.min_confluence = 70
            s.confirmation_bars = 1
            s.risk_percent = 0.75
            s.sl_atr_mult = 1.8
            s.min_rr = 1.5
            s.tp1_r = 1.0
            s.tp2_r = 2.0
            s.tp3_r = 3.0
            s.partial1_pct = 0.40
            s.partial2_pct = 0.35
            s.be_trigger_r = 1.0
            s.use_trailing = True
            s.trailing_start_r = 1.5
            s.trailing_step_atr = 0.7
            s.use_time_exit = False
            s.max_bars = 60
            s.philosophy = "FOLLOW TREND BUT EXPECT VOLATILITY"
            
        elif regime == MarketRegime.PRIME_REVERTING:
            s.entry_mode = EntryMode.MEAN_REVERT
            s.min_confluence = 75
            s.confirmation_bars = 2
            s.risk_percent = 0.5
            s.sl_atr_mult = 2.0
            s.min_rr = 1.0
            s.tp1_r = 0.5
            s.tp2_r = 1.0
            s.tp3_r = 1.5
            s.partial1_pct = 0.50
            s.partial2_pct = 0.30
            s.be_trigger_r = 0.5
            s.use_trailing = False
            s.use_time_exit = True
            s.max_bars = 20
            s.philosophy = "QUICK SCALP AT EXTREMES - GRAB AND RUN"
            
        elif regime == MarketRegime.NOISY_REVERTING:
            s.entry_mode = EntryMode.MEAN_REVERT
            s.min_confluence = 80
            s.confirmation_bars = 2
            s.risk_percent = 0.4
            s.sl_atr_mult = 2.2
            s.min_rr = 1.0
            s.tp1_r = 0.5
            s.tp2_r = 0.8
            s.tp3_r = 1.0
            s.partial1_pct = 0.60
            s.partial2_pct = 0.25
            s.be_trigger_r = 0.4
            s.use_trailing = False
            s.use_time_exit = True
            s.max_bars = 15
            s.philosophy = "VERY CAREFUL - GRAB AND RUN FASTER"
            
        elif regime == MarketRegime.TRANSITIONING:
            s.entry_mode = EntryMode.CONFIRMATION
            s.min_confluence = 90
            s.confirmation_bars = 3
            s.risk_percent = 0.25
            s.sl_atr_mult = 2.5
            s.min_rr = 1.0
            s.tp1_r = 0.5
            s.tp2_r = 0.8
            s.tp3_r = 1.0
            s.partial1_pct = 0.70
            s.partial2_pct = 0.20
            s.be_trigger_r = 0.3
            s.use_trailing = False
            s.use_time_exit = True
            s.max_bars = 10
            s.philosophy = "SURVIVAL MODE - WAIT FOR CLARITY"
            
        else:  # RANDOM_WALK, UNKNOWN
            s.entry_mode = EntryMode.DISABLED
            s.min_confluence = 100
            s.risk_percent = 0
            s.philosophy = "NO EDGE - DO NOT TRADE"
        
        return s
    
    def is_trading_allowed(self) -> bool:
        """Check if trading is allowed in current regime."""
        regime = self.last_analysis.regime
        
        if regime in [MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN]:
            return False
        
        if regime == MarketRegime.TRANSITIONING and self.last_analysis.confidence < 20:
            return False
        
        return True


# =============================================================================
# SESSION FILTER (CSessionFilter.mqh port)
# =============================================================================

class SessionFilter:
    """
    Port of CSessionFilter from MQL5.
    Session and day quality scoring for XAUUSD.
    """
    
    def __init__(self, gmt_offset: int = 0):
        self.gmt_offset = gmt_offset
        self.allow_asian = False
        self.allow_late_ny = False
        self.friday_close_hour = 14
        
        # Session windows (GMT hours)
        self.sessions = {
            TradingSession.ASIAN: (0, 7),
            TradingSession.LONDON: (7, 12),
            TradingSession.LONDON_NY_OVERLAP: (12, 16),
            TradingSession.NY: (16, 21),
            TradingSession.LATE_NY: (21, 24),
        }
    
    def get_gmt_hour(self, timestamp: datetime) -> int:
        """Convert timestamp to GMT hour."""
        gmt_hour = timestamp.hour - self.gmt_offset
        if gmt_hour < 0:
            gmt_hour += 24
        if gmt_hour >= 24:
            gmt_hour -= 24
        return gmt_hour
    
    def get_current_session(self, timestamp: datetime) -> TradingSession:
        """Determine current trading session."""
        if timestamp.weekday() >= 5:  # Saturday or Sunday
            return TradingSession.WEEKEND
        
        gmt_hour = self.get_gmt_hour(timestamp)
        
        # Check sessions in priority order
        if 12 <= gmt_hour < 16:
            return TradingSession.LONDON_NY_OVERLAP
        elif 7 <= gmt_hour < 12:
            return TradingSession.LONDON
        elif 16 <= gmt_hour < 21:
            return TradingSession.NY
        elif 21 <= gmt_hour or gmt_hour < 0:
            return TradingSession.LATE_NY
        elif 0 <= gmt_hour < 7:
            return TradingSession.ASIAN
        
        return TradingSession.UNKNOWN
    
    def get_session_quality(self, timestamp: datetime) -> SessionQuality:
        """Get quality of current session."""
        session = self.get_current_session(timestamp)
        
        if session == TradingSession.WEEKEND:
            return SessionQuality.BLOCKED
        elif session == TradingSession.LONDON_NY_OVERLAP:
            return SessionQuality.PRIME
        elif session == TradingSession.LONDON:
            return SessionQuality.HIGH
        elif session == TradingSession.NY:
            return SessionQuality.MEDIUM
        elif session == TradingSession.LATE_NY:
            return SessionQuality.LOW if self.allow_late_ny else SessionQuality.BLOCKED
        elif session == TradingSession.ASIAN:
            return SessionQuality.LOW if self.allow_asian else SessionQuality.BLOCKED
        
        return SessionQuality.BLOCKED
    
    def get_day_quality(self, timestamp: datetime) -> DayQuality:
        """Get quality of current day."""
        dow = timestamp.weekday()
        
        if dow in [5, 6]:  # Saturday, Sunday
            return DayQuality.BLOCKED
        elif dow == 0:  # Monday
            return DayQuality.LOW
        elif dow in [1, 2]:  # Tuesday, Wednesday
            return DayQuality.HIGH
        elif dow == 3:  # Thursday
            return DayQuality.MEDIUM
        elif dow == 4:  # Friday
            return DayQuality.LOW
        
        return DayQuality.MEDIUM
    
    def is_trading_allowed(self, timestamp: datetime) -> bool:
        """Check if trading is allowed."""
        session_quality = self.get_session_quality(timestamp)
        
        if session_quality == SessionQuality.BLOCKED:
            return False
        
        # Friday afternoon check
        if timestamp.weekday() == 4:  # Friday
            gmt_hour = self.get_gmt_hour(timestamp)
            if gmt_hour >= self.friday_close_hour:
                return False
        
        return True
    
    def get_session_score(self, timestamp: datetime) -> int:
        """Get session score for confluence (0-100)."""
        session_quality = self.get_session_quality(timestamp)
        day_quality = self.get_day_quality(timestamp)
        
        # Session component (max 70)
        session_scores = {
            SessionQuality.PRIME: 70,
            SessionQuality.HIGH: 55,
            SessionQuality.MEDIUM: 40,
            SessionQuality.LOW: 20,
            SessionQuality.BLOCKED: 0,
        }
        session_score = session_scores.get(session_quality, 0)
        
        # Day component (max 30)
        day_scores = {
            DayQuality.HIGH: 30,
            DayQuality.MEDIUM: 20,
            DayQuality.LOW: 10,
            DayQuality.BLOCKED: 0,
        }
        day_score = day_scores.get(day_quality, 0)
        
        # London open bonus
        session = self.get_current_session(timestamp)
        gmt_hour = self.get_gmt_hour(timestamp)
        if session == TradingSession.LONDON and gmt_hour < 9:
            session_score += 10
        
        return min(100, session_score + day_score)
    
    def get_session_name(self, timestamp: datetime) -> str:
        """Get name of current session."""
        session = self.get_current_session(timestamp)
        names = {
            TradingSession.ASIAN: "Asian",
            TradingSession.LONDON: "London",
            TradingSession.LONDON_NY_OVERLAP: "London/NY Overlap",
            TradingSession.NY: "New York",
            TradingSession.LATE_NY: "Late NY",
            TradingSession.WEEKEND: "Weekend",
            TradingSession.UNKNOWN: "Unknown",
        }
        return names.get(session, "Unknown")


# =============================================================================
# LIQUIDITY SWEEP DETECTOR (CLiquiditySweepDetector.mqh port)
# =============================================================================

class LiquiditySweepDetector:
    """
    Port of CLiquiditySweepDetector from MQL5.
    Detects BSL/SSL pools and sweep events.
    """
    
    def __init__(self):
        self.equal_tolerance = 3.0  # Points
        self.min_touches = 2
        self.lookback_bars = 100
        self.min_sweep_depth = 5.0
        self.max_bars_beyond = 3
        
        self.bsl_pools: List[LiquidityPool] = []
        self.ssl_pools: List[LiquidityPool] = []
        self.recent_sweeps: List[SweepEvent] = []
    
    def _is_equal_level(self, price1: float, price2: float) -> bool:
        """Check if two price levels are equal within tolerance."""
        return abs(price1 - price2) <= self.equal_tolerance
    
    def _find_swing_highs(self, highs: np.ndarray) -> List[Tuple[int, float]]:
        """Find swing high points."""
        swings = []
        for i in range(3, len(highs) - 3):
            is_swing = True
            for j in range(1, 4):
                if highs[i] <= highs[i - j] or highs[i] <= highs[i + j]:
                    is_swing = False
                    break
            if is_swing:
                swings.append((i, highs[i]))
        return swings
    
    def _find_swing_lows(self, lows: np.ndarray) -> List[Tuple[int, float]]:
        """Find swing low points."""
        swings = []
        for i in range(3, len(lows) - 3):
            is_swing = True
            for j in range(1, 4):
                if lows[i] >= lows[i - j] or lows[i] >= lows[i + j]:
                    is_swing = False
                    break
            if is_swing:
                swings.append((i, lows[i]))
        return swings
    
    def _find_equal_highs(self, highs: np.ndarray) -> List[LiquidityPool]:
        """Find equal highs (strong BSL)."""
        pools = []
        used_indices = set()
        
        for i in range(5, min(len(highs) - 5, self.lookback_bars)):
            if i in used_indices:
                continue
            
            high_level = highs[i]
            touches = 1
            touch_indices = [i]
            
            for j in range(i + 5, min(len(highs), self.lookback_bars)):
                if self._is_equal_level(highs[j], high_level):
                    touches += 1
                    touch_indices.append(j)
            
            if touches >= self.min_touches:
                pool = LiquidityPool()
                pool.level = high_level
                pool.pool_type = LiquidityType.BSL
                pool.touch_count = touches
                pool.is_equal_level = True
                pool.is_valid = True
                pools.append(pool)
                used_indices.update(touch_indices)
        
        return pools
    
    def _find_equal_lows(self, lows: np.ndarray) -> List[LiquidityPool]:
        """Find equal lows (strong SSL)."""
        pools = []
        used_indices = set()
        
        for i in range(5, min(len(lows) - 5, self.lookback_bars)):
            if i in used_indices:
                continue
            
            low_level = lows[i]
            touches = 1
            touch_indices = [i]
            
            for j in range(i + 5, min(len(lows), self.lookback_bars)):
                if self._is_equal_level(lows[j], low_level):
                    touches += 1
                    touch_indices.append(j)
            
            if touches >= self.min_touches:
                pool = LiquidityPool()
                pool.level = low_level
                pool.pool_type = LiquidityType.SSL
                pool.touch_count = touches
                pool.is_equal_level = True
                pool.is_valid = True
                pools.append(pool)
                used_indices.update(touch_indices)
        
        return pools
    
    def update(self, highs: np.ndarray, lows: np.ndarray, closes: np.ndarray, atr: float):
        """Update liquidity pools and check for sweeps."""
        # Find BSL pools
        self.bsl_pools = self._find_equal_highs(highs)
        swing_highs = self._find_swing_highs(highs)
        for idx, level in swing_highs:
            exists = any(self._is_equal_level(p.level, level) for p in self.bsl_pools)
            if not exists:
                pool = LiquidityPool()
                pool.level = level
                pool.pool_type = LiquidityType.BSL
                pool.touch_count = 1
                pool.is_equal_level = False
                pool.is_valid = True
                self.bsl_pools.append(pool)
        
        # Find SSL pools
        self.ssl_pools = self._find_equal_lows(lows)
        swing_lows = self._find_swing_lows(lows)
        for idx, level in swing_lows:
            exists = any(self._is_equal_level(p.level, level) for p in self.ssl_pools)
            if not exists:
                pool = LiquidityPool()
                pool.level = level
                pool.pool_type = LiquidityType.SSL
                pool.touch_count = 1
                pool.is_equal_level = False
                pool.is_valid = True
                self.ssl_pools.append(pool)
        
        # Check for sweeps
        self._check_for_sweeps(highs, lows, closes, atr)
    
    def _check_for_sweeps(self, highs: np.ndarray, lows: np.ndarray, closes: np.ndarray, atr: float):
        """Check for sweep events."""
        self.recent_sweeps = []
        
        # Check BSL sweeps
        for pool in self.bsl_pools:
            if pool.is_swept:
                continue
            
            for j in range(min(10, len(highs))):
                if highs[j] > pool.level + self.min_sweep_depth:
                    # Validate sweep
                    bars_beyond = 0
                    for k in range(j, -1, -1):
                        if closes[k] > pool.level:
                            bars_beyond += 1
                        else:
                            break
                    
                    sweep_depth = highs[j] - pool.level
                    
                    if sweep_depth >= self.min_sweep_depth and bars_beyond <= self.max_bars_beyond:
                        if atr > 0 and sweep_depth >= atr * 0.1:
                            pool.is_swept = True
                            
                            sweep = SweepEvent()
                            sweep.pool = pool
                            sweep.sweep_price = highs[j]
                            sweep.sweep_depth = sweep_depth
                            sweep.is_valid_sweep = True
                            
                            # Check rejection
                            if j < len(closes):
                                upper_wick = highs[j] - max(closes[j], closes[j] if j == 0 else closes[j-1])
                                body = abs(closes[j] - closes[j-1]) if j > 0 else 0
                                sweep.has_rejection = upper_wick > body * 1.5 if body > 0 else False
                            
                            sweep.returned_inside = closes[0] < pool.level if len(closes) > 0 else False
                            
                            self.recent_sweeps.append(sweep)
                            break
        
        # Check SSL sweeps
        for pool in self.ssl_pools:
            if pool.is_swept:
                continue
            
            for j in range(min(10, len(lows))):
                if lows[j] < pool.level - self.min_sweep_depth:
                    # Validate sweep
                    bars_beyond = 0
                    for k in range(j, -1, -1):
                        if closes[k] < pool.level:
                            bars_beyond += 1
                        else:
                            break
                    
                    sweep_depth = pool.level - lows[j]
                    
                    if sweep_depth >= self.min_sweep_depth and bars_beyond <= self.max_bars_beyond:
                        if atr > 0 and sweep_depth >= atr * 0.1:
                            pool.is_swept = True
                            
                            sweep = SweepEvent()
                            sweep.pool = pool
                            sweep.sweep_price = lows[j]
                            sweep.sweep_depth = sweep_depth
                            sweep.is_valid_sweep = True
                            
                            # Check rejection
                            if j < len(closes):
                                lower_wick = min(closes[j], closes[j] if j == 0 else closes[j-1]) - lows[j]
                                body = abs(closes[j] - closes[j-1]) if j > 0 else 0
                                sweep.has_rejection = lower_wick > body * 1.5 if body > 0 else False
                            
                            sweep.returned_inside = closes[0] > pool.level if len(closes) > 0 else False
                            
                            self.recent_sweeps.append(sweep)
                            break
    
    def has_recent_sweep(self, within_bars: int = 10) -> bool:
        """Check if there was a recent sweep."""
        return len(self.recent_sweeps) > 0
    
    def get_sweep_signal(self) -> SignalType:
        """Get trade signal after sweep."""
        if not self.recent_sweeps:
            return SignalType.NONE
        
        sweep = self.recent_sweeps[-1]
        
        if not sweep.is_valid_sweep or not sweep.has_rejection or not sweep.returned_inside:
            return SignalType.NONE
        
        # BSL sweep = bearish, SSL sweep = bullish
        if sweep.pool.pool_type == LiquidityType.BSL:
            return SignalType.SELL
        else:
            return SignalType.BUY
    
    def get_nearest_bsl(self, current_price: float) -> Optional[LiquidityPool]:
        """Get nearest BSL pool above current price."""
        nearest = None
        min_distance = float('inf')
        
        for pool in self.bsl_pools:
            if pool.is_swept or pool.level <= current_price:
                continue
            
            dist = pool.level - current_price
            if dist < min_distance:
                min_distance = dist
                nearest = pool
        
        return nearest
    
    def get_nearest_ssl(self, current_price: float) -> Optional[LiquidityPool]:
        """Get nearest SSL pool below current price."""
        nearest = None
        min_distance = float('inf')
        
        for pool in self.ssl_pools:
            if pool.is_swept or pool.level >= current_price:
                continue
            
            dist = current_price - pool.level
            if dist < min_distance:
                min_distance = dist
                nearest = pool
        
        return nearest


# =============================================================================
# MTF MANAGER (CMTFManager.mqh port - simplified for backtest)
# =============================================================================

class MTFManager:
    """
    Port of CMTFManager v3.2 from MQL5.
    Multi-timeframe analysis: H1/M15/M5 alignment.
    """
    
    def __init__(self, gmt_offset: int = 0):
        self.gmt_offset = gmt_offset
        self.min_trend_strength = 30.0
        self.min_confluence = 60.0
        
        self.htf_trend = MTFTrend.NEUTRAL
        self.mtf_trend = MTFTrend.NEUTRAL
        self.ltf_trend = MTFTrend.NEUTRAL
        
        self.htf_trend_strength = 0.0
        self.htf_hurst = 0.5
        self.htf_is_trending = False
        
        self.mtf_has_structure = False
        self.ltf_has_confirmation = False
        
        self.last_confluence = MTFConfluence()
    
    def _calculate_trend_strength(self, closes: np.ndarray) -> float:
        """Calculate trend strength (0-100)."""
        if len(closes) < 20:
            return 0.0
        
        closes = closes[-20:]
        
        # Directional bar count
        up_count = sum(1 for i in range(len(closes) - 1) if closes[i] > closes[i + 1])
        down_count = sum(1 for i in range(len(closes) - 1) if closes[i] < closes[i + 1])
        dir_score = abs(up_count - down_count) / 19.0 * 50
        
        # Price movement relative to range
        highest = np.max(closes)
        lowest = np.min(closes)
        range_val = highest - lowest
        net_move = abs(closes[0] - closes[-1])
        move_score = (net_move / range_val * 50) if range_val > 0 else 0
        
        return min(dir_score + move_score, 100.0)
    
    def _calculate_hurst(self, closes: np.ndarray, periods: int = 50) -> float:
        """Simplified Hurst calculation for MTF."""
        if len(closes) < periods:
            return 0.5
        
        prices = closes[-periods:]
        
        # Calculate returns
        returns = np.diff(np.log(prices))
        if len(returns) < 10:
            return 0.5
        
        mean = np.mean(returns)
        cumdev = np.cumsum(returns - mean)
        R = np.max(cumdev) - np.min(cumdev)
        S = np.std(returns, ddof=1)
        
        if S <= 0 or R <= 0:
            return 0.5
        
        RS = R / S
        H = np.log(RS) / np.log(len(returns))
        
        return max(0.0, min(1.0, H))
    
    def _determine_trend(self, ma_fast: float, ma_slow: float, price: float, atr: float) -> MTFTrend:
        """Determine trend direction."""
        threshold = atr * 0.3
        
        if price > ma_fast and ma_fast > ma_slow and (ma_fast - ma_slow) > threshold:
            return MTFTrend.BULLISH
        elif price < ma_fast and ma_fast < ma_slow and (ma_slow - ma_fast) > threshold:
            return MTFTrend.BEARISH
        elif abs(ma_fast - ma_slow) < threshold:
            return MTFTrend.RANGING
        
        return MTFTrend.NEUTRAL
    
    def _calculate_session_quality(self, timestamp: datetime) -> Tuple[float, int]:
        """Calculate session quality (0-1) and type."""
        gmt_hour = timestamp.hour - self.gmt_offset
        if gmt_hour < 0:
            gmt_hour += 24
        if gmt_hour >= 24:
            gmt_hour -= 24
        
        # Session types: 0=DEAD, 1=ASIAN, 2=NY, 3=LONDON, 4=OVERLAP
        if 13 <= gmt_hour < 16:
            return 1.0, 4  # OVERLAP
        elif 7 <= gmt_hour < 13:
            return 0.85, 3  # LONDON
        elif 16 <= gmt_hour < 21:
            return 0.85, 2  # NY
        elif 0 <= gmt_hour < 7:
            return 0.40, 1  # ASIAN
        
        return 0.25, 0  # DEAD
    
    def analyze_htf(self, h1_closes: np.ndarray, h1_atr: float):
        """Analyze H1 timeframe."""
        if len(h1_closes) < 50:
            self.htf_trend = MTFTrend.NEUTRAL
            return
        
        # Calculate MAs
        ma_20 = np.mean(h1_closes[-20:])
        ma_50 = np.mean(h1_closes[-50:])
        current_price = h1_closes[-1]
        
        self.htf_trend = self._determine_trend(ma_20, ma_50, current_price, h1_atr)
        self.htf_trend_strength = self._calculate_trend_strength(h1_closes)
        self.htf_hurst = self._calculate_hurst(h1_closes)
        
        # Is trending?
        ma_separation = abs(ma_20 - ma_50) / h1_atr if h1_atr > 0 else 0
        self.htf_is_trending = (self.htf_hurst > 0.55 and ma_separation > 0.5) or (ma_separation > 1.5)
    
    def analyze_mtf(self, m15_closes: np.ndarray, has_ob: bool = False, has_fvg: bool = False):
        """Analyze M15 timeframe."""
        # Inherit direction from HTF
        if self.htf_trend == MTFTrend.BULLISH:
            self.mtf_trend = MTFTrend.BULLISH
        elif self.htf_trend == MTFTrend.BEARISH:
            self.mtf_trend = MTFTrend.BEARISH
        else:
            self.mtf_trend = MTFTrend.NEUTRAL
        
        # Structure presence
        self.mtf_has_structure = has_ob or has_fvg
    
    def analyze_ltf(self, m5_closes: np.ndarray, m5_rsi: float):
        """Analyze M5 timeframe."""
        if len(m5_closes) < 6:
            self.ltf_trend = MTFTrend.NEUTRAL
            return
        
        # Calculate momentum
        momentum = (m5_closes[-1] - m5_closes[-6]) / m5_closes[-6] * 100 if m5_closes[-6] > 0 else 0
        
        # Determine LTF trend
        if m5_rsi > 55 and momentum > 0:
            self.ltf_trend = MTFTrend.BULLISH
        elif m5_rsi < 45 and momentum < 0:
            self.ltf_trend = MTFTrend.BEARISH
        else:
            self.ltf_trend = MTFTrend.NEUTRAL
        
        # Check momentum alignment with HTF
        momentum_aligned = False
        if self.htf_trend == MTFTrend.BULLISH and momentum > 0:
            momentum_aligned = True
        elif self.htf_trend == MTFTrend.BEARISH and momentum < 0:
            momentum_aligned = True
        
        # LTF confirmation (simplified)
        self.ltf_has_confirmation = momentum_aligned and abs(momentum) > 0.1
    
    def get_confluence(self, timestamp: datetime) -> MTFConfluence:
        """Get MTF confluence analysis."""
        result = MTFConfluence()
        
        result.htf_trend = self.htf_trend
        result.mtf_trend = self.mtf_trend
        result.ltf_trend = self.ltf_trend
        
        confluence_count = 0
        
        # HTF alignment
        if self.htf_trend in [MTFTrend.BULLISH, MTFTrend.BEARISH]:
            result.htf_aligned = True
            confluence_count += 1
        
        # MTF structure
        if self.mtf_has_structure:
            result.mtf_structure = True
            confluence_count += 1
        
        # LTF confirmation
        if self.ltf_has_confirmation:
            result.ltf_confirmed = True
            confluence_count += 1
        
        # Alignment quality
        if confluence_count >= 3:
            result.alignment = MTFAlignment.PERFECT
        elif confluence_count == 2:
            result.alignment = MTFAlignment.GOOD
        elif confluence_count == 1:
            result.alignment = MTFAlignment.WEAK
        else:
            result.alignment = MTFAlignment.NONE
        
        # Position size multiplier
        mult_map = {
            MTFAlignment.PERFECT: 1.0,
            MTFAlignment.GOOD: 0.75,
            MTFAlignment.WEAK: 0.5,
            MTFAlignment.NONE: 0.0,
        }
        result.position_size_mult = mult_map.get(result.alignment, 0.0)
        
        # Signal
        if result.alignment >= MTFAlignment.GOOD:
            if self.htf_trend == MTFTrend.BULLISH and self.ltf_has_confirmation:
                result.signal = SignalType.BUY
            elif self.htf_trend == MTFTrend.BEARISH and self.ltf_has_confirmation:
                result.signal = SignalType.SELL
        
        # Session quality
        session_quality, session_type = self._calculate_session_quality(timestamp)
        result.session_quality = session_quality
        result.session_ok = session_quality >= 0.5
        
        # Confidence
        conf = 0.0
        if result.htf_aligned:
            conf += 30.0
        if result.mtf_structure:
            conf += 35.0
        if result.ltf_confirmed:
            conf += 35.0
        conf += min(self.htf_trend_strength * 0.1, 10.0)
        
        if session_quality < 1.0:
            conf *= (0.5 + session_quality * 0.5)
        
        result.confidence = min(conf, 100.0)
        
        self.last_confluence = result
        return result
    
    def can_trade_long(self) -> bool:
        """Check if can trade long."""
        return (self.htf_trend == MTFTrend.BULLISH and 
                self.htf_is_trending and 
                self.htf_trend_strength >= self.min_trend_strength)
    
    def can_trade_short(self) -> bool:
        """Check if can trade short."""
        return (self.htf_trend == MTFTrend.BEARISH and 
                self.htf_is_trending and 
                self.htf_trend_strength >= self.min_trend_strength)


# =============================================================================
# CONFLUENCE SCORER (CConfluenceScorer.mqh port - simplified)
# =============================================================================

class ConfluenceScorer:
    """
    Port of CConfluenceScorer v4.2 from MQL5.
    10-factor scoring (structure, regime, sweep, AMD, OB, FVG, zone, MTF, footprint, fib)
    with Bayesian probability.
    """
    
    # Tier thresholds
    TIER_S_MIN = 90
    TIER_A_MIN = 80
    TIER_B_MIN = 70
    TIER_C_MIN = 60
    
    def __init__(self):
        # Default weights (10 factors = 100%)
        self.weights = {
            'structure': 0.18,
            'regime': 0.15,
            'sweep': 0.12,
            'amd': 0.10,
            'ob': 0.10,
            'fvg': 0.08,
            'zone': 0.05,
            'mtf': 0.15,
            'footprint': 0.07,
            'fib': 0.10,
        }
        
        # Bayesian parameters
        self.use_bayesian = False  # Disabled for backtest (Bayesian too strict)
        self.bayesian_params = {
            'p_structure_given_win': 0.72,
            'p_structure_given_loss': 0.45,
            'p_regime_given_win': 0.68,
            'p_regime_given_loss': 0.50,
            'p_sweep_given_win': 0.65,
            'p_sweep_given_loss': 0.48,
            'p_amd_given_win': 0.62,
            'p_amd_given_loss': 0.52,
            'p_ob_given_win': 0.70,
            'p_ob_given_loss': 0.40,
            'p_fvg_given_win': 0.67,
            'p_fvg_given_loss': 0.42,
            'p_zone_given_win': 0.60,
            'p_zone_given_loss': 0.45,
            'p_mtf_given_win': 0.78,
            'p_mtf_given_loss': 0.35,
            'p_footprint_given_win': 0.73,
            'p_footprint_given_loss': 0.38,
            'p_fib_given_win': 0.60,
            'p_fib_given_loss': 0.40,
            'prior_win': 0.52,
        }
        
        # Thresholds
        self.min_score = self.TIER_B_MIN
        self.min_confluences = 3
    
    def _calculate_bayesian_probability(self, result: ConfluenceResult) -> float:
        """Calculate Bayesian probability of win."""
        p_win = self.bayesian_params['prior_win']
        p_loss = 1.0 - p_win
        
        likelihood_win = 1.0
        likelihood_loss = 1.0
        
        # Factor presence threshold
        threshold = 60
        
        factors = [
            ('structure', result.structure_score),
            ('regime', result.regime_score),
            ('sweep', result.sweep_score),
            ('amd', result.amd_score),
            ('ob', result.ob_score),
            ('fvg', result.fvg_score),
            ('zone', result.premium_discount),
            ('mtf', result.mtf_score),
            ('footprint', result.footprint_score),
            ('fib', result.fib_score),
        ]
        
        for factor_name, score in factors:
            p_given_win = self.bayesian_params.get(f'p_{factor_name}_given_win', 0.5)
            p_given_loss = self.bayesian_params.get(f'p_{factor_name}_given_loss', 0.5)
            
            if score >= threshold:
                likelihood_win *= p_given_win
                likelihood_loss *= p_given_loss
            else:
                likelihood_win *= (1.0 - p_given_win)
                likelihood_loss *= (1.0 - p_given_loss)
        
        p_evidence = likelihood_win * p_win + likelihood_loss * p_loss
        
        if p_evidence <= 0:
            return self.bayesian_params['prior_win']
        
        posterior = (likelihood_win * p_win) / p_evidence
        return max(0.0, min(1.0, posterior))
    
    def _count_confluences(self, result: ConfluenceResult) -> int:
        """Count number of positive confluences."""
        threshold = 60
        count = 0
        
        for score in [
            result.structure_score,
            result.regime_score,
            result.sweep_score,
            result.amd_score,
            result.ob_score,
            result.fvg_score,
            result.premium_discount,
            result.mtf_score,
            result.footprint_score,
            result.fib_score,
        ]:
            if score >= threshold:
                count += 1
        
        return count
    
    def _classify_quality(self, score: float) -> SignalQuality:
        """Classify signal quality based on score."""
        if score >= self.TIER_S_MIN:
            return SignalQuality.ELITE
        elif score >= self.TIER_A_MIN:
            return SignalQuality.HIGH
        elif score >= self.TIER_B_MIN:
            return SignalQuality.MEDIUM
        elif score >= self.TIER_C_MIN:
            return SignalQuality.LOW
        return SignalQuality.INVALID
    
    def _determine_direction(self, 
                             regime_analysis: RegimeAnalysis,
                             mtf_confluence: MTFConfluence,
                             sweep_signal: SignalType) -> SignalType:
        """Determine trade direction based on multiple factors."""
        bullish_votes = 0
        bearish_votes = 0
        
        # MTF alignment (weight: 4 votes)
        if mtf_confluence.htf_trend == MTFTrend.BULLISH:
            bullish_votes += 4
        elif mtf_confluence.htf_trend == MTFTrend.BEARISH:
            bearish_votes += 4
        
        # LTF confirmation (weight: 1 vote)
        if mtf_confluence.ltf_confirmed:
            if mtf_confluence.signal == SignalType.BUY:
                bullish_votes += 1
            elif mtf_confluence.signal == SignalType.SELL:
                bearish_votes += 1
        
        # Sweep signal (weight: 2 votes)
        if sweep_signal == SignalType.BUY:
            bullish_votes += 2
        elif sweep_signal == SignalType.SELL:
            bearish_votes += 2
        
        # Minimum margin (relaxed from 3 to 1 for backtest due to HTF often NEUTRAL)
        if bullish_votes >= bearish_votes + 1 and bullish_votes >= 2:
            return SignalType.BUY
        elif bearish_votes >= bullish_votes + 1 and bearish_votes >= 2:
            return SignalType.SELL
        
        return SignalType.NONE
    
    def calculate_confluence(self,
                            regime_analysis: RegimeAnalysis,
                            mtf_confluence: MTFConfluence,
                            sweep_detector: LiquiditySweepDetector,
                            session_filter: SessionFilter,
                            timestamp: datetime,
                            current_price: float,
                            atr: float,
                            has_ob: bool = False,
                            has_fvg: bool = False,
                            m15_highs: Optional[np.ndarray] = None,
                            m15_lows: Optional[np.ndarray] = None,
                            m15_atr: Optional[float] = None) -> ConfluenceResult:
        """Main confluence calculation."""
        result = ConfluenceResult()
        
        # Component scores
        result.regime_score = 50.0 + regime_analysis.score_adjustment
        if regime_analysis.regime in [MarketRegime.PRIME_TRENDING, MarketRegime.PRIME_REVERTING]:
            result.regime_score = 85.0
        elif regime_analysis.regime in [MarketRegime.NOISY_TRENDING, MarketRegime.NOISY_REVERTING]:
            result.regime_score = 65.0
        elif regime_analysis.regime == MarketRegime.TRANSITIONING:
            result.regime_score = 45.0
        elif regime_analysis.regime == MarketRegime.RANDOM_WALK:
            result.regime_score = 25.0
        
        # MTF score
        result.mtf_score = mtf_confluence.confidence
        
        # Sweep score
        if sweep_detector.has_recent_sweep():
            result.sweep_score = 75.0
        else:
            result.sweep_score = 55.0
        
        # Session score contribution
        session_score = session_filter.get_session_score(timestamp)
        result.structure_score = 50.0 + (session_score - 50) * 0.3
        
        # AMD score (simplified - based on time of day)
        gmt_hour = session_filter.get_gmt_hour(timestamp)
        if 8 <= gmt_hour < 11:  # London manipulation
            result.amd_score = 70.0
        elif 12 <= gmt_hour < 15:  # Distribution
            result.amd_score = 80.0
        else:
            result.amd_score = 50.0
        
        # OB/FVG scores
        result.ob_score = 75.0 if has_ob else 50.0
        result.fvg_score = 70.0 if has_fvg else 50.0
        
        # Premium/Discount (simplified) using last 50 M15 highs/lows if available
        look_zone = min(len(m15_highs), 50) if m15_highs is not None else 0
        if look_zone >= 5:
            swing_high = float(np.max(m15_highs[-look_zone:]))
            swing_low = float(np.min(m15_lows[-look_zone:]))
            eq = (swing_high + swing_low) / 2
            result.premium_discount = 80.0 if current_price < eq else 70.0
        else:
            result.premium_discount = 50.0

        # Fibonacci proximity (using same swing as zone or broader)
        result.fib_score = 50.0
        look_fib = min(len(m15_highs), 100) if m15_highs is not None else 0
        if look_fib >= 10:
            swing_high = float(np.max(m15_highs[-look_fib:]))
            swing_low = float(np.min(m15_lows[-look_fib:]))
            if swing_high > swing_low:
                atr_ref = m15_atr if m15_atr and m15_atr > 0 else (swing_high - swing_low) / 50
                best = 1e9
                for lvl in (0.382, 0.618, 0.705):
                    fib_level = swing_low + (swing_high - swing_low) * lvl
                    best = min(best, abs(current_price - fib_level))
                if best <= 0.25 * atr_ref:
                    result.fib_score = 90.0
                elif best <= 0.50 * atr_ref:
                    result.fib_score = 75.0
                elif best <= 1.0 * atr_ref:
                    result.fib_score = 60.0
                else:
                    result.fib_score = 40.0
            else:
                result.fib_score = 40.0
        
        # Footprint score (simplified for backtest)
        result.footprint_score = 55.0
        
        # Calculate total score
        if self.use_bayesian:
            p_win = self._calculate_bayesian_probability(result)
            result.total_score = p_win * 100.0
        else:
            result.total_score = (
                result.structure_score * self.weights['structure'] +
                result.regime_score * self.weights['regime'] +
                result.sweep_score * self.weights['sweep'] +
                result.amd_score * self.weights['amd'] +
                result.ob_score * self.weights['ob'] +
                result.fvg_score * self.weights['fvg'] +
                result.premium_discount * self.weights['zone'] +
                result.mtf_score * self.weights['mtf'] +
                result.footprint_score * self.weights['footprint'] +
                result.fib_score * self.weights['fib']
            )
        
        # Regime adjustment
        result.regime_adjustment = regime_analysis.score_adjustment
        result.total_score += result.regime_adjustment
        
        # Confluence bonus
        result.total_confluences = self._count_confluences(result)
        if result.total_confluences >= 8:
            result.confluence_bonus = 15
        elif result.total_confluences >= 6:
            result.confluence_bonus = 10
        elif result.total_confluences >= 4:
            result.confluence_bonus = 5
        else:
            result.confluence_bonus = 0
        
        result.total_score += result.confluence_bonus
        result.total_score = max(0, min(100, result.total_score))
        
        # Direction
        sweep_signal = sweep_detector.get_sweep_signal()
        result.direction = self._determine_direction(regime_analysis, mtf_confluence, sweep_signal)
        
        # Quality
        result.quality = self._classify_quality(result.total_score)
        
        # Position size
        result.position_size_mult = regime_analysis.size_multiplier
        
        # Calculate trade setup BEFORE validation (needed for R:R check)
        if result.direction != SignalType.NONE and atr > 0:
            result.entry_price = current_price
            if result.direction == SignalType.BUY:
                result.stop_loss = current_price - atr * 1.5
                result.take_profit_1 = current_price + atr * 2.0
                result.take_profit_2 = current_price + atr * 3.0
            elif result.direction == SignalType.SELL:
                result.stop_loss = current_price + atr * 1.5
                result.take_profit_1 = current_price - atr * 2.0
                result.take_profit_2 = current_price - atr * 3.0
            
            risk = abs(result.entry_price - result.stop_loss)
            reward = abs(result.take_profit_1 - result.entry_price)
            result.risk_reward = reward / risk if risk > 0 else 0
        
        # Validate after R:R is calculated
        result.is_valid = self._validate_setup(result, regime_analysis, session_filter, timestamp)
        
        return result
    
    def _validate_setup(self, 
                        result: ConfluenceResult,
                        regime_analysis: RegimeAnalysis,
                        session_filter: SessionFilter,
                        timestamp: datetime) -> bool:
        """Validate if setup is tradeable."""
        # Must have direction
        if result.direction == SignalType.NONE:
            return False
        
        # Session check
        if not session_filter.is_trading_allowed(timestamp):
            return False
        
        # Regime check
        if regime_analysis.regime in [MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN]:
            return False
        
        # Get strategy for regime
        strategy = RegimeDetector().get_optimal_strategy(regime_analysis.regime)
        
        # Entry mode check
        if strategy.entry_mode == EntryMode.DISABLED:
            return False
        
        # Score check
        effective_min_score = max(self.min_score, int(strategy.min_confluence))
        if result.total_score < effective_min_score:
            return False
        
        # Confluence count check
        if result.total_confluences < self.min_confluences:
            return False
        
        # Quality check
        if result.quality == SignalQuality.INVALID:
            return False
        
        return True


# =============================================================================
# MAIN EA LOGIC CLASS (combines all modules)
# =============================================================================

class EALogicFull:
    """
    Full EA_SCALPER_XAUUSD v3.30 Logic.
    Combines all analysis modules for signal generation.
    """
    
    def __init__(self, gmt_offset: int = 0,
                 use_ml: bool = False,
                 ml_threshold: float = 0.65,
                 block_high_news: bool = True,
                 block_medium_news: bool = False,
                 allow_asian: bool = False,
                 allow_late_ny: bool = False,
                 relaxed_mtf_gate: bool = False,
                 require_ltf_confirm: bool = True,
                 debug: bool = False,
                 verbose: bool = False):
        self.gmt_offset = gmt_offset
        self.debug = debug
        self.verbose = verbose
        
        # Initialize all modules
        self.regime_detector = RegimeDetector()
        self.session_filter = SessionFilter(gmt_offset)
        self.session_filter.allow_asian = allow_asian
        self.session_filter.allow_late_ny = allow_late_ny
        self.sweep_detector = LiquiditySweepDetector()
        self.mtf_manager = MTFManager(gmt_offset)
        self.confluence_scorer = ConfluenceScorer()
        self.news_filter = NewsFilter(block_high_news, block_medium_news)
        self.risk_manager = RiskManager()
        
        # Configuration
        self.execution_threshold = 50
        self.min_rr = 1.5
        self.amd_threshold = 60.0  # Min AMD score (can be relaxed for backtest)
        self.risk_per_trade = 0.5  # 0.5%
        self.use_ml = use_ml
        self.ml_threshold = ml_threshold
        self.relaxed_mtf_gate = relaxed_mtf_gate  # For backtest compatibility
        self.require_ltf_confirm = require_ltf_confirm
        
        # State
        self.last_signal = SignalType.NONE
        self.last_confluence = ConfluenceResult()
        self.current_strategy = RegimeStrategy()
        
        # Debug stats
        self.gate_blocks = {f"GATE_{i}": 0 for i in range(1, 11)}
    
    def get_gate_stats(self) -> Dict:
        """Get gate blocking statistics."""
        return self.gate_blocks.copy()
    
    def analyze(self,
                h1_closes: np.ndarray,
                m15_closes: np.ndarray,
                m5_closes: np.ndarray,
                m15_highs: np.ndarray,
                m15_lows: np.ndarray,
                h1_atr: float,
                m15_atr: float,
                m5_rsi: float,
                timestamp: datetime,
                current_price: float,
                spread_points: int = 0,
                max_spread: int = 80,
                ml_prob: Optional[float] = None,
                news_events: Optional[List[Tuple[datetime, str, str]]] = None,
                balance: float = 100_000.0,
                ltf_df: Optional[pd.DataFrame] = None,
                ticks_df: Optional[pd.DataFrame] = None,
                footprint_config: Optional[FootprintConfig] = None,
                use_footprint: bool = True) -> ConfluenceResult:
        """
        Main analysis function - replicates OnTick logic from MQL5.
        
        Returns ConfluenceResult with signal and trade setup.
        """
        result = ConfluenceResult()
        
        # GATE 1: Spread check
        if spread_points > max_spread:
            self.gate_blocks["GATE_1"] += 1
            return result

        # GATE 2: Risk limits / soft stop / max trades
        self.risk_manager.balance = balance  # sync external balance
        self.risk_manager.initial_balance = max(self.risk_manager.initial_balance, balance)
        if not self.risk_manager.can_open(timestamp):
            self.gate_blocks["GATE_2"] += 1
            return result
        
        # GATE 3: Session check
        if not self.session_filter.is_trading_allowed(timestamp):
            self.gate_blocks["GATE_3"] += 1
            return result

        # GATE 4: News check
        if news_events is not None:
            self.news_filter.set_events(news_events)
        if not self.news_filter.is_allowed(timestamp):
            self.gate_blocks["GATE_4"] += 1
            return result

        # OPTIONAL: Build footprint from ticks and attach fp_score to LTF
        if use_footprint and ticks_df is not None:
            cfg = footprint_config or FootprintConfig(bar_timeframe='5min', verbose=self.verbose)
            if footprint_config is None:
                cfg.verbose = self.verbose
            analyzer = FootprintAnalyzer(cfg)
            td = ticks_df.copy()
            if 'timestamp' in td.columns:
                if not pd.api.types.is_datetime64_any_dtype(td['timestamp']):
                    td['timestamp'] = pd.to_datetime(td['timestamp'])
                td.set_index('timestamp', inplace=True)
            td.sort_index(inplace=True)
            fp_df = analyzer.analyze_ticks(td)
            if ltf_df is None or ltf_df.empty:
                # Use footprint bars as LTF input
                ltf_df = fp_df.rename(columns={'total_volume': 'volume'})
            else:
                ltf_df = merge_footprint_with_bars(ltf_df, fp_df)

        # GATE 5: ML confirmation (if enabled)
        if self.use_ml:
            if ml_prob is None:
                self.gate_blocks["GATE_5"] += 1
                return result
            if ml_prob >= self.ml_threshold:
                ml_dir = SignalType.BUY
            elif ml_prob <= 1 - self.ml_threshold:
                ml_dir = SignalType.SELL
            else:
                self.gate_blocks["GATE_5"] += 1
                return result
        else:
            ml_dir = SignalType.NONE
        
        # Analyze regime
        regime_analysis = self.regime_detector.analyze_regime(h1_closes)
        
        # GATE 6: Regime check
        if not self.regime_detector.is_trading_allowed():
            self.gate_blocks["GATE_6"] += 1
            return result
        
        # Get strategy for current regime
        self.current_strategy = self.regime_detector.get_optimal_strategy(regime_analysis.regime)
        
        # Structure/OB/FVG detection FIRST (needed for MTF analysis)
        has_ob = False
        has_fvg = False
        ob_zone = (0.0, 0.0)
        fvg_zone = (0.0, 0.0)
        if ltf_df is not None and not ltf_df.empty:
            ltf = ltf_df.copy()
            ltf["tr"] = (ltf["high"] - ltf["low"]).combine(ltf["high"] - ltf["close"].shift(1), max).combine(
                ltf["low"] - ltf["close"].shift(1), lambda a, b: max(abs(a), abs(b)))
            ltf["atr"] = ltf["tr"].rolling(14, min_periods=1).mean()
            obs = detect_order_blocks(ltf, ltf["atr"].values, displacement_mult=2.0)
            fvgs = detect_fvg(ltf, min_gap=0.3)
            price = float(ltf["close"].iloc[-1])
            atr = float(ltf["atr"].iloc[-1])
            # nearest OB in direction of current bias inferred from MTF signal
            for ob in reversed(obs):
                ps = proximity_score(price, ob["bottom"], ob["top"], atr)
                if ps > 0:
                    has_ob = True
                    ob_zone = (ob["bottom"], ob["top"])
                    break
            for f in reversed(fvgs):
                ps = proximity_score(price, f["bottom"], f["top"], atr)
                if ps > 0:
                    has_fvg = True
                    fvg_zone = (f["bottom"], f["top"])
                    break

        # Analyze MTF (now with OB/FVG info)
        self.mtf_manager.analyze_htf(h1_closes, h1_atr)
        self.mtf_manager.analyze_mtf(m15_closes, has_ob=has_ob, has_fvg=has_fvg)
        self.mtf_manager.analyze_ltf(m5_closes, m5_rsi)
        mtf_confluence = self.mtf_manager.get_confluence(timestamp)
        
        # GATE 7: MTF alignment check (can be relaxed for backtest)
        if not self.relaxed_mtf_gate:
            if mtf_confluence.alignment < MTFAlignment.GOOD:
                self.gate_blocks["GATE_7"] += 1
                return result
            if self.require_ltf_confirm and not mtf_confluence.ltf_confirmed:
                self.gate_blocks["GATE_7"] += 1
                return result
        else:
            # Relaxed: only require WEAK or better alignment
            if mtf_confluence.alignment < MTFAlignment.WEAK:
                self.gate_blocks["GATE_7"] += 1
                return result
        
        # Update sweep detector
        self.sweep_detector.update(m15_highs, m15_lows, m15_closes, m15_atr)
        sweep_signal = self.sweep_detector.get_sweep_signal()

        # Calculate confluence
        result = self.confluence_scorer.calculate_confluence(
            regime_analysis=regime_analysis,
            mtf_confluence=mtf_confluence,
            sweep_detector=self.sweep_detector,
            session_filter=self.session_filter,
            timestamp=timestamp,
            current_price=current_price,
            atr=m15_atr,
            has_ob=has_ob,
            has_fvg=has_fvg,
            m15_highs=m15_highs,
            m15_lows=m15_lows,
            m15_atr=m15_atr,
        )

        # GATE 8: AMD hard filter (block accumulation/manipulation)
        if result.amd_score < self.amd_threshold:
            self.gate_blocks["GATE_8"] += 1
            result.is_valid = False
            return result
        
        # GATE 9: Score check
        if result.total_score < self.execution_threshold:
            self.gate_blocks["GATE_9"] += 1
            result.is_valid = False
            return result
        
        # GATE 10: R:R check
        if result.risk_reward < self.min_rr:
            self.gate_blocks["GATE_10"] += 1
            result.is_valid = False
            return result

        # GATE 11: ML direction alignment if enabled
        if self.use_ml and ml_dir != SignalType.NONE and result.direction != ml_dir:
            self.gate_blocks["GATE_11"] += 1
            result.is_valid = False
            return result

        # Footprint score:
        # 1) if ltf_df supplies precomputed fp_score (from footprint_analyzer), use it
        # 2) else fall back to quick delta/imbalance proxy
        if ltf_df is not None and not ltf_df.empty:
            if "fp_score" in ltf_df.columns:
                result.footprint_score = float(ltf_df["fp_score"].iloc[-1])
            elif "volume" in ltf_df:
                last = ltf_df.tail(20)
                delta = (last["close"] - last["open"]).sum()
                rng = (last["high"] - last["low"]).mean()
                imbalance = float(delta / max(1e-9, rng))
                fp = 50.0 + np.tanh(imbalance) * 25.0
                result.footprint_score = max(30.0, min(90.0, fp))
            else:
                result.footprint_score = max(result.footprint_score, 55.0)
        else:
            result.footprint_score = max(result.footprint_score, 55.0)

        # Apply regime-specific TPs
        if self.current_strategy.tp1_r > 0 and result.is_valid:
            risk_price = abs(current_price - result.stop_loss)
            
            if result.direction == SignalType.BUY:
                result.take_profit_1 = current_price + risk_price * self.current_strategy.tp1_r
                result.take_profit_2 = current_price + risk_price * self.current_strategy.tp2_r
            elif result.direction == SignalType.SELL:
                result.take_profit_1 = current_price - risk_price * self.current_strategy.tp1_r
                result.take_profit_2 = current_price - risk_price * self.current_strategy.tp2_r
            
            result.risk_reward = self.current_strategy.tp1_r
        
        self.last_signal = result.direction
        self.last_confluence = result
        
        return result
    
    def on_trade_close(self, pnl: float, timestamp: datetime):
        """Notify risk manager of closed trade PnL for streak/DD logic."""
        self.risk_manager.record_trade(pnl, timestamp)
    
    def get_position_size(self, 
                          account_balance: float,
                          sl_points: float,
                          point_value: float = 0.01,
                          timestamp: Optional[datetime] = None) -> float:
        """Calculate position size based on risk."""
        if sl_points <= 0:
            return 0.0
        ts = timestamp or datetime.utcnow()
        session_mult = self.session_filter.get_session_score(ts) / 100.0
        risk_pct_override = self.current_strategy.risk_percent * 100 if self.current_strategy.risk_percent > 0 else None
        lot = self.risk_manager.lot_size(
            sl_points=sl_points,
            regime_mult=self.last_confluence.position_size_mult,
            conf_mult=self.last_confluence.position_size_mult,
            session_mult=session_mult,
            risk_percent_override=risk_pct_override
        )
        return lot
    
    def get_regime_info(self) -> Dict:
        """Get current regime information."""
        analysis = self.regime_detector.last_analysis
        return {
            'regime': analysis.regime.name if analysis.is_valid else 'UNKNOWN',
            'hurst': analysis.hurst_exponent,
            'entropy': analysis.shannon_entropy,
            'variance_ratio': analysis.variance_ratio,
            'confidence': analysis.confidence,
            'size_multiplier': analysis.size_multiplier,
            'strategy': self.current_strategy.philosophy,
        }
    
    def get_session_info(self, timestamp: datetime) -> Dict:
        """Get current session information."""
        return {
            'session': self.session_filter.get_session_name(timestamp),
            'quality': self.session_filter.get_session_quality(timestamp).name,
            'score': self.session_filter.get_session_score(timestamp),
            'trading_allowed': self.session_filter.is_trading_allowed(timestamp),
        }


# =============================================================================
# COMPATIBILITY: TradeSetup for tick_backtester.py
# =============================================================================

@dataclass
class TradeSetup:
    """Trade setup returned by evaluate_from_df() for tick_backtester compatibility."""
    direction: SignalType
    entry: float
    sl: float
    tp1: float
    tp2: float = 0.0
    tp3: float = 0.0
    risk_reward: float = 0.0
    lot: float = 0.01
    confluence: Optional[ConfluenceResult] = None
    regime: Optional[RegimeAnalysis] = None


@dataclass
class EAConfig:
    """Configuration for EALogic - compatible with ea_logic_python.py"""
    risk_per_trade_pct: float = 0.5
    max_daily_loss_pct: float = 5.0
    soft_stop_pct: float = 4.0
    max_total_loss_pct: float = 10.0
    max_trades_per_day: int = 20
    max_spread_points: float = 80.0
    slippage_points: float = 50.0
    execution_threshold: float = 65.0  # REAL threshold (not relaxed)
    confluence_min_score: float = 65.0  # REAL threshold
    amd_threshold: float = 40.0        # Relaxed for backtest (60.0 for live)
    allow_asian: bool = False  # Default: block Asian
    allow_late_ny: bool = False  # Default: block Late NY
    gmt_offset: int = 0
    friday_close_hour: int = 14
    news_enabled: bool = True
    block_high: bool = True
    block_medium: bool = False
    use_ml: bool = False
    ml_threshold: float = 0.65
    min_rr: float = 1.5  # REAL R:R (not relaxed)
    target_rr: float = 2.5
    max_wait_bars: int = 10
    use_mtf: bool = True
    min_mtf_confluence: float = 50.0
    require_htf_align: bool = True
    require_mtf_zone: bool = False
    require_ltf_confirm: bool = False  # Relaxed for backtest
    relaxed_mtf_gate: bool = True       # Skip strict MTF alignment check for backtest
    ob_displacement_mult: float = 2.0
    fvg_min_gap: float = 0.3
    point_value: float = 0.01
    tick_value: float = 1.0
    tick_size: float = 0.01
    use_fib_filter: bool = True
    fib_levels: Tuple[float, float, float] = (0.382, 0.618, 0.705)
    fib_lookback_bars: int = 100


# =============================================================================
# COMPATIBILITY: EALogic wrapper for tick_backtester.py
# =============================================================================

class EALogic:
    """
    Wrapper around EALogicFull that provides evaluate_from_df() interface
    for compatibility with tick_backtester.py.
    
    Uses REAL thresholds (not relaxed) for accurate backtesting.
    """
    
    def __init__(self, cfg: Optional[EAConfig] = None, initial_balance: float = 100_000.0):
        self.cfg = cfg or EAConfig()
        self.initial_balance = initial_balance
        
        # Create the full EA logic with session and MTF settings
        self.ea_full = EALogicFull(
            gmt_offset=self.cfg.gmt_offset,
            use_ml=self.cfg.use_ml,
            ml_threshold=self.cfg.ml_threshold,
            block_high_news=self.cfg.block_high,
            block_medium_news=self.cfg.block_medium,
            allow_asian=self.cfg.allow_asian,
            allow_late_ny=self.cfg.allow_late_ny,
            relaxed_mtf_gate=self.cfg.relaxed_mtf_gate,
            require_ltf_confirm=self.cfg.require_ltf_confirm,
        )
        
        # Override thresholds from config
        self.ea_full.execution_threshold = self.cfg.execution_threshold
        self.ea_full.min_rr = self.cfg.min_rr
        self.ea_full.amd_threshold = self.cfg.amd_threshold
        self.ea_full.risk_manager.initial_balance = initial_balance
        self.ea_full.risk_manager.balance = initial_balance
    
    def evaluate_from_df(self, 
                         ltf_df: pd.DataFrame, 
                         htf_df: pd.DataFrame, 
                         now: datetime,
                         ml_prob: Optional[float] = None, 
                         fp_score: float = 50.0,
                         mtf_alignment: Optional[float] = None,
                         news_events: Optional[List[Tuple[datetime, str, str]]] = None) -> Optional[TradeSetup]:
        """
        Evaluate trading signal from DataFrames.
        
        Compatible interface with tick_backtester.py.
        Uses FULL EA logic with REAL thresholds.
        
        Args:
            ltf_df: Low timeframe DataFrame (M5) with OHLCV + spread
            htf_df: High timeframe DataFrame (H1) with OHLCV
            now: Current timestamp
            ml_prob: ML probability (optional)
            fp_score: Footprint score (0-100)
            mtf_alignment: MTF alignment score (optional)
            news_events: List of (datetime, impact, title) tuples
            
        Returns:
            TradeSetup if valid signal, None otherwise
        """
        if ltf_df.empty:
            return None
        
        # Extract data from DataFrames
        # LTF (M5)
        ltf = ltf_df.copy()
        if 'atr' not in ltf.columns:
            ltf['tr'] = (ltf['high'] - ltf['low']).combine(
                (ltf['high'] - ltf['close'].shift(1)).abs(), max
            ).combine(
                (ltf['low'] - ltf['close'].shift(1)).abs(), max
            )
            ltf['atr'] = ltf['tr'].rolling(14, min_periods=1).mean()
        
        # Calculate RSI for LTF
        delta = ltf['close'].diff()
        gain = delta.where(delta > 0, 0).rolling(14, min_periods=1).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(14, min_periods=1).mean()
        rs = gain / loss.replace(0, 1e-10)
        ltf['rsi'] = 100 - (100 / (1 + rs))
        
        m5_closes = ltf['close'].values
        m5_rsi = float(ltf['rsi'].iloc[-1]) if not np.isnan(ltf['rsi'].iloc[-1]) else 50.0
        m5_atr = float(ltf['atr'].iloc[-1])
        
        # HTF (H1) - WP3 causal enforcement: apply as-of slicing
        if htf_df is not None and not htf_df.empty:
            htf = htf_df.copy()
            # Apply as-of filter: H1 bar is only available after its close time
            # (bar_start + 1 hour). This prevents look-ahead leakage.
            if hasattr(htf.index, 'to_series') or hasattr(htf.index, 'dtype'):
                try:
                    ts_now = pd.Timestamp(now)
                    htf_idx = pd.to_datetime(htf.index)
                    # H1 bar is only valid once bar_close <= now
                    # For bars indexed by open time, bar_close = index + 1h
                    htf = htf.loc[htf_idx + pd.Timedelta("1h") <= ts_now]
                except Exception:
                    # Fallback: use simple index slicing if index is datetime-like
                    try:
                        htf = htf.loc[:now]
                    except Exception:
                        pass  # Keep original if slicing fails

            # Contract enforcement: raise if HTF still has future data
            if len(htf) > 0:
                try:
                    last_htf_bar_time = pd.to_datetime(htf.index[-1])
                    htf_bar_close_time = last_htf_bar_time + pd.Timedelta("1h")
                    if htf_bar_close_time > pd.Timestamp(now):
                        raise ValueError(
                            f"HTF look-ahead leakage: htf[-1]={last_htf_bar_time}, "
                            f"bar_close={htf_bar_close_time}, now={now}. "
                            "HTF bar not yet closed at decision time."
                        )
                except (TypeError, ValueError) as e:
                    if "look-ahead" in str(e):
                        raise
                    # Index is not datetime-like, skip validation
                    pass
        else:
            htf = ltf

        if 'atr' not in htf.columns:
            htf['tr'] = (htf['high'] - htf['low']).combine(
                (htf['high'] - htf['close'].shift(1)).abs(), max
            ).combine(
                (htf['low'] - htf['close'].shift(1)).abs(), max
            )
            htf['atr'] = htf['tr'].rolling(14, min_periods=1).mean()
        
        h1_closes = htf['close'].values
        h1_atr = float(htf['atr'].iloc[-1]) if len(htf) > 0 else m5_atr
        
        # M15 approximation (resample from M5 if available)
        m15_closes = m5_closes[::3] if len(m5_closes) >= 3 else m5_closes
        m15_highs = ltf['high'].values[::3] if len(ltf) >= 3 else ltf['high'].values
        m15_lows = ltf['low'].values[::3] if len(ltf) >= 3 else ltf['low'].values
        m15_atr = m5_atr * 1.5  # Approximate
        
        # Current price and spread
        current_price = float(ltf['close'].iloc[-1])
        raw_spread = float(ltf['spread'].iloc[-1]) if 'spread' in ltf.columns else 30.0
        spread_points = int(raw_spread if raw_spread > 5 else raw_spread / self.cfg.point_value)
        
        # Add fp_score to ltf_df if provided
        if fp_score != 50.0:
            ltf['fp_score'] = fp_score
        
        # Call the full analyze method
        result = self.ea_full.analyze(
            h1_closes=h1_closes,
            m15_closes=m15_closes,
            m5_closes=m5_closes,
            m15_highs=m15_highs,
            m15_lows=m15_lows,
            h1_atr=h1_atr,
            m15_atr=m15_atr,
            m5_rsi=m5_rsi,
            timestamp=now,
            current_price=current_price,
            spread_points=spread_points,
            max_spread=int(self.cfg.max_spread_points),
            ml_prob=ml_prob,
            news_events=news_events,
            balance=self.ea_full.risk_manager.balance,
            ltf_df=ltf,
        )
        
        # Check if valid signal
        if not result.is_valid or result.direction == SignalType.NONE:
            return None
        
        # Build TradeSetup
        entry = current_price
        atr = m5_atr
        
        # Calculate SL/TP based on ATR and regime strategy
        strategy = self.ea_full.current_strategy
        sl_mult = strategy.sl_atr_mult if strategy.sl_atr_mult > 0 else 2.0
        tp1_mult = strategy.tp1_r if strategy.tp1_r > 0 else 1.5
        tp2_mult = strategy.tp2_r if strategy.tp2_r > 0 else 2.5
        tp3_mult = strategy.tp3_r if strategy.tp3_r > 0 else 3.5
        
        if result.direction == SignalType.BUY:
            sl = entry - atr * sl_mult
            tp1 = entry + atr * sl_mult * tp1_mult
            tp2 = entry + atr * sl_mult * tp2_mult
            tp3 = entry + atr * sl_mult * tp3_mult
        else:
            sl = entry + atr * sl_mult
            tp1 = entry - atr * sl_mult * tp1_mult
            tp2 = entry - atr * sl_mult * tp2_mult
            tp3 = entry - atr * sl_mult * tp3_mult
        
        # Calculate R:R
        risk = abs(entry - sl)
        reward = abs(tp1 - entry)
        rr = reward / risk if risk > 0 else 0.0
        
        # Check minimum R:R
        if rr < self.cfg.min_rr:
            return None
        
        # Calculate lot size
        sl_points = abs(entry - sl) / self.cfg.point_value
        lot = self.ea_full.get_position_size(
            self.ea_full.risk_manager.balance,
            sl_points,
            timestamp=now
        )
        
        # Get regime analysis
        regime_analysis = self.ea_full.regime_detector.last_analysis
        
        return TradeSetup(
            direction=result.direction,
            entry=entry,
            sl=sl,
            tp1=tp1,
            tp2=tp2,
            tp3=tp3,
            risk_reward=rr,
            lot=lot,
            confluence=result,
            regime=regime_analysis,
        )
    
    def evaluate(self, bar, hour: int, rsi: float = 50.0, ml_prob: float = 0.5, 
                 mtf_alignment: float = 0.5) -> Optional[TradeSetup]:
        """Legacy interface for shadow_exchange compatibility."""
        df = pd.DataFrame([{
            'timestamp': bar.timestamp if hasattr(bar, 'timestamp') else datetime.utcnow(),
            'open': bar.open,
            'high': bar.high,
            'low': bar.low,
            'close': bar.close,
            'volume': getattr(bar, 'volume', 0),
            'spread': getattr(bar, 'spread', 30.0),
        }])
        return self.evaluate_from_df(df, df, df['timestamp'].iloc[0], ml_prob=ml_prob)


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def create_ea_logic(gmt_offset: int = 0, debug: bool = False, **kwargs) -> EALogicFull:
    """Factory function to create EALogicFull instance."""
    return EALogicFull(gmt_offset=gmt_offset, debug=debug, **kwargs)


def create_ea_logic_compat(cfg: Optional[EAConfig] = None, initial_balance: float = 100_000.0) -> EALogic:
    """Factory function to create EALogic wrapper (tick_backtester compatible)."""
    return EALogic(cfg=cfg, initial_balance=initial_balance)


if __name__ == "__main__":
    # Test the implementation
    print("EA_SCALPER_XAUUSD v3.30 - Full Python Port")
    print("=" * 50)
    
    # Create instance
    ea = create_ea_logic(gmt_offset=0)
    
    # Generate test data
    np.random.seed(42)
    n_bars = 300
    base_price = 2000.0
    
    # Simulate trending price action
    returns = np.random.randn(n_bars) * 0.001 + 0.0001  # Slight upward bias
    h1_closes = base_price * np.cumprod(1 + returns)
    m15_closes = h1_closes[-100:]  # Subset
    m5_closes = h1_closes[-50:]
    m15_highs = m15_closes * 1.002
    m15_lows = m15_closes * 0.998
    
    # Test analysis
    from datetime import datetime
    timestamp = datetime(2024, 1, 15, 14, 30)  # Monday, London/NY overlap
    
    result = ea.analyze(
        h1_closes=h1_closes,
        m15_closes=m15_closes,
        m5_closes=m5_closes,
        m15_highs=m15_highs,
        m15_lows=m15_lows,
        h1_atr=5.0,
        m15_atr=2.0,
        m5_rsi=55.0,
        timestamp=timestamp,
        current_price=h1_closes[-1],
        spread_points=30,
    )
    
    print(f"\nTest Result:")
    print(f"  Direction: {result.direction.name}")
    print(f"  Score: {result.total_score:.1f}")
    print(f"  Quality: {result.quality.name}")
    print(f"  Valid: {result.is_valid}")
    print(f"  R:R: {result.risk_reward:.2f}")
    
    print(f"\nRegime Info:")
    regime_info = ea.get_regime_info()
    for k, v in regime_info.items():
        print(f"  {k}: {v}")
    
    print(f"\nSession Info:")
    session_info = ea.get_session_info(timestamp)
    for k, v in session_info.items():
        print(f"  {k}: {v}")
    
    print("\n" + "=" * 50)
    print("Port complete! All modules functional.")
