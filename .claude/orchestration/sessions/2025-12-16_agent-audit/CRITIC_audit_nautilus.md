# CRITIC ADVERSARIAL AUDIT: NAUTILUS-TRADER-ARCHITECT v3.0

**Date**: 2025-12-16
**Reviewer**: CRITIC v1.1
**Target**: `.claude/agents/nautilus-trader-architect.md`
**CLAUDE.md Version**: 3.10.9

---

## VERDICT: ISSUES_FOUND

The NAUTILUS agent specification is functional but has significant gaps that could lead to implementation failures, especially in live trading scenarios.

---

## CRITICAL ISSUES (3) - MUST FIX

### C1: Scope Conflict - Architecture vs Implementation

**Location**: Lines 18, 21, and Handoff table (line 277)

**Description**: The spec contains a fundamental contradiction:
- Line 18: "Autonomy: design + implement end-to-end with correct causality"
- Line 21: "Output: Architecture plan + Implementation + Validation + Handoffs"
- Handoff table: "Implementation needed → FORGE-NAUTILUS"

**Impact**: Agent confusion about its role. Does NAUTILUS design architecture and hand off to FORGE, or does it implement end-to-end? This leads to:
- Scope creep (NAUTILUS doing FORGE's job)
- Dropped handoffs (assuming other agent handles it)
- Duplicate work between agents

**Fix**: Clarify definitively:
```markdown
## ROLE BOUNDARIES
- NAUTILUS: Designs architecture, produces design artifacts, validates patterns
- FORGE-NAUTILUS: Implements code based on NAUTILUS designs
- NAUTILUS does NOT write production code - only templates/examples for design illustration
```

---

### C2: Template Contradicts Hard Gates - on_stop Incomplete

**Location**: Lines 51-55 (Hard Gates) vs Lines 169-172 (Template)

**Description**: Hard Gates specify cleanup requirements:
```
### Cleanup (on_stop)
- Close all positions.
- Cancel all orders.
- Unsubscribe from data feeds.  <-- REQUIRED
- No resource leaks.
```

But the Strategy Template only shows:
```python
def on_stop(self) -> None:
    # MANDATORY cleanup
    self.close_all_positions(self._instrument_id)
    self.cancel_all_orders(self._instrument_id)
    # MISSING: unsubscribe_bars(), unsubscribe_quote_ticks(), etc.
```

**Impact**: Strategies built from this template will have resource leaks. Agents trusting the template will produce non-compliant code.

**Fix**: Complete the template:
```python
def on_stop(self) -> None:
    # MANDATORY cleanup
    self.close_all_positions(self._instrument_id)
    self.cancel_all_orders(self._instrument_id)
    # Unsubscribe from data feeds
    self.unsubscribe_bars(self._bar_type)
    # If subscribed to ticks:
    # self.unsubscribe_quote_ticks(self._instrument_id)
```

---

### C3: No Structured Output Template

**Location**: Line 21, entire document

**Description**: The spec says output should be "Architecture plan + Implementation + Validation + Handoffs" but provides no template or format. Compare to CLAUDE.md which has detailed `structured_handoff` format.

**Impact**:
- Inconsistent outputs from NAUTILUS
- Downstream agents (FORGE, REVIEWER) receive unstructured input
- Information loss in handoffs
- No way to verify completeness

**Fix**: Add structured output template:
```markdown
## OUTPUT TEMPLATE

### Architecture Decision Document

## ARCHITECTURE_DECISION
Decision: [what pattern/approach was chosen]
Pattern: [Strategy-only | Actor+Strategy | Multi-Actor Pipeline]

## RATIONALE
- [Reason 1]
- [Reason 2]

## COMPONENT DIAGRAM
[ASCII diagram or description]

## INTERFACES
| Component | Inputs | Outputs | Dependencies |
|-----------|--------|---------|--------------|

## APEX COMPLIANCE
| Requirement | How Addressed |
|-------------|---------------|
| Trailing DD | [approach] |
| Time Gates | [approach] |
| Overnight | [approach] |

## TEMPORAL CORRECTNESS
[Verification approach]

## RISKS
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

## HANDOFF: NAUTILUS → [Target]
[Use structured_handoff format from CLAUDE.md]
```

---

## HIGH ISSUES (9) - SHOULD FIX

### H1: Time Gate Implementation is Vague

**Location**: Lines 57-61

**Description**: Says "Use Actor to publish time events" but provides no specifics on:
- How to convert UTC to ET in NautilusTrader
- How to handle DST (EST vs EDT transitions)
- Which clock source to use (system, exchange, simulated)
- Pattern for time-based event scheduling

**Impact**: Developers will implement time gates incorrectly, leading to Apex violations.

**Fix**: Add time handling pattern:
```python
# Example: Time gate Actor
from datetime import time
import pytz

ET = pytz.timezone('America/New_York')

def _get_et_time(self, ts_event: int) -> time:
    """Convert event timestamp to ET time."""
    utc_dt = datetime.utcfromtimestamp(ts_event / 1e9)
    et_dt = utc_dt.replace(tzinfo=pytz.UTC).astimezone(ET)
    return et_dt.time()

def on_bar(self, bar: Bar) -> None:
    et_time = self._get_et_time(bar.ts_event)
    if et_time >= time(16, 30):  # 4:30 PM ET
        self._block_new_trades = True
    if et_time >= time(16, 55):  # 4:55 PM ET
        self._emergency_close()
```

---

### H2: No Guidance on Testing Apex Compliance

**Location**: Absent from spec

**Description**: Spec lists Apex rules but provides no:
- Test cases for time gates
- Validation scripts for overnight check
- Sample backtest to verify DD tracking
- Regression tests for Apex compliance

**Impact**: Apex compliance cannot be verified systematically.

**Fix**: Add testing section:
```markdown
## APEX COMPLIANCE TESTING

Required test scenarios:
1. Trade attempt at 4:31 PM ET → MUST BE BLOCKED
2. Trade attempt at 4:29 PM ET → MUST BE ALLOWED
3. Open position at 4:54 PM ET → EMERGENCY CLOSE at 4:55 PM
4. Position held overnight → MUST FAIL VALIDATION
5. DD hits 4.0% trailing → HALT triggered
```

---

### H3: DD Tracking Architecture Not Specified

**Location**: Absent from spec

**Description**: Trailing DD tracking is critical for Apex but spec doesn't address:
- Where to track High-Water Mark (Strategy? Actor? External?)
- How to include unrealized P/L in calculations
- Equity curve monitoring pattern
- Circuit breaker architecture

**Impact**: DD tracking will be implemented ad-hoc, inconsistently, or incorrectly.

**Fix**: Add DD tracking pattern section.

---

### H4: Error Handling in on_start is Weak

**Location**: Lines 156-163

**Description**: Template shows minimal error handling:
```python
if instrument is None:
    self.log.error("Instrument not found")
    self.stop()
    return
```

Missing:
- Error event publication
- State cleanup before stop
- Graceful degradation options
- Retry logic for transient failures

**Fix**: Enhance error handling pattern.

---

### H5: on_bar Handler Template is Empty

**Location**: Lines 164-167

**Description**: Template shows only:
```python
def on_bar(self, bar: Bar) -> None:
    # CRITICAL: Use ONLY completed bar info
    pass
```

No guidance on:
- Checking for gap bars
- Handling first bar after connection
- Position state validation
- Market activity checks

**Fix**: Add substantive on_bar pattern with common checks.

---

### H6: Live Trading Architecture NOT Addressed

**Location**: Entire document

**Description**: Spec focuses almost exclusively on BacktestNode. Critical live trading concerns not addressed:
- TradingNode configuration
- Connection management
- Order rejection handling
- Latency spikes
- Venue adapter specifics

**Impact**: Architecture designed for backtest will fail in live environment.

**Fix**: Add "Live Trading Considerations" section covering differences from backtest.

---

### H7: No Versioning/Migration Strategy

**Location**: Absent from spec

**Description**: No guidance on:
- How to update Strategy without losing position state
- Config versioning between deployments
- Rollback patterns
- State persistence across restarts

**Fix**: Add operational patterns section.

---

### H8: Missing Resilience Patterns

**Location**: Absent from spec

**Description**: No patterns for:
- Circuit breakers (rate limiting, error cascades)
- Health checks / heartbeats
- Reconnection strategies
- Partial failure handling

**Fix**: Add resilience architecture section.

---

### H9: No Handoff for Live Trading Deployment

**Location**: Handoff table, lines 274-282

**Description**: Handoff table covers design → implementation → testing but stops there. No handoff for:
- Infrastructure / deployment
- Operations / monitoring
- Production support

**Impact**: Gap in production readiness pathway.

**Fix**: Add operational handoffs or clarify that production deployment is out of scope.

---

## MEDIUM ISSUES (7)

### M1: Pattern Decision Tree Too Simplistic

**Location**: Lines 72-90

**Description**: Binary decision tree doesn't handle:
- Components that both compute AND publish
- Risk management (is it Strategy, Actor, or separate?)
- Logging/monitoring actors
- State that spans multiple strategies

**Fix**: Add nuanced guidance and exceptions to pattern selection.

---

### M2: No Multi-Strategy Coordination Guidance

**Location**: Absent from spec

**Description**: No patterns for:
- Multiple strategies avoiding simultaneous trades
- Portfolio-level DD aggregation
- Cross-strategy signal sharing
- Resource contention

**Fix**: Add multi-strategy architecture section.

---

### M3: Actor Template Has Issues

**Location**: Lines 175-201

**Description**:
- `SignalActorConfig` is empty (`pass`)
- `publish_data()` has no example of signal object
- No error handling if no subscribers
- No lifecycle management

**Fix**: Flesh out Actor template with realistic example.

---

### M4: Self-Review Missing CRITIC Techniques

**Location**: Lines 291-292

**Description**: Says to apply "INVERSION, PRE-MORTEM, EDGE CASES" but CRITIC has 7 techniques:
1. INVERSION
2. PRE-MORTEM
3. STRESS TEST (missing)
4. REGIME SHIFT (missing)
5. APEX TRAP ANALYSIS (missing)
6. EDGE CASES
7. ASSUMPTION AUDIT (missing)

**Fix**: Update to include all 7 techniques or justify omissions.

---

### M5: Circular Dependency Risk in Handoffs

**Location**: Handoff table

**Description**: Potential loop:
- NAUTILUS → FORGE (for implementation)
- FORGE finds architecture issue → where to escalate?
- Back to NAUTILUS? Creates circular dependency.

**Fix**: Add escalation path guidance.

---

### M6: Missing Intake Requirements Template

**Location**: Absent from spec

**Description**: No template for requests coming INTO NAUTILUS:
- What information is needed to start architecture work?
- What questions to ask before designing?
- What are the required vs optional inputs?

**Fix**: Add "Architecture Request Template" section.

---

### M7: Assumption That Backtest Patterns Transfer to Live

**Location**: Implicit throughout spec

**Description**: Spec assumes BacktestNode patterns work for live:
- Different configuration structures
- Different venue behaviors
- Different data sources
- Different error modes

**Fix**: Explicitly call out backtest vs live differences.

---

## LOW ISSUES (1)

### L1: No Context7 Query Syntax Guidance

**Location**: Lines 298-309

**Description**: Lists topics to fetch but not how to query effectively. Missing:
- Example queries
- Navigation tips
- Fallback if Context7 is incomplete

**Fix**: Add query examples.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| "Pure Python, no MQL5" | What if hybrid needed? | Clarify scope or add integration patterns |
| Pattern selection is binary | Reality: many blur lines | Add nuanced guidance |
| BacktestNode = LiveNode patterns | Different behaviors | Document differences |
| Context7 has all docs | May be outdated | Add fallback: source code, GitHub |

---

## EDGE CASES NOT ADDRESSED

1. What if bar has no market activity (`is_single_price`)?
2. What if instrument is delisted mid-session?
3. What if venue rejects all orders (maintenance)?
4. What if clock skew between system and exchange?
5. What if portfolio has multiple gold instruments?

---

## STRESS TEST SCENARIOS NOT COVERED

1. Spread 3x normal during news
2. 500ms latency spike
3. Connection drop during open position
4. 100+ orders/second burst
5. Memory pressure with long backtest

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify on_stop cleanup pattern against NautilusTrader source
- [ ] Confirm time zone handling approach with Context7/docs
- [ ] Validate BacktestDataConfig fields are current
- [ ] Check if ParquetDataCatalog API has changed
- [ ] Review actual FORGE-NAUTILUS spec for handoff alignment

---

## CONFIDENCE: MEDIUM

**Reason**: The spec covers core patterns well but has significant gaps in:
1. Output format (CRITICAL)
2. Live trading architecture (HIGH)
3. Apex compliance testing (HIGH)
4. Scope clarity (CRITICAL)

These gaps could lead to agent confusion and non-compliant implementations.

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Agent produces architecture that works in backtest but fails live due to unhandled live-specific concerns (connection drops, order rejections, latency).

**Second most likely**: Scope confusion leads to NAUTILUS producing code that should be FORGE's responsibility, causing duplicated work or dropped handoffs.

**Third most likely**: Incomplete cleanup template leads to resource leaks in production.

**Mitigation**: Address the 3 CRITICAL issues first, then the 9 HIGH issues. Focus on live trading section and output template as priorities.

---

## RECOMMENDED PRIORITY ORDER

1. **C1**: Clarify scope (architecture vs implementation)
2. **C3**: Add structured output template
3. **C2**: Fix on_stop template to include unsubscribe
4. **H6**: Add live trading architecture section
5. **H1**: Add time gate implementation pattern
6. **H2**: Add Apex compliance test scenarios
7. **H3**: Add DD tracking architecture
8. **H8**: Add resilience patterns

---

**CRITIC v1.1 - Adversarial Quality Guardian**
*"Every gap found now is a failure prevented later."*
