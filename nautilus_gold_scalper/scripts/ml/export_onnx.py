from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path

import joblib
import numpy as np


@dataclass(frozen=True, slots=True)
class ExportResult:
    onnx_path: Path
    metadata_path: Path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Export trained sklearn entry filter to ONNX.")
    p.add_argument(
        "--model", required=True, help="Path to trained .joblib model (from train_filter.py)."
    )
    p.add_argument(
        "--allow-unsafe-pickle",
        action="store_true",
        help=(
            "Allow loading a pickle/joblib model from disk. "
            "DANGER: loading untrusted .joblib/.pkl can execute arbitrary code. "
            "Prefer exporting from a trusted training run only."
        ),
    )
    p.add_argument(
        "--features",
        default=None,
        help="Optional path to *_features.txt; defaults to sibling of --model.",
    )
    p.add_argument(
        "--out",
        default=None,
        help="Output .onnx path (default: same as --model but with .onnx suffix).",
    )
    p.add_argument(
        "--opset",
        type=int,
        default=12,
        help="Target ONNX opset version.",
    )
    p.add_argument(
        "--verify",
        action="store_true",
        help="Run a tiny inference parity check (sklearn vs onnxruntime).",
    )
    return p.parse_args()


def _infer_features_path(model_path: Path) -> Path:
    # train_filter.py writes: filter_<target>.joblib + filter_<target>_features.txt
    return model_path.with_name(f"{model_path.stem}_features.txt")


def _load_features(path: Path) -> list[str]:
    raw = path.read_text(encoding="utf-8")
    cols = [ln.strip() for ln in raw.splitlines() if ln.strip()]
    if not cols:
        raise ValueError(f"Empty feature list: {path}")
    return cols


def export_filter_onnx(
    model_path: Path,
    *,
    features_path: Path | None,
    out_path: Path | None,
    opset: int,
    verify: bool,
    allow_unsafe_pickle: bool = False,
) -> ExportResult:
    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType

    if opset < 11:
        raise ValueError("opset must be >= 11")

    if features_path is None:
        features_path = _infer_features_path(model_path)

    feature_cols = _load_features(features_path)

    if out_path is None:
        out_path = model_path.with_suffix(".onnx")

    out_path.parent.mkdir(parents=True, exist_ok=True)

    # NOTE: joblib uses pickle; loading untrusted data can execute arbitrary code.
    # Require explicit opt-in to avoid accidental RCE.
    if not allow_unsafe_pickle:
        raise RuntimeError(
            "Refusing to load model via joblib/pickle without explicit opt-in. "
            "Pass allow_unsafe_pickle=True (library) or --allow-unsafe-pickle (CLI)."
        )

    if model_path.suffix.lower() not in {".joblib", ".pkl"}:
        raise ValueError(f"Unexpected model suffix for pickle load: {model_path}")

    model = joblib.load(model_path)

    n_features = len(feature_cols)
    initial_types = [("float_input", FloatTensorType([None, n_features]))]

    # Ensure probabilities output is a numeric tensor (not ZipMap/sequence).
    # Setting zipmap=False on LogisticRegression reliably yields a (N,2) float tensor output.
    from sklearn.linear_model import LogisticRegression

    onx = convert_sklearn(
        model,
        initial_types=initial_types,
        target_opset=int(opset),
        options={LogisticRegression: {"zipmap": False}},
    )

    out_path.write_bytes(onx.SerializeToString())

    metadata_path = out_path.with_name(f"{out_path.stem}_metadata.json")
    metadata_path.write_text(
        json.dumps(
            {
                "model_format": "sklearn+skl2onnx",
                "model_path": str(model_path),
                "features_path": str(features_path),
                "feature_cols": feature_cols,
                "n_features": n_features,
                "opset": int(opset),
                "onnx_outputs": [o.name for o in onx.graph.output],
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )

    if verify:
        import onnxruntime as ort

        x = np.random.randn(8, n_features).astype(np.float32)

        proba_sklearn = model.predict_proba(x)[:, 1]

        sess = ort.InferenceSession(str(out_path), providers=["CPUExecutionProvider"])
        input_name = sess.get_inputs()[0].name
        outputs = {o.name: i for i, o in enumerate(sess.get_outputs())}

        if "probabilities" not in outputs:
            raise RuntimeError(f"ONNX outputs missing 'probabilities': {list(outputs)}")

        proba_onnx = sess.run(None, {input_name: x})[outputs["probabilities"]][:, 1]

        max_abs_err = float(np.max(np.abs(proba_sklearn - proba_onnx)))
        if max_abs_err > 1e-4:
            raise RuntimeError(f"ONNX parity check failed: max_abs_err={max_abs_err}")

    return ExportResult(onnx_path=out_path, metadata_path=metadata_path)


def main() -> int:
    args = parse_args()
    res = export_filter_onnx(
        Path(args.model),
        features_path=Path(args.features) if args.features else None,
        out_path=Path(args.out) if args.out else None,
        opset=int(args.opset),
        verify=bool(args.verify),
        allow_unsafe_pickle=bool(args.allow_unsafe_pickle),
    )
    print(f"Wrote ONNX: {res.onnx_path}")
    print(f"Wrote metadata: {res.metadata_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
