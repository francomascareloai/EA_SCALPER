from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any

import pandas as pd
from nautilus_gold_scalper.src.optimization.backtest_adapter import _extract_equity_series


@dataclass(frozen=True)
class _Snap:
    timestamp: datetime
    equity: float


class _DrawdownTracker:
    def __init__(self, history: list[_Snap]) -> None:
        self._history = history

    def get_history(self) -> list[_Snap]:
        return list(self._history)


class _Strategy:
    def __init__(self, history: list[_Snap] | None) -> None:
        self._drawdown_tracker = _DrawdownTracker(history or [])


class _Runner:
    def __init__(self, history: list[_Snap] | None, *, with_engine: bool = True) -> None:
        self.engine = object() if with_engine else None
        self.strategy = _Strategy(history) if history is not None else object()


def test_extract_equity_series_keeps_duplicate_timestamps() -> None:
    t = datetime(2025, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
    history = [
        _Snap(timestamp=t, equity=100_000.0),
        _Snap(timestamp=t, equity=102_000.0),
        _Snap(timestamp=t, equity=99_000.0),
    ]

    s = _extract_equity_series(_Runner(history), initial_balance=100_000.0)

    assert isinstance(s.index, pd.DatetimeIndex)
    assert s.index.tz is not None
    assert len(s) == 3
    assert s.index.duplicated().any()
    assert list(s.values) == [100_000.0, 102_000.0, 99_000.0]


def test_extract_equity_series_fails_closed_on_invalid_timestamps() -> None:
    t = datetime(2025, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
    history: list[Any] = [
        _Snap(timestamp=t, equity=100_000.0),
        {"timestamp": None, "equity": 99_000.0},
        _Snap(timestamp=t, equity=101_000.0),
    ]

    s = _extract_equity_series(_Runner(history), initial_balance=100_000.0)

    assert isinstance(s, pd.Series)
    assert s.name == "equity"
    assert len(s) == 0


def test_extract_equity_series_returns_empty_without_engine() -> None:
    t = datetime(2025, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
    history = [_Snap(timestamp=t, equity=100_000.0), _Snap(timestamp=t, equity=99_000.0)]

    s = _extract_equity_series(_Runner(history, with_engine=False), initial_balance=100_000.0)

    assert isinstance(s, pd.Series)
    assert len(s) == 0


def test_extract_equity_series_returns_empty_without_drawdown_tracker() -> None:
    runner: Any = _Runner(None)
    runner.engine = object()

    s = _extract_equity_series(runner, initial_balance=100_000.0)

    assert isinstance(s, pd.Series)
    assert s.name == "equity"
    assert len(s) == 0
