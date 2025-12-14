#!/usr/bin/env python3
"""
ea_logic_compat.py - Compatibility layer for backtester
========================================================
Provides simple interfaces that the realistic_backtester needs,
wrapping the more complex ea_logic_python.py classes.
"""

import numpy as np
from dataclasses import dataclass
from enum import Enum
from typing import Dict, Optional


class Regime(Enum):
    TRENDING = 1
    RANGING = 0
    REVERTING = -1
    RANDOM = -2


class Session(Enum):
    ASIA = 'ASIA'
    LONDON = 'LONDON'
    OVERLAP = 'OVERLAP'
    NY = 'NY'
    CLOSE = 'CLOSE'


class SignalType(Enum):
    BUY = 1
    SELL = -1
    NONE = 0


@dataclass
class Signal:
    """Trade signal for backtester"""
    signal_type: SignalType
    confidence: float
    confluence_score: float
    regime_score: float
    session_score: float
    mtf_alignment: float
    entry_price: float
    sl_price: float
    tp_price: float
    lot_size: float
    risk_reward: float


@dataclass
class BarData:
    """Single bar data"""
    timestamp: float
    open: float
    high: float
    low: float
    close: float
    volume: float = 0


class RegimeDetector:
    """Simple regime detector using Hurst exponent"""
    
    HURST_TRENDING = 0.55
    HURST_REVERTING = 0.45
    
    def __init__(self, window: int = 100):
        self.window = window
        self.prices = []
        self.current_regime = Regime.RANGING
        self.hurst = 0.5
        self.entropy = 0.5
    
    def update(self, price: float) -> Regime:
        self.prices.append(price)
        if len(self.prices) > self.window * 2:
            self.prices = self.prices[-self.window * 2:]
        
        if len(self.prices) >= self.window:
            self.hurst = self._calculate_hurst()
            self.entropy = self._calculate_entropy()
            self.current_regime = self._classify_regime()
        
        return self.current_regime
    
    def _calculate_hurst(self) -> float:
        prices = np.array(self.prices[-self.window:])
        returns = np.diff(np.log(prices + 1e-10))
        if len(returns) < 2:
            return 0.5
        
        mean_ret = np.mean(returns)
        deviations = returns - mean_ret
        cum_dev = np.cumsum(deviations)
        R = np.max(cum_dev) - np.min(cum_dev)
        S = np.std(returns, ddof=1)
        
        if S > 1e-10 and R > 1e-10:
            RS = R / S
            n = len(returns)
            H = np.log(RS) / np.log(n)
            return np.clip(H, 0, 1)
        return 0.5
    
    def _calculate_entropy(self) -> float:
        prices = np.array(self.prices[-50:])
        if len(prices) < 10:
            return 0.5
        returns = np.diff(prices) / (prices[:-1] + 1e-10)
        if len(returns) < 10:
            return 0.5
        hist, _ = np.histogram(returns, bins=10, density=True)
        hist = hist + 1e-10
        hist = hist / hist.sum()
        H = -np.sum(hist * np.log(hist))
        return H / np.log(10)
    
    def _classify_regime(self) -> Regime:
        if self.hurst > self.HURST_TRENDING:
            return Regime.TRENDING
        elif self.hurst < self.HURST_REVERTING:
            return Regime.REVERTING
        elif self.entropy > 0.9:
            return Regime.RANDOM
        return Regime.RANGING


class SessionFilter:
    """Session classifier"""
    
    SESSION_HOURS = {
        Session.ASIA: (0, 7),
        Session.LONDON: (7, 12),
        Session.OVERLAP: (12, 16),
        Session.NY: (16, 21),
        Session.CLOSE: (21, 24),
    }
    
    SESSION_SCORES = {
        Session.ASIA: 0.5,
        Session.LONDON: 0.8,
        Session.OVERLAP: 1.0,
        Session.NY: 0.7,
        Session.CLOSE: 0.3,
    }
    
    @classmethod
    def get_session(cls, hour: int) -> Session:
        for session, (start, end) in cls.SESSION_HOURS.items():
            if start <= hour < end:
                return session
        return Session.CLOSE
    
    @classmethod
    def get_session_score(cls, session: Session) -> float:
        return cls.SESSION_SCORES.get(session, 0.5)


class ConfluenceScorer:
    """Scores trade setups"""
    
    def __init__(self):
        self.weights = {
            'regime': 0.25,
            'session': 0.15,
            'mtf': 0.20,
            'rsi': 0.15,
            'structure': 0.15,
            'ml': 0.10
        }
    
    def score(self, factors: Dict[str, float]) -> float:
        total = 0
        weight_sum = 0
        for key, weight in self.weights.items():
            if key in factors:
                total += factors[key] * weight * 100
                weight_sum += weight
        return total / weight_sum if weight_sum > 0 else 0


class RiskManager:
    """Position sizing with Kelly"""
    
    def __init__(self, account_balance: float = 100000):
        self.account_balance = account_balance
        self.wins = 0
        self.losses = 0
        self.total_win = 0
        self.total_loss = 0
    
    def calculate_lot_size(self, sl_pips: float, regime_score: float = 1.0,
                           session_score: float = 1.0) -> float:
        base_risk = 0.01 * self.account_balance
        kelly = self._calculate_kelly()
        risk_amount = base_risk * kelly * regime_score * session_score
        lot_size = risk_amount / (sl_pips * 10.0 + 1e-10)
        return np.clip(lot_size, 0.01, 5.0)
    
    def _calculate_kelly(self) -> float:
        total = self.wins + self.losses
        if total < 30:
            return 0.25
        win_rate = self.wins / total
        if self.total_loss == 0:
            return 0.5
        avg_win = self.total_win / max(1, self.wins)
        avg_loss = abs(self.total_loss) / max(1, self.losses)
        if avg_loss == 0:
            return 0.5
        payoff = avg_win / avg_loss
        kelly = (win_rate * payoff - (1 - win_rate)) / payoff
        return np.clip(kelly * 0.5, 0.1, 0.5)
    
    def update_trade_result(self, pnl: float):
        if pnl > 0:
            self.wins += 1
            self.total_win += pnl
        else:
            self.losses += 1
            self.total_loss += abs(pnl)


class EALogic:
    """Main EA trading logic"""
    
    MIN_CONFLUENCE = 65
    TARGET_RR = 2.5
    
    def __init__(self, account_balance: float = 100000):
        self.regime_detector = RegimeDetector()
        self.confluence_scorer = ConfluenceScorer()
        self.risk_manager = RiskManager(account_balance)
    
    def evaluate(self, bar: BarData, hour: int, 
                 rsi: float = 50, ml_prob: float = 0.5,
                 mtf_alignment: float = 0.5) -> Optional[Signal]:
        
        regime = self.regime_detector.update(bar.close)
        
        if regime == Regime.RANDOM:
            return None
        
        session = SessionFilter.get_session(hour)
        session_score = SessionFilter.get_session_score(session)
        
        regime_score = 1.0 if regime == Regime.TRENDING else (0.7 if regime == Regime.REVERTING else 0.5)
        
        direction = self._get_direction(bar, rsi, ml_prob, regime)
        if direction == SignalType.NONE:
            return None
        
        factors = {
            'regime': regime_score,
            'session': session_score,
            'mtf': mtf_alignment,
            'rsi': self._rsi_score(rsi, direction),
            'structure': 0.5,
            'ml': ml_prob if direction == SignalType.BUY else (1 - ml_prob)
        }
        
        confluence = self.confluence_scorer.score(factors)
        if confluence < self.MIN_CONFLUENCE:
            return None
        
        entry = bar.close
        atr = (bar.high - bar.low) * 2
        
        if direction == SignalType.BUY:
            sl = entry - atr * 1.5
            tp = entry + atr * self.TARGET_RR * 1.5
        else:
            sl = entry + atr * 1.5
            tp = entry - atr * self.TARGET_RR * 1.5
        
        sl_pips = abs(entry - sl) / 0.01
        lot_size = self.risk_manager.calculate_lot_size(sl_pips, regime_score, session_score)
        rr = abs(tp - entry) / (abs(entry - sl) + 1e-10)
        
        return Signal(
            signal_type=direction,
            confidence=confluence,
            confluence_score=confluence,
            regime_score=regime_score,
            session_score=session_score,
            mtf_alignment=mtf_alignment,
            entry_price=entry,
            sl_price=sl,
            tp_price=tp,
            lot_size=lot_size,
            risk_reward=rr
        )
    
    def _get_direction(self, bar: BarData, rsi: float, 
                       ml_prob: float, regime: Regime) -> SignalType:
        if regime == Regime.TRENDING:
            if ml_prob > 0.65:
                return SignalType.BUY
            elif ml_prob < 0.35:
                return SignalType.SELL
        elif regime == Regime.REVERTING:
            if rsi < 30 and ml_prob > 0.5:
                return SignalType.BUY
            elif rsi > 70 and ml_prob < 0.5:
                return SignalType.SELL
        return SignalType.NONE
    
    def _rsi_score(self, rsi: float, direction: SignalType) -> float:
        if direction == SignalType.BUY:
            return 1.0 if rsi < 30 else (0.7 if rsi < 50 else 0.3)
        return 1.0 if rsi > 70 else (0.7 if rsi > 50 else 0.3)
