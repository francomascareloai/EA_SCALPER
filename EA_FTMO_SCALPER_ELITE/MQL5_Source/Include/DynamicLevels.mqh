//+------------------------------------------------------------------+
//|                                             DynamicLevels.mqh |
//|                                  Copyright 2024, TradeDev_Master |
//|                            Sistema Dinâmico de SL/TP Avançado |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "1.00"
#property strict

#include "..\Source\Core\DataStructures.mqh"
#include "Logger.mqh"

//+------------------------------------------------------------------+
//| Estrutura para dados de níveis dinâmicos                       |
//+------------------------------------------------------------------+
struct SDynamicLevels
{
   double   stopLoss;           // Nível de Stop Loss calculado
   double   takeProfit;         // Nível de Take Profit calculado
   double   atrValue;           // Valor ATR usado no cálculo
   double   riskRewardRatio;    // Ratio Risco/Recompensa
   double   volatilityFactor;   // Fator de volatilidade
   double   structuralLevel;    // Nível estrutural de referência
   string   calculationMethod; // Método de cálculo usado
   datetime timestamp;          // Timestamp do cálculo
};

//+------------------------------------------------------------------+
//| Enumeração para métodos de cálculo                             |
//+------------------------------------------------------------------+
enum ENUM_CALCULATION_METHOD
{
   METHOD_ATR_ONLY,        // Baseado apenas em ATR
   METHOD_STRUCTURAL,      // Baseado em níveis estruturais
   METHOD_HYBRID,          // Combinação ATR + Estrutural
   METHOD_ADAPTIVE         // Adaptativo baseado em volatilidade
};

//+------------------------------------------------------------------+
//| Enumeração para tipos de estrutura                             |
//+------------------------------------------------------------------+
enum ENUM_STRUCTURE_TYPE
{
   STRUCTURE_SWING_HIGH,   // Swing High
   STRUCTURE_SWING_LOW,    // Swing Low
   STRUCTURE_ORDER_BLOCK,  // Order Block
   STRUCTURE_LIQUIDITY,    // Nível de Liquidez
   STRUCTURE_FVG          // Fair Value Gap
};

//+------------------------------------------------------------------+
//| Estrutura de resultado dos níveis                               |
//+------------------------------------------------------------------+
struct SLevelResult
{
   bool     isValid;            // Se o resultado é válido
   double   stopLoss;           // Nível de Stop Loss
   double   takeProfit;         // Nível de Take Profit
   double   riskReward;         // Ratio Risco/Recompensa
   string   method;             // Método usado no cálculo
   datetime timestamp;          // Timestamp do cálculo
};

//+------------------------------------------------------------------+
//| Classe para cálculo dinâmico de níveis SL/TP                   |
//+------------------------------------------------------------------+
class CDynamicLevels
{
private:
   // Parâmetros de configuração
   int               m_atrPeriod;              // Período do ATR
   double            m_atrMultiplierSL;        // Multiplicador ATR para SL
   double            m_atrMultiplierTP;        // Multiplicador ATR para TP
   double            m_minRiskReward;          // Ratio mínimo risco/recompensa
   double            m_maxRiskReward;          // Ratio máximo risco/recompensa
   double            m_volatilityThreshold;    // Limite de volatilidade
   ENUM_CALCULATION_METHOD m_defaultMethod;   // Método padrão de cálculo
   
   // Dados de mercado
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   double            m_point;
   double            m_tickSize;
   int               m_digits;
   
   // Handles de indicadores
   int               m_atrHandle;
   
   // Dados históricos
   SDynamicLevels    m_lastCalculation;
   
   // Utilitários
   CLogger*          m_logger;
   
public:
   // Construtor e Destrutor
                     CDynamicLevels(void);
                    ~CDynamicLevels(void);
   
   // Inicialização
   bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger);
   void              Deinitialize(void);
   
   // Configuração
   void              SetATRParameters(int period, double slMultiplier, double tpMultiplier);
   void              SetATRPeriod(int period);
   void              SetMultipliers(double slMultiplier, double tpMultiplier);
   void              SetRiskRewardRange(double minRR, double maxRR);
   void              SetVolatilityThreshold(double threshold);
   void              SetDefaultMethod(ENUM_CALCULATION_METHOD method);
   
   // Cálculo principal
   SDynamicLevels    CalculateLevels(double entryPrice, ENUM_ORDER_TYPE orderType,
                                   ENUM_CALCULATION_METHOD method = METHOD_HYBRID,
                                   double structuralLevel = 0.0);
   
   // Métodos específicos
   double            CalculateATRStopLoss(double entryPrice, ENUM_ORDER_TYPE orderType);
   double            CalculateATRTakeProfit(double entryPrice, ENUM_ORDER_TYPE orderType, double stopLoss);
   double            CalculateStructuralStopLoss(double entryPrice, ENUM_ORDER_TYPE orderType, double structuralLevel);
   double            CalculateStructuralTakeProfit(double entryPrice, ENUM_ORDER_TYPE orderType, double stopLoss);
   
   // Análise de volatilidade
   double            GetCurrentATR(void);
   double            GetVolatilityFactor(void);
   bool              IsHighVolatility(void);
   
   // Níveis estruturais
   double            FindNearestSwingHigh(int lookback = 20);
   double            FindNearestSwingLow(int lookback = 20);
   double            FindNearestStructuralLevel(ENUM_ORDER_TYPE orderType, ENUM_STRUCTURE_TYPE structType);
   
   // Validação
   bool              ValidateStopLoss(double entryPrice, double stopLoss, ENUM_ORDER_TYPE orderType);
   bool              ValidateTakeProfit(double entryPrice, double takeProfit, ENUM_ORDER_TYPE orderType);
   double            NormalizePrice(double price);
   
   // Utilitários
   SDynamicLevels    GetLastCalculation(void) { return m_lastCalculation; }
   double            CalculateRiskRewardRatio(double entryPrice, double stopLoss, double takeProfit, ENUM_ORDER_TYPE orderType);
   string            GetCalculationDetails(SDynamicLevels &levels);
   
   // Métodos adicionais para configuração
   void              SetStopLossMethod(ENUM_CALCULATION_METHOD method);
   void              SetTakeProfitMethod(ENUM_CALCULATION_METHOD method);
   SDynamicLevels    GetOptimalLevels(double entryPrice, ENUM_ORDER_TYPE orderType);
   SDynamicLevels    CalculateAdaptiveLevels(double entryPrice, ENUM_ORDER_TYPE orderType);
   
   // Métodos FTMO Risk Management
   bool              ValidateFTMORiskManagement(double entryPrice, double stopLoss, double lotSize);
   double            CalculateFTMOLotSize(double entryPrice, double stopLoss, double riskPercent = 1.0);
   bool              CheckDrawdownLimits(void);
   double            GetCurrentDrawdown(void);
   bool              ValidateDailyLossLimit(void);
   double            GetCurrentEquity(void);
   bool              ValidateEquityProtection(void);
   double            CalculateEquityRisk(void);
   
private:
   // Métodos internos
   bool              InitializeIndicators(void);
   double            GetATRValue(int shift = 0);
   double            AdaptMultiplierToVolatility(double baseMultiplier);
   double            FindOptimalTakeProfit(double entryPrice, double stopLoss, ENUM_ORDER_TYPE orderType);
   
   void              UpdateLastCalculation(SDynamicLevels &levels);
   string            MethodToString(ENUM_CALCULATION_METHOD method);
   
   // Métodos específicos para testes
   double            CalculateDynamicSL(ENUM_ORDER_TYPE orderType, double entryPrice);
   double            CalculateDynamicTP(ENUM_ORDER_TYPE orderType, double entryPrice);
   bool              UpdateLevels(void);
   SDynamicLevels    GetLevelsConfig(void);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CDynamicLevels::CDynamicLevels(void)
{
   // Parâmetros padrão
   m_atrPeriod = 14;
   m_atrMultiplierSL = 2.0;
   m_atrMultiplierTP = 3.0;
   m_minRiskReward = 1.5;
   m_maxRiskReward = 3.0;
   m_volatilityThreshold = 0.0015; // 150 pips para XAUUSD
   m_defaultMethod = METHOD_HYBRID;
   
   // Inicializar dados
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_point = 0.0;
   m_tickSize = 0.0;
   m_digits = 0;
   
   m_atrHandle = INVALID_HANDLE;
   m_logger = NULL;
   
   ZeroMemory(m_lastCalculation);
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CDynamicLevels::~CDynamicLevels(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CDynamicLevels::Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   m_logger = logger;
   
   // Obter propriedades do símbolo
   m_point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   m_tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
   m_digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   
   // Inicializar indicadores
   if(!InitializeIndicators())
   {
      if(m_logger != NULL)
         m_logger.LogError("DynamicLevels", "Falha ao inicializar indicadores");
      return false;
   }
   
   if(m_logger != NULL)
      m_logger.LogInfo("DynamicLevels", "Sistema de níveis dinâmicos inicializado para " + symbol);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinicialização                                                  |
//+------------------------------------------------------------------+
void CDynamicLevels::Deinitialize(void)
{
   if(m_atrHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atrHandle);
      m_atrHandle = INVALID_HANDLE;
   }
   
   if(m_logger != NULL)
      m_logger.LogInfo("DynamicLevels", "Sistema de níveis dinâmicos deinicializado");
}

//+------------------------------------------------------------------+
//| Configurar parâmetros ATR                                       |
//+------------------------------------------------------------------+
void CDynamicLevels::SetATRParameters(int period, double slMultiplier, double tpMultiplier)
{
   m_atrPeriod = MathMax(1, period);
   m_atrMultiplierSL = MathMax(0.1, slMultiplier);
   m_atrMultiplierTP = MathMax(0.1, tpMultiplier);
   
   // Reinicializar ATR se necessário
   if(m_atrHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atrHandle);
      m_atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
   }
   
   if(m_logger != NULL)
   {
      string msg = StringFormat("Parâmetros ATR atualizados: Período=%d, SL_Mult=%.2f, TP_Mult=%.2f",
                               m_atrPeriod, m_atrMultiplierSL, m_atrMultiplierTP);
      m_logger.LogInfo("DynamicLevels", msg);
   }
}

//+------------------------------------------------------------------+
//| Configurar range de risco/recompensa                           |
//+------------------------------------------------------------------+
void CDynamicLevels::SetRiskRewardRange(double minRR, double maxRR)
{
   m_minRiskReward = MathMax(0.5, minRR);
   m_maxRiskReward = MathMax(m_minRiskReward, maxRR);
   
   if(m_logger != NULL)
   {
      string msg = StringFormat("Range R/R atualizado: Min=%.2f, Max=%.2f", m_minRiskReward, m_maxRiskReward);
      m_logger.LogInfo("DynamicLevels", msg);
   }
}

//+------------------------------------------------------------------+
//| Configurar limite de volatilidade                              |
//+------------------------------------------------------------------+
void CDynamicLevels::SetVolatilityThreshold(double threshold)
{
   m_volatilityThreshold = MathMax(0.0001, threshold);
   
   if(m_logger != NULL)
   {
      string msg = StringFormat("Limite de volatilidade atualizado: %.5f", m_volatilityThreshold);
      m_logger.LogInfo("DynamicLevels", msg);
   }
}

//+------------------------------------------------------------------+
//| Configurar método padrão                                       |
//+------------------------------------------------------------------+
void CDynamicLevels::SetDefaultMethod(ENUM_CALCULATION_METHOD method)
{
   m_defaultMethod = method;
   
   if(m_logger != NULL)
   {
      string msg = "Método padrão atualizado: " + MethodToString(method);
      m_logger.LogInfo("DynamicLevels", msg);
   }
}

//+------------------------------------------------------------------+
//| Calcular níveis dinâmicos                                      |
//+------------------------------------------------------------------+
SDynamicLevels CDynamicLevels::CalculateLevels(double entryPrice, ENUM_ORDER_TYPE orderType,
                                              ENUM_CALCULATION_METHOD method, double structuralLevel)
{
   SDynamicLevels levels;
   ZeroMemory(levels);
   
   levels.timestamp = TimeCurrent();
   levels.calculationMethod = MethodToString(method);
   levels.atrValue = GetCurrentATR();
   levels.volatilityFactor = GetVolatilityFactor();
   
   switch(method)
   {
      case METHOD_ATR_ONLY:
         levels.stopLoss = CalculateATRStopLoss(entryPrice, orderType);
         levels.takeProfit = CalculateATRTakeProfit(entryPrice, orderType, levels.stopLoss);
         break;
         
      case METHOD_STRUCTURAL:
         if(structuralLevel > 0)
         {
            levels.structuralLevel = structuralLevel;
            levels.stopLoss = CalculateStructuralStopLoss(entryPrice, orderType, structuralLevel);
         }
         else
         {
            levels.stopLoss = CalculateATRStopLoss(entryPrice, orderType);
         }
         levels.takeProfit = CalculateStructuralTakeProfit(entryPrice, orderType, levels.stopLoss);
         break;
         
      case METHOD_HYBRID:
         // Combinar ATR e estrutural
         double atrSL = CalculateATRStopLoss(entryPrice, orderType);
         double structSL = (structuralLevel > 0) ? 
                          CalculateStructuralStopLoss(entryPrice, orderType, structuralLevel) : atrSL;
         
         // Usar o mais conservador (mais próximo do preço de entrada)
         if(orderType == ORDER_TYPE_BUY)
            levels.stopLoss = MathMax(atrSL, structSL);
         else
            levels.stopLoss = MathMin(atrSL, structSL);
            
         levels.takeProfit = FindOptimalTakeProfit(entryPrice, levels.stopLoss, orderType);
         break;
         
      case METHOD_ADAPTIVE:
         // Adaptar baseado na volatilidade
         double adaptedMultiplier = AdaptMultiplierToVolatility(m_atrMultiplierSL);
         double atr = GetCurrentATR();
         
         if(orderType == ORDER_TYPE_BUY)
            levels.stopLoss = entryPrice - (atr * adaptedMultiplier);
         else
            levels.stopLoss = entryPrice + (atr * adaptedMultiplier);
            
         levels.takeProfit = FindOptimalTakeProfit(entryPrice, levels.stopLoss, orderType);
         break;
   }
   
   // Normalizar preços
   levels.stopLoss = NormalizePrice(levels.stopLoss);
   levels.takeProfit = NormalizePrice(levels.takeProfit);
   
   // Calcular ratio risco/recompensa
   levels.riskRewardRatio = CalculateRiskRewardRatio(entryPrice, levels.stopLoss, levels.takeProfit, orderType);
   
   // Validar níveis
   if(!ValidateStopLoss(entryPrice, levels.stopLoss, orderType) ||
      !ValidateTakeProfit(entryPrice, levels.takeProfit, orderType))
   {
      if(m_logger != NULL)
         m_logger.LogWarning("DynamicLevels", "Níveis calculados falharam na validação");
   }
   
   UpdateLastCalculation(levels);
   
   if(m_logger != NULL)
   {
      string msg = StringFormat("Níveis calculados: Entry=%.5f, SL=%.5f, TP=%.5f, RR=%.2f, ATR=%.5f",
                               entryPrice, levels.stopLoss, levels.takeProfit, 
                               levels.riskRewardRatio, levels.atrValue);
      m_logger.LogDebug("DynamicLevels", msg);
   }
   
   return levels;
}

//+------------------------------------------------------------------+
//| Calcular Stop Loss dinâmico                                    |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateDynamicSL(ENUM_ORDER_TYPE orderType, double entryPrice)
{
   SDynamicLevels levels = CalculateLevels(entryPrice, orderType, m_stopLossMethod);
   return levels.stopLoss;
}

//+------------------------------------------------------------------+
//| Calcular Take Profit dinâmico                                  |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateDynamicTP(ENUM_ORDER_TYPE orderType, double entryPrice)
{
   SDynamicLevels levels = CalculateLevels(entryPrice, orderType, m_takeProfitMethod);
   return levels.takeProfit;
}

//+------------------------------------------------------------------+
//| Atualizar níveis                                               |
//+------------------------------------------------------------------+
bool CDynamicLevels::UpdateLevels(void)
{
   // Atualizar dados de mercado
   double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   if(currentPrice <= 0)
      return false;
   
   // Atualizar timestamp da última atualização
   m_lastUpdate = TimeCurrent();
   
   if(m_logger != NULL)
   {
      m_logger.LogInfo("DynamicLevels", "Níveis atualizados com sucesso");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter configuração dos níveis                                  |
//+------------------------------------------------------------------+
SDynamicLevels CDynamicLevels::GetLevelsConfig(void)
{
   SDynamicLevels config;
   ZeroMemory(config);
   
   // Preencher configuração atual
   config.atrMultiplier = m_atrMultiplier;
   config.structuralMultiplier = m_structuralMultiplier;
   config.calculationMethod = MethodToString(m_stopLossMethod) + "/" + MethodToString(m_takeProfitMethod);
   config.timestamp = TimeCurrent();
   
   // Valores fictícios para demonstrar configuração
   config.stopLoss = 0.0;
   config.takeProfit = 0.0;
   config.riskReward = m_riskRewardRatio;
   config.confidence = 85.0; // Confiança padrão
   
   return config;
}

//+------------------------------------------------------------------+
//| Calcular Stop Loss baseado em ATR                              |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateATRStopLoss(double entryPrice, ENUM_ORDER_TYPE orderType)
{
   double atr = GetCurrentATR();
   if(atr <= 0) return 0.0;
   
   double multiplier = AdaptMultiplierToVolatility(m_atrMultiplierSL);
   
   if(orderType == ORDER_TYPE_BUY)
      return entryPrice - (atr * multiplier);
   else
      return entryPrice + (atr * multiplier);
}

//+------------------------------------------------------------------+
//| Calcular Take Profit baseado em ATR                            |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateATRTakeProfit(double entryPrice, ENUM_ORDER_TYPE orderType, double stopLoss)
{
   double risk = MathAbs(entryPrice - stopLoss);
   double targetRR = (m_minRiskReward + m_maxRiskReward) / 2.0; // Usar média do range
   
   if(orderType == ORDER_TYPE_BUY)
      return entryPrice + (risk * targetRR);
   else
      return entryPrice - (risk * targetRR);
}

//+------------------------------------------------------------------+
//| Calcular Stop Loss estrutural                                  |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateStructuralStopLoss(double entryPrice, ENUM_ORDER_TYPE orderType, double structuralLevel)
{
   double buffer = GetCurrentATR() * 0.5; // Buffer de 50% do ATR
   
   if(orderType == ORDER_TYPE_BUY)
      return structuralLevel - buffer;
   else
      return structuralLevel + buffer;
}

//+------------------------------------------------------------------+
//| Calcular Take Profit estrutural                                |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateStructuralTakeProfit(double entryPrice, ENUM_ORDER_TYPE orderType, double stopLoss)
{
   // Encontrar próximo nível estrutural
   double nextLevel = 0.0;
   
   if(orderType == ORDER_TYPE_BUY)
      nextLevel = FindNearestSwingHigh();
   else
      nextLevel = FindNearestSwingLow();
   
   if(nextLevel > 0)
   {
      double buffer = GetCurrentATR() * 0.3; // Buffer menor para TP
      
      if(orderType == ORDER_TYPE_BUY)
         return nextLevel - buffer;
      else
         return nextLevel + buffer;
   }
   
   // Fallback para cálculo baseado em RR
   return CalculateATRTakeProfit(entryPrice, orderType, stopLoss);
}

//+------------------------------------------------------------------+
//| Obter valor ATR atual                                          |
//+------------------------------------------------------------------+
double CDynamicLevels::GetCurrentATR(void)
{
   return GetATRValue(0);
}

//+------------------------------------------------------------------+
//| Obter fator de volatilidade                                    |
//+------------------------------------------------------------------+
double CDynamicLevels::GetVolatilityFactor(void)
{
   double currentATR = GetCurrentATR();
   if(currentATR <= 0) return 1.0;
   
   return currentATR / m_volatilityThreshold;
}

//+------------------------------------------------------------------+
//| Verificar se está em alta volatilidade                        |
//+------------------------------------------------------------------+
bool CDynamicLevels::IsHighVolatility(void)
{
   return (GetCurrentATR() > m_volatilityThreshold);
}

//+------------------------------------------------------------------+
//| Encontrar Swing High mais próximo                              |
//+------------------------------------------------------------------+
double CDynamicLevels::FindNearestSwingHigh(int lookback)
{
   double maxHigh = 0.0;
   
   for(int i = 1; i <= lookback; i++)
   {
      double high = iHigh(m_symbol, m_timeframe, i);
      if(high > maxHigh)
         maxHigh = high;
   }
   
   return maxHigh;
}

//+------------------------------------------------------------------+
//| Encontrar Swing Low mais próximo                               |
//+------------------------------------------------------------------+
double CDynamicLevels::FindNearestSwingLow(int lookback)
{
   double minLow = DBL_MAX;
   
   for(int i = 1; i <= lookback; i++)
   {
      double low = iLow(m_symbol, m_timeframe, i);
      if(low < minLow && low > 0)
         minLow = low;
   }
   
   return (minLow == DBL_MAX) ? 0.0 : minLow;
}

//+------------------------------------------------------------------+
//| Validar Stop Loss                                              |
//+------------------------------------------------------------------+
bool CDynamicLevels::ValidateStopLoss(double entryPrice, double stopLoss, ENUM_ORDER_TYPE orderType)
{
   if(stopLoss <= 0) return false;
   
   double minDistance = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL) * m_point;
   double distance = MathAbs(entryPrice - stopLoss);
   
   if(distance < minDistance) return false;
   
   // Verificar direção
   if(orderType == ORDER_TYPE_BUY && stopLoss >= entryPrice) return false;
   if(orderType == ORDER_TYPE_SELL && stopLoss <= entryPrice) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Validar Take Profit                                            |
//+------------------------------------------------------------------+
bool CDynamicLevels::ValidateTakeProfit(double entryPrice, double takeProfit, ENUM_ORDER_TYPE orderType)
{
   if(takeProfit <= 0) return false;
   
   double minDistance = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL) * m_point;
   double distance = MathAbs(entryPrice - takeProfit);
   
   if(distance < minDistance) return false;
   
   // Verificar direção
   if(orderType == ORDER_TYPE_BUY && takeProfit <= entryPrice) return false;
   if(orderType == ORDER_TYPE_SELL && takeProfit >= entryPrice) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Normalizar preço                                               |
//+------------------------------------------------------------------+
double CDynamicLevels::NormalizePrice(double price)
{
   return NormalizeDouble(price, m_digits);
}

//+------------------------------------------------------------------+
//| Calcular ratio risco/recompensa                                |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateRiskRewardRatio(double entryPrice, double stopLoss, double takeProfit, ENUM_ORDER_TYPE orderType)
{
   double risk = MathAbs(entryPrice - stopLoss);
   double reward = MathAbs(takeProfit - entryPrice);
   
   if(risk <= 0) return 0.0;
   
   return reward / risk;
}

//+------------------------------------------------------------------+
//| Obter detalhes do cálculo                                      |
//+------------------------------------------------------------------+
string CDynamicLevels::GetCalculationDetails(SDynamicLevels &levels)
{
   return StringFormat("Method:%s|ATR:%.5f|RR:%.2f|VolFactor:%.2f",
                      levels.calculationMethod, levels.atrValue, 
                      levels.riskRewardRatio, levels.volatilityFactor);
}

//+------------------------------------------------------------------+
//| Inicializar indicadores                                        |
//+------------------------------------------------------------------+
bool CDynamicLevels::InitializeIndicators(void)
{
   m_atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
   
   if(m_atrHandle == INVALID_HANDLE)
   {
      if(m_logger != NULL)
         m_logger.LogError("DynamicLevels", "Falha ao criar handle ATR");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter valor ATR                                                |
//+------------------------------------------------------------------+
double CDynamicLevels::GetATRValue(int shift)
{
   double atrBuffer[1];
   
   if(CopyBuffer(m_atrHandle, 0, shift, 1, atrBuffer) <= 0)
      return 0.0;
   
   return atrBuffer[0];
}

//+------------------------------------------------------------------+
//| Adaptar multiplicador à volatilidade                          |
//+------------------------------------------------------------------+
double CDynamicLevels::AdaptMultiplierToVolatility(double baseMultiplier)
{
   double volFactor = GetVolatilityFactor();
   
   // Reduzir multiplicador em alta volatilidade, aumentar em baixa
   if(volFactor > 1.5)
      return baseMultiplier * 0.8;  // Reduzir 20%
   else if(volFactor < 0.7)
      return baseMultiplier * 1.2;  // Aumentar 20%
   
   return baseMultiplier;
}

//+------------------------------------------------------------------+
//| Encontrar Take Profit ótimo                                    |
//+------------------------------------------------------------------+
double CDynamicLevels::FindOptimalTakeProfit(double entryPrice, double stopLoss, ENUM_ORDER_TYPE orderType)
{
   double risk = MathAbs(entryPrice - stopLoss);
   
   // Usar volatilidade para determinar RR ótimo
   double targetRR = m_minRiskReward;
   
   if(IsHighVolatility())
      targetRR = m_minRiskReward;  // Mais conservador em alta volatilidade
   else
      targetRR = m_maxRiskReward;  // Mais agressivo em baixa volatilidade
   
   if(orderType == ORDER_TYPE_BUY)
      return entryPrice + (risk * targetRR);
   else
      return entryPrice - (risk * targetRR);
}

//+------------------------------------------------------------------+
//| Atualizar último cálculo                                       |
//+------------------------------------------------------------------+
void CDynamicLevels::UpdateLastCalculation(SDynamicLevels &levels)
{
   m_lastCalculation = levels;
}

//+------------------------------------------------------------------+
//| Converter método para string                                   |
//+------------------------------------------------------------------+
string CDynamicLevels::MethodToString(ENUM_CALCULATION_METHOD method)
{
   switch(method)
   {
      case METHOD_ATR_ONLY:   return "ATR_ONLY";
      case METHOD_STRUCTURAL: return "STRUCTURAL";
      case METHOD_HYBRID:     return "HYBRID";
      case METHOD_ADAPTIVE:   return "ADAPTIVE";
      default:               return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Configurar método de Stop Loss                                 |
//+------------------------------------------------------------------+
void CDynamicLevels::SetStopLossMethod(ENUM_CALCULATION_METHOD method)
{
   m_defaultMethod = method;
   
   if(m_logger != NULL)
   {
      string msg = "Método de Stop Loss configurado para: " + MethodToString(method);
      m_logger.LogInfo("DynamicLevels", msg);
   }
}

//+------------------------------------------------------------------+
//| Configurar método de Take Profit                               |
//+------------------------------------------------------------------+
void CDynamicLevels::SetTakeProfitMethod(ENUM_CALCULATION_METHOD method)
{
   // Para compatibilidade, usar o mesmo método padrão
   m_defaultMethod = method;
   
   if(m_logger != NULL)
   {
      string msg = "Método de Take Profit configurado para: " + MethodToString(method);
      m_logger.LogInfo("DynamicLevels", msg);
   }
}

//+------------------------------------------------------------------+
//| Obter níveis ótimos                                            |
//+------------------------------------------------------------------+
SDynamicLevels CDynamicLevels::GetOptimalLevels(double entryPrice, ENUM_ORDER_TYPE orderType)
{
   // Usar método adaptativo para níveis ótimos
   return CalculateAdaptiveLevels(entryPrice, orderType);
}

//+------------------------------------------------------------------+
//| Calcular níveis adaptativos                                    |
//+------------------------------------------------------------------+
SDynamicLevels CDynamicLevels::CalculateAdaptiveLevels(double entryPrice, ENUM_ORDER_TYPE orderType)
{
   SDynamicLevels levels;
   ZeroMemory(levels);
   
   // Determinar método baseado na volatilidade atual
   ENUM_CALCULATION_METHOD adaptiveMethod;
   
   if(IsHighVolatility())
      adaptiveMethod = METHOD_STRUCTURAL;  // Usar estrutura em alta volatilidade
   else
      adaptiveMethod = METHOD_ATR_ONLY;    // Usar ATR em baixa volatilidade
   
   // Calcular níveis usando método adaptativo
   levels = CalculateLevels(entryPrice, orderType, adaptiveMethod);
   levels.calculationMethod = "ADAPTIVE_" + MethodToString(adaptiveMethod);
   
   if(m_logger != NULL)
   {
      string msg = StringFormat("Níveis adaptativos calculados: SL=%.5f, TP=%.5f, Método=%s",
                               levels.stopLoss, levels.takeProfit, levels.calculationMethod);
      m_logger.LogInfo("DynamicLevels", msg);
   }
   
   return levels;
}

//+------------------------------------------------------------------+
//| Validar conformidade FTMO para risk management                 |
//+------------------------------------------------------------------+
bool CDynamicLevels::ValidateFTMORiskManagement(double entryPrice, double stopLoss, double lotSize)
{
   // Verificar se SL está definido
   if(stopLoss <= 0)
   {
      if(m_logger != NULL)
         m_logger.LogError("DynamicLevels", "FTMO: Stop Loss obrigatório não definido");
      return false;
   }
   
   // Calcular risco por trade (máximo 1% FTMO)
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = MathAbs(entryPrice - stopLoss) * lotSize * SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
   double riskPercent = (riskAmount / accountBalance) * 100.0;
   
   if(riskPercent > 1.0)
   {
      if(m_logger != NULL)
      {
         string msg = StringFormat("FTMO: Risco por trade %.2f%% excede limite de 1%%", riskPercent);
         m_logger.LogError("DynamicLevels", msg);
      }
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calcular tamanho de lote baseado em risco FTMO                 |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateFTMOLotSize(double entryPrice, double stopLoss, double riskPercent = 1.0)
{
   if(stopLoss <= 0 || entryPrice <= 0)
      return 0.0;
   
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = (accountBalance * riskPercent) / 100.0;
   double pointValue = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
   double stopLossPoints = MathAbs(entryPrice - stopLoss);
   
   if(stopLossPoints <= 0 || pointValue <= 0)
      return 0.0;
   
   double lotSize = riskAmount / (stopLossPoints * pointValue);
   
   // Normalizar para tamanho mínimo/máximo de lote
   double minLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Verificar limites de drawdown FTMO                             |
//+------------------------------------------------------------------+
bool CDynamicLevels::CheckDrawdownLimits(void)
{
   double currentDrawdown = GetCurrentDrawdown();
   double dailyLoss = GetDailyLoss();
   
   // Limite de drawdown total: 10%
   if(currentDrawdown >= 10.0)
   {
      if(m_logger != NULL)
      {
         string msg = StringFormat("FTMO: Drawdown total %.2f%% atingiu limite de 10%%", currentDrawdown);
         m_logger.LogError("DynamicLevels", msg);
      }
      return false;
   }
   
   // Limite de perda diária: 5%
   if(dailyLoss >= 5.0)
   {
      if(m_logger != NULL)
      {
         string msg = StringFormat("FTMO: Perda diária %.2f%% atingiu limite de 5%%", dailyLoss);
         m_logger.LogError("DynamicLevels", msg);
      }
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter drawdown atual em percentual                             |
//+------------------------------------------------------------------+
double CDynamicLevels::GetCurrentDrawdown(void)
{
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double initialBalance = AccountInfoDouble(ACCOUNT_BALANCE); // Pode ser configurado
   
   if(initialBalance <= 0)
      return 0.0;
   
   double currentDrawdown = ((initialBalance - accountEquity) / initialBalance) * 100.0;
   
   return MathMax(0.0, currentDrawdown);
}

//+------------------------------------------------------------------+
//| Validar limite de perda diária                                 |
//+------------------------------------------------------------------+
bool CDynamicLevels::ValidateDailyLossLimit(void)
{
   double dailyLoss = GetDailyLoss();
   
   // Limite FTMO: 5% de perda diária
   if(dailyLoss >= 5.0)
   {
      if(m_logger != NULL)
      {
         string msg = StringFormat("FTMO: Perda diária %.2f%% excede limite de 5%%", dailyLoss);
         m_logger.LogError("DynamicLevels", msg);
      }
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter perda diária em percentual                               |
//+------------------------------------------------------------------+
double CDynamicLevels::GetDailyLoss(void)
{
   datetime startOfDay = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   double startBalance = AccountInfoDouble(ACCOUNT_BALANCE); // Idealmente salvo no início do dia
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   if(startBalance <= 0)
      return 0.0;
   
   double dailyLoss = ((startBalance - currentEquity) / startBalance) * 100.0;
   
   return MathMax(0.0, dailyLoss);
}

//+------------------------------------------------------------------+
//| Obter equity atual da conta                                    |
//+------------------------------------------------------------------+
double CDynamicLevels::GetCurrentEquity(void)
{
   return AccountInfoDouble(ACCOUNT_EQUITY);
}

//+------------------------------------------------------------------+
//| Validar proteção de equity FTMO                               |
//+------------------------------------------------------------------+
bool CDynamicLevels::ValidateEquityProtection(void)
{
   double currentEquity = GetCurrentEquity();
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   if(accountBalance <= 0)
      return false;
   
   // Calcular percentual de equity em relação ao balance
   double equityPercent = (currentEquity / accountBalance) * 100.0;
   
   // FTMO: Equity não deve cair abaixo de 90% do balance inicial
   if(equityPercent < 90.0)
   {
      if(m_logger != NULL)
      {
         string msg = StringFormat("FTMO: Equity %.2f%% abaixo do limite de proteção (90%%)", equityPercent);
         m_logger.LogError("DynamicLevels", msg);
      }
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calcular risco baseado no equity atual                        |
//+------------------------------------------------------------------+
double CDynamicLevels::CalculateEquityRisk(void)
{
   double currentEquity = GetCurrentEquity();
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   if(accountBalance <= 0)
      return 0.0;
   
   // Calcular risco como percentual do equity atual
   double equityRisk = ((accountBalance - currentEquity) / accountBalance) * 100.0;
   
   return MathMax(0.0, equityRisk);
}

//+------------------------------------------------------------------+