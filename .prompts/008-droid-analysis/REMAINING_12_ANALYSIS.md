# LAYER 2: Remaining 12 Droids Analysis

**Analysis Date:** 2025-12-07
**Analyst:** Elite Quantitative Research Analyst (deep-researcher subagent)
**Confidence:** HIGH (comprehensive file analysis completed)

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Total Size** | 163KB (12 droids) |
| **Estimated Redundancy** | ~98KB (60%) |
| **Potential Savings** | ~98KB |
| **Critical Droids** | 2 (orchestrator, onnx-model-builder) |
| **High Priority** | 3 (code-architect-reviewer, crucible, argus) |
| **Merge Candidates** | 3 (argus + deep-researcher + research-analyst-pro) |
| **Remove Candidates** | 2 (sentinel-ftmo-guardian, bmad-builder) |

---

## Per-Droid Analysis

### 1. code-architect-reviewer.md (28KB) - HIGH Priority

**Current Size:** 28KB
**Estimated Redundancy:** 65% (~18KB)
**Specialization:** Systemic code review, nth-order consequence analysis

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | Code review with dependency mapping and cascade analysis |
| **Project-Specific** | Yes - prop firm compliance, trading system patterns |
| **Overlap** | FORGE (both do code review) - SIGNIFICANT OVERLAP |
| **Usage Frequency** | HIGH - Pre-commit audits |

#### Unique Domain Knowledge (KEEP)

- 5-Layer Review Process (context, immediate, dependency, consequence, solutions)
- nth-Order Consequence Analysis (1st → 4th order + prop firm cascade)
- Quality Scoring System (0-100 with detailed breakdown)
- Dependency mapping workflow
- Multi-solution ranking with pros/cons

#### Redundant Sections (REMOVE)

- Generic coding principles (~3KB)
- ASCII art and banners (~1KB)
- Generic guardrails (~2KB)
- Output templates duplicated from FORGE (~4KB)
- Generic proactive triggers (~2KB)
- Language-specific checks (duplicated in FORGE) (~6KB)

#### Recommendation

**REFACTOR LATER (Phase 2)**
- Keep as dedicated REVIEWER role
- Remove overlap with FORGE
- Focus on: Consequence cascade, dependency mapping, scoring
- FORGE handles: Day-to-day coding, debugging
- code-architect-reviewer handles: Pre-commit audits, architectural review

---

### 2. onnx-model-builder.md (28KB) - CRITICAL Priority

**Current Size:** 28KB
**Estimated Redundancy:** 50% (~14KB)
**Specialization:** ML model training, ONNX export, MQL5 integration

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | ML/AI for trading - unique and critical |
| **Project-Specific** | Yes - direction prediction, regime detection |
| **Overlap** | None - unique specialization |
| **Usage Frequency** | MEDIUM (ML development phases) |

#### Unique Domain Knowledge (KEEP - ALL CRITICAL)

- Feature engineering templates for trading (~4KB)
- Model architectures (LSTM, GRU, CNN, Transformer) (~6KB)
- Walk-Forward validation for ML (~3KB)
- ONNX export workflow with MQL5 integration code (~5KB)
- Normalization parameter management (~2KB)
- RAG database queries for books/docs (~3KB)
- Quality standards (WFE≥0.6, <50ms inference) (~2KB)

#### Redundant Sections (REMOVE)

- Generic workflow descriptions (~3KB)
- Generic constraints inherited from AGENTS.md (~2KB)
- Verbose code templates (can be skills) (~6KB)
- Generic guardrails (~2KB)

#### Recommendation

**REFACTOR NOW (Phase 1)**
- CRITICAL for ML-based strategy components
- Unique integration: Python training → ONNX → MQL5
- No other droid provides this capability
- Priority: Elevate alongside TOP 5

---

### 3. sentinel-ftmo-guardian.md (20KB) - LOW Priority / REMOVE CANDIDATE

**Current Size:** 20KB
**Estimated Redundancy:** 95% with SENTINEL-APEX
**Specialization:** FTMO rules (5% daily, 10% total)

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | FTMO prop firm compliance |
| **Project-Specific** | NO - Project targets APEX, not FTMO |
| **Overlap** | SENTINEL-APEX covers 95% functionality |
| **Usage Frequency** | ZERO (project uses Apex/Tradovate) |

#### Key Differences from SENTINEL-APEX

| Rule | FTMO | APEX |
|------|------|------|
| Daily DD | 5% FIXED | N/A (no daily limit) |
| Total DD | 10% FIXED | 10% TRAILING from HWM |
| Overnight | Allowed | PROHIBITED |
| Close Time | None | 4:59 PM ET |
| Automation | Allowed | NOT on funded |

#### Recommendation

**CONSIDER REMOVAL**
- Project exclusively targets Apex/Tradovate
- SENTINEL-APEX already handles all risk calculations
- If FTMO needed in future: Add as SENTINEL mode/config, not separate droid
- Alternative: Archive to `.factory/droids/archived/`

---

### 4. crucible-gold-strategist.md (17KB) - HIGH Priority

**Current Size:** 17KB
**Estimated Redundancy:** 55% (~9KB)
**Specialization:** Backtest realism, XAUUSD-specific execution modeling

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | Backtest quality, slippage/spread/fill modeling |
| **Project-Specific** | Yes - XAUUSD, NautilusTrader, Apex |
| **Overlap** | ORACLE (both validate backtests) - Complementary not duplicate |
| **Usage Frequency** | HIGH - Every backtest validation |

#### Unique Domain Knowledge (KEEP)

- 25 Realism Gates (~5KB)
- XAUUSD spread model by session (~2KB)
- Slippage model configuration (~2KB)
- NautilusTrader BacktestEngine realism settings (~3KB)
- GO/NO-GO thresholds (Realism Score ≥90%) (~1KB)

#### Relationship with ORACLE

```
CRUCIBLE: Execution REALISM (slippage, spread, fills)
         └── "Is the backtest modeling real execution?"
         
ORACLE: Statistical VALIDITY (WFA, Monte Carlo, overfitting)
        └── "Are the results statistically robust?"

WORKFLOW: CRUCIBLE validates realism → ORACLE validates statistics
          Both must PASS for GO decision
```

#### Recommendation

**REFACTOR LATER (Phase 2)**
- Keep as complementary to ORACLE
- Focus exclusively on execution realism
- Remove overlap with ORACLE's statistical validation
- Add clear handoff protocol in AGENTS.md

---

### 5. argus-quant-researcher.md (15KB) - MERGE CANDIDATE

**Current Size:** 15KB
**Estimated Redundancy:** 80% with research-analyst-pro + deep-researcher
**Specialization:** Trading/quant research with triangulation

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | Research triangulation for trading |
| **Project-Specific** | Partially (order flow, SMC, ML trading) |
| **Overlap** | research-analyst-pro (same methodology), deep-researcher (same purpose) |
| **Usage Frequency** | MEDIUM |

#### Overlap Analysis

| Feature | ARGUS | RESEARCH-ANALYST-PRO | deep-researcher |
|---------|-------|---------------------|-----------------|
| Multi-source triangulation | ✅ | ✅ | ✅ |
| Confidence levels | ✅ | ✅ | ✅ |
| Academic + Practical + Empirical | ✅ | ✅ | ✅ |
| Trading-specific keywords | ✅ | ❌ | ✅ |
| RAG database queries | ✅ | ❌ | ❌ |
| Size | 15KB | 31KB | 12KB |

**Total overlap:** 58KB across 3 droids doing essentially the same job

#### Recommendation

**MERGE INTO SINGLE RESEARCH DROID**
- Combine: argus + research-analyst-pro + deep-researcher
- Name: ARGUS (keeps trading focus)
- Features: Best of all three
- Savings: 58KB → ~15KB = 43KB saved

---

### 6. git-guardian.md (15KB) - MEDIUM Priority

**Current Size:** 15KB
**Estimated Redundancy:** 40% (~6KB)
**Specialization:** Git operations with security focus

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | Version control, secrets detection |
| **Project-Specific** | No - Generic git operations |
| **Overlap** | None - Unique purpose |
| **Usage Frequency** | HIGH (every commit) but invoked implicitly |

#### Unique Domain Knowledge (KEEP)

- Pre-flight checklist (status, branch, diff, stash, log)
- Security scan patterns (API keys, passwords, tokens)
- File safety matrix
- Recovery playbook
- Emergency commands

#### Recommendation

**KEEP AS-IS or LIGHT REFACTOR**
- Useful for preventing credential leaks
- Not redundant with other droids
- Consider: Move to skill (`.factory/skills/git-guardian/`)

---

### 7. deep-researcher.md (12KB) - MERGE CANDIDATE

**Current Size:** 12KB
**Estimated Redundancy:** 90% with argus + research-analyst-pro
**Specialization:** Deep research with scientific critical thinking

#### Analysis

See ARGUS analysis above - these three should merge.

#### Recommendation

**MERGE INTO ARGUS**
- Contributes: Scientific critical thinking validation checklist
- After merge: Archive or delete this file

---

### 8. nautilus-nano.md (8KB) - KEEP (PARTY MODE)

**Current Size:** 8KB
**Estimated Redundancy:** 0% (designed to be compact)
**Specialization:** Compact NAUTILUS for multi-agent sessions

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | NautilusTrader migration (compact) |
| **Project-Specific** | Yes - Same as NAUTILUS but optimized |
| **Overlap** | NAUTILUS (by design - nano version) |
| **Usage Frequency** | HIGH (Party Mode) |

#### Unique Value

- 8KB vs 53KB NAUTILUS = 85% smaller
- Keeps: Migration essentials, MQL5 mapping, anti-patterns
- Removes: Full templates, diagrams, long explanations
- Perfect for: Multi-agent sessions with context limits

#### Recommendation

**KEEP AS-IS**
- Serves specific purpose (Party Mode)
- Already optimized
- Model for how to create "nano" versions of other droids

---

### 9. project-reader.md (6KB) - LOW Priority

**Current Size:** 6KB
**Estimated Redundancy:** 60% (~3.5KB)
**Specialization:** Project structure analysis

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | Codebase understanding, orientation |
| **Project-Specific** | No - Generic |
| **Overlap** | None |
| **Usage Frequency** | LOW (onboarding, occasional) |

#### Recommendation

**KEEP AS-IS or CONVERT TO SKILL**
- Small footprint (6KB)
- Useful for new sessions
- Consider: Move to skill

---

### 10. bmad-builder.md (5KB) - REMOVE CANDIDATE

**Current Size:** 5KB
**Estimated Redundancy:** N/A
**Specialization:** BMad Method module builder

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | BMad methodology |
| **Project-Specific** | NO - BMad is separate system |
| **Overlap** | None |
| **Usage Frequency** | ZERO for this project |

#### Recommendation

**REMOVE or ARCHIVE**
- Not used in EA_SCALPER_XAUUSD project
- BMad is separate methodology
- Archive to `.factory/droids/archived/`

---

### 11. trading-project-documenter.md (5KB) - LOW Priority

**Current Size:** 5KB
**Estimated Redundancy:** 50% (~2.5KB)
**Specialization:** Trading system documentation

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | Documentation for trading EAs |
| **Project-Specific** | Partially |
| **Overlap** | None |
| **Usage Frequency** | LOW |

#### Recommendation

**KEEP AS-IS or CONVERT TO SKILL**
- Small footprint
- Useful when documentation needed
- EDIT > CREATE principle should be enforced

---

### 12. ea-scalper-xauusd-orchestrator.md (4KB) - CRITICAL Priority / ELEVATE

**Current Size:** 4KB (surprisingly small for orchestrator)
**Estimated Redundancy:** 10%
**Specialization:** Central coordination hub

#### Analysis

| Aspect | Assessment |
|--------|------------|
| **Domain** | Workflow orchestration, droid routing |
| **Project-Specific** | YES - Project-specific coordinator |
| **Overlap** | None |
| **Usage Frequency** | Should be HIGH (currently underutilized) |

#### Current Content Review

Current orchestrator is **TOO BASIC**:
- Simple description paragraph
- Lists agents (CRUCIBLE, SENTINEL, FORGE, ORACLE, ARGUS, NAUTILUS)
- Mentions BUILD>PLAN philosophy
- Mentions Apex constraints
- **MISSING:** Workflow DAGs, automatic invocation, conditional steps

#### What Orchestrator SHOULD Have

```xml
<orchestrator_requirements>
  <must_have>
    <item>Dependency graph of all droids</item>
    <item>Workflow definitions (Strategy Dev, Code Review, Research)</item>
    <item>Automatic invocation based on triggers</item>
    <item>Conditional step handling</item>
    <item>Loop support (fix → re-test → validate)</item>
    <item>Progress tracking across sessions</item>
  </must_have>
  
  <workflows>
    <workflow name="Strategy Development">
      CRUCIBLE → SENTINEL → NAUTILUS → ORACLE → [FORGE if NO-GO] → loop
    </workflow>
    <workflow name="Code Review">
      FORGE → NAUTILUS → FORGE → ORACLE
    </workflow>
    <workflow name="Research to Strategy">
      ARGUS → ONNX-MODEL-BUILDER → CRUCIBLE → NAUTILUS → ORACLE
    </workflow>
  </workflows>
</orchestrator_requirements>
```

#### Recommendation

**REFACTOR NOW + ELEVATE TO MAESTRO ROLE**
- Currently 4KB is too small - should be ~15-20KB
- Add: Dependency graph, workflow definitions, automatic routing
- Priority 7 in decision hierarchy (coordinates but doesn't override)
- This is the MISSING PIECE for ecosystem coordination

---

## Priority Matrix

| Droid | Size | Redundancy | Priority | Recommendation |
|-------|------|------------|----------|----------------|
| ea-scalper-xauusd-orchestrator | 4KB | 10% | **CRITICAL** | REFACTOR NOW + ELEVATE |
| onnx-model-builder | 28KB | 50% | **CRITICAL** | REFACTOR NOW |
| crucible-gold-strategist | 17KB | 55% | **HIGH** | REFACTOR LATER |
| code-architect-reviewer | 28KB | 65% | **HIGH** | REFACTOR LATER |
| argus-quant-researcher | 15KB | 80% | **HIGH** | MERGE (with research droids) |
| deep-researcher | 12KB | 90% | **MEDIUM** | MERGE INTO ARGUS |
| git-guardian | 15KB | 40% | **MEDIUM** | KEEP or SKILL |
| nautilus-nano | 8KB | 0% | **MEDIUM** | KEEP AS-IS |
| project-reader | 6KB | 60% | **LOW** | KEEP or SKILL |
| trading-project-documenter | 5KB | 50% | **LOW** | KEEP or SKILL |
| sentinel-ftmo-guardian | 20KB | 95% | **LOW** | REMOVE/ARCHIVE |
| bmad-builder | 5KB | N/A | **LOW** | REMOVE/ARCHIVE |

---

## Refactoring Roadmap

### Phase 1 (with TOP 5) - Week 1

| Droid | Action | Estimated Time |
|-------|--------|----------------|
| ea-scalper-xauusd-orchestrator | Refactor + Elevate to MAESTRO | 4-6 hours |
| onnx-model-builder | Refactor (50% reduction) | 2-3 hours |

**Reason:** Critical for project success, currently underutilized

### Phase 2 (after TOP 5) - Week 2

| Droid | Action | Estimated Time |
|-------|--------|----------------|
| crucible-gold-strategist | Refactor (55% reduction) | 2 hours |
| code-architect-reviewer | Refactor (65% reduction) | 2 hours |
| argus + deep-researcher + research-analyst-pro | MERGE into ARGUS | 4 hours |

**Savings from merge:** 58KB → 15KB = 43KB saved

### Phase 3 (lower priority) - Week 3

| Droid | Action | Estimated Time |
|-------|--------|----------------|
| git-guardian | Optional skill conversion | 1 hour |
| project-reader | Optional skill conversion | 30 min |
| trading-project-documenter | Optional skill conversion | 30 min |

### Phase 4 (cleanup) - Week 4

| Droid | Action |
|-------|--------|
| sentinel-ftmo-guardian | Archive to `.factory/droids/archived/` |
| bmad-builder | Archive to `.factory/droids/archived/` |

---

## Total Savings (All 12 Droids)

| Phase | Droids | Before | After | Savings |
|-------|--------|--------|-------|---------|
| Phase 1 | 2 | 32KB | 22KB | 10KB |
| Phase 2 | 5 | 101KB | 40KB | 61KB |
| Phase 3 | 3 | 26KB | ~20KB (skills) | 6KB |
| Phase 4 | 2 | 25KB | 0KB | 25KB |
| **TOTAL** | **12** | **184KB** | **82KB** | **102KB (55%)** |

**Combined with TOP 5:**
- TOP 5: 131KB saved
- Remaining 12: 102KB saved
- **TOTAL ECOSYSTEM SAVINGS: 233KB (60%)**

---

## Appendix: Research Droid Merge Plan

### Current State (3 droids, 58KB)

```
argus-quant-researcher.md (15KB)
├── Trading-specific triangulation
├── RAG database queries
├── Priority areas table
└── Automatic alerts

research-analyst-pro.md (31KB)
├── Generic research methodology
├── Quality assurance framework
├── Report structure template
└── Multi-phase workflow

deep-researcher.md (12KB)
├── Scientific critical thinking
├── Multi-layer research execution
├── Confidence assessment
└── Deliverable format
```

### After Merge: ARGUS v3.0 (15KB)

```
argus-quant-researcher.md (15KB - MERGED)
├── From ARGUS:
│   ├── Trading-specific focus
│   ├── RAG database queries (mql5-books, mql5-docs)
│   ├── Priority areas (order flow, SMC, ML trading)
│   └── Automatic alerts
├── From RESEARCH-ANALYST-PRO:
│   ├── Quality assurance checklist (condensed)
│   └── Confidence level framework
├── From deep-researcher:
│   ├── Scientific critical thinking checklist
│   └── Multi-layer research phases (condensed)
└── Inherits from AGENTS.md:
    ├── Generic workflow templates
    ├── Output format templates
    └── Constraints/guardrails
```

### Merge Benefits

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Total size | 58KB | 15KB | -43KB (74%) |
| Tokens | 14,500 | 3,750 | -10,750 |
| Droids to maintain | 3 | 1 | -2 droids |
| Confusion factor | HIGH | NONE | "Which research droid to use?" eliminated |
