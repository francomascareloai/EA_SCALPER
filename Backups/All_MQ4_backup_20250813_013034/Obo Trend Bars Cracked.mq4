#property copyright "Copyright © 2009, O-bo.com"
#property link      "http://www.o-bo.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Maroon
#property indicator_color5 Lime
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_color8 Maroon

extern int Sensitivity = 1;
int Period1;
int Period2;
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
double Buffer8[];

int init() {
   ObjectCreate("Close line", OBJ_HLINE, 0, Time[40], Close[0]);
   ObjectSet("Close line", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("Close line", OBJPROP_COLOR, Silver);
   SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2);SetIndexBuffer(0, Buffer1);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 2);SetIndexBuffer(1, Buffer2);
   SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, 2);SetIndexBuffer(2, Buffer3);
   SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, 2);SetIndexBuffer(3, Buffer4);
   SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, 0);SetIndexBuffer(4, Buffer5);
   SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, 0);SetIndexBuffer(5, Buffer6);
   SetIndexStyle(6, DRAW_HISTOGRAM, EMPTY, 0);SetIndexBuffer(6, Buffer7);
   SetIndexStyle(7, DRAW_HISTOGRAM, EMPTY, 0);SetIndexBuffer(7, Buffer8);
   IndicatorShortName("OBO TrendBars");
   return (0);
}

int deinit() {
   ObjectDelete("Close line");
   Comment("");
   return (0);
}

int start() {
   double l_icci_0;
   double l_icci_8;
   int li_16;
   ObjectMove("Close line", 0, Time[20], Close[0]);
   if (Sensitivity == 1) {
      Period2 = 5;
      Period1 = 14;
   }
   if (Sensitivity == 0 || Sensitivity == 2 || Sensitivity > 3) {
      Period2 = 14;
      Period1 = 50;
   }
   if (Sensitivity == 3) {
      Period2 = 89;
      Period1 = 200;
   }
   //Comment("O-bo.com - Obo Trend Bars, Sensitivity : " + DoubleToStr(Sensitivity, 0));
   int l_ind_counted_20 = IndicatorCounted();
   if (Bars <= 15) return (0);
   if (l_ind_counted_20 < 1) {
      for (int pos = 1; pos <= 15; pos++)
      {
         Buffer1[Bars - pos] = 0.0;
         Buffer3[Bars - pos] = 0.0;
         Buffer2[Bars - pos] = 0.0;
         Buffer4[Bars - pos] = 0.0;
         Buffer5[Bars - pos] = 0.0;
         Buffer7[Bars - pos] = 0.0;
         Buffer6[Bars - pos] = 0.0;
         Buffer8[Bars - pos] = 0.0;
      }
   }
   if (l_ind_counted_20 > 0) li_16 = Bars - l_ind_counted_20;
   if (l_ind_counted_20 == 0) li_16 = Bars - 15 - 1;
   for (pos = li_16; pos >= 0; pos--)
   {
      l_icci_0 = iCCI(NULL, 0, Period2, PRICE_TYPICAL, pos);
      l_icci_8 = iCCI(NULL, 0, Period1, PRICE_TYPICAL, pos);
      Buffer1[pos] = EMPTY_VALUE;
      Buffer3[pos] = EMPTY_VALUE;
      Buffer2[pos] = EMPTY_VALUE;
      Buffer4[pos] = EMPTY_VALUE;
      Buffer5[pos] = EMPTY_VALUE;
      Buffer7[pos] = EMPTY_VALUE;
      Buffer6[pos] = EMPTY_VALUE;
      Buffer8[pos] = EMPTY_VALUE;
      if (l_icci_0 >= 0.0 && l_icci_8 >= 0.0)
      {
         Buffer1[pos] = MathMax(Open[pos], Close[pos]);
         Buffer2[pos] = MathMin(Open[pos], Close[pos]);
         Buffer5[pos] = High[pos];
         Buffer6[pos] = Low[pos];
      } 
      else
      {
         if (l_icci_8 >= 0.0 && l_icci_0 < 0.0)
         {
            Buffer3[pos] = MathMax(Open[pos], Close[pos]);
            Buffer4[pos] = MathMin(Open[pos], Close[pos]);
            Buffer7[pos] = High[pos];
            Buffer8[pos] = Low[pos];
         } 
         else
         {
            if (l_icci_0 < 0.0 && l_icci_8 < 0.0)
            {
               Buffer2[pos] = MathMax(Open[pos], Close[pos]);
               Buffer1[pos] = MathMin(Open[pos], Close[pos]);
               Buffer6[pos] = High[pos];
               Buffer5[pos] = Low[pos];
            }
            else 
            {
               if (l_icci_8 < 0.0 && l_icci_0 > 0.0)
               {
                  Buffer4[pos] = MathMax(Open[pos], Close[pos]);
                  Buffer3[pos] = MathMin(Open[pos], Close[pos]);
                  Buffer8[pos] = High[pos];
                  Buffer7[pos] = Low[pos];
               }
            }
         }
      }
   }
   return (0);
}