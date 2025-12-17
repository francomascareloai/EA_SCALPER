"""
Simple test to verify ONNX conversion works.
"""
import tempfile
import warnings
from pathlib import Path

import numpy as np
import pytest

warnings.filterwarnings(
    "ignore",
    message=r"Field onnx\.AttributeProto\.ints: Expected an int, got a boolean\..*",
    category=DeprecationWarning,
)


def _sklearn_to_onnx() -> None:
    """Sklearn model ONNX conversion smoke test."""
    print("\n" + "="*60)
    print("Testing sklearn -> ONNX conversion")
    print("="*60)

    import onnxruntime as ort
    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType
    from sklearn.ensemble import RandomForestClassifier

    # Train simple model
    print("\n1. Training RandomForest model...")
    X = np.random.randn(100, 5).astype(np.float32)
    y = (X[:, 0] + X[:, 1] > 0).astype(int)

    model = RandomForestClassifier(n_estimators=5, max_depth=3, random_state=42)
    model.fit(X, y)
    print("   OK: Model trained")

    with warnings.catch_warnings():
        warnings.filterwarnings(
            "ignore",
            message=r"Field onnx\.AttributeProto\.ints: Expected an int, got a boolean\..*",
            category=DeprecationWarning,
        )

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
    assert match, "ONNX and sklearn predictions should match for RandomForest"
    print("   OK: Predictions match!")

    # Cleanup
    Path(temp_path).unlink()

    print("\nSUCCESS: sklearn -> ONNX conversion works!")


def _lightgbm_to_onnx() -> None:
    """LightGBM model ONNX conversion smoke test."""
    print("\n" + "="*60)
    print("Testing LightGBM -> ONNX conversion")
    print("="*60)

    lgb = pytest.importorskip("lightgbm")
    onnxmltools = pytest.importorskip("onnxmltools")
    ort = pytest.importorskip("onnxruntime")
    from onnxmltools.convert.common.data_types import FloatTensorType
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
    with warnings.catch_warnings():
        warnings.filterwarnings(
            "ignore",
            message=r"Field onnx\.AttributeProto\.ints: Expected an int, got a boolean\..*",
            category=DeprecationWarning,
        )
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


def test_sklearn_to_onnx() -> None:
    _sklearn_to_onnx()


def test_lightgbm_to_onnx() -> None:
    _lightgbm_to_onnx()


if __name__ == "__main__":
    print("\n" + "="*60)
    print("ONNX CONVERSION TESTS")
    print("="*60)

    results = []

    def _run_as_bool(fn) -> bool:
        try:
            fn()
            return True
        except BaseException:
            return False

    # Test sklearn
    results.append(_run_as_bool(_sklearn_to_onnx))

    # Test LightGBM
    results.append(_run_as_bool(_lightgbm_to_onnx))

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
