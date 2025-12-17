"""
ExecutionModel
Applies slippage and commission for realistic fills.
"""
from __future__ import annotations

import random
from dataclasses import dataclass
from decimal import Decimal


@dataclass
class ExecutionCosts:
    base_slippage_cents: Decimal = Decimal("10")  # 10 cents default
    slippage_multiplier: Decimal = Decimal("1.5")
    commission_per_lot: Decimal = Decimal("5.0")


class ExecutionModel:
    def __init__(self, costs: ExecutionCosts):
        self.costs = costs

    def apply_slippage(self, side: str, current_price: Decimal, volatility: Decimal | None = None) -> Decimal:
        """
        Apply volatility-adjusted slippage (XAUUSD cents).
        """
        vol_factor = Decimal("1.0")
        if volatility is not None and volatility > 0:
            vol_factor = min(volatility / Decimal("0.5"), Decimal("3.0"))

        slip_cents = self.costs.base_slippage_cents * self.costs.slippage_multiplier * vol_factor
        slip = slip_cents / Decimal("100")  # convert cents to dollars

        jitter = Decimal(str(random.uniform(0.5, 1.5)))
        slip *= jitter

        if side.lower() == "buy":
            return current_price + slip
        return current_price - slip

    def commission(self, lots: Decimal) -> Decimal:
        return self.costs.commission_per_lot * lots
