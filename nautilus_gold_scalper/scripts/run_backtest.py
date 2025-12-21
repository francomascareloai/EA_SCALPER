"""Compatibility wrapper for test imports.

Tests import `scripts.run_backtest`, but the actual implementation lives in
`scripts/backtest/run_backtest.py`.
"""

from __future__ import annotations

from .backtest.run_backtest import BacktestRunner, create_mgc_instrument, create_xauusd_instrument

__all__ = [
    "BacktestRunner",
    "create_mgc_instrument",
    "create_xauusd_instrument",
]
