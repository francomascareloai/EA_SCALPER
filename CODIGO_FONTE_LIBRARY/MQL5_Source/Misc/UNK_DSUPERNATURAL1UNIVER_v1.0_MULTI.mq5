//+------------------------------------------------------------------+
//|                DSUPERNATURAL1 UNIVERSAL TRAILING STOP EA         |
//|                  Works with multiple Magic Numbers               |
//|                        Version 1.10
                  
//+------------------------------------------------------------------+
#property copyright "Copyright 2025,Robot Developer DSUPERNATURAL1"
#property version   "1.10"
#property strict
#property description "build by DSUPERNATURAL1 4 D GOOD OF ALL, THIS Expert implementing trailing logic to any ea VIA use of magic numbers separated by comma."
#property link "FOR CODING SERVICES AND FEEDBACKS MAIL US AT COVENANTOFBLESSING@GMAIL.COM, WE CAN TEACH AND HELP U TO BUILD ANY INDICATOR OR EA"
#property description "PUBLIC DISCLAMER:BY USING THIS EA FOREX TERMS AND CONDITIONS IS BINDING ON YOU, BE PROPERLY GUIDED"
#property description "FOR CODING SERVICES AND FEEDBACKS MAIL US AT COVENANTOFBLESSING@GMAIL.COM , CHAT US ON TELEGRAM @AMDBLESSED1"
#property link      " CHAT US ON TELEGRAM @AMDBLESSED1"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//--- Input parameters
input string   MagicNumbers       = "4953"; // Magic Numbers to track (comma separated)
input double   TrailStartPips     = 50.0;            // Trail Start (pips)
input double   TrailStopPips      = 20.0;            // Trail Stop (pips)
input double   TrailStepPips      = 10.0;            // Trail Step (pips)
input bool     EnableVirtualStops = true;           // Enable Virtual Stops
input int      VirtualStopTimeout = 0;               // Virtual Stop Timeout (seconds)

//--- Global variables
double pipValue;
long   magicNumbersArray[]; // Use long for magic numbers
CTrade trade;
CPositionInfo positionInfo;
COrderInfo orderInfo;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Calculate pip value based on symbol digits
   pipValue = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1) ? _Point * 10 : _Point;
   
   // Parse magic numbers
   ParseMagicNumbers(MagicNumbers);
   
   // Validate magic numbers
   if(ArraySize(magicNumbersArray) == 0)
   {
      Print("Error: No valid magic numbers provided");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   Print("Universal Trailing Stop EA started for Magic Numbers: ", MagicNumbers);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Universal Trailing Stop EA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Parse comma-separated magic numbers into array                   |
//+------------------------------------------------------------------+
void ParseMagicNumbers(string magicNumbersStr)
{
   string magicNumbersList[];
   int count = StringSplit(magicNumbersStr, ',', magicNumbersList);
   
   ArrayResize(magicNumbersArray, count);
   
   for(int i = 0; i < count; i++)
   {
      long magic = StringToInteger(StringTrim(magicNumbersList[i]));
      if(magic > 0) // Ensure valid magic number
         magicNumbersArray[i] = magic;
      else
         Print("Warning: Invalid magic number '", magicNumbersList[i], "' ignored");
   }
}

//+------------------------------------------------------------------+
//| Check if magic number is in our list                             |
//+------------------------------------------------------------------+
bool IsOurMagicNumber(long magic)
{
   for(int i = 0; i < ArraySize(magicNumbersArray); i++)
   {
      if(magic == magicNumbersArray[i])
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Process trailing stops on every tick
   TrailingStop();
   
   // Process virtual stops if enabled
   if(EnableVirtualStops)
   {
      VirtualStopsDriver("listen");
   }
}

//+------------------------------------------------------------------+
//| Trailing Stop Function                                           |
//+------------------------------------------------------------------+
void TrailingStop()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(positionInfo.SelectByIndex(i))
      {
         // Only process positions with our magic numbers
         if(!IsOurMagicNumber(positionInfo.Magic())) continue;
         
         string symbol = positionInfo.Symbol();
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
         
         double currentStop = positionInfo.StopLoss();
         double newStop = currentStop;
         double openPrice = positionInfo.PriceOpen();
         double currentPrice = positionInfo.PriceCurrent();
         double trailStart = TrailStartPips * pipValue;
         double trailStop = TrailStopPips * pipValue;
         double trailStep = TrailStepPips * pipValue;
         
         if(positionInfo.PositionType() == POSITION_TYPE_BUY)
         {
            if(currentPrice - openPrice >= trailStart)
            {
               if(currentStop == 0 || (currentPrice - trailStop) > currentStop)
               {
                  newStop = NormalizeDouble(currentPrice - trailStop, digits);
                  // Adjust to trail step
                  if(currentStop != 0 && (newStop - currentStop) < trailStep)
                  {
                     newStop = NormalizeDouble(currentStop + trailStep, digits);
                  }
               }
            }
         }
         else if(positionInfo.PositionType() == POSITION_TYPE_SELL)
         {
            if(openPrice - currentPrice >= trailStart)
            {
               if(currentStop == 0 || (currentPrice + trailStop) < currentStop)
               {
                  newStop = NormalizeDouble(currentPrice + trailStop, digits);
                  // Adjust to trail step
                  if(currentStop != 0 && (currentStop - newStop) < trailStep)
                  {
                     newStop = NormalizeDouble(currentStop - trailStep, digits);
                  }
               }
            }
         }
         
         // Only modify if new stop is better than current
         if(newStop != currentStop)
         {
            if(!trade.PositionModify(positionInfo.Ticket(), newStop, positionInfo.TakeProfit()))
            {
               Print("Failed to modify position ", positionInfo.Ticket(), 
                     ". Error: ", GetLastError(), 
                     " Current: ", currentStop, 
                     " New: ", newStop);
            }
            else
            {
               Print("Trailing stop updated for position ", positionInfo.Ticket(),
                     " New stop: ", newStop);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Virtual Stops Driver Function                                    |
//+------------------------------------------------------------------+
double VirtualStopsDriver(
   string command = "",
   ulong ti = 0,
   double sl = 0,
   double tp = 0,
   double slp = 0,
   double tpp = 0
)
{
   static bool initialized = false;
   static string name = "";
   static string loop_name[2] = {"sl", "tp"};
   static color loop_color[2] = {clrRed, clrBlue};
   static double loop_price[2] = {0, 0};
   static bool trade_pass = false;
   static ulong mem_to_ti[]; // tickets
   static int mem_to[];      // timeouts
   int i = 0;

   if(!EnableVirtualStops) return 0;

   if(!initialized || command == "initialize")
   {
      initialized = true;
      pipValue = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1) ? _Point * 10 : _Point;
   }

   if(command == "" || command == "listen")
   {
      int total = ObjectsTotal(0, -1, OBJ_HLINE);
      int length = 0;
      color clr = clrNONE;
      int sltp = 0;
      ulong ticket = 0;
      double level = 0;
      double askbid = 0;
      int polarity = 0;
      string symbol = "";

      for(i = total - 1; i >= 0; i--)
      {
         name = ObjectName(0, i, -1, OBJ_HLINE);
         if(StringSubstr(name, 0, 1) != "#") continue;
         
         length = StringLen(name);
         if(length < 5) continue;
         
         clr = (color)ObjectGetInteger(0, name, OBJPROP_COLOR);
         if(clr != loop_color[0] && clr != loop_color[1]) continue;
         
         string last_symbols = StringSubstr(name, length-2, 2);
         if(last_symbols == "sl") sltp = -1;
         else if(last_symbols == "tp") sltp = 1;
         else continue;
         
         ulong ticket0 = StringToInteger(StringSubstr(name, 1, length-4));
         if(ticket0 != ticket)
         {
            ticket = ticket0;
            if(positionInfo.SelectByTicket(ticket) && IsOurMagicNumber(positionInfo.Magic()))
            {
               symbol = positionInfo.Symbol();
               polarity = (positionInfo.PositionType() == POSITION_TYPE_BUY) ? 1 : -1;
               askbid = (positionInfo.PositionType() == POSITION_TYPE_BUY) ? 
                        SymbolInfoDouble(symbol, SYMBOL_BID) : SymbolInfoDouble(symbol, SYMBOL_ASK);
               trade_pass = true;
            }
            else trade_pass = false;
         }
         
         if(trade_pass)
         {
            level = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
            if(level > 0)
            {
               double level_p = polarity * level;
               double askbid_p = polarity * askbid;
               
               if((sltp == -1 && (level_p - askbid_p) >= 0) || // sl
                  (sltp == 1 && (askbid_p - level_p) >= 0))    // tp
               {
                  if((VirtualStopTimeout > 0) && (sltp == -1))
                  {
                     int index = ArraySearch(mem_to_ti, ticket);
                     if(index < 0)
                     {
                        int size = ArraySize(mem_to_ti);
                        ArrayResize(mem_to_ti, size+1);
                        ArrayResize(mem_to, size+1);
                        mem_to_ti[size] = ticket;
                        mem_to[size] = (int)TimeLocal();
                        Print("#", ticket, " timeout of ", VirtualStopTimeout, " seconds started");
                        continue;
                     }
                     else if(TimeLocal() - mem_to[index] <= VirtualStopTimeout)
                     {
                        continue;
                     }
                  }
                  
                  if(trade.PositionClose(ticket))
                  {
                     Print("Position ", ticket, " closed by virtual ", (sltp == -1 ? "stop loss" : "take profit"));
                     ObjectDelete(0, "#" + (string)ticket + " sl");
                     ObjectDelete(0, "#" + (string)ticket + " tp");
                  }
               }
            }
         }
         else if(!orderInfo.Select(ticket) || orderInfo.State() == ORDER_STATE_FILLED || orderInfo.State() == ORDER_STATE_CANCELED)
         {
            ObjectDelete(0, name);
         }
      }
      return 0;
   }
   else if(ti > 0 && (command == "get sl" || command == "get tp"))
   {
      double value = 0;
      name = "#" + IntegerToString(ti) + " " + StringSubstr(command, 4, 2);
      if(ObjectFind(0, name) > -1)
         value = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
      return value;
   }
   else if(ti > 0 && (command == "set" || command == "modify" || command == "clear" || command == "partial"))
   {
      loop_price[0] = sl;
      loop_price[1] = tp;
      
      for(i = 0; i < 2; i++)
      {
         name = "#" + IntegerToString(ti) + " " + loop_name[i];
         if(loop_price[i] > 0)
         {
            if(ObjectFind(0, name) == -1)
            {
               ObjectCreate(0, name, OBJ_HLINE, 0, 0, loop_price[i]);
               ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, name, OBJPROP_COLOR, loop_color[i]);
               ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
               ObjectSetString(0, name, OBJPROP_TEXT, name + " (virtual)");
            }
            else ObjectSetDouble(0, name, OBJPROP_PRICE, 0, loop_price[i]);
         }
         else ObjectDelete(0, name);
      }
      
      if(command == "set" || command == "modify")
      {
         Print(command, " #", IntegerToString(ti), ": virtual sl ", 
               DoubleToString(sl, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
               " tp ", DoubleToString(tp, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)));
      }
      return 1;
   }
   
   return 0; // Default return for all control paths
}

//+------------------------------------------------------------------+
//| Helper Functions                                                |
//+------------------------------------------------------------------+
int ArraySearch(ulong &array[], ulong value)
{
   for(int i = 0; i < ArraySize(array); i++)
      if(array[i] == value) return i;
   return -1;
}

string StringTrim(string str)
{
   string result = str;
   StringTrimLeft(result);
   StringTrimRight(result);
   return result;
}
//+------------------------------------------------------------------+