//+------------------------------------------------------------------+
//|                                                    MathUtils.mqh |
//|                       EA_SCALPER_XAUUSD - Math Utility Functions |
//|                    Shared utilities for lot size, price, etc.    |
//+------------------------------------------------------------------+
#ifndef MATHUTILS_MQH
#define MATHUTILS_MQH

#property copyright "EA_SCALPER_XAUUSD"
#property strict

// === LOT SIZE NORMALIZATION ===
// Threshold for division-by-zero guards
#define EPSILON_LOT    0.00001

//+------------------------------------------------------------------+
//| Normalize lot size to symbol constraints                          |
//| Returns normalized lot or 0.0 on error                           |
//+------------------------------------------------------------------+
double NormalizeLotSize(string symbol, double lot)
{
   double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   // Division-by-zero guard
   if(step <= EPSILON_LOT)
   {
      Print("NormalizeLotSize: SYMBOL_VOLUME_STEP is zero for ", symbol, " - using default 0.01");
      step = 0.01;
   }

   // Clamp to min/max
   lot = MathMax(min_lot, MathMin(max_lot, lot));

   // Round down to step
   lot = MathFloor(lot / step) * step;

   // Normalize to 2 decimal places (standard for lots)
   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Normalize lot size using current symbol                           |
//+------------------------------------------------------------------+
double NormalizeLotSizeCurrentSymbol(double lot)
{
   return NormalizeLotSize(_Symbol, lot);
}

//+------------------------------------------------------------------+
//| Check if lot size is valid for trading                            |
//| Returns true if lot >= min_lot and lot <= max_lot                 |
//+------------------------------------------------------------------+
bool IsValidLotSize(string symbol, double lot)
{
   double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);

   return (lot >= min_lot && lot <= max_lot);
}

//+------------------------------------------------------------------+
//| Get minimum tradeable lot size for symbol                         |
//+------------------------------------------------------------------+
double GetMinLotSize(string symbol)
{
   return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
}

//+------------------------------------------------------------------+
//| Get maximum tradeable lot size for symbol                         |
//+------------------------------------------------------------------+
double GetMaxLotSize(string symbol)
{
   return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
}

//+------------------------------------------------------------------+
//| Get lot step for symbol                                           |
//+------------------------------------------------------------------+
double GetLotStep(string symbol)
{
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(step <= EPSILON_LOT)
      return 0.01;  // Safe default
   return step;
}

#endif // MATHUTILS_MQH
//+------------------------------------------------------------------+
