#property copyright "2024, SniperFx"
#property link      "http://snipfx.com"

extern string t0 = "Лоты 0-постоянный, 1- зависит от баланса";
extern int ModeLot = 1;
extern double LotPost = 1.0;
extern double LotProc = 1.0;
extern string t3 = "Система выхода из просадок";
extern int Level = 1;
extern double Max = 1.0;
extern double STOPmax = 1.0;
extern string t5 = "Настройки Трейлинг стопа";
extern int Tral = 150;
extern int TralStep = 1;
extern string t6 = "Настройки доливок";
extern double Lim = 1.0;
extern int Step = 350;
extern string t7 = "Настройки пар";
extern string P1 = "EURUSD";
extern string P2 = "GBPUSD";
extern string P3 = "USDCHF";
extern string P4 = "EURGBP";
extern string P5 = "USDCAD";
extern string P6 = "GBPCHF";
extern string P7 = "NZDUSD";
extern string t8 = "Мелкие настройки";
extern int Tf = 60;
extern int Slip = 100;
extern int Magic = 123;
extern string Name = "SEVENFX";
extern bool Info = TRUE;
int G_datetime_264 = 0;
int G_datetime_268 = 0;
int G_datetime_272 = 0;
int G_datetime_276 = 0;
int G_datetime_280 = 0;
int G_datetime_284 = 0;
int G_datetime_288 = 0;
int G_datetime_292 = 0;
int G_datetime_296 = 0;
int G_datetime_300 = 0;
int G_datetime_304 = 0;
int G_datetime_308 = 0;
int G_datetime_312 = 0;
int G_datetime_316 = 0;
int Gi_320;
double Gd_324;
double G_lots_332;
bool OrderSen;
bool OrderMod;
bool OrderClos;
bool OrderDel;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gi_320 = 1;
   if (Digits == 5 || Digits == 3) Gi_320 = 10;
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_8;
   double lots_0 = 0;
   if (ModeLot == 0) lots_0 = LotPost;
   if (ModeLot == 1) lots_0 = NormalizeDouble(AccountBalance() / 100.0 * LotProc / (100.0 * MarketInfo(Symbol(), MODE_TICKVALUE) * Gi_320), 2);
   if (lots_0 < MarketInfo(Symbol(), MODE_MINLOT)) lots_0 = MarketInfo(Symbol(), MODE_MINLOT);
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.01) Li_8 = 2;
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) Li_8 = 1;
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 1.0) Li_8 = 0;
   if (Info) {
      Comment("" 
         + "\n" 
         + "SEVENFX EA FXROBOT" 
         + "\n" 
         + "________________________________" 
         + "\n" 
         + "Broker:           " + AccountCompany() 
         + "\n" 
         + "Date/Time:      " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) 
         + "\n" 
         + "________________________________" 
         + "\n" 
         + "Account Name:          " + AccountName() 
         + "\n" 
         + "Account Number:        " + AccountNumber() 
         + "\n" 
         + "_______________________________" 
         + "\n" 
         + "Account Balance:        " + DoubleToStr(AccountBalance(), 2) 
         + "\n" 
         + "Account Equity:         " + DoubleToStr(AccountEquity(), 2) 
         + "\n" 
      + "_______________________________");
   }
   double Ld_12 = AccountBalance() / 100.0 * STOPmax;
   if (f0_1(-1) >= Ld_12 && Ld_12 != 0.0) f0_5(Magic, -1);
   Gd_324 = AccountBalance() / 100.0 * Max;
   f0_2();
   if (f0_8(-1, P1) > 1 && f0_4(-1, P1) == 0) f0_3(P1, -1);
   if (f0_8(-1, P2) > 1 && f0_4(-1, P2) == 0) f0_3(P2, -1);
   if (f0_8(-1, P3) > 1 && f0_4(-1, P3) == 0) f0_3(P3, -1);
   if (f0_8(-1, P4) > 1 && f0_4(-1, P4) == 0) f0_3(P4, -1);
   if (f0_8(-1, P5) > 1 && f0_4(-1, P5) == 0) f0_3(P5, -1);
   if (f0_8(-1, P6) > 1 && f0_4(-1, P6) == 0) f0_3(P6, -1);
   if (f0_8(-1, P7) > 1 && f0_4(-1, P7) == 0) f0_3(P7, -1);
   if (f0_8(-1, P1) == 1) f0_6(Magic, P1);
   if (f0_8(-1, P2) == 1) f0_6(Magic, P2);
   if (f0_8(-1, P3) == 1) f0_6(Magic, P3);
   if (f0_8(-1, P4) == 1) f0_6(Magic, P4);
   if (f0_8(-1, P5) == 1) f0_6(Magic, P5);
   if (f0_8(-1, P6) == 1) f0_6(Magic, P6);
   if (f0_8(-1, P7) == 1) f0_6(Magic, P7);
   if (G_datetime_264 != iTime(P1, Tf, 0)) {
      G_datetime_264 = iTime(P1, Tf, 0);
      if (f0_8(OP_BUY, P1) > 0 && NormalizeDouble(MarketInfo(P1, MODE_ASK) + Step * MarketInfo(P1, MODE_POINT), Digits) <= f0_7(P1)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_BUY, P1)) * lots_0, Li_8);
         OrderSen=OrderSend(P1, OP_BUY, G_lots_332, NormalizeDouble(MarketInfo(P1, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
      }
      if (f0_8(OP_SELL, P1) > 0 && NormalizeDouble(MarketInfo(P1, MODE_BID) - Step * MarketInfo(P1, MODE_POINT), Digits) >= f0_0(P1)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_SELL, P1)) * lots_0, Li_8);
         OrderSen=OrderSend(P1, OP_SELL, G_lots_332, NormalizeDouble(MarketInfo(P1, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_268 != iTime(P2, Tf, 0)) {
      G_datetime_268 = iTime(P2, Tf, 0);
      if (f0_8(OP_BUY, P2) > 0 && NormalizeDouble(MarketInfo(P2, MODE_ASK) + Step * MarketInfo(P2, MODE_POINT), Digits) <= f0_7(P2)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_BUY, P2)) * lots_0, Li_8);
         OrderSen=OrderSend(P2, OP_BUY, G_lots_332, NormalizeDouble(MarketInfo(P2, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
      }
      if (f0_8(OP_SELL, P2) > 0 && NormalizeDouble(MarketInfo(P2, MODE_BID) - Step * MarketInfo(P2, MODE_POINT), Digits) >= f0_0(P2)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_SELL, P2)) * lots_0, Li_8);
         OrderSen=OrderSend(P2, OP_SELL, G_lots_332, NormalizeDouble(MarketInfo(P2, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_272 != iTime(P3, Tf, 0)) {
      G_datetime_272 = iTime(P3, Tf, 0);
      if (f0_8(OP_BUY, P3) > 0 && NormalizeDouble(MarketInfo(P3, MODE_ASK) + Step * MarketInfo(P3, MODE_POINT), Digits) <= f0_7(P3)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_BUY, P3)) * lots_0, Li_8);
         OrderSen=OrderSend(P3, OP_BUY, G_lots_332, NormalizeDouble(MarketInfo(P3, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
      }
      if (f0_8(OP_SELL, P3) > 0 && NormalizeDouble(MarketInfo(P3, MODE_BID) - Step * MarketInfo(P3, MODE_POINT), Digits) >= f0_0(P3)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_SELL, P3)) * lots_0, Li_8);
         OrderSen=OrderSend(P3, OP_SELL, G_lots_332, NormalizeDouble(MarketInfo(P3, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_276 != iTime(P4, Tf, 0)) {
      G_datetime_276 = iTime(P4, Tf, 0);
      if (f0_8(OP_BUY, P4) > 0 && NormalizeDouble(MarketInfo(P4, MODE_ASK) + Step * MarketInfo(P4, MODE_POINT), Digits) <= f0_7(P4)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_BUY, P4)) * lots_0, Li_8);
         OrderSen=OrderSend(P4, OP_BUY, G_lots_332, NormalizeDouble(MarketInfo(P4, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
      }
      if (f0_8(OP_SELL, P4) > 0 && NormalizeDouble(MarketInfo(P4, MODE_BID) - Step * MarketInfo(P4, MODE_POINT), Digits) >= f0_0(P4)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_SELL, P4)) * lots_0, Li_8);
         OrderSen=OrderSend(P4, OP_SELL, G_lots_332, NormalizeDouble(MarketInfo(P4, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_280 != iTime(P5, Tf, 0)) {
      G_datetime_280 = iTime(P5, Tf, 0);
      if (f0_8(OP_BUY, P5) > 0 && NormalizeDouble(MarketInfo(P5, MODE_ASK) + Step * MarketInfo(P5, MODE_POINT), Digits) <= f0_7(P5)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_BUY, P5)) * lots_0, Li_8);
         OrderSen=OrderSend(P5, OP_BUY, G_lots_332, NormalizeDouble(MarketInfo(P5, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
      }
      if (f0_8(OP_SELL, P5) > 0 && NormalizeDouble(MarketInfo(P5, MODE_BID) - Step * MarketInfo(P5, MODE_POINT), Digits) >= f0_0(P5)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_SELL, P5)) * lots_0, Li_8);
         OrderSen=OrderSend(P5, OP_SELL, G_lots_332, NormalizeDouble(MarketInfo(P5, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_284 != iTime(P6, Tf, 0)) {
      G_datetime_284 = iTime(P6, Tf, 0);
      if (f0_8(OP_BUY, P6) > 0 && NormalizeDouble(MarketInfo(P6, MODE_ASK) + Step * MarketInfo(P6, MODE_POINT), Digits) <= f0_7(P6)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_BUY, P6)) * lots_0, Li_8);
         OrderSen=OrderSend(P6, OP_BUY, G_lots_332, NormalizeDouble(MarketInfo(P6, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
      }
      if (f0_8(OP_SELL, P6) > 0 && NormalizeDouble(MarketInfo(P6, MODE_BID) - Step * MarketInfo(P6, MODE_POINT), Digits) >= f0_0(P6)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_SELL, P6)) * lots_0, Li_8);
         OrderSen=OrderSend(P6, OP_SELL, G_lots_332, NormalizeDouble(MarketInfo(P6, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_288 != iTime(P7, Tf, 0)) {
      G_datetime_288 = iTime(P7, Tf, 0);
      if (f0_8(OP_BUY, P7) > 0 && NormalizeDouble(MarketInfo(P7, MODE_ASK) + Step * MarketInfo(P7, MODE_POINT), Digits) <= f0_7(P7)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_BUY, P7)) * lots_0, Li_8);
         OrderSen=OrderSend(P7, OP_BUY, G_lots_332, NormalizeDouble(MarketInfo(P7, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
      }
      if (f0_8(OP_SELL, P7) > 0 && NormalizeDouble(MarketInfo(P7, MODE_BID) - Step * MarketInfo(P7, MODE_POINT), Digits) >= f0_0(P7)) {
         G_lots_332 = NormalizeDouble(MathPow(Lim, f0_8(OP_SELL, P7)) * lots_0, Li_8);
         OrderSen=OrderSend(P7, OP_SELL, G_lots_332, NormalizeDouble(MarketInfo(P7, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_292 != iTime(P1, Tf, 0)) {
      G_datetime_292 = iTime(P1, Tf, 0);
      if (f0_8(-1, P1) == 0) {
         if (iMA(P1, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) < iMA(P1, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P1, OP_BUY, lots_0, NormalizeDouble(MarketInfo(P1, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
         if (iMA(P1, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) > iMA(P1, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P1, OP_SELL, lots_0, NormalizeDouble(MarketInfo(P1, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_296 != iTime(P2, Tf, 0)) {
      G_datetime_296 = iTime(P2, Tf, 0);
      if (f0_8(-1, P2) == 0) {
         if (iMA(P2, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) < iMA(P2, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P2, OP_BUY, lots_0, NormalizeDouble(MarketInfo(P2, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
         if (iMA(P2, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) > iMA(P2, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P2, OP_SELL, lots_0, NormalizeDouble(MarketInfo(P2, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_300 != iTime(P3, Tf, 0)) {
      G_datetime_300 = iTime(P3, Tf, 0);
      if (f0_8(-1, P3) == 0) {
         if (iMA(P3, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) < iMA(P3, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P3, OP_BUY, lots_0, NormalizeDouble(MarketInfo(P3, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
         if (iMA(P3, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) > iMA(P3, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P3, OP_SELL, lots_0, NormalizeDouble(MarketInfo(P3, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_304 != iTime(P4, Tf, 0)) {
      G_datetime_304 = iTime(P4, Tf, 0);
      if (f0_8(-1, P4) == 0) {
         if (iMA(P4, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) < iMA(P4, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P4, OP_BUY, lots_0, NormalizeDouble(MarketInfo(P4, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
         if (iMA(P4, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) > iMA(P4, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P4, OP_SELL, lots_0, NormalizeDouble(MarketInfo(P4, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_308 != iTime(P5, Tf, 0)) {
      G_datetime_308 = iTime(P5, Tf, 0);
      if (f0_8(-1, P5) == 0) {
         if (iMA(P5, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) < iMA(P5, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P5, OP_BUY, lots_0, NormalizeDouble(MarketInfo(P5, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
         if (iMA(P5, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) > iMA(P5, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P5, OP_SELL, lots_0, NormalizeDouble(MarketInfo(P5, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_312 != iTime(P6, Tf, 0)) {
      G_datetime_312 = iTime(P6, Tf, 0);
      if (f0_8(-1, P6) == 0) {
         if (iMA(P6, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) < iMA(P6, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P6, OP_BUY, lots_0, NormalizeDouble(MarketInfo(P6, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
         if (iMA(P6, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) > iMA(P6, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P6, OP_SELL, lots_0, NormalizeDouble(MarketInfo(P6, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   if (G_datetime_316 != iTime(P7, Tf, 0)) {
      G_datetime_316 = iTime(P7, Tf, 0);
      if (f0_8(-1, P7) == 0) {
         if (iMA(P7, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) < iMA(P7, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P7, OP_BUY, lots_0, NormalizeDouble(MarketInfo(P7, MODE_ASK), Digits), Slip, 0, 0, Name, Magic, 0, Green);
         if (iMA(P7, Tf, 1, 0, MODE_SMA, PRICE_OPEN, 1) > iMA(P7, Tf, 1, 0, MODE_SMA, PRICE_CLOSE, 1)) OrderSen=OrderSend(P7, OP_SELL, lots_0, NormalizeDouble(MarketInfo(P7, MODE_BID), Digits), Slip, 0, 0, Name, Magic, 0, Red);
      }
   }
   return (0);
}

// D518A06262AC68F1F006A4F802588130
void f0_6(int A_magic_0, string A_symbol_4) {
   double bid_12;
   double ask_20;
   double point_28;
   if (Tral != 0) {
      for (int pos_36 = 0; pos_36 < OrdersTotal(); pos_36++) {
         if (OrderSelect(pos_36, SELECT_BY_POS) && OrderSymbol() == A_symbol_4 && OrderMagicNumber() == A_magic_0) {
            point_28 = MarketInfo(OrderSymbol(), MODE_POINT);
            if (OrderType() == OP_BUY) {
               bid_12 = MarketInfo(OrderSymbol(), MODE_BID);
               if (bid_12 > MathMax(OrderOpenPrice(), OrderStopLoss()) + (Tral + TralStep) * point_28) OrderMod=OrderModify(OrderTicket(), OrderOpenPrice(), bid_12 - Tral * point_28, OrderTakeProfit(), 0);
            }
            if (OrderType() == OP_SELL) {
               ask_20 = MarketInfo(OrderSymbol(), MODE_ASK);
               if ((ask_20 < MathMin(OrderOpenPrice(), OrderStopLoss()) - (Tral + TralStep) * point_28 && OrderStopLoss() != 0.0) || (ask_20 < OrderOpenPrice() - (Tral + TralStep) * point_28 &&
                  OrderStopLoss() == 0.0)) OrderMod=OrderModify(OrderTicket(), OrderOpenPrice(), ask_20 + Tral * point_28, OrderTakeProfit(), 0);
            }
         }
      }
   }
}

// E93F994F01C537C4E2F7D8528C3EB5E9
int f0_8(int A_cmd_0, string A_symbol_4) {
   int count_12 = 0;
   for (int pos_16 = OrdersTotal() - 1; pos_16 >= 0; pos_16--) {
      if (OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == A_symbol_4 && OrderMagicNumber() == Magic && (A_cmd_0 == -1 || OrderType() == A_cmd_0)) count_12++;
   }
   return (count_12);
}

// A5AAA4B27A5599B39B0D126F25CB59B0
int f0_4(int A_cmd_0, string A_symbol_4) {
   int count_12 = 0;
   for (int pos_16 = OrdersTotal() - 1; pos_16 >= 0; pos_16--) {
      if (OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == A_symbol_4 && OrderMagicNumber() == Magic && OrderProfit() < 0.0 && (A_cmd_0 == -1 || OrderType() == A_cmd_0)) count_12++;
   }
   return (count_12);
}

// E5BC962349889A417D958FDD143C52EB
double f0_7(string A_symbol_0) {
   double order_open_price_8;
   int ticket_16;
   double Ld_unused_20 = 0;
   int ticket_28 = 0;
   for (int pos_32 = OrdersTotal() - 1; pos_32 >= 0; pos_32--) {
      if (OrderSelect(pos_32, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == A_symbol_0 && OrderMagicNumber() == Magic && OrderType() == OP_BUY) {
            ticket_16 = OrderTicket();
            if (ticket_16 > ticket_28) {
               ticket_28 = ticket_16;
               order_open_price_8 = OrderOpenPrice();
               Ld_unused_20 = order_open_price_8;
            }
         }
      }
   }
   return (order_open_price_8);
}

// 12DC9EEE437B57CADDDDEE0D0BEC703E
double f0_0(string A_symbol_0) {
   double order_open_price_8;
   int ticket_16;
   double Ld_unused_20 = 0;
   int ticket_28 = 0;
   for (int pos_32 = OrdersTotal() - 1; pos_32 >= 0; pos_32--) {
      if (OrderSelect(pos_32, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == A_symbol_0 && OrderMagicNumber() == Magic && OrderType() == OP_SELL) {
            ticket_16 = OrderTicket();
            if (ticket_16 > ticket_28) {
               ticket_28 = ticket_16;
               order_open_price_8 = OrderOpenPrice();
               Ld_unused_20 = order_open_price_8;
            }
         }
      }
   }
   return (order_open_price_8);
}

// 182875B6C36A761F1E459624C1D93638
double f0_1(int A_cmd_0) {
   double Ld_ret_4 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES))
         if (OrderMagicNumber() == Magic && (OrderType() == A_cmd_0 || A_cmd_0 == -1)) Ld_ret_4 += OrderProfit() + OrderSwap() + OrderCommission();
   }
   return (Ld_ret_4);
}

// AB47F9C0859692F35C72CBA160986AD1
void f0_5(int Ai_unused_0, int Ai_unused_4) {
   double price_8;
   double price_16;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY) {
            price_8 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID), Digits);
            OrderClos=OrderClose(OrderTicket(), OrderLots(), price_8, Slip, Black);
         }
         if (OrderType() == OP_SELL) {
            price_16 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK), Digits);
            OrderClos=OrderClose(OrderTicket(), OrderLots(), price_16, Slip, Black);
         }
         if (OrderType() == -1) OrderDel=OrderDelete(OrderTicket());
      }
   }
}

// 716F6B30598BA30945D84485E61C1027
void f0_3(string A_symbol_0, int Ai_unused_8) {
   double price_12;
   double price_20;
   for (int pos_28 = OrdersTotal() - 1; pos_28 >= 0; pos_28--) {
      if (OrderSelect(pos_28, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == A_symbol_0 && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY) {
            price_12 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID), Digits);
            OrderClos=OrderClose(OrderTicket(), OrderLots(), price_12, Slip, Black);
         }
         if (OrderType() == OP_SELL) {
            price_20 = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK), Digits);
            OrderClos=OrderClose(OrderTicket(), OrderLots(), price_20, Slip, Black);
         }
         if (OrderType() == -1) OrderDel=OrderDelete(OrderTicket());
      }
   }
}

// 3BF3C289E143CB942DE8E518ABA8038A
void f0_2() {
   int Li_4;
   int ticket_12;
   double Ld_36;
   double Ld_44;
   double Lda_52[][2];
   string symbol_56;
 //  string Ls_unused_64;
   int Li_16 = 0;
   double Ld_20 = 0;
   double Ld_unused_28 = 0;
   ArrayResize(Lda_52, 0);
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
            Ld_36 = NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(), 2);
            if (Ld_20 > Ld_36) {
               Ld_20 = Ld_36;
               ticket_12 = OrderTicket();
               symbol_56 = OrderSymbol();
            }
            if (Ld_36 > 0.0) {
               Li_4++;
               ArrayResize(Lda_52, Li_4);
               Lda_52[Li_4 - 1][0] = Ld_36;
               Lda_52[Li_4 - 1][1] = OrderTicket();
            }
         }
      }
   }
   ArraySort(Lda_52, WHOLE_ARRAY, Li_16, MODE_DESCEND);
   for (pos_0 = 0; pos_0 < Level; pos_0++) Ld_44 += Lda_52[pos_0][0];
   if (Ld_20 < 0.0 && Ld_44 + Ld_20 >= Gd_324) {
      for (pos_0 = 0; pos_0 < Level; pos_0++) {
         if (OrderSelect(Lda_52[pos_0][1], SELECT_BY_TICKET, MODE_TRADES)) {
            if (OrderType() == OP_BUY) OrderClos=OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slip, CLR_NONE);
            if (OrderType() == OP_SELL) OrderClos=OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slip, CLR_NONE);
         }
      }
      if (OrderSelect(ticket_12, SELECT_BY_TICKET, MODE_TRADES)) {
         if (OrderType() == OP_BUY) OrderClos=OrderClose(ticket_12, OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slip, CLR_NONE);
         if (OrderType() == OP_SELL) OrderClos=OrderClose(ticket_12, OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slip, CLR_NONE);
      }
   }
}