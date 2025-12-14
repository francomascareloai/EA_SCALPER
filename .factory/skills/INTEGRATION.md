# SKILL INTEGRATION - Gold Trading Elite Squad

```
┌─────────────────────────────────────────────────────────────┐
│                   THE GOLD TRADING ELITE SQUAD              │
│                                                             │
│    🔥 CRUCIBLE    🛡️ SENTINEL    ⚒️ FORGE                   │
│    🔮 ORACLE      🔍 ARGUS                                  │
│                                                             │
│         "Cada skill e expert. Juntos, sao invenciveis."    │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. HANDOFF MATRIX (Quem Chama Quem)

```
                    CRUCIBLE
                    ┌───────┐
                    │MERCADO│
                    │SETUP  │
                    │REGIME │
                    └───┬───┘
                        │
         ┌──────────────┼──────────────┐
         │              │              │
         ▼              ▼              ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │SENTINEL │   │ ORACLE  │   │  FORGE  │
    │ /lot    │   │ /validar│   │/implementar
    │ /risco  │   │ /go-nogo│   │ /review │
    └────┬────┘   └────┬────┘   └────┬────┘
         │              │              │
         ▼              ▼              ▼
    ┌─────────────────────────────────────┐
    │              ARGUS                   │
    │         /pesquisar sempre            │
    │      Triangula e contribui           │
    └─────────────────────────────────────┘
```

### Tabela de Handoffs

| DE | PARA | QUANDO | DADOS ENVIADOS |
|----|------|--------|----------------|
| CRUCIBLE | SENTINEL | Setup validado | SL pips, direcao, tier |
| CRUCIBLE | ORACLE | Estrategia pronta | Parametros, periodo |
| CRUCIBLE | FORGE | Implementar pattern | Spec de entrada |
| SENTINEL | CRUCIBLE | Risk calculado | Lot, multiplicadores |
| SENTINEL | FORGE | Implementar circuit | Specs de CB |
| ORACLE | SENTINEL | GO aprovado | Max DD, sizing |
| ORACLE | FORGE | Bugs encontrados | Issues list |
| ORACLE | CRUCIBLE | Ajustar estrategia | Feedback metricas |
| FORGE | ORACLE | Codigo pronto | Modulo para validar |
| FORGE | CRUCIBLE | Implementado | Confirmacao |
| ARGUS | TODOS | Pesquisa completa | Findings, links |
| ARGUS | FORGE | Implementar finding | Code spec |

---

## 2. WORKFLOWS COMPOSTOS

### 2.1 OPEN TRADE (Fluxo Completo)

```
┌─────────────────────────────────────────────────────────────┐
│ WORKFLOW: OPEN TRADE (Setup → Execucao)                     │
└─────────────────────────────────────────────────────────────┘

FASE 1: ANALISE DE MERCADO (CRUCIBLE)
┌─────────────────────────────────────────────────────────────┐
│ 1. /mercado                                                 │
│    ├── Sessao: London-NY overlap?                          │
│    ├── Regime: PRIME ou NOISY trending?                    │
│    ├── Correlacoes: DXY, Yields, Ratio                     │
│    ├── News: Proximo HIGH impact?                          │
│    └── Estrutura: H1 trend, OB/FVG ativos                  │
│                                                             │
│ OUTPUT: Confluencia X/100, Direcao sugerida                │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Se confluencia > 70
                           ▼
FASE 2: VALIDACAO SETUP (CRUCIBLE)
┌─────────────────────────────────────────────────────────────┐
│ 2. /setup [buy/sell]                                        │
│    ├── Gates 1-2 (CRITICOS): Regime + Entropy              │
│    ├── Gates 3-10: Session, Spread, H1, M15, M5, OF, Liq   │
│    ├── Gates 11-12 (CRITICOS): DD Daily + Total            │
│    ├── Gates 13-15: Positions, R:R, Confluencia            │
│    └── Score: X/15                                          │
│                                                             │
│ OUTPUT: GO (>=13), CAUTION (11-12), NO GO (<11)           │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Se GO ou CAUTION
                           ▼
FASE 3: CALCULO DE RISCO (SENTINEL)
┌─────────────────────────────────────────────────────────────┐
│ 3. /lot [SL_pips]                                          │
│    ├── Lot base = (Equity × 0.5%) / (SL × TickValue)      │
│    ├── × Regime multiplier (0.5-1.0)                       │
│    ├── × DD multiplier (0.5-1.0)                           │
│    ├── × ML confidence multiplier (0.5-1.0)                │
│    └── Validar: Risk% <= 1%, Margem OK                     │
│                                                             │
│ OUTPUT: Lot final, Risk em %, FTMO compliance             │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Se validado
                           ▼
FASE 4: EXECUCAO
┌─────────────────────────────────────────────────────────────┐
│ 4. TRADE EXECUTION                                          │
│    ├── Entry: Preco atual ou limite                        │
│    ├── SL: Definido pelo setup                             │
│    ├── TP: R:R conforme estrategia                         │
│    └── Magic number: Identificador unico                   │
│                                                             │
│ LOG: Registrar todos parametros                            │
└─────────────────────────────────────────────────────────────┘
```

---

### 2.2 EMERGENCY (Fluxo de Crise)

```
┌─────────────────────────────────────────────────────────────┐
│ WORKFLOW: EMERGENCY (DD alto ou crash)                      │
└─────────────────────────────────────────────────────────────┘

TRIGGER: DD >= 4% detectado
                           │
                           ▼
FASE 1: ALERTA AUTOMATICO (SENTINEL)
┌─────────────────────────────────────────────────────────────┐
│ SENTINEL detecta e emite:                                   │
│ "🔴 SOFT STOP. DD em [X]%. ZERO novos trades."             │
│                                                             │
│ Acoes automaticas:                                          │
│ ├── Size multiplier = 0%                                    │
│ ├── Trading permitido = NAO                                │
│ └── Apenas gerenciamento de posicoes                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 2: ANALISE (CRUCIBLE + SENTINEL)
┌─────────────────────────────────────────────────────────────┐
│ Avaliar posicoes abertas:                                   │
│ ├── Quantas? Em lucro ou prejuizo?                         │
│ ├── Quanto cada uma contribui para DD?                     │
│ └── Regime atual favorece hold ou close?                   │
│                                                             │
│ Opcoes:                                                     │
│ A. HOLD (se regime favoravel, SL adequado)                 │
│ B. CLOSE (se regime desfavoravel)                          │
│ C. HEDGE (se incerteza alta)                               │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Franco decide
                           ▼
FASE 3: RECOVERY MODE
┌─────────────────────────────────────────────────────────────┐
│ Se DD reduziu para < 3%:                                    │
│ ├── Size = 25%                                             │
│ ├── Apenas Tier A+                                         │
│ ├── Max 1 trade/dia                                        │
│ └── 3 wins consecutivos para aumentar                      │
│                                                             │
│ Se DD continua >= 4%:                                       │
│ └── Manter SOFT STOP ate fim do dia                        │
└─────────────────────────────────────────────────────────────┘
```

---

### 2.3 GO-LIVE (Validacao Pre-Challenge)

```
┌─────────────────────────────────────────────────────────────┐
│ WORKFLOW: GO-LIVE (Backtest → FTMO Challenge)              │
└─────────────────────────────────────────────────────────────┘

FASE 1: BACKTEST BASICO (ORACLE)
┌─────────────────────────────────────────────────────────────┐
│ 1. /validar                                                 │
│    ├── Coletar dados: Trades >= 100, Periodo >= 2 anos    │
│    ├── Calcular metricas: Sharpe, SQN, DD, PF             │
│    └── Verificar thresholds                                │
│                                                             │
│ Se metricas OK → Proxima fase                              │
│ Se metricas FAIL → Voltar para CRUCIBLE ajustar           │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 2: WALK-FORWARD (ORACLE)
┌─────────────────────────────────────────────────────────────┐
│ 2. /wfa                                                     │
│    ├── Config: 12 windows, 70/30, 5 bar purge             │
│    ├── Calcular WFE para cada window                       │
│    ├── WFE medio >= 0.5?                                   │
│    └── Consistencia (quantos windows lucrativos)?          │
│                                                             │
│ Se WFE >= 0.5 → Proxima fase                               │
│ Se WFE < 0.5 → REJEITADO, voltar para design               │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 3: MONTE CARLO (ORACLE)
┌─────────────────────────────────────────────────────────────┐
│ 3. /montecarlo                                              │
│    ├── 5000 runs com block bootstrap                       │
│    ├── Calcular 95th percentile DD                         │
│    ├── Calcular P(Profit), P(DD > 10%)                     │
│    └── 95th DD <= 10%?                                      │
│                                                             │
│ Se 95th DD <= 10% → Proxima fase                           │
│ Se 95th DD > 10% → Ajustar sizing com SENTINEL             │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 4: OVERFITTING CHECK (ORACLE)
┌─────────────────────────────────────────────────────────────┐
│ 4. /overfitting                                             │
│    ├── Calcular PSR (Probabilistic Sharpe)                 │
│    ├── Calcular DSR (Deflated Sharpe)                      │
│    ├── PSR >= 0.90?                                        │
│    └── DSR > 0?                                            │
│                                                             │
│ Se DSR > 0 → Proxima fase                                  │
│ Se DSR <= 0 → OVERFITTED, redesenhar estrategia           │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 5: GO/NO-GO (ORACLE → SENTINEL)
┌─────────────────────────────────────────────────────────────┐
│ 5. /go-nogo                                                 │
│    ├── Compilar todos resultados                           │
│    ├── Checklist FTMO especifico                           │
│    └── Decisao final                                       │
│                                                             │
│ GO → SENTINEL calcula sizing final para $100k              │
│ CAUTION → Revisar pontos fracos                            │
│ NO GO → Voltar para CRUCIBLE/FORGE                         │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Se GO
                           ▼
FASE 6: SIZING FINAL (SENTINEL)
┌─────────────────────────────────────────────────────────────┐
│ 6. Configuracao para FTMO $100k                            │
│    ├── Risk per trade: 0.5% base                           │
│    ├── Max lot calculado para SL tipico                    │
│    ├── Circuit breakers configurados                       │
│    └── Alertas de DD ativados                              │
│                                                             │
│ OUTPUT: EA configurado e pronto para challenge             │
└─────────────────────────────────────────────────────────────┘
```

---

### 2.4 RESEARCH LOOP (Pesquisa Continua)

```
┌─────────────────────────────────────────────────────────────┐
│ WORKFLOW: RESEARCH LOOP (Melhoria Continua)                │
└─────────────────────────────────────────────────────────────┘

TRIGGER: Novo topico, claim, ou necessidade

                           │
                           ▼
FASE 1: PESQUISA (ARGUS)
┌─────────────────────────────────────────────────────────────┐
│ /pesquisar [topico]                                         │
│ ├── RAG local (mql5-books, mql5-docs)                      │
│ ├── Web search (perplexity, exa, brave)                    │
│ ├── GitHub (repos, code)                                    │
│ └── Scrape se necessario (firecrawl)                       │
│                                                             │
│ Triangular: Academico + Pratico + Empirico                 │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 2: VALIDACAO (ARGUS)
┌─────────────────────────────────────────────────────────────┐
│ /validar [finding]                                          │
│ ├── Quantas fontes confirmam?                              │
│ ├── Qualidade das fontes?                                  │
│ └── Nivel de confianca (ALTA/MEDIA/BAIXA)                  │
│                                                             │
│ Se ALTA → Proxima fase                                     │
│ Se MEDIA → Mais pesquisa                                   │
│ Se BAIXA → Descartar ou investigar mais                    │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Se ALTA confianca
                           ▼
FASE 3: APLICACAO (CRUCIBLE ou FORGE)
┌─────────────────────────────────────────────────────────────┐
│ Se e ESTRATEGIA → CRUCIBLE                                  │
│ ├── Integrar ao setup                                       │
│ └── Testar com /setup                                       │
│                                                             │
│ Se e CODIGO → FORGE                                         │
│ ├── Implementar modulo                                      │
│ └── Gerar testes                                            │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 4: VALIDACAO (ORACLE)
┌─────────────────────────────────────────────────────────────┐
│ /validar (novo codigo/estrategia)                          │
│ ├── Backtest com mudanca                                    │
│ ├── Comparar com baseline                                   │
│ └── Melhoria estatisticamente significante?                │
│                                                             │
│ Se SIM → Incorporar                                        │
│ Se NAO → Reverter ou ajustar                               │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
FASE 5: DOCUMENTACAO
┌─────────────────────────────────────────────────────────────┐
│ Salvar em DOCS/03_RESEARCH/FINDINGS/                       │
│ ├── Topico                                                  │
│ ├── Fontes consultadas                                      │
│ ├── Conclusoes                                              │
│ └── Impacto no projeto                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. PROTOCOLO DE COMUNICACAO

### Formato de Handoff

```
┌─────────────────────────────────────────────────────────────┐
│ HANDOFF: [ORIGEM] → [DESTINO]                              │
├─────────────────────────────────────────────────────────────┤
│ TRIGGER: [O que disparou o handoff]                        │
│ DADOS:   [Informacoes enviadas]                            │
│ ACAO:    [O que o destino deve fazer]                      │
│ RETORNO: [O que esperar de volta]                          │
└─────────────────────────────────────────────────────────────┘
```

### Exemplo Real

```
┌─────────────────────────────────────────────────────────────┐
│ HANDOFF: CRUCIBLE → SENTINEL                               │
├─────────────────────────────────────────────────────────────┤
│ TRIGGER: Setup validado como GO (14/15 gates)              │
│ DADOS:                                                     │
│   - Direcao: LONG                                          │
│   - SL: 35 pips                                            │
│   - Tier: A (14/15)                                        │
│   - Regime: PRIME_TRENDING                                 │
│ ACAO:   Calcular lot com /lot 35                          │
│ RETORNO: Lot final, risk %, validacao FTMO                │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. PROATIVIDADE E TRIGGERS

### Cada Skill Monitora:

| Skill | Monitora | Acao Automatica |
|-------|----------|-----------------|
| CRUCIBLE | Mencao de setup, mercado, sessao | Analisa e contribui |
| SENTINEL | DD, lot, risco, trades | Calcula e alerta |
| FORGE | Codigo, bug, erro | Escaneia e diagnostica |
| ORACLE | Backtest, resultado, live | Valida e questiona |
| ARGUS | Topico novo, claim | Pesquisa e triangula |

### Alertas Cross-Skill

```
SENTINEL detecta DD >= 3%:
├── Alerta para CRUCIBLE: "Modo CAUTION, apenas Tier A"
├── Alerta para FORGE: "Verificar se EA respeita circuit breaker"
└── Alerta para ORACLE: "Rever sizing pos-DD"

ORACLE detecta Sharpe > 3:
├── Alerta para todos: "Resultado suspeito, verificando overfitting"
└── Alerta para CRUCIBLE: "Nao usar estrategia ate validacao"

ARGUS detecta claim sem fonte:
├── Alerta: "Verificando claim..."
└── Busca evidencias automaticamente
```

---

## 5. RESOLUCAO DE CONFLITOS

### Hierarquia de Decisao

```
RISCO > ESTRATEGIA > PERFORMANCE > PESQUISA

1. SENTINEL (Risco) tem veto absoluto sobre trades
2. CRUCIBLE (Estrategia) define o setup
3. ORACLE (Performance) valida estatisticamente
4. ARGUS (Pesquisa) fornece fundamento teorico
5. FORGE (Codigo) implementa decisoes
```

### Cenarios de Conflito

| Conflito | Resolucao |
|----------|-----------|
| CRUCIBLE quer trade, SENTINEL bloqueia | SENTINEL vence (risco) |
| ORACLE aprova, SENTINEL diz DD alto | SENTINEL vence (risco) |
| ARGUS encontra paper contra estrategia | ORACLE testa, decide |
| FORGE diz codigo OK, ORACLE diz backtest ruim | ORACLE vence (dados) |

---

## 6. METRICAS DE COLABORACAO

### KPIs de Integracao

| Metrica | Target |
|---------|--------|
| Handoffs bem sucedidos | 95%+ |
| Tempo de resposta cross-skill | < 1 min |
| Conflitos resolvidos | 100% |
| Alertas proativos por sessao | 5-10 |
| Triangulacao ARGUS | 3+ fontes |

---

*"Um time de especialistas, unidos por um objetivo: consistencia."*

THE GOLD TRADING ELITE SQUAD - INTEGRATION v1.0
