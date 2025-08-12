//+------------------------------------------------------------------+
//|                                                     sell&buy.mq4 |
//+------------------------------------------------------------------+

extern double lots=0.1;
extern double target=4;
int cbars=0;
int magic=9348670;
int dist=24;

int start() {

 double profit=0;
 int j=OrdersTotal()-1;
 for (int i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if(OrderMagicNumber()==magic && OrderSymbol()==Symbol())
   profit=OrderProfit()+OrderSwap()+profit;
  }
 
 if (profit>=target)
  {
   j=OrdersTotal()-1;
   for (i=j;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     RefreshRates();
     if(OrderType()==OP_BUY && OrderMagicNumber()==magic && OrderSymbol()==Symbol())
      OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
    }
  }
 
 double sig = Lowest(NULL,0,MODE_LOW,dist,0);
 if(cbars!=Bars && sig==1)
  {
   RefreshRates();
   OrderSend(Symbol(),OP_BUY,lots,Ask,3,0,0,"buy",magic,0,Blue);
   string AN="ArrBuy "+TimeToStr(CurTime());
   ObjectCreate(AN,OBJ_ARROW,0,Time[1],Low[1]-6*Point,0,0,0,0);
   ObjectSet(AN, OBJPROP_ARROWCODE, 233);
   ObjectSet(AN, OBJPROP_COLOR , Blue);
  }

 profit=0;
 j=OrdersTotal()-1;
 for (i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if(OrderType()==OP_SELL && OrderMagicNumber()==magic && OrderSymbol()==Symbol())
   profit=OrderProfit()+OrderSwap()+profit;
  }
 
 if (profit>=target)
  {
   j=OrdersTotal()-1;
   for (i=j;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     RefreshRates();
     if(OrderType()==OP_SELL && OrderMagicNumber()==magic && OrderSymbol()==Symbol())
      OrderClose(OrderTicket(),OrderLots(),Ask,3,Magenta);
    }
  }
 
 sig = Highest(NULL,0,MODE_HIGH,dist,0);
 if(cbars!=Bars && sig==1)
  {
   RefreshRates();
   OrderSend(Symbol(),OP_SELL,lots,Bid,3,0,0,"sell",magic,0,Magenta);
   AN="ArrSell "+TimeToStr(CurTime());
   ObjectCreate(AN,OBJ_ARROW,0,Time[1],High[1]+6*Point,0,0,0,0);
   ObjectSet(AN, OBJPROP_ARROWCODE, 234);
   ObjectSet(AN, OBJPROP_COLOR , Magenta);
  }

 cbars=Bars;
 
 return(0);
}