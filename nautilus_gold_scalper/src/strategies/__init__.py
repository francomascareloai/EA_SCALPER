"""Trading strategies for NautilusTrader."""

from .base_strategy import BaseGoldStrategy, BaseStrategyConfig
from .gold_scalper_strategy import GoldScalperStrategy, GoldScalperConfig
from .strategy_selector import (
    StrategySelector,
    StrategySelection,
    StrategyType,
    MarketContext,
    NewsImpact,
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
