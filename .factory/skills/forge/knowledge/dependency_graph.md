# FORGE Knowledge: Dependency Graph

## EA Principal Dependencies

```
EA_SCALPER_XAUUSD.mq5
│
├─► Core/Definitions.mqh (TODOS dependem deste)
│   └── Enums: ENUM_SIGNAL_TYPE, ENUM_MTF_TREND, ENUM_REGIME_TYPE, etc.
│   └── Structs: STradeSignal, SConfluenceScore, etc.
│
├─► Risk/FTMO_RiskManager.mqh
│   ├── Definitions.mqh
│   └── Usado por: EA principal, CTradeManager
│
├─► Execution/CTradeManager.mqh
│   ├── Execution/TradeExecutor.mqh
│   ├── Risk/FTMO_RiskManager.mqh
│   └── Usado por: EA principal
│
├─► Signal/CConfluenceScorer.mqh
│   ├── Analysis/*.mqh (TODOS os 17 modulos)
│   ├── Definitions.mqh
│   └── Usado por: EA principal
│
├─► Bridge/COnnxBrain.mqh
│   ├── Models/direction_model.onnx
│   └── Usado por: EA principal
│
└─► Analysis/ (17 modulos)
    ├── CMTFManager.mqh (coordena MTF)
    │   ├── Definitions.mqh
    │   └── Usa: EliteOrderBlock, EliteFVG, CStructureAnalyzer
    │
    ├── CStructureAnalyzer.mqh (BOS/CHoCH)
    │   └── Definitions.mqh
    │
    ├── EliteOrderBlock.mqh (OB detector)
    │   └── Definitions.mqh
    │
    ├── EliteFVG.mqh (FVG detector)
    │   └── Definitions.mqh
    │
    ├── CLiquiditySweepDetector.mqh
    │   └── Definitions.mqh
    │
    ├── CRegimeDetector.mqh (Hurst/Entropy)
    │   └── Definitions.mqh
    │
    ├── CAMDCycleTracker.mqh
    │   └── Definitions.mqh
    │
    ├── CSessionFilter.mqh
    │   └── Definitions.mqh
    │
    ├── CNewsFilter.mqh
    │   └── Definitions.mqh
    │
    ├── CFootprintAnalyzer.mqh (Order Flow)
    │   └── Definitions.mqh
    │
    └── CEntryOptimizer.mqh
        └── Definitions.mqh
```

## Grafo Visual Simplificado

```
                    ┌─────────────────────┐
                    │ EA_SCALPER_XAUUSD   │
                    └─────────┬───────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌─────────────────┐
│FTMO_RiskMgr   │   │CTradeManager    │   │CConfluenceScorer│
└───────┬───────┘   └────────┬────────┘   └────────┬────────┘
        │                    │                     │
        │           ┌────────┴────────┐            │
        │           │                 │            │
        │           ▼                 ▼            │
        │   ┌──────────────┐  ┌──────────────┐    │
        │   │TradeExecutor │  │FTMO_RiskMgr  │    │
        │   └──────────────┘  └──────────────┘    │
        │                                          │
        │                                          │
        ▼                                          ▼
┌───────────────────────────────────────────────────────────┐
│                    Definitions.mqh                        │
│  (BASE - todos os modulos dependem deste!)               │
└───────────────────────────────────────────────────────────┘
        ▲
        │
┌───────┴───────────────────────────────────────────────────┐
│                   Analysis/ (17 modulos)                  │
├───────────────────────────────────────────────────────────┤
│ CMTFManager ────────► EliteOrderBlock                    │
│      │                EliteFVG                           │
│      │                CStructureAnalyzer                 │
│      │                                                   │
│ CFootprintAnalyzer (independente)                        │
│ CRegimeDetector (independente)                           │
│ CAMDCycleTracker (independente)                          │
│ CLiquiditySweepDetector (independente)                   │
│ CSessionFilter (independente)                            │
│ CNewsFilter (independente)                               │
│ CEntryOptimizer (independente)                           │
└───────────────────────────────────────────────────────────┘
```

## Modulos Criticos (Modificar com CUIDADO)

| Modulo | Criticidade | Motivo |
|--------|-------------|--------|
| **Definitions.mqh** | ⚠️ MAXIMA | TODOS dependem deste. Mudanca aqui = recompile TUDO |
| **FTMO_RiskManager.mqh** | ⚠️ MAXIMA | Violacao = conta FTMO terminada |
| **CTradeManager.mqh** | ⚠️ ALTA | Gerencia posicoes abertas |
| **TradeExecutor.mqh** | ⚠️ ALTA | Executa ordens reais |
| **CConfluenceScorer.mqh** | ⚠️ MEDIA | Agrega sinais de 17 modulos |

## Modulos Independentes (Modificar com SEGURANCA)

| Modulo | Dependentes | Impacto de Mudanca |
|--------|-------------|-------------------|
| CFootprintAnalyzer | Nenhum direto | Baixo |
| CRegimeDetector | CConfluenceScorer | Medio |
| CSessionFilter | CConfluenceScorer | Baixo |
| CNewsFilter | CConfluenceScorer | Baixo |
| CAMDCycleTracker | CConfluenceScorer | Medio |

## Fluxo de Dados

```
ENTRADA (Tick)
     │
     ▼
┌─────────────────────────────────────────────────────────┐
│ 1. Filtros (Session, News, Regime)                     │
│    └── Podem BLOQUEAR fluxo                            │
├─────────────────────────────────────────────────────────┤
│ 2. Analise MTF (H1 → M15 → M5)                         │
│    └── CMTFManager coordena                            │
├─────────────────────────────────────────────────────────┤
│ 3. Deteccao de Estruturas                              │
│    └── OB, FVG, Sweep, BOS/CHoCH                       │
├─────────────────────────────────────────────────────────┤
│ 4. Score de Confluencia                                │
│    └── CConfluenceScorer agrega tudo                   │
├─────────────────────────────────────────────────────────┤
│ 5. Validacao ONNX (opcional)                           │
│    └── COnnxBrain confirma direcao                     │
├─────────────────────────────────────────────────────────┤
│ 6. Risk Check                                          │
│    └── FTMO_RiskManager valida DD                      │
├─────────────────────────────────────────────────────────┤
│ 7. Execucao                                            │
│    └── CTradeManager → TradeExecutor                   │
└─────────────────────────────────────────────────────────┘
     │
     ▼
SAIDA (Trade ou BLOCK)
```

## Regras de Modificacao

### ANTES de modificar qualquer modulo:

1. **Grep por usos**: `rg "CModuloNome" MQL5/`
2. **Verificar dependencias upstream**: Quem inclui este modulo?
3. **Verificar dependencias downstream**: Este modulo inclui quem?
4. **Consultar BUGFIX_LOG**: Ja houve bugs neste modulo?
5. **Testar compilacao**: Compilar EA principal apos mudanca

### Arquivos que SEMPRE precisam recompilar o EA:

- Definitions.mqh
- FTMO_RiskManager.mqh
- CTradeManager.mqh
- TradeExecutor.mqh
- CConfluenceScorer.mqh
- EA_SCALPER_XAUUSD.mq5
