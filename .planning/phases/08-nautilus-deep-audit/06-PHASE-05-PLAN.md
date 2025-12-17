# PLAN: Phase 05 - Execution Layer Audit

> **Changelog:**
> - 2025-12-17: **CRITICAL** - Added mandatory delegation enforcement (Protocol 0). Orchestrator MUST NOT read source files directly.
> - 2025-12-16 (v1.1): Applied CRITIC review fixes: realistic execution defaults, Apex time gates, SL rejection handling, expanded edge cases, state machine requirement, workload rebalancing, quantitative success criteria, blocking criteria.

---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read source files directly.**
>
> This phase analyzes ~889 lines of execution-critical code. Reading these files directly will cause context overflow.

### Orchestrator Behavior

```
❌ WRONG (causes context overflow):
   Orchestrator reads execution files directly
   Orchestrator traces order lifecycle in main context
   → CONTEXT OVERFLOW → Summarization → LOST EXECUTION DETAILS

✅ CORRECT (sustainable):
   Orchestrator spawns FORGE sub-agents with delegation prompt
   Each FORGE reads assigned files, traces lifecycle, writes findings
   Each FORGE returns 300-word summary to orchestrator
   Orchestrator consolidates and updates MANIFEST.md
```

### Required Sub-Agent Prompts

**Agent A (Trade Manager):**
```
Execute Phase 05 Agent A (Trade Manager) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source file - orchestrator has NOT read it
2. File to analyze: nautilus_gold_scalper/src/execution/trade_manager.py (633 lines)
3. Focus: Lifecycle, state machine, Apex time gates, SL rejection handling
4. Produce state machine diagram with ALL order/position transitions
5. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_05_A_TRADEMGR_FINDINGS.md
6. Return ONLY summary (max 300 words) with issue counts and state machine status

Plan file: .planning/phases/08-nautilus-deep-audit/06-PHASE-05-PLAN.md
```

**Agent B (Execution Model + Adapters):**
```
Execute Phase 05 Agent B (Execution Model + Adapters) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/execution/execution_model.py (42 lines)
   - nautilus_gold_scalper/src/execution/base_adapter.py (128 lines)
   - nautilus_gold_scalper/src/execution/mt5_adapter.py (44 lines)
   - nautilus_gold_scalper/src/execution/ninjatrader_adapter.py (42 lines)
3. Focus: Execution realism, slippage model, Nautilus integration
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_05_B_ADAPTERS_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts

Plan file: .planning/phases/08-nautilus-deep-audit/06-PHASE-05-PLAN.md
```

---

## Objective
Critical analysis of execution layer to verify trade lifecycle management, slippage modeling, and broker adapter correctness for Apex prop firm live trading.

## Prerequisites (MUST COMPLETE BEFORE FILE AUDIT)

Before diving into file-by-file analysis, confirm:
1. **Execution Architecture:** Is trade_manager using Nautilus execution or custom path?
2. **Production Adapter:** Which adapter (MT5/NinjaTrader) is production-relevant for Apex/Tradovate?
3. **Execution Flow:** Document the actual order flow from strategy signal to fill

## Files Under Review

| File | Lines | Responsibility |
|------|-------|----------------|
| `base_adapter.py` | 128 | Base execution adapter |
| `execution_model.py` | 42 | Execution cost model |
| `mt5_adapter.py` | 44 | MT5 integration (stub?) |
| `ninjatrader_adapter.py` | 42 | NinjaTrader integration (stub?) |
| `trade_manager.py` | 633 | Trade lifecycle management |

**Total:** ~889 lines

## Execution Plan

### Agent Assignment (REBALANCED)

**Agent A (FORGE):** Trade Manager (Core Logic)
- `trade_manager.py` (633 lines - main logic)
- Focus: lifecycle, state machine, Apex time gates, edge cases
- ~633 lines

**Agent B (FORGE):** Execution Model + Adapters + Integration
- `execution_model.py` (42 lines) - CRITICAL for realism
- `base_adapter.py` (128 lines)
- `mt5_adapter.py` (44 lines)
- `ninjatrader_adapter.py` (42 lines)
- Focus: execution realism validation, Nautilus integration verification
- ~256 lines + integration analysis work to balance workload

## CRITICAL ANALYSIS AREAS

### trade_manager.py (CORE MODULE)

**Lifecycle Management:**
1. Order submission flow
2. Fill handling (complete, partial, rejected)
3. Position tracking
4. SL/TP management
5. Emergency close procedures
6. **Apex time gate enforcement**

**State Machine Requirement:**
- **MANDATORY:** Produce state machine diagram with ALL order/position transitions
- States: Pending, Submitted, PartialFill, Filled, Rejected, Cancelled, Expired
- All transitions must be documented with trigger conditions

**Questions to Answer:**
- How are partial fills handled?
- What happens on order rejection?
- **What happens on SL/TP order rejection while position is open?** (CRITICAL)
- Is there retry logic?
- Position state machine documented? **Produce diagram if missing.**
- Thread safety if needed?
- **Are Apex time gates (4:30, 4:55, 4:59 PM ET) enforced?**

**Edge Cases to Test:**
- Order rejected -> what state?
- Partial fill -> remaining quantity?
- SL/TP hit simultaneously?
- Connection loss during order?
- Requote handling?
- **SL order rejected while position open (CATASTROPHIC)** - what recovery?
- **Double-fill / duplicate event handling**
- **Out-of-sequence events (fill before ack)**
- **Price gap through SL level** - what fill price used?
- **Connection loss during protective order**
- **Stale order timeout recovery**
- **Weekend gap handling**
- **Holiday handling** - is holiday calendar integrated?

### execution_model.py

**Cost Modeling:**
1. Slippage calculation
2. Commission calculation
3. Spread impact
4. **Latency simulation** (MUST be non-zero)

**Questions to Answer:**
- Slippage model realistic?
- Commission per contract accurate for Apex/Tradovate?
- How does spread affect entry?
- **Latency simulation - is it realistic for Apex?**

**Config Values to Verify (from GoldScalperConfig):**
| Config | Current | ISSUE | Recommended |
|--------|---------|-------|-------------|
| `slippage_ticks` | 2 | OK | 2-4 ticks |
| `slippage_multiplier` | 1.5 | OK | 1.5-2.0 |
| `commission_per_contract` | 2.5 | Verify | Check Apex/Tradovate actual |
| `latency_ms` | 0 | **CRITICAL: UNREALISTIC** | 50-100ms (Apex realistic) |
| `partial_fill_prob` | 0.0 | **CRITICAL: UNREALISTIC** | 5-10% for realism |
| `fill_reject_base` | 0.0 | **CRITICAL: UNREALISTIC** | 1-3% during volatility |

**MANDATORY FINDINGS:** These unrealistic defaults must be flagged as MUST-FIX if unchanged.

### base_adapter.py

**Adapter Pattern:**
1. Interface definition
2. Required methods
3. Error handling contract

**Questions to Answer:**
- Is interface complete?
- Error types defined?
- Async support?

### mt5_adapter.py / ninjatrader_adapter.py

**Integration Status:**
- Are these stubs or implemented?
- Connection handling?
- Order mapping?
- Event translation?
- **Which is production-relevant for Apex/Tradovate?**

## CRITIC Checklists

### Trade Manager
| Check | Status |
|-------|--------|
| Order lifecycle complete | [ ] |
| Partial fill handling | [ ] |
| Entry rejection recovery | [ ] |
| **SL/TP rejection recovery** | [ ] |
| SL/TP management correct | [ ] |
| Position state consistent | [ ] |
| Emergency close works | [ ] |
| No blocking operations | [ ] |
| **State machine diagram produced** | [ ] |
| **Double-fill deduplication** | [ ] |
| **Out-of-sequence handling** | [ ] |

### Apex Execution Compliance
| Check | Status |
|-------|--------|
| Time gate at 4:30 PM ET enforced (block new trades) | [ ] |
| Emergency close at 4:55 PM ET | [ ] |
| Forced close by 4:59 PM ET | [ ] |
| Weekend position handling | [ ] |
| Holiday calendar integration | [ ] |
| Order validity (GTC/DAY) correct | [ ] |

### Execution Model
| Check | Status |
|-------|--------|
| Slippage realistic | [ ] |
| Commission accurate | [ ] |
| Spread impact modeled | [ ] |
| **Latency non-zero and realistic** | [ ] |
| **Partial fill probability non-zero** | [ ] |
| **Rejection probability non-zero** | [ ] |
| Config values sensible | [ ] |

### Adapters
| Check | Status |
|-------|--------|
| Interface complete | [ ] |
| Error handling defined | [ ] |
| Implementation status clear | [ ] |
| Production adapter identified | [ ] |

## Specific Questions

1. **Slippage 2 ticks + 1.5x multiplier**: What does this mean in practice?
2. **Commission $2.5 per contract**: Is this Apex/Tradovate accurate?
3. **Partial fill probability 0%**: **MUST be non-zero for realism (5-10% recommended)**
4. **Fill reject base 0%**: **MUST be non-zero (1-3% recommended)**
5. **Latency 0ms**: **MUST be set to realistic value (50-100ms for Apex)**

## Integration with NautilusTrader

**Nautilus Execution Model:**
- Strategy -> Order -> ExecutionEngine -> FillModel
- We're using custom ExecutionModel - does it integrate correctly?
- Are we using Nautilus's built-in execution or bypassing it?

**Questions:**
- How does `trade_manager` interact with Nautilus execution?
- Is there duplication of functionality?
- Are Nautilus events properly handled?

**MANDATORY:** Clear YES/NO answer on Nautilus integration architecture

## Success Criteria (QUANTITATIVE)

| Criterion | Measure | Target |
|-----------|---------|--------|
| All 5 execution modules reviewed | Count | 5/5 |
| State machine diagram produced | Diagram exists | YES with all transitions |
| Edge cases documented | Count | >= 12 edge cases |
| Slippage model verified | Comparison to historical data | Documented |
| Latency model | Value | >= 20ms |
| Partial fill probability | Value | > 0% |
| Rejection probability | Value | > 0% |
| Nautilus integration | Clear answer | YES/NO documented |
| `PHASE_05_FINDINGS.md` completed | File exists | YES |

## Blocking Criteria

**Any of these findings = BLOCKER for Phase 06:**
- Missing SL/TP rejection handling (catastrophic DD risk)
- Zero latency in production config
- Zero rejection probability in production config
- No emergency close mechanism for 4:55/4:59 PM
- State machine has undefined transitions
- **Missing connection monitoring (190K loss incident documented by ARGUS)**

**CRITICAL finding = must fix before Phase 06**

## Agents

**2 parallel FORGE agents (model: opus)**
- Each handles specific modules (see rebalanced assignment above)
- **MUST apply CRITIC self-review internally**
- Focus on edge case handling
- **Agent B assists with Nautilus integration analysis to balance workload**

## Output
`PHASE_05_FINDINGS.md` in this directory

Include:
- State machine diagram (Mermaid or ASCII)
- Edge case matrix with expected behavior
- Config value recommendations
- CRITICAL/HIGH/MEDIUM findings table
- Nautilus integration decision
- Blocking issues (if any)

---

## ARGUS Integration (2025-12-16)

### TRADOVATE Order Rejection Handling Verification

**Critical Context**: TRADOVATE has specific error codes and rejection scenarios that must be handled.

| Error | Meaning | Required Handling | Status |
|-------|---------|-------------------|--------|
| "Order can be placed by administrators only" | **ACCOUNT BLOWN - DD hit** | Immediate HALT, no retry | [ ] |
| "Send cancels only after 30 secs" | Too many cancel requests | Rate limit order modifications | [ ] |
| "The OCO ID cannot be reused" | OCO mode issue | Disable OCO, use separate orders | [ ] |
| "Atomic order operation in progress" | Order modification during fill/cancel | Queue order changes, don't spam | [ ] |
| "Session count to exceed maximum" | Multiple logins | Single session enforcement | [ ] |
| "Disconnect enforced by broker" | Connection settings wrong | Verify plug-in mode OFF | [ ] |

### Order Rejection Recovery Matrix

| Rejection Type | Position State | Required Action | Severity | Status |
|----------------|----------------|-----------------|----------|--------|
| Entry rejected | No position | Log and retry (with backoff) | MEDIUM | [ ] |
| SL rejected | Open position (NAKED) | **EMERGENCY: market close immediately** | CRITICAL | [ ] |
| TP rejected | Open position | Retry with market order | HIGH | [ ] |
| Modification rejected | Position with stale SL/TP | Verify current SL/TP, retry | HIGH | [ ] |
| Close rejected | Open position near 4:59 PM | Retry immediately, escalate | CRITICAL | [ ] |

### Rate Limiting Requirements

**TRADOVATE-specific rate limits:**
- [ ] Order modification cooldown: 30 seconds between cancel attempts
- [ ] Reconnection: Exponential backoff (2s, 4s, 8s, 16s...)
- [ ] Order queue: Max 1 pending order per symbol
- [ ] Heartbeat: Data feed verification every 5 seconds

### Platform Disconnect Scenario Verification

**Real incident from ARGUS research:** 190K lost across 14 accounts in single disconnection event (2024)

| Scenario | Expected Behavior | Status |
|----------|-------------------|--------|
| Connection lost mid-trade | Reconnect with exponential backoff | [ ] |
| Reconnect successful | Verify all positions, sync state | [ ] |
| Reconnect fails 3+ times | Switch to backup (mobile alert) | [ ] |
| Position open on reconnect | Verify SL/TP still active | [ ] |
| No data feed for 30s | HALT trading, alert | [ ] |

### NinjaTrader OIF Bridge Verification

**OIF = Order Instruction Files** (NinjaTrader's file-based order interface via ATI)

**User Context**: Will use NinjaTrader as execution bridge (file-based OIF)

**Note**: OIF uses ATI (Automated Trading Interface) which may leave audit trail. See ARGUS NT8 Add-On research for stealth alternatives (OrderEntry.Manual via Add-On).

| Check | Requirement | Status |
|-------|-------------|--------|
| OIF file write atomicity | Ensure complete write before signal | [ ] |
| OIF file read confirmation | Verify execution acknowledged | [ ] |
| OIF timeout handling | What if NinjaTrader doesn't respond? | [ ] |
| OIF state sync | Position state matches between systems | [ ] |
| OIF emergency close | Can force close via OIF in emergency? | [ ] |

### News Window Execution Blocking

**Gold (XAUUSD) during news:**
- Normal spread: 12-20 pips
- During news: 100-200+ pips
- Peak observed: **800+ pips slippage**

| Check | Requirement | Status |
|-------|-------------|--------|
| NFP/CPI/FOMC calendar integration | Known high-impact events flagged | [ ] |
| Spread spike detection | Real-time spread monitoring | [ ] |
| Trade blocking window | No trades 5-10 min before/after news | [ ] |
| Position exit during news | Use market order only (no limit) | [ ] |
| Slippage buffer in sizing | Size for 150% of planned SL | [ ] |

### Execution Model Apex Compliance

**ARGUS-derived requirements:**

```python
# Recommended values for Apex/TRADOVATE compliance
class ApexExecutionConfig:
    # Latency (must be non-zero)
    LATENCY_MS = 75  # 50-100ms realistic for Apex

    # Slippage
    SLIPPAGE_TICKS = 3  # Conservative for gold
    SLIPPAGE_MULTIPLIER = 1.5  # During volatility
    NEWS_SLIPPAGE_MULTIPLIER = 5.0  # During NFP/CPI

    # Rejection probability
    PARTIAL_FILL_PROB = 0.05  # 5% realistic
    FILL_REJECT_BASE = 0.02  # 2% base, higher during volatility

    # Commission
    COMMISSION_PER_CONTRACT = 2.50  # Verify with Apex/Tradovate

    # Rate limits
    ORDER_MODIFY_COOLDOWN_SEC = 30
    RECONNECT_INITIAL_DELAY_SEC = 2
    RECONNECT_MAX_DELAY_SEC = 60
```

### Execution Edge Cases from ARGUS

- [ ] **Gap through SL level**: What fill price is used? (must be actual gap-through price, not SL level)
- [ ] **Weekend gap handling**: Verify no positions held through Friday close
- [ ] **Holiday handling**: Is holiday calendar integrated for futures?
- [ ] **Rollover handling**: Contract expiration awareness
- [ ] **Quote disappearance**: What if bid/ask become unavailable?
- [ ] **Price rejection (requote)**: Retry logic with price update

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status
| ID | Issue | Status |
|----|-------|--------|
| C-001 | Unrealistic execution defaults (latency=0, partial_fill=0, rejection=0) | FIXED - Lines 100-109 explicitly flag these as CRITICAL with recommended values |
| C-002 | Missing Apex time gates in audit scope | FIXED - Lines 55, 68, 149-157 add comprehensive time gate checklist |
| C-003 | SL/TP rejection handling not addressed | FIXED - Lines 64, 76, 140, 217 mark as CRITICAL/CATASTROPHIC with blocking status |
| C-004 | Insufficient edge cases | FIXED - Lines 71-83 expanded to 12+ edge cases including double-fill, out-of-sequence, gaps |
| C-005 | No state machine requirement | FIXED - Lines 56-60, 145, 205, 221 make diagram MANDATORY with blocking criteria |
| C-006 | Unbalanced workload between agents | FIXED - Lines 29-42, 231 rebalance with integration analysis for Agent B |
| C-007 | Non-quantitative success criteria | FIXED - Lines 200-212 add specific measures and targets |
| C-008 | No blocking criteria defined | FIXED - Lines 214-223 define explicit blockers for Phase 06 |

### New Issues Found
None. The plan is comprehensive and well-structured for execution layer audit.

### Verdict
APPROVED - All previous CRITIC issues addressed. Ready for execution.
