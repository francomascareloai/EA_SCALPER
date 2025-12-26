from __future__ import annotations

import hashlib
import json
import os
import tempfile
from collections.abc import Callable
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, cast

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import TrialResult

# v1: included an unbounded `replay_results` list (deprecated)
# v2: bounded format; stores top-N results + optional strategy state
CHECKPOINT_FORMAT_VERSION: int = 2
DEFAULT_CHECKPOINT_FILENAME: str = "checkpoint.json"


class CheckpointError(RuntimeError):
    pass


def _normalize_jsonable(value: Any) -> Any:
    """Normalize common non-JSON scalar types."""
    if isinstance(value, (str, int, float, bool)) or value is None:
        return value

    # numpy scalars, pandas scalars, etc.
    if hasattr(value, "item") and callable(value.item):
        try:
            return value.item()
        except Exception:
            pass

    if isinstance(value, (datetime, Path)):
        return str(value)

    return str(value)


def _json_normalize(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {str(k): _json_normalize(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_json_normalize(v) for v in obj]
    return _normalize_jsonable(obj)


def compute_config_fingerprint(config: OptimizationConfig) -> str:
    """Compute a stable fingerprint for resume safety."""
    payload = _json_normalize(asdict(config))
    raw = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def trial_result_to_dict(result: TrialResult) -> dict[str, Any]:
    row = asdict(result)
    return cast(dict[str, Any], _json_normalize(row))


def trial_result_from_dict(data: dict[str, Any]) -> TrialResult:
    required = {
        "trial_id",
        "params",
        "sqn",
        "sharpe",
        "sortino",
        "profit_factor",
        "total_pnl",
        "trades",
        "win_rate",
        "max_drawdown_pct",
        "wfe",
        "wfe_std",
        "positive_days_ratio",
        "regime_scores",
        "trailing_dd",
        "daily_profit_max",
        "daily_dd",
        "time_gate_violations",
        "overnight_positions",
        "apex_compliant",
        "score",
    }
    missing = required.difference(data.keys())
    if missing:
        raise CheckpointError(f"TrialResult missing fields: {sorted(missing)}")

    return TrialResult(
        trial_id=int(data["trial_id"]),
        params=dict(data["params"]),
        sqn=float(data["sqn"]),
        sharpe=float(data["sharpe"]),
        sortino=float(data["sortino"]),
        profit_factor=float(data["profit_factor"]),
        total_pnl=float(data["total_pnl"]),
        trades=int(data["trades"]),
        win_rate=float(data["win_rate"]),
        max_drawdown_pct=float(data["max_drawdown_pct"]),
        wfe=float(data["wfe"]),
        wfe_std=float(data["wfe_std"]),
        positive_days_ratio=float(data["positive_days_ratio"]),
        regime_scores=dict(data["regime_scores"]),
        trailing_dd=float(data["trailing_dd"]),
        daily_profit_max=float(data["daily_profit_max"]),
        daily_dd=float(data["daily_dd"]),
        time_gate_violations=int(data["time_gate_violations"]),
        overnight_positions=int(data["overnight_positions"]),
        apex_compliant=bool(data["apex_compliant"]),
        score=float(data["score"]),
        mc_95_dd=data.get("mc_95_dd"),
        mc_99_dd=data.get("mc_99_dd"),
        degradation_survived=data.get("degradation_survived"),
        pbo=data.get("pbo"),
        duration_seconds=float(data.get("duration_seconds", 0.0)),
        output_dir=str(data.get("output_dir", "")),
        pruned=bool(data.get("pruned", False)),
    )


def atomic_write_text(path: Path, content: str) -> None:
    """Write content to `path` atomically."""
    path.parent.mkdir(parents=True, exist_ok=True)

    fd, tmp_path = tempfile.mkstemp(dir=str(path.parent), prefix=path.name, suffix=".tmp")
    tmp = Path(tmp_path)
    try:
        try:
            f = os.fdopen(fd, "w", encoding="utf-8")
        except Exception:
            # If fdopen fails, we must close the raw fd to avoid a leak.
            os.close(fd)
            raise

        with f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())

        os.replace(str(tmp), str(path))

        # Best-effort fsync of directory entry.
        try:
            dir_fd = os.open(str(path.parent), os.O_DIRECTORY)
        except Exception:
            dir_fd = None
        if dir_fd is not None:
            try:
                os.fsync(dir_fd)
            finally:
                os.close(dir_fd)

    finally:
        if tmp.exists():
            try:
                tmp.unlink()
            except Exception:
                pass


def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    atomic_write_text(path, json.dumps(payload, indent=2, sort_keys=True, default=str))


def quarantine_corrupt_checkpoint(path: Path) -> Path:
    ts = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    new_path = path.with_suffix(path.suffix + f".corrupt.{ts}")
    os.replace(str(path), str(new_path))
    return new_path


@dataclass(slots=True)
class OptimizationCheckpoint:
    format_version: int
    created_at_utc: str
    mode: str
    config_fingerprint: str
    resume_from_trial_id: int
    evaluated_total: int
    top_results: list[dict[str, Any]]
    search_state: dict[str, Any] | None = None


def load_checkpoint(path: Path) -> OptimizationCheckpoint:
    try:
        raw = path.read_text(encoding="utf-8")
        data = json.loads(raw)
    except Exception as e:
        raise CheckpointError(f"Failed to read checkpoint: {path}") from e

    if not isinstance(data, dict):
        raise CheckpointError("Checkpoint root must be an object")

    fv = int(data.get("format_version", -1))
    if fv not in {1, 2}:
        raise CheckpointError(f"Unsupported checkpoint format_version={fv}")

    top = data.get("top_results")
    if top is None or not isinstance(top, list):
        raise CheckpointError("Checkpoint missing top_results list")

    # v1 carried an unbounded replay_results list; ignore it during load.
    search_state = data.get("search_state")
    if search_state is not None and not isinstance(search_state, dict):
        raise CheckpointError("Checkpoint search_state must be an object or null")

    return OptimizationCheckpoint(
        format_version=fv,
        created_at_utc=str(data.get("created_at_utc", "")),
        mode=str(data.get("mode", "")),
        config_fingerprint=str(data.get("config_fingerprint", "")),
        resume_from_trial_id=int(data.get("resume_from_trial_id", 0)),
        evaluated_total=int(data.get("evaluated_total", 0)),
        top_results=cast(list[dict[str, Any]], top),
        search_state=cast(dict[str, Any] | None, search_state),
    )


class CheckpointManager:
    """Periodic, crash-safe checkpoint writer.

    Design goals:
      - Atomic writes and basic corruption handling.
      - Bounded checkpoint size (top-N results only).
      - Optional strategy state for deterministic resume.
    """

    def __init__(
        self,
        path: Path,
        *,
        mode: str,
        config_fingerprint: str,
        interval: int,
        keep_top_n: int,
        ignore_trial_id_lt: int = 0,
        state_provider: Callable[[], dict[str, Any] | None] | None = None,
        progress_provider: Callable[[TrialResult], int] | None = None,
    ) -> None:
        if interval <= 0:
            raise ValueError("checkpoint interval must be > 0")
        if keep_top_n <= 0:
            raise ValueError("keep_top_n must be > 0")
        if ignore_trial_id_lt < 0:
            raise ValueError("ignore_trial_id_lt must be >= 0")

        self._path = path
        self._mode = mode
        self._config_fingerprint = config_fingerprint
        self._interval = interval
        self._keep_top_n = keep_top_n
        self._ignore_trial_id_lt = ignore_trial_id_lt
        self._state_provider = state_provider
        self._progress_provider = progress_provider

        self._last_saved_at: int = 0
        self._top: list[TrialResult] = []

        self._cleanup_tmp_files()

    def seed_top_results(self, results: list[TrialResult]) -> None:
        self._top = list(results)
        self._top.sort(key=lambda r: r.score, reverse=True)
        if len(self._top) > self._keep_top_n:
            del self._top[self._keep_top_n :]

    def __call__(self, result: TrialResult) -> None:
        if result.trial_id < self._ignore_trial_id_lt:
            return

        self._record(result)

        progress = (
            int(self._progress_provider(result))
            if self._progress_provider is not None
            else int(result.trial_id) + 1
        )
        if progress - self._last_saved_at >= self._interval:
            self._save(progress)

    def force_save(self, progress: int) -> None:
        if progress < 0:
            raise ValueError("progress must be >= 0")
        self._save(int(progress))

    def _record(self, result: TrialResult) -> None:
        self._top.append(result)
        self._top.sort(key=lambda r: r.score, reverse=True)
        if len(self._top) > self._keep_top_n:
            del self._top[self._keep_top_n :]

    def _save(self, progress: int) -> None:
        payload = OptimizationCheckpoint(
            format_version=CHECKPOINT_FORMAT_VERSION,
            created_at_utc=datetime.now(timezone.utc).isoformat(),
            mode=self._mode,
            config_fingerprint=self._config_fingerprint,
            resume_from_trial_id=progress,
            evaluated_total=progress,
            top_results=[trial_result_to_dict(r) for r in self._top],
            search_state=self._state_provider() if self._state_provider is not None else None,
        )
        atomic_write_json(self._path, cast(dict[str, Any], _json_normalize(asdict(payload))))
        self._last_saved_at = progress

    def _cleanup_tmp_files(self) -> None:
        parent = self._path.parent
        prefix = self._path.name
        for p in parent.iterdir():
            if p.is_file() and p.name.startswith(prefix) and p.name.endswith(".tmp"):
                try:
                    p.unlink()
                except Exception:
                    pass
