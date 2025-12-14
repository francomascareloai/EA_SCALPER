"""Quick check of main Parquet file for backtest."""
import pandas as pd
import pyarrow.parquet as pq
from pathlib import Path

# Check the stride20 file (should be fast - 295MB sampled)
parquet_path = Path(r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\data\ticks\xauusd_2020_2024_stride20.parquet")

print("="*60)
print("QUICK PARQUET CHECK")
print("="*60)
print(f"\nFile: {parquet_path.name}")
print(f"Size: {parquet_path.stat().st_size / 1e6:.1f} MB")

# Metadata
pf = pq.ParquetFile(str(parquet_path))
print(f"Rows: {pf.metadata.num_rows:,}")
print(f"Columns: {pf.metadata.num_columns}")

# Schema
print("\nSchema:")
for i in range(pf.metadata.num_columns):
    col = pf.schema[i]
    print(f"  {col.name}: {col.physical_type}")

# Sample
print("\nFirst 5 rows:")
df = pd.read_parquet(parquet_path).head(5)
print(df)

# Date range
df_full = pd.read_parquet(parquet_path, columns=['datetime'])
print(f"\nDate range:")
print(f"  Start: {df_full['datetime'].min()}")
print(f"  End: {df_full['datetime'].max()}")
print(f"  Days: {(df_full['datetime'].max() - df_full['datetime'].min()).days}")

print("\n" + "="*60)
print("VERDICT")
print("="*60)

# Check compatibility with run_backtest.py
required_cols = {'datetime', 'bid', 'ask'}
actual_cols = set(df.columns)

if required_cols.issubset(actual_cols):
    print("Status: OK - Compatible with run_backtest.py")
    print(f"\nReady to use in backtest:")
    print(f'  tick_path = Path(r"{parquet_path}")')
else:
    missing = required_cols - actual_cols
    print(f"Status: INCOMPATIBLE - Missing columns: {missing}")
