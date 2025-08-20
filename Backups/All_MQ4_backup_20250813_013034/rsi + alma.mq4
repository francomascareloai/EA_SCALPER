//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrSandyBrown
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property strict

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
enum enDoWhat
{
   do_rsi,  // Make rsi using alma as price filter
   do_nma   // Make alma smoothed rsi
};

extern ENUM_TIMEFRAMES TimeFrame   = PERIOD_CURRENT; // Time frame to use
extern int             pperiod      = 14;            // Calculating period
extern enPrices        pprice       = pr_close;      // Price
extern int             AlmaPeriod   = 32;            // Alma period
extern double          AlmaSigma    = 6.0;           // Alma sigma
extern double          AlmaSample   = 0.25;          // Alma sample
extern enDoWhat        doWhat       = do_rsi;        // Make what?
extern int             linesWidth   =  3;            // Lines width
extern bool            Interpolate  = true;          // Interpolate in multi time frame mode?


double buffer[];
double bufferda[];
double bufferdb[];
double trend[];
string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(4);
   SetIndexBuffer(0,buffer,  INDICATOR_DATA); SetIndexStyle(0,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(1,bufferda,INDICATOR_DATA); SetIndexStyle(1,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(2,bufferdb,INDICATOR_DATA); SetIndexStyle(2,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(3,trend   ,INDICATOR_CALCULATIONS);
            indicatorFileName = WindowExpertName();
            returnBars        = TimeFrame==-99;
            TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" rsi alma ("+(string)pperiod+","+(string)AlmaPeriod+")");
   return(0);
}

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit=MathMin(Bars-counted_bars,Bars-2);
            if (returnBars) { buffer[0] = MathMin(limit+1,Bars-1); return(0); }
            if (TimeFrame != Period())
            {
               if (trend[limit]==-1) CleanPoint(limit,bufferda,bufferdb);
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  buffer[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,AlmaPeriod,AlmaSigma,AlmaSample,doWhat,0,y);
                  trend[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,AlmaPeriod,AlmaSigma,AlmaSample,doWhat,3,y);
                  bufferda[i] = EMPTY_VALUE;
                  bufferdb[i] = EMPTY_VALUE;
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  int n,k; datetime time = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                     for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           buffer[i+k] = buffer[i] + (buffer[i+n] - buffer[i]) * k/n;
               }
               for(int i=limit; i>=0; i--) if (trend[i] == -1) PlotPoint(i,bufferda,bufferdb,buffer);
               return(0);
            }

   //
   //
   //
   //
   //

   if (trend[limit]==-1) CleanPoint(limit,bufferda,bufferdb);
   for(int i=limit; i>=0; i--)
   {
      if (doWhat==do_rsi)
            buffer[i] = iRsi(iAlma(getPrice(pprice,Open,Close,High,Low,i),AlmaPeriod,AlmaSigma,AlmaSample,i),pperiod,i);
      else  buffer[i] = iAlma(iRsi(getPrice(pprice,Open,Close,High,Low,i),pperiod,i),AlmaPeriod,AlmaSigma,AlmaSample,i);
      bufferda[i] = EMPTY_VALUE;
      bufferdb[i] = EMPTY_VALUE;
      trend[i]    = trend[i+1];
      
         //
         //
         //
         //
         //
         
         if (buffer[i]>buffer[i+1]) trend[i] =  1;
         if (buffer[i]<buffer[i+1]) trend[i] = -1;
         if (trend[i] == -1) PlotPoint(i,bufferda,bufferdb,buffer);
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
//

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

double iRsi(double price, double period, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*3; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
         double alpha = 1.0/period; 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
   
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define almaInstances 1
double  almaWork[][almaInstances];
double iAlma(double price, int period, double sigma, double sample, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(almaWork,0)!=Bars) ArrayResize(almaWork,Bars); r=Bars-r-1; almaWork[r][instanceNo] = price;
   
   //
   //
   //
   //
   //

   double m = MathFloor(sample * (period - 1.0));
   double s = period/sigma, sum=0, div=0;
   for (int i=0; i<period && (r-i)>=0; i++)
      {
         double coeff = MathExp(-((i-m)*(i-m))/(2.0*s*s));
            sum += coeff*almaWork[r-i][instanceNo];
            div += coeff;
      }
   double talma = price; if (div!=0) talma = sum/div;
   return(talma);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
         {
            if (first[i+2] == EMPTY_VALUE) 
                  { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
            else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
         }
   else  { first[i] = from[i]; second[i] = EMPTY_VALUE; }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

double workHa[][4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
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
         
         switch (tprice)
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
   
   switch (tprice)
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}