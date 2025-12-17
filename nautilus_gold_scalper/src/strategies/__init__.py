"""Trading strategies for NautilusTrader."""

from .base_strategy import BaseGoldStrategy, BaseStrategyConfig
from .gold_scalper_strategy import GoldScalperConfig, GoldScalperStrategy
from .strategy_selector import (
    MarketContext,
    NewsImpact,
    StrategySelection,
    StrategySelector,
    StrategyType,
)

__all__ = [
    'BaseGoldStrategy',
    'BaseStrategyConfig',
    'GoldScalperStrategy',
    'GoldScalperConfig',
    'StrategySelector',
    'StrategySelection',
    'StrategyType',
    'MarketContext',
    'NewsImpact',
]
