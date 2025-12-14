# ML Feature Engineering - STREAM G (Part 1)

## Overview

This module provides comprehensive feature engineering for XAUUSD gold scalping ML models. It generates **49 features** organized into 7 categories from OHLCV (Open, High, Low, Close, Volume) data.

## Features (49 total)

### 1. Price Features (9)
- `returns` - Simple returns
- `log_returns` - Log returns
- `range_pct` - (high - low) / close
- `body_pct` - |close - open| / (high - low)
- `gap` - Price gap from previous close
- `upper_shadow` - Upper wick size (normalized)
- `lower_shadow` - Lower wick size (normalized)
- `roc_5` - 5-period rate of change
- `roc_10` - 10-period rate of change

### 2. Volume Features (5)
- `volume_ratio` - Volume / MA(volume)
- `volume_delta` - Directional volume (approximated)
- `volume_delta_ma` - 20-period MA of delta
- `vwap_distance` - Distance to VWAP
- `volume_volatility` - Rolling std of volume

### 3. Technical Indicators (17)
- `rsi_5`, `rsi_14`, `rsi_21` - RSI at multiple periods
- `macd`, `macd_signal`, `macd_histogram` - MACD components
- `atr_normalized` - ATR / close
- `bb_position` - Position within Bollinger Bands
- `bb_width_pct` - BB width as % of price
- `ema_8_dist`, `ema_21_dist`, `ema_50_dist`, `ema_200_dist` - EMA distances
- `sma_20_dist`, `sma_50_dist`, `sma_100_dist` - SMA distances
- `adx` - Average Directional Index

### 4. Structure Features (5)
- `swing_high_distance` - Distance to recent swing high
- `swing_low_distance` - Distance to recent swing low
- `trend_strength` - Linear regression slope (20-bar)
- `higher_highs` - Count of higher highs (10-bar window)
- `lower_lows` - Count of lower lows (10-bar window)

### 5. Regime Features (3)
- `hurst_exponent` - Hurst exponent (persistence/mean-reversion)
- `shannon_entropy` - Shannon entropy (randomness)
- `variance_ratio` - Variance ratio (Lo-MacKinlay test)

### 6. Statistical Features (4)
- `zscore` - Z-score of price (20-period)
- `skewness` - Rolling skewness of returns (30-period)
- `kurtosis` - Rolling kurtosis of returns (30-period)
- `autocorr_1` - Autocorrelation lag 1 (20-period)

### 7. Temporal Features (6)
- `hour_sin`, `hour_cos` - Cyclical hour encoding
- `day_sin`, `day_cos` - Cyclical day of week encoding
- `is_monday` - Monday flag
- `is_friday` - Friday flag

## Usage

### Basic Usage

```python
from src.ml import FeatureEngineer, FeatureConfig
import pandas as pd

# Load OHLCV data
df = pd.read_csv('xauusd_data.csv', index_col='timestamp', parse_dates=True)
# Required columns: 'open', 'high', 'low', 'close', 'volume'

# Create feature engineer
engineer = FeatureEngineer()

# Compute all features
features = engineer.compute_all_features(df)

# Get feature names
feature_names = engineer.get_feature_names()
print(f"Generated {len(feature_names)} features")

# Scale features for ML
scaled_features = engineer.scale_features(features, method='standard')
```

### Custom Configuration

```python
from src.ml import FeatureConfig

# Customize periods and parameters
config = FeatureConfig(
    rsi_periods=[7, 14, 28],           # Custom RSI periods
    ema_periods=[10, 20, 50, 100],     # Custom EMA periods
    atr_period=20,                      # Custom ATR period
    hurst_period=150,                   # Longer Hurst window
    entropy_period=100,                 # Longer entropy window
)

engineer = FeatureEngineer(config)
features = engineer.compute_all_features(df)
```

### Feature Groups

```python
# Get features organized by category
groups = engineer.get_feature_importance_groups()

for category, feature_list in groups.items():
    print(f"{category}: {len(feature_list)} features")
    print(f"  {', '.join(feature_list[:3])}...")  # Show first 3
```

### Scaling Methods

```python
# Standard scaling (zero mean, unit variance)
scaled = engineer.scale_features(features, method='standard', fit=True)

# Robust scaling (median and IQR - better for outliers)
scaled = engineer.scale_features(features, method='robust', fit=True)

# Transform new data using fitted scaler
new_features = engineer.compute_all_features(new_df)
scaled_new = engineer.scale_features(new_features, fit=False)  # Use existing scaler
```

## Configuration Options

### FeatureConfig Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `rsi_periods` | [5, 14, 21] | RSI calculation periods |
| `ema_periods` | [8, 21, 50, 200] | EMA periods |
| `sma_periods` | [20, 50, 100] | SMA periods |
| `atr_period` | 14 | ATR period |
| `bb_period` | 20 | Bollinger Bands period |
| `bb_std` | 2.0 | Bollinger Bands std dev |
| `hurst_period` | 100 | Hurst exponent window |
| `entropy_period` | 50 | Shannon entropy window |
| `volume_ma_period` | 20 | Volume MA period |
| `zscore_period` | 20 | Z-score window |
| `skew_period` | 30 | Skewness window |
| `kurt_period` | 30 | Kurtosis window |
| `macd_fast` | 12 | MACD fast period |
| `macd_slow` | 26 | MACD slow period |
| `macd_signal` | 9 | MACD signal period |
| `adx_period` | 14 | ADX period |

## Performance

All calculations are **vectorized** using NumPy/Pandas for optimal performance:
- ~1000 bars: < 1 second
- ~10000 bars: < 3 seconds
- ~100000 bars: < 30 seconds

## Requirements

```python
numpy>=1.24.0
pandas>=2.0.0
scikit-learn>=1.3.0
scipy>=1.11.0
```

## Testing

Run the built-in test:

```bash
python src/ml/feature_engineering.py
```

This will:
1. Generate sample OHLCV data (1000 bars)
2. Compute all 49 features
3. Scale features
4. Display statistics and sample output

## Integration with ML Models

### For Training

```python
# Prepare training data
features = engineer.compute_all_features(train_df)
scaled = engineer.scale_features(features, method='standard', fit=True)

# Train model
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier()
model.fit(scaled, y_train)
```

### For Inference

```python
# New data (real-time or backtest)
new_features = engineer.compute_all_features(new_df)
scaled_new = engineer.scale_features(new_features, fit=False)

# Predict
predictions = model.predict(scaled_new)
```

## Notes

- **NaN Handling**: Rolling calculations produce NaN for initial rows. These are automatically dropped by `compute_all_features()`.
- **Minimum Data**: Requires at least 200 bars for all features (due to Hurst exponent calculation).
- **Temporal Features**: Hour/day are cyclically encoded (sin/cos) to preserve circular nature of time.
- **Regime Features**: Hurst/Entropy/VR are computationally expensive on very large datasets (>1M bars). Consider sampling or batch processing.

## Future Enhancements (STREAM G Part 2+)

- Order flow features (from footprint data)
- Smart Money Concepts features (OB, FVG, liquidity sweeps)
- Multi-timeframe features
- Feature selection utilities
- Feature importance analysis
- ONNX model integration

## Author

Created as part of NAUTILUS MIGRATION MASTER PLAN - STREAM G (Part 1)
Date: 2025-12-03
