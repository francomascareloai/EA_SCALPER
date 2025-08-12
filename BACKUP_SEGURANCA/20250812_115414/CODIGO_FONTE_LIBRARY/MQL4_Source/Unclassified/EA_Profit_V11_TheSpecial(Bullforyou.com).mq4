#property copyright "Copyright 2013, onlinemoneythai."
#property link      "http://www.onlinemoneythai.com"

extern string RunEAonTimeframe = "H4";
extern string Products = "EA Profit V11 TheSpecial";
extern int MagicNumber = 2558;
extern bool StopOrder1 = TRUE;
extern bool StopOrder2 = TRUE;
extern bool StopOrder3 = TRUE;
extern bool StopOrder4 = TRUE;
extern bool StopOrder5 = TRUE;
extern string SettingOrder = "SettingOrder";
extern int MaxSpread = 20;
extern int MaxpipBuy = 100;
extern int MaxpipSell = 100;
extern double Lots = 0.01;
extern int TakeProfit = 800;
extern int StopLoss = 1000;
extern int Trailing = 20;
extern double Maxlot = 999.0;
extern int MaxOrder = 100;
extern string MoneyManagement = "AutoMoneyManagement";
extern bool AutoMoneyManagement = FALSE;
extern double PercentToRisk = 1.0;
extern double PercentSafety = 100.0;
extern string SetEMA = "Set Moving Average ";
extern int PeriodEMA = 50;
extern string SetDeletePendingTime = "SetDeletependingTime ( M1,M5,M15,M30,H1,H4,D1)";
extern string DeletePendingTime = "M15";
extern string Timeset = "Timeset";
extern int Start = 0;
extern int End = 0;
int Gi_252 = 0;
int G_bars_256;
int G_ticket_264;
int G_ticket_268;
double Gd_296;

int deinit() {
   ObjectsDeleteAll(0, EMPTY);
   return (0);
}

int f0_1() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol())
         if (OrderType() == OP_SELLSTOP) count_0++;
   }
   if (count_0 > 0) return (count_0);
   return (0);
}

int f0_2() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol())
         if (OrderType() == OP_BUYSTOP) count_0++;
   }
   if (count_0 > 0) return (count_0);
   return (0);
}

int start() {
   double iopen_12;
   int order_total_0 = OrdersTotal();
   int Li_4 = MaxSpread;
   int Li_8 = MaxSpread;
   if (OrdersTotal() < MaxOrder)
      if (OrdersTotal() > MaxOrder) return (0);
   if (Period() != PERIOD_H4) Comment("\n ERROR :: Invalid Timeframe, Please Switch to H4 !");
   if (Period() != PERIOD_H4) return (0);
   if (Start > End)
      if (Hour() >= End && Hour() < Start) return (0);
   if (Start < End)
      if (Hour() < Start || Hour() >= End) return (0);
   if (Bars > G_bars_256) iopen_12 = iOpen(NULL, 0, 1);
   double iclose_20 = iClose(NULL, 0, 1);
   double bid_28 = Bid;
   double ima_36 = iMA(NULL, 0, PeriodEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double Ld_44 = PercentToRisk / 1000.0;
   if (AutoMoneyManagement) Lots = NormalizeDouble(AccountBalance() * Ld_44 / PercentSafety / MarketInfo(Symbol(), MODE_TICKVALUE), 2);
   if (Lots > Maxlot) Lots = Maxlot;
   if (DeletePendingTime == "M1") Gd_296 = 1;
   if (DeletePendingTime == "M5") Gd_296 = 5;
   if (DeletePendingTime == "M15") Gd_296 = 15;
   if (DeletePendingTime == "M30") Gd_296 = 30;
   if (DeletePendingTime == "H1") Gd_296 = 60;
   if (DeletePendingTime == "H4") Gd_296 = 240;
   if (DeletePendingTime == "D1") Gd_296 = 1440;
   int datetime_52 = TimeCurrent() + 60.0 * Gd_296;
   if (Day() != Gi_252 || Gi_252 == 0) {
      if (StopOrder1 == TRUE) {
         if (order_total_0 < MaxOrder && f0_2() == 0 && iclose_20 > iopen_12 && bid_28 > ima_36 + Li_4 * Point) {
            G_ticket_264 = OrderSend(Symbol(), OP_BUYSTOP, Lots, Ask + Point * MaxpipBuy, 3, Bid - Point * StopLoss, Ask + Point * TakeProfit, "EA-POS-V11", MagicNumber, datetime_52,
               Blue);
         }
      }
      if (order_total_0 < MaxOrder && f0_1() == 0 && iclose_20 > iopen_12 && bid_28 < ima_36 - Li_8 * Point) {
         G_ticket_268 = OrderSend(Symbol(), OP_SELLSTOP, Lots, Bid - Point * MaxpipSell, 3, Ask + Point * StopLoss, Bid - Point * TakeProfit, "EA-POS-V11", MagicNumber, datetime_52,
            Red);
      }
      if (StopOrder2 == TRUE) {
         if (order_total_0 < MaxOrder && (f0_2() == 0 || f0_2() == 1) && iclose_20 > iopen_12 && bid_28 > ima_36 + Li_4 * Point) {
            G_ticket_264 = OrderSend(Symbol(), OP_BUYSTOP, Lots, Ask + 2.0 * (Point * MaxpipBuy), 3, Bid - Point * StopLoss, Ask + Point * TakeProfit, "EA-POS-V11", MagicNumber,
               datetime_52, Blue);
         }
      }
      if (order_total_0 < MaxOrder && (f0_1() == 0 || f0_1() == 1) && iclose_20 > iopen_12 && bid_28 < ima_36 - Li_8 * Point) {
         G_ticket_268 = OrderSend(Symbol(), OP_SELLSTOP, Lots, Bid - 2.0 * (Point * MaxpipSell), 3, Ask + Point * StopLoss, Bid - Point * TakeProfit, "EA-POS-V11", MagicNumber,
            datetime_52, Red);
      }
      if (StopOrder3 == TRUE) {
         if (order_total_0 < MaxOrder && (f0_2() == 0 || f0_2() == 1 || f0_2() == 2) && iclose_20 > iopen_12 && bid_28 > ima_36 + Li_4 * Point) {
            G_ticket_264 = OrderSend(Symbol(), OP_BUYSTOP, Lots, Ask + 3.0 * (Point * MaxpipBuy), 3, Bid - Point * StopLoss, Ask + Point * TakeProfit, "EA-POS-V11", MagicNumber,
               datetime_52, Blue);
         }
      }
      if (order_total_0 < MaxOrder && (f0_1() == 0 || f0_1() == 1 || f0_1() == 2) && iclose_20 > iopen_12 && bid_28 < ima_36 - Li_8 * Point) {
         G_ticket_268 = OrderSend(Symbol(), OP_SELLSTOP, Lots, Bid - 3.0 * (Point * MaxpipSell), 3, Ask + Point * StopLoss, Bid - Point * TakeProfit, "EA-POS-V11", MagicNumber,
            datetime_52, Red);
      }
      if (StopOrder4 == TRUE) {
         if (order_total_0 < MaxOrder && (f0_2() == 0 || f0_2() == 1 || f0_2() == 2 || f0_2() == 3) && iclose_20 > iopen_12 && bid_28 > ima_36 + Li_4 * Point) {
            G_ticket_264 = OrderSend(Symbol(), OP_BUYSTOP, Lots, Ask + 4.0 * (Point * MaxpipBuy), 3, Bid - Point * StopLoss, Ask + Point * TakeProfit, "EA-POS-V11", MagicNumber,
               datetime_52, Blue);
         }
      }
      if (order_total_0 < MaxOrder && (f0_1() == 0 || f0_1() == 1 || f0_1() == 2 || f0_1() == 3) && iclose_20 > iopen_12 && bid_28 < ima_36 - Li_8 * Point) {
         G_ticket_268 = OrderSend(Symbol(), OP_SELLSTOP, Lots, Bid - 4.0 * (Point * MaxpipSell), 3, Ask + Point * StopLoss, Bid - Point * TakeProfit, "EA-POS-V11", MagicNumber,
            datetime_52, Red);
      }
      if (StopOrder5 == TRUE) {
         if (order_total_0 < MaxOrder && (f0_2() == 0 || f0_2() == 1 || f0_2() == 2 || f0_2() == 3 || f0_1() == 4) && iclose_20 > iopen_12 && bid_28 > ima_36 + Li_4 * Point) {
            G_ticket_264 = OrderSend(Symbol(), OP_BUYSTOP, Lots, Ask + 5.0 * (Point * MaxpipBuy), 3, Bid - Point * StopLoss, Ask + Point * TakeProfit, "EA-POS-V11", MagicNumber,
               datetime_52, Blue);
         }
      }
      if (order_total_0 < MaxOrder && (f0_1() == 0 || f0_1() == 1 || f0_1() == 2 || f0_1() == 3 || f0_1() == 4) && iclose_20 > iopen_12 && bid_28 < ima_36 - Li_8 * Point) {
         G_ticket_268 = OrderSend(Symbol(), OP_SELLSTOP, Lots, Bid - 5.0 * (Point * MaxpipSell), 3, Ask + Point * StopLoss, Bid - Point * TakeProfit, "EA-POS-V11", MagicNumber,
            datetime_52, Red);
      }
      G_bars_256 = Bars;
      f0_0();
      f0_4();
      f0_3();
   }
   return (0);
}

void f0_0() {
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY) {
         if (Trailing > 0) {
            if (Bid - OrderOpenPrice() > Trailing * Point)
               if (OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > Trailing * Point) OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Trailing * Point, OrderTakeProfit(), 0, Blue);
         }
      }
      if (OrderType() == OP_SELL) {
         if (Trailing > 0) {
            if (OrderOpenPrice() - Ask > Trailing * Point)
               if (OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > Trailing * Point) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Trailing * Point, OrderTakeProfit(), 0, Red);
         }
      }
   }
}

void f0_3() {
   string Ls_0 = "";
   string Ls_8 = "\n";
   Ls_0 = Ls_0 + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## " + "EA Profit V11 TheSpecial" + Ls_8;
   Ls_0 = Ls_0 + "#######################################" + Ls_8;
   Ls_0 = Ls_0 + "## Balance :: " + DoubleToStr(AccountBalance(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## Equity :: " + DoubleToStr(AccountEquity(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## Margin :: " + DoubleToStr(AccountMargin(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## FreeMargin :: " + DoubleToStr(AccountFreeMargin(), 2) + Ls_8;
   Ls_0 = Ls_0 + "## MarginUsage :: " + DoubleToStr(100 - 100.0 * (AccountFreeMargin() / AccountBalance()), 2) + "%" + Ls_8;
   Ls_0 = Ls_0 + "## Profit :: " + DoubleToStr(AccountProfit(), 2) + Ls_8;
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

void f0_4() {
   ObjectCreate("EAname", OBJ_LABEL, 0, 0, 0);
   ObjectSet("EAname", OBJPROP_CORNER, 1);
   ObjectSet("EAname", OBJPROP_XDISTANCE, 20);
   ObjectSet("EAname", OBJPROP_YDISTANCE, 20);
   ObjectSetText("EAname", "EA Profit V11 TheSpecial" + "(" + Symbol() + ")", 30, "Browallia New", Gold);
   ObjectCreate("klc20", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc20", "Forex Server :: " + AccountServer(), 20, "Browallia New", Gold);
   ObjectSet("klc20", OBJPROP_CORNER, 1);
   ObjectSet("klc20", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc20", OBJPROP_YDISTANCE, 60);
   ObjectCreate("klc21", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc21", "Lots :: " + DoubleToStr(Lots, 2), 20, "Browallia New", Gold);
   ObjectSet("klc21", OBJPROP_CORNER, 1);
   ObjectSet("klc21", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc21", OBJPROP_YDISTANCE, 90);
   ObjectCreate("klc22", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc22", "Balance :: " + DoubleToStr(AccountBalance(), 2), 20, "Browallia New", Gold);
   ObjectSet("klc22", OBJPROP_CORNER, 1);
   ObjectSet("klc22", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc22", OBJPROP_YDISTANCE, 120);
   ObjectCreate("klc23", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc23", "Equity :: " + DoubleToStr(AccountEquity(), 2), 20, "Browallia New", Gold);
   ObjectSet("klc23", OBJPROP_CORNER, 1);
   ObjectSet("klc23", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc23", OBJPROP_YDISTANCE, 150);
   ObjectCreate("klc24", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc24", "Profit :: " + DoubleToStr(AccountProfit(), 2), 20, "Browallia New", Gold);
   ObjectSet("klc24", OBJPROP_CORNER, 1);
   ObjectSet("klc24", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc24", OBJPROP_YDISTANCE, 180);
   ObjectCreate("klc25", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc25", "OrdersTotal :: " + OrdersTotal(), 20, "Browallia New", Gold);
   ObjectSet("klc25", OBJPROP_CORNER, 1);
   ObjectSet("klc25", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc25", OBJPROP_YDISTANCE, 210);
   ObjectCreate("klc26", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("klc26", "Timeserver :: " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES), 20, "Browallia New", Gold);
   ObjectSet("klc26", OBJPROP_CORNER, 1);
   ObjectSet("klc26", OBJPROP_XDISTANCE, 10);
   ObjectSet("klc26", OBJPROP_YDISTANCE, 240);
}
