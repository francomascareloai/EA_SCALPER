#property copyright "© 2024 https://t.me/fxyashwinstore";
#property link "More Info: https://t.me/fxyashwinbest2022";
#property version "";
#property strict
#property description "www.oracleea.com\nThank You For Your Purchase, Contact Oracle Support Channel For Help";

#import "user32.dll"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PostMessageA(int,int,int,int);
int GetParent(int);
int GetAncestor(int,int);

#import

enum ENUM_LOT_MODE {
   LOT_MODE_FIXED = 1, // Fixed Lot
   LOT_MODE_PERCENT = 2 // Percent Lot
};

enum ENUM_TYPE_GRID_LOT {
   fix_lot = 0, // Fixed Start Lot 0.01 / 0.01 / 0.01 / 0.01 / 0.01 /.............
   Summ_lot = 1, // Summ Sart Lot   0.01 / 0.02 / 0.03 / 0.04 / 0.05 /.............
   Martingale = 2, // Martingale Lot  0.01 / 0.02 / 0.04 / 0.08 / 0.16 /.............
   Step_lot = 3 // Step Lot        0.01 / 0.01 / 0.01 / 0.02 / 0.02 / 0.02 / 0.03
};

enum ENUM_CLOSE_MODE {
   Close_all = 0, // All Trades
   Close_this_symbol = 1, // This Symbol
   Close_this_EA = 2 // Opened with EA
};

enum ENUM_PRICE_MODE {
   Money = 0, // Equity Money
   Percentage = 1 // Equity Percent
};

enum ENUM_CLOSENEWS_MODE {
   Close_nothing = 0, // False
   Close_all_t = 1, // All Trades
   Close_this_symbol_t = 2, // This Symbol Trades
   Close_this_EA_t = 3 // Opened with EA
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern bool InpManualInitGrid; // Start MANUAL Order  Grid  (Only if A / B Enable)
extern bool InpOpenNewOrders = true; // Open New Orders ?
extern bool OpenNewOrdersGrid = true; // Enable Grid ?
extern bool InpCloseAllNow; // closes all orders now
extern string Magic_ = "--------If all the engines are disabled runs a motor in buy and sell ---------";
extern bool InpEnableEngineA = true; // Enable Engine A   [BUY]
extern int InpMagic = 7799; // Magic Number  A
extern bool InpEnableEngineB = true; // Enable Engine B   [SELL]
extern int InpMagic2 = 9977; // Magic Number  B
extern string ConfigLOTE__ = "---------------------------Config Lot INIT--------------------------------------"; // LOT CONFIGURATION
extern ENUM_LOT_MODE InpLotMode = LOT_MODE_FIXED; // Lot Mode
extern double InpFixedLot = 0.01; // Fixed Lot
extern double InpPercentLot = 0.03; // Percent Lot
extern int InpTakeProfit = 100; // Take Profit in Pips
extern double GSL; // Stop Loss (Pips) - 0.0 to No SL
extern string Prop_Firm_EA_ConfigGrid__ = "---------------------------Config Grid--------------------------------------"; // GRID CONFIGURATION
extern ENUM_TYPE_GRID_LOT TypeGridLot = Martingale; // Type Grid Lot
extern int InpGridSize = 100; // Step Size in Pips
extern double InpGridFactor = 1.457; // Grid Increment Factor (If Martingale)
extern int InpGridStepLot = 4; // STEP LOT (If  Step Lot)
extern double InpMaxLot = 99; // Max Lot
extern int InpHedgex = 2; // After Level Change Lot A to B (Necessari all Engine Enable)
extern bool GridAllDirect; // Enable Grid Dual Side
extern int InpHedge; // Hedge After Level
extern string FilterOpenOneCandle__ = "--------------------Filter One Order by Candle--------------"; // FILTER ORDER
extern bool InpOpenOneCandle; // Open one order by candle
extern ENUM_TIMEFRAMES InpTimeframeBarOpen = PERIOD_CURRENT; // Timeframe OpenOneCandle
extern string MovingAverageConfig__ = "-----------------------------Moving Average-----------------------"; // MA SETUP
extern ENUM_TIMEFRAMES InpMaFrame = PERIOD_CURRENT; // Moving Average TimeFrame
extern int InpMaPeriod = 34; // Moving Average Period
extern ENUM_MA_METHOD InpMaMethod = MODE_EMA; // Moving Average Method
extern ENUM_APPLIED_PRICE InpMaPrice = PRICE_OPEN; // Moving Average Price
extern int InpMaShift; // Moving Average Shift
extern string HILOConfig__ = "-----------------------------HILO--------------------"; // HI-LO SETUP
extern bool EnableSinalHILO = true; // Enable Sinal  HILO
extern bool InpHILOFilterInverter; // If True Invert Filter
extern ENUM_TIMEFRAMES InpHILOFrame = PERIOD_CURRENT; // HILO TimeFrame
extern int InpHILOPeriod = 3; // HILO Period
extern ENUM_MA_METHOD InpHILOMethod = MODE_EMA; // HILO Method
extern int InpHILOShift; // HILO Shift
extern string TrailingStop__ = "--------------------Trailing Stop--------------"; // TRAILING STOP
extern bool InpUseTrailingStop; // Use Trailing Stop?
extern int InpTrailStart = 20; // TrailingStart
extern int InpTrailStop = 20; // Size Trailing stop
extern string BreakEven = "--------------------Break Even--------------"; // BREAKEVEN
extern bool InpUseBreakEven; // Use Break Even ?
extern int InpBreakEvenStart = 15; // Break Even Start
extern int InpBreakEvenStep = 3; // Break Even Step
extern string FilterSpread__ = "----------------------------Filter Max Spread--------------------";
extern int InpMaxSpread = 240; // Max Spread in Pips
extern string NoOpenMoreTradesWhenReaches__ = "------------------------Daily Limits / Targets ---------------"; // DAILY LIMITS
extern int MaxTrades; // Max trades (0 to NO limit)
extern double MaxLots; // Max lots (0 to NO limit)
extern string PriceRanger = "--------------------Range of Price----------------------"; // Range of Price
extern bool PriceRangerActive; // Activate Range of Price feature
extern double RangeDistance = 10; // Distance between actual price and the initial range limits
extern string EquityGuardian = "---------------------Equity Protection--------------------"; // Equity Protection
extern ENUM_CLOSE_MODE Action = Close_all; // When Equity Protection activates -> Close
extern bool CloseChart; // Close Chart
extern bool AutoTradeOFF; // Turn Off AutoTrade
extern bool CloseTerminal; // Close MetaTrader
extern double MaxFloatingDDMoney; // Max floating DrawDown in money (0 to OFF)
extern double MaxFloatingDDPercent; // Max floating DrawDown in percentage (0 to OFF)
extern double EquitySL; // Min Equity (0 to OFF)
extern ENUM_PRICE_MODE PriceModeDD = Money; // Max DD Mode
extern double MaxDailyDrawDown; // Max DD per Day (0 to no limit)
extern double MaxFloatingProfitMoney; // Max floating Profit in money (0 to OFF)
extern double MaxFloatingProfitPercent; // Max floating Profit in percentage (0 to OFF)
extern double EquityTP; // Max Equity (0 to OFF)
extern ENUM_PRICE_MODE PriceModeTP = Money; // Daily target Mode
extern double DailyTarget; // Daily target (0 to No limit)
extern string NewsFilter__ = "----------------------------News Filter------------------------";
extern bool NewsFilter; // Enable News Filter
extern ENUM_CLOSENEWS_MODE NewsAction = Close_nothing; // When News Filter activates -> Close
extern int AfterNewsStop = 120; // mins after  an event to stay out of trading
extern int BeforeNewsStop = 120; // mins before an event to stay out of trading
extern bool NewsLight; // Enable light news
extern bool NewsMedium; // Enable medium news
extern bool NewsHard = true; // Enable hard news
extern int offset = 3; // Your Time Zone, GMT (for news)
extern bool DrawLines; // Draw lines for news
extern bool HidePast; // Hide past news (Draw only future ones)
extern string TimeFilter__ = "-------------------------Scheduler---------------------------";
extern bool UseTimeFilter;
extern string SundayHours; // Sunday Trading Hours
extern string MondayHours; // Monday Trading Hours
extern string TuesdayHours; // Tuesday Trading Hours
extern string WednesdayHours; // Wednesday Trading Hours
extern string ThursdayHours; // Thursday Trading Hours
extern string FridayHours; // Friday Trading Hours
extern string SaturdayHours; // Saturday Trading Hours
extern bool InpCloseAllTrades = true; // Close All Trades when EA turns off
extern string _Visor1_ = "-----------------------------Visor 1 --------------------";
extern bool Visor1_Show_the_Time = true;
extern bool Visor1_Show_the_Price = true;
extern color Visor1_Price_Up_Color = LawnGreen;
extern color Visor1_Price_Down_Color = Tomato;
extern int Visor1_Price_X_Position = 10;
extern int Visor1_Price_Y_Position = 10;
extern int Visor1_Price_Size = 20;
extern int Visor1_Porcent_X_Position = 10;
extern int Visor1_Porcent_Y_Position = 70;
extern int Visor1_Porcent_Size = 20;
extern int Visor1_Symbol_X_Position = 10;
extern int Visor1_Symbol_Y_Position = 40;
extern int Visor1_Symbol_Size = 20;
extern int Visor1_Chart_Timezone = -5;
extern color Visor1_Time_Color = Yellow;
extern int Visor1_Time_Size = 17;
extern int Visor1_Time_X_Position = 10;
extern int Visor1_Time_Y_Position = 10;
extern int Visor1_Spread_Size = 10;
extern int Visor1_Spread_X_Position = 10;
extern int Visor1_Spread_Y_Position = 100;

bool returned_b;
long returned_l;
int returned_i;
string Is_0508;
double Ind_003;
int Ii_0528;
int Ii_0548;
bool Gb_0000;
bool Ib_0537;
double Id_0420;
double Id_0060;
bool Ib_0533;
bool Ib_0535;
bool Ib_0536;
int Ii_0578;
double Id_0418;
double Id_0400;
double Id_03F8;
double Id_0410;
double Id_0408;
string Is_0518;
string Is_04E8;
double Ind_000;
double Id_0450;
double Ind_004;
double Id_0458;
double Id_0460;
double Id_0468;
bool Ib_052D;
bool Ib_052E;
int Ii_0558;
long Il_0028;
int Ii_0540;
double Id_0480;
double Id_04B0;
double Id_04B8;
double Id_04C0;
double Id_04C8;
bool Ib_052F;
bool Ib_0530;
int Ii_0564;
long Il_0030;
int Ii_0544;
double Id_04D8;
string Is_04F8;
bool Ib_0532;
int Gi_0000;
string Is_0008;
string Is_0588;
long Gl_0000;
string Is_C150;
int Gi_0001;
int Gi_0002;
int Gi_0003;
int Gi_0004;
bool Gb_0003;
int Gi_0005;
double Gd_0003;
double Gd_0006;
int Gi_0007;
int Ii_0020;
double Gd_0007;
double Gd_0008;
int Gi_0009;
bool Ib_0000;
double Id_03F0;
double Gd_0009;
double Gd_000A;
bool Gb_000B;
double Gd_000B;
int Gi_000C;
int Gi_000D;
int Ii_054C;
double Gd_000C;
bool Gb_000E;
int Gi_000E;
string Gs_000E;
int Gi_000F;
string Gs_000F;
int Gi_0010;
string Gs_0010;
int Gi_0011;
string Gs_0011;
int Gi_0012;
string Gs_0012;
int Gi_0013;
string Gs_0013;
int Gi_0014;
string Gs_0014;
bool Gb_0015;
int Gi_0016;
int Gi_0017;
int Gi_0018;
int Gi_0019;
double Gd_0017;
double Gd_001A;
int Gi_001B;
double Gd_001B;
double Gd_001C;
int Gi_001D;
bool Gb_001D;
bool Ib_0538;
bool Ib_0534;
int Gi_001E;
int Gi_001F;
int Gi_0020;
bool Gb_001F;
int Gi_0021;
int Gi_0022;
int Gi_0023;
bool Gb_0022;
double Gd_0022;
int Gi_0024;
int Gi_0025;
bool Gb_0024;
double Gd_0026;
int Gi_0027;
int Gi_0028;
int Ii_057C;
double Id_0058;
double Id_0018;
bool Ib_0024;
long Il_0038;
double Id_0040;
double Id_0048;
double Id_0050;
double Id_0068;
double Id_03C8;
double Id_03D0;
double Id_03D8;
double Id_03E0;
double Id_03E8;
double Id_0428;
double Id_0430;
double Id_0438;
double Id_0440;
double Id_0448;
double Id_0470;
double Id_0478;
double Id_0488;
double Id_0490;
double Id_0498;
double Id_04A0;
double Id_04A8;
double Id_04D0;
double Id_04E0;
int Ii_0524;
bool Ib_052C;
bool Ib_0531;
int Ii_053C;
int Ii_0550;
int Ii_0554;
int Ii_055C;
int Ii_0560;
int Ii_0568;
int Ii_056C;
int Ii_0570;
int Ii_0574;
int Ii_0580;
int Ii_0584;
long Il_C148;
long Gl_0001;
string Gs_0002;
short Gst_0003;
short returned_st;
string Gs_0001;
string Gs_0004;
short Gst_0005;
string Gs_0003;
string Gs_0005;
int Gi_0006;
string Gs_0006;
string Gs_0007;
int Gi_0008;
string Gs_0008;
double Gd_0000;
double Gd_0001;
bool Gb_0001;
bool Gb_0005;
bool Gb_0007;
int Gi_000A;
double Gd_0002;
int Gi_000B;
double Gd_0005;
bool Gb_0004;
double Gd_0004;
bool Gb_000C;
double Ind_001;
double Ind_002;
bool Gb_0002;
long Gl_0005;
long Gl_0006;
long Gl_0007;
long Gl_0008;
long Gl_0009;
bool Gb_0009;
string Gs_000A;
long Gl_0002;
long Gl_0003;
long Gl_000A;
string Gs_000B;
string Gs_000C;
string Gs_000D;
long Gl_0010;
long Gl_0011;
string Gs_0009;
double Gd_000D;
double Gd_000E;
double Gd_000F;
double Gd_0011;
bool Gb_0013;
double Gd_0013;
double Gd_0015;
bool Gb_0016;
double Gd_0016;
double Gd_0018;
int Gi_0015;
double Gd_0014;
int Gi_002F;
long Gl_0017;
double Gd_0019;
int Gi_001A;
int Gi_001C;
double Gd_001D;
int Gi_0029;
double Gd_002B;
int Gi_002C;
int Gi_002D;
double Gd_002C;
double Gd_002E;
int Gi_0030;
double Gd_002F;
int Gi_002A;
int Gi_0026;
double Gd_0021;
double Gd_0023;
double Gd_0024;
double Gd_0025;
double Gd_0027;
double Gd_0029;
double Gd_002A;
long Gl_0004;
bool Gb_001C;
double Gd_001F;
double Gd_0010;
bool Gb_000D;
double Id_00A4[100];
string Is_05C8[4][1000];
double returned_double;
bool order_check;
int init() {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   int Li_FFFC;

   Ib_0000 = true;
   Is_0008 = "";
   Id_0018 = 0;
   Ii_0020 = 3;
   Ib_0024 = false;
   Il_0028 = 0;
   Il_0030 = 0;
   Il_0038 = 0;
   Id_0040 = 0;
   Id_0048 = 0;
   Id_0050 = 0;
   Id_0058 = 0;
   Id_0060 = 0;
   Id_0068 = 0;
   Id_03C8 = 0;
   Id_03D0 = 0;
   Id_03D8 = 0;
   Id_03E0 = 0;
   Id_03E8 = 0;
   Id_03F0 = 0;
   Id_03F8 = 0;
   Id_0400 = 0;
   Id_0408 = 0;
   Id_0410 = 0;
   Id_0418 = 0;
   Id_0420 = 0;
   Id_0428 = 0;
   Id_0430 = 0;
   Id_0438 = 0;
   Id_0440 = 0;
   Id_0448 = 0;
   Id_0450 = 0;
   Id_0458 = 0;
   Id_0460 = 0;
   Id_0468 = 0;
   Id_0470 = 0;
   Id_0478 = 0;
   Id_0480 = 0;
   Id_0488 = 0;
   Id_0490 = 0;
   Id_0498 = 0;
   Id_04A0 = 0;
   Id_04A8 = 0;
   Id_04B0 = 0;
   Id_04B8 = 0;
   Id_04C0 = 0;
   Id_04C8 = 0;
   Id_04D0 = 0;
   Id_04D8 = 0;
   Id_04E0 = 0;
   Ii_0524 = 0;
   Ii_0528 = 16776960;
   Ib_052C = false;
   Ib_052D = false;
   Ib_052E = false;
   Ib_052F = false;
   Ib_0530 = false;
   Ib_0531 = false;
   Ib_0532 = false;
   Ib_0533 = false;
   Ib_0534 = false;
   Ib_0535 = false;
   Ib_0536 = false;
   Ib_0537 = false;
   Ib_0538 = false;
   Ii_053C = 0;
   Ii_0540 = 0;
   Ii_0544 = 0;
   Ii_0548 = 8;
   Ii_054C = 0;
   Ii_0550 = 0;
   Ii_0554 = 0;
   Ii_0558 = 0;
   Ii_055C = 0;
   Ii_0560 = 0;
   Ii_0564 = 0;
   Ii_0568 = 0;
   Ii_056C = 0;
   Ii_0570 = 0;
   Ii_0574 = 0;
   Ii_0578 = 0;
   Ii_057C = 0;
   Ii_0580 = 0;
   Ii_0584 = 86400;
   Il_C148 = 0;
   Is_C150 = "2022.07.31";
   if (IsTradeAllowed() != true) {
      Alert("Not TradeAllowed");
   }
   if (TimeYear(TimeCurrent()) == 238) {
      tmp_str0000 = (string)TimeYear(TimeCurrent());
      tmp_str0000 = "©2022-" + tmp_str0000;
      tmp_str0000 = tmp_str0000 + ", Oracle";
      Is_0508 = tmp_str0000;
   } else {
      Is_0508 = "© 2022, Oracle";
   }
   tmp_str0000 = Is_0508;
   tmp_str0001 = "TM";
   ObjectDelete(tmp_str0001);
   ObjectCreate(0, tmp_str0001, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(tmp_str0001, OBJPROP_CORNER, 2);
   ObjectSet(tmp_str0001, OBJPROP_XDISTANCE, 2);
   ObjectSet(tmp_str0001, OBJPROP_YDISTANCE, 2);
   ObjectSetInteger(0, tmp_str0001, 1000, 0);
   ObjectSetString(0, tmp_str0001, 206, "\n");
   ObjectSetText(tmp_str0001, tmp_str0000, Ii_0548, "VERDANA", Ii_0528);
   if (PriceModeTP == 1 && (DailyTarget < 0)) {
      Alert("Daily target can't be a negative percent");
      Li_FFFC = 1;
      return Li_FFFC;
   }
   if (PriceModeDD == 1) {
      if ((MaxDailyDrawDown < 0) || (MaxDailyDrawDown > 100)) {

         Alert("Max DD per Day in percentage can't be negative or higher than 100");
         Li_FFFC = 1;
         return Li_FFFC;
      }
   }
   Ib_0537 = false;
   Id_0420 = AccountEquity();
   Id_0060 = 2;
   func_1125();
   Ib_0533 = true;
   Ib_0535 = false;
   Ib_0536 = false;
   Ii_0578 = 0;
   Id_0418 = 0;
   Id_0400 = 0;
   Id_03F8 = 0;
   Id_0410 = 0;
   Id_0408 = 0;
   Is_0518 = "";
   func_1058(0);
   if (InpManualInitGrid) {
      tmp_str0002 = "SELL";
      tmp_str0003 = "_lSELL";
      ObjectDelete(0, tmp_str0003);
      ObjectCreate(0, tmp_str0003, OBJ_BUTTON, 0, 100, 100);
      ObjectSetInteger(0, tmp_str0003, 102, 250);
      ObjectSetInteger(0, tmp_str0003, 103, 15);
      ObjectSetInteger(0, tmp_str0003, 1025, 8421504);
      ObjectSetInteger(0, tmp_str0003, 6, 16777215);
      ObjectSetInteger(0, tmp_str0003, 1019, 150);
      ObjectSetInteger(0, tmp_str0003, 1020, 35);
      ObjectSetInteger(0, tmp_str0003, 8, 0);
      ObjectSetString(0, tmp_str0003, 1001, "Arial");
      ObjectSetString(0, tmp_str0003, 999, tmp_str0002);
      ObjectSetInteger(0, tmp_str0003, 1000, 0);
      ObjectSetInteger(0, tmp_str0003, 9, 0);
      ObjectSetInteger(0, tmp_str0003, 17, 0);
      ObjectSetInteger(0, tmp_str0003, 208, 1);
      ObjectSetInteger(0, tmp_str0003, 207, 1);
      ObjectSetInteger(0, tmp_str0003, 1018, 0);
      tmp_str0004 = "BUY";
      tmp_str0005 = "_lBUY";
      ObjectDelete(0, tmp_str0005);
      ObjectCreate(0, tmp_str0005, OBJ_BUTTON, 0, 100, 100);
      ObjectSetInteger(0, tmp_str0005, 102, 420);
      ObjectSetInteger(0, tmp_str0005, 103, 15);
      ObjectSetInteger(0, tmp_str0005, 1025, 8421504);
      ObjectSetInteger(0, tmp_str0005, 6, 16777215);
      ObjectSetInteger(0, tmp_str0005, 1019, 150);
      ObjectSetInteger(0, tmp_str0005, 1020, 35);
      ObjectSetInteger(0, tmp_str0005, 8, 0);
      ObjectSetString(0, tmp_str0005, 1001, "Arial");
      ObjectSetString(0, tmp_str0005, 999, tmp_str0004);
      ObjectSetInteger(0, tmp_str0005, 1000, 0);
      ObjectSetInteger(0, tmp_str0005, 9, 0);
      ObjectSetInteger(0, tmp_str0005, 17, 0);
      ObjectSetInteger(0, tmp_str0005, 208, 1);
      ObjectSetInteger(0, tmp_str0005, 207, 1);
      ObjectSetInteger(0, tmp_str0005, 1018, 0);
      tmp_str0006 = "CLOSE ALL BUY";
      tmp_str0007 = "_lCLOSE ALL BUY";
      ObjectDelete(0, tmp_str0007);
      ObjectCreate(0, tmp_str0007, OBJ_BUTTON, 0, 100, 100);
      ObjectSetInteger(0, tmp_str0007, 102, 600);
      ObjectSetInteger(0, tmp_str0007, 103, 15);
      ObjectSetInteger(0, tmp_str0007, 1025, 8421504);
      ObjectSetInteger(0, tmp_str0007, 6, 16777215);
      ObjectSetInteger(0, tmp_str0007, 1019, 150);
      ObjectSetInteger(0, tmp_str0007, 1020, 35);
      ObjectSetInteger(0, tmp_str0007, 8, 0);
      ObjectSetString(0, tmp_str0007, 1001, "Arial");
      ObjectSetString(0, tmp_str0007, 999, tmp_str0006);
      ObjectSetInteger(0, tmp_str0007, 1000, 0);
      ObjectSetInteger(0, tmp_str0007, 9, 0);
      ObjectSetInteger(0, tmp_str0007, 17, 0);
      ObjectSetInteger(0, tmp_str0007, 208, 1);
      ObjectSetInteger(0, tmp_str0007, 207, 1);
      ObjectSetInteger(0, tmp_str0007, 1018, 0);
      tmp_str0008 = "CLOSE ALL SELL";
      tmp_str0009 = "_lCLOSE ALL SELL";
      ObjectDelete(0, tmp_str0009);
      ObjectCreate(0, tmp_str0009, OBJ_BUTTON, 0, 100, 100);
      ObjectSetInteger(0, tmp_str0009, 102, 770);
      ObjectSetInteger(0, tmp_str0009, 103, 15);
      ObjectSetInteger(0, tmp_str0009, 1025, 8421504);
      ObjectSetInteger(0, tmp_str0009, 6, 16777215);
      ObjectSetInteger(0, tmp_str0009, 1019, 150);
      ObjectSetInteger(0, tmp_str0009, 1020, 35);
      ObjectSetInteger(0, tmp_str0009, 8, 0);
      ObjectSetString(0, tmp_str0009, 1001, "Arial");
      ObjectSetString(0, tmp_str0009, 999, tmp_str0008);
      ObjectSetInteger(0, tmp_str0009, 1000, 0);
      ObjectSetInteger(0, tmp_str0009, 9, 0);
      ObjectSetInteger(0, tmp_str0009, 17, 0);
      ObjectSetInteger(0, tmp_str0009, 208, 1);
      ObjectSetInteger(0, tmp_str0009, 207, 1);
      ObjectSetInteger(0, tmp_str0009, 1018, 0);
   }
   Is_04E8 = _Symbol;
   if (_Digits == 3 || _Digits == 5) {

      Id_0450 = (_Point * 10);
   } else {
      Id_0450 = _Point;
   }
   Id_0458 = (InpGridSize * Id_0450);
   Id_0460 = (InpTakeProfit * Id_0450);
   Id_0468 = (GSL * Id_0450);
   Ib_052D = false;
   Ib_052E = false;
   Ii_0558 = 0;
   Il_0028 = -1;
   Ii_0540 = 0;
   Id_0480 = 0;
   if (_Digits == 3 || _Digits == 5) {

      Id_04B0 = (_Point * 10);
   } else {
      Id_04B0 = _Point;
   }
   Id_04B8 = (InpGridSize * Id_04B0);
   Id_04C0 = (InpTakeProfit * Id_04B0);
   Id_04C8 = (GSL * Id_04B0);
   Ib_052F = false;
   Ib_0530 = false;
   Ii_0564 = 0;
   Il_0030 = -1;
   Ii_0544 = 0;
   Id_04D8 = 0;
   Is_04F8 = "";
   Ib_0532 = true;
   PrintFormat(" www.oracleea.com");
   ChartSetInteger(0, 12, 0);
   HideTestIndicators(true);
   Gi_0000 = StringLen(Is_0008);
   if (Gi_0000 > 1) {
      Is_0588 = Is_0008;
      return 0;
   }
   Is_0588 = _Symbol;

   Li_FFFC = 0;

   return Li_FFFC;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   bool Lb_FFFF;

   /*
   Gl_0000 = TimeCurrent();
   returned_i = (int)StringToTime(Is_C150);
   if (returned_i == 238) {
   Gi_0000 = ChartGetInteger(0, 106, 0);
   Gi_0000 = Gi_0000 / 2;
   tmp_str0000 = "Your License Has Been Expired Please Contact Oracle Support Channel";
   tmp_str0001 = "EX";
   ObjectDelete(tmp_str0001);
   ObjectCreate(0, tmp_str0001, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(tmp_str0001, OBJPROP_ANCHOR, 8);
   ObjectSet(tmp_str0001, OBJPROP_XDISTANCE, Gi_0000);
   ObjectSet(tmp_str0001, OBJPROP_YDISTANCE, 8);
   ObjectSetText(tmp_str0001, tmp_str0000, 14, "Calibri", 16776960);
   return ;
   }
   */
   ObjectDelete(0, "EX");
   if (Visor1_Show_the_Price) {
      func_1111('');
   } else {
      func_1111('');
   }
   Gi_0000 = 0;
   Gi_0001 = OrdersTotal() - 1;
   Gi_0002 = Gi_0001;
   if (Gi_0001 >= 0) {
      do {
         if (OrderSelect(Gi_0002, 0, 0) && OrderSymbol() == _Symbol) {
            if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

               if (OrderSymbol() == _Symbol) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                        Gi_0000 = Gi_0000 + 1;
                     }
                  }
               }
            }
         }
         Gi_0002 = Gi_0002 - 1;
      } while (Gi_0002 >= 0);
   }
   if (Gi_0000 > 0) {
      func_1118(1);
   }
   Gi_0001 = 0;
   Gi_0003 = OrdersTotal() - 1;
   Gi_0004 = Gi_0003;
   if (Gi_0003 >= 0) {
      do {
         if (OrderSelect(Gi_0004, 0, 0) && OrderSymbol() == _Symbol) {
            if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

               if (OrderSymbol() == _Symbol) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                        Gi_0001 = Gi_0001 + 1;
                     }
                  }
               }
            }
         }
         Gi_0004 = Gi_0004 - 1;
      } while (Gi_0004 >= 0);
   }
   if (Gi_0001 == 0) {
      func_1118(0);
   }
   Is_04F8 = "";
   if (PriceRangerActive && Ib_0537) {
      if ((Ask > ObjectGetDouble(0, "SupRange", 20, 0)) || (Bid < ObjectGetDouble(0, "InfRange", 20, 0))) {

         PrintFormat("Range of Price -- Price going out of the range");
         Ib_0537 = false;
         ObjectDelete(0, "SupRange");
         ObjectDelete(0, "InfRange");
         ObjectSetString(0, "butRange", 999, "Create Range");
         ObjectSetInteger(0, "butRange", 1025, 32768);
         Gi_0003 = OrdersTotal() - 1;
         Gi_0005 = Gi_0003;
         if (Gi_0003 >= 0) {
            do {
               if (OrderSelect(Gi_0005, 0, 0) && OrderSymbol() == _Symbol) {
                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_BUY) {
                           order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
                        }
                        if (OrderType() == OP_SELL) {
                           order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
                        }
                     }
                  }
                  Sleep(1000);
               }
               Gi_0005 = Gi_0005 - 1;
            } while (Gi_0005 >= 0);
         }
         PrintFormat("Range of Price -- This symbol trades were closed");
         if (Ib_0000 == false) return;
         ChartClose(0);
         return ;
      }
   }
   Lb_FFFF = true;
   Gd_0009 = (Id_03F0 - AccountEquity());
   Gd_000A = (AccountEquity() - Id_03F0);
   if ((Id_03F8 < Gd_0009)) {
      Id_03F8 = Gd_0009;
   }
   if ((Id_0408 < Gd_000A)) {
      Id_0408 = Gd_000A;
   }
   Gd_000B = 0;
   Gi_000C = OrdersTotal() - 1;
   Gi_000D = Gi_000C;
   if (Gi_000C >= 0) {
      do {
         Ii_054C = OrderSelect(Gi_000D, 0, 0);
         Gd_000C = OrderProfit();
         Gd_000B = ((Gd_000C + OrderCommission()) + Gd_000B);
         Gi_000D = Gi_000D - 1;
      } while (Gi_000D >= 0);
   }
   Gd_000C = -Gd_000B;
   if ((Gd_000C > Id_0418)) {
      Id_0418 = Gd_000C;
   }
   if ((AccountEquity() < Id_0420)) {
      Id_0420 = AccountEquity();
   }
   tmp_str0003 = "Max DD: " + DoubleToString(Id_0418, 2);
   tmp_str0002 = tmp_str0003;
   ObjectSetText("MaxFloatDD_Label", tmp_str0002, Visor1_Spread_Size, "Arial", 16777215);
   tmp_str0004 = "Min Equity: " + DoubleToString(Id_0420, 2);
   tmp_str0003 = tmp_str0004;
   ObjectSetText("MinEquity_Label", tmp_str0003, Visor1_Spread_Size, "Arial", 16777215);
   if (Ii_0578 != Day()) {
      Ii_0578 = Day();
      func_1058(2);
   }
   if (UseTimeFilter) {
      string Ls_FFA8[7] = { "", "", "", "", "", "", "" };
      Ls_FFA8[0] = MondayHours;
      Ls_FFA8[1] = TuesdayHours;
      Ls_FFA8[2] = WednesdayHours;
      Ls_FFA8[3] = ThursdayHours;
      Ls_FFA8[4] = FridayHours;
      Ls_FFA8[5] = SaturdayHours;
      Ls_FFA8[6] = SundayHours;
      Gb_0015 = func_1009(Ls_FFA8);
      ArrayFree(Ls_FFA8);
      if (Gb_0015 != true) {
         Is_04F8 = Is_04F8 + "Filter TimeFilter ON \n";
         if (Ib_0533 != 0) return;
         PrintFormat("ROBOT OFF because TIME FILTER");
         if (InpCloseAllTrades) {
            Gi_0016 = 0;
            Gi_0017 = OrdersTotal() - 1;
            Gi_0018 = Gi_0017;
            if (Gi_0017 >= 0) {
               do {
                  if (OrderSelect(Gi_0018, 0, 0) && OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderSymbol() == _Symbol) {
                           if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                              if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                                 Gi_0016 = Gi_0016 + 1;
                              }
                           }
                        }
                     }
                  }
                  Gi_0018 = Gi_0018 - 1;
               } while (Gi_0018 >= 0);
            }
            if (Gi_0016 > 0) {
               Gi_0017 = OrdersTotal() - 1;
               Gi_0019 = Gi_0017;
               if (Gi_0017 >= 0) {
                  do {
                     if (OrderSelect(Gi_0019, 0, 0) && OrderSymbol() == _Symbol) {
                        if (OrderSymbol() == _Symbol) {
                           if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                              if (OrderType() == OP_BUY) {
                                 order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
                              }
                              if (OrderType() == OP_SELL) {
                                 order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
                              }
                           }
                        }
                        Sleep(1000);
                     }
                     Gi_0019 = Gi_0019 - 1;
                  } while (Gi_0019 >= 0);
               }
               PrintFormat("Close Trades because Time Filter");
            }
         }
         Ib_0533 = true;
         Lb_FFFF = false;
         return ;
      }
   }
   if (Ib_0533 == true) {
      PrintFormat("ROBOT ON because TIME FILTER");
      Ib_0533 = false;
      Lb_FFFF = true;
      func_1058(1);
   }
   if (NewsFilter) {
      if (func_1095()) {
         Comment("News time");
         Gb_001D = true;
      } else {
         Gb_001D = false;
      }
      if (Gb_001D) {
         Lb_FFFF = false;
         Is_04F8 = Is_04F8 + "Filter News ON \n";
         if (Ib_0538 != true) {
            Ib_0538 = true;
            PrintFormat("EA PAUSED because NEWS");
            func_1060();
         }
      }
   }
   if (Lb_FFFF == true && Ib_0538) {
      Ib_0538 = false;
      PrintFormat("EA ON because NEWS ended");
   }
   if (Ib_0534 == 0) {
      if (!func_1057()) {
         func_1059();
         Ib_0534 = true;
         Lb_FFFF = false;
      }
   } else {
      Lb_FFFF = false;
   }
   Gi_001E = 0;
   Gi_001F = OrdersTotal() - 1;
   Gi_0020 = Gi_001F;
   if (Gi_001F >= 0) {
      do {
         if (OrderSelect(Gi_0020, 0, 0) && OrderSymbol() == _Symbol) {
            if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

               if (OrderSymbol() == _Symbol) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                        Gi_001E = Gi_001E + 1;
                     }
                  }
               }
            }
         }
         Gi_0020 = Gi_0020 - 1;
      } while (Gi_0020 >= 0);
   }
   if (MaxTrades != 0 && Gi_001E >= MaxTrades) {
      Gb_001F = false;
   } else {
      Gb_001F = true;
   }
   if (Gb_001F != true) {
      Is_04F8 = Is_04F8 + "Filter NumTrades ON \n";
      Lb_FFFF = false;
      if (Ib_0536 != true) {
         Ib_0536 = true;
         Gi_0021 = 0;
         Gi_0022 = OrdersTotal() - 1;
         Gi_0023 = Gi_0022;
         if (Gi_0022 >= 0) {
            do {
               if (OrderSelect(Gi_0023, 0, 0) && OrderSymbol() == _Symbol) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     if (OrderSymbol() == _Symbol) {
                        if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                           if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                              Gi_0021 = Gi_0021 + 1;
                           }
                        }
                     }
                  }
               }
               Gi_0023 = Gi_0023 - 1;
            } while (Gi_0023 >= 0);
         }
         tmp_str0004 = (string)Gi_0021;
         tmp_str0004 = "EA PAUSED because Max Trades is reached. Actual EA trades = " + tmp_str0004;
         PrintFormat(tmp_str0004);
      }
   }
   Gd_0022 = 0;
   Gi_0024 = OrdersTotal() - 1;
   Gi_0025 = Gi_0024;
   if (Gi_0024 >= 0) {
      do {
         if (OrderSelect(Gi_0025, 0, 0)) {
            if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

               Gd_0022 = (Gd_0022 + OrderLots());
            }
         }
         Gi_0025 = Gi_0025 - 1;
      } while (Gi_0025 >= 0);
   }
   Gb_0024 = (NormalizeDouble(Gd_0022, 2) >= MaxLots);
   if ((MaxLots > 0) && Gb_0024 != false) {
      Gb_0024 = false;
   } else {
      Gb_0024 = true;
   }
   if (!Gb_0024) {
      Is_04F8 = Is_04F8 + "Filter NumLots ON \n";
      Lb_FFFF = false;
      if (!Ib_0535) {
         Ib_0535 = true;
         Gd_0026 = 0;
         Gi_0027 = OrdersTotal() - 1;
         Gi_0028 = Gi_0027;
         if (Gi_0027 >= 0) {
            do {
               if (OrderSelect(Gi_0028, 0, 0)) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     Gd_0026 = (Gd_0026 + OrderLots());
                  }
               }
               Gi_0028 = Gi_0028 - 1;
            } while (Gi_0028 >= 0);
         }
         tmp_str0005 = (string)NormalizeDouble(Gd_0026, 2);
         tmp_str0005 = "EA PAUSED because Max Lots is reached. Actual EA lots = " + tmp_str0005;
         PrintFormat(tmp_str0005);
      }
   } else {
      Ib_0535 = false;
   }
   func_1133();
   if (!IsTesting()) {
      if (Ii_057C == 1) {
         func_1117('');
      } else {
         func_1117('');
      }
   } else {
      func_1117('');
   }
   RefreshRates();
   Id_0058 = (MarketInfo(_Symbol, MODE_SPREAD) * Id_04B0);
   Gi_0027 = (int)MarketInfo(_Symbol, MODE_SPREAD);
   if (Gi_0027 > InpMaxSpread) {
      Is_04F8 = Is_04F8 + "Filter InpMaxSpread ON \n";
      Lb_FFFF = false;
   }
   func_1132(Lb_FFFF);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectDelete("butN4");
   ObjectDelete("butCAO");
   ObjectDelete("butCAP");
   ObjectDelete("butCAL");
   if (reason != 3) {
      ObjectDelete("butRange");
      ObjectDelete("SupRange");
      ObjectDelete("InfRange");
   }
   ObjectDelete("Market_Price_Label");
   ObjectDelete("Time_Label");
   ObjectDelete("TM");
   ObjectDelete("Porcent_Price_Label");
   ObjectDelete("Spread_Price_Label");
   ObjectDelete("Simbol_Price_Label");
   ObjectDelete("N4BG");
   ObjectDelete("butResDD");
   ObjectDelete("MaxFloatDD_Label");
   ObjectDelete("butMinEquity");
   ObjectDelete("MinEquity_Label");
   ChartSetInteger(0, 12, 1);
   ObjectsDeleteAll(0, 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
   if (sparam == "butCAO") {
      func_1116(1);
   }
   if (sparam == "butCAP") {
      func_1116(2);
   }
   if (sparam == "butCAL") {
      func_1116(3);
   }
   if (sparam == "butN4") {
      func_1116(4);
   }
   if (sparam == "butResDD") {
      func_1116(5);
   }
   if (sparam == "butMinEquity") {
      func_1116(6);
   }
   if (sparam != "butRange") return;
   func_1116(7);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester() {
   string tmp_str0000;
   double Ld_FFF8;

   func_1058(3);
   tmp_str0000 = Is_0518 + "MaxDD: ";
   tmp_str0000 = tmp_str0000 + DoubleToString(Id_0400, 2);
   PrintFormat(tmp_str0000);
   Ld_FFF8 = AccountEquity();
   return Ld_FFF8;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_1009(string &Fa_s_00[]) {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   bool Lb_FFFE;
   long Ll_FFF0;
   long Ll_FFE8;
   string Ls_FFD8;
   string Ls_FFC8;
   long Ll_FF58;
   int Li_FF54;
   int Li_FF50;
   int Li_FF4C;
   int Li_FF48;
   bool Lb_FFFF;

   Lb_FFFE = false;
   Ll_FFF0 = 0;
   Ll_FFE8 = 0;
   string Ls_FF94[];
   string Ls_FF60[];
   Ll_FF58 = TimeCurrent();
   Li_FF54 = TimeDayOfWeek(Time[0]) - 1;
   tmp_str0000 = ",";
   tmp_str0001 = Fa_s_00[Li_FF54];
   Gst_0003 = (short)StringGetCharacter(tmp_str0000, 0);
   Li_FF50 = StringSplit(tmp_str0001, Gst_0003, Ls_FF94);
   if (Li_FF50 > 0) {
      Li_FF4C = 0;
      if (Li_FF50 > 0) {
         do {
            tmp_str0002 = "-";
            tmp_str0003 = Ls_FF94[Li_FF4C];
            Gst_0005 = (short)StringGetCharacter(tmp_str0002, 0);
            Li_FF48 = StringSplit(tmp_str0003, Gst_0005, Ls_FF60);
            if (Li_FF48 == 1) {
               if (Li_FF4C == 0) {
                  Ls_FFD8 = "00:00";
                  Ls_FFC8 = Ls_FF60[0];
               } else {
                  Ls_FFD8 = Ls_FF60[0];
                  Ls_FFC8 = "23:59";
               }
            } else {
               if (Li_FF48 == 2) {
                  Ls_FFD8 = Ls_FF60[0];
                  Ls_FFC8 = Ls_FF60[1];
               }
            }
            tmp_str0004 = DoubleToString(Year(), 0);
            tmp_str0004 = tmp_str0004 + ".";
            tmp_str0004 = tmp_str0004 + DoubleToString(Month(), 0);
            tmp_str0004 = tmp_str0004 + ".";
            tmp_str0004 = tmp_str0004 + DoubleToString(Day(), 0);
            tmp_str0004 = tmp_str0004 + " ";
            tmp_str0004 = tmp_str0004 + Ls_FFD8;
            Ll_FFF0 = StringToTime(tmp_str0004);
            tmp_str0005 = DoubleToString(Year(), 0);
            tmp_str0005 = tmp_str0005 + ".";
            tmp_str0005 = tmp_str0005 + DoubleToString(Month(), 0);
            tmp_str0005 = tmp_str0005 + ".";
            tmp_str0005 = tmp_str0005 + DoubleToString(Day(), 0);
            tmp_str0005 = tmp_str0005 + " ";
            tmp_str0005 = tmp_str0005 + Ls_FFC8;
            Ll_FFE8 = StringToTime(tmp_str0005);
            if (Ll_FF58 >= Ll_FFF0 && Ll_FF58 < Ll_FFE8) {
               Lb_FFFE = true;
            }
            Li_FF4C = Li_FF4C + 1;
         } while (Li_FF4C < Li_FF50);
      }
   }
   Lb_FFFF = Lb_FFFE;
   ArrayFree(Ls_FF60);
   ArrayFree(Ls_FF94);
   return Lb_FFFE;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_1057() {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   double Ld_FFF0;
   bool Lb_FFFF;
   double Ld_FFE8;
   double Ld_FFE0;

   Gd_0000 = 0;
   Gi_0001 = OrdersTotal() - 1;
   Gi_0002 = Gi_0001;
   if (Gi_0001 >= 0) {
      do {
         Ii_054C = OrderSelect(Gi_0002, 0, 0);
         Gd_0001 = OrderProfit();
         Gd_0000 = ((Gd_0001 + OrderCommission()) + Gd_0000);
         Gi_0002 = Gi_0002 - 1;
      } while (Gi_0002 >= 0);
   }
   Ld_FFF0 = Gd_0000;
   if ((MaxFloatingDDMoney > 0) && (Gd_0000 < 0)) {
      Gd_0001 = -Gd_0000;
      if ((Gd_0001 > MaxFloatingDDMoney)) {
         tmp_str0000 = "STOP OUT because Max Floating DD Money is reached. Drawdown = " + DoubleToString(Gd_0000, 2);
         PrintFormat(tmp_str0000);
         Lb_FFFF = false;
         return Lb_FFFF;
      }
   }
   Ld_FFE8 = ((AccountBalance() * MaxFloatingDDPercent) / 100);
   if ((MaxFloatingDDPercent > 0) && (Ld_FFF0 < 0)) {
      Gd_0001 = -Ld_FFF0;
      if ((Gd_0001 > Ld_FFE8)) {
         tmp_str0001 = "STOP OUT because Max Floating DD Percent is reached. Drawdown = " + DoubleToString(Ld_FFF0, 2);
         PrintFormat(tmp_str0001);
         Lb_FFFF = false;
         return Lb_FFFF;
      }
   }
   if ((EquitySL > 0) && (AccountEquity() <= EquitySL)) {
      Gi_0001 = 0;
      Gi_0003 = OrdersTotal() - 1;
      Gi_0004 = Gi_0003;
      if (Gi_0003 >= 0) {
         do {
            if (OrderSelect(Gi_0004, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                           Gi_0001 = Gi_0001 + 1;
                        }
                     }
                  }
               }
            }
            Gi_0004 = Gi_0004 - 1;
         } while (Gi_0004 >= 0);
      }
      if (Gi_0001 > 0) {
         tmp_str0002 = "STOP OUT because Equity is lower than EquitySL. Actual Equity = " + DoubleToString(AccountEquity(), 2);
         PrintFormat(tmp_str0002);
      } else {
         tmp_str0003 = "EA is OFF because Equity is lower than EquitySL. Actual Equity = " + DoubleToString(AccountEquity(), 2);
         PrintFormat(tmp_str0003);
      }
      Lb_FFFF = false;
      return Lb_FFFF;
   }
   if ((AccountEquity() <= Id_03E0) && (MaxDailyDrawDown > 0)) {
      Gi_0003 = 0;
      Gi_0005 = OrdersTotal() - 1;
      Gi_0006 = Gi_0005;
      if (Gi_0005 >= 0) {
         do {
            if (OrderSelect(Gi_0006, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                           Gi_0003 = Gi_0003 + 1;
                        }
                     }
                  }
               }
            }
            Gi_0006 = Gi_0006 - 1;
         } while (Gi_0006 >= 0);
      }
      if (Gi_0003 > 0) {
         tmp_str0004 = "STOP OUT because Max Daily DD is reached. Actual Equity = " + DoubleToString(AccountEquity(), 2);
         PrintFormat(tmp_str0004);
      } else {
         tmp_str0005 = "EA is OFF until tomorrow because Max Daily DD was reached. Actual Equity = " + DoubleToString(AccountEquity(), 2);
         PrintFormat(tmp_str0005);
      }
      Lb_FFFF = false;
      return Lb_FFFF;
   }
   if ((MaxFloatingProfitMoney > 0) && (Ld_FFF0 > MaxFloatingProfitMoney)) {
      tmp_str0006 = "TAKE PROFIT because Max Floating Profit Money is reached. Actual Profit = " + DoubleToString(Ld_FFF0, 2);
      PrintFormat(tmp_str0006);
      Lb_FFFF = false;
      return Lb_FFFF;
   }
   Ld_FFE0 = ((AccountBalance() * MaxFloatingProfitPercent) / 100);
   if ((MaxFloatingProfitPercent > 0) && (Ld_FFF0 > Ld_FFE0)) {
      tmp_str0007 = "TAKE PROFIT because Max Floating Profit Percent is reached. Actual Profit = " + DoubleToString(Ld_FFF0, 2);
      tmp_str0007 = tmp_str0007 + " MaxFloating = ";
      tmp_str0007 = tmp_str0007 + DoubleToString(MaxFloatingProfitMoney, 2);
      PrintFormat(tmp_str0007);
      Lb_FFFF = false;
      return Lb_FFFF;
   }
   if ((EquityTP > 0) && (AccountEquity() >= EquityTP)) {
      Gi_0005 = 0;
      Gi_0007 = OrdersTotal() - 1;
      Gi_0008 = Gi_0007;
      if (Gi_0007 >= 0) {
         do {
            if (OrderSelect(Gi_0008, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                           Gi_0005 = Gi_0005 + 1;
                        }
                     }
                  }
               }
            }
            Gi_0008 = Gi_0008 - 1;
         } while (Gi_0008 >= 0);
      }
      if (Gi_0005 > 0) {
         tmp_str0008 = "TAKE PROFIT because Equity is higher than EquityTP. Actual Equity = " + DoubleToString(AccountEquity(), 2);
         PrintFormat(tmp_str0008);
      } else {
         tmp_str0009 = "EA is OFF because Equity is higher than EquityTP. Actual Equity = " + DoubleToString(AccountEquity(), 2);
         PrintFormat(tmp_str0009);
      }
      Lb_FFFF = false;
      return Lb_FFFF;
   }
   if ((AccountEquity() < Id_03E8)) return true;
   if ((DailyTarget <= 0)) return true;
   Gi_0007 = 0;
   Gi_0009 = OrdersTotal() - 1;
   Gi_000A = Gi_0009;
   if (Gi_0009 >= 0) {
      do {
         if (OrderSelect(Gi_000A, 0, 0) && OrderSymbol() == _Symbol) {
            if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

               if (OrderSymbol() == _Symbol) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                        Gi_0007 = Gi_0007 + 1;
                     }
                  }
               }
            }
         }
         Gi_000A = Gi_000A - 1;
      } while (Gi_000A >= 0);
   }
   if (Gi_0007 > 0) {
      tmp_str000A = "TAKE PROFIT because Daily Target is reached. Actual Equity = " + DoubleToString(AccountEquity(), 2);
      PrintFormat(tmp_str000A);
   } else {
      tmp_str000B = "EA is OFF until tomorrow because Daily Target was reached. Actual Equity = " + DoubleToString(AccountEquity(), 2);
      PrintFormat(tmp_str000B);
   }
   Lb_FFFF = false;
   return Lb_FFFF;

   Lb_FFFF = true;

   return Lb_FFFF;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1058(int Fa_i_00) {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   double Ld_FFF8;
   double Ld_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   string Ls_FFD8;

   if (PriceModeDD == 0) {
      Gd_0000 = MaxDailyDrawDown;
   } else {
      Gd_0000 = ((AccountEquity() * MaxDailyDrawDown) / 100);
   }
   Ld_FFF8 = Gd_0000;
   if (PriceModeTP == 0) {
      Gd_0000 = DailyTarget;
   } else {
      Gd_0000 = ((AccountEquity() * DailyTarget) / 100);
   }
   Ld_FFF0 = Gd_0000;
   if ((Id_03F8 > Id_0400)) {
      Id_0400 = Id_03F8;
   }
   Id_0410 = (AccountEquity() - Id_03F0);
   Li_FFEC = TimeDay(TimeCurrent());
   Li_FFE8 = TimeDayOfWeek(TimeCurrent());
   if (Fa_i_00 != 3) {
      if (Li_FFE8 == 1) {
         Li_FFEC = Li_FFEC - 3;
      } else {
         Li_FFEC = Li_FFEC - 1;
      }
   }
   tmp_str0000 = (string)Li_FFEC;
   tmp_str0000 = "\n" + tmp_str0000;
   tmp_str0000 = tmp_str0000 + "/";
   tmp_str0001 = (string)TimeMonth(TimeCurrent());
   tmp_str0000 = tmp_str0000 + tmp_str0001;
   tmp_str0000 = tmp_str0000 + "/";
   tmp_str0001 = (string)TimeYear(TimeCurrent());
   tmp_str0000 = tmp_str0000 + tmp_str0001;
   tmp_str0000 = tmp_str0000 + " ==> ";
   tmp_str0000 = tmp_str0000 + DoubleToString(Id_0410, 2);
   tmp_str0000 = tmp_str0000 + " -> ";
   tmp_str0000 = tmp_str0000 + DoubleToString(Id_0408, 2);
   tmp_str0000 = tmp_str0000 + " TP - ";
   tmp_str0000 = tmp_str0000 + DoubleToString(Id_03F8, 2);
   tmp_str0000 = tmp_str0000 + " DD";
   Ls_FFD8 = tmp_str0000;
   if (Fa_i_00 == 0) {
      tmp_str0001 = "\n\nBalance Inicial: " + DoubleToString(AccountBalance(), 2);
      tmp_str0001 = tmp_str0001 + "\n";
      Is_0518 = tmp_str0001;
   } else {
      if (Fa_i_00 == 2) {
         PrintFormat(Ls_FFD8);
         Is_0518 = Is_0518 + Ls_FFD8;
      } else {
         if (Fa_i_00 == 3) {
            if (TimeDayOfWeek(TimeCurrent()) == 0) {
               Li_FFEC = Li_FFEC - 2;
            }
            if (TimeDayOfWeek(TimeCurrent()) == 6) {
               Li_FFEC = Li_FFEC - 1;
            }
            Is_0518 = Is_0518 + Ls_FFD8;
            tmp_str0001 = "\n\nBalance Final: " + DoubleToString(AccountBalance(), 2);
            tmp_str0001 = tmp_str0001 + " - ";
            Is_0518 = Is_0518 + tmp_str0001;
         }
      }
   }
   if (Fa_i_00 == 2) {
      Id_0410 = 0;
      Id_0408 = 0;
      Id_03F8 = 0;
      returned_double = AccountEquity();
      Id_03F0 = returned_double;
      Id_03E0 = (Id_03F0 - Ld_FFF8);
      Id_03E8 = (returned_double + Ld_FFF0);
      tmp_str0001 = "Actual Equity: " + DoubleToString(AccountEquity(), 2);
      PrintFormat(tmp_str0001);
      tmp_str0002 = "min Equity: " + DoubleToString(Id_03E0, 2);
      PrintFormat(tmp_str0002);
      tmp_str0003 = "max Equity: " + DoubleToString(Id_03E8, 2);
      PrintFormat(tmp_str0003);
      tmp_str0004 = "MaxDD: " + DoubleToString(Id_0400, 2);
      PrintFormat(tmp_str0004);
   }
   Ib_0534 = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1059() {
   if (Action == 0) {
      PrintFormat("Equity Protection -> Closing all trades");
      Gi_0000 = OrdersTotal() - 1;
      Gi_0001 = Gi_0000;
      if (Gi_0000 >= 0) {
         do {
            if (OrderSelect(Gi_0001, 0, 0)) {
               if (OrderType() == OP_BUY) {
                  Gd_0000 = NormalizeDouble(Bid, _Digits);
               } else {
                  Gd_0000 = NormalizeDouble(Ask, _Digits);
               }
               if (OrderClose(OrderTicket(), OrderLots(), Gd_0000, Ii_0020, 255) != true) {
                  Print("OrderClose Error N", GetLastError());
               }
            }
            Gi_0001 = Gi_0001 - 1;
         } while (Gi_0001 >= 0);
      }
   } else {
      if (Action == 1) {
         PrintFormat("Equity Protection -> Closing only this symbol trades");
         Gi_0003 = OrdersTotal() - 1;
         Gi_0004 = Gi_0003;
         if (Gi_0003 >= 0) {
            do {
               if (OrderSelect(Gi_0004, 0, 0) && OrderSymbol() == _Symbol) {
                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_BUY) {
                           order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
                        }
                        if (OrderType() == OP_SELL) {
                           order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
                        }
                     }
                  }
                  Sleep(1000);
               }
               Gi_0004 = Gi_0004 - 1;
            } while (Gi_0004 >= 0);
         }
      } else {
         if (Action == 2) {
            PrintFormat("Equity Protection -> Closing trades opened by the EA");
            Gi_0008 = OrdersTotal() - 1;
            Gi_0009 = Gi_0008;
            if (Gi_0008 >= 0) {
               do {
                  if (OrderSelect(Gi_0009, 0, 0)) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_BUY) {
                           Gd_0008 = NormalizeDouble(Bid, _Digits);
                        } else {
                           Gd_0008 = NormalizeDouble(Ask, _Digits);
                        }
                        if (OrderClose(OrderTicket(), OrderLots(), Gd_0008, Ii_0020, 255) != true) {
                           Print(" OrderClose Error N", GetLastError());
                        }
                     }
                  }
                  Gi_0009 = Gi_0009 - 1;
               } while (Gi_0009 >= 0);
            }
         }
      }
   }
   if (CloseTerminal) {
      PostMessageA(GetParent(GetParent(GetParent(WindowHandle(_Symbol, _Period)))), 16, 0, 0);
   }
   if (CloseChart) {
      ChartClose(0);
   }
   if (AutoTradeOFF == false) return;
   Gi_000B = GetAncestor(WindowHandle(_Symbol, _Period), 2);
   if (Gi_000B != 0) {
      if (TerminalInfoInteger(8) != 0) {
         PostMessageA(Gi_000B, 273, 33020, 0);
         Print("AutoTrading disabled");
         return ;
      }
      Print("AutoTrading already disabled");
      return ;
   }
   Print("GetAncestor error: ", GetLastError());

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1060() {
   if (NewsAction == 1) {
      PrintFormat("News Filter -> Closing all trades");
      Gi_0000 = OrdersTotal() - 1;
      Gi_0001 = Gi_0000;
      if (Gi_0000 < 0) return;
      do {
         if (OrderSelect(Gi_0001, 0, 0)) {
            if (OrderType() == OP_BUY) {
               Gd_0000 = NormalizeDouble(Bid, _Digits);
            } else {
               Gd_0000 = NormalizeDouble(Ask, _Digits);
            }
            if (OrderClose(OrderTicket(), OrderLots(), Gd_0000, Ii_0020, 255) != true) {
               Print("OrderClose Error N", GetLastError());
            }
         }
         Gi_0001 = Gi_0001 - 1;
      } while (Gi_0001 >= 0);
      return ;
   }
   if (NewsAction == 2) {
      PrintFormat("News Filter -> Closing only this symbol trades");
      Gi_0003 = OrdersTotal() - 1;
      Gi_0004 = Gi_0003;
      if (Gi_0003 < 0) return;
      do {
         if (OrderSelect(Gi_0004, 0, 0) && OrderSymbol() == _Symbol) {
            if (OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if (OrderType() == OP_BUY) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
                  }
                  if (OrderType() == OP_SELL) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
                  }
               }
            }
            Sleep(1000);
         }
         Gi_0004 = Gi_0004 - 1;
      } while (Gi_0004 >= 0);
      return ;
   }
   if (NewsAction == 3) {
      PrintFormat("News Filter -> Closing trades opened by the EA");
      Gi_0008 = OrdersTotal() - 1;
      Gi_0009 = Gi_0008;
      if (Gi_0008 < 0) return;
      do {
         if (OrderSelect(Gi_0009, 0, 0)) {
            if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

               if (OrderType() == OP_BUY) {
                  Gd_0008 = NormalizeDouble(Bid, _Digits);
               } else {
                  Gd_0008 = NormalizeDouble(Ask, _Digits);
               }
               if (OrderClose(OrderTicket(), OrderLots(), Gd_0008, Ii_0020, 255) != true) {
                  Print(" OrderClose Error N", GetLastError());
               }
            }
         }
         Gi_0009 = Gi_0009 - 1;
      } while (Gi_0009 >= 0);
      return ;
   }
   if (NewsAction != 0) return;
   PrintFormat("News Filter ON but settings configured to not close trades");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int func_1063(int Fa_i_00, double Fa_d_01, double Fa_d_02, int Fa_i_03, string arg4, double Fa_d_05, double Fa_d_06) {
   string tmp_str0000;
   double Ld_FFF0;
   int Li_FFFC;

   Ld_FFF0 = 0;
   if (Fa_i_00 == 0) {
      Gi_0000 = 1;
      Gi_0001 = 0;
      Gi_0002 = OrdersTotal() - 1;
      Gi_0003 = Gi_0002;
      if (Gi_0002 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_0003, 0, 0);
            if (OrderSymbol() == _Symbol && OrderType() == OP_BUY) {
               Gi_0001 = Gi_0001 + 1;
            }
            Gi_0003 = Gi_0003 - 1;
         } while (Gi_0003 >= 0);
      }
      if (Gi_0001 == 0) {
         if ((GSL == 0)) {
            Gd_0004 = GSL;
         } else {
            Gd_0005 = ((GSL * _Point) * 10);
            Gd_0004 = (Ask - Gd_0005);
         }
         Ld_FFF0 = Gd_0004;
         Id_03D0 = Gd_0004;
      } else {
         Gi_0005 = 1;
         Gd_0006 = 0;
         Gi_0007 = OrdersTotal() - 1;
         if (Gi_0007 >= 0) {
            order_check = OrderSelect(Gi_0007, 0, 0);
            if (OrderSymbol() == _Symbol && OrderType() == OP_BUY && (OrderStopLoss() > 0)) {
               Gd_0006 = OrderStopLoss();
            }
         }
         if (Gi_0005 == 2) {
            Gi_0007 = OrdersTotal() - 1;
            if (Gi_0007 >= 0) {
               order_check = OrderSelect(Gi_0007, 0, 0);
               if (OrderSymbol() == _Symbol && OrderType() == OP_SELL && (OrderStopLoss() > 0)) {
                  Gd_0006 = OrderStopLoss();
               }
            }
         }
         Ld_FFF0 = Gd_0006;
         if ((GSL != 0) && (Gd_0006 == 0)) {
            Gd_0007 = ((GSL * _Point) * 10);
            Ld_FFF0 = (Ask - Gd_0007);
         }
      }
   }
   if (Fa_i_00 == 1) {
      Gi_0007 = 2;
      Gi_0008 = 0;
      Gi_0009 = OrdersTotal() - 1;
      Gi_000A = Gi_0009;
      if (Gi_0009 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_000A, 0, 0);
            if (OrderSymbol() == _Symbol && OrderType() == OP_SELL) {
               Gi_0008 = Gi_0008 + 1;
            }
            Gi_000A = Gi_000A - 1;
         } while (Gi_000A >= 0);
      }
      if (Gi_0008 == 0) {
         if ((GSL == 0)) {
            Gd_000B = GSL;
         } else {
            Gd_000B = (((GSL * _Point) * 10) + Bid);
         }
         Ld_FFF0 = Gd_000B;
         Id_03D8 = Gd_000B;
      } else {
         Gd_000B = 0;
         Gi_000C = OrdersTotal() - 1;
         if (Gi_000C >= 0) {
            order_check = OrderSelect(Gi_000C, 0, 0);
            if (OrderSymbol() == _Symbol && OrderType() == OP_SELL && (OrderStopLoss() > 0)) {
               Gd_000B = OrderStopLoss();
            }
         }
         Ld_FFF0 = Gd_000B;
         if ((GSL != 0) && (Gd_000B == 0)) {
            Ld_FFF0 = (((GSL * _Point) * 10) + Bid);
         }
      }
   }
   tmp_str0000 = "Order Send: Price = " + DoubleToString(Fa_d_02, 4);
   tmp_str0000 = tmp_str0000 + " GSL = ";
   tmp_str0000 = tmp_str0000 + DoubleToString(GSL, 4);
   tmp_str0000 = tmp_str0000 + "  STOP = ";
   tmp_str0000 = tmp_str0000 + DoubleToString(Ld_FFF0, 4);
   Print(tmp_str0000);
   Li_FFFC = OrderSend(Is_04E8, Fa_i_00, Fa_d_01, Fa_d_02, Ii_0020, Ld_FFF0, Fa_d_06, " ", Fa_i_03, 0, 4294967295);
   return Li_FFFC;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1088(int Fa_i_00, int Fa_i_01, double Fa_d_02, int Fa_i_03) {
   string tmp_str0000;
   string tmp_str0001;
   int Li_FFFC;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   bool Lb_FFDF;
   int Li_FFD8;

   Li_FFFC = 0;
   Gi_0000 = _Digits - 1;
   returned_double = MathPow(10, Gi_0000);
   Ld_FFF0 = ((double)1 / returned_double);
   if (_Digits == 3 || _Digits == 5) {

      Gi_0000 = _Digits - 1;
      returned_double = MathPow(10, Gi_0000);
      Ld_FFF0 = ((double)1 / returned_double);
   } else {
      Ld_FFF0 = _Point;
   }
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Lb_FFDF = false;
   if (Fa_i_01 == 0) return;
   Li_FFD8 = OrdersTotal() - 1;
   if (Li_FFD8 < 0) return;
   do {
      if (OrderSelect(Li_FFD8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Fa_i_03) {
         if (OrderSymbol() == _Symbol || OrderMagicNumber() == Fa_i_03) {

            if (OrderType() == OP_BUY) {
               Gd_0000 = (Bid - Fa_d_02);
               Li_FFFC = (int)NormalizeDouble((Gd_0000 / _Point), 0);
               Gd_0000 = (Fa_i_00 * Ld_FFF0);
               if (Li_FFFC >= Gd_0000) {
                  Ld_FFE8 = OrderStopLoss();
                  Gd_0000 = (Fa_i_01 * Ld_FFF0);
                  Ld_FFE0 = (Bid - Gd_0000);
                  Gd_0000 = Ld_FFE0;
                  Gd_0001 = Bid;
                  Gi_0002 = 0;
                  Gd_0003 = 0;
                  Gd_0004 = 0;
                  Gd_0004 = MarketInfo(_Symbol, MODE_STOPLEVEL);
                  if (_Digits == 3 || _Digits == 5) {

                     Gd_0004 = (Gd_0004 / 10);
                  }
                  Gd_0003 = Gd_0000;
                  if (Gi_0002 == 0) {
                     Gd_0005 = (Gd_0001 - Gd_0000);
                     if ((Gd_0005 < (Gd_0004 * _Point))) {
                        Gd_0003 = 0;
                     }
                  }
                  if (Gi_0002 == 1) {
                     Gd_0005 = (Gd_0003 - Gd_0001);
                     if ((Gd_0005 < (Gd_0004 * _Point))) {
                        Gd_0003 = 0;
                     }
                  }
                  returned_double = NormalizeDouble(Gd_0003, (int)MarketInfo(_Symbol, MODE_DIGITS));
                  Ld_FFE0 = returned_double;
                  if (Ld_FFE8 == 0 || (Ld_FFE8 != 0 && returned_double > Ld_FFE8)) {

                     OrderTicket();
                     if (OrdersTotal() > 0 && (Fa_d_02 < Ld_FFE0)) {
                        Lb_FFDF = OrderModify(OrderTicket(), Fa_d_02, Ld_FFE0, OrderTakeProfit(), 0, 16776960);
                        if (Lb_FFDF != true) {
                           tmp_str0000 = "Normal";
                           Gi_0006 = GetLastError();
                           if (Gi_0006 != 1 && Gi_0006 != 130) {
                              Print(tmp_str0000, ": Ordem: ", OrderTicket(), ". Falha ao tentar alterar ordem: ", Gi_0006, " ");
                           }
                        }
                     }
                  }
               }
            }
            if (OrderType() == OP_SELL) {
               Gd_0007 = (Fa_d_02 - Ask);
               Li_FFFC = (int)NormalizeDouble((Gd_0007 / _Point), 0);
               Gd_0007 = (Fa_i_00 * Ld_FFF0);
               if (Li_FFFC >= Gd_0007) {
                  Ld_FFE8 = OrderStopLoss();
                  Ld_FFE0 = ((Fa_i_01 * Ld_FFF0) + Ask);
                  Gd_0007 = Ld_FFE0;
                  Gd_0008 = Ask;
                  Gi_0009 = 1;
                  Gd_000A = 0;
                  Gd_000B = 0;
                  Gd_000B = MarketInfo(_Symbol, MODE_STOPLEVEL);
                  if (_Digits == 3 || _Digits == 5) {

                     Gd_000B = (Gd_000B / 10);
                  }
                  Gd_000A = Gd_0007;
                  if (Gi_0009 == 0) {
                     Gd_000C = (Gd_0008 - Gd_0007);
                     if ((Gd_000C < (Gd_000B * _Point))) {
                        Gd_000A = 0;
                     }
                  }
                  if (Gi_0009 == 1) {
                     Gd_000C = (Gd_000A - Gd_0008);
                     if ((Gd_000C < (Gd_000B * _Point))) {
                        Gd_000A = 0;
                     }
                  }
                  returned_double = NormalizeDouble(Gd_000A, (int)MarketInfo(_Symbol, MODE_DIGITS));
                  Ld_FFE0 = returned_double;
                  if (Ld_FFE8 == 0 || (Ld_FFE8 != 0 && returned_double < Ld_FFE8)) {

                     OrderTicket();
                     if (OrdersTotal() > 0 && (Fa_d_02 > Ld_FFE0)) {
                        Lb_FFDF = OrderModify(OrderTicket(), Fa_d_02, Ld_FFE0, OrderTakeProfit(), 0, 255);
                        if (Lb_FFDF != true) {
                           tmp_str0001 = "Normal";
                           Gi_000D = GetLastError();
                           if (Gi_000D != 1 && Gi_000D != 130) {
                              Print(tmp_str0001, ": Ordem: ", OrderTicket(), ". Falha ao tentar alterar ordem: ", Gi_000D, " ");
                           }
                        }
                     }
                  }
               }
            }
         }
         Sleep(1000);
      }
      Li_FFD8 = Li_FFD8 - 1;
   } while (Li_FFD8 >= 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_1095() {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   bool Lb_FFFE;
   int Li_FFF8;
   bool Lb_FFFF;

   Lb_FFFE = false;
   Gl_0000 = TimeCurrent() - Il_C148;
   Gl_0001 = Ii_0584;
   if (Gl_0000 >= Gl_0001) {
      Comment("News Loading...");
      Print("News Loading...");
      func_1101();
      Il_C148 = TimeCurrent();
   }
   WindowRedraw();
   func_1096();
   Li_FFF8 = 0;
   if (Ii_0580 <= 0) return Lb_FFFE;
   do {
      tmp_str0000 = Is_05C8[2, Li_FFF8];
      if (NewsHard && StringFind(tmp_str0000, "High", 0) >= 0) {
         Gb_0002 = true;
      } else {
         if (NewsMedium && StringFind(tmp_str0000, "Moderate", 0) >= 0) {
            Gb_0002 = true;
         } else {
            if (NewsLight && StringFind(tmp_str0000, "Low", 0) >= 0) {
               Gb_0002 = true;
            } else {
               Gb_0002 = false;
            }
         }
      }
      if (Gb_0002) {
         Gi_0003 = Li_FFF8;
         tmp_str0001 = Is_05C8[0, Li_FFF8];
         tmp_str0003 = StringSubstr(tmp_str0001, 14, 4);
         tmp_str0004 = StringSubstr(tmp_str0001, 11, 2);
         tmp_str0005 = StringSubstr(tmp_str0001, 8, 2);
         tmp_str0006 = StringSubstr(tmp_str0001, 5, 2);
         tmp_str0007 = StringSubstr(tmp_str0001, 0, 4);
         tmp_str0002 = StringConcatenate(tmp_str0007, ".", tmp_str0006, ".", tmp_str0005, " ", tmp_str0004, ":", tmp_str0003);
         Gl_0005 = StringToTime(tmp_str0002);
         Gi_0006 = offset * 3600;
         Gl_0006 = Gi_0006;
         Gl_0006 = Gl_0005 + Gl_0006;

         Gl_0008 = TimeCurrent();
         Gi_0009 = AfterNewsStop * 60;
         Gl_0009 = Gi_0009;
         Gl_0009 = Gl_0008 - Gl_0009;
         if (TimeCurrent() + BeforeNewsStop * 60 > Gl_0006
               && Gl_0009 < Gl_0006) {
            Gb_0009 = true;
         } else {
            Gb_0009 = false;
         }
         if (Gb_0009) {
            tmp_str0008 = Is_05C8[1, Li_FFF8];
            if (StringFind(Is_0588, tmp_str0008, 0) >= 0) {
               Gb_000B = true;
            } else {
               Gb_000B = false;
            }
            if (Gb_000B) {
               Lb_FFFE = true;
               return Lb_FFFE;
            }
         }
      }
      Li_FFF8 = Li_FFF8 + 1;
   } while (Li_FFF8 < Ii_0580);

   Lb_FFFF = Lb_FFFE;
   return Lb_FFFE;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1096() {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   int Li_FFFC;
   string Ls_FFF0;
   int Li_FFEC;

   if (DrawLines == false) return;
   Li_FFFC = 0;
   if (Ii_0580 <= 0) return;
   do {
      Gi_0000 = Li_FFFC;
      tmp_str0000 = Is_05C8[0, Li_FFFC];
      tmp_str0002 = StringSubstr(tmp_str0000, 14, 4);
      tmp_str0003 = StringSubstr(tmp_str0000, 11, 2);
      tmp_str0004 = StringSubstr(tmp_str0000, 8, 2);
      tmp_str0005 = StringSubstr(tmp_str0000, 5, 2);
      tmp_str0006 = StringSubstr(tmp_str0000, 0, 4);
      tmp_str0001 = StringConcatenate(tmp_str0006, ".", tmp_str0005, ".", tmp_str0004, " ", tmp_str0003, ":", tmp_str0002);
      Gl_0002 = StringToTime(tmp_str0001);
      Gi_0003 = offset * 3600;
      Gl_0003 = Gi_0003;
      tmp_str0007 = TimeToString((Gl_0002 + Gl_0003), 2);
      tmp_str0007 = tmp_str0007 + "_";
      tmp_str0007 = tmp_str0007 + Is_05C8[1, Li_FFFC];
      tmp_str0007 = tmp_str0007 + "_";
      tmp_str0007 = tmp_str0007 + Is_05C8[3, Li_FFFC];
      Ls_FFF0 = StringSubstr(tmp_str0007, 0, 63);
      if (Is_05C8[3, Li_FFFC] != "" && ObjectFind(Ls_FFF0) == 0) {
      } else {
         if (StringFind(Is_0588, Is_05C8[1, Li_FFFC], 0) < 0) {
         } else {
            Gi_0007 = Li_FFFC;
            tmp_str0008 = Is_05C8[0, Li_FFFC];
            tmp_str000A = StringSubstr(tmp_str0008, 14, 4);
            tmp_str000B = StringSubstr(tmp_str0008, 11, 2);
            tmp_str000C = StringSubstr(tmp_str0008, 8, 2);
            tmp_str000D = StringSubstr(tmp_str0008, 5, 2);
            tmp_str000E = StringSubstr(tmp_str0008, 0, 4);
            tmp_str0009 = StringConcatenate(tmp_str000E, ".", tmp_str000D, ".", tmp_str000C, " ", tmp_str000B, ":", tmp_str000A);
            Gl_0009 = StringToTime(tmp_str0009);
            Gi_000A = offset * 3600;
            Gl_000A = Gi_000A;
            Gl_000A = Gl_0009 + Gl_000A;
            if (Gl_000A < TimeCurrent() && HidePast) {
            } else {
               Li_FFEC = (int)4294967295;
               if (NewsHard && StringFind(Is_05C8[2, Li_FFFC], "High", 0) >= 0) {
                  Li_FFEC = 255;
               }
               if (NewsMedium && StringFind(Is_05C8[2, Li_FFFC], "Moderate", 0) >= 0) {
                  Li_FFEC = 65535;
               }
               if (NewsLight && StringFind(Is_05C8[2, Li_FFFC], "Low", 0) >= 0) {
                  Li_FFEC = 32768;
               }
               if (Li_FFEC == (int)4294967295) {
               } else {
                  if (Is_05C8[3, Li_FFFC] != "") {
                     Gi_000E = Li_FFFC;
                     tmp_str000F = Is_05C8[0, Li_FFFC];
                     tmp_str0011 = StringSubstr(tmp_str000F, 14, 4);
                     tmp_str0012 = StringSubstr(tmp_str000F, 11, 2);
                     tmp_str0013 = StringSubstr(tmp_str000F, 8, 2);
                     tmp_str0014 = StringSubstr(tmp_str000F, 5, 2);
                     tmp_str0015 = StringSubstr(tmp_str000F, 0, 4);
                     tmp_str0010 = StringConcatenate(tmp_str0015, ".", tmp_str0014, ".", tmp_str0013, " ", tmp_str0012, ":", tmp_str0011);
                     Gl_0010 = StringToTime(tmp_str0010);
                     Gi_0011 = offset * 3600;
                     Gl_0011 = Gi_0011;
                     ObjectCreate(0, Ls_FFF0, OBJ_VLINE, 0, (Gl_0010 + Gl_0011), 0, 0, 0, 0, 0);
                     ObjectSet(Ls_FFF0, OBJPROP_COLOR, Li_FFEC);
                     ObjectSet(Ls_FFF0, OBJPROP_STYLE, 2);
                     ObjectSetInteger(0, Ls_FFF0, 9, 1);
                  }
               }
            }
         }
      }
      Li_FFFC = Li_FFFC + 1;
   } while (Li_FFFC < Ii_0580);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1101() {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string Ls_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   int Li_FFE4;

   tmp_str0001 = NULL;
   tmp_str0002 = "";
   tmp_str0003 = "https://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
   char Lc_FFB0[];
   char Lc_FF7C[];
   if (WebRequest("GET", tmp_str0003, tmp_str0001, NULL, 5000, Lc_FFB0, 0, Lc_FF7C, tmp_str0000) == -1) {
      Print("WebRequest error, err.code  =", GetLastError());
      tmp_str0004 = "You must add the address ' https://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
      tmp_str0004 = "You must add the address ' https://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1' in the list of allowed URL tab 'Advisors' ";
      MessageBox(tmp_str0004, " Error ", 64);
   } else {
      PrintFormat("File successfully downloaded, the file size in bytes  =%d.", ArraySize(Lc_FF7C));
      Gi_0000 = FileOpen("news-log.html", 6);
      if (Gi_0000 != -1) {
         FileWriteArray(Gi_0000, Lc_FF7C, 0, ArraySize(Lc_FF7C));
         FileClose(Gi_0000);
         Gi_0001 = FileOpen("news-log.html", 5);
         tmp_str0002 = FileReadString(Gi_0001, ArraySize(Lc_FF7C));
         FileClose(Gi_0001);
      } else {
         Print("Error in FileOpen. Error code =", GetLastError());
      }
   }
   ArrayFree(Lc_FF7C);
   ArrayFree(Lc_FFB0);
   Ls_FFF0 = tmp_str0002;
   Li_FFEC = StringFind(Ls_FFF0, "pageStartAt>", 0) + 12;
   Li_FFE8 = StringFind(Ls_FFF0, "</tbody>", 0);
   Ls_FFF0 = StringSubstr(Ls_FFF0, Li_FFEC, (Li_FFE8 - Li_FFEC));
   Li_FFEC = 0;
   if (_StopFlag != 0) return;
   do {
      Li_FFEC = StringFind(Ls_FFF0, "event_timestamp", Li_FFEC) + 17;
      Li_FFE8 = StringFind(Ls_FFF0, "onclick", Li_FFEC) - 2;
      if (Li_FFEC < 17) return;
      if (Li_FFE8 < 0) return;
      Is_05C8[0, Ii_0580] = StringSubstr(Ls_FFF0, Li_FFEC, (Li_FFE8 - Li_FFEC));
      Li_FFEC = StringFind(Ls_FFF0, "flagCur", Li_FFEC) + 10;
      Li_FFE8 = Li_FFEC + 3;
      if (Li_FFEC < 10) return;
      if (Li_FFE8 < 3) return;
      Is_05C8[1, Ii_0580] = StringSubstr(Ls_FFF0, Li_FFEC, (Li_FFE8 - Li_FFEC));
      if (StringFind(Is_0588, Is_05C8[1, Ii_0580], 0) >= 0) {
         Li_FFEC = StringFind(Ls_FFF0, "title", Li_FFEC) + 7;
         Li_FFE8 = StringFind(Ls_FFF0, "Volatility", Li_FFEC) - 1;
         if (Li_FFEC < 7) return;
         if (Li_FFE8 < 0) return;
         Is_05C8[2, Ii_0580] = StringSubstr(Ls_FFF0, Li_FFEC, (Li_FFE8 - Li_FFEC));
         if (StringFind(Is_05C8[2, Ii_0580], "High", 0) < 0
               || NewsHard != false) {

            if (StringFind(Is_05C8[2, Ii_0580], "Moderate", 0) < 0
                  || NewsMedium != false) {

               if (StringFind(Is_05C8[2, Ii_0580], "Low", 0) < 0 || NewsLight) {

                  Li_FFEC = StringFind(Ls_FFF0, "left event", Li_FFEC) + 12;
                  Li_FFE4 = StringFind(Ls_FFF0, "Speaks", Li_FFEC);
                  Li_FFE8 = StringFind(Ls_FFF0, "<", Li_FFEC);
                  if (Li_FFEC < 12) return;
                  if (Li_FFE8 < 0) return;
                  if (Li_FFE4 < 0 || Li_FFE4 > Li_FFE8) {

                     Is_05C8[3, Ii_0580] = StringSubstr(Ls_FFF0, Li_FFEC, (Li_FFE8 - Li_FFEC));
                  } else {
                     Is_05C8[3, Ii_0580] = StringSubstr(Ls_FFF0, Li_FFEC, (Li_FFE4 - Li_FFEC));
                  }
                  Ii_0580 = Ii_0580 + 1;
                  if (Ii_0580 == 300) return;
               }
            }
         }
      }
   } while (_StopFlag == 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1110(int Fa_i_00, int Fa_i_01, double Fa_d_02, int Fa_i_03) {
   string tmp_str0000;
   string tmp_str0001;
   int Li_FFFC;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   bool Lb_FFDF;
   int Li_FFD8;

   Li_FFFC = 0;
   Gi_0000 = _Digits - 1;
   returned_double = MathPow(10, Gi_0000);
   Ld_FFF0 = ((double)1 / returned_double);
   if (_Digits == 3 || _Digits == 5) {

      Gi_0000 = _Digits - 1;
      returned_double = MathPow(10, Gi_0000);
      Ld_FFF0 = ((double)1 / returned_double);
   } else {
      Ld_FFF0 = _Point;
   }
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Lb_FFDF = false;
   if (Fa_i_00 == 0) return;
   Li_FFD8 = OrdersTotal() - 1;
   if (Li_FFD8 < 0) return;
   do {
      if (OrderSelect(Li_FFD8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Fa_i_03) {
         if (OrderSymbol() == _Symbol || OrderMagicNumber() == Fa_i_03) {

            if (OrderType() == OP_BUY) {
               Gd_0000 = (Bid - Fa_d_02);
               Li_FFFC = (int)NormalizeDouble((Gd_0000 / _Point), 0);
               Gd_0000 = (Fa_i_00 * Ld_FFF0);
               if (Li_FFFC > Gd_0000) {
                  Ld_FFE8 = OrderStopLoss();
                  Ld_FFE0 = ((Fa_i_01 * Ld_FFF0) + Fa_d_02);
                  Gd_0000 = Ld_FFE0;
                  Gd_0001 = Bid;
                  Gi_0002 = 0;
                  Gd_0003 = 0;
                  Gd_0004 = 0;
                  Gd_0004 = MarketInfo(_Symbol, MODE_STOPLEVEL);
                  if (_Digits == 3 || _Digits == 5) {

                     Gd_0004 = (Gd_0004 / 10);
                  }
                  Gd_0003 = Gd_0000;
                  if (Gi_0002 == 0) {
                     Gd_0005 = (Gd_0001 - Gd_0000);
                     if ((Gd_0005 < (Gd_0004 * _Point))) {
                        Gd_0003 = 0;
                     }
                  }
                  if (Gi_0002 == 1) {
                     Gd_0005 = (Gd_0003 - Gd_0001);
                     if ((Gd_0005 < (Gd_0004 * _Point))) {
                        Gd_0003 = 0;
                     }
                  }
                  returned_double = NormalizeDouble(Gd_0003, (int)MarketInfo(_Symbol, MODE_DIGITS));
                  Ld_FFE0 = returned_double;
                  if ((Bid >= ((Fa_i_01 * Ld_FFF0) + Fa_d_02))) {
                     if (Ld_FFE8 == 0 || (Ld_FFE8 != 0 && returned_double > Ld_FFE8)) {

                        OrderTicket();
                        if (OrdersTotal() > 0) {
                           Lb_FFDF = OrderModify(OrderTicket(), Fa_d_02, Ld_FFE0, OrderTakeProfit(), 0, 16776960);
                           if (Lb_FFDF != true) {
                              tmp_str0000 = "Normal";
                              Gi_0006 = GetLastError();
                              if (Gi_0006 != 1 && Gi_0006 != 130) {
                                 Print(tmp_str0000, ": Ordem: ", OrderTicket(), ". Falha ao tentar alterar ordem: ", Gi_0006, " ");
                              }
                           }
                        }
                     }
                  }
               }
            }
            if (OrderType() == OP_SELL) {
               Gd_0007 = (Fa_d_02 - Ask);
               Li_FFFC = (int)NormalizeDouble((Gd_0007 / _Point), 0);
               Gd_0007 = (Fa_i_00 * Ld_FFF0);
               if (Li_FFFC > Gd_0007) {
                  Ld_FFE8 = OrderStopLoss();
                  Gd_0007 = (Fa_i_01 * Ld_FFF0);
                  Ld_FFE0 = (Fa_d_02 - Gd_0007);
                  Gd_0007 = Ld_FFE0;
                  Gd_0008 = Ask;
                  Gi_0009 = 1;
                  Gd_000A = 0;
                  Gd_000B = 0;
                  Gd_000B = MarketInfo(_Symbol, MODE_STOPLEVEL);
                  if (_Digits == 3 || _Digits == 5) {

                     Gd_000B = (Gd_000B / 10);
                  }
                  Gd_000A = Gd_0007;
                  if (Gi_0009 == 0) {
                     Gd_000C = (Gd_0008 - Gd_0007);
                     if ((Gd_000C < (Gd_000B * _Point))) {
                        Gd_000A = 0;
                     }
                  }
                  if (Gi_0009 == 1) {
                     Gd_000C = (Gd_000A - Gd_0008);
                     if ((Gd_000C < (Gd_000B * _Point))) {
                        Gd_000A = 0;
                     }
                  }
                  returned_double = NormalizeDouble(Gd_000A, (int)MarketInfo(_Symbol, MODE_DIGITS));
                  Ld_FFE0 = returned_double;
                  Gd_000C = (Fa_i_01 * Ld_FFF0);
                  if ((Ask <= (Fa_d_02 - Gd_000C))) {
                     if (Ld_FFE8 == 0 || (Ld_FFE8 != 0 && returned_double < Ld_FFE8)) {

                        OrderTicket();
                        if (OrdersTotal() > 0) {
                           Lb_FFDF = OrderModify(OrderTicket(), Fa_d_02, Ld_FFE0, OrderTakeProfit(), 0, 255);
                           if (Lb_FFDF != true) {
                              tmp_str0001 = "Normal";
                              Gi_000D = GetLastError();
                              if (Gi_000D != 1 && Gi_000D != 130) {
                                 Print(tmp_str0001, ": Ordem: ", OrderTicket(), ". Falha ao tentar alterar ordem: ", Gi_000D, " ");
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         Sleep(1000);
      }
      Li_FFD8 = Li_FFD8 - 1;
   } while (Li_FFD8 >= 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1111(char Fa_s_00) {
   string tmp_str0000;
   string Ls_FFF0;
   double Ld_FFE8;
   string Ls_FFD8;
   string Ls_FFC8;
   string Ls_FFB8;

   Gi_0000 = Fa_s_00;
   if (Gi_0000 == 1) {
      Ls_FFF0 = DoubleToString(Bid, _Digits);
      ObjectCreate(0, "Market_Price_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      if ((Bid > Id_0018)) {
         ObjectSetText("Market_Price_Label", Ls_FFF0, Visor1_Price_Size, "Comic Sans MS", Visor1_Price_Up_Color);
      }
      if ((Bid < Id_0018)) {
         ObjectSetText("Market_Price_Label", Ls_FFF0, Visor1_Price_Size, "Comic Sans MS", Visor1_Price_Down_Color);
      }
      Id_0018 = Bid;
      ObjectSet("Market_Price_Label", OBJPROP_XDISTANCE, Visor1_Price_X_Position);
      ObjectSet("Market_Price_Label", OBJPROP_YDISTANCE, Visor1_Price_Y_Position);
      ObjectSet("Market_Price_Label", OBJPROP_CORNER, 1);
      if ((Bid > iClose(_Symbol, 1440, 1))) {
         Ii_0524 = 64636;
         Ii_053C = 1;
      }
      if ((Bid < iClose(_Symbol, 1440, 1))) {
         Ii_0524 = 4678655;
         Ii_053C = -1;
      }
      if ((iClose(_Symbol, 1440, 1) != 0)) {
         Gd_0000 = iClose(_Symbol, 1440, 0);
         Gd_0000 = (Gd_0000 / iClose(_Symbol, 1440, 1));
      } else {
         Gd_0000 = 0;
      }
      Ld_FFE8 = Gd_0000;
      tmp_str0000 = DoubleToString(((Gd_0000 - 1) * 100), 3);
      tmp_str0000 = tmp_str0000 + " %";
      Ls_FFD8 = tmp_str0000;
      ObjectCreate(0, "Porcent_Price_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSetText("Porcent_Price_Label", Ls_FFD8, Visor1_Porcent_Size, "Arial", Ii_0524);
      ObjectSet("Porcent_Price_Label", OBJPROP_CORNER, 1);
      ObjectSet("Porcent_Price_Label", OBJPROP_XDISTANCE, Visor1_Porcent_X_Position);
      ObjectSet("Porcent_Price_Label", OBJPROP_YDISTANCE, Visor1_Porcent_Y_Position);
      Ls_FFC8 = _Symbol;
      ObjectCreate(0, "Simbol_Price_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSetText("Simbol_Price_Label", Ls_FFC8, Visor1_Symbol_Size, "Arial", 16760576);
      ObjectSet("Simbol_Price_Label", OBJPROP_CORNER, 1);
      ObjectSet("Simbol_Price_Label", OBJPROP_XDISTANCE, Visor1_Symbol_X_Position);
      ObjectSet("Simbol_Price_Label", OBJPROP_YDISTANCE, Visor1_Symbol_Y_Position);
      tmp_str0000 = (string)MarketInfo(_Symbol, MODE_SPREAD);
      tmp_str0000 = "Spread : " + tmp_str0000;
      tmp_str0000 = tmp_str0000 + " pips";
      Ls_FFB8 = tmp_str0000;
      ObjectCreate(0, "Spread_Price_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSetText("Spread_Price_Label", Ls_FFB8, Visor1_Spread_Size, "Arial", 16777215);
      ObjectSet("Spread_Price_Label", OBJPROP_CORNER, 1);
      ObjectSet("Spread_Price_Label", OBJPROP_XDISTANCE, Visor1_Spread_X_Position);
      ObjectSet("Spread_Price_Label", OBJPROP_YDISTANCE, Visor1_Spread_Y_Position);
   }
   Gi_0000 = Fa_s_00;
   if (Gi_0000 != 2) return;
   ObjectDelete(0, "Market_Price_Label");
   ObjectDelete(0, "Porcent_Price_Label");
   ObjectDelete(0, "Simbol_Price_Label");
   ObjectDelete(0, "Spread_Price_Label");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1116(int Fa_i_00) {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   int Li_FFFC;
   int Li_FFF8;
   double Ld_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   double Ld_FFE0;
   int Li_FFDC;
   int Li_FFD8;
   double Ld_FFD0;

   if (Fa_i_00 == 1) {
      Li_FFFC = 0;
      Gi_0000 = 0;
      Gi_0001 = OrdersTotal() - 1;
      Gi_0002 = Gi_0001;
      if (Gi_0001 >= 0) {
         do {
            if (OrderSelect(Gi_0002, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                           Gi_0000 = Gi_0000 + 1;
                        }
                     }
                  }
               }
            }
            Gi_0002 = Gi_0002 - 1;
         } while (Gi_0002 >= 0);
      }
      Li_FFF8 = Gi_0000;
      if (Gi_0000 == 0) {
         ObjectSetInteger(0, "butCAO", 1018, 0);
         return ;
      }
      ObjectSetInteger(0, "butCAO", 6, 16711680);
      Gd_0001 = 0;
      Gi_0003 = OrdersTotal() - 1;
      Gi_0004 = Gi_0003;
      if (Gi_0003 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_0004, 0, 0);
            if (OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  Gd_0003 = OrderProfit();
                  Gd_0001 = ((Gd_0003 + OrderCommission()) + Gd_0001);
               }
            }
            Gi_0004 = Gi_0004 - 1;
         } while (Gi_0004 >= 0);
      }
      returned_double = NormalizeDouble(Gd_0001, 2);
      Ld_FFF0 = returned_double;
      tmp_str0000 = "CLOSE ALL ORDERS : " + _Symbol;
      tmp_str0001 = "Are you sure to CLOSE ALL ORDERS of " + _Symbol;
      tmp_str0001 = tmp_str0001 + ".\nThere are ";
      tmp_str0002 = (string)Li_FFF8;
      tmp_str0001 = tmp_str0001 + tmp_str0002;
      tmp_str0001 = tmp_str0001 + " orders, and Total P/L of $";
      tmp_str0001 = tmp_str0001 + DoubleToString(returned_double, 2);
      Li_FFFC = MessageBox(tmp_str0001, tmp_str0000, 308);
      if (Li_FFFC == 6) {
         Ii_0554 = OrdersTotal() - 1;
         if (Ii_0554 >= 0) {
            do {
               Ii_054C = OrderSelect(Ii_0554, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  if (OrderType() == OP_BUY) {
                     Ii_0550 = OrderClose(OrderTicket(), OrderLots(), Bid, 5, 4294967295);
                  }
                  if (OrderType() == OP_SELL) {
                     Ii_0550 = OrderClose(OrderTicket(), OrderLots(), Ask, 5, 4294967295);
                  }
               }
               Ii_0554 = Ii_0554 - 1;
            } while (Ii_0554 >= 0);
         }
         ObjectSetInteger(0, "butCAO", 1018, 0);
         ObjectSetInteger(0, "butCAO", 6, 0);
      } else {
         if (Li_FFFC == 7) {
            ObjectSetInteger(0, "butCAO", 1018, 0);
            ObjectSetInteger(0, "butCAO", 6, 0);
         }
      }
   }
   if (Fa_i_00 == 2) {
      Li_FFEC = 0;
      Gi_0008 = 0;
      Gi_0009 = OrdersTotal() - 1;
      Gi_000A = Gi_0009;
      if (Gi_0009 >= 0) {
         do {
            if (OrderSelect(Gi_000A, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                           Gi_0008 = Gi_0008 + 1;
                        }
                     }
                  }
               }
            }
            Gi_000A = Gi_000A - 1;
         } while (Gi_000A >= 0);
      }
      Li_FFE8 = Gi_0008;
      if (Gi_0008 == 0) {
         ObjectSetInteger(0, "butCAP", 1018, 0);
         return ;
      }
      ObjectSetInteger(0, "butCAP", 6, 16711680);
      Gd_0009 = 0;
      Ii_0570 = 0;
      Gi_000B = OrdersTotal() - 1;
      Gi_000C = Gi_000B;
      if (Gi_000B >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_000C, 0, 0);
            if (OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if ((OrderProfit() > 0)) {
                     Gd_0009 = (Gd_0009 + OrderProfit());
                     Ii_0570 = Ii_0570 + 1;
                  }
               }
            }
            Gi_000C = Gi_000C - 1;
         } while (Gi_000C >= 0);
      }
      returned_double = NormalizeDouble(Gd_0009, 2);
      Ld_FFE0 = returned_double;
      tmp_str0002 = "CLOSE ALL PROFITS : " + _Symbol;
      tmp_str0003 = "Are you sure to CLOSE ALL PROFITS of " + _Symbol;
      tmp_str0003 = tmp_str0003 + ".\nThere are ";
      tmp_str0004 = (string)Ii_0570;
      tmp_str0003 = tmp_str0003 + tmp_str0004;
      tmp_str0003 = tmp_str0003 + " orders profit, and Total P/L of $";
      tmp_str0003 = tmp_str0003 + DoubleToString(returned_double, 2);
      Li_FFEC = MessageBox(tmp_str0003, tmp_str0002, 308);
      if (Li_FFEC == 6) {
         Ii_0554 = OrdersTotal() - 1;
         if (Ii_0554 >= 0) {
            do {
               Ii_054C = OrderSelect(Ii_0554, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  if (OrderType() == OP_BUY && (OrderProfit() > 0.01)) {
                     Ii_0550 = OrderClose(OrderTicket(), OrderLots(), Bid, 5, 4294967295);
                  }
                  if (OrderType() == OP_SELL && (OrderProfit() > 0.01)) {
                     Ii_0550 = OrderClose(OrderTicket(), OrderLots(), Ask, 5, 4294967295);
                  }
               }
               Ii_0554 = Ii_0554 - 1;
            } while (Ii_0554 >= 0);
         }
         ObjectSetInteger(0, "butCAP", 1018, 0);
         ObjectSetInteger(0, "butCAP", 6, 0);
      } else {
         if (Li_FFEC == 7) {
            ObjectSetInteger(0, "butCAP", 1018, 0);
            ObjectSetInteger(0, "butCAP", 6, 0);
         }
      }
   }
   if (Fa_i_00 == 3) {
      Li_FFDC = 0;
      Gi_0010 = 0;
      Gi_0011 = OrdersTotal() - 1;
      Gi_0012 = Gi_0011;
      if (Gi_0011 >= 0) {
         do {
            if (OrderSelect(Gi_0012, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if (OrderSymbol() == _Symbol) {
                     if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                        if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                           Gi_0010 = Gi_0010 + 1;
                        }
                     }
                  }
               }
            }
            Gi_0012 = Gi_0012 - 1;
         } while (Gi_0012 >= 0);
      }
      Li_FFD8 = Gi_0010;
      if (Gi_0010 == 0) {
         ObjectSetInteger(0, "butCAL", 1018, 0);
         return ;
      }
      ObjectSetInteger(0, "butCAL", 6, 16711680);
      Gd_0011 = 0;
      Ii_0574 = 0;
      Gi_0013 = OrdersTotal() - 1;
      Gi_0014 = Gi_0013;
      if (Gi_0013 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_0014, 0, 0);
            if (OrderSymbol() == _Symbol) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  if ((OrderProfit() < 0)) {
                     Gd_0011 = (Gd_0011 + OrderProfit());
                     Ii_0574 = Ii_0574 + 1;
                  }
               }
            }
            Gi_0014 = Gi_0014 - 1;
         } while (Gi_0014 >= 0);
      }
      returned_double = NormalizeDouble(Gd_0011, 2);
      Ld_FFD0 = returned_double;
      tmp_str0004 = "CLOSE ALL LOSSES : " + _Symbol;
      tmp_str0005 = "Are you sure to CLOSE ALL LOSSES of " + _Symbol;
      tmp_str0005 = tmp_str0005 + ".\nThere are ";
      tmp_str0006 = (string)Ii_0574;
      tmp_str0005 = tmp_str0005 + tmp_str0006;
      tmp_str0005 = tmp_str0005 + " orders loss, and Total P/L of $";
      tmp_str0005 = tmp_str0005 + DoubleToString(returned_double, 2);
      Li_FFDC = MessageBox(tmp_str0005, tmp_str0004, 308);
      if (Li_FFDC == 6) {
         Ii_0554 = OrdersTotal() - 1;
         if (Ii_0554 >= 0) {
            do {
               Ii_054C = OrderSelect(Ii_0554, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  if (OrderType() == OP_BUY && (OrderProfit() <= -0.01)) {
                     Ii_0550 = OrderClose(OrderTicket(), OrderLots(), Bid, 5, 4294967295);
                  }
                  if (OrderType() == OP_SELL && (OrderProfit() <= -0.01)) {
                     Ii_0550 = OrderClose(OrderTicket(), OrderLots(), Ask, 5, 4294967295);
                  }
               }
               Ii_0554 = Ii_0554 - 1;
            } while (Ii_0554 >= 0);
         }
         ObjectSetInteger(0, "butCAL", 1018, 0);
         ObjectSetInteger(0, "butCAL", 6, 0);
      } else {
         if (Li_FFDC == 7) {
            ObjectSetInteger(0, "butCAL", 1018, 0);
            ObjectSetInteger(0, "butCAL", 6, 0);
         }
      }
   }
   if (Fa_i_00 == 4) {
      if (Ii_057C == 0) {
         Ii_057C = 1;
         func_1117('');
         ObjectSetInteger(0, "butN4", 1018, 0);
      } else {
         if (Ii_057C == 1) {
            Ii_057C = 0;
            func_1117('');
            ObjectSetInteger(0, "butN4", 1018, 0);
         }
      }
   }
   if (Fa_i_00 == 5) {
      Id_0418 = 0;
      tmp_str0007 = "Max DD: " + DoubleToString(0, 2);
      tmp_str0006 = tmp_str0007;
      ObjectSetText("MaxFloatDD_Label", tmp_str0006, Visor1_Spread_Size, "Arial", 16777215);
      ObjectSetInteger(0, "butResDD", 1018, 0);
   }
   if (Fa_i_00 == 6) {
      returned_double = AccountEquity();
      Id_0420 = returned_double;
      tmp_str0008 = "Min Equity: " + DoubleToString(returned_double, 2);
      tmp_str0007 = tmp_str0008;
      ObjectSetText("MinEquity_Label", tmp_str0007, Visor1_Spread_Size, "Arial", 16777215);
      ObjectSetInteger(0, "butMinEquity", 1018, 0);
   }
   if (Fa_i_00 != 7) return;
   if (ObjectFind(0, "SupRange") >= 0) {
      Ib_0537 = false;
      ObjectDelete(0, "SupRange");
      ObjectDelete(0, "InfRange");
      ObjectSetString(0, "butRange", 999, "Create Range");
      ObjectSetInteger(0, "butRange", 1025, 32768);
      PrintFormat("Price Ranger - Range removed by user");
      return ;
   }
   Ib_0537 = true;
   tmp_str0008 = "SupRange";
   ObjectCreate(0, tmp_str0008, OBJ_HLINE, 0, 0, (((RangeDistance * _Point) * 10) + Ask));
   ObjectSetInteger(0, tmp_str0008, 6, 32768);
   ObjectSetInteger(0, tmp_str0008, 8, 4);
   ObjectSetInteger(0, tmp_str0008, 17, 1);
   Gd_0018 = ((RangeDistance * _Point) * 10);
   tmp_str0009 = "InfRange";
   ObjectCreate(0, tmp_str0009, OBJ_HLINE, 0, 0, (Ask - Gd_0018));
   ObjectSetInteger(0, tmp_str0009, 6, 42495);
   ObjectSetInteger(0, tmp_str0009, 8, 4);
   ObjectSetInteger(0, tmp_str0009, 17, 1);
   ObjectSetString(0, "butRange", 999, "Remove Range");
   ObjectSetInteger(0, "butRange", 1025, 255);
   PrintFormat("Price Ranger - Range created");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1117(char Fa_s_00) {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string Ls_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   int Li_FFE4;
   int Li_FFE0;
   int Li_FFDC;
   int Li_FFD8;
   string Ls_FFC8;
   string Ls_FFB8;
   string Ls_FFA8;
   int Li_FFA4;
   int Li_FFA0;
   int Li_FF9C;
   int Li_FF98;
   int Li_FF94;
   string Ls_FF88;
   string Ls_FF78;
   string Ls_FF68;

   Li_FFEC = 0;
   Gi_0000 = Fa_s_00;
   if (Gi_0000 == 1 && IsOptimization() == false) {
      if (ChartGetInteger(0, 44, 0) == 0) {
         ObjectCreate(0, "N4BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "N4BG", 101, 0);
         returned_i = StringToColor("0,25,25");
         ObjectSetInteger(0, "N4BG", 1025, returned_i);
         ObjectSetInteger(0, "N4BG", 102, 0);
         ObjectSetInteger(0, "N4BG", 103, 12);
         ObjectSetInteger(0, "N4BG", 1019, 240);
         ObjectSetInteger(0, "N4BG", 1020, 330);
         ObjectSetInteger(0, "N4BG", 1029, 2);
         ObjectSetInteger(0, "N4BG", 17, 0);
         ObjectSetInteger(0, "N4BG", 1000, 0);
         Li_FFE8 = TimeHour(TimeCurrent());
         Li_FFE4 = TimeMinute(TimeCurrent());
         Li_FFE0 = TimeDay(TimeCurrent());
         Li_FFDC = TimeMonth(TimeCurrent());
         Li_FFD8 = TimeYear(TimeCurrent());
         Ls_FFC8 = (string)TimeDayOfWeek(TimeCurrent());
         Ls_FFB8 = "";
         if (Li_FFE4 < 10) {
            tmp_str0000 = (string)Li_FFE4;
            Ls_FFB8 = "0" + tmp_str0000;
         } else {
            Ls_FFB8 = DoubleToString(TimeMinute(TimeCurrent()), 0);
         }
         Gi_0000 = Li_FFE8 + Visor1_Chart_Timezone;
         Ls_FFA8 = DoubleToString(Gi_0000, 0);
         ObjectCreate(0, "Time_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
         tmp_str0000 = (string)Li_FFE0;
         tmp_str0000 = tmp_str0000 + "-";
         tmp_str0001 = (string)Li_FFDC;
         tmp_str0000 = tmp_str0000 + tmp_str0001;
         tmp_str0000 = tmp_str0000 + "-";
         tmp_str0001 = (string)Li_FFD8;
         tmp_str0000 = tmp_str0000 + tmp_str0001;
         tmp_str0000 = tmp_str0000 + " ";
         tmp_str0000 = tmp_str0000 + Ls_FFA8;
         tmp_str0000 = tmp_str0000 + ":";
         tmp_str0000 = tmp_str0000 + Ls_FFB8;
         ObjectSetText("Time_Label", tmp_str0000, Visor1_Time_Size, "Comic Sans MS", Visor1_Time_Color);
         ObjectSet("Time_Label", OBJPROP_XDISTANCE, Visor1_Time_X_Position);
         ObjectSet("Time_Label", OBJPROP_YDISTANCE, Visor1_Time_Y_Position);
         Ls_FFF0 = "\n\n";
         Ls_FFF0 = "\n\n=================================\n";
         tmp_str0001 = "\n\n=================================\n ";
         tmp_str0001 = "\n\n=================================\n  www.forexautomation.net ";
         tmp_str0001 = "\n\n=================================\n  www.forexautomation.net " + Is_C150;
         tmp_str0001 = tmp_str0001 + "\n";
         Ls_FFF0 = tmp_str0001;
         Ls_FFF0 = tmp_str0001 + "=================================\n";
         tmp_str0001 = Ls_FFF0 + "  Time of Broker:";
         tmp_str0001 = tmp_str0001 + TimeToString(TimeCurrent(), 5);
         tmp_str0001 = tmp_str0001 + "\n";
         Ls_FFF0 = tmp_str0001;
         tmp_str0001 = tmp_str0001 + "  Grid Size : ";
         tmp_str0002 = (string)InpGridSize;
         tmp_str0001 = tmp_str0001 + tmp_str0002;
         tmp_str0001 = tmp_str0001 + " Pips \n";
         Ls_FFF0 = tmp_str0001;
         tmp_str0002 = tmp_str0001 + "  TakeProfit: ";
         tmp_str0003 = (string)InpTakeProfit;
         tmp_str0002 = tmp_str0002 + tmp_str0003;
         tmp_str0002 = tmp_str0002 + " Pips \n";
         Ls_FFF0 = tmp_str0002;
         tmp_str0003 = tmp_str0002 + "  Lot Mode : ";
         tmp_str0004 = (string)InpLotMode;
         tmp_str0003 = tmp_str0003 + tmp_str0004;
         tmp_str0003 = tmp_str0003 + "  \n";
         Ls_FFF0 = tmp_str0003;
         tmp_str0004 = tmp_str0003 + "  Exponent Factor: ";
         tmp_str0005 = (string)InpGridFactor;
         tmp_str0004 = tmp_str0004 + tmp_str0005;
         tmp_str0004 = tmp_str0004 + " pips\n";
         Ls_FFF0 = tmp_str0004;
         tmp_str0005 = tmp_str0004 + "  InpMaxSpread: ";
         tmp_str0006 = (string)InpMaxSpread;
         tmp_str0005 = tmp_str0005 + tmp_str0006;
         tmp_str0005 = tmp_str0005 + " pips\n";
         Ls_FFF0 = tmp_str0005;
         Ls_FFF0 = tmp_str0005 + "=================================\n";
         tmp_str0006 = Ls_FFF0 + "  Equity:      ";
         tmp_str0006 = tmp_str0006 + DoubleToString(AccountEquity(), 2);
         tmp_str0006 = tmp_str0006 + " \n";
         Ls_FFF0 = tmp_str0006;
         tmp_str0006 = tmp_str0006 + "  Last Lot : | A : ";
         Gi_0000 = 1;
         Gd_0001 = 0;
         Gi_0002 = OrdersTotal() - 1;
         Gi_0003 = Gi_0002;
         if (Gi_0002 >= 0) {
            do {
               if (OrderSelect(Gi_0003, 0, 0)) {
                  if (OrderSymbol() != _Symbol) break;
                  if (OrderType() != 0) break;
                  Gd_0001 = OrderLots();
                  break;
               }
               Gi_0003 = Gi_0003 - 1;
            } while (Gi_0003 >= 0);
         }
         if (Gi_0000 == 2) {
            Gi_0002 = OrdersTotal() - 1;
            Gi_0004 = Gi_0002;
            if (Gi_0002 >= 0) {
               do {
                  if (OrderSelect(Gi_0004, 0, 0)) {
                     if (OrderSymbol() != _Symbol) break;
                     if (OrderType() != OP_SELL) break;
                     Gd_0001 = OrderLots();
                     break;
                  }
                  Gi_0004 = Gi_0004 - 1;
               } while (Gi_0004 >= 0);
            }
         }
         tmp_str0006 = tmp_str0006 + DoubleToString(NormalizeDouble(Gd_0001, 2), 2);
         tmp_str0006 = tmp_str0006 + " | B : ";
         Gi_0002 = 2;
         Gd_0005 = 0;

         if (Gi_0002 == 2) {
            Gi_0007 = OrdersTotal() - 1;
            Gi_0008 = Gi_0007;
            if (Gi_0007 >= 0) {
               do {
                  if (OrderSelect(Gi_0008, 0, 0)) {
                     if (OrderSymbol() != _Symbol) break;
                     if (OrderType() != OP_SELL) break;
                     Gd_0005 = OrderLots();
                     break;
                  }
                  Gi_0008 = Gi_0008 - 1;
               } while (Gi_0008 >= 0);
            }
         }
         tmp_str0006 = tmp_str0006 + DoubleToString(NormalizeDouble(Gd_0005, 2), 2);
         tmp_str0006 = tmp_str0006 + " \n";
         Ls_FFF0 = tmp_str0006;
         tmp_str0006 = tmp_str0006 + "  Orders Opens :   ";
         Gi_0007 = 0;
         Gi_0009 = OrdersTotal() - 1;
         Gi_000A = Gi_0009;
         if (Gi_0009 >= 0) {
            do {
               if (OrderSelect(Gi_000A, 0, 0) && OrderSymbol() == _Symbol) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     if (OrderSymbol() == _Symbol) {
                        if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                           if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                              Gi_0007 = Gi_0007 + 1;
                           }
                        }
                     }
                  }
               }
               Gi_000A = Gi_000A - 1;
            } while (Gi_000A >= 0);
         }
         tmp_str0007 = (string)Gi_0007;
         tmp_str0006 = tmp_str0006 + tmp_str0007;
         tmp_str0006 = tmp_str0006 + " | A : ";
         Gi_0009 = InpMagic;
         Gi_000B = 0;
         if (InpMagic == 2) {
            Gi_000C = OrdersTotal() - 1;
            Gi_000D = Gi_000C;
            if (Gi_000C >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_000D, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderType() == OP_SELL) {
                     Gi_000B = Gi_000B + 1;
                  }
                  Gi_000D = Gi_000D - 1;
               } while (Gi_000D >= 0);
            }
         } else {
            Gi_000C = OrdersTotal() - 1;
            Gi_000E = Gi_000C;
            if (Gi_000C >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_000E, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0009) {
                     Gi_000B = Gi_000B + 1;
                  }
                  Gi_000E = Gi_000E - 1;
               } while (Gi_000E >= 0);
            }
         }
         tmp_str0007 = (string)Gi_000B;
         tmp_str0006 = tmp_str0006 + tmp_str0007;
         tmp_str0006 = tmp_str0006 + " | B : ";
         Gi_000C = InpMagic2;
         Gi_000F = 0;
         if (InpMagic2 == 1) {
            Gi_0010 = OrdersTotal() - 1;
            Gi_0011 = Gi_0010;
            if (Gi_0010 >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_0011, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderType() == OP_BUY) {
                     Gi_000F = Gi_000F + 1;
                  }
                  Gi_0011 = Gi_0011 - 1;
               } while (Gi_0011 >= 0);
            }
         } else {
            Gi_0010 = OrdersTotal() - 1;
            Gi_0012 = Gi_0010;
            if (Gi_0010 >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_0012, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_000C) {
                     Gi_000F = Gi_000F + 1;
                  }
                  Gi_0012 = Gi_0012 - 1;
               } while (Gi_0012 >= 0);
            }
         }
         tmp_str0007 = (string)Gi_000F;
         tmp_str0006 = tmp_str0006 + tmp_str0007;
         tmp_str0006 = tmp_str0006 + " \n";
         Ls_FFF0 = tmp_str0006;
         tmp_str0007 = tmp_str0006 + "  Profit/Loss: ";
         tmp_str0007 = tmp_str0007 + DoubleToString(Id_0068, 2);
         tmp_str0007 = tmp_str0007 + " | A : ";
         Gi_0010 = InpMagic;
         Gd_0013 = 0;
         Gi_0014 = OrdersTotal() - 1;
         Gi_0015 = Gi_0014;
         if (Gi_0014 >= 0) {
            do {
               Ii_054C = OrderSelect(Gi_0015, 0, 0);
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0010) {
                  Gd_0014 = OrderProfit();
                  Gd_0013 = ((Gd_0014 + OrderCommission()) + Gd_0013);
               }
               Gi_0015 = Gi_0015 - 1;
            } while (Gi_0015 >= 0);
         }
         tmp_str0007 = tmp_str0007 + DoubleToString(Gd_0013, 2);
         tmp_str0007 = tmp_str0007 + " | B : ";
         Gi_0014 = InpMagic2;
         Gd_0016 = 0;
         Gi_0017 = OrdersTotal() - 1;
         Gi_0018 = Gi_0017;
         if (Gi_0017 >= 0) {
            do {
               Ii_054C = OrderSelect(Gi_0018, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  returned_i = OrderMagicNumber();
                  if (returned_i == Gi_0014) {
                     Gd_0017 = OrderProfit();
                     Gd_0016 = ((Gd_0017 + OrderCommission()) + Gd_0016);
                  }
               }
               Gi_0018 = Gi_0018 - 1;
            } while (Gi_0018 >= 0);
         }
         tmp_str0007 = tmp_str0007 + DoubleToString(Gd_0016, 2);
         tmp_str0007 = tmp_str0007 + " \n";
         Ls_FFF0 = tmp_str0007;
         Ls_FFF0 = tmp_str0007 + "=================================\n";
         tmp_str0007 = Ls_FFF0 + "  Max Profit: ";
         tmp_str0007 = tmp_str0007 + DoubleToString(Id_0408, 2);
         tmp_str0007 = tmp_str0007 + "\n";
         Ls_FFF0 = tmp_str0007;
         tmp_str0007 = tmp_str0007 + "  Max Drawdown: ";
         tmp_str0007 = tmp_str0007 + DoubleToString(Id_03F8, 2);
         tmp_str0007 = tmp_str0007 + "\n";
         Ls_FFF0 = tmp_str0007;
         tmp_str0007 = tmp_str0007 + "  Actual Profit: ";
         tmp_str0007 = tmp_str0007 + DoubleToString((AccountEquity() - Id_03F0), 2);
         tmp_str0007 = tmp_str0007 + "\n";
         Ls_FFF0 = tmp_str0007;
         Ls_FFF0 = tmp_str0007 + "=================================\n";
         tmp_str0007 = Ls_FFF0 + " TimeFilter : ";
         tmp_str0008 = (string)UseTimeFilter;
         tmp_str0007 = tmp_str0007 + tmp_str0008;
         tmp_str0007 = tmp_str0007 + " \n";
         Ls_FFF0 = tmp_str0007;
         Ls_FFF0 = tmp_str0007 + "=================================\n";
         Ls_FFF0 = Ls_FFF0 + Is_04F8;
         Comment(Ls_FFF0);
         Li_FFEC = 16;
      } else {
         ObjectCreate(0, "N4BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "N4BG", 101, 0);
         returned_i = StringToColor("0,25,25");
         ObjectSetInteger(0, "N4BG", 1025, returned_i);
         ObjectSetInteger(0, "N4BG", 102, 0);
         ObjectSetInteger(0, "N4BG", 103, 74);
         ObjectSetInteger(0, "N4BG", 1019, 240);
         ObjectSetInteger(0, "N4BG", 1020, 330);
         ObjectSetInteger(0, "N4BG", 1029, 2);
         ObjectSetInteger(0, "N4BG", 17, 0);
         ObjectSetInteger(0, "N4BG", 1000, 0);
         Li_FFA4 = TimeHour(TimeCurrent());
         Li_FFA0 = TimeMinute(TimeCurrent());
         Li_FF9C = TimeDay(TimeCurrent());
         Li_FF98 = TimeMonth(TimeCurrent());
         Li_FF94 = TimeYear(TimeCurrent());
         Ls_FF88 = (string)TimeDayOfWeek(TimeCurrent());
         Ls_FF78 = "";
         if (Li_FFA0 < 10) {
            tmp_str0008 = (string)Li_FFA0;
            Ls_FF78 = "0" + tmp_str0008;
         } else {
            Ls_FF78 = DoubleToString(TimeMinute(TimeCurrent()), 0);
         }
         Gi_0017 = Li_FFA4 + Visor1_Chart_Timezone;
         Ls_FF68 = DoubleToString(Gi_0017, 0);
         ObjectCreate(0, "Time_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
         tmp_str0008 = (string)Li_FF9C;
         tmp_str0008 = tmp_str0008 + "-";
         tmp_str0009 = (string)Li_FF98;
         tmp_str0008 = tmp_str0008 + tmp_str0009;
         tmp_str0008 = tmp_str0008 + "-";
         tmp_str0009 = (string)Li_FF94;
         tmp_str0008 = tmp_str0008 + tmp_str0009;
         tmp_str0008 = tmp_str0008 + " ";
         tmp_str0008 = tmp_str0008 + Ls_FF68;
         tmp_str0008 = tmp_str0008 + ":";
         tmp_str0008 = tmp_str0008 + Ls_FF78;
         ObjectSetText("Time_Label", tmp_str0008, Visor1_Time_Size, "Comic Sans MS", Visor1_Time_Color);
         ObjectSet("Time_Label", OBJPROP_XDISTANCE, Visor1_Time_X_Position);
         Gi_0017 = Visor1_Time_Y_Position + 62;
         ObjectSet("Time_Label", OBJPROP_YDISTANCE, Gi_0017);
         Ls_FFF0 = "\n\n";
         Ls_FFF0 = "\n\n=================================\n";
         tmp_str0009 = "\n\n=================================\n ";
         tmp_str0009 = "\n\n=================================\n  www.forexautomation.net ";
         tmp_str0009 = "\n\n=================================\n  www.forexautomation.net " + Is_C150;
         tmp_str0009 = tmp_str0009 + "\n";
         Ls_FFF0 = tmp_str0009;
         Ls_FFF0 = tmp_str0009 + "=================================\n";
         tmp_str0009 = Ls_FFF0 + "  Time of Broker:";
         tmp_str0009 = tmp_str0009 + TimeToString(TimeCurrent(), 5);
         tmp_str0009 = tmp_str0009 + "\n";
         Ls_FFF0 = tmp_str0009;
         tmp_str0009 = tmp_str0009 + "  Grid Size : ";
         tmp_str000A = (string)InpGridSize;
         tmp_str0009 = tmp_str0009 + tmp_str000A;
         tmp_str0009 = tmp_str0009 + " Pips \n";
         Ls_FFF0 = tmp_str0009;
         tmp_str000A = tmp_str0009 + "  TakeProfit: ";
         tmp_str000B = (string)InpTakeProfit;
         tmp_str000A = tmp_str000A + tmp_str000B;
         tmp_str000A = tmp_str000A + " Pips \n";
         Ls_FFF0 = tmp_str000A;
         tmp_str000B = tmp_str000A + "  Lot Mode : ";
         tmp_str000C = (string)InpLotMode;
         tmp_str000B = tmp_str000B + tmp_str000C;
         tmp_str000B = tmp_str000B + "  \n";
         Ls_FFF0 = tmp_str000B;
         tmp_str000C = tmp_str000B + "  Exponent Factor: ";
         tmp_str000D = (string)InpGridFactor;
         tmp_str000C = tmp_str000C + tmp_str000D;
         tmp_str000C = tmp_str000C + " pips\n";
         Ls_FFF0 = tmp_str000C;
         tmp_str000D = tmp_str000C + "  Daily Target: ";
         tmp_str000E = (string)DailyTarget;
         tmp_str000D = tmp_str000D + tmp_str000E;
         tmp_str000D = tmp_str000D + "\n";
         Ls_FFF0 = tmp_str000D;
         tmp_str000E = tmp_str000D + "  InpMaxSpread: ";
         tmp_str000F = (string)InpMaxSpread;
         tmp_str000E = tmp_str000E + tmp_str000F;
         tmp_str000E = tmp_str000E + " pips\n";
         Ls_FFF0 = tmp_str000E;
         Ls_FFF0 = tmp_str000E + "=================================\n";
         tmp_str000F = Ls_FFF0 + "  Equity:      ";
         tmp_str000F = tmp_str000F + DoubleToString(AccountEquity(), 2);
         tmp_str000F = tmp_str000F + " \n";
         Ls_FFF0 = tmp_str000F;
         tmp_str000F = tmp_str000F + "  Last Lot : | A : ";
         Gi_0017 = 1;
         Gd_0019 = 0;
         Gi_001A = OrdersTotal() - 1;
         Gi_001B = Gi_001A;
         if (Gi_001A >= 0) {
            do {
               if (OrderSelect(Gi_001B, 0, 0)) {
                  if (OrderSymbol() != _Symbol) break;
                  if (OrderType() != 0) break;
                  Gd_0019 = OrderLots();
                  break;
               }
               Gi_001B = Gi_001B - 1;
            } while (Gi_001B >= 0);
         }
         if (Gi_0017 == 2) {
            Gi_001A = OrdersTotal() - 1;
            Gi_001C = Gi_001A;
            if (Gi_001A >= 0) {
               do {
                  if (OrderSelect(Gi_001C, 0, 0)) {
                     if (OrderSymbol() != _Symbol) break;
                     if (OrderType() != OP_SELL) break;
                     Gd_0019 = OrderLots();
                     break;
                  }
                  Gi_001C = Gi_001C - 1;
               } while (Gi_001C >= 0);
            }
         }
         tmp_str000F = tmp_str000F + DoubleToString(NormalizeDouble(Gd_0019, 2), 2);
         tmp_str000F = tmp_str000F + " | B : ";
         Gi_001A = 2;
         Gd_001D = 0;

         if (Gi_001A == 2) {
            Gi_001F = OrdersTotal() - 1;
            Gi_0020 = Gi_001F;
            if (Gi_001F >= 0) {
               do {
                  if (OrderSelect(Gi_0020, 0, 0)) {
                     if (OrderSymbol() != _Symbol) break;
                     if (OrderType() != OP_SELL) break;
                     Gd_001D = OrderLots();
                     break;
                  }
                  Gi_0020 = Gi_0020 - 1;
               } while (Gi_0020 >= 0);
            }
         }
         tmp_str000F = tmp_str000F + DoubleToString(NormalizeDouble(Gd_001D, 2), 2);
         tmp_str000F = tmp_str000F + " \n";
         Ls_FFF0 = tmp_str000F;
         tmp_str000F = tmp_str000F + "  Orders Opens :   ";
         Gi_001F = 0;
         Gi_0021 = OrdersTotal() - 1;
         Gi_0022 = Gi_0021;
         if (Gi_0021 >= 0) {
            do {
               if (OrderSelect(Gi_0022, 0, 0) && OrderSymbol() == _Symbol) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     if (OrderSymbol() == _Symbol) {
                        if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                           if (OrderType() == OP_SELL || OrderType() == OP_BUY) {

                              Gi_001F = Gi_001F + 1;
                           }
                        }
                     }
                  }
               }
               Gi_0022 = Gi_0022 - 1;
            } while (Gi_0022 >= 0);
         }
         tmp_str0010 = (string)Gi_001F;
         tmp_str000F = tmp_str000F + tmp_str0010;
         tmp_str000F = tmp_str000F + " | A : ";
         Gi_0021 = InpMagic;
         Gi_0023 = 0;
         if (InpMagic == 2) {
            Gi_0024 = OrdersTotal() - 1;
            Gi_0025 = Gi_0024;
            if (Gi_0024 >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_0025, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderType() == OP_SELL) {
                     Gi_0023 = Gi_0023 + 1;
                  }
                  Gi_0025 = Gi_0025 - 1;
               } while (Gi_0025 >= 0);
            }
         } else {
            Gi_0024 = OrdersTotal() - 1;
            Gi_0026 = Gi_0024;
            if (Gi_0024 >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_0026, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0021) {
                     Gi_0023 = Gi_0023 + 1;
                  }
                  Gi_0026 = Gi_0026 - 1;
               } while (Gi_0026 >= 0);
            }
         }
         tmp_str0010 = (string)Gi_0023;
         tmp_str000F = tmp_str000F + tmp_str0010;
         tmp_str000F = tmp_str000F + " | B : ";
         Gi_0024 = InpMagic2;
         Gi_0027 = 0;
         if (InpMagic2 == 1) {
            Gi_0028 = OrdersTotal() - 1;
            Gi_0029 = Gi_0028;
            if (Gi_0028 >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_0029, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderType() == OP_BUY) {
                     Gi_0027 = Gi_0027 + 1;
                  }
                  Gi_0029 = Gi_0029 - 1;
               } while (Gi_0029 >= 0);
            }
         } else {
            Gi_0028 = OrdersTotal() - 1;
            Gi_002A = Gi_0028;
            if (Gi_0028 >= 0) {
               do {
                  Ii_054C = OrderSelect(Gi_002A, 0, 0);
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0024) {
                     Gi_0027 = Gi_0027 + 1;
                  }
                  Gi_002A = Gi_002A - 1;
               } while (Gi_002A >= 0);
            }
         }
         tmp_str0010 = (string)Gi_0027;
         tmp_str000F = tmp_str000F + tmp_str0010;
         tmp_str000F = tmp_str000F + " \n";
         Ls_FFF0 = tmp_str000F;
         tmp_str0010 = tmp_str000F + "  Profit/Loss: ";
         tmp_str0010 = tmp_str0010 + DoubleToString(Id_0068, 2);
         tmp_str0010 = tmp_str0010 + " | A : ";
         Gi_0028 = InpMagic;
         Gd_002B = 0;
         Gi_002C = OrdersTotal() - 1;
         Gi_002D = Gi_002C;
         if (Gi_002C >= 0) {
            do {
               Ii_054C = OrderSelect(Gi_002D, 0, 0);
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0028) {
                  Gd_002C = OrderProfit();
                  Gd_002B = ((Gd_002C + OrderCommission()) + Gd_002B);
               }
               Gi_002D = Gi_002D - 1;
            } while (Gi_002D >= 0);
         }
         tmp_str0010 = tmp_str0010 + DoubleToString(Gd_002B, 2);
         tmp_str0010 = tmp_str0010 + " | B : ";
         Gi_002C = InpMagic2;
         Gd_002E = 0;
         Gi_002F = OrdersTotal() - 1;
         Gi_0030 = Gi_002F;
         if (Gi_002F >= 0) {
            do {
               Ii_054C = OrderSelect(Gi_0030, 0, 0);
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_002C) {
                  Gd_002F = OrderProfit();
                  Gd_002E = ((Gd_002F + OrderCommission()) + Gd_002E);
               }
               Gi_0030 = Gi_0030 - 1;
            } while (Gi_0030 >= 0);
         }
         tmp_str0010 = tmp_str0010 + DoubleToString(Gd_002E, 2);
         tmp_str0010 = tmp_str0010 + " \n";
         Ls_FFF0 = tmp_str0010;
         Ls_FFF0 = tmp_str0010 + "=================================\n";
         tmp_str0010 = Ls_FFF0 + " TimeFilter : ";
         tmp_str0011 = (string)UseTimeFilter;
         tmp_str0010 = tmp_str0010 + tmp_str0011;
         tmp_str0010 = tmp_str0010 + " \n";
         Ls_FFF0 = tmp_str0010;
         Ls_FFF0 = tmp_str0010 + "=================================\n";
         Ls_FFF0 = Ls_FFF0 + Is_04F8;
         Comment(Ls_FFF0);
         Li_FFEC = 16;
      }
   }
   Gi_002F = Fa_s_00;
   if (Gi_002F != 2) return;
   ObjectDelete(0, "N4BG");
   ObjectDelete(0, "Time_Label");
   Comment("");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1118(int Fa_i_00) {
   if (Fa_i_00 == 1) {
      ObjectSetInteger(0, "butCAO", 101, 3);
      ObjectSetString(0, "butCAO", 1001, "Calibri");
      ObjectSetInteger(0, "butCAO", 100, 8);
      ObjectSetInteger(0, "butCAO", 102, 84);
      ObjectSetInteger(0, "butCAO", 103, 66);
      ObjectSetInteger(0, "butCAO", 1019, 82);
      ObjectSetInteger(0, "butCAO", 1020, 20);
      ObjectSetInteger(0, "butCAO", 208, 1);
      ObjectSetInteger(0, "butCAO", 207, 0);
      ObjectSetString(0, "butCAO", 999, "Close All Orders");
      ObjectSetInteger(0, "butCAO", 1018, 0);
      ObjectSetInteger(0, "butCAO", 1025, 11788021);
      ObjectSetInteger(0, "butCAO", 6, 0);
      ObjectSetInteger(0, "butCAP", 101, 3);
      ObjectSetString(0, "butCAP", 1001, "Calibri");
      ObjectSetInteger(0, "butCAP", 100, 8);
      ObjectSetInteger(0, "butCAP", 102, 84);
      ObjectSetInteger(0, "butCAP", 103, 44);
      ObjectSetInteger(0, "butCAP", 1019, 82);
      ObjectSetInteger(0, "butCAP", 1020, 20);
      ObjectSetInteger(0, "butCAP", 208, 1);
      ObjectSetInteger(0, "butCAP", 207, 0);
      ObjectSetString(0, "butCAP", 999, "Close All Profits");
      ObjectSetInteger(0, "butCAP", 1018, 0);
      ObjectSetInteger(0, "butCAP", 1025, 9498256);
      ObjectSetInteger(0, "butCAP", 6, 0);
      ObjectSetInteger(0, "butCAL", 101, 3);
      ObjectSetString(0, "butCAL", 1001, "Calibri");
      ObjectSetInteger(0, "butCAL", 100, 8);
      ObjectSetInteger(0, "butCAL", 102, 84);
      ObjectSetInteger(0, "butCAL", 103, 22);
      ObjectSetInteger(0, "butCAL", 1019, 82);
      ObjectSetInteger(0, "butCAL", 1020, 20);
      ObjectSetInteger(0, "butCAL", 208, 1);
      ObjectSetInteger(0, "butCAL", 207, 0);
      ObjectSetString(0, "butCAL", 999, "Close All Losses");
      ObjectSetInteger(0, "butCAL", 1018, 0);
      ObjectSetInteger(0, "butCAL", 1025, 42495);
      ObjectSetInteger(0, "butCAL", 6, 0);
   }
   if (Fa_i_00 != 0) return;
   ObjectSetInteger(0, "butCAO", 101, 3);
   ObjectSetString(0, "butCAO", 1001, "Calibri");
   ObjectSetInteger(0, "butCAO", 100, 8);
   ObjectSetInteger(0, "butCAO", 102, 84);
   ObjectSetInteger(0, "butCAO", 103, 66);
   ObjectSetInteger(0, "butCAO", 1019, 82);
   ObjectSetInteger(0, "butCAO", 1020, 20);
   ObjectSetInteger(0, "butCAO", 208, 1);
   ObjectSetInteger(0, "butCAO", 207, 0);
   ObjectSetString(0, "butCAO", 999, "Close All Orders");
   ObjectSetInteger(0, "butCAO", 1018, 0);
   ObjectSetInteger(0, "butCAO", 1025, 8421504);
   ObjectSetInteger(0, "butCAO", 6, 0);
   ObjectSetInteger(0, "butCAP", 101, 3);
   ObjectSetString(0, "butCAP", 1001, "Calibri");
   ObjectSetInteger(0, "butCAP", 100, 8);
   ObjectSetInteger(0, "butCAP", 102, 84);
   ObjectSetInteger(0, "butCAP", 103, 44);
   ObjectSetInteger(0, "butCAP", 1019, 82);
   ObjectSetInteger(0, "butCAP", 1020, 20);
   ObjectSetInteger(0, "butCAP", 208, 1);
   ObjectSetInteger(0, "butCAP", 207, 0);
   ObjectSetString(0, "butCAP", 999, "Close All Profits");
   ObjectSetInteger(0, "butCAP", 1018, 0);
   ObjectSetInteger(0, "butCAP", 1025, 8421504);
   ObjectSetInteger(0, "butCAP", 6, 0);
   ObjectSetInteger(0, "butCAL", 101, 3);
   ObjectSetString(0, "butCAL", 1001, "Calibri");
   ObjectSetInteger(0, "butCAL", 100, 8);
   ObjectSetInteger(0, "butCAL", 102, 84);
   ObjectSetInteger(0, "butCAL", 103, 22);
   ObjectSetInteger(0, "butCAL", 1019, 82);
   ObjectSetInteger(0, "butCAL", 1020, 20);
   ObjectSetInteger(0, "butCAL", 208, 1);
   ObjectSetInteger(0, "butCAL", 207, 0);
   ObjectSetString(0, "butCAL", 999, "Close All Losses");
   ObjectSetInteger(0, "butCAL", 1018, 0);
   ObjectSetInteger(0, "butCAL", 1025, 8421504);
   ObjectSetInteger(0, "butCAL", 6, 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1125() {
   ObjectCreate(0, "butN4", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "butN4", 101, 0);
   ObjectSetInteger(0, "butN4", 102, 80);
   ObjectSetInteger(0, "butN4", 103, 2);
   ObjectSetInteger(0, "butN4", 1019, 26);
   ObjectSetInteger(0, "butN4", 1020, 14);
   ObjectSetString(0, "butN4", 999, "INFO");
   ObjectSetInteger(0, "butN4", 100, 6);
   ObjectSetInteger(0, "butN4", 6, 0);
   ObjectSetInteger(0, "butN4", 1025, 15453831);
   ObjectSetInteger(0, "butN4", 1018, 0);
   ObjectCreate(0, "butCAO", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "butCAO", 101, 3);
   ObjectSetString(0, "butCAO", 1001, "Calibri");
   ObjectSetInteger(0, "butCAO", 100, 8);
   ObjectSetInteger(0, "butCAO", 102, 84);
   ObjectSetInteger(0, "butCAO", 103, 66);
   ObjectSetInteger(0, "butCAO", 1019, 82);
   ObjectSetInteger(0, "butCAO", 1020, 20);
   ObjectSetInteger(0, "butCAO", 208, 1);
   ObjectSetInteger(0, "butCAO", 207, 0);
   ObjectSetString(0, "butCAO", 999, "Close All Orders");
   ObjectSetInteger(0, "butCAO", 1018, 0);
   ObjectSetInteger(0, "butCAO", 1025, 8421504);
   ObjectSetInteger(0, "butCAO", 6, 0);
   ObjectCreate(0, "butCAP", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "butCAP", 101, 3);
   ObjectSetString(0, "butCAP", 1001, "Calibri");
   ObjectSetInteger(0, "butCAP", 100, 8);
   ObjectSetInteger(0, "butCAP", 102, 84);
   ObjectSetInteger(0, "butCAP", 103, 44);
   ObjectSetInteger(0, "butCAP", 1019, 82);
   ObjectSetInteger(0, "butCAP", 1020, 20);
   ObjectSetInteger(0, "butCAP", 208, 1);
   ObjectSetInteger(0, "butCAP", 207, 0);
   ObjectSetString(0, "butCAP", 999, "Close All Profits");
   ObjectSetInteger(0, "butCAP", 1018, 0);
   ObjectSetInteger(0, "butCAP", 1025, 8421504);
   ObjectSetInteger(0, "butCAP", 6, 0);
   ObjectCreate(0, "butCAL", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "butCAL", 101, 3);
   ObjectSetString(0, "butCAL", 1001, "Calibri");
   ObjectSetInteger(0, "butCAL", 100, 8);
   ObjectSetInteger(0, "butCAL", 102, 84);
   ObjectSetInteger(0, "butCAL", 103, 22);
   ObjectSetInteger(0, "butCAL", 1019, 82);
   ObjectSetInteger(0, "butCAL", 1020, 20);
   ObjectSetInteger(0, "butCAL", 208, 1);
   ObjectSetInteger(0, "butCAL", 207, 0);
   ObjectSetString(0, "butCAL", 999, "Close All Losses");
   ObjectSetInteger(0, "butCAL", 1018, 0);
   ObjectSetInteger(0, "butCAL", 1025, 8421504);
   ObjectSetInteger(0, "butCAL", 6, 0);
   if (PriceRangerActive && ObjectFind("butRange") < 0) {
      ObjectCreate(0, "butRange", OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, "butRange", 101, 1);
      ObjectSetString(0, "butRange", 1001, "Calibri");
      ObjectSetInteger(0, "butRange", 100, 8);
      Gi_0000 = Visor1_Spread_X_Position + 80;
      ObjectSetInteger(0, "butRange", 102, Gi_0000);
      Gi_0000 = Visor1_Spread_Y_Position + 100;
      ObjectSetInteger(0, "butRange", 103, Gi_0000);
      ObjectSetInteger(0, "butRange", 1019, 82);
      ObjectSetInteger(0, "butRange", 1020, 20);
      ObjectSetInteger(0, "butRange", 208, 1);
      ObjectSetInteger(0, "butRange", 207, 0);
      ObjectSetString(0, "butRange", 999, "Create Range");
      ObjectSetInteger(0, "butRange", 1018, 0);
      ObjectSetInteger(0, "butRange", 1025, 32768);
      ObjectSetInteger(0, "butRange", 6, 0);
   }
   func_1131();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1131() {
   string Ls_FFF0;
   string Ls_FFE0;

   ObjectCreate(0, "butResDD", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "butResDD", 101, 1);
   ObjectSetString(0, "butResDD", 1001, "Calibri");
   ObjectSetInteger(0, "butResDD", 100, 8);
   Gi_0000 = Visor1_Spread_X_Position + 10;
   ObjectSetInteger(0, "butResDD", 102, Gi_0000);
   Gi_0001 = Visor1_Spread_Y_Position + 20;
   ObjectSetInteger(0, "butResDD", 103, Gi_0001);
   ObjectSetInteger(0, "butResDD", 1019, 10);
   ObjectSetInteger(0, "butResDD", 1020, 15);
   ObjectSetInteger(0, "butResDD", 207, 0);
   ObjectSetString(0, "butResDD", 999, "X");
   ObjectSetInteger(0, "butResDD", 1025, 8421504);
   ObjectSetInteger(0, "butResDD", 6, 0);
   Ls_FFF0 = "Max DD: " + DoubleToString(Id_0418, 2);
   ObjectCreate(0, "MaxFloatDD_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText("MaxFloatDD_Label", Ls_FFF0, Visor1_Spread_Size, "Arial", 16777215);
   ObjectSet("MaxFloatDD_Label", OBJPROP_CORNER, 1);
   ObjectSet("MaxFloatDD_Label", OBJPROP_XDISTANCE, Gi_0000);
   ObjectSet("MaxFloatDD_Label", OBJPROP_YDISTANCE, Gi_0001);
   ObjectCreate(0, "butMinEquity", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "butMinEquity", 101, 1);
   ObjectSetString(0, "butMinEquity", 1001, "Calibri");
   ObjectSetInteger(0, "butMinEquity", 100, 8);
   ObjectSetInteger(0, "butMinEquity", 102, Gi_0000);
   Gi_0002 = Visor1_Spread_Y_Position + 40;
   ObjectSetInteger(0, "butMinEquity", 103, Gi_0002);
   ObjectSetInteger(0, "butMinEquity", 1019, 10);
   ObjectSetInteger(0, "butMinEquity", 1020, 15);
   ObjectSetInteger(0, "butMinEquity", 207, 0);
   ObjectSetString(0, "butMinEquity", 999, "X");
   ObjectSetInteger(0, "butMinEquity", 1025, 8421504);
   ObjectSetInteger(0, "butMinEquity", 6, 0);
   Ls_FFE0 = "Min Equity: " + DoubleToString(Id_0420, 2);
   ObjectCreate(0, "MinEquity_Label", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText("MinEquity_Label", Ls_FFE0, Visor1_Spread_Size, "Arial", 16777215);
   ObjectSet("MinEquity_Label", OBJPROP_CORNER, 1);
   ObjectSet("MinEquity_Label", OBJPROP_XDISTANCE, Gi_0000);
   ObjectSet("MinEquity_Label", OBJPROP_YDISTANCE, Gi_0002);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1132(bool FuncArg_Boolean_00000000) {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   int Li_FFFC;
   int Li_FFF8;
   int Li_FFF4;
   double Ld_FFE8;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Gd_0000 = iClose(NULL, 0, 0);
   if ((Gd_0000 > iMA(NULL, InpMaFrame, InpMaPeriod, 0, InpMaMethod, InpMaPrice, InpMaShift))) {
      Li_FFF8 = 1;
   }
   Gd_0000 = iClose(NULL, 0, 0);
   if ((Gd_0000 < iMA(NULL, InpMaFrame, InpMaPeriod, 0, InpMaMethod, InpMaPrice, InpMaShift))) {
      Li_FFF8 = -1;
   }
   Gi_0000 = 0;
   if (EnableSinalHILO != true) {
      Gi_0000 = 0;
   }
   Id_0040 = iMA(NULL, InpHILOFrame, InpHILOPeriod, 0, InpHILOMethod, 3, InpHILOShift);
   Id_0048 = iMA(NULL, InpHILOFrame, InpHILOPeriod, 0, InpHILOMethod, 2, InpHILOShift);
   Id_0050 = (Id_0048 - Id_0040);
   Ib_052C = (Bid >= ((Id_0050 / 2) + Id_0040));
   if ((Bid < Id_0040)) {
      Gi_0000 = -1;
   } else {
      if ((Bid > Id_0048)) {
         Gi_0000 = 1;
      }
   }
   if (InpHILOFilterInverter) {
      Gi_0001 = -Gi_0000;
      Gi_0000 = Gi_0001;
   }
   Li_FFF4 = Gi_0000;
   Gi_0001 = Gi_0000 + Li_FFF8;
   if (EnableSinalHILO != true) {
      Gi_0002 = 0;
   } else {
      Gi_0002 = 1;
   }
   Gi_0003 = Gi_0002 + 1;
   Li_FFFC = Gi_0001 / Gi_0003;
   Ld_FFE8 = 0;
   if (InpEnableEngineB == false && InpEnableEngineA == false) {
      tmp_str0000 = "S";
      func_1134(tmp_str0000, Li_FFFC, FuncArg_Boolean_00000000, 0, InpMagic, Ii_0540, Id_0470, Ib_052D, Ib_052E, Ii_0558, Ii_055C, Ii_0560, Id_0428, Id_0430, Id_0438, Id_0440, Id_0448, Id_0450, Id_0458, Id_0460, Il_0028, Id_0478);
      return ;
   }
   if (InpManualInitGrid != true) {
      if (Ii_0544 > InpHedgex && InpHedgex != 0) {
         Ld_FFE8 = (Id_04D8 / InpGridFactor);
      }
      if (Li_FFFC == 1 && InpEnableEngineA) {
         tmp_str0001 = "A";
         func_1134(tmp_str0001, 1, FuncArg_Boolean_00000000, Ld_FFE8, InpMagic, Ii_0540, Id_0470, Ib_052D, Ib_052E, Ii_0558, Ii_055C, Ii_0560, Id_0428, Id_0430, Id_0438, Id_0440, Id_0448, Id_0450, Id_0458, Id_0460, Il_0028, Id_0478);
      }
      if (Ii_0540 > InpHedgex && InpHedgex != 0) {
         Ld_FFE8 = (Id_0480 / InpGridFactor);
      }
      if (Li_FFFC != -1) return;
      if (InpEnableEngineB == false) return;
      tmp_str0002 = "B";
      func_1134(tmp_str0002, -1, FuncArg_Boolean_00000000, Ld_FFE8, InpMagic2, Ii_0544, Id_04D0, Ib_052F, Ib_0530, Ii_0564, Ii_0568, Ii_056C, Id_0488, Id_0490, Id_0498, Id_04A0, Id_04A8, Id_04B0, Id_04B8, Id_04C0, Il_0030, Id_04E0);
      return ;
   }
   tmp_str0003 = "A";
   func_1134(tmp_str0003, 0, FuncArg_Boolean_00000000, Ld_FFE8, InpMagic, Ii_0540, Id_0470, Ib_052D, Ib_052E, Ii_0558, Ii_055C, Ii_0560, Id_0428, Id_0430, Id_0438, Id_0440, Id_0448, Id_0450, Id_0458, Id_0460, Il_0028, Id_0478);
   tmp_str0004 = "B";
   func_1134(tmp_str0004, 0, FuncArg_Boolean_00000000, Ld_FFE8, InpMagic2, Ii_0544, Id_04D0, Ib_052F, Ib_0530, Ii_0564, Ii_0568, Ii_056C, Id_0488, Id_0490, Id_0498, Id_04A0, Id_04A8, Id_04B0, Id_04B8, Id_04C0, Il_0030, Id_04E0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1133() {
   string tmp_str0000;
   string tmp_str0001;

   Gi_0000 = InpMagic2;
   Gi_0001 = 0;
   if (InpMagic2 == 1) {
      Gi_0002 = OrdersTotal() - 1;
      Gi_0003 = Gi_0002;
      if (Gi_0002 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_0003, 0, 0);
            if (OrderSymbol() == _Symbol && OrderType() == OP_BUY) {
               Gi_0001 = Gi_0001 + 1;
            }
            Gi_0003 = Gi_0003 - 1;
         } while (Gi_0003 >= 0);
      }
   } else {
      Gi_0002 = OrdersTotal() - 1;
      Gi_0004 = Gi_0002;
      if (Gi_0002 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_0004, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0000) {
               Gi_0001 = Gi_0001 + 1;
            }
            Gi_0004 = Gi_0004 - 1;
         } while (Gi_0004 >= 0);
      }
   }
   if (Gi_0001 == 0) {
      ObjectDelete(0, "AvgA");
      Id_03D0 = 0;
   }
   Gi_0002 = InpMagic;
   Gi_0005 = 0;
   if (InpMagic == 2) {
      Gi_0006 = OrdersTotal() - 1;
      Gi_0007 = Gi_0006;
      if (Gi_0006 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_0007, 0, 0);
            if (OrderSymbol() == _Symbol && OrderType() == OP_SELL) {
               Gi_0005 = Gi_0005 + 1;
            }
            Gi_0007 = Gi_0007 - 1;
         } while (Gi_0007 >= 0);
      }
   } else {
      Gi_0006 = OrdersTotal() - 1;
      Gi_0008 = Gi_0006;
      if (Gi_0006 >= 0) {
         do {
            Ii_054C = OrderSelect(Gi_0008, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0002) {
               Gi_0005 = Gi_0005 + 1;
            }
            Gi_0008 = Gi_0008 - 1;
         } while (Gi_0008 >= 0);
      }
   }
   if (Gi_0005 == 0) {
      ObjectDelete(0, "AvgB");
      Id_03D8 = 0;
   }
   Gd_0006 = 0;
   Gi_0009 = OrdersTotal() - 1;
   Gi_000A = Gi_0009;
   if (Gi_0009 >= 0) {
      do {
         Ii_054C = OrderSelect(Gi_000A, 0, 0);
         if (OrderSymbol() == _Symbol) {
            if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

               Gd_0009 = OrderProfit();
               Gd_0006 = ((Gd_0009 + OrderCommission()) + Gd_0006);
            }
         }
         Gi_000A = Gi_000A - 1;
      } while (Gi_000A >= 0);
   }
   Id_0068 = Gd_0006;
   if (InpCloseAllNow) {
      Gi_0009 = InpMagic;
      Gi_000B = OrdersTotal() - 1;
      Gi_000C = Gi_000B;
      if (Gi_000B >= 0) {
         do {
            if (OrderSelect(Gi_000C, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0009) {
                  if (OrderType() == OP_BUY) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
                  }
                  if (OrderType() == OP_SELL) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
                  }
               }
               Sleep(1000);
            }
            Gi_000C = Gi_000C - 1;
         } while (Gi_000C >= 0);
      }
      Gi_0010 = InpMagic2;
      Gi_0011 = OrdersTotal() - 1;
      Gi_0012 = Gi_0011;
      if (Gi_0011 >= 0) {
         do {
            if (OrderSelect(Gi_0012, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0010) {
                  if (OrderType() == OP_BUY) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
                  }
                  if (OrderType() == OP_SELL) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
                  }
               }
               Sleep(1000);
            }
            Gi_0012 = Gi_0012 - 1;
         } while (Gi_0012 >= 0);
      }
      InpManualInitGrid = true;
   }
   Gi_0016 = InpMagic2;
   Gd_0017 = 0;
   Gi_0018 = 0;
   Gi_0019 = 0;
   Gi_001A = OrdersTotal() - 1;
   Gi_001B = Gi_001A;
   if (Gi_001A >= 0) {
      do {
         if (OrderSelect(Gi_001B, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0016 && OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0016 && OrderType() == OP_SELL) {
            Gi_0018 = OrderTicket();
            if (Gi_0018 > Gi_0019) {
               Gd_0017 = (Gd_0017 + OrderLots());
               Gi_0019 = Gi_0018;
            }
         }
         Gi_001B = Gi_001B - 1;
      } while (Gi_001B >= 0);
   }
   Id_04D8 = Gd_0017;
   Gi_001A = InpMagic;
   Gd_001C = 0;
   Gi_001D = 0;
   Gi_001E = 0;
   Gi_001F = OrdersTotal() - 1;
   Gi_0020 = Gi_001F;
   if (Gi_001F >= 0) {
      do {
         if (OrderSelect(Gi_0020, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_001A && OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_001A && OrderType() == OP_BUY) {
            Gi_001D = OrderTicket();
            if (Gi_001D > Gi_001E) {
               Gd_001C = (Gd_001C + OrderLots());
               Gi_001E = Gi_001D;
            }
         }
         Gi_0020 = Gi_0020 - 1;
      } while (Gi_0020 >= 0);
   }
   Id_0480 = Gd_001C;
   if (InpManualInitGrid == false) return;
   if ((Gd_001C > 0) || InpEnableEngineA == false) {

      ObjectSetInteger(0, "_lBUY", 1025, 8421504);
      ObjectSetInteger(0, "_lCLOSE ALL BUY", 1025, 32768);
   } else {
      ObjectSetInteger(0, "_lBUY", 1025, 16711680);
      ObjectSetInteger(0, "_lCLOSE ALL BUY", 1025, 8421504);
   }
   Gb_001F = (Id_04D8 > 0);
   if (Gb_001F || InpEnableEngineB == false) {

      ObjectSetInteger(0, "_lSELL", 1025, 8421504);
      ObjectSetInteger(0, "_lCLOSE ALL SELL", 1025, 32768);
   } else {
      ObjectSetInteger(0, "_lSELL", 1025, 255);
      ObjectSetInteger(0, "_lCLOSE ALL SELL", 1025, 8421504);
   }
   if (ObjectGetInteger(0, "_lBUY", 1018, 0) != 0) {
      Gb_001F = (Ii_0540 > 0);
      if (Gb_001F != true) {
         Gb_001F = !InpEnableEngineA;
      }
      if (Gb_001F != true) {
         tmp_str0000 = "A";
         func_1134(tmp_str0000, 1, false, 1, InpMagic, Ii_0540, Id_0470, Ib_052D, Ib_052E, Ii_0558, Ii_055C, Ii_0560, Id_0428, Id_0430, Id_0438, Id_0440, Id_0448, Id_0450, Id_0458, Id_0460, Il_0028, Id_0478);
         PrintFormat("BUY");
         ObjectSetInteger(0, "_lBUY", 1018, 0);
      }
   }
   if (ObjectGetInteger(0, "_lSELL", 1018, 0) != 0) {
      Gb_001F = (Ii_0544 > 0);
      if (Gb_001F != true) {
         Gb_001F = !InpEnableEngineA;
      }
      if (Gb_001F != true) {
         tmp_str0001 = "B";
         func_1134(tmp_str0001, -1, false, 1, InpMagic2, Ii_0544, Id_04D0, Ib_052F, Ib_0530, Ii_0564, Ii_0568, Ii_056C, Id_0488, Id_0490, Id_0498, Id_04A0, Id_04A8, Id_04B0, Id_04B8, Id_04C0, Il_0030, Id_04E0);
         ObjectSetInteger(0, "_lSELL", 1018, 0);
      }
   }
   if (ObjectGetInteger(0, "_lCLOSE ALL SELL", 1018, 0) != 0) {
      Gi_001F = InpMagic2;
      Gi_0021 = OrdersTotal() - 1;
      Gi_0022 = Gi_0021;
      if (Gi_0021 >= 0) {
         do {
            if (OrderSelect(Gi_0022, 0, 0) && OrderSymbol() == _Symbol) {
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_001F) {
                  if (OrderType() == OP_BUY) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
                  }
                  if (OrderType() == OP_SELL) {
                     order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
                  }
               }
               Sleep(1000);
            }
            Gi_0022 = Gi_0022 - 1;
         } while (Gi_0022 >= 0);
      }
      ObjectSetInteger(0, "_lCLOSE ALL SELL", 1018, 0);
   }
   if (!ObjectGetInteger(0, "_lCLOSE ALL BUY", 1018, 0)) return;
   Gi_0026 = InpMagic;
   Gi_0027 = OrdersTotal() - 1;
   Gi_0028 = Gi_0027;
   if (Gi_0027 >= 0) {
      do {
         if (OrderSelect(Gi_0028, 0, 0) && OrderSymbol() == _Symbol) {
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0026) {
               if (OrderType() == OP_BUY) {
                  order_check = OrderClose(OrderTicket(), OrderLots(), Bid, Ii_0020, 16711680);
               }
               if (OrderType() == OP_SELL) {
                  order_check = OrderClose(OrderTicket(), OrderLots(), Ask, Ii_0020, 255);
               }
            }
            Sleep(1000);
         }
         Gi_0028 = Gi_0028 - 1;
      } while (Gi_0028 >= 0);
   }
   ObjectSetInteger(0, "_lCLOSE ALL BUY", 1018, 0);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_1134(string Fa_s_00, int Fa_i_01, bool FuncArg_Boolean_00000002, double Fa_d_03, int Fa_i_04, int &Fa_i_05, double &Fa_d_06, bool &FuncArg_Boolean_00000007, bool &FuncArg_Boolean_00000008, int &Fa_i_09, int &Fa_i_0A, int &Fa_i_0B, double &Fa_d_0C, double &Fa_d_0D, double &Fa_d_0E, double &Fa_d_0F, double &Fa_d_10, double &Fa_d_11, double &Fa_d_12, double &Fa_d_13, long &Fa_l_14, double &Fa_d_15) {
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   int Li_FFFC;
   int Li_FFF8;
   int Li_FFF4;
   int Li_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
   double Ld_FFD0;
   double Ld_FFC8;
   double Ld_FFC0;
   double Ld_FFB8;
   double Ld_FFB0;
   double Ld_FFA8;
   double Ld_FFA0;
   int Li_FF9C;
   int Li_FF98;
   int Li_FF94;
   int Li_FF90;
   int Li_FF8C;
   int Li_FF88;
   int Li_FF84;
   bool Lb_FF83;
   bool Lb_FF82;
   bool Lb_FF81;
   bool Lb_FF80;
   double Ld_FF78;
   double Ld_FF70;
   double Ld_FF68;
   double Ld_FF60;
   double Ld_FF58;
   double Ld_FF50;
   double Ld_FF48;
   double Ld_FF40;
   double Ld_FF38;
   double Ld_FF30;
   double Ld_FF28;
   double Ld_FF20;
   double Ld_FF18;
   double Ld_FF10;
   long Ll_FF08;
   bool Lb_FF07;
   double Ld_FEF8;
   double Ld_FEF0;
   int Li_FEEC;
   double Ld_FEE0;
   double Ld_FED8;
   double Ld_FDD0;
   double Ld_FDC8;
   int Li_FDC4;
   int Li_FDC0;
   double Ld_FDB8;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Li_FFF0 = 0;
   Li_FFEC = 0;
   Li_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = 0;
   Ld_FFD0 = 0;
   Ld_FFC8 = 0;
   Ld_FFC0 = 0;
   Ld_FFB8 = 0;
   Ld_FFB0 = 0;
   Ld_FFA8 = 0;
   Ld_FFA0 = 0;
   Li_FF9C = 0;
   Li_FF98 = 0;
   Li_FF94 = 0;
   Li_FF90 = 0;
   Li_FF8C = 0;
   Li_FF88 = 0;
   Li_FF84 = 0;
   Lb_FF83 = false;
   Lb_FF82 = false;
   Lb_FF81 = false;
   Lb_FF80 = false;
   Ld_FF78 = 0;
   Ld_FF70 = 0;
   Ld_FF68 = 0;
   Ld_FF60 = 0;
   Ld_FF58 = 0;
   Ld_FF50 = 0;
   Ld_FF48 = 0;
   Ld_FF40 = 0;
   Ld_FF38 = 0;
   Ld_FF30 = 0;
   Ld_FF28 = Bid;
   Ld_FF20 = Ask;
   Ld_FF18 = iClose(NULL, 0, 0);
   Ld_FF10 = iOpen(NULL, 0, 0);
   Ll_FF08 = TimeCurrent();
   Lb_FF07 = false;
   Id_0058 = (Fa_d_11 * 2);
   Ld_FFC0 = AccountBalance();
   Ld_FFE0 = SymbolInfoDouble(Is_04E8, 34);
   Ld_FFD8 = SymbolInfoDouble(Is_04E8, 35);
   Ld_FFD0 = SymbolInfoDouble(Is_04E8, 36);
   Ld_FFC8 = Ld_FFE0;
   if (InpLotMode == 1) {
      Ld_FFC8 = InpFixedLot;
   } else {
      if (InpLotMode == 2) {
         Ld_FFB0 = ((InpPercentLot * AccountBalance()) / 100);
         Ld_FFB8 = MarketInfo(Is_04E8, MODE_MARGINREQUIRED);
         Gd_0000 = (Ld_FFB0 / Ld_FFB8);
         Gd_0000 = round((Gd_0000 / Ld_FFD0));
         Ld_FFC8 = (Ld_FFD0 * Gd_0000);
         if ((Ld_FFC8 < Ld_FFE0)) {
            Ld_FFC8 = Ld_FFE0;
         }
         if ((Ld_FFC8 > Ld_FFD8)) {
            Ld_FFC8 = Ld_FFD8;
         }
      }
   }
   Fa_i_0A = TimeDayOfWeek(Ll_FF08);
   if (Fa_i_0A != Fa_i_0B) {
      FuncArg_Boolean_00000008 = false;
      Fa_d_0F = 0;
   }
   Fa_i_0B = Fa_i_0A;
   Li_FFF8 = OrdersTotal();
   Fa_d_06 = 0;
   Ld_FEF8 = 0;
   Ld_FEF0 = 0;
   Li_FEEC = 0;
   Ld_FEE0 = 0;
   Ld_FED8 = 0;
   int Li_FE10[50];
   Ld_FDD0 = 0;
   Ld_FDC8 = 0;
   Li_FDC4 = 0;
   Li_FFFC = Li_FFF8 - 1;
   if (Li_FFFC >= 0) {
      do {
         if (OrderSelect(Li_FFFC, 0, 0) && OrderMagicNumber() == Fa_i_04 && OrderSymbol() == Is_04E8) {
            Ld_FFA8 = OrderOpenPrice();
            Li_FFF4 = OrderTicket();
            Li_FFF0 = OrderType();
            Ld_FFA0 = OrderLots();
            if (Li_FFF0 == 0) {
               if (Li_FFF4 > Li_FF9C) {
                  Ld_FF38 = Ld_FFA8;
                  Li_FF9C = Li_FFF4;
                  Gd_0000 = OrderProfit();
                  Gd_0000 = (Gd_0000 + OrderCommission());
                  Ld_FDC8 = (Gd_0000 + OrderSwap());
                  Li_FDC4 = Li_FFF4;
                  Ld_FF40 = Ld_FFA0;
               }
               Ld_FF58 = (((Ld_FFA8 - Id_0058) * Ld_FFA0) + Ld_FF58);
               Ld_FF68 = (Ld_FF68 + Ld_FFA0);
               Li_FF88 = Li_FF88 + 1;
               Li_FF94 = Li_FF94 + 1;
               Fa_d_06 = ((Ld_FFA8 * Ld_FFA0) + Fa_d_06);
               if ((OrderProfit() > 0)) {
                  Gd_0000 = OrderProfit();
                  Gd_0000 = (Gd_0000 + OrderCommission());
                  Ld_FEF8 = ((Gd_0000 + OrderSwap()) + Ld_FEF8);
               }
            }
            if (Li_FFF0 == 1) {
               if (Li_FFF4 > Li_FF98) {
                  Ld_FF30 = Ld_FFA8;
                  Li_FF98 = Li_FFF4;
                  Gd_0000 = OrderProfit();
                  Gd_0000 = (Gd_0000 + OrderCommission());
                  Ld_FDD0 = (Gd_0000 + OrderSwap());
                  Li_FDC4 = Li_FFF4;
                  Ld_FF48 = Ld_FFA0;
               }
               Ld_FF50 = (((Ld_FFA8 + Id_0058) * Ld_FFA0) + Ld_FF50);
               Ld_FF60 = (Ld_FF60 + Ld_FFA0);
               Li_FF84 = Li_FF84 + 1;
               Li_FF94 = Li_FF94 + 1;
               Fa_d_06 = ((Ld_FFA8 * Ld_FFA0) + Fa_d_06);
               if ((OrderProfit() > 0)) {
                  Gd_0000 = OrderProfit();
                  Gd_0000 = (Gd_0000 + OrderCommission());
                  Ld_FEF0 = ((Gd_0000 + OrderSwap()) + Ld_FEF0);
               }
            }
            Ld_FF78 = (Ld_FF78 + OrderProfit());
         }
         Li_FFFC = Li_FFFC - 1;
      } while (Li_FFFC >= 0);
   }
   Fa_i_05 = Li_FF94;
   Fa_d_10 = Ld_FF78;
   Gi_0000 = Li_FF84 + Li_FF88;
   if (Gi_0000 > 0) {
      Fa_d_06 = NormalizeDouble((Fa_d_06 / (Ld_FF68 + Ld_FF60)), _Digits);
   }
   Li_FDC0 = 16711680;
   if ((Ld_FF60 > 0)) {
      Li_FDC0 = 255;
   }
   if ((Ld_FF68 > 0) || (Ld_FF60 > 0)) {

      Gi_0000 = 3;
      Gi_0001 = 0;
      Gd_0002 = Fa_d_06;
      tmp_str0000 = "Avg" + Fa_s_00;
      tmp_str0001 = tmp_str0000;
      Gi_0003 = Li_FDC0;
      if (tmp_str0000 == "") {
         Gl_0005 = Time[0];
         tmp_str0001 = DoubleToString(Gl_0005, 0);
      }
      if ((Gd_0002 <= 0)) {
         Gd_0002 = Bid;
      }
      if (ObjectFind(tmp_str0001) < 0) {
         ObjectCreate(0, tmp_str0001, OBJ_HLINE, 0, 0, 0, 0, 0, 0, 0);
      }
      ObjectSet(tmp_str0001, OBJPROP_PRICE1, Gd_0002);
      ObjectSet(tmp_str0001, OBJPROP_COLOR, Gi_0003);
      ObjectSet(tmp_str0001, OBJPROP_STYLE, Gi_0001);
      ObjectSet(tmp_str0001, OBJPROP_WIDTH, Gi_0000);
   } else {
      tmp_str0000 = "Avg" + Fa_s_00;
      ObjectDelete(tmp_str0000);
   }
   if (InpUseTrailingStop) {
      func_1088(InpTrailStart, InpTrailStop, Fa_d_06, Fa_i_04);
   }
   if (InpUseBreakEven) {
      func_1110(InpBreakEvenStart, InpBreakEvenStep, Fa_d_06, Fa_i_04);
   }
   if (Li_FF94 == 0) {
      Fa_d_0F = (Fa_d_0F + Fa_d_10);
      FuncArg_Boolean_00000007 = false;
   }
   Gd_0005 = (Fa_d_0F + Ld_FF78);
   Gd_0006 = Gd_0005;
   Fa_d_15 = Gd_0005;
   if ((DailyTarget > 0) && (Gd_0006 >= DailyTarget)) {
      FuncArg_Boolean_00000008 = true;
   }
   if (FuncArg_Boolean_00000007) {
      if ((Fa_i_09 > 0 && Ld_FF28 >= Fa_d_0C)
            || (Fa_i_09 < 0 && Ld_FF20 <= Fa_d_0C)) {

         Lb_FF82 = true;
      }
   }
   if (!FuncArg_Boolean_00000007) {
      if (Li_FF94 > 0 && Ib_0024 == false) {
         if (OpenNewOrdersGrid == true && FuncArg_Boolean_00000002) {
            if (GridAllDirect) {
               if (Li_FF88 > 0 && ((Ld_FF20 - Ld_FF38) >= Fa_d_12)) {
                  Lb_FF81 = true;
               }
               if (Li_FF84 > 0 && ((Ld_FF30 - Ld_FF28) >= Fa_d_12)) {
                  Lb_FF80 = true;
               }
            }
            if (Li_FF88 > 0 && ((Ld_FF38 - Ld_FF20) >= Fa_d_12)) {
               Lb_FF81 = true;
            }
            if (Li_FF84 > 0 && ((Ld_FF28 - Ld_FF30) >= Fa_d_12)) {
               Lb_FF80 = true;
            }
         }
      } else {
         if (InpOpenNewOrders && FuncArg_Boolean_00000002) {
            Li_FFE8 = TimeHour(Ll_FF08);
            string Ls_FD64[7] = { "", "", "", "", "", "", "" };
            Ls_FD64[0] = MondayHours;
            Ls_FD64[1] = TuesdayHours;
            Ls_FD64[2] = WednesdayHours;
            Ls_FD64[3] = ThursdayHours;
            Ls_FD64[4] = FridayHours;
            Ls_FD64[5] = SaturdayHours;
            Ls_FD64[6] = SundayHours;
            Gb_000D = func_1009(Ls_FD64);
            ArrayFree(Ls_FD64);
            if (InpManualInitGrid || !UseTimeFilter || Gb_000D != false) {

               if (Fa_i_01 == 1) {
                  Lb_FF80 = true;
               }
               if (Fa_i_01 == -1) {
                  Lb_FF81 = true;
               }
            }
         }
      }
   } else {
      if (Fa_i_09 > 0 && (Ld_FF28 <= Fa_d_0E)) {
         Lb_FF81 = true;
      }
      if (Fa_i_09 < 0 && (Ld_FF20 >= Fa_d_0D)) {
         Lb_FF80 = true;
      }
   }
   if (InpHedge > 0 && FuncArg_Boolean_00000007 == false) {
      if (Lb_FF81 && Li_FF88 == InpHedge) {
         Fa_d_0E = Ld_FF28;
         FuncArg_Boolean_00000007 = true;
         ArrayFree(Li_FE10);
         return ;
      }
      if (Lb_FF80 && Li_FF84 == InpHedge) {
         Fa_d_0D = Ld_FF20;
         FuncArg_Boolean_00000007 = true;
         ArrayFree(Li_FE10);
         return ;
      }
   }
   if ((Fa_d_03 != 0) && Li_FF94 == 0) {
      Ld_FFC8 = Fa_d_03;
   } else {
      Ld_FDB8 = (Ld_FF48 + Ld_FF40);
      if (Lb_FF81) {
         Gd_000E = Ld_FFD0;
         Gi_000F = InpGridStepLot;
         Gd_0010 = Ld_FFC8;
         Gd_0011 = Ld_FDB8;
         Gi_0012 = Li_FF94;
         Gi_0013 = 0;
         Gd_0014 = 0;
         returned_i = TypeGridLot;
         if (returned_i <= 3) {
            if (returned_i == 0) {

               if (Gi_0013 == 0 || Gi_0013 == 1) {

                  Gd_0014 = Gd_0010;
               }
            }
            if (returned_i == 1) {

               Gd_0014 = (Gd_0010 * Gi_0012);
            }
            if (returned_i == 2) {

               returned_double = MathPow(InpGridFactor, Gi_0012);
               Gd_0015 = (Gd_0010 * returned_double);
               Gd_0015 = round((Gd_0015 / SymbolInfoDouble(Is_04E8, 36)));
               Gd_0014 = (SymbolInfoDouble(Is_04E8, 36) * Gd_0015);
            }
            if (returned_i == 3) {

               if (Gi_0012 == 0) {
                  Gd_0014 = Gd_0010;
               }
               Gi_0015 = Gi_0012 % Gi_000F;
               if (Gi_0015 == 0) {
                  Gd_0014 = (Gd_0011 + Gd_0010);
               } else {
                  Gd_0014 = Gd_0011;
               }
            }
         }
         Gd_0015 = round((Gd_0014 / Gd_000E));
         Ld_FFC8 = (Gd_000E * Gd_0015);
      }
      if (Lb_FF80) {
         Gd_0015 = Ld_FFD0;
         Gi_0016 = InpGridStepLot;
         Gd_0017 = Ld_FFC8;
         Gd_0018 = Ld_FDB8;
         Gi_0019 = Li_FF94;
         Gi_001A = 1;
         Gd_001B = 0;
         returned_i = TypeGridLot;
         if (returned_i <= 3) {
            if (returned_i == 0) {

               if (Gi_001A == 0 || Gi_001A == 1) {

                  Gd_001B = Gd_0017;
               }
            }
            if (returned_i == 1) {

               Gd_001B = (Gd_0017 * Gi_0019);
            }
            if (returned_i == 2) {

               returned_double = MathPow(InpGridFactor, Gi_0019);
               Gd_001C = (Gd_0017 * returned_double);
               Gd_001C = round((Gd_001C / SymbolInfoDouble(Is_04E8, 36)));
               Gd_001B = (SymbolInfoDouble(Is_04E8, 36) * Gd_001C);
            }
            if (returned_i == 3) {

               if (Gi_0019 == 0) {
                  Gd_001B = Gd_0017;
               }
               Gi_001C = Gi_0019 % Gi_0016;
               if (Gi_001C == 0) {
                  Gd_001B = (Gd_0018 + Gd_0017);
               } else {
                  Gd_001B = Gd_0018;
               }
            }
         }
         Gd_001C = round((Gd_001B / Gd_0015));
         Ld_FFC8 = (Gd_0015 * Gd_001C);
      }
      if (FuncArg_Boolean_00000007) {
         if (Lb_FF81) {
            Gd_001C = (Ld_FF60 * 3);
            Gd_001C = round((Gd_001C / Ld_FFD0));
            Ld_FFC8 = ((Ld_FFD0 * Gd_001C) - Ld_FF68);
         }
         if (Lb_FF80) {
            Gd_001C = (Ld_FF68 * 3);
            Gd_001C = round((Gd_001C / Ld_FFD0));
            Ld_FFC8 = ((Ld_FFD0 * Gd_001C) - Ld_FF60);
         }
      }
   }
   if ((Ld_FFC8 < Ld_FFE0)) {
      Ld_FFC8 = Ld_FFE0;
   }
   if ((Ld_FFC8 > Ld_FFD8)) {
      Ld_FFC8 = Ld_FFD8;
   }
   if ((Ld_FFC8 > InpMaxLot)) {
      Ld_FFC8 = InpMaxLot;
   }
   if ((MaxLots > 0)) {
      Gd_001C = 0;
      Gi_001D = OrdersTotal() - 1;
      Gi_001E = Gi_001D;
      if (Gi_001D >= 0) {
         do {
            if (OrderSelect(Gi_001E, 0, 0)) {
               if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                  Gd_001C = (Gd_001C + OrderLots());
               }
            }
            Gi_001E = Gi_001E - 1;
         } while (Gi_001E >= 0);
      }
      if (((Ld_FFC8 + NormalizeDouble(Gd_001C, 2)) > MaxLots)) {
         Gd_001D = 0;
         Gi_001F = OrdersTotal() - 1;
         Gi_0020 = Gi_001F;
         if (Gi_001F >= 0) {
            do {
               if (OrderSelect(Gi_0020, 0, 0)) {
                  if (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2) {

                     Gd_001D = (Gd_001D + OrderLots());
                  }
               }
               Gi_0020 = Gi_0020 - 1;
            } while (Gi_0020 >= 0);
         }
         Ld_FFC8 = (MaxLots - NormalizeDouble(Gd_001D, 2));
      }
   }
   if ((InpManualInitGrid && Li_FF94 == 0)
         || InpOpenOneCandle == false || Fa_l_14 != iTime(NULL, InpTimeframeBarOpen, 0)) {

      Fa_l_14 = iTime(NULL, InpTimeframeBarOpen, 0);
      if (Lb_FF81) {
         if (((Ld_FF68 + Ld_FFC8) == Ld_FF60)) {
            Ld_FFC8 = (Ld_FF60 + Ld_FFE0);
         }
         tmp_str0002 = Fa_s_00;
         Li_FFEC = func_1063(0, Ld_FFC8, Ld_FF20, Fa_i_04, tmp_str0002, 0, 0);
         if (Li_FFEC > 0) {
            Lb_FF07 = OrderSelect(Li_FFEC, 1, 0);
            Ld_FFA8 = OrderOpenPrice();
            Ld_FF58 = ((Ld_FFA8 * Ld_FFC8) + Ld_FF58);
            Ld_FF68 = (Ld_FF68 + Ld_FFC8);
            Gd_001F = (Ld_FF58 - Ld_FF50);
            Fa_d_0C = (NormalizeDouble((Gd_001F / (Ld_FF68 - Ld_FF60)), _Digits) + Fa_d_13);
            if (FuncArg_Boolean_00000007 != true) {
               Ld_FF70 = Fa_d_0C;
            } else {
               Ld_FF70 = (Fa_d_0C + Fa_d_13);
            }
            if (Li_FF88 == 0) {
               Fa_d_0D = Ld_FFA8;
            }
            Fa_i_09 = 1;
            Lb_FF83 = true;
         }
      }
      if (Lb_FF80) {
         if (((Ld_FF60 + Ld_FFC8) == Ld_FF68)) {
            Ld_FFC8 = (Ld_FF68 + Ld_FFE0);
         }
         tmp_str0003 = Fa_s_00;
         Li_FFEC = func_1063(1, Ld_FFC8, Ld_FF28, Fa_i_04, tmp_str0003, 0, 0);
         if (Li_FFEC > 0) {
            Lb_FF07 = OrderSelect(Li_FFEC, 1, 0);
            Ld_FFA8 = OrderOpenPrice();
            Ld_FF50 = ((Ld_FFA8 * Ld_FFC8) + Ld_FF50);
            Ld_FF60 = (Ld_FF60 + Ld_FFC8);
            Gd_001F = (Ld_FF50 - Ld_FF58);
            Fa_d_0C = (NormalizeDouble((Gd_001F / (Ld_FF60 - Ld_FF68)), _Digits) - Fa_d_13);
            if (FuncArg_Boolean_00000007 != true) {
               Ld_FF70 = Fa_d_0C;
            } else {
               Ld_FF70 = (Fa_d_0C - Fa_d_13);
            }
            if (Li_FF84 == 0) {
               Fa_d_0E = Ld_FFA8;
            }
            Fa_i_09 = -1;
            Lb_FF83 = true;
         }
      }
   }
   if (Lb_FF83) {
      Li_FFF8 = OrdersTotal();
      Li_FFFC = Li_FFF8 - 1;
      if (Li_FFFC >= 0) {
         do {
            if (OrderSelect(Li_FFFC, 0, 0) && OrderMagicNumber() == Fa_i_04 && OrderSymbol() == Is_04E8) {
               Li_FFF0 = OrderType();
               if (Fa_i_09 > 0) {
                  if (Li_FFF0 == 0) {
                     Lb_FF07 = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), Ld_FF70, 0, 4294967295);
                  }
                  if (Li_FFF0 == 1) {
                     Lb_FF07 = OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FF70, OrderTakeProfit(), 0, 4294967295);
                  }
               }
               if (Fa_i_09 < 0) {
                  if (Li_FFF0 == 0) {
                     Lb_FF07 = OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FF70, OrderTakeProfit(), 0, 4294967295);
                  }
                  if (Li_FFF0 == 1) {
                     Lb_FF07 = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), Ld_FF70, 0, 4294967295);
                  }
               }
            }
            Li_FFFC = Li_FFFC - 1;
         } while (Li_FFFC >= 0);
      }
   }
   ArrayFree(Li_FE10);

}


//+------------------------------------------------------------------+
