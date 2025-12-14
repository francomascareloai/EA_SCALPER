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

import numpy as np
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path
import pickle
import json
import logging

logger = logging.getLogger(__name__)

try:
    import onnx
    import onnxruntime as ort
    import onnxmltools
    from onnxmltools.convert.common.data_types import FloatTensorType
    from skl2onnx import convert_sklearn
    HAS_ONNX = True
except ImportError:
    HAS_ONNX = False
    logger.warning("ONNX libraries not available. Install with: pip install onnx onnxruntime onnxmltools skl2onnx")

from ..core.definitions import SignalType, MarketRegime


@dataclass
class EnsemblePrediction:
    """Result from ensemble prediction."""
    signal: SignalType
    probability: float  # 0-1, probability of predicted direction
    confidence: float   # 0-1, model confidence
    
    # Individual model predictions
    model_predictions: Dict[str, float] = field(default_factory=dict)
    
    # Metadata
    regime: Optional[MarketRegime] = None
    ensemble_type: str = "weighted_voting"
    timestamp: Optional[datetime] = None
    
    @property
    def is_valid(self) -> bool:
        """Check if prediction meets confidence threshold."""
        return self.confidence >= 0.6 and self.probability >= 0.55


@dataclass
class EnsembleConfig:
    """Configuration for ensemble predictor."""
    # Model weights (must sum to 1.0)
    model_weights: Dict[str, float] = field(default_factory=lambda: {
        "lightgbm": 0.4,
        "xgboost": 0.35,
        "random_forest": 0.25,
    })
    
    # Thresholds
    min_probability: float = 0.55  # Min probability to generate signal
    min_confidence: float = 0.60   # Min confidence to act on signal
    
    # Regime-specific adjustments
    regime_weights: Dict[str, Dict[str, float]] = field(default_factory=lambda: {
        "REGIME_PRIME_TRENDING": {"lightgbm": 0.5, "xgboost": 0.35, "random_forest": 0.15},
        "REGIME_NOISY_TRENDING": {"lightgbm": 0.4, "xgboost": 0.4, "random_forest": 0.2},
        "REGIME_PRIME_REVERTING": {"lightgbm": 0.35, "xgboost": 0.35, "random_forest": 0.3},
        "REGIME_NOISY_REVERTING": {"lightgbm": 0.4, "xgboost": 0.35, "random_forest": 0.25},
    })
    
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
    """
    
    def __init__(self, config: Optional[EnsembleConfig] = None):
        self.config = config or EnsembleConfig()
        self._models: Dict[str, Any] = {}
        self._calibrators: Dict[str, Any] = {}
        self._is_fitted = False
    
    def add_model(self, name: str, model: Any, weight: Optional[float] = None) -> None:
        """
        Add a model to the ensemble.
        
        Args:
            name: Model identifier
            model: Trained model with predict_proba method
            weight: Optional weight override
        """
        self._models[name] = model
        
        if weight is not None:
            self.config.model_weights[name] = weight
        elif name not in self.config.model_weights:
            # Default equal weight
            n_models = len(self._models)
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
    
    def predict(
        self,
        features: np.ndarray,
        regime: Optional[MarketRegime] = None,
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
        
        # Get weights for current regime
        weights = self._get_regime_weights(regime)
        
        # Collect predictions from all models
        model_probs: Dict[str, float] = {}
        model_preds: Dict[str, int] = {}
        
        for name, model in self._models.items():
            if name not in weights:
                continue
            
            try:
                # Check if model is ONNX Runtime session
                if HAS_ONNX and isinstance(model, ort.InferenceSession):
                    # ONNX inference
                    input_name = model.get_inputs()[0].name
                    output_name = model.get_outputs()[0].name
                    
                    # Run inference
                    onnx_output = model.run(
                        [output_name],
                        {input_name: features.astype(np.float32)}
                    )[0]
                    
                    # Extract probability (assuming binary classification)
                    if len(onnx_output.shape) == 2 and onnx_output.shape[1] >= 2:
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
            except Exception as e:
                # Skip failed models
                logger.debug(f"Model {name} prediction failed: {e}")
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
            timestamp=datetime.now(),
        )
    
    def _get_regime_weights(self, regime: Optional[MarketRegime]) -> Dict[str, float]:
        """Get model weights adjusted for current regime."""
        if regime is None:
            return self.config.model_weights.copy()
        
        regime_name = regime.name
        
        if regime_name in self.config.regime_weights:
            return self.config.regime_weights[regime_name].copy()
        
        return self.config.model_weights.copy()
    
    def _calculate_confidence(
        self,
        model_probs: Dict[str, float],
        weights: Dict[str, float],
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
        certainty = np.mean([abs(p - 0.5) for p in probs]) * 2
        
        # Variance factor: lower variance = higher confidence
        variance = np.std(probs)
        variance_score = max(0, 1 - variance * 4)  # Penalize high variance
        
        # Combined confidence
        confidence = 0.4 * agreement_score + 0.4 * certainty + 0.2 * variance_score
        
        return min(1.0, max(0.0, confidence))
    
    def _calibrate_probability(self, model_name: str, probability: float) -> float:
        """Calibrate probability using stored calibrator."""
        if model_name not in self._calibrators:
            return probability
        
        calibrator = self._calibrators[model_name]
        
        try:
            calibrated = calibrator.predict_proba([[probability]])[0, 1]
            return float(calibrated)
        except Exception as e:
            logger.warning(f"Calibration failed: {e}")
            return probability
    
    def fit_calibration(
        self,
        X: np.ndarray,
        y: np.ndarray,
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
                CalibratorClass = IsotonicRegression
            else:
                from sklearn.linear_model import LogisticRegression
                CalibratorClass = LogisticRegression
        except ImportError:
            return
        
        for name, model in self._models.items():
            if not hasattr(model, "predict_proba"):
                continue
            
            try:
                probs = model.predict_proba(X)[:, 1]
                
                if self.config.calibration_method == "isotonic":
                    calibrator = CalibratorClass(out_of_bounds="clip")
                    calibrator.fit(probs, y)
                else:
                    calibrator = CalibratorClass()
                    calibrator.fit(probs.reshape(-1, 1), y)
                
                self._calibrators[name] = calibrator
            except Exception as e:
                logger.warning(f"Calibrator training failed for {name}: {e}")
                continue
    
    def predict_with_uncertainty(
        self,
        features: np.ndarray,
        regime: Optional[MarketRegime] = None,
        n_bootstrap: int = 100,
    ) -> Tuple[EnsemblePrediction, float, float]:
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
        features: np.ndarray,
    ) -> Dict[str, Any]:
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
                name: "BUY" if p >= 0.5 else "SELL"
                for name, p in pred.model_predictions.items()
            },
        }
    
    def save(self, filepath: str) -> None:
        """
        Save ensemble to disk using ONNX and JSON.
        
        Saves:
        - Config as JSON
        - Each model as ONNX
        - Calibrators as pickle (small, internal use)
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
        with open(config_path, 'w') as f:
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
                    logger.warning(f"Failed to save {model_name} to ONNX: {e}. Using pickle fallback.")
                    pkl_path = models_dir / f"{model_name}.pkl"
                    with open(pkl_path, 'wb') as f:
                        pickle.dump(model, f)
        else:
            # Fallback to pickle if ONNX not available
            logger.warning("ONNX not available, using pickle - security vulnerability!")
            models_path = ensemble_dir / "models.pkl"
            with open(models_path, 'wb') as f:
                pickle.dump(self._models, f)
        
        # Save calibrators (small objects, keep as pickle for simplicity)
        if self._calibrators:
            calibrators_path = ensemble_dir / "calibrators.pkl"
            with open(calibrators_path, 'wb') as f:
                pickle.dump(self._calibrators, f)
        
        logger.info(f"Ensemble saved to: {ensemble_dir}")
    
    def _save_model_onnx(self, model: Any, filepath: str, model_name: str) -> None:
        """Export a single model to ONNX format."""
        if not HAS_ONNX:
            raise ImportError("ONNX libraries not installed")
        
        # Get number of features
        if hasattr(model, 'n_features_in_'):
            n_features = model.n_features_in_
        elif hasattr(model, '_n_features'):
            n_features = model._n_features
        else:
            # Try to infer from first prediction attempt
            raise ValueError(f"Cannot determine number of features for {model_name}")
        
        # Define initial type
        initial_type = [('float_input', FloatTensorType([None, n_features]))]
        
        # Detect model type and convert
        model_type = type(model).__name__
        
        try:
            import lightgbm as lgb
            if isinstance(model, lgb.LGBMClassifier) or isinstance(model, lgb.Booster):
                onnx_model = onnxmltools.convert_lightgbm(
                    model,
                    initial_types=initial_type,
                    target_opset=12
                )
                onnxmltools.utils.save_model(onnx_model, filepath)
                return
        except ImportError:
            pass
        
        try:
            import xgboost as xgb
            if isinstance(model, xgb.XGBClassifier) or isinstance(model, xgb.Booster):
                onnx_model = onnxmltools.convert_xgboost(
                    model,
                    initial_types=initial_type,
                    target_opset=12
                )
                onnxmltools.utils.save_model(onnx_model, filepath)
                return
        except ImportError:
            pass
        
        # Try sklearn conversion
        try:
            from sklearn.base import BaseEstimator
            if isinstance(model, BaseEstimator):
                onnx_model = convert_sklearn(
                    model,
                    initial_types=initial_type,
                    target_opset=12
                )
                onnxmltools.utils.save_model(onnx_model, filepath)
                return
        except ImportError:
            pass
        
        raise ValueError(f"Unsupported model type for ONNX: {model_type}")
    
    @classmethod
    def load(cls, filepath: str) -> "EnsemblePredictor":
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
                # Fallback to pickle
                return cls._load_pickle(filepath)
        
        # Load config from JSON
        config_path = ensemble_dir / "config.json"
        if not config_path.exists():
            return cls._load_pickle(filepath)
        
        with open(config_path, 'r') as f:
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
                except Exception as e:
                    logger.warning(f"Failed to load {model_name} from ONNX: {e}")
        else:
            # Try pickle fallback
            models_pkl = ensemble_dir / "models.pkl"
            if models_pkl.exists():
                logger.warning("Loading models from pickle - security vulnerability!")
                with open(models_pkl, 'rb') as f:
                    predictor._models = pickle.load(f)
        
        # Load calibrators
        calibrators_path = ensemble_dir / "calibrators.pkl"
        if calibrators_path.exists():
            with open(calibrators_path, 'rb') as f:
                predictor._calibrators = pickle.load(f)
        
        predictor._is_fitted = len(predictor._models) > 0
        
        return predictor
    
    @classmethod
    def _load_pickle(cls, filepath: str) -> "EnsemblePredictor":
        """Fallback loader for old pickle format."""
        logger.warning("Loading pickle file - security vulnerability! Migrate to ONNX.")
        
        with open(filepath, "rb") as f:
            state = pickle.load(f)
        
        predictor = cls(config=state["config"])
        predictor._models = state["models"]
        predictor._calibrators = state.get("calibrators", {})
        predictor._is_fitted = len(predictor._models) > 0
        
        return predictor
    
    @staticmethod
    def _load_model_onnx(filepath: str) -> ort.InferenceSession:
        """Load ONNX model for inference."""
        if not HAS_ONNX:
            raise ImportError("ONNX libraries not installed")
        
        sess_options = ort.SessionOptions()
        sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        
        session = ort.InferenceSession(
            filepath,
            sess_options=sess_options,
            providers=['CPUExecutionProvider']
        )
        
        return session


class StackingEnsemble:
    """
    Stacking ensemble using meta-learner.
    
    First layer: Base models generate predictions
    Second layer: Meta-model combines predictions
    """
    
    def __init__(
        self,
        base_models: Dict[str, Any],
        meta_model: Optional[Any] = None,
    ):
        self.base_models = base_models
        self.meta_model = meta_model
        self._is_fitted = False
    
    def fit(
        self,
        X: np.ndarray,
        y: np.ndarray,
        X_val: Optional[np.ndarray] = None,
        y_val: Optional[np.ndarray] = None,
    ) -> None:
        """
        Fit stacking ensemble.
        
        Uses out-of-fold predictions from base models to train meta-model.
        """
        from sklearn.model_selection import KFold
        
        n_samples = len(X)
        n_models = len(self.base_models)
        
        # Generate out-of-fold predictions
        oof_predictions = np.zeros((n_samples, n_models))
        
        kf = KFold(n_splits=5, shuffle=False)
        
        for fold_idx, (train_idx, val_idx) in enumerate(kf.split(X)):
            X_train, X_val_fold = X[train_idx], X[val_idx]
            y_train = y[train_idx]
            
            for model_idx, (name, model) in enumerate(self.base_models.items()):
                # Clone and fit model
                model.fit(X_train, y_train)
                
                # Generate predictions
                if hasattr(model, "predict_proba"):
                    proba = model.predict_proba(X_val_fold)
                    oof_predictions[val_idx, model_idx] = proba[:, 1]
                else:
                    oof_predictions[val_idx, model_idx] = model.predict(X_val_fold)
        
        # Fit meta-model on OOF predictions
        if self.meta_model is None:
            try:
                from sklearn.linear_model import LogisticRegression
                self.meta_model = LogisticRegression(max_iter=1000)
            except ImportError:
                raise ImportError("sklearn required for stacking")
        
        self.meta_model.fit(oof_predictions, y)
        
        # Refit base models on full data
        for name, model in self.base_models.items():
            model.fit(X, y)
        
        self._is_fitted = True
    
    def predict_proba(self, X: np.ndarray) -> np.ndarray:
        """Generate stacked predictions."""
        if not self._is_fitted:
            raise ValueError("Ensemble not fitted")
        
        # Get base model predictions
        n_samples = len(X)
        n_models = len(self.base_models)
        base_preds = np.zeros((n_samples, n_models))
        
        for model_idx, (name, model) in enumerate(self.base_models.items()):
            if hasattr(model, "predict_proba"):
                base_preds[:, model_idx] = model.predict_proba(X)[:, 1]
            else:
                base_preds[:, model_idx] = model.predict(X)
        
        # Meta-model prediction
        return self.meta_model.predict_proba(base_preds)
    
    def predict(self, X: np.ndarray) -> np.ndarray:
        """Generate class predictions."""
        proba = self.predict_proba(X)
        return (proba[:, 1] >= 0.5).astype(int)
