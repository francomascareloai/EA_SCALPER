"""
Main Training and Export Script
EA_SCALPER_XAUUSD - Singularity Edition

Complete pipeline: Data -> Features -> Train -> Validate -> Export -> Deploy

Usage:
    python -m ml_pipeline.train_and_export [--data-file FILE] [--days DAYS]
"""
import argparse
import sys
from pathlib import Path

import numpy as np
import pandas as pd

from .config import DATA_DIR, MODELS_DIR, TRAINING_CONFIG, DIRECTION_CONFIG
from .data_collector import MT5DataCollector, CSVDataLoader, collect_training_data
from .feature_engineering import create_features, create_labels, prepare_training_data
from .model_training import train_direction_model, walk_forward_analysis, save_model
from .onnx_export import export_direction_model, create_model_info


def run_full_pipeline(
    data_file: str = None,
    collect_days: int = 365,
    model_type: str = "lstm",
    run_wfa: bool = True
):
    """
    Run the complete ML pipeline
    
    Args:
        data_file: Path to CSV data file (if None, collects from MT5)
        collect_days: Days of data to collect from MT5
        model_type: "lstm" or "gru"
        run_wfa: Whether to run Walk-Forward Analysis
    """
    print("=" * 60)
    print("EA_SCALPER_XAUUSD - ML Pipeline")
    print("Singularity Edition")
    print("=" * 60)
    
    # Step 1: Get Data
    print("\n[1/5] Loading Data...")
    
    if data_file:
        loader = CSVDataLoader()
        df = loader.load(data_file)
        if df is None:
            print(f"Failed to load {data_file}")
            return False
    else:
        # Try to collect from MT5
        print(f"Collecting {collect_days} days of data from MT5...")
        data = collect_training_data(days=collect_days, timeframes=["M15"])
        
        if not data:
            # Check for existing data
            existing_files = list(DATA_DIR.glob("*.csv"))
            if existing_files:
                print(f"Using existing data file: {existing_files[0]}")
                loader = CSVDataLoader()
                df = loader.load(existing_files[0].name)
            else:
                print("No data available. Please:")
                print("1. Ensure MT5 is running and logged in, OR")
                print("2. Place a CSV file in:", DATA_DIR)
                return False
        else:
            df = data["M15"]
    
    print(f"Data loaded: {len(df)} bars from {df.index[0]} to {df.index[-1]}")
    
    # Step 2: Prepare Features
    print("\n[2/5] Engineering Features...")
    
    X_train, y_train, X_val, y_val, scaler = prepare_training_data(
        df,
        sequence_length=DIRECTION_CONFIG.sequence_length,
        lookahead=5,
        threshold=0.001,
        validation_split=TRAINING_CONFIG.validation_split
    )
    
    print(f"Training set: {X_train.shape[0]} samples")
    print(f"Validation set: {X_val.shape[0]} samples")
    print(f"Features: {X_train.shape[2]}")
    print(f"Sequence length: {X_train.shape[1]}")
    
    # Step 3: Walk-Forward Analysis (optional but recommended)
    wfe = 0.0
    if run_wfa:
        print("\n[3/5] Walk-Forward Analysis...")
        X_full = np.concatenate([X_train, X_val], axis=0)
        y_full = np.concatenate([y_train, y_val], axis=0)
        
        accuracies, wfe = walk_forward_analysis(
            X_full, y_full,
            n_splits=TRAINING_CONFIG.walk_forward_windows
        )
        
        if wfe < TRAINING_CONFIG.min_wfe:
            print(f"\nWARNING: WFE ({wfe:.4f}) is below minimum ({TRAINING_CONFIG.min_wfe})")
            print("Model may not generalize well. Consider:")
            print("- More training data")
            print("- Different features")
            print("- Simpler model")
            # Continue anyway for now
    else:
        print("\n[3/5] Skipping Walk-Forward Analysis...")
    
    # Step 4: Train Final Model
    print("\n[4/5] Training Final Model...")
    
    model, history = train_direction_model(
        X_train, y_train,
        X_val, y_val,
        model_type=model_type
    )
    
    # Save model
    model_path = save_model(model, history, f"direction_{model_type}")
    
    # Step 5: Export to ONNX
    print("\n[5/5] Exporting to ONNX...")
    
    success = export_direction_model(model=model, model_type=model_type)
    
    if success:
        # Create model info
        create_model_info(
            "direction_model",
            (1, DIRECTION_CONFIG.sequence_length, len(DIRECTION_CONFIG.features)),
            (1, 2),
            DIRECTION_CONFIG.features,
            "scaler_params.json"
        )
        
        print("\n" + "=" * 60)
        print("PIPELINE COMPLETE!")
        print("=" * 60)
        print(f"\nResults:")
        print(f"  - Validation Accuracy: {history['final_accuracy']:.4f}")
        print(f"  - Walk-Forward Efficiency: {wfe:.4f}")
        print(f"  - Model saved to: {model_path}")
        print(f"  - ONNX deployed to: MQL5/Models/direction_model.onnx")
        print(f"\nNext steps:")
        print("  1. Restart MetaTrader 5")
        print("  2. Attach EA to XAUUSD M15 chart")
        print("  3. Enable 'Use ML' option")
        print("  4. Run backtest to validate")
        
        return True
    else:
        print("Export failed!")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="EA_SCALPER_XAUUSD ML Training Pipeline"
    )
    parser.add_argument(
        "--data-file", "-d",
        type=str,
        default=None,
        help="Path to CSV data file (if not provided, collects from MT5)"
    )
    parser.add_argument(
        "--days",
        type=int,
        default=365,
        help="Days of data to collect from MT5 (default: 365)"
    )
    parser.add_argument(
        "--model",
        type=str,
        default="lstm",
        choices=["lstm", "gru"],
        help="Model type (default: lstm)"
    )
    parser.add_argument(
        "--skip-wfa",
        action="store_true",
        help="Skip Walk-Forward Analysis (faster but less reliable)"
    )
    
    args = parser.parse_args()
    
    success = run_full_pipeline(
        data_file=args.data_file,
        collect_days=args.days,
        model_type=args.model,
        run_wfa=not args.skip_wfa
    )
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
