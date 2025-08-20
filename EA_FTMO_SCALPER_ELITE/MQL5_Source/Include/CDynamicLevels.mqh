//+------------------------------------------------------------------+
//| CDynamicLevels.mqh                                               |
//| Copyright 2024, TradeDev_Master                                  |
//| FTMO SCALPER ELITE v2.0 - Dynamic SL/TP Calculator              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "2.00"
#property strict

#include <Object.mqh>
#include <Arrays\ArrayDouble.mqh>

//+------------------------------------------------------------------+
//| Enumerações e Estruturas                                         |
//+------------------------------------------------------------------+
enum ENUM_LEVEL_TYPE
{
   LEVEL_SUPPORT = 1,
   LEVEL_RESISTANCE = -1,
   LEVEL_NEUTRAL = 0
};

enum ENUM_VOLATILITY_STATE
{
   VOLATILITY_LOW = 1,
   VOLATILITY_NORMAL = 2,
   VOLATILITY_HIGH = 3,
   VOLATILITY_EXTREME = 4
};

struct SLevelData
{
   double price;
   ENUM_LEVEL_TYPE type;
   double strength;
   datetime formation_time;
   int touch_count;
   bool is_active;
};

struct SDynamicLevelsResult
{
   double stop_loss;
   double take_profit_1;
   double take_profit_2;
   double take_profit_3;
   double risk_reward_ratio;
   double confidence_score;
   string analysis_summary;
};

struct SMarketStructure
{
   double swing_high;
   double swing_low;
   double current_range;
   ENUM_VOLATILITY_STATE volatility;
   double atr_value;
   double support_level;
   double resistance_level;
};

//+------------------------------------------------------------------+
//| Calculadora de Níveis Dinâmicos                                 |
//+------------------------------------------------------------------+
class CDynamicLevels : public CObject
{
private:
   // Handles de indicadores
   int m_atr_handle;
   int m_bb_handle;
   
   // Parâmetros de configuração
   int m_atr_period;
   int m_swing_lookback;
   double m_min_rr_ratio;
   double m_max_rr_ratio;
   
   // Arrays para níveis detectados
   CArrayDouble m_support_levels;
   CArrayDouble m_resistance_levels;
   
   // Configurações FTMO
   double m_max_risk_percent;
   double m_account_balance;
   
public:
   CDynamicLevels(int atr_period = 14, int swing_lookback = 20, double min_rr = 1.5, double max_rr = 4.0)
      : m_atr_period(atr_period), m_swing_lookback(swing_lookback), 
        m_min_rr_ratio(min_rr), m_max_rr_ratio(max_rr), m_max_risk_percent(1.0)
   {
      InitializeIndicators();
      m_account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   }
   
   ~CDynamicLevels()
   {
      if(m_atr_handle != INVALID_HANDLE) IndicatorRelease(m_atr_handle);
      if(m_bb_handle != INVALID_HANDLE) IndicatorRelease(m_bb_handle);
   }
   
   void InitializeIndicators()
   {
      m_atr_handle = iATR(_Symbol, PERIOD_CURRENT, m_atr_period);
      m_bb_handle = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
      
      if(m_atr_handle == INVALID_HANDLE)
         Print("Erro ao criar handle ATR");
      if(m_bb_handle == INVALID_HANDLE)
         Print("Erro ao criar handle Bollinger Bands");
   }
   
   //+------------------------------------------------------------------+
   //| Calcular níveis dinâmicos para uma posição                       n   //+------------------------------------------------------------------+
   SDynamicLevelsResult CalculateDynamicLevels(ENUM_ORDER_TYPE order_type, double entry_price, 
                                               double lot_size = 0.01, ENUM_TIMEFRAMES timeframe = PERIOD_M15)
   {
      SDynamicLevelsResult result;
      ZeroMemory(result);
      
      // Obter estrutura de mercado atual
      SMarketStructure market = AnalyzeMarketStructure(timeframe);
      
      if(market.atr_value <= 0)
      {
         result.analysis_summary = "Erro: ATR inválido";
         return result;
      }
      
      // Detectar níveis de suporte e resistência
      UpdateSupportResistanceLevels(timeframe);
      
      // Calcular SL baseado na estrutura de mercado
      result.stop_loss = CalculateStopLoss(order_type, entry_price, market);
      
      // Calcular múltiplos TPs
      CalculateMultipleTakeProfits(order_type, entry_price, result.stop_loss, market, result);
      
      // Validar conformidade FTMO
      ValidateFTMOCompliance(entry_price, result.stop_loss, lot_size, result);
      
      // Calcular métricas de confiança
      result.confidence_score = CalculateConfidenceScore(market, result);
      
      // Gerar resumo da análise
      result.analysis_summary = GenerateAnalysisSummary(order_type, market, result);
      
      return result;
   }
   
   //+------------------------------------------------------------------+
   //| Analisar estrutura de mercado                                    |
   //+------------------------------------------------------------------+
   SMarketStructure AnalyzeMarketStructure(ENUM_TIMEFRAMES timeframe)
   {
      SMarketStructure market;
      ZeroMemory(market);
      
      // Obter ATR
      double atr_values[1];
      if(CopyBuffer(m_atr_handle, 0, 0, 1, atr_values) == 1)
         market.atr_value = atr_values[0];
      else
         return market;
      
      // Obter dados de preço
      MqlRates rates[];
      if(CopyRates(_Symbol, timeframe, 0, m_swing_lookback + 10, rates) < m_swing_lookback)
         return market;
      
      // Detectar swing points
      DetectSwingPoints(rates, market);
      
      // Calcular range atual
      market.current_range = market.swing_high - market.swing_low;
      
      // Determinar estado de volatilidade
      market.volatility = DetermineVolatilityState(market.atr_value, timeframe);
      
      // Encontrar níveis de suporte e resistência mais próximos
      market.support_level = FindNearestSupportLevel(SymbolInfoDouble(_Symbol, SYMBOL_BID));
      market.resistance_level = FindNearestResistanceLevel(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
      
      return market;
   }
   
   //+------------------------------------------------------------------+
   //| Detectar swing points                                            |
   //+------------------------------------------------------------------+
   void DetectSwingPoints(const MqlRates rates[], SMarketStructure &market)
   {
      int size = ArraySize(rates);
      if(size < 5) return;
      
      market.swing_high = rates[0].high;
      market.swing_low = rates[0].low;
      
      // Encontrar swing high e low nos últimos candles
      for(int i = 2; i < size - 2; i++)
      {
         // Swing High
         if(rates[i].high > rates[i-1].high && rates[i].high > rates[i-2].high &&
            rates[i].high > rates[i+1].high && rates[i].high > rates[i+2].high)
         {
            if(rates[i].high > market.swing_high)
               market.swing_high = rates[i].high;
         }
         
         // Swing Low
         if(rates[i].low < rates[i-1].low && rates[i].low < rates[i-2].low &&
            rates[i].low < rates[i+1].low && rates[i].low < rates[i+2].low)
         {
            if(rates[i].low < market.swing_low)
               market.swing_low = rates[i].low;
         }
      }
   }
   
   //+------------------------------------------------------------------+
   //| Determinar estado de volatilidade                                |
   //+------------------------------------------------------------------+
   ENUM_VOLATILITY_STATE DetermineVolatilityState(double current_atr, ENUM_TIMEFRAMES timeframe)
   {
      // Obter ATR histórico para comparação
      double atr_history[50];
      if(CopyBuffer(m_atr_handle, 0, 0, 50, atr_history) != 50)
         return VOLATILITY_NORMAL;
      
      // Calcular média e desvio padrão do ATR
      double atr_sum = 0, atr_sq_sum = 0;
      for(int i = 1; i < 50; i++) // Excluir o valor atual
      {
         atr_sum += atr_history[i];
         atr_sq_sum += atr_history[i] * atr_history[i];
      }
      
      double atr_mean = atr_sum / 49;
      double atr_variance = (atr_sq_sum / 49) - (atr_mean * atr_mean);
      double atr_std = MathSqrt(atr_variance);
      
      // Classificar volatilidade
      if(current_atr > atr_mean + 2 * atr_std)
         return VOLATILITY_EXTREME;
      else if(current_atr > atr_mean + atr_std)
         return VOLATILITY_HIGH;
      else if(current_atr < atr_mean - atr_std)
         return VOLATILITY_LOW;
      
      return VOLATILITY_NORMAL;
   }
   
   //+------------------------------------------------------------------+
   //| Calcular Stop Loss dinâmico                                      |
   //+------------------------------------------------------------------+
   double CalculateStopLoss(ENUM_ORDER_TYPE order_type, double entry_price, const SMarketStructure &market)
   {
      double sl_distance = 0;
      
      // Base: 1.5x ATR
      double base_distance = market.atr_value * 1.5;
      
      // Ajustar baseado na volatilidade
      double volatility_multiplier = 1.0;
      switch(market.volatility)
      {
         case VOLATILITY_LOW: volatility_multiplier = 0.8; break;
         case VOLATILITY_NORMAL: volatility_multiplier = 1.0; break;
         case VOLATILITY_HIGH: volatility_multiplier = 1.3; break;
         case VOLATILITY_EXTREME: volatility_multiplier = 1.6; break;
      }
      
      sl_distance = base_distance * volatility_multiplier;
      
      // Ajustar baseado em níveis de suporte/resistência
      if(order_type == ORDER_TYPE_BUY)
      {
         double structure_sl = market.swing_low - (market.atr_value * 0.5);
         double support_sl = market.support_level - (market.atr_value * 0.3);
         
         // Usar o SL mais conservador (mais próximo do preço)
         double calculated_sl = entry_price - sl_distance;
         
         if(structure_sl > 0 && structure_sl < entry_price)
            calculated_sl = MathMax(calculated_sl, structure_sl);
         
         if(support_sl > 0 && support_sl < entry_price)
            calculated_sl = MathMax(calculated_sl, support_sl);
         
         return calculated_sl;
      }
      else // ORDER_TYPE_SELL
      {
         double structure_sl = market.swing_high + (market.atr_value * 0.5);
         double resistance_sl = market.resistance_level + (market.atr_value * 0.3);
         
         // Usar o SL mais conservador (mais próximo do preço)
         double calculated_sl = entry_price + sl_distance;
         
         if(structure_sl > 0 && structure_sl > entry_price)
            calculated_sl = MathMin(calculated_sl, structure_sl);
         
         if(resistance_sl > 0 && resistance_sl > entry_price)
            calculated_sl = MathMin(calculated_sl, resistance_sl);
         
         return calculated_sl;
      }
   }
   
   //+------------------------------------------------------------------+
   //| Calcular múltiplos Take Profits                                  |
   //+------------------------------------------------------------------+
   void CalculateMultipleTakeProfits(ENUM_ORDER_TYPE order_type, double entry_price, double stop_loss,
                                    const SMarketStructure &market, SDynamicLevelsResult &result)
   {
      double sl_distance = MathAbs(entry_price - stop_loss);
      
      if(order_type == ORDER_TYPE_BUY)
      {
         // TP1: 1.5x SL (conservador)
         result.take_profit_1 = entry_price + (sl_distance * 1.5);
         
         // TP2: 2.5x SL (moderado)
         result.take_profit_2 = entry_price + (sl_distance * 2.5);
         
         // TP3: Baseado em resistência ou 4x SL
         double resistance_tp = market.resistance_level;
         double calculated_tp3 = entry_price + (sl_distance * 4.0);
         
         if(resistance_tp > entry_price && resistance_tp < calculated_tp3)
            result.take_profit_3 = resistance_tp - (market.atr_value * 0.2); // Margem de segurança
         else
            result.take_profit_3 = calculated_tp3;
      }
      else // ORDER_TYPE_SELL
      {
         // TP1: 1.5x SL (conservador)
         result.take_profit_1 = entry_price - (sl_distance * 1.5);
         
         // TP2: 2.5x SL (moderado)
         result.take_profit_2 = entry_price - (sl_distance * 2.5);
         
         // TP3: Baseado em suporte ou 4x SL
         double support_tp = market.support_level;
         double calculated_tp3 = entry_price - (sl_distance * 4.0);
         
         if(support_tp < entry_price && support_tp > calculated_tp3)
            result.take_profit_3 = support_tp + (market.atr_value * 0.2); // Margem de segurança
         else
            result.take_profit_3 = calculated_tp3;
      }
      
      // Calcular Risk/Reward ratio
      double tp1_distance = MathAbs(result.take_profit_1 - entry_price);
      result.risk_reward_ratio = tp1_distance / sl_distance;
   }
   
   //+------------------------------------------------------------------+
   //| Validar conformidade FTMO                                        |
   //+------------------------------------------------------------------+
   void ValidateFTMOCompliance(double entry_price, double stop_loss, double lot_size, 
                              SDynamicLevelsResult &result)
   {
      // Calcular risco em dinheiro
      double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      double sl_distance_points = MathAbs(entry_price - stop_loss) / point;
      double risk_money = sl_distance_points * tick_value * lot_size / tick_size;
      
      double risk_percent = (risk_money / m_account_balance) * 100;
      
      // Verificar se excede o limite de risco
      if(risk_percent > m_max_risk_percent)
      {
         // Ajustar lot size para conformidade
         double max_risk_money = m_account_balance * (m_max_risk_percent / 100);
         double suggested_lot = (max_risk_money * tick_size) / (sl_distance_points * tick_value);
         
         result.analysis_summary += StringFormat(" | AVISO: Risco %.2f%% > %.1f%%. Lot sugerido: %.2f", 
                                                risk_percent, m_max_risk_percent, suggested_lot);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Calcular score de confiança                                      |
   //+------------------------------------------------------------------+
   double CalculateConfidenceScore(const SMarketStructure &market, const SDynamicLevelsResult &result)
   {
      double score = 0.5; // Base score
      
      // Bonus por Risk/Reward adequado
      if(result.risk_reward_ratio >= m_min_rr_ratio && result.risk_reward_ratio <= m_max_rr_ratio)
         score += 0.2;
      
      // Bonus por volatilidade adequada
      if(market.volatility == VOLATILITY_NORMAL || market.volatility == VOLATILITY_HIGH)
         score += 0.15;
      
      // Bonus por níveis de estrutura claros
      if(market.swing_high > 0 && market.swing_low > 0 && market.current_range > market.atr_value)
         score += 0.15;
      
      return MathMin(score, 1.0);
   }
   
   //+------------------------------------------------------------------+
   //| Gerar resumo da análise                                          |
   //+------------------------------------------------------------------+
   string GenerateAnalysisSummary(ENUM_ORDER_TYPE order_type, const SMarketStructure &market, 
                                 const SDynamicLevelsResult &result)
   {
      string summary = "";
      
      summary += StringFormat("%s | ATR: %.5f | RR: %.1f | Conf: %.1f%%", 
                             (order_type == ORDER_TYPE_BUY) ? "COMPRA" : "VENDA",
                             market.atr_value, result.risk_reward_ratio, result.confidence_score * 100);
      
      summary += " | Vol: ";
      switch(market.volatility)
      {
         case VOLATILITY_LOW: summary += "BAIXA"; break;
         case VOLATILITY_NORMAL: summary += "NORMAL"; break;
         case VOLATILITY_HIGH: summary += "ALTA"; break;
         case VOLATILITY_EXTREME: summary += "EXTREMA"; break;
      }
      
      return summary;
   }
   
   //+------------------------------------------------------------------+
   //| Atualizar níveis de suporte e resistência                        |
   //+------------------------------------------------------------------+
   void UpdateSupportResistanceLevels(ENUM_TIMEFRAMES timeframe)
   {
      m_support_levels.Clear();
      m_resistance_levels.Clear();
      
      MqlRates rates[];
      if(CopyRates(_Symbol, timeframe, 0, 100, rates) < 100) return;
      
      // Detectar níveis de suporte e resistência usando pivot points
      for(int i = 5; i < 95; i++)
      {
         // Resistance (pivot high)
         if(rates[i].high > rates[i-1].high && rates[i].high > rates[i-2].high &&
            rates[i].high > rates[i+1].high && rates[i].high > rates[i+2].high)
         {
            m_resistance_levels.Add(rates[i].high);
         }
         
         // Support (pivot low)
         if(rates[i].low < rates[i-1].low && rates[i].low < rates[i-2].low &&
            rates[i].low < rates[i+1].low && rates[i].low < rates[i+2].low)
         {
            m_support_levels.Add(rates[i].low);
         }
      }
   }
   
   //+------------------------------------------------------------------+
   //| Encontrar nível de suporte mais próximo                          |
   //+------------------------------------------------------------------+
   double FindNearestSupportLevel(double current_price)
   {
      double nearest_support = 0;
      double min_distance = DBL_MAX;
      
      for(int i = 0; i < m_support_levels.Total(); i++)
      {
         double level = m_support_levels.At(i);
         if(level < current_price)
         {
            double distance = current_price - level;
            if(distance < min_distance)
            {
               min_distance = distance;
               nearest_support = level;
            }
         }
      }
      
      return nearest_support;
   }
   
   //+------------------------------------------------------------------+
   //| Encontrar nível de resistência mais próximo                      |
   //+------------------------------------------------------------------+
   double FindNearestResistanceLevel(double current_price)
   {
      double nearest_resistance = 0;
      double min_distance = DBL_MAX;
      
      for(int i = 0; i < m_resistance_levels.Total(); i++)
      {
         double level = m_resistance_levels.At(i);
         if(level > current_price)
         {
            double distance = level - current_price;
            if(distance < min_distance)
            {
               min_distance = distance;
               nearest_resistance = level;
            }
         }
      }
      
      return nearest_resistance;
   }
   
   //+------------------------------------------------------------------+
   //| Setters para configuração                                        |
   //+------------------------------------------------------------------+
   void SetMaxRiskPercent(double risk_percent) { m_max_risk_percent = risk_percent; }
   void SetMinRRRatio(double min_rr) { m_min_rr_ratio = min_rr; }
   void SetMaxRRRatio(double max_rr) { m_max_rr_ratio = max_rr; }
   
   //+------------------------------------------------------------------+
   //| Getters para informações                                         |
   //+------------------------------------------------------------------+
   double GetCurrentATR() 
   {
      double atr_values[1];
      if(CopyBuffer(m_atr_handle, 0, 0, 1, atr_values) == 1)
         return atr_values[0];
      return 0;
   }
   
   int GetSupportLevelsCount() const { return m_support_levels.Total(); }
   int GetResistanceLevelsCount() const { return m_resistance_levels.Total(); }
};

//+------------------------------------------------------------------+