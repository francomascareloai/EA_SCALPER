# Phase Validators for XAUUSD Data Validation Pipeline
# Each phase uses DuckDB for high-performance Parquet queries

"""
Phase Validators:
- Phase1AValidator: Deep Data Validation (CSV → Parquet quality)
- Phase2Validator: Main Catalog Validation (schema, temporal, price, gaps, regime)
- Phase3Validator: Session Catalog Validation (6 sessions, DST handling)
- Phase4Validator: Integrity & Cleanup (cross-catalog consistency)
- Phase5Validator: Advanced Validation (GJR-GARCH, stylized facts, look-ahead)

All validators use DuckDB for 10-50x faster Parquet queries vs NautilusTrader.
NautilusTrader ParquetDataCatalog is only used for Phases 6-7 (actual backtesting).
"""

from nautilus_gold_scalper.src.validation.phases.phase_1a import Phase1AValidator
from nautilus_gold_scalper.src.validation.phases.phase_2 import Phase2Validator
from nautilus_gold_scalper.src.validation.phases.phase_3_4 import (
    SESSION_NAMES,
    SESSIONS,
    Phase3Validator,
    Phase4Validator,
)
from nautilus_gold_scalper.src.validation.phases.phase_5 import Phase5Validator

__all__ = [
    "Phase1AValidator",
    "Phase2Validator",
    "Phase3Validator",
    "Phase4Validator",
    "Phase5Validator",
    "SESSIONS",
    "SESSION_NAMES",
]
