"""Technical indicators for Gold Scalper."""

from .structure_analyzer import (
    StructureAnalyzer,
    StructureState,
    StructurePointType,
    MarketBias,
    BreakType,
    SwingPoint,
    StructureBreak,
)
from .session_filter import SessionFilter
from .regime_detector import RegimeDetector

# Footprint module ainda nao migrado; import protegido para evitar falhas.
try:
    from .footprint_analyzer import (
        FootprintAnalyzer,
        FootprintState,
        FootprintLevel,
        StackedImbalance,
        AbsorptionZone,
        ValueArea,
        AuctionType,
        FootprintSimulator,
    )
except ImportError:  # pragma: no cover - modulo ausente em alguns estagios da migracao
    FootprintAnalyzer = None  # type: ignore
    FootprintState = None  # type: ignore
    FootprintLevel = None  # type: ignore
    StackedImbalance = None  # type: ignore
    AbsorptionZone = None  # type: ignore
    ValueArea = None  # type: ignore
    AuctionType = None  # type: ignore
    FootprintSimulator = None  # type: ignore

# STREAM C: SMC Components (migrated from MQL5)
from .order_block_detector import OrderBlockDetector
from .fvg_detector import FVGDetector
from .liquidity_sweep import LiquiditySweepDetector
from .amd_cycle_tracker import AMDCycleTracker

__all__ = [
    # Structure analysis
    'StructureAnalyzer',
    'StructureState',
    'StructurePointType',
    'MarketBias',
    'BreakType',
    'SwingPoint',
    'StructureBreak',
    # Session and regime
    'SessionFilter',
    'RegimeDetector',
    # Footprint (optional)
    'FootprintAnalyzer',
    'FootprintState',
    'FootprintLevel',
    'StackedImbalance',
    'AbsorptionZone',
    'ValueArea',
    'AuctionType',
    'FootprintSimulator',
    # SMC components (STREAM C)
    'OrderBlockDetector',
    'FVGDetector',
    'LiquiditySweepDetector',
    'AMDCycleTracker',
]
