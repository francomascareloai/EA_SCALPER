#property copyright "Matt Todorovski 2025"
#property link      "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version   "1.06"
#property strict

input double LotSize = 0.1;
input int FastMAPeriod = 15;
input int SlowMAPeriod = 20;
input int ATRPeriod = 14;
input double ATRMultiplierTrailing = 2.0;
input int Slippage = 3;
input string TradeComment = "XU Trend Following EA";
input int MagicNumber = 202503221;
input double MartingaleMultiplier = 2.0;
input int MaxMartingaleSteps = 3;
input double HedgeTriggerPips = 300;
input double HedgeLotMultiplier = 0.5;
input double HedgeCloseProfitPips = 150;

double fastMA, slowMA, prevFastMA, prevSlowMA, atr;
int currentMartingaleStep = 0;
double lastLoss = 0.0;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   datetime currentTime = TimeCurrent();
   int hour = TimeHour(currentTime);
   if(hour < 14 || hour > 20) return;

   fastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   slowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   prevFastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   prevSlowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   atr = iATR(NULL, PERIOD_M5, ATRPeriod, 0);

   double bid = Bid;
   double ask = Ask;

   ManageHedging();
   ManageTrailingStop();

   if(fastMA > slowMA && prevFastMA <= prevSlowMA && bid <= fastMA)
   {
      double lot = CalculateLotSize();
      double sl = bid - (atr * 2.0);
      double tp = ask + (atr * 4.0);
      
      int ticket = OrderSend(Symbol(), OP_BUY, lot, ask, Slippage, 
                           sl, tp, TradeComment, MagicNumber, 0, clrGreen);
                           
      if(ticket < 0)
         Print("OrderSend failed with error #", GetLastError());
      else
         currentMartingaleStep = (currentMartingaleStep > 0) ? currentMartingaleStep + 1 : 1;
   }

   if(fastMA < slowMA && prevFastMA >= prevSlowMA && ask >= fastMA)
   {
      double lot = CalculateLotSize();
      double sl = ask + (atr * 2.0);
      double tp = bid - (atr * 4.0);
      
      int ticket = OrderSend(Symbol(), OP_SELL, lot, bid, Slippage, 
                           sl, tp, TradeComment, MagicNumber, 0, clrRed);
                           
      if(ticket < 0)
         Print("OrderSend failed with error #", GetLastError());
      else
         currentMartingaleStep = (currentMartingaleStep > 0) ? currentMartingaleStep + 1 : 1;
   }
}

double CalculateLotSize()
{
   if(currentMartingaleStep == 0 || lastLoss == 0.0) return LotSize;
   if(currentMartingaleStep >= MaxMartingaleSteps) return LotSize;
   return LotSize * MathPow(MartingaleMultiplier, currentMartingaleStep);
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
               else if(HasHedgePosition(OP_SELL) && Bid - OrderOpenPrice() > HedgeCloseProfitPips * Point)
               {
                  CloseHedgePosition(OP_SELL);
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
               else if(HasHedgePosition(OP_BUY) && OrderOpenPrice() - Ask > HedgeCloseProfitPips * Point)
               {
                  CloseHedgePosition(OP_BUY);
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

void OnTrade()
{
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(OrderCloseTime() > TimeCurrent() - 60)
            {
               if(OrderProfit() < 0)
               {
                  lastLoss = MathAbs(OrderProfit());
               }
               else
               {
                  currentMartingaleStep = 0;
                  lastLoss = 0.0;
               }
            }
         }
      }
   }
}