#!/usr/bin/env python3
"""
convert_tick_data.py - Convert large tick CSV to optimized Parquet format.

BATCH 1 BLOCKER: This script must run before ANY other processing.

Features:
- Chunked reading (RAM < 8GB for 24GB+ files)
- Auto-detect CSV format
- Normalize to standard format
- Save as yearly Parquet files
- Create monthly chunks for backtest
- Generate conversion statistics

Usage:
    python scripts/data/convert_tick_data.py \
        --input Python_Agent_Hub/ml_pipeline/data/XAUUSD_ftmo_all_desde_2003.csv \
        --output data/processed/ \
        --chunk-size 5000000 \
        --years 2020-2025
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional, Tuple, Dict, Any, List

import numpy as np
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from tqdm import tqdm


# Standard output columns
STANDARD_COLUMNS = ['timestamp', 'bid', 'ask', 'volume', 'spread', 'mid_price', 'timestamp_unix']


def detect_format(file_path: str, sample_lines: int = 5) -> Dict[str, Any]:
    """
    Auto-detect CSV format by reading sample lines.
    
    Returns dict with:
        - has_header: bool
        - columns: list of column names or indices
        - timestamp_col: column name/index for timestamp
        - timestamp_format: strptime format string
        - bid_col, ask_col: column indices
        - has_volume: bool
    """
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = [f.readline().strip() for _ in range(sample_lines)]
    
    first_line = lines[0]
    parts = first_line.split(',')
    
    # Check if first line is header
    has_header = False
    try:
        float(parts[1])
    except (ValueError, IndexError):
        has_header = True
    
    # Detect format based on number of columns
    n_cols = len(parts)
    
    format_info = {
        'has_header': has_header,
        'n_columns': n_cols,
        'timestamp_col': 0,
        'bid_col': 1,
        'ask_col': 2,
        'has_volume': False,
        'volume_cols': [],
    }
    
    # Format 1: timestamp,bid,ask (our actual format)
    if n_cols == 3:
        format_info['format_type'] = 'simple'
    # Format 2: timestamp,bid,ask,volume
    elif n_cols == 4:
        format_info['format_type'] = 'with_volume'
        format_info['has_volume'] = True
        format_info['volume_cols'] = [3]
    # Format 3: timestamp,bid,ask,bid_volume,ask_volume
    elif n_cols == 5:
        format_info['format_type'] = 'with_bid_ask_volume'
        format_info['has_volume'] = True
        format_info['volume_cols'] = [3, 4]
    # Format 4: OHLC bars
    elif n_cols >= 6:
        format_info['format_type'] = 'ohlc_bars'
        print("WARNING: Detected OHLC bar format, not tick data!")
    
    # Detect timestamp format from data line (not header)
    sample_ts = parts[0] if not has_header else lines[1].split(',')[0]
    
    # Format: 20200102 01:00:04.735 (QuantDataManager/FTMO format)
    if sample_ts[0:8].isdigit() and ' ' in sample_ts and ':' in sample_ts:
        if '.' in sample_ts.split(' ')[1]:
            format_info['timestamp_format'] = '%Y%m%d %H:%M:%S.%f'
        else:
            format_info['timestamp_format'] = '%Y%m%d %H:%M:%S'
    # Format: 2003.05.05 03:01:03.421
    elif '.' in sample_ts and len(sample_ts) > 20:
        format_info['timestamp_format'] = '%Y.%m.%d %H:%M:%S.%f'
    # Format: 2003.05.05 03:01:03
    elif sample_ts.count('.') >= 2:
        format_info['timestamp_format'] = '%Y.%m.%d %H:%M:%S'
    # Format: 2003-05-05 03:01:03
    elif '-' in sample_ts:
        if '.' in sample_ts:
            format_info['timestamp_format'] = '%Y-%m-%d %H:%M:%S.%f'
        else:
            format_info['timestamp_format'] = '%Y-%m-%d %H:%M:%S'
    # ISO 8601: 2003-05-05T03:01:03.421
    elif 'T' in sample_ts:
        if '.' in sample_ts:
            format_info['timestamp_format'] = '%Y-%m-%dT%H:%M:%S.%f'
        else:
            format_info['timestamp_format'] = '%Y-%m-%dT%H:%M:%S'
    else:
        format_info['timestamp_format'] = None
        print(f"WARNING: Could not detect timestamp format for: {sample_ts}")
    
    return format_info


def parse_timestamp(ts_str: str, fmt: str) -> pd.Timestamp:
    """Parse timestamp string to pandas Timestamp."""
    try:
        return pd.to_datetime(ts_str, format=fmt)
    except:
        return pd.NaT


def process_chunk(
    chunk: pd.DataFrame, 
    format_info: Dict[str, Any]
) -> pd.DataFrame:
    """
    Process a chunk of raw data into standard format.
    
    Standard columns: timestamp, bid, ask, volume, spread, mid_price, timestamp_unix
    """
    df = chunk.copy()
    
    # Rename columns to standard names
    col_mapping = {
        df.columns[format_info['bid_col']]: 'bid',
        df.columns[format_info['ask_col']]: 'ask',
    }
    
    if format_info['timestamp_col'] == 0:
        col_mapping[df.columns[0]] = 'timestamp'
    
    # Handle volume column(s)
    if format_info['has_volume'] and format_info['volume_cols']:
        vol_col = format_info['volume_cols'][0]
        if vol_col < len(df.columns):
            col_mapping[df.columns[vol_col]] = 'volume'
    
    df = df.rename(columns=col_mapping)
    
    # Convert timestamp
    if format_info['timestamp_format']:
        df['timestamp'] = pd.to_datetime(
            df['timestamp'], 
            format=format_info['timestamp_format'],
            errors='coerce'
        )
    else:
        df['timestamp'] = pd.to_datetime(df['timestamp'], errors='coerce')
    
    # Convert bid/ask to float
    df['bid'] = pd.to_numeric(df['bid'], errors='coerce')
    df['ask'] = pd.to_numeric(df['ask'], errors='coerce')
    
    # Handle volume - default to 1 if not present
    if 'volume' not in df.columns:
        df['volume'] = 1
    else:
        df['volume'] = pd.to_numeric(df['volume'], errors='coerce').fillna(1).astype(np.int64)
    
    # Calculate derived columns
    df['spread'] = (df['ask'] - df['bid']) * 100  # In cents (pips for XAUUSD)
    df['mid_price'] = (df['bid'] + df['ask']) / 2
    df['timestamp_unix'] = df['timestamp'].astype(np.int64) // 10**6  # Milliseconds since epoch
    
    # Keep only standard columns
    output_cols = ['timestamp', 'bid', 'ask', 'volume', 'spread', 'mid_price', 'timestamp_unix']
    df = df[[c for c in output_cols if c in df.columns]]
    
    # Drop rows with invalid data
    df = df.dropna(subset=['timestamp', 'bid', 'ask'])
    
    # Filter out unrealistic values (XAUUSD typically 1000-3000 range)
    df = df[
        (df['bid'] > 500) & (df['bid'] < 5000) & 
        (df['ask'] > 500) & (df['ask'] < 5000) & 
        (df['spread'] >= 0) & (df['spread'] < 500)  # Max $5 spread
    ]
    
    return df


def collect_statistics(
    df: pd.DataFrame, 
    stats: Dict[str, Any]
) -> Dict[str, Any]:
    """Update running statistics with chunk data."""
    if df.empty:
        return stats
    
    # Update counts
    stats['total_ticks'] += len(df)
    stats['valid_ticks'] += len(df)
    
    # Update date range
    min_ts = df['timestamp'].min()
    max_ts = df['timestamp'].max()
    
    if pd.isna(stats['min_date']) or min_ts < stats['min_date']:
        stats['min_date'] = min_ts
    if pd.isna(stats['max_date']) or max_ts > stats['max_date']:
        stats['max_date'] = max_ts
    
    # Update spread stats
    stats['spread_sum'] += df['spread'].sum()
    stats['spread_count'] += len(df)
    stats['spread_max'] = max(stats['spread_max'], df['spread'].max())
    stats['spread_min'] = min(stats['spread_min'], df['spread'].min())
    
    # Update price stats
    if 'price_min' not in stats:
        stats['price_min'] = float('inf')
        stats['price_max'] = float('-inf')
    stats['price_min'] = min(stats['price_min'], df['mid_price'].min())
    stats['price_max'] = max(stats['price_max'], df['mid_price'].max())
    
    # Update volume stats
    if 'volume' in df.columns:
        if 'volume_sum' not in stats:
            stats['volume_sum'] = 0
        stats['volume_sum'] += df['volume'].sum()
    
    # Track by year
    df['year'] = df['timestamp'].dt.year
    for year, group in df.groupby('year'):
        if year not in stats['by_year']:
            stats['by_year'][year] = {
                'ticks': 0, 
                'spread_sum': 0, 
                'spread_count': 0,
                'volume_sum': 0,
                'price_min': float('inf'),
                'price_max': float('-inf'),
                'min_date': None,
                'max_date': None
            }
        stats['by_year'][year]['ticks'] += len(group)
        stats['by_year'][year]['spread_sum'] += group['spread'].sum()
        stats['by_year'][year]['spread_count'] += len(group)
        stats['by_year'][year]['price_min'] = min(stats['by_year'][year]['price_min'], group['mid_price'].min())
        stats['by_year'][year]['price_max'] = max(stats['by_year'][year]['price_max'], group['mid_price'].max())
        
        if 'volume' in group.columns:
            stats['by_year'][year]['volume_sum'] += group['volume'].sum()
        
        grp_min = group['timestamp'].min()
        grp_max = group['timestamp'].max()
        if stats['by_year'][year]['min_date'] is None or grp_min < stats['by_year'][year]['min_date']:
            stats['by_year'][year]['min_date'] = grp_min
        if stats['by_year'][year]['max_date'] is None or grp_max > stats['by_year'][year]['max_date']:
            stats['by_year'][year]['max_date'] = grp_max
    
    return stats


def detect_gaps(df: pd.DataFrame, threshold_hours: float = 1.0) -> List[Dict]:
    """Detect gaps larger than threshold in tick data."""
    gaps = []
    
    if len(df) < 2:
        return gaps
    
    df_sorted = df.sort_values('timestamp')
    time_diffs = df_sorted['timestamp'].diff()
    threshold = pd.Timedelta(hours=threshold_hours)
    
    gap_mask = time_diffs > threshold
    gap_indices = df_sorted.index[gap_mask]
    
    for idx in gap_indices:
        prev_idx = df_sorted.index[df_sorted.index.get_loc(idx) - 1]
        gap_start = df_sorted.loc[prev_idx, 'timestamp']
        gap_end = df_sorted.loc[idx, 'timestamp']
        gap_duration = gap_end - gap_start
        
        # Check if it's a weekend gap (Friday to Sunday/Monday)
        is_weekend = gap_start.dayofweek >= 4 and gap_end.dayofweek <= 0
        
        gaps.append({
            'start': gap_start.isoformat(),
            'end': gap_end.isoformat(),
            'duration_hours': gap_duration.total_seconds() / 3600,
            'is_weekend': is_weekend
        })
    
    return gaps


def convert_tick_data(
    input_path: str,
    output_dir: str,
    chunk_size: int = 5_000_000,
    years_filter: Optional[Tuple[int, int]] = None,
    create_monthly_chunks: bool = True
) -> Dict[str, Any]:
    """
    Main conversion function.
    
    Args:
        input_path: Path to input CSV file
        output_dir: Directory for output files
        chunk_size: Number of rows per chunk
        years_filter: Optional (start_year, end_year) tuple to filter data
        create_monthly_chunks: Whether to create monthly chunk files
    
    Returns:
        Dictionary with conversion statistics
    """
    input_path = Path(input_path)
    output_dir = Path(output_dir)
    
    # Create output directories
    output_dir.mkdir(parents=True, exist_ok=True)
    chunks_dir = output_dir / 'chunks'
    if create_monthly_chunks:
        chunks_dir.mkdir(exist_ok=True)
    
    print(f"Input: {input_path}")
    print(f"Output: {output_dir}")
    print(f"Chunk size: {chunk_size:,} rows")
    
    # Detect format
    print("\nDetecting CSV format...")
    format_info = detect_format(str(input_path))
    print(f"  Format type: {format_info['format_type']}")
    print(f"  Has header: {format_info['has_header']}")
    print(f"  Timestamp format: {format_info['timestamp_format']}")
    
    # Initialize statistics
    stats = {
        'input_file': str(input_path),
        'output_dir': str(output_dir),
        'chunk_size': chunk_size,
        'format_detected': format_info['format_type'],
        'total_ticks': 0,
        'valid_ticks': 0,
        'min_date': pd.NaT,
        'max_date': pd.NaT,
        'spread_sum': 0,
        'spread_count': 0,
        'spread_max': float('-inf'),
        'spread_min': float('inf'),
        'by_year': {},
        'gaps': [],
        'processing_time_seconds': 0
    }
    
    # Buffers for yearly/monthly aggregation
    year_buffers: Dict[int, List[pd.DataFrame]] = {}
    month_buffers: Dict[str, List[pd.DataFrame]] = {}
    
    start_time = datetime.now()
    
    # Count total lines for progress bar
    print("\nCounting lines (this may take a while for large files)...")
    total_lines = sum(1 for _ in open(input_path, 'r', encoding='utf-8', errors='ignore'))
    print(f"  Total lines: {total_lines:,}")
    
    # Process in chunks
    print("\nProcessing chunks...")
    
    # Determine column names for headerless files
    col_names = None
    if not format_info['has_header']:
        if format_info['n_columns'] == 3:
            col_names = ['timestamp', 'bid', 'ask']
        elif format_info['n_columns'] == 4:
            col_names = ['timestamp', 'bid', 'ask', 'volume']
        elif format_info['n_columns'] == 5:
            col_names = ['timestamp', 'bid', 'ask', 'bid_volume', 'ask_volume']
    
    reader = pd.read_csv(
        input_path,
        chunksize=chunk_size,
        header=0 if format_info['has_header'] else None,
        names=col_names,
        encoding='utf-8',
        on_bad_lines='skip'
    )
    
    n_chunks = (total_lines // chunk_size) + 1
    
    for chunk_idx, chunk in enumerate(tqdm(reader, total=n_chunks, desc="Processing")):
        # Process chunk
        df = process_chunk(chunk, format_info)
        
        if df.empty:
            continue
        
        # Apply year filter if specified
        if years_filter:
            df = df[
                (df['timestamp'].dt.year >= years_filter[0]) & 
                (df['timestamp'].dt.year <= years_filter[1])
            ]
        
        if df.empty:
            continue
        
        # Collect statistics
        stats = collect_statistics(df, stats)
        
        # Detect gaps (sample every 10th chunk to save time)
        if chunk_idx % 10 == 0:
            chunk_gaps = detect_gaps(df, threshold_hours=24)
            stats['gaps'].extend([g for g in chunk_gaps if not g['is_weekend']])
        
        # Buffer by year
        df['year'] = df['timestamp'].dt.year
        for year, group in df.groupby('year'):
            if year not in year_buffers:
                year_buffers[year] = []
            year_buffers[year].append(group.drop(columns=['year']))
        
        # Buffer by month if requested
        if create_monthly_chunks:
            df['year_month'] = df['timestamp'].dt.strftime('%Y%m')
            for ym, group in df.groupby('year_month'):
                if ym not in month_buffers:
                    month_buffers[ym] = []
                month_buffers[ym].append(group.drop(columns=['year', 'year_month']))
        
        # Flush buffers if they get too large (> 5M rows per year) - memory efficient
        for year, buffer in list(year_buffers.items()):
            total_rows = sum(len(b) for b in buffer)
            if total_rows > 5_000_000:
                print(f"\n  Flushing year {year} buffer ({total_rows:,} rows)...")
                year_df = pd.concat(buffer, ignore_index=True)
                year_file = output_dir / f'ticks_{year}.parquet'
                
                # Append mode - write new partition file
                partition_idx = len(list(output_dir.glob(f'ticks_{year}_*.parquet')))
                partition_file = output_dir / f'ticks_{year}_{partition_idx:04d}.parquet'
                year_df.to_parquet(partition_file, compression='snappy', index=False)
                year_buffers[year] = []
                del year_df  # Free memory
    
    # Flush remaining buffers
    print("\nWriting remaining yearly partitions...")
    for year, buffer in tqdm(year_buffers.items(), desc="Yearly files"):
        if not buffer:
            continue
        
        year_df = pd.concat(buffer, ignore_index=True)
        partition_idx = len(list(output_dir.glob(f'ticks_{year}_*.parquet')))
        partition_file = output_dir / f'ticks_{year}_{partition_idx:04d}.parquet'
        year_df.to_parquet(partition_file, compression='snappy', index=False)
        del year_df
    
    # Merge year partitions into single file (memory-efficient using pyarrow)
    print("\nMerging yearly partitions...")
    for year in tqdm(stats['by_year'].keys(), desc="Merging"):
        partition_files = sorted(output_dir.glob(f'ticks_{year}_*.parquet'))
        if not partition_files:
            continue
        
        year_file = output_dir / f'ticks_{year}.parquet'
        
        # Read and merge with pyarrow (streaming)
        tables = [pq.read_table(f) for f in partition_files]
        merged = pa.concat_tables(tables)
        pq.write_table(merged, year_file, compression='snappy')
        
        # Cleanup partition files
        for pf in partition_files:
            pf.unlink()
        
        stats['by_year'][year]['file'] = str(year_file)
        stats['by_year'][year]['file_size_mb'] = year_file.stat().st_size / (1024 * 1024)
        del tables, merged
    
    if create_monthly_chunks:
        print("\nWriting monthly chunks...")
        for ym, buffer in tqdm(month_buffers.items(), desc="Monthly chunks"):
            if not buffer:
                continue
            
            month_df = pd.concat(buffer, ignore_index=True)
            month_file = chunks_dir / f'ticks_{ym}.parquet'
            month_df.to_parquet(month_file, compression='snappy', index=False)
            del month_df
    
    # Finalize statistics
    end_time = datetime.now()
    stats['processing_time_seconds'] = (end_time - start_time).total_seconds()
    
    if stats['spread_count'] > 0:
        stats['spread_avg'] = stats['spread_sum'] / stats['spread_count']
    else:
        stats['spread_avg'] = 0
    
    # Convert timestamps to strings for JSON
    stats['min_date'] = stats['min_date'].isoformat() if pd.notna(stats['min_date']) else None
    stats['max_date'] = stats['max_date'].isoformat() if pd.notna(stats['max_date']) else None
    
    for year in stats['by_year']:
        if stats['by_year'][year]['spread_count'] > 0:
            stats['by_year'][year]['spread_avg'] = (
                stats['by_year'][year]['spread_sum'] / stats['by_year'][year]['spread_count']
            )
        if stats['by_year'][year]['min_date']:
            stats['by_year'][year]['min_date'] = stats['by_year'][year]['min_date'].isoformat()
        if stats['by_year'][year]['max_date']:
            stats['by_year'][year]['max_date'] = stats['by_year'][year]['max_date'].isoformat()
    
    # Remove internal tracking fields
    del stats['spread_sum']
    del stats['spread_count']
    for year in stats['by_year']:
        del stats['by_year'][year]['spread_sum']
        del stats['by_year'][year]['spread_count']
    
    # Filter out weekend gaps and limit to top 100
    stats['gaps'] = sorted(
        [g for g in stats['gaps'] if not g.get('is_weekend', False)],
        key=lambda x: x['duration_hours'],
        reverse=True
    )[:100]
    stats['critical_gaps_count'] = len([g for g in stats['gaps'] if g['duration_hours'] > 24])
    
    # Save statistics
    stats_file = output_dir / 'CONVERSION_STATS.json'
    with open(stats_file, 'w') as f:
        json.dump(stats, f, indent=2, default=str)
    
    print(f"\n{'='*60}")
    print("CONVERSION COMPLETE")
    print(f"{'='*60}")
    print(f"Total ticks processed: {stats['total_ticks']:,}")
    print(f"Valid ticks: {stats['valid_ticks']:,}")
    print(f"Date range: {stats['min_date']} to {stats['max_date']}")
    print(f"Average spread: {stats['spread_avg']:.2f} cents")
    print(f"Critical gaps (>24h non-weekend): {stats['critical_gaps_count']}")
    print(f"Processing time: {stats['processing_time_seconds']:.1f} seconds")
    print(f"\nOutput files saved to: {output_dir}")
    print(f"Statistics saved to: {stats_file}")
    
    return stats


def main():
    parser = argparse.ArgumentParser(
        description='Convert tick data CSV to optimized Parquet format'
    )
    parser.add_argument(
        '--input', '-i',
        required=True,
        help='Path to input CSV file'
    )
    parser.add_argument(
        '--output', '-o',
        default='data/processed/',
        help='Output directory for Parquet files'
    )
    parser.add_argument(
        '--chunk-size', '-c',
        type=int,
        default=5_000_000,
        help='Number of rows per processing chunk (default: 5M)'
    )
    parser.add_argument(
        '--years', '-y',
        help='Year range filter, e.g., "2020-2025"'
    )
    parser.add_argument(
        '--no-monthly',
        action='store_true',
        help='Skip creating monthly chunk files'
    )
    
    args = parser.parse_args()
    
    # Parse years filter
    years_filter = None
    if args.years:
        try:
            start, end = args.years.split('-')
            years_filter = (int(start), int(end))
        except:
            print(f"Invalid years format: {args.years}. Use 'YYYY-YYYY'")
            sys.exit(1)
    
    # Run conversion
    stats = convert_tick_data(
        input_path=args.input,
        output_dir=args.output,
        chunk_size=args.chunk_size,
        years_filter=years_filter,
        create_monthly_chunks=not args.no_monthly
    )
    
    return 0 if stats['valid_ticks'] > 0 else 1


if __name__ == '__main__':
    sys.exit(main())
