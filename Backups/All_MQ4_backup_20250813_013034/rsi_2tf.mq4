//+------------------------------------------------------------------+
//|                                          RSI 2TF Oscillyator.mq4 |
//|                        Copyright © 2016, assurkov, Alexey Surkov |
//|                                          http://www.assurkov.ru/ |
//+------------------------------------------------------------------+
#property strict
#property copyright "Copyright © 2016,  www.assurkov.ru, Alexey Surkov"
#property link      "https://www.mql5.com/ru/market/product/15565"
#property version     "1.00"


#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 20
#property indicator_level2 80
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Salmon

#property indicator_width1 1
#property indicator_width2 2


//----
extern int Period=14;
input int NewTimeFrame=60;

//---- buffers
double Buffer1[],Buffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   string sShortName;

   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(0,DRAW_LINE);
   sShortName="RSI 2TF"+"("+string(Period)+")";
   IndicatorShortName(sShortName);

   SetIndexLabel(0,sShortName);
   SetIndexDrawBegin(0,14);

   SetIndexBuffer(1,Buffer2);


   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();

   if(counted_bars<0)
     {
      Print("Indicator Error (Counted bars < 0)!");
      return(-1);
     }

   if(Bars<17)
     {
      Print("Indicator Error (Bars < 12)!");
      return(-1);
     }
   int limit=Bars-17;

   if(counted_bars>17)
     {
      limit=Bars-counted_bars;
     }

   for(int i=limit; i>=0; i --)
     {

      Buffer1[i]=EMPTY_VALUE;
      Buffer2[i]=EMPTY_VALUE;

      Buffer1[i]=iRSI("0",0,Period,PRICE_CLOSE,i);

      int iNext1=iBarShift(NULL,NewTimeFrame,iTime(NULL,0,i));
      Buffer2[i]=iRSI("0",NewTimeFrame,Period,PRICE_CLOSE,iNext1);
     }
//--------------------------------------------------------------------
   return (0);
  }
//--------------------------------------------------------------------
