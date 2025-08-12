#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
#property description "Join Telegram Channel for daily Unlimited Source Codes @ex4tomq4decompilercom"
#property description "Find Fresh Decompiled Source Codes - https://www.ex4tomq4decompiler.com/free-mt4-robots"
//---

enum enum_nbuyqwlot
{
 alk = 0, //Low Risk Set(20% annual profit)
 kje = 1, //Mid Risk Set(40% annual profit)
 shg = 2, //Considerable Risk Set (80% annual profit)
 sje = 3, //High Risk Set (120% annual profit)
 nba = 4, //Dynamic Lot (based on Equity)
 nbe = 5, //Dynamic Lot (based on Balance)
 jhw = 6, //Deposit Load (%)
 kwe = 7  //Fixed Lot (Initial Lot) 
};
extern string MM_Setting = "----------------  Select the risk settings  ----------------";
input enum_nbuyqwlot LotSizingMethod = 0;
extern double LotSizingValueFixed = 0.01;
extern double LotSizingValueDynamic = 5000.0;
extern double LotSizingDepositLoadPercent = 0.15;
extern string Strategy_Setting = "------  Modify the pairs if you have a suffix  ------";
extern string Symbols = "AUDCAD,AUDNZD,NZDCAD";
extern string Additional_Setting = "------  Change the comment and instance  ------";
extern string TradeComment = "Miracle";
extern int UID = 0;
extern bool ShowPanel = TRUE;


 string EA_Name = "Miracle EA";
string Use_TradeAgain = "If => TRUE,EA will trade again,If => FALSE => EA will Off";
bool TradeAgain = TRUE;
string Use_LotSizingValueDynamic = "Example = 10,EA will trader for 10 Laps";
//int LotSizingValueDynamic = 10000;
int Gi_108;
 string Use_Hour = "Start End Hour";
 int StartTrade = 0;
 int EndTrade = 23;
 string Use_DbLots = "If = 1-> Multiplier Lot, If = 2-> Fixed Lot";
 int DbLots = 1;
 double Lots = 0.01;
 double SL = 0.0;
 double TP = 4.0;
 double Distance = 3.0;
 double Multiplier = 1.6;
 int MaxLevel = 20;
double Gd_176 = 3.0;
 double LotsDecimal = 2.0;
 int MagicNumber = 163991;
string EA_Comment = "Miracle MT4";
double Gd_unused_204 = 0.0;
double G_price_212;
double G_price_220;
double G_bid_228;
double G_ask_236;
double Gd_244;
double Gd_252;
bool Gi_260;
datetime G_time_264 = 0;
int Gi_268 = 0;
double Gd_272;
int G_pos_280 = 0;
int Gi_284;
double Gd_288 = 0.0;
bool Gi_296 = FALSE;
bool Gi_300 = FALSE;
bool Gi_304 = FALSE;
int Gi_308;
bool Gi_312 = FALSE;
double Gd_316;
//int Gi_324 = 65535;
//int Gi_328 = 65535;
//extern int Gi_332 = Lime;
extern color Gi_324 = Yellow;
extern color Gi_328 = Red;
extern color Gi_332 = Lime;
double Gd_336;
double MoneyPerLot = 1.7;

int init() {
 
   if (Digits == 3 || Digits == 5) Gd_316 = 10.0 * Point;
   else Gd_316 = Point;
   return (0);
}

int deinit() {
   ObjectsDeleteAll();
   return (0);
}

int start() {
   double order_lots_0;
   double order_lots_8;
   double iclose_16;
   double iclose_24;
   double Ld_32;
   f0_8();
   f0_9();
   f0_0();
   if (f0_10()) {
      if (G_time_264 == Time[0]) return (0);
      G_time_264 = Time[0];
      Gi_284 = f0_12();
      if (Gi_284 == 0) Gi_260 = FALSE;
      for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
         if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               Gi_300 = TRUE;
               Gi_304 = FALSE;
               order_lots_0 = OrderLots();
               break;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_SELL) {
               Gi_300 = FALSE;
               Gi_304 = TRUE;
               order_lots_8 = OrderLots();
               break;
            }
         }
      }
      if (Gi_284 > 0 && Gi_284 <= MaxLevel) {
         RefreshRates();
         Gd_244 = f0_11();
         Gd_252 = f0_3();
         if (Gi_300 && Gd_244 - Ask >= Distance * Gd_316) Gi_296 = TRUE;
         if (Gi_304 && Bid - Gd_252 >= Distance * Gd_316) Gi_296 = TRUE;
      }
      if (Gi_284 < 1) {
         Gi_304 = FALSE;
         Gi_300 = FALSE;
         Gi_296 = TRUE;
      }
      if (Gi_296) {
         Gd_244 = f0_11();
         Gd_252 = f0_3();
         if (Gi_304) {
            Gd_272 = f0_4(OP_SELL);
            Gi_268 = Gi_284;
            if (Gd_272 > 0.0) {
               RefreshRates();
               Gi_308 = f0_5(1, Gd_272, Bid, Gd_176, Ask, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
               if (Gi_308 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               Gd_252 = f0_3();
               Gi_296 = FALSE;
               Gi_312 = TRUE;
            }
         } else {
            if (Gi_300) {
               Gd_272 = f0_4(OP_BUY);
               Gi_268 = Gi_284;
               if (Gd_272 > 0.0) {
                  Gi_308 = f0_5(0, Gd_272, Ask, Gd_176, Bid, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                  if (Gi_308 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  Gd_244 = f0_11();
                  Gi_296 = FALSE;
                  Gi_312 = TRUE;
               }
            }
         }
      }
      if (Hour() >= StartTrade && Hour() < EndTrade) {
         if (Gi_108 < LotSizingValueDynamic && TradeAgain) {
            if (Gi_296 && Gi_284 < 1) {
               iclose_16 = iClose(Symbol(), 0, 2);
               iclose_24 = iClose(Symbol(), 0, 1);
               G_bid_228 = Bid;
               G_ask_236 = Ask;
               if ((!Gi_304) && (!Gi_300)) {
                  Gi_268 = Gi_284;
                  if (iclose_16 > iclose_24) {
                     Gd_272 = f0_4(OP_SELL);
                     if (Gd_272 > 0.0) {
                        Gi_308 = f0_5(1, Gd_272, G_bid_228, Gd_176, G_bid_228, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                        Gi_108++;
                        if (Gi_308 < 0) {
                           Print(Gd_272, "Error: ", GetLastError());
                           return (0);
                        }
                        Gd_244 = f0_11();
                        Gi_312 = TRUE;
                     }
                  } else {
                     Gd_272 = f0_4(OP_BUY);
                     if (Gd_272 > 0.0) {
                        Gi_308 = f0_5(0, Gd_272, G_ask_236, Gd_176, G_ask_236, 0, 0, EA_Comment + "-" + Gi_268, MagicNumber, 0, CLR_NONE);
                        Gi_108++;
                        if (Gi_308 < 0) {
                           Print(Gd_272, "Error: ", GetLastError());
                           return (0);
                        }
                        Gd_252 = f0_3();
                        Gi_312 = TRUE;
                     }
                  }
               }
            }
         }
      }
      Gi_284 = f0_12();
      G_price_220 = 0;
      Ld_32 = 0;
      for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
         if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               G_price_220 += OrderOpenPrice() * OrderLots();
               Ld_32 += OrderLots();
            }
         }
      }
      if (Gi_284 > 0) G_price_220 = NormalizeDouble(G_price_220 / Ld_32, Digits);
      if (Gi_312) {
         for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
            if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_BUY) {
                  G_price_212 = G_price_220 + TP * Gd_316;
                  Gd_288 = G_price_220 - SL * Gd_316;
                  Gi_260 = TRUE;
               }
            }
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_SELL) {
                  G_price_212 = G_price_220 - TP * Gd_316;
                  Gd_288 = G_price_220 + SL * Gd_316;
                  Gi_260 = TRUE;
               }
            }
         }
      }
      if (!Gi_312) return (0);
      if (Gi_260 != TRUE) return (0);
      for (G_pos_280 = OrdersTotal() - 1; G_pos_280 >= 0; G_pos_280--) {
         if (OrderSelect(G_pos_280, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) if (OrderModify(OrderTicket(), G_price_220, OrderStopLoss(), G_price_212, 0, White))
         Gi_312 = FALSE;
      }
   }
   return (0);
}

double f0_4(int A_cmd_0) {
   double lots_4;
   int datetime_12;
   switch (DbLots) {
   case 0:
      lots_4 = Lots;
      break;
   case 1:
      lots_4 = NormalizeDouble(Lots * MathPow(Multiplier, Gi_268), LotsDecimal);
      break;
   case 2:
      datetime_12 = 0;
      lots_4 = Lots;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (datetime_12 < OrderCloseTime()) {
                  datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) {
                     lots_4 = NormalizeDouble(OrderLots() * Multiplier, LotsDecimal);
                     continue;
                  }
                  lots_4 = Lots;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), A_cmd_0, lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (lots_4);
}

int f0_12() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

int f0_5(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_unused_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch (Ai_0) {
   case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, SL), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, SL), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         RefreshRates();
         ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_14(Bid, SL), f0_1(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_7(Ad_24, SL), f0_2(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_7(Ad_24, SL), f0_2(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_7(Ask, SL), f0_2(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}

double f0_14(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Gd_316);
}

double f0_7(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Gd_316);
}

double f0_1(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Gd_316);
}

double f0_2(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Gd_316);
}

double f0_11() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

double f0_3() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

void f0_0() {
   if (iClose(Symbol(), PERIOD_H1, 0) > iClose(Symbol(), PERIOD_H1, 2)) {
      if (iClose(Symbol(), PERIOD_H1, 0) < iClose(Symbol(), PERIOD_H1, 2)) {
         if (iClose(Symbol(), PERIOD_H1, 0) > iClose(Symbol(), PERIOD_H1, 1)) {
            if (iClose(Symbol(), PERIOD_H1, 0) < iClose(Symbol(), PERIOD_H1, 1)) {
               if (iOpen(Symbol(), 0, 0) > iOpen(Symbol(), 0, 1)) {
                  if (iOpen(Symbol(), 0, 0) < iOpen(Symbol(), 0, 1)) {
                     if (iClose(Symbol(), 0, 0) > iClose(Symbol(), 0, 1)) {
                        if (iClose(Symbol(), 0, 0) >= iClose(Symbol(), 0, 1)) {
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

double f0_13() {
   Gd_336 = 0;
   double Ld_ret_0 = 0;
   for (int pos_8 = 0; pos_8 < OrdersHistoryTotal(); pos_8++) {
      if (OrderSelect(pos_8, SELECT_BY_POS, MODE_HISTORY))
      if (OrderType() == OP_BUY && 1) Gd_336 += OrderLots();
   }
   Ld_ret_0 = Gd_336 * MoneyPerLot;
   return (Ld_ret_0);
}

void f0_8() {
   ObjectCreate("Original", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Original", " ", 10, "Arial Bold", Red);
   ObjectSet("Original", OBJPROP_CORNER, 2);
   ObjectSet("Original", OBJPROP_XDISTANCE, 200);
   ObjectSet("Original", OBJPROP_YDISTANCE, 10);
}

void f0_9() {
   color color_0;
   int Li_4 = 65280;
   if (AccountEquity() - AccountBalance() < 0.0) Li_4 = 255;
   if (Seconds() >= 0 && Seconds() < 10) color_0 = Red;
   if (Seconds() >= 10 && Seconds() < 20) color_0 = Violet;
   if (Seconds() >= 20 && Seconds() < 30) color_0 = Orange;
   if (Seconds() >= 30 && Seconds() < 40) color_0 = Blue;
   if (Seconds() >= 40 && Seconds() < 50) color_0 = Yellow;
   if (Seconds() >= 50 && Seconds() <= 59) color_0 = Aqua;
   string Ls_8 = "-------------------------------------------";
   f0_6("L01", "Arial", 9, 10, 10, Gi_328, 1, Ls_8);
   f0_6("L02", "Verdana", 15, 10, 25, color_0, 1, "Miracle MT4");
   f0_6("L0i", "Mistral", 12, 10, 45, Gi_324, 1, "Scalping");
   f0_6("L03", "Arial", 9, 10, 60, Gi_328, 1, Ls_8);
   f0_6("L04", "Arial", 9, 10, 75, Gi_332, 1, "Account Company: " + AccountCompany());
   f0_6("L05", "Arial", 9, 10, 90, Gi_332, 1, "Name Server: " + AccountServer());
   f0_6("L06", "Arial", 9, 10, 105, Gi_332, 1, "Account Name: " + AccountName());
   f0_6("L07", "Arial", 9, 10, 120, Gi_332, 1, "Name Number: " + AccountNumber());
   f0_6("L08", "Arial", 9, 10, 135, Gi_332, 1, "Account Leverage: 1 " + AccountLeverage());
   f0_6("L09", "Arial", 9, 10, 150, Gi_332, 1, "Time Server: " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   f0_6("L10", "Arial", 9, 10, 165, Gi_332, 1, "Spread: " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0));
   f0_6("L11", "Arial", 9, 10, 180, Gi_332, 1, "Account Balance: $ " + DoubleToStr(AccountBalance(), 2));
   f0_6("L12", "Arial", 9, 10, 195, Gi_332, 1, "Account Equity: $ " + DoubleToStr(AccountEquity(), 2));
   f0_6("L13", "Arial", 9, 10, 210, Gi_332, 1, "Order Total: " + DoubleToStr(OrdersTotal(), 0));
   f0_6("L14", "Arial", 9, 10, 390, Li_4, 1, "Profit / Loss: $ " + DoubleToStr(AccountEquity() - AccountBalance(), 2));
   f0_6("L15", "Arial", 15, 10, 425, Li_4, 1, " Reembolso: $ " + DoubleToStr(f0_13(), 2));
   ObjectCreate("j", OBJ_LABEL, 0, 0, 0);
   ObjectSet("j", OBJPROP_CORNER, 2);
   ObjectSet("j", OBJPROP_XDISTANCE, 10);
   ObjectSet("j", OBJPROP_YDISTANCE, 10);
   ObjectSetText("j", "Miracle MT4 ", 15, "Mistral", color_0);
}

void f0_6(string A_name_0, string A_fontname_8, int A_fontsize_16, int A_x_20, int A_y_24, color A_color_28, int A_corner_32, string A_text_36) {
   if (ObjectFind(A_name_0) < 0) ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(A_name_0, A_text_36, A_fontsize_16, A_fontname_8, A_color_28);
   ObjectSet(A_name_0, OBJPROP_CORNER, A_corner_32);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_20);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_24);
}

int f0_10() {
   if (IsTesting()) return (1);
   if (IsTradeAllowed()) return (1);
   return (0);
}
