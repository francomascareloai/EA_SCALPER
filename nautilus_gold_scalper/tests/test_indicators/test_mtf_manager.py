"""Compatibility tests for deprecated indicators.mtf_manager import path.

The production MTF manager is SMC-based and lives in ``src.signals.mtf_manager``.
The legacy EMA-based implementation was removed; ``src.indicators.mtf_manager``
remains as a shim which re-exports the production implementation.
"""

import pytest


def test_indicators_mtf_manager_is_deprecated_shim() -> None:
    with pytest.warns(DeprecationWarning):
        from src.indicators import mtf_manager as deprecated

    from src.signals import mtf_manager as signals

    assert deprecated.MTFManager is signals.MTFManager
    assert deprecated.MTFState is signals.MTFState
    assert deprecated.Timeframe is signals.Timeframe
    assert deprecated.TimeframeAnalysis is signals.TimeframeAnalysis
