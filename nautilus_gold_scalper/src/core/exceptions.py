"""
Custom exceptions for Nautilus Gold Scalper.
"""


class GoldScalperError(Exception):
    """Base exception for Gold Scalper."""
    pass


class InsufficientDataError(GoldScalperError):
    """Insufficient data for calculation."""
    pass


class RiskLimitExceededError(GoldScalperError):
    """Risk limit exceeded - trading not allowed."""
    pass


class DailyLimitExceededError(RiskLimitExceededError):
    """Daily loss limit exceeded."""
    pass


class TotalDrawdownExceededError(RiskLimitExceededError):
    """Total drawdown limit exceeded."""
    pass


class InvalidConfigError(GoldScalperError):
    """Invalid configuration parameter."""
    pass


class SessionBlockedError(GoldScalperError):
    """Trading session is blocked."""
    pass


class RegimeNotTradableError(GoldScalperError):
    """Market regime is not tradeable (random walk)."""
    pass


class SpreadTooHighError(GoldScalperError):
    """Spread exceeds maximum allowed."""
    pass


class InvalidSignalError(GoldScalperError):
    """Signal validation failed."""
    pass


class ExecutionError(GoldScalperError):
    """Order execution error."""
    pass


class BrokerConnectionError(GoldScalperError):
    """Broker connection error."""
    pass


class DataFeedError(GoldScalperError):
    """Data feed error."""
    pass
