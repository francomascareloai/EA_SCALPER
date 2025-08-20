/*
   
*/
#property copyright "Copyright © 2008, Forex Day Monster"
#property link      "www.forexprofitmonster.com"

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 100.0
#property indicator_buffers 6
#property indicator_color1 DimGray
#property indicator_color2 DimGray
#property indicator_color3 DarkGreen
#property indicator_color4 Maroon
#property indicator_color5 Lime
#property indicator_color6 Red

extern string note1 = "Chart Time Frame";
extern string note2 = "0=current time frame";
extern string note3 = "1=M1, 5=M5, 15=M15, 30=M30";
extern string note4 = "60=H1, 240=H4, 1440=D1";
extern string note5 = "10080=W1, 43200=MN1";
extern int timeFrame = 0;
int g_period_120 = 13;
int gi_124 = 3;
int g_slowing_128 = 3;
int g_ma_method_132 = MODE_EMA;
int g_price_field_136 = 0;
double gd_140 = 80.0;
double gd_148 = 20.0;
bool gi_156 = TRUE;
bool gi_160 = FALSE;
bool gi_164 = FALSE;
bool gi_168 = FALSE;
bool gi_172 = FALSE;
bool gi_176 = FALSE;
double g_ibuf_180[];
double g_ibuf_184[];
double g_ibuf_188[];
double g_ibuf_192[];
double g_ibuf_196[];
double g_ibuf_200[];
int g_timeframe_204;
int gia_208[];
int gi_212;
int gi_216;
string gs_nothing_220 = "nothing";
datetime g_time_228;

int init() {
   SetIndexBuffer(0, g_ibuf_184);
   SetIndexBuffer(1, g_ibuf_180);
   SetIndexBuffer(2, g_ibuf_188);
   SetIndexBuffer(3, g_ibuf_192);
   SetIndexBuffer(4, g_ibuf_196);
   SetIndexBuffer(5, g_ibuf_200);
   if (gi_156) {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
      SetIndexStyle(2, DRAW_HISTOGRAM);
      SetIndexStyle(3, DRAW_HISTOGRAM);
      SetIndexStyle(4, DRAW_HISTOGRAM);
      SetIndexStyle(5, DRAW_HISTOGRAM);
      SetIndexLabel(0, "FDM Oscillator");
      SetIndexLabel(1, "FDM Oscillator");
      SetIndexLabel(2, "FDM Oscillator");
      SetIndexLabel(3, "FDM Oscillator");
      SetIndexLabel(4, "FDM Oscillator");
      SetIndexLabel(5, "FDM Oscillator");
   } else {
      SetIndexLabel(0, "FDM Oscillator");
      SetIndexLabel(1, "FDM Oscillator");
      SetIndexLabel(2, "FDM Oscillator");
      SetIndexLabel(3, "FDM Oscillator");
      SetIndexLabel(4, "FDM Oscillator");
      SetIndexLabel(5, "FDM Oscillator");
      SetIndexStyle(0, DRAW_LINE);
      SetIndexStyle(1, DRAW_LINE);
      SetIndexStyle(2, DRAW_LINE);
      SetIndexStyle(3, DRAW_LINE);
      SetIndexStyle(4, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
      gi_124 = MathMax(gi_124, 1);
      if (gi_124 == 1) {
         SetIndexStyle(0, DRAW_NONE);
         SetIndexLabel(0, NULL);
      } else {
         SetIndexStyle(0, DRAW_LINE);
         SetIndexLabel(0, "FDM Signal");
      }
   }
   g_timeframe_204 = stringToTimeFrame(timeFrame);
   string ls_0 = "FDM Oscillator (" + TimeFrameToString(g_timeframe_204);
   IndicatorShortName(ls_0 + ")");
   return (0);
}

int deinit() {
   DeleteArrows();
   return (0);
}

int start() {
   int l_ind_counted_0 = IndicatorCounted();
   if (l_ind_counted_0 < 0) return (-1);
   int li_4 = MathMax(Bars - l_ind_counted_0, g_timeframe_204 / Period());
   ArrayCopySeries(gia_208, 5, NULL, g_timeframe_204);
   int l_index_8 = 0;
   int l_shift_12 = 0;
   while (l_index_8 < li_4) {
      if (Time[l_index_8] < gia_208[l_shift_12]) l_shift_12++;
      g_ibuf_180[l_index_8] = iStochastic(NULL, g_timeframe_204, g_period_120, gi_124, g_slowing_128, g_ma_method_132, g_price_field_136, MODE_MAIN, l_shift_12);
      g_ibuf_184[l_index_8] = iStochastic(NULL, g_timeframe_204, g_period_120, gi_124, g_slowing_128, g_ma_method_132, g_price_field_136, MODE_SIGNAL, l_shift_12);
      l_index_8++;
   }
   l_index_8 = li_4;
   l_shift_12 = 0;
   while (l_index_8 >= 0) {
      if (gi_156) {
         g_ibuf_188[l_index_8] = EMPTY_VALUE;
         g_ibuf_192[l_index_8] = EMPTY_VALUE;
         if (g_ibuf_180[l_index_8] > gd_140) g_ibuf_188[l_index_8] = 100;
         else {
            if (g_ibuf_180[l_index_8] < gd_148) g_ibuf_192[l_index_8] = 100;
            else {
               if (g_ibuf_180[l_index_8] > g_ibuf_180[l_index_8 + 1]) g_ibuf_196[l_index_8] = 100;
               else {
                  if (g_ibuf_180[l_index_8] < g_ibuf_180[l_index_8 + 1]) g_ibuf_200[l_index_8] = 100;
                  else {
                     g_ibuf_196[l_index_8] = g_ibuf_196[l_index_8 + 1];
                     g_ibuf_200[l_index_8] = g_ibuf_200[l_index_8 + 1];
                  }
               }
            }
         }
      } else {
         if (g_ibuf_180[l_index_8] > gd_140) {
            g_ibuf_188[l_index_8] = g_ibuf_180[l_index_8];
            g_ibuf_188[l_index_8 + 1] = g_ibuf_180[l_index_8 + 1];
         } else {
            g_ibuf_188[l_index_8] = EMPTY_VALUE;
            if (g_ibuf_188[l_index_8 + 2] == EMPTY_VALUE) g_ibuf_188[l_index_8 + 1] = EMPTY_VALUE;
         }
         if (g_ibuf_180[l_index_8] < gd_148) {
            g_ibuf_192[l_index_8] = g_ibuf_180[l_index_8];
            g_ibuf_192[l_index_8 + 1] = g_ibuf_180[l_index_8 + 1];
         } else {
            g_ibuf_192[l_index_8] = EMPTY_VALUE;
            if (g_ibuf_192[l_index_8 + 2] == EMPTY_VALUE) g_ibuf_192[l_index_8 + 1] = EMPTY_VALUE;
         }
      }
      l_index_8--;
   }
   DeleteArrows();
   if (gi_160) {
      gi_216 = MathCeil(iATR(NULL, 0, 50, 0) / Point);
      for (l_index_8 = 0; l_index_8 < WindowBarsPerChart(); l_index_8++) {
         if (g_ibuf_180[l_index_8] > gd_140 && g_ibuf_180[l_index_8 + 1] < gd_140) DrawArrow(l_index_8, "up");
         if (g_ibuf_180[l_index_8] < gd_148 && g_ibuf_180[l_index_8 + 1] > gd_148) DrawArrow(l_index_8, "down");
      }
   }
   if (gi_164) {
      if (g_ibuf_180[0] > gd_140 && g_ibuf_180[1] < gd_140) doAlert(gd_140 + " line crossed up");
      if (g_ibuf_180[0] < gd_148 && g_ibuf_180[1] > gd_148) doAlert(gd_140 + " line crossed down");
   }
   return (0);
}

void DrawArrow(int ai_0, string as_4) {
   gi_212++;
   string l_str_concat_12 = StringConcatenate("FDM Signal", gi_212);
   ObjectCreate(l_str_concat_12, OBJ_ARROW, 0, Time[ai_0], 0);
   if (as_4 == "up") {
      ObjectSet(l_str_concat_12, OBJPROP_PRICE1, High[ai_0] + gi_216 * Point);
      ObjectSet(l_str_concat_12, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
      ObjectSet(l_str_concat_12, OBJPROP_COLOR, Red);
      return;
   }
   ObjectSet(l_str_concat_12, OBJPROP_PRICE1, Low[ai_0] - gi_216 * Point);
   ObjectSet(l_str_concat_12, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
   ObjectSet(l_str_concat_12, OBJPROP_COLOR, LimeGreen);
}

void DeleteArrows() {
   while (gi_212 > 0) {
      ObjectDelete(StringConcatenate("FDM Signal", gi_212));
      gi_212--;
   }
}

void doAlert(string as_0) {
   string l_str_concat_8;
   if (gs_nothing_220 != as_0 || g_time_228 != Time[0]) {
      gs_nothing_220 = as_0;
      g_time_228 = Time[0];
      l_str_concat_8 = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " FDM Oscillator ", as_0);
      if (gi_168) Alert(l_str_concat_8);
      if (gi_172) PlaySound("alert2.wav");
      if (gi_176) SendMail(StringConcatenate(Symbol(), " FDM Oscillator crossing"), l_str_concat_8);
   }
}

int stringToTimeFrame(string as_0) {
   int l_timeframe_8 = 0;
   as_0 = StringUpperCase(as_0);
   if (as_0 == "M1" || as_0 == "1") l_timeframe_8 = 1;
   if (as_0 == "M5" || as_0 == "5") l_timeframe_8 = 5;
   if (as_0 == "M15" || as_0 == "15") l_timeframe_8 = 15;
   if (as_0 == "M30" || as_0 == "30") l_timeframe_8 = 30;
   if (as_0 == "H1" || as_0 == "60") l_timeframe_8 = 60;
   if (as_0 == "H4" || as_0 == "240") l_timeframe_8 = 240;
   if (as_0 == "D1" || as_0 == "1440") l_timeframe_8 = 1440;
   if (as_0 == "W1" || as_0 == "10080") l_timeframe_8 = 10080;
   if (as_0 == "MN" || as_0 == "43200") l_timeframe_8 = 43200;
   if (l_timeframe_8 < Period()) l_timeframe_8 = Period();
   return (l_timeframe_8);
}

string TimeFrameToString(int ai_0) {
   string ls_ret_4 = "Current time frame";
   switch (ai_0) {
   case 1:
      ls_ret_4 = "M1";
      break;
   case 5:
      ls_ret_4 = "M5";
      break;
   case 15:
      ls_ret_4 = "M15";
      break;
   case 30:
      ls_ret_4 = "M30";
      break;
   case 60:
      ls_ret_4 = "H1";
      break;
   case 240:
      ls_ret_4 = "H4";
      break;
   case 1440:
      ls_ret_4 = "D1";
      break;
   case 10080:
      ls_ret_4 = "W1";
      break;
   case 43200:
      ls_ret_4 = "MN1";
   }
   return (ls_ret_4);
}

string StringUpperCase(string as_0) {
   int li_20;
   string ls_ret_8 = as_0;
   for (int li_16 = StringLen(as_0) - 1; li_16 >= 0; li_16--) {
      li_20 = StringGetChar(ls_ret_8, li_16);
      if ((li_20 > '`' && li_20 < '{') || (li_20 > 'ß' && li_20 < 256)) ls_ret_8 = StringSetChar(ls_ret_8, li_16, li_20 - 32);
      else
         if (li_20 > -33 && li_20 < 0) ls_ret_8 = StringSetChar(ls_ret_8, li_16, li_20 + 224);
   }
   return (ls_ret_8);
}