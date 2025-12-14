"""
EA_SCALPER_XAUUSD - Backtest Strategy Modules
==============================================
P1 Enhanced (2025-12-01)

Modules:
- ea_logic_full: Main EA logic port from MQL5
- ea_logic_python: Simplified Python implementation
- ea_logic_compat: Compatibility layer
- fibonacci_analyzer: Fibonacci Golden Pocket + Extensions (NEW)
- adaptive_kelly: DD-responsive position sizing (NEW)
- spread_analyzer: Smart spread awareness (NEW)
"""

from .ea_logic_full import (
    EALogicFull,
    create_ea_logic,
    RegimeDetector,
    SessionFilter,
    MTFManager,
    ConfluenceScorer,
    LiquiditySweepDetector,
    RiskManager,
    SignalType,
    MarketRegime,
    SignalQuality,
)

from .fibonacci_analyzer import (
    FibonacciAnalyzer,
    create_fibonacci_analyzer,
    FibonacciLevels,
    FibAnalysisResult,
    FibCluster,
)

from .adaptive_kelly import (
    AdaptiveKelly,
    create_adaptive_kelly,
    KellyMode,
    KellySizingResult,
    TradeStats,
)

from .spread_analyzer import (
    SpreadAnalyzer,
    create_spread_analyzer,
    SpreadCondition,
    SpreadAnalysisResult,
)

__all__ = [
    # Main EA
    "EALogicFull",
    "create_ea_logic",
    "RegimeDetector",
    "SessionFilter",
    "MTFManager",
    "ConfluenceScorer",
    "LiquiditySweepDetector",
    "RiskManager",
    "SignalType",
    "MarketRegime",
    "SignalQuality",
    # P1 Enhancements
    "FibonacciAnalyzer",
    "create_fibonacci_analyzer",
    "FibonacciLevels",
    "FibAnalysisResult",
    "AdaptiveKelly",
    "create_adaptive_kelly",
    "KellyMode",
    "KellySizingResult",
    "SpreadAnalyzer",
    "create_spread_analyzer",
    "SpreadCondition",
    "SpreadAnalysisResult",
]
