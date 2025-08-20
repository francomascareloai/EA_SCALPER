# GUIA DE COMPLIANCE FTMO - EA FTMO SCALPER ELITE

## 📋 REQUISITOS FTMO OBRIGATÓRIOS

### 1. **REGRAS DE RISCO FUNDAMENTAIS**

#### Maximum Daily Loss (Perda Máxima Diária)
- **Limite**: 5% do saldo inicial
- **Cálculo**: Balance inicial × 5%
- **Implementação**: Monitoramento contínuo do equity
- **Ação**: Fechamento automático de todas as posições

```mql5
// Exemplo: Conta de $100,000
// Perda máxima diária: $5,000
// Se equity cair para $95,000 ou menos = VIOLAÇÃO

if(currentEquity <= (initialBalance - (initialBalance * MaxDailyLoss / 100)))
{
   CloseAllPositions();
   canTrade = false;
}
```

#### Maximum Loss (Perda Máxima Total)
- **Limite**: 10% do saldo inicial
- **Cálculo**: Balance inicial × 10%
- **Implementação**: Controle de drawdown total
- **Ação**: Encerramento da conta

```mql5
// Exemplo: Conta de $100,000
// Perda máxima total: $10,000
// Se equity cair para $90,000 ou menos = VIOLAÇÃO

if(currentEquity <= (initialBalance - (initialBalance * MaxTotalLoss / 100)))
{
   CloseAllPositions();
   canTrade = false;
   // Conta encerrada
}
```

### 2. **REGRAS DE TRADING OBRIGATÓRIAS**

#### Stop Loss Obrigatório
- **Regra**: Todas as posições DEVEM ter Stop Loss
- **Exceção**: Nenhuma
- **Implementação**: Validação antes da abertura

```mql5
// Validação obrigatória
if(signal.stopLoss == 0 || signal.stopLoss == EMPTY_VALUE)
{
   Print("ERRO: Stop Loss obrigatório para FTMO compliance");
   return false;
}
```

#### Minimum Stop Loss Distance
- **Regra**: SL deve respeitar Stop Level do broker
- **Cálculo**: Symbol.StopsLevel() × Symbol.Point()
- **Implementação**: Validação automática

```mql5
bool IsValidStopLevel(double price, double sl, int type)
{
   double minDistance = symbol.StopsLevel() * symbol.Point();
   
   if(type == ORDER_TYPE_BUY)
      return (price - sl) >= minDistance;
   else
      return (sl - price) >= minDistance;
}
```

### 3. **REGRAS DE POSICIONAMENTO**

#### Maximum Risk per Trade
- **Recomendação**: 1-2% do saldo por trade
- **Implementação**: Cálculo automático de lot size

```mql5
double CalculatePositionSize(double entryPrice, double stopLoss, double riskPercent)
{
   double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent / 100;
   double slDistance = MathAbs(entryPrice - stopLoss);
   double tickValue = symbol.TickValue();
   double tickSize = symbol.TickSize();
   
   double lotSize = riskAmount / (slDistance / tickSize * tickValue);
   return NormalizeLots(lotSize);
}
```

#### Maximum Positions
- **Recomendação**: Limitar número de posições simultâneas
- **Implementação**: Controle antes da abertura

```mql5
if(PositionsTotal() >= MaxPositions)
{
   Print("Máximo de posições atingido: ", MaxPositions);
   return false;
}
```

### 4. **REGRAS DE TEMPO E SESSÃO**

#### Trading Hours
- **Recomendação**: Evitar trading fora de sessões principais
- **Implementação**: Filtro de horário

```mql5
bool IsValidTradingTime()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Evitar fins de semana
   if(dt.day_of_week == 0 || dt.day_of_week == 6)
      return false;
   
   // Verificar horário de sessão
   if(dt.hour < SessionStartHour || dt.hour > SessionEndHour)
      return false;
   
   return true;
}
```

#### News Trading
- **Recomendação**: Evitar trading durante notícias de alto impacto
- **Implementação**: Filtro de notícias

```mql5
bool IsNewsTime()
{
   // Verificar se estamos próximos de notícias importantes
   // Implementação baseada em calendário econômico
   return false; // Simplificado
}
```

## 🎯 ESTRATÉGIAS APROVADAS PARA FTMO

### ✅ **ESTRATÉGIAS RECOMENDADAS**

#### 1. Trend Following
- **Características**: Segue tendências estabelecidas
- **Risk/Reward**: 1:2 ou melhor
- **Win Rate**: 40-60%
- **Drawdown**: Baixo a moderado

#### 2. Breakout Trading
- **Características**: Entrada em rompimentos confirmados
- **Risk/Reward**: 1:1.5 ou melhor
- **Win Rate**: 50-70%
- **Drawdown**: Moderado

#### 3. Scalping Conservativo
- **Características**: Trades rápidos com SL apertado
- **Risk/Reward**: 1:1 mínimo
- **Win Rate**: 60-80%
- **Drawdown**: Baixo

#### 4. SMC/ICT (Smart Money Concepts)
- **Características**: Análise institucional
- **Risk/Reward**: 1:3 ou melhor
- **Win Rate**: 30-50%
- **Drawdown**: Baixo

### ❌ **ESTRATÉGIAS PROIBIDAS**

#### 1. Grid Trading
- **Problema**: Pode gerar grandes drawdowns
- **Risco**: Violação da regra de 5%/10%
- **Status**: **PROIBIDO**

#### 2. Martingale
- **Problema**: Aumento exponencial de risco
- **Risco**: Perda total da conta
- **Status**: **PROIBIDO**

#### 3. Hedging Agressivo
- **Problema**: Pode mascarar perdas reais
- **Risco**: Violação de regras
- **Status**: **RESTRITO**

#### 4. High Frequency Trading
- **Problema**: Pode ser considerado manipulação
- **Risco**: Desqualificação
- **Status**: **RESTRITO**

## 📊 MÉTRICAS DE PERFORMANCE FTMO

### **PROFIT TARGET (Meta de Lucro)**

#### Challenge Phase
- **Meta**: 8% em 30 dias
- **Cálculo**: Balance inicial × 8%
- **Exemplo**: $100,000 → $8,000 lucro

#### Verification Phase
- **Meta**: 5% em 60 dias
- **Cálculo**: Balance inicial × 5%
- **Exemplo**: $100,000 → $5,000 lucro

### **MÉTRICAS DE QUALIDADE**

#### Sharpe Ratio
- **Mínimo**: 1.0
- **Recomendado**: > 1.5
- **Cálculo**: (Retorno - Risk Free) / Volatilidade

#### Maximum Drawdown
- **Máximo**: 5% (diário) / 10% (total)
- **Recomendado**: < 3%
- **Monitoramento**: Contínuo

#### Profit Factor
- **Mínimo**: 1.2
- **Recomendado**: > 1.5
- **Cálculo**: Lucros Totais / Perdas Totais

#### Win Rate
- **Mínimo**: 40%
- **Recomendado**: > 55%
- **Balanceamento**: Com Risk/Reward adequado

## 🔧 IMPLEMENTAÇÃO NO EA

### **CLASSE DE COMPLIANCE**

```mql5
class CFTMOCompliance
{
private:
   double m_initialBalance;
   double m_maxDailyLoss;
   double m_maxTotalLoss;
   bool m_canTrade;
   
public:
   bool Initialize(double initialBalance)
   {
      m_initialBalance = initialBalance;
      m_maxDailyLoss = initialBalance * 0.05; // 5%
      m_maxTotalLoss = initialBalance * 0.10; // 10%
      m_canTrade = true;
      return true;
   }
   
   bool CheckCompliance()
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      // Verificar perda máxima total
      if(currentEquity <= (m_initialBalance - m_maxTotalLoss))
      {
         m_canTrade = false;
         Alert("FTMO VIOLATION: Maximum Total Loss Exceeded!");
         return false;
      }
      
      // Verificar perda máxima diária
      double dailyPnL = GetDailyPnL();
      if(dailyPnL <= -m_maxDailyLoss)
      {
         m_canTrade = false;
         Alert("FTMO VIOLATION: Maximum Daily Loss Exceeded!");
         CloseAllPositions();
         return false;
      }
      
      return m_canTrade;
   }
   
   double GetDailyPnL()
   {
      // Implementar cálculo de P&L diário
      return 0; // Simplificado
   }
};
```

### **VALIDAÇÃO DE TRADES**

```mql5
bool ValidateFTMOTrade(STradeSignal &signal)
{
   // 1. Verificar Stop Loss obrigatório
   if(signal.stopLoss == 0)
   {
      Print("FTMO ERROR: Stop Loss is mandatory");
      return false;
   }
   
   // 2. Verificar distância mínima do SL
   if(!IsValidStopLevel(signal.entryPrice, signal.stopLoss, signal.direction))
   {
      Print("FTMO ERROR: Stop Loss too close");
      return false;
   }
   
   // 3. Verificar tamanho da posição
   if(signal.lotSize > GetMaxLotSize())
   {
      Print("FTMO ERROR: Position size too large");
      return false;
   }
   
   // 4. Verificar compliance geral
   if(!ftmoCompliance.CheckCompliance())
   {
      Print("FTMO ERROR: Compliance violation");
      return false;
   }
   
   return true;
}
```

## 📈 RELATÓRIOS E MONITORAMENTO

### **DASHBOARD DE COMPLIANCE**

```mql5
void PrintFTMOStatus()
{
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double dailyPnL = GetDailyPnL();
   double totalPnL = currentEquity - m_initialBalance;
   
   Print("=== FTMO COMPLIANCE STATUS ===");
   Print("Initial Balance: ", m_initialBalance);
   Print("Current Equity: ", currentEquity);
   Print("Daily P&L: ", dailyPnL, " (Max: ", -m_maxDailyLoss, ")");
   Print("Total P&L: ", totalPnL, " (Max: ", -m_maxTotalLoss, ")");
   Print("Can Trade: ", m_canTrade ? "YES" : "NO");
   Print("===============================");
}
```

### **ALERTAS AUTOMÁTICOS**

```mql5
void CheckFTMOAlerts()
{
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double dailyPnL = GetDailyPnL();
   
   // Alerta de proximidade do limite diário (80%)
   if(dailyPnL <= -(m_maxDailyLoss * 0.8))
   {
      SendAlert(ALERT_TYPE_PUSH, "WARNING: Approaching daily loss limit!");
   }
   
   // Alerta de proximidade do limite total (80%)
   double totalLoss = m_initialBalance - currentEquity;
   if(totalLoss >= (m_maxTotalLoss * 0.8))
   {
      SendAlert(ALERT_TYPE_EMAIL, "WARNING: Approaching total loss limit!");
   }
}
```

## ✅ CHECKLIST DE COMPLIANCE

### **PRÉ-TRADING**
- [ ] Stop Loss configurado
- [ ] Position size calculado corretamente
- [ ] Compliance verificado
- [ ] Horário de trading válido
- [ ] Filtros de notícias ativos

### **DURANTE TRADING**
- [ ] Monitoramento contínuo de equity
- [ ] Verificação de drawdown
- [ ] Alertas de proximidade de limites
- [ ] Trailing stop ativo
- [ ] Take profit configurado

### **PÓS-TRADING**
- [ ] Relatório de performance
- [ ] Análise de compliance
- [ ] Backup de dados
- [ ] Atualização de estatísticas
- [ ] Preparação para próxima sessão

---

*Guia de Compliance FTMO atualizado em: 18/08/2025*
*Baseado nas regras oficiais FTMO 2025*