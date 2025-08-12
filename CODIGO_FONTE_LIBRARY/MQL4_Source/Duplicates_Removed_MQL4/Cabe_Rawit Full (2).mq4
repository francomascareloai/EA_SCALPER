#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
//----

extern string Str = "1. SETTINGS FOR OPTIMIZATION";
extern bool QuickTesting = FALSE;
extern bool Optimization = FALSE;
extern int YearTest = 0;
extern int MonthTest = 0;
extern int WeekYear = 0;
extern int DayWeek = 7;
extern int Strategy = 0;
extern string Str0 = "2. GENERAL SETTINGS";
extern int TimeBroker = 3;
extern int Milliseconds = 100;
extern double Spread = 30.0;
extern int Slippage = 30;
extern bool ObDel = FALSE;
extern double DeviationCoefSL = 2.0;
extern string StrStrategy = "3. TRADING STRATEGIES";
extern bool Strategy_1 = TRUE;
extern bool Strategy_2 = TRUE;
extern bool Strategy_3 = TRUE;
extern bool Strategy_4 = TRUE;
extern string StrCalendarMonth = "4. TRADING MONTH";
extern bool January = TRUE;
extern bool February = TRUE;
extern bool March = TRUE;
extern bool April = TRUE;
extern bool May = TRUE;
extern bool June = TRUE;
extern bool July = TRUE;
extern bool August = TRUE;
extern bool September = TRUE;
extern bool October = TRUE;
extern bool November = TRUE;
extern bool December = TRUE;
extern string StrCalendarWEEK = "5. TRADING WEEK OF THE YEAR";
extern bool Week_1 = TRUE;
extern bool Week_2 = TRUE;
extern bool Week_3 = TRUE;
extern bool Week_4 = TRUE;
extern bool Week_5 = TRUE;
extern bool Week_6 = TRUE;
extern bool Week_7 = TRUE;
extern bool Week_8 = FALSE;
extern bool Week_9 = TRUE;
extern bool Week_10 = TRUE;
extern bool Week_11 = TRUE;
extern bool Week_12 = TRUE;
extern bool Week_13 = TRUE;
extern bool Week_14 = TRUE;
extern bool Week_15 = TRUE;
extern bool Week_16 = TRUE;
extern bool Week_17 = TRUE;
extern bool Week_18 = TRUE;
extern bool Week_19 = TRUE;
extern bool Week_20 = TRUE;
extern bool Week_21 = TRUE;
extern bool Week_22 = TRUE;
extern bool Week_23 = TRUE;
extern bool Week_24 = TRUE;
extern bool Week_25 = TRUE;
extern bool Week_26 = TRUE;
extern bool Week_27 = TRUE;
extern bool Week_28 = TRUE;
extern bool Week_29 = TRUE;
extern bool Week_30 = FALSE;
extern bool Week_31 = TRUE;
extern bool Week_32 = TRUE;
extern bool Week_33 = TRUE;
extern bool Week_34 = TRUE;
extern bool Week_35 = TRUE;
extern bool Week_36 = FALSE;
extern bool Week_37 = TRUE;
extern bool Week_38 = TRUE;
extern bool Week_39 = FALSE;
extern bool Week_40 = TRUE;
extern bool Week_41 = TRUE;
extern bool Week_42 = TRUE;
extern bool Week_43 = TRUE;
extern bool Week_44 = TRUE;
extern bool Week_45 = TRUE;
extern bool Week_46 = TRUE;
extern bool Week_47 = TRUE;
extern bool Week_48 = TRUE;
extern bool Week_49 = TRUE;
extern bool Week_50 = TRUE;
extern bool Week_51 = TRUE;
extern bool Week_52 = FALSE;
extern bool Week_53 = TRUE;
extern bool Week_54 = TRUE;
extern string StrCalendarDay = "6. TRADING DAYS OF THE WEEK";
extern bool Monday = TRUE;
extern bool Tuesday = TRUE;
extern bool Wednesday = TRUE;
extern bool Thursday = TRUE;
extern bool Friday = TRUE;
extern bool Saturday = FALSE;
extern bool Sunday = FALSE;
extern string Str1 = "7. STRATEGY 1 SETTINGS";
extern double MaxRisk = 0.75;
extern double FixLot = 0.01;
extern double TakeProfitCoef = 16.0;
extern double StopLossCoef = 0.17;
extern double OpenOrderCoef = 2.0;
extern int Magic = 1;
extern string iComment = "PRADO S1; R=0.75%;";
extern int TimeFrames = 1440;
extern int BarCount = 2;
extern int Bar = 1;
extern double OrderCoefLevel = 0.0;
extern double EveningCoef = 0.087;
extern int TralTF = 60;
extern int TralCoef = 2;
extern double BoomCoef = 0.03;
extern double BoomMinDistCoef = 0.4;
extern double BoomMaxPrc = 99.0;
extern double TralBoomStep = 20.0;
extern int StartTradeHour = 22;
extern int StartTradeMinute = 0;
extern int FinishTradeHour = 17;
extern int FinishTradeMinute = 59;
extern int EveningTacticsHour = 18;
extern int EveningTacticsMinute = 0;
extern int CloseAllHour = 19;
extern int CloseAllMinute = 0;
extern string Str2 = "8. STRATEGY 2 SETTINGS";
extern double MaxRisk2 = 0.75;
extern double FixLot2 = 0.01;
extern double TakeProfitCoef2 = 16.0;
extern double StopLossCoef2 = 0.17;
extern double OpenOrderCoef2 = 2.0;
extern int Magic2 = 2;
extern string iComment2 = "PRADO S2; R=0.75%;";
extern int TimeFrames2 = 1440;
extern int BarCount2 = 2;
extern int Bar2 = 1;
extern double OrderCoefLevel2 = 0.0;
extern double EveningCoef2 = 0.087;
extern int TralTF2 = 60;
extern int TralCoef2 = 4;
extern double BoomCoef2 = 0.03;
extern double BoomMinDistCoef2 = 0.29;
extern double BoomMaxPrc2 = 99.0;
extern double TralBoomStep2 = 20.0;
extern int StartTradeHour2 = 22;
extern int StartTradeMinute2 = 0;
extern int FinishTradeHour2 = 17;
extern int FinishTradeMinute2 = 59;
extern int EveningTacticsHour2 = 18;
extern int EveningTacticsMinute2 = 0;
extern int CloseAllHour2 = 19;
extern int CloseAllMinute2 = 0;
extern string Str3 = "9. STRATEGY 3 SETTINGS";
extern double MaxRisk3 = 0.75;
extern double FixLot3 = 0.01;
extern double TakeProfitCoef3 = 16.0;
extern double StopLossCoef3 = 0.18;
extern double OpenOrderCoef3 = 0.2;
extern int Magic3 = 3;
extern string iComment3 = "PRADO S3; R=0.75%;";
extern int TimeFrames3 = 60;
extern int BarCount3 = 28;
extern int Bar3 = 1;
extern double OrderCoefLevel3 = 0.0;
extern double EveningCoef3 = 0.087;
extern int TralTF3 = 60;
extern int TralCoef3 = 2;
extern double BoomCoef3 = 0.03;
extern double BoomMinDistCoef3 = 0.4;
extern double BoomMaxPrc3 = 99.0;
extern double TralBoomStep3 = 20.0;
extern int StartTradeHour3 = 22;
extern int StartTradeMinute3 = 0;
extern int FinishTradeHour3 = 17;
extern int FinishTradeMinute3 = 59;
extern int EveningTacticsHour3 = 18;
extern int EveningTacticsMinute3 = 0;
extern int CloseAllHour3 = 19;
extern int CloseAllMinute3 = 0;
extern string Str4 = "10. STRATEGY 4 SETTINGS";
extern double MaxRisk4 = 0.75;
extern double FixLot4 = 0.01;
extern double TakeProfitCoef4 = 16.0;
extern double StopLossCoef4 = 0.18;
extern double OpenOrderCoef4 = 0.4;
extern int Magic4 = 4;
extern string iComment4 = "PRADO S4; R=0.75%;";
extern int TimeFrames4 = 60;
extern int BarCount4 = 28;
extern int Bar4 = 1;
extern double OrderCoefLevel4 = 0.0;
extern double EveningCoef4 = 0.087;
extern int TralTF4 = 60;
extern int TralCoef4 = 4;
extern double BoomCoef4 = 0.03;
extern double BoomMinDistCoef4 = 0.29;
extern double BoomMaxPrc4 = 99.0;
extern double TralBoomStep4 = 20.0;
extern int StartTradeHour4 = 22;
extern int StartTradeMinute4 = 0;
extern int FinishTradeHour4 = 17;
extern int FinishTradeMinute4 = 59;
extern int EveningTacticsHour4 = 18;
extern int EveningTacticsMinute4 = 0;
extern int CloseAllHour4 = 19;
extern int CloseAllMinute4 = 0;


 string param = "+++ Parameter Setting +++";
 double TakeProfit = 15.0;
 double Lots = 0.1;
 int MaxTrades = 100;
 double Multi_Lot = 2.0;
 int Digit_Lot = 2;
  double Max_Lots = 400.0;
  int Pips = 5;
  double Start_OP = 1.1;
  double Stop_OP = 0.9;
  int slippage = 2;
  double TrailingStop = 0.0;
  double InitialStop = 1600.0;
  string Stealth = "+++ Stealth Mode +++";
  string Note = "for Stealth Take Profit must greater than Pips_Stealth";
  bool Stealth_mode = FALSE;
  int Pips_Stealth = 11;
  string MM = "+++ MM Setting +++";
  bool mm = FALSE;
  double Multipler = 1.0;
  bool ReverseCondition = FALSE;
  string Other = "+++ Other Setting +++";
  color TitleColor = OrangeRed;
  color Line_Color = Yellow;
  color TextColor = Lime;
string gs_236;
int g_count_244 = 0;
int g_pos_248 = 0;
double g_price_252 = 0.0;
double g_price_260 = 0.0;
double g_ask_268 = 0.0;
double g_bid_276 = 0.0;
double g_lots_284 = 0.0;
double g_lots_292 = 0.0;
string gs_300;
int g_cmd_308 = OP_BUY;
int gi_312 = 0;
bool gi_316 = TRUE;
double g_order_open_price_320 = 0.0;
int gi_328 = 0;
double gd_unused_332 = 0.0;
int gi_unused_340 = 0;
int gi_unused_344 = 0;
double gd_unused_348 = 0.0;
double gd_unused_356 = 0.0;
double gd_unused_364 = 0.0;
double gd_372 = 0.0;
string gs_unused_380 = "";
string gs_unused_388 = "";

int init() {

//--- 

   ObjectsDeleteAll();
   return (0);
}

int deinit() {
   ObjectsDeleteAll(0, OBJ_LABEL);
   return (0);
}

int start() {
   int li_12;
   double icustom_224;
   double icustom_232;
   double icustom_240;
   double icustom_248;
   int slippage_0 = slippage;
   if (mm) g_lots_284 = NormalizeDouble(AccountBalance() * Multipler / 10000.0, Digit_Lot);
   else g_lots_284 = Lots;
   if (g_lots_284 > 100.0) g_lots_284 = 100;
   g_count_244 = 0;
   for (g_pos_248 = 0; g_pos_248 < OrdersTotal(); g_pos_248++) {
      OrderSelect(g_pos_248, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) g_count_244++;
   }
   if (gd_372 == 0.0) gd_372 = 5;
   if (gi_328 > g_count_244) {
      for (g_pos_248 = OrdersTotal(); g_pos_248 >= 0; g_pos_248--) {
         OrderSelect(g_pos_248, SELECT_BY_POS, MODE_TRADES);
         g_cmd_308 = OrderType();
         if (OrderSymbol() == Symbol()) {
            if (g_cmd_308 == OP_BUY) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage_0, Blue);
            if (g_cmd_308 != OP_SELL) return (0);
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage_0, Red);
            return (0);
         }
      }
   }
   gi_328 = g_count_244;
   if (g_count_244 >= MaxTrades) gi_316 = FALSE;
   else gi_316 = TRUE;
   if (g_order_open_price_320 == 0.0) {
      for (g_pos_248 = 0; g_pos_248 < OrdersTotal(); g_pos_248++) {
         OrderSelect(g_pos_248, SELECT_BY_POS, MODE_TRADES);
         g_cmd_308 = OrderType();
         if (OrderSymbol() == Symbol()) {
            g_order_open_price_320 = OrderOpenPrice();
            if (g_cmd_308 == OP_BUY) gi_312 = 2;
            if (g_cmd_308 == OP_SELL) gi_312 = 1;
         }
      }
   }
   int li_unused_4 = 0;
   gs_300 = "Waiting.....";
   int li_8 = 13;
   int li_24 = 10;
   int li_28 = 5;
   double ld_32 = (iHigh(NULL, PERIOD_D1, 0) - iLow(NULL, PERIOD_D1, 0)) / Point;
   double ld_40 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   double ld_48 = (iHigh(NULL, PERIOD_D1, 2) - iLow(NULL, PERIOD_D1, 2)) / Point;
   double ld_56 = (iHigh(NULL, PERIOD_D1, 3) - iLow(NULL, PERIOD_D1, 3)) / Point;
   double ld_64 = (iHigh(NULL, PERIOD_D1, 4) - iLow(NULL, PERIOD_D1, 4)) / Point;
   double ld_72 = (iHigh(NULL, PERIOD_D1, 5) - iLow(NULL, PERIOD_D1, 5)) / Point;
   double ld_80 = (iHigh(NULL, PERIOD_D1, 6) - iLow(NULL, PERIOD_D1, 6)) / Point;
   double ld_88 = (iHigh(NULL, PERIOD_D1, 7) - iLow(NULL, PERIOD_D1, 7)) / Point;
   double ld_96 = (iHigh(NULL, PERIOD_D1, 8) - iLow(NULL, PERIOD_D1, 8)) / Point;
   double ld_104 = (iHigh(NULL, PERIOD_D1, 9) - iLow(NULL, PERIOD_D1, 9)) / Point;
   double ld_112 = (iHigh(NULL, PERIOD_D1, 10) - iLow(NULL, PERIOD_D1, 10)) / Point;
   double ld_120 = (iHigh(NULL, PERIOD_D1, 11) - iLow(NULL, PERIOD_D1, 11)) / Point;
   double ld_128 = (iHigh(NULL, PERIOD_D1, 12) - iLow(NULL, PERIOD_D1, 12)) / Point;
   double ld_136 = (iHigh(NULL, PERIOD_D1, 13) - iLow(NULL, PERIOD_D1, 13)) / Point;
   double ld_144 = (iHigh(NULL, PERIOD_D1, 14) - iLow(NULL, PERIOD_D1, 14)) / Point;
   double ld_152 = (iHigh(NULL, PERIOD_D1, 15) - iLow(NULL, PERIOD_D1, 15)) / Point;
   double ld_160 = (iHigh(NULL, PERIOD_D1, 16) - iLow(NULL, PERIOD_D1, 16)) / Point;
   double ld_168 = (iHigh(NULL, PERIOD_D1, 17) - iLow(NULL, PERIOD_D1, 17)) / Point;
   double ld_176 = (iHigh(NULL, PERIOD_D1, 18) - iLow(NULL, PERIOD_D1, 18)) / Point;
   double ld_184 = (iHigh(NULL, PERIOD_D1, 19) - iLow(NULL, PERIOD_D1, 19)) / Point;
   double ld_192 = (iHigh(NULL, PERIOD_D1, 20) - iLow(NULL, PERIOD_D1, 20)) / Point;
   double ld_200 = (iHigh(NULL, PERIOD_D1, 21) - iLow(NULL, PERIOD_D1, 21)) / Point;
   double ld_208 = (iHigh(NULL, PERIOD_D1, 22) - iLow(NULL, PERIOD_D1, 22)) / Point;
   double ld_216 = (ld_40 + ld_48 + ld_56 + ld_64 + ld_72 + ld_80 + ld_88 + ld_96 + ld_104 + ld_112 + ld_120 + ld_128 + ld_136 + ld_144 + ld_152 + ld_160 + ld_168 + ld_176 +
      ld_184 + ld_192 + ld_200 + ld_208) / 44.0;
   if (ld_32 > ld_216 * Start_OP && ld_32 < 2.0 * ld_216 * Stop_OP) {
      icustom_224 = iCustom(Symbol(), 0, "Ruwet", 0, li_8, 0, 0, 1, 1, 0, 0, 0);
      icustom_232 = iCustom(Symbol(), 0, "Ruwet", 0, li_8, 0, 0, 1, 1, 0, 0, 1);
      icustom_240 = iCustom(Symbol(), 0, "BBSTOP", li_24, 1, 1, 1, 1, 1000, 0, 0);
      icustom_248 = iCustom(Symbol(), 0, "BBSTOP", li_24, 1, 1, 1, 1, 1000, 1, 0);
      if (icustom_224 > icustom_232 && icustom_240 > 0.0 && icustom_224 - icustom_232 > li_28 / 1000) {
         li_12 = 2;
         gs_300 = "UP";
      } else {
         if (icustom_224 < icustom_232 && icustom_248 > 0.0 && icustom_224 - icustom_232 < (-1 * li_28) / 1000) {
            li_12 = 1;
            gs_300 = "DOWN";
         }
      }
   }
   Comment("\n Batas Atas : ", DoubleToStr(2.0 * ld_216 * Stop_OP, 0), 
      "\n Mulai OP : ", DoubleToStr(ld_216 * Start_OP, 0), 
   "\n sekarang : ", DoubleToStr(ld_32, 0));
   if (g_count_244 < 1) {
      gi_312 = 3;
      if (li_12 == 1) gi_312 = 1;
      if (li_12 == 2) gi_312 = 2;
      if (li_12 == 0) gi_312 = 0;
      if (ReverseCondition) {
         if (gi_312 == 1) gi_312 = 2;
         else
            if (gi_312 == 2) gi_312 = 1;
      }
   }
   for (g_pos_248 = OrdersTotal(); g_pos_248 >= 0; g_pos_248--) {
      OrderSelect(g_pos_248, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_SELL) {
            if (TrailingStop > 0.0) {
               if (OrderOpenPrice() - Ask >= (TrailingStop + Pips) * Point) {
                  if (OrderStopLoss() > Ask + Point * TrailingStop) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderClosePrice() - TakeProfit * Point - TrailingStop * Point, 800, Purple);
                     return (0);
                  }
               }
            }
         }
         if (OrderType() == OP_BUY) {
            if (TrailingStop > 0.0) {
               if (Bid - OrderOpenPrice() >= (TrailingStop + Pips) * Point) {
                  if (OrderStopLoss() < Bid - Point * TrailingStop) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderClosePrice() + TakeProfit * Point + TrailingStop * Point, 800, Yellow);
                     return (0);
                  }
               }
            }
         }
      }
   }
   gd_unused_332 = 0;
   gi_unused_340 = 0;
   gi_unused_344 = 0;
   gd_unused_348 = 0;
   gd_unused_356 = 0;
   if (gi_312 == 1 && gi_316) {
      if (Bid - g_order_open_price_320 >= Pips * Point || g_count_244 < 1) {
         g_bid_276 = Bid;
         g_order_open_price_320 = 0;
         if (TakeProfit == 0.0) g_price_260 = 0;
         else g_price_260 = g_bid_276 - TakeProfit * Point;
         if (InitialStop == 0.0) g_price_252 = 0;
         else g_price_252 = g_bid_276 + InitialStop * Point;
         if (g_count_244 != 0) {
            g_lots_292 = g_lots_284;
            for (g_pos_248 = 1; g_pos_248 <= g_count_244; g_pos_248++) g_lots_292 = NormalizeDouble(Multi_Lot * g_lots_292, Digit_Lot);
         } else g_lots_292 = g_lots_284;
         if (g_lots_292 > Max_Lots) g_lots_292 = Max_Lots;
         OrderSend(Symbol(), OP_SELL, g_lots_292, g_bid_276, slippage_0, g_price_252, g_price_260, "My Robo - Sell " + g_count_244, Magic, 0, Red);
         return (0);
      }
   }
   if (gi_312 == 2 && gi_316) {
      if (g_order_open_price_320 - Ask >= Pips * Point || g_count_244 < 1) {
         g_ask_268 = Ask;
         g_order_open_price_320 = 0;
         if (TakeProfit == 0.0) g_price_260 = 0;
         else g_price_260 = g_ask_268 + TakeProfit * Point;
         if (InitialStop == 0.0) g_price_252 = 0;
         else g_price_252 = g_ask_268 - InitialStop * Point;
         if (g_count_244 != 0) {
            g_lots_292 = g_lots_284;
            for (g_pos_248 = 1; g_pos_248 <= g_count_244; g_pos_248++) g_lots_292 = NormalizeDouble(Multi_Lot * g_lots_292, Digit_Lot);
         } else g_lots_292 = g_lots_284;
         if (g_lots_292 > Max_Lots) g_lots_292 = Max_Lots;
         OrderSend(Symbol(), OP_BUY, g_lots_292, g_ask_268, slippage_0, g_price_252, g_price_260, "My Robo - Buy " + g_count_244, Magic, 0, Blue);
         return (0);
      }
   }
   gs_236 = "Normal Mode";
   if (Stealth_mode) {
      Scalper();
      gs_236 = "Stealth Mode";
   }
   Display_Info();
   return (0);
}

void Display_Info() {
   int li_4;
   int li_0 = 65280;
   if (AccountEquity() - AccountBalance() < 0.0) li_0 = 255;
   if (Seconds() >= 0 && Seconds() < 10) li_4 = 255;
   if (Seconds() >= 10 && Seconds() < 20) li_4 = 15631086;
   if (Seconds() >= 20 && Seconds() < 30) li_4 = 42495;
   if (Seconds() >= 30 && Seconds() < 40) li_4 = 16711680;
   if (Seconds() >= 40 && Seconds() < 50) li_4 = 65535;
   if (Seconds() >= 50 && Seconds() <= 59) li_4 = 16776960;
   string ls_8 = "-------------------------------------------";
   LABEL("L01", "Arial", 9, 10, 10, Line_Color, 1, ls_8);
   LABEL("L02", "Arial", 14, 10, 25, li_4, 1, "::: Cabe Rawit :::");
   LABEL("L0i", "Arial", 10, 10, 45, TitleColor, 1, "-- The Spirit of Indonesia --");
   LABEL("L03", "Arial", 9, 10, 60, Line_Color, 1, ls_8);
   LABEL("L04", "Arial", 9, 10, 75, TextColor, 1, ">> Account Balance : " + DoubleToStr(AccountBalance(), 0));
   LABEL("L05", "Arial", 9, 10, 90, TextColor, 1, ">> Account Equity  : " + DoubleToStr(AccountEquity(), 0));
   LABEL("L07", "Arial", 9, 10, 105, TextColor, 1, ">> Server    : " + AccountServer());
   LABEL("L08", "Arial", 9, 10, 120, TextColor, 1, ">> Starting Lots   : " + DoubleToStr(Lots, 2));
   LABEL("L09", "Arial", 9, 10, 135, TextColor, 1, ">> Pip Spread      : " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0));
   LABEL("L10", "Arial", 9, 10, 150, li_0, 1, ">> Profit         : " + DoubleToStr(AccountEquity() - AccountBalance(), 0));
   LABEL("L110", "Arial", 9, 10, 165, TextColor, 1, ">> Level OP   :  " + g_count_244);
   LABEL("L120", "Arial", 9, 10, 180, TextColor, 1, ">> Lot OP   :  " + DoubleToStr(g_lots_292, 2));
   LABEL("L100", "Arial", 9, 12, 200, DarkSalmon, 1, ">> Trend   :  " + gs_300);
   LABEL("L130", "Arial", 9, 10, 220, Line_Color, 1, gs_236);
   LABEL("L11", "Arial", 10, 10, 240, li_4, 1, "::: (c) Dhonic 2011 :::");
   LABEL("L12", "Arial", 9, 10, 255, Line_Color, 1, ls_8);
}

void LABEL(string a_name_0, string a_fontname_8, int a_fontsize_16, int a_x_20, int a_y_24, color a_color_28, int a_corner_32, string a_text_36) {
   if (ObjectFind(a_name_0) < 0) ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(a_name_0, a_text_36, a_fontsize_16, a_fontname_8, a_color_28);
   ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_32);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_20);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_24);
}

void Scalper() {
   int cmd_0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      cmd_0 = OrderType();
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if (cmd_0 == OP_BUY && Bid - OrderOpenPrice() > Pips_Stealth * Point) {
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Blue);
            return;
         }
         if (cmd_0 == OP_SELL && OrderOpenPrice() - Ask > Pips_Stealth * Point) {
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Red);
            return;
         }
      }
   }
}
