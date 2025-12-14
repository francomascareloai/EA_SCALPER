"""Quick Training Script for XAUUSD Direction Model"""
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
from sklearn.preprocessing import StandardScaler
import json
from pathlib import Path
import shutil

print('='*60)
print('EA_SCALPER_XAUUSD - ML Training')
print('='*60)

# 1. Load data
print('\n[1/6] Loading data...')
BASE = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub')
df = pd.read_csv(BASE / 'ml_pipeline/data/xauusd_m15_clean.csv', index_col=0, parse_dates=True)
print(f'Data: {len(df)} bars')

# 2. Create features
print('\n[2/6] Creating features...')

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

features = pd.DataFrame(index=df.index)
features['returns'] = df['close'].pct_change()
features['log_returns'] = np.log(df['close'] / df['close'].shift(1))
features['range_pct'] = (df['high'] - df['low']) / df['close']
features['rsi'] = calc_rsi(df['close'], 14) / 100
atr = calc_atr(df['high'], df['low'], df['close'], 14)
features['atr_norm'] = atr / df['close']
ma20 = df['close'].rolling(20).mean()
features['ma_dist'] = (df['close'] - ma20) / ma20
bb_mid = df['close'].rolling(20).mean()
bb_std = df['close'].rolling(20).std()
features['bb_pos'] = (df['close'] - bb_mid) / (2 * bb_std)
features['hour_sin'] = np.sin(2 * np.pi * df.index.hour / 24)
features['hour_cos'] = np.cos(2 * np.pi * df.index.hour / 24)
features = features.dropna()
print(f'Features: {len(features)} samples, {len(features.columns)} features')

# 3. Labels
print('\n[3/6] Creating labels...')
future_return = df['close'].shift(-4) / df['close'] - 1
labels = (future_return > 0.001).astype(int)
labels = labels.loc[features.index].dropna()
features = features.loc[labels.index]
print(f'Labels: {len(labels)} ({labels.mean():.1%} bullish)')

# 4. Normalize
print('\n[4/6] Normalizing...')
scaler = StandardScaler()
scaled = scaler.fit_transform(features.values)
(BASE / 'ml_pipeline/models').mkdir(exist_ok=True)
with open(BASE / 'ml_pipeline/models/scaler_params.json', 'w') as f:
    json.dump({'means': scaler.mean_.tolist(), 'stds': scaler.scale_.tolist()}, f)

# Sequences
seq_len = 100
X, y = [], []
for i in range(seq_len, len(scaled)):
    X.append(scaled[i-seq_len:i])
    y.append(labels.iloc[i])
X, y = np.array(X), np.array(y)
split = int(0.8 * len(X))
X_train, X_val = X[:split], X[split:]
y_train, y_val = y[:split], y[split:]
print(f'Train: {len(X_train)}, Val: {len(X_val)}')

# 5. Train
print('\n[5/6] Training LSTM...')

class LSTM(nn.Module):
    def __init__(self, n_features):
        super().__init__()
        self.lstm = nn.LSTM(n_features, 64, 2, dropout=0.2, batch_first=True)
        self.fc = nn.Sequential(
            nn.Linear(64, 32), 
            nn.ReLU(), 
            nn.Dropout(0.2), 
            nn.Linear(32, 2)
        )
    
    def forward(self, x):
        out, _ = self.lstm(x)
        return torch.softmax(self.fc(out[:, -1, :]), dim=1)

model = LSTM(X_train.shape[2])
optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)
criterion = nn.CrossEntropyLoss()

train_dl = DataLoader(
    TensorDataset(torch.FloatTensor(X_train), torch.LongTensor(y_train)), 
    batch_size=64, shuffle=True
)
val_dl = DataLoader(
    TensorDataset(torch.FloatTensor(X_val), torch.LongTensor(y_val)), 
    batch_size=64
)

best_acc = 0
for epoch in range(50):
    # Train
    model.train()
    for xb, yb in train_dl:
        optimizer.zero_grad()
        loss = criterion(model(xb), yb)
        loss.backward()
        optimizer.step()
    
    # Validate
    model.eval()
    correct = 0
    with torch.no_grad():
        for xb, yb in val_dl:
            pred = model(xb).argmax(dim=1)
            correct += (pred == yb).sum().item()
    acc = correct / len(y_val)
    
    if acc > best_acc:
        best_acc = acc
        torch.save(model.state_dict(), BASE / 'ml_pipeline/models/best.pt')
    
    if (epoch + 1) % 10 == 0:
        print(f'Epoch {epoch+1}/50 - Val Acc: {acc:.4f}')

print(f'\nBest Accuracy: {best_acc:.4f}')

# 6. Export ONNX
print('\n[6/6] Exporting ONNX...')
model.load_state_dict(torch.load(BASE / 'ml_pipeline/models/best.pt'))
model.eval()

dummy_input = torch.randn(1, seq_len, X_train.shape[2])
torch.onnx.export(
    model, 
    dummy_input, 
    str(BASE / 'ml_pipeline/models/direction_model.onnx'),
    input_names=['input'],
    output_names=['output'],
    dynamic_axes={'input': {0: 'batch'}, 'output': {0: 'batch'}}
)

# Copy to MQL5
MQL5_MODELS = BASE.parent / 'MQL5' / 'Models'
MQL5_MODELS.mkdir(exist_ok=True)
shutil.copy(BASE / 'ml_pipeline/models/direction_model.onnx', MQL5_MODELS)
shutil.copy(BASE / 'ml_pipeline/models/scaler_params.json', MQL5_MODELS)

print('\n' + '='*60)
print('DONE!')
print('='*60)
print(f'Validation Accuracy: {best_acc:.4f}')
print(f'Model saved to: MQL5/Models/direction_model.onnx')
