//+------------------------------------------------------------------+
//|                                             VolumeOscillator.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1

#include <MovingAverages.mqh>

//--- plot Volume OSC
#property indicator_label1  "Volume OSC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input uint                 InpPeriodShort =  5;             // Short Length
input uint                 InpPeriodLong  =  10;            // Long Length
input ENUM_APPLIED_VOLUME  InpVolume      =  VOLUME_TICK;   // Volume

//--- indicator buffers
double   ExtBufferOSC[];
double   ExtBufferVolume[];
double   ExtBufferEMALong[];
double   ExtBufferEMAShort[];

//--- global variables
int      ExtPeriodLong;
int      ExtPeriodShort;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBufferOSC, INDICATOR_DATA);
   SetIndexBuffer(1,ExtBufferVolume, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtBufferEMALong, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtBufferEMAShort, INDICATOR_CALCULATIONS);
   
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(ExtBufferOSC, true);
   ArraySetAsSeries(ExtBufferVolume, true);
   ArraySetAsSeries(ExtBufferEMALong, true);
   ArraySetAsSeries(ExtBufferEMAShort, true);
   
//--- setting the periods, short name and levels for the indicator
   ExtPeriodLong =int(InpPeriodLong <1 ? 1 : InpPeriodLong);
   ExtPeriodShort=int(InpPeriodShort<1 ? 1 : InpPeriodShort);
   IndicatorSetString(INDICATOR_SHORTNAME, StringFormat("Volume Osc (%lu, %lu)", ExtPeriodShort, ExtPeriodLong));
   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0.0);

//--- success
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
//--- checking for the minimum number of bars for calculation
   int max=fmax(ExtPeriodLong, ExtPeriodShort);
   if(rates_total<fmax(max, 2))
      return 0;
      
//--- setting predefined indicator arrays as timeseries
   ArraySetAsSeries(volume,true);
   ArraySetAsSeries(tick_volume,true);
   
//--- checking and calculating the number of bars to be calculated
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1-max;
      ArrayInitialize(ExtBufferOSC, EMPTY_VALUE);
      ArrayInitialize(ExtBufferVolume, 0);
      ArrayInitialize(ExtBufferEMALong, 0);
      ArrayInitialize(ExtBufferEMAShort, 0);
     }

//--- calculate RAW data
   for(int i=limit; i>=0; i--)
      ExtBufferVolume[i]=double(InpVolume==VOLUME_TICK ? tick_volume[i] : volume[i]);
   
   if(ExponentialMAOnBuffer(rates_total, prev_calculated, 0, ExtPeriodLong, ExtBufferVolume, ExtBufferEMALong)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total, prev_calculated, 0, ExtPeriodShort, ExtBufferVolume, ExtBufferEMAShort)==0)
      return 0;
   
//--- calculation Volume Oscillator
   for(int i=limit; i>=0; i--)
      ExtBufferOSC[i]=(ExtBufferEMALong[i]!=0 ? 100 * (ExtBufferEMAShort[i] - ExtBufferEMALong[i]) / ExtBufferEMALong[i] : 0);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
