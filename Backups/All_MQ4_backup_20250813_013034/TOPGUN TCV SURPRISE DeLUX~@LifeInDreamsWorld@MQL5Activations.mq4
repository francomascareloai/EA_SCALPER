/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: Ht t P: //W ww .M E T Aq u oteS.ne t
   E-mail :  S UpP o r T @ metA Quo tEs .Ne t
*/
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern string Program = "TOPGUN TCV SURPRISE DeLUX .·‡Ú";
extern string PAIR = "EURCHF,EURUSD,GBPUSD,USDCAD,NZDUSD";
extern string Rev = "555";
extern bool UseAutoLot = TRUE;
extern string œ¿–¿Ã≈“–€..ÀŒ“¿ = "#############################";
extern double Lots = 0.1;
extern double MaxLots = 1.0;
extern double MinLots = 0.01;
extern double MaximumRisk = 3.0;
extern bool Aggressive = TRUE;
extern int Nanpin1 = 3;
extern int Nanpin2 = 20;
extern string Œ¡Ÿ»≈..œ¿–¿Ã≈“–€ = "#############################";
extern int FTLOrderWaitingTime = 16;
extern int BuyLossPoint = 321;
extern int SellLossPoint = 317;
extern int LowToHigh = 512;
extern int hgt = 15;
extern int Slippage = 7;
extern string Ã¿√» ..ÕŒÃ≈–¿ = "#############################";
extern int MAGIC1 = 321031;
extern int MAGIC2 = 321034;
extern int MAGIC3 = 321037;
extern string “≈… œ–Œ‘»“..»..—“≈œ€ = "#############################";
extern int TP1 = 10;
extern int TP2 = 15;
extern int TP3 = 15;
extern int step1 = 20;
extern int step2 = 20;
extern string œ¿–¿Ã≈“–€..»Õƒ» ¿“Œ–Œ¬ = "#############################";
extern string S1 = "---------------- Bollinger Filter";
extern int bolPrd = 20;
extern double bolDev = 2.0;
extern int keltPrd = 10;
extern double keltFactor = 1.5;
extern int shift = 3;
extern string S2 = "---------------- Control Filter";
extern int period = 18;
extern double factor = 1.0;
extern string S3 = "---------------- Fractal Filter";
extern int TFfractal = 10;
extern string ƒ»¿œ¿«ŒÕ..“Œ–√Œ¬À» = "#############################";
extern int time = 1;
extern int Hourstarttime = 22;
extern int Hourstoptime = 21;
string Gs_332 = "TOPGUN TCV SURPRISE DeLUX .·‡Ú";
double Gd_340 = 0.01;
int Gi_unused_348;
int Gi_352 = 1;
int Gi_356 = 1;
int Gia_360[6] = {16711680, 255, 16711680, 255, 16711680, 255};
string Gs_364 = "lblfincp_";
extern bool audioAlert = FALSE;
extern bool Info = TRUE;
string Gs_unused_380 = "TOPGUN TCV SURPRISE DeLUX .·‡Ú";
int Gia_444[10] = {0, 1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
double G_minlot_448;
double G_maxlot_456;
double G_lotstep_464;
double G_lotsize_472;
bool Gi_488;
double Gd_492;
double Gd_500;
string G_text_508;
string G_dbl2str_516;
string G_dbl2str_524;
string G_dbl2str_532;
string G_dbl2str_540;
color G_color_548;
double G_ticksize_552;
double Gd_unused_560 = 0.0;
double Gd_unused_568 = 0.0;
int Gi_unused_612;
double Gd_616;
double Gd_624;
double Gda_632[];
double Gda_636[];
double Gda_640[];
double Gd_644;
double Gd_unused_652;
double G_point_660;

// D1F1DB447EF654C1839D0A416E1B4F67
double f0_7() {
   double Ld_ret_0;
   if (Digits == 5 || Digits == 3) Ld_ret_0 = 0.00001;
   else Ld_ret_0 = 0.0001;
   return (Ld_ret_0);
}

// F9A3F1FF83F305DEDD7E895750AF8C8C
int f0_11() {
   double Ld_ret_0;
   if (Digits == 5 || Digits == 3) Ld_ret_0 = 10;
   else Ld_ret_0 = 1;
   return (Ld_ret_0);
}

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gd_644 = f0_7();
   Gd_unused_652 = f0_11();
   G_point_660 = MarketInfo(Symbol(), MODE_POINT);
   Gd_624 = f0_12(period, shift) * factor;
   Gi_unused_348 = 1;
   int Li_unused_0 = 0;
   if (IsTesting() == TRUE) Gi_unused_348 = 1;
   Gi_488 = FALSE;
   G_ticksize_552 = MarketInfo(Symbol(), MODE_TICKSIZE);
   if (Info) {
      ObjectCreate("Lable1", OBJ_LABEL, 0, 0, 1.0);
      ObjectSet("Lable1", OBJPROP_CORNER, 2);
      ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
      ObjectSet("Lable1", OBJPROP_YDISTANCE, 11);
      G_text_508 = "TOPGUN TCV SURPRISE DeLUX .·‡Ú" + CharToStr(174) + "THE BEST";
      ObjectSetText("Lable1", G_text_508, 13, "Times New Roman", Blue);
   }
   Gi_unused_612 = MathLog(1 / MarketInfo(Symbol(), MODE_LOTSTEP)) / MathLog(10);
   G_minlot_448 = MarketInfo(Symbol(), MODE_MINLOT);
   G_maxlot_456 = MarketInfo(Symbol(), MODE_MAXLOT);
   G_lotstep_464 = MarketInfo(Symbol(), MODE_LOTSTEP);
   G_lotsize_472 = MarketInfo(Symbol(), MODE_LOTSIZE);
   if (Aggressive) {
      Gi_352 = Nanpin1;
      Gi_356 = Nanpin2;
   }
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_4 = OrderMagicNumber();
   if (Li_4 < 0) return (-1);
   if (Li_4 > 0) Li_4--;
   int Li_0 = Bars - Li_4;
   for (int Li_16 = 0; Li_16 < Li_0; Li_16++) Gda_636[Li_16] = iMA(NULL, 0, period, 0, MODE_SMA, PRICE_TYPICAL, Li_16);
   double Ld_8 = f0_12(period, Li_16) * factor;
   Gda_632[Li_16] = Gda_636[Li_16] + Ld_8;
   Gda_640[Li_16] = Gda_636[Li_16] - Ld_8;
   Gda_632[Li_16] = 1;
   Gda_636[Li_16] = 1;
   Gda_640[Li_16] = 1;
   if (Gi_488) return (0);
   if (Info) {
      if (Gd_500 >= 5.0 * (Gd_492 / 6.0)) G_color_548 = DodgerBlue;
      if (Gd_500 >= 4.0 * (Gd_492 / 6.0) && Gd_500 < 5.0 * (Gd_492 / 6.0)) G_color_548 = DeepSkyBlue;
      if (Gd_500 >= 3.0 * (Gd_492 / 6.0) && Gd_500 < 4.0 * (Gd_492 / 6.0)) G_color_548 = Gold;
      if (Gd_500 >= 2.0 * (Gd_492 / 6.0) && Gd_500 < 3.0 * (Gd_492 / 6.0)) G_color_548 = OrangeRed;
      if (Gd_500 >= Gd_492 / 6.0 && Gd_500 < 2.0 * (Gd_492 / 6.0)) G_color_548 = Crimson;
      if (Gd_500 < Gd_492 / 5.0) G_color_548 = Red;
      ObjectDelete("Lable4");
      ObjectCreate("Lable4", OBJ_LABEL, 0, 0, 1.0);
      ObjectSet("Lable4", OBJPROP_CORNER, 3);
      ObjectSet("Lable4", OBJPROP_XDISTANCE, 33);
      ObjectSet("Lable4", OBJPROP_YDISTANCE, 71);
      G_dbl2str_532 = DoubleToStr(AccountStopoutLevel(), 2);
      ObjectSetText("Lable4", "Stop Out         " + G_dbl2str_532 + "", 15, "Times New Roman", Lime);
      ObjectDelete("Lable2");
      ObjectCreate("Lable2", OBJ_LABEL, 0, 0, 1.0);
      ObjectSet("Lable2", OBJPROP_CORNER, 3);
      ObjectSet("Lable2", OBJPROP_XDISTANCE, 33);
      ObjectSet("Lable2", OBJPROP_YDISTANCE, 51);
      G_dbl2str_516 = DoubleToStr(AccountBalance(), 2);
      ObjectSetText("Lable2", "¡¿À¿Õ—     " + G_dbl2str_516 + "", 15, "Times New Roman", Lime);
      ObjectDelete("Lable3");
      ObjectCreate("Lable3", OBJ_LABEL, 0, 0, 1.0);
      ObjectSet("Lable3", OBJPROP_CORNER, 3);
      ObjectSet("Lable3", OBJPROP_XDISTANCE, 33);
      ObjectSet("Lable3", OBJPROP_YDISTANCE, 31);
      G_dbl2str_524 = DoubleToStr(AccountEquity(), 2);
      ObjectSetText("Lable3", "ŒÒÚ‡ÚÓÍ —Â‰ÒÚ‚     " + G_dbl2str_524 + "", 15, "Times New Roman", G_color_548);
      ObjectDelete("Lable5");
      ObjectCreate("Lable5", OBJ_LABEL, 0, 0, 1.0);
      ObjectSet("Lable5", OBJPROP_CORNER, 3);
      ObjectSet("Lable5", OBJPROP_XDISTANCE, 33);
      ObjectSet("Lable5", OBJPROP_YDISTANCE, 11);
      G_dbl2str_540 = DoubleToStr(AccountFreeMargin(), 2);
      ObjectSetText("Lable5", "—‚Ó·Ó‰Ì˚Â —Â‰ÒÚ‚‡      " + G_dbl2str_540 + "", 15, "Times New Roman", G_color_548);
      Gd_616 = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), 0);
      Comment("" 
         + "\n" 
         + "TOPGUN TCV SURPRISE DeLUX .·‡Ú" 
         + "\n" 
         + "________________________________" 
         + "\n" 
         + "¡ÓÍÂ:         " + AccountCompany() 
         + "\n" 
         + "¬ÂÏˇ ·ÓÍÂ‡:  " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) 
         + "\n" 
         + "________________________________" 
         + "\n" 
         + "ÕÓÏÂ Ò˜∏Ú        " + AccountNumber() 
         + "\n" 
         + "œÎÂ˜Ó:             " + AccountLeverage() 
         + "\n" 
         + "_______________________________" 
         + "\n" 
         + "¡‡Î‡ÌÒ:               " + DoubleToStr(AccountBalance(), 2) 
         + "\n" 
         + "—ÔÂ‰:                " + DoubleToStr(Gd_616, 2) 
         + "\n" 
      + "_______________________________");
   }
   Gd_340 = f0_10();
   double Ld_20 = iATR(NULL, 0, keltPrd, shift) * keltFactor;
   double istddev_28 = iStdDev(NULL, 0, bolPrd, 0, MODE_SMA, PRICE_CLOSE, shift);
   double Ld_36 = bolDev * istddev_28 / Ld_20;
   if (UseAutoLot) Lots = f0_10();
   if ((!IsOptimization()) && (!IsTesting()) && (!IsVisualMode())) {
      f0_6();
      f0_4();
   }
   double Ld_44 = 0;
   double Ld_52 = NormalizeDouble(Ask, Digits);
   double Ld_60 = NormalizeDouble(Bid, Digits);
   double maxlot_68 = MarketInfo(Symbol(), MODE_MAXLOT);
   double ibands_76 = iBands(NULL, 0, keltPrd, bolDev, keltFactor, PRICE_MEDIAN, MODE_UPPER, shift);
   double ibands_84 = iBands(NULL, 0, keltPrd, bolDev, keltFactor, PRICE_MEDIAN, MODE_LOWER, shift);
   Gda_636[shift] = iMA(NULL, 0, period, 0, MODE_SMA, PRICE_TYPICAL, shift);
   Ld_20 = 1;
   istddev_28 = 1;
   Ld_36 = 1;
   Gda_636[shift] = 1;
   double irvi_92 = iRVI(NULL, PERIOD_M15, 12, MODE_MAIN, shift);
   double ifractals_100 = iFractals(NULL, TFfractal, MODE_UPPER, 3);
   double Ld_108 = MathAbs(ibands_76 - ibands_84);
   if (iBands(NULL, 0, bolPrd, 2, 0, PRICE_LOW, MODE_LOWER, 0) > Low[0]) return (0);
   if (f0_0(0, MAGIC1) > 0.0 && f0_0(0, MAGIC2) == 0.0) {
      if (Ld_60 > f0_2(MAGIC1) + TP1 * Point) {
         while (Ld_60 < f0_8(Slippage, MAGIC1)) {
         }
      }
   } else {
      if (f0_0(1, MAGIC1) < 0.0 && f0_0(1, MAGIC2) == 0.0) {
         if (Ld_52 < f0_2(MAGIC1) - TP1 * Point) {
            while (Ld_52 < f0_8(Slippage, MAGIC1)) {
            }
         }
      }
   }
   if (f0_0(0, MAGIC2) > 0.0 && f0_0(0, MAGIC3) == 0.0) {
      if (Ld_60 > f0_2(MAGIC2) + TP2 * Point) {
         while (Ld_60 < f0_8(Slippage, MAGIC2)) {
         }
         while (Ld_60 < f0_8(Slippage, MAGIC1)) {
         }
      }
   } else {
      if (f0_0(1, MAGIC2) < 0.0 && f0_0(1, MAGIC3) == 0.0) {
         if (Ld_52 < f0_2(MAGIC2) - TP2 * Point) {
            while (Ld_52 < f0_8(Slippage, MAGIC2)) {
            }
            while (Ld_52 < f0_8(Slippage, MAGIC1)) {
            }
         }
      }
   }
   if (f0_0(0, MAGIC3) > 0.0) {
      if (Ld_60 > f0_2(MAGIC3) + TP3 * Point || Ld_60 < f0_2(MAGIC3) - BuyLossPoint * Point) {
         while (Ld_60 < f0_8(Slippage, MAGIC3)) {
         }
         while (Ld_60 < f0_8(Slippage, MAGIC2)) {
         }
         while (Ld_60 < f0_8(Slippage, MAGIC1)) {
         }
      }
   } else {
      if (f0_0(1, MAGIC3) < 0.0) {
         if (Ld_52 < f0_2(MAGIC3) - TP3 * Point || Ld_52 > f0_2(MAGIC3) + SellLossPoint * Point) {
            while (Ld_52 < f0_8(Slippage, MAGIC3)) {
            }
            while (Ld_52 < f0_8(Slippage, MAGIC2)) {
            }
            while (Ld_52 < f0_8(Slippage, MAGIC1)) {
            }
         }
      }
   }
   if (f0_9() == 1) {
      if (f0_0(6, MAGIC1) == 0.0) {
         if (Ld_108 >= hgt * Point) {
            for (Ld_44 = Lots; Ld_44 > maxlot_68; Ld_44 -= maxlot_68) {
               if (Ld_52 < ibands_84) f0_5(0, maxlot_68, Ld_52, Slippage, 0, 0, Gs_332, MAGIC1);
               if (Ld_60 > ibands_76) f0_5(1, maxlot_68, Ld_60, Slippage, 0, 0, Gs_332, MAGIC1);
            }
            if (Ld_52 < ibands_84) f0_5(0, Ld_44, Ld_52, Slippage, 0, 0, Gs_332, MAGIC1);
            if (Ld_60 > ibands_76) f0_5(1, Ld_44, Ld_60, Slippage, 0, 0, Gs_332, MAGIC1);
         }
      }
      if (f0_0(0, MAGIC2) == 0.0 && f0_0(0, MAGIC1) > 0.0) {
         if (Ld_52 < f0_2(MAGIC1) - step1 * Point) {
            for (Ld_44 = Lots * Gi_352; Ld_44 > maxlot_68; Ld_44 -= maxlot_68) f0_5(0, maxlot_68, Ld_52, Slippage, 0, 0, Gs_332, MAGIC2);
            f0_5(0, Ld_44, Ld_52, Slippage, 0, 0, Gs_332, MAGIC2);
         }
      } else {
         if (f0_0(1, MAGIC2) == 0.0 && f0_0(1, MAGIC1) < 0.0) {
            if (Ld_60 > f0_2(MAGIC1) + step1 * Point) {
               for (Ld_44 = Lots * Gi_352; Ld_44 > maxlot_68; Ld_44 -= maxlot_68) f0_5(1, maxlot_68, Ld_60, Slippage, 0, 0, Gs_332, MAGIC2);
               f0_5(1, Ld_44, Ld_60, Slippage, 0, 0, Gs_332, MAGIC2);
            }
         }
      }
      if (f0_0(0, MAGIC3) == 0.0 && f0_0(0, MAGIC2) > 0.0) {
         if (Ld_52 < f0_2(MAGIC2) - step2 * Point) {
            for (Ld_44 = Lots * Gi_356; Ld_44 > maxlot_68; Ld_44 -= maxlot_68) f0_5(0, maxlot_68, Ld_52, Slippage, 0, 0, Gs_332, MAGIC3);
            f0_5(0, Ld_44, Ld_52, Slippage, 0, 0, Gs_332, MAGIC3);
         }
      } else {
         if (f0_0(1, MAGIC3) == 0.0 && f0_0(1, MAGIC2) < 0.0) {
            if (Ld_60 > f0_2(MAGIC2) + step2 * Point) {
               for (Ld_44 = Lots * Gi_356; Ld_44 > maxlot_68; Ld_44 -= maxlot_68) f0_5(1, maxlot_68, Ld_60, Slippage, 0, 0, Gs_332, MAGIC3);
               f0_5(1, Ld_44, Ld_60, Slippage, 0, 0, Gs_332, MAGIC3);
            }
         }
      }
   }
   if (audioAlert == TRUE && shift == 0) PlaySound("alert.wav");
   return (0);
}

// EBFE91FAEB07FF5788FD1001AD46AE29
double f0_10() {
   double Ld_ret_0 = MaxLots;
   int hist_total_8 = OrdersHistoryTotal();
   int count_12 = 0;
   Ld_ret_0 = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 1250000.0, 1);
   if (Ld_ret_0 < 0.1) Ld_ret_0 = 0.1;
   if (MinLots < 0.1 || Ld_ret_0 < 0.1) {
      Ld_ret_0 = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 125000.0, 2);
      if (Ld_ret_0 < 0.01) Ld_ret_0 = 0.01;
   }
   for (int pos_16 = hist_total_8 - 1; pos_16 >= 0; pos_16--) {
      if (OrderSelect(pos_16, SELECT_BY_POS, MODE_HISTORY) == FALSE) {
         Print("Error in history!");
         break;
      }
      if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
      if (OrderProfit() > 0.0) break;
      if (OrderProfit() < 0.0) count_12++;
   }
   if (count_12 > 1) Ld_ret_0 = NormalizeDouble(Ld_ret_0 - Ld_ret_0 * count_12, 1);
   if (Ld_ret_0 < MinLots) Ld_ret_0 = MinLots;
   if (Ld_ret_0 > MaxLots) Ld_ret_0 = MaxLots;
   if (!UseAutoLot) Ld_ret_0 = MaxLots;
   return (Ld_ret_0);
}

// 8ADA62867827EF528EC1678A05C0C9E0
double f0_2(int A_magic_0) {
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS) == FALSE) break;
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != A_magic_0) continue;
      if (OrderType() != OP_BUY && OrderType() != OP_SELL) continue;
      return (OrderOpenPrice());
   }
   return (0);
}

// 1DD737E00CF8A2F7B3CBB48C6EF47832
double f0_0(int Ai_0, int A_magic_4) {
   double Ld_ret_8 = 0.0;
   for (int pos_16 = 0; pos_16 < OrdersTotal(); pos_16++) {
      if (OrderSelect(pos_16, SELECT_BY_POS) == FALSE) break;
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != A_magic_4) continue;
      switch (Ai_0) {
      case 0:
         if (OrderType() != OP_BUY) break;
         Ld_ret_8 += OrderLots();
         break;
      case 1:
         if (OrderType() != OP_SELL) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 2:
         if (OrderType() != OP_BUYLIMIT) break;
         Ld_ret_8 += OrderLots();
         break;
      case 3:
         if (OrderType() != OP_SELLLIMIT) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 4:
         if (OrderType() != OP_BUYSTOP) break;
         Ld_ret_8 += OrderLots();
         break;
      case 5:
         if (OrderType() != OP_SELLSTOP) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 6:
         if (OrderType() == OP_BUY) Ld_ret_8 += OrderLots();
         if (OrderType() != OP_SELL) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 7:
         if (OrderType() == OP_BUYLIMIT) Ld_ret_8 += OrderLots();
         if (OrderType() != OP_SELLLIMIT) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 8:
         if (OrderType() == OP_BUYSTOP) Ld_ret_8 += OrderLots();
         if (OrderType() != OP_SELLSTOP) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 9:
         if (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) Ld_ret_8 += OrderLots();
         if (!(OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 10:
         if (!(OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)) break;
         Ld_ret_8 += OrderLots();
         break;
      case 11:
         if (!(OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)) break;
         Ld_ret_8 -= OrderLots();
         break;
      case 12:
         if (OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) Ld_ret_8 += OrderLots();
         if (!(OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)) break;
         Ld_ret_8 -= OrderLots();
         break;
      default:
         Print("[CurrentOrdersError] : Illegal order type(" + Ai_0 + ")");
      }
   }
   return (Ld_ret_8);
}

// 544F76D66380655C79338C3174495F4B
int f0_1(int A_cmd_0, double A_lots_4, double A_price_12, int A_slippage_20, double A_price_24, double A_price_32, string A_comment_40, int A_magic_48) {
   int error_52;
   A_price_12 = NormalizeDouble(A_price_12, Digits);
   A_price_24 = NormalizeDouble(A_price_24, Digits);
   A_price_32 = NormalizeDouble(A_price_32, Digits);
   int Li_56 = GetTickCount();
   while (true) {
      if (GetTickCount() - Li_56 > 1000 * FTLOrderWaitingTime) {
         Alert("OrderSend timeout. Check the experts log.");
         return (0);
      }
      if (IsTradeAllowed() == TRUE) {
         RefreshRates();
         if (OrderSend(Symbol(), A_cmd_0, A_lots_4, A_price_12, A_slippage_20, A_price_24, A_price_32, A_comment_40, A_magic_48, 0, Gia_360[A_cmd_0]) != -1) return (1);
         error_52 = GetLastError();
         Print("[OrderSendError] : ", error_52, " ", error_52);
         if (error_52 == 129/* INVALID_PRICE */) Sleep(300);
         if (error_52 == 134/* NOT_ENOUGH_MONEY */) Sleep(3600);
         if (error_52 != 129/* INVALID_PRICE */) {
            if (error_52 != 130/* INVALID_STOPS */) {
            }
         }
      }
      Sleep(100);
   }
   return /*(WARN)*/;
}

// E41F7857807685B4AE26FAEF9F3641B7
int f0_8(int A_slippage_0, int A_magic_4) {
   int cmd_8;
   int error_12;
   int ticket_16 = 0;
   for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
      if (OrderSelect(pos_20, SELECT_BY_POS) == FALSE) break;
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != A_magic_4) continue;
      cmd_8 = OrderType();
      if (cmd_8 == OP_BUY || cmd_8 == OP_SELL) {
         ticket_16 = OrderTicket();
         break;
      }
   }
   if (ticket_16 == 0) return (0);
   int Li_24 = GetTickCount();
   while (true) {
      if (GetTickCount() - Li_24 > 1000 * FTLOrderWaitingTime) {
         Alert("OrderClose timeout. Check the experts log.");
         return (0);
      }
      if (IsTradeAllowed() == TRUE) {
         RefreshRates();
         if (OrderClose(ticket_16, OrderLots(), NormalizeDouble(OrderClosePrice(), Digits), A_slippage_0, Gia_360[cmd_8]) == 1) return (1);
         error_12 = GetLastError();
         Print("[OrderCloseError] : ", error_12, " ", error_12);
         if (error_12 == 129/* INVALID_PRICE */) Sleep(300);
         if (error_12 == 134/* NOT_ENOUGH_MONEY */) Sleep(3600);
         if (error_12 != 129/* INVALID_PRICE */) {
         }
      }
      Sleep(100);
   }
   return /*(WARN)*/;
}

// B2B503306846268EAE9ABDEC34FDC027
void f0_5(int Ai_0, double Ad_4, double Ad_12, int Ai_20, int Ai_24, int Ai_28, string As_32, int Ai_40) {
   int Li_44 = 1;
   if (Digits == 3 || Digits == 5) Li_44 = 10;
   Ai_20 *= Li_44;
   if (Ai_0 == 1 || Ai_0 == 3 || Ai_0 == 5) Li_44 = -1 * Li_44;
   double Ld_48 = 0;
   double Ld_56 = 0;
   if (Ai_24 > 0) Ld_48 = Ad_12 - Ai_24 * Point * Li_44;
   if (Ai_28 > 0) Ld_56 = Ad_12 + Ai_28 * Point * Li_44;
   f0_1(Ai_0, Ad_4, Ad_12, Ai_20, Ld_48, Ld_56, As_32, Ai_40);
}

// 97265C974964F68E43402B476A8AA8AB
void f0_4() {
   string name_0 = Gs_364 + "L_1";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 390);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
   }
   ObjectSetText(name_0, "TOPGUN TCV           ", 25, "Arial", Blue);
   name_0 = Gs_364 + "L_2";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(name_0, "     SURPRISE DeLUX", 15, "Arial", Red);
   name_0 = Gs_364 + "L_3";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 397);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_0, "       brother from the best", 12, "Arial", Gold);
   name_0 = Gs_364 + "L_4";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 57);
   }
   ObjectSetText(name_0, "     _____________________", 12, "Arial", Gray);
   name_0 = Gs_364 + "L_5";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_0, "     _____________________", 12, "Arial", Gray);
}

// 92106D273A87E0D4E98361E7DB777FFA
double f0_3(int Ai_0) {
   double Ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC1 || OrderMagicNumber() == MAGIC2 || OrderMagicNumber() == MAGIC3)
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, Ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, Ai_0) + 86400) Ld_ret_4 += OrderProfit();
   }
   return (Ld_ret_4);
}

// B53A5EDA65DD2C5C76918FE4BE35941D
void f0_6() {
   double Ld_0 = f0_3(0);
   string name_8 = Gs_364 + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, " ÒÂ„Ó‰Ìˇ: " + DoubleToStr(Ld_0, 2), 12, "Courier New", GreenYellow);
   Ld_0 = f0_3(1);
   name_8 = Gs_364 + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 30);
   }
   ObjectSetText(name_8, " ‚˜Â‡: " + DoubleToStr(Ld_0, 2), 12, "Courier New", GreenYellow);
   Ld_0 = f0_3(2);
   name_8 = Gs_364 + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 45);
   }
   ObjectSetText(name_8, "ÔÓÁ‡‚˜Â‡: " + DoubleToStr(Ld_0, 2), 12, "Courier New", GreenYellow);
   name_8 = Gs_364 + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_8, "lot: " + Gd_340, 12, "Courier New", Aqua);
}

// FD11F3C4F8AA91E2706477A9D1868C24
double f0_12(int Ai_0, int Ai_4) {
   double Ld_ret_8 = 0;
   for (int Li_16 = Ai_4; Li_16 < Ai_4 + Ai_0; Li_16++) Ld_ret_8 += High[Li_16] - Low[Li_16];
   Ld_ret_8 /= Ai_0;
   return (Ld_ret_8);
}

// EA8F0CD9EE5544453FA168DCDCE30DFF
int f0_9() {
   if ((Hour() >= 0 && Hour() <= Hourstoptime - 1) || (Hour() >= Hourstarttime && Hour() <= 23) && Hourstarttime > Hourstoptime) return (1);
   if (Hour() >= Hourstarttime && Hour() <= Hourstoptime - 1 && Hourstarttime < Hourstoptime) return (1);
   return (0);
}
