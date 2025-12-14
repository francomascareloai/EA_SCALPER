"""
Fast Training Script - Trains models without full WFA
For quick iteration and testing
"""
import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
from sklearn.preprocessing import StandardScaler
from pathlib import Path
import json
import shutil
import warnings
warnings.filterwarnings('ignore')

BASE_DIR = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub\ml_pipeline')
DATA_DIR = BASE_DIR / 'data'
MODEL_DIR = BASE_DIR / 'models'
MQL5_DIR = BASE_DIR.parent.parent / 'MQL5' / 'Models'
MODEL_DIR.mkdir(exist_ok=True)
MQL5_DIR.mkdir(exist_ok=True)

print("=" * 60)
print("FAST TRAINING - Direction + Regime Models")
print("=" * 60)

# Load data
print("\n[1/6] Loading data...")
df = pd.read_csv(DATA_DIR / 'xauusd-m15-bid-2020-01-01-2025-11-28.csv')
df['time'] = pd.to_datetime(df['timestamp'], unit='ms')
df.set_index('time', inplace=True)
df.columns = ['timestamp', 'open', 'high', 'low', 'close', 'volume']
df = df.drop('timestamp', axis=1)
print(f"  Loaded {len(df)} bars")

# Create features (simplified - without slow Hurst calculation)
print("\n[2/6] Creating features...")

def calc_rsi(prices, period=14):
    delta = prices.diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    return 100 - (100 / (1 + gain / (loss + 1e-10)))

def calc_atr(high, low, close, period=14):
    tr = pd.concat([high - low, abs(high - close.shift(1)), abs(low - close.shift(1))], axis=1).max(axis=1)
    return tr.rolling(window=period).mean()

# Fast Hurst approximation using variance ratio
def fast_hurst(prices, window=100):
    """Fast Hurst approximation using log-variance method."""
    def hurst_single(p):
        if len(p) < 20:
            return 0.5
        returns = np.diff(np.log(p))
        # Variance ratio method
        var1 = np.var(returns)
        var2 = np.var(returns[::2])  # Subsampled
        if var1 == 0 or var2 == 0:
            return 0.5
        h = 0.5 * np.log2(var2 / var1 + 1)
        return np.clip(h, 0, 1)
    return prices.rolling(window).apply(hurst_single, raw=True)

# Fast entropy
def fast_entropy(returns, window=100):
    def entropy_single(r):
        r = r[np.isfinite(r)]
        if len(r) < 10:
            return 2.0
        hist, _ = np.histogram(r, bins=10, density=True)
        hist = hist[hist > 0]
        return -np.sum(hist * np.log2(hist + 1e-10)) / 4
    return returns.rolling(window).apply(entropy_single, raw=True)

close = df['close']
high = df['high']
low = df['low']

f = pd.DataFrame(index=df.index)
f['returns'] = close.pct_change()
f['log_returns'] = np.log(close / close.shift(1))
f['range_pct'] = (high - low) / close
f['rsi'] = calc_rsi(close, 14) / 100
atr = calc_atr(high, low, close, 14)
f['atr_norm'] = atr / close
ma20 = close.rolling(20).mean()
f['ma_dist'] = (close - ma20) / ma20
bb_std = close.rolling(20).std()
f['bb_pos'] = (close - ma20) / (2 * bb_std + 1e-10)

print("  Calculating Hurst (fast method)...")
f['hurst'] = fast_hurst(close, 100)

print("  Calculating Entropy...")
f['entropy'] = fast_entropy(f['returns'], 100)

f['hour_sin'] = np.sin(2 * np.pi * df.index.hour / 24)
f['hour_cos'] = np.cos(2 * np.pi * df.index.hour / 24)
f['session'] = df.index.hour.map(lambda h: 0 if h < 7 else (1 if h < 15 else 2)) / 2

# Add volatility regime
f['vol_regime'] = atr.rolling(500).apply(lambda x: (x.iloc[-1] - x.min()) / (x.max() - x.min() + 1e-10) if len(x) > 0 else 0.5, raw=False)

f = f.dropna()
print(f"  Created {len(f.columns)} features: {list(f.columns)}")
print(f"  Samples: {len(f)}")

# Create labels
print("\n[3/6] Creating labels...")
future_return = close.shift(-4) / close - 1
direction_labels = (future_return > 0.001).astype(int).loc[f.index].dropna()

# Regime labels from Hurst
def classify_regime(h):
    if pd.isna(h): return 2
    if h > 0.55: return 0  # Trending
    if h < 0.45: return 1  # Reverting
    return 2  # Random

regime_labels = f['hurst'].apply(classify_regime)

# Align
common_idx = f.index.intersection(direction_labels.index)
f = f.loc[common_idx]
direction_labels = direction_labels.loc[common_idx]
regime_labels = regime_labels.loc[common_idx]

print(f"  Direction: {len(direction_labels)} ({direction_labels.mean():.1%} bullish)")
regime_counts = regime_labels.value_counts()
print(f"  Regime: Trending={regime_counts.get(0, 0)}, Reverting={regime_counts.get(1, 0)}, Random={regime_counts.get(2, 0)}")

# Normalize
print("\n[4/6] Normalizing and creating sequences...")
scaler = StandardScaler()
scaled = scaler.fit_transform(f.values)

scaler_params = {
    'means': scaler.mean_.tolist(),
    'stds': scaler.scale_.tolist(),
    'features': list(f.columns)
}
with open(MODEL_DIR / 'scaler_params_v2.json', 'w') as fp:
    json.dump(scaler_params, fp, indent=2)

# Create sequences
seq_len = 100
X_dir, y_dir = [], []
X_reg, y_reg = [], []
for i in range(seq_len, len(scaled)):
    X_dir.append(scaled[i-seq_len:i])
    y_dir.append(direction_labels.iloc[i])
    X_reg.append(scaled[i-seq_len:i])
    y_reg.append(regime_labels.iloc[i])

X_dir, y_dir = np.array(X_dir), np.array(y_dir)
X_reg, y_reg = np.array(X_reg), np.array(y_reg)

# 80/20 split
split = int(0.8 * len(X_dir))
print(f"  Train: {split}, Val: {len(X_dir) - split}")

# Models
class DirectionGRU(nn.Module):
    def __init__(self, n_features, hidden=64):
        super().__init__()
        self.gru = nn.GRU(n_features, hidden, 2, dropout=0.2, batch_first=True)
        self.fc = nn.Sequential(nn.Linear(hidden, 32), nn.ReLU(), nn.Dropout(0.2), nn.Linear(32, 2))
    def forward(self, x):
        out, _ = self.gru(x)
        return torch.softmax(self.fc(out[:, -1, :]), dim=1)

class RegimeGRU(nn.Module):
    def __init__(self, n_features, hidden=32):
        super().__init__()
        self.gru = nn.GRU(n_features, hidden, 1, batch_first=True)
        self.fc = nn.Sequential(nn.Linear(hidden, 16), nn.ReLU(), nn.Linear(16, 3))
    def forward(self, x):
        out, _ = self.gru(x)
        return torch.softmax(self.fc(out[:, -1, :]), dim=1)

n_features = f.shape[1]

# Train Direction Model
print("\n[5/6] Training models...")
print("\n  Training DirectionGRU...")
dir_model = DirectionGRU(n_features)
dir_opt = torch.optim.Adam(dir_model.parameters(), lr=1e-4)
dir_crit = nn.CrossEntropyLoss()

dir_train = DataLoader(TensorDataset(torch.FloatTensor(X_dir[:split]), torch.LongTensor(y_dir[:split])), batch_size=64, shuffle=True)
dir_val = DataLoader(TensorDataset(torch.FloatTensor(X_dir[split:]), torch.LongTensor(y_dir[split:])), batch_size=64)

best_dir_acc = 0
for ep in range(80):
    dir_model.train()
    for xb, yb in dir_train:
        dir_opt.zero_grad()
        dir_crit(dir_model(xb), yb).backward()
        dir_opt.step()
    
    dir_model.eval()
    with torch.no_grad():
        correct = sum((dir_model(xb).argmax(1) == yb).sum().item() for xb, yb in dir_val)
        acc = correct / len(y_dir[split:])
    
    if acc > best_dir_acc:
        best_dir_acc = acc
        torch.save(dir_model.state_dict(), MODEL_DIR / 'direction_gru_v2.pt')
    
    if (ep + 1) % 20 == 0:
        print(f"    Epoch {ep+1}/80 - Val Acc: {acc:.4f}")

print(f"  Direction Best Accuracy: {best_dir_acc:.4f}")

# Train Regime Model
print("\n  Training RegimeGRU...")
reg_model = RegimeGRU(n_features)
reg_opt = torch.optim.Adam(reg_model.parameters(), lr=1e-4)
reg_crit = nn.CrossEntropyLoss()

reg_train = DataLoader(TensorDataset(torch.FloatTensor(X_reg[:split]), torch.LongTensor(y_reg[:split])), batch_size=64, shuffle=True)
reg_val = DataLoader(TensorDataset(torch.FloatTensor(X_reg[split:]), torch.LongTensor(y_reg[split:])), batch_size=64)

best_reg_acc = 0
for ep in range(80):
    reg_model.train()
    for xb, yb in reg_train:
        reg_opt.zero_grad()
        reg_crit(reg_model(xb), yb).backward()
        reg_opt.step()
    
    reg_model.eval()
    with torch.no_grad():
        correct = sum((reg_model(xb).argmax(1) == yb).sum().item() for xb, yb in reg_val)
        acc = correct / len(y_reg[split:])
    
    if acc > best_reg_acc:
        best_reg_acc = acc
        torch.save(reg_model.state_dict(), MODEL_DIR / 'regime_gru_v2.pt')
    
    if (ep + 1) % 20 == 0:
        print(f"    Epoch {ep+1}/80 - Val Acc: {acc:.4f}")

print(f"  Regime Best Accuracy: {best_reg_acc:.4f}")

# Export to ONNX
print("\n[6/6] Exporting to ONNX...")
dummy = torch.randn(1, seq_len, n_features)

dir_model.load_state_dict(torch.load(MODEL_DIR / 'direction_gru_v2.pt', weights_only=True))
dir_model.eval()
torch.onnx.export(dir_model, dummy, str(MODEL_DIR / 'direction_v2.onnx'), 
                  input_names=['input'], output_names=['output'], opset_version=14, dynamo=False)

reg_model.load_state_dict(torch.load(MODEL_DIR / 'regime_gru_v2.pt', weights_only=True))
reg_model.eval()
torch.onnx.export(reg_model, dummy, str(MODEL_DIR / 'regime_v2.onnx'),
                  input_names=['input'], output_names=['output'], opset_version=14, dynamo=False)

# Copy to MQL5
shutil.copy(MODEL_DIR / 'direction_v2.onnx', MQL5_DIR)
shutil.copy(MODEL_DIR / 'regime_v2.onnx', MQL5_DIR)
shutil.copy(MODEL_DIR / 'scaler_params_v2.json', MQL5_DIR)

# Save summary
summary = {
    'features': list(f.columns),
    'n_features': n_features,
    'seq_len': seq_len,
    'samples': len(f),
    'direction_accuracy': best_dir_acc,
    'regime_accuracy': best_reg_acc,
    'regime_distribution': {
        'trending': int(regime_counts.get(0, 0)),
        'reverting': int(regime_counts.get(1, 0)),
        'random': int(regime_counts.get(2, 0))
    }
}
with open(MODEL_DIR / 'training_summary_v2.json', 'w') as fp:
    json.dump(summary, fp, indent=2)

print("\n" + "=" * 60)
print("TRAINING COMPLETE!")
print("=" * 60)
print(f"\nDirection Accuracy: {best_dir_acc:.4f}")
print(f"Regime Accuracy: {best_reg_acc:.4f}")
print(f"\nModels saved to: {MQL5_DIR}")
print("  - direction_v2.onnx")
print("  - regime_v2.onnx")
print("  - scaler_params_v2.json")
print(f"\nFeatures ({n_features}): {list(f.columns)}")
