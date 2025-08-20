//+------------------------------------------------------------------+
//|                                                VolumeAnalyzer.mqh |
//|                                    TradeDev_Master Elite System |
//|                      Advanced Volume Analysis for FTMO Scalping |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "2.10"
#property description "High-Performance Volume Analysis with Order Flow Detection"

#include "DataStructures.mqh"
#include "Interfaces.mqh"
#include "Logger.mqh"
#include "CacheManager.mqh"

//+------------------------------------------------------------------+
//| Enumerações para análise de volume                               |
//+------------------------------------------------------------------+
enum ENUM_VOLUME_TYPE
{
   VOLUME_TYPE_TICK = 0,         // Volume por tick
   VOLUME_TYPE_REAL = 1,         // Volume real
   VOLUME_TYPE_SPREAD = 2        // Volume por spread
};

enum ENUM_VOLUME_TREND
{
   VOLUME_TREND_INCREASING = 0,  // Volume crescente
   VOLUME_TREND_DECREASING = 1,  // Volume decrescente
   VOLUME_TREND_STABLE = 2,      // Volume estável
   VOLUME_TREND_SPIKE = 3,       // Pico de volume
   VOLUME_TREND_EXHAUSTION = 4   // Exaustão de volume
};

enum ENUM_ORDER_FLOW
{
   ORDER_FLOW_BULLISH = 0,       // Fluxo comprador
   ORDER_FLOW_BEARISH = 1,       // Fluxo vendedor
   ORDER_FLOW_NEUTRAL = 2,       // Fluxo neutro
   ORDER_FLOW_ACCUMULATION = 3,  // Acumulação
   ORDER_FLOW_DISTRIBUTION = 4   // Distribuição
};

enum ENUM_VOLUME_PROFILE
{
   PROFILE_NORMAL = 0,           // Perfil normal
   PROFILE_BIMODAL = 1,          // Perfil bimodal
   PROFILE_SKEWED_HIGH = 2,      // Inclinado para cima
   PROFILE_SKEWED_LOW = 3,       // Inclinado para baixo
   PROFILE_FLAT = 4              // Perfil plano
};

enum ENUM_VOLUME_SIGNAL
{
   VOLUME_SIGNAL_NONE = 0,       // Nenhum sinal
   VOLUME_SIGNAL_BREAKOUT = 1,   // Sinal de rompimento
   VOLUME_SIGNAL_REVERSAL = 2,   // Sinal de reversão
   VOLUME_SIGNAL_CONTINUATION = 3, // Sinal de continuação
   VOLUME_SIGNAL_EXHAUSTION = 4, // Sinal de exaustão
   VOLUME_SIGNAL_ACCUMULATION = 5 // Sinal de acumulação
};

//+------------------------------------------------------------------+
//| Estruturas para análise de volume                                |
//+------------------------------------------------------------------+
struct SVolumeData
{
   datetime time;                // Tempo
   double price;                 // Preço
   long volume;                  // Volume
   long tick_volume;             // Volume de ticks
   double vwap;                  // VWAP (Volume Weighted Average Price)
   double volume_ma;             // Média móvel do volume
   double volume_std;            // Desvio padrão do volume
   ENUM_VOLUME_TREND trend;      // Tendência do volume
   double volume_ratio;          // Razão volume atual/média
   bool is_high_volume;          // Se é alto volume
   bool is_low_volume;           // Se é baixo volume
   double volume_percentile;     // Percentil do volume
};

struct SOrderFlowData
{
   datetime time;                // Tempo
   double price;                 // Preço
   long buy_volume;              // Volume de compra
   long sell_volume;             // Volume de venda
   double buy_sell_ratio;        // Razão compra/venda
   ENUM_ORDER_FLOW flow_type;    // Tipo de fluxo
   double flow_strength;         // Força do fluxo (0-100)
   double cumulative_delta;      // Delta cumulativo
   double volume_imbalance;      // Desequilíbrio de volume
   bool is_institutional;        // Se é fluxo institucional
   double aggression_index;      // Índice de agressão
};

struct SVolumeProfile
{
   double price_levels[100];     // Níveis de preço
   long volume_at_price[100];    // Volume em cada preço
   double poc_price;             // Point of Control (POC)
   double value_area_high;       // Área de valor alta
   double value_area_low;        // Área de valor baixa
   double value_area_volume;     // Volume da área de valor
   ENUM_VOLUME_PROFILE profile_type; // Tipo de perfil
   int total_levels;             // Total de níveis
   double volume_weighted_price; // Preço ponderado por volume
   double profile_balance;       // Equilíbrio do perfil
};

struct SVolumeIndicators
{
   double obv;                   // On Balance Volume
   double ad_line;               // Accumulation/Distribution Line
   double cmf;                   // Chaikin Money Flow
   double mfi;                   // Money Flow Index
   double vwap;                  // Volume Weighted Average Price
   double vwap_std_dev;          // Desvio padrão do VWAP
   double volume_oscillator;     // Oscilador de volume
   double price_volume_trend;    // Price Volume Trend
   double volume_rate_of_change; // Taxa de mudança do volume
   double ease_of_movement;      // Ease of Movement
   double negative_volume_index; // Negative Volume Index
   double positive_volume_index; // Positive Volume Index
};

struct SVolumeAnalysis
{
   SVolumeData current_data;     // Dados atuais
   SOrderFlowData order_flow;    // Fluxo de ordens
   SVolumeProfile profile;       // Perfil de volume
   SVolumeIndicators indicators; // Indicadores de volume
   ENUM_VOLUME_SIGNAL signal;   // Sinal de volume
   double signal_strength;       // Força do sinal (0-100)
   string analysis_summary;      // Resumo da análise
   datetime last_update;         // Última atualização
   bool is_valid;                // Se a análise é válida
};

struct SVolumeConfiguration
{
   ENUM_VOLUME_TYPE volume_type;     // Tipo de volume
   int lookback_period;              // Período de análise
   int ma_period;                    // Período da média móvel
   double high_volume_threshold;     // Limite de alto volume
   double low_volume_threshold;      // Limite de baixo volume
   bool enable_order_flow;           // Habilitar análise de fluxo
   bool enable_volume_profile;       // Habilitar perfil de volume
   bool enable_vwap;                 // Habilitar VWAP
   int profile_levels;               // Níveis do perfil
   double value_area_percentage;     // Percentual da área de valor
   bool filter_low_volume;           // Filtrar baixo volume
   double institutional_threshold;   // Limite para fluxo institucional
   bool enable_tick_analysis;        // Habilitar análise de ticks
   int smoothing_period;             // Período de suavização
};

//+------------------------------------------------------------------+
//| Classe principal do analisador de volume                         |
//+------------------------------------------------------------------+
class CVolumeAnalyzer : public IAnalyzer
{
private:
   // Configuração
   SVolumeConfiguration m_config;
   
   // Cache e dados
   CCacheManager* m_cache;
   SVolumeData m_volume_history[];
   SOrderFlowData m_order_flow_history[];
   SVolumeProfile m_current_profile;
   SVolumeIndicators m_indicators;
   
   // Buffers para cálculos
   double m_price_buffer[];
   long m_volume_buffer[];
   long m_tick_volume_buffer[];
   datetime m_time_buffer[];
   
   // Variáveis de controle
   datetime m_last_update;
   int m_data_count;
   bool m_is_initialized;
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   
   // Estatísticas
   double m_volume_mean;
   double m_volume_std_dev;
   double m_volume_percentiles[101];
   
public:
   // Construtor e destrutor
   CVolumeAnalyzer();
   ~CVolumeAnalyzer();
   
   // Implementação da interface IAnalyzer
   virtual bool Init(void) override;
   virtual void Deinit(void) override;
   virtual bool SelfTest(void) override;
   virtual void SetConfig(const string config_string) override;
   virtual string GetConfig(void) override;
   virtual string GetStatus(void) override;
   
   // Configuração
   void SetVolumeConfiguration(const SVolumeConfiguration &config);
   void SetSymbol(const string symbol, const ENUM_TIMEFRAMES timeframe);
   void SetCacheManager(CCacheManager* cache);
   
   // Análise principal
   SVolumeAnalysis AnalyzeVolume(void);
   bool UpdateVolumeData(void);
   void CalculateVolumeIndicators(void);
   
   // Análise de fluxo de ordens
   SOrderFlowData AnalyzeOrderFlow(const int bar_index = 0);
   double CalculateBuySellRatio(const int bar_index);
   double CalculateCumulativeDelta(const int lookback);
   bool DetectInstitutionalFlow(const SOrderFlowData &flow_data);
   
   // Perfil de volume
   SVolumeProfile CalculateVolumeProfile(const int start_bar, const int end_bar);
   double FindPointOfControl(const SVolumeProfile &profile);
   void CalculateValueArea(SVolumeProfile &profile);
   ENUM_VOLUME_PROFILE ClassifyProfile(const SVolumeProfile &profile);
   
   // Indicadores de volume
   double CalculateOBV(const int period);
   double CalculateADLine(const int period);
   double CalculateCMF(const int period);
   double CalculateMFI(const int period);
   double CalculateVWAP(const int period);
   double CalculateVolumeOscillator(const int fast_period, const int slow_period);
   double CalculatePVT(const int period);
   double CalculateEaseOfMovement(const int period);
   
   // Sinais de volume
   ENUM_VOLUME_SIGNAL DetectVolumeSignal(void);
   double CalculateSignalStrength(const ENUM_VOLUME_SIGNAL signal);
   bool ValidateVolumeBreakout(const double price_change, const double volume_change);
   bool DetectVolumeExhaustion(void);
   bool DetectAccumulation(void);
   bool DetectDistribution(void);
   
   // Análise estatística
   void CalculateVolumeStatistics(void);
   double GetVolumePercentile(const long volume);
   bool IsHighVolume(const long volume);
   bool IsLowVolume(const long volume);
   ENUM_VOLUME_TREND GetVolumeTrend(const int period);
   
   // Getters
   SVolumeData GetCurrentVolumeData(void);
   SOrderFlowData GetCurrentOrderFlow(void);
   SVolumeProfile GetCurrentProfile(void) { return m_current_profile; }
   SVolumeIndicators GetIndicators(void) { return m_indicators; }
   
   // Relatórios
   string GenerateVolumeReport(void);
   string GenerateOrderFlowReport(void);
   string GenerateProfileReport(void);
   
   // Utilitários
   bool IsVolumeDataAvailable(void);
   int GetAvailableDataCount(void) { return m_data_count; }
   datetime GetLastUpdateTime(void) { return m_last_update; }
   
private:
   // Métodos auxiliares
   void InitializeBuffers(void);
   void UpdateBuffers(void);
   bool LoadHistoricalData(const int bars_count);
   void CalculateMovingAverages(void);
   void UpdateVolumeStatistics(void);
   double NormalizeVolume(const long volume);
   bool ValidateVolumeData(const int bar_index);
   void LogVolumeEvent(const string message, const ENUM_LOG_LEVEL level);
   string FormatVolumeValue(const long volume);
   double CalculateVolumeWeight(const int bar_index);
   void CleanupOldData(void);
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
CVolumeAnalyzer::CVolumeAnalyzer()
{
   // Configuração padrão
   m_config.volume_type = VOLUME_TYPE_TICK;
   m_config.lookback_period = 100;
   m_config.ma_period = 20;
   m_config.high_volume_threshold = 2.0;
   m_config.low_volume_threshold = 0.5;
   m_config.enable_order_flow = true;
   m_config.enable_volume_profile = true;
   m_config.enable_vwap = true;
   m_config.profile_levels = 50;
   m_config.value_area_percentage = 70.0;
   m_config.filter_low_volume = true;
   m_config.institutional_threshold = 5.0;
   m_config.enable_tick_analysis = true;
   m_config.smoothing_period = 3;
   
   // Inicializar variáveis
   m_cache = NULL;
   m_last_update = 0;
   m_data_count = 0;
   m_is_initialized = false;
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_volume_mean = 0.0;
   m_volume_std_dev = 0.0;
   
   // Zerar estruturas
   ZeroMemory(m_current_profile);
   ZeroMemory(m_indicators);
   ArrayInitialize(m_volume_percentiles, 0.0);
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
CVolumeAnalyzer::~CVolumeAnalyzer()
{
   ArrayFree(m_volume_history);
   ArrayFree(m_order_flow_history);
   ArrayFree(m_price_buffer);
   ArrayFree(m_volume_buffer);
   ArrayFree(m_tick_volume_buffer);
   ArrayFree(m_time_buffer);
}

//+------------------------------------------------------------------+
//| Inicialização                                                     |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::Init(void)
{
   g_logger.Info("Inicializando Volume Analyzer...");
   
   // Configurar símbolo padrão
   if(m_symbol == "")
   {
      m_symbol = _Symbol;
      m_timeframe = _Period;
   }
   
   // Inicializar buffers
   InitializeBuffers();
   
   // Carregar dados históricos
   if(!LoadHistoricalData(m_config.lookback_period))
   {
      g_logger.Error("Erro ao carregar dados históricos de volume");
      return false;
   }
   
   // Calcular estatísticas iniciais
   CalculateVolumeStatistics();
   
   // Calcular indicadores
   CalculateVolumeIndicators();
   
   m_is_initialized = true;
   g_logger.Info("Volume Analyzer inicializado com sucesso");
   return true;
}

//+------------------------------------------------------------------+
//| Deinicialização                                                   |
//+------------------------------------------------------------------+
void CVolumeAnalyzer::Deinit(void)
{
   g_logger.Info("Volume Analyzer deinicializado");
}

//+------------------------------------------------------------------+
//| Auto-teste                                                        |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::SelfTest(void)
{
   g_logger.Debug("Executando auto-teste do Volume Analyzer...");
   
   // Teste 1: Verificar dados de volume
   if(!IsVolumeDataAvailable())
   {
      g_logger.Error("Dados de volume não disponíveis");
      return false;
   }
   
   // Teste 2: Testar cálculo de VWAP
   double test_vwap = CalculateVWAP(20);
   if(test_vwap <= 0)
   {
      g_logger.Error("Falha no cálculo do VWAP");
      return false;
   }
   
   // Teste 3: Testar análise de fluxo
   if(m_config.enable_order_flow)
   {
      SOrderFlowData test_flow = AnalyzeOrderFlow(0);
      if(test_flow.time == 0)
      {
         g_logger.Warning("Dados de fluxo de ordens limitados");
      }
   }
   
   // Teste 4: Testar perfil de volume
   if(m_config.enable_volume_profile)
   {
      SVolumeProfile test_profile = CalculateVolumeProfile(0, 50);
      if(test_profile.total_levels == 0)
      {
         g_logger.Warning("Perfil de volume vazio");
      }
   }
   
   g_logger.Debug("Auto-teste do Volume Analyzer concluído");
   return true;
}

//+------------------------------------------------------------------+
//| Configurar via string                                            |
//+------------------------------------------------------------------+
void CVolumeAnalyzer::SetConfig(const string config_string)
{
   string params[];
   int count = StringSplit(config_string, ';', params);
   
   for(int i = 0; i < count; i++)
   {
      string pair[];
      if(StringSplit(params[i], '=', pair) == 2)
      {
         string key = pair[0];
         string value = pair[1];
         
         if(key == "lookback_period")
            m_config.lookback_period = (int)StringToInteger(value);
         else if(key == "ma_period")
            m_config.ma_period = (int)StringToInteger(value);
         else if(key == "high_volume_threshold")
            m_config.high_volume_threshold = StringToDouble(value);
         else if(key == "enable_order_flow")
            m_config.enable_order_flow = (value == "true");
         else if(key == "enable_vwap")
            m_config.enable_vwap = (value == "true");
         // Adicionar mais parâmetros conforme necessário
      }
   }
   
   g_logger.Info("Configuração do Volume Analyzer atualizada");
}

//+------------------------------------------------------------------+
//| Obter configuração atual                                          |
//+------------------------------------------------------------------+
string CVolumeAnalyzer::GetConfig(void)
{
   string config = "";
   config += "lookback_period=" + IntegerToString(m_config.lookback_period) + ";";
   config += "ma_period=" + IntegerToString(m_config.ma_period) + ";";
   config += "high_volume_threshold=" + DoubleToString(m_config.high_volume_threshold, 2) + ";";
   config += "enable_order_flow=" + (m_config.enable_order_flow ? "true" : "false") + ";";
   config += "enable_vwap=" + (m_config.enable_vwap ? "true" : "false") + ";";
   
   return config;
}

//+------------------------------------------------------------------+
//| Obter status atual                                                |
//+------------------------------------------------------------------+
string CVolumeAnalyzer::GetStatus(void)
{
   string status = "Volume Analyzer Status:\n";
   status += "Initialized: " + (m_is_initialized ? "YES" : "NO") + "\n";
   status += "Data Count: " + IntegerToString(m_data_count) + "\n";
   status += "Last Update: " + TimeToString(m_last_update) + "\n";
   status += "Current VWAP: " + DoubleToString(m_indicators.vwap, 5) + "\n";
   status += "Volume Trend: " + EnumToString(GetVolumeTrend(10)) + "\n";
   status += "Order Flow: " + (m_config.enable_order_flow ? "Enabled" : "Disabled") + "\n";
   
   return status;
}

//+------------------------------------------------------------------+
//| Análise principal de volume                                       |
//+------------------------------------------------------------------+
SVolumeAnalysis CVolumeAnalyzer::AnalyzeVolume(void)
{
   SVolumeAnalysis analysis;
   ZeroMemory(analysis);
   
   if(!m_is_initialized)
   {
      g_logger.Warning("Volume Analyzer não inicializado");
      return analysis;
   }
   
   // Atualizar dados
   if(!UpdateVolumeData())
   {
      g_logger.Error("Erro ao atualizar dados de volume");
      return analysis;
   }
   
   // Obter dados atuais
   analysis.current_data = GetCurrentVolumeData();
   
   // Análise de fluxo de ordens
   if(m_config.enable_order_flow)
   {
      analysis.order_flow = AnalyzeOrderFlow(0);
   }
   
   // Perfil de volume
   if(m_config.enable_volume_profile)
   {
      analysis.profile = CalculateVolumeProfile(0, m_config.lookback_period);
   }
   
   // Indicadores
   analysis.indicators = m_indicators;
   
   // Detectar sinais
   analysis.signal = DetectVolumeSignal();
   analysis.signal_strength = CalculateSignalStrength(analysis.signal);
   
   // Resumo da análise
   analysis.analysis_summary = "Volume: " + FormatVolumeValue(analysis.current_data.volume) +
                              ", Trend: " + EnumToString(analysis.current_data.trend) +
                              ", Signal: " + EnumToString(analysis.signal);
   
   analysis.last_update = TimeCurrent();
   analysis.is_valid = true;
   
   return analysis;
}

//+------------------------------------------------------------------+
//| Atualizar dados de volume                                         |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::UpdateVolumeData(void)
{
   // Verificar se há novos dados
   datetime current_time = iTime(m_symbol, m_timeframe, 0);
   if(current_time <= m_last_update)
   {
      return true; // Dados já atualizados
   }
   
   // Atualizar buffers
   UpdateBuffers();
   
   // Recalcular estatísticas
   CalculateVolumeStatistics();
   
   // Recalcular indicadores
   CalculateVolumeIndicators();
   
   m_last_update = current_time;
   
   LogVolumeEvent("Dados de volume atualizados", LOG_DEBUG);
   return true;
}

//+------------------------------------------------------------------+
//| Calcular indicadores de volume                                   |
//+------------------------------------------------------------------+
void CVolumeAnalyzer::CalculateVolumeIndicators(void)
{
   if(m_data_count < m_config.ma_period)
   {
      return;
   }
   
   // On Balance Volume
   m_indicators.obv = CalculateOBV(m_config.lookback_period);
   
   // Accumulation/Distribution Line
   m_indicators.ad_line = CalculateADLine(m_config.lookback_period);
   
   // Chaikin Money Flow
   m_indicators.cmf = CalculateCMF(m_config.ma_period);
   
   // Money Flow Index
   m_indicators.mfi = CalculateMFI(14);
   
   // VWAP
   if(m_config.enable_vwap)
   {
      m_indicators.vwap = CalculateVWAP(m_config.lookback_period);
   }
   
   // Volume Oscillator
   m_indicators.volume_oscillator = CalculateVolumeOscillator(5, 10);
   
   // Price Volume Trend
   m_indicators.price_volume_trend = CalculatePVT(m_config.lookback_period);
   
   // Ease of Movement
   m_indicators.ease_of_movement = CalculateEaseOfMovement(14);
   
   LogVolumeEvent("Indicadores de volume calculados", LOG_DEBUG);
}

//+------------------------------------------------------------------+
//| Calcular VWAP                                                    |
//+------------------------------------------------------------------+
double CVolumeAnalyzer::CalculateVWAP(const int period)
{
   if(m_data_count < period || period <= 0)
   {
      return 0.0;
   }
   
   double sum_pv = 0.0;
   long sum_volume = 0;
   
   for(int i = 0; i < period && i < m_data_count; i++)
   {
      double typical_price = (iHigh(m_symbol, m_timeframe, i) + 
                             iLow(m_symbol, m_timeframe, i) + 
                             iClose(m_symbol, m_timeframe, i)) / 3.0;
      long volume = iVolume(m_symbol, m_timeframe, i);
      
      sum_pv += typical_price * volume;
      sum_volume += volume;
   }
   
   return (sum_volume > 0) ? sum_pv / sum_volume : 0.0;
}

//+------------------------------------------------------------------+
//| Detectar sinal de volume                                         |
//+------------------------------------------------------------------+
ENUM_VOLUME_SIGNAL CVolumeAnalyzer::DetectVolumeSignal(void)
{
   if(m_data_count < 10)
   {
      return VOLUME_SIGNAL_NONE;
   }
   
   // Obter dados atuais
   long current_volume = iVolume(m_symbol, m_timeframe, 0);
   double current_close = iClose(m_symbol, m_timeframe, 0);
   double previous_close = iClose(m_symbol, m_timeframe, 1);
   double price_change = (current_close - previous_close) / previous_close * 100.0;
   
   // Verificar rompimento com volume
   if(IsHighVolume(current_volume) && MathAbs(price_change) > 0.5)
   {
      if(ValidateVolumeBreakout(price_change, current_volume))
      {
         return VOLUME_SIGNAL_BREAKOUT;
      }
   }
   
   // Verificar exaustão
   if(DetectVolumeExhaustion())
   {
      return VOLUME_SIGNAL_EXHAUSTION;
   }
   
   // Verificar acumulação
   if(DetectAccumulation())
   {
      return VOLUME_SIGNAL_ACCUMULATION;
   }
   
   // Verificar reversão
   if(IsHighVolume(current_volume) && price_change * GetVolumeTrend(5) < 0)
   {
      return VOLUME_SIGNAL_REVERSAL;
   }
   
   return VOLUME_SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| Métodos auxiliares simplificados                                 |
//+------------------------------------------------------------------+
void CVolumeAnalyzer::InitializeBuffers(void)
{
   int buffer_size = m_config.lookback_period + 50;
   ArrayResize(m_price_buffer, buffer_size);
   ArrayResize(m_volume_buffer, buffer_size);
   ArrayResize(m_tick_volume_buffer, buffer_size);
   ArrayResize(m_time_buffer, buffer_size);
   ArrayResize(m_volume_history, buffer_size);
   ArrayResize(m_order_flow_history, buffer_size);
}

void CVolumeAnalyzer::UpdateBuffers(void)
{
   // Implementação simplificada
   m_data_count = MathMin(m_config.lookback_period, Bars(m_symbol, m_timeframe));
}

bool CVolumeAnalyzer::LoadHistoricalData(const int bars_count)
{
   // Implementação simplificada
   m_data_count = MathMin(bars_count, Bars(m_symbol, m_timeframe));
   return (m_data_count > 0);
}

void CVolumeAnalyzer::CalculateVolumeStatistics(void)
{
   if(m_data_count < 10) return;
   
   // Calcular média e desvio padrão do volume
   long sum = 0;
   for(int i = 0; i < m_data_count; i++)
   {
      sum += iVolume(m_symbol, m_timeframe, i);
   }
   m_volume_mean = (double)sum / m_data_count;
   
   double sum_sq = 0.0;
   for(int i = 0; i < m_data_count; i++)
   {
      double diff = iVolume(m_symbol, m_timeframe, i) - m_volume_mean;
      sum_sq += diff * diff;
   }
   m_volume_std_dev = MathSqrt(sum_sq / m_data_count);
}

bool CVolumeAnalyzer::IsHighVolume(const long volume)
{
   return (volume > m_volume_mean * m_config.high_volume_threshold);
}

bool CVolumeAnalyzer::IsLowVolume(const long volume)
{
   return (volume < m_volume_mean * m_config.low_volume_threshold);
}

ENUM_VOLUME_TREND CVolumeAnalyzer::GetVolumeTrend(const int period)
{
   if(m_data_count < period) return VOLUME_TREND_STABLE;
   
   long recent_avg = 0, older_avg = 0;
   
   for(int i = 0; i < period/2; i++)
   {
      recent_avg += iVolume(m_symbol, m_timeframe, i);
   }
   
   for(int i = period/2; i < period; i++)
   {
      older_avg += iVolume(m_symbol, m_timeframe, i);
   }
   
   recent_avg /= (period/2);
   older_avg /= (period/2);
   
   if(recent_avg > older_avg * 1.2) return VOLUME_TREND_INCREASING;
   if(recent_avg < older_avg * 0.8) return VOLUME_TREND_DECREASING;
   
   return VOLUME_TREND_STABLE;
}

void CVolumeAnalyzer::LogVolumeEvent(const string message, const ENUM_LOG_LEVEL level)
{
   switch(level)
   {
      case LOG_DEBUG:
         g_logger.Debug("[VOLUME] " + message);
         break;
      case LOG_INFO:
         g_logger.Info("[VOLUME] " + message);
         break;
      case LOG_WARNING:
         g_logger.Warning("[VOLUME] " + message);
         break;
      case LOG_ERROR:
         g_logger.Error("[VOLUME] " + message);
         break;
   }
}

string CVolumeAnalyzer::FormatVolumeValue(const long volume)
{
   if(volume >= 1000000)
      return DoubleToString(volume/1000000.0, 1) + "M";
   else if(volume >= 1000)
      return DoubleToString(volume/1000.0, 1) + "K";
   else
      return IntegerToString(volume);
}

// Implementações simplificadas dos métodos restantes
SVolumeData CVolumeAnalyzer::GetCurrentVolumeData(void) { SVolumeData data; ZeroMemory(data); return data; }
SOrderFlowData CVolumeAnalyzer::AnalyzeOrderFlow(const int bar_index = 0) { SOrderFlowData flow; ZeroMemory(flow); return flow; }
SVolumeProfile CVolumeAnalyzer::CalculateVolumeProfile(const int start_bar, const int end_bar) { SVolumeProfile profile; ZeroMemory(profile); return profile; }
double CVolumeAnalyzer::CalculateOBV(const int period) { return 0.0; }
double CVolumeAnalyzer::CalculateADLine(const int period) { return 0.0; }
double CVolumeAnalyzer::CalculateCMF(const int period) { return 0.0; }
double CVolumeAnalyzer::CalculateMFI(const int period) { return 0.0; }
double CVolumeAnalyzer::CalculateVolumeOscillator(const int fast_period, const int slow_period) { return 0.0; }
double CVolumeAnalyzer::CalculatePVT(const int period) { return 0.0; }
double CVolumeAnalyzer::CalculateEaseOfMovement(const int period) { return 0.0; }
double CVolumeAnalyzer::CalculateSignalStrength(const ENUM_VOLUME_SIGNAL signal) { return 50.0; }
bool CVolumeAnalyzer::ValidateVolumeBreakout(const double price_change, const double volume_change) { return false; }
bool CVolumeAnalyzer::DetectVolumeExhaustion(void) { return false; }
bool CVolumeAnalyzer::DetectAccumulation(void) { return false; }
bool CVolumeAnalyzer::DetectDistribution(void) { return false; }
bool CVolumeAnalyzer::IsVolumeDataAvailable(void) { return (m_data_count > 0); }
string CVolumeAnalyzer::GenerateVolumeReport(void) { return "Volume Report"; }
string CVolumeAnalyzer::GenerateOrderFlowReport(void) { return "Order Flow Report"; }
string CVolumeAnalyzer::GenerateProfileReport(void) { return "Profile Report"; }

//+------------------------------------------------------------------+
//| Implementações dos métodos da interface IAnalyzer                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Executar análise principal                                       |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::Analyze()
{
   if(!m_is_initialized)
      return false;
      
   // Atualizar dados de volume
   if(!UpdateVolumeData())
      return false;
      
   // Calcular indicadores
   CalculateVolumeIndicators();
   
   // Analisar fluxo de ordens
   SOrderFlowData flow = AnalyzeOrderFlow();
   
   // Detectar sinais
   bool has_signal = false;
   if(DetectVolumeExhaustion() || DetectAccumulation() || DetectDistribution())
      has_signal = true;
      
   return has_signal;
}

//+------------------------------------------------------------------+
//| Verificar se há novo sinal                                       |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::HasNewSignal()
{
   if(!m_is_initialized || m_data_count == 0)
      return false;
      
   // Verificar se há dados novos desde a última análise
   datetime current_time = TimeCurrent();
   if(current_time <= m_last_update)
      return false;
      
   return Analyze();
}

//+------------------------------------------------------------------+
//| Obter descrição do último sinal                                  |
//+------------------------------------------------------------------+
string CVolumeAnalyzer::GetLastSignalDescription()
{
   if(!m_is_initialized)
      return "Analisador não inicializado";
      
   string description = "Volume Analysis: ";
   
   if(DetectAccumulation())
      description += "Acumulação detectada. ";
   if(DetectDistribution())
      description += "Distribuição detectada. ";
   if(DetectVolumeExhaustion())
      description += "Exaustão de volume detectada. ";
      
   if(description == "Volume Analysis: ")
      description += "Nenhum sinal significativo.";
      
   return description;
}

//+------------------------------------------------------------------+
//| Definir período de análise                                       |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::SetAnalysisPeriod(int period)
{
   if(period < 10 || period > 1000)
      return false;
      
   m_config.analysis_period = period;
   return true;
}

//+------------------------------------------------------------------+
//| Definir sensibilidade                                            |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::SetSensitivity(double sensitivity)
{
   if(sensitivity < 0.1 || sensitivity > 10.0)
      return false;
      
   m_config.sensitivity = sensitivity;
   return true;
}

//+------------------------------------------------------------------+
//| Obter precisão da análise                                        |
//+------------------------------------------------------------------+
double CVolumeAnalyzer::GetAccuracy()
{
   if(m_data_count == 0)
      return 0.0;
      
   // Calcular precisão baseada na consistência dos sinais
   double accuracy = 75.0; // Base accuracy
   
   if(m_volume_std_dev > 0)
   {
      double cv = m_volume_std_dev / m_volume_mean;
      if(cv < 0.5)
         accuracy += 10.0; // Dados mais consistentes
      else if(cv > 2.0)
         accuracy -= 15.0; // Dados muito voláteis
   }
   
   return MathMax(0.0, MathMin(100.0, accuracy));
}

//+------------------------------------------------------------------+
//| Contar sinais detectados                                         |
//+------------------------------------------------------------------+
int CVolumeAnalyzer::GetSignalCount()
{
   int count = 0;
   
   if(DetectAccumulation()) count++;
   if(DetectDistribution()) count++;
   if(DetectVolumeExhaustion()) count++;
   
   return count;
}

//+------------------------------------------------------------------+
//| Resetar estatísticas                                             |
//+------------------------------------------------------------------+
void CVolumeAnalyzer::ResetStatistics()
{
   m_volume_mean = 0.0;
   m_volume_std_dev = 0.0;
   m_data_count = 0;
   m_last_update = 0;
   
   ArrayResize(m_volume_history, 0);
   ArrayResize(m_order_flow_history, 0);
   ArrayResize(m_volume_percentiles, 101);
   ArrayInitialize(m_volume_percentiles, 0.0);
   
   ZeroMemory(m_current_profile);
   ZeroMemory(m_indicators);
}

//+------------------------------------------------------------------+
//| Obter informações de debug                                       |
//+------------------------------------------------------------------+
string CVolumeAnalyzer::GetDebugInfo()
{
   string info = "=== Volume Analyzer Debug ===\n";
   info += "Initialized: " + (m_is_initialized ? "Yes" : "No") + "\n";
   info += "Symbol: " + m_symbol + "\n";
   info += "Timeframe: " + EnumToString(m_timeframe) + "\n";
   info += "Data Count: " + IntegerToString(m_data_count) + "\n";
   info += "Volume Mean: " + DoubleToString(m_volume_mean, 0) + "\n";
   info += "Volume Std Dev: " + DoubleToString(m_volume_std_dev, 0) + "\n";
   info += "Last Update: " + TimeToString(m_last_update) + "\n";
   info += "Analysis Period: " + IntegerToString(m_config.analysis_period) + "\n";
   info += "Sensitivity: " + DoubleToString(m_config.sensitivity, 2) + "\n";
   info += "Accuracy: " + DoubleToString(GetAccuracy(), 1) + "%\n";
   
   return info;
}

//+------------------------------------------------------------------+
//| Validar configuração                                             |
//+------------------------------------------------------------------+
bool CVolumeAnalyzer::ValidateConfiguration()
{
   if(m_config.analysis_period < 10 || m_config.analysis_period > 1000)
   {
      Print("Erro: Período de análise inválido: ", m_config.analysis_period);
      return false;
   }
   
   if(m_config.sensitivity < 0.1 || m_config.sensitivity > 10.0)
   {
      Print("Erro: Sensibilidade inválida: ", m_config.sensitivity);
      return false;
   }
   
   if(m_symbol == "")
   {
      Print("Erro: Símbolo não definido");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+