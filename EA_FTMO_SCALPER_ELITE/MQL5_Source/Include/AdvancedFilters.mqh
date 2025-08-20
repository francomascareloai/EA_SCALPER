//+------------------------------------------------------------------+
//|                                           AdvancedFilters.mqh |
//|                                  Copyright 2024, TradeDev_Master |
//|                         Sistema Avançado de Filtros de Trading |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "1.00"
#property strict

#include "..\Source\Core\DataStructures.mqh"
#include "Logger.mqh"

//+------------------------------------------------------------------+
//| Estrutura para resultado dos filtros                           |
//+------------------------------------------------------------------+
struct SFilterResult
{
   bool     passed;              // Se passou no filtro
   double   score;               // Pontuação do filtro (0-100)
   double   value;               // Valor do indicador
   string   description;         // Descrição do resultado
   datetime timestamp;           // Timestamp da análise
};

//+------------------------------------------------------------------+
//| Estrutura para análise completa de filtros                     |
//+------------------------------------------------------------------+
struct SAdvancedFilterAnalysis
{
   SFilterResult momentum;       // Resultado do filtro de momentum
   SFilterResult volume;         // Resultado do filtro de volume
   SFilterResult trend;          // Resultado do filtro de tendência
   SFilterResult volatility;     // Resultado do filtro de volatilidade
   SFilterResult strength;       // Resultado do filtro de força
   
   double        totalScore;     // Pontuação total (0-100)
   bool          allPassed;      // Se todos os filtros passaram
   int           passedCount;    // Quantidade de filtros que passaram
   string        summary;        // Resumo da análise
   datetime      timestamp;      // Timestamp da análise completa
};

//+------------------------------------------------------------------+
//| Enumeração para tipos de filtro                                |
//+------------------------------------------------------------------+
enum ENUM_FILTER_TYPE
{
   FILTER_MOMENTUM,     // Filtro de momentum (RSI, MACD)
   FILTER_VOLUME,       // Filtro de volume
   FILTER_TREND,        // Filtro de tendência (EMAs)
   FILTER_VOLATILITY,   // Filtro de volatilidade (ATR)
   FILTER_STRENGTH      // Filtro de força do movimento
};

//+------------------------------------------------------------------+
//| Enumeração para direção do sinal                               |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_DIRECTION
{
   SIGNAL_BULLISH,      // Sinal de alta
   SIGNAL_BEARISH,      // Sinal de baixa
   SIGNAL_NEUTRAL       // Sinal neutro
};

//+------------------------------------------------------------------+
//| Classe para filtros avançados                                  |
//+------------------------------------------------------------------+
class CAdvancedFilters
{
private:
   // Parâmetros de configuração
   int               m_rsiPeriod;              // Período do RSI
   double            m_rsiOverbought;          // Nível de sobrecompra RSI
   double            m_rsiOversold;            // Nível de sobrevenda RSI
   
   int               m_macdFast;               // Período rápido MACD
   int               m_macdSlow;               // Período lento MACD
   int               m_macdSignal;             // Período do sinal MACD
   
   int               m_emaFastPeriod;          // Período EMA rápida
   int               m_emaSlowPeriod;          // Período EMA lenta
   
   int               m_volumePeriod;           // Período para análise de volume
   double            m_volumeThreshold;        // Limite mínimo de volume
   
   int               m_atrPeriod;              // Período ATR
   double            m_volatilityThreshold;    // Limite de volatilidade
   
   // Dados de mercado
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   
   // Handles de indicadores
   int               m_rsiHandle;
   int               m_macdHandle;
   int               m_emaFastHandle;
   int               m_emaSlowHandle;
   int               m_atrHandle;
   
   // Pesos dos filtros
   double            m_momentumWeight;
   double            m_volumeWeight;
   double            m_trendWeight;
   double            m_volatilityWeight;
   double            m_strengthWeight;
   
   // Filtro de notícias
   bool              m_newsFilterEnabled;
   int               m_newsMinutesBefore;
   int               m_newsMinutesAfter;
   
   // Utilitários
   CLogger*          m_logger;
   
public:
   // Construtor e Destrutor
                     CAdvancedFilters(void);
                    ~CAdvancedFilters(void);
   
   // Inicialização
   bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger);
   void              Deinitialize(void);
   
   // Configuração de parâmetros
   void              SetRSIParameters(int period, double overbought, double oversold);
   void              SetMACDParameters(int fast, int slow, int signal);
   void              SetEMAParameters(int fastPeriod, int slowPeriod);
   void              SetVolumeParameters(int period, double threshold);
   void              SetVolatilityParameters(int atrPeriod, double threshold);
   void              SetFilterWeights(double momentum, double volume, double trend, double volatility, double strength);
   
   // Análise principal
   SAdvancedFilterAnalysis AnalyzeFilters(ENUM_SIGNAL_DIRECTION direction);
   
   // Filtros individuais
   SFilterResult     AnalyzeMomentum(ENUM_SIGNAL_DIRECTION direction);
   SFilterResult     AnalyzeVolume(ENUM_SIGNAL_DIRECTION direction);
   SFilterResult     AnalyzeTrend(ENUM_SIGNAL_DIRECTION direction);
   SFilterResult     AnalyzeVolatility(ENUM_SIGNAL_DIRECTION direction);
   SFilterResult     AnalyzeStrength(ENUM_SIGNAL_DIRECTION direction);
   
   // Métodos específicos de indicadores
   double            GetRSI(int shift = 0);
   double            GetMACDMain(int shift = 0);
   double            GetMACDSignal(int shift = 0);
   double            GetEMAFast(int shift = 0);
   double            GetEMASlow(int shift = 0);
   double            GetATR(int shift = 0);
   double            GetVolumeRatio(int shift = 0);
   
   // Análises auxiliares
   bool              IsMomentumBullish(void);
   bool              IsMomentumBearish(void);
   bool              IsTrendBullish(void);
   bool              IsTrendBearish(void);
   bool              IsVolumeConfirming(ENUM_SIGNAL_DIRECTION direction);
   bool              IsVolatilityAcceptable(void);
   
   // Utilitários
   double            CalculateOverallScore(SAdvancedFilterAnalysis &analysis);
   string            GetFilterSummary(SAdvancedFilterAnalysis &analysis);
   bool              PassesMinimumRequirements(SAdvancedFilterAnalysis &analysis, double minScore = 60.0);
   
   // Métodos adicionais para configuração
   void              SetMomentumFilter(bool enabled, double weight = 25.0);
   void              SetVolumeFilter(bool enabled, double weight = 20.0);
   void              SetTrendFilter(bool enabled, double weight = 30.0);
   void              SetNewsFilter(bool enabled, int minutesBefore = 30, int minutesAfter = 30);
   SAdvancedFilterAnalysis GetFilterConfig(void);
   bool              ApplyFilters(ENUM_SIGNAL_DIRECTION direction, double minScore = 60.0);
   
private:
   // Métodos internos
   bool              InitializeIndicators(void);
   SFilterResult     CreateFilterResult(bool passed, double score, double value, string description);
   double            NormalizeScore(double value, double min, double max, bool inverse = false);
   string            DirectionToString(ENUM_SIGNAL_DIRECTION direction);
   double            CalculateVolumeAverage(int period);
   double            CalculatePriceStrength(ENUM_SIGNAL_DIRECTION direction);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CAdvancedFilters::CAdvancedFilters(void)
{
   // Parâmetros padrão
   m_rsiPeriod = 14;
   m_rsiOverbought = 70.0;
   m_rsiOversold = 30.0;
   
   m_macdFast = 12;
   m_macdSlow = 26;
   m_macdSignal = 9;
   
   m_emaFastPeriod = 21;
   m_emaSlowPeriod = 50;
   
   m_volumePeriod = 20;
   m_volumeThreshold = 1.2; // 120% da média
   
   m_atrPeriod = 14;
   m_volatilityThreshold = 0.0015; // Para XAUUSD
   
   // Pesos padrão (total = 100%)
   m_momentumWeight = 25.0;
   m_volumeWeight = 20.0;
   m_trendWeight = 30.0;
   m_volatilityWeight = 15.0;
   m_strengthWeight = 10.0;
   
   // Filtro de notícias padrão
   m_newsFilterEnabled = true;
   m_newsMinutesBefore = 30;
   m_newsMinutesAfter = 30;
   
   // Inicializar handles
   m_rsiHandle = INVALID_HANDLE;
   m_macdHandle = INVALID_HANDLE;
   m_emaFastHandle = INVALID_HANDLE;
   m_emaSlowHandle = INVALID_HANDLE;
   m_atrHandle = INVALID_HANDLE;
   
   m_logger = NULL;
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CAdvancedFilters::~CAdvancedFilters(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CAdvancedFilters::Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   m_logger = logger;
   
   if(!InitializeIndicators())
   {
      if(m_logger != NULL)
         m_logger.LogError("AdvancedFilters", "Falha ao inicializar indicadores");
      return false;
   }
   
   if(m_logger != NULL)
      m_logger.LogInfo("AdvancedFilters", "Sistema de filtros avançados inicializado para " + symbol);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinicialização                                                  |
//+------------------------------------------------------------------+
void CAdvancedFilters::Deinitialize(void)
{
   if(m_rsiHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_rsiHandle);
      m_rsiHandle = INVALID_HANDLE;
   }
   
   if(m_macdHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_macdHandle);
      m_macdHandle = INVALID_HANDLE;
   }
   
   if(m_emaFastHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_emaFastHandle);
      m_emaFastHandle = INVALID_HANDLE;
   }
   
   if(m_emaSlowHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_emaSlowHandle);
      m_emaSlowHandle = INVALID_HANDLE;
   }
   
   if(m_atrHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atrHandle);
      m_atrHandle = INVALID_HANDLE;
   }
   
   if(m_logger != NULL)
      m_logger.LogInfo("AdvancedFilters", "Sistema de filtros avançados deinicializado");
}

//+------------------------------------------------------------------+
//| Configurar parâmetros RSI                                      |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetRSIParameters(int period, double overbought, double oversold)
{
   m_rsiPeriod = MathMax(2, period);
   m_rsiOverbought = MathMax(50.0, overbought);
   m_rsiOversold = MathMin(50.0, oversold);
   
   // Reinicializar RSI se necessário
   if(m_rsiHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_rsiHandle);
      m_rsiHandle = iRSI(m_symbol, m_timeframe, m_rsiPeriod, PRICE_CLOSE);
   }
}

//+------------------------------------------------------------------+
//| Configurar parâmetros MACD                                     |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetMACDParameters(int fast, int slow, int signal)
{
   m_macdFast = MathMax(1, fast);
   m_macdSlow = MathMax(m_macdFast + 1, slow);
   m_macdSignal = MathMax(1, signal);
   
   // Reinicializar MACD se necessário
   if(m_macdHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_macdHandle);
      m_macdHandle = iMACD(m_symbol, m_timeframe, m_macdFast, m_macdSlow, m_macdSignal, PRICE_CLOSE);
   }
}

//+------------------------------------------------------------------+
//| Configurar parâmetros EMA                                      |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetEMAParameters(int fastPeriod, int slowPeriod)
{
   m_emaFastPeriod = MathMax(1, fastPeriod);
   m_emaSlowPeriod = MathMax(m_emaFastPeriod + 1, slowPeriod);
   
   // Reinicializar EMAs se necessário
   if(m_emaFastHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_emaFastHandle);
      m_emaFastHandle = iMA(m_symbol, m_timeframe, m_emaFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   }
   
   if(m_emaSlowHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_emaSlowHandle);
      m_emaSlowHandle = iMA(m_symbol, m_timeframe, m_emaSlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   }
}

//+------------------------------------------------------------------+
//| Configurar parâmetros de volume                                |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetVolumeParameters(int period, double threshold)
{
   m_volumePeriod = MathMax(5, period);
   m_volumeThreshold = MathMax(1.0, threshold);
}

//+------------------------------------------------------------------+
//| Configurar parâmetros de volatilidade                          |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetVolatilityParameters(int atrPeriod, double threshold)
{
   m_atrPeriod = MathMax(1, atrPeriod);
   m_volatilityThreshold = MathMax(0.0001, threshold);
   
   // Reinicializar ATR se necessário
   if(m_atrHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atrHandle);
      m_atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
   }
}

//+------------------------------------------------------------------+
//| Configurar pesos dos filtros                                   |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetFilterWeights(double momentum, double volume, double trend, double volatility, double strength)
{
   double total = momentum + volume + trend + volatility + strength;
   
   if(total > 0)
   {
      m_momentumWeight = (momentum / total) * 100.0;
      m_volumeWeight = (volume / total) * 100.0;
      m_trendWeight = (trend / total) * 100.0;
      m_volatilityWeight = (volatility / total) * 100.0;
      m_strengthWeight = (strength / total) * 100.0;
   }
}

//+------------------------------------------------------------------+
//| Analisar todos os filtros                                      |
//+------------------------------------------------------------------+
SAdvancedFilterAnalysis CAdvancedFilters::AnalyzeFilters(ENUM_SIGNAL_DIRECTION direction)
{
   SAdvancedFilterAnalysis analysis;
   ZeroMemory(analysis);
   
   analysis.timestamp = TimeCurrent();
   
   // Analisar cada filtro
   analysis.momentum = AnalyzeMomentum(direction);
   analysis.volume = AnalyzeVolume(direction);
   analysis.trend = AnalyzeTrend(direction);
   analysis.volatility = AnalyzeVolatility(direction);
   analysis.strength = AnalyzeStrength(direction);
   
   // Calcular estatísticas
   analysis.passedCount = 0;
   if(analysis.momentum.passed) analysis.passedCount++;
   if(analysis.volume.passed) analysis.passedCount++;
   if(analysis.trend.passed) analysis.passedCount++;
   if(analysis.volatility.passed) analysis.passedCount++;
   if(analysis.strength.passed) analysis.passedCount++;
   
   analysis.allPassed = (analysis.passedCount == 5);
   analysis.totalScore = CalculateOverallScore(analysis);
   analysis.summary = GetFilterSummary(analysis);
   
   if(m_logger != NULL)
   {
      string msg = StringFormat("Análise de filtros [%s]: Score=%.1f, Passed=%d/5, AllPassed=%s",
                               DirectionToString(direction), analysis.totalScore, 
                               analysis.passedCount, analysis.allPassed ? "Sim" : "Não");
      m_logger.LogDebug("AdvancedFilters", msg);
   }
   
   return analysis;
}

//+------------------------------------------------------------------+
//| Analisar filtro de momentum                                    |
//+------------------------------------------------------------------+
SFilterResult CAdvancedFilters::AnalyzeMomentum(ENUM_SIGNAL_DIRECTION direction)
{
   double rsi = GetRSI();
   double macdMain = GetMACDMain();
   double macdSignal = GetMACDSignal();
   
   bool rsiOk = false;
   bool macdOk = false;
   double score = 0.0;
   
   if(direction == SIGNAL_BULLISH)
   {
      rsiOk = (rsi > m_rsiOversold && rsi < m_rsiOverbought); // RSI em zona neutra/bullish
      macdOk = (macdMain > macdSignal); // MACD acima da linha de sinal
      score = NormalizeScore(rsi, m_rsiOversold, m_rsiOverbought) * 0.6 + 
              (macdOk ? 40.0 : 0.0);
   }
   else if(direction == SIGNAL_BEARISH)
   {
      rsiOk = (rsi < m_rsiOverbought && rsi > m_rsiOversold); // RSI em zona neutra/bearish
      macdOk = (macdMain < macdSignal); // MACD abaixo da linha de sinal
      score = NormalizeScore(rsi, m_rsiOverbought, m_rsiOversold, true) * 0.6 + 
              (macdOk ? 40.0 : 0.0);
   }
   
   bool passed = rsiOk && macdOk;
   string desc = StringFormat("RSI:%.1f MACD:%.5f/%.5f", rsi, macdMain, macdSignal);
   
   return CreateFilterResult(passed, score, rsi, desc);
}

//+------------------------------------------------------------------+
//| Analisar filtro de volume                                      |
//+------------------------------------------------------------------+
SFilterResult CAdvancedFilters::AnalyzeVolume(ENUM_SIGNAL_DIRECTION direction)
{
   double volumeRatio = GetVolumeRatio();
   bool volumeOk = (volumeRatio >= m_volumeThreshold);
   
   double score = NormalizeScore(volumeRatio, 1.0, 2.0) * 100.0;
   score = MathMin(100.0, score);
   
   string desc = StringFormat("VolumeRatio:%.2f (Min:%.2f)", volumeRatio, m_volumeThreshold);
   
   return CreateFilterResult(volumeOk, score, volumeRatio, desc);
}

//+------------------------------------------------------------------+
//| Analisar filtro de tendência                                   |
//+------------------------------------------------------------------+
SFilterResult CAdvancedFilters::AnalyzeTrend(ENUM_SIGNAL_DIRECTION direction)
{
   double emaFast = GetEMAFast();
   double emaSlow = GetEMASlow();
   double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   bool trendOk = false;
   double score = 0.0;
   
   if(direction == SIGNAL_BULLISH)
   {
      trendOk = (emaFast > emaSlow && currentPrice > emaFast);
      score = (emaFast > emaSlow ? 50.0 : 0.0) + (currentPrice > emaFast ? 50.0 : 0.0);
   }
   else if(direction == SIGNAL_BEARISH)
   {
      trendOk = (emaFast < emaSlow && currentPrice < emaFast);
      score = (emaFast < emaSlow ? 50.0 : 0.0) + (currentPrice < emaFast ? 50.0 : 0.0);
   }
   
   string desc = StringFormat("EMA_Fast:%.5f EMA_Slow:%.5f Price:%.5f", emaFast, emaSlow, currentPrice);
   
   return CreateFilterResult(trendOk, score, emaFast - emaSlow, desc);
}

//+------------------------------------------------------------------+
//| Analisar filtro de volatilidade                                |
//+------------------------------------------------------------------+
SFilterResult CAdvancedFilters::AnalyzeVolatility(ENUM_SIGNAL_DIRECTION direction)
{
   double atr = GetATR();
   bool volatilityOk = (atr >= m_volatilityThreshold * 0.5 && atr <= m_volatilityThreshold * 2.0);
   
   double score = 100.0;
   if(atr < m_volatilityThreshold * 0.5)
      score = NormalizeScore(atr, 0, m_volatilityThreshold * 0.5) * 100.0;
   else if(atr > m_volatilityThreshold * 2.0)
      score = NormalizeScore(atr, m_volatilityThreshold * 2.0, m_volatilityThreshold * 3.0, true) * 100.0;
   
   string desc = StringFormat("ATR:%.5f (Range:%.5f-%.5f)", atr, 
                             m_volatilityThreshold * 0.5, m_volatilityThreshold * 2.0);
   
   return CreateFilterResult(volatilityOk, score, atr, desc);
}

//+------------------------------------------------------------------+
//| Analisar filtro de força                                       |
//+------------------------------------------------------------------+
SFilterResult CAdvancedFilters::AnalyzeStrength(ENUM_SIGNAL_DIRECTION direction)
{
   double strength = CalculatePriceStrength(direction);
   bool strengthOk = (strength >= 60.0); // Força mínima de 60%
   
   double score = strength;
   string desc = StringFormat("PriceStrength:%.1f%%", strength);
   
   return CreateFilterResult(strengthOk, score, strength, desc);
}

//+------------------------------------------------------------------+
//| Obter valor RSI                                                |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetRSI(int shift)
{
   double rsiBuffer[1];
   if(CopyBuffer(m_rsiHandle, 0, shift, 1, rsiBuffer) <= 0)
      return 50.0; // Valor neutro em caso de erro
   return rsiBuffer[0];
}

//+------------------------------------------------------------------+
//| Obter MACD principal                                           |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetMACDMain(int shift)
{
   double macdBuffer[1];
   if(CopyBuffer(m_macdHandle, 0, shift, 1, macdBuffer) <= 0)
      return 0.0;
   return macdBuffer[0];
}

//+------------------------------------------------------------------+
//| Obter MACD sinal                                               |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetMACDSignal(int shift)
{
   double signalBuffer[1];
   if(CopyBuffer(m_macdHandle, 1, shift, 1, signalBuffer) <= 0)
      return 0.0;
   return signalBuffer[0];
}

//+------------------------------------------------------------------+
//| Obter EMA rápida                                               |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetEMAFast(int shift)
{
   double emaBuffer[1];
   if(CopyBuffer(m_emaFastHandle, 0, shift, 1, emaBuffer) <= 0)
      return 0.0;
   return emaBuffer[0];
}

//+------------------------------------------------------------------+
//| Obter EMA lenta                                                |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetEMASlow(int shift)
{
   double emaBuffer[1];
   if(CopyBuffer(m_emaSlowHandle, 0, shift, 1, emaBuffer) <= 0)
      return 0.0;
   return emaBuffer[0];
}

//+------------------------------------------------------------------+
//| Obter ATR                                                       |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetATR(int shift)
{
   double atrBuffer[1];
   if(CopyBuffer(m_atrHandle, 0, shift, 1, atrBuffer) <= 0)
      return 0.0;
   return atrBuffer[0];
}

//+------------------------------------------------------------------+
//| Obter ratio de volume                                          |
//+------------------------------------------------------------------+
double CAdvancedFilters::GetVolumeRatio(int shift)
{
   long currentVolume = iVolume(m_symbol, m_timeframe, shift);
   double avgVolume = CalculateVolumeAverage(m_volumePeriod);
   
   if(avgVolume <= 0) return 1.0;
   
   return (double)currentVolume / avgVolume;
}

//+------------------------------------------------------------------+
//| Verificar se momentum é bullish                                |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsMomentumBullish(void)
{
   SFilterResult momentum = AnalyzeMomentum(SIGNAL_BULLISH);
   return momentum.passed;
}

//+------------------------------------------------------------------+
//| Verificar se momentum é bearish                                |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsMomentumBearish(void)
{
   SFilterResult momentum = AnalyzeMomentum(SIGNAL_BEARISH);
   return momentum.passed;
}

//+------------------------------------------------------------------+
//| Verificar se tendência é bullish                               |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsTrendBullish(void)
{
   SFilterResult trend = AnalyzeTrend(SIGNAL_BULLISH);
   return trend.passed;
}

//+------------------------------------------------------------------+
//| Verificar se tendência é bearish                               |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsTrendBearish(void)
{
   SFilterResult trend = AnalyzeTrend(SIGNAL_BEARISH);
   return trend.passed;
}

//+------------------------------------------------------------------+
//| Verificar se volume confirma                                   |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsVolumeConfirming(ENUM_SIGNAL_DIRECTION direction)
{
   SFilterResult volume = AnalyzeVolume(direction);
   return volume.passed;
}

//+------------------------------------------------------------------+
//| Verificar se volatilidade é aceitável                         |
//+------------------------------------------------------------------+
bool CAdvancedFilters::IsVolatilityAcceptable(void)
{
   SFilterResult volatility = AnalyzeVolatility(SIGNAL_NEUTRAL);
   return volatility.passed;
}

//+------------------------------------------------------------------+
//| Calcular pontuação geral                                       |
//+------------------------------------------------------------------+
double CAdvancedFilters::CalculateOverallScore(SAdvancedFilterAnalysis &analysis)
{
   double totalScore = 0.0;
   
   totalScore += analysis.momentum.score * (m_momentumWeight / 100.0);
   totalScore += analysis.volume.score * (m_volumeWeight / 100.0);
   totalScore += analysis.trend.score * (m_trendWeight / 100.0);
   totalScore += analysis.volatility.score * (m_volatilityWeight / 100.0);
   totalScore += analysis.strength.score * (m_strengthWeight / 100.0);
   
   return MathMin(100.0, totalScore);
}

//+------------------------------------------------------------------+
//| Obter resumo dos filtros                                       |
//+------------------------------------------------------------------+
string CAdvancedFilters::GetFilterSummary(SAdvancedFilterAnalysis &analysis)
{
   return StringFormat("M:%s(%.1f) V:%s(%.1f) T:%s(%.1f) Vol:%s(%.1f) S:%s(%.1f)",
                      analysis.momentum.passed ? "✓" : "✗", analysis.momentum.score,
                      analysis.volume.passed ? "✓" : "✗", analysis.volume.score,
                      analysis.trend.passed ? "✓" : "✗", analysis.trend.score,
                      analysis.volatility.passed ? "✓" : "✗", analysis.volatility.score,
                      analysis.strength.passed ? "✓" : "✗", analysis.strength.score);
}

//+------------------------------------------------------------------+
//| Verificar se passa nos requisitos mínimos                      |
//+------------------------------------------------------------------+
bool CAdvancedFilters::PassesMinimumRequirements(SAdvancedFilterAnalysis &analysis, double minScore)
{
   return (analysis.totalScore >= minScore && analysis.passedCount >= 3);
}

//+------------------------------------------------------------------+
//| Inicializar indicadores                                        |
//+------------------------------------------------------------------+
bool CAdvancedFilters::InitializeIndicators(void)
{
   m_rsiHandle = iRSI(m_symbol, m_timeframe, m_rsiPeriod, PRICE_CLOSE);
   m_macdHandle = iMACD(m_symbol, m_timeframe, m_macdFast, m_macdSlow, m_macdSignal, PRICE_CLOSE);
   m_emaFastHandle = iMA(m_symbol, m_timeframe, m_emaFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   m_emaSlowHandle = iMA(m_symbol, m_timeframe, m_emaSlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   m_atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
   
   if(m_rsiHandle == INVALID_HANDLE || m_macdHandle == INVALID_HANDLE ||
      m_emaFastHandle == INVALID_HANDLE || m_emaSlowHandle == INVALID_HANDLE ||
      m_atrHandle == INVALID_HANDLE)
   {
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Criar resultado de filtro                                      |
//+------------------------------------------------------------------+
SFilterResult CAdvancedFilters::CreateFilterResult(bool passed, double score, double value, string description)
{
   SFilterResult result;
   result.passed = passed;
   result.score = MathMax(0.0, MathMin(100.0, score));
   result.value = value;
   result.description = description;
   result.timestamp = TimeCurrent();
   
   return result;
}

//+------------------------------------------------------------------+
//| Normalizar pontuação                                           |
//+------------------------------------------------------------------+
double CAdvancedFilters::NormalizeScore(double value, double min, double max, bool inverse)
{
   if(max <= min) return 0.0;
   
   double normalized = (value - min) / (max - min);
   normalized = MathMax(0.0, MathMin(1.0, normalized));
   
   if(inverse)
      normalized = 1.0 - normalized;
   
   return normalized;
}

//+------------------------------------------------------------------+
//| Converter direção para string                                  |
//+------------------------------------------------------------------+
string CAdvancedFilters::DirectionToString(ENUM_SIGNAL_DIRECTION direction)
{
   switch(direction)
   {
      case SIGNAL_BULLISH: return "BULLISH";
      case SIGNAL_BEARISH: return "BEARISH";
      case SIGNAL_NEUTRAL: return "NEUTRAL";
      default: return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Calcular média de volume                                       |
//+------------------------------------------------------------------+
double CAdvancedFilters::CalculateVolumeAverage(int period)
{
   long totalVolume = 0;
   
   for(int i = 1; i <= period; i++)
   {
      totalVolume += iVolume(m_symbol, m_timeframe, i);
   }
   
   return (double)totalVolume / period;
}

//+------------------------------------------------------------------+
//| Calcular força do preço                                        |
//+------------------------------------------------------------------+
double CAdvancedFilters::CalculatePriceStrength(ENUM_SIGNAL_DIRECTION direction)
{
   double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double high = iHigh(m_symbol, m_timeframe, 0);
   double low = iLow(m_symbol, m_timeframe, 0);
   double range = high - low;
   
   if(range <= 0) return 50.0;
   
   double strength = 0.0;
   
   if(direction == SIGNAL_BULLISH)
   {
      // Força bullish: quão próximo está do high
      strength = ((currentPrice - low) / range) * 100.0;
   }
   else if(direction == SIGNAL_BEARISH)
   {
      // Força bearish: quão próximo está do low
      strength = ((high - currentPrice) / range) * 100.0;
   }
   else
   {
      // Força neutra: distância do meio
      double mid = (high + low) / 2.0;
      strength = (1.0 - (MathAbs(currentPrice - mid) / (range / 2.0))) * 100.0;
   }
   
   return MathMax(0.0, MathMin(100.0, strength));
}

//+------------------------------------------------------------------+
//| Configurar filtro de momentum                                   |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetMomentumFilter(bool enabled, double weight = 25.0)
{
   if(enabled)
   {
      m_momentumWeight = weight;
   }
   else
   {
      m_momentumWeight = 0.0;
   }
   
   if(m_logger != NULL)
   {
      m_logger.LogInfo("AdvancedFilters", StringFormat("Momentum filter %s with weight %.1f", 
                                enabled ? "enabled" : "disabled", weight));
   }
}

//+------------------------------------------------------------------+
//| Configurar filtro de volume                                     |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetVolumeFilter(bool enabled, double weight = 20.0)
{
   if(enabled)
   {
      m_volumeWeight = weight;
   }
   else
   {
      m_volumeWeight = 0.0;
   }
   
   if(m_logger != NULL)
   {
      m_logger.LogInfo("AdvancedFilters", StringFormat("Volume filter %s with weight %.1f", 
                                enabled ? "enabled" : "disabled", weight));
   }
}

//+------------------------------------------------------------------+
//| Configurar filtro de tendência                                  |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetTrendFilter(bool enabled, double weight = 30.0)
{
   if(enabled)
   {
      m_trendWeight = weight;
   }
   else
   {
      m_trendWeight = 0.0;
   }
   
   if(m_logger != NULL)
   {
      m_logger.LogInfo("AdvancedFilters", StringFormat("Trend filter %s with weight %.1f", 
                                enabled ? "enabled" : "disabled", weight));
   }
}

//+------------------------------------------------------------------+
//| Obter configuração dos filtros                                  |
//+------------------------------------------------------------------+
SAdvancedFilterAnalysis CAdvancedFilters::GetFilterConfig(void)
{
   SAdvancedFilterAnalysis config;
   ZeroMemory(config);
   
   // Criar resultado fictício para mostrar configuração
   config.momentum.score = m_momentumWeight;
   config.volume.score = m_volumeWeight;
   config.trend.score = m_trendWeight;
   config.volatility.score = m_volatilityWeight;
   config.strength.score = m_strengthWeight;
   
   config.totalScore = m_momentumWeight + m_volumeWeight + m_trendWeight + 
                      m_volatilityWeight + m_strengthWeight;
   
   config.summary = StringFormat("Weights: Momentum=%.1f, Volume=%.1f, Trend=%.1f, Volatility=%.1f, Strength=%.1f",
                                m_momentumWeight, m_volumeWeight, m_trendWeight, 
                                m_volatilityWeight, m_strengthWeight);
   
   config.timestamp = TimeCurrent();
   
   return config;
}

//+------------------------------------------------------------------+
//| Aplicar filtros com pontuação mínima                           |
//+------------------------------------------------------------------+
bool CAdvancedFilters::ApplyFilters(ENUM_SIGNAL_DIRECTION direction, double minScore = 60.0)
{
   SAdvancedFilterAnalysis analysis = AnalyzeFilters(direction);
   
   bool passed = PassesMinimumRequirements(analysis, minScore);
   
   if(m_logger != NULL)
   {
      m_logger.LogInfo("AdvancedFilters", StringFormat("Filters analysis for %s: Score=%.1f, MinRequired=%.1f, Result=%s",
                                DirectionToString(direction), analysis.totalScore, minScore,
                                passed ? "PASSED" : "FAILED"));
   }
   
   return passed;
}

//+------------------------------------------------------------------+
//| Configurar filtro de notícias                                  |
//+------------------------------------------------------------------+
void CAdvancedFilters::SetNewsFilter(bool enabled, int minutesBefore = 30, int minutesAfter = 30)
{
   m_newsFilterEnabled = enabled;
   m_newsMinutesBefore = minutesBefore;
   m_newsMinutesAfter = minutesAfter;
   
   if(m_logger != NULL)
   {
      if(enabled)
      {
         m_logger.LogInfo("AdvancedFilters", 
                         StringFormat("News filter enabled: %d min before, %d min after",
                                     minutesBefore, minutesAfter));
      }
      else
      {
         m_logger.LogInfo("AdvancedFilters", "News filter disabled");
      }
   }
}

//+------------------------------------------------------------------+