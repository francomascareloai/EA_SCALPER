#property copyright "Matt Todorovski 2025"
#property link      "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version   "1.06"
#property strict

input double LotSize = 0.01;
input int FastMAPeriod = 15;
input int SlowMAPeriod = 20;
input int ADXPeriod = 14;
input double ADXThreshold = 25.0;
input int ATRPeriod = 14;
input double ATRMultiplierTrailing = 2.0;
input double ATRVolatilityThreshold = 0.0005;
input int Slippage = 3;
input string TradeComment = "XU Trend Following EA";
input int MagicNumber = 202503221;
input double HedgeTriggerPips = 200;
input double HedgeLotMultiplier = 1.0;
input double HedgeCloseProfitPips = 100;
input double MaxDrawdownPercent = 10.0;
input double MaxDailyLossPercent = 5.0;
input int MinTradeIntervalMinutes = 15;

double fastMA, slowMA, prevFastMA, prevSlowMA, adx, atr;
double dailyLoss = 0.0;
double equityPeak = 0.0;
datetime lastTradeTime = 0;
bool isPaused = false;
datetime pauseEndTime = 0;

int OnInit()
{
   equityPeak = AccountBalance();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   if(TimeCurrent() < pauseEndTime) return;

   if(!IsNewDay()) dailyLoss = CalculateDailyLoss();
   if(dailyLoss <= -AccountBalance() * MaxDailyLossPercent / 100.0) return;

   double currentEquity = AccountEquity();
   if(currentEquity > equityPeak) equityPeak = currentEquity;
   if((equityPeak - currentEquity) / equityPeak * 100.0 > MaxDrawdownPercent)
   {
      isPaused = true;
      pauseEndTime = TimeCurrent() + 24 * 60 * 60;
      return;
   }

   datetime currentTime = TimeCurrent();
   int hour = TimeHour(currentTime);
   if(hour < 14 || hour > 20) return;

   if(currentTime - lastTradeTime < MinTradeIntervalMinutes * 60) return;

   fastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   slowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   prevFastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   prevSlowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   adx = iADX(NULL, PERIOD_M5, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 0);
   atr = iATR(NULL, PERIOD_M5, ATRPeriod, 0);

   if(atr < ATRVolatilityThreshold) return;

   double bid = Bid;
   double ask = Ask;

   ManageHedging();
   ManageTrailingStop();

   if(fastMA > slowMA && prevFastMA <= prevSlowMA && bid <= fastMA && adx > ADXThreshold)
   {
      double sl = bid - (atr * 2.0);
      double tp = ask + (atr * 4.0);
      
      int ticket = OrderSend(Symbol(), OP_BUY, LotSize, ask, Slippage, 
                           sl, tp, TradeComment, MagicNumber, 0, clrGreen);
                           
      if(ticket >= 0)
         lastTradeTime = TimeCurrent();
      else
         Print("OrderSend failed with error #", GetLastError());
   }

   if(fastMA < slowMA && prevFastMA >= prevSlowMA && ask >= fastMA && adx > ADXThreshold)
   {
      double sl = ask + (atr * 2.0);
      double tp = bid - (atr * 4.0);
      
      int ticket = OrderSend(Symbol(), OP_SELL, LotSize, bid, Slippage, 
                           sl, tp, TradeComment, MagicNumber, 0, clrRed);
                           
      if(ticket >= 0)
         lastTradeTime = TimeCurrent();
      else
         Print("OrderSend failed with error #", GetLastError());
   }
}

void ManageTrailingStop()
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            double trailingStop = atr * ATRMultiplierTrailing;
            if(OrderType() == OP_BUY)
            {
               if(Bid - OrderOpenPrice() > trailingStop)
               {
                  double newSL = Bid - trailingStop;
                  if(newSL > OrderStopLoss())
                  {
                     bool modified = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen);
                     if(!modified)
                        Print("OrderModify failed for Buy order with error #", GetLastError());
                  }
               }
            }
            else if(OrderType() == OP_SELL)
            {
               if(OrderOpenPrice() - Ask > trailingStop)
               {
                  double newSL = Ask + trailingStop;
                  if(newSL < OrderStopLoss() || OrderStopLoss() == 0)
                  {
                     bool modified = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrRed);
                     if(!modified)
                        Print("OrderModify failed for Sell order with error #", GetLastError());
                  }
               }
            }
         }
      }
   }
}

void ManageHedging()
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(OrderType() == OP_BUY)
            {
               if(OrderOpenPrice() - Bid > HedgeTriggerPips * Point)
               {
                  if(!HasHedgePosition(OP_SELL))
                  {
                     int ticket = OrderSend(Symbol(), OP_SELL, LotSize * HedgeLotMultiplier, Bid, Slippage, 
                                          0, 0, "Hedge", MagicNumber + 1, 0, clrRed);
                     if(ticket < 0)
                        Print("Hedge OrderSend failed with error #", GetLastError());
                  }
               }
               else if(HasHedgePosition(OP_SELL))
               {
                  double totalProfit = OrderProfit() + GetHedgeProfit(OP_SELL);
                  if(totalProfit > HedgeCloseProfitPips * Point)
                  {
                     CloseHedgePosition(OP_SELL);
                  }
               }
            }
            else if(OrderType() == OP_SELL)
            {
               if(Ask - OrderOpenPrice() > HedgeTriggerPips * Point)
               {
                  if(!HasHedgePosition(OP_BUY))
                  {
                     int ticket = OrderSend(Symbol(), OP_BUY, LotSize * HedgeLotMultiplier, Ask, Slippage, 
                                          0, 0, "Hedge", MagicNumber + 1, 0, clrGreen);
                     if(ticket < 0)
                        Print("Hedge OrderSend failed with error #", GetLastError());
                  }
               }
               else if(HasHedgePosition(OP_BUY))
               {
                  double totalProfit = OrderProfit() + GetHedgeProfit(OP_BUY);
                  if(totalProfit > HedgeCloseProfitPips * Point)
                  {
                     CloseHedgePosition(OP_BUY);
                  }
               }
            }
         }
      }
   }
}

bool HasHedgePosition(int type)
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber + 1 && OrderType() == type)
            return true;
      }
   }
   return false;
}

double GetHedgeProfit(int type)
{
   double profit = 0.0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber + 1 && OrderType() == type)
            profit += OrderProfit();
      }
   }
   return profit;
}

void CloseHedgePosition(int type)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber + 1 && OrderType() == type)
         {
            bool closed = OrderClose(OrderTicket(), OrderLots(), OrderType() == OP_BUY ? Bid : Ask, Slippage, clrBlue);
            if(!closed)
               Print("OrderClose failed for hedge with error #", GetLastError());
         }
      }
   }
}

bool IsNewDay()
{
   static datetime lastDay = 0;
   datetime currentDay = TimeCurrent() / 86400;
   if(currentDay != lastDay)
   {
      lastDay = currentDay;
      return true;
   }
   return false;
}

double CalculateDailyLoss()
{
   double loss = 0.0;
   for(int i = 0; i < OrdersHistoryTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(TimeDayOfYear(OrderCloseTime()) == TimeDayOfYear(TimeCurrent()))
               loss += OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }
   return loss;
}