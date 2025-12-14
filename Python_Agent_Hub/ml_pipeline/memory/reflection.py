"""
Reflection Engine - Rule-Based Trade Analysis
EA_SCALPER_XAUUSD - Learning Edition

Analyzes closed trades to identify patterns and generate lessons.
100% rule-based - no LLM dependency, fast and deterministic.

Inspired by TradingAgents but optimized for:
- No API costs
- Instant analysis
- Deterministic results
"""
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple
from datetime import datetime
import json

from .trade_memory import TradeRecord, TradeMemory


@dataclass
class TradeReflection:
    """Result of reflecting on a trade."""
    ticket: int
    outcome: str  # 'WIN', 'LOSS', 'BREAKEVEN'
    reflection: str  # Human-readable analysis
    lessons: List[str]  # Specific lessons learned
    factors_positive: List[str]  # What went right
    factors_negative: List[str]  # What went wrong
    recommendation: str  # Future recommendation
    severity: str  # 'INFO', 'WARNING', 'CRITICAL'


class ReflectionEngine:
    """
    Rule-Based Reflection Engine.
    
    Analyzes trades using predefined rules to identify:
    - Why trades won or lost
    - Patterns in losing trades
    - Actionable lessons
    
    No LLM required - pure rule-based analysis.
    """
    
    def __init__(self, memory: Optional[TradeMemory] = None):
        """
        Initialize Reflection Engine.
        
        Args:
            memory: TradeMemory instance for storing reflections
        """
        self.memory = memory
        
        # Define analysis rules
        self._setup_rules()
    
    def _setup_rules(self):
        """Setup analysis rules for different scenarios."""
        
        # Rules for losing trades
        self.loss_rules = [
            # Regime-related
            {
                'condition': lambda t: t.features.get('hurst', 0.5) >= 0.45 and t.features.get('hurst', 0.5) <= 0.55,
                'lesson': "Traded in random walk regime (Hurst ~0.5) - avoid trading when Hurst is 0.45-0.55",
                'factor': "Random walk regime",
                'severity': 'WARNING'
            },
            {
                'condition': lambda t: t.features.get('entropy', 2.0) > 2.5,
                'lesson': "High entropy (>2.5) indicates noisy market - reduce size or wait",
                'factor': "High market noise",
                'severity': 'WARNING'
            },
            
            # Session-related
            {
                'condition': lambda t: t.session == 'ASIAN',
                'lesson': "Asian session loss - consider disabling Asian trading",
                'factor': "Low liquidity session",
                'severity': 'INFO'
            },
            {
                'condition': lambda t: t.session == 'NY' and t.entry_time.hour >= 20,
                'lesson': "Late NY session (after 20:00) - volume drops, spreads widen",
                'factor': "End of day trading",
                'severity': 'INFO'
            },
            
            # Spread-related
            {
                'condition': lambda t: t.spread_state in ['ELEVATED', 'HIGH', 'EXTREME'],
                'lesson': f"Spread was elevated - entry cost was high",
                'factor': "Elevated spread",
                'severity': 'WARNING'
            },
            
            # News-related
            {
                'condition': lambda t: t.news_window,
                'lesson': "Trade during news window - volatile and unpredictable",
                'factor': "News volatility",
                'severity': 'WARNING'
            },
            
            # Signal quality
            {
                'condition': lambda t: t.signal_tier in ['C', 'D'],
                'lesson': "Low tier signal (C/D) - only trade Tier A/B for better win rate",
                'factor': "Weak signal",
                'severity': 'WARNING'
            },
            {
                'condition': lambda t: t.confluence_score < 70,
                'lesson': "Low confluence score (<70) - need more confirming factors",
                'factor': "Low confluence",
                'severity': 'WARNING'
            },
            
            # Technical
            {
                'condition': lambda t: t.features.get('rsi', 50) > 70 and t.direction == 'BUY',
                'lesson': "Bought in overbought condition (RSI>70) - wait for pullback",
                'factor': "Overbought entry",
                'severity': 'INFO'
            },
            {
                'condition': lambda t: t.features.get('rsi', 50) < 30 and t.direction == 'SELL',
                'lesson': "Sold in oversold condition (RSI<30) - wait for bounce",
                'factor': "Oversold entry",
                'severity': 'INFO'
            },
            
            # R:R related
            {
                'condition': lambda t: abs(t.stop_loss - t.entry_price) > 50,  # > 50 pips SL
                'lesson': "Stop loss was too wide (>50 pips) - tighten SL or skip",
                'factor': "Wide stop loss",
                'severity': 'INFO'
            },
        ]
        
        # Rules for winning trades (to reinforce)
        self.win_rules = [
            {
                'condition': lambda t: t.features.get('hurst', 0.5) > 0.55,
                'lesson': "Trending regime (Hurst>0.55) worked well - continue trading trends",
                'factor': "Trending market",
            },
            {
                'condition': lambda t: t.session in ['LONDON', 'NY'] and 8 <= t.entry_time.hour <= 16,
                'lesson': "Core session trading (London/NY overlap) is optimal",
                'factor': "Optimal session",
            },
            {
                'condition': lambda t: t.signal_tier == 'A',
                'lesson': "Tier A signals have high success rate - prioritize these",
                'factor': "Strong signal",
            },
            {
                'condition': lambda t: t.confluence_score >= 85,
                'lesson': "High confluence (85+) leads to better outcomes",
                'factor': "High confluence",
            },
            {
                'condition': lambda t: t.r_multiple >= 2.0,
                'lesson': "Achieved 2R+ - good risk:reward execution",
                'factor': "Excellent R:R",
            },
        ]
    
    def reflect(self, trade: TradeRecord) -> TradeReflection:
        """
        Analyze a single trade and generate reflection.
        
        Args:
            trade: Completed trade to analyze
            
        Returns:
            TradeReflection with analysis results
        """
        # Determine outcome
        if trade.r_multiple > 0.1:
            outcome = 'WIN'
        elif trade.r_multiple < -0.1:
            outcome = 'LOSS'
        else:
            outcome = 'BREAKEVEN'
        
        factors_positive = []
        factors_negative = []
        lessons = []
        severity = 'INFO'
        
        if outcome == 'LOSS':
            # Apply loss rules
            for rule in self.loss_rules:
                try:
                    if rule['condition'](trade):
                        lessons.append(rule['lesson'])
                        factors_negative.append(rule['factor'])
                        if rule.get('severity') == 'CRITICAL':
                            severity = 'CRITICAL'
                        elif rule.get('severity') == 'WARNING' and severity != 'CRITICAL':
                            severity = 'WARNING'
                except Exception:
                    continue
        
        elif outcome == 'WIN':
            # Apply win rules
            for rule in self.win_rules:
                try:
                    if rule['condition'](trade):
                        lessons.append(rule['lesson'])
                        factors_positive.append(rule['factor'])
                except Exception:
                    continue
        
        # Generate reflection text
        reflection = self._generate_reflection_text(trade, outcome, factors_positive, factors_negative)
        
        # Generate recommendation
        recommendation = self._generate_recommendation(trade, outcome, lessons)
        
        return TradeReflection(
            ticket=trade.ticket,
            outcome=outcome,
            reflection=reflection,
            lessons=lessons,
            factors_positive=factors_positive,
            factors_negative=factors_negative,
            recommendation=recommendation,
            severity=severity
        )
    
    def _generate_reflection_text(
        self,
        trade: TradeRecord,
        outcome: str,
        factors_positive: List[str],
        factors_negative: List[str]
    ) -> str:
        """Generate human-readable reflection text."""
        
        lines = []
        
        # Header
        lines.append(f"Trade #{trade.ticket} Analysis ({outcome})")
        lines.append(f"Direction: {trade.direction} | R-Multiple: {trade.r_multiple:.2f}")
        lines.append(f"Context: {trade.regime} regime, {trade.session} session")
        lines.append("")
        
        if outcome == 'LOSS':
            if factors_negative:
                lines.append("Contributing Factors to Loss:")
                for factor in factors_negative:
                    lines.append(f"  - {factor}")
            else:
                lines.append("No specific pattern identified for this loss.")
        
        elif outcome == 'WIN':
            if factors_positive:
                lines.append("Factors Contributing to Success:")
                for factor in factors_positive:
                    lines.append(f"  + {factor}")
        
        return "\n".join(lines)
    
    def _generate_recommendation(
        self,
        trade: TradeRecord,
        outcome: str,
        lessons: List[str]
    ) -> str:
        """Generate actionable recommendation."""
        
        if outcome == 'WIN':
            return "Continue similar setups with these conditions."
        
        elif outcome == 'LOSS':
            if not lessons:
                return "Review trade manually - no pattern detected."
            
            # Prioritize lessons
            if any('random walk' in l.lower() for l in lessons):
                return "CRITICAL: Add Hurst filter gate - avoid 0.45-0.55 range."
            
            if any('entropy' in l.lower() for l in lessons):
                return "Add entropy check - reduce size when entropy > 2.5."
            
            if any('news' in l.lower() for l in lessons):
                return "Enable news window filter to avoid volatility."
            
            if any('spread' in l.lower() for l in lessons):
                return "Tighten spread filter threshold."
            
            if any('tier' in l.lower() or 'confluence' in l.lower() for l in lessons):
                return "Increase minimum signal quality threshold."
            
            return "Review and adjust filters based on identified patterns."
        
        return "Trade was breakeven - consider tightening TP or SL."
    
    def reflect_and_store(self, trade: TradeRecord) -> TradeReflection:
        """
        Reflect on trade and store in memory.
        
        Args:
            trade: Completed trade
            
        Returns:
            TradeReflection result
        """
        reflection = self.reflect(trade)
        
        # Update trade in memory with reflection
        if self.memory:
            self.memory.update_reflection(
                ticket=trade.ticket,
                reflection=reflection.reflection,
                lessons=reflection.lessons
            )
        
        return reflection
    
    def batch_reflect(self, trades: List[TradeRecord]) -> List[TradeReflection]:
        """Reflect on multiple trades."""
        return [self.reflect(trade) for trade in trades]
    
    def get_pattern_summary(self, trades: List[TradeRecord]) -> Dict:
        """
        Analyze multiple trades to find recurring patterns.
        
        Returns summary of most common issues.
        """
        all_factors_negative = []
        all_factors_positive = []
        
        for trade in trades:
            reflection = self.reflect(trade)
            all_factors_negative.extend(reflection.factors_negative)
            all_factors_positive.extend(reflection.factors_positive)
        
        # Count occurrences
        from collections import Counter
        
        neg_counts = Counter(all_factors_negative)
        pos_counts = Counter(all_factors_positive)
        
        return {
            'total_trades': len(trades),
            'most_common_issues': neg_counts.most_common(5),
            'most_common_strengths': pos_counts.most_common(5),
            'top_recommendation': self._get_top_recommendation(neg_counts)
        }
    
    def _get_top_recommendation(self, issue_counts: Dict[str, int]) -> str:
        """Get top recommendation based on issue frequency."""
        if not issue_counts:
            return "No significant patterns found."
        
        top_issue = issue_counts.most_common(1)[0][0]
        
        recommendations = {
            'Random walk regime': "Add strict Hurst filter (only trade H>0.55 or H<0.45)",
            'High market noise': "Add entropy filter (skip when entropy > 2.5)",
            'Low liquidity session': "Disable Asian session trading",
            'Elevated spread': "Tighten spread threshold to 2.0x average max",
            'News volatility': "Extend news window buffer to 45 minutes",
            'Weak signal': "Only trade Tier A/B signals",
            'Low confluence': "Increase minimum confluence to 80",
        }
        
        return recommendations.get(top_issue, f"Address '{top_issue}' pattern")


class RiskModeSelector:
    """
    Multi-Perspective Risk Mode Selector.
    
    Instead of LLM-based debate, uses calculated modes:
    - AGGRESSIVE: Maximize opportunity
    - NEUTRAL: Balanced (default)
    - CONSERVATIVE: Capital preservation
    - ADAPTIVE: Auto-adjust based on recent performance
    """
    
    def __init__(self, memory: Optional[TradeMemory] = None):
        self.memory = memory
        self.current_mode = 'NEUTRAL'
        self.consecutive_losses = 0
        self.daily_pnl = 0.0
    
    def update_state(self, trade_result: float, is_new_day: bool = False):
        """Update internal state based on trade results."""
        if is_new_day:
            self.daily_pnl = 0.0
        
        self.daily_pnl += trade_result
        
        if trade_result < 0:
            self.consecutive_losses += 1
        else:
            self.consecutive_losses = 0
    
    def get_mode(self, account_dd_daily: float, account_dd_total: float) -> Dict:
        """
        Determine current risk mode based on conditions.
        
        Returns:
            Dict with mode, multiplier, and reasoning
        """
        # AGGRESSIVE mode
        aggressive = self._aggressive_perspective(account_dd_daily, account_dd_total)
        
        # NEUTRAL mode
        neutral = self._neutral_perspective(account_dd_daily, account_dd_total)
        
        # CONSERVATIVE mode
        conservative = self._conservative_perspective(account_dd_daily, account_dd_total)
        
        # Adaptive selection
        selected = self._select_mode(aggressive, neutral, conservative)
        
        return {
            'mode': selected['mode'],
            'size_multiplier': selected['size_multiplier'],
            'score_adjustment': selected.get('score_adjustment', 0),
            'can_trade': selected['can_trade'],
            'reasoning': selected['reasoning'],
            'perspectives': {
                'aggressive': aggressive,
                'neutral': neutral,
                'conservative': conservative
            }
        }
    
    def _aggressive_perspective(self, dd_daily: float, dd_total: float) -> Dict:
        """Aggressive perspective - maximize opportunity."""
        can_trade = dd_daily < 4.5 and dd_total < 9.0  # Slightly looser than FTMO
        
        return {
            'mode': 'AGGRESSIVE',
            'can_trade': can_trade,
            'size_multiplier': 1.25,  # 25% larger positions
            'score_adjustment': 0,  # No adjustment needed
            'reasoning': 'Maximize opportunity within FTMO limits'
        }
    
    def _neutral_perspective(self, dd_daily: float, dd_total: float) -> Dict:
        """Neutral perspective - balanced approach."""
        can_trade = (
            dd_daily < 4.0 and
            dd_total < 8.0 and
            self.consecutive_losses < 5
        )
        
        return {
            'mode': 'NEUTRAL',
            'can_trade': can_trade,
            'size_multiplier': 1.0,
            'score_adjustment': 0,
            'reasoning': 'Standard risk parameters'
        }
    
    def _conservative_perspective(self, dd_daily: float, dd_total: float) -> Dict:
        """Conservative perspective - capital preservation."""
        can_trade = (
            dd_daily < 2.0 and  # Half of normal
            dd_total < 5.0 and  # Half of normal
            self.consecutive_losses < 3
        )
        
        return {
            'mode': 'CONSERVATIVE',
            'can_trade': can_trade,
            'size_multiplier': 0.5,  # Half size
            'score_adjustment': 10,  # Require higher score
            'reasoning': 'Capital preservation priority'
        }
    
    def _select_mode(self, agg: Dict, neu: Dict, con: Dict) -> Dict:
        """Select appropriate mode based on conditions."""
        
        # If in trouble, force conservative
        if self.consecutive_losses >= 3:
            return {
                **con,
                'reasoning': f'Forced CONSERVATIVE: {self.consecutive_losses} consecutive losses'
            }
        
        # If daily DD is high, be conservative
        if self.daily_pnl < -2.0:  # Lost 2% today
            return {
                **con,
                'reasoning': f'Forced CONSERVATIVE: Daily PnL {self.daily_pnl:.1f}%'
            }
        
        # Normal selection - use neutral as default
        return neu


if __name__ == '__main__':
    # Test reflection engine
    from datetime import datetime, timedelta
    
    engine = ReflectionEngine()
    
    # Create a losing trade
    losing_trade = TradeRecord(
        ticket=12345,
        symbol='XAUUSD',
        direction='BUY',
        entry_time=datetime.now() - timedelta(hours=2),
        exit_time=datetime.now(),
        entry_price=2000,
        exit_price=1985,
        stop_loss=1980,
        take_profit=2040,
        profit_loss=-15,
        profit_pips=-15,
        r_multiple=-0.75,
        is_winner=False,
        features={
            'hurst': 0.48,  # Random walk!
            'entropy': 2.8,  # High noise!
            'rsi': 65,
        },
        regime='RANDOM',
        session='ASIAN',  # Bad session
        spread_state='ELEVATED',  # Bad spread
        news_window=False,
        confluence_score=68,  # Low
        signal_tier='C'  # Low tier
    )
    
    reflection = engine.reflect(losing_trade)
    
    print("=" * 60)
    print("TRADE REFLECTION")
    print("=" * 60)
    print(reflection.reflection)
    print()
    print(f"Severity: {reflection.severity}")
    print(f"Lessons ({len(reflection.lessons)}):")
    for lesson in reflection.lessons:
        print(f"  - {lesson}")
    print()
    print(f"Recommendation: {reflection.recommendation}")
    
    # Test risk mode selector
    print("\n" + "=" * 60)
    print("RISK MODE SELECTION")
    print("=" * 60)
    
    selector = RiskModeSelector()
    
    # Normal conditions
    mode = selector.get_mode(1.0, 3.0)
    print(f"Normal conditions: {mode['mode']} (size: {mode['size_multiplier']}x)")
    
    # After losses
    selector.consecutive_losses = 4
    mode = selector.get_mode(1.0, 3.0)
    print(f"After 4 losses: {mode['mode']} (size: {mode['size_multiplier']}x)")
    print(f"  Reason: {mode['reasoning']}")
