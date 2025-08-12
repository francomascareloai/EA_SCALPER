//+------------------------------------------------------------------+
//|                                            Reverse No Repair.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots 2

#property indicator_color1 clrRed
#property indicator_width1 1
#property indicator_type1 DRAW_ARROW

#property indicator_color2 clrBlue
#property indicator_width2 1
#property indicator_type2 DRAW_ARROW

input int FilterCandle=12;
double bufferUp[];
double bufferDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,bufferUp,INDICATOR_DATA);
   SetIndexBuffer(1,bufferDown,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

   ArraySetAsSeries(bufferDown,true);
   ArraySetAsSeries(bufferUp,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   int limit;
   if(prev_calculated>0)
      limit=rates_total-prev_calculated -1;
   else
      limit=rates_total -1;

   for(int i=limit; i>=0; i--)
     {
      bufferUp[i]=0;
      bufferDown[i]=0;

      if(i+FilterCandle+2<rates_total)
        {
         if(isUp(i+1))
           {
            bufferUp[i+2]=low[i+2];
           }

         if(isDown(i+1))
           {
            bufferDown[i+2]=high[i+2];
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

bool isUp(int index)
  {
   bool flag=true;
   int preIndex=index+1;
   if(
      iLow(Symbol(),0,index)>iLow(Symbol(),0,preIndex)
      && iHigh(Symbol(),0,index)>iHigh(Symbol(),0,preIndex)
      && iClose(Symbol(),0,index)>iClose(Symbol(),0,preIndex)
      )
     {
      int startIndex=preIndex+1;
      int endIndex=preIndex+FilterCandle-1;
      for(int i=startIndex; i<=endIndex; i++)
        {
         if(iLow(Symbol(),0,i)<iLow(Symbol(),0,preIndex))
           {
            flag=false;
            break;
           }
        }
     }
   else
     {
      flag=false;
     }

   return flag;
  }
//+------------------------------------------------------------------+

bool isDown(int index)
  {
   bool flag=true;
   int preIndex=index+1;
   if(
      iLow(Symbol(),0,index)<iLow(Symbol(),0,preIndex)
      && iHigh(Symbol(),0,index)<iHigh(Symbol(),0,preIndex)
      && iClose(Symbol(),0,index)<iClose(Symbol(),0,preIndex)
      )
     {
      int start=preIndex+1;
      int end=preIndex+FilterCandle-1;
      for(int i=start; i<=end; i++)
        {
         if(iHigh(Symbol(),0,i)>iHigh(Symbol(),0,preIndex))
           {
            flag=false;
            break;
           }
        }
     }
   else
     {
      flag=false;
     }

   return flag;
  }
//+------------------------------------------------------------------+
