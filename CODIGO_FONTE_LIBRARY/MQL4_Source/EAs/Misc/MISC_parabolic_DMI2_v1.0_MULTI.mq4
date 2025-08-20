//+------------------------------------------------------------------+
//|                                              Parabolic by Maloma |
//+------------------------------------------------------------------+

#include <stdlib.mqh>

extern double Lots=0.1;
extern int    tp=23;
extern int    sl=40;
extern double ADXPer=17;
extern double PorogAdx=21;
extern double PorogIN=18;
extern double PorogOUT=12;
       int    magic=1064032;
       int    i,j;
       int    CBar;
       double DIP=0, DIM=0, Adx1=0, Adx2=0;
       bool   CanS=false,CanB=false;
       int    TF1=0;//PERIOD_M1;

int start()
{
 if (CBar<Bars)
  {
   DIP=MathRound(iADX(Symbol(),TF1,ADXPer,PRICE_TYPICAL,MODE_PLUSDI,1));
   DIM=MathRound(iADX(Symbol(),TF1,ADXPer,PRICE_TYPICAL,MODE_MINUSDI,1));
   Adx1=iADX(Symbol(),TF1,ADXPer,PRICE_TYPICAL,MODE_MAIN,1);
   
   Print("DIP=",DIP," DIM=",DIM," Adx=",Adx1);
   
   if (Adx1>PorogAdx && DIP>DIM && DIP>PorogIN) CanB=true; else CanB=false;
   if (Adx1>PorogAdx && DIM>DIP && DIM>PorogIN) CanS=true; else CanS=false;

   if (OrdersTotal()<1)
    {
     if (CanB) OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-sl*Point,Ask+tp*Point,"",magic,0,Green);
     if (CanS) OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+sl*Point,Bid-tp*Point,"",magic,0,Red);     
    }
    
   j=OrdersTotal()-1;
   for (i=j;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if (OrderType()==OP_SELL && DIM<PorogOUT) OrderClose(OrderTicket(),OrderLots(),Ask,3,LightSalmon);
     if (OrderType()==OP_BUY && DIP<PorogOUT) OrderClose(OrderTicket(),OrderLots(),Ask,3,PaleGreen);
    }

   CBar=Bars;
  }
 return(0);
}


