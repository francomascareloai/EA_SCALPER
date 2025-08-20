
#property copyright "Copyright © 2009, TradeWays"
#property link      "http://www.tradeways.org"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Black

extern int PosX = 10;
extern int PosY = 15;
extern int Corner = 1;
extern int N = 20;
string gs_92 = "1";
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double g_ibuf_120[];

int init() {
   IndicatorBuffers(6);
   SetIndexBuffer(0, g_ibuf_100);
   SetIndexBuffer(1, g_ibuf_104);
   SetIndexBuffer(2, g_ibuf_108);
   SetIndexBuffer(3, g_ibuf_112);
   SetIndexBuffer(4, g_ibuf_116);
   SetIndexBuffer(5, g_ibuf_120);
   return (0);
}

int deinit() {
   fObjDeleteByPrefix("HHL_Semafor_" + gs_92);
   return (0);
}

int start() {
   double l_high_8;
   double l_low_16;
   //if (TimeCurrent() > StrToTime("2050.04.20")) {
   //   Alert("New version available! Download it using re-activated link from Plimus");
   //   return;
   //}
   int li_0 = Bars - IndicatorCounted();
   for (int li_4 = li_0 - 1; li_4 >= 0; li_4--) {
      l_high_8 = High[iHighest(Symbol(), 0, MODE_HIGH, N, li_4)];
      l_low_16 = Low[iLowest(Symbol(), 0, MODE_LOW, N, li_4)];
      g_ibuf_100[li_4] = (l_high_8 - l_low_16) / Point;
      g_ibuf_104[li_4] = EMPTY_VALUE;
      g_ibuf_108[li_4] = EMPTY_VALUE;
      g_ibuf_112[li_4] = EMPTY_VALUE;
      if (g_ibuf_104[li_4 + 1] != EMPTY_VALUE) g_ibuf_104[li_4] = g_ibuf_100[li_4];
      if (g_ibuf_108[li_4 + 1] != EMPTY_VALUE) g_ibuf_108[li_4] = g_ibuf_100[li_4];
      if (g_ibuf_112[li_4 + 1] != EMPTY_VALUE) g_ibuf_112[li_4] = g_ibuf_100[li_4];
      g_ibuf_116[li_4] = g_ibuf_116[li_4 + 1];
      if (g_ibuf_100[li_4 + 1] > g_ibuf_100[li_4])
         if (g_ibuf_100[li_4 + 2] <= g_ibuf_100[li_4 + 1]) g_ibuf_116[li_4] = g_ibuf_100[li_4 + 1];
      if (g_ibuf_100[li_4 + 1] > g_ibuf_100[li_4]) {
         g_ibuf_104[li_4] = g_ibuf_100[li_4];
         g_ibuf_108[li_4] = EMPTY_VALUE;
         g_ibuf_112[li_4] = EMPTY_VALUE;
      }
      if (g_ibuf_100[li_4 + 1] < g_ibuf_100[li_4]) {
         if (g_ibuf_116[li_4] < g_ibuf_100[li_4]) {
            g_ibuf_104[li_4] = EMPTY_VALUE;
            g_ibuf_108[li_4] = EMPTY_VALUE;
            g_ibuf_112[li_4] = g_ibuf_100[li_4];
         } else {
            g_ibuf_104[li_4] = EMPTY_VALUE;
            g_ibuf_108[li_4] = g_ibuf_100[li_4];
            g_ibuf_112[li_4] = EMPTY_VALUE;
         }
      }
   }
   if (Corner < 2) {
      fObjLabel("HHL_Semafor_" + gs_92 + "_Red", PosX, PosY, StringSetChar("", 0, 'l'), Corner, Gray, 16, 0, "Wingdings", FALSE);
      fObjLabel("HHL_Semafor_" + gs_92 + "_Yellow", PosX, PosY + 15, StringSetChar("", 0, 'l'), Corner, Gray, 16, 0, "Wingdings", FALSE);
      fObjLabel("HHL_Semafor_" + gs_92 + "_Green", PosX, PosY + 30, StringSetChar("", 0, 'l'), Corner, Gray, 16, 0, "Wingdings", FALSE);
      if (g_ibuf_104[0] != EMPTY_VALUE) fObjLabel("HHL_Semafor_" + gs_92 + "_Red", PosX, PosY, StringSetChar("", 0, 'l'), Corner, Red, 16, 0, "Wingdings", FALSE);
      if (g_ibuf_108[0] != EMPTY_VALUE) fObjLabel("HHL_Semafor_" + gs_92 + "_Yellow", PosX, PosY + 15, StringSetChar("", 0, 'l'), Corner, Yellow, 16, 0, "Wingdings", FALSE);
      if (g_ibuf_112[0] != EMPTY_VALUE) fObjLabel("HHL_Semafor_" + gs_92 + "_Green", PosX, PosY + 30, StringSetChar("", 0, 'l'), Corner, Lime, 16, 0, "Wingdings", FALSE);
   } else {
      fObjLabel("HHL_Semafor_" + gs_92 + "_Red", PosX, PosY + 30, StringSetChar("", 0, 'l'), Corner, Gray, 16, 0, "Wingdings", FALSE);
      fObjLabel("HHL_Semafor_" + gs_92 + "_Yellow", PosX, PosY + 15, StringSetChar("", 0, 'l'), Corner, Gray, 16, 0, "Wingdings", FALSE);
      fObjLabel("HHL_Semafor_" + gs_92 + "_Green", PosX, PosY, StringSetChar("", 0, 'l'), Corner, Gray, 16, 0, "Wingdings", FALSE);
      if (g_ibuf_104[0] != EMPTY_VALUE) fObjLabel("HHL_Semafor_" + gs_92 + "_Red", PosX, PosY + 30, StringSetChar("", 0, 'l'), Corner, Red, 16, 0, "Wingdings", FALSE);
      if (g_ibuf_108[0] != EMPTY_VALUE) fObjLabel("HHL_Semafor_" + gs_92 + "_Yellow", PosX, PosY + 15, StringSetChar("", 0, 'l'), Corner, Yellow, 16, 0, "Wingdings", FALSE);
      if (g_ibuf_112[0] != EMPTY_VALUE) fObjLabel("HHL_Semafor_" + gs_92 + "_Green", PosX, PosY, StringSetChar("", 0, 'l'), Corner, Lime, 16, 0, "Wingdings", FALSE);
   }
   return (0);
}

void fObjLabel(string a_name_0, int a_x_8, int a_y_12, string a_text_16, int a_corner_24 = 0, color a_color_28 = 255, int a_fontsize_32 = 8, int a_window_36 = 0, string a_fontname_40 = "Arial", bool a_bool_48 = FALSE) {
   if (ObjectFind(a_name_0) != a_window_36) ObjectCreate(a_name_0, OBJ_LABEL, a_window_36, 0, 0);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_8);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_12);
   ObjectSetText(a_name_0, a_text_16, a_fontsize_32, a_fontname_40, a_color_28);
   ObjectSet(a_name_0, OBJPROP_BACK, a_bool_48);
   ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_24);
}

void fObjDeleteByPrefix(string as_0) {
   for (int li_8 = ObjectsTotal() - 1; li_8 >= 0; li_8--)
      if (StringFind(ObjectName(li_8), as_0, 0) == 0) ObjectDelete(ObjectName(li_8));
}