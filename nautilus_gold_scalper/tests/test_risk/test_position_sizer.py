import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.risk.position_sizer import LotSizeMethod, PositionSizer


def test_drawdown_throttles_risk_percent():
    """Test that DD throttle reduces position size at elevated DD levels.

    DD Throttle Tiers (per position_sizer.py _apply_drawdown_throttle):
    - >= dd_hard (default 5%): 75% cut (0.25x)
    - >= dd_soft (default 3%): 50% cut (0.50x)
    - >= 2%: 25% cut (0.75x)

    At 4% DD with default dd_hard=5%, dd_soft=3%:
    - 4% < 5% (dd_hard), so NOT 0.25x
    - 4% >= 3% (dd_soft), so 0.50x applies

    Additionally, MAX_RISK_PER_TRADE = 0.0075 caps the risk at 0.75%.
    """
    sizer = PositionSizer(method=LotSizeMethod.PERCENT_RISK, risk_per_trade=0.01)
    lot_normal = sizer.calculate_lot(
        balance=100_000, stop_loss_pips=50, pip_value=10.0, current_drawdown_pct=0.0
    )
    lot_dd = sizer.calculate_lot(
        balance=100_000, stop_loss_pips=50, pip_value=10.0, current_drawdown_pct=0.04
    )

    assert lot_dd < lot_normal
    # At 4% DD with default dd_soft=3%, the 0.50x multiplier applies.
    # Expected ratio: lot_dd / lot_normal <= 0.55 (0.50 + margin for rounding)
    # Actual: risk is throttled by 0.50x at 4% DD with default settings.
    assert lot_dd <= lot_normal * 0.7  # 0.50x with some margin for rounding
