/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h ttp: //W w w . M E t A qUOteS . NeT
   E-mail : sU p p O RT@m e t a qu oT ES .N e t
*/

extern int Magic = 111;
extern bool CloseAllNow = FALSE;
extern string moneymanagement = "Money Management";
extern double BuyLots = 0.1;
extern double SellLots = 0.1;
extern bool MM = FALSE;
extern double BuyRisk = 2.0;
extern double SellRisk = 2.0;
int Gi_128 = 1;
extern double MinLot = 0.1;
extern double MaxLot = 1.0;
extern int LotDigits = 2;
extern string ordersmanagement = "Order Management";
extern int StopLoss = 0;
extern int TakeProfit = 30;
extern bool ConstantStop = FALSE;
extern int Step1 = 30;
extern int TP1 = 30;
extern double Multiplier1 = 2.0;
extern int Step2 = 30;
extern int TP2 = 30;
extern double Multiplier2 = 2.0;
extern int Step3 = 30;
extern int TP3 = 30;
extern double Multiplier3 = 2.0;
extern int Step4 = 30;
extern int TP4 = 30;
extern double Multiplier4 = 2.0;
extern int Step5 = 30;
extern int TP5 = 30;
extern double Multiplier5 = 2.0;
extern int Step6 = 30;
extern int TP6 = 30;
extern double Multiplier6 = 2.0;
extern int Step7 = 30;
extern int TP7 = 30;
extern double Multiplier7 = 2.0;
extern int Step8 = 30;
extern int TP8 = 30;
extern double Multiplier8 = 2.0;
extern int Step9 = 30;
extern int TP9 = 30;
extern double Multiplier9 = 2.0;
extern int Step10 = 30;
extern int TP10 = 30;
extern double Multiplier10 = 2.0;
extern int Step11 = 30;
extern int TP11 = 30;
extern double Multiplier11 = 2.0;
extern int Step12 = 30;
extern int TP12 = 30;
extern double Multiplier12 = 2.0;
extern int Step13 = 30;
extern int TP13 = 30;
extern double Multiplier13 = 2.0;
extern int Step14 = 30;
extern int TP14 = 30;
extern double Multiplier14 = 2.0;
extern int Step15 = 30;
extern int TP15 = 30;
extern double Multiplier15 = 2.0;
extern int Step16 = 30;
extern int TP16 = 30;
extern double Multiplier16 = 2.0;
extern int Step17 = 30;
extern int TP17 = 30;
extern double Multiplier17 = 2.0;
extern int Step18 = 30;
extern int TP18 = 30;
extern double Multiplier18 = 2.0;
extern int Step19 = 30;
extern int TP19 = 30;
extern double Multiplier19 = 2.0;
extern int Step20 = 30;
extern int TP20 = 30;
extern double Multiplier20 = 2.0;
extern int Slippage = 3;
extern string entrylogics = "Entry Settins";
extern bool UseMACD = FALSE;
extern int MACDFast = 14;
extern int MACDSlow = 26;
extern int MACDSMA = 9;
extern string timefilter = "Time Filter";
extern int StartHour = 0;
extern int EndHour = 24;
extern int FridayCloseTime = 20;
double Gd_540;
double Gd_548;
double G_price_556;
double G_price_564;
double G_lots_572;
double G_price_580;
double Gd_588;
double Gd_596;
int G_order_total_604;
int G_digits_608;
int Gi_612;
int G_ticket_616;
bool G_bool_620;

int init() {
   G_digits_608 = Digits;
   if (G_digits_608 == 3 || G_digits_608 == 5) {
      Gd_540 = 10.0 * Point;
      Gd_548 = 10;
   } else {
      Gd_540 = Point;
      Gd_548 = 1;
   }
   return (1);
}

int start() {
   if (count(OP_BUY) + count(OP_SELL) == 0) {
      BuyLots = NormalizeDouble(AccountBalance() / 1000.0 / 100.0 * BuyRisk, LotDigits);
      SellLots = NormalizeDouble(AccountBalance() / 1000.0 / 100.0 * SellRisk, LotDigits);
      if (BuyLots < MinLot) BuyLots = MinLot;
      if (SellLots < MinLot) SellLots = MinLot;
      if (BuyLots > MaxLot) BuyLots = MaxLot;
      if (SellLots > MaxLot) SellLots = MaxLot;
   }
   if (CloseAllNow == TRUE) {
      for (G_order_total_604 = OrdersTotal(); G_order_total_604 >= 0; G_order_total_604--) {
         OrderSelect(G_order_total_604, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() || Gi_128 == 3 && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
            if (OrderType() != OP_BUY && OrderType() != OP_SELL) OrderDelete(OrderTicket());
         }
      }
      return (0);
   }
   int ticket_0 = 0;
   int ticket_4 = 0;
   int ticket_8 = 0;
   int ticket_12 = 0;
   double order_lots_16 = 0;
   double order_lots_24 = 0;
   double order_lots_32 = 0;
   double order_lots_40 = 0;
   double order_lots_48 = 0;
   double order_lots_56 = 0;
   double order_open_price_64 = 0;
   double order_open_price_72 = 0;
   double Ld_80 = 0;
   double Ld_88 = 0;
   double Ld_96 = 0;
   double Ld_104 = 0;
   string Ls_112 = "";
   string Ls_120 = "";
   string Ls_128 = "";
   string Ls_136 = "";
   string Ls_144 = "";
   string Ls_152 = "";
   string Ls_160 = "";
   string Ls_168 = "";
   string Ls_176 = "";
   if (iMACD(NULL, 0, MACDFast, MACDSlow, MACDSMA, PRICE_CLOSE, MODE_MAIN, 0) > iMACD(NULL, 0, MACDFast, MACDSlow, MACDSMA, PRICE_CLOSE, MODE_MAIN, 1)) Gi_612 = 2;
   if (iMACD(NULL, 0, MACDFast, MACDSlow, MACDSMA, PRICE_CLOSE, MODE_MAIN, 0) < iMACD(NULL, 0, MACDFast, MACDSlow, MACDSMA, PRICE_CLOSE, MODE_MAIN, 1)) Gi_612 = 1;
   for (G_order_total_604 = 0; G_order_total_604 < OrdersTotal(); G_order_total_604++) {
      OrderSelect(G_order_total_604, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() || Gi_128 == 3 && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY && ticket_0 < OrderTicket()) {
            order_lots_16 = OrderLots();
            order_open_price_64 = OrderOpenPrice();
            ticket_0 = OrderTicket();
            Ld_88 = OrderTakeProfit();
         }
         if (OrderType() == OP_BUY) {
            if (OrderLots() < order_lots_48 || order_lots_48 == 0.0) {
               order_lots_48 = OrderLots();
               Ld_96 = OrderOpenPrice() - StopLoss * Gd_540;
            }
         }
         if (OrderType() == OP_SELL && ticket_4 < OrderTicket()) {
            order_lots_24 = OrderLots();
            order_open_price_72 = OrderOpenPrice();
            ticket_4 = OrderTicket();
            Ld_80 = OrderTakeProfit();
         }
         if (OrderType() == OP_SELL) {
            if (OrderLots() < order_lots_56 || order_lots_56 == 0.0) {
               order_lots_56 = OrderLots();
               Ld_104 = OrderOpenPrice() + StopLoss * Gd_540;
            }
         }
         if (OrderType() == OP_BUYLIMIT) {
            ticket_8 = OrderTicket();
            order_lots_32 = OrderLots();
         }
         if (OrderType() == OP_SELLLIMIT) {
            ticket_12 = OrderTicket();
            order_lots_40 = OrderLots();
         }
      }
   }
   if (ticket_0 == 0 && ticket_8 != 0) OrderDelete(ticket_8);
   if (ticket_0 == 0 && ticket_8 == 0) {
      G_price_556 = Ask - StopLoss * Gd_540;
      if (StopLoss <= 0) G_price_556 = 0;
      G_price_564 = Ask + TakeProfit * Gd_540;
      if ((StartHour < EndHour && TimeHour(TimeCurrent()) >= StartHour && TimeHour(TimeCurrent()) < EndHour) || (StartHour > EndHour && TimeHour(TimeCurrent()) >= StartHour ||
         TimeHour(TimeCurrent()) < EndHour)) {
         if (DayOfWeek() != 5 || Hour() < FridayCloseTime) {
            if ((Gi_612 == 2 && ticket_4 == 0) || UseMACD == FALSE) {
               if (AccountFreeMarginCheck(Symbol(), OP_BUY, BuyLots) >= 0.0) {
                  if (Gi_128 != 2 && Gi_128 != 3) OrderSend(Symbol(), OP_BUY, BuyLots, Ask, Slippage * Gd_548, G_price_556, G_price_564, "", Magic, 0, CLR_NONE);
                  else {
                     G_ticket_616 = OrderSend(Symbol(), OP_BUY, BuyLots, Ask, Slippage * Gd_548, 0, 0, "", Magic, 0, CLR_NONE);
                     G_bool_620 = OrderModify(G_ticket_616, OrderOpenPrice(), G_price_556, G_price_564, 0, CLR_NONE);
                     if (G_bool_620 == FALSE) Print("Error modifying BUY order : ", GetLastError());
                  }
               } else {
                  if (AccountFreeMarginCheck(Symbol(), OP_BUY, BuyLots) >= 0.0) Ls_176 = "we recommend you to decrease your start lot or increase deposit";
                  else Ls_128 = "BUY," + DoubleToStr(BuyLots, 2) + " lots. ";
               }
            }
         }
      }
   }
   if (ticket_4 == 0 && ticket_12 != 0) OrderDelete(ticket_12);
   if (ticket_4 == 0 && ticket_12 == 0) {
      G_price_556 = Bid + StopLoss * Gd_540;
      if (StopLoss <= 0) G_price_556 = 0;
      G_price_564 = Bid - TakeProfit * Gd_540;
      if ((StartHour < EndHour && TimeHour(TimeCurrent()) >= StartHour && TimeHour(TimeCurrent()) < EndHour) || (StartHour > EndHour && TimeHour(TimeCurrent()) >= StartHour ||
         TimeHour(TimeCurrent()) < EndHour)) {
         if (DayOfWeek() != 5 || Hour() < FridayCloseTime) {
            if ((Gi_612 == 1 && ticket_0 == 0) || UseMACD == FALSE) {
               if (AccountFreeMarginCheck(Symbol(), OP_SELL, SellLots) >= 0.0) {
                  if (Gi_128 != 2 && Gi_128 != 3) OrderSend(Symbol(), OP_SELL, SellLots, Bid, Slippage * Gd_548, G_price_556, G_price_564, "", Magic, 0, CLR_NONE);
                  else {
                     G_ticket_616 = OrderSend(Symbol(), OP_SELL, SellLots, Bid, Slippage * Gd_548, 0, 0, "", Magic, 0, CLR_NONE);
                     G_bool_620 = OrderModify(G_ticket_616, OrderOpenPrice(), G_price_556, G_price_564, 0, CLR_NONE);
                     if (G_bool_620 == FALSE) Print("Error modifying SELL order : ", GetLastError());
                  }
               } else {
                  if (AccountFreeMarginCheck(Symbol(), OP_SELL, SellLots) >= 0.0) Ls_176 = "we recommend you to decrease your start lot or increase deposit";
                  else Ls_136 = "SELL," + DoubleToStr(SellLots, 2) + " lots. ";
               }
            }
         }
      }
   }
   if (ticket_0 != 0 && ticket_8 != 0) {
      if (AccountFreeMarginCheck(Symbol(), OP_BUY, order_lots_32) < 0.0) {
         Ls_160 = "BUYLIMIT," + DoubleToStr(order_lots_32, 2) + " lots. ";
         OrderDelete(ticket_8);
      }
   }
   if (ticket_0 != 0 && ticket_8 == 0) {
      if (AccountFreeMarginCheck(Symbol(), OP_BUY, FinalMultiplier(NormalizeDouble(order_lots_16 / order_lots_48, 0)) * order_lots_16) >= 0.0) {
         Gd_596 = FinalStep(NormalizeDouble(order_lots_16 / order_lots_48, 0));
         Gd_588 = FinalTP(NormalizeDouble(order_lots_16 / order_lots_48, 0));
         G_price_580 = order_open_price_64 - Gd_596 * Gd_540;
         if (ConstantStop == FALSE) G_price_556 = G_price_580 - StopLoss * Gd_540;
         else G_price_556 = Ld_96;
         if (StopLoss <= 0) G_price_556 = 0;
         G_price_564 = G_price_580 + Gd_588 * Gd_540;
         G_lots_572 = NormalizeDouble(FinalMultiplier(NormalizeDouble(order_lots_16 / order_lots_48, 0)) * order_lots_16, LotDigits);
         OrderSend(Symbol(), OP_BUYLIMIT, G_lots_572, G_price_580, Slippage * Gd_548, G_price_556, G_price_564, "", Magic, 0, CLR_NONE);
      } else Ls_144 = "BUYLIMIT," + DoubleToStr(2.0 * order_lots_16, 2) + " lots. ";
   }
   if (ticket_4 != 0 && ticket_12 != 0) {
      if (AccountFreeMarginCheck(Symbol(), OP_SELL, order_lots_40) < 0.0) {
         Ls_168 = "SELLLIMIT," + DoubleToStr(order_lots_40, 2) + " lots. ";
         OrderDelete(ticket_12);
      }
   }
   if (ticket_4 != 0 && ticket_12 == 0) {
      if (AccountFreeMarginCheck(Symbol(), OP_SELL, FinalMultiplier(NormalizeDouble(order_lots_24 / order_lots_56, 0)) * order_lots_24) >= 0.0) {
         Gd_596 = FinalStep(NormalizeDouble(order_lots_24 / order_lots_56, 0));
         Gd_588 = FinalTP(NormalizeDouble(order_lots_24 / order_lots_56, 0));
         G_price_580 = order_open_price_72 + Gd_596 * Gd_540;
         if (ConstantStop == FALSE) G_price_556 = G_price_580 + StopLoss * Gd_540;
         else G_price_556 = Ld_104;
         if (StopLoss <= 0) G_price_556 = 0;
         G_price_564 = G_price_580 - Gd_588 * Gd_540;
         G_lots_572 = NormalizeDouble(FinalMultiplier(NormalizeDouble(order_lots_24 / order_lots_56, 0)) * order_lots_24, LotDigits);
         OrderSend(Symbol(), OP_SELLLIMIT, G_lots_572, G_price_580, Slippage * Gd_548, G_price_556, G_price_564, "", Magic, 0, CLR_NONE);
      } else Ls_152 = "SELLLIMIT," + DoubleToStr(2.0 * order_lots_24, 2) + " lots. ";
   }
   for (G_order_total_604 = 0; G_order_total_604 < OrdersTotal(); G_order_total_604++) {
      OrderSelect(G_order_total_604, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() || Gi_128 == 3 && OrderType() == OP_BUY && ticket_0 != 0 && OrderMagicNumber() == Magic) {
         if (ConstantStop == FALSE) G_price_556 = order_open_price_64 - StopLoss * Gd_540;
         else G_price_556 = Ld_96;
         if (StopLoss <= 0) G_price_556 = 0;
         if (ticket_0 > OrderTicket()) G_price_564 = Ld_88;
         else G_price_564 = OrderTakeProfit();
         if (G_price_564 != OrderTakeProfit() || G_price_556 != OrderStopLoss()) OrderModify(OrderTicket(), OrderOpenPrice(), G_price_556, G_price_564, 0, CLR_NONE);
      }
      if (OrderSymbol() == Symbol() || Gi_128 == 3 && OrderType() == OP_SELL && ticket_4 != 0 && OrderMagicNumber() == Magic) {
         if (ConstantStop == FALSE) G_price_556 = order_open_price_72 + StopLoss * Gd_540;
         else G_price_556 = Ld_104;
         if (StopLoss <= 0) G_price_556 = 0;
         if (ticket_4 > OrderTicket()) G_price_564 = Ld_80;
         else G_price_564 = OrderTakeProfit();
         if (G_price_564 != OrderTakeProfit() || G_price_556 != OrderStopLoss()) OrderModify(OrderTicket(), OrderOpenPrice(), G_price_556, G_price_564, 0, CLR_NONE);
      }
   }
   if (Ls_128 != "" || Ls_136 != "" || Ls_144 != "" || Ls_152 != "" || Ls_160 != "" || Ls_168 != "") Ls_112 = "Not enough margin for opening orders: ";
   Comment(Ls_120, 
      "\n", Ls_112, Ls_128, Ls_136, Ls_144, Ls_152, Ls_160, Ls_168, 
   "\n", Ls_176);
   return (0);
}

double FinalMultiplier(double Ad_0) {
   switch (Ad_0) {
   case 1.0:
      return (Multiplier1);
   case 2.0:
      return (Multiplier2);
   case 4.0:
      return (Multiplier3);
   case 8.0:
      return (Multiplier4);
   case 16.0:
      return (Multiplier5);
   case 32.0:
      return (Multiplier6);
   case 64.0:
      return (Multiplier7);
   case 128.0:
      return (Multiplier8);
   case 256.0:
      return (Multiplier9);
   case 512.0:
      return (Multiplier10);
   case 1024.0:
      return (Multiplier11);
   case 2048.0:
      return (Multiplier12);
   case 4096.0:
      return (Multiplier13);
   case 8192.0:
      return (Multiplier14);
   case 16384.0:
      return (Multiplier15);
   case 32768.0:
      return (Multiplier16);
   case 65536.0:
      return (Multiplier17);
   case 131072.0:
      return (Multiplier18);
   case 262144.0:
      return (Multiplier19);
   case 524288.0:
      return (Multiplier20);
   }
   return (Step20);
}

int FinalStep(double Ad_0) {
   switch (Ad_0) {
   case 1.0:
      return (Step1);
   case 2.0:
      return (Step2);
   case 4.0:
      return (Step3);
   case 8.0:
      return (Step4);
   case 16.0:
      return (Step5);
   case 32.0:
      return (Step6);
   case 64.0:
      return (Step7);
   case 128.0:
      return (Step8);
   case 256.0:
      return (Step9);
   case 512.0:
      return (Step10);
   case 1024.0:
      return (Step11);
   case 2048.0:
      return (Step12);
   case 4096.0:
      return (Step13);
   case 8192.0:
      return (Step14);
   case 16384.0:
      return (Step15);
   case 32768.0:
      return (Step16);
   case 65536.0:
      return (Step17);
   case 131072.0:
      return (Step18);
   case 262144.0:
      return (Step19);
   case 524288.0:
      return (Step20);
   }
   return (Step20);
}

int FinalTP(double Ad_0) {
   switch (Ad_0) {
   case 1.0:
      return (TP1);
   case 2.0:
      return (TP2);
   case 4.0:
      return (TP3);
   case 8.0:
      return (TP4);
   case 16.0:
      return (TP5);
   case 32.0:
      return (TP6);
   case 64.0:
      return (TP7);
   case 128.0:
      return (TP8);
   case 256.0:
      return (TP9);
   case 512.0:
      return (TP10);
   case 1024.0:
      return (TP11);
   case 2048.0:
      return (TP12);
   case 4096.0:
      return (TP13);
   case 8192.0:
      return (TP14);
   case 16384.0:
      return (TP15);
   case 32768.0:
      return (TP16);
   case 65536.0:
      return (TP17);
   case 131072.0:
      return (TP18);
   case 262144.0:
      return (TP19);
   case 524288.0:
      return (TP20);
   }
   return (TP20);
}

int count(int A_cmd_0) {
   int count_4 = 0;
   if (OrdersTotal() > 0) {
      for (G_order_total_604 = OrdersTotal(); G_order_total_604 >= 0; G_order_total_604--) {
         OrderSelect(G_order_total_604, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == A_cmd_0 && OrderMagicNumber() == Magic) count_4++;
      }
      return (count_4);
   }
   return (0);
}
