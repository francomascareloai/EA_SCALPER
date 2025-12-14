# LAYER 4: Overlap & Conflict Resolution Analysis

**Analysis Date:** 2025-12-07
**Analyst:** Elite Quantitative Research Analyst (deep-researcher subagent)
**Confidence:** HIGH (systematic overlap mapping + conflict scenario analysis)

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Overlaps Identified** | 4 major areas |
| **Conflict Scenarios** | 7 documented |
| **Resolution Framework** | 7-level authority hierarchy |
| **Merge Candidates** | 3 droids (research area) |
| **Handoffs Clarified** | 12 droid-to-droid |

---

## Overlap Analysis

### Overlap 1: Code Architecture (FORGE vs NAUTILUS)

#### Current State

| Aspect | FORGE | NAUTILUS |
|--------|-------|----------|
| **Purpose** | Python/Nautilus implementation | MQL5→Nautilus migration |
| **Handles** | Day-to-day coding, debugging | Architecture decisions |
| **Code Type** | Any Python trading code | NautilusTrader-specific |
| **Templates** | Anti-patterns, test scaffolds | Strategy/Actor/Backtest |

#### Overlap Zone

Both droids work with **NautilusTrader Python code**, causing confusion:

```
User: "I need to create a Strategy for gold scalping"

FORGE thinks: "I implement Python code with tests"
NAUTILUS thinks: "I design Strategy architecture and migration"

WHO TO INVOKE?
```

#### Resolution

```yaml
clear_boundaries:
  NAUTILUS:
    - High-level architecture decisions (Strategy vs Actor)
    - MQL5 → Nautilus migration mapping
    - Backtest setup (ParquetDataCatalog, BacktestNode)
    - Event-driven pattern guidance
    - Performance target definition
    
  FORGE:
    - Low-level implementation
    - Debugging (Deep Debug protocol)
    - Testing (pytest scaffolds)
    - Code quality (anti-patterns)
    - Context7 documentation queries

workflow:
  step_1: NAUTILUS designs architecture
  step_2: FORGE implements code
  step_3: NAUTILUS validates backtest setup
  step_4: FORGE fixes issues

routing_rule:
  "design Strategy" → NAUTILUS
  "implement Strategy" → FORGE
  "migrate from MQL5" → NAUTILUS
  "fix bug in Strategy" → FORGE
  "setup backtest" → NAUTILUS
```

#### Documentation Update

Add to AGENTS.md `<handoffs>`:

```xml
<handoff from="NAUTILUS" to="FORGE" trigger="implement">
  NAUTILUS designs architecture → FORGE implements
  Pass: Architecture spec, file locations, patterns to follow
</handoff>

<handoff from="FORGE" to="NAUTILUS" trigger="validate">
  FORGE implements → NAUTILUS validates backtest
  Pass: Code files, test results, backtest config
</handoff>
```

---

### Overlap 2: Code Review (FORGE vs code-architect-reviewer vs senior-code-reviewer)

#### Current State

| Droid | Focus | Depth |
|-------|-------|-------|
| FORGE | Python/Nautilus patterns | Day-to-day |
| code-architect-reviewer | Systemic review, consequences | Pre-commit |
| senior-code-reviewer | Generic best practices | N/A (archived?) |

**Note:** senior-code-reviewer doesn't exist in current inventory - may be outdated reference.

#### Overlap Zone

Both FORGE and code-architect-reviewer do code review:

- FORGE: `/review` command with 20-item checklist
- code-architect-reviewer: 5-layer review with consequence analysis

#### Resolution

```yaml
clear_boundaries:
  FORGE_review:
    - Day-to-day code quality
    - Python/Nautilus patterns
    - Anti-pattern detection
    - Quick 20-item checklist
    - Trigger: During development
    
  code-architect-reviewer:
    - Pre-commit comprehensive audit
    - Dependency mapping (upstream/downstream)
    - nth-order consequence analysis
    - Quality scoring (0-100)
    - Multi-solution ranking
    - Trigger: Before commit/deploy

workflow:
  during_development:
    - FORGE reviews incrementally
    - Catches immediate issues
    
  before_commit:
    - code-architect-reviewer runs full audit
    - Maps dependencies, consequences
    - Scores and approves/rejects

routing_rule:
  "review this code" → FORGE (during dev)
  "audit before commit" → code-architect-reviewer
  "pre-deploy review" → code-architect-reviewer
  "check my changes" → FORGE
```

---

### Overlap 3: Research (ARGUS vs research-analyst-pro vs deep-researcher)

#### Current State

| Droid | Focus | Size |
|-------|-------|------|
| argus-quant-researcher | Trading/quant research | 15KB |
| research-analyst-pro | Generic multi-source research | 31KB |
| deep-researcher | Deep research with critical thinking | 12KB |

**Total:** 58KB for essentially the same function

#### Overlap Zone

All three droids:
- Use multi-source triangulation
- Rate confidence levels (HIGH/MEDIUM/LOW)
- Search academic + practical + empirical sources
- Produce research reports

#### Resolution

**MERGE INTO SINGLE DROID: ARGUS v3.0**

```yaml
merged_droid:
  name: argus-quant-researcher
  version: 3.0
  
  from_argus:
    - Trading-specific keywords and priority areas
    - RAG database queries (mql5-books, mql5-docs)
    - Automatic alerts for suspicious claims
    
  from_research_analyst_pro:
    - Quality assurance checklist (condensed)
    - Report structure template
    
  from_deep_researcher:
    - Scientific critical thinking checklist
    - Multi-layer research phases
    
  inherits_from_agents_md:
    - Generic workflow templates
    - Output format templates
    - Constraints/guardrails

routing_rule:
  ANY research request → ARGUS (single point)
```

#### Actions

1. Merge into argus-quant-researcher.md (15KB target)
2. Archive research-analyst-pro.md
3. Archive deep-researcher.md
4. Update all references

---

### Overlap 4: Backtest Validation (ORACLE vs CRUCIBLE)

#### Current State

| Droid | Focus |
|-------|-------|
| ORACLE | Statistical validity (WFA, Monte Carlo, DSR) |
| CRUCIBLE | Execution realism (slippage, spread, fills) |

#### Overlap Zone

Both validate backtests, but with different focus:

```
ORACLE asks: "Are these results statistically robust?"
CRUCIBLE asks: "Does this backtest model real execution?"
```

#### Resolution

**These are COMPLEMENTARY, not duplicative**

```yaml
clear_workflow:
  step_1:
    droid: CRUCIBLE
    action: "Validate execution realism"
    check: "25 Realism Gates ≥90%"
    
  step_2:
    droid: ORACLE
    action: "Validate statistical robustness"
    check: "WFE≥0.6, DSR>0, PSR≥0.85"
    
  decision:
    both_pass: "GO for live"
    one_fails: "NO-GO, address issues"

handoff:
  CRUCIBLE → ORACLE:
    trigger: "Realism validated, check statistics"
    pass: Backtest config, realism score
    
  ORACLE → CRUCIBLE:
    trigger: "Stats look suspicious, verify realism"
    pass: Statistical concerns to investigate
```

#### Documentation Update

Add to AGENTS.md:

```xml
<complementary_roles>
  <pair>
    <droid_a>CRUCIBLE</droid_a>
    <droid_b>ORACLE</droid_b>
    <relationship>Complementary validators</relationship>
    <workflow>CRUCIBLE validates realism → ORACLE validates statistics</workflow>
    <both_required>Yes - both must PASS for GO decision</both_required>
  </pair>
</complementary_roles>
```

---

## Decision Matrix for Overlaps

| Scenario | Droid A | Droid B | Decision Rule |
|----------|---------|---------|---------------|
| "Review Python trading code" | FORGE | code-architect-reviewer | FORGE (day-to-day) |
| "Pre-commit audit" | FORGE | code-architect-reviewer | code-architect-reviewer |
| "Design Strategy architecture" | NAUTILUS | FORGE | NAUTILUS first, FORGE implements |
| "Research ML algo for trading" | ARGUS | (merged) | ARGUS (only option) |
| "Validate backtest results" | ORACLE | CRUCIBLE | Both sequentially |
| "Check backtest realism" | CRUCIBLE | ORACLE | CRUCIBLE |
| "Check statistical validity" | ORACLE | CRUCIBLE | ORACLE |
| "Migrate MQL5 to Python" | NAUTILUS | FORGE | NAUTILUS |
| "Fix bug in Strategy" | FORGE | NAUTILUS | FORGE |

---

## Conflict Resolution Framework

### Authority Hierarchy (7 Levels)

```xml
<decision_hierarchy>
  <description>
    When droids disagree, this hierarchy determines final authority.
    Lower priority number = higher authority (priority 1 beats priority 7).
  </description>
  
  <level priority="1" domain="risk_management">
    <droid>SENTINEL</droid>
    <authority>VETO on any trade/action if risk limits breached</authority>
    <veto_conditions>
      - Trailing DD >9%
      - Time <30min to 4:59 PM ET
      - Consistency rule >30%
      - Position size >1% risk
    </veto_conditions>
    <cannot_override>No droid can override SENTINEL veto</cannot_override>
  </level>
  
  <level priority="2" domain="validation">
    <droid>ORACLE</droid>
    <authority>GO/NO-GO decision on backtests and strategies</authority>
    <veto_conditions>
      - WFE <0.6
      - DSR ≤0
      - PSR <0.85
      - Monte Carlo 95th DD >10%
    </veto_conditions>
    <can_be_overridden_by>SENTINEL only (risk trumps validation)</can_be_overridden_by>
  </level>
  
  <level priority="3" domain="realism">
    <droid>CRUCIBLE</droid>
    <authority>Backtest realism validation</authority>
    <veto_conditions>
      - Realism Score <90%
      - Instant fills detected
      - No slippage model
    </veto_conditions>
    <can_be_overridden_by>SENTINEL, ORACLE</can_be_overridden_by>
  </level>
  
  <level priority="4" domain="strategy_design">
    <droid>CRUCIBLE (setup analysis)</droid>
    <authority>Setup quality recommendation</authority>
    <provides>
      - Confluence score
      - Setup tier (A/B/C)
      - Entry/exit levels
    </provides>
    <can_be_overridden_by>SENTINEL (risk), ORACLE (validation), CRUCIBLE (realism)</can_be_overridden_by>
  </level>
  
  <level priority="5" domain="architecture">
    <droid>NAUTILUS</droid>
    <authority>High-level architecture decisions</authority>
    <decides>
      - Strategy vs Actor pattern
      - Event-driven design
      - Migration approach
      - Performance targets
    </decides>
    <can_be_overridden_by>FORGE (implementation concerns), higher priorities</can_be_overridden_by>
  </level>
  
  <level priority="6" domain="implementation">
    <droid>FORGE</droid>
    <authority>Low-level implementation decisions</authority>
    <decides>
      - Code patterns
      - Test approach
      - Bug fixes
      - Performance optimization
    </decides>
    <can_be_overridden_by>NAUTILUS (architecture), higher priorities</can_be_overridden_by>
  </level>
  
  <level priority="7" domain="orchestration">
    <droid>ORCHESTRATOR</droid>
    <authority>Workflow coordination</authority>
    <role>
      - Invoke droids in correct order
      - Route requests to appropriate specialist
      - Track progress across sessions
    </role>
    <note>Coordinates but doesn't override domain authorities</note>
  </level>
</decision_hierarchy>
```

### Conflict Resolution Protocol

```xml
<conflict_resolution>
  <protocol name="Droid Disagreement Resolution">
    <trigger>Two or more droids provide contradictory recommendations</trigger>
    
    <steps>
      <step number="1">
        <action>Identify conflict domain</action>
        <domains>risk, validation, realism, strategy, architecture, implementation</domains>
      </step>
      
      <step number="2">
        <action>Check decision_hierarchy for domain authority</action>
        <lookup>Which droid has authority for this domain?</lookup>
      </step>
      
      <step number="3">
        <action>Domain authority droid has final say</action>
        <exception>Unless higher-priority droid has valid concern</exception>
      </step>
      
      <step number="4">
        <action>If still unclear, escalate to ORCHESTRATOR</action>
        <orchestrator_role>Mediate by gathering more context</orchestrator_role>
      </step>
      
      <step number="5">
        <action>If ORCHESTRATOR can't resolve, escalate to USER</action>
        <format>Present both sides with evidence and recommendation</format>
      </step>
    </steps>
  </protocol>
</conflict_resolution>
```

---

## Conflict Scenarios & Resolutions

### Scenario 1: CRUCIBLE GO vs SENTINEL BLOCK

```yaml
situation:
  CRUCIBLE: "Excellent setup! Confluence 9/10, Tier A. GO."
  SENTINEL: "Trailing DD at 8.9%. BLOCK - too close to limit."

resolution:
  step_1: Domain is RISK (DD concern)
  step_2: SENTINEL has priority 1 authority for risk
  step_3: SENTINEL veto WINS
  
  outcome: "Trade blocked despite excellent setup"
  rationale: "Account survival > great setup"
```

### Scenario 2: ORACLE NO-GO vs CRUCIBLE LOOKS GOOD

```yaml
situation:
  CRUCIBLE: "Setup looks great in backtest, 2.5 profit factor"
  ORACLE: "NO-GO. WFE 0.42 - below threshold. Overfitting suspected."

resolution:
  step_1: Domain is VALIDATION (statistical concern)
  step_2: ORACLE has priority 2 authority for validation
  step_3: ORACLE NO-GO WINS
  
  outcome: "Strategy rejected despite good-looking metrics"
  rationale: "Statistical validity > surface-level performance"
```

### Scenario 3: NAUTILUS Actor vs FORGE Inline

```yaml
situation:
  NAUTILUS: "Use Actor pattern for divergence detection - decoupled, reusable"
  FORGE: "Inline in Strategy for 2ms performance gain"

resolution:
  step_1: Domain is ARCHITECTURE (pattern decision)
  step_2: NAUTILUS has priority 5 authority for architecture
  step_3: NAUTILUS suggestion WINS
  
  outcome: "Actor pattern used"
  rationale: "Long-term maintainability > 2ms gain"
  
  exception:
    if: "Performance budget critically tight (<5ms slack)"
    then: "FORGE concern elevated, discuss tradeoff"
```

### Scenario 4: FORGE Bug Fix vs ORACLE Re-validation

```yaml
situation:
  FORGE: "Fixed the bug, ready to deploy"
  ORACLE: "Code changed. Previous validation INVALID. Re-run WFA."

resolution:
  step_1: Domain is VALIDATION (code change impact)
  step_2: ORACLE has authority on validation requirements
  step_3: ORACLE wins - re-validation REQUIRED
  
  outcome: "Deployment blocked until WFA re-run"
  rationale: "Bug fix could affect strategy behavior"
```

### Scenario 5: CRUCIBLE Realism vs ORACLE Statistics

```yaml
situation:
  CRUCIBLE: "Realism Score 92%, backtest is realistic"
  ORACLE: "Sharpe 4.2 is suspicious. Check for overfitting."

resolution:
  step_1: Both have valid concerns (realism vs statistics)
  step_2: Complementary validators - both must pass
  step_3: ORACLE concern wins - investigate overfitting
  
  outcome: "Further investigation required"
  workflow: "Even realistic backtest can be overfit"
```

### Scenario 6: ARGUS Research vs FORGE Implementation

```yaml
situation:
  ARGUS: "Research shows Shannon entropy effective for regime detection"
  FORGE: "But implementation would exceed OnTick budget by 10ms"

resolution:
  step_1: Domain crosses RESEARCH and IMPLEMENTATION
  step_2: FORGE has implementation authority
  step_3: Negotiate: Can ARGUS find faster approach?
  
  outcome: "Research finding adapted to implementation constraint"
  workflow: "ARGUS → find alternative OR FORGE → optimize implementation"
```

### Scenario 7: ORCHESTRATOR Routing Conflict

```yaml
situation:
  User: "I need help with my Strategy"
  ORCHESTRATOR: Routes to NAUTILUS (architecture)
  User intent: Actually wanted FORGE (debug issue)

resolution:
  step_1: ORCHESTRATOR should clarify ambiguous requests
  step_2: Ask: "Do you need architecture guidance or debugging help?"
  step_3: Route based on clarification
  
  prevention: "ORCHESTRATOR always clarifies before routing ambiguous requests"
```

---

## Handoffs Clarification

### Complete Handoff Map

| From | To | Trigger | Context to Pass |
|------|-----|---------|-----------------|
| ORCHESTRATOR | any | Route request | User intent, priority |
| CRUCIBLE | SENTINEL | Setup ready | SL, direction, tier, confluence |
| SENTINEL | ORACLE | Risk approved | Position size, DD state |
| ORACLE | FORGE | NO-GO (needs fix) | Failed metrics, areas to fix |
| ORACLE | CRUCIBLE | Check realism | Suspicious metrics |
| FORGE | ORACLE | Code complete | Changed files, test results |
| FORGE | NAUTILUS | Architecture question | Code context, design concern |
| NAUTILUS | FORGE | Design complete | Architecture spec, patterns |
| NAUTILUS | ORACLE | Backtest complete | Strategy config, results |
| ARGUS | FORGE | Research to implement | Findings, code patterns |
| ARGUS | CRUCIBLE | Research to strategy | Trading concepts to apply |
| code-architect-reviewer | FORGE | Issues found | Code locations, fixes needed |

### Handoff Protocol Template

```xml
<handoff_format>
  <header>
    <from_droid>[DROID NAME]</from_droid>
    <to_droid>[TARGET DROID]</to_droid>
    <trigger>[What triggered this handoff]</trigger>
  </header>
  
  <context>
    <summary>[1-2 sentence summary]</summary>
    <files>[Relevant files with paths]</files>
    <state>[Current state: complete/incomplete/blocked]</state>
  </context>
  
  <request>
    <action>[What the target droid should do]</action>
    <constraints>[Any constraints to respect]</constraints>
    <priority>[HIGH/MEDIUM/LOW]</priority>
  </request>
  
  <data>
    [Relevant data, metrics, or parameters]
  </data>
</handoff_format>
```

---

## Recommendations

### Immediate Actions

1. **Update AGENTS.md with expanded `<decision_hierarchy>`**
   - Add all 7 priority levels
   - Document veto conditions
   - Add `<conflict_resolution>` protocol

2. **Document handoffs in AGENTS.md**
   - Add `<handoffs>` section
   - Include all 12 droid-to-droid handoffs
   - Specify context to pass

3. **Merge overlapping research droids**
   - Combine argus + research-analyst-pro + deep-researcher
   - Keep ARGUS as the single research droid
   - Archive others

4. **Clarify FORGE vs code-architect-reviewer**
   - FORGE: Day-to-day development
   - code-architect-reviewer: Pre-commit audits
   - Add routing rules to ORCHESTRATOR

### Documentation Updates

Add to AGENTS.md:

```xml
<!-- Add after <agent_intelligence_gates> -->

<overlap_resolution>
  <overlap area="code_architecture">
    <droids>NAUTILUS, FORGE</droids>
    <rule>NAUTILUS designs → FORGE implements</rule>
  </overlap>
  
  <overlap area="code_review">
    <droids>FORGE, code-architect-reviewer</droids>
    <rule>FORGE (during dev) vs code-architect-reviewer (pre-commit)</rule>
  </overlap>
  
  <overlap area="research">
    <droids>ARGUS</droids>
    <note>Merged from argus + research-analyst-pro + deep-researcher</note>
  </overlap>
  
  <overlap area="backtest_validation">
    <droids>CRUCIBLE, ORACLE</droids>
    <rule>Complementary: CRUCIBLE (realism) → ORACLE (statistics)</rule>
  </overlap>
</overlap_resolution>

<routing_rules>
  <rule pattern="design Strategy|architecture" route_to="NAUTILUS"/>
  <rule pattern="implement|code|debug" route_to="FORGE"/>
  <rule pattern="review code|check changes" route_to="FORGE"/>
  <rule pattern="audit|pre-commit|pre-deploy" route_to="code-architect-reviewer"/>
  <rule pattern="research|investigate|find" route_to="ARGUS"/>
  <rule pattern="backtest realism|slippage|spread" route_to="CRUCIBLE"/>
  <rule pattern="validate|WFA|Monte Carlo|GO/NO-GO" route_to="ORACLE"/>
  <rule pattern="lot|risk|DD|position size" route_to="SENTINEL"/>
  <rule pattern="ML|ONNX|model|training" route_to="ONNX-MODEL-BUILDER"/>
</routing_rules>
```

---

## Appendix: Conflict Resolution Examples (Detailed)

### Example Output for Scenario 1

```markdown
┌─────────────────────────────────────────────────────────────┐
│ ⚔️ CONFLICT DETECTED                                        │
├─────────────────────────────────────────────────────────────┤
│ DROID A: CRUCIBLE                                          │
│ Recommendation: GO - Excellent setup, confluence 9/10      │
│                                                             │
│ DROID B: SENTINEL                                          │
│ Recommendation: BLOCK - DD 8.9%, too close to 10% limit    │
├─────────────────────────────────────────────────────────────┤
│ CONFLICT DOMAIN: RISK                                      │
│ AUTHORITY: SENTINEL (Priority 1)                           │
├─────────────────────────────────────────────────────────────┤
│ RESOLUTION: SENTINEL VETO WINS                             │
│                                                             │
│ Rationale:                                                  │
│ - Risk management has absolute priority                     │
│ - Account survival > great setup                            │
│ - 8.9% DD leaves only 1.1% buffer                          │
│ - One bad trade could breach 10% and terminate account     │
├─────────────────────────────────────────────────────────────┤
│ OUTCOME: Trade BLOCKED                                      │
│                                                             │
│ Next Steps:                                                │
│ - Wait for DD to recover below 7%                          │
│ - Or wait for HWM to increase (new peak equity)            │
│ - Setup may still be valid later                           │
└─────────────────────────────────────────────────────────────┘
```
