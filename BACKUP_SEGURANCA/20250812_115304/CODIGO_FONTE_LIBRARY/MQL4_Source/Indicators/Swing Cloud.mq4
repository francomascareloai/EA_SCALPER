//+------------------------------------------------------------------+
//|                                                 Swing Cloud 2020 |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Silver
#property indicator_color2 Silver
#property indicator_color3 DeepSkyBlue
#property indicator_color4 Salmon

extern string Settings_ex = "---- Indicator Settings";
extern int TrendPeriod = 200;
extern int SwingPeriod = 120;
extern int MaxHistoryBars = 3000;

extern string CL_Settings = "---- Drawing Settings";
extern color BullColor = DeepSkyBlue;
extern color BearColor = Tomato;
extern int   LineWidth = 1;
extern int   LineStyle = 2;

double ibuf_A[]; //Stopline
double ibuf_B[]; //SwingLine
double ibuf_C[]; //CloudUpFill
double ibuf_D[]; //CloudDownFill

double ibuf_E[];
double ibuf_F[];
double ibuf_G[];
double ibuf_H[];

string Gs_A;

int Gi_A;
int Gi_B;
int Gi_C;
int Gi_D;

double Gd_A;
double Gd_B;

bool Gb_A;


//
int init()
  {
   IndicatorBuffers(8);
   IndicatorShortName("Swing Cloud");
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_HISTOGRAM,LineStyle,LineWidth,BullColor);
   SetIndexStyle(3, DRAW_HISTOGRAM,LineStyle,LineWidth,BearColor);

   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));

   SetIndexBuffer(0, ibuf_A);
   SetIndexBuffer(1, ibuf_B);
   SetIndexBuffer(2, ibuf_C);
   SetIndexBuffer(3, ibuf_D);

   SetIndexBuffer(4, ibuf_E);
   SetIndexBuffer(5, ibuf_F);
   SetIndexBuffer(6, ibuf_G);
   SetIndexBuffer(7, ibuf_H);

   double Ld_A = TrendPeriod;
   Gd_A = Ld_A / 100.0;
   Ld_A = SwingPeriod;
   Gd_B = Ld_A / 100.0;
   Gi_A = TrendPeriod / 2;
   Gi_B = TrendPeriod / 4;
   Gi_C = TrendPeriod / 8;
   Gi_D = TrendPeriod / 16;
   Gs_A = WindowExpertName();

   return (0);
  }

//
int start()
  {
   int Li_unused_A;
   double iatr_A;
   double Ld_B;
   double Ld_C;
   double icustom_A;
   double icustom_B;
   double icustom_C;
   double icustom_D;
   double icustom_E;
   double icustom_F;
   double icustom_G;
   double icustom_H;

   int Li_B = 1;
   int ind_counted_A = IndicatorCounted();
   if(ind_counted_A < 0)
      return (-1);
   int Li_C = Bars - 1 - ind_counted_A;
   for(int Li_D = Li_C; Li_D >= Li_B; Li_D--)
     {
      Li_unused_A = Li_D > MaxHistoryBars;
      iatr_A = iATR(Symbol(), 0, 100, Li_D);
      Ld_B = High[Li_D] + iatr_A * Gd_A;
      Ld_C = Low[Li_D] - iatr_A * Gd_A;
      if(ibuf_E[Li_D + 1] != EMPTY_VALUE && Ld_C < ibuf_E[Li_D + 1])
         Ld_C = ibuf_E[Li_D + 1];
      if(ibuf_F[Li_D + 1] != EMPTY_VALUE && Ld_B > ibuf_F[Li_D + 1])
         Ld_B = ibuf_F[Li_D + 1];
      ibuf_H[Li_D] = ibuf_H[Li_D + 1];
      ibuf_E[Li_D] = EMPTY_VALUE;
      ibuf_F[Li_D] = EMPTY_VALUE;
      ibuf_G[Li_D] = EMPTY_VALUE;
      if(Close[Li_D] > Ld_B && ibuf_H[Li_D + 1] != 0.0)
         ibuf_H[Li_D] = 0;
      else
         if(Close[Li_D] < Ld_C && ibuf_H[Li_D + 1] != 1.0)
            ibuf_H[Li_D] = 1;
      if(ibuf_H[Li_D] == 0.0)
        {
         ibuf_E[Li_D] = Ld_C;
         ibuf_A[Li_D] = Ld_C;
         ibuf_B[Li_D] = Ld_C + iatr_A * Gd_B;
         ibuf_C[Li_D] = ibuf_B[Li_D];
         ibuf_D[Li_D] = ibuf_A[Li_D];
        }
      else
        {
         ibuf_F[Li_D] = Ld_B;
         ibuf_A[Li_D] = Ld_B;
         ibuf_B[Li_D] = Ld_B - iatr_A * Gd_B;
         ibuf_C[Li_D] = ibuf_B[Li_D];
         ibuf_D[Li_D] = ibuf_A[Li_D];
        }
      if((!Gb_A) || iatr_A == 0.0 || iatr_A == EMPTY_VALUE)
         continue;
      icustom_A = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_A, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D);
      icustom_B = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_A, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D + 1);
      icustom_C = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_B, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D);
      icustom_D = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_B, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D + 1);
      icustom_E = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_C, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D);
      icustom_F = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_C, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D + 1);
      icustom_G = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_D, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D);
      icustom_H = iCustom(Symbol(), 0, Gs_A, Settings_ex, Gi_D, SwingPeriod, MaxHistoryBars, 0, 0, 7, Li_D + 1);

     }
   return (0);
  }
//+------------------------------------------------------------------+