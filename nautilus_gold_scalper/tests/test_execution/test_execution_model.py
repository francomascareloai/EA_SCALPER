import random
from decimal import Decimal

from nautilus_gold_scalper.src.execution.execution_model import ExecutionCosts, ExecutionModel


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


def test_execution_model_tick_slippage_applies_when_tick_size_provided():
    random.seed(42)

    costs = ExecutionCosts(
        base_slippage_cents=Decimal("0"),
        slippage_multiplier=Decimal("0"),
        commission_per_lot=Decimal("5.0"),
    )
    model = ExecutionModel(costs)
    model.realism.slippage_ticks = 3

    price = Decimal("2000.00")
    tick_size = Decimal("0.10")

    slipped_buy = model.apply_slippage("buy", price, tick_size=tick_size)
    slipped_sell = model.apply_slippage("sell", price, tick_size=tick_size)

    assert slipped_buy == price + Decimal("0.30")
    assert slipped_sell == price - Decimal("0.30")
