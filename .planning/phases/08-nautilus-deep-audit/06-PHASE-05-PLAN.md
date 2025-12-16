# PLAN: Phase 05 - Execution Layer Audit

## Objective
Critical analysis of execution layer to verify trade lifecycle management, slippage modeling, and broker adapter correctness.

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

### Agent Assignment

**Agent A (FORGE):** Trade Manager (Core)
- `trade_manager.py` (633 lines - main logic)
- `execution_model.py` (42 lines)
- ~675 lines

**Agent B (FORGE):** Adapters
- `base_adapter.py` (128 lines)
- `mt5_adapter.py` (44 lines)
- `ninjatrader_adapter.py` (42 lines)
- ~214 lines

## CRITICAL ANALYSIS AREAS

### trade_manager.py (CORE MODULE)

**Lifecycle Management:**
1. Order submission flow
2. Fill handling (complete, partial, rejected)
3. Position tracking
4. SL/TP management
5. Emergency close procedures

**Questions to Answer:**
- How are partial fills handled?
- What happens on order rejection?
- Is there retry logic?
- Position state machine documented?
- Thread safety if needed?

**Edge Cases to Test:**
- Order rejected → what state?
- Partial fill → remaining quantity?
- SL/TP hit simultaneously?
- Connection loss during order?
- Requote handling?

### execution_model.py

**Cost Modeling:**
1. Slippage calculation
2. Commission calculation
3. Spread impact

**Questions to Answer:**
- Slippage model realistic?
- Commission per contract accurate?
- How does spread affect entry?
- Latency simulation?

**Config Values to Verify (from GoldScalperConfig):**
- `slippage_ticks: 2`
- `slippage_multiplier: 1.5`
- `commission_per_contract: 2.5`
- `latency_ms: 0`
- `partial_fill_prob: 0.0`
- `fill_reject_base: 0.0`

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

## CRITIC Checklist

### Trade Manager
| Check | Status |
|-------|--------|
| Order lifecycle complete | ⬜ |
| Partial fill handling | ⬜ |
| Rejection recovery | ⬜ |
| SL/TP management correct | ⬜ |
| Position state consistent | ⬜ |
| Emergency close works | ⬜ |
| No blocking operations | ⬜ |

### Execution Model
| Check | Status |
|-------|--------|
| Slippage realistic | ⬜ |
| Commission accurate | ⬜ |
| Spread impact modeled | ⬜ |
| Config values sensible | ⬜ |

### Adapters
| Check | Status |
|-------|--------|
| Interface complete | ⬜ |
| Error handling defined | ⬜ |
| Implementation status clear | ⬜ |

## Specific Questions

1. **Slippage 2 ticks + 1.5x multiplier**: What does this mean in practice?
2. **Commission $2.5 per contract**: Is this Apex/Tradovate accurate?
3. **Partial fill probability 0%**: Should this be non-zero for realism?
4. **Fill reject base 0%**: Should this be non-zero?

## Integration with NautilusTrader

**Nautilus Execution Model:**
- Strategy → Order → ExecutionEngine → FillModel
- We're using custom ExecutionModel - does it integrate correctly?
- Are we using Nautilus's built-in execution or bypassing it?

**Questions:**
- How does `trade_manager` interact with Nautilus execution?
- Is there duplication of functionality?
- Are Nautilus events properly handled?

## Success Criteria
- [ ] All 5 execution modules reviewed
- [ ] Trade lifecycle fully documented
- [ ] Slippage model verified as realistic
- [ ] Edge cases catalogued
- [ ] Integration with Nautilus clarified
- [ ] `PHASE_05_FINDINGS.md` completed

## Agents

**2 parallel FORGE agents (model: opus)**
- Each handles specific modules
- Must apply CRITIC self-review internally
- Focus on edge case handling

## Output
`PHASE_05_FINDINGS.md` in this directory
