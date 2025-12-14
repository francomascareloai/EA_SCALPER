"""
Validate data directory structure and config consistency.

Checks:
1. config.yaml exists and is valid
2. Active dataset file exists
3. Stats in config match actual file
4. Directory structure is correct
5. Scripts reference config.yaml (not hardcoded paths)

Usage:
    python scripts/validate_data_structure.py
"""
import yaml
import pandas as pd
from pathlib import Path
import sys


def validate_config():
    """Validate config.yaml exists and is well-formed."""
    config_path = Path("data/config.yaml")
    
    print("=" * 80)
    print("VALIDATING DATA STRUCTURE")
    print("=" * 80)
    
    if not config_path.exists():
        print(f"\n[X] FAIL: config.yaml not found at {config_path}")
        return None
    
    print(f"\n[OK] config.yaml found: {config_path}")
    
    try:
        config = yaml.safe_load(open(config_path))
        print("[OK] config.yaml is valid YAML")
    except Exception as e:
        print(f"[X] FAIL: config.yaml is invalid YAML: {e}")
        return None
    
    # Check required keys
    required_keys = ["active_dataset", "session_performance", "alternative_datasets", "generation_settings"]
    for key in required_keys:
        if key not in config:
            print(f"[X] FAIL: Missing required key: {key}")
            return None
    
    print(f"[OK] All required keys present")
    return config


def validate_active_dataset(config):
    """Validate active dataset exists and stats match."""
    active = config["active_dataset"]
    
    print(f"\n{'-' * 80}")
    print("ACTIVE DATASET VALIDATION")
    print(f"{'-' * 80}")
    
    print(f"Name: {active['name']}")
    print(f"Path: {active['path']}")
    
    # Check file exists
    file_path = Path(active["path"])
    if not file_path.exists():
        print(f"[X] FAIL: Active dataset file not found: {file_path}")
        return False
    
    print(f"[OK] File exists: {file_path}")
    
    # Check file size
    actual_size_mb = file_path.stat().st_size / 1024 / 1024
    config_size_mb = active["stats"]["file_size_mb"]
    size_diff_pct = abs(actual_size_mb - config_size_mb) / config_size_mb * 100
    
    print(f"File size: {actual_size_mb:.1f} MB (config: {config_size_mb:.1f} MB)")
    
    if size_diff_pct > 5:
        print(f"[!] WARNING: File size differs by {size_diff_pct:.1f}% from config")
        print(f"    This might indicate file was modified or config is outdated")
    else:
        print(f"[OK] File size matches config (within 5%)")
    
    # Load and validate tick count
    try:
        df = pd.read_parquet(file_path)
        actual_ticks = len(df)
        config_ticks = active["stats"]["total_ticks"]
        
        print(f"Tick count: {actual_ticks:,} (config: {config_ticks:,})")
        
        if actual_ticks != config_ticks:
            print(f"[X] FAIL: Tick count mismatch!")
            print(f"    Actual: {actual_ticks:,}")
            print(f"    Config: {config_ticks:,}")
            print(f"    Please update config.yaml stats")
            return False
        
        print(f"[OK] Tick count matches config exactly")
        return True
        
    except Exception as e:
        print(f"[X] FAIL: Could not load parquet file: {e}")
        return False


def validate_directory_structure():
    """Validate directory structure matches README."""
    print(f"\n{'-' * 80}")
    print("DIRECTORY STRUCTURE VALIDATION")
    print(f"{'-' * 80}")
    
    required_dirs = [
        "data/raw",
        "data/processed/by_session",
        "data/processed/by_period",
        "data/processed/experimental",
        "data/versions",
    ]
    
    all_exist = True
    for dir_path in required_dirs:
        path = Path(dir_path)
        if path.exists():
            print(f"[OK] {dir_path}")
        else:
            print(f"[X] MISSING: {dir_path}")
            all_exist = False
    
    return all_exist


def validate_metadata():
    """Check if metadata.json exists for raw datasets."""
    print(f"\n{'-' * 80}")
    print("METADATA VALIDATION")
    print(f"{'-' * 80}")
    
    raw_dir = Path("data/raw")
    parquets = list(raw_dir.glob("*.parquet"))
    
    if not parquets:
        print("[!] WARNING: No parquet files in data/raw/")
        return True
    
    all_have_metadata = True
    for parquet_file in parquets:
        metadata_file = parquet_file.with_suffix(".parquet.metadata.json")
        if metadata_file.exists():
            print(f"[OK] {parquet_file.name} -> {metadata_file.name}")
        else:
            print(f"[!] WARNING: Missing metadata for {parquet_file.name}")
            print(f"    Expected: {metadata_file}")
            all_have_metadata = False
    
    return all_have_metadata


def validate_script_usage():
    """Check if key scripts use config.yaml."""
    print(f"\n{'-' * 80}")
    print("SCRIPT USAGE VALIDATION")
    print(f"{'-' * 80}")
    
    scripts_to_check = [
        ("check_data_quality.py", "config.yaml"),
        ("nautilus_gold_scalper/scripts/run_backtest.py", "config.yaml"),
    ]
    
    all_valid = True
    for script_path, search_term in scripts_to_check:
        path = Path(script_path)
        if not path.exists():
            print(f"[!] WARNING: Script not found: {script_path}")
            continue
        
        content = path.read_text(encoding='utf-8')
        if search_term in content:
            print(f"[OK] {script_path} uses {search_term}")
        else:
            print(f"[X] FAIL: {script_path} does NOT use {search_term}")
            print(f"    Script may have hardcoded paths!")
            all_valid = False
    
    return all_valid


def main():
    """Run all validations."""
    
    # 1. Validate config
    config = validate_config()
    if config is None:
        print("\n[X] VALIDATION FAILED: config.yaml invalid or missing")
        sys.exit(1)
    
    # 2. Validate active dataset
    dataset_valid = validate_active_dataset(config)
    
    # 3. Validate directory structure
    dirs_valid = validate_directory_structure()
    
    # 4. Validate metadata
    metadata_valid = validate_metadata()
    
    # 5. Validate script usage
    scripts_valid = validate_script_usage()
    
    # Summary
    print(f"\n{'=' * 80}")
    print("VALIDATION SUMMARY")
    print(f"{'=' * 80}")
    
    checks = [
        ("config.yaml structure", config is not None),
        ("Active dataset file", dataset_valid),
        ("Directory structure", dirs_valid),
        ("Metadata files", metadata_valid),
        ("Script usage", scripts_valid),
    ]
    
    all_passed = all(result for _, result in checks)
    
    for check_name, result in checks:
        status = "[OK] PASS" if result else "[X] FAIL"
        print(f"{status}: {check_name}")
    
    if all_passed:
        print(f"\n{'=' * 80}")
        print("[OK] ALL VALIDATIONS PASSED!")
        print(f"{'=' * 80}")
        print("\nData structure is correctly configured.")
        print("All scripts should now use config.yaml as single source of truth.")
        sys.exit(0)
    else:
        print(f"\n{'=' * 80}")
        print("[X] SOME VALIDATIONS FAILED")
        print(f"{'=' * 80}")
        print("\nPlease fix the issues above before proceeding.")
        sys.exit(1)


if __name__ == "__main__":
    main()
