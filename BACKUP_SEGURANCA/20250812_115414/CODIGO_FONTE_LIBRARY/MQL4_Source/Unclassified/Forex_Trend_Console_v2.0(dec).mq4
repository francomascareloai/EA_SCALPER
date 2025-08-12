#property copyright "Copyright © 2012, ForexTrendConsole.com"
#property link      "http://www.ForexTrendConsole.com/"

#property indicator_chart_window

#import "Forex_Trend_Console.dll"
   void CheckVersion(int a0, string& a1[]);
#import

string EURUSD="EURUSD",GBPUSD="GBPUSD",USDJPY="USDJPY",USDCAD="USDCAD",USDCHF="USDCHF",AUDUSD="AUDUSD",NZDUSD="NZDUSD",EURGBP="EURGBP";
string EURCHF="EURCHF",GBPJPY="GBPJPY",AUDJPY="AUDJPY",EURJPY="EURJPY",CHFJPY="CHFJPY",GBPCHF="GBPCHF",XAUUSD="XAUUSD",XAGUSD="XAGUSD";
extern string Symbols_To_Display = "EURUSD,GBPUSD,USDJPY,USDCAD,USDCHF,AUDUSD,NZDUSD,EURGBP,EURCHF,GBPJPY,AUDJPY,EURJPY,CHFJPY,GBPCHF,XAUUSD,XAGUSD";
extern string Symbol_Name_Prefix = "";
extern string Symbol_Name_Suffix = "";
extern string ________1________="быстрый мувинг";
extern int FAST_EMA=10;
extern string ________2________="медленный мувинг";
extern int SLOW_EMA=100;
extern string ________3________="Kperiod - стохастика";
extern int Kperiod=20;
extern string ________4________="Dperiod - стохастика";
extern int Dperiod=30;
extern string ________5________="замедление - стохастика";
extern int slowing=15;


string gsa_100[];
string g_str_concat_104;
double gda_112[3][6];
bool gi_unused_116 = TRUE;
int gi_120;
int g_datetime_124;
string g_name_128 = "checkver.csv";
int file_8;

int init() {
   int file_0;
   int error_4;
   int str2time_8;
   string ls_12;
   int li_20;
   f0_2(Symbols_To_Display);
   f0_4();
   g_str_concat_104 = StringConcatenate("TC_", Period(), "_");
   ArrayInitialize(gda_112, -1);
   bool li_24 = TRUE;
   if (f0_14(g_name_128)) {
      file_0 = FileOpen(g_name_128, FILE_CSV|FILE_READ, ",");
      if (file_0 > 0) {
         if (FileIsEnding(file_0) == FALSE) {
            ls_12 = FileReadString(file_0);
            str2time_8 = StrToTime(ls_12);
         }
         FileClose(file_0);
      }
      if (str2time_8 > TimeCurrent() - 259200) li_24 = FALSE;
   }
   if (li_24) {
      if (f0_14(g_name_128)) FileDelete(g_name_128);
      file_0 = FileOpen(g_name_128, FILE_CSV|FILE_WRITE|FILE_READ, ",");
      if (file_0 > 0) {
         FileSeek(file_0, 0, SEEK_END);
         li_20 = FileWrite(file_0, TimeCurrent());
         FileClose(file_0);
      } else {
         error_4 = GetLastError();
         if (error_4 > 0/* NO_ERROR */) Print(StringConcatenate(g_name_128, " Error File error=", error_4));
      }
      string lsa_28[2] = {"ForexTrendConsole", "Check for updates"};
      CheckVersion(2.0, lsa_28);
   }
   return (0);
}

int deinit() {
   ObjectsDeleteAll(0);
   return (0);
}

int f0_14(string a_name_0) {
   int file_8 = FileOpen(a_name_0, FILE_READ);
   if (file_8 < 1) return (0);
   FileClose(file_8);
   return (1);
}

int f0_1() {
   bool li_ret_0 = FALSE;
   if (g_datetime_124 < iTime(NULL, 0, 0)) {
      g_datetime_124 = iTime(NULL, 0, 0);
      li_ret_0 = TRUE;
   }
   return (li_ret_0);
}

void f0_4() {
   int li_16;
   string str_concat_0 = StringConcatenate("Head_", 1);
   string ls_8 = "Desk to trade";
   f0_3(str_concat_0, ls_8, 10, 3, DodgerBlue, 20);
   str_concat_0 = StringConcatenate("Head_", 2);
   ls_8 = "v" + DoubleToStr(2.0, 2);
   f0_3(str_concat_0, ls_8, 275, 13, DodgerBlue, 13);
   str_concat_0 = StringConcatenate("Head_", 3);
   ls_8 = "trend your friend";
   f0_3(str_concat_0, ls_8, 10, 33, DodgerBlue, 13);
   str_concat_0 = StringConcatenate("Head_", 4);
   ls_8 = StringConcatenate("Trend Detection Time Frame: ", f0_7(Period()));
   f0_3(str_concat_0, ls_8, 10, 55, DodgerBlue, 13);
   int x_20 = 665;
   int li_24 = -5;
   for (int li_28 = 1; li_28 <= 3; li_28++) {
      li_16 = 15 * li_28;
      str_concat_0 = StringConcatenate("Legend_", li_28, "_", x_20, "_", li_24 + li_16);
      if (ObjectFind(str_concat_0) == -1) {
         ObjectCreate(str_concat_0, OBJ_LABEL, 0, 0, 0);
         ObjectSet(str_concat_0, OBJPROP_CORNER, 0);
         ObjectSet(str_concat_0, OBJPROP_COLOR, Blue);
         ObjectSet(str_concat_0, OBJPROP_XDISTANCE, x_20);
         ObjectSet(str_concat_0, OBJPROP_YDISTANCE, li_24 + li_16);
         ObjectSetText(str_concat_0, "n", 15, "Wingdings", f0_0(li_28, 1));
      }
   }
   str_concat_0 = StringConcatenate("Legend_", 0);
   ls_8 = "Legend: ";
   f0_3(str_concat_0, ls_8, 666, 2, DodgerBlue, 8);
   str_concat_0 = StringConcatenate("Legend_", 1);
   ls_8 = "= Strong down trend ";
   f0_3(str_concat_0, ls_8, 683, 14, DodgerBlue, 8);
   str_concat_0 = StringConcatenate("Legend_", 2);
   ls_8 = "= Neutral ";
   f0_3(str_concat_0, ls_8, 683, 29, DodgerBlue, 8);
   str_concat_0 = StringConcatenate("Legend_", 3);
   ls_8 = "= Strong up trend ";
   f0_3(str_concat_0, ls_8, 683, 44, DodgerBlue, 8);
   f0_9(0, "WndSignals", 500, 1, 260, 500, White);
   str_concat_0 = StringConcatenate("SignalsH_", 1);
   ls_8 = StringConcatenate("Trading Signals for ", f0_7(Period()), ": ");
   f0_3(str_concat_0, ls_8, 560, 120, Blue, 12);
   str_concat_0 = StringConcatenate("SignalsH_", 2);
   ls_8 = "(By broker time) ";
   f0_3(str_concat_0, ls_8, 560, 140, Blue, 8);
   str_concat_0 = StringConcatenate("Signal_", 1, "_1");
   f0_10(str_concat_0, "No signals yet. ", 560, 170, DodgerBlue, 12);
}

void f0_10(string a_name_0, string a_text_8, int a_x_16, int a_y_20, color a_color_24, int a_fontsize_28) {
   if (ObjectFind(a_name_0) == -1) ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, 0);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_16);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_20);
   ObjectSetText(a_name_0, a_text_8, a_fontsize_28, "Arial", a_color_24);
}

void f0_3(string a_name_0, string a_text_8, int a_x_16, int a_y_20, color a_color_24, int a_fontsize_28) {
   if (ObjectFind(a_name_0) == -1) ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, 0);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_16);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_20);
   ObjectSetText(a_name_0, a_text_8, a_fontsize_28, "Arial", a_color_24);
}

string f0_7(int ai_0) {
   string ls_ret_4;
   switch (ai_0) {
   case 1:
      ls_ret_4 = "1 Minute";
      break;
   case 5:
      ls_ret_4 = "5 Minutes";
      break;
   case 15:
      ls_ret_4 = "15 Minutes";
      break;
   case 30:
      ls_ret_4 = "30 Minutes";
      break;
   case 60:
      ls_ret_4 = "1 Hour";
      break;
   case 240:
      ls_ret_4 = "4 Hours";
      break;
   case 1440:
      ls_ret_4 = "Daily";
      break;
   case 10080:
      ls_ret_4 = "Weekly";
      break;
   case 43200:
      ls_ret_4 = "Monthly";
      break;
   default:
      ls_ret_4 = "1 Hour";
   }
   return (ls_ret_4);
}

int f0_0(int ai_0, int ai_4) {
   int li_ret_8;
   if (ai_4 == 0) {
      switch (ai_0) {
      case 1:
         li_ret_8 = 128;
         break;
      case 2:
         li_ret_8 = 2237106;
         break;
      case 3:
         li_ret_8 = 255;
         break;
      case 4:
         li_ret_8 = 4678655;
         break;
      case 5:
         li_ret_8 = 11119017;
         break;
      case 6:
         li_ret_8 = 3329434;
         break;
      case 7:
         li_ret_8 = 3329330;
         break;
      case 8:
         li_ret_8 = 32768;
         break;
      case 9:
         li_ret_8 = 25600;
         break;
      default:
         li_ret_8 = 16777215;
      }
   }
   if (ai_4 == 1) {
      switch (ai_0) {
      case 1:
         li_ret_8 = 128;
         break;
      case 2:
         li_ret_8 = 11119017;
         break;
      case 3:
         li_ret_8 = 25600;
         break;
      default:
         li_ret_8 = 11119017;
      }
   }
   return (li_ret_8);
}

int f0_8(int ai_0) {
   int li_ret_4 = 10 * ai_0 + (ai_0 - 1);
   return (li_ret_4);
}

void f0_6(string a_text_0, int a_x_8, int a_y_12, int ai_16, int a_y_20, int ai_24) {
   int li_36;
   string str_concat_28 = StringConcatenate("Symb_", a_x_8, "_", a_y_12);
   if (ObjectFind(str_concat_28) == -1) {
      ObjectCreate(str_concat_28, OBJ_LABEL, 0, 0, 0);
      ObjectSet(str_concat_28, OBJPROP_CORNER, 0);
      ObjectSet(str_concat_28, OBJPROP_COLOR, DodgerBlue);
      ObjectSet(str_concat_28, OBJPROP_XDISTANCE, a_x_8);
      ObjectSet(str_concat_28, OBJPROP_YDISTANCE, a_y_12);
      ObjectSetText(str_concat_28, a_text_0, 13, "Arial", DodgerBlue);
   }
   for (int li_40 = 1; li_40 <= 9; li_40++) {
      li_36 = 11 * li_40;
      str_concat_28 = StringConcatenate("B", li_40, "_", ai_16 + li_36, "_", a_y_20);
      if (ObjectFind(str_concat_28) == -1) {
         ObjectCreate(str_concat_28, OBJ_LABEL, 0, 0, 0);
         ObjectSet(str_concat_28, OBJPROP_CORNER, 0);
         ObjectSet(str_concat_28, OBJPROP_COLOR, Blue);
         ObjectSet(str_concat_28, OBJPROP_XDISTANCE, ai_16 + li_36);
         ObjectSet(str_concat_28, OBJPROP_YDISTANCE, a_y_20);
         ObjectSetText(str_concat_28, "n", 15, "Wingdings", f0_0(li_40, 0));
      }
   }
   str_concat_28 = StringConcatenate("Arrow_", ai_16, "_", a_y_20);
   if (ObjectFind(str_concat_28) == -1) ObjectCreate(str_concat_28, OBJ_LABEL, 0, 0, 0);
   if (ai_24 > 0) {
      ObjectSet(str_concat_28, OBJPROP_CORNER, 0);
      ObjectSet(str_concat_28, OBJPROP_COLOR, DodgerBlue);
      ObjectSet(str_concat_28, OBJPROP_XDISTANCE, ai_16 + f0_8(ai_24));
      ObjectSet(str_concat_28, OBJPROP_YDISTANCE, a_y_20 - 9);
      ObjectSetText(str_concat_28, "q", 12, "Wingdings 3", DodgerBlue);
      return;
   }
   ObjectSet(str_concat_28, OBJPROP_CORNER, 0);
   ObjectSet(str_concat_28, OBJPROP_COLOR, DodgerBlue);
   ObjectSet(str_concat_28, OBJPROP_XDISTANCE, ai_16 + 54);
   ObjectSet(str_concat_28, OBJPROP_YDISTANCE, a_y_20 - 7);
   ObjectSetText(str_concat_28, "N/A", 7, "Arial", DodgerBlue);
}

void f0_2(string as_0) {
   int lia_20[];
   int li_12 = 0;
   int count_16 = 0;
   for (int li_8 = 0; li_8 < StringLen(as_0); li_8++) {
      if (StringGetChar(as_0, li_8) == ',') {
         count_16++;
         if (count_16 >= 0) {
            li_12++;
            ArrayResize(lia_20, li_12);
            lia_20[li_12 - 1] = li_8;
         }
      }
   }
   ArrayResize(gsa_100, li_12 + 1);
   gsa_100[0] = StringSubstr(as_0, 0, lia_20[0]);
   for (li_8 = 1; li_8 <= li_12; li_8++) gsa_100[li_8] = StringSubstr(as_0, lia_20[li_8 - 1] + 1, lia_20[li_8] - (lia_20[li_8 - 1]) - 1);
}

int f0_5(string a_symbol_0) {
   int li_ret_8 = -1;
   double ima_12 = iMA(a_symbol_0, 0, FAST_EMA, 0, MODE_EMA, PRICE_CLOSE, 30);
   double ima_20 = iMA(a_symbol_0, 0, FAST_EMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ima_28 = iMA(a_symbol_0, 0, SLOW_EMA, 0, MODE_EMA, PRICE_CLOSE, 100);
   double ima_36 = iMA(a_symbol_0, 0, SLOW_EMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   

   
   
   if (ima_20 - ima_12 > 0.0 && ima_36 - ima_28 > 0.0) li_ret_8 = 0;
   else
      if (ima_20 - ima_12 < 0.0 && ima_36 - ima_28 < 0.0) li_ret_8 = 1;
   return (li_ret_8);
}

int f0_11(string a_symbol_0) {
   int li_ret_8 = 5;
 //  double istochastic_eurusd = iStochastic(EURUSD, 0, 20, 30, 15, MODE_SMMA, 0, MODE_MAIN, 0);
 //   double istochastic_nzdusd = iStochastic(NZDUSD, 0, 20, 30, 15, MODE_SMMA, 0, MODE_MAIN, 0);
 //  GlobalVariableSet("istochastic_eurusd"+Period(),istochastic_eurusd);
 //  GlobalVariableSet("istochastic_nzdusd"+Period(),istochastic_nzdusd);
   double istochastic_12 = iStochastic(a_symbol_0, 0, Kperiod, Dperiod, slowing, MODE_SMMA, 0, MODE_MAIN, 0);
  /*
   if (istochastic_12 > 50.0) li_ret_8 = 6;
   if (istochastic_12 > 65.0) li_ret_8 = 7;
   if (istochastic_12 > 70.0) li_ret_8 = 8;
   if (istochastic_12 > 80.0) li_ret_8 = 9;
   if (istochastic_12 <= 50.0) li_ret_8 = 4;
   if (istochastic_12 < 35.0) li_ret_8 = 3;
   if (istochastic_12 < 30.0) li_ret_8 = 2;
   if (istochastic_12 < 20.0) li_ret_8 = 1;
  */
   if (istochastic_12 > 0.0 && istochastic_12 <= 20.0) li_ret_8 = 1;
   if (istochastic_12 > 20.0 && istochastic_12 <= 30.0) li_ret_8 = 2;
   if (istochastic_12 > 30.0 && istochastic_12 <= 35.0) li_ret_8 = 3;
   if (istochastic_12 > 35.0 && istochastic_12 <= 47.0) li_ret_8 = 4;
   if (istochastic_12 > 47.0 && istochastic_12 <= 52.0) li_ret_8 = 5;
   if (istochastic_12 > 52.0 && istochastic_12 <= 65.0) li_ret_8 = 6;
   if (istochastic_12 > 65.0 && istochastic_12 <= 70.0) li_ret_8 = 7;
   if (istochastic_12 > 70.0 && istochastic_12 <= 80.0) li_ret_8 = 8;
   if (istochastic_12 > 80.0 && istochastic_12 <= 100.0) li_ret_8 = 9;
 
   
   
   
   return (li_ret_8);
}

// проверяем состояние рынка для каждой валюты 

 


void f0_9(int a_window_0, string as_4, double a_x_12, double a_y_20, double ad_28, double ad_36, color a_color_44) {
   double fontsize_48;
   double fontsize_56;
   double ld_64;
   int li_72;
   if (ad_28 > ad_36) {
      li_72 = MathCeil(ad_28 / ad_36);
      fontsize_48 = MathRound(100.0 * ad_36 / 77.0);
      fontsize_56 = MathRound(100.0 * ad_28 / 77.0);
      ld_64 = fontsize_56 / li_72 - 2.0 * (fontsize_48 / (9 - ad_36 / 100.0));
      for (int count_76 = 0; count_76 < li_72; count_76++) {
         ObjectCreate(as_4 + count_76, OBJ_LABEL, a_window_0, 0, 0);
         ObjectSetText(as_4 + count_76, CharToStr(110), fontsize_48, "Wingdings", a_color_44);
         ObjectSet(as_4 + count_76, OBJPROP_XDISTANCE, a_x_12 + ld_64 * count_76);
         ObjectSet(as_4 + count_76, OBJPROP_YDISTANCE, a_y_20);
         ObjectSet(as_4 + count_76, OBJPROP_BACK, TRUE);
      }
   } else {
      li_72 = MathCeil(ad_36 / ad_28);
      fontsize_48 = MathRound(100.0 * ad_36 / 77.0);
      fontsize_56 = MathRound(100.0 * ad_28 / 77.0);
      ld_64 = fontsize_48 / li_72 - 2.0 * (fontsize_56 / (9 - ad_28 / 100.0));
      for (count_76 = 0; count_76 < li_72; count_76++) {
         ObjectCreate(as_4 + count_76, OBJ_LABEL, a_window_0, 0, 0);
         ObjectSetText(as_4 + count_76, CharToStr(110), fontsize_56, "Wingdings", a_color_44);
         ObjectSet(as_4 + count_76, OBJPROP_XDISTANCE, a_x_12);
         ObjectSet(as_4 + count_76, OBJPROP_YDISTANCE, a_y_20 + ld_64 * count_76);
         ObjectSet(as_4 + count_76, OBJPROP_BACK, TRUE);
      }
   }
}

void f0_13() {
   string str_concat_0;
   string str_concat_8;
   string str_concat_16;
   string str_concat_24;
   string str_concat_32;
   string ls_40;
   string ls_48;
   int li_56;
   for (int index_60 = 0; index_60 <= 2; index_60++) {
      if (gda_112[index_60][1] > -1.0) {
         li_56 = gda_112[index_60][1];
         if (gda_112[index_60][5] == 1.0) {
            if (gda_112[index_60][2] == 0.0) {
               ls_40 = "BUY";
               ls_48 = "oversold";
            } else {
               ls_40 = "SELL";
               ls_48 = "overbought";
            }
            str_concat_8 = StringConcatenate(gsa_100[li_56], " was in extreme ");
            str_concat_16 = StringConcatenate(ls_48, " and now recovered.");
            str_concat_24 = StringConcatenate("Counter-trend ", ls_40, " signal ");
            str_concat_32 = StringConcatenate("at ", gda_112[index_60][4]);
         } else {
            if (gda_112[index_60][5] == 2.0) {
               if (gda_112[index_60][2] == 0.0) {
                  ls_40 = "BUY";
                  ls_48 = "overbought";
               } else {
                  ls_40 = "SELL";
                  ls_48 = "oversold";
               }
               str_concat_8 = StringConcatenate(gsa_100[li_56], " continues to be");
               str_concat_16 = StringConcatenate(ls_48, ". Trend following");
               str_concat_24 = StringConcatenate(ls_40, " signal triggered at ");
               str_concat_32 = StringConcatenate("price ", gda_112[index_60][4]);
            }
         }
         str_concat_0 = StringConcatenate("Signal_", index_60 + 1, "_1");
         f0_10(str_concat_0, StringConcatenate(TimeToStr(gda_112[index_60][3], TIME_DATE|TIME_MINUTES), ":"), 560, 20 * index_60 + 170 + 90 * index_60, DodgerBlue, 12);
         str_concat_0 = StringConcatenate("Signal_", index_60 + 1, "_2");
         f0_10(str_concat_0, str_concat_8, 560, 20 * index_60 + 190 + 90 * index_60, DodgerBlue, 12);
         str_concat_0 = StringConcatenate("Signal_", index_60 + 1, "_3");
         f0_10(str_concat_0, str_concat_16, 560, 20 * index_60 + 210 + 90 * index_60, DodgerBlue, 12);
         str_concat_0 = StringConcatenate("Signal_", index_60 + 1, "_4");
         f0_10(str_concat_0, str_concat_24, 560, 20 * index_60 + 230 + 90 * index_60, DodgerBlue, 12);
         str_concat_0 = StringConcatenate("Signal_", index_60 + 1, "_5");
         f0_10(str_concat_0, str_concat_32, 560, 20 * index_60 + 250 + 90 * index_60, DodgerBlue, 12);
      }
   }
}

void f0_12(int ai_0, int ai_4, int ai_8, double ad_12, int ai_20) {
   int li_24 = -1;
   int li_28 = -1;
   for (int li_32 = 2; li_32 >= 0; li_32--) {
      if (gda_112[li_32][1] == ai_0) li_24 = li_32;
      if (gda_112[li_32][1] == -1.0) li_28 = li_32;
   }
   if (li_28 > -1 && li_24 == -1) {
      gda_112[li_28][1] = ai_0;
      gda_112[li_28][2] = ai_4;
      gda_112[li_28][3] = ai_8;
      gda_112[li_28][4] = ad_12;
      gda_112[li_28][5] = ai_20;
      gi_120++;
      return;
   }
   if (li_28 == -1 && li_24 == -1) {
      gda_112[0][1] = gda_112[1][1];
      gda_112[0][2] = gda_112[1][2];
      gda_112[0][3] = gda_112[1][3];
      gda_112[0][4] = gda_112[1][4];
      gda_112[0][5] = gda_112[1][5];
      gda_112[1][1] = gda_112[2][1];
      gda_112[1][2] = gda_112[2][2];
      gda_112[1][3] = gda_112[2][3];
      gda_112[1][4] = gda_112[2][4];
      gda_112[1][5] = gda_112[2][5];
      gda_112[2][1] = ai_0;
      gda_112[2][2] = ai_4;
      gda_112[2][3] = ai_8;
      gda_112[2][4] = ad_12;
      gda_112[2][5] = ai_20;
      gi_120++;
      return;
   }
   if (li_28 > -1 && li_24 > -1 && gda_112[li_24][2] != ai_4) {
      gda_112[li_28][1] = ai_0;
      gda_112[li_28][2] = ai_4;
      gda_112[li_28][3] = ai_8;
      gda_112[li_28][4] = ad_12;
      gda_112[li_28][5] = ai_20;
      gi_120++;
      return;
   }
   if (li_28 == -1 && li_24 > -1 && gda_112[li_24][2] != ai_4) {
      gda_112[li_24][1] = ai_0;
      gda_112[li_24][2] = ai_4;
      gda_112[li_24][3] = ai_8;
      gda_112[li_24][4] = ad_12;
      gda_112[li_24][5] = ai_20;
      gi_120++;
   }
}

int start() {
   string symbol_8;
   int li_16;
   int li_24;
   int li_28;
   bool li_0 = f0_1();
   if (li_0) gi_120 = 1;
   int index_4 = 0;
   for (int count_32 = 0; count_32 <= 1; count_32++) {
      for (int li_36 = 1; li_36 <= 8; li_36++) {
         symbol_8 = gsa_100[index_4];
         li_28 = 5;
         li_16 = f0_5(symbol_8);
         li_24 = f0_11(symbol_8);
         if (li_16 == 0) {
            if (li_24 >= 6) li_28 = li_24;
            if (li_24 <= 4) li_28 = 4;
            if (li_24 <= 2) li_28 = 3;
         }
         if (li_16 == 1) {
            if (li_24 <= 4) li_28 = li_24;
            if (li_24 >= 6) li_28 = 6;
            if (li_24 >= 8) li_28 = 7;
         }
         f0_6(symbol_8, 300 * count_32 + 8, 70 * li_36 + 32, 300 * count_32 + 85, 70 * li_36 + 30, li_28);
         RefreshRates();
         if (GlobalVariableGet(StringConcatenate(g_str_concat_104, "ExtremeBuy_", index_4)) == 1.0 && li_28 == 3) {
            if (gi_120 <= 3) f0_12(index_4, 0, TimeCurrent(), MarketInfo(symbol_8, MODE_BID), 1);
         } else {
            if (GlobalVariableGet(StringConcatenate(g_str_concat_104, "ExtremeSell_", index_4)) == 1.0 && li_28 == 7)
               if (gi_120 <= 3) f0_12(index_4, 1, TimeCurrent(), MarketInfo(symbol_8, MODE_BID), 1);
         }
         if (li_28 == 1) {
            GlobalVariableSet(StringConcatenate(g_str_concat_104, "ExtremeBuy_", index_4), 1);
            if (gi_120 <= 1) f0_12(index_4, 1, TimeCurrent(), MarketInfo(symbol_8, MODE_BID), 2);
         }
         if (li_28 > 2 && li_28 <= 5) GlobalVariableSet(StringConcatenate(g_str_concat_104, "ExtremeBuy_", index_4), 0);
         if (li_28 == 9) {
            GlobalVariableSet(StringConcatenate(g_str_concat_104, "ExtremeSell_", index_4), 1);
            if (gi_120 <= 1) f0_12(index_4, 0, TimeCurrent(), MarketInfo(symbol_8, MODE_BID), 2);
         }
         if (li_28 < 8 && li_28 >= 5) GlobalVariableSet(StringConcatenate(g_str_concat_104, "ExtremeSell_", index_4), 0);
         index_4++;
      }
   }
   f0_13();
   return (0);
}