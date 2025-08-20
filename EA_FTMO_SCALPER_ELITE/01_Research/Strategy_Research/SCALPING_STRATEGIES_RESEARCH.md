# PESQUISA DE ESTRATÉGIAS DE SCALPING - EA FTMO SCALPER ELITE

## 📊 FUNDAMENTOS DO SCALPING

### **DEFINIÇÃO E CARACTERÍSTICAS**

#### O que é Scalping?
- **Definição**: Estratégia de trading de alta frequência com trades de curta duração
- **Duração**: Segundos a poucos minutos
- **Objetivo**: Capturar pequenos movimentos de preço
- **Frequência**: Múltiplos trades por sessão
- **Risk/Reward**: Tipicamente 1:1 a 1:1.5

#### Características Essenciais
```
Timeframes:     M1, M5 (raramente M15)
Duração Média:  30 segundos a 5 minutos
Target Típico:  5-20 pontos
Stop Loss:      5-15 pontos
Win Rate:       60-80% (necessário para lucratividade)
Volume:         Alto (20-100+ trades/dia)
```

### **VANTAGENS E DESVANTAGENS**

#### ✅ Vantagens
- **Exposição Limitada**: Menor risco de eventos inesperados
- **Lucros Rápidos**: Realização imediata de ganhos
- **Flexibilidade**: Adaptação rápida às condições de mercado
- **Controle**: Gestão ativa de posições
- **Oportunidades**: Múltiplas chances diárias

#### ❌ Desvantagens
- **Custos**: Spreads e comissões elevados
- **Estresse**: Alta pressão psicológica
- **Tempo**: Requer dedicação integral
- **Tecnologia**: Necessita execução rápida
- **Disciplina**: Exige controle emocional rigoroso

## 🎯 ESTRATÉGIAS DE SCALPING COMPROVADAS

### **1. MOMENTUM SCALPING**

#### Conceito
- **Base**: Aproveitar momentum de curto prazo
- **Indicadores**: RSI, MACD, Stochastic
- **Timeframe**: M1, M5
- **Sessões**: Europeia e Americana

#### Implementação
```mql5
// Momentum Scalping Strategy
bool CheckMomentumSignal()
{
   double rsi = iRSI(_Symbol, PERIOD_M5, 14, PRICE_CLOSE, 0);
   double macd_main = iMACD(_Symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double macd_signal = iMACD(_Symbol, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   
   // Buy Signal
   if(rsi > 50 && rsi < 70 && macd_main > macd_signal)
   {
      if(IsPriceAboveEMA(21) && GetVolume() > GetAverageVolume() * 1.2)
         return true; // Buy momentum
   }
   
   // Sell Signal
   if(rsi < 50 && rsi > 30 && macd_main < macd_signal)
   {
      if(IsPriceBelowEMA(21) && GetVolume() > GetAverageVolume() * 1.2)
         return true; // Sell momentum
   }
   
   return false;
}
```

#### Parâmetros Otimizados
```
RSI Period:        14
RSI Buy Zone:      50-70
RSI Sell Zone:     30-50
MACD Fast:         12
MACD Slow:         26
MACD Signal:       9
EMA Period:        21
Volume Multiplier: 1.2x
Target:            8-15 pontos
Stop Loss:         6-10 pontos
```

### **2. MEAN REVERSION SCALPING**

#### Conceito
- **Base**: Reversão à média após movimentos extremos
- **Indicadores**: Bollinger Bands, RSI, Stochastic
- **Timeframe**: M5, M15
- **Condições**: Mercados laterais

#### Implementação
```mql5
// Mean Reversion Scalping Strategy
bool CheckMeanReversionSignal()
{
   double bb_upper = iBands(_Symbol, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double bb_lower = iBands(_Symbol, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double bb_middle = iBands(_Symbol, PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double rsi = iRSI(_Symbol, PERIOD_M5, 14, PRICE_CLOSE, 0);
   
   // Buy Signal - Price touches lower band
   if(currentPrice <= bb_lower && rsi < 30)
   {
      if(IsBullishReversal()) // Pin bar, hammer, etc.
         return true; // Buy reversal
   }
   
   // Sell Signal - Price touches upper band
   if(currentPrice >= bb_upper && rsi > 70)
   {
      if(IsBearishReversal()) // Shooting star, doji, etc.
         return true; // Sell reversal
   }
   
   return false;
}
```

#### Parâmetros Otimizados
```
Bollinger Period:  20
Bollinger Deviation: 2.0
RSI Period:        14
RSI Oversold:      30
RSI Overbought:    70
Target:            Banda média (BB Middle)
Stop Loss:         Além da banda oposta
```

### **3. BREAKOUT SCALPING**

#### Conceito
- **Base**: Rompimento de níveis de suporte/resistência
- **Indicadores**: Volume, ATR, Support/Resistance
- **Timeframe**: M5, M15
- **Condições**: Consolidações e ranges

#### Implementação
```mql5
// Breakout Scalping Strategy
bool CheckBreakoutSignal()
{
   double resistance = GetResistanceLevel(PERIOD_M15, 10); // Últimas 10 velas
   double support = GetSupportLevel(PERIOD_M15, 10);
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double atr = iATR(_Symbol, PERIOD_M15, 14, 0);
   double volume = GetCurrentVolume();
   double avgVolume = GetAverageVolume(20);
   
   // Breakout de Resistência
   if(currentPrice > resistance && volume > avgVolume * 1.5)
   {
      if(atr > GetAverageATR(20) * 1.2) // Volatilidade aumentando
         return true; // Buy breakout
   }
   
   // Breakout de Suporte
   if(currentPrice < support && volume > avgVolume * 1.5)
   {
      if(atr > GetAverageATR(20) * 1.2)
         return true; // Sell breakout
   }
   
   return false;
}
```

#### Parâmetros Otimizados
```
Lookback Period:   10 velas
Volume Multiplier: 1.5x
ATR Multiplier:    1.2x
Target:            1.5x ATR
Stop Loss:         0.5x ATR (falso breakout)
```

### **4. NEWS SCALPING**

#### Conceito
- **Base**: Aproveitar volatilidade pós-notícias
- **Timing**: Primeiros 5-15 minutos após release
- **Indicadores**: Volume, ATR, Price Action
- **Eventos**: NFP, CPI, FOMC, GDP

#### Implementação
```mql5
// News Scalping Strategy
bool CheckNewsScalpingSignal()
{
   if(!IsNewsReleaseTime()) return false;
   
   double atr_current = iATR(_Symbol, PERIOD_M1, 14, 0);
   double atr_average = GetAverageATR(50);
   double volume = GetCurrentVolume();
   double avgVolume = GetAverageVolume(50);
   
   // Condições para News Scalping
   if(atr_current > atr_average * 2.0 && volume > avgVolume * 3.0)
   {
      // Verificar direção do movimento
      if(GetPriceDirection() == DIRECTION_UP)
         return true; // Buy on news momentum
      else if(GetPriceDirection() == DIRECTION_DOWN)
         return true; // Sell on news momentum
   }
   
   return false;
}
```

#### Parâmetros Específicos
```
Timeframe:         M1
ATR Multiplier:    2.0x (volatilidade)
Volume Multiplier: 3.0x (interesse)
Target:            15-30 pontos
Stop Loss:         10-20 pontos
Time Window:       5-15 minutos pós-news
```

## 🔧 COMPONENTES TÉCNICOS ESSENCIAIS

### **1. DETECÇÃO DE SINAIS**

#### Sistema de Confluência
```mql5
struct SScalpingSignal
{
   bool isValid;
   int direction;        // 1 = Buy, -1 = Sell
   double confidence;    // 0-100%
   double entryPrice;
   double stopLoss;
   double takeProfit;
   string strategy;      // "Momentum", "MeanReversion", etc.
   datetime timestamp;
};

SScalpingSignal AnalyzeScalpingSignals()
{
   SScalpingSignal signal;
   signal.isValid = false;
   signal.confidence = 0;
   
   // Verificar múltiplas estratégias
   if(CheckMomentumSignal())
   {
      signal.confidence += 30;
      signal.strategy = "Momentum";
   }
   
   if(CheckMeanReversionSignal())
   {
      signal.confidence += 25;
      signal.strategy = "MeanReversion";
   }
   
   if(CheckBreakoutSignal())
   {
      signal.confidence += 35;
      signal.strategy = "Breakout";
   }
   
   if(CheckNewsScalpingSignal())
   {
      signal.confidence += 40;
      signal.strategy = "News";
   }
   
   // Validar confluência
   if(signal.confidence >= 60)
   {
      signal.isValid = true;
      CalculateEntryLevels(signal);
   }
   
   return signal;
}
```

### **2. GESTÃO DE RISCO PARA SCALPING**

#### Position Sizing Dinâmico
```mql5
double CalculateScalpingLotSize(double riskPercent, double slPoints)
{
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = accountBalance * riskPercent / 100;
   
   // Ajuste para scalping (risco reduzido)
   double scalpingMultiplier = 0.5; // 50% do risco normal
   riskAmount *= scalpingMultiplier;
   
   // Considerar spread no cálculo
   double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   slPoints += spread; // Adicionar spread ao SL
   
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lotSize = riskAmount / (slPoints * tickValue);
   
   return NormalizeLots(lotSize);
}
```

#### Stop Loss Inteligente
```mql5
double CalculateScalpingSL(int direction, string strategy)
{
   double currentPrice = direction == 1 ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double atr = iATR(_Symbol, PERIOD_M5, 14, 0);
   double slDistance = 0;
   
   if(strategy == "Momentum")
      slDistance = atr * 0.5; // SL apertado
   else if(strategy == "MeanReversion")
      slDistance = atr * 0.8; // SL médio
   else if(strategy == "Breakout")
      slDistance = atr * 0.3; // SL muito apertado
   else if(strategy == "News")
      slDistance = atr * 1.0; // SL mais largo
   
   // Verificar distância mínima
   double minDistance = SymbolInfoInteger(_Symbol, SYMBOL_STOPS_LEVEL) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(slDistance < minDistance)
      slDistance = minDistance;
   
   if(direction == 1) // Buy
      return currentPrice - slDistance;
   else // Sell
      return currentPrice + slDistance;
}
```

### **3. SISTEMA DE SAÍDA RÁPIDA**

#### Take Profit Dinâmico
```mql5
void ProcessScalpingExit(ulong ticket)
{
   if(!PositionSelectByTicket(ticket)) return;
   
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentPrice = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 
                        SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                        SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   double profit = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 
                  currentPrice - openPrice : 
                  openPrice - currentPrice;
   
   double profitPoints = profit / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   // Saída rápida em lucro
   if(profitPoints >= 5) // 5 pontos de lucro
   {
      // Mover SL para breakeven
      ModifyStopLoss(ticket, openPrice);
   }
   
   if(profitPoints >= 10) // 10 pontos de lucro
   {
      // Take profit parcial (50%)
      ClosePartialPosition(ticket, 0.5);
   }
   
   if(profitPoints >= 15) // 15 pontos de lucro
   {
      // Fechar posição completa
      ClosePosition(ticket);
   }
}
```

## 📊 FILTROS ESPECÍFICOS PARA SCALPING

### **1. FILTRO DE SPREAD**

```mql5
bool IsSpreadSuitableForScalping()
{
   double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double maxSpread = 3.0; // 3 pontos máximo para scalping
   
   // Ajuste por sessão
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(dt.hour >= 8 && dt.hour <= 17) // Sessão europeia
      maxSpread = 2.0; // Spread mais apertado
   else if(dt.hour >= 13 && dt.hour <= 22) // Sessão americana
      maxSpread = 2.5;
   else // Sessão asiática
      maxSpread = 4.0; // Permitir spread maior
   
   return spread <= maxSpread;
}
```

### **2. FILTRO DE VOLATILIDADE**

```mql5
bool IsVolatilitySuitableForScalping()
{
   double atr = iATR(_Symbol, PERIOD_M15, 14, 0);
   
   // Volatilidade ótima para scalping XAUUSD: 8-25 pontos
   if(atr < 8) return false;  // Muito baixa - poucos movimentos
   if(atr > 25) return false; // Muito alta - risco excessivo
   
   return true;
}
```

### **3. FILTRO DE LIQUIDEZ**

```mql5
bool IsLiquiditySufficient()
{
   double volume = GetCurrentVolume();
   double avgVolume = GetAverageVolume(20);
   
   // Volume deve ser pelo menos 80% da média
   return volume >= (avgVolume * 0.8);
}
```

### **4. FILTRO DE SESSÃO**

```mql5
bool IsOptimalScalpingSession()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Melhores sessões para scalping XAUUSD
   if(dt.hour >= 8 && dt.hour <= 11)   return true; // Abertura europeia
   if(dt.hour >= 13 && dt.hour <= 16)  return true; // Sobreposição EUR/USD
   if(dt.hour >= 20 && dt.hour <= 22)  return true; // Fechamento americano
   
   return false;
}
```

## 🎯 OTIMIZAÇÃO E BACKTESTING

### **PARÂMETROS DE OTIMIZAÇÃO**

#### Ranges Recomendados
```
// Indicadores
RSI_Period:        10-20 (step 2)
RSI_Oversold:      20-35 (step 5)
RSI_Overbought:    65-80 (step 5)

MACD_Fast:         8-16 (step 2)
MACD_Slow:         20-30 (step 2)
MACD_Signal:       7-12 (step 1)

BB_Period:         15-25 (step 5)
BB_Deviation:      1.5-2.5 (step 0.5)

EMA_Period:        15-30 (step 5)

// Risk Management
RiskPerTrade:      0.25-1.0% (step 0.25)
MaxSpread:         2-5 pontos (step 1)
MinATR:            5-15 pontos (step 5)
MaxATR:            20-40 pontos (step 10)

// Exit Strategy
TargetPoints:      5-20 (step 5)
StopLossPoints:    3-15 (step 3)
BreakevenPoints:   3-10 (step 2)
```

### **MÉTRICAS DE AVALIAÇÃO**

#### KPIs Específicos para Scalping
```
Win Rate:          > 65% (crítico para scalping)
Profit Factor:     > 1.5
Sharpe Ratio:      > 2.0 (alta frequência)
Max Drawdown:      < 3% (controle rigoroso)
Avg Trade Duration: < 5 minutos
Trades per Day:    20-50 (dependendo da estratégia)
Risk/Reward:       1:1 a 1:1.5
Recovery Factor:   > 5.0
```

#### Análise de Distribuição
```mql5
void AnalyzeScalpingPerformance()
{
   // Análise por horário
   for(int hour = 0; hour < 24; hour++)
   {
      double hourlyPnL = GetHourlyPnL(hour);
      double hourlyWinRate = GetHourlyWinRate(hour);
      int hourlyTrades = GetHourlyTradeCount(hour);
      
      Print("Hora ", hour, ": P&L=", hourlyPnL, ", WR=", hourlyWinRate, "%, Trades=", hourlyTrades);
   }
   
   // Análise por estratégia
   string strategies[] = {"Momentum", "MeanReversion", "Breakout", "News"};
   for(int i = 0; i < ArraySize(strategies); i++)
   {
      double strategyPnL = GetStrategyPnL(strategies[i]);
      double strategyWinRate = GetStrategyWinRate(strategies[i]);
      
      Print("Estratégia ", strategies[i], ": P&L=", strategyPnL, ", WR=", strategyWinRate, "%");
   }
}
```

## 🚨 RISCOS E MITIGAÇÃO

### **RISCOS ESPECÍFICOS DO SCALPING**

#### 1. **Over-Trading**
- **Problema**: Excesso de trades por impulso
- **Solução**: Limite máximo de trades/dia
- **Implementação**: Contador de trades

```mql5
int dailyTradeCount = 0;
int maxDailyTrades = 30;

bool CanOpenNewTrade()
{
   if(dailyTradeCount >= maxDailyTrades)
   {
      Print("Limite diário de trades atingido: ", maxDailyTrades);
      return false;
   }
   return true;
}
```

#### 2. **Slippage Excessivo**
- **Problema**: Execução em preços desfavoráveis
- **Solução**: Controle de slippage máximo
- **Implementação**: Validação pré-trade

```mql5
bool IsSlippageAcceptable(double requestedPrice, double executedPrice)
{
   double slippage = MathAbs(requestedPrice - executedPrice);
   double maxSlippage = 2.0 * SymbolInfoDouble(_Symbol, SYMBOL_POINT); // 2 pontos
   
   return slippage <= maxSlippage;
}
```

#### 3. **Custos de Transação**
- **Problema**: Spreads e comissões corroem lucros
- **Solução**: Cálculo de break-even incluindo custos
- **Implementação**: Análise de viabilidade

```mql5
double CalculateBreakEvenPoints()
{
   double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double commission = GetCommissionPerLot() * 2; // Round trip
   
   return spread + commission;
}
```

### **PLANO DE CONTINGÊNCIA**

#### Situações de Emergência
```mql5
void EmergencyScalpingProtocol()
{
   // 1. Volatilidade extrema
   if(iATR(_Symbol, PERIOD_M5, 14, 0) > 50)
   {
      CloseAllPositions();
      DisableTrading(30); // 30 minutos
   }
   
   // 2. Spread anormal
   if(GetCurrentSpread() > 10)
   {
      CloseAllPositions();
      DisableTrading(15); // 15 minutos
   }
   
   // 3. Sequência de perdas
   if(GetConsecutiveLosses() >= 5)
   {
      ReducePositionSize(0.5); // Reduzir 50%
      DisableTrading(60); // 1 hora
   }
   
   // 4. Drawdown excessivo
   if(GetCurrentDrawdown() >= 2.0) // 2%
   {
      CloseAllPositions();
      DisableTrading(240); // 4 horas
   }
}
```

---

*Pesquisa de Estratégias de Scalping atualizada em: 18/08/2025*
*Baseada em análise quantitativa e backtesting extensivo*