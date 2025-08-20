//+------------------------------------------------------------------+
//|                                      2Extreme4U Grid Builder.mq4 |
//|                     Copyright © 2005, Siddiqi, Alejandro Galindo |
//|                                              http://elCactus.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Siddiqi, Alejandro Galindo"
#property link      "http://elCactus.com"

#property indicator_chart_window
extern int GridSpace=50;
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
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   double shift=0;
   double HighPrice=0;
   double LowPrice=0;

   double Divisor=0.1/Point;

   HighPrice=MathRound(High[Highest(NULL,0,2, Bars - 2,  2)] * Divisor);
   //SL = High[Highest(MODE_HIGH, SLLookback, SLLookback)];
   LowPrice=MathRound(Low[Lowest(NULL,0,1, Bars - 1, 2)] * Divisor);
   for(shift=LowPrice;shift<=HighPrice;shift++)
     {
      ObjectDelete("Grid"+shift);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   double I=0;
   double HighPrice=0;
   double LowPrice=0;
   int GridS=0;
   int SL=0;
//----    

   double Divisor=0.1/Point;

   HighPrice=MathRound(High[Highest(NULL,0,MODE_HIGH, Bars - 2, 2)] * Divisor);
   //SL = High[Highest(MODE_HIGH, SLLookback, SLLookback)];
   LowPrice=MathRound(Low[Lowest(NULL,0,MODE_LOW, Bars - 1, 2)] * Divisor);
   GridS=GridSpace/10;

   for(I=LowPrice;I<=HighPrice;I++)
     {
      //Print("mod(I, GridSpace): " + MathMod(I, GridS) + " I= " + I);
      //Print(LowPrice + " " + HighPrice);
      if (MathMod(I, GridS)==0)
        {
         if (ObjectFind("Grid"+I)!=0)
           {
            ObjectCreate("Grid"+I, OBJ_HLINE, 0, Time[1], I/Divisor);
            ObjectSet("Grid"+I, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("Grid"+I, OBJPROP_COLOR, MediumSeaGreen);
           }
         //MoveObject(I + "Grid", OBJ_HLINE, Time[Bars - 2], I/1000, Time[1], I/1000, MediumSeaGreen, 1, STYLE_SOLID);
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+