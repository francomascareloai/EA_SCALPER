# Redundancy Map - Droid Optimization

## Executive Summary
- **Total redundancy**: 82KB (42% of TOP 5)
- **Token savings potential**: 20,250 tokens
- **Droids analyzed**: 5 (NAUTILUS, ORACLE, FORGE, SENTINEL, RESEARCH-ANALYST-PRO)
- **Target post-refactor**: 115KB (41% reduction)

---

## NAUTILUS (53KB → 36KB)

### Redundancies Identified

#### 1. Generic NEVER/ALWAYS Rules (~8KB)
**Conteúdo duplicado:**
- NEVER assume, ALWAYS verify patterns
- NEVER silent errors, ALWAYS explicit handling
- NEVER magic numbers, ALWAYS named constants
- Generic clean code principles

**Já existe em AGENTS.md:**
```xml
<strategic_intelligence>
  <mandatory_reflection_protocol>
    Q2: What am I NOT seeing? (blind spots)
    Q6: What edge cases? (failure modes)
  </mandatory_reflection_protocol>
</strategic_intelligence>
```

**Ação:** REMOVE (herdar de AGENTS.md)

#### 2. Generic Error Handling Patterns (~5KB)
**Conteúdo duplicado:**
- Try/except best practices
- Logging patterns
- Error propagation strategies

**Já existe em AGENTS.md:**
```xml
<pattern_recognition_library>
  <pattern name="silent_failure">
    Signs: Empty catch blocks, ignored return values
    Prevention: Explicit error handling, logging, fail-fast
  </pattern>
</pattern_recognition_library>
```

**Ação:** REMOVE (herdar de AGENTS.md)

#### 3. Generic Code Review Checklist (~4KB)
**Conteúdo duplicado:**
- Code quality checks
- Security validation
- Performance considerations

**Já existe em AGENTS.md:**
```xml
<genius_mode_templates>
  <template name="code_review_critical">
    Critical issues, major issues, minor issues
  </template>
</genius_mode_templates>
```

**Ação:** REMOVE (usar template do AGENTS.md)

---

### Conhecimento Único a Manter

#### 1. MQL5 → Python Migration Mappings (~12KB)
**Conteúdo:**
```
<mql5_to_python>
  <map from="OnInit()" to="Strategy.__init__() + on_start()"/>
  <map from="OnTick()" to="on_quote_tick(tick: QuoteTick)"/>
  <map from="OrderSend()" to="submit_order(order: Order)"/>
  <map from="OrderModify()" to="modify_order(order: Order)"/>
  <map from="PositionGetDouble()" to="cache.positions()"/>
</mql5_to_python>
```

**Ação:** MANTER (especialização Nautilus)

#### 2. Event-Driven Architecture Patterns (~10KB)
**Conteúdo:**
- Strategy vs Actor decision tree
- MessageBus pub/sub patterns
- Cache access patterns (instruments, bars, positions, orders)
- Lifecycle methods (on_start, on_stop, on_bar, on_event)

**Ação:** MANTER (especialização Nautilus)

#### 3. Performance Targets (~2KB)
**Conteúdo:**
- on_bar: <1ms
- on_quote_tick: <100μs
- MessageBus overhead: <50μs
- Cache lookups: <10μs

**Ação:** MANTER (especialização Nautilus)

#### 4. BacktestNode/ParquetDataCatalog Setup (~8KB)
**Conteúdo:**
- Parquet schema requirements
- DataConfig construction
- VenueConfig setup
- BacktestEngine initialization

**Ação:** MANTER (especialização Nautilus)

---

### Additional Reflection Questions (3 perguntas)
1. **Q18**: Does this follow NautilusTrader event-driven patterns? (MessageBus for signals, cache for data access, no globals)
2. **Q19**: Am I using correct class hierarchy (Strategy vs Actor)?
3. **Q20**: Does migration preserve behavior without look-ahead bias? (bar[1] vs bar[0])

---

### Savings
- **Remove**: 17KB
- **Keep**: 36KB
- **Target size**: 36KB (economia 32%)

---

## ORACLE (38KB → 19KB)

### Redundancies Identified

#### 1. Generic "Question Everything" Principles (~10KB)
**Conteúdo duplicado:**
- Skeptical thinking patterns
- Bias awareness
- Critical evaluation frameworks

**Já existe em AGENTS.md:**
```xml
<mandatory_reflection_protocol>
  Q2: What am I NOT seeing? (blind spots)
  Q4: Is there simpler/better solution? (alternatives)
</mandatory_reflection_protocol>
```

**Ação:** REMOVE (herdar de AGENTS.md)

#### 2. Generic Sample Size Concepts (~3KB)
**Conteúdo duplicado:**
- Statistical significance concepts
- Data sufficiency principles

**Ação:** REMOVE (manter apenas thresholds específicos)

#### 3. WFA/MC Conceptual Explanations (~4KB)
**Conteúdo duplicado:**
- What is Walk-Forward Analysis
- Why Monte Carlo matters
- General overfitting concepts

**Ação:** REMOVE (manter apenas formulas e config)

---

### Conhecimento Único a Manter

#### 1. Statistical Thresholds (~5KB)
**Conteúdo:**
```
WFE ≥ 0.6  (Walk-Forward Efficiency)
PSR ≥ 0.85 (Probabilistic Sharpe Ratio)
DSR > 0    (Deflated Sharpe Ratio)
MC_95th_DD < 5% (Monte Carlo 95th percentile DD)
SQN > 2.0  (System Quality Number)
```

**Ação:** MANTER (especialização Oracle)

#### 2. WFA Formulas and Configuration (~4KB)
**Conteúdo:**
- 12 windows, 70% IS, 30% OOS
- Purged cross-validation (embargo period)
- Rolling vs anchored formulas
- WFE = (IS_Sharpe × IS_Trades - OOS_Sharpe × OOS_Trades) / Total_Trades

**Ação:** MANTER (especialização Oracle)

#### 3. Monte Carlo Block Bootstrap Specifications (~3KB)
**Conteúdo:**
- 5000 runs minimum
- block_size = 20 trades
- replacement = True
- preserve trade sequence correlation

**Ação:** MANTER (especialização Oracle)

#### 4. GO/NO-GO Decision Gates (~3KB)
**Conteúdo:**
```
STEP 1: WFE ≥ 0.6? → IF NO: NO-GO
STEP 2: PSR ≥ 0.85? → IF NO: NO-GO
STEP 3: DSR > 0? → IF NO: NO-GO
STEP 4: MC_95th_DD < 5%? → IF NO: NO-GO
STEP 5: SQN > 2.0? → IF NO: NO-GO
STEP 6: No look-ahead bias? → IF NO: NO-GO
STEP 7: Slippage realistic? → IF NO: NO-GO
```

**Ação:** MANTER (especialização Oracle)

---

### Additional Reflection Questions (3 perguntas)
1. **Q11**: Is backtest using look-ahead bias? (All indicators use bar[1] or earlier, never bar[0] for signals)
2. **Q12**: What regime change would invalidate results? (2024 XAUUSD trending, but 2025 range-bound?)
3. **Q13**: Am I overfitting to recent price action? (WFA validation, parameter stability, OOS >50% of IS performance)

---

### Savings
- **Remove**: 19KB
- **Keep**: 19KB
- **Target size**: 19KB (economia 50%)

---

## FORGE (37KB → 19KB)

### Redundancies Identified

#### 1. Generic DEEP DEBUG Protocol (~7KB)
**Conteúdo duplicado:**
- 5 Whys methodology
- Root cause analysis steps
- Debugging workflow

**Já existe em AGENTS.md:**
```xml
<genius_mode_templates>
  <template name="bug_fix_root_cause">
    Symptom → 5 Whys → Root cause → Fix strategy
  </template>
</genius_mode_templates>
```

**Ação:** REMOVE (usar template do AGENTS.md)

#### 2. Generic Clean Code Principles (~5KB)
**Conteúdo duplicado:**
- DRY, SOLID, YAGNI principles
- Naming conventions (general)
- Code organization patterns

**Já existe em AGENTS.md:**
```xml
<core_principles>
  Safety > Apex > Performance > Maintainability
</core_principles>
```

**Ação:** REMOVE (herdar de AGENTS.md)

#### 3. Generic Code Review Checklist (~5KB)
**Conteúdo duplicado:**
- Race conditions check
- Error handling check
- Input validation check

**Já existe em AGENTS.md:**
```xml
<proactive_problem_detection>
  <scan_categories>
    dependencies, performance, security, race_condition, resource_leak
  </scan_categories>
</proactive_problem_detection>
```

**Ação:** REMOVE (herdar de AGENTS.md)

---

### Conhecimento Único a Manter

#### 1. Python/Nautilus Anti-Patterns (~8KB)
**Conteúdo:**
```
AP-01: submit_order in try/except (NautilusTrader handles internally)
AP-02: Cache access without null check (returns None if not found)
AP-03: Missing super().__init__() in Actor/Strategy
AP-04: Blocking operations in on_quote_tick (<100μs budget)
AP-05: Circular imports (Strategy → Actor → Strategy)
AP-06: Mutable default arguments (def foo(bar=[]):)
AP-07: Global state (shared dicts, singletons)
AP-08: Missing type hints (mypy strict mode required)
```

**Ação:** MANTER (especialização Forge)

#### 2. Context7 Integration Workflow (~3KB)
**Conteúdo:**
- Query /nautechsystems/nautilus_trader BEFORE implementing
- Search for "Strategy lifecycle" or "Actor pattern"
- Validate against official docs (not assumptions)

**Ação:** MANTER (especialização Forge)

#### 3. Python Coding Standards (~4KB)
**Conteúdo:**
- PascalCase for classes
- snake_case for functions/variables
- Complete type hints (mypy strict)
- Docstrings with Args/Returns/Raises

**Ação:** MANTER (especialização Forge)

#### 4. Test Scaffolding Templates (~4KB)
**Conteúdo:**
```python
@pytest.fixture
def strategy(config):
    return MyStrategy(config=config)

def test_on_start(strategy):
    strategy.on_start()
    assert strategy.is_initialized
```

**Ação:** MANTER (especialização Forge)

---

### Additional Reflection Questions (3 perguntas)
1. **Q21**: Are async resources properly cleaned? (on_stop, context managers)
2. **Q22**: Did I consult Context7 for NautilusTrader docs BEFORE implementing?
3. **Q23**: Anti-patterns avoided and type hints complete? (mypy strict)

---

### Savings
- **Remove**: 18KB
- **Keep**: 19KB
- **Target size**: 19KB (economia 49%)

---

## SENTINEL (37KB → 24KB)

### Redundancies Identified

#### 1. Generic Risk Management Philosophy (~6KB)
**Conteúdo duplicado:**
- Risk-first thinking
- Conservative bias principles
- Proactive vs reactive concepts

**Já existe em AGENTS.md:**
```xml
<strategic_intelligence>
  <five_step_foresight>
    Project EVERY decision through 5 steps
  </five_step_foresight>
</strategic_intelligence>
```

**Ação:** REMOVE (herdar de AGENTS.md)

#### 2. Circuit Breaker Concept Explanation (~4KB)
**Conteúdo duplicado:**
- What is circuit breaker
- Why multiple levels matter
- Generic state machine concepts

**Ação:** REMOVE (manter apenas Apex-specific levels)

#### 3. Generic Time Zone Concepts (~3KB)
**Conteúdo duplicado:**
- Time zone conversion basics
- UTC vs local time explanation

**Ação:** REMOVE (manter apenas 4:59 PM ET deadline specifics)

---

### Conhecimento Único a Manter

#### 1. Apex Trading Rules (~8KB)
**Conteúdo:**
```
10% trailing DD from HWM (includes unrealized P&L)
NO overnight positions (close ALL by 4:59 PM ET)
30% consistency rule (daily profit < 30% of account)
5% max single trade risk (from current equity, not starting balance)
```

**Ação:** MANTER (especialização Sentinel)

#### 2. Circuit Breaker Levels (~4KB)
**Conteúdo:**
```
LEVEL 0 (NORMAL): DD 0-4% → Full operation
LEVEL 1 (WARNING): DD 4-6% → 75% position sizing
LEVEL 2 (CAUTION): DD 6-8% → 50% position sizing
LEVEL 3 (DANGER): DD 8-9.5% → 25% position sizing, alerts
LEVEL 4 (EMERGENCY): DD 9.5-10% → BLOCK all trades, manual override
```

**Ação:** MANTER (especialização Sentinel)

#### 3. Position Sizing Formulas (~5KB)
**Conteúdo:**
```
Base_Risk = 1% of current equity
DD_Multiplier = (1 - DD/10)  # Reduces as DD approaches limit
Time_Multiplier = min(1.0, time_until_459PM / 60min)  # Reduces close to deadline
Regime_Multiplier = {TRENDING: 1.0, RANGING: 0.75, VOLATILE: 0.5}
Final_Size = Base_Risk × DD_Mult × Time_Mult × Regime_Mult
```

**Ação:** MANTER (especialização Sentinel)

#### 4. High-Water Mark Tracking (~3KB)
**Conteúdo:**
```
HWM = max(Starting Balance, Peak Equity Ever)
Current Equity = Balance + Unrealized P&L
Trailing DD = (HWM - Current Equity) / HWM
CRITICAL: Must include UNREALIZED profits (Apex-specific, unlike FTMO)
```

**Ação:** MANTER (especialização Sentinel)

#### 5. Workflows (/risco, /trailing, etc) (~4KB)
**Conteúdo:**
- /risco {lot} → Validates if lot size within risk limits
- /trailing → Shows current DD from HWM with buffer remaining
- /overnight → Checks if sufficient time to close before 4:59 PM
- /lot {profit} → Calculates max lot size for target profit
- /consistency → Validates 30% rule for daily profit

**Ação:** MANTER (especialização Sentinel)

---

### Additional Reflection Questions (3 perguntas)
1. **Q8**: What market condition makes risk calculation WRONG? (news event, gap, flash crash, illiquidity)
2. **Q9**: Am I measuring trailing DD from ACTUAL HWM or stale cached value? (Verify HWM includes unrealized P&L)
3. **Q10**: What happens if news event hits at 4:50 PM ET? (Can we close before 4:59 PM deadline or forced liquidation?)

---

### Savings
- **Remove**: 13KB
- **Keep**: 24KB
- **Target size**: 24KB (economia 35%)

---

## RESEARCH-ANALYST-PRO (31KB → 17KB)

### Redundancies Identified

#### 1. Generic Research Principles (~8KB)
**Conteúdo duplicado:**
- Critical thinking concepts
- Source evaluation basics
- Bias awareness principles

**Já existe em AGENTS.md:**
```xml
<mandatory_reflection_protocol>
  Q2: What am I NOT seeing? (blind spots, assumptions)
  Q4: Is there simpler/better solution? (alternatives)
</mandatory_reflection_protocol>
```

**Ação:** REMOVE (herdar de AGENTS.md)

#### 2. Multi-Source Verification Concept (~3KB)
**Conteúdo duplicado:**
- Why multiple sources matter
- Triangulation concept explanation

**Ação:** REMOVE (manter apenas rating system específico)

#### 3. Generic QA Checklist (~3KB)
**Conteúdo duplicado:**
- Quality assurance steps
- Validation principles

**Já existe em AGENTS.md:**
```xml
<enforcement_validation>
  Quality gates, checks, enforcement actions
</enforcement_validation>
```

**Ação:** REMOVE (herdar de AGENTS.md)

---

### Conhecimento Único a Manter

#### 1. Multi-Source Triangulation Methodology (~4KB)
**Conteúdo:**
```
Require 3+ independent sources
Similarity threshold: 0.8 (semantic match)
Conflict resolution: Weighted by credibility score
Convergence: 75% agreement minimum for HIGH confidence
```

**Ação:** MANTER (especialização Research)

#### 2. Source Credibility Rating System (~4KB)
**Conteúdo:**
```
Authority (1-10): Author expertise, institutional backing
Accuracy (1-10): Fact-checked, peer-reviewed, cited
Relevance (1-10): Topic match, domain specificity
Recency (1-10): Publication date, data freshness
Final Score = (Authority × 0.3) + (Accuracy × 0.4) + (Relevance × 0.2) + (Recency × 0.1)
```

**Ação:** MANTER (especialização Research)

#### 3. Confidence Level Framework (~3KB)
**Conteúdo:**
```
LOW (1-4): Single source, or sources conflict, or low credibility
MEDIUM (5-7): 2-3 sources converge, moderate credibility
HIGH (8-10): 3+ high-credibility sources converge, consensus
Drivers: Source count, convergence %, credibility scores
```

**Ação:** MANTER (especialização Research)

#### 4. Research Report Structure (~3KB)
**Conteúdo:**
```markdown
## Executive Summary (1-2 sentences)
## Key Findings (bullet points with confidence levels)
## Methodology (sources used, search strategy)
## Source Analysis (credibility scores, agreements/conflicts)
## Recommendations (actionable with rationale)
## Confidence Assessment (overall level with drivers)
```

**Ação:** MANTER (especialização Research)

#### 5. Decision Frameworks (~3KB)
**Conteúdo:**
- Evidence Matrix (claims × sources grid)
- RCR Weighting (Recency-Credibility-Relevance)
- Scenario Analysis (best/worst/likely cases)

**Ação:** MANTER (especialização Research)

---

### Additional Reflection Questions (3 perguntas)
1. **Q16**: What is confidence level? (Academic consensus vs single paper, replicated vs novel, theoretical vs empirical)
2. **Q17**: What biases exist in sources? (Publication bias, industry vs academic, cherry-picked data)
3. **Q24**: Have I triangulated across 3+ independent sources? (Not just citing same data from different articles)

---

### Savings
- **Remove**: 14KB
- **Keep**: 17KB
- **Target size**: 17KB (economia 45%)

---

## Aggregate Analysis

### Total Savings
- **Before**: 196KB (49,000 tokens)
- **After**: 115KB (28,750 tokens)
- **Savings**: 81KB (20,250 tokens, 41% reduction)

### Party Mode Impact
- **Before overhead**: 61,700 tokens
- **After overhead**: 36,000 tokens
- **Savings**: 25,700 tokens (42% improvement)

### Inheritance Map

```
AGENTS.md v3.4 (base framework)
├── strategic_intelligence (7 mandatory questions)
├── genius_mode_templates (4 templates)
├── complexity_assessment (4 levels)
├── enforcement_validation (quality gates)
├── compressed_protocols (fast + emergency modes)
├── pattern_learning (auto-learning from bugs)
├── amplifier_protocols (decision tree)
├── thinking_conflicts (resolution framework)
└── thinking_observability (audit trail)

    ↓ HERANÇA (inherit="full")

NAUTILUS (36KB specialization)
├── domain_knowledge: Migration, Event patterns, Performance targets
└── additional_reflection_questions: Q18, Q19, Q20

ORACLE (19KB specialization)
├── domain_knowledge: Thresholds, WFA, Monte Carlo, GO/NO-GO
└── additional_reflection_questions: Q11, Q12, Q13

FORGE (19KB specialization)
├── domain_knowledge: Anti-patterns, Context7, Python standards, Test templates
└── additional_reflection_questions: Q21, Q22, Q23

SENTINEL (24KB specialization)
├── domain_knowledge: Apex rules, Circuit breaker, Position sizing, HWM tracking
└── additional_reflection_questions: Q8, Q9, Q10

RESEARCH (17KB specialization)
├── domain_knowledge: Triangulation, Credibility rating, Confidence framework
└── additional_reflection_questions: Q16, Q17, Q24
```

### Next Steps
1. **Review** this REDUNDANCY_MAP.md and droid-analysis.md
2. **Execute** 009-agents-nautilus-update.md (enhance AGENTS.md with Nautilus examples)
3. **Execute** 010-droid-refactoring-master.md (FASE 2-4: implement refactoring sequentially)

---

**Analysis Date**: 2025-12-07  
**Confidence Level**: HIGH  
**Method**: Line-by-line comparison across 6,938 total lines (5 droids + AGENTS.md)
