"""
ORACLE v2.2 - Institutional-Grade Backtesting Validation
=========================================================

Complete validation pipeline for trading strategies:
- Walk-Forward Analysis
- Monte Carlo Block Bootstrap
- PSR/DSR/PBO Overfitting Detection
- Execution Cost Simulation
- Prop Firm Validation (FTMO)
- Unified Confidence Scoring
- Sample Data Generation

Usage:
    # Full pipeline
    python -m scripts.oracle.go_nogo_validator --input trades.csv --n-trials 100
    
    # Individual components
    python -m scripts.oracle.walk_forward --input trades.csv
    python -m scripts.oracle.monte_carlo --input trades.csv --block
    python -m scripts.oracle.deflated_sharpe --input returns.csv --trials 10
    python -m scripts.oracle.prop_firm_validator --input trades.csv --firm ftmo
    python -m scripts.oracle.execution_simulator --input trades.csv --mode pessimistic
    python -m scripts.oracle.mt5_trade_exporter --symbol XAUUSD --sample
    python -m scripts.oracle.sample_data --output sample.csv --trades 500

For: EA_SCALPER_XAUUSD Project
"""

__version__ = "2.2.1"
__author__ = "ORACLE v2.2 - Institutional-Grade Validator"

# Core modules
from scripts.oracle.walk_forward import WalkForwardAnalyzer, WFAMode, WFAResult
from scripts.oracle.monte_carlo import BlockBootstrapMC, MCResult
from scripts.oracle.deflated_sharpe import SharpeAnalyzer, SharpeAnalysisResult
from scripts.oracle.metrics import calculate_sharpe, calculate_sortino, calculate_sqn

# New v2.2 modules
from scripts.oracle.execution_simulator import (
    ExecutionSimulator, 
    ExecutionConfig, 
    MarketCondition,
    SimulationMode
)
from scripts.oracle.prop_firm_validator import (
    PropFirmValidator, 
    PropFirm, 
    PropFirmResult
)
from scripts.oracle.go_nogo_validator import (
    GoNoGoValidator, 
    ValidationCriteria, 
    ValidationResult,
    Decision
)

# Unified Confidence Scoring (v2.2.1)
from scripts.oracle.confidence import (
    UnifiedConfidenceCalculator,
    ConfidenceComponents,
    calculate_confidence_score
)

# Sample Data Generation (v2.2.1)
from scripts.oracle.sample_data import (
    generate_sample_trades,
    generate_realistic_xauusd_trades,
    generate_edge_case_trades
)

# Optional MT5 exporter
try:
    from scripts.oracle.mt5_trade_exporter import MT5TradeExporter
except ImportError:
    MT5TradeExporter = None

__all__ = [
    # Version
    '__version__',
    
    # Walk-Forward
    'WalkForwardAnalyzer',
    'WFAMode',
    'WFAResult',
    
    # Monte Carlo
    'BlockBootstrapMC',
    'MCResult',
    
    # Sharpe Analysis
    'SharpeAnalyzer',
    'SharpeAnalysisResult',
    
    # Metrics
    'calculate_sharpe',
    'calculate_sortino',
    'calculate_sqn',
    
    # Execution Simulation
    'ExecutionSimulator',
    'ExecutionConfig',
    'MarketCondition',
    'SimulationMode',
    
    # Prop Firm
    'PropFirmValidator',
    'PropFirm',
    'PropFirmResult',
    
    # GO/NO-GO Pipeline
    'GoNoGoValidator',
    'ValidationCriteria',
    'ValidationResult',
    'Decision',
    
    # Confidence Scoring (v2.2.1)
    'UnifiedConfidenceCalculator',
    'ConfidenceComponents',
    'calculate_confidence_score',
    
    # Sample Data (v2.2.1)
    'generate_sample_trades',
    'generate_realistic_xauusd_trades',
    'generate_edge_case_trades',
    
    # MT5 Export
    'MT5TradeExporter',
]
