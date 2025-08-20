//+------------------------------------------------------------------+
//|                                                Master_Candle.mq4 |
//|                                                         Emi Joy22|
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emi Joy22"
#property link      ""

#property indicator_chart_window

extern int MinEngulfCandles = 4;
extern color TopLineColor = Green;
extern color BottomLineColor = Maroon;
extern int LineWidth = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
   int    obj_total=ObjectsTotal();
   string name, topLine, bottomLine;
   topLine = Symbol()+"_"+Period()+"_MasterTop_";
   bottomLine = Symbol()+"_"+Period()+"_MasterBottom_";
   for(int i=obj_total-1; i>=0; i--)
   {
      name=ObjectName(i);
      if (StringFind(name,topLine,0) != -1 || StringFind(name,bottomLine,0) != -1)
      {
         ObjectDelete(name);
      }
   }
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int i;                           // Bar index       
   int Counted_bars;                // Number of counted bars
   //--------------------------------------------------------------------   
   Counted_bars=IndicatorCounted(); // Number of counted bars   
   i=Bars-Counted_bars-1;           // Index of the first uncounted   
   
   // always recount the latest possible location for a master candle to be formed
   if (i == 0)
   {
      i = MinEngulfCandles+1; 
   }
   while(i>MinEngulfCandles)                      // Loop for uncounted bars     
   {      
      if (isMasterCandle(i))
      {
         DrawLines(i);
      }
      i--;
   }
//----
   return(0);
}

bool isMasterCandle(int index)
{
   double CandleTop = High[index];
   double CandleBottom = Low[index];
   
   for (int h = index-1; h >= index - MinEngulfCandles; h--)
   {
      if (High[h] > CandleTop || Low[h] < CandleBottom)
      {
         return (false);
      }
   }
   
   return (true);
}

void DrawLines(int index)
{
   string TopName = Symbol()+"_"+Period()+"_MasterTop_" + Time[index];
   ObjectCreate(TopName, OBJ_TREND, 0, Time[index], High[index], Time[index - MinEngulfCandles], High[index]);
   ObjectSet(TopName, OBJPROP_RAY, false);
   ObjectSet(TopName, OBJPROP_WIDTH, LineWidth);
   ObjectSet(TopName, OBJPROP_COLOR, TopLineColor);
   
   string BottomName = Symbol()+"_"+Period()+"_MasterBottom_" + Time[index];
   ObjectCreate(BottomName, OBJ_TREND, 0, Time[index], Low[index], Time[index - MinEngulfCandles], Low[index]);
   ObjectSet(BottomName, OBJPROP_RAY, false);
   ObjectSet(BottomName, OBJPROP_WIDTH, LineWidth);
   ObjectSet(BottomName, OBJPROP_COLOR, BottomLineColor);
}
//+------------------------------------------------------------------+