//+------------------------------------------------------------------+
//|                                                  ICollection.mqh |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Interface ICollection<T>.                                        |
//| Usage: Defines methods to manipulate generic collections.        |
//+------------------------------------------------------------------+
template<typename T>
interface ICollection
  {
//--- methods of filling data 
   bool      Add(T value);
//--- methods of access to protected data
   int       Count(void);
   bool      Contains(T item);
//--- methods of copy data from collection   
   int       CopyTo(T &dst_array[],const int dst_start=0);
//--- methods of cleaning and removing
   void      Clear(void);
   bool      Remove(T item);
  };
//+------------------------------------------------------------------+
