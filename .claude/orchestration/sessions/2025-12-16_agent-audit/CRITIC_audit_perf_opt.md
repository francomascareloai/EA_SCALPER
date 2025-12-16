# CRITIC Adversarial Audit: PERF_OPT v2.1

**Agent**: `.claude/agents/performance-optimizer.md`
**Auditor**: CRITIC
**Date**: 2025-12-16
**CLAUDE.md Version**: 3.10.9

---

## Executive Summary

PERF_OPT v2.1 is a reasonably well-structured performance optimization agent with clear budgets and a measure-first philosophy. However, the audit reveals several gaps that could lead to incomplete optimization coverage, unclear escalation paths, and missing capabilities for real-world trading system profiling.

**Severity Distribution**:
- CRITICAL: 1
- HIGH: 3
- MEDIUM: 4
- LOW: 2

---

## CRITIC Technique Application

### 1. INVERSION ("What would make this agent fail?")

| Failure Mode | Impact | Finding |
|--------------|--------|---------|
| Agent optimizes wrong code path | Wasted effort, real bottleneck remains | **MEDIUM**: No explicit guidance on identifying HOT vs WARM vs COLD paths |
| Optimization breaks correctness | Trading losses, Apex violation | **Addressed** by guardrails section |
| Budget inconsistency | Confusion on enforcement | **CRITICAL**: Header says "OnTick <50ms" but body says "<1ms / <100us" |
| No access to production metrics | Blind optimization | **HIGH**: No guidance on production profiling vs dev profiling differences |
| Micro-benchmark vs real load | False positives | **MEDIUM**: Missing guidance on realistic load simulation |

### 2. PRE-MORTEM ("It's 6 months later and PERF_OPT caused a production incident...")

**Scenario 1**: Agent optimized a function using unsafe parallelism, causing race condition in live trading.
- **Missing**: No explicit prohibition on introducing threading/async without review
- **Severity**: HIGH

**Scenario 2**: Agent optimized memory allocation by reusing objects, but stale state leaked between trades.
- **Missing**: No guidance on stateful optimization pitfalls in trading context
- **Severity**: MEDIUM

**Scenario 3**: Agent declared optimization "done" but only tested on small dataset; production load 100x higher crashed the system.
- **Missing**: No guidance on load testing/stress testing requirements
- **Severity**: HIGH

### 3. STRESS TEST ("What happens under extreme conditions?")

| Extreme Condition | Agent Behavior | Gap |
|-------------------|----------------|-----|
| 100+ functions flagged as bottlenecks | Unclear prioritization | No triage protocol for mass hotspots |
| Profiling data is 10MB+ | Context overflow | Mentions "delegate to Explorer" but no concrete protocol |
| External dependency (ONNX) is slow but unchangeable | No fallback | No guidance on "optimize around" vs "escalate to ONNX_BUILDER" |
| Memory pressure (GC pauses) | Unaddressed | Only CPU profiling mentioned; no memory profiling guidance |
| Network latency spikes | Unaddressed | Hub <400ms assumes stable network; no jitter handling |

### 4. EDGE CASES

| Edge Case | Current Handling | Recommendation |
|-----------|------------------|----------------|
| Code already at budget limit (49ms vs 50ms) | Unclear | Add "buffer zone" guidance (e.g., target <40ms for headroom) |
| Multiple hot paths competing | Unclear | Add prioritization: which to optimize first? |
| Third-party library is bottleneck | Not addressed | Add guidance on wrapping/caching vs escalating |
| Profile shows equal time across 20 functions | No guidance | Add "spread bottleneck" handling |
| Test suite itself is slow | Unclear if in scope | Clarify scope boundaries |
| CI/CD pipeline performance | Unclear if in scope | Clarify scope boundaries |

### 5. ASSUMPTION AUDIT

| Assumption in Spec | Validity Check | Issue |
|--------------------|----------------|-------|
| cProfile is sufficient | PARTIAL | cProfile has overhead; line_profiler may be needed for micro-optimization |
| Budget numbers are correct | CONFLICTING | Header vs body contradiction on OnTick budget |
| Tests catch correctness regressions | MAYBE | May need specific perf-correctness tests |
| Hot path is known | MAYBE | Often discovered during profiling, not before |
| Single measurement is representative | NO | Should mandate multiple runs/statistical significance |
| Profile in dev = profile in prod | NO | Production has different memory pressure, data volume |

---

## Detailed Findings

### CRITICAL-001: Budget Contradiction

**Location**: Header (lines 4-5) vs Body (line 33)
**Issue**: Header states "OnTick <50ms" but body specifies "Strategy handlers: <1ms / <100us". This is a 50x difference.
**Impact**: Agent may enforce wrong budget, either too strict (blocking valid code) or too lenient (allowing slow code)
**Recommendation**: Clarify definitively:
- OnTick (MQL5): <50ms
- Strategy handlers (NautilusTrader on_bar/on_quote_tick): <1ms median, <100us p99
- Document which budget applies to which codebase

---

### HIGH-001: Missing Concurrency/Parallelism Guardrails

**Location**: Not present
**Issue**: Agent may introduce threading, async, or multiprocessing optimizations without understanding trading-specific constraints (GIL, event loop, state sharing)
**Impact**: Race conditions, deadlocks, stale state in live trading
**Recommendation**: Add guardrail:
```
- Concurrency: NEVER introduce threading/multiprocessing without SENTINEL review.
  Async is allowed only within NautilusTrader patterns.
  Object reuse must be reviewed for state leakage.
```

---

### HIGH-002: No Memory Profiling Guidance

**Location**: Quick commands section (lines 47-51)
**Issue**: Only cProfile (CPU) mentioned. Memory issues (GC pauses, allocations in hot path) are common bottlenecks
**Impact**: May miss memory-related performance issues
**Recommendation**: Add commands:
```bash
python3 -m memory_profiler script.py
python3 -m tracemalloc  # or via code instrumentation
```
Add memory-specific budget guidance.

---

### HIGH-003: Missing Load Testing Requirements

**Location**: Workflow section (lines 39-45)
**Issue**: Workflow mentions "measure baseline" but doesn't specify realistic load conditions
**Impact**: Optimization validated on small dataset may fail under production load
**Recommendation**: Add step:
```
1.5) Ensure measurement uses realistic data volume (minimum: 1 day of tick data, ~50k ticks)
     and realistic concurrency (if applicable).
```

---

### MEDIUM-001: Missing Escalation Matrix

**Location**: Guardrails (lines 53-56)
**Issue**: Only mentions "REVIEWER handoff" but no clear escalation for other scenarios
**Impact**: Agent may not know when to escalate to ONNX_BUILDER, FORGE, or SENTINEL
**Recommendation**: Add escalation matrix:
```
## Escalation
- Optimization requires code change in trading logic → FORGE
- Optimization requires model retraining/quantization → ONNX_BUILDER
- Optimization affects risk calculations → SENTINEL
- Optimization requires architecture change → Orchestrator
- Cannot meet budget without major refactor → Escalate with evidence
```

---

### MEDIUM-002: Missing Statistical Rigor

**Location**: Workflow section
**Issue**: No requirement for multiple profiling runs, statistical significance, or variance reporting
**Impact**: Noisy measurements lead to false conclusions
**Recommendation**: Add:
```
- Minimum 5 profiling runs for any measurement
- Report median and p95/p99, not just mean
- Variance >20% requires investigation before optimization
```

---

### MEDIUM-003: Unclear Scope Boundaries

**Location**: Not defined
**Issue**: Unclear if agent handles: test suite performance, CI/CD, build times, IDE performance
**Impact**: Either scope creep or missed opportunities
**Recommendation**: Add explicit scope section:
```
## Scope
IN SCOPE: Trading strategy handlers, ONNX inference, Hub calls, data processing pipelines
OUT OF SCOPE: Test suite speed (unless blocking CI), IDE/tooling, build times, documentation generation
```

---

### MEDIUM-004: Missing "Cannot Optimize" Protocol

**Location**: Not present
**Issue**: No guidance on what to do when budget cannot be met (algorithm is inherently O(n^2), etc.)
**Impact**: Agent may waste cycles or give up without proper handoff
**Recommendation**: Add:
```
## Cannot Meet Budget
If budget cannot be met after 2 optimization rounds:
1. Document the constraint (algorithmic, I/O-bound, external dependency)
2. Calculate the gap (e.g., "current 80ms, budget 50ms, gap 60%")
3. Propose alternatives: caching, async, architecture change
4. Escalate to orchestrator with evidence for architecture review
```

---

### LOW-001: Missing Version History/Changelog

**Location**: Header
**Issue**: Only version number, no history of changes
**Impact**: Hard to track what changed between versions
**Recommendation**: Add changelog section or reference to central changelog

---

### LOW-002: Missing Example Output

**Location**: Not present
**Issue**: Output format described but no concrete example
**Impact**: Inconsistent outputs, harder for orchestrator to parse
**Recommendation**: Add example:
```
## Example Output
HOTSPOTS:
  1. on_bar(): 2.3ms (47% of handler time) - 1200 calls
  2. calculate_position_size(): 0.8ms (16%) - 1200 calls

PROPOSED_CHANGE:
  - Cache ONNX session instead of reloading
  - Memoize position size for same parameters

EVIDENCE:
  - Before: on_bar() median 2.3ms, p99 4.1ms
  - After: on_bar() median 0.4ms, p99 0.9ms

RISK:
  - Cache invalidation if model changes mid-session
  - Memoization memory growth with many unique inputs

VALIDATION:
  - [ ] pytest passes
  - [ ] Manual test with 1-day backtest
  - [ ] Budget met (<1ms)
```

---

## Missing Capabilities Assessment

| Capability | Status | Priority |
|------------|--------|----------|
| Memory profiling | MISSING | HIGH |
| Async/concurrency optimization | MISSING | HIGH |
| Load testing guidance | MISSING | HIGH |
| GPU profiling (ONNX/CUDA) | MISSING | MEDIUM |
| Network latency profiling | MISSING | MEDIUM |
| Flame graph generation | MISSING | LOW |
| Distributed tracing | MISSING | LOW |

---

## Recommendations Summary

### Must Fix (Before Production Use)
1. **Resolve budget contradiction** - Clarify OnTick vs strategy handler budgets
2. **Add concurrency guardrails** - Prevent unsafe parallelization
3. **Add load testing requirements** - Ensure realistic profiling

### Should Fix
4. Add memory profiling guidance
5. Add escalation matrix
6. Add statistical rigor requirements
7. Define scope boundaries

### Nice to Have
8. Add example output
9. Add version history
10. Add flame graph tooling

---

## Verification Steps for Fixes

After fixes are applied:
1. Re-read spec and verify budget numbers are consistent throughout
2. Verify escalation paths cover all handoff agents in router
3. Run PERF_OPT on test case and verify output matches expected format
4. Check guardrails section explicitly mentions concurrency
5. Confirm memory profiling commands are syntactically correct

---

**Audit Status**: COMPLETE
**Auditor**: CRITIC
**Next Action**: Route findings to spec maintainer for review and fixes
