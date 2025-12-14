import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.indicators.footprint_analyzer import FootprintAnalyzer


def test_stack_decay_configurable():
    fp = FootprintAnalyzer(stack_decay_30m=0.6, stack_decay_60m=0.3)
    assert fp.stack_decay_30m == 0.6
    assert fp.stack_decay_60m == 0.3


def test_score_bounds_configurable():
    fp = FootprintAnalyzer(score_floor=30.0, score_cap=90.0)
    # Score calculation uses these bounds; just assert they are set
    assert fp.score_floor == 30.0
    assert fp.score_cap == 90.0
