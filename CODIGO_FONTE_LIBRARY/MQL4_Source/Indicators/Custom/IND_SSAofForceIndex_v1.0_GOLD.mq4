//+------------------------------------------------------------------+
//|                                                 SSA of price.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

//
//
//    max arraySize - 5000
//    max lag - 200 (but will be slow for big lags)
//    max numberOfComputations - 20 (it just makes it "fit" more precise to source array)
//
//

#import "libSSA.dll"
   void fastSingular(double& sourceArray[],int arraySize, int lag, int numberOfComputationLoops, double& destinationArray[]);
#import

//
//
//
//
//

#property indicator_separate_window
#property indicator_buffers    1
//#property indicator_minimum -100
//#property indicator_maximum  0
#property indicator_buffers  1
#property indicator_color1 Goldenrod
#property indicator_width1   2
#property indicator_level1 -80
#property indicator_level2 -20
#property indicator_levelcolor White
#property indicator_levelstyle STYLE_DOT



//
//
//
//
//

   extern int Lag                  =  25;
   extern int NumberOfComputations =   2;
   extern int NumberOfBars         = 500;
   extern int Price                = PRICE_CLOSE;
   extern int ForcePeriod         = 13;
   extern ENUM_MA_METHOD ForceMaMethod = MODE_SMA;
   extern ENUM_APPLIED_PRICE ForcePrice = PRICE_CLOSE;
//
//
//
//
//

double SSA[];
double sourceValues[];
double calcValues[];

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
   SetIndexBuffer(0,SSA);
      NumberOfBars = MathMin(NumberOfBars,5000);
   ArrayResize(sourceValues,NumberOfBars);
   ArrayResize(calcValues,NumberOfBars);
   return(0);
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
   static datetime barTime;
   int counted_bars=IndicatorCounted();
   int i,n,limit;

   //
   //
   //
   //
   //
      
   n = NumberOfBars;
      if (n > Bars)
      {
         n = Bars;
         if (ArraySize(sourceValues) != n) { ArrayResize(sourceValues,n); ArrayResize(calcValues,n); }
      }                     
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,n-1);
                   SetIndexDrawBegin(0,Bars-n);
                   if (barTime!=Time[0])
                   {
                        barTime=Time[0];
                        limit=n-1;
                   }                        

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)  sourceValues[i]=iForce(NULL,0,ForcePeriod,ForceMaMethod,ForcePrice,i);
                            fastSingular(sourceValues,n,Lag,NumberOfComputations,calcValues); ArrayCopy(SSA,calcValues);
   return(0);
}