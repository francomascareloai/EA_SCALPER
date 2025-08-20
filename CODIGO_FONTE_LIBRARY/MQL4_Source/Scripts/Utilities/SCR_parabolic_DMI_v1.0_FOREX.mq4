//+------------------------------------------------------------------+
//|                                              Parabolic by Maloma |
//+------------------------------------------------------------------+

#include <stdlib.mqh>

extern double Lots=0.1;
extern int    tp=23;
extern int    sl=40;
extern double Step1=0.02;
extern double ADXPer=13;
extern double PorogAdx=20;
extern double DeltaIN=20;
extern double DeltaOUT=20;
       int    magic=1064032;
       int    i,j;
       int    CBar;
       double HI1, LO1, PC1, DIP=0, DIM=0, Adx1=0, Adx2=0;
       bool   CanS=false,CanB=false;
       int    TF1=0;//PERIOD_M1;

int start()
{
 if (CBar<Bars)
  {
   PC1=iSAR(Symbol(),TF1,Step1,0.2,1);
   HI1=iHigh(Symbol(),TF1,1);
   LO1=iLow(Symbol(),TF1,1);
   DIP=iADX(Symbol(),TF1,ADXPer,PRICE_TYPICAL,MODE_PLUSDI,1);
   DIM=iADX(Symbol(),TF1,ADXPer,PRICE_TYPICAL,MODE_MINUSDI,1);
   Adx1=iADX(Symbol(),TF1,ADXPer,PRICE_TYPICAL,MODE_MAIN,1);
   Adx2=iADX(Symbol(),TF1,ADXPer,PRICE_TYPICAL,MODE_MAIN,2);
   
   Print("DIP=",DIP," DIM=",DIM," Adx=",Adx1);
   
   if (PC1<LO1 && Adx1>PorogAdx && Adx1>Adx2 && (DIP-DIM)>DeltaIN) CanB=true; else CanB=false;
   if (PC1>HI1 && Adx1>PorogAdx && Adx1>Adx2 && (DIM-DIP)>DeltaIN) CanS=true; else CanS=false;

   if (OrdersTotal()<1)
    {
     if (CanB) OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-sl*Point,Ask+tp*Point,"",magic,0,Green);
     if (CanS) OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+sl*Point,Bid-tp*Point,"",magic,0,Red);     
    }
    
   j=OrdersTotal()-1;
   for (i=j;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if (OrderType()==OP_SELL && (DIM-DIP)<DeltaOUT) OrderClose(OrderTicket(),OrderLots(),Ask,3,LightSalmon);
     if (OrderType()==OP_BUY && (DIP-DIM)<DeltaOUT) OrderClose(OrderTicket(),OrderLots(),Ask,3,PaleGreen);
    }

   CBar=Bars;
  }
 return(0);
}


