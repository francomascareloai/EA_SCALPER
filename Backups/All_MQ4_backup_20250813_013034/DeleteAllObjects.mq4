//+------------------------------------------------------------------+
//|                                             DeleteAllObjects.mq4 |
//|                       Copyright 2014, ForexTradingAutomation.com |
//|                                http://ForexTradingAutomation.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, ForexTradingAutomation.com"
#property link      "http://ForexTradingAutomation.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   long currChart;
   long prevChart=ChartFirst();
   int deleted = ObjectsDeleteAll(prevChart);
   int chartCount = 1;
   // Loop through charts
   while(true)
     {
      // Get next chart
      currChart=ChartNext(prevChart);
      // If currChart < 0 ==> we iterated through all charts, exit loop
      if(currChart<0)
         break;
      deleted += ObjectsDeleteAll(currChart);
      chartCount++;
      prevChart=currChart;
     }
   PrintFormat("Deleted %d objects on %d charts", deleted, chartCount);     
  }
//+------------------------------------------------------------------+
