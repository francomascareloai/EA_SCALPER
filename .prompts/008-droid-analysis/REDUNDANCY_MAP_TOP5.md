# LAYER 1: TOP 5 Droids Redundancy Mapping

**Analysis Date:** 2025-12-07
**Analyst:** Elite Quantitative Research Analyst (deep-researcher subagent)
**Confidence:** HIGH (comprehensive file analysis + AGENTS.md v3.4 comparison)

---

## Executive Summary

| Droid | Current Size | Redundancy | Unique Domain Knowledge | Projected After | Savings |
|-------|--------------|------------|-------------------------|-----------------|---------|
| NAUTILUS | 53KB | 70% (~37KB) | 16KB (migration, patterns) | 16KB | 37KB (70%) |
| ORACLE | 38KB | 68% (~26KB) | 12KB (WFA, Monte Carlo) | 12KB | 26KB (68%) |
| FORGE | 37KB | 65% (~24KB) | 13KB (Deep Debug, Context7) | 13KB | 24KB (65%) |
| SENTINEL-APEX | 37KB | 60% (~22KB) | 15KB (Apex formulas) | 15KB | 22KB (60%) |
| RESEARCH | 31KB | 72% (~22KB) | 9KB (triangulation) | 9KB | 22KB (71%) |
| **TOTAL** | **196KB** | **~131KB** | **65KB** | **65KB** | **131KB (67%)** |

**Token Impact:** ~32,750 tokens saved (131KB ÷ 4 bytes/token)

---

## Per-Droid Analysis

### 1. NAUTILUS (nautilus-trader-architect.md) - 53KB

#### A. Redundant Sections (to remove - inherit from AGENTS.md)

| Section | Lines | Size Est. | Maps to AGENTS.md |
|---------|-------|-----------|-------------------|
| `<core_principles>` (10 mandamentos) | ~30 | 2KB | `<core_principles>` general rules |
| ASCII art banner | ~15 | 1KB | Not needed in runtime |
| `<guardrails>` 12 NEVER rules | ~30 | 2KB | `<python_nautilus_guardrails>` + inherited |
| `<proactive_behavior>` table | ~20 | 1.5KB | `<proactive_triggers>` inherited |
| Generic error handling patterns | ~100 | 8KB | `<error_recovery>` in AGENTS.md |
| Generic logging/output formats | ~50 | 4KB | `<output_format>` inherited |
| `<skills_integration>` handoff descriptions | ~60 | 5KB | `<handoffs>` simplified |
| Generic principles repeated | ~100 | 8KB | `<strategic_intelligence>` inherited |
| Performance targets (generic) | ~20 | 1.5KB | Can be in config |
| **SUBTOTAL REDUNDANT** | **~425** | **~37KB** | |

#### B. Unique Domain Knowledge (KEEP)

| Section | Lines | Size Est. | Why Essential |
|---------|-------|-----------|---------------|
| `<mql5_mapping>` complete tables | ~150 | 12KB | **CRITICAL** - OnInit→on_start, OrderSend→submit_order |
| `<decision_tree>` Strategy vs Actor | ~50 | 4KB | **CRITICAL** - Architecture decision guide |
| `<code_patterns>` Strategy template | ~100 | 8KB | **HIGH** - Ready-to-use templates |
| `<code_patterns>` Actor template | ~60 | 5KB | **HIGH** - Data processing patterns |
| `<code_patterns>` Backtest setup | ~80 | 6KB | **HIGH** - ParquetDataCatalog config |
| `<nautilus_trader_architecture>` diagram | ~50 | 4KB | **MEDIUM** - System overview |
| `<event_flow>` Order lifecycle | ~40 | 3KB | **MEDIUM** - Event understanding |
| Project structure `nautilus_gold_scalper/` | ~40 | 3KB | **MEDIUM** - Project-specific |
| Migration streams A-H status | ~30 | 2KB | **MEDIUM** - Project tracking |
| Anti-patterns NAP-01 to NAP-10 | ~40 | 3KB | **HIGH** - Nautilus-specific pitfalls |
| Performance targets (Nautilus-specific) | ~20 | 1.5KB | **HIGH** - on_bar <1ms, on_tick <100μs |

#### C. Additional Reflection Questions (for AGENTS.md)

```xml
<agent name="NAUTILUS">
  <additional_reflection_questions>
    <question id="18" category="nautilus_specific">
      Am I using Strategy or Actor pattern correctly for this use case?
      Check: Does this component TRADE? → Strategy. Only PROCESS data? → Actor.
    </question>
    <question id="19" category="nautilus_specific">
      Does my on_bar handler complete in <1ms?
      Profile: Use cProfile, ensure numpy for calculations, no object creation in hot path.
    </question>
    <question id="20" category="nautilus_specific">
      Am I correctly handling the NautilusTrader lifecycle?
      Check: super().__init__() called? on_stop cleanup? indicator.initialized checked?
    </question>
  </additional_reflection_questions>
</agent>
```

#### D. Savings Calculation

- **Before:** 53KB
- **Remove:** 37KB (redundant generic protocols)
- **Keep:** 16KB (domain knowledge)
- **After:** 16KB
- **Savings:** 37KB (70%)

---

### 2. ORACLE (oracle-backtest-commander.md) - 38KB

#### A. Redundant Sections (to remove)

| Section | Lines | Size Est. | Maps to AGENTS.md |
|---------|-------|-----------|-------------------|
| ASCII banner | ~15 | 1KB | Not needed |
| `<personality>` traits | ~10 | 0.5KB | Generic agent config |
| `<prime_directive>` general | ~20 | 1.5KB | `<mission>` inherited |
| `<core_principles>` 10 rules | ~40 | 3KB | `<strategic_intelligence>` |
| Generic output templates | ~100 | 8KB | `<output_format>` inherited |
| `<proactive_behavior>` triggers | ~40 | 3KB | `<proactive_triggers>` inherited |
| Generic validation patterns | ~80 | 6KB | `<validation_checklist>` inherited |
| `<guardrails>` NEVER rules | ~30 | 2KB | Inherited from base |
| **SUBTOTAL REDUNDANT** | **~335** | **~26KB** | |

#### B. Unique Domain Knowledge (KEEP)

| Section | Lines | Size Est. | Why Essential |
|---------|-------|-----------|---------------|
| `<statistical_thresholds>` complete | ~100 | 8KB | **CRITICAL** - WFE≥0.6, DSR>0, PSR≥0.85 |
| `<apex_trading_expertise>` rules | ~30 | 2KB | **CRITICAL** - 10% trailing, 4:59 PM ET |
| Walk-Forward Analysis workflow | ~60 | 5KB | **CRITICAL** - 12 windows, IS/OOS split |
| Monte Carlo specification | ~40 | 3KB | **CRITICAL** - Block bootstrap, 5000 runs |
| GO/NO-GO 7-step checklist | ~50 | 4KB | **CRITICAL** - Decision framework |
| Python `StatisticalValidator` class | ~80 | 6KB | **HIGH** - WFE, PSR, DSR calculations |
| Suspicious patterns detection | ~30 | 2KB | **HIGH** - Sharpe>3.5, WinRate>80% |
| `<complementary_roles>` with CRUCIBLE | ~20 | 1.5KB | **MEDIUM** - Handoff clarity |

#### C. Additional Reflection Questions

```xml
<agent name="ORACLE">
  <additional_reflection_questions>
    <question id="21" category="backtest_specific">
      Did I validate with Walk-Forward Analysis (WFE ≥ 0.6)?
      NO WFA = NO GO decision possible. In-sample only is INVALID.
    </question>
    <question id="22" category="backtest_specific">
      Is DSR (Deflated Sharpe Ratio) > 0?
      DSR < 0 = CONFIRMED OVERFITTING. Reject strategy immediately.
    </question>
    <question id="23" category="backtest_specific">
      What's the Monte Carlo 95th percentile max DD?
      Must be below Apex 10% trailing limit. Target <8% with safety buffer.
    </question>
  </additional_reflection_questions>
</agent>
```

#### D. Savings Calculation

- **Before:** 38KB
- **Remove:** 26KB (redundant)
- **Keep:** 12KB (domain knowledge)
- **After:** 12KB
- **Savings:** 26KB (68%)

---

### 3. FORGE (forge-mql5-architect.md) - 37KB

#### A. Redundant Sections (to remove)

| Section | Lines | Size Est. | Maps to AGENTS.md |
|---------|-------|-----------|-------------------|
| ASCII banner | ~12 | 0.8KB | Not needed |
| `<mission>` REGRA ZERO | ~10 | 0.6KB | Mission inherited |
| `<principles>` 10 rules | ~25 | 2KB | `<core_principles>` inherited |
| Generic coding standards | ~60 | 5KB | `<coding_standards>` inherited |
| Generic error handling | ~80 | 6KB | `<error_recovery>` inherited |
| `<code_review>` 20-item checklist | ~60 | 5KB | Can be shared REVIEWER template |
| `<constraints>` NEVER rules | ~40 | 3KB | Inherited guardrails |
| Generic output templates | ~40 | 3KB | `<output_format>` inherited |
| **SUBTOTAL REDUNDANT** | **~327** | **~24KB** | |

#### B. Unique Domain Knowledge (KEEP)

| Section | Lines | Size Est. | Why Essential |
|---------|-------|-----------|---------------|
| `<anti_patterns>` AP-01 to AP-12 | ~50 | 4KB | **CRITICAL** - Python/Nautilus pitfalls |
| P0.1 DEEP DEBUG protocol | ~40 | 3KB | **CRITICAL** - Hypothesis ranking methodology |
| P0.2 CODE + TEST protocol | ~30 | 2KB | **HIGH** - Always deliver with tests |
| P0.3 SELF-CORRECTION 7 checks | ~30 | 2KB | **HIGH** - Pre-delivery validation |
| P0.6 CONTEXT FIRST protocol | ~40 | 3KB | **CRITICAL** - Context7 mandatory query |
| `<nautilus_patterns>` lifecycle | ~50 | 4KB | **HIGH** - Strategy/Actor/Indicator |
| `<context7_queries>` templates | ~30 | 2KB | **HIGH** - Ready-to-use queries |
| BUGFIX_LOG format | ~15 | 1KB | **MEDIUM** - Bug tracking |

#### C. Additional Reflection Questions

```xml
<agent name="FORGE">
  <additional_reflection_questions>
    <question id="24" category="implementation_specific">
      Did I query Context7 NautilusTrader docs BEFORE implementing?
      MANDATORY for any Nautilus feature. Documentation-driven development.
    </question>
    <question id="25" category="implementation_specific">
      Did I deliver CODE + TEST together?
      Every .py file MUST have corresponding test_*.py file.
    </question>
    <question id="26" category="implementation_specific">
      Did I run the 7 self-correction checks before delivering?
      Error handling? Type hints? Null checks? Cleanup? Prop firm? Regression? Nautilus patterns?
    </question>
  </additional_reflection_questions>
</agent>
```

#### D. Savings Calculation

- **Before:** 37KB
- **Remove:** 24KB (redundant)
- **Keep:** 13KB (domain knowledge)
- **After:** 13KB
- **Savings:** 24KB (65%)

---

### 4. SENTINEL-APEX (sentinel-apex-guardian.md) - 37KB

#### A. Redundant Sections (to remove)

| Section | Lines | Size Est. | Maps to AGENTS.md |
|---------|-------|-----------|-------------------|
| ASCII banner | ~12 | 0.8KB | Not needed |
| `<personality>` traits | ~10 | 0.6KB | Generic config |
| `<core_principles>` 10 rules | ~25 | 2KB | `<strategic_intelligence>` inherited |
| Generic output templates | ~80 | 6KB | `<output_format>` inherited |
| `<time_zones>` conversion info | ~30 | 2KB | Can be utility function |
| `<account_examples>` | ~30 | 2KB | Can be config/documentation |
| `<typical_phrases>` | ~20 | 1.5KB | Personality inherited |
| `<constraints>` NEVER rules | ~30 | 2KB | Inherited guardrails |
| Handoffs descriptions | ~20 | 1.5KB | Simplified in AGENTS.md |
| State machine diagram (text) | ~30 | 2KB | Can be visual reference |
| **SUBTOTAL REDUNDANT** | **~287** | **~22KB** | |

#### B. Unique Domain Knowledge (KEEP)

| Section | Lines | Size Est. | Why Essential |
|---------|-------|-----------|---------------|
| `<apex_limits>` complete rules | ~40 | 3KB | **CRITICAL** - 10% trailing, 4:59 PM, 30% |
| `<apex_vs_ftmo>` comparison | ~25 | 2KB | **CRITICAL** - Apex ≠ FTMO |
| `<circuit_breaker>` 5 levels | ~50 | 4KB | **CRITICAL** - Level 0-4 definitions |
| `/lot` workflow with multipliers | ~60 | 5KB | **CRITICAL** - Trailing + Time multipliers |
| `/trailing` DD monitor | ~40 | 3KB | **CRITICAL** - HWM includes unrealized |
| `/overnight` time check | ~30 | 2KB | **CRITICAL** - 4:59 PM ET deadline |
| `/consistency` 30% rule | ~20 | 1.5KB | **HIGH** - Max profit per day |
| Formulas (lot sizing, trailing DD) | ~30 | 2KB | **CRITICAL** - Mathematical definitions |
| `<automatic_alerts>` triggers | ~30 | 2KB | **HIGH** - When to alert |

#### C. Additional Reflection Questions

```xml
<agent name="SENTINEL">
  <additional_reflection_questions>
    <question id="27" category="risk_specific">
      Am I calculating trailing DD from HIGH-WATER MARK (not starting balance)?
      HWM includes UNREALIZED P&L. A floating $1k profit RAISES your floor by $1k.
    </question>
    <question id="28" category="risk_specific">
      Is there sufficient time before 4:59 PM ET deadline?
      Apply time multiplier: <30min = 0%, 30min-1h = 0.5, 1h-2h = 0.7, >3h = 1.0
    </question>
    <question id="29" category="risk_specific">
      Would this trade breach the 30% consistency rule?
      Max profit/day = 30% of profit target. Check before taking high-reward trades.
    </question>
  </additional_reflection_questions>
</agent>
```

#### D. Savings Calculation

- **Before:** 37KB
- **Remove:** 22KB (redundant)
- **Keep:** 15KB (domain knowledge)
- **After:** 15KB
- **Savings:** 22KB (60%)

---

### 5. RESEARCH-ANALYST-PRO (research-analyst-pro.md) - 31KB

#### A. Redundant Sections (to remove)

| Section | Lines | Size Est. | Maps to AGENTS.md |
|---------|-------|-----------|-------------------|
| `<role>` description | ~10 | 0.6KB | Inherited |
| `<expertise>` domains | ~15 | 1KB | Inherited |
| `<personality>` traits | ~10 | 0.6KB | Inherited |
| `<mission>` description | ~15 | 1KB | Inherited |
| `<constraints>` MUST/NEVER | ~30 | 2KB | Inherited from `<guardrails>` |
| Generic workflow templates | ~150 | 12KB | `<research_workflow>` can be skill |
| Generic report structure | ~80 | 6KB | Template can be separate |
| Quality assurance checklist | ~40 | 3KB | `<quality_monitoring>` inherited |
| **SUBTOTAL REDUNDANT** | **~350** | **~22KB** | |

#### B. Unique Domain Knowledge (KEEP)

| Section | Lines | Size Est. | Why Essential |
|---------|-------|-----------|---------------|
| `<methodology>` 8-step research | ~40 | 3KB | **HIGH** - Structured approach |
| Source evaluation criteria | ~30 | 2KB | **CRITICAL** - Credibility/relevance |
| Multi-source triangulation | ~40 | 3KB | **CRITICAL** - 3+ sources requirement |
| Confidence level framework | ~30 | 2KB | **CRITICAL** - HIGH/MEDIUM/LOW |
| `<decision_frameworks>` 5 tools | ~40 | 3KB | **HIGH** - RCR weighting, scenarios |
| `<edge_cases>` handling | ~30 | 2KB | **MEDIUM** - Conflicting sources |

#### C. Additional Reflection Questions

```xml
<agent name="RESEARCH">
  <additional_reflection_questions>
    <question id="30" category="research_specific">
      Did I triangulate with 3+ independent sources?
      Single-source claims are NOT trusted. Academic + Practical + Empirical.
    </question>
    <question id="31" category="research_specific">
      Did I explicitly state confidence level with justification?
      HIGH (3+ agree), MEDIUM (2), LOW (conflicting). Never omit.
    </question>
    <question id="32" category="research_specific">
      Did I search for CONTRADICTING evidence, not just confirming?
      Bias: Looking only for what confirms hypothesis. Actively seek counter-evidence.
    </question>
  </additional_reflection_questions>
</agent>
```

#### D. Savings Calculation

- **Before:** 31KB
- **Remove:** 22KB (redundant)
- **Keep:** 9KB (domain knowledge)
- **After:** 9KB
- **Savings:** 22KB (71%)

---

## Inheritance Map

```yaml
# How refactored droids inherit from AGENTS.md

NAUTILUS:
  inherits_from: "AGENTS.md v3.4"
  inherited_sections:
    - strategic_intelligence (full)
    - genius_mode_templates.new_feature_analysis
    - genius_mode_templates.code_review_critical
    - enforcement_validation
    - pattern_learning
    - error_recovery
  domain_specific:
    - mql5_mapping (unique)
    - nautilus_patterns (unique)
    - strategy_templates (unique)
    - performance_targets (Nautilus-specific)
  additional_questions: [Q18, Q19, Q20]

ORACLE:
  inherits_from: "AGENTS.md v3.4"
  inherited_sections:
    - strategic_intelligence (full)
    - genius_mode_templates.architecture_decision
    - enforcement_validation
    - feedback_loop
  domain_specific:
    - statistical_thresholds (unique)
    - wfa_methodology (unique)
    - monte_carlo_spec (unique)
    - go_nogo_checklist (unique)
  additional_questions: [Q21, Q22, Q23]

FORGE:
  inherits_from: "AGENTS.md v3.4"
  inherited_sections:
    - strategic_intelligence (full)
    - genius_mode_templates.bug_fix_root_cause
    - pattern_learning
    - error_recovery
  domain_specific:
    - anti_patterns (unique)
    - deep_debug_protocol (unique)
    - context7_integration (unique)
    - self_correction_checks (unique)
  additional_questions: [Q24, Q25, Q26]

SENTINEL:
  inherits_from: "AGENTS.md v3.4"
  inherited_sections:
    - strategic_intelligence (partial)
    - enforcement_validation
    - emergency_mode (from compressed_protocols)
  domain_specific:
    - apex_rules (unique)
    - circuit_breaker_levels (unique)
    - lot_sizing_formulas (unique)
    - trailing_dd_calculation (unique)
  additional_questions: [Q27, Q28, Q29]

RESEARCH:
  inherits_from: "AGENTS.md v3.4"
  inherited_sections:
    - strategic_intelligence (full)
    - quality_monitoring
  domain_specific:
    - triangulation_methodology (unique)
    - confidence_levels (unique)
    - source_evaluation (unique)
  additional_questions: [Q30, Q31, Q32]
```

---

## Total Impact Summary

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Total Size** | 196KB | 65KB | -131KB (67%) |
| **Tokens** | ~49,000 | ~16,250 | -32,750 (67%) |
| **Party Mode Overhead** | 31,100 tokens | 10,300 tokens | -20,800 freed |
| **Context Window %** | 49% of 100K | 16% of 100K | +33% freed |

---

## Recommended Actions

### Immediate (Phase 1)

1. **Update AGENTS.md v3.4 → v3.4.1**
   - Add `<droid_versions>` registry
   - Add 15 additional reflection questions (Q18-Q32)
   - Expand agent_custom_protocols for each droid

2. **Refactor TOP 5 Droids**
   - Remove redundant sections
   - Add `<inheritance>` section pointing to AGENTS.md v3.4.1
   - Keep only domain-specific knowledge
   - Add 3 additional_reflection_questions per droid

### Quality Gates (Post-Refactoring)

For each refactored droid, validate:

| Gate | Check | Pass Criteria |
|------|-------|---------------|
| Size | File size reduced | <40% of original |
| Domain | Domain knowledge preserved | Semantic similarity >95% |
| Function | Functional test | Output matches original for test tasks |
| Inheritance | Points to correct AGENTS.md | Version 3.4.1 specified |
| Questions | Has 3 additional questions | Unique, domain-specific |

---

## Appendix: Test Tasks for Validation

### NAUTILUS Test Tasks
1. "Explain Actor vs Strategy pattern in NautilusTrader"
2. "How to migrate MQL5 OnTick() to Nautilus?"
3. "What's the performance budget for on_bar handler?"

### ORACLE Test Tasks
1. "What's the WFE threshold for GO decision?"
2. "Explain Walk-Forward Efficiency calculation"
3. "How many Monte Carlo runs required?"

### FORGE Test Tasks
1. "How to avoid blocking in on_bar handler?"
2. "What's the Deep Debug protocol?"
3. "How to use pytest fixtures for NautilusTrader?"

### SENTINEL Test Tasks
1. "Calculate trailing DD with unrealized P&L"
2. "What's the circuit breaker level at 8.5% DD?"
3. "Explain position sizing formula with time multiplier"

### RESEARCH Test Tasks
1. "What confidence level for single arXiv paper?"
2. "Explain multi-source triangulation methodology"
3. "How to rate source credibility?"
