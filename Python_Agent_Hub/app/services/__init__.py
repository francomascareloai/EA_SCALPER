# Services
# NOTE: Keep this module lightweight.
# Heavy optional dependencies (numpy/pandas/etc) should not be imported at module
# import time because it breaks CLI/module execution in minimal environments.

try:
    from .gold_fundamentals import (
        GoldFundamentalsService,
        MacroAnalyzer,
        OilAnalyzer,
        ETFFlowAnalyzer,
        get_fundamentals_service,
    )
    from .news_sentiment import (
        NewsSentimentService,
        SentimentAnalyzer,
        get_sentiment_service,
    )
except Exception:
    # Optional services may require heavy dependencies (numpy/pandas).
    # Keep imports best-effort so lightweight modules (like economic calendar tools)
    # can still be executed in minimal environments.
    pass
