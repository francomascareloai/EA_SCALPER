"""
ML Model Trainer for XAUUSD Gold Scalping.
STREAM G - Machine Learning (Part 2)

Provides training infrastructure for trading ML models:
- Walk-Forward Analysis (WFA) training
- Purged K-Fold cross-validation
- Model serialization (ONNX-only)
- Training metrics tracking
- Early stopping with patience
"""

from __future__ import annotations

import json
import logging
import warnings
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")
logger = logging.getLogger(__name__)

try:
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.linear_model import LogisticRegression
    from sklearn.metrics import (
        accuracy_score,
        f1_score,
        log_loss,
        precision_score,
        recall_score,
        roc_auc_score,
    )

    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False

try:
    import lightgbm as lgb

    HAS_LIGHTGBM = True
except ImportError:
    HAS_LIGHTGBM = False

try:
    import xgboost as xgb

    HAS_XGBOOST = True
except ImportError:
    HAS_XGBOOST = False

try:
    import onnx
    import onnxmltools
    import onnxruntime as ort
    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType

    HAS_ONNX = True
except ImportError:
    HAS_ONNX = False
    logger.warning(
        "ONNX libraries not available. Install with: pip install onnx onnxruntime onnxmltools skl2onnx"
    )


@dataclass
class TrainingConfig:
    """Configuration for model training."""

    # Cross-validation
    n_splits: int = 5
    gap: int = 10  # Gap between train/test to prevent leakage

    # Walk-forward
    wf_train_size: int = 5000  # Bars for training
    wf_test_size: int = 500  # Bars for testing
    wf_step_size: int = 250  # Step between folds

    # Training
    early_stopping_rounds: int = 50
    validation_fraction: float = 0.2
    random_state: int = 42

    # Output
    model_dir: str = "data/models"
    save_onnx: bool = True


@dataclass
class TrainingResult:
    """Results from model training."""

    model_name: str
    accuracy: float
    precision: float
    recall: float
    f1: float
    auc: float = 0.0
    log_loss_val: float = 0.0

    # Walk-forward metrics
    wf_efficiency: float = 0.0  # OOS vs IS performance ratio
    oos_sharpe: float = 0.0

    # Training details
    train_samples: int = 0
    test_samples: int = 0
    n_features: int = 0
    training_time_seconds: float = 0.0

    fold_results: list[dict[str, Any]] = field(default_factory=list)
    feature_importance: dict[str, float] = field(default_factory=dict)

    timestamp: datetime | None = None
    model_path: str | None = None


class PurgedTimeSeriesSplit:
    """
    Time series cross-validation with purging.

    Prevents look-ahead bias by ensuring a gap between
    training and test sets.
    """

    def __init__(self, n_splits: int = 5, gap: int = 10):
        self.n_splits = n_splits
        self.gap = gap

    def split(
        self, X: np.ndarray[Any, Any]
    ) -> list[tuple[np.ndarray[Any, Any], np.ndarray[Any, Any]]]:
        """Generate train/test indices with purging."""
        n = len(X)
        test_size = n // (self.n_splits + 1)

        splits = []
        for i in range(self.n_splits):
            test_start = (i + 1) * test_size
            test_end = test_start + test_size

            if test_end > n:
                test_end = n

            # Train up to gap before test
            train_end = test_start - self.gap

            if train_end <= 0:
                continue

            train_idx = np.arange(0, train_end)
            test_idx = np.arange(test_start, test_end)

            splits.append((train_idx, test_idx))

        return splits


class WalkForwardValidator:
    """
    Walk-Forward Analysis validator.

    Simulates realistic trading conditions by training on
    historical data and testing on subsequent out-of-sample period.
    """

    def __init__(
        self,
        train_size: int = 5000,
        test_size: int = 500,
        step_size: int = 250,
        gap: int = 10,
    ):
        self.train_size = train_size
        self.test_size = test_size
        self.step_size = step_size
        self.gap = gap

    def split(
        self, X: np.ndarray[Any, Any]
    ) -> list[tuple[np.ndarray[Any, Any], np.ndarray[Any, Any]]]:
        """Generate walk-forward train/test indices."""
        n = len(X)
        splits = []

        start = 0
        while True:
            train_end = start + self.train_size
            test_start = train_end + self.gap
            test_end = test_start + self.test_size

            if test_end > n:
                break

            train_idx = np.arange(start, train_end)
            test_idx = np.arange(test_start, test_end)

            splits.append((train_idx, test_idx))

            start += self.step_size

        return splits


class ModelTrainer:
    """
    Comprehensive ML model trainer for trading strategies.

    Features:
    - Multiple model types (RF, XGB, LGB, etc.)
    - Walk-Forward Analysis
    - Purged cross-validation
    - Feature importance tracking
    - Model serialization
    """

    def __init__(self, config: TrainingConfig | None = None):
        self.config = config or TrainingConfig()
        self._models: dict[str, Any] = {}
        self._results: dict[str, TrainingResult] = {}

        # Create model directory
        Path(self.config.model_dir).mkdir(parents=True, exist_ok=True)

    def train_classifier(
        self,
        X: np.ndarray[Any, Any],
        y: np.ndarray[Any, Any],
        model_type: str = "lightgbm",
        feature_names: list[str] | None = None,
        **kwargs: Any,
    ) -> TrainingResult:
        """
        Train a classification model.

        Args:
            X: Feature matrix (n_samples, n_features)
            y: Target labels (0/1 for direction)
            model_type: One of 'lightgbm', 'xgboost', 'random_forest', 'logistic'
            feature_names: Optional feature names for importance tracking
            **kwargs: Additional model parameters

        Returns:
            TrainingResult with metrics and model path
        """
        import time

        start_time = time.time()

        # Get model
        model = self._create_model(model_type, **kwargs)

        if model is None:
            raise ValueError(f"Unknown model type: {model_type}")

        # Walk-forward validation
        wf_validator = WalkForwardValidator(
            train_size=self.config.wf_train_size,
            test_size=self.config.wf_test_size,
            step_size=self.config.wf_step_size,
            gap=self.config.gap,
        )

        splits = wf_validator.split(X)

        if len(splits) == 0:
            # Fall back to purged time series split
            purged_cv = PurgedTimeSeriesSplit(
                n_splits=self.config.n_splits,
                gap=self.config.gap,
            )
            splits = purged_cv.split(X)

        # Collect results across folds
        fold_results = []
        is_accuracies = []
        oos_accuracies = []

        for fold_idx, (train_idx, test_idx) in enumerate(splits):
            X_train, X_test = X[train_idx], X[test_idx]
            y_train, y_test = y[train_idx], y[test_idx]

            # Train
            if model_type == "lightgbm" and HAS_LIGHTGBM:
                model = self._train_lightgbm(X_train, y_train, X_test, y_test, **kwargs)
            elif model_type == "xgboost" and HAS_XGBOOST:
                model = self._train_xgboost(X_train, y_train, X_test, y_test, **kwargs)
            else:
                model.fit(X_train, y_train)

            # Evaluate
            train_pred = model.predict(X_train)
            test_pred = model.predict(X_test)

            train_acc = accuracy_score(y_train, train_pred)
            test_acc = accuracy_score(y_test, test_pred)

            is_accuracies.append(train_acc)
            oos_accuracies.append(test_acc)

            # Detailed metrics for test set
            fold_result = {
                "fold": fold_idx,
                "train_size": len(train_idx),
                "test_size": len(test_idx),
                "train_acc": train_acc,
                "test_acc": test_acc,
                "test_precision": precision_score(y_test, test_pred, zero_division=0),
                "test_recall": recall_score(y_test, test_pred, zero_division=0),
                "test_f1": f1_score(y_test, test_pred, zero_division=0),
            }

            # AUC if probabilities available
            if hasattr(model, "predict_proba"):
                try:
                    test_proba = model.predict_proba(X_test)[:, 1]
                    fold_result["test_auc"] = roc_auc_score(y_test, test_proba)
                    fold_result["test_logloss"] = log_loss(y_test, test_proba)
                except Exception:
                    logger.warning(
                        "Metrics calculation failed for fold %s",
                        fold_idx + 1,
                        exc_info=True,
                    )

            fold_results.append(fold_result)

        # Aggregate metrics
        avg_metrics = self._aggregate_fold_metrics(fold_results)

        # Calculate WF efficiency
        mean_is = float(np.mean(is_accuracies))
        mean_oos = float(np.mean(oos_accuracies))
        wf_efficiency = mean_oos / mean_is if mean_is > 0.0 else 0.0

        # Retrain on full data for final model
        final_model = self._create_model(model_type, **kwargs)
        if model_type == "lightgbm" and HAS_LIGHTGBM:
            val_size = int(len(X) * self.config.validation_fraction)
            final_model = self._train_lightgbm(
                X[:-val_size], y[:-val_size], X[-val_size:], y[-val_size:], **kwargs
            )
        elif model_type == "xgboost" and HAS_XGBOOST:
            val_size = int(len(X) * self.config.validation_fraction)
            final_model = self._train_xgboost(
                X[:-val_size], y[:-val_size], X[-val_size:], y[-val_size:], **kwargs
            )
        else:
            final_model.fit(X, y)

        # Feature importance
        feature_importance = self._get_feature_importance(
            final_model, feature_names or [f"f{i}" for i in range(X.shape[1])]
        )

        # Save model
        model_path = self._save_model(final_model, model_type)

        training_time = time.time() - start_time

        result = TrainingResult(
            model_name=model_type,
            accuracy=avg_metrics["accuracy"],
            precision=avg_metrics["precision"],
            recall=avg_metrics["recall"],
            f1=avg_metrics["f1"],
            auc=avg_metrics.get("auc", 0.0),
            log_loss_val=avg_metrics.get("logloss", 0.0),
            wf_efficiency=wf_efficiency,
            train_samples=len(X),
            test_samples=self.config.wf_test_size * len(splits),
            n_features=X.shape[1],
            training_time_seconds=training_time,
            fold_results=fold_results,
            feature_importance=feature_importance,
            timestamp=datetime.now(),
            model_path=model_path,
        )

        self._models[model_type] = final_model
        self._results[model_type] = result

        return result

    def _create_model(self, model_type: str, **kwargs: Any) -> Any:
        """Create a model instance."""
        if model_type == "lightgbm" and HAS_LIGHTGBM:
            model_params: dict[str, Any] = {
                "objective": "binary",
                "metric": "binary_logloss",
                "boosting_type": "gbdt",
                "num_leaves": 31,
                "learning_rate": 0.05,
                "feature_fraction": 0.8,
                "bagging_fraction": 0.8,
                "bagging_freq": 5,
                "verbose": -1,
                "random_state": self.config.random_state,
            }
            model_params.update(kwargs)
            return lgb.LGBMClassifier(**model_params)

        elif model_type == "xgboost" and HAS_XGBOOST:
            xgb_params: dict[str, Any] = {
                "objective": "binary:logistic",
                "eval_metric": "logloss",
                "max_depth": 6,
                "learning_rate": 0.05,
                "subsample": 0.8,
                "colsample_bytree": 0.8,
                "random_state": self.config.random_state,
                "verbosity": 0,
            }
            xgb_params.update(kwargs)
            return xgb.XGBClassifier(**xgb_params)

        elif model_type == "random_forest" and HAS_SKLEARN:
            rf_params: dict[str, Any] = {
                "n_estimators": 100,
                "max_depth": 10,
                "min_samples_split": 5,
                "min_samples_leaf": 2,
                "random_state": self.config.random_state,
                "n_jobs": -1,
            }
            rf_params.update(kwargs)
            return RandomForestClassifier(**rf_params)

        elif model_type == "logistic" and HAS_SKLEARN:
            lr_params: dict[str, Any] = {
                "penalty": "l2",
                "C": 1.0,
                "max_iter": 1000,
                "random_state": self.config.random_state,
            }
            lr_params.update(kwargs)
            return LogisticRegression(**lr_params)

        return None

    def _train_lightgbm(
        self,
        X_train: np.ndarray[Any, Any],
        y_train: np.ndarray[Any, Any],
        X_val: np.ndarray[Any, Any],
        y_val: np.ndarray[Any, Any],
        **kwargs: Any,
    ) -> Any:
        """Train LightGBM with early stopping."""
        if not HAS_LIGHTGBM:
            raise ImportError("LightGBM not installed")

        model = self._create_model("lightgbm", **kwargs)

        model.fit(
            X_train,
            y_train,
            eval_set=[(X_val, y_val)],
            callbacks=[
                lgb.early_stopping(stopping_rounds=self.config.early_stopping_rounds),
                lgb.log_evaluation(period=0),  # Disable logging
            ],
        )

        return model

    def _train_xgboost(
        self,
        X_train: np.ndarray[Any, Any],
        y_train: np.ndarray[Any, Any],
        X_val: np.ndarray[Any, Any],
        y_val: np.ndarray[Any, Any],
        **kwargs: Any,
    ) -> Any:
        """Train XGBoost with early stopping."""
        if not HAS_XGBOOST:
            raise ImportError("XGBoost not installed")

        model = self._create_model("xgboost", **kwargs)

        model.fit(
            X_train,
            y_train,
            eval_set=[(X_val, y_val)],
            early_stopping_rounds=self.config.early_stopping_rounds,
            verbose=False,
        )

        return model

    def _aggregate_fold_metrics(self, fold_results: list[dict[str, Any]]) -> dict[str, float]:
        """Aggregate metrics across folds."""
        metrics: dict[str, float] = {
            "accuracy": float(np.mean([f["test_acc"] for f in fold_results])),
            "precision": float(np.mean([f["test_precision"] for f in fold_results])),
            "recall": float(np.mean([f["test_recall"] for f in fold_results])),
            "f1": float(np.mean([f["test_f1"] for f in fold_results])),
        }

        if "test_auc" in fold_results[0]:
            metrics["auc"] = float(np.mean([f.get("test_auc", 0.0) for f in fold_results]))

        if "test_logloss" in fold_results[0]:
            metrics["logloss"] = float(np.mean([f.get("test_logloss", 0.0) for f in fold_results]))

        return metrics

    def _get_feature_importance(
        self,
        model: Any,
        feature_names: list[str],
    ) -> dict[str, float]:
        """Extract feature importance from model."""
        importance: dict[str, float] = {}

        if hasattr(model, "feature_importances_"):
            imp = model.feature_importances_
            for name, val in zip(feature_names, imp, strict=True):
                importance[name] = float(val)

        elif hasattr(model, "coef_"):
            imp = np.abs(model.coef_).flatten()
            for name, val in zip(feature_names, imp, strict=True):
                importance[name] = float(val)

        # Sort by importance
        importance = dict(sorted(importance.items(), key=lambda x: x[1], reverse=True))

        return importance

    def _save_model(self, model: Any, model_type: str) -> str:
        """Save model to disk in ONNX format.

        Security: pickle serialization is disabled (RCE risk). If ONNX export is not
        available, the caller must handle persistence outside this module.
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        if not self.config.save_onnx:
            raise RuntimeError("Model persistence disabled (save_onnx=False)")

        if not HAS_ONNX:
            raise RuntimeError("ONNX libraries not installed; cannot save model safely")

        filename = f"{model_type}_{timestamp}.onnx"
        filepath = Path(self.config.model_dir) / filename

        try:
            self._save_model_onnx(model, str(filepath), model_type)
        except Exception as e:
            raise RuntimeError(f"ONNX export failed for {model_type}: {e}") from e

        logger.info(f"Model saved to ONNX: {filepath}")
        return str(filepath)

    def _save_model_onnx(self, model: Any, filepath: str, model_type: str) -> None:
        """
        Export model to ONNX format.

        Supports LightGBM, XGBoost, and sklearn models.
        """
        if not HAS_ONNX:
            raise ImportError("ONNX libraries not installed")

        # Get number of features from model
        if hasattr(model, "n_features_in_"):
            n_features = model.n_features_in_
        elif hasattr(model, "_n_features"):
            n_features = model._n_features
        else:
            raise ValueError("Cannot determine number of features from model")

        # Define initial type for ONNX conversion
        initial_type = [("float_input", FloatTensorType([None, n_features]))]

        if model_type == "lightgbm" and HAS_LIGHTGBM:
            # Convert LightGBM to ONNX
            onnx_model = onnxmltools.convert_lightgbm(
                model, initial_types=initial_type, target_opset=12
            )
        elif model_type == "xgboost" and HAS_XGBOOST:
            # Convert XGBoost to ONNX
            onnx_model = onnxmltools.convert_xgboost(
                model, initial_types=initial_type, target_opset=12
            )
        elif model_type in ["random_forest", "logistic"] and HAS_SKLEARN:
            # Convert sklearn model to ONNX
            onnx_model = convert_sklearn(model, initial_types=initial_type, target_opset=12)
        else:
            raise ValueError(f"Unsupported model type for ONNX: {model_type}")

        # Save ONNX model
        onnxmltools.utils.save_model(onnx_model, filepath)

        # Save metadata as JSON
        metadata = {
            "model_type": model_type,
            "n_features": n_features,
            "timestamp": datetime.now().isoformat(),
            "onnx_version": onnx.__version__,
        }

        metadata_path = filepath.replace(".onnx", "_metadata.json")
        with open(metadata_path, "w") as f:
            json.dump(metadata, f, indent=2)

    def load_model(self, model_path: str) -> Any:
        """Load model from disk.

        Security: pickle deserialization is disabled (RCE risk). Only ONNX models are
        supported.
        """
        path = Path(model_path)

        if path.suffix != ".onnx":
            raise ValueError(f"Unsupported model format: {path.suffix} (expected .onnx)")

        if not HAS_ONNX:
            raise RuntimeError("ONNX libraries not installed; cannot load model")

        return self._load_model_onnx(str(path))

    def _load_model_onnx(self, filepath: str) -> ort.InferenceSession:
        """
        Load ONNX model for inference.

        Returns an ONNX Runtime InferenceSession.
        """
        if not HAS_ONNX:
            raise ImportError("ONNX libraries not installed")

        # Load metadata
        metadata_path = filepath.replace(".onnx", "_metadata.json")
        metadata = {}
        if Path(metadata_path).exists():
            with open(metadata_path) as f:
                metadata = json.load(f)

        # Create ONNX Runtime session
        sess_options = ort.SessionOptions()
        sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL

        session = ort.InferenceSession(
            filepath, sess_options=sess_options, providers=["CPUExecutionProvider"]
        )

        # NOTE: onnxruntime.InferenceSession is implemented in C and doesn't support
        # attaching arbitrary attributes reliably across versions.
        # Return both session and metadata via a separate lookup if needed.

        return session

    def get_model(self, model_type: str) -> Any | None:
        """Get a trained model by type."""
        return self._models.get(model_type)

    def get_result(self, model_type: str) -> TrainingResult | None:
        """Get training result by model type."""
        return self._results.get(model_type)

    def compare_models(self) -> pd.DataFrame:
        """Compare all trained models."""
        if not self._results:
            return pd.DataFrame()

        data = []
        for name, result in self._results.items():
            data.append(
                {
                    "model": name,
                    "accuracy": result.accuracy,
                    "precision": result.precision,
                    "recall": result.recall,
                    "f1": result.f1,
                    "auc": result.auc,
                    "wf_efficiency": result.wf_efficiency,
                    "training_time": result.training_time_seconds,
                }
            )

        return pd.DataFrame(data).sort_values("f1", ascending=False)
