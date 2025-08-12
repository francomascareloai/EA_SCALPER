//+------------------------------------------------------------------+
//|                                               SuperTrend nrp.mq4 |
//+------------------------------------------------------------------+
#property copyright "copyleft www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrSandyBrown
#property indicator_color3 clrSandyBrown
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};

extern ENUM_TIMEFRAMES TimeFrame     = PERIOD_CURRENT;
extern int             CCIperiod     = 50;
extern enPrices        applied_price = 5; 
extern int             ATRperiod     = 10;
extern int             Shift         = 0;
extern bool            Interpolate   = true;

//
//
//
//
//

double Trend[];
double TrendDoA[];
double TrendDoB[];
double Direction[];
double prices[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0,Trend);    SetIndexLabel(0,"SuperTrend");
      SetIndexBuffer(1,TrendDoA); SetIndexLabel(1,"SuperTrend");
      SetIndexBuffer(2,TrendDoB); SetIndexLabel(2,"SuperTrend");
      SetIndexBuffer(3,Direction);
      SetIndexBuffer(4,prices);
      
      //
      //
      //
      //
      //
     
        indicatorFileName = WindowExpertName();
        returnBars        = (TimeFrame==-99);
        TimeFrame         = MathMax(TimeFrame,_Period);  
        for (int i=0; i<3; i++) SetIndexShift(i,Shift*TimeFrame/_Period);   
     
      //
      //
      //
      //
      //
     
      IndicatorShortName(timeFrameToString(TimeFrame)+"  SuperTrend nrp");
return(0);
}  
int deinit() {  return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int k,n,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1); 
           if (returnBars) { Trend[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame==Period())
   {
     if (Direction[limit] == -1) CleanPoint(limit,TrendDoA,TrendDoB);
     for(int i=limit; i>=0; i--)
     {
         prices[i] = getPrice(applied_price,Open,Close,High,Low,i);
         double avg      = 0; for(k=0; k<CCIperiod; k++) avg +=         prices[i+k];      avg /= CCIperiod;
         double dev      = 0; for(k=0; k<CCIperiod; k++) dev += MathAbs(prices[i+k]-avg); dev /= CCIperiod;
         double cciTrend = 0;
            if (dev!=0)
                  cciTrend = (prices[i]-avg)/(0.015*dev);
         
         //
         //
         //
         //
         //
         
         TrendDoA[i]  = EMPTY_VALUE;
         TrendDoB[i]  = EMPTY_VALUE;
         Trend[i]     = Trend[i+1];
         Direction[i] = Direction[i+1];
            if (cciTrend > 0) { Trend[i] = MathMax(Low[i]  - iATR(NULL,0,ATRperiod,i),Trend[i+1]); Direction[i] =  1; }
            if (cciTrend < 0) { Trend[i] = MathMin(High[i] + iATR(NULL,0,ATRperiod,i),Trend[i+1]); Direction[i] = -1; }
            if (Direction[i]==-1) PlotPoint(i,TrendDoA,TrendDoB,Trend);
   }
   return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (Direction[limit] == -1) CleanPoint(limit,TrendDoA,TrendDoB);
   for (i=limit;i>=0; i--)
   {
       int y = iBarShift(NULL,TimeFrame,Time[i]);
          Trend[i]     = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CCIperiod,applied_price,ATRperiod,0,0,y);
          Direction[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CCIperiod,applied_price,ATRperiod,0,3,y);
          TrendDoA[i]  = EMPTY_VALUE;
          TrendDoB[i]  = EMPTY_VALUE;
            if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

            //
            //
            //
            //
            //

            datetime time = iTime(NULL,TimeFrame,y);
               for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(k = 1; k < n; k++)
                  Trend[i+k] = Trend[i] + (Trend[i+n] - Trend[i])   *k/n;
   }
   for (i=limit;i>=0;i--) if (Direction[i] == -1) PlotPoint(i,TrendDoA,TrendDoB,Trend);
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
      if (first[i+2] == EMPTY_VALUE) {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose)
 {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars);
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (price)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
   }
   return(0);
}