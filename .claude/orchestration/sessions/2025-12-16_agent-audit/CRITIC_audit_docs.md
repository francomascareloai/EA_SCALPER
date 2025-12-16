# CRITIC Adversarial Audit: trading-project-documenter.md

```
CRITIC ADVERSARIAL REVIEW
==========================
Artifact: .claude/agents/trading-project-documenter.md
Type: Agent Specification
Reviewer: CRITIC v1.1
Date: 2025-12-16
CLAUDE_MD_VERSION: 3.10.9

VERDICT: ISSUES_FOUND
```

---

## Executive Summary

The DOCS v1.1 agent specification is functional but lacks the rigor expected for a trading project where documentation accuracy directly impacts trading decisions and compliance. The spec is ~56 lines while comparable agents like CRITIC are ~375 lines - this disparity indicates missing structure.

| Severity | Count |
|----------|-------|
| CRITICAL | 3 |
| HIGH | 6 |
| MEDIUM | 7 |
| LOW | 4 |
| **TOTAL** | **20** |

---

## CRITICAL ISSUES (Must Fix)

### C1. Missing Command/Reproduction Verification Protocol

**Location:** Lines 39-40 (Final checklist)

**Issue:** The checklist says "Includes 'how to run' + 'how to validate' commands" but does NOT require VERIFICATION that these commands actually work before delivery.

**Impact:** Docs could include broken, deprecated, or incorrect commands. A user following bad commands could corrupt data, fail backtests, or misconfigure the trading system.

**Fix:** Add verification section:
```markdown
## Verification Protocol
Before delivering documentation:
- Run all `how to run` commands in e2b sandbox
- Verify output matches documented expectations
- For deterministic outputs, include hash/checksum
- Flag any commands that require environment-specific setup
```

---

### C2. No Security Guardrails

**Location:** Entire spec (missing section)

**Issue:** The spec has NO prohibition against documenting sensitive information. No mention of secrets, API keys, credentials, or proprietary algorithm details.

**Impact:** Agent could accidentally include API keys, account numbers, or trading credentials in public documentation. CLAUDE.md says "Never expose secrets/keys/credentials" but DOCS doesn't explicitly inherit this.

**Fix:** Add GUARDRAILS section:
```markdown
## GUARDRAILS (NEVER Do)
- NEVER document API keys, secrets, passwords, tokens
- NEVER include actual account numbers or trading credentials
- NEVER expose proprietary algorithm parameters (exact thresholds, trained model weights)
- NEVER document internal IP addresses, connection strings, or infrastructure details
- Before delivery: grep for patterns: API_KEY, SECRET, PASSWORD, TOKEN, PRIVATE
```

---

### C3. CRITIC Thought Count Inconsistency

**Location:** Line 51 (CRITIC Self-Review Protocol)

**Issue:** Spec says "Use sequential-thinking MCP (8-10 thoughts)" but the actual CRITIC spec (.claude/agents/critic-adversarial.md line 73) mandates "12-15 thoughts minimum".

**Impact:** Reduced review rigor. Documentation would receive ~30% less adversarial analysis than other artifacts.

**Fix:** Change line 51 to:
```markdown
2. Use sequential-thinking MCP (12-15 thoughts minimum, as per CRITIC v1.1 standard)
```

---

## HIGH ISSUES

### H1. Missing PROJECT CONTEXT Section

**Location:** Entire spec (missing section)

**Issue:** CRITIC spec includes detailed PROJECT CONTEXT with Apex non-negotiables table, validation thresholds, and NautilusTrader specifics. DOCS spec has NONE of this embedded context.

**Impact:** Agent must look up context each time, risking missing critical constraints. May produce docs that omit or incorrectly state Apex rules.

**Fix:** Add PROJECT CONTEXT section (copy from CRITIC spec):
```markdown
## PROJECT CONTEXT (CRITICAL - ALWAYS APPLY)

### Apex Non-Negotiables (MUST INCLUDE when relevant)
| Rule | Requirement |
|------|-------------|
| Trailing DD | 5% from HIGH-WATER MARK (includes unrealized!) |
| Overnight | PROHIBITED - close ALL by 4:59 PM ET |
| Time Gate | Block new trades after 4:30 PM ET |
| Emergency Close | Force-close from 4:55 PM ET |
| Consistency | Max 30% profit in single day |

### Validation Thresholds (MUST VERIFY in backtest docs)
| Metric | Minimum | Red Flag |
|--------|---------|----------|
| WFE | >=0.6 | <0.3 = FAIL |
| SQN | >=2.0 | >7.0 = suspicious |
| PSR | >=0.85 | <0.70 = FAIL |
| DSR | >0 | <=0 = OVERFITTED |
| PBO | <25% | >50% = FAIL |
| MC95 DD | <4% | >5% = FAIL |
```

---

### H2. Missing ESCALATION Section

**Location:** Entire spec (missing section)

**Issue:** No guidance on when to hand off to other agents. What if docs require code review, risk validation, or strategy clarification?

**Impact:** Agent may deliver docs without appropriate specialist review, leading to inaccurate technical documentation.

**Fix:** Add WHEN TO ESCALATE section:
```markdown
## WHEN TO ESCALATE
| Situation | Escalate To |
|-----------|-------------|
| Code examples need verification | FORGE |
| Risk/sizing/DD documentation | SENTINEL |
| Strategy logic documentation | CRUCIBLE |
| Backtest result documentation | ORACLE |
| Performance claims | PERF_OPT |
| Architecture docs | NAUTILUS |
```

---

### H3. Incomplete Deliverables Template

**Location:** Lines 28-33 (Deliverables template)

**Issue:** Template covers: Overview, Config/Parameters, Flow, Validation, Operations. Missing critical sections.

**Missing sections:**
- Changelog/Version History
- Dependencies (packages, libraries, versions)
- Error Handling (what errors, how handled, recovery)
- Testing (what tests, how to run, expected results)
- Security Considerations
- Maintenance Procedures

**Fix:** Expand template:
```markdown
## Deliverables (template)
- Overview: goal, scope, architecture (1 small ASCII diagram if useful)
- Config/Parameters: table (name, type, default, range, impact, risk)
- Dependencies: required packages, versions, data sources
- Flow: data -> signals -> risk/Apex -> execution -> logs
- Error Handling: possible errors, handling, recovery procedures
- Validation: backtest/WFA/MC + thresholds + sample requirements
- Testing: test commands, expected results, coverage
- Operations: time gates, circuit breakers, troubleshooting
- Changelog: version history, what changed, when
```

---

### H4. No Structured Output Format

**Location:** Lines 17-18 (Output section)

**Issue:** CRITIC has a detailed OUTPUT FORMAT section with structured template. DOCS just says "Output: doc patch + reproduction commands + next steps" - too vague.

**Impact:** Inconsistent documentation structure. No standard header, no versioning, no author attribution.

**Fix:** Add OUTPUT FORMAT section:
```markdown
## Output Format

Every documentation file MUST include:
```yaml
---
title: [Doc Title]
version: [e.g., 1.0.0]
last_updated: YYYY-MM-DD
last_verified: YYYY-MM-DD
author: [agent or human]
audience: [developer|operator|trader|auditor]
related: [list of related docs]
---
```

Body structure:
1. Purpose (1-2 sentences)
2. Prerequisites (what user needs before reading)
3. [Main content sections per template]
4. Related Documentation (cross-references)
5. Changelog (if not first version)
```

---

### H5. Missing Cross-Reference Validation

**Location:** Lines 42-43 (Final checklist)

**Issue:** When updating one doc, there's no protocol to check if other docs reference it and might now be inconsistent.

**Impact:** Documentation can become internally inconsistent. Old docs may reference renamed files, changed parameters, or deprecated features.

**Fix:** Add to checklist:
```markdown
- [ ] Cross-references verified: rg -n "filename" DOCS/ to find all references
- [ ] If doc renamed: update all referencing docs
- [ ] If parameters changed: update all docs that mention those parameters
```

---

### H6. Limited CRITIC Techniques in Self-Review

**Location:** Lines 52-53 (CRITIC Self-Review Protocol)

**Issue:** Self-review only applies INVERSION and ASSUMPTION AUDIT (2 of 7 CRITIC techniques). Missing: PRE-MORTEM, STRESS TEST, REGIME SHIFT, APEX TRAP, EDGE CASE.

**Impact:** Less rigorous self-review compared to other agents. May miss failure modes that other techniques would catch.

**Fix:** Expand line 52:
```markdown
3. Apply all 7 CRITIC techniques:
   - INVERSION ("how could this doc mislead the reader?")
   - PRE-MORTEM ("if someone fails because of this doc, why?")
   - STRESS TEST ("what if params are at extreme values?")
   - EDGE CASE ("what about empty/null/missing cases?")
   - ASSUMPTION AUDIT ("what am I assuming that might be wrong?")
   - APEX TRAP ("do I correctly state all Apex constraints?")
   - REGIME SHIFT ("does this doc work across market conditions?")
```

---

## MEDIUM ISSUES

### M1. Vague "When Relevant" for Apex Compliance

**Location:** Line 21 (INHERITS section), Line 42 (checklist)

**Issue:** "Apex non-negotiables (when relevant)" and "Mentions Apex non-negotiables when relevant" - WHO decides relevance?

**Fix:** Replace with explicit criteria:
```markdown
ALWAYS include Apex rules when documenting:
- Position sizing or lot calculations
- Risk parameters or DD limits
- Time-related settings (trading hours, sessions)
- Trade frequency or consistency rules
- Emergency procedures or circuit breakers
```

---

### M2. Missing Doc Versioning/Staleness Detection

**Location:** Entire spec (missing)

**Issue:** No protocol for detecting or marking stale documentation. Docs can become dangerously outdated.

**Fix:** Add freshness protocol:
```markdown
## Doc Freshness
- Every doc MUST have YAML frontmatter with `last_verified: YYYY-MM-DD`
- Docs older than 30 days: flag for review
- Docs older than 90 days: add STALE warning banner
- Link docs to source files; if source changes, flag doc for update
```

---

### M3. No Audience Definition Taxonomy

**Location:** Line 16 (Autonomy section)

**Issue:** Says "ask only if audience/scope/artifacts are missing" but doesn't define WHO the audiences are.

**Fix:** Add audience taxonomy:
```markdown
## Audience Types
| Audience | Focus | Detail Level |
|----------|-------|--------------|
| Developer | Implementation, code examples | High |
| Operator | Deployment, monitoring, troubleshooting | Medium |
| Trader | Usage, parameters, expected behavior | Low |
| Auditor | Compliance, validation, evidence | Medium |

If doc serves multiple audiences, add separate sections.
```

---

### M4. Checklist Too Short

**Location:** Lines 39-43 (Final checklist)

**Issue:** Only 4 checklist items. CRITIC and ORACLE have 20+ items. Documentation quality requires more thorough checklist.

**Fix:** Expand to ~10 items:
```markdown
## Final Checklist
- [ ] Includes "how to run" + "how to validate" commands
- [ ] Commands verified to actually work (tested in sandbox)
- [ ] No sensitive information (secrets, API keys, credentials)
- [ ] Includes realistic costs (spread/slippage) where applicable
- [ ] Mentions Apex non-negotiables where applicable
- [ ] Avoids duplication and updates DOCS/_INDEX.md
- [ ] Cross-references verified (no broken links)
- [ ] Version/date stamp in YAML frontmatter
- [ ] Prerequisites clearly listed
- [ ] Known limitations documented
```

---

### M5. No Multi-Audience Template Support

**Location:** Lines 28-33 (Deliverables template)

**Issue:** Single template structure may not serve all audiences. A developer and a trader need different information.

**Fix:** Add audience-specific section guidance:
```markdown
For multi-audience docs, add optional sections:
## For Developers
[Technical implementation details, code snippets]

## For Operators
[Deployment, monitoring, log locations]

## For Traders
[High-level usage, parameter tuning guidance]
```

---

### M6. Missing Proactive Behavior

**Location:** Entire spec (missing section)

**Issue:** CRITIC has PROACTIVE BEHAVIOR table (detect X -> do Y). DOCS has none.

**Fix:** Add section:
```markdown
## Proactive Behavior
| Detect | Action |
|--------|--------|
| Code file modified | "Checking if docs need update..." |
| New feature/module added | "Documentation needed. Drafting..." |
| Backtest completed | "Should results be documented?" |
| "document", "docs", "guide" | Begin documentation workflow |
```

---

### M7. No Loop/Retry in Self-Review

**Location:** Lines 47-55 (CRITIC Self-Review Protocol)

**Issue:** CRITIC spec says "Loop until CRITIC returns PASS_WITH_NOTES" but DOCS just says "Only deliver when confident." No iteration protocol.

**Fix:** Add iteration requirement:
```markdown
6. If issues found during self-review:
   - Fix issues
   - Re-run self-review (steps 2-5)
   - Repeat until no CRITICAL/HIGH issues remain
7. Only deliver when confident documentation is accurate and complete
```

---

## LOW ISSUES

### L1. No Archival/Deprecation Protocol

**Location:** Entire spec (missing)

**Issue:** No guidance on what to do when a feature is deprecated and its docs become obsolete.

**Fix:** Add:
```markdown
## Archival Protocol
- Deprecated docs: move to DOCS/archive/
- Add deprecation notice with date and reason
- Update _INDEX.md to remove from active list
- Add redirect note if replacement doc exists
```

---

### L2. Missing Performance/Scaling Section in Template

**Location:** Lines 28-33 (Deliverables template)

**Issue:** No guidance on documenting performance characteristics, resource requirements, or scaling considerations.

**Fix:** Add to template:
```markdown
- Performance: expected latency, resource usage, scaling limits
```

---

### L3. No Diagram/ASCII Art Guidelines

**Location:** Line 29 (template mentions "1 small ASCII diagram if useful")

**Issue:** No guidelines on ASCII diagram size, style, or maintenance.

**Fix:** Add:
```markdown
ASCII diagrams:
- Max width: 60 characters (fits in terminal/narrow views)
- Use simple box-drawing characters: +, -, |, >, <
- Include legend if symbols are non-obvious
- Keep diagrams simple - complex diagrams become unreadable
```

---

### L4. No Error Catalog Format Guidance

**Location:** Line 33 (Operations: troubleshooting)

**Issue:** Troubleshooting mentioned but no structured format for documenting errors.

**Fix:** Add:
```markdown
Error documentation format:
| Error Code | Message | Cause | Resolution |
|------------|---------|-------|------------|
| E001 | ... | ... | ... |

Central error catalog: DOCS/06_REFERENCE/ERROR_CODES.md
```

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| "Search first: rg" | Assumes ripgrep available, DOCS/ exists | Add fallback: "or grep -r" |
| "One home per topic" | Topics overlap (Apex applies everywhere) | Allow cross-references, avoid artificial boundaries |
| "Good docs are reproducible" | ML training is stochastic | Document seeds, note non-determinism |
| "Inherits from CLAUDE.md" | CLAUDE.md could change | Embed critical rules directly in spec |
| "Max signal, minimal narrative" | New users need context | Add "Prerequisites" section to template |
| "Update DOCS/_INDEX.md" | _INDEX format unknown | Provide format template |

---

## EDGE CASES TESTED

| Edge Case | Result |
|-----------|--------|
| Documentation for unreleased/experimental features | NO guidance on marking "draft" or "experimental" |
| Documentation spanning Python + MQL5 | Single template, no cross-language format |
| Sensitive trading parameters | NO security classification |
| Historical/deprecated docs | NO archival protocol |
| Empty states (nothing to document yet) | NO "N/A" or "pending" guidance |
| DOCS/_INDEX.md doesn't exist | NO guidance on creating it |
| Multiple docs cover overlapping topics | NO consolidation protocol |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| 50+ parameters to document | Template would create wall of text; no grouping guidance |
| Code has no tests yet | Checklist says include validation but no "pending" option |
| Heavy docs generation (many docs at once) | No quality threshold or rate limiting |
| CLAUDE.md inheritance fails | No fallback behavior specified |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify DOCS/_INDEX.md format and update spec accordingly
- [ ] Confirm which docs require Apex compliance mentions
- [ ] Review existing docs for security issues (secrets exposure)
- [ ] Validate that template covers all doc types in project

---

## PRE-MORTEM SUMMARY

**Most likely failure mode:** User follows documented command that doesn't work (not verified before delivery), misconfigures system, causes bad backtest or trading loss.

**Second most likely:** Documentation includes sensitive information (API keys, account details) that gets committed to public repo.

**Third most likely:** Docs become stale, user follows outdated Apex rules (wrong time gates, wrong DD thresholds), account terminated.

**Mitigation:**
1. Add command verification protocol (CRITICAL fix C1)
2. Add security guardrails (CRITICAL fix C2)
3. Add freshness/staleness protocol (MEDIUM fix M2)

---

## CONFIDENCE: HIGH

**Reason:**
- Direct comparison with CRITIC spec (same project)
- All gaps are concrete and verifiable
- Recommendations are specific and actionable
- Analysis based on 15 sequential thoughts with 7 adversarial techniques

---

## RECOMMENDED VERSION UPDATE

Current: DOCS v1.1
Recommended after fixes: DOCS v1.2

### Priority Order for Fixes:
1. C1 (Command Verification) - Immediate
2. C2 (Security Guardrails) - Immediate
3. C3 (CRITIC Thought Count) - Immediate
4. H1 (PROJECT CONTEXT) - This week
5. H2 (ESCALATION) - This week
6. H3-H6 (Other HIGH) - This week
7. M1-M7 (MEDIUM) - Next iteration
8. L1-L4 (LOW) - When convenient

---

*CRITIC v1.1 - Adversarial Quality Guardian*
*"Every bug found now is a loss prevented later."*
