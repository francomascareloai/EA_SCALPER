-- SQLite Index Optimization for trade_memory.db
-- Agent 9: Database Optimization Specialist
-- Generated: 2025-12-15
--
-- Purpose: Optimize query performance for trade memory similarity lookups
-- Expected Impact: 3-5x speedup on lookups, <10 KB storage cost
--
-- Usage:
--   sqlite3 Python_Agent_Hub/data/trade_memory.db < scripts/optimize/create_trade_memory_indexes.sql

-- ============================================================================
-- COMPOSITE INDEXES FOR COMMON QUERIES
-- ============================================================================

-- Index 1: Similarity lookup with time filtering (most common query)
-- Covers: check_situation() method in trade_memory.py
CREATE INDEX IF NOT EXISTS idx_similarity_fast
  ON trades(feature_hash, entry_time DESC, is_winner, r_multiple)
  WHERE entry_time > datetime('now', '-90 days');

-- Index 2: Regime + Session + Direction analysis
-- Covers: Performance analysis by market conditions
CREATE INDEX IF NOT EXISTS idx_regime_session
  ON trades(regime, session, direction, entry_time DESC);

-- Index 3: Signal tier filtering
-- Covers: Queries filtering by signal quality
CREATE INDEX IF NOT EXISTS idx_signal_tier
  ON trades(signal_tier, is_winner, confluence_score);

-- Index 4: Covering index for statistics queries
-- Covers: get_statistics() method
CREATE INDEX IF NOT EXISTS idx_stats_covering
  ON trades(entry_time, is_winner, r_multiple, profit_pips);

-- Index 5: Worst situations analysis
-- Covers: get_worst_situations() method
CREATE INDEX IF NOT EXISTS idx_worst_situations
  ON trades(feature_hash, is_winner, r_multiple)
  WHERE r_multiple < 0;

-- ============================================================================
-- ANALYZE AND OPTIMIZE
-- ============================================================================

-- Update query planner statistics
ANALYZE trades;

-- Reclaim unused space and rebuild indexes
VACUUM;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check index usage
SELECT
    name as index_name,
    sql as definition
FROM sqlite_master
WHERE type = 'index'
  AND tbl_name = 'trades'
ORDER BY name;

-- Estimate space usage
SELECT
    name,
    SUM(pgsize) / 1024.0 as size_kb
FROM dbstat
WHERE name = 'trades'
GROUP BY name;
