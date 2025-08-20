//+------------------------------------------------------------------+
//| CAdvancedSignalEngine.mqh                                        |
//| Copyright 2024, TradeDev_Master                                  |
//| FTMO SCALPER ELITE v2.0 - Advanced Signal Engine                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "2.00"
#property strict

#include <Trade\Trade.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Object.mqh>

//+------------------------------------------------------------------+
//| Enumerações e Estruturas                                         |
//+------------------------------------------------------------------+
#ifndef ENUM_SIGNAL_TYPE_DEFINED
#define ENUM_SIGNAL_TYPE_DEFINED
enum ENUM_SIGNAL_TYPE
{
   SIGNAL_BUY = 1,
   SIGNAL_SELL = -1,
   SIGNAL_NEUTRAL = 0
};
#endif

enum ENUM_TIMEFRAME_WEIGHT
{
   TF_M1_WEIGHT = 10,
   TF_M5_WEIGHT = 25,
   TF_M15_WEIGHT = 35,
   TF_H1_WEIGHT = 30
};

#ifndef ENUM_SESSION_TYPE_DEFINED
#define ENUM_SESSION_TYPE_DEFINED
enum ENUM_SESSION_TYPE
{
   SESSION_LONDON = 1,
   SESSION_NEW_YORK = 2,
   SESSION_ASIAN = 3,
   SESSION_OVERLAP = 4,
   SESSION_INACTIVE = 0
};
#endif

struct SSignalData
{
   ENUM_SIGNAL_TYPE signal_type;
   double confidence;
   double weight;
   string source;
   datetime timestamp;
   ENUM_TIMEFRAMES timeframe;
};

struct SOrderBlockData
{
   double price_level;
   double volume;
   datetime formation_time;
   bool is_bullish;
   double strength_score;
   bool is_active;
};

struct SConfluenceResult
{
   ENUM_SIGNAL_TYPE final_signal;
   double total_score;
   double confidence_level;
   int signal_count;
   string analysis_summary;
};

//+------------------------------------------------------------------+
//| Classe Base para Análise de Sinais                              |
//+------------------------------------------------------------------+
class CSignalAnalyzer : public CObject
{
protected:
   string m_name;
   double m_weight;
   bool m_enabled;
   
public:
   CSignalAnalyzer(string name, double weight = 1.0) : m_name(name), m_weight(weight), m_enabled(true) {}
   virtual ~CSignalAnalyzer() {}
   
   virtual SSignalData AnalyzeSignal(ENUM_TIMEFRAMES timeframe) = 0;
   
   void SetWeight(double weight) { m_weight = weight; }
   double GetWeight() const { return m_weight; }
   void SetEnabled(bool enabled) { m_enabled = enabled; }
   bool IsEnabled() const { return m_enabled; }
   string GetName() const { return m_name; }
};

//+------------------------------------------------------------------+
//| Análise RSI Multi-Timeframe                                     |
//+------------------------------------------------------------------+
class CRSIMultiTimeframeAnalyzer : public CSignalAnalyzer
{
private:
   int m_rsi_period;
   double m_oversold_level;
   double m_overbought_level;
   int m_rsi_handles[4]; // M1, M5, M15, H1
   
public:
   CRSIMultiTimeframeAnalyzer(int period = 14, double oversold = 30.0, double overbought = 70.0) 
      : CSignalAnalyzer("RSI_MultiTF", 1.0), m_rsi_period(period), 
        m_oversold_level(oversold), m_overbought_level(overbought)
   {
      InitializeHandles();
   }
   
   ~CRSIMultiTimeframeAnalyzer()
   {
      for(int i = 0; i < 4; i++)
         if(m_rsi_handles[i] != INVALID_HANDLE)
            IndicatorRelease(m_rsi_handles[i]);
   }
   
   void InitializeHandles()
   {
      ENUM_TIMEFRAMES timeframes[4] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1};
      
      for(int i = 0; i < 4; i++)
      {
         m_rsi_handles[i] = iRSI(_Symbol, timeframes[i], m_rsi_period, PRICE_CLOSE);
         if(m_rsi_handles[i] == INVALID_HANDLE)
            Print("Erro ao criar handle RSI para timeframe: ", EnumToString(timeframes[i]));
      }
   }
   
   virtual SSignalData AnalyzeSignal(ENUM_TIMEFRAMES timeframe) override
   {
      SSignalData signal;
      signal.source = m_name;
      signal.timeframe = timeframe;
      signal.timestamp = TimeCurrent();
      signal.signal_type = SIGNAL_NEUTRAL;
      signal.confidence = 0.0;
      signal.weight = m_weight;
      
      int tf_index = GetTimeframeIndex(timeframe);
      if(tf_index < 0 || m_rsi_handles[tf_index] == INVALID_HANDLE)
         return signal;
      
      double rsi_values[3];
      if(CopyBuffer(m_rsi_handles[tf_index], 0, 0, 3, rsi_values) != 3)
         return signal;
      
      double current_rsi = rsi_values[0];
      double prev_rsi = rsi_values[1];
      double prev2_rsi = rsi_values[2];
      
      // Análise de divergência e momentum
      if(current_rsi < m_oversold_level && prev_rsi > current_rsi && prev2_rsi > prev_rsi)
      {
         signal.signal_type = SIGNAL_BUY;
         signal.confidence = (m_oversold_level - current_rsi) / m_oversold_level;
      }
      else if(current_rsi > m_overbought_level && prev_rsi < current_rsi && prev2_rsi < prev_rsi)
      {
         signal.signal_type = SIGNAL_SELL;
         signal.confidence = (current_rsi - m_overbought_level) / (100.0 - m_overbought_level);
      }
      
      // Ajuste de confiança baseado no timeframe
      signal.confidence *= GetTimeframeMultiplier(timeframe);
      
      return signal;
   }
   
private:
   int GetTimeframeIndex(ENUM_TIMEFRAMES tf)
   {
      switch(tf)
      {
         case PERIOD_M1: return 0;
         case PERIOD_M5: return 1;
         case PERIOD_M15: return 2;
         case PERIOD_H1: return 3;
         default: return -1;
      }
   }
   
   double GetTimeframeMultiplier(ENUM_TIMEFRAMES tf)
   {
      switch(tf)
      {
         case PERIOD_M1: return 0.8;
         case PERIOD_M5: return 1.0;
         case PERIOD_M15: return 1.2;
         case PERIOD_H1: return 1.5;
         default: return 1.0;
      }
   }
};

//+------------------------------------------------------------------+
//| Análise de Confluência de Médias Móveis                         |
//+------------------------------------------------------------------+
class CMAConfluenceAnalyzer : public CSignalAnalyzer
{
private:
   int m_ma_fast_period;
   int m_ma_slow_period;
   ENUM_MA_METHOD m_ma_method;
   int m_ma_fast_handle;
   int m_ma_slow_handle;
   
public:
   CMAConfluenceAnalyzer(int fast_period = 21, int slow_period = 50, ENUM_MA_METHOD method = MODE_EMA)
      : CSignalAnalyzer("MA_Confluence", 1.0), m_ma_fast_period(fast_period), 
        m_ma_slow_period(slow_period), m_ma_method(method)
   {
      m_ma_fast_handle = iMA(_Symbol, PERIOD_CURRENT, m_ma_fast_period, 0, m_ma_method, PRICE_CLOSE);
      m_ma_slow_handle = iMA(_Symbol, PERIOD_CURRENT, m_ma_slow_period, 0, m_ma_method, PRICE_CLOSE);
   }
   
   ~CMAConfluenceAnalyzer()
   {
      if(m_ma_fast_handle != INVALID_HANDLE) IndicatorRelease(m_ma_fast_handle);
      if(m_ma_slow_handle != INVALID_HANDLE) IndicatorRelease(m_ma_slow_handle);
   }
   
   virtual SSignalData AnalyzeSignal(ENUM_TIMEFRAMES timeframe) override
   {
      SSignalData signal;
      signal.source = m_name;
      signal.timeframe = timeframe;
      signal.timestamp = TimeCurrent();
      signal.signal_type = SIGNAL_NEUTRAL;
      signal.confidence = 0.0;
      signal.weight = m_weight;
      
      if(m_ma_fast_handle == INVALID_HANDLE || m_ma_slow_handle == INVALID_HANDLE)
         return signal;
      
      double ma_fast[3], ma_slow[3];
      if(CopyBuffer(m_ma_fast_handle, 0, 0, 3, ma_fast) != 3 ||
         CopyBuffer(m_ma_slow_handle, 0, 0, 3, ma_slow) != 3)
         return signal;
      
      double price_current = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      // Análise de confluência
      bool fast_above_slow = ma_fast[0] > ma_slow[0];
      bool price_above_fast = price_current > ma_fast[0];
      bool price_above_slow = price_current > ma_slow[0];
      
      // Crossover detection
      bool bullish_cross = ma_fast[0] > ma_slow[0] && ma_fast[1] <= ma_slow[1];
      bool bearish_cross = ma_fast[0] < ma_slow[0] && ma_fast[1] >= ma_slow[1];
      
      if(fast_above_slow && price_above_fast && price_above_slow)
      {
         signal.signal_type = SIGNAL_BUY;
         signal.confidence = 0.7;
         if(bullish_cross) signal.confidence = 0.9;
      }
      else if(!fast_above_slow && !price_above_fast && !price_above_slow)
      {
         signal.signal_type = SIGNAL_SELL;
         signal.confidence = 0.7;
         if(bearish_cross) signal.confidence = 0.9;
      }
      
      return signal;
   }
};

//+------------------------------------------------------------------+
//| Análise de Volume                                                |
//+------------------------------------------------------------------+
class CVolumeAnalyzer : public CSignalAnalyzer
{
private:
   int m_volume_ma_period;
   double m_volume_threshold;
   
public:
   CVolumeAnalyzer(int ma_period = 20, double threshold = 1.5)
      : CSignalAnalyzer("Volume_Analysis", 1.0), m_volume_ma_period(ma_period), m_volume_threshold(threshold) {}
   
   virtual SSignalData AnalyzeSignal(ENUM_TIMEFRAMES timeframe) override
   {
      SSignalData signal;
      signal.source = m_name;
      signal.timeframe = timeframe;
      signal.timestamp = TimeCurrent();
      signal.signal_type = SIGNAL_NEUTRAL;
      signal.confidence = 0.0;
      signal.weight = m_weight;
      
      long volumes[21];
      if(CopyTickVolume(_Symbol, timeframe, 0, 21, volumes) != 21)
         return signal;
      
      // Calcular média de volume
      long volume_sum = 0;
      for(int i = 1; i < 21; i++)
         volume_sum += volumes[i];
      
      double volume_avg = (double)volume_sum / 20.0;
      double current_volume = (double)volumes[0];
      
      // Detectar surto de volume
      if(current_volume > volume_avg * m_volume_threshold)
      {
         MqlRates rates[2];
         if(CopyRates(_Symbol, timeframe, 0, 2, rates) == 2)
         {
            bool bullish_candle = rates[0].close > rates[0].open;
            signal.signal_type = bullish_candle ? SIGNAL_BUY : SIGNAL_SELL;
            signal.confidence = MathMin(current_volume / (volume_avg * m_volume_threshold), 2.0) / 2.0;
         }
      }
      
      return signal;
   }
};

//+------------------------------------------------------------------+
//| Detector de Order Blocks                                         |
//+------------------------------------------------------------------+
class COrderBlockDetector : public CSignalAnalyzer
{
private:
   int m_lookback_period;
   double m_min_block_size;
   CArrayObj m_order_blocks;
   
public:
   COrderBlockDetector(int lookback = 50, double min_size = 0.0001)
      : CSignalAnalyzer("Order_Blocks", 1.0), m_lookback_period(lookback), m_min_block_size(min_size) {}
   
   virtual SSignalData AnalyzeSignal(ENUM_TIMEFRAMES timeframe) override
   {
      SSignalData signal;
      signal.source = m_name;
      signal.timeframe = timeframe;
      signal.timestamp = TimeCurrent();
      signal.signal_type = SIGNAL_NEUTRAL;
      signal.confidence = 0.0;
      signal.weight = m_weight;
      
      UpdateOrderBlocks(timeframe);
      
      double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      SOrderBlockData* nearest_block = FindNearestOrderBlock(current_price);
      
      if(nearest_block != NULL && nearest_block.is_active)
      {
         double distance = MathAbs(current_price - nearest_block.price_level);
         double atr = GetATR(timeframe, 14);
         
         if(distance <= atr * 0.5) // Próximo ao Order Block
         {
            signal.signal_type = nearest_block.is_bullish ? SIGNAL_BUY : SIGNAL_SELL;
            signal.confidence = nearest_block.strength_score * (1.0 - distance / (atr * 0.5));
         }
      }
      
      return signal;
   }
   
private:
   void UpdateOrderBlocks(ENUM_TIMEFRAMES timeframe)
   {
      MqlRates rates[];
      if(CopyRates(_Symbol, timeframe, 0, m_lookback_period, rates) < m_lookback_period)
         return;
      
      // Detectar Order Blocks (implementação simplificada)
      for(int i = 2; i < m_lookback_period - 2; i++)
      {
         if(IsOrderBlock(rates, i))
         {
            SOrderBlockData* block = new SOrderBlockData();
            block.price_level = (rates[i].high + rates[i].low) / 2.0;
            block.formation_time = rates[i].time;
            block.is_bullish = rates[i].close > rates[i].open;
            block.strength_score = CalculateBlockStrength(rates, i);
            block.is_active = true;
            
            m_order_blocks.Add(block);
         }
      }
   }
   
   bool IsOrderBlock(const MqlRates rates[], int index)
   {
      // Lógica simplificada para detectar Order Blocks
      double body_size = MathAbs(rates[index].close - rates[index].open);
      double candle_range = rates[index].high - rates[index].low;
      
      return body_size > candle_range * 0.7 && candle_range > m_min_block_size;
   }
   
   double CalculateBlockStrength(const MqlRates rates[], int index)
   {
      // Calcular força do Order Block baseado em volume e contexto
      return 0.8; // Implementação simplificada
   }
   
   SOrderBlockData* FindNearestOrderBlock(double price)
   {
      SOrderBlockData* nearest = NULL;
      double min_distance = DBL_MAX;
      
      for(int i = 0; i < m_order_blocks.Total(); i++)
      {
         SOrderBlockData* block = m_order_blocks.At(i);
         if(block != NULL && block.is_active)
         {
            double distance = MathAbs(price - block.price_level);
            if(distance < min_distance)
            {
               min_distance = distance;
               nearest = block;
            }
         }
      }
      
      return nearest;
   }
   
   double GetATR(ENUM_TIMEFRAMES timeframe, int period)
   {
      int atr_handle = iATR(_Symbol, timeframe, period);
      if(atr_handle == INVALID_HANDLE) return 0.001;
      
      double atr_value[1];
      if(CopyBuffer(atr_handle, 0, 0, 1, atr_value) == 1)
      {
         IndicatorRelease(atr_handle);
         return atr_value[0];
      }
      
      IndicatorRelease(atr_handle);
      return 0.001;
   }
};

//+------------------------------------------------------------------+
//| Detector de Breakouts ATR                                        |
//+------------------------------------------------------------------+
class CATRBreakoutDetector : public CSignalAnalyzer
{
private:
   int m_atr_period;
   double m_breakout_multiplier;
   int m_atr_handle;
   
public:
   CATRBreakoutDetector(int atr_period = 14, double multiplier = 1.5)
      : CSignalAnalyzer("ATR_Breakout", 1.0), m_atr_period(atr_period), m_breakout_multiplier(multiplier)
   {
      m_atr_handle = iATR(_Symbol, PERIOD_CURRENT, m_atr_period);
   }
   
   ~CATRBreakoutDetector()
   {
      if(m_atr_handle != INVALID_HANDLE) IndicatorRelease(m_atr_handle);
   }
   
   virtual SSignalData AnalyzeSignal(ENUM_TIMEFRAMES timeframe) override
   {
      SSignalData signal;
      signal.source = m_name;
      signal.timeframe = timeframe;
      signal.timestamp = TimeCurrent();
      signal.signal_type = SIGNAL_NEUTRAL;
      signal.confidence = 0.0;
      signal.weight = m_weight;
      
      if(m_atr_handle == INVALID_HANDLE) return signal;
      
      double atr_values[1];
      MqlRates rates[3];
      
      if(CopyBuffer(m_atr_handle, 0, 0, 1, atr_values) != 1 ||
         CopyRates(_Symbol, timeframe, 0, 3, rates) != 3)
         return signal;
      
      double atr = atr_values[0];
      double breakout_threshold = atr * m_breakout_multiplier;
      
      // Detectar breakout
      double prev_high = rates[1].high;
      double prev_low = rates[1].low;
      double current_close = rates[0].close;
      
      if(current_close > prev_high + breakout_threshold)
      {
         signal.signal_type = SIGNAL_BUY;
         signal.confidence = MathMin((current_close - prev_high) / breakout_threshold, 2.0) / 2.0;
      }
      else if(current_close < prev_low - breakout_threshold)
      {
         signal.signal_type = SIGNAL_SELL;
         signal.confidence = MathMin((prev_low - current_close) / breakout_threshold, 2.0) / 2.0;
      }
      
      return signal;
   }
};

//+------------------------------------------------------------------+
//| Filtro de Sessão                                                 |
//+------------------------------------------------------------------+
class CSessionFilter : public CObject
{
private:
   bool m_london_enabled;
   bool m_newyork_enabled;
   bool m_overlap_enabled;
   
public:
   CSessionFilter(bool london = true, bool newyork = true, bool overlap = true)
      : m_london_enabled(london), m_newyork_enabled(newyork), m_overlap_enabled(overlap) {}
   
   ENUM_SESSION_TYPE GetCurrentSession()
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      
      int hour_gmt = dt.hour;
      
      // Sessão de Londres: 08:00 - 17:00 GMT
      bool london_active = (hour_gmt >= 8 && hour_gmt < 17);
      
      // Sessão de Nova York: 13:00 - 22:00 GMT
      bool newyork_active = (hour_gmt >= 13 && hour_gmt < 22);
      
      // Overlap: 13:00 - 17:00 GMT
      if(london_active && newyork_active && m_overlap_enabled)
         return SESSION_OVERLAP;
      else if(london_active && m_london_enabled)
         return SESSION_LONDON;
      else if(newyork_active && m_newyork_enabled)
         return SESSION_NEW_YORK;
      
      return SESSION_INACTIVE;
   }
   
   bool IsSessionActive()
   {
      return GetCurrentSession() != SESSION_INACTIVE;
   }
   
   double GetSessionMultiplier()
   {
      ENUM_SESSION_TYPE session = GetCurrentSession();
      switch(session)
      {
         case SESSION_OVERLAP: return 1.5;
         case SESSION_LONDON: return 1.2;
         case SESSION_NEW_YORK: return 1.1;
         default: return 0.5;
      }
   }
};

//+------------------------------------------------------------------+
//| Sistema de Pesos Adaptativos                                     |
//+------------------------------------------------------------------+
class CAdaptiveWeightSystem : public CObject
{
private:
   double m_performance_history[100];
   int m_history_index;
   bool m_history_full;
   
public:
   CAdaptiveWeightSystem() : m_history_index(0), m_history_full(false)
   {
      ArrayInitialize(m_performance_history, 0.0);
   }
   
   void UpdatePerformance(double performance)
   {
      m_performance_history[m_history_index] = performance;
      m_history_index++;
      
      if(m_history_index >= 100)
      {
         m_history_index = 0;
         m_history_full = true;
      }
   }
   
   double CalculateAdaptiveWeight(string analyzer_name, double base_weight)
   {
      if(!m_history_full && m_history_index < 10)
         return base_weight;
      
      int count = m_history_full ? 100 : m_history_index;
      double sum = 0.0;
      
      for(int i = 0; i < count; i++)
         sum += m_performance_history[i];
      
      double avg_performance = sum / count;
      
      // Ajustar peso baseado na performance
      if(avg_performance > 0.6)
         return base_weight * 1.2;
      else if(avg_performance < 0.4)
         return base_weight * 0.8;
      
      return base_weight;
   }
};

//+------------------------------------------------------------------+
//| Engine Principal de Sinais Avançados                            |
//+------------------------------------------------------------------+
class CAdvancedSignalEngine : public CObject
{
private:
   CArrayObj m_analyzers;
   CSessionFilter* m_session_filter;
   CAdaptiveWeightSystem* m_weight_system;
   
   // Parâmetros de configuração
   double m_min_confidence_threshold;
   double m_min_total_score;
   int m_min_signal_count;
   
public:
   CAdvancedSignalEngine(double min_confidence = 0.6, double min_score = 2.0, int min_signals = 2)
      : m_min_confidence_threshold(min_confidence), m_min_total_score(min_score), m_min_signal_count(min_signals)
   {
      m_session_filter = new CSessionFilter(true, true, true);
      m_weight_system = new CAdaptiveWeightSystem();
      
      InitializeAnalyzers();
   }
   
   ~CAdvancedSignalEngine()
   {
      if(m_session_filter != NULL) delete m_session_filter;
      if(m_weight_system != NULL) delete m_weight_system;
      
      for(int i = 0; i < m_analyzers.Total(); i++)
      {
         CSignalAnalyzer* analyzer = m_analyzers.At(i);
         if(analyzer != NULL) delete analyzer;
      }
   }
   
   void InitializeAnalyzers()
   {
      // Adicionar analisadores
      m_analyzers.Add(new CRSIMultiTimeframeAnalyzer(14, 30, 70));
      m_analyzers.Add(new CMAConfluenceAnalyzer(21, 50, MODE_EMA));
      m_analyzers.Add(new CVolumeAnalyzer(20, 1.5));
      m_analyzers.Add(new COrderBlockDetector(50, 0.0001));
      m_analyzers.Add(new CATRBreakoutDetector(14, 1.5));
   }
   
   SConfluenceResult AnalyzeConfluence(ENUM_TIMEFRAMES primary_timeframe = PERIOD_M15)
   {
      SConfluenceResult result;
      result.final_signal = SIGNAL_NEUTRAL;
      result.total_score = 0.0;
      result.confidence_level = 0.0;
      result.signal_count = 0;
      result.analysis_summary = "";
      
      // Verificar se a sessão está ativa
      if(!m_session_filter.IsSessionActive())
      {
         result.analysis_summary = "Sessão inativa - trading suspenso";
         return result;
      }
      
      double session_multiplier = m_session_filter.GetSessionMultiplier();
      
      // Coletar sinais de todos os analisadores
      double buy_score = 0.0, sell_score = 0.0;
      int buy_count = 0, sell_count = 0;
      
      ENUM_TIMEFRAMES timeframes[4] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1};
      
      for(int tf = 0; tf < 4; tf++)
      {
         double tf_weight = GetTimeframeWeight(timeframes[tf]);
         
         for(int i = 0; i < m_analyzers.Total(); i++)
         {
            CSignalAnalyzer* analyzer = m_analyzers.At(i);
            if(analyzer == NULL || !analyzer.IsEnabled()) continue;
            
            SSignalData signal = analyzer.AnalyzeSignal(timeframes[tf]);
            
            if(signal.confidence >= m_min_confidence_threshold)
            {
               double adaptive_weight = m_weight_system.CalculateAdaptiveWeight(
                  analyzer.GetName(), analyzer.GetWeight());
               
               double weighted_score = signal.confidence * adaptive_weight * tf_weight * session_multiplier;
               
               if(signal.signal_type == SIGNAL_BUY)
               {
                  buy_score += weighted_score;
                  buy_count++;
               }
               else if(signal.signal_type == SIGNAL_SELL)
               {
                  sell_score += weighted_score;
                  sell_count++;
               }
               
               result.signal_count++;
            }
         }
      }
      
      // Determinar sinal final
      if(buy_score > sell_score && buy_score >= m_min_total_score && buy_count >= m_min_signal_count)
      {
         result.final_signal = SIGNAL_BUY;
         result.total_score = buy_score;
         result.confidence_level = MathMin(buy_score / (buy_score + sell_score), 1.0);
         result.analysis_summary = StringFormat("COMPRA: Score=%.2f, Sinais=%d, Confiança=%.1f%%", 
                                              buy_score, buy_count, result.confidence_level * 100);
      }
      else if(sell_score > buy_score && sell_score >= m_min_total_score && sell_count >= m_min_signal_count)
      {
         result.final_signal = SIGNAL_SELL;
         result.total_score = sell_score;
         result.confidence_level = MathMin(sell_score / (buy_score + sell_score), 1.0);
         result.analysis_summary = StringFormat("VENDA: Score=%.2f, Sinais=%d, Confiança=%.1f%%", 
                                              sell_score, sell_count, result.confidence_level * 100);
      }
      else
      {
         result.analysis_summary = StringFormat("NEUTRO: Buy=%.2f(%d), Sell=%.2f(%d) - Critérios não atendidos", 
                                              buy_score, buy_count, sell_score, sell_count);
      }
      
      return result;
   }
   
   void UpdatePerformance(double performance)
   {
      m_weight_system.UpdatePerformance(performance);
   }
   
   void SetMinConfidenceThreshold(double threshold) { m_min_confidence_threshold = threshold; }
   void SetMinTotalScore(double score) { m_min_total_score = score; }
   void SetMinSignalCount(int count) { m_min_signal_count = count; }
   
   // Getters para métricas
   double GetMinConfidenceThreshold() const { return m_min_confidence_threshold; }
   double GetMinTotalScore() const { return m_min_total_score; }
   int GetMinSignalCount() const { return m_min_signal_count; }
   
private:
   double GetTimeframeWeight(ENUM_TIMEFRAMES tf)
   {
      switch(tf)
      {
         case PERIOD_M1: return 0.1;
         case PERIOD_M5: return 0.25;
         case PERIOD_M15: return 0.35;
         case PERIOD_H1: return 0.3;
         default: return 0.1;
      }
   }
};

//+------------------------------------------------------------------+