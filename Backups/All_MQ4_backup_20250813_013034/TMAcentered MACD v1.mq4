//+------------------------------------------------------------------+
//|                                        TriangularMA centered.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  DeepSkyBlue
#property indicator_color2  OrangeRed
#property indicator_color3  DimGray
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  1

//
//
//
//
//

extern int FastHalfLength = 50;
extern int SlowHalfLength = 100;
extern int Price          = PRICE_CLOSE;

//
//
//
//
//

double ExtMapBuffer[];
double Uptrend[];
double Dntrend[];
double buffer2[];
double buffer3[];
double buffer4[];
double pricesArray[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int init()
{
   FastHalfLength=MathMax(FastHalfLength,1);
   SlowHalfLength=MathMax(SlowHalfLength,1);

   IndicatorBuffers(7);   
   SetIndexBuffer(0,Uptrend);  SetIndexDrawBegin(0,SlowHalfLength);
   SetIndexBuffer(1,Dntrend);  SetIndexDrawBegin(1,SlowHalfLength);
   SetIndexBuffer(2,buffer2);
   SetIndexBuffer(3,ExtMapBuffer);
   ArraySetAsSeries(ExtMapBuffer, true); 
   SetIndexBuffer(4,buffer3);
   SetIndexBuffer(5,buffer4);
   SetIndexBuffer(6,pricesArray);
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
      SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID);

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
   double sum,sumw;
   int counted_bars=IndicatorCounted();
   int i,j,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           limit=MathMax(limit,FastHalfLength);
           limit=MathMax(limit,SlowHalfLength);

 
    double trend[];

    ArrayResize(trend, limit); 
    ArraySetAsSeries(trend, true); 

   //
   //
   //
   //
   //
   
   for (i=limit;i>=0;i--) pricesArray[i] = iMA(NULL,0,1,0,MODE_SMA,Price,i);
   for (i=limit;i>=0;i--)
   {
         buffer3[i] = calculateTma(pricesArray,FastHalfLength,i);
         buffer4[i] = calculateTma(pricesArray,SlowHalfLength,i);
         ExtMapBuffer[i] = buffer3[i]-buffer4[i];
         buffer2[i] = 0; 


        trend[i] = trend[i+1];
        if (ExtMapBuffer[i]> ExtMapBuffer[i+1]) trend[i] =1;
        if (ExtMapBuffer[i]< ExtMapBuffer[i+1]) trend[i] =-1;
    
    if (trend[i]>0)
    { Uptrend[i] = ExtMapBuffer[i]; 
      if (trend[i+1]<0) Uptrend[i+1]=ExtMapBuffer[i+1];
      Dntrend[i] = EMPTY_VALUE;
    }
    else              
    if (trend[i]<0)
    { 
      Dntrend[i] = ExtMapBuffer[i]; 
      if (trend[i+1]>0) Dntrend[i+1]=ExtMapBuffer[i+1];
      Uptrend[i] = EMPTY_VALUE;
    }     


   }
   
   //
   //
   //
   //
   //
   
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

double calculateTma(double& prices[], int halfLength, int i)
{
   int j,k;

   double sum  = (halfLength+1)*prices[i];
   double sumw = (halfLength+1);

   for(j=1, k=halfLength; j<=halfLength; j++, k--)
   {
      sum  += k*prices[i+j];
      sumw += k;

      if (j<=i)
      {
         sum  += k*prices[i-j];
         sumw += k;
      }
   }
   return(sum/sumw);
}

