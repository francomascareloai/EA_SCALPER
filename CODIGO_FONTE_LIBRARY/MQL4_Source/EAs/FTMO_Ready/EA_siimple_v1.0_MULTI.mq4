//+-----===   simple   ===-----+
#property copyright "Copyright © 2006, maloma"
#include <stdlib.mqh>
#include <stderror.mqh>

extern double Lots         = 0.1;
extern int    TP           = 50;
extern int    SL           = 50;
extern int    BU           = 20;
extern int    MagicNumber  = 505050;
       int    Slippage     = 3;

       int    Tt, CBar;

void init()
{
 return(0);
}

int OpenOrder(string S, int OP)
{
 int cnt=10;
 int res=0;
 RefreshRates();
 if (OP==OP_BUY)
  {
   double Price=MarketInfo(S,MODE_ASK);
   double CTP=Price+TP*Point;
   if (SL!=0) double CSL=Price-SL*Point;
  }
 if (OP==OP_SELL)
  {
   Price=MarketInfo(S,MODE_BID);
   CTP=Price-TP*Point;
   if (SL!=0) CSL=Price+SL*Point;
  }
 while (res==0 && cnt>0)
  {
   res=OrderSend(S,OP,Lots,Price,Slippage,CSL,CTP," try_enter © maloma ",MagicNumber,0,CLR_NONE);
   if (res>0) 
     {
      Comment("                                                                               ");
      Sleep(2000);
     } 
    else 
     {
      int le=GetLastError();
      Comment("                                                                               ");
      Comment("Ошибка открытия ордера #",le," - ",ErrorDescription(le));
      Sleep(6000);
      cnt--;
     }
  }
 if (res==-1) res=0;
 return(res);
}

bool CloseOrder(int T, string S, int OP)
{
 int cnt=10;
 bool res=false;
 if (OP==OP_BUY) {double Price=MarketInfo(S,MODE_BID);}
 if (OP==OP_SELL)       {Price=MarketInfo(S,MODE_ASK);}
 while (!res && cnt>0)
  {
   OrderSelect(T,SELECT_BY_TICKET,MODE_TRADES);
   res=OrderClose(T,OrderLots(),Price,Slippage,CLR_NONE);
   if (res) 
     {
      Comment("                                                                               ");
      Sleep(2000);
     } 
    else 
     {
      int le=GetLastError();
      Comment("                                                                               ");
      Comment("Ошибка закрытия ордера #",le," - ",ErrorDescription(le));
      Sleep(6000);
      cnt--;
     }
  }
 return(res);
}

void MoveStop()
{
 OrderSelect(Tt,SELECT_BY_TICKET,MODE_TRADES);
 if (OrderType()==OP_BUY) OrderModify(Tt,OrderOpenPrice(),Bid-BU*Point,OrderTakeProfit(),0,CLR_NONE);
 if (OrderType()==OP_BUY) OrderModify(Tt,OrderOpenPrice(),Ask+BU*Point,OrderTakeProfit(),0,CLR_NONE);
 return(0);
}

void start()
{
 if (CBar!=Bars)
  {
   if (DayOfWeek()>1)
    {
     if (iOpen(Symbol(),PERIOD_D1,1)<iClose(Symbol(),PERIOD_D1,1)) Tt=OpenOrder(Symbol(),OP_SELL);
     if (iOpen(Symbol(),PERIOD_D1,1)>iClose(Symbol(),PERIOD_D1,1)) Tt=OpenOrder(Symbol(),OP_BUY);
    }
   if (DayOfWeek()==1)
    {
     if (iOpen(Symbol(),PERIOD_D1,2)<iClose(Symbol(),PERIOD_D1,2)) Tt=OpenOrder(Symbol(),OP_SELL);
     if (iOpen(Symbol(),PERIOD_D1,2)>iClose(Symbol(),PERIOD_D1,2)) Tt=OpenOrder(Symbol(),OP_BUY);
    }
   CBar=Bars;
  }
 OrderSelect(Tt,SELECT_BY_TICKET,MODE_TRADES);
 if (OrderType()==OP_BUY && Bid-OrderOpenPrice()>BU*Point && OrderStopLoss()<OrderOpenPrice()) MoveStop();
 if (OrderType()==OP_SELL && OrderOpenPrice()-Ask>BU*Point && OrderStopLoss()>OrderOpenPrice()) MoveStop();
 OrderSelect(Tt,SELECT_BY_TICKET,MODE_TRADES);
 if (OrdersTotal()>0 && Hour()==23) CloseOrder(Tt, Symbol(), OrderType());
 return(0);
}

