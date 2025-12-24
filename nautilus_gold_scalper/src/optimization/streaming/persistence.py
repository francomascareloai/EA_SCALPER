from __future__ import annotations

import json
from dataclasses import asdict
from pathlib import Path
from typing import Any

import pandas as pd

from src.optimization.search.base import TrialResult


class ParquetResultSink:
    """Incrementally persists trial results to Parquet.

    Writes to a partitioned dataset to avoid read/concat/write scaling.
    Output layout:
      <base_dir>/<dataset_name>/part-00000.parquet
      <base_dir>/<dataset_name>/part-00001.parquet
      ...

    This keeps RAM bounded even for very large trial counts.
    """

    def __init__(
        self,
        base_dir: str | Path,
        *,
        flush_every: int = 50,
        dataset_name: str = "results_dataset",
    ) -> None:
        if flush_every <= 0:
            raise ValueError("flush_every must be > 0")

        self.base_dir = Path(base_dir)
        self.dataset_dir = self.base_dir / dataset_name
        self.dataset_dir.mkdir(parents=True, exist_ok=True)

        self.flush_every = flush_every
        self._buffer: list[dict[str, Any]] = []
        self._part = 0

    def append(self, result: TrialResult) -> None:
        self._buffer.append(self._result_to_row(result))
        if len(self._buffer) >= self.flush_every:
            self.flush()

    def flush(self) -> None:
        if not self._buffer:
            return

        df = pd.DataFrame(self._buffer)
        path = self.dataset_dir / f"part-{self._part:05d}.parquet"
        df.to_parquet(path, index=False)

        self._part += 1
        self._buffer = []

    def close(self) -> None:
        self.flush()

    def _result_to_row(self, result: TrialResult) -> dict[str, Any]:
        row = asdict(result)
        row["params"] = json.dumps(result.params, default=str, sort_keys=True)
        row["regime_scores"] = json.dumps(result.regime_scores, default=str, sort_keys=True)
        if result.degradation_survived is not None:
            row["degradation_survived"] = json.dumps(result.degradation_survived, default=str)
        return row


class ResultStreamer:
    """Adapter that exposes a simple callable for SearchStrategy.on_result."""

    def __init__(self, sink: ParquetResultSink) -> None:
        self._sink = sink

    def __call__(self, result: TrialResult) -> None:
        self._sink.append(result)

    def close(self) -> None:
        self._sink.close()
