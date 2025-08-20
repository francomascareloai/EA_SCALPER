//+------------------------------------------------------------------+
//|                                                Amerika by Maloma |
//+------------------------------------------------------------------+

#include <stdlib.mqh>

extern double Lots=0.1;
extern int    Hour2StartCalc=7;
extern int    Hour2SetPending=13;
extern int    MinChannel=40;
extern int    Filtr=5;
extern int    TStOp=10;
extern int    TStEp=5;
       double Spread;
       double Max, Min;
       double sl, tp;
       int    magic=3287429;
       int    i,j;

void CalcRange()
{
 Spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;
 Max=High[Highest(NULL,PERIOD_M1,MODE_HIGH,250,1)]+Filtr*Point;
 Min=Low[Lowest(NULL,PERIOD_M1,MODE_LOW,250,1)]-Filtr*Point;
 Print("1. Max=",Max," Min=",Min);
 if ((Max-Min)<MinChannel)
  {
   Max=NormalizeDouble(Max+(MinChannel*Point-(Max-Min))/2,Digits);
   Min=NormalizeDouble(Min-(MinChannel*Point-(Max-Min))/2,Digits);
   Print("2. Max=",Max," Min=",Min," разность=",(MinChannel*Point-(Max-Min))/2);
  }
 return(0);
}

void SetOrders()
{
 OrderSend(Symbol(),OP_BUYSTOP,Lots,Max+Spread,3,Max+Spread-MinChannel*Point,0,"",magic,0,Green);
 OrderSend(Symbol(),OP_SELLSTOP,Lots,Min,3,Min+MinChannel*Point,0,"",magic,0,Green);
 return(0);
}

void Tral()

{
 for(i=OrdersTotal()-1;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if ((OrderSymbol()==Symbol()) && (OrderMagicNumber()==magic))
      {
       if (OrderType()==OP_BUY && Bid-OrderOpenPrice()>TStOp*Point)
        {
//         if (Bid-OrderOpenPrice()>=Bezubitok*Point && OrderStopLoss()<OrderOpenPrice())
//          {OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+1*Point,OrderTakeProfit(),0,CLR_NONE);}
         if (Bid-OrderStopLoss()>=(TStOp+TStEp)*Point)
          {OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TStOp*Point,OrderTakeProfit(),0,CLR_NONE);}
        }
       if (OrderType()==OP_SELL && OrderOpenPrice()-Ask>TStOp*Point)
        {
//         if (OrderOpenPrice()-Ask>=Bezubitok*Point && OrderStopLoss()>OrderOpenPrice())
//          {OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-1*Point,OrderTakeProfit(),0,CLR_NONE);}
         if (OrderStopLoss()-Ask>=(TStOp+TStEp)*Point)
          {OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TStOp*Point,OrderTakeProfit(),0,CLR_NONE);}
        }
      }
    }
 return(0);
}

int start()
{
 if (Hour()==0 && OrdersTotal()>0)
  {
   Print(3);
   j=OrdersTotal()-1;
   for (i=j;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if (OrderType()>1)
      {
       OrderDelete(OrderTicket());
      }
    }
  }
 if (Hour()<Hour2SetPending)
  {
   Max=0;
   Min=0;
   return(0);
  }
 if (Max==0 && Min==0) {CalcRange();}
 if (OrdersTotal()<1) {SetOrders();}
 Tral();
 return(0);
}


