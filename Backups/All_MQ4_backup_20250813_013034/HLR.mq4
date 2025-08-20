//+------------------------------------------------------------------+
//|                                                          HLR.mq4 |
//|                                      Copyright © 2007, Alexandre |
//|                      http://www.kroufr.ru/content/view/1184/124/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Alexandre"
#property link      "http://www.kroufr.ru/content/view/1184/124/"
//----
#property indicator_separate_window
#property indicator_buffers 1 
#property indicator_minimum 0 
#property indicator_maximum 100
#property indicator_color1 Red
#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
//---- input parameters
extern bool LastBarOnly = true; 
extern int  HLR_Range   = 40;
//---- buffers
double HLR_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(HLR_Range <= 1) 
       HLR_Range = 1; 
//---- indicators
   IndicatorShortName("Hi-Lo Range Oscillator (" + HLR_Range + ")"); 
   SetLevelStyle(STYLE_DASHDOT, 1, DodgerBlue); 
   SetIndexStyle(0, DRAW_LINE); 
   SetIndexLabel(0, "HLR"); 
   SetIndexBuffer(0, HLR_Buffer); 
   SetIndexDrawBegin(0, HLR_Range); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   int i, Limit, cnt_bars;
   double hhv, llv, m_pr; 
   static bool   run_once; 
   static double m_pr_old; 
// to prevent possible error 
   if(counted_bars < 0) 
       return(-1); 
   Limit = Bars - counted_bars;
// run once on start
   if(run_once == false) 
       cnt_bars = Limit - HLR_Range; 
   else
       if(LastBarOnly == false) 
           cnt_bars = Limit; 
       else
           cnt_bars = 0; 
   m_pr = (High[cnt_bars] + Low[cnt_bars]) / 2.0; 
//----
   if(MathAbs(m_pr - m_pr_old) < Point) 
       return(0); 
   else 
       m_pr_old = m_pr; 
//----
   for(i = cnt_bars; i >= 0; i--)
     {
       hhv  = High[iHighest(NULL, 0, MODE_HIGH, HLR_Range, i)];
       llv  =  Low[iLowest (NULL, 0, MODE_LOW,  HLR_Range, i)]; 
       m_pr = (High[i] + Low[i]) / 2.0; 
       HLR_Buffer[i] = 100.0 * (m_pr - llv) / (hhv - llv); 
     } 
//----
   if(run_once == false) 
       run_once = true; 
//----
   return(0);
  }
//+------------------------------------------------------------------+