#property copyright "Copyright © 2011, http://cmillion.narod.ru"
#property link      "cmillion@narod.ru"

extern bool Buy = TRUE;
extern bool Sell = TRUE;
extern int OrdersLimit = 5;
extern int OrdersStop = 10;
extern int OrdersTek = 4;
extern double lotLimit = 0.1;
extern double lotStop = 0.4;
extern double PlusLot = 0.1;
extern double K_Lot = 1.0;
extern int MoveStepGread = 10;
extern int FirstStep = 0;
extern int Step = 0;
extern int SLoss = 0;
extern int TProfit = 0;
extern double NoLoss = 0.0;
extern double TrailingPercentStep = 0.0;
extern double ProfitStartTrall = 0.0;
extern double ProfitStartK = 0.3;
extern double TrailingPercentProfit = 30.0;
extern string ___________________ = "";
extern int SleepTime = 0;
extern int magic = 1000;
extern double Diapazon = 1.0;
extern string __________________ = "";
extern bool AlertOn = TRUE;
extern bool DrawInfo = TRUE;
extern bool SendMailInfo = FALSE;
extern string _________________ = "";
extern int TimeStart = 0;
extern int TimeEnd = 24;
extern string ________________ = "";
extern bool CloseEndWeek = TRUE;
extern int HourClose = 18;
extern int Key = 0;
extern int Lok = 4;
extern bool LokNoLoss = TRUE;
string gs_276 = "Setka Limit Loc v4.2 ";
string g_str_concat_284;
bool g_bool_292;
bool gi_296 = TRUE;
bool gi_300;
bool gi_304;
bool gi_308;
bool gi_312;
int gi_316 = 3256;
int g_stoplevel_320;
int g_acc_number_324;
int gi_328;
int gi_332;
double gd_336;
double gda_344[100];
double gda_348[100];
double gda_352[100];
double gda_356[100];
double gda_360[100];
double gda_364[100];
double gd_368;
double gd_376;
string g_str_concat_384;
string g_str_concat_392;
string g_str_concat_400;
string g_str_concat_408;
string g_var_name_416;
double g_maxlot_424;
double gd_432;
double gd_440;

int init() {
   g_str_concat_392 = StringConcatenate(Symbol(), " Up ", magic);
   g_str_concat_400 = StringConcatenate(Symbol(), " Dn ", magic);
   g_str_concat_408 = StringConcatenate(Symbol(), " De ", magic);
   if (IsTesting()) {
      GlobalVariableDel(g_str_concat_392);
      GlobalVariableDel(g_str_concat_400);
      GlobalVariableDel(g_str_concat_408);
   }
   g_var_name_416 = Symbol() + " Trall";
   if (GlobalVariableCheck(g_var_name_416)) {
      gi_300 = TRUE;
      gd_368 = GlobalVariableGet(g_var_name_416);
   }
   g_str_concat_384 = StringConcatenate(" ", AccountCurrency());
   if (TrailingPercentProfit != 0.0) gd_376 = ProfitStartTrall / 100.0 * TrailingPercentProfit;
   gd_368 = ProfitStartTrall;
   if (OrdersLimit > 99) OrdersLimit = 99;
   if (OrdersStop > 99) OrdersStop = 99;
   g_maxlot_424 = MarketInfo(Symbol(), MODE_MAXLOT);
   double ld_0 = MarketInfo(Symbol(), MODE_MINLOT);
   if (lotLimit < ld_0) {
      lotLimit = ld_0;
      Alert("Минимальный лот lotLimit изменен на ", ld_0);
   }
   if (lotStop < ld_0) {
      lotStop = ld_0;
      Alert("Минимальный лот lotStop изменен на ", ld_0);
   }
   double ld_8 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (PlusLot < ld_8 && PlusLot != 0.0) {
      PlusLot = ld_8;
      Alert("Добавка лота изменена на ", ld_8);
   }
   for (int li_16 = 1; li_16 < 100; li_16++) {
      gda_344[li_16] = lotLimit + PlusLot * (li_16 - 1);
      if (K_Lot != 1.0) gda_344[li_16] = PlusLot * MathPow(K_Lot, li_16 - 1);
   }
   for (li_16 = Lok; li_16 < 100; li_16++) {
      gda_348[li_16] = lotStop + PlusLot * (li_16 - 1);
      if (K_Lot != 1.0) gda_348[li_16] = lotStop * MathPow(K_Lot, li_16 - 1);
   }
   ObjectCreate("Balance", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Balance", OBJPROP_CORNER, 1);
   ObjectSet("Balance", OBJPROP_XDISTANCE, 5);
   ObjectSet("Balance", OBJPROP_YDISTANCE, 15);
   ObjectCreate("Equity", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Equity", OBJPROP_CORNER, 1);
   ObjectSet("Equity", OBJPROP_XDISTANCE, 5);
   ObjectSet("Equity", OBJPROP_YDISTANCE, 30);
   ObjectCreate("FreeMargin", OBJ_LABEL, 0, 0, 0);
   ObjectSet("FreeMargin", OBJPROP_CORNER, 1);
   ObjectSet("FreeMargin", OBJPROP_XDISTANCE, 5);
   ObjectSet("FreeMargin", OBJPROP_YDISTANCE, 45);
   if (!f0_0()) {
      Comment("ошибка котировок, пробую перезапустить");
      Sleep(5000);
      if (!f0_0()) Alert("ошибка котировок, перезапустите советник вручную");
   }
   g_bool_292 = (!IsDemo()) && !IsTesting();
   ObjectCreate("Profit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Profit", OBJPROP_CORNER, 1);
   ObjectSet("Profit", OBJPROP_XDISTANCE, 5);
   ObjectSet("Profit", OBJPROP_YDISTANCE, 90);
   ObjectCreate("ProfitB", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ProfitB", OBJPROP_CORNER, 1);
   ObjectSet("ProfitB", OBJPROP_XDISTANCE, 5);
   ObjectSet("ProfitB", OBJPROP_YDISTANCE, 60);
   ObjectCreate("ProfitS", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ProfitS", OBJPROP_CORNER, 1);
   ObjectSet("ProfitS", OBJPROP_XDISTANCE, 5);
   ObjectSet("ProfitS", OBJPROP_YDISTANCE, 75);
   ObjectCreate("ProfitStartTrall", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ProfitStartTrall", OBJPROP_CORNER, 1);
   ObjectSet("ProfitStartTrall", OBJPROP_XDISTANCE, 5);
   ObjectSet("ProfitStartTrall", OBJPROP_YDISTANCE, 105);
   ObjectCreate("Copyright", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Copyright", OBJPROP_CORNER, 3);
   ObjectSet("Copyright", OBJPROP_XDISTANCE, 5);
   ObjectSet("Copyright", OBJPROP_YDISTANCE, 5);
   ObjectSetText("Copyright", "Copyright © 2011, http://cmillion.narod.ru\n", 8, "Arial", Gold);
   ObjectCreate("comment2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("comment2", OBJPROP_CORNER, 1);
   ObjectSet("comment2", OBJPROP_XDISTANCE, 5);
   ObjectSet("comment2", OBJPROP_YDISTANCE, 130);
   ObjectSetText("comment2", "Торговля ", 8, "Arial", Gray);
   return (0);
}

bool f0_0() {
   double ihigh_0;
   double ilow_8;
   double ld_20;
   double ld_28;
   double ld_36;
   int magic_44;
   int cmd_48;
   if (GlobalVariableCheck(g_str_concat_392) && GlobalVariableCheck(g_str_concat_400) && GlobalVariableCheck(g_str_concat_408)) {
      gd_432 = GlobalVariableGet(g_str_concat_392);
      gd_440 = GlobalVariableGet(g_str_concat_400);
      gd_336 = GlobalVariableGet(g_str_concat_408);
   } else {
      if (Step == 0) {
         for (int li_16 = 0; li_16 < 30; li_16++) {
            ihigh_0 = iHigh(NULL, PERIOD_D1, li_16);
            ilow_8 = iLow(NULL, PERIOD_D1, li_16);
            if (ihigh_0 == 0.0 || ilow_8 == 0.0) continue;
            if (gd_336 < (ihigh_0 - ilow_8) / OrdersLimit) gd_336 = (ihigh_0 - ilow_8) / OrdersLimit * Diapazon;
         }
      } else gd_336 = Step * Point;
      if (gd_336 == 0.0) return (FALSE);
      for (li_16 = OrdersTotal() - 1; li_16 >= 0; li_16--) {
         if (OrderSelect(li_16, SELECT_BY_POS, MODE_TRADES)) {
            magic_44 = OrderMagicNumber();
            cmd_48 = OrderType();
            if (OrderSymbol() == Symbol() && magic_44 >= magic && magic_44 <= magic + 100) {
               ld_36 = NormalizeDouble(OrderOpenPrice(), Digits);
               if (cmd_48 == OP_BUYLIMIT)
                  if (ld_20 < ld_36) ld_20 = ld_36;
               if (cmd_48 == OP_SELLLIMIT)
                  if (ld_28 > ld_36 || ld_28 == 0.0) ld_28 = ld_36;
            }
         }
      }
      if (ld_20 == 0.0 && ld_28 == 0.0) {
         if (FirstStep < MarketInfo(Symbol(), MODE_STOPLEVEL)) {
            gd_432 = Ask + gd_336;
            gd_440 = Bid - gd_336;
         } else {
            gd_432 = Ask + FirstStep * Point;
            gd_440 = Bid - FirstStep * Point;
         }
      } else {
         gd_432 = ld_28;
         gd_440 = ld_20;
      }
      GlobalVariableSet(g_str_concat_392, gd_432);
      GlobalVariableSet(g_str_concat_400, gd_440);
      GlobalVariableSet(g_str_concat_408, gd_336);
   }
   gi_328 = gd_336 / Point;
   gi_332 = NormalizeDouble(gi_328 * TrailingPercentStep / 100.0, 0);
   if (Sell) gda_352[1] = NormalizeDouble(gd_432, Digits);
   if (Buy) gda_356[1] = NormalizeDouble(gd_440, Digits);
   for (li_16 = 2; li_16 <= OrdersLimit; li_16++) {
      if (Sell) gda_352[li_16] = NormalizeDouble(gda_352[li_16 - 1] + gd_336, Digits);
      if (Buy) gda_356[li_16] = NormalizeDouble(gda_356[li_16 - 1] - gd_336, Digits);
   }
   if (Buy) gda_360[Lok] = NormalizeDouble(gd_440, Digits);
   if (Sell) gda_364[Lok] = NormalizeDouble(gd_432, Digits);
   for (li_16 = Lok + 1; li_16 <= Lok + OrdersStop; li_16++) {
      if (Buy) gda_360[li_16] = NormalizeDouble(gda_360[li_16 - 1] - gd_336, Digits);
      if (Sell) gda_364[li_16] = NormalizeDouble(gda_364[li_16 - 1] + gd_336, Digits);
   }
   g_acc_number_324 = AccountNumber();
   g_str_concat_284 = StringConcatenate("Установленные параметры ", gs_276);
   if (IsDemo()) g_str_concat_284 = StringConcatenate(g_str_concat_284, " демо ");
   else g_str_concat_284 = StringConcatenate(g_str_concat_284, " реал ");
   g_str_concat_284 = StringConcatenate(g_str_concat_284, " счет ", g_acc_number_324, 
   "\n");
   if (SLoss != 0) g_str_concat_284 = StringConcatenate(g_str_concat_284, "Стоплосс ", SLoss, " \\ ");
   if (TProfit != 0) g_str_concat_284 = StringConcatenate(g_str_concat_284, "Тейкпрофит ", TProfit, " \\ ");
   if (TrailingPercentStep != 0.0) g_str_concat_284 = StringConcatenate(g_str_concat_284, "TrailingStop ", TrailingPercentStep, "% ", gi_332, " п \\ ");
   if (NoLoss > 0.0) g_str_concat_284 = StringConcatenate(g_str_concat_284, "безубыток ", NoLoss, " п \\ ");
   g_str_concat_284 = StringConcatenate(g_str_concat_284, "лот ", DoubleToStr(gda_344[1], 2));
   if (PlusLot != 0.0) g_str_concat_284 = StringConcatenate(g_str_concat_284, " \\ PlusLot ", DoubleToStr(PlusLot, 2));
   if (K_Lot != 1.0) g_str_concat_284 = StringConcatenate(g_str_concat_284, " \\ K_Lot ", DoubleToStr(K_Lot, 2));
   if (FirstStep != 0) g_str_concat_284 = StringConcatenate(g_str_concat_284, " \\ FirstStep ", FirstStep);
   g_str_concat_284 = StringConcatenate(g_str_concat_284, " \\ Сетка  ", gi_328, " п х ", OrdersLimit, " + Lok Stop ", OrdersStop, "\\ ");
   if (Step == 0) g_str_concat_284 = StringConcatenate(g_str_concat_284, " Diapazon ", Diapazon, " \\ ");
   if (TrailingPercentProfit == 0.0) g_str_concat_284 = StringConcatenate(g_str_concat_284, "Профит для закрытия " + DoubleToStr(ProfitStartTrall, 2), g_str_concat_384, " \\ ");
   else {
      if (ProfitStartTrall > 0.0) {
         g_str_concat_284 = StringConcatenate(g_str_concat_284, "Трайлинг старт = " + DoubleToStr(ProfitStartTrall, 2), g_str_concat_384, "  ", TrailingPercentProfit, "% откат = " +
            DoubleToStr(gd_376, 2), g_str_concat_384, " \\ ");
      } else {
         g_str_concat_284 = StringConcatenate(g_str_concat_284, "Трайлинг старт расчетный ", TrailingPercentProfit, "% откат \\ ");
         if (ProfitStartK != 1.0) g_str_concat_284 = StringConcatenate(g_str_concat_284, " К расчета прибыли ", DoubleToStr(ProfitStartK, 2), " \\ ");
      }
   }
   g_str_concat_284 = StringConcatenate(g_str_concat_284, 
   "\nТаймаут после профита ", SleepTime, " сек. \\ ");
   g_str_concat_284 = StringConcatenate(g_str_concat_284, "Время выставления ордеров с ", TimeStart, ":00 до ", TimeEnd, ":00");
   if (CloseEndWeek) g_str_concat_284 = StringConcatenate(g_str_concat_284, " \\ Окончание торгов в пятницу в ", HourClose, ":00");
   g_str_concat_284 = StringConcatenate(g_str_concat_284, " \\ Lok после ", Lok, " ордера \n");
   return (TRUE);
}

int deinit() {
   if (IsTesting()) {
      GlobalVariableDel(g_str_concat_392);
      GlobalVariableDel(g_str_concat_400);
      GlobalVariableDel(g_str_concat_408);
   }
   ObjectDelete("Balance");
   ObjectDelete("Equity");
   ObjectDelete("Profit");
   ObjectDelete("ProfitB");
   ObjectDelete("ProfitS");
   ObjectDelete("FreeMargin");
   ObjectDelete("Copyright");
   ObjectDelete("ProfitStartTrall");
   ObjectDelete("comment2");
   return (0);
}

int start() {
   bool li_4;
   double ld_16;
   double ld_24;
   double ld_32;
   double ld_40;
   double price_48;
   double price_56;
   double ld_64;
   double ld_72;
   double order_lots_80;
   double price_88;
   double price_96;
   double price_104;
   double price_112;
   double price_120;
   double price_128;
   int li_136;
   int li_140;
   int cmd_144;
   int magic_148;
   int li_152;
   int li_156;
   int li_160;
   int li_164;
   double ld_172;
   double ld_180;
   double ld_188;
   string str_concat_208;
   int ticket_216;
   double price_228;
   if (!IsTradeAllowed()) {
      ObjectSetText("comment2", "Торговля запрещена", 8, "Arial", Red);
      return (0);
   }
   ObjectSetText("comment2", "Торговля разрешена", 8, "Arial", Green);
   int hour_0 = Hour();
   if (TimeStart < TimeEnd && hour_0 >= TimeStart && hour_0 < TimeEnd) li_4 = TRUE;
   else {
      if (TimeStart > TimeEnd && hour_0 >= TimeStart || hour_0 < TimeEnd) li_4 = TRUE;
      else li_4 = FALSE;
   }
   g_stoplevel_320 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   for (int pos_168 = OrdersTotal() - 1; pos_168 >= 0; pos_168--) {
      if (OrderSelect(pos_168, SELECT_BY_POS, MODE_TRADES)) {
         magic_148 = OrderMagicNumber();
         if (OrderSymbol() == Symbol() && magic_148 >= magic && magic_148 <= magic + 100) {
            price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
            cmd_144 = OrderType();
            order_lots_80 = OrderLots();
            if (cmd_144 == OP_BUY) {
               if (price_104 < price_96 || price_104 == 0.0) price_104 = price_96;
               if (price_120 > price_96 || price_120 == 0.0) price_120 = price_96;
               ld_64 += price_96 * order_lots_80;
               li_136++;
               ld_32 += order_lots_80;
               ld_24 += OrderProfit() + OrderSwap() + OrderCommission();
            }
            if (cmd_144 == OP_SELL) {
               if (price_112 > price_96 || price_112 == 0.0) price_112 = price_96;
               if (price_128 < price_96 || price_128 == 0.0) price_128 = price_96;
               ld_72 += price_96 * order_lots_80;
               li_140++;
               ld_40 += order_lots_80;
               ld_16 += OrderProfit() + OrderSwap() + OrderCommission();
            }
            if (cmd_144 == OP_BUYLIMIT) li_152++;
            if (cmd_144 == OP_SELLLIMIT) li_156++;
            if (cmd_144 == OP_BUYSTOP) li_164++;
            if (cmd_144 == OP_SELLSTOP) li_160++;
         }
      }
   }
   if (MoveStepGread != 0 && li_136 + li_140 == 0) {
      if (FirstStep < MarketInfo(Symbol(), MODE_STOPLEVEL)) {
         ld_172 = Ask + gd_336;
         ld_180 = Bid - gd_336;
      } else {
         ld_172 = Ask + FirstStep * Point;
         ld_180 = Bid - FirstStep * Point;
      }
      if (MoveStepGread < (ld_180 - gda_356[1]) / Point && Buy && (!Sell)) {
         GlobalVariableSet(g_str_concat_400, gda_356[1] + MoveStepGread * Point);
         f0_0();
      }
      if (MoveStepGread < (gda_352[1] - ld_172) / Point && (!Buy) && Sell) {
         GlobalVariableSet(g_str_concat_392, gda_352[1] - MoveStepGread * Point);
         f0_0();
      }
   }
   double ld_8 = ld_16 + ld_24;
   if (li_152 == 0 && li_156 == 0 && li_160 == 0 && li_164 == 0) {
      GlobalVariableDel(g_str_concat_392);
      GlobalVariableDel(g_str_concat_400);
      GlobalVariableDel(g_str_concat_408);
      f0_0();
   }
   ObjectDelete("SLb");
   ObjectDelete("SLs");
   if (li_136 > 0) {
      price_48 = NormalizeDouble(ld_64 / ld_32, Digits);
      ObjectCreate("SLb", OBJ_ARROW, 0, Time[0], price_48, 0, 0, 0, 0);
      ObjectSet("SLb", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
      ObjectSet("SLb", OBJPROP_COLOR, Blue);
      if (li_156 > 0) f0_4(OP_SELLLIMIT);
   }
   if (li_140 > 0) {
      price_56 = NormalizeDouble(ld_72 / ld_40, Digits);
      ObjectCreate("SLs", OBJ_ARROW, 0, Time[0], price_56, 0, 0, 0, 0);
      ObjectSet("SLs", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
      ObjectSet("SLs", OBJPROP_COLOR, Red);
      if (li_152 > 0) f0_4(OP_BUYLIMIT);
   }
   if (LokNoLoss && (ld_24 > ld_16 && ld_32 >= ld_40) || (ld_24 < ld_16 && ld_32 <= ld_40)) {
      for (pos_168 = OrdersTotal() - 1; pos_168 >= 0; pos_168--) {
         if (OrderSelect(pos_168, SELECT_BY_POS, MODE_TRADES)) {
            magic_148 = OrderMagicNumber();
            if (OrderSymbol() == Symbol() && magic_148 >= magic && magic_148 <= magic + 100) {
               cmd_144 = OrderType();
               ld_188 = NormalizeDouble(OrderStopLoss(), Digits);
               price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
               if (cmd_144 == OP_BUY) {
                  price_88 = NormalizeDouble(Bid - gi_328 * Point, Digits);
                  if (price_88 >= price_96) {
                     if (price_96 > ld_188)
                        if (OrderModify(OrderTicket(), price_96, price_96, OrderTakeProfit(), 0, White)) Print("Перенос стоплосс -------------------- функция LokNoLoss");
                  }
               }
               if (cmd_144 == OP_SELL) {
                  price_88 = NormalizeDouble(Ask + gi_328 * Point, Digits);
                  if (price_88 <= price_96) {
                     if (price_96 < ld_188 || ld_188 == 0.0)
                        if (OrderModify(OrderTicket(), price_96, price_96, OrderTakeProfit(), 0, White)) Print("Перенос стоплосс -------------------- функция LokNoLoss");
                  }
               }
            }
         }
      }
   }
   if (NoLoss >= g_stoplevel_320 && NoLoss != 0.0) {
      for (pos_168 = OrdersTotal() - 1; pos_168 >= 0; pos_168--) {
         if (OrderSelect(pos_168, SELECT_BY_POS, MODE_TRADES)) {
            magic_148 = OrderMagicNumber();
            if (OrderSymbol() == Symbol() && magic_148 >= magic && magic_148 <= magic + 100) {
               cmd_144 = OrderType();
               ld_188 = NormalizeDouble(OrderStopLoss(), Digits);
               price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
               if (cmd_144 == OP_BUY && price_48 != 0.0) {
                  price_88 = NormalizeDouble(Bid - NoLoss * Point, Digits);
                  if (price_88 >= price_48) {
                     if (price_48 > ld_188)
                        if (OrderModify(OrderTicket(), price_96, price_48, OrderTakeProfit(), 0, White)) Print("Перенос стоплосс ====================== функция NoLoss");
                  }
               }
               if (cmd_144 == OP_SELL && price_56 != 0.0) {
                  price_88 = NormalizeDouble(Ask + NoLoss * Point, Digits);
                  if (price_88 <= price_56) {
                     if (price_56 < ld_188 || ld_188 == 0.0)
                        if (OrderModify(OrderTicket(), price_96, price_56, OrderTakeProfit(), 0, White)) Print("Перенос стоплосс ====================== функция NoLoss");
                  }
               }
            }
         }
      }
   }
   if (gi_332 >= g_stoplevel_320 && gi_332 != 0) {
      for (pos_168 = OrdersTotal() - 1; pos_168 >= 0; pos_168--) {
         if (OrderSelect(pos_168, SELECT_BY_POS, MODE_TRADES)) {
            magic_148 = OrderMagicNumber();
            if (OrderSymbol() == Symbol() && magic_148 >= magic && magic_148 <= magic + 100) {
               cmd_144 = OrderType();
               ld_188 = NormalizeDouble(OrderStopLoss(), Digits);
               price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
               if (cmd_144 == OP_BUY && price_48 != 0.0) {
                  price_88 = NormalizeDouble(Bid - gi_332 * Point, Digits);
                  if (price_88 > price_48 || price_88 < price_48 - gi_328 * 2 * Point) {
                     if (price_88 > ld_188 && price_88 > price_96 || price_88 > price_48)
                        if (OrderModify(OrderTicket(), price_96, price_88, OrderTakeProfit(), 0, White)) Print("Перенос стоплосс ====================== функция TrailingStop");
                  }
               }
               if (cmd_144 == OP_SELL && price_56 != 0.0) {
                  price_88 = NormalizeDouble(Ask + gi_332 * Point, Digits);
                  if (price_88 < price_56 || price_88 > price_56 + gi_328 * 2 * Point) {
                     if (price_88 < ld_188 || ld_188 == 0.0 && price_88 < price_96 || price_88 < price_56)
                        if (OrderModify(OrderTicket(), price_96, price_88, OrderTakeProfit(), 0, White)) Print("Перенос стоплосс ====================== функция TrailingStop");
                  }
               }
            }
         }
      }
   }
   if (g_bool_292 && Key != 2 * g_acc_number_324 - gi_316) {
      Comment("Демо версия,\nДля получения ключа обратитесь cmillion@narod.ru, сообщите ", g_acc_number_324);
      return;
   }
   double tradeallowed_196 = MarketInfo(Symbol(), MODE_TRADEALLOWED);
   if (tradeallowed_196 == 1.0 || (!g_bool_292)) {
      Comment(g_str_concat_284, 
         "\nBuy ", li_136, 
      "\nSell ", li_140);
   } else Comment("Торги по данному инструменту запрещены ", tradeallowed_196);
   if (DayOfWeek() != 5) {
      if (!gi_296) {
         f0_0();
         gi_296 = TRUE;
      }
   } else {
      if (li_136 + li_140 == 0 && CloseEndWeek && Hour() >= HourClose) {
         if (gi_296) {
            if (AlertOn) Alert(Symbol(), " Конец недели закрываем ордера");
            gi_296 = FALSE;
            if (DrawInfo) {
               ObjectCreate(TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES), OBJ_VLINE, 0, Time[0], 0, 0, 0, 0, 0);
               ObjectSet(TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES), OBJPROP_COLOR, Red);
            }
         }
         if (li_152 + li_156 + li_160 + li_164 > 0) f0_4(-1);
         Comment("Конец недели, не торгуем после ", HourClose);
         return;
      }
   }
   if (ProfitStartTrall == 0.0 && (!gi_300)) {
      if (ld_32 + ld_40 == 0.0) gd_368 = lotLimit * gi_328 * MarketInfo(Symbol(), MODE_TICKVALUE);
      else gd_368 = MathAbs(ld_32 - ld_40) * gi_328 * MarketInfo(Symbol(), MODE_TICKVALUE) * ProfitStartK;
   }
   int li_204 = TimeCurrent() + 60 * SleepTime;
   if (ld_8 >= gd_368) {
      gd_376 = ld_8 / 100.0 * TrailingPercentProfit;
      if (!gi_300) {
         if (AlertOn) Alert(Symbol(), " ", AccountCompany(), " Запуск трейлинга, прибыль = ", DoubleToStr(ld_8, 2));
         f0_6(Red, StringConcatenate("Start ", DoubleToStr(ld_8, 2)), -1);
      } else {
         Print(Symbol(), " ", AccountCompany(), " Запуск трейлинга, прибыль = ", DoubleToStr(ld_8, 2));
         if (ld_8 > gd_368) {
            if (AlertOn) Alert(Symbol(), "  Новый максимум Profit = ", DoubleToStr(ld_8, 2), " закрытие при ", DoubleToStr(ld_8 - gd_376, 2));
            str_concat_208 = StringConcatenate(TimeToStr(TimeCurrent(), TIME_SECONDS), " Новый максимум ", DoubleToStr(ld_8, 2));
            ObjectCreate(str_concat_208, OBJ_ARROW, 0, Time[0], Bid, 0, 0, 0, 0);
            ObjectSet(str_concat_208, OBJPROP_ARROWCODE, 4);
            ObjectSet(str_concat_208, OBJPROP_COLOR, Yellow);
         }
      }
      gi_300 = TRUE;
      if (!GlobalVariableCheck(g_var_name_416)) GlobalVariableSet(g_var_name_416, gd_368);
      gd_368 = ld_8;
      if (li_152 + li_156 + li_160 + li_164 > 0) f0_4(-1);
   }
   if (gi_300 && ld_8 <= gd_368 - gd_376) {
      if (AlertOn) Alert(Symbol(), " ", AccountCompany(), " Достигнут уровень отката по трейлингу, прибыль = ", DoubleToStr(ld_8, 2));
      f0_6(f0_5(ld_8 < 0.0, 255, 32768), StringConcatenate("Profit ", DoubleToStr(ld_8, 2)), 1);
      f0_3();
      gd_376 = gd_368 / 100.0 * TrailingPercentProfit;
      gi_300 = FALSE;
      GlobalVariableDel(g_var_name_416);
      if (SendMailInfo) {
         SendMail(StringConcatenate(gs_276, " ", AccountCompany()), StringConcatenate("Profit ", Symbol(), " = ", DoubleToStr(ld_8, 2), 
            "\nBuy ", li_136, "  Lot = ", DoubleToStr(ld_32, 2), 
            "\nSell ", li_140, "  Lot = ", DoubleToStr(ld_40, 2), 
            "\nTrailing ", DoubleToStr(ProfitStartTrall, 2), "  ", DoubleToStr(gd_368, 2), 
            "\nOrders ", OrdersTotal(), 
            "\nEquity ", DoubleToStr(AccountEquity(), 2), 
            "\nFreeMargin ", DoubleToStr(AccountFreeMargin(), 2), 
         "\nBalance ", DoubleToStr(AccountBalance(), 2)));
      }
      gd_368 = ProfitStartTrall;
      while (TimeCurrent() < li_204) {
         Comment("Достигнут уровень отката по трейлингу, новый старт программы через ", TimeToStr(li_204 - TimeCurrent(), TIME_SECONDS));
         Sleep(1000);
      }
   }
   if (li_136 >= 5 || li_140 >= 5) {
      if (gi_304 && SendMailInfo) {
         SendMail(StringConcatenate(gs_276, " ", AccountCompany()), StringConcatenate("many orders open\nProfit ", Symbol(), " = ", DoubleToStr(ld_8, 2), 
            "\nBuy ", li_136, "  Lot = ", DoubleToStr(ld_32, 2), 
            "\nSell ", li_140, "  Lot = ", DoubleToStr(ld_40, 2), 
            "\nOrders ", OrdersTotal(), 
            "\nEquity ", DoubleToStr(AccountEquity(), 2), 
            "\nFreeMargin ", DoubleToStr(AccountFreeMargin(), 2), 
         "\nBalance ", DoubleToStr(AccountBalance(), 2)));
      }
      gi_304 = FALSE;
   } else gi_304 = TRUE;
   if (!li_4 && li_136 + li_140 == 0) {
      Comment("Не торговое время ");
      if (li_152 + li_156 + li_160 + li_164 > 0) f0_4(-1);
   } else {
      if (!gi_300) {
         for (pos_168 = MathMax(Lok + OrdersStop, OrdersLimit); pos_168 > 0; pos_168--) {
            if (gda_352[pos_168] >= Ask + g_stoplevel_320 * Point && gda_344[pos_168] <= g_maxlot_424) {
               if (li_136 == 0) {
                  ticket_216 = f0_1(3, magic + pos_168);
                  if (ticket_216 == 0) {
                     if (gda_352[pos_168] - Ask <= OrdersTek * gd_336 + FirstStep * Point) f0_2(3, magic + pos_168, gda_352[pos_168]);
                  } else {
                     if (OrderSelect(ticket_216, SELECT_BY_TICKET)) {
                        price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
                        if (OrderType() > OP_SELL) {
                           if (price_96 != gda_352[pos_168]) {
                              if (SLoss != 0) price_88 = NormalizeDouble(gda_352[pos_168] + gi_308 * Point, Digits);
                              else price_88 = 0;
                              if (TProfit != 0) price_228 = NormalizeDouble(gda_352[pos_168] - gi_312 * Point, Digits);
                              else price_228 = 0;
                              if (!OrderModify(ticket_216, gda_352[pos_168], price_88, price_228, 0, Green)) Print("OrderModify SellLimit Error ", GetLastError());
                           }
                        }
                     }
                  }
               }
            }
            if (gda_364[pos_168] >= Ask + g_stoplevel_320 * Point && gda_344[pos_168] <= g_maxlot_424) {
               if (li_140 >= Lok) {
                  ticket_216 = f0_1(4, magic + pos_168);
                  if (ticket_216 == 0) {
                     if (gda_364[pos_168] - Ask <= OrdersTek * gd_336 + FirstStep * Point) f0_2(4, magic + pos_168, gda_364[pos_168]);
                  } else {
                     if (OrderSelect(ticket_216, SELECT_BY_TICKET)) {
                        price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
                        if (OrderType() > OP_SELL) {
                           if (price_96 != gda_364[pos_168]) {
                              if (SLoss != 0) price_88 = NormalizeDouble(gda_364[pos_168] + gi_308 * Point, Digits);
                              else price_88 = 0;
                              if (TProfit != 0) price_228 = NormalizeDouble(gda_364[pos_168] - gi_312 * Point, Digits);
                              else price_228 = 0;
                              if (!OrderModify(ticket_216, gda_364[pos_168], price_88, price_228, 0, Green)) Print("OrderModify BuyStop Error ", GetLastError());
                           }
                        }
                     }
                  }
               }
            }
            if (gda_356[pos_168] <= Bid - g_stoplevel_320 * Point && gda_356[pos_168] > 0.0 && gda_344[pos_168] <= g_maxlot_424) {
               if (li_140 == 0) {
                  ticket_216 = f0_1(2, magic + pos_168);
                  if (ticket_216 == 0) {
                     if (Bid - gda_356[pos_168] <= OrdersTek * gd_336 + FirstStep * Point) f0_2(2, magic + pos_168, gda_356[pos_168]);
                  } else {
                     if (OrderSelect(ticket_216, SELECT_BY_TICKET)) {
                        price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
                        if (OrderType() > OP_SELL) {
                           if (price_96 != gda_356[pos_168]) {
                              if (SLoss != 0) price_88 = NormalizeDouble(gda_356[pos_168] - gi_308 * Point, Digits);
                              else price_88 = 0;
                              if (TProfit != 0) price_228 = NormalizeDouble(gda_356[pos_168] + gi_312 * Point, Digits);
                              else price_228 = 0;
                              if (!OrderModify(ticket_216, gda_356[pos_168], price_88, price_228, 0, Green)) Print("OrderModify BuyLimit Error ", GetLastError());
                           }
                        }
                     }
                  }
               }
            }
            if (gda_360[pos_168] <= Bid - g_stoplevel_320 * Point && gda_360[pos_168] > 0.0 && gda_344[pos_168] <= g_maxlot_424) {
               if (li_136 >= Lok) {
                  ticket_216 = f0_1(5, magic + pos_168);
                  if (ticket_216 == 0) {
                     if (Bid - gda_360[pos_168] > OrdersTek * gd_336 + FirstStep * Point) continue;
                     f0_2(5, magic + pos_168, gda_360[pos_168]);
                     continue;
                  }
                  if (OrderSelect(ticket_216, SELECT_BY_TICKET)) {
                     price_96 = NormalizeDouble(OrderOpenPrice(), Digits);
                     if (OrderType() > OP_SELL) {
                        if (price_96 != gda_360[pos_168]) {
                           if (SLoss != 0) price_88 = NormalizeDouble(gda_360[pos_168] + gi_308 * Point, Digits);
                           else price_88 = 0;
                           if (TProfit != 0) price_228 = NormalizeDouble(gda_360[pos_168] - gi_312 * Point, Digits);
                           else price_228 = 0;
                           if (!OrderModify(ticket_216, gda_360[pos_168], price_88, price_228, 0, Green)) Print("OrderModify SellStop Error ", GetLastError());
                        }
                     }
                  }
               }
            }
         }
      }
      ObjectSetText("Balance", StringConcatenate("Balance ", DoubleToStr(AccountBalance(), 2)), 12, "Arial", Green);
      ObjectSetText("Equity", StringConcatenate("Equity ", DoubleToStr(AccountEquity(), 2)), 12, "Arial", Green);
      ObjectSetText("FreeMargin", StringConcatenate("Free Margin ", DoubleToStr(AccountFreeMargin(), 2)), 12, "Arial", Green);
      if (ld_32 > 0.0) ObjectSetText("ProfitB", StringConcatenate("Profit Buy ", DoubleToStr(ld_24, 2), "  Lot = ", DoubleToStr(ld_32, 2)), 12, "Arial", f0_5(ld_24 > 0.0, 32768, 255));
      else ObjectSetText("ProfitB", "", 12, "Arial", Gray);
      if (ld_40 > 0.0) ObjectSetText("ProfitS", StringConcatenate("Profit Sell ", DoubleToStr(ld_16, 2), "  Lot = ", DoubleToStr(ld_40, 2)), 12, "Arial", f0_5(ld_16 > 0.0, 32768, 255));
      else ObjectSetText("ProfitS", "", 12, "Arial", Gray);
      if (ld_40 + ld_32 > 0.0) ObjectSetText("Profit", StringConcatenate("Profit All ", DoubleToStr(ld_8, 2)), 12, "Arial", f0_5(ld_8 >= 0.0, 8421504, 32768));
      else ObjectSetText("Profit", "", 12, "Arial", Gray);
      if (gi_300) return (ObjectSetText("ProfitStartTrall", StringConcatenate("Profit Close ", DoubleToStr(gd_368 - gd_376, 2)), 10, "Arial", Gold));
      else {
      }
   }
   return (ObjectSetText("ProfitStartTrall", StringConcatenate("Profit Close ", DoubleToStr(gd_368, 2)), 10, "Arial", f0_5(gd_368 != 0.0, 8421504, 32768)));
}

int f0_1(int ai_0, int a_magic_4) {
   int cmd_8;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            if (OrderMagicNumber() == a_magic_4) {
               cmd_8 = OrderType();
               if (cmd_8 == OP_BUYLIMIT || cmd_8 == OP_BUY && ai_0 == 2) return (OrderTicket());
               if (cmd_8 == OP_SELLLIMIT || cmd_8 == OP_SELL && ai_0 == 3) return (OrderTicket());
               if (cmd_8 == OP_BUYSTOP || cmd_8 == OP_BUY && ai_0 == 4) return (OrderTicket());
               if (cmd_8 == OP_SELLSTOP || cmd_8 == OP_SELL && ai_0 == 5) return (OrderTicket());
            }
         }
      }
   }
   return (0);
}

void f0_2(int ai_0, int a_magic_4, double a_price_8) {
   double price_16;
   double price_24;
   if (SLoss == -1) gi_308 = gi_328;
   else {
      if (SLoss >= g_stoplevel_320) gi_308 = SLoss;
      else gi_308 = FALSE;
   }
   if (TProfit == -1) gi_312 = gi_328;
   else {
      if (TProfit >= g_stoplevel_320) gi_312 = TProfit;
      else gi_312 = FALSE;
   }
   if (ai_0 == 3) {
      if (SLoss != 0) price_16 = NormalizeDouble(a_price_8 + gi_308 * Point, Digits);
      else price_16 = 0;
      if (TProfit != 0) price_24 = NormalizeDouble(a_price_8 - gi_312 * Point, Digits);
      else price_24 = 0;
      if (OrderSend(Symbol(), OP_SELLLIMIT, gda_344[a_magic_4 - magic], a_price_8, 1, price_16, price_24, gs_276 + DoubleToStr(a_magic_4 - magic, 0), a_magic_4, 0, Red) == -1) Print("OrderSend SELLLIMIT Error ", GetLastError(), " Lot ", a_magic_4 - magic, " = ", gda_344[a_magic_4 - magic]);
   }
   if (ai_0 == 2) {
      if (SLoss != 0) price_16 = NormalizeDouble(a_price_8 - gi_308 * Point, Digits);
      else price_16 = 0;
      if (TProfit != 0) price_24 = NormalizeDouble(a_price_8 + gi_312 * Point, Digits);
      else price_24 = 0;
      if (OrderSend(Symbol(), OP_BUYLIMIT, gda_344[a_magic_4 - magic], a_price_8, 1, price_16, price_24, gs_276 + DoubleToStr(a_magic_4 - magic, 0), a_magic_4, 0, Blue) == -1) Print("OrderSend BUYLIMIT Error ", GetLastError(), " Lot ", a_magic_4 - magic, " = ", gda_344[a_magic_4 - magic]);
   }
   if (ai_0 == 5) {
      if (SLoss != 0) price_16 = NormalizeDouble(a_price_8 + gi_308 * Point, Digits);
      else price_16 = 0;
      if (TProfit != 0) price_24 = NormalizeDouble(a_price_8 - gi_312 * Point, Digits);
      else price_24 = 0;
      if (OrderSend(Symbol(), OP_SELLSTOP, gda_348[a_magic_4 - magic], a_price_8, 1, price_16, price_24, gs_276 + DoubleToStr(a_magic_4 - magic, 0), a_magic_4, 0, Red) == -1) Print("OrderSend SELLSTOP Error ", GetLastError(), " Lot ", a_magic_4 - magic, " = ", gda_348[a_magic_4 - magic]);
   }
   if (ai_0 == 4) {
      if (SLoss != 0) price_16 = NormalizeDouble(a_price_8 - gi_308 * Point, Digits);
      else price_16 = 0;
      if (TProfit != 0) price_24 = NormalizeDouble(a_price_8 + gi_312 * Point, Digits);
      else price_24 = 0;
      if (OrderSend(Symbol(), OP_BUYSTOP, gda_348[a_magic_4 - magic], a_price_8, 1, price_16, price_24, gs_276 + DoubleToStr(a_magic_4 - magic, 0), a_magic_4, 0, Blue) == -1) Print("OrderSend BUYSTOP Error ", GetLastError(), " Lot ", a_magic_4 - magic, " = ", gda_348[a_magic_4 - magic]);
   }
}

int f0_3() {
   int error_4;
   int li_8;
   int cmd_12;
   int magic_16;
   int count_24;
   bool is_closed_0 = TRUE;
   while (!g_bool_292 || Key == g_acc_number_324 * 2 - gi_316) {
      for (int pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS)) {
            magic_16 = OrderMagicNumber();
            if (OrderSymbol() == Symbol() && magic_16 >= magic && magic_16 <= magic + 100) {
               cmd_12 = OrderType();
               if (cmd_12 == OP_BUY) {
                  is_closed_0 = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 3, Blue);
                  if (is_closed_0) Comment("Закрыт ордер N ", OrderTicket(), "  прибыль ", OrderProfit(), "     ", TimeToStr(TimeCurrent(), TIME_SECONDS));
               }
               if (cmd_12 == OP_SELL) {
                  is_closed_0 = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 3, Red);
                  if (is_closed_0) Comment("Закрыт ордер N ", OrderTicket(), "  прибыль ", OrderProfit(), "     ", TimeToStr(TimeCurrent(), TIME_SECONDS));
               }
               if (!is_closed_0) {
                  error_4 = GetLastError();
                  if (error_4 >= 2/* COMMON_ERROR */) {
                     if (error_4 == 129/* INVALID_PRICE */) {
                        Comment("Неправильная цена ", TimeToStr(TimeCurrent(), TIME_SECONDS));
                        RefreshRates();
                        continue;
                     }
                     if (error_4 == 146/* TRADE_CONTEXT_BUSY */) {
                        if (!(IsTradeContextBusy())) continue;
                        Sleep(2000);
                        continue;
                     }
                     Comment("Ошибка ", error_4, " закрытия ордера N ", OrderTicket(), "     ", TimeToStr(TimeCurrent(), TIME_SECONDS));
                  }
               }
            }
         }
      }
      count_24 = 0;
      for (pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         if (OrderSelect(pos_20, SELECT_BY_POS)) {
            magic_16 = OrderMagicNumber();
            if (OrderSymbol() == Symbol() && magic_16 >= magic && magic_16 <= magic + 100) {
               cmd_12 = OrderType();
               if (cmd_12 == OP_BUY || cmd_12 == OP_SELL) count_24++;
            }
         }
      }
      if (count_24 == 0) break;
      li_8++;
      if (li_8 > 10) {
         if (AlertOn) Alert(Symbol(), " Не удалось закрыть все сделки, осталось еще ", count_24);
         return (0);
      }
      Sleep(1000);
      RefreshRates();
   }
   f0_0();
   return (1);
}

int f0_4(int a_cmd_0) {
   int cmd_16;
   int magic_20;
   if (a_cmd_0 == OP_BUY) {
      GlobalVariableDel(g_str_concat_392);
      GlobalVariableDel(g_str_concat_400);
      GlobalVariableDel(g_str_concat_408);
   }
   int li_unused_4 = 1;
   if (!g_bool_292 || Key == g_acc_number_324 * 2 - gi_316) {
      for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
         if (OrderSelect(pos_24, SELECT_BY_POS)) {
            magic_20 = OrderMagicNumber();
            if (OrderSymbol() == Symbol() && magic_20 >= magic && magic_20 <= magic + 100) {
               cmd_16 = OrderType();
               if (cmd_16 > OP_SELL && cmd_16 == a_cmd_0 || a_cmd_0 == -1) OrderDelete(OrderTicket());
            }
         }
      }
   }
   return (1);
}

int f0_5(bool ai_0, int ai_4, int ai_8) {
   if (ai_0) return (ai_4);
   return (ai_8);
}

void f0_6(color a_color_0, string a_text_4, int ai_12) {
   string str_concat_16;
   if (DrawInfo) {
      str_concat_16 = StringConcatenate(TimeToStr(TimeCurrent(), TIME_SECONDS), " ", a_text_4);
      ObjectDelete(str_concat_16);
      if (ai_12 == 1) ObjectCreate(str_concat_16, OBJ_TEXT, 0, Time[0], Bid, 0, 0, 0, 0);
      if (ai_12 == -1) {
         if (Low[10] > Low[0]) ObjectCreate(str_concat_16, OBJ_TEXT, 0, Time[10], Low[0], 0, 0, 0, 0);
         else ObjectCreate(str_concat_16, OBJ_TEXT, 0, Time[10], High[0], 0, 0, 0, 0);
      }
      ObjectSetText(str_concat_16, a_text_4, 10, "Times New Roman", a_color_0);
   }
}