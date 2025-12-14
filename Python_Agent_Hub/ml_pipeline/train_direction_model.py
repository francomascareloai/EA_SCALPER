"""
Direction Model Training - LSTM for XAUUSD
EA_SCALPER_XAUUSD - Singularity Edition

Trains an LSTM model to predict price direction with Walk-Forward Validation.
Exports to ONNX for MQL5 deployment.
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime
import json
import warnings
warnings.filterwarnings('ignore')

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import TimeSeriesSplit
from sklearn.metrics import accuracy_score, classification_report, f1_score

DATA_DIR = Path(__file__).parent / "data"
MODEL_DIR = Path(__file__).parent.parent.parent / "MQL5" / "Models"
MODEL_DIR.mkdir(exist_ok=True)


class DirectionLSTM(nn.Module):
    """LSTM model for direction prediction."""
    
    def __init__(self, input_size: int, hidden_size: int = 64, num_layers: int = 2, dropout: float = 0.2):
        super().__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        
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
            nn.Linear(32, 2)  # Binary: bearish, bullish
        )
    
    def forward(self, x):
        # x: (batch, seq_len, features)
        lstm_out, _ = self.lstm(x)
        last_hidden = lstm_out[:, -1, :]  # Take last timestep
        logits = self.fc(last_hidden)
        return torch.softmax(logits, dim=1)


class TimeSeriesDataset(Dataset):
    """Dataset for sequence data."""
    
    def __init__(self, X: np.ndarray, y: np.ndarray, seq_len: int = 100):
        self.X = torch.FloatTensor(X)
        self.y = torch.LongTensor(y)
        self.seq_len = seq_len
    
    def __len__(self):
        return len(self.X) - self.seq_len
    
    def __getitem__(self, idx):
        x_seq = self.X[idx:idx + self.seq_len]
        y_target = self.y[idx + self.seq_len - 1]
        return x_seq, y_target


def prepare_data(dataset_path: Path, filter_neutral: bool = True):
    """Load and prepare data for training."""
    print("Loading dataset...")
    df = pd.read_parquet(dataset_path)
    
    # Separate features and target
    y = df['target'].values
    X = df.drop(columns=['target']).values
    
    # Filter neutral samples if requested
    if filter_neutral:
        mask = y != 2
        X = X[mask]
        y = y[mask]
        print(f"Filtered neutral samples: {len(y):,} remaining")
    
    return X, y, df.drop(columns=['target']).columns.tolist()


def train_epoch(model, dataloader, criterion, optimizer, device):
    """Train for one epoch."""
    model.train()
    total_loss = 0
    correct = 0
    total = 0
    
    for X_batch, y_batch in dataloader:
        X_batch, y_batch = X_batch.to(device), y_batch.to(device)
        
        optimizer.zero_grad()
        outputs = model(X_batch)
        loss = criterion(outputs, y_batch)
        loss.backward()
        optimizer.step()
        
        total_loss += loss.item()
        _, predicted = outputs.max(1)
        total += y_batch.size(0)
        correct += predicted.eq(y_batch).sum().item()
    
    return total_loss / len(dataloader), 100. * correct / total


def evaluate(model, dataloader, criterion, device):
    """Evaluate model."""
    model.eval()
    total_loss = 0
    all_preds = []
    all_targets = []
    
    with torch.no_grad():
        for X_batch, y_batch in dataloader:
            X_batch, y_batch = X_batch.to(device), y_batch.to(device)
            outputs = model(X_batch)
            loss = criterion(outputs, y_batch)
            
            total_loss += loss.item()
            _, predicted = outputs.max(1)
            all_preds.extend(predicted.cpu().numpy())
            all_targets.extend(y_batch.cpu().numpy())
    
    accuracy = accuracy_score(all_targets, all_preds)
    f1 = f1_score(all_targets, all_preds, average='weighted')
    
    return total_loss / len(dataloader), accuracy * 100, f1


def walk_forward_validation(
    X: np.ndarray, 
    y: np.ndarray,
    n_splits: int = 5,
    seq_len: int = 100,
    hidden_size: int = 64,
    num_layers: int = 2,
    epochs: int = 50,
    batch_size: int = 64,
    learning_rate: float = 1e-4
):
    """Walk-Forward Analysis for robust validation."""
    print("\n" + "="*60)
    print("WALK-FORWARD VALIDATION")
    print("="*60)
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Device: {device}")
    
    tscv = TimeSeriesSplit(n_splits=n_splits)
    fold_results = []
    
    for fold, (train_idx, val_idx) in enumerate(tscv.split(X)):
        print(f"\n--- Fold {fold + 1}/{n_splits} ---")
        print(f"Train: {len(train_idx):,} samples | Val: {len(val_idx):,} samples")
        
        # Split data
        X_train, X_val = X[train_idx], X[val_idx]
        y_train, y_val = y[train_idx], y[val_idx]
        
        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_val_scaled = scaler.transform(X_val)
        
        # Create datasets
        train_dataset = TimeSeriesDataset(X_train_scaled, y_train, seq_len)
        val_dataset = TimeSeriesDataset(X_val_scaled, y_val, seq_len)
        
        train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=False)
        val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
        
        # Create model
        input_size = X.shape[1]
        model = DirectionLSTM(input_size, hidden_size, num_layers).to(device)
        criterion = nn.CrossEntropyLoss()
        optimizer = optim.Adam(model.parameters(), lr=learning_rate)
        scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=5, factor=0.5)
        
        # Train
        best_val_acc = 0
        patience_counter = 0
        
        for epoch in range(epochs):
            train_loss, train_acc = train_epoch(model, train_loader, criterion, optimizer, device)
            val_loss, val_acc, val_f1 = evaluate(model, val_loader, criterion, device)
            scheduler.step(val_loss)
            
            if val_acc > best_val_acc:
                best_val_acc = val_acc
                patience_counter = 0
            else:
                patience_counter += 1
            
            if (epoch + 1) % 10 == 0:
                print(f"  Epoch {epoch+1}: Train Loss={train_loss:.4f}, Acc={train_acc:.1f}% | Val Acc={val_acc:.1f}%, F1={val_f1:.3f}")
            
            if patience_counter >= 10:
                print(f"  Early stopping at epoch {epoch+1}")
                break
        
        fold_results.append({
            'fold': fold + 1,
            'val_accuracy': best_val_acc,
            'train_samples': len(train_idx),
            'val_samples': len(val_idx)
        })
        
        print(f"  Best Val Accuracy: {best_val_acc:.2f}%")
    
    # Summary
    avg_acc = np.mean([r['val_accuracy'] for r in fold_results])
    std_acc = np.std([r['val_accuracy'] for r in fold_results])
    
    print("\n" + "="*60)
    print("WALK-FORWARD RESULTS")
    print("="*60)
    for r in fold_results:
        print(f"  Fold {r['fold']}: {r['val_accuracy']:.2f}%")
    print(f"\n  Average: {avg_acc:.2f}% (+/- {std_acc:.2f}%)")
    print(f"  WFE (Walk-Forward Efficiency): {avg_acc/100:.3f}")
    
    return fold_results, avg_acc


def train_final_model(
    X: np.ndarray,
    y: np.ndarray,
    feature_names: list,
    seq_len: int = 100,
    hidden_size: int = 64,
    num_layers: int = 2,
    epochs: int = 100,
    batch_size: int = 64,
    learning_rate: float = 1e-4
):
    """Train final model on all data and export to ONNX."""
    print("\n" + "="*60)
    print("TRAINING FINAL MODEL")
    print("="*60)
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # Scale all data
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Save scaler params for MQL5
    scaler_params = {
        'means': scaler.mean_.tolist(),
        'stds': scaler.scale_.tolist(),
        'feature_names': feature_names
    }
    scaler_path = MODEL_DIR / "direction_scaler.json"
    with open(scaler_path, 'w') as f:
        json.dump(scaler_params, f, indent=2)
    print(f"Scaler saved to {scaler_path}")
    
    # Create dataset
    dataset = TimeSeriesDataset(X_scaled, y, seq_len)
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=False)
    
    # Create model
    input_size = X.shape[1]
    model = DirectionLSTM(input_size, hidden_size, num_layers).to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    
    # Train
    print(f"\nTraining on {len(dataset):,} samples...")
    for epoch in range(epochs):
        train_loss, train_acc = train_epoch(model, dataloader, criterion, optimizer, device)
        
        if (epoch + 1) % 10 == 0:
            print(f"  Epoch {epoch+1}/{epochs}: Loss={train_loss:.4f}, Acc={train_acc:.1f}%")
    
    # Export to ONNX
    print("\nExporting to ONNX...")
    model.eval()
    model.cpu()
    
    dummy_input = torch.randn(1, seq_len, input_size)
    onnx_path = MODEL_DIR / "direction_model.onnx"
    
    torch.onnx.export(
        model,
        dummy_input,
        onnx_path,
        export_params=True,
        opset_version=11,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={
            'input': {0: 'batch'},
            'output': {0: 'batch'}
        }
    )
    
    print(f"ONNX model saved to {onnx_path}")
    print(f"Model size: {onnx_path.stat().st_size / 1024:.1f} KB")
    
    # Validate ONNX
    import onnx
    onnx_model = onnx.load(onnx_path)
    onnx.checker.check_model(onnx_model)
    print("ONNX model validated successfully!")
    
    return model, scaler


def main():
    print("="*60)
    print("DIRECTION MODEL TRAINING PIPELINE")
    print("EA_SCALPER_XAUUSD - Singularity Edition")
    print("="*60)
    print(f"Started: {datetime.now()}")
    
    # Find dataset
    dataset_path = DATA_DIR / "XAUUSD_ML_dataset_M15_H1.parquet"
    
    if not dataset_path.exists():
        print(f"ERROR: Dataset not found at {dataset_path}")
        print("Run feature_engineering.py first!")
        return
    
    # Load data
    X, y, feature_names = prepare_data(dataset_path, filter_neutral=True)
    print(f"\nDataset shape: {X.shape}")
    print(f"Features: {len(feature_names)}")
    print(f"Class balance: {100*np.mean(y==0):.1f}% bearish, {100*np.mean(y==1):.1f}% bullish")
    
    # Walk-Forward Validation
    fold_results, avg_acc = walk_forward_validation(
        X, y,
        n_splits=5,
        seq_len=100,
        hidden_size=64,
        num_layers=2,
        epochs=50,
        batch_size=64,
        learning_rate=1e-4
    )
    
    # Check if WFE is acceptable
    wfe = avg_acc / 100
    if wfe < 0.55:
        print(f"\nWARNING: WFE ({wfe:.3f}) is below 0.55 threshold!")
        print("Model may not have predictive power. Consider:")
        print("  - More features")
        print("  - Different architecture")
        print("  - More data")
    else:
        print(f"\nWFE ({wfe:.3f}) meets minimum threshold (0.55)")
    
    # Train final model
    if wfe >= 0.52:  # Allow slightly lower for final training
        model, scaler = train_final_model(
            X, y, feature_names,
            seq_len=100,
            hidden_size=64,
            num_layers=2,
            epochs=100,
            batch_size=64,
            learning_rate=1e-4
        )
        
        print("\n" + "="*60)
        print("TRAINING COMPLETE!")
        print("="*60)
        print(f"\nFiles created in {MODEL_DIR}:")
        print("  - direction_model.onnx (for MQL5)")
        print("  - direction_scaler.json (normalization params)")
    
    print(f"\nFinished: {datetime.now()}")


if __name__ == "__main__":
    main()
