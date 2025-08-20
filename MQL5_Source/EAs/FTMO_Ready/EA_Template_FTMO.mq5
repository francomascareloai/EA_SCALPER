//+------------------------------------------------------------------+
//|                                           EA_Template_FTMO.mq5 |
//|                                  Copyright 2025, TradeDev_Master |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TradeDev_Master"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Template EA FTMO-Ready com gerenciamento de risco avançado"

//--- Includes
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//--- Objects
CTrade         trade;
CPositionInfo  position;
CAccountInfo   account;

//--- Input Parameters
input group "=== RISK MANAGEMENT ==="
input double   RiskPercent = 1.0;           // Risk per trade (%)
input double   MaxDailyLoss = 5.0;          // Max daily loss (%)
input double   MaxTotalDD = 10.0;           // Max total drawdown (%)
input bool     UseFixedLot = false;         // Use fixed lot size
input double   FixedLotSize = 0.01;         // Fixed lot size

input group "=== TRADING PARAMETERS ==="
input int      MagicNumber = 123456;        // Magic number
input string   TradeComment = "FTMO_EA";    // Trade comment
input bool     TradeOnNewBar = true;        // Trade only on new bar

input group "=== TIME FILTERS ==="
input bool     UseTimeFilter = true;        // Enable time filter
input int      StartHour = 8;               // Start trading hour
input int      EndHour = 18;                // End trading hour

input group "=== NEWS FILTER ==="
input bool     UseNewsFilter = true;        // Enable news filter
input int      NewsFilterMinutes = 30;      // Minutes before/after news

//--- Global Variables
datetime       lastBarTime = 0;
double         dailyStartBalance = 0;
double         maxEquity = 0;
bool           tradingAllowed = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Set magic number
   trade.SetExpertMagicNumber(MagicNumber);
   
   //--- Initialize daily balance
   dailyStartBalance = account.Balance();
   maxEquity = account.Equity();
   
   //--- Print initialization info
   Print("EA initialized successfully");
   Print("Account Balance: ", account.Balance());
   Print("Account Equity: ", account.Equity());
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("EA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check if new bar
   if(TradeOnNewBar && !IsNewBar()) return;
   
   //--- Risk management checks
   if(!CheckRiskManagement()) return;
   
   //--- Time filter check
   if(!CheckTimeFilter()) return;
   
   //--- News filter check
   if(!CheckNewsFilter()) return;
   
   //--- Main trading logic
   MainTradingLogic();
}

//+------------------------------------------------------------------+
//| Check if new bar formed                                         |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Risk Management System                                          |
//+------------------------------------------------------------------+
bool CheckRiskManagement()
{
   //--- Update max equity
   if(account.Equity() > maxEquity)
      maxEquity = account.Equity();
   
   //--- Check daily loss limit
   double dailyPnL = account.Equity() - dailyStartBalance;
   double dailyLossPercent = (dailyPnL / dailyStartBalance) * 100;
   
   if(dailyLossPercent <= -MaxDailyLoss)
   {
      tradingAllowed = false;
      Print("ALERT: Daily loss limit reached: ", dailyLossPercent, "%");
      CloseAllPositions();
      return false;
   }
   
   //--- Check total drawdown
   double currentDD = ((maxEquity - account.Equity()) / maxEquity) * 100;
   if(currentDD >= MaxTotalDD)
   {
      tradingAllowed = false;
      Print("ALERT: Maximum drawdown reached: ", currentDD, "%");
      CloseAllPositions();
      return false;
   }
   
   return tradingAllowed;
}

//+------------------------------------------------------------------+
//| Time Filter                                                     |
//+------------------------------------------------------------------+
bool CheckTimeFilter()
{
   if(!UseTimeFilter) return true;
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(dt.hour >= StartHour && dt.hour < EndHour)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| News Filter                                                     |
//+------------------------------------------------------------------+
bool CheckNewsFilter()
{
   if(!UseNewsFilter) return true;
   
   //--- Implement news filter logic here
   //--- This is a placeholder - implement actual news calendar check
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Position Size                                         |
//+------------------------------------------------------------------+
double CalculatePositionSize(double stopLossPoints)
{
   if(UseFixedLot)
      return FixedLotSize;
   
   double riskAmount = account.Balance() * (RiskPercent / 100.0);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lotSize = riskAmount / (stopLossPoints * tickValue);
   
   //--- Normalize lot size
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Main Trading Logic                                              |
//+------------------------------------------------------------------+
void MainTradingLogic()
{
   //--- Implement your trading strategy here
   //--- This is a template - add your entry/exit logic
   
   //--- Example: Simple moving average crossover
   double ma_fast = iMA(_Symbol, PERIOD_CURRENT, 10, 0, MODE_SMA, PRICE_CLOSE);
   double ma_slow = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
   
   //--- Check for buy signal
   if(ma_fast > ma_slow && !HasOpenPosition(POSITION_TYPE_BUY))
   {
      OpenBuyPosition();
   }
   
   //--- Check for sell signal
   if(ma_fast < ma_slow && !HasOpenPosition(POSITION_TYPE_SELL))
   {
      OpenSellPosition();
   }
}

//+------------------------------------------------------------------+
//| Check if position exists                                        |
//+------------------------------------------------------------------+
bool HasOpenPosition(ENUM_POSITION_TYPE posType)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(position.SelectByIndex(i))
      {
         if(position.Symbol() == _Symbol && 
            position.Magic() == MagicNumber &&
            position.PositionType() == posType)
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Open Buy Position                                               |
//+------------------------------------------------------------------+
void OpenBuyPosition()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = ask - 100 * _Point;  // 100 points SL
   double tp = ask + 200 * _Point;  // 200 points TP
   
   double lotSize = CalculatePositionSize(100); // 100 points risk
   
   if(trade.Buy(lotSize, _Symbol, ask, sl, tp, TradeComment))
   {
      Print("Buy order opened successfully");
   }
   else
   {
      Print("Failed to open buy order. Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Open Sell Position                                              |
//+------------------------------------------------------------------+
void OpenSellPosition()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = bid + 100 * _Point;  // 100 points SL
   double tp = bid - 200 * _Point;  // 200 points TP
   
   double lotSize = CalculatePositionSize(100); // 100 points risk
   
   if(trade.Sell(lotSize, _Symbol, bid, sl, tp, TradeComment))
   {
      Print("Sell order opened successfully");
   }
   else
   {
      Print("Failed to open sell order. Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Close All Positions                                             |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(position.SelectByIndex(i))
      {
         if(position.Symbol() == _Symbol && position.Magic() == MagicNumber)
         {
            trade.PositionClose(position.Ticket());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Timer function (optional)                                       |
//+------------------------------------------------------------------+
void OnTimer()
{
   //--- Reset daily balance at start of new day
   static int lastDay = -1;
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(dt.day != lastDay)
   {
      lastDay = dt.day;
      dailyStartBalance = account.Balance();
      tradingAllowed = true;
      Print("New trading day started. Balance reset to: ", dailyStartBalance);
   }
}

//+------------------------------------------------------------------+