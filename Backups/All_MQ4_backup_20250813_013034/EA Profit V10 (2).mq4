/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  Ht tP : //www. MetAquot Es.N e T
   E-mail : SU Pp or T@ ME T a Q uO T e S.nET
*/
#property copyright "Copyright 2013, Onlinemoneythai"
#property link      "http://www.onlinemoneythai.com"

extern string RunEAonTimeframe = "H4";
extern string Productskey = "V10N-CD56-EU12-JP89-FR74-MN23";
extern string Products = "EA Profit V10 Trader(THAILAND)";
extern int MagicNumber = 1556;
extern string SettingeaComment = "SettingeaComment";
extern bool eaComment1 = FALSE;
extern string SettingOrder = "SettingOrder";
extern int MaxSpread = 2;
extern double Lots = 0.01;
extern int TakeProfit = 80;
extern int StopLoss = 100;
extern int trailing = 2;
extern double Maxlot = 99.0;
extern int MaxOrder = 100;
extern string MoneyManagement = "AutoMoneyManagement";
extern bool AutoMoneyManagement = FALSE;
extern double PercentToRisk = 1.0;
extern double PercentSafety = 200.0;
extern string SetDeletePendingTime = "SetDeletependingTime ( M1,M5,M15,M30,H1,H4,D1)";
extern string DeletePendingTime = "M15";
extern string SetEMA = "Set Moving Average ";
extern int PeriodEMA = 50;
extern string Timeset = "Timeset";
extern int StartTrade = 0;
extern int EndTrade = 0;
int G_bars_232;
int G_ticket_240;
int G_ticket_244;
int Gi_252 = 0;
double Gd_280;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   if (Digits == 5) {
      MaxSpread = 10 * MaxSpread;
      TakeProfit = 10 * TakeProfit;
      StopLoss = 10 * StopLoss;
      trailing = 10 * trailing;
   }
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectsDeleteAll(0, EMPTY);
   return (0);
}

// 1C827DFF0C63B286303A3EAEF673B56B
int f0_0() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol())
         if (OrderType() == OP_SELLSTOP) count_0++;
   }
   if (count_0 > 0) return (count_0);
   return (0);
}

// 2E14BEE9A9821BFFA968C7123D43E7E6
int f0_1() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol())
         if (OrderType() == OP_BUYSTOP) count_0++;
   }
   if (count_0 > 0) return (count_0);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double iopen_8;
   int Li_0 = MaxSpread;
   int Li_4 = MaxSpread;
   if (Productskey != "V10N-CD56-EU12-JP89-FR74-MN23") Comment("\n ERROR :: Invalid Productskey !");
   if (Productskey != "V10N-CD56-EU12-JP89-FR74-MN23") return (0);
   if (Year() > 2018) Comment("\n ERROR :: EA Expire Please Update New Version !");
   if (Year() > 2018) return (0);
   if (Period() != PERIOD_H4) Comment("\n ERROR :: Invalid Timeframe, Please Switch to H4 !");
   if (Period() != PERIOD_H4) return (0);
   if (OrdersTotal() < MaxOrder)
      if (OrdersTotal() > MaxOrder) return (0);
   if (StartTrade > EndTrade)
      if (Hour() >= EndTrade && Hour() < StartTrade) return (0);
   if (StartTrade < EndTrade)
      if (Hour() < StartTrade || Hour() >= EndTrade) return (0);
   if (Bars > G_bars_232) iopen_8 = iOpen(NULL, 0, 1);
   double iclose_16 = iClose(NULL, 0, 1);
   double bid_24 = Bid;
   double ima_32 = iMA(NULL, 0, PeriodEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double Ld_40 = PercentToRisk / 1000.0;
   if (AutoMoneyManagement) Lots = NormalizeDouble(AccountBalance() * Ld_40 / PercentSafety / MarketInfo(Symbol(), MODE_TICKVALUE), 2);
   if (Lots > Maxlot) Lots = Maxlot;
   if (DeletePendingTime == "M1") Gd_280 = 1;
   if (DeletePendingTime == "M5") Gd_280 = 5;
   if (DeletePendingTime == "M15") Gd_280 = 15;
   if (DeletePendingTime == "M30") Gd_280 = 30;
   if (DeletePendingTime == "H1") Gd_280 = 60;
   if (DeletePendingTime == "H4") Gd_280 = 240;
   if (DeletePendingTime == "D1") Gd_280 = 1440;
   int datetime_48 = TimeCurrent() + 60.0 * Gd_280;
   if (Day() != Gi_252 || Gi_252 == 0) {
      if (f0_1() == 0 && iclose_16 > iopen_8 && bid_24 > ima_32 + Li_0 * Point) {
         G_ticket_240 = OrderSend(Symbol(), OP_BUYSTOP, Lots, Ask + Point * Li_0, 3, Bid - Point * StopLoss, Ask + Point * TakeProfit, "EA-PO-V10", MagicNumber, datetime_48,
            Blue);
      }
      if (f0_0() == 0 && iclose_16 > iopen_8 && bid_24 < ima_32 - Li_4 * Point) {
         G_ticket_244 = OrderSend(Symbol(), OP_SELLSTOP, Lots, Bid - Point * Li_4, 3, Ask + Point * StopLoss, Bid - Point * TakeProfit, "EA-PO-V10", MagicNumber, datetime_48,
            Red);
      }
      G_bars_232 = Bars;
      f0_2();
      f0_4();
      if (eaComment1 == TRUE) f0_3();
   }
   return (0);
}

// 7464F3B908A3CF705097CF5A67DB185F
void f0_2() {
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY) {
         if (trailing > 0) {
            if (Bid - OrderOpenPrice() > trailing * Point)
               if (OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > trailing * Point) OrderModify(OrderTicket(), OrderOpenPrice(), Bid - trailing * Point, OrderTakeProfit(), 0, Blue);
         }
      }
      if (OrderType() == OP_SELL) {
         if (trailing > 0) {
            if (OrderOpenPrice() - Ask > trailing * Point)
               if (OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > trailing * Point) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + trailing * Point, OrderTakeProfit(), 0, Red);
         }
      }
   }
}

// 773E9ECACC0D186289BC481F1502B87E
void f0_3() {
   string Ls_0 = "";
   string Ls_8 = "\n";
   Ls_0 = Ls_0 + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## " + "EA Profit V10 Trader(THAILAND)" + Ls_8;
   Ls_0 = Ls_0 + "## " + "Copyright © 2013 onlinemoneythai.com" + Ls_8;
   Ls_0 = Ls_0 + "## " + "Visit: http://www.onlinemoneythai.com " + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## EA Productskey :: " + Productskey + Ls_8;
   Ls_0 = Ls_0 + "## EA Expireyear :: " + 2018 + Ls_8;
   Ls_0 = Ls_0 + "## EA MagicNumber :: " + MagicNumber + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## Forex Server :: " + AccountServer() + Ls_8;
   Ls_0 = Ls_0 + "## AccountNumber :: " + AccountNumber() + Ls_8;
   Ls_0 = Ls_0 + "## AccountName :: " + AccountName() + Ls_8;
   Ls_0 = Ls_0 + "## Leverage :: " + AccountLeverage() + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## Balance :: " + DoubleToStr(AccountBalance(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## Equity :: " + DoubleToStr(AccountEquity(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## Margin :: " + DoubleToStr(AccountMargin(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## FreeMargin :: " + DoubleToStr(AccountFreeMargin(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## MarginUsage :: " + DoubleToStr(100 - 100.0 * (AccountFreeMargin() / AccountBalance()), 2) + "%" + Ls_8;
   Ls_0 = Ls_0 + "## Profit :: " + DoubleToStr(AccountProfit(), 2) + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## Symbol :: " + Symbol() + Ls_8;
   Ls_0 = Ls_0 + "## Price :: " + DoubleToStr(Bid, 5) + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## Lots :: " + DoubleToStr(Lots, 2) + Ls_8;
   Ls_0 = Ls_0 + "## TakeProfit :: " + TakeProfit + Ls_8;
   Ls_0 = Ls_0 + "## StopLoss :: " + StopLoss + Ls_8;
   Ls_0 = Ls_0 + "## OrdersTotal :: " + OrdersTotal() + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## Timeserver :: " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES) + Ls_8;
   Ls_0 = Ls_0 + "## Timeslocal :: " + TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES) + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Comment(Ls_0);
}

// BD787A2F340C4AC21BA083035209F751
void f0_4() {
   ObjectCreate("EAname", OBJ_LABEL, 0, 0, 0);
   ObjectSet("EAname", OBJPROP_CORNER, 1);
   ObjectSet("EAname", OBJPROP_XDISTANCE, 20);
   ObjectSet("EAname", OBJPROP_YDISTANCE, 20);
   ObjectSetText("EAname", "EA Profit V10 Trader(THAILAND)" + "(" + Symbol() + ")", 30, "-JS Angsumalin", Gold);
   ObjectCreate("klc20", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc20", "Forex Server :: " + AccountServer(), 16, "Browallia New", Gold);
   ObjectSet("klc20", OBJPROP_CORNER, 1);
   ObjectSet("klc20", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc20", OBJPROP_YDISTANCE, 60);
   ObjectCreate("klc32", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc32", "AccountNumber :: " + AccountNumber(), 16, "Browallia New", Gold);
   ObjectSet("klc32", OBJPROP_CORNER, 1);
   ObjectSet("klc32", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc32", OBJPROP_YDISTANCE, 80);
   ObjectCreate("klc21", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc21", "Lots :: " + DoubleToStr(Lots, 2), 16, "Browallia New", Gold);
   ObjectSet("klc21", OBJPROP_CORNER, 1);
   ObjectSet("klc21", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc21", OBJPROP_YDISTANCE, 100);
   ObjectCreate("klc22", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc22", "Balance :: " + DoubleToStr(AccountBalance(), 2), 16, "Browallia New", Gold);
   ObjectSet("klc22", OBJPROP_CORNER, 1);
   ObjectSet("klc22", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc22", OBJPROP_YDISTANCE, 120);
   ObjectCreate("klc23", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc23", "Equity :: " + DoubleToStr(AccountEquity(), 2), 16, "Browallia New", Gold);
   ObjectSet("klc23", OBJPROP_CORNER, 1);
   ObjectSet("klc23", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc23", OBJPROP_YDISTANCE, 140);
   ObjectCreate("klc24", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc24", "TotalProfit :: " + DoubleToStr(AccountProfit(), 2), 16, "Browallia New", Gold);
   ObjectSet("klc24", OBJPROP_CORNER, 1);
   ObjectSet("klc24", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc24", OBJPROP_YDISTANCE, 160);
   ObjectCreate("klc27", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc27", "OrdersTotal :: " + OrdersTotal(), 16, "Browallia New", Gold);
   ObjectSet("klc27", OBJPROP_CORNER, 1);
   ObjectSet("klc27", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc27", OBJPROP_YDISTANCE, 180);
   ObjectCreate("klc29", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc29", "DayOfWeek :: " + DayOfWeek(), 16, "Browallia New", Gold);
   ObjectSet("klc29", OBJPROP_CORNER, 1);
   ObjectSet("klc29", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc29", OBJPROP_YDISTANCE, 200);
   ObjectCreate("klc26", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc26", "Timeserver :: " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES), 16, "Browallia New", Gold);
   ObjectSet("klc26", OBJPROP_CORNER, 1);
   ObjectSet("klc26", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc26", OBJPROP_YDISTANCE, 220);
   ObjectCreate("klc30", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc30", "EA Expireyear :: " + 2018, 16, "Browallia New", Gold);
   ObjectSet("klc30", OBJPROP_CORNER, 1);
   ObjectSet("klc30", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc30", OBJPROP_YDISTANCE, 240);
   ObjectCreate("klc31", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc31", "EA Productskey :: " + Productskey, 16, "Browallia New", Gold);
   ObjectSet("klc31", OBJPROP_CORNER, 1);
   ObjectSet("klc31", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc31", OBJPROP_YDISTANCE, 260);
   ObjectCreate("klc19", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc19", "_________________", 90, "Tahoma", Red);
   ObjectSet("klc19", OBJPROP_CORNER, 1);
   ObjectSet("klc19", OBJPROP_XDISTANCE, 1200);
   ObjectSet("klc19", OBJPROP_YDISTANCE, 270);
   ObjectCreate("klc18", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc18", "_________________", 90, "Tahoma", White);
   ObjectSet("klc18", OBJPROP_CORNER, 1);
   ObjectSet("klc18", OBJPROP_XDISTANCE, 1200);
   ObjectSet("klc18", OBJPROP_YDISTANCE, 280);
   ObjectCreate("klc17", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc17", "_________________", 90, "Tahoma", Blue);
   ObjectSet("klc17", OBJPROP_CORNER, 1);
   ObjectSet("klc17", OBJPROP_XDISTANCE, 1200);
   ObjectSet("klc17", OBJPROP_YDISTANCE, 290);
   ObjectCreate("klc16", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc16", "_________________", 90, "Tahoma", Blue);
   ObjectSet("klc16", OBJPROP_CORNER, 1);
   ObjectSet("klc16", OBJPROP_XDISTANCE, 1200);
   ObjectSet("klc16", OBJPROP_YDISTANCE, 295);
   ObjectCreate("klc15", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc15", "_________________", 90, "Tahoma", White);
   ObjectSet("klc15", OBJPROP_CORNER, 1);
   ObjectSet("klc15", OBJPROP_XDISTANCE, 1200);
   ObjectSet("klc15", OBJPROP_YDISTANCE, 305);
   ObjectCreate("klc14", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc14", "_________________", 90, "Tahoma", Red);
   ObjectSet("klc14", OBJPROP_CORNER, 1);
   ObjectSet("klc14", OBJPROP_XDISTANCE, 1200);
   ObjectSet("klc14", OBJPROP_YDISTANCE, 315);
   ObjectCreate("klc13", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc13", "THAILAND", 50, "Tahoma", Red);
   ObjectSet("klc13", OBJPROP_CORNER, 1);
   ObjectSet("klc13", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc13", OBJPROP_YDISTANCE, 330);
}
