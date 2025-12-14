"""
Analyze existing Parquet tick data files to assess backtest readiness.
"""
import pandas as pd
import pyarrow.parquet as pq
from pathlib import Path
from datetime import datetime

def analyze_parquet_file(parquet_path: Path) -> dict:
    """Analyze a single Parquet file."""
    try:
        # Read metadata
        parquet_file = pq.ParquetFile(str(parquet_path))
        
        # Get basic stats
        num_rows = parquet_file.metadata.num_rows
        num_cols = parquet_file.metadata.num_columns
        file_size_mb = parquet_path.stat().st_size / (1024 * 1024)
        
        # Get schema
        schema = {parquet_file.schema[i].name: str(parquet_file.schema[i].physical_type) 
                  for i in range(num_cols)}
        
        # Sample first and last rows to get date range
        df_first = pd.read_parquet(parquet_path, engine='pyarrow').head(1)
        df_last = pd.read_parquet(parquet_path, engine='pyarrow').tail(1)
        
        # Determine datetime column
        datetime_col = None
        for col in ['datetime', 'DateTime', 'timestamp', 'time']:
            if col in df_first.columns:
                datetime_col = col
                break
        
        date_start = df_first[datetime_col].iloc[0] if datetime_col else None
        date_end = df_last[datetime_col].iloc[0] if datetime_col else None
        
        return {
            'file': parquet_path.name,
            'path': str(parquet_path),
            'rows': num_rows,
            'columns': num_cols,
            'size_mb': round(file_size_mb, 2),
            'schema': schema,
            'date_start': date_start,
            'date_end': date_end,
            'days': (date_end - date_start).days if date_start and date_end else None,
            'status': '✅ OK'
        }
    except Exception as e:
        return {
            'file': parquet_path.name,
            'path': str(parquet_path),
            'status': f'❌ Error: {str(e)}'
        }


def main():
    """Analyze all tick Parquet files."""
    project_root = Path(__file__).parent.parent
    
    # Look for tick data in multiple locations
    search_paths = [
        project_root / "data" / "ticks",
        project_root / "data" / "processed",
        project_root / "Python_Agent_Hub" / "ml_pipeline" / "data",
    ]
    
    print("=" * 80)
    print("PARQUET TICK DATA ANALYSIS")
    print("=" * 80)
    
    all_files = []
    for search_path in search_paths:
        if search_path.exists():
            parquet_files = list(search_path.glob("*.parquet"))
            tick_files = [f for f in parquet_files if 'tick' in f.name.lower()]
            all_files.extend(tick_files)
    
    if not all_files:
        print("❌ No tick Parquet files found in:")
        for path in search_paths:
            print(f"  - {path}")
        return
    
    print(f"\nFound {len(all_files)} Parquet files\n")
    
    results = []
    for parquet_file in sorted(all_files, key=lambda x: x.name):
        print(f"Analyzing {parquet_file.name}...")
        result = analyze_parquet_file(parquet_file)
        results.append(result)
    
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80 + "\n")
    
    for result in results:
        print(f"FILE: {result['file']}")
        print(f"   Status: {result['status']}")
        if result['status'] == '✅ OK':
            print(f"   Rows: {result['rows']:,}")
            print(f"   Size: {result['size_mb']:.2f} MB")
            print(f"   Period: {result['date_start']} to {result['date_end']} ({result['days']} days)")
            print(f"   Columns: {', '.join(result['schema'].keys())}")
        print()
    
    # Recommend best file for backtest
    ok_results = [r for r in results if r['status'] == '✅ OK']
    if ok_results:
        # Prefer files with most recent data and good coverage
        best = max(ok_results, key=lambda x: (x['date_end'], x['rows']))
        
        print("=" * 80)
        print("RECOMMENDATION FOR BACKTEST")
        print("=" * 80)
        print(f"\n>>> Best file: {best['file']}")
        print(f"   Path: {best['path']}")
        print(f"   Rows: {best['rows']:,} ticks")
        print(f"   Period: {best['date_start']} to {best['date_end']}")
        print(f"   Size: {best['size_mb']:.2f} MB")
        print(f"\n✅ READY FOR BACKTEST!")
        print(f"\nUsage in run_backtest.py:")
        print(f'   tick_path = Path("{best["path"]}")')


if __name__ == "__main__":
    main()
