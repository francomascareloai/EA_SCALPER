//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property  copyright ""
#property  link      ""
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  MediumBlue    //bbMacd up
#property  indicator_color2  Red           //bbMacd down
#property  indicator_color3  MediumBlue    //Upperband
#property  indicator_color4  Red           //Lowerband
#import "libSSA.dll"
   void fastSingular(double& sourceArray[],int arraySize, int lag, int numberOfComputationLoops, double& destinationArray[]);
#import

//
//
//
//
//


extern int    Length               = 20;
extern double StDv                 = 1.1;
extern int    LagFast              = 38;
extern int    LagSlow              = 128;
extern int    NumberOfComputations =    2;
extern int    NumberOfBars         = 2000;
extern ENUM_APPLIED_PRICE Price = PRICE_CLOSE;


double ExtMapBuffer1[];  // bbMacd
double ExtMapBuffer2[];  // bbMacd
double ExtMapBuffer3[];  // Upperband Line
double ExtMapBuffer4[];  // Lowerband Line

double bbMacd[];
double prices[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
   IndicatorBuffers(6);   
   SetIndexBuffer(0, ExtMapBuffer1); SetIndexStyle(0, DRAW_ARROW); SetIndexArrow(0, 108);
   SetIndexBuffer(1, ExtMapBuffer2); SetIndexStyle(1, DRAW_ARROW); SetIndexArrow(1, 108);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexBuffer(3, ExtMapBuffer4);
   SetIndexBuffer(4, bbMacd);
   SetIndexBuffer(5, prices);    
   IndicatorShortName("BB MACD SSA (" + LagFast + "," + LagSlow + "," + Length+")");
   return(0);
}
int deinit() { return(0); }

//
//
//
//
//

double sourceValues[];
double calcValuesa[];
double calcValuesb[];
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         int calcBars = MathMin(NumberOfBars,Bars-1);
         if (ArraySize(sourceValues)!=calcBars)
         {
            ArrayResize(sourceValues,calcBars);
            ArrayResize(calcValuesa ,calcBars);
            ArrayResize(calcValuesb ,calcBars);
         }
         for(int i=limit; i>=0; i--)  prices[i]=iMA(NULL,0,1,0,MODE_SMA,Price,i);
            ArrayCopy(sourceValues,prices,0,0,calcBars);
               fastSingular(sourceValues,calcBars,LagFast,NumberOfComputations,calcValuesa); 
               fastSingular(sourceValues,calcBars,LagSlow,NumberOfComputations,calcValuesb); 
         for(i = calcBars; i >=0; i--) bbMacd[i] = calcValuesa[i]-calcValuesb[i];
         for(i = calcBars; i >=0; i--)
         {
            double avg = iMAOnArray(bbMacd, 0, Length, 0, MODE_EMA, i);
            double dev = iStdDevOnArray(bbMacd, 0, Length, MODE_EMA, 0, i);  
               ExtMapBuffer1[i]=bbMacd[i];
               ExtMapBuffer2[i]=bbMacd[i];
               ExtMapBuffer3[i]=avg+(StDv*dev);
               ExtMapBuffer4[i]=avg-(StDv*dev);
               if(bbMacd[i] > bbMacd[i+1]) ExtMapBuffer2[i] = EMPTY_VALUE;
               if(bbMacd[i] < bbMacd[i+1]) ExtMapBuffer1[i] = EMPTY_VALUE;
         }
   return(0);
}