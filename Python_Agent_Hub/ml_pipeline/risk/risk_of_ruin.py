"""
Risk of Ruin Calculator - Ralph Vince Methodology
EA_SCALPER_XAUUSD - Risk Module

Calculates probability of account ruin using Monte Carlo simulation.
Essential for validating system safety before live trading.

References:
- "The Mathematics of Money Management" - Ralph Vince
- "Trade Your Way to Financial Freedom" - Van Tharp
"""
import numpy as np
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
import scipy.stats as stats


@dataclass
class RiskOfRuinResult:
    """Complete Risk of Ruin analysis result."""
    risk_of_ruin: float           # Probability of hitting ruin level (0-1)
    probability_of_success: float  # Probability of hitting target (0-1)
    inconclusive: float           # Neither ruin nor target reached
    
    # Drawdown analysis
    median_max_drawdown: float    # Median max DD across simulations
    percentile_95_drawdown: float # 95th percentile max DD
    percentile_99_drawdown: float # 99th percentile max DD
    
    # Position sizing recommendations
    optimal_kelly_fraction: float # Kelly Criterion
    half_kelly: float             # Half Kelly (more conservative)
    quarter_kelly: float          # Quarter Kelly (very conservative)
    
    # Simulation parameters
    simulations: int
    trades_per_sim: int
    
    @property
    def is_safe(self) -> bool:
        """System is safe if RoR < 5%."""
        return self.risk_of_ruin < 0.05
    
    @property
    def safety_rating(self) -> str:
        if self.risk_of_ruin < 0.01:
            return 'Excellent'
        elif self.risk_of_ruin < 0.05:
            return 'Good'
        elif self.risk_of_ruin < 0.10:
            return 'Warning'
        else:
            return 'Dangerous'


class RiskOfRuinCalculator:
    """
    Risk of Ruin Calculator using Monte Carlo simulation.
    
    Key Concepts:
    - Risk of Ruin = probability of losing X% before gaining Y%
    - Uses Monte Carlo with R-multiple distribution
    - More accurate than analytical formulas for trading
    
    Usage:
    - Run BEFORE live trading to validate system
    - If RoR > 5%, reduce risk per trade
    - Aim for RoR < 1% for professional trading
    """
    
    def __init__(self, seed: Optional[int] = None):
        """
        Initialize calculator.
        
        Args:
            seed: Random seed for reproducibility (None for random)
        """
        if seed is not None:
            np.random.seed(seed)
    
    def calculate_monte_carlo(
        self,
        win_rate: float,
        avg_win_r: float,
        avg_loss_r: float,
        risk_per_trade: float,
        ruin_level: float = 0.20,
        target_level: float = 0.50,
        trades_per_sim: int = 200,
        simulations: int = 10000,
        use_distribution: bool = True,
        win_std: Optional[float] = None,
        loss_std: Optional[float] = None
    ) -> RiskOfRuinResult:
        """
        Calculate Risk of Ruin via Monte Carlo simulation.
        
        Args:
            win_rate: Win rate (0-1), e.g., 0.60 for 60%
            avg_win_r: Average winner in R-multiples, e.g., 2.0
            avg_loss_r: Average loser in R-multiples (absolute value), e.g., 1.0
            risk_per_trade: Fraction risked per trade, e.g., 0.01 for 1%
            ruin_level: Drawdown that defines ruin, e.g., 0.20 for 20%
            target_level: Profit target, e.g., 0.50 for 50%
            trades_per_sim: Number of trades per simulation
            simulations: Number of Monte Carlo simulations
            use_distribution: If True, use normal distribution for R
            win_std: Std dev of wins (default: avg_win_r * 0.3)
            loss_std: Std dev of losses (default: avg_loss_r * 0.3)
        
        Returns:
            RiskOfRuinResult with all metrics
        """
        ruined = 0
        succeeded = 0
        max_drawdowns = []
        
        # Default standard deviations
        if win_std is None:
            win_std = avg_win_r * 0.3
        if loss_std is None:
            loss_std = avg_loss_r * 0.3
        
        for _ in range(simulations):
            equity = 1.0
            peak_equity = 1.0
            max_dd_this_sim = 0.0
            sim_ruined = False
            sim_succeeded = False
            
            for _ in range(trades_per_sim):
                # Generate trade result
                if np.random.random() < win_rate:
                    # Winner
                    if use_distribution:
                        r_result = np.random.normal(avg_win_r, win_std)
                        r_result = max(0.1, r_result)  # Min 0.1R win
                    else:
                        r_result = avg_win_r
                    equity += risk_per_trade * r_result
                else:
                    # Loser
                    if use_distribution:
                        r_result = np.random.normal(avg_loss_r, loss_std)
                        r_result = max(0.1, min(r_result, 2.0))  # Clamp to 0.1-2R loss
                    else:
                        r_result = avg_loss_r
                    equity -= risk_per_trade * r_result
                
                # Update peak and drawdown
                if equity > peak_equity:
                    peak_equity = equity
                
                drawdown = (peak_equity - equity) / peak_equity
                max_dd_this_sim = max(max_dd_this_sim, drawdown)
                
                # Check ruin
                if drawdown >= ruin_level:
                    ruined += 1
                    sim_ruined = True
                    break
                
                # Check success
                profit = equity - 1.0
                if profit >= target_level:
                    succeeded += 1
                    sim_succeeded = True
                    break
            
            max_drawdowns.append(max_dd_this_sim)
        
        # Calculate Kelly Criterion
        kelly = self._calculate_kelly(win_rate, avg_win_r, avg_loss_r)
        
        return RiskOfRuinResult(
            risk_of_ruin=ruined / simulations,
            probability_of_success=succeeded / simulations,
            inconclusive=(simulations - ruined - succeeded) / simulations,
            median_max_drawdown=np.median(max_drawdowns),
            percentile_95_drawdown=np.percentile(max_drawdowns, 95),
            percentile_99_drawdown=np.percentile(max_drawdowns, 99),
            optimal_kelly_fraction=kelly,
            half_kelly=kelly / 2,
            quarter_kelly=kelly / 4,
            simulations=simulations,
            trades_per_sim=trades_per_sim
        )
    
    def calculate_with_r_multiples(
        self,
        r_multiples: List[float],
        risk_per_trade: float,
        ruin_level: float = 0.20,
        target_level: float = 0.50,
        trades_per_sim: int = 200,
        simulations: int = 10000
    ) -> RiskOfRuinResult:
        """
        Calculate RoR using actual R-multiple distribution from backtest.
        
        More accurate than parametric method as it uses real distribution.
        
        Args:
            r_multiples: List of actual R-multiples from backtest
            Other args same as calculate_monte_carlo
        """
        ruined = 0
        succeeded = 0
        max_drawdowns = []
        
        r_array = np.array(r_multiples)
        
        for _ in range(simulations):
            equity = 1.0
            peak_equity = 1.0
            max_dd_this_sim = 0.0
            
            # Sample from actual distribution
            sampled_r = np.random.choice(r_array, size=trades_per_sim, replace=True)
            
            for r in sampled_r:
                equity += risk_per_trade * r
                
                if equity > peak_equity:
                    peak_equity = equity
                
                drawdown = (peak_equity - equity) / peak_equity
                max_dd_this_sim = max(max_dd_this_sim, drawdown)
                
                if drawdown >= ruin_level:
                    ruined += 1
                    break
                
                if (equity - 1.0) >= target_level:
                    succeeded += 1
                    break
            
            max_drawdowns.append(max_dd_this_sim)
        
        # Calculate stats from actual distribution
        winners = [r for r in r_multiples if r > 0]
        losers = [abs(r) for r in r_multiples if r < 0]
        
        win_rate = len(winners) / len(r_multiples) if r_multiples else 0.5
        avg_win = np.mean(winners) if winners else 1.0
        avg_loss = np.mean(losers) if losers else 1.0
        
        kelly = self._calculate_kelly(win_rate, avg_win, avg_loss)
        
        return RiskOfRuinResult(
            risk_of_ruin=ruined / simulations,
            probability_of_success=succeeded / simulations,
            inconclusive=(simulations - ruined - succeeded) / simulations,
            median_max_drawdown=np.median(max_drawdowns),
            percentile_95_drawdown=np.percentile(max_drawdowns, 95),
            percentile_99_drawdown=np.percentile(max_drawdowns, 99),
            optimal_kelly_fraction=kelly,
            half_kelly=kelly / 2,
            quarter_kelly=kelly / 4,
            simulations=simulations,
            trades_per_sim=trades_per_sim
        )
    
    def _calculate_kelly(
        self, 
        win_rate: float, 
        avg_win_r: float, 
        avg_loss_r: float
    ) -> float:
        """
        Calculate Kelly Criterion.
        
        f* = (p * b - q) / b
        where p = win rate, q = loss rate, b = win/loss ratio
        """
        if avg_loss_r == 0:
            return 0
        
        p = win_rate
        q = 1 - win_rate
        b = avg_win_r / avg_loss_r
        
        kelly = (p * b - q) / b
        return max(0, min(kelly, 1.0))  # Clamp 0-100%
    
    def calculate_analytical(
        self,
        win_rate: float,
        avg_win_r: float,
        avg_loss_r: float,
        risk_per_trade: float,
        ruin_level: float = 0.20
    ) -> float:
        """
        Calculate Risk of Ruin using analytical formula (approximation).
        
        Less accurate than Monte Carlo but instantaneous.
        Useful for quick estimates.
        """
        # Edge per trade
        edge = win_rate * avg_win_r - (1 - win_rate) * avg_loss_r
        
        if edge <= 0:
            return 1.0  # Losing system = 100% ruin
        
        # Units of risk to reach ruin
        units_to_ruin = ruin_level / risk_per_trade
        
        # Gambler's Ruin formula
        a = (1 - edge) / (1 + edge) if edge != 0 else 1
        
        if abs(a) >= 1:
            return 1.0
        
        ror = a ** units_to_ruin
        return min(1.0, max(0.0, ror))
    
    def find_safe_risk(
        self,
        win_rate: float,
        avg_win_r: float,
        avg_loss_r: float,
        max_ror: float = 0.01,
        ruin_level: float = 0.20,
        precision: int = 15
    ) -> float:
        """
        Find maximum safe risk per trade for given max RoR.
        
        Uses binary search for efficiency.
        
        Args:
            max_ror: Maximum acceptable risk of ruin (default 1%)
            precision: Number of binary search iterations
        
        Returns:
            Maximum safe risk percentage (0-1)
        """
        low = 0.001   # 0.1%
        high = 0.10   # 10%
        
        for _ in range(precision):
            mid = (low + high) / 2
            result = self.calculate_monte_carlo(
                win_rate=win_rate,
                avg_win_r=avg_win_r,
                avg_loss_r=avg_loss_r,
                risk_per_trade=mid,
                ruin_level=ruin_level,
                simulations=1000
            )
            
            if result.risk_of_ruin > max_ror:
                high = mid
            else:
                low = mid
        
        return low
    
    def sensitivity_analysis(
        self,
        win_rate: float,
        avg_win_r: float,
        avg_loss_r: float,
        risk_levels: List[float] = None
    ) -> Dict[float, RiskOfRuinResult]:
        """
        Analyze RoR sensitivity to different risk levels.
        
        Returns dict mapping risk_per_trade to RoR result.
        """
        if risk_levels is None:
            risk_levels = [0.005, 0.01, 0.015, 0.02, 0.025, 0.03, 0.04, 0.05]
        
        results = {}
        for risk in risk_levels:
            results[risk] = self.calculate_monte_carlo(
                win_rate=win_rate,
                avg_win_r=avg_win_r,
                avg_loss_r=avg_loss_r,
                risk_per_trade=risk,
                simulations=5000
            )
        
        return results
    
    def print_report(self, result: RiskOfRuinResult, params: dict):
        """Print formatted Risk of Ruin report."""
        print("\n" + "=" * 60)
        print("RISK OF RUIN ANALYSIS (Ralph Vince Method)")
        print("=" * 60)
        
        print(f"\n--- Input Parameters ---")
        print(f"Win Rate:          {params.get('win_rate', 0)*100:.1f}%")
        print(f"Average Win:       +{params.get('avg_win_r', 0):.2f}R")
        print(f"Average Loss:      -{params.get('avg_loss_r', 0):.2f}R")
        print(f"Risk per Trade:    {params.get('risk_per_trade', 0)*100:.2f}%")
        print(f"Ruin Level:        {params.get('ruin_level', 0.2)*100:.0f}% drawdown")
        print(f"Target:            {params.get('target_level', 0.5)*100:.0f}% profit")
        
        print(f"\n--- Monte Carlo Results ({result.simulations:,} simulations) ---")
        print(f"Risk of Ruin:      {result.risk_of_ruin*100:.2f}%")
        print(f"P(Success):        {result.probability_of_success*100:.2f}%")
        print(f"Inconclusive:      {result.inconclusive*100:.2f}%")
        print(f"Safety Rating:     {result.safety_rating}")
        
        print(f"\n--- Drawdown Analysis ---")
        print(f"Median Max DD:     {result.median_max_drawdown*100:.1f}%")
        print(f"95th Pctl DD:      {result.percentile_95_drawdown*100:.1f}%")
        print(f"99th Pctl DD:      {result.percentile_99_drawdown*100:.1f}%")
        
        print(f"\n--- Position Sizing (Kelly Criterion) ---")
        print(f"Optimal Kelly:     {result.optimal_kelly_fraction*100:.2f}%")
        print(f"Half Kelly:        {result.half_kelly*100:.2f}% (recommended)")
        print(f"Quarter Kelly:     {result.quarter_kelly*100:.2f}% (conservative)")
        
        print(f"\n--- Interpretation ---")
        if result.risk_of_ruin < 0.01:
            print("EXCELLENT: Risk of ruin < 1%. System is very safe.")
            print("You can trade with confidence at current risk level.")
        elif result.risk_of_ruin < 0.05:
            print("GOOD: Risk of ruin 1-5%. Acceptable for trading.")
            print("Consider using Half Kelly for extra safety.")
        elif result.risk_of_ruin < 0.10:
            print("WARNING: Risk of ruin 5-10%. System is risky.")
            print("REDUCE risk per trade or improve system stats.")
        else:
            print("DANGEROUS: Risk of ruin > 10%!")
            print("DO NOT TRADE with current parameters!")
            print("Either reduce risk significantly or improve system.")
        
        # FTMO specific warning
        ruin_level = params.get('ruin_level', 0.2)
        if ruin_level <= 0.10 and result.risk_of_ruin > 0.01:
            print("\n FTMO WARNING: With 10% max DD limit,")
            print(f"   {result.risk_of_ruin*100:.1f}% RoR means ~{int(100/result.risk_of_ruin) if result.risk_of_ruin > 0 else '∞'} accounts")
            print("   before one gets blown. Reduce risk!")
        
        print("=" * 60)


if __name__ == '__main__':
    # Test with sample parameters
    calc = RiskOfRuinCalculator(seed=42)
    
    # System parameters (realistic example)
    params = {
        'win_rate': 0.60,
        'avg_win_r': 2.0,
        'avg_loss_r': 1.0,
        'risk_per_trade': 0.01,  # 1%
        'ruin_level': 0.20,      # 20% DD
        'target_level': 0.10,    # 10% profit (FTMO)
    }
    
    print("Calculating Risk of Ruin (this may take a moment)...")
    result = calc.calculate_monte_carlo(**params, simulations=10000)
    calc.print_report(result, params)
    
    # Find safe risk
    print("\n" + "-" * 60)
    print("Finding maximum safe risk for 1% RoR...")
    safe_risk = calc.find_safe_risk(
        win_rate=params['win_rate'],
        avg_win_r=params['avg_win_r'],
        avg_loss_r=params['avg_loss_r'],
        max_ror=0.01,
        ruin_level=params['ruin_level']
    )
    print(f"Maximum safe risk per trade: {safe_risk*100:.2f}%")
    
    # Sensitivity analysis
    print("\n" + "-" * 60)
    print("Risk Sensitivity Analysis:")
    print("-" * 60)
    sensitivity = calc.sensitivity_analysis(
        win_rate=params['win_rate'],
        avg_win_r=params['avg_win_r'],
        avg_loss_r=params['avg_loss_r']
    )
    
    print(f"{'Risk %':<10} {'RoR %':<10} {'P(Success) %':<15} {'Rating':<12}")
    print("-" * 50)
    for risk, res in sorted(sensitivity.items()):
        print(f"{risk*100:<10.2f} {res.risk_of_ruin*100:<10.2f} {res.probability_of_success*100:<15.2f} {res.safety_rating:<12}")
