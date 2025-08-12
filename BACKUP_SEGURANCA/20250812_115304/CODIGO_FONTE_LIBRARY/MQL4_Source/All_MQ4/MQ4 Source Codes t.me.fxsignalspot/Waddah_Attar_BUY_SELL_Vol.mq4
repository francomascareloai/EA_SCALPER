//+------------------------------------------------------------------+
//|                                     Waddah Attar Buy Sell Volume |
//|                               Copyright © 2007, ww.metaforex.net |
//|                                   Waddah Attar www.metaforex.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, www.metaforex.net"
#property link      "www.metaforex.net"
//----
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow
//---- buffers
double P1;
double P2;
double P1Buffer[];
double P2Buffer[];
double P3Buffer[];
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, P1Buffer);
   SetIndexBuffer(1, P2Buffer);
   SetIndexBuffer(2, P3Buffer);
//----
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 2);
//----
   IndicatorDigits(0);
   Comment("Waddah Attar Buy Sell Volume www.metaforex.net");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   int i,ii;
   static int pii=-1;
   
   for(i = 0; i <iBars(Symbol(),PERIOD_M1) ; i++)
     {
       ii = iBarShift(Symbol(), Period(), iTime(Symbol(),PERIOD_M1,i), true);
       //----
       if (pii!=ii)
       {
         P1=0;
         P2=0;
         P1Buffer[ii]=0;
         P2Buffer[ii]=0;
         P3Buffer[ii]=0;
       }
       
       if (ii != -1)
       {
         if (iClose(Symbol(),PERIOD_M1,i)>iClose(Symbol(),PERIOD_M1,i+1))
         {
           P1 = P1+(iVolume(Symbol(),PERIOD_M1,i));
         }
         if (iClose(Symbol(),PERIOD_M1,i)<iClose(Symbol(),PERIOD_M1,i+1))
         {
           P2 = P2-(iVolume(Symbol(),PERIOD_M1,i));
         }
         if (iClose(Symbol(),PERIOD_M1,i)==iClose(Symbol(),PERIOD_M1,i+1))
         {
           P1 = P1+(iVolume(Symbol(),PERIOD_M1,i)/2);
           P2 = P2-(iVolume(Symbol(),PERIOD_M1,i)/2);
         }
       }
       P1Buffer[ii]=P1;
       P2Buffer[ii]=P2;
       P3Buffer[ii]=P1+P2;

       pii=ii;
    }
//----
   return(0);
  }

