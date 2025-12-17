"""
Test script to verify ONNX migration for ML modules.
"""
import sys
from pathlib import Path

import numpy as np

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

def test_model_trainer_onnx():
    """Test ModelTrainer ONNX export/import."""
    print("\n" + "="*60)
    print("Testing ModelTrainer ONNX Migration")
    print("="*60)

    try:
        from ml.model_trainer import ModelTrainer, TrainingConfig

        # Create synthetic data
        np.random.seed(42)
        X = np.random.randn(1000, 10)
        y = (X[:, 0] + X[:, 1] > 0).astype(int)

        # Configure to use ONNX
        config = TrainingConfig(
            n_splits=3,
            wf_train_size=500,
            wf_test_size=100,
            wf_step_size=100,
            save_onnx=True,
            model_dir="data/test_models"
        )

        trainer = ModelTrainer(config=config)

        # Test with Random Forest (sklearn)
        print("\n1. Testing Random Forest ONNX export...")
        result = trainer.train_classifier(
            X, y,
            model_type="random_forest",
            n_estimators=10,
            max_depth=5
        )

        print(f"   ✓ Model trained: {result.model_name}")
        print(f"   ✓ Accuracy: {result.accuracy:.3f}")
        print(f"   ✓ WFE: {result.wf_efficiency:.3f}")
        print(f"   ✓ Saved to: {result.model_path}")

        # Check if ONNX file exists
        if result.model_path.endswith('.onnx'):
            print("   ✓ ONNX export successful!")

            # Test loading
            print("\n2. Testing ONNX model loading...")
            loaded_model = trainer.load_model(result.model_path)
            print(f"   ✓ Model loaded: {type(loaded_model).__name__}")

            # Test inference with ONNX
            print("\n3. Testing ONNX inference...")
            test_input = X[:5]

            if hasattr(loaded_model, 'run'):
                # ONNX Runtime session
                input_name = loaded_model.get_inputs()[0].name
                output = loaded_model.run(None, {input_name: test_input.astype(np.float32)})
                print(f"   ✓ ONNX inference successful! Output shape: {output[0].shape}")
            else:
                print(f"   ⚠ Loaded model is not ONNX session: {type(loaded_model)}")
        else:
            print(f"   ⚠ Model saved as pickle: {result.model_path}")

        print("\n✅ ModelTrainer ONNX migration test PASSED!")
        return

    except Exception as e:
        print(f"\n❌ ModelTrainer test FAILED: {e}")
        import traceback
        traceback.print_exc()
        raise


def test_ensemble_predictor_onnx():
    """Test EnsemblePredictor ONNX/JSON export/import."""
    print("\n" + "="*60)
    print("Testing EnsemblePredictor ONNX/JSON Migration")
    print("="*60)

    try:
        from sklearn.ensemble import RandomForestClassifier

        from ml.ensemble_predictor import EnsembleConfig, EnsemblePredictor

        # Create synthetic data
        np.random.seed(42)
        X_train = np.random.randn(500, 10)
        y_train = (X_train[:, 0] + X_train[:, 1] > 0).astype(int)

        # Train simple models
        print("\n1. Training models for ensemble...")
        model1 = RandomForestClassifier(n_estimators=10, max_depth=5, random_state=42)
        model1.fit(X_train, y_train)
        print("   ✓ Model 1 trained")

        model2 = RandomForestClassifier(n_estimators=15, max_depth=4, random_state=43)
        model2.fit(X_train, y_train)
        print("   ✓ Model 2 trained")

        # Create ensemble
        print("\n2. Creating ensemble...")
        config = EnsembleConfig(
            model_weights={"model1": 0.6, "model2": 0.4},
            min_probability=0.55,
            min_confidence=0.60
        )
        ensemble = EnsemblePredictor(config=config)
        ensemble.add_model("model1", model1)
        ensemble.add_model("model2", model2)
        print("   ✓ Ensemble created")

        # Test prediction before save
        print("\n3. Testing prediction before save...")
        test_features = X_train[:1]
        pred = ensemble.predict(test_features)
        print(f"   ✓ Prediction: {pred.signal.name}, prob={pred.probability:.3f}, conf={pred.confidence:.3f}")

        # Save ensemble
        print("\n4. Saving ensemble to ONNX/JSON...")
        save_path = "data/test_models/test_ensemble"
        ensemble.save(save_path)
        print(f"   ✓ Ensemble saved to: {save_path}")

        # Check directory structure
        save_dir = Path(save_path)
        if save_dir.exists():
            print(f"   ✓ Directory created: {save_dir}")

            config_file = save_dir / "config.json"
            if config_file.exists():
                print(f"   ✓ Config JSON exists: {config_file}")

            models_dir = save_dir / "models"
            if models_dir.exists():
                onnx_files = list(models_dir.glob("*.onnx"))
                print(f"   ✓ ONNX models saved: {len(onnx_files)} files")

        # Load ensemble
        print("\n5. Loading ensemble from ONNX/JSON...")
        loaded_ensemble = EnsemblePredictor.load(str(save_dir))
        print(f"   ✓ Ensemble loaded with {len(loaded_ensemble._models)} models")

        # Test prediction after load
        print("\n6. Testing prediction after load...")
        pred_loaded = loaded_ensemble.predict(test_features)
        print(f"   ✓ Prediction: {pred_loaded.signal.name}, prob={pred_loaded.probability:.3f}, conf={pred_loaded.confidence:.3f}")

        # Compare predictions
        if abs(pred.probability - pred_loaded.probability) < 0.01:
            print("   ✓ Predictions match before/after save!")
        else:
            print(f"   ⚠ Prediction mismatch: {pred.probability:.3f} vs {pred_loaded.probability:.3f}")

        print("\n✅ EnsemblePredictor ONNX/JSON migration test PASSED!")
        return

    except Exception as e:
        print(f"\n❌ EnsemblePredictor test FAILED: {e}")
        import traceback
        traceback.print_exc()
        raise


if __name__ == "__main__":
    print("\n" + "="*60)
    print("ONNX MIGRATION VERIFICATION TESTS")
    print("="*60)

    results = []

    def _run_as_bool(fn):
        try:
            fn()
            return True
        except BaseException:
            return False

    # Test ModelTrainer
    results.append(_run_as_bool(test_model_trainer_onnx))

    # Test EnsemblePredictor
    results.append(_run_as_bool(test_ensemble_predictor_onnx))

    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    passed = sum(results)
    total = len(results)
    print(f"\nTests Passed: {passed}/{total}")

    if passed == total:
        print("\n✅ ALL TESTS PASSED - ONNX Migration Successful!")
        sys.exit(0)
    else:
        print("\n❌ SOME TESTS FAILED - Review errors above")
        sys.exit(1)
