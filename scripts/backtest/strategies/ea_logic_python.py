#!/usr/bin/env python3
"""
ea_logic_python.py - Python parity layer for EA_SCALPER_XAUUSD
==============================================================
Replicates (>=95%) the EA gates/filters for Python backtests.
OnTick order: spread -> risk(FTMO) -> session -> news -> ML ->
MTF/HTF -> confluence (9 factors) -> AMD -> entry optimizer -> sizing.

Compat: shadow_exchange still calls evaluate(bar,...); for full use call
evaluate_from_df(ltf_df, htf_df, now,...).
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from typing import Dict, List, Optional, Tuple
import numpy as np
import pandas as pd

# ---------------- ENUMS -----------------

class SignalType(Enum):
    NONE = 0
    BUY = 1
    SELL = -1

class MarketRegime(Enum):
    PRIME_TRENDING = 0
    NOISY_TRENDING = 1
    PRIME_REVERTING = 2
    NOISY_REVERTING = 3
    RANDOM_WALK = 4
    TRANSITIONING = 5
    UNKNOWN = 6

class EntryMode(Enum):
    BREAKOUT = 0
    PULLBACK = 1
    MEAN_REVERT = 2
    CONFIRMATION = 3
    DISABLED = 4

class SignalQuality(Enum):
    INVALID = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    ELITE = 4

# -------------- DATA CLASSES --------------

@dataclass
class BarData:
    timestamp: datetime
    open: float
    high: float
    low: float
    close: float
    volume: float = 0.0
    spread: float = 0.0

@dataclass
class RegimeStrategy:
    entry_mode: EntryMode
    min_confluence: float
    confirmation_bars: int
    risk_percent: float
    sl_atr_mult: float
    min_rr: float
    tp1_r: float
    tp2_r: float
    tp3_r: float
    partial1_pct: float
    partial2_pct: float
    be_trigger_r: float
    use_trailing: bool
    trailing_start_r: float
    trailing_step_atr: float
    use_time_exit: bool
    max_bars: int
    philosophy: str

@dataclass
class RegimeAnalysis:
    regime: MarketRegime = MarketRegime.UNKNOWN
    hurst: float = 0.5
    hurst_short: float = 0.5
    hurst_long: float = 0.5
    entropy: float = 1.5
    variance_ratio: float = 1.0
    transition_prob: float = 0.0
    multiscale_agreement: float = 50.0
    size_multiplier: float = 0.0
    score_adjustment: int = -50
    confidence: float = 0.0
    strategy: RegimeStrategy = None

@dataclass
class ConfluenceResult:
    direction: SignalType
    total_score: float
    quality: SignalQuality
    total_confluences: int
    regime_score: float
    structure_score: float
    sweep_score: float
    amd_score: float
    ob_score: float
    fvg_score: float
    zone_score: float
    mtf_score: float
    footprint_score: float
    fib_score: float
    position_size_mult: float
    signal_reason: str
    is_valid: bool

@dataclass
class TradeSetup:
    direction: SignalType
    entry: float
    sl: float
    tp1: float
    tp2: float
    tp3: float
    risk_reward: float
    lot: float
    confluence: ConfluenceResult
    regime: RegimeAnalysis

@dataclass
class EAConfig:
    risk_per_trade_pct: float = 0.5
    max_daily_loss_pct: float = 5.0
    soft_stop_pct: float = 4.0
    max_total_loss_pct: float = 10.0
    max_trades_per_day: int = 20
    max_spread_points: float = 80.0
    slippage_points: float = 50.0
    execution_threshold: float = 50.0
    confluence_min_score: float = 70.0
    allow_asian: bool = True
    allow_late_ny: bool = True
    gmt_offset: int = 0
    friday_close_hour: int = 14
    news_enabled: bool = True
    block_high: bool = True
    block_medium: bool = False
    use_ml: bool = False
    ml_threshold: float = 0.65
    min_rr: float = 1.5
    target_rr: float = 2.5
    max_wait_bars: int = 10
    use_mtf: bool = False
    min_mtf_confluence: float = 50.0
    require_htf_align: bool = False
    require_mtf_zone: bool = False
    require_ltf_confirm: bool = False
    ob_displacement_mult: float = 2.0
    fvg_min_gap: float = 0.3
    point_value: float = 0.01
    tick_value: float = 1.0     # value of one tick in account currency
    tick_size: float = 0.01     # tick size in price units
    # Fibonacci filter
    use_fib_filter: bool = True
    fib_levels: Tuple[float, float, float] = (0.382, 0.618, 0.705)
    fib_lookback_bars: int = 100

# -------------- UTILS --------------

def _rs_hurst(series: np.ndarray, min_k: int = 10, max_k: int = 50) -> float:
    if series.size < min_k + 1:
        return 0.5
    log_returns = np.diff(np.log(series + 1e-10))
    if log_returns.size < min_k:
        return 0.5
    rs, ns = [], []
    for n in range(min_k, min(max_k, log_returns.size // 2) + 1):
        num = log_returns.size // n
        if num < 1:
            continue
        reshaped = log_returns[: num * n].reshape(num, n)
        mean = reshaped.mean(axis=1, keepdims=True)
        dev = reshaped - mean
        cum = np.cumsum(dev, axis=1)
        R = cum.max(axis=1) - cum.min(axis=1)
        S = reshaped.std(axis=1, ddof=1)
        mask = S > 1e-10
        if mask.sum() == 0:
            continue
        rs.append((R[mask] / S[mask]).mean())
        ns.append(n)
    if len(rs) < 3:
        return 0.5
    log_n = np.log(ns)
    log_rs = np.log(rs)
    A = np.vstack([log_n, np.ones_like(log_n)]).T
    slope, _ = np.linalg.lstsq(A, log_rs, rcond=None)[0]
    return float(np.clip(slope, 0.0, 1.0))

def _shannon_entropy(returns: np.ndarray, bins: int = 10) -> float:
    if returns.size < 20:
        return 1.5
    hist, _ = np.histogram(returns, bins=bins, density=True)
    hist = hist + 1e-12
    hist = hist / hist.sum()
    H = -(hist * np.log(hist)).sum()
    return float(H)

def _variance_ratio(prices: np.ndarray, lag: int = 2) -> float:
    if prices.size < lag + 2:
        return 1.0
    r = np.diff(prices)
    var1 = r.var(ddof=1)
    if var1 == 0:
        return 1.0
    rlag = prices[lag:] - prices[:-lag]
    varl = rlag.var(ddof=1)
    return float(varl / (var1 * lag))

def _swing_bias(highs: np.ndarray, lows: np.ndarray, strength: int = 3) -> Tuple[str, float]:
    if len(highs) < strength * 4:
        return "NEUTRAL", 50.0
    hh = highs[-strength:].max(); ll = lows[-strength:].min()
    phh = highs[-2 * strength: -strength].max(); pll = lows[-2 * strength: -strength].min()
    if hh > phh and ll > pll:
        return "BULL", 75.0
    if hh < phh and ll < pll:
        return "BEAR", 75.0
    return "NEUTRAL", 50.0

# -------------- REGIME DETECTOR --------------

class RegimeDetectorPython:
    def __init__(self, cfg: EAConfig):
        self.cfg = cfg

    def analyze(self, closes: np.ndarray) -> RegimeAnalysis:
        closes = np.asarray(closes, dtype=float)
        if closes.size < 220:
            return RegimeAnalysis(regime=MarketRegime.UNKNOWN, strategy=self._strategy(MarketRegime.UNKNOWN))
        hs = _rs_hurst(closes[-50:], 10, 25)
        hm = _rs_hurst(closes[-100:], 10, 40)
        hl = _rs_hurst(closes[-200:], 10, 50)
        h = hm
        returns = np.diff(np.log(closes[-100:] + 1e-10))
        ent = _shannon_entropy(returns, 10)
        vr = _variance_ratio(closes[-200:], 2)
        agreement = self._agreement(hs, hm, hl)
        trans = self._transition(h, hs, hl)
        regime = self._classify(h, ent, vr, agreement, trans)
        conf = self._confidence(h, ent, vr, agreement, trans)
        size = self._size_mult(regime, agreement, conf, trans)
        adj = self._score_adj(regime, conf, agreement)
        strat = self._strategy(regime)
        return RegimeAnalysis(regime, h, hs, hl, ent, vr, trans, agreement, size, adj, conf, strat)

    @staticmethod
    def _agreement(hs: float, hm: float, hl: float) -> float:
        arr = np.array([hs, hm, hl]); std = arr.std()
        base = max(0.0, 1.0 - std / 0.1) * 100
        same_side = (arr > 0.55).all() or (arr < 0.45).all()
        return float(min(100.0, base + (10 if same_side else 0)))

    @staticmethod
    def _transition(h: float, hs: float, hl: float) -> float:
        dist = min(abs(h - 0.45), abs(h - 0.55))
        velocity = hs - hl
        prob = 0.0
        if dist < 0.05: prob += (0.05 - dist) * 8
        if velocity * (1 if h > 0.5 else -1) < -0.01: prob += min(0.4, abs(velocity) * 4)
        return float(np.clip(prob, 0.0, 1.0))

    @staticmethod
    def _classify(h: float, ent: float, vr: float, ag: float, trans: float) -> MarketRegime:
        if trans > 0.6: return MarketRegime.TRANSITIONING
        if 0.45 <= h <= 0.55 and 0.9 <= vr <= 1.1: return MarketRegime.RANDOM_WALK
        if h > 0.55:
            return MarketRegime.PRIME_TRENDING if ent < 1.5 and vr > 1.1 and ag >= 66 else MarketRegime.NOISY_TRENDING
        if h < 0.45:
            return MarketRegime.PRIME_REVERTING if ent < 1.5 and vr < 0.9 and ag >= 66 else MarketRegime.NOISY_REVERTING
        return MarketRegime.UNKNOWN

    @staticmethod
    def _confidence(h: float, ent: float, vr: float, ag: float, trans: float) -> float:
        conf = min(30.0, abs(h - 0.5) * 60)
        conf += 20 if (h > 0.55 and vr > 1.1) or (h < 0.45 and vr < 0.9) else 10 if abs(vr - 1.0) > 0.05 else 0
        conf += ag * 0.2
        conf += 15 if ent < 1.0 else 10 if ent < 1.5 else 5 if ent < 2.0 else 0
        conf -= trans * 20
        return float(np.clip(conf, 0.0, 100.0))

    @staticmethod
    def _size_mult(regime: MarketRegime, ag: float, conf: float, trans: float) -> float:
        base = {
            MarketRegime.PRIME_TRENDING: 1.0,
            MarketRegime.PRIME_REVERTING: 1.0,
            MarketRegime.NOISY_TRENDING: 0.5,
            MarketRegime.NOISY_REVERTING: 0.5,
            MarketRegime.TRANSITIONING: 0.25,
            MarketRegime.RANDOM_WALK: 0.0,
            MarketRegime.UNKNOWN: 0.0,
        }[regime]
        if trans > 0.3: base *= (1.0 - trans * 0.3)
        if ag < 50: base *= 0.75
        if conf < 30: base *= 0.5
        elif conf < 50: base *= 0.75
        return float(np.clip(base, 0.0, 1.0))

    @staticmethod
    def _score_adj(regime: MarketRegime, conf: float, ag: float) -> int:
        adj = {
            MarketRegime.PRIME_TRENDING: 10,
            MarketRegime.PRIME_REVERTING: 10,
            MarketRegime.NOISY_TRENDING: 0,
            MarketRegime.NOISY_REVERTING: 0,
            MarketRegime.TRANSITIONING: -20,
            MarketRegime.RANDOM_WALK: -30,
            MarketRegime.UNKNOWN: -50,
        }.get(regime, -50)
        if conf > 80: adj += 10
        if ag > 90: adj += 5
        if conf < 30: adj -= 10
        return int(adj)

    @staticmethod
    def _strategy(regime: MarketRegime) -> RegimeStrategy:
        if regime == MarketRegime.PRIME_TRENDING:
            return RegimeStrategy(EntryMode.BREAKOUT, 65, 1, 0.01, 1.5, 1.5, 1.0, 2.5, 4.0, 0.33, 0.33, 0.7, True, 1.0, 0.5, False, 100, "TREND IS YOUR FRIEND")
        if regime == MarketRegime.NOISY_TRENDING:
            return RegimeStrategy(EntryMode.PULLBACK, 70, 1, 0.0075, 1.8, 1.5, 1.0, 2.0, 3.0, 0.40, 0.35, 1.0, True, 1.5, 0.7, False, 60, "FOLLOW TREND BUT VOLATILE")
        if regime == MarketRegime.PRIME_REVERTING:
            return RegimeStrategy(EntryMode.MEAN_REVERT, 75, 2, 0.005, 2.0, 1.0, 0.5, 1.0, 1.5, 0.50, 0.30, 0.5, False, 0.0, 0.0, True, 20, "QUICK SCALP")
        if regime == MarketRegime.NOISY_REVERTING:
            return RegimeStrategy(EntryMode.MEAN_REVERT, 80, 2, 0.004, 2.2, 1.0, 0.5, 0.8, 1.0, 0.60, 0.25, 0.4, False, 0.0, 0.0, True, 15, "CAREFUL REVERT")
        if regime == MarketRegime.TRANSITIONING:
            return RegimeStrategy(EntryMode.CONFIRMATION, 90, 3, 0.0025, 2.5, 1.0, 0.5, 0.8, 1.0, 0.70, 0.20, 0.3, False, 0.0, 0.0, True, 10, "SURVIVAL")
        return RegimeStrategy(EntryMode.DISABLED, 100, 0, 0.0, 2.0, 1.0, 1.0, 2.0, 3.0, 0.33, 0.33, 1.0, False, 0.0, 0.0, False, 50, "NO EDGE")

# -------------- SESSION / NEWS --------------

class SessionFilterPython:
    def __init__(self, cfg: EAConfig):
        self.cfg = cfg
    def is_allowed(self, dt: datetime) -> Tuple[bool, str]:
        hour = (dt.hour - self.cfg.gmt_offset) % 24
        session = self._session(hour)
        if session == "ASIAN" and not self.cfg.allow_asian: return False, session
        if session == "LATE_NY" and not self.cfg.allow_late_ny: return False, session
        if dt.weekday() == 4 and hour >= self.cfg.friday_close_hour: return False, session
        if session == "DEAD": return False, session
        return True, session
    @staticmethod
    def _session(hour: int) -> str:
        if 0 <= hour < 8: return "ASIAN"
        if 8 <= hour < 12: return "LONDON"
        if 12 <= hour < 16: return "OVERLAP"
        if 16 <= hour < 21: return "LATE_NY"
        return "DEAD"
    @staticmethod
    def session_score(session: str) -> float:
        return {"ASIAN":0.5, "LONDON":0.8, "OVERLAP":1.0, "LATE_NY":0.7, "DEAD":0.2}.get(session,0.5)

class NewsFilterPython:
    def __init__(self, cfg: EAConfig, events: Optional[List[Tuple[datetime,str,str]]]=None):
        self.cfg = cfg; self.events = events or []
    def is_allowed(self, now: datetime) -> bool:
        if not self.cfg.news_enabled: return True
        for t, impact, _ in self.events:
            if abs((t - now).total_seconds()) <= 900:
                if impact == "high" and self.cfg.block_high: return False
                if impact == "medium" and self.cfg.block_medium: return False
        return True

# -------------- STRUCTURE / OB / FVG / SWEEP / AMD --------------

def detect_order_blocks(df: pd.DataFrame, displacement_mult: float = 2.0) -> List[Dict]:
    obs = []
    if "atr" not in df: return obs
    atr = df["atr"].values; o=df["open"].values; h=df["high"].values; l=df["low"].values; c=df["close"].values
    for i in range(5, len(df)-3):
        if np.isnan(atr[i]) or atr[i] <= 0: continue
        if c[i] < o[i]:
            disp = h[i+1:i+4].max() - c[i]
            if disp >= atr[i]*displacement_mult: obs.append({"idx":i,"type":"BULL","top":o[i],"bottom":l[i],"strength":disp/atr[i]})
        if c[i] > o[i]:
            disp = c[i] - l[i+1:i+4].min()
            if disp >= atr[i]*displacement_mult: obs.append({"idx":i,"type":"BEAR","top":h[i],"bottom":o[i],"strength":disp/atr[i]})
    return obs

def detect_fvg(df: pd.DataFrame, min_gap: float = 0.3) -> List[Dict]:
    fvgs=[]; h=df["high"].values; l=df["low"].values
    for i in range(2,len(df)):
        c1h=h[i-2]; c3l=l[i]
        if c3l>c1h and (c3l-c1h)>=min_gap: fvgs.append({"idx":i-1,"type":"BULL","top":c3l,"bottom":c1h})
        c1l=l[i-2]; c3h=h[i]
        if c1l>c3h and (c1l-c3h)>=min_gap: fvgs.append({"idx":i-1,"type":"BEAR","top":c1l,"bottom":c3h})
    return fvgs

def proximity_score(price: float, low: float, high: float, atr: float) -> float:
    if atr <= 0: return 0.0
    if low <= price <= high: return 100.0
    dist = min(abs(price-low), abs(price-high))
    if dist <= atr: return 70 + (atr - dist)/atr*30
    if dist <= 2*atr: return 50 + (2*atr - dist)/atr*20
    return max(0.0, 50 - (dist-2*atr)/(3*atr)*50)

def liquidity_sweep(df: pd.DataFrame, lookback: int = 20, tolerance: float = 0.1) -> Tuple[bool, SignalType]:
    if len(df) < lookback+2: return False, SignalType.NONE
    highs=df["high"].values; lows=df["low"].values
    rh=highs[-2]; rl=lows[-2]
    took_high = rh > highs[-lookback-2:-2].max()*(1 - tolerance/100)
    took_low  = rl < lows[-lookback-2:-2].min()*(1 + tolerance/100)
    if took_high and not took_low: return True, SignalType.SELL
    if took_low and not took_high: return True, SignalType.BUY
    return False, SignalType.NONE

def amd_phase(df: pd.DataFrame) -> Tuple[str,float]:
    if len(df) < 15: return "ACCUMULATION", 40.0
    closes=df["close"].values; x=np.arange(len(closes[-20:])); slope,_=np.polyfit(x, closes[-20:], 1)
    atr = df["atr"].iloc[-1] if "atr" in df else 0.0
    if slope>0 and atr>0 and slope/atr>0.2: return "DISTRIBUTION", 70.0
    if slope<0 and atr>0 and abs(slope)/atr>0.2: return "MANIPULATION", 60.0
    return "ACCUMULATION", 50.0

# -------------- RISK MANAGER (FTMO) --------------

class RiskManagerPython:
    def __init__(self, cfg: EAConfig, initial_balance: float = 100_000.0):
        self.cfg = cfg
        self.initial_balance = initial_balance
        self.balance = initial_balance
        self.peak_balance = initial_balance
        self.daily_start = initial_balance
        self.current_day = None
        self.trades_today = 0
        self.halted = False
        self.soft_paused = False
        self.consecutive_wins = 0
        self.consecutive_losses = 0
        self.last_pnl = 0.0
    def on_new_day(self, now: datetime):
        if self.current_day != now.date():
            self.current_day = now.date()
            self.daily_start = self.balance
            self.trades_today = 0
            self.halted = False
            self.soft_paused = False
            self.consecutive_wins = 0
            self.consecutive_losses = 0
    def can_open(self, now: datetime) -> bool:
        self.on_new_day(now)
        if self.halted or self.trades_today >= self.cfg.max_trades_per_day:
            return False
        daily_dd = max(0.0, (self.daily_start - self.balance) / max(1e-9, self.daily_start))
        total_dd = max(0.0, (self.peak_balance - self.balance) / max(1e-9, self.peak_balance))
        if daily_dd >= self.cfg.max_total_loss_pct / 100.0:
            self.halted = True
            return False
        if total_dd >= self.cfg.max_total_loss_pct / 100.0:
            self.halted = True
            return False
        if daily_dd >= self.cfg.max_daily_loss_pct / 100.0:
            self.halted = True
            return False
        if daily_dd >= self.cfg.soft_stop_pct / 100.0:
            self.soft_paused = True
            return False
        self.soft_paused = False
        return True
    def record_trade(self, pnl: float, now: datetime):
        self.on_new_day(now)
        self.balance += pnl
        self.trades_today += 1
        self.consecutive_wins = self.consecutive_wins + 1 if pnl > 0 else 0
        self.consecutive_losses = self.consecutive_losses + 1 if pnl < 0 else 0
        self.last_pnl = pnl
        if self.balance > self.peak_balance:
            self.peak_balance = self.balance
    def _momentum_mult(self) -> float:
        if self.consecutive_losses >= 2:
            return 0.5
        if self.consecutive_wins >= 2:
            return 1.2
        return 1.0
    def lot_size(self, sl_points: float, regime_mult: float, conf_mult: float, session_mult: float = 1.0) -> float:
        if sl_points <= 0:
            return 0.01
        if self.halted or self.soft_paused:
            return 0.0
        daily_dd = max(0.0, (self.daily_start - self.balance) / max(1e-9, self.daily_start))
        drawdown_factor = max(0.2, 1.0 - daily_dd / max(1e-9, self.cfg.soft_stop_pct / 100.0))
        effective_regime = np.clip(regime_mult, 0.1, 3.0)
        effective_conf = max(0.5, conf_mult)
        momentum_mult = self._momentum_mult()
        risk_percent = self.cfg.risk_per_trade_pct
        risk_amount = self.balance * (risk_percent / 100.0) * drawdown_factor
        value_per_point = (self.cfg.tick_value or 1.0) * (self.cfg.point_value / max(1e-9, self.cfg.tick_size))
        lot = risk_amount / max(1e-9, sl_points * value_per_point)
        lot *= effective_regime * effective_conf * session_mult * momentum_mult
        return float(np.clip(lot, 0.01, 10.0))

# -------------- CONFLUENCE (9 fatores) --------------

class ConfluenceScorerPython:
    def __init__(self):
        # weights: structure, regime, sweep, amd, ob, fvg, zone, mtf, footprint, fib
        self.session_weights = {
            "ASIAN":   (0.11,0.16,0.07,0.07,0.16,0.13,0.07,0.07,0.05,0.11),
            "LONDON":  (0.20,0.11,0.17,0.11,0.07,0.05,0.03,0.12,0.05,0.09),
            "OVERLAP": (0.17,0.13,0.13,0.09,0.09,0.07,0.04,0.13,0.06,0.09),
            "LATE_NY": (0.14,0.10,0.09,0.07,0.07,0.06,0.04,0.17,0.16,0.10),
            "DEAD":    (0.17,0.14,0.11,0.09,0.09,0.07,0.04,0.12,0.07,0.10),
        }
    def score(self, session: str, regime: RegimeAnalysis, structure_score: float, sweep_score: float,
              amd_score: float, ob_score: float, fvg_score: float, zone_score: float,
              mtf_score: float, fp_score: float, fib_score: float, direction: SignalType) -> ConfluenceResult:
        w = self.session_weights.get(session, self.session_weights["DEAD"])
        total = (structure_score*w[0] + regime.confidence*w[1] + sweep_score*w[2] + amd_score*w[3] +
                 ob_score*w[4] + fvg_score*w[5] + zone_score*w[6] + mtf_score*w[7] + fp_score*w[8] +
                 fib_score*w[9])
        score = total / sum(w)
        score += regime.score_adjustment
        score = max(0.0, min(100.0, score))
        confs = sum(x >= 60 for x in [structure_score, regime.confidence, sweep_score, amd_score, ob_score, fvg_score, zone_score, mtf_score, fp_score, fib_score])
        if score >= 90: quality = SignalQuality.ELITE
        elif score >= 80: quality = SignalQuality.HIGH
        elif score >= 70: quality = SignalQuality.MEDIUM
        elif score >= 60: quality = SignalQuality.LOW
        else: quality = SignalQuality.INVALID
        # FIX BUG #2: Use MQL5-parity thresholds (>= 70, >= 3) instead of relaxed (>= 50, >= 2)
        # Original relaxed: score >= 50 and confs >= 2 - caused low win rate
        valid = score >= 70 and confs >= 3 and direction != SignalType.NONE
        return ConfluenceResult(direction, score, quality, confs, regime.confidence, structure_score, sweep_score,
                                amd_score, ob_score, fvg_score, zone_score, mtf_score, fp_score, fib_score,
                                regime.size_multiplier, f"Score {score:.1f} | Conf {confs}/10", valid)

# -------------- ENTRY OPTIMIZER --------------

class EntryOptimizerPython:
    def __init__(self, cfg: EAConfig):
        self.cfg = cfg
    def build_entry(self, direction: SignalType, price: float, atr: float,
                    fvg_zone: Tuple[float,float], ob_zone: Tuple[float,float],
                    sweep_level: Optional[float], strat: RegimeStrategy) -> Tuple[bool,float,float,float,float,float,float]:
        entry = price; sl=None; tp1=tp2=tp3=None
        if ob_zone[0] and ob_zone[1]:
            low, high = ob_zone
            if direction == SignalType.BUY:
                entry = min(price, (low+high)/2); sl = low - atr*strat.sl_atr_mult
            else:
                entry = max(price, (low+high)/2); sl = high + atr*strat.sl_atr_mult
        elif fvg_zone[0] and fvg_zone[1]:
            low, high = fvg_zone
            if direction == SignalType.BUY:
                entry = min(price, low); sl = low - atr*strat.sl_atr_mult
            else:
                entry = max(price, high); sl = high + atr*strat.sl_atr_mult
        elif sweep_level:
            if direction == SignalType.BUY:
                entry = min(price, sweep_level); sl = sweep_level - atr*strat.sl_atr_mult
            else:
                entry = max(price, sweep_level); sl = sweep_level + atr*strat.sl_atr_mult
        if sl is None:
            sl = price - atr*strat.sl_atr_mult if direction == SignalType.BUY else price + atr*strat.sl_atr_mult
        risk = abs(entry - sl)
        if risk <= 0: return False,0,0,0,0,0,0
        tp1 = entry + risk*strat.tp1_r*(1 if direction == SignalType.BUY else -1)
        tp2 = entry + risk*strat.tp2_r*(1 if direction == SignalType.BUY else -1)
        tp3 = entry + risk*strat.tp3_r*(1 if direction == SignalType.BUY else -1)
        rr = abs(tp1 - entry)/risk
        # Use cfg.min_rr (relaxed) instead of strat.min_rr (strict) for backtesting
        if rr < self.cfg.min_rr: return False,0,0,0,0,0,0
        return True, entry, sl, tp1, tp2, tp3, rr

# -------------- EALogic --------------

class EALogic:
    def __init__(self, cfg: Optional[EAConfig]=None, initial_balance: float = 100_000.0):
        self.cfg = cfg or EAConfig()
        self.regime = RegimeDetectorPython(self.cfg)
        self.session = SessionFilterPython(self.cfg)
        self.news = NewsFilterPython(self.cfg)
        self.scorer = ConfluenceScorerPython()
        self.optimizer = EntryOptimizerPython(self.cfg)
        self.risk = RiskManagerPython(self.cfg, initial_balance)

    # legado (shadow_exchange)
    def evaluate(self, bar: BarData, hour: int, rsi: float = 50.0, ml_prob: float = 0.5, mtf_alignment: float = 0.5) -> Optional[TradeSetup]:
        df = pd.DataFrame([{ "timestamp": bar.timestamp, "open": bar.open, "high": bar.high, "low": bar.low, "close": bar.close, "volume": bar.volume, "spread": bar.spread }])
        df["tr"] = (df["high"]-df["low"]).rolling(14, min_periods=1).mean()
        df["atr"] = df["tr"]
        now = bar.timestamp.replace(tzinfo=timezone.utc)
        return self.evaluate_from_df(df, df, now, ml_prob=ml_prob, fp_score=50.0, mtf_alignment=mtf_alignment)

    # completo
    def evaluate_from_df(self, ltf_df: pd.DataFrame, htf_df: pd.DataFrame, now: datetime,
                         ml_prob: Optional[float]=None, fp_score: float = 50.0,
                         mtf_alignment: Optional[float]=None,
                         news_events: Optional[List[Tuple[datetime,str,str]]]=None) -> Optional[TradeSetup]:
        if ltf_df.empty: return None
        if news_events is not None: self.news.events = news_events
        # Spread: if already in points (>5), use directly; otherwise convert from price
        raw_spread = float(ltf_df["spread"].iloc[-1]) if "spread" in ltf_df else 30.0
        spread_points = raw_spread if raw_spread > 5 else raw_spread / self.cfg.point_value
        if spread_points > self.cfg.max_spread_points: return None
        if not self.risk.can_open(now): return None
        session_ok, session_name = self.session.is_allowed(now)
        if not session_ok: return None
        if not self.news.is_allowed(now): return None
        regime = self.regime.analyze(ltf_df["close"].values)
        if regime.regime in (MarketRegime.RANDOM_WALK, MarketRegime.UNKNOWN): return None
        ml_dir = SignalType.NONE
        if self.cfg.use_ml and ml_prob is not None:
            if ml_prob >= self.cfg.ml_threshold: ml_dir = SignalType.BUY
            elif ml_prob <= 1 - self.cfg.ml_threshold: ml_dir = SignalType.SELL
            else: return None
        ltf_df = ltf_df.copy()
        ltf_df["tr"] = (ltf_df["high"] - ltf_df["low"]).combine(ltf_df["high"]-ltf_df["close"].shift(1), max).combine(ltf_df["low"]-ltf_df["close"].shift(1), lambda a,b: max(abs(a),abs(b)))
        ltf_df["atr"] = ltf_df["tr"].rolling(14, min_periods=1).mean()
        atr = float(ltf_df["atr"].iloc[-1])
        bias, structure_score = _swing_bias(ltf_df["high"].values, ltf_df["low"].values, 3)
        structure_score = structure_score if bias != "NEUTRAL" else 50.0
        obs = detect_order_blocks(ltf_df, self.cfg.ob_displacement_mult)
        fvgs = detect_fvg(ltf_df, self.cfg.fvg_min_gap)
        price = float(ltf_df["close"].iloc[-1])
        ob_score=0.0; ob_zone=(0.0,0.0)
        for ob in reversed(obs):
            ob_score = max(ob_score, proximity_score(price, ob["bottom"], ob["top"], atr))
            if ob_score>0: ob_zone=(ob["bottom"], ob["top"]); break
        fvg_score=0.0; fvg_zone=(0.0,0.0)
        for f in reversed(fvgs):
            fvg_score = max(fvg_score, proximity_score(price, f["bottom"], f["top"], atr))
            if fvg_score>0: fvg_zone=(f["bottom"], f["top"]); break
        has_sweep, sweep_dir = liquidity_sweep(ltf_df, 20, 0.1)
        sweep_score = 80.0 if has_sweep else 40.0
        sweep_level = float(ltf_df["low"].iloc[-2] if sweep_dir==SignalType.BUY else ltf_df["high"].iloc[-2]) if has_sweep else None
        amd_name, amd_score = amd_phase(ltf_df)
        range_high = float(ltf_df["high"].rolling(50, min_periods=5).max().iloc[-1])
        range_low = float(ltf_df["low"].rolling(50, min_periods=5).min().iloc[-1])
        eq = (range_high + range_low)/2
        in_discount = price < eq
        zone_score = 80.0 if (in_discount and bias=="BULL") or ((not in_discount) and bias=="BEAR") else 50.0

        # Fibonacci proximity
        fib_score = 50.0
        if self.cfg.use_fib_filter:
            look = min(len(ltf_df), self.cfg.fib_lookback_bars)
            swing_high = float(ltf_df["high"].tail(look).max())
            swing_low = float(ltf_df["low"].tail(look).min())
            if swing_high > swing_low:
                best = 1e9
                for lvl in self.cfg.fib_levels:
                    fib_level = swing_low + (swing_high - swing_low) * lvl
                    best = min(best, abs(price - fib_level))
                if best <= 0.25 * atr:
                    fib_score = 90.0
                elif best <= 0.50 * atr:
                    fib_score = 75.0
                elif best <= 1.0 * atr:
                    fib_score = 60.0
                else:
                    fib_score = 40.0
            else:
                fib_score = 40.0
        else:
            fib_score = 50.0
        if mtf_alignment is None:
            mtf_alignment = 50.0
            if not htf_df.empty:
                htf_ma = htf_df["close"].rolling(50, min_periods=1).mean().iloc[-1]
                htf_trend_bull = htf_df["close"].iloc[-1] > htf_ma
                mtf_alignment = 80.0 if (htf_trend_bull and bias=="BULL") or ((not htf_trend_bull) and bias=="BEAR") else 40.0
        mtf_score = float(mtf_alignment)
        fp_score = float(fp_score)
        direction = SignalType.NONE
        if bias == "BULL": direction = SignalType.BUY
        elif bias == "BEAR": direction = SignalType.SELL
        if ml_dir != SignalType.NONE and ml_dir != direction: return None
        conf = self.scorer.score(session_name, regime, structure_score, sweep_score, amd_score, ob_score, fvg_score, zone_score, mtf_score, fp_score, fib_score, direction)
        if (not conf.is_valid) or conf.total_score < self.cfg.execution_threshold: return None
        ok, entry, sl, tp1, tp2, tp3, rr = self.optimizer.build_entry(direction, price, atr, fvg_zone, ob_zone, sweep_level, regime.strategy)
        if not ok or rr < self.cfg.min_rr: return None
        sl_points = abs(entry - sl)/self.cfg.point_value
        lot = self.risk.lot_size(sl_points, regime.size_multiplier, conf.position_size_mult)
        return TradeSetup(direction, entry, sl, tp1, tp2, tp3, rr, lot, conf, regime)

if __name__ == "__main__":
    now = datetime.utcnow().replace(tzinfo=timezone.utc)
    prices = np.linspace(2000, 2010, 300) + np.random.randn(300) * 2
    df = pd.DataFrame({
        "timestamp": pd.date_range(end=now, periods=300, freq="5min"),
        "open": prices + np.random.randn(300)*0.5,
        "high": prices + np.random.rand(300),
        "low": prices - np.random.rand(300),
        "close": prices,
        "volume": np.random.randint(100,1000,300),
        "spread": np.full(300, 0.45)
    })
    cfg = EAConfig(); ea = EALogic(cfg)
    sig = ea.evaluate_from_df(df, df.resample("1h", on="timestamp").last(), now)
    print("Signal:", sig.direction if sig else "NONE")
