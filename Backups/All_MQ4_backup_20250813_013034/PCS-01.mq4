//+-----===         PCS         ===-----+
//+-----=== Designed for EURAUD ===-----+

#property copyright "Copyright © 2006, maloma"
#include <stdlib.mqh>
#include <stderror.mqh>

extern double Lots          = 0.1;
extern int    StopLoss      = 1000;
extern int    TakeProfit    = 1000;
extern int    MagicNumber   = 6540123;
extern string PCP           = "   ---   Параметры PriceChannel_Stop_v6   ---   ";
extern double Risk          = 0.30;
extern int    ChannelPeriod = 9;   //Price Channel Period
       int    Slippage      = 3;
       double SL,TP;
       int    i,j,CBar,CTicket=0;
       string S;

void init()
{
 CBar=0;
 S=Symbol();
 SL=StopLoss*MarketInfo(S,MODE_POINT);
 TP=TakeProfit*MarketInfo(S,MODE_POINT);
 return(0);
}

int OpenOrder(string S, int OP)
{
 
 int cnt=10;
 int res=0;
 if (OP==OP_BUY)
  {
   double Price=MarketInfo(S,MODE_ASK);
   double CSL=Price-SL;
   double CTP=Price+TP;
  }
 if (OP==OP_SELL)
  {
   Price=MarketInfo(S,MODE_BID);
   CSL=Price+SL;
   CTP=Price-TP;
  }
 while (res==0 && cnt>0)
  {
   res=OrderSend(S,OP,Lots,Price,Slippage,CSL,CTP," Crazy`s`Graal on "+S+" ",MagicNumber,0,CLR_NONE);
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

int Signal()
{
 int res=0;
 double tmp=iCustom(S,0,"PriceChannel_Stop_v6",ChannelPeriod,Risk,1,1,1,0,100,2,0);
 if (tmp>0) res=1;
 tmp=iCustom(S,0,"PriceChannel_Stop_v6",ChannelPeriod,Risk,1,1,1,0,100,3,0);
 if (tmp>0) res=-1;
 return(res);
}

bool BuyNotExist()
{
 bool res=true;
 for (i=OrdersTotal()-1;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY) res=false;
   if (!res) break;
  }
 return(res);
}

bool SellNotExist()
{
 bool res=true;
 for (i=OrdersTotal()-1;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL) res=false;
   if (!res) break;
  }
 return(res);
}

void start()
{
 i=Bars;
 j=Signal();
 if (j==1 && CBar!=i) if (BuyNotExist())
  {
   CloseOrder(CTicket,S,OP_SELL);
   CTicket=OpenOrder(S, OP_BUY);
   CBar=i;
  }
  if (j==-1 && CBar!=i) if (SellNotExist())
  {
   CloseOrder(CTicket,S,OP_BUY);
   CTicket=OpenOrder(S, OP_SELL);
   CBar=i;
  }
 return(0);
}

