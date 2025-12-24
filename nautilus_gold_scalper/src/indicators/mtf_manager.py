"""Deprecated import path for multi-timeframe analysis.

.. deprecated:: 2025-12-23
    Use ``nautilus_gold_scalper.src.signals.mtf_manager`` (SMC-based) instead.

This module remains as a compatibility shim so existing imports keep working,
but it no longer provides the legacy EMA-based implementation.
"""

from __future__ import annotations

import warnings

# Emit deprecation warning on import
warnings.warn(
    "nautilus_gold_scalper.src.indicators.mtf_manager is deprecated. "
    "Use nautilus_gold_scalper.src.signals.mtf_manager instead.",
    DeprecationWarning,
    stacklevel=2,
)

from ..signals.mtf_manager import (  # noqa: E402
    MTFManager,
    MTFState,
    Timeframe,
    TimeframeAnalysis,
)

__all__ = [
    "MTFManager",
    "MTFState",
    "Timeframe",
    "TimeframeAnalysis",
]
