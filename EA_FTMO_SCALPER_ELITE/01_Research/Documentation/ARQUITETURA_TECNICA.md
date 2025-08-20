# ARQUITETURA TÉCNICA - EA FTMO SCALPER ELITE

## 📋 VISÃO GERAL TÉCNICA

O EA FTMO Scalper Elite é um Expert Advisor desenvolvido em MQL5 com arquitetura modular e orientada a objetos, projetado especificamente para compliance com regras FTMO e prop firms.

## 🏗️ ARQUITETURA DO SISTEMA

### Estrutura Modular

```
EA_FTMO_SCALPER_ELITE.mq5
├── Risk Management System
├── Advanced Filters Module
├── Confluence Entry System
├── Intelligent Exit System
├── Alert & Notification System
└── Utility Functions
```

### Componentes Principais

#### 1. **Risk Management System**
- **Arquivo**: `RiskManager.mqh`
- **Função**: Proteção de capital e compliance FTMO
- **Características**:
  - Equity stop automático (5% diário / 10% total)
  - Position sizing baseado em risco por trade
  - Zona de segurança para proteção de lucros
  - Fechamento automático em situações críticas
  - Monitoramento contínuo de drawdown

#### 2. **Advanced Filters Module**
- **Arquivo**: `AdvancedFilters.mqh`
- **Função**: Filtrar condições de mercado inadequadas
- **Filtros Implementados**:
  - **News Filter**: Evita trading durante notícias de alto impacto
  - **Session Filter**: Limita trading a sessões específicas
  - **Volatility Filter**: Controla trading baseado em ATR
  - **Spread Filter**: Evita trading com spreads altos
  - **Time Filter**: Controle de horários personalizados

#### 3. **Confluence Entry System**
- **Arquivo**: `ConfluenceEntrySystem.mqh`
- **Função**: Análise multi-indicador para sinais de entrada
- **Indicadores Utilizados**:
  - **RSI (14)**: Identificação de sobrecompra/sobrevenda
  - **MACD (12,26,9)**: Confirmação de momentum
  - **EMA (50)**: Direção da tendência
- **Níveis de Confluência**: 1-5 (configurável)
- **Cálculo SL/TP**: Baseado em ATR com multiplicador 2.0

#### 4. **Intelligent Exit System**
- **Arquivo**: `IntelligentExitSystem.mqh`
- **Função**: Gerenciamento avançado de saídas
- **Tipos de Trailing Stop**:
  - **Fixed**: Distância fixa em pontos
  - **Percent**: Percentual do lucro
  - **ATR**: Baseado em Average True Range
  - **MA**: Seguindo Moving Average
  - **SAR**: Parabolic SAR
  - **High/Low**: Máximas/mínimas de velas
- **Breakeven**: Automático após X pontos de lucro
- **Partial TP**: Take profit parcial em níveis configuráveis

#### 5. **Alert & Notification System**
- **Arquivo**: `IntelligentAlertSystem.mqh`
- **Função**: Notificações em tempo real
- **Canais Suportados**:
  - Popup alerts (MetaTrader)
  - Sound alerts
  - Email notifications
  - Push notifications
  - Telegram Bot API
  - WhatsApp (via API)

## 🔧 IMPLEMENTAÇÃO TÉCNICA

### Estruturas de Dados

```mql5
// Estrutura de Sinal de Trade
struct STradeSignal
{
   bool isValid;         // Sinal válido
   int direction;        // 1 = Buy, -1 = Sell
   double entryPrice;    // Preço de entrada
   double stopLoss;      // Stop Loss
   double takeProfit;    // Take Profit
   double lotSize;       // Tamanho da posição
   string comment;       // Comentário
};

// Estrutura de Dados de Risco
struct SRiskData
{
   double currentEquity; // Equity atual
   double dailyPnL;      // P&L diário
   double totalPnL;      // P&L total
   double riskAmount;    // Valor de risco por trade
   bool canTrade;        // Pode negociar
   string riskStatus;    // Status do risco
};
```

### Fluxo de Execução

#### OnInit()
1. Configuração de objetos de trading
2. Inicialização de indicadores
3. Configuração de arrays
4. Inicialização de variáveis de controle
5. Validação de parâmetros

#### OnTick()
1. **Verificação de Nova Barra**
   ```mql5
   if(!IsNewBar()) return;
   ```

2. **Atualização de Dados**
   ```mql5
   account.Refresh();
   symbol.RefreshRates();
   ```

3. **Verificação de Risco**
   ```mql5
   SRiskData riskData = CheckRiskManagement();
   if(!riskData.canTrade) return;
   ```

4. **Aplicação de Filtros**
   ```mql5
   if(!CheckAdvancedFilters()) return;
   ```

5. **Processamento de Saídas**
   ```mql5
   ProcessExitSystem();
   ```

6. **Análise de Entrada**
   ```mql5
   STradeSignal signal = AnalyzeEntrySignal();
   if(signal.isValid) ExecuteTrade(signal);
   ```

### Algoritmo de Confluência

```mql5
int confluenceCount = 0;
int direction = 0;

// Análise RSI
if(rsi_buffer[0] < RSI_Oversold && rsi_buffer[1] >= RSI_Oversold)
{
   confluenceCount++;
   direction = 1; // Buy signal
}

// Análise MACD
if(macd_main[0] > macd_signal[0] && macd_main[1] <= macd_signal[1])
{
   if(direction == 1 || direction == 0)
   {
      confluenceCount++;
      if(direction == 0) direction = 1;
   }
}

// Análise EMA
if(currentPrice > ema_buffer[0] && direction == 1)
{
   confluenceCount++;
}

// Validação de Confluência
if(confluenceCount >= ConfluenceLevel && direction != 0)
{
   signal.isValid = true;
   // ... calcular SL/TP e lot size
}
```

### Cálculo de Position Sizing

```mql5
// Baseado no risco por trade
SRiskData risk = CheckRiskManagement();
double slDistance = MathAbs(signal.entryPrice - signal.stopLoss);
double tickValue = symbol.TickValue();
double tickSize = symbol.TickSize();

signal.lotSize = (risk.riskAmount / (slDistance / tickSize * tickValue));
signal.lotSize = NormalizeLots(signal.lotSize);
```

### Sistema de Trailing Stop ATR

```mql5
double CalculateATRTrailing(ulong ticket)
{
   if(CopyBuffer(handle_ATR, 0, 1, 1, atr_buffer) <= 0) return 0;
   
   double currentPrice = position.Type() == POSITION_TYPE_BUY ? symbol.Bid() : symbol.Ask();
   double atr = atr_buffer[0];
   double currentSL = position.StopLoss();
   double newSL = 0;
   
   if(position.Type() == POSITION_TYPE_BUY)
   {
      newSL = currentPrice - (atr * ATR_Multiplier);
      if(newSL > currentSL) return newSL;
   }
   else
   {
      newSL = currentPrice + (atr * ATR_Multiplier);
      if(newSL < currentSL || currentSL == 0) return newSL;
   }
   
   return 0;
}
```

## 📊 PARÂMETROS DE CONFIGURAÇÃO

### Risk Management
- `RiskPerTrade`: 1.0% (risco por trade)
- `MaxDailyLoss`: 5.0% (perda máxima diária)
- `MaxTotalLoss`: 10.0% (perda máxima total)
- `SafetyZonePercent`: 2.0% (zona de segurança)
- `MaxPositions`: 1 (máximo de posições)

### Entry System
- `ConfluenceLevel`: 3 (nível de confluência)
- `RSI_Period`: 14
- `RSI_Oversold`: 30.0
- `RSI_Overbought`: 70.0
- `MACD_Fast`: 12
- `MACD_Slow`: 26
- `MACD_Signal`: 9
- `EMA_Period`: 50
- `ATR_Multiplier`: 2.0

### Exit System
- `TrailingType`: TRAILING_ATR
- `TrailingStart`: 10.0 pontos
- `TrailingStep`: 5.0 pontos
- `BreakevenPoints`: 15.0 pontos
- `PartialTP1_Percent`: 30.0%
- `PartialTP1_Points`: 20.0 pontos

### Filters
- `NewsFilterMinutes`: 30 (minutos antes/depois)
- `SessionStartHour`: 8 (início sessão)
- `SessionEndHour`: 17 (fim sessão)
- `MinATR`: 0.5 (ATR mínimo)
- `MaxATR`: 3.0 (ATR máximo)
- `MaxSpread`: 2.0 pontos

## 🔍 VALIDAÇÕES E COMPLIANCE

### FTMO Requirements Checklist
- ✅ **Stop Loss Obrigatório**: Todas as posições têm SL
- ✅ **Controle de Drawdown**: Monitoramento 5%/10%
- ✅ **Position Sizing**: Baseado em risco por trade
- ✅ **News Filter**: Evita trading durante notícias
- ✅ **Session Control**: Limita horários de trading
- ✅ **Risk Management**: Fechamento automático
- ✅ **Equity Protection**: Zona de segurança

### Validações Técnicas
- **Stop Level Validation**: Verifica distância mínima
- **Lot Size Normalization**: Respeita min/max/step
- **Spread Validation**: Controla custos de transação
- **Indicator Validation**: Verifica dados válidos
- **Error Handling**: Tratamento robusto de erros

## 🚀 PERFORMANCE E OTIMIZAÇÃO

### Métricas Alvo
- **Sharpe Ratio**: > 1.5
- **Maximum Drawdown**: < 5%
- **Profit Factor**: > 1.3
- **Win Rate**: > 60%
- **Risk/Reward**: 1:1.5 (mínimo)

### Otimizações Implementadas
- **New Bar Detection**: Evita processamento desnecessário
- **Buffer Management**: Arrays otimizados
- **Memory Management**: Liberação adequada de handles
- **Error Handling**: Prevenção de crashes
- **Logging**: Debugging detalhado

## 🔧 MANUTENÇÃO E DEBUGGING

### Logs Importantes
- Inicialização de indicadores
- Execução de trades
- Ativação de trailing stops
- Alertas de risco
- Fechamento de posições

### Pontos de Monitoramento
- Equity vs. Balance
- Drawdown diário/total
- Performance dos filtros
- Eficácia do trailing stop
- Taxa de acerto dos sinais

---

*Documento técnico atualizado em: 18/08/2025*
*Versão do EA: 1.0.0*