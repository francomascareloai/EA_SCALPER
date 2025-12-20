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
