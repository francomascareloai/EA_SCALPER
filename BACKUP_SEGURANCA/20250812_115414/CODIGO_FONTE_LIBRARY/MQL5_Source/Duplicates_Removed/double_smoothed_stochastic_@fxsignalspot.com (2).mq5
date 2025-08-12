//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers   10
#property indicator_plots     4
#property indicator_minimum  -1
#property indicator_maximum 101

#property indicator_label1  "Stochastic levels"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLimeGreen,clrOrange
#property indicator_label2  "Stochastic"
#property indicator_type2   DRAW_LINE
#property indicator_color2  DimGray
#property indicator_width2  2
#property indicator_label3  "UP"
#property indicator_type3   DRAW_NONE
#property indicator_color3  clrNONE
#property indicator_label4  "DN"
#property indicator_type4   DRAW_NONE
#property indicator_color4  clrNONE

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

input int    StochasticPeriod = 55;       // Stochastic period
input int    EMAPeriod        = 15;       // Smoothing period
input int    EMAPeriod2       =  7;       // Smoothing period
input enPrices PriceForHigh   = pr_high;  // Price to use for high
input enPrices PriceForLow    = pr_low;   // Price to use for low
input enPrices PriceForClose  = pr_close; // Price to use for close
input double UpLevel          = 80.0;     // Overbought level
input double DnLevel          = 20.0;     // Oversold level

//
//
//
//
//

double StochasticBuffer[];
double LevelsBuffer[];
double StochasticLine[];
double calcBuffer[];
double calcBuffer1[];
double prh[],prl[],prc[];
double up[],dn[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,StochasticBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LevelsBuffer    ,INDICATOR_DATA);
   SetIndexBuffer(2,StochasticLine  ,INDICATOR_DATA);
   SetIndexBuffer(3,up    ,INDICATOR_DATA);
   SetIndexBuffer(4,dn    ,INDICATOR_DATA);
   SetIndexBuffer(5,calcBuffer      ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,calcBuffer1     ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,prh             ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,prl             ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,prc             ,INDICATOR_CALCULATIONS);
  
   IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,UpLevel);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,DnLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,DimGray);
   IndicatorSetString(INDICATOR_SHORTNAME,"Double smoothe stochastic ("+(string)StochasticPeriod+","+(string)EMAPeriod+")");
   
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   double alpha  = 2.0/(1.0+EMAPeriod);
   double alpha1 = 2.0/(1.0+EMAPeriod2);
         
   //
   //
   //
   //
   //
   
   for (int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
   {
      prh[i] = getPrice(PriceForHigh ,open,close,high,low,rates_total,i,0);
      prl[i] = getPrice(PriceForLow  ,open,close,high,low,rates_total,i,1);
      prc[i] = getPrice(PriceForClose,open,close,high,low,rates_total,i,2);
         double max = prh[i]; for(int k=1; k<StochasticPeriod && (i-k)>=0; k++) max = MathMax(max,prh[i-k]);
         double min = prl[i]; for(int k=1; k<StochasticPeriod && (i-k)>=0; k++) min = MathMin(min,prl[i-k]);
         double sto = 0;
         if (max!=min)
               sto = (prc[i]-min)/(max-min)*100.00;
               calcBuffer[i] = calcBuffer[i-1]+alpha*(sto-calcBuffer[i-1]);
      
         //
         //
         //
         //
         //
      
         max = calcBuffer[i]; for(int k=1; k<StochasticPeriod && (i-k)>=0; k++) max = MathMax(max,calcBuffer[i-k]);
         min = calcBuffer[i]; for(int k=1; k<StochasticPeriod && (i-k)>=0; k++) min = MathMin(min,calcBuffer[i-k]);
         if (max!=min)
               sto = (calcBuffer[i]-min)/(max-min)*100.00;
         else  sto = 0;            
         calcBuffer1[i] = calcBuffer1[i-1]+alpha*(sto-calcBuffer1[i-1]);
         StochasticBuffer[i] = StochasticBuffer[i-1]+alpha1*(calcBuffer1[i]-StochasticBuffer[i-1]);
         StochasticLine[i]   = StochasticBuffer[i];
         LevelsBuffer[i]     = StochasticBuffer[i];
         up[i]=up[i-1]; dn[i]=dn[i-1];
         if (StochasticBuffer[i]>=UpLevel) {LevelsBuffer[i] = UpLevel; up[i]= 1; dn[i]=0;}
         if (StochasticBuffer[i]<=DnLevel) {LevelsBuffer[i] = DnLevel; dn[i]=-1; up[i]=0;}
   }
   return(rates_total);
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

#define instances 3
double workHa[][instances*4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int bars, int i,  int instanceNo=0)
{
  if (price>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo *= 4;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
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