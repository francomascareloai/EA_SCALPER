//+------------------------------------------------------------------+
//|                                                          ZZZ.mq4 |
//+------------------------------------------------------------------+

#property copyright "Maloma"
#include <stdlib.mqh>
#property show_inputs

extern double Lots = 0.1;
//extern int    Filtr = 2;
extern int    profit = 3;
extern int    loss = 15;

       double SSP, SSSL, SSTP, BSP, BSSL, BSTP;
       int    magic=390349;
       int    ndir, dir=0;
       bool   sell=false, buy=false;
       double spread;
       
extern int  ExtDepth     = 12;
extern int  ExtDeviation = 5;
extern int  ExtBackstep  = 3;
       int  ShiftBars    = 0;

int start()

{
 int    i,j;
 double y3=0, y2=0, y1=0, zz;    // экстремумы Зиг-Зага
 int    x3, x2, x1, sh=ShiftBars;// номера баров

 spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;

// Берём три экстремума Зиг-Зага
 while (y3==0) {
//   Print(GetLastError());
   zz=iCustom(NULL, 0, "ZigZag2", ExtDepth, ExtDeviation, ExtBackstep, 0, sh);
   if (zz!=0 && zz!=EMPTY_VALUE) {
     if      (y1==0) { x1=sh; y1=zz; }
     else if (y2==0) { x2=sh; y2=zz; }
     else if (y3==0) { x3=sh; y3=zz; }
   }
   sh++;
 }

// Print(x1," ",x2," ",x3);

 if (y2>y1) {ndir=-1;}
 if (y2<y1) {ndir=1;}
 
 if ((dir==1) && (ndir==-1) && ((iHigh(Symbol(),0,x2)-iLow(Symbol(),0,x3))>10*Point)) {sell=true; buy=false;} else
 if ((dir==-1) && (ndir==1) && ((iHigh(Symbol(),0,x3)-iLow(Symbol(),0,x2))>10*Point)) {buy=true; sell=false;}
 else {buy=false; sell=false;}
// Print("dir=",dir," ndir=",ndir, " buy=",buy," sell=",sell," разница1=",iHigh(Symbol(),0,x2)-iLow(Symbol(),0,x3)," разница2=",iHigh(Symbol(),0,x3)-iLow(Symbol(),0,x2));
 dir=ndir; 
/*
 if (dir==1)
  {
   BSP=Ask;
   BSSL=iLow(Symbol(),0,x2)-Filtr*Point;
   BSTP=NormalizeDouble(BSP+(BSP-iLow(Symbol(),0,x2))*0.618,Digits);
   
   SSP=BSSL;  
   SSSL=BSP;  
   SSTP=SSP-
  }
 if (dir==-1)
  {
   SSP=Bid;  
   SSSL=iHigh(Symbol(),0,x2)+(MarketInfo(Symbol(),MODE_SPREAD)+Filtr)*Point;  
   SSTP=NormalizeDouble(SSP-(iHigh(Symbol(),0,x2)-SSP)*0.618,Digits);
   
   BSP=SSSL;
   BSSL=SSP;
   BSTP=BSP+;
  }
*/  
 if (buy) OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, Ask-loss*Point, Ask+profit*Point, "", magic, 0, Green);
// Print (BSP," ",BSSL," ",BSTP," ",Ask);
 Print("+",GetLastError());
 if (sell) OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, Bid+loss*Point, Bid-profit*Point, "", magic, 0, Red);
// Print (SSP," ",SSSL," ",SSTP," ",Bid);
 Print("-",GetLastError());
 return( 0 );
}


