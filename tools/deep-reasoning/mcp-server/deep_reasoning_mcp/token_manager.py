"""Token manager for CLIProxy Codex accounts with rotation."""

import json
import logging
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)

# Default CLIProxy auth directory
DEFAULT_AUTH_DIR = Path.home() / ".cli-proxy-api"


@dataclass
class CodexAccount:
    """A Codex account with access token."""

    email: str
    access_token: str
    refresh_token: str
    account_id: str
    expired: datetime
    file_path: Path
    last_used: Optional[datetime] = None
    error_count: int = 0
    cooldown_until: Optional[datetime] = None

    @property
    def is_expired(self) -> bool:
        """Check if token is expired."""
        # Handle timezone-aware vs naive comparison
        now = datetime.now()
        expired = self.expired
        # Make both naive for comparison
        if expired.tzinfo is not None:
            expired = expired.replace(tzinfo=None)
        return now >= expired

    @property
    def is_in_cooldown(self) -> bool:
        """Check if account is in cooldown (rate limited)."""
        if self.cooldown_until is None:
            return False
        return datetime.now() < self.cooldown_until

    @property
    def is_available(self) -> bool:
        """Check if account is available for use."""
        return not self.is_expired and not self.is_in_cooldown


@dataclass
class TokenManager:
    """Manages Codex tokens with rotation and cooldown handling."""

    auth_dir: Path = field(default_factory=lambda: DEFAULT_AUTH_DIR)
    accounts: list[CodexAccount] = field(default_factory=list)
    _current_index: int = 0

    def load_accounts(self) -> int:
        """Load all Codex accounts from auth directory."""
        self.accounts = []

        if not self.auth_dir.exists():
            logger.warning(f"Auth directory not found: {self.auth_dir}")
            return 0

        for json_file in self.auth_dir.glob("codex-*.json"):
            try:
                data = json.loads(json_file.read_text())

                # Parse expiry date
                expired_str = data.get("expired", "")
                try:
                    # Handle timezone offset format: 2026-01-04T09:39:11-03:00
                    expired = datetime.fromisoformat(expired_str)
                except ValueError:
                    # Fallback: assume far future if parse fails
                    expired = datetime(2099, 1, 1)

                account = CodexAccount(
                    email=data.get("email", "unknown"),
                    access_token=data["access_token"],
                    refresh_token=data.get("refresh_token", ""),
                    account_id=data.get("account_id", ""),
                    expired=expired,
                    file_path=json_file,
                )
                self.accounts.append(account)
                logger.debug(f"Loaded account: {account.email}")

            except (json.JSONDecodeError, KeyError) as e:
                logger.warning(f"Failed to load {json_file}: {e}")
                continue

        # Sort by expiry date (furthest first)
        self.accounts.sort(key=lambda a: a.expired, reverse=True)

        logger.info(f"Loaded {len(self.accounts)} Codex accounts")
        return len(self.accounts)

    def get_next_token(self) -> Optional[str]:
        """Get next available token using round-robin rotation."""
        if not self.accounts:
            self.load_accounts()

        if not self.accounts:
            logger.error("No Codex accounts available")
            return None

        # Try each account in rotation
        attempts = 0
        while attempts < len(self.accounts):
            account = self.accounts[self._current_index]
            self._current_index = (self._current_index + 1) % len(self.accounts)

            if account.is_available:
                account.last_used = datetime.now()
                logger.debug(f"Using account: {account.email}")
                return account.access_token

            attempts += 1

        logger.error("All accounts are expired or in cooldown")
        return None

    def mark_rate_limited(self, token: str, cooldown_seconds: int = 60) -> None:
        """Mark account as rate limited."""
        for account in self.accounts:
            if account.access_token == token:
                account.cooldown_until = datetime.now() + __import__(
                    "datetime"
                ).timedelta(seconds=cooldown_seconds)
                account.error_count += 1
                logger.warning(
                    f"Account {account.email} rate limited for {cooldown_seconds}s"
                )
                break

    def mark_error(self, token: str) -> None:
        """Mark account as having an error."""
        for account in self.accounts:
            if account.access_token == token:
                account.error_count += 1
                # If too many errors, put in longer cooldown
                if account.error_count >= 3:
                    account.cooldown_until = datetime.now() + __import__(
                        "datetime"
                    ).timedelta(minutes=5)
                    logger.warning(
                        f"Account {account.email} has {account.error_count} errors, cooldown 5min"
                    )
                break

    def get_stats(self) -> dict:
        """Get statistics about available accounts."""
        available = sum(1 for a in self.accounts if a.is_available)
        expired = sum(1 for a in self.accounts if a.is_expired)
        cooldown = sum(1 for a in self.accounts if a.is_in_cooldown)

        return {
            "total": len(self.accounts),
            "available": available,
            "expired": expired,
            "in_cooldown": cooldown,
            "accounts": [
                {
                    "email": a.email,
                    "available": a.is_available,
                    "expired": a.is_expired,
                    "in_cooldown": a.is_in_cooldown,
                    "error_count": a.error_count,
                }
                for a in self.accounts
            ],
        }


# Global singleton
_token_manager: Optional[TokenManager] = None


def get_token_manager() -> TokenManager:
    """Get global token manager instance."""
    global _token_manager
    if _token_manager is None:
        _token_manager = TokenManager()
        _token_manager.load_accounts()
    return _token_manager
