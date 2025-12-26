"""
Ensemble Predictor for XAUUSD Gold Scalping.
STREAM G - Machine Learning (Part 3)

Combines multiple ML models for robust predictions:
- Weighted voting ensemble
- Stacking ensemble
- Regime-conditional model selection
- Confidence calibration
"""

from __future__ import annotations

import json
import logging
from dataclasses import asdict, dataclass, field

# NOTE: Avoid datetime.now() usage here to keep backtests deterministic.
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

import numpy as np

if TYPE_CHECKING:
    from ..core.definitions import MarketRegime, SignalType
else:
    try:
        from ..core.definitions import MarketRegime, SignalType
    except ImportError:  # Allow import when src/ is placed on sys.path (tests do this)
        from core.definitions import MarketRegime, SignalType

logger = logging.getLogger(__name__)

try:
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
class EnsemblePrediction:
    """Result from ensemble prediction."""

    signal: SignalType
    probability: float  # 0-1, probability of predicted direction
    confidence: float  # 0-1, model confidence

    # Individual model predictions
    model_predictions: dict[str, float] = field(default_factory=dict)

    # Metadata
    regime: MarketRegime | None = None
    ensemble_type: str = "weighted_voting"
    timestamp: datetime | None = None

    @property
    def is_valid(self) -> bool:
        """Check if prediction meets confidence threshold."""
        return self.confidence >= 0.6 and self.probability >= 0.55


@dataclass
class EnsembleConfig:
    """Configuration for ensemble predictor."""

    # Model weights (must sum to 1.0)
    model_weights: dict[str, float] = field(
        default_factory=lambda: {
            "lightgbm": 0.4,
            "xgboost": 0.35,
            "random_forest": 0.25,
        }
    )

    # Thresholds
    min_probability: float = 0.55  # Min probability to generate signal
    min_confidence: float = 0.60  # Min confidence to act on signal

    # Regime-specific adjustments
    regime_weights: dict[str, dict[str, float]] = field(
        default_factory=lambda: {
            "REGIME_PRIME_TRENDING": {"lightgbm": 0.5, "xgboost": 0.35, "random_forest": 0.15},
            "REGIME_NOISY_TRENDING": {"lightgbm": 0.4, "xgboost": 0.4, "random_forest": 0.2},
            "REGIME_PRIME_REVERTING": {"lightgbm": 0.35, "xgboost": 0.35, "random_forest": 0.3},
            "REGIME_NOISY_REVERTING": {"lightgbm": 0.4, "xgboost": 0.35, "random_forest": 0.25},
        }
    )

    # Confidence calibration
    use_calibration: bool = True
    calibration_method: str = "isotonic"  # or "platt"


class EnsemblePredictor:
    """
    Ensemble predictor combining multiple ML models.

    Features:
    - Weighted voting across models
    - Regime-adaptive weight adjustment
    - Confidence calibration
    - Disagreement detection

    Input contract:
    - `features` must match the trained feature count for the ensemble.
    """

    def __init__(self, config: EnsembleConfig | None = None):
        self.config = config or EnsembleConfig()
        self._models: dict[str, Any] = {}
        self._calibrators: dict[str, Any] = {}
        self._is_fitted = False
        self._n_features: int | None = None

    def add_model(self, name: str, model: Any, weight: float | None = None) -> None:
        """
        Add a model to the ensemble.

        Args:
            name: Model identifier
            model: Trained model with predict_proba method
            weight: Optional weight override
        """
        self._models[name] = model

        n_features = self._infer_n_features(model)
        if n_features is not None:
            if self._n_features is None:
                self._n_features = n_features
            elif self._n_features != n_features:
                raise ValueError(
                    f"Inconsistent n_features across models: {self._n_features} vs {n_features}"
                )

        if weight is not None:
            self.config.model_weights[name] = weight
        elif name not in self.config.model_weights:
            # Default equal weight
            n_models = len(self._models)
            if n_models == 0:
                default_weight = 1.0  # R13-FIX: avoid division by zero (defensive)
            else:
                default_weight = 1.0 / n_models
            self.config.model_weights[name] = default_weight

        # Normalize weights
        self._normalize_weights()

        self._is_fitted = True

    def _normalize_weights(self) -> None:
        """Normalize model weights to sum to 1.0."""
        total = sum(self.config.model_weights.values())
        if total > 0:
            for name in self.config.model_weights:
                self.config.model_weights[name] /= total

    def _infer_n_features(self, model: Any) -> int | None:
        if hasattr(model, "n_features_in_"):
            try:
                return int(model.n_features_in_)
            except Exception:
                return None

        # ONNX Runtime session
        if HAS_ONNX and isinstance(model, ort.InferenceSession):
            try:
                shape = model.get_inputs()[0].shape
                if len(shape) >= 2 and shape[1] is not None:
                    return int(shape[1])
            except Exception:
                return None

        return None

    def predict(
        self,
        features: np.ndarray[Any, Any],
        regime: MarketRegime | None = None,
    ) -> EnsemblePrediction:
        """
        Generate ensemble prediction.

        Args:
            features: Feature vector or matrix (n_samples, n_features)
            regime: Current market regime for adaptive weighting

        Returns:
            EnsemblePrediction with signal, probability, and confidence
        """
        if not self._is_fitted or len(self._models) == 0:
            return EnsemblePrediction(
                signal=SignalType.SIGNAL_NONE,
                probability=0.5,
                confidence=0.0,
            )

        # Ensure 2D
        if features.ndim == 1:
            features = features.reshape(1, -1)

        # Validate feature shape (prevent runtime misalignment)
        if self._n_features is not None and int(features.shape[1]) != int(self._n_features):
            raise ValueError(
                f"Invalid features shape: expected n_features={self._n_features}, got {features.shape[1]}"
            )

        # Get weights for current regime
        weights = self._get_regime_weights(regime)

        # Collect predictions from all models
        model_probs: dict[str, float] = {}
        model_preds: dict[str, int] = {}

        for name, model in self._models.items():
            if name not in weights:
                continue

            try:
                # Check if model is ONNX Runtime session
                if HAS_ONNX and isinstance(model, ort.InferenceSession):
                    # ONNX inference
                    input_name = model.get_inputs()[0].name

                    # Run inference (request all outputs; different converters name outputs differently)
                    outputs = model.run(
                        None,
                        {input_name: features.astype(np.float32)},
                    )

                    # Extract probability from a (N,2) tensor output when available.
                    onnx_output = None
                    for out in outputs:
                        try:
                            if (
                                hasattr(out, "shape")
                                and len(out.shape) == 2
                                and int(out.shape[1]) == 2
                            ):
                                onnx_output = out
                                break
                        except Exception:
                            continue
                    if onnx_output is None:
                        onnx_output = outputs[0]

                    if (
                        hasattr(onnx_output, "shape")
                        and len(onnx_output.shape) == 2
                        and int(onnx_output.shape[1]) >= 2
                    ):
                        prob = float(onnx_output[0, 1])  # Probability of class 1
                    else:
                        prob = float(onnx_output[0, 0])

                    # Calibrate if enabled
                    if self.config.use_calibration and name in self._calibrators:
                        prob = self._calibrate_probability(name, prob)

                    model_probs[name] = prob
                    model_preds[name] = 1 if prob >= 0.5 else 0

                elif hasattr(model, "predict_proba"):
                    # Sklearn-style model
                    proba = model.predict_proba(features)
                    # Take probability of class 1 (BUY direction)
                    if proba.shape[1] == 2:
                        prob = float(proba[0, 1])
                    else:
                        prob = float(proba[0, 0])

                    # Calibrate if enabled
                    if self.config.use_calibration and name in self._calibrators:
                        prob = self._calibrate_probability(name, prob)

                    model_probs[name] = prob
                    model_preds[name] = 1 if prob >= 0.5 else 0
                else:
                    # Simple predict method
                    pred = model.predict(features)
                    model_preds[name] = int(pred[0])
                    model_probs[name] = float(pred[0])
            except Exception:
                # Skip failed models
                logger.debug("Model %s prediction failed", name, exc_info=True)
                continue

        if not model_probs:
            return EnsemblePrediction(
                signal=SignalType.SIGNAL_NONE,
                probability=0.5,
                confidence=0.0,
            )

        # Weighted voting
        weighted_prob = 0.0
        total_weight = 0.0

        for name, prob in model_probs.items():
            w = weights.get(name, 0.0)
            weighted_prob += prob * w
            total_weight += w

        if total_weight > 0:
            weighted_prob /= total_weight
        else:
            weighted_prob = 0.5

        # Calculate confidence based on model agreement
        confidence = self._calculate_confidence(model_probs, weights)

        # Determine signal
        signal = SignalType.SIGNAL_NONE
        if weighted_prob >= self.config.min_probability:
            signal = SignalType.SIGNAL_BUY
        elif weighted_prob <= (1 - self.config.min_probability):
            signal = SignalType.SIGNAL_SELL

        # If confidence too low, no signal
        if confidence < self.config.min_confidence:
            signal = SignalType.SIGNAL_NONE

        return EnsemblePrediction(
            signal=signal,
            probability=weighted_prob,
            confidence=confidence,
            model_predictions=model_probs,
            regime=regime,
            ensemble_type="weighted_voting",
            timestamp=None,
        )

    def _get_regime_weights(self, regime: MarketRegime | None) -> dict[str, float]:
        """Get model weights adjusted for current regime."""
        if regime is None:
            return self.config.model_weights.copy()

        regime_name = regime.name

        if regime_name in self.config.regime_weights:
            return self.config.regime_weights[regime_name].copy()

        return self.config.model_weights.copy()

    def _calculate_confidence(
        self,
        model_probs: dict[str, float],
        weights: dict[str, float],
    ) -> float:
        """
        Calculate confidence based on model agreement and certainty.

        High confidence when:
        - Models agree on direction
        - Individual probabilities are far from 0.5
        """
        if len(model_probs) < 2:
            # Single model - use probability distance from 0.5
            prob = list(model_probs.values())[0]
            return abs(prob - 0.5) * 2

        # Agreement factor: how much models agree
        probs = list(model_probs.values())
        directions = [1 if p >= 0.5 else 0 for p in probs]
        agreement = sum(directions) / len(directions)
        agreement_score = 2 * abs(agreement - 0.5)  # 0 when 50/50, 1 when unanimous

        # Certainty factor: average distance from 0.5
        certainty = float(np.mean([abs(p - 0.5) for p in probs])) * 2.0

        # Variance factor: lower variance = higher confidence
        variance = float(np.std(probs))
        variance_score = max(0.0, 1.0 - variance * 4.0)  # Penalize high variance

        # Combined confidence
        confidence = 0.4 * agreement_score + 0.4 * certainty + 0.2 * variance_score

        return float(min(1.0, max(0.0, confidence)))

    def _calibrate_probability(self, model_name: str, probability: float) -> float:
        """Calibrate probability using stored calibrator."""
        if model_name not in self._calibrators:
            return probability

        calibrator = self._calibrators[model_name]

        try:
            # IsotonicRegression exposes predict(), LogisticRegression exposes predict_proba().
            if hasattr(calibrator, "predict_proba"):
                calibrated = calibrator.predict_proba([[probability]])[0, 1]
                return float(calibrated)
            calibrated_any = calibrator.predict([probability])
            return float(calibrated_any[0])
        except Exception:
            logger.warning("Calibration failed", exc_info=True)
            return probability

    def fit_calibration(
        self,
        X: np.ndarray[Any, Any],
        y: np.ndarray[Any, Any],
    ) -> None:
        """
        Fit probability calibrators for each model.

        Args:
            X: Validation features
            y: True labels
        """
        try:
            if self.config.calibration_method == "isotonic":
                from sklearn.isotonic import IsotonicRegression

                calibrator_kind = "isotonic"
                IsotonicClass = IsotonicRegression
            else:
                from sklearn.linear_model import LogisticRegression

                calibrator_kind = "platt"
                PlattClass = LogisticRegression
        except ImportError:
            return

        for name, model in self._models.items():
            if not hasattr(model, "predict_proba"):
                continue

            try:
                probs = model.predict_proba(X)[:, 1]

                if calibrator_kind == "isotonic":
                    calibrator = IsotonicClass(out_of_bounds="clip")
                    calibrator.fit(probs, y)
                else:
                    calibrator = PlattClass()
                    calibrator.fit(probs.reshape(-1, 1), y)

                self._calibrators[name] = calibrator
            except Exception:
                logger.warning("Calibrator training failed for %s", name, exc_info=True)
                continue

    def predict_with_uncertainty(
        self,
        features: np.ndarray[Any, Any],
        regime: MarketRegime | None = None,
        n_bootstrap: int = 100,
    ) -> tuple[EnsemblePrediction, float, float]:
        """
        Predict with uncertainty estimation via bootstrap.

        Returns:
            Tuple of (prediction, lower_bound, upper_bound) for probability
        """
        base_pred = self.predict(features, regime)

        if n_bootstrap <= 0:
            return base_pred, base_pred.probability, base_pred.probability

        # Bootstrap predictions by randomly weighting models
        bootstrap_probs = []

        for _ in range(n_bootstrap):
            # Random perturbation of weights
            perturbed_weights = {}
            for name, w in self.config.model_weights.items():
                perturbed_weights[name] = w * np.random.uniform(0.8, 1.2)

            # Normalize
            total = sum(perturbed_weights.values())
            if total == 0.0:
                # R13-FIX: avoid division by zero if all weights are zero
                n_models = len(perturbed_weights)
                if n_models == 0:
                    perturbed_weights = {}
                else:
                    perturbed_weights = dict.fromkeys(perturbed_weights, 1.0 / n_models)
            else:
                for name in perturbed_weights:
                    perturbed_weights[name] /= total

            # Predict with perturbed weights
            weighted_prob = 0.0
            for name, prob in base_pred.model_predictions.items():
                weighted_prob += prob * perturbed_weights.get(name, 0.0)

            bootstrap_probs.append(weighted_prob)

        lower = np.percentile(bootstrap_probs, 2.5)
        upper = np.percentile(bootstrap_probs, 97.5)

        return base_pred, float(lower), float(upper)

    def get_model_disagreement(
        self,
        features: np.ndarray[Any, Any],
    ) -> dict[str, Any]:
        """
        Analyze model disagreement for given features.

        Useful for identifying uncertain market conditions.
        """
        pred = self.predict(features)

        probs = list(pred.model_predictions.values())

        if len(probs) < 2:
            return {
                "disagreement_score": 0.0,
                "max_diff": 0.0,
                "std": 0.0,
                "unanimous": True,
            }

        directions = [1 if p >= 0.5 else 0 for p in probs]
        unanimous = len(set(directions)) == 1

        return {
            "disagreement_score": np.std(probs),
            "max_diff": max(probs) - min(probs),
            "std": np.std(probs),
            "unanimous": unanimous,
            "model_directions": {
                name: "BUY" if p >= 0.5 else "SELL" for name, p in pred.model_predictions.items()
            },
        }

    def save(self, filepath: str) -> None:
        """
        Save ensemble to disk using ONNX and JSON.

        Saves:
        - Config as JSON
        - Each model as ONNX

        Security: pickle serialization is disabled.
        """
        base_path = Path(filepath)
        base_dir = base_path.parent
        base_name = base_path.stem

        # Create directory for ensemble
        ensemble_dir = base_dir / base_name
        ensemble_dir.mkdir(parents=True, exist_ok=True)

        # Save config as JSON
        config_path = ensemble_dir / "config.json"
        config_dict = asdict(self.config)
        with open(config_path, "w") as f:
            json.dump(config_dict, f, indent=2)

        # Save each model as ONNX
        if HAS_ONNX:
            models_dir = ensemble_dir / "models"
            models_dir.mkdir(exist_ok=True)

            for model_name, model in self._models.items():
                try:
                    onnx_path = models_dir / f"{model_name}.onnx"
                    self._save_model_onnx(model, str(onnx_path), model_name)
                    logger.info(f"Saved {model_name} to ONNX: {onnx_path}")
                except Exception as e:
                    raise RuntimeError(f"Failed to save {model_name} to ONNX: {e}") from e
        else:
            raise RuntimeError("ONNX not available; cannot save models safely")

        if self._calibrators:
            logger.warning("Skipping calibrator persistence (pickle disabled)")

        logger.info(f"Ensemble saved to: {ensemble_dir}")

    def _save_model_onnx(self, model: Any, filepath: str, model_name: str) -> None:
        """Export a single model to ONNX format."""
        if not HAS_ONNX:
            raise ImportError("ONNX libraries not installed")

        # Get number of features
        if hasattr(model, "n_features_in_"):
            n_features = model.n_features_in_
        elif hasattr(model, "_n_features"):
            n_features = model._n_features
        else:
            # Try to infer from first prediction attempt
            raise ValueError(f"Cannot determine number of features for {model_name}")

        # Define initial type
        initial_type = [("float_input", FloatTensorType([None, n_features]))]

        # Detect model type and convert
        model_type = type(model).__name__

        try:
            import lightgbm as lgb

            if isinstance(model, lgb.LGBMClassifier) or isinstance(model, lgb.Booster):
                onnx_model = onnxmltools.convert_lightgbm(
                    model, initial_types=initial_type, target_opset=12
                )
                onnxmltools.utils.save_model(onnx_model, filepath)
                return
        except ImportError:
            pass

        try:
            import xgboost as xgb

            if isinstance(model, xgb.XGBClassifier) or isinstance(model, xgb.Booster):
                onnx_model = onnxmltools.convert_xgboost(
                    model, initial_types=initial_type, target_opset=12
                )
                onnxmltools.utils.save_model(onnx_model, filepath)
                return
        except ImportError:
            pass

        # Try sklearn conversion
        try:
            from sklearn.base import BaseEstimator

            if isinstance(model, BaseEstimator):
                onnx_model = convert_sklearn(model, initial_types=initial_type, target_opset=12)
                onnxmltools.utils.save_model(onnx_model, filepath)
                return
        except ImportError:
            pass

        raise ValueError(f"Unsupported model type for ONNX: {model_type}")

    @classmethod
    def load(cls, filepath: str) -> EnsemblePredictor:
        """
        Load ensemble from disk.

        Tries ONNX + JSON first, falls back to pickle with warning.
        """
        base_path = Path(filepath)

        # Check if it's a directory (new format)
        if base_path.is_dir():
            ensemble_dir = base_path
        else:
            # Try to find directory version
            ensemble_dir = base_path.parent / base_path.stem
            if not ensemble_dir.exists():
                raise FileNotFoundError(f"Ensemble directory not found: {ensemble_dir}")

        # Load config from JSON
        config_path = ensemble_dir / "config.json"
        if not config_path.exists():
            raise FileNotFoundError(f"Missing config.json in ensemble dir: {ensemble_dir}")

        with open(config_path) as f:
            config_dict = json.load(f)

        config = EnsembleConfig(**config_dict)
        predictor = cls(config=config)

        # Load models from ONNX
        models_dir = ensemble_dir / "models"
        if models_dir.exists() and HAS_ONNX:
            for model_file in models_dir.glob("*.onnx"):
                model_name = model_file.stem
                try:
                    session = cls._load_model_onnx(str(model_file))
                    predictor._models[model_name] = session
                    logger.info(f"Loaded {model_name} from ONNX")
                except Exception:
                    logger.warning("Failed to load %s from ONNX", model_name, exc_info=True)
        else:
            raise RuntimeError("ONNX not available; cannot load models")

        predictor._calibrators = {}

        predictor._is_fitted = len(predictor._models) > 0

        return predictor

    @classmethod
    def _load_pickle(cls, filepath: str) -> EnsemblePredictor:
        raise RuntimeError(
            "Pickle loading is disabled (RCE risk). Re-export ensemble to ONNX/JSON."
        )

    @staticmethod
    def _load_model_onnx(filepath: str) -> ort.InferenceSession:
        """Load ONNX model for inference."""
        if not HAS_ONNX:
            raise ImportError("ONNX libraries not installed")

        sess_options = ort.SessionOptions()
        sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL

        session = ort.InferenceSession(
            filepath, sess_options=sess_options, providers=["CPUExecutionProvider"]
        )

        return session


class StackingEnsemble:
    """
    Stacking ensemble using meta-learner with temporal cross-validation.

    First layer: Base models generate predictions using TimeSeriesSplit
    Second layer: Meta-model combines predictions

    IMPORTANT: Input data MUST be sorted ascending by time to prevent look-ahead bias.
    The fit() method uses TimeSeriesSplit which ensures training data is always
    temporally before test data in each fold.
    """

    def __init__(
        self,
        base_models: dict[str, Any],
        meta_model: Any | None = None,
        n_splits: int = 5,
        gap: int = 10,
    ):
        """
        Initialize stacking ensemble.

        Args:
            base_models: Dictionary of model name to model instance.
            meta_model: Optional meta-model for stacking (defaults to LogisticRegression).
            n_splits: Number of time-series CV splits (default 5).
            gap: Number of samples to skip between train and test to prevent leakage (default 10).
        """
        self.base_models = base_models
        self.meta_model = meta_model
        self.n_splits = n_splits
        self.gap = gap
        self._is_fitted = False

    def fit(
        self,
        X: np.ndarray[Any, Any],
        y: np.ndarray[Any, Any],
        X_val: np.ndarray[Any, Any] | None = None,
        y_val: np.ndarray[Any, Any] | None = None,
    ) -> None:
        """
        Fit stacking ensemble using temporal cross-validation.

        Uses TimeSeriesSplit to generate out-of-fold predictions from base models,
        ensuring training data is always temporally before test data (no look-ahead).

        CRITICAL: Input data X, y MUST be sorted ascending by time.

        Args:
            X: Feature matrix (n_samples, n_features), sorted by time ascending.
            y: Target labels.
            X_val: Optional validation features (unused, kept for API compatibility).
            y_val: Optional validation labels (unused, kept for API compatibility).
        """
        from sklearn.model_selection import TimeSeriesSplit

        n_samples = len(X)
        n_models = len(self.base_models)

        # Generate out-of-fold predictions using TimeSeriesSplit (temporal CV)
        # Note: With TimeSeriesSplit, early samples are never in test set
        # We use NaN for samples without predictions and filter them for meta-model
        oof_predictions = np.full((n_samples, n_models), np.nan)

        # TimeSeriesSplit ensures train is ALWAYS before test (no look-ahead)
        # gap parameter adds purging buffer between train and test
        tscv = TimeSeriesSplit(n_splits=self.n_splits, gap=self.gap)

        for _fold_idx, (train_idx, val_idx) in enumerate(tscv.split(X)):
            X_train, X_val_fold = X[train_idx], X[val_idx]
            y_train = y[train_idx]

            for model_idx, (_name, model) in enumerate(self.base_models.items()):
                # Clone and fit model
                model.fit(X_train, y_train)

                # Generate predictions
                if hasattr(model, "predict_proba"):
                    proba = model.predict_proba(X_val_fold)
                    oof_predictions[val_idx, model_idx] = proba[:, 1]
                else:
                    oof_predictions[val_idx, model_idx] = model.predict(X_val_fold)

        # Filter to samples that have OOF predictions (exclude early samples without predictions)
        # With TimeSeriesSplit, first few samples are never in test set
        valid_mask = ~np.isnan(oof_predictions[:, 0])
        oof_valid = oof_predictions[valid_mask]
        y_valid = y[valid_mask]

        if len(y_valid) == 0:
            raise ValueError(
                "No valid OOF predictions generated. "
                "Ensure dataset is large enough for n_splits + gap."
            )

        # Fit meta-model on OOF predictions (only samples with valid predictions)
        if self.meta_model is None:
            try:
                from sklearn.linear_model import LogisticRegression

                self.meta_model = LogisticRegression(max_iter=1000)
            except ImportError as err:
                raise ImportError("sklearn required for stacking") from err

        self.meta_model.fit(oof_valid, y_valid)

        # Refit base models on full data for final predictions
        for _name, model in self.base_models.items():
            model.fit(X, y)

        self._is_fitted = True

    def predict_proba(self, X: np.ndarray[Any, Any]) -> np.ndarray[Any, Any]:
        """Generate stacked predictions."""
        if not self._is_fitted:
            raise ValueError("Ensemble not fitted")

        if self.meta_model is None:
            raise ValueError("Ensemble not fitted")

        # Get base model predictions
        n_samples = len(X)
        n_models = len(self.base_models)
        base_preds = np.zeros((n_samples, n_models))

        for model_idx, (_name, model) in enumerate(self.base_models.items()):
            if hasattr(model, "predict_proba"):
                base_preds[:, model_idx] = model.predict_proba(X)[:, 1]
            else:
                base_preds[:, model_idx] = model.predict(X)

        # Meta-model prediction
        meta_proba_any = self.meta_model.predict_proba(base_preds)
        return cast(np.ndarray[Any, Any], np.asarray(meta_proba_any))

    def predict(self, X: np.ndarray[Any, Any]) -> np.ndarray[Any, Any]:
        """Generate class predictions."""
        proba = self.predict_proba(X)
        preds_any = (proba[:, 1] >= 0.5).astype(int)
        return cast(np.ndarray[Any, Any], np.asarray(preds_any))
