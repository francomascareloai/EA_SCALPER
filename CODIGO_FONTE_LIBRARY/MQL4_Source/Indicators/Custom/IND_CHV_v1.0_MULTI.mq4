//+------------------------------------------------------------------+
//|                                                          CHO.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property  indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DarkBlue
//---- input parameters
extern int       SmoothPeriod=10;
extern int       ROCPeriod=10;
extern int       TypeSmooth=1;// 0 - SMA, 1 - EMA
//---- buffers
double CHV[];
double HL[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   string name,smoothString;
   if (TypeSmooth<0 || TypeSmooth>1) TypeSmooth=1;
   if (TypeSmooth==0) smoothString="SMA"; else smoothString="EMA";
   name="Chaikin Volatility("+SmoothPeriod+","+smoothString+")";

   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CHV);
   SetIndexLabel(0,name);
   SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(1,HL);
   SetIndexEmptyValue(1,0.0);
   IndicatorShortName(name);
   IndicatorDigits(1);
   
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
   int    counted_bars=IndicatorCounted();
   int limit,i;
   double curr_value,shift_value;
//----
   if (counted_bars<0) return(-1);

   if (counted_bars==0) 
      {
      limit=Bars-1;
      for (i=limit;i>=0;i--)
        {
         HL[i]=High[i]-Low[i];
        }
      for(i=limit-2*SmoothPeriod;i>=0;i--)
        {
         curr_value=iMAOnArray(HL,0,SmoothPeriod,0,TypeSmooth,i);
         shift_value=iMAOnArray(HL,0,SmoothPeriod,0,TypeSmooth,i+ROCPeriod);
         CHV[i]=(curr_value-shift_value)/shift_value*100;
        }
      }

   if (counted_bars>0) 
     {
      limit=Bars-counted_bars;
      for (i=limit;i>=0;i--)
        {
         HL[i]=High[i]-Low[i];
        }
      for(i=limit;i>=0;i--)
        {
         curr_value=iMAOnArray(HL,0,SmoothPeriod,0,TypeSmooth,i);
         shift_value=iMAOnArray(HL,0,SmoothPeriod,0,TypeSmooth,i+ROCPeriod);
         CHV[i]=(curr_value-shift_value)/shift_value*100;
        }
      }            
//----
   return(0);
  }
//+------------------------------------------------------------------+