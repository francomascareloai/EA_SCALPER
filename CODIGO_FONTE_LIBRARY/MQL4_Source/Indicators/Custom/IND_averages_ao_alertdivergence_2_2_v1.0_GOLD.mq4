#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"


#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     MediumVioletRed
#property indicator_color2     MediumVioletRed
#property indicator_color3     LimeGreen
#property indicator_color4     LimeGreen
#property indicator_color5     Gold
#property indicator_width1     2
#property indicator_width3     2
#property indicator_width5     2
#property indicator_levelcolor DarkSlateGray

//
//
//
//
//

extern string TimeFrame                 = "Current time frame";
extern int    FastMaPeriod              = 5;
extern int    FastMaMode                = MODE_EMA;
extern int    SlowMaPeriod              = 34;
extern int    SlowMaMode                = MODE_EMA;
extern int    AoPrice                   = PRICE_MEDIAN;
extern bool   divergenceVisible         = true;
extern bool   divergenceOnValuesVisible = true;
extern bool   divergenceOnChartVisible  = true;
extern color  divergenceBullishColor    = Green;
extern color  divergenceBearishColor    = Red;
extern string divergenceUniqueID        = "AO divergence1";
extern bool   HistogramOnSlope          = true;
extern bool   Interpolate               = true;

extern string MaModes                   = "";
extern string __0                       = "SMA";
extern string __1                       = "EMA";
extern string __2                       = "Double smoothed EMA";
extern string __3                       = "Double EMA (DEMA)";
extern string __4                       = "Triple EMA (TEMA)";
extern string __5                       = "Smoothed MA";
extern string __6                       = "Linear weighted MA";
extern string __7                       = "Parabolic weighted MA";
extern string __8                       = "Alexander MA";
extern string __9                       = "Volume weghted MA";
extern string __10                      = "Hull MA";
extern string __11                      = "Triangular MA";
extern string __12                      = "Sine weighted MA";
extern string __13                      = "Linear regression";
extern string __14                      = "IE/2";
extern string __15                      = "NonLag MA";
extern string __16                      = "Zero lag EMA";
extern string __17                      = "Leader EMA";
extern string __18                      = "Super smoother";
extern string __19                      = "Smoother";

extern string note                      = "turn on Alert = true; turn off = false";
extern bool   alertsOn                  = true;
extern bool   alertsOnSlope             = false;
extern bool   alertsOnZeroCross         = true;
extern bool   alertsOnCurrent           = true;
extern bool   alertsMessage             = true;
extern bool   alertsSound               = false;
extern bool   alertsEmail               = false;
extern bool   alertsNotify              = false;

extern bool   arrowsVisible             = true;
extern string arrowsIdentifier          = "AO Arrows1";
extern double arrowsDisplacement        = 1.0;

extern bool   arrowsOnSlope             = false;
extern color  arrowsOnSlopeUpColor      = LimeGreen;
extern color  arrowsOnSlopeDnColor      = Red;
extern int    arrowsOnSlopeUpCode       = 241;
extern int    arrowsOnSlopeDnCode       = 242;
extern int    arrowsOnSlopeUpSize       = 1;
extern int    arrowsOnSlopeDnSize       = 1;

extern bool   arrowsOnZeroCross         = true;
extern color  arrowsOnZeroCrossUpColor  = LimeGreen;
extern color  arrowsOnZeroCrossDnColor  = Red;
extern int    arrowsOnZeroCrossUpCode   = 119;
extern int    arrowsOnZeroCrossDnCode   = 119;
extern int    arrowsOnZeroCrossUpSize   = 3;
extern int    arrowsOnZeroCrossDnSize   = 3;


//
//
//
//
//

double Upa[];
double Upb[];
double Dna[];
double Dnb[];
double ao[];
double trend[];
double slope[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;
string shortName;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int init()
{
   IndicatorBuffers(7);   
    SetIndexBuffer(0,Dna);   SetIndexStyle(0,DRAW_HISTOGRAM);
    SetIndexBuffer(1,Dnb);   SetIndexStyle(1,DRAW_HISTOGRAM);
    SetIndexBuffer(2,Upa);   SetIndexStyle(2,DRAW_HISTOGRAM);
    SetIndexBuffer(3,Upb);   SetIndexStyle(3,DRAW_HISTOGRAM);
    SetIndexBuffer(4,ao);
    SetIndexBuffer(5,trend);
    SetIndexBuffer(6,slope);
    SetLevelValue(0,0);
   
      //
      //
      //
      //
      //
   
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      calculateValue    = (TimeFrame=="calculateValue");
      if (calculateValue)
      {
         int s = StringFind(divergenceUniqueID,":",0);
               shortName = divergenceUniqueID;
               divergenceUniqueID = StringSubstr(divergenceUniqueID,0,s);
               return(0);
      }            
      timeFrame = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
      
      shortName = divergenceUniqueID+": "+timeFrameToString(timeFrame)+"  AO of "+getAverageName(FastMaMode)+")";
   IndicatorShortName(shortName);
return(0);
}

//
//
//
//
//
   
int deinit()
{
   
   int lookForLength = StringLen(divergenceUniqueID);
   
   for (int i=ObjectsTotal()-1; i>=0; i--) {
   
   string objectName = ObjectName(i);
   if (StringSubstr(objectName,0,lookForLength) == divergenceUniqueID) ObjectDelete(objectName);
   
   }
   
   if (!calculateValue && arrowsVisible) deleteArrows();
   
return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
    
int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { Dna[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {            
     for(i=limit; i>=0; i--)
     {
        double price  = getPrice(AoPrice,i);
        ao[i]  = iCustomMa(FastMaMode,price,FastMaPeriod,i,0)-iCustomMa(SlowMaMode,price,SlowMaPeriod,i,1);
        Dna[i] = EMPTY_VALUE;
        Dnb[i] = EMPTY_VALUE;
        Upa[i] = EMPTY_VALUE;
        Upb[i] = EMPTY_VALUE;
        trend[i] = trend[i+1];
        slope[i]= slope[i+1];
        if (ao[i] > 0)       trend[i]  =  1;
        if (ao[i] < 0)       trend[i]  = -1;
        if (ao[i] > ao[i+1]) slope[i] =  1;
        if (ao[i] < ao[i+1]) slope[i] = -1;
         
        if (divergenceVisible)
        {
           CatchBullishDivergence(ao,i);
           CatchBearishDivergence(ao,i);
        }
                                     
        if (HistogramOnSlope)
        {
           if (trend[i]== 1 && slope[i] == 1) Upa[i] = ao[i];
           if (trend[i]== 1 && slope[i] ==-1) Upb[i] = ao[i];
           if (trend[i]==-1 && slope[i] ==-1) Dna[i] = ao[i];
           if (trend[i]==-1 && slope[i] == 1) Dnb[i] = ao[i];
         }
         else
         {                  
           if (trend[i]== 1) Upa[i] = ao[i];
           if (trend[i]==-1) Dna[i] = ao[i];
         }
           manageArrow(i);         
      }
    manageAlerts();
    return(0);
    } 
     
    //
    //
    //
    //
    //

    limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
    for(i=limit; i>=0; i--)
    {
       int y = iBarShift(NULL,timeFrame,Time[i]);
           ao[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastMaPeriod,FastMaMode,SlowMaPeriod,SlowMaMode,AoPrice,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,Interpolate,4,y);
           trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastMaPeriod,FastMaMode,SlowMaPeriod,SlowMaMode,AoPrice,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,Interpolate,5,y);
           slope[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastMaPeriod,FastMaMode,SlowMaPeriod,SlowMaMode,AoPrice,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,Interpolate,6,y);
           Dna[i]   = EMPTY_VALUE;
           Dnb[i]   = EMPTY_VALUE;
           Upa[i]   = EMPTY_VALUE;
           Upb[i]   = EMPTY_VALUE;
           
           if (HistogramOnSlope)
           {
             if (trend[i]== 1 && slope[i] == 1) Upa[i] = ao[i];
             if (trend[i]== 1 && slope[i] ==-1) Upb[i] = ao[i];
             if (trend[i]==-1 && slope[i] ==-1) Dna[i] = ao[i];
             if (trend[i]==-1 && slope[i] == 1) Dnb[i] = ao[i];
           }
           else
           {                  
             if (trend[i]== 1) Upa[i] = ao[i];
             if (trend[i]==-1) Dna[i] = ao[i];
           }
           manageArrow(i);
                
           //
           //
           //
           //
           //
        
           if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

           //
           //
           //
           //
           //

           datetime time = iTime(NULL,timeFrame,y);
              for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
              for(int k = 1; k < n; k++) 
              {
                 ao[i+k] = ao[i] + (ao[i+n] - ao[i])* k/n;
                 if (Dna[i]!= EMPTY_VALUE) Dna[i+k] = ao[i+k];
                 if (Dnb[i]!= EMPTY_VALUE) Dnb[i+k] = ao[i+k];
                 if (Upa[i]!= EMPTY_VALUE) Upa[i+k] = ao[i+k];
                 if (Upb[i]!= EMPTY_VALUE) Upb[i+k] = ao[i+k];
              }     
   }
   manageAlerts();
return(0);
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

double getPrice(int type, int i)
{
   switch (type)
   {
      case 7:     return((Open[i]+Close[i])/2.0);
      case 8:     return((Open[i]+High[i]+Low[i]+Close[i])/4.0);
      default :   return(iMA(NULL,0,1,0,MODE_SMA,type,i));
   }      
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

string methodNames[] = {"SMA","EMA","Double smoothed EMA","Double EMA","Triple EMA","Smoothed MA","Linear weighted MA","Parabolic weighted MA","Alexander MA","Volume weghted MA","Hull MA","Triangular MA","Sine weighted MA","Linear regression","IE/2","NonLag MA","Zero lag EMA","Leader EMA","Super smoother","Smoothed"};
string getAverageName(int& method)
{
   int max = ArraySize(methodNames)-1;
      method=MathMax(MathMin(method,max),0); return(methodNames[method]);
}

//
//
//
//
//

#define _maWorkBufferx1 2
#define _maWorkBufferx2 4
#define _maWorkBufferx3 6
#define _maWorkBufferx5 10

double iCustomMa(int mode, double price, double length, int i, int instanceNo=0)
{
   int r = Bars-i-1;
   switch (mode)
   {
      case 0  : return(iSma(price,length,r,instanceNo));
      case 1  : return(iEma(price,length,r,instanceNo));
      case 2  : return(iDsema(price,length,r,instanceNo));
      case 3  : return(iDema(price,length,r,instanceNo));
      case 4  : return(iTema(price,length,r,instanceNo));
      case 5  : return(iSmma(price,length,r,instanceNo));
      case 6  : return(iLwma(price,length,r,instanceNo));
      case 7  : return(iLwmp(price,length,r,instanceNo));
      case 8  : return(iAlex(price,length,r,instanceNo));
      case 9  : return(iWwma(price,length,r,instanceNo));
      case 10 : return(iHull(price,length,r,instanceNo));
      case 11 : return(iTma(price,length,r,instanceNo));
      case 12 : return(iSineWMA(price,length,r,instanceNo));
      case 13 : return(iLinr(price,length,r,instanceNo));
      case 14 : return(iIe2(price,length,r,instanceNo));
      case 15 : return(iNonLagMa(price,length,r,instanceNo));
      case 16 : return(iZeroLag(price,length,r,instanceNo));
      case 17 : return(iLeader(price,length,r,instanceNo));
      case 18 : return(iSsm(price,length,r,instanceNo));
      case 19 : return(iSmooth(price,length,r,instanceNo));
      default : return(0);
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= Bars) ArrayResize(workDsema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]);
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= Bars) ArrayResize(workDema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workDema[r][_dema1+instanceNo] = workDema[r-1][_dema1+instanceNo]+alpha*(price                         -workDema[r-1][_dema1+instanceNo]);
          workDema[r][_dema2+instanceNo] = workDema[r-1][_dema2+instanceNo]+alpha*(workDema[r][_dema1+instanceNo]-workDema[r-1][_dema2+instanceNo]);
   return(workDema[r][_dema1+instanceNo]*2.0-workDema[r][_dema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= Bars) ArrayResize(workTema,Bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]);
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workLwmp[][_maWorkBufferx1];
double iLwmp(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwmp,0)!= Bars) ArrayResize(workLwmp,Bars);
   
   //
   //
   //
   //
   //
   
   workLwmp[r][instanceNo] = price;
      double sumw = period*period;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (period-k)*(period-k);
                sumw  += weight;
                sum   += weight*workLwmp[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workAlex[][_maWorkBufferx1];
double iAlex(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workAlex,0)!= Bars) ArrayResize(workAlex,Bars);
   if (period<4) return(price);
   
   //
   //
   //
   //
   //

   workAlex[r][instanceNo] = price;
      double sumw = period-2;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k-2;
                sumw  += weight;
                sum   += weight*workAlex[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workTma[][_maWorkBufferx1];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTma,0)!= Bars) ArrayResize(workTma,Bars);
   
   //
   //
   //
   //
   //
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workSineWMA[][_maWorkBufferx1];
#define Pi 3.14159265358979323846264338327950288

double iSineWMA(double price, int period, int r, int instanceNo=0)
{
   if (period<1) return(price);
   if (ArrayRange(workSineWMA,0)!= Bars) ArrayResize(workSineWMA,Bars);
   
   //
   //
   //
   //
   //
   
   workSineWMA[r][instanceNo] = price;
      double sum  = 0;
      double sumw = 0;
  
      for(int k=0; k<period && (r-k)>=0; k++)
      { 
         double weight = MathSin(Pi*(k+1.0)/(period+1.0));
                sumw  += weight;
                sum   += weight*workSineWMA[r-k][instanceNo]; 
      }
      return(sum/sumw);
}

//
//
//
//
//

double workWwma[][_maWorkBufferx1];
double iWwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workWwma,0)!= Bars) ArrayResize(workWwma,Bars);
   
   //
   //
   //
   //
   //
   
   workWwma[r][instanceNo] = price;
      int    i    = Bars-r-1;
      double sumw = Volume[i];
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = Volume[i+k];
                sumw  += weight;
                sum   += weight*workWwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workHull[][_maWorkBufferx2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars);

   //
   //
   //
   //
   //

      int HmaPeriod  = MathMax(period,2);
      int HalfPeriod = MathFloor(HmaPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= Bars) ArrayResize(workLinr,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}

//
//
//
//
//

double workIe2[][_maWorkBufferx1];
double iIe2(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workIe2,0)!= Bars) ArrayResize(workIe2,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workIe2[r][instanceNo] = price;
         double sumx=0, sumxx=0, sumxy=0, sumy=0;
         for (int k=0; k<period; k++)
         {
            price = workIe2[r-k][instanceNo];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
         }
         double tslope  = (period*sumxy - sumx*sumy)/(sumx*sumx-period*sumxx);
         double average = sumy/period;
   return(((average+tslope)+(sumy+tslope*sumx)/period)/2.0);
}

//
//
//
//
//

double workLeader[][_maWorkBufferx2];
double iLeader(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLeader,0)!= Bars) ArrayResize(workLeader,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      double alpha = 2.0/(period+1.0);
         workLeader[r][instanceNo  ] = workLeader[r-1][instanceNo  ]+alpha*(price                          -workLeader[r-1][instanceNo  ]);
         workLeader[r][instanceNo+1] = workLeader[r-1][instanceNo+1]+alpha*(price-workLeader[r][instanceNo]-workLeader[r-1][instanceNo+1]);

   return(workLeader[r][instanceNo]+workLeader[r][instanceNo+1]);
}

//
//
//
//
//

double workZl[][_maWorkBufferx2];
#define _price 0
#define _zlema 1

double iZeroLag(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workZl,0)!=Bars) ArrayResize(workZl,Bars); instanceNo *= 2;

   //
   //
   //
   //
   //

   double alpha = 2.0/(1.0+length); 
   int    per   = (length-1.0)/2.0; 

   workZl[r][_price+instanceNo] = price;
   if (r<per)
          workZl[r][_zlema+instanceNo] = price;
   else   workZl[r][_zlema+instanceNo] = workZl[r-1][_zlema+instanceNo]+alpha*(2.0*price-workZl[r-per][_price+instanceNo]-workZl[r-1][_zlema+instanceNo]);
   return(workZl[r][_zlema+instanceNo]);
}

//
//
//
//
//

double workSmooth[][_maWorkBufferx5];
double iSmooth(double price,int length,int r, int instanceNo=0)
{
   if (ArrayRange(workSmooth,0)!=Bars) ArrayResize(workSmooth,Bars); instanceNo *= 5;
 	if(r<=2) { workSmooth[r][instanceNo] = price; workSmooth[r][instanceNo+2] = price; workSmooth[r][instanceNo+4] = price; return(price); }
   
   //
   //
   //
   //
   //
   
	double alpha = 0.45*(length-1.0)/(0.45*(length-1.0)+2.0);
   	  workSmooth[r][instanceNo+0] =  price+alpha*(workSmooth[r-1][instanceNo]-price);
	     workSmooth[r][instanceNo+1] = (price - workSmooth[r][instanceNo])*(1-alpha)+alpha*workSmooth[r-1][instanceNo+1];
	     workSmooth[r][instanceNo+2] =  workSmooth[r][instanceNo+0] + workSmooth[r][instanceNo+1];
	     workSmooth[r][instanceNo+3] = (workSmooth[r][instanceNo+2] - workSmooth[r-1][instanceNo+4])*MathPow(1.0-alpha,2) + MathPow(alpha,2)*workSmooth[r-1][instanceNo+3];
	     workSmooth[r][instanceNo+4] =  workSmooth[r][instanceNo+3] + workSmooth[r-1][instanceNo+4]; 
   return(workSmooth[r][instanceNo+4]);
}

//
//
//
//
//

double workSsm[][_maWorkBufferx2];
#define _tprice  0
#define _ssm    1

double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3

//
//
//
//
//

double iSsm(double price, double period, int i, int instanceNo)
{
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_period] != period)
   {
      workSsmCoeffs[instanceNo][_period] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_c2] = b1;
         workSsmCoeffs[instanceNo][_c3] = -a1*a1;
         workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2;   
          workSsm[i][s+_tprice] = price;
          workSsm[i][s+_ssm]    = workSsmCoeffs[instanceNo][_c1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_price])/2.0 + 
                                  workSsmCoeffs[instanceNo][_c2]*workSsm[i-1][s+_ssm]                               + 
                                  workSsmCoeffs[instanceNo][_c3]*workSsm[i-2][s+_ssm]; 
   return(workSsm[i][s+_ssm]);
}

//
//
//
//
//

#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[3][_maWorkBufferx1];
double  nlmprices[ ][_maWorkBufferx1];
double  nlmalphas[ ][_maWorkBufferx1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(nlmprices,0) != Bars)       ArrayResize(nlmprices,Bars);
   if (ArrayRange(nlmvalues,0) <  instanceNo) ArrayResize(nlmvalues,instanceNo);
                               nlmprices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlmprices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[_length][instanceNo] != length  || ArraySize(nlmalphas)==0)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlmvalues[_length][instanceNo] = length;
         nlmvalues[_len   ][instanceNo] = length*4 + Phase;  
         nlmvalues[_weight][instanceNo] = 0;

         if (ArrayRange(nlmalphas,0) < nlmvalues[_len][instanceNo]) ArrayResize(nlmalphas,nlmvalues[_len][instanceNo]);
         for (int k=0; k<nlmvalues[_len][instanceNo]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[_weight][instanceNo] += nlmalphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[_weight][instanceNo]>0)
   {
      double sum = 0;
           for (k=0; k < nlmvalues[_len][instanceNo]; k++) sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
           return( sum / nlmvalues[_weight][instanceNo]);
   }
   else return(0);           
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

void CatchBullishDivergence(double& values[], int i)
{
   i++;
            ObjectDelete(divergenceUniqueID+"l"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"l"+"os" + DoubleToStr(Time[i],0));            
   if (!IsIndicatorLow(values,i)) return;  

   //
   //
   //
   //
   //

   int currentLow = i;
   int lastLow    = GetIndicatorLastLow(values,i+1);
      if (values[currentLow] > values[lastLow] && Low[currentLow] < Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],divergenceBullishColor,STYLE_SOLID);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow],divergenceBullishColor,STYLE_SOLID);
      }
      if (values[currentLow] < values[lastLow] && Low[currentLow] > Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow], divergenceBullishColor, STYLE_DOT);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow], divergenceBullishColor, STYLE_DOT);
      }
}

//
//
//
//
//

void CatchBearishDivergence(double& values[], int i)
{
   i++; 
            ObjectDelete(divergenceUniqueID+"h"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"h"+"os" + DoubleToStr(Time[i],0));            
   if (IsIndicatorPeak(values,i) == false) return;

   //
   //
   //
   //
   //
      
   int currentPeak = i;
   int lastPeak = GetIndicatorLastPeak(values,i+1);
      if (values[currentPeak] < values[lastPeak] && High[currentPeak]>High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],divergenceBearishColor,STYLE_SOLID);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak],divergenceBearishColor,STYLE_SOLID);
      }
      if(values[currentPeak] > values[lastPeak] && High[currentPeak] < High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak], divergenceBearishColor, STYLE_DOT);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak], divergenceBearishColor, STYLE_DOT);
      }
}

//
//
//
//
//

bool IsIndicatorPeak(double& values[], int i) { return(values[i] >= values[i+1] && values[i] > values[i+2] && values[i] > values[i-1]); }
bool IsIndicatorLow( double& values[], int i) { return(values[i] <= values[i+1] && values[i] < values[i+2] && values[i] < values[i-1]); }

int GetIndicatorLastPeak(double& values[], int shift)
{
   for(int i = shift+5; i<Bars; i++)
         if (values[i] >= values[i+1] && values[i] > values[i+2] && values[i] >= values[i-1] && values[i] > values[i-2]) return(i);
   return(-1);
}

//
//
//
//
//

int GetIndicatorLastLow(double& values[], int shift)
{
   for(int i = shift+5; i<Bars; i++)
         if (values[i] <= values[i+1] && values[i] < values[i+2] && values[i] <= values[i-1] && values[i] < values[i-2]) return(i);
   return(-1);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string   label = divergenceUniqueID+first+"os"+DoubleToStr(t1,0);
   if (Interpolate) t2 += Period()*60-1;
    
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//
//
//
//
//

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = WindowFind(shortName);
   if (indicatorWindow < 0) return;
   if (Interpolate) t2 += Period()*60-1;
   
   string label = divergenceUniqueID+first+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs) {
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str) {
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--) {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar)); 

      //
      //
      //
      //
      //
            
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnSlope && slope[whichBar] != slope[whichBar+1])
      {
         if (slope[whichBar] ==  1) doAlert(time1,mess1,whichBar,"sloping up");
         if (slope[whichBar] == -1) doAlert(time1,mess1,whichBar,"sloping down");
      }
      
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnZeroCross && trend[whichBar]!= trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(time2,mess2,whichBar,"crossing zero up");
         if (trend[whichBar] == -1) doAlert(time2,mess2,whichBar,"crossing zero down");
      }   
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," AO ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," AO "),message);
          if (alertsSound)   PlaySound("alert2.wav");
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

void manageArrow(int i)
{
   if (!calculateValue && arrowsVisible)
   {
      deleteArrow(Time[i]);
      if (arrowsOnSlope && slope[i] != slope[i+1])
      {
         if (slope[i] == 1) drawArrow(i,arrowsOnSlopeUpColor,arrowsOnSlopeUpCode,arrowsOnSlopeUpSize,false);
         if (slope[i] ==-1) drawArrow(i,arrowsOnSlopeDnColor,arrowsOnSlopeDnCode,arrowsOnSlopeDnSize,true);
      }
      
      if (arrowsOnZeroCross && trend[i]!= trend[i+1])
      {
         if (trend[i] == 1) drawArrow(i,arrowsOnZeroCrossUpColor,arrowsOnZeroCrossUpCode,arrowsOnZeroCrossUpSize,false);
         if (trend[i] ==-1) drawArrow(i,arrowsOnZeroCrossDnColor,arrowsOnZeroCrossDnCode,arrowsOnZeroCrossDnSize,true);
      }   
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,int theSize,bool up)
{
    string name = arrowsIdentifier+":"+Time[i];
    double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize ); 
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsDisplacement * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsDisplacement * gap);
}

//
//
//
//
//

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}




      


