//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  C'0,187,0'
#property indicator_color2  C'255,0,0'
#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//
//
//

extern int FastEma          = 12;
extern int SlowEma          = 26;
extern int Price            = PRICE_CLOSE;
extern int StochasticLength = 55;
extern int SmoothEMA        = 15;
double dssBuffer[];
double dssBufferda[];
double dssBufferdb[];
double slope[];

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
   SetIndexBuffer(0,dssBufferda);SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dssBufferdb);SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,dssBuffer);
   SetIndexBuffer(3,slope);
      StochasticLength = MathMax(1,StochasticLength);
      SmoothEMA        = MathMax(1,SmoothEMA);
   IndicatorShortName("DSS Bressert of MACD Histo ("+FastEma+","+SlowEma+","+StochasticLength+","+SmoothEMA+")");
   return(0);
}
int deinit(){ return(0); }


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
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1);
   
   //
   //
   //
   //
   //
   
 	for(int i = limit; i>=0; i--)
 	{
 	    double price    = iMA(NULL,0,FastEma,0,MODE_EMA,Price,i)-iMA(NULL,0,SlowEma,0,MODE_EMA,Price,i);
 	       dssBuffer[i] = iDss(price,price,price,StochasticLength,SmoothEMA,i);
 	       dssBufferda[i] = EMPTY_VALUE;
 	       dssBufferdb[i] = EMPTY_VALUE;
          slope[i]       = slope[i+1];
            if (dssBuffer[i]>dssBuffer[i+1]) slope[i] =  1;  
            if (dssBuffer[i]<dssBuffer[i+1]) slope[i] = -1;  
            if (slope[i] == 1) dssBufferda[i] = 1;
            if (slope[i] ==-1) dssBufferdb[i] = 1;
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

double workDss[][5];
#define _st1    0
#define _ss1    1
#define _pHigh  2
#define _pLow   3
#define _dss    4

double iDss(double close, double high, double low, int length, double smooth, int r)
{
   if (ArrayRange(workDss,0)!=Bars) ArrayResize(workDss,Bars); r=Bars-r-1;
   
   //
   //
   //
   //
   //
   
      double alpha = 2.0 / (1.0+smooth);
         workDss[r][_pHigh]  = high;
         workDss[r][_pLow]   = low;
     
         double min = workDss[r][_pLow];
         double max = workDss[r][_pHigh];
         for (int k=1; k<length && (r-k)>=0; k++)
         {
            min = MathMin(min,workDss[r-k][_pLow]);
            max = MathMax(max,workDss[r-k][_pHigh]);
         }
      
         workDss[r][_st1] = 0;
               if (min!=max) workDss[r][_st1] = 100*(close-min)/(max-min);
         workDss[r][_ss1] = workDss[r-1][_ss1]+alpha*(workDss[r][_st1]-workDss[r-1][_ss1]);

         //
         //
         //
         //
         //
         
         min = workDss[r][_ss1];
         max = workDss[r][_ss1];
         for (k=1; k<length && (r-k)>=0; k++)
         {
            min = MathMin(min,workDss[r-k][_ss1]);
            max = MathMax(max,workDss[r-k][_ss1]);
         }
         double stoch = 0; if (min!=max) stoch = 100*(workDss[r][_ss1]-min)/(max-min);
         
         //
         //
         //
         //
         //
         
         workDss[r][_dss] = workDss[r-1][_dss]+alpha*(stoch -workDss[r-1][_dss]);
   return(workDss[r][_dss]);
}


