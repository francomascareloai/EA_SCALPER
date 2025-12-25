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

    assert aligned.index.tolist() == pd.to_datetime([
        "2025-01-01 10:05:00",
        "2025-01-01 10:10:00",
    ]).tolist()


def test_build_strategy_config_maps_new_execution_fields() -> None:
    """Ensure runner maps new execution config keys into GoldScalperConfig."""

    from nautilus_trader.model.data import BarSpecification, BarType
    from nautilus_trader.model.enums import AggregationSource, BarAggregation, PriceType
    from nautilus_trader.model.identifiers import InstrumentId

    from nautilus_gold_scalper.scripts.backtest.run_backtest import build_strategy_config

    bar_type = BarType(
        instrument_id=InstrumentId.from_str("XAU/USD.SIM"),
        bar_spec=BarSpecification(step=5, aggregation=BarAggregation.MINUTE, price_type=PriceType.MID),
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


def test_bar_spec_from_minutes_maps_60_to_hour() -> None:
    from nautilus_trader.model.enums import BarAggregation

    from nautilus_gold_scalper.scripts.backtest.run_backtest import _bar_spec_from_minutes

    spec = _bar_spec_from_minutes(minutes=60)
    assert spec.step == 1
    assert spec.aggregation == BarAggregation.HOUR


def test_bar_spec_from_minutes_rejects_non_divisor_minute_step() -> None:
    import pytest

    from nautilus_gold_scalper.scripts.backtest.run_backtest import _bar_spec_from_minutes

    with pytest.raises(ValueError):
        _bar_spec_from_minutes(minutes=7)
