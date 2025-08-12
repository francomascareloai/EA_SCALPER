//+------------------------------------------------------------------+
//|                                News Trading Pending Order EA.mq4 |
//|                                                MD. Khairul Basar |
//|                              https://www.facebook.com/Omaanuushh |
//+------------------------------------------------------------------+
#property copyright "MD. Khairul Basar"
#property link      "https://www.facebook.com/Omaanuushh"
#property version   "1.6"
#property strict
//--- includes
#include <stderror.mqh>
#include <stdlib.mqh>
//--- enumerations
enum curr
  {
   EUR,
   GBP,
   USD,
   JPY
  };
//--- input parameters
input double   Lots                 =0.01;                  // Lot size
input double   TakeProfit           =0.0;                   // Take profit (Points)
input double   StopLoss             =5.0;                   // Stop loss (Points)
input double   StartDistance        =5.0;                   // Spacing from current price (Points)
input double   SpacingBetweenOrders =10.0;                  // Spacing between orders (Points)
input double   TrailingStop         =0.0;                   // Trailing Stop
input int      NumberOfOrders       =1;                     // Number of orders of each type
input int      ExpireMinutes        =5;                     // Order expiration time (Minutes)
input int      MagicNumber          =0;                     // Magic Number
input int      Slippage             =3;                     // Slippage
input string   Comments             ="";                    // Comment
input curr     NewsCurrency         =USD;                   // News impact currency
input bool     MajorsMinors         =True;                  // Open trade in majors and minors
input bool     ThisChart            =True;                  // Open trade in this chart symbol
input bool     BuyLimit             =True;                  // Open Buy Limit orders
input bool     SellLimit            =True;                  // Open Sell Limit orders
input bool     BuyStop              =True;                  // Open Buy Stop orders
input bool     SellStop             =True;                  // Open Sell Stop orders
//--- global declarations
void ProcessOrders(string str);
void CheckCurrencyPairs();
void SetTrailingStop();
void DeleteOrders();
int Max(int value1,int value2);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CheckCurrencyPairs();
   SetTrailingStop();
   DeleteOrders();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert Max function                                              |
//+------------------------------------------------------------------+
int Max(int value1,int value2)
  {
   if(value1>value2) return value1;
   else return value2;
  }
//+------------------------------------------------------------------+
//| Expert DeleteOrders function                                     |
//+------------------------------------------------------------------+
void DeleteOrders()
  {
   int i,Total,Type;
   bool Flag=True;
   datetime TimeEnd=TimeLocal()+5*60;

   while(Flag && TimeLocal()<=TimeEnd)
     {
      Flag=False;
      Total=OrdersTotal();
      for(i=0;i<Total;i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            Type=OrderType();
            if(Type!=OP_BUY && Type!=OP_SELL)
               if(OrderDelete(OrderTicket(),clrNONE)==false)
                  Flag=True;
           }
         else
            Flag=True;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert CheckCurrencyPairs function                               |
//+------------------------------------------------------------------+
void CheckCurrencyPairs()
  {

   string Pairs[]={"EUR","GBP","USD","JPY"};
   string CurrencySymbol;
   bool Flag=True;
   int i;
   if(MajorsMinors)
     {
      for(i=0;i<4;i++)
        {
         if(i==NewsCurrency) continue;
         if(i<NewsCurrency)
            CurrencySymbol=StringConcatenate(Pairs[i],EnumToString(NewsCurrency));
         else if(i>NewsCurrency)
            CurrencySymbol=StringConcatenate(EnumToString(NewsCurrency),Pairs[i]);

         ProcessOrders(CurrencySymbol);
         if(CurrencySymbol==Symbol())
            Flag=False;
        }
     }
   if(ThisChart && Flag)
      ProcessOrders(Symbol());

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert SetTrailingStop function                                  |
//+------------------------------------------------------------------+
void SetTrailingStop()
  {

   int i,Total,Type;
   double OpenPrice,MarketPrice,TSPrice,Points,Spread;
   string CurrencySymbol;
   datetime TimeEnd=TimeLocal()+Max(ExpireMinutes,15)*60;

   Total=OrdersTotal();
   while(TimeLocal()<=TimeEnd && Total>0)
     {
      if(TrailingStop==0.0) continue;
      Total=OrdersTotal();
      for(i=0;i<Total;i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {

            Type=OrderType();

            if(Type==OP_BUY)
              {
               OpenPrice=OrderOpenPrice();
               CurrencySymbol=OrderSymbol();
               Points=MarketInfo(CurrencySymbol,MODE_POINT);
               Spread=MarketInfo(CurrencySymbol,MODE_SPREAD);
               MarketPrice=MarketInfo(CurrencySymbol,MODE_ASK);
               TSPrice=OpenPrice+MathMax(MathCeil(TrailingStop),Spread)*Points;

               if(MarketPrice>TSPrice && OrderStopLoss()<TSPrice)
                  if(OrderModify(OrderTicket(),OpenPrice,TSPrice,OrderTakeProfit(),OrderExpiration(),clrNONE)==False)
                     Alert(ErrorDescription(GetLastError()));
              }
            else if(Type==OP_SELL)
              {
               OpenPrice=OrderOpenPrice();
               CurrencySymbol=OrderSymbol();
               Points=MarketInfo(CurrencySymbol,MODE_POINT);
               Spread=MarketInfo(CurrencySymbol,MODE_SPREAD);
               MarketPrice=MarketInfo(CurrencySymbol,MODE_BID);
               TSPrice=OpenPrice-MathMax(MathCeil(TrailingStop),Spread)*Points;

               if(MarketPrice<TSPrice && OrderStopLoss()>TSPrice)
                  if(OrderModify(OrderTicket(),OpenPrice,TSPrice,OrderTakeProfit(),OrderExpiration(),clrNONE)==False)
                     Alert(ErrorDescription(GetLastError()));
              }
           }
        }
     }
   if(TrailingStop>0.0) Alert("Trailing Stop Deactivated.");
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert ProcessOrders function                                    |
//+------------------------------------------------------------------+
void ProcessOrders(string str)
  {

   double Points=MarketInfo(str,MODE_POINT);
   double Spread=MarketInfo(str,MODE_SPREAD);
   double EntryDistance=MathMax(StartDistance,Spread);
   double BuyLimitPrice=MarketInfo(str,MODE_ASK)-MathCeil(EntryDistance)*Points;
   double BuyStopPrice=MarketInfo(str,MODE_ASK)+MathCeil(EntryDistance)*Points;
   double SellLimitPrice=MarketInfo(str,MODE_BID)+MathCeil(EntryDistance)*Points;
   double SellStopPrice=MarketInfo(str,MODE_BID)-MathCeil(EntryDistance)*Points;
   double SLPrice,TPPrice;
   datetime TimeNow;
   int i;

   for(i=0;i<NumberOfOrders;i++)
     {
      if(BuyLimit)
        {
         if(TakeProfit<=0.0)
           {
            TPPrice=0.0;
           }
         else
           {
            TPPrice=MathMax(TakeProfit,Spread);
            TPPrice=BuyLimitPrice+MathCeil(TPPrice)*Points;
           }

         if(StopLoss<=0.0)
           {
            SLPrice=0.0;
           }
         else
           {
            SLPrice=MathMax(StopLoss,Spread);
            SLPrice=BuyLimitPrice-MathCeil(SLPrice)*Points;
           }

         if(ExpireMinutes<=0) TimeNow=0;
         else TimeNow=TimeLocal()+ExpireMinutes*60;

         if(OrderSend(str,OP_BUYLIMIT,Lots,BuyLimitPrice,Slippage,SLPrice,TPPrice,Comments,MagicNumber,TimeNow,clrNONE)!=-1)
            BuyLimitPrice=BuyLimitPrice-SpacingBetweenOrders*Points;
         else
            Alert(ErrorDescription(GetLastError()));
        }
      if(BuyStop)
        {
         if(TakeProfit<=0.0)
           {
            TPPrice=0.0;
           }
         else
           {
            TPPrice=MathMax(TakeProfit,Spread);
            TPPrice=BuyStopPrice+MathCeil(TPPrice)*Points;
           }

         if(StopLoss<=0.0)
           {
            SLPrice=0.0;
           }
         else
           {
            SLPrice=MathMax(StopLoss,Spread);
            SLPrice=BuyStopPrice-MathCeil(SLPrice)*Points;
           }

         if(ExpireMinutes<=0) TimeNow=0;
         else TimeNow=TimeLocal()+ExpireMinutes*60;

         if(OrderSend(str,OP_BUYSTOP,Lots,BuyStopPrice,Slippage,SLPrice,TPPrice,Comments,MagicNumber,TimeNow,clrNONE)!=-1)
            BuyStopPrice=BuyStopPrice+SpacingBetweenOrders*Points;
         else
            Alert(ErrorDescription(GetLastError()));
        }
      if(SellLimit)
        {
         if(TakeProfit<=0.0)
           {
            TPPrice=0.0;
           }
         else
           {
            TPPrice=MathMax(TakeProfit,Spread);
            TPPrice=SellLimitPrice-MathCeil(TPPrice)*Points;
           }

         if(StopLoss<=0.0)
           {
            SLPrice=0.0;
           }
         else
           {
            SLPrice=MathMax(StopLoss,Spread);
            SLPrice=SellLimitPrice+MathCeil(SLPrice)*Points;
           }

         if(ExpireMinutes<=0) TimeNow=0;
         else TimeNow=TimeLocal()+ExpireMinutes*60;

         if(OrderSend(str,OP_SELLLIMIT,Lots,SellLimitPrice,Slippage,SLPrice,TPPrice,Comments,MagicNumber,TimeNow,clrNONE)!=-1)
            SellLimitPrice=SellLimitPrice+SpacingBetweenOrders*Points;
         else
            Alert(ErrorDescription(GetLastError()));
        }
      if(SellStop)
        {
         if(TakeProfit<=0.0)
           {
            TPPrice=0.0;
           }
         else
           {
            TPPrice=MathMax(TakeProfit,Spread);
            TPPrice=SellStopPrice-MathCeil(TPPrice)*Points;
           }

         if(StopLoss<=0.0)
           {
            SLPrice=0.0;
           }
         else
           {
            SLPrice=MathMax(StopLoss,Spread);
            SLPrice=SellStopPrice+MathCeil(SLPrice)*Points;
           }

         if(ExpireMinutes<=0) TimeNow=0;
         else TimeNow=TimeLocal()+ExpireMinutes*60;

         if(OrderSend(str,OP_SELLSTOP,Lots,SellStopPrice,Slippage,SLPrice,TPPrice,Comments,MagicNumber,TimeNow,clrNONE)!=-1)
            SellStopPrice=SellStopPrice-SpacingBetweenOrders*Points;
         else
            Alert(ErrorDescription(GetLastError()));
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

