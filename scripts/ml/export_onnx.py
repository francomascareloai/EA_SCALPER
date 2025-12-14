#!/usr/bin/env python3
"""
export_onnx.py - Export trained PyTorch model to ONNX format for MQL5.

BATCH 3: Converts the trained direction model to ONNX for use in EA.

Usage:
    python scripts/ml/export_onnx.py \
        --model models/direction_model_lstm.pt \
        --output MQL5/Models/direction_model.onnx
"""

import argparse
import json
import sys
from pathlib import Path

import numpy as np

try:
    import torch
    import torch.nn as nn
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False


class DirectionLSTM(nn.Module):
    """LSTM model for direction prediction (must match train_wfa.py)."""
    
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
        lstm_out, _ = self.lstm(x)
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


def export_to_onnx(
    model_path: str,
    output_path: str,
    opset_version: int = 11
) -> bool:
    """
    Export PyTorch model to ONNX.
    
    Args:
        model_path: Path to .pt model file
        output_path: Path for output .onnx file
        opset_version: ONNX opset version
    
    Returns:
        True if successful
    """
    if not TORCH_AVAILABLE:
        print("ERROR: PyTorch required")
        return False
    
    print(f"\nLoading model from: {model_path}")
    
    # Load checkpoint
    checkpoint = torch.load(model_path, map_location='cpu')
    
    model_type = checkpoint.get('model_type', 'lstm')
    seq_length = checkpoint.get('seq_length', 10)
    feature_cols = checkpoint.get('feature_cols', [])
    hidden_size = checkpoint.get('hidden_size', 64)
    n_features = len(feature_cols)
    
    print(f"  Model type: {model_type}")
    print(f"  Sequence length: {seq_length}")
    print(f"  Features: {n_features}")
    print(f"  Hidden size: {hidden_size}")
    
    # Create model
    if model_type == 'lstm':
        model = DirectionLSTM(n_features, hidden_size)
    else:
        model = DirectionGRU(n_features, hidden_size)
    
    model.load_state_dict(checkpoint['model_state_dict'])
    model.eval()
    
    # Create dummy input
    # Shape: (batch_size, seq_length, n_features)
    dummy_input = torch.randn(1, seq_length, n_features)
    
    print(f"\nExporting to ONNX...")
    print(f"  Input shape: {dummy_input.shape}")
    
    # Export
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Use legacy exporter for compatibility
    torch.onnx.export(
        model,
        dummy_input,
        str(output_path),
        export_params=True,
        opset_version=opset_version,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={
            'input': {0: 'batch_size'},
            'output': {0: 'batch_size'}
        },
        dynamo=False  # Use legacy TorchScript exporter
    )
    
    print(f"\nONNX model saved to: {output_path}")
    
    # Verify
    try:
        import onnx
        onnx_model = onnx.load(str(output_path))
        onnx.checker.check_model(onnx_model)
        print("ONNX model verification: PASSED")
    except ImportError:
        print("WARNING: onnx package not installed, skipping verification")
    except Exception as e:
        print(f"WARNING: ONNX verification failed: {e}")
    
    # Save metadata for MQL5
    meta_path = output_path.with_suffix('.json')
    with open(meta_path, 'w') as f:
        json.dump({
            'model_type': model_type,
            'seq_length': seq_length,
            'n_features': n_features,
            'feature_cols': feature_cols,
            'hidden_size': hidden_size,
            'input_shape': list(dummy_input.shape),
            'opset_version': opset_version
        }, f, indent=2)
    print(f"Metadata saved to: {meta_path}")
    
    # Generate scaler params for MQL5
    print("\nGenerating scaler parameters for MQL5...")
    scaler_path = Path(model_path).parent / 'scaler.pkl'
    if scaler_path.exists():
        import pickle
        with open(scaler_path, 'rb') as f:
            scaler = pickle.load(f)
        
        scaler_params = {
            'mean': scaler.mean_.tolist(),
            'scale': scaler.scale_.tolist(),
            'feature_cols': feature_cols
        }
        
        scaler_json_path = output_path.parent / 'scaler_params.json'
        with open(scaler_json_path, 'w') as f:
            json.dump(scaler_params, f, indent=2)
        print(f"Scaler params saved to: {scaler_json_path}")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description='Export trained PyTorch model to ONNX format'
    )
    parser.add_argument('--model', '-m', required=True,
                        help='Path to trained .pt model file')
    parser.add_argument('--output', '-o', default='MQL5/Models/direction_model.onnx',
                        help='Output path for ONNX model')
    parser.add_argument('--opset', type=int, default=11,
                        help='ONNX opset version (default: 11)')
    
    args = parser.parse_args()
    
    success = export_to_onnx(
        model_path=args.model,
        output_path=args.output,
        opset_version=args.opset
    )
    
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
