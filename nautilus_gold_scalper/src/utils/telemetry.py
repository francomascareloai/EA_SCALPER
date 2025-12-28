"""
Lightweight JSONL telemetry sink for strategy observability.

Writes structured events to a single file to keep all operational signals in one place.
"""

from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, TextIO


class TelemetrySink:
    """Append-only JSONL writer with graceful failure handling.

    PERF:
        Avoid opening the telemetry file on every event. Keep a per-process file
        handle open (line-buffered) and reopen if the process forks.

    SAFETY:
        Telemetry must never impact trading logic. All errors are swallowed.
    """

    def __init__(self, path: Path | str, enabled: bool = True) -> None:
        self.enabled = bool(enabled)
        self.path = Path(path)
        self._fp: TextIO | None = None
        self._pid: int | None = None

        if self.enabled:
            self.path.parent.mkdir(parents=True, exist_ok=True)

    def _ensure_open(self) -> TextIO:
        pid = os.getpid()
        if self._fp is not None and self._pid == pid:
            return self._fp

        # Process changed (fork) or file not open yet.
        try:
            if self._fp is not None:
                self._fp.close()
        except Exception:
            pass

        self._pid = pid
        # Line-buffered: flushes at newline boundaries (similar durability to open/close per event,
        # without the syscall overhead).
        self._fp = self.path.open("a", encoding="utf-8", buffering=1)
        return self._fp

    def emit(self, event: str, payload: object | None = None) -> None:
        """Write a single telemetry event."""
        if not self.enabled:
            return
        try:
            record: dict[str, Any] = {"event": event}
            if payload is None:
                pass
            elif isinstance(payload, dict):
                record.update(payload)
            else:
                record["payload"] = payload

            # Keep prior behavior: only inject wall-clock ts if caller did not supply one.
            record.setdefault("ts", datetime.now(timezone.utc).isoformat())

            fp = self._ensure_open()
            fp.write(json.dumps(record, ensure_ascii=True) + "\n")
        except Exception:
            # Never let telemetry failures impact trading logic
            return

    def flush(self) -> None:
        if not self.enabled:
            return
        try:
            if self._fp is not None:
                self._fp.flush()
        except Exception:
            return

    def close(self) -> None:
        if not self.enabled:
            return
        try:
            if self._fp is not None:
                try:
                    self._fp.flush()
                except Exception:
                    pass
                self._fp.close()
            self._fp = None
            self._pid = None
        except Exception:
            return
