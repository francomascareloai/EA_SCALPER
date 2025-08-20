//+------------------------------------------------------------------+
//|                            Quantile based signed volume analysis |
//+------------------------------------------------------------------+
#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Chartreuse
#property indicator_color2  OrangeRed
#property indicator_width1  4
#property indicator_width2  4

//
//
//
//
//

extern int    Periods             = 17;
extern int    Price               = PRICE_CLOSE;
extern double UpQuantilePercent   = 90;
extern double DownQuantilePercent = 10;
extern double AtrUpperPercent     = 75;
extern double AtrLowerPercent     = 25;
extern bool   LimitToZeroes       = true;

//
//
//
//
//

double bufferUp[];
double bufferDn[];
double quantUp[];
double quantDn[];
double prices[];
double trend[];


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
   IndicatorBuffers(6);
      SetIndexBuffer(0,bufferUp); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,bufferDn); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,quantUp);
      SetIndexBuffer(3,quantDn);
      SetIndexBuffer(4,prices);
      
      //
      //
      //
      //
      //
      
      Periods             = MathMax(Periods,1);
      UpQuantilePercent   = MathMax(MathMin(UpQuantilePercent,100),0);
      DownQuantilePercent = MathMax(MathMin(DownQuantilePercent,100),0);
   IndicatorShortName("Quantile based signed volume analysis 1 ("+Periods+","+DoubleToStr(UpQuantilePercent,2)+","+DoubleToStr(DownQuantilePercent,2)+")");
}
int deinit() { return(0); }

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
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)
   {
      prices[i]  = iMA(NULL,0,1,0,MODE_SMA,Price,i);
      quantUp[i] = iQuantile(Periods,UpQuantilePercent  ,i);
      quantDn[i] = iQuantile(Periods,DownQuantilePercent,i);
      
      //
      //
      //
      //
      //
      
      bufferUp[i] = 0;
      bufferDn[i] = 0;
      for (int k=0; k<Periods; k++)
      {
         double atr  = iATR(NULL,0,1,i+k);
         double sign = 0;
            if (prices[i+k] > Low[i+k]+atr*AtrUpperPercent/100.0 && prices[i+k]>prices[i+k+1]) sign =  1;
            if (prices[i+k] < Low[i+k]+atr*AtrLowerPercent/100.0 && prices[i+k]<prices[i+k+1]) sign = -1;
            if (prices[i+k] > quantUp[i+k]) bufferUp[i]+= sign*Volume[i+k]*prices[i+k]*atr;
            if (prices[i+k] < quantDn[i+k]) bufferDn[i]+= sign*Volume[i+k]*prices[i+k]*atr;
      }
      if (LimitToZeroes)
      {
         bufferUp[i] = MathMax(bufferUp[i],0);
         bufferDn[i] = MathMin(bufferDn[i],0);
      }         
   }
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

double quantileArray[];
double iQuantile(int period, double qp, int i)
{
   if (ArraySize(quantileArray)!=period) ArrayResize(quantileArray,period);
                  for(int k=0; k<period && (i+k)<Bars; k++) quantileArray[k] = prices[i+k];
       ArraySort(quantileArray);

   //
   //
   //
   //
   //
   
   double index = (period-1)*qp/100.00;
   int    ind   = index;
   double delta = index - ind;
   if (ind == NormalizeDouble(index,5))
         return(            quantileArray[ind]);
   else  return((1.0-delta)*quantileArray[ind]+delta*quantileArray[ind+1]);
}