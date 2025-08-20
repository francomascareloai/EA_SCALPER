//+------------------------------------------------------------------+
//|                                                AutoDayFibs V1.3  |
//|                                                                  |
//|              Copyright © 2005-2008, Jason Robinson (jnrtrading)  |
//|                                 http://www.spreadtrade2win.com   |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//|Options: AutomaticallyAdjustToToday (true/false);                 |
//|               Determine whether to have the indicator            |
//|               automatically adjust to todays prices.             |
//|         TimeToAdjust (in 24 hour format 0-23);                   |
//|               If AutomaticallyAdjustToToday is set               |
//|               to 'true' then you can determine at                |
//|               what time the fib lines switch to using            |
//|               todays prices instead of yesterdays.               |
//|               Works only for whole hours.                        |
//|         DaysBackForHigh and DaysBackForLow;                      |
//|               If AutomaticallyAdjustToToday is set               |
//|               to 'false' then you can adjust the                 |
//|               amount of days back to take the high               |
//|               and low readings from.                             |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005-2008, Jason Robinson (jnrtrading)"
#property link      "http://www.spreadtrade2win.com"

#property indicator_chart_window
extern bool AutomaticallyAdjustToToday = true;
extern int TimeToAdjust;
extern int DaysBackForHigh;
extern int DaysBackForLow;
extern color ColourOfLines = DodgerBlue;


double Rates[][6];

double fib000,
       fib236,
       fib382,
       fib50,
       fib618,
       fib764,
       fib100,
       fib1618,
       fib2618,
       fib4236,
       range,
       prevRange,
       high,
       low;
    
bool objectsExist, highFirst;

//---- buffers

       

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
prevRange = 0;
objectsExist = false;
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   ObjectDelete("fib000");
   ObjectDelete("fib000_label");
   ObjectDelete("fib236");
   ObjectDelete("fib236_label");
   ObjectDelete("fib382");
   ObjectDelete("fib382_label");
   ObjectDelete("fib50");
   ObjectDelete("fib50_label");
   ObjectDelete("fib618");
   ObjectDelete("fib618_label");
   ObjectDelete("fib764");
   ObjectDelete("fib764_label");
   ObjectDelete("fib100");
   ObjectDelete("fib100_label");
   ObjectDelete("fib1618");
   ObjectDelete("fib1618_label");
   ObjectDelete("fib2618");
   ObjectDelete("fib2618_label");
   ObjectDelete("fib4236");
   ObjectDelete("fib4236_label");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//---- 
   //Print(prevRange);
   ArrayCopyRates(Rates, Symbol(), PERIOD_D1);   
   
   if (AutomaticallyAdjustToToday == true) {
      if (Hour() >= 0 && Hour() < TimeToAdjust) {
         DaysBackForHigh = 1;
         DaysBackForLow = 1;
      }
      else if (Hour() >= DaysBackForLow && Hour() <= 23) {
         DaysBackForHigh = 0;
         DaysBackForLow = 0;
      }
   }
   high = Rates[DaysBackForHigh][3];
   low = Rates[DaysBackForLow][2];
   range = high - low;
   
   for (int i = 0; i < Bars; i++) {
      if(High[i] == high) {
         highFirst = true;
         break;
      }
      else if(Low[i] == low) {
         highFirst = false;
         break;
      }
   } 
   //Print(highFirst);
   
   // Delete Objects if necessary
   if (prevRange != range) {
      ObjectDelete("fib000");
      ObjectDelete("fib000_label");
      ObjectDelete("fib236");
      ObjectDelete("fib236_label");
      ObjectDelete("fib382");
      ObjectDelete("fib382_label");
      ObjectDelete("fib50");
      ObjectDelete("fib50_label");
      ObjectDelete("fib618");
      ObjectDelete("fib618_label");
      ObjectDelete("fib764");
      ObjectDelete("fib764_label");
      ObjectDelete("fib100");
      ObjectDelete("fib100_label");
      ObjectDelete("fib1618");
      ObjectDelete("fib1618_label");
      ObjectDelete("fib2618");
      ObjectDelete("fib2618_label");
      ObjectDelete("fib4236");
      ObjectDelete("fib4236_label");
      objectsExist = false;
      prevRange = range;
      //Print("Objects do not exist");
   }
   
   if (highFirst == false) {
      fib000 = low;
      fib236 = (range * 0.236) + low;
      fib382 = (range * 0.382) + low;
      fib50 = (high + low) / 2;
      fib618 = (range * 0.618) + low;
      fib764 = (range * 0.764) + low;
      fib100 = high;
      fib1618 = (range * 0.618) + high;
      fib2618 = (range * 0.618) + (high + range);
      fib4236 = (range * 0.236) + high + (range * 3);
   }
   else if (highFirst == true) {
      fib000 = high;
      fib236 = high - (range * 0.236);
      fib382 = high - (range * 0.382);
      fib50  = (high + low) / 2;
      fib618 = high - (range * 0.618);
      fib764 = high - (range * 0.764);
      fib100 = low;
      fib1618 = low - (range * 0.618);
      fib2618 = (low - range) - (range * 0.618);// + (high + range);
      fib4236 = low - (range * 3) - (range * 0.236);// + high + (range * 3);
   }
   
   if (objectsExist == false) {
      ObjectCreate("fib000", OBJ_HLINE, 0, Time[0], fib000);
      ObjectSet("fib000", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib000", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib000_label", OBJ_TEXT, 0, Time[0], fib000);
      ObjectSetText("fib000_label","                             0.0", 8, "Times", Black);
   
      ObjectCreate("fib236", OBJ_HLINE, 0, Time[0], fib236);
      ObjectSet("fib236", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib236", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib236_label", OBJ_TEXT, 0, Time[0], fib236);
      ObjectSetText("fib236_label","                             23.6", 8, "Times", Black);
   
      ObjectCreate("fib382", OBJ_HLINE, 0, Time[0], fib382);
      ObjectSet("fib382", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib382", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib382_label", OBJ_TEXT, 0, Time[0], fib382);
      ObjectSetText("fib382_label","                             38.2", 8, "Times", Black);
   
      ObjectCreate("fib50", OBJ_HLINE, 0, Time[0], fib50);
      ObjectSet("fib50", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib50", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib50_label", OBJ_TEXT, 0, Time[0], fib50);
      ObjectSetText("fib50_label","                             50.0", 8, "Times", Black);
   
      ObjectCreate("fib618", OBJ_HLINE, 0, Time[0], fib618);
      ObjectSet("fib618", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib618", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib618_label", OBJ_TEXT, 0, Time[0], fib618);
      ObjectSetText("fib618_label","                             61.8", 8, "Times", Black);
   
      ObjectCreate("fib764", OBJ_HLINE, 0, Time[0], fib764);
      ObjectSet("fib764", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib764", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib764_label", OBJ_TEXT, 0, Time[0], fib764);
      ObjectSetText("fib764_label","                             76.4", 8, "Times", Black);
   
      ObjectCreate("fib100", OBJ_HLINE, 0, Time[0], fib100);
      ObjectSet("fib100", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib100", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib100_label", OBJ_TEXT, 0, Time[0], fib100);
      ObjectSetText("fib100_label","                             100.0", 8, "Times", Black);
   
      ObjectCreate("fib1618", OBJ_HLINE, 0, Time[0], fib1618);
      ObjectSet("fib1618", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib1618", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib1618_label", OBJ_TEXT, 0, Time[0], fib1618);
      ObjectSetText("fib1618_label","                             161.8", 8, "Times", Black);
   
      ObjectCreate("fib2618", OBJ_HLINE, 0, Time[0], fib2618);
      ObjectSet("fib2618", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib2618", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib2618_label", OBJ_TEXT, 0, Time[0], fib2618);
      ObjectSetText("fib2618_label","                             261.8", 8, "Times", Black);
   
      ObjectCreate("fib4236", OBJ_HLINE, 0, Time[0], fib4236);
      ObjectSet("fib4236", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet("fib4236", OBJPROP_COLOR, ColourOfLines);
      ObjectCreate("fib4236_label", OBJ_TEXT, 0, Time[0], fib4236);
      ObjectSetText("fib4236_label","                             423.6", 8, "Times", Black);
      //Print("Objects Exist");
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+