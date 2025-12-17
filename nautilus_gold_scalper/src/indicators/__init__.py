"""Technical indicators for Gold Scalper."""

from .regime_detector import RegimeDetector
from .session_filter import SessionFilter
from .structure_analyzer import (
    BreakType,
    MarketBias,
    StructureAnalyzer,
    StructureBreak,
    StructurePointType,
    StructureState,
    SwingPoint,
)

# Footprint module ainda nao migrado; import protegido para evitar falhas.
try:
    from .footprint_analyzer import (
        AbsorptionZone,
        AuctionType,
        FootprintAnalyzer,
        FootprintLevel,
        FootprintSimulator,
        FootprintState,
        StackedImbalance,
        ValueArea,
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
from .amd_cycle_tracker import AMDCycleTracker
from .fvg_detector import FVGDetector
from .liquidity_sweep import LiquiditySweepDetector
from .order_block_detector import OrderBlockDetector

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
