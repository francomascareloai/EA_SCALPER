//+------------------------------------------------------------------+
//|                                                          PDF.mq4 |
//|                         Copyright © 2006, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 MediumSeaGreen

double pdf[];
//---- input parameters
extern int       ch_size=20;
//extern int limit_value=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,pdf);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
//----
//---- indicators
   int counter[100];
   int totBars=Bars;
   int value=0;
   
   int    counted_bars=IndicatorCounted();
      
      if(counted_bars<0) return(-1);
   ArrayInitialize(counter,0);   
   for(int i =Bars-1-ch_size;i>=0;i--)
   {
   value=MathCeil(iStochastic(NULL,0,ch_size, 2,1,MODE_SMA,0,MODE_MAIN,i));  
   counter[100-value]=counter[100-value]+1;   
   //if(counter[100-value]>limit_value && limit_value!=0)counter[100-value]=limit_value;
   }
   pdf[0]=0;
   for(i=100;i>0;i--)
   {
      pdf[i]=counter[i];
      
     // Print(pdf[i]);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+