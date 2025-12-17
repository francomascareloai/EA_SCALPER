from __future__ import annotations

import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

SCRIPTS_DIR = ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    # Keep project root first so `import scripts.*` resolves to this repo.
    sys.path.insert(1, str(SCRIPTS_DIR))

# Defensive: some environments/plugins can import a different top-level `scripts` module
# before our tests run. Ensure `scripts` resolves to this repository's package.
existing = sys.modules.get("scripts")
existing_file = getattr(existing, "__file__", None)
if existing is not None and isinstance(existing_file, str) and existing_file:
    try:
        if not Path(existing_file).resolve().is_relative_to(ROOT):
            del sys.modules["scripts"]
    except Exception:
        # If we can't determine provenance, prefer leaving it alone.
        pass
