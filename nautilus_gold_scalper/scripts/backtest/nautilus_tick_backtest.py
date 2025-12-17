"""Deprecated alias for the canonical backtest CLI.

Use:
  `python -m nautilus_gold_scalper.scripts.run_backtest --feed ticks ...`
"""

from __future__ import annotations

import sys
from pathlib import Path


def main() -> None:
    repo_root = Path(__file__).resolve().parents[2]
    sys.path.insert(0, str(repo_root))
    from nautilus_gold_scalper.scripts.backtest.run_backtest import main as run

    run()


if __name__ == "__main__":
    main()

