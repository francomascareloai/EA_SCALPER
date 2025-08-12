//
// EA Studio Portfolio Expert Advisor
//
// Created with: Expert Advisor Studio
// Website: https://eatradingacademy.com/software/expert-advisor-studio/
//
// Copyright 2022, Forex Software Ltd.
//
// This Portfolio Expert works in MetaTrader 5 hedging accounts.
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
#property version   "3.4"
#property strict

static input double Entry_Amount       =    0.01; // Entry lots
static input int    Base_Magic_Number  =     100; // Base Magic Number

static input string ___Options_______  = "-----"; // --- Options ---
static input int    Max_Open_Positions =     100; // Max Open Positions

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  100
#define OP_FLAT           -1
#define OP_BUY            ORDER_TYPE_BUY
#define OP_SELL           ORDER_TYPE_SELL

// Session time is set in seconds from 00:00
const int sessionSundayOpen           =     0; // 00:00
const int sessionSundayClose          = 86400; // 24:00
const int sessionMondayThursdayOpen   =     0; // 00:00
const int sessionMondayThursdayClose  = 86400; // 24:00
const int sessionFridayOpen           =     0; // 00:00
const int sessionFridayClose          = 86400; // 24:00
const bool sessionIgnoreSunday        = false;
const bool sessionCloseAtSessionClose = false;
const bool sessionCloseAtFridayClose  = false;

const int    strategiesCount = 10;
const double sigma        = 0.000001;
const int    requiredBars = 88;

datetime barTime;
double   stopLevel;
double   pip;
bool     setProtectionSeparately = false;
ENUM_ORDER_TYPE_FILLING orderFillingType = ORDER_FILLING_FOK;
int indHandlers[100][12][2];

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
   ulong  Ticket;
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
   barTime   = Time(0);
   stopLevel = (int) SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   pip       = GetPipValue();

   InitIndicatorHandlers();

   return ValidateInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if ( IsForceSessionClose() )
     {
      CloseAllPositions();
      return;
     }

   datetime time = Time(0);
   if (time > barTime)
     {
      barTime = time;
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
      ManageSignal(signalList[i]);
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
         return;
        }

      if (signal.IsTrailingStop)
        {
         double trailingStop = GetTrailingStopPrice(position, signal.StopLossPips);
         ManageTrailingStop(position, trailingStop);
        }
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
   int posTotal = PositionsTotal();
   int count    = 0;

   for (int posIndex = 0; posIndex < posTotal; posIndex++)
     {
      ulong ticket = PositionGetTicket(posIndex);
      if ( PositionSelectByTicket(ticket) &&
           PositionGetString(POSITION_SYMBOL) == _Symbol )
        {
         long magicNumber = PositionGetInteger(POSITION_MAGIC);
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

   int posTotal = PositionsTotal();
   for (int posIndex = 0; posIndex < posTotal; posIndex++)
     {
      ulong ticket = PositionGetTicket(posIndex);
      if (PositionSelectByTicket(ticket) &&
          PositionGetString(POSITION_SYMBOL) == _Symbol &&
          PositionGetInteger(POSITION_MAGIC) == magicNumber)
        {
         position.Type       = (int) PositionGetInteger(POSITION_TYPE);
         position.Ticket     = ticket;
         position.Lots       = NormalizeDouble( PositionGetDouble(POSITION_VOLUME),           2);
         position.Price      = NormalizeDouble( PositionGetDouble(POSITION_PRICE_OPEN), _Digits);
         position.StopLoss   = NormalizeDouble( PositionGetDouble(POSITION_SL),         _Digits);
         position.TakeProfit = NormalizeDouble( PositionGetDouble(POSITION_TP),         _Digits);
         break;
        }
     }

   return position;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal CreateEntrySignal(int strategyIndex, bool canOpenLong,    bool canOpenShort,
                         int stopLossPips,  int  takeProfitPips, bool isTrailingStop,
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
   int    command    = OrderDirectionToCommand(signal.Direction);
   double stopLoss   = GetStopLossPrice(command,   signal.StopLossPips);
   double takeProfit = GetTakeProfitPrice(command, signal.TakeProfitPips);
   ManageOrderSend(command, Entry_Amount, stopLoss, takeProfit, 0, signal.MagicNumber);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(Position &position)
  {
   int command = position.Type == OP_BUY ? OP_SELL : OP_BUY;
   ManageOrderSend(command, position.Lots, 0, 0, position.Ticket, position.MagicNumber);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for (int i = 0; i < strategiesCount; i++)
     {
      int magicNumber = GetMagicNumber(i);
      Position position = CreatePosition(magicNumber);

      if (position.Type == OP_BUY || position.Type == OP_SELL)
         ClosePosition(position);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageOrderSend(int command, double lots, double stopLoss, double takeProfit, ulong ticket, int magicNumber)
  {
   for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      if ( IsTradeContextFree() )
        {
         MqlTradeRequest request;
         MqlTradeResult  result;
         ZeroMemory(request);
         ZeroMemory(result);

         request.action       = TRADE_ACTION_DEAL;
         request.symbol       = _Symbol;
         request.volume       = lots;
         request.type         = command == OP_BUY ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         request.price        = command == OP_BUY ? Ask() : Bid();
         request.type_filling = orderFillingType;
         request.deviation    = 10;
         request.sl           = stopLoss;
         request.tp           = takeProfit;
         request.magic        = magicNumber;
         request.position     = ticket;
         request.comment      = IntegerToString(magicNumber);

         bool isOrderCheck = CheckOrder(request);
         bool isOrderSend  = false;

         if (isOrderCheck)
           {
            ResetLastError();
            isOrderSend = OrderSend(request, result);
           }

         if (isOrderCheck && isOrderSend && result.retcode == TRADE_RETCODE_DONE)
            return;
        }

      Sleep(TRADE_RETRY_WAIT);
      Print("Order Send retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyPosition(double stopLoss, double takeProfit, ulong ticket, int magicNumber)
  {
   for (int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      if ( IsTradeContextFree() )
        {
         MqlTradeRequest request;
         MqlTradeResult  result;
         ZeroMemory(request);
         ZeroMemory(result);

         request.action   = TRADE_ACTION_SLTP;
         request.symbol   = _Symbol;
         request.sl       = stopLoss;
         request.tp       = takeProfit;
         request.magic    = magicNumber;
         request.position = ticket;
         request.comment  = IntegerToString(magicNumber);

         bool isOrderCheck = CheckOrder(request);
         bool isOrderSend  = false;

         if (isOrderCheck)
           {
            ResetLastError();
            isOrderSend = OrderSend(request, result);
           }

         if (isOrderCheck && isOrderSend && result.retcode == TRADE_RETCODE_DONE)
            return;
        }

      Sleep(TRADE_RETRY_WAIT);
      Print("Order Send retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckOrder(MqlTradeRequest &request)
  {
   MqlTradeCheckResult check;
   ZeroMemory(check);
   ResetLastError();

   if ( OrderCheck(request, check) )
      return true;

   Print("Error with OrderCheck: " + check.comment);

   if (check.retcode == TRADE_RETCODE_INVALID_FILL)
     {
      switch (orderFillingType)
        {
         case ORDER_FILLING_FOK:
            Print("Filling mode changed to: ORDER_FILLING_IOC");
            orderFillingType = ORDER_FILLING_IOC;
            break;
         case ORDER_FILLING_IOC:
            Print("Filling mode changed to: ORDER_FILLING_RETURN");
            orderFillingType = ORDER_FILLING_RETURN;
            break;
         case ORDER_FILLING_RETURN:
            Print("Filling mode changed to: ORDER_FILLING_FOK");
            orderFillingType = ORDER_FILLING_FOK;
            break;
        }

      request.type_filling = orderFillingType;

      return CheckOrder(request);
     }

   return false;
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
   double spread = ask - bid;
   double stopLevelPoints = _Point * stopLevel;
   double stopLossPoints  = pip * stopLoss;

   if (position.Type == OP_BUY)
     {
      double newStopLoss = High(1) - stopLossPoints;
      if (position.StopLoss <= newStopLoss - pip)
         return newStopLoss < bid
                  ? newStopLoss >= bid - stopLevelPoints
                     ? bid - stopLevelPoints
                     : newStopLoss
                  : bid;
     }

   if (position.Type == OP_SELL)
     {
      double newStopLoss = Low(1) + spread + stopLossPoints;
      if (position.StopLoss >= newStopLoss + pip)
         return newStopLoss > ask
                  ? newStopLoss <= ask + stopLevelPoints
                     ? ask + stopLevelPoints
                     : newStopLoss
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

   if ( MathAbs(trailingStop - position.StopLoss) > _Point )
     {
      position.StopLoss = NormalizeDouble(trailingStop, _Digits);
      ModifyPosition(position.StopLoss, position.TakeProfit, position.Ticket, position.MagicNumber);
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
   return SymbolInfoDouble(_Symbol, SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ask()
  {
   return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(int bar)
  {
   datetime buffer[];
   ArrayResize(buffer, 1);
   return CopyTime(_Symbol, _Period, bar, 1, buffer) == 1 ? buffer[0] : 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(int bar)
  {
   double buffer[];
   ArrayResize(buffer, 1);
   return CopyOpen(_Symbol, _Period, bar, 1, buffer) == 1 ? buffer[0] : 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double High(int bar)
  {
   double buffer[];
   ArrayResize(buffer, 1);
   return CopyHigh(_Symbol, _Period, bar, 1, buffer) == 1 ? buffer[0] : 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Low(int bar)
  {
   double buffer[];
   ArrayResize(buffer, 1);
   return CopyLow(_Symbol, _Period, bar, 1, buffer) == 1 ? buffer[0] : 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(int bar)
  {
   double buffer[];
   ArrayResize(buffer, 1);
   return CopyClose(_Symbol, _Period, bar, 1, buffer) == 1 ? buffer[0] : 0;
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
bool IsTradeAllowed()
  {
   return (bool) MQL5InfoInteger(MQL5_TRADE_ALLOWED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RefreshRates()
  {
   // Dummy function to make it compatible with MQL4
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DayOfWeek()
  {
   MqlDateTime mqlTime;
   TimeToStruct(Time(0), mqlTime);
   return mqlTime.day_of_week;
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
ENUM_INIT_RETCODE ValidateInit()
  {
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitIndicatorHandlers()
  {
   TesterHideIndicators(true);
   // Directional Indicators (9)
   indHandlers[0][0][0] = iADX(NULL, 0, 9);
   // Williams' Percent Range (8)
   indHandlers[0][1][0] = iWPR(NULL, 0, 8);
   // ADX (10)
   indHandlers[0][2][0] = iADX(NULL, 0, 10);
   // Envelopes (Close, Simple, 25, 0.88)
   indHandlers[0][3][0] = iEnvelopes(NULL, 0, 25, 0, MODE_SMA, PRICE_CLOSE, 0.88);
   // Williams' Percent Range (7), Level: -37.0
   indHandlers[1][0][0] = iWPR(NULL, 0, 7);
   // DeMarker (18), Level: 0.45
   indHandlers[1][1][0] = iDeMarker(NULL, 0, 18);
   // Standard Deviation (Close, Simple, 35), Level: 0.0045
   indHandlers[1][2][0] = iStdDev(NULL, 0, 35, 0, MODE_SMA, PRICE_CLOSE);
   // Williams' Percent Range (40)
   indHandlers[1][3][0] = iWPR(NULL, 0, 40);
   // RSI (Close, 24), Level: 87
   indHandlers[1][4][0] = iRSI(NULL, 0, 24, PRICE_CLOSE);
   // Awesome Oscillator, Level: 0.0000
   indHandlers[2][0][0] = iAO(NULL, 0);
   // Awesome Oscillator, Level: 0.0000
   indHandlers[2][1][0] = iAO(NULL, 0);
   // Accelerator Oscillator
   indHandlers[2][2][0] = iAC(NULL, 0);
   // Bollinger Bands (Close, 25, 2.51)
   indHandlers[2][3][0] = iBands(NULL, 0, 25, 0, 2.51, PRICE_CLOSE);
   // Stochastic Signal (4, 1, 1)
   indHandlers[2][4][0] = iStochastic(NULL, 0, 4, 1, 1, MODE_SMA, STO_LOWHIGH);
   // Average True Range (17)
   indHandlers[3][0][0] = iATR(NULL, 0, 17);
   // Alligator (Smoothed, Median, 43, 29, 29, 14, 14, 4)
   indHandlers[3][1][0] = iAlligator(NULL, 0, 43, 29, 29, 14, 14, 4, MODE_SMMA, PRICE_MEDIAN);
   // Standard Deviation (Close, Simple, 26), Level: 0.0052
   indHandlers[3][2][0] = iStdDev(NULL, 0, 26, 0, MODE_SMA, PRICE_CLOSE);
   // Awesome Oscillator, Level: 0.0000
   indHandlers[4][0][0] = iAO(NULL, 0);
   // Directional Indicators (37)
   indHandlers[4][1][0] = iADX(NULL, 0, 37);
   // Envelopes (Close, Simple, 23, 0.66)
   indHandlers[4][2][0] = iEnvelopes(NULL, 0, 23, 0, MODE_SMA, PRICE_CLOSE, 0.66);
   // Stochastic (17, 17, 15), Level: 20.0
   indHandlers[5][0][0] = iStochastic(NULL, 0, 17, 17, 15, MODE_SMA, 0);
   // RSI (Close, 39), Level: 44
   indHandlers[5][1][0] = iRSI(NULL, 0, 39, PRICE_CLOSE);
   // Williams' Percent Range (39)
   indHandlers[5][2][0] = iWPR(NULL, 0, 39);
   // Williams' Percent Range (24)
   indHandlers[5][3][0] = iWPR(NULL, 0, 24);
   // ADX (43), Level: 38.0
   indHandlers[5][4][0] = iADX(NULL, 0, 43);
   // Williams' Percent Range (25), Level: -80.0
   indHandlers[6][0][0] = iWPR(NULL, 0, 25);
   // ADX (38), Level: 21.0
   indHandlers[6][1][0] = iADX(NULL, 0, 38);
   // Bollinger Bands (Close, 17, 2.49)
   indHandlers[6][2][0] = iBands(NULL, 0, 17, 0, 2.49, PRICE_CLOSE);
   // Standard Deviation (Close, Simple, 8), Level: 0.0032
   indHandlers[6][3][0] = iStdDev(NULL, 0, 8, 0, MODE_SMA, PRICE_CLOSE);
   // RSI (Close, 31), Level: 32
   indHandlers[6][4][0] = iRSI(NULL, 0, 31, PRICE_CLOSE);
   // Alligator (Smoothed, Median, 20, 4, 4, 3, 3, 2)
   indHandlers[7][0][0] = iAlligator(NULL, 0, 20, 4, 4, 3, 3, 2, MODE_SMMA, PRICE_MEDIAN);
   // Directional Indicators (23)
   indHandlers[7][1][0] = iADX(NULL, 0, 23);
   // Stochastic Signal (7, 2, 1)
   indHandlers[7][2][0] = iStochastic(NULL, 0, 7, 2, 1, MODE_SMA, STO_LOWHIGH);
   // Envelopes (Close, Simple, 23, 0.16)
   indHandlers[7][3][0] = iEnvelopes(NULL, 0, 23, 0, MODE_SMA, PRICE_CLOSE, 0.16);
   // Commodity Channel Index (Typical, 37), Level: 0
   indHandlers[8][0][0] = iCCI(NULL, 0, 37, PRICE_TYPICAL);
   // Moving Average (Simple, Close, 9, 0)
   indHandlers[8][1][0] = iMA(NULL, 0, 9, 0, MODE_SMA, PRICE_CLOSE);
   // Envelopes (Close, Simple, 37, 0.64)
   indHandlers[8][2][0] = iEnvelopes(NULL, 0, 37, 0, MODE_SMA, PRICE_CLOSE, 0.64);
   // Alligator (Smoothed, Median, 30, 18, 18, 6, 6, 5)
   indHandlers[9][0][0] = iAlligator(NULL, 0, 30, 18, 18, 6, 6, 5, MODE_SMMA, PRICE_MEDIAN);
   // Moving Averages Crossover (Simple, Simple, 4, 23)
   indHandlers[9][1][0] = iMA(NULL, 0, 4, 0, MODE_SMA, PRICE_CLOSE);
   // Moving Averages Crossover (Simple, Simple, 4, 23)
   indHandlers[9][1][1] = iMA(NULL, 0, 23, 0, MODE_SMA, PRICE_CLOSE);
   // Bollinger Bands (Close, 10, 3.95)
   indHandlers[9][2][0] = iBands(NULL, 0, 10, 0, 3.95, PRICE_CLOSE);
   TesterHideIndicators(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSignals(Signal &signalList[])
  {
   int i = 0;
   ArrayResize(signalList, 2 * strategiesCount);

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":0,"stopLoss":37,"takeProfit":46,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Directional Indicators","listIndexes":[0,0,0,0,0],"numValues":[9,0,0,0,0,0]},{"name":"Williams' Percent Range","listIndexes":[0,0,0,0,0],"numValues":[8,-20,0,0,0,0]},{"name":"ADX","listIndexes":[7,0,0,0,0],"numValues":[10,0,0,0,0,0]}],"closeFilters":[{"name":"Envelopes","listIndexes":[2,3,0,0,0],"numValues":[25,0.88,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_00();
   signalList[i++] = GetEntrySignal_00();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":74,"takeProfit":56,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Williams' Percent Range","listIndexes":[4,0,0,0,0],"numValues":[7,-37,0,0,0,0]},{"name":"DeMarker","listIndexes":[3,0,0,0,0],"numValues":[18,0.45,0,0,0,0]},{"name":"Standard Deviation","listIndexes":[3,3,0,0,0],"numValues":[35,0.0045,0,0,0,0]},{"name":"Williams' Percent Range","listIndexes":[1,0,0,0,0],"numValues":[40,-20,0,0,0,0]}],"closeFilters":[{"name":"RSI","listIndexes":[2,3,0,0,0],"numValues":[24,87,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_01();
   signalList[i++] = GetEntrySignal_01();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":100,"takeProfit":68,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Awesome Oscillator","listIndexes":[5,0,0,0,0],"numValues":[0,0,0,0,0,0]},{"name":"Awesome Oscillator","listIndexes":[5,0,0,0,0],"numValues":[0,0,0,0,0,0]},{"name":"Accelerator Oscillator","listIndexes":[1,0,0,0,0],"numValues":[0,0,0,0,0,0]},{"name":"Bollinger Bands","listIndexes":[4,3,0,0,0],"numValues":[25,2.51,0,0,0,0]}],"closeFilters":[{"name":"Stochastic Signal","listIndexes":[0,0,0,0,0],"numValues":[4,1,1,0,0,0]}]} */
   signalList[i++] = GetExitSignal_02();
   signalList[i++] = GetEntrySignal_02();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":19,"takeProfit":90,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Average True Range","listIndexes":[6,0,0,0,0],"numValues":[17,0.01,0,0,0,0]},{"name":"Alligator","listIndexes":[9,3,4,0,0],"numValues":[43,29,29,14,14,4]}],"closeFilters":[{"name":"Standard Deviation","listIndexes":[4,3,0,0,0],"numValues":[26,0.0052,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_03();
   signalList[i++] = GetEntrySignal_03();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":48,"takeProfit":93,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Awesome Oscillator","listIndexes":[4,0,0,0,0],"numValues":[0,0,0,0,0,0]},{"name":"Directional Indicators","listIndexes":[1,0,0,0,0],"numValues":[37,0,0,0,0,0]}],"closeFilters":[{"name":"Envelopes","listIndexes":[5,3,0,0,0],"numValues":[23,0.66,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_04();
   signalList[i++] = GetEntrySignal_04();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":60,"takeProfit":90,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Stochastic","listIndexes":[5,0,0,0,0],"numValues":[17,17,15,20,0,0]},{"name":"RSI","listIndexes":[3,3,0,0,0],"numValues":[39,44,0,0,0,0]},{"name":"Williams' Percent Range","listIndexes":[7,0,0,0,0],"numValues":[39,-20,0,0,0,0]},{"name":"Williams' Percent Range","listIndexes":[1,0,0,0,0],"numValues":[24,-20,0,0,0,0]}],"closeFilters":[{"name":"ADX","listIndexes":[5,0,0,0,0],"numValues":[43,38,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_05();
   signalList[i++] = GetEntrySignal_05();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":37,"takeProfit":39,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Williams' Percent Range","listIndexes":[5,0,0,0,0],"numValues":[25,-80,0,0,0,0]},{"name":"ADX","listIndexes":[2,0,0,0,0],"numValues":[38,21,0,0,0,0]},{"name":"Bollinger Bands","listIndexes":[4,3,0,0,0],"numValues":[17,2.49,0,0,0,0]},{"name":"Standard Deviation","listIndexes":[3,3,0,0,0],"numValues":[8,0.0032,0,0,0,0]}],"closeFilters":[{"name":"RSI","listIndexes":[5,3,0,0,0],"numValues":[31,32,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_06();
   signalList[i++] = GetEntrySignal_06();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":46,"takeProfit":96,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Alligator","listIndexes":[6,3,4,0,0],"numValues":[20,4,4,3,3,2]},{"name":"Directional Indicators","listIndexes":[0,0,0,0,0],"numValues":[23,0,0,0,0,0]},{"name":"Stochastic Signal","listIndexes":[3,0,0,0,0],"numValues":[7,2,1,0,0,0]}],"closeFilters":[{"name":"Envelopes","listIndexes":[1,3,0,0,0],"numValues":[23,0.16,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_07();
   signalList[i++] = GetEntrySignal_07();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":34,"takeProfit":71,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Commodity Channel Index","listIndexes":[5,5,0,0,0],"numValues":[37,0,0,0,0,0]},{"name":"Moving Average","listIndexes":[6,0,3,0,0],"numValues":[9,0,0,0,0,0]}],"closeFilters":[{"name":"Envelopes","listIndexes":[3,3,0,0,0],"numValues":[37,0.64,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_08();
   signalList[i++] = GetEntrySignal_08();

   /*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":98,"takeProfit":65,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Alligator","listIndexes":[10,3,4,0,0],"numValues":[30,18,18,6,6,5]},{"name":"Moving Averages Crossover","listIndexes":[3,0,0,0,0],"numValues":[4,23,0,0,0,0]}],"closeFilters":[{"name":"Bollinger Bands","listIndexes":[5,3,0,0,0],"numValues":[10,3.95,0,0,0,0]}]} */
   signalList[i++] = GetExitSignal_09();
   signalList[i++] = GetEntrySignal_09();

   if (i != 2 * strategiesCount)
      ArrayResize(signalList, i);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_00()
  {
   // Directional Indicators (9)
   double ind0buffer0[]; CopyBuffer(indHandlers[0][0][0], 1, 1, 2, ind0buffer0);
   double ind0buffer1[]; CopyBuffer(indHandlers[0][0][0], 2, 1, 2, ind0buffer1);
   double ind0val1  = ind0buffer0[1];
   double ind0val2  = ind0buffer1[1];
   double ind0val3  = ind0buffer0[0];
   double ind0val4  = ind0buffer1[0];
   bool   ind0long  = ind0val1 > ind0val2 + sigma && ind0val3 < ind0val4 - sigma;
   bool   ind0short = ind0val1 < ind0val2 - sigma && ind0val3 > ind0val4 + sigma;
   // Williams' Percent Range (8)
   double ind1buffer[]; CopyBuffer(indHandlers[0][1][0], 0, 1, 3, ind1buffer);
   double ind1val1  = ind1buffer[2];
   double ind1val2  = ind1buffer[1];
   bool   ind1long  = ind1val1 > ind1val2 + sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma;
   // ADX (10)
   double ind2buffer[]; CopyBuffer(indHandlers[0][2][0], 0, 1, 3, ind2buffer);
   double ind2val1  = ind2buffer[2];
   double ind2val2  = ind2buffer[1];
   double ind2val3  = ind2buffer[0];
   bool   ind2long  = ind2val1 < ind2val2 - sigma && ind2val2 > ind2val3 + sigma;
   bool   ind2short = ind2long;

   return CreateEntrySignal(0, ind0long && ind1long && ind2long, ind0short && ind1short && ind2short, 37, 46, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_00()
  {
   // Envelopes (Close, Simple, 25, 0.88)
   double ind3buffer0[]; CopyBuffer(indHandlers[0][3][0], 0, 1, 2, ind3buffer0);
   double ind3buffer1[]; CopyBuffer(indHandlers[0][3][0], 1, 1, 2, ind3buffer1);
   double ind3upBand1 = ind3buffer0[1];
   double ind3dnBand1 = ind3buffer1[1];
   double ind3upBand2 = ind3buffer0[0];
   double ind3dnBand2 = ind3buffer1[0];
   bool   ind3long    = Open(0) < ind3upBand1 - sigma && Open(1) > ind3upBand2 + sigma;
   bool   ind3short   = Open(0) > ind3dnBand1 + sigma && Open(1) < ind3dnBand2 - sigma;

   return CreateExitSignal(0, ind3long, ind3short, 37, 46, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_01()
  {
   // Williams' Percent Range (7), Level: -37.0
   double ind0buffer[]; CopyBuffer(indHandlers[1][0][0], 0, 1, 3, ind0buffer);
   double ind0val1  = ind0buffer[2];
   double ind0val2  = ind0buffer[1];
   bool   ind0long  = ind0val1 > -37.0 + sigma && ind0val2 < -37.0 - sigma;
   bool   ind0short = ind0val1 < -100 - -37.0 - sigma && ind0val2 > -100 - -37.0 + sigma;
   // DeMarker (18), Level: 0.45
   double ind1buffer[]; CopyBuffer(indHandlers[1][1][0], 0, 1, 3, ind1buffer);
   double ind1val1  = ind1buffer[2];
   bool   ind1long  = ind1val1 < 0.45 - sigma;
   bool   ind1short = ind1val1 > 1 - 0.45 + sigma;
   // Standard Deviation (Close, Simple, 35), Level: 0.0045
   double ind2buffer[]; CopyBuffer(indHandlers[1][2][0], 0, 1, 3, ind2buffer);
   double ind2val1  = ind2buffer[2];
   bool   ind2long  = ind2val1 < 0.0045 - sigma;
   bool   ind2short = ind2long;
   // Williams' Percent Range (40)
   double ind3buffer[]; CopyBuffer(indHandlers[1][3][0], 0, 1, 3, ind3buffer);
   double ind3val1  = ind3buffer[2];
   double ind3val2  = ind3buffer[1];
   bool   ind3long  = ind3val1 < ind3val2 - sigma;
   bool   ind3short = ind3val1 > ind3val2 + sigma;

   return CreateEntrySignal(1, ind0long && ind1long && ind2long && ind3long, ind0short && ind1short && ind2short && ind3short, 74, 56, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_01()
  {
   // RSI (Close, 24), Level: 87
   double ind4buffer[]; CopyBuffer(indHandlers[1][4][0], 0, 1, 3, ind4buffer);
   double ind4val1  = ind4buffer[2];
   bool   ind4long  = ind4val1 > 87 + sigma;
   bool   ind4short = ind4val1 < 100 - 87 - sigma;

   return CreateExitSignal(1, ind4long, ind4short, 74, 56, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_02()
  {
   // Awesome Oscillator, Level: 0.0000
   double ind0buffer[]; CopyBuffer(indHandlers[2][0][0], 0, 1, 3, ind0buffer);
   double ind0val1  = ind0buffer[2];
   double ind0val2  = ind0buffer[1];
   bool   ind0long  = ind0val1 < 0.0000 - sigma && ind0val2 > 0.0000 + sigma;
   bool   ind0short = ind0val1 > 0.0000 + sigma && ind0val2 < 0.0000 - sigma;
   // Awesome Oscillator, Level: 0.0000
   double ind1buffer[]; CopyBuffer(indHandlers[2][1][0], 0, 1, 3, ind1buffer);
   double ind1val1  = ind1buffer[2];
   double ind1val2  = ind1buffer[1];
   bool   ind1long  = ind1val1 < 0.0000 - sigma && ind1val2 > 0.0000 + sigma;
   bool   ind1short = ind1val1 > 0.0000 + sigma && ind1val2 < 0.0000 - sigma;
   // Accelerator Oscillator
   double ind2buffer[]; CopyBuffer(indHandlers[2][2][0], 0, 1, 3, ind2buffer);
   double ind2val1  = ind2buffer[2];
   double ind2val2  = ind2buffer[1];
   bool   ind2long  = ind2val1 < ind2val2 - sigma;
   bool   ind2short = ind2val1 > ind2val2 + sigma;
   // Bollinger Bands (Close, 25, 2.51)
   double ind3buffer0[]; CopyBuffer(indHandlers[2][3][0], 1, 1, 2, ind3buffer0);
   double ind3buffer1[]; CopyBuffer(indHandlers[2][3][0], 2, 1, 2, ind3buffer1);
   double ind3upBand1 = ind3buffer0[1];
   double ind3dnBand1 = ind3buffer1[1];
   double ind3upBand2 = ind3buffer0[0];
   double ind3dnBand2 = ind3buffer1[0];
   bool   ind3long    = Open(0) < ind3dnBand1 - sigma && Open(1) > ind3dnBand2 + sigma;
   bool   ind3short   = Open(0) > ind3upBand1 + sigma && Open(1) < ind3upBand2 - sigma;

   return CreateEntrySignal(2, ind0long && ind1long && ind2long && ind3long, ind0short && ind1short && ind2short && ind3short, 100, 68, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_02()
  {
   // Stochastic Signal (4, 1, 1)
   double ind4buffer0[]; CopyBuffer(indHandlers[2][4][0], MAIN_LINE,   1, 2, ind4buffer0);
   double ind4buffer1[]; CopyBuffer(indHandlers[2][4][0], SIGNAL_LINE, 1, 2, ind4buffer1);
   double ind4val1  = ind4buffer0[1];
   double ind4val2  = ind4buffer1[1];
   double ind4val3  = ind4buffer0[0];
   double ind4val4  = ind4buffer1[0];
   bool   ind4long  = ind4val1 > ind4val2 + sigma && ind4val3 < ind4val4 - sigma;
   bool   ind4short = ind4val1 < ind4val2 - sigma && ind4val3 > ind4val4 + sigma;

   return CreateExitSignal(2, ind4long, ind4short, 100, 68, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_03()
  {
   // Average True Range (17)
   double ind0buffer[]; CopyBuffer(indHandlers[3][0][0], 0, 1, 3, ind0buffer);
   double ind0val1  = ind0buffer[2];
   double ind0val2  = ind0buffer[1];
   double ind0val3  = ind0buffer[0];
   bool   ind0long  = ind0val1 > ind0val2 + sigma && ind0val2 < ind0val3 - sigma;
   bool   ind0short = ind0long;
   // Alligator (Smoothed, Median, 43, 29, 29, 14, 14, 4)
   double ind1buffer0[]; CopyBuffer(indHandlers[3][1][0], 0, 1, 2, ind1buffer0);
   double ind1buffer1[]; CopyBuffer(indHandlers[3][1][0], 1, 1, 2, ind1buffer1);
   double ind1buffer2[]; CopyBuffer(indHandlers[3][1][0], 2, 1, 2, ind1buffer2);
   double ind1val1  = ind1buffer2[1];
   double ind1val2  = ind1buffer0[1];
   double ind1val3  = ind1buffer2[0];
   double ind1val4  = ind1buffer0[0];
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val3 > ind1val4 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val3 < ind1val4 - sigma;

   return CreateEntrySignal(3, ind0long && ind1long, ind0short && ind1short, 19, 90, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_03()
  {
   // Standard Deviation (Close, Simple, 26), Level: 0.0052
   double ind2buffer[]; CopyBuffer(indHandlers[3][2][0], 0, 1, 3, ind2buffer);
   double ind2val1  = ind2buffer[2];
   double ind2val2  = ind2buffer[1];
   bool   ind2long  = ind2val1 > 0.0052 + sigma && ind2val2 < 0.0052 - sigma;
   bool   ind2short = ind2long;

   return CreateExitSignal(3, ind2long, ind2short, 19, 90, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_04()
  {
   // Awesome Oscillator, Level: 0.0000
   double ind0buffer[]; CopyBuffer(indHandlers[4][0][0], 0, 1, 3, ind0buffer);
   double ind0val1  = ind0buffer[2];
   double ind0val2  = ind0buffer[1];
   bool   ind0long  = ind0val1 > 0.0000 + sigma && ind0val2 < 0.0000 - sigma;
   bool   ind0short = ind0val1 < 0.0000 - sigma && ind0val2 > 0.0000 + sigma;
   // Directional Indicators (37)
   double ind1buffer0[]; CopyBuffer(indHandlers[4][1][0], 1, 1, 2, ind1buffer0);
   double ind1buffer1[]; CopyBuffer(indHandlers[4][1][0], 2, 1, 2, ind1buffer1);
   double ind1val1  = ind1buffer0[1];
   double ind1val2  = ind1buffer1[1];
   double ind1val3  = ind1buffer0[0];
   double ind1val4  = ind1buffer1[0];
   bool   ind1long  = ind1val1 < ind1val2 - sigma && ind1val3 > ind1val4 + sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma && ind1val3 < ind1val4 - sigma;

   return CreateEntrySignal(4, ind0long && ind1long, ind0short && ind1short, 48, 93, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_04()
  {
   // Envelopes (Close, Simple, 23, 0.66)
   double ind2buffer0[]; CopyBuffer(indHandlers[4][2][0], 0, 1, 2, ind2buffer0);
   double ind2buffer1[]; CopyBuffer(indHandlers[4][2][0], 1, 1, 2, ind2buffer1);
   double ind2upBand1 = ind2buffer0[1];
   double ind2dnBand1 = ind2buffer1[1];
   double ind2upBand2 = ind2buffer0[0];
   double ind2dnBand2 = ind2buffer1[0];
   bool   ind2long    = Open(0) > ind2dnBand1 + sigma && Open(1) < ind2dnBand2 - sigma;
   bool   ind2short   = Open(0) < ind2upBand1 - sigma && Open(1) > ind2upBand2 + sigma;

   return CreateExitSignal(4, ind2long, ind2short, 48, 93, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_05()
  {
   // Stochastic (17, 17, 15), Level: 20.0
   double ind0buffer[]; CopyBuffer(indHandlers[5][0][0], MAIN_LINE, 1, 3, ind0buffer);
   double ind0val1  = ind0buffer[2];
   double ind0val2  = ind0buffer[1];
   bool   ind0long  = ind0val1 < 20.0 - sigma && ind0val2 > 20.0 + sigma;
   bool   ind0short = ind0val1 > 100 - 20.0 + sigma && ind0val2 < 100 - 20.0 - sigma;
   // RSI (Close, 39), Level: 44
   double ind1buffer[]; CopyBuffer(indHandlers[5][1][0], 0, 1, 3, ind1buffer);
   double ind1val1  = ind1buffer[2];
   bool   ind1long  = ind1val1 < 44 - sigma;
   bool   ind1short = ind1val1 > 100 - 44 + sigma;
   // Williams' Percent Range (39)
   double ind2buffer[]; CopyBuffer(indHandlers[5][2][0], 0, 1, 3, ind2buffer);
   double ind2val1  = ind2buffer[2];
   double ind2val2  = ind2buffer[1];
   double ind2val3  = ind2buffer[0];
   bool   ind2long  = ind2val1 < ind2val2 - sigma && ind2val2 > ind2val3 + sigma;
   bool   ind2short = ind2val1 > ind2val2 + sigma && ind2val2 < ind2val3 - sigma;
   // Williams' Percent Range (24)
   double ind3buffer[]; CopyBuffer(indHandlers[5][3][0], 0, 1, 3, ind3buffer);
   double ind3val1  = ind3buffer[2];
   double ind3val2  = ind3buffer[1];
   bool   ind3long  = ind3val1 < ind3val2 - sigma;
   bool   ind3short = ind3val1 > ind3val2 + sigma;

   return CreateEntrySignal(5, ind0long && ind1long && ind2long && ind3long, ind0short && ind1short && ind2short && ind3short, 60, 90, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_05()
  {
   // ADX (43), Level: 38.0
   double ind4buffer[]; CopyBuffer(indHandlers[5][4][0], 0, 1, 3, ind4buffer);
   double ind4val1  = ind4buffer[2];
   double ind4val2  = ind4buffer[1];
   bool   ind4long  = ind4val1 < 38.0 - sigma && ind4val2 > 38.0 + sigma;
   bool   ind4short = ind4long;

   return CreateExitSignal(5, ind4long, ind4short, 60, 90, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_06()
  {
   // Williams' Percent Range (25), Level: -80.0
   double ind0buffer[]; CopyBuffer(indHandlers[6][0][0], 0, 1, 3, ind0buffer);
   double ind0val1  = ind0buffer[2];
   double ind0val2  = ind0buffer[1];
   bool   ind0long  = ind0val1 < -80.0 - sigma && ind0val2 > -80.0 + sigma;
   bool   ind0short = ind0val1 > -100 - -80.0 + sigma && ind0val2 < -100 - -80.0 - sigma;
   // ADX (38), Level: 21.0
   double ind1buffer[]; CopyBuffer(indHandlers[6][1][0], 0, 1, 3, ind1buffer);
   double ind1val1  = ind1buffer[2];
   bool   ind1long  = ind1val1 > 21.0 + sigma;
   bool   ind1short = ind1long;
   // Bollinger Bands (Close, 17, 2.49)
   double ind2buffer0[]; CopyBuffer(indHandlers[6][2][0], 1, 1, 2, ind2buffer0);
   double ind2buffer1[]; CopyBuffer(indHandlers[6][2][0], 2, 1, 2, ind2buffer1);
   double ind2upBand1 = ind2buffer0[1];
   double ind2dnBand1 = ind2buffer1[1];
   double ind2upBand2 = ind2buffer0[0];
   double ind2dnBand2 = ind2buffer1[0];
   bool   ind2long    = Open(0) < ind2dnBand1 - sigma && Open(1) > ind2dnBand2 + sigma;
   bool   ind2short   = Open(0) > ind2upBand1 + sigma && Open(1) < ind2upBand2 - sigma;
   // Standard Deviation (Close, Simple, 8), Level: 0.0032
   double ind3buffer[]; CopyBuffer(indHandlers[6][3][0], 0, 1, 3, ind3buffer);
   double ind3val1  = ind3buffer[2];
   bool   ind3long  = ind3val1 < 0.0032 - sigma;
   bool   ind3short = ind3long;

   return CreateEntrySignal(6, ind0long && ind1long && ind2long && ind3long, ind0short && ind1short && ind2short && ind3short, 37, 39, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_06()
  {
   // RSI (Close, 31), Level: 32
   double ind4buffer[]; CopyBuffer(indHandlers[6][4][0], 0, 1, 3, ind4buffer);
   double ind4val1  = ind4buffer[2];
   double ind4val2  = ind4buffer[1];
   bool   ind4long  = ind4val1 < 32 - sigma && ind4val2 > 32 + sigma;
   bool   ind4short = ind4val1 > 100 - 32 + sigma && ind4val2 < 100 - 32 - sigma;

   return CreateExitSignal(6, ind4long, ind4short, 37, 39, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_07()
  {
   // Alligator (Smoothed, Median, 20, 4, 4, 3, 3, 2)
   double ind0buffer0[]; CopyBuffer(indHandlers[7][0][0], 0, 1, 2, ind0buffer0);
   double ind0buffer1[]; CopyBuffer(indHandlers[7][0][0], 1, 1, 2, ind0buffer1);
   double ind0buffer2[]; CopyBuffer(indHandlers[7][0][0], 2, 1, 2, ind0buffer2);
   double ind0val1  = ind0buffer2[1];
   double ind0val2  = ind0buffer1[1];
   double ind0val3  = ind0buffer2[0];
   double ind0val4  = ind0buffer1[0];
   bool   ind0long  = ind0val1 > ind0val2 + sigma && ind0val3 < ind0val4 - sigma;
   bool   ind0short = ind0val1 < ind0val2 - sigma && ind0val3 > ind0val4 + sigma;
   // Directional Indicators (23)
   double ind1buffer0[]; CopyBuffer(indHandlers[7][1][0], 1, 1, 2, ind1buffer0);
   double ind1buffer1[]; CopyBuffer(indHandlers[7][1][0], 2, 1, 2, ind1buffer1);
   double ind1val1  = ind1buffer0[1];
   double ind1val2  = ind1buffer1[1];
   double ind1val3  = ind1buffer0[0];
   double ind1val4  = ind1buffer1[0];
   bool   ind1long  = ind1val1 > ind1val2 + sigma && ind1val3 < ind1val4 - sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma && ind1val3 > ind1val4 + sigma;
   // Stochastic Signal (7, 2, 1)
   double ind2buffer0[]; CopyBuffer(indHandlers[7][2][0], MAIN_LINE,   1, 2, ind2buffer0);
   double ind2buffer1[]; CopyBuffer(indHandlers[7][2][0], SIGNAL_LINE, 1, 2, ind2buffer1);
   double ind2val1  = ind2buffer0[1];
   double ind2val2  = ind2buffer1[1];
   bool   ind2long  = ind2val1 < ind2val2 - sigma;
   bool   ind2short = ind2val1 > ind2val2 + sigma;

   return CreateEntrySignal(7, ind0long && ind1long && ind2long, ind0short && ind1short && ind2short, 46, 96, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_07()
  {
   // Envelopes (Close, Simple, 23, 0.16)
   double ind3buffer0[]; CopyBuffer(indHandlers[7][3][0], 0, 1, 2, ind3buffer0);
   double ind3buffer1[]; CopyBuffer(indHandlers[7][3][0], 1, 1, 2, ind3buffer1);
   double ind3upBand1 = ind3buffer0[1];
   double ind3dnBand1 = ind3buffer1[1];
   bool   ind3long  = Open(0) < ind3dnBand1 - sigma;
   bool   ind3short = Open(0) > ind3upBand1 + sigma;

   return CreateExitSignal(7, ind3long, ind3short, 46, 96, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_08()
  {
   // Commodity Channel Index (Typical, 37), Level: 0
   double ind0buffer[]; CopyBuffer(indHandlers[8][0][0], 0, 1, 3, ind0buffer);
   double ind0val1  = ind0buffer[2];
   double ind0val2  = ind0buffer[1];
   bool   ind0long  = ind0val1 < 0 - sigma && ind0val2 > 0 + sigma;
   bool   ind0short = ind0val1 > 0 + sigma && ind0val2 < 0 - sigma;
   // Moving Average (Simple, Close, 9, 0)
   double ind1buffer[]; CopyBuffer(indHandlers[8][1][0], 0, 1, 3, ind1buffer);
   double ind1val1  = ind1buffer[2];
   double ind1val2  = ind1buffer[1];
   double ind1val3  = ind1buffer[0];
   bool   ind1long  = ind1val1 > ind1val2 + sigma && ind1val2 < ind1val3 - sigma;
   bool   ind1short = ind1val1 < ind1val2 - sigma && ind1val2 > ind1val3 + sigma;

   return CreateEntrySignal(8, ind0long && ind1long, ind0short && ind1short, 34, 71, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_08()
  {
   // Envelopes (Close, Simple, 37, 0.64)
   double ind2buffer0[]; CopyBuffer(indHandlers[8][2][0], 0, 1, 2, ind2buffer0);
   double ind2buffer1[]; CopyBuffer(indHandlers[8][2][0], 1, 1, 2, ind2buffer1);
   double ind2upBand1 = ind2buffer0[1];
   double ind2dnBand1 = ind2buffer1[1];
   double ind2upBand2 = ind2buffer0[0];
   double ind2dnBand2 = ind2buffer1[0];
   bool   ind2long    = Open(0) > ind2upBand1 + sigma && Open(1) < ind2upBand2 - sigma;
   bool   ind2short   = Open(0) < ind2dnBand1 - sigma && Open(1) > ind2dnBand2 + sigma;

   return CreateExitSignal(8, ind2long, ind2short, 34, 71, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetEntrySignal_09()
  {
   // Alligator (Smoothed, Median, 30, 18, 18, 6, 6, 5)
   double ind0buffer0[]; CopyBuffer(indHandlers[9][0][0], 0, 1, 2, ind0buffer0);
   double ind0buffer1[]; CopyBuffer(indHandlers[9][0][0], 1, 1, 2, ind0buffer1);
   double ind0buffer2[]; CopyBuffer(indHandlers[9][0][0], 2, 1, 2, ind0buffer2);
   double ind0val1  = ind0buffer1[1];
   double ind0val2  = ind0buffer0[1];
   double ind0val3  = ind0buffer1[0];
   double ind0val4  = ind0buffer0[0];
   bool   ind0long  = ind0val1 > ind0val2 + sigma && ind0val3 < ind0val4 - sigma;
   bool   ind0short = ind0val1 < ind0val2 - sigma && ind0val3 > ind0val4 + sigma;
   // Moving Averages Crossover (Simple, Simple, 4, 23)
   double ind1buffer0[]; CopyBuffer(indHandlers[9][1][0], 0, 1, 2, ind1buffer0);
   double ind1buffer1[]; CopyBuffer(indHandlers[9][1][1], 0, 1, 2, ind1buffer1);
   double ind1val1  = ind1buffer0[1];
   double ind1val2  = ind1buffer1[1];
   bool   ind1long  = ind1val1 < ind1val2 - sigma;
   bool   ind1short = ind1val1 > ind1val2 + sigma;

   return CreateEntrySignal(9, ind0long && ind1long, ind0short && ind1short, 98, 65, false, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Signal GetExitSignal_09()
  {
   // Bollinger Bands (Close, 10, 3.95)
   double ind2buffer0[]; CopyBuffer(indHandlers[9][2][0], 1, 1, 2, ind2buffer0);
   double ind2buffer1[]; CopyBuffer(indHandlers[9][2][0], 2, 1, 2, ind2buffer1);
   double ind2upBand1 = ind2buffer0[1];
   double ind2dnBand1 = ind2buffer1[1];
   double ind2upBand2 = ind2buffer0[0];
   double ind2dnBand2 = ind2buffer1[0];
   bool   ind2long    = Open(0) > ind2dnBand1 + sigma && Open(1) < ind2dnBand2 - sigma;
   bool   ind2short   = Open(0) < ind2upBand1 - sigma && Open(1) > ind2upBand2 + sigma;

   return CreateExitSignal(9, ind2long, ind2short, 98, 65, false);
  }
//+------------------------------------------------------------------+
/*STRATEGY MARKET Premium Data; EURUSD; M1 */
