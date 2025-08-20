//+------------------------------------------------------------------+
//|                                           SignalConfluence.mqh |
//|                                  Copyright 2024, TradeDev_Master |
//|                                 Sistema de Confluência Avançado |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "1.00"
#property strict

#include "Logger.mqh"

//+------------------------------------------------------------------+
//| Enumeração para força do sinal                                  |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_STRENGTH
{
   SIGNAL_WEAK,       // Sinal fraco (< 50%)
   SIGNAL_MODERATE,   // Sinal moderado (50-70%)
   SIGNAL_STRONG,     // Sinal forte (70-85%)
   SIGNAL_VERY_STRONG // Sinal muito forte (> 85%)
};

//+------------------------------------------------------------------+
//| Estrutura de configuração da confluência                        |
//+------------------------------------------------------------------+
struct SConfluenceConfig
{
   double   minScore;           // Pontuação mínima para entrada
   double   orderBlockWeight;   // Peso Order Block
   double   fvgWeight;         // Peso FVG
   double   liquidityWeight;   // Peso Liquidez
   double   structureWeight;   // Peso Estrutura
   double   momentumWeight;    // Peso Momentum
   double   volumeWeight;      // Peso Volume
   bool     requireOrderBlock; // Exigir Order Block
   bool     requireFVG;        // Exigir FVG
   bool     requireLiquidity;  // Exigir Liquidez
};

//+------------------------------------------------------------------+
//| Estrutura para armazenar dados de confluência                   |
//+------------------------------------------------------------------+
struct SConfluenceData
{
   double   orderBlockScore;     // Pontuação Order Block (0-30)
   double   fvgScore;           // Pontuação FVG (0-25)
   double   liquidityScore;     // Pontuação Liquidez (0-20)
   double   structureScore;     // Pontuação Estrutura (0-25)
   double   momentumScore;      // Pontuação Momentum (0-15)
   double   volumeScore;        // Pontuação Volume (0-10)
   double   totalScore;         // Pontuação Total (0-125)
   datetime timestamp;          // Timestamp da análise
   string   details;           // Detalhes da confluência
};

//+------------------------------------------------------------------+
//| Estrutura de resultado da confluência                           |
//+------------------------------------------------------------------+
struct SConfluenceResult
{
   bool     isValid;            // Se o resultado é válido
   double   score;              // Pontuação final (0-100)
   ENUM_SIGNAL_STRENGTH strength; // Força do sinal
   ENUM_CONFLUENCE_TYPE type;   // Tipo de confluência
   string   reason;             // Razão da confluência
   datetime timestamp;          // Timestamp do resultado
};

//+------------------------------------------------------------------+
//| Enumeração para tipos de confluência                            |
//+------------------------------------------------------------------+
enum ENUM_CONFLUENCE_TYPE
{
   CONFLUENCE_BULLISH,    // Confluência de alta
   CONFLUENCE_BEARISH,    // Confluência de baixa
   CONFLUENCE_NEUTRAL     // Sem confluência clara
};

//+------------------------------------------------------------------+
//| Classe para análise de confluência de sinais                   |
//+------------------------------------------------------------------+
class CSignalConfluence
{
private:
   // Parâmetros de configuração
   double            m_minConfluenceScore;     // Pontuação mínima para entrada
   double            m_orderBlockWeight;       // Peso Order Block (padrão: 30)
   double            m_fvgWeight;             // Peso FVG (padrão: 25)
   double            m_liquidityWeight;       // Peso Liquidez (padrão: 20)
   double            m_structureWeight;       // Peso Estrutura (padrão: 25)
   double            m_momentumWeight;        // Peso Momentum (padrão: 15)
   double            m_volumeWeight;          // Peso Volume (padrão: 10)
   
   // Dados históricos
   SConfluenceData   m_lastBullishConfluence;
   SConfluenceData   m_lastBearishConfluence;
   
   // Utilitários
   CLogger*          m_logger;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   
public:
   // Construtor e Destrutor
                     CSignalConfluence(void);
                    ~CSignalConfluence(void);
   
   // Inicialização
   bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger);
   void              Deinitialize(void);
   
   // Configuração de pesos
   void              SetWeights(double obWeight, double fvgWeight, double liqWeight, 
                                double structWeight, double momWeight, double volWeight);
   void              SetMinConfluenceScore(double minScore) { m_minConfluenceScore = minScore; }
   
   // Análise principal
   double            CalculateConfluenceScore(ENUM_CONFLUENCE_TYPE type, 
                                             bool hasOrderBlock, double obStrength,
                                             bool hasFVG, double fvgStrength,
                                             bool hasLiquidity, double liqStrength,
                                             bool hasStructure, double structStrength,
                                             double rsiValue, double volumeRatio);
   
   // Validação de sinais
   bool              IsValidBullishConfluence(double score);
   bool              IsValidBearishConfluence(double score);

   // Funções de cálculo de pontuação
   double            CalculateBuyScore(COrderBlockDetector &ob_detector, CFVGDetector &fvg_detector, CLiquidityDetector &liq_detector, CMarketStructureAnalyzer &ms_analyzer, CAdvancedFilters &adv_filters, bool use_adv_filters);
   double            CalculateSellScore(COrderBlockDetector &ob_detector, CFVGDetector &fvg_detector, CLiquidityDetector &liq_detector, CMarketStructureAnalyzer &ms_analyzer, CAdvancedFilters &adv_filters, bool use_adv_filters);
   
   // Análise detalhada
   SConfluenceData   GetLastBullishConfluence(void) { return m_lastBullishConfluence; }
   SConfluenceData   GetLastBearishConfluence(void) { return m_lastBearishConfluence; }
   
   // Utilitários
   string            GetConfluenceDetails(SConfluenceData &data);
   double            GetConfluenceQuality(double score);
   
   // Validação de sinais
   bool              ValidateSignal(ENUM_CONFLUENCE_TYPE type, double score);
   ENUM_SIGNAL_STRENGTH GetSignalStrength(double score);
   
   // Configuração
   void              SetConfig(SConfluenceConfig &config);
   SConfluenceConfig GetConfig(void);
   
   // Análise de confluência principal
   SConfluenceResult AnalyzeConfluence(ENUM_CONFLUENCE_TYPE type);
   double            CalculateScore(ENUM_CONFLUENCE_TYPE type);
   double            GetConfluenceLevel(ENUM_CONFLUENCE_TYPE type);
   bool              AddSignal(ENUM_CONFLUENCE_TYPE type, double strength);
   
private:
   // Métodos internos
   double            CalculateOrderBlockScore(bool hasOB, double strength);
   double            CalculateFVGScore(bool hasFVG, double strength);
   double            CalculateLiquidityScore(bool hasLiq, double strength);
   double            CalculateStructureScore(bool hasStruct, double strength);
   double            CalculateMomentumScore(double rsiValue, ENUM_CONFLUENCE_TYPE type);
   double            CalculateVolumeScore(double volumeRatio);
   
   void              UpdateConfluenceData(ENUM_CONFLUENCE_TYPE type, SConfluenceData &data);
   string            FormatConfluenceDetails(SConfluenceData &data);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CSignalConfluence::CSignalConfluence(void)
{
   // Inicializar pesos padrão
   m_orderBlockWeight = 30.0;
   m_fvgWeight = 25.0;
   m_liquidityWeight = 20.0;
   m_structureWeight = 25.0;
   m_momentumWeight = 15.0;
   m_volumeWeight = 10.0;
   
   // Pontuação mínima padrão (70% da pontuação máxima)
   m_minConfluenceScore = 70.0;
   
   // Inicializar dados
   ZeroMemory(m_lastBullishConfluence);
   ZeroMemory(m_lastBearishConfluence);
   
   m_logger = NULL;
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CSignalConfluence::~CSignalConfluence(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
bool CSignalConfluence::Initialize(string symbol, ENUM_TIMEFRAMES timeframe, CLogger* logger)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   m_logger = logger;
   
   if(m_logger != NULL)
      m_logger.LogInfo("SignalConfluence", "Sistema de confluência inicializado para " + symbol);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinicialização                                                  |
//+------------------------------------------------------------------+
void CSignalConfluence::Deinitialize(void)
{
   if(m_logger != NULL)
      m_logger.LogInfo("SignalConfluence", "Sistema de confluência deinicializado");
}

//+------------------------------------------------------------------+
//| Configurar pesos dos componentes                                 |
//+------------------------------------------------------------------+
void CSignalConfluence::SetWeights(double obWeight, double fvgWeight, double liqWeight,
                                  double structWeight, double momWeight, double volWeight)
{
   m_orderBlockWeight = MathMax(0, obWeight);
   m_fvgWeight = MathMax(0, fvgWeight);
   m_liquidityWeight = MathMax(0, liqWeight);
   m_structureWeight = MathMax(0, structWeight);
   m_momentumWeight = MathMax(0, momWeight);
   m_volumeWeight = MathMax(0, volWeight);
   
   if(m_logger != NULL)
   {
      string msg = StringFormat("Pesos atualizados: OB=%.1f, FVG=%.1f, LIQ=%.1f, STRUCT=%.1f, MOM=%.1f, VOL=%.1f",
                               m_orderBlockWeight, m_fvgWeight, m_liquidityWeight, 
                               m_structureWeight, m_momentumWeight, m_volumeWeight);
      m_logger.LogInfo("SignalConfluence", msg);
   }
}

//+------------------------------------------------------------------+
//| Calcular pontuação de confluência                               |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateConfluenceScore(ENUM_CONFLUENCE_TYPE type,
                                                  bool hasOrderBlock, double obStrength,
                                                  bool hasFVG, double fvgStrength,
                                                  bool hasLiquidity, double liqStrength,
                                                  bool hasStructure, double structStrength,
                                                  double rsiValue, double volumeRatio)
{
   SConfluenceData data;
   ZeroMemory(data);
   
   // Calcular pontuações individuais
   data.orderBlockScore = CalculateOrderBlockScore(hasOrderBlock, obStrength);
   data.fvgScore = CalculateFVGScore(hasFVG, fvgStrength);
   data.liquidityScore = CalculateLiquidityScore(hasLiquidity, liqStrength);
   data.structureScore = CalculateStructureScore(hasStructure, structStrength);
   data.momentumScore = CalculateMomentumScore(rsiValue, type);
   data.volumeScore = CalculateVolumeScore(volumeRatio);
   
   // Calcular pontuação total
   data.totalScore = data.orderBlockScore + data.fvgScore + data.liquidityScore + 
                    data.structureScore + data.momentumScore + data.volumeScore;
   
   data.timestamp = TimeCurrent();
   data.details = FormatConfluenceDetails(data);
   
   // Atualizar dados históricos
   UpdateConfluenceData(type, data);
   
   if(m_logger != NULL)
   {
      string typeStr = (type == CONFLUENCE_BULLISH) ? "BULLISH" : "BEARISH";
      string msg = StringFormat("Confluência %s: Score=%.1f (OB:%.1f, FVG:%.1f, LIQ:%.1f, STRUCT:%.1f, MOM:%.1f, VOL:%.1f)",
                               typeStr, data.totalScore, data.orderBlockScore, data.fvgScore,
                               data.liquidityScore, data.structureScore, data.momentumScore, data.volumeScore);
      m_logger.LogDebug("SignalConfluence", msg);
   }
   
   return data.totalScore;
}

//+------------------------------------------------------------------+
//| Validar confluência bullish                                     |
//+------------------------------------------------------------------+
bool CSignalConfluence::IsValidBullishConfluence(double score)
{
   return (score >= m_minConfluenceScore);
}

//+------------------------------------------------------------------+
//| Validar confluência bearish                                     |
//+------------------------------------------------------------------+
bool CSignalConfluence::IsValidBearishConfluence(double score)
{
   return (score >= m_minConfluenceScore);
}

//+------------------------------------------------------------------+
//| Calcular pontuação Order Block                                  |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateOrderBlockScore(bool hasOB, double strength)
{
   if(!hasOB) return 0.0;
   
   // Strength deve estar entre 0.0 e 1.0
   double normalizedStrength = MathMax(0.0, MathMin(1.0, strength));
   
   return m_orderBlockWeight * normalizedStrength;
}

//+------------------------------------------------------------------+
//| Calcular pontuação FVG                                          |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateFVGScore(bool hasFVG, double strength)
{
   if(!hasFVG) return 0.0;
   
   double normalizedStrength = MathMax(0.0, MathMin(1.0, strength));
   
   return m_fvgWeight * normalizedStrength;
}

//+------------------------------------------------------------------+
//| Calcular pontuação Liquidez                                     |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateLiquidityScore(bool hasLiq, double strength)
{
   if(!hasLiq) return 0.0;
   
   double normalizedStrength = MathMax(0.0, MathMin(1.0, strength));
   
   return m_liquidityWeight * normalizedStrength;
}

//+------------------------------------------------------------------+
//| Calcular pontuação Estrutura                                    |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateStructureScore(bool hasStruct, double strength)
{
   if(!hasStruct) return 0.0;
   
   double normalizedStrength = MathMax(0.0, MathMin(1.0, strength));
   
   return m_structureWeight * normalizedStrength;
}

//+------------------------------------------------------------------+
//| Calcular pontuação Momentum                                     |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateMomentumScore(double rsiValue, ENUM_CONFLUENCE_TYPE type)
{
   if(rsiValue < 0 || rsiValue > 100) return 0.0;
   
   double score = 0.0;
   
   if(type == CONFLUENCE_BULLISH)
   {
      // Para sinais de alta, RSI deve estar em oversold ou saindo de oversold
      if(rsiValue <= 30)
         score = 1.0;  // RSI em oversold extremo
      else if(rsiValue <= 40)
         score = 0.8;  // RSI saindo de oversold
      else if(rsiValue <= 50)
         score = 0.5;  // RSI neutro baixo
      else
         score = 0.2;  // RSI alto (menos favorável para compra)
   }
   else if(type == CONFLUENCE_BEARISH)
   {
      // Para sinais de baixa, RSI deve estar em overbought ou saindo de overbought
      if(rsiValue >= 70)
         score = 1.0;  // RSI em overbought extremo
      else if(rsiValue >= 60)
         score = 0.8;  // RSI saindo de overbought
      else if(rsiValue >= 50)
         score = 0.5;  // RSI neutro alto
      else
         score = 0.2;  // RSI baixo (menos favorável para venda)
   }
   
   return m_momentumWeight * score;
}

//+------------------------------------------------------------------+
//| Calcular pontuação Volume                                       |
//+------------------------------------------------------------------+
double CSignalConfluence::CalculateVolumeScore(double volumeRatio)
{
   if(volumeRatio <= 0) return 0.0;
   
   double score = 0.0;
   
   // Volume ratio é a relação entre volume atual e média de volume
   if(volumeRatio >= 2.0)
      score = 1.0;      // Volume muito alto
   else if(volumeRatio >= 1.5)
      score = 0.8;      // Volume alto
   else if(volumeRatio >= 1.2)
      score = 0.6;      // Volume acima da média
   else if(volumeRatio >= 1.0)
      score = 0.4;      // Volume normal
   else
      score = 0.2;      // Volume baixo
   
   return m_volumeWeight * score;
}

//+------------------------------------------------------------------+
//| Atualizar dados de confluência                                  |
//+------------------------------------------------------------------+
void CSignalConfluence::UpdateConfluenceData(ENUM_CONFLUENCE_TYPE type, SConfluenceData &data)
{
   if(type == CONFLUENCE_BULLISH)
      m_lastBullishConfluence = data;
   else if(type == CONFLUENCE_BEARISH)
      m_lastBearishConfluence = data;
}

//+------------------------------------------------------------------+
//| Formatar detalhes da confluência                                |
//+------------------------------------------------------------------+
string CSignalConfluence::FormatConfluenceDetails(SConfluenceData &data)
{
   return StringFormat("OB:%.1f|FVG:%.1f|LIQ:%.1f|STRUCT:%.1f|MOM:%.1f|VOL:%.1f|TOTAL:%.1f",
                      data.orderBlockScore, data.fvgScore, data.liquidityScore,
                      data.structureScore, data.momentumScore, data.volumeScore, data.totalScore);
}

//+------------------------------------------------------------------+
//| Obter detalhes da confluência                                   |
//+------------------------------------------------------------------+
string CSignalConfluence::GetConfluenceDetails(SConfluenceData &data)
{
   return data.details;
}

//+------------------------------------------------------------------+
//| Obter qualidade da confluência                                  |
//+------------------------------------------------------------------+
double CSignalConfluence::GetConfluenceQuality(double score)
{
   double maxScore = m_orderBlockWeight + m_fvgWeight + m_liquidityWeight + 
                    m_structureWeight + m_momentumWeight + m_volumeWeight;
   
   if(maxScore <= 0) return 0.0;
   
   return (score / maxScore) * 100.0;  // Retorna percentual de qualidade
}

//+------------------------------------------------------------------+
//| Validar sinal baseado na pontuação                              |
//+------------------------------------------------------------------+
bool CSignalConfluence::ValidateSignal(ENUM_CONFLUENCE_TYPE type, double score)
{
   // Verificar se a pontuação atende ao mínimo
   if(score < m_minConfluenceScore)
      return false;
   
   // Log da validação
   if(m_logger != NULL)
   {
      string typeStr = (type == CONFLUENCE_BULLISH) ? "BULLISH" : "BEARISH";
      string msg = StringFormat("Sinal %s validado: Score=%.2f (Min=%.2f)", 
                               typeStr, score, m_minConfluenceScore);
      m_logger.LogInfo("SignalConfluence", msg);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter força do sinal baseado na pontuação                       |
//+------------------------------------------------------------------+
ENUM_SIGNAL_STRENGTH CSignalConfluence::GetSignalStrength(double score)
{
   double maxScore = m_orderBlockWeight + m_fvgWeight + m_liquidityWeight + 
                    m_structureWeight + m_momentumWeight + m_volumeWeight;
   
   if(maxScore <= 0) return SIGNAL_WEAK;
   
   double percentage = (score / maxScore) * 100.0;
   
   if(percentage >= 85.0)
      return SIGNAL_VERY_STRONG;
   else if(percentage >= 70.0)
      return SIGNAL_STRONG;
   else if(percentage >= 50.0)
      return SIGNAL_MODERATE;
   else
      return SIGNAL_WEAK;
}

//+------------------------------------------------------------------+
//| Configurar parâmetros da confluência                            |
//+------------------------------------------------------------------+
void CSignalConfluence::SetConfig(SConfluenceConfig &config)
{
   m_minConfluenceScore = config.minScore;
   m_orderBlockWeight = config.orderBlockWeight;
   m_fvgWeight = config.fvgWeight;
   m_liquidityWeight = config.liquidityWeight;
   m_structureWeight = config.structureWeight;
   m_momentumWeight = config.momentumWeight;
   m_volumeWeight = config.volumeWeight;
   
   if(m_logger != NULL)
      m_logger.LogInfo("SignalConfluence", "Configuração atualizada via SetConfig");
}

//+------------------------------------------------------------------+
//| Obter configuração atual                                        |
//+------------------------------------------------------------------+
SConfluenceConfig CSignalConfluence::GetConfig(void)
{
   SConfluenceConfig config;
   config.minScore = m_minConfluenceScore;
   config.orderBlockWeight = m_orderBlockWeight;
   config.fvgWeight = m_fvgWeight;
   config.liquidityWeight = m_liquidityWeight;
   config.structureWeight = m_structureWeight;
   config.momentumWeight = m_momentumWeight;
   config.volumeWeight = m_volumeWeight;
   config.requireOrderBlock = false;  // Padrão
   config.requireFVG = false;         // Padrão
   config.requireLiquidity = false;   // Padrão
   
   return config;
}

//+------------------------------------------------------------------+
//| Obter nível de confluência normalizado (0.0 - 1.0)             |
//+------------------------------------------------------------------+
double CSignalConfluence::GetConfluenceLevel(ENUM_CONFLUENCE_TYPE type)
{
   // Calcular score atual
   double currentScore = CalculateScore(type);
   
   // Normalizar para 0.0 - 1.0
   double maxPossibleScore = m_orderBlockWeight + m_fvgWeight + m_liquidityWeight + 
                            m_structureWeight + m_momentumWeight + m_volumeWeight;
   
   if(maxPossibleScore <= 0.0)
      return 0.0;
   
   double normalizedLevel = currentScore / maxPossibleScore;
   
   // Garantir que está no range 0.0 - 1.0
   if(normalizedLevel < 0.0) normalizedLevel = 0.0;
   if(normalizedLevel > 1.0) normalizedLevel = 1.0;
   
   return normalizedLevel;
}

//+------------------------------------------------------------------+
//| Adicionar sinal ao sistema de confluência                      |
//+------------------------------------------------------------------+
bool CSignalConfluence::AddSignal(ENUM_CONFLUENCE_TYPE type, double strength)
{
   if(strength < 0.0 || strength > 1.0)
      return false;
   
   // Atualizar dados de confluência baseado no tipo
   if(type == CONFLUENCE_BULLISH)
   {
      m_lastBullishConfluence.timestamp = TimeCurrent();
      m_lastBullishConfluence.totalScore += strength * 10.0; // Converter para escala 0-100
   }
   else if(type == CONFLUENCE_BEARISH)
   {
      m_lastBearishConfluence.timestamp = TimeCurrent();
      m_lastBearishConfluence.totalScore += strength * 10.0; // Converter para escala 0-100
   }
   
   return true;
}

//+------------------------------------------------------------------+