//+------------------------------------------------------------------+
//|                                              Parabolic by Maloma |
//+------------------------------------------------------------------+

#include <stdlib.mqh>

extern double Lots=0.1;
extern int    tp=23;
extern int    sl=40;
extern double Step1=0.02;
//extern double Step2=0.004;
extern double Step2=0.1;
       double Max=0.2;
       int    magic=1064032;
       int    i,j;
       int    CBar;
       double HI1, LO1, HI2, LO2, PC1, PC2, MA;
       bool   CanS=false,CanB=false;
       int    TF1=PERIOD_M1, TF2=PERIOD_H1;

int start()
{
 if (CBar<Bars)
  {
   PC1=iSAR(Symbol(),TF1,Step1,Max,1);
   PC2=iSAR(Symbol(),TF2,Step2,Max,0);
   HI1=iHigh(Symbol(),TF1,1);
   HI2=iHigh(Symbol(),TF2,0);
   LO1=iLow(Symbol(),TF1,1);
   LO2=iLow(Symbol(),TF2,0);
   MA=iMA(Symbol(),TF1,50,0,MODE_SMA,PRICE_CLOSE,1);

   if (PC1<LO1 && PC2<LO2 && LO1>MA && PC1<MA) CanB=true;
   if (PC1>HI1 && PC2>HI2 && HI1<MA && PC1>MA) CanS=true;
   if ((PC1<LO1 && PC2>HI2) || (PC1>HI1 && PC2<LO2)) {CanB=false; CanS=false;}

   Print (PC1," ",PC2);
   if (OrdersTotal()<1)
    {
     if (CanB) OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-sl*Point,Ask+tp*Point,"",magic,0,Green);
     if (CanS) OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+sl*Point,Bid-tp*Point,"",magic,0,Red);     
    }
    
   j=OrdersTotal()-1;
   for (i=j;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if (OrderType()==OP_SELL && PC2<LO2) OrderClose(OrderTicket(),OrderLots(),Ask,3,LightSalmon);
     if (OrderType()==OP_BUY && PC2>HI2) OrderClose(OrderTicket(),OrderLots(),Ask,3,PaleGreen);
    }

   CBar=Bars;
  }
 return(0);
}


