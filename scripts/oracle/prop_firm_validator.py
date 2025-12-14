"""
Prop Firm Validator - FTMO Specific
====================================

Validates trading strategies against prop firm rules:
- FTMO daily drawdown (equity-based)
- FTMO total drawdown
- Probability of violation via Monte Carlo
- Position sizing recommendations

For: EA_SCALPER_XAUUSD - ORACLE Validation v2.2

Usage:
    python -m scripts.oracle.prop_firm_validator --input trades.csv --firm ftmo
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass
from typing import List, Dict, Optional
from enum import Enum
import argparse


class PropFirm(Enum):
    FTMO = "ftmo"
    MFF = "mff"          # MyFundedFx
    E8 = "e8"            # E8 Funding
    TFT = "tft"          # The Funded Trader
    TOPSTEP = "topstep"


@dataclass
class FirmRules:
    """Rules for a specific prop firm"""
    name: str
    daily_dd_limit: float      # % of initial balance
    total_dd_limit: float      # % of initial balance
    profit_target_p1: float    # Phase 1 target %
    profit_target_p2: float    # Phase 2 target %
    min_trading_days: int
    max_leverage: int
    uses_equity_dd: bool       # True = uses equity (floating), False = uses balance
    trailing_dd: bool          # True = DD trails with profit


# Predefined firm rules
FIRM_RULES = {
    PropFirm.FTMO: FirmRules(
        name="FTMO",
        daily_dd_limit=5.0,
        total_dd_limit=10.0,
        profit_target_p1=10.0,
        profit_target_p2=5.0,
        min_trading_days=4,
        max_leverage=100,
        uses_equity_dd=True,
        trailing_dd=False
    ),
    PropFirm.MFF: FirmRules(
        name="MyFundedFx",
        daily_dd_limit=5.0,
        total_dd_limit=12.0,
        profit_target_p1=8.0,
        profit_target_p2=5.0,
        min_trading_days=0,
        max_leverage=100,
        uses_equity_dd=True,
        trailing_dd=False
    ),
    PropFirm.E8: FirmRules(
        name="E8 Funding",
        daily_dd_limit=5.0,
        total_dd_limit=8.0,
        profit_target_p1=8.0,
        profit_target_p2=4.0,
        min_trading_days=0,
        max_leverage=100,
        uses_equity_dd=True,
        trailing_dd=False
    ),
}


@dataclass
class PropFirmResult:
    """Result of prop firm validation"""
    firm: str
    rules: FirmRules
    
    # Monte Carlo probabilities
    p_daily_breach: float      # P(violating daily DD)
    p_total_breach: float      # P(violating total DD)
    p_pass_challenge: float    # P(reaching profit target)
    
    # Drawdown analysis
    dd_95th: float             # 95th percentile DD
    dd_99th: float             # 99th percentile DD
    max_losing_streak_dd: float  # DD from max losing streak
    
    # Position sizing
    recommended_risk_pct: float
    max_safe_risk_pct: float
    
    # Verdict
    is_approved: bool
    confidence_score: int
    verdict: str
    warnings: List[str]


class PropFirmValidator:
    """
    Validates trading strategies against prop firm rules.
    
    Uses Monte Carlo simulation to estimate:
    - Probability of violating daily/total DD
    - Probability of passing challenge
    - Recommended position sizing
    """
    
    def __init__(
        self,
        firm: PropFirm = PropFirm.FTMO,
        account_size: float = 100000,
        n_simulations: int = 5000
    ):
        self.firm = firm
        self.rules = FIRM_RULES.get(firm, FIRM_RULES[PropFirm.FTMO])
        self.account_size = account_size
        self.n_simulations = n_simulations
        self._rng = np.random.default_rng()
    
    def validate(self, trades: pd.DataFrame, profit_col: str = 'profit') -> PropFirmResult:
        """
        Validate strategy against prop firm rules.
        
        Args:
            trades: DataFrame with trade data
            profit_col: Column name for profit/pnl
        
        Returns:
            PropFirmResult with validation results
        """
        profits = trades[profit_col].values
        n_trades = len(profits)
        
        # Calculate optimal block size
        block_size = max(5, int(n_trades ** (1/3)))
        n_blocks = n_trades // block_size
        
        if n_blocks < 3:
            block_size = max(1, n_trades // 3)
            n_blocks = n_trades // block_size
        
        # Monte Carlo simulation
        daily_breaches = 0
        total_breaches = 0
        passes = 0
        max_dds = []
        losing_streak_dds = []
        
        daily_limit_usd = self.account_size * self.rules.daily_dd_limit / 100
        total_limit_usd = self.account_size * self.rules.total_dd_limit / 100
        profit_target_usd = self.account_size * self.rules.profit_target_p1 / 100
        
        for _ in range(self.n_simulations):
            # Block bootstrap
            if n_blocks > 0:
                block_indices = self._rng.integers(0, n_blocks, size=n_blocks)
                sim_profits = []
                for block_idx in block_indices:
                    start = block_idx * block_size
                    end = min(start + block_size, n_trades)
                    sim_profits.extend(profits[start:end])
            else:
                sim_profits = list(profits)
            
            # Simulate challenge
            result = self._simulate_challenge(
                sim_profits, daily_limit_usd, total_limit_usd, profit_target_usd
            )
            
            if result['daily_breached']:
                daily_breaches += 1
            if result['total_breached']:
                total_breaches += 1
            if result['target_reached']:
                passes += 1
            
            max_dds.append(result['max_dd_pct'])
            
            # Track losing streak DD
            streak_dd = self._calculate_losing_streak_dd(sim_profits)
            losing_streak_dds.append(streak_dd)
        
        # Calculate probabilities
        p_daily = daily_breaches / self.n_simulations * 100
        p_total = total_breaches / self.n_simulations * 100
        p_pass = passes / self.n_simulations * 100
        
        dd_95 = np.percentile(max_dds, 95)
        dd_99 = np.percentile(max_dds, 99)
        max_streak_dd = np.percentile(losing_streak_dds, 95) / self.account_size * 100
        
        # Position sizing recommendation
        rec_risk, max_risk = self._calculate_position_sizing(profits, dd_95)
        
        # Determine verdict
        warnings = []
        if p_daily > 5:
            warnings.append(f"Daily DD violation risk: {p_daily:.1f}%")
        if p_total > 2:
            warnings.append(f"Total DD violation risk: {p_total:.1f}%")
        if dd_95 > 8:
            warnings.append(f"95th percentile DD ({dd_95:.1f}%) > 8%")
        if max_streak_dd > 4:
            warnings.append(f"10-loss streak could hit {max_streak_dd:.1f}% DD")
        
        is_approved = p_daily < 5 and p_total < 2 and dd_95 < 8
        
        # Confidence score (0-20 for prop firm component)
        score = self._calculate_confidence_component(p_daily, p_total, dd_95)
        
        if is_approved:
            verdict = f"APPROVED for {self.rules.name} Challenge"
        elif p_daily < 10 and p_total < 5:
            verdict = f"MARGINAL - Consider reducing risk for {self.rules.name}"
        else:
            verdict = f"REJECTED - Too risky for {self.rules.name}"
        
        return PropFirmResult(
            firm=self.rules.name,
            rules=self.rules,
            p_daily_breach=p_daily,
            p_total_breach=p_total,
            p_pass_challenge=p_pass,
            dd_95th=dd_95,
            dd_99th=dd_99,
            max_losing_streak_dd=max_streak_dd,
            recommended_risk_pct=rec_risk,
            max_safe_risk_pct=max_risk,
            is_approved=is_approved,
            confidence_score=score,
            verdict=verdict,
            warnings=warnings
        )
    
    def _simulate_challenge(
        self,
        profits: List[float],
        daily_limit: float,
        total_limit: float,
        target: float
    ) -> Dict:
        """Simulate a single challenge run"""
        balance = self.account_size
        equity = self.account_size
        peak = self.account_size
        
        daily_pnl = 0
        trades_today = 0
        
        daily_breached = False
        total_breached = False
        target_reached = False
        max_dd_pct = 0
        
        for pnl in profits:
            # Update balance and equity
            balance += pnl
            equity = balance  # Simplified (no open positions)
            
            # Track daily
            daily_pnl += pnl
            trades_today += 1
            
            # FTMO uses equity for DD calculation
            if self.rules.uses_equity_dd:
                current_dd = self.account_size - equity
            else:
                current_dd = self.account_size - balance
            
            # Check daily DD (simplified: every 20 trades = 1 day)
            if trades_today >= 20:
                daily_dd = -daily_pnl if daily_pnl < 0 else 0
                if daily_dd >= daily_limit:
                    daily_breached = True
                daily_pnl = 0
                trades_today = 0
            
            # Check total DD
            if current_dd >= total_limit:
                total_breached = True
            
            # Track max DD
            dd_pct = current_dd / self.account_size * 100
            max_dd_pct = max(max_dd_pct, dd_pct)
            
            # Check target
            profit = balance - self.account_size
            if profit >= target:
                target_reached = True
        
        return {
            'daily_breached': daily_breached,
            'total_breached': total_breached,
            'target_reached': target_reached,
            'max_dd_pct': max_dd_pct,
            'final_profit': balance - self.account_size
        }
    
    def _calculate_losing_streak_dd(self, profits: List[float], streak_length: int = 10) -> float:
        """Calculate DD from a losing streak"""
        # Find worst consecutive losing streak
        max_loss = 0
        current_loss = 0
        streak = 0
        
        for pnl in profits:
            if pnl < 0:
                current_loss += abs(pnl)
                streak += 1
                if streak >= streak_length:
                    max_loss = max(max_loss, current_loss)
            else:
                current_loss = 0
                streak = 0
        
        return max_loss
    
    def _calculate_position_sizing(self, profits: np.ndarray, dd_95: float) -> tuple:
        """Calculate recommended position sizing"""
        # Current risk per trade (estimated)
        avg_loss = abs(profits[profits < 0].mean()) if any(profits < 0) else 0
        current_risk = avg_loss / self.account_size * 100
        
        # Target: keep 95th DD under 6% (buffer from 10%)
        target_dd = 6.0
        
        if dd_95 > 0 and current_risk > 0:
            adjustment = target_dd / dd_95
            recommended = min(1.0, current_risk * adjustment)
        else:
            recommended = 0.5
        
        # Max safe risk: keep 95th DD under 8%
        max_dd = 8.0
        if dd_95 > 0 and current_risk > 0:
            max_safe = min(1.5, current_risk * (max_dd / dd_95))
        else:
            max_safe = 1.0
        
        return round(recommended, 2), round(max_safe, 2)
    
    def _calculate_confidence_component(self, p_daily: float, p_total: float, dd_95: float) -> int:
        """Calculate confidence score component (0-20)"""
        score = 0
        
        # P(daily breach) - 10 points max
        if p_daily < 2:
            score += 10
        elif p_daily < 5:
            score += 7
        elif p_daily < 10:
            score += 3
        
        # P(total breach) - 10 points max
        if p_total < 1:
            score += 10
        elif p_total < 2:
            score += 7
        elif p_total < 5:
            score += 3
        
        return score
    
    def generate_report(self, result: PropFirmResult) -> str:
        """Generate text report"""
        lines = [
            "=" * 60,
            f"PROP FIRM VALIDATION REPORT - {result.firm}",
            "=" * 60,
            f"Account Size: ${self.account_size:,.0f}",
            f"Simulations: {self.n_simulations:,}",
            "-" * 60,
            f"RULES ({result.firm}):",
            f"  Daily DD Limit: {result.rules.daily_dd_limit}%",
            f"  Total DD Limit: {result.rules.total_dd_limit}%",
            f"  Profit Target P1: {result.rules.profit_target_p1}%",
            f"  Uses Equity DD: {'Yes' if result.rules.uses_equity_dd else 'No'}",
            "-" * 60,
            "VIOLATION PROBABILITIES:",
            f"  P(Daily DD > {result.rules.daily_dd_limit}%): {result.p_daily_breach:.1f}%",
            f"  P(Total DD > {result.rules.total_dd_limit}%): {result.p_total_breach:.1f}%",
            f"  P(Passing Challenge): {result.p_pass_challenge:.1f}%",
            "-" * 60,
            "DRAWDOWN DISTRIBUTION:",
            f"  95th Percentile DD: {result.dd_95th:.1f}%",
            f"  99th Percentile DD: {result.dd_99th:.1f}%",
            f"  10-Loss Streak DD: {result.max_losing_streak_dd:.1f}%",
            "-" * 60,
            "POSITION SIZING:",
            f"  Recommended Risk/Trade: {result.recommended_risk_pct}%",
            f"  Maximum Safe Risk: {result.max_safe_risk_pct}%",
            "-" * 60,
        ]
        
        if result.warnings:
            lines.append("WARNINGS:")
            for w in result.warnings:
                lines.append(f"  ⚠️ {w}")
            lines.append("-" * 60)
        
        lines.extend([
            f"VERDICT: {result.verdict}",
            f"Confidence Component: {result.confidence_score}/20",
            "=" * 60
        ])
        
        return "\n".join(lines)


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='Prop Firm Validator')
    parser.add_argument('--input', '-i', required=True, help='CSV file with trades')
    parser.add_argument('--firm', '-f', choices=['ftmo', 'mff', 'e8'], default='ftmo')
    parser.add_argument('--account', '-a', type=float, default=100000, help='Account size')
    parser.add_argument('--simulations', '-n', type=int, default=5000)
    parser.add_argument('--column', '-c', default='profit', help='Profit column')
    
    args = parser.parse_args()
    
    # Load data
    df = pd.read_csv(args.input)
    if args.column not in df.columns:
        for col in ['profit', 'pnl', 'pl', 'return']:
            if col in df.columns:
                args.column = col
                break
        else:
            print(f"Error: Column '{args.column}' not found.")
            return
    
    # Run validation
    firm = PropFirm(args.firm)
    validator = PropFirmValidator(firm=firm, account_size=args.account, n_simulations=args.simulations)
    result = validator.validate(df, profit_col=args.column)
    
    # Print report
    print(validator.generate_report(result))


if __name__ == '__main__':
    main()
