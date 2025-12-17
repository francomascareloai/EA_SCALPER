"""Deprecated entrypoint.

Use the canonical CLI:
  `python -m nautilus_gold_scalper.scripts.run_backtest --sweep --start DATE --end DATE`
"""

from __future__ import annotations


def main() -> None:
    raise SystemExit(
        "Deprecated: use `python -m nautilus_gold_scalper.scripts.run_backtest --sweep ...` "
        "(see `nautilus_gold_scalper/scripts/backtest/run_backtest.py`)."
    )


if __name__ == "__main__":
    main()
