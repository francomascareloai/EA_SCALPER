#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
//----

extern string strSystemTrade_1="****************************************";
extern bool isAuto_Trade=false;
extern string strSystemTrade_2="****************************************";
extern double Default_Money=10000.0;
extern double MaxTP_psnt=100000.0;
extern double MaxSL_psnt=0.0;
extern string strSystemTrade_3="****************************************";
extern bool isLots_Auto=true;
extern double CalcLots_of_Optimize=20000.0;
extern double Lots=0.1;
extern string strSystemTrade_31="----------------------------------------";
extern int MaxEnter_Step=3;
extern double Double_Lots=1.7;
extern int Pending_stop_gap=34;
extern string strSystemTrade_4="****************************************";
extern double AutoStop_tp=16.0;
extern double AutoStop_sl=0.0;
extern double TrailingStop_tp=12.0;
extern double TrailingStop_sl=0.0;
extern bool isTrailingStop=true;
extern double TrailingStop_step=2.0;
extern bool isSystem_StopProf=true;
extern bool isSystem_StopLoss=true;
extern string strSystemTrade_23="****************************************";
extern bool isAlam_Enter=false;
extern string StartTime="09:35";
extern string EndTime="17:54";

int Zddfi_184 = 140;
string Zddf_comment_192 = "";
double Zddfd_200 = 100000.0;
double Zddfd_208 = 0.1;
double Zddf_pips_216 = 10000.0;
int Zddf_ma_method_224 = MODE_LWMA;
int Zddfi_228 = 0;
int Zddfi_232 = 0;
int Zddfi_236 = 23;
int Zddfi_240 = 59;
int Zddfi_244 = 0;
double Zddf_pips_248 = 0.0;
int Zddf_digits_256 = 0;
double Zddf_point_260 = 0.0;
int Zddfi_268;
double Zddfd_272;
double Zddfd_280;
double Zddfd_288;
 int MagicNumber;
 int StopLoss;
 string ErrorDescription;
double Zddfd_296;
double Zddfd_304;
double Zddfd_312;
double Zddfd_320;
int Zddf_slippage_328 = 3;
bool Zddfi_332;
double Zddfd_336;
double Zddfda_344[30];
int Zddfi_348 = 0;
string Zddfs_dummy_352;
string Zddfs_unused_360 = "";
string Zddfs_unused_368 = "";
string Zddfs_unused_404 = "000,000,000";
string Zddfs_unused_412 = "000,000,255";
int Zddfi_432 = 40;
double Zddf_timeframe_436 = 240.0;
bool Zddfi_444 = TRUE;
int Zddfi_unused_448 = 6908265;
 int TrailingStop = 2;
 string TrailingStart = "-2";
 int Buffer = 2;
 int MaxSpread = 2;
 bool MoneyManagement = TRUE;
 double Risk = 5.0;
 int Activation_Code = 0;
 int OP_TRD = 1;
 double ThaBull = 22.0;
 double TrailingStep = 0.3;
 double Lock = 0.3;
 double MinLots = 0.01;
 double MAX_LOT = 0.01;
 bool UseMM = TRUE;
 double Spread = 0.8;
string Zddf_name_452 = "SpreadIndikatorObj";
double Zddfd_unused_460;
int Zddfi_unused_468 = 255;
int Zddfi_unused_472 = 11119017;
int Zddfi_unused_476 = 8388352;
bool Zddfi_unused_480 = TRUE;
double Zddf_ihigh_484;
double Zddf_ilow_492;
double Zddfd_500;
int Zddf_datetime_508;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() { 
Risk = Risk*4;

StopLoss = StopLoss*20;

   int timeframe_0;
   TrailingStop = MathRound(TrailingStop);
   ThaBull = MathRound(ThaBull);
   ArrayInitialize(Zddfda_344, 0);
   Zddf_digits_256 = Digits;
   Zddf_point_260 = Point;
   Print("Digits: " + Zddf_digits_256 + " Point: " + DoubleToStr(Zddf_point_260, Zddf_digits_256));
   double lotstep_4 = MarketInfo(Symbol(), MODE_LOTSTEP);
   Zddfi_268 = MathLog(lotstep_4) / MathLog(0.1);
   Zddfd_272 = MathMax(MinLots, MarketInfo(Symbol(), MODE_MINLOT));
   Zddfd_280 = MathMin(Zddfd_200, MarketInfo(Symbol(), MODE_MAXLOT));
   Zddfd_288 = Risk / 100.0;
   Zddfd_296 = NormalizeDouble(Zddf_pips_216 * Zddf_point_260, Zddf_digits_256 + 1);
   Zddfd_304 = NormalizeDouble(Risk * Zddf_point_260, Zddf_digits_256);
   Zddfd_312 = NormalizeDouble(ThaBull * Zddf_point_260, Zddf_digits_256);
   Zddfd_320 = NormalizeDouble(Zddf_point_260 * Zddfi_184, Zddf_digits_256);
   Zddfi_332 = FALSE;
   Zddfd_336 = NormalizeDouble(Zddf_pips_248 * Zddf_point_260, Zddf_digits_256 + 1);
   if (!IsTesting()) {
      if (Zddfi_444) {
         timeframe_0 = Period();
         switch (timeframe_0) {
         case PERIOD_M1:
            Zddf_timeframe_436 = 5;
            break;
         case PERIOD_M5:
            Zddf_timeframe_436 = 15;
            break;
         case PERIOD_M15:
            Zddf_timeframe_436 = 30;
            break;
         case PERIOD_M30:
            Zddf_timeframe_436 = 60;
            break;
         case PERIOD_H1:
            Zddf_timeframe_436 = 240;
            break;
         case PERIOD_H4:
            Zddf_timeframe_436 = 1440;
            break;
         case PERIOD_D1:
            Zddf_timeframe_436 = 10080;
            break;
         case PERIOD_W1:
            Zddf_timeframe_436 = 43200;
            break;
         case PERIOD_MN1:
            Zddf_timeframe_436 = 43200;
         }
      }
      Zddfd_unused_460 = 0.0001;
      f0_1();
      f0_2();
   }
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   if (!IsTesting()) {
      for (int Ewfi_0 = 1; Ewfi_0 <= Zddfi_432; Ewfi_0++) ObjectDelete("Padding_rect" + Ewfi_0);
      for (int count_4 = 0; count_4 < 10; count_4++) {
         ObjectDelete("BD" + count_4);
         ObjectDelete("SD" + count_4);
      }
      ObjectDelete("time");
      ObjectDelete(Zddf_name_452);
   }
   Comment("");
   ObjectDelete("B3LLogo");
   ObjectDelete("B3LCopy");
   ObjectDelete("FiboUp");
   ObjectDelete("FiboDn");
   ObjectDelete("FiboIn");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int error_0;
   string Ewfs_4;
   int ticket_12;
   double price_16;
   bool bool_24;
   double Ewfd_28;
   double Ewfd_36;
   double price_44;
   double Ewfd_52;
   int Ewfi_60;
   int cmd_64;
   double Ewfd_68;
   double Ewfd_76;
   double ihigh_84 = iHigh(NULL, 0, 0);
   double ilow_92 = iLow(NULL, 0, 0);
   double ivalue_100 = iCustom(Symbol(),Period(),"Indicator1",0,0);
   double ivalue_108 = iCustom(Symbol(),Period(),"Indicator2",0,0);
   double Ewfd_116 = ivalue_100 - ivalue_108;
   if (!Zddfi_332) {
      for (int pos_124 = OrdersHistoryTotal() - 1; pos_124 >= 0; pos_124--) {
         if (OrderSelect(pos_124, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderProfit() != 0.0) {
               if (OrderClosePrice() != OrderOpenPrice()) {
                  if (OrderSymbol() == Symbol()) {
                     Zddfi_332 = TRUE;
                     Ewfd_52 = MathAbs(OrderProfit() / (OrderClosePrice() - OrderOpenPrice()));
                     Zddfd_336 = (-OrderCommission()) / Ewfd_52;
                     break;
                  }
               }
            }
         }
      }
   }
   int ima_100;
   int ima_108;
   double Ewfd_128 = Ask - Bid;
   ArrayCopy(Zddfda_344, Zddfda_344, 0, 1, 29);
   Zddfda_344[29] = Ewfd_128;
   if (Zddfi_348 < 30) Zddfi_348++;
   double Ewfd_136 = 0;
   pos_124 = 29;
   for (int count_144 = 0; count_144 < Zddfi_348; count_144++) {
      Ewfd_136 += Zddfda_344[pos_124];
      pos_124--;
   }
   double Ewfd_148 = Ewfd_136 / Zddfi_348;
   double Ewfd_156 = NormalizeDouble(Ask + Zddfd_336, Zddf_digits_256);
   double Ewfd_164 = NormalizeDouble(Bid - Zddfd_336, Zddf_digits_256);
   double Ewfd_172 = NormalizeDouble(Ewfd_148 + Zddfd_336, Zddf_digits_256 + 1);
   double Ewfd_180 = ihigh_84 - ilow_92;
   if (Ewfd_180 > Zddfd_320) {
      if (Bid < ima_100) Ewfi_60 = -1;
      else
         if (Bid > ima_108) Ewfi_60 = 1;
   }
   int count_188 = 0;
   for (pos_124 = 0; pos_124 < OrdersTotal(); pos_124++) {
      if (OrderSelect(pos_124, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber) {
            cmd_64 = OrderType();
            if (cmd_64 == OP_BUYLIMIT || cmd_64 == OP_SELLLIMIT) continue;
            if (OrderSymbol() == Symbol()) {
               count_188++;
               switch (cmd_64) {
               case OP_BUY:
                  if (ThaBull < 0.0) break;
                  Ewfd_36 = NormalizeDouble(OrderStopLoss(), Zddf_digits_256);
                  price_44 = NormalizeDouble(Bid - Zddfd_312, Zddf_digits_256);
                  if (!((Ewfd_36 == 0.0 || price_44 > Ewfd_36))) break;
                  bool_24 = OrderModify(OrderTicket(), OrderOpenPrice(), price_44, OrderTakeProfit(), 0, Lime);
                  if (!((!bool_24))) break;
                  error_0 = GetLastError();
                  Print("BUY Modify Error Code: " + error_0 + " Message: " + Ewfs_4 + " OP: " + DoubleToStr(price_16, Zddf_digits_256) + " SL: " + DoubleToStr(price_44, Zddf_digits_256) +
                     " Bid: " + DoubleToStr(Bid, Zddf_digits_256) + " Ask: " + DoubleToStr(Ask, Zddf_digits_256));
                  break;
               case OP_SELL:
                  if (ThaBull < 0.0) break;
                  Ewfd_36 = NormalizeDouble(OrderStopLoss(), Zddf_digits_256);
                  price_44 = NormalizeDouble(Ask + Zddfd_312, Zddf_digits_256);
                  if (!((Ewfd_36 == 0.0 || price_44 < Ewfd_36))) break;
                  bool_24 = OrderModify(OrderTicket(), OrderOpenPrice(), price_44, OrderTakeProfit(), 0, Orange);
                  if (!((!bool_24))) break;
                  error_0 = GetLastError();
                  Print("SELL Modify Error Code: " + error_0 + " Message: " + Ewfs_4 + " OP: " + DoubleToStr(price_16, Zddf_digits_256) + " SL: " + DoubleToStr(price_44, Zddf_digits_256) +
                     " Bid: " + DoubleToStr(Bid, Zddf_digits_256) + " Ask: " + DoubleToStr(Ask, Zddf_digits_256));
                  break;
               case OP_BUYSTOP:
                  Ewfd_28 = NormalizeDouble(OrderOpenPrice(), Zddf_digits_256);
                  price_16 = NormalizeDouble(Ask + Zddfd_304, Zddf_digits_256);
                  if (!((price_16 < Ewfd_28))) break;
                  price_44 = NormalizeDouble(price_16 - StopLoss * Point, Zddf_digits_256);
                  bool_24 = OrderModify(OrderTicket(), price_16, price_44, OrderTakeProfit(), 0, Lime);
                  if (!((!bool_24))) break;
                  error_0 = GetLastError();
                  Print("BUYSTOP Modify Error Code: " + error_0 + " Message: " + Ewfs_4 + " OP: " + DoubleToStr(price_16, Zddf_digits_256) + " SL: " + DoubleToStr(price_44, Zddf_digits_256) +
                     " Bid: " + DoubleToStr(Bid, Zddf_digits_256) + " Ask: " + DoubleToStr(Ask, Zddf_digits_256));
                  break;
               case OP_SELLSTOP:
                  Ewfd_28 = NormalizeDouble(OrderOpenPrice(), Zddf_digits_256);
                  price_16 = NormalizeDouble(Bid - Zddfd_304, Zddf_digits_256);
                  if (!((price_16 > Ewfd_28))) break;
                  price_44 = NormalizeDouble(price_16 + StopLoss * Point, Zddf_digits_256);
                  bool_24 = OrderModify(OrderTicket(), price_16, price_44, OrderTakeProfit(), 0, Orange);
                  if (!((!bool_24))) break;
                  error_0 = GetLastError();
                  Print("SELLSTOP Modify Error Code: " + error_0 + " Message: " + Ewfs_4 + " OP: " + DoubleToStr(price_16, Zddf_digits_256) + " SL: " + DoubleToStr(price_44, Zddf_digits_256) +
                     " Bid: " + DoubleToStr(Bid, Zddf_digits_256) + " Ask: " + DoubleToStr(Ask, Zddf_digits_256));
               }
            }
         }
      }
   }
   if (count_188 == 0 && Ewfi_60 != 0 && Ewfd_172 <= Zddfd_296 && f0_0()) {
      Ewfd_68 = AccountBalance() * AccountLeverage() * Zddfd_288;
      if (!UseMM) Ewfd_68 = Zddfd_208;
      Ewfd_76 = NormalizeDouble(Ewfd_68 / MarketInfo(Symbol(), MODE_LOTSIZE), Zddfi_268);
      Ewfd_76 = MathMax(Zddfd_272, Ewfd_76);
      Ewfd_76 = MathMin(Zddfd_280, Ewfd_76);
      if (Ewfi_60 < 0) {
         price_16 = NormalizeDouble(Ask + Zddfd_304, Zddf_digits_256);
         price_44 = NormalizeDouble(price_16 - StopLoss * Point, Zddf_digits_256);
         ticket_12 = OrderSend(Symbol(), OP_BUYSTOP, Ewfd_76, price_16, Zddf_slippage_328, price_44, 0, Zddf_comment_192, MagicNumber, 0, Lime);
         if (ticket_12 <= 0) {
            error_0 = GetLastError();
            Print("BUYSTOP Send Error Code: " + error_0 + " Message: " + Ewfs_4 + " LT: " + DoubleToStr(Ewfd_76, Zddfi_268) + " OP: " + DoubleToStr(price_16, Zddf_digits_256) +
               " SL: " + DoubleToStr(price_44, Zddf_digits_256) + " Bid: " + DoubleToStr(Bid, Zddf_digits_256) + " Ask: " + DoubleToStr(Ask, Zddf_digits_256));
         }
      } else {
         price_16 = NormalizeDouble(Bid - Zddfd_304, Zddf_digits_256);
         price_44 = NormalizeDouble(price_16 + StopLoss * Point, Zddf_digits_256);
         ticket_12 = OrderSend(Symbol(), OP_SELLSTOP, Ewfd_76, price_16, Zddf_slippage_328, price_44, 0, Zddf_comment_192, MagicNumber, 0, Orange);
         if (ticket_12 <= 0) {
            error_0 = GetLastError();
          
            Print("BUYSELL Send Error Code: " + error_0 + " Message: " + Ewfs_4 + " LT: " + DoubleToStr(Ewfd_76, Zddfi_268) + " OP: " + DoubleToStr(price_16, Zddf_digits_256) +
               " SL: " + DoubleToStr(price_44, Zddf_digits_256) + " Bid: " + DoubleToStr(Bid, Zddf_digits_256) + " Ask: " + DoubleToStr(Ask, Zddf_digits_256));
         }
      }
   }
   string Ewfs_196 = "AvgSpread:" + DoubleToStr(Ewfd_148, Zddf_digits_256) + "  Commission rate:" + DoubleToStr(Zddfd_336, Zddf_digits_256 + 1) + "  Real avg. spread:" + DoubleToStr(Ewfd_172,
      Zddf_digits_256 + 1);
   if (Ewfd_172 > Zddfd_296) {
      Ewfs_196 = Ewfs_196 
         + "\n" 
      + "The EA can not run with this spread ( " + DoubleToStr(Ewfd_172, Zddf_digits_256 + 1) + " > " + DoubleToStr(Zddfd_296, Zddf_digits_256 + 1) + " )";
   }
   if (count_188 != 0 || Ewfi_60 != 0) {
   }
   if (!IsTesting()) {
      f0_1();
      f0_2();
   }
   return (0);
}

// 09CBB5F5CE12C31A043D5C81BF20AA4A
int f0_0() {
   if ((Hour() > Zddfi_228 && Hour() < Zddfi_236) || (Hour() == Zddfi_228 && Minute() >= Zddfi_232) || (Hour() == Zddfi_236 && Minute() < Zddfi_240)) return (1);
   return (0);
}

// 2569208C5E61CB15E209FFE323DB48B7
void f0_1() {
   double Ewfda_0[10];
   double Ewfda_4[10];
   double Ewfda_8[10];
   double Ewfda_12[10];
   int Ewfi_unused_16;
   int Ewfi_20;
   int Ewfi_24;
   int Ewfi_28;
   if (Period() < Zddf_timeframe_436) {
      ArrayCopySeries(Ewfda_0, 2, Symbol(), Zddf_timeframe_436);
      ArrayCopySeries(Ewfda_4, 1, Symbol(), Zddf_timeframe_436);
      ArrayCopySeries(Ewfda_8, 0, Symbol(), Zddf_timeframe_436);
      ArrayCopySeries(Ewfda_12, 3, Symbol(), Zddf_timeframe_436);
      Ewfi_28 = 3;
      for (int Ewfi_32 = 2; Ewfi_32 >= 0; Ewfi_32--) {
         Ewfi_20 = Time[0] + Period() * (90 * Ewfi_28);
         Ewfi_24 = Time[0] + 90 * (Period() * (Ewfi_28 + 1));
         if (ObjectFind("BD" + Ewfi_32) == -1) {
            if (Ewfda_8[Ewfi_32] > Ewfda_12[Ewfi_32]) Ewfi_unused_16 = 170;
            else Ewfi_unused_16 = 43520;
         } else {
            if (Ewfda_8[Ewfi_32] > Ewfda_12[Ewfi_32]) Ewfi_unused_16 = 170;
            else Ewfi_unused_16 = 43520;
         }
         Ewfi_28++;
         Ewfi_28++;
      }
   }
}

// 945D754CB0DC06D04243FCBA25FC0802
void f0_2() {
   int Ewfi_0 = iBarShift(NULL, PERIOD_D1, Time[0]) + 1;
   Zddf_ihigh_484 = iHigh(NULL, PERIOD_D1, Ewfi_0);
   Zddf_ilow_492 = iLow(NULL, PERIOD_D1, Ewfi_0);
   Zddf_datetime_508 = iTime(NULL, PERIOD_D1, Ewfi_0);
   if (TimeDayOfWeek(Zddf_datetime_508) == 0) {
      Zddf_ihigh_484 = MathMax(Zddf_ihigh_484, iHigh(NULL, PERIOD_D1, Ewfi_0 + 1));
      Zddf_ilow_492 = MathMin(Zddf_ilow_492, iLow(NULL, PERIOD_D1, Ewfi_0 + 1));
   }
   Zddfd_500 = Zddf_ihigh_484 - Zddf_ilow_492;
}
