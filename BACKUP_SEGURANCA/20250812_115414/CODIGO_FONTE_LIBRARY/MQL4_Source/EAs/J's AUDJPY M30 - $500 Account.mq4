//
// Robot Factory Portfolio Expert Advisor
//
// Created with: Forex Robot Factory | Expert Advisor Generator
// Website: https://www.forexrobotacademy.com/expert-advisor-generator/
//
// Copyright 2022, Forex Software Ltd.
//
// This Portfolio Expert works in MetaTrader 4.
// It opens separate positions for each strategy.
// Every position has an unique magic number, which corresponds to the index of the strategy.
//
// Risk Disclosure
//
// Futures and forex trading contains substantial risk and is not for every investor.
// An investor could potentially lose all or more than the initial investment.
// Risk capital is money that can be lost without jeopardizing ones’ financial security or life style.
// Only risk capital should be used for trading and only those with sufficient risk capital should consider trading.

#property copyright "Forex Software Ltd."
#property version   "3.3"
#property strict

static input double Entry_Amount       =    0.01; // Entry lots
static input int    Base_Magic_Number  =     100; // Base Magic Number

static input string ___Options_______  = "-----"; // --- Options ---
static input int    Max_Open_Positions =     100; // Max Open Positions

#define TRADE_RETRY_COUNT   4
#define TRADE_RETRY_WAIT  100
#define OP_FLAT            -1

// Session time is set in seconds from 00:00
const int  sessionSundayOpen           =     0; // 00:00
const int  sessionSundayClose          = 86400; // 24:00
const int  sessionMondayThursdayOpen   =     0; // 00:00
const int  sessionMondayThursdayClose  = 86400; // 24:00
const int  sessionFridayOpen           =     0; // 00:00
const int  sessionFridayClose          = 86400; // 24:00
const bool sessionIgnoreSunday         = false;
const bool sessionCloseAtSessionClose  = false;
const bool sessionCloseAtFridayClose   = false;

const int    strategiesCount = 75;
const double sigma        = 0.000001;
const int    requiredBars = 84;

datetime barTime;
double   stopLevel;
double   pip;
bool     setProtectionSeparately = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OrderScope
  {
   ORDER_SCOPE_UNDEFINED,
   ORDER_SCOPE_ENTRY,
   ORDER_SCOPE_EXIT
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OrderDirection
  {
   ORDER_DIRECTION_NONE,
   ORDER_DIRECTION_BUY,
   ORDER_DIRECTION_SELL,
   ORDER_DIRECTION_BOTH
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Position
  {
   int    Type;
   int    Ticket;
   int    MagicNumber;
   double Lots;
   double Price;
   double StopLoss;
   double TakeProfit;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Signal
  {
   int            MagicNumber;
   OrderScope     Scope;
   OrderDirection Direction;
   int            StopLossPips;
   int            TakeProfitPips;
   bool           IsTrailingStop;
   bool           OppositeReverse;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   barTime   = Time[0];
   stopLevel = MarketInfo(_Symbol, MODE_STOPLEVEL);
   pip       = GetPipValue();

   return ValidateInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (ArraySize(Time) < requiredBars)
      return;

   if ( IsForceSessionClose() )
     {
      CloseAllPositions();
      return;
     }

   if (Time[0] > barTime)
     {
      barTime = Time[0];
      OnBar();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBar()
  {
   if ( IsOutOfSession() )
      return;

   Signal signalList[];
   SetSignals(signalList);
   int signalsCount = ArraySize(signalList);

   for (int i = 0; i < signalsCount; i++)
     {
      Signal signal = signalList[i];
      ManageSignal(signal);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageSignal(Signal &signal)
  {
   Position position = CreatePosition(signal.MagicNumber);

   if (position.Type != OP_FLAT && signal.Scope == ORDER_SCOPE_EXIT)
     {
      if ( (signal.Direction == ORDER_DIRECTION_BOTH) ||
           (position.Type == OP_BUY  && signal.Direction == ORDER_DIRECTION_SELL) ||
           (position.Type == OP_SELL && signal.Direction == ORDER_DIRECTION_BUY ) )
        {
         ClosePosition(position);
        }
     }

   if (position.Type != OP_FLAT && signal.Scope == ORDER_SCOPE_EXIT && signal.IsTrailingStop)
     {
      double trailingStop = GetTrailingStopPrice(position, signal.StopLossPips);
      Print(trailingStop);
      ManageTrailingStop(position, trailingStop);
     }

   if (position.Type != OP_FLAT && signal.OppositeReverse)
     {
      if ( (position.Type == OP_BUY  && signal.Direction == ORDER_DIRECTION_SELL) ||
           (position.Type == OP_SELL && signal.Direction == ORDER_DIRECTION_BUY ) )
        {
         ClosePosition(position);
         ManageSignal(signal);
         return;
        }
     }

   if (position.Type == OP_FLAT && signal.Scope == ORDER_SCOPE_ENTRY)
     {
      if (signal.Direction == ORDER_DIRECTION_BUY || signal.Direction == ORDER_DIRECTION_SELL)
        {
         if ( CountPositions() < Max_Open_Positions )
            OpenPosition(signal);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountPositions()
  {
   int minMagic = GetMagicNumber(0);
   int maxMagic = GetMagicNumber(strategiesCount);
   int posTotal = OrdersTotal();
   int count    = 0;

   for (int posIndex = posTotal - 1; posIndex >= 0; posIndex--)
     {
      if ( OrderSelect(posIndex, SELECT_BY_POS, MODE_TRADES) &&
           OrderSymbol() == _Symbol &&
           OrderCloseTime()== 0 )
        {
         int magicNumber = OrderMagicNumber();
         if (magicNumber >= minMagic && magicNumber <= maxMagic)
            count++;
        }
     }

   return count;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Position CreatePosition(int magicNumber)
  {
   Position position;
   position.MagicNumber = magicNumber;
   position.Type        = OP_FLAT;
   position.Ticket      = 0;
   position.Lots        = 0;
   position.Price       = 0;
   position.StopLoss    = 0;
   position.TakeProfit  = 0;

   int total = OrdersTotal();
   for (int pos = total - 1; pos >= 0; pos--)
     {
      if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) &&
          OrderSymbol()      == _Symbol &&
          OrderMagicNumber() == magicNumber &&
          OrderCloseTime()   == 0)
        {
         position.Type       = OrderType();
         position.Lots       = OrderLots();
         position.Ticket     = OrderTicket();
         position.Price      = OrderOpenPrice();
         position.StopLoss   = OrderStopLoss();
         position.TakeProfit = OrderTakeProfit();
         break;
        }
     }

   return position;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal CreateEntrySignal(int strategyIndex, bool canOpenLong,   bool canOpenShort,
                         int stopLossPips,  int takeProfitPips, bool isTrailingStop,
                         bool oppositeReverse = false)
  {
   Signal signal;

   signal.MagicNumber     = GetMagicNumber(strategyIndex);
   signal.Scope           = ORDER_SCOPE_ENTRY;
   signal.StopLossPips    = stopLossPips;
   signal.TakeProfitPips  = takeProfitPips;
   signal.IsTrailingStop  = isTrailingStop;
   signal.OppositeReverse = oppositeReverse;
   signal.Direction       = canOpenLong && canOpenShort ? ORDER_DIRECTION_BOTH
                                         : canOpenLong  ? ORDER_DIRECTION_BUY
                                         : canOpenShort ? ORDER_DIRECTION_SELL
                                                        : ORDER_DIRECTION_NONE;

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal CreateExitSignal(int strategyIndex, bool canCloseLong,   bool canCloseShorts,
                        int stopLossPips,  int  takeProfitPips, bool isTrailingStop)
  {
   Signal signal;

   signal.MagicNumber     = GetMagicNumber(strategyIndex);
   signal.Scope           = ORDER_SCOPE_EXIT;
   signal.StopLossPips    = stopLossPips;
   signal.TakeProfitPips  = takeProfitPips;
   signal.IsTrailingStop  = isTrailingStop;
   signal.OppositeReverse = false;
   signal.Direction       = canCloseLong && canCloseShorts ? ORDER_DIRECTION_BOTH
                                          : canCloseLong   ? ORDER_DIRECTION_SELL
                                          : canCloseShorts ? ORDER_DIRECTION_BUY
                                                           : ORDER_DIRECTION_NONE;

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition(Signal &signal)
  {
   for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      int    ticket     = 0;
      int    lastError  = 0;
      bool   modified   = false;
      int    command    = OrderDirectionToCommand(signal.Direction);
      double amount     = Entry_Amount;
      int    magicNum   = signal.MagicNumber;
      string comment    = IntegerToString(magicNum);
      color  arrowColor = command == OP_BUY ? clrGreen : clrRed;

      if ( IsTradeContextFree() )
        {
         double price      = command == OP_BUY ? Ask() : Bid();
         double stopLoss   = GetStopLossPrice(command, signal.StopLossPips);
         double takeProfit = GetTakeProfitPrice(command, signal.TakeProfitPips);
         bool   isSLOrTP   = stopLoss > _Point || takeProfit > _Point;

         if (setProtectionSeparately)
           {
            // Send an entry order without SL and TP
            ticket = OrderSend(_Symbol, command, amount, price, 10, 0, 0, comment, magicNum, 0, arrowColor);

            // If the order is successful, modify the position with the corresponding SL and TP
            if (ticket > 0 && isSLOrTP)
               modified = OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrBlue);
           }
         else
           {
            // Send an entry order with SL and TP
            ticket    = OrderSend(_Symbol, command, amount, price, 10, stopLoss, takeProfit, comment, magicNum, 0, arrowColor);
            lastError = GetLastError();

            // If order fails, check if it is because inability to set SL or TP
            if (ticket <= 0 && lastError == 130)
              {
               // Send an entry order without SL and TP
               ticket = OrderSend(_Symbol, command, amount, price, 10, 0, 0, comment, magicNum, 0, arrowColor);

               // Try to set SL and TP
               if (ticket > 0 && isSLOrTP)
                  modified = OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrBlue);

               // Mark the expert to set SL and TP with a separate order
               if (ticket > 0 && modified)
                 {
                  setProtectionSeparately = true;
                  Print("Detected ECN type position protection.");
                 }
              }
           }
        }

      if (ticket > 0)
         break;

      lastError = GetLastError();

      if (lastError != 135 && lastError != 136 && lastError != 137 && lastError != 138)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Open Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(Position &position)
  {
   for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      bool closed    = 0;
      int  lastError = 0;

      if ( IsTradeContextFree() )
        {
         double price = position.Type == OP_BUY ? Bid() : Ask();
         closed    = OrderClose(position.Ticket, position.Lots, price, 10, clrYellow);
         lastError = GetLastError();
        }

      if (closed)
        {
         position.Type       = OP_FLAT;
         position.Lots       = 0;
         position.Price      = 0;
         position.StopLoss   = 0;
         position.TakeProfit = 0;
         break;
        }

      if (lastError == 4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Close Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyPosition(Position &position)
  {
   for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      bool modified  = 0;
      int  lastError = 0;

      if (IsTradeContextFree())
        {
         modified  = OrderModify(position.Ticket, 0, position.StopLoss, position.TakeProfit, 0, clrBlue);
         lastError = GetLastError();
        }

      if (modified)
        {
         position = CreatePosition(position.MagicNumber);
         break;
        }

      if (lastError == 4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Modify Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for (int i = 0; i < strategiesCount; i++)
     {
      Position position = CreatePosition( GetMagicNumber(i) );

      if (position.Type == OP_BUY || position.Type == OP_SELL)
         ClosePosition(position);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossPrice(int command, int stopLossPips)
  {
   if (stopLossPips == 0)
      return 0;

   double delta    = MathMax(pip * stopLossPips, _Point * stopLevel);
   double stopLoss = command == OP_BUY ? Bid() - delta : Ask() + delta;

   return NormalizeDouble(stopLoss, _Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTakeProfitPrice(int command, int takeProfitPips)
  {
   if (takeProfitPips == 0)
      return 0;

   double delta      = MathMax(pip * takeProfitPips, _Point * stopLevel);
   double takeProfit = command == OP_BUY ? Bid() + delta : Ask() - delta;

   return NormalizeDouble(takeProfit, _Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrailingStopPrice(Position &position, int stopLoss)
  {
   double bid = Bid();
   double ask = Ask();
   double stopLevelPoints = _Point * stopLevel;
   double stopLossPoints  = pip * stopLoss;

   if (position.Type == OP_BUY)
     {
      double stopLossPrice = High(1) - stopLossPoints;
      if (position.StopLoss < stopLossPrice - pip)
         return stopLossPrice < bid
                 ? stopLossPrice >= bid - stopLevelPoints
                    ? bid - stopLevelPoints
                    : stopLossPrice
                 : bid;
     }

   if (position.Type == OP_SELL)
     {
      double stopLossPrice = Low(1) + stopLossPoints;
      if (position.StopLoss > stopLossPrice + pip)
         return stopLossPrice > ask
                 ? stopLossPrice <= ask + stopLevelPoints
                    ? ask + stopLevelPoints
                    : stopLossPrice
                 : ask;
     }

   return position.StopLoss;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageTrailingStop(Position &position, double trailingStop)
  {
   if ( (position.Type == OP_BUY  && MathAbs(trailingStop - Bid()) < _Point) ||
        (position.Type == OP_SELL && MathAbs(trailingStop - Ask()) < _Point) )
     {
      ClosePosition(position);
      return;
     }

   if (MathAbs(trailingStop - position.StopLoss) > _Point)
     {
      position.StopLoss = NormalizeDouble(trailingStop, _Digits);
      ModifyPosition(position);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeContextFree()
  {
   if ( IsTradeAllowed() )
      return true;

   uint startWait = GetTickCount();
   Print("Trade context is busy! Waiting...");

   while (true)
     {
      if ( IsStopped() )
         return false;

      uint diff = GetTickCount() - startWait;
      if (diff > 30 * 1000)
        {
         Print("The waiting limit exceeded!");
         return false;
        }

      if ( IsTradeAllowed() )
        {
         RefreshRates();
         return true;
        }

      Sleep(TRADE_RETRY_WAIT);
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOutOfSession()
  {
   int dayOfWeek    = DayOfWeek();
   int periodStart  = int(Time(0) % 86400);
   int periodLength = PeriodSeconds(_Period);
   int periodFix    = periodStart + (sessionCloseAtSessionClose ? periodLength : 0);
   int friBarFix    = periodStart + (sessionCloseAtFridayClose || sessionCloseAtSessionClose ? periodLength : 0);

   return dayOfWeek == 0 && sessionIgnoreSunday ? true
        : dayOfWeek == 0 ? periodStart < sessionSundayOpen         || periodFix > sessionSundayClose
        : dayOfWeek  < 5 ? periodStart < sessionMondayThursdayOpen || periodFix > sessionMondayThursdayClose
                         : periodStart < sessionFridayOpen         || friBarFix > sessionFridayClose;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsForceSessionClose()
  {
   if (!sessionCloseAtFridayClose && !sessionCloseAtSessionClose)
      return false;

   int dayOfWeek = DayOfWeek();
   int periodEnd = int(Time(0) % 86400) + PeriodSeconds(_Period);

   return dayOfWeek == 0 && sessionCloseAtSessionClose ? periodEnd > sessionSundayClose
        : dayOfWeek  < 5 && sessionCloseAtSessionClose ? periodEnd > sessionMondayThursdayClose
        : dayOfWeek == 5 ? periodEnd > sessionFridayClose : false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bid()
  {
   return MarketInfo(_Symbol, MODE_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ask()
  {
   return MarketInfo(_Symbol, MODE_ASK);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(int bar)
  {
   return Time[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(int bar)
  {
   return Open[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double High(int bar)
  {
   return High[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Low(int bar)
  {
   return Low[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(int bar)
  {
   return Close[bar];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipValue()
  {
   return _Digits == 4 || _Digits == 5 ? 0.0001
        : _Digits == 2 || _Digits == 3 ? 0.01
                        : _Digits == 1 ? 0.1 : 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetMagicNumber(int strategyIndex)
  {
   return 1000 * Base_Magic_Number + strategyIndex;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderDirectionToCommand(OrderDirection dir)
  {
   return dir == ORDER_DIRECTION_BUY  ? OP_BUY
        : dir == ORDER_DIRECTION_SELL ? OP_SELL
                                      : OP_FLAT;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSignals(Signal &signalList[])
  {
   int i = 0;
   ArrayResize(signalList, 2 * strategiesCount);
   HideTestIndicators(true);

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Long or Short","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]},{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"RVI Signal","listIndexes":[2,0,0,0,0],"numValues":[48,0,0,0,0,0]},{"name":"MACD Signal","listIndexes":[2,3,0,0,0],"numValues":[20,33,8,0,0,0]}]} */
   signalList[i++] = GetExitSignal_00();
   signalList[i++] = GetEntrySignal_00();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]},{"name":"Long or Short","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]}],"closeFilters":[{"name":"RVI Signal","listIndexes":[1,0,0,0,0],"numValues":[41,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_01();
   signalList[i++] = GetEntrySignal_01();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[5,0,0,0,0,0]}],"closeFilters":[{"name":"Moving Average of Oscillator","listIndexes":[2,3,0,0,0],"numValues":[16,31,7,0,0,0]},{"name":"Awesome Oscillator","listIndexes":[4,0,0,0,0],"numValues":[0,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_02();
   signalList[i++] = GetEntrySignal_02();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"MACD Signal","listIndexes":[2,3,0,0,0],"numValues":[12,34,10,0,0,0]}]} */
   signalList[i++] = GetExitSignal_03();
   signalList[i++] = GetEntrySignal_03();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"Moving Average of Oscillator","listIndexes":[2,3,0,0,0],"numValues":[6,47,17,0,0,0]}]} */
   signalList[i++] = GetExitSignal_04();
   signalList[i++] = GetEntrySignal_04();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Standard Deviation","listIndexes":[2,3,0,0,0],"numValues":[30,0.01,0,0,0,0]},{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[13,0,0,0,0,0]}],"closeFilters":[{"name":"Alligator","listIndexes":[7,3,4,0,0],"numValues":[34,11,11,7,7,5]},{"name":"Commodity Channel Index","listIndexes":[4,5,0,0,0],"numValues":[44,77,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_05();
   signalList[i++] = GetEntrySignal_05();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[13,0,0,0,0,0]}],"closeFilters":[{"name":"Directional Indicators","listIndexes":[0,0,0,0,0],"numValues":[41,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_06();
   signalList[i++] = GetEntrySignal_06();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[14,0,0,0,0,0]}],"closeFilters":[{"name":"Average True Range","listIndexes":[6,0,0,0,0],"numValues":[49,0.01,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_07();
   signalList[i++] = GetEntrySignal_07();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[16,0,0,0,0,0]}],"closeFilters":[{"name":"Commodity Channel Index","listIndexes":[2,5,0,0,0],"numValues":[5,37,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_08();
   signalList[i++] = GetEntrySignal_08();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[11,0,0,0,0,0]}],"closeFilters":[{"name":"MACD Signal","listIndexes":[0,3,0,0,0],"numValues":[20,24,12,0,0,0]},{"name":"Money Flow Index","listIndexes":[4,0,0,0,0],"numValues":[44,77,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_09();
   signalList[i++] = GetEntrySignal_09();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[14,0,0,0,0,0]}],"closeFilters":[{"name":"Awesome Oscillator","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_010();
   signalList[i++] = GetEntrySignal_010();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"ADX","listIndexes":[5,0,0,0,0],"numValues":[6,35,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_011();
   signalList[i++] = GetEntrySignal_011();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[13,0,0,0,0,0]}],"closeFilters":[{"name":"Money Flow Index","listIndexes":[5,0,0,0,0],"numValues":[50,52,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_012();
   signalList[i++] = GetEntrySignal_012();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[11,0,0,0,0,0]}],"closeFilters":[{"name":"Stochastic Signal","listIndexes":[2,0,0,0,0],"numValues":[12,10,8,0,0,0]}]} */
   signalList[i++] = GetExitSignal_013();
   signalList[i++] = GetEntrySignal_013();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Awesome Oscillator","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]},{"name":"Moving Average","listIndexes":[2,0,3,0,0],"numValues":[49,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_014();
   signalList[i++] = GetEntrySignal_014();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Bears Power","listIndexes":[5,0,0,0,0],"numValues":[21,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_015();
   signalList[i++] = GetEntrySignal_015();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"DeMarker","listIndexes":[6,0,0,0,0],"numValues":[24,0,0,0,0,0]},{"name":"MACD","listIndexes":[0,3,0,0,0],"numValues":[19,39,9,0,0,0]}]} */
   signalList[i++] = GetExitSignal_016();
   signalList[i++] = GetEntrySignal_016();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Money Flow Index","listIndexes":[2,0,0,0,0],"numValues":[37,69,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_017();
   signalList[i++] = GetEntrySignal_017();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Standard Deviation","listIndexes":[5,3,0,0,0],"numValues":[25,2.12,0,0,0,0]},{"name":"Money Flow Index","listIndexes":[7,0,0,0,0],"numValues":[41,20,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_018();
   signalList[i++] = GetEntrySignal_018();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[12,0,0,0,0,0]}],"closeFilters":[{"name":"RVI","listIndexes":[7,0,0,0,0],"numValues":[45,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_019();
   signalList[i++] = GetEntrySignal_019();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Stochastic Signal","listIndexes":[1,0,0,0,0],"numValues":[13,6,8,0,0,0]},{"name":"Accelerator Oscillator","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_020();
   signalList[i++] = GetEntrySignal_020();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"Force Index","listIndexes":[5,0,0,0,0],"numValues":[19,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_021();
   signalList[i++] = GetEntrySignal_021();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Moving Average of Oscillator","listIndexes":[0,3,0,0,0],"numValues":[19,28,8,0,0,0]}]} */
   signalList[i++] = GetExitSignal_022();
   signalList[i++] = GetEntrySignal_022();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Directional Indicators","listIndexes":[2,0,0,0,0],"numValues":[31,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_023();
   signalList[i++] = GetEntrySignal_023();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"Bollinger Bands","listIndexes":[3,3,0,0,0],"numValues":[38,1.61,0,0,0,0]},{"name":"Moving Average","listIndexes":[6,0,3,0,0],"numValues":[37,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_024();
   signalList[i++] = GetEntrySignal_024();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Moving Average","listIndexes":[7,0,3,0,0],"numValues":[30,0,0,0,0,0]},{"name":"Momentum","listIndexes":[5,3,0,0,0],"numValues":[24,88.5793,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_025();
   signalList[i++] = GetEntrySignal_025();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[13,0,0,0,0,0]}],"closeFilters":[{"name":"Momentum","listIndexes":[3,3,0,0,0],"numValues":[43,23.49,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_026();
   signalList[i++] = GetEntrySignal_026();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Bollinger Bands","listIndexes":[3,3,0,0,0],"numValues":[15,1.33,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_027();
   signalList[i++] = GetEntrySignal_027();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"RVI Signal","listIndexes":[0,0,0,0,0],"numValues":[40,0,0,0,0,0]},{"name":"RVI Signal","listIndexes":[1,0,0,0,0],"numValues":[29,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_028();
   signalList[i++] = GetEntrySignal_028();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"Standard Deviation","listIndexes":[5,3,0,0,0],"numValues":[15,0.16,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_029();
   signalList[i++] = GetEntrySignal_029();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"Bulls Power","listIndexes":[2,0,0,0,0],"numValues":[11,0.0009,0,0,0,0]},{"name":"RVI Signal","listIndexes":[2,0,0,0,0],"numValues":[33,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_030();
   signalList[i++] = GetEntrySignal_030();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Alligator","listIndexes":[9,3,4,0,0],"numValues":[26,25,25,11,11,3]}]} */
   signalList[i++] = GetExitSignal_031();
   signalList[i++] = GetEntrySignal_031();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"Bulls Power","listIndexes":[2,0,0,0,0],"numValues":[11,0.0009,0,0,0,0]},{"name":"RVI Signal","listIndexes":[2,0,0,0,0],"numValues":[33,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_032();
   signalList[i++] = GetEntrySignal_032();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"Commodity Channel Index","listIndexes":[0,5,0,0,0],"numValues":[47,0,0,0,0,0]},{"name":"Directional Indicators","listIndexes":[2,0,0,0,0],"numValues":[41,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_033();
   signalList[i++] = GetEntrySignal_033();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Average True Range","listIndexes":[5,0,0,0,0],"numValues":[33,0.05,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_034();
   signalList[i++] = GetEntrySignal_034();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"DeMarker","listIndexes":[4,0,0,0,0],"numValues":[44,0.11,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_035();
   signalList[i++] = GetEntrySignal_035();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[13,0,0,0,0,0]}],"closeFilters":[{"name":"RVI","listIndexes":[5,0,0,0,0],"numValues":[12,0.1,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_036();
   signalList[i++] = GetEntrySignal_036();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"RVI Signal","listIndexes":[0,0,0,0,0],"numValues":[40,0,0,0,0,0]},{"name":"Awesome Oscillator","listIndexes":[5,0,0,0,0],"numValues":[-0.47,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_037();
   signalList[i++] = GetEntrySignal_037();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"RVI Signal","listIndexes":[0,0,0,0,0],"numValues":[40,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_038();
   signalList[i++] = GetEntrySignal_038();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"Directional Indicators","listIndexes":[2,0,0,0,0],"numValues":[20,0,0,0,0,0]},{"name":"Moving Average of Oscillator","listIndexes":[6,3,0,0,0],"numValues":[14,30,17,0,0,0]}]} */
   signalList[i++] = GetExitSignal_039();
   signalList[i++] = GetEntrySignal_039();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Bollinger Bands","listIndexes":[0,3,0,0,0],"numValues":[14,3.47,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_040();
   signalList[i++] = GetEntrySignal_040();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[11,0,0,0,0,0]}],"closeFilters":[{"name":"Bears Power","listIndexes":[7,0,0,0,0],"numValues":[13,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_041();
   signalList[i++] = GetEntrySignal_041();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"MACD Signal","listIndexes":[0,3,0,0,0],"numValues":[20,43,18,0,0,0]}]} */
   signalList[i++] = GetExitSignal_042();
   signalList[i++] = GetEntrySignal_042();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[14,0,0,0,0,0]}],"closeFilters":[{"name":"RSI","listIndexes":[3,3,0,0,0],"numValues":[30,4,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_043();
   signalList[i++] = GetEntrySignal_043();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"Average True Range","listIndexes":[5,0,0,0,0],"numValues":[6,1.48,0,0,0,0]},{"name":"Moving Average of Oscillator","listIndexes":[7,3,0,0,0],"numValues":[15,46,15,0,0,0]}]} */
   signalList[i++] = GetExitSignal_044();
   signalList[i++] = GetEntrySignal_044();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"RVI Signal","listIndexes":[1,0,0,0,0],"numValues":[37,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_045();
   signalList[i++] = GetEntrySignal_045();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[12,0,0,0,0,0]}],"closeFilters":[{"name":"Stochastic","listIndexes":[6,0,0,0,0],"numValues":[9,9,6,20,0,0]}]} */
   signalList[i++] = GetExitSignal_046();
   signalList[i++] = GetEntrySignal_046();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Accelerator Oscillator","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]},{"name":"Moving Averages Crossover","listIndexes":[0,0,0,0,0],"numValues":[8,41,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_047();
   signalList[i++] = GetEntrySignal_047();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[12,0,0,0,0,0]}],"closeFilters":[{"name":"Directional Indicators","listIndexes":[1,0,0,0,0],"numValues":[37,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_048();
   signalList[i++] = GetEntrySignal_048();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]},{"name":"ADX","listIndexes":[3,0,0,0,0],"numValues":[28,40,0,0,0,0]}],"closeFilters":[{"name":"Alligator","listIndexes":[9,3,4,0,0],"numValues":[26,25,25,11,11,3]},{"name":"Donchian Channel","listIndexes":[2,0,0,0,0],"numValues":[10,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_049();
   signalList[i++] = GetEntrySignal_049();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"MACD","listIndexes":[5,3,0,0,0],"numValues":[17,23,9,0,0,0]}]} */
   signalList[i++] = GetExitSignal_050();
   signalList[i++] = GetEntrySignal_050();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[13,0,0,0,0,0]}],"closeFilters":[{"name":"Money Flow Index","listIndexes":[4,0,0,0,0],"numValues":[42,36,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_051();
   signalList[i++] = GetEntrySignal_051();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"Momentum","listIndexes":[2,3,0,0,0],"numValues":[35,100.14,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_052();
   signalList[i++] = GetEntrySignal_052();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"MACD","listIndexes":[4,3,0,0,0],"numValues":[4,38,9,0,0,0]}]} */
   signalList[i++] = GetExitSignal_053();
   signalList[i++] = GetEntrySignal_053();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Stochastic","listIndexes":[4,0,0,0,0],"numValues":[13,11,13,18,0,0]},{"name":"Accelerator Oscillator","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_054();
   signalList[i++] = GetEntrySignal_054();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"Force Index","listIndexes":[5,0,0,0,0],"numValues":[19,0,0,0,0,0]},{"name":"Stochastic","listIndexes":[4,0,0,0,0],"numValues":[17,14,9,13,0,0]}]} */
   signalList[i++] = GetExitSignal_055();
   signalList[i++] = GetEntrySignal_055();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"Williams' Percent Range","listIndexes":[2,0,0,0,0],"numValues":[50,-8,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_056();
   signalList[i++] = GetEntrySignal_056();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"Standard Deviation","listIndexes":[7,3,0,0,0],"numValues":[27,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_057();
   signalList[i++] = GetEntrySignal_057();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[5,0,0,0,0,0]}],"closeFilters":[{"name":"Bollinger Bands","listIndexes":[1,3,0,0,0],"numValues":[16,3.89,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_058();
   signalList[i++] = GetEntrySignal_058();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[5,0,0,0,0,0]}],"closeFilters":[{"name":"Moving Average of Oscillator","listIndexes":[4,3,0,0,0],"numValues":[21,41,10,0,0,0]}]} */
   signalList[i++] = GetExitSignal_059();
   signalList[i++] = GetEntrySignal_059();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[8,0,0,0,0,0]}],"closeFilters":[{"name":"Stochastic","listIndexes":[4,0,0,0,0],"numValues":[17,14,9,13,0,0]}]} */
   signalList[i++] = GetExitSignal_060();
   signalList[i++] = GetEntrySignal_060();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[12,0,0,0,0,0]}],"closeFilters":[{"name":"Bulls Power","listIndexes":[4,0,0,0,0],"numValues":[44,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_061();
   signalList[i++] = GetEntrySignal_061();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"Momentum","listIndexes":[3,3,0,0,0],"numValues":[20,-51.89,0,0,0,0]},{"name":"Accelerator Oscillator","listIndexes":[5,0,0,0,0],"numValues":[0.2224,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_062();
   signalList[i++] = GetEntrySignal_062();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[11,0,0,0,0,0]}],"closeFilters":[{"name":"Moving Average of Oscillator","listIndexes":[3,3,0,0,0],"numValues":[5,30,14,-0.8169,0,0]},{"name":"Envelopes","listIndexes":[5,3,0,0,0],"numValues":[29,0.07,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_063();
   signalList[i++] = GetEntrySignal_063();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"RVI","listIndexes":[5,0,0,0,0],"numValues":[22,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_064();
   signalList[i++] = GetEntrySignal_064();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[12,0,0,0,0,0]}],"closeFilters":[{"name":"Bulls Power","listIndexes":[0,0,0,0,0],"numValues":[42,0,0,0,0,0]},{"name":"Force Index","listIndexes":[4,0,0,0,0],"numValues":[17,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_065();
   signalList[i++] = GetEntrySignal_065();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Moving Average","listIndexes":[2,0,3,0,0],"numValues":[45,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_066();
   signalList[i++] = GetEntrySignal_066();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"Alligator","listIndexes":[11,3,4,0,0],"numValues":[26,13,13,6,6,3]}]} */
   signalList[i++] = GetExitSignal_067();
   signalList[i++] = GetEntrySignal_067();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[12,0,0,0,0,0]}],"closeFilters":[{"name":"Donchian Channel","listIndexes":[0,0,0,0,0],"numValues":[17,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_068();
   signalList[i++] = GetEntrySignal_068();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[11,0,0,0,0,0]}],"closeFilters":[{"name":"Directional Indicators","listIndexes":[1,0,0,0,0],"numValues":[13,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_069();
   signalList[i++] = GetEntrySignal_069();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[12,0,0,0,0,0]}],"closeFilters":[{"name":"Money Flow Index","listIndexes":[2,0,0,0,0],"numValues":[35,51,0,0,0,0]},{"name":"Awesome Oscillator","listIndexes":[4,0,0,0,0],"numValues":[0,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_070();
   signalList[i++] = GetEntrySignal_070();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[14,0,0,0,0,0]},{"name":"Bollinger Bands","listIndexes":[1,3,0,0,0],"numValues":[27,1.14,0,0,0,0]}],"closeFilters":[{"name":"Directional Indicators","listIndexes":[0,0,0,0,0],"numValues":[29,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_071();
   signalList[i++] = GetEntrySignal_071();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[11,0,0,0,0,0]}],"closeFilters":[{"name":"Volumes","listIndexes":[4,0,0,0,0],"numValues":[441146,0,0,0,0,0]},{"name":"On Balance Volume","listIndexes":[0,0,0,0,0],"numValues":[0,0,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_072();
   signalList[i++] = GetEntrySignal_072();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[7,0,0,0,0,0]}],"closeFilters":[{"name":"Bulls Power","listIndexes":[4,0,0,0,0],"numValues":[50,0,0,0,0,0]},{"name":"Standard Deviation","listIndexes":[2,3,0,0,0],"numValues":[13,1.33,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_073();
   signalList[i++] = GetEntrySignal_073();

   /*STRATEGY CODE {"properties":{"entryLots":0.01,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":20,"takeProfit":20,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":true},"openFilters":[{"name":"Donchian Channel","listIndexes":[4,0,0,0,0],"numValues":[6,0,0,0,0,0]}],"closeFilters":[{"name":"Commodity Channel Index","listIndexes":[5,5,0,0,0],"numValues":[38,-200,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_074();
   signalList[i++] = GetEntrySignal_074();

   HideTestIndicators(false);
   if (i != 2 * strategiesCount)
      ArrayResize(signalList, i);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_00()
  {
   // Long or Short
   bool ind0long  = true;
   bool ind0short = false;
   // Donchian Channel (9)

   double ind1Up1 = DBL_MIN;
   double ind1Up2 = DBL_MIN;
   double ind1Dn1 = DBL_MAX;
   double ind1Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind1Up1) ind1Up1 = High(bar);
      if(Low(bar)  < ind1Dn1) ind1Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind1Up2) ind1Up2 = High(bar);
      if(Low(bar)  < ind1Dn2) ind1Dn2 = Low(bar);
     }

   double ind1upBand1 = ind1Up1;
   double ind1dnBand1 = ind1Dn1;
   double ind1upBand2 = ind1Up2;
   double ind1dnBand2 = ind1Dn2;
   bool   ind1long    = Open(0) < ind1dnBand1 - sigma && Open(1) > ind1dnBand2 + sigma;
   bool   ind1short   = Open(0) > ind1upBand1 + sigma && Open(1) < ind1upBand2 - sigma;

   return CreateEntrySignal(0, ind0long && ind1long, ind0short && ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_00()
  {
   // RVI Signal (48)
   double ind2val1  = iRVI(NULL, 0, 48, MODE_MAIN, 1) - iRVI(NULL, 0, 48, MODE_SIGNAL, 1);
   bool   ind2long  = ind2val1 > 0 + sigma;
   bool   ind2short = ind2val1 < 0 - sigma;
   // MACD Signal (Close, 20, 33, 8)
   double ind3val1  = iMACD(NULL, 0, 20, 33, 8, PRICE_CLOSE, MODE_MAIN, 1) - iMACD(NULL, 0, 20, 33, 8, PRICE_CLOSE ,MODE_SIGNAL, 1);
   bool   ind3long  = ind3val1 > 0 + sigma;
   bool   ind3short = ind3val1 < 0 - sigma;

   return CreateExitSignal(0, ind2long || ind3long, ind2short || ind3short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_01()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;
   // Long or Short
   bool ind1long  = true;
   bool ind1short = false;

   return CreateEntrySignal(1, ind0long && ind1long, ind0short && ind1short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_01()
  {
   // RVI Signal (41)
   double ind2val1  = iRVI(NULL, 0, 41, MODE_MAIN, 1) - iRVI(NULL, 0, 41, MODE_SIGNAL, 1);
   double ind2val2  = iRVI(NULL, 0, 41, MODE_MAIN, 2) - iRVI(NULL, 0, 41, MODE_SIGNAL, 2);
   bool   ind2long  = ind2val1 < 0 - sigma && ind2val2 > 0 + sigma;
   bool   ind2short = ind2val1 > 0 + sigma && ind2val2 < 0 - sigma;

   return CreateExitSignal(1, ind2long, ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_02()
  {
   // Donchian Channel (5)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 5 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 5 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(2, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_02()
  {
   // Moving Average of Oscillator (Close, 16, 31, 7), Level: 0.0000
   double ind1val1  = iOsMA(NULL, 0, 16, 31, 7, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 > 0.0000 + sigma;
   bool   ind1short = ind1val1 < 0.0000 - sigma;
   // Awesome Oscillator, Level: 0.0000
   double ind2val1  = iAO(NULL, 0, 1);
   double ind2val2  = iAO(NULL, 0, 2);
   bool   ind2long  = ind2val1 > 0.0000 + sigma && ind2val2 < 0.0000 - sigma;
   bool   ind2short = ind2val1 < 0.0000 - sigma && ind2val2 > 0.0000 + sigma;

   return CreateExitSignal(2, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_03()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(3, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_03()
  {
   // MACD Signal (Close, 12, 34, 10)
   double ind1val1  = iMACD(NULL, 0, 12, 34, 10, PRICE_CLOSE, MODE_MAIN, 1) - iMACD(NULL, 0, 12, 34, 10, PRICE_CLOSE ,MODE_SIGNAL, 1);
   bool   ind1long  = ind1val1 > 0 + sigma;
   bool   ind1short = ind1val1 < 0 - sigma;

   return CreateExitSignal(3, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_04()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(4, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_04()
  {
   // Moving Average of Oscillator (Close, 6, 47, 17), Level: 0.0000
   double ind1val1  = iOsMA(NULL, 0, 6, 47, 17, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 > 0.0000 + sigma;
   bool   ind1short = ind1val1 < 0.0000 - sigma;

   return CreateExitSignal(4, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_05()
  {
   // Standard Deviation (Close, Simple, 30), Level: 0.0100
   double ind0val1  = iStdDev(NULL , 0, 30, 0, MODE_SMA, PRICE_CLOSE, 1);
   bool   ind0long  = ind0val1 > 0.0100 + sigma;
   bool   ind0short = ind0long;
   // Donchian Channel (13)

   double ind1Up1 = DBL_MIN;
   double ind1Up2 = DBL_MIN;
   double ind1Dn1 = DBL_MAX;
   double ind1Dn2 = DBL_MAX;

   for(int bar = 1; bar < 13 + 1; bar++)
     {
      if(High(bar) > ind1Up1) ind1Up1 = High(bar);
      if(Low(bar)  < ind1Dn1) ind1Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 13 + 2; bar++)
     {
      if(High(bar) > ind1Up2) ind1Up2 = High(bar);
      if(Low(bar)  < ind1Dn2) ind1Dn2 = Low(bar);
     }

   double ind1upBand1 = ind1Up1;
   double ind1dnBand1 = ind1Dn1;
   double ind1upBand2 = ind1Up2;
   double ind1dnBand2 = ind1Dn2;
   bool   ind1long    = Open(0) < ind1dnBand1 - sigma && Open(1) > ind1dnBand2 + sigma;
   bool   ind1short   = Open(0) > ind1upBand1 + sigma && Open(1) < ind1upBand2 - sigma;

   return CreateEntrySignal(5, ind0long && ind1long, ind0short && ind1short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_05()
  {
   // Alligator (Smoothed, Median, 34, 11, 11, 7, 7, 5)
   double ind2val1  = iAlligator(NULL, 0, 34, 11, 11, 7, 7, 5, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS,  1);
   double ind2val2  = iAlligator(NULL, 0, 34, 11, 11, 7, 7, 5, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 1);
   double ind2val3  = iAlligator(NULL, 0, 34, 11, 11, 7, 7, 5, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS,  2);
   double ind2val4  = iAlligator(NULL, 0, 34, 11, 11, 7, 7, 5, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 2);
   bool   ind2long  = ind2val1 < ind2val2 - sigma && ind2val3 > ind2val4 + sigma;
   bool   ind2short = ind2val1 > ind2val2 + sigma && ind2val3 < ind2val4 - sigma;
   // Commodity Channel Index (Typical, 44), Level: 77
   double ind3val1  = iCCI(NULL, 0, 44, PRICE_TYPICAL, 1);
   double ind3val2  = iCCI(NULL, 0, 44, PRICE_TYPICAL, 2);
   bool   ind3long  = ind3val1 > 77 + sigma && ind3val2 < 77 - sigma;
   bool   ind3short = ind3val1 < -77 - sigma && ind3val2 > -77 + sigma;

   return CreateExitSignal(5, ind2long || ind3long, ind2short || ind3short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_06()
  {
   // Donchian Channel (13)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 13 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 13 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(6, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_06()
  {
   // Directional Indicators (41)
   double ind1val1  = iADX(NULL, 0, 41, PRICE_CLOSE, 1, 1) - iADX(NULL ,0 ,41, PRICE_CLOSE, 2, 1);
   double ind1val2  = iADX(NULL, 0, 41, PRICE_CLOSE, 1, 2) - iADX(NULL ,0 ,41, PRICE_CLOSE, 2, 2);
   bool   ind1long  = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   bool   ind1short = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;

   return CreateExitSignal(6, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_07()
  {
   // Donchian Channel (14)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 14 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 14 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(7, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_07()
  {
   // Average True Range (49)
   double ind1val1  = iATR(NULL, 0, 49, 1);
   double ind1val2  = iATR(NULL, 0, 49, 2);
   double ind1val3  = iATR(NULL, 0, 49, 3);
   bool   ind1long  = ind1val1 > ind1val2 + sigma && ind1val2 < ind1val3 - sigma;
   bool   ind1short = ind1long;

   return CreateExitSignal(7, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_08()
  {
   // Donchian Channel (16)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 16 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 16 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(8, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_08()
  {
   // Commodity Channel Index (Typical, 5), Level: 37
   double ind1val1  = iCCI(NULL, 0, 5, PRICE_TYPICAL, 1);
   bool   ind1long  = ind1val1 > 37 + sigma;
   bool   ind1short = ind1val1 < -37 - sigma;

   return CreateExitSignal(8, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_09()
  {
   // Donchian Channel (11)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 11 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 11 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(9, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_09()
  {
   // MACD Signal (Close, 20, 24, 12)
   double ind1val1  = iMACD(NULL, 0, 20, 24, 12, PRICE_CLOSE, MODE_MAIN, 1) - iMACD(NULL, 0, 20, 24, 12, PRICE_CLOSE ,MODE_SIGNAL, 1);
   double ind1val2  = iMACD(NULL, 0, 20, 24, 12, PRICE_CLOSE, MODE_MAIN, 2) - iMACD(NULL, 0, 20, 24, 12, PRICE_CLOSE ,MODE_SIGNAL, 2);
   bool   ind1long  = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   bool   ind1short = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   // Money Flow Index (44), Level: 77
   double ind2val1  = iMFI(NULL, 0, 44, 1);
   double ind2val2  = iMFI(NULL, 0, 44, 2);
   bool   ind2long  = ind2val1 > 77 + sigma && ind2val2 < 77 - sigma;
   bool   ind2short = ind2val1 < 100 - 77 - sigma && ind2val2 > 100 - 77 + sigma;

   return CreateExitSignal(9, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_010()
  {
   // Donchian Channel (14)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 14 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 14 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(10, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_010()
  {
   // Awesome Oscillator
   double ind1val1  = iAO(NULL, 0, 1);
   double ind1val2  = iAO(NULL, 0, 2);
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;

   return CreateExitSignal(10, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_011()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(11, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_011()
  {
   // ADX (6), Level: 35.0
   double ind1val1  = iADX(NULL, 0, 6, PRICE_CLOSE, 0, 1);
   double ind1val2  = iADX(NULL, 0, 6, PRICE_CLOSE, 0, 2);
   bool   ind1long  = ind1val1 < 35.0 - sigma && ind1val2 > 35.0 + sigma;
   bool   ind1short = ind1long;

   return CreateExitSignal(11, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_012()
  {
   // Donchian Channel (13)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 13 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 13 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(12, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_012()
  {
   // Money Flow Index (50), Level: 52
   double ind1val1  = iMFI(NULL, 0, 50, 1);
   double ind1val2  = iMFI(NULL, 0, 50, 2);
   bool   ind1long  = ind1val1 < 52 - sigma && ind1val2 > 52 + sigma;
   bool   ind1short = ind1val1 > 100 - 52 + sigma && ind1val2 < 100 - 52 - sigma;

   return CreateExitSignal(12, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_013()
  {
   // Donchian Channel (11)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 11 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 11 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(13, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_013()
  {
   // Stochastic Signal (12, 10, 8)
   double ind1val1  = iStochastic(NULL, 0, 12, 10, 8, MODE_SMA, 0, MODE_MAIN,   1);
   double ind1val2  = iStochastic(NULL, 0, 12, 10, 8, MODE_SMA, 0, MODE_SIGNAL, 1);
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;

   return CreateExitSignal(13, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_014()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(14, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_014()
  {
   // Awesome Oscillator
   double ind1val1  = iAO(NULL, 0, 1);
   double ind1val2  = iAO(NULL, 0, 2);
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;
   // Moving Average (Simple, Close, 49, 0)
   double ind2val1  = iMA(NULL, 0, 49, 0, MODE_SMA, PRICE_CLOSE, 1);
   bool   ind2long  = Open(0) > ind2val1 + sigma;
   bool   ind2short = Open(0) < ind2val1 - sigma;

   return CreateExitSignal(14, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_015()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(15, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_015()
  {
   // Bears Power (21), Level: 0.0000
   double ind1val1  = iBearsPower(NULL, 0, 21, PRICE_CLOSE, 1);
   double ind1val2  = iBearsPower(NULL, 0, 21, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 < 0.0000 - sigma && ind1val2 > 0.0000 + sigma;
   bool   ind1short = ind1val1 > 0.0000 + sigma && ind1val2 < 0.0000 - sigma;

   return CreateExitSignal(15, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_016()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(16, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_016()
  {
   // DeMarker (24)
   double ind1val1  = iDeMarker(NULL, 0, 24, 1);
   double ind1val2  = iDeMarker(NULL, 0, 24, 2);
   double ind1val3  = iDeMarker(NULL, 0, 24, 3);
   bool   ind1long  = ind1val1 > ind1val2 + sigma && ind1val2 < ind1val3 - sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma && ind1val2 > ind1val3 + sigma;
   // MACD (Close, 19, 39, 9)
   double ind2val1  = iMACD(NULL, 0, 19, 39, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double ind2val2  = iMACD(NULL, 0, 19, 39, 9, PRICE_CLOSE, MODE_MAIN, 2);
   bool   ind2long  = ind2val1 > ind2val2 + sigma;
   bool   ind2short = ind2val1 < ind2val2 - sigma;

   return CreateExitSignal(16, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_017()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(17, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_017()
  {
   // Money Flow Index (37), Level: 69
   double ind1val1  = iMFI(NULL, 0, 37, 1);
   bool   ind1long  = ind1val1 > 69 + sigma;
   bool   ind1short = ind1val1 < 100 - 69 - sigma;

   return CreateExitSignal(17, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_018()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(18, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_018()
  {
   // Standard Deviation (Close, Simple, 25), Level: 2.1200
   double ind1val1  = iStdDev(NULL , 0, 25, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ind1val2  = iStdDev(NULL , 0, 25, 0, MODE_SMA, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 < 2.1200 - sigma && ind1val2 > 2.1200 + sigma;
   bool   ind1short = ind1long;
   // Money Flow Index (41)
   double ind2val1  = iMFI(NULL, 0, 41, 1);
   double ind2val2  = iMFI(NULL, 0, 41, 2);
   double ind2val3  = iMFI(NULL, 0, 41, 3);
   bool   ind2long  = ind2val1 < ind2val2 - sigma && ind2val2 > ind2val3 + sigma;
   bool   ind2short = ind2val1 > ind2val2 + sigma && ind2val2 < ind2val3 - sigma;

   return CreateExitSignal(18, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_019()
  {
   // Donchian Channel (12)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 12 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 12 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(19, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_019()
  {
   // RVI (45)
   double ind1val1  = iRVI(NULL, 0, 45, MODE_MAIN, 1);
   double ind1val2  = iRVI(NULL, 0, 45, MODE_MAIN, 2);
   double ind1val3  = iRVI(NULL, 0, 45, MODE_MAIN, 3);
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val2 > ind1val3 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val2 < ind1val3 - sigma;

   return CreateExitSignal(19, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_020()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(20, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_020()
  {
   // Stochastic Signal (13, 6, 8)
   double ind1val1  = iStochastic(NULL, 0, 13, 6, 8, MODE_SMA, 0, MODE_MAIN,   1);
   double ind1val2  = iStochastic(NULL, 0, 13, 6, 8, MODE_SMA, 0, MODE_SIGNAL, 1);
   double ind1val3  = iStochastic(NULL, 0, 13, 6, 8, MODE_SMA, 0, MODE_MAIN,   2);
   double ind1val4  = iStochastic(NULL, 0, 13, 6, 8, MODE_SMA, 0, MODE_SIGNAL, 2);
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val3 > ind1val4 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val3 < ind1val4 - sigma;
   // Accelerator Oscillator
   double ind2val1  = iAC(NULL, 0, 1);
   double ind2val2  = iAC(NULL, 0, 2);
   bool   ind2long  = ind2val1 > ind2val2 + sigma;
   bool   ind2short = ind2val1 < ind2val2 - sigma;

   return CreateExitSignal(20, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_021()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(21, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_021()
  {
   // Force Index (Simple, 19)
   double ind1val1  = iForce(NULL, 0, 19, MODE_SMA, PRICE_CLOSE, 1);
   double ind1val2  = iForce(NULL, 0, 19, MODE_SMA, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   bool   ind1short = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;

   return CreateExitSignal(21, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_022()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(22, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_022()
  {
   // Moving Average of Oscillator (Close, 19, 28, 8)
   double ind1val1  = iOsMA(NULL, 0, 19, 28, 8, PRICE_CLOSE, 1);
   double ind1val2  = iOsMA(NULL, 0, 19, 28, 8, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;

   return CreateExitSignal(22, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_023()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(23, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_023()
  {
   // Directional Indicators (31)
   double ind1val1  = iADX(NULL, 0, 31, PRICE_CLOSE, 1, 1) - iADX(NULL ,0 ,31, PRICE_CLOSE, 2, 1);
   bool   ind1long  = ind1val1 > 0 + sigma;
   bool   ind1short = ind1val1 < 0 - sigma;

   return CreateExitSignal(23, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_024()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(24, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_024()
  {
   // Bollinger Bands (Close, 38, 1.61)
   double ind1upBand1 = iBands(NULL, 0, 38, 1.61, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ind1dnBand1 = iBands(NULL, 0, 38, 1.61, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double ind1upBand2 = iBands(NULL, 0, 38, 1.61, 0, PRICE_CLOSE, MODE_UPPER, 2);
   double ind1dnBand2 = iBands(NULL, 0, 38, 1.61, 0, PRICE_CLOSE, MODE_LOWER, 2);
   bool   ind1long    = Open(0) > ind1upBand1 + sigma && Open(1) < ind1upBand2 - sigma;
   bool   ind1short   = Open(0) < ind1dnBand1 - sigma && Open(1) > ind1dnBand2 + sigma;
   // Moving Average (Simple, Close, 37, 0)
   double ind2val1  = iMA(NULL, 0, 37, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ind2val2  = iMA(NULL, 0, 37, 0, MODE_SMA, PRICE_CLOSE, 2);
   double ind2val3  = iMA(NULL, 0, 37, 0, MODE_SMA, PRICE_CLOSE, 3);
   bool   ind2long  = ind2val1 > ind2val2 + sigma && ind2val2 < ind2val3 - sigma;
   bool   ind2short = ind2val1 < ind2val2 - sigma && ind2val2 > ind2val3 + sigma;

   return CreateExitSignal(24, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_025()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(25, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_025()
  {
   // Moving Average (Simple, Close, 30, 0)
   double ind1val1  = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ind1val2  = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, 2);
   double ind1val3  = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, 3);
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val2 > ind1val3 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val2 < ind1val3 - sigma;
   // Momentum (Close, 24), Level: 88.5793
   double ind2val1  = iMomentum(NULL, 0, 24, PRICE_CLOSE, 1);
   double ind2val2  = iMomentum(NULL, 0, 24, PRICE_CLOSE, 2);
   bool   ind2long  = ind2val1 < 88.5793 - sigma && ind2val2 > 88.5793 + sigma;
   bool   ind2short = ind2val1 > 200 - 88.5793 + sigma && ind2val2 < 200 - 88.5793 - sigma;

   return CreateExitSignal(25, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_026()
  {
   // Donchian Channel (13)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 13 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 13 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(26, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_026()
  {
   // Momentum (Close, 43), Level: 23.4900
   double ind1val1  = iMomentum(NULL, 0, 43, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 < 23.4900 - sigma;
   bool   ind1short = ind1val1 > 200 - 23.4900 + sigma;

   return CreateExitSignal(26, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_027()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(27, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_027()
  {
   // Bollinger Bands (Close, 15, 1.33)
   double ind1upBand1 = iBands(NULL, 0, 15, 1.33, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ind1dnBand1 = iBands(NULL, 0, 15, 1.33, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double ind1upBand2 = iBands(NULL, 0, 15, 1.33, 0, PRICE_CLOSE, MODE_UPPER, 2);
   double ind1dnBand2 = iBands(NULL, 0, 15, 1.33, 0, PRICE_CLOSE, MODE_LOWER, 2);
   bool   ind1long    = Open(0) > ind1upBand1 + sigma && Open(1) < ind1upBand2 - sigma;
   bool   ind1short   = Open(0) < ind1dnBand1 - sigma && Open(1) > ind1dnBand2 + sigma;

   return CreateExitSignal(27, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_028()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(28, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_028()
  {
   // RVI Signal (40)
   double ind1val1  = iRVI(NULL, 0, 40, MODE_MAIN, 1) - iRVI(NULL, 0, 40, MODE_SIGNAL, 1);
   double ind1val2  = iRVI(NULL, 0, 40, MODE_MAIN, 2) - iRVI(NULL, 0, 40, MODE_SIGNAL, 2);
   bool   ind1long  = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   bool   ind1short = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   // RVI Signal (29)
   double ind2val1  = iRVI(NULL, 0, 29, MODE_MAIN, 1) - iRVI(NULL, 0, 29, MODE_SIGNAL, 1);
   double ind2val2  = iRVI(NULL, 0, 29, MODE_MAIN, 2) - iRVI(NULL, 0, 29, MODE_SIGNAL, 2);
   bool   ind2long  = ind2val1 < 0 - sigma && ind2val2 > 0 + sigma;
   bool   ind2short = ind2val1 > 0 + sigma && ind2val2 < 0 - sigma;

   return CreateExitSignal(28, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_029()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(29, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_029()
  {
   // Standard Deviation (Close, Simple, 15), Level: 0.1600
   double ind1val1  = iStdDev(NULL , 0, 15, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ind1val2  = iStdDev(NULL , 0, 15, 0, MODE_SMA, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 < 0.1600 - sigma && ind1val2 > 0.1600 + sigma;
   bool   ind1short = ind1long;

   return CreateExitSignal(29, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_030()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(30, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_030()
  {
   // Bulls Power (11), Level: 0.0009
   double ind1val1  = iBullsPower(NULL, 0, 11, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 > 0.0009 + sigma;
   bool   ind1short = ind1val1 < -0.0009 - sigma;
   // RVI Signal (33)
   double ind2val1  = iRVI(NULL, 0, 33, MODE_MAIN, 1) - iRVI(NULL, 0, 33, MODE_SIGNAL, 1);
   bool   ind2long  = ind2val1 > 0 + sigma;
   bool   ind2short = ind2val1 < 0 - sigma;

   return CreateExitSignal(30, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_031()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(31, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_031()
  {
   // Alligator (Smoothed, Median, 26, 25, 25, 11, 11, 3)
   double ind1val1  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS,  1);
   double ind1val2  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW,   1);
   double ind1val3  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS,  2);
   double ind1val4  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW,   2);
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val3 > ind1val4 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val3 < ind1val4 - sigma;

   return CreateExitSignal(31, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_032()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(32, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_032()
  {
   // Bulls Power (11), Level: 0.0009
   double ind1val1  = iBullsPower(NULL, 0, 11, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 > 0.0009 + sigma;
   bool   ind1short = ind1val1 < -0.0009 - sigma;
   // RVI Signal (33)
   double ind2val1  = iRVI(NULL, 0, 33, MODE_MAIN, 1) - iRVI(NULL, 0, 33, MODE_SIGNAL, 1);
   bool   ind2long  = ind2val1 > 0 + sigma;
   bool   ind2short = ind2val1 < 0 - sigma;

   return CreateExitSignal(32, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_033()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(33, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_033()
  {
   // Commodity Channel Index (Typical, 47)
   double ind1val1  = iCCI(NULL, 0, 47, PRICE_TYPICAL, 1);
   double ind1val2  = iCCI(NULL, 0, 47, PRICE_TYPICAL, 2);
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;
   // Directional Indicators (41)
   double ind2val1  = iADX(NULL, 0, 41, PRICE_CLOSE, 1, 1) - iADX(NULL ,0 ,41, PRICE_CLOSE, 2, 1);
   bool   ind2long  = ind2val1 > 0 + sigma;
   bool   ind2short = ind2val1 < 0 - sigma;

   return CreateExitSignal(33, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_034()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(34, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_034()
  {
   // Average True Range (33), Level: 0.0500
   double ind1val1  = iATR(NULL, 0, 33, 1);
   double ind1val2  = iATR(NULL, 0, 33, 2);
   bool   ind1long  = ind1val1 < 0.0500 - sigma && ind1val2 > 0.0500 + sigma;
   bool   ind1short = ind1long;

   return CreateExitSignal(34, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_035()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(35, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_035()
  {
   // DeMarker (44), Level: 0.11
   double ind1val1  = iDeMarker(NULL, 0, 44, 1);
   double ind1val2  = iDeMarker(NULL, 0, 44, 2);
   bool   ind1long  = ind1val1 > 0.11 + sigma && ind1val2 < 0.11 - sigma;
   bool   ind1short = ind1val1 < 1 - 0.11 - sigma && ind1val2 > 1 - 0.11 + sigma;

   return CreateExitSignal(35, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_036()
  {
   // Donchian Channel (13)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 13 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 13 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(36, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_036()
  {
   // RVI (12), Level: 0.10
   double ind1val1  = iRVI(NULL, 0, 12, MODE_MAIN, 1);
   double ind1val2  = iRVI(NULL, 0, 12, MODE_MAIN, 2);
   bool   ind1long  = ind1val1 < 0.10 - sigma && ind1val2 > 0.10 + sigma;
   bool   ind1short = ind1val1 > -0.10 + sigma && ind1val2 < -0.10 - sigma;

   return CreateExitSignal(36, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_037()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(37, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_037()
  {
   // RVI Signal (40)
   double ind1val1  = iRVI(NULL, 0, 40, MODE_MAIN, 1) - iRVI(NULL, 0, 40, MODE_SIGNAL, 1);
   double ind1val2  = iRVI(NULL, 0, 40, MODE_MAIN, 2) - iRVI(NULL, 0, 40, MODE_SIGNAL, 2);
   bool   ind1long  = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   bool   ind1short = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   // Awesome Oscillator, Level: -0.4700
   double ind2val1  = iAO(NULL, 0, 1);
   double ind2val2  = iAO(NULL, 0, 2);
   bool   ind2long  = ind2val1 < -0.4700 - sigma && ind2val2 > -0.4700 + sigma;
   bool   ind2short = ind2val1 > 0.4700 + sigma && ind2val2 < 0.4700 - sigma;

   return CreateExitSignal(37, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_038()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(38, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_038()
  {
   // RVI Signal (40)
   double ind1val1  = iRVI(NULL, 0, 40, MODE_MAIN, 1) - iRVI(NULL, 0, 40, MODE_SIGNAL, 1);
   double ind1val2  = iRVI(NULL, 0, 40, MODE_MAIN, 2) - iRVI(NULL, 0, 40, MODE_SIGNAL, 2);
   bool   ind1long  = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   bool   ind1short = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;

   return CreateExitSignal(38, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_039()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(39, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_039()
  {
   // Directional Indicators (20)
   double ind1val1  = iADX(NULL, 0, 20, PRICE_CLOSE, 1, 1) - iADX(NULL ,0 ,20, PRICE_CLOSE, 2, 1);
   bool   ind1long  = ind1val1 > 0 + sigma;
   bool   ind1short = ind1val1 < 0 - sigma;
   // Moving Average of Oscillator (Close, 14, 30, 17)
   double ind2val1  = iOsMA(NULL, 0, 14, 30, 17, PRICE_CLOSE, 1);
   double ind2val2  = iOsMA(NULL, 0, 14, 30, 17, PRICE_CLOSE, 2);
   double ind2val3  = iOsMA(NULL, 0, 14, 30, 17, PRICE_CLOSE, 3);
   bool   ind2long  = ind2val1 > ind2val2 + sigma && ind2val2 < ind2val3 - sigma;
   bool   ind2short = ind2val1 < ind2val2 - sigma && ind2val2 > ind2val3 + sigma;

   return CreateExitSignal(39, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_040()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(40, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_040()
  {
   // Bollinger Bands (Close, 14, 3.47)
   double ind1upBand1 = iBands(NULL, 0, 14, 3.47, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ind1dnBand1 = iBands(NULL, 0, 14, 3.47, 0, PRICE_CLOSE, MODE_LOWER, 1);
   bool   ind1long  = Open(0) > ind1upBand1 + sigma;
   bool   ind1short = Open(0) < ind1dnBand1 - sigma;

   return CreateExitSignal(40, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_041()
  {
   // Donchian Channel (11)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 11 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 11 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(41, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_041()
  {
   // Bears Power (13)
   double ind1val1  = iBearsPower(NULL, 0, 13, PRICE_CLOSE, 1);
   double ind1val2  = iBearsPower(NULL, 0, 13, PRICE_CLOSE, 2);
   double ind1val3  = iBearsPower(NULL, 0, 13, PRICE_CLOSE, 3);
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val2 > ind1val3 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val2 < ind1val3 - sigma;

   return CreateExitSignal(41, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_042()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(42, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_042()
  {
   // MACD Signal (Close, 20, 43, 18)
   double ind1val1  = iMACD(NULL, 0, 20, 43, 18, PRICE_CLOSE, MODE_MAIN, 1) - iMACD(NULL, 0, 20, 43, 18, PRICE_CLOSE ,MODE_SIGNAL, 1);
   double ind1val2  = iMACD(NULL, 0, 20, 43, 18, PRICE_CLOSE, MODE_MAIN, 2) - iMACD(NULL, 0, 20, 43, 18, PRICE_CLOSE ,MODE_SIGNAL, 2);
   bool   ind1long  = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   bool   ind1short = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;

   return CreateExitSignal(42, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_043()
  {
   // Donchian Channel (14)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 14 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 14 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(43, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_043()
  {
   // RSI (Close, 30), Level: 4
   double ind1val1  = iRSI(NULL, 0, 30, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 < 4 - sigma;
   bool   ind1short = ind1val1 > 100 - 4 + sigma;

   return CreateExitSignal(43, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_044()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(44, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_044()
  {
   // Average True Range (6), Level: 1.4800
   double ind1val1  = iATR(NULL, 0, 6, 1);
   double ind1val2  = iATR(NULL, 0, 6, 2);
   bool   ind1long  = ind1val1 < 1.4800 - sigma && ind1val2 > 1.4800 + sigma;
   bool   ind1short = ind1long;
   // Moving Average of Oscillator (Close, 15, 46, 15)
   double ind2val1  = iOsMA(NULL, 0, 15, 46, 15, PRICE_CLOSE, 1);
   double ind2val2  = iOsMA(NULL, 0, 15, 46, 15, PRICE_CLOSE, 2);
   double ind2val3  = iOsMA(NULL, 0, 15, 46, 15, PRICE_CLOSE, 3);
   bool   ind2long  = ind2val1 < ind2val2 - sigma && ind2val2 > ind2val3 + sigma;
   bool   ind2short = ind2val1 > ind2val2 + sigma && ind2val2 < ind2val3 - sigma;

   return CreateExitSignal(44, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_045()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(45, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_045()
  {
   // RVI Signal (37)
   double ind1val1  = iRVI(NULL, 0, 37, MODE_MAIN, 1) - iRVI(NULL, 0, 37, MODE_SIGNAL, 1);
   double ind1val2  = iRVI(NULL, 0, 37, MODE_MAIN, 2) - iRVI(NULL, 0, 37, MODE_SIGNAL, 2);
   bool   ind1long  = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   bool   ind1short = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;

   return CreateExitSignal(45, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_046()
  {
   // Donchian Channel (12)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 12 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 12 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(46, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_046()
  {
   // Stochastic (9, 9, 6)
   double ind1val1  = iStochastic(NULL, 0, 9, 9, 6, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 1);
   double ind1val2  = iStochastic(NULL, 0, 9, 9, 6, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 2);
   double ind1val3  = iStochastic(NULL, 0, 9, 9, 6, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 3);
   bool   ind1long  = ind1val1 > ind1val2 + sigma && ind1val2 < ind1val3 - sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma && ind1val2 > ind1val3 + sigma;

   return CreateExitSignal(46, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_047()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(47, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_047()
  {
   // Accelerator Oscillator
   double ind1val1  = iAC(NULL, 0, 1);
   double ind1val2  = iAC(NULL, 0, 2);
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;
   // Moving Averages Crossover (Simple, Simple, 8, 41)
   double ind2val1  = iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ind2val2  = iMA(NULL, 0, 41, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ind2val3  = iMA(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE, 2);
   double ind2val4  = iMA(NULL, 0, 41, 0, MODE_SMA, PRICE_CLOSE, 2);
   bool   ind2long  = ind2val1 > ind2val2 + sigma && ind2val3 < ind2val4 - sigma;
   bool   ind2short = ind2val1 < ind2val2 - sigma && ind2val3 > ind2val4 + sigma;

   return CreateExitSignal(47, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_048()
  {
   // Donchian Channel (12)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 12 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 12 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(48, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_048()
  {
   // Directional Indicators (37)
   double ind1val1  = iADX(NULL, 0, 37, PRICE_CLOSE, 1, 1) - iADX(NULL ,0 ,37, PRICE_CLOSE, 2, 1);
   double ind1val2  = iADX(NULL, 0, 37, PRICE_CLOSE, 1, 2) - iADX(NULL ,0 ,37, PRICE_CLOSE, 2, 2);
   bool   ind1long  = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   bool   ind1short = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;

   return CreateExitSignal(48, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_049()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;
   // ADX (28), Level: 40.0
   double ind1val1  = iADX(NULL, 0, 28, PRICE_CLOSE, 0, 1);
   bool   ind1long  = ind1val1 < 40.0 - sigma;
   bool   ind1short = ind1long;

   return CreateEntrySignal(49, ind0long && ind1long, ind0short && ind1short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_049()
  {
   // Alligator (Smoothed, Median, 26, 25, 25, 11, 11, 3)
   double ind2val1  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS,  1);
   double ind2val2  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW,   1);
   double ind2val3  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS,  2);
   double ind2val4  = iAlligator(NULL, 0, 26, 25, 25, 11, 11, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW,   2);
   bool   ind2long  = ind2val1 < ind2val2 - sigma && ind2val3 > ind2val4 + sigma;
   bool   ind2short = ind2val1 > ind2val2 + sigma && ind2val3 < ind2val4 - sigma;
   // Donchian Channel (10)

   double ind3Up1 = DBL_MIN;
   double ind3Up2 = DBL_MIN;
   double ind3Dn1 = DBL_MAX;
   double ind3Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind3Up1) ind3Up1 = High(bar);
      if(Low(bar)  < ind3Dn1) ind3Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind3Up2) ind3Up2 = High(bar);
      if(Low(bar)  < ind3Dn2) ind3Dn2 = Low(bar);
     }

   double ind3upBand1 = ind3Up1;
   double ind3dnBand1 = ind3Dn1;
   double ind3upBand2 = ind3Up2;
   double ind3dnBand2 = ind3Dn2;
   bool   ind3long    = Open(0) < ind3upBand1 - sigma && Open(1) > ind3upBand2 + sigma;
   bool   ind3short   = Open(0) > ind3dnBand1 + sigma && Open(1) < ind3dnBand2 - sigma;

   return CreateExitSignal(49, ind2long || ind3long, ind2short || ind3short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_050()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(50, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_050()
  {
   // MACD (Close, 17, 23, 9)
   double ind1val1  = iMACD(NULL, 0, 17, 23, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double ind1val2  = iMACD(NULL, 0, 17, 23, 9, PRICE_CLOSE, MODE_MAIN, 2);
   bool   ind1long  = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   bool   ind1short = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;

   return CreateExitSignal(50, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_051()
  {
   // Donchian Channel (13)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 13 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 13 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(51, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_051()
  {
   // Money Flow Index (42), Level: 36
   double ind1val1  = iMFI(NULL, 0, 42, 1);
   double ind1val2  = iMFI(NULL, 0, 42, 2);
   bool   ind1long  = ind1val1 > 36 + sigma && ind1val2 < 36 - sigma;
   bool   ind1short = ind1val1 < 100 - 36 - sigma && ind1val2 > 100 - 36 + sigma;

   return CreateExitSignal(51, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_052()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(52, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_052()
  {
   // Momentum (Close, 35), Level: 100.1400
   double ind1val1  = iMomentum(NULL, 0, 35, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 > 100.1400 + sigma;
   bool   ind1short = ind1val1 < 200 - 100.1400 - sigma;

   return CreateExitSignal(52, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_053()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(53, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_053()
  {
   // MACD (Close, 4, 38, 9)
   double ind1val1  = iMACD(NULL, 0, 4, 38, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double ind1val2  = iMACD(NULL, 0, 4, 38, 9, PRICE_CLOSE, MODE_MAIN, 2);
   bool   ind1long  = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   bool   ind1short = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;

   return CreateExitSignal(53, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_054()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(54, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_054()
  {
   // Stochastic (13, 11, 13), Level: 18.0
   double ind1val1  = iStochastic(NULL, 0, 13, 11, 13, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 1);
   double ind1val2  = iStochastic(NULL, 0, 13, 11, 13, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 2);
   bool   ind1long  = ind1val1 > 18.0 + sigma && ind1val2 < 18.0 - sigma;
   bool   ind1short = ind1val1 < 100 - 18.0 - sigma && ind1val2 > 100 - 18.0 + sigma;
   // Accelerator Oscillator
   double ind2val1  = iAC(NULL, 0, 1);
   double ind2val2  = iAC(NULL, 0, 2);
   bool   ind2long  = ind2val1 > ind2val2 + sigma;
   bool   ind2short = ind2val1 < ind2val2 - sigma;

   return CreateExitSignal(54, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_055()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(55, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_055()
  {
   // Force Index (Simple, 19)
   double ind1val1  = iForce(NULL, 0, 19, MODE_SMA, PRICE_CLOSE, 1);
   double ind1val2  = iForce(NULL, 0, 19, MODE_SMA, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   bool   ind1short = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;
   // Stochastic (17, 14, 9), Level: 13.0
   double ind2val1  = iStochastic(NULL, 0, 17, 14, 9, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 1);
   double ind2val2  = iStochastic(NULL, 0, 17, 14, 9, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 2);
   bool   ind2long  = ind2val1 > 13.0 + sigma && ind2val2 < 13.0 - sigma;
   bool   ind2short = ind2val1 < 100 - 13.0 - sigma && ind2val2 > 100 - 13.0 + sigma;

   return CreateExitSignal(55, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_056()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(56, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_056()
  {
   // Williams' Percent Range (50), Level: -8.0
   double ind1val1  = iWPR(NULL, 0, 50, 1);
   bool   ind1long  = ind1val1 > -8.0 + sigma;
   bool   ind1short = ind1val1 < -100 - -8.0 - sigma;

   return CreateExitSignal(56, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_057()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(57, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_057()
  {
   // Standard Deviation (Close, Simple, 27)
   double ind1val1  = iStdDev(NULL , 0, 27, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ind1val2  = iStdDev(NULL , 0, 27, 0, MODE_SMA, PRICE_CLOSE, 2);
   double ind1val3  = iStdDev(NULL , 0, 27, 0, MODE_SMA, PRICE_CLOSE, 3);
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val2 > ind1val3 + sigma;
   bool   ind1short = ind1long;

   return CreateExitSignal(57, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_058()
  {
   // Donchian Channel (5)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 5 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 5 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(58, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_058()
  {
   // Bollinger Bands (Close, 16, 3.89)
   double ind1upBand1 = iBands(NULL, 0, 16, 3.89, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ind1dnBand1 = iBands(NULL, 0, 16, 3.89, 0, PRICE_CLOSE, MODE_LOWER, 1);
   bool   ind1long  = Open(0) < ind1dnBand1 - sigma;
   bool   ind1short = Open(0) > ind1upBand1 + sigma;

   return CreateExitSignal(58, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_059()
  {
   // Donchian Channel (5)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 5 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 5 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(59, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_059()
  {
   // Moving Average of Oscillator (Close, 21, 41, 10), Level: 0.0000
   double ind1val1  = iOsMA(NULL, 0, 21, 41, 10, PRICE_CLOSE, 1);
   double ind1val2  = iOsMA(NULL, 0, 21, 41, 10, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 > 0.0000 + sigma && ind1val2 < 0.0000 - sigma;
   bool   ind1short = ind1val1 < 0.0000 - sigma && ind1val2 > 0.0000 + sigma;

   return CreateExitSignal(59, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_060()
  {
   // Donchian Channel (8)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 8 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 8 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(60, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_060()
  {
   // Stochastic (17, 14, 9), Level: 13.0
   double ind1val1  = iStochastic(NULL, 0, 17, 14, 9, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 1);
   double ind1val2  = iStochastic(NULL, 0, 17, 14, 9, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 2);
   bool   ind1long  = ind1val1 > 13.0 + sigma && ind1val2 < 13.0 - sigma;
   bool   ind1short = ind1val1 < 100 - 13.0 - sigma && ind1val2 > 100 - 13.0 + sigma;

   return CreateExitSignal(60, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_061()
  {
   // Donchian Channel (12)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 12 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 12 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(61, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_061()
  {
   // Bulls Power (44), Level: 0.0000
   double ind1val1  = iBullsPower(NULL, 0, 44, PRICE_CLOSE, 1);
   double ind1val2  = iBullsPower(NULL, 0, 44, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 > 0.0000 + sigma && ind1val2 < 0.0000 - sigma;
   bool   ind1short = ind1val1 < 0.0000 - sigma && ind1val2 > 0.0000 + sigma;

   return CreateExitSignal(61, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_062()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(62, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_062()
  {
   // Momentum (Close, 20), Level: -51.8900
   double ind1val1  = iMomentum(NULL, 0, 20, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 < -51.8900 - sigma;
   bool   ind1short = ind1val1 > 200 - -51.8900 + sigma;
   // Accelerator Oscillator, Level: 0.2224
   double ind2val1  = iAC(NULL, 0, 1);
   double ind2val2  = iAC(NULL, 0, 2);
   bool   ind2long  = ind2val1 < 0.2224 - sigma && ind2val2 > 0.2224 + sigma;
   bool   ind2short = ind2val1 > -0.2224 + sigma && ind2val2 < -0.2224 - sigma;

   return CreateExitSignal(62, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_063()
  {
   // Donchian Channel (11)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 11 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 11 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(63, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_063()
  {
   // Moving Average of Oscillator (Close, 5, 30, 14), Level: -0.8169
   double ind1val1  = iOsMA(NULL, 0, 5, 30, 14, PRICE_CLOSE, 1);
   bool   ind1long  = ind1val1 < -0.8169 - sigma;
   bool   ind1short = ind1val1 > 0.8169 + sigma;
   // Envelopes (Close, Simple, 29, 0.07)
   double ind2upBand1 = iEnvelopes(NULL, 0, 29, MODE_SMA, 0, PRICE_CLOSE, 0.07, MODE_UPPER, 1);
   double ind2dnBand1 = iEnvelopes(NULL, 0, 29, MODE_SMA, 0, PRICE_CLOSE, 0.07, MODE_LOWER, 1);
   double ind2upBand2 = iEnvelopes(NULL, 0, 29, MODE_SMA, 0, PRICE_CLOSE, 0.07, MODE_UPPER, 2);
   double ind2dnBand2 = iEnvelopes(NULL, 0, 29, MODE_SMA, 0, PRICE_CLOSE, 0.07, MODE_LOWER, 2);
   bool   ind2long    = Open(0) > ind2dnBand1 + sigma && Open(1) < ind2dnBand2 - sigma;
   bool   ind2short   = Open(0) < ind2upBand1 - sigma && Open(1) > ind2upBand2 + sigma;

   return CreateExitSignal(63, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_064()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(64, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_064()
  {
   // RVI (22), Level: 0.00
   double ind1val1  = iRVI(NULL, 0, 22, MODE_MAIN, 1);
   double ind1val2  = iRVI(NULL, 0, 22, MODE_MAIN, 2);
   bool   ind1long  = ind1val1 < 0.00 - sigma && ind1val2 > 0.00 + sigma;
   bool   ind1short = ind1val1 > 0.00 + sigma && ind1val2 < 0.00 - sigma;

   return CreateExitSignal(64, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_065()
  {
   // Donchian Channel (12)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 12 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 12 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(65, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_065()
  {
   // Bulls Power (42)
   double ind1val1  = iBullsPower(NULL, 0, 42, PRICE_CLOSE, 1);
   double ind1val2  = iBullsPower(NULL, 0, 42, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;
   // Force Index (Simple, 17)
   double ind2val1  = iForce(NULL, 0, 17, MODE_SMA, PRICE_CLOSE, 1);
   double ind2val2  = iForce(NULL, 0, 17, MODE_SMA, PRICE_CLOSE, 2);
   bool   ind2long  = ind2val1 > 0 + sigma && ind2val2 < 0 - sigma;
   bool   ind2short = ind2val1 < 0 - sigma && ind2val2 > 0 + sigma;

   return CreateExitSignal(65, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_066()
  {
   // Donchian Channel (9)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 9 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 9 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(66, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_066()
  {
   // Moving Average (Simple, Close, 45, 0)
   double ind1val1  = iMA(NULL, 0, 45, 0, MODE_SMA, PRICE_CLOSE, 1);
   bool   ind1long  = Open(0) > ind1val1 + sigma;
   bool   ind1short = Open(0) < ind1val1 - sigma;

   return CreateExitSignal(66, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_067()
  {
   // Donchian Channel (10)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 10 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 10 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(67, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_067()
  {
   // Alligator (Smoothed, Median, 26, 13, 13, 6, 6, 3)
   double ind1val1  = iAlligator(NULL, 0, 26, 13, 13, 6, 6, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 1);
   double ind1val2  = iAlligator(NULL, 0, 26, 13, 13, 6, 6, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW,   1);
   double ind1val3  = iAlligator(NULL, 0, 26, 13, 13, 6, 6, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 2);
   double ind1val4  = iAlligator(NULL, 0, 26, 13, 13, 6, 6, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW,   2);
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val3 > ind1val4 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val3 < ind1val4 - sigma;

   return CreateExitSignal(67, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_068()
  {
   // Donchian Channel (12)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 12 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 12 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(68, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_068()
  {
   // Donchian Channel (17)

   double ind1Up1 = DBL_MIN;
   double ind1Up2 = DBL_MIN;
   double ind1Dn1 = DBL_MAX;
   double ind1Dn2 = DBL_MAX;

   for(int bar = 1; bar < 17 + 1; bar++)
     {
      if(High(bar) > ind1Up1) ind1Up1 = High(bar);
      if(Low(bar)  < ind1Dn1) ind1Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 17 + 2; bar++)
     {
      if(High(bar) > ind1Up2) ind1Up2 = High(bar);
      if(Low(bar)  < ind1Dn2) ind1Dn2 = Low(bar);
     }

   double ind1upBand1 = ind1Up1;
   double ind1dnBand1 = ind1Dn1;
   bool   ind1long  = Open(0) > ind1upBand1 + sigma;
   bool   ind1short = Open(0) < ind1dnBand1 - sigma;

   return CreateExitSignal(68, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_069()
  {
   // Donchian Channel (11)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 11 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 11 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(69, ind0long, ind0short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_069()
  {
   // Directional Indicators (13)
   double ind1val1  = iADX(NULL, 0, 13, PRICE_CLOSE, 1, 1) - iADX(NULL ,0 ,13, PRICE_CLOSE, 2, 1);
   double ind1val2  = iADX(NULL, 0, 13, PRICE_CLOSE, 1, 2) - iADX(NULL ,0 ,13, PRICE_CLOSE, 2, 2);
   bool   ind1long  = ind1val1 < 0 - sigma && ind1val2 > 0 + sigma;
   bool   ind1short = ind1val1 > 0 + sigma && ind1val2 < 0 - sigma;

   return CreateExitSignal(69, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_070()
  {
   // Donchian Channel (12)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 12 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 12 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(70, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_070()
  {
   // Money Flow Index (35), Level: 51
   double ind1val1  = iMFI(NULL, 0, 35, 1);
   bool   ind1long  = ind1val1 > 51 + sigma;
   bool   ind1short = ind1val1 < 100 - 51 - sigma;
   // Awesome Oscillator, Level: 0.0000
   double ind2val1  = iAO(NULL, 0, 1);
   double ind2val2  = iAO(NULL, 0, 2);
   bool   ind2long  = ind2val1 > 0.0000 + sigma && ind2val2 < 0.0000 - sigma;
   bool   ind2short = ind2val1 < 0.0000 - sigma && ind2val2 > 0.0000 + sigma;

   return CreateExitSignal(70, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_071()
  {
   // Donchian Channel (14)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 14 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 14 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;
   // Bollinger Bands (Close, 27, 1.14)
   double ind1upBand1 = iBands(NULL, 0, 27, 1.14, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double ind1dnBand1 = iBands(NULL, 0, 27, 1.14, 0, PRICE_CLOSE, MODE_LOWER, 1);
   bool   ind1long  = Open(0) < ind1dnBand1 - sigma;
   bool   ind1short = Open(0) > ind1upBand1 + sigma;

   return CreateEntrySignal(71, ind0long && ind1long, ind0short && ind1short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_071()
  {
   // Directional Indicators (29)
   double ind2val1  = iADX(NULL, 0, 29, PRICE_CLOSE, 1, 1) - iADX(NULL ,0 ,29, PRICE_CLOSE, 2, 1);
   double ind2val2  = iADX(NULL, 0, 29, PRICE_CLOSE, 1, 2) - iADX(NULL ,0 ,29, PRICE_CLOSE, 2, 2);
   bool   ind2long  = ind2val1 > 0 + sigma && ind2val2 < 0 - sigma;
   bool   ind2short = ind2val1 < 0 - sigma && ind2val2 > 0 + sigma;

   return CreateExitSignal(71, ind2long, ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_072()
  {
   // Donchian Channel (11)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 11 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 11 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(72, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_072()
  {
   // Volumes, Level: 441146
   double ind1val1  = (double) iVolume(NULL, 0, 1);
   double ind1val2  = (double) iVolume(NULL, 0, 2);
   bool   ind1long  = ind1val1 > 441146 + sigma && ind1val2 < 441146 - sigma;
   bool   ind1short = ind1long;
   // On Balance Volume
   double ind2val1  = iOBV(NULL, 0, PRICE_CLOSE, 1);
   double ind2val2  = iOBV(NULL, 0, PRICE_CLOSE, 2);
   bool   ind2long  = ind2val1 > ind2val2 + sigma;
   bool   ind2short = ind2val1 < ind2val2 - sigma;

   return CreateExitSignal(72, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_073()
  {
   // Donchian Channel (7)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 7 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 7 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(73, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_073()
  {
   // Bulls Power (50), Level: 0.0000
   double ind1val1  = iBullsPower(NULL, 0, 50, PRICE_CLOSE, 1);
   double ind1val2  = iBullsPower(NULL, 0, 50, PRICE_CLOSE, 2);
   bool   ind1long  = ind1val1 > 0.0000 + sigma && ind1val2 < 0.0000 - sigma;
   bool   ind1short = ind1val1 < 0.0000 - sigma && ind1val2 > 0.0000 + sigma;
   // Standard Deviation (Close, Simple, 13), Level: 1.3300
   double ind2val1  = iStdDev(NULL , 0, 13, 0, MODE_SMA, PRICE_CLOSE, 1);
   bool   ind2long  = ind2val1 > 1.3300 + sigma;
   bool   ind2short = ind2long;

   return CreateExitSignal(73, ind1long || ind2long, ind1short || ind2short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_074()
  {
   // Donchian Channel (6)

   double ind0Up1 = DBL_MIN;
   double ind0Up2 = DBL_MIN;
   double ind0Dn1 = DBL_MAX;
   double ind0Dn2 = DBL_MAX;

   for(int bar = 1; bar < 6 + 1; bar++)
     {
      if(High(bar) > ind0Up1) ind0Up1 = High(bar);
      if(Low(bar)  < ind0Dn1) ind0Dn1 = Low(bar);
     }
   for(int bar = 2; bar < 6 + 2; bar++)
     {
      if(High(bar) > ind0Up2) ind0Up2 = High(bar);
      if(Low(bar)  < ind0Dn2) ind0Dn2 = Low(bar);
     }

   double ind0upBand1 = ind0Up1;
   double ind0dnBand1 = ind0Dn1;
   double ind0upBand2 = ind0Up2;
   double ind0dnBand2 = ind0Dn2;
   bool   ind0long    = Open(0) < ind0dnBand1 - sigma && Open(1) > ind0dnBand2 + sigma;
   bool   ind0short   = Open(0) > ind0upBand1 + sigma && Open(1) < ind0upBand2 - sigma;

   return CreateEntrySignal(74, ind0long, ind0short, 20, 20, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_074()
  {
   // Commodity Channel Index (Typical, 38), Level: -200
   double ind1val1  = iCCI(NULL, 0, 38, PRICE_TYPICAL, 1);
   double ind1val2  = iCCI(NULL, 0, 38, PRICE_TYPICAL, 2);
   bool   ind1long  = ind1val1 < -200 - sigma && ind1val2 > -200 + sigma;
   bool   ind1short = ind1val1 > 200 + sigma && ind1val2 < 200 - sigma;

   return CreateExitSignal(74, ind1long, ind1short, 20, 20, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE ValidateInit()
  {
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
/*STRATEGY MARKET Premium Data; AUDJPY; M30 */
