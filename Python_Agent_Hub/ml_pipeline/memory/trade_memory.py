"""
Trade Memory System - Inspired by TradingAgents
EA_SCALPER_XAUUSD - Learning Edition

Stores past trades with features and outcomes.
Retrieves similar situations to avoid repeating mistakes.

Key differences from TradingAgents:
- Uses SQLite instead of ChromaDB (simpler, Windows-friendly)
- Feature-based similarity instead of embeddings (faster, deterministic)
- No LLM dependency (pure rule-based)
"""
import sqlite3
import json
import hashlib
from datetime import datetime, timedelta
from dataclasses import dataclass, asdict
from typing import List, Optional, Dict, Tuple, Any
from pathlib import Path
import numpy as np


@dataclass
class TradeRecord:
    """Complete record of a trade with features and outcome."""
    # Trade identification
    ticket: int
    symbol: str
    direction: str  # 'BUY' or 'SELL'
    
    # Timing
    entry_time: datetime
    exit_time: datetime
    
    # Prices
    entry_price: float
    exit_price: float
    stop_loss: float
    take_profit: float
    
    # Result
    profit_loss: float
    profit_pips: float
    r_multiple: float
    is_winner: bool
    
    # Features at entry (for similarity matching)
    features: Dict[str, float]
    
    # Context
    regime: str  # 'TRENDING', 'REVERTING', 'RANDOM'
    session: str  # 'ASIAN', 'LONDON', 'NY'
    spread_state: str  # 'NORMAL', 'ELEVATED', 'HIGH'
    news_window: bool
    confluence_score: int
    signal_tier: str  # 'A', 'B', 'C', 'D'
    
    # Reflection (added later)
    reflection: Optional[str] = None
    lessons: Optional[List[str]] = None
    
    def feature_hash(self) -> str:
        """Create hash of key features for fast similarity lookup."""
        key_features = {
            'hurst_bin': self._bin_value(self.features.get('hurst', 0.5), [0.45, 0.55]),
            'entropy_bin': self._bin_value(self.features.get('entropy', 2.0), [1.5, 2.5]),
            'rsi_bin': self._bin_value(self.features.get('rsi', 50), [30, 70]),
            'regime': self.regime,
            'session': self.session,
            'direction': self.direction,
        }
        hash_str = json.dumps(key_features, sort_keys=True)
        return hashlib.md5(hash_str.encode()).hexdigest()[:16]
    
    def _bin_value(self, value: float, thresholds: List[float]) -> str:
        """Bin a value into categories."""
        if value < thresholds[0]:
            return 'LOW'
        elif value > thresholds[1]:
            return 'HIGH'
        return 'MID'


@dataclass
class MemoryQuery:
    """Query result from memory."""
    similar_trades: List[TradeRecord]
    total_found: int
    win_rate: float
    avg_r_multiple: float
    should_avoid: bool
    avoid_reason: Optional[str]
    confidence: float  # 0-1, based on sample size


class TradeMemory:
    """
    Trade Memory System using SQLite.
    
    Features:
    - Stores all trades with full context
    - Fast similarity matching via feature hashing
    - Temporal decay (recent trades weight more)
    - Automatic cleanup of old data
    
    Usage:
        memory = TradeMemory()
        
        # Record a trade
        memory.record_trade(trade_record)
        
        # Check before new trade
        query = memory.check_situation(current_features)
        if query.should_avoid:
            print(f"Avoiding: {query.avoid_reason}")
    """
    
    def __init__(
        self,
        db_path: Optional[str] = None,
        max_records: int = 1000,
        lookback_days: int = 90,
        min_similarity_trades: int = 3,
        loss_threshold: float = 0.6  # 60% loss rate to trigger avoid
    ):
        """
        Initialize Trade Memory.
        
        Args:
            db_path: Path to SQLite database
            max_records: Maximum trades to keep
            lookback_days: Only consider trades from last N days
            min_similarity_trades: Minimum similar trades to make decision
            loss_threshold: Loss rate threshold to trigger avoid
        """
        if db_path is None:
            db_path = Path(__file__).parent.parent.parent / "data" / "trade_memory.db"
        
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        
        self.max_records = max_records
        self.lookback_days = lookback_days
        self.min_similarity_trades = min_similarity_trades
        self.loss_threshold = loss_threshold
        
        self._init_database()
    
    def _init_database(self):
        """Initialize SQLite database schema."""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS trades (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    ticket INTEGER UNIQUE,
                    symbol TEXT,
                    direction TEXT,
                    entry_time TEXT,
                    exit_time TEXT,
                    entry_price REAL,
                    exit_price REAL,
                    stop_loss REAL,
                    take_profit REAL,
                    profit_loss REAL,
                    profit_pips REAL,
                    r_multiple REAL,
                    is_winner INTEGER,
                    features TEXT,
                    feature_hash TEXT,
                    regime TEXT,
                    session TEXT,
                    spread_state TEXT,
                    news_window INTEGER,
                    confluence_score INTEGER,
                    signal_tier TEXT,
                    reflection TEXT,
                    lessons TEXT,
                    created_at TEXT DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Index for fast similarity lookup
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_feature_hash 
                ON trades(feature_hash)
            """)
            
            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_entry_time 
                ON trades(entry_time)
            """)
            
            conn.commit()
    
    def record_trade(self, trade: TradeRecord) -> int:
        """
        Record a completed trade to memory.
        
        Returns:
            ID of the inserted record
        """
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                INSERT OR REPLACE INTO trades (
                    ticket, symbol, direction, entry_time, exit_time,
                    entry_price, exit_price, stop_loss, take_profit,
                    profit_loss, profit_pips, r_multiple, is_winner,
                    features, feature_hash, regime, session, spread_state,
                    news_window, confluence_score, signal_tier,
                    reflection, lessons
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                trade.ticket,
                trade.symbol,
                trade.direction,
                trade.entry_time.isoformat(),
                trade.exit_time.isoformat(),
                trade.entry_price,
                trade.exit_price,
                trade.stop_loss,
                trade.take_profit,
                trade.profit_loss,
                trade.profit_pips,
                trade.r_multiple,
                1 if trade.is_winner else 0,
                json.dumps(trade.features),
                trade.feature_hash(),
                trade.regime,
                trade.session,
                trade.spread_state,
                1 if trade.news_window else 0,
                trade.confluence_score,
                trade.signal_tier,
                trade.reflection,
                json.dumps(trade.lessons) if trade.lessons else None
            ))
            
            conn.commit()
            
            # Cleanup old records if needed
            self._cleanup_old_records(conn)
            
            return cursor.lastrowid
    
    def check_situation(
        self,
        features: Dict[str, float],
        direction: str,
        regime: str,
        session: str
    ) -> MemoryQuery:
        """
        Check if current situation matches past losing trades.
        
        Args:
            features: Current market features
            direction: Proposed trade direction
            regime: Current regime
            session: Current session
            
        Returns:
            MemoryQuery with recommendation
        """
        # Create a temporary trade record for hash
        temp_trade = TradeRecord(
            ticket=0,
            symbol='XAUUSD',
            direction=direction,
            entry_time=datetime.now(),
            exit_time=datetime.now(),
            entry_price=0, exit_price=0, stop_loss=0, take_profit=0,
            profit_loss=0, profit_pips=0, r_multiple=0, is_winner=False,
            features=features,
            regime=regime,
            session=session,
            spread_state='NORMAL',
            news_window=False,
            confluence_score=0,
            signal_tier='C'
        )
        
        feature_hash = temp_trade.feature_hash()
        
        # Query similar trades
        cutoff_date = (datetime.now() - timedelta(days=self.lookback_days)).isoformat()
        
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            
            # Get exact hash matches
            cursor = conn.execute("""
                SELECT * FROM trades 
                WHERE feature_hash = ? 
                AND entry_time > ?
                ORDER BY entry_time DESC
                LIMIT 20
            """, (feature_hash, cutoff_date))
            
            rows = cursor.fetchall()
        
        # Convert to TradeRecord objects
        similar_trades = [self._row_to_trade(row) for row in rows]
        
        # Calculate statistics
        total_found = len(similar_trades)
        
        if total_found == 0:
            return MemoryQuery(
                similar_trades=[],
                total_found=0,
                win_rate=0.5,  # Neutral
                avg_r_multiple=0,
                should_avoid=False,
                avoid_reason=None,
                confidence=0.0
            )
        
        winners = [t for t in similar_trades if t.is_winner]
        win_rate = len(winners) / total_found
        avg_r = np.mean([t.r_multiple for t in similar_trades])
        
        # Determine if should avoid
        should_avoid = False
        avoid_reason = None
        
        if total_found >= self.min_similarity_trades:
            loss_rate = 1 - win_rate
            
            if loss_rate >= self.loss_threshold:
                should_avoid = True
                avoid_reason = f"Similar situations had {loss_rate*100:.0f}% loss rate ({total_found} trades)"
            
            # Also check average R
            if avg_r < -0.5 and total_found >= 5:
                should_avoid = True
                avoid_reason = f"Similar situations avg R: {avg_r:.2f} ({total_found} trades)"
        
        # Confidence based on sample size
        confidence = min(1.0, total_found / 10)
        
        return MemoryQuery(
            similar_trades=similar_trades,
            total_found=total_found,
            win_rate=win_rate,
            avg_r_multiple=avg_r,
            should_avoid=should_avoid,
            avoid_reason=avoid_reason,
            confidence=confidence
        )
    
    def update_reflection(self, ticket: int, reflection: str, lessons: List[str]):
        """Update a trade's reflection after analysis."""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                UPDATE trades 
                SET reflection = ?, lessons = ?
                WHERE ticket = ?
            """, (reflection, json.dumps(lessons), ticket))
            conn.commit()
    
    def get_recent_trades(self, limit: int = 50) -> List[TradeRecord]:
        """Get most recent trades."""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.execute("""
                SELECT * FROM trades 
                ORDER BY entry_time DESC 
                LIMIT ?
            """, (limit,))
            
            return [self._row_to_trade(row) for row in cursor.fetchall()]
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get overall memory statistics."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                SELECT 
                    COUNT(*) as total_trades,
                    SUM(CASE WHEN is_winner = 1 THEN 1 ELSE 0 END) as winners,
                    AVG(r_multiple) as avg_r,
                    AVG(profit_pips) as avg_pips,
                    COUNT(DISTINCT feature_hash) as unique_situations
                FROM trades
            """)
            row = cursor.fetchone()
            
            return {
                'total_trades': row[0] or 0,
                'winners': row[1] or 0,
                'win_rate': (row[1] or 0) / (row[0] or 1),
                'avg_r_multiple': row[2] or 0,
                'avg_pips': row[3] or 0,
                'unique_situations': row[4] or 0
            }
    
    def get_worst_situations(self, limit: int = 10) -> List[Dict]:
        """Get situations with worst performance (for analysis)."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                SELECT 
                    feature_hash,
                    regime,
                    session,
                    direction,
                    COUNT(*) as trade_count,
                    SUM(CASE WHEN is_winner = 1 THEN 1 ELSE 0 END) as wins,
                    AVG(r_multiple) as avg_r
                FROM trades
                GROUP BY feature_hash
                HAVING trade_count >= 3
                ORDER BY avg_r ASC
                LIMIT ?
            """, (limit,))
            
            results = []
            for row in cursor.fetchall():
                results.append({
                    'feature_hash': row[0],
                    'regime': row[1],
                    'session': row[2],
                    'direction': row[3],
                    'trade_count': row[4],
                    'wins': row[5],
                    'loss_rate': 1 - (row[5] / row[4]),
                    'avg_r': row[6]
                })
            
            return results
    
    def _row_to_trade(self, row: sqlite3.Row) -> TradeRecord:
        """Convert database row to TradeRecord."""
        return TradeRecord(
            ticket=row['ticket'],
            symbol=row['symbol'],
            direction=row['direction'],
            entry_time=datetime.fromisoformat(row['entry_time']),
            exit_time=datetime.fromisoformat(row['exit_time']),
            entry_price=row['entry_price'],
            exit_price=row['exit_price'],
            stop_loss=row['stop_loss'],
            take_profit=row['take_profit'],
            profit_loss=row['profit_loss'],
            profit_pips=row['profit_pips'],
            r_multiple=row['r_multiple'],
            is_winner=bool(row['is_winner']),
            features=json.loads(row['features']),
            regime=row['regime'],
            session=row['session'],
            spread_state=row['spread_state'],
            news_window=bool(row['news_window']),
            confluence_score=row['confluence_score'],
            signal_tier=row['signal_tier'],
            reflection=row['reflection'],
            lessons=json.loads(row['lessons']) if row['lessons'] else None
        )
    
    def _cleanup_old_records(self, conn: sqlite3.Connection):
        """Remove old records to keep database size manageable."""
        # Count current records
        cursor = conn.execute("SELECT COUNT(*) FROM trades")
        count = cursor.fetchone()[0]
        
        if count > self.max_records:
            # Delete oldest records
            to_delete = count - self.max_records
            conn.execute("""
                DELETE FROM trades 
                WHERE id IN (
                    SELECT id FROM trades 
                    ORDER BY entry_time ASC 
                    LIMIT ?
                )
            """, (to_delete,))
            conn.commit()


if __name__ == '__main__':
    # Test the memory system
    memory = TradeMemory(db_path=":memory:")  # In-memory for testing
    
    # Create sample trades
    from datetime import datetime, timedelta
    
    for i in range(10):
        trade = TradeRecord(
            ticket=1000 + i,
            symbol='XAUUSD',
            direction='BUY' if i % 2 == 0 else 'SELL',
            entry_time=datetime.now() - timedelta(days=i),
            exit_time=datetime.now() - timedelta(days=i, hours=-2),
            entry_price=2000 + i,
            exit_price=2000 + i + (10 if i % 3 != 0 else -15),
            stop_loss=2000 + i - 20,
            take_profit=2000 + i + 40,
            profit_loss=10 if i % 3 != 0 else -15,
            profit_pips=10 if i % 3 != 0 else -15,
            r_multiple=0.5 if i % 3 != 0 else -0.75,
            is_winner=i % 3 != 0,
            features={
                'hurst': 0.55 + (i * 0.01),
                'entropy': 1.5 + (i * 0.05),
                'rsi': 50 + (i * 2),
            },
            regime='TRENDING' if i % 2 == 0 else 'REVERTING',
            session='LONDON' if i < 5 else 'NY',
            spread_state='NORMAL',
            news_window=False,
            confluence_score=75 + i,
            signal_tier='B'
        )
        memory.record_trade(trade)
    
    # Test query
    query = memory.check_situation(
        features={'hurst': 0.56, 'entropy': 1.55, 'rsi': 52},
        direction='BUY',
        regime='TRENDING',
        session='LONDON'
    )
    
    print("Memory Statistics:")
    stats = memory.get_statistics()
    for k, v in stats.items():
        print(f"  {k}: {v}")
    
    print(f"\nSimilar Trades Found: {query.total_found}")
    print(f"Win Rate: {query.win_rate*100:.1f}%")
    print(f"Avg R: {query.avg_r_multiple:.2f}")
    print(f"Should Avoid: {query.should_avoid}")
    if query.avoid_reason:
        print(f"Reason: {query.avoid_reason}")
    
    print("\nWorst Situations:")
    for sit in memory.get_worst_situations(5):
        print(f"  {sit['regime']}/{sit['session']}/{sit['direction']}: {sit['loss_rate']*100:.0f}% loss, avg R: {sit['avg_r']:.2f}")
