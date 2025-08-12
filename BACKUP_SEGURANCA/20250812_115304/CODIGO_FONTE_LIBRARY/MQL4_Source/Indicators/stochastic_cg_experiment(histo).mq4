//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrMediumSeaGreen
#property indicator_color2  clrCrimson
#property indicator_minimum 0
#property indicator_maximum 1
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

extern int             Length           = 32;
extern enPrices        Price            = pr_close; // Price to use 
input int              Width                 = 2;                 // If auto width = false then use this
input bool            UseAutoWidth     = true;              // Auto adjust bar width
extern color           color1                = clrMediumSeaGreen;      // Bearish bar color
extern color           color2                = clrCrimson;      // Bullish bar color

double cg[];
double storaw[];
double stocg[];
double valda[];
double valdb[];
double stosig[];
double trend[];

int candlewidth=0;

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
 if (UseAutoWidth)
   {
      int scale = int(ChartGetInteger(0,CHART_SCALE));
      switch(scale) 
	   {
	      case 0: candlewidth =  1; break;
	      case 1: candlewidth =  1; break;
		   case 2: candlewidth =  2; break;
		   case 3: candlewidth =  3; break;
		   case 4: candlewidth =  6; break;
		   case 5: candlewidth = 14; break;
	   }
	}
	else { candlewidth = Width; }
	
   IndicatorBuffers(7);
      SetIndexBuffer(0,valda); SetIndexStyle(0,DRAW_HISTOGRAM,0,candlewidth, color1); 
      SetIndexBuffer(1,valdb); SetIndexStyle(1,DRAW_HISTOGRAM,0,candlewidth, color2); 
      
      SetIndexBuffer(2,stocg);
      SetIndexBuffer(3,stosig);
      SetIndexBuffer(4,cg);
      SetIndexBuffer(5,storaw);
      SetIndexBuffer(6,trend);

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
               
   IndicatorShortName(" Stochastic CG ("+Length+")");
   return(0); 
}
int deinit() 
{  
  
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

int start()
{
   int k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
    if(ChartGetInteger(0,CHART_SCALE) != candlewidth) init();     

   //
   //
   //
   //
   //

 
     
      for(int i=limit; i>=0; i--)
      {
         double num = 0;
         double den = 0;
            for (k=0; k<Length; k++)
            {
               double price = getPrice(Price,Open,Close,High,Low,i+k);
                      num += price*(Length-k);
                      den += k-Length;
            }
            if (den!=0)
                  cg[i] = -num/den;
            else  cg[i] = 0;
         
            //
            //
            //
            //
            //
         
            double hh = cg[ArrayMaximum(cg,Length,i)];          
            double ll = cg[ArrayMinimum(cg,Length,i)];
            if (hh!=ll)
                  storaw[i] = (cg[i]-ll)/(hh-ll);
            else  storaw[i] = 0;
            double smtcg = (4.0*storaw[i]+3.0*storaw[i+1]+2.0*storaw[i+2]+storaw[i+3])/10.0;
         
            //
            //
            //
            //
            //
            
            stocg[i]   = 2.0*(smtcg-0.5);
            stosig[i]  = 0.96*(stocg[i+1] + 0.02);
           
            trend[i]   = trend[i+1];
               if (stocg[i]>stosig[i]) trend[i] =  1;
               if (stocg[i]<stosig[i]) trend[i] = -1;
         valda[i] = (trend[i] == 1) ? 1 : EMPTY_VALUE;
         valdb[i] = (trend[i] ==-1) ? 1 : EMPTY_VALUE;  
               
               //
               //
               //
               //
               //
     
              
      }
    
      return(0);
   }
   
   //
   //
   //
   //
   //
   
  

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
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
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

