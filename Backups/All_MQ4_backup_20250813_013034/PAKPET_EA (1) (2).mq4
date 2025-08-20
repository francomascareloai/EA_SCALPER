/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: H t TP: / / ww w. mE tAquOT E S.NE t
   E-mail :  su PP Or T @ M eTaquO tes . n eT
*/
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern string Nama_EA = "PAKPET_EA";
extern bool Trade_buy = TRUE;
extern bool Trade_sell = TRUE;
extern int Mulai_Jam = 23;
extern int Akhir_Jam = 7;
extern bool Tp_in_Money = TRUE;
extern double TP_in_money = 2.0;
extern int TP = 10;
extern int SL = 100;
extern double Lots = 0.1;
extern bool TrailingStop_ = TRUE;
extern int TrailingStop = 20;
extern int Magic = 69;
extern string Seting_MA = "Sembarang";
extern int Pereode_1 = 4;
extern int Pereode_2 = 4;
extern int Jarak_order = 35;
extern int Max_order = 10;
extern double DiMarti = 1.3;
extern string Seting_Donchian = "Sembarang";
extern int IPeriod = 20;
double Gd_184;
double Gd_192;
double Gd_200;
double Gd_208;
double Gd_216;
int Gi_224;
int Gi_228;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   if (Digits == 3 || Digits == 5) Gd_216 = 10.0 * Point;
   else Gd_216 = Point;
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_56;
   f0_8();
   if (TrailingStop_) f0_1();
   if (Tp_in_Money && TP_in_money <= f0_6()) {
      f0_4();
      f0_4();
   }
   double Ld_0 = iCustom(Symbol(), 0, "Donchian Bands", IPeriod, 0, 0);
   double Ld_8 = iCustom(Symbol(), 0, "Donchian Bands", IPeriod, 1, 0);
   double Ld_16 = iCustom(Symbol(), 0, "Donchian Bands", IPeriod, 2, 0);
   double Ld_24 = iMA(Symbol(), 0, Pereode_1, 0, MODE_SMA, PRICE_OPEN, 1);
   double Ld_32 = iMA(Symbol(), 0, Pereode_1, 0, MODE_SMA, PRICE_CLOSE, 1);
   double Ld_40 = iMA(Symbol(), 0, Pereode_2, 0, MODE_SMA, PRICE_OPEN, 2);
   double Ld_48 = iMA(Symbol(), 0, Pereode_2, 0, MODE_SMA, PRICE_CLOSE, 2);
   if (Ld_0 < Ask) Li_56 = 1;
   if (Ld_8 > Bid) Li_56 = 2;
   if (Ld_40 > Ld_48 && Ld_24 < Ld_32) Li_56 = 1;
   if (Ld_40 < Ld_48 && Ld_24 > Ld_32) Li_56 = 2;
   if (f0_0() == 1) {
      if (SL == 0) Gd_184 = 0;
      else Gd_184 = Ask - SL * Gd_216;
      if (SL == 0) Gd_200 = 0;
      else Gd_200 = Bid + SL * Gd_216;
      if (TP == 0) Gd_192 = 0;
      else Gd_192 = Ask + TP * Gd_216;
      if (TP == 0) Gd_208 = 0;
      else Gd_208 = Bid - TP * Gd_216;
      if (f0_3() == 1 && Gi_224 != Time[0] && f0_2(OP_SELL) == 0 && f0_2(OP_BUY) < Max_order && Trade_buy && Li_56 == 1) {
         OrderSend(Symbol(), OP_BUY, f0_5(OP_BUY), Ask, 3, Gd_184, Gd_192, Nama_EA, Magic, 0, Blue);
         Gi_224 = Time[0];
      }
      if (f0_3() == 2 && Gi_228 != Time[0] && f0_2(OP_BUY) == 0 && f0_2(OP_SELL) < Max_order && Trade_sell && Li_56 == 2) {
         OrderSend(Symbol(), OP_SELL, f0_5(OP_SELL), Bid, 3, Gd_200, Gd_208, Nama_EA, Magic, 0, Red);
         Gi_228 = Time[0];
      }
      if (f0_2(OP_BUY) == 0 && f0_2(OP_SELL) == 0 && Trade_buy && Li_56 == 2) OrderSend(Symbol(), OP_BUY, f0_7(Lots), Ask, 3, Gd_184, Gd_192, Nama_EA, Magic, 0, Blue);
      if (f0_2(OP_BUY) == 0 && f0_2(OP_SELL) == 0 && Trade_sell && Li_56 == 1) OrderSend(Symbol(), OP_SELL, f0_7(Lots), Bid, 3, Gd_200, Gd_208, Nama_EA, Magic, 0, Red);
   }
   return (0);
}

// 2E73ACE255DFC4B0C218919CDC64D695
int f0_0() {
   bool Li_0 = FALSE;
   if (Mulai_Jam > Akhir_Jam) {
      if (Hour() >= Mulai_Jam || Hour() < Akhir_Jam) Li_0 = TRUE;
   } else
      if (Hour() >= Mulai_Jam && Hour() < Akhir_Jam) Li_0 = TRUE;
   return (Li_0);
}

// 4B6F6F2833698A9F0EBA7887BD128E3F
int f0_2(int Ai_0) {
   int Li_4 = 0;
   for (int Li_8 = 0; Li_8 < OrdersTotal(); Li_8++) {
      OrderSelect(Li_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic || OrderType() != Ai_0) continue;
      Li_4++;
   }
   return (Li_4);
}

// C3938DD81FE1366E93D2E29A6FFE2005
double f0_7(double Ad_0) {
   double Ld_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   double Ld_16 = MarketInfo(Symbol(), MODE_MINLOT);
   double Ld_24 = MarketInfo(Symbol(), MODE_LOTSTEP);
   double Ld_32 = Ld_24 * NormalizeDouble(Ad_0 / Ld_24, 0);
   Ld_32 = MathMax(MathMin(Ld_8, Ld_32), Ld_16);
   return (Ld_32);
}

// 3EC0170BFBF7342AE15040BBA3800EBE
void f0_1() {
   for (int Li_0 = 0; Li_0 < OrdersTotal(); Li_0++) {
      OrderSelect(Li_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
      if (OrderType() == OP_BUY) {
         if (Bid - OrderOpenPrice() > Gd_216 * TrailingStop) {
            if (OrderStopLoss() < Bid - Gd_216 * TrailingStop || OrderStopLoss() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Gd_216 * TrailingStop, OrderTakeProfit(), 0, Green);
               return;
            }
         }
      }
      if (OrderType() == OP_SELL) {
         if (OrderOpenPrice() - Ask > Gd_216 * TrailingStop) {
            if (OrderStopLoss() > Ask + Gd_216 * TrailingStop || OrderStopLoss() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Gd_216 * TrailingStop, OrderTakeProfit(), 0, Red);
               return;
            }
         }
      }
   }
}

// 799B6F2C43F9E173C5420064357F04E6
void f0_4() {
   for (int Li_0 = OrdersTotal() - 1; Li_0 >= 0; Li_0--) {
      OrderSelect(Li_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
      if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      else {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3, CLR_NONE);
         else OrderClose(OrderTicket(), OrderLots(), Ask, 3, CLR_NONE);
      }
   }
}

// 9726255EEC083AA56DC0449A21B33190
double f0_6() {
   double Ld_0 = 0;
   for (int Li_8 = 0; Li_8 < OrdersTotal(); Li_8++) {
      OrderSelect(Li_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
      Ld_0 += OrderProfit();
   }
   return (Ld_0);
}

// 72517BF8E06592913EB950DEC195448C
int f0_3() {
   int Li_0;
   int Li_4;
   double Ld_8;
   double Ld_16;
   for (int Li_40 = 0; Li_40 < OrdersTotal(); Li_40++) {
      if (OrderSelect(Li_40, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
         Li_0 = OrderType();
         if (Li_0 == OP_BUY) Ld_8 = OrderOpenPrice();
         if (Li_0 == OP_SELL) Ld_16 = OrderOpenPrice();
      }
   }
   double Ld_44 = Ld_8 - Jarak_order * Gd_216;
   double Ld_52 = Ld_16 + Jarak_order * Gd_216;
   if (Ask <= Ld_44 && f0_2(OP_BUY) > 0) Li_4 = 1;
   if (Bid >= Ld_52 && f0_2(OP_SELL) > 0) Li_4 = 2;
   return (Li_4);
}

// 8EDEE252963BDE04BB752CA7343F6E74
double f0_5(int Ai_0) {
   double Ld_4;
   double Ld_12;
   for (int Li_20 = 0; Li_20 < OrdersTotal(); Li_20++) {
      if (OrderSelect(Li_20, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic || OrderType() != Ai_0) continue;
         Ld_12 = OrderLots();
      }
   }
   if (OrderType() == Ai_0) Ld_4 = f0_7(Lots * MathPow(DiMarti, f0_2(Ai_0)));
   return (Ld_4);
}

// D304BA20E96D87411588EEABAC850E34
void f0_8() {
   Comment("\n ", 
      "\n ", 
      "\n ------------------------------------------------", 
      "\n :: =>PAKPET_EA<=", 
      "\n :: =>NAMMYOHORENGEKYO<=", 
      "\n :: =>Donasi sukarela Rek.BCA 4620444915 Adi Putra Pratama<=", 
      "\n ------------------------------------------------", 
      "\n :: Spread                 : ", MarketInfo(Symbol(), MODE_SPREAD), 
      "\n :: Leverage               : 1 : ", AccountLeverage(), 
      "\n :: Equity                 : ", AccountEquity(), 
      "\n :: Jam Server             :", Hour(), ":", Minute(), 
      "\n ------------------------------------------------", 
      "\n :: >>pakpet<<", 
   "\n ------------------------------------------------");
}
