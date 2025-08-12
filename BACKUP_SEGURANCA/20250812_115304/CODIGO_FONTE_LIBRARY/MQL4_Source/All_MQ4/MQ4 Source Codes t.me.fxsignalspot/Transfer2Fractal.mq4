//+-----===      Transfer2Fractal      ===-----+
//+-----=== Designed for Sergey Gukach ===-----+

#property copyright "Copyright © 2006, maloma"
#include <stdlib.mqh>
#include <stderror.mqh>

extern double Lots          = 0.1;
extern int    StopLoss      = 20;
extern int    TakeProfit    = 30;
extern int    MagicNumber   = 999555111;

extern int    StartHour  = 8;
extern int    Filtr      = 5;
extern int    EndHour    = 21;
       
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

void GetLevels()
{
 HiPrice=0;
 LoPrice=0;
 int i=0;
 while (HiPrice==0 || LoPrice==0)
  {
 //----Up and Down Fractals
//----5 bars Fractal
   if(High[i+3]>High[i+3+1] && High[i+3]>High[i+3+2] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<Low[i+3+1] && Low[i+3]<Low[i+3+2] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }
//----6 bars Fractal
   if(High[i+3]==High[i+3+1] && High[i+3]>High[i+3+2] && High[i+3]>High[i+3+3] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]==Low[i+3+1] && Low[i+3]<Low[i+3+2] && Low[i+3]<Low[i+3+3] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }                      
//----7 bars Fractal
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]>High[i+3+3] && High[i+3]>High[i+3+4] && High[i+3]>High[i+3-1] && 
      High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]<Low[i+3+3] && Low[i+3]<Low[i+3+4] && Low[i+3]<Low[i+3-1] && 
      Low[i+3]<Low[i+3-2] && LoPrice==0)
     { 
      LoPrice=Low[i+3];
      i++;
      continue;
     }                  
 //----8 bars Fractal                          
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]==High[i+3+3] && High[i+3]>High[i+3+4] && High[i+3]>High[i+3+5] && 
      High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]==Low[i+3+3] && Low[i+3]<Low[i+3+4] && Low[i+3]<Low[i+3+5] && 
      Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }                              
//----9 bars Fractal                                        
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]>=High[i+3+3] && High[i+3]==High[i+3+4] && High[i+3]>High[i+3+5] && 
      High[i+3]>High[i+3+6] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]<=Low[i+3+3] && Low[i+3]==Low[i+3+4] && Low[i+3]<Low[i+3+5] && 
      Low[i+3]<Low[i+3+6] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }                        
   i++;
  }
}

void start()
{
}