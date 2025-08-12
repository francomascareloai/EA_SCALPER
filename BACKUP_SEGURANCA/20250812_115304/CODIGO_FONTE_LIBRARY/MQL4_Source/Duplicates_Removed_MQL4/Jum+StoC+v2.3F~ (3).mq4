/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  hTT P:/ /Ww w . me T aqUoT e s .n E T
   E-mail : S u PporT @M ETaQu o Te s.n e t
*/
#property copyright "Jum69"
#property link      "Gifaesa@yahoo.com"

extern string Seting_Parameter = "=>Parameter Pro+v2.3<<";
extern string Khusus_Closing = "=>Gunakan sesuai Kebutuhan<<";
extern bool Close_Panic = FALSE;
extern bool Close_Buy_Trend = FALSE;
extern bool Close_Sell_Trend = FALSE;
extern bool Close_Buy_Counter = FALSE;
extern bool Close_Sell_Counter = FALSE;
extern string Seting_Risk_Target = "=>Gunakan sesuai Kebutuhan<<";
extern bool Risk_In_Money = FALSE;
extern double Risk_in_money = 1000.0;
extern double Target_Persen = 1000.0;
extern string Seting_Mode_Trend = "=>Seting Trade trend<<";
extern int StartHour = 0;
extern int StopHour = 24;
extern bool Buy_Trend = TRUE;
extern bool Sell_Trend = TRUE;
extern string Seting_Mode_Conter = "=>Seting Trade Counter Trend<<";
extern int Start_Hour = 0;
extern int Stop_Hour = 24;
extern bool Buy_Counter = TRUE;
extern bool Sell_Counter = TRUE;
extern string Gap_ = "==>Gap_Factor= jarak pip gap order ";
extern bool Close_All_Gap = TRUE;
extern double Gap_Factor = 38.0;
extern string Seting_MM = "=>Seting sesuai selera<<";
extern string Lot_info = "Lot Mode = 1 -> Compound; Mode = 2 -> Fix Lot)";
extern int Lot_mode = 2;
extern string Lot_info2 = "Rumus Compound = Balance/Manage_Lot";
extern double Manage_Lot = 10000.0;
extern double Fix_lot = 0.01;
extern int Magic = 69;
extern double Range = 21.0;
extern int Level_Max = 12;
extern int Star_ModifTp = 4;
extern double DiMarti = 1.7;
extern double SL = 253.0;
extern double TP = 30.0;
extern bool Tp_In_money = FALSE;
extern double Tp_in_money = 7.0;
extern bool Dtrailing = FALSE;
extern int Trailing = 5;
extern string Indi_Seting = "==>Stockhastik trend & MA Seting<<=";
extern int kperiod = 10;
extern int dperiod = 3;
extern int slowing = 3;
extern int lo_level = 25;
extern int up_level = 75;
extern int maPereode = 25;
extern string Indi_Stoch_2 = "==>Stockhastik counter trend<<=";
extern int k_period = 32;
extern int d_period = 12;
extern int s_lowing = 12;
extern int lolevel = 30;
extern int uplevel = 70;
double Gd_376;
double Gd_384;
double G_stoplevel_392;
double G_lots_400;
int Gi_408 = 0;
int Gi_412 = 0;
int G_ticket_416 = 0;
string Gs_420 = "+Jum+StoCh-1+";
string Gs_428 = "+Jum+StoCh-2+";
string Gs_436 = "+Jum+StoCh-3+";
string Gs_444 = "+Jum+StoCh-4+";
string Gs_dummy_452;
string Gs_dummy_460;
string Gs_dummy_468;
string Gs_dummy_476;
double Gd_484;
string Gsa_492[10];
int Gi_496;
int Gi_500;
int Gi_504;
int Gi_508;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gd_484 = AccountBalance();
   if (Digits == 3 || Digits == 5) Gd_376 = 10.0 * Point;
   else Gd_376 = Point;
   Gd_384 = MarketInfo(Symbol(), MODE_MINLOT);
   G_stoplevel_392 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (G_lots_400 < Gd_384) Print("lotsize is to small.");
   if (SL < G_stoplevel_392) Print("stoploss is to tight.");
   if (TP < G_stoplevel_392) Print("takeprofit is to tight.");
   if (Gd_384 == 0.01) Gi_408 = 2;
   if (Gd_384 == 0.1) Gi_408 = 1;
   Gi_496 = Magic + 9;
   Gi_500 = Magic + 99;
   Gi_504 = Magic + 999;
   Gi_508 = Magic + 9999;
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectDelete("ObjLabel1");
   ObjectDelete("ObjLabel2");
   ObjectDelete("ObjLabel3");
   ObjectDelete("ObjLabel4");
   ObjectDelete("ObjLabel5");
   ObjectDelete("ObjLabel6");
   ObjectDelete("ObjLabel7");
   ObjectDelete("ObjLabel8");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   f0_18();
   f0_35();
   double Ld_0 = Gd_484 * Target_Persen / 100.0;
   if (AccountEquity() >= Gd_484 + Ld_0) {
      f0_54();
      f0_15();
      f0_37();
      f0_22();
      return;
   }
   if (Close_Panic) {
      f0_54();
      f0_15();
      f0_37();
      f0_22();
   }
   if (Close_Buy_Trend) f0_54();
   if (Close_Sell_Trend) f0_15();
   if (Close_Buy_Counter) f0_37();
   if (Close_Sell_Counter) f0_22();
   if (Lot_mode == 1) G_lots_400 = NormalizeDouble(AccountBalance() / Manage_Lot, 2);
   if (Lot_mode == 2) G_lots_400 = Fix_lot;
   if (Lot_mode < 1 || Lot_mode > 2) return (0);
   if (G_lots_400 < Gd_384) G_lots_400 = Gd_384;
   if (!Close_Panic) {
      f0_49();
      f0_31();
      f0_11();
      f0_26();
      f0_1(Gi_496, Gs_420);
      f0_1(Gi_500, Gs_428);
      f0_1(Gi_504, Gs_436);
      f0_1(Gi_508, Gs_444);
   }
   f0_7();
   f0_4();
   f0_33();
   f0_39();
   if (Dtrailing) f0_2();
   if (Dtrailing) f0_0();
   if (Dtrailing) f0_9();
   if (Dtrailing) f0_52();
   if (Tp_In_money && f0_36(Magic + 9) + f0_36(Magic + 99) + f0_36(Magic + 999) + f0_36(Magic + 9999) >= Tp_in_money) {
      f0_54();
      f0_15();
      f0_37();
      f0_22();
   }
   if (Risk_In_Money && f0_36(Magic + 9) + f0_36(Magic + 99) + f0_36(Magic + 999) + f0_36(Magic + 9999) <= (-1.0 * Risk_in_money)) {
      f0_54();
      f0_15();
      f0_37();
      f0_22();
   }
   double ima_8 = iMA(Symbol(), 0, maPereode, 0, MODE_LWMA, PRICE_CLOSE, 0);
   double istochastic_16 = iStochastic(NULL, 0, kperiod, dperiod, slowing, MODE_SMA, 0, MODE_MAIN, 0);
   if (f0_3() == 1 && (!Close_Panic)) {
      if ((!Close_Buy_Trend) && Buy_Trend && f0_51() == 0 && Close[1] > ima_8 && istochastic_16 < up_level) G_ticket_416 = OrderSend(Symbol(), OP_BUY, G_lots_400, Ask, 3, Ask - SL * Gd_376, Ask + TP * Gd_376, "+Jum+StoCh-1+" + f0_51(), Magic + 9, 0, White);
      if ((!Close_Sell_Trend) && Sell_Trend && f0_27() == 0 && Close[1] < ima_8 && istochastic_16 > lo_level) G_ticket_416 = OrderSend(Symbol(), OP_SELL, G_lots_400, Bid, 3, Bid + SL * Gd_376, Bid - TP * Gd_376, "+Jum+StoCh-2+" + f0_27(), Magic + 99, 0, Aqua);
   }
   if (Gi_412 == 0 && (!Close_Panic)) {
      if ((!Close_Buy_Counter) && Buy_Counter && f0_46() == 0 && f0_17() == -2) G_ticket_416 = OrderSend(Symbol(), OP_BUY, G_lots_400, Ask, 3, Ask - SL * Gd_376, Ask + TP * Gd_376, "+Jum+StoCh-3+" + f0_46(), Magic + 999, 0, Blue);
      if ((!Close_Sell_Counter) && Sell_Counter && f0_10() == 0 && f0_17() == 2) G_ticket_416 = OrderSend(Symbol(), OP_SELL, G_lots_400, Bid, 3, Bid + SL * Gd_376, Bid - TP * Gd_376, "+Jum+StoCh-4+" + f0_10(), Magic + 9999, 0, Red);
   }
   if (f0_51() == 1 && f0_41(OP_BUYLIMIT) == 1) f0_54();
   if (f0_27() == 1 && f0_14(OP_SELLLIMIT) == 1) f0_15();
   if (f0_46() == 1 && f0_40(OP_BUYLIMIT) == 1) f0_37();
   if (f0_10() == 1 && f0_34(OP_SELLLIMIT) == 1) f0_22();
   if (f0_41(OP_BUYLIMIT) > 1) f0_6();
   if (f0_14(OP_SELLLIMIT) > 1) f0_23();
   if (f0_40(OP_BUYLIMIT) > 1) f0_44();
   if (f0_34(OP_SELLLIMIT) > 1) f0_24();
   double Ld_24 = f0_19() - f0_43() - MarketInfo(Symbol(), MODE_SPREAD) * Gd_376;
   if (Ld_24 > 0.0 && Ld_24 > Range * Gd_376) f0_6();
   double Ld_32 = f0_45() - f0_13() - MarketInfo(Symbol(), MODE_SPREAD) * Gd_376;
   if (Ld_32 > 0.0 && Ld_32 > Range * Gd_376) f0_23();
   double Ld_40 = f0_21() - f0_38() - MarketInfo(Symbol(), MODE_SPREAD) * Gd_376;
   if (Ld_40 > 0.0 && Ld_40 > Range * Gd_376) f0_44();
   double Ld_48 = f0_5() - f0_25() - MarketInfo(Symbol(), MODE_SPREAD) * Gd_376;
   if (Ld_48 > 0.0 && Ld_48 > Range * Gd_376) f0_24();
   double Ld_56 = MarketInfo(Symbol(), MODE_SPREAD) * Gd_376;
   if (Close_All_Gap && f0_51() != Level_Max && f0_51() == f0_41(OP_BUY) && f0_41(OP_BUYLIMIT) == 0 && Bid < f0_55() - (Ld_56 * Gd_376 + Gap_Factor * Gd_376)) f0_54();
   if (Close_All_Gap && f0_27() != Level_Max && f0_27() == f0_14(OP_SELL) && f0_14(OP_SELLLIMIT) == 0 && Ask > f0_30() + Ld_56 * Gd_376 + Gap_Factor * Gd_376) f0_15();
   if (Close_All_Gap && f0_46() != Level_Max && f0_46() == f0_40(OP_BUY) && f0_40(OP_BUYLIMIT) == 0 && Bid < f0_48() - (Ld_56 * Gd_376 + Gap_Factor * Gd_376)) f0_37();
   if (Close_All_Gap && f0_10() != Level_Max && f0_10() == f0_34(OP_SELL) && f0_34(OP_SELLLIMIT) == 0 && Ask > f0_8() + Ld_56 * Gd_376 + Gap_Factor * Gd_376) f0_22();
   if (f0_41(OP_BUY) >= 1 && f0_41(OP_BUYLIMIT) > 1) f0_6();
   if (f0_14(OP_SELL) >= 1 && f0_14(OP_SELLLIMIT) > 1) f0_23();
   if (f0_40(OP_BUY) >= 1 && f0_40(OP_BUYLIMIT) > 1) f0_44();
   if (f0_34(OP_SELL) >= 1 && f0_34(OP_SELLLIMIT) > 1) f0_24();
   if (f0_41(OP_BUY) >= 1 && f0_16(OP_BUYLIMIT) > NormalizeDouble(f0_16(OP_BUY) * DiMarti, Gi_408)) f0_6();
   if (f0_14(OP_SELL) >= 1 && f0_53(OP_SELLLIMIT) > NormalizeDouble(f0_53(OP_SELL) * DiMarti, Gi_408)) f0_23();
   if (f0_40(OP_BUY) >= 1 && f0_12(OP_BUYLIMIT) > NormalizeDouble(f0_12(OP_BUY) * DiMarti, Gi_408)) f0_44();
   if (f0_34(OP_SELL) >= 0 && f0_29(OP_SELLLIMIT) > NormalizeDouble(f0_29(OP_SELL) * DiMarti, Gi_408)) f0_24();
   return (0);
}

// 521345A9FB579F52117F27BE6E0673EE
int f0_17() {
   double ima_0 = iMA(Symbol(), 0, maPereode, 0, MODE_LWMA, PRICE_CLOSE, 0);
   double istochastic_8 = iStochastic(NULL, 0, k_period, d_period, s_lowing, MODE_SMA, 0, MODE_MAIN, 0);
   if (f0_32() == 1) {
      if (istochastic_8 > uplevel) return (2);
      if (istochastic_8 < lolevel) return (-2);
   }
   return (0);
}

// B20F59B3985C5F3854AB7E260249C6B0
double f0_36(int A_magic_0) {
   double Ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
      if (A_magic_0 == OrderMagicNumber()) Ld_ret_4 += OrderProfit();
   }
   return (Ld_ret_4);
}

// F699DC4087AF27504C95C2D408DA3A73
void f0_54() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      else {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
         else OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
      }
   }
}

// 4E971D1710FFA8E9A6D8A542DD088841
void f0_15() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      else {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
         else OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
      }
   }
}

// B7FED70D5E6ADC15F0AD0B7BADAC33CA
void f0_37() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      else {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
         else OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
      }
   }
}

// 5C749C4EDFD32AACFBCC1C02388A01E4
void f0_22() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      else {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
         else OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
      }
   }
}

// E66E87DBCE562B74124B777813014A3E
void f0_49() {
   int cmd_0;
   double order_open_price_4;
   double order_lots_12;
   double price_24;
   double Ld_32;
   if (f0_51() > 0 && f0_51() < Level_Max) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
         cmd_0 = OrderType();
         order_open_price_4 = OrderOpenPrice();
         order_lots_12 = OrderLots();
      }
      price_24 = order_open_price_4 - Range * Gd_376;
      Ld_32 = order_open_price_4 + Range * Gd_376;
      if (cmd_0 == OP_BUY && f0_41(OP_BUYLIMIT) == 0) {
         G_ticket_416 = OrderSend(Symbol(), OP_BUYLIMIT, NormalizeDouble(order_lots_12 * DiMarti, Gi_408), price_24, 3, price_24 - SL * Gd_376, price_24 + TP * Gd_376, "+Jum+StoCh-1+" +
            f0_51(), Magic + 9, 0, White);
      }
   }
}

// 8A8A445AE39AC5DD0D079725D7570BB2
void f0_31() {
   int cmd_0;
   double order_open_price_4;
   double order_lots_12;
   double Ld_24;
   double price_32;
   if (f0_27() > 0 && f0_27() < Level_Max) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
         cmd_0 = OrderType();
         order_open_price_4 = OrderOpenPrice();
         order_lots_12 = OrderLots();
      }
      Ld_24 = order_open_price_4 - Range * Gd_376;
      price_32 = order_open_price_4 + Range * Gd_376;
      if (cmd_0 == OP_SELL && f0_14(OP_SELLLIMIT) == 0) {
         G_ticket_416 = OrderSend(Symbol(), OP_SELLLIMIT, NormalizeDouble(order_lots_12 * DiMarti, Gi_408), price_32, 3, price_32 + SL * Gd_376, price_32 - TP * Gd_376, "+Jum+StoCh-2+" +
            f0_27(), Magic + 99, 0, Aqua);
      }
   }
}

// 38A0529D45DB7F1993A837150A5746E1
void f0_11() {
   int cmd_0;
   double order_open_price_4;
   double order_lots_12;
   double price_24;
   double Ld_32;
   if (f0_46() > 0 && f0_46() < Level_Max) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
         cmd_0 = OrderType();
         order_open_price_4 = OrderOpenPrice();
         order_lots_12 = OrderLots();
      }
      price_24 = order_open_price_4 - Range * Gd_376;
      Ld_32 = order_open_price_4 + Range * Gd_376;
      if (cmd_0 == OP_BUY && f0_40(OP_BUYLIMIT) == 0) {
         G_ticket_416 = OrderSend(Symbol(), OP_BUYLIMIT, NormalizeDouble(order_lots_12 * DiMarti, Gi_408), price_24, 3, price_24 - SL * Gd_376, price_24 + TP * Gd_376, "+Jum+StoCh-3+" +
            f0_46(), Magic + 999, 0, Blue);
      }
   }
}

// 75BAAE806815EDAFE9F9DB9F995C88F9
void f0_26() {
   int cmd_0;
   double order_open_price_4;
   double order_lots_12;
   double Ld_24;
   double price_32;
   if (f0_10() > 0 && f0_10() < Level_Max) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
         cmd_0 = OrderType();
         order_open_price_4 = OrderOpenPrice();
         order_lots_12 = OrderLots();
      }
      Ld_24 = order_open_price_4 - Range * Gd_376;
      price_32 = order_open_price_4 + Range * Gd_376;
      if (cmd_0 == OP_SELL && f0_34(OP_SELLLIMIT) == 0) {
         G_ticket_416 = OrderSend(Symbol(), OP_SELLLIMIT, NormalizeDouble(order_lots_12 * DiMarti, Gi_408), price_32, 3, price_32 + SL * Gd_376, price_32 - TP * Gd_376, "+Jum+StoCh-4+" +
            f0_10(), Magic + 9999, 0, Red);
      }
   }
}

// 31170B8EDC7877BFE7CA270815F9DDE1
void f0_7() {
   int cmd_0;
   double order_stoploss_4;
   double order_takeprofit_12;
   if (f0_41(OP_BUY) >= Star_ModifTp) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9 || OrderType() > OP_SELL) continue;
         cmd_0 = OrderType();
         order_stoploss_4 = OrderStopLoss();
         order_takeprofit_12 = OrderTakeProfit();
      }
      for (pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9 || OrderType() > OP_SELL) continue;
         if (OrderType() == cmd_0)
            if (OrderTakeProfit() != order_takeprofit_12) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), order_takeprofit_12, 0, CLR_NONE);
      }
   }
}

// 23BB1372F55F29677EA3450043F0BEE3
void f0_4() {
   int cmd_0;
   double order_stoploss_4;
   double order_takeprofit_12;
   if (f0_14(OP_SELL) >= Star_ModifTp) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99 || OrderType() > OP_SELL) continue;
         cmd_0 = OrderType();
         order_stoploss_4 = OrderStopLoss();
         order_takeprofit_12 = OrderTakeProfit();
      }
      for (pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99 || OrderType() > OP_SELL) continue;
         if (OrderType() == cmd_0)
            if (OrderTakeProfit() != order_takeprofit_12) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), order_takeprofit_12, 0, CLR_NONE);
      }
   }
}

// 9F7AB904DDBD5C72EFC7947CBC1F20AF
void f0_33() {
   int cmd_0;
   double order_stoploss_4;
   double order_takeprofit_12;
   if (f0_40(OP_BUY) >= Star_ModifTp) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999 || OrderType() > OP_SELL) continue;
         cmd_0 = OrderType();
         order_stoploss_4 = OrderStopLoss();
         order_takeprofit_12 = OrderTakeProfit();
      }
      for (pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999 || OrderType() > OP_SELL) continue;
         if (OrderType() == cmd_0)
            if (OrderTakeProfit() != order_takeprofit_12) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), order_takeprofit_12, 0, CLR_NONE);
      }
   }
}

// C917851C8449D7F3AB456E888C317273
void f0_39() {
   int cmd_0;
   double order_stoploss_4;
   double order_takeprofit_12;
   if (f0_34(OP_SELL) >= Star_ModifTp) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999 || OrderType() > OP_SELL) continue;
         cmd_0 = OrderType();
         order_stoploss_4 = OrderStopLoss();
         order_takeprofit_12 = OrderTakeProfit();
      }
      for (pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999 || OrderType() > OP_SELL) continue;
         if (OrderType() == cmd_0)
            if (OrderTakeProfit() != order_takeprofit_12) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), order_takeprofit_12, 0, CLR_NONE);
      }
   }
}

// E88281D5AF2DD03563421CE99F68112E
int f0_51() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      count_0++;
   }
   return (count_0);
}

// C9DFBEFD96A6547DFC46138E677118A3
int f0_41(int A_cmd_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      if (A_cmd_0 == OrderType()) count_4++;
   }
   return (count_4);
}

// 789C277C084CF68D143D621C709AB1A5
int f0_27() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      count_0++;
   }
   return (count_0);
}

// 4E8949BEFCC2B020D87CF8F0091423FF
int f0_14(int A_cmd_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      if (A_cmd_0 == OrderType()) count_4++;
   }
   return (count_4);
}

// DC7418592FF94F859519E973AF80D5C4
int f0_46() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      count_0++;
   }
   return (count_0);
}

// C930A15162B29F0216E7DD7951A38FEC
int f0_40(int A_cmd_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      if (A_cmd_0 == OrderType()) count_4++;
   }
   return (count_4);
}

// 3798C89B783C6FB5A2149C473063471D
int f0_10() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      count_0++;
   }
   return (count_0);
}

// A916837D43789E46D921827FE311A180
int f0_34(int A_cmd_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      if (A_cmd_0 == OrderType()) count_4++;
   }
   return (count_4);
}

// 212452DE8DD4E3765FBFA3DF557BA7EC
int f0_3() {
   bool Li_ret_0 = FALSE;
   if (StartHour > StopHour) {
      if (TimeHour(TimeCurrent()) >= StartHour || TimeHour(TimeCurrent()) < StopHour) Li_ret_0 = TRUE;
   } else
      if (TimeHour(TimeCurrent()) >= StartHour && TimeHour(TimeCurrent()) < StopHour) Li_ret_0 = TRUE;
   return (Li_ret_0);
}

// 98B03CD06244C904E7BE6CEDC0959B37
int f0_32() {
   bool Li_ret_0 = FALSE;
   if (Start_Hour > Stop_Hour) {
      if (TimeHour(TimeCurrent()) >= Start_Hour || TimeHour(TimeCurrent()) < Stop_Hour) Li_ret_0 = TRUE;
   } else
      if (TimeHour(TimeCurrent()) >= Start_Hour && TimeHour(TimeCurrent()) < Stop_Hour) Li_ret_0 = TRUE;
   return (Li_ret_0);
}

// 551B723EAFD6A31D444FCB2F5920FBD3
void f0_18() {
   if (Lot_mode == 1) G_lots_400 = NormalizeDouble(AccountBalance() / Manage_Lot, 2);
   if (Lot_mode == 2) G_lots_400 = Fix_lot;
   Comment(" ---------------------------------------------", 
      "\n :: ===>Jum+StoCh+v2.3F+<===", 
      "\n :: Free Share, Not Sell", 
      "\n :: Spread                 : ", MarketInfo(Symbol(), MODE_SPREAD), 
      "\n :: Leverage               : 1 : ", AccountLeverage(), 
      "\n :: Equity                 : ", AccountEquity(), 
      "\n :: Jam Server             :", Hour(), ":", Minute(), 
      "\n ------------------------------------------------", 
      "\n :: Trend", 
      "\n :: StartHour              :", StartHour, 
      "\n :: StopHour               :", StopHour, 
      "\n ------------------------------------------------", 
      "\n :: Counter Trend", 
      "\n :: StartHour              :", Start_Hour, 
      "\n :: StopHour               :", Stop_Hour, 
      "\n ------------------------------------------------", 
      "\n :: DiMarti                :", DiMarti, 
      "\n :: LevelMax               :", Level_Max, 
      "\n :: Range                  :", Range, 
      "\n ------------------------------------------------", 
      "\n :: Star_ModifTpSL         :", Star_ModifTp, 
      "\n :: Lot                    :", G_lots_400, 
      "\n :: SL                     :", SL, 
      "\n :: TP                     :", TP, 
      "\n :: Tp_in_money            :", Tp_in_money, 
      "\n ------------------------------------------------", 
      "\n :: ==>HAPPY TRADING<==", 
      "\n ------------------------------------------------", 
      "\n :: >>By@Jum69<<", 
   "\n ------------------------------------------------");
}

// 2F3F303748BEC86E1038658A8B81FD2E
void f0_6() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
   }
}

// 60F23CBAB2D4657E181DAFC57D4C092A
void f0_23() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
   }
}

// D2208D1B3A5BDD053470333DE3AB22DF
void f0_44() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
   }
}

// 66DDA547B358DD6437BFFF7A34A4749F
void f0_24() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
   }
}

// 57C0C41A85CF4268F06840A0E2DAF9CB
double f0_19() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUY) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELL) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// D12530EE0F4144E208F9892550AC4414
double f0_43() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUYLIMIT) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELLLIMIT) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// 48A35FED401ACCAA0B5DCB548C029968
double f0_13() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUY) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELL) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// D93C3B0C86BA42344A73959FEF6459D0
double f0_45() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUYLIMIT) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELLLIMIT) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// 5B4F617F383D053F57E8893A8483678D
double f0_21() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUY) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELL) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// B9C5BA540566A9510AAE4C559753F3F1
double f0_38() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUYLIMIT) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELLLIMIT) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// 6EF95D982F0075719FADD76B90C98CFC
double f0_25() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUY) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELL) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// 26DCA5A1D5936BC01D2DAD1EB98845A1
double f0_5() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      cmd_0 = OrderType();
      if (cmd_0 == OP_BUYLIMIT) order_open_price_4 = OrderOpenPrice();
      if (cmd_0 == OP_SELLLIMIT) order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// FA4E1B640C4C23952D1685A64B1A8234
double f0_55() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      cmd_0 = OrderType();
      order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// 8465A63DC24987BD0A4963F9C4008A9F
double f0_30() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      cmd_0 = OrderType();
      order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// DD9DEA8A61E25E00946C456603359D6E
double f0_48() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      cmd_0 = OrderType();
      order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// 3266FCBA2F7EA23DF456BA652099FA0A
double f0_8() {
   int cmd_0;
   double order_open_price_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      cmd_0 = OrderType();
      order_open_price_4 = OrderOpenPrice();
   }
   return (order_open_price_4);
}

// 50D37C5590CD3060C345DC5C886F144A
double f0_16(int A_cmd_0) {
   double order_lots_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
      A_cmd_0 = OrderType();
      if (A_cmd_0 == OP_BUY) order_lots_4 = OrderLots();
      if (A_cmd_0 == OP_BUYLIMIT) order_lots_4 = OrderLots();
   }
   return (order_lots_4);
}

// F3A55A1359FE0A12653C7C86D0E4636D
double f0_53(int A_cmd_0) {
   double order_lots_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
      A_cmd_0 = OrderType();
      if (A_cmd_0 == OP_SELL) order_lots_4 = OrderLots();
      if (A_cmd_0 == OP_SELLLIMIT) order_lots_4 = OrderLots();
   }
   return (order_lots_4);
}

// 412AE35045AB19A453713D3A18B4EB5C
double f0_12(int A_cmd_0) {
   double order_lots_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
      A_cmd_0 = OrderType();
      if (A_cmd_0 == OP_BUY) order_lots_4 = OrderLots();
      if (A_cmd_0 == OP_BUYLIMIT) order_lots_4 = OrderLots();
   }
   return (order_lots_4);
}

// 84199EAF75B5BF8D2AA2B1CC1A93963D
double f0_29(int A_cmd_0) {
   double order_lots_4;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
      A_cmd_0 = OrderType();
      if (A_cmd_0 == OP_SELL) order_lots_4 = OrderLots();
      if (A_cmd_0 == OP_SELLLIMIT) order_lots_4 = OrderLots();
   }
   return (order_lots_4);
}

// 1EA58164390F7C8C3A5FC6555D49C4CC
void f0_2() {
   double price_0 = f0_28();
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic + 9) {
         if (OrderType() == OP_BUY) {
            if (Bid - price_0 > Gd_376 * Trailing) {
               if (OrderStopLoss() < Bid - Gd_376 * Trailing) {
                  OrderModify(OrderTicket(), price_0, Bid - Gd_376 * Trailing, OrderTakeProfit(), 0, Blue);
                  return;
               }
            }
         }
      }
   }
}

// 0F580DC10F7A61EF884FE17B81BCFBD9
void f0_0() {
   double price_0 = f0_50();
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic + 99) {
         if (OrderType() == OP_SELL) {
            if (price_0 - Ask > Gd_376 * Trailing) {
               if (OrderStopLoss() > Ask + Gd_376 * Trailing || OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), price_0, Ask + Gd_376 * Trailing, OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

// 3457E2065911204D97ACB974F492D594
void f0_9() {
   double price_0 = f0_47();
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic + 999) {
         if (OrderType() == OP_BUY) {
            if (Bid - price_0 > Gd_376 * Trailing) {
               if (OrderStopLoss() < Bid - Gd_376 * Trailing) {
                  OrderModify(OrderTicket(), price_0, Bid - Gd_376 * Trailing, OrderTakeProfit(), 0, Blue);
                  return;
               }
            }
         }
      }
   }
}

// E9AF4186D6F605E17D6FC71A5E9622D9
void f0_52() {
   double price_0 = f0_20();
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic + 9999) {
         if (OrderType() == OP_SELL) {
            if (price_0 - Ask > Gd_376 * Trailing) {
               if (OrderStopLoss() > Ask + Gd_376 * Trailing || OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), price_0, Ask + Gd_376 * Trailing, OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

// 79B7EFA2D20E8BA00E23FE620C1D5715
double f0_28() {
   int cmd_16;
   double Ld_ret_0 = 0;
   double Ld_8 = 0;
   for (int pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
      Sleep(1);
      if (OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9) continue;
         cmd_16 = OrderType();
         if (cmd_16 == OP_BUY) {
            Ld_ret_0 += OrderOpenPrice() * OrderLots();
            Ld_8 += OrderLots();
         }
      }
   }
   if (Ld_8 > 0.0) Ld_ret_0 = NormalizeDouble(Ld_ret_0 / Ld_8, MarketInfo(OrderSymbol(), MODE_DIGITS));
   return (Ld_ret_0);
}

// E70445D6495DC87DFD18DC44615E65D5
double f0_50() {
   int cmd_16;
   double Ld_ret_0 = 0;
   double Ld_8 = 0;
   for (int pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
      Sleep(1);
      if (OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 99) continue;
         cmd_16 = OrderType();
         if (cmd_16 == OP_SELL) {
            Ld_ret_0 += OrderOpenPrice() * OrderLots();
            Ld_8 += OrderLots();
         }
      }
   }
   if (Ld_8 > 0.0) Ld_ret_0 = NormalizeDouble(Ld_ret_0 / Ld_8, MarketInfo(OrderSymbol(), MODE_DIGITS));
   return (Ld_ret_0);
}

// DD5BB1407400F9F8FEF49745987F0FE5
double f0_47() {
   int cmd_16;
   double Ld_ret_0 = 0;
   double Ld_8 = 0;
   for (int pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
      Sleep(1);
      if (OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 999) continue;
         cmd_16 = OrderType();
         if (cmd_16 == OP_BUY) {
            Ld_ret_0 += OrderOpenPrice() * OrderLots();
            Ld_8 += OrderLots();
         }
      }
   }
   if (Ld_8 > 0.0) Ld_ret_0 = NormalizeDouble(Ld_ret_0 / Ld_8, MarketInfo(OrderSymbol(), MODE_DIGITS));
   return (Ld_ret_0);
}

// 58C031536B20A4CCCBBFC425FD2A9C73
double f0_20() {
   int cmd_16;
   double Ld_ret_0 = 0;
   double Ld_8 = 0;
   for (int pos_20 = OrdersTotal() - 1; pos_20 >= 0; pos_20--) {
      Sleep(1);
      if (OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic + 9999) continue;
         cmd_16 = OrderType();
         if (cmd_16 == OP_SELL) {
            Ld_ret_0 += OrderOpenPrice() * OrderLots();
            Ld_8 += OrderLots();
         }
      }
   }
   if (Ld_8 > 0.0) Ld_ret_0 = NormalizeDouble(Ld_ret_0 / Ld_8, MarketInfo(OrderSymbol(), MODE_DIGITS));
   return (Ld_ret_0);
}

// 1722A28089F91B73FFF8708C26800A5E
void f0_1(int A_magic_0, string As_4) {
   int cmd_16;
   double order_open_price_20;
   double order_lots_28;
   double Ld_40;
   int Li_12 = f0_56(A_magic_0);
   if (Li_12 > 0 && Li_12 < Level_Max) {
      for (int pos_36 = 0; pos_36 < OrdersTotal(); pos_36++) {
         if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != A_magic_0) continue;
            cmd_16 = OrderType();
            order_open_price_20 = OrderOpenPrice();
            order_lots_28 = OrderLots();
         }
      }
      Ld_40 = order_open_price_20 - Range * Gd_376;
      if (cmd_16 == OP_BUY && Ask <= Ld_40) G_ticket_416 = OrderSend(Symbol(), OP_BUY, f0_42(order_lots_28 * DiMarti), Ask, 3, Ask - SL * Gd_376, Ask + TP * Gd_376, As_4 + Li_12, A_magic_0, 0, Green);
      Ld_40 = order_open_price_20 + Range * Gd_376;
      if (cmd_16 == OP_SELL && Bid >= Ld_40) G_ticket_416 = OrderSend(Symbol(), OP_SELL, f0_42(order_lots_28 * DiMarti), Bid, 3, Bid + SL * Gd_376, Bid - TP * Gd_376, As_4 + Li_12, A_magic_0, 0, Yellow);
   }
}

// CF699EF5D42DEFC5E2D9E4610AFDF822
double f0_42(double Ad_0) {
   double maxlot_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   double minlot_16 = MarketInfo(Symbol(), MODE_MINLOT);
   double lotstep_24 = MarketInfo(Symbol(), MODE_LOTSTEP);
   double Ld_32 = lotstep_24 * NormalizeDouble(Ad_0 / lotstep_24, 0);
   Ld_32 = MathMax(MathMin(maxlot_8, Ld_32), minlot_16);
   return (Ld_32);
}

// FBB44B4487415B134BCE9C790A27FE5E
int f0_56(int A_magic_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
         if (A_magic_0 == OrderMagicNumber()) count_4++;
   }
   return (count_4);
}

// B021DF6AAC4654C454F46C77646E745F
void f0_35() {
   Gsa_492[0] = "-------------------------------------------";
   Gsa_492[1] = "";
   Gsa_492[4] = "";
   Gsa_492[5] = "";
   Gsa_492[6] = "";
   Gsa_492[7] = "";
   Gsa_492[2] = "==>>gifaesa@yahoo,com==";
   Gsa_492[3] = "-------------------------------------------";
   double irsi_0 = iRSI(NULL, PERIOD_M1, 3, PRICE_CLOSE, 0);
   if (irsi_0 < 15.0) Gsa_492[1] = "::::+Jum+StoCh+::::";
   else {
      if (irsi_0 >= 15.0 && irsi_0 < 30.0) Gsa_492[4] = "::::+Jum+StoCh+::::";
      else {
         if (irsi_0 >= 30.0 && irsi_0 <= 60.0) Gsa_492[5] = "::::+Jum+StoCh+::::";
         else {
            if (irsi_0 >= 60.0 && irsi_0 <= 80.0) Gsa_492[6] = "::::+Jum+StoCh+::::";
            else Gsa_492[7] = "::::+Jum+StoCh+::::";
         }
      }
   }
   ObjectCreate("ObjLabel1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel1", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel1", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel1", OBJPROP_YDISTANCE, 17);
   ObjectSetText("ObjLabel1", Gsa_492[0], 10, "Arial", Yellow);
   ObjectCreate("ObjLabel2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel2", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel2", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel2", OBJPROP_YDISTANCE, 30);
   ObjectSetText("ObjLabel2", Gsa_492[1], 17, "Arial", Aqua);
   ObjectCreate("ObjLabel5", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel5", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel5", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel5", OBJPROP_YDISTANCE, 30);
   ObjectSetText("ObjLabel5", Gsa_492[4], 17, "Arial", Red);
   ObjectCreate("ObjLabel6", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel6", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel6", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel6", OBJPROP_YDISTANCE, 30);
   ObjectSetText("ObjLabel6", Gsa_492[5], 17, "Arial", Blue);
   ObjectCreate("ObjLabel7", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel7", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel7", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel7", OBJPROP_YDISTANCE, 30);
   ObjectSetText("ObjLabel7", Gsa_492[6], 17, "Arial", Yellow);
   ObjectCreate("ObjLabel8", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel8", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel8", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel8", OBJPROP_YDISTANCE, 30);
   ObjectSetText("ObjLabel8", Gsa_492[7], 17, "Arial", DarkOrange);
   ObjectCreate("ObjLabel4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 50);
   ObjectSetText("ObjLabel4", Gsa_492[2], 10, "Arial", Lime);
   ObjectCreate("ObjLabel3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel3", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel3", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel3", OBJPROP_YDISTANCE, 63);
   ObjectSetText("ObjLabel3", Gsa_492[0], 10, "Arial", Yellow);
   int Li_16 = Time[0] + 60 * Period() - TimeCurrent();
   double Ld_8 = Li_16 / 60.0;
   int Li_20 = Li_16 % 60;
   Li_16 = (Li_16 - Li_16 % 60) / 60;
   ObjectDelete("time");
   if (ObjectFind("time") != 0) {
      ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0] + 0.0005);
      ObjectSetText("time", "                             " + Li_16 + ":" + Li_20, 14, "Arial", Orange);
      return;
   }
   ObjectMove("time", 0, Time[0], Close[0] + 0.0005);
}
