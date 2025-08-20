//+------------------------------------------------------------------+
//|ASSARV10 by "www.assarofficial.com"
//|                                                                  |
//|   Misty Horivak
//+------------------------------------------------------------------+
#property strict
//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); 
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SLTP_MODE
  {
   Server=0,//Place SL n TP
   Client=1,//Hidden SL n TP
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TRAILINGSTOP_METHOD
  {
   TS_NONE=0,//No Trailing Stop
   TS_CLASSIC=1,//Classic
   TS_STEP_DISTANCE=2,//Step Keep Distance
   TS_STEP_BY_STEP=3, //Step By Step
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern string Contact1 = "www.assarofficial.com";
extern string Contact2 = "support@assarofficial.com";
extern string Important3 = "Default settings are for 6 digit pairs";
extern string Important4 = "Use default setting with leverage 1:500!";
extern string Important5 = "Use on any time frame. But do NOT move between time frames.";
extern string Currency = "Any currency pair under 4 pip spread.";
extern bool    mm = TRUE;
extern double  risk = 1;
extern double  default_lot = 0.01;
extern int     MaxSpread = 40;
extern int     StopLoss = 200;
extern int     TakeProfit = 50;
input ENUM_SLTP_MODE SLnTPMode=Client;
input int      LockProfitAfter=20;//Target Pips to Lock Profit
input int      ProfitLock=15;//Profit To Lock
input ENUM_TRAILINGSTOP_METHOD TrailingStopMethod=TS_STEP_DISTANCE;//Trailing Method
input int      TrailingStop=5;//Trailing Stop
input int      TrailingStep=1;//Trailing Stop Step
input bool     inpEnableAlert=true;//Enable Alert


input string                  hint4                         = "===== Forex Events Settings =====";
input bool                    FilterByEvents                = TRUE;
input int                     BeforeEventsInMinutes         = 60;
input int                     AfterEventsInMinutes          = 30;
input ENUM_BASE_CORNER        EventsAlertDispCorner         = CORNER_RIGHT_LOWER;
input int                     EventsAlertDispX              = 15;
input int                     EventsAlertDispY              = 15;
input string                  EventLabelFont                = "Verdana";
input int                     EventLabelFontSize            = 8;
input bool                    IncludeHigh                   = true;
input bool                    IncludeMedium                 = true;
input bool                    IncludeLow                    = false;
input color                   HighImpactColor               = clrRed;
input color                   MediumImpactColor             = clrOrange;
input color                   LowImpactColor                = clrYellow;
input bool                    IncludeSpeaks                 = true;
input bool                    IncludeHolidays               = true;
input bool                    ReportAllPairs                = false;
input bool                    ReportUSD                     = true;
input bool                    ReportEUR                     = true;
input bool                    ReportGBP                     = true;
input bool                    ReportCAD                     = true;
input bool                    ReportCHF                     = true;
input bool                    ReportJPY                     = true;
input bool                    ReportAUD                     = true;
input bool                    ReportNZD                     = true;
input bool                    ReportCNY                     = true;

int Zi_396;
int Zi_400;
int Zi_404;
int Zi_408;
int Zi_412;
int Zi_416;
int Zi_420;
int Zi_424;
int Z_count_428 = 0;
int Zi_432 = 0;
double Zda_436[30];
double Z_lots_440;
double Zd_448;
double Zd_456;
double Zd_464;
double Zd_472;
double Z_lotstep_480;
double Z_marginrequired_488;
double Zd_496 = 0.0;
bool ECN_Mode = FALSE;
bool Debug = FALSE;
bool Verbose = TRUE;
int MaxExecution = 0;
int MaxExecutionMinutes = 10;
double AddPriceGap = 0.0;
double Commission = 0.0;
int Slippage = 3;
double MinimumUseStopLevel = 10.0;
double VolatilityMultiplier = 125.0;
double VolatilityLimit = 325.0;
bool UseVolatilityPercentage = TRUE;
int f;
double VolatilityPercentageLimit = 125.0;
int UseIndicatorSwitch = 3;
double BBDeviation = 1.5;
string COMMENT = "ASSARV10 support@assarofficial.com";
bool AUTOMM = mm;
double EnvelopesDeviation = 0.07;
int OrderExpireSeconds = 3600;
double MinLots = 0.01;
double MaxLots = 1000.0;
bool TakeShots = TRUE;
int DelayTicks = 1;
int ShotsPerBar = 1;
string Zs_320 = "ASSARV10 support@assarofficial.com";
int Z_period_328 = 3;
int Z_digits_332 = 0;
int Zi_336 = 0;
datetime Z_time_340 = 0;
int Z_count_344 = 0;
int Zi_348 = 0;
int Zi_352 = -1;
int Zi_356 = 0;
int Zi_360 = 0;
enum lottype
  {
   Fixed_lot=0,   
   Risk_per_trade=1, 
   Margin_percent_use=2,   
  };
enum trailingmode
  {
   Adaptive_by_Time=0,  
   Adaptive_by_Volatility=1,     
   Adaptive_by_Volume=2,
  };
enum gmt
  {
   Auto_GMT_not_for_tester=0,   
   Manual_GMT=1,   
  };

 int Expert_Id = 8888;
 string Expert_Comment = "";

 lottype Lot_Type = 1;
 double Lot_Risk = 1.0;
 double Lot_Max = 0.0;
 bool TrailingStop_CorrectSL = TRUE;
 bool TrailingStop_UseRealOPAndSL = TRUE;
 trailingmode TrailingStop_TrailingMode = 0;




datetime Z_datetime_364;
int Z_leverage_368;
double Zi_372;
int Zi_376;
int Zi_380;
int Zi_384;
int Zi_388;
int Zi_392;

datetime Zi_504;
int Zi_508 = -1;
int Zi_512 = 3000000;
int Zi_516 = 0;

string lbl = "Assar.", gbl;
string STR_OPTYPE[]={"Buy","Sell","Buy Limit","Sell Limit","Buy Stop","Sell Stop"};
string lblEvent; bool Reset;

int init() {
   Print("====== Initialization of ", Zs_320, " ======");
   //------------------------------------------------------------------
   gbl = lbl+Symbol()+".";
   if (IsTesting()) { gbl = "B."+gbl; GlobalVariablesDeleteAll(gbl); }
   if (FilterByEvents) { InitEvents(); Reset = true; }
   //------------------------------------------------------------------
   Z_datetime_364 = TimeLocal();
   Zi_336 = -1;
   Z_digits_332 = Digits;
   Z_leverage_368 = AccountLeverage();
   Z_lotstep_480 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (UseIndicatorSwitch < 1 || UseIndicatorSwitch > 4) UseIndicatorSwitch = 1;
   if (UseIndicatorSwitch == 4) UseVolatilityPercentage = FALSE;
   if (Zd_464 == 0.0 && AddPriceGap == 0.0) Zd_464 = MinimumUseStopLevel;
   VolatilityPercentageLimit = VolatilityPercentageLimit / 100.0 + 1.0;
   VolatilityMultiplier /= 10.0;
   ArrayInitialize(Zda_436, 0);
   VolatilityLimit *= Point;
   Commission = f0_12(Commission * Point);
   Zd_464 *= Point;
   AddPriceGap *= Point;
   if (MinLots < MarketInfo(Symbol(), MODE_MINLOT)) MinLots = MarketInfo(Symbol(), MODE_MINLOT);
   if (MaxLots > MarketInfo(Symbol(), MODE_MAXLOT)) MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   if (MaxLots < MinLots) MaxLots = MinLots;
   Z_marginrequired_488 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   Zi_372 = MarketInfo(Symbol(), MODE_LOTSIZE);
   f0_4();
   Z_lots_440 = f0_11();
   if (Expert_Id < 0) f0_13();
   if (MaxExecution > 0) MaxExecutionMinutes = 60 * MaxExecution;
   f0_14();
   Print("========== Initialization complete! ===========\n");
   start();
   return (0);
}


int deinit() {
   if (FilterByEvents) DeInitEvents();
   string Ms_0 = "";
   if (IsTesting() && MaxExecution > 0) {
      Ms_0 = Ms_0 + "During backtesting " + IntegerToString(Z_count_428) + " number of ticks was ";
      Ms_0 = Ms_0 + "skipped to simulate latency of up to " + IntegerToString(MaxExecution) + " ms";
      f0_3(Ms_0);
   }
   f0_5();
   Print(Zs_320, " has been deinitialized!");
   return (0);
}


int start() {
   //------------------------------------------------------------------
   if (!IsConnected() || AccountNumber() == 0 || Bars <= 30 || ArraySize(Time) == 0) return(0);
   if (IsConnected() && FilterByEvents) { CheckEvents(Reset); if (Reset) Reset = false; }
   //------------------------------------------------------------------
   AUTOMM = mm;
   f0_9();
   SetSLnTP();
   return (0);
}


void f0_9() {
   string Ms_unused_8;
   bool bool_24 = false;
   int Mi_32 = 0;
   int Mi_36 = 0;
   int Mi_40 = 0;
   int ticket_52;
   int Mi_88 = 0;
   int Mi_92 = 0;
   double Md_128 = 0;
   double price_144;
   double order_stoploss_152;
   double order_takeprofit_160;
   double Md_184 = 0;
   double Md_192 = 0;
   double Md_200 = 0;
   double Md_208 = 0;
   double Md_216 = 0;
   double Md_224 = 0;
   double Md_232 = 0;
   double Md_240 = 0;
   double Md_248 = 0;
   double price_312;
   double Md_344;
   if (Z_time_340 < Time[0]) {
      if (Zi_432 < 10) Zi_432++;
      Zd_496 += (Z_count_344 - Zd_496) / Zi_432;
      Z_time_340 = Time[0];
      Z_count_344 = 0;
   } else Z_count_344++;
   if (IsTesting() && MaxExecution != 0 && Zi_352 != -1) {
      Md_344 = MathRound(Zd_496 * MaxExecution / 60000.0);
      if (Z_count_428 >= Md_344) {
         Zi_352 = -1;
         Z_count_428 = 0;
      } else {
         Z_count_428++;
         return;
      }
   }
   double ask_96 = MarketInfo(Symbol(), MODE_ASK);
   double bid_104 = MarketInfo(Symbol(), MODE_BID);
   double ihigh_168 = iHigh(Symbol(), PERIOD_M1, 0);
   double ilow_176 = iLow(Symbol(), PERIOD_M1, 0);
   double Md_280 = ihigh_168 - ilow_176;
   string Ms_16 = "";
   if (UseIndicatorSwitch == 1 || UseIndicatorSwitch == 4) {
      Md_184 = iMA(Symbol(), PERIOD_M1, Z_period_328, 0, MODE_LWMA, PRICE_LOW, 0);
      Md_192 = iMA(Symbol(), PERIOD_M1, Z_period_328, 0, MODE_LWMA, PRICE_HIGH, 0);
      Md_200 = Md_192 - Md_184;
      Mi_32 = bid_104 >= Md_184 + Md_200 / 2.0;
      Ms_16 = "iMA_low: " + f0_6(Md_184) + ", iMA_high: " + f0_6(Md_192) + ", iMA_diff: " + f0_6(Md_200);
   }
   if (UseIndicatorSwitch == 2) {
      Md_208 = iBands(Symbol(), PERIOD_M1, Z_period_328, BBDeviation, 0, PRICE_OPEN, MODE_UPPER, 0);
      Md_216 = iBands(Symbol(), PERIOD_M1, Z_period_328, BBDeviation, 0, PRICE_OPEN, MODE_LOWER, 0);
      Md_224 = Md_208 - Md_216;
      Mi_36 = bid_104 >= Md_216 + Md_224 / 2.0;
      Ms_16 = "iBands_upper: " + f0_6(Md_216) + ", iBands_lower: " + f0_6(Md_216) + ", iBands_diff: " + f0_6(Md_224);
   }
   if (UseIndicatorSwitch == 3) {
      Md_232 = iEnvelopes(Symbol(), PERIOD_M1, Z_period_328, MODE_LWMA, 0, PRICE_OPEN, EnvelopesDeviation, MODE_UPPER, 0);
      Md_240 = iEnvelopes(Symbol(), PERIOD_M1, Z_period_328, MODE_LWMA, 0, PRICE_OPEN, EnvelopesDeviation, MODE_LOWER, 0);
      Md_248 = Md_232 - Md_240;
      Mi_40 = bid_104 >= Md_240 + Md_248 / 2.0;
      Ms_16 = "iEnvelopes_upper: " + f0_6(Md_232) + ", iEnvelopes_lower: " + f0_6(Md_240) + ", iEnvelopes_diff: " + f0_6(Md_248);
   }
   bool Mi_48 = FALSE;
   int Mi_72 = 0;
   if (UseIndicatorSwitch == 1 && Mi_32 == 1) {
      Mi_48 = TRUE;
      Zd_448 = Md_192;
      Zd_456 = Md_184;
   } else {
      if (UseIndicatorSwitch == 2 && Mi_36 == 1) {
         Mi_48 = TRUE;
         Zd_448 = Md_208;
         Zd_456 = Md_216;
      } else {
         if (UseIndicatorSwitch == 3 && Mi_40 == 1) {
            Mi_48 = TRUE;
            Zd_448 = Md_232;
            Zd_456 = Md_240;
         }
      }
   }
   double Md_288 = ask_96 - bid_104;
   datetime datetime_56 = TimeCurrent() + OrderExpireSeconds;
   Z_lots_440 = f0_11();
   ArrayCopy(Zda_436, Zda_436, 0, 1, 29);
   Zda_436[29] = Md_288;
   if (Zi_348 < 30) Zi_348++;
   double Md_320 = 0;
   int pos_64 = 29;
   for (int count_68 = 0; count_68 < Zi_348; count_68++) {
      Md_320 += Zda_436[pos_64];
      pos_64--;
   }
   double Md_296 = Md_320 / Zi_348;
   double Md_328 = f0_12(ask_96 + Commission);
   double Md_336 = f0_12(bid_104 - Commission);
   double Md_304 = Md_296 + Commission;
   if (mm == TRUE) VolatilityLimit = Md_304 * VolatilityMultiplier;
   if (Md_280 && VolatilityLimit && Zd_456 && Zd_448 && UseIndicatorSwitch != 4) {
      if (Md_280 > VolatilityLimit) {
         Md_128 = Md_280 / VolatilityLimit;
         if (UseVolatilityPercentage == FALSE || (UseVolatilityPercentage == TRUE && Md_128 > VolatilityPercentageLimit)) {
            if (bid_104 < Zd_456) Mi_72 = -1;
            else
               if (bid_104 > Zd_448) Mi_72 = 1;
         }
      } else Md_128 = 0;
   }
   if (AccountBalance() <= 0.0) {
      Comment("ERROR -- Account Balance is " + DoubleToStr(MathRound(AccountBalance()), 0));
      return;
   }
   Zi_352 = -1;
   int count_76 = 0;
   int count_80 = 0;
   for (pos_64 = 0; pos_64 < OrdersTotal(); pos_64++) {
     f = OrderSelect(pos_64, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == Expert_Id && OrderCloseTime() == 0) {
         if (OrderSymbol() != Symbol()) {
            count_80++;
            continue;
         }
         switch (OrderType()) {
         case OP_BUY:
            RefreshRates();
            count_76++;
            break;
         case OP_SELL:
            RefreshRates();
            count_76++;
            break;
         case OP_BUYSTOP:
            if (Mi_48 == FALSE) {
               count_76++;
            } else 
            f = OrderDelete(OrderTicket());
            break;
         case OP_SELLSTOP:
            if (Mi_48 == TRUE) {
               count_76++;
            } else 
            f = OrderDelete(OrderTicket());
         }
      }
   }
   if (Zi_336 >= 0 || Zi_336 == -2) {
      Mi_92 = (int)NormalizeDouble(bid_104 / Point, 0);
      Mi_88 = (int)NormalizeDouble(ask_96 / Point, 0);
      if (Mi_92 % 10 != 0 || Mi_88 % 10 != 0) Zi_336 = -1;
      else {
         if (Zi_336 >= 0 && Zi_336 < 10) Zi_336++;
         else Zi_336 = -2;
      }
   }
   int Mi_unused_28 = 0;
   if (Mi_72 != 0 && MaxExecution > 0 && Zi_356 > MaxExecution) {
      Mi_72 = 0;
      if (Debug || Verbose) Print("Server is too Slow. Average Execution: " + IntegerToString(Zi_356));
   }
   double Md_112 = ask_96 + Zd_464;
   double Md_120 = bid_104 - Zd_464;
   string event;
   if (count_76 == 0 && Mi_72 != 0 && f0_12(Md_304) <= f0_12(MaxSpread * Point) && Zi_336 == -1) {
      if ((Mi_72 == -1 || Mi_72 == 2) && !IsAnyEventAround(TimeGMT(), event)) {
         price_144 = ask_96 + Zd_464;
         if (ECN_Mode == TRUE) {
            price_144 = Md_112;
            order_stoploss_152 = 0;
            order_takeprofit_160 = 0;
            Zi_352 = (int)GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_BUYSTOP, Z_lots_440, price_144, Slippage, order_stoploss_152, order_takeprofit_160, COMMENT, Expert_Id, 0, Lime);
            if (ticket_52 > 0) {
               Zi_352 = (int)GetTickCount() - Zi_352;
               if (Debug || Verbose) Print("Order executed in " + IntegerToString(Zi_352) + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Mi_unused_28 = 1;
               Zi_352 = -1;
               f0_0();
            }
            if (OrderSelect(ticket_52, SELECT_BY_TICKET)) {
               RefreshRates();
               price_144 = OrderOpenPrice();
               order_stoploss_152 = f0_12(price_144 - Md_288 - StopLoss * Point - AddPriceGap);
               order_takeprofit_160 = f0_12(price_144 + TakeProfit * Point + AddPriceGap);
               Zi_352 = (int)GetTickCount();
               bool_24 = OrderModify(OrderTicket(), price_144, order_stoploss_152, order_takeprofit_160, datetime_56, Lime);
               if (bool_24 == TRUE) {
                  Zi_352 = (int)GetTickCount() - Zi_352;
                  if (Debug || Verbose) Print("Order executed in " + IntegerToString(Zi_352) + " ms");
                  if (TakeShots && (!IsTesting())) f0_8();
               } else {
                  Mi_unused_28 = 1;
                  Zi_352 = -1;
                  f0_0();
               }
            }
         } else {
            RefreshRates();
            price_144 = Md_112;
            order_stoploss_152 = f0_12(price_144 - Md_288 - StopLoss * Point - AddPriceGap);
            order_takeprofit_160 = f0_12(price_144 + TakeProfit * Point + AddPriceGap);
            if (SLnTPMode==Client) { order_stoploss_152=0; order_takeprofit_160=0; }
            Zi_352 = (int)GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_BUYSTOP, Z_lots_440, price_144, Slippage, order_stoploss_152, order_takeprofit_160, COMMENT, Expert_Id, datetime_56, Lime);
            if (ticket_52 > 0) {
               Zi_352 = (int)GetTickCount() - Zi_352;
               if (Debug || Verbose) Print("Order executed in " + IntegerToString(Zi_352) + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Mi_unused_28 = 1;
               Zi_352 = -1;
               f0_0();
            }
         }
      }
      if ((Mi_72 == 1 || Mi_72 == 2) && !IsAnyEventAround(TimeGMT(), event)) {
         price_144 = Md_120;
         order_stoploss_152 = 0;
         order_takeprofit_160 = 0;
         if (ECN_Mode) {
            Zi_352 = (int)GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_SELLSTOP, Z_lots_440, price_144, Slippage, order_stoploss_152, order_takeprofit_160, COMMENT, Expert_Id, 0, Orange);
            if (ticket_52 > 0) {
               Zi_352 = (int)GetTickCount() - Zi_352;
               if (Debug || Verbose) Print("Order executed in " + IntegerToString(Zi_352) + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Mi_unused_28 = 1;
               Zi_352 = -1;
               f0_0();
            }
            if (OrderSelect(ticket_52, SELECT_BY_TICKET)) {
               RefreshRates();
               price_144 = OrderOpenPrice();
               order_stoploss_152 = f0_12(price_144 + Md_288 + StopLoss * Point + AddPriceGap);
               order_takeprofit_160 = f0_12(price_144 - TakeProfit * Point - AddPriceGap);
               Zi_352 = (int)GetTickCount();
               bool_24 = OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_152, order_takeprofit_160, datetime_56, Orange);
            }
            if (bool_24 == true) {
               Zi_352 = (int)GetTickCount() - Zi_352;
               if (Debug || Verbose) Print("Order executed in " + IntegerToString(Zi_352) + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Mi_unused_28 = 1;
               Zi_352 = -1;
               f0_0();
            }
         } else {
            RefreshRates();
            price_144 = Md_120;
            order_stoploss_152 = f0_12(price_144 + Md_288 + StopLoss * Point + AddPriceGap);
            order_takeprofit_160 = f0_12(price_144 - TakeProfit * Point - AddPriceGap);
            if (SLnTPMode==Client) { order_stoploss_152=0; order_takeprofit_160=0; }
            Zi_352 = (int)GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_SELLSTOP, Z_lots_440, price_144, Slippage, order_stoploss_152, order_takeprofit_160, COMMENT, Expert_Id, datetime_56, Orange);
            if (ticket_52 > 0) {
               Zi_352 = (int)GetTickCount() - Zi_352;
               if (Debug || Verbose) Print("Order executed in " + IntegerToString(Zi_352) + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Mi_unused_28 = 1;
               Zi_352 = 0;
               f0_0();
            }
         }
      }
   }
   if (MaxExecution && Zi_352 == -1 && (TimeLocal() - Z_datetime_364) % MaxExecutionMinutes == 0 && !IsAnyEventAround(TimeGMT(), event)) {
      if (IsTesting() && MaxExecution) {
         MathSrand((uint)TimeLocal());
         Zi_352 = MathRand() / (32767 / MaxExecution);
      } else {
        
            price_312 = 2.0 * ask_96;
            ticket_52 = OrderSend(Symbol(), OP_BUYSTOP, Z_lots_440, price_312, Slippage, 0, 0, COMMENT, Expert_Id, 0, Lime);
            Zi_352 = (int)GetTickCount();
            bool_24 = OrderModify(ticket_52, price_312 + 10.0 * Point, 0, 0, 0, Lime);
            Zi_352 = (int)GetTickCount() - Zi_352;
           
           f = OrderDelete(ticket_52);
         
      }
   }
   if (Zi_352 >= 0) {
      if (Zi_360 < 10) Zi_360++;
      Zi_356 += (Zi_352 - Zi_356) / Zi_360;
   }
   if (Zi_336 >= 0) {
      Comment("Robot is initializing...");
      return;
   }
   if (Zi_336 == -2) {
      Comment("ERROR -- Instrument " + Symbol() + " prices should have " + IntegerToString(Z_digits_332) + " fraction digits on broker account");
      return;
   }
   string Ms_0 = TimeToStr(TimeCurrent()) + " Tick: " + f0_10(Z_count_344);
   if (Debug || Verbose) {
      Ms_0 = Ms_0 
      + "\n*** DEBUG MODE *** \nCurrency pair: " + Symbol() + ", Volatility: " + f0_6(Md_280) + ", VolatilityLimit: " + f0_6(VolatilityLimit) + ", VolatilityPercentage: " + f0_6(Md_128);
      Ms_0 = Ms_0 
      + "\nPriceDirection: " + StringSubstr("BUY NULLSELLBOTH", Mi_72 * 4 + 4, 4) + ", Expire: " + TimeToStr(datetime_56, TIME_MINUTES) + ", Open orders: " + IntegerToString(count_76);
      Ms_0 = Ms_0 
      + "\nBid: " + f0_6(bid_104) + ", Ask: " + f0_6(ask_96) + ", " + Ms_16;
      Ms_0 = Ms_0 
      + "\nAvgSpread: " + f0_6(Md_296) + ", RealAvgSpread: " + f0_6(Md_304) + ", Commission: " + f0_6(Commission) + ", Lots: " + DoubleToStr(Z_lots_440, 2) + ", Execution: " + IntegerToString(Zi_352) + " ms";
      if (f0_12(Md_304) > f0_12(MaxSpread * Point)) {
         Ms_0 = Ms_0 
            + "\n" 
         + "The current spread (" + f0_6(Md_304) + ") is higher than what has been set as MaxSpread (" + f0_6(MaxSpread * Point) + ") so no trading is allowed right now on this currency pair!";
      }
      if (MaxExecution > 0 && Zi_356 > MaxExecution) {
         Ms_0 = Ms_0 
            + "\n" 
         + "The current Avg Execution (" + IntegerToString(Zi_356) + ") is higher than what has been set as MaxExecution (" + IntegerToString(MaxExecution) + " ms), so no trading is allowed right now on this currency pair!";
      }
      Comment(Ms_0);
      if (count_76 != 0 || Mi_72 != 0) f0_2(Ms_0);
   }
}


string f0_6(double Od_0) {
   return (DoubleToStr(Od_0, Z_digits_332));
}


double f0_12(double Od_0) {
   return (NormalizeDouble(Od_0, Z_digits_332));
}


string f0_10(int Oi_0) {
   if (Oi_0 < 10) return ("00" + IntegerToString(Oi_0));
   if (Oi_0 < 100) return ("0" + IntegerToString(Oi_0));
   return ("" + IntegerToString(Oi_0));
}


void f0_2(string Os_0) {
   int Mi_8;
   int Mi_12 = -1;
   while (Mi_12 < StringLen(Os_0)) {
      Mi_8 = Mi_12 + 1;
      Mi_12 = StringFind(Os_0, 
      "\n", Mi_8);
      if (Mi_12 == -1) {
         Print(StringSubstr(Os_0, Mi_8));
         return;
      }
      Print(StringSubstr(Os_0, Mi_8, Mi_12 - Mi_8));
   }
}


int f0_13() {
   string Ms_0 = Symbol();
   int str_len_8 = StringLen(Ms_0);
   int Mi_12 = 0;
   for (int Mi_16 = 0; Mi_16 < str_len_8 - 1; Mi_16++) Mi_12 += StringGetChar(Ms_0, Mi_16);
   Expert_Id = AccountNumber() + Mi_12;
   return (0);
}


void f0_8() {
   int Mi_0;
   if (ShotsPerBar > 0) Mi_0 = (int)MathRound(60 * Period() / ShotsPerBar);
   else Mi_0 = 60 * Period();
   int Mi_4 = (int)MathFloor((TimeCurrent() - Time[0]) / Mi_0);
   if (Time[0] != Zi_504) {
      Zi_504 = Time[0];
      Zi_508 = DelayTicks;
   } else
      if (Mi_4 > Zi_512) f0_1("i");
   Zi_512 = Mi_4;
   if (Zi_508 == 0) f0_1("");
   if (Zi_508 >= 0) Zi_508--;
}


string f0_7(int Oi_0, int Oi_4) {
   string dbl2str_8 = DoubleToStr(Oi_0, 0);
   for (; StringLen(dbl2str_8) < Oi_4; dbl2str_8 = "0" + dbl2str_8) {
   }
   return (dbl2str_8);
}


void f0_1(string Os_0 = "") {
   Zi_516++;
   string Ms_8 = "SnapShot" + Symbol() + IntegerToString(Period()) + "\\" + IntegerToString(Year()) + "-" + f0_7(Month(), 2) + "-" + f0_7(Day(), 2) + " " + f0_7(Hour(), 2) + "_" + f0_7(Minute(), 2) + "_" + f0_7(Seconds(),
      2) + " " + IntegerToString(Zi_516) + Os_0 + ".gif";
   if (!WindowScreenShot(Ms_8, 640, 480)) Print("ScreenShot error: ", ErrorDescription(GetLastError()));
}


double f0_11() {
   int Mi_40 = 0;
   if (Z_lotstep_480 == 1.0) Mi_40 = 0;
   if (Z_lotstep_480 == 0.1) Mi_40 = 1;
   if (Z_lotstep_480 == 0.01) Mi_40 = 2;
   double Md_8 = AccountEquity();
   double Md_24 = MathMin(MathFloor(0.98 * Md_8 / Z_marginrequired_488 / Z_lotstep_480) * Z_lotstep_480, MaxLots);
   double Md_32 = MinLots;
   double Md_ret_16 = MathMin(MathFloor(risk / 102.0 * Md_8 / (StopLoss + AddPriceGap) / Z_lotstep_480) * Z_lotstep_480, MaxLots);
   Md_ret_16 = NormalizeDouble(Md_ret_16, Mi_40);
   string Ms_0 = "";
   if (AUTOMM == FALSE) {
      Md_ret_16 = default_lot;
      if (default_lot > Md_24) {
         Md_ret_16 = Md_24;
         Ms_0 = "Note: Manual lotsize is too high. It has been recalculated to maximum allowed " + DoubleToStr(Md_24, 2);
         Print(Ms_0);
         Comment(Ms_0);
         default_lot = Md_24;
      } else
         if (default_lot < Md_32) Md_ret_16 = Md_32;
   }
   return (Md_ret_16);
}


double f0_4() {
   double Md_8 = AccountEquity();
   double Md_16 = MathFloor(Md_8 / Z_marginrequired_488 / Z_lotstep_480) * Z_lotstep_480;
   double Md_40 = MathFloor(100.0 * (Md_16 * (Zd_464 + StopLoss) / Md_8) / 0.1) / 10.0;
   double Md_24 = MinLots;
   double Md_48 = MathRound(100.0 * (Md_24 * StopLoss / Md_8) / 0.1) / 10.0;
   string Ms_0 = "";
   if (AUTOMM == TRUE) {
      if (risk > Md_40) {
         Ms_0 = Ms_0 + "Note: risk has manually been set to " + DoubleToStr(risk, 1) + " but cannot be higher than " + DoubleToStr(Md_40, 1) + " according to ";
         Ms_0 = Ms_0 + "the broker, StopLoss and Equity. It has now been adjusted accordingly to " + DoubleToStr(Md_40, 1) + "%";
         risk = Md_40;
         f0_3(Ms_0);
      }
      if (risk < Md_48) {
         Ms_0 = Ms_0 + "Note: risk has manually been set to " + DoubleToStr(risk, 1) + " but cannot be lower than " + DoubleToStr(Md_48, 1) + " according to ";
         Ms_0 = Ms_0 + "the broker, StopLoss, AddPriceGap and Equity. It has now been adjusted accordingly to " + DoubleToStr(Md_48, 1) + "%";
         risk = Md_48;
         f0_3(Ms_0);
      }
   } else {
      if (default_lot < MinLots) {
         Ms_0 = "Manual lotsize " + DoubleToStr(default_lot, 2) + " cannot be less than " + DoubleToStr(MinLots, 2) + ". It has now been adjusted to " + DoubleToStr(MinLots,
            2);
         default_lot = MinLots;
         f0_3(Ms_0);
      }
      if (default_lot > MaxLots) {
         Ms_0 = "Manual lotsize " + DoubleToStr(default_lot, 2) + " cannot be greater than " + DoubleToStr(MaxLots, 2) + ". It has now been adjusted to " + DoubleToStr(MinLots,
            2);
         default_lot = MaxLots;
         f0_3(Ms_0);
      }
      if (default_lot > Md_16) {
         Ms_0 = "Manual lotsize " + DoubleToStr(default_lot, 2) + " cannot be greater than maximum allowed lotsize. It has now been adjusted to " + DoubleToStr(Md_16, 2);
         default_lot = Md_16;
         f0_3(Ms_0);
      }
   }
   return (0.0);
}


void f0_14() {
   string Ms_0;
   string Ms_8;
   string Ms_16;
   int Mi_24 = IsDemo() + IsTesting();
   int Mi_28 = AccountFreeMarginMode();
   int Mi_32 = AccountStopoutMode();
   if (Mi_28 == 0) Ms_0 = "that floating profit/loss is not used for calculation.";
   else {
      if (Mi_28 == 1) Ms_0 = "both floating profit and loss on open positions.";
      else {
         if (Mi_28 == 2) Ms_0 = "only profitable values, where current loss on open positions are not included.";
         else
            if (Mi_28 == 3) Ms_0 = "only loss values are used for calculation, where current profitable open positions are not included.";
      }
   }
   if (Mi_32 == 0) Ms_8 = "percentage ratio between margin and equity.";
   else
      if (Mi_32 == 1) Ms_8 = "comparison of the free margin level to the absolute value.";
   if (AUTOMM == TRUE) Ms_16 = " (automatically calculated lots).";
   if (AUTOMM == FALSE) Ms_16 = " (fixed manual lots).";
   Print("Broker name: ", AccountCompany());
   Print("Broker server: ", AccountServer());
   Print("Account type: ", StringSubstr("RealDemoTest", Mi_24 * 4, 4));
   Print("Initial account balance: ", AccountBalance(), " ", AccountCurrency());
   Print("Broker digits: ", Z_digits_332);
   Print("Broker stoplevel / freezelevel (max): ", Zd_464, " points.");
   Print("Broker stopout level: ", Zd_472, "%");
   Print("Broker Point: ", DoubleToStr(Point, Z_digits_332), " on ", AccountCurrency());
   Print("Broker account leverage in percentage: ", Z_leverage_368);
   Print("Broker credit value on the account: ", AccountCredit());
   Print("Broker account margin: ", AccountMargin());
   Print("Broker calculation of free margin allowed to open positions considers " + Ms_0);
   Print("Broker calculates stopout level as " + Ms_8);
   Print("Broker requires at least ", Z_marginrequired_488, " ", AccountCurrency(), " in margin for 1 lot.");
   Print("Broker set 1 lot to trade ", Zi_372, " ", AccountCurrency());
   Print("Broker minimum allowed lotsize: ", MinLots);
   Print("Broker maximum allowed lotsize: ", MaxLots);
   Print("Broker allow lots to be resized in ", Z_lotstep_480, " steps.");
   Print("risk: ", risk, "%");
   Print("risk adjusted lotsize: ", DoubleToStr(Z_lots_440, 2) + Ms_16);
}

void f0_3(string Os_0) {
   Print(Os_0);
   Comment(Os_0);
}


void f0_0() {
   int error_0 = GetLastError();
   switch (error_0) {
   case 1/* NO_RESULT */:
      Zi_376++;
      return;
   case 4/* SERVER_BUSY */:
      Zi_380++;
      return;
   case 6/* NO_CONNECTION */:
      Zi_384++;
      return;
   case 8/* TOO_FREQUENT_REQUESTS */:
      Zi_388++;
      return;
   case 129/* INVALID_PRICE */:
      Zi_392++;
      return;
   case 130/* INVALID_STOPS */:
      Zi_396++;
      return;
   case 131/* INVALID_TRADE_VOLUME */:
      Zi_400++;
      return;
   case 135/* PRICE_CHANGED */:
      Zi_404++;
      return;
   case 137/* BROKER_BUSY */:
      Zi_408++;
      return;
   case 138/* REQUOTE */:
      Zi_412++;
      return;
   case 141/* TOO_MANY_REQUESTS */:
      Zi_416++;
      return;
   case 145/* TRADE_MODIFY_DENIED */:
      Zi_420++;
      return;
   case 146/* TRADE_CONTEXT_BUSY */:
      Zi_424++;
      return;
      return;
   }
}


void f0_5() {
   string Ms_0 = "Number of times the brokers server reported that ";
   if (Zi_376 > 0) f0_3(Ms_0 + "SL and TP was modified to existing values: " + DoubleToStr(Zi_376, 0));
   if (Zi_380 > 0) f0_3(Ms_0 + "it is buzy: " + DoubleToStr(Zi_380, 0));
   if (Zi_384 > 0) f0_3(Ms_0 + "the connection is lost: " + DoubleToStr(Zi_384, 0));
   if (Zi_388 > 0) f0_3(Ms_0 + "there was too many requests: " + DoubleToStr(Zi_388, 0));
   if (Zi_392 > 0) f0_3(Ms_0 + "the price was invalid: " + DoubleToStr(Zi_392, 0));
   if (Zi_396 > 0) f0_3(Ms_0 + "invalid SL and/or TP: " + DoubleToStr(Zi_396, 0));
   if (Zi_400 > 0) f0_3(Ms_0 + "invalid lot size: " + DoubleToStr(Zi_400, 0));
   if (Zi_404 > 0) f0_3(Ms_0 + "the price has changed: " + DoubleToStr(Zi_404, 0));
   if (Zi_408 > 0) f0_3(Ms_0 + "the broker is buzy: " + DoubleToStr(Zi_408, 0));
   if (Zi_412 > 0) f0_3(Ms_0 + "requotes " + DoubleToStr(Zi_412, 0));
   if (Zi_416 > 0) f0_3(Ms_0 + "too many requests " + DoubleToStr(Zi_416, 0));
   if (Zi_420 > 0) f0_3(Ms_0 + "modifying orders is denied " + DoubleToStr(Zi_420, 0));
   if (Zi_424 > 0) f0_3(Ms_0 + "trade context is buzy: " + DoubleToStr(Zi_424, 0));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LockProfit(int TiketOrder,int TargetPoints,int LockedPoints)
  {
   if(TargetPoints==0 || LockedPoints==0) return false;

   if(OrderSelect(TiketOrder,SELECT_BY_TICKET,MODE_TRADES)==false) return false;

   double CurrentSL=(OrderStopLoss()!=0)?OrderStopLoss():OrderOpenPrice();
   double point=MarketInfo(OrderSymbol(),MODE_POINT);
   int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   double minstoplevel=MarketInfo(OrderSymbol(),MODE_STOPLEVEL);
   double ask=MarketInfo(OrderSymbol(),MODE_ASK);
   double bid=MarketInfo(OrderSymbol(),MODE_BID);
   double PSL=0;
   if (SLnTPMode==Client)
   {
     CurrentSL = GlobalVariableGet(gbl+IntegerToString(OrderTicket())+".SL");
     if (CurrentSL==0 && OrderStopLoss()!=0) CurrentSL = OrderStopLoss();
   }

   if((OrderType()==OP_BUY) && (bid-OrderOpenPrice()>=TargetPoints*point) && (CurrentSL<=OrderOpenPrice()))
     {
      PSL=NormalizeDouble(OrderOpenPrice()+(LockedPoints*point),digits);
     }
   else if((OrderType()==OP_SELL) && (OrderOpenPrice()-ask>=TargetPoints*point) && (CurrentSL>=OrderOpenPrice()))
     {
      PSL=NormalizeDouble(OrderOpenPrice()-(LockedPoints*point),digits);
     }
   else
      return false;

   Print(STR_OPTYPE[OrderType()]," #",OrderTicket()," ProfitLock: OP=",OrderOpenPrice()," CSL=",CurrentSL," PSL=",PSL," LP=",LockedPoints);
   if (SLnTPMode == Server)
   {
     if(OrderModify(OrderTicket(),OrderOpenPrice(),PSL,OrderTakeProfit(),0,clrRed))
        return true;
    else
        return false;
   }
   else
   {
     GlobalVariableSet(gbl+IntegerToString(OrderTicket())+".SL", PSL);
     return true;
   }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RZ_TrailingStop(int TiketOrder,int JumlahPoin,int Step=1,ENUM_TRAILINGSTOP_METHOD Method=TS_STEP_DISTANCE)
  {
   if(JumlahPoin==0) return false;

   if(OrderSelect(TiketOrder,SELECT_BY_TICKET,MODE_TRADES)==false) return false;

   double CurrentSL=(OrderStopLoss()!=0)?OrderStopLoss():OrderOpenPrice();
   double point=MarketInfo(OrderSymbol(),MODE_POINT);
   int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   double minstoplevel=MarketInfo(OrderSymbol(),MODE_STOPLEVEL);
   double ask=MarketInfo(OrderSymbol(),MODE_ASK);
   double bid=MarketInfo(OrderSymbol(),MODE_BID);
   double TSL=0;
   if (SLnTPMode==Client)
   {
     CurrentSL = GlobalVariableGet(gbl+IntegerToString(OrderTicket())+".SL");
     if (CurrentSL==0 && OrderStopLoss()!=0) CurrentSL = OrderStopLoss();
   }

   JumlahPoin=JumlahPoin+(int)minstoplevel;

   if((OrderType()==OP_BUY) && (bid-OrderOpenPrice()>JumlahPoin*point))
     {
      if(CurrentSL==0 || CurrentSL<OrderOpenPrice()) CurrentSL=OrderOpenPrice();

      if((bid-CurrentSL)>=JumlahPoin*point)
        {
         switch(Method)
           {
            case TS_CLASSIC://Classic, no step
               TSL=NormalizeDouble(bid-(JumlahPoin*point),digits);
               break;
            case TS_STEP_DISTANCE://Step keeping distance
               TSL=NormalizeDouble(bid-((JumlahPoin-Step)*point),digits);
               break;
            case TS_STEP_BY_STEP://Step by step (slow)
               TSL=NormalizeDouble(CurrentSL+(Step*point),digits);
               break;
            default:
               TSL=0;
           }
        }
       if (SLnTPMode==Client && TSL!=0 && TSL<CurrentSL) TSL = 0;
     }

   else if((OrderType()==OP_SELL) && (OrderOpenPrice()-ask>JumlahPoin*point))
     {
      if(CurrentSL==0 || CurrentSL>OrderOpenPrice()) CurrentSL=OrderOpenPrice();

      if((CurrentSL-ask)>=JumlahPoin*point)
        {
         switch(Method)
           {
            case TS_CLASSIC://Classic
               TSL=NormalizeDouble(ask+(JumlahPoin*point),digits);
               break;
            case TS_STEP_DISTANCE://Step keeping distance
               TSL=NormalizeDouble(ask+((JumlahPoin-Step)*point),digits);
               break;
            case TS_STEP_BY_STEP://Step by step (slow)
               TSL=NormalizeDouble(CurrentSL-(Step*point),digits);
               break;
            default:
               TSL=0;
           }
        }
       if (SLnTPMode==Client && TSL!=0 && TSL>CurrentSL) TSL = 0;
     }

   if(TSL==0) return false;

   Print(STR_OPTYPE[OrderType()]," #",OrderTicket()," TrailingStop: OP=",OrderOpenPrice()," CSL=",CurrentSL," TSL=",TSL," TS=",JumlahPoin," Step=",Step);
   bool res = false;
   if (SLnTPMode == Server)
   {
     res=OrderModify(OrderTicket(),OrderOpenPrice(),TSL,OrderTakeProfit(),0,clrRed);
   }
   else
   {
     GlobalVariableSet(gbl+IntegerToString(OrderTicket())+".SL", TSL);
     res = true;
   }
   if(res == true) return true;
   else return false;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetSLnTP()
  {
   double SL,TP;
   SL=TP=0.00;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()!=Symbol()) continue;
      if (OrderMagicNumber()!=Expert_Id) continue;
      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;

      double point=MarketInfo(OrderSymbol(),MODE_POINT);
      double minstoplevel=MarketInfo(OrderSymbol(),MODE_STOPLEVEL);
      double ask=MarketInfo(OrderSymbol(),MODE_ASK);
      double bid=MarketInfo(OrderSymbol(),MODE_BID);
      int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
      double sl = GlobalVariableGet(gbl+IntegerToString(OrderTicket())+".SL");

      //Print("Check SL & TP : ",OrderSymbol()," SL = ",OrderStopLoss()," TP = ",OrderTakeProfit());

      double ClosePrice=0;
      int Points=0;
      color CloseColor=clrNONE;

      //Get Points
      if(OrderType()==OP_BUY)
        {
         CloseColor=clrBlue;
         ClosePrice=bid;
         Points=(int)((ClosePrice-OrderOpenPrice())/point);
        }
      else if(OrderType()==OP_SELL)
        {
         CloseColor=clrRed;
         ClosePrice=ask;
         Points=(int)((OrderOpenPrice()-ClosePrice)/point);
        }

      if (SLnTPMode==Client && sl!=0 && OrderType()==OP_BUY && NormalizeDouble(bid, digits)<=NormalizeDouble(sl, digits))
      {
         if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,3,CloseColor))
           {
            if(inpEnableAlert)
              {
               Alert("Closed by Virtual SL #",OrderTicket()," PL=",OrderProfit()," Points=",Points);
              }
           }
         continue;
      }
      if (SLnTPMode==Client && sl!=0 && OrderType()==OP_SELL && NormalizeDouble(ask, digits)>=NormalizeDouble(sl, digits))
      {
         if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,3,CloseColor))
           {
            if(inpEnableAlert)
              {
               Alert("Closed by Virtual SL #",OrderTicket()," PL=",OrderProfit()," Points=",Points);
              }
           }
         continue;
      }

      //Set Server SL and TP
      if(SLnTPMode==Server)
        {
         if(OrderType()==OP_BUY || OrderType()==OP_BUYSTOP)
           {
            SL=(StopLoss>0)?NormalizeDouble(OrderOpenPrice()-((StopLoss+minstoplevel)*point),digits):0;
            TP=(TakeProfit>0)?NormalizeDouble(OrderOpenPrice()+((TakeProfit+minstoplevel)*point),digits):0;
           }
         else if(OrderType()==OP_SELL || OrderType()==OP_SELLSTOP)
           {
            SL=(StopLoss>0)?NormalizeDouble(OrderOpenPrice()+((StopLoss+minstoplevel)*point),digits):0;
            TP=(TakeProfit>0)?NormalizeDouble(OrderOpenPrice()-((TakeProfit+minstoplevel)*point),digits):0;
           }

         if(OrderStopLoss()==0.0 && OrderTakeProfit()==0.0)
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,Blue);
         else if(OrderTakeProfit()==0.0)
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP,0,Blue);
         else if(OrderStopLoss()==0.0)
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Red);
        }
      //Hidden SL and TP
      else if(SLnTPMode==Client)
        {
         if((TakeProfit>0 && Points>=TakeProfit) || (StopLoss>0 && Points<=-StopLoss))
           {
            if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,3,CloseColor))
              {
               if(inpEnableAlert)
                 {
                  if(OrderProfit()>0)
                     Alert("Closed by Virtual TP #",OrderTicket()," Profit=",OrderProfit()," Points=",Points);
                  if(OrderProfit()<0)
                     Alert("Closed by Virtual SL #",OrderTicket()," Loss=",OrderProfit()," Points=",Points);
                 }
              }
           }
        }

      if(LockProfitAfter>0 && ProfitLock>0 && Points>=LockProfitAfter)
        {
         if(Points<=LockProfitAfter+TrailingStop)
           {
            LockProfit(OrderTicket(),LockProfitAfter,ProfitLock);
           }
         else if(Points>=LockProfitAfter+TrailingStop)
           {
            RZ_TrailingStop(OrderTicket(),TrailingStop,TrailingStep,TrailingStopMethod);
           }
        }
      else if(LockProfitAfter==0)
        {
         RZ_TrailingStop(OrderTicket(),TrailingStop,TrailingStep,TrailingStopMethod);
        }

     }

   return false;

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//FOREX EVENTS MANAGER
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#define TITLE     0
#define COUNTRY   1
#define DATE      2
#define TIME      3
#define IMPACT    4
#define FORECAST  5
#define PREVIOUS  6
//+------------------------------------------------------------------+
#define EVENTMAX 256
//+------------------------------------------------------------------+
bool     SkipSameTimeNews = false;
bool 	   EnableLogging    = false;   // Perhaps remove this from externs once its working well
bool     SaveXmlFiles     = true;		// If true, this will keep the daily XML files
bool     AllowWebUpdates  = true;
int      DebugLevel       = 5;
string   sUrl             = "http://www.forexfactory.com/ff_calendar_thisweek.xml";
int      logHandle        = -1;
string 	sTags[7]         = { "<title>", "<country>", "<date>", "<time>", "<impact>", "<forecast>", "<previous>" };
string 	eTags[7]         = { "</title>", "</country>", "</date>", "</time>", "</impact>", "</forecast>", "</previous>" };
string 	mainData[EVENTMAX][7];
datetime mainDataGMT[EVENTMAX];
string lines[];
color colors[];
int NewsCount;
string checkCountries;
//+------------------------------------------------------------------+
bool IsAnyEventAround(datetime base, string &event)
{
  //------------------------------------------------------------------
  if (IsTesting()) return (false);
  if (!FilterByEvents) return (false); 
  //------------------------------------------------------------------
  datetime dt;
  for (int i = 0; i < NewsCount; i++)
  {
    dt = StrToTime(MakeDateTime(mainData[i][DATE], mainData[i][TIME]));
    if (mainData[i][IMPACT] == "Holiday" && base-dt < 24*60*60)
    {
      event = mainData[i][COUNTRY]+" - "+TimeToStr(dt, TIME_DATE|TIME_SECONDS)+" - "+mainData[i][TITLE];
      return (true);
    }
    if (dt >= base && dt - base <= BeforeEventsInMinutes * 60)
    {
      event = mainData[i][COUNTRY]+" - "+TimeToStr(dt, TIME_DATE|TIME_SECONDS)+" - "+mainData[i][TITLE];
      return (true);
    }
    else if (base >= dt && base - dt <= AfterEventsInMinutes * 60)
    {
      event = mainData[i][COUNTRY]+" - "+TimeToStr(dt, TIME_DATE|TIME_SECONDS)+" - "+mainData[i][TITLE];
      return (true);
    }
  }
  return (false);
  //------------------------------------------------------------------
}
//+------------------------------------------------------------------+
int CheckEvents(bool reset = false)
{
  //------------------------------------------------------------------
  static int newsIdx = 0;
  static datetime PrevReadTime = 0;
  if (reset) PrevReadTime = 0;
  if (!IsTesting() && (newsIdx == 0 || (TimeLocal() - PrevReadTime > 60 * 60)))
  {
    string sXMLData = ReadXMLFile();
    if (sXMLData == "") return (0);
    newsIdx = ParseXML(sXMLData);
    PrevReadTime = TimeLocal();
  }
  //------------------------------------------------------------------
  datetime Gmt = TimeGMT(), time = 0;
  ArrayResize(lines, 0); ArrayResize(colors, 0);
  NewsCount = newsIdx;
  //------------------------------------------------------------------
  int i;
  for (i = 0; i < newsIdx; i++)
  {
    if (mainData[i][IMPACT] == "Holiday") continue;
    time = StrToTime(MakeDateTime(mainData[i][DATE], mainData[i][TIME]));
    if (time > Gmt) break;
  }
  if (i == newsIdx) i = newsIdx - 5;
  i--;
  if (i < 0) i = 0;
  //------------------------------------------------------------------
  int index = -1;
  int dif = int(TimeGMT() - TimeCurrent());
  int mod = (int)MathMod(MathAbs(dif), 60), add = 0;
  if (mod != 0 && mod > 30) add = (60-mod);
  if (mod != 0 && mod < 30) add = -mod;
  if (dif < 0) dif = dif - add;
  else if (dif >= 0) dif = dif + add;
  Gmt = TimeGMT();
  for (; i < newsIdx; i++)
  {
    time = StrToTime(MakeDateTime(mainData[i][DATE], mainData[i][TIME]));
    if (Gmt > time) if (Gmt - time > AfterEventsInMinutes * 60) continue;
    if (Gmt < time) if (time - Gmt > BeforeEventsInMinutes * 60) continue;
    index++;
    ArrayResize(lines, index+1); ArrayResize(colors, index+1);
    lines[index] = mainData[i][COUNTRY] + ", " + mainData[i][TITLE] + ", ";
    if (time < Gmt) lines[index] = lines[index] + "-" + TimeToStr(TimeCurrent() - (time - dif), TIME_SECONDS);
    else lines[index] = lines[index] + TimeToStr(time - dif - TimeCurrent(), TIME_SECONDS);
    colors[index] = LowImpactColor;
    if (mainData[i][IMPACT] == "High") colors[index] = HighImpactColor;
    else if (mainData[i][IMPACT] == "Medium") colors[index] = MediumImpactColor;
    else if (mainData[i][IMPACT] == "Low") colors[index] = LowImpactColor;
    if (index == 4) break;
  }
  //------------------------------------------------------------------
  for (i = index; i >= 0; i--)
  {
    DrawLabel(lblEvent+IntegerToString(index-i), EventsAlertDispX, EventsAlertDispY * (index - i + 1), colors[i]);
    ObjectSetText(lblEvent+IntegerToString(index-i), lines[i], EventLabelFontSize, EventLabelFont);
  }
  if (index == -1)
  {
    index = 0;
    DrawLabel(lblEvent+IntegerToString(index), EventsAlertDispX, EventsAlertDispY * (index + 1), Red);
    ObjectSetText(lblEvent+IntegerToString(index), "no events around!!!", EventLabelFontSize, EventLabelFont);
  }
  for (i = index + 1; i < 10; i++)
    if (ObjectFind(lblEvent+IntegerToString(i)) != -1) ObjectDelete(lblEvent+IntegerToString(i));
  //------------------------------------------------------------------
  return (1);
}
//+------------------------------------------------------------------+
void InitEvents()
{
  // If we are not logging, then do not output debug statements either
  // moved by euclid
  if (!EnableLogging) DebugLevel = 0;
  // Open the log file (will not open if logging is turned off)
  // Filename changed by euclid
  OpenLog(StringConcatenate("FFCal", Symbol(), Period()));
  lblEvent = lbl + "Event.";
  checkCountries = "";
  if (ReportAUD) checkCountries = checkCountries + ",AUD,";
  if (ReportCAD) checkCountries = checkCountries + ",CAD,";
  if (ReportCHF) checkCountries = checkCountries + ",CHF,";
  if (ReportCNY) checkCountries = checkCountries + ",CNY,";
  if (ReportEUR) checkCountries = checkCountries + ",EUR,";
  if (ReportGBP) checkCountries = checkCountries + ",GBP,";
  if (ReportJPY) checkCountries = checkCountries + ",JPY,";
  if (ReportNZD) checkCountries = checkCountries + ",NZD,";
  if (ReportUSD) checkCountries = checkCountries + ",USD,";
}
//+------------------------------------------------------------------+
void DeInitEvents()
{
  if (logHandle > 0) FileClose(logHandle);
  for (int i = 0; i < 10; i++)
    if (ObjectFind(lblEvent+IntegerToString(i)) != -1) ObjectDelete(lblEvent+IntegerToString(i));
}
//+------------------------------------------------------------------+
string GetXmlFileName()
{
  return (IntegerToString(Month())+"-"+IntegerToString(Day())+"-"+IntegerToString(Year())+"-"+"FFCal.xml");
}
//+------------------------------------------------------------------+
int ParseXML(string sData)
{
  //Print("Parse XML");
  // Get the currency pair, and split it into the two countries
  string pair = Symbol();
  string cntry1 = StringSubstr(pair, 0, 3);
  string cntry2 = StringSubstr(pair, 3, 3);
  if ( DebugLevel > 0 ) Print( "cntry1 = ", cntry1, " cntry2 = ", cntry2 );
  if ( DebugLevel > 0 ) Log( "Weekly calendar for " + pair + "\n\n" );

  // -------------------------------------------------
  // Parse the XML file looking for an event to report
  // -------------------------------------------------
  int newsIdx = 0;
  int BoEvent = 0;
  int begin, next, end;
  string PrevNewsTime = "";
  while ( newsIdx < EVENTMAX ) {
    BoEvent = StringFind( sData, "<event>", BoEvent );
    if ( BoEvent == -1 ) break;

    BoEvent += 7;
    next = StringFind( sData, "</event>", BoEvent );
    if ( next == -1 ) break;

    string myEvent = StringSubstr( sData, BoEvent, next - BoEvent );
    BoEvent = next;

    begin = 0;
    bool skip = false;
    for ( int i = 0; i < 7; i++ ) {
      mainData[newsIdx][i] = "";
      next = StringFind( myEvent, sTags[i], begin );

      // Within this event, if tag not found, then it must be missing; skip it
      if ( next == -1 )
        continue;
      else {
        // We must have found the sTag okay...
        begin = next + StringLen( sTags[i] );			// Advance past the start tag
        end = StringFind( myEvent, eTags[i], begin );	// Find start of end tag
        if ( end > begin && end != -1 ) {
          // Get data between start and end tag
          //mainData[newsIdx][i] = StringSubstr(myEvent, begin, end - begin);
          // Get data between start and end tag
          mainData[newsIdx][i] = StringSubstr( myEvent, begin, end - begin );
          //check for CDATA tag - added by euclid
          if ( StringSubstr( mainData[newsIdx][i], 0, 9 ) == "<![CDATA[" ) {
            mainData[newsIdx][i] = StringSubstr( mainData[newsIdx][i], 9, StringLen( mainData[newsIdx][i] ) - 12 );
          }
          if ( StringSubstr( mainData[newsIdx][i], 0, 4 ) == "&lt;" ) {
            mainData[newsIdx][i] = "<" + StringSubstr( mainData[newsIdx][i], 4 );
          }
          if ( StringSubstr( mainData[newsIdx][i], 0, 4 ) == "&gt;" ) {
            mainData[newsIdx][i] = ">" + StringSubstr( mainData[newsIdx][i], 4 );
          }

          //also needs to check for HTML entities here... (euclid)
        }
      }
    }

    // = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =
    // Test against filters that define whether we want to
    // skip this particular annoucement
    if ( cntry1 != mainData[newsIdx][COUNTRY] && cntry2 != mainData[newsIdx][COUNTRY] && ( !ReportAllPairs ) )  skip = true;
    if ( StringFind(checkCountries, cntry1)==-1 && StringFind(checkCountries, cntry2)==-1 ) skip = true;
    if ( !IncludeHigh && mainData[newsIdx][IMPACT]   == "High" )   skip = true;
    if ( !IncludeMedium && mainData[newsIdx][IMPACT] == "Medium" ) skip = true;
    if ( !IncludeLow && mainData[newsIdx][IMPACT]    == "Low" )    skip = true;
    if ( !IncludeHolidays && mainData[newsIdx][IMPACT] == "Holiday" ) skip = true;
    if ( !IncludeSpeaks && ( StringFind( mainData[newsIdx][TITLE], "speaks" ) != -1 || StringFind( mainData[newsIdx][TITLE], "Speaks" ) != -1 ) ) skip = true;

    if (mainData[newsIdx][IMPACT] == "Holiday") mainData[newsIdx][TIME] = "0:00am";

    if ( mainData[newsIdx][TIME] == "All Day" ||
         mainData[newsIdx][TIME] == "Tentative" ||
         mainData[newsIdx][TIME] == "" )
      skip = true;


    if( SkipSameTimeNews && PrevNewsTime == mainData[newsIdx][DATE] + mainData[newsIdx][TIME] )
      skip = true;

    PrevNewsTime = mainData[newsIdx][DATE] + mainData[newsIdx][TIME];

    // = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =
    // If not skipping this event, then log it into the draw buffers
    if ( !skip ) {
      mainDataGMT[newsIdx] = StrToTime( MakeDateTime( mainData[newsIdx][DATE], mainData[newsIdx][TIME] ) );
      Log( "Weekly calendar for " + pair + "\n\n" );
      if ( DebugLevel > 0 ) {
        Log( "FOREX FACTORY\nTitle: " + mainData[newsIdx][TITLE] +
             "\nCountry: " + mainData[newsIdx][COUNTRY] +
             "\nDate: " + mainData[newsIdx][DATE] +
             "\nTime: " + mainData[newsIdx][TIME] +
             "\nImpact: " + mainData[newsIdx][IMPACT] +
             "\nForecast: " + mainData[newsIdx][FORECAST] +
             "\nPrevious: " + mainData[newsIdx][PREVIOUS] + "\n\n" );
      }
      newsIdx++;
    } else {
      // delete skipped data.
      mainData[newsIdx][TITLE] = "";
    }
  }//while

  return( newsIdx );
}
//+------------------------------------------------------------------+
string MakeDateTime( string strDate, string strTime )
{
  // Print("Converting Forex Factory Time into Metatrader time..."); //added by MN
  // Converts forexfactory time & date into yyyy.mm.dd hh:mm
  int n1stDash = StringFind( strDate, "-" );
  int n2ndDash = StringFind( strDate, "-", n1stDash + 1 );

  string strMonth = StringSubstr( strDate, 0, 2 );
  string strDay = StringSubstr( strDate, 3, 2 );
  string strYear = StringSubstr( strDate, 6, 4 );
//	strYear = "20" + strYear;

  int nTimeColonPos = StringFind( strTime, ":" );
  string strHour = StringSubstr( strTime, 0, nTimeColonPos );
  string strMinute = StringSubstr( strTime, nTimeColonPos + 1, 2 );
  string strAM_PM = StringSubstr( strTime, StringLen( strTime ) - 2 );

  int nHour24 = StrToInteger( strHour );
  if ((strAM_PM == "pm" || strAM_PM == "PM") && nHour24 != 12 ) {
    nHour24 += 12;
  }
  if ((strAM_PM == "am" || strAM_PM == "AM") && nHour24 == 12 ) {
    nHour24 = 0;
  }
  strHour = IntegerToString(nHour24);
  if (nHour24 < 10) strHour = " 0" + strHour; else strHour = " " + strHour;
  string sTime = StringConcatenate(strYear, ".", strMonth, ".", strDay, strHour, ":", strMinute);
  return (sTime);
}
//+------------------------------------------------------------------+
string ReadXMLFile()
{
  string tmpData = "";
  bool NeedToGetFile = false;
  // Added this section to check if the XML file already exists.
  // If it does NOT, then we need to set a flag to go get it
  string xmlFileName = GetXmlFileName();
  int xmlHandle = FileOpen( xmlFileName, FILE_BIN | FILE_READ );

  // File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
  if ( xmlHandle >= 0 ) {
    // Since file exists, close what we just opened
    if( FileSize( xmlHandle ) < 70 ) NeedToGetFile = true;
    FileClose( xmlHandle );
  } else {
    NeedToGetFile = true;
  }

  //added by MN. Set this to false when using in another EA or Chart, so that the multiple
  //instances of the indicator dont fight with each other
  if ( AllowWebUpdates ) {
    // New method: Use global variables so that when put on multiple charts, it
    // will not update overly often; only first time and every 4 hours
    if ( DebugLevel > 1 )
      Print(DoubleToStr(GlobalVariableGet("LastUpdateTime"),0) + " " + IntegerToString(TimeLocal()-(int)GlobalVariableGet("LastUpdateTime")));

    if ( NeedToGetFile || GlobalVariableCheck( "LastUpdateTime" ) == false ||
         ( TimeLocal() - GlobalVariableGet( "LastUpdateTime" ) ) > 2*60*60 ) {

      if ( DebugLevel > 1 ) Print( "sUrl == ", sUrl );
      if ( DebugLevel > 0 ) Print( "Grabbing Web, url = ", sUrl );

      // THIS CALL WAS DONATED BY PAUL TO HELP FIX THE RESOURCE ERROR
      bool isOk = GrabWeb( sUrl, tmpData ); //PlaySound("tick");
      if (!isOk) return ( "" );

      if ( DebugLevel > 0 ) {
        Print( "Opening XML file...\n" );
        Print( tmpData );
      }

      // Write the contents of the ForexFactory page to an .htm file
      // If it is still open from the above FileOpen call, close it.
      xmlHandle = FileOpen( xmlFileName, FILE_BIN | FILE_WRITE );
      if ( xmlHandle < 0 ) {
        if ( DebugLevel > 0 )
          Print( "Can\'t open new xml file, the last error is ", GetLastError() );
        return( "" );
      }
      FileWriteString( xmlHandle, tmpData, StringLen( tmpData ) );
      FileClose( xmlHandle );

      if ( DebugLevel > 0 ) Print( "Wrote XML file...\n" );

      // THIS BLOCK OF CODE DONATED BY WALLY TO FIX THE RESOURCE ERROR
      //--- Look for the end XML tag to ensure that a complete page was downloaded ---//
      int end = StringFind( tmpData, "</weeklyevents>", 0 );

      if ( end <= 0 ) {
        Alert( "FFCal Error - Web page download was not complete!" );
        return( "" );
      } else {
        // set global to time of last update
        GlobalVariableSet( "LastUpdateTime", TimeLocal() );
        //
      }
      //-------------------------------------------------------------------------------//
    }
  } //end of allow web updates

  if( tmpData != "" ) return( tmpData );

  // Open the XML file
  //xmlFileName = "test.xml";
  xmlHandle = FileOpen( xmlFileName, FILE_BIN | FILE_READ );
  if ( xmlHandle < 0 ) {
    Print( "Can\'t open xml file: ", xmlFileName, ".  The last error is ", GetLastError() );
    return( "" );
  }
  if ( DebugLevel > 0 ) Print( "XML file open must be okay" );

  // Read in the whole XML file
  // Workaround for FileReadString limitation - added by euclid
  tmpData = "";
  string buffer;
  while (!FileIsEnding(xmlHandle))
  {
    buffer = "";
    buffer = FileReadString(xmlHandle, 4096);
    tmpData = tmpData + buffer;
  }
  //changed to StringConcatenate (string + string is not reliable) - euclid
  FileClose(xmlHandle);

  static string OLDxmlFileName = "";
  if( !SaveXmlFiles && AllowWebUpdates )
    if( xmlFileName != OLDxmlFileName &&  OLDxmlFileName != "" ) FileDelete( OLDxmlFileName );
  OLDxmlFileName = xmlFileName;

  return( tmpData );
}
//+------------------------------------------------------------------+
void DrawLabel(string name, int x, int y, color col)
{
  if (ObjectFind(name) == -1)
  {
    ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
    ObjectSet(name, OBJPROP_BACK, false);
    ObjectSet(name, OBJPROP_CORNER, EventsAlertDispCorner);
    if (EventsAlertDispCorner == 0 || EventsAlertDispCorner == 2) ObjectSet(name, OBJPROP_ANCHOR, ANCHOR_LEFT);
    else ObjectSet(name, OBJPROP_ANCHOR, ANCHOR_RIGHT);
    ObjectSet(name, OBJPROP_XDISTANCE, x);
    ObjectSet(name, OBJPROP_YDISTANCE, y);
  }
  if (ObjectGet(name, OBJPROP_COLOR) != col) ObjectSet(name, OBJPROP_COLOR, col);
}
//+------------------------------------------------------------------+
//====================================================================
//====================================================================
//====================================================================
//======================   GrabWeb Functions   =======================
//====================================================================
// Main Webscraping function
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// bool GrabWeb(string strUrl, string& strWebPage)
// returns the text of any webpage. Returns false on timeout or other error
//
// Parsing functions
// ~~~~~~~~~~~~~~~~~
// string GetData(string strWebPage, int nStart, string strLeftTag, string strRightTag, int& nPos)
// obtains the text between two tags found after nStart, and sets nPos to the end of the second tag
//
// void Goto(string strWebPage, int nStart, string strTag, int& nPos)
// Sets nPos to the end of the first tag found after nStart
//+------------------------------------------------------------------+
bool bWinInetDebug = false;
//+------------------------------------------------------------------+
int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig = 0;
int Internet_Open_Type_Direct = 1;
int Internet_Open_Type_Proxy = 3;
int Buffer_LEN = 80;
//+------------------------------------------------------------------+
#import "wininet.dll"
//+------------------------------------------------------------------+
#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 // Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 // Does not add the returned entity to the cache. 
#define INTERNET_FLAG_RELOAD            0x80000000 // Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.
//+------------------------------------------------------------------+
int InternetOpenW(
  string sAgent,
  int		lAccessType,
  string sProxyName = "",
  string sProxyBypass = "",
  int    lFlags = 0
);
//+------------------------------------------------------------------+
int InternetOpenUrlW(
  int    hInternetSession,
  string sUrl,
  string sHeaders = "",
  int    lHeadersLength = 0,
  uint   lFlags = 0,
  int    lContext = 0
);
//+------------------------------------------------------------------+
bool InternetReadFile(
  int     hFile,
  uchar&  sBuffer[],
  int     lNumBytesToRead,
  int&    lNumberOfBytesRead[]
);
//+------------------------------------------------------------------+
int InternetCloseHandle(
  int hInet
);
#import
//+------------------------------------------------------------------+
int hSession( bool Direct )
{
  string InternetAgent;
  if ( hSession_IEType == 0 ) {
    InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
    hSession_IEType = InternetOpenW( InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0 );
    hSession_Direct = InternetOpenW( InternetAgent, Internet_Open_Type_Direct, "0", "0", 0 );
  }
  if ( Direct ) {
    return( hSession_Direct );
  } else {
    return( hSession_IEType );
  }
}
//+------------------------------------------------------------------+
bool GrabWeb( string strUrl, string& strWebPage )
{
  bool result;
  int hInternet;
  int iResult;
  int lReturn[]	= {1};
  int session = hSession(FALSE);
  hInternet = InternetOpenUrlW( session, strUrl, "", 0, 
                                INTERNET_FLAG_NO_CACHE_WRITE |
                                INTERNET_FLAG_PRAGMA_NOCACHE |
                                INTERNET_FLAG_RELOAD, 0);
  if ( hInternet == 0 ) return( false );
  int read[1];
  uchar buf[100];
  string page = "";
  while (true)
  {
    result = InternetReadFile(hInternet, buf, ArraySize(buf), read);
    if (read[0] > 0) page = page + CharArrayToString(buf, 0, read[0], CP_UTF8);
    else             break;
  }
  strWebPage = page;
  iResult = InternetCloseHandle(hInternet);
  if (iResult == 0) return (false);
  return (true);
}
//+------------------------------------------------------------------+
bool GrabWeb2( string strUrl, string& strWebPage )
{
   string cookie=NULL, headers; 
   char post[], result[]; 
   int res; 
   ResetLastError(); 
   int timeout = 5000;
   res = WebRequest("GET",strUrl,cookie,NULL,timeout,post,0,result,headers); 
   if(res==-1) 
     { 
      Print("Error in WebRequest. Error code  =",GetLastError()); 
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
      Alert("Add the address \n"+strUrl+"\nin the list of allowed URLs on tab 'Expert Advisors' on Tools->Options menu"); 
      return (false);
     } 
   else 
     { 
      strWebPage = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
      return (true);
     } 
}
//+------------------------------------------------------------------+
//====================================================================
//====================================================================
//=====================   LogUtils Functions   =======================
//====================================================================
//====================================================================
void OpenLog( string strName )
{
  if ( !EnableLogging ) return;

  if ( logHandle <= 0 ) {
    string strMonthPad = "";
    string strDayPad = "";
    MqlDateTime mdt;
    TimeToStruct(TimeCurrent(), mdt);
    if ( mdt.mon < 10 ) strMonthPad = "0";
    if ( mdt.day < 10 )   strDayPad   = "0";

    string strFilename = "";
    StringConcatenate( strFilename, strName, "_", mdt.year, strMonthPad, mdt.mon, strDayPad, mdt.day, "_log.txt" );

    logHandle = FileOpen( strFilename, FILE_CSV | FILE_READ | FILE_WRITE );
    Print( "logHandle =================================== ", logHandle );
  }
  if ( logHandle > 0 ) {
    FileFlush( logHandle );
    FileSeek( logHandle, 0, SEEK_END );
  }
}
//+------------------------------------------------------------------+
void Log( string msg )
{
  if ( !EnableLogging ) return;
  if ( logHandle <= 0 ) return;

  msg = TimeToString( TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS ) + " " + msg;
  FileWrite( logHandle, msg );
}
//+------------------------------------------------------------------+
