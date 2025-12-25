"""Legacy wrapper for the historical eval-20d grid search workflow.

This workflow was archived under:
- `nautilus_gold_scalper/scripts/archive/optimization_legacy/grid_search_eval20d.py`

The canonical entrypoint for optimization is now:
- `nautilus_gold_scalper/scripts/optimize.py`

This module is kept to avoid breaking existing docs/commands.
"""

from __future__ import annotations

from nautilus_gold_scalper.scripts.archive.optimization_legacy.grid_search_eval20d import main


if __name__ == "__main__":
    raise SystemExit(main())
