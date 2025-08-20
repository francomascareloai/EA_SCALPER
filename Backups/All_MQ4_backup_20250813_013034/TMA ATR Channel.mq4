//Revisions by Trainman, July 26, 2012
#property copyright "Extreme TMA System"
#property link      "http://www.forexfactory.com/showthread.php?t=343533m"
// 8/14/19 revised by Banzai @ https://forex-station.com/viewtopic.php?p=1295394026#p1295394026
// not for sale, auction, rent, nor lease

#property indicator_chart_window
#property indicator_buffers    18
#property indicator_color1     DimGray
#property indicator_color2     HotPink
#property indicator_color3     SpringGreen
#property indicator_color4     HotPink
#property indicator_color5     SpringGreen
#property indicator_color6     HotPink
#property indicator_color7     SpringGreen
#property indicator_color8     HotPink
#property indicator_color9     SpringGreen
#property indicator_color10     HotPink
#property indicator_color11     SpringGreen
#property indicator_color12     HotPink
#property indicator_color13     SpringGreen
#property indicator_color14     HotPink
#property indicator_color15     SpringGreen
#property indicator_color16     Lime
#property indicator_color17     Red
#property indicator_color18     Gold
#property indicator_style2     STYLE_DOT
#property indicator_style3     STYLE_DOT
#property indicator_style4     STYLE_DOT
#property indicator_style5     STYLE_DOT
#property indicator_style6     STYLE_DOT
#property indicator_style7     STYLE_DOT
#property indicator_style8     STYLE_DOT
#property indicator_style9     STYLE_DOT
#property indicator_style10     STYLE_DOT
#property indicator_style11     STYLE_DOT
#property indicator_style12     STYLE_SOLID
#property indicator_style13     STYLE_SOLID
#property indicator_style14     STYLE_SOLID
#property indicator_style15     STYLE_SOLID
#property  indicator_width1 1
#property  indicator_width2 1
#property  indicator_width3 1
#property  indicator_width4 1
#property  indicator_width5 1
#property  indicator_width6 1
#property  indicator_width7 1
#property  indicator_width8 1
#property  indicator_width9 1
#property  indicator_width10 1
#property  indicator_width11 1
#property  indicator_width12 1
#property  indicator_width13 1
#property  indicator_width14 2
#property  indicator_width15 2
#property  indicator_width16 3
#property  indicator_width17 3
#property  indicator_width18 3

#define PIPSTOFORCERECALC 10

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;
extern int    TMAPeriod      = 20;
extern ENUM_APPLIED_PRICE    Price           = PRICE_CLOSE;
extern int    ATRPeriod       = 100;
extern double TrendThreshold = 0.25;
extern bool ShowCenterLine = true;
extern double ATRMultiplier   = 1.618;
extern double ATRMultiplier2  = 2.0;
extern double ATRMultiplier3  = 2.236;
extern double ATRMultiplier4  = 2.5;
extern double ATRMultiplier5  = 2.618;
extern double ATRMultiplier6  = 3.0;
extern double ATRMultiplier7  = 3.236;

extern bool   alertsOn        = false;
extern bool   alertsMessage   = false;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern bool   MoveEndpointEveryTick = false;
extern int    MaxBarsBack     = 5000;


double tma[];
double upperBand[], upperBand2[], upperBand3[], upperBand4[], upperBand5[], upperBand6[], upperBand7[];
double lowerBand[], lowerBand2[], lowerBand3[], lowerBand4[], lowerBand5[], lowerBand6[], lowerBand7[];
double bull[];
double bear[];
double neutral[];
 
int    FirstAvailableBar;
bool AlertHappened;
datetime AlertTime;
double TICK;
bool AdditionalDigit;
double  SumTMAPeriod,
        TickScaleFactor,
        Threshold,
        PriorTick,
        FullSumW;

int init()
{
  AdditionalDigit = MarketInfo(Symbol(), MODE_MARGINCALCMODE) == 0 && MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0 && Digits % 2 == 1;

  TICK = MarketInfo(Symbol(), MODE_TICKSIZE);
  if (AdditionalDigit)
    TICK *= 10;

  TimeFrame         = fmax(TimeFrame,_Period);
             
  IndicatorBuffers(18); 
  SetIndexBuffer(0,tma); 
  SetIndexBuffer(1,upperBand); 
  SetIndexBuffer(2,lowerBand); 
  SetIndexBuffer(3,upperBand2); 
  SetIndexBuffer(4,lowerBand2); 
  SetIndexBuffer(5,upperBand3); 
  SetIndexBuffer(6,lowerBand3); 
  SetIndexBuffer(7,upperBand4); 
  SetIndexBuffer(8,lowerBand4); 
  SetIndexBuffer(9,upperBand5); 
  SetIndexBuffer(10,lowerBand5); 
  SetIndexBuffer(11,upperBand6); 
  SetIndexBuffer(12,lowerBand6); 
  SetIndexBuffer(13,upperBand7); 
  SetIndexBuffer(14,lowerBand7); 
  SetIndexBuffer(15,bull); 
  SetIndexBuffer(16,bear); 
  SetIndexBuffer(17,neutral); 
  
  //SetIndexLabel(0, "FastTMA " + TimeFrame + ")");  
  SetIndexLabel(1, "FastTMA " + TimeFrame + " Upper line");  
  SetIndexLabel(2, "FastTMA " + TimeFrame + " Lower line");  
  SetIndexLabel(3, "FastTMA " + TimeFrame + " Upper line");  
  SetIndexLabel(4, "FastTMA " + TimeFrame + " Lower line");  
  SetIndexLabel(5, "FastTMA " + TimeFrame + " Upper line");  
  SetIndexLabel(6, "FastTMA " + TimeFrame + " Lower line");  
  SetIndexLabel(7, "FastTMA " + TimeFrame + " Upper line");  
  SetIndexLabel(8, "FastTMA " + TimeFrame + " Lower line");  
  SetIndexLabel(9, "FastTMA " + TimeFrame + " Upper line");  
  SetIndexLabel(10, "FastTMA " + TimeFrame + " Lower line");  
  SetIndexLabel(11, "FastTMA " + TimeFrame + " Upper line");  
  SetIndexLabel(12, "FastTMA " + TimeFrame + " Lower line");  
  SetIndexLabel(13, "FastTMA " + TimeFrame + " Upper line");  
  SetIndexLabel(14, "FastTMA " + TimeFrame + " Lower line");  
  SetIndexLabel(15, "FastTMA(" + TimeFrame + ")");  
  SetIndexLabel(16, "FastTMA(" + TimeFrame + ")");  
  SetIndexLabel(17, "FastTMA(" + TimeFrame + ")");  

  IndicatorShortName(TimeFrameToString(TimeFrame)+" TMA bands ("+TMAPeriod+")");
  SumTMAPeriod = 0;
  for (int i = 1; i <= TMAPeriod; i++)
    SumTMAPeriod += i;
  FullSumW = TMAPeriod + 1 + 2 * SumTMAPeriod;
  TickScaleFactor = (TMAPeriod + 1) / (TMAPeriod + 1 + SumTMAPeriod); // relative weight of latest tick
  PriorTick = Close[0];
  if (Digits < 4)
    Threshold = PIPSTOFORCERECALC * 0.01;
  else
    Threshold = PIPSTOFORCERECALC * 0.0001;
    
  FirstAvailableBar = iBars(NULL, TimeFrame) - TMAPeriod - 1;
  return(0);
}
int deinit() { return(0); }


int start()
{
  int counted_bars=IndicatorCounted();
  if(counted_bars<0) return(-1);
  if(Period() > TimeFrame) 
    return(0); // don't plot lower TFs on upper TF charts

  int i,limit;
  static double PriceAtFullRecalc = 0;
  static double range, range2, range3, range4, range5, range6, range7 = 0;
  static double slope, slope2, slope3, slope4, slope5, slope6, slope7 = 0;
  // if (uncounted bars are zero and price change is small)
  if (((Bars - counted_bars) == 1) && (MathAbs(Close[0] - PriceAtFullRecalc) < Threshold))
    {
    if (MoveEndpointEveryTick)
      { // incremental change to end point
      tma[0] = CalcTmaUpdate(tma[0]);
      upperBand[0] = tma[0] + range;
      lowerBand[0] = tma[0] - range;
      DrawCenterLine(0, slope);   
      upperBand2[0] = tma[0] + range2;
      lowerBand2[0] = tma[0] - range2;
      DrawCenterLine(0, slope2);   
      upperBand3[0] = tma[0] + range3;
      lowerBand3[0] = tma[0] - range3;
      DrawCenterLine(0, slope3);   
      upperBand4[0] = tma[0] + range4;
      lowerBand4[0] = tma[0] - range4;
      DrawCenterLine(0, slope4);   
      upperBand5[0] = tma[0] + range5;
      lowerBand5[0] = tma[0] - range5;
      DrawCenterLine(0, slope5);   
      upperBand6[0] = tma[0] + range6;
      lowerBand6[0] = tma[0] - range6;
      DrawCenterLine(0, slope6);   
      upperBand7[0] = tma[0] + range7;
      lowerBand7[0] = tma[0] - range7;
      DrawCenterLine(0, slope7);   
      }
    else
      return(0);
    }
  else // complete recalculation
    {
    PriceAtFullRecalc = Close[0];
    if(counted_bars>0) counted_bars--;
    double barsPerTma = (TimeFrame / Period());
    limit=MathMin(Bars-1, MaxBarsBack); 
    limit=MathMin(limit,Bars-counted_bars+ TMAPeriod * barsPerTma ); 
   
    int mtfShift = 0;
    int lastMtfShift = 999;
    double prevTma = tma[limit+1];
    double tmaVal = tma[limit+1];
    for (i=limit; i>=0; i--)
      {
      if (TimeFrame == Period())
        {
        mtfShift = i;
        }
      else
        {         
        mtfShift = iBarShift(Symbol(),TimeFrame,Time[i]);
        } 
      
      if (mtfShift > FirstAvailableBar) continue; // exceeded available historical data
      if(mtfShift == lastMtfShift)
        {       
        tma[i] =tma[i+1] + ((tmaVal - prevTma) * (1/barsPerTma));         
        upperBand[i] = tma[i] + range;
        lowerBand[i] = tma[i] - range;
        DrawCenterLine(i, slope);   
        upperBand2[i] = tma[i] + range2;
        lowerBand2[i] = tma[i] - range2;
        DrawCenterLine(i, slope2);   
        upperBand3[i] = tma[i] + range3;
        lowerBand3[i] = tma[i] - range3;
        DrawCenterLine(i, slope3);   
        upperBand4[i] = tma[i] + range4;
        lowerBand4[i] = tma[i] - range4;
        DrawCenterLine(i, slope4);   
        upperBand5[i] = tma[i] + range5;
        lowerBand5[i] = tma[i] - range5;
        DrawCenterLine(i, slope5);   
        upperBand6[i] = tma[i] + range6;
        lowerBand6[i] = tma[i] - range6;
        DrawCenterLine(i, slope6);   
        upperBand7[i] = tma[i] + range7;
        lowerBand7[i] = tma[i] - range7;
        DrawCenterLine(i, slope7);   
        continue;
        }
      
      lastMtfShift = mtfShift;
      prevTma = tmaVal;
      tmaVal = CalcTma(mtfShift);
      
      range = iATR(NULL,TimeFrame,ATRPeriod,mtfShift+10)*ATRMultiplier;
      if(range == 0) range = 1;
      range2 = iATR(NULL,TimeFrame,ATRPeriod,mtfShift+10)*ATRMultiplier2;
      if(range2 == 0) range2 = 1;
      range3 = iATR(NULL,TimeFrame,ATRPeriod,mtfShift+10)*ATRMultiplier3;
      if(range3 == 0) range3 = 1;
      range4 = iATR(NULL,TimeFrame,ATRPeriod,mtfShift+10)*ATRMultiplier4;
      if(range4 == 0) range4 = 1;
      range5 = iATR(NULL,TimeFrame,ATRPeriod,mtfShift+10)*ATRMultiplier5;
      if(range5 == 0) range5 = 1;
      range6 = iATR(NULL,TimeFrame,ATRPeriod,mtfShift+10)*ATRMultiplier6;
      if(range6 == 0) range6 = 1;
      range7 = iATR(NULL,TimeFrame,ATRPeriod,mtfShift+10)*ATRMultiplier7;
      if(range7 == 0) range7 = 1;
      
      if (barsPerTma > 1)
        {
        tma[i] =prevTma + ((tmaVal - prevTma) * (1/barsPerTma));
        }
      else
        {
        tma[i] =tmaVal;
        }
      upperBand[i] = tma[i]+range;
      lowerBand[i] = tma[i]-range;
      upperBand2[i] = tma[i]+range2;
      lowerBand2[i] = tma[i]-range2;
      upperBand3[i] = tma[i]+range3;
      lowerBand3[i] = tma[i]-range3;
      upperBand4[i] = tma[i]+range4;
      lowerBand4[i] = tma[i]-range4;
      upperBand5[i] = tma[i]+range5;
      lowerBand5[i] = tma[i]-range5;
      upperBand6[i] = tma[i]+range6;
      lowerBand6[i] = tma[i]-range6;
      upperBand7[i] = tma[i]+range7;
      lowerBand7[i] = tma[i]-range7;

      slope = (tmaVal-prevTma) / ((range / ATRMultiplier) * 0.1);
      slope2 = (tmaVal-prevTma) / ((range2 / ATRMultiplier2) * 0.1);
      slope3 = (tmaVal-prevTma) / ((range3 / ATRMultiplier3) * 0.1);
      slope4 = (tmaVal-prevTma) / ((range4 / ATRMultiplier4) * 0.1);
      slope5 = (tmaVal-prevTma) / ((range5 / ATRMultiplier5) * 0.1);
      slope6 = (tmaVal-prevTma) / ((range6 / ATRMultiplier6) * 0.1);
      slope7 = (tmaVal-prevTma) / ((range7 / ATRMultiplier7) * 0.1);
            
      DrawCenterLine(i, slope);
      DrawCenterLine(i, slope2);
      DrawCenterLine(i, slope3);
      DrawCenterLine(i, slope4);
      DrawCenterLine(i, slope5);
      DrawCenterLine(i, slope6);
      DrawCenterLine(i, slope7);
          
      }
    }

   manageAlerts();
   return(0);
}

void DrawCenterLine(int shift, double slope)
{

   bull[shift] = EMPTY_VALUE;
   bear[shift] = EMPTY_VALUE;          
   neutral[shift] = EMPTY_VALUE; 
   if (ShowCenterLine)
   {
      if(slope > TrendThreshold)
      {
         bull[shift] = tma[shift];
      }
      else if(slope < -1 * TrendThreshold)
      {
         bear[shift] = tma[shift];
      }
      else
      {
         neutral[shift] = tma[shift];
      }
   }
}


//---------------------------------------------------------------------
double CalcTma( int inx )
  {
  double tma2;
  if(inx >= TMAPeriod)
    tma2 = CalcPureTma(inx);
  else
    tma2 = CalcTmaEstimate(inx);
  return( tma2 );
  }
  
//---------------------------------------------------------------------
double CalcPureTma( int i )
  {
  int j = TMAPeriod + 1; 
  int k;
  double sum=0;
  switch (Price)
         {
         case     0:sum=j * iClose(NULL, TimeFrame, i);break;
         case     1:sum=j * iOpen(NULL, TimeFrame, i);break;
         case     2:sum=j * iHigh(NULL, TimeFrame, i);break;
         case     3:sum=j * iLow(NULL, TimeFrame, i);break;
         case     4:sum=j * (iHigh(NULL, TimeFrame, i)+iLow(NULL, TimeFrame, i))/2;break;
         case     5:sum=j * (iHigh(NULL, TimeFrame, i)+iLow(NULL, TimeFrame, i)+iClose(NULL, TimeFrame, i))/3;break;
         case     6:sum=j * (iHigh(NULL, TimeFrame, i)+iLow(NULL, TimeFrame, i)+iClose(NULL, TimeFrame, i)+iClose(NULL, TimeFrame, i))/4;break;
         default   :sum=j * iClose(NULL, TimeFrame, i);break;
         }
  
  for    (k = 1; k <= TMAPeriod; k++)
         {
         switch(Price)
               {
               case     0:sum = sum + (j - k) * (iClose(NULL, TimeFrame, i+k) + iClose(NULL, TimeFrame, i-k));break;
               case     1:sum = sum + (j - k) * (iOpen(NULL, TimeFrame, i+k) + iOpen(NULL, TimeFrame, i-k));break;
               case     2:sum = sum + (j - k) * (iHigh(NULL, TimeFrame, i+k) + iHigh(NULL, TimeFrame, i-k));break;
               case     3:sum = sum + (j - k) * (iLow(NULL, TimeFrame, i+k) + iLow(NULL, TimeFrame, i-k));break;
               
               case     4:sum = sum + (j - k) * ( 
                                                (iHigh(NULL, TimeFrame, i+k) + iLow(NULL, TimeFrame, i+k))/2 + 
                                                (iHigh(NULL, TimeFrame, i-k) + iLow(NULL, TimeFrame, i-k))/2
                                                );break;
               
               case     5:sum = sum + (j - k) * ( 
                                                (iHigh(NULL, TimeFrame, i+k) + iLow(NULL, TimeFrame, i+k) + iClose(NULL, TimeFrame, i+k))/3 + 
                                                (iHigh(NULL, TimeFrame, i-k) + iLow(NULL, TimeFrame, i-k) + iClose(NULL, TimeFrame, i-k))/3
                                                );break;
               
               case     6:sum = sum + (j - k) * ( 
                                                (iHigh(NULL, TimeFrame, i+k) + iLow(NULL, TimeFrame, i+k) + iClose(NULL, TimeFrame, i+k) + iClose(NULL, TimeFrame, i+k))/4 + 
                                                (iHigh(NULL, TimeFrame, i-k) + iLow(NULL, TimeFrame, i-k) + iClose(NULL, TimeFrame, i-k) + iClose(NULL, TimeFrame, i-k))/4
                                                );break;
               
               default   :sum = sum + (j - k) * (iClose(NULL, TimeFrame, i+k) + iClose(NULL, TimeFrame, i-k));break;
               }
         }        
  return( sum / FullSumW );
  }

//---------------------------------------------------------------------
double CalcTmaEstimate( int i )
//only returns correct result if i <= TMAPeriod
  {
  double sum = 0;
  double sumW;
  int k,
      j = TMAPeriod + 1;
      sumW = 0;
  // compute left half
  for (k = 0; k <= TMAPeriod; k++)
      {
      switch(Price)
         {  case     0: sum += (j - k) * iClose(NULL, TimeFrame, i+k);
                        sumW += (j - k);break;
            case     1: sum += (j - k) * iOpen(NULL, TimeFrame, i+k);
                        sumW += (j - k);break;
            case     2: sum += (j - k) * iHigh(NULL, TimeFrame, i+k);
                        sumW += (j - k);break;
            case     3: sum += (j - k) * iLow(NULL, TimeFrame, i+k);
                        sumW += (j - k);break;
            case     4: sum += (j - k) * (   (  iHigh(NULL, TimeFrame, i+k) + 
                                                iLow(NULL,TimeFrame, i+k)
                                             )/2
                                         );
                        sumW += (j - k);break;
            case     5: sum += (j - k) * (   (  iHigh(NULL, TimeFrame, i+k) + 
                                                iLow(NULL,TimeFrame, i+k) +
                                                iClose(NULL,TimeFrame, i+k)
                                             )/3
                                         );
                        sumW += (j - k);break;
            case     6: sum += (j - k) * (   (  iHigh(NULL, TimeFrame, i+k) + 
                                                iLow(NULL,TimeFrame, i+k) +
                                                iClose(NULL,TimeFrame, i+k) +
                                                iClose(NULL,TimeFrame, i+k)
                                             )/4
                                         );
                        sumW += (j - k);break;
            
            default   : sum += (j - k) * iClose(NULL, TimeFrame, i+k);
                        sumW += (j - k);break;
         }                          
    }
  // compute right half
  j = TMAPeriod;
  for (k = i-1; k >= 0; k--)
      {
      switch(Price)
         {  case     0: sum += j * iClose(NULL, TimeFrame, k);
                        sumW += j;break;
            case     1: sum += j * iOpen(NULL, TimeFrame, k);
                        sumW += j;break;
            case     2: sum += j * iHigh(NULL, TimeFrame, k);
                        sumW += j;break;
            case     3: sum += j * iLow(NULL, TimeFrame, k);
                        sumW += j;break;
            case     4: sum += j *        (   ( iHigh(NULL, TimeFrame, k) +
                                                iLow(NULL, TimeFrame, k)
                                              )/2
                                          );
                        sumW += j;break;
            case     5: sum += j *        (   ( iHigh(NULL, TimeFrame, k) +
                                                iLow(NULL, TimeFrame, k) +
                                                iClose(NULL, TimeFrame, k)
                                              )/3
                                          );
                        sumW += j;break;
            case     6: sum += j *        (   ( iHigh(NULL, TimeFrame, k) +
                                                iLow(NULL, TimeFrame, k) +
                                                iClose(NULL, TimeFrame, k) +
                                                iClose(NULL, TimeFrame, k)
                                              )/4
                                          );
                        sumW += j;break;
            
            default   : sum += j * iClose(NULL, TimeFrame, k);
                        sumW += j;break;
                        
         }               
      j--;
      }
      switch(Price)
         {  case 0   :PriorTick = Close[0];break;
            case 1   :PriorTick = Open[0];break;
            case 2   :PriorTick = High[0];break;
            case 3   :PriorTick = Low[0];break;
            case 4   :PriorTick = (High[0]+Low[0])/2;break;
            case 5   :PriorTick = (High[0]+Low[0]+Close[0])/3;break;
            case 6   :PriorTick = (High[0]+Low[0]+Close[0]+Close[0])/4;break;
            default  :PriorTick = Close[0];break;
         }
  return( sum / sumW );
  }

//---------------------------------------------------------------------
// if the next tick arrives but it still goes in the same bar, this
// function updates the latest value without a complete recalculation
double CalcTmaUpdate( double PreviousTma )
  {
  double r;
  switch(Price)
      {  case 0   :  r = PreviousTma + (Close[0] - PriorTick) * TickScaleFactor;
                     PriorTick = Close[0];
                     break;
         case 1   :  r = PreviousTma + (Open[0] - PriorTick) * TickScaleFactor;
                     PriorTick = Open[0];
                     break;
         case 2   :  r = PreviousTma + (High[0] - PriorTick) * TickScaleFactor;
                     PriorTick = High[0];
                     break;
         case 3   :  r = PreviousTma + (Low[0] - PriorTick) * TickScaleFactor;
                     PriorTick = Low[0];
                     break;
         case 4   :  r = PreviousTma + ((High[0]+Low[0])/2 - PriorTick) * TickScaleFactor;
                     PriorTick = (High[0]+Low[0])/2;
                     break;
         case 5   :  r = PreviousTma + ((High[0]+Low[0]+Close[0])/3 - PriorTick) * TickScaleFactor;
                     PriorTick = (High[0]+Low[0]+Close[0])/3;
                     break;
         case 6   :  r = PreviousTma + ((High[0]+Low[0]+Close[0]+Close[0])/4 - PriorTick) * TickScaleFactor;
                     PriorTick = (High[0]+Low[0]+Close[0]+Close[0])/4;
                     break;
         
         default  :  r = PreviousTma + (Close[0] - PriorTick) * TickScaleFactor;
                     PriorTick = Close[0];
                     break;
      }            
  return( r );
  }
//---------------------------------------------------------------------

void manageAlerts()
{
   if (alertsOn)
   { 
      int trend;        
      if (Close[0] > upperBand[0]) trend =  1;
      else if (Close[0] < lowerBand[0]) trend = -1;
      if (Close[0] > upperBand2[0]) trend =  1;
      else if (Close[0] < lowerBand2[0]) trend = -1;
      if (Close[0] > upperBand3[0]) trend =  1;
      else if (Close[0] < lowerBand3[0]) trend = -1;
      if (Close[0] > upperBand4[0]) trend =  1;
      else if (Close[0] < lowerBand4[0]) trend = -1;
      if (Close[0] > upperBand5[0]) trend =  1;
      else if (Close[0] < lowerBand5[0]) trend = -1;
      if (Close[0] > upperBand6[0]) trend =  1;
      else if (Close[0] < lowerBand6[0]) trend = -1;
      if (Close[0] > upperBand7[0]) trend =  1;
      else if (Close[0] < lowerBand7[0]) trend = -1;
      else {AlertHappened = false;}
            
      if (!AlertHappened && AlertTime != Time[0])
      {       
         if (trend == 1) doAlert("up");
         if (trend ==-1) doAlert("down");
      }         
   }
}


void doAlert(string doWhat)
{ 
   if (AlertHappened) return;
   AlertHappened = true;
   AlertTime = Time[0];
   string message;
     
   message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," "+TimeFrameToString(TimeFrame)+" TMA bands price penetrated ",doWhat," band");
   if (alertsMessage) Alert(message);
   if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TMA bands "),message);
   if (alertsSound)   PlaySound("alert2.wav");

}

//+-------------------------------------------------------------------
//|   Time Frame Handlers                                                               
//+-------------------------------------------------------------------


string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};


int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
   {
      if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) 
      {
//         return(MathMax(iTfTable[i],Period()));
         return(iTfTable[i]);
      }
   }
   return(Period());
   
}
string TimeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int charcode = StringGetChar(s, length);
         if((charcode > 96 && charcode < 123) || (charcode > 223 && charcode < 256))
                     s = StringSetChar(s, length, charcode - 32);
         else if(charcode > -33 && charcode < 0)
                     s = StringSetChar(s, length, charcode + 224);
   }
   return(s);
}