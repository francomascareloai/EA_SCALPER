#property copyright "Russ Horn Forex Master Method"
#property link      "www.forexmastermethod.com"

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Black

/* #import "wininet.dll"
   int InternetOpenA(string a0, int a1, string a2, string a3, int a4);
   int InternetOpenUrlA(int a0, string a1, string a2, int a3, int a4, int a5);
   int InternetReadFile(int a0, string a1, int a2, int& a3[]);
   int InternetCloseHandle(int a0);
#import 
*/

//extern string note = " ======= Authentication SETTINGS ======";
//extern string username = "";
//extern string password = "";
extern double LowValue = 2.0;
extern double MaxValue = 8.0;
extern string PairAlert = "";
extern int AlertDelay = 30;
extern int Hours = 1;
//extern string sOutput = "EUR,USD"; //"EUR,GBP,AUD,NZD,USD,CAD,CHF,JPY";
//extern string sPairs = "EURUSD"; //"EURUSD,EURGBP,EURCHF,EURJPY,EURAUD,EURNZD,GBPUSD,AUDUSD,NZDUSD,USDJPY,USDCHF,USDCAD,EURCAD,CADJPY,GBPJPY,GBPCHF";
extern color cCurrency = Lime;
extern color cScoreHigh = Aqua;
extern color cScoreHour = Orange;
extern int Window = 0;
extern int Corner = 3;
extern int Xdistance = 0;
extern int Ydistance = 0;

string gsa_160[16];
string gsa_164[8];
int gia_168[8] = {40, 10, 160, 130, 190, 70, 220, 100};
int gia_172[] = {16612911, 16620590, 16702510, 15990063, 11206190, 5569869, 4193654, 3669164, 3407316, 3144445, 3144189, 3138813, 3069181, 3126526, 3046654, 3098621, 4207864, 4207864, 4207864, 4207864};
int gia_176[11] = {0, 4, 11, 23, 39, 50, 61, 78, 89, 96, 100};
int gi_180 = 16;
int gi_184 = 8;
double gda_188[8];
double gda_192[16];
double gda_196[16];
double gda_200[8];
double gda_204[16];
double gda_208[16];
int g_datetime_212 = 0;
int g_str2int_216 = 0;
bool gi_220 = TRUE;
bool gi_224 = TRUE;
int gia_228[64] = {65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47};
int gi_232 = 1;
string gs_dummy_236;
int gi_244 = 0;
int gi_248 = 0;
int g_count_252 = 0;
string gs_256;
int gia_264[1];
string gs_272 = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

int init() {
   int li_12;
   g_str2int_216 = 0;
   gi_220 = TRUE;
   gi_224 = TRUE;
   string ls_0 = StringSubstr(Symbol(),0,3)+","+StringSubstr(Symbol(),3,3); //string ls_0 = sOutput;
   int index_8 = 0;
   while (StringLen(ls_0) > 0) {
      li_12 = StringFind(ls_0, ",");
      gsa_164[index_8] = StringSubstr(ls_0, 0, 3);
      ls_0 = StringSubstr(ls_0, li_12 + 1);
      index_8++;
      if (li_12 < 0) break;
   }
   gi_184 = index_8;
   if (gi_184 > 8) {
      gi_184 = 8;
      Comment("\n\n ERRORR:\n  Maximum NUMBER of Output Currencies is 8 \n Only first 8 will be taken");
   }
   index_8 = 0;
   ls_0 = Symbol(); //ls_0 = sPairs;
   while (StringLen(ls_0) > 0) {
      li_12 = StringFind(ls_0, ",");
      gsa_160[index_8] = StringSubstr(ls_0, 0, li_12);
      ls_0 = StringSubstr(ls_0, li_12 + 1);
      index_8++;
      if (li_12 < 0) break;
   }
   gi_180 = index_8;
   if (gi_180 > 16) {
      gi_180 = 16;
      Comment("\n\n ERRORR:\n  Maximum NUMBER of Pairs is 16 \n Only first 16 will be taken");
   }
   deinit();
   Print("PairCount:", gi_180);
   for (int index_16 = 0; index_16 < gi_184; index_16++) {
      for (int count_20 = 0; count_20 < 20; count_20++) {
         objectCreate("CPM" + gsa_164[index_16] + count_20, 7 * (21 - count_20), gia_168[index_16]);
         objectCreate("CPM" + gsa_164[index_16] + count_20 + "x", 7 * (21 - count_20), gia_168[index_16] - 5);
         objectCreate("CPM" + gsa_164[index_16] + count_20 + "h", 7 * (21 - count_20), gia_168[index_16] + 10);
      }
      objectCreate("CPM" + gsa_164[index_16], 195, gia_168[index_16] + 10, gsa_164[index_16], 10, "Verdana", cCurrency);
      objectCreate("CPM" + gsa_164[index_16] + "_Str", 170, gia_168[index_16] + 7, DoubleToStr(0, 1), 8, "Verdana", cScoreHigh);
      objectCreate("CPM" + gsa_164[index_16] + "_Str_h", 170, gia_168[index_16] + 20, DoubleToStr(0, 1), 8, "Verdana", cScoreHour);
   }
   ObjectsRedraw();
   return (0);
}

int start() {
   string text_0;
   int count_16;
   int count_20;
   string ls_24;
   double ld_32;
   double ld_40;
   double low_48;
   double ld_56;
   double ld_72;
   double bid_80;

   double ld_88 = 0.01;
   if (gi_220 == TRUE) {
      for (int index_8 = 0; index_8 < gi_180; index_8++) {
         RefreshRates();
         ld_88 = 0.0001;
         ls_24 = gsa_160[index_8];
         if (StringSubstr(ls_24, 3, 3) == "JPY") ld_88 = 0.01;
         low_48 = MarketInfo(ls_24, MODE_LOW);
         bid_80 = MarketInfo(ls_24, MODE_BID);
         ld_56 = (bid_80 - low_48) / MathMax(MarketInfo(ls_24, MODE_HIGH) - low_48, ld_88);
         gda_192[index_8] = CheckRatio(100.0 * ld_56);
         gda_196[index_8] = 9.9 - CheckRatio(100.0 * ld_56);
         low_48 = MyLowest(ls_24);
         ld_72 = MyHighest(ls_24);
         ld_56 = (bid_80 - low_48) / MathMax(ld_72 - low_48, ld_88);
         gda_208[index_8] = CheckRatio(100.0 * ld_56);
         gda_204[index_8] = 9.9 - CheckRatio(100.0 * ld_56);
      }
      for (int index_12 = 0; index_12 < gi_184; index_12++) {
         count_16 = 0;
         count_20 = 0;
         ld_32 = 0;
         ld_40 = 0;
         for (index_8 = 0; index_8 < gi_180; index_8++) {
            if (StringSubstr(gsa_160[index_8], 0, 3) == gsa_164[index_12]) {
               ld_32 += gda_192[index_8];
               count_16++;
               ld_40 += gda_208[index_8];
               count_20++;
            }
            if (StringSubstr(gsa_160[index_8], 3, 3) == gsa_164[index_12]) {
               ld_32 += gda_196[index_8];
               count_16++;
               ld_40 += gda_204[index_8];
               count_20++;
            }
            if (count_16 > 0) gda_188[index_12] = NormalizeDouble(ld_32 / count_16, 1);
            else gda_188[index_12] = -1;
            if (count_20 > 0) gda_200[index_12] = NormalizeDouble(ld_40 / count_20, 1);
            else gda_200[index_12] = -1;
         }
      }
      for (index_12 = 0; index_12 < gi_184; index_12++) {
         ShowData(index_12);
         if (gda_188[index_12] < LowValue && StringFind(PairAlert, gsa_164[index_12]) != -1 && TimeCurrent() - g_datetime_212 > AlertDelay) {
            PlaySound("news.wav");
            g_datetime_212 = TimeCurrent();
         }
         if (gda_188[index_12] > MaxValue && StringFind(PairAlert, gsa_164[index_12]) != -1 && TimeCurrent() - g_datetime_212 > AlertDelay) {
            PlaySound("news.wav");
            g_datetime_212 = TimeCurrent();
         }
      }
   }
   return (0);
}

int CheckRatio(double ad_0) {
   int li_ret_8 = -1;
   if (ad_0 <= 0.0) li_ret_8 = 0;
   else {
      for (int index_12 = 0; index_12 < 11; index_12++) {
         if (ad_0 < gia_176[index_12]) {
            li_ret_8 = index_12 - 1;
            break;
         }
      }
      if (li_ret_8 == -1) li_ret_8 = 9.9;
   }
   return (li_ret_8);
}

double MyLowest(string a_symbol_0) {
   double ilow_8 = iLow(a_symbol_0, 0, 0);
   int timeframe_16 = 15;
   int li_20 = 4;
   if (Hours < 3) {
      timeframe_16 = 5;
      li_20 = 12;
   }
   for (int li_24 = 0; li_24 < Hours * li_20; li_24++)
      if (ilow_8 > iLow(a_symbol_0, timeframe_16, li_24)) ilow_8 = iLow(a_symbol_0, timeframe_16, li_24);
   return (ilow_8);
}

double MyHighest(string a_symbol_0) {
   double ihigh_8 = iHigh(a_symbol_0, 0, 0);
   int timeframe_16 = 15;
   int li_20 = 4;
   if (Hours < 3) {
      timeframe_16 = 5;
      li_20 = 12;
   }
   for (int li_24 = 0; li_24 < Hours * li_20; li_24++)
      if (ihigh_8 < iHigh(a_symbol_0, timeframe_16, li_24)) ihigh_8 = iHigh(a_symbol_0, timeframe_16, li_24);
   return (ihigh_8);
}

void objectCreate(string a_name_0, int a_x_8, int a_y_12, string a_text_16 = ".", int a_fontsize_24 = 42, string a_fontname_28 = "Arial", color a_color_36 = -1) {
   ObjectCreate(a_name_0, OBJ_LABEL, Window, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, Corner);
   ObjectSet(a_name_0, OBJPROP_COLOR, a_color_36);
   //Print(a_x_8+ " " + a_y_12);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_8 -13 + Xdistance);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_12 -4 + Ydistance);
   ObjectSetText(a_name_0, a_text_16, a_fontsize_24, a_fontname_28, a_color_36);
}

void ShowData(int ai_0) {
   double ld_4 = 0;
   for (int index_12 = 0; index_12 < 20; index_12++) {
      ld_4 = index_12;
      if (gda_188[ai_0] > ld_4 / 2.0) {
         ObjectSet("CPM" + gsa_164[ai_0] + index_12, OBJPROP_COLOR, gia_172[index_12]);
         ObjectSet("CPM" + gsa_164[ai_0] + index_12 + "x", OBJPROP_COLOR, gia_172[index_12]);
      } else {
         ObjectSet("CPM" + gsa_164[ai_0] + index_12, OBJPROP_COLOR, CLR_NONE);
         ObjectSet("CPM" + gsa_164[ai_0] + index_12 + "x", OBJPROP_COLOR, CLR_NONE);
      }
      if (gda_200[ai_0] > ld_4 / 2.0) ObjectSet("CPM" + gsa_164[ai_0] + index_12 + "h", OBJPROP_COLOR, gia_172[index_12]);
      else ObjectSet("CPM" + gsa_164[ai_0] + index_12 + "h", OBJPROP_COLOR, CLR_NONE);
   }
   ObjectSetText("CPM" + gsa_164[ai_0] + "_Str", DoubleToStr(gda_188[ai_0], 1), 8, "Verdana", cScoreHigh);
   ObjectSetText("CPM" + gsa_164[ai_0] + "_Str_h", DoubleToStr(gda_200[ai_0], 1), 8, "Verdana", cScoreHour);
}

int deinit() {
   int objs_total_0;
   Comment("");
   string name_4 = "";
   bool li_12 = TRUE;
   while (li_12) {
      li_12 = FALSE;
      objs_total_0 = ObjectsTotal();
      for (int li_16 = 0; li_16 < objs_total_0; li_16++) {
         name_4 = ObjectName(li_16);
         if (StringFind(name_4, "CPM") != -1) {
            ObjectDelete(name_4);
            li_12 = TRUE;
         }
      }
   }
   return (0);
}







