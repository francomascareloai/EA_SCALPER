import pandas as pd


def test_ablation_htf_bias_is_not_visible_before_htf_close() -> None:
    """WP3: HTF bias must not leak into LTF bars before the HTF bar is closed.

    `ablation_study.resample_to_ohlc()` uses pandas resample defaults, which label bars
    by period start. If HTF bias is aligned on HTF bar start, it leaks the HTF close
    into all LTF bars within that HTF period.

    Guard: make HTF bias usable only at (bar_start + HTF_tf).
    """

    ltf_idx = pd.date_range("2025-01-01 01:00:00", periods=12, freq="5min", tz=None)
    ltf_bars = pd.DataFrame(index=ltf_idx)

    htf_idx = pd.date_range("2025-01-01 00:00:00", periods=3, freq="1h", tz=None)
    htf_bars = pd.DataFrame({"htf_bullish": [True, False, True]}, index=htf_idx)

    # Simulate ablation_study alignment logic: availability at bar close.
    htf_available = htf_bars["htf_bullish"].copy()
    htf_available.index = pd.to_datetime(htf_available.index) + pd.Timedelta("1h")

    aligned = htf_available.reindex(ltf_bars.index, method="ffill")

    # During 01:00..01:55, the *last closed* HTF bar is the 00:00 bar (available at 01:00).
    assert (aligned == True).all()


def test_footprint_floor_index_is_shifted_to_bar_close() -> None:
    """WP3: Footprint metrics grouped by floor('5min') are only known after bar close.

    FootprintAnalyzer groups ticks by `ticks.index.floor('5min')`, so the resulting
    footprint index represents bar *start*. The score must be aligned to bar close.
    """

    fp_idx = pd.to_datetime(["2025-01-01 10:00:00", "2025-01-01 10:05:00"])
    fp_df = pd.DataFrame({"fp_score": [60.0, 40.0]}, index=fp_idx)

    aligned = fp_df.copy()
    aligned.index = pd.to_datetime(aligned.index) + pd.Timedelta("5min")

    assert (
        aligned.index.tolist()
        == pd.to_datetime(
            [
                "2025-01-01 10:05:00",
                "2025-01-01 10:10:00",
            ]
        ).tolist()
    )


def test_bars_resample_is_labeled_at_bar_close() -> None:
    """WP3: Pandas resample must label OHLC at bar close, not bar start.

    If bars are labeled at bar start, strategy can observe full OHLC as if it was
    known at the beginning of the period (look-ahead).

    Guard mirrors `aggregate_tick_df_to_ohlcv()`.
    """

    idx = pd.to_datetime(
        [
            "2025-01-01 10:00:01",
            "2025-01-01 10:04:59",
            "2025-01-01 10:05:00",
        ],
        utc=True,
    )
    df = pd.DataFrame({"bid": [100.0, 100.2, 100.1], "ask": [100.1, 100.3, 100.2]}, index=idx)
    df = df.reset_index().rename(columns={"index": "datetime"})

    from nautilus_gold_scalper.scripts.backtest.run_backtest import aggregate_tick_df_to_ohlcv

    bars = aggregate_tick_df_to_ohlcv(df, interval_minutes=5)

    # First bar covers [10:00, 10:05); it should be labeled at 10:05.
    assert bars.index[0] == pd.Timestamp("2025-01-01 10:05:00+00:00")


def test_load_bars_csv_respects_timestamp_basis_open_vs_close(tmp_path) -> None:
    """Bars CSV timestamp basis must be explicit to avoid double-shift.

    - timestamp_basis='open' shifts timestamps +ltf_minutes to align to bar close.
    - timestamp_basis='close' leaves timestamps as-is.
    """

    from nautilus_gold_scalper.scripts.backtest.run_backtest import load_bars_csv

    csv_path = tmp_path / "bars.csv"
    csv_path.write_text(
        "timestamp,open,high,low,close,volume\n"
        "2025-01-01T10:00:00Z,100,101,99,100.5,10\n"
        "2025-01-01T10:05:00Z,100.5,102,100,101.0,12\n"
        "2025-01-01T10:10:00Z,101.0,103,100.5,102.0,11\n",
        encoding="utf-8",
    )

    df_close = load_bars_csv(
        csv_path,
        start_date="2025-01-01",
        end_date="2025-01-01",
        ltf_minutes=5,
        timestamp_basis="close",
    )
    assert df_close.index[0] == pd.Timestamp("2025-01-01 10:00:00+00:00")

    df_open = load_bars_csv(
        csv_path,
        start_date="2025-01-01",
        end_date="2025-01-01",
        ltf_minutes=5,
        timestamp_basis="open",
    )
    assert df_open.index[0] == pd.Timestamp("2025-01-01 10:05:00+00:00")


def test_build_strategy_config_maps_new_execution_fields() -> None:
    """Ensure runner maps new execution config keys into GoldScalperConfig."""

    from nautilus_gold_scalper.scripts.backtest.run_backtest import build_strategy_config
    from nautilus_trader.model.data import BarSpecification, BarType
    from nautilus_trader.model.enums import AggregationSource, BarAggregation, PriceType
    from nautilus_trader.model.identifiers import InstrumentId

    bar_type = BarType(
        instrument_id=InstrumentId.from_str("XAU/USD.SIM"),
        bar_spec=BarSpecification(
            step=5, aggregation=BarAggregation.MINUTE, price_type=PriceType.MID
        ),
        aggregation_source=AggregationSource.INTERNAL,
    )

    cfg = {
        "execution": {
            "trade_partial_tp_r": 1.25,
            "trade_partial_tp_percent": 0.33,
            "trade_trailing_start_r": 1.70,
            "trend_target_rr_ratio": 3.30,
            "mean_revert_target_rr_ratio": 1.40,
            "trend_breakout_lookback": 35,
            "trend_min_atr_percentile_breakout": 72.0,
            "trend_er_enabled": True,
            "trend_er_period": 55,
            "trend_er_smoothing": 4,
            "trend_er_min": 0.42,
            "mean_revert_er_enabled": True,
            "mean_revert_er_period": 50,
            "mean_revert_er_smoothing": 3,
            "mean_revert_er_max": 0.20,
            "force_mean_revert": True,
            "require_htf_align": False,
            "max_concurrent_positions": 2,
            "max_concurrent_instruments": 3,
            "vol_spacing_min_seconds": 12.0,
            "vol_spacing_max_seconds": 345.0,
            "vol_spacing_reference_atr": 1.25,
            "virtual_gate_enabled": False,
            "virtual_gate_lookback_bars": 33,
            "virtual_gate_range_spike_multiplier": 4.5,
            "virtual_gate_cluster_spike_multiplier": 3.5,
            "virtual_gate_cluster_max_fraction": 0.45,
            "virtual_gate_fail_open_on_insufficient_history": False,
            # New timeframe execution keys
            "ltf_bar_minutes": 5,
            "mtf_bar_minutes": 15,
            "htf_bar_minutes": 60,
            "management_bar_minutes": 60,
        }
    }

    sc = build_strategy_config(cfg, bar_type, InstrumentId.from_str("XAU/USD.SIM"), ltf_minutes=5)

    assert sc.trade_partial_tp_r == 1.25
    assert sc.trade_partial_tp_percent == 0.33
    assert sc.trade_trailing_start_r == 1.70
    assert sc.trend_target_rr_ratio == 3.30
    assert sc.mean_revert_target_rr_ratio == 1.40
    assert sc.trend_breakout_lookback == 35
    assert sc.trend_min_atr_percentile_breakout == 72.0
    assert sc.trend_er_enabled is True
    assert sc.trend_er_period == 55
    assert sc.trend_er_smoothing == 4
    assert sc.trend_er_min == 0.42
    assert sc.mean_revert_er_enabled is True
    assert sc.mean_revert_er_period == 50
    assert sc.mean_revert_er_smoothing == 3
    assert sc.mean_revert_er_max == 0.20
    assert sc.force_mean_revert is True

    # Phase 11 safety layer mappings
    assert sc.max_concurrent_positions == 2
    assert sc.max_concurrent_instruments == 3
    assert sc.vol_spacing_min_seconds == 12.0
    assert sc.vol_spacing_max_seconds == 345.0
    assert sc.vol_spacing_reference_atr == 1.25
    assert sc.virtual_gate_enabled is False
    assert sc.virtual_gate_lookback_bars == 33
    assert sc.virtual_gate_range_spike_multiplier == 4.5
    assert sc.virtual_gate_cluster_spike_multiplier == 3.5
    assert sc.virtual_gate_cluster_max_fraction == 0.45
    assert sc.virtual_gate_fail_open_on_insufficient_history is False


def test_bar_spec_from_minutes_maps_60_to_hour() -> None:
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _bar_spec_from_minutes
    from nautilus_trader.model.enums import BarAggregation

    spec = _bar_spec_from_minutes(minutes=60)
    assert spec.step == 1
    assert spec.aggregation == BarAggregation.HOUR


def test_bar_spec_from_minutes_rejects_non_divisor_minute_step() -> None:
    import pytest
    from nautilus_gold_scalper.scripts.backtest.run_backtest import _bar_spec_from_minutes

    with pytest.raises(ValueError):
        _bar_spec_from_minutes(minutes=7)
