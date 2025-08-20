//+------------------------------------------------------------------+
//|                                                 AutoEnvelope.mq4 |
//|                                Copyright © 2011, Leandro Farias. |
//|                           Dr. Alexander Elder AutoEnvelope based |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Leandro Farias (Dr. Alexander Elder AutoEnvelope based)"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Green

//--- input parameters
extern int       mme_periodo=26;          // Slow MME
extern int       mme2_periodo=13;         // Fast MME
extern int       stdev_periodo=60;        // Period standard seviation (60 recommended)
extern int       band_mme=200;            // Smoothing channel bands MME (200 recommended)
extern bool       hide=false;             // Show/hide

double emapb1[];                          // Upper band
double emapb2[];                          // Lower band
double emapb3[];                          // Slow MME
double emapb4[];                          // Fast MME

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

      SetIndexBuffer(0,emapb1);
      SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1);

      SetIndexBuffer(1,emapb2);
      SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1);
   
      SetIndexBuffer(2,emapb3);
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);

      SetIndexBuffer(3,emapb4);
      SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);
      

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
int start()
  {
   int    counted_bars=IndicatorCounted();
   int i,a=0;
   int nLimit;
   double stdv;
   double mme, mme_ontem, k;
   
   if(hide == true) return(0);

   nLimit = Bars - mme_periodo;
   
   k = 2.0 / (band_mme+1);

   for(i = nLimit; i > -1; i--,a++)
   {
         stdv = iStdDev(NULL, 0, stdev_periodo, 0, MODE_EMA, PRICE_CLOSE, i);

         if(a == 0) mme_ontem = stdv;
         else mme_ontem = mme;

         mme = (stdv * k) + (mme_ontem * (1 - k));

         emapb3[i] = iMA(NULL, 0, mme_periodo, 0, MODE_EMA, PRICE_CLOSE, i);
         
         if(mme2_periodo > 0)
         {
            emapb4[i] = iMA(NULL, 0, mme2_periodo, 0, MODE_EMA, PRICE_CLOSE, i);
         }
         
         emapb1[i] = emapb3[i]*(1+(mme / emapb3[i]));
         emapb2[i] = emapb3[i]*(1-(mme / emapb3[i]));
         
   }
   

//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

