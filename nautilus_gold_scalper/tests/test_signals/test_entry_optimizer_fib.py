import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.signals.entry_optimizer import (
    EntryOptimizer,
    EntryType,
    SignalDirection,
)


def test_entry_optimizer_uses_golden_pocket_and_fib_targets():
    optimizer = EntryOptimizer()
    golden_pocket = (1995.0, 1997.0)
    fib_targets = (2005.0, 2010.0, 2015.0)

    entry = optimizer.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=0.0,
        fvg_high=0.0,
        ob_low=0.0,
        ob_high=0.0,
        sweep_level=0.0,
        current_price=1996.0,
        atr=5.0,
        golden_pocket=golden_pocket,
        fib_targets=fib_targets,
    )

    assert entry.entry_type == EntryType.ENTRY_FIB_RETRACE
    assert entry.is_valid
    # Fib targets should override ladder
    assert entry.take_profit_1 >= fib_targets[0]
    assert entry.take_profit_2 >= fib_targets[1]
    assert entry.take_profit_3 >= fib_targets[2]


def test_spread_blocks_low_urgency_entries():
    optimizer = EntryOptimizer()
    entry = optimizer.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        current_price=2000.0,
        atr=5.0,
        spread_ratio=2.0,
        signal_urgency=0.5,
    )

    assert entry.is_valid is False
    assert entry.zone_type == "SPREAD_BLOCK"
