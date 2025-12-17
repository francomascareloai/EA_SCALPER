"""Deprecated entrypoint.

This was an experimental parameter-optimization script and is now archived.
Use the canonical CLI instead:
  `python -m nautilus_gold_scalper.scripts.run_backtest ...`
"""

from __future__ import annotations


def main() -> None:
    raise SystemExit(
        "Deprecated: use `python -m nautilus_gold_scalper.scripts.run_backtest ...`. "
        "If you really need the old optimizer, recover it from git history."
    )


if __name__ == "__main__":
    main()

