"""
EA_SCALPER_XAUUSD - Complete ML Training Pipeline
==================================================
15 Features + Walk-Forward Analysis + ONNX Export

Features:
1. returns          - Simple returns
2. log_returns      - Log returns
3. range_pct        - (high-low)/close
4. rsi_14           - RSI(14) / 100
5. atr_norm         - ATR(14) / close
6. ma_dist          - (close - MA20) / MA20
7. bb_pos           - Bollinger Band position
8. hurst            - Hurst Exponent (rolling 100)
9. entropy_norm     - Shannon Entropy / 4
10. session         - 0=Asia, 1=London, 2=NY
11. hour_sin        - sin(2π × hour / 24)
12. hour_cos        - cos(2π × hour / 24)
13. momentum_5      - (close - close[5]) / close[5]
14. momentum_20     - (close - close[20]) / close[20]
15. volatility_ratio - ATR / ATR_20_avg

Author: Franco + Singularity AI
Date: 2025-11-28
"""

import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
from sklearn.preprocessing import StandardScaler
import json
from pathlib import Path
import shutil
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

print('='*70)
print('EA_SCALPER_XAUUSD - Complete ML Training (15 Features + WFA)')
print('='*70)

# Paths
BASE = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub')
DATA_FILE_MT5 = BASE / 'ml_pipeline/data/xauusd-m15-bid-2020-01-01-2025-11-28_MT5.csv'
DATA_FILE_CLEAN = BASE / 'ml_pipeline/data/xauusd_m15_clean.csv'
MODELS_DIR = BASE / 'ml_pipeline/models'
MQL5_MODELS = BASE.parent / 'MQL5' / 'Models'
MODELS_DIR.mkdir(exist_ok=True)
MQL5_MODELS.mkdir(exist_ok=True)


def load_mt5_data(filepath):
    """Load MT5 exported data (tab-separated, no headers)"""
    df = pd.read_csv(
        filepath, 
        sep='\t',
        names=['date', 'time', 'open', 'high', 'low', 'close', 'volume'],
        parse_dates=[[0, 1]]
    )
    df = df.rename(columns={'date_time': 'time'})
    df = df.set_index('time')
    return df


def load_clean_data(filepath):
    """Load clean CSV data"""
    df = pd.read_csv(filepath, index_col='time', parse_dates=True)
    return df

# Configuration
SEQ_LEN = 100           # Sequence length for LSTM
LOOKAHEAD = 5           # Bars to look ahead for label
THRESHOLD = 0.0015      # 0.15% minimum move for signal
VALIDATION_SPLIT = 0.2  # 20% validation
N_FEATURES = 15
EPOCHS = 100
BATCH_SIZE = 64
LEARNING_RATE = 1e-4
EARLY_STOPPING = 15
WFA_SPLITS = 10         # Walk-Forward Analysis splits

# ============================================================================
# FEATURE ENGINEERING FUNCTIONS
# ============================================================================

def calculate_rsi(prices: pd.Series, period: int = 14) -> pd.Series:
    """Calculate RSI indicator"""
    delta = prices.diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    rs = gain / loss
    return 100 - (100 / (1 + rs))


def calculate_atr(high: pd.Series, low: pd.Series, close: pd.Series, period: int = 14) -> pd.Series:
    """Calculate ATR indicator"""
    tr1 = high - low
    tr2 = abs(high - close.shift(1))
    tr3 = abs(low - close.shift(1))
    tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
    return tr.rolling(window=period).mean()


def calculate_hurst_exponent(prices: np.ndarray, max_lag: int = 20) -> float:
    """Calculate Hurst Exponent using R/S analysis"""
    # Remove NaN values
    prices = prices[~np.isnan(prices)]
    
    if len(prices) < max_lag * 2:
        return 0.5
    
    lags = range(2, max_lag)
    rs_values = []
    
    for lag in lags:
        subseries_count = len(prices) // lag
        rs_list = []
        
        for i in range(subseries_count):
            subseries = prices[i * lag:(i + 1) * lag]
            if len(subseries) < 2:
                continue
            mean = np.mean(subseries)
            cumdev = np.cumsum(subseries - mean)
            R = np.max(cumdev) - np.min(cumdev)
            S = np.std(subseries, ddof=1)
            if S > 0:
                rs_list.append(R / S)
        
        if rs_list:
            rs_values.append(np.mean(rs_list))
    
    if len(rs_values) < 2:
        return 0.5
    
    log_lags = np.log(list(lags)[:len(rs_values)])
    log_rs = np.log(rs_values)
    
    slope, _ = np.polyfit(log_lags, log_rs, 1)
    return np.clip(slope, 0, 1)


def calculate_shannon_entropy(returns: np.ndarray, bins: int = 10) -> float:
    """Calculate Shannon Entropy"""
    # Remove NaN values
    returns = returns[~np.isnan(returns)]
    
    if len(returns) < 10:
        return 0
    
    try:
        hist, _ = np.histogram(returns, bins=bins, density=True)
        hist = hist[hist > 0]
        return -np.sum(hist * np.log2(hist)) if len(hist) > 0 else 0
    except:
        return 0


def get_session(hour: int) -> int:
    """Get trading session: 0=Asia, 1=London, 2=NY"""
    if hour < 7:
        return 0  # Asia
    elif hour < 15:
        return 1  # London
    else:
        return 2  # NY


def create_all_features(df: pd.DataFrame) -> pd.DataFrame:
    """Create all 15 features"""
    print('\n[FEATURES] Creating 15 features...')
    
    features = pd.DataFrame(index=df.index)
    
    # 1-2: Returns
    features['returns'] = df['close'].pct_change()
    features['log_returns'] = np.log(df['close'] / df['close'].shift(1))
    
    # 3: Range percentage
    features['range_pct'] = (df['high'] - df['low']) / df['close']
    
    # 4: RSI
    features['rsi_14'] = calculate_rsi(df['close'], 14) / 100
    
    # 5: ATR normalized
    atr = calculate_atr(df['high'], df['low'], df['close'], 14)
    features['atr_norm'] = atr / df['close']
    
    # 6: MA distance
    ma20 = df['close'].rolling(20).mean()
    features['ma_dist'] = (df['close'] - ma20) / ma20
    
    # 7: Bollinger Band position
    bb_mid = df['close'].rolling(20).mean()
    bb_std = df['close'].rolling(20).std()
    bb_width = 4 * bb_std  # 2 std each side
    features['bb_pos'] = (df['close'] - bb_mid) / bb_width.replace(0, np.nan)
    
    # 8: Hurst Exponent (rolling)
    print('  - Calculating Hurst Exponent (slow)...')
    hurst_window = 100
    hurst_values = []
    prices = df['close'].values
    for i in range(len(prices)):
        if i < hurst_window:
            hurst_values.append(0.5)
        else:
            h = calculate_hurst_exponent(prices[i-hurst_window:i])
            hurst_values.append(h)
    features['hurst'] = hurst_values
    
    # 9: Shannon Entropy (rolling)
    print('  - Calculating Shannon Entropy...')
    entropy_window = 100
    returns_arr = df['close'].pct_change().values
    entropy_values = []
    for i in range(len(returns_arr)):
        if i < entropy_window:
            entropy_values.append(0)
        else:
            e = calculate_shannon_entropy(returns_arr[i-entropy_window:i])
            entropy_values.append(e / 4.0)  # Normalize
    features['entropy_norm'] = entropy_values
    
    # 10: Session
    features['session'] = df.index.hour.map(get_session)
    
    # 11-12: Time cyclical features
    features['hour_sin'] = np.sin(2 * np.pi * df.index.hour / 24)
    features['hour_cos'] = np.cos(2 * np.pi * df.index.hour / 24)
    
    # 13-14: Momentum
    features['momentum_5'] = (df['close'] - df['close'].shift(5)) / df['close'].shift(5)
    features['momentum_20'] = (df['close'] - df['close'].shift(20)) / df['close'].shift(20)
    
    # 15: Volatility ratio
    atr_20_avg = atr.rolling(20).mean()
    features['volatility_ratio'] = atr / atr_20_avg.replace(0, np.nan)
    
    # Drop NaN rows
    features = features.dropna()
    print(f'  - Created {len(features)} samples with {len(features.columns)} features')
    
    return features


def create_labels(df: pd.DataFrame, lookahead: int = 5, threshold: float = 0.001) -> pd.Series:
    """Create direction labels"""
    future_return = df['close'].shift(-lookahead) / df['close'] - 1
    labels = (future_return > threshold).astype(int)
    return labels


# ============================================================================
# MODEL DEFINITION
# ============================================================================

class DirectionLSTM(nn.Module):
    """LSTM for direction prediction"""
    
    def __init__(self, input_size=15, hidden_size=64, num_layers=2, dropout=0.3):
        super().__init__()
        
        self.lstm = nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            dropout=dropout if num_layers > 1 else 0,
            batch_first=True
        )
        
        self.fc = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(32, 2)  # [P(bearish), P(bullish)]
        )
    
    def forward(self, x):
        lstm_out, _ = self.lstm(x)
        last_hidden = lstm_out[:, -1, :]
        logits = self.fc(last_hidden)
        return torch.softmax(logits, dim=1)


# ============================================================================
# TRAINING FUNCTIONS
# ============================================================================

def train_model(X_train, y_train, X_val, y_val, epochs=100, patience=15):
    """Train model with early stopping"""
    
    model = DirectionLSTM(input_size=X_train.shape[2])
    optimizer = torch.optim.Adam(model.parameters(), lr=LEARNING_RATE)
    criterion = nn.CrossEntropyLoss()
    
    train_loader = DataLoader(
        TensorDataset(torch.FloatTensor(X_train), torch.LongTensor(y_train)),
        batch_size=BATCH_SIZE, shuffle=True
    )
    val_loader = DataLoader(
        TensorDataset(torch.FloatTensor(X_val), torch.LongTensor(y_val)),
        batch_size=BATCH_SIZE
    )
    
    best_val_acc = 0
    best_state = None
    patience_counter = 0
    
    for epoch in range(epochs):
        # Train
        model.train()
        for xb, yb in train_loader:
            optimizer.zero_grad()
            loss = criterion(model(xb), yb)
            loss.backward()
            optimizer.step()
        
        # Validate
        model.eval()
        correct = 0
        total = 0
        with torch.no_grad():
            for xb, yb in val_loader:
                pred = model(xb).argmax(dim=1)
                correct += (pred == yb).sum().item()
                total += yb.size(0)
        
        val_acc = correct / total
        
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            best_state = model.state_dict().copy()
            patience_counter = 0
        else:
            patience_counter += 1
        
        if (epoch + 1) % 20 == 0:
            print(f'    Epoch {epoch+1}/{epochs} - Val Acc: {val_acc:.4f} (Best: {best_val_acc:.4f})')
        
        if patience_counter >= patience:
            print(f'    Early stopping at epoch {epoch+1}')
            break
    
    if best_state:
        model.load_state_dict(best_state)
    
    return model, best_val_acc


def walk_forward_analysis(X, y, n_splits=10):
    """Walk-Forward Analysis for robust validation"""
    
    print(f'\n[WFA] Running Walk-Forward Analysis ({n_splits} splits)...')
    
    window_size = len(X) // n_splits
    accuracies = []
    
    for i in range(n_splits - 1):
        start_idx = i * window_size
        end_idx = (i + 2) * window_size
        
        if end_idx > len(X):
            break
        
        window_X = X[start_idx:end_idx]
        window_y = y[start_idx:end_idx]
        
        split_idx = int(len(window_X) * 0.8)
        X_train, X_test = window_X[:split_idx], window_X[split_idx:]
        y_train, y_test = window_y[:split_idx], window_y[split_idx:]
        
        # Train on this window
        model, _ = train_model(X_train, y_train, X_test, y_test, epochs=50, patience=5)
        
        # Evaluate
        model.eval()
        with torch.no_grad():
            test_loader = DataLoader(
                TensorDataset(torch.FloatTensor(X_test), torch.LongTensor(y_test)),
                batch_size=BATCH_SIZE
            )
            correct = 0
            total = 0
            for xb, yb in test_loader:
                pred = model(xb).argmax(dim=1)
                correct += (pred == yb).sum().item()
                total += yb.size(0)
        
        acc = correct / total
        accuracies.append(acc)
        print(f'  Window {i+1}: OOS Accuracy = {acc:.4f}')
    
    mean_acc = np.mean(accuracies)
    std_acc = np.std(accuracies)
    wfe = mean_acc - std_acc  # Walk-Forward Efficiency
    
    print(f'\n[WFA RESULTS]')
    print(f'  Mean OOS Accuracy: {mean_acc:.4f} (+/- {std_acc:.4f})')
    print(f'  Walk-Forward Efficiency (WFE): {wfe:.4f}')
    print(f'  WFE >= 0.6? {"YES ✓" if wfe >= 0.6 else "NO ✗"}')
    
    return accuracies, wfe


# ============================================================================
# MAIN PIPELINE
# ============================================================================

def main():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # 1. Load Data - Try MT5 format first, then clean format
    print(f'\n[1/7] Loading data...')
    try:
        if DATA_FILE_MT5.exists():
            print(f'  Loading MT5 format: {DATA_FILE_MT5.name}')
            df = load_mt5_data(DATA_FILE_MT5)
            data_file_used = DATA_FILE_MT5
        else:
            raise FileNotFoundError("MT5 file not found")
    except Exception as e:
        print(f'  MT5 format failed ({e}), trying clean format...')
        df = load_clean_data(DATA_FILE_CLEAN)
        data_file_used = DATA_FILE_CLEAN
    
    print(f'  Loaded {len(df)} bars ({df.index[0]} to {df.index[-1]})')
    
    # 2. Create Features
    print(f'\n[2/7] Creating 15 features...')
    features = create_all_features(df)
    
    # 3. Create Labels
    print(f'\n[3/7] Creating labels (lookahead={LOOKAHEAD}, threshold={THRESHOLD})...')
    labels = create_labels(df, LOOKAHEAD, THRESHOLD)
    
    # Align
    common_idx = features.index.intersection(labels.dropna().index)
    features = features.loc[common_idx]
    labels = labels.loc[common_idx]
    print(f'  Labels: {len(labels)} ({labels.mean():.1%} bullish)')
    
    # 4. Normalize
    print(f'\n[4/7] Normalizing features...')
    scaler = StandardScaler()
    scaled = scaler.fit_transform(features.values)
    
    # Save scaler params
    scaler_params = {
        'means': scaler.mean_.tolist(),
        'stds': scaler.scale_.tolist(),
        'feature_names': features.columns.tolist()
    }
    with open(MODELS_DIR / 'scaler_params_15f.json', 'w') as f:
        json.dump(scaler_params, f, indent=2)
    print(f'  Scaler params saved')
    
    # 5. Create Sequences
    print(f'\n[5/7] Creating sequences (seq_len={SEQ_LEN})...')
    X, y = [], []
    for i in range(SEQ_LEN, len(scaled)):
        X.append(scaled[i-SEQ_LEN:i])
        y.append(labels.iloc[i])
    X, y = np.array(X), np.array(y)
    print(f'  Created {len(X)} sequences')
    
    # Split
    split = int(len(X) * (1 - VALIDATION_SPLIT))
    X_train, X_val = X[:split], X[split:]
    y_train, y_val = y[:split], y[split:]
    print(f'  Train: {len(X_train)}, Val: {len(X_val)}')
    
    # 6. Walk-Forward Analysis
    accuracies, wfe = walk_forward_analysis(X, y, WFA_SPLITS)
    
    # 7. Final Training
    print(f'\n[6/7] Final training on full data...')
    model, final_acc = train_model(X_train, y_train, X_val, y_val, EPOCHS, EARLY_STOPPING)
    print(f'  Final Validation Accuracy: {final_acc:.4f}')
    
    # 8. Export ONNX
    print(f'\n[7/7] Exporting ONNX model...')
    model.eval()
    
    dummy_input = torch.randn(1, SEQ_LEN, N_FEATURES)
    onnx_path = MODELS_DIR / f'direction_15f_{timestamp}.onnx'
    
    torch.onnx.export(
        model,
        dummy_input,
        str(onnx_path),
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={'input': {0: 'batch'}, 'output': {0: 'batch'}},
        opset_version=11
    )
    print(f'  Saved: {onnx_path}')
    
    # Copy to standard name and MQL5
    shutil.copy(onnx_path, MODELS_DIR / 'direction_model_15f.onnx')
    shutil.copy(onnx_path, MQL5_MODELS / 'direction_model_15f.onnx')
    shutil.copy(MODELS_DIR / 'scaler_params_15f.json', MQL5_MODELS / 'scaler_params_15f.json')
    
    # Save training report
    report = {
        'timestamp': timestamp,
        'data_file': str(data_file_used.name),
        'total_bars': len(df),
        'features': N_FEATURES,
        'feature_names': features.columns.tolist(),
        'sequence_length': SEQ_LEN,
        'lookahead': LOOKAHEAD,
        'threshold': THRESHOLD,
        'train_samples': len(X_train),
        'val_samples': len(X_val),
        'epochs_config': EPOCHS,
        'batch_size': BATCH_SIZE,
        'learning_rate': LEARNING_RATE,
        'wfa_splits': WFA_SPLITS,
        'wfa_accuracies': accuracies,
        'wfa_mean_accuracy': float(np.mean(accuracies)),
        'wfa_std': float(np.std(accuracies)),
        'walk_forward_efficiency': float(wfe),
        'wfe_passed': wfe >= 0.6,
        'final_val_accuracy': float(final_acc),
        'model_path': str(onnx_path.name)
    }
    
    with open(MODELS_DIR / f'training_report_{timestamp}.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    # Summary
    print('\n' + '='*70)
    print('TRAINING COMPLETE')
    print('='*70)
    print(f'Features:           {N_FEATURES}')
    print(f'Train Samples:      {len(X_train):,}')
    print(f'Val Samples:        {len(X_val):,}')
    print(f'Final Val Accuracy: {final_acc:.4f} ({final_acc*100:.1f}%)')
    print(f'WFA Mean Accuracy:  {np.mean(accuracies):.4f}')
    print(f'Walk-Forward Eff:   {wfe:.4f} {"(PASSED ✓)" if wfe >= 0.6 else "(FAILED ✗)"}')
    print(f'Model saved to:     MQL5/Models/direction_model_15f.onnx')
    print('='*70)
    
    return report


if __name__ == '__main__':
    report = main()
