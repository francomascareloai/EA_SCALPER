//+------------------------------------------------------------------+
//|                                           ScalperEMAEASimple.mq4 |
//|                                         Copyright 2023, AlFa7961 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <stderror.mqh>
#include <stdlib.mqh>

#property copyright "2023, AlFa7961"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

enum Strategy { SCALPEREMAs };
enum HedgeStrategy { ProTrend, ContraTrend };
enum HedgeCloseStrategy { CloseASAP, TrailingStop };

input int MAGICMA = 3937;
input double lotSize = 0.01; // Lot size for the orders
input int periodEMAFast = 39;
input int periodEMASlow = 740;
input Strategy strategy = SCALPEREMAs;
/*input*/ int stochasticK = 5;
/*input*/ int stochasticD = 5;
/*input*/ int stochasticSlowing = 5;
/*input*/ double overboughtLevel = 80;
/*input*/ double oversoldLevel = 20;
input HedgeStrategy hedgeStrategy = ProTrend;
input HedgeCloseStrategy hedgeCloseStrategy = TrailingStop;
input int distance = 10;
input int stopLossDeltaPoints = 50;
input int takeProfitActivationPoints = 10;
input int trailingStopDeltaPoints = 840;
input int maxOpenBuyOrders = 1;
input int maxOpenSellOrders = 1;
input bool AllOrders = false;

enum BarColor { GREEN_BAR, RED_BAR };
int maxBarsBack = 100;

// Indicator buffers (replicating indicator's buffers)
double buySignalBuffer[];
double sellSignalBuffer[];
double barSizeBuffer[];
double distanceFromEmaBuffer[];
double retracementIndexBuffer[];
double stochasticIndexBuffer[];
double breakEMAFastIndexBuffer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(buySignalBuffer,  2*maxBarsBack);
   ArrayResize(sellSignalBuffer,  2*maxBarsBack);
   ArrayResize(barSizeBuffer,  2*maxBarsBack);
   ArrayResize(distanceFromEmaBuffer,  2*maxBarsBack);
   ArrayResize(retracementIndexBuffer, 2*maxBarsBack);
   ArrayResize(stochasticIndexBuffer, 2*maxBarsBack);
   ArrayResize(breakEMAFastIndexBuffer,   2*maxBarsBack);

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Place your deinitialization code here
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
datetime lastBarTime = 0; // Store the opening time of the last bar
datetime lastTrailingUpdateTime = 0; // Store the time of the last trailing stop update
int trailingStopIntervalMinutes = 5; // The minimum interval between trailing stop updates in minutes

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentBarTime = Time[0]; // Get the opening time of the current bar

// Check if a new bar has opened
   if(currentBarTime != lastBarTime)
     {
      lastBarTime = currentBarTime; // Update the last bar's opening time

      // Calculate the EMA value at Slow periods
      double emaSlowValue = iMA(Symbol(), 0, periodEMASlow, 0, MODE_EMA, PRICE_CLOSE, 1);

      // Get the signals from the indicator buffers
      double buySignal = 0.0;
      double sellSignal = 0.0;
      if(strategy == SCALPEREMAs)
        {
         ScalperEMAStrategy();
        }

      buySignal = buySignalBuffer[1];
      sellSignal = sellSignalBuffer[1];

      // Check for open orders
      int totalOrders = OrdersTotal();
      int hasBuyOrder = 0;
      int hasSellOrder = 0;

      for(int i = 0; i < totalOrders; i++)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == Symbol())
              {
               if(!AllOrders && OrderMagicNumber()!=MAGICMA)
                 {
                  continue;
                 }
               if(OrderType() == OP_BUY)
                 {
                  hasBuyOrder++;
                 }
               else
                  if(OrderType() == OP_SELL)
                    {
                     hasSellOrder++;
                    }
              }
           }
        }

      int ticket = 0;
      // Check if a BUY signal is present
      if(buySignal == 1.0 && hasBuyOrder < maxOpenBuyOrders && hasSellOrder < maxOpenSellOrders)
        {
         if(CanOpenOrder(OP_BUY))
           {
            ticket = OpenBuyOrder();
           }
        }

      // Check if a SELL signal is present
      if(sellSignal == 1.0 && hasBuyOrder < maxOpenBuyOrders && hasSellOrder < maxOpenSellOrders)
        {
         if(CanOpenOrder(OP_SELL))
           {
            ticket = OpenSellOrder();
           }
        }
     }

// Check if enough time has passed to update the trailing stop
   if(TimeCurrent() - lastTrailingUpdateTime >= trailingStopIntervalMinutes * 60)
     {
      SetTrailingStop();
      // SetTrailingStopEMADynamic(trailingStopDeltaPoints, trailingStopBreakEvenPoints);
      lastTrailingUpdateTime = TimeCurrent(); // Update the last trailing stop update time
     }
  }

//+------------------------------------------------------------------+
void SetTrailingStop()
  {
   ResetLastError();
   int totalOrders = OrdersTotal();

   double currentProfit = AccountEquity() - AccountBalance();
   double newStopLossBuy = 0.0;
   double newStopLossSell = 0.0;

   if(hedgeCloseStrategy == TrailingStop || totalOrders == 1)
     {
      for(int i = 0; i < totalOrders; i++)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == Symbol())
              {
               if(!AllOrders && OrderMagicNumber()!=MAGICMA)
                 {
                  continue;
                 }
               if(OrderType() == OP_BUY)
                 {
                  if(Bid > OrderOpenPrice() + takeProfitActivationPoints * Point)
                    {
                     newStopLossBuy = CheckStopLoss(Bid + trailingStopDeltaPoints, OP_BUY);
                     // Print("Activation @: ", newStopLossBuy);
                    }
                  if((OrderStopLoss() == 0 && newStopLossBuy > 0) || (newStopLossBuy > 0 && newStopLossBuy > OrderStopLoss()))
                     if(OrderModify(OrderTicket(), 0, newStopLossBuy, OrderTakeProfit(), 0, clrNONE))
                       {
                        Print("OK modifying BUY order ticket", OrderTicket(), "!");
                       }
                     else
                       {
                        int error = GetLastError();
                        if(error == 1)
                          {
                           Print("Error 1 (ERR_NO_RESULT) while modifying BUY order. Details:");
                           Print("Details: ", ErrorDescription(error));
                           Print("Order Type: OP_BUY");
                           Print("Stop Loss: ", newStopLossBuy);
                           Print("Take Profit: ", OrderTakeProfit());
                          }
                        if(error == 130)
                          {
                           Print("Error 130 (ERR_INVALID_STOPS) while modifying BUY order. Details:");
                           Print("Details: ", ErrorDescription(error));
                           Print("Order Type: OP_BUY");
                           Print("Stop Loss: ", newStopLossBuy);
                           Print("Take Profit: ", OrderTakeProfit());
                          }
                        else
                          {
                           Print("Error modifying BUY order. Error code: ", error, " - ", ErrorDescription(error));
                          }
                       }
                 }
               else
                  if(OrderType() == OP_SELL)
                    {
                     if(Ask < OrderOpenPrice() - takeProfitActivationPoints * Point)
                       {
                        newStopLossSell = CheckStopLoss(Ask - trailingStopDeltaPoints, OP_SELL);
                        // Print("Activation @: ", newStopLossSell);
                       }
                     if((OrderStopLoss() == 0 && newStopLossSell > 0) || (newStopLossSell > 0 && newStopLossSell < OrderStopLoss()))
                        if(OrderModify(OrderTicket(), 0, newStopLossSell, OrderTakeProfit(), 0, clrNONE))
                          {
                           Print("OK modifying SELL order ticket", OrderTicket(), "!");
                          }
                        else
                          {
                           int error = GetLastError();
                           if(error == 1)
                             {
                              Print("Error 1 (ERR_NO_RESULT) while modifying SELL order. Details:");
                              Print("Details: ", ErrorDescription(error));
                              Print("Order Type: OP_SELL");
                              Print("Stop Loss: ", newStopLossSell);
                              Print("Take Profit: ", OrderTakeProfit());
                             }
                           if(error == 130)
                             {
                              Print("Error 130 (ERR_INVALID_STOPS) while modifying SELL order. Details:");
                              Print("Details: ", ErrorDescription(error));
                              Print("Order Type: OP_SELL");
                              Print("Stop Loss: ", newStopLossSell);
                              Print("Take Profit: ", OrderTakeProfit());
                             }
                           else
                             {
                              Print("Error modifying SELL order. Error code: ", error, " - ", ErrorDescription(error));
                             }
                          }
                    }
              }
           }
        }
     }
   else
      if(currentProfit > 0)
        {
         for(int i = 0; i < totalOrders; i++)
           {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              {
               if(OrderSymbol() == Symbol())
                 {
                  if(!AllOrders && OrderMagicNumber()!=MAGICMA)
                    {
                     continue;
                    }
                  // Retry order closure with adjusted price if requote occurs
                  RefreshRates();
                  // Select the correct price.
                  double orderClosePrice = OrderClosePrice();
                  if(OrderType() == OP_BUY)
                     orderClosePrice = Bid;
                  else
                     if(OrderType() == OP_SELL)
                        orderClosePrice = Ask;
                  for(int retryCount = 0; retryCount < 3; retryCount++)
                    {
                     bool result = OrderClose(OrderTicket(), OrderLots(), orderClosePrice, 2, clrNONE);

                     if(result)
                       {
                        Print("Order closed successfully: ", OrderType(), " ", OrderLots(), " lots at price ", orderClosePrice);
                        break;
                       }
                     else
                       {
                        if(GetLastError() == 138)  // Requote error
                          {
                           orderClosePrice = MarketInfo(OrderSymbol(), MODE_BID) + MarketInfo(OrderSymbol(), MODE_POINT) * retryCount;
                           Sleep(1000); // Wait for a second before retrying
                          }
                        else
                          {
                           Print("Error closing order: ", GetLastError());
                           break;
                          }
                       }
                    }
                 }
              }
           }
        }

   RefreshRates();
   if(hedgeStrategy == ProTrend)
     {
      double Buys = CountBuys();
      double Sells = CountSells();

      if(Buys - Ask >= distance * Point)
         if(CanOpenOrder(OP_BUY))
           {
            OpenBuyOrder();
           }

      if(Bid - Sells >= distance * Point)
         if(CanOpenOrder(OP_SELL))
           {
            OpenSellOrder();
           }
     }
   if(hedgeStrategy == ContraTrend)
     {
      int lastOrderType = 0;
      double lastOrderOpenPrice = 0;
      double lastOrderLots = 0;
      GetLastOrderTypeAndOpenPrice(lastOrderType, lastOrderOpenPrice, lastOrderLots);
      if(lastOrderOpenPrice > 0 && lastOrderLots > 0)
        {
         if(lastOrderType == OP_BUY && lastOrderOpenPrice - Ask >= distance * Point)
           {
            if(totalOrders == 1)
              {
               if(CanOpenOrder(OP_SELL))
                 {
                  OpenSellOrder();
                 }
              }
            else
               if(CanOpenOrder(OP_BUY))
                 {
                  OpenBuyOrder();
                 }
           }
         if(lastOrderType == OP_SELL && Bid - lastOrderOpenPrice >= distance * Point)
           {
            if(totalOrders == 1)
              {
               if(CanOpenOrder(OP_BUY))
                 {
                  OpenBuyOrder();
                 }
              }
            else
               if(CanOpenOrder(OP_SELL))
                 {
                  OpenSellOrder();
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+
double CountBuys()
  {
   double orderOpenPrice = Ask;
   int ticket_8 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
         if(!AllOrders && OrderMagicNumber()!=MAGICMA)
            continue;
      if(OrderSymbol() == Symbol() && OrderType() == OP_BUY)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            orderOpenPrice = OrderOpenPrice();
            ticket_20 = ticket_8;
           }
        }
     }
   return (orderOpenPrice);
  }
//+------------------------------------------------------------------+
double CountSells()
  {
   double orderOpenPrice = Bid;
   int ticket_8 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
         if(!AllOrders && OrderMagicNumber()!=MAGICMA)
            continue;
      if(OrderSymbol() == Symbol() && OrderType() == OP_SELL)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            orderOpenPrice = OrderOpenPrice();
            ticket_20 = ticket_8;
           }
        }
     }
   return (orderOpenPrice);
  }
//+------------------------------------------------------------------+
void GetLastOrderTypeAndOpenPrice(int& type, double& orderOpenPrice, double& orderLots)
  {
   int ticket_8 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      if(OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
         if(!AllOrders && OrderMagicNumber()!=MAGICMA)
            continue;
      if(OrderSymbol() == Symbol())
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            type = OrderType();
            orderOpenPrice = OrderOpenPrice();
            orderLots = OrderLots();
            ticket_20 = ticket_8;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description)
  {

   if(AccountBalance() < 10)
     {
      Comment("minimum balances is $10");
      return(false);
     }

//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots, int type)
  {
   double free_margin = AccountFreeMarginCheck(symb, type, lots);
//-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }

//+------------------------------------------------------------------+
double CheckLotSize()
  {
   double minLotSize = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLotSize = MarketInfo(Symbol(), MODE_MAXLOT);

   if(lotSize < minLotSize)
     {
      Print("Warning: Lot size is too small. Minimum lot size for ", Symbol(), " is ", minLotSize);
      return minLotSize;
     }
   else
      if(lotSize > maxLotSize)
        {
         Print("Warning: Lot size is too large. Maximum lot size for ", Symbol(), " is ", maxLotSize);
         return maxLotSize;
        }

// Lot size is within the valid range
   return lotSize;
  }

//+------------------------------------------------------------------+
int OpenBuyOrder()
  {
   ResetLastError();
   double lotSizeToUse = CheckLotSize();
   int ticket = OrderSend(Symbol(), OP_BUY, lotSizeToUse, Ask, 2, 0, 0, "", MAGICMA, clrNONE);
   if(ticket <= 0)
     {
      Print("Failed to send BUY order: Error ", ErrorDescription(GetLastError()));
     }
   double emaSlow = iMA(NULL, 0, periodEMAFast, 0, MODE_EMA, PRICE_CLOSE, 0);
   double distanceFromEMA = Ask - emaSlow + MarketInfo(Symbol(), MODE_SPREAD) * Point;
   double stopLoss = (stopLossDeltaPoints == 0.0 ? 0.0 : CheckStopLoss(Ask - stopLossDeltaPoints * Point - distanceFromEMA, OP_BUY));
   double takeProfit = 0.0; //NormalizeDouble(Bid + takeProfitPoints * Point, Digits);

   if(stopLoss > 0)
      if(OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrNONE))
        {
         Print("OK modifying BUY order ticket", OrderTicket(), "!");
        }
      else
        {
         int error = GetLastError();
         if(error == 1)
           {
            Print("Error 1 (ERR_NO_RESULT) while modifying BUY order. Details:");
            Print("Details: ", ErrorDescription(error));
            Print("Order Type: OP_BUY");
            Print("Stop Loss: ", stopLoss);
            Print("Take Profit: ", takeProfit);
           }
         if(error == 130)
           {
            Print("Error 130 (ERR_INVALID_STOPS) while modifying BUY order. Details:");
            Print("Details: ", ErrorDescription(error));
            Print("Order Type: OP_BUY");
            Print("Stop Loss: ", stopLoss);
            Print("Take Profit: ", takeProfit);
           }
         else
           {
            Print("Error modifying BUY order. Error code: ", error, " - ", ErrorDescription(error));
           }
        }

   return ticket;
  }

//+------------------------------------------------------------------+
int OpenSellOrder()
  {
   ResetLastError();
   double lotSizeToUse = CheckLotSize();
   int ticket = OrderSend(Symbol(), OP_SELL, lotSizeToUse, Bid, 2, 0, 0, "", MAGICMA, clrNONE);
   if(ticket <= 0)
     {
      Print("Failed to send SELL order: Error ", ErrorDescription(GetLastError()));
     }
   double emaSlow = iMA(NULL, 0, periodEMASlow, 0, MODE_EMA, PRICE_CLOSE, 0);
   double distanceFromEMA = emaSlow - Bid - MarketInfo(Symbol(), MODE_SPREAD) * Point;
   double stopLoss = (stopLossDeltaPoints == 0.0 ? 0.0 : CheckStopLoss(Bid + stopLossDeltaPoints * Point + distanceFromEMA, OP_SELL));
   double takeProfit = 0.0; //NormalizeDouble(Ask - takeProfitPoints * Point, Digits);

   if(stopLoss > 0)
      if(OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrNONE))
        {
         Print("OK modifying SELL order ticket", OrderTicket(), "!");
        }
      else
        {
         int error = GetLastError();
         if(error == 1)
           {
            Print("Error 1 (ERR_NO_RESULT) while modifying SELL order. Details:");
            Print("Details: ", ErrorDescription(error));
            Print("Order Type: OP_SELL");
            Print("Stop Loss: ", stopLoss);
            Print("Take Profit: ", takeProfit);
           }
         if(error == 130)
           {
            Print("Error 130 (ERR_INVALID_STOPS) while modifying SELL order. Details:");
            Print("Details: ", ErrorDescription(error));
            Print("Order Type: OP_SELL");
            Print("Stop Loss: ", stopLoss);
            Print("Take Profit: ", takeProfit);
           }
         else
           {
            Print("Error modifying SELL order. Error code: ", error, " - ", ErrorDescription(error));
           }
        }

   return ticket;
  }

//+------------------------------------------------------------------+
double CheckStopLoss(double stopLoss, int orderType)
  {
   double minStopDistance = trailingStopDeltaPoints * Point + (MarketInfo(Symbol(), MODE_SPREAD) + MarketInfo(Symbol(), MODE_STOPLEVEL)) * Point;

   double _stopLoss = NormalizeDouble(stopLoss, Digits);
   switch(orderType)
     {
      case OP_BUY:
         _stopLoss = NormalizeDouble(MathMin(stopLoss, Ask - minStopDistance), Digits);
         break;
      case OP_SELL:
         _stopLoss = NormalizeDouble(MathMax(stopLoss, Bid + minStopDistance), Digits);
         break;
     }

   return _stopLoss;
  }

//+------------------------------------------------------------------+
bool CanOpenOrder(int orderType)
  {
// Add your conditions here to determine if it's suitable to open an order.
// For example, you can check additional trading criteria or risk management rules.

// Return true if the conditions are met.
   string description = "";
   if(CheckVolumeValue(CheckLotSize(), description) && CheckMoneyForTrade(Symbol(), CheckLotSize(), orderType))
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+
double GetDistanceFromEMA(double currentPrice, double emaSlow)
  {
   return MathAbs(currentPrice - emaSlow);
  }

//+------------------------------------------------------------------+
bool IsDistanceLowerThanNeighboringBars(double currentDistance, double& distances[])
  {
   for(int i = 0; i < 3; i++)
     {
      if(currentDistance >= distances[i])
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
bool IsDistanceLowerThanBarSize(double distanceFromEMAInPips, double barSizeInPips)
  {
   return distanceFromEMAInPips < barSizeInPips;
  }

//+------------------------------------------------------------------+
bool IsBreakEMAFastCondition(BarColor barColor, double openPrice, double closePrice, double emaFast)
  {
   if(barColor == GREEN_BAR)
     {
      return openPrice < emaFast && closePrice > emaFast;
     }
   else
      if(barColor == RED_BAR)
        {
         return openPrice > emaFast && closePrice < emaFast;
        }
   return false;
  }

//+------------------------------------------------------------------+
bool CrossesSignalFromAbove(double mainLine, double signalLine, double prevMainLine, double prevSignalLine)
  {
   if(prevMainLine >= 80 && mainLine <= 80)
     {
      return true;
     }
   return false;
  }


//+------------------------------------------------------------------+
bool CrossesSignalFromBelow(double mainLine, double signalLine, double prevMainLine, double prevSignalLine)
  {
   if(prevMainLine <= 20 && mainLine >= 20)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Signals                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Internal function to replicate indicator's logic                 |
//+------------------------------------------------------------------+
void ScalperEMAStrategy()
  {
   bool retracementCondition = false;
   bool breakEMAFastCondition = false;
   bool stochasticCondition = false;

   int lastBuySignalIndex = maxBarsBack;
   int lastSellSignalIndex = maxBarsBack;

   int retracementBarIndex = maxBarsBack;
   int breakEMAFastBarIndex = maxBarsBack;
   int stochasticBarIndex = maxBarsBack;

   for(int i = maxBarsBack - 1; i >= 0; i--)
     {
      buySignalBuffer[i] = 0.0;
      sellSignalBuffer[i] = 0.0;

      // Determine the color of the current bar
      BarColor currentBarColor = (iClose(NULL,0,i) > iOpen(NULL,0,i)) ? GREEN_BAR : RED_BAR;

      // Calculate EMAs
      double emaFast = iMA(NULL, 0, periodEMAFast, 0, MODE_EMA, PRICE_CLOSE, i);
      double emaSlow = iMA(NULL, 0, periodEMASlow, 0, MODE_EMA, PRICE_CLOSE, i);
      double emaFastPrev = iMA(NULL, 0, periodEMAFast, 0, MODE_EMA, PRICE_CLOSE, i+1);

      // Calculate Stochastic
      double stochasticMain = iStochastic(NULL, 0, stochasticK, stochasticD, stochasticSlowing, MODE_EMA, 0, MODE_MAIN, i);
      double stochasticSignal = iStochastic(NULL, 0, stochasticK, stochasticD, stochasticSlowing, MODE_EMA, 0, MODE_SIGNAL, i);
      double stochasticPrevMain = iStochastic(NULL, 0, stochasticK, stochasticD, stochasticSlowing, MODE_EMA, 0, MODE_MAIN, i+1);
      double stochasticPrevSignal = iStochastic(NULL, 0, stochasticK, stochasticD, stochasticSlowing, MODE_EMA, 0, MODE_SIGNAL, i+1);

      // Calculate ADX
      double adxLevel = 37.0;
      double adx      = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, i);
      double adxPrev  = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, i+1);
      double adxPrev2 = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, i+2);

      // Calculate the distance from the Slow EMA
      double distanceFromEMAPrice = iClose(NULL,0,i);
      if(iClose(NULL,0,i) > emaSlow)
         distanceFromEMAPrice = iLow(NULL,0,i);
      if(iClose(NULL,0,i) < emaSlow)
         distanceFromEMAPrice = iHigh(NULL,0,i);

      double distanceFromEMAInPips = GetDistanceFromEMA(distanceFromEMAPrice, emaSlow) / Point;

      // Calculate the bar size in pips
      double barSizeInPips = (iHigh(NULL,0,i) - iLow(NULL,0,i)) / Point;

      barSizeBuffer[i] = barSizeInPips;
      distanceFromEmaBuffer[i] = distanceFromEMAInPips;

      // Calculate distances of previous and next 3 bars
      double prevDistances[16];
      double nextDistances[16];
      if(i > 5)
        {
         for(int j = 1; j < 4; j++)
           {
            if(iClose(NULL,0,i) > emaSlow)
              {
               prevDistances[j - 1] = GetDistanceFromEMA(iLow(NULL,0,i - j - 1), emaSlow) / Point;
               nextDistances[j - 1] = GetDistanceFromEMA(iLow(NULL,0,i + j + 1), emaSlow) / Point;
              }
            if(iClose(NULL,0,i) < emaSlow)
              {
               prevDistances[j - 1] = GetDistanceFromEMA(iHigh(NULL,0,i - j - 1), emaSlow) / Point;
               nextDistances[j - 1] = GetDistanceFromEMA(iHigh(NULL,0,i + j + 1), emaSlow) / Point;
              }
           }
        }

      // Check if the current distance is lower than previous and next 3 bars
      bool isLowerThanNeighbors = IsDistanceLowerThanNeighboringBars(distanceFromEMAInPips, prevDistances) &&
                                  IsDistanceLowerThanNeighboringBars(distanceFromEMAInPips, nextDistances);

      // Check if the distanceFromEMA is lower than the bar size
      bool isLowerThanBarSize = IsDistanceLowerThanBarSize(distanceFromEMAInPips, barSizeInPips);

      if(isLowerThanNeighbors && isLowerThanBarSize)
        {
         retracementCondition = true;
         retracementBarIndex = i;
         retracementIndexBuffer[i] = i;
        }

      // BUY condition
      if(iOpen(NULL,0,i) > emaSlow && iClose(NULL,0,i) > emaSlow && emaFast > emaSlow)
        {

         // Check the break of EMA Fast condition
         breakEMAFastCondition = IsBreakEMAFastCondition(currentBarColor, iOpen(NULL,0,i), iClose(NULL,0,i), emaFast);
         if((currentBarColor == GREEN_BAR && breakEMAFastCondition) || (emaFastPrev < emaSlow && emaFast > emaSlow))
           {
            breakEMAFastBarIndex = i;
            breakEMAFastIndexBuffer[i] = i;
           }

         // Check Stochastic condition
         stochasticCondition = CrossesSignalFromBelow(stochasticMain, stochasticSignal, stochasticPrevMain, stochasticPrevSignal);
         if(stochasticCondition)
           {
            stochasticBarIndex = i;
            stochasticIndexBuffer[i] = i;
           }

         // Check retracement and break of Fast EMA
         if(
            adx < adxLevel &&
            ((lastBuySignalIndex - i) > 3 && (retracementBarIndex - i) <= 3 && (stochasticBarIndex - i) <= 3 && (breakEMAFastBarIndex - i) <= 3 && breakEMAFastBarIndex < retracementBarIndex)
         )
           {
            // Draw a green arrow for buy signal
            ObjectCreate("BuyArrow" + IntegerToString(i), OBJ_ARROW_UP, 0, Time[i], iLow(NULL,0,i) - Point * 10);
            ObjectSetInteger(0, "BuyArrow" + IntegerToString(i), OBJPROP_COLOR, clrGreen);
            buySignalBuffer[i] = 1; // Place a buy signal on the chart
            lastBuySignalIndex = i;
           }
        }
      // SELL condition
      else
         if(iOpen(NULL,0,i) < emaSlow && iClose(NULL,0,i) < emaSlow && emaFast < emaSlow) // Use "else if" to avoid conflicting conditions
           {

            // Check the break of EMA Fast condition
            breakEMAFastCondition = IsBreakEMAFastCondition(currentBarColor, iOpen(NULL,0,i), iClose(NULL,0,i), emaFast);
            if((currentBarColor == RED_BAR && breakEMAFastCondition) || (emaFastPrev > emaSlow && emaFast < emaSlow))
              {
               breakEMAFastBarIndex = i;
               breakEMAFastIndexBuffer[i] = i;
              }

            // Check Stochastic condition
            stochasticCondition = CrossesSignalFromAbove(stochasticMain, stochasticSignal, stochasticPrevMain, stochasticPrevSignal);
            if(stochasticCondition)
              {
               stochasticBarIndex = i;
               stochasticIndexBuffer[i] = i;
              }

            if(
               adx < adxLevel &&
               ((lastSellSignalIndex - i) > 3 && (retracementBarIndex - i) <= 3 && (stochasticBarIndex - i) <= 3 && (breakEMAFastBarIndex - i) <= 3 && breakEMAFastBarIndex < retracementBarIndex)
            )
              {
               // Draw a red arrow for sell signal
               ObjectCreate("SellArrow" + IntegerToString(i), OBJ_ARROW_DOWN, 0, Time[i], iHigh(NULL,0,i) + Point * 10);
               ObjectSetInteger(0, "SellArrow" + IntegerToString(i), OBJPROP_COLOR, clrRed);
               sellSignalBuffer[i] = 1; // Place a sell signal on the chart
               lastSellSignalIndex = i;
              }
           }
     }
  }
//+------------------------------------------------------------------+
