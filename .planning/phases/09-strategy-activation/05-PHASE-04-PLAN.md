# PLAN: Phase 04 - MEAN_REVERT Decision

## Metadata
- **Phase:** 04
- **Priority:** P1 - HIGH
- **Status:** Not Started
- **Agents:** 1 CRUCIBLE (opus) - research only
- **Depends On:** Phase 03 Complete
- **Checkpoint:** User decision required

---

## MANDATORY EXECUTION PROTOCOL

**ESTE PROTOCOLO DEVE SER SEGUIDO EM TODAS AS ACOES:**

### 1. Autonomous Loop (CRITIC ate GO)
```
Executar task → CRITIC review (opus) → GO?
                      ↓ NO
                Fix automatico → CRITIC review → loop (max 3x)
                      ↓ ainda NO-GO apos 3x
                Perguntar usuario
```

### 2. Quick Backtest Apos Cada Fix
```bash
# OBRIGATORIO apos qualquer mudanca de codigo
python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-01-07

# Verificar:
# - Trades > 0 (senao algo quebrou)
# - Sem erros no log
# - Trade count nao caiu 50%+
```

### 3. Parallel Agents (sem limite)
- Pode spawnar multiplos agents em paralelo para fixes
- FORGE + ORACLE + SENTINEL simultaneo se necessario
- Nao economizar - usar quantos precisar

### 4. Anti-Hallucination
- SEMPRE mostrar output dos comandos
- NUNCA dizer "deve funcionar" sem testar
- NUNCA inventar metricas - usar output real

### 5. Verificacao Obrigatoria
```bash
# Antes de qualquer GO:
mypy --strict nautilus_gold_scalper/
pytest -q
# Quick backtest (1 semana)
```

**NOTA: Esta fase REQUER decisao do usuario (MEAN_REVERT: implementar/remover/adiar)**

---

## Objective

Decidir se implementamos a estratégia Mean Revert ou removemos o enum. Atualmente existe `STRATEGY_MEAN_REVERT` no código mas ZERO implementação. Precisamos de uma decisão clara: implementar ou remover.

---

## Context

**Current State:**
- `StrategyType.STRATEGY_MEAN_REVERT` exists in enum
- `RegimeDetector` can detect mean-reverting regime (Hurst < 0.45)
- `StrategySelector` has logic to return MEAN_REVERT
- But NO actual strategy implementation exists
- If selected, system would fail or fallback to SMC

**Why This Matters:**
- Broken enum → unexpected behavior
- Mean reversion could diversify the strategy portfolio
- But may not make sense for XAUUSD scalping
- Need research before deciding

---

## Tasks

### Task 04-01: Mean Revert Research

**Status:** Not Started

**Research Questions:**

1. **Faz sentido para XAUUSD scalping?**
   - Gold é conhecido por trends fortes
   - Mas há períodos de consolidação
   - Regime detector já identifica esses períodos

2. **Quais indicadores usaríamos?**
   - Bollinger Bands (price touching bands)?
   - RSI oversold/overbought?
   - Mean reversion to VWAP?
   - Combination?

3. **StrategySelector já detecta regime "reverting":**
   - Hurst < 0.45 indica mean reversion
   - Como usar essa informação?
   - Trade contra extremos?

4. **Riscos:**
   - Mean reversion em trending market = disaster
   - Over-trading em ranges?
   - False signals?

**Research Sources:**
- Academic papers on mean reversion in commodities
- XAUUSD specific studies
- Existing implementations in the codebase

**Deliverable:** `orchestration/MEAN_REVERT_RESEARCH.md`

**Content:**
```markdown
# Mean Revert Research

## Summary
[1-paragraph summary with recommendation]

## Analysis

### XAUUSD Suitability
[Analysis of whether mean reversion fits XAUUSD]

### Proposed Implementation
[If recommending implementation, what would it look like?]

### Indicators to Use
- [ ] Bollinger Bands - rationale
- [ ] RSI - rationale
- [ ] Other - rationale

### Integration with Selector
[How would it work with existing RegimeDetector?]

### Risks
[What could go wrong?]

## Recommendation
[ ] IMPLEMENT - with this approach
[ ] REMOVE - not suitable for XAUUSD
[ ] DEFER - keep enum but don't implement yet
```

**Acceptance Criteria:**
- [ ] Research completed
- [ ] Clear recommendation provided
- [ ] Risks documented

---

### Task 04-02: User Decision Gate

**Status:** Not Started

**Present Options to User:**

```
Mean Revert Decision Required:

Based on research findings:
[Summary of research]

Options:
1. IMPLEMENT: Create signals/mean_revert.py (~200 lines)
   - Bollinger + RSI approach
   - Integrate with router
   - Backtest and validate
   - Effort: ~2 days

2. REMOVE: Delete enum and update Selector
   - Clean removal of MEAN_REVERT
   - Selector returns SMC when regime is reverting
   - Effort: ~30 minutes

3. DEFER: Keep enum, fallback to SMC
   - No code changes
   - When MEAN_REVERT selected, use SMC instead
   - Revisit later when we have more data
   - Effort: ~15 minutes

Your choice? (1/2/3)
```

**Decision Recording:**
```yaml
decision:
  date: YYYY-MM-DD
  choice: IMPLEMENT | REMOVE | DEFER
  rationale: "[user's reasoning]"
  action_plan: "[next steps]"
```

---

### Task 04-03: Execute Decision

**Status:** Not Started

**If IMPLEMENT:**

1. Create `src/signals/mean_revert.py`:
```python
class MeanRevertGenerator:
    """Generate mean reversion trading signals."""

    def __init__(self, config: MeanRevertConfig):
        self.bb_period = config.bb_period  # e.g., 20
        self.bb_std = config.bb_std  # e.g., 2.0
        self.rsi_period = config.rsi_period  # e.g., 14
        self.rsi_oversold = config.rsi_oversold  # e.g., 30
        self.rsi_overbought = config.rsi_overbought  # e.g., 70

    def generate_candidates(self, data) -> list[MeanRevertCandidate]:
        # Detect oversold: price near lower BB + RSI < oversold
        # Detect overbought: price near upper BB + RSI > overbought
        # Generate candidates with score
        pass
```

2. Create `MeanRevertCandidate` dataclass
3. Add `MEAN_REVERT` arm to router
4. Integrate in `gold_scalper_strategy.py`
5. Write tests
6. Run backtest

**If REMOVE:**

1. Remove from `StrategyType` enum (or keep but never return)
2. Update `StrategySelector` to not return MEAN_REVERT
3. Update any code that handles MEAN_REVERT
4. Run tests to verify no breaks

**If DEFER:**

1. Update `StrategySelector`:
```python
if selected == STRATEGY_MEAN_REVERT:
    return STRATEGY_SMC_SCALPER  # Fallback until implemented
```

2. Add TODO comment
3. Document deferral reason

---

## Execution Order

```
04-01 (Research) ─────→ [CRUCIBLE]
        ↓
04-02 (User Decision) ─→ [WAIT FOR USER]
        ↓
04-03 (Execute) ──────→ [FORGE if implement, else quick edit]
```

---

## Phase Completion Checklist

- [ ] Research completed
- [ ] Options presented to user
- [ ] User decision recorded
- [ ] Decision executed
- [ ] Tests pass

---

## Deliverables

1. `orchestration/MEAN_REVERT_RESEARCH.md` - Research findings
2. `orchestration/PHASE_04_DECISION.md` - Decision record
3. Code changes (if IMPLEMENT or REMOVE)

---

## Exit Criteria

Phase 04 is COMPLETE when:
1. User has made a clear decision
2. Decision has been executed
3. Tests pass
4. No broken enum paths remain

**Next Phase:** Phase 05 - Framework Integration
