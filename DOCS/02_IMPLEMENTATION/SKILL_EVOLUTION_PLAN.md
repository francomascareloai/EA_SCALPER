# Plano de Evolução dos Skills v2.2

**Data**: 2025-11-30  
**Status**: PLANEJADO  
**Baseado em**: 20 reflexões via Sequential Thinking  
**Objetivo**: Evoluir os 5 skills para v2.2 com padronização, decision trees, e integração

---

## 0. Princípios Orientadores

### O QUE FAZER
- ✅ Cada skill deve ser **autônomo** (funcionar sozinho)
- ✅ Adicionar seções **sem remover** conteúdo existente
- ✅ Manter formato **Markdown** (sem YAML/schemas complexos)
- ✅ Decision trees com **máximo 5 níveis**
- ✅ Redundância **intencional** de info crítica (FTMO rules)
- ✅ Implementar em **fases incrementais** (cada fase = sistema funcional)

### O QUE NÃO FAZER
- ❌ NÃO criar _shared folder (cada skill autônomo)
- ❌ NÃO remover conteúdo para "limpar"
- ❌ NÃO over-engineer protocolos
- ❌ NÃO criar dependências circulares
- ❌ NÃO automatizar demais (manual é OK)

---

## 1. Estado Atual

| Skill | Status | Versão | Tamanho | Faltando |
|-------|--------|--------|---------|----------|
| CRUCIBLE | ✅ Modularizado | v2.1 | 21.8KB | Decision trees, Triggers padronizados |
| FORGE | ✅ Modularizado | v2.1 | 22.6KB | Guardrails, Decision trees |
| SENTINEL | ✅ Modularizado | v1.0 | 19.9KB | Guardrails, MCPs nos workflows, Decision trees |
| ARGUS | ❌ Monolítico | - | 55.8KB | Tudo |
| ORACLE | ❌ Monolítico | - | 22.5KB | Tudo |

---

## 2. Estrutura Padrão v2.2

Cada skill deve ter estas seções no SKILL.md:

```markdown
---
name: skill-name
description: |
  ...
---

# SKILL vX.X

## Identity
## Core Principles
## Commands
## Workflows (com MCPs explícitos)
## Decision Trees (NOVO)
## Guardrails (NOVO - NUNCA FAÇA)
## Proactive Triggers (PADRONIZADO)
## Handoffs
## RAG Queries
```

---

## 3. Fases de Implementação

### FASE 1: Quick Wins (30 min)
**Objetivo**: Resolver inconsistências rápidas

| Tarefa | Skill | Descrição |
|--------|-------|-----------|
| 1.1 | SENTINEL | Atualizar versão v1.0 → v2.0 |
| 1.2 | SENTINEL | Adicionar seção Guardrails |
| 1.3 | FORGE | Adicionar seção Guardrails |
| 1.4 | ALL | Padronizar formato de Handoffs |

**Guardrails SENTINEL**:
```
❌ NUNCA arriscar mais que 1% por trade
❌ NUNCA ignorar DD > 4% (soft stop obrigatório)
❌ NUNCA operar em circuit breaker BLOCKED
❌ NUNCA calcular DD com Balance (usar Equity)
❌ NUNCA pular recovery mode após 5+ losses
❌ NUNCA operar 2min antes/depois de news HIGH (FTMO)
❌ NUNCA manter posições no weekend (FTMO)
```

**Guardrails FORGE**:
```
❌ NUNCA OrderSend sem verificar retcode
❌ NUNCA CopyBuffer sem ArraySetAsSeries
❌ NUNCA divisão sem guard clause
❌ NUNCA array access sem bounds check
❌ NUNCA entregar código sem Self-Correction (5 checks)
❌ NUNCA criar módulo sem Test scaffold
❌ NUNCA loop crítico com alocação de memória
```

---

### FASE 2: MCPs Explícitos (45 min)
**Objetivo**: Workflows procedurais com MCPs

| Tarefa | Skill | Descrição |
|--------|-------|-----------|
| 2.1 | SENTINEL | MCPs no workflow /lot |
| 2.2 | SENTINEL | MCPs no workflow /kelly |
| 2.3 | SENTINEL | MCPs no workflow /risco |
| 2.4 | FORGE | MCPs no workflow /bug |
| 2.5 | FORGE | MCPs no workflow /review |

**Exemplo /lot SENTINEL**:
```
PASSO 1: OBTER EQUITY
├── MCP: postgres___query (SELECT equity FROM account_state)
├── Fallback: Usar valor informado pelo usuário
└── Output: equity = $X

PASSO 2: CALCULAR BASE
├── MCP: calculator___div (equity * risk_pct, sl_pips * tick_value)
├── Formula: Lot = (Equity × Risk%) / (SL × TickValue)
└── Output: base_lot = X.XX

PASSO 3: APLICAR MULTIPLICADORES
├── Regime: via CRUCIBLE ou input
├── DD: via estado interno
├── Circuit: via estado interno
├── MCP: calculator___mul (base_lot, multiplicador_total)
└── Output: adjusted_lot = X.XX

PASSO 4: VALIDAR E RETORNAR
├── Check: lot >= min_lot AND lot <= max_lot
├── MCP: memory___add_observations (salvar cálculo)
└── Output: LOT RECOMENDADO: X.XX
```

---

### FASE 3: Decision Trees (1h)
**Objetivo**: Criar árvores de decisão visuais

| Skill | Tree | Descrição |
|-------|------|-----------|
| CRUCIBLE | "Posso analisar?" | Sessão → Regime → News |
| CRUCIBLE | "Setup válido?" | 15 gates resumidos |
| CRUCIBLE | "Qual estratégia?" | Regime → Strategy |
| SENTINEL | "Posso operar?" | DD → Circuit → Exposure |
| SENTINEL | "Qual tamanho?" | Base → Multiplicadores |
| SENTINEL | "Emergência?" | Triggers de ação |
| FORGE | "Como debugar?" | Tipo de bug → Protocolo |
| FORGE | "Código pronto?" | 5 checks |

**Exemplo Decision Tree CRUCIBLE - "Posso Analisar?"**:
```
┌─────────────────────────────────────────────────────────────────┐
│                    POSSO ANALISAR MERCADO?                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Regime = RANDOM_WALK?                                       │
│     ├─ SIM → 🛑 PARAR: "Sem edge, aguarde mudança de regime"   │
│     └─ NÃO → Continuar...                                       │
│                                                                 │
│  2. Sessão = Asia (22:00-07:00 GMT)?                           │
│     ├─ SIM → ⚠️ CAUTELA: "Spread alto (~40pts), baixa vol"     │
│     │         └─ Quer continuar mesmo assim?                   │
│     │             ├─ NÃO → 🛑 PARAR                            │
│     │             └─ SIM → Continuar com alerta...             │
│     └─ NÃO → Continuar...                                       │
│                                                                 │
│  3. News HIGH em 30min?                                         │
│     ├─ SIM → ⚠️ CAUTELA: "Aguardar após news"                  │
│     │         └─ FTMO: 2min antes/depois = BLOQUEADO           │
│     └─ NÃO → Continuar...                                       │
│                                                                 │
│  4. Daily DD > 4%?                                              │
│     ├─ SIM → 🟠 RESTRITO: "Soft stop, apenas gerenciar"        │
│     └─ NÃO → Continuar...                                       │
│                                                                 │
│  5. Spread > 30 pts?                                            │
│     ├─ SIM → ⚠️ AGUARDAR: "Spread normalizar"                  │
│     └─ NÃO → ✅ PODE ANALISAR                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Exemplo Decision Tree SENTINEL - "Posso Operar?"**:
```
┌─────────────────────────────────────────────────────────────────┐
│                      POSSO ABRIR TRADE?                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Circuit Breaker Level?                                      │
│     ├─ 3+ (SOFT STOP/EMERGENCY) → 🛑 BLOQUEADO                 │
│     ├─ 2 (CAUTION) → ⚠️ Size máximo 50%                        │
│     └─ 0-1 → Continuar...                                       │
│                                                                 │
│  2. Daily DD atual?                                             │
│     ├─ >= 5% → 🛑 BLOQUEADO (limite FTMO)                       │
│     ├─ >= 4% → 🟠 SOFT STOP (buffer esgotado)                  │
│     ├─ >= 3% → ⚠️ CAUTELA (size 75%)                           │
│     └─ < 3% → Continuar...                                      │
│                                                                 │
│  3. Posições abertas?                                           │
│     ├─ >= 3 → ⚠️ LIMITE: Fechar uma antes de abrir             │
│     └─ < 3 → Continuar...                                       │
│                                                                 │
│  4. Exposure total?                                             │
│     ├─ >= 3% → ⚠️ LIMITE: Reduzir exposure                     │
│     └─ < 3% → Continuar...                                      │
│                                                                 │
│  5. Loss streak?                                                │
│     ├─ >= 5 → 🛑 PARAR HOJE                                     │
│     ├─ >= 3 → ⚠️ COOLDOWN 1h, size 75%                         │
│     └─ < 3 → ✅ PODE OPERAR                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Exemplo Decision Tree FORGE - "Como Debugar?"**:
```
┌─────────────────────────────────────────────────────────────────┐
│                      DIAGNÓSTICO DE BUG                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Bug é em runtime (crash, erro)?                             │
│     ├─ SIM → PROTOCOLO P0.1 (Deep Debug)                       │
│     │        ├─ Invocar code-reasoning MCP                      │
│     │        ├─ 5+ thoughts de análise                          │
│     │        └─ Hipóteses ranqueadas                            │
│     └─ NÃO → Continuar...                                       │
│                                                                 │
│  2. Bug é de lógica (resultado errado)?                         │
│     ├─ SIM → ANÁLISE STEP-BY-STEP                              │
│     │        ├─ Identificar input/output esperado               │
│     │        ├─ Trace manual do código                          │
│     │        └─ Encontrar divergência                           │
│     └─ NÃO → Continuar...                                       │
│                                                                 │
│  3. Bug é de performance (lento)?                               │
│     ├─ SIM → PROFILING                                          │
│     │        ├─ GetMicrosecondCount() antes/depois              │
│     │        ├─ Identificar hot path                            │
│     │        └─ Otimizar (cache, algoritmo)                     │
│     └─ NÃO → Continuar...                                       │
│                                                                 │
│  4. Bug é de integração (ONNX, Python)?                         │
│     ├─ SIM → CHECK BOUNDARIES                                   │
│     │        ├─ Verificar shapes/tipos                          │
│     │        ├─ Verificar ordem de features                     │
│     │        └─ Verificar normalização                          │
│     └─ NÃO → ❓ DESCREVER MELHOR O PROBLEMA                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

### FASE 4: Proactive Triggers Padronizados (30 min)
**Objetivo**: Cada skill com triggers explícitos

**Formato padrão**:
```markdown
## Proactive Triggers

| Pattern | Ação | Prioridade |
|---------|------|------------|
| "bug", "erro", "crash" | Invocar P0.1 Deep Debug | ALTA |
| código mostrado | Executar Self-Correction | MÉDIA |
| novo módulo criado | Gerar Test scaffold | MÉDIA |
```

**CRUCIBLE Triggers**:
| Pattern | Ação | Prioridade |
|---------|------|------------|
| "XAUUSD", "ouro", "gold" | Verificar sessão atual | ALTA |
| "comprar", "vender", "entrar" | Alertar sobre regime/sessão | ALTA |
| "setup", "trade" | Sugerir /setup para validação | MÉDIA |
| início de conversa | Status rápido (sessão, regime) | MÉDIA |

**SENTINEL Triggers**:
| Pattern | Ação | Prioridade |
|---------|------|------------|
| "DD", "drawdown" | Mostrar status atual | ALTA |
| "lot", "tamanho", "quanto" | Calcular lot automaticamente | ALTA |
| "posso operar" | Executar decision tree | ALTA |
| DD >= 3% detectado | Alerta proativo | CRÍTICA |
| 3+ losses detectados | Sugerir cooldown | ALTA |

**FORGE Triggers**:
| Pattern | Ação | Prioridade |
|---------|------|------------|
| "bug", "erro", "falha", "crash" | Invocar code-reasoning | CRÍTICA |
| código MQL5 mostrado | Verificar anti-patterns | ALTA |
| "implementar", "criar" | Preparar TDD scaffold | MÉDIA |
| "performance", "lento" | Sugerir profiling | MÉDIA |

---

### FASE 5: Integração (45 min)
**Objetivo**: Protocolos de comunicação + arquivo de integração

**Protocolo de Handoff (simples)**:
```
┌─────────────────────────────────────────────────────────────────┐
│ HANDOFF REQUEST                                                 │
├─────────────────────────────────────────────────────────────────┤
│ FROM:     [SKILL origem]                                        │
│ TO:       [SKILL destino]                                       │
│ ACTION:   [comando a executar]                                  │
│ CONTEXT:  [informação relevante]                                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ HANDOFF RESPONSE                                                │
├─────────────────────────────────────────────────────────────────┤
│ STATUS:   [APPROVED / REJECTED / NEEDS_INFO]                    │
│ RESULT:   [dados do resultado]                                  │
│ NOTES:    [observações adicionais]                              │
└─────────────────────────────────────────────────────────────────┘
```

**Criar .factory/skills/INTEGRATION.md**:
- Matriz de handoffs (quem chama quem)
- Exemplos de composição (fluxos completos)
- Cenários comuns (abrir trade, emergência, debug)

---

### FASE 6: Expansão (2h)
**Objetivo**: Modularizar ARGUS e ORACLE com padrões v2.2

| Tarefa | Skill | Descrição |
|--------|-------|-----------|
| 6.1 | ARGUS | Backup + Modularização |
| 6.2 | ARGUS | Aplicar todos os padrões v2.2 |
| 6.3 | ORACLE | Backup + Modularização |
| 6.4 | ORACLE | Aplicar todos os padrões v2.2 |
| 6.5 | ALL | Atualizar versão para v2.2 |
| 6.6 | ALL | Atualizar INTEGRATION.md |

---

## 4. Métricas de Sucesso

| Métrica | Critério | Como Verificar |
|---------|----------|----------------|
| Consistência | Todos skills têm mesmas seções | Comparar estrutura |
| Completude | 60 fundamentos preservados | Verificar references.md |
| Usabilidade | Decision trees cobrem cenários | Testar fluxos |
| Integração | Handoffs funcionam | Simular composição |
| Tamanho | Cada skill < 30KB | Verificar bytes |
| Versão | Todos em v2.2 | Verificar headers |

---

## 5. Cronograma Estimado

| Fase | Duração | Acumulado |
|------|---------|-----------|
| Fase 1: Quick Wins | 30 min | 30 min |
| Fase 2: MCPs | 45 min | 1h 15min |
| Fase 3: Decision Trees | 1h | 2h 15min |
| Fase 4: Triggers | 30 min | 2h 45min |
| Fase 5: Integração | 45 min | 3h 30min |
| Fase 6: Expansão | 2h | 5h 30min |

**Total estimado**: ~5h 30min

---

## 6. Checklist de Execução

### Fase 1 ☐
- [ ] SENTINEL: Atualizar v1.0 → v2.0
- [ ] SENTINEL: Adicionar Guardrails
- [ ] FORGE: Adicionar Guardrails
- [ ] ALL: Padronizar Handoffs

### Fase 2 ☐
- [ ] SENTINEL: MCPs no /lot
- [ ] SENTINEL: MCPs no /kelly
- [ ] SENTINEL: MCPs no /risco
- [ ] FORGE: MCPs no /bug
- [ ] FORGE: MCPs no /review

### Fase 3 ☐
- [ ] CRUCIBLE: Tree "Posso analisar?"
- [ ] CRUCIBLE: Tree "Setup válido?"
- [ ] CRUCIBLE: Tree "Qual estratégia?"
- [ ] SENTINEL: Tree "Posso operar?"
- [ ] SENTINEL: Tree "Qual tamanho?"
- [ ] SENTINEL: Tree "Emergência?"
- [ ] FORGE: Tree "Como debugar?"
- [ ] FORGE: Tree "Código pronto?"

### Fase 4 ☐
- [ ] CRUCIBLE: Triggers padronizados
- [ ] SENTINEL: Triggers padronizados
- [ ] FORGE: Triggers padronizados

### Fase 5 ☐
- [ ] Definir protocolo de handoff
- [ ] Criar INTEGRATION.md
- [ ] Adicionar exemplos de composição

### Fase 6 ☐
- [ ] ARGUS: Backup
- [ ] ARGUS: Modularizar
- [ ] ARGUS: Aplicar padrões v2.2
- [ ] ORACLE: Backup
- [ ] ORACLE: Modularizar
- [ ] ORACLE: Aplicar padrões v2.2
- [ ] ALL: Versão → v2.2

---

## 7. Notas das Reflexões (Sequential Thinking)

### Decisões Chave Tomadas:
1. **Autonomia > Centralização**: Cada skill funciona sozinho, redundância intencional OK
2. **ASCII > Mermaid**: Decision trees em ASCII para máxima compatibilidade
3. **Protocolo simples**: 4 campos request, 3 campos response (não over-engineer)
4. **Fases incrementais**: Cada fase deixa sistema funcional
5. **Preservar > Limpar**: Adicionar seções, nunca remover conteúdo

### Riscos Identificados:
1. Over-engineering → Mitigado por princípio de simplicidade
2. Inconsistência → Mitigado por fases completas (todos skills de cada vez)
3. Quebrar existente → Mitigado por apenas adicionar, nunca remover

### O Que NÃO Fazer:
1. ❌ Shared folder
2. ❌ YAML/schemas complexos
3. ❌ Muitos campos obrigatórios
4. ❌ Decision trees > 5 níveis
5. ❌ Remover conteúdo existente
6. ❌ Dependências circulares

---

*Plano criado baseado em 20 reflexões via Sequential Thinking*
*Próximo passo: Executar Fase 1 (Quick Wins)*
