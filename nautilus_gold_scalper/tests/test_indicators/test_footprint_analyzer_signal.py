import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.indicators.footprint_analyzer import FootprintAnalyzer, FootprintSignal


def test_footprint_strong_buy_from_stacked_and_absorption():
    fp = FootprintAnalyzer(imbalance_ratio=2.5, stacked_min=3)
    # Craft synthetic tick data with strong buy imbalances and absorption
    tick_data = []
    price = 2000.0
    # Three stacked levels with heavy buy imbalance
    for i in range(3):
        tick_data.append((price + i * 0.5, 300, True))   # big ask volume
        tick_data.append((price + i * 0.5, 50, False))   # small bid volume
    # Absorption: high volume, low delta at level near high
    tick_data.append((price + 1.0, 400, False))
    tick_data.append((price + 1.0, 380, True))

    state = fp.analyze_bar(
        high=2002.0,
        low=1999.0,
        open_price=1999.5,
        close=2001.5,
        volume=2000,
        tick_data=tick_data,
    )

    assert state.signal == FootprintSignal.FP_SIGNAL_BUY
    assert state.score > 55
