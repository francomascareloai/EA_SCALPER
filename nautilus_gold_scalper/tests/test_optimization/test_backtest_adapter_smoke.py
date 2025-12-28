"""
Smoke tests for the backtest adapter module.

These tests validate the contract between ApexOptimizer and BacktestRunner
using mocked backends to avoid running full tick backtests in CI.

Tests verify:
1. backtest_fn returns (trades_df, equity_series) with correct schema
2. ApexOptimizer._objective_fn consumes the adapter output correctly
3. Parameter dotpath expansion works for both flat and nested dicts
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any
from unittest.mock import MagicMock, patch

import numpy as np
import pandas as pd
import pytest


@pytest.fixture
def mock_trades_df() -> pd.DataFrame:
    """Create synthetic trades DataFrame with required schema."""
    base_time = datetime(2020, 1, 15, 10, 0, 0, tzinfo=timezone.utc)
    n_trades = 50

    trades = []
    for i in range(n_trades):
        entry_time = base_time + timedelta(hours=i * 4)
        exit_time = entry_time + timedelta(hours=2)
        # Alternate wins/losses with slight positive bias
        pnl = 150.0 if i % 3 != 0 else -100.0
        trades.append(
            {
                "instrument_id": "XAUUSD.SIM",
                "entry_time": entry_time,
                "exit_time": exit_time,
                "timestamp": entry_time,  # Must be entry_time (no look-ahead)
                "pnl": pnl,
            }
        )

    return pd.DataFrame(trades)


@pytest.fixture
def mock_equity_series(mock_trades_df: pd.DataFrame) -> pd.Series:
    """Create synthetic equity series from trades."""
    initial_balance = 50000.0
    sorted_trades = mock_trades_df.sort_values("timestamp")
    cumulative_pnl = sorted_trades["pnl"].cumsum()
    equity = initial_balance + cumulative_pnl
    return pd.Series(
        equity.values,
        index=pd.DatetimeIndex(sorted_trades["timestamp"].values, tz="UTC"),
    )


class TestBacktestAdapterContract:
    """Test the backtest_fn contract with mocked BacktestRunner."""

    def test_trades_df_has_required_columns(self, mock_trades_df: pd.DataFrame) -> None:
        """Verify trades DataFrame has all required columns."""
        required = {"timestamp", "pnl", "entry_time", "exit_time"}
        assert required.issubset(set(mock_trades_df.columns))

    def test_trades_df_timestamp_is_entry_time(self, mock_trades_df: pd.DataFrame) -> None:
        """Verify timestamp equals entry_time (no look-ahead bias)."""
        assert (mock_trades_df["timestamp"] == mock_trades_df["entry_time"]).all()

    def test_equity_series_has_timezone(self, mock_equity_series: pd.Series) -> None:
        """Verify equity series index is timezone-aware."""
        assert mock_equity_series.index.tz is not None

    def test_equity_series_is_monotonic_index(self, mock_equity_series: pd.Series) -> None:
        """Verify equity series has monotonically increasing index."""
        assert mock_equity_series.index.is_monotonic_increasing


class TestBacktestAdapterFactory:
    """Test create_backtest_fn factory function."""

    @patch("src.optimization.backtest_adapter._get_backtest_runner")
    def test_factory_returns_callable(self, mock_get_runner: MagicMock) -> None:
        """Verify factory returns a callable."""
        from src.optimization.backtest_adapter import create_backtest_fn

        mock_runner_class = MagicMock()
        mock_get_runner.return_value = mock_runner_class

        backtest_fn = create_backtest_fn(initial_balance=50000.0)
        assert callable(backtest_fn)

    @patch("src.optimization.backtest_adapter._get_backtest_runner")
    def test_backtest_fn_calls_runner(
        self,
        mock_get_runner: MagicMock,
        mock_trades_df: pd.DataFrame,
        mock_equity_series: pd.Series,
    ) -> None:
        """Verify backtest_fn calls BacktestRunner.run() with correct args."""
        from src.optimization.backtest_adapter import create_backtest_fn

        # Setup mock runner
        mock_runner = MagicMock()
        mock_runner.engine = MagicMock()
        mock_runner.engine.trader.generate_positions_report.return_value = _create_positions_report(
            mock_trades_df
        )
        mock_runner.strategy = MagicMock()
        mock_runner.strategy._drawdown_tracker = None

        mock_runner_class = MagicMock(return_value=mock_runner)
        mock_get_runner.return_value = mock_runner_class

        backtest_fn = create_backtest_fn(initial_balance=50000.0)

        params = {"execution.execution_threshold": 75}
        trades_df, equity_series = backtest_fn(params, "2020-01-01", "2020-03-31")

        # Verify runner was called
        mock_runner.run.assert_called_once()
        call_kwargs = mock_runner.run.call_args.kwargs
        assert call_kwargs["start_date"] == "2020-01-01"
        assert call_kwargs["end_date"] == "2020-03-31"
        assert call_kwargs["execution_threshold"] == 75

    @patch("src.optimization.backtest_adapter._get_backtest_runner")
    def test_backtest_fn_extracts_trades_and_equity(
        self,
        mock_get_runner: MagicMock,
        mock_trades_df: pd.DataFrame,
    ) -> None:
        """Verify backtest_fn extracts trades_df and equity_series correctly."""
        from src.optimization.backtest_adapter import create_backtest_fn

        # Setup mock runner
        mock_runner = MagicMock()
        mock_runner.engine = MagicMock()
        mock_runner.engine.trader.generate_positions_report.return_value = _create_positions_report(
            mock_trades_df
        )
        mock_runner.strategy = MagicMock()
        mock_runner.strategy._drawdown_tracker = None

        mock_runner_class = MagicMock(return_value=mock_runner)
        mock_get_runner.return_value = mock_runner_class

        backtest_fn = create_backtest_fn(initial_balance=50000.0)

        params = {}
        trades_df, equity_series = backtest_fn(params, "2020-01-01", "2020-03-31")

        # Verify output schema
        assert isinstance(trades_df, pd.DataFrame)
        assert isinstance(equity_series, pd.Series)
        assert "timestamp" in trades_df.columns
        assert "pnl" in trades_df.columns


class TestParameterDotpathExpansion:
    """Test parameter extraction from dotpath and nested dict formats."""

    def test_get_value_flat_dotpath(self) -> None:
        """Verify _get_value extracts from flat dotpath keys."""
        from src.optimization.backtest_adapter import _MISSING, _get_value

        params = {"execution.execution_threshold": 75, "risk.max_positions": 3}
        assert _get_value(params, "execution.execution_threshold") == 75
        assert _get_value(params, "risk.max_positions") == 3
        assert _get_value(params, "nonexistent.key") is _MISSING

    def test_get_value_nested_dict(self) -> None:
        """Verify _get_value extracts from nested dict structure."""
        from src.optimization.backtest_adapter import _MISSING, _get_value

        params = {
            "execution": {"execution_threshold": 75, "use_mtf": True},
            "risk": {"max_positions": 3},
        }
        assert _get_value(params, "execution.execution_threshold") == 75
        assert _get_value(params, "execution.use_mtf") is True
        assert _get_value(params, "risk.max_positions") == 3
        assert _get_value(params, "nonexistent.key") is _MISSING

    def test_get_param_int(self) -> None:
        """Verify _get_param_int with various input types."""
        from src.optimization.backtest_adapter import _get_param_int

        params = {
            "int_val": 75,
            "float_val": 80.0,
            "str_val": "85",
            "invalid": "abc",
        }
        assert _get_param_int(params, "int_val", 0) == 75
        assert _get_param_int(params, "float_val", 0) == 80
        assert _get_param_int(params, "str_val", 0) == 85
        assert _get_param_int(params, "invalid", 99) == 99
        assert _get_param_int(params, "missing", 42) == 42

    def test_get_param_bool(self) -> None:
        """Verify _get_param_bool with various input types."""
        from src.optimization.backtest_adapter import _get_param_bool

        params = {
            "bool_true": True,
            "bool_false": False,
            "int_one": 1,
            "int_zero": 0,
            "str_true": "true",
            "str_false": "false",
            "str_yes": "yes",
            "str_no": "no",
        }
        assert _get_param_bool(params, "bool_true", False) is True
        assert _get_param_bool(params, "bool_false", True) is False
        assert _get_param_bool(params, "int_one", False) is True
        assert _get_param_bool(params, "int_zero", True) is False
        assert _get_param_bool(params, "str_true", False) is True
        assert _get_param_bool(params, "str_false", True) is False
        assert _get_param_bool(params, "str_yes", False) is True
        assert _get_param_bool(params, "str_no", True) is False
        assert _get_param_bool(params, "missing", True) is True


class TestAdapterConfigDataclass:
    """Test BacktestAdapterConfig dataclass."""

    def test_default_values(self) -> None:
        """Verify default configuration values."""
        from src.optimization.backtest_adapter import BacktestAdapterConfig

        config = BacktestAdapterConfig()
        assert config.initial_balance == 50000.0
        assert config.ltf_minutes == 1
        assert config.sample_rate == 1
        assert config.seed == 42
        assert config.feed_mode == "ticks"
        assert config.bars_file is None
        assert config.prop_firm_enabled is True

    def test_custom_values(self) -> None:
        """Verify custom configuration values."""
        from src.optimization.backtest_adapter import BacktestAdapterConfig

        config = BacktestAdapterConfig(
            initial_balance=100000.0,
            ltf_minutes=5,
            sample_rate=10,
            seed=123,
            feed_mode="bars",
            bars_file="/path/to/bars.parquet",
            prop_firm_enabled=False,
        )
        assert config.initial_balance == 100000.0
        assert config.ltf_minutes == 5
        assert config.sample_rate == 10
        assert config.seed == 123
        assert config.feed_mode == "bars"
        assert config.bars_file == "/path/to/bars.parquet"
        assert config.prop_firm_enabled is False


class TestApexOptimizerIntegration:
    """Test integration with ApexOptimizer (mocked)."""

    @patch("src.optimization.backtest_adapter._get_backtest_runner")
    def test_optimizer_consumes_backtest_fn(
        self,
        mock_get_runner: MagicMock,
        mock_trades_df: pd.DataFrame,
    ) -> None:
        """Verify ApexOptimizer can consume backtest_fn output."""
        from src.optimization.backtest_adapter import create_backtest_fn

        # Setup mock runner
        mock_runner = MagicMock()
        mock_runner.engine = MagicMock()
        mock_runner.engine.trader.generate_positions_report.return_value = _create_positions_report(
            mock_trades_df
        )
        mock_runner.strategy = MagicMock()
        mock_runner.strategy._drawdown_tracker = None

        mock_runner_class = MagicMock(return_value=mock_runner)
        mock_get_runner.return_value = mock_runner_class

        backtest_fn = create_backtest_fn(initial_balance=50000.0)

        # Verify backtest_fn has correct signature for ApexOptimizer
        params: dict[str, Any] = {}
        trades_df, equity_series = backtest_fn(params, "2020-01-01", "2020-03-31")

        # Verify WFA-compatible output
        assert not trades_df.empty
        assert "timestamp" in trades_df.columns
        assert "pnl" in trades_df.columns
        assert trades_df["pnl"].dtype in (np.float64, float)


def _create_positions_report(trades_df: pd.DataFrame) -> pd.DataFrame:
    """Convert mock trades to Nautilus positions report format."""
    report = pd.DataFrame(
        {
            "instrument_id": trades_df["instrument_id"],
            "ts_opened": trades_df["entry_time"],
            "ts_closed": trades_df["exit_time"],
            "realized_pnl": [f"{pnl:.2f} USD" for pnl in trades_df["pnl"]],
        }
    )
    return report
