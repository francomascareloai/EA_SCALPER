"""
Adaptive Kelly Position Sizing - EA_SCALPER_XAUUSD P1 Enhancement
==================================================================
DD-responsive Kelly Criterion with Bayesian uncertainty.

Based on:
- Van Tharp: R-Multiple and Position Sizing
- Ralph Vince: Optimal f and Risk of Ruin
- Kelly Criterion with uncertainty adjustment

Features:
- Half-Kelly for safety (standard practice)
- DD-adaptive reduction (protect capital)
- Regime-aware sizing
- Win rate uncertainty (Bayesian)
- Streak momentum adjustment

Author: FORGE v3.1
Date: 2025-12-01
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Optional, Tuple
from enum import IntEnum


class KellyMode(IntEnum):
    """Kelly sizing mode."""
    FULL = 0       # Full Kelly (aggressive, not recommended)
    HALF = 1       # Half Kelly (standard)
    QUARTER = 2    # Quarter Kelly (conservative)
    ADAPTIVE = 3   # DD-adaptive (recommended)


@dataclass
class TradeStats:
    """Historical trade statistics."""
    total_trades: int = 0
    wins: int = 0
    losses: int = 0
    total_profit_r: float = 0.0
    total_loss_r: float = 0.0
    avg_win_r: float = 0.0
    avg_loss_r: float = 0.0
    win_rate: float = 0.0
    win_rate_std: float = 0.1  # Uncertainty
    expectancy: float = 0.0
    profit_factor: float = 0.0
    
    # Streaks
    consecutive_wins: int = 0
    consecutive_losses: int = 0
    max_consecutive_wins: int = 0
    max_consecutive_losses: int = 0


@dataclass
class KellySizingResult:
    """Result of Kelly calculation."""
    kelly_fraction: float = 0.0       # Raw Kelly %
    adjusted_fraction: float = 0.0    # After all adjustments
    risk_percent: float = 0.0         # Final risk % to use
    lot_size: float = 0.0             # Calculated lot
    
    # Adjustments applied
    kelly_mode: KellyMode = KellyMode.HALF
    dd_adjustment: float = 1.0        # Multiplier from DD
    regime_adjustment: float = 1.0    # Multiplier from regime
    streak_adjustment: float = 1.0    # Multiplier from streaks
    uncertainty_adjustment: float = 1.0  # Multiplier from win rate uncertainty
    
    # Diagnostics
    recommended_max_risk: float = 0.0
    is_trading_allowed: bool = True
    reason: str = ""


class AdaptiveKelly:
    """
    Adaptive Kelly Position Sizing with DD protection.
    
    Key principles:
    1. Kelly = (W * R - L) / R where W=win_rate, L=loss_rate, R=win/loss ratio
    2. Half-Kelly is standard for lower variance
    3. Reduce size when in drawdown (capital preservation)
    4. Account for win rate uncertainty (Bayesian)
    """
    
    # FTMO limits
    MAX_DAILY_DD = 0.05      # 5%
    MAX_TOTAL_DD = 0.10      # 10%
    SOFT_STOP_DD = 0.04      # 4% - start reducing
    CRITICAL_DD = 0.08       # 8% - minimal sizing
    
    # Risk limits
    MIN_RISK_PERCENT = 0.1   # 0.1%
    MAX_RISK_PERCENT = 2.0   # 2.0%
    DEFAULT_RISK = 0.5       # 0.5%
    
    def __init__(self, 
                 mode: KellyMode = KellyMode.ADAPTIVE,
                 min_trades_for_kelly: int = 30,
                 use_uncertainty: bool = True,
                 use_dd_adjustment: bool = True,
                 use_streak_adjustment: bool = True):
        """
        Initialize Adaptive Kelly.
        
        Args:
            mode: Kelly mode (HALF recommended, ADAPTIVE for DD-responsive)
            min_trades_for_kelly: Minimum trades before using Kelly
            use_uncertainty: Apply Bayesian uncertainty adjustment
            use_dd_adjustment: Apply DD-based reduction
            use_streak_adjustment: Apply streak-based momentum
        """
        self.mode = mode
        self.min_trades_for_kelly = min_trades_for_kelly
        self.use_uncertainty = use_uncertainty
        self.use_dd_adjustment = use_dd_adjustment
        self.use_streak_adjustment = use_streak_adjustment
        
        # Trade history
        self.trades: List[float] = []  # R-multiples
        self.stats = TradeStats()
        
        # Account state
        self.initial_balance = 100000.0
        self.current_balance = 100000.0
        self.peak_balance = 100000.0
        self.daily_start_balance = 100000.0
    
    def record_trade(self, r_multiple: float):
        """Record trade result in R-multiples."""
        self.trades.append(r_multiple)
        self._update_stats()
    
    def _update_stats(self):
        """Update trade statistics."""
        if len(self.trades) == 0:
            return
        
        wins = [r for r in self.trades if r > 0]
        losses = [r for r in self.trades if r < 0]
        
        self.stats.total_trades = len(self.trades)
        self.stats.wins = len(wins)
        self.stats.losses = len(losses)
        
        self.stats.total_profit_r = sum(wins) if wins else 0
        self.stats.total_loss_r = abs(sum(losses)) if losses else 0
        
        self.stats.avg_win_r = np.mean(wins) if wins else 0
        self.stats.avg_loss_r = abs(np.mean(losses)) if losses else 1.0
        
        self.stats.win_rate = len(wins) / len(self.trades) if self.trades else 0
        
        # Win rate uncertainty (standard error)
        if len(self.trades) > 1:
            p = self.stats.win_rate
            n = len(self.trades)
            self.stats.win_rate_std = np.sqrt(p * (1 - p) / n)
        else:
            self.stats.win_rate_std = 0.2  # High uncertainty
        
        # Expectancy
        self.stats.expectancy = (
            self.stats.win_rate * self.stats.avg_win_r - 
            (1 - self.stats.win_rate) * self.stats.avg_loss_r
        )
        
        # Profit factor
        if self.stats.total_loss_r > 0:
            self.stats.profit_factor = self.stats.total_profit_r / self.stats.total_loss_r
        else:
            self.stats.profit_factor = float('inf') if self.stats.total_profit_r > 0 else 0
        
        # Update streaks
        if self.trades:
            last_r = self.trades[-1]
            if last_r > 0:
                self.stats.consecutive_wins += 1
                self.stats.consecutive_losses = 0
                self.stats.max_consecutive_wins = max(
                    self.stats.max_consecutive_wins, 
                    self.stats.consecutive_wins
                )
            elif last_r < 0:
                self.stats.consecutive_losses += 1
                self.stats.consecutive_wins = 0
                self.stats.max_consecutive_losses = max(
                    self.stats.max_consecutive_losses,
                    self.stats.consecutive_losses
                )
    
    def update_balance(self, balance: float, is_new_day: bool = False):
        """Update account balance."""
        self.current_balance = balance
        
        if balance > self.peak_balance:
            self.peak_balance = balance
        
        if is_new_day:
            self.daily_start_balance = balance
    
    def get_current_dd(self) -> Tuple[float, float]:
        """Get current daily and total drawdown."""
        daily_dd = max(0, (self.daily_start_balance - self.current_balance) / 
                       max(1e-9, self.daily_start_balance))
        total_dd = max(0, (self.peak_balance - self.current_balance) / 
                       max(1e-9, self.peak_balance))
        return daily_dd, total_dd
    
    def calculate_kelly(self, 
                        win_rate: float = None,
                        avg_win_r: float = None,
                        avg_loss_r: float = None) -> float:
        """
        Calculate raw Kelly fraction.
        
        Kelly formula: f* = (p * b - q) / b
        where p = win rate, q = 1-p, b = win/loss ratio
        """
        if win_rate is None:
            win_rate = self.stats.win_rate
        if avg_win_r is None:
            avg_win_r = self.stats.avg_win_r
        if avg_loss_r is None:
            avg_loss_r = self.stats.avg_loss_r
        
        if win_rate <= 0 or avg_loss_r <= 0:
            return 0.0
        
        p = win_rate
        q = 1 - win_rate
        b = avg_win_r / avg_loss_r  # Win/loss ratio
        
        # Kelly formula
        kelly = (p * b - q) / b
        
        return max(0, kelly)
    
    def _get_dd_adjustment(self) -> float:
        """
        Get position size adjustment based on drawdown.
        
        Progressive reduction:
        - DD < 3%: Full size (1.0)
        - DD 3-4%: 75% size
        - DD 4-5%: 50% size
        - DD 5-8%: 25% size
        - DD > 8%: 0% (no trading)
        """
        daily_dd, total_dd = self.get_current_dd()
        max_dd = max(daily_dd, total_dd)
        
        if max_dd >= self.CRITICAL_DD:
            return 0.0  # Stop trading
        elif max_dd >= self.MAX_DAILY_DD:
            return 0.25
        elif max_dd >= self.SOFT_STOP_DD:
            return 0.50
        elif max_dd >= 0.03:
            return 0.75
        else:
            return 1.0
    
    def _get_streak_adjustment(self) -> float:
        """
        Get position size adjustment based on streaks.
        
        - 2+ consecutive wins: +20% (momentum)
        - 2+ consecutive losses: -50% (protect capital)
        """
        if self.stats.consecutive_losses >= 3:
            return 0.25
        elif self.stats.consecutive_losses >= 2:
            return 0.50
        elif self.stats.consecutive_wins >= 3:
            return 1.3
        elif self.stats.consecutive_wins >= 2:
            return 1.2
        else:
            return 1.0
    
    def _get_uncertainty_adjustment(self) -> float:
        """
        Get adjustment for win rate uncertainty.
        
        Uses lower bound of confidence interval.
        More trades = lower uncertainty = higher adjustment.
        """
        if not self.use_uncertainty or self.stats.total_trades < 10:
            return 0.8  # Conservative with few trades
        
        # Use 1 standard deviation below win rate (68% CI lower bound)
        conservative_win_rate = max(0, self.stats.win_rate - self.stats.win_rate_std)
        
        # Ratio of conservative to actual
        if self.stats.win_rate > 0:
            return min(1.0, conservative_win_rate / self.stats.win_rate)
        return 0.8
    
    def _get_regime_adjustment(self, regime_multiplier: float) -> float:
        """
        Get adjustment based on market regime.
        
        PRIME regimes: full size
        NOISY regimes: reduced size
        RANDOM/TRANSITION: minimal or no trading
        """
        return max(0, min(1.5, regime_multiplier))
    
    def calculate_position_size(self,
                                 sl_points: float,
                                 regime_multiplier: float = 1.0,
                                 point_value: float = 0.01,
                                 tick_value: float = 1.0,
                                 tick_size: float = 0.01) -> KellySizingResult:
        """
        Calculate optimal position size.
        
        Args:
            sl_points: Stop loss in points
            regime_multiplier: Regime-based multiplier (0-1.5)
            point_value: Value per point
            tick_value: Value per tick
            tick_size: Tick size
        
        Returns:
            KellySizingResult with lot size and diagnostics
        """
        result = KellySizingResult()
        result.kelly_mode = self.mode
        
        # Check if trading allowed
        daily_dd, total_dd = self.get_current_dd()
        
        if total_dd >= self.MAX_TOTAL_DD:
            result.is_trading_allowed = False
            result.reason = f"Total DD {total_dd*100:.1f}% >= limit {self.MAX_TOTAL_DD*100:.1f}%"
            return result
        
        if daily_dd >= self.MAX_DAILY_DD:
            result.is_trading_allowed = False
            result.reason = f"Daily DD {daily_dd*100:.1f}% >= limit {self.MAX_DAILY_DD*100:.1f}%"
            return result
        
        if sl_points <= 0:
            result.is_trading_allowed = False
            result.reason = "Invalid SL"
            return result
        
        # Calculate base Kelly
        if self.stats.total_trades >= self.min_trades_for_kelly:
            result.kelly_fraction = self.calculate_kelly()
        else:
            # Not enough data - use default
            result.kelly_fraction = self.DEFAULT_RISK / 100.0
        
        # Apply mode
        if self.mode == KellyMode.FULL:
            adjusted = result.kelly_fraction
        elif self.mode == KellyMode.HALF:
            adjusted = result.kelly_fraction * 0.5
        elif self.mode == KellyMode.QUARTER:
            adjusted = result.kelly_fraction * 0.25
        else:  # ADAPTIVE
            adjusted = result.kelly_fraction * 0.5  # Start with half
        
        # Apply adjustments
        if self.use_dd_adjustment:
            result.dd_adjustment = self._get_dd_adjustment()
            adjusted *= result.dd_adjustment
        
        if self.use_streak_adjustment:
            result.streak_adjustment = self._get_streak_adjustment()
            adjusted *= result.streak_adjustment
        
        if self.use_uncertainty:
            result.uncertainty_adjustment = self._get_uncertainty_adjustment()
            adjusted *= result.uncertainty_adjustment
        
        result.regime_adjustment = self._get_regime_adjustment(regime_multiplier)
        adjusted *= result.regime_adjustment
        
        result.adjusted_fraction = adjusted
        
        # Convert to risk percent and apply limits
        result.risk_percent = adjusted * 100.0
        result.risk_percent = max(self.MIN_RISK_PERCENT, 
                                   min(self.MAX_RISK_PERCENT, result.risk_percent))
        
        # Handle zero adjustment
        if result.dd_adjustment == 0:
            result.risk_percent = 0
            result.is_trading_allowed = False
            result.reason = f"DD too high ({max(daily_dd, total_dd)*100:.1f}%)"
        
        # Calculate lot size
        if result.risk_percent > 0 and sl_points > 0:
            risk_amount = self.current_balance * (result.risk_percent / 100.0)
            value_per_point = tick_value * (point_value / max(1e-9, tick_size))
            result.lot_size = risk_amount / max(1e-9, sl_points * value_per_point)
            result.lot_size = float(np.clip(round(result.lot_size, 2), 0.01, 10.0))
        
        # Recommended max risk
        if self.stats.expectancy > 0:
            result.recommended_max_risk = min(
                result.kelly_fraction * 100.0,
                self.MAX_RISK_PERCENT
            )
        else:
            result.recommended_max_risk = 0
        
        return result
    
    def get_risk_of_ruin(self, risk_percent: float, 
                          ruin_level: float = 0.20,
                          simulations: int = 1000) -> float:
        """
        Monte Carlo Risk of Ruin calculation.
        
        Args:
            risk_percent: Risk per trade %
            ruin_level: DD level that defines ruin (default 20%)
            simulations: Number of MC simulations
        
        Returns:
            Probability of ruin (0-1)
        """
        if self.stats.total_trades < 10:
            return 0.5  # Unknown with insufficient data
        
        ruined = 0
        trades_per_sim = 100
        
        for _ in range(simulations):
            equity = 1.0
            peak = 1.0
            
            for _ in range(trades_per_sim):
                # Generate random trade result
                if np.random.random() < self.stats.win_rate:
                    r = np.random.normal(self.stats.avg_win_r, self.stats.avg_win_r * 0.3)
                    r = max(0.1, r)
                    equity += (risk_percent / 100.0) * r
                else:
                    r = np.random.normal(self.stats.avg_loss_r, self.stats.avg_loss_r * 0.3)
                    r = max(0.1, r)
                    equity -= (risk_percent / 100.0) * r
                
                if equity > peak:
                    peak = equity
                
                dd = (peak - equity) / peak
                if dd >= ruin_level:
                    ruined += 1
                    break
        
        return ruined / simulations
    
    def get_stats_summary(self) -> dict:
        """Get summary of trade statistics."""
        daily_dd, total_dd = self.get_current_dd()
        
        return {
            'total_trades': self.stats.total_trades,
            'win_rate': f"{self.stats.win_rate*100:.1f}%",
            'avg_win_r': f"{self.stats.avg_win_r:.2f}R",
            'avg_loss_r': f"{self.stats.avg_loss_r:.2f}R",
            'expectancy': f"{self.stats.expectancy:.3f}R",
            'profit_factor': f"{self.stats.profit_factor:.2f}",
            'kelly_fraction': f"{self.calculate_kelly()*100:.2f}%",
            'half_kelly': f"{self.calculate_kelly()*50:.2f}%",
            'current_dd': f"{max(daily_dd, total_dd)*100:.2f}%",
            'streak': f"+{self.stats.consecutive_wins}" if self.stats.consecutive_wins > 0 
                      else f"-{self.stats.consecutive_losses}",
        }


# Convenience function
def create_adaptive_kelly(**kwargs) -> AdaptiveKelly:
    """Factory function to create AdaptiveKelly."""
    return AdaptiveKelly(**kwargs)


if __name__ == "__main__":
    # Test
    print("Adaptive Kelly Test")
    print("=" * 50)
    
    kelly = AdaptiveKelly(mode=KellyMode.ADAPTIVE)
    kelly.initial_balance = 100000
    kelly.current_balance = 100000
    kelly.peak_balance = 100000
    kelly.daily_start_balance = 100000
    
    # Simulate some trades
    np.random.seed(42)
    for _ in range(50):
        # 60% win rate, avg +1.5R win, -1R loss
        if np.random.random() < 0.6:
            r = np.random.normal(1.5, 0.3)
        else:
            r = -np.random.normal(1.0, 0.2)
        kelly.record_trade(r)
    
    print("\nTrade Statistics:")
    for k, v in kelly.get_stats_summary().items():
        print(f"  {k}: {v}")
    
    # Calculate position size
    result = kelly.calculate_position_size(
        sl_points=50.0,
        regime_multiplier=1.0,
    )
    
    print(f"\nPosition Sizing Result:")
    print(f"  Kelly Fraction: {result.kelly_fraction*100:.2f}%")
    print(f"  Adjusted Fraction: {result.adjusted_fraction*100:.2f}%")
    print(f"  Risk Percent: {result.risk_percent:.2f}%")
    print(f"  Lot Size: {result.lot_size:.2f}")
    print(f"  DD Adjustment: {result.dd_adjustment:.2f}")
    print(f"  Streak Adjustment: {result.streak_adjustment:.2f}")
    print(f"  Allowed: {result.is_trading_allowed}")
    
    # Test DD scenario
    print("\n--- Simulating 4% Drawdown ---")
    kelly.current_balance = 96000  # 4% DD
    result_dd = kelly.calculate_position_size(sl_points=50.0, regime_multiplier=1.0)
    print(f"  DD Adjustment: {result_dd.dd_adjustment:.2f}")
    print(f"  Risk Percent: {result_dd.risk_percent:.2f}%")
    print(f"  Allowed: {result_dd.is_trading_allowed}")
    
    # Risk of Ruin
    print("\n--- Risk of Ruin Analysis ---")
    ror = kelly.get_risk_of_ruin(risk_percent=0.5)
    print(f"  RoR at 0.5% risk: {ror*100:.1f}%")
    ror2 = kelly.get_risk_of_ruin(risk_percent=1.0)
    print(f"  RoR at 1.0% risk: {ror2*100:.1f}%")
