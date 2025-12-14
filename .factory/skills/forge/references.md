# References - FORGE v3.0

## Knowledge Embedding (NOVO v3.0)

| Arquivo | Proposito | Quando Consultar |
|---------|-----------|------------------|
| `knowledge/dependency_graph.md` | Grafo de dependencias do projeto | ANTES de modificar qualquer modulo |
| `knowledge/bug_patterns.md` | 12 bug patterns do BUGFIX_LOG | ANTES de modificar + CHECK 7 |
| `knowledge/project_patterns.md` | Convencoes do projeto | Ao criar codigo novo |

---

## MCPs Primarios

| MCP | Uso | Limite |
|-----|-----|--------|
| mql5-docs | Sintaxe MQL5, funcoes, exemplos | Ilimitado |
| mql5-books | Patterns, arquitetura, ML/ONNX | Ilimitado |
| github | Repos, code search, PRs | Normal |
| context7 | Docs de libs externas | Normal |
| e2b | Sandbox Python para testes | Free tier |
| code-reasoning | Debug step-by-step (OBRIGATORIO p/ bugs) | Ilimitado |
| sequential-thinking | Problemas complexos 5+ steps | Ilimitado |
| memory | Decisoes arquiteturais persistentes | Ilimitado |
| vega-lite | Diagramas, graficos performance | Ilimitado |

---

## RAG Queries Uteis

```bash
# Sintaxe MQL5 (usar mql5-docs)
mql5-docs "OrderSend" OR "CTrade" OR "CPositionInfo"
mql5-docs "CopyBuffer" OR "CopyRates" OR "iATR"
mql5-docs "OnnxCreate" OR "OnnxRun" OR "OnnxSetInputShape"

# Patterns de Design (usar mql5-books)
mql5-books "design pattern" OR "factory pattern" OR "strategy pattern"
mql5-books "error handling" OR "defensive programming"
mql5-books "memory management" OR "resource cleanup"

# ML/ONNX (usar mql5-books)
mql5-books "ONNX" OR "neural network" OR "machine learning MQL5"
mql5-books "feature engineering" OR "normalization" OR "StandardScaler"

# Performance
mql5-books "optimization" OR "performance" OR "latency"
mql5-docs "GetMicrosecondCount" OR "GetTickCount"
```

---

## Arquivos do Projeto (38 Modulos)

### Estrutura Principal
| Camada | Caminho | Modulos |
|--------|---------|---------|
| Analysis | `MQL5/Include/EA_SCALPER/Analysis/` | 17 modulos |
| Signal | `MQL5/Include/EA_SCALPER/Signal/` | 3 modulos |
| Risk | `MQL5/Include/EA_SCALPER/Risk/` | 2 modulos |
| Execution | `MQL5/Include/EA_SCALPER/Execution/` | 2 modulos |
| Bridge | `MQL5/Include/EA_SCALPER/Bridge/` | 5 modulos |
| Safety | `MQL5/Include/EA_SCALPER/Safety/` | 3 modulos |
| Context | `MQL5/Include/EA_SCALPER/Context/` | 3 modulos |
| Strategy | `MQL5/Include/EA_SCALPER/Strategy/` | 3 modulos |

### Arquivos Chave
| Arquivo | Caminho |
|---------|---------|
| EA Principal | `MQL5/Experts/EA_SCALPER_XAUUSD.mq5` |
| Arquitetura Index | `MQL5/Include/EA_SCALPER/INDEX.md` |
| Definitions | `MQL5/Include/EA_SCALPER/Core/Definitions.mqh` |
| ONNX Brain | `MQL5/Include/EA_SCALPER/Bridge/COnnxBrain.mqh` |
| FTMO Risk | `MQL5/Include/EA_SCALPER/Risk/FTMO_RiskManager.mqh` |
| Python Bridge | `MQL5/Include/EA_SCALPER/Bridge/PythonBridge.mqh` |

### Python Agent Hub
```
Python_Agent_Hub/
├── app/main.py                  # FastAPI app
├── app/routers/                 # API endpoints
├── app/services/                # Business logic
└── ml_pipeline/                 # Training, ONNX export
```

---

## Handoffs

| Para | Quando | Exemplo |
|------|--------|---------|
| CRUCIBLE | Questoes de estrategia | "setup", "SMC", "order flow" |
| SENTINEL | Calcular risco | "lot size", "Kelly", "DD" |
| ORACLE | Validar codigo | "backtest", "WFA", "Monte Carlo" |
| ARGUS | Pesquisa profunda | "papers", "repos", "best practices" |

---

## Anti-Patterns Completos (20)

| ID | Nome | Risco | Fix Rapido |
|----|------|-------|------------|
| AP-01 | OrderSend sem check | CRITICO | Verificar retcode |
| AP-02 | CopyBuffer sem Series | CRITICO | ArraySetAsSeries |
| AP-03 | Lot sem normalize | ALTO | NormalizeLot() |
| AP-04 | Divisao sem zero check | CRITICO | Guard clause |
| AP-05 | Array sem bounds | CRITICO | Check ArraySize |
| AP-06 | Indicador nao liberado | MEDIO | IndicatorRelease |
| AP-07 | Objeto nao deletado | MEDIO | delete + NULL |
| AP-08 | String em hot path | ALTO | Cache ou reduzir |
| AP-09 | Magic duplicado | ALTO | Input unico |
| AP-10 | Timer muito frequente | MEDIO | >= 1 segundo |
| AP-11 | Print flooding | MEDIO | Rate limit |
| AP-12 | Global object init | ALTO | Init em OnInit |
| AP-13 | Static sem reset | ALTO | Daily reset |
| AP-14 | DD com Balance | CRITICO | Usar Equity |
| AP-15 | Spread ignorado | ALTO | Max spread check |
| AP-16 | Weekend sem gestao | ALTO | Fechar sexta |
| AP-17 | News nao filtrada | ALTO | Calendario check |
| AP-18 | Retry infinito | ALTO | Max 3 retries |
| AP-19 | Timeout sem fallback | ALTO | Fallback MQL5-only |
| AP-20 | Feature order ONNX | CRITICO | Ordem = Python |

---

## Emergency Protocols

### /emergency stop - EA parou
1. MT5 conectado? Auto Trading ON?
2. Verificar Experts tab (erros)
3. Filtros: Sessao? News? Regime? DD?
4. Sinais: Score? MTF? Spread?

### /emergency crash
1. Journal: "critical error"?
2. Posicoes abertas? Gerenciar manual
3. Remover EA, reiniciar MT5
4. Re-anexar com defaults

### /emergency dd - Drawdown alto
```
DD 4%: ALERTA - Parar novas entradas
DD 6%: CRITICO - Considerar fechar
DD 8%: EMERGENCIA - Fechar TUDO
```

### /emergency live - Go-live checklist
1. Backtest tick data: PF > 1.5?
2. Forward test demo: 2+ semanas OK?
3. Monte Carlo: 95% lucrativo?
4. Walk-Forward: WFE > 0.6?

---

## Naming Conventions

```mql5
// Classes: CPascalCase
class COrderBlockDetector { };

// Metodos: PascalCase()
bool Initialize();
double CalculateScore();

// Variaveis: camelCase
double currentPrice;
bool isValid;

// Constantes: UPPER_SNAKE_CASE
#define MAX_SLIPPAGE 30
const double FTMO_DAILY_DD = 5.0;

// Membros: m_prefix
double m_stopLoss;
int m_magicNumber;

// Globais: g_prefix
double g_dailyStartEquity;
```

---

## ONDE SALVAR OUTPUTS

| Tipo | Pasta |
|------|-------|
| Code audits | `DOCS/02_IMPLEMENTATION/PHASES/PHASE_0_AUDIT/` |
| Phase deliverables | `DOCS/02_IMPLEMENTATION/PHASES/PHASE_N/` |
| Setup guides | `DOCS/05_GUIDES/SETUP/` |
| Usage guides | `DOCS/05_GUIDES/USAGE/` |
| Progress | `DOCS/02_IMPLEMENTATION/PROGRESS.md` |
