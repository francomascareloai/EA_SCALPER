"""Module entrypoint for running the Nautilus tick backtest.

This exists to satisfy the project plan's canonical command:

    python -m nautilus_gold_scalper.run_backtest --start YYYY-MM-DD --end YYYY-MM-DD

The implementation lives in `nautilus_gold_scalper.scripts.backtest.run_backtest`.
"""

from __future__ import annotations

from nautilus_gold_scalper.scripts.backtest.run_backtest import main


if __name__ == "__main__":
    main()
