//+------------------------------------------------------------------+
//|                                               FibProgression.mq4
//+------------------------------------------------------------------+
#property indicator_chart_window

extern double highLow           = 0.0;
extern int    fibProgLines      = 6;
extern bool   progressionUpward = FALSE;
extern color  color1            = Yellow;
extern int    lineThickness     = 1;
//----
int  fibProgressStart = 0;
bool onceThrough      = FALSE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function
//+------------------------------------------------------------------+
int init()
{
   int i, startIndx = 0;
//----
   if((lineThickness < 1) || (lineThickness > 5 ))
      lineThickness = 1;
   if((fibProgLines < 2) || (fibProgLines > 20))
      fibProgLines = 6;
   while(TRUE)
   {
      for(fibProgressStart = startIndx; ; fibProgressStart++)
         if(ObjectFind("Prog" + fibProgressStart) == -1)
            break;
      for(i = fibProgressStart; i < (fibProgressStart + fibProgLines); i++)
         if(ObjectFind("Prog" + i) == 0)
            break;
      if(i == (fibProgressStart + fibProgLines))
         break;
      else
         startIndx += (fibProgressStart + fibProgLines);
   }
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function
//+------------------------------------------------------------------+
int deinit()
{
   int i;
//----
   for(i = fibProgressStart; i < (fibProgressStart + fibProgLines); i++)
      ObjectDelete("Prog" + i);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function
//+------------------------------------------------------------------+
int start()
{
   int i, prevAdder = 34, adder = 55;
   double tmp00, tmp01, tmp02;
//----
   if(!onceThrough)
      for(i = fibProgressStart; i < (fibProgressStart + fibProgLines); i++)
      {
         tmp00 = adder * Point;
         tmp01 = prevAdder * Point;
         if(progressionUpward)
            tmp02 = highLow + tmp00;
         else
            tmp02 = highLow - tmp00;
         ObjectCreate("Prog" + i, OBJ_HLINE, 0, Time[1], tmp02);
         ObjectSet("Prog" + i, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet("Prog" + i, OBJPROP_COLOR, color1);
         ObjectSet("Prog" + i, OBJPROP_WIDTH, lineThickness);
         adder += prevAdder;
         prevAdder = adder - prevAdder;
      }
   onceThrough = TRUE;
//----
   return(0);
}
//+------------------------------------------------------------------+