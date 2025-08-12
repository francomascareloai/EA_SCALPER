//+------------------------------------------------------------------+
//|                                            paul_maloma by Maloma |
//+------------------------------------------------------------------+

#include <stdlib.mqh>
#include <stderror.mqh>

extern double Lots=0.1;
extern int    SL=30;
extern int    TP=30;
extern bool   DelOther=true;
extern int    Hour2Enter=7;
extern int    Filtr=30;
       int    magic=1257942;        
       int    i,j;
       double HiLev, LoLev;     
       double Spread;

int hilooday()
{
  HiLev=iHigh(Symbol(),PERIOD_D1,0)+5*Point;
  LoLev=iLow(Symbol(),PERIOD_D1,0)-5*Point;
}

int exist()
{
  int is=0;
  for (i=0;i<OrdersTotal();i++)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if ((OrderSymbol()==Symbol())&&(OrderMagicNumber()==magic)) {is++;}
    }
  return(is);
}

int OpenOrders()
{
  OrderSend(Symbol(),OP_BUYSTOP,Lots,HiLev+Spread,3,HiLev-SL*Point,HiLev+TP*Point,NULL,magic,0,CLR_NONE);
  OrderSend(Symbol(),OP_SELLSTOP,Lots,LoLev,3,LoLev+SL*Point+Spread,LoLev-TP*Point+Spread,NULL,magic,0,CLR_NONE);
  return(0);
}

int start()
{ 
  Spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;
  hilooday();
  if ((Hour()==Hour2Enter)&&(exist()==0))
    {
     OpenOrders();
    }
  return(0);
}