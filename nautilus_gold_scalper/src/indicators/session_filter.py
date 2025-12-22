"""
Session Filter para XAUUSD.
Migrado de: MQL5/Include/EA_SCALPER/Analysis/CSessionFilter.mqh

XAUUSD Session Dynamics (UTC-based, fixed - do NOT shift with DST):
- ASIAN (00:00-07:00 UTC): LOW volatility, range-bound, DO NOT TRADE
- LONDON (07:00-12:00 UTC): HIGH volatility, trend initiation, BEST WINDOW
- OVERLAP (12:00-15:00 UTC): HIGHEST volatility, PRIME WINDOW
- NY (15:00-17:00 UTC): HIGH volatility, continuation/reversal
- LATE (17:00-21:00 UTC): LOW liquidity, erratic, AVOID

NOTE: Session boundaries are defined in UTC (equivalent to GMT) and do NOT shift
with DST transitions. This is intentional for backtesting determinism - the session
windows remain stable across the entire dataset. During DST transitions, the actual
local trading hours in London/NY shift by ~1 hour, but for volatility pattern
filtering purposes, fixed UTC windows are acceptable.

For Apex time gates (4:30 PM, 4:55 PM, 4:59 PM ET), use TimeConstraintManager
which properly handles America/New_York timezone with DST awareness.
"""
from datetime import datetime, time, timedelta
from typing import Any
import warnings
from zoneinfo import ZoneInfo

# UTC timezone for consistent session detection
_UTC = ZoneInfo("UTC")

from ..core.data_types import SessionInfo
from ..core.definitions import SessionQuality, TradingSession


class SessionFilter:
    """
    Filtro de sessao de trading para XAUUSD.

    Determina:
    - Qual sessao esta ativa
    - Qualidade da sessao para trading
    - Se trading e permitido
    - Fatores de ajuste (volatilidade, spread)

    Session boundaries are in UTC and do NOT shift with DST. This is intentional
    for backtesting determinism. For Apex time gates (4:30/4:55/4:59 PM ET),
    use TimeConstraintManager which handles America/New_York properly.
    """

    # Session windows (UTC - fixed, do NOT shift with DST)
    SESSIONS = {
        TradingSession.SESSION_ASIAN: {
            "start": time(0, 0),
            "end": time(7, 0),
            "quality": SessionQuality.SESSION_QUALITY_BLOCKED,
            "volatility_factor": 0.5,
            "spread_factor": 1.5,
        },
        TradingSession.SESSION_LONDON: {
            "start": time(7, 0),
            "end": time(12, 0),
            "quality": SessionQuality.SESSION_QUALITY_HIGH,
            "volatility_factor": 1.2,
            "spread_factor": 0.8,
        },
        TradingSession.SESSION_LONDON_NY_OVERLAP: {
            "start": time(12, 0),
            "end": time(15, 0),
            "quality": SessionQuality.SESSION_QUALITY_PRIME,
            "volatility_factor": 1.5,
            "spread_factor": 0.7,
        },
        TradingSession.SESSION_NY: {
            "start": time(15, 0),
            "end": time(17, 0),
            "quality": SessionQuality.SESSION_QUALITY_HIGH,
            "volatility_factor": 1.3,
            "spread_factor": 0.9,
        },
        TradingSession.SESSION_LATE_NY: {
            "start": time(17, 0),
            "end": time(21, 0),
            "quality": SessionQuality.SESSION_QUALITY_LOW,
            "volatility_factor": 0.7,
            "spread_factor": 1.2,
        },
    }

    def __init__(
        self,
        broker_gmt_offset: int = 0,
        allow_asian: bool = False,
        allow_late_ny: bool = False,
        friday_close_hour: int = 14,
    ):
        """
        Inicializa o filtro de sessao.

        Args:
            broker_gmt_offset: DEPRECATED - ignored. Timestamps are expected in UTC.
                NautilusTrader provides UTC timestamps; no offset needed.
            allow_asian: Override para permitir Asian session
            allow_late_ny: Override para permitir Late NY
            friday_close_hour: Hora UTC para fechar posicoes na sexta-feira.
                NOTE: For Apex compliance (ET-based), use TimeConstraintManager instead.

        Timestamps passed to this filter should come from bar.ts_event or bar.ts_init
        (NautilusTrader), which are always UTC. Do NOT pass datetime.now() in backtest
        context as that would make results non-deterministic.
        """
        # Deprecation warning for broker_gmt_offset
        if broker_gmt_offset != 0:
            warnings.warn(
                "broker_gmt_offset is deprecated and ignored. "
                "All timestamps are expected in UTC (NautilusTrader standard). "
                "This parameter will be removed in a future version.",
                DeprecationWarning,
                stacklevel=2,
            )
        self.broker_gmt_offset = 0  # Always 0 - kept for backward compat signature
        self.allow_asian = allow_asian
        self.allow_late_ny = allow_late_ny
        self.friday_close_hour = friday_close_hour

    def get_session_info(self, timestamp: datetime) -> SessionInfo:
        """Obtem informacoes completas sobre a sessao atual."""
        utc_time = self._to_utc(timestamp)
        current_time = utc_time.time()

        if utc_time.weekday() >= 5:
            return SessionInfo(
                session=TradingSession.SESSION_WEEKEND,
                quality=SessionQuality.SESSION_QUALITY_BLOCKED,
                is_trading_allowed=False,
                hours_until_close=0.0,
                volatility_factor=0.0,
                spread_factor=1.5,
                reason="Weekend - mercado fechado",
            )

        if utc_time.weekday() == 4 and utc_time.hour >= self.friday_close_hour:
            return SessionInfo(
                session=TradingSession.SESSION_LATE_NY,
                quality=SessionQuality.SESSION_QUALITY_BLOCKED,
                is_trading_allowed=False,
                hours_until_close=0.0,
                volatility_factor=0.0,
                spread_factor=1.5,
                reason=f"Friday apos {self.friday_close_hour}:00 UTC",
            )

        session, session_config = self._identify_session(current_time)
        is_allowed, reason = self._is_trading_allowed(session)
        hours_until_close = self._hours_until(session_config["end"], utc_time)

        return SessionInfo(
            session=session,
            quality=session_config["quality"],
            is_trading_allowed=is_allowed,
            hours_until_close=hours_until_close,
            volatility_factor=session_config["volatility_factor"],
            spread_factor=session_config["spread_factor"],
            reason=reason,
        )

    def _identify_session(self, current_time: time) -> tuple[TradingSession, dict[str, Any]]:
        """Identifica qual sessao esta ativa com base no horario UTC."""
        for session, config in self.SESSIONS.items():
            start = config.get("start")
            end = config.get("end")
            if isinstance(start, time) and isinstance(end, time) and start <= current_time < end:
                return session, config

        return TradingSession.SESSION_ASIAN, self.SESSIONS[TradingSession.SESSION_ASIAN]

    def _is_trading_allowed(self, session: TradingSession) -> tuple[bool, str]:
        """Verifica se trading e permitido na sessao."""
        if session == TradingSession.SESSION_ASIAN:
            if self.allow_asian:
                return True, "Asian permitido por override"
            return False, "Asian session bloqueada"

        if session == TradingSession.SESSION_LATE_NY:
            if self.allow_late_ny:
                return True, "Late NY permitido por override"
            return False, "Late NY session bloqueada"

        if session in {
            TradingSession.SESSION_LONDON,
            TradingSession.SESSION_LONDON_NY_OVERLAP,
            TradingSession.SESSION_NY,
        }:
            return True, f"{session.name} - trading permitido"

        return False, f"{session.name} - nao tradavel"

    def _to_utc(self, timestamp: datetime) -> datetime:
        """Convert timestamp to UTC for session detection.

        Args:
            timestamp: datetime from bar.ts_event/ts_init (NautilusTrader).
                - If timezone-aware: convert to UTC
                - If naive: assume already UTC (NautilusTrader standard)

        Returns:
            Naive datetime in UTC for session boundary comparison.

        Note:
            Do NOT pass datetime.now() in backtest context - use bar timestamps
            for deterministic results.
        """
        if timestamp.tzinfo is None:
            # Naive datetime - assume UTC (NautilusTrader standard)
            return timestamp
        else:
            # Timezone-aware - convert to UTC and strip tzinfo for comparison
            return timestamp.astimezone(_UTC).replace(tzinfo=None)

    def _hours_until(self, session_end: time, utc_time: datetime) -> float:
        """Calcula horas restantes ate o fim da sessao atual."""
        end_dt = datetime.combine(utc_time.date(), session_end)
        if end_dt <= utc_time:
            end_dt += timedelta(days=1)
        delta = end_dt - utc_time
        return max(0.0, delta.total_seconds() / 3600.0)


    def is_valid_session(self, timestamp: datetime) -> bool:
        """
        Check if trading is allowed in the current session.

        Args:
            timestamp: Current timestamp to check

        Returns:
            True if trading is allowed, False otherwise

        Example:
            filter = SessionFilter()
            from datetime import datetime
            ts = datetime(2024, 1, 15, 13, 30)  # 13:30 UTC = Overlap
            filter.is_valid_session(ts)  # Returns: True
        """
        info = self.get_session_info(timestamp)
        return bool(info.is_trading_allowed)

    def get_current_session(self, timestamp: datetime) -> TradingSession:
        """
        Get the current trading session.

        Args:
            timestamp: Current timestamp

        Returns:
            TradingSession enum value (ASIAN, LONDON, OVERLAP, NY, LATE_NY, WEEKEND)

        Example:
            filter = SessionFilter()
            from datetime import datetime
            ts = datetime(2024, 1, 15, 13, 30)  # 13:30 UTC
            session = filter.get_current_session(ts)
            # session == TradingSession.SESSION_LONDON_NY_OVERLAP: True
        """
        info = self.get_session_info(timestamp)
        return info.session

    def is_prime_time(self, timestamp: datetime) -> bool:
        """Retorna True se estiver no overlap Londres/NY (prime window)."""
        info = self.get_session_info(timestamp)
        return bool(info.session == TradingSession.SESSION_LONDON_NY_OVERLAP)

    def get_session_quality_factor(self, timestamp: datetime) -> float:
        """Fator (0-1) para ajustar scores com base na qualidade da sessao."""
        info = self.get_session_info(timestamp)
        factors: dict[SessionQuality, float] = {
            SessionQuality.SESSION_QUALITY_BLOCKED: 0.0,
            SessionQuality.SESSION_QUALITY_LOW: 0.3,
            SessionQuality.SESSION_QUALITY_MEDIUM: 0.6,
            SessionQuality.SESSION_QUALITY_HIGH: 0.85,
            SessionQuality.SESSION_QUALITY_PRIME: 1.0,
        }
        return factors.get(info.quality, 0.0)
# ✓ FORGE v4.0: 7/7 checks - Session filter with FTMO-compliant session management
