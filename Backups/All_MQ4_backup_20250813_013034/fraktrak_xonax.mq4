//+------------------------------------------------------------------+
//|                                               FrakTrak XonaX.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      Tfr=240;        //TimeFrame
input double   Lots=0.01;     //Lots size
input int      Tprof=1000;     //TakeProfit
input int      TreilSt=100;    //Trailing Stop
input int      TrStKor=10;     //The size of the correction Trailing Stop
input int      Magik=1001012;  //Magic Number
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   static double Upf,Lowf;
   double Tupf=0,Tlowf=0;
   int i,k;
   for(i=2; i<5000; i++)
     {
      Tupf=iFractals(Symbol(),Tfr,MODE_UPPER,i);
      if(Tupf>0)
         break;
     }
   for(k=2; k<5000; k++)
     {
      Tlowf=iFractals(Symbol(),Tfr,MODE_LOWER,k);
      if(Tlowf>0)
         break;
     }
//----Open position
//if(i>0) Print("i = ", i, " k = ",k);
   int total=OrdersTotal();
/*if(total<1)
      {*/
   if(Ask>Tupf+15*_Point && Tupf!=Upf)
     {
      double StL=NormalizeDouble(Tlowf,_Digits);
      int ticket=OrderSend(NULL,OP_BUY,Lots,Ask,30,StL,Bid+Tprof*_Point,NULL,Magik,0,clrBlue);
      if(ticket<0)
        {
         Print("OrderSend error #",GetLastError());
        }
      else {Print("Ask=",Ask,"Upf=",Upf," StL=",StL); Upf=Tupf;}
     }
   if(Bid<Tlowf-15*_Point && Tlowf!=Lowf)
     {
      double StL=NormalizeDouble(Tupf,_Digits);
      int ticket=OrderSend(NULL,OP_SELL,Lots,Bid,30,StL,Ask-Tprof*_Point,NULL,Magik,0,clrRed);
      if(ticket<0)
        {
         Print("OrderSend error #",GetLastError());
        }
      else {Print("Bid=",Bid,"Lowf=",Lowf," StL=",StL);   Lowf=Tlowf;}
     }
// }
//----Trailing Stop operation
   for(int cni=0;cni<total;cni++)
     {
      if(!OrderSelect(cni,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderMagicNumber()==Magik && TreilSt>0)
        {
         if(OrderType()==OP_BUY)
           {
            if(Bid-OrderOpenPrice()>_Point*TreilSt)
              {
               if(OrderStopLoss()<Bid-_Point*TreilSt-TrStKor*_Point)
                 {
                  //--- modify order and exit
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-_Point*TreilSt,OrderTakeProfit(),0,clrBlue))
                     Print("OrderModify error ",GetLastError());
                  return;
                 }
              }
           }
         if(OrderType()==OP_SELL)
           {
            if((OrderOpenPrice()-Ask)>_Point*TreilSt)
              {
               if(OrderStopLoss()>Ask+_Point*TreilSt+_Point*TrStKor)
                 {
                  //--- modify order and exit
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TreilSt,OrderTakeProfit(),0,clrRed))
                     Print("OrderModify error ",GetLastError());
                  return;
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
