//+------------------------------------------------------------------+
//|                                      Elliott Wave Oscillator.mq4 |
//|                                    Copyright 2016, Hossein Nouri |
//|                           https://www.mql5.com/en/users/hsnnouri |
//+------------------------------------------------------------------+
//v1.1
//Modified, 18/04/2022, by jeanlouie, www.forexfactory.com/jeanlouie
// - option for no negative values in histo and ma-histo

#property copyright "Copyright 2016, Hossein Nouri."
#property link      "https://www.mql5.com/en/users/hsnnouri"
#property version   "1.1"
#property description "a good oscillator for helping you to count elliot waves" 
#property strict
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   6

//--- plot UpperGrowing
#property indicator_label1  "UpperGrowing"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot UpperFalling
#property indicator_label2  "UpperFalling"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot LowerGrowing
#property indicator_label3  "LowerGrowing"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrMaroon
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot LowerFalling
#property indicator_label4  "LowerFalling"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- moving average
#property indicator_label5  "MA"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDodgerBlue
#property indicator_style5  STYLE_DOT
#property indicator_width5  1

#property indicator_label6  "Temp"
#property indicator_type6   DRAW_NONE

#property  indicator_level1     0.0
#property  indicator_levelcolor clrSilver
#property  indicator_levelstyle STYLE_DOT

//--- input parameters
input int                  FastMa=5;
input int                  SlowMA=35;
input ENUM_APPLIED_PRICE   PriceSource=PRICE_MEDIAN;
input ENUM_MA_METHOD       SmoothingMethod=MODE_SMA;
input string               desc="*** Moving Average of Values ***";
input bool                 ShowMA=true;
input int                  MaPeriod=5;
input ENUM_MA_METHOD       MaMethod=MODE_SMA;
input bool                 NoNegatives=false;
//--- indicator buffers
double         UpperGrowingBuffer[];
double         UpperFallingBuffer[];
double         LowerGrowingBuffer[];
double         LowerFallingBuffer[];
double         MABuffer[];
double         MATemp[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorDigits(Digits);
   SetIndexBuffer(0,UpperGrowingBuffer);
   SetIndexBuffer(1,UpperFallingBuffer);
   SetIndexBuffer(2,LowerGrowingBuffer);
   SetIndexBuffer(3,LowerFallingBuffer);
   SetIndexBuffer(4,MABuffer);
   SetIndexBuffer(5,MATemp);
   

//ArrayResize(MATemp,Bars+1);
//ArraySetAsSeries(MATemp,true);

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
   if(ArraySize(MATemp)<rates_total) ArrayResize(MATemp,rates_total+1);
   for(int i=0;i<(rates_total-prev_calculated);i++)
     {
      calculateValue(i);
     }
   calculateValue(0);
   if(ShowMA==true)
     {
      double tmp = 0;
      for(int i=0;i<(rates_total-prev_calculated);i++)
        {
         tmp = iMAOnArray(MATemp,0,MaPeriod,0,MaMethod,i);
         if(NoNegatives)MABuffer[i]=MathAbs(tmp);
         else MABuffer[i]=tmp;
        }
      tmp = iMAOnArray(MATemp,0,MaPeriod,0,MaMethod,0);
      if(NoNegatives)MABuffer[0]=MathAbs(tmp);
      else MABuffer[0]=tmp;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void calculateValue(int index)
  {
   double slowMA=iMA(Symbol(), PERIOD_CURRENT,SlowMA,0,SmoothingMethod,PriceSource,index);
   double fastMA=iMA(Symbol(), PERIOD_CURRENT,FastMa,0,SmoothingMethod,PriceSource,index);
   double value=fastMA-slowMA;
   double slowMAPrev=iMA(Symbol(), PERIOD_CURRENT,SlowMA,0,SmoothingMethod,PriceSource,index+1);
   double fastMAPrev=iMA(Symbol(), PERIOD_CURRENT,FastMa,0,SmoothingMethod,PriceSource,index+1);
   double valuePrev=fastMAPrev-slowMAPrev;
   int nn = NoNegatives?-1:1;
   MATemp[index]=value;
   if(value>0 && value>valuePrev)
     {
      UpperGrowingBuffer[index]=value;
      UpperFallingBuffer[index]=EMPTY_VALUE;
     }
   if(value>0 && value<valuePrev)
     {
      UpperFallingBuffer[index]=value;
      UpperGrowingBuffer[index]=EMPTY_VALUE;
     }
   if(value<0 && value>valuePrev)
     {
      LowerGrowingBuffer[index]=value*nn;
      LowerFallingBuffer[index]=EMPTY_VALUE;
     }
   if(value<0 && value<valuePrev)
     {
      LowerFallingBuffer[index]=value*nn;
      LowerGrowingBuffer[index]=EMPTY_VALUE;
     }
  }
//+------------------------------------------------------------------+
