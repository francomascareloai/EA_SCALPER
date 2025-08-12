#property copyright "Copyright © 2006, maloma"
#include <stdlib.mqh>
#include <stderror.mqh>

extern double Lots         = 0.1;
extern int    StopLoss     = 0;
extern int    TakeProfit   = 0;
extern int    MinProfit    = 20;
extern int    ClosePercent = 80;
extern int    FirstStep    = 10;
extern int    NextStep     = 10;
extern int    OneSideSteps = 7;
       int    Magic        = 1234321;
       int    Slippage     = 3;
       double MaxProfit    = 0;
       double CurProfit    = 0;
       double CloseLevel;
       int    i,j;
       int    bc,sc,bsc,ssc;
       string S;
       double P,Spread,SL,TP,FS,NS;

void init()
{
 S=Symbol();
 P=MarketInfo(S,MODE_POINT);
 Spread=MarketInfo(S,MODE_SPREAD)*P;
 SL=StopLoss*P;
 TP=TakeProfit*P;
 FS=FirstStep*P;
 NS=NextStep*P;
 CloseLevel=NormalizeDouble(MinProfit*ClosePercent/100,2);
 return(0);
}

void CheckOrders()
{
 bc=0;
 sc=0;
 bsc=0;
 ssc=0;
 j=OrdersTotal();
 for (i=0;i<j;i++)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   string OS=OrderSymbol();
   int OMN=OrderMagicNumber();
   int OT=OrderType();
   if (OS==S && OMN==Magic && OT==OP_BUY) bc++;
   if (OS==S && OMN==Magic && OT==OP_SELL) sc++;
   if (OS==S && OMN==Magic && OT==OP_BUYSTOP) bsc++;
   if (OS==S && OMN==Magic && OT==OP_SELLSTOP) ssc++;
  }
// Print("BC=",bc);Print("SC=",sc);Print("BSC=",bsc);Print("SSC=",ssc);
 return(0);
}

void OpenOrders()
{
 MaxProfit    = 0;
 CurProfit    = 0;
 double _Bid=MarketInfo(S,MODE_BID);
 double _Ask=_Bid+Spread;
 double BuyPrice=_Ask+FS;
 double SellPrice=_Bid-FS;
 if (SL!=0)
  {double BSL=BuyPrice-SL; double SSL=SellPrice+SL;} else {BSL=0; SSL=0;}
 if (TP!=0)
  {double BTP=BuyPrice+TP; double STP=SellPrice-TP;} else {BTP=0; STP=0;}
 OrderSend(S,OP_BUYSTOP,Lots,BuyPrice,Slippage,BSL,BTP," My_Pyr © maloma ",Magic,0,Blue);
 OrderSend(S,OP_SELLSTOP,Lots,SellPrice,Slippage,SSL,STP," My_Pyr © maloma ",Magic,0,Red);
 for (i=1;i<OneSideSteps;i++)
  {
   double CurBuyPrice=BuyPrice+NS*i;
   double CurSellPrice=SellPrice-NS*i;
   if (SL!=0)
    {BSL=CurBuyPrice-SL; SSL=CurSellPrice+SL;} else {BSL=0; SSL=0;}
   if (TP!=0)
    {BTP=CurBuyPrice+TP; STP=CurSellPrice-TP;} else {BTP=0; STP=0;}
   OrderSend(S,OP_BUYSTOP,Lots,CurBuyPrice,Slippage,BSL,BTP," My_Pyr © maloma ",Magic,0,Blue);
//    Print(ErrorDescription(GetLastError()));
   OrderSend(S,OP_SELLSTOP,Lots,CurSellPrice,Slippage,SSL,STP," My_Pyr © maloma ",Magic,0,Red);
//    Print(ErrorDescription(GetLastError()));
  }
 return(0);
}

double CalcSummary()
{
 double overall=0;
 j=OrdersTotal();
 for (i=0;i<j;i++)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   string OS=OrderSymbol();
   int OMN=OrderMagicNumber();
   int OT=OrderType();
   if (OS==S && OMN==Magic && OT==OP_BUY) overall=overall+OrderProfit();
   if (OS==S && OMN==Magic && OT==OP_SELL) overall=overall+OrderProfit();
  }
 return(overall);
}

double CloseAll()
{
 j=OrdersTotal()-1;
 for (i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   string OS=OrderSymbol();
   int OMN=OrderMagicNumber();
   int OT=OrderType();
   if (OS==S && OMN==Magic && OT==OP_BUY)
    OrderClose(OrderTicket(),OrderLots(),MarketInfo(S,MODE_BID),Slippage,DarkBlue);
   if (OS==S && OMN==Magic && OT==OP_SELL)
    OrderClose(OrderTicket(),OrderLots(),MarketInfo(S,MODE_ASK),Slippage,Maroon);
  }
 j=OrdersTotal();
 for (i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   OS=OrderSymbol();
   OMN=OrderMagicNumber();
   OT=OrderType();
   if (OS==S && OMN==Magic && OT>1)
    OrderDelete(OrderTicket());
   Print(ErrorDescription(GetLastError()));
  }
 return(0);
}

void start()
{
 CheckOrders();
 if (bc+sc+bsc+ssc==0) OpenOrders();
 CurProfit=CalcSummary();
 if (MaxProfit>=MinProfit && CurProfit<=CloseLevel && CurProfit>0) CloseAll();
 if (MaxProfit<CurProfit) MaxProfit=CurProfit;
 return(0);
}

