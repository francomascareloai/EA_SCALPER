//+------------------------------------------------------------------+
//|                                                Trend Traffic.mq4 |
//|                                    Copyright © 2006, Nick Barker |
//|                                       http://www.tradingintl.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Nicholas Barker"
#property  link      "http://www.tradingintl.com"
#property  link      "nick@barker.net"

#property  indicator_separate_window
#property  indicator_buffers 6

#property  indicator_color1  Silver
#property  indicator_color2  Lime
#property  indicator_color3  Yellow
#property  indicator_color4  Red
#property  indicator_color5  White
#property  indicator_color6  Blue
//#property  indicator_color7  White

extern int High_Period_Comparison=60;
extern int FastEMA=10,SlowEMA=16;
extern double RedZone=0.5;
int L1,L2;
//---- indicator buffers
double     ExtBuffer0[];
double     ExtBuffer1[];
double     ExtBuffer2[];
double     ExtBuffer3[];
double     ExtBuffer4[];
double     ExtBuffer5[];
double     ExtBuffer6[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {

   IndicatorBuffers(6);

   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,2);
   IndicatorDigits(Digits+2);
   SetIndexDrawBegin(0,38);
   SetIndexDrawBegin(1,38);
   SetIndexDrawBegin(2,38);
   SetIndexDrawBegin(3,38);

   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(5,ExtBuffer3);
   SetIndexBuffer(4,ExtBuffer4);
   SetIndexBuffer(3,ExtBuffer5);
   SetIndexBuffer(3,ExtBuffer5);

   IndicatorShortName("Trend Traffic");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);


   L1= High_Period_Comparison/Period()*FastEMA;
   L2= High_Period_Comparison/Period()*SlowEMA;
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Trend Traffic Light                                              |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
   
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
  
   for(int i=0; i<limit; i++)
      ExtBuffer3[i]=iMA(NULL,0,L1,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,L2,0,MODE_EMA,PRICE_CLOSE,i);
  
   for(i=0; i<limit; i++)
      ExtBuffer4[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
   
   bool up=true;double upper,lower;bool gr8,le5;
   for(i=limit-1; i>=0; i--){
      if(ExtBuffer3[i]>0){
         gr8=true;le5=false;lower=0;
      }else{
         gr8=false;le5=true;upper=0;
      }
      if(gr8 && ExtBuffer3[i]>upper)upper=ExtBuffer3[i];
      else if(le5 && ExtBuffer3[i]<lower)lower=ExtBuffer3[i];
     
      current=ExtBuffer3[i];
      prev=ExtBuffer3[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(gr8){
         if( ExtBuffer3[i]<upper*RedZone){
            ExtBuffer2[i]=0.0;
            ExtBuffer1[i]=0.0;
            ExtBuffer5[i]=current;
         }
         else if(!up){
            ExtBuffer2[i]=current;
            ExtBuffer1[i]=0.0;
            ExtBuffer5[i]=0.0;
         }
         else if(up){
            ExtBuffer1[i]=current;
            ExtBuffer2[i]=0.0;
            ExtBuffer5[i]=0.0;
         }
      }
      else if(le5){
         if(ExtBuffer3[i]>lower*RedZone){
            ExtBuffer2[i]=0.0;
            ExtBuffer1[i]=0.0;
            ExtBuffer5[i]=current;
         }
         else if(!up){
            ExtBuffer1[i]=current;
            ExtBuffer2[i]=0.0;
            ExtBuffer5[i]=0.0;
         }
         else if(up){
            ExtBuffer2[i]=current;
            ExtBuffer1[i]=0.0;
            ExtBuffer5[i]=0.0;
         }
      }
      ExtBuffer0[i]=current;
   }
   return(0);
}

