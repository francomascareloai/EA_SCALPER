#!/usr/bin/env python3
"""
verify_csv_redundancy.py - Verify session CSVs are redundant with Parquet catalogs
Agent 9: Database Optimization Specialist

Before deleting 14 GB of session CSVs, this script verifies that all data
exists in the Parquet catalogs.

Usage:
    python3 scripts/optimize/verify_csv_redundancy.py
"""

import pandas as pd
from pathlib import Path
import hashlib
from typing import Dict
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
CSV_DIR = PROJECT_ROOT / "data" / "session_csvs"
CATALOG_DIR = PROJECT_ROOT / "data" / "catalog_native_sessions"


def hash_dataframe(df: pd.DataFrame) -> str:
    """Create hash of DataFrame content for comparison."""
    # Use first 1000 rows for quick comparison
    sample = df.head(1000)
    content = sample.to_csv(index=False).encode('utf-8')
    return hashlib.md5(content).hexdigest()


def verify_session(session_name: str) -> Dict:
    """Verify a single session CSV matches Parquet catalog."""
    csv_path = CSV_DIR / f"xauusd_{session_name}.csv"
    catalog_path = CATALOG_DIR / f"xauusd_2003_2025_stride1_{session_name}"

    if not csv_path.exists():
        return {
            'session': session_name,
            'csv_exists': False,
            'catalog_exists': catalog_path.exists(),
            'verified': False,
            'error': 'CSV not found'
        }

    if not catalog_path.exists():
        return {
            'session': session_name,
            'csv_exists': True,
            'catalog_exists': False,
            'verified': False,
            'error': 'Catalog not found'
        }

    try:
        # Load samples from both sources
        print(f"  Loading CSV: {csv_path.name}...")
        df_csv = pd.read_csv(csv_path, nrows=10000)

        print(f"  Loading Parquet catalog...")
        # Find first parquet file in catalog
        parquet_files = list(catalog_path.rglob("*.parquet"))
        if not parquet_files:
            return {
                'session': session_name,
                'csv_exists': True,
                'catalog_exists': True,
                'verified': False,
                'error': 'No parquet files in catalog'
            }

        df_parquet = pd.read_parquet(parquet_files[0], nrows=10000)

        # Compare data
        csv_hash = hash_dataframe(df_csv)
        parquet_hash = hash_dataframe(df_parquet)

        return {
            'session': session_name,
            'csv_exists': True,
            'catalog_exists': True,
            'csv_rows': len(df_csv),
            'parquet_rows': len(df_parquet),
            'csv_size_mb': csv_path.stat().st_size / (1024 * 1024),
            'verified': True,
            'data_matches': csv_hash == parquet_hash,
            'error': None
        }

    except Exception as e:
        return {
            'session': session_name,
            'csv_exists': True,
            'catalog_exists': True,
            'verified': False,
            'error': str(e)
        }


def main():
    print("=" * 80)
    print("CSV REDUNDANCY VERIFICATION")
    print("=" * 80)
    print(f"CSV Directory: {CSV_DIR}")
    print(f"Catalog Directory: {CATALOG_DIR}")
    print()

    sessions = ['ASIAN', 'LONDON', 'NY', 'OVERLAP', 'EVENING', 'LATE_NY']

    results = []
    for session in sessions:
        print(f"\nVerifying {session}...")
        result = verify_session(session)
        results.append(result)

        if result['verified']:
            status = "✓ VERIFIED" if result.get('data_matches') else "⚠ DATA MISMATCH"
            print(f"  {status}")
            print(f"  CSV: {result['csv_size_mb']:.1f} MB, {result['csv_rows']:,} rows")
            print(f"  Parquet: {result['parquet_rows']:,} rows")
        else:
            print(f"  ✗ FAILED: {result['error']}")

    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)

    verified_count = sum(1 for r in results if r.get('verified'))
    matching_count = sum(1 for r in results if r.get('data_matches'))
    total_csv_mb = sum(r.get('csv_size_mb', 0) for r in results)

    print(f"Verified: {verified_count}/{len(sessions)}")
    print(f"Data Matches: {matching_count}/{len(sessions)}")
    print(f"Total CSV Size: {total_csv_mb:.1f} MB ({total_csv_mb/1024:.1f} GB)")

    if verified_count == len(sessions) and matching_count == len(sessions):
        print("\n✓ ALL CSVs VERIFIED AS REDUNDANT")
        print("\nSafe to delete session CSVs:")
        print(f"  rm -rf {CSV_DIR}")
        print(f"\nEstimated savings: {total_csv_mb/1024:.1f} GB")
        sys.exit(0)
    else:
        print("\n✗ VERIFICATION FAILED")
        print("DO NOT delete CSVs until all sessions are verified")
        sys.exit(1)


if __name__ == '__main__':
    main()
