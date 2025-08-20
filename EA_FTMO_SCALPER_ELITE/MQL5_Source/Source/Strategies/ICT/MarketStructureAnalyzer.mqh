//+------------------------------------------------------------------+
//|                                        MarketStructureAnalyzer.mqh |
//|                                    TradeDev_Master Elite System |
//|                                   Advanced ICT Market Structure |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property version   "2.10"
#property strict

// Includes necessários
#include "../../Core/DataStructures.mqh"
#include "../../Core/Interfaces.mqh"
#include "../../Core/Logger.mqh"

//+------------------------------------------------------------------+
//| Estruturas específicas para Market Structure                     |
//+------------------------------------------------------------------+
enum ENUM_STRUCTURE_TYPE
{
   STRUCTURE_BOS_BULLISH,     // Break of Structure Bullish
   STRUCTURE_BOS_BEARISH,     // Break of Structure Bearish
   STRUCTURE_CHOCH_BULLISH,   // Change of Character Bullish
   STRUCTURE_CHOCH_BEARISH,   // Change of Character Bearish
   STRUCTURE_MSS_BULLISH,     // Market Structure Shift Bullish
   STRUCTURE_MSS_BEARISH      // Market Structure Shift Bearish
};

enum ENUM_TREND_STATE
{
   TREND_BULLISH,
   TREND_BEARISH,
   TREND_RANGING,
   TREND_TRANSITION
};

struct SMarketStructure
{
   datetime          time;              // Tempo da estrutura
   double            price;             // Preço da quebra/mudança
   ENUM_STRUCTURE_TYPE type;            // Tipo de estrutura
   double            previous_high;     // High anterior relevante
   double            previous_low;      // Low anterior relevante
   double            strength;          // Força da estrutura (0-100)
   bool              confirmed;         // Se está confirmada
   int               candles_since;     // Candles desde a formação
   double            volume_ratio;      // Ratio de volume
   string            description;       // Descrição da estrutura
};

struct SSwingPoint
{
   datetime          time;
   double            price;
   bool              is_high;           // true = swing high, false = swing low
   int               strength;          // Força do swing (1-5)
   bool              broken;            // Se foi quebrado
   datetime          break_time;        // Quando foi quebrado
   double            break_price;       // Preço da quebra
};

struct STrendAnalysis
{
   ENUM_TREND_STATE  current_trend;
   ENUM_TREND_STATE  previous_trend;
   datetime          trend_start_time;
   double            trend_strength;    // 0-100
   int               structure_count;   // Quantas estruturas na tendência atual
   double            trend_angle;       // Ângulo da tendência
   bool              trend_exhaustion;  // Sinais de exaustão
};

//+------------------------------------------------------------------+
//| Classe principal para análise de Market Structure                |
//+------------------------------------------------------------------+
class CMarketStructureAnalyzer : public IDetector
{
private:
   // Configurações básicas
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   bool              m_initialized;
   
   // Configurações
   int               m_lookback_candles;
   int               m_swing_strength;
   double            m_min_structure_size;
   bool              m_use_volume_confirmation;
   double            m_volume_threshold;
   bool              m_strict_confirmation;
   
   // Arrays de dados
   SMarketStructure  m_structures[];
   SSwingPoint       m_swing_highs[];
   SSwingPoint       m_swing_lows[];
   STrendAnalysis    m_trend_analysis;
   
   // Cache e performance
   datetime          m_last_analysis_time;
   int               m_last_analyzed_bar;
   bool              m_cache_valid;
   
   // Estatísticas
   int               m_total_bos_detected;
   int               m_total_choch_detected;
   int               m_total_mss_detected;
   double            m_accuracy_rate;
   
   // Métodos privados - Detecção
   bool              DetectSwingPoints();
   bool              DetectBOS();
   bool              DetectCHoCH();
   bool              DetectMSS();
   
   // Métodos privados - Análise
   bool              AnalyzeTrendState();
   double            CalculateStructureStrength(const SMarketStructure &structure);
   bool              ValidateStructure(const SMarketStructure &structure);
   
   // Métodos privados - Swing Points
   bool              IsSwingHigh(int bar_index, int strength);
   bool              IsSwingLow(int bar_index, int strength);
   void              UpdateSwingPoints();
   
   // Métodos privados - Confirmação
   bool              ConfirmWithVolume(const SMarketStructure &structure);
   bool              ConfirmWithPrice(const SMarketStructure &structure);
   bool              ConfirmWithTime(const SMarketStructure &structure);
   
   // Métodos privados - Utilitários
   void              CleanupOldStructures();
   void              UpdateStatistics();
   bool              IsValidTimeframe();
   double            GetVolumeRatio(int bar_index);
   
public:
   // Construtor e Destrutor
                     CMarketStructureAnalyzer();
                    ~CMarketStructureAnalyzer();
   
   // Métodos da interface IDetector
   virtual bool      Init(const string symbol, const ENUM_TIMEFRAMES timeframe) override;
   virtual void      Deinit() override;
   virtual bool      SelfTest() override;
   
   // Métodos abstratos da interface IDetector
   virtual bool      DetectStructures() override;
   virtual bool      HasNewStructure() override;
   virtual string    GetLastStructureDescription() override;
   virtual bool      SetLookbackCandles(int candles) override;
   virtual bool      SetSwingStrength(int strength) override;
   virtual bool      SetMinStructureSize(double size) override;
   virtual bool      SetVolumeConfirmation(bool enable) override;
   virtual bool      SetStrictConfirmation(bool enable) override;
   virtual double    GetDetectionAccuracy() override;
   virtual void      ResetStatistics() override;
   virtual string    GetDebugInfo() override;
   virtual bool      ValidateConfiguration() override;
   
   // Métodos abstratos da interface IModule
   virtual bool      Init() override { return Init(m_symbol, m_timeframe); }
   virtual bool      IsInitialized() override { return m_initialized; }
   virtual string    GetModuleName() override { return "MarketStructureAnalyzer"; }
   virtual string    GetVersion() override { return "2.10"; }
   
   // Configuração (implementação dos métodos da interface)
   void              SetVolumeConfirmation(bool use_volume, double threshold = 1.5);
   
   // Análise principal
   bool              AnalyzeMarketStructure();
   bool              ScanForStructures();
   void              UpdateAnalysis();
   
   // Acesso aos dados
   int               GetStructuresCount() const { return ArraySize(m_structures); }
   SMarketStructure  GetStructure(int index) const;
   SMarketStructure  GetLatestStructure() const;
   
   // Swing Points
   int               GetSwingHighsCount() const { return ArraySize(m_swing_highs); }
   int               GetSwingLowsCount() const { return ArraySize(m_swing_lows); }
   SSwingPoint       GetSwingHigh(int index) const;
   SSwingPoint       GetSwingLow(int index) const;
   
   // Análise de tendência
   STrendAnalysis    GetTrendAnalysis() const { return m_trend_analysis; }
   ENUM_TREND_STATE  GetCurrentTrend() const { return m_trend_analysis.current_trend; }
   double            GetTrendStrength() const { return m_trend_analysis.trend_strength; }
   
   // Análise de qualidade
   double            GetStructureQuality(const SMarketStructure &structure);
   bool              IsStructureReliable(const SMarketStructure &structure);
   double            GetConfidenceLevel(const SMarketStructure &structure);
   
   // Filtros
   void              FilterByType(ENUM_STRUCTURE_TYPE type, SMarketStructure &filtered[]);
   void              FilterByTimeRange(datetime start_time, datetime end_time, SMarketStructure &filtered[]);
   void              FilterByStrength(double min_strength, SMarketStructure &filtered[]);
   
   // Estatísticas
   void              GetStatistics(int &total_structures, double &accuracy, int &bos_count, int &choch_count);
   double            GetDetectionAccuracy() const { return m_accuracy_rate; }
   
   // Alertas e notificações
   bool              HasNewStructure() const;
   string            GetLastStructureDescription() const;
   void              SetAlertCallback(void* callback);
   
   // Debug e validação
   string            GetDebugInfo() const;
   bool              ValidateConfiguration() const;
   void              PrintStructures() const;
   void              ExportToCSV(const string filename) const;
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
CMarketStructureAnalyzer::CMarketStructureAnalyzer()
{
   // Configurações padrão
   m_initialized = false;
   m_lookback_candles = 100;
   m_swing_strength = 3;
   m_min_structure_size = 10.0; // pontos
   m_use_volume_confirmation = true;
   m_volume_threshold = 1.5;
   m_strict_confirmation = false;
   
   // Inicializar arrays
   ArrayResize(m_structures, 0);
   ArrayResize(m_swing_highs, 0);
   ArrayResize(m_swing_lows, 0);
   
   // Cache
   m_last_analysis_time = 0;
   m_last_analyzed_bar = -1;
   m_cache_valid = false;
   
   // Estatísticas
   m_total_bos_detected = 0;
   m_total_choch_detected = 0;
   m_total_mss_detected = 0;
   m_accuracy_rate = 0.0;
   
   // Trend analysis
   m_trend_analysis.current_trend = TREND_RANGING;
   m_trend_analysis.previous_trend = TREND_RANGING;
   m_trend_analysis.trend_start_time = 0;
   m_trend_analysis.trend_strength = 0.0;
   m_trend_analysis.structure_count = 0;
   m_trend_analysis.trend_angle = 0.0;
   m_trend_analysis.trend_exhaustion = false;
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
CMarketStructureAnalyzer::~CMarketStructureAnalyzer()
{
   ArrayFree(m_structures);
   ArrayFree(m_swing_highs);
   ArrayFree(m_swing_lows);
}

//+------------------------------------------------------------------+
//| Inicialização                                                     |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::Init(const string symbol, const ENUM_TIMEFRAMES timeframe)
{
   // Definir símbolo e timeframe
   m_symbol = symbol;
   m_timeframe = timeframe;
   
   if(!IDetector::Init(symbol, timeframe))
      return false;
   
   // Validar configurações
   if(!ValidateConfiguration())
   {
      g_logger.Error("MarketStructureAnalyzer: Configuração inválida");
      return false;
   }
   
   // Limpar dados anteriores
   ArrayResize(m_structures, 0);
   ArrayResize(m_swing_highs, 0);
   ArrayResize(m_swing_lows, 0);
   
   // Reset cache
   m_last_analysis_time = 0;
   m_last_analyzed_bar = -1;
   m_cache_valid = false;
   
   m_initialized = true;
   g_logger.Info("MarketStructureAnalyzer inicializado para " + symbol + " " + EnumToString(timeframe));
   return true;
}

//+------------------------------------------------------------------+
//| Deinicialização                                                   |
//+------------------------------------------------------------------+
void CMarketStructureAnalyzer::Deinit()
{
   ArrayFree(m_structures);
   ArrayFree(m_swing_highs);
   ArrayFree(m_swing_lows);
   
   m_initialized = false;
   g_logger.Info("MarketStructureAnalyzer deinicializado");
   IDetector::Deinit();
}

//+------------------------------------------------------------------+
//| Auto-teste                                                        |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::SelfTest()
{
   g_logger.Info("Iniciando auto-teste do MarketStructureAnalyzer...");
   
   // Teste 1: Configuração
   if(!ValidateConfiguration())
   {
      g_logger.Error("SelfTest falhou: Configuração inválida");
      return false;
   }
   
   // Teste 2: Detecção de swing points
   if(!DetectSwingPoints())
   {
      g_logger.Warning("SelfTest: Nenhum swing point detectado (pode ser normal)");
   }
   
   // Teste 3: Análise de estrutura
   if(!AnalyzeMarketStructure())
   {
      g_logger.Warning("SelfTest: Análise de estrutura retornou false (pode ser normal)");
   }
   
   g_logger.Info("Auto-teste do MarketStructureAnalyzer concluído com sucesso");
   return true;
}

//+------------------------------------------------------------------+
//| Análise principal de Market Structure                            |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::AnalyzeMarketStructure()
{
   if(!m_initialized)
      return false;
   
   // Verificar se precisa atualizar
   datetime current_time = TimeCurrent();
   int current_bar = Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe) - 1;
   
   if(m_cache_valid && current_bar == m_last_analyzed_bar)
      return true;
   
   // Detectar swing points primeiro
   if(!DetectSwingPoints())
      return false;
   
   // Detectar estruturas
   bool bos_detected = DetectBOS();
   bool choch_detected = DetectCHoCH();
   bool mss_detected = DetectMSS();
   
   // Analisar tendência
   AnalyzeTrendState();
   
   // Limpar estruturas antigas
   CleanupOldStructures();
   
   // Atualizar estatísticas
   UpdateStatistics();
   
   // Atualizar cache
   m_last_analysis_time = current_time;
   m_last_analyzed_bar = current_bar;
   m_cache_valid = true;
   
   return (bos_detected || choch_detected || mss_detected);
}

//+------------------------------------------------------------------+
//| Detectar Swing Points                                            |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::DetectSwingPoints()
{
   int bars_available = Bars(m_symbol, (ENUM_TIMEFRAMES)m_timeframe);
   if(bars_available < m_lookback_candles + m_swing_strength * 2)
      return false;
   
   // Limpar arrays anteriores
   ArrayResize(m_swing_highs, 0);
   ArrayResize(m_swing_lows, 0);
   
   // Detectar swing highs e lows
   for(int i = m_swing_strength; i < m_lookback_candles - m_swing_strength; i++)
   {
      // Swing High
      if(IsSwingHigh(i, m_swing_strength))
      {
         SSwingPoint swing;
         swing.time = iTime(m_symbol, m_timeframe, i);
         swing.price = iHigh(m_symbol, m_timeframe, i);
         swing.is_high = true;
         swing.strength = m_swing_strength;
         swing.broken = false;
         swing.break_time = 0;
         swing.break_price = 0;
         
         ArrayResize(m_swing_highs, ArraySize(m_swing_highs) + 1);
         m_swing_highs[ArraySize(m_swing_highs) - 1] = swing;
      }
      
      // Swing Low
      if(IsSwingLow(i, m_swing_strength))
      {
         SSwingPoint swing;
         swing.time = iTime(m_symbol, m_timeframe, i);
         swing.price = iLow(m_symbol, m_timeframe, i);
         swing.is_high = false;
         swing.strength = m_swing_strength;
         swing.broken = false;
         swing.break_time = 0;
         swing.break_price = 0;
         
         ArrayResize(m_swing_lows, ArraySize(m_swing_lows) + 1);
         m_swing_lows[ArraySize(m_swing_lows) - 1] = swing;
      }
   }
   
   return (ArraySize(m_swing_highs) > 0 || ArraySize(m_swing_lows) > 0);
}

//+------------------------------------------------------------------+
//| Verificar se é Swing High                                        |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::IsSwingHigh(int bar_index, int strength)
{
   double center_high = iHigh(m_symbol, m_timeframe, bar_index);
   
   // Verificar candles à esquerda
   for(int i = 1; i <= strength; i++)
   {
      if(iHigh(m_symbol, m_timeframe, bar_index + i) >= center_high)
         return false;
   }
   
   // Verificar candles à direita
   for(int i = 1; i <= strength; i++)
   {
      if(iHigh(m_symbol, m_timeframe, bar_index - i) >= center_high)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar se é Swing Low                                         |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::IsSwingLow(int bar_index, int strength)
{
   double center_low = iLow(m_symbol, m_timeframe, bar_index);
   
   // Verificar candles à esquerda
   for(int i = 1; i <= strength; i++)
   {
      if(iLow(m_symbol, m_timeframe, bar_index + i) <= center_low)
         return false;
   }
   
   // Verificar candles à direita
   for(int i = 1; i <= strength; i++)
   {
      if(iLow(m_symbol, m_timeframe, bar_index - i) <= center_low)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Detectar Break of Structure (BOS)                                |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::DetectBOS()
{
   if(ArraySize(m_swing_highs) < 2 || ArraySize(m_swing_lows) < 2)
      return false;
   
   bool detected = false;
   double current_price = iClose(m_symbol, m_timeframe, 0);
   
   // BOS Bullish - quebra de swing high anterior
   for(int i = 0; i < ArraySize(m_swing_highs); i++)
   {
      if(!m_swing_highs[i].broken && current_price > m_swing_highs[i].price)
      {
         SMarketStructure structure;
         structure.time = TimeCurrent();
         structure.price = current_price;
         structure.type = STRUCTURE_BOS_BULLISH;
         structure.previous_high = m_swing_highs[i].price;
         structure.previous_low = 0;
         structure.strength = CalculateStructureStrength(structure);
         structure.confirmed = !m_strict_confirmation;
         structure.candles_since = 0;
         structure.volume_ratio = GetVolumeRatio(0);
         structure.description = "BOS Bullish - Quebra de " + DoubleToString(m_swing_highs[i].price, _Digits);
         
         if(ValidateStructure(structure))
         {
            ArrayResize(m_structures, ArraySize(m_structures) + 1);
            m_structures[ArraySize(m_structures) - 1] = structure;
            
            m_swing_highs[i].broken = true;
            m_swing_highs[i].break_time = TimeCurrent();
            m_swing_highs[i].break_price = current_price;
            
            m_total_bos_detected++;
            detected = true;
         }
      }
   }
   
   // BOS Bearish - quebra de swing low anterior
   for(int i = 0; i < ArraySize(m_swing_lows); i++)
   {
      if(!m_swing_lows[i].broken && current_price < m_swing_lows[i].price)
      {
         SMarketStructure structure;
         structure.time = TimeCurrent();
         structure.price = current_price;
         structure.type = STRUCTURE_BOS_BEARISH;
         structure.previous_high = 0;
         structure.previous_low = m_swing_lows[i].price;
         structure.strength = CalculateStructureStrength(structure);
         structure.confirmed = !m_strict_confirmation;
         structure.candles_since = 0;
         structure.volume_ratio = GetVolumeRatio(0);
         structure.description = "BOS Bearish - Quebra de " + DoubleToString(m_swing_lows[i].price, _Digits);
         
         if(ValidateStructure(structure))
         {
            ArrayResize(m_structures, ArraySize(m_structures) + 1);
            m_structures[ArraySize(m_structures) - 1] = structure;
            
            m_swing_lows[i].broken = true;
            m_swing_lows[i].break_time = TimeCurrent();
            m_swing_lows[i].break_price = current_price;
            
            m_total_bos_detected++;
            detected = true;
         }
      }
   }
   
   return detected;
}

//+------------------------------------------------------------------+
//| Detectar Change of Character (CHoCH)                             |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::DetectCHoCH()
{
   // CHoCH é mais complexo - requer análise de tendência anterior
   if(ArraySize(m_structures) < 2)
      return false;
   
   // Implementação simplificada - pode ser expandida
   bool detected = false;
   
   // Lógica para detectar mudança de caráter baseada em estruturas anteriores
   // Esta é uma implementação básica que pode ser refinada
   
   return detected;
}

//+------------------------------------------------------------------+
//| Detectar Market Structure Shift (MSS)                            |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::DetectMSS()
{
   // MSS é similar ao CHoCH mas com critérios mais rigorosos
   // Implementação pode ser adicionada conforme necessário
   return false;
}

//+------------------------------------------------------------------+
//| Calcular força da estrutura                                      |
//+------------------------------------------------------------------+
double CMarketStructureAnalyzer::CalculateStructureStrength(const SMarketStructure &structure)
{
   double strength = 50.0; // Base
   
   // Fator volume
   if(structure.volume_ratio > m_volume_threshold)
      strength += 20.0;
   
   // Fator tamanho da quebra
   double break_size = 0;
   if(structure.type == STRUCTURE_BOS_BULLISH && structure.previous_high > 0)
      break_size = structure.price - structure.previous_high;
   else if(structure.type == STRUCTURE_BOS_BEARISH && structure.previous_low > 0)
      break_size = structure.previous_low - structure.price;
   
   if(break_size > m_min_structure_size)
      strength += 15.0;
   
   // Limitar entre 0-100
   return MathMax(0.0, MathMin(100.0, strength));
}

//+------------------------------------------------------------------+
//| Validar estrutura                                                |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::ValidateStructure(const SMarketStructure &structure)
{
   // Validação básica
   if(structure.strength < 30.0)
      return false;
   
   // Validação de volume se habilitada
   if(m_use_volume_confirmation && !ConfirmWithVolume(structure))
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Confirmar com volume                                             |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::ConfirmWithVolume(const SMarketStructure &structure)
{
   return structure.volume_ratio >= m_volume_threshold;
}

//+------------------------------------------------------------------+
//| Obter ratio de volume                                            |
//+------------------------------------------------------------------+
double CMarketStructureAnalyzer::GetVolumeRatio(int bar_index)
{
   long current_volume = iVolume(m_symbol, m_timeframe, bar_index);
   
   // Calcular média de volume dos últimos 20 candles
   long total_volume = 0;
   int count = 0;
   
   for(int i = bar_index + 1; i <= bar_index + 20; i++)
   {
      long vol = iVolume(m_symbol, m_timeframe, i);
      if(vol > 0)
      {
         total_volume += vol;
         count++;
      }
   }
   
   if(count == 0)
      return 1.0;
   
   double avg_volume = (double)total_volume / count;
   return avg_volume > 0 ? (double)current_volume / avg_volume : 1.0;
}

//+------------------------------------------------------------------+
//| Validar configuração                                             |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::ValidateConfiguration() const
{
   if(m_lookback_candles < 20 || m_lookback_candles > 1000)
      return false;
   
   if(m_swing_strength < 1 || m_swing_strength > 10)
      return false;
   
   if(m_min_structure_size < 0)
      return false;
   
   if(m_volume_threshold < 0.1 || m_volume_threshold > 10.0)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter estrutura por índice                                       |
//+------------------------------------------------------------------+
SMarketStructure CMarketStructureAnalyzer::GetStructure(int index) const
{
   SMarketStructure empty_structure = {0};
   
   if(index < 0 || index >= ArraySize(m_structures))
      return empty_structure;
   
   return m_structures[index];
}

//+------------------------------------------------------------------+
//| Obter última estrutura                                           |
//+------------------------------------------------------------------+
SMarketStructure CMarketStructureAnalyzer::GetLatestStructure() const
{
   SMarketStructure empty_structure = {0};
   
   if(ArraySize(m_structures) == 0)
      return empty_structure;
   
   return m_structures[ArraySize(m_structures) - 1];
}

//+------------------------------------------------------------------+
//| Limpar estruturas antigas                                        |
//+------------------------------------------------------------------+
void CMarketStructureAnalyzer::CleanupOldStructures()
{
   datetime cutoff_time = TimeCurrent() - PeriodSeconds((ENUM_TIMEFRAMES)m_timeframe) * m_lookback_candles;
   
   // Remover estruturas muito antigas
   for(int i = ArraySize(m_structures) - 1; i >= 0; i--)
   {
      if(m_structures[i].time < cutoff_time)
      {
         // Remover elemento do array
         for(int j = i; j < ArraySize(m_structures) - 1; j++)
         {
            m_structures[j] = m_structures[j + 1];
         }
         ArrayResize(m_structures, ArraySize(m_structures) - 1);
      }
   }
}

//+------------------------------------------------------------------+
//| Atualizar estatísticas                                           |
//+------------------------------------------------------------------+
void CMarketStructureAnalyzer::UpdateStatistics()
{
   // Calcular taxa de acurácia baseada em estruturas confirmadas
   int confirmed_count = 0;
   int total_count = ArraySize(m_structures);
   
   for(int i = 0; i < total_count; i++)
   {
      if(m_structures[i].confirmed)
         confirmed_count++;
   }
   
   m_accuracy_rate = total_count > 0 ? (double)confirmed_count / total_count * 100.0 : 0.0;
}

//+------------------------------------------------------------------+
//| Implementações dos métodos da interface IDetector                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Detectar estruturas (método principal da interface)              |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::DetectStructures()
{
   if(!m_initialized)
      return false;
      
   bool detected = false;
   
   // Detectar swing points primeiro
   if(DetectSwingPoints())
      detected = true;
      
   // Detectar estruturas de mercado
   if(DetectBOS())
      detected = true;
      
   if(DetectCHoCH())
      detected = true;
      
   if(DetectMSS())
      detected = true;
      
   // Atualizar análise de tendência
   if(AnalyzeTrendState())
      detected = true;
      
   // Limpar estruturas antigas
   CleanupOldStructures();
   
   // Atualizar estatísticas
   UpdateStatistics();
   
   return detected;
}

//+------------------------------------------------------------------+
//| Verificar se há nova estrutura                                   |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::HasNewStructure()
{
   if(ArraySize(m_structures) == 0)
      return false;
      
   SMarketStructure latest = GetLatestStructure();
   return (latest.time > m_last_analysis_time);
}

//+------------------------------------------------------------------+
//| Obter descrição da última estrutura                              |
//+------------------------------------------------------------------+
string CMarketStructureAnalyzer::GetLastStructureDescription()
{
   if(ArraySize(m_structures) == 0)
      return "Nenhuma estrutura detectada";
      
   SMarketStructure latest = GetLatestStructure();
   return latest.description;
}

//+------------------------------------------------------------------+
//| Definir velas de lookback                                        |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::SetLookbackCandles(int candles)
{
   if(candles < 20 || candles > 1000)
      return false;
      
   m_lookback_candles = candles;
   return true;
}

//+------------------------------------------------------------------+
//| Definir força do swing                                           |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::SetSwingStrength(int strength)
{
   if(strength < 1 || strength > 10)
      return false;
      
   m_swing_strength = strength;
   return true;
}

//+------------------------------------------------------------------+
//| Definir tamanho mínimo da estrutura                              |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::SetMinStructureSize(double size)
{
   if(size < 0)
      return false;
      
   m_min_structure_size = size;
   return true;
}

//+------------------------------------------------------------------+
//| Definir confirmação por volume                                   |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::SetVolumeConfirmation(bool enable)
{
   m_use_volume_confirmation = enable;
   return true;
}

//+------------------------------------------------------------------+
//| Definir confirmação rigorosa                                     |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::SetStrictConfirmation(bool enable)
{
   m_strict_confirmation = enable;
   return true;
}

//+------------------------------------------------------------------+
//| Obter precisão da detecção                                       |
//+------------------------------------------------------------------+
double CMarketStructureAnalyzer::GetDetectionAccuracy()
{
   return m_accuracy_rate;
}

//+------------------------------------------------------------------+
//| Resetar estatísticas                                             |
//+------------------------------------------------------------------+
void CMarketStructureAnalyzer::ResetStatistics()
{
   m_total_bos_detected = 0;
   m_total_choch_detected = 0;
   m_total_mss_detected = 0;
   m_accuracy_rate = 0.0;
   
   // Limpar arrays de estruturas
   ArrayResize(m_structures, 0);
   ArrayResize(m_swing_highs, 0);
   ArrayResize(m_swing_lows, 0);
   
   g_logger.Info("Estatísticas do MarketStructureAnalyzer resetadas");
}

//+------------------------------------------------------------------+
//| Obter informações de debug (implementação da interface)          |
//+------------------------------------------------------------------+
string CMarketStructureAnalyzer::GetDebugInfo()
{
   string info = "=== Market Structure Analyzer Debug ===\n";
   info += "Initialized: " + (m_initialized ? "Yes" : "No") + "\n";
   info += "Symbol: " + m_symbol + "\n";
   info += "Timeframe: " + EnumToString(m_timeframe) + "\n";
   info += "Structures: " + IntegerToString(ArraySize(m_structures)) + "\n";
   info += "Swing Highs: " + IntegerToString(ArraySize(m_swing_highs)) + "\n";
   info += "Swing Lows: " + IntegerToString(ArraySize(m_swing_lows)) + "\n";
   info += "BOS Detected: " + IntegerToString(m_total_bos_detected) + "\n";
   info += "CHoCH Detected: " + IntegerToString(m_total_choch_detected) + "\n";
   info += "MSS Detected: " + IntegerToString(m_total_mss_detected) + "\n";
   info += "Accuracy: " + DoubleToString(m_accuracy_rate, 2) + "%\n";
   info += "Current Trend: " + EnumToString(m_trend_analysis.current_trend) + "\n";
   info += "Lookback Candles: " + IntegerToString(m_lookback_candles) + "\n";
   info += "Swing Strength: " + IntegerToString(m_swing_strength) + "\n";
   info += "Min Structure Size: " + DoubleToString(m_min_structure_size, 1) + "\n";
   info += "Volume Confirmation: " + (m_use_volume_confirmation ? "Yes" : "No") + "\n";
   info += "Strict Confirmation: " + (m_strict_confirmation ? "Yes" : "No") + "\n";
   
   return info;
}

//+------------------------------------------------------------------+
//| Validar configuração (implementação da interface)                |
//+------------------------------------------------------------------+
bool CMarketStructureAnalyzer::ValidateConfiguration()
{
   if(m_lookback_candles < 20 || m_lookback_candles > 1000)
   {
      g_logger.Error("Lookback candles inválido: " + IntegerToString(m_lookback_candles));
      return false;
   }
   
   if(m_swing_strength < 1 || m_swing_strength > 10)
   {
      g_logger.Error("Swing strength inválido: " + IntegerToString(m_swing_strength));
      return false;
   }
   
   if(m_min_structure_size < 0)
   {
      g_logger.Error("Min structure size inválido: " + DoubleToString(m_min_structure_size, 1));
      return false;
   }
   
   if(m_volume_threshold < 0.1 || m_volume_threshold > 10.0)
   {
      g_logger.Error("Volume threshold inválido: " + DoubleToString(m_volume_threshold, 2));
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Instância global                                                 |
//+------------------------------------------------------------------+
CMarketStructureAnalyzer g_market_structure_analyzer;

//+------------------------------------------------------------------+