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
        # Costs as of 2024-2025 for MGC (Micro Gold)
        # Breakdown is per-side (per fill) USD; round turn ~= 2x.
        if product != "mgc":
            raise ValueError(f"Unsupported Apex commission lookup for product={product!r}")
        if gateway == "rithmic":
            return 1.14  # Exchange $0.52 + NFA $0.02 + Routing $0.10 + Commission $0.50
        if gateway == "tradovate":
            return 1.04  # Exchange $0.52 + NFA $0.02 + Commission $0.50
        raise ValueError(f"Unsupported gateway={gateway!r}")

    # FTMO is FX/CFD, not futures. For CFDs we approximate the spread cost as a
    # per-side proxy: half-spread in USD (entry/exit).
    if profile == "ftmo":
        if product == "xauusd":
            # Typical XAUUSD CFD spread assumption: ~$0.30 → half-spread ~$0.15 per side.
            return 0.15
        raise NotImplementedError(
            "FTMO commission schedule not implemented for this product; use manual commission_per_contract"
        )

    raise ValueError(f"Unsupported profile={profile!r}")
