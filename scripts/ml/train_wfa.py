#!/usr/bin/env python3
"""
train_wfa.py - Train direction prediction model using Walk-Forward Analysis.

BATCH 3: Trains LSTM/GRU model with proper WFA to avoid overfitting.

Walk-Forward Analysis:
    - Split data into IS (In-Sample) and OOS (Out-of-Sample) windows
    - Train on IS, validate on OOS
    - Roll forward and repeat
    - Calculate WFE (Walk-Forward Efficiency)

Usage:
    python scripts/ml/train_wfa.py \
        --features data/features/features.parquet \
        --output models/ \
        --model-type lstm \
        --is-window 2000 \
        --oos-window 500
"""

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd

try:
    import torch
    import torch.nn as nn
    from torch.utils.data import DataLoader, TensorDataset
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False
    print("WARNING: PyTorch not available. Install with: pip install torch")

try:
    from sklearn.preprocessing import StandardScaler
    from sklearn.metrics import accuracy_score, roc_auc_score
    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False


class DirectionLSTM(nn.Module):
    """LSTM model for direction prediction."""
    
    def __init__(self, input_size: int, hidden_size: int = 64, 
                 num_layers: int = 2, dropout: float = 0.2):
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
            nn.Linear(32, 1),
            nn.Sigmoid()
        )
    
    def forward(self, x):
        # x shape: (batch, seq_len, features)
        lstm_out, _ = self.lstm(x)
        # Use last timestep
        last_out = lstm_out[:, -1, :]
        return self.fc(last_out)


class DirectionGRU(nn.Module):
    """GRU model for direction prediction."""
    
    def __init__(self, input_size: int, hidden_size: int = 64,
                 num_layers: int = 2, dropout: float = 0.2):
        super().__init__()
        
        self.gru = nn.GRU(
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
            nn.Linear(32, 1),
            nn.Sigmoid()
        )
    
    def forward(self, x):
        gru_out, _ = self.gru(x)
        last_out = gru_out[:, -1, :]
        return self.fc(last_out)


def create_sequences(X: np.ndarray, y: np.ndarray, 
                     seq_length: int = 10) -> Tuple[np.ndarray, np.ndarray]:
    """Create sequences for LSTM/GRU input."""
    X_seq, y_seq = [], []
    
    for i in range(seq_length, len(X)):
        X_seq.append(X[i-seq_length:i])
        y_seq.append(y[i])
    
    return np.array(X_seq), np.array(y_seq)


def train_model(model: nn.Module, train_loader: DataLoader, 
                val_loader: DataLoader, epochs: int = 50,
                lr: float = 0.001, patience: int = 10,
                verbose: bool = True) -> Dict:
    """Train model with early stopping."""
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = model.to(device)
    
    criterion = nn.BCELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    
    best_val_loss = float('inf')
    best_state = None
    patience_counter = 0
    history = {'train_loss': [], 'val_loss': [], 'val_acc': []}
    
    for epoch in range(epochs):
        # Training
        model.train()
        train_loss = 0
        for X_batch, y_batch in train_loader:
            X_batch = X_batch.to(device)
            y_batch = y_batch.to(device)
            
            optimizer.zero_grad()
            outputs = model(X_batch).squeeze()
            loss = criterion(outputs, y_batch)
            loss.backward()
            optimizer.step()
            
            train_loss += loss.item()
        
        train_loss /= len(train_loader)
        
        # Validation
        model.eval()
        val_loss = 0
        all_preds = []
        all_labels = []
        
        with torch.no_grad():
            for X_batch, y_batch in val_loader:
                X_batch = X_batch.to(device)
                y_batch = y_batch.to(device)
                
                outputs = model(X_batch).squeeze()
                loss = criterion(outputs, y_batch)
                val_loss += loss.item()
                
                all_preds.extend(outputs.cpu().numpy())
                all_labels.extend(y_batch.cpu().numpy())
        
        val_loss /= len(val_loader)
        val_acc = accuracy_score(all_labels, [1 if p > 0.5 else 0 for p in all_preds])
        
        history['train_loss'].append(train_loss)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(val_acc)
        
        if verbose and (epoch + 1) % 10 == 0:
            print(f"  Epoch {epoch+1}/{epochs} - Train: {train_loss:.4f}, Val: {val_loss:.4f}, Acc: {val_acc:.4f}")
        
        # Early stopping
        if val_loss < best_val_loss:
            best_val_loss = val_loss
            best_state = model.state_dict().copy()
            patience_counter = 0
        else:
            patience_counter += 1
            if patience_counter >= patience:
                if verbose:
                    print(f"  Early stopping at epoch {epoch+1}")
                break
    
    # Load best model
    if best_state:
        model.load_state_dict(best_state)
    
    return history


def walk_forward_train(
    features: pd.DataFrame,
    model_type: str = 'lstm',
    is_window: int = 2000,
    oos_window: int = 500,
    seq_length: int = 10,
    hidden_size: int = 64,
    epochs: int = 50,
    verbose: bool = True
) -> Dict:
    """
    Train model using Walk-Forward Analysis.
    
    Args:
        features: DataFrame with features and target
        model_type: 'lstm' or 'gru'
        is_window: In-Sample window size
        oos_window: Out-of-Sample window size
        seq_length: Sequence length for LSTM/GRU
        hidden_size: Hidden layer size
        epochs: Max epochs per fold
        verbose: Print progress
    
    Returns:
        Dict with trained model, scaler, and WFA results
    """
    if not TORCH_AVAILABLE or not SKLEARN_AVAILABLE:
        raise RuntimeError("PyTorch and sklearn required")
    
    # Prepare data
    feature_cols = [c for c in features.columns if c not in ['datetime', 'target']]
    X = features[feature_cols].values
    y = features['target'].values
    
    n_samples = len(X)
    n_features = len(feature_cols)
    
    print(f"\nWalk-Forward Analysis")
    print(f"  Samples: {n_samples:,}")
    print(f"  Features: {n_features}")
    print(f"  IS Window: {is_window}")
    print(f"  OOS Window: {oos_window}")
    
    # Calculate number of folds
    n_folds = (n_samples - is_window) // oos_window
    print(f"  Folds: {n_folds}")
    
    # Results storage
    wfa_results = {
        'folds': [],
        'is_metrics': [],
        'oos_metrics': [],
        'wfe_values': []
    }
    
    # Scaler (fit on first IS window)
    scaler = StandardScaler()
    
    # Best model tracking
    best_model = None
    best_oos_acc = 0
    
    for fold in range(n_folds):
        if verbose:
            print(f"\n--- Fold {fold+1}/{n_folds} ---")
        
        # Define windows
        is_start = fold * oos_window
        is_end = is_start + is_window
        oos_start = is_end
        oos_end = min(oos_start + oos_window, n_samples)
        
        if oos_end <= oos_start:
            break
        
        # Split data
        X_is = X[is_start:is_end]
        y_is = y[is_start:is_end]
        X_oos = X[oos_start:oos_end]
        y_oos = y[oos_start:oos_end]
        
        # Scale
        if fold == 0:
            X_is_scaled = scaler.fit_transform(X_is)
        else:
            X_is_scaled = scaler.transform(X_is)
        X_oos_scaled = scaler.transform(X_oos)
        
        # Create sequences
        X_is_seq, y_is_seq = create_sequences(X_is_scaled, y_is, seq_length)
        X_oos_seq, y_oos_seq = create_sequences(X_oos_scaled, y_oos, seq_length)
        
        if len(X_is_seq) == 0 or len(X_oos_seq) == 0:
            continue
        
        # Create tensors
        X_is_t = torch.FloatTensor(X_is_seq)
        y_is_t = torch.FloatTensor(y_is_seq)
        X_oos_t = torch.FloatTensor(X_oos_seq)
        y_oos_t = torch.FloatTensor(y_oos_seq)
        
        # Split IS into train/val
        val_size = int(len(X_is_t) * 0.2)
        train_size = len(X_is_t) - val_size
        
        train_dataset = TensorDataset(X_is_t[:train_size], y_is_t[:train_size])
        val_dataset = TensorDataset(X_is_t[train_size:], y_is_t[train_size:])
        
        train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
        val_loader = DataLoader(val_dataset, batch_size=32)
        
        # Create model
        if model_type == 'lstm':
            model = DirectionLSTM(n_features, hidden_size)
        else:
            model = DirectionGRU(n_features, hidden_size)
        
        # Train
        history = train_model(model, train_loader, val_loader, 
                             epochs=epochs, verbose=verbose)
        
        # Evaluate on OOS
        model.eval()
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        model = model.to(device)
        
        with torch.no_grad():
            X_oos_t = X_oos_t.to(device)
            oos_preds = model(X_oos_t).squeeze().cpu().numpy()
        
        oos_acc = accuracy_score(y_oos_seq, [1 if p > 0.5 else 0 for p in oos_preds])
        is_acc = history['val_acc'][-1] if history['val_acc'] else 0
        
        # WFE = OOS / IS
        wfe = oos_acc / is_acc if is_acc > 0 else 0
        
        if verbose:
            print(f"  IS Acc: {is_acc:.4f}, OOS Acc: {oos_acc:.4f}, WFE: {wfe:.4f}")
        
        wfa_results['folds'].append(fold + 1)
        wfa_results['is_metrics'].append(is_acc)
        wfa_results['oos_metrics'].append(oos_acc)
        wfa_results['wfe_values'].append(wfe)
        
        # Track best model
        if oos_acc > best_oos_acc:
            best_oos_acc = oos_acc
            best_model = model.state_dict().copy()
    
    # Summary
    avg_is = np.mean(wfa_results['is_metrics'])
    avg_oos = np.mean(wfa_results['oos_metrics'])
    avg_wfe = np.mean(wfa_results['wfe_values'])
    
    print(f"\n{'='*50}")
    print("WFA SUMMARY")
    print(f"{'='*50}")
    print(f"Average IS Accuracy:  {avg_is:.4f}")
    print(f"Average OOS Accuracy: {avg_oos:.4f}")
    print(f"Average WFE:          {avg_wfe:.4f}")
    print(f"WFE >= 0.6: {'PASS' if avg_wfe >= 0.6 else 'FAIL'}")
    
    # Create final model with best weights
    if model_type == 'lstm':
        final_model = DirectionLSTM(n_features, hidden_size)
    else:
        final_model = DirectionGRU(n_features, hidden_size)
    
    if best_model:
        final_model.load_state_dict(best_model)
    
    return {
        'model': final_model,
        'scaler': scaler,
        'feature_cols': feature_cols,
        'seq_length': seq_length,
        'wfa_results': wfa_results,
        'avg_wfe': avg_wfe,
        'passed': avg_wfe >= 0.6
    }


def main():
    parser = argparse.ArgumentParser(
        description='Train direction prediction model with Walk-Forward Analysis'
    )
    parser.add_argument('--features', '-f', required=True,
                        help='Path to features parquet file')
    parser.add_argument('--output', '-o', default='models/',
                        help='Output directory for model')
    parser.add_argument('--model-type', '-m', choices=['lstm', 'gru'],
                        default='lstm', help='Model type')
    parser.add_argument('--is-window', type=int, default=2000,
                        help='In-Sample window size')
    parser.add_argument('--oos-window', type=int, default=500,
                        help='Out-of-Sample window size')
    parser.add_argument('--seq-length', type=int, default=10,
                        help='Sequence length')
    parser.add_argument('--hidden-size', type=int, default=64,
                        help='Hidden layer size')
    parser.add_argument('--epochs', type=int, default=50,
                        help='Max epochs per fold')
    
    args = parser.parse_args()
    
    if not TORCH_AVAILABLE:
        print("ERROR: PyTorch required. Install with: pip install torch")
        return 1
    
    # Load features
    print(f"\nLoading features from: {args.features}")
    features = pd.read_parquet(args.features)
    print(f"  Loaded {len(features):,} samples")
    
    # Train with WFA
    result = walk_forward_train(
        features=features,
        model_type=args.model_type,
        is_window=args.is_window,
        oos_window=args.oos_window,
        seq_length=args.seq_length,
        hidden_size=args.hidden_size,
        epochs=args.epochs
    )
    
    # Save model and metadata
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Save PyTorch model
    model_path = output_dir / f'direction_model_{args.model_type}.pt'
    torch.save({
        'model_state_dict': result['model'].state_dict(),
        'model_type': args.model_type,
        'seq_length': result['seq_length'],
        'feature_cols': result['feature_cols'],
        'hidden_size': args.hidden_size
    }, model_path)
    print(f"\nModel saved to: {model_path}")
    
    # Save scaler
    import pickle
    scaler_path = output_dir / 'scaler.pkl'
    with open(scaler_path, 'wb') as f:
        pickle.dump(result['scaler'], f)
    print(f"Scaler saved to: {scaler_path}")
    
    # Save WFA results
    wfa_path = output_dir / 'wfa_results.json'
    with open(wfa_path, 'w') as f:
        json.dump({
            'wfa_results': {
                'folds': result['wfa_results']['folds'],
                'is_metrics': [float(x) for x in result['wfa_results']['is_metrics']],
                'oos_metrics': [float(x) for x in result['wfa_results']['oos_metrics']],
                'wfe_values': [float(x) for x in result['wfa_results']['wfe_values']]
            },
            'avg_wfe': float(result['avg_wfe']),
            'passed': bool(result['passed']),
            'model_type': args.model_type,
            'is_window': args.is_window,
            'oos_window': args.oos_window,
            'timestamp': datetime.now().isoformat()
        }, f, indent=2)
    print(f"WFA results saved to: {wfa_path}")
    
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    sys.exit(main())
