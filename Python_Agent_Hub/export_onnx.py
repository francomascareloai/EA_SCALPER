"""
Simple ONNX Export for Direction Model
"""
import torch
import torch.nn as nn
import shutil
from pathlib import Path
from datetime import datetime
import sys
import os

# Disable Unicode output issues
os.environ['PYTHONIOENCODING'] = 'utf-8'

print('='*60)
print('ONNX Export Script')
print('='*60)

BASE = Path(r'C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\Python_Agent_Hub')
MODELS_DIR = BASE / 'ml_pipeline/models'
MQL5_MODELS = BASE.parent / 'MQL5' / 'Models'
MQL5_MODELS.mkdir(exist_ok=True)

SEQ_LEN = 100
N_FEATURES = 13

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

# Load or create model
print('\nCreating model...')
model = DirectionLSTM(input_size=N_FEATURES)
model.eval()

# Dummy input
print('Creating dummy input...')
dummy = torch.randn(1, SEQ_LEN, N_FEATURES)

# Export with JIT trace method (most compatible)
print('Exporting ONNX...')
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
onnx_path = MODELS_DIR / f'direction_13f_{timestamp}.onnx'

# Use torch.onnx.dynamo_export (PyTorch 2.x API)
try:
    # Try the new dynamo export first
    export_output = torch.onnx.dynamo_export(model, dummy)
    export_output.save(str(onnx_path))
except Exception as e:
    print(f'  Dynamo export failed: {e}')
    print('  Trying torch.jit.script...')
    
    # Fallback: Script and export without dynamic axes
    scripted = torch.jit.script(model)
    scripted.save(str(MODELS_DIR / f'direction_13f_{timestamp}.pt'))
    
    # Manual ONNX export
    torch.onnx.export(
        model, 
        dummy, 
        str(onnx_path),
        input_names=['input'], 
        output_names=['output'],
        opset_version=17,
        dynamo=False
    )
print(f'  Saved: {onnx_path}')

# Copy to destinations
print('Copying to MQL5/Models...')
shutil.copy(onnx_path, MODELS_DIR / 'direction_model_final.onnx')
shutil.copy(onnx_path, MQL5_MODELS / 'direction_model_final.onnx')

# Copy scaler
scaler_src = MODELS_DIR / 'scaler_params_13f.json'
if scaler_src.exists():
    shutil.copy(scaler_src, MQL5_MODELS / 'scaler_params_final.json')
    print('  Copied scaler_params_final.json')

print('\n' + '='*60)
print('EXPORT COMPLETE!')
print('='*60)
print(f'Model: MQL5/Models/direction_model_final.onnx')
print(f'Scaler: MQL5/Models/scaler_params_final.json')
print('='*60)
