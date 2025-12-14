from decimal import Decimal
import random

from nautilus_gold_scalper.src.execution.execution_model import ExecutionModel, ExecutionCosts


def test_execution_model_slippage_and_commission():
    random.seed(42)
    costs = ExecutionCosts(
        base_slippage_cents=Decimal("10"),
        slippage_multiplier=Decimal("1.0"),
        commission_per_lot=Decimal("5.0"),
    )
    model = ExecutionModel(costs)

    price = Decimal("2000.00")
    slipped_buy = model.apply_slippage("buy", price)
    slipped_sell = model.apply_slippage("sell", price)

    assert slipped_buy > price
    assert slipped_sell < price

    commission = model.commission(Decimal("1.5"))
    assert commission == Decimal("7.5")
