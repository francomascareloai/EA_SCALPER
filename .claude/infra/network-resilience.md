# Network Resilience

> **Purpose**: Ensure robust handling of network failures and degraded conditions

## Connection Management

| Property | Value |
|----------|-------|
| **Reconnect Strategy** | Exponential backoff: 1s → 2s → 4s → 8s → 16s → cap at 30s |
| **Max Attempts** | 10 attempts before declaring connection dead |
| **Circuit Breaker** | After 3 consecutive failures in 5 minutes: halt trading for 15 minutes |

## Data Integrity

| Property | Requirement |
|----------|-------------|
| **Sequence Validation** | Reject out-of-order messages; request gap fill if sequence breaks |
| **Stale Threshold** | Data older than 5 seconds is STALE; do not use for decisions |
| **Heartbeat** | Expect every 5 seconds; trigger reconnect if missed 3x |

## Graceful Degradation

| Level | Condition | Action |
|-------|-----------|--------|
| 1 | Latency spike >500ms | Log warning; continue with caution |
| 2 | Latency spike >2s | Halt new entries; monitor existing positions |
| 3 | Connection lost | Execute NETWORK_DISCONNECT playbook |

## Testing Requirements

Before go-live, verify:
- [ ] Simulate network disconnect during paper trading
- [ ] Emergency close works with broker connection restored mid-close
- [ ] Reconnection logic with various failure durations

## Async Implementation (CRITICAL)

**Problem**: Blocking handlers freeze HWM/DD updates, creating stale risk view

### Rules
1. ALL reconnection logic MUST run in separate async task/thread
2. Event handlers (on_tick, on_bar, on_order) MUST remain non-blocking
3. Use `asyncio.create_task()` or threading for reconnection backoff loops
4. Never `sleep()` or `wait()` inside Nautilus Actor event handlers

### Nautilus Pattern

```python
# CORRECT: Schedule reconnection via timer/async
self.clock.set_timer("reconnect", timedelta(seconds=backoff))
# OR
asyncio.create_task(self._reconnect_loop())

# WRONG: Blocking inside event handler
time.sleep(backoff)  # NEVER DO THIS
await asyncio.sleep(backoff)  # NEVER inside on_data/on_event
```
