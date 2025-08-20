//+------------------------------------------------------------------+
//| CSignalConfluence.mqh                                            |
//| Copyright 2024, TradeDev_Master                                  |
//| FTMO SCALPER ELITE v2.0 - Signal Confluence System              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "2.00"
#property strict

#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include "CAdvancedSignalEngine.mqh"
#include "CDynamicLevels.mqh"

//+------------------------------------------------------------------+
//| Enumerações e Estruturas                                         |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_STRENGTH
{
   SIGNAL_VERY_WEAK = 1,
   SIGNAL_WEAK = 2,
   SIGNAL_MODERATE = 3,
   SIGNAL_STRONG = 4,
   SIGNAL_VERY_STRONG = 5
};

enum ENUM_CONFLUENCE_RESULT
{
   CONFLUENCE_NO_SIGNAL = 0,
   CONFLUENCE_WEAK_BUY = 1,
   CONFLUENCE_MODERATE_BUY = 2,
   CONFLUENCE_STRONG_BUY = 3,
   CONFLUENCE_WEAK_SELL = -1,
   CONFLUENCE_MODERATE_SELL = -2,
   CONFLUENCE_STRONG_SELL = -3
};

struct SSignalComponent
{
   string name;
   ENUM_SIGNAL_DIRECTION direction;
   double strength;
   double weight;
   string description;
   datetime timestamp;
};

struct SConfluenceAnalysis
{
   ENUM_CONFLUENCE_RESULT final_signal;
   double total_score;
   double buy_score;
   double sell_score;
   double confidence_level;
   int active_signals_count;
   string analysis_summary;
   SSignalComponent components[20]; // Máximo 20 componentes
   int components_count;
   SDynamicLevelsResult levels_data;
};

struct SConfluenceSettings
{
   // Pesos dos componentes (0.0 - 1.0)
   double rsi_weight;
   double ma_confluence_weight;
   double volume_weight;
   double order_blocks_weight;
   double atr_breakout_weight;
   double session_filter_weight;
   double correlation_weight;
   
   // Thresholds
   double min_confluence_score;
   double strong_signal_threshold;
   double very_strong_threshold;
   
   // Filtros
   bool enable_session_filter;
   bool enable_correlation_filter;
   bool enable_volume_filter;
   bool enable_atr_filter;
};

//+------------------------------------------------------------------+
//| Sistema de Confluência de Sinais                                 |
//+------------------------------------------------------------------+
class CSignalConfluence : public CObject
{
private:
   CAdvancedSignalEngine* m_signal_engine;
   CDynamicLevels* m_levels_calculator;
   
   SConfluenceSettings m_settings;
   SConfluenceAnalysis m_last_analysis;
   
   // Histórico de sinais para análise de performance
   CArrayObj m_signal_history;
   
   // Controle de tempo
   datetime m_last_analysis_time;
   int m_analysis_interval_seconds;
   
public:
   CSignalConfluence()
   {
      m_signal_engine = new CAdvancedSignalEngine();
      m_levels_calculator = new CDynamicLevels();
      
      InitializeDefaultSettings();
      
      m_last_analysis_time = 0;
      m_analysis_interval_seconds = 30; // Análise a cada 30 segundos
      
      ZeroMemory(m_last_analysis);
   }
   
   ~CSignalConfluence()
   {
      if(m_signal_engine != NULL) delete m_signal_engine;
      if(m_levels_calculator != NULL) delete m_levels_calculator;
      m_signal_history.Clear();
   }
   
   //+------------------------------------------------------------------+
   //| Inicializar configurações padrão                                 |
   //+------------------------------------------------------------------+
   void InitializeDefaultSettings()
   {
      // Pesos otimizados para XAUUSD scalping
      m_settings.rsi_weight = 0.20;
      m_settings.ma_confluence_weight = 0.25;
      m_settings.volume_weight = 0.15;
      m_settings.order_blocks_weight = 0.25;
      m_settings.atr_breakout_weight = 0.10;
      m_settings.session_filter_weight = 0.05;
      m_settings.correlation_weight = 0.10;
      
      // Thresholds calibrados
      m_settings.min_confluence_score = 0.60;
      m_settings.strong_signal_threshold = 0.75;
      m_settings.very_strong_threshold = 0.85;
      
      // Filtros ativos
      m_settings.enable_session_filter = true;
      m_settings.enable_correlation_filter = true;
      m_settings.enable_volume_filter = true;
      m_settings.enable_atr_filter = true;
   }
   
   //+------------------------------------------------------------------+
   //| Análise principal de confluência                                 |
   //+------------------------------------------------------------------+
   SConfluenceAnalysis AnalyzeConfluence(ENUM_TIMEFRAMES primary_timeframe = PERIOD_M15)
   {
      // Verificar se é hora de nova análise
      datetime current_time = TimeCurrent();
      if(current_time - m_last_analysis_time < m_analysis_interval_seconds)
         return m_last_analysis;
      
      SConfluenceAnalysis analysis;
      ZeroMemory(analysis);
      analysis.components_count = 0;
      
      // 1. Coletar sinais de todos os componentes
      CollectRSISignals(analysis, primary_timeframe);
      CollectMAConfluenceSignals(analysis, primary_timeframe);
      CollectVolumeSignals(analysis, primary_timeframe);
      CollectOrderBlockSignals(analysis, primary_timeframe);
      CollectATRBreakoutSignals(analysis, primary_timeframe);
      
      // 2. Aplicar filtros
      if(m_settings.enable_session_filter)
         ApplySessionFilter(analysis);
      
      if(m_settings.enable_correlation_filter)
         ApplyCorrelationFilter(analysis);
      
      // 3. Calcular scores finais
      CalculateFinalScores(analysis);
      
      // 4. Determinar sinal final
      DetermineFinalSignal(analysis);
      
      // 5. Calcular níveis dinâmicos se houver sinal
      if(analysis.final_signal != CONFLUENCE_NO_SIGNAL)
      {
         ENUM_ORDER_TYPE order_type = (analysis.final_signal > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         double entry_price = (order_type == ORDER_TYPE_BUY) ? 
                             SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                             SymbolInfoDouble(_Symbol, SYMBOL_BID);
         
         analysis.levels_data = m_levels_calculator.CalculateDynamicLevels(order_type, entry_price, 0.01, primary_timeframe);
      }
      
      // 6. Gerar resumo da análise
      GenerateAnalysisSummary(analysis);
      
      // 7. Salvar análise
      m_last_analysis = analysis;
      m_last_analysis_time = current_time;
      
      return analysis;
   }
   
   //+------------------------------------------------------------------+
   //| Coletar sinais RSI multi-timeframe                               |
   //+------------------------------------------------------------------+
   void CollectRSISignals(SConfluenceAnalysis &analysis, ENUM_TIMEFRAMES primary_tf)
   {
      SMultiTimeframeSignal rsi_signal = m_signal_engine.AnalyzeRSIMultiTimeframe(primary_tf);
      
      if(rsi_signal.signal_strength > 0)
      {
         SSignalComponent component;
         component.name = "RSI_MultiTF";
         component.direction = rsi_signal.primary_direction;
         component.strength = rsi_signal.signal_strength;
         component.weight = m_settings.rsi_weight;
         component.description = StringFormat("RSI: %.1f | TFs: %d/%d", 
                                            rsi_signal.confluence_score, 
                                            rsi_signal.confirming_timeframes, 
                                            rsi_signal.total_timeframes);
         component.timestamp = TimeCurrent();
         
         AddSignalComponent(analysis, component);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Coletar sinais de confluência de MAs                             |
   //+------------------------------------------------------------------+
   void CollectMAConfluenceSignals(SConfluenceAnalysis &analysis, ENUM_TIMEFRAMES primary_tf)
   {
      SMAConfluenceSignal ma_signal = m_signal_engine.AnalyzeMAConfluence(primary_tf);
      
      if(ma_signal.signal_strength > 0)
      {
         SSignalComponent component;
         component.name = "MA_Confluence";
         component.direction = ma_signal.direction;
         component.strength = ma_signal.signal_strength;
         component.weight = m_settings.ma_confluence_weight;
         component.description = StringFormat("MA Conf: %.1f | Align: %d/%d", 
                                            ma_signal.confluence_score,
                                            ma_signal.aligned_mas,
                                            ma_signal.total_mas);
         component.timestamp = TimeCurrent();
         
         AddSignalComponent(analysis, component);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Coletar sinais de volume                                         |
   //+------------------------------------------------------------------+
   void CollectVolumeSignals(SConfluenceAnalysis &analysis, ENUM_TIMEFRAMES primary_tf)
   {
      SVolumeSignal volume_signal = m_signal_engine.AnalyzeVolumeSignal(primary_tf);
      
      if(volume_signal.signal_strength > 0)
      {
         SSignalComponent component;
         component.name = "Volume_Analysis";
         component.direction = volume_signal.direction;
         component.strength = volume_signal.signal_strength;
         component.weight = m_settings.volume_weight;
         component.description = StringFormat("Vol: %.1f | Surge: %s | OBV: %s", 
                                            volume_signal.volume_ratio,
                                            volume_signal.is_volume_surge ? "SIM" : "NÃO",
                                            EnumToString(volume_signal.obv_trend));
         component.timestamp = TimeCurrent();
         
         AddSignalComponent(analysis, component);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Coletar sinais de Order Blocks                                   |
   //+------------------------------------------------------------------+
   void CollectOrderBlockSignals(SConfluenceAnalysis &analysis, ENUM_TIMEFRAMES primary_tf)
   {
      SOrderBlockSignal ob_signal = m_signal_engine.AnalyzeOrderBlocks(primary_tf);
      
      if(ob_signal.signal_strength > 0)
      {
         SSignalComponent component;
         component.name = "Order_Blocks";
         component.direction = ob_signal.direction;
         component.strength = ob_signal.signal_strength;
         component.weight = m_settings.order_blocks_weight;
         component.description = StringFormat("OB: %s | Dist: %.1f pips | Score: %.1f", 
                                            EnumToString(ob_signal.block_type),
                                            ob_signal.distance_to_block / _Point / 10,
                                            ob_signal.block_strength);
         component.timestamp = TimeCurrent();
         
         AddSignalComponent(analysis, component);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Coletar sinais de breakout ATR                                   |
   //+------------------------------------------------------------------+
   void CollectATRBreakoutSignals(SConfluenceAnalysis &analysis, ENUM_TIMEFRAMES primary_tf)
   {
      SATRBreakoutSignal atr_signal = m_signal_engine.AnalyzeATRBreakout(primary_tf);
      
      if(atr_signal.signal_strength > 0)
      {
         SSignalComponent component;
         component.name = "ATR_Breakout";
         component.direction = atr_signal.direction;
         component.strength = atr_signal.signal_strength;
         component.weight = m_settings.atr_breakout_weight;
         component.description = StringFormat("ATR Break: %.1f%% | Vol: %.1fx", 
                                            atr_signal.breakout_percentage * 100,
                                            atr_signal.volume_confirmation);
         component.timestamp = TimeCurrent();
         
         AddSignalComponent(analysis, component);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Aplicar filtro de sessão                                         |
   //+------------------------------------------------------------------+
   void ApplySessionFilter(SConfluenceAnalysis &analysis)
   {
      if(!m_signal_engine.IsActiveSession())
      {
         // Reduzir força de todos os sinais durante sessões inativas
         for(int i = 0; i < analysis.components_count; i++)
         {
            analysis.components[i].strength *= 0.7; // Redução de 30%
         }
         
         SSignalComponent filter_component;
         filter_component.name = "Session_Filter";
         filter_component.direction = SIGNAL_NEUTRAL;
         filter_component.strength = -0.2; // Penalidade
         filter_component.weight = m_settings.session_filter_weight;
         filter_component.description = "Sessão inativa - sinais reduzidos";
         filter_component.timestamp = TimeCurrent();
         
         AddSignalComponent(analysis, filter_component);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Aplicar filtro de correlação                                     |
   //+------------------------------------------------------------------+
   void ApplyCorrelationFilter(SConfluenceAnalysis &analysis)
   {
      double dxy_correlation = m_signal_engine.GetDXYCorrelation();
      
      if(MathAbs(dxy_correlation) > 0.7) // Correlação forte
      {
         SSignalComponent correlation_component;
         correlation_component.name = "DXY_Correlation";
         correlation_component.direction = (dxy_correlation > 0) ? SIGNAL_SELL : SIGNAL_BUY;
         correlation_component.strength = MathAbs(dxy_correlation);
         correlation_component.weight = m_settings.correlation_weight;
         correlation_component.description = StringFormat("DXY Corr: %.2f", dxy_correlation);
         correlation_component.timestamp = TimeCurrent();
         
         AddSignalComponent(analysis, correlation_component);
      }
   }
   
   //+------------------------------------------------------------------+
   //| Calcular scores finais                                           |
   //+------------------------------------------------------------------+
   void CalculateFinalScores(SConfluenceAnalysis &analysis)
   {
      analysis.buy_score = 0;
      analysis.sell_score = 0;
      analysis.active_signals_count = 0;
      
      for(int i = 0; i < analysis.components_count; i++)
      {
         SSignalComponent comp = analysis.components[i];
         double weighted_strength = comp.strength * comp.weight;
         
         if(comp.direction == SIGNAL_BUY)
         {
            analysis.buy_score += weighted_strength;
            analysis.active_signals_count++;
         }
         else if(comp.direction == SIGNAL_SELL)
         {
            analysis.sell_score += weighted_strength;
            analysis.active_signals_count++;
         }
         // SIGNAL_NEUTRAL contribui para ambos os scores (filtros)
         else if(comp.direction == SIGNAL_NEUTRAL)
         {
            analysis.buy_score += weighted_strength;
            analysis.sell_score += weighted_strength;
         }
      }
      
      // Score total é a diferença entre buy e sell
      analysis.total_score = analysis.buy_score - analysis.sell_score;
      
      // Calcular nível de confiança baseado na quantidade e força dos sinais
      double max_possible_score = 0;
      for(int i = 0; i < analysis.components_count; i++)
      {
         max_possible_score += analysis.components[i].weight;
      }
      
      if(max_possible_score > 0)
      {
         analysis.confidence_level = MathMax(analysis.buy_score, analysis.sell_score) / max_possible_score;
      }
   }
   
   //+------------------------------------------------------------------+
   //| Determinar sinal final                                           |
   //+------------------------------------------------------------------+
   void DetermineFinalSignal(SConfluenceAnalysis &analysis)
   {
      double abs_score = MathAbs(analysis.total_score);
      
      // Verificar se atende o score mínimo
      if(abs_score < m_settings.min_confluence_score)
      {
         analysis.final_signal = CONFLUENCE_NO_SIGNAL;
         return;
      }
      
      // Determinar direção e força
      bool is_buy = analysis.total_score > 0;
      
      ENUM_CONFLUENCE_RESULT signal;
      
      if(abs_score >= m_settings.very_strong_threshold)
      {
         signal = is_buy ? CONFLUENCE_STRONG_BUY : CONFLUENCE_STRONG_SELL;
      }
      else if(abs_score >= m_settings.strong_signal_threshold)
      {
         signal = is_buy ? CONFLUENCE_MODERATE_BUY : CONFLUENCE_MODERATE_SELL;
      }
      else
      {
         signal = is_buy ? CONFLUENCE_WEAK_BUY : CONFLUENCE_WEAK_SELL;
      }
      
      analysis.final_signal = signal;
   }
   
   //+------------------------------------------------------------------+
   //| Gerar resumo da análise                                          |
   //+------------------------------------------------------------------+
   void GenerateAnalysisSummary(SConfluenceAnalysis &analysis)
   {
      string summary = "";
      
      // Sinal principal
      switch(analysis.final_signal)
      {
         case CONFLUENCE_NO_SIGNAL:
            summary = "SEM SINAL";
            break;
         case CONFLUENCE_WEAK_BUY:
            summary = "COMPRA FRACA";
            break;
         case CONFLUENCE_MODERATE_BUY:
            summary = "COMPRA MODERADA";
            break;
         case CONFLUENCE_STRONG_BUY:
            summary = "COMPRA FORTE";
            break;
         case CONFLUENCE_WEAK_SELL:
            summary = "VENDA FRACA";
            break;
         case CONFLUENCE_MODERATE_SELL:
            summary = "VENDA MODERADA";
            break;
         case CONFLUENCE_STRONG_SELL:
            summary = "VENDA FORTE";
            break;
      }
      
      // Adicionar métricas
      summary += StringFormat(" | Score: %.2f | Conf: %.1f%% | Sinais: %d", 
                             analysis.total_score, 
                             analysis.confidence_level * 100, 
                             analysis.active_signals_count);
      
      // Adicionar componentes principais
      summary += " | Componentes: ";
      for(int i = 0; i < MathMin(analysis.components_count, 3); i++)
      {
         if(i > 0) summary += ", ";
         summary += analysis.components[i].name;
      }
      
      analysis.analysis_summary = summary;
   }
   
   //+------------------------------------------------------------------+
   //| Adicionar componente de sinal                                    |
   //+------------------------------------------------------------------+
   void AddSignalComponent(SConfluenceAnalysis &analysis, const SSignalComponent &component)
   {
      if(analysis.components_count < 20)
      {
         analysis.components[analysis.components_count] = component;
         analysis.components_count++;
      }
   }
   
   //+------------------------------------------------------------------+
   //| Getters para informações                                         |
   //+------------------------------------------------------------------+
   SConfluenceAnalysis GetLastAnalysis() const { return m_last_analysis; }
   
   bool HasValidSignal() const 
   { 
      return m_last_analysis.final_signal != CONFLUENCE_NO_SIGNAL; 
   }
   
   bool IsBuySignal() const 
   { 
      return m_last_analysis.final_signal > 0; 
   }
   
   bool IsSellSignal() const 
   { 
      return m_last_analysis.final_signal < 0; 
   }
   
   double GetSignalStrength() const 
   { 
      return MathAbs((double)m_last_analysis.final_signal) / 3.0; 
   }
   
   double GetConfidenceLevel() const 
   { 
      return m_last_analysis.confidence_level; 
   }
   
   //+------------------------------------------------------------------+
   //| Configurações                                                    |
   //+------------------------------------------------------------------+
   void SetConfluenceSettings(const SConfluenceSettings &settings)
   {
      m_settings = settings;
   }
   
   SConfluenceSettings GetConfluenceSettings() const
   {
      return m_settings;
   }
   
   void SetAnalysisInterval(int seconds)
   {
      m_analysis_interval_seconds = MathMax(seconds, 10); // Mínimo 10 segundos
   }
   
   //+------------------------------------------------------------------+
   //| Métodos de validação FTMO                                        |
   //+------------------------------------------------------------------+
   bool IsSignalFTMOCompliant() const
   {
      if(!HasValidSignal()) return false;
      
      // Verificar se os níveis dinâmicos são válidos
      if(m_last_analysis.levels_data.risk_reward_ratio < 1.2) return false;
      
      // Verificar confiança mínima
      if(m_last_analysis.confidence_level < 0.6) return false;
      
      // Verificar se há sinais suficientes
      if(m_last_analysis.active_signals_count < 3) return false;
      
      return true;
   }
   
   //+------------------------------------------------------------------+
   //| Métodos de debug e análise                                       |
   //+------------------------------------------------------------------+
   string GetDetailedAnalysis() const
   {
      if(!HasValidSignal()) return "Nenhum sinal ativo";
      
      string details = "=== ANÁLISE DETALHADA ===\n";
      details += "Sinal: " + m_last_analysis.analysis_summary + "\n";
      details += "\nComponentes:\n";
      
      for(int i = 0; i < m_last_analysis.components_count; i++)
      {
         SSignalComponent comp = m_last_analysis.components[i];
         details += StringFormat("- %s: %s (%.2f x %.2f = %.3f)\n",
                               comp.name,
                               EnumToString(comp.direction),
                               comp.strength,
                               comp.weight,
                               comp.strength * comp.weight);
      }
      
      if(m_last_analysis.levels_data.stop_loss > 0)
      {
         details += "\nNíveis Dinâmicos:\n";
         details += StringFormat("SL: %.5f | TP1: %.5f | TP2: %.5f | TP3: %.5f\n",
                               m_last_analysis.levels_data.stop_loss,
                               m_last_analysis.levels_data.take_profit_1,
                               m_last_analysis.levels_data.take_profit_2,
                               m_last_analysis.levels_data.take_profit_3);
         details += StringFormat("RR: %.1f | Confiança: %.1f%%\n",
                               m_last_analysis.levels_data.risk_reward_ratio,
                               m_last_analysis.levels_data.confidence_score * 100);
      }
      
      return details;
   }
};

//+------------------------------------------------------------------+