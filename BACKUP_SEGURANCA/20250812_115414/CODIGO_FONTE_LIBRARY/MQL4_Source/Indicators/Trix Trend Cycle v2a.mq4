//+------------------------------------------------------------------+
//|                                           Trix Trend Cycle 1.mq4 |
//|                                                            Knoxy |
//+------------------------------------------------------------------+
#property copyright "dgianelly"
#property link      "www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Silver
#property indicator_color2  Lime
#property indicator_color3  Red
#property indicator_width2  2
#property indicator_width3  2
//
//
//
//
//
extern int TrixPeriod = 4;

//
//
//
//
//

double stcBuffer[];
double Upper[];
double Lower[];
double trix_buffer3[];
double cdBuffer[];
double fastKBuffer[];
double fastDBuffer[];
double fastKKBuffer[];


double trix_buffer1[];
double trix_buffer2[];



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
   IndicatorBuffers(8);
   SetIndexBuffer(0,stcBuffer);
   SetIndexBuffer(1,Upper);
   SetIndexBuffer(2,Lower);
   SetIndexBuffer(3,trix_buffer3);
   SetIndexBuffer(4,cdBuffer);
   SetIndexBuffer(5,fastKBuffer);
   SetIndexBuffer(6,fastDBuffer);
   SetIndexBuffer(7,fastKKBuffer);


   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(2,DRAW_LINE, STYLE_SOLID, 2);
   IndicatorShortName("Trix TC1 ("+TrixPeriod+") v2");
   
   ArraySetAsSeries(trix_buffer1,true);
   ArraySetAsSeries(trix_buffer2,true);
   
   int index = Bars;
   ArrayResize(trix_buffer1,index);
   ArrayResize(trix_buffer2,index);

   return(0);
}

int deinit()
{
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

int start()
{
   double alphaCD      = 2.0 / (1.0 + 3.0);
   int    counted_bars = IndicatorCounted();
   int    limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         
   limit = Bars;


   //
   //
   //
   //
   //

  for(i=0; i<limit; i++) trix_buffer1[i]=iMA(NULL,0,TrixPeriod,0,MODE_SMMA,(PRICE_CLOSE+PRICE_HIGH+PRICE_LOW),i);
  for(i=0; i<limit; i++) trix_buffer2[i]=iMAOnArray(trix_buffer1,0,TrixPeriod,0,MODE_SMMA,i);
  for(i=0; i<limit; i++) trix_buffer3[i]=iMAOnArray(trix_buffer2,0,TrixPeriod,0,MODE_EMA,i);
  
  
  Comment(trix_buffer3[0]);
   //
   //
   //
   
   for(i = limit; i >= 0; i--)
   {

      cdBuffer[i]   = cdBuffer[i+1]+alphaCD*(trix_buffer3[i]-trix_buffer3[i+1]);

      //
      //
      //
      //
      //
      
      double lowCd  = minValue(cdBuffer,i);
      double highCd = maxValue(cdBuffer,i)-lowCd;
         if (highCd > 0)
               fastKBuffer[i] = 100*((cdBuffer[i]-lowCd)/highCd);
         else  fastKBuffer[i] = fastKBuffer[i+1];
               fastDBuffer[i] = fastDBuffer[i+1]+0.5*(fastKBuffer[i]-fastDBuffer[i+1]);
               
      //
      //
      //
      //
      //
                     
      double lowStoch  = minValue(fastDBuffer,i);
      double highStoch = maxValue(fastDBuffer,i)-lowStoch;
         if (highStoch > 0)
               fastKKBuffer[i] = 100*((fastDBuffer[i]-lowStoch)/highStoch);
         else  fastKKBuffer[i] = fastKKBuffer[i+1];
               stcBuffer[i]    = stcBuffer[i+1]+0.5*(fastKKBuffer[i]-stcBuffer[i+1]);
   }

   for(i = limit; i >= 0; i--)
   {
      if (stcBuffer[i] > stcBuffer[i+1]) { Upper[i] = stcBuffer[i]; Upper[i+1] = stcBuffer[i+1]; }
      else if (stcBuffer[i] < stcBuffer[i+1])   { Lower[i] = stcBuffer[i]; Lower[i+1] = stcBuffer[i+1]; }
      else if (stcBuffer[i] == stcBuffer[i+1] && Lower[i+1]!=EMPTY_VALUE && Upper[i+1]==EMPTY_VALUE)   { Lower[i] = Lower[i+1];}
      else if (stcBuffer[i] == stcBuffer[i+1] && Upper[i+1]!=EMPTY_VALUE && Lower[i+1]==EMPTY_VALUE)   { Upper[i] = Upper[i+1];}
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

double minValue(double& array[],int shift)
{
   double minValue = array[shift];
            for (int i=1; i<4; i++) minValue = MathMin(minValue,array[shift+i]);
   return(minValue);
}
double maxValue(double& array[],int shift)
{
   double maxValue = array[shift];
            for (int i=1; i<4; i++) maxValue = MathMax(maxValue,array[shift+i]);
   return(maxValue);
}