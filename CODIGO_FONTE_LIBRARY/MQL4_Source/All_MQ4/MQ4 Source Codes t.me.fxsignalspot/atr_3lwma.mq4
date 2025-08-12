//+------------------------------------------------------------------+
//|                                                    ATR_3LWMA.mq4 |
//|                                           Copyright 2015, fxborg |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
#property version   "1.01"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_color1 Red
#property indicator_color2 DarkTurquoise
#property indicator_color3 DodgerBlue
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
//--- input parameters
input int      InpSigPeriod=14;  // Signal Period
input int      InpFastPeriod=25; // Fast Period
input int      InpSlowPeriod=50; // Slow Period
int SigMaPeriod=(int)MathCeil(InpSigPeriod/5);
int FastMaPeriod = (int)MathCeil(InpFastPeriod/5);
int SlowMaPeriod = (int)MathCeil(InpSlowPeriod/5);
int   CalcPeriod=InpSlowPeriod*2;
//---
int min_rates_total;
//--- indicator buffers
double FastAtrMaBuffer[];
double SlowAtrMaBuffer[];
double SigAtrMaBuffer[];
//---
double FastAtrBuffer[];
double SlowAtrBuffer[];
double SigAtrBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpFastPeriod>InpSlowPeriod)
     {
      Alert("InpSlowPeriod is too small.");
      return(INIT_FAILED);
     }
   if(InpSigPeriod>InpFastPeriod)
     {
      Alert("InpSigPeriod is too large.");
      return(INIT_FAILED);
     }
//---- Initialization of variables of data calculation starting point
   min_rates_total=1+InpSlowPeriod+1+SlowMaPeriod+1;
//--- indicator buffers mapping
   IndicatorBuffers(6);
//--- indicator buffers
   SetIndexBuffer(0,SigAtrMaBuffer);
   SetIndexBuffer(1,FastAtrMaBuffer);
   SetIndexBuffer(2,SlowAtrMaBuffer);
   SetIndexBuffer(3,SigAtrBuffer);
   SetIndexBuffer(4,FastAtrBuffer);
   SetIndexBuffer(5,SlowAtrBuffer);
//---
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexEmptyValue(5,EMPTY_VALUE);
//---
   SetIndexDrawBegin(0,min_rates_total);
   SetIndexDrawBegin(1,min_rates_total);
   SetIndexDrawBegin(2,min_rates_total);
   SetIndexDrawBegin(3,min_rates_total);
   SetIndexDrawBegin(4,min_rates_total);
   SetIndexDrawBegin(5,min_rates_total);
//---
   string short_name="ATR 3LWMA("+IntegerToString(InpSigPeriod)
                     +","+IntegerToString(InpFastPeriod)
                     +","+IntegerToString(InpSlowPeriod)+")";
   IndicatorShortName(short_name);
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
   int i,j,first;
//--- check for bars count
   if(rates_total<=min_rates_total)
      return(0);
//---
   MathSrand(int(TimeLocal()));
//--- indicator buffers
   ArraySetAsSeries(SigAtrMaBuffer,false);
   ArraySetAsSeries(FastAtrMaBuffer,false);
   ArraySetAsSeries(SlowAtrMaBuffer,false);

   ArraySetAsSeries(SigAtrBuffer,false);
   ArraySetAsSeries(FastAtrBuffer,false);
   ArraySetAsSeries(SlowAtrBuffer,false);
//--- rate data
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//+----------------------------------------------------+
//|Set Atr Buffeer                                     |
//+----------------------------------------------------+
   first=InpSlowPeriod+1-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         FastAtrBuffer[i]=EMPTY_VALUE;
         SlowAtrBuffer[i]=EMPTY_VALUE;
        }
     }
//---
   for(i=first; i<rates_total-1 && !IsStopped(); i++)
     {
      if(!random(20) && rates_total-i>CalcPeriod && FastAtrBuffer[i]!=EMPTY_VALUE) continue;
      //--- 
      SlowAtrBuffer[i]=calc_atr(InpSlowPeriod,i,high,low,close);
      FastAtrBuffer[i]=calc_atr(InpFastPeriod,i,high,low,close);
      SigAtrBuffer[i]=calc_atr(InpSigPeriod,i,high,low,close);
     }
//+----------------------------------------------------+
//| Set MA Buffeer                                     |
//+----------------------------------------------------+
   first=InpSlowPeriod-1+SlowMaPeriod-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         SigAtrMaBuffer[i]=EMPTY_VALUE;
         FastAtrMaBuffer[i]=EMPTY_VALUE;
         SlowAtrMaBuffer[i]=EMPTY_VALUE;
        }
     }
//--- ma cycle
   for(i=first; i<rates_total-1 && !IsStopped(); i++)
     {
        {
         double sum=0.0;
         for(j=(i-SlowMaPeriod+1);j<=i;j++) sum+=SlowAtrBuffer[j];
         SlowAtrMaBuffer[i]=sum/SlowMaPeriod;
        }
        {
         double sum=0.0;
         for(j=(i-FastMaPeriod+1);j<=i;j++) sum+=FastAtrBuffer[j];
         FastAtrMaBuffer[i]=sum/FastMaPeriod;
        }
        {
         double sum=0.0;
         for(j=(i-SigMaPeriod+1);j<=i;j++) sum+=SigAtrBuffer[j];
         SigAtrMaBuffer[i]=sum/SigMaPeriod;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+----------------------------------------------------+
//| random                                             |
//+----------------------------------------------------+
bool random(int x)
  {
   int ran=MathRand();
   bool res=(MathMod(ran,x)==0);
   return(res);
  }
//+----------------------------------------------------+
//| calc lwma atr                                      |
//+----------------------------------------------------+
double calc_atr(int len,int i,const double  &h[],const double  &l[],const double  &c[])
  {
//--- 
   double range[];
   ArrayResize(range,len);
   int sz=0;
//--- 
   for(int j=len-1;j>=0;j--)
     {
      range[sz]=(MathMax(h[i-j],c[i-j-1])-MathMin(l[i-j],c[i-j-1]));
      sz++;
     }
//--- 
   if(sz==len)
      return(lwma_atr(range,len));
   else
      return(EMPTY_VALUE);
//--- 
  }
//+----------------------------------------------------+
//| lwma atr impl                                      |
//+----------------------------------------------------+
double lwma_atr(const double  &price[],int n)
  {
//--- 
   double y=0.0;
   int x=0;
//--- 
   for(int i=0;i<n;i++)
     {
      y+=price[i]*(i + 1);
      x+= (i+1);
     }
//--- 
   return(y/double(x));
  }
//+------------------------------------------------------------------+
