# Live Infrastructure Requirements

> **Purpose**: Required infrastructure for paper trading and live deployment

## Data Feed

| Property | Requirement |
|----------|-------------|
| **Provider** | Apex / NinjaTrader / Rithmic (any with XAUUSD tick data) |
| **Minimum Resolution** | Tick-by-tick or 1-second bars for HWM tracking |
| **Latency Target** | Receive tick within 50ms of exchange timestamp |
| **Fallback** | If primary feed drops, halt trading (do NOT use stale data) |
| **Validation** | Timestamps must be monotonically increasing; reject out-of-order ticks |

## Execution

| Property | Requirement |
|----------|-------------|
| **Broker** | Apex Trader Funding (evaluation → funded) |
| **Latency Budget** | Order submission to acknowledgment <200ms |
| **Order Types** | Market orders for emergency close; limit orders for entries |
| **Partial Fills** | Treat filled portion as open position; remainder as canceled |

### MGC Contract Specs

| Property | Value |
|----------|-------|
| **Instrument** | MGC (Micro Gold) on CME via Apex/Rithmic |
| **Tick Size** | $0.10 |
| **Point Value** | $10.00 per point ($1.00 per tick) |
| **Contract Size** | 10 troy ounces |

### Slippage Assumptions

| Condition | Expected Slippage |
|-----------|-------------------|
| Normal | $0.10-$0.30 (1-3 ticks) |
| News Events | $1.00+ (10+ ticks) |
| Emergency Close | $2.00+ (20+ ticks) - assume worst case |

## Monitoring

### Real-time Metrics
- Current DD % (tick-by-tick)
- HWM value and timestamp of last update
- Open positions count and unrealized PnL
- Time to market close (countdown)
- Daily profit % (for 30% cap tracking in live)

### Alerts (references `dd_limits.taxonomy.trailing_dd`)

| Level | Condition |
|-------|-----------|
| WARN | Trailing DD >3.0% |
| CAUTION | Trailing DD >3.5% |
| CRITICAL | Trailing DD >4.0% |
| HALT | Trailing DD >4.5% OR network disconnect >30s |

### Health Checks

| Interval | Check |
|----------|-------|
| 5s | Data feed heartbeat |
| 10s | Broker connection status |
| 60s | Position reconciliation (local vs broker) |

## Logging

| Log Type | Contents | Retention |
|----------|----------|-----------|
| Trade Log | Every entry/exit with timestamp, price, slippage, HWM at time | 90 days |
| System Log | Connection events, errors, latency spikes, health check failures | 90 days |
