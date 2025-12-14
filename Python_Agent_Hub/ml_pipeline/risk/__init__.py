"""
Risk Management Modules for EA_SCALPER_XAUUSD
- R-Multiple Tracker (Van Tharp)
- Risk of Ruin Calculator (Ralph Vince)
- Position Sizing (Kelly, Optimal f)
"""
from .r_multiple_tracker import RMultipleTracker, Trade, RMultipleStats
from .risk_of_ruin import RiskOfRuinCalculator, RiskOfRuinResult

__all__ = [
    'RMultipleTracker',
    'Trade',
    'RMultipleStats',
    'RiskOfRuinCalculator',
    'RiskOfRuinResult'
]
