//+------------------------------------------------------------------+
//|                                                        Vidya.mq4 |
//|                                                                  |
//| Vidya developed by Tushar Chande                                 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property  indicator_chart_window
#property  indicator_buffers 3
#property  indicator_color1  clrDeepSkyBlue
#property  indicator_color2  clrDimGray
#property  indicator_color3  clrDarkOrange
#property  indicator_width1  2
#property  indicator_width3  2
#property  indicator_style2  STYLE_DOT
#property  strict

//
//
//
//
//

extern int  CmoPeriod      = 10;    // CMO period
extern int  SmoothPeriod   =  9;    // Smoothing period
extern bool ShowHighLine   = true;  // Show high line?
extern bool ShowMiddleLine = true;  // Show middle line?
extern bool ShowLowLine    = true;  // Show low line?

double vidya1[],vidya2[],vidya3[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,vidya1);
   SetIndexBuffer(1,vidya2);
   SetIndexBuffer(2,vidya3);
   return(0);
}
int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1);
   
   for(int i=limit; i>=0; i--) 
   {
      double median = (High[i]+Low[i])/2;
      if (ShowHighLine)   vidya1[i] = iVidya(High[i],median,CmoPeriod,SmoothPeriod,i,0);
      if (ShowMiddleLine) vidya2[i] = iVidya(median ,median,CmoPeriod,SmoothPeriod,i,1);
      if (ShowLowLine)    vidya3[i] = iVidya(Low[i] ,median,CmoPeriod,SmoothPeriod,i,2);
   }
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _vidyaInstances     3
#define _vidyaInstancesSize 3
double  vidya_work[][_vidyaInstances*_vidyaInstancesSize];
#define vidya_price 0
#define vidya_pricc 1
#define vidya_value 2

double iVidya(double price, double pricc, int cmoPeriods, int smoothPeriod, int r, int instanceNo=0)
{
   if (ArrayRange(vidya_work,0)!=Bars) ArrayResize(vidya_work,Bars); r = Bars-r-1; int s = instanceNo*_vidyaInstancesSize;
   
   //
   //
   //    using two prices prevents errors when zone indicator is calculated
   //
   //
   
   vidya_work[r][s+vidya_price] = price;
   vidya_work[r][s+vidya_pricc] = pricc;
          double sumUp = 0, sumDo = 0;
          for (int k=0; k<cmoPeriods && (r-k-1)>=0; k++)
          {
               double diff = vidya_work[r-k][s+vidya_pricc]-vidya_work[r-k-1][s+vidya_pricc];
                  if (diff > 0)
                        sumUp += diff;
                  else  sumDo -= diff;
          }      
          vidya_work[r][s+vidya_value] = (r>0) ? vidya_work[r-1][s+vidya_value]+((((sumUp+sumDo)!=0)?MathAbs((sumUp-sumDo)/(sumUp+sumDo)):1)*2.00/(1.00+MathMax(smoothPeriod,1)))*(vidya_work[r][s+vidya_price]-vidya_work[r-1][s+vidya_value]) : price;
   return(vidya_work[r][s+vidya_value]);
}