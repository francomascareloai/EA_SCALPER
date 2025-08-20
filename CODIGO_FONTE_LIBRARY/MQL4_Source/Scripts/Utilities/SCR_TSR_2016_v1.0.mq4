/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  ht T P:/ / w WW . m E tA q UOt ES . n ET
   E-mail :  SUPp ORT @ MET a Q uo TeS. NE T
*/
#property copyright "Jum69"
#property link      "Gifaesa@yahoo.com"

extern string Seting_Parameter = "=>Parameter Pro+v2.5<<";
extern string StopTrade_Info = "=>Model Stop Profit / Take Loss EA<<";
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
extern string Seting_MM = "=>Seting sesuai selera<<";
extern string Lot_info = "Lot Mode = 1 -> Compound; Mode = 2 -> Fix Lot)";
extern int Lot_mode = 2;
extern string Lot_info2 = "Rumus Compound = Balance/Manage_Lot";
extern double Manage_Lot = 10000.0;
extern double Fix_lot = 0.01;
extern int Magic = 69;
extern double Range = 21.0;
extern int Level_Max = 12;
extern double DiMarti = 1.7;
extern double SL = 253.0;
extern double TP = 30.0;
extern int Star_ModifTp_Bep = 3;
extern double Tp_from_Bep = 11.0;
extern bool Tp_In_money = FALSE;
extern double Tp_in_money = 7.0;
extern bool Dtrailing = TRUE;
extern int StartTrail = 10;
extern int Trailing = 7;
extern string Indi_Seting = "==>Stockhastic trend & MA Seting<<=";
extern int kperiod = 32;
extern int dperiod = 12;
extern int slowing = 12;
extern int lo_level = 25; 
extern int up_level = 75;
extern int maPereode = 25;
extern string Indi_Stoch_2 = "==>Stockhastic counter trend<<=";
extern int k_period = 32;
extern int d_period = 12;
extern int s_lowing = 12;
extern int lolevel = 30; 
extern int uplevel = 70;
double Gd_376;
double Gd_384;
double G_lots_392;
double Gd_400;
int G_ticket_408 = 0;
int G_magic_412;
int G_magic_416;
int G_magic_420;
int G_magic_424;
string Gs_428 = "+Jum+StoCh-1+";
string Gs_436 = "+Jum+StoCh-2+";
string Gs_444 = "+Jum+StoCh-3+";
string Gs_452 = "+Jum+StoCh-4+";
string Gs_dummy_460;
string Gs_dummy_468;
string Gs_dummy_476;
string Gs_dummy_484;
string Gsa_492[10];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gd_400 = AccountBalance();
   Gd_376 = MarketInfo(Symbol(), MODE_TICKSIZE);
   int Li_0 = 1;
   if (Digits == 3 || Digits == 5) {
      Gd_376 = 10.0 * Gd_376;
      Li_0 = 10 * Li_0;
   }
   Gd_384 = MarketInfo(Symbol(), MODE_STOPLEVEL) / Li_0;
   if (SL > 0.0 && SL < Gd_384) {
      Print("stoploss is too tight.");
      SL = Gd_384;
   }
   if (TP > 0.0 && TP < Gd_384) {
      Print("takeprofit is too tight.");
      TP = Gd_384;
   }
   if (Trailing < Gd_384) {
      Print("trailing is too tight.");
      Trailing = Gd_384;
   }
   G_magic_412 = Magic + 9;
   G_magic_416 = Magic + 99;
   G_magic_420 = Magic + 999;
   G_magic_424 = Magic + 9999;
   if (Lot_mode == 2) G_lots_392 = f0_7(Fix_lot);
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
   if (Lot_mode == 1) G_lots_392 = f0_7(AccountBalance() / Manage_Lot);
   if (Lot_mode < 1 || Lot_mode > 2) {
      Comment("invalid Lot_Mode");
      return (0);
   }
   f0_2();
   f0_5();
   double Ld_0 = Gd_400 * Target_Persen / 100.0;
   if (AccountEquity() >= Gd_400 + Ld_0 || (Risk_In_Money && AccountEquity() <= Gd_400 - Risk_in_money) || Close_Panic) {
      f0_3(G_magic_412);
      f0_3(G_magic_416);
      f0_3(G_magic_420);
      f0_3(G_magic_424);
      return;
   }
   if (Close_Buy_Trend) f0_3(G_magic_412);
   if (Close_Sell_Trend) f0_3(G_magic_416);
   if (Close_Buy_Counter) f0_3(G_magic_420);
   if (Close_Sell_Counter) f0_3(G_magic_424);
   if (Tp_In_money && f0_6(G_magic_412) + f0_6(G_magic_416) + f0_6(G_magic_420) + f0_6(G_magic_424) >= Tp_in_money) {
      f0_3(G_magic_412);
      f0_3(G_magic_416);
      f0_3(G_magic_420);
      f0_3(G_magic_424);
   }
   f0_8(G_magic_412, Gs_428);
   f0_8(G_magic_416, Gs_436);
   f0_8(G_magic_420, Gs_444);
   f0_8(G_magic_424, Gs_452);
   f0_9(G_magic_412);
   f0_9(G_magic_416);
   f0_9(G_magic_420);
   f0_9(G_magic_424);
   if (Dtrailing) {
      f0_14(G_magic_412);
      f0_14(G_magic_416);
      f0_14(G_magic_420);
      f0_14(G_magic_424);
   }
   if (!Close_Panic) {
      if ((!Close_Buy_Trend) && Buy_Trend && f0_13(G_magic_412) == 0 && f0_1(1) == -2) G_ticket_408 = OrderSend(Symbol(), OP_BUY, G_lots_392, Ask, 3, Ask - SL * Gd_376, 0, Gs_428 + 0, G_magic_412, 0, White);
      if ((!Close_Sell_Trend) && Sell_Trend && f0_13(G_magic_416) == 0 && f0_1(1) == 2) G_ticket_408 = OrderSend(Symbol(), OP_SELL, G_lots_392, Bid, 3, Bid + SL * Gd_376, 0, Gs_436 + 0, G_magic_416, 0, Aqua);
      if ((!Close_Buy_Counter) && Buy_Counter && f0_13(G_magic_420) == 0 && f0_1(-1) == -2) G_ticket_408 = OrderSend(Symbol(), OP_BUY, G_lots_392, Ask, 3, Ask - SL * Gd_376, 0, Gs_444 + 0, G_magic_420, 0, Blue);
      if ((!Close_Sell_Counter) && Sell_Counter && f0_13(G_magic_424) == 0 && f0_1(-1) == 2) G_ticket_408 = OrderSend(Symbol(), OP_SELL, G_lots_392, Bid, 3, Bid + SL * Gd_376, 0, Gs_452 + 0, G_magic_424, 0, Red);
   }
   return (0);
}

// 521345A9FB579F52117F27BE6E0673EE
int f0_1(int Ai_0) {
   double ima_4 = iMA(Symbol(), 0, maPereode, 0, MODE_LWMA, PRICE_CLOSE, 0);
   double istochastic_12 = iStochastic(NULL, 0, kperiod, dperiod, slowing, MODE_SMA, 0, MODE_MAIN, 0);
   double istochastic_20 = iStochastic(NULL, 0, k_period, d_period, s_lowing, MODE_SMA, 0, MODE_MAIN, 0);
   if (Ai_0 == 1 && f0_0() == 1) {
      if (Close[1] < ima_4 && istochastic_12 > lo_level) return (2);
      if (Close[1] > ima_4 && istochastic_12 < up_level) return (-2);
   }
   if (Ai_0 == -1 && f0_4() == 1) {
      if (istochastic_20 > uplevel) return (2);
      if (istochastic_20 < lolevel) return (-2);
   }
   return (0);
}

// B20F59B3985C5F3854AB7E260249C6B0
double f0_6(int A_magic_0) {
   double Ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersTotal(); pos_12++) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
      if (A_magic_0 == OrderMagicNumber()) Ld_ret_4 += OrderProfit();
   }
   return (Ld_ret_4);
}

// 799B6F2C43F9E173C5420064357F04E6
void f0_3(int A_magic_0) {
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (A_magic_0 == OrderMagicNumber()) {
            if (OrderType() > OP_SELL) {
               OrderDelete(OrderTicket());
               continue;
            }
            if (OrderType() == OP_BUY) {
               OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
               continue;
            }
            OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
         }
      }
   }
}

// D2C24D8988C79CBCD26CAA5360E70D3B
void f0_8(int A_magic_0, string As_4) {
   int cmd_16;
   double order_open_price_20;
   double order_lots_28;
   double Ld_40;
   int Li_12 = f0_13(A_magic_0);
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
      if (cmd_16 == OP_BUY && Ask <= Ld_40) G_ticket_408 = OrderSend(Symbol(), OP_BUY, f0_7(order_lots_28 * DiMarti), Ask, 3, Ask - SL * Gd_376, 0, As_4 + Li_12, A_magic_0, 0, Green);
      Ld_40 = order_open_price_20 + Range * Gd_376;
      if (cmd_16 == OP_SELL && Bid >= Ld_40) G_ticket_408 = OrderSend(Symbol(), OP_SELL, f0_7(order_lots_28 * DiMarti), Bid, 3, Bid + SL * Gd_376, 0, As_4 + Li_12, A_magic_0, 0, Yellow);
   }
}

// E537BD21FFFF2D1921BD631DBE4E5641
void f0_9(int A_magic_0) {
   double Ld_8;
   double price_16;
   int Li_4 = f0_13(A_magic_0);
   if (Li_4 != 0) {
      if (Tp_from_Bep == 0.0 || TP == 0.0) return;
      Ld_8 = MathMax(f0_12(A_magic_0, OP_SELL), f0_12(A_magic_0, OP_BUY));
      for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
         if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
               if (OrderMagicNumber() == A_magic_0) {
                  if (Li_4 < Star_ModifTp_Bep) price_16 = f0_11(OrderType(), TP, OrderOpenPrice());
                  else price_16 = f0_11(OrderType(), Tp_from_Bep, Ld_8);
                  if (!f0_10(price_16, OrderTakeProfit())) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_16, 0, CLR_NONE);
               }
            }
         }
      }
   }
}

// FBB44B4487415B134BCE9C790A27FE5E
int f0_13(int A_magic_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
         if (A_magic_0 == OrderMagicNumber()) count_4++;
   }
   return (count_4);
}

// 212452DE8DD4E3765FBFA3DF557BA7EC
int f0_0() {
   bool Li_ret_0 = FALSE;
   if (StartHour > StopHour) {
      if (TimeHour(TimeCurrent()) >= StartHour || TimeHour(TimeCurrent()) < StopHour) Li_ret_0 = TRUE;
   } else
      if (TimeHour(TimeCurrent()) >= StartHour && TimeHour(TimeCurrent()) < StopHour) Li_ret_0 = TRUE;
   return (Li_ret_0);
}

// 98B03CD06244C904E7BE6CEDC0959B37
int f0_4() {
   bool Li_ret_0 = FALSE;
   if (Start_Hour > Stop_Hour) {
      if (TimeHour(TimeCurrent()) >= Start_Hour || TimeHour(TimeCurrent()) < Stop_Hour) Li_ret_0 = TRUE;
   } else
      if (TimeHour(TimeCurrent()) >= Start_Hour && TimeHour(TimeCurrent()) < Stop_Hour) Li_ret_0 = TRUE;
   return (Li_ret_0);
}

// 551B723EAFD6A31D444FCB2F5920FBD3
void f0_2() {
   Comment(" ---------------------------------------------", 
      "\n :: ===>Jum+StoCh+v2.5F+<===", 
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
      "\n :: Star_ModifTp_Bep       :", Star_ModifTp_Bep, 
      "\n :: Lot                    :", G_lots_392, 
      "\n :: SL                     :", SL, 
      "\n :: TP                     :", TP, 
      "\n :: Tp_in_money            :", Tp_in_money, 
      "\n ------------------------------------------------", 
      "\n :: ==>HAPPY TRADING<==", 
      "\n ------------------------------------------------", 
      "\n :: >>By: Fanioz + Jum69<<", 
   "\n ------------------------------------------------");
}

// FDD5E0C68EEEAC73C07299767285F173
void f0_14(int A_magic_0) {
   int Li_4;
   double price_24;
   double Ld_8 = f0_12(A_magic_0, OP_BUY);
   double Ld_16 = f0_12(A_magic_0, OP_SELL);
   for (int pos_32 = OrdersTotal() - 1; pos_32 >= 0; pos_32--) {
      if (OrderSelect(pos_32, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            if (OrderMagicNumber() == A_magic_0) {
               if (OrderType() == OP_BUY) {
                  Li_4 = NormalizeDouble((Bid - Ld_8) / Gd_376, 0);
                  if (Li_4 < StartTrail) break;
                  price_24 = NormalizeDouble(Bid - Trailing * Gd_376, Digits);
                  if (OrderStopLoss() == 0.0 || price_24 > OrderStopLoss()) OrderModify(OrderTicket(), OrderOpenPrice(), price_24, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  Li_4 = NormalizeDouble((Ld_16 - Ask) / Gd_376, 0);
                  if (Li_4 < StartTrail) break;
                  price_24 = NormalizeDouble(Ask + Trailing * Gd_376, Digits);
                  if (OrderStopLoss() == 0.0 || price_24 < OrderStopLoss()) OrderModify(OrderTicket(), OrderOpenPrice(), price_24, OrderTakeProfit(), 0, Pink);
               }
            }
         }
      }
   }
}

// F13FBEA2A572A0F4C0E556A78DEBE130
double f0_12(int A_magic_0, int A_cmd_4) {
   double Ld_ret_8 = 0;
   double Ld_16 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      Sleep(1);
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            if (A_cmd_4 == OrderType()) {
               if (A_magic_0 == OrderMagicNumber()) {
                  Ld_ret_8 += OrderOpenPrice() * OrderLots();
                  Ld_16 += OrderLots();
               }
            }
         }
      }
   }
   if (Ld_16 > 0.0) Ld_ret_8 = NormalizeDouble(Ld_ret_8 / Ld_16, Digits);
   return (Ld_ret_8);
}

// F118561F66E8842F90A7F72983FC298F
double f0_11(int Ai_0, int Ai_4, double Ad_8) {
   if (Ai_4 == 0) return (0);
   if (MathMod(Ai_0, 2) == 0.0) return (Ad_8 + Gd_376 * Ai_4);
   return (Ad_8 - Gd_376 * Ai_4);
}

// CF699EF5D42DEFC5E2D9E4610AFDF822
double f0_7(double Ad_0) {
   double maxlot_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   double minlot_16 = MarketInfo(Symbol(), MODE_MINLOT);
   double lotstep_24 = MarketInfo(Symbol(), MODE_LOTSTEP);
   double Ld_32 = lotstep_24 * NormalizeDouble(Ad_0 / lotstep_24, 0);
   Ld_32 = MathMax(MathMin(maxlot_8, Ld_32), minlot_16);
   return (Ld_32);
}

// EA6A96F8F1079FD551A37FB62C23AE0D
bool f0_10(double Ad_0, double Ad_8) {
   bool bool_16 = NormalizeDouble(Ad_0 / Point, 0) == NormalizeDouble(Ad_8 / Point, 0);
   return (bool_16);
}

// B021DF6AAC4654C454F46C77646E745F
void f0_5() {
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
