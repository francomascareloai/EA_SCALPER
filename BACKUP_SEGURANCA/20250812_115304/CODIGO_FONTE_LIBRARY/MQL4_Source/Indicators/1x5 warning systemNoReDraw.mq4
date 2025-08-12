
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
extern int FasterMode = 3; //0=sma, 1=ema, 2=smma, 3=lwma
extern int FasterMA =   1;
extern int SlowerMode = 3; //0=sma, 1=ema, 2=smma, 3=lwma
extern int SlowerMA =   5;
extern bool UseAlert= true;
 double alertTag;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW,0,2);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);

   SetIndexStyle(1, DRAW_ARROW,0,2);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit, i, counter;
   double fasterMAnow, slowerMAnow, fasterMAprevious, slowerMAprevious, 
fasterMAafter, slowerMAafter;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      fasterMAnow =      iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i+1);
      fasterMAprevious = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i+2);

      slowerMAnow =      iMA(NULL, 0, SlowerMA, 1, SlowerMode, PRICE_OPEN, i+1);
      slowerMAprevious = iMA(NULL, 0, SlowerMA, 1, SlowerMode, PRICE_OPEN, i+2);
      
      if ( (fasterMAnow > slowerMAnow) && (fasterMAprevious < slowerMAprevious)) 
      {
         CrossUp[i] = Low[i] - Range*0.5;
         if ( alertTag!=Time[0])
         {
          //PlaySound("news.wav");// buy wav
          if (UseAlert) Alert(Symbol(),"  M",Period()," MA cross BUY");
         }
          alertTag = Time[0];
      }
      else if ((fasterMAnow < slowerMAnow) && (fasterMAprevious > slowerMAprevious)) 
      {
         CrossDown[i] = High[i] + Range*0.5;
         if ( alertTag!=Time[0])
         {
          //PlaySound("news.wav"); //sell wav
           if (UseAlert) Alert(Symbol(),"  M",Period()," MA cross SELL");
         }
          alertTag = Time[0];
      }
   }
   return(0);
}


       