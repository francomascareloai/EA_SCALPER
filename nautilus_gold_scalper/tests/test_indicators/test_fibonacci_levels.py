import math
import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.indicators.structure_analyzer import (
    StructureAnalyzer,
    SwingPoint,
    MarketBias,
)
from nautilus_gold_scalper.src.signals.confluence_scorer import ConfluenceScorer
from nautilus_gold_scalper.src.core.data_types import OrderBlock, ConfluenceResult
from nautilus_gold_scalper.src.core.definitions import (
    SignalType,
    TradingSession,
    WEIGHT_FIB,
)


def test_calculates_golden_pocket_and_extensions():
    analyzer = StructureAnalyzer()
    analyzer._state.last_high = SwingPoint(price=110.0, is_high=True)
    analyzer._state.last_low = SwingPoint(price=100.0, is_high=False)
    analyzer._state.bias = MarketBias.BULLISH

    analyzer._calculate_fibonacci_levels(current_price=103.75)

    fib = analyzer._state.fibonacci
    assert fib is not None
    assert fib.in_golden_pocket is True
    assert math.isclose(fib.golden_low, 110 - 10 * 0.65, rel_tol=1e-4)
    assert math.isclose(fib.golden_high, 110 - 10 * 0.618, rel_tol=1e-4)
    assert math.isclose(fib.ext_1618, 110 + 10 * 0.618, rel_tol=1e-4)


def test_confluence_scores_fibonacci_overlap():
    # Setup a fibonacci pocket around current price
    analyzer = StructureAnalyzer()
    analyzer._state.last_high = SwingPoint(price=110.0, is_high=True)
    analyzer._state.last_low = SwingPoint(price=100.0, is_high=False)
    analyzer._state.bias = MarketBias.BULLISH
    analyzer._calculate_fibonacci_levels(current_price=103.7)
    state = analyzer._state

    # OB covering the pocket for extra bonus
    ob = OrderBlock(
        high_price=104.0,
        low_price=103.0,
        direction=SignalType.SIGNAL_BUY,
        is_valid=True,
    )

    scorer = ConfluenceScorer(min_score_to_trade=0)
    result: ConfluenceResult = scorer.calculate_score(
        structure_state=state,
        regime_analysis=None,
        session_info=None,
        order_blocks=[ob],
        fvgs=None,
        sweeps=None,
        amd_cycle=None,
        mtf_score=0.0,
        mtf_aligned=False,
        footprint_score=0.0,
        footprint_direction=SignalType.SIGNAL_NONE,
        current_price=103.7,
        current_session=TradingSession.SESSION_LONDON,
    )

    # Expect a fib score capped by weight and reflected in result
    assert result.fib_score <= WEIGHT_FIB
    assert result.fib_score > 0
    assert result.total_score > 0
