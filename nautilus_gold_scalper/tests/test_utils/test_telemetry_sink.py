from __future__ import annotations

import json
from pathlib import Path

from nautilus_gold_scalper.src.utils.telemetry import TelemetrySink


def _read_jsonl(path: Path) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        rows.append(json.loads(line))
    return rows


def test_telemetry_sink_writes_jsonl_and_injects_ts(tmp_path: Path) -> None:
    p = tmp_path / "telemetry.jsonl"
    t = TelemetrySink(p, enabled=True)

    t.emit("evt", {"x": 1})
    t.close()

    rows = _read_jsonl(p)
    assert len(rows) == 1
    assert rows[0]["event"] == "evt"
    assert rows[0]["x"] == 1
    assert "ts" in rows[0]


def test_telemetry_sink_does_not_override_ts_if_provided(tmp_path: Path) -> None:
    p = tmp_path / "telemetry.jsonl"
    t = TelemetrySink(p, enabled=True)

    t.emit("evt", {"ts": "2025-01-01T00:00:00Z"})
    t.close()

    rows = _read_jsonl(p)
    assert rows[0]["ts"] == "2025-01-01T00:00:00Z"


def test_telemetry_sink_noop_when_disabled(tmp_path: Path) -> None:
    p = tmp_path / "telemetry.jsonl"
    t = TelemetrySink(p, enabled=False)

    t.emit("evt", {"x": 1})
    t.close()

    assert not p.exists()
