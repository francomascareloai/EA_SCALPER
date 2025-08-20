//+------------------------------------------------------------------+
//|                                        EA_FTMO_Scalper_Elite.mq5 |
//|                                    TradeDev_Master Elite System |
//|                          Advanced ICT/SMC Scalping EA - FTMO |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "2.12"
#property description "Elite FTMO-Ready Scalping EA with ICT/SMC Analysis"
#property description "Implements Order Blocks, FVG, Liquidity Detection"
#property description "Advanced Risk Management & Performance Analytics"

// Includes dos módulos desenvolvidos
#include "Source/Core/DataStructures.mqh"
#include "Source/Core/Interfaces.mqh"
#include "Source/Core/Logger.mqh"
#include "Source/Core/ConfigManager.mqh"
#include "Source/Core/CacheManager.mqh"
#include "Source/Core/PerformanceAnalyzer.mqh"
#include "Source/Strategies/ICT/OrderBlockDetector.mqh"
#include "Source/Strategies/ICT/FVGDetector.mqh"
#include "Source/Strategies/ICT/LiquidityDetector.mqh"
#include "Source/Strategies/ICT/MarketStructureAnalyzer.mqh"

// Includes das novas classes de melhorias
#include "Source/Core/AdvancedClasses.mqh"

// Includes padrão MQL5
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Enumerações                                                      |
//+------------------------------------------------------------------+
// Enumerações definidas em DataStructures.mqh

//+------------------------------------------------------------------+
//| Parâmetros de entrada do EA                                      |
//+------------------------------------------------------------------+

// === CONFIGURAÇÕES GERAIS ===
input group "=== CONFIGURAÇÕES GERAIS ==="
input string EA_Comment = "FTMO_Scalper_Elite_v2.12";  // Comentário das ordens
input int Magic_Number = 20241201;                      // Número mágico
input bool Enable_Logging = true;                       // Habilitar logging
input ENUM_LOG_LEVEL Log_Level = LOG_INFO;              // Nível de log

// === GESTÃO DE RISCO FTMO ===
input group "=== GESTÃO DE RISCO FTMO ==="
input double Max_Risk_Per_Trade = 1.0;                  // Risco máximo por trade (%)
input double Daily_Loss_Limit = 5.0;                    // Limite de perda diária (%)
input double Max_Drawdown_Limit = 10.0;                 // Limite de drawdown máximo (%)
input double Account_Risk_Limit = 2.0;                  // Risco total da conta (%)
input bool Enable_News_Filter = true;                   // Filtro de notícias
input int News_Minutes_Before = 30;                     // Minutos antes da notícia
input int News_Minutes_After = 30;                      // Minutos após a notícia

// === CONFIGURAÇÕES ICT/SMC ===
input group "=== CONFIGURAÇÕES ICT/SMC ==="
input bool Enable_Order_Blocks = true;                  // Habilitar Order Blocks
input bool Enable_FVG = true;                          // Habilitar Fair Value Gaps
input bool Enable_Liquidity = true;                    // Habilitar Liquidity Detection
input bool Enable_Market_Structure = true;             // Habilitar Market Structure
input int ICT_Lookback_Candles = 100;                  // Candles para análise ICT
input double Min_Order_Block_Size = 10.0;              // Tamanho mínimo Order Block (pontos)
input double Min_FVG_Size = 5.0;                       // Tamanho mínimo FVG (pontos)

// === CONFIGURAÇÕES DE ENTRADA ===
input group "=== CONFIGURAÇÕES DE ENTRADA ==="
input double Lot_Size = 0.01;                          // Tamanho de lote
input bool Use_Auto_Lot = true;                        // Usar cálculo automático de lote
input int Stop_Loss_Points = 100;                      // Stop Loss em pontos
input int Take_Profit_Points = 150;                    // Take Profit em pontos
input bool Use_Trailing_Stop = true;                   // Usar trailing stop
input int Trailing_Stop_Points = 50;                   // Trailing stop em pontos
input int Trailing_Step_Points = 10;                   // Passo de trailing stop

// === SISTEMA DE CONFLUÊNCIA ===
input group "=== SISTEMA DE CONFLUÊNCIA ==="
input bool Enable_Confluence_System = true;            // Habilitar sistema de confluência
input double Min_Confluence_Score = 70.0;              // Pontuação mínima para entrada
input double OB_Weight = 25.0;                         // Peso Order Block (%)
input double FVG_Weight = 20.0;                        // Peso FVG (%)
input double Liquidity_Weight = 20.0;                  // Peso Liquidez (%)
input double Structure_Weight = 15.0;                  // Peso Estrutura (%)
input double Momentum_Weight = 10.0;                   // Peso Momentum (%)
input double Volume_Weight = 10.0;                     // Peso Volume (%)

// === SL/TP DINÂMICO ===
input group "=== SL/TP DINÂMICO ==="
input bool Enable_Dynamic_SLTP = true;                 // Habilitar SL/TP dinâmico
input ENUM_SL_CALCULATION_METHOD SL_Method = SL_HYBRID; // Método de cálculo SL
input ENUM_TP_CALCULATION_METHOD TP_Method = TP_STRUCTURE; // Método de cálculo TP
input double ATR_Multiplier_SL = 1.5;                  // Multiplicador ATR para SL
input double ATR_Multiplier_TP = 2.5;                  // Multiplicador ATR para TP
input double Risk_Reward_Ratio = 2.0;                  // Ratio Risco/Recompensa
input bool Allow_Manual_Override = true;               // Permitir sobrescrita manual

// === FILTROS AVANÇADOS ===
input group "=== FILTROS AVANÇADOS ==="
input bool Enable_Advanced_Filters = true;             // Habilitar filtros avançados
input double RSI_Oversold = 30.0;                      // RSI oversold
input double RSI_Overbought = 70.0;                    // RSI overbought
input double Volume_Threshold = 1.5;                   // Threshold volume relativo
input int EMA_Fast_Period = 21;                        // Período EMA rápida
input int EMA_Slow_Period = 50;                        // Período EMA lenta
input double ATR_Volatility_Threshold = 1.2;           // Threshold volatilidade ATR

// === FILTROS DE TEMPO ===
input group "=== FILTROS DE TEMPO ==="
input bool Enable_Time_Filter = true;                  // Habilitar filtro de tempo
input int Start_Hour = 8;                              // Hora de início (servidor)
input int End_Hour = 18;                               // Hora de fim (servidor)
input bool Trade_Monday = true;                        // Negociar segunda-feira
input bool Trade_Tuesday = true;                       // Negociar terça-feira
input bool Trade_Wednesday = true;                     // Negociar quarta-feira
input bool Trade_Thursday = true;                      // Negociar quinta-feira
input bool Trade_Friday = true;                        // Negociar sexta-feira

// === TRAILING STOP INTELIGENTE ===
input group "=== TRAILING STOP INTELIGENTE ==="
input bool Enable_Smart_Trailing = true;               // Habilitar trailing stop inteligente
input ENUM_TRAILING_METHOD Trailing_Method = TRAILING_STRUCTURE_BREAKS; // Método de trailing
input double Structure_Buffer_Points = 5.0;            // Buffer para estruturas (pontos)
input bool Use_OrderBlock_Levels = true;               // Usar níveis de Order Blocks
input bool Use_FVG_Levels = true;                      // Usar níveis de FVG
input bool Use_Liquidity_Levels = true;                // Usar níveis de liquidez
input double ATR_Trailing_Multiplier = 1.5;            // Multiplicador ATR para trailing
input int Trailing_Lookback_Bars = 20;                 // Barras para análise de estrutura

// === CONFIGURAÇÕES AVANÇADAS ===
input group "=== CONFIGURAÇÕES AVANÇADAS ==="
input int Max_Positions = 3;                           // Máximo de posições simultâneas
input double Min_Spread_Points = 20.0;                 // Spread máximo permitido
input bool Enable_Performance_Analytics = true;        // Habilitar análise de performance
input bool Enable_Cache = true;                        // Habilitar cache
input int Cache_Timeout_Seconds = 300;                 // Timeout de cache (segundos)

//+------------------------------------------------------------------+
//| Variáveis globais                                                |
//+------------------------------------------------------------------+

// Objetos de trading
CTrade trade;
CSymbolInfo symbol_info;
CPositionInfo position_info;
CAccountInfo account_info;

// Detectores ICT/SMC
COrderBlockDetector order_block_detector;
CFVGDetector fvg_detector;
CLiquidityDetector liquidity_detector;
CMarketStructureAnalyzer market_structure_analyzer;

// Gestores de sistema
CConfigManager config_manager;
CCacheManager cache_manager;
CPerformanceAnalyzer performance_analyzer;

// Novas classes de melhorias
CSignalConfluence signal_confluence;
CDynamicLevels dynamic_levels;
CAdvancedFilters advanced_filters;

// Variáveis de controle
datetime last_bar_time = 0;
bool ea_initialized = false;
double daily_start_balance = 0.0;
datetime daily_start_time = 0;
int total_positions_today = 0;
double daily_profit_loss = 0.0;
bool trading_allowed = true;

// Handles de indicadores
int atr_handle = INVALID_HANDLE;

// Estatísticas
struct SEAStatistics
{
   int total_trades;
   int winning_trades;
   int losing_trades;
   double total_profit;
   double total_loss;
   double max_profit;
   double max_loss;
   double win_rate;
   double profit_factor;
   double sharpe_ratio;
   datetime last_trade_time;
};

SEAStatistics ea_stats;

//+------------------------------------------------------------------+
//| Função de inicialização do Expert Advisor                       |
//+------------------------------------------------------------------+
int OnInit()
{
   // Inicializar logger
   if(g_logger == NULL)
   {
      g_logger = new CLogger();
   }
   
   // Configurar logging
   if(Enable_Logging)
   {
      g_logger.SetLogLevel(Log_Level);
      g_logger.Info("=== INICIANDO EA FTMO SCALPER ELITE v2.10 ===");
   }
   
   // Validar parâmetros de entrada
   if(!ValidateInputParameters())
   {
      if(g_logger != NULL) g_logger.Error("Parâmetros de entrada inválidos");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Inicializar símbolo
   if(!symbol_info.Name(_Symbol))
   {
      if(g_logger != NULL) g_logger.Error("Erro ao inicializar informações do símbolo");
      return INIT_FAILED;
   }
   
   // Configurar objeto de trade
   trade.SetExpertMagicNumber(Magic_Number);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(_Symbol);
   
   // Inicializar gestores
   if(!InitializeManagers())
   {
      if(g_logger != NULL) g_logger.Error("Erro ao inicializar gestores");
      return INIT_FAILED;
   }
   
   // Inicializar detectores ICT/SMC
   if(!InitializeDetectors())
   {
      if(g_logger != NULL) g_logger.Error("Erro ao inicializar detectores ICT/SMC");
      return INIT_FAILED;
   }
   
   // Inicializar indicadores
   atr_handle = iATR(_Symbol, _Period, 14);
   if(atr_handle == INVALID_HANDLE)
   {
      if(g_logger != NULL) g_logger.Error("Erro ao inicializar indicador ATR");
      return INIT_FAILED;
   }
   
   // Inicializar sistemas avançados
   if(!InitializeAdvancedSystems())
   {
      if(g_logger != NULL) g_logger.Error("Erro ao inicializar sistemas avançados");
      return INIT_FAILED;
   }
   
   // Inicializar estatísticas
   InitializeStatistics();
   
   // Configurar timer para análise periódica
   EventSetTimer(60); // Timer a cada minuto
   
   // Marcar como inicializado
   ea_initialized = true;
   daily_start_balance = account_info.Balance();
   daily_start_time = TimeCurrent();
   
   if(g_logger != NULL)
   {
      g_logger.Info("EA inicializado com sucesso");
      g_logger.Info("Símbolo: " + _Symbol + ", Timeframe: " + EnumToString(_Period));
      g_logger.Info("Saldo inicial: " + DoubleToString(daily_start_balance, 2));
   }
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Função de deinicialização                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Parar timer
   EventKillTimer();
   
   // Salvar estatísticas
   if(Enable_Performance_Analytics)
   {
      performance_analyzer.SaveReport("FTMO_Scalper_Elite_Report.html");
   }
   
   // Log de encerramento
   if(g_logger != NULL)
   {
      g_logger.Info("=== EA FTMO SCALPER ELITE FINALIZADO ===");
      g_logger.Info("Razão: " + GetDeinitReasonText(reason));
      g_logger.Info("Trades totais: " + IntegerToString(ea_stats.total_trades));
      g_logger.Info("Win Rate: " + DoubleToString(ea_stats.win_rate, 2) + "%");
      g_logger.Info("Profit Factor: " + DoubleToString(ea_stats.profit_factor, 2));
   }
   
   // Deinicializar componentes
   order_block_detector.Deinit();
   fvg_detector.Deinit();
   liquidity_detector.Deinit();
   market_structure_analyzer.Deinit();
   performance_analyzer.Deinit();
   
   // Liberar handles de indicadores
   if(atr_handle != INVALID_HANDLE)
   {
      IndicatorRelease(atr_handle);
      atr_handle = INVALID_HANDLE;
   }
   
   ea_initialized = false;
   
   // Liberar logger
   if(g_logger != NULL)
   {
      delete g_logger;
      g_logger = NULL;
   }
}

//+------------------------------------------------------------------+
//| Função principal - executada a cada tick                        |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!ea_initialized)
      return;
   
   // Verificar se é um novo bar
   datetime current_bar_time = iTime(_Symbol, _Period, 0);
   bool new_bar = (current_bar_time != last_bar_time);
   
   if(new_bar)
   {
      last_bar_time = current_bar_time;
      
      // Análise principal em novos bars
      PerformMainAnalysis();
   }
   
   // Gestão de posições abertas (a cada tick)
   ManageOpenPositions();
   
   // Verificar limites de risco
   CheckRiskLimits();
   
   // Atualizar estatísticas
   UpdateStatistics();
}

//+------------------------------------------------------------------+
//| Função do timer - executada periodicamente                      |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(!ea_initialized)
      return;
   
   // Verificar se é um novo dia
   CheckNewDay();
   
   // Atualizar análise de performance
   if(Enable_Performance_Analytics)
   {
      performance_analyzer.UpdateMetrics();
   }
   
   // Limpar cache antigo
   if(Enable_Cache)
   {
      cache_manager.CleanupExpired();
   }
   
   // Log periódico de status
   LogPeriodicStatus();
}

//+------------------------------------------------------------------+
//| Validar parâmetros de entrada                                    |
//+------------------------------------------------------------------+
bool ValidateInputParameters()
{
   // Validar risco
   if(Max_Risk_Per_Trade <= 0 || Max_Risk_Per_Trade > 10)
   {
      g_logger.Error("Max_Risk_Per_Trade deve estar entre 0.1 e 10");
      return false;
   }
   
   if(Daily_Loss_Limit <= 0 || Daily_Loss_Limit > 20)
   {
      g_logger.Error("Daily_Loss_Limit deve estar entre 0.1 e 20");
      return false;
   }
   
   // Validar lote
   if(Lot_Size <= 0)
   {
      g_logger.Error("Lot_Size deve ser maior que 0");
      return false;
   }
   
   // Validar stops
   if(Stop_Loss_Points <= 0 || Take_Profit_Points <= 0)
   {
      g_logger.Error("Stop Loss e Take Profit devem ser maiores que 0");
      return false;
   }
   
   // Validar horários
   if(Start_Hour < 0 || Start_Hour > 23 || End_Hour < 0 || End_Hour > 23)
   {
      g_logger.Error("Horários devem estar entre 0 e 23");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Inicializar gestores                                             |
//+------------------------------------------------------------------+
bool InitializeManagers()
{
   // Inicializar config manager
   if(!config_manager.Init())
   {
      g_logger.Error("Erro ao inicializar ConfigManager");
      return false;
   }
   
   // Inicializar cache manager
   if(Enable_Cache)
   {
      if(!cache_manager.Init(Cache_Timeout_Seconds))
      {
         g_logger.Error("Erro ao inicializar CacheManager");
         return false;
      }
   }
   
   // Inicializar performance analyzer
   if(Enable_Performance_Analytics)
   {
      if(!performance_analyzer.Init(_Symbol, _Period))
      {
         g_logger.Error("Erro ao inicializar PerformanceAnalyzer");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Inicializar detectores ICT/SMC                                   |
//+------------------------------------------------------------------+
bool InitializeDetectors()
{
   // Order Block Detector
   if(Enable_Order_Blocks)
   {
      if(!order_block_detector.Init(_Symbol, _Period))
      {
         g_logger.Error("Erro ao inicializar OrderBlockDetector");
         return false;
      }
      order_block_detector.SetMinBlockSize(Min_Order_Block_Size);
      order_block_detector.SetLookbackCandles(ICT_Lookback_Candles);
   }
   
   // FVG Detector
   if(Enable_FVG)
   {
      if(!fvg_detector.Init(_Symbol, _Period))
      {
         g_logger.Error("Erro ao inicializar FVGDetector");
         return false;
      }
      fvg_detector.SetMinGapSize(Min_FVG_Size);
      fvg_detector.SetLookbackCandles(ICT_Lookback_Candles);
   }
   
   // Liquidity Detector
   if(Enable_Liquidity)
   {
      if(!liquidity_detector.Init(_Symbol, _Period))
      {
         g_logger.Error("Erro ao inicializar LiquidityDetector");
         return false;
      }
      liquidity_detector.SetLookbackCandles(ICT_Lookback_Candles);
   }
   
   // Market Structure Analyzer
   if(Enable_Market_Structure)
   {
      if(!market_structure_analyzer.Init(_Symbol, _Period))
      {
         g_logger.Error("Erro ao inicializar MarketStructureAnalyzer");
         return false;
      }
      market_structure_analyzer.SetLookbackCandles(ICT_Lookback_Candles);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Inicializar estatísticas                                         |
//+------------------------------------------------------------------+
void InitializeStatistics()
{
   ea_stats.total_trades = 0;
   ea_stats.winning_trades = 0;
   ea_stats.losing_trades = 0;
   ea_stats.total_profit = 0.0;
   ea_stats.total_loss = 0.0;
   ea_stats.max_profit = 0.0;
   ea_stats.max_loss = 0.0;
   ea_stats.win_rate = 0.0;
   ea_stats.profit_factor = 0.0;
   ea_stats.sharpe_ratio = 0.0;
   ea_stats.last_trade_time = 0;
}

//+------------------------------------------------------------------+
//| Análise principal                                                |
//+------------------------------------------------------------------+
void PerformMainAnalysis()
{
   // Verificar se trading está permitido
   if(!IsTradingAllowed())
      return;
   
   // Atualizar detectores ICT/SMC
   UpdateDetectors();
   
   // Procurar sinais de entrada
   SearchForEntrySignals();
}

//+------------------------------------------------------------------+
//| Verificar se trading está permitido                              |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
   // Verificar se trading está globalmente permitido
   if(!trading_allowed)
      return false;
   
   // Verificar filtro de tempo
   if(Enable_Time_Filter && !IsTimeToTrade())
      return false;
   
   // Verificar filtro de notícias
   if(Enable_News_Filter && IsNewsTime())
      return false;
   
   // Verificar spread
   double current_spread = symbol_info.Spread() * symbol_info.Point();
   if(current_spread > Min_Spread_Points * symbol_info.Point())
   {
      g_logger.Debug("Spread muito alto: " + DoubleToString(current_spread / symbol_info.Point(), 1));
      return false;
   }
   
   // Verificar máximo de posições
   if(GetOpenPositionsCount() >= Max_Positions)
   {
      g_logger.Debug("Máximo de posições atingido: " + IntegerToString(Max_Positions));
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar se é hora de negociar                                  |
//+------------------------------------------------------------------+
bool IsTimeToTrade()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Verificar dia da semana
   switch(dt.day_of_week)
   {
      case 1: if(!Trade_Monday) return false; break;
      case 2: if(!Trade_Tuesday) return false; break;
      case 3: if(!Trade_Wednesday) return false; break;
      case 4: if(!Trade_Thursday) return false; break;
      case 5: if(!Trade_Friday) return false; break;
      default: return false; // Fim de semana
   }
   
   // Verificar horário
   if(Start_Hour <= End_Hour)
   {
      return (dt.hour >= Start_Hour && dt.hour < End_Hour);
   }
   else
   {
      return (dt.hour >= Start_Hour || dt.hour < End_Hour);
   }
}

//+------------------------------------------------------------------+
//| Verificar se é hora de notícias                                  |
//+------------------------------------------------------------------+
bool IsNewsTime()
{
   // Implementação simplificada - pode ser expandida com calendário econômico
   // Por enquanto, evitar trading nas primeiras horas do dia
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Evitar primeiras 2 horas do dia de trading
   if(dt.hour >= 0 && dt.hour < 2)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Atualizar detectores                                             |
//+------------------------------------------------------------------+
void UpdateDetectors()
{
   // Atualizar Order Blocks
   if(Enable_Order_Blocks)
   {
      order_block_detector.ScanForOrderBlocks();
   }
   
   // Atualizar FVGs
   if(Enable_FVG)
   {
      fvg_detector.ScanForFVGs();
   }
   
   // Atualizar Liquidity
   if(Enable_Liquidity)
   {
      liquidity_detector.ScanForLiquidity();
   }
   
   // Atualizar Market Structure
   if(Enable_Market_Structure)
   {
      market_structure_analyzer.AnalyzeMarketStructure();
   }
}

//+------------------------------------------------------------------+
//| Procurar sinais de entrada                                       |
//+------------------------------------------------------------------+
void SearchForEntrySignals()
{
   // Analisar sinais de compra
   if(AnalyzeBuySignals())
   {
      ExecuteBuyOrder();
   }
   
   // Analisar sinais de venda
   if(AnalyzeSellSignals())
   {
      ExecuteSellOrder();
   }
}

//+------------------------------------------------------------------+
//| Analisar sinais de compra                                        |
//+------------------------------------------------------------------+
bool AnalyzeBuySignals()
{
   // Se sistema de confluência estiver habilitado, usar nova lógica
   if(Enable_Confluence_System)
   {
      return AnalyzeBuySignalsWithConfluence();
   }
   
   // Lógica original (fallback)
   bool signal = false;
   
   // Verificar Order Blocks bullish
   if(Enable_Order_Blocks)
   {
      SOrderBlock latest_ob = order_block_detector.GetLatestOrderBlock();
      if(latest_ob.type == ORDER_BLOCK_BULLISH && latest_ob.is_valid)
      {
         double current_price = symbol_info.Bid();
         if(current_price >= latest_ob.low && current_price <= latest_ob.high)
         {
            signal = true;
            g_logger.Debug("Sinal de compra: Order Block Bullish");
         }
      }
   }
   
   // Verificar FVG bullish
   if(Enable_FVG && !signal)
   {
      SFVG latest_fvg = fvg_detector.GetLatestFVG();
      if(latest_fvg.type == FVG_BULLISH && latest_fvg.is_valid)
      {
         double current_price = symbol_info.Bid();
         if(current_price >= latest_fvg.low && current_price <= latest_fvg.high)
         {
            signal = true;
            g_logger.Debug("Sinal de compra: FVG Bullish");
         }
      }
   }
   
   // Verificar Market Structure bullish
   if(Enable_Market_Structure && signal)
   {
      SMarketStructure latest_structure = market_structure_analyzer.GetLatestStructure();
      if(latest_structure.type == STRUCTURE_BOS_BULLISH)
      {
         g_logger.Debug("Confirmação: BOS Bullish");
      }
      else
      {
         signal = false; // Cancelar sinal se estrutura não confirma
      }
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| Analisar sinais de compra com sistema de confluência             |
//+------------------------------------------------------------------+
bool AnalyzeBuySignalsWithConfluence()
{
   // Configurar pesos do sistema de confluência
   signal_confluence.SetWeights(OB_Weight, FVG_Weight, Liquidity_Weight, 
                               Structure_Weight, Momentum_Weight, Volume_Weight);
   
   // Configurar filtros avançados se habilitados
   if(Enable_Advanced_Filters)
   {
      advanced_filters.SetRSILevels(RSI_Oversold, RSI_Overbought);
      advanced_filters.SetVolumeThreshold(Volume_Threshold);
      advanced_filters.SetEMAPeriods(EMA_Fast_Period, EMA_Slow_Period);
      advanced_filters.SetATRThreshold(ATR_Volatility_Threshold);
   }
   
   // Calcular pontuação de confluência para compra
   double confluence_score = signal_confluence.CalculateBuyScore(
      order_block_detector, fvg_detector, liquidity_detector, 
      market_structure_analyzer, advanced_filters, Enable_Advanced_Filters);
   
   // Log da pontuação
   g_logger.Debug("Pontuação confluência COMPRA: " + DoubleToString(confluence_score, 2));
   
   // Verificar se atende ao critério mínimo
   if(confluence_score >= Min_Confluence_Score)
   {
      g_logger.Info("SINAL DE COMPRA confirmado - Score: " + DoubleToString(confluence_score, 2));
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Analisar sinais de venda                                         |
//+------------------------------------------------------------------+
bool AnalyzeSellSignals()
{
   // Se sistema de confluência estiver habilitado, usar nova lógica
   if(Enable_Confluence_System)
   {
      return AnalyzeSellSignalsWithConfluence();
   }
   
   // Lógica original (fallback)
   bool signal = false;
   
   // Verificar Order Blocks bearish
   if(Enable_Order_Blocks)
   {
      SOrderBlock latest_ob = order_block_detector.GetLatestOrderBlock();
      if(latest_ob.type == ORDER_BLOCK_BEARISH && latest_ob.is_valid)
      {
         double current_price = symbol_info.Ask();
         if(current_price >= latest_ob.low && current_price <= latest_ob.high)
         {
            signal = true;
            g_logger.Debug("Sinal de venda: Order Block Bearish");
         }
      }
   }
   
   // Verificar FVG bearish
   if(Enable_FVG && !signal)
   {
      SFVG latest_fvg = fvg_detector.GetLatestFVG();
      if(latest_fvg.type == FVG_BEARISH && latest_fvg.is_valid)
      {
         double current_price = symbol_info.Ask();
         if(current_price >= latest_fvg.low && current_price <= latest_fvg.high)
         {
            signal = true;
            g_logger.Debug("Sinal de venda: FVG Bearish");
         }
      }
   }
   
   // Verificar Market Structure bearish
   if(Enable_Market_Structure && signal)
   {
      SMarketStructure latest_structure = market_structure_analyzer.GetLatestStructure();
      if(latest_structure.type == STRUCTURE_BOS_BEARISH)
      {
         g_logger.Debug("Confirmação: BOS Bearish");
      }
      else
      {
         signal = false; // Cancelar sinal se estrutura não confirma
      }
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| Analisar sinais de venda com sistema de confluência              |
//+------------------------------------------------------------------+
bool AnalyzeSellSignalsWithConfluence()
{
   // Configurar pesos do sistema de confluência
   signal_confluence.SetWeights(OB_Weight, FVG_Weight, Liquidity_Weight, 
                               Structure_Weight, Momentum_Weight, Volume_Weight);
   
   // Configurar filtros avançados se habilitados
   if(Enable_Advanced_Filters)
   {
      advanced_filters.SetRSILevels(RSI_Oversold, RSI_Overbought);
      advanced_filters.SetVolumeThreshold(Volume_Threshold);
      advanced_filters.SetEMAPeriods(EMA_Fast_Period, EMA_Slow_Period);
      advanced_filters.SetATRThreshold(ATR_Volatility_Threshold);
   }
   
   // Calcular pontuação de confluência para venda
   double confluence_score = signal_confluence.CalculateSellScore(
      order_block_detector, fvg_detector, liquidity_detector, 
      market_structure_analyzer, advanced_filters, Enable_Advanced_Filters);
   
   // Log da pontuação
   g_logger.Debug("Pontuação confluência VENDA: " + DoubleToString(confluence_score, 2));
   
   // Verificar se atende ao critério mínimo
   if(confluence_score >= Min_Confluence_Score)
   {
      g_logger.Info("SINAL DE VENDA confirmado - Score: " + DoubleToString(confluence_score, 2));
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Executar ordem de compra                                         |
//+------------------------------------------------------------------+
void ExecuteBuyOrder()
{
   double lot_size = CalculateLotSize();
   double entry_price = symbol_info.Ask();
   double stop_loss, take_profit;
   
   // Calcular SL/TP dinâmico se habilitado
   if(Enable_Dynamic_SLTP && !Allow_Manual_Override)
   {
      // Configurar parâmetros do sistema dinâmico
      dynamic_levels.SetATRMultipliers(ATR_Multiplier_SL, ATR_Multiplier_TP);
      dynamic_levels.SetRiskRewardRatio(Risk_Reward_Ratio);
      
      // Calcular níveis dinâmicos
      stop_loss = dynamic_levels.CalculateDynamicSL(ORDER_TYPE_BUY, entry_price, SL_Method);
      take_profit = dynamic_levels.CalculateDynamicTP(ORDER_TYPE_BUY, entry_price, stop_loss, TP_Method);
      
      g_logger.Debug("SL/TP Dinâmico - SL: " + DoubleToString(stop_loss, symbol_info.Digits()) + 
                    ", TP: " + DoubleToString(take_profit, symbol_info.Digits()));
   }
   else
   {
      // Usar valores fixos (lógica original)
      stop_loss = entry_price - Stop_Loss_Points * symbol_info.Point();
      take_profit = entry_price + Take_Profit_Points * symbol_info.Point();
      
      g_logger.Debug("SL/TP Fixo - SL: " + DoubleToString(stop_loss, symbol_info.Digits()) + 
                    ", TP: " + DoubleToString(take_profit, symbol_info.Digits()));
   }
   
   // Normalizar preços
   stop_loss = NormalizeDouble(stop_loss, symbol_info.Digits());
   take_profit = NormalizeDouble(take_profit, symbol_info.Digits());
   
   // Validar níveis
   if(!ValidateSLTPLevels(ORDER_TYPE_BUY, entry_price, stop_loss, take_profit))
   {
      g_logger.Error("Níveis de SL/TP inválidos para ordem de COMPRA");
      return;
   }
   
   // Executar ordem
   if(trade.Buy(lot_size, _Symbol, entry_price, stop_loss, take_profit, EA_Comment))
   {
      g_logger.Info("Ordem de COMPRA executada - Lote: " + DoubleToString(lot_size, 2) + 
                   ", Preço: " + DoubleToString(entry_price, symbol_info.Digits()) +
                   ", SL: " + DoubleToString(stop_loss, symbol_info.Digits()) +
                   ", TP: " + DoubleToString(take_profit, symbol_info.Digits()));
      
      // Atualizar estatísticas
      ea_stats.total_trades++;
      ea_stats.last_trade_time = TimeCurrent();
      
      // Registrar no performance analyzer
      if(Enable_Performance_Analytics)
      {
         performance_analyzer.RecordTrade(ORDER_TYPE_BUY, lot_size, entry_price, stop_loss, take_profit);
      }
   }
   else
   {
      g_logger.Error("Erro ao executar ordem de COMPRA: " + IntegerToString(trade.ResultRetcode()) + 
                    " - " + trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Executar ordem de venda                                          |
//+------------------------------------------------------------------+
void ExecuteSellOrder()
{
   double lot_size = CalculateLotSize();
   double entry_price = symbol_info.Bid();
   double stop_loss, take_profit;
   
   // Calcular SL/TP dinâmico se habilitado
   if(Enable_Dynamic_SLTP && !Allow_Manual_Override)
   {
      // Configurar parâmetros do sistema dinâmico
      dynamic_levels.SetATRMultipliers(ATR_Multiplier_SL, ATR_Multiplier_TP);
      dynamic_levels.SetRiskRewardRatio(Risk_Reward_Ratio);
      
      // Calcular níveis dinâmicos
      stop_loss = dynamic_levels.CalculateDynamicSL(ORDER_TYPE_SELL, entry_price, SL_Method);
      take_profit = dynamic_levels.CalculateDynamicTP(ORDER_TYPE_SELL, entry_price, stop_loss, TP_Method);
      
      g_logger.Debug("SL/TP Dinâmico - SL: " + DoubleToString(stop_loss, symbol_info.Digits()) + 
                    ", TP: " + DoubleToString(take_profit, symbol_info.Digits()));
   }
   else
   {
      // Usar valores fixos (lógica original)
      stop_loss = entry_price + Stop_Loss_Points * symbol_info.Point();
      take_profit = entry_price - Take_Profit_Points * symbol_info.Point();
      
      g_logger.Debug("SL/TP Fixo - SL: " + DoubleToString(stop_loss, symbol_info.Digits()) + 
                    ", TP: " + DoubleToString(take_profit, symbol_info.Digits()));
   }
   
   // Normalizar preços
   stop_loss = NormalizeDouble(stop_loss, symbol_info.Digits());
   take_profit = NormalizeDouble(take_profit, symbol_info.Digits());
   
   // Validar níveis
   if(!ValidateSLTPLevels(ORDER_TYPE_SELL, entry_price, stop_loss, take_profit))
   {
      g_logger.Error("Níveis de SL/TP inválidos para ordem de VENDA");
      return;
   }
   
   // Executar ordem
   if(trade.Sell(lot_size, _Symbol, entry_price, stop_loss, take_profit, EA_Comment))
   {
      g_logger.Info("Ordem de VENDA executada - Lote: " + DoubleToString(lot_size, 2) + 
                   ", Preço: " + DoubleToString(entry_price, symbol_info.Digits()) +
                   ", SL: " + DoubleToString(stop_loss, symbol_info.Digits()) +
                   ", TP: " + DoubleToString(take_profit, symbol_info.Digits()));
      
      // Atualizar estatísticas
      ea_stats.total_trades++;
      ea_stats.last_trade_time = TimeCurrent();
      
      // Registrar no performance analyzer
      if(Enable_Performance_Analytics)
      {
         performance_analyzer.RecordTrade(ORDER_TYPE_SELL, lot_size, entry_price, stop_loss, take_profit);
      }
   }
   else
   {
      g_logger.Error("Erro ao executar ordem de VENDA: " + IntegerToString(trade.ResultRetcode()) + 
                    " - " + trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Calcular tamanho do lote                                         |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   if(!Use_Auto_Lot)
      return Lot_Size;
   
   // Cálculo automático baseado no risco
   double account_balance = account_info.Balance();
   double risk_amount = account_balance * Max_Risk_Per_Trade / 100.0;
   double stop_loss_points = Stop_Loss_Points;
   double point_value = symbol_info.TickValue();
   
   double calculated_lot = risk_amount / (stop_loss_points * point_value);
   
   // Normalizar para o tamanho mínimo/máximo permitido
   double min_lot = symbol_info.LotsMin();
   double max_lot = symbol_info.LotsMax();
   double lot_step = symbol_info.LotsStep();
   
   calculated_lot = MathMax(min_lot, MathMin(max_lot, calculated_lot));
   calculated_lot = NormalizeDouble(calculated_lot / lot_step, 0) * lot_step;
   
   return calculated_lot;
}

//+------------------------------------------------------------------+
//| Gerenciar posições abertas                                       |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(position_info.SelectByIndex(i))
      {
         if(position_info.Symbol() == _Symbol && position_info.Magic() == Magic_Number)
         {
            // Aplicar trailing stop se habilitado
            if(Use_Trailing_Stop)
            {
               ApplyTrailingStop();
            }
            
            // Verificar outras condições de saída
            CheckExitConditions();
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Aplicar trailing stop inteligente                                |
//+------------------------------------------------------------------+
void ApplyTrailingStop()
{
   if(!Enable_Smart_Trailing) 
   {
      ApplyFixedTrailingStop();
      return;
   }
   
   double new_sl = 0.0;
   bool should_update = false;
   
   // Calcular novo SL baseado no método selecionado
   switch(Smart_Trailing_Method)
   {
      case TRAILING_FIXED_POINTS:
         new_sl = CalculateFixedTrailingSL();
         break;
         
      case TRAILING_ORDER_BLOCKS:
         new_sl = CalculateOrderBlockTrailingSL();
         break;
         
      case TRAILING_STRUCTURE_BREAKS:
         new_sl = CalculateStructureBreakTrailingSL();
         break;
         
      case TRAILING_FVG_LEVELS:
         new_sl = CalculateFVGTrailingSL();
         break;
         
      case TRAILING_LIQUIDITY_ZONES:
         new_sl = CalculateLiquidityTrailingSL();
         break;
         
      case TRAILING_ATR_DYNAMIC:
         new_sl = CalculateATRTrailingSL();
         break;
         
      default:
         new_sl = CalculateFixedTrailingSL();
         break;
   }
   
   // Validar e aplicar novo SL
   if(new_sl > 0 && ValidateTrailingSL(new_sl))
   {
      new_sl = NormalizeDouble(new_sl, symbol_info.Digits());
      
      if(trade.PositionModify(position_info.Ticket(), new_sl, position_info.TakeProfit()))
      {
         string method_name = EnumToString(Smart_Trailing_Method);
         g_logger.Info(StringFormat("Trailing Stop Inteligente aplicado [%s] - Novo SL: %.5f", 
                      method_name, new_sl));
      }
      else
      {
         g_logger.Error("Falha ao aplicar Trailing Stop: " + IntegerToString(GetLastError()));
      }
   }
}

//+------------------------------------------------------------------+
//| Aplicar trailing stop fixo (método tradicional)                  |
//+------------------------------------------------------------------+
void ApplyFixedTrailingStop()
{
   double current_price;
   double new_sl;
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      current_price = symbol_info.Bid();
      new_sl = current_price - Trailing_Stop_Points * symbol_info.Point();
      
      if(new_sl > position_info.StopLoss() + Trailing_Step_Points * symbol_info.Point())
      {
         new_sl = NormalizeDouble(new_sl, symbol_info.Digits());
         if(trade.PositionModify(position_info.Ticket(), new_sl, position_info.TakeProfit()))
         {
            g_logger.Debug("Trailing Stop fixo aplicado - Novo SL: " + DoubleToString(new_sl, symbol_info.Digits()));
         }
      }
   }
   else if(position_info.PositionType() == POSITION_TYPE_SELL)
   {
      current_price = symbol_info.Ask();
      new_sl = current_price + Trailing_Stop_Points * symbol_info.Point();
      
      if(new_sl < position_info.StopLoss() - Trailing_Step_Points * symbol_info.Point() || position_info.StopLoss() == 0)
      {
         new_sl = NormalizeDouble(new_sl, symbol_info.Digits());
         if(trade.PositionModify(position_info.Ticket(), new_sl, position_info.TakeProfit()))
         {
            g_logger.Debug("Trailing Stop fixo aplicado - Novo SL: " + DoubleToString(new_sl, symbol_info.Digits()));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Verificar condições de saída                                     |
//+------------------------------------------------------------------+
void CheckExitConditions()
{
   // Implementar lógica adicional de saída baseada em ICT/SMC
   // Por exemplo, sair se Order Block for invalidado
   
   // Esta função pode ser expandida com lógica mais sofisticada
}

//+------------------------------------------------------------------+
//| Verificar limites de risco                                       |
//+------------------------------------------------------------------+
void CheckRiskLimits()
{
   double current_balance = account_info.Balance();
   double current_equity = account_info.Equity();
   
   // Verificar perda diária
   double daily_loss = (daily_start_balance - current_balance) / daily_start_balance * 100.0;
   if(daily_loss >= Daily_Loss_Limit)
   {
      g_logger.Warning("Limite de perda diária atingido: " + DoubleToString(daily_loss, 2) + "%");
      CloseAllPositions("Limite de perda diária");
      trading_allowed = false;
   }
   
   // Verificar drawdown
   double drawdown = (current_balance - current_equity) / current_balance * 100.0;
   if(drawdown >= Max_Drawdown_Limit)
   {
      g_logger.Warning("Limite de drawdown atingido: " + DoubleToString(drawdown, 2) + "%");
      CloseAllPositions("Limite de drawdown");
      trading_allowed = false;
   }
}

//+------------------------------------------------------------------+
//| Fechar todas as posições                                         |
//+------------------------------------------------------------------+
void CloseAllPositions(const string reason)
{
   g_logger.Warning("Fechando todas as posições - Razão: " + reason);
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(position_info.SelectByIndex(i))
      {
         if(position_info.Symbol() == _Symbol && position_info.Magic() == Magic_Number)
         {
            trade.PositionClose(position_info.Ticket());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Obter número de posições abertas                                 |
//+------------------------------------------------------------------+
int GetOpenPositionsCount()
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(position_info.SelectByIndex(i))
      {
         if(position_info.Symbol() == _Symbol && position_info.Magic() == Magic_Number)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Verificar novo dia                                               |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   MqlDateTime current_dt, daily_dt;
   TimeToStruct(TimeCurrent(), current_dt);
   TimeToStruct(daily_start_time, daily_dt);
   
   if(current_dt.day != daily_dt.day)
   {
      // Novo dia - resetar contadores
      daily_start_balance = account_info.Balance();
      daily_start_time = TimeCurrent();
      total_positions_today = 0;
      daily_profit_loss = 0.0;
      trading_allowed = true;
      
      g_logger.Info("=== NOVO DIA DE TRADING ===");
      g_logger.Info("Saldo inicial: " + DoubleToString(daily_start_balance, 2));
   }
}

//+------------------------------------------------------------------+
//| Atualizar estatísticas                                           |
//+------------------------------------------------------------------+
void UpdateStatistics()
{
   // Calcular win rate
   if(ea_stats.total_trades > 0)
   {
      ea_stats.win_rate = (double)ea_stats.winning_trades / ea_stats.total_trades * 100.0;
   }
   
   // Calcular profit factor
   if(ea_stats.total_loss > 0)
   {
      ea_stats.profit_factor = ea_stats.total_profit / MathAbs(ea_stats.total_loss);
   }
}

//+------------------------------------------------------------------+
//| Log periódico de status                                          |
//+------------------------------------------------------------------+
void LogPeriodicStatus()
{
   static datetime last_status_time = 0;
   datetime current_time = TimeCurrent();
   
   // Log a cada 30 minutos
   if(current_time - last_status_time >= 1800)
   {
      last_status_time = current_time;
      
      g_logger.Info("=== STATUS PERIÓDICO ===");
      g_logger.Info("Posições abertas: " + IntegerToString(GetOpenPositionsCount()));
      g_logger.Info("Trades hoje: " + IntegerToString(ea_stats.total_trades));
      g_logger.Info("Win Rate: " + DoubleToString(ea_stats.win_rate, 2) + "%");
   }
}

//+------------------------------------------------------------------+
//| Validar níveis de SL/TP                                          |
//+------------------------------------------------------------------+
bool ValidateSLTPLevels(ENUM_ORDER_TYPE order_type, double entry_price, double stop_loss, double take_profit)
{
   double min_stop_level = symbol_info.StopsLevel() * symbol_info.Point();
   
   if(order_type == ORDER_TYPE_BUY)
   {
      // Para compra: SL deve estar abaixo do preço de entrada
      if(stop_loss >= entry_price)
      {
         g_logger.Error("SL inválido para BUY: SL >= Entry Price");
         return false;
      }
      
      // Verificar distância mínima
      if((entry_price - stop_loss) < min_stop_level)
      {
         g_logger.Error("SL muito próximo do Entry Price para BUY");
         return false;
      }
      
      // Para compra: TP deve estar acima do preço de entrada
      if(take_profit <= entry_price)
      {
         g_logger.Error("TP inválido para BUY: TP <= Entry Price");
         return false;
      }
      
      // Verificar distância mínima
      if((take_profit - entry_price) < min_stop_level)
      {
         g_logger.Error("TP muito próximo do Entry Price para BUY");
         return false;
      }
   }
   else if(order_type == ORDER_TYPE_SELL)
   {
      // Para venda: SL deve estar acima do preço de entrada
      if(stop_loss <= entry_price)
      {
         g_logger.Error("SL inválido para SELL: SL <= Entry Price");
         return false;
      }
      
      // Verificar distância mínima
      if((stop_loss - entry_price) < min_stop_level)
      {
         g_logger.Error("SL muito próximo do Entry Price para SELL");
         return false;
      }
      
      // Para venda: TP deve estar abaixo do preço de entrada
      if(take_profit >= entry_price)
      {
         g_logger.Error("TP inválido para SELL: TP >= Entry Price");
         return false;
      }
      
      // Verificar distância mínima
      if((entry_price - take_profit) < min_stop_level)
      {
         g_logger.Error("TP muito próximo do Entry Price para SELL");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Inicializar sistemas avançados                                   |
//+------------------------------------------------------------------+
bool InitializeAdvancedSystems()
{
   // Inicializar sistema de confluência
   if(Enable_Signal_Confluence)
   {
      if(!signal_confluence.Initialize())
      {
         g_logger.Error("Falha ao inicializar sistema de confluência");
         return false;
      }
      g_logger.Info("Sistema de confluência inicializado com sucesso");
   }
   
   // Inicializar níveis dinâmicos
   if(Enable_Dynamic_SLTP)
   {
      if(!dynamic_levels.Initialize(_Symbol, _Period))
      {
         g_logger.Error("Falha ao inicializar níveis dinâmicos");
         return false;
      }
      g_logger.Info("Sistema de níveis dinâmicos inicializado com sucesso");
   }
   
   // Inicializar filtros avançados
   if(Enable_Advanced_Filters)
   {
      if(!advanced_filters.Initialize(_Symbol, _Period))
      {
         g_logger.Error("Falha ao inicializar filtros avançados");
         return false;
      }
      g_logger.Info("Filtros avançados inicializados com sucesso");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calcular SL baseado em pontos fixos                              |
//+------------------------------------------------------------------+
double CalculateFixedTrailingSL()
{
   double current_price = (position_info.PositionType() == POSITION_TYPE_BUY) ? 
                         symbol_info.Bid() : symbol_info.Ask();
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      return current_price - Trailing_Stop_Points * symbol_info.Point();
   }
   else
   {
      return current_price + Trailing_Stop_Points * symbol_info.Point();
   }
}

//+------------------------------------------------------------------+
//| Calcular SL baseado em Order Blocks                              |
//+------------------------------------------------------------------+
double CalculateOrderBlockTrailingSL()
{
   if(!ict_detector.IsInitialized()) return 0.0;
   
   double ob_level = 0.0;
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      // Para posições de compra, buscar Order Block de suporte mais próximo
      if(Use_OrderBlock_Levels && ict_detector.GetNearestOrderBlock(POSITION_TYPE_BUY, ob_level))
      {
         return ob_level - (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   else
   {
      // Para posições de venda, buscar Order Block de resistência mais próximo
      if(Use_OrderBlock_Levels && ict_detector.GetNearestOrderBlock(POSITION_TYPE_SELL, ob_level))
      {
         return ob_level + (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   
   // Fallback para método fixo
   return CalculateFixedTrailingSL();
}

//+------------------------------------------------------------------+
//| Calcular SL baseado em quebras de estrutura                      |
//+------------------------------------------------------------------+
double CalculateStructureBreakTrailingSL()
{
   if(!smc_detector.IsInitialized()) return 0.0;
   
   double structure_level = 0.0;
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      // Para compras, buscar último swing low quebrado
      if(smc_detector.GetLastStructureBreak(POSITION_TYPE_BUY, structure_level))
      {
         return structure_level - (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   else
   {
      // Para vendas, buscar último swing high quebrado
      if(smc_detector.GetLastStructureBreak(POSITION_TYPE_SELL, structure_level))
      {
         return structure_level + (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   
   return CalculateFixedTrailingSL();
}

//+------------------------------------------------------------------+
//| Calcular SL baseado em níveis FVG                                |
//+------------------------------------------------------------------+
double CalculateFVGTrailingSL()
{
   if(!ict_detector.IsInitialized()) return 0.0;
   
   double fvg_level = 0.0;
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      // Para compras, buscar FVG de suporte
      if(Use_FVG_Levels && ict_detector.GetNearestFVG(POSITION_TYPE_BUY, fvg_level))
      {
         return fvg_level - (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   else
   {
      // Para vendas, buscar FVG de resistência
      if(Use_FVG_Levels && ict_detector.GetNearestFVG(POSITION_TYPE_SELL, fvg_level))
      {
         return fvg_level + (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   
   return CalculateFixedTrailingSL();
}

//+------------------------------------------------------------------+
//| Calcular SL baseado em zonas de liquidez                         |
//+------------------------------------------------------------------+
double CalculateLiquidityTrailingSL()
{
   if(!ict_detector.IsInitialized()) return 0.0;
   
   double liquidity_level = 0.0;
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      // Para compras, buscar zona de liquidez de suporte
      if(Use_Liquidity_Levels && ict_detector.GetNearestLiquidityZone(POSITION_TYPE_BUY, liquidity_level))
      {
         return liquidity_level - (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   else
   {
      // Para vendas, buscar zona de liquidez de resistência
      if(Use_Liquidity_Levels && ict_detector.GetNearestLiquidityZone(POSITION_TYPE_SELL, liquidity_level))
      {
         return liquidity_level + (Structure_Buffer_Points * symbol_info.Point());
      }
   }
   
   return CalculateFixedTrailingSL();
}

//+------------------------------------------------------------------+
//| Calcular SL baseado em ATR dinâmico                              |
//+------------------------------------------------------------------+
double CalculateATRTrailingSL()
{
   // Obter valor ATR atual
   double atr_values[];
   if(CopyBuffer(atr_handle, 0, 0, 1, atr_values) <= 0)
   {
      return CalculateFixedTrailingSL();
   }
   
   double atr_value = atr_values[0];
   double current_price = (position_info.PositionType() == POSITION_TYPE_BUY) ? 
                         symbol_info.Bid() : symbol_info.Ask();
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      return current_price - (atr_value * ATR_Multiplier);
   }
   else
   {
      return current_price + (atr_value * ATR_Multiplier);
   }
}

//+------------------------------------------------------------------+
//| Validar nível de trailing SL                                     |
//+------------------------------------------------------------------+
bool ValidateTrailingSL(double new_sl)
{
   if(new_sl <= 0) return false;
   
   double current_sl = position_info.StopLoss();
   double min_distance = symbol_info.StopsLevel() * symbol_info.Point();
   double current_price = (position_info.PositionType() == POSITION_TYPE_BUY) ? 
                         symbol_info.Bid() : symbol_info.Ask();
   
   if(position_info.PositionType() == POSITION_TYPE_BUY)
   {
      // Para compras, novo SL deve ser maior que o atual e respeitar distância mínima
      if(new_sl <= current_sl) return false;
      if(current_price - new_sl < min_distance) return false;
   }
   else
   {
      // Para vendas, novo SL deve ser menor que o atual e respeitar distância mínima
      if(current_sl > 0 && new_sl >= current_sl) return false;
      if(new_sl - current_price < min_distance) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter texto da razão de deinicialização                          |
//+------------------------------------------------------------------+
string GetDeinitReasonText(const int reason)
{
   switch(reason)
   {
      case REASON_PROGRAM: return "EA removido do gráfico";
      case REASON_REMOVE: return "EA deletado do gráfico";
      case REASON_RECOMPILE: return "EA recompilado";
      case REASON_CHARTCHANGE: return "Símbolo ou timeframe alterado";
      case REASON_CHARTCLOSE: return "Gráfico fechado";
      case REASON_PARAMETERS: return "Parâmetros alterados";
      case REASON_ACCOUNT: return "Conta alterada";
      case REASON_TEMPLATE: return "Template aplicado";
      case REASON_INITFAILED: return "Falha na inicialização";
      case REASON_CLOSE: return "Terminal fechado";
      default: return "Razão desconhecida";
   }
}

//+------------------------------------------------------------------+
//| Fim do Expert Advisor                                            |
//+------------------------------------------------------------------+