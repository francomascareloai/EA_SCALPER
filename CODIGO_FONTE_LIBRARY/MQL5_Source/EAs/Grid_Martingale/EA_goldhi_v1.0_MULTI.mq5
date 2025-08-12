//+------------------------------------------------------------------+
//|                        Trend Recovery EA for MT5                |
//|        Profit-Oriented EA without SL, 1% Profit Booking        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>
CTrade trade;

input double AutoLotPer1000 = 0.01;
input int FastEMA = 12;
input int SlowEMA = 26;
input int SignalSMA = 9;
input int RSI_Period = 14;
input double RSI_Overbought = 70;
input double RSI_Oversold = 30;
input double ProfitTargetPercent = 1.0;
input int TradeDelayMinutes = 5;
input ulong MagicNumber = 123456;
input double MaxAllowedDrawdownPercent = 20;
input int MaxOpenTrades = 300;
input int MaxRecoverySteps = 10;
input double MaxLotSize = 0.2;
input ENUM_TIMEFRAMES TrendTF = PERIOD_H1;
input int LossCooldownMinutes = 30;
input double MinCandleSizePoints = 150;
input double MinSignalCandleSize = 200;
input double MinCandleBodyRatio = 0.5;
input double MaxSlippagePips = 3;
input int MinGapFromLastTradeBars = 1; // Minimum H1 candle gap between trades
input double MaxLossPerTradePercent = 2.0; // Max loss per trade in percent

//---
double profitLockValue = 0;
datetime lastTradeTime = 0;
int recoveryStep = 0;
int consecutiveLosses = 0;
datetime lastLossTime = 0;
bool currentTrendUp = false;
bool currentTrendDown = false;
datetime lastTradeBarTime = 0;

//--- Auto Lot Calculation
double GetLotSize()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double baseLot = AutoLotPer1000 * (balance / 1000.0);
   double lot = baseLot * MathPow(2, recoveryStep);
   if(lot > MaxLotSize)
      lot = MaxLotSize;
   return NormalizeDouble(lot, 2);
}

bool IsMaxDrawdownExceeded()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dd = ((balance - equity) / balance) * 100;
   return (dd >= MaxAllowedDrawdownPercent);
}

int CurrentOpenTrades()
{
   int count = 0;
   for(int i=0; i<PositionsTotal(); i++)
   {
      if(PositionGetSymbol(i) == _Symbol)
         count++;
   }
   return count;
}

bool IsTrendUp()
{
   int emaFastHandle = iMA(_Symbol, TrendTF, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   int emaSlowHandle = iMA(_Symbol, TrendTF, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);

   double emaFastBuffer[], emaSlowBuffer[];
   if(CopyBuffer(emaFastHandle, 0, 0, 1, emaFastBuffer) < 0) return false;
   if(CopyBuffer(emaSlowHandle, 0, 0, 1, emaSlowBuffer) < 0) return false;

   return emaFastBuffer[0] > emaSlowBuffer[0];
}

bool IsTrendDown()
{
   int emaFastHandle = iMA(_Symbol, TrendTF, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   int emaSlowHandle = iMA(_Symbol, TrendTF, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);

   double emaFastBuffer[], emaSlowBuffer[];
   if(CopyBuffer(emaFastHandle, 0, 0, 1, emaFastBuffer) < 0) return false;
   if(CopyBuffer(emaSlowHandle, 0, 0, 1, emaSlowBuffer) < 0) return false;

   return emaFastBuffer[0] < emaSlowBuffer[0];
}

bool IsBigCandle()
{
   double high = iHigh(_Symbol, _Period, 1);
   double low = iLow(_Symbol, _Period, 1);
   double open = iOpen(_Symbol, _Period, 1);
   double close = iClose(_Symbol, _Period, 1);
   double size = MathAbs(high - low) / _Point;
   double body = MathAbs(close - open) / _Point;
   double bodyRatio = body / size;
   return size >= MinCandleSizePoints && bodyRatio >= MinCandleBodyRatio;
}

bool IsSignalBuy()
{
   int emaFastHandle = iMA(_Symbol, _Period, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   int emaSlowHandle = iMA(_Symbol, _Period, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   int rsiHandle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);

   double emaFastBuffer[], emaSlowBuffer[], rsiBuffer[];
   if(CopyBuffer(emaFastHandle, 0, 0, 1, emaFastBuffer) < 0) return false;
   if(CopyBuffer(emaSlowHandle, 0, 0, 1, emaSlowBuffer) < 0) return false;
   if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) < 0) return false;

   double candleBody = MathAbs(iClose(_Symbol, _Period, 1) - iOpen(_Symbol, _Period, 1)) / _Point;
   double candleClose = iClose(_Symbol, _Period, 1);
   double candleOpen = iOpen(_Symbol, _Period, 1);

   int macd_handle = iMACD(_Symbol, _Period, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE);
   double macd_main[], macd_signal[];
   if (CopyBuffer(macd_handle, 0, 0, 1, macd_main) < 0) return false;
   if (CopyBuffer(macd_handle, 1, 0, 1, macd_signal) < 0) return false;

   bool bullishCandle = candleClose > candleOpen;
   bool condition1 = (emaFastBuffer[0] > emaSlowBuffer[0] && rsiBuffer[0] > 50 && macd_main[0] > macd_signal[0]);
   bool condition2 = (IsTrendUp() && bullishCandle && rsiBuffer[0] > 50);

   return (condition1 || condition2) && candleBody > MinSignalCandleSize && IsBigCandle();
}

bool IsSignalSell()
{
   int emaFastHandle = iMA(_Symbol, _Period, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   int emaSlowHandle = iMA(_Symbol, _Period, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   int rsiHandle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);

   double emaFastBuffer[], emaSlowBuffer[], rsiBuffer[];
   if(CopyBuffer(emaFastHandle, 0, 0, 1, emaFastBuffer) < 0) return false;
   if(CopyBuffer(emaSlowHandle, 0, 0, 1, emaSlowBuffer) < 0) return false;
   if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) < 0) return false;

   double candleBody = MathAbs(iClose(_Symbol, _Period, 1) - iOpen(_Symbol, _Period, 1)) / _Point;
   double candleClose = iClose(_Symbol, _Period, 1);
   double candleOpen = iOpen(_Symbol, _Period, 1);

   int macd_handle = iMACD(_Symbol, _Period, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE);
   double macd_main[], macd_signal[];
   if (CopyBuffer(macd_handle, 0, 0, 1, macd_main) < 0) return false;
   if (CopyBuffer(macd_handle, 1, 0, 1, macd_signal) < 0) return false;

   bool bearishCandle = candleClose < candleOpen;
   bool condition1 = (emaFastBuffer[0] < emaSlowBuffer[0] && rsiBuffer[0] < 50 && macd_main[0] < macd_signal[0]);
   bool condition2 = (IsTrendDown() && bearishCandle && rsiBuffer[0] < 50);

   return (condition1 || condition2) && candleBody > MinSignalCandleSize && IsBigCandle();
}

int OnInit()
{
   Print("EA Initialized Successfully");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Print("EA Removed");
}

void OnTick()
{
   if(IsMaxDrawdownExceeded() || CurrentOpenTrades() >= MaxOpenTrades)
      return;

   datetime currentBarTime = iTime(_Symbol, PERIOD_H1, 0);
   if(currentBarTime == lastTradeBarTime) return;

   double lot = GetLotSize();

   if(IsSignalBuy())
   {
      if(trade.Buy(lot, _Symbol))
      {
         lastTradeBarTime = currentBarTime;
         Print("Buy Trade Placed");
      }
   }
   else if(IsSignalSell())
   {
      if(trade.Sell(lot, _Symbol))
      {
         lastTradeBarTime = currentBarTime;
         Print("Sell Trade Placed");
      }
   }
}
