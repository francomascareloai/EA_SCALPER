#!/usr/bin/env python3
"""
adaptive_kelly_sizer.py - Adaptive Kelly position sizing for live trading.

BATCH 6: Implements real-time Kelly criterion with sample size correction.

Features:
- Rolling Kelly calculation with confidence intervals
- Regime-aware sizing
- FTMO limit enforcement
- Drawdown-based reduction

Usage:
    from scripts.live.adaptive_kelly_sizer import AdaptiveKellySizer
    
    sizer = AdaptiveKellySizer()
    lot_size = sizer.calculate_lot(sl_pips=15, regime='TRENDING', session='OVERLAP')
"""

import json
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np
from scipy import stats


@dataclass
class TradeRecord:
    """Single trade record for Kelly calculation."""
    pnl: float
    regime: str
    session: str
    timestamp: datetime


@dataclass
class KellyResult:
    """Kelly calculation result."""
    kelly_full: float
    kelly_half: float
    kelly_quarter: float
    kelly_recommended: float
    win_rate: float
    payoff_ratio: float
    sample_size: int
    confidence_level: float
    recommendation: str


class AdaptiveKellySizer:
    """
    Adaptive Kelly position sizing with safety features.
    
    Implements Bailey & Lopez de Prado conservative Kelly formula.
    """
    
    # FTMO limits
    MAX_RISK_PER_TRADE = 0.02  # 2% max
    DAILY_DD_LIMIT = 0.05
    TOTAL_DD_LIMIT = 0.10
    
    # Kelly adjustments
    MIN_SAMPLE_SIZE = 30
    CONFIDENCE_LEVEL = 0.95
    
    def __init__(self, account_balance: float = 100000):
        self.account_balance = account_balance
        self.equity = account_balance
        self.daily_equity_high = account_balance
        self.total_equity_high = account_balance
        
        # Trade history by segment
        self.trades: List[TradeRecord] = []
        self.kelly_by_segment: Dict[str, KellyResult] = {}
        
        # State
        self.current_dd_pct = 0
        self.daily_dd_pct = 0
    
    def add_trade(self, pnl: float, regime: str = 'ALL', 
                  session: str = 'ALL'):
        """Add completed trade to history."""
        self.trades.append(TradeRecord(
            pnl=pnl,
            regime=regime,
            session=session,
            timestamp=datetime.now()
        ))
        
        # Update equity
        self.equity += pnl
        
        if self.equity > self.daily_equity_high:
            self.daily_equity_high = self.equity
        if self.equity > self.total_equity_high:
            self.total_equity_high = self.equity
        
        # Update drawdown
        self.daily_dd_pct = (self.daily_equity_high - self.equity) / self.daily_equity_high
        self.current_dd_pct = (self.total_equity_high - self.equity) / self.total_equity_high
        
        # Recalculate Kelly for affected segments
        self._update_kelly(regime, session)
    
    def _update_kelly(self, regime: str, session: str):
        """Update Kelly for segment."""
        segment = f"{regime}_{session}"
        
        # Get trades for this segment
        segment_trades = [t for t in self.trades 
                        if t.regime == regime and t.session == session]
        
        if len(segment_trades) < self.MIN_SAMPLE_SIZE:
            return
        
        result = self._calculate_conservative_kelly(segment_trades)
        self.kelly_by_segment[segment] = result
    
    def _calculate_conservative_kelly(self, trades: List[TradeRecord]) -> KellyResult:
        """
        Calculate Kelly with sample size correction.
        
        Reference: Bailey & Lopez de Prado (2012)
        """
        pnls = [t.pnl for t in trades]
        N = len(pnls)
        
        wins = [p for p in pnls if p > 0]
        losses = [p for p in pnls if p <= 0]
        
        if not wins or not losses:
            return KellyResult(
                kelly_full=0, kelly_half=0, kelly_quarter=0,
                kelly_recommended=0, win_rate=0, payoff_ratio=0,
                sample_size=N, confidence_level=self.CONFIDENCE_LEVEL,
                recommendation='INSUFFICIENT_DATA'
            )
        
        # Basic stats
        p = len(wins) / N  # Win rate
        q = 1 - p
        avg_win = np.mean(wins)
        avg_loss = abs(np.mean(losses))
        b = avg_win / avg_loss  # Payoff ratio
        
        # Full Kelly
        if b > 0:
            kelly_full = (p * b - q) / b
        else:
            kelly_full = 0
        
        # Method 1: Simple sqrt(N) correction
        kelly_simple = kelly_full * (1 - 1/np.sqrt(N))
        
        # Method 2: 95% CI lower bound
        z = stats.norm.ppf(self.CONFIDENCE_LEVEL)
        p_se = np.sqrt(p * q / N)
        p_lower = max(0.01, p - z * p_se)
        
        # SE of payoff ratio (approximation)
        if len(wins) > 1:
            b_se = np.std(wins) / np.sqrt(len(wins)) / avg_loss
            b_lower = max(0.1, b - z * b_se)
        else:
            b_lower = b * 0.5
        
        kelly_ci = (p_lower * b_lower - (1 - p_lower)) / b_lower if b_lower > 0 else 0
        
        # Use most conservative
        kelly_conservative = max(0, min(kelly_simple, kelly_ci))
        
        # Determine recommendation
        if N < 30:
            recommendation = 'kelly_quarter'
            kelly_rec = kelly_conservative * 0.25
        elif N < 100:
            recommendation = 'kelly_quarter'
            kelly_rec = kelly_conservative * 0.25
        elif N < 300:
            recommendation = 'kelly_half'
            kelly_rec = kelly_conservative * 0.5
        else:
            recommendation = 'kelly_60'
            kelly_rec = kelly_conservative * 0.6
        
        return KellyResult(
            kelly_full=kelly_full,
            kelly_half=kelly_conservative * 0.5,
            kelly_quarter=kelly_conservative * 0.25,
            kelly_recommended=kelly_rec,
            win_rate=p * 100,
            payoff_ratio=b,
            sample_size=N,
            confidence_level=self.CONFIDENCE_LEVEL,
            recommendation=recommendation
        )
    
    def calculate_lot(self, sl_pips: float, regime: str = 'ALL',
                      session: str = 'ALL') -> float:
        """
        Calculate lot size for a trade.
        
        Args:
            sl_pips: Stop loss in pips
            regime: Current regime
            session: Current session
        
        Returns:
            Lot size
        """
        segment = f"{regime}_{session}"
        
        # Get Kelly for segment or global
        if segment in self.kelly_by_segment:
            kelly = self.kelly_by_segment[segment].kelly_recommended
        elif 'ALL_ALL' in self.kelly_by_segment:
            kelly = self.kelly_by_segment['ALL_ALL'].kelly_recommended
        else:
            kelly = 0.01  # Default conservative
        
        # Base risk
        risk_pct = min(kelly, self.MAX_RISK_PER_TRADE)
        
        # DD reduction
        risk_pct = self._apply_dd_reduction(risk_pct)
        
        # Calculate risk amount
        risk_amount = self.equity * risk_pct
        
        # Convert to lots (XAUUSD: ~$10/pip for 1 lot)
        pip_value = 10.0
        lot_size = risk_amount / (sl_pips * pip_value)
        
        # Clamp
        return max(0.01, min(lot_size, 5.0))
    
    def _apply_dd_reduction(self, risk_pct: float) -> float:
        """Reduce risk based on current drawdown."""
        # Soft stop: reduce by 50% above 4%
        if self.daily_dd_pct > 0.04:
            risk_pct *= 0.5
        
        # Soft stop: reduce by 50% above 8%
        if self.current_dd_pct > 0.08:
            risk_pct *= 0.5
        
        # Hard stop: no new trades above limits
        if self.daily_dd_pct > 0.045 or self.current_dd_pct > 0.09:
            risk_pct = 0
        
        return risk_pct
    
    def get_kelly_table(self) -> Dict:
        """Get Kelly values for all segments."""
        return {
            segment: {
                'kelly_recommended': result.kelly_recommended,
                'win_rate': result.win_rate,
                'payoff_ratio': result.payoff_ratio,
                'sample_size': result.sample_size,
                'recommendation': result.recommendation
            }
            for segment, result in self.kelly_by_segment.items()
        }
    
    def save_state(self, filepath: str):
        """Save sizer state to file."""
        state = {
            'account_balance': self.account_balance,
            'equity': self.equity,
            'trades': [
                {'pnl': t.pnl, 'regime': t.regime, 'session': t.session,
                 'timestamp': t.timestamp.isoformat()}
                for t in self.trades
            ],
            'kelly_table': self.get_kelly_table()
        }
        
        with open(filepath, 'w') as f:
            json.dump(state, f, indent=2)
    
    def load_state(self, filepath: str):
        """Load sizer state from file."""
        with open(filepath, 'r') as f:
            state = json.load(f)
        
        self.account_balance = state['account_balance']
        self.equity = state['equity']
        
        self.trades = [
            TradeRecord(
                pnl=t['pnl'],
                regime=t['regime'],
                session=t['session'],
                timestamp=datetime.fromisoformat(t['timestamp'])
            )
            for t in state['trades']
        ]
        
        # Recalculate Kelly
        for trade in self.trades:
            self._update_kelly(trade.regime, trade.session)


if __name__ == '__main__':
    # Test
    sizer = AdaptiveKellySizer(100000)
    
    # Add some trades
    np.random.seed(42)
    for i in range(50):
        pnl = np.random.normal(50, 100)  # Mean $50, std $100
        regime = np.random.choice(['TRENDING', 'REVERTING'])
        session = np.random.choice(['OVERLAP', 'LONDON', 'NY'])
        sizer.add_trade(pnl, regime, session)
    
    # Calculate lot
    lot = sizer.calculate_lot(sl_pips=15, regime='TRENDING', session='OVERLAP')
    print(f"Recommended lot: {lot:.2f}")
    
    # Show Kelly table
    print("\nKelly Table:")
    for segment, data in sizer.get_kelly_table().items():
        print(f"  {segment}: Kelly={data['kelly_recommended']:.4f}, "
              f"WR={data['win_rate']:.1f}%, N={data['sample_size']}")
