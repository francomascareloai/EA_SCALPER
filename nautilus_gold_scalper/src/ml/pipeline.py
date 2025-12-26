"""
Feature pipeline for ML training/inference parity.

This module ensures:
- identical feature computation between train and inference
- consistent feature order
- scaler parameters persisted and reused
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd
from sklearn.preprocessing import RobustScaler, StandardScaler

from .feature_engineering import FeatureConfig, FeatureEngineer


@dataclass
class FeaturePipeline:
    """
    End-to-end feature pipeline with scaler persistence.

    Usage:
        pipeline = FeaturePipeline()
        X_train = pipeline.fit(train_df, method="standard")
        pipeline.save("data/models/feature_pipeline.json")

        pipeline = FeaturePipeline.load("data/models/feature_pipeline.json")
        X_live = pipeline.transform(live_df)
    """

    config: FeatureConfig = field(default_factory=FeatureConfig)
    scaler_method: str | None = None
    feature_names: list[str] = field(default_factory=list)
    scaler: StandardScaler | RobustScaler | None = None
    engineer: FeatureEngineer = field(init=False)

    def __post_init__(self) -> None:
        self.engineer = FeatureEngineer(self.config)

    def fit(self, df: pd.DataFrame, method: str = "standard") -> pd.DataFrame:
        """Compute features and fit scaler on training data only."""
        features = self.engineer.compute_all_features(df)
        self.feature_names = features.columns.tolist()
        self.scaler_method = method
        scaled = self.engineer.scale_features(features, method=method, fit=True)
        self.scaler = self.engineer.scaler
        return scaled

    def transform(self, df: pd.DataFrame) -> pd.DataFrame:
        """Compute features and transform with the fitted scaler."""
        if self.scaler is None or self.scaler_method is None:
            raise ValueError("Pipeline not fitted. Call fit() or load() first.")
        if not self.feature_names:
            raise ValueError("Feature names missing. Call fit() or load() first.")

        features = self.engineer.compute_all_features(df)
        self._validate_feature_names(features.columns)
        features = features[self.feature_names]

        self.engineer.scaler = self.scaler
        return self.engineer.scale_features(features, method=self.scaler_method, fit=False)

    def to_numpy(self, df: pd.DataFrame) -> np.ndarray[Any, Any]:
        """Transform features and return numpy array for model input."""
        array_any = self.transform(df).to_numpy()
        return np.asarray(array_any)

    def save(self, path: str) -> None:
        """Save pipeline config, feature order, and scaler state to JSON."""
        if self.scaler is None or self.scaler_method is None or not self.feature_names:
            raise ValueError("Pipeline not fitted. Nothing to save.")

        state = {
            "version": 1,
            "feature_config": asdict(self.config),
            "feature_names": self.feature_names,
            "scaler": _serialize_scaler(self.scaler, self.scaler_method),
        }

        out_path = Path(path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(state, f, indent=2)

    @classmethod
    def load(cls, path: str) -> FeaturePipeline:
        """Load pipeline config, feature order, and scaler state from JSON."""
        with open(path, encoding="utf-8") as f:
            state = json.load(f)

        config = FeatureConfig(**state["feature_config"])
        pipeline = cls(config=config)
        pipeline.feature_names = list(state["feature_names"])

        scaler_state = state["scaler"]
        pipeline.scaler_method = str(scaler_state.get("method", scaler_state["type"]))
        pipeline.scaler = _deserialize_scaler(scaler_state)
        pipeline.engineer.scaler = pipeline.scaler

        return pipeline

    def _validate_feature_names(self, columns: pd.Index) -> None:
        expected = self.feature_names
        actual = list(columns)
        if actual == expected:
            return

        expected_set = set(expected)
        actual_set = set(actual)
        missing = [name for name in expected if name not in actual_set]
        extra = [name for name in actual if name not in expected_set]

        if not missing and not extra:
            raise ValueError("Feature order mismatch. Column order must match training.")

        raise ValueError(
            f"Feature mismatch. Missing: {missing or 'none'}, Extra: {extra or 'none'}."
        )


def _serialize_scaler(
    scaler: StandardScaler | RobustScaler,
    method: str,
) -> dict[str, Any]:
    if isinstance(scaler, StandardScaler):
        return {
            "type": "standard",
            "method": method,
            "mean": scaler.mean_.tolist(),
            "scale": scaler.scale_.tolist(),
            "var": scaler.var_.tolist(),
            "n_features_in": int(scaler.n_features_in_),
            "n_samples_seen": int(getattr(scaler, "n_samples_seen_", 0)),
        }

    if isinstance(scaler, RobustScaler):
        return {
            "type": "robust",
            "method": method,
            "center": scaler.center_.tolist(),
            "scale": scaler.scale_.tolist(),
            "quantile_range": list(scaler.quantile_range),
            "with_centering": bool(scaler.with_centering),
            "with_scaling": bool(scaler.with_scaling),
            "unit_variance": bool(getattr(scaler, "unit_variance", False)),
            "n_features_in": int(scaler.n_features_in_),
            "n_samples_seen": int(getattr(scaler, "n_samples_seen_", 0)),
        }

    raise ValueError(f"Unsupported scaler type: {type(scaler).__name__}")


def _deserialize_scaler(state: dict[str, Any]) -> StandardScaler | RobustScaler:
    scaler_type = state.get("type")

    if scaler_type == "standard":
        scaler = StandardScaler()
        scaler.mean_ = np.asarray(state["mean"], dtype=float)
        scaler.scale_ = np.asarray(state["scale"], dtype=float)
        scaler.var_ = np.asarray(state["var"], dtype=float)
        scaler.n_features_in_ = int(state["n_features_in"])
        # Fallback to 1 (not n_features) since n_samples_seen_ is a sample count, not feature count
        scaler.n_samples_seen_ = int(state.get("n_samples_seen", 1))
        return scaler

    if scaler_type == "robust":
        scaler = RobustScaler(
            with_centering=bool(state.get("with_centering", True)),
            with_scaling=bool(state.get("with_scaling", True)),
            quantile_range=tuple(state.get("quantile_range", (25.0, 75.0))),
            unit_variance=bool(state.get("unit_variance", False)),
        )
        scaler.center_ = np.asarray(state["center"], dtype=float)
        scaler.scale_ = np.asarray(state["scale"], dtype=float)
        scaler.n_features_in_ = int(state["n_features_in"])
        # Fallback to 1 (not n_features) since n_samples_seen_ is a sample count, not feature count
        scaler.n_samples_seen_ = int(state.get("n_samples_seen", 1))
        return scaler

    raise ValueError(f"Unsupported scaler type in state: {scaler_type}")
