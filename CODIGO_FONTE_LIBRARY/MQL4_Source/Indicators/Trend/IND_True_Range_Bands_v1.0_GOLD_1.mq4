/*------------------------------------------------------------------+
 |                                             True Range Bands.mq4 |
 |                                                 Copyright © 2010 |
 |                                             basisforex@gmail.com |
 +------------------------------------------------------------------*/
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 White
#property indicator_color2 Yellow
#property indicator_color3 Yellow
//----
extern int       nPeriod     = 13;
extern double    Deviation   = 1.618;
extern int       MaShift     = 0;
//----
double MaBuffer[];
double MaTUp[];
double MaTDn[];
//+------------------------------------------------------------------+
int init()
 {
   SetIndexShift(0, MaShift);
   SetIndexShift(1, MaShift);
   SetIndexShift(2, MaShift);
//----
   SetIndexBuffer(0, MaBuffer);
   SetIndexBuffer(1, MaTUp);
   SetIndexBuffer(2, MaTDn);
//----
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
//----
   SetIndexLabel(0, "MA");
   SetIndexLabel(1, "MaUp");
   SetIndexLabel(1, "MaDn");
//----
   return(0);
 }
//+------------------------------------------------------------------+
int start()
 {
   int limit;
   double a;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
   for(int i = 0; i < limit; i++)
    {
      for(int j = 0; j < nPeriod; j++)
       {
         a = a + (iHigh(NULL, 0, i + j) + iLow(NULL, 0, i + j) + iClose(NULL, 0, i + j) * 2) / 4;
       }       
      MaBuffer[i]  =  a / nPeriod;
      a = 0;
      if(iClose(NULL, 0, i) > MaBuffer[i])
       {
         MaTUp[i] = MaBuffer[i] + iATR(NULL, 0, nPeriod, i) * Deviation;
         MaTDn[i] = MaBuffer[i] - iATR(NULL, 0, nPeriod, i);
       }  
      else if(iClose(NULL, 0, i) < MaBuffer[i])
       {
         MaTDn[i] = MaBuffer[i] - iATR(NULL, 0, nPeriod, i) * Deviation;
         MaTUp[i] = MaBuffer[i] + iATR(NULL, 0, nPeriod, i);
       } 
      else if(iClose(NULL, 0, i) == MaBuffer[i])
       {
         MaTDn[i] = MaBuffer[i] - iATR(NULL, 0, nPeriod, i) * Deviation;
         MaTUp[i] = MaBuffer[i] + iATR(NULL, 0, nPeriod, i) * Deviation;
       }  
    }  
   //-----
   return(0);
 }
//+------------------------------------------------------------------+

