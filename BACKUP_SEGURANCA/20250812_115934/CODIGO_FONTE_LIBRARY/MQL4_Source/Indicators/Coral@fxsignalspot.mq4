//+===============================================+
//|               Индикатор фильтра: Coral 30.mq4 |
//|                  Период = 260 для (GBPUSD M5) |
//|   Русифицировано и модифицировано: karlosslim |
//|                     San Francisco, California |
//|                                          2013 |
//+===============================================+
#property copyright "2013"
#property link      ""
//===============================
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrGold // (White)
#property indicator_width1 2 // (2)
#property indicator_color2 clrForestGreen // (RoyalBlue)    DarkBlue
#property indicator_width2 2 // (2)
#property indicator_color3 clrRed // (DarkOrange)   Crimson
#property indicator_width3 2 // (2)
//===============================
extern string ПЕРИОД = "ПЕРИОД"; 
extern int    Период = 60; // (260)  (30)   gi_80
extern int    ШиринаКанала = 60;
extern bool  ShowLevels = true;
//---------------------
extern string ЦВЕТ              = "ЦВЕТ";
extern color  Цвет_Смены_Тренда = clrGold; // (White)
extern color  Цвет_Тренд_Buy    = clrForestGreen; // (RoyalBlue)    DarkBlue
extern color  Цвет_Тренд_Sell   = clrRed; // (DarkOrange)   Crimson   FireBrick
//---------------------
extern string РАЗМЕР               = "РАЗМЕР";
extern int	  Толщина_Линии = 3; // (2)
//===============================
bool   gi_76 = TRUE;
double gd_84 = 0.4;
double UpLine[], DnLine[], g_ibuf_92[];
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
double gda_108[];
double gda_112[];
double gda_116[];
double gda_120[];
double gda_124[];
double gda_128[];
double gd_132;
double gd_140;
double gd_148;
double gd_156;
double gd_164;
double gd_172;
double gd_180;
double gd_188;
double gd_196;
//===================
int init() {
   IndicatorBuffers(6);
   IndicatorDigits(Digits);
   SetIndexBuffer(0, g_ibuf_92);   SetIndexStyle(0, DRAW_LINE, EMPTY, Толщина_Линии, Цвет_Смены_Тренда);
   SetIndexBuffer(1, g_ibuf_96);   SetIndexStyle(1, DRAW_LINE, EMPTY, Толщина_Линии, Цвет_Тренд_Buy);
   SetIndexBuffer(2, g_ibuf_100);  SetIndexStyle(2, DRAW_LINE, EMPTY, Толщина_Линии, Цвет_Тренд_Sell);
   if(ShowLevels)  {
     SetIndexBuffer(3, UpLine);      SetIndexStyle(3, DRAW_LINE, 2, 1, clrDimGray);
     SetIndexBuffer(4, DnLine);      SetIndexStyle(4, DRAW_LINE, 2, 1, clrDimGray);
   }
   SetIndexBuffer(5, g_ibuf_104);



   IndicatorShortName("Coral (" + Период + ") ");
   gd_188 = gd_84 * gd_84;
   gd_196 = 0;
   gd_196 = gd_188 * gd_84;
   gd_132 = -gd_196;
   gd_140 = 3.0 * (gd_188 + gd_196);
   gd_148 = -3.0 * (2.0 * gd_188 + gd_84 + gd_196);
   gd_156 = 3.0 * gd_84 + 1.0 + gd_196 + 3.0 * gd_188;
   gd_164 = Период;
   if (gd_164 < 1.0) gd_164 = 1;
   gd_164 = (gd_164 - 1.0) / 2.0 + 1.0;
   gd_172 = 2 / (gd_164 + 1.0);
   gd_180 = 1 - gd_172;
   return (0);
}
//===================
int deinit() {
   return (0);
}
//===================
int start() {
   double ld_0;
   double ld_8;
   if (gi_76 == FALSE) return (0);
   int li_20 = IndicatorCounted();
   if (li_20 < 0) return (-1);
   if (li_20 > 0) li_20--;
   int li_16 = Bars - li_20 - 1;
   ArrayResize(gda_108, Bars + 1);
   ArrayResize(gda_112, Bars + 1);
   ArrayResize(gda_116, Bars + 1);
   ArrayResize(gda_120, Bars + 1);
   ArrayResize(gda_124, Bars + 1);
   ArrayResize(gda_128, Bars + 1);
   for (int li_24 = li_16; li_24 >= 0; li_24--) {
      gda_108[Bars - li_24] = gd_172 * Close[li_24] + gd_180 * (gda_108[Bars - li_24 - 1]);
      gda_112[Bars - li_24] = gd_172 * (gda_108[Bars - li_24]) + gd_180 * (gda_112[Bars - li_24 - 1]);
      gda_116[Bars - li_24] = gd_172 * (gda_112[Bars - li_24]) + gd_180 * (gda_116[Bars - li_24 - 1]);
      gda_120[Bars - li_24] = gd_172 * (gda_116[Bars - li_24]) + gd_180 * (gda_120[Bars - li_24 - 1]);
      gda_124[Bars - li_24] = gd_172 * (gda_120[Bars - li_24]) + gd_180 * (gda_124[Bars - li_24 - 1]);
      gda_128[Bars - li_24] = gd_172 * (gda_124[Bars - li_24]) + gd_180 * (gda_128[Bars - li_24 - 1]);
      g_ibuf_104[li_24] = gd_132 * (gda_128[Bars - li_24]) + gd_140 * (gda_124[Bars - li_24]) + gd_148 * (gda_120[Bars - li_24]) + gd_156 * (gda_116[Bars - li_24]);
      UpLine[li_24] = g_ibuf_104[li_24]+ШиринаКанала*_Point;
      DnLine[li_24] = g_ibuf_104[li_24]-ШиринаКанала*_Point;
      ld_0 = g_ibuf_104[li_24];
      ld_8 = g_ibuf_104[li_24 + 1];
      g_ibuf_92[li_24] = ld_0;
      g_ibuf_96[li_24] = ld_0;
      g_ibuf_100[li_24] = ld_0;
      if (ld_8 > ld_0) g_ibuf_96[li_24] = EMPTY_VALUE;
      else {
         if (ld_8 < ld_0) g_ibuf_100[li_24] = EMPTY_VALUE;
         else g_ibuf_92[li_24] = EMPTY_VALUE;
      }
   }
   return (0);
}
//===================
//===================
//===================