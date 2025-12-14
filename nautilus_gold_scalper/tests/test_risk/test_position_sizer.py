import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.risk.position_sizer import PositionSizer, LotSizeMethod


def test_drawdown_throttles_risk_percent():
    sizer = PositionSizer(method=LotSizeMethod.PERCENT_RISK, risk_per_trade=0.01)
    lot_normal = sizer.calculate_lot(
        balance=100_000, stop_loss_pips=50, pip_value=10.0, current_drawdown_pct=0.0
    )
    lot_dd = sizer.calculate_lot(
        balance=100_000, stop_loss_pips=50, pip_value=10.0, current_drawdown_pct=0.04
    )

    assert lot_dd < lot_normal
    # 4% DD should cut risk at least by half
    assert lot_dd <= lot_normal * 0.6
