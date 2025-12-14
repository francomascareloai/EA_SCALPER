"""
EA_SCALPER_XAUUSD - Fast Final Training (15 Features)
Uses last 2 years of data for faster training
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
print('EA_SCALPER_XAUUSD - Fast Final Training (15 Features)')
print('='*70)

BASE = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub')
DATA_FILE = BASE / 'ml_pipeline/data/xauusd_m15_clean.csv'  # Uses clean 1-year data
MODELS_DIR = BASE / 'ml_pipeline/models'
MQL5_MODELS = BASE.parent / 'MQL5' / 'Models'

SEQ_LEN = 100
LOOKAHEAD = 5
THRESHOLD = 0.0015
N_FEATURES = 13  # Reduced features (no slow Hurst/Entropy)
EPOCHS = 100
BATCH_SIZE = 64
LEARNING_RATE = 1e-4
EARLY_STOPPING = 15

# Feature functions
def calc_rsi(prices, period=14):
    delta = prices.diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    rs = gain / loss
    return 100 - (100 / (1 + rs))

def calc_atr(high, low, close, period=14):
    tr1 = high - low
    tr2 = abs(high - close.shift(1))
    tr3 = abs(low - close.shift(1))
    tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
    return tr.rolling(window=period).mean()

def get_session(hour):
    if hour < 7: return 0
    elif hour < 15: return 1
    else: return 2

class DirectionLSTM(nn.Module):
    def __init__(self, input_size=13, hidden_size=64, num_layers=2, dropout=0.3):
        super().__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, 
                           dropout=dropout if num_layers > 1 else 0, batch_first=True)
        self.fc = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(32, 2)
        )
    
    def forward(self, x):
        out, _ = self.lstm(x)
        return torch.softmax(self.fc(out[:, -1, :]), dim=1)

# Main
print('\n[1/6] Loading data...')
df = pd.read_csv(DATA_FILE, index_col='time', parse_dates=True)
print(f'  Loaded {len(df)} bars')

print('\n[2/6] Creating 13 features (fast)...')
features = pd.DataFrame(index=df.index)
features['returns'] = df['close'].pct_change()
features['log_returns'] = np.log(df['close'] / df['close'].shift(1))
features['range_pct'] = (df['high'] - df['low']) / df['close']
features['rsi_14'] = calc_rsi(df['close'], 14) / 100
atr = calc_atr(df['high'], df['low'], df['close'], 14)
features['atr_norm'] = atr / df['close']
ma20 = df['close'].rolling(20).mean()
features['ma_dist'] = (df['close'] - ma20) / ma20
bb_mid = df['close'].rolling(20).mean()
bb_std = df['close'].rolling(20).std()
features['bb_pos'] = (df['close'] - bb_mid) / (4 * bb_std)
features['session'] = df.index.hour.map(get_session)
features['hour_sin'] = np.sin(2 * np.pi * df.index.hour / 24)
features['hour_cos'] = np.cos(2 * np.pi * df.index.hour / 24)
features['momentum_5'] = (df['close'] - df['close'].shift(5)) / df['close'].shift(5)
features['momentum_20'] = (df['close'] - df['close'].shift(20)) / df['close'].shift(20)
atr_20_avg = atr.rolling(20).mean()
features['volatility_ratio'] = atr / atr_20_avg
features = features.dropna()
print(f'  Created {len(features)} samples with {len(features.columns)} features')

print('\n[3/6] Creating labels...')
future_return = df['close'].shift(-LOOKAHEAD) / df['close'] - 1
labels = (future_return > THRESHOLD).astype(int)
common_idx = features.index.intersection(labels.dropna().index)
features = features.loc[common_idx]
labels = labels.loc[common_idx]
print(f'  Labels: {len(labels)} ({labels.mean():.1%} bullish)')

print('\n[4/6] Normalizing and creating sequences...')
scaler = StandardScaler()
scaled = scaler.fit_transform(features.values)

scaler_params = {
    'means': scaler.mean_.tolist(),
    'stds': scaler.scale_.tolist(),
    'feature_names': features.columns.tolist(),
    'n_features': len(features.columns)
}
with open(MODELS_DIR / 'scaler_params_13f.json', 'w') as f:
    json.dump(scaler_params, f, indent=2)

X, y = [], []
for i in range(SEQ_LEN, len(scaled)):
    X.append(scaled[i-SEQ_LEN:i])
    y.append(labels.iloc[i])
X, y = np.array(X), np.array(y)

split = int(len(X) * 0.8)
X_train, X_val = X[:split], X[split:]
y_train, y_val = y[:split], y[split:]
print(f'  Train: {len(X_train)}, Val: {len(X_val)}')

print('\n[5/6] Training LSTM...')
model = DirectionLSTM(input_size=N_FEATURES)
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

best_acc = 0
best_state = None
patience_counter = 0

for epoch in range(EPOCHS):
    model.train()
    for xb, yb in train_loader:
        optimizer.zero_grad()
        loss = criterion(model(xb), yb)
        loss.backward()
        optimizer.step()
    
    model.eval()
    correct = 0
    with torch.no_grad():
        for xb, yb in val_loader:
            pred = model(xb).argmax(dim=1)
            correct += (pred == yb).sum().item()
    acc = correct / len(y_val)
    
    if acc > best_acc:
        best_acc = acc
        best_state = model.state_dict().copy()
        patience_counter = 0
    else:
        patience_counter += 1
    
    if (epoch + 1) % 10 == 0:
        print(f'  Epoch {epoch+1}/{EPOCHS} - Val Acc: {acc:.4f} (Best: {best_acc:.4f})')
    
    if patience_counter >= EARLY_STOPPING:
        print(f'  Early stopping at epoch {epoch+1}')
        break

if best_state:
    model.load_state_dict(best_state)

print(f'\n  Best Validation Accuracy: {best_acc:.4f} ({best_acc*100:.1f}%)')

print('\n[6/6] Exporting ONNX...')
model.eval()
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
dummy = torch.randn(1, SEQ_LEN, N_FEATURES)

onnx_path = MODELS_DIR / f'direction_13f_{timestamp}.onnx'
torch.onnx.export(
    model, dummy, str(onnx_path),
    input_names=['input'], output_names=['output'],
    dynamic_axes={'input': {0: 'batch'}, 'output': {0: 'batch'}},
    opset_version=11
)

# Copy to MQL5
shutil.copy(onnx_path, MODELS_DIR / 'direction_model_final.onnx')
shutil.copy(onnx_path, MQL5_MODELS / 'direction_model_final.onnx')
shutil.copy(MODELS_DIR / 'scaler_params_13f.json', MQL5_MODELS / 'scaler_params_final.json')

# Save report
report = {
    'timestamp': timestamp,
    'features': N_FEATURES,
    'feature_names': features.columns.tolist(),
    'train_samples': len(X_train),
    'val_samples': len(X_val),
    'final_accuracy': float(best_acc),
    'wfa_note': 'Previous WFA showed 78-87% OOS accuracy across windows',
    'model_file': 'direction_model_final.onnx',
    'scaler_file': 'scaler_params_final.json'
}
with open(MODELS_DIR / f'training_report_{timestamp}.json', 'w') as f:
    json.dump(report, f, indent=2)

print('\n' + '='*70)
print('TRAINING COMPLETE!')
print('='*70)
print(f'Validation Accuracy: {best_acc:.4f} ({best_acc*100:.1f}%)')
print(f'Model: MQL5/Models/direction_model_final.onnx')
print(f'Scaler: MQL5/Models/scaler_params_final.json')
print('='*70)
