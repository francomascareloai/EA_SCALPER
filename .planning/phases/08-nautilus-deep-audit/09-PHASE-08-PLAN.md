# PLAN: Phase 08 - Integration Points Audit

## Objective
Verify that all modules integrate correctly, data flows properly between components, and there are no state synchronization issues.

## Integration Points to Verify

### Strategy ↔ Risk Integration

```
GoldScalperStrategy
    ↓ calls
PropFirmManager
    ↓ uses
├── DrawdownTracker
├── CircuitBreaker
├── TimeConstraintManager
├── ConsistencyTracker
└── PositionSizer
```

**Questions:**
- Are all risk checks called before trade entry?
- Is priority correct (DD > Time > Consistency)?
- Are risk modules updated on every position change?
- Is state synchronized after position close?

### Indicator ↔ Strategy Integration

```
GoldScalperStrategy
    ↓ subscribes to bars
    ↓ on_bar triggers
├── RegimeDetector.update()
├── SessionFilter.check()
├── StructureAnalyzer.analyze()
├── OrderBlockDetector.detect()
├── FVGDetector.detect()
├── LiquiditySweepDetector.detect()
├── AMDCycleTracker.track()
├── FootprintAnalyzer.analyze()
└── MTFManager.align()
```

**Questions:**
- Is update order correct (regime before structure)?
- Are all indicators updated before signal generation?
- Is bar data passed correctly?
- Are warmup periods respected?

### Signal ↔ Execution Integration

```
ConfluenceScorer.score()
    ↓ returns score
GoldScalperStrategy.evaluate()
    ↓ if score >= threshold
ExecutionModel.calculate_costs()
    ↓ adjusted entry/SL/TP
TradeManager.submit_order()
```

**Questions:**
- Is score threshold applied correctly?
- Are execution costs factored into R:R?
- Is position size from PositionSizer?
- Is spread check done before submission?

### Time Synchronization

**All modules must agree on:**
- Current timestamp (ET timezone)
- Current trading session
- Current day (for resets)
- DST status

**Questions:**
- Is timezone handling consistent?
- Are daily resets synchronized?
- Is there a single time source?

## Execution Plan

### Agent Assignment

**Agent A (NAUTILUS):** Strategy-Risk Integration
- Map data flow from strategy to risk modules
- Verify call order and frequency
- Check state synchronization
- ~Focus on PropFirmManager orchestration

**Agent B (NAUTILUS):** Indicator-Strategy Integration
- Map indicator update flow
- Verify temporal ordering
- Check data consistency
- ~Focus on MTF alignment

## Integration Diagrams to Create

### 1. Data Flow Diagram
```
Bars → Indicators → Signals → Strategy → Risk → Execution
```

### 2. State Diagram
```
IDLE → READY → SIGNAL → RISK_CHECK → EXECUTE → POSITION → EXIT
```

### 3. Event Flow Diagram
```
on_bar → update_indicators → check_signals → risk_gate → submit_order → on_fill → update_state
```

## CRITIC Checklist

### Strategy-Risk Integration
| Check | Status |
|-------|--------|
| All risk checks before entry | ⬜ |
| DD check uses current HWM | ⬜ |
| Time check uses current ET | ⬜ |
| Circuit breaker consulted | ⬜ |
| Position size from sizer | ⬜ |
| State updated on fill | ⬜ |
| State updated on close | ⬜ |

### Indicator-Strategy Integration
| Check | Status |
|-------|--------|
| All indicators updated in on_bar | ⬜ |
| Update order documented | ⬜ |
| Warmup period enforced | ⬜ |
| No stale data used | ⬜ |
| MTF bars aligned | ⬜ |

### Signal-Execution Integration
| Check | Status |
|-------|--------|
| Score threshold applied | ⬜ |
| Execution costs factored | ⬜ |
| Spread checked | ⬜ |
| Order submitted correctly | ⬜ |
| SL/TP attached | ⬜ |

### Time Synchronization
| Check | Status |
|-------|--------|
| Single time source | ⬜ |
| ET timezone used | ⬜ |
| DST handled | ⬜ |
| Daily reset synchronized | ⬜ |

## Specific Integration Questions

1. **PropFirmManager**: Does it orchestrate or just report?
2. **MTFManager**: How does it handle HTF bar not yet closed?
3. **CircuitBreaker**: Is it consulted on every trade or just on losses?
4. **DrawdownTracker**: Is it updated on every tick or bar?
5. **TimeConstraintManager**: Who calls it and when?
6. **PositionSizer**: Does it get latest equity or cached?
7. **SpreadMonitor**: Is it consulted before entry?
8. **ExecutionModel**: Is it integrated with Nautilus or bypasses?

## Failure Mode Analysis

| Integration Point | Failure Mode | Impact |
|------------------|--------------|--------|
| Risk not checked | Trade entered in HALT state | Account loss |
| DD not updated | DD exceeded undetected | Account terminated |
| Time gate missed | Overnight position | Apex violation |
| Stale indicator | Wrong signal | Bad trades |
| Wrong timezone | Time gate fails | Apex violation |
| State desync | Phantom positions | Undefined behavior |

## Success Criteria
- [ ] All integration points mapped
- [ ] Data flow diagrams created
- [ ] State synchronization verified
- [ ] Time handling confirmed correct
- [ ] No orphan state detected
- [ ] `PHASE_08_FINDINGS.md` completed

## Agents

**2 parallel NAUTILUS agents (model: opus)**
- Each handles specific integration paths
- Must apply CRITIC self-review internally
- Focus on state consistency

## Output
`PHASE_08_FINDINGS.md` in this directory
