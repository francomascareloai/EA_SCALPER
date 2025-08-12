/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  HTtp: / /wWW .M etaq u o tEs . Ne t
   E-mail :  S UPp o R T @m eTaQ uO T ES.NE t
*/
#property link      "http://www.forexter.land.ru/indicators.htm"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 White
#property indicator_color2 Lime
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Green
#property indicator_color6 MediumVioletRed
#property indicator_color7 LimeGreen
#property indicator_color8 MediumVioletRed

int Gi_76 = 3;
extern int SRZZ = 60;
int Gi_84 = 20;
int Gi_88 = 21;
int Gi_92 = 3;
bool Gi_96 = FALSE;
int Gi_100 = 0;
double G_ibuf_104[];
double G_ibuf_108[];
double Gda_112[];
double Gda_116[];
double G_ibuf_120[];
double G_ibuf_124[];
double G_ibuf_128[];
double G_ibuf_132[];
int Gia_136[6] = {0, 0, 0, 0, 0, 0};
int Gia_140[5] = {0, 0, 0, 0, 0};
int Gi_144;
int Gi_148;
int Gi_152;
int Gi_156;
int Gi_160;
bool Gi_164 = TRUE;
int G_bars_168 = 0;

void MainCalculation(int Ai_0) {
   if (Bars - Ai_0 > Gi_76 + 1) SACalc(Ai_0);
   else Gda_112[Ai_0] = 0;
   if (Bars - Ai_0 > Gi_88 + Gi_76 + 2) {
      SMCalc(Ai_0);
      return;
   }
   Gda_116[Ai_0] = 0;
}

void SACalc(int Ai_0) {
   int Li_4;
   int count_8;
   int Li_12;
   int Li_16;
   double Ld_24;
   switch (Gi_100) {
   case 0:
      Gda_112[Ai_0] = iMA(NULL, 0, Gi_76 + 1, 0, MODE_LWMA, PRICE_CLOSE, Ai_0);
      break;
   case 1:
      Gda_112[Ai_0] = iMA(NULL, 0, Gi_76 + 1, 0, MODE_LWMA, PRICE_OPEN, Ai_0);
      break;
   case 4:
      Gda_112[Ai_0] = iMA(NULL, 0, Gi_76 + 1, 0, MODE_LWMA, PRICE_MEDIAN, Ai_0);
      break;
   case 5:
      Gda_112[Ai_0] = iMA(NULL, 0, Gi_76 + 1, 0, MODE_LWMA, PRICE_TYPICAL, Ai_0);
      break;
   case 6:
      Gda_112[Ai_0] = iMA(NULL, 0, Gi_76 + 1, 0, MODE_LWMA, PRICE_WEIGHTED, Ai_0);
      break;
   default:
      Gda_112[Ai_0] = iMA(NULL, 0, Gi_76 + 1, 0, MODE_LWMA, PRICE_OPEN, Ai_0);
   }
   for (int Li_20 = Ai_0 + Gi_76 + 2; Li_20 > Ai_0; Li_20--) {
      Ld_24 = 0.0;
      Li_4 = 0;
      count_8 = 0;
      Li_12 = Li_20 + Gi_76;
      Li_16 = Li_20 - Gi_76;
      if (Li_16 < Ai_0) Li_16 = Ai_0;
      while (Li_12 >= Li_20) {
         count_8++;
         Ld_24 += count_8 * SnakePrice(Li_12);
         Li_4 += count_8;
         Li_12--;
      }
      while (Li_12 >= Li_16) {
         count_8--;
         Ld_24 += count_8 * SnakePrice(Li_12);
         Li_4 += count_8;
         Li_12--;
      }
      Gda_112[Li_20] = Ld_24 / Li_4;
   }
}

double SnakePrice(int Ai_0) {
   switch (Gi_100) {
   case 0:
      return (Close[Ai_0]);
   case 1:
      return (Open[Ai_0]);
   case 4:
      return ((High[Ai_0] + Low[Ai_0]) / 2.0);
   case 5:
      return ((Close[Ai_0] + High[Ai_0] + Low[Ai_0]) / 3.0);
   case 6:
      return ((2.0 * Close[Ai_0] + High[Ai_0] + Low[Ai_0]) / 4.0);
   }
   return (Open[Ai_0]);
}

void SMCalc(int Ai_0) {
   double Ld_4;
   double Ld_12;
   for (int Li_20 = Ai_0 + Gi_76 + 2; Li_20 >= Ai_0; Li_20--) {
      Ld_4 = Gda_112[ArrayMaximum(Gda_112, Gi_88, Li_20)];
      Ld_12 = Gda_112[ArrayMinimum(Gda_112, Gi_88, Li_20)];
      Gda_116[Li_20] = ((Gi_92 + 2) * 2 * Gda_112[Li_20] - (Ld_4 + Ld_12)) / 2.0 / (Gi_92 + 1);
   }
}

void LZZCalc(int Ai_0) {
   int Li_8;
   int Li_12;
   int Li_16;
   int index_20;
   int Li_4 = Ai_0 - 1;
   int Li_24 = 0;
   int Li_28 = 0;
   while (Li_4 < Gi_144 && Li_16 == 0) {
      Li_4++;
      G_ibuf_108[Li_4] = 0;
      Li_8 = Li_4 - Gi_84;
      if (Li_8 < Ai_0) Li_8 = Ai_0;
      Li_12 = Li_4 + Gi_84;
      if (Li_4 == ArrayMinimum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
         Li_16 = -1;
         Li_24 = Li_4;
      }
      if (Li_4 == ArrayMaximum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
         Li_16 = 1;
         Li_28 = Li_4;
      }
   }
   if (Li_16 != 0) {
      index_20 = 0;
      if (Li_4 > Ai_0) {
         if (Gda_116[Li_4] > Gda_116[Ai_0]) {
            if (Li_16 == 1) {
               if (Li_4 >= Ai_0 + Gi_84 && index_20 < 5) {
                  index_20++;
                  Gia_136[index_20] = Li_4;
               }
               Li_28 = Li_4;
               G_ibuf_108[Li_4] = Gda_116[Li_4];
            }
         } else {
            if (Li_16 == -1) {
               if (Li_4 >= Ai_0 + Gi_84 && index_20 < 5) {
                  index_20++;
                  Gia_136[index_20] = Li_4;
               }
               Li_24 = Li_4;
               G_ibuf_108[Li_4] = Gda_116[Li_4];
            }
         }
      }
      if (Li_4 < Gi_160 || index_20 < 5) {
         while (true) {
            G_ibuf_108[Li_4] = 0;
            Li_8 = Li_4 - Gi_84;
            if (Li_8 < Ai_0) Li_8 = Ai_0;
            Li_12 = Li_4 + Gi_84;
            if (Li_4 == ArrayMinimum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
               if (Li_16 == -1 && Gda_116[Li_4] < Gda_116[Li_24]) {
                  if (Li_4 >= Ai_0 + Gi_84 && index_20 < 5) Gia_136[index_20] = Li_4;
                  G_ibuf_108[Li_24] = 0;
                  G_ibuf_108[Li_4] = Gda_116[Li_4];
                  Li_24 = Li_4;
               }
               if (Li_16 == 1) {
                  if (Li_4 >= Ai_0 + Gi_84 && index_20 < 5) {
                     index_20++;
                     Gia_136[index_20] = Li_4;
                  }
                  G_ibuf_108[Li_4] = Gda_116[Li_4];
                  Li_16 = -1;
                  Li_24 = Li_4;
               }
            }
            if (Li_4 == ArrayMaximum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
               if (Li_16 == 1 && Gda_116[Li_4] > Gda_116[Li_28]) {
                  if (Li_4 >= Ai_0 + Gi_84 && index_20 < 5) Gia_136[index_20] = Li_4;
                  G_ibuf_108[Li_28] = 0;
                  G_ibuf_108[Li_4] = Gda_116[Li_4];
                  Li_28 = Li_4;
               }
               if (Li_16 == -1) {
                  if (Li_4 >= Ai_0 + Gi_84 && index_20 < 5) {
                     index_20++;
                     Gia_136[index_20] = Li_4;
                  }
                  G_ibuf_108[Li_4] = Gda_116[Li_4];
                  Li_16 = 1;
                  Li_28 = Li_4;
               }
            }
            Li_4++;
            if (Li_4 > Gi_144) return;
            if (Li_4 < Gi_160 || index_20 < 5) continue;
            break;
         }
      }
      Gi_152 = Bars - Gia_136[5];
      G_ibuf_108[Ai_0] = Gda_116[Ai_0];
      return;
   }
}

void SZZCalc(int Ai_0) {
   int Li_8;
   int Li_12;
   int Li_16;
   int index_20;
   int Li_4 = Ai_0 - 1;
   int Li_24 = 0;
   int Li_28 = 0;
   while (Li_4 <= Gi_160 && Li_16 == 0) {
      Li_4++;
      G_ibuf_132[Li_4] = 0;
      G_ibuf_128[Li_4] = 0;
      G_ibuf_124[Li_4] = 0;
      G_ibuf_120[Li_4] = 0;
      G_ibuf_104[Li_4] = 0;
      Li_8 = Li_4 - SRZZ;
      if (Li_8 < Ai_0) Li_8 = Ai_0;
      Li_12 = Li_4 + SRZZ;
      if (Li_4 == ArrayMinimum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
         Li_16 = -1;
         Li_24 = Li_4;
      }
      if (Li_4 == ArrayMaximum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
         Li_16 = 1;
         Li_28 = Li_4;
      }
   }
   if (Li_16 != 0) {
      index_20 = 0;
      if (Li_4 > Ai_0) {
         if (Gda_116[Li_4] > Gda_116[Ai_0]) {
            if (Li_16 == 1) {
               if (Li_4 >= Ai_0 + SRZZ && index_20 < 4) {
                  index_20++;
                  Gia_140[index_20] = Li_4;
               }
               Li_28 = Li_4;
               G_ibuf_124[Li_4 - 1] = Open[Li_4 - 1];
            }
         } else {
            if (Li_16 == -1) {
               if (Li_4 >= Ai_0 + SRZZ && index_20 < 4) {
                  index_20++;
                  Gia_140[index_20] = Li_4;
               }
               Li_24 = Li_4;
               G_ibuf_120[Li_4 - 1] = Open[Li_4 - 1];
            }
         }
      }
      if (Li_4 <= Gi_160 || index_20 < 4) {
         while (true) {
            G_ibuf_132[Li_4] = 0;
            G_ibuf_128[Li_4] = 0;
            G_ibuf_124[Li_4] = 0;
            G_ibuf_120[Li_4] = 0;
            G_ibuf_104[Li_4] = 0;
            Li_8 = Li_4 - SRZZ;
            if (Li_8 < Ai_0) Li_8 = Ai_0;
            Li_12 = Li_4 + SRZZ;
            if (Li_4 == ArrayMinimum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
               if (Li_16 == -1 && Gda_116[Li_4] < Gda_116[Li_24]) {
                  if (Li_4 >= Ai_0 + SRZZ && index_20 < 4) Gia_140[index_20] = Li_4;
                  G_ibuf_120[Li_24 - 1] = 0;
                  G_ibuf_120[Li_4 - 1] = Open[Li_4 - 1];
                  Li_24 = Li_4;
               }
               if (Li_16 == 1) {
                  if (Li_4 >= Ai_0 + SRZZ && index_20 < 4) {
                     index_20++;
                     Gia_140[index_20] = Li_4;
                  }
                  G_ibuf_120[Li_4 - 1] = Open[Li_4 - 1];
                  Li_16 = -1;
                  Li_24 = Li_4;
               }
            }
            if (Li_4 == ArrayMaximum(Gda_116, Li_12 - Li_8 + 1, Li_8)) {
               if (Li_16 == 1 && Gda_116[Li_4] > Gda_116[Li_28]) {
                  if (Li_4 >= Ai_0 + SRZZ && index_20 < 4) Gia_140[index_20] = Li_4;
                  G_ibuf_124[Li_28 - 1] = 0;
                  G_ibuf_124[Li_4 - 1] = Open[Li_4 - 1];
                  Li_28 = Li_4;
               }
               if (Li_16 == -1) {
                  if (Li_4 >= Ai_0 + SRZZ && index_20 < 4) {
                     index_20++;
                     Gia_140[index_20] = Li_4;
                  }
                  G_ibuf_124[Li_4 - 1] = Open[Li_4 - 1];
                  Li_16 = 1;
                  Li_28 = Li_4;
               }
            }
            Li_4++;
            if (Li_4 > Gi_160) return;
            if (Li_4 <= Gi_160 || index_20 < 4) continue;
            break;
         }
      }
      Gi_148 = Bars - Gia_140[4];
      return;
   }
}

void ArrCalc() {
   int Li_8;
   int Li_16 = 0;
   for (int Li_0 = Gi_160; G_ibuf_108[Li_0] == 0.0; Li_0--) {
   }
   int Li_4 = Li_0;
   double Ld_20 = G_ibuf_108[Li_0];
   for (Li_0--; G_ibuf_108[Li_0] == 0.0; Li_0--) {
   }
   if (G_ibuf_108[Li_0] > Ld_20) Li_16 = 1;
   if (G_ibuf_108[Li_0] > 0.0 && G_ibuf_108[Li_0] < Ld_20) Li_16 = -1;
   Ld_20 = G_ibuf_108[Li_4];
   for (Li_0 = Li_4 - 1; Li_0 > 0; Li_0--) {
      if (G_ibuf_108[Li_0] > Ld_20) {
         Li_16 = -1;
         Ld_20 = G_ibuf_108[Li_0];
      }
      if (G_ibuf_108[Li_0] > 0.0 && G_ibuf_108[Li_0] < Ld_20) {
         Li_16 = 1;
         Ld_20 = G_ibuf_108[Li_0];
      }
      if (Li_16 > 0 && G_ibuf_124[Li_0] > 0.0) {
         G_ibuf_104[Li_0] = Open[Li_0];
         G_ibuf_124[Li_0] = 0;
      }
      if (Li_16 < 0 && G_ibuf_120[Li_0] > 0.0) {
         G_ibuf_104[Li_0] = Open[Li_0];
         G_ibuf_120[Li_0] = 0;
      }
      if (Li_16 > 0 && G_ibuf_120[Li_0] > 0.0) {
         if (Li_0 > 1) {
            Li_4 = Li_0 - 1;
            Li_8 = Li_4 - SRZZ + 1;
            if (Li_8 < 0) Li_8 = 0;
            for (int Li_12 = Li_4; Li_12 >= Li_8 && G_ibuf_124[Li_12] == 0.0; Li_12--) {
               G_ibuf_128[Li_12] = G_ibuf_120[Li_0];
               G_ibuf_132[Li_12] = 0;
            }
         }
         if (Li_0 == 1) G_ibuf_128[0] = G_ibuf_120[Li_0];
      }
      if (Li_16 < 0 && G_ibuf_124[Li_0] > 0.0) {
         if (Li_0 > 1) {
            Li_4 = Li_0 - 1;
            Li_8 = Li_4 - SRZZ + 1;
            if (Li_8 < 0) Li_8 = 0;
            for (Li_12 = Li_4; Li_12 >= Li_8 && G_ibuf_120[Li_12] == 0.0; Li_12--) {
               G_ibuf_132[Li_12] = G_ibuf_124[Li_0];
               G_ibuf_128[Li_12] = 0;
            }
         }
         if (Li_0 == 1) G_ibuf_132[0] = G_ibuf_124[Li_0];
      }
   }
}

void deinit() {
}

int init() {
   IndicatorBuffers(8);
   SetIndexBuffer(0, G_ibuf_104);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 5);
   SetIndexArrow(0, 167);
   SetIndexEmptyValue(0, 0.0);
   SetIndexBuffer(1, G_ibuf_108);
   if (Gi_96) {
      SetIndexStyle(1, DRAW_SECTION, EMPTY, 2);
      SetIndexEmptyValue(1, 0.0);
   } else SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(2, Gda_112);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(3, Gda_116);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(4, G_ibuf_120);
   SetIndexStyle(4, DRAW_ARROW, EMPTY, 3);
   SetIndexArrow(4, 104);
   SetIndexEmptyValue(4, 0.0);
   SetIndexBuffer(5, G_ibuf_124);
   SetIndexStyle(5, DRAW_ARROW, EMPTY, 3);
   SetIndexArrow(5, 104);
   SetIndexEmptyValue(5, 0.0);
   SetIndexBuffer(6, G_ibuf_128);
   SetIndexStyle(6, DRAW_ARROW, EMPTY, 3);
   SetIndexArrow(6, 104);
   SetIndexEmptyValue(6, 0.0);
   SetIndexBuffer(7, G_ibuf_132);
   SetIndexStyle(7, DRAW_ARROW, EMPTY, 3);
   SetIndexArrow(7, 104);
   SetIndexEmptyValue(7, 0.0);
   return (0);
}

int start() {
   int Li_0 = IndicatorCounted();
   if (Li_0 < 0) return (-1);
   if (Li_0 > 0) Li_0--;
   if (Gi_164 == TRUE) {
      if (Gi_76 < 2) Gi_76 = 2;
      if (Bars <= (Gi_84 + Gi_88 + Gi_76 + 2) * 2) return (-1);
      if (SRZZ <= Gi_76) SRZZ = Gi_76 + 1;
      Gi_144 = Bars - (Gi_84 + Gi_88 + Gi_76 + 2);
      Gi_160 = Gi_144;
      Gi_156 = Gi_160;
      G_bars_168 = Bars;
      Gi_164 = FALSE;
   }
   int Li_4 = Bars - Li_0;
   for (int Li_8 = Li_4; Li_8 >= 0; Li_8--) MainCalculation(Li_8);
   if (G_bars_168 != Bars) {
      Gi_156 = Bars - Gi_148;
      Gi_160 = Bars - Gi_152;
      G_bars_168 = Bars;
   }
   SZZCalc(0);
   LZZCalc(0);
   ArrCalc();
   return (0);
}
