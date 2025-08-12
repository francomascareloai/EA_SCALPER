#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//--- Input Parameters for Optimization
input group "Optimization Settings"
input double MaxSpread = 2.0;           // Maximum Spread (pips)
input ENUM_ACCOUNT_TRADE_MODE AccountType = ACCOUNT_TRADE_MODE_REAL; // Account Type (Real, Demo)
input double RiskPercentMin = 0.5;      // Min Risk % per trade
input double RiskPercentMax = 2.0;      // Max Risk % per trade
input int TrailingStopMin = 30;         // Min Trailing Stop (pips)
input int TrailingStopMax = 70;         // Max Trailing Stop (pips)
input int BreakEvenPipsMin = 10;        // Min Break Even Pips
input int BreakEvenPipsMax = 30;        // Max Break Even Pips
input int MACD_FastEMA = 12;            // MACD Fast EMA
input int MACD_SlowEMA = 26;            // MACD Slow EMA
input int MACD_Signal = 9;              // MACD Signal
input int Momentum_Period = 14;         // Momentum Period
input double Momentum_Threshold = 100;  // Momentum Threshold
input int MA_Period = 200;              // MA Period

input group "General Settings"
input double RiskPercent = 1.0;         // Risk % per trade (default)
input int TrailingStop = 50;            // Trailing Stop (pips, default)
input int TrailingStep = 10;            // Trailing Step (pips)
input int BreakEvenPips = 20;           // Break Even Pips (default)
input int MagicNumber = 123456;         // Magic Number
input string EAComment = "InstitutionNumbersEA"; // EA Comment

//--- Global Variables
CTrade trade;
CPositionInfo posInfo;
COrderInfo orderInfo;
double highLine = 0, lowLine = 0;
bool isBullishD1 = false;
datetime lastTradeDay = 0;
int tradeCountToday = 0;
const int MAX_TRADES_PER_DAY = 10;

//--- Indicator Handles
int macdHandle, momentumHandle, maHandle, atrHandle;

//--- Initialization
int OnInit()
{
   // Set magic number
   trade.SetExpertMagicNumber(MagicNumber);
   
   // Validate account type
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) != AccountType)
   {
      Print("Account type mismatch. Expected: ", EnumToString(AccountType));
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   // Initialize indicators with user-specified parameters
   macdHandle = iMACD(_Symbol, PERIOD_M1, MACD_FastEMA, MACD_SlowEMA, MACD_Signal, PRICE_CLOSE);
   momentumHandle = iMomentum(_Symbol, PERIOD_M1, Momentum_Period, PRICE_CLOSE);
   maHandle = iMA(_Symbol, PERIOD_M1, MA_Period, 0, MODE_SMA, PRICE_CLOSE);
   atrHandle = iATR(_Symbol, PERIOD_D1, 14);
   
   // Check indicator initialization
   if(macdHandle == INVALID_HANDLE || momentumHandle == INVALID_HANDLE || 
      maHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
   {
      Print("Failed to initialize indicators");
      return(INIT_FAILED);
   }
   
   // Log optimization settings
   Print("Optimization Settings: MaxSpread=", MaxSpread, " pips, AccountType=", EnumToString(AccountType), 
         ", RiskPercent=", RiskPercent, ", TrailingStop=", TrailingStop, ", BreakEvenPips=", BreakEvenPips);
   
   return(INIT_SUCCEEDED);
}

//--- Deinitialization
void OnDeinit(const int reason)
{
   // Release indicator handles
   IndicatorRelease(macdHandle);
   IndicatorRelease(momentumHandle);
   IndicatorRelease(maHandle);
   IndicatorRelease(atrHandle);
   
   // Clean objects
   ObjectsDeleteAll(0, "InstLine_");
}

//--- Main Tick Function
void OnTick()
{
   // Check if it's a new trading day at 00:00 GMT
   datetime currentTime = TimeGMT();
   MqlDateTime timeStruct, lastStruct;
   TimeToStruct(currentTime, timeStruct);
   TimeToStruct(lastTradeDay, lastStruct);
   if(timeStruct.hour == 0 && timeStruct.min == 0 && 
      (lastTradeDay == 0 || timeStruct.day != lastStruct.day))
   {
      lastTradeDay = currentTime;
      tradeCountToday = 0;
      CleanOldTradesAndObjects();
   }
   
   // Limit trades per day
   if(tradeCountToday >= MAX_TRADES_PER_DAY) return;
   
   // Check spread
   double currentSpread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
   if(currentSpread > MaxSpread)
   {
      Print("Spread too high: ", currentSpread, " pips (Max: ", MaxSpread, ")");
      return;
   }
   
   // Step 1: D1 Analysis
   if(!AnalyzeD1()) return;
   
   // Step 2: M15 Analysis
   if(!AnalyzeM15()) return;
   
   // Step 3: M1 Confirmation and Entry
   AnalyzeM1AndEnter();
   
   // Manage open positions
   ManagePositions();
}

//--- D1 Analysis
bool AnalyzeD1()
{
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(atrHandle, 0, 1, 1, atr) <= 0) return false;
   
   double open[], close[], high[], low[];
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   
   if(CopyOpen(_Symbol, PERIOD_D1, 1, 1, open) <= 0 ||
      CopyClose(_Symbol, PERIOD_D1, 1, 1, close) <= 0 ||
      CopyHigh(_Symbol, PERIOD_D1, 1, 1, high) <= 0 ||
      CopyLow(_Symbol, PERIOD_D1, 1, 1, low) <= 0) return false;
   
   double body = MathAbs(close[0] - open[0]);
   double upperWick = high[0] - MathMax(open[0], close[0]);
   double lowerWick = MathMin(open[0], close[0]) - low[0];
   
   // Check for huge candle
   if(body > 1.5 * atr[0] && 
      upperWick < 0.2 * body && 
      lowerWick < 0.2 * body)
   {
      highLine = high[0];
      lowLine = low[0];
      isBullishD1 = close[0] > open[0];
      
      // Draw institutional lines
      ObjectCreate(0, "InstLine_High", OBJ_HLINE, 0, TimeCurrent(), highLine);
      ObjectCreate(0, "InstLine_Low", OBJ_HLINE, 0, TimeCurrent(), lowLine);
      return true;
   }
   
   return false;
}

//--- M15 Analysis
bool AnalyzeM15()
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   if(CopyHigh(_Symbol, PERIOD_M15, 1, 2, high) <= 0 ||
      CopyLow(_Symbol, PERIOD_M15, 1, 2, low) <= 0 ||
      CopyClose(_Symbol, PERIOD_M15, 1, 2, close) <= 0) return false;
   
   // Check for wick retest
   bool touchHigh = high[1] >= highLine && high[1] - close[1] > (high[1] - low[1]) * 0.5;
   bool touchLow = low[1] <= lowLine && close[1] - low[1] > (high[1] - low[1]) * 0.5;
   
   // Check if current candle closes near line
   double pipRange = 10 * _Point;
   if(touchHigh && MathAbs(close[0] - highLine) <= pipRange) return true;
   if(touchLow && MathAbs(close[0] - lowLine) <= pipRange) return true;
   
   return false;
}

//--- M1 Analysis and Entry
void AnalyzeM1AndEnter()
{
   // Get indicator values
   double macd[], signal[], momentum[], ma[];
   ArraySetAsSeries(macd, true);
   ArraySetAsSeries(signal, true);
   ArraySetAsSeries(momentum, true);
   ArraySetAsSeries(ma, true);
   
   if(CopyBuffer(macdHandle, 0, 1, 2, macd) <= 0 ||
      CopyBuffer(macdHandle, 1, 1, 2, signal) <= 0 ||
      CopyBuffer(momentumHandle, 0, 1, 1, momentum) <= 0 ||
      CopyBuffer(maHandle, 0, 1, 1, ma) <= 0) return;
   
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(_Symbol, PERIOD_M1, 1, 3, close) <= 0) return;
   
   // Smart Money Patterns
   bool choch = CheckCHOCH();
   bool bsl_ssl = CheckBSLSSL();
   bool fvg = CheckFVG();
   
   int signalCount = (choch ? 1 : 0) + (bsl_ssl ? 1 : 0) + (fvg ? 1 : 0);
   if(signalCount == 0) return;
   
   // Indicator Confluence
   bool macdCross = (macd[1] < signal[1] && macd[0] > signal[0]) || 
                    (macd[1] > signal[1] && macd[0] < signal[0]);
   bool momentumValid = momentum[0] < Momentum_Threshold;
   bool aboveMA = close[0] > ma[0];
   bool belowMA = close[0] < ma[0];
   
   // Entry Logic
   if(macdCross && momentumValid)
   {
      if(isBullishD1 && aboveMA && close[0] <= highLine)
         OpenTrade(ORDER_TYPE_BUY, signalCount);
      else if(!isBullishD1 && belowMA && close[0] >= lowLine)
         OpenTrade(ORDER_TYPE_SELL, signalCount);
   }
}

//--- Smart Money Pattern Checks
bool CheckCHOCH()
{
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   if(CopyHigh(_Symbol, PERIOD_M1, 1, 5, high) <= 0 ||
      CopyLow(_Symbol, PERIOD_M1, 1, 5, low) <= 0) return false;
   
   // Simplified CHOCH: Break of previous high/low
   if(isBullishD1 && high[0] > high[1] && low[1] < low[2]) return true;
   if(!isBullishD1 && low[0] < low[1] && high[1] > high[2]) return true;
   
   return false;
}

bool CheckBSLSSL()
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   if(CopyHigh(_Symbol, PERIOD_M1, 1, 3, high) <= 0 ||
      CopyLow(_Symbol, PERIOD_M1, 1, 3, low) <= 0 ||
      CopyClose(_Symbol, PERIOD_M1, 1, 3, close) <= 0) return false;
   
   // Check for liquidity sweep and rejection
   if(isBullishD1 && high[1] > high[2] && close[1] < close[2]) return true;
   if(!isBullishD1 && low[1] < low[2] && close[1] > close[2]) return true;
   
   return false;
}

bool CheckFVG()
{
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   if(CopyHigh(_Symbol, PERIOD_M1, 1, 3, high) <= 0 ||
      CopyLow(_Symbol, PERIOD_M1, 1, 3, low) <= 0) return false;
   
   // Check for Fair Value Gap
   if(high[2] < low[0] || low[2] > high[0]) return true;
   return false;
}

//--- Open Trade
void OpenTrade(ENUM_ORDER_TYPE type, int signalCount)
{
   double sl = CalculateStopLoss(type);
   double lotSize = CalculateLotSize(sl);
   int positions = (signalCount >= 2) ? 5 : 1;
   
   for(int i = 0; i < positions; i++)
   {
      for(int retry = 0; retry < 3; retry++)
      {
         double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                        SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(trade.Buy(lotSize, _Symbol, price, sl, 0, EAComment) && type == ORDER_TYPE_BUY ||
            trade.Sell(lotSize, _Symbol, price, sl, 0, EAComment) && type == ORDER_TYPE_SELL)
         {
            tradeCountToday++;
            Print("Trade opened: Type=", EnumToString(type), ", LotSize=", lotSize, 
                  ", Spread=", (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point);
            break;
         }
         Sleep(1000);
      }
   }
}

//--- Calculate Stop Loss
double CalculateStopLoss(ENUM_ORDER_TYPE type)
{
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(atrHandle, 0, 1, 1, atr) <= 0) return 0;
   
   double price = (type == ORDER_TYPE_BUY) ? 
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = (type == ORDER_TYPE_BUY) ? price - atr[0] : price + atr[0];
   return NormalizeDouble(sl, _Digits);
}

//--- Calculate Lot Size
double CalculateLotSize(double sl)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (RiskPercent / 100.0);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slPoints = MathAbs(price - sl) / point;
   
   double lotSize = riskAmount / (slPoints * tickValue);
   lotSize = NormalizeDouble(lotSize, 2);
   return MathMax(lotSize, 0.01);
}

//--- Manage Positions
void ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && 
         PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                              SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                              SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double sl = PositionGetDouble(POSITION_SL);
         
         // Break Even
         if(BreakEvenPips > 0)
         {
            double profitPips = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                                (currentPrice - openPrice) / _Point :
                                (openPrice - currentPrice) / _Point;
            if(profitPips >= BreakEvenPips && sl != openPrice)
            {
               trade.PositionModify(ticket, openPrice, 0);
               Print("Break Even applied: Ticket=", ticket);
            }
         }
         
         // Trailing Stop
         if(TrailingStop > 0)
         {
            double newSL = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                           currentPrice - TrailingStop * _Point :
                           currentPrice + TrailingStop * _Point;
            if((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && newSL > sl) ||
               (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && newSL < sl))
            {
               trade.PositionModify(ticket, newSL, 0);
               Print("Trailing Stop updated: Ticket=", ticket, ", New SL=", newSL);
            }
         }
         
         // Continuation Entry
         CheckContinuationEntry(ticket);
      }
   }
}

//--- Check Continuation Entry
void CheckContinuationEntry(ulong ticket)
{
   if(!PositionSelectByTicket(ticket)) return;
   
   double ma[];
   ArraySetAsSeries(ma, true);
   if(CopyBuffer(maHandle, 0, 1, 1, ma) <= 0) return;
   
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(_Symbol, PERIOD_M1, 1, 2, close) <= 0) return;
   
   // Check for engulfing or pin bar near MA
   bool isEngulfing = MathAbs(close[0] - close[1]) > MathAbs(close[1] - close[2]);
   bool nearMA = MathAbs(close[0] - ma[0]) <= 10 * _Point;
   
   if(isEngulfing && nearMA)
   {
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      OpenTrade(type == POSITION_TYPE_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, 1);
      Print("Continuation trade opened: Ticket=", ticket);
   }
}

//--- Clean Old Trades and Objects
void CleanOldTradesAndObjects()
{
   // Close old positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && 
         PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         trade.PositionClose(ticket);
         Print("Closed old position: Ticket=", ticket);
      }
   }
   
   // Delete old objects
   ObjectsDeleteAll(0, "InstLine_");
}