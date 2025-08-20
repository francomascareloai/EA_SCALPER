//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property description "MGH System (Martingale Grid & Hedging) by Kfx"
#property description "http://www.forexfactory.com/showthread.php?t=497448"
#property description "EA autor: GoldenEA; some changes: SwingMan"
#property description "minor modifications proposed by Paracelsus #post 707"


#include <WinUser32.mqh>
//#include <stdlib.mqh>
#include <OrderSendReliable_v2.1.mqh>
//#include <OrderCloseReliable.mqh>
//
//--- input parameters
//+------------------------------------------------------------------+
input double   LotsMultiplier =2.5;
extern int     MaxLevel       =2;
extern double  BaseLot        = 0.10;
extern double  maxLot         =2;
extern int     MagicNo        = 2900;
extern   int   BasicOrder_Grid=10;
input double Basket_TakeProfit=6;
int  InsideOrder_Grid=5;
bool Enable_InsideOrders=false;
double  ClsPercnt      = 0.1;
//+------------------------------------------------------------------+
double OrderGap;
//+------------------------------------------------------------------+

string         TextDisplay;

static double  pt;
string         TradeComment="mghA";

int            numBuy,numSell,prevnumBuy,prevnumSell,numPenBuy,numPenSell;

double         maxBuyLots,maxSellLots,totalProfit,AllProfit,prevEquity=0,currEquity=0;

static double  lowestBuyPrice,highestSellPrice,lowestSellPrice,highestBuyPrice,lowestSellPrice2,highestBuyPrice2;
datetime       lastBuyTime,lastSellTime;
double         totalSellProfit,totalBuyProfit;
int            lastestOrderCloseType;

double         AveragePrice,TotalVolume;
bool           EAsuspended=false;
datetime       SuspenEATime=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   pt=Point;
   if(Digits==3 || Digits==5) pt=10*pt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   CountOrders();
   if(numBuy==0 && numSell==0)
     {
      prevEquity=AccountEquity();
      OrderGap=1.0*BasicOrder_Grid;
     }
   if(numBuy!=0 || numSell!=0) currEquity=AccountEquity();

   prevnumSell=numSell;
   prevnumBuy=numBuy;
   double tp=0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderTakeProfit()==0)
        {
         if(OrderType()==OP_SELL && numSell<=MaxLevel)
           {
            if(numSell==1) tp=lowestSellPrice -OrderGap *pt;
            if(numSell>1) tp=lowestSellPrice-2*pt;
            SetTakeProfit(OP_SELL,tp);
           }

         if(OrderType()==OP_BUY && numBuy<=MaxLevel)
           {
            if(numBuy==1) tp=highestBuyPrice+OrderGap *pt;
            if(numBuy>1) tp=highestBuyPrice+2*pt;
            SetTakeProfit(OP_BUY,tp);
           }

         if(Enable_InsideOrders)
           {
            if(OrderType()==OP_SELL && numSell>MaxLevel)
              {
               if(numSell<6) tp=highestSellPrice -OrderGap *pt;
               if(numSell==6) tp=highestSellPrice -2.0*OrderGap*pt;
               SetInsideTakeProfit(OP_SELL,tp);
              }

            if(OrderType()==OP_BUY && numBuy>MaxLevel)
              {
               if(numBuy<6) tp=lowestBuyPrice+OrderGap *pt;
               if(numBuy==6) tp=lowestBuyPrice+2.0*OrderGap*pt;
               SetInsideTakeProfit(OP_BUY,tp);
              }
           }
        }
     }

   double OpenProfit=totalBuyProfit+totalSellProfit;
//double maxLot=0;
//double maxProfit;

   TextDisplay="\n\n                                Open Buy: "+numBuy+" Open Sell: "+numSell+
               "\n                                Open Sell Profit: "+totalSellProfit+" Open Buy Profit: "+totalBuyProfit+
               "\n                                Open Profit: "+OpenProfit;

   TextDisplay=CheckReport()+TextDisplay;
   Comment(TextDisplay);
//  if((numBuy == MaxLevel && numSell == MaxLevel) && (currEquity-prevEquity)/prevEquity>= ClsPercnt) CloseOpenPairPositions();

  if(numBuy + numSell > 1 && OpenProfit>=Basket_TakeProfit) CloseOpenPairPositions();


   ManageOrders();
   if(Enable_InsideOrders)
      ManageInsideOrders();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlaceSingleOrder(string sym,int type,double lotsize,double price)
  {
   int ticket;
//int result;
   color cColor;
   if(type==OP_BUY) cColor=clrBlue; else
   if(type==OP_SELL) cColor=clrRed;

   lotsize=NormalizeDouble(lotsize,2);

   ticket=OrderSendReliable(sym,type,lotsize,price,0,0,0,TradeComment,MagicNo,0,cColor);
   
   //Print("");
   Print("  ###  Lot size: ",DoubleToStr(lotsize,2));
   Print("  ###  Grid size: ",DoubleToStr(OrderGap,0),"   numBuy= ",numBuy,"   numSell=",numSell);  
   
   //Print("");
   

   if(ticket>0 && type==OP_SELL)
     {
      while(prevnumSell==numSell)
        {
         CountOrders();
        }
      prevnumSell=numSell;
     }

   if(ticket>0 && type==OP_BUY)
     {
      while(prevnumBuy==numBuy)
        {
         CountOrders();
        }
      prevnumBuy=numBuy;
     }

   if(ticket<0)
     {
      // error handling: to be implemented
      int e=GetLastError();
      Print("Error: "+DoubleToStr(e,0));
     }
// }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountOrders()
  {
   numBuy=0; numSell=0; maxBuyLots=0; maxSellLots=0; totalSellProfit=0; totalBuyProfit=0;
   double buyProfit1=0; double buyProfit2=0; double sellProfit1=0; double sellProfit2=0;
   lowestBuyPrice=9999; highestSellPrice=0; lowestSellPrice=9999; highestBuyPrice=0;lowestSellPrice2=9999; highestBuyPrice2=0;
   bool bRes;
   for(int cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {
      bRes=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            numBuy++;
            buyProfit1+=OrderProfit()+OrderSwap()+OrderCommission();
            if(OrderOpenPrice()<lowestBuyPrice)
              {
               lowestBuyPrice=OrderOpenPrice();
               lastBuyTime=OrderOpenTime();
              }
            if(OrderOpenPrice()>highestBuyPrice)
              { highestBuyPrice=OrderOpenPrice();}

            //   totalBuyProfit += OrderProfit();
            if(OrderLots()>maxBuyLots) maxBuyLots=OrderLots();
           }
         else if(OrderType()==OP_SELL)
           {
            numSell++;
            sellProfit1+=OrderProfit()+OrderSwap()+OrderCommission();
            if(OrderOpenPrice()>highestSellPrice)
              {
               highestSellPrice=OrderOpenPrice();
               lastSellTime=OrderOpenTime();
              }
            if(OrderOpenPrice()<lowestSellPrice)
              { lowestSellPrice=OrderOpenPrice();}

            //    totalSellProfit += OrderProfit();
            if(OrderLots()>maxSellLots) maxSellLots=OrderLots();
           }

         //

         totalBuyProfit=buyProfit1;
         totalSellProfit=sellProfit1;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  SetTakeProfit(int type,double tp)
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      //        if ( OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol()  && OrderMagicNumber()==Magic && OrderType()==type ) ModifySelectedOrder(type, TP);
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()==type)
         ModifySelectedOrder(type,tp);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOpenPairPositions()
  {
   bool bRes;
   for(int i=10; i>=0; i--)
     {
      for(int cnt=OrdersTotal()-1; cnt>=0; cnt--)
        {
         bRes=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderMagicNumber()==MagicNo)
           {
            if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
               OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5);
            else
            if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
               OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifySelectedOrder(int type,double tp)
  {
   bool ok=OrderModifyReliable(OrderTicket(),OrderOpenPrice(),0,tp,0);
   if(!ok)
     {
      int err=GetLastError();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Punto(string symbol)
  {
   if(StringFind(symbol,"JPY")>=0)
     {
      return(0.01);
        } else {
      return(0.0001);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SPREAD()
  {
   double this=(Ask-Bid)/Punto(Symbol());
   return(this);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageOrders()
  {
   CountOrders();

//      double OrderGap=10;
   double Lots=0;

//      {
   if(numBuy==0 && numSell==0 && iClose(Symbol(),PERIOD_D1,1)>iClose(Symbol(),PERIOD_D1,2))
     {
      RefreshRates();
      PlaceSingleOrder(Symbol(),OP_BUY,BaseLot,Ask);
     }

   if(numBuy>0 && numSell==0 && Ask<=(lowestBuyPrice-OrderGap*pt) && numBuy<MaxLevel)
     {
      RefreshRates();
      // SetStopLoss(OP_SELL);
      //  if (numBuy <=5) PlaceSingleOrder(Symbol(), OP_SELL, Lots, Bid);
      //  if (numBuy >5)  PlaceSingleOrder(Symbol(), OP_SELL, 2*BaseLot, Bid);
      PlaceSingleOrder(Symbol(),OP_BUY,BaseLot,Ask);
     }

// double lot   }

   if(numBuy==0 && numSell>=MaxLevel && Ask>(highestSellPrice+OrderGap*pt))
     {
      RefreshRates();
      Lots=LotsMultiplier*maxSellLots;
      Lots=NormalizeDouble(Lots,2);
      if(Lots>maxLot) Lots=maxLot;
      PlaceSingleOrder(Symbol(),OP_BUY,Lots,Ask);
     }

   if(numBuy>0 && numSell>=MaxLevel && Ask<=(lowestBuyPrice-OrderGap*pt) && numBuy<MaxLevel)
     {
      RefreshRates();
      // SetStopLoss(OP_SELL);
      //  if (numBuy <=5) PlaceSingleOrder(Symbol(), OP_SELL, Lots, Bid);
      //  if (numBuy >5)  PlaceSingleOrder(Symbol(), OP_SELL, 2*BaseLot, Bid);
      Lots=LotsMultiplier*maxSellLots;
      Lots=NormalizeDouble(Lots,2);
      if(Lots>maxLot) Lots=maxLot;
      PlaceSingleOrder(Symbol(),OP_BUY,Lots,Ask);
     }

   CountOrders();

   if(numBuy==0 && numSell==0 && iClose(Symbol(),PERIOD_D1,1)<=iClose(Symbol(),PERIOD_D1,2))
     {
      RefreshRates();
      PlaceSingleOrder(Symbol(),OP_SELL,BaseLot,Bid);
      //  RefreshRates();
      //   PlaceSingleOrder(HedgingPair, OP_BUY, Lots, MarketInfo(HedgingPair, MODE_BID));
     }

   if(numSell>0 && Bid>=(highestSellPrice+OrderGap*pt) && numBuy==0 && numSell<MaxLevel)
     {
      RefreshRates();
      // SetStopLoss(OP_BUY);
      //  if(numSell <=5) PlaceSingleOrder(Symbol(), OP_BUY, Lots, Ask);
      //  if(numSell >5) PlaceSingleOrder(Symbol(), OP_BUY, 2*BaseLot, Ask);
      PlaceSingleOrder(Symbol(),OP_SELL,BaseLot,Bid);
     }

// double lot

   if(numBuy>=MaxLevel && numSell==0 && Bid<(lowestBuyPrice-OrderGap*pt))
     {
      RefreshRates();
      Lots=LotsMultiplier*maxBuyLots;
      Lots=NormalizeDouble(Lots,2);
      if(Lots>maxLot) Lots=maxLot;
      PlaceSingleOrder(Symbol(),OP_SELL,Lots,Bid);
      //  RefreshRates();
      //   PlaceSingleOrder(HedgingPair, OP_BUY, Lots, MarketInfo(HedgingPair, MODE_BID));
     }

   if(numSell>0 && Bid>=(highestSellPrice+OrderGap*pt) && numBuy>=MaxLevel && numSell<MaxLevel)
     {
      RefreshRates();
      // SetStopLoss(OP_BUY);
      //  if(numSell <=5) PlaceSingleOrder(Symbol(), OP_BUY, Lots, Ask);
      //  if(numSell >5) PlaceSingleOrder(Symbol(), OP_BUY, 2*BaseLot, Ask);
      Lots=LotsMultiplier*maxBuyLots;
      Lots=NormalizeDouble(Lots,2);
      if(Lots>maxLot) Lots=maxLot;
      PlaceSingleOrder(Symbol(),OP_SELL,Lots,Bid);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CheckReport()
  {
   static string   ProfitReport="";
   static int   TimeToReport = 0;
   static int   TradeCounter = 0;
#define Daily    0
#define Weekly   1
#define Monthly  2
#define All      3

   if(TradeCounter!=HistoryTotal())
     {
      TradeCounter = HistoryTotal();
      TimeToReport = 0;
     }

   if(TimeLocal()>TimeToReport)
     {
      TimeToReport=TimeLocal()+300;
      double   Profit[10],Lots[10],Count[10];
      ArrayInitialize(Profit,0);
      ArrayInitialize(Lots,0.000001);
      ArrayInitialize(Count,0.000001);

      int Today     = TimeCurrent() - (TimeCurrent() % 86400);
      int ThisWeek  = Today - TimeDayOfWeek(Today)*86400;
      int ThisMonth = TimeMonth(TimeCurrent());
      for(int i=0; i<HistoryTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol()==Symbol() && OrderCloseTime()>0)
           {
            Count[All]+=1;
            Profit[All]+=OrderProfit()+OrderSwap();
            Lots[All]+=OrderLots();
            if(OrderCloseTime()>=Today)
              {
               Count[Daily]+=1;
               Profit[Daily]+=OrderProfit()+OrderSwap();
               Lots[Daily]+=OrderLots();
              }
            if(OrderCloseTime()>=ThisWeek)
              {
               Count[Weekly]+=1;
               Profit[Weekly]+=OrderProfit()+OrderSwap();
               Lots[Weekly]+=OrderLots();
              }
            if(TimeMonth(OrderCloseTime())==ThisMonth)
              {
               Count[Monthly]+=1;
               Profit[Monthly]+=OrderProfit()+OrderSwap();
               Lots[Monthly]+=OrderLots();
              }
           }
        }
      double OpenProfit=totalBuyProfit+totalSellProfit;

      ProfitReport="\n\n                                 PROFIT REPORT ( "+AccountCurrency()+" )"+
                   "\n                                Today: "+DoubleToStr(Profit[Daily],2)+
                   "\n                                This Week: "+DoubleToStr(Profit[Weekly],2)+
                   "\n                                This Month: "+DoubleToStr(Profit[Monthly],2)+
                   "\n                                All Profits: "+DoubleToStr(Profit[All],2)+
                   "\n                                All Trades: "+DoubleToStr(Count[All],0)+"  (Average "+DoubleToStr(Profit[All]/Count[All],2)+" per trade)"+
                   "\n                                All Lots: "+DoubleToStr(Lots[All],2)+"  (Average "+DoubleToStr(Profit[All]/Lots[All],2)+" per lot)";
     }
   return (ProfitReport);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageInsideOrders()
  {
   CountOrders();

   OrderGap=1.0*InsideOrder_Grid;   
   double Lots=0;

//   if(!SellOnly)
//      {
   if(numBuy>=MaxLevel && numSell>=MaxLevel && (lowestBuyPrice-highestSellPrice)>=40*pt)
     {
      RefreshRates();
      //             if(maxBuyLots > maxSellLots && Ask <=(lowestBuyPrice - (lowestBuyPrice - highestSellPrice)/3) && numBuy <6)
      if(maxBuyLots>maxSellLots && Ask<highestSellPrice && numBuy<6)
        {
         PlaceSingleOrder(Symbol(),OP_BUY,BaseLot,Ask);
        }

      //   if(maxBuyLots > maxSellLots && Bid >=( highestSellPrice + (lowestBuyPrice - highestSellPrice)/3) && numSell <6)
      if(maxBuyLots>maxSellLots && Bid>=highestBuyPrice && numSell<6)
        {
         PlaceSingleOrder(Symbol(),OP_SELL,maxSellLots,Bid);
        }

      if(maxBuyLots<maxSellLots && Ask<=(lowestBuyPrice -(lowestBuyPrice-highestSellPrice)/3) && numBuy<6)
        {
         PlaceSingleOrder(Symbol(),OP_BUY,maxBuyLots,Ask);
        }

      if(maxBuyLots<maxSellLots && Bid>=(highestSellPrice+(lowestBuyPrice-highestSellPrice)/3) && numSell<6)
        {
         PlaceSingleOrder(Symbol(),OP_SELL,BaseLot,Bid);
        }
     }

   if(numBuy>MaxLevel && numBuy<6 && Ask<=(lowestBuyPrice -(lowestBuyPrice-highestSellPrice)/3))
     {
      RefreshRates();
      if(maxBuyLots>maxSellLots)
        {
         PlaceSingleOrder(Symbol(),OP_BUY,BaseLot,Ask);
        }

      if(maxBuyLots<maxSellLots)
        {
         PlaceSingleOrder(Symbol(),OP_BUY,maxBuyLots,Ask);
        }
     }

   if(numSell>MaxLevel && numSell<6 && Bid>=(highestSellPrice+(lowestBuyPrice-highestSellPrice)/3))
     {
      RefreshRates();
      if(maxBuyLots>maxSellLots)
        {
         PlaceSingleOrder(Symbol(),OP_SELL,maxSellLots,Bid);
        }

      if(maxBuyLots<maxSellLots)
        {
         PlaceSingleOrder(Symbol(),OP_SELL,BaseLot,Bid);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  SetInsideTakeProfit(int type,double tp)
  {
   int   i;
   int   count=0;

   for(i=0; i<OrdersTotal(); i++)
     {
      //        if ( OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol()  && OrderMagicNumber()==Magic && OrderType()==type ) ModifySelectedOrder(type, TP);
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()==type && 
         (OrderTakeProfit()==0 || MathAbs(OrderTakeProfit()-tp)<20*pt))
         ModifySelectedOrder(type,tp);
     }
  }

//Check TP
