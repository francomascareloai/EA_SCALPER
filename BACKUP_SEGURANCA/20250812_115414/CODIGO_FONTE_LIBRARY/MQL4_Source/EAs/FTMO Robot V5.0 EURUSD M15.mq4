//
// EA Studio Expert Advisor
//
// Created with: Expert Advisor Studio
// Website: https://studio.eatradingacademy.com/
//
// Copyright 2023, Forex Software Ltd.
//
// Risk Disclosure
//
// Futures and forex trading contains substantial risk and is not for every investor.
// An investor could potentially lose all or more than the initial investment.
// Risk capital is money that can be lost without jeopardizing ones’ financial security or life style.
// Only risk capital should be used for trading and only those with sufficient risk capital should consider trading.

#property copyright "Forex Software Ltd."
#property version   "3.5"
#property strict

static input string _Properties_ = "------"; // --- Expert Properties ---
static input double Entry_Amount =     0.10; // Entry lots
       input int    Stop_Loss    =       25; // Stop Loss   (pips)
       input int    Take_Profit  =       90; // Take Profit (pips)

static input string ___0______   = "------"; // --- Entry Time ---
       input int    Ind0Param0   =        2; // From hour
       input int    Ind0Param1   =        0; // From minute
       input int    Ind0Param2   =       22; // Until hour
       input int    Ind0Param3   =        0; // Until minute

static input string ___1______   = "------"; // --- Envelopes ---
       input int    Ind1Param0   =       33; // Period
       input double Ind1Param1   =     0.06; // Deviation %

static input string ___2______   = "------"; // --- DeMarker ---
       input int    Ind2Param0   =       45; // Period
       input double Ind2Param1   =     0.45; // Level

static input string ___3______   = "------"; // --- MACD ---
       input int    Ind3Param0   =       25; // Fast EMA
       input int    Ind3Param1   =       35; // Slow EMA
       input int    Ind3Param2   =        9; // MACD SMA

static input string ___4______   = "------"; // --- RSI ---
       input int    Ind4Param0   =        5; // Period
       input int    Ind4Param1   =       43; // Level

static input string ___5______   = "------"; // --- RSI ---
       input int    Ind5Param0   =       20; // Period
       input int    Ind5Param1   =       30; // Level

static input string ___6______   = "------"; // --- Average True Range ---
       input int    Ind6Param0   =       30; // Period
       input double Ind6Param1   =   0.0015; // Level
static input string __Options___ = "------"; // --- Options ---
static input int    Magic_Number = 59611042; // Magic Number
static input int    Max_Spread   =        0; // Max spread protection (points)
static input int    Min_Equity   =        0; // Min equity protection (currency)

#define TRADE_RETRY_COUNT   4
#define TRADE_RETRY_WAIT  100
#define OP_FLAT            -1

// Session time is set in seconds from 00:00
int  sessionSundayOpen          =     0; // 00:00
int  sessionSundayClose         = 86400; // 24:00
int  sessionMondayThursdayOpen  =     0; // 00:00
int  sessionMondayThursdayClose = 86400; // 24:00
int  sessionFridayOpen          =     0; // 00:00
int  sessionFridayClose         = 86400; // 24:00
bool sessionIgnoreSunday        = true;
bool sessionCloseAtSessionClose = false;
bool sessionCloseAtFridayClose  = false;

const double sigma        = 0.000001;
const int    requiredBars = 48;

double posType       = OP_FLAT;
int    posTicket     = 0;
double posLots       = 0;
double posStopLoss   = 0;
double posTakeProfit = 0;

datetime barTime;
double   pip;
double   stopLevel;
bool     isTrailingStop          = false;
bool     setProtectionSeparately = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   barTime        = Time[0];
   stopLevel      = MarketInfo(_Symbol, MODE_STOPLEVEL);
   pip            = GetPipValue();
   isTrailingStop = isTrailingStop && Stop_Loss > 0;

   return ValidateInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   if(ArraySize(Time) < requiredBars)
      return;

   if(Min_Equity>0 && AccountInfoDouble(ACCOUNT_EQUITY)<Min_Equity)
      ActivateMinEquityProtection();

   if(Time[0] > barTime)
     {
      barTime = Time[0];
      OnBar();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBar(void)
  {
   UpdatePosition();

   if(posType != OP_FLAT && IsForceSessionClose())
     {
      ClosePosition();
      return;
     }

   if(IsOutOfSession())
      return;

   if(posType != OP_FLAT)
     {
      ManageClose();
      UpdatePosition();
     }

   if(posType != OP_FLAT && isTrailingStop)
     {
      double trailingStop = GetTrailingStopPrice();
      ManageTrailingStop(trailingStop);
      UpdatePosition();
     }

   int entrySignal = GetEntrySignal();

   if ((posType == OP_BUY  && entrySignal == OP_SELL) ||
       (posType == OP_SELL && entrySignal == OP_BUY ))
     {
      ClosePosition();

      // Hack to prevent MT bug https://forexsb.com/forum/post/73434/#p73434
      int repeatCount = 80;
      int delay       = 50;
      for (int i = 0; i < repeatCount; i++)
      {
         UpdatePosition();
         if (posType == OP_FLAT) break;
         Sleep(delay);
      }
     }

   if(posType == OP_FLAT && entrySignal != OP_FLAT)
     {
      OpenPosition(entrySignal);
      UpdatePosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePosition(void)
  {
   posType   = OP_FLAT;
   posTicket = 0;
   posLots   = 0;
   int total = OrdersTotal();

   for(int pos = total - 1; pos >= 0; pos -= 1)
     {
      if(OrderSelect(pos, SELECT_BY_POS) &&
         OrderSymbol()      == _Symbol   &&
         OrderMagicNumber() == Magic_Number)
        {
         posType       = OrderType();
         posLots       = OrderLots();
         posTicket     = OrderTicket();
         posStopLoss   = OrderStopLoss();
         posTakeProfit = OrderTakeProfit();
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetEntrySignal(void)
  {
   // Entry Time (2, 0, 22, 0)

   int fromTime0  = Ind0Param0 * 3600 + Ind0Param1 * 60;
   int untilTime0 = Ind0Param2 * 3600 + Ind0Param3 * 60;

   MqlDateTime mqlTime0;
   TimeToStruct(Time(0), mqlTime0);
   int barMinutes0 = mqlTime0.hour * 3600 + mqlTime0.min * 60;

   bool isOnTime0 = fromTime0 < untilTime0
      ? barMinutes0 >= fromTime0 && barMinutes0 <= untilTime0
      : barMinutes0 >= fromTime0 || barMinutes0 <= untilTime0;

   bool ind0long  = isOnTime0;
   bool ind0short = isOnTime0;


   // Envelopes (Close, Simple, 33, 0.06)
   double ind1upBand1 = iEnvelopes(NULL, 0, Ind1Param0, MODE_SMA, 0, PRICE_CLOSE, Ind1Param1, MODE_UPPER, 1);
   double ind1dnBand1 = iEnvelopes(NULL, 0, Ind1Param0, MODE_SMA, 0, PRICE_CLOSE, Ind1Param1, MODE_LOWER, 1);
   double ind1upBand2 = iEnvelopes(NULL, 0, Ind1Param0, MODE_SMA, 0, PRICE_CLOSE, Ind1Param1, MODE_UPPER, 2);
   double ind1dnBand2 = iEnvelopes(NULL, 0, Ind1Param0, MODE_SMA, 0, PRICE_CLOSE, Ind1Param1, MODE_LOWER, 2);
   bool   ind1long    = Open(0) > ind1dnBand1 + sigma && Open(1) < ind1dnBand2 - sigma;
   bool   ind1short   = Open(0) < ind1upBand1 - sigma && Open(1) > ind1upBand2 + sigma;

   // DeMarker (45), Level: 0.45
   double ind2val1  = iDeMarker(NULL, 0, Ind2Param0, 1);
   bool   ind2long  = ind2val1 > Ind2Param1 + sigma;
   bool   ind2short = ind2val1 < 1 - Ind2Param1 - sigma;

   // MACD (Close, 25, 35, 9)
   double ind3val1  = iMACD(NULL, 0, Ind3Param0, Ind3Param1, Ind3Param2, PRICE_CLOSE, MODE_MAIN, 1);
   double ind3val2  = iMACD(NULL, 0, Ind3Param0, Ind3Param1, Ind3Param2, PRICE_CLOSE, MODE_MAIN, 2);
   bool   ind3long  = ind3val1 > ind3val2 + sigma;
   bool   ind3short = ind3val1 < ind3val2 - sigma;

   // RSI (Close, 5), Level: 43
   double ind4val1  = iRSI(NULL, 0, Ind4Param0, PRICE_CLOSE, 1);
   bool   ind4long  = ind4val1 > Ind4Param1 + sigma;
   bool   ind4short = ind4val1 < 100 - Ind4Param1 - sigma;

   // RSI (Close, 20)
   double ind5val1  = iRSI(NULL, 0, Ind5Param0, PRICE_CLOSE, 1);
   double ind5val2  = iRSI(NULL, 0, Ind5Param0, PRICE_CLOSE, 2);
   double ind5val3  = iRSI(NULL, 0, Ind5Param0, PRICE_CLOSE, 3);
   bool   ind5long  = ind5val1 > ind5val2 + sigma && ind5val2 < ind5val3 - sigma;
   bool   ind5short = ind5val1 < ind5val2 - sigma && ind5val2 > ind5val3 + sigma;

   bool canOpenLong  = ind0long && ind1long && ind2long && ind3long && ind4long && ind5long;
   bool canOpenShort = ind0short && ind1short && ind2short && ind3short && ind4short && ind5short;

   return canOpenLong  && !canOpenShort ? OP_BUY
        : canOpenShort && !canOpenLong  ? OP_SELL
        : OP_FLAT;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageClose(void)
  {
   // Average True Range (30), Level: 0.0015
   double ind6val1  = iATR(NULL, 0, Ind6Param0, 1);
   double ind6val2  = iATR(NULL, 0, Ind6Param0, 2);
   bool   ind6long  = ind6val1 > Ind6Param1 + sigma && ind6val2 < Ind6Param1 - sigma;
   bool   ind6short = ind6long;

   if((posType == OP_BUY  && ind6long) ||
        (posType == OP_SELL && ind6short) )
      ClosePosition();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition(const int command)
  {
   if(!IsWithinMaxSpread()) return;

   for(int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      int    ticket     = 0;
      int    lastError  = 0;
      bool   modified   = false;
      string comment    = IntegerToString(Magic_Number);
      color  arrowColor = command == OP_BUY ? clrGreen : clrRed;

      if(IsTradeContextFree())
        {
         const double price      = command == OP_BUY ? Ask() : Bid();
         const double stopLoss   = GetStopLossPrice(command);
         const double takeProfit = GetTakeProfitPrice(command);

         if(setProtectionSeparately)
           {
            // Send an entry order without SL and TP
            ticket = OrderSend(_Symbol, command, Entry_Amount, price, 10, 0, 0, comment, Magic_Number, 0, arrowColor);

            // If the order is successful, modify the position with the corresponding SL and TP
            if(ticket > 0 && (Stop_Loss > 0 || Take_Profit > 0))
               modified = OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrBlue);
           }
         else
           {
            // Send an entry order with SL and TP
            ticket    = OrderSend(_Symbol, command, Entry_Amount, price, 10, stopLoss, takeProfit, comment, Magic_Number, 0, arrowColor);
            lastError = GetLastError();

            // If order fails, check if it is because inability to set SL or TP
            if(ticket <= 0 && lastError == 130)
              {
               // Send an entry order without SL and TP
               ticket = OrderSend(_Symbol, command, Entry_Amount, price, 10, 0, 0, comment, Magic_Number, 0, arrowColor);

               // Try setting SL and TP
               if(ticket > 0 && (Stop_Loss > 0 || Take_Profit > 0))
                  modified = OrderModify(ticket, 0, stopLoss, takeProfit, 0, clrBlue);

               // Mark the expert to set SL and TP with a separate order
               if(ticket > 0 && modified)
                 {
                  setProtectionSeparately = true;
                  Print("Detected ECN type position protection.");
                 }
              }
           }
        }

      if(ticket > 0)
         break;

      lastError = GetLastError();
      if(lastError != 135 && lastError != 136 && lastError != 137 && lastError != 138)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Open Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(void)
  {
   for(int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      bool closed;
      int lastError = 0;

      if(IsTradeContextFree())
        {
         const double price = posType == OP_BUY ? Bid() : Ask();
         closed    = OrderClose(posTicket, posLots, price, 10, clrYellow);
         lastError = GetLastError();
        }

      if(closed)
         break;

      if(lastError == 4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Close Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyPosition(void)
  {
   for(int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt++)
     {
      bool modified;
      int lastError = 0;

      if(IsTradeContextFree())
        {
         modified  = OrderModify(posTicket, 0, posStopLoss, posTakeProfit, 0, clrBlue);
         lastError = GetLastError();
        }

      if(modified)
         break;

      if(lastError == 4108)
         break;

      Sleep(TRADE_RETRY_WAIT);
      Print("Modify Position retry no: " + IntegerToString(attempt + 2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStopLossPrice(int command)
  {
   if(Stop_Loss == 0)
      return 0;

   const double delta    = MathMax(pip * Stop_Loss, _Point * stopLevel);
   const double stopLoss = command == OP_BUY ? Bid() - delta : Ask() + delta;

   return NormalizeDouble(stopLoss, _Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTakeProfitPrice(int command)
  {
   if(Take_Profit == 0)
      return 0;

   const double delta      = MathMax(pip * Take_Profit, _Point * stopLevel);
   const double takeProfit = command == OP_BUY ? Bid() + delta : Ask() - delta;

   return NormalizeDouble(takeProfit, _Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrailingStopPrice(void)
  {
   const double bid = Bid();
   const double ask = Ask();
   const double spread = ask - bid;
   const double stopLevelPoints = _Point * stopLevel;
   const double stopLossPoints  = pip * Stop_Loss;

   if(posType == OP_BUY)
     {
      const double newStopLoss = High(1) - stopLossPoints;
      if(posStopLoss <= newStopLoss - pip)
         return newStopLoss < bid
                 ? newStopLoss >= bid - stopLevelPoints
                    ? bid - stopLevelPoints
                    : newStopLoss
                 : bid;
     }

   if(posType == OP_SELL)
     {
      const double newStopLoss = Low(1) + spread + stopLossPoints;
      if(posStopLoss >= newStopLoss + pip)
         return newStopLoss > ask
                 ? newStopLoss <= ask + stopLevelPoints
                    ? ask + stopLevelPoints
                    : newStopLoss
                 : ask;
     }

   return posStopLoss;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageTrailingStop(double trailingStop)
  {
   if((posType == OP_BUY  && MathAbs(trailingStop - Bid()) < _Point) ||
      (posType == OP_SELL && MathAbs(trailingStop - Ask()) < _Point))
     {
      ClosePosition();
      return;
     }

   if( MathAbs(trailingStop - posStopLoss) > _Point )
     {
      posStopLoss = NormalizeDouble(trailingStop, _Digits);
      ModifyPosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bid(void)
  {
   return MarketInfo(_Symbol, MODE_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ask(void)
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
bool IsTradeContextFree(void)
  {
   if(IsTradeAllowed())
      return true;

   const uint startWait = GetTickCount();
   Print("Trade context is busy! Waiting...");

   while(true)
     {
      if(IsStopped())
         return false;

      const uint diff = GetTickCount() - startWait;
      if(diff > 30 * 1000)
        {
         Print("The waiting limit exceeded!");
         return false;
        }

      if(IsTradeAllowed())
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
bool IsOutOfSession(void)
  {
   const int dayOfWeek    = DayOfWeek();
   const int periodStart  = int(Time(0) % 86400);
   const int periodLength = PeriodSeconds(_Period);
   const int periodFix    = periodStart + (sessionCloseAtSessionClose ? periodLength : 0);
   const int friBarFix    = periodStart + (sessionCloseAtFridayClose || sessionCloseAtSessionClose ? periodLength : 0);

   return dayOfWeek == 0 && sessionIgnoreSunday ? true
        : dayOfWeek == 0 ? periodStart < sessionSundayOpen         || periodFix > sessionSundayClose
        : dayOfWeek  < 5 ? periodStart < sessionMondayThursdayOpen || periodFix > sessionMondayThursdayClose
                         : periodStart < sessionFridayOpen         || friBarFix > sessionFridayClose;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsForceSessionClose(void)
  {
   if(!sessionCloseAtFridayClose && !sessionCloseAtSessionClose)
      return false;

   const int dayOfWeek = DayOfWeek();
   const int periodEnd = int(Time(0) % 86400) + PeriodSeconds(_Period);

   return dayOfWeek == 0 && sessionCloseAtSessionClose ? periodEnd > sessionSundayClose
        : dayOfWeek  < 5 && sessionCloseAtSessionClose ? periodEnd > sessionMondayThursdayClose
        : dayOfWeek == 5 ? periodEnd > sessionFridayClose : false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsWithinMaxSpread(void)
  {
   if(Max_Spread == 0)
      return true;

   for(int attempt = 0; attempt < TRADE_RETRY_COUNT; attempt += 1)
     {
      const int spread = (int) MathRound((Ask() - Bid()) / _Point);

      if(spread <= Max_Spread)
         return true;

      Print("Too high spread of " + IntegerToString(spread) + " points. Waiting...");
      Sleep(TRADE_RETRY_WAIT);
     }

   Print("The entry order is cancelled due to too high spread.");

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActivateMinEquityProtection(void)
  {
   if(posType == OP_BUY || posType == OP_SELL)
      ClosePosition();

   const string equity  = DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
   const string message = "Minimum equity protection activated at: " + IntegerToString(Min_Equity);
   Comment(message);
   Print(message);

   Sleep(20 * 1000);
   ExpertRemove();
   OnDeinit(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE ValidateInit()
  {
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
/*STRATEGY MARKET FTMO-Data; EURUSD; M15 */
/*STRATEGY CODE {"properties":{"entryLots":0.1,"tradeDirectionMode":0,"oppositeEntrySignal":1,"stopLoss":25,"takeProfit":90,"useStopLoss":true,"useTakeProfit":true,"isTrailingStop":false},"openFilters":[{"name":"Entry Time","listIndexes":[0,0,0,0,0],"numValues":[2,0,22,0,0,0]},{"name":"Envelopes","listIndexes":[5,3,0,0,0],"numValues":[33,0.06,0,0,0,0]},{"name":"DeMarker","listIndexes":[2,0,0,0,0],"numValues":[45,0.45,0,0,0,0]},{"name":"MACD","listIndexes":[0,3,0,0,0],"numValues":[25,35,9,0,0,0]},{"name":"RSI","listIndexes":[2,3,0,0,0],"numValues":[5,43,0,0,0,0]},{"name":"RSI","listIndexes":[6,3,0,0,0],"numValues":[20,30,0,0,0,0]}],"closeFilters":[{"name":"Average True Range","listIndexes":[4,0,0,0,0],"numValues":[30,0.0015,0,0,0,0]}]} */
