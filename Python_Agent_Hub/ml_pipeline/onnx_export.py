"""
ONNX Export for MQL5 Integration
EA_SCALPER_XAUUSD - Singularity Edition

Exports PyTorch models to ONNX format for use in MetaTrader 5
"""
import torch
import torch.nn as nn
import numpy as np
from pathlib import Path
from typing import Optional
import onnx
import json
import shutil

from .config import MODELS_DIR, MQL5_MODELS_DIR, DIRECTION_CONFIG
from .model_training import DirectionLSTM, DirectionGRU


def export_to_onnx(
    model: nn.Module,
    input_shape: tuple,
    output_path: Path,
    opset_version: int = 11
) -> bool:
    """
    Export PyTorch model to ONNX format
    
    Args:
        model: Trained PyTorch model
        input_shape: Input tensor shape (batch, sequence, features)
        output_path: Path to save ONNX model
        opset_version: ONNX opset version (11 works well with MQL5)
        
    Returns:
        True if successful
    """
    model.eval()
    
    # Create dummy input
    dummy_input = torch.randn(input_shape)
    
    try:
        # Export
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
            }
        )
        
        # Validate
        onnx_model = onnx.load(str(output_path))
        onnx.checker.check_model(onnx_model)
        
        print(f"Model exported successfully to {output_path}")
        print(f"Input shape: {input_shape}")
        print(f"Opset version: {opset_version}")
        
        return True
        
    except Exception as e:
        print(f"Export failed: {e}")
        return False


def verify_onnx_inference(
    onnx_path: Path,
    test_input: np.ndarray
) -> Optional[np.ndarray]:
    """
    Verify ONNX model produces valid output
    
    Args:
        onnx_path: Path to ONNX model
        test_input: Test input array
        
    Returns:
        Model output or None if failed
    """
    try:
        import onnxruntime as ort
        
        session = ort.InferenceSession(str(onnx_path))
        input_name = session.get_inputs()[0].name
        output_name = session.get_outputs()[0].name
        
        result = session.run(
            [output_name],
            {input_name: test_input.astype(np.float32)}
        )
        
        output = result[0]
        print(f"ONNX inference successful!")
        print(f"Output shape: {output.shape}")
        print(f"Sample output: {output[0]}")
        
        return output
        
    except ImportError:
        print("onnxruntime not installed. Install with: pip install onnxruntime")
        return None
    except Exception as e:
        print(f"Inference verification failed: {e}")
        return None


def copy_to_mql5(source_path: Path, model_name: str = "direction_model.onnx"):
    """Copy ONNX model to MQL5 Models folder"""
    dest_path = MQL5_MODELS_DIR / model_name
    
    try:
        shutil.copy(source_path, dest_path)
        print(f"Model copied to {dest_path}")
        return True
    except Exception as e:
        print(f"Failed to copy model: {e}")
        return False


def export_direction_model(
    model_path: Optional[Path] = None,
    model: Optional[nn.Module] = None,
    model_type: str = "lstm"
) -> bool:
    """
    Export direction model to ONNX and copy to MQL5
    
    Args:
        model_path: Path to saved PyTorch model (.pt file)
        model: Or provide model directly
        model_type: "lstm" or "gru"
        
    Returns:
        True if successful
    """
    # Load model if path provided
    if model is None and model_path:
        config = {
            "input_size": len(DIRECTION_CONFIG.features),
            "hidden_size": DIRECTION_CONFIG.hidden_size,
            "num_layers": DIRECTION_CONFIG.num_layers,
            "dropout": DIRECTION_CONFIG.dropout,
            "output_size": DIRECTION_CONFIG.output_size
        }
        
        if model_type == "gru":
            model = DirectionGRU(**config)
        else:
            model = DirectionLSTM(**config)
            
        checkpoint = torch.load(model_path)
        model.load_state_dict(checkpoint['model_state_dict'])
        print(f"Loaded model from {model_path}")
        
    if model is None:
        print("No model provided")
        return False
    
    # Export to ONNX
    input_shape = (1, DIRECTION_CONFIG.sequence_length, len(DIRECTION_CONFIG.features))
    onnx_path = MODELS_DIR / "direction_model.onnx"
    
    if not export_to_onnx(model, input_shape, onnx_path):
        return False
    
    # Verify inference
    test_input = np.random.randn(*input_shape).astype(np.float32)
    output = verify_onnx_inference(onnx_path, test_input)
    
    if output is None:
        return False
    
    # Copy to MQL5 folder
    if not copy_to_mql5(onnx_path, "direction_model.onnx"):
        return False
    
    print("\nDirection model exported and deployed to MQL5!")
    return True


def create_model_info(
    model_name: str,
    input_shape: tuple,
    output_shape: tuple,
    features: list,
    scaler_path: str
) -> dict:
    """Create model info JSON for documentation"""
    info = {
        "model_name": model_name,
        "input_shape": list(input_shape),
        "output_shape": list(output_shape),
        "features": features,
        "scaler_params_path": scaler_path,
        "opset_version": 11,
        "framework": "PyTorch -> ONNX",
        "usage": {
            "input": "Normalized features sequence (batch, seq_len, features)",
            "output": "[P(bearish), P(bullish)]",
            "threshold": 0.65
        }
    }
    
    info_path = MQL5_MODELS_DIR / f"{model_name}_info.json"
    with open(info_path, 'w') as f:
        json.dump(info, f, indent=2)
    
    print(f"Model info saved to {info_path}")
    return info


if __name__ == "__main__":
    print("ONNX Export Example")
    print("=" * 50)
    
    # Create a test model
    config = {
        "input_size": len(DIRECTION_CONFIG.features),
        "hidden_size": DIRECTION_CONFIG.hidden_size,
        "num_layers": DIRECTION_CONFIG.num_layers,
        "dropout": 0.0,  # No dropout for export
        "output_size": DIRECTION_CONFIG.output_size
    }
    
    model = DirectionLSTM(**config)
    
    # Export
    input_shape = (1, DIRECTION_CONFIG.sequence_length, len(DIRECTION_CONFIG.features))
    onnx_path = MODELS_DIR / "test_direction_model.onnx"
    
    if export_to_onnx(model, input_shape, onnx_path):
        # Verify
        test_input = np.random.randn(*input_shape).astype(np.float32)
        verify_onnx_inference(onnx_path, test_input)
        
        # Create model info
        create_model_info(
            "direction_model",
            input_shape,
            (1, 2),
            DIRECTION_CONFIG.features,
            "scaler_params.json"
        )
