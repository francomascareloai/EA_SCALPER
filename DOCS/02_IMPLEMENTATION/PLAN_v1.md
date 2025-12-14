# EA_SCALPER_XAUUSD - PLANO DE IMPLEMENTAÇÃO COMPLETO

**Versão**: 1.0  
**Data**: 2025-11-30  
**Autor**: Droid (Claude) + Franco  
**Status**: APROVADO PARA EXECUÇÃO

---

## EXECUTIVE SUMMARY

Este documento define o plano completo para levar o EA_SCALPER_XAUUSD de **especificação** para **produção institucional**. O plano foi desenvolvido após:
- Criação de 5 agentes especializados (~9,500 linhas de expertise)
- Party Mode Session #001 com implementação de P1/P2/P3
- Reflexão profunda sobre abordagens alternativas

**Abordagem escolhida**: HYBRID VALIDATION + BUILD
- Não é "validate then build" (muito sequencial)
- Não é "build then validate" (muito arriscado)
- É "audit → validate baseline → build iteratively"

**Timeline estimado**: 5-9 semanas até produção

---

## PRINCÍPIOS DE DESIGN DO PLANO

1. **Cada fase tem deliverables CLAROS** - outputs específicos
2. **Cada fase tem SUCCESS CRITERIA** - como saber se passou
3. **Cada fase pode ser executada por QUALQUER agent** - auto-contido
4. **Checkpoints permitem correção de curso** - não é waterfall
5. **MVP mindset** - pode deployar após Phase 4 se necessário

---

## INVENTÁRIO ATUAL (Pre-Phase 0)

### O Que Já Existe

| Componente | Status | Localização |
|------------|--------|-------------|
| Agent Skills (5) | ✅ Completo | `.factory/skills/` |
| NANO versions (5) | ✅ Completo | `.factory/skills/*-nano.md` |
| AGENTS.md routing | ✅ Completo | `AGENTS.md` |
| MQL5 Structure | ⚠️ Parcial | `MQL5/Include/EA_SCALPER/` |
| Python Agent Hub | ⚠️ Parcial | `Python_Agent_Hub/` |
| RAG Database | ✅ Completo | `.rag-db/` (24,544 chunks) |
| PRD Specification | ✅ Completo | `DOCS/prd.md` |
| Party Mode Session | ✅ Completo | `DOCS/PARTY_MODE/` |

### O Que Falta

| Componente | Prioridade | Phase |
|------------|------------|-------|
| Audit do código existente | CRÍTICO | 0 |
| Dados XAUUSD limpos | CRÍTICO | 1 |
| Backtest baseline | CRÍTICO | 1 |
| WFA com dados reais | CRÍTICO | 2 |
| Monte Carlo real | CRÍTICO | 2 |
| Modelo ONNX treinado | ALTO | 3 |
| Integração completa | ALTO | 4 |
| WATCHTOWER agent | MÉDIO | 5 |
| Paper trading results | MÉDIO | 6 |

---

## PHASE 0: AUDIT (1-2 dias)

### Objetivo
Inventariar o código existente, identificar gaps, e priorizar trabalho.

### Tasks

#### 0.1 Audit MQL5 Structure
```
COMANDO: Usar FORGE para auditar

ARQUIVOS A VERIFICAR:
├── MQL5/Include/EA_SCALPER/
│   ├── Core/ (verificar existência e completude)
│   ├── Risk/ (FTMO_RiskManager.mqh status)
│   ├── Analysis/ (regime detection status)
│   ├── ML/ (ONNX integration status)
│   ├── Backtest/ (CBacktestRealism.mqh status)
│   └── Safety/ (circuit breakers status)
│
├── MQL5/Experts/
│   └── EA_SCALPER_XAUUSD.mq5 (main EA status)

OUTPUT: DOCS/AUDIT_MQL5.md com:
- Lista de arquivos existentes
- Status de cada módulo (COMPLETE/PARTIAL/MISSING)
- Gaps identificados
- Dependências mapeadas
```

#### 0.2 Audit Python Agent Hub
```
COMANDO: Usar FORGE para auditar

ARQUIVOS A VERIFICAR:
├── Python_Agent_Hub/
│   ├── app/services/regime_detector.py (status)
│   ├── app/services/feature_engineering.py (status)
│   ├── app/models/ (ONNX models status)
│   └── requirements.txt (dependencies)

OUTPUT: DOCS/AUDIT_PYTHON.md
```

#### 0.3 Create Gap Analysis
```
COMANDO: Combinar audits em análise de gaps

OUTPUT: DOCS/GAP_ANALYSIS.md com:
- Matriz: Componente vs Status vs Prioridade
- Estimativa de esforço por gap
- Dependências entre gaps
- Ordem de implementação recomendada
```

### Deliverables Phase 0
- [ ] `DOCS/AUDIT_MQL5.md`
- [ ] `DOCS/AUDIT_PYTHON.md`
- [ ] `DOCS/GAP_ANALYSIS.md`

### Success Criteria Phase 0
- [ ] 100% dos diretórios MQL5 auditados
- [ ] 100% dos arquivos Python auditados
- [ ] Gap analysis com prioridades definidas
- [ ] Próximos passos claros

### Checkpoint
```
DECISÃO: Se gaps são MÍNIMOS → Pular para Phase 2
         Se gaps são SIGNIFICATIVOS → Phase 1 inclui remediation
```

---

## PHASE 1: DATA + BASELINE (3-5 dias)

### Objetivo
Obter dados limpos e estabelecer baseline de performance.

### Tasks

#### 1.1 Data Acquisition
```
OPÇÃO A: Export do MT5 (preferido)
- Abrir MT5
- Symbols → XAUUSD → Export Bars
- Período: 2022-01-01 a 2024-12-31
- Timeframe: M5
- Formato: CSV
- Salvar em: data/XAUUSD_M5_2022_2024.csv

OPÇÃO B: API (fallback)
- Usar twelve-data MCP
- Limitado a 5000 candles por request
- Precisa de múltiplas requests

OPÇÃO C: Public Data (último recurso)
- Kaggle datasets
- Dukascopy historical

OUTPUT: data/XAUUSD_M5_2022_2024.csv
FORMATO: datetime,open,high,low,close,volume
LINHAS ESPERADAS: ~150,000+ (3 anos de M5)
```

#### 1.2 Data Validation
```python
# scripts/validate_data.py

VERIFICAÇÕES:
□ Sem gaps maiores que 2 dias (exceto weekends)
□ Sem valores negativos
□ Sem duplicatas
□ Timezone consistente (UTC preferido)
□ Volume não-zero em >95% das bars

OUTPUT: DOCS/DATA_QUALITY_REPORT.md
```

#### 1.3 Baseline Backtest
```
OBJETIVO: Rodar backtest SIMPLES para ter baseline

ESTRATÉGIA BASELINE:
- Entry: Cruzamento de MAs (simple)
- Exit: Fixed TP/SL
- Risk: 1% por trade
- Sem ML, sem regime detection

FERRAMENTA: MT5 Strategy Tester ou Python backtest

OUTPUT:
- Reports/BASELINE_BACKTEST.html
- DOCS/BASELINE_METRICS.md com:
  - Total trades
  - Win rate
  - Profit factor
  - Max drawdown
  - Sharpe ratio
```

### Deliverables Phase 1
- [ ] `data/XAUUSD_M5_2022_2024.csv` (dados limpos)
- [ ] `scripts/validate_data.py`
- [ ] `DOCS/DATA_QUALITY_REPORT.md`
- [ ] `Reports/BASELINE_BACKTEST.html`
- [ ] `DOCS/BASELINE_METRICS.md`

### Success Criteria Phase 1
- [ ] Dados com >95% quality score
- [ ] Baseline backtest executado
- [ ] Métricas baseline documentadas
- [ ] Dados prontos para WFA

---

## PHASE 2: VALIDATION PIPELINE (5-7 dias)

### Objetivo
Implementar e executar validação estatística completa.

### Tasks

#### 2.1 Create Validation Pipeline
```python
# scripts/validation_pipeline.py

COMPONENTES:
1. DataLoader - carrega e prepara dados
2. StrategyRunner - executa estratégia
3. WFAAnalyzer - Walk-Forward Analysis
4. MonteCarloSimulator - Block Bootstrap MC
5. ReportGenerator - gera relatórios

USAR: Código já implementado em ORACLE 11.0.4 e 4.6
```

#### 2.2 Execute WFA
```
CONFIGURAÇÃO:
- Windows: 10
- IS/OOS Split: 70/30
- Overlap: 25%
- Min trades per window: 10
- Período: 2022-2024

MÉTRICAS A CALCULAR:
- WFE (Return-based)
- WFE (Sharpe-based)
- OOS Positive %
- OOS Consistency (StdDev)

OUTPUT: Reports/WFA_REPORT.md
```

#### 2.3 Execute Monte Carlo
```
CONFIGURAÇÃO:
- Simulations: 5000
- Method: Block Bootstrap (usar código de ORACLE 4.6)
- Block size: Auto-calculated

MÉTRICAS A CALCULAR:
- DD 5th/50th/95th/99th percentile
- Profit distribution
- Risk of ruin (5% and 10%)
- Streak analysis

OUTPUT: Reports/MONTECARLO_REPORT.md
```

#### 2.4 Generate GO/NO-GO Report
```
USAR: ORACLE /go-nogo criteria

CRITERIOS MANDATÓRIOS (8):
□ 1. Trades >= 100
□ 2. Win Rate >= 40%
□ 3. Profit Factor >= 1.5
□ 4. Max DD <= 15%
□ 5. WFE >= 0.5
□ 6. OOS Positive >= 60%
□ 7. SQN >= 2.0
□ 8. Expectancy > 0

CRITERIOS DE QUALIDADE (8):
□ 9.  Monte Carlo 95th DD < 8%
□ 10. % Profitable Months > 60%
□ 11. Sharpe > 1.5
□ 12. Sortino > 2.0
□ 13. Calmar > 3.0
□ 14. Recovery Factor > 3.0
□ 15. SQN >= 2.5
□ 16. P-value < 0.05

OUTPUT: Reports/GO_NOGO_REPORT.md
```

### Deliverables Phase 2
- [ ] `scripts/validation_pipeline.py`
- [ ] `scripts/wfa_analyzer.py`
- [ ] `scripts/monte_carlo.py`
- [ ] `Reports/WFA_REPORT.md`
- [ ] `Reports/MONTECARLO_REPORT.md`
- [ ] `Reports/GO_NOGO_REPORT.md`

### Success Criteria Phase 2
- [ ] WFE >= 0.5 (MÍNIMO para prosseguir)
- [ ] Monte Carlo 95th DD < 10%
- [ ] 8/8 critérios mandatórios passam
- [ ] GO ou GO_WITH_CAUTION no relatório

### Checkpoint CRÍTICO
```
SE GO → Prosseguir para Phase 3
SE NO-GO → PARAR e revisar estratégia

NÃO PROSSEGUIR COM NO-GO!
Melhor descobrir agora do que perder dinheiro depois.
```

---

## PHASE 3: ML/ONNX MODEL (7-10 dias)

### Objetivo
Treinar, validar e exportar modelo de ML para predição de direção.

### Tasks

#### 3.1 Feature Engineering
```python
# scripts/feature_engineering.py

FEATURES (15 do PRD):
1. RSI(14)
2. MACD histogram
3. ATR(14)
4. Bollinger Band position
5. SMA crossover signal
6. Volume ratio
7. Price momentum
8. Hurst exponent
9. Shannon entropy
10. DXY correlation
11. Hour of day (cyclical)
12. Day of week (cyclical)
13. Recent high distance
14. Recent low distance
15. Spread normalized

OUTPUT: data/features_2022_2024.parquet
```

#### 3.2 Model Training
```python
# scripts/train_model.py

ARQUITETURA:
- LSTM ou GRU (começar simples)
- Input: 15 features × lookback (20-50 bars)
- Output: Direction probability (0-1)
- Hidden: 64-128 units

TRAINING:
- Split: Time-based (não random!)
- Train: 2022-2023
- Validation: 2024 H1
- Test: 2024 H2

FRAMEWORKS:
- PyTorch ou TensorFlow
- Export to ONNX

OUTPUT: 
- models/direction_model.onnx
- DOCS/MODEL_ARCHITECTURE.md
```

#### 3.3 Model Validation (ML-specific WFA)
```
IMPORTANTE: ML precisa de validação EXTRA

USAR: Walk-Forward Analysis com retraining
- Retrain em cada window IS
- Test em window OOS
- Medir WFE do MODELO (não da estratégia)

MÉTRICAS:
- Accuracy OOS
- AUC-ROC OOS
- Calibration (Brier score)
- Feature importance (SHAP)

OUTPUT: Reports/ML_VALIDATION_REPORT.md
```

#### 3.4 ONNX Integration Test
```cpp
// Test em MQL5

VERIFICAR:
□ ONNX carrega sem erro
□ Inference < 5ms
□ Output shape correto
□ Probabilidades entre 0-1
□ Threshold de 0.65 funciona

OUTPUT: Tests/test_onnx_integration.mq5
```

### Deliverables Phase 3
- [ ] `scripts/feature_engineering.py`
- [ ] `scripts/train_model.py`
- [ ] `data/features_2022_2024.parquet`
- [ ] `models/direction_model.onnx`
- [ ] `DOCS/MODEL_ARCHITECTURE.md`
- [ ] `Reports/ML_VALIDATION_REPORT.md`
- [ ] `Tests/test_onnx_integration.mq5`

### Success Criteria Phase 3
- [ ] WFE do modelo >= 0.6
- [ ] Accuracy OOS >= 55%
- [ ] Inference time < 5ms
- [ ] ONNX integra com MQL5 sem erros

---

## PHASE 4: EA INTEGRATION (5-7 dias)

### Objetivo
Integrar todos os componentes no EA final.

### Tasks

#### 4.1 Fill Code Gaps (from Phase 0 audit)
```
BASEADO NO GAP_ANALYSIS.md:

COMPONENTES A COMPLETAR:
□ CSignalManager - entry/exit logic
□ CRiskManager - SENTINEL rules integradas
□ CRegimeDetector - strategy switching (CRUCIBLE 11.x)
□ COnnxBrain - ML inference wrapper
□ CCircuitBreaker - emergency stops

CADA COMPONENTE DEVE:
- Seguir padrões de FORGE
- Ter error handling completo
- Ter logging apropriado
- Ter testes unitários
```

#### 4.2 Main EA Assembly
```cpp
// MQL5/Experts/EA_SCALPER_XAUUSD.mq5

ESTRUTURA:
int OnInit() {
    // Load ONNX
    // Initialize managers
    // Connect to Python Hub (if needed)
}

void OnTick() {
    // 1. Check circuit breakers (SENTINEL)
    // 2. Detect regime (CRUCIBLE)
    // 3. Get ML prediction (ORACLE validation)
    // 4. Check entry conditions
    // 5. Calculate position size (SENTINEL)
    // 6. Execute trade
    // 7. Log everything
}

void OnDeinit() {
    // Cleanup
}
```

#### 4.3 Integration Tests
```
TEST SUITE:

1. Unit Tests (cada componente)
   - CRiskManager_Test.mq5
   - CSignalManager_Test.mq5
   - etc.

2. Integration Tests
   - Full cycle test (entry to exit)
   - FTMO compliance test
   - Circuit breaker trigger test
   - Regime switch test

3. Stress Tests
   - High volatility simulation
   - Gap handling
   - Connection loss recovery

OUTPUT: Tests/ directory com todos os testes
```

#### 4.4 Full Backtest with ML
```
EXECUTAR:
- MT5 Strategy Tester
- Período: 2024 (OOS do model training)
- Mode: Every tick based on real ticks
- Com CBacktestRealism em SIM_PESSIMISTIC

COMPARAR:
- Baseline (Phase 1) vs ML-enhanced
- Improvement esperado: 20%+ em Sharpe

OUTPUT: Reports/FULL_BACKTEST_ML.md
```

### Deliverables Phase 4
- [ ] `MQL5/Include/EA_SCALPER/` completo
- [ ] `MQL5/Experts/EA_SCALPER_XAUUSD.mq5`
- [ ] `Tests/*.mq5` (suite de testes)
- [ ] `Reports/FULL_BACKTEST_ML.md`

### Success Criteria Phase 4
- [ ] Todos os testes passam
- [ ] Backtest ML > Baseline
- [ ] FTMO compliance verificada
- [ ] Sem memory leaks
- [ ] OnTick < 50ms

---

## PHASE 5: HARDENING (3-5 dias)

### Objetivo
Preparar para produção com monitoramento e segurança.

### Tasks

#### 5.1 WATCHTOWER Agent
```
CRIAR: .factory/skills/watchtower-monitor.md

RESPONSABILIDADES:
- Live performance monitoring
- Anomaly detection
- Alert generation
- Daily reports
- Emergency shutdown triggers

MÉTRICAS MONITORADAS:
- Real-time P&L
- DD vs limits
- Trade frequency
- Slippage analysis
- Model confidence drift
```

#### 5.2 Logging System
```cpp
// Enhanced logging

NÍVEIS:
- DEBUG: Every decision
- INFO: Every trade
- WARNING: Unusual conditions
- ERROR: Failures
- CRITICAL: Emergency stops

OUTPUT:
- logs/EA_SCALPER_YYYY-MM-DD.log
- Rotation: Daily
- Retention: 30 days
```

#### 5.3 Alert System
```
TRIGGERS:
- DD >= 3% → Telegram/Email warning
- DD >= 4% → Reduce size automatically
- DD >= 5% → STOP + Alert
- Model confidence < 0.5 → Skip trades
- Unusual spread → Pause

INTEGRAÇÃO:
- Telegram bot (opcional)
- Email via Python Hub
- MT5 Push notifications
```

#### 5.4 Graceful Degradation
```
CENÁRIOS E RESPOSTAS:

1. ONNX falha → Fallback para regras simples
2. Python Hub offline → EA opera standalone
3. Broker disconnect → Gerenciar posições existentes
4. High spread → Pausar novas entradas
5. News event → Aumentar SL buffer

CADA CENÁRIO:
- Documentado em DOCS/CONTINGENCY_PLAN.md
- Testado com simulation
```

### Deliverables Phase 5
- [ ] `.factory/skills/watchtower-monitor.md`
- [ ] `MQL5/Include/EA_SCALPER/Monitoring/` components
- [ ] `DOCS/CONTINGENCY_PLAN.md`
- [ ] `DOCS/ALERTING_SETUP.md`
- [ ] Alert system funcionando

### Success Criteria Phase 5
- [ ] Logs capturando tudo
- [ ] Alerts disparando corretamente
- [ ] Graceful degradation testada
- [ ] WATCHTOWER skill criada

---

## PHASE 6: PAPER TRADING (14-30 dias)

### Objetivo
Validar em condições reais sem risco.

### Tasks

#### 6.1 Setup Demo Account
```
BROKER: Mesmo que será usado em live
CONTA: Demo $100,000 (simular FTMO Challenge)
PERÍODO: Mínimo 2 semanas, ideal 4 semanas

CONFIGURAÇÃO:
- Same settings as planned live
- Full logging enabled
- WATCHTOWER active
```

#### 6.2 Daily Monitoring
```
CHECKLIST DIÁRIO:
□ Trades executados vs esperados
□ DD atual vs limits
□ Model predictions vs actual
□ Slippage analysis
□ Any anomalies

OUTPUT: Reports/PAPER_TRADING_DAILY/
```

#### 6.3 Weekly Analysis
```
MÉTRICAS SEMANAIS:
- Total trades
- Win rate
- Profit factor
- Sharpe (realized)
- DD max
- Comparison vs backtest

OUTPUT: Reports/PAPER_TRADING_WEEKLY/
```

#### 6.4 Final Assessment
```
APÓS 4 SEMANAS:

CRITERIOS PARA GO-LIVE:
□ Profit factor >= 1.3 (pode ser menor que backtest)
□ Max DD <= 8%
□ Win rate >= 50%
□ No critical bugs
□ All alerts worked correctly
□ Slippage within expectations

OUTPUT: Reports/PAPER_TRADING_FINAL.md
```

### Deliverables Phase 6
- [ ] `Reports/PAPER_TRADING_DAILY/` (daily logs)
- [ ] `Reports/PAPER_TRADING_WEEKLY/` (weekly analysis)
- [ ] `Reports/PAPER_TRADING_FINAL.md`

### Success Criteria Phase 6
- [ ] 4 semanas de paper trading completas
- [ ] Métricas dentro do esperado
- [ ] Sem bugs críticos
- [ ] Confiança para ir live

---

## TIMELINE CONSOLIDADO

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TIMELINE DE IMPLEMENTAÇÃO                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Semana 1:  ██████░░░░░░░░░░░░░░░░░░░░░░░░░░  Phase 0 + Phase 1           │
│  Semana 2:  ░░░░░░██████████░░░░░░░░░░░░░░░░  Phase 2                      │
│  Semana 3:  ░░░░░░░░░░░░░░░░████████░░░░░░░░  Phase 3 (start)             │
│  Semana 4:  ░░░░░░░░░░░░░░░░░░░░░░░░████████  Phase 3 (complete)          │
│  Semana 5:  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██████████  Phase 4           │
│  Semana 6:  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████  Phase 5       │
│  Semana 7+: ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████████    │
│             Phase 6 (Paper Trading - 2-4 weeks)                            │
│                                                                             │
│  TOTAL: 7-10 semanas até paper trading completo                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## CHECKPOINTS E GATES

### Gate 0→1: Audit Complete
- [ ] Todos os gaps identificados
- [ ] Prioridades definidas
- **DECISÃO**: Prosseguir ou refatorar estrutura existente

### Gate 1→2: Data Ready
- [ ] Dados limpos disponíveis
- [ ] Baseline estabelecido
- **DECISÃO**: Prosseguir ou melhorar data quality

### Gate 2→3: Validation Pass ⭐ CRÍTICO
- [ ] WFE >= 0.5
- [ ] GO/NO-GO = GO
- **DECISÃO**: SE NO-GO → PARAR E REVISAR ESTRATÉGIA

### Gate 3→4: Model Ready
- [ ] ONNX exportado e testado
- [ ] WFE do modelo >= 0.6
- **DECISÃO**: Prosseguir ou retreinar modelo

### Gate 4→5: EA Complete
- [ ] Todos os testes passam
- [ ] Backtest ML > Baseline
- **DECISÃO**: Prosseguir ou debugar

### Gate 5→6: Production Ready
- [ ] Monitoring funcionando
- [ ] Alerts testados
- **DECISÃO**: Iniciar paper trading

### Gate 6→Live: Paper Trading Success
- [ ] 4 semanas sem issues críticos
- [ ] Métricas dentro do esperado
- **DECISÃO**: GO LIVE ou estender paper trading

---

## COMO USAR ESTE PLANO

### Para Iniciar Nova Sessão

```
PROMPT PARA O AGENT:

"Estou executando o IMPLEMENTATION_PLAN_v1.md do EA_SCALPER_XAUUSD.

STATUS ATUAL: Phase [X], Task [Y]

ÚLTIMO DELIVERABLE: [descrever]

PRÓXIMO PASSO: [descrever]

Por favor, execute o próximo passo seguindo as especificações do plano."
```

### Tracking de Progresso

Manter atualizado:
```markdown
## PROGRESS TRACKER

| Phase | Status | Data Início | Data Fim | Notas |
|-------|--------|-------------|----------|-------|
| 0     | [ ]    |             |          |       |
| 1     | [ ]    |             |          |       |
| 2     | [ ]    |             |          |       |
| 3     | [ ]    |             |          |       |
| 4     | [ ]    |             |          |       |
| 5     | [ ]    |             |          |       |
| 6     | [ ]    |             |          |       |
```

---

## RISCOS E MITIGAÇÕES

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| WFA falha (WFE < 0.5) | Médio | CRÍTICO | Revisar estratégia antes de codar |
| Dados com baixa qualidade | Baixo | Alto | Validação rigorosa em Phase 1 |
| ONNX integration issues | Médio | Médio | Testar cedo, ter fallback |
| Model overfitting | Médio | Alto | WFA específico para ML |
| Paper trading diverge muito | Médio | Médio | Investigar causas, ajustar |

---

## REFERÊNCIAS

- **Agent Skills**: `.factory/skills/*.md`
- **PRD**: `DOCS/prd.md`
- **Party Mode Session**: `DOCS/PARTY_MODE/SESSION_001_2025-11-30.md`
- **AGENTS.md**: Routing e conhecimento
- **CLAUDE_REFERENCE.md**: Referência técnica

---

## APROVAÇÃO

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   PLANO APROVADO PARA EXECUÇÃO                               ║
║                                                               ║
║   Data: 2025-11-30                                           ║
║   Versão: 1.0                                                ║
║   Status: READY                                              ║
║                                                               ║
║   Próximo passo: Iniciar Phase 0 (AUDIT)                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

*"Validate first. Build second. Deploy third."*
