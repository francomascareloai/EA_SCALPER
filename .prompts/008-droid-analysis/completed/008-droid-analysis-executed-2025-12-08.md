# 🔍 PROMPT: Comprehensive Droid Ecosystem Analysis (V2.0)

## 📋 Objective

Executar análise **COMPLETA E HOLÍSTICA** do ecossistema de droids do projeto em **5 LAYERS**:

1. **LAYER 1:** TOP 5 droids optimization (redundancy mapping)
2. **LAYER 2:** Remaining 12 droids analysis (193KB não analisados)
3. **LAYER 3:** Gap analysis (droids críticos faltando)
4. **LAYER 4:** Overlap/conflict resolution framework
5. **LAYER 5:** Ecosystem health (versioning, quality gates, observability, dependency graph)

**Why it matters:** O plano v1.0 resolvia apenas 50% do problema (TOP 5 = 196KB de 389KB totais). Esta versão analisa TODO o ecossistema, identifica gaps críticos (security, performance, data-pipeline, monitoring, deployment), resolve overlaps/conflicts, e cria framework de qualidade para garantir saúde do sistema a longo prazo.

**Genius-level approach:** Um gênio não otimiza só o que existe - analisa o sistema holisticamente, identifica o que falta, resolve conflicts, e estabelece processos para evitar degradação futura.

---

## 📁 Context

**Master Plan:**
@.factory/specs/2025-12-07-plano-otimiza-o-completa-dos-droids-token-efficiency-consistency.md

**Base Framework:**
@AGENTS.md (v3.4.1 com strategic_intelligence, genius_mode_templates, complexity_assessment)

**Current Droid Inventory (17 droids, 389KB total):**

**TOP 5 (196KB, 50%):**
- @.factory/droids/nautilus-trader-architect.md (53KB)
- @.factory/droids/oracle-backtest-commander.md (38KB)
- @.factory/droids/forge-mql5-architect.md (37KB)
- @.factory/droids/sentinel-apex-guardian.md (37KB)
- @.factory/droids/research-analyst-pro.md (31KB)

**REMAINING 12 (193KB, 50%):**
- @.factory/droids/code-architect-reviewer.md
- @.factory/droids/crucible-gold-strategist.md
- @.factory/droids/onnx-model-builder.md ⚠️ **CRITICAL - ML models**
- @.factory/droids/ea-scalper-xauusd-orchestrator.md ⚠️ **MAESTRO candidate**
- @.factory/droids/project-reader.md
- @.factory/droids/trading-project-documenter.md
- @.factory/droids/ai-engineer.md (personal)
- @.factory/droids/backend-typescript-architect.md (personal)
- @.factory/droids/business-analyst.md (personal)
- @.factory/droids/database-optimizer.md (personal)
- @.factory/droids/senior-code-reviewer.md (personal)
- @.factory/droids/ui-engineer.md (personal)

**Skills (alternative invocation):**
- @.factory/skills/argus/SKILL.md (argus-research-analyst)
- @.factory/skills/crucible/SKILL.md (crucible-nano)
- @.factory/skills/forge/SKILL.md (forge-nano)
- @.factory/skills/oracle/SKILL.md (oracle-nano)
- @.factory/skills/sentinel/SKILL.md (sentinel-apex-guardian)
- @.factory/skills/nautilus/SKILL.md (nautilus-nano)

**Project Structure:**
```
nautilus_gold_scalper/
├── src/
│   ├── strategies/    (NAUTILUS?)
│   ├── actors/        (NAUTILUS?)
│   ├── indicators/    (???)
│   ├── risk/          (SENTINEL)
│   ├── execution/     (???)
│   └── signals/       (CRUCIBLE?)
├── configs/           (???)
├── scripts/           (???)
└── tests/             (FORGE? ORACLE?)
```

---

## 🎯 Requirements

---

### 🔴 LAYER 1: TOP 5 Optimization (Redundancy Mapping)

**Objetivo:** Mapear redundâncias linha-por-linha nos TOP 5 droids para herança do AGENTS.md.

#### 1.1 Para CADA droid (NAUTILUS, ORACLE, FORGE, SENTINEL, RESEARCH):

**A. Identificar Seções Duplicadas do AGENTS.md:**
- Protocols genéricos (NEVER/ALWAYS/MUST rules em `<strategic_intelligence>`)
- Genius templates (output formats, checklists em `<genius_mode_templates>`)
- Complexity assessment (SIMPLE/MEDIUM/COMPLEX/CRITICAL rules)
- Error recovery patterns (já em `<error_recovery>`)
- Enforcement validation (já em `<enforcement_validation>`)
- Pattern learning (já em `<pattern_learning>`)

**B. Extrair Conhecimento Único de Domínio:**

**NAUTILUS:**
- MQL5 → Python migration mappings (OnInit → on_start, OnTick → on_quote_tick)
- Event-driven architecture patterns (MessageBus, Cache, Actor vs Strategy)
- Performance targets (<1ms on_bar, <100μs on_tick)
- ParquetDataCatalog / BacktestNode setup

**ORACLE:**
- Statistical thresholds (WFE ≥0.6, DSR >0, PSR ≥0.85, MC_95th_DD<5%, SQN >2.0)
- Walk-Forward formulas (IS/OOS split, purged CV)
- Monte Carlo specifications (Block bootstrap, 5000 runs)
- GO/NO-GO gates (7-step checklist)

**FORGE:**
- Python/Nautilus-specific anti-patterns (circular imports, mutable defaults, blocking)
- Deep Debug protocol
- Context7 integration for NautilusTrader docs
- Test scaffolding templates (pytest fixtures)

**SENTINEL:**
- Apex Trading formulas (10% trailing DD from HWM, 4:59 PM ET deadline)
- Position sizing formulas (Kelly, time multiplier, DD awareness)
- Circuit breaker levels (WARNING/CAUTION/DANGER/BLOCKED)
- Recovery protocols específicos de Apex

**RESEARCH-ANALYST-PRO:**
- Multi-source triangulation methodology
- Source credibility rating system
- Confidence level frameworks
- Research log structure

**C. Definir 3 Additional Reflection Questions por droid**

**D. Calcular Savings:**
- Before size: {XX}KB
- Remove: {YY}KB (redundant)
- Keep: {ZZ}KB (domain knowledge)
- After size: {ZZ}KB
- Savings: {YY}KB ({PP}%)

#### 1.2 Output para LAYER 1:

**File:** `REDUNDANCY_MAP_TOP5.md`

Estrutura detalhada (same as original prompt) com:
- Executive summary
- Per-droid analysis (redundancies + domain knowledge + questions)
- Aggregate savings
- Inheritance map

---

### 🟠 LAYER 2: Remaining 12 Droids Analysis

**Objetivo:** Analisar os 12 droids restantes (193KB) para redundância, especialização, e prioridade.

#### 2.1 Para CADA droid dos remaining 12:

**A. Size Analysis:**
- Current size in KB
- Estimated redundancy % (compare with AGENTS.md)
- Potential savings

**B. Specialization Analysis:**
- What domain does this droid cover?
- Is it project-specific or personal/generic?
- Overlap with TOP 5 droids?

**C. Priority Ranking:**
- **CRITICAL:** Used frequently, project-essential (e.g., onnx-model-builder, orchestrator)
- **HIGH:** Used occasionally, important (e.g., crucible, code-architect-reviewer)
- **MEDIUM:** Used rarely, nice-to-have (e.g., project-reader, trading-project-documenter)
- **LOW:** Never used, consider removing (TBD)

**D. Refactoring Recommendation:**
- **REFACTOR NOW:** High priority + high savings (>60%)
- **REFACTOR LATER:** Medium priority or medium savings (30-60%)
- **KEEP AS-IS:** Low priority or low savings (<30%)
- **REMOVE/MERGE:** Never used or complete overlap

#### 2.2 Special Focus: Critical Droids

**🎯 ea-scalper-xauusd-orchestrator.md:**
- **Hypothesis:** This should be the MAESTRO that coordinates all other droids
- **Current usage:** Likely underutilized
- **Potential:** Central coordination hub for complex workflows (setup → backtest → validate → deploy)
- **Analysis:**
  - Does it coordinate other droids?
  - Does it have dependency graph?
  - Does it invoke droids in correct order?
  - Should it replace manual "invoke CRUCIBLE then SENTINEL then ORACLE" workflow?

**🤖 onnx-model-builder.md:**
- **Critical because:** ML models for direction prediction, regime detection
- **Usage pattern:** How often invoked? With which other droids?
- **Integration:** Does it hand off to ORACLE for validation? To FORGE for integration?

**⚔️ crucible-gold-strategist.md:**
- **Overlap with:** ORACLE (both analyze setups/strategies)
- **Specialization:** XAUUSD-specific, SMC patterns
- **Refactor?** Or keep specialized?

#### 2.3 Personal vs Project Droids

**Personal droids (7):**
- ai-engineer, backend-typescript-architect, business-analyst, database-optimizer, senior-code-reviewer, ui-engineer, plus others
- **Question:** Are these used for THIS project or generic?
- **Decision:** If generic and rarely used → deprioritize refactoring

**Project droids (10):**
- Focus refactoring effort here

#### 2.4 Output para LAYER 2:

**File:** `REMAINING_12_ANALYSIS.md`

```markdown
# Remaining 12 Droids Analysis

## Executive Summary
- Total size: {XX}KB
- Estimated redundancy: {YY}% ({ZZ}KB)
- Potential savings: {WW}KB
- Critical droids: {list}
- Low-priority droids: {list}

## Per-Droid Analysis

### ea-scalper-xauusd-orchestrator (CRITICAL)
- Size: {XX}KB
- Redundancy: {YY}%
- Specialization: Central coordination, droid orchestration
- Priority: CRITICAL (should be MAESTRO)
- Recommendation: REFACTOR NOW + ELEVATE TO MAESTRO ROLE
- Current issues: {list}
- Proposed enhancements: {list}

### onnx-model-builder (CRITICAL)
- Size: {XX}KB
- Redundancy: {YY}%
- Specialization: ML model training, ONNX export for MQL5/Python
- Priority: CRITICAL (ML is core to strategy)
- Recommendation: REFACTOR NOW
- Integration gaps: {Does it hand off to ORACLE? To FORGE?}

### crucible-gold-strategist
- Size: {XX}KB
- Redundancy: {YY}%
- Specialization: XAUUSD setups, SMC analysis
- Priority: HIGH
- Overlap: ORACLE (both analyze strategies)
- Recommendation: REFACTOR LATER (after TOP 5)

[Continue for all 12...]

## Priority Matrix

| Droid | Size | Redundancy | Priority | Recommendation |
|-------|------|------------|----------|----------------|
| orchestrator | {XX}KB | {YY}% | CRITICAL | REFACTOR NOW + MAESTRO |
| onnx-model-builder | {XX}KB | {YY}% | CRITICAL | REFACTOR NOW |
| crucible | {XX}KB | {YY}% | HIGH | REFACTOR LATER |
| ... | ... | ... | ... | ... |

## Refactoring Roadmap

**Phase 1 (with TOP 5):**
- orchestrator (MAESTRO role)
- onnx-model-builder (ML critical)

**Phase 2 (after TOP 5):**
- crucible
- code-architect-reviewer
- project-reader

**Phase 3 (lower priority):**
- trading-project-documenter
- personal droids (if used for project)

**Consider removal:**
- {droids never used}
```

---

### 🟡 LAYER 3: Gap Analysis (Droids Faltando)

**Objetivo:** Identificar droids críticos que DEVERIAM existir mas NÃO existem.

#### 3.1 Critical Gaps Identified:

**🔐 GAP 1: SECURITY-COMPLIANCE Droid**

**Why critical:**
- Trading system handles real money
- Apex Trading compliance requirements (10% DD, 4:59 PM, 30% consistency)
- API keys for brokers, data feeds (Twelve-Data, Tradovate)
- Risk of: Credential leaks, compliance violations, unauthorized access

**Proposed droid:**
```
security-compliance-guardian.md
├─ Security audit: Scan code for hardcoded secrets, insecure patterns
├─ Credential management: Validate .env usage, no secrets in code/logs
├─ Compliance validation: Verify Apex rules enforced (DD, time, consistency)
├─ Access control: Who can modify risk params? Who can deploy?
└─ Audit trail: Log all sensitive operations
```

**Urgency:** HIGH (money + compliance = can't fail)

---

**⚡ GAP 2: PERFORMANCE-OPTIMIZER Droid**

**Why critical:**
- OnTick budget <50ms is CRITICAL for trading system
- Python performance bottlenecks (loops, memory leaks, blocking I/O)
- ONNX inference <5ms budget
- Risk of: Missed trades, slippage, execution delays

**Proposed droid:**
```
performance-optimizer.md
├─ Profiling: cProfile, line_profiler, memory_profiler on Python modules
├─ Bottleneck analysis: Identify O(n²) algorithms, unnecessary loops
├─ Optimization suggestions: Numpy vectorization, Cython compilation, async patterns
├─ Budget tracking: OnTick timing, ONNX inference timing, memory usage
└─ Regression prevention: Performance tests, budget alerts
```

**Urgency:** HIGH (performance = $$$)

---

**📊 GAP 3: DATA-PIPELINE Droid**

**Why critical:**
- ParquetDataCatalog: Data ingestion, storage, retrieval
- Twelve-Data MCP: Real-time + historical data
- Data quality: Bad data = bad backtests = bad decisions
- Risk of: Look-ahead bias, missing data, corrupted feeds

**Proposed droid:**
```
data-pipeline-engineer.md
├─ Data ingestion: Twelve-Data → Parquet (with validation)
├─ Data cleaning: Handle gaps, duplicates, outliers
├─ Data validation: Timestamp correctness, OHLCV integrity
├─ Storage optimization: Parquet compression, partitioning
└─ Quality monitoring: Data freshness, feed health
```

**Urgency:** MEDIUM-HIGH (quality data = quality decisions)

---

**📡 GAP 4: MONITORING-ALERTING Droid**

**Why critical:**
- Trailing DD monitoring (real-time, not just on trade)
- Equity curve tracking (detect anomalies)
- Position status (stuck positions, overnight risk)
- Risk of: Blow account without noticing, miss critical alerts

**Proposed droid:**
```
monitoring-alerting-operator.md
├─ Real-time monitoring: Trailing DD, equity, position status
├─ Alerting: Slack/email when DD >8%, equity drop >5%, stuck position
├─ Anomaly detection: Unusual drawdown patterns, execution delays
├─ Dashboard: Real-time metrics (DD, equity curve, win rate, Sharpe)
└─ Circuit breaker integration: Trigger SENTINEL emergency protocols
```

**Urgency:** MEDIUM (safety net)

---

**🚀 GAP 5: DEPLOYMENT-DEVOPS Droid**

**Why critical:**
- Deploy to production (live trading environment)
- Environment management (dev/staging/prod configs)
- Rollback on failure (revert to last stable version)
- Risk of: Manual deployment errors, downtime, configuration drift

**Proposed droid:**
```
deployment-devops-engineer.md
├─ CI/CD pipeline: Automated testing → build → deploy
├─ Environment management: Dev/staging/prod configs, secrets management
├─ Deployment: Blue-green deployment, canary releases
├─ Rollback: Automated rollback on failure detection
└─ Health checks: Post-deployment validation, smoke tests
```

**Urgency:** MEDIUM (maturity)

---

#### 3.2 Evaluation Framework for Gaps:

For each proposed droid:

**A. Justification:**
- What problem does it solve?
- What's the risk if it doesn't exist?
- Is there a workaround? (Manual process, external tool)

**B. Priority:**
- CRITICAL: Must have, high risk
- HIGH: Should have, medium risk
- MEDIUM: Nice to have, low risk
- LOW: Optional, negligible risk

**C. Implementation Effort:**
- SIMPLE: <1 day
- MEDIUM: 1-3 days
- COMPLEX: >3 days

**D. ROI (Return on Investment):**
- HIGH: Prevents catastrophic failure (security, compliance)
- MEDIUM: Improves efficiency significantly (performance, monitoring)
- LOW: Incremental improvement (devops, documentation)

#### 3.3 Output para LAYER 3:

**File:** `GAP_ANALYSIS.md`

```markdown
# Droid Gap Analysis

## Executive Summary
- Gaps identified: 5 critical droids missing
- Highest priority: SECURITY-COMPLIANCE (compliance + money)
- Total estimated effort: {XX} days
- Risk without gaps filled: {HIGH/MEDIUM/LOW}

## Gap Details

### GAP 1: SECURITY-COMPLIANCE Droid
- **Why critical:** {justification}
- **Risk if missing:** {credential leaks, compliance violations}
- **Priority:** CRITICAL
- **Effort:** MEDIUM (2-3 days)
- **ROI:** HIGH (prevents catastrophic failure)
- **Workaround:** Manual security audits (not scalable)
- **Recommendation:** CREATE IMMEDIATELY

### GAP 2: PERFORMANCE-OPTIMIZER Droid
[Same structure]

[Continue for all 5 gaps...]

## Priority Matrix

| Gap | Priority | Effort | ROI | Recommendation |
|-----|----------|--------|-----|----------------|
| Security-Compliance | CRITICAL | MEDIUM | HIGH | CREATE NOW |
| Performance-Optimizer | HIGH | MEDIUM | HIGH | CREATE SOON |
| Data-Pipeline | MEDIUM | COMPLEX | MEDIUM | CREATE LATER |
| Monitoring-Alerting | MEDIUM | MEDIUM | MEDIUM | CREATE LATER |
| Deployment-DevOps | LOW | COMPLEX | LOW | OPTIONAL |

## Implementation Roadmap

**Phase 1 (Immediate):**
- Security-Compliance droid
- Performance-Optimizer droid

**Phase 2 (After TOP 5 refactoring):**
- Data-Pipeline droid
- Monitoring-Alerting droid

**Phase 3 (Optional):**
- Deployment-DevOps droid
```

---

### 🟢 LAYER 4: Overlap/Conflict Resolution

**Objetivo:** Identificar e resolver overlaps entre droids e estabelecer conflict resolution framework.

#### 4.1 Overlap Analysis:

**A. Identify Overlapping Droids:**

**Overlap 1: Code Architecture**
- **Droids:** FORGE (Python/Nautilus code) vs NAUTILUS (Migration/Strategy/Actor)
- **Overlap:** Both work with NautilusTrader Python code
- **Confusion:** When to invoke FORGE vs NAUTILUS?
- **Resolution:**
  - **NAUTILUS:** Migration from MQL5, high-level architecture (Strategy vs Actor decision), Backtest setup
  - **FORGE:** Low-level Python implementation, debugging, testing, code quality
  - **Handoff:** NAUTILUS designs → FORGE implements → NAUTILUS validates backtest
- **Document in:** `<handoffs>` section of AGENTS.md

**Overlap 2: Code Review**
- **Droids:** FORGE (/review trigger) vs code-architect-reviewer vs senior-code-reviewer
- **Overlap:** All do code review
- **Confusion:** Which one to invoke?
- **Resolution:**
  - **FORGE:** Python/Nautilus code review (domain-specific patterns)
  - **code-architect-reviewer:** Architecture/design review (high-level)
  - **senior-code-reviewer:** General best practices, security, performance
  - **Decision:** MERGE code-architect-reviewer + senior-code-reviewer into one (generic-code-reviewer), keep FORGE for domain-specific

**Overlap 3: Research**
- **Droids:** ARGUS (quant research) vs research-analyst-pro
- **Overlap:** Both do research with triangulation
- **Confusion:** Different names, similar function
- **Resolution:**
  - **ARGUS:** Trading/quant-specific research (papers, backtest validation, algo design)
  - **research-analyst-pro:** General multi-source research
  - **Decision:** Keep both OR merge into one with domain parameter

**Overlap 4: Backtest**
- **Droids:** ORACLE (validation) vs NAUTILUS (backtest setup)
- **Overlap:** Both involve backtesting
- **Confusion:** Who does what?
- **Resolution:**
  - **NAUTILUS:** Backtest SETUP (ParquetDataCatalog, BacktestNode, configs)
  - **ORACLE:** Backtest VALIDATION (WFA, Monte Carlo, GO/NO-GO decision)
  - **Handoff:** NAUTILUS sets up → runs backtest → ORACLE validates results
- **Clear in:** dependency graph (DAG)

**B. Decision Matrix for Overlaps:**

| Scenario | Droid A | Droid B | Decision Rule |
|----------|---------|---------|---------------|
| "Review Python trading code" | FORGE | senior-code-reviewer | Use FORGE (domain-specific) |
| "Design Strategy architecture" | NAUTILUS | FORGE | Use NAUTILUS (high-level), FORGE implements |
| "Research ML algo for trading" | ARGUS | research-analyst-pro | Use ARGUS (trading-specific) |
| "Validate backtest results" | ORACLE | NAUTILUS | Use ORACLE (validation is its domain) |

#### 4.2 Conflict Resolution Framework:

**A. Authority Hierarchy (expand AGENTS.md `<decision_hierarchy>`):**

**Current (incomplete):**
```xml
<decision_hierarchy>
  <level priority="1">SENTINEL (veto on risk)</level>
  <level priority="2">ORACLE (validation authority)</level>
  <level priority="3">CRUCIBLE (setup recommendation)</level>
</decision_hierarchy>
```

**Expanded (complete):**
```xml
<decision_hierarchy>
  <description>
    When droids disagree, this hierarchy determines who has final authority.
    Lower priority number = higher authority (priority 1 beats priority 2).
  </description>
  
  <level priority="1" domain="risk_management">
    <droid>SENTINEL</droid>
    <authority>VETO on any trade if DD >9%, time <30min to 4:59 PM, or consistency >30%</authority>
    <cannot_override>No other droid can override SENTINEL veto</cannot_override>
  </level>
  
  <level priority="2" domain="validation">
    <droid>ORACLE</droid>
    <authority>GO/NO-GO decision on backtests, NO-GO if WFE <0.6 or DSR ≤0</authority>
    <cannot_override>SENTINEL can veto (priority 1) but no one else</cannot_override>
  </level>
  
  <level priority="3" domain="strategy_design">
    <droid>CRUCIBLE</droid>
    <authority>Setup recommendation (confluence score, setup quality)</authority>
    <can_be_overridden_by>SENTINEL (risk), ORACLE (validation)</can_be_overridden_by>
  </level>
  
  <level priority="4" domain="architecture">
    <droid>NAUTILUS</droid>
    <authority>High-level architecture decisions (Strategy vs Actor, event-driven patterns)</authority>
    <can_be_overridden_by>FORGE (if implementation concerns)</can_be_overridden_by>
  </level>
  
  <level priority="5" domain="implementation">
    <droid>FORGE</droid>
    <authority>Low-level implementation, code quality, testing</authority>
    <can_be_overridden_by>NAUTILUS (if architecture conflict), SENTINEL (if performance risk)</can_be_overridden_by>
  </level>
  
  <level priority="6" domain="research">
    <droid>ARGUS</droid>
    <authority>Research findings, source credibility</authority>
    <can_be_overridden_by>ORACLE (if contradicts backtest), SENTINEL (if risk concern)</can_be_overridden_by>
  </level>
  
  <level priority="7" domain="orchestration">
    <droid>ORCHESTRATOR</droid>
    <authority>Workflow coordination, droid invocation order</authority>
    <note>Coordinates but doesn't override domain authorities</note>
  </level>
</decision_hierarchy>
```

**B. Conflict Resolution Protocol:**

```xml
<conflict_resolution>
  <protocol name="Droid Disagreement">
    <trigger>Two or more droids provide contradictory recommendations</trigger>
    
    <steps>
      <step number="1">Identify which domain the conflict is in (risk, validation, strategy, etc)</step>
      <step number="2">Check decision_hierarchy for domain authority</step>
      <step number="3">Domain authority droid has final say</step>
      <step number="4">If still unclear, escalate to ORCHESTRATOR for mediation</step>
      <step number="5">If ORCHESTRATOR can't resolve, escalate to USER</step>
    </steps>
    
    <example>
      <scenario>
        CRUCIBLE recommends trade (confluence score 9/10, excellent setup)
        SENTINEL blocks (trailing DD 8.9%, too close to limit)
      </scenario>
      <resolution>
        Step 1: Domain = risk_management
        Step 2: SENTINEL has priority 1 authority for risk
        Step 3: SENTINEL veto WINS
        Step 4: No escalation needed
        Outcome: Trade blocked
      </resolution>
    </example>
    
    <example>
      <scenario>
        NAUTILUS suggests Actor pattern for divergence detection
        FORGE suggests inline implementation for performance
      </scenario>
      <resolution>
        Step 1: Domain = architecture (high-level) vs implementation (low-level)
        Step 2: NAUTILUS priority 4 (architecture), FORGE priority 5 (implementation)
        Step 3: NAUTILUS suggestion wins (Actor pattern)
        Step 4: FORGE implements Actor pattern (follows NAUTILUS decision)
        Outcome: Actor pattern used
      </resolution>
    </example>
  </protocol>
</conflict_resolution>
```

#### 4.3 Output para LAYER 4:

**File:** `OVERLAP_CONFLICT_ANALYSIS.md`

```markdown
# Overlap & Conflict Analysis

## Executive Summary
- Overlaps identified: 4 major areas (code architecture, code review, research, backtest)
- Conflicts possible: {XX} scenarios
- Resolution framework: Authority hierarchy + conflict resolution protocol
- Recommendation: Update AGENTS.md with expanded `<decision_hierarchy>` and `<conflict_resolution>`

## Overlap Details

### Overlap 1: Code Architecture (FORGE vs NAUTILUS)
- **Droids involved:** FORGE, NAUTILUS
- **Overlap area:** Both work with NautilusTrader Python code
- **Confusion factor:** HIGH (users don't know which to invoke)
- **Resolution:**
  - NAUTILUS: High-level architecture, migration, Strategy vs Actor decision
  - FORGE: Low-level implementation, debugging, testing
  - Handoff: NAUTILUS designs → FORGE implements
- **Document in:** `<handoffs>` section of AGENTS.md

[Continue for all overlaps...]

## Conflict Scenarios

### Scenario 1: SENTINEL blocks but CRUCIBLE insists
- **Current state:** No clear resolution protocol
- **Proposed resolution:** SENTINEL priority 1 (risk) beats CRUCIBLE priority 3 (strategy)
- **Outcome:** Trade blocked (SENTINEL veto wins)

### Scenario 2: ORACLE says NO-GO but CRUCIBLE says setup is 10/10
- **Current state:** Conflict not addressed
- **Proposed resolution:** ORACLE priority 2 (validation) beats CRUCIBLE priority 3 (setup)
- **Outcome:** NO-GO decision wins (don't trade even if setup looks good)

[Continue for all conflict scenarios...]

## Decision Matrix

| Conflict | Droid A (recommendation) | Droid B (recommendation) | Winner | Reason |
|----------|--------------------------|--------------------------|--------|--------|
| Trade decision | CRUCIBLE (GO) | SENTINEL (BLOCK) | SENTINEL | Priority 1 > Priority 3 |
| Backtest | ORACLE (NO-GO) | CRUCIBLE (LOOKS GOOD) | ORACLE | Priority 2 > Priority 3 |
| Architecture | NAUTILUS (Actor) | FORGE (inline) | NAUTILUS | Priority 4 > Priority 5 |

## Recommendations

1. **Update AGENTS.md:**
   - Expand `<decision_hierarchy>` with all 7 priority levels
   - Add `<conflict_resolution>` protocol with examples

2. **Document handoffs:**
   - NAUTILUS → FORGE (design → implement)
   - NAUTILUS → ORACLE (backtest setup → validation)
   - CRUCIBLE → SENTINEL (setup → risk check)
   - ORACLE → FORGE (validation feedback → fixes)

3. **Merge overlapping droids:**
   - code-architect-reviewer + senior-code-reviewer → generic-code-reviewer
   - Keep FORGE for domain-specific Python/Nautilus reviews

4. **Clarify routing rules:**
   - Add decision matrix to AGENTS.md
   - "Review Python trading code" → FORGE
   - "Review generic TypeScript" → generic-code-reviewer
```

---

### 🔵 LAYER 5: Ecosystem Health

**Objetivo:** Estabelecer processos para garantir saúde do ecossistema de droids a longo prazo.

#### 5.1 Versioning & Tracking:

**A. Version Registry:**

Add to AGENTS.md:
```xml
<droid_versions>
  <description>
    Central registry of all droid versions. Updated after each refactoring.
    Used to ensure sessions use latest versions.
  </description>
  
  <droid name="NAUTILUS" current_version="2.1" refactored="2025-12-07">
    <changelog>
      <version number="2.1">Inheritance from AGENTS.md v3.4.1, 72% token reduction</version>
      <version number="2.0">Initial version with full protocols</version>
    </changelog>
    <file>.factory/droids/nautilus-trader-architect.md</file>
    <size>15KB</size>
  </droid>
  
  <droid name="ORACLE" current_version="2.1" refactored="2025-12-07">
    <changelog>
      <version number="2.1">Inheritance from AGENTS.md v3.4.1, 68% token reduction</version>
      <version number="2.0">Initial version</version>
    </changelog>
    <file>.factory/droids/oracle-backtest-commander.md</file>
    <size>12KB</size>
  </droid>
  
  <!-- Continue for all droids -->
</droid_versions>
```

**B. Version Checking:**

Protocol for ensuring correct version used:
1. When Task agent invokes droid, check `<droid_versions>` for current_version
2. Load droid file from specified path
3. Verify version metadata in droid file matches registry
4. If mismatch → warn user + suggest update

#### 5.2 Quality Gates:

**A. Post-Refactoring Validation:**

For EACH refactored droid, run quality gate:

```python
# Pseudo-code for quality gate
def validate_refactored_droid(droid_name, version_before, version_after):
    """
    Validates that refactored droid maintains functionality while reducing size.
    """
    # 1. Size check
    size_before = get_droid_size(droid_name, version_before)
    size_after = get_droid_size(droid_name, version_after)
    assert size_after < size_before * 0.5, f"Size reduction <50% (target: 60-70%)"
    
    # 2. Domain knowledge check
    domain_knowledge_before = extract_domain_knowledge(droid_name, version_before)
    domain_knowledge_after = extract_domain_knowledge(droid_name, version_after)
    similarity = semantic_similarity(domain_knowledge_before, domain_knowledge_after)
    assert similarity > 0.95, f"Domain knowledge loss detected (similarity: {similarity})"
    
    # 3. Functional test
    test_tasks = get_test_tasks(droid_name)  # e.g., "Explain Actor vs Strategy" for NAUTILUS
    for task in test_tasks:
        output_before = invoke_droid(droid_name, version_before, task)
        output_after = invoke_droid(droid_name, version_after, task)
        semantic_match = semantic_similarity(output_before, output_after)
        assert semantic_match > 0.85, f"Output mismatch for task: {task}"
    
    # 4. Inheritance check
    inheritance_section = extract_section(droid_name, version_after, "<inheritance>")
    assert inheritance_section is not None, "Missing <inheritance> section"
    assert "AGENTS.md v3.4.1" in inheritance_section, "Not inheriting from correct AGENTS.md version"
    
    # 5. Additional questions check
    questions = extract_section(droid_name, version_after, "<additional_reflection_questions>")
    assert len(questions) == 3, f"Expected 3 additional questions, found {len(questions)}"
    
    return {
        "droid": droid_name,
        "size_reduction": (size_before - size_after) / size_before * 100,
        "knowledge_similarity": similarity,
        "functional_tests_passed": len(test_tasks),
        "status": "PASS"
    }
```

**Test tasks per droid:**
```
NAUTILUS test tasks:
1. "Explain Actor vs Strategy pattern in NautilusTrader"
2. "How to migrate MQL5 OnTick() to Nautilus?"
3. "What's the performance budget for on_bar handler?"

ORACLE test tasks:
1. "What's the WFE threshold for GO decision?"
2. "Explain Walk-Forward Efficiency calculation"
3. "How many Monte Carlo runs required?"

FORGE test tasks:
1. "How to avoid blocking in on_bar handler?"
2. "What's the Deep Debug protocol?"
3. "How to use pytest fixtures for NautilusTrader?"

SENTINEL test tasks:
1. "Calculate trailing DD with unrealized P&L"
2. "What's the circuit breaker level at 8.5% DD?"
3. "Explain position sizing formula with time multiplier"

RESEARCH test tasks:
1. "What confidence level for single arXiv paper?"
2. "Explain multi-source triangulation methodology"
3. "How to rate source credibility?"
```

**B. Continuous Quality Monitoring:**

Add to AGENTS.md:
```xml
<quality_monitoring>
  <metrics>
    <metric name="droid_invocation_count">Track how often each droid is used</metric>
    <metric name="droid_error_rate">Track failures per droid</metric>
    <metric name="droid_avg_execution_time">Track performance</metric>
    <metric name="droid_output_quality">User feedback on output quality (thumbs up/down)</metric>
  </metrics>
  
  <storage>memory MCP - knowledge graph</storage>
  
  <entity type="droid_invocation">
    <attributes>
      droid_name, timestamp, task_summary, execution_time_seconds, 
      status (success/failure), output_length, user_feedback (1-5 stars)
    </attributes>
  </entity>
  
  <reporting frequency="weekly">
    <report name="Droid Health Dashboard">
      - Most used droids (top 10)
      - Highest error rate droids (need fixes)
      - Slowest droids (need optimization)
      - Lowest rated droids (need improvement)
      - Unused droids (consider removal)
    </report>
  </reporting>
</quality_monitoring>
```

#### 5.3 Dependency Graph (DAG):

**A. Identify Dependencies:**

Map dependencies between droids based on handoffs:

```
CRUCIBLE (setup analysis)
    ↓ (hands off setup to)
SENTINEL (risk check)
    ↓ (if approved, hands off to)
NAUTILUS (backtest setup)
    ↓ (hands off backtest results to)
ORACLE (backtest validation)
    ↓ (if NO-GO, hands off issues to)
FORGE (implement fixes)
    ↓ (fixed code handed back to)
NAUTILUS (re-test)
    ↓ (loop until GO)
ORACLE (final validation)
    ↓ (if GO, hands off to)
DEPLOYMENT (optional - Gap 5 droid)
```

**B. Document DAG:**

Add to AGENTS.md:
```xml
<dependency_graph>
  <description>
    Directed Acyclic Graph (DAG) of droid dependencies.
    Shows which droids depend on output of which other droids.
    Used for automatic workflow orchestration.
  </description>
  
  <workflow name="Strategy Development & Deployment">
    <step order="1" droid="CRUCIBLE" output="setup_analysis.md">
      Analyze XAUUSD setup, calculate confluence score
    </step>
    <step order="2" droid="SENTINEL" input="setup_analysis.md" output="risk_decision.md">
      Validate risk constraints (DD, time, consistency)
      Can VETO if risk too high
    </step>
    <step order="3" droid="NAUTILUS" input="setup_analysis.md" output="backtest_setup.yaml">
      Configure backtest (ParquetDataCatalog, BacktestNode)
      Run backtest, produce results
    </step>
    <step order="4" droid="ORACLE" input="backtest_results.json" output="validation_report.md">
      Validate backtest (WFA, Monte Carlo, GO/NO-GO)
    </step>
    <step order="5" droid="FORGE" input="validation_report.md" output="fixes_implemented">
      If NO-GO: Implement fixes based on ORACLE feedback
      Condition: only if ORACLE says NO-GO
    </step>
    <step order="6" droid="NAUTILUS" input="fixes_implemented" output="re_test_results">
      Re-run backtest with fixes
      Condition: only if step 5 executed
      Loop: back to step 4 until GO
    </step>
    <step order="7" droid="DEPLOYMENT" input="validation_report.md (GO)" output="deployed">
      Deploy to production
      Condition: only if ORACLE says GO
      Optional: Gap 5 droid (may not exist yet)
    </step>
  </workflow>
  
  <workflow name="Code Review & Refactoring">
    <step order="1" droid="FORGE" output="code_analysis.md">
      Analyze code, identify issues
    </step>
    <step order="2" droid="NAUTILUS" input="code_analysis.md" output="architecture_review.md">
      Review architecture, suggest high-level changes
      Condition: if code_analysis mentions architecture issues
    </step>
    <step order="3" droid="FORGE" input="architecture_review.md" output="refactored_code">
      Implement refactoring based on NAUTILUS suggestions
    </step>
    <step order="4" droid="ORACLE" input="refactored_code" output="regression_test_results">
      Run regression tests to ensure no breakage
      Condition: if tests exist
    </step>
  </workflow>
  
  <workflow name="Research → Strategy Design">
    <step order="1" droid="ARGUS" output="research_findings.md">
      Research trading concepts, ML algos, market microstructure
    </step>
    <step order="2" droid="ONNX-MODEL-BUILDER" input="research_findings.md" output="ml_model.onnx">
      Train ML model based on research findings
      Condition: if research mentions ML approach
    </step>
    <step order="3" droid="CRUCIBLE" input="research_findings.md,ml_model.onnx" output="strategy_design.md">
      Design strategy incorporating research + ML model
    </step>
    <step order="4" droid="NAUTILUS" input="strategy_design.md" output="strategy_implementation.py">
      Implement strategy in NautilusTrader
    </step>
    <step order="5" droid="ORACLE" input="strategy_implementation.py" output="backtest_validation.md">
      Backtest and validate
    </step>
  </workflow>
</dependency_graph>
```

**C. Orchestrator Role:**

The **ea-scalper-xauusd-orchestrator** droid should:
1. Know the dependency graphs (workflows)
2. Invoke droids in correct order automatically
3. Handle conditional steps (e.g., "only if ORACLE says NO-GO")
4. Loop when needed (e.g., fix → re-test → validate loop)
5. Report progress to user

**Upgrade orchestrator.md:**
- Add workflow knowledge
- Add dependency graph
- Add automatic invocation logic
- Elevate to MAESTRO role

#### 5.4 Observability:

**A. Logging Standard:**

All droids must log to structured format:
```json
{
  "timestamp": "2025-12-07T18:30:00Z",
  "droid": "NAUTILUS",
  "version": "2.1",
  "task": "Explain Actor vs Strategy pattern",
  "execution_time_seconds": 4.2,
  "thinking_score": 0.82,
  "reflection_questions_applied": 10,
  "status": "success",
  "output_length_chars": 2345,
  "user_feedback": null  // will be filled if user provides feedback
}
```

**B. Metrics Dashboard:**

Create `DOCS/04_REPORTS/DROID_METRICS_DASHBOARD.md` (updated weekly):
```markdown
# Droid Ecosystem Metrics Dashboard

**Period:** 2025-12-01 to 2025-12-07

## Usage Statistics

| Droid | Invocations | Avg Exec Time | Error Rate | Avg Quality Score |
|-------|-------------|---------------|------------|-------------------|
| FORGE | 45 | 5.2s | 2.2% | 4.3/5 |
| ORACLE | 32 | 8.7s | 0% | 4.8/5 |
| SENTINEL | 28 | 2.1s | 0% | 4.9/5 |
| NAUTILUS | 18 | 12.3s | 5.6% | 4.1/5 |
| CRUCIBLE | 15 | 6.5s | 0% | 4.6/5 |
| ARGUS | 8 | 45.2s | 12.5% | 3.8/5 |
| ORCHESTRATOR | 2 | 3.5s | 0% | N/A |
| ... | ... | ... | ... | ... |

## Red Flags

🚨 **NAUTILUS error rate 5.6%** (target: <2%)
  - Root cause: Migration logic failing on complex MQL5 patterns
  - Action: Add more test cases, improve error handling

🚨 **ARGUS slow execution 45.2s** (target: <30s)
  - Root cause: Multiple web searches, sequential not parallel
  - Action: Parallelize research tool calls

🚨 **ARGUS low quality score 3.8/5** (target: >4.0)
  - Root cause: User feedback: "Too many low-confidence sources"
  - Action: Improve source filtering, prioritize Tier 1 sources

## Recommendations

1. Fix NAUTILUS error rate: Add test suite for MQL5 migration edge cases
2. Optimize ARGUS: Parallelize research tool calls, improve source filtering
3. Monitor FORGE (highest usage): Ensure quality doesn't degrade with scale
```

#### 5.5 Output para LAYER 5:

**File:** `ECOSYSTEM_HEALTH_FRAMEWORK.md`

```markdown
# Droid Ecosystem Health Framework

## Executive Summary
- Versioning: Central registry in AGENTS.md `<droid_versions>`
- Quality gates: Post-refactoring validation with functional tests
- Observability: Metrics dashboard tracking usage, errors, performance, quality
- Dependency graph: 3 workflows documented (Strategy Development, Code Review, Research→Design)
- Orchestrator: ea-scalper-xauusd-orchestrator elevated to MAESTRO role

## Versioning & Tracking

### Version Registry (AGENTS.md addition)
{XML structure as shown above}

### Version Checking Protocol
{Steps for ensuring correct version used}

## Quality Gates

### Post-Refactoring Validation
{Python pseudo-code for quality gate}

### Test Tasks per Droid
{List of functional tests per droid}

### Continuous Quality Monitoring
{XML structure for metrics tracking}

## Dependency Graph (DAG)

### Workflow 1: Strategy Development & Deployment
{7-step workflow: CRUCIBLE → SENTINEL → NAUTILUS → ORACLE → FORGE → NAUTILUS → DEPLOYMENT}

### Workflow 2: Code Review & Refactoring
{4-step workflow: FORGE → NAUTILUS → FORGE → ORACLE}

### Workflow 3: Research → Strategy Design
{5-step workflow: ARGUS → ONNX-MODEL-BUILDER → CRUCIBLE → NAUTILUS → ORACLE}

### Orchestrator Enhancements
- Add workflow knowledge to ea-scalper-xauusd-orchestrator.md
- Implement automatic invocation based on DAG
- Handle conditional steps and loops
- Elevate to MAESTRO role (priority 7 in decision_hierarchy)

## Observability

### Logging Standard
{JSON logging format}

### Metrics Dashboard
{Weekly report structure}

### Red Flag Detection
- Error rate >2% → Alert + investigate
- Avg exec time >30s → Optimize
- Quality score <4.0 → Improve
- Unused droids → Consider removal

## Recommendations for AGENTS.md Updates

1. Add `<droid_versions>` section
2. Add `<quality_monitoring>` section
3. Add `<dependency_graph>` section with 3 workflows
4. Expand `<decision_hierarchy>` to include ORCHESTRATOR at priority 7
5. Add versioning check protocol to session initialization
```

---

## 📤 Output

### Primary Output

**File:** `.prompts/008-droid-analysis/droid-ecosystem-analysis.md`

```xml
<droid_ecosystem_analysis>
  <metadata>
    <version>2.0</version>
    <date>{YYYY-MM-DD}</date>
    <scope>Comprehensive 5-layer analysis</scope>
    <execution_time>{XX}h {YY}min</execution_time>
  </metadata>
  
  <executive_summary>
    <total_droids>17</total_droids>
    <total_size>389KB</total_size>
    <layer_1_findings>
      <top_5_redundancy>{XX}KB ({YY}%)</top_5_redundancy>
      <top_5_savings>{ZZ}KB ({WW}% reduction)</top_5_savings>
    </layer_1_findings>
    <layer_2_findings>
      <remaining_12_redundancy>{XX}KB ({YY}%)</remaining_12_redundancy>
      <remaining_12_savings>{ZZ}KB ({WW}% reduction)</remaining_12_savings>
      <critical_droids>orchestrator, onnx-model-builder</critical_droids>
    </layer_2_findings>
    <layer_3_findings>
      <gaps_identified>5 critical droids</gaps_identified>
      <highest_priority>security-compliance (compliance + money)</highest_priority>
    </layer_3_findings>
    <layer_4_findings>
      <overlaps_identified>4 major areas</overlaps_identified>
      <conflicts_addressable>Yes (via authority hierarchy)</conflicts_addressable>
    </layer_4_findings>
    <layer_5_findings>
      <versioning_framework>Central registry + checking protocol</versioning_framework>
      <quality_gates>Post-refactoring validation with functional tests</quality_gates>
      <observability>Metrics dashboard tracking 4 dimensions</observability>
      <dependency_graph>3 workflows documented</dependency_graph>
    </layer_5_findings>
    <total_impact>
      <token_savings>{XXXXX} tokens</token_savings>
      <party_mode_improvement>+{XX}% budget freed</party_mode_improvement>
      <ecosystem_maturity>Significantly improved (versioning, quality, observability)</ecosystem_maturity>
    </total_impact>
  </executive_summary>
  
  <layer_1_results>
    <file>REDUNDANCY_MAP_TOP5.md</file>
    <summary>{link to LAYER 1 output file}</summary>
  </layer_1_results>
  
  <layer_2_results>
    <file>REMAINING_12_ANALYSIS.md</file>
    <summary>{link to LAYER 2 output file}</summary>
  </layer_2_results>
  
  <layer_3_results>
    <file>GAP_ANALYSIS.md</file>
    <summary>{link to LAYER 3 output file}</summary>
  </layer_3_results>
  
  <layer_4_results>
    <file>OVERLAP_CONFLICT_ANALYSIS.md</file>
    <summary>{link to LAYER 4 output file}</summary>
  </layer_4_results>
  
  <layer_5_results>
    <file>ECOSYSTEM_HEALTH_FRAMEWORK.md</file>
    <summary>{link to LAYER 5 output file}</summary>
  </layer_5_results>
  
  <recommendations>
    <immediate_actions>
      <action priority="CRITICAL">Create security-compliance droid (Gap 1)</action>
      <action priority="CRITICAL">Create performance-optimizer droid (Gap 2)</action>
      <action priority="HIGH">Refactor TOP 5 droids (NAUTILUS, ORACLE, FORGE, SENTINEL, RESEARCH)</action>
      <action priority="HIGH">Refactor orchestrator + elevate to MAESTRO role</action>
      <action priority="HIGH">Refactor onnx-model-builder (critical for ML)</action>
    </immediate_actions>
    
    <phased_roadmap>
      <phase number="1" timeline="Week 1">
        - Execute 009-agents-nautilus-update.md (AGENTS.md v3.4 → v3.4.1)
        - Execute 010-droid-refactoring-master.md (TOP 5 refactoring)
        - Create security-compliance droid
        - Create performance-optimizer droid
      </phase>
      
      <phase number="2" timeline="Week 2">
        - Refactor orchestrator → MAESTRO role
        - Refactor onnx-model-builder
        - Refactor crucible
        - Update AGENTS.md with:
          * `<droid_versions>` registry
          * Expanded `<decision_hierarchy>` (7 levels)
          * `<conflict_resolution>` protocol
          * `<dependency_graph>` (3 workflows)
          * `<quality_monitoring>` framework
      </phase>
      
      <phase number="3" timeline="Week 3">
        - Create data-pipeline droid (Gap 3)
        - Create monitoring-alerting droid (Gap 4)
        - Refactor remaining project droids (code-architect-reviewer, project-reader, etc)
        - Merge overlapping droids (code-architect-reviewer + senior-code-reviewer)
      </phase>
      
      <phase number="4" timeline="Week 4">
        - Optional: Create deployment-devops droid (Gap 5)
        - Refactor personal droids (if used for project)
        - Establish quality monitoring (weekly metrics dashboard)
        - Remove unused droids
      </phase>
    </phased_roadmap>
  </recommendations>
  
  <next_steps>
    <step order="1">Review all 5 layer outputs (REDUNDANCY_MAP, REMAINING_12, GAP_ANALYSIS, OVERLAP_CONFLICT, ECOSYSTEM_HEALTH)</step>
    <step order="2">Prioritize gaps: Create security-compliance + performance-optimizer droids first</step>
    <step order="3">Execute 009-agents-nautilus-update.md</step>
    <step order="4">Execute 010-droid-refactoring-master.md (TOP 5 + orchestrator + onnx-model-builder)</step>
    <step order="5">Update AGENTS.md with layer 4 + layer 5 enhancements</step>
    <step order="6">Implement quality monitoring (metrics dashboard)</step>
  </next_steps>
  
  <confidence>HIGH</confidence>
  <dependencies>
    <dependency>AGENTS.md v3.4.1 stable and complete</dependency>
    <dependency>Backups created before any refactoring</dependency>
    <dependency>Git commits with detailed changelogs</dependency>
    <dependency>User approval on gap droids to create</dependency>
  </dependencies>
  
  <open_questions>
    <question>Should all 5 gap droids be created or prioritize top 2 (security, performance)?</question>
    <question>Should personal droids be refactored or left as-is (if not used for project)?</question>
    <question>How to implement automatic version checking (Task agent enhancement)?</question>
    <question>Should orchestrator automatic invocation be opt-in or default?</question>
  </open_questions>
  
  <assumptions>
    <assumption>Remaining 12 droids have similar redundancy patterns as TOP 5 (70%)</assumption>
    <assumption>Gap droids are approved for creation (user decision)</assumption>
    <assumption>Orchestrator can be elevated to MAESTRO without breaking existing workflows</assumption>
    <assumption>Quality monitoring can be implemented with memory MCP knowledge graph</assumption>
  </assumptions>
</droid_ecosystem_analysis>
```

---

### Secondary Outputs (5 files)

1. **`REDUNDANCY_MAP_TOP5.md`** (LAYER 1)
2. **`REMAINING_12_ANALYSIS.md`** (LAYER 2)
3. **`GAP_ANALYSIS.md`** (LAYER 3)
4. **`OVERLAP_CONFLICT_ANALYSIS.md`** (LAYER 4)
5. **`ECOSYSTEM_HEALTH_FRAMEWORK.md`** (LAYER 5)

---

### Tertiary Output

**File:** `.prompts/008-droid-analysis/SUMMARY.md`

```markdown
# 🔍 Comprehensive Droid Ecosystem Analysis Summary (V2.0)

**One-liner:** Complete 5-layer holistic analysis of 17 droids (389KB): redundancy mapping, gap identification (5 critical droids missing), overlap resolution, and ecosystem health framework

## Version
v2.0 - Comprehensive 5-layer analysis (expanded from v1.0 TOP 5 only)

## Objective
Analyze ENTIRE droid ecosystem holistically: optimize existing droids (redundancy), identify missing droids (gaps), resolve conflicts (overlaps), and establish long-term health (versioning, quality, observability).

## Key Findings

### LAYER 1: TOP 5 Optimization
• Total redundancy: ~135KB (69% of TOP 5)
• Token savings: ~33,750 tokens
• Each droid has 70-80% duplication with AGENTS.md v3.4
• Refactoring: 196KB → 61KB (135KB saved)

### LAYER 2: Remaining 12 Analysis
• Total size: 193KB (50% of ecosystem, NOT analyzed in v1.0)
• Estimated redundancy: ~130KB (67%)
• Critical droids identified: orchestrator (MAESTRO candidate), onnx-model-builder (ML)
• Personal droids: 7 (may not need refactoring if not used for project)

### LAYER 3: Gap Analysis (⚠️ CRITICAL)
• **5 droids MISSING but critically needed:**
  1. **security-compliance** (CRITICAL - money + compliance)
  2. **performance-optimizer** (HIGH - OnTick <50ms budget)
  3. **data-pipeline** (MEDIUM - data quality)
  4. **monitoring-alerting** (MEDIUM - safety net)
  5. **deployment-devops** (LOW - maturity)

### LAYER 4: Overlap/Conflict Resolution
• **4 major overlaps identified:**
  1. FORGE vs NAUTILUS (code architecture)
  2. FORGE vs code-architect-reviewer vs senior-code-reviewer (code review)
  3. ARGUS vs research-analyst-pro (research)
  4. ORACLE vs NAUTILUS (backtest)
• **Resolution:** Authority hierarchy (7 levels) + conflict resolution protocol
• **Merge candidates:** code-architect-reviewer + senior-code-reviewer → generic-code-reviewer

### LAYER 5: Ecosystem Health
• **Versioning:** Central registry in AGENTS.md `<droid_versions>`
• **Quality gates:** Post-refactoring validation with functional tests
• **Observability:** Metrics dashboard (usage, errors, performance, quality)
• **Dependency graph:** 3 workflows documented (Strategy Dev, Code Review, Research→Design)
• **Orchestrator:** Elevate ea-scalper-xauusd-orchestrator to MAESTRO role

## Total Impact

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Total size** | 389KB | ~160KB | -229KB (59%) |
| **Tokens** | 97,250 | ~40,000 | -57,250 (59%) |
| **Party Mode overhead** | 61,700 | ~30,000 | +31,700 freed (51%) |
| **Gaps filled** | 0 critical droids | 5 created | Risk mitigation |
| **Conflicts resolved** | Ad-hoc | Formal framework | Consistency |
| **Observability** | None | Full metrics | Continuous improvement |

## Deliverables
- `REDUNDANCY_MAP_TOP5.md` (LAYER 1 - detailed redundancy analysis)
- `REMAINING_12_ANALYSIS.md` (LAYER 2 - per-droid analysis + priority matrix)
- `GAP_ANALYSIS.md` (LAYER 3 - 5 missing droids + justification)
- `OVERLAP_CONFLICT_ANALYSIS.md` (LAYER 4 - resolution framework)
- `ECOSYSTEM_HEALTH_FRAMEWORK.md` (LAYER 5 - versioning, quality, observability, DAG)
- `droid-ecosystem-analysis.md` (consolidated XML report)

## Decisions Needed

### Immediate (CRITICAL):
• Approve creation of security-compliance droid? (compliance + money = can't fail)
• Approve creation of performance-optimizer droid? (OnTick <50ms is critical)

### High Priority:
• Approve refactoring of remaining 12 droids (Phase 2-3)?
• Approve elevation of orchestrator to MAESTRO role?
• Approve merging overlapping droids (code reviewers)?

### Medium Priority:
• Create data-pipeline droid (Phase 3)?
• Create monitoring-alerting droid (Phase 3)?
• Refactor personal droids (if used for project)?

### Low Priority:
• Create deployment-devops droid (Phase 4)?

## Blockers
None - this is analysis phase (no code changes yet)

## Next Step
Review all 5 layer outputs, prioritize gap droids (security + performance first), then execute 009-agents-nautilus-update.md

## Estimated Time
2-3 hours for comprehensive 5-layer analysis (vs 30-45 min for v1.0 TOP 5 only)

## Intelligence Required
- **Sequential-thinking** (25+ thoughts minimum for CRITICAL complexity)
- **ARGUS research** for best practices in droid orchestration, quality gates
- **Proactive problem detection** for all 7 categories (especially security, performance, technical debt)
- **Genius-level holistic thinking:** Not just optimize what exists, but analyze system health and future-proof
