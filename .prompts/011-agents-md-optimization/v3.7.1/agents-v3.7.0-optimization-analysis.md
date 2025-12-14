# AGENTS.md v3.7.0 Optimization Analysis

## Current State (v3.7.0)

### Metrics
- **Line count:** 1,098 lines
- **File size:** 65,480 bytes (65KB)
- **Estimated tokens:** ~16,250 tokens
- **Version:** 3.7.0
- **Last updated:** 2025-12-08

### Major Sections
1. metadata
2. identity
3. quick_reference
4. platform_support
5. strategic_intelligence (~350 lines)
6. agent_routing
7. knowledge_map
8. critical_context
  - apex_trading
  - **drawdown_protection (~200 lines - MAIN CULPRIT)**
  - performance_limits
  - ml_thresholds
  - forge_rule
  - powershell_critical
9. error_recovery
10. critical_bug_protocol (~100 lines)
11. session_rules
12. mql5_compilation
13. windows_cli
14. observability
15. document_hygiene
16. best_practices
17. git_workflow
18. appendix

## Findings

### Redundancies Detected

#### 1. drawdown_protection Section (~200 lines → Target: 60 lines, 70% reduction)
**Issue:** Massive v3.7.0 addition with extreme verbosity
- **daily_dd_limits:** 4 tiers with verbose `<response>`, `<rationale>`, `<recovery>` nested tags
- **total_dd_limits:** 5 tiers with same verbose pattern
- **dynamic_daily_limit:** 3 complete examples with full calculations (fresh_account, warning_level, critical_level)
- **recovery_strategy:** Multi-day scenario with verbose day-by-day breakdown + comparison section
- **sentinel_enforcement:** 6 rules that can be consolidated to 3

**Savings Estimate:** 140 lines (200 → 60)

**Optimization Strategy:**
- Convert tier `<response>` and `<rationale>` from nested tags to XML attributes
- Remove 2 of 3 dynamic_daily_limit examples (keep fresh_account baseline)
- Compress recovery_strategy from multi-paragraph to inline bullet points
- Consolidate sentinel_enforcement from 6 rules to 3

#### 2. priority_hierarchy Resolution Examples (3 → Target: 1)
**Issue:** 3 complete verbose examples (performance_vs_maintainability, apex_vs_performance, safety_vs_elegance)
- Each example has scenario, analysis, resolution, rule fields
- Examples are repetitive - all demonstrate same principle

**Savings Estimate:** ~40 lines (keep 1 representative example)

**Optimization Strategy:**
- Keep apex_vs_performance (most critical for Apex Trading)
- Remove other 2 examples

#### 3. critical_bug_protocol Examples (2 → Target: 1)
**Issue:** 2 complete examples (CRITICAL: unrealized_pnl_ignored, HIGH: timezone_assumption)
- Each has bug, impact, root_cause_chain (5 whys), prevention (4 items)
- ~50 lines per example

**Savings Estimate:** ~50 lines (remove 1 example)

**Optimization Strategy:**
- Keep CRITICAL example (unrealized_pnl_ignored) - most relevant to Apex
- Remove HIGH example (timezone_assumption)

#### 4. code_change_tracking::future_improvements_tracking (~40 → Target: 15 lines)
**Issue:** Verbose explanations of when_to_add, never_add, entry_format, status_transitions
- Multiple nested `<trigger>` tags with detailed descriptions
- Verbose philosophy section

**Savings Estimate:** 25 lines

**Optimization Strategy:**
- Consolidate when_to_add from 6 separate `<trigger>` tags to single inline text
- Consolidate never_add from 3 `<scenario>` tags to single inline text
- Compress entry_format from 5 `<required>` tags to single inline text
- Compress status_transitions to single line

#### 5. quality_gates Verbose Descriptions
**Issue:** pre_trade_checklist, trading_logic_review, pre_deploy_validation have verbose `<description>` and `<enforcement>` sections

**Savings Estimate:** ~20 lines

**Optimization Strategy:**
- Keep structure but compress verbose prose to concise directives

## Optimization Plan

### Phase 1: Structural Compression
1. **drawdown_protection section** (200 → 60 lines):
   - Convert verbose nested tags to XML attributes for tiers
   - Remove 2 of 3 dynamic_daily_limit examples
   - Compress recovery_strategy from multi-paragraph to inline
   - Consolidate sentinel_enforcement from 6 → 3 rules

### Phase 2: Example Reduction
2. **priority_hierarchy** (3 → 1 example): Remove 2 verbose examples
3. **critical_bug_protocol** (2 → 1 example): Remove HIGH example, keep CRITICAL

### Phase 3: Template Optimization
4. **code_change_tracking::future_improvements_tracking** (40 → 15 lines):
   - Consolidate verbose nested tags to inline text
   - Compress philosophy to single line

5. **quality_gates** compression:
   - Keep structure but reduce verbose prose

### Phase 4: Content Deduplication
6. Remove repeated "Apex limit 5%" mentions (consolidate to quick_reference)
7. Remove redundant validation mentions (already in forge_rule)

### Phase 5: Prose Reduction
8. Convert explanatory prose to concise directives throughout
9. Remove motivational/philosophical content

## Projected Outcome

### Target Metrics
- **Target line count:** ~650 lines (40% reduction from 1,098)
- **Target file size:** ~40KB (38% reduction from 65KB)
- **Target tokens:** ~11,000 tokens (32% reduction from ~16,250)

### Reduction Breakdown
| Section | Before | After | Savings |
|---------|--------|-------|---------|
| drawdown_protection | 200 | 60 | 140 lines (70%) |
| priority_hierarchy examples | 60 | 20 | 40 lines |
| critical_bug_protocol examples | 100 | 50 | 50 lines |
| future_improvements_tracking | 40 | 15 | 25 lines |
| quality_gates descriptions | 60 | 40 | 20 lines |
| Misc redundancies | 180 | 115 | 65 lines |
| **TOTAL** | **1,098** | **~650** | **~450 lines (41%)** |

## Critical Content to Preserve (100%)

### Must Preserve Exactly
- All 7 agent identities, triggers, and MCPs
- All Apex Trading constraints (5% trailing DD, 4:59 PM ET, 30% consistency, no overnight)
- All 7 mandatory reflection questions
- All complexity levels with requirements
- All handoff gates and enforcement rules
- Multi-tier DD protection functionality (daily + total DD limits)
- Dynamic daily limit formula
- Recovery strategy concept
- Platform support (Nautilus/MQL5) routing rules

### Can Compress (But Must Preserve Functionality)
- Examples (keep 1-2 best per concept)
- Verbose explanations (convert to concise directives)
- Redundant warnings (state once, reference elsewhere)
- Long nested XML (convert to attributes where possible)

## Risks

### Low Risk
- Example reduction: 1 representative example per concept is sufficient
- Prose compression: Directives are clearer than verbose explanations
- XML attribute conversion: Same information, more compact format

### Mitigation
- Validate ALL v3.7.0 critical functionality preserved
- Test agent routing with sample commands after optimization
- Keep backup AGENTS.md.backup for rollback capability

## Next Steps

1. **Execute optimization** following 5-phase plan
2. **Generate optimized file** AGENTS-optimized-v3.7.1.md
3. **Validate preservation** of all critical functionality
4. **Create comparison report** with before/after metrics
5. **Test agent routing** to ensure no regressions
6. **Create SUMMARY.md** with deployment plan
