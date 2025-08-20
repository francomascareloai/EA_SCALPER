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
   do_rsi,  // Make rsi using adxvma as price filter
   do_nma   // Make adxvma smoothed rsi
};

extern ENUM_TIMEFRAMES TimeFrame   = PERIOD_CURRENT; // Time frame to use
extern int             pperiod      = 14;            // Calculating period
extern enPrices        pprice       = pr_close;      // Price
extern int             psmooth      = 1;             // Price smoothing
extern int             filter       = 10;            // adxvma period 
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
   IndicatorShortName(timeFrameToString(TimeFrame)+" rsi adxvma ("+(string)pperiod+","+(string)filter+")");
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
                  buffer[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,psmooth,filter,doWhat,0,y);
                  trend[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,psmooth,filter,doWhat,3,y);
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
            buffer[i] = iRsi(iAdxvma(iSsm(getPrice(pprice,Open,Close,High,Low,i),psmooth,i),filter,i),pperiod,i);
      else  buffer[i] = iAdxvma(iRsi(iSsm(getPrice(pprice,Open,Close,High,Low,i),psmooth,i),pperiod,i),filter,i);
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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define adxvmaInstances 1
double  adxvmaWork[][adxvmaInstances*7];
#define _adxvmaWprc 0
#define _adxvmaWpdm 1
#define _adxvmaWmdm 2
#define _adxvmaWpdi 3
#define _adxvmaWmdi 4
#define _adxvmaWout 5
#define _adxvmaWval 6

double iAdxvma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(adxvmaWork,0)!=Bars) ArrayResize(adxvmaWork,Bars); r=Bars-r-1; instanceNo*=7;
   
   //
   //
   //
   //
   //
   
   adxvmaWork[r][instanceNo+_adxvmaWprc] = price;
   if (r<1) 
   { 
      adxvmaWork[r][instanceNo+_adxvmaWval] = adxvmaWork[r][instanceNo+_adxvmaWprc]; 
            return(adxvmaWork[r][_adxvmaWval]); 
   }

   //
   //
   //
   //
   //
      
      double tpdm = 0;
      double tmdm = 0;
      double diff = adxvmaWork[r][instanceNo+_adxvmaWprc]-adxvmaWork[r-1][instanceNo+_adxvmaWprc];
      if (diff>0)
            tpdm =  diff;
      else  tmdm = -diff;          
      adxvmaWork[r][instanceNo+_adxvmaWpdm] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdm]+tpdm)/period;
      adxvmaWork[r][instanceNo+_adxvmaWmdm] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdm]+tmdm)/period;

      //
      //
      //
      //
      //

         double trueRange = adxvmaWork[r][instanceNo+_adxvmaWpdm]+adxvmaWork[r][instanceNo+_adxvmaWmdm];
         double tpdi      = 0;
         double tmdi      = 0;
               if (trueRange>0)
               {
                  tpdi = adxvmaWork[r][instanceNo+_adxvmaWpdm]/trueRange;
                  tmdi = adxvmaWork[r][instanceNo+_adxvmaWmdm]/trueRange;
               }            
         adxvmaWork[r][instanceNo+_adxvmaWpdi] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdi]+tpdi)/period;
         adxvmaWork[r][instanceNo+_adxvmaWmdi] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdi]+tmdi)/period;
   
         //
         //
         //
         //
         //
                  
         double tout  = 0; 
            if ((adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi])>0) 
                  tout = MathAbs(adxvmaWork[r][instanceNo+_adxvmaWpdi]-adxvmaWork[r][instanceNo+_adxvmaWmdi])/(adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi]);
                                 adxvmaWork[r][instanceNo+_adxvmaWout] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWout]+tout)/period;

         //
         //
         //
         //
         //
                 
         double thi = MathMax(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
         double tlo = MathMin(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
            for (int j = 2; j<period && r-j>=0; j++)
            {
               thi = MathMax(adxvmaWork[r-j][instanceNo+_adxvmaWout],thi);
               tlo = MathMin(adxvmaWork[r-j][instanceNo+_adxvmaWout],tlo);
            }            
         double vi = 0; if ((thi-tlo)>0) vi = (adxvmaWork[r][instanceNo+_adxvmaWout]-tlo)/(thi-tlo);

         //
         //
         //
         //
         //
         
          adxvmaWork[r][instanceNo+_adxvmaWval] = ((period-vi)*adxvmaWork[r-1][instanceNo+_adxvmaWval]+vi*adxvmaWork[r][instanceNo+_adxvmaWprc])/period;
   return(adxvmaWork[r][instanceNo+_adxvmaWval]);
}

//
//
//
//
//

#define Pi 3.14159265358979323846264338327950288
double workSsm[][2];
#define _tprice  0
#define _ssm     1

double workSsmCoeffs[][4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3

double iSsm(double price, double period, int i, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_speriod] != period)
   {
      workSsmCoeffs[instanceNo][_speriod] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_sc2] = b1;
         workSsmCoeffs[instanceNo][_sc3] = -a1*a1;
         workSsmCoeffs[instanceNo][_sc1] = 1.0 - workSsmCoeffs[instanceNo][_sc2] - workSsmCoeffs[instanceNo][_sc3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2; i = Bars-i-1;
      workSsm[i][s+_ssm]    = price;
      workSsm[i][s+_tprice] = price;
      if (i>1)
      {  
          workSsm[i][s+_ssm] = workSsmCoeffs[instanceNo][_sc1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                               workSsmCoeffs[instanceNo][_sc2]*workSsm[i-1][s+_ssm]                                + 
                               workSsmCoeffs[instanceNo][_sc3]*workSsm[i-2][s+_ssm]; }
   return(workSsm[i][s+_ssm]);
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