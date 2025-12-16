# PLAN: Phase 08 - Integration Points Audit

> **Changelog**: 2025-12-16 - Applied CRITIC review fixes: Added agents C/D for all 4 integration areas (C-001), added 30% consistency rule (C-002), specified unrealized P/L in HWM (C-003), added all 3 time gates (C-004), added response enforcement verification (C-005), added edge cases section (C-006), added synthesis step (C-007), expanded failure modes (C-008), added initialization/crash recovery checks (C-009/C-010), clarified success criteria (C-011).

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
- **Does risk check False enforce trade rejection (not just log)?**

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
- **How are order rejections handled?**
- **How are partial fills handled?**

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
- **Are all 3 Apex time gates implemented (4:30, 4:55, 4:59 PM ET)?**

## Execution Plan

### Agent Assignment

**Agent A (NAUTILUS):** Strategy-Risk Integration
- Map data flow from strategy to risk modules
- Verify call order and frequency
- Check state synchronization
- Focus on PropFirmManager orchestration
- **Verify risk check False enforces trade rejection**
- **Verify 30% consistency rule enforcement**
- **Verify HWM includes unrealized P/L**

**Agent B (NAUTILUS):** Indicator-Strategy Integration
- Map indicator update flow
- Verify temporal ordering
- Check data consistency
- Focus on MTF alignment
- **Verify initialization sequence**

**Agent C (NAUTILUS):** Signal-Execution Integration
- Verify spread check before entry
- Verify execution costs factored into R:R
- Verify order submission to Nautilus
- **Verify fill handling (complete, partial, rejected)**
- **Verify SL/TP attachment**
- **Verify position size source**

**Agent D (NAUTILUS):** Time Synchronization
- Verify timezone consistency across all modules
- Verify DST handling (Nov/Mar transitions)
- **Verify 4:30 PM ET blocks new trades**
- **Verify 4:55 PM ET force close starts**
- **Verify 4:59 PM ET final deadline enforced**
- Verify daily reset logic synchronized
- Verify single time source

### Synthesis Step
**Orchestrator:** After all agents complete, orchestrator merges findings into `PHASE_08_FINDINGS.md`:
- Consolidate issues by severity
- Cross-reference integration gaps
- Identify systemic patterns
- Compile final checklist status

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
| DD check uses HWM including unrealized P/L | ⬜ |
| Time check uses current ET | ⬜ |
| Circuit breaker consulted | ⬜ |
| Position size from sizer | ⬜ |
| State updated on fill | ⬜ |
| State updated on close | ⬜ |
| **30% max profit per day enforced** | ⬜ |
| **Risk check False enforces trade rejection** | ⬜ |
| **4:30 PM ET block new trades verified** | ⬜ |
| **4:55 PM ET force close start verified** | ⬜ |
| **4:59 PM ET final deadline verified** | ⬜ |

### Indicator-Strategy Integration
| Check | Status |
|-------|--------|
| All indicators updated in on_bar | ⬜ |
| Update order documented | ⬜ |
| Warmup period enforced | ⬜ |
| No stale data used | ⬜ |
| MTF bars aligned | ⬜ |
| **Initialization sequence verified** | ⬜ |

### Signal-Execution Integration
| Check | Status |
|-------|--------|
| Score threshold applied | ⬜ |
| Execution costs factored | ⬜ |
| Spread checked | ⬜ |
| Order submitted correctly | ⬜ |
| SL/TP attached | ⬜ |
| **Order rejection handled** | ⬜ |
| **Partial fill handled** | ⬜ |

### Time Synchronization
| Check | Status |
|-------|--------|
| Single time source | ⬜ |
| ET timezone used | ⬜ |
| DST handled | ⬜ |
| Daily reset synchronized | ⬜ |
| **4:30 PM ET gate verified** | ⬜ |
| **4:55 PM ET gate verified** | ⬜ |
| **4:59 PM ET gate verified** | ⬜ |

### Edge Cases
| Check | Status |
|-------|--------|
| Partial fill handling documented | ⬜ |
| Order rejection recovery documented | ⬜ |
| Connection loss behavior documented | ⬜ |
| Gap event handling documented | ⬜ |
| Crash recovery mechanism exists | ⬜ |
| Module initialization failure handled | ⬜ |

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
| **Order rejected** | Trade not entered, strategy thinks it entered | Undefined behavior |
| **Partial fill** | Position size incorrect, SL/TP wrong | Account loss |
| **Gap event** | SL slipped, DD exceeded | Account terminated |
| **Unrealized P/L not in HWM** | Floor calculated wrong | Account terminated |
| **30% consistency breached** | Single day > 30% profit | Apex violation |
| **Connection drop mid-trade** | Position left unmanaged | Overnight violation |
| **Module init failure** | Strategy runs without risk checks | Account terminated |
| **Crash during position** | State lost, position unmanaged | Account loss |

## Assumptions to Validate

| Assumption | Challenge | Validation Method |
|------------|-----------|-------------------|
| PropFirmManager is single orchestration point | Other code might bypass it | grep for direct DD/time/position access |
| ET timezone conversion is correct | DST transitions in Nov/Mar | Test with specific DST transition dates |
| NautilusTrader events are ordered | Events could be delayed/reordered | Verify Nautilus guarantees in docs |
| Indicators are deterministic | Randomness could affect reproducibility | Check for random calls in indicator code |
| State persists correctly | Crash could corrupt state | Verify state recovery mechanism exists |

## Success Criteria
- [ ] All integration points documented with code references and verification tests
- [ ] Data flow diagrams created with actual method names
- [ ] State synchronization verified with trace logs
- [ ] Time handling confirmed correct for DST transitions
- [ ] No orphan state detected via static analysis
- [ ] All 3 time gates verified with code paths
- [ ] 30% consistency rule enforcement verified
- [ ] HWM unrealized P/L inclusion verified
- [ ] Edge cases (partial fills, rejections, gaps) documented
- [ ] `PHASE_08_FINDINGS.md` completed with severity-ordered issues

## Agents

**4 parallel NAUTILUS agents (model: opus)**
- Agent A: Strategy-Risk integration
- Agent B: Indicator-Strategy integration
- Agent C: Signal-Execution integration
- Agent D: Time synchronization
- Each applies CRITIC self-review internally
- Focus on state consistency and response enforcement

## Output
`PHASE_08_FINDINGS.md` in this directory (synthesized by orchestrator from all agent outputs)

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status
| ID | Issue | Status |
|----|-------|--------|
| C-001 | Only 2 agents, need 4 for all integration areas | FIXED - Agents C/D added (lines 108-123) |
| C-002 | Missing 30% consistency rule | FIXED - Added to checklist, failure modes, success criteria |
| C-003 | HWM must include unrealized P/L | FIXED - Explicitly stated in lines 99, 155, 233 |
| C-004 | Only mentioned 4:30 PM, missing 4:55/4:59 PM | FIXED - All 3 gates in lines 119-121, 163-165, 195-197 |
| C-005 | Risk check must enforce rejection, not just log | FIXED - Added verification in lines 97, 162 |
| C-006 | Missing edge cases section | FIXED - Added lines 199-207 |
| C-007 | Missing synthesis step for orchestrator | FIXED - Added lines 125-130 |
| C-008 | Failure mode table incomplete | FIXED - Expanded with 8 additional failure modes |
| C-009 | Missing initialization sequence verification | FIXED - Added to Agent B scope and checklist |
| C-010 | Missing crash recovery verification | FIXED - Added to edge cases and assumptions |
| C-011 | Success criteria vague | FIXED - Expanded with 10 specific criteria |

### New Issues Found
None. Plan is comprehensive and Apex-compliant.

### Verdict
APPROVED
