# References - CRUCIBLE v3.0

## EA Modules (O Que o Robo Ja Calcula)

| Modulo | Caminho | O Que Faz |
|--------|---------|-----------|
| **CRegimeDetector** | `Analysis/CRegimeDetector.mqh` | Hurst + Entropy + Classificacao |
| **CMTFManager** | `Analysis/CMTFManager.mqh` | H1/M15/M5 alignment + confluence |
| **CFootprintAnalyzer** | `Analysis/CFootprintAnalyzer.mqh` | Delta, Imbalance, POC, VAH/VAL |
| **EliteOrderBlock** | `Analysis/EliteOrderBlock.mqh` | OB detection + quality score |
| **EliteFVG** | `Analysis/EliteFVG.mqh` | FVG detection + fill tracking |
| **CLiquiditySweepDetector** | `Analysis/CLiquiditySweepDetector.mqh` | BSL/SSL + Equal H/L |
| **CAMDCycleTracker** | `Analysis/CAMDCycleTracker.mqh` | AMD phase detection |
| **CStructureAnalyzer** | `Analysis/CStructureAnalyzer.mqh` | BOS/CHoCH/Swing Points |
| **CSessionFilter** | `Analysis/CSessionFilter.mqh` | Session validation |
| **CNewsFilter** | `Analysis/CNewsFilter.mqh` | News blocking |
| **FTMO_RiskManager** | `Risk/FTMO_RiskManager.mqh` | DD tracking, circuit breaker |
| **COnnxBrain** | `Bridge/COnnxBrain.mqh` | ML direction (P>0.65) |

**DOCUMENTACAO COMPLETA**: `MQL5/Include/EA_SCALPER/INDEX.md` (2000 linhas)

---

## MCPs Primarios (Para o Que o EA NAO Faz)

| MCP | Uso | Limite |
|-----|-----|--------|
| perplexity | DXY, COT, central banks, macro | Normal |
| brave-search | Noticias, eventos, backup | Normal |
| mql5-books | SMC, Order Flow, teoria trading | Ilimitado |
| mql5-docs | Sintaxe MQL5, funcoes | Ilimitado |
| time | Sessoes, fusos horarios | Ilimitado |
| memory | Contexto persistente | Ilimitado |
| calculator | Risk/reward, position sizing | Ilimitado |
| sequential-thinking | Analise complexa (5+ steps) | Ilimitado |

---

## Data Queries Templates

### DXY (Dollar Index)
```
TOOL: perplexity-search
QUERY: "DXY dollar index current price today live"
INTERPRETACAO:
  - Subindo = pressao no ouro (correlacao -0.70)
  - Caindo = suporte para ouro
  - Estavel = neutro
```

### Gold/Silver Ratio
```
TOOL: perplexity-search
QUERY: "gold silver ratio today current value"
INTERPRETACAO:
  - > 80 = ouro "caro" vs prata
  - 66 = media historica
  - Extremos = reversao possivel
```

### COT Report
```
TOOL: perplexity-search
QUERY: "CFTC COT report gold futures latest speculative positions"
INTERPRETACAO:
  - Extreme long = possivel topo
  - Extreme short = possivel fundo
```

### Real Yields
```
TOOL: perplexity-search
QUERY: "US 10 year real yield TIPS current"
INTERPRETACAO:
  - Negativo = bullish para ouro
  - Positivo alto = bearish para ouro
```

### Economic Calendar
```
TOOL: perplexity-search
QUERY: "forex economic calendar today high impact USD events"
INTERPRETACAO:
  - RED (HIGH) = evitar 30min antes/depois
  - ORANGE (MEDIUM) = cautela
```

---

## RAG Queries Uteis

```bash
# SMC Patterns
mql5-books "order block" OR "breaker block" OR "mitigation"

# Fair Value Gaps
mql5-books "fair value gap" OR "FVG" OR "imbalance zone"

# Liquidity
mql5-books "liquidity sweep" OR "stop hunt" OR "BSL" OR "SSL"

# Sessoes
mql5-books "asian session" OR "london session" OR "new york session"

# Correlacoes Gold
mql5-books "DXY" OR "US10Y" OR "gold correlation" OR "real yields"

# Order Flow
mql5-books "footprint" OR "delta" OR "POC" OR "value area"

# Regime Detection
mql5-books "hurst exponent" OR "shannon entropy" OR "regime"

# Sintaxe MQL5 (usar mql5-docs)
mql5-docs "CopyRates" OR "OrderSend" OR "SymbolInfoDouble"
```

---

## Handoffs

| Para | Quando | Exemplo de Trigger |
|------|--------|-------------------|
| SENTINEL | Calcular risco/lot | "verificar risco", "calcular lot", "position size" |
| SENTINEL | Verificar DD/compliance | "FTMO status", "DD atual" |
| ORACLE | Validar backtest | "validar estatisticamente", "WFA", "Monte Carlo" |
| ORACLE | GO/NO-GO decision | "aprovar estrategia", "go-nogo" |
| FORGE | Implementar codigo | "implementar", "codar", "criar modulo" |
| ARGUS | Pesquisa profunda | "pesquisar", "encontrar papers" |

---

## Arquivos do Projeto (Quick Reference)

| Area | Caminho |
|------|---------|
| EA Principal | `MQL5/Experts/EA_SCALPER_XAUUSD.mq5` |
| CMTFManager | `MQL5/Include/EA_SCALPER/Analysis/CMTFManager.mqh` |
| CRegimeDetector | `MQL5/Include/EA_SCALPER/Analysis/CRegimeDetector.mqh` |
| CFootprintAnalyzer | `MQL5/Include/EA_SCALPER/Analysis/CFootprintAnalyzer.mqh` |
| EliteOrderBlock | `MQL5/Include/EA_SCALPER/Analysis/EliteOrderBlock.mqh` |
| EliteFVG | `MQL5/Include/EA_SCALPER/Analysis/EliteFVG.mqh` |
| FTMO_RiskManager | `MQL5/Include/EA_SCALPER/Risk/FTMO_RiskManager.mqh` |
| Arquitetura Index | `MQL5/Include/EA_SCALPER/INDEX.md` |

---

## Quantification Reference

### Correlacoes
| Termo | Quantificacao |
|-------|---------------|
| DXY caindo | change < -0.3%/dia |
| DXY subindo | change > +0.3%/dia |
| Correlacao forte | \|r\| > 0.70 |

### Spread
| Termo | Quantificacao |
|-------|---------------|
| Aceitavel | <= 25 pontos |
| Bom | <= 18 pontos |
| Alto | > 30 pontos |
| Perigoso | > 45 pontos |

### Sessoes (GMT)
| Sessao | Horario | Qualidade |
|--------|---------|-----------|
| Asia | 22:00-07:00 | EVITAR |
| London | 08:00-12:00 | BOA |
| NY Open | 12:30-14:00 | BOA |
| Overlap | 12:00-16:00 | IDEAL |

### Regimes
| Termo | Hurst | Entropy | Size |
|-------|-------|---------|------|
| Prime Trending | > 0.65 | < 2.0 | 100% |
| Noisy Trending | 0.55-0.65 | any | 75% |
| Mean Reverting | 0.45-0.55 | < 2.5 | 50% |
| Random Walk | < 0.45 | > 2.5 | 0% |

---

## ONDE SALVAR OUTPUTS

| Tipo | Pasta |
|------|-------|
| Strategy findings | `DOCS/03_RESEARCH/FINDINGS/` |
| Market analysis | `DOCS/03_RESEARCH/FINDINGS/` |
| Progress updates | `DOCS/02_IMPLEMENTATION/PROGRESS.md` |

---

## 60 Fundamentos de Trading XAUUSD

### Macro (8)
| # | Fato | Dado |
|---|------|------|
| 1 | Correlacao DXY | **-0.70** |
| 2 | Correlacao Real Yields | **-0.55 a -0.82** |
| 3 | Oil Feature Importance | **42%** |
| 4 | Correlacao VIX | **+0.40** |
| 5 | Central Banks Compra | **1000+ tonnes/ano** |
| 6 | Central Bank Share | **25%** da demanda |
| 7 | ETF Inflows | Recordes 2024-2025 |
| 8 | Volatilidade | Move RAPIDO |

### Sessoes (6)
| # | Fato | Dado |
|---|------|------|
| 9 | Asia vs Overlap | **260x** mais movimentos |
| 10 | Melhor Horario | **12:00-16:00 GMT** |
| 11 | Pior Horario | **22:00-00:00 GMT** |
| 12 | 8AM NY | Fortes movimentos |
| 13 | 15:00 GMT | London Fix |
| 14 | Asia | Acumulacao, evitar |

### Order Flow (7)
| # | Conceito | Uso |
|---|----------|-----|
| 15 | POC | Maior volume |
| 16 | Value Area | 70% do volume |
| 17 | VAH/VAL | Topo/Fundo VA |
| 18 | Delta | Compras - Vendas |
| 19 | Imbalance | Delta extremo |
| 20 | Absorpcao | Volume sem movimento |
| 21 | Footprint | Realidade do mercado |

### Smart Money Concepts (7)
| # | Conceito | Aplicacao |
|---|----------|-----------|
| 22 | Liquidity Sweep | Quebra, pega stops, reverte |
| 23 | BSL/SSL | Buy/Sell Side Liquidity |
| 24 | Order Blocks | Zonas institucionais |
| 25 | FVG | Gaps que preenchem |
| 26 | BOS/CHoCH | Estrutura/Reversao |
| 27 | AMD | Accumulation→Manipulation→Distribution |
| 28 | Equal Highs/Lows | Imas de liquidez |

### Regime Detection (6)
| # | Metrica | Interpretacao |
|---|---------|---------------|
| 29 | Hurst > 0.55 | TRENDING |
| 30 | Hurst < 0.45 | REVERTING |
| 31 | Hurst ~ 0.50 | RANDOM - NAO OPERAR |
| 32 | Entropy < 1.5 | Full size |
| 33 | Entropy 1.5-2.5 | Half size |
| 34 | Entropy > 2.5 | NAO operar |

### Erros Fatais (8)
| # | Erro | Consequencia |
|---|------|--------------|
| 35 | Ignorar DXY | -0.70 perdida |
| 36 | Operar Asia | 260x menos oportunidades |
| 37 | Ignorar News | Moves de $20-40 |
| 38 | Over-leverage | Ouro move rapido |
| 39 | Contra H1 | Contra macro |
| 40 | Random Walk | Sem edge |
| 41 | Impulso | Sem analise |
| 42 | Lote errado | Risco descontrolado |

### Avancado (4)
| # | Indicador | Uso |
|---|-----------|-----|
| 43 | Gold-Silver Ratio | 92:1 vs 66:1 media |
| 44 | COT Reports | Extremos = reversao |
| 45 | GOFO/Lease Rates | Negativo = escassez |
| 46 | Gamma Exposure | Opcoes movem spot |

### Position Sizing (3)
| # | Conceito | Regra |
|---|----------|-------|
| 47 | Kelly Criterion | (bp - q) / b |
| 48 | Fractional Kelly | 25% do Kelly |
| 49 | Risco por Trade | Max 1%, ideal 0.5% |

### Mental Models (4)
| # | Modelo | Aplicacao |
|---|--------|-----------|
| 50 | Reflexivity | Feedback loops |
| 51 | Second-Order | "E depois?" |
| 52 | Fractal Markets | Mesmos padroes |
| 53 | Adverse Selection | Por que executou? |

### Sazonalidade (4)
| # | Periodo | Forca |
|---|---------|-------|
| 54 | Janeiro | +5% |
| 55 | Ago-Set | +3% |
| 56 | Mai-Jun | Fraco |
| 57 | Dezembro | Forte |

### Microestrutura (3)
| # | Conceito | Implicacao |
|---|----------|------------|
| 58 | Spread Components | 3 partes |
| 59 | Information Leakage | Slippage alto |
| 60 | Execution Quality | Monitorar |
