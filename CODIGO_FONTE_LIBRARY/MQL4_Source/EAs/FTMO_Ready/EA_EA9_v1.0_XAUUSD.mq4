
#property copyright ""
#property link      ""

extern string _EA = "______Super COMBO_______";
extern int Magic = 201200727;
extern double Lots = 0.01;
extern int TakeProfit_OP1 = 10;
extern int TakeProfit_Marti = 10;
extern int StopLoss = 0;
extern int Step = 20;
extern int Max_Level = 12;
extern bool Stop_Buy = FALSE;
extern bool Stop_Sell = FALSE;
extern string _TIMEFILTER = "_______ TIME FILTER BROKER TIME _______";
extern bool Use_TimeFilter = FALSE;
extern int StartHour = 0;
extern int EndHour = 24;
int Gi_156;
int Gi_160;
int Gi_164;
string Gs_unused_168;
double Gd_176 = 2.0;
int Gi_184 = 0;
double G_lots_188;
double G_lots_196;
double G_minlot_204;
int Gi_212;
int Gi_216;
int G_slippage_220 = 10;
int Gi_224;
int Gi_228;
double G_order_lots_232;
double G_order_open_price_240;
double G_order_lots_248;
double G_order_open_price_256;
double G_order_open_price_264;
double G_order_lots_272;
int G_cmd_280;
int G_count_284;
int G_count_288;
int G_order_total_292;
int G_count_296;
int G_count_300;
bool G_is_closed_304;
bool G_is_deleted_308;
int G_datetime_312;
double Gd_unused_316;
double Gd_324;
double Gd_332;
double G_order_takeprofit_340;
double G_order_stoploss_348;
int G_count_356 = 0;
int G_count_360 = 0;
double G_order_takeprofit_364;
double G_order_takeprofit_372;
double G_order_stoploss_380;
double G_order_stoploss_388;
double Gd_396;
double Gd_404;
string Gs_412;
int G_pos_420;
double G_order_lots_424;
double Gd_432;

int init() {
   if (!IsExpertEnabled()) Alert("KLIK AKTIVASI EA");
   if (!IsTradeAllowed()) Alert("CENTANG ALLOW LIVE TRADING");
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   G_minlot_204 = MarketInfo(Symbol(), MODE_MINLOT);
   if (G_minlot_204 / 0.01 == 1.0) Gi_212 = 2;
   else Gi_212 = 1;
   if (10.0 * MarketInfo(Symbol(), MODE_LOTSTEP) < 1.0) Gi_212 = 2;
   else Gi_212 = 1;
   if (Digits == 5 || Digits == 3 || Symbol() == "GOLD" || Symbol() == "GOLD." || Symbol() == "GOLDm") {
      Gi_216 = 10;
      G_slippage_220 = 100;
   } else Gi_216 = 1;
   G_lots_188 = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), Gi_212);
   G_lots_196 = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), Gi_212);
   if (Lots < G_lots_188) Lots = G_lots_188;
   if (Lots > G_lots_196) Lots = G_lots_196;
   Lots = NormalizeDouble(Lots, Gi_212);
   Gi_228 = NormalizeDouble(MarketInfo(Symbol(), MODE_STOPLEVEL), 2);
   Gi_224 = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), 2);
   if (Gi_184 * Gi_216 < Gi_228 + Gi_224 && Gi_184 != 0) Gi_184 = (Gi_228 + Gi_224) / Gi_216;
   if (Step * Gi_216 < Gi_228 + Gi_224 && Step != 0) Step = (Gi_228 + Gi_224) / Gi_216;
   f0_4();
   if (G_count_296 == 0 && G_count_360 > 0) f0_2(2);
   if (G_count_300 == 0 && G_count_356 > 0) f0_2(3);
   f0_4();
   if (f0_6()) {
      if (G_count_296 == 0 && G_count_360 == 0 && Stop_Buy == FALSE)
         if (f0_0(Symbol(), OP_BUY, Blue, Lots, G_slippage_220, Ask, 0, 0, 0, "OP1", Magic)) G_datetime_312 = iTime(Symbol(), 0, 0);
      if (G_count_300 == 0 && G_count_356 == 0 && Stop_Sell == FALSE)
         if (f0_0(Symbol(), OP_SELL, Red, Lots, G_slippage_220, Bid, 0, 0, 0, "OP1", Magic)) G_datetime_312 = iTime(Symbol(), 0, 0);
   }
   f0_4();
   if (G_count_296 > 0 && G_count_296 < Max_Level && G_count_360 == 0) {
      Gd_324 = NormalizeDouble(G_order_lots_248 * Gd_176, Gi_212);
      if (G_count_296 == Max_Level - 1) Gd_unused_316 = StopLoss;
      else Gd_unused_316 = 0;
      Gd_332 = G_order_open_price_256 - Step * Gi_216 * Point;
      if (Ask - Gd_332 > Gi_228 * Point) {
      }
      if (Ask <= Gd_332)
         if (f0_0(Symbol(), OP_BUY, Blue, f0_8(G_count_296, 0), G_slippage_220, Ask, 0, 0, 0, "", Magic)) G_datetime_312 = iTime(Symbol(), 0, 0);
   }
   f0_4();
   if (G_count_300 > 0 && G_count_300 < Max_Level && G_count_356 == 0) {
      Gd_324 = NormalizeDouble(G_order_lots_232 * Gd_176, Gi_212);
      if (G_count_300 == Max_Level - 1) Gd_unused_316 = StopLoss;
      else Gd_unused_316 = 0;
      Gd_332 = G_order_open_price_240 + Step * Gi_216 * Point;
      if (Gd_332 - Bid > Gi_228 * Point) {
      }
      if (Bid >= Gd_332)
         if (f0_0(Symbol(), OP_SELL, Red, f0_8(G_count_300, 1), G_slippage_220, Bid, 0, 0, 0, "", Magic)) G_datetime_312 = iTime(Symbol(), 0, 0);
   }
   f0_4();
   Gd_396 = f0_11(OP_BUY);
   Gd_404 = f0_11(OP_SELL);
   if (G_count_296 > 0) {
      if (G_count_296 == 1) Gd_432 = TakeProfit_OP1;
      else Gd_432 = TakeProfit_Marti + 1;
      if (Gd_432 * Gi_216 < Gi_228 + Gi_224 && Gd_432 != 0.0) Gd_432 = (Gi_228 + Gi_224) / Gi_216;
      f0_1(OP_BUY, Gd_396 + Gd_432 * Gi_216 * Point);
      if (StopLoss != 0) f0_10(OP_BUY, Gd_396 - StopLoss * Gi_216 * Point);
   }
   if (G_count_300 > 0) {
      if (G_count_300 == 1) Gd_432 = TakeProfit_OP1;
      else Gd_432 = TakeProfit_Marti + 1;
      f0_1(OP_SELL, Gd_404 - Gd_432 * Gi_216 * Point);
      if (StopLoss != 0) f0_10(OP_SELL, Gd_404 + StopLoss * Gi_216 * Point);
   }
   f0_5(1, "MAGIC", DoubleToStr(Magic, 0));
   f0_5(2, "NAMA", AccountName());
   f0_5(3, "No. ACC", AccountNumber());
   f0_5(4, "BROKER", AccountCompany());
   f0_5(5, "LEVERAGE", "1:" + DoubleToStr(AccountLeverage(), 0));
   f0_5(6, "BALANCE", DoubleToStr(AccountBalance(), 2));
   f0_5(7, "EQUITY", DoubleToStr(AccountEquity(), 2));
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
      Alert("BALANCE TIDAK CUKUP UNTUK MEMBUKA ORDER");
      return (0);
   }
   return (0);
}

void f0_3(int A_cmd_0) {
   for (G_order_total_292 = OrdersTotal(); G_order_total_292 >= 0; G_order_total_292--) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == A_cmd_0 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic || OrderComment() == Gs_412) {
         G_order_lots_272 = OrderLots();
         G_pos_420 = G_order_total_292;
         return;
      }
   }
}

void f0_7(int A_cmd_0) {
   for (G_order_total_292 = G_pos_420 - 1; G_order_total_292 >= 0; G_order_total_292--) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == A_cmd_0 && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic || OrderComment() == Gs_412) {
         G_order_lots_424 = OrderLots();
         return;
      }
   }
}

double f0_8(int Ai_0, int Ai_4) {
   double Ld_8;
   f0_3(Ai_4);
   f0_7(Ai_4);
   int Li_16 = Ai_0;
   if (Li_16 == 1) Ld_8 = 2.0 * Lots;
   else Ld_8 = G_order_lots_424 + G_order_lots_272;
   Ld_8 = NormalizeDouble(Ld_8, Gi_212);
   return (Ld_8);
}

// D1DDCE31F1A86B3140880F6B1877CBF8
double f0_11(int A_cmd_0) {
   double Ld_4 = 0;
   double Ld_12 = 0;
   double Ld_ret_20 = 0;
   for (G_order_total_292 = 0; G_order_total_292 < OrdersTotal(); G_order_total_292++) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == A_cmd_0) {
         Ld_4 += OrderLots();
         Ld_12 += OrderLots() * OrderOpenPrice();
      }
   }
   if (Ld_4 != 0.0) Ld_ret_20 = Ld_12 / Ld_4;
   else Ld_ret_20 = 0;
   return (Ld_ret_20);
}

// 2569208C5E61CB15E209FFE323DB48B7
void f0_1(int A_cmd_0, double Ad_4) {
   for (G_order_total_292 = OrdersTotal(); G_order_total_292 >= 0; G_order_total_292--) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == A_cmd_0)
         if (NormalizeDouble(OrderTakeProfit(), Digits) != NormalizeDouble(Ad_4, Digits)) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(Ad_4, Digits), 0, CLR_NONE);
   }
}

// AA5EA51BFAC7B64E723BF276E0075513
void f0_10(int A_cmd_0, double Ad_4) {
   for (G_order_total_292 = OrdersTotal(); G_order_total_292 >= 0; G_order_total_292--) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == A_cmd_0)
         if (NormalizeDouble(OrderStopLoss(), Digits) != NormalizeDouble(Ad_4, Digits)) OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ad_4, Digits), OrderTakeProfit(), 0, CLR_NONE);
   }
}

// 689C35E4872BA754D7230B8ADAA28E48
void f0_5(int Ai_0, string As_4, string As_12) {
   int Li_20;
   int Li_24;
   if ((!IsTradeAllowed()) || (!IsExpertEnabled())) {
      ObjectDelete("baris0");
      return;
   }
   switch (Ai_0) {
   case 1:
      Li_20 = 40;
      Li_24 = 60;
      break;
   case 2:
      Li_20 = 40;
      Li_24 = 75;
      break;
   case 3:
      Li_20 = 40;
      Li_24 = 90;
      break;
   case 4:
      Li_20 = 40;
      Li_24 = 105;
      break;
   case 5:
      Li_20 = 40;
      Li_24 = 120;
      break;
   case 6:
      Li_20 = 40;
      Li_24 = 135;
      break;
   case 7:
      Li_20 = 40;
      Li_24 = 150;
      break;
   case 8:
      Li_20 = 40;
      Li_24 = 165;
      break;
   case 9:
      Li_20 = 40;
      Li_24 = 180;
      break;
   case 10:
      Li_20 = 40;
      Li_24 = 195;
      break;
   case 11:
      Li_20 = 40;
      Li_24 = 210;
      break;
   case 12:
      Li_20 = 40;
      Li_24 = 225;
      break;
   case 13:
      Li_20 = 40;
      Li_24 = 240;
      break;
   case 14:
      Li_20 = 40;
      Li_24 = 255;
      break;
   case 15:
      Li_20 = 40;
      Li_24 = 270;
      break;
   case 16:
      Li_20 = 40;
      Li_24 = 285;
      break;
   case 17:
      Li_20 = 40;
      Li_24 = 300;
   }
   f0_9("baris0", WindowExpertName() + " Salam Profit", 10, 40, 20, Red, 0);
   f0_9("baris00", "Donasi Seiklasnya U7126318 ", 8, 40, 10, Yellow, 2);
   f0_9("baris" + Ai_0, As_4, 8, Li_20, Li_24, Yellow, 0);
   f0_9("baris_" + Ai_0, ":", 8, Li_20 + 150, Li_24, Yellow, 0);
   f0_9("baris-" + Ai_0, As_12, 8, Li_20 + 160, Li_24, Yellow, 0);
}

// A9B24A824F70CC1232D1C2BA27039E8D
void f0_9(string A_name_0, string A_text_8, int A_fontsize_16, int A_x_20, int A_y_24, color A_color_28, int A_corner_32) {
   if (ObjectFind(A_name_0) < 0) ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet(A_name_0, OBJPROP_CORNER, A_corner_32);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_20);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_24);
   ObjectSetText(A_name_0, A_text_8, A_fontsize_16, "Tahoma", A_color_28);
}

// 09CBB5F5CE12C31A043D5C81BF20AA4A
int f0_0(string A_symbol_0, int A_cmd_8, color A_color_12, double A_lots_16, double A_slippage_24, double Ad_32, int Ai_40, double Ad_44, double Ad_52, string A_comment_60, int A_magic_68) {
   double price_72;
   double price_80;
   int ticket_88 = 0;
   RefreshRates();
   Gi_228 = NormalizeDouble(MarketInfo(Symbol(), MODE_STOPLEVEL), 0);
   Gi_224 = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), 0);
   if (A_cmd_8 == OP_BUY || A_cmd_8 == OP_BUYLIMIT || A_cmd_8 == OP_BUYSTOP) {
      if (Ad_52 * Gi_216 > Gi_228 && (!Ai_40)) price_72 = Ad_32 + Ad_52 * Gi_216 * Point;
      else price_72 = 0;
      if (Ad_44 * Gi_216 > Gi_228 + Gi_224 && (!Ai_40)) price_80 = Ad_32 - Ad_44 * Gi_216 * Point;
      else price_80 = 0;
      if (Ad_44 == 0.0) price_80 = 0;
   }
   if (A_cmd_8 == OP_SELL || A_cmd_8 == OP_SELLLIMIT || A_cmd_8 == OP_SELLSTOP) {
      if (Ad_52 * Gi_216 > Gi_228 && (!Ai_40)) price_72 = Ad_32 - Ad_52 * Gi_216 * Point;
      else price_72 = 0;
      if (Ad_44 * Gi_216 > Gi_228 + Gi_224 && (!Ai_40)) price_80 = Ad_32 + Ad_44 * Gi_216 * Point;
      else price_80 = 0;
      if (Ad_44 == 0.0) price_80 = 0;
   }
   ticket_88 = OrderSend(A_symbol_0, A_cmd_8, A_lots_16, NormalizeDouble(Ad_32, Digits), A_slippage_24, price_80, price_72, A_comment_60, A_magic_68, 0, A_color_12);
   if (ticket_88 <= 0) Sleep(1000);
   else return (1);
   return (0);
}

// 6ABA3523C7A75AAEA41CC0DEC7953CC5
int f0_6() {
   Gi_156 = EndHour + Gi_164;
   Gi_160 = StartHour + Gi_164;
   if (StartHour + Gi_164 < 0) Gi_160 = StartHour + Gi_164 + 24;
   if (EndHour + Gi_164 < 0) Gi_156 = EndHour + Gi_164 + 24;
   if (StartHour + Gi_164 > 24) Gi_160 = StartHour + Gi_164 - 24;
   if (EndHour + Gi_164 > 24) Gi_156 = EndHour + Gi_164 - 24;
   if (Use_TimeFilter == FALSE) {
      Gs_unused_168 = "";
      return (1);
   }
   if (Gi_160 < Gi_156) {
      if (Hour() >= Gi_160 && Hour() < Gi_156) {
         Gs_unused_168 = "";
         return (1);
      }
      Gs_unused_168 = "WARNING: Trading diluar Time Filter, No Open Position\n";
      return (0);
   }
   if (Gi_160 > Gi_156) {
      if (Hour() >= Gi_160 || Hour() < Gi_156) {
         Gs_unused_168 = "";
         return (1);
      }
      Gs_unused_168 = "WARNING: Trading diluar Time Filter, No Open Position\n";
      return (0);
   }
   return (0);
}

// 58B0897F29A3AD862616D6CBF39536ED
void f0_4() {
   G_count_288 = 0;
   G_count_296 = 0;
   G_count_300 = 0;
   G_count_284 = 0;
   G_count_356 = 0;
   G_count_360 = 0;
   for (G_order_total_292 = 0; G_order_total_292 < OrdersTotal(); G_order_total_292++) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY || OrderType() == OP_SELL) {
         G_count_288++;
         G_order_open_price_264 = OrderOpenPrice();
         G_order_lots_272 = OrderLots();
         G_cmd_280 = OrderType();
         G_order_takeprofit_340 = OrderTakeProfit();
         G_order_stoploss_348 = OrderStopLoss();
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT) G_count_284++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT) G_count_356++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) G_count_360++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY) {
         G_count_296++;
         G_order_open_price_256 = OrderOpenPrice();
         G_order_takeprofit_364 = OrderTakeProfit();
         G_order_stoploss_380 = OrderStopLoss();
         G_order_lots_248 = OrderLots();
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELL) {
         G_count_300++;
         G_order_open_price_240 = OrderOpenPrice();
         G_order_lots_232 = OrderLots();
         G_order_takeprofit_372 = OrderTakeProfit();
         G_order_stoploss_388 = OrderStopLoss();
      }
   }
}

// 50257C26C4E5E915F022247BABD914FE
void f0_2(int Ai_0) {
   int count_4;
   G_is_closed_304 = FALSE;
   G_is_deleted_308 = FALSE;
   for (G_order_total_292 = OrdersTotal(); G_order_total_292 >= 0; G_order_total_292--) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY && Ai_0 == 0 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_closed_304 == 0) {
               RefreshRates();
               G_is_closed_304 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), G_slippage_220, Blue);
               if (G_is_closed_304 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_closed_304 = TRUE;
            }
            G_is_closed_304 = FALSE;
         }
         if (OrderType() == OP_SELL && Ai_0 == 1 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_closed_304 == 0) {
               RefreshRates();
               G_is_closed_304 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), G_slippage_220, Red);
               if (G_is_closed_304 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_closed_304 = TRUE;
            }
            G_is_closed_304 = FALSE;
         }
      }
   }
   for (G_order_total_292 = OrdersTotal(); G_order_total_292 >= 0; G_order_total_292--) {
      OrderSelect(G_order_total_292, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUYLIMIT && Ai_0 == 2 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_308 == 0) {
               RefreshRates();
               G_is_deleted_308 = OrderDelete(OrderTicket());
               if (G_is_deleted_308 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_308 = TRUE;
            }
            G_is_deleted_308 = FALSE;
         }
         if (OrderType() == OP_SELLLIMIT && Ai_0 == 3 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_308 == 0) {
               RefreshRates();
               G_is_deleted_308 = OrderDelete(OrderTicket());
               if (G_is_deleted_308 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_308 = TRUE;
            }
            G_is_deleted_308 = FALSE;
         }
         if (OrderType() == OP_BUYSTOP && Ai_0 == 4 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_308 == 0) {
               RefreshRates();
               G_is_deleted_308 = OrderDelete(OrderTicket());
               if (G_is_deleted_308 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_308 = TRUE;
            }
            G_is_deleted_308 = FALSE;
         }
         if (OrderType() == OP_SELLSTOP && Ai_0 == 5 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_308 == 0) {
               RefreshRates();
               G_is_deleted_308 = OrderDelete(OrderTicket());
               if (G_is_deleted_308 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_308 = TRUE;
            }
            G_is_deleted_308 = FALSE;
         }
      }
   }
}
