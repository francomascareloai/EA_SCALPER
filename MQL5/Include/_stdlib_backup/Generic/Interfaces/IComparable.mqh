//+------------------------------------------------------------------+
//|                                                  IComparable.mqh |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "IEqualityComparable.mqh"
//+------------------------------------------------------------------+
//| Interface IComparable<T>.                                        |
//| Usage: Defines a generalized comparison method to create a       |
//| type-specific comparison method for ordering or sorting          |
//| instances.                                                       |
//+------------------------------------------------------------------+
template<typename T>
interface IComparable: public IEqualityComparable<T>
  {
//--- method for determining compare
   int       Compare(T value);
  };
//+------------------------------------------------------------------+
