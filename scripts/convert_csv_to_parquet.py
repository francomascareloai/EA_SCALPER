"""
Quick CSV to Parquet converter for tick data.
Converts 6.3GB CSV to ~1.5GB Parquet with optimized compression.
"""
import pandas as pd
from pathlib import Path
import sys

def convert_tick_csv_to_parquet(
    csv_path: str,
    output_path: str = None,
    chunksize: int = 1_000_000
):
    """
    Convert large tick CSV to Parquet with chunked reading.
    
    Args:
        csv_path: Path to input CSV
        output_path: Path to output Parquet (default: same name .parquet)
        chunksize: Rows per chunk (1M = ~40MB RAM)
    """
    csv_path = Path(csv_path)
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV not found: {csv_path}")
    
    if output_path is None:
        output_path = csv_path.with_suffix('.parquet')
    else:
        output_path = Path(output_path)
    
    print(f"Converting {csv_path.name} to Parquet...")
    print(f"Output: {output_path}")
    print(f"Chunk size: {chunksize:,} rows")
    
    # Read in chunks and write to parquet
    chunks_processed = 0
    total_rows = 0
    
    # First pass: get schema and first chunk
    first_chunk = True
    
    for chunk in pd.read_csv(
        csv_path,
        chunksize=chunksize,
        parse_dates=['DateTime'],
        dtype={'Bid': 'float32', 'Ask': 'float32', 'Volume': 'int32'}
    ):
        # Rename columns to match expected format
        chunk.columns = ['datetime', 'bid', 'ask', 'volume']
        
        # Ensure datetime is timezone-aware (UTC)
        if chunk['datetime'].dt.tz is None:
            chunk['datetime'] = pd.to_datetime(chunk['datetime'], utc=True)
        
        # Write chunk
        if first_chunk:
            # First chunk: create file
            chunk.to_parquet(
                output_path,
                engine='pyarrow',
                compression='snappy',
                index=False
            )
            first_chunk = False
        else:
            # Subsequent chunks: append
            chunk.to_parquet(
                output_path,
                engine='pyarrow',
                compression='snappy',
                index=False,
                append=True
            )
        
        chunks_processed += 1
        total_rows += len(chunk)
        
        if chunks_processed % 10 == 0:
            print(f"  Processed {chunks_processed} chunks ({total_rows:,} rows)...")
    
    print(f"✅ Conversion complete!")
    print(f"  Total rows: {total_rows:,}")
    print(f"  CSV size: {csv_path.stat().st_size / 1e9:.2f} GB")
    print(f"  Parquet size: {output_path.stat().st_size / 1e9:.2f} GB")
    print(f"  Compression ratio: {csv_path.stat().st_size / output_path.stat().st_size:.1f}x")
    
    return output_path


def main():
    """CLI entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Convert tick CSV to Parquet')
    parser.add_argument('csv_path', help='Path to input CSV file')
    parser.add_argument('--output', '-o', default=None, help='Output Parquet path (default: same name)')
    parser.add_argument('--chunksize', '-c', type=int, default=1_000_000, help='Chunk size (default: 1M)')
    
    args = parser.parse_args()
    
    try:
        output = convert_tick_csv_to_parquet(args.csv_path, args.output, args.chunksize)
        print(f"\n✅ Success! Parquet file: {output}")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
