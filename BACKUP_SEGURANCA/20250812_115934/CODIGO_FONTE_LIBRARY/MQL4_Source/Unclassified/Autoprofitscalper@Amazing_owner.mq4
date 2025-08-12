#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property show_inputs

#include <WinUser32.mqh>
//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import "user32.dll"
   int GetDlgItem(int a0, int a1);
   int GetAncestor(int a0, int a1);
#import "newest.dll"
   string val_bid_ask(string a0);
   string inits(string a0);
#import

string Gs_76 = "The Skyla Foundation ||  Best EA ||  Version 3.2";
extern bool read_pr_nastr = FALSE;
extern bool trade = TRUE;
extern double MinUr = 5.0;
extern double Slippage = 2.0;
extern double Lots = 0.1;
extern int LotsPercent = 40;
extern double max_lots = 2.9;
extern int TakeProfit = 0;
extern int StopLoss = 0;
extern double FixTP = 1.0;
extern double FixSL = 7.0;
extern int sdvig_bid = 0;
extern int luft = 0;
extern int Fixspred = 0;
extern bool whc = FALSE;
extern int NTrades = 3;
extern bool sound = TRUE;
extern bool spred_saxo = TRUE;
extern bool visual = TRUE;
extern bool visual_bid = TRUE;
extern bool visual_pr_kotir = FALSE;
extern bool new_kot = FALSE;
extern bool ruka = FALSE;
extern int Dig = 1;
extern bool setka = FALSE;
extern bool mt_setka_vykl = FALSE;
string Gs_212 = "";
int Gi_220 = 3;
double Gd_224 = 0.0;
int Gi_232 = 300;
double Gd_236;
double Gd_244;
double Gd_252;
int Gi_260;
color G_color_264 = Green;
string Gs_268 = "expert.wav";
double G_point_276;
string Gs_dummy_284;
string Gs_dummy_292;
int G_fontsize_300;
int G_fontsize_304;
double Gd_308;
double Gd_316;
int G_magic_324;
int Gi_328;
int Gi_332;
double Gd_336;
int G_ticket_344;
int G_pos_348;
int G_count_352;
string Gs_dummy_356;
string Gs_dummy_364;
string Gs_372;
string Gs_380;
string Gs_388;
double Gd_unused_396 = 0.0;
double Gd_404;
double Gd_412;
double Gd_420;
double Gd_428;
double Gd_436;
double Gd_444;
double Gd_452;
string Gs_dummy_460;
string Gs_468;
double Gd_476;
double Gd_484;
int Gi_492;
int Gi_unused_496 = 0;
int Gi_500;
int Gi_504;
int Gi_508;
int Gi_512;
extern int Account = 99460;
string Gs_520;
double Gd_528;
double G_ask_536;
double G_marginrequired_544;
double G_lotstep_552;
double Gd_560;
double Gd_568;
string Gs_576 = "";
string Gs_584;
string Gs_592;
string G_symbol_600;
string Gs_608;
string Gs_616;
string Gs_dummy_624;
bool Gi_632 = FALSE;
int Gi_unused_636;

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_0;
   double price_4;
   double price_12;
   string Ls_unused_20;
   if (AccountNumber() != Account) {
      Print("Неправильный номер счёта");
      return (0);
   }
   G_symbol_600 = "";
   Gi_unused_636 = 0;
   int Li_28 = GetTickCount();
   MathSrand(TimeLocal());
   G_magic_324 = MathRand();
   if (ruka) G_magic_324 = 0;
   double Ld_32 = TakeProfit;
   double Ld_40 = StopLoss;
   G_marginrequired_544 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   G_lotstep_552 = MarketInfo(Symbol(), MODE_LOTSTEP);
   Gd_560 = MarketInfo(Symbol(), MODE_MINLOT);
   Gd_568 = MarketInfo(Symbol(), MODE_MAXLOT);
   bool Li_48 = TRUE;
   while (IsStopped() == FALSE) {
      if (AccountEquity() != 0.0 && Li_48 == TRUE) {
         f0_13();
         f0_11();
         Li_48 = FALSE;
      }
      Gs_468 = Gs_76 
      + "\n";
      Gs_468 = Gs_468 + " " 
      + "\n";
      Gs_468 = Gs_468 + "Last inquiry about the warrant worked" + DoubleToStr((GetTickCount() - Gi_260) / 1000, 0) + " Seconds back. currency " + Gs_212 
      + "\n";
      Gs_468 = Gs_468 + " " 
      + "\n";
      if (ruka) {
         Gs_468 = Gs_468 + "The manual mode is included" 
         + "\n";
      }
      if (new_kot) {
         Gs_468 = Gs_468 + "The new mode of quotations is included" 
         + "\n";
      }
      Gs_468 = Gs_468 + "Operation minimum level=" + DoubleToStr(MinUr, 1) 
      + "\n";
      Gs_468 = Gs_468 + "Rigid stop=" + DoubleToStr(StopLoss, 0) + "  Rigid teik profit=" + DoubleToStr(TakeProfit, 0) 
      + "\n";
      Gs_584 = inits("a");
      if (Gi_632) Print(Gs_584);
      Li_0 = StrToDouble(f0_2(Gs_584, -1));
      Gs_468 = Gs_468 + " " 
      + "\n";
      Gs_468 = Gs_468 + "Quantity of currencies in handling=" + Li_0 
      + "\n";
      if (Gi_632) Print(Li_0);
      Gd_412 = 0;
      Gs_592 = "";
      Gs_608 = "";
      Gs_616 = "";
      for (int count_52 = 0; count_52 < Li_0; count_52++) {
         if (Gi_632) Print(Gd_412);
         f0_12(count_52);
         if (Gi_328 == 0 && G_point_276 == 0.0) continue;
         f0_1();
         TakeProfit = Ld_32;
         StopLoss = Ld_40;
         if (trade && Gd_428 > 0.0) {
            G_count_352 = 0;
            if (OrdersTotal() > 0) {
               for (G_pos_348 = 0; G_pos_348 < OrdersTotal(); G_pos_348++) {
                  OrderSelect(G_pos_348, SELECT_BY_POS, MODE_TRADES);
                  if (OrderSymbol() == G_symbol_600 && OrderMagicNumber() == G_magic_324) G_count_352++;
               }
            }
            if (G_count_352 < NTrades && MathAbs(Gd_412) >= Gd_308 + Gd_316 && GetTickCount() - Gi_260 >= 5000) {
               Gi_260 = GetTickCount();
               Gs_212 = G_symbol_600;
               price_4 = 0;
               price_12 = 0;
               f0_11();
               if (Gd_412 >= Gd_308) {
                  if (whc != TRUE && TakeProfit > 0) price_4 = G_ask_536 + TakeProfit * G_point_276;
                  if (whc != TRUE && StopLoss > 0) price_12 = Gd_528 - StopLoss * G_point_276;
                  if (ruka) {
                     f0_10();
                     G_ticket_344 = 1;
                  } else {
                     if (!AccountFreeMarginCheck(G_symbol_600, OP_BUY, Lots) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) G_ticket_344 = OrderSend(G_symbol_600, OP_BUY, Lots, G_ask_536 - luft * G_point_276, Slippage, price_12, price_4, 0, G_magic_324, 0, MediumBlue);
                     Print(G_symbol_600 + " buy at the price=" + G_ask_536 + " price Saxo bank=" + Gd_404 + " i=" + Gd_412 + " lot=" + NormalizeDouble(Lots, 2) + " spread Saxo bank=" +
                        NormalizeDouble(Gd_224, 1) + " спред мт=" + NormalizeDouble(Gd_316, 2) + " стоп=" + price_12 + " тейком=" + price_4);
                  }
                  if (G_ticket_344 > 0) {
                     if (OrderSelect(G_ticket_344, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY order opened : ", ErrorDescription(OrderOpenPrice()));
                     PlaySound(Gs_268);
                  } else Print("Error opening BUY order : ", ErrorDescription(GetLastError()));
               }
               if (Gd_412 <= -Gd_308) {
                  if (whc != TRUE && TakeProfit > 0) price_4 = Gd_528 - TakeProfit * G_point_276;
                  if (whc != TRUE && StopLoss > 0) price_12 = G_ask_536 + StopLoss * G_point_276;
                  if (ruka) {
                     f0_10();
                     G_ticket_344 = 1;
                  } else {
                     if (!AccountFreeMarginCheck(G_symbol_600, OP_SELL, Lots) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) G_ticket_344 = OrderSend(G_symbol_600, OP_SELL, Lots, Gd_528 + luft * G_point_276, Slippage, price_12, price_4, 0, G_magic_324, 0, Red);
                     Print(G_symbol_600 + " sell at the price=" + Gd_528 + " price Saxo bank=" + Gd_404 + " i=" + Gd_412 + " лотом=" + NormalizeDouble(Lots, 2) + " spread Saxo bank=" +
                        NormalizeDouble(Gd_224, 1) + " спред мт=" + NormalizeDouble(Gd_316, 2) + " стоп=" + price_12 + " тейком=" + price_4);
                  }
                  if (G_ticket_344 > 0) {
                     if (OrderSelect(G_ticket_344, SELECT_BY_TICKET, MODE_TRADES)) Print("SELL order opened : ", OrderOpenPrice());
                     PlaySound(Gs_268);
                  } else Print("Error opening SELL order : ", ErrorDescription(GetLastError()));
               }
               if (whc == TRUE && TakeProfit > 0) {
                  f0_9();
                  f0_8();
               }
               if (whc == TRUE && StopLoss > 0) {
                  f0_0();
                  f0_7();
               }
            }
         }
         if (Gi_632) Print(MathAbs(Gd_412), " ", (G_ask_536 - Gd_528) / G_point_276);
         if (FixTP != 0.0)
            if (MathAbs(Gd_412) <= (G_ask_536 - Gd_528) / G_point_276) f0_6();
         if (FixSL != 0.0)
            if (MathAbs(Gd_412) < Gd_316) f0_4();
         Gi_332++;
         if (visual && Symbol() == G_symbol_600) {
            G_fontsize_300 = 14;
            G_fontsize_304 = 8;
            G_color_264 = Red;
            if (MathAbs(Gd_412) >= Gd_308 + Gd_316) {
               G_fontsize_300 = 26;
               G_fontsize_304 = 16;
               G_color_264 = Lime;
            }
            f0_5();
         }
      }
      Gs_468 = Gs_468 + "The list of currencies " + Gs_592 
      + "\n";
      Gs_468 = Gs_468 + Gs_608;
      Gs_468 = Gs_468 + " " 
      + "\n";
      Gs_468 = Gs_468 + Gs_616;
      Gs_468 = Gs_468 + " " 
      + "\n";
      if (trade) Gs_520 = "Trade is permitted";
      else Gs_520 = "Trade is prohibited";
      Gs_468 = Gs_468 + "program teik=" + DoubleToStr(Gd_484, 1) 
      + "\n";
      Gs_468 = Gs_468 + "program stop=" + DoubleToStr(FixSL, 1) 
      + "\n";
      Gs_468 = Gs_468 + "Deposit percent=" + DoubleToStr(LotsPercent, 1) 
      + "\n";
      Gs_468 = Gs_468 + "Working lot=" + DoubleToStr(Lots, 2) 
      + "\n";
      Gs_468 = Gs_468 
         + "\n" 
         + Gs_520 
      + "\n";
      if (sound) {
         Gs_468 = Gs_468 + "The sound alarm system is included" 
         + "\n";
      }
      Comment(Gs_468);
      Gs_468 = "";
      Sleep(100);
   }
   return (0);
}

// 20868FA29DFC38AC154B8EF762766B41
string f0_2(string As_0, int Ai_8) {
   string Ls_ret_12;
   if (Ai_8 == -1) Ls_ret_12 = StringSubstr(As_0, 0, 2);
   else Ls_ret_12 = StringSubstr(As_0, 7 * Ai_8 + 3, 6);
   return (Ls_ret_12);
}

// 2D70DA379B3FFB56BD104B348BA21C55
double f0_3(string As_0, int Ai_8) {
   double str2dbl_12;
   int Li_20 = StringFind(As_0, "!", 0);
   if (Ai_8 == 0) str2dbl_12 = StrToDouble(StringSubstr(As_0, 0, Li_20));
   else str2dbl_12 = StrToDouble(StringSubstr(As_0, Li_20 + 1, 7));
   return (str2dbl_12);
}

// D6C5518C6CAE9538BCA7AB6F9F342D7D
int f0_11() {
   double Ld_0;
   double Ld_8;
   double Ld_16;
   int Li_24;
   if (LotsPercent > 0) {
      Ld_0 = NormalizeDouble(NormalizeDouble(AccountEquity() / G_marginrequired_544, 2) * LotsPercent / 100.0, 2);
      Ld_8 = Ld_0;
      Li_24 = Ld_8 / G_lotstep_552;
      Ld_16 = Li_24 * G_lotstep_552;
      Gd_336 = Ld_16;
      if (Gd_336 < Gd_560) Gd_336 = Gd_560;
      if (Gd_336 > Gd_568) Gd_336 = Gd_568;
      Lots = Gd_336;
   }
   if (Lots > max_lots) Lots = max_lots;
   return (0);
}

// 9A2D793774C5C8094678898A3EA3E26D
int f0_9() {
   double price_0;
   if (OrdersTotal() > 0) {
      for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
         OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY) {
            if (OrderMagicNumber() == G_magic_324) {
               price_0 = NormalizeDouble(OrderOpenPrice(), Gi_328) + TakeProfit * G_point_276;
               if (NormalizeDouble(OrderTakeProfit(), Gi_328) != price_0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_0, 0, Red);
            }
         }
      }
   }
   return (0);
}

// 8F84BBD29696AA3F0FECF7277445ADC1
int f0_8() {
   double price_0;
   if (OrdersTotal() > 0) {
      for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
         OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_SELL) {
            if (OrderMagicNumber() == G_magic_324) {
               price_0 = NormalizeDouble(OrderOpenPrice(), Gi_328) - TakeProfit * G_point_276;
               if (NormalizeDouble(OrderTakeProfit(), Gi_328) != price_0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_0, 0, Red);
            }
         }
      }
   }
   return (0);
}

// 1C5B70EF1C364E17D5B3030051898E78
int f0_0() {
   double price_0;
   if (OrdersTotal() > 0) {
      for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
         OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY) {
            if (OrderMagicNumber() == G_magic_324) {
               price_0 = NormalizeDouble(OrderOpenPrice(), Gi_328) - StopLoss * G_point_276;
               if (NormalizeDouble(OrderStopLoss(), Gi_328) != price_0) OrderModify(OrderTicket(), OrderOpenPrice(), price_0, OrderTakeProfit(), 0, Red);
            }
         }
      }
   }
   return (0);
}

// 57C2581CEB81ED5C608C590596561472
int f0_7() {
   double price_0;
   if (OrdersTotal() > 0) {
      for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
         OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_SELL) {
            if (OrderMagicNumber() == G_magic_324) {
               price_0 = NormalizeDouble(OrderOpenPrice(), Gi_328) + StopLoss * G_point_276;
               if (NormalizeDouble(OrderStopLoss(), Gi_328) != price_0) OrderModify(OrderTicket(), OrderOpenPrice(), price_0, OrderTakeProfit(), 0, Red);
            }
         }
      }
   }
   return (0);
}

// 5681F3288DB688D43C03CC73B75970A3
void f0_6() {
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == G_symbol_600 && OrderMagicNumber() == G_magic_324) {
            if (OrderType() == OP_BUY) {
               Gd_436 = MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice();
               Gd_452 = Gd_484 * G_point_276;
               Gd_452 = NormalizeDouble(Gd_452, Gi_328);
               if (Gd_436 >= Gd_452) {
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID) + luft * G_point_276, Slippage);
                  return;
               }
            }
            if (OrderType() == OP_SELL) {
               Gd_444 = OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_ASK);
               Gd_452 = Gd_484 * G_point_276;
               Gd_452 = NormalizeDouble(Gd_452, Gi_328);
               if (Gd_444 >= Gd_452) {
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK) - luft * G_point_276, Slippage);
                  return;
               }
            }
         }
      }
   }
}

// 30D5655D01E1EB80F4482A408F5C9EAB
void f0_4() {
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == G_symbol_600 && OrderMagicNumber() == G_magic_324) {
            if (OrderType() == OP_BUY) {
               Gd_436 = OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_BID);
               Gd_436 = NormalizeDouble(Gd_436, Gi_328);
               Gd_452 = FixSL * G_point_276;
               Gd_452 = NormalizeDouble(Gd_452, Gi_328);
               if (Gd_436 >= Gd_452) {
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID) + luft * G_point_276, Slippage);
                  return;
               }
            }
            if (OrderType() == OP_SELL) {
               Gd_444 = MarketInfo(OrderSymbol(), MODE_ASK) - OrderOpenPrice();
               Gd_444 = NormalizeDouble(Gd_444, Gi_328);
               Gd_452 = FixSL * G_point_276;
               Gd_452 = NormalizeDouble(Gd_452, Gi_328);
               if (Gd_444 >= Gd_452) {
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK) - luft * G_point_276, Slippage);
                  return;
               }
            }
         }
      }
   }
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectDelete("BidMT");
   ObjectDelete("BidGL");
   ObjectDelete("RMTGL");
   ObjectDelete("RMTGLsig");
   ObjectDelete("bid_saxo");
   ObjectDelete("bid_mt");
   ObjectDelete("bid label");
   ObjectDelete("ask label");
   ObjectDelete("ask_saxo");
   Comment("");
   return (0);
}

// D84642AAA21638432D6E6B83A0A8962A
int f0_12(int Ai_0) {
   G_symbol_600 = f0_2(Gs_584, Ai_0);
   string Ls_4 = G_symbol_600;
   if (Gi_632) Print("symb " + G_symbol_600);
   int Li_12 = StringFind(Symbol(), G_symbol_600, 0);
   if (Li_12 != 1) {
      if (Li_12 > 0) Gs_576 = StringSubstr(Symbol(), 0, Li_12 - 1);
      if (Li_12 == 0) {
         Li_12 += 6;
         if (Li_12 >= 6) Gs_576 = StringSubstr(Symbol(), Li_12, StringLen(Symbol()) - 1);
      }
   }
   G_symbol_600 = G_symbol_600 + Gs_576;
   RefreshRates();
   Gd_528 = MarketInfo(G_symbol_600, MODE_BID);
   G_ask_536 = MarketInfo(G_symbol_600, MODE_ASK);
   Gs_592 = Gs_592 + G_symbol_600 + " ";
   Gi_328 = MarketInfo(G_symbol_600, MODE_DIGITS);
   if (Gi_328 == 3) {
      Gi_328 = 2;
      Slippage = 10.0 * Slippage;
   }
   if (Gi_328 == 5) {
      Gi_328 = 4;
      Slippage = 10.0 * Slippage;
   }
   if (Gi_632) Print("symb " + G_symbol_600 + " dig=" + Gi_328);
   G_point_276 = MarketInfo(G_symbol_600, MODE_POINT);
   if (G_point_276 == 0.001) G_point_276 = 0.01;
   if (G_point_276 == 0.00001) G_point_276 = 0.0001;
   if (Gi_632) Print("symb " + G_symbol_600 + " pp=" + G_point_276);
   if (ruka && G_symbol_600 != Symbol()) {
      Gi_328 = 0;
      G_point_276 = 0;
      Gs_608 = Gs_608 + G_symbol_600 + " not present" 
      + "\n";
      return (0);
   }
   if (Gi_328 == 0 && G_point_276 == 0.0) {
      Gs_608 = Gs_608 + G_symbol_600 + " not present" 
      + "\n";
      return (0);
   }
   string Ls_16 = val_bid_ask(Ls_4);
   Gs_372 = f0_3(Ls_16, 0);
   if (Gi_632) Print("symb Valuta " + Gs_372);
   Gd_404 = StrToDouble(Gs_372) + sdvig_bid * G_point_276;
   Gd_404 = NormalizeDouble(Gd_404, MarketInfo(G_symbol_600, MODE_DIGITS));
   Gd_428 = Gd_404;
   Gs_388 = f0_3(Ls_16, 1);
   Gd_420 = StrToDouble(Gs_388) + sdvig_bid * G_point_276;
   Gd_420 = NormalizeDouble(Gd_420, MarketInfo(G_symbol_600, MODE_DIGITS));
   GlobalVariableSet(G_symbol_600 + "_bid", Gd_404);
   GlobalVariableSet(G_symbol_600 + "_ask", Gd_420);
   if (!new_kot) {
      Gd_316 = (NormalizeDouble(G_ask_536, MarketInfo(G_symbol_600, MODE_DIGITS)) - NormalizeDouble(Gd_528, MarketInfo(G_symbol_600, MODE_DIGITS))) / G_point_276;
      if (Fixspred > 0) Gd_316 = Fixspred;
      Gd_412 = (Gd_404 - NormalizeDouble(Gd_528, MarketInfo(G_symbol_600, MODE_DIGITS))) / G_point_276;
      Gd_224 = (Gd_420 - Gd_404) / G_point_276;
   }
   if (new_kot) {
      Gd_316 = 0;
      Gd_224 = 0;
      Gd_244 = Gd_404 + (Gd_420 - Gd_404) / 2.0;
      Gd_236 = Bid + (Ask - Bid) / 2.0;
      Gd_252 = (Gd_244 - Gd_236) / G_point_276;
      Gd_412 = Gd_252;
      Gd_528 = Gd_236;
      Gd_404 = Gd_244;
      Gd_420 = Gd_236;
   }
   f0_14();
   if (MathAbs(Gd_412) >= Gi_232) Gd_412 = 0;
   if (Gi_632) Print("symb spred_mt " + G_symbol_600 + " " + Gd_316);
   return (0);
}

// 20259362CCDF54B0904EA564E702C7E0
int f0_1() {
   Gd_308 = MinUr;
   if (spred_saxo) {
      if (Gd_224 > 4.0) {
         if (Gd_224 > Gd_316) Gd_308 = MinUr + (Gd_224 - Gd_316) / 2.0;
         if (2.0 * MathAbs(Gd_316) < MathAbs(Gd_224)) Gd_308 = MinUr + (Gd_224 - Gd_316);
      }
   }
   Gd_484 = FixTP;
   if (Gd_316 < MathAbs(Gd_412)) Gd_484 = TakeProfit;
   if (Gd_308 < MinUr) Gd_308 = MinUr;
   if (MathAbs(Gd_412) >= Gd_308 + Gd_316) {
      if (Gd_412 >= Gd_308) Gs_380 = "BUY " + DoubleToStr(G_ask_536, Gi_328);
      else Gs_380 = "SELL " + DoubleToStr(Gd_528, Gi_328);
      if (Gi_632) {
         Print("i=", Gd_412, " MinUr=", MinUr, " MinUrt=", Gd_308, "  Global=", Gd_404, "  Bid=", NormalizeDouble(Gd_528, Gi_328), "  Ask=", NormalizeDouble(G_ask_536, Gi_328),
            "  ", Gs_380, "  спред саксы=", Gd_224, "  спред мт=", Gd_316);
      }
      if (sound == TRUE && Gd_476 != iBars(G_symbol_600, PERIOD_M1)) Gd_476 = iBars(G_symbol_600, PERIOD_M1);
   }
   if (!new_kot) {
      Gs_608 = Gs_608 + G_symbol_600 + " bid=" + DoubleToStr(Gd_404, 5) + "(" + DoubleToStr(Gd_412, 1) + ") " + DoubleToStr(Gd_308 + Gd_316, 1) + " spred=" + DoubleToStr(Gd_224, 1) + "(" + DoubleToStr(Gd_316, 1) + ")" 
      + "\n";
   }
   if (new_kot) {
      Gs_608 = Gs_608 + G_symbol_600 + " bidGL=" + DoubleToStr(Gd_404, 5) + "(" + DoubleToStr(Gd_412, 1) + ") " + DoubleToStr(Gd_308 + Gd_316, 1) + " bidMT=" + DoubleToStr(Gd_528, 5) 
      + "\n";
   }
   return (0);
}

// DF6B9DB7C359D7510664659222237505
int f0_14() {
   double global_var_0 = GlobalVariableGet("proverka_bid_" + G_symbol_600);
   double global_var_8 = GlobalVariableGet("proverka_ask_" + G_symbol_600);
   double global_var_16 = GlobalVariableGet("proverka_tik_" + AccountNumber());
   if (Gd_404 == global_var_0 && Gd_420 == global_var_8) {
      if (GetTickCount() - global_var_16 > 1000 * Gi_220) {
         Gd_412 = 0;
         if (visual_pr_kotir) {
            Gs_468 = Gs_468 + G_symbol_600 + " Something with giving of quotations. Communication probably was gone in a current " + DoubleToStr((GetTickCount() - global_var_16) / 1000.0, 0) + " second" 
            + "\n";
         }
      }
   } else {
      GlobalVariableSet("proverka_bid_" + G_symbol_600, Gd_404);
      GlobalVariableSet("proverka_ask_" + G_symbol_600, Gd_420);
      GlobalVariableSet("proverka_tik_" + AccountNumber(), GetTickCount());
   }
   if (GetTickCount() - GlobalVariableGet("proverka_zapusk_") < 1000 * (Gi_220 * 2)) {
      Gd_412 = 0;
      Gs_468 = "=========================================================================================================" 
      + "\n";
      Gs_468 = Gs_468 + " Before script start remains " + DoubleToStr((1000 * (Gi_220 * 2) - (GetTickCount() - GlobalVariableGet("proverka_zapusk_"))) / 1000.0, 0) + " second" 
      + "\n";
      Gs_468 = Gs_468 + "=========================================================================================================" 
      + "\n";
   }
   return (0);
}

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   if (read_pr_nastr) {
      Print("We read options from the previous start");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_trade") == 1.0) trade = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "whc") == 1.0) whc = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "sound") == 1.0) sound = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "spred_saxo") == 1.0) spred_saxo = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "visual") == 1.0) visual = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "visual_bid") == 1.0) visual_bid = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "visual_pr_kotir") == 1.0) visual_pr_kotir = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "new_kot") == 1.0) new_kot = TRUE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_trade") == 2.0) trade = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "whc") == 2.0) whc = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "sound") == 2.0) sound = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "spred_saxo") == 2.0) spred_saxo = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "visual") == 2.0) visual = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "visual_bid") == 2.0) visual_bid = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "visual_pr_kotir") == 2.0) visual_pr_kotir = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "new_kot") == 2.0) new_kot = FALSE;
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_MinUr") != 0.0) MinUr = GlobalVariableGet("nastr_" + AccountNumber() + "_MinUr");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_Lots") != 0.0) Lots = GlobalVariableGet("nastr_" + AccountNumber() + "_Lots");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_LotsPercent") != 0.0) LotsPercent = GlobalVariableGet("nastr_" + AccountNumber() + "_LotsPercent");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_max_lots") != 0.0) max_lots = GlobalVariableGet("nastr_" + AccountNumber() + "_max_lots");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_TakeProfit") != 0.0) TakeProfit = GlobalVariableGet("nastr_" + AccountNumber() + "_TakeProfit");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "StopLoss") != 0.0) StopLoss = GlobalVariableGet("nastr_" + AccountNumber() + "_" + "StopLoss");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "FixTP") != 0.0) FixTP = GlobalVariableGet("nastr_" + AccountNumber() + "_" + "FixTP");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "FixSL") != 0.0) FixSL = GlobalVariableGet("nastr_" + AccountNumber() + "_" + "FixSL");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "sdvig_bid") != 0.0) sdvig_bid = GlobalVariableGet("nastr_" + AccountNumber() + "_" + "sdvig_bid");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "Fixspred") != 0.0) Fixspred = GlobalVariableGet("nastr_" + AccountNumber() + "_" + "Fixspred");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "NTrades") != 0.0) NTrades = GlobalVariableGet("nastr_" + AccountNumber() + "_" + "NTrades");
      if (GlobalVariableGet("nastr_" + AccountNumber() + "_" + "Slippage") != 0.0) Slippage = GlobalVariableGet("nastr_" + AccountNumber() + "_" + "Slippage");
   }
   Print("We write down the data on the future");
   if (trade) GlobalVariableSet("nastr_" + AccountNumber() + "_trade", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_trade", 2);
   if (whc) GlobalVariableSet("nastr_" + AccountNumber() + "_" + "whc", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_" + "whc", 2);
   if (sound) GlobalVariableSet("nastr_" + AccountNumber() + "_" + "sound", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_" + "sound", 2);
   if (spred_saxo) GlobalVariableSet("nastr_" + AccountNumber() + "_" + "spred_saxo", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_" + "spred_saxo", 2);
   if (visual) GlobalVariableSet("nastr_" + AccountNumber() + "_" + "visual", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_" + "visual", 2);
   if (visual_bid) GlobalVariableSet("nastr_" + AccountNumber() + "_" + "visual_bid", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_" + "visual_bid", 2);
   if (visual_pr_kotir) GlobalVariableSet("nastr_" + AccountNumber() + "_" + "visual_pr_kotir", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_" + "visual_pr_kotir", 2);
   if (new_kot) GlobalVariableSet("nastr_" + AccountNumber() + "_" + "new_kot", 1);
   else GlobalVariableSet("nastr_" + AccountNumber() + "_" + "new_kot", 2);
   GlobalVariableSet("nastr_" + AccountNumber() + "_MinUr", MinUr);
   GlobalVariableSet("nastr_" + AccountNumber() + "_Lots", Lots);
   GlobalVariableSet("nastr_" + AccountNumber() + "_LotsPercent", LotsPercent);
   GlobalVariableSet("nastr_" + AccountNumber() + "_max_lots", max_lots);
   GlobalVariableSet("nastr_" + AccountNumber() + "_TakeProfit", TakeProfit);
   GlobalVariableSet("nastr_" + AccountNumber() + "_" + "StopLoss", StopLoss);
   GlobalVariableSet("nastr_" + AccountNumber() + "_" + "FixTP", FixTP);
   GlobalVariableSet("nastr_" + AccountNumber() + "_" + "FixSL", FixSL);
   GlobalVariableSet("nastr_" + AccountNumber() + "_" + "sdvig_bid", sdvig_bid);
   GlobalVariableSet("nastr_" + AccountNumber() + "_" + "Fixspred", Fixspred);
   GlobalVariableSet("nastr_" + AccountNumber() + "_" + "NTrades", NTrades);
   GlobalVariableSet("nastr_" + AccountNumber() + "_" + "Slippage", Slippage);
   Gs_468 = "";
   GlobalVariableSet("proverka_zapusk_", GetTickCount());
   Gi_260 = GetTickCount();
   double price_0 = NormalizeDouble(Bid, 2) - 0.02;
   if (mt_setka_vykl) {
      Gi_492 = WindowHandle(Symbol(), Period());
      PostMessageA(Gi_492, WM_COMMAND, 33021, 0);
   }
   if (setka) {
      for (int count_8 = 0; count_8 < 20; count_8++) {
         ObjectCreate("asd_" + price_0 + "_b", OBJ_HLINE, 0, TimeCurrent(), price_0);
         ObjectSet("asd_" + price_0 + "_b", OBJPROP_COLOR, LightSlateGray);
         ObjectSet("asd_" + price_0 + "_b", OBJPROP_STYLE, STYLE_DOT);
         ObjectSet("asd_" + price_0 + "_b", OBJPROP_WIDTH, 1);
         price_0 += 0.002;
      }
   }
   Gs_212 = "none";
   return (0);
}

// B3C05E0BF138E2BE42A8F82E264C81C1
int f0_10() {
   int Li_0;
   int Li_4;
   int Li_8;
   int Li_unused_12;
   int Li_16;
   int Li_20;
   int Li_24;
   int Li_28 = 3000;
   Gi_508 = FindWindowA("#32770", "Ордер");
   if (Gi_508 != 0) {
      Gi_512 = GetWindow(Gi_508, 5);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_512 = GetWindow(Gi_512, 5);
      Gi_504 = Gi_512;
      Gi_512 = GetWindow(Gi_512, 2);
      Gi_500 = Gi_512;
      Gi_508 = GetDlgItem(Gi_508, 1384);
      Gi_508 = GetDlgItem(Gi_508, 1001);
      SetWindowTextA(Gi_508, DoubleToStr(Lots, Dig));
      if (Gd_252 > 0.0) SendMessageA(Gi_500, 245, 0, 0);
      if (Gd_252 < 0.0) SendMessageA(Gi_504, 245, 0, 0);
   } else {
      Gi_492 = WindowHandle(Symbol(), Period());
      Li_4 = GetAncestor(Gi_492, 2);
      PostMessageA(Gi_492, WM_COMMAND, 35458, 0);
      Gi_508 = 0;
      Li_0 = GetTickCount();
      while (Gi_508 == 0) {
         Gi_508 = FindWindowA("#32770", "Ордер");
         if (GetTickCount() - Li_0 > Li_28) return (0);
      }
      Li_8 = GetWindow(Gi_508, 5);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_8 = GetWindow(Li_8, 2);
      Li_unused_12 = 0;
      Li_16 = Li_8;
      Li_8 = 0;
      while (Li_8 == 0) {
         Li_8 = GetWindow(Li_16, 2);
         Li_8 = GetWindow(Li_8, 5);
         if (GetTickCount() - Li_0 > Li_28) return (0);
      }
      Li_20 = Li_8;
      Li_16 = Li_8;
      Li_8 = 0;
      while (Li_8 == 0) {
         Li_8 = GetWindow(Li_16, 2);
         if (GetTickCount() - Li_0 > Li_28) return (0);
      }
      Li_24 = Li_8;
      SendMessageA(Li_24, 245, 0, 0);
      Gi_508 = GetDlgItem(Gi_508, 1384);
      Gi_508 = GetDlgItem(Gi_508, 1001);
      SetWindowTextA(Gi_508, DoubleToStr(0.1, 1));
      if (Gd_252 > 0.0) SendMessageA(Li_24, 245, 0, 0);
      if (Gd_252 < 0.0) SendMessageA(Li_20, 245, 0, 0);
   }
   return (0);
}

// 3ACA4AEDC82351568345A79B39A76820
int f0_5() {
   string Ls_unused_0;
   if (ObjectFind("bid_saxo") == -1) {
      ObjectCreate("bid_saxo", OBJ_HLINE, 0, TimeCurrent(), Gd_404);
      ObjectSet("bid_saxo", OBJPROP_COLOR, Yellow);
      ObjectSet("bid_saxo", OBJPROP_STYLE, STYLE_SOLID);
   }
   ObjectMove("bid_saxo", 0, TimeCurrent(), Gd_404);
   if (visual_bid)
      if (ObjectFind("bid label") == -1) ObjectCreate("bid label", OBJ_TEXT, 0, Time[0], Low[0] - 10.0 * G_point_276);
   if (Gd_412 >= 0.0) ObjectSetText("bid label", DoubleToStr(Gd_412, 1), G_fontsize_304, "Arial", Lime);
   else ObjectSetText("bid label", DoubleToStr(Gd_412, 1), G_fontsize_304, "Arial", Red);
   ObjectMove("bid label", 0, Time[0], Low[0] - 10.0 * G_point_276);
   if (ObjectFind("ask label") == -1) ObjectCreate("ask label", OBJ_TEXT, 0, Time[0], High[0] + 10.0 * G_point_276);
   ObjectSetText("ask label", DoubleToStr((Ask - Bid) / G_point_276, 1), 8, "Arial", Red);
   ObjectMove("ask label", 0, Time[0], High[0] + 10.0 * G_point_276);
   if (ObjectFind("RMTGL") == -1) {
      ObjectCreate("RMTGL", OBJ_LABEL, 0, 0, 0);
      ObjectSet("RMTGL", OBJPROP_CORNER, 1);
      ObjectSet("RMTGL", OBJPROP_XDISTANCE, 15);
      ObjectSet("RMTGL", OBJPROP_YDISTANCE, 0);
   }
   ObjectSetText("RMTGL", DoubleToStr(Gd_412, 1), G_fontsize_300, "Arial Black", G_color_264);
   if (ObjectFind("ask_saxo") == -1) {
      ObjectCreate("ask_saxo", OBJ_HLINE, 0, TimeCurrent(), Gd_420);
      ObjectSet("ask_saxo", OBJPROP_COLOR, Red);
      ObjectSet("ask_saxo", OBJPROP_STYLE, STYLE_SOLID);
   }
   ObjectMove("ask_saxo", 0, TimeCurrent(), Gd_420);
   WindowRedraw();
   return (0);
}

// D9394066970E44AE252FD0347E58C03E
int f0_13() {
   G_marginrequired_544 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   G_lotstep_552 = MarketInfo(Symbol(), MODE_LOTSTEP);
   Gd_560 = MarketInfo(Symbol(), MODE_MINLOT);
   Gd_568 = MarketInfo(Symbol(), MODE_MAXLOT);
   if (G_marginrequired_544 == 0.0) {
      G_marginrequired_544 = 1000;
      Print("MODE_MARGINREQUIRED error");
   }
   if (G_lotstep_552 == 0.0) {
      G_lotstep_552 = 0.1;
      Print("MODE_LOTSTEP error");
   }
   if (Gd_560 == 0.0) {
      Gd_560 = 0.1;
      Print("MODE_MINLOT error");
   }
   if (Gd_568 == 0.0) {
      Gd_568 = 1000;
      Print("MODE_MAXLOT error");
   }
   return (0);
}
