"""
Spread Analyzer - EA_SCALPER_XAUUSD P1 Enhancement
===================================================
Smart spread awareness to optimize entry timing.

Features:
- Track average spread by session
- Detect spread spikes (avoid)
- Calculate optimal entry timing
- Adjust SL/TP for current spread

Author: FORGE v3.1
Date: 2025-12-01
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
from datetime import datetime, timedelta
from enum import IntEnum
from collections import deque


class SpreadCondition(IntEnum):
    """Current spread condition."""
    OPTIMAL = 0      # < avg spread (great for entry)
    NORMAL = 1       # Around avg spread
    ELEVATED = 2     # 1.5x avg (caution)
    HIGH = 3         # 2x avg (avoid)
    EXTREME = 4      # 3x+ avg (no trade)


class SessionType(IntEnum):
    """Trading session type."""
    ASIAN = 0
    LONDON = 1
    LONDON_NY_OVERLAP = 2
    NY = 3
    LATE_NY = 4
    WEEKEND = 5


@dataclass
class SpreadStats:
    """Spread statistics for a session."""
    session: SessionType = SessionType.LONDON
    avg_spread: float = 0.0
    min_spread: float = 0.0
    max_spread: float = 0.0
    std_spread: float = 0.0
    samples: int = 0


@dataclass
class SpreadAnalysisResult:
    """Result of spread analysis."""
    current_spread: float = 0.0
    avg_spread: float = 0.0
    spread_ratio: float = 1.0       # current / avg
    condition: SpreadCondition = SpreadCondition.NORMAL
    
    # Entry recommendation
    allow_entry: bool = True
    wait_for_better: bool = False
    urgency_threshold: float = 0.8  # Signal urgency needed to trade
    
    # Adjustments
    sl_adjustment: float = 0.0      # Points to add to SL
    tp_adjustment: float = 0.0      # Points to subtract from TP
    cost_in_r: float = 0.0          # Spread cost as fraction of R
    
    # Timing
    seconds_until_optimal: int = 0
    optimal_session: str = ""
    
    reason: str = ""


class SpreadAnalyzer:
    """
    Smart spread analysis for optimal entry timing.
    
    Key principles:
    1. Track spread by session (London has tightest spreads)
    2. Avoid entry during spread spikes
    3. Adjust execution based on spread conditions
    4. Calculate true cost of entry
    """
    
    # Typical XAUUSD spread thresholds (in points)
    OPTIMAL_SPREAD = 20       # Ideal
    NORMAL_SPREAD = 35        # Acceptable
    HIGH_SPREAD = 50          # Elevated
    MAX_SPREAD = 80           # Maximum allowed
    
    # Session spread multipliers (London = baseline)
    SESSION_SPREAD_MULT = {
        SessionType.ASIAN: 1.4,
        SessionType.LONDON: 1.0,
        SessionType.LONDON_NY_OVERLAP: 0.9,
        SessionType.NY: 1.1,
        SessionType.LATE_NY: 1.5,
        SessionType.WEEKEND: 3.0,
    }
    
    def __init__(self, 
                 history_size: int = 1000,
                 spike_threshold: float = 1.5,
                 max_allowed_spread: int = 80,
                 gmt_offset: int = 0):
        """
        Initialize Spread Analyzer.
        
        Args:
            history_size: Number of spread samples to keep
            spike_threshold: Ratio above avg to consider spike
            max_allowed_spread: Maximum spread to allow entry
            gmt_offset: GMT offset for session detection
        """
        self.history_size = history_size
        self.spike_threshold = spike_threshold
        self.max_allowed_spread = max_allowed_spread
        self.gmt_offset = gmt_offset
        
        # Spread history per session
        self.spread_history: Dict[SessionType, deque] = {
            session: deque(maxlen=history_size)
            for session in SessionType
        }
        
        # Overall history
        self.recent_spreads = deque(maxlen=100)
        
        # Session stats
        self.session_stats: Dict[SessionType, SpreadStats] = {}
        self._initialize_default_stats()
    
    def _initialize_default_stats(self):
        """Initialize with default spread estimates."""
        for session in SessionType:
            mult = self.SESSION_SPREAD_MULT.get(session, 1.0)
            self.session_stats[session] = SpreadStats(
                session=session,
                avg_spread=self.NORMAL_SPREAD * mult,
                min_spread=self.OPTIMAL_SPREAD * mult,
                max_spread=self.HIGH_SPREAD * mult,
                std_spread=10.0 * mult,
                samples=0,
            )
    
    def get_current_session(self, timestamp: datetime) -> SessionType:
        """Determine current trading session."""
        if timestamp.weekday() >= 5:
            return SessionType.WEEKEND
        
        gmt_hour = timestamp.hour - self.gmt_offset
        if gmt_hour < 0:
            gmt_hour += 24
        if gmt_hour >= 24:
            gmt_hour -= 24
        
        if 12 <= gmt_hour < 16:
            return SessionType.LONDON_NY_OVERLAP
        elif 7 <= gmt_hour < 12:
            return SessionType.LONDON
        elif 16 <= gmt_hour < 21:
            return SessionType.NY
        elif 21 <= gmt_hour or gmt_hour < 0:
            return SessionType.LATE_NY
        else:  # 0 <= gmt_hour < 7
            return SessionType.ASIAN
    
    def record_spread(self, spread: float, timestamp: datetime):
        """Record a spread observation."""
        session = self.get_current_session(timestamp)
        
        self.spread_history[session].append(spread)
        self.recent_spreads.append(spread)
        
        # Update session stats
        history = list(self.spread_history[session])
        if history:
            stats = self.session_stats[session]
            stats.avg_spread = np.mean(history)
            stats.min_spread = np.min(history)
            stats.max_spread = np.max(history)
            stats.std_spread = np.std(history) if len(history) > 1 else 10.0
            stats.samples = len(history)
    
    def get_average_spread(self, session: SessionType = None, 
                           use_recent: bool = True) -> float:
        """Get average spread for session or recent history."""
        if use_recent and len(self.recent_spreads) >= 20:
            return np.mean(list(self.recent_spreads))
        
        if session is not None and session in self.session_stats:
            return self.session_stats[session].avg_spread
        
        return self.NORMAL_SPREAD
    
    def get_spread_condition(self, current_spread: float, 
                              avg_spread: float) -> SpreadCondition:
        """Classify current spread condition."""
        if avg_spread <= 0:
            avg_spread = self.NORMAL_SPREAD
        
        ratio = current_spread / avg_spread
        
        if ratio <= 0.8:
            return SpreadCondition.OPTIMAL
        elif ratio <= 1.2:
            return SpreadCondition.NORMAL
        elif ratio <= 1.5:
            return SpreadCondition.ELEVATED
        elif ratio <= 2.0:
            return SpreadCondition.HIGH
        else:
            return SpreadCondition.EXTREME
    
    def calculate_spread_cost(self, spread: float, sl_points: float) -> float:
        """
        Calculate spread cost as fraction of risk (R).
        
        Spread = entry cost = reduces effective R:R
        
        Example: 30 point spread with 50 point SL = 0.6R cost
        """
        if sl_points <= 0:
            return 0.0
        return spread / sl_points
    
    def get_sl_adjustment(self, current_spread: float, 
                          avg_spread: float) -> float:
        """
        Get SL adjustment for current spread.
        
        If spread is elevated, may need wider SL to avoid
        being stopped out by spread expansion.
        """
        if current_spread <= avg_spread:
            return 0.0
        
        excess = current_spread - avg_spread
        return excess * 0.5  # Add half of excess to SL
    
    def get_optimal_session(self) -> Tuple[SessionType, float]:
        """Get session with best (tightest) spread."""
        best_session = SessionType.LONDON_NY_OVERLAP
        best_spread = float('inf')
        
        for session, stats in self.session_stats.items():
            if session == SessionType.WEEKEND:
                continue
            if stats.avg_spread < best_spread and stats.samples > 10:
                best_spread = stats.avg_spread
                best_session = session
        
        return best_session, best_spread
    
    def analyze(self, current_spread: float, timestamp: datetime,
                sl_points: float = 50.0,
                signal_urgency: float = 0.5) -> SpreadAnalysisResult:
        """
        Analyze current spread and provide recommendations.
        
        Args:
            current_spread: Current spread in points
            timestamp: Current timestamp
            sl_points: Planned stop loss in points
            signal_urgency: How urgent is the signal (0-1)
        
        Returns:
            SpreadAnalysisResult with recommendations
        """
        result = SpreadAnalysisResult()
        result.current_spread = current_spread
        
        # Record spread
        self.record_spread(current_spread, timestamp)
        
        # Get average for current session
        session = self.get_current_session(timestamp)
        result.avg_spread = self.get_average_spread(session)
        
        # Calculate ratio
        result.spread_ratio = (current_spread / result.avg_spread 
                               if result.avg_spread > 0 else 1.0)
        
        # Get condition
        result.condition = self.get_spread_condition(current_spread, result.avg_spread)
        
        # Calculate cost
        result.cost_in_r = self.calculate_spread_cost(current_spread, sl_points)
        
        # Entry decision
        if current_spread > self.max_allowed_spread:
            result.allow_entry = False
            result.reason = f"Spread {current_spread} > max {self.max_allowed_spread}"
        elif result.condition == SpreadCondition.EXTREME:
            result.allow_entry = False
            result.reason = f"Extreme spread: {result.spread_ratio:.1f}x avg"
        elif result.condition == SpreadCondition.HIGH:
            # Allow only if signal is urgent
            result.urgency_threshold = 0.9
            result.allow_entry = signal_urgency >= 0.9
            result.wait_for_better = signal_urgency < 0.9
            result.reason = f"High spread: {result.spread_ratio:.1f}x avg"
        elif result.condition == SpreadCondition.ELEVATED:
            result.urgency_threshold = 0.7
            result.allow_entry = True
            result.wait_for_better = signal_urgency < 0.7
            result.reason = f"Elevated spread: {result.spread_ratio:.1f}x avg"
        else:
            result.allow_entry = True
            result.wait_for_better = False
            result.reason = "Normal spread conditions"
        
        # Adjustments
        result.sl_adjustment = self.get_sl_adjustment(current_spread, result.avg_spread)
        result.tp_adjustment = current_spread * 0.3  # Reduce TP slightly
        
        # Optimal session info
        opt_session, opt_spread = self.get_optimal_session()
        result.optimal_session = opt_session.name
        
        # Estimate time to optimal (simplified)
        if session != opt_session:
            result.seconds_until_optimal = self._estimate_time_to_session(
                timestamp, opt_session
            )
        
        return result
    
    def _estimate_time_to_session(self, now: datetime, 
                                   target: SessionType) -> int:
        """Estimate seconds until target session."""
        # Session start hours (GMT)
        session_starts = {
            SessionType.ASIAN: 0,
            SessionType.LONDON: 7,
            SessionType.LONDON_NY_OVERLAP: 12,
            SessionType.NY: 16,
            SessionType.LATE_NY: 21,
        }
        
        if target not in session_starts:
            return 0
        
        target_hour = session_starts[target]
        current_hour = now.hour - self.gmt_offset
        if current_hour < 0:
            current_hour += 24
        
        hours_until = target_hour - current_hour
        if hours_until <= 0:
            hours_until += 24
        
        return hours_until * 3600
    
    def should_wait_for_spread(self, current_spread: float,
                                timestamp: datetime,
                                max_wait_minutes: int = 15) -> Tuple[bool, str]:
        """
        Should we wait for better spread?
        
        Returns:
            (should_wait, reason)
        """
        session = self.get_current_session(timestamp)
        avg = self.get_average_spread(session)
        
        if current_spread > avg * 1.5:
            return True, f"Spread {current_spread:.0f} > 1.5x avg ({avg:.0f})"
        
        # Check if spread typically improves soon
        if session == SessionType.LATE_NY:
            return True, "Late NY session - spreads typically wide"
        
        if session == SessionType.ASIAN and current_spread > avg * 1.2:
            return True, "Asian session - wait for London"
        
        return False, "Spread acceptable"
    
    def get_session_summary(self) -> Dict[str, dict]:
        """Get spread summary for all sessions."""
        summary = {}
        for session, stats in self.session_stats.items():
            summary[session.name] = {
                'avg_spread': f"{stats.avg_spread:.1f}",
                'min_spread': f"{stats.min_spread:.1f}",
                'max_spread': f"{stats.max_spread:.1f}",
                'samples': stats.samples,
            }
        return summary


# Convenience function
def create_spread_analyzer(**kwargs) -> SpreadAnalyzer:
    """Factory function to create SpreadAnalyzer."""
    return SpreadAnalyzer(**kwargs)


if __name__ == "__main__":
    # Test
    print("Spread Analyzer Test")
    print("=" * 50)
    
    analyzer = SpreadAnalyzer(gmt_offset=0)
    
    # Simulate spread observations
    np.random.seed(42)
    base_time = datetime(2024, 1, 15, 14, 0)  # London/NY overlap
    
    for i in range(50):
        spread = np.random.normal(30, 10)
        spread = max(15, spread)
        t = base_time + timedelta(minutes=i)
        analyzer.record_spread(spread, t)
    
    print("\nSession Summary:")
    for session, info in analyzer.get_session_summary().items():
        print(f"  {session}: avg={info['avg_spread']}, samples={info['samples']}")
    
    # Test analysis
    print("\n--- Normal Spread Analysis ---")
    result = analyzer.analyze(
        current_spread=30,
        timestamp=datetime(2024, 1, 15, 14, 30),
        sl_points=50,
        signal_urgency=0.7,
    )
    print(f"  Spread: {result.current_spread}")
    print(f"  Avg: {result.avg_spread:.1f}")
    print(f"  Ratio: {result.spread_ratio:.2f}")
    print(f"  Condition: {result.condition.name}")
    print(f"  Allow Entry: {result.allow_entry}")
    print(f"  Cost in R: {result.cost_in_r:.2f}")
    
    print("\n--- High Spread Analysis ---")
    result2 = analyzer.analyze(
        current_spread=70,
        timestamp=datetime(2024, 1, 15, 14, 30),
        sl_points=50,
        signal_urgency=0.7,
    )
    print(f"  Spread: {result2.current_spread}")
    print(f"  Ratio: {result2.spread_ratio:.2f}")
    print(f"  Condition: {result2.condition.name}")
    print(f"  Allow Entry: {result2.allow_entry}")
    print(f"  Wait for Better: {result2.wait_for_better}")
    print(f"  Reason: {result2.reason}")
