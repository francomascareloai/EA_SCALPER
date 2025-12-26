from __future__ import annotations

from datetime import datetime, timezone

import pandas as pd

from src.optimization.validation.wfa_inline import InlineWFA


def test_inline_wfa_fails_closed_on_invalid_entry_time_timestamps() -> None:
    trades_df = pd.DataFrame(
        {
            "entry_time": ["bad", datetime(2025, 1, 2, tzinfo=timezone.utc)],
            "timestamp": ["bad", datetime(2025, 1, 2, tzinfo=timezone.utc)],
            "pnl": [10.0, -5.0],
        }
    )

    wfa = InlineWFA(windows=2, is_ratio=0.5, purge_days=0, embargo_days=0)
    splits = wfa.compute_window_splits("2025-01-01", "2025-01-03")

    windows = wfa.analyze_trade_series(trades_df, splits)

    assert windows == []
