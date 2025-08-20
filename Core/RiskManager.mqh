//+------------------------------------------------------------------+
//| RiskManager.mqh - Advanced Risk Management System              |
//| TradeDev_Master Elite Trading System                            |
//| Copyright 2024, Advanced Trading Solutions                      |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Estrutura de configuração de risco                              |
//+------------------------------------------------------------------+
struct RiskConfig
{
   double maxRiskPerTrade;        // Risco máximo por trade (% do capital)
   double maxDailyDrawdown;       // Drawdown máximo diário
   double maxWeeklyDrawdown;      // Drawdown máximo semanal
   double maxMonthlyDrawdown;     // Drawdown máximo mensal
   int maxConcurrentTrades;       // Máximo de trades simultâneos
   double maxCorrelationRisk;     // Risco máximo de correlação
   bool enableNewsFilter;         // Filtro de notícias
   bool enableTimeFilter;         // Filtro de horário
   double stopLossMultiplier;     // Multiplicador de stop loss
   double takeProfitMultiplier;   // Multiplicador de take profit
};

//+------------------------------------------------------------------+
//| Estrutura de métricas de risco                                  |
//+------------------------------------------------------------------+
struct RiskMetrics
{
   double currentDrawdown;        // Drawdown atual
   double dailyPnL;              // P&L diário
   double weeklyPnL;             // P&L semanal
   double monthlyPnL;            // P&L mensal
   int activeTrades;             // Trades ativos
   double totalExposure;         // Exposição total
   double correlationRisk;       // Risco de correlação
   datetime lastRiskCheck;       // Última verificação de risco
};

//+------------------------------------------------------------------+
//| Enumeração de níveis de risco                                   |
//+------------------------------------------------------------------+
enum RISK_LEVEL
{
   RISK_LOW,
   RISK_MEDIUM,
   RISK_HIGH,
   RISK_CRITICAL
};

//+------------------------------------------------------------------+
//| Classe de gerenciamento de risco                                |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
   RiskConfig        m_config;
   RiskMetrics       m_metrics;
   CTrade           m_trade;
   double           m_initialBalance;
   double           m_peakBalance;
   datetime         m_dayStart;
   datetime         m_weekStart;
   datetime         m_monthStart;
   
   // Arrays para histórico
   double           m_dailyPnLHistory[];
   double           m_drawdownHistory[];
   
   // Métodos privados
   bool UpdateMetrics(void);
   double CalculatePositionSize(string symbol, double riskAmount, double stopLoss);
   bool CheckCorrelationRisk(string symbol);
   bool CheckNewsFilter(void);
   bool CheckTimeFilter(void);
   RISK_LEVEL GetCurrentRiskLevel(void);
   void LogRiskEvent(string message, RISK_LEVEL level);
   
public:
   // Construtor e destrutor
   CRiskManager(void);
   ~CRiskManager(void);
   
   // Inicialização
   bool Initialize(double maxRiskPerTrade = 0.01, double maxDailyDrawdown = 0.05);
   bool SetConfig(RiskConfig &config);
   
   // Verificações principais
   bool CheckRiskLimits(void);
   bool CanOpenTrade(string symbol, ENUM_ORDER_TYPE orderType, double volume);
   double GetOptimalPositionSize(string symbol, double stopLoss, double riskPercent = 0.0);
   
   // Gestão de posições
   bool ValidateStopLoss(string symbol, ENUM_ORDER_TYPE orderType, double price, double stopLoss);
   bool ValidateTakeProfit(string symbol, ENUM_ORDER_TYPE orderType, double price, double takeProfit);
   bool AdjustPositionSize(ulong ticket, double newVolume);
   
   // Monitoramento
   void OnTick(void);
   void OnTradeOpen(ulong ticket);
   void OnTradeClose(ulong ticket);
   
   // Getters
   RiskMetrics GetMetrics(void) { return m_metrics; }
   RISK_LEVEL GetRiskLevel(void) { return GetCurrentRiskLevel(); }
   double GetMaxDrawdown(void);
   double GetSharpeRatio(void);
   
   // Relatórios
   bool GenerateRiskReport(string &report);
   bool ExportRiskData(string filename);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CRiskManager::CRiskManager(void)
{
   m_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_peakBalance = m_initialBalance;
   
   // Inicializar datas
   datetime current = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(current, dt);
   
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   m_dayStart = StructToTime(dt);
   
   dt.day_of_week = 1; // Segunda-feira
   m_weekStart = StructToTime(dt);
   
   dt.day = 1;
   m_monthStart = StructToTime(dt);
   
   // Configuração padrão
   m_config.maxRiskPerTrade = 0.01;
   m_config.maxDailyDrawdown = 0.05;
   m_config.maxWeeklyDrawdown = 0.10;
   m_config.maxMonthlyDrawdown = 0.15;
   m_config.maxConcurrentTrades = 5;
   m_config.maxCorrelationRisk = 0.7;
   m_config.enableNewsFilter = true;
   m_config.enableTimeFilter = true;
   m_config.stopLossMultiplier = 1.0;
   m_config.takeProfitMultiplier = 2.0;
   
   ZeroMemory(m_metrics);
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CRiskManager::~CRiskManager(void)
{
   ArrayFree(m_dailyPnLHistory);
   ArrayFree(m_drawdownHistory);
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CRiskManager::Initialize(double maxRiskPerTrade = 0.01, double maxDailyDrawdown = 0.05)
{
   m_config.maxRiskPerTrade = maxRiskPerTrade;
   m_config.maxDailyDrawdown = maxDailyDrawdown;
   
   if(!UpdateMetrics())
   {
      Print("Failed to initialize risk metrics");
      return false;
   }
   
   Print("Risk Manager initialized successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Verificar limites de risco                                      |
//+------------------------------------------------------------------+
bool CRiskManager::CheckRiskLimits(void)
{
   if(!UpdateMetrics())
      return false;
   
   // Verificar drawdown diário
   if(m_metrics.currentDrawdown >= m_config.maxDailyDrawdown)
   {
      LogRiskEvent("Daily drawdown limit exceeded: " + DoubleToString(m_metrics.currentDrawdown * 100, 2) + "%", RISK_CRITICAL);
      return false;
   }
   
   // Verificar número de trades ativos
   if(m_metrics.activeTrades >= m_config.maxConcurrentTrades)
   {
      LogRiskEvent("Maximum concurrent trades reached: " + IntegerToString(m_metrics.activeTrades), RISK_HIGH);
      return false;
   }
   
   // Verificar filtros de tempo e notícias
   if(m_config.enableTimeFilter && !CheckTimeFilter())
   {
      return false;
   }
   
   if(m_config.enableNewsFilter && !CheckNewsFilter())
   {
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar se pode abrir trade                                   |
//+------------------------------------------------------------------+
bool CRiskManager::CanOpenTrade(string symbol, ENUM_ORDER_TYPE orderType, double volume)
{
   if(!CheckRiskLimits())
      return false;
   
   // Verificar risco de correlação
   if(!CheckCorrelationRisk(symbol))
   {
      LogRiskEvent("Correlation risk too high for symbol: " + symbol, RISK_HIGH);
      return false;
   }
   
   // Verificar se o volume está dentro dos limites
   double maxVolume = GetOptimalPositionSize(symbol, 0, m_config.maxRiskPerTrade);
   if(volume > maxVolume)
   {
      LogRiskEvent("Volume exceeds risk limits: " + DoubleToString(volume, 2), RISK_MEDIUM);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calcular tamanho ótimo da posição                               |
//+------------------------------------------------------------------+
double CRiskManager::GetOptimalPositionSize(string symbol, double stopLoss, double riskPercent = 0.0)
{
   if(riskPercent == 0.0)
      riskPercent = m_config.maxRiskPerTrade;
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * riskPercent;
   
   if(stopLoss == 0.0)
   {
      // Se não há stop loss definido, usar um padrão baseado no ATR
      double atr = iATR(symbol, PERIOD_H1, 14, 0);
      stopLoss = atr * 2.0; // 2x ATR como stop loss padrão
   }
   
   return CalculatePositionSize(symbol, riskAmount, stopLoss);
}

//+------------------------------------------------------------------+
//| Calcular tamanho da posição                                     |
//+------------------------------------------------------------------+
double CRiskManager::CalculatePositionSize(string symbol, double riskAmount, double stopLoss)
{
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double volumeStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   
   if(stopLoss <= 0 || tickValue <= 0 || tickSize <= 0)
      return minVolume;
   
   double stopLossInTicks = stopLoss / tickSize;
   double riskPerLot = stopLossInTicks * tickValue;
   
   if(riskPerLot <= 0)
      return minVolume;
   
   double optimalVolume = riskAmount / riskPerLot;
   
   // Ajustar para o step de volume
   optimalVolume = MathFloor(optimalVolume / volumeStep) * volumeStep;
   
   // Garantir que está dentro dos limites
   optimalVolume = MathMax(optimalVolume, minVolume);
   optimalVolume = MathMin(optimalVolume, maxVolume);
   
   return optimalVolume;
}

//+------------------------------------------------------------------+
//| Atualizar métricas de risco                                     |
//+------------------------------------------------------------------+
bool CRiskManager::UpdateMetrics(void)
{
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Atualizar peak balance
   if(currentBalance > m_peakBalance)
      m_peakBalance = currentBalance;
   
   // Calcular drawdown atual
   m_metrics.currentDrawdown = (m_peakBalance - currentEquity) / m_peakBalance;
   
   // Calcular P&L diário
   m_metrics.dailyPnL = currentBalance - m_initialBalance;
   
   // Contar trades ativos
   m_metrics.activeTrades = PositionsTotal();
   
   // Calcular exposição total
   m_metrics.totalExposure = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByIndex(i))
      {
         double volume = PositionGetDouble(POSITION_VOLUME);
         double price = PositionGetDouble(POSITION_PRICE_OPEN);
         m_metrics.totalExposure += volume * price;
      }
   }
   
   m_metrics.lastRiskCheck = TimeCurrent();
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar filtro de tempo                                       |
//+------------------------------------------------------------------+
bool CRiskManager::CheckTimeFilter(void)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Evitar trading durante rollover (22:00 - 02:00 GMT)
   if(dt.hour >= 22 || dt.hour <= 2)
      return false;
   
   // Evitar trading em fins de semana
   if(dt.day_of_week == 0 || dt.day_of_week == 6)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar filtro de notícias                                    |
//+------------------------------------------------------------------+
bool CRiskManager::CheckNewsFilter(void)
{
   // Implementar verificação de calendário econômico
   // Por enquanto, retorna true (sem filtro ativo)
   return true;
}

//+------------------------------------------------------------------+
//| Verificar risco de correlação                                   |
//+------------------------------------------------------------------+
bool CRiskManager::CheckCorrelationRisk(string symbol)
{
   // Implementar análise de correlação entre símbolos
   // Por enquanto, retorna true (sem verificação ativa)
   return true;
}

//+------------------------------------------------------------------+
//| Obter nível de risco atual                                      |
//+------------------------------------------------------------------+
RISK_LEVEL CRiskManager::GetCurrentRiskLevel(void)
{
   if(m_metrics.currentDrawdown >= m_config.maxDailyDrawdown * 0.8)
      return RISK_CRITICAL;
   else if(m_metrics.currentDrawdown >= m_config.maxDailyDrawdown * 0.6)
      return RISK_HIGH;
   else if(m_metrics.currentDrawdown >= m_config.maxDailyDrawdown * 0.3)
      return RISK_MEDIUM;
   else
      return RISK_LOW;
}

//+------------------------------------------------------------------+
//| Log de eventos de risco                                         |
//+------------------------------------------------------------------+
void CRiskManager::LogRiskEvent(string message, RISK_LEVEL level)
{
   string levelStr = "LOW";
   if(level == RISK_MEDIUM) levelStr = "MEDIUM";
   if(level == RISK_HIGH) levelStr = "HIGH";
   if(level == RISK_CRITICAL) levelStr = "CRITICAL";
   
   string logMsg = TimeToString(TimeCurrent()) + " [RISK-" + levelStr + "] " + message;
   Print(logMsg);
   
   // Salvar em arquivo de log de risco
   int handle = FileOpen("RiskManager.log", FILE_WRITE|FILE_TXT|FILE_ANSI, "\t");
   if(handle != INVALID_HANDLE)
   {
      FileWrite(handle, logMsg);
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
//| Processamento no tick                                           |
//+------------------------------------------------------------------+
void CRiskManager::OnTick(void)
{
   UpdateMetrics();
   
   // Verificar se alguma posição precisa de ajuste de risco
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByIndex(i))
      {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         double currentPnL = PositionGetDouble(POSITION_PROFIT);
         
         // Implementar trailing stop ou outras regras de gestão
         // baseadas no risco atual
      }
   }
}

//+------------------------------------------------------------------+
//| Gerar relatório de risco                                        |
//+------------------------------------------------------------------+
bool CRiskManager::GenerateRiskReport(string &report)
{
   UpdateMetrics();
   
   report = "\n=== RISK MANAGEMENT REPORT ===\n";
   report += "Generated: " + TimeToString(TimeCurrent()) + "\n\n";
   
   report += "CURRENT METRICS:\n";
   report += "- Current Drawdown: " + DoubleToString(m_metrics.currentDrawdown * 100, 2) + "%\n";
   report += "- Daily P&L: $" + DoubleToString(m_metrics.dailyPnL, 2) + "\n";
   report += "- Active Trades: " + IntegerToString(m_metrics.activeTrades) + "\n";
   report += "- Total Exposure: $" + DoubleToString(m_metrics.totalExposure, 2) + "\n";
   report += "- Risk Level: " + EnumToString(GetCurrentRiskLevel()) + "\n\n";
   
   report += "RISK LIMITS:\n";
   report += "- Max Risk Per Trade: " + DoubleToString(m_config.maxRiskPerTrade * 100, 2) + "%\n";
   report += "- Max Daily Drawdown: " + DoubleToString(m_config.maxDailyDrawdown * 100, 2) + "%\n";
   report += "- Max Concurrent Trades: " + IntegerToString(m_config.maxConcurrentTrades) + "\n";
   
   return true;
}

//+------------------------------------------------------------------+