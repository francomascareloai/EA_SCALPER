# Skill Modularization Plan v2.0

**Data**: 2025-11-30
**Status**: CORRIGIDO - Alinhado com Factory Docs
**Objetivo**: Modularizar os 5 skills seguindo padrao oficial Factory CLI

---

## 0. Por Que Skills (Nao Droids)

| Feature | Skills | Custom Droids |
|---------|--------|---------------|
| Acesso a MCPs | ✅ Sim | ❌ Nao |
| Ferramentas externas | ✅ Sim | ❌ Limitado |
| Invocacao automatica | ✅ Pelo modelo | Manual via Task |
| Composicao | ✅ Chainable | Isolados |

**Conclusao**: Skills sao a escolha correta para CRUCIBLE, FORGE, etc. porque precisam de MCPs.

---

## 1. Estrutura Oficial Factory (Documentacao)

```
.factory/skills/<skill-name>/
├── SKILL.md          # OBRIGATORIO: frontmatter + instrucoes
├── references.md     # OPCIONAL: links para APIs, docs, tipos
├── checklists.md     # OPCIONAL: validacoes e gates
└── schemas/          # OPCIONAL: JSON/YAML schemas
```

**NAO documentado** (evitar):
- Subpastas arbitrarias (core/, knowledge/, workflows/)
- Estruturas profundas de diretorios
- Multiplos arquivos .md alem dos padrao

---

## 2. Estrutura Atual vs Proposta Corrigida

### Atual (Monolitico)
```
.factory/skills/
├── crucible-xauusd-expert.md     (~1300 linhas)
├── forge-code-architect.md       (~3200 linhas)
├── sentinel-risk-guardian.md     (~800 linhas)
├── oracle-backtest-commander.md  (~600 linhas)
├── argus-research-analyst.md     (~1200 linhas)
└── *-nano.md                     (versoes reduzidas)
```

### Proposta Corrigida (Alinhada com Factory Docs)
```
.factory/skills/
├── crucible/
│   ├── SKILL.md           # Core: identity + principles + commands + workflows
│   ├── references.md      # Links: RAG queries, MCPs, APIs, handoffs
│   └── checklists.md      # Gates: pre-trade, FTMO compliance
│
├── forge/
│   ├── SKILL.md           # Core: identity + principles + protocols P0.x
│   ├── references.md      # Links: RAG docs/books, patterns, libs
│   └── checklists.md      # Gates: self-correction, code quality
│
├── sentinel/
│   ├── SKILL.md           # Core: identity + principles + state machine
│   ├── references.md      # Links: calculadora, formulas, FTMO rules
│   └── checklists.md      # Gates: risk assessment, circuit breaker
│
├── oracle/
│   ├── SKILL.md           # Core: identity + principles + validation pipeline
│   ├── references.md      # Links: scripts Python, metricas, thresholds
│   └── checklists.md      # Gates: GO/NO-GO criteria
│
└── argus/
    ├── SKILL.md           # Core: identity + principles + research workflow
    ├── references.md      # Links: sources, MCPs de busca, RAG
    └── checklists.md      # Gates: triangulation, output format
```

---

## 3. Estrategia de Reducao de Tokens

### Antes: Tudo no arquivo principal
- Knowledge inline (sessoes, SMC, correlacoes...)
- Workflows completos
- Exemplos extensos
- Checklists

### Depois: Referencias ao RAG + Arquivos de Suporte

| Conteudo | Onde Fica | Como Acessar |
|----------|-----------|--------------|
| Identity/Principles | `SKILL.md` | Sempre carregado |
| Commands/Routing | `SKILL.md` | Sempre carregado |
| Knowledge detalhado | `.rag-db/books/` | Query semantica sob demanda |
| Sintaxe MQL5 | `.rag-db/docs/` | Query semantica sob demanda |
| Workflows step-by-step | `SKILL.md` (resumido) | Inline |
| Checklists/Gates | `checklists.md` | Carregado quando validar |
| Links/APIs/Handoffs | `references.md` | Carregado quando precisar |

**Economia estimada**: 40-60% de tokens por skill

---

## 4. Template SKILL.md (Padrao Factory)

```markdown
---
name: crucible-xauusd-expert
description: |
  CRUCIBLE - The Battle-Tested Gold Veteran. Expert trader de XAUUSD 
  com 20+ anos de experiencia. Combina SMC, Order Flow e analise 
  institucional. Use para analise de mercado, validacao de setups,
  e review de codigo de estrategia.
  
  Triggers: "Crucible", "mercado", "setup", "XAUUSD", "ouro", "gold"
---

# CRUCIBLE - The Battle-Tested Gold Veteran v2.0

## Identity
[Resumo da persona - 10-15 linhas max]

## Core Principles
[10 mandamentos - lista concisa]

## Commands
| Comando | Acao |
|---------|------|
| /mercado | Analise completa do mercado |
| /setup [tipo] | Validar setup especifico |
| /regime | Detectar regime atual |

## Workflows

### /mercado
1. Verificar sessao atual (time MCP)
2. Buscar preco XAUUSD (twelve-data MCP)
3. Consultar correlacoes DXY/yields (perplexity MCP)
4. Consultar RAG para contexto SMC (mql5-books)
5. Sintetizar analise

### /setup
1. Receber parametros do setup
2. Validar contra checklist (ver checklists.md)
3. Calcular score de confluencia
4. Emitir recomendacao

## Handoffs
- → SENTINEL: "Verificar risco antes de executar"
- → ORACLE: "Validar estatisticamente"
- → FORGE: "Implementar em codigo"

## RAG Queries (sob demanda)
Para knowledge detalhado, consultar:
- SMC/ICT: `mql5-books "order blocks" OR "fair value gap"`
- Sessoes: `mql5-books "london session" OR "new york session"`
- Correlacoes: `mql5-books "DXY correlation" OR "gold correlation"`
```

---

## 5. Template references.md

```markdown
# References - CRUCIBLE

## MCPs Primarios
| MCP | Uso | Limite |
|-----|-----|--------|
| twelve-data | Precos XAUUSD real-time | 8 req/min |
| perplexity | DXY, COT, macro | Normal |
| mql5-books | SMC, Order Flow, teoria | Ilimitado |
| mql5-docs | Sintaxe MQL5 | Ilimitado |
| time | Sessoes, fusos | Ilimitado |
| memory | Contexto persistente | Ilimitado |

## RAG Queries Uteis
```
# SMC Patterns
mql5-books "order block" OR "breaker block" OR "mitigation"

# Sessoes
mql5-books "asian session" OR "london session" OR "new york"

# Correlacoes
mql5-books "DXY" OR "US10Y" OR "gold correlation"
```

## Handoffs
| Para | Quando | Trigger |
|------|--------|---------|
| SENTINEL | Calcular risco/lot | "verificar risco", "calcular lot" |
| ORACLE | Validar backtest | "validar estatisticamente" |
| FORGE | Implementar codigo | "implementar", "codar" |

## APIs Externas
- Forex Factory: Calendario economico
- TradingView: Charts (via perplexity search)
```

---

## 6. Template checklists.md

```markdown
# Checklists - CRUCIBLE

## Pre-Trade Checklist
- [ ] Sessao ativa? (London/NY overlap preferido)
- [ ] Regime != RANDOM_WALK?
- [ ] News de alto impacto em 30min?
- [ ] Correlacoes alinhadas? (DXY inverso)
- [ ] Setup tem confluencia >= 3 fatores?

## FTMO Compliance
- [ ] Risk/trade <= 1%?
- [ ] Daily DD atual < 4%?
- [ ] Total DD atual < 8%?
- [ ] Posicao unica (nao piramide)?

## Setup Validation (15 Gates)
1. [ ] Direcao alinhada com HTF bias
2. [ ] Order Block identificado
3. [ ] Liquidity sweep ocorreu
4. [ ] FVG presente para entrada
5. [ ] RR >= 1:2 minimo
6. [ ] SL atras de estrutura
7. [ ] TP em nivel logico
8. [ ] Volume confirma
9. [ ] Spread aceitavel
10. [ ] Horario adequado
11. [ ] Sem news iminente
12. [ ] Correlacoes OK
13. [ ] Regime favoravel
14. [ ] DD disponivel
15. [ ] Confianca >= 7/10
```

---

## 7. Plano de Execucao Corrigido

### Fase 1: Piloto com CRUCIBLE (1h)
- [ ] Criar pasta `.factory/skills/crucible/`
- [ ] Criar SKILL.md seguindo template
- [ ] Criar references.md
- [ ] Criar checklists.md
- [ ] Testar que Factory reconhece o skill
- [ ] Testar invocacao com triggers
- [ ] Validar acesso a MCPs funciona

### Fase 2: Se Piloto OK, Migrar Demais (2h)
- [ ] FORGE (maior, ~45min)
- [ ] SENTINEL (~30min)
- [ ] ORACLE (~30min)
- [ ] ARGUS (~30min)

### Fase 3: Cleanup (30min)
- [ ] Mover skills antigos para `_archive/`
- [ ] Atualizar AGENTS.md
- [ ] Remover versoes *-nano.md
- [ ] Commit final

**Tempo Total**: ~3.5 horas

---

## 8. Criterios de Sucesso

| Criterio | Como Verificar |
|----------|----------------|
| Factory reconhece skill | Aparece em `/skills` ou invocacao |
| MCPs funcionam | Testar twelve-data, perplexity no skill |
| RAG funciona | Query mql5-books retorna resultados |
| Reducao tokens | Comparar contexto antes/depois |
| Triggers funcionam | Dizer "Crucible mercado" ativa skill |

---

## 9. Rollback Plan

```
Se algo der errado:
1. Skills antigos em .factory/skills/_archive/
2. Reverter: copy _archive/*.md para skills/
3. Factory volta a funcionar
```

---

## 10. Diferencas vs Plano Original

| Aspecto | Plano v1 (Errado) | Plano v2 (Corrigido) |
|---------|-------------------|----------------------|
| Subpastas | core/, knowledge/, workflows/ | Apenas raiz do skill |
| Arquivos | 15+ por skill | 3 por skill (SKILL, refs, checks) |
| Knowledge | Em arquivos .md | No RAG (ja esta la!) |
| Estrutura | Profunda, complexa | Flat, documentada |
| Economia tokens | Assumida | Via RAG queries |

---

## 11. Proximos Passos

1. **Aprovar este plano corrigido**
2. **Executar Fase 1** (piloto CRUCIBLE)
3. **Validar** que tudo funciona
4. **Continuar** com demais skills

Quer que eu inicie o piloto com CRUCIBLE agora?
