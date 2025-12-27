"""Commission schedules for prop/broker profiles.

Keep this module as the single source of truth for *assumed* commissions used by:
- Backtests (engine FeeModel)
- Strategy-side execution realism (when engine fees are not available)

Important:
- Values here are assumptions used for simulation/risk accounting.
- For live trading, always prefer broker-provided actual fills/fees when available.
"""

from __future__ import annotations

import logging
from typing import Literal

PropProfile = Literal["apex", "ftmo"]
Product = Literal["xauusd", "mgc"]
Gateway = Literal["rithmic", "tradovate"]

_LOG = logging.getLogger(__name__)


def commission_per_side_usd(*, profile: PropProfile, product: Product, gateway: Gateway) -> float:
    """Return commission per side (per fill) in USD.

    Notes:
    - We model commission as "per side". Round turn ~= 2x per-side.
    - This function models *explicit commissions only*.
      Do NOT use it to model spread if your feed already contains bid/ask.
    - The backtest runner can also stress spread via bid/ask widening; charging a
      spread-proxy here would double-count costs.
    - Unsupported combinations generally raise, except for conservative
      fail-open fallbacks which prevent avoidable backtest crashes.
    """

    if profile == "apex":
        # Apex is primarily futures (e.g., MGC). For our XAUUSD spot/CFD dataset,
        # we treat Apex as having *no explicit commission* and rely on bid/ask + slippage.
        #
        # This avoids a common footgun:
        # - If the feed already contains bid/ask, spread is already paid implicitly.
        # - If we also model half-spread as "commission" here, we double-charge.
        if product == "xauusd":
            _LOG.warning(
                "[commission_schedule] Fallback: Apex commission requested for product='xauusd'. "
                "Returning 0.0 (explicit commissions only; spread/slippage modeled elsewhere)."
            )
            return 0.0

        # Costs as of 2024-2025 for MGC (Micro Gold)
        # Breakdown is per-side (per fill) USD; round turn ~= 2x.
        if product != "mgc":
            raise ValueError(f"Unsupported Apex commission lookup for product={product!r}")
        if gateway == "rithmic":
            return 1.14  # Exchange $0.52 + NFA $0.02 + Routing $0.10 + Commission $0.50
        if gateway == "tradovate":
            return 1.04  # Exchange $0.52 + NFA $0.02 + Commission $0.50
        raise ValueError(f"Unsupported gateway={gateway!r}")

    # FTMO is FX/CFD, not futures.
    # For this project we do NOT encode spread as a commission schedule because the
    # feed already contains bid/ask. Keep FTMO strict until we define an explicit
    # broker commission model.
    if profile == "ftmo":
        raise NotImplementedError(
            "FTMO commission schedule intentionally undefined (avoid spread double-counting). "
            "Use execution.commission_source=manual with commission_per_contract=0.0 and rely on bid/ask + slippage."
        )

    raise ValueError(f"Unsupported profile={profile!r}")
