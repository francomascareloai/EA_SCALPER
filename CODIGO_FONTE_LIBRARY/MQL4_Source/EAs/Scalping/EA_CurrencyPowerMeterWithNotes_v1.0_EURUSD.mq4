
#property copyright "Russ Horn Forex Master Method"
#property link      "www.forexmastermethod.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Black

/* #import "wininet.dll"
   int InternetOpenA(string a0, int a1, string a2, string a3, int a4);
   int InternetOpenUrlA(int a0, string a1, string a2, int a3, int a4, int a5);
   int InternetReadFile(int a0, string a1, int a2, int& a3[]);
   int InternetCloseHandle(int a0);
#import 
*/

extern string note = " ======= Authentication SETTINGS ======";
extern string username = "";
extern string password = "";
extern double LowValue = 2.0;
extern double MaxValue = 8.0;
extern string PairAlert = "";
extern int AlertDelay = 30;
extern int Hours = 1;
extern int Corner = 1;
extern string shiftY_rule = "Corner=0 или1:shiftY=40__Corner=2 или3:shiftY=0";
extern int shiftY = 40;
extern string sOutput = "EUR,GBP,AUD,NZD,USD,CAD,CHF,JPY";
extern string sPairs = "EURUSD,EURGBP,EURCHF,EURJPY,EURAUD,EURNZD,GBPUSD,AUDUSD,NZDUSD,USDJPY,USDCHF,USDCAD,EURCAD,CADJPY,GBPJPY,GBPCHF";
extern color cCurrency = Lime;
extern color cScoreHigh = Aqua;
extern color cScoreHour = Orange;
string pairs[32];
string outputCurrencies[16];
int gia_168[8] = {40, 10, 160, 130, 190, 70, 220, 100,250,280,310,340};
int gia_172[] = {16612911, 16620590, 16702510, 15990063, 11206190, 5569869, 4193654, 3669164, 3407316, 3144445, 3144189, 3138813, 3069181, 3126526, 3046654, 3098621, 4207864, 4207864, 4207864, 4207864};
int distributionRanges[11] = {0, 4, 11, 23, 39, 50, 61, 78, 89, 96, 100};
int pairsNr = 32;
int outputCurrenciesNr = 16;

double resultstDailyTf[16];
double positiveDistributionDaily[32];
double negativeDistributionDaily[32];
double resultstMyPeriod[16];
double negativeDistributionMyPeriod[32];
double positiveDistributionMyPeriod[32];
int g_datetime_212 = 0;
int g_str2int_216 = 0;
bool authenticated = TRUE;
bool toCheckAuthentication = TRUE;
int gia_228[64] = {65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47};
int gi_232 = 1;
string gs_dummy_236;
int gi_244 = 0;
int gi_248 = 0;
int g_count_252 = 0;
string gs_256;
int gia_264[1];
string gs_272 = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
//____________________________________________________________________________________________________
int init() 
   {
      int li_12;
      g_str2int_216 = 0;
      authenticated = TRUE;
      toCheckAuthentication = TRUE;
      string ls_0 = sOutput;
      int index_8 = 0;
      while (StringLen(ls_0) > 0) 
         {
            li_12 = StringFind(ls_0, ",");
            outputCurrencies[index_8] = StringSubstr(ls_0, 0, 3);
            ls_0 = StringSubstr(ls_0, li_12 + 1);
            index_8++;
            if (li_12 < 0) break;
         }
      outputCurrenciesNr = index_8;
      if (outputCurrenciesNr > 16) 
         {
            outputCurrenciesNr = 16;
            Comment("\n\n ERRORR:\n  Maximum NUMBER of Output Currencies is 16 \n Only first 16 will be taken");
         }
      //---
      index_8 = 0;
      ls_0 = sPairs;
      while (StringLen(ls_0) > 0) {
         li_12 = StringFind(ls_0, ",");
         pairs[index_8] = StringSubstr(ls_0, 0, li_12);
         ls_0 = StringSubstr(ls_0, li_12 + 1);
         index_8++;
         if (li_12 < 0) break;
      }
      pairsNr = index_8;
      if (pairsNr > 32) {
         pairsNr = 32;
         Comment("\n\n ERRORR:\n  Maximum NUMBER of Pairs is 32 \n Only first 32 will be taken");
      }
      Print("PairCount:", pairsNr);
      for (int index_16 = 0; index_16 < outputCurrenciesNr; index_16++) {
         for (int count_20 = 0; count_20 < 20; count_20++) {
            objectCreate("CPM" + outputCurrencies[index_16] + count_20, 7 * (21 - count_20), gia_168[index_16]);
            objectCreate("CPM" + outputCurrencies[index_16] + count_20 + "x", 7 * (21 - count_20), gia_168[index_16] - 5);
            objectCreate("CPM" + outputCurrencies[index_16] + count_20 + "h", 7 * (21 - count_20), gia_168[index_16] + 10);
         }
         objectCreate("CPM" + outputCurrencies[index_16], 195, gia_168[index_16] + 10 + shiftY, outputCurrencies[index_16], 9, "Verdana", cCurrency);
         objectCreate("CPM" + outputCurrencies[index_16] + "_Str", 170, gia_168[index_16] + 7 + shiftY, DoubleToStr(0, 1), 8, "Verdana", cScoreHigh);
         objectCreate("CPM" + outputCurrencies[index_16] + "_Str_h", 170, gia_168[index_16] + 20 + shiftY, DoubleToStr(0, 1), 8, "Verdana", cScoreHour);
      }
      ObjectsRedraw();
      return (0);
   }
//____________________________________________________________________________________________________
int start() {
   string text_0;
   int countDailyTf;
   int countMyPeriod;
   string pair;
   double sumDaily;
   double sumMyPeriod;
   double dailyLow, currentLow, currentHigh;
   double priceRelativePosition;
   //double ld_72;
   double bid;
   double dailyRange;
   
   if (toCheckAuthentication == TRUE && g_str2int_216 == 0) 
      {
         ObjectCreate("CPMerror", OBJ_LABEL, 0, 0, 0);
         ObjectSet("CPMerror", OBJPROP_CORNER, 0);
         ObjectSet("CPMerror", OBJPROP_COLOR, Red);
         ObjectSet("CPMerror", OBJPROP_XDISTANCE, 100);
         ObjectSet("CPMerror", OBJPROP_YDISTANCE, 30);
         text_0 = "Authentication ...";
         ObjectSetText("CPMerror", text_0, 16, "Verdana", Red);
         // g_str2int_216 = StrToInteger(authentication(username, password));
         if (2 + 2 == 4) 
            {
               authenticated = TRUE;
               ObjectDelete("CPMerror");
            } 
         else 
            {
               text_0 = "CPM Auth FAILED email to support@forexmastermethod.com";
               authenticated = FALSE;
               if (g_str2int_216 == 0) text_0 = text_0 + " Err:021";
               if (g_str2int_216 == 4) text_0 = text_0 + " Err:024";
               ObjectSetText("CPMerror", text_0, 14, "Verdana", Red);
            }
         toCheckAuthentication = FALSE;
      }
   //---
   double pipValue = 0.01;
   if (authenticated == TRUE) 
      {
         for (int index_8 = 0; index_8 < pairsNr; index_8++) 
            {
               RefreshRates();
               pipValue = 0.0001;
               pair = pairs[index_8];
               if (StringSubstr(pair, 3, 3) == "JPY") pipValue = 0.01;
               dailyLow = MarketInfo(pair, MODE_LOW);
               dailyRange = MarketInfo(pair, MODE_HIGH) - dailyLow;
               bid = MarketInfo(pair, MODE_BID);
               priceRelativePosition = (bid - dailyLow) / MathMax(dailyRange, pipValue);
               positiveDistributionDaily[index_8] = CheckRatio(100.0 * priceRelativePosition);
               negativeDistributionDaily[index_8] = 9.9 - CheckRatio(100.0 * priceRelativePosition);
               //---
               currentLow = MyLowest(pair);
               currentHigh = MyHighest(pair);
               priceRelativePosition = (bid - currentLow) / MathMax(currentHigh - currentLow, pipValue);
               positiveDistributionMyPeriod[index_8] = CheckRatio(100.0 * priceRelativePosition);
               negativeDistributionMyPeriod[index_8] = 9.9 - CheckRatio(100.0 * priceRelativePosition);
            }
         //---
         for (int index_12 = 0; index_12 < outputCurrenciesNr; index_12++)
            {
               countDailyTf = 0;
               countMyPeriod = 0;
               sumDaily = 0;
               sumMyPeriod = 0;
               for (index_8 = 0; index_8 < pairsNr; index_8++) 
                  {
                     if (StringSubstr(pairs[index_8], 0, 3) == outputCurrencies[index_12]) 
                        {
                           sumDaily += positiveDistributionDaily[index_8];
                           countDailyTf++;
                           sumMyPeriod += positiveDistributionMyPeriod[index_8];
                           countMyPeriod++;
                        }
                    
                    if (StringSubstr(pairs[index_8], 3, 3) == outputCurrencies[index_12]) 
                        {
                           sumDaily += negativeDistributionDaily[index_8];
                           countDailyTf++;
                           sumMyPeriod += negativeDistributionMyPeriod[index_8];
                           countMyPeriod++;
                        }
                  
                   if (countDailyTf > 0) 
                       {resultstDailyTf[index_12] = NormalizeDouble(sumDaily / countDailyTf, 1);}
                   else 
                       {resultstDailyTf[index_12] = -1;}
                  
                   if (countMyPeriod > 0) 
                       {resultstMyPeriod[index_12] = NormalizeDouble(sumMyPeriod / countMyPeriod, 1);}
                   else 
                       {resultstMyPeriod[index_12] = -1;}
            }
      } //end if (authenticated == TRUE) 
      //---
      for (index_12 = 0; index_12 < outputCurrenciesNr; index_12++) 
         {
            ShowData(index_12);
            if (resultstDailyTf[index_12] < LowValue && StringFind(PairAlert, outputCurrencies[index_12]) != -1 && TimeCurrent() - g_datetime_212 > AlertDelay) 
               {
                  PlaySound("news.wav");
                  g_datetime_212 = TimeCurrent();
               }
            if (resultstDailyTf[index_12] > MaxValue && StringFind(PairAlert, outputCurrencies[index_12]) != -1 && TimeCurrent() - g_datetime_212 > AlertDelay) 
               {
                  PlaySound("news.wav");
                  g_datetime_212 = TimeCurrent();
               }
        }
   }
   return (0);
}
//____________________________________________________________________________________________________
int CheckRatio(double ad_0) 
   {
      int result = -1;
      if (ad_0 <= 0.0) 
         {result = 0;}
      else 
         {
            for (int index_12 = 0; index_12 < 11; index_12++) 
               {
                  if (ad_0 < distributionRanges[index_12]) //int distributionRanges[11] = {0, 4, 11, 23, 39, 50, 61, 78, 89, 96, 100};
                     {
                        result = index_12 - 1;
                        break;
                     }
               }
               if (result == -1) result = 9.9;
         }
      //---  
      return (result);
   }
//____________________________________________________________________________________________________
double MyLowest(string pair) {
   double ilow_8 = iLow(pair, 0, 0);  //current timeframe current bar low
   int timeframe_16 = 15;
   int li_20 = 4;
   if (Hours < 3) {
      timeframe_16 = 5;
      li_20 = 12;
   }
   
   for (int li_24 = 0; li_24 < Hours * li_20; li_24++) //
      if (ilow_8 > iLow(pair, timeframe_16, li_24)) ilow_8 = iLow(pair, timeframe_16, li_24);
   return (ilow_8);
   /*
   in case of Hours == 2
   for (int li_24 = 0; li_24 < 24; li_24++) // 0 to 23
      if (ilow_8 > iLow(pair, M5, li_24)) ilow_8 = iLow(pair, timeframe_16, li_24); //lowest low of current timeframe or of M5 in the last 2 hours
   return (ilow_8);
   
   in case of Hours == 4
   for (int li_24 = 0; li_24 < 16; li_24++) // 0 to 16
      if (ilow_8 > iLow(pair, M15, li_24)) ilow_8 = iLow(pair, timeframe_16, li_24); //lowest low of current timeframe or of M15 in the last 4 hours
   return (ilow_8);   
   */
}
//____________________________________________________________________________________________________
double MyHighest(string pair) {
   double ihigh_8 = iHigh(pair, 0, 0);
   int timeframe_16 = 15;
   int li_20 = 4;
   if (Hours < 3) {
      timeframe_16 = 5;
      li_20 = 12;
   }
   for (int li_24 = 0; li_24 < Hours * li_20; li_24++)
      if (ihigh_8 < iHigh(pair, timeframe_16, li_24)) ihigh_8 = iHigh(pair, timeframe_16, li_24);
   return (ihigh_8);
}
//____________________________________________________________________________________________________
void objectCreate(string a_name_0, int a_x_8, int a_y_12, string a_text_16 = ".", int a_fontsize_24 = 42, string a_fontname_28 = "Arial", color a_color_36 = -1) {
   ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, Corner);
   ObjectSet(a_name_0, OBJPROP_COLOR, a_color_36);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_8);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_12);
   ObjectSetText(a_name_0, a_text_16, a_fontsize_24, a_fontname_28, a_color_36);
}
//____________________________________________________________________________________________________
void ShowData(int ai_0) {
   double ld_4 = 0;
   for (int index_12 = 0; index_12 < 20; index_12++) {
      ld_4 = index_12;
      if (resultstDailyTf[ai_0] > ld_4 / 2.0) {
         ObjectSet("CPM" + outputCurrencies[ai_0] + index_12, OBJPROP_COLOR, gia_172[index_12]);
         ObjectSet("CPM" + outputCurrencies[ai_0] + index_12 + "x", OBJPROP_COLOR, gia_172[index_12]);
      } else {
         ObjectSet("CPM" + outputCurrencies[ai_0] + index_12, OBJPROP_COLOR, CLR_NONE);
         ObjectSet("CPM" + outputCurrencies[ai_0] + index_12 + "x", OBJPROP_COLOR, CLR_NONE);
      }
      if (resultstMyPeriod[ai_0] > ld_4 / 2.0) ObjectSet("CPM" + outputCurrencies[ai_0] + index_12 + "h", OBJPROP_COLOR, gia_172[index_12]);
      else ObjectSet("CPM" + outputCurrencies[ai_0] + index_12 + "h", OBJPROP_COLOR, CLR_NONE);
   }
   ObjectSetText("CPM" + outputCurrencies[ai_0] + "_Str", DoubleToStr(resultstDailyTf[ai_0], 1), 8, "Verdana", cScoreHigh);
   ObjectSetText("CPM" + outputCurrencies[ai_0] + "_Str_h", DoubleToStr(resultstMyPeriod[ai_0], 1), 8, "Verdana", cScoreHour);
}
//____________________________________________________________________________________________________
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
//____________________________________________________________________________________________________
string authentication(string as_0, string as_8) {
/*
   string ls_24;
   string ls_unused_32;
   string ls_16 = "mode=authenticate&username=" + as_0 + "&password=" + as_8;
   Base64Encode(ls_16, ls_24);
   return (LoadURL(ProcessURL("http://www.forexmastermethod.com/authea/cpm_auth.php?encoded=" + ls_24)));
*/
   return (1);
}
//____________________________________________________________________________________________________
void Base64Encode(string as_0, string &as_8) {
   int li_28;
   int li_32;
   int li_36;
   int li_40;
   int li_44;
   int li_48;
   int li_52;
   int li_16 = 0;
   int li_20 = 0;
   int str_len_24 = StringLen(as_0);
   while (li_16 < str_len_24) {
      li_36 = StringGetChar(as_0, li_16);
      li_16++;
      if (li_16 >= str_len_24) {
         li_32 = 0;
         li_28 = 0;
         li_20 = 2;
      } else {
         li_32 = StringGetChar(as_0, li_16);
         li_16++;
         if (li_16 >= str_len_24) {
            li_28 = 0;
            li_20 = 1;
         } else {
            li_28 = StringGetChar(as_0, li_16);
            li_16++;
         }
      }
      li_40 = li_36 >> 2;
      li_44 = (li_36 & 3 * 16) | li_32 >> 4;
      li_48 = (li_32 & 15 * 4) | li_28 >> 6;
      li_52 = li_28 & 63;
      as_8 = as_8 + CharToStr(gia_228[li_40]);
      as_8 = as_8 + CharToStr(gia_228[li_44]);
      switch (li_20) {
      case 0:
         as_8 = as_8 + CharToStr(gia_228[li_48]);
         as_8 = as_8 + CharToStr(gia_228[li_52]);
         break;
      case 1:
         as_8 = as_8 + CharToStr(gia_228[li_48]);
         as_8 = as_8 + "=";
         break;
      case 2:
         as_8 = as_8 + "==";
      }
   }
}
//____________________________________________________________________________________________________
/*
string LoadURL(string as_0) {
   g_count_252 = 0;
   for (gi_244 = FALSE; g_count_252 < 3 && gi_244 == FALSE; g_count_252++) {
      if (gi_248 != 0) gi_244 = InternetOpenUrlA(gi_248, as_0, 0, 0, -2079850240, 0);
      if (gi_244 == FALSE) {
         InternetCloseHandle(gi_248);
         gi_248 = InternetOpenA("mymt4InetSession", gi_232, 0, 0, 0);
      }
   }
   gs_256 = "";
   gia_264[0] = 1;
   while (gia_264[0] > 0) {
      InternetReadFile(gi_244, gs_272, 200, gia_264);
      if (gia_264[0] > 0) gs_256 = gs_256 + StringSubstr(gs_272, 0, gia_264[0]);
      if (StringSubstr(gs_272, 0, gia_264[0]) == "0") break;
      if (StringSubstr(gs_272, 0, gia_264[0]) == "4") break;
      if (StringSubstr(gs_272, 0, gia_264[0]) == "1") break;
   }
   InternetCloseHandle(gi_244);
   return (gs_256);
}

*/
//____________________________________________________________________________________________________
string ProcessURL(string as_0) {
   string ls_12;
   string ls_20;
   for (int li_8 = StringFind(as_0, " "); li_8 != -1; li_8 = StringFind(as_0, " ")) {
      ls_12 = StringTrimLeft(StringTrimRight(StringSubstr(as_0, 0, StringFind(as_0, " ", 0))));
      ls_20 = StringTrimLeft(StringTrimRight(StringSubstr(as_0, StringFind(as_0, " ", 0))));
      as_0 = ls_12 + "%20" + ls_20;
   }
   return (as_0);
}
//____________________________________________________________________________________________________