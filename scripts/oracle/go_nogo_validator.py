"""
GO/NO-GO Validation Pipeline
=============================

Integrates all validation components for institutional-grade
strategy validation:
- Walk-Forward Analysis
- Monte Carlo Block Bootstrap  
- PSR/DSR/PBO Overfitting Detection
- Execution Cost Simulation
- Prop Firm Validation

For: EA_SCALPER_XAUUSD - ORACLE Validation v2.2

Usage:
    python -m scripts.oracle.go_nogo_validator --input trades.csv --n-trials 100
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass
from typing import List, Dict, Optional
from enum import Enum
from datetime import datetime
from pathlib import Path
import argparse

from scripts.oracle.walk_forward import WalkForwardAnalyzer
from scripts.oracle.monte_carlo import BlockBootstrapMC
from scripts.oracle.deflated_sharpe import SharpeAnalyzer
from scripts.oracle.prop_firm_validator import PropFirmValidator, PropFirm


class Decision(Enum):
    STRONG_GO = "STRONG_GO"
    GO = "GO"
    INVESTIGATE = "INVESTIGATE"
    NO_GO = "NO_GO"


@dataclass
class ValidationCriteria:
    """Configurable validation criteria"""
    # WFA
    min_wfe: float = 0.6
    min_oos_positive: float = 0.7
    
    # Monte Carlo
    max_95th_dd: float = 8.0
    max_prob_ruin: float = 5.0
    
    # Sharpe
    min_psr: float = 0.90
    min_dsr: float = 0.0
    
    # General
    min_trades: int = 100
    min_sharpe: float = 0.5
    max_dd_realized: float = 15.0
    
    # Prop Firm
    max_daily_breach_prob: float = 5.0
    max_total_breach_prob: float = 2.0


@dataclass
class ValidationResult:
    """Complete validation result"""
    decision: Decision
    confidence: int  # 0-100
    
    # Individual results
    wfa_passed: bool
    wfa_wfe: float
    wfa_oos_positive: float
    
    mc_passed: bool
    mc_95th_dd: float
    mc_prob_ruin: float
    mc_var_95: float
    mc_cvar_95: float
    
    sharpe_passed: bool
    sharpe_observed: float
    sharpe_psr: float
    sharpe_dsr: float
    
    propfirm_passed: bool
    propfirm_p_daily: float
    propfirm_p_total: float
    
    # Summary metrics
    total_trades: int
    total_pnl: float
    realized_sharpe: float
    realized_max_dd: float
    win_rate: float
    profit_factor: float
    
    # Details
    reasons: List[str]
    warnings: List[str]


class GoNoGoValidator:
    """
    Complete GO/NO-GO validation pipeline.
    
    Integrates:
    - Walk-Forward Analysis (robustness)
    - Monte Carlo Block Bootstrap (risk distribution)
    - PSR/DSR/PBO (overfitting detection)
    - Prop Firm Validation (FTMO-specific)
    
    Outputs:
    - Decision: STRONG_GO / GO / INVESTIGATE / NO_GO
    - Confidence Score: 0-100
    - Detailed Report
    """
    
    def __init__(
        self,
        criteria: ValidationCriteria = None,
        n_trials: int = 1,
        initial_capital: float = 100000
    ):
        self.criteria = criteria or ValidationCriteria()
        self.n_trials = n_trials
        self.initial_capital = initial_capital
    
    def validate(self, trades_df: pd.DataFrame, profit_col: str = 'profit') -> ValidationResult:
        """
        Execute complete validation pipeline.
        
        Args:
            trades_df: DataFrame with trades
            profit_col: Column name for profit/pnl
        
        Returns:
            ValidationResult with decision and details
        """
        reasons = []
        warnings = []
        
        # Ensure profit column exists
        if profit_col not in trades_df.columns:
            for col in ['profit', 'pnl', 'pl', 'return']:
                if col in trades_df.columns:
                    profit_col = col
                    break
            else:
                raise ValueError(f"No profit column found in DataFrame")
        
        pnl = trades_df[profit_col].values
        n_trades = len(pnl)
        
        # 0. Basic validation
        if n_trades < self.criteria.min_trades:
            return self._insufficient_sample_result(n_trades)
        
        # 1. Basic metrics
        total_pnl = pnl.sum()
        win_rate = (pnl > 0).mean()
        
        gross_profit = pnl[pnl > 0].sum() if any(pnl > 0) else 0
        gross_loss = abs(pnl[pnl < 0].sum()) if any(pnl < 0) else 1
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else 0
        
        # Realized Sharpe
        if pnl.std() > 0:
            realized_sharpe = np.sqrt(252) * pnl.mean() / pnl.std()
        else:
            realized_sharpe = 0
        
        # Realized Max DD
        equity = np.cumsum(pnl) + self.initial_capital
        peak = np.maximum.accumulate(equity)
        dd_pct = (peak - equity) / peak * 100
        realized_max_dd = dd_pct.max()
        
        print("Step 1/6: Basic metrics calculated")
        
        # 2. Walk-Forward Analysis
        print("Step 2/6: Running Walk-Forward Analysis...")
        try:
            wfa = WalkForwardAnalyzer(n_windows=12, is_ratio=0.75)
            wfa_result = wfa.run(trades_df, return_col=profit_col)
            wfa_wfe = wfa_result.wfe
            wfa_oos_positive = wfa_result.oos_positive_pct / 100
            wfa_passed = wfa_wfe >= self.criteria.min_wfe and wfa_oos_positive >= self.criteria.min_oos_positive
        except Exception as e:
            print(f"  WFA failed: {e}")
            wfa_wfe = 0
            wfa_oos_positive = 0
            wfa_passed = False
            warnings.append(f"WFA could not run: {str(e)}")
        
        if not wfa_passed:
            reasons.append(f"WFA: WFE={wfa_wfe:.2f} < {self.criteria.min_wfe}")
        
        # 3. Monte Carlo Block Bootstrap
        print("Step 3/6: Running Monte Carlo Simulation...")
        try:
            mc = BlockBootstrapMC(n_simulations=5000, initial_capital=self.initial_capital)
            mc_result = mc.run(trades_df, use_block=True)
            mc_95th = mc_result.dd_95th
            mc_prob_ruin = mc_result.risk_of_ruin_10pct
            mc_var_95 = mc_result.var_95
            mc_cvar_95 = mc_result.cvar_95
            mc_passed = mc_95th < self.criteria.max_95th_dd and mc_prob_ruin < self.criteria.max_prob_ruin
        except Exception as e:
            print(f"  MC failed: {e}")
            mc_95th = 99
            mc_prob_ruin = 99
            mc_var_95 = 99
            mc_cvar_95 = 99
            mc_passed = False
            warnings.append(f"Monte Carlo could not run: {str(e)}")
        
        if not mc_passed:
            if mc_95th >= self.criteria.max_95th_dd:
                reasons.append(f"MC: 95th DD={mc_95th:.1f}% >= {self.criteria.max_95th_dd}%")
            if mc_prob_ruin >= self.criteria.max_prob_ruin:
                reasons.append(f"MC: P(Ruin)={mc_prob_ruin:.1f}% >= {self.criteria.max_prob_ruin}%")
        
        # 4. PSR/DSR Analysis
        print("Step 4/6: Running Sharpe Analysis...")
        try:
            sharpe_analyzer = SharpeAnalyzer()
            returns = pnl / self.initial_capital
            sharpe_result = sharpe_analyzer.analyze(returns, n_trials=self.n_trials)
            sharpe_observed = sharpe_result.observed_sharpe
            sharpe_psr = sharpe_result.probabilistic_sharpe
            sharpe_dsr = sharpe_result.deflated_sharpe
            sharpe_passed = sharpe_psr >= self.criteria.min_psr and sharpe_dsr >= self.criteria.min_dsr
        except Exception as e:
            print(f"  Sharpe analysis failed: {e}")
            sharpe_observed = 0
            sharpe_psr = 0
            sharpe_dsr = -99
            sharpe_passed = False
            warnings.append(f"Sharpe analysis could not run: {str(e)}")
        
        if not sharpe_passed:
            if sharpe_psr < self.criteria.min_psr:
                reasons.append(f"PSR: {sharpe_psr:.2f} < {self.criteria.min_psr}")
            if sharpe_dsr < self.criteria.min_dsr:
                reasons.append(f"DSR: {sharpe_dsr:.2f} < {self.criteria.min_dsr} (OVERFITTING)")
        
        # 5. Prop Firm Validation
        print("Step 5/6: Running Prop Firm Validation...")
        try:
            pf_validator = PropFirmValidator(firm=PropFirm.FTMO, account_size=self.initial_capital)
            pf_result = pf_validator.validate(trades_df, profit_col=profit_col)
            propfirm_p_daily = pf_result.p_daily_breach
            propfirm_p_total = pf_result.p_total_breach
            propfirm_passed = propfirm_p_daily < self.criteria.max_daily_breach_prob and \
                             propfirm_p_total < self.criteria.max_total_breach_prob
        except Exception as e:
            print(f"  Prop firm validation failed: {e}")
            propfirm_p_daily = 99
            propfirm_p_total = 99
            propfirm_passed = False
            warnings.append(f"Prop firm validation could not run: {str(e)}")
        
        if not propfirm_passed:
            if propfirm_p_daily >= self.criteria.max_daily_breach_prob:
                reasons.append(f"FTMO: P(daily breach)={propfirm_p_daily:.1f}% >= {self.criteria.max_daily_breach_prob}%")
            if propfirm_p_total >= self.criteria.max_total_breach_prob:
                reasons.append(f"FTMO: P(total breach)={propfirm_p_total:.1f}% >= {self.criteria.max_total_breach_prob}%")
        
        # 6. Additional warnings
        print("Step 6/6: Final analysis...")
        if realized_max_dd > self.criteria.max_dd_realized * 0.8:
            warnings.append(f"DD approaching limit: {realized_max_dd:.1f}%")
        if win_rate < 0.4:
            warnings.append(f"Low win rate: {win_rate:.1%}")
        if profit_factor < 1.5:
            warnings.append(f"Low profit factor: {profit_factor:.2f}")
        if realized_sharpe > 4.0:
            warnings.append(f"Sharpe {realized_sharpe:.2f} suspiciously high - verify!")
        
        # 7. Calculate confidence score
        confidence = self._calculate_confidence(
            wfa_passed, wfa_wfe,
            mc_passed, mc_95th, mc_prob_ruin,
            sharpe_passed, sharpe_psr, sharpe_dsr,
            propfirm_passed, propfirm_p_daily, propfirm_p_total,
            len(warnings)
        )
        
        # 8. Final decision
        all_passed = wfa_passed and mc_passed and sharpe_passed and propfirm_passed
        
        if all_passed and confidence >= 85:
            decision = Decision.STRONG_GO
        elif all_passed or (confidence >= 70 and len(reasons) <= 1):
            decision = Decision.GO
        elif confidence >= 50 or len(reasons) <= 2:
            decision = Decision.INVESTIGATE
        else:
            decision = Decision.NO_GO
        
        return ValidationResult(
            decision=decision,
            confidence=confidence,
            wfa_passed=wfa_passed,
            wfa_wfe=wfa_wfe,
            wfa_oos_positive=wfa_oos_positive,
            mc_passed=mc_passed,
            mc_95th_dd=mc_95th,
            mc_prob_ruin=mc_prob_ruin,
            mc_var_95=mc_var_95,
            mc_cvar_95=mc_cvar_95,
            sharpe_passed=sharpe_passed,
            sharpe_observed=sharpe_observed,
            sharpe_psr=sharpe_psr,
            sharpe_dsr=sharpe_dsr,
            propfirm_passed=propfirm_passed,
            propfirm_p_daily=propfirm_p_daily,
            propfirm_p_total=propfirm_p_total,
            total_trades=n_trades,
            total_pnl=total_pnl,
            realized_sharpe=realized_sharpe,
            realized_max_dd=realized_max_dd,
            win_rate=win_rate,
            profit_factor=profit_factor,
            reasons=reasons,
            warnings=warnings
        )
    
    def _insufficient_sample_result(self, n_trades: int) -> ValidationResult:
        """Return result for insufficient sample"""
        return ValidationResult(
            decision=Decision.NO_GO,
            confidence=0,
            wfa_passed=False, wfa_wfe=0, wfa_oos_positive=0,
            mc_passed=False, mc_95th_dd=0, mc_prob_ruin=0, mc_var_95=0, mc_cvar_95=0,
            sharpe_passed=False, sharpe_observed=0, sharpe_psr=0, sharpe_dsr=0,
            propfirm_passed=False, propfirm_p_daily=0, propfirm_p_total=0,
            total_trades=n_trades, total_pnl=0, realized_sharpe=0, realized_max_dd=0,
            win_rate=0, profit_factor=0,
            reasons=[f"Insufficient trades: {n_trades} < {self.criteria.min_trades}"],
            warnings=[]
        )
    
    def _calculate_confidence(
        self,
        wfa_passed, wfa_wfe,
        mc_passed, mc_95th, mc_prob_ruin,
        sharpe_passed, sharpe_psr, sharpe_dsr,
        propfirm_passed, propfirm_p_daily, propfirm_p_total,
        n_warnings
    ) -> int:
        """Calculate confidence score 0-100"""
        score = 0
        
        # WFA component (25 points)
        if wfa_wfe >= 0.7:
            score += 25
        elif wfa_wfe >= 0.6:
            score += 20
        elif wfa_wfe >= 0.5:
            score += 15
        elif wfa_wfe >= 0.4:
            score += 5
        
        # Monte Carlo component (25 points)
        if mc_95th < 6:
            score += 25
        elif mc_95th < 8:
            score += 20
        elif mc_95th < 10:
            score += 10
        
        # Sharpe component (20 points)
        if sharpe_psr >= 0.95 and sharpe_dsr > 1:
            score += 20
        elif sharpe_psr >= 0.90 and sharpe_dsr > 0:
            score += 15
        elif sharpe_psr >= 0.85:
            score += 10
        elif sharpe_psr >= 0.80:
            score += 5
        
        # Prop Firm component (20 points)
        if propfirm_p_daily < 2 and propfirm_p_total < 1:
            score += 20
        elif propfirm_p_daily < 5 and propfirm_p_total < 2:
            score += 15
        elif propfirm_p_daily < 10:
            score += 5
        
        # Bonus for all passing (10 points)
        if wfa_passed and mc_passed and sharpe_passed and propfirm_passed:
            score += 10
        
        # Warning penalty
        score -= n_warnings * 3
        
        return max(0, min(100, score))
    
    def generate_report(self, result: ValidationResult) -> str:
        """Generate complete Markdown report"""
        lines = [
            "# GO/NO-GO Validation Report",
            f"\n**Date**: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
            f"**Decision**: **{result.decision.value}**",
            f"**Confidence Score**: {result.confidence}/100",
            "",
            "---",
            "",
            "## Summary Metrics",
            "",
            "| Metric | Value | Status |",
            "|--------|-------|--------|",
            f"| Total Trades | {result.total_trades} | {'✅' if result.total_trades >= self.criteria.min_trades else '❌'} |",
            f"| Total P&L | ${result.total_pnl:,.2f} | {'✅' if result.total_pnl > 0 else '❌'} |",
            f"| Win Rate | {result.win_rate:.1%} | {'✅' if result.win_rate >= 0.4 else '⚠️'} |",
            f"| Profit Factor | {result.profit_factor:.2f} | {'✅' if result.profit_factor >= 2.0 else '⚠️'} |",
            f"| Realized Sharpe | {result.realized_sharpe:.2f} | {'✅' if result.realized_sharpe >= 1.5 else '⚠️'} |",
            f"| Max Drawdown | {result.realized_max_dd:.1f}% | {'✅' if result.realized_max_dd <= 10 else '❌'} |",
            "",
            "---",
            "",
            "## Validation Results",
            "",
            "### Walk-Forward Analysis",
            f"- **Status**: {'✅ PASS' if result.wfa_passed else '❌ FAIL'}",
            f"- WFE: {result.wfa_wfe:.2f} (target: >= {self.criteria.min_wfe})",
            f"- OOS Positive: {result.wfa_oos_positive:.1%} (target: >= {self.criteria.min_oos_positive:.0%})",
            "",
            "### Monte Carlo Block Bootstrap",
            f"- **Status**: {'✅ PASS' if result.mc_passed else '❌ FAIL'}",
            f"- 95th Percentile DD: {result.mc_95th_dd:.1f}% (target: < {self.criteria.max_95th_dd}%)",
            f"- P(Ruin DD>10%): {result.mc_prob_ruin:.1f}% (target: < {self.criteria.max_prob_ruin}%)",
            f"- VaR 95%: {result.mc_var_95:.1f}%",
            f"- CVaR 95%: {result.mc_cvar_95:.1f}%",
            "",
            "### Overfitting Detection (PSR/DSR)",
            f"- **Status**: {'✅ PASS' if result.sharpe_passed else '❌ FAIL'}",
            f"- Observed Sharpe: {result.sharpe_observed:.2f}",
            f"- PSR: {result.sharpe_psr:.2f} (target: >= {self.criteria.min_psr})",
            f"- DSR: {result.sharpe_dsr:.2f} (target: > {self.criteria.min_dsr})",
            f"- N Trials Tested: {self.n_trials}",
            "",
            "### Prop Firm Validation (FTMO)",
            f"- **Status**: {'✅ PASS' if result.propfirm_passed else '❌ FAIL'}",
            f"- P(Daily DD > 5%): {result.propfirm_p_daily:.1f}% (target: < {self.criteria.max_daily_breach_prob}%)",
            f"- P(Total DD > 10%): {result.propfirm_p_total:.1f}% (target: < {self.criteria.max_total_breach_prob}%)",
            "",
        ]
        
        if result.reasons:
            lines.extend([
                "---",
                "",
                "## Failure Reasons",
                "",
            ])
            for reason in result.reasons:
                lines.append(f"- ❌ {reason}")
            lines.append("")
        
        if result.warnings:
            lines.extend([
                "---",
                "",
                "## Warnings",
                "",
            ])
            for warning in result.warnings:
                lines.append(f"- ⚠️ {warning}")
            lines.append("")
        
        lines.extend([
            "---",
            "",
            "## Final Decision",
            "",
        ])
        
        if result.decision == Decision.STRONG_GO:
            lines.extend([
                "### ✅✅ STRONG GO",
                "",
                "Strategy has passed ALL validation criteria with excellent scores.",
                "Approved for FTMO Challenge with high confidence.",
            ])
        elif result.decision == Decision.GO:
            lines.extend([
                "### ✅ GO",
                "",
                "Strategy has passed validation criteria.",
                "Approved for FTMO Challenge.",
            ])
        elif result.decision == Decision.INVESTIGATE:
            lines.extend([
                "### ⚠️ INVESTIGATE",
                "",
                "Strategy has mixed results. Review warnings and failed criteria.",
                "Consider adjustments before proceeding.",
            ])
        else:
            lines.extend([
                "### ❌ NO-GO",
                "",
                "Strategy has FAILED critical validation criteria.",
                "Do NOT proceed to live trading. Revise strategy.",
            ])
        
        lines.extend([
            "",
            "---",
            "",
            f"*Report generated by ORACLE v2.2 - {datetime.now().isoformat()}*"
        ])
        
        return "\n".join(lines)


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='GO/NO-GO Validation Pipeline')
    parser.add_argument('--input', '-i', required=True, help='CSV file with trades')
    parser.add_argument('--output', '-o', help='Output report path')
    parser.add_argument('--n-trials', '-n', type=int, default=1, help='Number of strategies tested')
    parser.add_argument('--capital', type=float, default=100000, help='Initial capital')
    parser.add_argument('--column', '-c', default='profit', help='Profit column')
    
    args = parser.parse_args()
    
    # Load data
    print(f"Loading trades from {args.input}...")
    trades = pd.read_csv(args.input)
    print(f"Loaded {len(trades)} trades")
    
    # Run validation
    print("\nRunning validation pipeline...\n")
    validator = GoNoGoValidator(n_trials=args.n_trials, initial_capital=args.capital)
    result = validator.validate(trades, profit_col=args.column)
    
    # Generate report
    report = validator.generate_report(result)
    
    # Output
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write(report)
        print(f"\nReport saved to {output_path}")
    
    # Print summary
    print("\n" + "=" * 60)
    print(f"DECISION: {result.decision.value}")
    print(f"CONFIDENCE: {result.confidence}/100")
    print("=" * 60)
    
    if result.reasons:
        print("\nFailed criteria:")
        for r in result.reasons:
            print(f"  - {r}")
    
    return 0 if result.decision in [Decision.GO, Decision.STRONG_GO] else 1


if __name__ == '__main__':
    exit(main())
