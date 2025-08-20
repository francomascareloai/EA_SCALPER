//+------------------------------------------------------------------+
//|                                        ConfluenceEntrySystem.mqh |
//|                                  Copyright 2024, TradeDev_Master |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "RiskManager.mqh"
#include "AdvancedFilters.mqh"

//+------------------------------------------------------------------+
//| Enumerações para sinais de entrada                               |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE
{
   SIGNAL_NONE = 0,     // Nenhum sinal
   SIGNAL_BUY = 1,      // Sinal de compra
   SIGNAL_SELL = -1     // Sinal de venda
};

enum ENUM_CONFLUENCE_LEVEL
{
   CONFLUENCE_WEAK = 2,     // Confluência fraca (2 indicadores)
   CONFLUENCE_MEDIUM = 3,   // Confluência média (3 indicadores)
   CONFLUENCE_STRONG = 4    // Confluência forte (4 indicadores)
};

//+------------------------------------------------------------------+
//| Estrutura para configurações dos indicadores                     |
//+------------------------------------------------------------------+
struct IndicatorSettings
{
   // Supertrend
   int      supertrend_period;
   double   supertrend_multiplier;
   
   // RSI
   int      rsi_period;
   double   rsi_oversold;
   double   rsi_overbought;
   
   // MACD
   int      macd_fast_ema;
   int      macd_slow_ema;
   int      macd_signal;
   
   // EMA
   int      ema_fast;
   int      ema_slow;
   
   // Confluência
   ENUM_CONFLUENCE_LEVEL min_confluence_level;
   bool     require_market_structure;
};

//+------------------------------------------------------------------+
//| Estrutura para dados de mercado                                  |
//+------------------------------------------------------------------+
struct MarketStructure
{
   double   higher_high;
   double   higher_low;
   double   lower_high;
   double   lower_low;
   bool     uptrend;
   bool     downtrend;
   bool     sideways;
};

//+------------------------------------------------------------------+
//| Classe principal do sistema de confluência                       |
//+------------------------------------------------------------------+
class CConfluenceEntrySystem
{
private:
   // Handles dos indicadores
   int               m_supertrend_handle;
   int               m_rsi_handle;
   int               m_macd_handle;
   int               m_ema_fast_handle;
   int               m_ema_slow_handle;
   
   // Configurações
   IndicatorSettings m_settings;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   
   // Buffers para dados dos indicadores
   double            m_supertrend_main[];
   double            m_supertrend_trend[];
   double            m_rsi_buffer[];
   double            m_macd_main[];
   double            m_macd_signal[];
   double            m_ema_fast[];
   double            m_ema_slow[];
   
   // Estrutura de mercado
   MarketStructure   m_market_structure;
   
   // Dependências
   CFTMORiskManager  *m_risk_manager;
   CAdvancedFilters  *m_filters;
   
   // Métodos privados
   bool              InitializeIndicators();
   bool              UpdateIndicatorData();
   ENUM_SIGNAL_TYPE  AnalyzeSupertrend();
   ENUM_SIGNAL_TYPE  AnalyzeRSI();
   ENUM_SIGNAL_TYPE  AnalyzeMACD();
   ENUM_SIGNAL_TYPE  AnalyzeEMA();
   bool              AnalyzeMarketStructure();
   int               CountConfluenceSignals(ENUM_SIGNAL_TYPE signal_type);
   bool              ValidateEntry(ENUM_SIGNAL_TYPE signal_type);
   
public:
   // Construtor e destrutor
                     CConfluenceEntrySystem();
                    ~CConfluenceEntrySystem();
   
   // Métodos de inicialização
   bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe, 
                               CFTMORiskManager *risk_manager,
                               CAdvancedFilters *filters);
   void              Deinitialize();
   
   // Configuração dos indicadores
   void              SetSupertrendSettings(int period, double multiplier);
   void              SetRSISettings(int period, double oversold, double overbought);
   void              SetMACDSettings(int fast_ema, int slow_ema, int signal);
   void              SetEMASettings(int fast, int slow);
   void              SetConfluenceSettings(ENUM_CONFLUENCE_LEVEL min_level, bool require_structure);
   
   // Análise de sinais
   ENUM_SIGNAL_TYPE  AnalyzeEntry();
   bool              IsValidEntryTime();
   double            CalculateStopLoss(ENUM_SIGNAL_TYPE signal_type);
   double            CalculateTakeProfit(ENUM_SIGNAL_TYPE signal_type, double stop_loss);
   
   // Métodos de informação
   string            GetSignalReport();
   string            GetIndicatorStatus();
   MarketStructure   GetMarketStructure() { return m_market_structure; }
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
CConfluenceEntrySystem::CConfluenceEntrySystem()
{
   // Inicializar handles como inválidos
   m_supertrend_handle = INVALID_HANDLE;
   m_rsi_handle = INVALID_HANDLE;
   m_macd_handle = INVALID_HANDLE;
   m_ema_fast_handle = INVALID_HANDLE;
   m_ema_slow_handle = INVALID_HANDLE;
   
   // Configurações padrão
   m_settings.supertrend_period = 10;
   m_settings.supertrend_multiplier = 3.0;
   m_settings.rsi_period = 14;
   m_settings.rsi_oversold = 30.0;
   m_settings.rsi_overbought = 70.0;
   m_settings.macd_fast_ema = 12;
   m_settings.macd_slow_ema = 26;
   m_settings.macd_signal = 9;
   m_settings.ema_fast = 21;
   m_settings.ema_slow = 50;
   m_settings.min_confluence_level = CONFLUENCE_MEDIUM;
   m_settings.require_market_structure = true;
   
   // Inicializar estrutura de mercado
   ZeroMemory(m_market_structure);
   
   // Configurar arrays como séries temporais
   ArraySetAsSeries(m_supertrend_main, true);
   ArraySetAsSeries(m_supertrend_trend, true);
   ArraySetAsSeries(m_rsi_buffer, true);
   ArraySetAsSeries(m_macd_main, true);
   ArraySetAsSeries(m_macd_signal, true);
   ArraySetAsSeries(m_ema_fast, true);
   ArraySetAsSeries(m_ema_slow, true);
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
CConfluenceEntrySystem::~CConfluenceEntrySystem()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicialização do sistema                                          |
//+------------------------------------------------------------------+
bool CConfluenceEntrySystem::Initialize(string symbol, ENUM_TIMEFRAMES timeframe,
                                       CFTMORiskManager *risk_manager,
                                       CAdvancedFilters *filters)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   m_risk_manager = risk_manager;
   m_filters = filters;
   
   if(!InitializeIndicators())
   {
      Print("[ConfluenceEntry] Erro ao inicializar indicadores");
      return false;
   }
   
   Print("[ConfluenceEntry] Sistema inicializado com sucesso para ", symbol, " ", EnumToString(timeframe));
   return true;
}

//+------------------------------------------------------------------+
//| Inicialização dos indicadores                                     |
//+------------------------------------------------------------------+
bool CConfluenceEntrySystem::InitializeIndicators()
{
   // Inicializar RSI
   m_rsi_handle = iRSI(m_symbol, m_timeframe, m_settings.rsi_period, PRICE_CLOSE);
   if(m_rsi_handle == INVALID_HANDLE)
   {
      Print("[ConfluenceEntry] Erro ao criar handle RSI");
      return false;
   }
   
   // Inicializar MACD
   m_macd_handle = iMACD(m_symbol, m_timeframe, m_settings.macd_fast_ema, 
                        m_settings.macd_slow_ema, m_settings.macd_signal, PRICE_CLOSE);
   if(m_macd_handle == INVALID_HANDLE)
   {
      Print("[ConfluenceEntry] Erro ao criar handle MACD");
      return false;
   }
   
   // Inicializar EMAs
   m_ema_fast_handle = iMA(m_symbol, m_timeframe, m_settings.ema_fast, 0, MODE_EMA, PRICE_CLOSE);
   if(m_ema_fast_handle == INVALID_HANDLE)
   {
      Print("[ConfluenceEntry] Erro ao criar handle EMA rápida");
      return false;
   }
   
   m_ema_slow_handle = iMA(m_symbol, m_timeframe, m_settings.ema_slow, 0, MODE_EMA, PRICE_CLOSE);
   if(m_ema_slow_handle == INVALID_HANDLE)
   {
      Print("[ConfluenceEntry] Erro ao criar handle EMA lenta");
      return false;
   }
   
   // Nota: Supertrend precisa ser implementado como indicador customizado
   // Por enquanto, vamos usar ATR + MA como aproximação
   
   return true;
}

//+------------------------------------------------------------------+
//| Atualização dos dados dos indicadores                            |
//+------------------------------------------------------------------+
bool CConfluenceEntrySystem::UpdateIndicatorData()
{
   // Copiar dados do RSI
   if(CopyBuffer(m_rsi_handle, 0, 0, 3, m_rsi_buffer) <= 0)
   {
      Print("[ConfluenceEntry] Erro ao copiar dados RSI");
      return false;
   }
   
   // Copiar dados do MACD
   if(CopyBuffer(m_macd_handle, MAIN_LINE, 0, 3, m_macd_main) <= 0 ||
      CopyBuffer(m_macd_handle, SIGNAL_LINE, 0, 3, m_macd_signal) <= 0)
   {
      Print("[ConfluenceEntry] Erro ao copiar dados MACD");
      return false;
   }
   
   // Copiar dados das EMAs
   if(CopyBuffer(m_ema_fast_handle, 0, 0, 3, m_ema_fast) <= 0 ||
      CopyBuffer(m_ema_slow_handle, 0, 0, 3, m_ema_slow) <= 0)
   {
      Print("[ConfluenceEntry] Erro ao copiar dados EMA");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Análise do RSI                                                   |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CConfluenceEntrySystem::AnalyzeRSI()
{
   if(ArraySize(m_rsi_buffer) < 2) return SIGNAL_NONE;
   
   double current_rsi = m_rsi_buffer[0];
   double previous_rsi = m_rsi_buffer[1];
   
   // Sinal de compra: RSI saindo da zona de sobrevenda
   if(previous_rsi <= m_settings.rsi_oversold && current_rsi > m_settings.rsi_oversold)
      return SIGNAL_BUY;
   
   // Sinal de venda: RSI saindo da zona de sobrecompra
   if(previous_rsi >= m_settings.rsi_overbought && current_rsi < m_settings.rsi_overbought)
      return SIGNAL_SELL;
   
   return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| Análise do MACD                                                  |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CConfluenceEntrySystem::AnalyzeMACD()
{
   if(ArraySize(m_macd_main) < 2 || ArraySize(m_macd_signal) < 2) return SIGNAL_NONE;
   
   double current_macd = m_macd_main[0];
   double current_signal = m_macd_signal[0];
   double previous_macd = m_macd_main[1];
   double previous_signal = m_macd_signal[1];
   
   // Sinal de compra: MACD cruza acima da linha de sinal
   if(previous_macd <= previous_signal && current_macd > current_signal)
      return SIGNAL_BUY;
   
   // Sinal de venda: MACD cruza abaixo da linha de sinal
   if(previous_macd >= previous_signal && current_macd < current_signal)
      return SIGNAL_SELL;
   
   return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| Análise das EMAs                                                 |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CConfluenceEntrySystem::AnalyzeEMA()
{
   if(ArraySize(m_ema_fast) < 2 || ArraySize(m_ema_slow) < 2) return SIGNAL_NONE;
   
   double current_fast = m_ema_fast[0];
   double current_slow = m_ema_slow[0];
   double previous_fast = m_ema_fast[1];
   double previous_slow = m_ema_slow[1];
   
   // Sinal de compra: EMA rápida cruza acima da EMA lenta
   if(previous_fast <= previous_slow && current_fast > current_slow)
      return SIGNAL_BUY;
   
   // Sinal de venda: EMA rápida cruza abaixo da EMA lenta
   if(previous_fast >= previous_slow && current_fast < current_slow)
      return SIGNAL_SELL;
   
   return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| Análise da estrutura de mercado                                  |
//+------------------------------------------------------------------+
bool CConfluenceEntrySystem::AnalyzeMarketStructure()
{
   // Obter dados de preço
   MqlRates rates[];
   if(CopyRates(m_symbol, m_timeframe, 0, 20, rates) <= 0)
      return false;
   
   ArraySetAsSeries(rates, true);
   
   // Identificar máximas e mínimas recentes
   double recent_highs[5], recent_lows[5];
   int high_count = 0, low_count = 0;
   
   for(int i = 2; i < 18 && high_count < 5 && low_count < 5; i++)
   {
      // Identificar máximas locais
      if(rates[i].high > rates[i-1].high && rates[i].high > rates[i+1].high && 
         rates[i].high > rates[i-2].high && rates[i].high > rates[i+2].high)
      {
         recent_highs[high_count++] = rates[i].high;
      }
      
      // Identificar mínimas locais
      if(rates[i].low < rates[i-1].low && rates[i].low < rates[i+1].low && 
         rates[i].low < rates[i-2].low && rates[i].low < rates[i+2].low)
      {
         recent_lows[low_count++] = rates[i].low;
      }
   }
   
   // Analisar tendência baseada na estrutura
   if(high_count >= 2 && low_count >= 2)
   {
      bool higher_highs = recent_highs[0] > recent_highs[1];
      bool higher_lows = recent_lows[0] > recent_lows[1];
      bool lower_highs = recent_highs[0] < recent_highs[1];
      bool lower_lows = recent_lows[0] < recent_lows[1];
      
      m_market_structure.uptrend = higher_highs && higher_lows;
      m_market_structure.downtrend = lower_highs && lower_lows;
      m_market_structure.sideways = !m_market_structure.uptrend && !m_market_structure.downtrend;
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Contagem de sinais de confluência                                |
//+------------------------------------------------------------------+
int CConfluenceEntrySystem::CountConfluenceSignals(ENUM_SIGNAL_TYPE signal_type)
{
   int count = 0;
   
   // Verificar cada indicador
   if(AnalyzeRSI() == signal_type) count++;
   if(AnalyzeMACD() == signal_type) count++;
   if(AnalyzeEMA() == signal_type) count++;
   // if(AnalyzeSupertrend() == signal_type) count++; // Implementar quando disponível
   
   return count;
}

//+------------------------------------------------------------------+
//| Análise principal de entrada                                     |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CConfluenceEntrySystem::AnalyzeEntry()
{
   // Verificar se o trading é permitido pelos filtros
   if(m_filters != NULL && !m_filters.IsTradingAllowed())
      return SIGNAL_NONE;
   
   // Verificar se o risk manager permite trading
   if(m_risk_manager != NULL && !m_risk_manager.IsTradingAllowed())
      return SIGNAL_NONE;
   
   // Atualizar dados dos indicadores
   if(!UpdateIndicatorData())
      return SIGNAL_NONE;
   
   // Analisar estrutura de mercado se necessário
   if(m_settings.require_market_structure)
   {
      if(!AnalyzeMarketStructure())
         return SIGNAL_NONE;
   }
   
   // Verificar confluência para compra
   int buy_signals = CountConfluenceSignals(SIGNAL_BUY);
   if(buy_signals >= (int)m_settings.min_confluence_level)
   {
      if(!m_settings.require_market_structure || m_market_structure.uptrend)
         return SIGNAL_BUY;
   }
   
   // Verificar confluência para venda
   int sell_signals = CountConfluenceSignals(SIGNAL_SELL);
   if(sell_signals >= (int)m_settings.min_confluence_level)
   {
      if(!m_settings.require_market_structure || m_market_structure.downtrend)
         return SIGNAL_SELL;
   }
   
   return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| Cálculo do Stop Loss                                             |
//+------------------------------------------------------------------+
double CConfluenceEntrySystem::CalculateStopLoss(ENUM_SIGNAL_TYPE signal_type)
{
   if(signal_type == SIGNAL_NONE) return 0.0;
   
   // Obter ATR para cálculo dinâmico
   int atr_handle = iATR(m_symbol, m_timeframe, 14);
   if(atr_handle == INVALID_HANDLE) return 0.0;
   
   double atr_buffer[1];
   if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) <= 0)
   {
      IndicatorRelease(atr_handle);
      return 0.0;
   }
   
   double atr_value = atr_buffer[0];
   IndicatorRelease(atr_handle);
   
   // Obter preço atual
   MqlTick tick;
   if(!SymbolInfoTick(m_symbol, tick))
      return 0.0;
   
   double current_price = (signal_type == SIGNAL_BUY) ? tick.ask : tick.bid;
   double stop_distance = atr_value * 2.0; // 2x ATR como distância padrão
   
   if(signal_type == SIGNAL_BUY)
      return current_price - stop_distance;
   else
      return current_price + stop_distance;
}

//+------------------------------------------------------------------+
//| Cálculo do Take Profit                                           |
//+------------------------------------------------------------------+
double CConfluenceEntrySystem::CalculateTakeProfit(ENUM_SIGNAL_TYPE signal_type, double stop_loss)
{
   if(signal_type == SIGNAL_NONE || stop_loss == 0.0) return 0.0;
   
   // Obter preço atual
   MqlTick tick;
   if(!SymbolInfoTick(m_symbol, tick))
      return 0.0;
   
   double current_price = (signal_type == SIGNAL_BUY) ? tick.ask : tick.bid;
   double stop_distance = MathAbs(current_price - stop_loss);
   double tp_ratio = 2.0; // Risk:Reward 1:2
   
   if(signal_type == SIGNAL_BUY)
      return current_price + (stop_distance * tp_ratio);
   else
      return current_price - (stop_distance * tp_ratio);
}

//+------------------------------------------------------------------+
//| Configuração do Supertrend                                       |
//+------------------------------------------------------------------+
void CConfluenceEntrySystem::SetSupertrendSettings(int period, double multiplier)
{
   m_settings.supertrend_period = period;
   m_settings.supertrend_multiplier = multiplier;
}

//+------------------------------------------------------------------+
//| Configuração do RSI                                              |
//+------------------------------------------------------------------+
void CConfluenceEntrySystem::SetRSISettings(int period, double oversold, double overbought)
{
   m_settings.rsi_period = period;
   m_settings.rsi_oversold = oversold;
   m_settings.rsi_overbought = overbought;
}

//+------------------------------------------------------------------+
//| Configuração do MACD                                             |
//+------------------------------------------------------------------+
void CConfluenceEntrySystem::SetMACDSettings(int fast_ema, int slow_ema, int signal)
{
   m_settings.macd_fast_ema = fast_ema;
   m_settings.macd_slow_ema = slow_ema;
   m_settings.macd_signal = signal;
}

//+------------------------------------------------------------------+
//| Configuração das EMAs                                            |
//+------------------------------------------------------------------+
void CConfluenceEntrySystem::SetEMASettings(int fast, int slow)
{
   m_settings.ema_fast = fast;
   m_settings.ema_slow = slow;
}

//+------------------------------------------------------------------+
//| Configuração da confluência                                      |
//+------------------------------------------------------------------+
void CConfluenceEntrySystem::SetConfluenceSettings(ENUM_CONFLUENCE_LEVEL min_level, bool require_structure)
{
   m_settings.min_confluence_level = min_level;
   m_settings.require_market_structure = require_structure;
}

//+------------------------------------------------------------------+
//| Relatório de sinais                                              |
//+------------------------------------------------------------------+
string CConfluenceEntrySystem::GetSignalReport()
{
   if(!UpdateIndicatorData())
      return "Erro ao atualizar dados";
   
   string report = "\n=== RELATÓRIO DE CONFLUÊNCIA ===\n";
   
   // Status dos indicadores
   ENUM_SIGNAL_TYPE rsi_signal = AnalyzeRSI();
   ENUM_SIGNAL_TYPE macd_signal = AnalyzeMACD();
   ENUM_SIGNAL_TYPE ema_signal = AnalyzeEMA();
   
   report += StringFormat("RSI (%.1f): %s\n", 
                         ArraySize(m_rsi_buffer) > 0 ? m_rsi_buffer[0] : 0.0,
                         rsi_signal == SIGNAL_BUY ? "COMPRA" : 
                         rsi_signal == SIGNAL_SELL ? "VENDA" : "NEUTRO");
   
   report += StringFormat("MACD (%.5f/%.5f): %s\n",
                         ArraySize(m_macd_main) > 0 ? m_macd_main[0] : 0.0,
                         ArraySize(m_macd_signal) > 0 ? m_macd_signal[0] : 0.0,
                         macd_signal == SIGNAL_BUY ? "COMPRA" : 
                         macd_signal == SIGNAL_SELL ? "VENDA" : "NEUTRO");
   
   report += StringFormat("EMA (%.5f/%.5f): %s\n",
                         ArraySize(m_ema_fast) > 0 ? m_ema_fast[0] : 0.0,
                         ArraySize(m_ema_slow) > 0 ? m_ema_slow[0] : 0.0,
                         ema_signal == SIGNAL_BUY ? "COMPRA" : 
                         ema_signal == SIGNAL_SELL ? "VENDA" : "NEUTRO");
   
   // Confluência
   int buy_count = CountConfluenceSignals(SIGNAL_BUY);
   int sell_count = CountConfluenceSignals(SIGNAL_SELL);
   
   report += StringFormat("\nConfluência COMPRA: %d/%d\n", buy_count, 3);
   report += StringFormat("Confluência VENDA: %d/%d\n", sell_count, 3);
   
   // Estrutura de mercado
   if(m_settings.require_market_structure)
   {
      AnalyzeMarketStructure();
      report += StringFormat("\nEstrutura: %s\n",
                            m_market_structure.uptrend ? "ALTA" :
                            m_market_structure.downtrend ? "BAIXA" : "LATERAL");
   }
   
   return report;
}

//+------------------------------------------------------------------+
//| Status dos indicadores                                           |
//+------------------------------------------------------------------+
string CConfluenceEntrySystem::GetIndicatorStatus()
{
   string status = "\n=== STATUS DOS INDICADORES ===\n";
   
   status += StringFormat("RSI Handle: %s\n", 
                         m_rsi_handle != INVALID_HANDLE ? "OK" : "ERRO");
   status += StringFormat("MACD Handle: %s\n", 
                         m_macd_handle != INVALID_HANDLE ? "OK" : "ERRO");
   status += StringFormat("EMA Fast Handle: %s\n", 
                         m_ema_fast_handle != INVALID_HANDLE ? "OK" : "ERRO");
   status += StringFormat("EMA Slow Handle: %s\n", 
                         m_ema_slow_handle != INVALID_HANDLE ? "OK" : "ERRO");
   
   return status;
}

//+------------------------------------------------------------------+
//| Desinicialização                                                 |
//+------------------------------------------------------------------+
void CConfluenceEntrySystem::Deinitialize()
{
   // Liberar handles dos indicadores
   if(m_rsi_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_rsi_handle);
      m_rsi_handle = INVALID_HANDLE;
   }
   
   if(m_macd_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_macd_handle);
      m_macd_handle = INVALID_HANDLE;
   }
   
   if(m_ema_fast_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_ema_fast_handle);
      m_ema_fast_handle = INVALID_HANDLE;
   }
   
   if(m_ema_slow_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_ema_slow_handle);
      m_ema_slow_handle = INVALID_HANDLE;
   }
   
   Print("[ConfluenceEntry] Sistema desinicializado");
}

//+------------------------------------------------------------------+