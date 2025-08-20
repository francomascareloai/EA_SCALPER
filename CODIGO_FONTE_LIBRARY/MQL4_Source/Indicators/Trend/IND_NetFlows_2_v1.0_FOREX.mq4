//+------------------------------------------------------------------+
//|                                                     NetFlows.mq4 |
//|                                  Copyright © 2010, Shon Shampain |
//|                                       http://www.zencowsgomu.com |
//|                                                                  |
//|       Visit http://www.zencowsgomu.com, an oasis of sanity       |
//|                      for currency traders.                       |
//|                                                                  |
//|       Original out-of-the-box thinking, ideas, indicators,       |
//|                    educational EAs and more.                     |
//|                                                                  |
//|         Home of the consistent T4 Forex trading signal.          |
//|             Backtesting profitably since 1-1-2002.               |
//+------------------------------------------------------------------+

#property copyright "Shon Shampain"
#property link      "http://www.zencowsgomu.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Yellow

extern bool tenths = true;
int NUM_CURRENCIES = 8;
string currencies [8];
string pairs[50]; // We could allocate this dynamically based upon actual numbers, but...
int pix;
double mult [50];
bool is_first[50];
bool is_second[50];
double Index1 [];
double Index2 [];
string first, second;

int init()
{
   currencies[0] = "USD";
   currencies[1] = "EUR";
   currencies[2] = "GBP";
   currencies[3] = "JPY";
   currencies[4] = "CHF";
   currencies[5] = "CAD";
   currencies[6] = "NZD";
   currencies[7] = "AUD";

   pix = 0;
   
   /* The first step is to try every currency vs. every other currency
      to determine which pairs are supported on our platform. */
   int i, j, z;
   string build;
   int d;
   
   for (i = 0; i < NUM_CURRENCIES; i++)
   {
      for (j = i + 1; j < NUM_CURRENCIES; j++)
      {
         build = StringConcatenate(currencies[i], currencies[j]);
         d = MarketInfo(build, MODE_DIGITS);
         /* Note: AFAIK, testing for platform inclusion of a pair by
            seeing if MarketInfo(Digits) returns a good value is undocumented,
            but it seems to work the way we want. */
         if (d > 0)
         {
            pairs[pix] = build;
            pix++;
         }
         else
         {
            /* Try the inverse mapping */
            build = StringConcatenate(currencies[j], currencies[i]);
            d = MarketInfo(build, MODE_DIGITS);
            if (d > 0)
            {
               pairs[pix] = build;
               pix++;
            }
         }
      }
   }
   
   Print("The following ", pix, " pairs seem to be present on your platform:");
   for (i = 0; i < pix; i++)
      Print((i+1), ": ", pairs[i]);

   for (z = 0; z < pix; z++)
   {
      d = MarketInfo(pairs[z], MODE_DIGITS);
      if (tenths) d -= 1;
      mult[z] = 1.0;
      for (int x = 0; x < d; x++)
         mult[z] *= 10.0;
   }

   /* Step through all currency pairs, and mark if they belong to either the first
      currency's index, or the second's. */
   first = StringSubstr(Symbol(), 0, 3);
   second = StringSubstr(Symbol(), 3, 3);
   for (z = 0; z < pix; z++)
   {
      is_first[z] = (StringFind(pairs[z], first) != -1);
      is_second[z] = (StringFind(pairs[z], second) != -1);
   }
   
   Print("The Net Flow index for ", first, " is made up of:");
   for (z = 0; z < pix; z++)
      if (is_first[z])
         Print(pairs[z]);
   Print("The Net Flow index for ", second, " is made up of:");
   for (z = 0; z < pix; z++)
      if (is_second[z])
         Print(pairs[z]);
         
   SetIndexBuffer(0, Index1);
   SetIndexBuffer(1, Index2);
      
   SetLevelValue(0, 0.0);
   SetLevelStyle(STYLE_DOT, 1, Silver);
  
   return(0);
}

int deinit()
{
   return(0);
}
  
double net_flow(int i, string which, bool is_marked [])
{
   double value = 0.0;
   for (int z = 0; z < pix; z++)
   {
      if (is_marked[z])
      {
         bool short1 = (StringFind(StringSubstr(pairs[z], 3), which) != -1);
         double pips = (iClose(pairs[z], Period(), i) - iOpen(pairs[z], Period(), i)) * mult[z];
         double weighted_pips = pips * iVolume(pairs[z], Period(), i);
         if (short1) value -= weighted_pips;
         else value += weighted_pips;
      }
   }
   return(value);
}
 
int start()
{
   int z;
   double value;
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int i = Bars - counted_bars;
   if(counted_bars==0) i--;
   
   while(i>=0)
   {
      Index1[i] = net_flow(i, first, is_first);
      Index2[i] = net_flow(i, second, is_second);
      i--;
   }
   
   return(0);
}

