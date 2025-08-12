
#property copyright "Copyright © 2011, Sergey Vladimirov"
#property link      "svlad1983@hotmail.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Black
#property indicator_color3 Black

int gi_unused_76 = 110;
double g_ibuf_80[];
double gda_84[];
int g_period_88 = 13;
int g_period_92 = 34;
int g_period_96 = 8;
double g_ibuf_100[];
double g_ibuf_104[];
string g_symbol_108;
string gs_116;
string gs_dummy_124;
int gi_unused_132;
int g_timeframe_136;
//string gs_unused_144 = "";
//int gi_unused_152 = 16777215;
string gs_156;
string gs_172;
//int gi_unused_184;
//int g_acc_number_188;
//double gd_unused_196 = 3.0;
int g_color_204 = Red;
//string gs_unused_208 = "Font Size";
int g_fontsize_216 = 20;
//string gs_unused_220 = "Font Type";
//string gs_verdana_228 = "Verdana";
//string g_text_236 = ">>> CHECKING ACCOUNT <<<";
//string g_text_244 = ">>> AUTHORIZATION <<<";
//string g_name_252 = "cmtagtpbi01";
//string g_name_260 = "cmtagtpbi02";
bool gi_268 = FALSE;

int init()
{
   //gi_unused_184 = 1;
   g_timeframe_136 = Period();
   gs_116 = f0_0(g_timeframe_136);
   g_symbol_108 = Symbol();
   gi_unused_132 = Digits;
   gs_172 = "!indicator2 ";
   gs_156 = gs_172 + "0";
   IndicatorShortName(gs_172);
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 1, Red);
   SetIndexBuffer(0, g_ibuf_80);
   SetIndexBuffer(1, g_ibuf_100);
   SetIndexBuffer(2, g_ibuf_104);
   IndicatorDigits(0);
   return (0);
}

int deinit() {
   //ObjectDelete(g_name_252);
   //ObjectDelete(g_name_260);
   //Comment("");
   return (0);
}

int start() {
   int li_4;
   //ObjectDelete(g_name_252);
   //ObjectDelete(g_name_260);
   int li_8 = IndicatorCounted();
   if (li_8 > 0) li_8--;
   if (gi_268) li_4 = Bars - li_8;
   else li_4 = Bars;
   for (int li_12 = 0; li_12 < li_4; li_12++) {
      gda_84[li_12] = EMPTY_VALUE;
      g_ibuf_80[li_12] = EMPTY_VALUE;
      g_ibuf_100[li_12] = iMA(g_symbol_108, 0, g_period_88, 0, MODE_EMA, PRICE_CLOSE, li_12) - iMA(g_symbol_108, 0, g_period_92, 0, MODE_EMA, PRICE_CLOSE, li_12);
   }
   double ld_16 = 2.0 / (g_period_88 + 1.0);
   double ld_24 = 2.0 / (g_period_92 + 1.0);
   double ld_32 = ld_16 - ld_24;
   for (li_12 = 0; li_12 < li_4; li_12++) g_ibuf_104[li_12] = iMAOnArray(g_ibuf_100, Bars, g_period_96, 0, MODE_SMA, li_12);
   for (li_12 = 0; li_12 < li_4; li_12++) {
      if (MathAbs(ld_32) > 0.0) {
         g_ibuf_80[li_12] = (ld_16 * iMA(g_symbol_108, 0, g_period_88, 0, MODE_EMA, PRICE_CLOSE, li_12) + iMA(g_symbol_108, 0, g_period_92, 0, MODE_EMA, PRICE_CLOSE, li_12) - iMA(g_symbol_108,
            0, g_period_88, 0, MODE_EMA, PRICE_CLOSE, li_12) - ld_24 * iMA(g_symbol_108, 0, g_period_92, 0, MODE_EMA, PRICE_CLOSE, li_12) + g_ibuf_104[li_12]) / ld_32;
      } else g_ibuf_80[li_12] = 0;
   }
   if (li_12 > 100) gi_268 = TRUE;
   return (0);
}

/*void f0_1() {
   ObjectCreate(g_name_252, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(g_name_252, g_text_236, g_fontsize_216, gs_verdana_228, g_color_204);
   ObjectSet(g_name_252, OBJPROP_CORNER, 0);
   ObjectSet(g_name_252, OBJPROP_XDISTANCE, 5);
   ObjectSet(g_name_252, OBJPROP_YDISTANCE, 10);
   ObjectCreate(g_name_260, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(g_name_260, g_text_244, g_fontsize_216, gs_verdana_228, g_color_204);
   ObjectSet(g_name_260, OBJPROP_CORNER, 0);
   ObjectSet(g_name_260, OBJPROP_XDISTANCE, 5);
   ObjectSet(g_name_260, OBJPROP_YDISTANCE, g_fontsize_216 + 20);
}*/

string f0_0(int ai_0) {
   string ls_ret_4;
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
      ls_ret_4 = "MN";
   }
   return (ls_ret_4);
}