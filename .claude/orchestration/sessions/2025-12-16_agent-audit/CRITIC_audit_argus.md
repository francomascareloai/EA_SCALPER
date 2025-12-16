# CRITIC Adversarial Audit: ARGUS (argus-quant-researcher.xml)

**Audit Date**: 2025-12-16
**Auditor**: CRITIC Agent
**Target Spec**: `.claude/agents/argus-quant-researcher.xml`
**Spec Version**: 2.3
**CLAUDE.md Version**: 3.10.9

---

## Executive Summary

The ARGUS spec is a reasonably well-structured research agent specification with clear role definition, triangulation methodology, and workflow steps. However, it contains **1 CRITICAL**, **4 HIGH**, **5 MEDIUM**, and **4 LOW** severity issues that need addressing before production use.

The most urgent issue is a **direct contradiction with CLAUDE.md** regarding sub-agent spawning, which could cause runtime confusion or orchestration failures.

---

## Severity Counts

| Severity | Count |
|----------|-------|
| CRITICAL | 1 |
| HIGH | 4 |
| MEDIUM | 5 |
| LOW | 4 |
| **TOTAL** | **14** |

---

## CRITICAL Findings

### C1: Sub-Agent Delegation Violation

**Location**: `<thinking_protocol><delegation>` (line 36)
**Current Text**: "For large literature/code exploration: delegate to Explorer sub-agent, act on summary"
**Issue**: CLAUDE.md explicitly states in `<critic_gate><how_it_works>`: "Sub-agents cannot spawn other sub-agents."

This is a **direct contradiction** that would cause confusion during execution. ARGUS is always run as a sub-agent (per the router), so it cannot spawn Explorer.

**Impact**:
- Runtime confusion when ARGUS attempts forbidden delegation
- Potential infinite loops or orchestrator errors
- Breaks the sub-agent model

**Fix**:
```xml
<delegation>
  For large literature/code exploration, report back to orchestrator with a clear
  scope definition for a follow-up Explorer task. Do NOT attempt to spawn sub-agents
  directly. Use self-contained searches within session limits.
</delegation>
```

---

## HIGH Findings

### H1: Missing Structured Handoff Format

**Location**: `<output_template>` (lines 62-68)
**Issue**: CLAUDE.md `<structured_handoff>` requires specific fields when handing off to other agents:
- Context (task, files)
- Decisions Made (with rationale)
- Assumptions (with safety justification)
- Risks Identified (with mitigation)
- Open Questions
- Next Agent Should

ARGUS output_template only has: Claim, Verdict, Evidence, Applicability, Next step.

**Impact**: Information loss between agents, downstream agents missing critical context.

**Fix**: Add structured handoff block to output template:
```xml
<output_template>
  <!-- Existing fields -->
  <field>Claim</field>
  <field>Verdict: HIGH / MEDIUM / LOW / NOT_TRUSTED</field>
  <field>Evidence (3 sources): academic | code | empirical</field>
  <field>Applicability to EA_SCALPER_XAUUSD: impact + 1st/2nd/3rd-order risks</field>

  <!-- NEW: Structured handoff block -->
  <handoff>
    <context>Task performed + files analyzed</context>
    <decisions>Key decisions with rationale</decisions>
    <assumptions>Assumptions made and why safe</assumptions>
    <risks>Identified risks and mitigations</risks>
    <open_questions>Questions for downstream agent</open_questions>
    <next_agent_should>Specific actions for target agent</next_agent_should>
  </handoff>
</output_template>
```

### H2: Missing Version Reporting

**Location**: Entire spec (missing)
**Issue**: CLAUDE.md `<model_policy><version_reporting>` requires:
- Every sub-agent MUST include: `AGENT_VERSION: [version from spec header]`
- Output header with: AGENT, VERSION, CLAUDE_MD_VERSION, STATUS

ARGUS has no such instruction.

**Impact**: Cannot track which spec version produced outputs, makes debugging difficult.

**Fix**: Add to output_template:
```xml
<output_header mandatory="true">
  AGENT: ARGUS
  VERSION: 2.3
  CLAUDE_MD_VERSION: 3.10.9
  STATUS: COMPLETE | PARTIAL | FAILED
</output_header>
```

### H3: Incomplete Output Template vs CLAUDE.md Requirements

**Location**: `<output_template>` (lines 62-68)
**Issue**: Missing required fields:
1. Status field (COMPLETE/PARTIAL/FAILED)
2. Source citations format (how to list sources)
3. Open questions field
4. Assumptions field
5. Confidence score (only has verdict categories)

**Impact**: Outputs not compatible with orchestration expectations.

**Fix**: Expand output_template with all required fields.

### H4: No Error/Failure Handling Protocol

**Location**: Entire spec (missing)
**Issue**: No guidance on:
- What to return when research fails
- How to handle partial results
- When to abort vs continue with limited data
- Tool failure recovery

**Impact**: Undefined behavior when things go wrong.

**Fix**: Add error handling section:
```xml
<error_handling>
  <partial_success>
    Return STATUS: PARTIAL with:
    - What was found
    - What could not be found and why
    - Confidence impact
  </partial_success>
  <complete_failure>
    Return STATUS: FAILED with:
    - Attempted sources
    - Failure reasons
    - Recommended alternative approach
  </complete_failure>
  <tool_failures>
    <mcp_timeout>Retry once, then proceed with available evidence</mcp_timeout>
    <no_results>Log "No results from [tool]" and continue</no_results>
    <all_tools_fail>Return PARTIAL with explanation</all_tools_fail>
  </tool_failures>
</error_handling>
```

---

## MEDIUM Findings

### M1: Unclear Web Access Policy

**Location**: `<core>` line 22
**Current Text**: "web/GitHub (if allowed)"
**Issue**: What determines "if allowed"? Who allows it? Default policy?

**Fix**:
```xml
<web_access_policy>
  <default>Allowed unless user explicitly restricts</default>
  <check>Look for "no web", "offline", or "local only" in user context</check>
  <prefer>Local sources first, web for gaps only</prefer>
</web_access_policy>
```

### M2: No Search Depth/Time Budget

**Location**: `<workflow>` steps
**Issue**: Research can take infinite time with no stopping criteria.

**Fix**:
```xml
<search_limits>
  <papers>Max 10 relevant papers reviewed in depth</papers>
  <repos>Max 5 repositories analyzed</repos>
  <time_budget>30 min research before interim report</time_budget>
  <depth>If >3 citation levels deep, summarize and stop</depth>
</search_limits>
```

### M3: No "Out of Scope" Boundary Definition

**Location**: Entire spec (missing)
**Issue**: What should ARGUS refuse? When to redirect?

**Fix**:
```xml
<out_of_scope>
  <implementation_requests>Redirect to FORGE: "This requires implementation, not research"</implementation_requests>
  <risk_calculations>Redirect to SENTINEL: "Risk/sizing calculations are SENTINEL's domain"</risk_calculations>
  <strategy_design>Redirect to CRUCIBLE: "Strategy design/setup belongs to CRUCIBLE"</strategy_design>
  <non_trading>Redirect to DOCS or decline: "This is outside trading research scope"</non_trading>
</out_of_scope>
```

### M4: Missing Output File Protocol Reference

**Location**: Entire spec (missing)
**Issue**: CLAUDE.md `<orchestration_output_protocol>` requires heavy tasks write to session folders. ARGUS, being research-heavy, should comply.

**Fix**:
```xml
<output_protocol>
  <reference>See CLAUDE.md orchestration_output_protocol</reference>
  <heavy_research>Write complete analysis to session folder if research exceeds 500 words</heavy_research>
  <summary_to_chat>Return only 300-word summary with file path to chat</summary_to_chat>
</output_protocol>
```

### M5: CRITIC Self-Review Loop Not Explained

**Location**: `<critic_protocol>` (lines 70-82)
**Issue**: References critic file but doesn't explain the iterative fix-and-rerun loop per CLAUDE.md.

**Fix**:
```xml
<critic_protocol>
  <!-- Existing content -->
  <self_review_loop>
    1. Complete research/verdict
    2. Apply CRITIC techniques (INVERSION, ASSUMPTION AUDIT, PRE-MORTEM)
    3. If CRITICAL/HIGH issues found: fix and repeat step 2
    4. Only return output when confident verdict is defensible
    5. Include CRITIC notes in output
  </self_review_loop>
</critic_protocol>
```

---

## LOW Findings

### L1: No Input Validation

**Issue**: No handling for:
- Empty claim ("/research" with no topic)
- Non-trading research requests
- Already-implemented techniques

**Fix**:
```xml
<input_validation>
  <empty_input>Request: "Please specify a claim or topic to research"</empty_input>
  <non_trading>Redirect: "This appears non-trading-related. Consider DOCS agent."</non_trading>
  <pre_check>Before researching, verify if topic already exists in codebase via rg search</pre_check>
</input_validation>
```

### L2: No Source Age/Temporal Validity Guidance

**Issue**: A 2010 paper on HFT may be outdated. No guidance on assessing temporal relevance.

**Fix**:
```xml
<source_age>
  <preferred>Research from last 5 years (2020+)</preferred>
  <caution>5-10 years old: market regime may have changed</caution>
  <outdated>10+ years: require explicit justification for continued relevance</outdated>
  <check>Has market microstructure changed since publication?</check>
</source_age>
```

### L3: Fuzzy Confidence Level Boundaries

**Issue**: Difference between MEDIUM and LOW is unclear.
- MEDIUM: "2 strong sources, partial reproduction"
- LOW: "1 source or weak methodology"

What's "strong"? What's "partial reproduction"?

**Fix**: Add calibration examples:
```xml
<confidence_examples>
  <HIGH_example>Peer-reviewed paper + open-source implementation with tests + verified live results</HIGH_example>
  <MEDIUM_example>ArXiv preprint + GitHub repo (100+ stars) but no tests or live validation</MEDIUM_example>
  <LOW_example>Blog post with code snippets + no independent verification</LOW_example>
  <NOT_TRUSTED_example>Vendor claims 90% win rate with no methodology or data shared</NOT_TRUSTED_example>
</confidence_examples>
```

### L4: Missing XAUUSD-Specific Context

**Issue**: ARGUS should evaluate research applicability to XAUUSD/Apex but has no embedded context about XAUUSD characteristics.

**Fix**:
```xml
<xauusd_context>
  <spread>2-5 pips typical, spikes 10x during news</spread>
  <volatility>100-200 pips/day average, can exceed 500 during events</volatility>
  <sessions>Best liquidity: London/NY overlap (8-12 ET)</sessions>
  <apex_constraints>
    No overnight positions, close by 4:59 PM ET,
    5% trailing DD from HWM, 30% max profit/day for consistency
  </apex_constraints>
</xauusd_context>
```

---

## Additional Recommendations

### R1: Add Handoff Loop Prevention

```xml
<handoff_rules>
  <track_chain>Include "From: [agent/user], To: [target]" in output</track_chain>
  <no_return>If received from agent X, do not hand back to agent X</no_return>
  <max_depth>Max 3 handoffs before escalating to user</max_depth>
</handoff_rules>
```

### R2: Define DSR/PBO Abbreviations

Line 50 mentions "DSR/PBO" without definition. Add:
```xml
<abbreviations>
  <DSR>Deflated Sharpe Ratio - adjusts for multiple testing</DSR>
  <PBO>Probability of Backtest Overfitting</PBO>
</abbreviations>
```

### R3: Add Overlap Clarification with CRUCIBLE

```xml
<agent_boundaries>
  <crucible>Strategy DESIGN and SETUP (creating new strategies)</crucible>
  <argus>Research VALIDATION (evaluating existing claims/techniques)</argus>
  <overlap_resolution>
    If user wants to APPLY research to strategy design: ARGUS researches, hands to CRUCIBLE for design
    If user wants to VALIDATE existing strategy: goes directly to ORACLE
  </overlap_resolution>
</agent_boundaries>
```

---

## Proposed Updated Spec Structure

```xml
<agent version="2.4">
  <metadata>...</metadata>
  <identity>...</identity>
  <core>...</core>
  <inheritance>...</inheritance>

  <!-- NEW SECTIONS -->
  <input_validation>...</input_validation>
  <out_of_scope>...</out_of_scope>
  <web_access_policy>...</web_access_policy>
  <search_limits>...</search_limits>
  <source_age>...</source_age>
  <xauusd_context>...</xauusd_context>

  <thinking_protocol>
    <!-- Remove or rewrite delegation -->
  </thinking_protocol>

  <workflow>...</workflow>
  <confidence_heuristics>...</confidence_heuristics>
  <confidence_examples>...</confidence_examples>

  <output_template>
    <!-- Expanded with handoff, version, status -->
  </output_template>

  <output_protocol>...</output_protocol>
  <error_handling>...</error_handling>
  <handoff_rules>...</handoff_rules>

  <critic_protocol>
    <!-- Add self_review_loop -->
  </critic_protocol>

  <agent_boundaries>...</agent_boundaries>
</agent>
```

---

## Conclusion

ARGUS v2.3 is a solid foundation but needs updates to:
1. **Fix the CRITICAL sub-agent delegation violation** (immediate)
2. **Add CLAUDE.md compliance** for structured handoffs, version reporting, output formats
3. **Improve robustness** with error handling, input validation, search limits
4. **Enhance clarity** with boundary definitions and calibration examples

Recommended priority:
1. C1 (delegation violation) - BLOCK
2. H1-H4 (CLAUDE.md compliance) - HIGH
3. M1-M5 (robustness) - MEDIUM
4. L1-L4 (clarity) - LOW

---

**Audit Status**: COMPLETE
**Auditor**: CRITIC Agent
**Next Action**: Fix C1 immediately, then address HIGH findings before using ARGUS in production
