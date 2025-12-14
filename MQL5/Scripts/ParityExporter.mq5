//+------------------------------------------------------------------+
//|                                              ParityExporter.mq5 |
//|                           EA_SCALPER_XAUUSD - Parity Validation |
//|      Export signals for Python parity validation                |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property script_show_inputs

#include "../Include/EA_SCALPER/Analysis/CRegimeDetector.mqh"

input datetime InpStartDate = D'2025.11.10 00:00:00';  // Start Date
input datetime InpEndDate   = D'2025.11.28 23:59:59';  // End Date
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_M15;       // Timeframe
input string InpOutputFile = "parity_signals_mql5.csv"; // Output File

CRegimeDetector g_regime;

void OnStart()
{
   Print("=== Parity Exporter Starting ===");
   Print("Start: ", InpStartDate);
   Print("End: ", InpEndDate);
   Print("TF: ", EnumToString(InpTimeframe));
   
   int file = FileOpen(InpOutputFile, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(file == INVALID_HANDLE)
   {
      Print("ERROR: Cannot create output file: ", InpOutputFile);
      return;
   }
   
   // Write header
   FileWrite(file, "timestamp", "bar_index", "close", 
             "hurst_short", "hurst_medium", "hurst_long", "hurst_exponent",
             "shannon_entropy", "variance_ratio", "multiscale_agreement",
             "transition_prob", "regime_velocity", "bars_in_regime",
             "regime", "confidence", "size_mult", "score_adj",
             "is_valid");
   
   // Get bar count
   int total_bars = Bars(_Symbol, InpTimeframe, InpStartDate, InpEndDate);
   Print("Total bars in range: ", total_bars);
   
   if(total_bars < 250)
   {
      Print("ERROR: Not enough bars (need at least 250, got ", total_bars, ")");
      FileClose(file);
      return;
   }
   
   // Process each bar
   int exported = 0;
   
   for(int shift = total_bars - 1; shift >= 0; shift--)
   {
      datetime bar_time = iTime(_Symbol, InpTimeframe, shift);
      
      if(bar_time < InpStartDate || bar_time > InpEndDate)
         continue;
      
      // Get closing price
      double close_price = iClose(_Symbol, InpTimeframe, shift);
      
      // Analyze regime at this bar
      SRegimeAnalysis regime = g_regime.AnalyzeRegime(_Symbol, InpTimeframe);
      
      // Write row
      FileWrite(file, 
         TimeToString(bar_time, TIME_DATE|TIME_MINUTES),
         shift,
         DoubleToString(close_price, 2),
         DoubleToString(regime.hurst_short, 4),
         DoubleToString(regime.hurst_medium, 4),
         DoubleToString(regime.hurst_long, 4),
         DoubleToString(regime.hurst_exponent, 4),
         DoubleToString(regime.shannon_entropy, 4),
         DoubleToString(regime.variance_ratio, 4),
         DoubleToString(regime.multiscale_agreement, 2),
         DoubleToString(regime.transition_probability, 4),
         DoubleToString(regime.regime_velocity, 6),
         regime.bars_in_regime,
         g_regime.RegimeToString(regime.regime),
         DoubleToString(regime.confidence, 2),
         DoubleToString(regime.size_multiplier, 3),
         regime.score_adjustment,
         regime.is_valid ? "true" : "false"
      );
      
      exported++;
      
      if(exported % 100 == 0)
         Print("Exported ", exported, " bars...");
   }
   
   FileClose(file);
   
   Print("=== Export Complete ===");
   Print("Total exported: ", exported, " bars");
   Print("Output file: ", InpOutputFile);
   Print("File location: ", TerminalInfoString(TERMINAL_DATA_PATH), "\\MQL5\\Files\\", InpOutputFile);
}
//+------------------------------------------------------------------+
