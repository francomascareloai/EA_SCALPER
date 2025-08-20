//===================================================================================================================================================//
#property copyright   "Copyright 2014-2019, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.2"
#property description "iCompass"
#property strict
//===================================================================================================================================================//
#property  indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1 clrMidnightBlue
#property  indicator_color2 clrDarkViolet
#property  indicator_width1 2
#property  indicator_width2 2
//===================================================================================================================================================//
input int  BarsCount = 10000;
input int  MAperiods = 30;
input int  ShiftBars = 0;
input bool AlertON   = TRUE;
//===================================================================================================================================================//
double ExtBuffer0[];
double ExtBuffer1[];
double ExtBuffer2[];
double ExtBuffer3[];
double ExtBufferh1[];
double ExtBufferh2[];
double MovingAverage[];
bool AlertBuy=TRUE;
bool AlertSell=TRUE;
int AlertSignal=0;
//===================================================================================================================================================//
int OnInit(void)
  {
   IndicatorShortName(WindowExpertName());
   IndicatorDigits(Digits);
   IndicatorBuffers(7);
//---
   SetIndexBuffer(0,ExtBufferh1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,"UpTrend");
//---
   SetIndexBuffer(1,ExtBufferh2);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexLabel(1,"DownTrend");
//---
   SetIndexBuffer(2,ExtBuffer3);
   SetIndexBuffer(3,ExtBuffer0);
   SetIndexBuffer(4,ExtBuffer1);
   SetIndexBuffer(5,ExtBuffer2);
   SetIndexBuffer(6,MovingAverage);
   return(INIT_SUCCEEDED);
  }
//===================================================================================================================================================//
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
//-----------------------------------------------------------------------------------
   int i;
   int k;
   int Limit=0;
   double Value=0;
   double LastValue=0;
   double GetBuffer=0;
   double MedianPrice;
   double MinLow=0;
   double MaxHigh=0;
   double sum=0;
   double sumw=0;
   double weight;
   double SmoothBars=NormalizeDouble(MAperiods/3,0);
   int CountedBars=BarsCount;//IndicatorCounted();
   if(CountedBars>Bars-1-SmoothBars)
      CountedBars=Bars-1-(MAperiods/3);
   if(CountedBars<0)
      return(-1);
   if(CountedBars>0)
      CountedBars--;
   Limit=CountedBars;
//-----------------------------------------------------------------------------------
   for(i=0; i<Limit; i++)
     {
      MovingAverage[i]=iMA(NULL,0,MAperiods,0,0,0,i+ShiftBars);
      MaxHigh=high[Highest(NULL,0,MODE_HIGH,MAperiods,i+ShiftBars)];
      MinLow=low[Lowest(NULL,0,MODE_LOW,MAperiods,i+ShiftBars)];
      MedianPrice=(high[i+ShiftBars]+low[i+ShiftBars])/2;
      Value=0.33*2*((MedianPrice-MinLow)/(MaxHigh-MinLow)-0.5)+0.67*LastValue;
      ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*GetBuffer;
      LastValue=Value;
      GetBuffer=ExtBuffer0[i];
      if(ExtBuffer0[i]>0)
         ExtBuffer1[i]=10;
      else
         ExtBuffer1[i]=-10;
     }
//-----------------------------------------------------------------------------------
   for(i=Limit; i>=0; i--)
     {
      sum=0;
      sumw=0;
      for(k=0; k<SmoothBars && (i+k)<BarsCount; k++)
        {
         weight=SmoothBars-k;
         sumw+=weight;
         sum+=weight*ExtBuffer1[i+k];
        }
      if(sumw!=0)
         ExtBuffer2[i]=sum/sumw;
      else
         ExtBuffer2[i]=0;
     }
//-----------------------------------------------------------------------------------
   for(i=0; i<=Limit; i++)
     {
      sum=0;
      sumw=0;
      for(k=0; k<SmoothBars && (i-k)>=0; k++)
        {
         weight=SmoothBars-k;
         sumw+=weight;
         sum+=weight*ExtBuffer2[i-k];
        }
      if(sumw!=0)
         ExtBuffer3[i]=sum/sumw;
      else
         ExtBuffer3[i]=0;
     }
//-----------------------------------------------------------------------------------
   for(i=Limit-1; i>=0; i--)
     {
      ExtBufferh1[i]=EMPTY_VALUE;
      ExtBufferh2[i]=EMPTY_VALUE;
      //---
      if(ExtBuffer3[i]>0)
        {
         ExtBufferh1[i]=MovingAverage[i];
         if(ExtBuffer3[i+1]<0)
            ExtBufferh1[i+1]=MovingAverage[i+1];
        }
      //---
      if(ExtBuffer3[i]<0)
        {
         ExtBufferh2[i]=MovingAverage[i];
         if(ExtBuffer3[i+1]>0)
            ExtBufferh2[i+1]=MovingAverage[i+1];
        }
      //---
     }
//-----------------------------------------------------------------------------------
//Pop up alerts
   if(AlertON==TRUE)
     {
      if((AlertBuy==true) && ((ExtBuffer3[1]>0)) && ((ExtBuffer3[2]<0)))
        {
         AlertSignal=1;
         AlertBuy=FALSE;
         AlertSell=TRUE;
        }
      //---
      if((AlertSell==true) && ((ExtBuffer3[1]<0)) && ((ExtBuffer3[2]>0)))
        {
         AlertSignal=-1;
         AlertBuy=TRUE;
         AlertSell=FALSE;
        }
      //-----------------------------------------------------------------------------------
      if(AlertSignal>0)
        {
         Alert(WindowExpertName()+" => Buy signal @ "+DoubleToStr(close[0],Digits)+" "+Symbol()+", Time: "+TimeToString(TimeCurrent())+", "+DoubleToStr(Period(),0)+" Minutes Chart");
         AlertSignal=0;
        }
      if(AlertSignal<0)
        {
         Alert(WindowExpertName()+" => Sell signal @ "+DoubleToStr(close[0],Digits)+" "+Symbol()+", Time: "+TimeToString(TimeCurrent())+", "+DoubleToStr(Period(),0)+" Minutes Chart");
         AlertSignal=0;
        }
     }
//-----------------------------------------------------------------------------------
   return(rates_total);
  }
//===================================================================================================================================================//
