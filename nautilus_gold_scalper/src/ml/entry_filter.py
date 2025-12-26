from __future__ import annotations

import json
import logging
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any, cast

import numpy as np
from numpy.typing import NDArray

logger = logging.getLogger(__name__)


@dataclass(frozen=True, slots=True)
class EntryFilterModelInfo:
    key: str
    onnx_path: Path
    metadata_path: Path
    feature_cols: list[str]
    n_features: int


@dataclass(frozen=True, slots=True)
class EntryFilterDecision:
    should_trade: bool
    p_edge: float | None
    model_key: str | None
    latency_ms: float | None
    reason: str


class OnnxEntryFilter:
    """Deterministic, fail-open ONNX entry filter.

    - Loads ONNX Runtime sessions at startup (never during hot path unless caller chooses).
    - Vectorizes a dict of features using metadata feature order.
    - Produces p_edge as P(class=1) from the ONNX probabilities tensor.

    Security note: runtime uses ONNX only (no pickle/joblib).
    """

    def __init__(self, model_path: Path):
        self._root = model_path
        self._models: dict[str, tuple[Any, EntryFilterModelInfo]] = {}
        self._input_names: dict[str, str] = {}
        self._prob_output_idx: dict[str, int] = {}
        self._init_error: str | None = None

    @property
    def init_error(self) -> str | None:
        return self._init_error

    def initialize(self) -> None:
        """Load model(s) and warm up sessions.

        If any load fails, the filter remains usable (fail-open), with `init_error` set.
        """
        try:
            self._models = self._load_models(self._root)
        except Exception as exc:
            self._models = {}
            self._init_error = f"load_failed:{type(exc).__name__}"
            logger.warning("[ML_FILTER] init failed", exc_info=True)
            return

        self._input_names = {}
        self._prob_output_idx = {}

        for key, (session, info) in self._models.items():
            try:
                input_name = session.get_inputs()[0].name
                out_names = [o.name for o in session.get_outputs()]
                if "probabilities" in out_names:
                    prob_idx = out_names.index("probabilities")
                else:
                    prob_idx = -1
                    for i, o in enumerate(session.get_outputs()):
                        try:
                            shp = getattr(o, "shape", None)
                            if shp is not None and len(shp) == 2 and int(shp[1]) == 2:
                                prob_idx = i
                                break
                        except Exception:
                            continue
                    if prob_idx < 0:
                        raise RuntimeError(f"Cannot locate probability output: outputs={out_names}")

                self._input_names[key] = str(input_name)
                self._prob_output_idx[key] = int(prob_idx)

                # Warm-up to avoid first-call latency spikes.
                x = np.zeros((1, int(info.n_features)), dtype=np.float32)
                _ = session.run(None, {input_name: x})
                logger.info("[ML_FILTER] warmed model=%s n_features=%s", key, info.n_features)
            except Exception:
                logger.warning("[ML_FILTER] warm-up failed model=%s", key, exc_info=True)

    @staticmethod
    def _direction_to_key(direction: str | int | float) -> str | None:
        """Normalize direction input to model key.

        Accepts:
        - Strings: "long"/"short" (also "buy"/"sell", "1"/"-1")
        - Numerics: positive -> long, negative -> short

        Returns None when direction cannot be determined.
        """
        if isinstance(direction, str):
            d = direction.strip().lower()
            if d in ("short", "sell", "-1"):
                return "short"
            if d in ("long", "buy", "1"):
                return "long"
            return None

        # IntEnum/SignalType/Direction values behave like numbers.
        try:
            x = float(direction)
        except Exception:
            return None

        if x < 0.0:
            return "short"
        if x > 0.0:
            return "long"
        return None

    def predict(
        self,
        features: dict[str, object],
        *,
        direction: str | int | float,
        min_p_edge: float,
        mode: str,
    ) -> EntryFilterDecision:
        """Apply the filter.

        direction: "long" | "short" (used to pick direction-specific model when available)
        mode: "log_only" | "gate" (gate blocks when p_edge < min_p_edge)
        """
        # Master fail-open: if uninitialized or no models, never block.
        if not self._models:
            return EntryFilterDecision(
                should_trade=True,
                p_edge=None,
                model_key=None,
                latency_ms=None,
                reason="model_unavailable",
            )

        dir_key = self._direction_to_key(direction)
        if dir_key is None:
            # Invalid/unrecognized direction -> remain fail-open and pick any model.
            key = next(iter(self._models.keys()))
        else:
            key = dir_key
            if key not in self._models:
                # Fallback to any available model.
                key = next(iter(self._models.keys()))

        session, info = self._models[key]

        input_name = self._input_names.get(key)
        prob_idx = self._prob_output_idx.get(key)
        if not input_name or prob_idx is None:
            # If initialize() didn't cache names, remain fail-open.
            return EntryFilterDecision(
                should_trade=True,
                p_edge=None,
                model_key=key,
                latency_ms=None,
                reason="model_unavailable",
            )

        t0 = time.perf_counter_ns()
        try:
            x = self._vectorize(features, info.feature_cols)
            # Treat any non-finite value (NaN/Inf) as a missing feature and fail-open.
            if not bool(np.isfinite(x).all()):
                latency_ms = (time.perf_counter_ns() - t0) / 1e6
                return EntryFilterDecision(
                    should_trade=True,
                    p_edge=None,
                    model_key=key,
                    latency_ms=float(latency_ms),
                    reason="missing_features",
                )
            outputs = session.run(None, {input_name: x})
            p_edge = self._extract_p_edge(outputs, session, prob_idx=int(prob_idx))
        except Exception as exc:
            latency_ms = (time.perf_counter_ns() - t0) / 1e6
            return EntryFilterDecision(
                should_trade=True,
                p_edge=None,
                model_key=key,
                latency_ms=float(latency_ms),
                reason=f"inference_failed:{type(exc).__name__}",
            )

        latency_ms = (time.perf_counter_ns() - t0) / 1e6

        if not np.isfinite(p_edge):
            return EntryFilterDecision(
                should_trade=True,
                p_edge=None,
                model_key=key,
                latency_ms=float(latency_ms),
                reason="invalid_output:nan",
            )

        # Defensive bounds; logistic-style probabilities should be in [0,1].
        if p_edge < -0.01 or p_edge > 1.01:
            return EntryFilterDecision(
                should_trade=True,
                p_edge=None,
                model_key=key,
                latency_ms=float(latency_ms),
                reason=f"invalid_output:out_of_range:{p_edge}",
            )

        p_edge_f = float(max(0.0, min(1.0, p_edge)))

        # BUG-ENUM-001: Avoid brittle comparisons (`str(mode) == "gate"`).
        if str(mode).strip().lower() == "gate" and p_edge_f < float(min_p_edge):
            return EntryFilterDecision(
                should_trade=False,
                p_edge=p_edge_f,
                model_key=key,
                latency_ms=float(latency_ms),
                reason="blocked_below_threshold",
            )

        return EntryFilterDecision(
            should_trade=True,
            p_edge=p_edge_f,
            model_key=key,
            latency_ms=float(latency_ms),
            reason="ok",
        )

    @staticmethod
    def _vectorize(features: dict[str, object], feature_cols: list[str]) -> NDArray[np.float32]:
        vals: list[float] = []
        for name in feature_cols:
            v = features.get(name)
            if v is None:
                vals.append(float("nan"))
                continue
            if isinstance(v, bool):
                vals.append(1.0 if v else 0.0)
                continue
            if isinstance(v, (int, float)):
                vals.append(float(v))
                continue
            # Try parsing numeric strings (telemetry may serialize ints/floats as str).
            if isinstance(v, str):
                try:
                    vals.append(float(v))
                except ValueError:
                    vals.append(float("nan"))
                continue
            vals.append(float("nan"))

        x = cast(NDArray[np.float32], np.asarray(vals, dtype=np.float32).reshape(1, -1))
        return x

    @staticmethod
    def _extract_p_edge(outputs: list[Any], session: Any, *, prob_idx: int) -> float:
        # Preferred: use cached output index from initialize().
        if 0 <= int(prob_idx) < len(outputs):
            probs = outputs[int(prob_idx)]
        else:
            out_names = [o.name for o in session.get_outputs()]
            # Fallback: find output named "probabilities".
            if "probabilities" in out_names:
                idx = out_names.index("probabilities")
                probs = outputs[idx]
            else:
                # Last resort: pick the first 2D output with shape (N,2).
                probs = None
                for arr in outputs:
                    try:
                        if hasattr(arr, "shape") and len(arr.shape) == 2 and int(arr.shape[1]) == 2:
                            probs = arr
                            break
                    except Exception:
                        continue
                if probs is None:
                    raise RuntimeError(f"Cannot locate probability output: outputs={out_names}")

        return float(probs[0, 1])

    @staticmethod
    def _load_models(model_path: Path) -> dict[str, tuple[Any, EntryFilterModelInfo]]:
        try:
            import onnxruntime as ort
        except Exception as exc:  # pragma: no cover
            raise RuntimeError("onnxruntime not available") from exc

        def load_one(key: str, onnx_path: Path) -> tuple[Any, EntryFilterModelInfo]:
            metadata_path = onnx_path.with_name(f"{onnx_path.stem}_metadata.json")
            meta = json.loads(metadata_path.read_text(encoding="utf-8"))
            cols = meta.get("feature_cols")
            if not isinstance(cols, list) or not all(isinstance(c, str) for c in cols):
                raise ValueError(f"Invalid feature_cols in metadata: {metadata_path}")
            n_features = int(meta.get("n_features", len(cols)))
            if n_features != len(cols):
                raise ValueError(f"n_features mismatch: {n_features} vs {len(cols)}")

            sess_options = ort.SessionOptions()
            sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
            session = ort.InferenceSession(
                str(onnx_path),
                sess_options=sess_options,
                providers=["CPUExecutionProvider"],
            )

            return (
                session,
                EntryFilterModelInfo(
                    key=key,
                    onnx_path=onnx_path,
                    metadata_path=metadata_path,
                    feature_cols=list(cols),
                    n_features=n_features,
                ),
            )

        if model_path.is_dir():
            models: dict[str, tuple[Any, EntryFilterModelInfo]] = {}
            long_path = model_path / "filter_y_good_long.onnx"
            short_path = model_path / "filter_y_good_short.onnx"
            if (
                long_path.exists()
                and long_path.with_name(f"{long_path.stem}_metadata.json").exists()
            ):
                models["long"] = load_one("long", long_path)
            if (
                short_path.exists()
                and short_path.with_name(f"{short_path.stem}_metadata.json").exists()
            ):
                models["short"] = load_one("short", short_path)
            if models:
                return models
            raise FileNotFoundError(f"No filter models found in dir: {model_path}")

        if model_path.suffix != ".onnx":
            raise ValueError(
                f"Unsupported model format: {model_path.suffix} (expected .onnx or dir)"
            )
        if not model_path.exists():
            raise FileNotFoundError(f"Model not found: {model_path}")
        meta_path = model_path.with_name(f"{model_path.stem}_metadata.json")
        if not meta_path.exists():
            raise FileNotFoundError(f"Metadata not found: {meta_path}")

        session, info = load_one("generic", model_path)
        return {"long": (session, info), "short": (session, info)}
