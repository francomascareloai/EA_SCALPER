"""
Apex Optimizer - Unified optimization pipeline for Apex-compliant trading strategies.

Three-layer architecture:
1. SEARCH: Grid/Random/Bayesian parameter exploration
2. VALIDATE: Inline WFA + Apex compliance checking
3. STRESS: Monte Carlo + overfitting detection (top N only)
"""

from src.optimization.config import OptimizationConfig
from src.optimization.optimizer import ApexOptimizer

__all__ = ["ApexOptimizer", "OptimizationConfig"]
