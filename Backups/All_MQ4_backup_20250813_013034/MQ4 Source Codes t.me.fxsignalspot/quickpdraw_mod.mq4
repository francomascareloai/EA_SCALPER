//+------------------------------------------------------------------+
//|                                                   quick draw.mq4 |
//|                                                           .....h |
//|                                                 hayseedville.com |
//+------------------------------------------------------------------+
#property copyright ".....h"
#property link      "hayseedville.com"

#property indicator_chart_window

extern double start       =    0.0; 
extern int    pips        =    100;
extern int    steps       =      5;
extern bool   DrawUp      =   true;
extern bool   DrawDown    =   true;
extern color  clr         =   SteelBlue;  
extern int    LineWidth   =   1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
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
//----
   int i;
   
   if(DrawUp)
   {
   for(i=0; i<steps;i++)
    {
    Draw("up"+i,start+pips*i*Point);
    }
   }
 
   if(DrawDown)
   {
   for(i=0; i<steps;i++)
    {
    Draw("dn"+i,start-pips*i*Point);
    }
   }
 
 
 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

   
   void Draw(string name, double level)
   {  
   ObjectDelete(name);
   ObjectCreate(name, OBJ_HLINE, 0, 0, level);
   ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name, OBJPROP_WIDTH, LineWidth);
   ObjectSet(name, OBJPROP_COLOR, clr);
   }
   

