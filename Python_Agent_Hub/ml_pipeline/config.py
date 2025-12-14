"""
Configuration for ML Pipeline
EA_SCALPER_XAUUSD - Singularity Edition
"""
from pathlib import Path
from dataclasses import dataclass
from typing import List

# Paths
PROJECT_ROOT = Path(__file__).parent.parent.parent
ML_PIPELINE_DIR = Path(__file__).parent
DATA_DIR = ML_PIPELINE_DIR / "data"
MODELS_DIR = ML_PIPELINE_DIR / "models"
MQL5_MODELS_DIR = PROJECT_ROOT / "MQL5" / "Models"

# Ensure directories exist
DATA_DIR.mkdir(exist_ok=True)
MODELS_DIR.mkdir(exist_ok=True)
MQL5_MODELS_DIR.mkdir(exist_ok=True)

@dataclass
class ModelConfig:
    """Configuration for a model"""
    name: str
    sequence_length: int
    features: List[str]
    hidden_size: int
    num_layers: int
    dropout: float
    output_size: int
    
# Direction Model Config
DIRECTION_CONFIG = ModelConfig(
    name="direction_model",
    sequence_length=100,
    features=[
        "returns", "log_returns", "range_pct",
        "rsi_m5", "rsi_m15", "rsi_h1",
        "atr_norm", "ma_dist", "bb_pos",
        "hurst", "entropy_norm",
        "session", "hour_sin", "hour_cos",
        "ob_distance"
    ],
    hidden_size=64,
    num_layers=2,
    dropout=0.2,
    output_size=2  # [P(bearish), P(bullish)]
)

# Volatility Model Config
VOLATILITY_CONFIG = ModelConfig(
    name="volatility_model",
    sequence_length=50,
    features=[
        "atr", "range", "volume_ratio", "returns_std", "high_low_ratio"
    ],
    hidden_size=32,
    num_layers=1,
    dropout=0.1,
    output_size=5  # ATR forecast for 5 bars
)

# Training Config
@dataclass
class TrainingConfig:
    """Training hyperparameters"""
    batch_size: int = 64
    epochs: int = 100
    learning_rate: float = 1e-4
    early_stopping_patience: int = 10
    validation_split: float = 0.2
    walk_forward_windows: int = 10
    min_wfe: float = 0.6  # Minimum Walk-Forward Efficiency

TRAINING_CONFIG = TrainingConfig()

# Symbol Config
SYMBOL = "XAUUSD"
TIMEFRAME = "M15"

# Feature normalization defaults
DEFAULT_NORM_PARAMS = {
    "returns": {"mean": 0.0, "std": 0.005},
    "log_returns": {"mean": 0.0, "std": 0.005},
    "range_pct": {"mean": 0.003, "std": 0.002},
    "rsi_m5": {"mean": 50.0, "std": 20.0},
    "rsi_m15": {"mean": 50.0, "std": 20.0},
    "rsi_h1": {"mean": 50.0, "std": 20.0},
    "atr_norm": {"mean": 0.002, "std": 0.001},
    "ma_dist": {"mean": 0.0, "std": 0.005},
    "bb_pos": {"mean": 0.0, "std": 1.0},
    "hurst": {"mean": 0.5, "std": 0.15},
    "entropy_norm": {"mean": 0.5, "std": 0.25},
    "session": {"mean": 1.0, "std": 1.0},
    "hour_sin": {"mean": 0.0, "std": 1.0},
    "hour_cos": {"mean": 0.0, "std": 1.0},
    "ob_distance": {"mean": 1.0, "std": 1.0},
}
