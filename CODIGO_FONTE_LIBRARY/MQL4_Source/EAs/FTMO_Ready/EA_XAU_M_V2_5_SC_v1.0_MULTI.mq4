//+------------------------------------------------------------------+
//|                                                 XAU MINER EA.mq4 |
//|                                   Copyright 2021,  ZHEIL COMPANY |
//|                                                                  |                              \
//+------------------------------------------------------------------+
#property copyright "XAU MINER"
#property link      "https://t.me/xauminerEA"
#property version     "1.00" #property strict directive
#property description   "MARTI PRO SCALPER COMBINED HEDGE "
#property description   "FXZHEIL"
#property description   "CURRENCY SETTING M30 timeframe 10000$Cents per 0.03lot starting"
#property description   "TIMEFRAME M30"
#property description   "FULL VERSION"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern string xXAUMINERx = "https://t.me/xauminerEA";
extern string LICENSED_TO = "=XAU MINER CHANNEL.=";
extern bool MARtiScalper = TRUE;
double Account = 123567;
extern string xxxxxxxxxxx = "35.176.119.134";
extern bool USEnewsFilter = TRUE;
extern string xxSETTINGSxx = "==>>MONEY MANAGEMENT SETTINGS<<==";
extern double Lots = 0.01;
extern double LotExponent = 1.55;
int Gi_108 = 2;
extern double MaxLots = 100.0;
extern bool MM = FALSE;
extern double TakeProfit = 200.0;
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
extern string xxxxxxxxxxxx = "Set Current Trade & Orders";
int MaxTrades_Hilo = 1000;
bool Gi_220 = FALSE;
double Gd_224 = 48.0;
extern bool UseTrailingStop_Hilo = FALSE;
double G_pips_236 = 500.0;
extern double TrailStart_Hilo = 10.0;
extern double TrailStop_Hilo = 5.0;
extern double PipStep_Hilo = 200.0;
double slip_Hilo = 3.0;
int MagicNumber_Hilo = 11111;
double G_price_280;
double Gd_288;
double Gd_unused_296;
double Gd_unused_304;
double G_price_312;
double G_bid_320;
double G_ask_328;
double Gd_336;
double Gd_344;
double Gd_352;
bool Gi_360;
string Gs_364 = "";
int Gi_372 = 123;
int Gi_376;
int Gi_380 = 123;
double Gd_384;
int G_pos_392 = 123;
int Gi_396;
double Gd_400 = 0.0;
bool Gi_408 = FALSE;
bool Gi_412 = FALSE;
bool Gi_416 = FALSE;
int Gi_420;
bool Gi_424 = FALSE;
double Gd_428;
double Gd_436;
extern string MartiPRO = ">>=============<< ";
int MaxTrades_15 = 1000;
int G_timeframe_496 = PERIOD_H1;
extern bool UseTrailingStop_15 = FALSE;
double G_pips_508 = 500.0;
extern double TrailStart_15 = 10.0;
extern double TrailStop_15 = 5.0;
bool Gi_532 = FALSE;
double Gd_536 = 48.0;
extern double PipStep_15 = 200.0;
double slip_15 = 3.0;
int G_magic_176_15 = 12324;
double G_price_564;
double Gd_572;
double Gd_unused_580;
double Gd_unused_588;
double G_price_596;
double G_bid_604;
double G_ask_612;
double Gd_620;
double Gd_628;
double Gd_636;
bool Gi_644;
string Gs_648 = "";
int Gi_656 = 123;
int Gi_660;
int Gi_664 = 123;
double Gd_668;
int G_pos_676 = 123;
int Gi_680;
double Gd_684 = 0.0;
bool Gi_692 = FALSE;
bool Gi_696 = FALSE;
bool Gi_700 = FALSE;
int Gi_704;
bool Gi_708 = FALSE;
double Gd_712;
double Gd_720;
int G_datetime_728 = 1;
extern string EXPERTSPro = ">>++++++++++<<";
int MaxTrades_16 = 1000;
int G_timeframe_784 = PERIOD_H1;
extern bool UseTrailingStop_16 = FALSE;
double G_pips_792 = 500.0;
extern double TrailStart_16 = 10.0;
extern double TrailStop_16 = 5.0;
bool Gi_816 = FALSE;
double Gd_820 = 48.0;
extern double PipStep_16 = 200.0;
double slip_16 = 3.0;
int G_magic_176_16 = 16794;
double G_price_848;
double Gd_856;
double Gd_unused_864;
double Gd_unused_872;
double G_price_880;
double G_bid_888;
double G_ask_896;
double Gd_904;
double Gd_912;
double Gd_920;
bool Gi_928;
string Gs_932 = "";
int Gi_940 = 123;
int Gi_944;
int Gi_948 = 123;
double Gd_952;
int G_pos_960 = 123;
int Gi_964;
double Gd_968 = 0.0;
bool Gi_976 = FALSE;
bool Gi_980 = FALSE;
bool Gi_984 = FALSE;
int Gi_988;
bool Gi_992 = FALSE;
double Gd_996;
double Gd_1004;
int G_datetime_1012 = 1;
int G_timeframe_1024 = PERIOD_M1;
int G_timeframe_1028 = PERIOD_M5;
int G_timeframe_1032 = PERIOD_M15;
int G_timeframe_1036 = PERIOD_M30;
int G_timeframe_1040 = PERIOD_H1;
int G_timeframe_1044 = PERIOD_H4;
int G_timeframe_1048 = PERIOD_D1;
bool G_corner_1052 = TRUE;
int Gi_1056 = 0;
int Gi_1060 = 10;
int G_window_1064 = 0;
bool Gi_1068 = TRUE;
bool Gi_unused_1072 = TRUE;
bool Gi_1076 = FALSE;
int G_color_1080 = Green;
int G_color_1084 = Green;
int G_color_1088 = Maroon;
int G_color_1092 = Blue;
int Gi_unused_1096 = 36095;
int G_color_1100 = Lime;
int G_color_1104 = Yellow;
int Gi_1108 = 65280;
int Gi_1112 = 17919;
int G_color_1116 = Red;
int G_color_1120 = Blue;
int G_color_1124 = Yellow;
int G_period_1128 = 8;
int G_period_1132 = 17;
int G_period_1136 = 9;
int G_applied_price_1140 = PRICE_CLOSE;
int G_color_1144 = Lime;
int G_color_1148 = Maroon;
int G_color_1152 = LimeGreen;
int G_color_1156 = MediumBlue;
string Gs_unused_1160 = "<<<< STR Indicator Settings >>>>>>>>>>>>>";
string Gs_unused_1168 = "<<<< RSI Settings >>>>>>>>>>>>>";
int G_period_1176 = 9;
int G_applied_price_1180 = PRICE_CLOSE;
string Gs_unused_1184 = "<<<< CCI Settings >>>>>>>>>>>>>>";
int G_period_1192 = 13;
int G_applied_price_1196 = PRICE_CLOSE;
string Gs_unused_1200 = "<<<< STOCH Settings >>>>>>>>>>>";
int G_period_1208 = 5;
int G_period_1212 = 3;
int G_slowing_1216 = 3;
int G_ma_method_1220 = MODE_EMA;
string Gs_unused_1224 = "<<<< STR Colors >>>>>>>>>>>>>>>>";
int G_color_1232 = MediumBlue;
int G_color_1236 = Green;
int G_color_1240 = Yellow;
string Gs_unused_1244 = "<<<< MA Settings >>>>>>>>>>>>>>";
int G_period_1252 = 5;
int G_period_1256 = 9;
int G_ma_method_1260 = MODE_EMA;
int G_applied_price_1264 = PRICE_CLOSE;
string Gs_unused_1268 = "<<<< MA Colors >>>>>>>>>>>>>>";
int G_color_1276 = SteelBlue;
int G_color_1280 = DarkGreen;
string Gs_dummy_1292;
string G_text_1464;
string G_text_1472;
bool Gi_1480 = FALSE;//TRUE;
extern bool CloseFriday = FALSE;
extern int CloseFridayHour = 0;
extern bool OpenMondey = TRUE;
extern int OpenMondeyHour = 0;
extern string KEY = "Philippines Forex Traders";
int Gi_1492;
int G_str2int_1496;
int G_str2int_1500;
int G_str2int_1504;

// E37F0136AA3FFAF149B351F6A4C948E9
int init()
  {
   string Ls_4;
   string Ls_12;
   string Ls_20;
   string Ls_28;
   string Ls_36;
   string Ls_44;
   Gd_352 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   Gd_636 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   Gd_920 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   ObjectCreate("Lable1", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 2);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 21);
   G_text_1472 = "XAU MINER EA  ,, .";
   ObjectSetText("Lable1", G_text_1472, 28, "Comic Sans MS", Lime);
   ObjectCreate("Lable", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("Lable", OBJPROP_CORNER, 2);
   ObjectSet("Lable", OBJPROP_XDISTANCE, 3);
   ObjectSet("Lable", OBJPROP_YDISTANCE, 1);
   G_text_1464 = " ----------------------";
   ObjectSetText("Lable", G_text_1464, 10, "Wingdings", Blue);
   if(Gi_1480)
     {
      if(KEY != "")
        {
         Gi_1492 = 0;
         for(int Li_0 = 0; Li_0 < StringLen(KEY); Li_0++)
           {
            if(StringSubstr(KEY, Li_0, 1) != "X")
               Ls_4 = Ls_4 + StringSubstr(KEY, Li_0, 1);
            else
              {
               Ls_12 = Ls_12 + f0_15(Ls_4);
               Ls_4 = "";
              }
           }
         for(Li_0 = 0; Li_0 < StringLen(Ls_12); Li_0 += 2)
           {
            if(StringSubstr(Ls_12, Li_0, 2) == "55")
               Ls_20 = Ls_20 + "0";
            else
              {
               if(StringSubstr(Ls_12, Li_0, 2) == "21")
                  Ls_20 = Ls_20 + "1";
               else
                 {
                  if(StringSubstr(Ls_12, Li_0, 2) == "98")
                     Ls_20 = Ls_20 + "2";
                  else
                    {
                     if(StringSubstr(Ls_12, Li_0, 2) == "42")
                        Ls_20 = Ls_20 + "3";
                     else
                       {
                        if(StringSubstr(Ls_12, Li_0, 2) == "10")
                           Ls_20 = Ls_20 + "4";
                        else
                          {
                           if(StringSubstr(Ls_12, Li_0, 2) == "14")
                              Ls_20 = Ls_20 + "5";
                           else
                             {
                              if(StringSubstr(Ls_12, Li_0, 2) == "88")
                                 Ls_20 = Ls_20 + "6";
                              else
                                {
                                 if(StringSubstr(Ls_12, Li_0, 2) == "66")
                                    Ls_20 = Ls_20 + "7";
                                 else
                                   {
                                    if(StringSubstr(Ls_12, Li_0, 2) == "33")
                                       Ls_20 = Ls_20 + "8";
                                    else
                                      {
                                       if(StringSubstr(Ls_12, Li_0, 2) == "32")
                                          Ls_20 = Ls_20 + "9";
                                       else
                                         {
                                          if(StringSubstr(Ls_12, Li_0, 2) == "96")
                                             Ls_20 = Ls_20 + "a";
                                          else
                                            {
                                             if(StringSubstr(Ls_12, Li_0, 2) == "30")
                                                Ls_20 = Ls_20 + "b";
                                             else
                                               {
                                                if(StringSubstr(Ls_12, Li_0, 2) == "77")
                                                   Ls_20 = Ls_20 + "c";
                                                else
                                                  {
                                                   if(StringSubstr(Ls_12, Li_0, 2) == "90")
                                                      Ls_20 = Ls_20 + "d";
                                                   else
                                                     {
                                                      if(StringSubstr(Ls_12, Li_0, 2) == "24")
                                                         Ls_20 = Ls_20 + "e";
                                                      else
                                                        {
                                                         if(StringSubstr(Ls_12, Li_0, 2) == "29")
                                                            Ls_20 = Ls_20 + "f";
                                                         else
                                                           {
                                                            if(StringSubstr(Ls_12, Li_0, 2) == "39")
                                                               Ls_20 = Ls_20 + "g";
                                                            else
                                                              {
                                                               if(StringSubstr(Ls_12, Li_0, 2) == "48")
                                                                  Ls_20 = Ls_20 + "h";
                                                               else
                                                                 {
                                                                  if(StringSubstr(Ls_12, Li_0, 2) == "56")
                                                                     Ls_20 = Ls_20 + "i";
                                                                  else
                                                                    {
                                                                     if(StringSubstr(Ls_12, Li_0, 2) == "16")
                                                                        Ls_20 = Ls_20 + "j";
                                                                     else
                                                                       {
                                                                        if(StringSubstr(Ls_12, Li_0, 2) == "62")
                                                                           Ls_20 = Ls_20 + "k";
                                                                        else
                                                                          {
                                                                           if(StringSubstr(Ls_12, Li_0, 2) == "15")
                                                                              Ls_20 = Ls_20 + "l";
                                                                           else
                                                                             {
                                                                              if(StringSubstr(Ls_12, Li_0, 2) == "71")
                                                                                 Ls_20 = Ls_20 + "m";
                                                                              else
                                                                                {
                                                                                 if(StringSubstr(Ls_12, Li_0, 2) == "81")
                                                                                    Ls_20 = Ls_20 + "n";
                                                                                 else
                                                                                   {
                                                                                    if(StringSubstr(Ls_12, Li_0, 2) == "93")
                                                                                       Ls_20 = Ls_20 + "o";
                                                                                    else
                                                                                      {
                                                                                       if(StringSubstr(Ls_12, Li_0, 2) == "74")
                                                                                          Ls_20 = Ls_20 + "p";
                                                                                       else
                                                                                         {
                                                                                          if(StringSubstr(Ls_12, Li_0, 2) == "83")
                                                                                             Ls_20 = Ls_20 + "q";
                                                                                          else
                                                                                            {
                                                                                             if(StringSubstr(Ls_12, Li_0, 2) == "44")
                                                                                                Ls_20 = Ls_20 + "r";
                                                                                             else
                                                                                               {
                                                                                                if(StringSubstr(Ls_12, Li_0, 2) == "51")
                                                                                                   Ls_20 = Ls_20 + "s";
                                                                                                else
                                                                                                  {
                                                                                                   if(StringSubstr(Ls_12, Li_0, 2) == "69")
                                                                                                      Ls_20 = Ls_20 + "t";
                                                                                                   else
                                                                                                     {
                                                                                                      if(StringSubstr(Ls_12, Li_0, 2) == "40")
                                                                                                         Ls_20 = Ls_20 + "u";
                                                                                                      else
                                                                                                        {
                                                                                                         if(StringSubstr(Ls_12, Li_0, 2) == "73")
                                                                                                            Ls_20 = Ls_20 + "v";
                                                                                                         else
                                                                                                           {
                                                                                                            if(StringSubstr(Ls_12, Li_0, 2) == "59")
                                                                                                               Ls_20 = Ls_20 + "w";
                                                                                                            else
                                                                                                              {
                                                                                                               if(StringSubstr(Ls_12, Li_0, 2) == "36")
                                                                                                                  Ls_20 = Ls_20 + "x";
                                                                                                               else
                                                                                                                 {
                                                                                                                  if(StringSubstr(Ls_12, Li_0, 2) == "26")
                                                                                                                     Ls_20 = Ls_20 + "y";
                                                                                                                  else
                                                                                                                    {
                                                                                                                     if(StringSubstr(Ls_12, Li_0, 2) == "25")
                                                                                                                        Ls_20 = Ls_20 + "z";
                                                                                                                     else
                                                                                                                       {
                                                                                                                        if(StringSubstr(Ls_12, Li_0, 2) == "28")
                                                                                                                           Ls_20 = Ls_20 + "!";
                                                                                                                        else
                                                                                                                          {
                                                                                                                           if(StringSubstr(Ls_12, Li_0, 2) == "65")
                                                                                                                              Ls_20 = Ls_20 + "&";
                                                                                                                           else
                                                                                                                             {
                                                                                                                              if(StringSubstr(Ls_12, Li_0, 2) == "52")
                                                                                                                                 Ls_20 = Ls_20 + "#";
                                                                                                                              else
                                                                                                                                {
                                                                                                                                 if(StringSubstr(Ls_12, Li_0, 2) == "57")
                                                                                                                                    Ls_20 = Ls_20 + "$";
                                                                                                                                 else
                                                                                                                                   {
                                                                                                                                    if(StringSubstr(Ls_12, Li_0, 2) == "31")
                                                                                                                                       Ls_20 = Ls_20 + "%";
                                                                                                                                    else
                                                                                                                                      {
                                                                                                                                       if(StringSubstr(Ls_12, Li_0, 2) == "91")
                                                                                                                                          Ls_20 = Ls_20 + "*";
                                                                                                                                       else
                                                                                                                                         {
                                                                                                                                          if(StringSubstr(Ls_12, Li_0, 2) == "60")
                                                                                                                                             Ls_20 = Ls_20 + "+";
                                                                                                                                          else
                                                                                                                                            {
                                                                                                                                             if(StringSubstr(Ls_12, Li_0, 2) == "92")
                                                                                                                                                Ls_20 = Ls_20 + "-";
                                                                                                                                             else
                                                                                                                                               {
                                                                                                                                                if(StringSubstr(Ls_12, Li_0, 2) == "34")
                                                                                                                                                   Ls_20 = Ls_20 + "?";
                                                                                                                                                else
                                                                                                                                                  {
                                                                                                                                                   if(StringSubstr(Ls_12, Li_0, 2) == "46")
                                                                                                                                                      Ls_20 = Ls_20 + "^";
                                                                                                                                                   else
                                                                                                                                                     {
                                                                                                                                                      if(StringSubstr(Ls_12, Li_0, 2) == "38")
                                                                                                                                                         Ls_20 = Ls_20 + "|";
                                                                                                                                                      else
                                                                                                                                                        {
                                                                                                                                                         if(StringSubstr(Ls_12, Li_0, 2) == "37")
                                                                                                                                                            Ls_20 = Ls_20 + "@";
                                                                                                                                                         else
                                                                                                                                                           {
                                                                                                                                                            if(StringSubstr(Ls_12, Li_0, 2) == "49")
                                                                                                                                                               Ls_20 = Ls_20 + "_";
                                                                                                                                                            else
                                                                                                                                                              {
                                                                                                                                                               if(StringSubstr(Ls_12, Li_0, 2) == "50")
                                                                                                                                                                  Ls_20 = Ls_20 + "S";
                                                                                                                                                               else
                                                                                                                                                                  if(StringSubstr(Ls_12, Li_0, 2) == "19")
                                                                                                                                                                     Ls_20 = Ls_20 + ".";
                                                                                                                                                              }
                                                                                                                                                           }
                                                                                                                                                        }
                                                                                                                                                     }
                                                                                                                                                  }
                                                                                                                                               }
                                                                                                                                            }
                                                                                                                                         }
                                                                                                                                      }
                                                                                                                                   }
                                                                                                                                }
                                                                                                                             }
                                                                                                                          }
                                                                                                                       }
                                                                                                                    }
                                                                                                                 }
                                                                                                              }
                                                                                                           }
                                                                                                        }
                                                                                                     }
                                                                                                  }
                                                                                               }
                                                                                            }
                                                                                         }
                                                                                      }
                                                                                   }
                                                                                }
                                                                             }
                                                                          }
                                                                       }
                                                                    }
                                                                 }
                                                              }
                                                           }
                                                        }
                                                     }
                                                  }
                                               }
                                            }
                                         }
                                      }
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              }
           }
         Ls_28 = StringSubstr(Ls_20, 1, 2);
         Ls_36 = StringSubstr(Ls_20, 3, 2);
         Ls_44 = StringSubstr(Ls_20, 5, 4);
         G_str2int_1496 = StrToInteger(Ls_28);
         G_str2int_1500 = StrToInteger(Ls_36);
         G_str2int_1504 = StrToInteger(Ls_44);
         if(Year() > G_str2int_1504)
            Gi_1492 = 3;
         if(Year() == G_str2int_1504)
           {
            if(Month() > G_str2int_1500)
               Gi_1492 = 3;
            if(Month() == G_str2int_1500)
               if(Day() > G_str2int_1496)
                  Gi_1492 = 3;
           }
        }
      else
         Gi_1492 = 1;
      Gi_1480 = FALSE;
     }
//   Comment("\n", "License will expire on ", G_str2int_1496, "/", G_str2int_1500, "/", G_str2int_1504);
   Comment("\n", "Connected . . . . .");
   return (0);
  }

// 52D46093050F38C27267BCE42543EF60
int deinit()
  {

  }
//=============================================================================================================
int start()
  {



//=============================================================================================================

   int Li_4;
   int Li_8;
   int Li_12;
   int Li_16;
   int Li_20;
   int Li_24;
   int Li_28;
   color color_32;
   color color_36;
   color color_40;
   color color_44;
   color color_48;
   color color_52;
   color color_56;
   string Ls_unused_60;
   color color_68;
   color color_72;
   color color_76;
   color color_80;
   color color_84;
   color color_88;
   color color_92;
   color color_96;
   string Ls_unused_100;
   color color_108;
   int Li_unused_112;
   double ihigh_1128;
   double ilow_1136;
   double iclose_1144;
   double iclose_1152;
   double Ld_1192;
   double Ld_1248;
   double Ld_1256;
   int Li_1264;
   int count_1268;
   double Ld_1316;
   double Ld_1324;
   int Li_1332;
   int count_1336;
   if(Gi_1492 == 1)
     {
      Alert("Empty license KEY! Please enter the license KEY!");
      return;
     }
   if(Gi_1492 == 2)
     {
      Alert("Invalid license KEY! Please enter a valid license KEY!");
      return;
     }
   if(Gi_1492 == 3)
     {
      Alert("The license KEY has expired!");
      return;
     }
   int ind_counted_0 = IndicatorCounted();
   /*   if (!IsDemo())
         if (AccountNumber() != Account) return (0);*/
   if(Lots > MaxLots)
      Lots = MaxLots;
   Comment(""
           + "\n"
           + "DEVELOPED BY FXZHEIL +639485758802"
           + "Broker  : " + AccountCompany()
           + "Server Time : " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS)
           + "Your Name    : " + AccountName()
           + "Account #  : " + AccountNumber()
           + "Balance : " + DoubleToStr(AccountBalance(), 2)
           + "Equity   : " + DoubleToStr(AccountEquity(), 2)
           + "");
   int ind_counted_272 = IndicatorCounted();
   string text_276 = "";
   string text_284 = "";
   string text_292 = "";
   string text_300 = "";
   string text_308 = "";
   string text_316 = "";
   string text_324 = "";
   if(G_timeframe_1024 == PERIOD_M1)
      text_276 = "M1";
   if(G_timeframe_1024 == PERIOD_M5)
      text_276 = "M5";
   if(G_timeframe_1024 == PERIOD_M15)
      text_276 = "M15";
   if(G_timeframe_1024 == PERIOD_M30)
      text_276 = "M30";
   if(G_timeframe_1024 == PERIOD_H1)
      text_276 = "H1";
   if(G_timeframe_1024 == PERIOD_H4)
      text_276 = "H4";
   if(G_timeframe_1024 == PERIOD_D1)
      text_276 = "D1";
   if(G_timeframe_1024 == PERIOD_W1)
      text_276 = "W1";
   if(G_timeframe_1024 == PERIOD_MN1)
      text_276 = "MN";
   if(G_timeframe_1028 == PERIOD_M1)
      text_284 = "M1";
   if(G_timeframe_1028 == PERIOD_M5)
      text_284 = "M5";
   if(G_timeframe_1028 == PERIOD_M15)
      text_284 = "M15";
   if(G_timeframe_1028 == PERIOD_M30)
      text_284 = "M30";
   if(G_timeframe_1028 == PERIOD_H1)
      text_284 = "H1";
   if(G_timeframe_1028 == PERIOD_H4)
      text_284 = "H4";
   if(G_timeframe_1028 == PERIOD_D1)
      text_284 = "D1";
   if(G_timeframe_1028 == PERIOD_W1)
      text_284 = "W1";
   if(G_timeframe_1028 == PERIOD_MN1)
      text_284 = "MN";
   if(G_timeframe_1032 == PERIOD_M1)
      text_292 = "M1";
   if(G_timeframe_1032 == PERIOD_M5)
      text_292 = "M5";
   if(G_timeframe_1032 == PERIOD_M15)
      text_292 = "M15";
   if(G_timeframe_1032 == PERIOD_M30)
      text_292 = "M30";
   if(G_timeframe_1032 == PERIOD_H1)
      text_292 = "H1";
   if(G_timeframe_1032 == PERIOD_H4)
      text_292 = "H4";
   if(G_timeframe_1032 == PERIOD_D1)
      text_292 = "D1";
   if(G_timeframe_1032 == PERIOD_W1)
      text_292 = "W1";
   if(G_timeframe_1032 == PERIOD_MN1)
      text_292 = "MN";
   if(G_timeframe_1036 == PERIOD_M1)
      text_300 = "M1";
   if(G_timeframe_1036 == PERIOD_M5)
      text_300 = "M5";
   if(G_timeframe_1036 == PERIOD_M15)
      text_300 = "M15";
   if(G_timeframe_1036 == PERIOD_M30)
      text_300 = "M30";
   if(G_timeframe_1036 == PERIOD_H1)
      text_300 = "H1";
   if(G_timeframe_1036 == PERIOD_H4)
      text_300 = "H4";
   if(G_timeframe_1036 == PERIOD_D1)
      text_300 = "D1";
   if(G_timeframe_1036 == PERIOD_W1)
      text_300 = "W1";
   if(G_timeframe_1036 == PERIOD_MN1)
      text_300 = "MN";
   if(G_timeframe_1040 == PERIOD_M1)
      text_308 = "M1";
   if(G_timeframe_1040 == PERIOD_M5)
      text_308 = "M5";
   if(G_timeframe_1040 == PERIOD_M15)
      text_308 = "M15";
   if(G_timeframe_1040 == PERIOD_M30)
      text_308 = "M30";
   if(G_timeframe_1040 == PERIOD_H1)
      text_308 = "H1";
   if(G_timeframe_1040 == PERIOD_H4)
      text_308 = "H4";
   if(G_timeframe_1040 == PERIOD_D1)
      text_308 = "D1";
   if(G_timeframe_1040 == PERIOD_W1)
      text_308 = "W1";
   if(G_timeframe_1040 == PERIOD_MN1)
      text_308 = "MN";
   if(G_timeframe_1044 == PERIOD_M1)
      text_316 = "M1";
   if(G_timeframe_1044 == PERIOD_M5)
      text_316 = "M5";
   if(G_timeframe_1044 == PERIOD_M15)
      text_316 = "M15";
   if(G_timeframe_1044 == PERIOD_M30)
      text_316 = "M30";
   if(G_timeframe_1044 == PERIOD_H1)
      text_316 = "H1";
   if(G_timeframe_1044 == PERIOD_H4)
      text_316 = "H4";
   if(G_timeframe_1044 == PERIOD_D1)
      text_316 = "D1";
   if(G_timeframe_1044 == PERIOD_W1)
      text_316 = "W1";
   if(G_timeframe_1044 == PERIOD_MN1)
      text_316 = "MN";
   if(G_timeframe_1048 == PERIOD_M1)
      text_324 = "M1";
   if(G_timeframe_1048 == PERIOD_M5)
      text_324 = "M5";
   if(G_timeframe_1048 == PERIOD_M15)
      text_324 = "M15";
   if(G_timeframe_1048 == PERIOD_M30)
      text_324 = "M30";
   if(G_timeframe_1048 == PERIOD_H1)
      text_324 = "H1";
   if(G_timeframe_1048 == PERIOD_H4)
      text_324 = "H4";
   if(G_timeframe_1048 == PERIOD_D1)
      text_324 = "D1";
   if(G_timeframe_1048 == PERIOD_W1)
      text_324 = "W1";
   if(G_timeframe_1048 == PERIOD_MN1)
      text_324 = "MN";
   if(G_timeframe_1024 == PERIOD_M15)
      Li_4 = -2;
   if(G_timeframe_1024 == PERIOD_M30)
      Li_4 = -2;
   if(G_timeframe_1028 == PERIOD_M15)
      Li_8 = -2;
   if(G_timeframe_1028 == PERIOD_M30)
      Li_8 = -2;
   if(G_timeframe_1032 == PERIOD_M15)
      Li_12 = -2;
   if(G_timeframe_1032 == PERIOD_M30)
      Li_12 = -2;
   if(G_timeframe_1036 == PERIOD_M15)
      Li_16 = -2;
   if(G_timeframe_1036 == PERIOD_M30)
      Li_16 = -2;
   if(G_timeframe_1040 == PERIOD_M15)
      Li_20 = -2;
   if(G_timeframe_1040 == PERIOD_M30)
      Li_20 = -2;
   if(G_timeframe_1044 == PERIOD_M15)
      Li_24 = -2;
   if(G_timeframe_1044 == PERIOD_M30)
      Li_24 = -2;
   if(G_timeframe_1048 == PERIOD_M15)
      Li_28 = -2;
   if(G_timeframe_1044 == PERIOD_M30)
      Li_28 = -2;
   if(Gi_1056 < 0)
      return (0);

   string text_332 = "";
   string text_340 = "";
   string text_348 = "";
   string text_356 = "";
   string text_364 = "";
   string text_372 = "";
   string text_380 = "";
   string Ls_unused_388 = "";
   string Ls_unused_396 = "";
   double imacd_404 = iMACD(NULL, G_timeframe_1024, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_MAIN, 0);
   double imacd_412 = iMACD(NULL, G_timeframe_1024, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_SIGNAL, 0);
   double imacd_420 = iMACD(NULL, G_timeframe_1028, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_MAIN, 0);
   double imacd_428 = iMACD(NULL, G_timeframe_1028, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_SIGNAL, 0);
   double imacd_436 = iMACD(NULL, G_timeframe_1032, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_MAIN, 0);
   double imacd_444 = iMACD(NULL, G_timeframe_1032, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_SIGNAL, 0);
   double imacd_452 = iMACD(NULL, G_timeframe_1036, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_MAIN, 0);
   double imacd_460 = iMACD(NULL, G_timeframe_1036, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_SIGNAL, 0);
   double imacd_468 = iMACD(NULL, G_timeframe_1040, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_MAIN, 0);
   double imacd_476 = iMACD(NULL, G_timeframe_1040, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_SIGNAL, 0);
   double imacd_484 = iMACD(NULL, G_timeframe_1044, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_MAIN, 0);
   double imacd_492 = iMACD(NULL, G_timeframe_1044, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_SIGNAL, 0);
   double imacd_500 = iMACD(NULL, G_timeframe_1048, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_MAIN, 0);
   double imacd_508 = iMACD(NULL, G_timeframe_1048, G_period_1128, G_period_1132, G_period_1136, G_applied_price_1140, MODE_SIGNAL, 0);
   if(imacd_404 > imacd_412)
     {
      text_356 = "-";
      color_44 = G_color_1152;
     }
   if(imacd_404 <= imacd_412)
     {
      text_356 = "-";
      color_44 = G_color_1148;
     }
   if(imacd_404 > imacd_412 && imacd_404 > 0.0)
     {
      text_356 = "-";
      color_44 = G_color_1144;
     }
   if(imacd_404 <= imacd_412 && imacd_404 < 0.0)
     {
      text_356 = "-";
      color_44 = G_color_1156;
     }
   if(imacd_420 > imacd_428)
     {
      text_364 = "-";
      color_48 = G_color_1152;
     }
   if(imacd_420 <= imacd_428)
     {
      text_364 = "-";
      color_48 = G_color_1148;
     }
   if(imacd_420 > imacd_428 && imacd_420 > 0.0)
     {
      text_364 = "-";
      color_48 = G_color_1144;
     }
   if(imacd_420 <= imacd_428 && imacd_420 < 0.0)
     {
      text_364 = "-";
      color_48 = G_color_1156;
     }
   if(imacd_436 > imacd_444)
     {
      text_372 = "-";
      color_52 = G_color_1152;
     }
   if(imacd_436 <= imacd_444)
     {
      text_372 = "-";
      color_52 = G_color_1148;
     }
   if(imacd_436 > imacd_444 && imacd_436 > 0.0)
     {
      text_372 = "-";
      color_52 = G_color_1144;
     }
   if(imacd_436 <= imacd_444 && imacd_436 < 0.0)
     {
      text_372 = "-";
      color_52 = G_color_1156;
     }
   if(imacd_452 > imacd_460)
     {
      text_380 = "-";
      color_56 = G_color_1152;
     }
   if(imacd_452 <= imacd_460)
     {
      text_380 = "-";
      color_56 = G_color_1148;
     }
   if(imacd_452 > imacd_460 && imacd_452 > 0.0)
     {
      text_380 = "-";
      color_56 = G_color_1144;
     }
   if(imacd_452 <= imacd_460 && imacd_452 < 0.0)
     {
      text_380 = "-";
      color_56 = G_color_1156;
     }
   if(imacd_468 > imacd_476)
     {
      text_340 = "-";
      color_36 = G_color_1152;
     }
   if(imacd_468 <= imacd_476)
     {
      text_340 = "-";
      color_36 = G_color_1148;
     }
   if(imacd_468 > imacd_476 && imacd_468 > 0.0)
     {
      text_340 = "-";
      color_36 = G_color_1144;
     }
   if(imacd_468 <= imacd_476 && imacd_468 < 0.0)
     {
      text_340 = "-";
      color_36 = G_color_1156;
     }
   if(imacd_484 > imacd_492)
     {
      text_348 = "-";
      color_40 = G_color_1152;
     }
   if(imacd_484 <= imacd_492)
     {
      text_348 = "-";
      color_40 = G_color_1148;
     }
   if(imacd_484 > imacd_492 && imacd_484 > 0.0)
     {
      text_348 = "-";
      color_40 = G_color_1144;
     }
   if(imacd_484 <= imacd_492 && imacd_484 < 0.0)
     {
      text_348 = "-";
      color_40 = G_color_1156;
     }
   if(imacd_500 > imacd_508)
     {
      text_332 = "-";
      color_32 = G_color_1152;
     }
   if(imacd_500 <= imacd_508)
     {
      text_332 = "-";
      color_32 = G_color_1148;
     }
   if(imacd_500 > imacd_508 && imacd_500 > 0.0)
     {
      text_332 = "-";
      color_32 = G_color_1144;
     }
   if(imacd_500 <= imacd_508 && imacd_500 < 0.0)
     {
      text_332 = "-";
      color_32 = G_color_1156;
     }

   double irsi_516 = iRSI(NULL, G_timeframe_1048, G_period_1176, G_applied_price_1180, 0);
   double irsi_524 = iRSI(NULL, G_timeframe_1044, G_period_1176, G_applied_price_1180, 0);
   double irsi_532 = iRSI(NULL, G_timeframe_1040, G_period_1176, G_applied_price_1180, 0);
   double irsi_540 = iRSI(NULL, G_timeframe_1036, G_period_1176, G_applied_price_1180, 0);
   double irsi_548 = iRSI(NULL, G_timeframe_1032, G_period_1176, G_applied_price_1180, 0);
   double irsi_556 = iRSI(NULL, G_timeframe_1028, G_period_1176, G_applied_price_1180, 0);
   double irsi_564 = iRSI(NULL, G_timeframe_1024, G_period_1176, G_applied_price_1180, 0);
   double istochastic_572 = iStochastic(NULL, G_timeframe_1048, G_period_1208, G_period_1212, G_slowing_1216, G_ma_method_1220, 0, MODE_MAIN, 0);
   double istochastic_580 = iStochastic(NULL, G_timeframe_1044, G_period_1208, G_period_1212, G_slowing_1216, G_ma_method_1220, 0, MODE_MAIN, 0);
   double istochastic_588 = iStochastic(NULL, G_timeframe_1040, G_period_1208, G_period_1212, G_slowing_1216, G_ma_method_1220, 0, MODE_MAIN, 0);
   double istochastic_596 = iStochastic(NULL, G_timeframe_1036, G_period_1208, G_period_1212, G_slowing_1216, G_ma_method_1220, 0, MODE_MAIN, 0);
   double istochastic_604 = iStochastic(NULL, G_timeframe_1032, G_period_1208, G_period_1212, G_slowing_1216, G_ma_method_1220, 0, MODE_MAIN, 0);
   double istochastic_612 = iStochastic(NULL, G_timeframe_1028, G_period_1208, G_period_1212, G_slowing_1216, G_ma_method_1220, 0, MODE_MAIN, 0);
   double istochastic_620 = iStochastic(NULL, G_timeframe_1024, G_period_1208, G_period_1212, G_slowing_1216, G_ma_method_1220, 0, MODE_MAIN, 0);
   double icci_628 = iCCI(NULL, G_timeframe_1048, G_period_1192, G_applied_price_1196, 0);
   double icci_636 = iCCI(NULL, G_timeframe_1044, G_period_1192, G_applied_price_1196, 0);
   double icci_644 = iCCI(NULL, G_timeframe_1040, G_period_1192, G_applied_price_1196, 0);
   double icci_652 = iCCI(NULL, G_timeframe_1036, G_period_1192, G_applied_price_1196, 0);
   double icci_660 = iCCI(NULL, G_timeframe_1032, G_period_1192, G_applied_price_1196, 0);
   double icci_668 = iCCI(NULL, G_timeframe_1028, G_period_1192, G_applied_price_1196, 0);
   double icci_676 = iCCI(NULL, G_timeframe_1024, G_period_1192, G_applied_price_1196, 0);
   string text_684 = "";
   string text_692 = "";
   string text_700 = "";
   string text_708 = "";
   string text_716 = "";
   string text_724 = "";
   string text_732 = "";
   string Ls_unused_740 = "";
   string Ls_unused_748 = "";
   text_732 = "-";
   color color_756 = G_color_1240;
   text_716 = "-";
   color color_760 = G_color_1240;
   text_684 = "-";
   color color_764 = G_color_1240;
   text_724 = "-";
   color color_768 = G_color_1240;
   text_692 = "-";
   color color_772 = G_color_1240;
   text_700 = "-";
   color color_776 = G_color_1240;
   text_708 = "-";
   color color_780 = G_color_1240;
   if(irsi_516 > 50.0 && istochastic_572 > 40.0 && icci_628 > 0.0)
     {
      text_732 = "-";
      color_756 = G_color_1232;
     }
   if(irsi_524 > 50.0 && istochastic_580 > 40.0 && icci_636 > 0.0)
     {
      text_716 = "-";
      color_760 = G_color_1232;
     }
   if(irsi_532 > 50.0 && istochastic_588 > 40.0 && icci_644 > 0.0)
     {
      text_684 = "-";
      color_764 = G_color_1232;
     }
   if(irsi_540 > 50.0 && istochastic_596 > 40.0 && icci_652 > 0.0)
     {
      text_724 = "-";
      color_768 = G_color_1232;
     }
   if(irsi_548 > 50.0 && istochastic_604 > 40.0 && icci_660 > 0.0)
     {
      text_692 = "-";
      color_772 = G_color_1232;
     }
   if(irsi_556 > 50.0 && istochastic_612 > 40.0 && icci_668 > 0.0)
     {
      text_700 = "-";
      color_776 = G_color_1232;
     }
   if(irsi_564 > 50.0 && istochastic_620 > 40.0 && icci_676 > 0.0)
     {
      text_708 = "-";
      color_780 = G_color_1232;
     }
   if(irsi_516 < 50.0 && istochastic_572 < 60.0 && icci_628 < 0.0)
     {
      text_732 = "-";
      color_756 = G_color_1236;
     }
   if(irsi_524 < 50.0 && istochastic_580 < 60.0 && icci_636 < 0.0)
     {
      text_716 = "-";
      color_760 = G_color_1236;
     }
   if(irsi_532 < 50.0 && istochastic_588 < 60.0 && icci_644 < 0.0)
     {
      text_684 = "-";
      color_764 = G_color_1236;
     }
   if(irsi_540 < 50.0 && istochastic_596 < 60.0 && icci_652 < 0.0)
     {
      text_724 = "-";
      color_768 = G_color_1236;
     }
   if(irsi_548 < 50.0 && istochastic_604 < 60.0 && icci_660 < 0.0)
     {
      text_692 = "-";
      color_772 = G_color_1236;
     }
   if(irsi_556 < 50.0 && istochastic_612 < 60.0 && icci_668 < 0.0)
     {
      text_700 = "-";
      color_776 = G_color_1236;
     }
   if(irsi_564 < 50.0 && istochastic_620 < 60.0 && icci_676 < 0.0)
     {
      text_708 = "-";
      color_780 = G_color_1236;
     }

   double ima_784 = iMA(Symbol(), G_timeframe_1024, G_period_1252, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_792 = iMA(Symbol(), G_timeframe_1024, G_period_1256, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_800 = iMA(Symbol(), G_timeframe_1028, G_period_1252, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_808 = iMA(Symbol(), G_timeframe_1028, G_period_1256, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_816 = iMA(Symbol(), G_timeframe_1032, G_period_1252, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_824 = iMA(Symbol(), G_timeframe_1032, G_period_1256, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_832 = iMA(Symbol(), G_timeframe_1036, G_period_1252, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_840 = iMA(Symbol(), G_timeframe_1036, G_period_1256, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_848 = iMA(Symbol(), G_timeframe_1040, G_period_1252, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_856 = iMA(Symbol(), G_timeframe_1040, G_period_1256, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_864 = iMA(Symbol(), G_timeframe_1044, G_period_1252, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_872 = iMA(Symbol(), G_timeframe_1044, G_period_1256, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_880 = iMA(Symbol(), G_timeframe_1048, G_period_1252, 0, G_ma_method_1260, G_applied_price_1264, 0);
   double ima_888 = iMA(Symbol(), G_timeframe_1048, G_period_1256, 0, G_ma_method_1260, G_applied_price_1264, 0);
   string text_896 = "";
   string text_904 = "";
   string text_912 = "";
   string text_920 = "";
   string text_928 = "";
   string text_936 = "";
   string text_944 = "";
   string Ls_unused_952 = "";
   string Ls_unused_960 = "";
   if(ima_784 > ima_792)
     {
      text_896 = "-";
      color_68 = G_color_1276;
     }
   if(ima_784 <= ima_792)
     {
      text_896 = "-";
      color_68 = G_color_1280;
     }
   if(ima_800 > ima_808)
     {
      text_904 = "-";
      color_72 = G_color_1276;
     }
   if(ima_800 <= ima_808)
     {
      text_904 = "-";
      color_72 = G_color_1280;
     }
   if(ima_816 > ima_824)
     {
      text_912 = "-";
      color_76 = G_color_1276;
     }
   if(ima_816 <= ima_824)
     {
      text_912 = "-";
      color_76 = G_color_1280;
     }
   if(ima_832 > ima_840)
     {
      text_920 = "-";
      color_80 = G_color_1276;
     }
   if(ima_832 <= ima_840)
     {
      text_920 = "-";
      color_80 = G_color_1280;
     }
   if(ima_848 > ima_856)
     {
      text_928 = "-";
      color_84 = G_color_1276;
     }
   if(ima_848 <= ima_856)
     {
      text_928 = "-";
      color_84 = G_color_1280;
     }
   if(ima_864 > ima_872)
     {
      text_936 = "-";
      color_88 = G_color_1276;
     }
   if(ima_864 <= ima_872)
     {
      text_936 = "-";
      color_88 = G_color_1280;
     }
   if(ima_880 > ima_888)
     {
      text_944 = "-";
      color_92 = G_color_1276;
     }
   if(ima_880 <= ima_888)
     {
      text_944 = "-";
      color_92 = G_color_1280;
     }

   double Ld_968 = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits);
   double ima_976 = iMA(Symbol(), PERIOD_M1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
   string Ls_unused_984 = "";
   if(ima_976 > Ld_968)
     {
      Ls_unused_984 = "";
      color_96 = G_color_1120;
     }
   if(ima_976 < Ld_968)
     {
      Ls_unused_984 = "";
      color_96 = G_color_1116;
     }
   if(ima_976 == Ld_968)
     {
      Ls_unused_984 = "";
      color_96 = G_color_1124;
     }

   if(Gi_1076 == FALSE)
     {
      if(Gi_1068 == TRUE)
        {

        }
     }
   if(Gi_1076 == TRUE)
     {
      if(Gi_1068 == TRUE)
        {

        }
     }
   int Li_992 = 0;
   int Li_996 = 0;
   int Li_1000 = 0;
   int Li_1004 = 0;
   int Li_1008 = 0;
   int Li_1012 = 0;
   Li_992 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   for(Li_1012 = 1; Li_1012 <= 5; Li_1012++)
      Li_996 = Li_996 + (iHigh(NULL, PERIOD_D1, Li_1012) - iLow(NULL, PERIOD_D1, Li_1012)) / Point;
   for(Li_1012 = 1; Li_1012 <= 10; Li_1012++)
      Li_1000 = Li_1000 + (iHigh(NULL, PERIOD_D1, Li_1012) - iLow(NULL, PERIOD_D1, Li_1012)) / Point;
   for(Li_1012 = 1; Li_1012 <= 20; Li_1012++)
      Li_1004 = Li_1004 + (iHigh(NULL, PERIOD_D1, Li_1012) - iLow(NULL, PERIOD_D1, Li_1012)) / Point;
   Li_996 /= 5;
   Li_1000 /= 10;
   Li_1004 /= 20;
   Li_1008 = (Li_992 + Li_996 + Li_1000 + Li_1004) / 4;
   string Ls_unused_1016 = "";
   string Ls_unused_1024 = "";
   string dbl2str_1032 = "";
   string dbl2str_1040 = "";
   string dbl2str_1048 = "";
   string dbl2str_1056 = "";
   string Ls_unused_1064 = "";
   string Ls_unused_1072 = "";
   string Ls_1080 = "";
   double iopen_1088 = iOpen(NULL, PERIOD_D1, 0);
   double iclose_1096 = iClose(NULL, PERIOD_D1, 0);
   double Ld_1104 = (Ask - Bid) / Point;
   double ihigh_1112 = iHigh(NULL, PERIOD_D1, 0);
   double ilow_1120 = iLow(NULL, PERIOD_D1, 0);
   dbl2str_1040 = DoubleToStr((iclose_1096 - iopen_1088) / Point, 0);
   dbl2str_1032 = DoubleToStr(Ld_1104, Digits - 4);
   dbl2str_1048 = DoubleToStr(Li_1008, Digits - 4);
   Ls_1080 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   dbl2str_1056 = DoubleToStr((ihigh_1112 - ilow_1120) / Point, 0);
   if(iclose_1096 >= iopen_1088)
     {
      Ls_unused_1064 = "-";
      color_108 = G_color_1100;
     }
   if(iclose_1096 < iopen_1088)
     {
      Ls_unused_1064 = "-";
      color_108 = G_color_1104;
     }
   if(dbl2str_1048 >= Ls_1080)
     {
      Ls_unused_1072 = "-";
      Li_unused_112 = Gi_1108;
     }
   if(dbl2str_1048 < Ls_1080)
     {
      Ls_unused_1072 = "-";
      Li_unused_112 = Gi_1112;


     }
   ObjectDelete("1");
   ObjectCreate("1", OBJ_LABEL, G_window_1064, 0, 0);
   ObjectSetText("1", "XAU MINER", 50, "Georgia", Blue);

   double Ld_1160 = LotExponent;
   int Li_1168 = Gi_108;
   double Ld_1172 = TakeProfit;
   bool bool_1180 = UseEquityStop;
   double Ld_1184 = TotalEquityRisk;
   if(MM == TRUE)
     {
      if(MathCeil(AccountBalance()) < 2000.0)
         Ld_1192 = Lots;
      else
         Ld_1192 = 0.00001 * MathCeil(AccountBalance());
     }
   else
      Ld_1192 = Lots;
   if((CloseFriday == TRUE && DayOfWeek() == 5 && TimeCurrent() >= StrToTime(CloseFridayHour + ":00")) || (OpenMondey == TRUE && DayOfWeek() == 1 && TimeCurrent() <= StrToTime(OpenMondeyHour +
         ":00")))
      return (0);
   if(UseTrailingStop_Hilo)
      f0_35(TrailStart_Hilo, TrailStop_Hilo, G_price_312);
   if(Gi_220)
     {
      if(TimeCurrent() >= Gi_376)
        {
         f0_24();
         Print("Closed All due_Hilo to TimeOut");
        }
     }
   if(Gi_372 == Time[0])
      return (0);
   Gi_372 = Time[0];
   double Ld_1200 = f0_31();
   if(bool_1180)
     {
      if(Ld_1200 < 0.0 && MathAbs(Ld_1200) > Ld_1184 / 100.0 * f0_7())
        {
         f0_24();
         Print("Closed All due_Hilo to Stop Out");
         Gi_424 = FALSE;
        }
     }
   Gi_396 = f0_4();
   if(Gi_396 == 0)
      Gi_360 = FALSE;
   for(G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--)
     {
      OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
        {
         if(OrderType() == OP_BUY)
           {
            Gi_412 = TRUE;
            Gi_416 = FALSE;
            break;
           }
        }
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
        {
         if(OrderType() == OP_SELL)
           {
            Gi_412 = FALSE;
            Gi_416 = TRUE;
            break;
           }
        }
     }
   if(Gi_396 > 0 && Gi_396 <= MaxTrades_Hilo)
     {
      RefreshRates();
      Gd_336 = f0_32();
      Gd_344 = f0_20();
      if(Gi_412 && Gd_336 - Ask >= PipStep_Hilo * Point)
         Gi_408 = TRUE;
      if(Gi_416 && Bid - Gd_344 >= PipStep_Hilo * Point)
         Gi_408 = TRUE;
     }
   if(Gi_396 < 1)
     {
      Gi_416 = FALSE;
      Gi_412 = FALSE;
      Gi_408 = TRUE;
      Gd_288 = AccountEquity();
     }
   if(Gi_408)
     {
      Gd_336 = f0_32();
      Gd_344 = f0_20();
      if(Gi_416)
        {
         Gi_380 = Gi_396;
         Gd_384 = NormalizeDouble(Ld_1192 * MathPow(Ld_1160, Gi_380), Li_1168);
         RefreshRates();
         Gi_420 = f0_3(1, Gd_384, Bid, slip_Hilo, Ask, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Hilo, 0, HotPink);
         if(Gi_420 < 0)
           {
            Print("Error: ", GetLastError());
            return (0);
           }
         Gd_344 = f0_20();
         Gi_408 = FALSE;
         Gi_424 = TRUE;
        }
      else
        {
         if(Gi_412)
           {
            Gi_380 = Gi_396;
            Gd_384 = NormalizeDouble(Ld_1192 * MathPow(Ld_1160, Gi_380), Li_1168);
            Gi_420 = f0_3(0, Gd_384, Ask, slip_Hilo, Bid, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Hilo, 0, Lime);
            if(Gi_420 < 0)
              {
               Print("Error: ", GetLastError());
               return (0);
              }
            Gd_336 = f0_32();
            Gi_408 = FALSE;
            Gi_424 = TRUE;
           }
        }
     }
   if(Gi_408 && Gi_396 < 1)
     {
      ihigh_1128 = iHigh(Symbol(), 0, 1);
      ilow_1136 = iLow(Symbol(), 0, 2);
      G_bid_320 = Bid;
      G_ask_328 = Ask;
      if((!Gi_416) && !Gi_412)
        {
         Gi_380 = Gi_396;
         Gd_384 = NormalizeDouble(Ld_1192 * MathPow(Ld_1160, Gi_380), Li_1168);
         if(ihigh_1128 > ilow_1136)
           {
            if(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0)
              {
               Gi_420 = f0_3(1, Gd_384, G_bid_320, slip_Hilo, G_bid_320, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Hilo, 0, HotPink);
               if(Gi_420 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return (0);
                 }
               Gd_336 = f0_32();
               Gi_424 = TRUE;
              }
           }
         else
           {
            if(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0)
              {
               Gi_420 = f0_3(0, Gd_384, G_ask_328, slip_Hilo, G_ask_328, 0, 0, Gs_364 + "-" + Gi_380, MagicNumber_Hilo, 0, Lime);
               if(Gi_420 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return (0);
                 }
               Gd_344 = f0_20();
               Gi_424 = TRUE;
              }
           }
         if(Gi_420 > 0)
            Gi_376 = TimeCurrent() + 60.0 * (60.0 * Gd_224);
         Gi_408 = FALSE;
        }
     }
   Gi_396 = f0_4();
   G_price_312 = 0;
   double Ld_1208 = 0;
   for(G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--)
     {
      OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
        {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
           {
            G_price_312 += OrderOpenPrice() * OrderLots();
            Ld_1208 += OrderLots();
           }
        }
     }
   if(Gi_396 > 0)
      G_price_312 = NormalizeDouble(G_price_312 / Ld_1208, Digits);
   if(Gi_424)
     {
      for(G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--)
        {
         OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
            continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
           {
            if(OrderType() == OP_BUY)
              {
               G_price_280 = G_price_312 + Ld_1172 * Point;
               Gd_unused_296 = G_price_280;
               Gd_400 = G_price_312 - G_pips_236 * Point;
               Gi_360 = TRUE;
              }
           }
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
           {
            if(OrderType() == OP_SELL)
              {
               G_price_280 = G_price_312 - Ld_1172 * Point;
               Gd_unused_304 = G_price_280;
               Gd_400 = G_price_312 + G_pips_236 * Point;
               Gi_360 = TRUE;
              }
           }
        }
     }
   if(Gi_424)
     {
      if(Gi_360 == TRUE)
        {
         for(G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--)
           {
            OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
            if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
               continue;
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
               OrderModify(OrderTicket(), G_price_312, OrderStopLoss(), G_price_280, 0, Yellow);
            Gi_424 = FALSE;
           }
        }
     }
   double Ld_1216 = LotExponent;
   int Li_1224 = Gi_108;
   double Ld_1228 = TakeProfit;
   bool bool_1236 = UseEquityStop;
   double Ld_1240 = TotalEquityRisk;
   if(MM == TRUE)
     {
      if(MathCeil(AccountBalance()) < 2000.0)
         Ld_1248 = Lots;
      else
         Ld_1248 = 0.00001 * MathCeil(AccountBalance());
     }
   else
      Ld_1248 = Lots;
   if((CloseFriday == TRUE && DayOfWeek() == 5 && TimeCurrent() >= StrToTime(CloseFridayHour + ":00")) || (OpenMondey == TRUE && DayOfWeek() == 1 && TimeCurrent() <= StrToTime(OpenMondeyHour +
         ":00")))
      return (0);
   if(UseTrailingStop_15)
      f0_21(TrailStart_15, TrailStop_15, G_price_596);
   if(Gi_532)
     {
      if(TimeCurrent() >= Gi_660)
        {
         f0_18();
         Print("Closed All due to TimeOut");
        }
     }
   if(Gi_656 != Time[0])
     {
      Gi_656 = Time[0];
      Ld_1256 = f0_29();
      if(bool_1236)
        {
         if(Ld_1256 < 0.0 && MathAbs(Ld_1256) > Ld_1240 / 100.0 * f0_16())
           {
            f0_18();
            Print("Closed All due to Stop Out");
            Gi_708 = FALSE;
           }
        }
      Gi_680 = f0_5();
      if(Gi_680 == 0)
         Gi_644 = FALSE;
      for(G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--)
        {
         OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
            continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
           {
            if(OrderType() == OP_BUY)
              {
               Gi_696 = TRUE;
               Gi_700 = FALSE;
               break;
              }
           }
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
           {
            if(OrderType() == OP_SELL)
              {
               Gi_696 = FALSE;
               Gi_700 = TRUE;
               break;
              }
           }
        }
      if(Gi_680 > 0 && Gi_680 <= MaxTrades_15)
        {
         RefreshRates();
         Gd_620 = f0_36();
         Gd_628 = f0_28();
         if(Gi_696 && Gd_620 - Ask >= PipStep_15 * Point)
            Gi_692 = TRUE;
         if(Gi_700 && Bid - Gd_628 >= PipStep_15 * Point)
            Gi_692 = TRUE;
        }
      if(Gi_680 < 1)
        {
         Gi_700 = FALSE;
         Gi_696 = FALSE;
         Gi_692 = TRUE;
         Gd_572 = AccountEquity();
        }
      if(Gi_692)
        {
         Gd_620 = f0_36();
         Gd_628 = f0_28();
         if(Gi_700)
           {
            Gi_664 = Gi_680;
            Gd_668 = NormalizeDouble(Ld_1248 * MathPow(Ld_1216, Gi_664), Li_1224);
            RefreshRates();
            Gi_704 = f0_2(1, Gd_668, Bid, slip_15, Ask, 0, 0, Gs_648 + "-" + Gi_664, G_magic_176_15, 0, HotPink);
            if(Gi_704 < 0)
              {
               Print("Error: ", GetLastError());
               return (0);
              }
            Gd_628 = f0_28();
            Gi_692 = FALSE;
            Gi_708 = TRUE;
           }
         else
           {
            if(Gi_696)
              {
               Gi_664 = Gi_680;
               Gd_668 = NormalizeDouble(Ld_1248 * MathPow(Ld_1216, Gi_664), Li_1224);
               Gi_704 = f0_2(0, Gd_668, Ask, slip_15, Bid, 0, 0, Gs_648 + "-" + Gi_664, G_magic_176_15, 0, Lime);
               if(Gi_704 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return (0);
                 }
               Gd_620 = f0_36();
               Gi_692 = FALSE;
               Gi_708 = TRUE;
              }
           }
        }
     }
   if(G_datetime_728 != iTime(NULL, G_timeframe_496, 0))
     {
      Li_1264 = OrdersTotal();
      count_1268 = 0;
      for(int Li_1272 = Li_1264; Li_1272 >= 1; Li_1272--)
        {
         OrderSelect(Li_1272 - 1, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
            continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
            count_1268++;
        }
      if(Li_1264 == 0 || count_1268 < 1)
        {
         iclose_1144 = iClose(Symbol(), 0, 2);
         iclose_1152 = iClose(Symbol(), 0, 1);
         G_bid_604 = Bid;
         G_ask_612 = Ask;
         Gi_664 = Gi_680;
         Gd_668 = Ld_1248;
         if(iclose_1144 > iclose_1152)
           {
            Gi_704 = f0_2(1, Gd_668, G_bid_604, slip_15, G_bid_604, 0, 0, Gs_648 + "-" + Gi_664, G_magic_176_15, 0, HotPink);
            if(Gi_704 < 0)
              {
               Print("Error: ", GetLastError());
               return (0);
              }
            Gd_620 = f0_36();
            Gi_708 = TRUE;
           }
         else
           {
            Gi_704 = f0_2(0, Gd_668, G_ask_612, slip_15, G_ask_612, 0, 0, Gs_648 + "-" + Gi_664, G_magic_176_15, 0, Lime);
            if(Gi_704 < 0)
              {
               Print("Error: ", GetLastError());
               return (0);
              }
            Gd_628 = f0_28();
            Gi_708 = TRUE;
           }
         if(Gi_704 > 0)
            Gi_660 = TimeCurrent() + 60.0 * (60.0 * Gd_536);
         Gi_692 = FALSE;
        }
      G_datetime_728 = iTime(NULL, G_timeframe_496, 0);
     }
   Gi_680 = f0_5();
   G_price_596 = 0;
   double Ld_1276 = 0;
   for(G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--)
     {
      OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
        {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
           {
            G_price_596 += OrderOpenPrice() * OrderLots();
            Ld_1276 += OrderLots();
           }
        }
     }
   if(Gi_680 > 0)
      G_price_596 = NormalizeDouble(G_price_596 / Ld_1276, Digits);
   if(Gi_708)
     {
      for(G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--)
        {
         OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
            continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
           {
            if(OrderType() == OP_BUY)
              {
               G_price_564 = G_price_596 + Ld_1228 * Point;
               Gd_unused_580 = G_price_564;
               Gd_684 = G_price_596 - G_pips_508 * Point;
               Gi_644 = TRUE;
              }
           }
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
           {
            if(OrderType() == OP_SELL)
              {
               G_price_564 = G_price_596 - Ld_1228 * Point;
               Gd_unused_588 = G_price_564;
               Gd_684 = G_price_596 + G_pips_508 * Point;
               Gi_644 = TRUE;
              }
           }
        }
     }
   if(Gi_708)
     {
      if(Gi_644 == TRUE)
        {
         for(G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--)
           {
            OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
            if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
               continue;
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
               OrderModify(OrderTicket(), G_price_596, OrderStopLoss(), G_price_564, 0, Yellow);
            Gi_708 = FALSE;
           }
        }
     }
   double Ld_1284 = LotExponent;
   int Li_1292 = Gi_108;
   double Ld_1296 = TakeProfit;
   bool bool_1304 = UseEquityStop;
   double Ld_1308 = TotalEquityRisk;
   if(MM == TRUE)
     {
      if(MathCeil(AccountBalance()) < 2000.0)
         Ld_1316 = Lots;
      else
         Ld_1316 = 0.00001 * MathCeil(AccountBalance());
     }
   else
      Ld_1316 = Lots;
   if((CloseFriday == TRUE && DayOfWeek() == 5 && TimeCurrent() >= StrToTime(CloseFridayHour + ":00")) || (OpenMondey == TRUE && DayOfWeek() == 1 && TimeCurrent() <= StrToTime(OpenMondeyHour +
         ":00")))
      return (0);
   if(UseTrailingStop_16)
      f0_34(TrailStart_16, TrailStop_16, G_price_880);
   if(Gi_816)
     {
      if(TimeCurrent() >= Gi_944)
        {
         f0_0();
         Print("Closed All due to TimeOut");
        }
     }
   if(Gi_940 != Time[0])
     {
      Gi_940 = Time[0];
      Ld_1324 = f0_8();
      if(bool_1304)
        {
         if(Ld_1324 < 0.0 && MathAbs(Ld_1324) > Ld_1308 / 100.0 * f0_30())
           {
            f0_0();
            Print("Closed All due to Stop Out");
            Gi_992 = FALSE;
           }
        }
      Gi_964 = f0_12();
      if(Gi_964 == 0)
         Gi_928 = FALSE;
      for(G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--)
        {
         OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
            continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
           {
            if(OrderType() == OP_BUY)
              {
               Gi_980 = TRUE;
               Gi_984 = FALSE;
               break;
              }
           }
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
           {
            if(OrderType() == OP_SELL)
              {
               Gi_980 = FALSE;
               Gi_984 = TRUE;
               break;
              }
           }
        }
      if(Gi_964 > 0 && Gi_964 <= MaxTrades_16)
        {
         RefreshRates();
         Gd_904 = f0_17();
         Gd_912 = f0_27();
         if(Gi_980 && Gd_904 - Ask >= PipStep_16 * Point)
            Gi_976 = TRUE;
         if(Gi_984 && Bid - Gd_912 >= PipStep_16 * Point)
            Gi_976 = TRUE;
        }
      if(Gi_964 < 1)
        {
         Gi_984 = FALSE;
         Gi_980 = FALSE;
         Gd_856 = AccountEquity();
        }
      if(Gi_976)
        {
         Gd_904 = f0_17();
         Gd_912 = f0_27();
         if(Gi_984)
           {
            Gi_948 = Gi_964;
            Gd_952 = NormalizeDouble(Ld_1316 * MathPow(Ld_1284, Gi_948), Li_1292);
            RefreshRates();
            Gi_988 = f0_6(1, Gd_952, Bid, slip_16, Ask, 0, 0, Gs_932 + "-" + Gi_948, G_magic_176_16, 0, HotPink);
            if(Gi_988 < 0)
              {
               Print("Error: ", GetLastError());
               return (0);
              }
            Gd_912 = f0_27();
            Gi_976 = FALSE;
            Gi_992 = TRUE;
           }
         else
           {
            if(Gi_980)
              {
               Gi_948 = Gi_964;
               Gd_952 = NormalizeDouble(Ld_1316 * MathPow(Ld_1284, Gi_948), Li_1292);
               Gi_988 = f0_6(0, Gd_952, Ask, slip_16, Bid, 0, 0, Gs_932 + "-" + Gi_948, G_magic_176_16, 0, Lime);
               if(Gi_988 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return (0);
                 }
               Gd_904 = f0_17();
               Gi_976 = FALSE;
               Gi_992 = TRUE;
              }
           }
        }
     }
   if(G_datetime_1012 != iTime(NULL, G_timeframe_784, 0))
     {
      Li_1332 = OrdersTotal();
      count_1336 = 0;
      for(int Li_1340 = Li_1332; Li_1340 >= 1; Li_1340--)
        {
         OrderSelect(Li_1340 - 1, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
            continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
            count_1336++;
        }
      if(Li_1332 == 0 || count_1336 < 1)
        {
         iclose_1144 = iClose(Symbol(), 0, 2);
         iclose_1152 = iClose(Symbol(), 0, 1);
         G_bid_888 = Bid;
         G_ask_896 = Ask;
         Gi_948 = Gi_964;
         Gd_952 = Ld_1316;
         if(iclose_1144 > iclose_1152)
           {
            if(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0)
              {
               Gi_988 = f0_6(1, Gd_952, G_bid_888, slip_16, G_bid_888, 0, 0, Gs_932 + "-" + Gi_948, G_magic_176_16, 0, HotPink);
               if(Gi_988 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return (0);
                 }
               Gd_904 = f0_17();
               Gi_992 = TRUE;
              }
           }
         else
           {
            if(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0)
              {
               Gi_988 = f0_6(0, Gd_952, G_ask_896, slip_16, G_ask_896, 0, 0, Gs_932 + "-" + Gi_948, G_magic_176_16, 0, Lime);
               if(Gi_988 < 0)
                 {
                  Print("Error: ", GetLastError());
                  return (0);
                 }
               Gd_912 = f0_27();
               Gi_992 = TRUE;
              }
           }
         if(Gi_988 > 0)
            Gi_944 = TimeCurrent() + 60.0 * (60.0 * Gd_820);
         Gi_976 = FALSE;
        }
      G_datetime_1012 = iTime(NULL, G_timeframe_784, 0);
     }
   Gi_964 = f0_12();
   G_price_880 = 0;
   double Ld_1344 = 0;
   for(G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--)
     {
      OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
        {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
           {
            G_price_880 += OrderOpenPrice() * OrderLots();
            Ld_1344 += OrderLots();
           }
        }
     }
   if(Gi_964 > 0)
      G_price_880 = NormalizeDouble(G_price_880 / Ld_1344, Digits);
   if(Gi_992)
     {
      for(G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--)
        {
         OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
            continue;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
           {
            if(OrderType() == OP_BUY)
              {
               G_price_848 = G_price_880 + Ld_1296 * Point;
               Gd_unused_864 = G_price_848;
               Gd_968 = G_price_880 - G_pips_792 * Point;
               Gi_928 = TRUE;
              }
           }
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
           {
            if(OrderType() == OP_SELL)
              {
               G_price_848 = G_price_880 - Ld_1296 * Point;
               Gd_unused_872 = G_price_848;
               Gd_968 = G_price_880 + G_pips_792 * Point;
               Gi_928 = TRUE;
              }
           }
        }
     }
   if(Gi_992)
     {
      if(Gi_928 == TRUE)
        {
         for(G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--)
           {
            OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
            if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
               continue;
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
               OrderModify(OrderTicket(), G_price_880, OrderStopLoss(), G_price_848, 0, Yellow);
            Gi_992 = FALSE;
           }
        }
     }
   return (0);
  }

// 1DCB176FA67889B5B0CADBD0A6FE56CB
int f0_4()
  {
   int count_0 = 0;
   for(int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--)
     {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
         if(OrderType() == OP_SELL || OrderType() == OP_BUY)
            count_0++;
     }
   return (count_0);
  }

// BC923F6CA29E7C93CDFEA0D2DFB5608A
void f0_24()
  {
   for(int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--)
     {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol())
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
           {
            if(OrderType() == OP_BUY)
               OrderClose(OrderTicket(), OrderLots(), Bid, slip_Hilo, Blue);
            if(OrderType() == OP_SELL)
               OrderClose(OrderTicket(), OrderLots(), Ask, slip_Hilo, Red);
           }
         Sleep(1000);
        }
     }
  }

// 18EBBC4DF42B2A4E20BA8E3AA1C6A3DF
int f0_3(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56)
  {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch(Ai_0)
     {
      case 2:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_22(Ad_24, Ai_32), f0_19(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(1000);
           }
         break;
      case 4:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_22(Ad_24, Ai_32), f0_19(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 0:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            RefreshRates();
            ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_22(Bid, Ai_32), f0_19(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
            PlaySound("jaipong.wav");
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 3:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_11(Ad_24, Ai_32), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 5:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_11(Ad_24, Ai_32), f0_1(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 1:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_11(Ask, Ai_32), f0_1(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
            PlaySound("jaipong.wav");
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
     }
   return (ticket_60);
  }

// ABBF0924C7D109476997F144FF69BA18
double f0_22(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 - Ai_8 * Point);
  }

// 65324E009A83B2CB88BFB3D4529CFA3F
double f0_11(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 + Ai_8 * Point);
  }

// A4B319A5A3851A7BB5CE0B195DF27F55
double f0_19(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 + Ai_8 * Point);
  }

// 0CCFFE5E259E6D9684C883601327DD0E
double f0_1(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 - Ai_8 * Point);
  }

// DEE6BAA1FB47E044DB484D868C724C77
double f0_31()
  {
   double Ld_ret_0 = 0;
   for(G_pos_392 = OrdersTotal() - 1; G_pos_392 >= 0; G_pos_392--)
     {
      OrderSelect(G_pos_392, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
            Ld_ret_0 += OrderProfit();
     }
   return (Ld_ret_0);
  }

// F65FADF1B81B5341149ECACF620D59C5
void f0_35(int Ai_0, int Ai_4, double A_price_8)
  {
   int Li_16;
   double order_stoploss_20;
   double price_28;
   if(Ai_4 != 0)
     {
      for(int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--)
        {
         if(OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
               continue;
            if(OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_Hilo)
              {
               if(OrderType() == OP_BUY)
                 {
                  Li_16 = NormalizeDouble((Bid - A_price_8) / Point, 0);
                  if(Li_16 < Ai_0)
                     continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Bid - Ai_4 * Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20))
                     OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Aqua);
                 }
               if(OrderType() == OP_SELL)
                 {
                  Li_16 = NormalizeDouble((A_price_8 - Ask) / Point, 0);
                  if(Li_16 < Ai_0)
                     continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Ask + Ai_4 * Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20))
                     OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Red);
                 }
              }
            Sleep(1000);
           }
        }
     }
  }

// 30DCB0D08244C03D0790FB15BE95C82F
double f0_7()
  {
   if(f0_4() == 0)
      Gd_428 = AccountEquity();
   if(Gd_428 < Gd_436)
      Gd_428 = Gd_436;
   else
      Gd_428 = AccountEquity();
   Gd_436 = AccountEquity();
   return (Gd_428);
  }

// E22889128875A189AD17995E32998332
double f0_32()
  {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_BUY)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

// A5F3F48E555BFC9A5526CC1B30FF0AB2
double f0_20()
  {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_SELL)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

// 22F0FA52408CE450B63ADF3F087F21DE
int f0_5()
  {
   int count_0 = 0;
   for(int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--)
     {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
         if(OrderType() == OP_SELL || OrderType() == OP_BUY)
            count_0++;
     }
   return (count_0);
  }

// A180C6ED0DC34AACA6CCA8CB05FECC10
void f0_18()
  {
   for(int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--)
     {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol())
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
           {
            if(OrderType() == OP_BUY)
               OrderClose(OrderTicket(), OrderLots(), Bid, slip_15, Blue);
            if(OrderType() == OP_SELL)
               OrderClose(OrderTicket(), OrderLots(), Ask, slip_15, Red);
           }
         Sleep(1000);
        }
     }
  }

// 114DC2E883BB39B95234C711A240BE3E
int f0_2(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56)
  {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch(Ai_0)
     {
      case 2:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_13(Ad_24, Ai_32), f0_25(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(1000);
           }
         break;
      case 4:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_13(Ad_24, Ai_32), f0_25(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 0:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            RefreshRates();
            ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_13(Bid, Ai_32), f0_25(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
            PlaySound("keroncong.wav");
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 3:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_33(Ad_24, Ai_32), f0_26(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 5:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_33(Ad_24, Ai_32), f0_26(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 1:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_33(Ask, Ai_32), f0_26(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
            PlaySound("keroncong.wav");
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
     }
   return (ticket_60);
  }

// 7AE15E889172CCCB33ECFB32124CDF19
double f0_13(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 - Ai_8 * Point);
  }

// E29638E1934BE380D2D902E838F29BF7
double f0_33(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 + Ai_8 * Point);
  }

// BCF3A4C4831B7913DD5F18AF706ADC75
double f0_25(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 + Ai_8 * Point);
  }

// C4C44C724F3DAE9C33262735893D433A
double f0_26(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 - Ai_8 * Point);
  }

// D3C476201B00C1A782FB71A65C106452
double f0_29()
  {
   double Ld_ret_0 = 0;
   for(G_pos_676 = OrdersTotal() - 1; G_pos_676 >= 0; G_pos_676--)
     {
      OrderSelect(G_pos_676, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15)
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
            Ld_ret_0 += OrderProfit();
     }
   return (Ld_ret_0);
  }

// A84D2ACC80FE890D5547A65D5C3D18EE
void f0_21(int Ai_0, int Ai_4, double A_price_8)
  {
   int Li_16;
   double order_stoploss_20;
   double price_28;
   if(Ai_4 != 0)
     {
      for(int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--)
        {
         if(OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
               continue;
            if(OrderSymbol() == Symbol() || OrderMagicNumber() == G_magic_176_15)
              {
               if(OrderType() == OP_BUY)
                 {
                  Li_16 = NormalizeDouble((Bid - A_price_8) / Point, 0);
                  if(Li_16 < Ai_0)
                     continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Bid - Ai_4 * Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20))
                     OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Aqua);
                 }
               if(OrderType() == OP_SELL)
                 {
                  Li_16 = NormalizeDouble((A_price_8 - Ask) / Point, 0);
                  if(Li_16 < Ai_0)
                     continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Ask + Ai_4 * Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20))
                     OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Red);
                 }
              }
            Sleep(1000);
           }
        }
     }
  }

// 9EB62284E5C15187BCA5B502C66B6C59
double f0_16()
  {
   if(f0_5() == 0)
      Gd_712 = AccountEquity();
   if(Gd_712 < Gd_720)
      Gd_712 = Gd_720;
   else
      Gd_712 = AccountEquity();
   Gd_720 = AccountEquity();
   return (Gd_712);
  }

// F66F194C04A03CB5E74EC2A8C1DD0537
double f0_36()
  {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15 && OrderType() == OP_BUY)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

// C8E1186288BBCE29FD09990000128B35
double f0_28()
  {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_15)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_15 && OrderType() == OP_SELL)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

// 6EF0698100DD80AB6B7953B95E5FAD5C
int f0_12()
  {
   int count_0 = 0;
   for(int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--)
     {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
         if(OrderType() == OP_SELL || OrderType() == OP_BUY)
            count_0++;
     }
   return (count_0);
  }

// 065CE9405D7D7C2EAE70F2FF0F5A8147
void f0_0()
  {
   for(int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--)
     {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol())
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
           {
            if(OrderType() == OP_BUY)
               OrderClose(OrderTicket(), OrderLots(), Bid, slip_16, Blue);
            if(OrderType() == OP_SELL)
               OrderClose(OrderTicket(), OrderLots(), Ask, slip_16, Red);
           }
         Sleep(1000);
        }
     }
  }

// 25977731C5753DECF295DA11C4378DE5
int f0_6(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56)
  {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch(Ai_0)
     {
      case 2:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, Ai_32), f0_9(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(1000);
           }
         break;
      case 4:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_14(Ad_24, Ai_32), f0_9(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 0:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            RefreshRates();
            ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_14(Bid, Ai_32), f0_9(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
            PlaySound("tortor.wav");
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 3:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_23(Ad_24, Ai_32), f0_10(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 5:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_23(Ad_24, Ai_32), f0_10(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
                                  A_color_56);
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
         break;
      case 1:
         for(count_68 = 0; count_68 < Li_72; count_68++)
           {
            ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_23(Ask, Ai_32), f0_10(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
            PlaySound("tortor.wav");
            error_64 = GetLastError();
            if(error_64 == 0/* NO_ERROR */)
               break;
            if(!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */)))
               break;
            Sleep(5000);
           }
     }
   return (ticket_60);
  }

// 87D810BEA6B0AD2FCF70C69C17E19362
double f0_14(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 - Ai_8 * Point);
  }

// B3477275C69E607F97F2840B12AE4A9F
double f0_23(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 + Ai_8 * Point);
  }

// 37FA8C95BB37E55BB52283CC69099A5F
double f0_9(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 + Ai_8 * Point);
  }

// 5EF05A0BDFEED3445F4FE51BA1977B3C
double f0_10(double Ad_0, int Ai_8)
  {
   if(Ai_8 == 0)
      return (0);
   return (Ad_0 - Ai_8 * Point);
  }

// 31C5A9E59B9C6E81AE342B735890CD44
double f0_8()
  {
   double Ld_ret_0 = 0;
   for(G_pos_960 = OrdersTotal() - 1; G_pos_960 >= 0; G_pos_960--)
     {
      OrderSelect(G_pos_960, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16)
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
            Ld_ret_0 += OrderProfit();
     }
   return (Ld_ret_0);
  }

// ED2502136334FB187FF67433121886AF
void f0_34(int Ai_0, int Ai_4, double A_price_8)
  {
   int Li_16;
   double order_stoploss_20;
   double price_28;
   if(Ai_4 != 0)
     {
      for(int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--)
        {
         if(OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
               continue;
            if(OrderSymbol() == Symbol() || OrderMagicNumber() == G_magic_176_16)
              {
               if(OrderType() == OP_BUY)
                 {
                  Li_16 = NormalizeDouble((Bid - A_price_8) / Point, 0);
                  if(Li_16 < Ai_0)
                     continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Bid - Ai_4 * Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20))
                     OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Aqua);
                 }
               if(OrderType() == OP_SELL)
                 {
                  Li_16 = NormalizeDouble((A_price_8 - Ask) / Point, 0);
                  if(Li_16 < Ai_0)
                     continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Ask + Ai_4 * Point;
                  if(order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20))
                     OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Red);
                 }
              }
            Sleep(1000);
           }
        }
     }
  }

// DED4C3E9893A50A6B8A9A57E1BCD0548
double f0_30()
  {
   if(f0_12() == 0)
      Gd_996 = AccountEquity();
   if(Gd_996 < Gd_1004)
      Gd_996 = Gd_1004;
   else
      Gd_996 = AccountEquity();
   Gd_1004 = AccountEquity();
   return (Gd_996);
  }

// 9FC0A73FE3F286FD086830C3094E8AB3
double f0_17()
  {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16 && OrderType() == OP_BUY)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

// C55A286500E20535F02887DCF6EFC3C6
double f0_27()
  {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_176_16)
         continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_176_16 && OrderType() == OP_SELL)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }

// 92C7F8E36E974654E9EB3FFC8596DD76
string f0_15(string As_0)
  {
   int str_len_8 = StringLen(As_0);
   bool Li_ret_12 = FALSE;
   for(int Li_16 = 0; Li_16 < str_len_8; Li_16++)
     {
      if(StringSubstr(As_0, Li_16, 1) == "1")
         Li_ret_12 = Li_ret_12 + MathPow(16, str_len_8 - Li_16 - 1);
      else
        {
         if(StringSubstr(As_0, Li_16, 1) == "2")
            Li_ret_12 = Li_ret_12 + 2.0 * MathPow(16, str_len_8 - Li_16 - 1);
         else
           {
            if(StringSubstr(As_0, Li_16, 1) == "3")
               Li_ret_12 = Li_ret_12 + 3.0 * MathPow(16, str_len_8 - Li_16 - 1);
            else
              {
               if(StringSubstr(As_0, Li_16, 1) == "4")
                  Li_ret_12 = Li_ret_12 + 4.0 * MathPow(16, str_len_8 - Li_16 - 1);
               else
                 {
                  if(StringSubstr(As_0, Li_16, 1) == "5")
                     Li_ret_12 = Li_ret_12 + 5.0 * MathPow(16, str_len_8 - Li_16 - 1);
                  else
                    {
                     if(StringSubstr(As_0, Li_16, 1) == "6")
                        Li_ret_12 = Li_ret_12 + 6.0 * MathPow(16, str_len_8 - Li_16 - 1);
                     else
                       {
                        if(StringSubstr(As_0, Li_16, 1) == "7")
                           Li_ret_12 = Li_ret_12 + 7.0 * MathPow(16, str_len_8 - Li_16 - 1);
                        else
                          {
                           if(StringSubstr(As_0, Li_16, 1) == "8")
                              Li_ret_12 = Li_ret_12 + 8.0 * MathPow(16, str_len_8 - Li_16 - 1);
                           else
                             {
                              if(StringSubstr(As_0, Li_16, 1) == "9")
                                 Li_ret_12 = Li_ret_12 + 9.0 * MathPow(16, str_len_8 - Li_16 - 1);
                              else
                                {
                                 if(StringSubstr(As_0, Li_16, 1) == "A")
                                    Li_ret_12 = Li_ret_12 + 10.0 * MathPow(16, str_len_8 - Li_16 - 1);
                                 else
                                   {
                                    if(StringSubstr(As_0, Li_16, 1) == "B")
                                       Li_ret_12 = Li_ret_12 + 11.0 * MathPow(16, str_len_8 - Li_16 - 1);
                                    else
                                      {
                                       if(StringSubstr(As_0, Li_16, 1) == "C")
                                          Li_ret_12 = Li_ret_12 + 12.0 * MathPow(16, str_len_8 - Li_16 - 1);
                                       else
                                         {
                                          if(StringSubstr(As_0, Li_16, 1) == "D")
                                             Li_ret_12 = Li_ret_12 + 13.0 * MathPow(16, str_len_8 - Li_16 - 1);
                                          else
                                            {
                                             if(StringSubstr(As_0, Li_16, 1) == "E")
                                                Li_ret_12 = Li_ret_12 + 14.0 * MathPow(16, str_len_8 - Li_16 - 1);
                                             else
                                                if(StringSubstr(As_0, Li_16, 1) == "F")
                                                   Li_ret_12 = Li_ret_12 + 15.0 * MathPow(16, str_len_8 - Li_16 - 1);
                                            }
                                         }
                                      }
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
     }
   return (Li_ret_12);
  }
//+------------------------------------------------------------------+
