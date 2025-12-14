"""
Lightweight JSONL telemetry sink for strategy observability.

Writes structured events to a single file to keep all operational signals in one place.
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Optional


class TelemetrySink:
    """Append-only JSONL writer with graceful failure handling."""

    def __init__(self, path: Path | str, enabled: bool = True) -> None:
        self.enabled = bool(enabled)
        self.path = Path(path)
        if self.enabled:
            self.path.parent.mkdir(parents=True, exist_ok=True)

    def emit(self, event: str, payload: Optional[Dict[str, Any]] = None) -> None:
        """Write a single telemetry event."""
        if not self.enabled:
            return
        try:
            record: Dict[str, Any] = {"event": event}
            if payload:
                record.update(payload)
            record.setdefault("ts", datetime.now(timezone.utc).isoformat())
            with self.path.open("a", encoding="utf-8") as f:
                f.write(json.dumps(record, ensure_ascii=True) + "\n")
        except Exception:
            # Never let telemetry failures impact trading logic
            return

