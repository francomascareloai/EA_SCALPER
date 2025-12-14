# LAYER 5: Ecosystem Health Framework

**Analysis Date:** 2025-12-07
**Analyst:** Elite Quantitative Research Analyst (deep-researcher subagent)
**Confidence:** HIGH (systematic framework design)

---

## Executive Summary

| Component | Status |
|-----------|--------|
| **Versioning Framework** | Designed - Central registry in AGENTS.md |
| **Quality Gates** | Defined - Post-refactoring validation |
| **Observability Metrics** | Specified - 4 dimensions tracking |
| **Dependency Graph** | Mapped - 3 workflows documented |
| **ORCHESTRATOR Role** | Elevated to MAESTRO |

---

## 1. Versioning & Tracking

### 1.1 Version Registry (AGENTS.md Addition)

```xml
<droid_versions>
  <description>
    Central registry of all droid versions. Updated after each refactoring.
    Used to ensure sessions use latest versions and track changelog.
  </description>
  
  <!-- TOP 5 (Post-Refactoring) -->
  
  <droid name="NAUTILUS" current_version="2.1" refactored="2025-12-07">
    <changelog>
      <version number="2.1" date="2025-12-07">
        Inheritance from AGENTS.md v3.4.1, 70% token reduction,
        removed redundant protocols, kept MQL5 mapping and patterns
      </version>
      <version number="2.0" date="2025-11-15">Initial NautilusTrader version</version>
    </changelog>
    <file>.factory/droids/nautilus-trader-architect.md</file>
    <size>16KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <droid name="ORACLE" current_version="3.2" refactored="2025-12-07">
    <changelog>
      <version number="3.2" date="2025-12-07">
        Inheritance from AGENTS.md v3.4.1, 68% reduction,
        kept statistical thresholds and WFA methodology
      </version>
      <version number="3.1" date="2025-11-20">Apex Trading edition</version>
    </changelog>
    <file>.factory/droids/oracle-backtest-commander.md</file>
    <size>12KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <droid name="FORGE" current_version="5.1" refactored="2025-12-07">
    <changelog>
      <version number="5.1" date="2025-12-07">
        Inheritance from AGENTS.md v3.4.1, 65% reduction,
        kept Deep Debug and Context7 protocols
      </version>
      <version number="5.0" date="2025-11-18">Python/Nautilus edition</version>
    </changelog>
    <file>.factory/droids/forge-mql5-architect.md</file>
    <size>13KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <droid name="SENTINEL" current_version="3.1" refactored="2025-12-07">
    <changelog>
      <version number="3.1" date="2025-12-07">
        Inheritance from AGENTS.md v3.4.1, 60% reduction,
        kept Apex formulas and circuit breaker levels
      </version>
      <version number="3.0" date="2025-11-15">Apex Guardian edition</version>
    </changelog>
    <file>.factory/droids/sentinel-apex-guardian.md</file>
    <size>15KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <droid name="ARGUS" current_version="3.0" refactored="2025-12-07">
    <changelog>
      <version number="3.0" date="2025-12-07">
        Merged from argus + research-analyst-pro + deep-researcher,
        consolidated 58KB → 15KB, single research droid
      </version>
      <version number="2.1" date="2025-11-10">Trading specialist</version>
    </changelog>
    <file>.factory/droids/argus-quant-researcher.md</file>
    <size>15KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <!-- REMAINING (Post-Refactoring) -->
  
  <droid name="ORCHESTRATOR" current_version="2.0" refactored="2025-12-07">
    <changelog>
      <version number="2.0" date="2025-12-07">
        Elevated to MAESTRO role, added workflow DAGs,
        automatic routing, progress tracking
      </version>
      <version number="1.0" date="2025-11-01">Basic coordinator</version>
    </changelog>
    <file>.factory/droids/ea-scalper-xauusd-orchestrator.md</file>
    <size>15KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <droid name="ONNX-MODEL-BUILDER" current_version="1.1" refactored="2025-12-07">
    <changelog>
      <version number="1.1" date="2025-12-07">
        50% reduction, kept ML templates and ONNX export
      </version>
      <version number="1.0" date="2025-11-05">Initial ML builder</version>
    </changelog>
    <file>.factory/droids/onnx-model-builder.md</file>
    <size>14KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <droid name="CRUCIBLE" current_version="4.1" refactored="2025-12-07">
    <changelog>
      <version number="4.1" date="2025-12-07">
        55% reduction, kept 25 Realism Gates
      </version>
      <version number="4.0" date="2025-11-12">Backtest quality guardian</version>
    </changelog>
    <file>.factory/droids/crucible-gold-strategist.md</file>
    <size>8KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <droid name="code-architect-reviewer" current_version="1.1" refactored="2025-12-07">
    <changelog>
      <version number="1.1" date="2025-12-07">
        65% reduction, kept consequence analysis
      </version>
      <version number="1.0" date="2025-11-08">Systemic reviewer</version>
    </changelog>
    <file>.factory/droids/code-architect-reviewer.md</file>
    <size>10KB</size>
    <dependencies>AGENTS.md v3.4.1</dependencies>
  </droid>
  
  <!-- NANO VERSIONS -->
  
  <droid name="NAUTILUS-NANO" current_version="2.0" refactored="2025-11-25">
    <changelog>
      <version number="2.0" date="2025-11-25">
        Compact version for Party Mode, 8KB
      </version>
    </changelog>
    <file>.factory/droids/nautilus-nano.md</file>
    <size>8KB</size>
    <note>Compact version of NAUTILUS for multi-agent sessions</note>
  </droid>
  
  <!-- UTILITIES (Keep as-is) -->
  
  <droid name="git-guardian" current_version="1.0">
    <file>.factory/droids/git-guardian.md</file>
    <size>15KB</size>
    <note>Utility droid, not project-specific</note>
  </droid>
  
  <droid name="project-reader" current_version="1.0">
    <file>.factory/droids/project-reader.md</file>
    <size>6KB</size>
    <note>Utility droid</note>
  </droid>
  
  <!-- ARCHIVED -->
  
  <droid name="sentinel-ftmo-guardian" status="ARCHIVED" archived="2025-12-07">
    <reason>Project targets Apex, not FTMO</reason>
    <archive_location>.factory/droids/archived/</archive_location>
  </droid>
  
  <droid name="bmad-builder" status="ARCHIVED" archived="2025-12-07">
    <reason>Not used in this project</reason>
    <archive_location>.factory/droids/archived/</archive_location>
  </droid>
  
  <droid name="research-analyst-pro" status="MERGED" merged="2025-12-07">
    <merged_into>ARGUS v3.0</merged_into>
  </droid>
  
  <droid name="deep-researcher" status="MERGED" merged="2025-12-07">
    <merged_into>ARGUS v3.0</merged_into>
  </droid>
</droid_versions>
```

### 1.2 Version Checking Protocol

```python
# Pseudo-code for version checking (Task agent implementation)

def verify_droid_version(droid_name: str) -> bool:
    """
    Verify that the loaded droid matches the registry version.
    Called automatically when Task agent invokes a droid.
    """
    # 1. Load version registry from AGENTS.md
    registry = load_droid_versions_from_agents_md()
    
    # 2. Get expected version for this droid
    expected = registry.get(droid_name)
    if expected is None:
        log.warning(f"Droid {droid_name} not in registry")
        return True  # Allow unknown droids
    
    # 3. Check if droid is archived
    if expected.status == "ARCHIVED":
        log.warning(f"Droid {droid_name} is ARCHIVED. Suggest alternative.")
        return False
    
    if expected.status == "MERGED":
        log.info(f"Droid {droid_name} merged into {expected.merged_into}")
        return False
    
    # 4. Load droid file and check version metadata
    droid_file = load_droid_file(expected.file)
    if droid_file.version != expected.current_version:
        log.warning(
            f"Version mismatch: {droid_name} file has v{droid_file.version}, "
            f"registry expects v{expected.current_version}"
        )
        suggest_update()
        return False
    
    # 5. Verify inheritance
    if expected.dependencies:
        for dep in expected.dependencies:
            if not verify_dependency(dep):
                log.error(f"Dependency {dep} not met for {droid_name}")
                return False
    
    return True
```

---

## 2. Quality Gates

### 2.1 Post-Refactoring Validation

For EACH refactored droid, run this validation suite:

```yaml
quality_gate:
  name: "Post-Refactoring Validation"
  
  gates:
    - name: "Size Reduction"
      check: "file_size_after < file_size_before * 0.5"
      target: "60-70% reduction"
      fail_action: "Review - may have kept too much"
    
    - name: "Domain Knowledge Preserved"
      check: "semantic_similarity(domain_before, domain_after) > 0.95"
      method: "Compare key sections for semantic equivalence"
      fail_action: "Restore missing domain knowledge"
    
    - name: "Functional Test"
      check: "All test tasks produce equivalent outputs"
      tasks_per_droid: 3
      fail_action: "Debug and fix differences"
    
    - name: "Inheritance Section"
      check: "Has <inheritance> section pointing to AGENTS.md v3.4.1"
      fail_action: "Add inheritance section"
    
    - name: "Additional Questions"
      check: "Has 3 unique additional_reflection_questions"
      fail_action: "Add domain-specific questions"
    
    - name: "Compilation"
      check: "Droid loads without errors"
      fail_action: "Fix syntax/structure issues"
```

### 2.2 Test Tasks Per Droid

```yaml
test_tasks:
  NAUTILUS:
    - task: "Explain Actor vs Strategy pattern in NautilusTrader"
      expected_concepts: [Actor, Strategy, MessageBus, on_bar, submit_order]
    - task: "How to migrate MQL5 OnTick() to Nautilus?"
      expected_concepts: [on_quote_tick, tick handler, performance]
    - task: "What's the performance budget for on_bar handler?"
      expected_values: ["<1ms", "5ms max"]
  
  ORACLE:
    - task: "What's the WFE threshold for GO decision?"
      expected_values: ["0.6", "minimum 0.5"]
    - task: "Explain Walk-Forward Efficiency calculation"
      expected_concepts: [OOS, IS, sharpe, windows]
    - task: "How many Monte Carlo runs required?"
      expected_values: ["5000", "minimum 1000"]
  
  FORGE:
    - task: "How to avoid blocking in on_bar handler?"
      expected_concepts: [async, numpy, vectorization, <1ms]
    - task: "What's the Deep Debug protocol?"
      expected_concepts: [hypothesis, ranking, evidence]
    - task: "How to use pytest fixtures for NautilusTrader?"
      expected_concepts: [conftest, fixtures, mock]
  
  SENTINEL:
    - task: "Calculate trailing DD with unrealized P&L"
      expected_concepts: [HWM, floating, floor, equity]
    - task: "What's the circuit breaker level at 8.5% DD?"
      expected_values: ["Level 3", "SOFT STOP", "0% new trades"]
    - task: "Explain position sizing formula with time multiplier"
      expected_concepts: [lot, SL, tick value, time proximity]
  
  ARGUS:
    - task: "What confidence level for single arXiv paper?"
      expected_values: ["LOW", "NOT_TRUSTED", "need triangulation"]
    - task: "Explain multi-source triangulation methodology"
      expected_concepts: [academic, practical, empirical, 3 sources]
    - task: "How to rate source credibility?"
      expected_concepts: [peer review, stars, author, bias]
```

### 2.3 Continuous Quality Monitoring

```xml
<quality_monitoring>
  <description>
    Continuous tracking of droid quality and usage.
    Data stored in memory MCP knowledge graph.
  </description>
  
  <metrics>
    <metric name="invocation_count">
      <description>How often each droid is invoked</description>
      <alert_if>droid invoked 0 times in 7 days (unused)</alert_if>
    </metric>
    
    <metric name="error_rate">
      <description>Percentage of failed invocations</description>
      <target>< 2%</target>
      <alert_if>> 5% (needs investigation)</alert_if>
    </metric>
    
    <metric name="avg_execution_time">
      <description>Average time to complete task</description>
      <target>< 30 seconds for simple tasks</target>
      <alert_if>> 60 seconds (needs optimization)</alert_if>
    </metric>
    
    <metric name="output_quality">
      <description>User feedback score (1-5)</description>
      <target>> 4.0</target>
      <alert_if>< 3.5 (needs improvement)</alert_if>
    </metric>
  </metrics>
  
  <storage>
    <entity type="droid_invocation">
      <attributes>
        droid_name, timestamp, task_summary, 
        execution_time_seconds, status (success/failure),
        output_length, user_feedback (1-5 or null)
      </attributes>
    </entity>
  </storage>
  
  <reporting frequency="weekly">
    <report name="Droid Health Dashboard">
      <section>Most used droids (top 10)</section>
      <section>Highest error rate droids (need fixes)</section>
      <section>Slowest droids (need optimization)</section>
      <section>Lowest rated droids (need improvement)</section>
      <section>Unused droids (consider removal)</section>
    </report>
  </reporting>
</quality_monitoring>
```

---

## 3. Observability

### 3.1 Logging Standard

All droids must log using this structured format:

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
  "user_feedback": null,
  "handoff_to": null,
  "handoff_from": "ORCHESTRATOR"
}
```

### 3.2 Metrics Dashboard

Location: `DOCS/04_REPORTS/DROID_METRICS_DASHBOARD.md`

Updated: Weekly (or on-demand)

```markdown
# Droid Ecosystem Metrics Dashboard

**Period:** 2025-12-01 to 2025-12-07

## Usage Statistics

| Droid | Invocations | Avg Exec Time | Error Rate | Avg Quality |
|-------|-------------|---------------|------------|-------------|
| FORGE | 45 | 5.2s | 2.2% | 4.3/5 |
| ORACLE | 32 | 8.7s | 0% | 4.8/5 |
| SENTINEL | 28 | 2.1s | 0% | 4.9/5 |
| NAUTILUS | 18 | 12.3s | 5.6% | 4.1/5 |
| CRUCIBLE | 15 | 6.5s | 0% | 4.6/5 |
| ARGUS | 8 | 45.2s | 12.5% | 3.8/5 |
| ORCHESTRATOR | 5 | 3.5s | 0% | N/A |
| ONNX-MODEL-BUILDER | 3 | 120s | 0% | 4.5/5 |
| code-architect-reviewer | 2 | 15s | 0% | 4.7/5 |

## Health Indicators

### 🟢 Healthy
- ORACLE: 0% error rate, high quality
- SENTINEL: Fast, reliable, highly rated
- CRUCIBLE: Consistent performance

### 🟡 Needs Attention
- NAUTILUS: 5.6% error rate (target <2%)
  - Root cause: Migration logic failing on complex MQL5 patterns
  - Action: Add more test cases, improve error handling

### 🔴 Critical
- ARGUS: 12.5% error rate, low quality 3.8/5
  - Root cause: Web search timeouts, low-confidence sources
  - Action: Parallelize searches, improve source filtering

## Trends

### Invocation Trend (Last 4 Weeks)
```
Week 1: ████████████████ 156 invocations
Week 2: ██████████████████ 178 invocations
Week 3: ████████████████████ 201 invocations
Week 4: ██████████████████████ 234 invocations (+17%)
```

### Error Rate Trend
```
Week 1: 4.2%
Week 2: 3.8%
Week 3: 3.1%
Week 4: 2.9% (improving ✓)
```

## Recommendations

1. **Fix NAUTILUS error rate**: Add test suite for MQL5 migration edge cases
2. **Optimize ARGUS**: Parallelize research tool calls, cache frequent queries
3. **Monitor FORGE**: Highest usage, ensure quality doesn't degrade at scale
4. **Review unused droids**: git-guardian (0 invocations), project-reader (1)
```

### 3.3 Red Flag Detection

```yaml
red_flag_rules:
  - condition: "error_rate > 5%"
    severity: "WARNING"
    action: "Investigate and fix within 1 week"
    
  - condition: "error_rate > 10%"
    severity: "CRITICAL"
    action: "Immediate investigation, may disable droid"
    
  - condition: "avg_execution_time > 60s"
    severity: "WARNING"
    action: "Profile and optimize"
    
  - condition: "quality_score < 3.5"
    severity: "WARNING"
    action: "Review user feedback, improve outputs"
    
  - condition: "invocations == 0 for 14 days"
    severity: "INFO"
    action: "Consider archiving or merging"
    
  - condition: "version_mismatch"
    severity: "WARNING"
    action: "Update droid file or registry"
```

---

## 4. Dependency Graph (DAG)

### 4.1 Workflow: Strategy Development & Deployment

```
┌─────────────┐
│  CRUCIBLE   │  Step 1: Analyze setup, calculate confluence
│  (setup)    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  SENTINEL   │  Step 2: Validate risk constraints
│  (risk)     │  Can VETO if DD >9% or time <30min
└──────┬──────┘
       │ (if approved)
       ▼
┌─────────────┐
│  NAUTILUS   │  Step 3: Configure backtest
│  (backtest) │  ParquetDataCatalog, BacktestNode
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  CRUCIBLE   │  Step 4: Validate realism (25 Gates)
│  (realism)  │  Can BLOCK if Realism <90%
└──────┬──────┘
       │ (if realistic)
       ▼
┌─────────────┐
│   ORACLE    │  Step 5: Statistical validation
│ (validation)│  WFA, Monte Carlo, GO/NO-GO
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
   ▼       ▼
┌─────┐  ┌─────┐
│ GO  │  │NO-GO│
└──┬──┘  └──┬──┘
   │        │
   │        ▼
   │    ┌─────────────┐
   │    │   FORGE     │  Step 6a: Implement fixes
   │    │   (fix)     │
   │    └──────┬──────┘
   │           │
   │           └─── Loop back to Step 3 ───┘
   │
   ▼
┌─────────────┐
│ DEPLOYMENT  │  Step 7: Deploy to production
│  (optional) │  (Gap droid - may not exist)
└─────────────┘
```

### 4.2 Workflow: Code Review & Refactoring

```
┌─────────────┐
│   FORGE     │  Step 1: Analyze code, identify issues
│  (analyze)  │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ code-architect-     │  Step 2: Pre-commit audit
│ reviewer (audit)    │  Dependency mapping, consequences
└──────────┬──────────┘
           │
           ▼ (if architecture concern)
┌─────────────┐
│  NAUTILUS   │  Step 3: Review architecture
│  (review)   │  Suggest high-level changes
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   FORGE     │  Step 4: Implement refactoring
│  (refactor) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   ORACLE    │  Step 5: Run regression tests
│  (test)     │  Ensure no breakage
└─────────────┘
```

### 4.3 Workflow: Research → Strategy Design

```
┌─────────────┐
│   ARGUS     │  Step 1: Research trading concepts
│  (research) │  ML algos, market microstructure
└──────┬──────┘
       │
       ▼ (if ML approach)
┌─────────────────────┐
│ ONNX-MODEL-BUILDER  │  Step 2: Train ML model
│   (train)           │  ONNX export for MQL5/Python
└──────────┬──────────┘
           │
           ▼
┌─────────────┐
│  CRUCIBLE   │  Step 3: Design strategy
│  (design)   │  Incorporate research + ML model
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  NAUTILUS   │  Step 4: Implement strategy
│ (implement) │  NautilusTrader Strategy/Actor
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   ORACLE    │  Step 5: Backtest and validate
│ (validate)  │  WFA, Monte Carlo
└─────────────┘
```

### 4.4 ORCHESTRATOR Workflow Knowledge

The ORCHESTRATOR (elevated to MAESTRO) should know these workflows and:

1. **Invoke droids in correct order** based on user intent
2. **Handle conditional steps** (e.g., "only if ORACLE says NO-GO")
3. **Support loops** (fix → re-test → validate)
4. **Track progress** across sessions
5. **Report status** to user

```xml
<orchestrator_workflows>
  <workflow id="strategy_dev" name="Strategy Development">
    <steps>CRUCIBLE → SENTINEL → NAUTILUS → CRUCIBLE → ORACLE → [FORGE] → loop</steps>
    <description>Full strategy development from setup to validation</description>
  </workflow>
  
  <workflow id="code_review" name="Code Review & Refactoring">
    <steps>FORGE → code-architect-reviewer → [NAUTILUS] → FORGE → ORACLE</steps>
    <description>Pre-commit code quality workflow</description>
  </workflow>
  
  <workflow id="research_strategy" name="Research to Strategy">
    <steps>ARGUS → [ONNX-MODEL-BUILDER] → CRUCIBLE → NAUTILUS → ORACLE</steps>
    <description>Research-driven strategy design</description>
  </workflow>
</orchestrator_workflows>
```

---

## 5. ORCHESTRATOR Elevation to MAESTRO

### 5.1 Current State (4KB - Insufficient)

The current orchestrator is too basic:
- Simple description paragraph
- Lists agents
- Mentions philosophy
- **MISSING:** Workflows, DAG, automatic routing, progress tracking

### 5.2 Proposed Enhancement

```yaml
orchestrator_v2:
  name: ea-scalper-xauusd-orchestrator
  role: MAESTRO
  version: 2.0
  size_target: 15-20KB
  
  new_capabilities:
    workflow_knowledge:
      - All 3 workflow DAGs
      - Conditional step handling
      - Loop support
      
    automatic_routing:
      - Parse user intent
      - Match to workflow or droid
      - Route without user specifying droid
      
    progress_tracking:
      - Track workflow state across sessions
      - Resume from last step
      - Report completion percentage
      
    clarification_handling:
      - Detect ambiguous requests
      - Ask clarifying questions
      - Route after clarification
      
    handoff_management:
      - Coordinate droid handoffs
      - Pass context between droids
      - Track handoff chain
  
  decision_hierarchy_position: Priority 7
  note: "Coordinates but doesn't override domain authorities"
```

### 5.3 ORCHESTRATOR Template

```markdown
---
name: ea-scalper-xauusd-orchestrator
description: |
  MAESTRO v2.0 - Central orchestration hub for EA_SCALPER_XAUUSD project.
  Coordinates all specialized droids, routes requests, tracks progress.
  
  KNOWS ALL WORKFLOWS:
  - Strategy Development: CRUCIBLE → SENTINEL → NAUTILUS → ORACLE
  - Code Review: FORGE → code-architect-reviewer → NAUTILUS
  - Research to Strategy: ARGUS → ONNX-MODEL-BUILDER → CRUCIBLE
  
  AUTOMATIC ROUTING:
  - Parses user intent
  - Routes to correct specialist
  - Handles handoffs between droids
model: inherit
---

# MAESTRO v2.0 - The Orchestration Hub

## Role
Central command-and-control for EA_SCALPER_XAUUSD project.
You are the CONDUCTOR that ensures all instruments play in harmony.

## Core Philosophy
BUILD > PLAN, CODE > DOCS, SHIP > PERFECT

## Workflows You Know

### 1. Strategy Development
[DAG from above]

### 2. Code Review
[DAG from above]

### 3. Research to Strategy
[DAG from above]

## Routing Rules
[Pattern → Droid mapping]

## Progress Tracking
[How to track across sessions]

## Handoff Protocol
[How to coordinate between droids]

## Conflict Escalation
[When to escalate to user]
```

---

## 6. Recommendations Summary

### Immediate (Phase 1)

1. **Add `<droid_versions>` to AGENTS.md v3.4.1**
2. **Add `<quality_monitoring>` to AGENTS.md**
3. **Create workflow DAGs in AGENTS.md**
4. **Refactor ORCHESTRATOR to MAESTRO role**

### Continuous

5. **Implement weekly metrics dashboard**
6. **Set up red flag detection**
7. **Track droid invocations in memory MCP**

### Post-Refactoring

8. **Run quality gates on all refactored droids**
9. **Validate functional tests pass**
10. **Archive unused droids**

---

## Appendix: AGENTS.md Update Summary

Add these sections to AGENTS.md v3.4 → v3.4.1:

```xml
<!-- New sections to add -->

1. <droid_versions>
   - Central registry of all droids
   - Version tracking with changelog
   - Dependencies specified
   
2. <quality_monitoring>
   - Invocation tracking
   - Error rate monitoring
   - Quality scoring
   - Weekly reporting
   
3. <dependency_graph>
   - 3 workflow DAGs
   - Step-by-step flows
   - Conditional handling
   
4. <orchestrator_workflows>
   - Workflow definitions
   - Automatic routing rules
   - Progress tracking
   
5. <overlap_resolution>
   - Clear boundaries
   - Routing rules
   - Merge status
   
6. <routing_rules>
   - Pattern → Droid mapping
   - Disambiguation rules
```
