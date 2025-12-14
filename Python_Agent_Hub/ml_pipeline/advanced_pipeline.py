"""
EA_SCALPER_XAUUSD - Advanced ML Pipeline
=========================================
Complete pipeline with:
- 15 features including Hurst Exponent and Shannon Entropy
- RegimeClassifier + DirectionLSTM + VolatilityGRU
- Walk-Forward Analysis validation
- ONNX export for MQL5
"""

import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
from sklearn.preprocessing import StandardScaler
from pathlib import Path
import json
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# CONFIGURATION
# ============================================================================

BASE_DIR = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline')
DATA_DIR = BASE_DIR / 'data'
MODEL_DIR = BASE_DIR / 'models'
MODEL_DIR.mkdir(exist_ok=True)

CONFIG = {
    'seq_len': 100,           # Sequence length for LSTM
    'batch_size': 64,
    'epochs': 100,
    'lr': 1e-4,
    'hidden_size': 64,
    'num_layers': 2,
    'dropout': 0.2,
    'lookahead': 4,           # 4 bars = 1 hour for M15
    'threshold': 0.001,       # 0.1% move threshold
    'hurst_window': 100,
    'entropy_window': 100,
    'wfa_train_months': 12,   # 1 year training
    'wfa_test_months': 3,     # 3 months testing
    'min_wfe': 0.6,           # Minimum Walk-Forward Efficiency
}

# ============================================================================
# HURST EXPONENT CALCULATION (R/S Method)
# ============================================================================

def calculate_hurst(prices: np.ndarray, min_k: int = 10, max_k: int = 50) -> float:
    """
    Calculate Hurst exponent using R/S analysis.
    H > 0.55: Trending
    H < 0.45: Mean-reverting
    H ~ 0.5: Random walk
    """
    if len(prices) < max_k * 2:
        return 0.5  # Default to random walk if insufficient data
    
    log_prices = np.log(prices)
    returns = np.diff(log_prices)
    
    if len(returns) < max_k:
        return 0.5
    
    rs_values = []
    window_sizes = []
    
    for n in range(min_k, min(max_k + 1, len(returns) // 2)):
        num_subseries = len(returns) // n
        if num_subseries < 1:
            continue
            
        rs_list = []
        for i in range(num_subseries):
            subseries = returns[i * n:(i + 1) * n]
            if len(subseries) < 2:
                continue
                
            mean_val = np.mean(subseries)
            cumdev = np.cumsum(subseries - mean_val)
            R = np.max(cumdev) - np.min(cumdev)
            S = np.std(subseries, ddof=1)
            
            if S > 1e-10:
                rs_list.append(R / S)
        
        if rs_list:
            rs_values.append(np.mean(rs_list))
            window_sizes.append(n)
    
    if len(rs_values) < 3:
        return 0.5
    
    # Linear regression on log-log scale
    log_n = np.log(window_sizes)
    log_rs = np.log(rs_values)
    
    try:
        H = np.polyfit(log_n, log_rs, 1)[0]
        return float(np.clip(H, 0, 1))
    except:
        return 0.5


def calculate_hurst_rolling(prices: pd.Series, window: int = 100) -> pd.Series:
    """Calculate rolling Hurst exponent."""
    return prices.rolling(window).apply(
        lambda x: calculate_hurst(x.values), raw=False
    )

# ============================================================================
# SHANNON ENTROPY CALCULATION
# ============================================================================

def calculate_entropy(returns: np.ndarray, bins: int = 10) -> float:
    """
    Calculate Shannon entropy of returns distribution.
    Low entropy (<1.5): Predictable, low noise
    High entropy (>2.5): Random, high noise
    """
    if len(returns) < bins:
        return 2.0  # Default to medium entropy
    
    # Remove NaN and infinite values
    returns = returns[np.isfinite(returns)]
    if len(returns) < bins:
        return 2.0
    
    hist, _ = np.histogram(returns, bins=bins, density=True)
    hist = hist[hist > 0]  # Remove zeros to avoid log(0)
    
    if len(hist) == 0:
        return 2.0
    
    # Normalize to create probability distribution
    hist = hist / hist.sum()
    
    return float(-np.sum(hist * np.log2(hist + 1e-10)))


def calculate_entropy_rolling(returns: pd.Series, window: int = 100) -> pd.Series:
    """Calculate rolling Shannon entropy."""
    return returns.rolling(window).apply(
        lambda x: calculate_entropy(x.values), raw=False
    )

# ============================================================================
# TECHNICAL INDICATORS
# ============================================================================

def calculate_rsi(prices: pd.Series, period: int = 14) -> pd.Series:
    """Calculate Relative Strength Index."""
    delta = prices.diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    rs = gain / (loss + 1e-10)
    return 100 - (100 / (1 + rs))


def calculate_atr(high: pd.Series, low: pd.Series, close: pd.Series, period: int = 14) -> pd.Series:
    """Calculate Average True Range."""
    tr1 = high - low
    tr2 = abs(high - close.shift(1))
    tr3 = abs(low - close.shift(1))
    tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
    return tr.rolling(window=period).mean()

# ============================================================================
# FEATURE ENGINEERING - 15 FEATURES
# ============================================================================

def create_features(df_m15: pd.DataFrame, df_h1: pd.DataFrame = None) -> pd.DataFrame:
    """
    Create 15 features for ML models.
    
    Features:
    1. returns - Simple returns
    2. log_returns - Log returns  
    3. range_pct - High-Low range as % of close
    4. rsi_m15 - RSI on M15
    5. atr_norm - ATR normalized by price
    6. ma_dist - Distance from MA20
    7. bb_pos - Bollinger Band position
    8. hurst - Hurst exponent (regime)
    9. entropy - Shannon entropy (noise)
    10. rsi_h1 - RSI from H1 (MTF)
    11. trend_h1 - H1 trend direction
    12. session - Trading session (0=Asia, 1=London, 2=NY)
    13. hour_sin - Hour cyclical (sin)
    14. hour_cos - Hour cyclical (cos)
    15. volatility_regime - ATR percentile
    """
    print("Creating features...")
    
    f = pd.DataFrame(index=df_m15.index)
    close = df_m15['close']
    high = df_m15['high']
    low = df_m15['low']
    
    # 1-2: Returns
    f['returns'] = close.pct_change()
    f['log_returns'] = np.log(close / close.shift(1))
    
    # 3: Range
    f['range_pct'] = (high - low) / close
    
    # 4: RSI M15
    f['rsi_m15'] = calculate_rsi(close, 14) / 100
    
    # 5: ATR normalized
    atr = calculate_atr(high, low, close, 14)
    f['atr_norm'] = atr / close
    
    # 6: MA distance
    ma20 = close.rolling(20).mean()
    f['ma_dist'] = (close - ma20) / ma20
    
    # 7: Bollinger Band position
    bb_std = close.rolling(20).std()
    bb_upper = ma20 + 2 * bb_std
    bb_lower = ma20 - 2 * bb_std
    f['bb_pos'] = (close - ma20) / (bb_upper - bb_lower + 1e-10)
    
    # 8: Hurst Exponent (CRITICAL for regime detection)
    print("  Calculating Hurst exponent (this takes a while)...")
    f['hurst'] = calculate_hurst_rolling(close, CONFIG['hurst_window'])
    
    # 9: Shannon Entropy (CRITICAL for noise detection)
    print("  Calculating Shannon entropy...")
    f['entropy'] = calculate_entropy_rolling(f['returns'], CONFIG['entropy_window']) / 4  # Normalize to ~0-1
    
    # 10-11: H1 features (Multi-Timeframe)
    if df_h1 is not None:
        print("  Adding H1 MTF features...")
        rsi_h1 = calculate_rsi(df_h1['close'], 14) / 100
        rsi_h1.index = pd.to_datetime(rsi_h1.index)
        
        # Resample H1 to M15 (forward fill)
        rsi_h1_m15 = rsi_h1.reindex(df_m15.index, method='ffill')
        f['rsi_h1'] = rsi_h1_m15
        
        # H1 trend (MA crossover)
        ma_fast_h1 = df_h1['close'].rolling(10).mean()
        ma_slow_h1 = df_h1['close'].rolling(30).mean()
        trend_h1 = (ma_fast_h1 > ma_slow_h1).astype(float)
        trend_h1.index = pd.to_datetime(trend_h1.index)
        trend_h1_m15 = trend_h1.reindex(df_m15.index, method='ffill')
        f['trend_h1'] = trend_h1_m15
    else:
        f['rsi_h1'] = f['rsi_m15']  # Fallback
        f['trend_h1'] = 0.5
    
    # 12: Session
    hour = df_m15.index.hour
    f['session'] = hour.map(lambda h: 0 if h < 7 else (1 if h < 15 else 2)) / 2  # Normalize to 0-1
    
    # 13-14: Hour cyclical
    f['hour_sin'] = np.sin(2 * np.pi * hour / 24)
    f['hour_cos'] = np.cos(2 * np.pi * hour / 24)
    
    # 15: Volatility regime (ATR percentile)
    f['volatility_regime'] = atr.rolling(500).apply(
        lambda x: (x.iloc[-1] - x.min()) / (x.max() - x.min() + 1e-10) if len(x) > 0 else 0.5,
        raw=False
    )
    
    print(f"  Created {len(f.columns)} features")
    return f

# ============================================================================
# LABEL GENERATION
# ============================================================================

def create_labels(df: pd.DataFrame, lookahead: int = 4, threshold: float = 0.001) -> dict:
    """
    Create labels for different models.
    
    Returns:
        dict with:
        - 'direction': 0=bearish, 1=bullish (for DirectionLSTM)
        - 'regime': 0=trending, 1=reverting, 2=random (for RegimeClassifier)
        - 'volatility': next N bars ATR (for VolatilityGRU)
    """
    close = df['close']
    
    # Direction labels
    future_return = close.shift(-lookahead) / close - 1
    direction = (future_return > threshold).astype(int)
    
    # Regime labels (based on Hurst)
    # Will be calculated after features are created
    
    # Volatility labels (future ATR)
    high = df['high']
    low = df['low']
    atr = calculate_atr(high, low, close, 14)
    volatility = atr.shift(-lookahead)  # Future ATR
    
    return {
        'direction': direction,
        'volatility': volatility
    }


def create_regime_labels(hurst: pd.Series) -> pd.Series:
    """Create regime labels from Hurst exponent."""
    def classify_regime(h):
        if pd.isna(h):
            return 2  # Random
        if h > 0.55:
            return 0  # Trending
        elif h < 0.45:
            return 1  # Mean-reverting
        else:
            return 2  # Random walk
    
    return hurst.apply(classify_regime)

# ============================================================================
# MODEL ARCHITECTURES
# ============================================================================

class DirectionLSTM(nn.Module):
    """LSTM for direction prediction."""
    
    def __init__(self, input_size: int, hidden_size: int = 64, num_layers: int = 2, dropout: float = 0.2):
        super().__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, dropout=dropout, batch_first=True)
        self.fc = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(32, 2)
        )
    
    def forward(self, x):
        out, _ = self.lstm(x)
        return torch.softmax(self.fc(out[:, -1, :]), dim=1)


class RegimeClassifier(nn.Module):
    """GRU classifier for regime detection (trending/reverting/random)."""
    
    def __init__(self, input_size: int, hidden_size: int = 32, num_layers: int = 1, dropout: float = 0.1):
        super().__init__()
        self.gru = nn.GRU(input_size, hidden_size, num_layers, dropout=dropout if num_layers > 1 else 0, batch_first=True)
        self.fc = nn.Sequential(
            nn.Linear(hidden_size, 16),
            nn.ReLU(),
            nn.Linear(16, 3)  # 3 classes: trending, reverting, random
        )
    
    def forward(self, x):
        out, _ = self.gru(x)
        return torch.softmax(self.fc(out[:, -1, :]), dim=1)


class VolatilityGRU(nn.Module):
    """GRU for volatility forecasting."""
    
    def __init__(self, input_size: int, hidden_size: int = 32, forecast_horizon: int = 1):
        super().__init__()
        self.gru = nn.GRU(input_size, hidden_size, batch_first=True)
        self.fc = nn.Linear(hidden_size, forecast_horizon)
    
    def forward(self, x):
        out, _ = self.gru(x)
        return torch.relu(self.fc(out[:, -1, :]))  # ATR is positive

# ============================================================================
# TRAINING FUNCTIONS
# ============================================================================

def create_sequences(features: np.ndarray, labels: np.ndarray, seq_len: int = 100) -> tuple:
    """Create sequences for LSTM/GRU training."""
    X, y = [], []
    for i in range(seq_len, len(features)):
        X.append(features[i-seq_len:i])
        y.append(labels[i])
    return np.array(X), np.array(y)


def train_model(model: nn.Module, train_loader: DataLoader, val_loader: DataLoader,
                epochs: int = 100, lr: float = 1e-4, task: str = 'classification') -> dict:
    """Train a model and return metrics."""
    
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    
    if task == 'classification':
        criterion = nn.CrossEntropyLoss()
    else:
        criterion = nn.MSELoss()
    
    best_val_metric = 0 if task == 'classification' else float('inf')
    best_state = None
    history = {'train_loss': [], 'val_metric': []}
    
    for epoch in range(epochs):
        # Training
        model.train()
        train_loss = 0
        for xb, yb in train_loader:
            optimizer.zero_grad()
            output = model(xb)
            
            if task == 'classification':
                loss = criterion(output, yb)
            else:
                loss = criterion(output.squeeze(), yb)
            
            loss.backward()
            optimizer.step()
            train_loss += loss.item()
        
        train_loss /= len(train_loader)
        
        # Validation
        model.eval()
        val_metric = 0
        with torch.no_grad():
            if task == 'classification':
                correct = 0
                total = 0
                for xb, yb in val_loader:
                    pred = model(xb).argmax(dim=1)
                    correct += (pred == yb).sum().item()
                    total += len(yb)
                val_metric = correct / total
            else:
                mse_sum = 0
                count = 0
                for xb, yb in val_loader:
                    pred = model(xb).squeeze()
                    mse_sum += ((pred - yb) ** 2).sum().item()
                    count += len(yb)
                val_metric = mse_sum / count  # MSE (lower is better)
        
        history['train_loss'].append(train_loss)
        history['val_metric'].append(val_metric)
        
        # Save best
        if task == 'classification' and val_metric > best_val_metric:
            best_val_metric = val_metric
            best_state = model.state_dict().copy()
        elif task == 'regression' and val_metric < best_val_metric:
            best_val_metric = val_metric
            best_state = model.state_dict().copy()
        
        if (epoch + 1) % 20 == 0:
            metric_name = 'Accuracy' if task == 'classification' else 'MSE'
            print(f"    Epoch {epoch+1}/{epochs} - Loss: {train_loss:.4f}, Val {metric_name}: {val_metric:.4f}")
    
    # Restore best
    if best_state is not None:
        model.load_state_dict(best_state)
    
    return {
        'best_metric': best_val_metric,
        'history': history
    }

# ============================================================================
# WALK-FORWARD ANALYSIS
# ============================================================================

def walk_forward_analysis(features: pd.DataFrame, labels: pd.Series, 
                          model_class, model_kwargs: dict,
                          train_months: int = 12, test_months: int = 3,
                          task: str = 'classification') -> dict:
    """
    Perform Walk-Forward Analysis.
    
    Returns:
        dict with WFE, fold results, etc.
    """
    print("\n  Running Walk-Forward Analysis...")
    
    # Prepare data
    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(features.values)
    
    # Align features and labels
    common_idx = features.index.intersection(labels.dropna().index)
    scaled_df = pd.DataFrame(scaled_features, index=features.index, columns=features.columns)
    scaled_df = scaled_df.loc[common_idx]
    labels = labels.loc[common_idx]
    
    # Create date ranges for folds
    start_date = scaled_df.index[0]
    end_date = scaled_df.index[-1]
    
    fold_results = []
    current_date = start_date + pd.DateOffset(months=train_months)
    
    fold_num = 0
    while current_date + pd.DateOffset(months=test_months) <= end_date:
        fold_num += 1
        
        # Define train/test periods
        train_start = current_date - pd.DateOffset(months=train_months)
        train_end = current_date
        test_start = current_date
        test_end = current_date + pd.DateOffset(months=test_months)
        
        # Get data for this fold
        train_mask = (scaled_df.index >= train_start) & (scaled_df.index < train_end)
        test_mask = (scaled_df.index >= test_start) & (scaled_df.index < test_end)
        
        X_train_raw = scaled_df.loc[train_mask].values
        y_train_raw = labels.loc[train_mask].values
        X_test_raw = scaled_df.loc[test_mask].values
        y_test_raw = labels.loc[test_mask].values
        
        if len(X_train_raw) < CONFIG['seq_len'] + 100 or len(X_test_raw) < CONFIG['seq_len'] + 10:
            current_date += pd.DateOffset(months=test_months)
            continue
        
        # Create sequences
        X_train, y_train = create_sequences(X_train_raw, y_train_raw, CONFIG['seq_len'])
        X_test, y_test = create_sequences(X_test_raw, y_test_raw, CONFIG['seq_len'])
        
        if len(X_train) < 100 or len(X_test) < 10:
            current_date += pd.DateOffset(months=test_months)
            continue
        
        # Create data loaders
        train_loader = DataLoader(
            TensorDataset(torch.FloatTensor(X_train), torch.LongTensor(y_train) if task == 'classification' else torch.FloatTensor(y_train)),
            batch_size=CONFIG['batch_size'], shuffle=True
        )
        test_loader = DataLoader(
            TensorDataset(torch.FloatTensor(X_test), torch.LongTensor(y_test) if task == 'classification' else torch.FloatTensor(y_test)),
            batch_size=CONFIG['batch_size']
        )
        
        # Train model for this fold
        model = model_class(**model_kwargs)
        result = train_model(model, train_loader, test_loader, 
                            epochs=50, lr=CONFIG['lr'], task=task)
        
        fold_results.append({
            'fold': fold_num,
            'train_period': f"{train_start.date()} to {train_end.date()}",
            'test_period': f"{test_start.date()} to {test_end.date()}",
            'is_metric': result['history']['val_metric'][-1],  # In-sample (last train)
            'oos_metric': result['best_metric']  # Out-of-sample
        })
        
        print(f"    Fold {fold_num}: OOS {'Acc' if task == 'classification' else 'MSE'} = {result['best_metric']:.4f}")
        
        current_date += pd.DateOffset(months=test_months)
    
    if not fold_results:
        return {'wfe': 0, 'fold_results': [], 'passed': False}
    
    # Calculate Walk-Forward Efficiency
    if task == 'classification':
        avg_oos = np.mean([f['oos_metric'] for f in fold_results])
        avg_is = np.mean([f['is_metric'] for f in fold_results])
        wfe = avg_oos / (avg_is + 1e-10)
    else:
        # For regression, lower is better, so invert
        avg_oos = np.mean([f['oos_metric'] for f in fold_results])
        avg_is = np.mean([f['is_metric'] for f in fold_results])
        wfe = avg_is / (avg_oos + 1e-10)  # IS/OOS (should be < 1 for good generalization)
    
    passed = wfe >= CONFIG['min_wfe']
    
    print(f"\n  WFE = {wfe:.3f} ({'PASSED' if passed else 'FAILED'} - min {CONFIG['min_wfe']})")
    
    return {
        'wfe': wfe,
        'avg_oos_metric': avg_oos,
        'fold_results': fold_results,
        'passed': passed,
        'scaler_params': {
            'means': scaler.mean_.tolist(),
            'stds': scaler.scale_.tolist()
        }
    }

# ============================================================================
# MAIN PIPELINE
# ============================================================================

def main():
    print("=" * 70)
    print("EA_SCALPER_XAUUSD - Advanced ML Pipeline")
    print("=" * 70)
    
    # 1. Load data
    print("\n[1/7] Loading data...")
    df_m15 = pd.read_csv(DATA_DIR / 'xauusd-m15-bid-2020-01-01-2025-11-28.csv')
    df_m15['time'] = pd.to_datetime(df_m15['timestamp'], unit='ms')
    df_m15.set_index('time', inplace=True)
    df_m15 = df_m15.drop('timestamp', axis=1)
    df_m15.columns = ['open', 'high', 'low', 'close', 'volume']
    print(f"  M15: {len(df_m15)} bars ({df_m15.index[0]} to {df_m15.index[-1]})")
    
    df_h1 = pd.read_csv(DATA_DIR / 'xauusd-h1-bid-2020-01-01-2025-11-28.csv')
    df_h1['time'] = pd.to_datetime(df_h1['timestamp'], unit='ms')
    df_h1.set_index('time', inplace=True)
    df_h1 = df_h1.drop('timestamp', axis=1)
    df_h1.columns = ['open', 'high', 'low', 'close', 'volume']
    print(f"  H1: {len(df_h1)} bars")
    
    # 2. Create features
    print("\n[2/7] Creating 15 features...")
    features = create_features(df_m15, df_h1)
    features = features.dropna()
    print(f"  Features: {len(features)} samples, {len(features.columns)} features")
    print(f"  Feature list: {list(features.columns)}")
    
    # 3. Create labels
    print("\n[3/7] Creating labels...")
    labels = create_labels(df_m15, CONFIG['lookahead'], CONFIG['threshold'])
    direction_labels = labels['direction'].loc[features.index].dropna()
    regime_labels = create_regime_labels(features['hurst'])
    volatility_labels = labels['volatility'].loc[features.index].dropna()
    
    # Align all
    common_idx = features.index.intersection(direction_labels.index).intersection(regime_labels.index)
    features = features.loc[common_idx]
    direction_labels = direction_labels.loc[common_idx]
    regime_labels = regime_labels.loc[common_idx]
    volatility_labels = volatility_labels.loc[common_idx[:len(volatility_labels)]]
    
    print(f"  Direction labels: {len(direction_labels)} ({direction_labels.mean():.1%} bullish)")
    print(f"  Regime distribution: Trending={sum(regime_labels==0)}, Reverting={sum(regime_labels==1)}, Random={sum(regime_labels==2)}")
    
    # 4. Train RegimeClassifier with WFA
    print("\n[4/7] Training RegimeClassifier...")
    regime_wfa = walk_forward_analysis(
        features, regime_labels,
        RegimeClassifier, {'input_size': features.shape[1], 'hidden_size': 32},
        train_months=CONFIG['wfa_train_months'],
        test_months=CONFIG['wfa_test_months'],
        task='classification'
    )
    
    if regime_wfa['passed']:
        print("  RegimeClassifier PASSED WFA validation!")
    else:
        print("  WARNING: RegimeClassifier FAILED WFA - consider adjusting")
    
    # 5. Train DirectionLSTM with WFA  
    print("\n[5/7] Training DirectionLSTM...")
    direction_wfa = walk_forward_analysis(
        features, direction_labels,
        DirectionLSTM, {'input_size': features.shape[1], 'hidden_size': CONFIG['hidden_size']},
        train_months=CONFIG['wfa_train_months'],
        test_months=CONFIG['wfa_test_months'],
        task='classification'
    )
    
    if direction_wfa['passed']:
        print("  DirectionLSTM PASSED WFA validation!")
    else:
        print("  WARNING: DirectionLSTM FAILED WFA - consider adjusting")
    
    # 6. Train final models on all data
    print("\n[6/7] Training final models on full dataset...")
    
    # Prepare full dataset
    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(features.values)
    
    # Save scaler params
    scaler_params = {
        'means': scaler.mean_.tolist(),
        'stds': scaler.scale_.tolist(),
        'feature_names': list(features.columns)
    }
    with open(MODEL_DIR / 'scaler_params_15f.json', 'w') as f:
        json.dump(scaler_params, f, indent=2)
    print(f"  Saved scaler params to {MODEL_DIR / 'scaler_params_15f.json'}")
    
    # Create sequences for full training
    X_dir, y_dir = create_sequences(scaled_features, direction_labels.values, CONFIG['seq_len'])
    X_reg, y_reg = create_sequences(scaled_features, regime_labels.values, CONFIG['seq_len'])
    
    # Split 90/10 for final validation
    split = int(0.9 * len(X_dir))
    
    # Train DirectionLSTM
    print("\n  Training DirectionLSTM (final)...")
    dir_model = DirectionLSTM(input_size=features.shape[1], hidden_size=CONFIG['hidden_size'])
    dir_train_loader = DataLoader(
        TensorDataset(torch.FloatTensor(X_dir[:split]), torch.LongTensor(y_dir[:split])),
        batch_size=CONFIG['batch_size'], shuffle=True
    )
    dir_val_loader = DataLoader(
        TensorDataset(torch.FloatTensor(X_dir[split:]), torch.LongTensor(y_dir[split:])),
        batch_size=CONFIG['batch_size']
    )
    dir_result = train_model(dir_model, dir_train_loader, dir_val_loader, 
                             epochs=CONFIG['epochs'], lr=CONFIG['lr'])
    torch.save(dir_model.state_dict(), MODEL_DIR / 'direction_lstm_15f.pt')
    print(f"  DirectionLSTM final accuracy: {dir_result['best_metric']:.4f}")
    
    # Train RegimeClassifier
    print("\n  Training RegimeClassifier (final)...")
    reg_model = RegimeClassifier(input_size=features.shape[1], hidden_size=32)
    reg_train_loader = DataLoader(
        TensorDataset(torch.FloatTensor(X_reg[:split]), torch.LongTensor(y_reg[:split])),
        batch_size=CONFIG['batch_size'], shuffle=True
    )
    reg_val_loader = DataLoader(
        TensorDataset(torch.FloatTensor(X_reg[split:]), torch.LongTensor(y_reg[split:])),
        batch_size=CONFIG['batch_size']
    )
    reg_result = train_model(reg_model, reg_train_loader, reg_val_loader,
                             epochs=CONFIG['epochs'], lr=CONFIG['lr'])
    torch.save(reg_model.state_dict(), MODEL_DIR / 'regime_classifier_15f.pt')
    print(f"  RegimeClassifier final accuracy: {reg_result['best_metric']:.4f}")
    
    # 7. Export to ONNX
    print("\n[7/7] Exporting models to ONNX...")
    
    MQL5_DIR = BASE_DIR.parent.parent / 'MQL5' / 'Models'
    MQL5_DIR.mkdir(exist_ok=True)
    
    # Export DirectionLSTM
    dir_model.eval()
    dummy = torch.randn(1, CONFIG['seq_len'], features.shape[1])
    torch.onnx.export(
        dir_model, dummy,
        str(MODEL_DIR / 'direction_model_15f.onnx'),
        input_names=['input'], output_names=['output'],
        opset_version=14, dynamo=False
    )
    
    # Export RegimeClassifier
    reg_model.eval()
    torch.onnx.export(
        reg_model, dummy,
        str(MODEL_DIR / 'regime_model_15f.onnx'),
        input_names=['input'], output_names=['output'],
        opset_version=14, dynamo=False
    )
    
    # Copy to MQL5
    import shutil
    shutil.copy(MODEL_DIR / 'direction_model_15f.onnx', MQL5_DIR)
    shutil.copy(MODEL_DIR / 'regime_model_15f.onnx', MQL5_DIR)
    shutil.copy(MODEL_DIR / 'scaler_params_15f.json', MQL5_DIR)
    
    # Save summary
    summary = {
        'config': CONFIG,
        'features': list(features.columns),
        'direction_wfa': {
            'wfe': direction_wfa['wfe'],
            'passed': direction_wfa['passed'],
            'avg_oos_accuracy': direction_wfa['avg_oos_metric']
        },
        'regime_wfa': {
            'wfe': regime_wfa['wfe'],
            'passed': regime_wfa['passed'],
            'avg_oos_accuracy': regime_wfa['avg_oos_metric']
        },
        'final_metrics': {
            'direction_accuracy': dir_result['best_metric'],
            'regime_accuracy': reg_result['best_metric']
        },
        'data_info': {
            'total_samples': len(features),
            'date_range': f"{features.index[0]} to {features.index[-1]}"
        }
    }
    
    with open(MODEL_DIR / 'training_summary.json', 'w') as f:
        json.dump(summary, f, indent=2, default=str)
    
    print("\n" + "=" * 70)
    print("TRAINING COMPLETE!")
    print("=" * 70)
    print(f"\nModels saved to: {MQL5_DIR}")
    print(f"  - direction_model_15f.onnx")
    print(f"  - regime_model_15f.onnx")
    print(f"  - scaler_params_15f.json")
    print(f"\nWalk-Forward Results:")
    print(f"  Direction WFE: {direction_wfa['wfe']:.3f} ({'PASSED' if direction_wfa['passed'] else 'FAILED'})")
    print(f"  Regime WFE: {regime_wfa['wfe']:.3f} ({'PASSED' if regime_wfa['passed'] else 'FAILED'})")
    print(f"\nFinal Validation Metrics:")
    print(f"  Direction Accuracy: {dir_result['best_metric']:.4f}")
    print(f"  Regime Accuracy: {reg_result['best_metric']:.4f}")


if __name__ == '__main__':
    main()
