"""Commission schedules for prop/broker profiles.

Keep this module as the single source of truth for *assumed* commissions used by:
- Backtests (engine FeeModel)
- Strategy-side execution realism (when engine fees are not available)

Important:
- Values here are assumptions used for simulation/risk accounting.
- For live trading, always prefer broker-provided actual fills/fees when available.
"""

from __future__ import annotations

from typing import Literal

PropProfile = Literal["apex", "ftmo"]
Product = Literal["xauusd", "mgc"]
Gateway = Literal["rithmic", "tradovate"]


def commission_per_side_usd(*, profile: PropProfile, product: Product, gateway: Gateway) -> float:
    """Return commission per side (per fill) in USD.

    Notes:
    - We model commission as "per side". Round turn ~= 2x per-side.
    - This function is intentionally strict: unsupported combinations raise.
    """

    if profile == "apex":
        if product != "mgc":
            raise ValueError(f"Unsupported Apex commission lookup for product={product!r}")
        if gateway == "rithmic":
            return 0.76
        if gateway == "tradovate":
            return 0.67
        raise ValueError(f"Unsupported gateway={gateway!r}")

    # FTMO is FX/CFD, not futures. Keep explicit until we define a schedule.
    if profile == "ftmo":
        raise NotImplementedError("FTMO commission schedule not implemented; use manual commission_per_contract")

    raise ValueError(f"Unsupported profile={profile!r}")
