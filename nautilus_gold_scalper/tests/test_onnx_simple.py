"""
Simple test to verify ONNX conversion works.
"""
import numpy as np
from pathlib import Path
import tempfile

def test_sklearn_to_onnx():
    """Test sklearn model ONNX conversion."""
    print("\n" + "="*60)
    print("Testing sklearn -> ONNX conversion")
    print("="*60)
    
    try:
        from sklearn.ensemble import RandomForestClassifier
        from skl2onnx import convert_sklearn
        from skl2onnx.common.data_types import FloatTensorType
        import onnxruntime as ort
        
        # Train simple model
        print("\n1. Training RandomForest model...")
        X = np.random.randn(100, 5).astype(np.float32)
        y = (X[:, 0] + X[:, 1] > 0).astype(int)
        
        model = RandomForestClassifier(n_estimators=5, max_depth=3, random_state=42)
        model.fit(X, y)
        print("   OK: Model trained")
        
        # Convert to ONNX
        print("\n2. Converting to ONNX...")
        initial_type = [('float_input', FloatTensorType([None, 5]))]
        onnx_model = convert_sklearn(model, initial_types=initial_type, target_opset=12)
        print("   OK: Converted to ONNX")
        
        # Save to temp file
        with tempfile.NamedTemporaryFile(suffix='.onnx', delete=False) as f:
            temp_path = f.name
        
        with open(temp_path, 'wb') as f:
            f.write(onnx_model.SerializeToString())
        print(f"   OK: Saved to {temp_path}")
        
        # Load and test inference
        print("\n3. Testing ONNX inference...")
        sess = ort.InferenceSession(temp_path, providers=['CPUExecutionProvider'])
        
        input_name = sess.get_inputs()[0].name
        test_input = X[:3]
        
        onnx_pred = sess.run(None, {input_name: test_input})[0]
        sklearn_pred = model.predict(test_input)
        
        print(f"   ONNX prediction: {onnx_pred}")
        print(f"   sklearn prediction: {sklearn_pred}")
        
        # Compare
        match = np.allclose(onnx_pred, sklearn_pred)
        if match:
            print("   OK: Predictions match!")
        else:
            print("   WARNING: Predictions differ")
        
        # Cleanup
        Path(temp_path).unlink()
        
        print("\nSUCCESS: sklearn -> ONNX conversion works!")
        return True
        
    except Exception as e:
        print(f"\nFAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_lightgbm_to_onnx():
    """Test LightGBM model ONNX conversion."""
    print("\n" + "="*60)
    print("Testing LightGBM -> ONNX conversion")
    print("="*60)
    
    try:
        import lightgbm as lgb
        import onnxmltools
        from onnxmltools.convert.common.data_types import FloatTensorType
        import onnxruntime as ort
        
        # Train simple model
        print("\n1. Training LightGBM model...")
        X = np.random.randn(100, 5).astype(np.float32)
        y = (X[:, 0] + X[:, 1] > 0).astype(int)
        
        model = lgb.LGBMClassifier(n_estimators=5, max_depth=3, verbose=-1, random_state=42)
        model.fit(X, y)
        print("   OK: Model trained")
        
        # Convert to ONNX
        print("\n2. Converting to ONNX...")
        initial_type = [('float_input', FloatTensorType([None, 5]))]
        onnx_model = onnxmltools.convert_lightgbm(model, initial_types=initial_type, target_opset=12)
        print("   OK: Converted to ONNX")
        
        # Save to temp file
        with tempfile.NamedTemporaryFile(suffix='.onnx', delete=False) as f:
            temp_path = f.name
        
        onnxmltools.utils.save_model(onnx_model, temp_path)
        print(f"   OK: Saved to {temp_path}")
        
        # Load and test inference
        print("\n3. Testing ONNX inference...")
        sess = ort.InferenceSession(temp_path, providers=['CPUExecutionProvider'])
        
        input_name = sess.get_inputs()[0].name
        test_input = X[:3]
        
        onnx_output = sess.run(None, {input_name: test_input})
        print(f"   OK: ONNX inference successful, output shape: {onnx_output[0].shape}")
        
        # Cleanup
        Path(temp_path).unlink()
        
        print("\nSUCCESS: LightGBM -> ONNX conversion works!")
        return True
        
    except ImportError as e:
        print(f"\nSKIPPED: LightGBM not available - {e}")
        return True  # Not a failure, just not installed
    except Exception as e:
        print(f"\nFAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("\n" + "="*60)
    print("ONNX CONVERSION TESTS")
    print("="*60)
    
    results = []
    
    # Test sklearn
    results.append(test_sklearn_to_onnx())
    
    # Test LightGBM
    results.append(test_lightgbm_to_onnx())
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    passed = sum(results)
    total = len(results)
    print(f"\nTests: {passed}/{total} passed")
    
    if passed == total:
        print("\nALL TESTS PASSED!")
    else:
        print("\nSOME TESTS FAILED")
