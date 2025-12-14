# EA_SCALPER_XAUUSD v4.0 - Multi-Strategy News Trading
## Especificação Técnica Completa

**Versão**: 1.0
**Data**: 2024-11-29
**Autor**: Singularity Architect + Franco

---

## 1. Visão Geral

### 1.1 Objetivo

Evoluir o EA de um scalper técnico puro para um **sistema multi-estratégia adaptativo** que:
- Opera a FAVOR das notícias (não apenas evita)
- Adapta estratégia ao contexto de mercado
- Funciona no backtest com dados históricos de notícias
- Mantém compliance FTMO com modo safe

### 1.2 Filosofia de Design

```
"ASSUME O PIOR, PREPARE-SE PARA O PIOR, LUCRE QUANDO DER CERTO"

- Backtest deve ser MAIS DIFÍCIL que live (slippage, spread simulados)
- Se lucra no backtest pessimista, lucra no live
- Defesa em camadas: nunca depender de uma única proteção
```

### 1.3 Evolução de Versões

| Versão | Nome | Foco |
|--------|------|------|
| v3.20 | Singularity MTF | Multi-timeframe + SMC |
| v3.21 | Fundamentals | FRED, Oil, FinBERT |
| **v4.0** | **Adaptive Multi-Strategy** | **News Trading + Strategy Selector** |

---

## 2. Arquitetura de 5 Camadas

### 2.1 Diagrama Completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                    EA_SCALPER_XAUUSD v4.0                           │
│                 DEFENSIVE MULTI-STRATEGY ARCHITECTURE               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ╔═══════════════════════════════════════════════════════════════╗ │
│  ║ LAYER 1: SAFETY FIRST (Sempre Ativo)                          ║ │
│  ║ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ ║ │
│  ║ │ Circuit     │ │ Spread      │ │ MaxLoss     │ │ Emergency │ ║ │
│  ║ │ Breaker     │ │ Monitor     │ │ PerTrade    │ │ Close     │ ║ │
│  ║ │ DD>4%=STOP  │ │ 5x=BLOCK    │ │ 1% max      │ │ All       │ ║ │
│  ║ └─────────────┘ └─────────────┘ └─────────────┘ └───────────┘ ║ │
│  ╚═══════════════════════════════════════════════════════════════╝ │
│                              │                                      │
│                              ▼                                      │
│  ╔═══════════════════════════════════════════════════════════════╗ │
│  ║ LAYER 2: CONTEXT DETECTOR                                     ║ │
│  ║ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ ║ │
│  ║ │ News        │ │ Regime      │ │ Session     │ │ Holiday   │ ║ │
│  ║ │ Window      │ │ Detector    │ │ Detector    │ │ Detector  │ ║ │
│  ║ │ ±30min HIGH │ │ Hurst/Ent   │ │ Asia/Lon/NY │ │ US/UK     │ ║ │
│  ║ └─────────────┘ └─────────────┘ └─────────────┘ └───────────┘ ║ │
│  ╚═══════════════════════════════════════════════════════════════╝ │
│                              │                                      │
│                              ▼                                      │
│  ╔═══════════════════════════════════════════════════════════════╗ │
│  ║ LAYER 3: STRATEGY SELECTOR                                    ║ │
│  ║                                                               ║ │
│  ║   CONTEXTO                    ESTRATÉGIA                      ║ │
│  ║   ────────                    ──────────                      ║ │
│  ║   news_window + high_conf  →  NewsTrader (Direction)         ║ │
│  ║   news_window + low_conf   →  NewsTrader (Straddle)          ║ │
│  ║   news_window + FTMO_mode  →  NoTrade (Avoid)                ║ │
│  ║   trending (H>0.55)        →  TrendFollower                  ║ │
│  ║   ranging (H~0.5)          →  MeanReversion                  ║ │
│  ║   DEFAULT                  →  SMCScalper (atual)             ║ │
│  ║                                                               ║ │
│  ╚═══════════════════════════════════════════════════════════════╝ │
│                              │                                      │
│                              ▼                                      │
│  ╔═══════════════════════════════════════════════════════════════╗ │
│  ║ LAYER 4: STRATEGY EXECUTION                                   ║ │
│  ║ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ ║ │
│  ║ │ News        │ │ SMC         │ │ Trend       │ │ Mean      │ ║ │
│  ║ │ Trader      │ │ Scalper     │ │ Follower    │ │ Reversion │ ║ │
│  ║ │ Pre/Pull/   │ │ OB/FVG/     │ │ Breakout    │ │ Fade      │ ║ │
│  ║ │ Straddle    │ │ Sweep       │ │ Momentum    │ │ Extremes  │ ║ │
│  ║ └─────────────┘ └─────────────┘ └─────────────┘ └───────────┘ ║ │
│  ╚═══════════════════════════════════════════════════════════════╝ │
│                              │                                      │
│                              ▼                                      │
│  ╔═══════════════════════════════════════════════════════════════╗ │
│  ║ LAYER 5: BACKTEST REALISM (Apenas em Backtest)                ║ │
│  ║ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ ║ │
│  ║ │ Slippage    │ │ Spread      │ │ Latency     │ │ Reject    │ ║ │
│  ║ │ Simulator   │ │ Simulator   │ │ Simulator   │ │ Simulator │ ║ │
│  ║ │ +10-50 pips │ │ 5x normal   │ │ +500ms      │ │ 20% fail  │ ║ │
│  ║ └─────────────┘ └─────────────┘ └─────────────┘ └───────────┘ ║ │
│  ╚═══════════════════════════════════════════════════════════════╝ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Descrição de Cada Camada

#### Layer 1: Safety First
- **Sempre ativo**, independente da estratégia
- Protege contra catástrofes
- Não pode ser desligado

#### Layer 2: Context Detector
- Analisa o estado atual do mercado
- Determina qual contexto estamos
- Alimenta o Strategy Selector

#### Layer 3: Strategy Selector
- Decide qual estratégia usar
- Baseado no contexto detectado
- Hierarquia de prioridades clara

#### Layer 4: Strategy Execution
- Executa a estratégia selecionada
- Cada estratégia é um módulo isolado
- Interfaces padronizadas

#### Layer 5: Backtest Realism
- Ativo apenas em backtest
- Adiciona dificuldades artificiais
- Garante robustez

---

## 3. Problemas Antecipados (37 Riscos)

### 3.1 Riscos de Execução

| # | Problema | Probabilidade | Impacto | Solução Implementada |
|---|----------|---------------|---------|----------------------|
| 1 | Slippage extremo (50+ pips) | Alta | Crítico | Limit orders, SlippageSimulator |
| 2 | Broker manipulation | Média | Alto | Testar broker, fallback |
| 3 | Whipsaw (stop 2x) | Alta | Alto | Pullback entry, não spike |
| 4 | Spread 10x normal | Alta | Médio | SpreadSimulator, aceitar custo |
| 5 | Requotes infinitos | Média | Médio | Pending orders |

### 3.2 Riscos de Timing

| # | Problema | Probabilidade | Impacto | Solução Implementada |
|---|----------|---------------|---------|----------------------|
| 6 | API delay 1-15s | Alta | Alto | Pré-posicionar, cache |
| 7 | Python Hub lento | Baixa | Médio | Carregar no init, cache |
| 8 | Evento ±2min do horário | Média | Médio | Buffer ±5 minutos |
| 9 | Múltiplos eventos | Baixa | Alto | Detectar clustering |
| 10 | Evento cancelado | Baixa | Médio | Verificar status |

### 3.3 Riscos de Estratégia

| # | Problema | Probabilidade | Impacto | Solução Implementada |
|---|----------|---------------|---------|----------------------|
| 11 | Overfitting | Alta | Crítico | Regras genéricas, WFA |
| 12 | Correlação quebrada | Média | Alto | Usar magnitude, não direção |
| 13 | Conflito estratégias | Média | Médio | Hierarquia clara |
| 14 | Switch mid-trade | Alta | Baixo | Trade mantém estratégia |
| 15 | 70% spikes revertem | Alta | Alto | Pullback entry |

### 3.4 Riscos de Dados/Backtest

| # | Problema | Probabilidade | Impacto | Solução Implementada |
|---|----------|---------------|---------|----------------------|
| 16 | Survivorship bias | Média | Alto | Fonte completa (FF) |
| 17 | Look-ahead bias | Alta | Crítico | Só forecast, não actual |
| 18 | Regime changes | Alta | Alto | Regime-aware params |
| 19 | Sem spread histórico | Alta | Médio | Simular 5x |
| 20 | Bar data perde spikes | Alta | Alto | Worst-case assumption |

### 3.5 Riscos de Risk Management

| # | Problema | Probabilidade | Impacto | Solução Implementada |
|---|----------|---------------|---------|----------------------|
| 21 | 1% + 300 pip spike | Média | Crítico | 0.25% durante news |
| 22 | Losses correlacionados | Média | Alto | Max 1 news/dia |
| 23 | Gap weekend | Baixa | Alto | Fechar sexta 14:00 |
| 24 | FTMO rules | Alta | Crítico | Modo FTMO Safe |
| 25 | 3 losses = 5% DD | Média | Alto | Circuit breaker |
| 26 | Revenge trading | Média | Alto | Cooldown 2-4h |

### 3.6 Riscos Técnicos

| # | Problema | Probabilidade | Impacto | Solução Implementada |
|---|----------|---------------|---------|----------------------|
| 27 | Complexidade bugs | Alta | Alto | Módulos isolados, testes |
| 28 | EA reinicia | Média | Médio | Persistência estado |
| 29 | Timezone confusion | Alta | Alto | Tudo em UTC |
| 30 | API rate limits | Média | Médio | Cache 1x/hora |
| 31 | Memory leaks | Baixa | Médio | Limpar eventos >24h |

### 3.7 Riscos de Mercado

| # | Problema | Probabilidade | Impacto | Solução Implementada |
|---|----------|---------------|---------|----------------------|
| 32 | Flash crash | Baixa | Crítico | Hard stop sempre |
| 33 | Liquidity vacuum | Alta | Alto | Guaranteed stops |
| 34 | Fake news | Baixa | Médio | Só eventos oficiais |
| 35 | Surprise intervention | Baixa | Crítico | Max DD geral |
| 36 | Feriados | Média | Médio | Holiday detector |
| 37 | Divergência correlação | Média | Médio | Detectar, cautela |

---

## 4. News Trading Strategy

### 4.1 Tipos de Eventos e Impacto no Gold

| Evento | Impacto | Movimento Típico | Frequência |
|--------|---------|------------------|------------|
| **Fed Decision** | CRÍTICO | 100-300 pips | 8x/ano |
| **NFP** | ALTO | 50-150 pips | 12x/ano |
| **CPI** | ALTO | 30-100 pips | 12x/ano |
| **PPI** | MÉDIO | 20-50 pips | 12x/ano |
| **Jobless Claims** | MÉDIO | 15-40 pips | 52x/ano |
| **GDP** | MÉDIO | 20-60 pips | 4x/ano |
| **Retail Sales** | MÉDIO | 15-40 pips | 12x/ano |
| **ISM** | MÉDIO | 20-50 pips | 12x/ano |

### 4.2 Três Modos de News Trading

#### Modo 1: PRE-POSITION (Direção Clara)

**Quando usar**: Quando consenso é forte e fundamentals apontam direção

```
EXEMPLO: Fed Meeting com expectativa HAWKISH
- Mercado espera rate hike
- Gold deve CAIR

ENTRY:
- 5-10 min ANTES do evento
- SELL com limit order
- Tamanho: 0.25% risk

STOP:
- ATR(14) * 2 acima da entrada
- Aceita spike inicial

TARGET:
- ATR(14) * 4
- Ou trailing após spike

EDGE:
- Entra antes do movimento
- Melhor preço
- Risco: evento surprise
```

#### Modo 2: PULLBACK (Após Spike)

**Quando usar**: Após spike inicial, esperar reversão parcial

```
EXEMPLO: NFP melhor que esperado
- Spike inicial DOWN 80 pips
- Pullback UP 30 pips (38% retrace)

ENTRY:
- 30-60 segundos APÓS o spike
- Esperar pullback de 30-50%
- Entrar na direção do spike original

STOP:
- Abaixo/acima do pullback
- Mais apertado que pre-position

TARGET:
- Re-teste do spike low/high
- Ou extensão 127%

EDGE:
- Confirmação de direção
- Melhor R:R
- Risco: reversão completa
```

#### Modo 3: STRADDLE (Direção Incerta)

**Quando usar**: Quando movimento é garantido mas direção não

```
EXEMPLO: CPI muito aguardado
- Expectativa incerta
- Volatilidade garantida

ENTRY:
- 2 pending orders
- BUY STOP acima do range
- SELL STOP abaixo do range
- Distance: ATR * 1.5

STOP:
- Opposite side + buffer
- Ou ATR * 1.5

TARGET:
- ATR * 3
- Trailing após 50% do target

EDGE:
- Pega movimento qualquer direção
- Risco: whipsaw (stop 2x)

PROTEÇÃO:
- OCO (One Cancels Other)
- Se um ativa, cancela o outro
```

### 4.3 Fluxo de Decisão News Trading

```
                    ┌─────────────────┐
                    │ Evento em       │
                    │ 30 minutos?     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ É HIGH impact?  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         ┌────▼────┐   ┌─────▼─────┐  ┌─────▼─────┐
         │ FTMO    │   │ Direção   │  │ Direção   │
         │ Mode?   │   │ Clara?    │  │ Incerta   │
         └────┬────┘   └─────┬─────┘  └─────┬─────┘
              │              │              │
         ┌────▼────┐   ┌─────▼─────┐  ┌─────▼─────┐
         │ AVOID   │   │ PRE-POS   │  │ STRADDLE  │
         │ (NoTrade)│   │ ou        │  │ ou        │
         └─────────┘   │ PULLBACK  │  │ PULLBACK  │
                       └───────────┘  └───────────┘
```

---

## 5. Economic Calendar System

### 5.1 Fontes de Dados

| Fonte | API | Dados | Uso |
|-------|-----|-------|-----|
| **Finnhub** | REST | Real-time calendar | Live trading |
| **Forex Factory** | Scrape | Histórico 2007+ | Backtest |
| **Investing.com** | Scrape | Histórico + Forecast | Backtest |
| **Local CSV** | File | Cache local | Fallback |

### 5.2 Estrutura de Dados de Evento

```cpp
struct SEconomicEvent
{
   datetime          time;           // UTC time
   string            event_name;     // "Non-Farm Payrolls"
   string            currency;       // "USD"
   ENUM_NEWS_IMPACT  impact;         // HIGH, MEDIUM, LOW
   double            forecast;       // Expectativa
   double            previous;       // Valor anterior
   double            actual;         // Valor real (só após)
   string            unit;           // "K", "%", etc
   bool              is_speech;      // É discurso (não tem números)
   
   // Calculated fields
   double            surprise;       // actual - forecast
   double            surprise_pct;   // surprise / previous * 100
   ENUM_SURPRISE_DIR direction;      // BETTER, WORSE, INLINE
};
```

### 5.3 Arquivo Histórico (CSV)

```csv
datetime,event,currency,impact,forecast,previous,actual
2024-01-05 13:30:00,Non-Farm Payrolls,USD,HIGH,170K,199K,216K
2024-01-11 13:30:00,CPI m/m,USD,HIGH,0.2%,0.1%,0.3%
2024-01-31 19:00:00,Fed Interest Rate Decision,USD,HIGH,5.50%,5.50%,5.50%
...
```

### 5.4 Gold Response Map

Baseado em análise histórica (RAG research):

```cpp
// Como gold reage a surprises USD
MAP<string, ENUM_GOLD_RESPONSE> GoldResponseMap = {
   // Dados melhores que esperado = USD forte = Gold DOWN
   {"NFP_BETTER", GOLD_DOWN},
   {"CPI_HIGHER", GOLD_UP},        // Inflação = gold hedge
   {"GDP_BETTER", GOLD_DOWN},
   {"JOBLESS_LOWER", GOLD_DOWN},
   
   // Fed
   {"FED_HAWKISH", GOLD_DOWN},
   {"FED_DOVISH", GOLD_UP},
   
   // Safe haven
   {"VIX_SPIKE", GOLD_UP},
   {"CRISIS", GOLD_UP},
};
```

---

## 6. Backtest Realism Layer

### 6.1 Por Que É Necessário

```
PROBLEMA: Backtest normal é OTIMISTA demais
- Spread fixo (real varia 10x durante news)
- Slippage zero (real pode ser 50+ pips)
- Execução instantânea (real tem delay)
- 100% fill rate (real tem rejeições)

RESULTADO: EA lucrativo no backtest, falha no live

SOLUÇÃO: Backtest PESSIMISTA
- Se lucra com tudo contra, lucra no live
```

### 6.2 Simuladores

#### SlippageSimulator

```cpp
class CSlippageSimulator
{
public:
   double AddSlippage(double price, ENUM_ORDER_TYPE type, bool is_news_window)
   {
      double slippage_pips;
      
      if(is_news_window)
         slippage_pips = MathRand() % 50 + 10;  // 10-60 pips
      else
         slippage_pips = MathRand() % 5;         // 0-5 pips
      
      double slippage_price = slippage_pips * _Point * 10;
      
      // Slippage sempre contra você
      if(type == ORDER_TYPE_BUY)
         return price + slippage_price;  // Compra mais caro
      else
         return price - slippage_price;  // Vende mais barato
   }
};
```

#### SpreadSimulator

```cpp
class CSpreadSimulator
{
public:
   double GetSimulatedSpread(bool is_news_window, bool is_holiday)
   {
      double base_spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
      
      if(is_news_window)
         return base_spread * 5;  // 5x durante news
      else if(is_holiday)
         return base_spread * 2;  // 2x em feriado
      else
         return base_spread;
   }
};
```

#### LatencySimulator

```cpp
class CLatencySimulator
{
public:
   int GetExecutionDelay(bool is_news_window)
   {
      if(is_news_window)
         return 500 + (MathRand() % 1000);  // 500-1500ms
      else
         return 50 + (MathRand() % 100);    // 50-150ms
   }
};
```

#### RejectSimulator

```cpp
class CRejectSimulator
{
public:
   bool ShouldReject(bool is_news_window)
   {
      int reject_chance;
      
      if(is_news_window)
         reject_chance = 30;  // 30% rejection
      else
         reject_chance = 5;   // 5% rejection
      
      return (MathRand() % 100) < reject_chance;
   }
};
```

---

## 7. Strategy Selector

### 7.1 Hierarquia de Decisão

```cpp
ENUM_STRATEGY CStrategySelector::SelectStrategy()
{
   // 1. SAFETY CHECK (sempre primeiro)
   if(m_circuit_breaker.IsTriggered())
      return STRATEGY_NONE;
   
   // 2. FTMO MODE CHECK
   if(InpFTMOSafeMode && IsNewsWindow())
      return STRATEGY_AVOID_NEWS;
   
   // 3. NEWS WINDOW (prioridade alta)
   if(IsNewsWindow())
   {
      double confidence = GetNewsDirectionConfidence();
      
      if(confidence > 0.7)
         return STRATEGY_NEWS_PREPOSITION;
      else if(confidence > 0.5)
         return STRATEGY_NEWS_PULLBACK;
      else
         return STRATEGY_NEWS_STRADDLE;
   }
   
   // 4. REGIME BASED
   double hurst = m_regime.GetHurst();
   
   if(hurst > 0.55)
      return STRATEGY_TREND_FOLLOWER;
   else if(hurst < 0.45)
      return STRATEGY_MEAN_REVERSION;
   
   // 5. DEFAULT
   return STRATEGY_SMC_SCALPER;
}
```

### 7.2 Transição Entre Estratégias

```cpp
void CStrategySelector::OnStrategyChange(ENUM_STRATEGY old_strat, ENUM_STRATEGY new_strat)
{
   // Log transition
   Print("Strategy change: ", EnumToString(old_strat), " -> ", EnumToString(new_strat));
   
   // Rules for open trades:
   // - Trades abertos mantêm sua estratégia original
   // - Novos trades usam nova estratégia
   // - Se HIGH impact news chegando, pode fazer emergency close
   
   if(new_strat == STRATEGY_NEWS_PREPOSITION && HasOpenTrades())
   {
      // Decide: manter ou fechar trades existentes
      if(GetOpenTradesRisk() > 0.5)  // > 0.5% em risco
      {
         CloseAllTrades("News approaching, reducing exposure");
      }
   }
}
```

---

## 8. Arquivos a Criar

### 8.1 Python (5 arquivos)

| Arquivo | Função |
|---------|--------|
| `economic_calendar.py` | Finnhub API + parsing |
| `calendar_history.py` | Carregar CSV histórico |
| `news_direction.py` | Calcular direção esperada |
| `routers/calendar.py` | Endpoints FastAPI |
| `data/economic_events.csv` | Histórico 2020-2024 |

### 8.2 MQL5 (8 arquivos)

| Arquivo | Camada | Função |
|---------|--------|--------|
| `CCircuitBreaker.mqh` | Safety | DD protection |
| `CSpreadMonitor.mqh` | Safety | Spread check |
| `CNewsWindowDetector.mqh` | Context | Detectar janela news |
| `CHolidayDetector.mqh` | Context | Detectar feriados |
| `CStrategySelector.mqh` | Selector | Escolher estratégia |
| `CNewsTrader.mqh` | Execution | News trading logic |
| `CTrendFollower.mqh` | Execution | Trend following |
| `CBacktestRealism.mqh` | Backtest | Simuladores |

### 8.3 Estrutura de Pastas

```
MQL5/Include/EA_SCALPER/
├── Safety/                    [NEW]
│   ├── CCircuitBreaker.mqh
│   └── CSpreadMonitor.mqh
│
├── Context/                   [NEW]
│   ├── CNewsWindowDetector.mqh
│   ├── CHolidayDetector.mqh
│   └── CContextAggregator.mqh
│
├── Strategy/                  [NEW]
│   ├── CStrategySelector.mqh
│   ├── CNewsTrader.mqh
│   ├── CTrendFollower.mqh
│   ├── CMeanReversion.mqh
│   └── IStrategy.mqh          (interface)
│
├── Backtest/                  [NEW]
│   ├── CBacktestRealism.mqh
│   ├── CSlippageSimulator.mqh
│   ├── CSpreadSimulator.mqh
│   └── CLatencySimulator.mqh
│
├── Analysis/                  (existente)
├── Signal/                    (existente)
├── Bridge/                    (existente)
├── Risk/                      (existente)
└── Execution/                 (existente)
```

---

## 9. Inputs do EA (v4.0)

### 9.1 Novos Inputs

```cpp
//--- Strategy Selection
input bool   InpEnableNewsTrading = true;     // Ativar News Trading
input bool   InpEnableTrendFollower = true;   // Ativar Trend Follower
input bool   InpEnableMeanReversion = true;   // Ativar Mean Reversion
input bool   InpFTMOSafeMode = false;         // Modo FTMO (evita news)

//--- News Trading
input int    InpNewsWindowMinutes = 30;       // Janela antes do evento (min)
input int    InpNewsWindowAfter = 15;         // Janela após evento (min)
input double InpNewsRiskPercent = 0.25;       // Risk % durante news
input int    InpMaxNewsTradesDay = 1;         // Max news trades por dia
input int    InpPullbackWaitSeconds = 45;     // Espera antes de pullback

//--- Backtest Realism
input bool   InpSimulateSlippage = true;      // Simular slippage
input bool   InpSimulateSpread = true;        // Simular spread extra
input bool   InpSimulateLatency = true;       // Simular latência
input bool   InpSimulateRejects = true;       // Simular rejeições
input int    InpMaxSlippagePips = 50;         // Max slippage (pips)

//--- Circuit Breaker
input double InpDailyDDLimit = 4.0;           // DD diário limite (%)
input double InpTotalDDLimit = 8.0;           // DD total limite (%)
input int    InpCooldownMinutes = 120;        // Cooldown após loss (min)
```

---

## 10. Cronograma de Implementação

### Fase 1: Foundation (Esta sessão)
- [ ] Criar estrutura de pastas
- [ ] Economic Calendar Service (Python)
- [ ] CSV histórico inicial
- [ ] CNewsWindowDetector (MQL5)

### Fase 2: Safety Layer
- [ ] CCircuitBreaker
- [ ] CSpreadMonitor
- [ ] CHolidayDetector

### Fase 3: News Trading
- [ ] CNewsTrader (3 modos)
- [ ] Integração com calendar
- [ ] Backtest validation

### Fase 4: Strategy Selector
- [ ] CStrategySelector
- [ ] Transições
- [ ] Testes integrados

### Fase 5: Backtest Realism
- [ ] Simuladores
- [ ] Validação contra live

### Fase 6: Validation
- [ ] Walk-Forward Analysis
- [ ] Monte Carlo
- [ ] Demo trading

---

## 11. Métricas de Sucesso

| Métrica | Target | Medição |
|---------|--------|---------|
| Win Rate (News) | > 55% | Por estratégia |
| Avg R:R (News) | > 2.5 | Por trade |
| Max DD (Backtest Pessimista) | < 8% | Com simuladores |
| Profit Factor | > 2.0 | Geral |
| News trades/mês | 5-10 | Qualidade > quantidade |
| Correlation com SMC | < 0.3 | Diversificação |

---

## 12. Riscos Residuais Aceitos

Após todas as proteções, ainda existem riscos que ACEITAMOS:

1. **Black Swan** - Eventos imprevisíveis (guerra, pandemia)
2. **Broker Insolvency** - Broker falir durante trade
3. **Exchange Halt** - Mercado fechar inesperadamente
4. **Regulatory Change** - Novas regras que afetam trading

**Mitigação**: Max DD geral de 10%, diversificação de capital entre brokers.

---

*Documento preparado para implementação do EA_SCALPER_XAUUSD v4.0*
*"Assume o pior, prepare-se para o pior, lucre quando der certo"*
