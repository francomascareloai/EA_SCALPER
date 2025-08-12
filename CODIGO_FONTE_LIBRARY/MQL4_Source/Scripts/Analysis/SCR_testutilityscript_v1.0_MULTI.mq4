//+------------------------------------------------------------------+
//|                                         Test Utility Script.mq4 |
//|                        Copyright 2025, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

// Input parameters
input string SymbolToAnalyze = "EURUSD";
input ENUM_TIMEFRAMES TimeFrame = PERIOD_H1;
input int BarsToAnalyze = 100;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("Starting utility script analysis...");
   
   // Analyze symbol data
   AnalyzeSymbol(SymbolToAnalyze, TimeFrame, BarsToAnalyze);
   
   // Generate report
   GenerateReport();
   
   Print("Utility script analysis completed.");
}

//+------------------------------------------------------------------+
//| Analyze symbol function                                          |
//+------------------------------------------------------------------+
void AnalyzeSymbol(string symbol, ENUM_TIMEFRAMES tf, int bars)
{
   double high_sum = 0;
   double low_sum = 0;
   double close_sum = 0;
   
   for(int i = 0; i < bars; i++)
   {
      high_sum += iHigh(symbol, tf, i);
      low_sum += iLow(symbol, tf, i);
      close_sum += iClose(symbol, tf, i);
   }
   
   double avg_high = high_sum / bars;
   double avg_low = low_sum / bars;
   double avg_close = close_sum / bars;
   
   Print("Analysis for ", symbol, " on ", EnumToString(tf));
   Print("Average High: ", DoubleToString(avg_high, 5));
   Print("Average Low: ", DoubleToString(avg_low, 5));
   Print("Average Close: ", DoubleToString(avg_close, 5));
}

//+------------------------------------------------------------------+
//| Generate report function                                         |
//+------------------------------------------------------------------+
void GenerateReport()
{
   string report = "";
   report += "=== MARKET ANALYSIS REPORT ===\n";
   report += "Symbol: " + SymbolToAnalyze + "\n";
   report += "TimeFrame: " + EnumToString(TimeFrame) + "\n";
   report += "Bars Analyzed: " + IntegerToString(BarsToAnalyze) + "\n";
   report += "Analysis Date: " + TimeToString(TimeCurrent()) + "\n";
   report += "==============================\n";
   
   Print(report);
}