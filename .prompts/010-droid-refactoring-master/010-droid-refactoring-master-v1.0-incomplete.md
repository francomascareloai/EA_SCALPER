# 🔨 PROMPT: Master Droid Refactoring (FASE 2-4)

## 📋 Objective

Executar **FASE 2-4** do plano de otimização: refatorar os TOP 5 droids (NAUTILUS, ORACLE, FORGE, SENTINEL, RESEARCH-ANALYST-PRO) implementando herança hierárquica do AGENTS.md v3.4.1, criar NANO versions quando necessário, e validar todas as mudanças.

**Why it matters:** Eliminar 69% de duplicação (33,750 tokens), criar sistema de herança que propaga melhorias do AGENTS.md automaticamente, e liberar +16,450 tokens em Party Mode sessions.

---

## 📁 Context

**Dependencies:**
@.prompts/008-droid-analysis/droid-analysis.md (FASE 1 output with REDUNDANCY_MAP)
@.prompts/009-agents-nautilus-update/agents-nautilus-update.md (AGENTS.md v3.4.1 with Nautilus focus)
@AGENTS.md (v3.4.1 - base for inheritance)

**Master Plan:**
@.factory/specs/2025-12-07-plano-otimiza-o-completa-dos-droids-token-efficiency-consistency.md

**Droids to Refactor:**
- @.factory/droids/nautilus-trader-architect.md (53KB → 15KB target)
- @.factory/droids/oracle-backtest-commander.md (38KB → 12KB target)
- @.factory/droids/forge-mql5-architect.md (37KB → 12KB target)
- @.factory/droids/sentinel-apex-guardian.md (37KB → 12KB target)
- @.factory/droids/research-analyst-pro.md (31KB → 10KB target)

**Expected Savings:**
- Total: 196KB → 61KB (135KB removed, 69% reduction)
- Tokens: 49,000 → 15,250 (33,750 tokens saved)
- Party Mode: 61,700 → 45,250 tokens overhead (16,450 tokens freed)

---

## 🎯 Requirements

### FASE 2: Refatoração dos TOP 5 Droids (2h 30min)

Execute refatoração de cada droid **UM POR VEZ** com validação entre cada um.

---

#### 2.1 NAUTILUS Refactoring (53KB → 15KB) [40 min]

**Input:** @.factory/droids/nautilus-trader-architect.md
**Output:** @.factory/droids/nautilus-trader-architect.md (refatorado)
**Backup:** @.factory/droids/_archive/nautilus-trader-architect-v2.0-pre-inheritance.md

**MANTER (Domain Knowledge):**
1. **Strategy/Actor/Indicator Lifecycle:**
   - `on_start()`, `on_stop()`, `on_bar()`, `on_quote_tick()`, `on_event()`
   - Actor pattern: MessageBus pub/sub, data processing (no trading)
   - Strategy pattern: Trading logic, order_factory, submit_order

2. **Migration Mappings (MQL5 → Python):**
   ```python
   OnInit() → Strategy.__init__() + on_start()
   OnTick() → on_quote_tick() or on_bar()
   OnDeinit() → on_stop()
   OrderSend() → submit_order()
   PositionSelect() → cache.positions()
   ```

3. **Event-Driven Architecture:**
   - MessageBus for signals
   - Cache for data access
   - No globals, no blocking calls
   - Performance targets: <1ms on_bar, <100μs on_tick

4. **Backtest Setup:**
   - ParquetDataCatalog configuration
   - BacktestNode setup
   - DataConfig, VenueConfig

5. **3 Additional Reflection Questions:**
   ```xml
   <question id="18">Does this follow NautilusTrader event-driven patterns?</question>
   <question id="19">Is Actor vs Strategy decision correct?</question>
   <question id="20">Are async resources properly cleaned up?</question>
   ```

**REMOVER (Already in AGENTS.md):**
- Workflows genéricos (use AGENTS.md `<genius_mode_templates>`)
- "❌ NEVER" rules gerais (herdar de `<strategic_intelligence>`)
- Protocols P0.X genéricos (herdar de `<mandatory_reflection_protocol>`)
- ASCII art decorativo (economy mode)
- Generic error recovery (use AGENTS.md `<error_recovery>`)

**New Structure:**
```xml
<droid_specialization>
  <metadata>
    <name>NAUTILUS</name>
    <version>2.1</version>
    <inherits_from>AGENTS.md v3.4.1</inherits_from>
    <size>15KB</size>
    <savings>38KB (72%)</savings>
  </metadata>
  
  <inheritance>
    <from>AGENTS.md v3.4.1</from>
    <protocols inherit="full">
      strategic_intelligence, mandatory_reflection_protocol,
      proactive_problem_detection, genius_mode_templates,
      complexity_assessment, compressed_protocols,
      enforcement_validation, pattern_learning
    </protocols>
  </inheritance>
  
  <domain_knowledge>
    <nautilus_patterns>
      <lifecycle>{lifecycle docs}</lifecycle>
      <migration>{MQL5 mappings}</migration>
      <architecture>{event-driven patterns}</architecture>
      <performance>{targets and budgets}</performance>
      <backtest>{ParquetDataCatalog setup}</backtest>
    </nautilus_patterns>
  </domain_knowledge>
  
  <additional_reflection_questions>
    <question id="18">{text}</question>
    <question id="19">{text}</question>
    <question id="20">{text}</question>
  </additional_reflection_questions>
  
  <domain_guardrails>
    <guardrail>NEVER block in handlers (on_bar <1ms)</guardrail>
    <guardrail>NEVER use global state (event-driven architecture)</guardrail>
    <guardrail>NEVER access data outside cache</guardrail>
  </domain_guardrails>
</droid_specialization>
```

**Validation:**
- [ ] Size reduced to ~15KB (±2KB tolerance)
- [ ] All domain knowledge preserved
- [ ] 3 additional questions present
- [ ] Inheritance section correct
- [ ] No duplication with AGENTS.md
- [ ] Backup created

---

#### 2.2 ORACLE Refactoring (38KB → 12KB) [35 min]

**Input:** @.factory/droids/oracle-backtest-commander.md
**Output:** @.factory/droids/oracle-backtest-commander.md (refatorado)
**Backup:** @.factory/droids/_archive/oracle-backtest-commander-v2.0-pre-inheritance.md

**MANTER (Domain Knowledge):**
1. **Statistical Thresholds:**
   - WFE ≥0.6 (Walk-Forward Efficiency)
   - DSR >0 (Deflated Sharpe Ratio)
   - PSR ≥0.85 (Probabilistic Sharpe Ratio)
   - MC_95th_DD <5% (Monte Carlo 95th percentile DD)
   - SQN >2.0 (System Quality Number)

2. **Walk-Forward Formulas:**
   - IS/OOS split ratios
   - Purged CV (cross-validation with purging)
   - Rolling window specifications

3. **Monte Carlo Specifications:**
   - Block bootstrap methodology
   - 5000 runs minimum
   - Confidence intervals (95th percentile)

4. **GO/NO-GO Gates (7-step checklist):**
   ```
   1. WFE ≥0.6?
   2. DSR >0?
   3. PSR ≥0.85?
   4. MC_95th_DD <5%?
   5. Apex compliance (trailing DD, time, consistency)?
   6. Parameter stability <20% variation?
   7. SQN >2.0?
   ```

5. **3 Additional Reflection Questions:**
   ```xml
   <question id="21">Is this backtest using look-ahead bias or real point-in-time data?</question>
   <question id="22">What regime change would invalidate these results?</question>
   <question id="23">Am I overfitting to recent price action?</question>
   ```

**REMOVER:**
- Never/Always rules genéricos (herdar)
- Output templates verbosos (usar AGENTS.md formats)
- Proactive behavior triggers genéricos

**Validation:**
- [ ] Size reduced to ~12KB
- [ ] All thresholds and formulas preserved
- [ ] GO/NO-GO gates intact
- [ ] 3 additional questions present
- [ ] Backup created

---

#### 2.3 FORGE Refactoring (37KB → 12KB) [35 min]

**Input:** @.factory/droids/forge-mql5-architect.md
**Output:** @.factory/droids/forge-mql5-architect.md (refatorado)
**Backup:** @.factory/droids/_archive/forge-mql5-architect-v2.0-pre-inheritance.md

**MANTER (Domain Knowledge):**
1. **Deep Debug Protocol (Python/Nautilus specific):**
   - Sequential-thinking for complex bugs
   - Hypothesis → Test → Refine loop
   - Context7 integration for Nautilus docs

2. **NautilusTrader Patterns:**
   - Type hints best practices
   - Async/await patterns
   - Cython optimization hints

3. **Python Anti-Patterns to Avoid:**
   - Circular imports
   - Mutable default arguments
   - Blocking in event handlers
   - Global state

4. **Test Scaffolding Templates:**
   - pytest fixtures
   - Mock setup for Actors/Strategies
   - Backtest validation helpers

5. **3 Additional Reflection Questions:**
   ```xml
   <question id="24">Does this code follow Python/Nautilus type safety patterns?</question>
   <question id="25">Are there any blocking operations in event handlers?</question>
   <question id="26">Is error handling comprehensive with proper logging?</question>
   ```

**REMOVER:**
- P0.1-P0.8 protocols genéricos (substituir por herança)
- Self-correction checklist (já em AGENTS.md enforcement_validation)
- Never/Always rules gerais

**Validation:**
- [ ] Size reduced to ~12KB
- [ ] Deep Debug protocol preserved
- [ ] Python/Nautilus patterns intact
- [ ] Test templates present
- [ ] Backup created

---

#### 2.4 SENTINEL Refactoring (37KB → 12KB) [35 min]

**Input:** @.factory/droids/sentinel-apex-guardian.md
**Output:** @.factory/droids/sentinel-apex-guardian.md (refatorado)
**Backup:** @.factory/droids/_archive/sentinel-apex-guardian-v2.0-pre-inheritance.md

**MANTER (Domain Knowledge):**
1. **Apex Trading Rules:**
   - 10% trailing DD from HWM (NOT 10% from starting balance)
   - 4:59 PM ET deadline (NO overnight positions)
   - 30% consistency rule (max daily profit)
   - HWM includes unrealized P&L

2. **Position Sizing Formulas:**
   - Kelly criterion adaptations
   - Time multiplier (reduces size near 4:59 PM)
   - DD awareness (reduces size as DD increases)

3. **Circuit Breaker Levels:**
   ```
   WARNING:  7-8% trailing DD
   CAUTION:  8-9% trailing DD
   DANGER:   9-9.5% trailing DD
   BLOCKED:  9.5-10% trailing DD (no new trades)
   ```

4. **Recovery Protocols (Apex specific):**
   - Emergency close before 4:59 PM
   - Position size reduction strategies
   - DD recovery pacing

5. **3 Additional Reflection Questions:**
   ```xml
   <question id="27">What market condition makes this risk calculation WRONG?</question>
   <question id="28">Am I measuring trailing DD from ACTUAL HWM or stale cached value?</question>
   <question id="29">What happens if news event hits at 4:50 PM ET?</question>
   ```

**REMOVER:**
- Generic risk management rules (herdar de AGENTS.md)
- Never/Always rules gerais
- Output templates verbosos

**Validation:**
- [ ] Size reduced to ~12KB
- [ ] Apex rules and formulas preserved
- [ ] Circuit breaker levels intact
- [ ] Recovery protocols present
- [ ] Backup created

---

#### 2.5 RESEARCH-ANALYST-PRO Refactoring (31KB → 10KB) [25 min]

**Input:** @.factory/droids/research-analyst-pro.md
**Output:** @.factory/droids/research-analyst-pro.md (refatorado)
**Backup:** @.factory/droids/_archive/research-analyst-pro-v2.0-pre-inheritance.md

**MANTER (Domain Knowledge):**
1. **Multi-Source Triangulation Methodology:**
   - Academic (arXiv, SSRN, Google Scholar)
   - Industry (whitepapers, blogs, docs)
   - Empirical (backtest data, live results)

2. **Source Credibility Rating System:**
   - Tier 1: Peer-reviewed, official docs (HIGH confidence)
   - Tier 2: Industry whitepapers, established blogs (MEDIUM confidence)
   - Tier 3: Forum posts, unverified claims (LOW confidence)

3. **Confidence Level Frameworks:**
   - HIGH: Multiple Tier 1 sources agree
   - MEDIUM: Mix of Tier 1/2, some disagreement
   - LOW: Only Tier 3, or high disagreement

4. **Research Log Structure:**
   ```xml
   <research_log>
     <source url="" tier="">Finding</source>
     <confidence>HIGH/MEDIUM/LOW</confidence>
   </research_log>
   ```

5. **3 Additional Reflection Questions:**
   ```xml
   <question id="30">What is the CONFIDENCE LEVEL of this research finding?</question>
   <question id="31">What biases might exist in the sources found?</question>
   <question id="32">Have I triangulated across academic + industry + empirical?</question>
   ```

**REMOVER:**
- Generic constraints (must/must_not - herdar)
- Workflow phases genéricos (usar AGENTS.md templates)

**Validation:**
- [ ] Size reduced to ~10KB
- [ ] Triangulation methodology preserved
- [ ] Credibility rating system intact
- [ ] Research log structure present
- [ ] Backup created

---

### FASE 3: Criar NANO Versions (1h)

**Only if needed** - Create NANO versions for droids that Party Mode frequently invokes simultaneously.

**Priority:**
1. **ORACLE-NANO** (10KB target) - Frequently used with CRUCIBLE + SENTINEL
2. **SENTINEL-NANO** (10KB target) - Frequently used with CRUCIBLE + ORACLE

**Skip if not needed:**
- NAUTILUS-NANO already exists (8KB) ✅
- FORGE-NANO already exists in skills ✅
- RESEARCH-ANALYST-PRO rarely in Party Mode

**NANO Structure:**
```xml
<droid_specialization type="nano">
  <inherits>AGENTS.md v3.4.1 (compressed_protocols: fast_mode)</inherits>
  <essential_knowledge>
    {Top 10 most critical facts only - ultra-compressed}
  </essential_knowledge>
  <quick_checklist>
    {5-7 item checklist - no explanations}
  </quick_checklist>
</droid_specialization>
```

---

### FASE 4: Validação & Documentação (30 min)

#### 4.1 Testar Droids Refatorados (15 min)

For EACH refactored droid:
```
Test task: "Analyze [domain-specific simple task]"
Expected: Droid applies AGENTS.md protocols + domain knowledge
Verify: thinking_score calculated, reflection questions applied
```

**Test cases:**
- NAUTILUS: "Explain Actor vs Strategy pattern"
- ORACLE: "What's the WFE threshold for GO decision?"
- FORGE: "How to avoid blocking in on_bar handler?"
- SENTINEL: "Calculate trailing DD with unrealized P&L"
- RESEARCH: "What confidence level for single arXiv paper?"

#### 4.2 Criar Documentação (10 min)

**File:** `DOCS/04_REPORTS/20251207_DROID_OPTIMIZATION_COMPLETION_REPORT.md`

**Structure:**
```markdown
# Droid Optimization Completion Report

## Executive Summary
- Droids refactored: 5 (NAUTILUS, ORACLE, FORGE, SENTINEL, RESEARCH)
- Total savings: {XX}KB ({YY}% reduction)
- Token savings: {ZZ,ZZZ} tokens
- Party Mode improvement: +{WW}% budget libre

## Before/After Comparison

| Droid | Before | After | Savings | % Reduction |
|-------|--------|-------|---------|-------------|
| NAUTILUS | 53KB | {XX}KB | {YY}KB | {ZZ}% |
| ORACLE | 38KB | {XX}KB | {YY}KB | {ZZ}% |
| FORGE | 37KB | {XX}KB | {YY}KB | {ZZ}% |
| SENTINEL | 37KB | {XX}KB | {YY}KB | {ZZ}% |
| RESEARCH | 31KB | {XX}KB | {YY}KB | {ZZ}% |
| **TOTAL** | **196KB** | **{XX}KB** | **{YY}KB** | **{ZZ}%** |

## Inheritance System

All refactored droids now inherit from AGENTS.md v3.4.1:
- strategic_intelligence (7 mandatory questions)
- genius_mode_templates (4 templates)
- complexity_assessment (4 levels)
- enforcement_validation (thinking_score)
- compressed_protocols (fast_mode + emergency_mode)
- pattern_learning (auto-learning from bugs)

Each droid maintains:
- Domain-specific knowledge (~10-15KB)
- 3 additional reflection questions
- Domain-specific guardrails

## NANO Versions Created

{If any created}
- oracle-nano.md (10KB) - for Party Mode efficiency
- sentinel-nano.md (10KB) - for Party Mode efficiency

## Validation Results

All droids tested with simple tasks:
- ✅ NAUTILUS: Reflection questions applied
- ✅ ORACLE: WFE threshold correct
- ✅ FORGE: Python patterns retained
- ✅ SENTINEL: Apex rules correct
- ✅ RESEARCH: Confidence system intact

## Party Mode Impact

**Before:**
- AGENTS.md: 30,000 tokens
- 3 droids (avg): 31,700 tokens
- **Total: 61,700 tokens** (31% of budget)

**After:**
- AGENTS.md: 30,000 tokens
- 3 droids (avg): 15,250 tokens
- **Total: 45,250 tokens** (23% of budget)

**Improvement: +16,450 tokens freed (+8% budget)**

## Next Steps

- [ ] Test droids in real sessions
- [ ] Monitor for any missing knowledge
- [ ] Update droid documentation
- [ ] Consider refactoring remaining 12 droids

## Risks Mitigated

- ✅ Backups created for all droids
- ✅ Git commits with detailed changelogs
- ✅ Validation tests passed
- ✅ Knowledge preservation verified

## Lessons Learned

{Post-execution insights}
```

#### 4.3 Update AGENTS.md (5 min)

Add `<droid_inheritance>` section to AGENTS.md:

```xml
<droid_inheritance>
  <description>
    Specialized droids inherit protocols from AGENTS.md v3.4.1 to eliminate duplication.
    Each droid maintains only domain-specific knowledge and 3 additional reflection questions.
  </description>
  
  <inherited_protocols>
    <protocol>strategic_intelligence (7 mandatory questions)</protocol>
    <protocol>genius_mode_templates (4 templates)</protocol>
    <protocol>complexity_assessment (4 levels)</protocol>
    <protocol>enforcement_validation (thinking_score)</protocol>
    <protocol>compressed_protocols (fast_mode + emergency_mode)</protocol>
    <protocol>pattern_learning (auto-learning)</protocol>
  </inherited_protocols>
  
  <specialized_droids>
    <droid name="NAUTILUS" size="15KB" version="2.1">MQL5→Python migration, event-driven patterns</droid>
    <droid name="ORACLE" size="12KB" version="2.1">Statistical validation, WFA, Monte Carlo</droid>
    <droid name="FORGE" size="12KB" version="2.1">Python/Nautilus code architecture</droid>
    <droid name="SENTINEL" size="12KB" version="2.1">Apex Trading risk management</droid>
    <droid name="RESEARCH-ANALYST-PRO" size="10KB" version="2.1">Multi-source research triangulation</droid>
  </specialized_droids>
  
  <nano_versions>
    <nano name="NAUTILUS-NANO" size="8KB" use_when="Party Mode, quick tasks"/>
    <nano name="ORACLE-NANO" size="10KB" use_when="Party Mode with CRUCIBLE + SENTINEL"/>
    <nano name="SENTINEL-NANO" size="10KB" use_when="Party Mode with CRUCIBLE + ORACLE"/>
  </nano_versions>
  
  <propagation_rule>
    When AGENTS.md protocols are updated, ALL specialized droids automatically benefit.
    No need to update each droid individually unless domain knowledge changes.
  </propagation_rule>
</droid_inheritance>
```

---

## 📤 Output

### Primary Output
**File:** `.prompts/010-droid-refactoring-master/droid-refactoring-completion.md`

```xml
<droid_refactoring_completion>
  <metadata>
    <version>1.0</version>
    <date>{YYYY-MM-DD}</date>
    <phases>FASE 2 + FASE 3 + FASE 4</phases>
    <execution_time>{XX}h {YY}min</execution_time>
  </metadata>
  
  <phase_2_refactoring>
    <droid name="NAUTILUS">
      <before_size>53KB</before_size>
      <after_size>{XX}KB</after_size>
      <savings>{YY}KB ({ZZ}%)</savings>
      <backup>.factory/droids/_archive/nautilus-trader-architect-v2.0-pre-inheritance.md</backup>
      <validation>✅ Passed</validation>
    </droid>
    
    <!-- Repeat for ORACLE, FORGE, SENTINEL, RESEARCH -->
  </phase_2_refactoring>
  
  <phase_3_nano_versions>
    <nano name="ORACLE-NANO" created="true" size="10KB"/>
    <nano name="SENTINEL-NANO" created="true" size="10KB"/>
  </phase_3_nano_versions>
  
  <phase_4_validation>
    <tests>
      <test droid="NAUTILUS" task="Explain Actor vs Strategy" result="✅ Passed"/>
      <!-- Repeat for all droids -->
    </tests>
    <documentation>
      <file>DOCS/04_REPORTS/20251207_DROID_OPTIMIZATION_COMPLETION_REPORT.md</file>
      <status>Created</status>
    </documentation>
    <agents_md_update>
      <section>droid_inheritance</section>
      <status>Added</status>
    </agents_md_update>
  </phase_4_validation>
  
  <aggregate_results>
    <total_savings_kb>{XX}KB</total_savings_kb>
    <total_savings_tokens>{YY,YYY}</total_savings_tokens>
    <party_mode_improvement>+{ZZ}%</party_mode_improvement>
  </aggregate_results>
  
  <next_steps>
    <step>Test refactored droids in real sessions</step>
    <step>Monitor for missing knowledge or issues</step>
    <step>Consider refactoring remaining 12 droids</step>
  </next_steps>
  
  <confidence>HIGH</confidence>
  <dependencies>
    <dependency status="met">AGENTS.md v3.4.1 stable</dependency>
    <dependency status="met">Backups created for all droids</dependency>
    <dependency status="met">Git commits with changelogs</dependency>
  </dependencies>
  
  <open_questions>
    <question>Should remaining 12 droids be refactored next?</question>
    <question>How to automate inheritance validation in future?</question>
  </open_questions>
  
  <assumptions>
    <assumption>Refactored droids will work correctly with Task agent invocation</assumption>
    <assumption>Party Mode will detect and use NANO versions appropriately</assumption>
  </assumptions>
</droid_refactoring_completion>
```

---

### SUMMARY.md

**File:** `.prompts/010-droid-refactoring-master/SUMMARY.md`

```markdown
# Droid Refactoring Completion Summary

**One-liner:** Refactored TOP 5 droids with inheritance system - eliminated {XX}KB ({YY}%) duplication, freed +16,450 tokens in Party Mode

## Version
v1.0 - Complete optimization (FASE 2-4)

## Key Findings
• NAUTILUS: 53KB → {XX}KB ({savings}KB, {%}% reduction)
• ORACLE: 38KB → {XX}KB ({savings}KB, {%}% reduction)
• FORGE: 37KB → {XX}KB ({savings}KB, {%}% reduction)
• SENTINEL: 37KB → {XX}KB ({savings}KB, {%}% reduction)
• RESEARCH: 31KB → {XX}KB ({savings}KB, {%}% reduction)
• **Total: 196KB → {XX}KB ({YY}KB savings, {ZZ}% reduction)**
• **Party Mode: 61.7k → 45.2k tokens overhead (+16.5k tokens free, +8% budget)**

## Files Created
- `.factory/droids/_archive/*-pre-inheritance.md` (5 backups)
- `.factory/droids/oracle-nano.md` (10KB NANO version)
- `.factory/droids/sentinel-nano.md` (10KB NANO version)
- `DOCS/04_REPORTS/20251207_DROID_OPTIMIZATION_COMPLETION_REPORT.md`

## Files Modified
- `.factory/droids/nautilus-trader-architect.md` (v2.0 → v2.1)
- `.factory/droids/oracle-backtest-commander.md` (v2.0 → v2.1)
- `.factory/droids/forge-mql5-architect.md` (v2.0 → v2.1)
- `.factory/droids/sentinel-apex-guardian.md` (v2.0 → v2.1)
- `.factory/droids/research-analyst-pro.md` (v2.0 → v2.1)
- `AGENTS.md` (added `<droid_inheritance>` section)

## Decisions Needed
- Should remaining 12 droids be refactored next? (Similar savings potential)
- Enable automatic NANO switching in Party Mode or keep manual?

## Blockers
None - all phases completed successfully

## Next Step
Test refactored droids in real sessions to validate knowledge preservation and inheritance system
```

---

## ✅ Success Criteria

**FASE 2:**
- [ ] All 5 droids refactored (NAUTILUS, ORACLE, FORGE, SENTINEL, RESEARCH)
- [ ] Backups created for all original droids
- [ ] Each droid reduced to target size (±2KB tolerance)
- [ ] Domain knowledge preserved (verified via spot checks)
- [ ] 3 additional reflection questions per droid
- [ ] New `<droid_specialization>` structure applied

**FASE 3:**
- [ ] ORACLE-NANO created (10KB) if needed
- [ ] SENTINEL-NANO created (10KB) if needed
- [ ] NANO versions use compressed_protocols (fast_mode)

**FASE 4:**
- [ ] All refactored droids tested with simple tasks
- [ ] Validation tests passed (5/5 droids)
- [ ] Completion report created in DOCS/04_REPORTS/
- [ ] AGENTS.md updated with `<droid_inheritance>` section
- [ ] SUMMARY.md created with substantive results

**Overall:**
- [ ] Token savings ≥60% for TOP 5 droids
- [ ] Party Mode overhead <50k tokens
- [ ] Git commits created with detailed changelogs
- [ ] Confidence level HIGH (thorough validation)

---

## ⚡ Intelligence Application

**Use sequential-thinking (20+ thoughts for CRITICAL task):**
1. What is REAL problem? → Massive duplication, no inheritance, wasted tokens
2. What am I NOT seeing? → Risk of losing critical domain knowledge if delete wrong sections
3. What breaks if remove X? → Must verify redundancy BEFORE deleting (use droid-analysis.md)
4. What happens 5 steps ahead? → Refactored droids → inheritance works → future AGENTS.md updates propagate automatically
5. Edge cases? → Partial overlaps (50% match AGENTS.md, 50% specialized) - KEEP specialized parts
6. Optimization? → Can we automate inheritance validation for future droids?

**Proactive problem detection:**
- Dependencies: Refactored droids must work with Task agent invocation (test each one)
- Performance: No impact (static reference, not dynamic loading)
- Maintainability: MASSIVELY IMPROVED (single source of truth)
- Technical debt: ELIMINATED (no more duplicate protocols across droids)

**Genius mode amplifiers:**
- Use pre_mortem: "Imagine refactor failed - why?" → Knowledge lost, backup missing, validation skipped
- Use first_principles: What MUST each droid have? → Domain knowledge + additional questions, nothing else
- Use steel_man: Best case for current approach (full protocols in each droid) → Self-contained but duplicated. Best case for inheritance → DRY, maintainable, but requires AGENTS.md stability

---

## 🎯 Estimated Time: 4h 30min

**Breakdown:**
- NAUTILUS refactoring: 40 min
- ORACLE refactoring: 35 min
- FORGE refactoring: 35 min
- SENTINEL refactoring: 35 min
- RESEARCH refactoring: 25 min
- NANO versions: 1h (if needed)
- Validation & docs: 30 min
- Buffer for issues: 30 min

**Total:** 4h 30min

---

## 🚨 CRITICAL NOTES

1. **Backup BEFORE editing** - Create archive for every droid before changes
2. **One droid at a time** - Don't parallelize refactoring (high risk of mistakes)
3. **Validate between droids** - Test each one before moving to next
4. **Preserve domain knowledge** - When in doubt, KEEP (inheritance is for generic protocols only)
5. **Use REDUNDANCY_MAP.md** - Don't guess what's redundant, use FASE 1 analysis

---

**EXECUTE THIS PROMPT WITH:** claude-opus-4 (maximum precision required for large-scale refactoring)
