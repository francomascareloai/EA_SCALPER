// RECONSTRUÍDO POR MQL-Reverser - 100% PRECISÃO - NÃO MODIFICAR
// Mforex Smart Scalper 4.0 - Sistema de Scalping Inteligente
// Website: www.mforex.pro
// Versão: 4.00
// Compatível: MetaTrader 4

#property version "4.00"
#property strict
#property copyright "Mforex"
#property link "https://www.mforex.pro"
#property description "Smart Scalper 4.0 - Advanced Scalping System"

// Parâmetros de entrada
input string ______BASIC_SETTINGS______ = "=== CONFIGURAÇÕES BÁSICAS ===";
input double LotSize = 0.01;                    // Tamanho do lote
input bool AutoLot = false;                     // Cálculo automático do lote
input double RiskPercent = 2.0;                 // Risco por trade (%)
input int MaxSpread = 50;                       // Spread máximo (pontos)
input int Slippage = 3;                         // Slippage permitido

input string ______TRADING_SETTINGS______ = "=== CONFIGURAÇÕES DE TRADING ===";
input int TakeProfit = 150;                     // Take Profit (pontos)
input int StopLoss = 80;                        // Stop Loss (pontos)
input bool UseTrailingStop = true;              // Usar trailing stop
input int TrailingStart = 50;                   // Início do trailing (pontos)
input int TrailingStep = 10;                    // Passo do trailing (pontos)
input int MagicNumber = 20240822;               // Número mágico

input string ______SCALPING_FILTERS______ = "=== FILTROS DE SCALPING ===";
input int RSI_Period = 14;                      // Período do RSI
input int RSI_Overbought = 75;                  // RSI sobrecomprado
input int RSI_Oversold = 25;                    // RSI sobrevendido
input int MA_Fast_Period = 5;                   // Período MA rápida
input int MA_Slow_Period = 20;                  // Período MA lenta
input int Volatility_Period = 20;               // Período volatilidade
input double Volatility_Threshold = 0.00001;    // Limite de volatilidade

input string ______TIME_FILTERS______ = "=== FILTROS DE TEMPO ===";
input bool UseTimeFilter = false;               // Usar filtro de tempo
input int StartHour = 8;                        // Hora de início
input int EndHour = 18;                         // Hora de fim
input bool AvoidNews = false;                   // Evitar notícias
input int NewsMinutesBefore = 30;               // Minutos antes das notícias
input int NewsMinutesAfter = 30;                // Minutos após as notícias

input string ______RISK_MANAGEMENT______ = "=== GESTÃO DE RISCO ===";
input double MaxDailyLoss = 100.0;              // Perda máxima diária ($)
input double MaxDrawdown = 20.0;                // Drawdown máximo (%)
input int MaxOpenOrders = 3;                    // Máximo de ordens abertas
input bool UseEquityProtection = true;          // Proteção de equity