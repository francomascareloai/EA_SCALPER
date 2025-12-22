"""
ExecutionModel
Applies slippage, latency, rejection, and partial fill modeling for realistic fills.

Execution Realism Parameters
----------------------------
The ExecutionModel supports the following parameters for realistic backtest simulation:

1. **latency_ms** (float, default=50.0):
   Simulated execution latency in milliseconds. Represents the delay between
   order submission and fill. In backtests, this affects the price at which
   orders are filled (price may move during latency period).

2. **reject_probability** (float, default=0.0, range 0-1):
   Probability that an order is rejected by the exchange/broker. Common causes
   in live trading: insufficient margin, market closed, invalid price, etc.
   A value of 0.05 means 5% of orders will be rejected.

3. **partial_fill_probability** (float, default=0.0, range 0-1):
   Probability that an order receives a partial fill instead of full fill.
   Simulates liquidity constraints. When triggered, only a portion (typically
   50-90%) of the order is filled, and the remainder may need re-submission.

4. **slippage_ticks** (int, default=0):
   Fixed adverse slippage in ticks (price increments). This is IN ADDITION to
   the volatility-adjusted slippage from ExecutionCosts. Represents worst-case
   market impact or spread widening during execution.

Usage in Backtest
-----------------
These parameters allow stress-testing strategies under realistic conditions:
- Conservative: latency_ms=50, reject_prob=0.01, partial_fill=0.05, slippage=1
- Aggressive:   latency_ms=150, reject_prob=0.05, partial_fill=0.15, slippage=3

The actual fill simulation logic may reside in the backtest engine (e.g.,
NautilusTrader's FillModel). These parameters are exposed for configuration
and can be passed to the fill model during backtest setup.
"""
from __future__ import annotations

import random
from dataclasses import dataclass, field
from decimal import Decimal
from typing import Any


@dataclass
class ExecutionCosts:
    """Cost parameters for execution simulation."""

    base_slippage_cents: Decimal = Decimal("10")  # 10 cents default
    slippage_multiplier: Decimal = Decimal("1.5")
    commission_per_lot: Decimal = Decimal("5.0")


@dataclass
class ExecutionRealism:
    """
    Parameters for realistic order execution modeling.

    These parameters simulate real-world execution imperfections:
    - Latency between order and fill
    - Order rejections
    - Partial fills due to liquidity
    - Fixed adverse slippage (tick-based)
    """

    latency_ms: float = 50.0
    """Simulated execution latency in milliseconds (default: 50ms)."""

    reject_probability: float = 0.0
    """Probability of order rejection, range [0, 1] (default: 0.0 = no rejections)."""

    partial_fill_probability: float = 0.0
    """Probability of partial fill, range [0, 1] (default: 0.0 = always full fills)."""

    slippage_ticks: int = 0
    """Fixed adverse slippage in ticks/price increments (default: 0)."""

    def __post_init__(self) -> None:
        """Validate parameter ranges."""
        if self.latency_ms < 0:
            raise ValueError(f"latency_ms must be >= 0, got {self.latency_ms}")
        if not 0 <= self.reject_probability <= 1:
            raise ValueError(
                f"reject_probability must be in [0, 1], got {self.reject_probability}"
            )
        if not 0 <= self.partial_fill_probability <= 1:
            raise ValueError(
                f"partial_fill_probability must be in [0, 1], got {self.partial_fill_probability}"
            )
        if self.slippage_ticks < 0:
            raise ValueError(f"slippage_ticks must be >= 0, got {self.slippage_ticks}")

    def to_dict(self) -> dict[str, Any]:
        """Export parameters as dict for backtest configuration."""
        return {
            "latency_ms": self.latency_ms,
            "reject_probability": self.reject_probability,
            "partial_fill_probability": self.partial_fill_probability,
            "slippage_ticks": self.slippage_ticks,
        }

    @classmethod
    def conservative(cls) -> "ExecutionRealism":
        """Factory for conservative (realistic but not pessimistic) settings."""
        return cls(
            latency_ms=50.0,
            reject_probability=0.01,
            partial_fill_probability=0.05,
            slippage_ticks=1,
        )

    @classmethod
    def aggressive(cls) -> "ExecutionRealism":
        """Factory for aggressive (stress-test) settings."""
        return cls(
            latency_ms=150.0,
            reject_probability=0.05,
            partial_fill_probability=0.15,
            slippage_ticks=3,
        )

    @classmethod
    def ideal(cls) -> "ExecutionRealism":
        """Factory for ideal (no imperfections) settings - for baseline comparison."""
        return cls(
            latency_ms=0.0,
            reject_probability=0.0,
            partial_fill_probability=0.0,
            slippage_ticks=0,
        )


class ExecutionModel:
    """
    Execution model with cost and realism parameters.

    Combines ExecutionCosts (slippage, commission) with ExecutionRealism
    (latency, rejects, partial fills) for comprehensive fill simulation.
    """

    def __init__(
        self,
        costs: ExecutionCosts,
        realism: ExecutionRealism | None = None,
    ) -> None:
        """
        Initialize ExecutionModel.

        Args:
            costs: Cost parameters (slippage, commission)
            realism: Realism parameters (latency, rejects, partials).
                     Defaults to ExecutionRealism() if not provided.
        """
        self.costs = costs
        self.realism = realism if realism is not None else ExecutionRealism()

    # -------------------------------------------------------------------------
    # Properties to expose realism parameters for backtest configuration
    # -------------------------------------------------------------------------

    @property
    def latency_ms(self) -> float:
        """Simulated execution latency in milliseconds."""
        return self.realism.latency_ms

    @property
    def reject_probability(self) -> float:
        """Probability of order rejection [0, 1]."""
        return self.realism.reject_probability

    @property
    def partial_fill_probability(self) -> float:
        """Probability of partial fill [0, 1]."""
        return self.realism.partial_fill_probability

    @property
    def slippage_ticks(self) -> int:
        """Fixed adverse slippage in ticks."""
        return self.realism.slippage_ticks

    # -------------------------------------------------------------------------
    # Fill simulation methods
    # -------------------------------------------------------------------------

    def should_reject(self) -> bool:
        """
        Determine if an order should be rejected based on reject_probability.

        Returns:
            True if order should be rejected, False otherwise.
        """
        if self.realism.reject_probability <= 0:
            return False
        return random.random() < self.realism.reject_probability

    def get_fill_ratio(self) -> float:
        """
        Determine fill ratio based on partial_fill_probability.

        Returns:
            Fill ratio in range (0.5, 1.0]. Returns 1.0 for full fill,
            or a random value in (0.5, 0.9] for partial fill.
        """
        if self.realism.partial_fill_probability <= 0:
            return 1.0
        if random.random() < self.realism.partial_fill_probability:
            # Partial fill: between 50% and 90%
            return random.uniform(0.5, 0.9)
        return 1.0

    def apply_slippage(
        self,
        side: str,
        current_price: Decimal,
        volatility: Decimal | None = None,
        tick_size: Decimal | None = None,
    ) -> Decimal:
        """
        Apply volatility-adjusted slippage plus fixed tick slippage.

        Args:
            side: "buy" or "sell"
            current_price: Current market price
            volatility: Optional volatility factor for dynamic slippage
            tick_size: Price increment for tick-based slippage (e.g., 0.01 for XAUUSD)

        Returns:
            Adjusted price after slippage (adverse to trader).
        """
        # Volatility-adjusted slippage (existing logic)
        vol_factor = Decimal("1.0")
        if volatility is not None and volatility > 0:
            vol_factor = min(volatility / Decimal("0.5"), Decimal("3.0"))

        slip_cents = (
            self.costs.base_slippage_cents * self.costs.slippage_multiplier * vol_factor
        )
        slip = slip_cents / Decimal("100")  # convert cents to dollars

        jitter = Decimal(str(random.uniform(0.5, 1.5)))
        slip *= jitter

        # Add fixed tick slippage if tick_size provided
        if tick_size is not None and self.realism.slippage_ticks > 0:
            tick_slip = tick_size * Decimal(self.realism.slippage_ticks)
            slip += tick_slip

        # Apply adverse to trader (buy = higher price, sell = lower price)
        if side.lower() == "buy":
            return current_price + slip
        return current_price - slip

    def commission(self, lots: Decimal) -> Decimal:
        """Calculate commission for given lot size."""
        return self.costs.commission_per_lot * lots

    # -------------------------------------------------------------------------
    # Configuration export
    # -------------------------------------------------------------------------

    def to_config_dict(self) -> dict[str, Any]:
        """
        Export full configuration as dict for backtest setup.

        Returns:
            Dict with both costs and realism parameters.
        """
        return {
            "costs": {
                "base_slippage_cents": float(self.costs.base_slippage_cents),
                "slippage_multiplier": float(self.costs.slippage_multiplier),
                "commission_per_lot": float(self.costs.commission_per_lot),
            },
            "realism": self.realism.to_dict(),
        }

    @classmethod
    def with_conservative_realism(cls, costs: ExecutionCosts) -> "ExecutionModel":
        """Factory for conservative realism settings."""
        return cls(costs=costs, realism=ExecutionRealism.conservative())

    @classmethod
    def with_aggressive_realism(cls, costs: ExecutionCosts) -> "ExecutionModel":
        """Factory for aggressive (stress-test) realism settings."""
        return cls(costs=costs, realism=ExecutionRealism.aggressive())

    @classmethod
    def with_ideal_realism(cls, costs: ExecutionCosts) -> "ExecutionModel":
        """Factory for ideal (no imperfections) settings."""
        return cls(costs=costs, realism=ExecutionRealism.ideal())
