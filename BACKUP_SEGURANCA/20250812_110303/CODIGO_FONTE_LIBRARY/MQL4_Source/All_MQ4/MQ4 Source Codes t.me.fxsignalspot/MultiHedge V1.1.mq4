//+------------------------------------------------------------------+
//|                                              MultiHedge V1.1.mq4 |
//|                       Copyright 2015, MyLuckySoft Software Corp. |
//|                                      https://www.myluckysoft.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MyLuckySoft Software Corp."
#property link      "https://www.myluckysoft.com"
#property version   "1.10"
#property strict

#include <stdlib.mqh>

enum TrType { Buy=0, Sell=1 };

input double   Lots = 1;
input int      TargetPips = 10;
input int      Slippage = 3;
input int      Magic = 332255;
input int      CoolingTime = 5;
input string   Suffix = "";
input string   Pair1 = "AUDUSD";
input TrType   TradeType1 = Sell;
input string   Pair2 = "USDCAD";
input TrType   TradeType2 = Buy;
input string   Pair3 = "USDJPY";
input TrType   TradeType3 = Buy;

int TotalCount = 0;
int Slip;
bool CloseAll;
int DigFactor = 1;
datetime TradeStart;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Slip = Slippage;
   if (Digits == 3 || Digits == 5)
   {
      Slip = Slippage*10;
      DigFactor = 10;
   }
   CloseAll = false;
   TradeStart = TimeCurrent();
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   double BidPrice=0, AskPrice=0;
   double PipsProfit=0;
   double MyPoin;
   TotalCount = 0;
   for (int i=0; i<OrdersTotal(); i++)
   {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if (OrderMagicNumber() == Magic && (OrderSymbol() == Pair1+Suffix || OrderSymbol() == Pair2+Suffix || OrderSymbol() == Pair3+Suffix))
         {
            TotalCount++;
            BidPrice = MarketInfo(OrderSymbol(),MODE_BID);
            AskPrice = MarketInfo(OrderSymbol(),MODE_ASK);
            MyPoin = MarketInfo(OrderSymbol(),MODE_POINT)*DigFactor;
            if (OrderType() == OP_BUY)
            {
               PipsProfit += (BidPrice-OrderOpenPrice())/MyPoin;
            }
            if (OrderType() == OP_SELL)
            {
               PipsProfit += (OrderOpenPrice()-AskPrice)/MyPoin;
            }
         }
      }
   }
   if (PipsProfit > TargetPips)
   {
      CloseAll = true;
   }
   
   if (TotalCount == 0 && CloseAll)
   {
      CloseAll = false;
      TradeStart = TimeCurrent()+CoolingTime*60;
   }
   
   Comment("PipsProfit = ",DoubleToStr(PipsProfit,1),"\nCloseAll = ",CloseAll,"\nTotalCount = ",TotalCount);
   
   if (TotalCount == 0 && !CloseAll && TimeCurrent() > TradeStart)
   {
      int Tries;
      int Tiket1=-1, Tiket2=-1, Tiket3=-1;
      Tries = 0;
      while(Tiket1 == -1)
      {
         Tiket1 = SendOrder(Pair1+Suffix,TradeType1);
         if (Tiket1 == -1)
         {
            Sleep(500);
            Tries++;
         }
         if (Tries > 5)
         {
            Tiket1 = 1;
            Alert("Failed to send order for ",Pair2," after 5 tries. Error: ",ErrorDescription(GetLastError()));
         }
      }
      Tries = 0;
      while(Tiket2 == -1)
      {
         Tiket2 = SendOrder(Pair2+Suffix,TradeType2);
         if (Tiket2 == -1)
         {
            Sleep(500);
            Tries++;
         }
         if (Tries > 5)
         {
            Tiket2 = 1;
            Alert("Failed to send order for ",Pair2," after 5 tries. Error: ",ErrorDescription(GetLastError()));
         }
      }
      Tries = 0;
      while(Tiket3 == -1)
      {
         Tiket3 = SendOrder(Pair3+Suffix,TradeType3);
         if (Tiket3 == -1)
         {
            Sleep(500);
            Tries++;
         }
         if (Tries > 5)
         {
            Tiket3 = 1;
            Alert("Failed to send order for ",Pair2," after 5 tries. Error: ",ErrorDescription(GetLastError()));
         }
      }
   }
   if (CloseAll) CloseAllTrades();
}
//+------------------------------------------------------------------+
int SendOrder(string Symb, int Type)
{
   int Tiket = -1;
   double price = 0;
   color warna = Gray;
   if (Type == OP_BUY)
   {
      price = MarketInfo(Symb,MODE_ASK);
      warna = Blue;
   }
   if (Type == OP_SELL)
   {
      price = MarketInfo(Symb,MODE_BID);
      warna = Red;
   }
   RefreshRates();
   Tiket = OrderSend(Symb,Type,Lots,price,Slip,0,0,NULL,Magic,0,warna);
   return Tiket;
}
//+------------------------------------------------------------------+
void CloseAllTrades()
{
   for (int i=0; i<OrdersTotal(); i++)
   {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if (OrderMagicNumber() == Magic && (OrderSymbol() == Pair1+Suffix || OrderSymbol() == Pair2+Suffix || OrderSymbol() == Pair3+Suffix))
         {
            if (OrderType() == OP_BUY)
            {
               bool Clsd = false;
               double price = MarketInfo(OrderSymbol(),MODE_BID);
               Clsd = OrderClose(OrderTicket(),OrderLots(),price,Slip,Blue);
            }
            if (OrderType() == OP_SELL)
            {
               bool Clsd = false;
               double price = MarketInfo(OrderSymbol(),MODE_ASK);
               Clsd = OrderClose(OrderTicket(),OrderLots(),price,Slip,Red);
            }
         }
      }
   }
}
//+------------------------------------------------------------------+