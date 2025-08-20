//+------------------------------------------------------------------+
//|                                        #TMA+CHANNEL_END_POINT.mq4 |
//|                                                   by Sohocool |
 //////////////////////                               April 2012
//|                      Copyright © 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5

#property indicator_color1 Red
#property indicator_style1 0

#property indicator_color3 Lime
#property indicator_style3 0


#property indicator_color4 Lime


#property indicator_color5 Red 




double upper[], middle[], lower[];
double upArrow[];
double dnArrow[];


extern int     HalfLength = 56;
//extern int     MA_MODE = 0;
// int     PRICE_MODE = 6;
extern int     ATR_PERIOD = 100;
extern double  K = 3.0;
//extern bool    ATR_MODE = false;

int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,0);
   SetIndexDrawBegin(0,0);
   SetIndexBuffer(0,upper);

   SetIndexStyle(1,DRAW_NONE);
   SetIndexShift(1,0);
   SetIndexDrawBegin(1,0);
   SetIndexBuffer(1,middle);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexShift(2,0);
   SetIndexDrawBegin(2,0);
   SetIndexBuffer(2,lower);
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,upArrow);
   
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,234);
   SetIndexBuffer(4,dnArrow);
    

//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   double avg;
   
   for(int x=0; x<limit; x++) {
      
       middle[x] = iMA(NULL, 0, HalfLength , 0, 2, 6, x);
      
     // if (ATR_MODE)
      avg  = iATR(NULL,0,ATR_PERIOD, x+10);
     // else 
    //  avg  = findAvg(ATR_PERIOD, x);
      
      upper[x] = middle[x] + K*avg;
      lower[x] = middle[x] - K*avg;
      
      upArrow[x] = EMPTY_VALUE;
      dnArrow[x] = EMPTY_VALUE;  
      if (( High[x]>lower[x])  && Close[x]<Open[x]  && Close[x]<lower[x]) dnArrow[x] = High[x]+iATR(NULL,0,20,x);
      if (( Low [x]<upper[x])  && Close[x]>Open[x]  && Close[x]>upper[x]) upArrow[x] = Low [x]-iATR(NULL,0,20,x);

      
      
   }
   return(0);
  }
//+------------------------------------------------------------------+


  // double findAvg(int period, int shift) {
  //    double sum=0;
   //   for (int x=shift;x<(shift+period);x++) {     
    //     sum += High[x]-Low[x];
   //   }
   //   sum = sum/period;
   //   return (sum);
//   }