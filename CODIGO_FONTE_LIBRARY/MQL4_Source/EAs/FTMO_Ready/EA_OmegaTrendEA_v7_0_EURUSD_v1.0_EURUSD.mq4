
#import "Kernel32.dll"
   void GetSystemTime(int& a0[]);
#import

extern bool NFA_Rules = FALSE;
extern int Max_Spread = 5;
extern int Max_Slippage = 2;
extern bool AutoGMT_Offset = TRUE;
extern int ManualGMT_Offset = 2;
extern bool DST_Usage = TRUE;
extern string X = "====== Omega Trend Settings =======";
extern int Indicator_TimeFrame = 60;
extern int Action_TimeFrame = 5;
extern int Volatility_Period = 27;
extern int Smooth_Factor = 0;
extern int Max_Width_Pips = 115;
extern int Min_Follow_Pips = 5;
extern double TrendLine_Level = 3.2;
extern double PivotLine_Level = 0.93;
extern double Bar_Acceleration = 1.25;
extern int Profit_Acceleration = 0;
extern string Y = "====== Signal 1 Settings =======";
bool gi_168 = FALSE;
extern int Signal_1 = 1;
extern bool RecoveryMode_1 = FALSE;
extern double Fixed_Lots_1 = 0.1;
extern double AutoMM_1 = 0.0;
extern double AutoMM_Max_1 = 10.0;
extern int Magic_1 = 10101;
extern int Signal_1_TakeProfit = 310;
extern int Signal_1_StopLoss = 0;
extern int Signal_1_StrongPips = 0;
bool gi_220 = TRUE;
extern bool Hour_Filtering = TRUE;
extern int TradeHour1 = 21;
extern int TradeHour2 = 19;
extern int TradeHour3 = 13;
extern int TradeHour4 = 9;
extern int TradeHour5 = 12;
extern int TradeHour6 = 4;
extern int TradeHour7 = 8;
extern int TradeHour8 = 14;
extern int TradeHour9 = 10;
extern bool Swing_Filtering = TRUE;
extern int Swing_MA_Period = 50;
int gi_272 = 1;
extern int Swing_Impulse = -60;
extern int NoTradeDay = 0;
extern string Z = "====== Signal 2 Settings =======";
bool gi_292 = FALSE;
extern int Signal_2 = 1;
extern bool RecoveryMode_2 = FALSE;
extern double Fixed_Lots_2 = 0.1;
extern double AutoMM_2 = 0.0;
extern double AutoMM_Max_2 = 10.0;
extern int Magic_2 = 20202;
extern double TargetFactor = 0.35;
extern int Signal_2_TakeProfit = 0;
extern int Signal_2_StopLoss = 0;
extern int Signal_2_Exit_Profit = 29;
extern int MinStop = 45;
extern bool IgnoreSmallStopTrades = TRUE;
int gi_360 = 3;
int gi_364 = 3;
int gi_368 = 50;
double gd_372 = 10.0;
double gd_380 = 1.05;
bool gi_388 = TRUE;
int gi_392 = 0;
double gd_396 = 0.01;
double gd_404 = 0.01;
double gd_412 = 0.01;
int gi_420 = 100000;
double gd_424 = 1000.0;
double gd_432 = 0.0001;
double gd_440 = 0.1;
int gi_448 = 2;
int gi_452 = 0;
double gd_456 = 0.0;
int gi_464 = 0;
int gi_468 = 0;
int gi_472 = 0;
int gi_476 = 0;
int gi_480 = 0;
int gi_484 = 0;
double gd_488 = 1.0;


int GMTOffset() {
   int lia_0[4];
   int lia_4[43];
   string ls_unused_16;
   GetSystemTime(lia_0);
   int li_36 = lia_0[0] & 65535;
   int li_40 = lia_0[0] >> 16;
   int li_44 = lia_0[1] >> 16;
   int li_48 = lia_0[2] & 65535;
   int li_52 = lia_0[2] >> 16;
   int li_56 = lia_0[3] & 65535;
   string ls_8 = FormatDateTime(li_36, li_40, li_44, li_48, li_52, li_56);
   double ld_28 = TimeCurrent() - StrToTime(ls_8);
   return (MathRound(ld_28 / 3600.0));
}

string FormatDateTime(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20) {
   string ls_24 = ai_4 + 100;
   ls_24 = StringSubstr(ls_24, 1);
   string ls_32 = ai_8 + 100;
   ls_32 = StringSubstr(ls_32, 1);
   string ls_40 = ai_12 + 100;
   ls_40 = StringSubstr(ls_40, 1);
   string ls_48 = ai_16 + 100;
   ls_48 = StringSubstr(ls_48, 1);
   string ls_56 = ai_20 + 100;
   ls_56 = StringSubstr(ls_56, 1);
   return (StringConcatenate(ai_0, ".", ls_24, ".", ls_32, " ", ls_40, ":", ls_48, ":", ls_56));
}

void init() {
   gi_388 = TRUE;
   Comment("");
   if (ObjectFind("Omega") >= 0) ObjectDelete("Omega");
   if (ObjectFind("Omega1") >= 0) ObjectDelete("Omega1");
   if (ObjectFind("BKGR") >= 0) ObjectDelete("BKGR");
   if (ObjectFind("BKGR1") >= 0) ObjectDelete("BKGR1");
   if (ObjectFind("BKGR2") >= 0) ObjectDelete("BKGR2");
   if (ObjectFind("BKGR3") >= 0) ObjectDelete("BKGR3");
}

int deinit() {
   Comment("");
   if (ObjectFind("Omega") >= 0) ObjectDelete("Omega");
   if (ObjectFind("Omega1") >= 0) ObjectDelete("Omega1");
   if (ObjectFind("BKGR") >= 0) ObjectDelete("BKGR");
   if (ObjectFind("BKGR1") >= 0) ObjectDelete("BKGR1");
   if (ObjectFind("BKGR2") >= 0) ObjectDelete("BKGR2");
   if (ObjectFind("BKGR3") >= 0) ObjectDelete("BKGR3");
   return (0);
}

int start() {
   string ls_48;
   double ld_80;
   double ld_88;
   int li_168;
   string ls_0 = "";
   if (gi_388) {
      gi_388 = FALSE;
      gd_396 = MarketInfo(Symbol(), MODE_MINLOT);
      gd_404 = MarketInfo(Symbol(), MODE_MAXLOT);
      gi_420 = MarketInfo(Symbol(), MODE_LOTSIZE);
      gd_412 = MarketInfo(Symbol(), MODE_LOTSTEP);
      gd_424 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
      if (Digits <= 3) gd_432 = 0.01;
      else gd_432 = 0.0001;
      if (Digits == 3 || Digits == 5) gd_440 = 0.1;
      else gd_440 = 1;
   }
   string ls_8 = Symbol() + "_" + DoubleToStr(Indicator_TimeFrame, 0) + "_" + DoubleToStr(MathMax(Magic_1, Magic_2), 0);
   if (IsTesting()) ls_8 = ls_8 + "_Test";
   if (gd_456 < Point || gi_452 < iTime(NULL, Indicator_TimeFrame, 1)) {
      gd_456 = MathMax(iCustom(NULL, Indicator_TimeFrame, "OmegaTrend_v7.0", 0, 0, 0, Volatility_Period, Smooth_Factor, Max_Width_Pips, Min_Follow_Pips, ls_8, TrendLine_Level,
         PivotLine_Level, Bar_Acceleration, Profit_Acceleration, 999, 0, 1), iCustom(NULL, Indicator_TimeFrame, "OmegaTrend_v7.0", 0, 0, 0, Volatility_Period, Smooth_Factor,
         Max_Width_Pips, Min_Follow_Pips, ls_8, TrendLine_Level, PivotLine_Level, Bar_Acceleration, Profit_Acceleration, 999, 1, 1));
      if (gd_456 < Point) {
         Comment("\nInitializing ...");
         return (0);
      }
      gi_452 = iTime(NULL, Indicator_TimeFrame, 1);
   }
   if (!IsTesting() && AutoGMT_Offset == TRUE) gi_448 = GMTOffset();
   else gi_448 = ManualGMT_Offset;
   gi_392 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   double ld_16 = 1;
   double ld_24 = 0;
   if (StringSubstr(AccountCurrency(), 0, 3) == "JPY") {
      ld_24 = MarketInfo("USDJPY" + StringSubstr(Symbol(), 6), MODE_BID);
      if (ld_24 > 0.1) ld_16 = ld_24;
      else ld_16 = 82;
   }
   if (StringSubstr(AccountCurrency(), 0, 3) == "GBP") {
      ld_24 = MarketInfo("GBPUSD" + StringSubstr(Symbol(), 6), MODE_BID);
      if (ld_24 > 0.1) ld_16 = 1 / ld_24;
      else ld_16 = 0.625;
   }
   if (StringSubstr(AccountCurrency(), 0, 3) == "EUR") {
      ld_24 = MarketInfo("EURUSD" + StringSubstr(Symbol(), 6), MODE_BID);
      if (ld_24 > 0.1) ld_16 = 1 / ld_24;
      else ld_16 = 0.7751937984;
   }
   double ld_32 = Fixed_Lots_1;
   if (AutoMM_1 > 0.0 && (!RecoveryMode_1)) ld_32 = MathMax(gd_396, MathMin(gd_404, MathCeil(MathMin(AutoMM_Max_1, AutoMM_1) / ld_16 / 100.0 * AccountFreeMargin() / gd_412 / (gi_420 / 100)) * gd_412));
   if (AutoMM_1 > 0.0 && RecoveryMode_1) ld_32 = f0_0(AutoMM_1, AutoMM_Max_1);
   double ld_40 = Fixed_Lots_2;
   if (AutoMM_2 > 0.0 && (!RecoveryMode_2)) ld_40 = MathMax(gd_396, MathMin(gd_404, MathCeil(MathMin(AutoMM_Max_2, AutoMM_2) / ld_16 / 100.0 * AccountFreeMargin() / gd_412 / (gi_420 / 100)) * gd_412));
   if (AutoMM_2 > 0.0 && RecoveryMode_2) ld_40 = f0_0(AutoMM_2, AutoMM_Max_2);
   if ((!IsTesting()) || IsVisualMode()) {
      if (!IsTesting() || TimeCurrent() >= gi_464 + 1 || iVolume(NULL, PERIOD_M1, 0) <= 1.0) {
         gi_464 = TimeCurrent();
         ls_0 = ls_0 
            + "\n  " 
            + "\n  " 
            + "\n  " 
            + "\n  " 
            + "\n   Account Holder: " + AccountName() 
            + "\n  ------------------------------------------------" 
         + "\n   Acount Type: ";
         if (IsDemo()) ls_0 = ls_0 + " DEMO";
         else ls_0 = ls_0 + " REAL";
         ls_0 = ls_0 
         + "\n   Account Leverage: " + AccountLeverage();
         ls_0 = ls_0 
         + "\n   Account Currency: " + AccountCurrency();
         if (DST_Usage == TRUE) ls_48 = "YES";
         if (DST_Usage == FALSE) ls_48 = "NO";
         ls_0 = ls_0 
            + "\n  ------------------------------------------------" 
            + "\n   GMT : " + TimeToStr(TimeCurrent() - 3600 * gi_448, TIME_DATE|TIME_MINUTES|TIME_SECONDS) 
            + "\n   Broker : " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS) 
            + "\n   Broker GMT Offset: " + gi_448 
         + "\n   DST_Usage: " + ls_48;
         ls_0 = ls_0 
         + "\n  ------------------------------------------------";
         ls_0 = ls_0 
         + "\n   Ballance: " + DoubleToStr(AccountBalance(), 1);
         ls_0 = ls_0 
         + "\n   Free Margin: " + DoubleToStr(AccountFreeMargin(), 1);
         if (Signal_1 != 0) {
            ls_0 = ls_0 
            + "\n  ------------------------------------------------";
            if (Signal_1 > 0) {
               ls_0 = ls_0 
               + "\n   Signal 1 is Active!";
            } else {
               ls_0 = ls_0 
               + "\n   Signal 1 in Stealth Mode";
            }
            if (AutoMM_1 > 0.0) {
               ls_0 = ls_0 
                  + "\n   AutoMM - ENABLED" 
               + "\n   Risk = " + DoubleToStr(AutoMM_1, 1) + "%";
            }
            if (RecoveryMode_1) {
               ls_0 = ls_0 
               + "\n   Recovery Mode - ENABLED";
            } else {
               ls_0 = ls_0 
               + "\n   Recovery Mode - DISABLED";
            }
            ls_0 = ls_0 
            + "\n   Trading Lots = " + DoubleToStr(ld_32, 2);
            if (Signal_1_StopLoss > 0) {
               ls_0 = ls_0 
               + "\n   SL = " + Signal_1_StopLoss + " pips";
            } else {
               ls_0 = ls_0 
               + "\n   StopLoss = auto";
            }
            if (Signal_1_TakeProfit > 0) {
               ls_0 = ls_0 
               + "\n   TakeProfit = " + Signal_1_TakeProfit + " pips";
            } else {
               ls_0 = ls_0 
               + "\n   TakeProfit = auto";
            }
         }
         if (Signal_2 != 0) {
            ls_0 = ls_0 
            + "\n  ------------------------------------------------";
            if (Signal_2 > 0) {
               ls_0 = ls_0 
               + "\n   Signal 2 is Active!";
            } else {
               ls_0 = ls_0 
               + "\n   Signal 2 in Stealth Mode";
            }
            if (AutoMM_1 > 0.0) {
               ls_0 = ls_0 
                  + "\n   AutoMM - ENABLED" 
               + "\n   Risk = " + DoubleToStr(AutoMM_1, 1) + "%";
            }
            if (RecoveryMode_1) {
               ls_0 = ls_0 
               + "\n   Recovery Mode - ENABLED";
            } else {
               ls_0 = ls_0 
               + "\n   Recovery Mode - DISABLED";
            }
            ls_0 = ls_0 
            + "\n   Trading Lots = " + DoubleToStr(ld_40, 2);
            if (Signal_2_StopLoss > 0) {
               ls_0 = ls_0 
               + "\n   StopLoss = " + Signal_2_StopLoss + " pips";
            } else {
               ls_0 = ls_0 
               + "\n   StopLoss = auto";
            }
            if (Signal_2_TakeProfit > 0) {
               ls_0 = ls_0 
               + "\n   TakeProfit = " + Signal_2_TakeProfit + " pips";
            } else {
               ls_0 = ls_0 
               + "\n   TakeProfit = auto";
            }
         }
         ls_0 = ls_0 
            + "\n  ------------------------------------------------" 
         + "\n   Spread = " + DoubleToStr((Ask - Bid) / gd_432, 1) + " pips";
         if (Ask - Bid > Max_Spread * gd_432) ls_0 = ls_0 + " - TOO HIGH";
         else ls_0 = ls_0 + " ";
         ls_0 = ls_0 
         + "\n  ------------------------------------------------";
         Comment(ls_0);
         if (ObjectFind("BKGR") < 0) {
            ObjectCreate("BKGR", OBJ_LABEL, 0, 0, 0);
            ObjectSetText("BKGR", "g", 36, "Webdings", Aqua);
            ObjectSet("BKGR", OBJPROP_CORNER, 0);
            ObjectSet("BKGR", OBJPROP_BACK, TRUE);
            ObjectSet("BKGR", OBJPROP_XDISTANCE, 5);
            ObjectSet("BKGR", OBJPROP_YDISTANCE, 15);
         }
         if (ObjectFind("BKGR1") < 0) {
            ObjectCreate("BKGR1", OBJ_LABEL, 0, 0, 0);
            ObjectSetText("BKGR1", "g", 36, "Webdings", Aqua);
            ObjectSet("BKGR1", OBJPROP_CORNER, 0);
            ObjectSet("BKGR1", OBJPROP_BACK, TRUE);
            ObjectSet("BKGR1", OBJPROP_XDISTANCE, 43);
            ObjectSet("BKGR1", OBJPROP_YDISTANCE, 15);
         }
         if (ObjectFind("BKGR2") < 0) {
            ObjectCreate("BKGR2", OBJ_LABEL, 0, 0, 0);
            ObjectSetText("BKGR2", "g", 36, "Webdings", Aqua);
            ObjectSet("BKGR2", OBJPROP_CORNER, 0);
            ObjectSet("BKGR2", OBJPROP_BACK, TRUE);
            ObjectSet("BKGR2", OBJPROP_XDISTANCE, 81);
            ObjectSet("BKGR2", OBJPROP_YDISTANCE, 15);
         }
         if (ObjectFind("BKGR3") < 0) {
            ObjectCreate("BKGR3", OBJ_LABEL, 0, 0, 0);
            ObjectSetText("BKGR3", "g", 36, "Webdings", Aqua);
            ObjectSet("BKGR3", OBJPROP_CORNER, 0);
            ObjectSet("BKGR3", OBJPROP_BACK, TRUE);
            ObjectSet("BKGR3", OBJPROP_XDISTANCE, 119);
            ObjectSet("BKGR3", OBJPROP_YDISTANCE, 15);
         }
         if (ObjectFind("Omega") < 0) {
            ObjectCreate("Omega", OBJ_LABEL, 0, 0, 0);
            ObjectSetText("Omega", "  OMEGA TREND EA ", 11, "Tahoma bold", Fuchsia);
            ObjectSet("Omega", OBJPROP_CORNER, 0);
            ObjectSet("Omega", OBJPROP_BACK, FALSE);
            ObjectSet("Omega", OBJPROP_XDISTANCE, 11);
            ObjectSet("Omega", OBJPROP_YDISTANCE, 24);
         }
         if (ObjectFind("Omega1") < 0) {
            ObjectCreate("Omega1", OBJ_LABEL, 0, 0, 0);
            ObjectSetText("Omega1", "www.omega-trend.com", 9, "Tahoma bold", DodgerBlue);
            ObjectSet("Omega1", OBJPROP_CORNER, 0);
            ObjectSet("Omega1", OBJPROP_BACK, FALSE);
            ObjectSet("Omega1", OBJPROP_XDISTANCE, 14);
            ObjectSet("Omega1", OBJPROP_YDISTANCE, 41);
         }
      }
   }
   if (Ask - Bid > Max_Spread * gd_432) return (0);
   if (!IsTradeAllowed()) return (0);
   if (Action_TimeFrame > 0 && iTime(NULL, Action_TimeFrame, 0) <= gi_468) return (0);
   if (Action_TimeFrame > 0) gi_468 = iTime(NULL, Action_TimeFrame, 0);
   int li_56 = 0;
   int li_60 = 0;
   int li_64 = 0;
   int li_68 = 0;
   int li_72 = 0;
   int li_76 = 0;
   double ld_104 = MathMax(iCustom(NULL, Indicator_TimeFrame, "OmegaTrend_v7.0", 0, 0, 0, Volatility_Period, Smooth_Factor, Max_Width_Pips, Min_Follow_Pips, ls_8, TrendLine_Level,
      PivotLine_Level, Bar_Acceleration, Profit_Acceleration, 999, 0, 0), iCustom(NULL, Indicator_TimeFrame, "OmegaTrend_v7.0", 0, 0, 0, Volatility_Period, Smooth_Factor,
      Max_Width_Pips, Min_Follow_Pips, ls_8, TrendLine_Level, PivotLine_Level, Bar_Acceleration, Profit_Acceleration, 999, 1, 0));
   double ld_112 = MathMax(iCustom(NULL, Indicator_TimeFrame, "OmegaTrend_v7.0", 0, 0, 0, Volatility_Period, Smooth_Factor, Max_Width_Pips, Min_Follow_Pips, ls_8, TrendLine_Level,
      PivotLine_Level, Bar_Acceleration, Profit_Acceleration, 999, 2, 0), iCustom(NULL, Indicator_TimeFrame, "OmegaTrend_v7.0", 0, 0, 0, Volatility_Period, Smooth_Factor,
      Max_Width_Pips, Min_Follow_Pips, ls_8, TrendLine_Level, PivotLine_Level, Bar_Acceleration, Profit_Acceleration, 999, 3, 0));
   bool li_120 = FALSE;
   bool li_124 = FALSE;
   bool li_128 = FALSE;
   bool li_132 = FALSE;
   bool li_136 = FALSE;
   bool li_140 = FALSE;
   bool li_144 = FALSE;
   bool li_148 = FALSE;
   if (ld_112 > Point && iTime(NULL, Indicator_TimeFrame, 1) - GlobalVariableGet(ls_8 + "_LastSignalTime") < 1.0) {
      if (Signal_1 != 0 && GlobalVariableGet(ls_8 + "_SignalType1") > 0.5 && Signal_1_StrongPips <= 0 || Bid > gd_456 + Signal_1_StrongPips * gd_432) {
         if (!gi_168) li_120 = TRUE;
         else li_128 = TRUE;
         if (gi_220 == TRUE && (!gi_168)) li_132 = TRUE;
         if (gi_220 == TRUE && gi_168) li_124 = TRUE;
      } else {
         if (Signal_1 != 0 && GlobalVariableGet(ls_8 + "_SignalType1") < -0.5 && Signal_1_StrongPips <= 0 || Bid < gd_456 - Signal_1_StrongPips * gd_432) {
            if (!gi_168) li_128 = TRUE;
            else li_120 = TRUE;
            if (gi_220 == TRUE && (!gi_168)) li_124 = TRUE;
            if (gi_220 == TRUE && gi_168) li_132 = TRUE;
         }
      }
      if (Signal_2 != 0 && GlobalVariableGet(ls_8 + "_SignalType2") > 0.5 && Bid - ld_104 > MinStop * gd_432 || (!IgnoreSmallStopTrades)) li_136 = TRUE;
      else
         if (Signal_2 != 0 && GlobalVariableGet(ls_8 + "_SignalType2") < -0.5 && ld_104 - Bid > MinStop * gd_432 || (!IgnoreSmallStopTrades)) li_144 = TRUE;
   }
   for (int li_96 = OrdersTotal() - 1; li_96 >= 0; li_96--) {
      if (!OrderSelect(li_96, SELECT_BY_POS, MODE_TRADES)) Print("Error in OrderSelect! Position:", li_96);
      else {
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
               li_72++;
               if (OrderMagicNumber() == Magic_1) li_56++;
               if (OrderMagicNumber() == Magic_2) li_64++;
            } else {
               li_76++;
               if (OrderMagicNumber() == Magic_1) li_60++;
               if (OrderMagicNumber() == Magic_2) li_68++;
            }
            if (OrderMagicNumber() == Magic_1) {
               if (OrderType() == OP_BUY) {
                  RefreshRates();
                  if (Signal_1_StopLoss <= 0) ld_80 = NormalizeDouble(ld_104, Digits);
                  else ld_80 = NormalizeDouble(MathMax(OrderOpenPrice(), Bid) - Signal_1_StopLoss * gd_432, Digits);
                  ld_88 = NormalizeDouble(OrderOpenPrice() + Signal_1_TakeProfit * gd_432, Digits);
                  if (Signal_1 > 0 && OrderStopLoss() < Point) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), MathMin(ld_80, NormalizeDouble(Bid - gi_392 * Point, Digits)), MathMax(ld_88, NormalizeDouble(Ask + gi_392 * Point,
                        Digits)), 0, Blue) == FALSE) Print("Error in OrderModify! Long Position at Bid:", Bid, " sl=", ld_80, " tp=", ld_88);
                  } else {
                     if (Signal_1 > 0 && OrderStopLoss() <= ld_80 - Point && ld_80 <= NormalizeDouble(Bid - gi_392 * Point, Digits))
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), ld_80, OrderTakeProfit(), 0, Blue) == FALSE) Print("Error in OrderModify! Long Position at Bid:", Bid, " sl=", ld_80);
                  }
                  if (!(li_124 == TRUE || Bid <= ld_80 || Bid >= ld_88)) continue;
                  for (int li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
                     RefreshRates();
                     if (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), Max_Slippage / gd_440, Violet)) {
                        li_72--;
                        li_56--;
                        break;
                     }
                     Sleep(MathMax(100, 1000 * gi_364));
                  }
               } else {
                  if (OrderType() != OP_SELL) continue;
                  RefreshRates();
                  if (Signal_1_StopLoss <= 0) ld_80 = NormalizeDouble(ld_104, Digits);
                  else ld_80 = NormalizeDouble(MathMin(OrderOpenPrice(), Ask) + Signal_1_StopLoss * gd_432, Digits);
                  ld_88 = NormalizeDouble(OrderOpenPrice() - Signal_1_TakeProfit * gd_432, Digits);
                  if (Signal_1 > 0 && OrderStopLoss() < Point) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), MathMax(ld_80, NormalizeDouble(Ask + gi_392 * Point, Digits)), MathMin(ld_88, NormalizeDouble(Bid - gi_392 * Point,
                        Digits)), 0, Red) == FALSE) Print("Error in OrderModify! Short Position at Ask:", Ask, " sl=", ld_80, " tp=", ld_88);
                  } else {
                     if (Signal_1 > 0 && OrderStopLoss() >= ld_80 + Point && ld_80 >= NormalizeDouble(Ask + gi_392 * Point, Digits))
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), ld_80, OrderTakeProfit(), 0, Red) == FALSE) Print("Error in OrderModify! Short Position at Bid:", Ask, " sl=", ld_80);
                  }
                  if (!(li_132 == TRUE || Ask >= ld_80 || Ask <= ld_88)) continue;
                  for (li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
                     RefreshRates();
                     if (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), Max_Slippage / gd_440, Violet)) {
                        li_76--;
                        li_60--;
                        break;
                     }
                     Sleep(MathMax(100, 1000 * gi_364));
                  }
                  continue;
               }
            }
            if (OrderMagicNumber() == Magic_2) {
               if (OrderType() == OP_BUY) {
                  RefreshRates();
                  if (Signal_2_StopLoss <= 0 && OrderOpenPrice() - ld_104 >= MinStop * gd_432) ld_80 = NormalizeDouble(ld_104, Digits);
                  if (Signal_2_StopLoss <= 0 && OrderOpenPrice() - ld_104 < MinStop * gd_432) ld_80 = NormalizeDouble(MathMax(OrderOpenPrice(), Bid) - MinStop * gd_432, Digits);
                  if (Signal_2_StopLoss > 0) ld_80 = NormalizeDouble(MathMax(OrderOpenPrice(), Bid) - Signal_2_StopLoss * gd_432, Digits);
                  if (Signal_2_TakeProfit <= 0) ld_88 = NormalizeDouble(OrderOpenPrice() + MathAbs(ld_104 - ld_112) * TargetFactor, Digits);
                  else ld_88 = NormalizeDouble(OrderOpenPrice() + Signal_2_TakeProfit * gd_432, Digits);
                  if (Signal_2 > 0 && OrderStopLoss() < Point) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), MathMin(ld_80, NormalizeDouble(Bid - gi_392 * Point, Digits)), MathMax(ld_88, NormalizeDouble(Ask + gi_392 * Point,
                        Digits)), 0, Blue) == FALSE) Print("Error in OrderModify! Long Position at Bid:", Bid, " sl=", ld_80, " tp=", ld_88);
                  } else {
                     if (Signal_2 > 0 && OrderStopLoss() <= ld_80 - Point && ld_80 <= NormalizeDouble(Bid - gi_392 * Point, Digits))
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), ld_80, OrderTakeProfit(), 0, Blue) == FALSE) Print("Error in OrderModify! Long Position at Bid:", Bid, " sl=", ld_80);
                  }
                  if (!(li_140 == TRUE || Bid <= ld_80 || Bid >= ld_88 || (Signal_2_Exit_Profit > 0 && Bid - OrderOpenPrice() >= Signal_2_Exit_Profit * gd_432 && iClose(NULL, PERIOD_M5,
                     1) < iOpen(NULL, PERIOD_M5, 1)))) continue;
                  for (li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
                     RefreshRates();
                     if (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), Max_Slippage / gd_440, Violet)) {
                        li_72--;
                        li_64--;
                        break;
                     }
                     Sleep(MathMax(100, 1000 * gi_364));
                  }
                  continue;
               }
               if (OrderType() == OP_SELL) {
                  RefreshRates();
                  if (Signal_2_StopLoss <= 0 && ld_104 - OrderOpenPrice() >= MinStop * gd_432) ld_80 = NormalizeDouble(ld_104, Digits);
                  if (Signal_2_StopLoss <= 0 && ld_104 - OrderOpenPrice() < MinStop * gd_432) ld_80 = NormalizeDouble(MathMin(OrderOpenPrice(), Ask) + MinStop * gd_432, Digits);
                  if (Signal_2_StopLoss > 0) ld_80 = NormalizeDouble(MathMin(OrderOpenPrice(), Ask) + Signal_2_StopLoss * gd_432, Digits);
                  if (Signal_2_TakeProfit <= 0) ld_88 = NormalizeDouble(OrderOpenPrice() - MathAbs(ld_112 - ld_104) * TargetFactor, Digits);
                  else ld_88 = NormalizeDouble(OrderOpenPrice() - Signal_2_TakeProfit * gd_432, Digits);
                  if (Signal_2 > 0 && OrderStopLoss() < Point) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), MathMax(ld_80, NormalizeDouble(Ask + gi_392 * Point, Digits)), MathMin(ld_88, NormalizeDouble(Bid - gi_392 * Point,
                        Digits)), 0, Red) == FALSE) Print("Error in OrderModify! Short Position at Ask:", Ask, " sl=", ld_80, " tp=", ld_88);
                  } else {
                     if (Signal_2 > 0 && OrderStopLoss() >= ld_80 + Point && ld_80 >= NormalizeDouble(Ask + gi_392 * Point, Digits))
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), ld_80, OrderTakeProfit(), 0, Red) == FALSE) Print("Error in OrderModify! Short Position at Bid:", Ask, " sl=", ld_80);
                  }
                  if (li_148 == TRUE || Ask >= ld_80 || Ask <= ld_88 || (Signal_2_Exit_Profit > 0 && OrderOpenPrice() - Ask >= Signal_2_Exit_Profit * gd_432 && iClose(NULL, PERIOD_M5,
                     1) > iOpen(NULL, PERIOD_M5, 1))) {
                     for (li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
                        RefreshRates();
                        if (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), Max_Slippage / gd_440, Violet)) {
                           li_76--;
                           li_68--;
                           break;
                        }
                        Sleep(MathMax(100, 1000 * gi_364));
                     }
                  }
               }
            }
         }
      }
   }
   bool li_152 = FALSE;
   bool li_156 = FALSE;
   double ld_160 = iMA(NULL, PERIOD_H1, Swing_MA_Period, 0, MODE_SMMA, PRICE_CLOSE, gi_272);
   if (Swing_Filtering && Bid > ld_160 + Swing_Impulse * gd_432) li_156 = TRUE;
   if (Swing_Filtering && Bid < ld_160 - Swing_Impulse * gd_432) li_152 = TRUE;
   if (!Swing_Filtering) li_156 = TRUE;
   li_152 = TRUE;
   if (IsTesting()) li_168 = f0_3();
   else li_168 = f0_1();
   if (li_152) {
      if (DayOfWeek() != NoTradeDay) {
         if ((Hour_Filtering && li_168 == TradeHour1 || li_168 == TradeHour2 || li_168 == TradeHour3 || li_168 == TradeHour4 || li_168 == TradeHour5 || li_168 == TradeHour6 ||
            li_168 == TradeHour7 || li_168 == TradeHour8 || li_168 == TradeHour9) || (!Hour_Filtering)) {
            if (li_120 == TRUE && li_56 == 0 && li_124 == FALSE) {
               if (NFA_Rules == FALSE || li_72 + li_76 == 0) {
                  if (f0_2(1, iTime(NULL, Indicator_TimeFrame, 1), gi_472, DayOfWeek())) {
                     for (li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
                        RefreshRates();
                        if (OrderSend(Symbol(), OP_BUY, ld_32, NormalizeDouble(Ask, Digits), Max_Slippage / gd_440, 0, 0, "", Magic_1, 0, Blue) >= 0) {
                           gi_472 = iTime(NULL, Indicator_TimeFrame, 1);
                           break;
                        }
                        Print("Error opening long order!: ", GetLastError());
                        Sleep(MathMax(100, 1000 * gi_364));
                     }
                  }
               }
            }
         }
      }
   }
   if (li_156) {
      if (DayOfWeek() != NoTradeDay) {
         if ((Hour_Filtering && li_168 == TradeHour1 || li_168 == TradeHour2 || li_168 == TradeHour3 || li_168 == TradeHour4 || li_168 == TradeHour5 || li_168 == TradeHour6 ||
            li_168 == TradeHour7 || li_168 == TradeHour8 || li_168 == TradeHour9) || (!Hour_Filtering)) {
            if (li_128 == TRUE && li_60 == 0 && li_132 == FALSE) {
               if (NFA_Rules == FALSE || li_72 + li_76 == 0) {
                  if (f0_2(1, iTime(NULL, Indicator_TimeFrame, 1), gi_476, DayOfWeek())) {
                     for (li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
                        RefreshRates();
                        if (OrderSend(Symbol(), OP_SELL, ld_32, NormalizeDouble(Bid, Digits), Max_Slippage / gd_440, 0, 0, "", Magic_1, 0, Red) >= 0) {
                           gi_476 = iTime(NULL, Indicator_TimeFrame, 1);
                           break;
                        }
                        Print("Error opening short order!: ", GetLastError());
                        Sleep(MathMax(100, 1000 * gi_364));
                     }
                  }
               }
            }
         }
      }
   }
   if (li_136 == TRUE && li_64 == 0 && li_140 == FALSE) {
      if (NFA_Rules == FALSE || li_72 + li_76 == 0) {
         if (f0_2(2, iTime(NULL, Indicator_TimeFrame, 1), gi_480, DayOfWeek())) {
            for (li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
               RefreshRates();
               if (OrderSend(Symbol(), OP_BUY, ld_40, NormalizeDouble(Ask, Digits), Max_Slippage / gd_440, 0, 0, "", Magic_2, 0, Blue) >= 0) {
                  gi_480 = iTime(NULL, Indicator_TimeFrame, 1);
                  break;
               }
               Print("Error opening long order!: ", GetLastError());
               Sleep(MathMax(100, 1000 * gi_364));
            }
         }
      }
   }
   if (li_144 == TRUE && li_68 == 0 && li_148 == FALSE) {
      if (NFA_Rules == FALSE || li_72 + li_76 == 0) {
         if (f0_2(2, iTime(NULL, Indicator_TimeFrame, 1), gi_484, DayOfWeek())) {
            for (li_100 = 1; li_100 <= MathMax(1, gi_360); li_100++) {
               RefreshRates();
               if (OrderSend(Symbol(), OP_SELL, ld_40, NormalizeDouble(Bid, Digits), Max_Slippage / gd_440, 0, 0, "", Magic_2, 0, Red) >= 0) {
                  gi_484 = iTime(NULL, Indicator_TimeFrame, 1);
                  break;
               }
               Print("Error opening short order!: ", GetLastError());
               Sleep(MathMax(100, 1000 * gi_364));
            }
         }
      }
   }
   return (0);
}

int f0_2(int ai_0, int ai_4, int ai_8, int ai_12) {
   bool li_16 = FALSE;
   if (ai_4 > ai_8)
      if (ai_0 != 1 || ai_12 != 0) li_16 = TRUE;
   return (li_16);
}

int f0_1() {
   int li_0 = Hour();
   li_0 -= gi_448;
   if (DST_Usage == TRUE && (Month() > 3 && Month() < 11)) li_0++;
   if (li_0 > 23) li_0 -= 24;
   if (li_0 < 0) li_0 += 24;
   return (li_0);
}

int f0_3() {
   int li_0 = Hour();
   li_0 -= gi_448;
   if (li_0 > 23) li_0 -= 24;
   if (li_0 < 0) li_0 += 24;
   return (li_0);
}

double f0_0(double ad_0, double ad_8) {
   double ld_32;
   int li_40;
   double ld_44;
   int li_52;
   double ld_56;
   int li_64;
   double ld_68;
   int li_76;
   double ld_24 = 1;
   if (gd_380 > 0.0 && ad_0 > 0.0) {
      ld_32 = 0;
      li_40 = 0;
      ld_44 = 0;
      li_52 = 0;
      ld_56 = 0;
      li_64 = 0;
      for (int li_80 = OrdersHistoryTotal() - 1; li_80 >= 0; li_80--) {
         if (OrderSelect(li_80, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_1 || OrderMagicNumber() == Magic_2) {
               li_40++;
               ld_32 += OrderProfit();
               if (ld_32 > ld_56) {
                  ld_56 = ld_32;
                  li_64 = li_40;
               }
               if (ld_32 < ld_44) {
                  ld_44 = ld_32;
                  li_52 = li_40;
               }
               if (li_40 >= gi_368) break;
            }
         }
      }
      if (li_64 <= li_52) ld_24 = MathPow(gd_380, li_52);
      else {
         ld_32 = ld_56;
         li_40 = li_64;
         ld_68 = ld_56;
         li_76 = li_64;
         for (li_80 = OrdersHistoryTotal() - li_64 - 1; li_80 >= 0; li_80--) {
            if (OrderSelect(li_80, SELECT_BY_POS, MODE_HISTORY)) {
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic_1 || OrderMagicNumber() == Magic_2) {
                  if (li_40 >= gi_368) break;
                  li_40++;
                  ld_32 += OrderProfit();
                  if (ld_32 < ld_68) {
                     ld_68 = ld_32;
                     li_76 = li_40;
                  }
               }
            }
         }
         if (li_76 == li_64 || ld_68 == ld_56) ld_24 = MathPow(gd_380, li_52);
         else {
            if (MathAbs(ld_44 - ld_56) / MathAbs(ld_68 - ld_56) >= (gd_372 + 100.0) / 100.0) ld_24 = MathPow(gd_380, li_52);
            else ld_24 = MathPow(gd_380, li_76);
         }
      }
   }
   for (double ld_16 = MathMax(gd_396, MathMin(gd_404, MathCeil(MathMin(ad_8, ld_24 * ad_0) / 100.0 * AccountFreeMargin() / gd_412 / (gi_420 / 100)) * gd_412)); ld_16 >= 2.0 * gd_396 &&
      1.05 * (ld_16 * gd_424) >= AccountFreeMargin(); ld_16 -= gd_396) {
   }
   return (ld_16);
}