//+------------------------------------------------------------------+
//| H1 XAUUSD SIMPLE STRATEGY #7, 1K TESTED 2024-01-01...2025-03-29  |
//+------------------------------------------------------------------+
#property copyright "AGG2017"
#property link      "FreeWare"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                            Inputs                                |
//+------------------------------------------------------------------+
extern string  General        = "-----GENERAL SETIINGS----";
extern int     MagicNumber    = 1969; // Magic Number
extern bool    UseRisk        = false;// Use Account Based Lot Size?
input int      Risk           = 1;    // Percentage Risk
input double   Lots           = 0.05; // Lots per Risk
input double   FixedLot       = 0.05; // Fixed Lot Size
input int      MaxOrders      = 3;    // Max Orders
input int      SLoss          = 3000; // SL in pips
input int      TProfit        = 3000; // TP in pips

extern string  MA             = "-----TA SETIINGS----";
extern int     BBPeriod       = 30;
extern double  BBDeviation    = 2.0;
extern int     MAPeriod       = 28;
extern int     RSIPeriod      = 28;
extern int     RSIUpperLevel  = 70;
extern int     RSILowerLevel  = 40;
extern int     BarOffset      = 1;
extern int     BarsSqueeze    = 5;
extern bool    UseCCI         = false;
extern int     CCIPeriod      = 14;
extern int     CCIUpperLevel  = 100;
extern int     CCILowerLevel  = -100;
extern ENUM_APPLIED_PRICE     AppliedPrice   = PRICE_CLOSE;

//+------------------------------------------------------------------+
//|                        Global Variables                          |
//+------------------------------------------------------------------+
double bb_upper[100];
double bb_lower[100];

//+------------------------------------------------------------------+
//|                        Expert function                           |
//+------------------------------------------------------------------+
void OnTick() {
   if(Bars < BBPeriod) return;
   if(Bars < MAPeriod) return;
   if(Bars < RSIPeriod) return;
   if(Bars < CCIPeriod) return;
   if(Bars < BarOffset) return;
   double UpperBBand = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, AppliedPrice, MODE_UPPER, BarOffset);
   double LowerBBand = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, AppliedPrice, MODE_LOWER, BarOffset);
   double myMA = iMA(_Symbol, _Period, MAPeriod, 0, MODE_SMA, AppliedPrice, BarOffset);
   double myRSI = iRSI(_Symbol, _Period, RSIPeriod, AppliedPrice, BarOffset);
   double myCCI;
   if(Open[BarOffset] < UpperBBand && Close[BarOffset] > UpperBBand && myRSI > RSIUpperLevel && OrdersTotal() < MaxOrders && CheckOpenOrders() < 1 && NewBar() && !IsNarrower()) {
      if(UseCCI) {
         myCCI = iCCI(_Symbol, _Period, CCIPeriod, AppliedPrice, BarOffset);
         if(myCCI > CCIUpperLevel) {
            OpenSellTrade();
         }
      } else {
         OpenSellTrade();
      }
   }
   if(Open[BarOffset] > LowerBBand && Close[BarOffset] < LowerBBand && myRSI < RSILowerLevel && OrdersTotal() < MaxOrders && CheckOpenOrders() < 1 && NewBar() && !IsNarrower()) {
      if(UseCCI) {
         myCCI = iCCI(_Symbol, _Period, CCIPeriod, AppliedPrice, BarOffset);
         if(myCCI > CCIUpperLevel) {
            OpenBuyTrade();
         }
      } else {
         OpenBuyTrade();
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseMyBuyTrades() {
   int ret;
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      ret = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      string CurrencyPair = OrderSymbol();
      if(_Symbol == CurrencyPair)
         if(OrderMagicNumber() == MagicNumber)
            if(OrderType() == OP_BUY) {
               int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
               double bid_n = NormalizeDouble(Bid, digits);
               ret = OrderClose(OrderTicket(), OrderLots(), bid_n, 3, NULL);
            }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseMySellTrades() {
   int ret;
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      ret = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      string CurrencyPair = OrderSymbol();
      if(_Symbol == CurrencyPair)
         if(OrderMagicNumber() == MagicNumber)
            if(OrderType() == OP_SELL) {
               int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
               double ask_n = NormalizeDouble(Ask, digits);
               ret = OrderClose(OrderTicket(), OrderLots(), ask_n, 3, NULL);
            }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuyTrade() {
   double pp = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   double ask_n = NormalizeDouble(Ask, digits);
   double sl_n = NormalizeDouble(Ask - SLoss * _Point, digits);
   double tp_n = NormalizeDouble(Ask + TProfit * _Point, digits);
   double LotSize = (Risk * AccountEquity() / 100) * Lots;
   if(UseRisk == true) {
      int ret = OrderSend(_Symbol, OP_BUY, LotSize, ask_n, 3, 0, 0, NULL, MagicNumber, 0, Green);
   } else {
      int ret = OrderSend(_Symbol, OP_BUY, FixedLot, ask_n, 3, sl_n, tp_n, NULL, MagicNumber, 0, Green);
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSellTrade() {
   double pp = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   double bid_n = NormalizeDouble(Bid, digits);
   double sl_n = NormalizeDouble(Bid + SLoss * _Point, digits);
   double tp_n = NormalizeDouble(Bid - TProfit * _Point, digits);
   double LotSize = (Risk * AccountEquity() / 100) * Lots;
   if(UseRisk == true) {
      int ret = OrderSend(_Symbol, OP_SELL, LotSize, bid_n, 3, 0, 0, NULL, MagicNumber, 0, Red);
   } else {
      int ret = OrderSend(_Symbol, OP_SELL, FixedLot, bid_n, 3, sl_n, tp_n, NULL, MagicNumber, 0, Red);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckOpenOrders() {
   int openOrders = OrdersTotal();
   for(int i = 0; i < openOrders; i++) {
      if(OrderSelect(i, SELECT_BY_POS) == true) {
         if(OrderOpenTime() >= Time[0]) {
            return true;
         }
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar() {
   static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar != curbar) {
      lastbar = curbar;
      return (true);
   } else {
      return(false);
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNarrower() {
   int n = BarsSqueeze >> 1;
   if(n > 100) n = 100;
   int nn = n << 1;
   for(int i = 0; i < nn; i++) {
      bb_upper[i] = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, AppliedPrice, MODE_UPPER, i + 1);
      bb_lower[i] = iBands(_Symbol, _Period, BBPeriod, BBDeviation, 0, AppliedPrice, MODE_LOWER, i + 1);
   }
   for(int ij = 0; ij < n; ij++) {
      if((bb_upper[ij] - bb_lower[ij]) >= (bb_upper[ij + n] - bb_lower[ij + n])) {
         return(false);
      }
   }
   return(true);
}
