"""
Unified Confidence Score System
================================

Provides a single, consistent confidence scoring system
for all Oracle validation components.

For: EA_SCALPER_XAUUSD - ORACLE Validation v2.2

Usage:
    from scripts.oracle.confidence import UnifiedConfidenceCalculator, ConfidenceComponents
    
    calc = UnifiedConfidenceCalculator()
    components = calc.calculate(
        wfe=0.65, oos_positive_pct=0.8,
        dd_95=7.5, prob_ruin=3.0,
        psr=0.92, dsr=0.8,
        p_daily=3.5, p_total=1.5
    )
    print(f"Total Score: {components.total}")
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple
from enum import Enum


class Decision(Enum):
    STRONG_GO = "STRONG_GO"
    GO = "GO"
    INVESTIGATE = "INVESTIGATE"
    NO_GO = "NO_GO"


@dataclass
class ConfidenceComponents:
    """Breakdown of confidence score components"""
    wfa: int = 0          # 0-25 points
    monte_carlo: int = 0  # 0-25 points
    sharpe: int = 0       # 0-20 points
    prop_firm: int = 0    # 0-20 points
    bonus: int = 0        # 0-10 points (Level 4 robustness)
    penalties: int = 0    # Negative points (warnings)
    
    # Details for reporting
    wfa_details: Dict = field(default_factory=dict)
    mc_details: Dict = field(default_factory=dict)
    sharpe_details: Dict = field(default_factory=dict)
    propfirm_details: Dict = field(default_factory=dict)
    warnings: List[str] = field(default_factory=list)
    
    @property
    def total(self) -> int:
        """Calculate total score (0-100)"""
        raw = self.wfa + self.monte_carlo + self.sharpe + self.prop_firm + self.bonus - self.penalties
        return max(0, min(100, raw))
    
    @property
    def decision(self) -> Decision:
        """Determine decision based on total score"""
        if self.total >= 85:
            return Decision.STRONG_GO
        elif self.total >= 70:
            return Decision.GO
        elif self.total >= 50:
            return Decision.INVESTIGATE
        else:
            return Decision.NO_GO
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for JSON serialization"""
        return {
            'wfa': self.wfa,
            'monte_carlo': self.monte_carlo,
            'sharpe': self.sharpe,
            'prop_firm': self.prop_firm,
            'bonus': self.bonus,
            'penalties': self.penalties,
            'total': self.total,
            'decision': self.decision.value,
            'wfa_details': self.wfa_details,
            'mc_details': self.mc_details,
            'sharpe_details': self.sharpe_details,
            'propfirm_details': self.propfirm_details,
            'warnings': self.warnings
        }
    
    def generate_report(self) -> str:
        """Generate formatted report string"""
        lines = [
            "=" * 60,
            "CONFIDENCE SCORE BREAKDOWN",
            "=" * 60,
            "",
            f"WFA Component:        {self.wfa:3}/25",
        ]
        
        if self.wfa_details:
            lines.append(f"  - WFE: {self.wfa_details.get('wfe', 'N/A')}")
            lines.append(f"  - OOS Positive: {self.wfa_details.get('oos_positive', 'N/A')}")
        
        lines.extend([
            "",
            f"Monte Carlo Component: {self.monte_carlo:3}/25",
        ])
        
        if self.mc_details:
            lines.append(f"  - DD 95th: {self.mc_details.get('dd_95', 'N/A')}%")
            lines.append(f"  - P(Ruin): {self.mc_details.get('prob_ruin', 'N/A')}%")
        
        lines.extend([
            "",
            f"Sharpe Component:     {self.sharpe:3}/20",
        ])
        
        if self.sharpe_details:
            lines.append(f"  - PSR: {self.sharpe_details.get('psr', 'N/A')}")
            lines.append(f"  - DSR: {self.sharpe_details.get('dsr', 'N/A')}")
        
        lines.extend([
            "",
            f"Prop Firm Component:  {self.prop_firm:3}/20",
        ])
        
        if self.propfirm_details:
            lines.append(f"  - P(Daily Breach): {self.propfirm_details.get('p_daily', 'N/A')}%")
            lines.append(f"  - P(Total Breach): {self.propfirm_details.get('p_total', 'N/A')}%")
        
        lines.extend([
            "",
            f"Level 4 Bonus:        {self.bonus:3}/10",
            f"Warning Penalties:    {-self.penalties:3}",
            "",
            "-" * 60,
            f"TOTAL SCORE:          {self.total:3}/100",
            f"DECISION:             {self.decision.value}",
            "=" * 60,
        ])
        
        if self.warnings:
            lines.extend([
                "",
                "WARNINGS:",
            ])
            for w in self.warnings:
                lines.append(f"  - {w}")
        
        return "\n".join(lines)


class UnifiedConfidenceCalculator:
    """
    Unified Confidence Score Calculator for Oracle v2.2.
    
    Scoring System:
    - WFA Component: 0-25 points
    - Monte Carlo Component: 0-25 points
    - Sharpe Component (PSR/DSR): 0-20 points
    - Prop Firm Component: 0-20 points
    - Level 4 Bonus: 0-10 points
    - Warning Penalties: -3 points each
    
    Total: 0-100 points
    
    Decision Thresholds:
    - 85-100: STRONG_GO
    - 70-84: GO
    - 50-69: INVESTIGATE
    - 0-49: NO_GO
    """
    
    @staticmethod
    def calculate_wfa_component(wfe: float, oos_positive_pct: float) -> Tuple[int, Dict]:
        """
        Calculate WFA Component (0-25 points).
        
        Args:
            wfe: Walk-Forward Efficiency (0-1+)
            oos_positive_pct: Percentage of OOS positive windows (0-1)
        
        Returns:
            (score, details_dict)
        """
        score = 0
        
        # WFE scoring (0-15 points)
        if wfe >= 0.7:
            wfe_score = 15
        elif wfe >= 0.6:
            wfe_score = 12
        elif wfe >= 0.5:
            wfe_score = 8
        elif wfe >= 0.4:
            wfe_score = 4
        else:
            wfe_score = 0
        score += wfe_score
        
        # OOS Positive scoring (0-10 points)
        if oos_positive_pct >= 0.8:
            oos_score = 10
        elif oos_positive_pct >= 0.7:
            oos_score = 7
        elif oos_positive_pct >= 0.6:
            oos_score = 4
        elif oos_positive_pct >= 0.5:
            oos_score = 2
        else:
            oos_score = 0
        score += oos_score
        
        details = {
            'wfe': round(wfe, 3),
            'wfe_score': wfe_score,
            'oos_positive': round(oos_positive_pct, 3),
            'oos_score': oos_score
        }
        
        return min(25, score), details
    
    @staticmethod
    def calculate_mc_component(dd_95: float, prob_ruin: float) -> Tuple[int, Dict]:
        """
        Calculate Monte Carlo Component (0-25 points).
        
        Args:
            dd_95: 95th percentile max drawdown (%)
            prob_ruin: Probability of hitting 10% DD (%)
        
        Returns:
            (score, details_dict)
        """
        score = 0
        
        # DD 95th scoring (0-15 points)
        if dd_95 < 5:
            dd_score = 15
        elif dd_95 < 6:
            dd_score = 12
        elif dd_95 < 8:
            dd_score = 8
        elif dd_95 < 10:
            dd_score = 4
        else:
            dd_score = 0
        score += dd_score
        
        # P(Ruin) scoring (0-10 points)
        if prob_ruin < 2:
            ruin_score = 10
        elif prob_ruin < 5:
            ruin_score = 7
        elif prob_ruin < 10:
            ruin_score = 4
        elif prob_ruin < 15:
            ruin_score = 2
        else:
            ruin_score = 0
        score += ruin_score
        
        details = {
            'dd_95': round(dd_95, 2),
            'dd_score': dd_score,
            'prob_ruin': round(prob_ruin, 2),
            'ruin_score': ruin_score
        }
        
        return min(25, score), details
    
    @staticmethod
    def calculate_sharpe_component(psr: float, dsr: float) -> Tuple[int, Dict]:
        """
        Calculate Sharpe Component (0-20 points).
        
        Args:
            psr: Probabilistic Sharpe Ratio (0-1)
            dsr: Deflated Sharpe Ratio (can be negative)
        
        Returns:
            (score, details_dict)
        """
        score = 0
        
        # PSR scoring (0-10 points)
        if psr >= 0.95:
            psr_score = 10
        elif psr >= 0.90:
            psr_score = 7
        elif psr >= 0.85:
            psr_score = 4
        elif psr >= 0.80:
            psr_score = 2
        else:
            psr_score = 0
        score += psr_score
        
        # DSR scoring (0-10 points)
        # DSR < 0 = OVERFITTING, gets 0 points
        if dsr > 1.0:
            dsr_score = 10
        elif dsr > 0.5:
            dsr_score = 7
        elif dsr > 0:
            dsr_score = 4
        else:
            dsr_score = 0  # DSR <= 0 = overfitting
        score += dsr_score
        
        details = {
            'psr': round(psr, 3),
            'psr_score': psr_score,
            'dsr': round(dsr, 3),
            'dsr_score': dsr_score,
            'overfitting_warning': dsr < 0
        }
        
        return min(20, score), details
    
    @staticmethod
    def calculate_propfirm_component(p_daily: float, p_total: float) -> Tuple[int, Dict]:
        """
        Calculate Prop Firm Component (0-20 points).
        
        Args:
            p_daily: Probability of daily DD breach (%)
            p_total: Probability of total DD breach (%)
        
        Returns:
            (score, details_dict)
        """
        score = 0
        
        # P(Daily Breach) scoring (0-10 points)
        if p_daily < 2:
            daily_score = 10
        elif p_daily < 5:
            daily_score = 7
        elif p_daily < 10:
            daily_score = 4
        elif p_daily < 15:
            daily_score = 2
        else:
            daily_score = 0
        score += daily_score
        
        # P(Total Breach) scoring (0-10 points)
        if p_total < 1:
            total_score = 10
        elif p_total < 2:
            total_score = 7
        elif p_total < 5:
            total_score = 4
        elif p_total < 10:
            total_score = 2
        else:
            total_score = 0
        score += total_score
        
        details = {
            'p_daily': round(p_daily, 2),
            'daily_score': daily_score,
            'p_total': round(p_total, 2),
            'total_score': total_score
        }
        
        return min(20, score), details
    
    @staticmethod
    def generate_warnings(
        wfe: float,
        dd_95: float,
        psr: float,
        dsr: float,
        p_daily: float,
        p_total: float,
        sharpe_observed: float = None,
        win_rate: float = None,
        profit_factor: float = None
    ) -> List[str]:
        """Generate warning messages for concerning metrics."""
        warnings = []
        
        # Critical warnings
        if dsr < 0:
            warnings.append(f"DSR={dsr:.2f} < 0: OVERFITTING DETECTED")
        
        if dd_95 > 10:
            warnings.append(f"DD 95th={dd_95:.1f}% > 10%: High ruin risk")
        
        if p_daily > 10:
            warnings.append(f"P(Daily DD>5%)={p_daily:.1f}% > 10%: Daily violation likely")
        
        if p_total > 5:
            warnings.append(f"P(Total DD>10%)={p_total:.1f}% > 5%: Total violation likely")
        
        # Moderate warnings
        if wfe < 0.4:
            warnings.append(f"WFE={wfe:.2f} < 0.4: Severe overfitting suspected")
        
        if psr < 0.80:
            warnings.append(f"PSR={psr:.2f} < 0.80: Sharpe may be noise")
        
        # Suspicious metrics warnings
        if sharpe_observed is not None and sharpe_observed > 4.0:
            warnings.append(f"Sharpe={sharpe_observed:.2f} > 4.0: SUSPICIOUS - verify calculation")
        
        if win_rate is not None and win_rate > 0.80:
            warnings.append(f"Win Rate={win_rate:.1%} > 80%: Possible curve-fitting or martingale")
        
        if profit_factor is not None and profit_factor > 5.0:
            warnings.append(f"Profit Factor={profit_factor:.2f} > 5.0: SUSPICIOUS - verify data")
        
        return warnings
    
    def calculate(
        self,
        wfe: float,
        oos_positive_pct: float,
        dd_95: float,
        prob_ruin: float,
        psr: float,
        dsr: float,
        p_daily: float,
        p_total: float,
        level4_complete: bool = False,
        sharpe_observed: float = None,
        win_rate: float = None,
        profit_factor: float = None
    ) -> ConfidenceComponents:
        """
        Calculate complete confidence score.
        
        Args:
            wfe: Walk-Forward Efficiency (0-1+)
            oos_positive_pct: OOS positive windows ratio (0-1)
            dd_95: 95th percentile max DD (%)
            prob_ruin: P(hitting 10% DD) (%)
            psr: Probabilistic Sharpe Ratio (0-1)
            dsr: Deflated Sharpe Ratio
            p_daily: P(daily DD breach) (%)
            p_total: P(total DD breach) (%)
            level4_complete: All Level 4 criteria passed
            sharpe_observed: Observed Sharpe (for warnings)
            win_rate: Win rate (for warnings)
            profit_factor: Profit factor (for warnings)
        
        Returns:
            ConfidenceComponents with complete breakdown
        """
        # Calculate each component
        wfa_score, wfa_details = self.calculate_wfa_component(wfe, oos_positive_pct)
        mc_score, mc_details = self.calculate_mc_component(dd_95, prob_ruin)
        sharpe_score, sharpe_details = self.calculate_sharpe_component(psr, dsr)
        pf_score, pf_details = self.calculate_propfirm_component(p_daily, p_total)
        
        # Level 4 bonus
        bonus = 10 if level4_complete else 0
        
        # Generate warnings
        warnings = self.generate_warnings(
            wfe, dd_95, psr, dsr, p_daily, p_total,
            sharpe_observed, win_rate, profit_factor
        )
        
        # Calculate penalties
        penalties = len(warnings) * 3
        
        return ConfidenceComponents(
            wfa=wfa_score,
            monte_carlo=mc_score,
            sharpe=sharpe_score,
            prop_firm=pf_score,
            bonus=bonus,
            penalties=penalties,
            wfa_details=wfa_details,
            mc_details=mc_details,
            sharpe_details=sharpe_details,
            propfirm_details=pf_details,
            warnings=warnings
        )


# Convenience function
def calculate_confidence_score(
    wfe: float,
    oos_positive_pct: float,
    dd_95: float,
    prob_ruin: float,
    psr: float,
    dsr: float,
    p_daily: float,
    p_total: float,
    **kwargs
) -> int:
    """
    Quick function to calculate just the total score.
    
    Returns:
        Total confidence score (0-100)
    """
    calc = UnifiedConfidenceCalculator()
    components = calc.calculate(
        wfe, oos_positive_pct, dd_95, prob_ruin, psr, dsr, p_daily, p_total, **kwargs
    )
    return components.total


if __name__ == '__main__':
    # Example usage
    calc = UnifiedConfidenceCalculator()
    
    # Example good strategy
    result = calc.calculate(
        wfe=0.65,
        oos_positive_pct=0.80,
        dd_95=7.5,
        prob_ruin=3.5,
        psr=0.92,
        dsr=0.85,
        p_daily=4.0,
        p_total=1.8,
        sharpe_observed=2.1,
        win_rate=0.55,
        profit_factor=2.3
    )
    
    print(result.generate_report())
    print()
    print(f"Decision: {result.decision.value}")
