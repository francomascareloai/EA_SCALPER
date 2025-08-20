#property  copyright ""
#property  link      ""

#property  indicator_chart_window
#property  indicator_buffers 1
#property  indicator_color1  Red
#property  indicator_width1  2
//#property  indicator_color2  Blue
//#property  indicator_width2  2
//
//
//
//
//
 
extern int period = 3;
//extern int SmoothPeriod = 5;
//extern int SmoothPhase = 0;
double prices[],przces[];
double lwma1[];
double lwma2[];
int price  = PRICE_CLOSE;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//
double gda_164[][30];
int init()
{
   IndicatorBuffers(3);
      SetIndexBuffer(0,lwma2);
      SetIndexBuffer(1,lwma1);
      SetIndexBuffer(2,prices);
   
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
   double sum,sumw,weight;
   int i,k,limit,counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars+period,Bars-1);

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--) prices[i] = iMA(NULL,0,1,0,MODE_SMA,price,i);
   for(i=limit; i>=0; i--)
   {
      for(k=0, sum=0, sumw=0; k<period && (i+k)<Bars; k++) { 
      weight = period-k; 
      sumw += weight; 
      sum += weight*prices[i+k]; }
      
      if (sumw!=0)
            lwma1[i] = sum/sumw;
      else  lwma1[i] = 0;
   }      
   
   for(i=0; i<=limit; i++)
   {
      for(k=0, sum=0, sumw=0; k<period && (i-k)>=0; k++) { 
      weight = period-k; sumw += weight; 
      sum += weight*lwma1[i-k]; }         
          
      if (sumw!=0)
            lwma2[i] = sum/sumw;
      else  lwma2[i] = 0;
   }     
   return (0); 
}
