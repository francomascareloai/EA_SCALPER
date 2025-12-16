# Quick Start: Database Optimization

**Agent 9 - Database Optimization Specialist**
**Generated**: 2025-12-15

## Immediate Actions (30 minutes)

### 1. Apply SQLite Indexes (5 minutes)
```bash
cd /home/franco/projetos/EA_SCALPER_XAUUSD

# Apply optimizations
sqlite3 Python_Agent_Hub/data/trade_memory.db < scripts/optimize/create_trade_memory_indexes.sql

# Expected: 3-5x faster similarity lookups
```

### 2. Verify CSV Redundancy (10 minutes)
```bash
# Check if session CSVs can be safely deleted
python3 scripts/optimize/verify_csv_redundancy.py

# If verification passes:
# rm -rf data/session_csvs/  # Saves 14 GB
```

### 3. Analyze Column Pruning Opportunities (15 minutes)
```bash
# Generate report (dry run)
python3 scripts/optimize/add_column_pruning.py --dry-run --report DOCS/04_REPORTS/column_pruning.md

# Review the report and apply top 10 optimizations manually
# Full automation available via: --apply flag (use with caution)
```

## Expected Results

| Optimization | Time | Savings | Impact |
|--------------|------|---------|--------|
| SQLite Indexes | 5 min | 0 MB | 3-5x query speed |
| Delete CSVs | 10 min | 14 GB | Cleaner structure |
| Column Pruning (top 10) | 15 min | 40% memory | 2-3x load speed |
| **TOTAL** | **30 min** | **14 GB + 40% RAM** | **2-5x faster** |

## Safety Checks

Before any destructive operation:
```bash
# Backup data directory
tar -czf data_backup_$(date +%Y%m%d).tar.gz data/session_csvs/

# Verify backtest results match
python3 scripts/backtest/quick_multi_year.py > before.txt
# ... apply optimizations ...
python3 scripts/backtest/quick_multi_year.py > after.txt
diff before.txt after.txt  # Should be identical
```

## Monitoring

After optimizations, track performance:
```python
import time
start = time.time()
df = pd.read_parquet('data/ticks.parquet', columns=['timestamp', 'bid', 'ask'])
print(f"Load time: {time.time() - start:.2f}s, Memory: {df.memory_usage().sum() / 1e6:.0f} MB")
```

## Full Report

See: `DOCS/03_RESEARCH/FINDINGS/DB_OPTIMIZATION_REPORT_20251215.md`
