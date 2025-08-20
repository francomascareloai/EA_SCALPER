//+------------------------------------------------------------------+
//|                                        EA_FTMO_SCALPER_ELITE.mq5 |
//|                                  Copyright 2025, TradeDev_Master |
//|                                 Expert Advisor FTMO Compliant    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TradeDev_Master"
#property link      "https://github.com/tradedev-master"
#property version   "1.00"
#property description "EA FTMO Scalper Elite - Sistema de Trading Automatizado"
#property description "Otimizado para FTMO e Prop Firms - XAUUSD Scalping"
#property description "Sistemas Integrados: Risk Management + Confluence Entry + Intelligent Exit + Advanced Filters"

//--- Includes dos sistemas desenvolvidos
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//--- Includes dos módulos do projeto
#include "..\MQL5_Source\Source\Core\DataStructures.mqh"
#include "..\02_Source_Code\Risk_Management\RiskManager.mqh"
#include "..\02_Source_Code\Filters\AdvancedFilters.mqh"
#include "..\02_Source_Code\Entry_Systems\ConfluenceEntrySystem.mqh"
#include "..\02_Source_Code\Exit_Systems\IntelligentExitSystem.mqh"

//--- Includes dos novos sistemas avançados (Fase 1)
#include "..\MQL5_Source\Include\CAdvancedSignalEngine.mqh"
#include "..\MQL5_Source\Include\CDynamicLevels.mqh"
#include "..\MQL5_Source\Include\CSignalConfluence.mqh"

//+------------------------------------------------------------------+
//| PARÂMETROS DE ENTRADA                                            |
//+------------------------------------------------------------------+

//--- Configurações Gerais
input group "=== CONFIGURAÇÕES GERAIS ==="
input string EA_Comment = "EA_FTMO_SCALPER_ELITE_v1.0";  // Comentário do EA
input int MagicNumber = 123456;                           // Número Mágico
input bool EnableTrading = true;                          // Habilitar Trading
input bool EnableAlerts = true;                           // Habilitar Alertas

//--- Risk Management
input group "=== GERENCIAMENTO DE RISCO ==="
input double RiskPerTrade = 1.0;                         // Risco por Trade (%)
input double MaxDailyLoss = 5.0;                         // Perda Máxima Diária (%)
input double MaxTotalLoss = 10.0;                        // Perda Máxima Total (%)
input double SafetyZonePercent = 2.0;                    // Zona de Segurança (%)
input bool EnableEquityStop = true;                      // Habilitar Equity Stop
input int MaxPositions = 1;                              // Máximo de Posições

//--- Entry System (Confluence)
input group "=== SISTEMA DE ENTRADA ==="
input int ConfluenceLevel = 3;                           // Nível de Confluência (1-5)
input int RSI_Period = 14;                               // Período RSI
input double RSI_Oversold = 30.0;                       // RSI Oversold
input double RSI_Overbought = 70.0;                     // RSI Overbought
input int MACD_Fast = 12;                                // MACD Fast EMA
input int MACD_Slow = 26;                                // MACD Slow EMA
input int MACD_Signal = 9;                               // MACD Signal
input int EMA_Period = 50;                               // Período EMA
input double ATR_Multiplier = 2.0;                      // Multiplicador ATR para SL/TP

//--- Exit System
input group "=== SISTEMA DE SAÍDA ==="
input ENUM_TRAILING_TYPE TrailingType = TRAILING_ATR;    // Tipo de Trailing Stop
input double TrailingStart = 10.0;                      // Início do Trailing (pontos)
input double TrailingStep = 5.0;                        // Passo do Trailing (pontos)
input double TrailingPercent = 50.0;                    // Trailing Percentual (%)
input bool EnableBreakeven = true;                       // Habilitar Breakeven
input double BreakevenPoints = 15.0;                    // Pontos para Breakeven
input bool EnablePartialTP = true;                       // Habilitar TP Parcial
input double PartialTP1_Percent = 30.0;                 // TP Parcial 1 (%)
input double PartialTP1_Points = 20.0;                  // TP Parcial 1 (pontos)

//--- Advanced Filters
input group "=== FILTROS AVANÇADOS ==="
input bool EnableNewsFilter = true;                      // Filtro de Notícias
input int NewsFilterMinutes = 30;                       // Minutos antes/depois notícias
input bool EnableSessionFilter = true;                   // Filtro de Sessão
input int SessionStartHour = 8;                         // Hora Início Sessão
input int SessionEndHour = 17;                          // Hora Fim Sessão
input bool EnableVolatilityFilter = true;               // Filtro de Volatilidade
input double MinATR = 0.5;                              // ATR Mínimo
input double MaxATR = 3.0;                              // ATR Máximo
input bool EnableSpreadFilter = true;                   // Filtro de Spread
input double MaxSpread = 2.0;                           // Spread Máximo (pontos)

//--- Alert System
input group "=== SISTEMA DE ALERTAS ==="
input bool EnablePopupAlerts = true;                    // Alertas Popup
input bool EnableSoundAlerts = true;                    // Alertas Sonoros
input bool EnableEmailAlerts = false;                   // Alertas Email
input bool EnablePushAlerts = false;                    // Alertas Push
input string TelegramToken = "";                        // Token Bot Telegram
input string TelegramChatID = "";                       // Chat ID Telegram

//+------------------------------------------------------------------+
//| ENUMERAÇÕES                                                      |
//+------------------------------------------------------------------+

// Níveis de Alerta
enum ENUM_ALERT_LEVEL
{
   ALERT_LOW = 1,       // Alerta baixo
   ALERT_MEDIUM = 2,    // Alerta médio
   ALERT_HIGH = 3       // Alerta alto
};

// Tipos de Trailing Stop
#ifndef ENUM_TRAILING_TYPE_DEFINED
#define ENUM_TRAILING_TYPE_DEFINED
enum ENUM_TRAILING_TYPE
{
   TRAILING_FIXED,      // Trailing Fixo
   TRAILING_PERCENT,    // Trailing Percentual
   TRAILING_ATR,        // Trailing ATR
   TRAILING_MA,         // Trailing Moving Average
   TRAILING_SAR,        // Trailing Parabolic SAR
   TRAILING_HIGHLOW     // Trailing High/Low
};
#endif

//+------------------------------------------------------------------+
//| VARIÁVEIS GLOBAIS                                                |
//+------------------------------------------------------------------+

// Objetos de Trading
CTrade trade;
CPositionInfo position;
COrderInfo order;
CAccountInfo account;
CSymbolInfo symbol;

// Objetos dos Módulos do Projeto
CRiskManager riskManager;
CAdvancedFilters advancedFilters;
CConfluenceEntrySystem confluenceEntry;
CIntelligentExitSystem intelligentExit;

// Objetos dos Novos Sistemas Avançados (Fase 1)
CAdvancedSignalEngine* advancedSignalEngine;
CDynamicLevels* dynamicLevels;
CSignalConfluence* signalConfluence;

// Handles dos Indicadores
int handle_RSI;
int handle_MACD;
int handle_EMA;
int handle_ATR;
int handle_SAR;

// Variáveis de Controle
double dailyStartBalance;
double totalStartBalance;
bool tradingEnabled;
datetime lastBarTime;
int barsTotal;

// Arrays dos Indicadores
double rsi_buffer[];
double macd_main[];
double macd_signal[];
double ema_buffer[];
double atr_buffer[];
double sar_buffer[];

// Estruturas de Dados
struct STradeSignal
{
   bool isValid;
   int direction;        // 1 = Buy, -1 = Sell
   double entryPrice;
   double stopLoss;
   double takeProfit;
   double lotSize;
   string comment;
};

struct SRiskData
{
   double currentEquity;
   double dailyPnL;
   double totalPnL;
   double riskAmount;
   bool canTrade;
   string riskStatus;
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== EA FTMO SCALPER ELITE v1.0 - Inicializando ===");
   
   // Configurar objetos de trading
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());
   
   // Configurar símbolo
   if(!symbol.Name(Symbol()))
   {
      Print("Erro ao configurar símbolo: ", Symbol());
      return INIT_FAILED;
   }
   
   // Inicializar indicadores
   if(!InitializeIndicators())
   {
      Print("Erro ao inicializar indicadores");
      return INIT_FAILED;
   }
   
   // Inicializar módulos do projeto
   if(!InitializeProjectModules())
   {
      Print("Erro ao inicializar módulos do projeto");
      return INIT_FAILED;
   }
   
   // Inicializar novos sistemas avançados (Fase 1)
   if(!InitializeAdvancedSystems())
   {
      Print("Erro ao inicializar sistemas avançados");
      return INIT_FAILED;
   }
   
   // Configurar arrays
   ArraySetAsSeries(rsi_buffer, true);
   ArraySetAsSeries(macd_main, true);
   ArraySetAsSeries(macd_signal, true);
   ArraySetAsSeries(ema_buffer, true);
   ArraySetAsSeries(atr_buffer, true);
   ArraySetAsSeries(sar_buffer, true);
   
   // Inicializar variáveis de controle
   dailyStartBalance = account.Balance();
   totalStartBalance = account.Balance();
   tradingEnabled = EnableTrading;
   lastBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
   barsTotal = iBars(Symbol(), PERIOD_CURRENT);
   
   Print("EA inicializado com sucesso!");
   Print("Símbolo: ", Symbol());
   Print("Timeframe: ", EnumToString(Period()));
   Print("Magic Number: ", MagicNumber);
   Print("Balance Inicial: ", DoubleToString(account.Balance(), 2));
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("=== EA FTMO SCALPER ELITE - Finalizando ===");
   
   // Liberar handles dos indicadores
   if(handle_RSI != INVALID_HANDLE) IndicatorRelease(handle_RSI);
   if(handle_MACD != INVALID_HANDLE) IndicatorRelease(handle_MACD);
   if(handle_EMA != INVALID_HANDLE) IndicatorRelease(handle_EMA);
   if(handle_ATR != INVALID_HANDLE) IndicatorRelease(handle_ATR);
   if(handle_SAR != INVALID_HANDLE) IndicatorRelease(handle_SAR);
   
   // Liberar objetos dos sistemas avançados
   if(advancedSignalEngine != NULL) delete advancedSignalEngine;
   if(dynamicLevels != NULL) delete dynamicLevels;
   if(signalConfluence != NULL) delete signalConfluence;
   
   Print("EA finalizado. Motivo: ", EnumToString((ENUM_DEINIT_REASON)reason));
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verificar se é uma nova barra
   if(!IsNewBar()) return;
   
   // Atualizar dados de conta
   account.Refresh();
   symbol.RefreshRates();
   
   // Verificar gerenciamento de risco
   SRiskData riskData = CheckRiskManagement();
   if(!riskData.canTrade)
   {
      if(EnableAlerts)
         SendAlert("RISK ALERT", riskData.riskStatus, ALERT_HIGH);
      return;
   }
   
   // Verificar filtros avançados
   if(!CheckAdvancedFilters())
   {
      return;
   }
   
   // Processar sistema de saída (trailing stops)
   ProcessExitSystem();
   
   // Verificar se pode abrir novas posições
   if(PositionsTotal() >= MaxPositions)
      return;
   
   // Analisar sinal de entrada
   STradeSignal signal = AnalyzeEntrySignal();
   
   if(signal.isValid)
   {
      // Executar trade
      if(ExecuteTrade(signal))
      {
         if(EnableAlerts)
            SendAlert("TRADE OPENED", 
                     StringFormat("Direção: %s | Preço: %.5f | SL: %.5f | TP: %.5f",
                                 signal.direction > 0 ? "BUY" : "SELL",
                                 signal.entryPrice, signal.stopLoss, signal.takeProfit),
                     ALERT_MEDIUM);
      }
   }
}

//+------------------------------------------------------------------+
//| Inicializar Indicadores                                         |
//+------------------------------------------------------------------+
bool InitializeIndicators()
{
   // RSI
   handle_RSI = iRSI(Symbol(), PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
   if(handle_RSI == INVALID_HANDLE)
   {
      Print("Erro ao criar handle RSI");
      return false;
   }
   
   // MACD
   handle_MACD = iMACD(Symbol(), PERIOD_CURRENT, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   if(handle_MACD == INVALID_HANDLE)
   {
      Print("Erro ao criar handle MACD");
      return false;
   }
   
   // EMA
   handle_EMA = iMA(Symbol(), PERIOD_CURRENT, EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   if(handle_EMA == INVALID_HANDLE)
   {
      Print("Erro ao criar handle EMA");
      return false;
   }
   
   // ATR
   handle_ATR = iATR(Symbol(), PERIOD_CURRENT, 14);
   if(handle_ATR == INVALID_HANDLE)
   {
      Print("Erro ao criar handle ATR");
      return false;
   }
   
   // Parabolic SAR
   handle_SAR = iSAR(Symbol(), PERIOD_CURRENT, 0.02, 0.2);
   if(handle_SAR == INVALID_HANDLE)
   {
      Print("Erro ao criar handle SAR");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Inicializar Módulos do Projeto                                  |
//+------------------------------------------------------------------+
bool InitializeProjectModules()
{
   // Inicializar Risk Manager
   if(!riskManager.Initialize(Symbol(), MagicNumber, MaxDailyLoss, MaxTotalLoss, RiskPerTrade))
   {
      Print("Erro ao inicializar Risk Manager");
      return false;
   }
   
   // Inicializar Advanced Filters
   if(!advancedFilters.Initialize(Symbol(), MaxSpread, MinVolatility, MaxVolatility))
   {
      Print("Erro ao inicializar Advanced Filters");
      return false;
   }
   
   // Inicializar Confluence Entry System
   if(!confluenceEntry.Initialize(Symbol(), RSI_Period, MACD_Fast, MACD_Slow, MACD_Signal, EMA_Period))
   {
      Print("Erro ao inicializar Confluence Entry System");
      return false;
   }
   
   // Inicializar Intelligent Exit System
   if(!intelligentExit.Initialize(Symbol(), ATR_Period, TrailingStopType, BreakevenPoints, TrailingStart))
   {
      Print("Erro ao inicializar Intelligent Exit System");
      return false;
   }
   
   Print("Todos os módulos do projeto inicializados com sucesso!");
   return true;
}

//+------------------------------------------------------------------+
//| Inicializar Sistemas Avançados (Fase 1)                        |
//+------------------------------------------------------------------+
bool InitializeAdvancedSystems()
{
   Print("=== Inicializando Sistemas Avançados (Fase 1) ===");
   
   // Criar instâncias dos objetos
   advancedSignalEngine = new CAdvancedSignalEngine();
   dynamicLevels = new CDynamicLevels();
   signalConfluence = new CSignalConfluence();
   
   if(advancedSignalEngine == NULL || dynamicLevels == NULL || signalConfluence == NULL)
   {
      Print("Erro ao criar instâncias dos sistemas avançados");
      return false;
   }
   
   // Inicializar CAdvancedSignalEngine
   if(!advancedSignalEngine.Initialize(Symbol()))
   {
      Print("Erro ao inicializar CAdvancedSignalEngine");
      return false;
   }
   
   // Inicializar CDynamicLevels
   if(!dynamicLevels.Initialize(Symbol()))
   {
      Print("Erro ao inicializar CDynamicLevels");
      return false;
   }
   
   // Inicializar CSignalConfluence
   if(!signalConfluence.Initialize(Symbol(), advancedSignalEngine, dynamicLevels))
   {
      Print("Erro ao inicializar CSignalConfluence");
      return false;
   }
   
   Print("Sistemas Avançados inicializados com sucesso!");
   return true;
}

//+------------------------------------------------------------------+
//| Verificar se é nova barra                                       |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
   if(currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Verificar Gerenciamento de Risco                                |
//+------------------------------------------------------------------+
SRiskData CheckRiskManagement()
{
   SRiskData risk;
   
   // Usar o módulo RiskManager para verificações
   if(!riskManager.CanTrade())
   {
      risk.canTrade = false;
      risk.riskStatus = riskManager.GetRiskStatus();
      risk.currentEquity = account.Equity();
      risk.dailyPnL = riskManager.GetDailyPnL();
      risk.totalPnL = riskManager.GetTotalPnL();
      risk.riskAmount = 0.0;
      
      // Fechar todas as posições se necessário
      if(riskManager.ShouldCloseAllPositions())
      {
         CloseAllPositions(risk.riskStatus);
      }
      
      return risk;
   }
   
   // Atualizar dados de risco
   riskManager.UpdateRiskData();
   
   risk.currentEquity = account.Equity();
   risk.dailyPnL = riskManager.GetDailyPnL();
   risk.totalPnL = riskManager.GetTotalPnL();
   risk.riskAmount = riskManager.CalculatePositionSize(Symbol(), 0.0); // Será calculado com SL real
   risk.canTrade = true;
   risk.riskStatus = "OK";
   
   return risk;
}

//+------------------------------------------------------------------+
//| Verificar Filtros Avançados                                     |
//+------------------------------------------------------------------+
bool CheckAdvancedFilters()
{
   // Usar o módulo AdvancedFilters para todas as verificações
   return advancedFilters.CheckAllFilters();
}

//+------------------------------------------------------------------+
//| Analisar Sinal de Entrada (Sistema de Confluência Avançado)    |
//+------------------------------------------------------------------+
STradeSignal AnalyzeEntrySignal()
{
   STradeSignal signal;
   signal.isValid = false;
   signal.direction = 0;
   
   // === SISTEMA AVANÇADO DE CONFLUÊNCIA (FASE 1) ===
   // Usar o novo sistema CSignalConfluence para análise completa
   SConfluenceResult confluenceResult = signalConfluence.AnalyzeConfluence();
   
   if(!confluenceResult.isValid || confluenceResult.finalScore < 60.0)
   {
      // Fallback para sistema original se necessário
      if(confluenceResult.finalScore > 0.0)
      {
         Print("Sinal de confluência fraco - Score: ", DoubleToString(confluenceResult.finalScore, 1), 
               " (mínimo: 60.0)");
      }
      return signal;
   }
   
   // Converter resultado da confluência para estrutura STradeSignal
   signal.isValid = true;
   signal.direction = confluenceResult.direction;
   signal.entryPrice = confluenceResult.entryPrice;
   signal.stopLoss = confluenceResult.stopLoss;
   signal.takeProfit = confluenceResult.takeProfit;
   signal.comment = StringFormat("ADV_CONFLUENCE_v2.0_Score%.1f", confluenceResult.finalScore);
   
   // Calcular tamanho da posição usando RiskManager
   double slDistance = MathAbs(signal.entryPrice - signal.stopLoss);
   signal.lotSize = riskManager.CalculatePositionSize(Symbol(), slDistance);
   
   // Validar se o tamanho da posição é válido
   signal.lotSize = NormalizeLots(signal.lotSize);
   
   if(signal.lotSize <= 0.0)
   {
      signal.isValid = false;
      Print("Tamanho de posição inválido calculado: ", signal.lotSize);
      return signal;
   }
   
   // Log detalhado do sinal avançado
   Print("=== SINAL AVANÇADO DETECTADO ===");
   Print("Score Final: ", DoubleToString(confluenceResult.finalScore, 1));
   Print("Direção: ", signal.direction > 0 ? "BUY" : "SELL");
   Print("Preço Entrada: ", DoubleToString(signal.entryPrice, 5));
   Print("Stop Loss: ", DoubleToString(signal.stopLoss, 5));
   Print("Take Profit: ", DoubleToString(signal.takeProfit, 5));
   Print("Lote Calculado: ", DoubleToString(signal.lotSize, 2));
   Print("Distância SL: ", DoubleToString(slDistance / symbol.Point(), 1), " pontos");
   Print("Confiança: ", DoubleToString(confluenceResult.confidence, 1), "%");
   
   return signal;
}

//+------------------------------------------------------------------+
//| Executar Trade                                                  |
//+------------------------------------------------------------------+
bool ExecuteTrade(STradeSignal &signal)
{
   bool result = false;
   
   if(signal.direction > 0) // Buy
   {
      result = trade.Buy(signal.lotSize, Symbol(), signal.entryPrice, 
                        signal.stopLoss, signal.takeProfit, signal.comment);
   }
   else // Sell
   {
      result = trade.Sell(signal.lotSize, Symbol(), signal.entryPrice,
                         signal.stopLoss, signal.takeProfit, signal.comment);
   }
   
   if(result)
   {
      Print("Trade executado: ", signal.direction > 0 ? "BUY" : "SELL",
            " | Lotes: ", DoubleToString(signal.lotSize, 2),
            " | Preço: ", DoubleToString(signal.entryPrice, 5),
            " | SL: ", DoubleToString(signal.stopLoss, 5),
            " | TP: ", DoubleToString(signal.takeProfit, 5));
   }
   else
   {
      Print("Erro ao executar trade: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Processar Sistema de Saída                                      |
//+------------------------------------------------------------------+
void ProcessExitSystem()
{
   // Usar o módulo IntelligentExitSystem para processar todas as saídas
   intelligentExit.ProcessAllPositions();
}

//+------------------------------------------------------------------+
//| Fechar Todas as Posições                                        |
//+------------------------------------------------------------------+
void CloseAllPositions(string reason)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!position.SelectByIndex(i)) continue;
      if(position.Symbol() != Symbol()) continue;
      if(position.Magic() != MagicNumber) continue;
      
      if(trade.PositionClose(position.Ticket()))
      {
         Print("Posição fechada: ", position.Ticket(), " | Motivo: ", reason);
      }
   }
}

//+------------------------------------------------------------------+
//| Normalizar Lotes                                                |
//+------------------------------------------------------------------+
double NormalizeLots(double lots)
{
   double minLot = symbol.LotsMin();
   double maxLot = symbol.LotsMax();
   double stepLot = symbol.LotsStep();
   
   if(lots < minLot) return minLot;
   if(lots > maxLot) return maxLot;
   
   return MathRound(lots / stepLot) * stepLot;
}

//+------------------------------------------------------------------+
//| Verificar se o nível de stop é válido                           |
//+------------------------------------------------------------------+
bool IsValidStopLevel(double price, ENUM_POSITION_TYPE posType)
{
   double currentPrice = posType == POSITION_TYPE_BUY ? symbol.Bid() : symbol.Ask();
   double stopLevel = symbol.StopsLevel() * symbol.Point();
   
   if(posType == POSITION_TYPE_BUY)
   {
      return (currentPrice - price) >= stopLevel;
   }
   else
   {
      return (price - currentPrice) >= stopLevel;
   }
}

//+------------------------------------------------------------------+
//| Enviar Alerta                                                   |
//+------------------------------------------------------------------+
void SendAlert(string title, string message, int priority)
{
   string fullMessage = StringFormat("[%s] %s: %s", 
                                    TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
                                    title, message);
   
   if(EnablePopupAlerts)
   {
      Alert(fullMessage);
   }
   
   if(EnableSoundAlerts)
   {
      PlaySound("alert.wav");
   }
   
   if(EnableEmailAlerts)
   {
      SendMail(title, fullMessage);
   }
   
   if(EnablePushAlerts)
   {
      SendNotification(fullMessage);
   }
   
   Print("ALERT: ", fullMessage);
}

//+------------------------------------------------------------------+