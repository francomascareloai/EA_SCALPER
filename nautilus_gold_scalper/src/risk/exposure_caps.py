from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class ExposureCapsResult:
    allow_entry: bool
    reason: str | None = None


class ExposureCaps:
    """Entry-only exposure caps.

    This component MUST NOT be used to block forced closes / flattening.
    """

    def __init__(
        self,
        *,
        max_concurrent_positions: int = 1,
        max_concurrent_instruments: int = 1,
    ) -> None:
        self.max_concurrent_positions = int(max_concurrent_positions)
        self.max_concurrent_instruments = int(max_concurrent_instruments)

    def evaluate(
        self,
        *,
        open_positions_count: int,
        open_instruments_count: int,
    ) -> ExposureCapsResult:
        if open_positions_count >= self.max_concurrent_positions:
            return ExposureCapsResult(False, "max_concurrent_positions")

        if open_instruments_count >= self.max_concurrent_instruments:
            return ExposureCapsResult(False, "max_concurrent_instruments")

        return ExposureCapsResult(True, None)
