# Estrategias dos Melhores Robos - O Que Aproveitar

**Data**: 2025-12-02  
**Fonte**: Pesquisa ARGUS  
**Objetivo**: Extrair tacticas implementaveis

---

## 1. DOS TOP TRADERS FTMO

### 1.1 Choon Chiat (Top 1 Scalper Gold)

**O que ele faz que FUNCIONA:**

```
ESTRATEGIA: "Consolidation Bounce"
├── Timeframes: M30 + M5
├── Win Rate: 70%
├── R:R: 1:1 (mas com 70% win rate, funciona)
├── Trades/dia: 2-3 MAX
└── Target diario: 200 pips

LOGICA:
1. Identificar RANGE (consolidacao) no M30
2. Esperar preco tocar suporte/resistencia
3. Confirmar com Bollinger Bands (toque na banda)
4. Confirmar com RSI (oversold/overbought)
5. Entrar no bounce
6. SL atras do nivel
7. TP no outro lado do range
```

**Para implementar no nosso EA:**
```mql5
// Adicionar detector de consolidacao
bool IsConsolidation(int period = 20)
{
   double range = iHigh(_Symbol, PERIOD_M30, iHighest(_Symbol, PERIOD_M30, MODE_HIGH, period, 0))
                - iLow(_Symbol, PERIOD_M30, iLowest(_Symbol, PERIOD_M30, MODE_LOW, period, 0));
   double atr = GetATR(PERIOD_M30, 14);
   
   return (range < atr * 2.5);  // Range menor que 2.5x ATR = consolidacao
}
```

**Prioridade**: ALTA - Simples e efetivo

---

### 1.2 Leo (Top Intraday - Stop Hunt Strategy)

**O que ele faz que FUNCIONA:**

```
ESTRATEGIA: "Institutional Stop Hunt"
├── Timeframe: M15 apenas
├── Sessoes: London (hora 2-3) + NY (hora 2-3)
├── R:R: 1:3
├── Foco: Identificar onde instituicoes "calam" o varejo

LOGICA:
1. Identificar ONDE estao os stops do varejo
   - Abaixo de double bottoms
   - Acima de double tops
   - Atras de niveis obvios
2. Esperar SWEEP desses niveis
3. Entrar na REVERSAO apos o sweep
4. SL atras do sweep
5. TP em 3x o risco
```

**Para implementar no nosso EA:**
```mql5
// Ja temos CLiquiditySweepDetector!
// Melhorar para detectar "obvious levels" do varejo

struct SRetailLiquidityPool
{
   double level;
   ENUM_LIQUIDITY_TYPE type;  // DOUBLE_TOP, DOUBLE_BOTTOM, ROUND_NUMBER
   int touches;               // Quantas vezes tocou (mais = mais stops)
   datetime last_touch;
};

// Sweep + Reversao = Entry
bool IsStopHuntEntry(ENUM_SIGNAL_TYPE &signal)
{
   SLiquidityPool ssl = g_Sweep.GetNearestSSL(price);
   if(ssl.is_valid && ssl.was_swept && !ssl.was_traded)
   {
      // Confirmar reversao com candle pattern
      if(IsBullishEngulfing(1))
      {
         signal = SIGNAL_BUY;
         return true;
      }
   }
   return false;
}
```

**Prioridade**: ALTA - Ja temos a base (CLiquiditySweepDetector)

---

## 2. DOS MELHORES EAs MYFXBOOK

### 2.1 Seagull EA (1800% gain, 5.6% DD)

**O que ele faz:**
```
ESTRATEGIA: "Grid Inteligente com Hedge"
├── NAO usa martingale puro
├── Usa grid ADAPTATIVO (spacing muda com volatilidade)
├── Hedge parcial em DD
├── Recovery mode quando em perda

DIFERENCIAL:
- Grid spacing = ATR * multiplier
- Quando DD > 3%: abre hedge parcial
- Quando DD > 5%: para de abrir novas posicoes
```

**Para implementar:**
```mql5
// Grid adaptativo (spacing baseado em ATR)
double GetAdaptiveGridSpacing()
{
   double atr = GetATR(PERIOD_H1, 14);
   double base_spacing = 50;  // pips
   
   // Em alta volatilidade, aumentar spacing
   // Em baixa volatilidade, diminuir
   return base_spacing * (atr / GetATR(PERIOD_H1, 100));
}
```

**Prioridade**: BAIXA - Grid nao combina com FTMO (risco de DD)

---

### 2.2 FXStabilizer (3693% gain, 13% DD)

**O que ele faz:**
```
ESTRATEGIA: "Night Scalping"
├── Opera APENAS na sessao asiatica
├── Mercado mais calmo = moves menores mas previsiveis
├── Targets pequenos (10-20 pips)
├── Muitos trades (alta frequencia)

LOGICA:
1. Detectar range asiatico (00:00 - 08:00 GMT)
2. Trade bounces dentro do range
3. SL apertado (1x range)
4. TP no meio do range
```

**Para implementar:**
```mql5
// Adicionar modo "Asian Range Scalper"
struct SAsianRange
{
   double high;
   double low;
   double mid;
   bool is_valid;
};

SAsianRange GetAsianRange()
{
   SAsianRange ar;
   // Calcular high/low entre 00:00 e 08:00 GMT
   datetime asian_start = GetTodayTime(0, 0);
   datetime asian_end = GetTodayTime(8, 0);
   
   ar.high = iHigh(_Symbol, PERIOD_M15, iHighest(...));
   ar.low = iLow(_Symbol, PERIOD_M15, iLowest(...));
   ar.mid = (ar.high + ar.low) / 2;
   ar.is_valid = (ar.high - ar.low) > 50 * _Point;
   
   return ar;
}
```

**Prioridade**: MEDIA - Pode ser util como estrategia alternativa

---

### 2.3 Forex Fury (93% win rate)

**O que ele faz:**
```
ESTRATEGIA: "Low Risk Scalping"
├── Win rate altissimo (93%)
├── R:R baixo (0.5:1 tipico)
├── Muitos filtros para so pegar "easy trades"
├── Foco em consistencia, nao em grandes gains

FILTROS:
1. Spread < X pips
2. Volatilidade no range ideal
3. Sem news nas proximas 2 horas
4. Tendencia clara no H1
5. Preco em zona de suporte/resistencia
```

**Para implementar:**
```mql5
// Criar "Easy Trade Filter"
bool IsEasyTrade()
{
   // 1. Spread aceitavel
   if(GetSpread() > 40) return false;
   
   // 2. Volatilidade ideal (nao muito alta, nao muito baixa)
   double vol_rank = GetVolRank();
   if(vol_rank < 0.3 || vol_rank > 0.8) return false;
   
   // 3. News free
   if(!g_NewsNative.IsTradingAllowed()) return false;
   
   // 4. H1 trend claro
   if(g_MTF.GetHTFTrend() == TREND_NONE) return false;
   
   // 5. Em zona de estrutura
   if(!HasStructureContext()) return false;
   
   return true;
}
```

**Prioridade**: ALTA - Filtro de qualidade

---

## 3. DO MEDALLION FUND (Adaptado para Retail)

### 3.1 Mean Reversion com Momentum

**Conceito:**
```
NAO da pra replicar HFT, MAS podemos usar os PRINCIPIOS:

1. MEAN REVERSION em ranges
   - Quando preco desvia muito da media, tende a voltar
   - Usar Bollinger Bands ou Z-Score

2. MOMENTUM em breakouts
   - Quando rompe com forca, continua
   - Confirmar com volume/delta

3. REGIME SWITCHING
   - Detectar quando mercado muda de trending para ranging
   - Trocar estrategia automaticamente
```

**Para implementar:**
```mql5
// Ja temos CRegimeDetector!
// Melhorar para trocar estrategia automaticamente

void AdaptStrategyToRegime()
{
   ENUM_MARKET_REGIME regime = g_Regime.GetCurrentRegime();
   
   switch(regime)
   {
      case REGIME_TRENDING:
         // Usar breakout/momentum entries
         g_EntryOpt.SetMode(ENTRY_BREAKOUT);
         g_ModeCfg.min_rr = 2.0;
         break;
         
      case REGIME_MEAN_REVERTING:
         // Usar bounce entries em extremos
         g_EntryOpt.SetMode(ENTRY_MEAN_REVERT);
         g_ModeCfg.min_rr = 1.5;
         break;
         
      case REGIME_RANDOM_WALK:
         // NAO OPERAR
         g_ModeCfg.execution_threshold = 999;
         break;
   }
}
```

**Prioridade**: ALTA - Ja temos 80% implementado

---

### 3.2 Kelly Criterion Dinamico

**Conceito:**
```
Position sizing baseado em edge estimado:

Kelly % = (Win% * AvgWin - Loss% * AvgLoss) / AvgWin

MELHORIAS:
1. Usar Kelly FRACIONADO (25-50% do full Kelly)
2. Ajustar baseado em DD recente
3. Ajustar baseado em regime
```

**Para implementar:**
```mql5
// Ja temos algo em FTMO_RiskManager
// Melhorar para Kelly adaptativo

double GetAdaptiveKellyRisk()
{
   double win_rate = g_Stats.GetRecentWinRate(50);  // Ultimos 50 trades
   double avg_win = g_Stats.GetAvgWin();
   double avg_loss = g_Stats.GetAvgLoss();
   
   double kelly = (win_rate * avg_win - (1 - win_rate) * avg_loss) / avg_win;
   kelly = MathMax(0, kelly);
   
   // Fracao do Kelly (mais conservador)
   double fraction = 0.25;  // Usar 25% do Kelly
   
   // Ajustar por DD
   double dd = g_RiskManager.GetCurrentDD();
   if(dd > 3) fraction *= 0.5;
   if(dd > 5) fraction *= 0.25;
   
   return kelly * fraction;
}
```

**Prioridade**: MEDIA - Refinamento

---

## 4. DO REPO GITHUB (carlosrod723)

### 4.1 Estrategias ICT Nomeadas

**Conceito:**
```
4 tipos de setups bem definidos:

NFT (No Follow-Through):
- Candle com pavio longo (rejeicao)
- Seguido de candle na direcao oposta
- Entry: No fechamento do segundo candle

FT (Follow-Through):
- 2 candles consecutivos fechando alem do range anterior
- Momentum confirmado
- Entry: Apos o segundo candle

SFT (Strong Follow-Through):
- FT + confirmacao de sweep
- Candles maiores que media
- Entry: Com confirmacao de liquidez

CT (Counter-Trend):
- Trade contra a tendencia
- Apenas em zonas premium/discount extremas
- Requer mais confirmacao
```

**Para implementar:**
```mql5
// Criar enum para tipos de setup
enum ENUM_ICT_SETUP
{
   SETUP_NONE,
   SETUP_NFT,      // No Follow-Through (rejeicao)
   SETUP_FT,       // Follow-Through (momentum)
   SETUP_SFT,      // Strong Follow-Through (sweep + momentum)
   SETUP_CT        // Counter-Trend (reversao)
};

// Detectar tipo de setup atual
ENUM_ICT_SETUP DetectICTSetup()
{
   // Verificar SFT primeiro (mais forte)
   if(HasLiquiditySweep() && HasMomentum() && HasFibDiscount())
      return SETUP_SFT;
   
   // FT
   if(HasMomentum() && !HasLiquiditySweep())
      return SETUP_FT;
   
   // NFT
   if(HasRejectionWick() && HasFollowCandle())
      return SETUP_NFT;
   
   // CT
   if(InExtremeFibZone() && HasReversalPattern())
      return SETUP_CT;
   
   return SETUP_NONE;
}
```

**Prioridade**: MEDIA - Organizacao conceitual

---

### 4.2 Retry Logic (Robusto)

**Conceito:**
```
Quando order falha, tentar novamente:
- Max 3 tentativas
- Delay de 1 segundo entre tentativas
- Apenas para erros "retryable"
```

**Para implementar:**
```mql5
bool PlaceOrderWithRetry(ENUM_ORDER_TYPE type, double lot, double price, double sl, double tp)
{
   int max_attempts = 3;
   int delay_ms = 1000;
   
   for(int attempt = 1; attempt <= max_attempts; attempt++)
   {
      bool result = trade.OrderOpen(_Symbol, type, lot, 0, price, sl, tp, ORDER_TIME_GTC, 0, "");
      
      if(result)
         return true;
      
      int error = GetLastError();
      
      // Erros que vale tentar de novo
      if(error == 128 || error == 129 || error == 130 || 
         error == 136 || error == 137 || error == 138 ||
         error == 10004 || error == 10006)
      {
         Print("Attempt ", attempt, " failed. Retrying in ", delay_ms, "ms...");
         Sleep(delay_ms);
         continue;
      }
      
      // Erro nao-retryable
      Print("Non-retryable error: ", error);
      break;
   }
   
   return false;
}
```

**Prioridade**: ALTA - Robustez

---

## 5. RESUMO: O QUE IMPLEMENTAR

### PRIORIDADE ALTA (Fazer esta semana)

| Feature | De Onde | Complexidade | Impacto |
|---------|---------|--------------|---------|
| Easy Trade Filter | Forex Fury | Baixa | Alto |
| Stop Hunt Entry | Leo/FTMO | Media | Alto |
| Retry Logic | GitHub | Baixa | Medio |
| Consolidation Bounce | Choon Chiat | Media | Alto |

### PRIORIDADE MEDIA (Proximas semanas)

| Feature | De Onde | Complexidade | Impacto |
|---------|---------|--------------|---------|
| ICT Setup Types | GitHub | Media | Medio |
| Asian Range Mode | FXStabilizer | Media | Medio |
| Kelly Adaptativo | Medallion | Media | Medio |

### PRIORIDADE BAIXA (Futuro)

| Feature | De Onde | Complexidade | Impacto |
|---------|---------|--------------|---------|
| Grid Adaptativo | Seagull EA | Alta | Baixo (FTMO) |
| HFT-style | Medallion | Impossivel | N/A |

---

## 6. CODIGO PRONTO PARA COPIAR

### Easy Trade Filter (Adicionar ao EA)

```mql5
//+------------------------------------------------------------------+
//| Easy Trade Filter - Inspirado em Forex Fury                      |
//+------------------------------------------------------------------+
bool IsEasyTrade()
{
   // 1. Spread aceitavel (< 50% do SL tipico)
   int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread > 50) return false;
   
   // 2. Volatilidade no sweet spot
   double vol = GetVolRank();
   if(vol < 0.25 || vol > 0.85) return false;
   
   // 3. Sessao ativa (London ou NY)
   if(!g_Session.IsLondonOrNY()) return false;
   
   // 4. Sem news em 30 min
   SNewsWindowNative news = g_NewsNative.CheckNewsWindow();
   if(news.action == NEWS_ACTION_BLOCK) return false;
   
   // 5. HTF trend definido
   SMTFConfluence mtf = g_MTF.GetConfluence();
   if(!mtf.htf_aligned) return false;
   
   // 6. Tem estrutura (OB ou FVG)
   if(!HasOrderBlock() && !HasFVG()) return false;
   
   return true;
}
```

### Consolidation Bounce (Adicionar ao CStructureAnalyzer)

```mql5
//+------------------------------------------------------------------+
//| Consolidation Bounce - Inspirado em Choon Chiat                  |
//+------------------------------------------------------------------+
struct SConsolidation
{
   double high;
   double low;
   double mid;
   int bars;
   bool is_valid;
};

SConsolidation DetectConsolidation(int lookback = 20)
{
   SConsolidation cons;
   cons.is_valid = false;
   
   double highest = iHigh(_Symbol, PERIOD_M30, iHighest(_Symbol, PERIOD_M30, MODE_HIGH, lookback, 1));
   double lowest = iLow(_Symbol, PERIOD_M30, iLowest(_Symbol, PERIOD_M30, MODE_LOW, lookback, 1));
   double range = highest - lowest;
   
   // ATR para comparar
   double atr = iATR(_Symbol, PERIOD_M30, 14);
   double atr_val[];
   ArraySetAsSeries(atr_val, true);
   CopyBuffer(iATR(_Symbol, PERIOD_M30, 14), 0, 0, 1, atr_val);
   
   // Range < 2.5x ATR = consolidacao
   if(range < atr_val[0] * 2.5)
   {
      cons.high = highest;
      cons.low = lowest;
      cons.mid = (highest + lowest) / 2;
      cons.bars = lookback;
      cons.is_valid = true;
   }
   
   return cons;
}

ENUM_SIGNAL_TYPE GetConsolidationBounceSignal()
{
   SConsolidation cons = DetectConsolidation();
   if(!cons.is_valid) return SIGNAL_NONE;
   
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double buffer = (cons.high - cons.low) * 0.1;  // 10% buffer
   
   // Perto do low = potencial buy
   if(price < cons.low + buffer)
   {
      // Confirmar com RSI oversold
      if(GetRSI(PERIOD_M30, 14) < 30)
         return SIGNAL_BUY;
   }
   
   // Perto do high = potencial sell
   if(price > cons.high - buffer)
   {
      // Confirmar com RSI overbought
      if(GetRSI(PERIOD_M30, 14) > 70)
         return SIGNAL_SELL;
   }
   
   return SIGNAL_NONE;
}
```

---

*Documento criado para referencia de implementacao*
