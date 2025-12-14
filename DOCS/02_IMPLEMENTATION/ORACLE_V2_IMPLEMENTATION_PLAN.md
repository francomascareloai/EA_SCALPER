# ORACLE v2.0 - Plano de Implementação Completo

**Data**: 2025-11-30
**Autor**: BMad Builder
**Fonte**: DEEP_DIVE_BACKTESTING_MASTER.md (ARGUS)
**Objetivo**: Transformar ORACLE em validador de backtesting state-of-art

---

## 1. VISÃO GERAL

### 1.1 Estado Atual do ORACLE

| Arquivo | Localização | Tamanho |
|---------|-------------|---------|
| Skill ORACLE | `.factory/skills/oracle-backtest-commander.md` | 1934 linhas |
| Deep Dive ARGUS | `DOCS/03_RESEARCH/FINDINGS/DEEP_DIVE_BACKTESTING_MASTER.md` | 3799 linhas |

### 1.2 Gap Analysis

| Feature | ORACLE Atual | Deep Dive ARGUS | Ação |
|---------|--------------|-----------------|------|
| WFA Básico | ✅ Tem | ✅ Tem melhor | ATUALIZAR |
| WFA Purged CV | ❌ Não tem | ✅ Completo | ADICIONAR |
| WFA CPCV | ❌ Não tem | ✅ Completo | ADICIONAR |
| Monte Carlo Block | ✅ Tem | ✅ Tem melhor | ATUALIZAR |
| Monte Carlo VaR/CVaR | ❌ Não tem | ✅ Completo | ADICIONAR |
| PSR (Probabilistic Sharpe) | ❌ Não tem | ✅ Completo | ADICIONAR |
| DSR (Deflated Sharpe) | ❌ Não tem | ✅ Completo | ADICIONAR |
| PBO (Prob Backtest Overfit) | ❌ Não tem | ✅ Completo | ADICIONAR |
| Execution Simulator Python | ❌ Não tem | ✅ Completo | ADICIONAR |
| Pipeline MT5→Python | ❌ Não tem | ✅ Completo | ADICIONAR |
| Estatísticas Prop Firms | ⚠️ Básico | ✅ Dados reais | ATUALIZAR |
| GO/NO-GO Integrado | ✅ Tem | ✅ Mais completo | ATUALIZAR |

### 1.3 Estratégia de Implementação

```
PRINCÍPIO: Dividir em 5 fases incrementais para não sobrecarregar contexto

FASE 1 → FASE 2 → FASE 3 → FASE 4 → FASE 5
  ↓         ↓         ↓         ↓         ↓
Overfit   WFA      Monte     Pipeline   PropFirm
Detection Upgrade  Carlo     Integrado  Stats
```

---

## 2. FASE 1: OVERFITTING DETECTION

### 2.1 Objetivo
Adicionar detecção científica de overfitting usando métricas de Lopez de Prado.

### 2.2 O Que Adicionar ao ORACLE

#### 2.2.1 Nova Seção: "PARTE X: DETECÇÃO DE OVERFITTING"

```markdown
# PARTE X: DETECÇÃO CIENTÍFICA DE OVERFITTING

## X.1 O Problema do Overfitting em Trading

[Copiar do Deep Dive - Subtema 3, Seção 3.1]
- Definição
- Por que é tão comum
- Exemplo clássico (1000 estratégias)

## X.2 Probabilistic Sharpe Ratio (PSR)

[Copiar do Deep Dive - Seção 3.2]
- Formula completa
- Interpretação (tabela)
- Por que é melhor que Sharpe tradicional

## X.3 Deflated Sharpe Ratio (DSR)

[Copiar do Deep Dive - Seção 3.3]
- Problema do Multiple Testing
- Formula E[max(SR)]
- Formula DSR
- Interpretação

## X.4 Probability of Backtest Overfitting (PBO)

[Copiar do Deep Dive - Seção 3.4]
- CPCV explicado
- Formula PBO
- Interpretação (tabela)

## X.5 Checklist Anti-Overfitting

[Copiar do Deep Dive - Seção 3.5]
- 10 items do checklist
```

#### 2.2.2 Novo Comando: `/overfitting`

```markdown
## Comando: /overfitting [backtest]

WORKFLOW:
1. Carregar dados do backtest
2. Calcular Sharpe observado
3. Calcular PSR (com skewness/kurtosis)
4. Calcular DSR (dado N trials)
5. Calcular PBO (se CPCV disponível)
6. Gerar relatório

OUTPUT:
┌─────────────────────────────────────────────────────────────────┐
│               OVERFITTING ANALYSIS REPORT                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SHARPE ANALYSIS:                                               │
│  ├── Observed Sharpe:      2.15                                │
│  ├── PSR (vs SR=0):        0.92 ✅                             │
│  ├── E[max(SR)] (N=10):    1.52                                │
│  ├── DSR:                  0.63 ✅                             │
│  └── Min Track Record:     45 trades                           │
│                                                                 │
│  VERDICT: LIKELY REAL EDGE                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 Código Python a Criar

**Arquivo**: `scripts/deflated_sharpe.py`

```python
# EXTRAIR DO DEEP DIVE - Seção 3.3.3
# Classe SharpeAnalyzer completa
# ~150 linhas
```

### 2.4 Localização no ORACLE

Inserir APÓS a seção atual de "DETECÇÃO DE BIAS" (Parte 6)
- Linha atual: ~linha 900-1000
- Nova seção: ~300 linhas

### 2.5 Checklist de Implementação FASE 1

```
□ 1. Ler seção atual de bias no ORACLE (identificar onde inserir)
□ 2. Criar nova seção "DETECÇÃO CIENTÍFICA DE OVERFITTING"
□ 3. Adicionar PSR com formula e interpretação
□ 4. Adicionar DSR com formula e interpretação
□ 5. Adicionar PBO com explicação
□ 6. Adicionar Checklist Anti-Overfitting (10 items)
□ 7. Adicionar comando /overfitting
□ 8. Criar scripts/deflated_sharpe.py
□ 9. Testar que skill carrega corretamente
```

---

## 3. FASE 2: WFA UPGRADE

### 3.1 Objetivo
Melhorar WFA existente com Purged CV e CPCV.

### 3.2 O Que Atualizar no ORACLE

#### 3.2.1 Atualizar Seção WFA Existente (Parte 3)

```markdown
## 3.1 Tipos de WFA: Rolling vs Anchored [NOVO]

[Copiar do Deep Dive - Seção 1.2]
- Diagrama Rolling
- Diagrama Anchored
- Quando usar cada um
- Recomendação para EA_SCALPER (Rolling)

## 3.2 Configuração Recomendada [ATUALIZAR]

WFA_CONFIG = {
    "type": "rolling",
    "n_windows": 15,
    "is_ratio": 0.75,
    "overlap": 0.20,
    "purge_gap": 0.02,      # NOVO
    "embargo_pct": 0.01,    # NOVO
    "min_trades_per_window": 30,
    "min_wfe": 0.6,
}

## 3.3 Purged Cross-Validation [NOVO]

[Copiar do Deep Dive - Seção 1.4]
- Problema do Data Leakage
- Solução: Purged K-Fold
- Diagrama com PURGE gap
- Código Python

## 3.4 CPCV - Combinatorial Purged CV [NOVO]

[Copiar do Deep Dive - Seção 1.4.3]
- Por que CPCV
- Mais caminhos = mais confiança
- Diagrama com paths
```

### 3.3 Código Python a Atualizar

**Arquivo**: `scripts/walk_forward_analysis.py`

```python
# EXTRAIR DO DEEP DIVE - Seção 1.5.2
# Classe WalkForwardAnalyzer atualizada
# Adicionar: Purged gap, Rolling/Anchored modes
# ~300 linhas
```

### 3.4 Checklist de Implementação FASE 2

```
□ 1. Identificar seção WFA atual no ORACLE (Parte 3)
□ 2. Adicionar seção Rolling vs Anchored
□ 3. Atualizar configuração recomendada
□ 4. Adicionar Purged Cross-Validation
□ 5. Adicionar CPCV
□ 6. Atualizar código Python
□ 7. Atualizar comando /wfa com novas opções
```

---

## 4. FASE 3: MONTE CARLO UPGRADE

### 4.1 Objetivo
Melhorar Monte Carlo com VaR/CVaR e critérios específicos FTMO.

### 4.2 O Que Atualizar no ORACLE

#### 4.2.1 Atualizar Seção Monte Carlo (Parte 4)

```markdown
## 4.X VaR e CVaR [NOVO]

[Copiar do Deep Dive - Seção 2.3]
- Definição VaR 95%
- Definição CVaR 95% (Expected Shortfall)
- Por que CVaR é mais útil
- Exemplo com números

## 4.X Critérios FTMO Específicos [ATUALIZAR]

CRITERIOS MC PARA FTMO:
┌────────────────────────────────────────────────────────────┐
│ Métrica              │ Limite  │ Descrição                │
├──────────────────────┼─────────┼──────────────────────────┤
│ P(Daily DD > 5%)     │ < 5%    │ Raramente viola diário   │
│ P(Total DD > 10%)    │ < 2%    │ Quase nunca viola total  │
│ 95th Percentile DD   │ < 8%    │ Buffer de segurança      │
│ VaR 95%              │ < 8%    │ Pior caso provável       │
│ CVaR 95%             │ < 10%   │ Média dos piores casos   │
└────────────────────────────────────────────────────────────┘

## 4.X Confidence Score [ATUALIZAR]

[Copiar do Deep Dive - método _calculate_confidence_score]
Score 0-100 baseado em:
- DD 95th (40 pontos)
- P(FTMO fail) (30 pontos)
- Sharpe (20 pontos)
- Return (10 pontos)
```

### 4.3 Código Python a Atualizar

**Arquivo**: Atualizar seção de Monte Carlo no skill

```python
# EXTRAIR DO DEEP DIVE - Seção 2.3
# Adicionar VaR/CVaR ao MonteCarloResult
# Adicionar confidence_score
# ~100 linhas de mudanças
```

### 4.4 Checklist de Implementação FASE 3

```
□ 1. Identificar seção Monte Carlo atual (Parte 4)
□ 2. Adicionar VaR e CVaR
□ 3. Atualizar critérios FTMO (tabela)
□ 4. Adicionar Confidence Score
□ 5. Atualizar código Python no skill
□ 6. Atualizar output do comando /montecarlo
```

---

## 5. FASE 4: PIPELINE INTEGRADO

### 5.1 Objetivo
Adicionar workflow completo MT5 → Python → GO/NO-GO.

### 5.2 O Que Adicionar ao ORACLE

#### 5.2.1 Nova Seção: "PARTE Y: PIPELINE DE VALIDAÇÃO"

```markdown
# PARTE Y: PIPELINE DE VALIDAÇÃO INTEGRADO

## Y.1 Arquitetura Híbrida MQL5+Python

[Copiar do Deep Dive - Seção 5.1-5.2]
- Por que híbrido
- Diagrama do pipeline
- Componentes

## Y.2 Exportação de Trades MT5 → Python

[Copiar do Deep Dive - Seção 5.3]
- Via Python API (MetaTrader5 package)
- Via XML Export
- Código mt5_trade_exporter.py

## Y.3 GO/NO-GO Validator

[Copiar do Deep Dive - Seção 5.4]
- ValidationCriteria
- ValidationResult
- GoNoGoValidator class
- Exemplo de uso

## Y.4 Workflow Completo

[Copiar do Deep Dive - Seção 5.5]
- Passo 1: Configurar EA
- Passo 2: Rodar MT5 Tester
- Passo 3: Exportar trades
- Passo 4: Executar validação
- Passo 5: Revisar relatório
```

#### 5.2.2 Novo Comando: `/pipeline`

```markdown
## Comando: /pipeline [trades.csv]

Executa pipeline completo de validação:
1. Load & Preprocess
2. Walk-Forward Analysis
3. Monte Carlo Block Bootstrap
4. Deflated Sharpe Ratio
5. Execution Cost Analysis
6. GO/NO-GO Decision

OUTPUT: Relatório completo em DOCS/04_REPORTS/VALIDATION/
```

### 5.3 Scripts Python a Criar

| Script | Linhas | Fonte no Deep Dive |
|--------|--------|-------------------|
| `scripts/mt5_trade_exporter.py` | ~200 | Seção 5.3.1 |
| `scripts/go_nogo_validator.py` | ~400 | Seção 5.4.2 |
| `scripts/full_validation_pipeline.py` | ~50 | Seção 5.5.2 |

### 5.4 Checklist de Implementação FASE 4

```
□ 1. Criar nova seção "PIPELINE DE VALIDAÇÃO"
□ 2. Adicionar arquitetura híbrida
□ 3. Adicionar exportação MT5→Python
□ 4. Adicionar GO/NO-GO Validator
□ 5. Adicionar workflow completo
□ 6. Criar scripts/mt5_trade_exporter.py
□ 7. Criar scripts/go_nogo_validator.py
□ 8. Criar scripts/full_validation_pipeline.py
□ 9. Adicionar comando /pipeline
```

---

## 6. FASE 5: ESTATÍSTICAS PROP FIRMS

### 6.1 Objetivo
Adicionar dados reais sobre prop firms e checklist pre-challenge.

### 6.2 O Que Atualizar no ORACLE

#### 6.2.1 Atualizar Seção FTMO (Parte 9)

```markdown
## 9.X Estatísticas Reais de Prop Firms [NOVO]

[Copiar do Deep Dive - Seção 6.1]
- Taxa de falha: 94% (300k+ contas)
- Funil de conversão (diagrama)
- Por que traders falham (tabela)

## 9.X Checklist Pre-Challenge [NOVO]

[Copiar do Deep Dive - Seção 6.4]
- 9 items obrigatórios antes de começar
- SE QUALQUER "NÃO" → NÃO INICIAR

## 9.X Position Sizing para Prop Firms [ATUALIZAR]

[Copiar do Deep Dive - Seção 6.3.3]
- Regra de ouro: Risk <= 1%
- Justificativa matemática
- Formula de lot size
- Exemplo com números
```

### 6.3 Checklist de Implementação FASE 5

```
□ 1. Identificar seção FTMO atual (Parte 9)
□ 2. Adicionar estatísticas reais (94% falham)
□ 3. Adicionar funil de conversão
□ 4. Adicionar "Por que traders falham"
□ 5. Adicionar Checklist Pre-Challenge
□ 6. Atualizar Position Sizing
□ 7. Atualizar comando /ftmo
```

---

## 7. REFERÊNCIA RÁPIDA: O QUE COPIAR DO DEEP DIVE

### 7.1 Seções para Copiar (com localização)

| Fase | Seção Deep Dive | Linhas Aprox | Destino no ORACLE |
|------|-----------------|--------------|-------------------|
| 1 | 3.1 Problema Overfitting | 1-50 | Nova Parte X |
| 1 | 3.2 PSR | 51-150 | Nova Parte X |
| 1 | 3.3 DSR + código | 151-300 | Nova Parte X |
| 1 | 3.4 PBO | 301-400 | Nova Parte X |
| 1 | 3.5 Checklist | 401-450 | Nova Parte X |
| 2 | 1.2 Rolling vs Anchored | 50-150 | Parte 3 |
| 2 | 1.4 Purged CV | 200-350 | Parte 3 |
| 3 | 2.3 VaR/CVaR | 300-400 | Parte 4 |
| 3 | 2.4 Interpretação | 400-450 | Parte 4 |
| 4 | 5.1-5.2 Arquitetura | 1933-2100 | Nova Parte Y |
| 4 | 5.3 Export | 2100-2400 | Nova Parte Y |
| 4 | 5.4 Validator | 2400-2800 | Nova Parte Y |
| 5 | 6.1 Estatísticas | 2800-3000 | Parte 9 |
| 5 | 6.3-6.4 Checklist | 3000-3150 | Parte 9 |

### 7.2 Código Python para Criar/Atualizar

| Arquivo | Ação | Fonte | Linhas |
|---------|------|-------|--------|
| `scripts/deflated_sharpe.py` | CRIAR | Deep Dive 3.3.3 | ~150 |
| `scripts/walk_forward_analysis.py` | CRIAR | Deep Dive 1.5.2 | ~300 |
| `scripts/monte_carlo_block_bootstrap.py` | CRIAR | Deep Dive 2.3 | ~250 |
| `scripts/execution_cost_analyzer.py` | CRIAR | Deep Dive 4.3 | ~300 |
| `scripts/mt5_trade_exporter.py` | CRIAR | Deep Dive 5.3.1 | ~200 |
| `scripts/go_nogo_validator.py` | CRIAR | Deep Dive 5.4.2 | ~400 |

---

## 8. ESTRUTURA FINAL DO ORACLE v2.0

```
ORACLE v2.0 - The Statistical Truth-Seeker
├── PARTE 0: CONTEXTO DO PROJETO (já adicionado)
├── PARTE 1: IDENTIDADE E PRINCÍPIOS (existente)
├── PARTE 2: COMANDOS (atualizar com novos)
├── PARTE 3: WALK-FORWARD ANALYSIS (FASE 2 - upgrade)
│   ├── 3.1 Rolling vs Anchored [NOVO]
│   ├── 3.2 WFE [existente]
│   ├── 3.3 Purged Cross-Validation [NOVO]
│   └── 3.4 CPCV [NOVO]
├── PARTE 4: MONTE CARLO (FASE 3 - upgrade)
│   ├── 4.1 Block Bootstrap [existente]
│   ├── 4.2 VaR e CVaR [NOVO]
│   ├── 4.3 Critérios FTMO [atualizar]
│   └── 4.4 Confidence Score [NOVO]
├── PARTE 5: MÉTRICAS (existente)
├── PARTE 6: DETECÇÃO DE BIAS (existente)
├── PARTE 7: DETECÇÃO DE OVERFITTING [NOVO - FASE 1]
│   ├── 7.1 Problema do Overfitting
│   ├── 7.2 PSR (Probabilistic Sharpe)
│   ├── 7.3 DSR (Deflated Sharpe)
│   ├── 7.4 PBO (Probability of Overfitting)
│   └── 7.5 Checklist Anti-Overfitting
├── PARTE 8: GO/NO-GO FRAMEWORK (existente - atualizar)
├── PARTE 9: VALIDAÇÃO FTMO (FASE 5 - upgrade)
│   ├── 9.1 Parâmetros FTMO [existente]
│   ├── 9.2 Estatísticas Reais [NOVO]
│   ├── 9.3 Por Que Traders Falham [NOVO]
│   ├── 9.4 Checklist Pre-Challenge [NOVO]
│   └── 9.5 Position Sizing [atualizar]
├── PARTE 10: PIPELINE DE VALIDAÇÃO [NOVO - FASE 4]
│   ├── 10.1 Arquitetura Híbrida
│   ├── 10.2 Export MT5→Python
│   ├── 10.3 GO/NO-GO Validator
│   └── 10.4 Workflow Completo
├── PARTE 11: ALERTAS PROATIVOS (existente)
└── PARTE 12: MCP TOOLKIT (existente)
```

---

## 9. NOVOS COMANDOS A ADICIONAR

| Comando | Fase | Descrição |
|---------|------|-----------|
| `/overfitting [backtest]` | 1 | Análise PSR/DSR/PBO |
| `/wfa --type rolling` | 2 | WFA com tipo especificado |
| `/wfa --purged` | 2 | WFA com Purged CV |
| `/montecarlo --ftmo` | 3 | MC com critérios FTMO |
| `/pipeline [trades.csv]` | 4 | Pipeline completo |
| `/propfirm [backtest]` | 5 | Validação prop firm |

---

## 10. ORDEM DE EXECUÇÃO

```
SESSÃO 1: FASE 1 (Overfitting Detection)
├── Ler ORACLE atual, identificar onde inserir
├── Adicionar nova PARTE 7
├── Criar scripts/deflated_sharpe.py
└── Testar

SESSÃO 2: FASE 2 (WFA Upgrade)
├── Atualizar PARTE 3
├── Adicionar Rolling/Anchored, Purged CV, CPCV
├── Criar scripts/walk_forward_analysis.py
└── Testar

SESSÃO 3: FASE 3 (Monte Carlo Upgrade)
├── Atualizar PARTE 4
├── Adicionar VaR/CVaR, Confidence Score
├── Criar scripts/monte_carlo_block_bootstrap.py
└── Testar

SESSÃO 4: FASE 4 (Pipeline Integrado)
├── Adicionar nova PARTE 10
├── Criar scripts de export e validator
└── Testar

SESSÃO 5: FASE 5 (Prop Firms Stats)
├── Atualizar PARTE 9
├── Adicionar estatísticas e checklists
└── Testar final
```

---

## 11. MÉTRICAS DE SUCESSO

Após implementação completa:

| Métrica | Antes | Depois |
|---------|-------|--------|
| Comandos disponíveis | 14 | 20 |
| Linhas do skill | 1934 | ~2800 |
| Scripts Python | 0 | 6 |
| Cobertura de Lopez de Prado | 20% | 90% |
| Critérios GO/NO-GO | 16 | 24 |

---

## 12. RISCOS E MITIGAÇÕES

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Skill muito grande para contexto | Média | Alto | Dividir em fases, testar cada uma |
| Código Python não funciona | Baixa | Médio | Testar scripts isoladamente |
| Perder contexto entre sessões | Média | Alto | Este documento como guia |
| Conflitos com estrutura existente | Baixa | Médio | Ler antes de editar |

---

## 13. COMANDOS ÚTEIS DURANTE IMPLEMENTAÇÃO

```bash
# Ver estrutura atual do ORACLE
type .factory\skills\oracle-backtest-commander.md | findstr /n "PARTE"

# Contar linhas
find /c /v "" .factory\skills\oracle-backtest-commander.md

# Ver seção específica do Deep Dive
type DOCS\03_RESEARCH\FINDINGS\DEEP_DIVE_BACKTESTING_MASTER.md | more

# Criar script
type nul > scripts\deflated_sharpe.py
```

---

*Documento criado por BMad Builder 🧙 - 2025-11-30*
*Use este documento como guia durante toda a implementação!*
