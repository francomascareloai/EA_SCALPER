"""
Generate session-specific parquet datasets for empirical session analysis.

Splits full 24h dataset into individual session files:
- Asian (19:00-02:00 ET)
- London (02:00-07:00 ET)
- Overlap (07:00-10:00 ET)
- NY (10:00-12:00 ET)
- Late NY (12:00-16:00 ET)

Usage:
    python scripts/generate_session_datasets.py
    
Output:
    data/processed/by_session/xauusd_2020_2024_stride20_asian.parquet
    data/processed/by_session/xauusd_2020_2024_stride20_london.parquet
    data/processed/by_session/xauusd_2020_2024_stride20_overlap.parquet
    data/processed/by_session/xauusd_2020_2024_stride20_ny.parquet
    data/processed/by_session/xauusd_2020_2024_stride20_late_ny.parquet
"""
import yaml
import pandas as pd
import pytz
from pathlib import Path


def generate_session_datasets():
    """Generate session-specific datasets from active dataset."""
    
    # Load config
    config_path = Path("data/config.yaml")
    if not config_path.exists():
        raise FileNotFoundError(f"Config not found: {config_path}")
    
    config = yaml.safe_load(open(config_path))
    
    # Load active dataset
    active_dataset = config["active_dataset"]
    input_path = Path(active_dataset["path"])
    
    print("=" * 80)
    print("GENERATING SESSION-SPECIFIC DATASETS")
    print("=" * 80)
    print(f"\nInput: {input_path}")
    print(f"Dataset: {active_dataset['name']}")
    print(f"Total ticks: {active_dataset['stats']['total_ticks']:,}")
    
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")
    
    # Load data
    print("\nLoading data...")
    df = pd.read_parquet(input_path)
    
    # Ensure UTC timezone
    if df['datetime'].dt.tz is None:
        df['datetime'] = df['datetime'].dt.tz_localize('UTC')
    
    # Convert to ET for session filtering
    df['datetime_et'] = df['datetime'].dt.tz_convert(pytz.timezone('US/Eastern'))
    df['hour_et'] = df['datetime_et'].dt.hour
    
    # Create output directory
    output_dir = Path("data/processed/by_session")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Session definitions (from config)
    sessions = config["generation_settings"]["sessions"]
    
    print(f"\n{'-' * 80}")
    print("GENERATING SESSIONS:")
    print(f"{'-' * 80}")
    
    # Generate each session
    for session_name, session_config in sessions.items():
        start_hour = session_config["start_hour"]
        end_hour = session_config["end_hour"]
        description = session_config["description"]
        
        print(f"\n[{session_name.upper()}] {description}")
        print(f"  Hours: {start_hour:02d}:00 - {end_hour:02d}:00 ET")
        
        # Handle overnight sessions (e.g., Asian 19:00-02:00)
        if start_hour > end_hour:
            # Spans midnight
            session_df = df[(df['hour_et'] >= start_hour) | (df['hour_et'] < end_hour)]
        else:
            session_df = df[(df['hour_et'] >= start_hour) & (df['hour_et'] < end_hour)]
        
        # Remove helper columns
        session_df = session_df.drop(columns=['datetime_et', 'hour_et'])
        
        # Generate output filename
        base_name = input_path.stem.replace("_full", "")
        output_filename = f"{base_name}_{session_name}.parquet"
        output_path = output_dir / output_filename
        
        # Save
        session_df.to_parquet(output_path, compression='snappy')
        
        file_size_mb = output_path.stat().st_size / 1024 / 1024
        percentage = len(session_df) / len(df) * 100
        
        print(f"  Ticks: {len(session_df):,} ({percentage:.1f}% of total)")
        print(f"  Output: {output_path}")
        print(f"  Size: {file_size_mb:.1f} MB")
        print(f"  [OK] Generated")
    
    print(f"\n{'=' * 80}")
    print("SESSION DATASETS GENERATED SUCCESSFULLY")
    print(f"{'=' * 80}")
    print(f"\nOutput directory: {output_dir}")
    print(f"Total files: {len(sessions)}")
    
    print("\nNext steps:")
    print("1. Run backtest on each session independently:")
    print("   python scripts/run_backtest.py --start 2024-11-01 --end 2024-11-30")
    print("   (Update config.yaml to point to each session file)")
    print("\n2. Compare metrics: win rate, Sharpe, profit factor, DD")
    print("\n3. Update config.yaml session_performance with results")
    print("\n4. Apply session filter based on empirical evidence")


if __name__ == "__main__":
    generate_session_datasets()
