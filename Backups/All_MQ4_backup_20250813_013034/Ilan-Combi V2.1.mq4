//+------------------------------------------------------------------+
//|                                             Ilan-Combi V2.1 mq4 |
//|                                                            Night |
//|                                               alfonius@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Night"
#property link      "alfonius@yandex.ru"

//+------------------------------------------------------------------+
//=====================
//=====================
extern string _= "Общие_Настройки";
extern double MinLots = 0.01;       // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
extern bool MM =false;               // ММ - манименеджмент
extern int PeriodATR = 5;           //таймфрейм АТR для расчёта колен (на 1 выше текущего- для М1 ставим 5, для М5 ставим 15 и т.д.) 
extern int PeriodDeM = 15;          //таймфрейм DeMarker для расчёта лота (для М1- 15)
int ATR = 4000;
//extern bool UseATR =true;         // используем АТР для расчёта колен
//extern bool UseATRLot =true;      // используем АТР для расчёта лота
//extern int ATRLot = 4000;

//=====================
//First
//=====================
extern string __= "Настройки First";
bool UseTrailingStop_H = FALSE;     // использовать трейлинг стоп
extern double LotExponent_H = 1.69; // умножение лотов в серии по експоненте для вывода в безубыток. первый лот 0.1, серия: 0.15, 0.26, 0.43 ...
//=====================
double Lots_H;                      // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
int lotdecimal_H = 2;               // 2 - микролоты 0.01, 1 - мини лоты 0.1, 0 - нормальные лоты 1.0
extern double TakeProfit_H = 10.0;  // тейк профит
extern double PipStep_H = 30.0;     // шаг колена
extern double slip_H = 3.0;         // проскальзывание
extern int MaxTrades_H = 7;        // максимально количество одновременно открытых ордеров
int MagicNumber_H = 111;            // магик
//======================
bool UseEquityStop_H = FALSE;       // использовать риск в процентах
double TotalEquityRisk_H = 20.0;    // риск в процентах от депозита
bool UseTimeOut_H = FALSE;          // использовать анулирование ордеров по времени
double MaxTradeOpenHours_H = 48.0;  // через колько часов анулировать висячие ордера
double Stoploss_H = 500.0;          
double TrailStart_H = 15.0;
double TrailStop_H = 5.0;
//======================
double PriceTarget_H, StartEquity_H, BuyTarget_H, SellTarget_H ;
double AveragePrice_H, SellLimit_H, BuyLimit_H ;
double LastBuyPrice_H, LastSellPrice_H, Spread_H;
bool flag_H;
string EAName_H = "First";
int timeprev_H = 0, expiration_H;
int NumOfTrades_H = 0;
double iLots_H;
int cnt_H = 0, total_H;
double Stopper_H = 0.0;
bool TradeNow_H = FALSE, LongTrade_H = FALSE, ShortTrade_H = FALSE;
int ticket_H;
bool NewOrdersPlaced_H = FALSE;
double AccountEquityHighAmt_H, PrevEquity_H;
//=======================
//Second
//=======================
extern string ___= "Настройки Second";
bool UseTrailing_G = FALSE;
extern double MultiLotsFactor_G = 1.69;
extern double TakeProfit_G = 10.0;
extern double StepLots_G = 30.0;
double TrailStart_G = 15.0;
double TrailStop_G = 5.0;
extern int MaxCountOrders_G = 7;
bool SafeEquity_G = FALSE;
double SafeEquityRisk_G = 20.0;
extern double slippage_G = 3.0;
int MagicNumber_G = 13579;
//==========
double Step_H;
double Step_G;
double Step_HLot;
double Step_GLot;
//==========
bool gi_220_G = FALSE;
double gd_224_G = 48.0;
double g_pips_232_G = 500.0;
double gd_240_G = 0.0;
bool gi_248_G = TRUE;
bool gi_252_G = FALSE;
int gi_256_G = 1;
double g_price_260_G;
double gd_268_G;
double gd_unused_276_G;
double gd_unused_284_G;
double g_price_292_G;
double g_bid_300_G;
double g_ask_308_G;
double gd_316_G;
double gd_324_G;
double gd_340_G;
bool gi_348_G;
string gs_352_G = "Second";
int g_time_360_G = 0;
int gi_364_G;
int gi_368_G = 0;    // № ордера
double gd_372_G;
int g_pos_380_G = 0; //cnt_H
int gi_384_G;
double gd_388_G = 0.0;
bool gi_396_G = FALSE;
bool gi_400_G = FALSE;
bool gi_404_G = FALSE;
int gi_408_G;
bool gi_412_G = FALSE;
int g_datetime_416_G = 0;
int g_datetime_420_G = 0;
double gd_424_G;
double gd_432_G;

//==============================
//индикатор
//==============================
double gd_308;
int g_timeframe_492 = PERIOD_M1;
int g_timeframe_496 = PERIOD_M5;
int g_timeframe_500 = PERIOD_M15;
int g_timeframe_504 = PERIOD_M30;
int g_timeframe_508 = PERIOD_H1;
int g_timeframe_512 = PERIOD_H4;
int g_timeframe_516 = PERIOD_D1;
//string gs_unused_520 = "<<<< Chart Position Settings >>>>>";
bool g_corner_528 = TRUE;
int gi_532 = 0;
int gi_536 = 10;
int g_window_540 = 0;
//string gs_unused_544 = " <<<< Comments Settings >>>>>>>>";
bool gi_552 = TRUE;
bool gi_556 = TRUE;
bool gi_560 = FALSE;
int g_color_564 = Gray;
int g_color_568 = Gray;
int g_color_572 = Gray;
int g_color_576 = DarkOrange;
int g_color_580 = DarkOrange;
int gi_584 = 65280;
int gi_588 = 17919;
int gi_592 = 65280;
int gi_596 = 17919;
//string gs_unused_600 = " <<<< Price Color Settings >>>>>>>>";
int gi_608 = 65280;
int gi_612 = 255;
int gi_616 = 42495;
//string gs_unused_620 = "<<<< MACD Settings >>>>>>>>>>>";
int g_period_628 = 8;
int g_period_632 = 17;
int g_period_636 = 9;
int g_applied_price_640 = PRICE_CLOSE;
//string gs_unused_644 = "<<<< MACD Colors >>>>>>>>>>>>>>>>>>";
int gi_652 = 65280;
int gi_656 = 4678655;
int gi_660 = 32768;
int gi_664 = 255;
string gs_unused_668 = "<<<< STR Indicator Settings >>>>>>>>>>>>>";
string gs_unused_676 = "<<<< RSI Settings >>>>>>>>>>>>>";
int g_period_684 = 9;
int g_applied_price_688 = PRICE_CLOSE;
string gs_unused_692 = "<<<< CCI Settings >>>>>>>>>>>>>>";
int g_period_700 = 13;
int g_applied_price_704 = PRICE_CLOSE;
string gs_unused_708 = "<<<< STOCH Settings >>>>>>>>>>>";
int g_period_716 = 5;
int g_period_720 = 3;
int g_slowing_724 = 3;
int g_ma_method_728 = MODE_EMA;
string gs_unused_732 = "<<<< STR Colors >>>>>>>>>>>>>>>>";
int gi_740 = 65280;
int gi_744 = 255;
int gi_748 = 42495;
string gs_unused_752 = "<<<< MA Settings >>>>>>>>>>>>>>";
int g_period_760 = 5;
int g_period_764 = 9;
int g_ma_method_768 = MODE_EMA;
int g_applied_price_772 = PRICE_CLOSE;
string gs_unused_776 = "<<<< MA Colors >>>>>>>>>>>>>>";
int gi_784 = 65280;
int gi_788 = 255;
bool gi_792;
bool gi_796;
string gs_800;
double gd_808;
double g_acc_number_816;
double g_str2dbl_824;
double g_str_len_832;
double gd_848;
double gd_856;
double g_period_864;
double g_period_872;
double g_period_880;
double gd_888;
double gd_896;
double gd_904;
double gd_912;
double g_shift_920;
double gd_928;
double gd_936;
double gd_960;
double gd_968;
int g_bool_976;
double gd_980;
bool g_bool_988;
int gi_992;
//==============================
//==============================
//=======================
string    txt,txt1;
//=======================
int init()
{
//------------------------   
   ObjectCreate("Lable1",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 2);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 21);
   txt1="Ilan-Combi 2.1";
   ObjectSetText("Lable1",txt1,16,"Times New Roman",DeepSkyBlue);
//-------------------------
ObjectCreate("Lable",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable", OBJPROP_CORNER, 2);
   ObjectSet("Lable", OBJPROP_XDISTANCE, 3);
   ObjectSet("Lable", OBJPROP_YDISTANCE, 1);
   txt="Night "+CharToStr(174)+" alfonius@yandex.ru";
   ObjectSetText("Lable",txt,16,"Times New Roman",DeepSkyBlue);
//-------------------------   
//----First
Spread_H = MarketInfo(Symbol(), MODE_SPREAD) * Point; 
//----Second
gd_340_G = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   switch (MarketInfo(Symbol(), MODE_MINLOT)) {
   case 0.001:
      gd_240_G = 3;
      break;
   case 0.01:
      gd_240_G = 2;
      break;
   case 0.1:
      gd_240_G = 1;
      break;
   case 1.0:
      gd_240_G = 0;

   return(0);
}
}
//===================
//===================
int deinit()
  {
//=================
//=================
   ObjectDelete("cja");
   ObjectDelete("Signalprice");
   ObjectDelete("SIG_BARS_TF1");
   ObjectDelete("SIG_BARS_TF2");
   ObjectDelete("SIG_BARS_TF3");
   ObjectDelete("SIG_BARS_TF4");
   ObjectDelete("SIG_BARS_TF5");
   ObjectDelete("SIG_BARS_TF6");
   ObjectDelete("SIG_BARS_TF7");
   ObjectDelete("SSignalMACD_TEXT");
   ObjectDelete("SSignalMACDM1");
   ObjectDelete("SSignalMACDM5");
   ObjectDelete("SSignalMACDM15");
   ObjectDelete("SSignalMACDM30");
   ObjectDelete("SSignalMACDH1");
   ObjectDelete("SSignalMACDH4");
   ObjectDelete("SSignalMACDD1");
   ObjectDelete("SSignalSTR_TEXT");
   ObjectDelete("SignalSTRM1");
   ObjectDelete("SignalSTRM5");
   ObjectDelete("SignalSTRM15");
   ObjectDelete("SignalSTRM30");
   ObjectDelete("SignalSTRH1");
   ObjectDelete("SignalSTRH4");
   ObjectDelete("SignalSTRD1");
   ObjectDelete("SignalEMA_TEXT");
   ObjectDelete("SignalEMAM1");
   ObjectDelete("SignalEMAM5");
   ObjectDelete("SignalEMAM15");
   ObjectDelete("SignalEMAM30");
   ObjectDelete("SignalEMAH1");
   ObjectDelete("SignalEMAH4");
   ObjectDelete("SignalEMAD1");
   ObjectDelete("SIG_DETAIL_1");
   ObjectDelete("SIG_DETAIL_2");
   ObjectDelete("SIG_DETAIL_3");
   ObjectDelete("SIG_DETAIL_4");
   ObjectDelete("SIG_DETAIL_5");
   ObjectDelete("SIG_DETAIL_6");
   ObjectDelete("SIG_DETAIL_7");
   ObjectDelete("SIG_DETAIL_8");
//=================
//=================
//----
 ObjectDelete("Lable");
 ObjectDelete("Lable1"); 
//----
return(0);
}
//===================
//===================
int start() 
{
   //======================
   //======================
   {
   int li_0;
   int li_4;
   int li_8;
   int li_12;
   int li_16;
   int li_20;
   int li_24;
   color l_color_28;
   color l_color_32;
   color l_color_36;
   color l_color_40;
   color l_color_44;
   color l_color_48;
   color l_color_52;
   string ls_unused_56;
   color l_color_64;
   color l_color_68;
   color l_color_72;
   color l_color_76;
   color l_color_80;
   color l_color_84;
   color l_color_88;
   color l_color_92;
   string ls_unused_96;
   color l_color_104;
   color l_color_108;
   double ld_968;
   double l_istochastic_976;
   double l_istochastic_984;
   double l_istochastic_992;
   double l_istochastic_1000;
   double l_ima_1008;
   double l_ima_1016;
   double l_ima_1024;
   double l_iclose_1032;
   double l_iclose_1040;
   double l_iclose_1048;
   double l_iclose_1056;
   double l_iopen_1064;
   double l_ima_1072;
   double l_ima_1080;
   int li_1088;
   double ld_1092;
   double l_ord_lots_1100;
   double l_ord_lots_1108;
   double ld_1116;
   int l_ind_counted_112 = IndicatorCounted();
   string l_text_116 = "";
   string l_text_124 = "";
   string l_text_132 = "";
   string l_text_140 = "";
   string l_text_148 = "";
   string l_text_156 = "";
   string l_text_164 = "";
   if (g_timeframe_492 == PERIOD_M1) l_text_116 = "M1";
   if (g_timeframe_492 == PERIOD_M5) l_text_116 = "M5";
   if (g_timeframe_492 == PERIOD_M15) l_text_116 = "M15";
   if (g_timeframe_492 == PERIOD_M30) l_text_116 = "M30";
   if (g_timeframe_492 == PERIOD_H1) l_text_116 = "H1";
   if (g_timeframe_492 == PERIOD_H4) l_text_116 = "H4";
   if (g_timeframe_492 == PERIOD_D1) l_text_116 = "D1";
   if (g_timeframe_492 == PERIOD_W1) l_text_116 = "W1";
   if (g_timeframe_492 == PERIOD_MN1) l_text_116 = "MN";
   if (g_timeframe_496 == PERIOD_M1) l_text_124 = "M1";
   if (g_timeframe_496 == PERIOD_M5) l_text_124 = "M5";
   if (g_timeframe_496 == PERIOD_M15) l_text_124 = "M15";
   if (g_timeframe_496 == PERIOD_M30) l_text_124 = "M30";
   if (g_timeframe_496 == PERIOD_H1) l_text_124 = "H1";
   if (g_timeframe_496 == PERIOD_H4) l_text_124 = "H4";
   if (g_timeframe_496 == PERIOD_D1) l_text_124 = "D1";
   if (g_timeframe_496 == PERIOD_W1) l_text_124 = "W1";
   if (g_timeframe_496 == PERIOD_MN1) l_text_124 = "MN";
   if (g_timeframe_500 == PERIOD_M1) l_text_132 = "M1";
   if (g_timeframe_500 == PERIOD_M5) l_text_132 = "M5";
   if (g_timeframe_500 == PERIOD_M15) l_text_132 = "M15";
   if (g_timeframe_500 == PERIOD_M30) l_text_132 = "M30";
   if (g_timeframe_500 == PERIOD_H1) l_text_132 = "H1";
   if (g_timeframe_500 == PERIOD_H4) l_text_132 = "H4";
   if (g_timeframe_500 == PERIOD_D1) l_text_132 = "D1";
   if (g_timeframe_500 == PERIOD_W1) l_text_132 = "W1";
   if (g_timeframe_500 == PERIOD_MN1) l_text_132 = "MN";
   if (g_timeframe_504 == PERIOD_M1) l_text_140 = "M1";
   if (g_timeframe_504 == PERIOD_M5) l_text_140 = "M5";
   if (g_timeframe_504 == PERIOD_M15) l_text_140 = "M15";
   if (g_timeframe_504 == PERIOD_M30) l_text_140 = "M30";
   if (g_timeframe_504 == PERIOD_H1) l_text_140 = "H1";
   if (g_timeframe_504 == PERIOD_H4) l_text_140 = "H4";
   if (g_timeframe_504 == PERIOD_D1) l_text_140 = "D1";
   if (g_timeframe_504 == PERIOD_W1) l_text_140 = "W1";
   if (g_timeframe_504 == PERIOD_MN1) l_text_140 = "MN";
   if (g_timeframe_508 == PERIOD_M1) l_text_148 = "M1";
   if (g_timeframe_508 == PERIOD_M5) l_text_148 = "M5";
   if (g_timeframe_508 == PERIOD_M15) l_text_148 = "M15";
   if (g_timeframe_508 == PERIOD_M30) l_text_148 = "M30";
   if (g_timeframe_508 == PERIOD_H1) l_text_148 = "H1";
   if (g_timeframe_508 == PERIOD_H4) l_text_148 = "H4";
   if (g_timeframe_508 == PERIOD_D1) l_text_148 = "D1";
   if (g_timeframe_508 == PERIOD_W1) l_text_148 = "W1";
   if (g_timeframe_508 == PERIOD_MN1) l_text_148 = "MN";
   if (g_timeframe_512 == PERIOD_M1) l_text_156 = "M1";
   if (g_timeframe_512 == PERIOD_M5) l_text_156 = "M5";
   if (g_timeframe_512 == PERIOD_M15) l_text_156 = "M15";
   if (g_timeframe_512 == PERIOD_M30) l_text_156 = "M30";
   if (g_timeframe_512 == PERIOD_H1) l_text_156 = "H1";
   if (g_timeframe_512 == PERIOD_H4) l_text_156 = "H4";
   if (g_timeframe_512 == PERIOD_D1) l_text_156 = "D1";
   if (g_timeframe_512 == PERIOD_W1) l_text_156 = "W1";
   if (g_timeframe_512 == PERIOD_MN1) l_text_156 = "MN";
   if (g_timeframe_516 == PERIOD_M1) l_text_164 = "M1";
   if (g_timeframe_516 == PERIOD_M5) l_text_164 = "M5";
   if (g_timeframe_516 == PERIOD_M15) l_text_164 = "M15";
   if (g_timeframe_516 == PERIOD_M30) l_text_164 = "M30";
   if (g_timeframe_516 == PERIOD_H1) l_text_164 = "H1";
   if (g_timeframe_516 == PERIOD_H4) l_text_164 = "H4";
   if (g_timeframe_516 == PERIOD_D1) l_text_164 = "D1";
   if (g_timeframe_516 == PERIOD_W1) l_text_164 = "W1";
   if (g_timeframe_516 == PERIOD_MN1) l_text_164 = "MN";
   if (g_timeframe_492 == PERIOD_M15) li_0 = -2;
   if (g_timeframe_492 == PERIOD_M30) li_0 = -2;
   if (g_timeframe_496 == PERIOD_M15) li_4 = -2;
   if (g_timeframe_496 == PERIOD_M30) li_4 = -2;
   if (g_timeframe_500 == PERIOD_M15) li_8 = -2;
   if (g_timeframe_500 == PERIOD_M30) li_8 = -2;
   if (g_timeframe_504 == PERIOD_M15) li_12 = -2;
   if (g_timeframe_504 == PERIOD_M30) li_12 = -2;
   if (g_timeframe_508 == PERIOD_M15) li_16 = -2;
   if (g_timeframe_508 == PERIOD_M30) li_16 = -2;
   if (g_timeframe_512 == PERIOD_M15) li_20 = -2;
   if (g_timeframe_512 == PERIOD_M30) li_20 = -2;
   if (g_timeframe_516 == PERIOD_M15) li_24 = -2;
   if (g_timeframe_512 == PERIOD_M30) li_24 = -2;
   if (gi_532 < 0) return (0);
   ObjectDelete("SIG_BARS_TF1");
   ObjectCreate("SIG_BARS_TF1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SIG_BARS_TF1", l_text_116, 7, "Arial Bold", g_color_564);
   ObjectSet("SIG_BARS_TF1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SIG_BARS_TF1", OBJPROP_XDISTANCE, gi_536 + 134 + li_0);
   ObjectSet("SIG_BARS_TF1", OBJPROP_YDISTANCE, gi_532 + 25);
   ObjectDelete("SIG_BARS_TF2");
   ObjectCreate("SIG_BARS_TF2", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SIG_BARS_TF2", l_text_124, 7, "Arial Bold", g_color_564);
   ObjectSet("SIG_BARS_TF2", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SIG_BARS_TF2", OBJPROP_XDISTANCE, gi_536 + 114 + li_4);
   ObjectSet("SIG_BARS_TF2", OBJPROP_YDISTANCE, gi_532 + 25);
   ObjectDelete("SIG_BARS_TF3");
   ObjectCreate("SIG_BARS_TF3", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SIG_BARS_TF3", l_text_132, 7, "Arial Bold", g_color_564);
   ObjectSet("SIG_BARS_TF3", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SIG_BARS_TF3", OBJPROP_XDISTANCE, gi_536 + 94 + li_8);
   ObjectSet("SIG_BARS_TF3", OBJPROP_YDISTANCE, gi_532 + 25);
   ObjectDelete("SIG_BARS_TF4");
   ObjectCreate("SIG_BARS_TF4", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SIG_BARS_TF4", l_text_140, 7, "Arial Bold", g_color_564);
   ObjectSet("SIG_BARS_TF4", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SIG_BARS_TF4", OBJPROP_XDISTANCE, gi_536 + 74 + li_12);
   ObjectSet("SIG_BARS_TF4", OBJPROP_YDISTANCE, gi_532 + 25);
   ObjectDelete("SIG_BARS_TF5");
   ObjectCreate("SIG_BARS_TF5", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SIG_BARS_TF5", l_text_148, 7, "Arial Bold", g_color_564);
   ObjectSet("SIG_BARS_TF5", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SIG_BARS_TF5", OBJPROP_XDISTANCE, gi_536 + 54 + li_16);
   ObjectSet("SIG_BARS_TF5", OBJPROP_YDISTANCE, gi_532 + 25);
   ObjectDelete("SIG_BARS_TF6");
   ObjectCreate("SIG_BARS_TF6", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SIG_BARS_TF6", l_text_156, 7, "Arial Bold", g_color_564);
   ObjectSet("SIG_BARS_TF6", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SIG_BARS_TF6", OBJPROP_XDISTANCE, gi_536 + 34 + li_20);
   ObjectSet("SIG_BARS_TF6", OBJPROP_YDISTANCE, gi_532 + 25);
   ObjectDelete("SIG_BARS_TF7");
   ObjectCreate("SIG_BARS_TF7", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SIG_BARS_TF7", l_text_164, 7, "Arial Bold", g_color_564);
   ObjectSet("SIG_BARS_TF7", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SIG_BARS_TF7", OBJPROP_XDISTANCE, gi_536 + 14 + li_24);
   ObjectSet("SIG_BARS_TF7", OBJPROP_YDISTANCE, gi_532 + 25);
   string l_text_172 = "";
   string l_text_180 = "";
   string l_text_188 = "";
   string l_text_196 = "";
   string l_text_204 = "";
   string l_text_212 = "";
   string l_text_220 = "";
   string ls_unused_228 = "";
   string ls_unused_236 = "";
   double l_imacd_244 = iMACD(NULL, g_timeframe_492, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_MAIN, 0);
   double l_imacd_252 = iMACD(NULL, g_timeframe_492, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_SIGNAL, 0);
   double l_imacd_260 = iMACD(NULL, g_timeframe_496, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_MAIN, 0);
   double l_imacd_268 = iMACD(NULL, g_timeframe_496, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_SIGNAL, 0);
   double l_imacd_276 = iMACD(NULL, g_timeframe_500, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_MAIN, 0);
   double l_imacd_284 = iMACD(NULL, g_timeframe_500, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_SIGNAL, 0);
   double l_imacd_292 = iMACD(NULL, g_timeframe_504, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_MAIN, 0);
   double l_imacd_300 = iMACD(NULL, g_timeframe_504, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_SIGNAL, 0);
   double l_imacd_308 = iMACD(NULL, g_timeframe_508, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_MAIN, 0);
   double l_imacd_316 = iMACD(NULL, g_timeframe_508, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_SIGNAL, 0);
   double l_imacd_324 = iMACD(NULL, g_timeframe_512, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_MAIN, 0);
   double l_imacd_332 = iMACD(NULL, g_timeframe_512, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_SIGNAL, 0);
   double l_imacd_340 = iMACD(NULL, g_timeframe_516, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_MAIN, 0);
   double l_imacd_348 = iMACD(NULL, g_timeframe_516, g_period_628, g_period_632, g_period_636, g_applied_price_640, MODE_SIGNAL, 0);
   if (l_imacd_244 > l_imacd_252) {
      l_text_196 = "-";
      l_color_40 = gi_660;
   }
   if (l_imacd_244 <= l_imacd_252) {
      l_text_196 = "-";
      l_color_40 = gi_656;
   }
   if (l_imacd_244 > l_imacd_252 && l_imacd_244 > 0.0) {
      l_text_196 = "-";
      l_color_40 = gi_652;
   }
   if (l_imacd_244 <= l_imacd_252 && l_imacd_244 < 0.0) {
      l_text_196 = "-";
      l_color_40 = gi_664;
   }
   if (l_imacd_260 > l_imacd_268) {
      l_text_204 = "-";
      l_color_44 = gi_660;
   }
   if (l_imacd_260 <= l_imacd_268) {
      l_text_204 = "-";
      l_color_44 = gi_656;
   }
   if (l_imacd_260 > l_imacd_268 && l_imacd_260 > 0.0) {
      l_text_204 = "-";
      l_color_44 = gi_652;
   }
   if (l_imacd_260 <= l_imacd_268 && l_imacd_260 < 0.0) {
      l_text_204 = "-";
      l_color_44 = gi_664;
   }
   if (l_imacd_276 > l_imacd_284) {
      l_text_212 = "-";
      l_color_48 = gi_660;
   }
   if (l_imacd_276 <= l_imacd_284) {
      l_text_212 = "-";
      l_color_48 = gi_656;
   }
   if (l_imacd_276 > l_imacd_284 && l_imacd_276 > 0.0) {
      l_text_212 = "-";
      l_color_48 = gi_652;
   }
   if (l_imacd_276 <= l_imacd_284 && l_imacd_276 < 0.0) {
      l_text_212 = "-";
      l_color_48 = gi_664;
   }
   if (l_imacd_292 > l_imacd_300) {
      l_text_220 = "-";
      l_color_52 = gi_660;
   }
   if (l_imacd_292 <= l_imacd_300) {
      l_text_220 = "-";
      l_color_52 = gi_656;
   }
   if (l_imacd_292 > l_imacd_300 && l_imacd_292 > 0.0) {
      l_text_220 = "-";
      l_color_52 = gi_652;
   }
   if (l_imacd_292 <= l_imacd_300 && l_imacd_292 < 0.0) {
      l_text_220 = "-";
      l_color_52 = gi_664;
   }
   if (l_imacd_308 > l_imacd_316) {
      l_text_180 = "-";
      l_color_32 = gi_660;
   }
   if (l_imacd_308 <= l_imacd_316) {
      l_text_180 = "-";
      l_color_32 = gi_656;
   }
   if (l_imacd_308 > l_imacd_316 && l_imacd_308 > 0.0) {
      l_text_180 = "-";
      l_color_32 = gi_652;
   }
   if (l_imacd_308 <= l_imacd_316 && l_imacd_308 < 0.0) {
      l_text_180 = "-";
      l_color_32 = gi_664;
   }
   if (l_imacd_324 > l_imacd_332) {
      l_text_188 = "-";
      l_color_36 = gi_660;
   }
   if (l_imacd_324 <= l_imacd_332) {
      l_text_188 = "-";
      l_color_36 = gi_656;
   }
   if (l_imacd_324 > l_imacd_332 && l_imacd_324 > 0.0) {
      l_text_188 = "-";
      l_color_36 = gi_652;
   }
   if (l_imacd_324 <= l_imacd_332 && l_imacd_324 < 0.0) {
      l_text_188 = "-";
      l_color_36 = gi_664;
   }
   if (l_imacd_340 > l_imacd_348) {
      l_text_172 = "-";
      l_color_28 = gi_660;
   }
   if (l_imacd_340 <= l_imacd_348) {
      l_text_172 = "-";
      l_color_28 = gi_656;
   }
   if (l_imacd_340 > l_imacd_348 && l_imacd_340 > 0.0) {
      l_text_172 = "-";
      l_color_28 = gi_652;
   }
   if (l_imacd_340 <= l_imacd_348 && l_imacd_340 < 0.0) {
      l_text_172 = "-";
      l_color_28 = gi_664;
   }
   ObjectDelete("SSignalMACD_TEXT");
   ObjectCreate("SSignalMACD_TEXT", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACD_TEXT", "MACD", 6, "Tahoma Narrow", g_color_568);
   ObjectSet("SSignalMACD_TEXT", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACD_TEXT", OBJPROP_XDISTANCE, gi_536 + 153);
   ObjectSet("SSignalMACD_TEXT", OBJPROP_YDISTANCE, gi_532 + 35);
   ObjectDelete("SSignalMACDM1");
   ObjectCreate("SSignalMACDM1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACDM1", l_text_196, 45, "Tahoma Narrow", l_color_40);
   ObjectSet("SSignalMACDM1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACDM1", OBJPROP_XDISTANCE, gi_536 + 130);
   ObjectSet("SSignalMACDM1", OBJPROP_YDISTANCE, gi_532 + 2);
   ObjectDelete("SSignalMACDM5");
   ObjectCreate("SSignalMACDM5", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACDM5", l_text_204, 45, "Tahoma Narrow", l_color_44);
   ObjectSet("SSignalMACDM5", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACDM5", OBJPROP_XDISTANCE, gi_536 + 110);
   ObjectSet("SSignalMACDM5", OBJPROP_YDISTANCE, gi_532 + 2);
   ObjectDelete("SSignalMACDM15");
   ObjectCreate("SSignalMACDM15", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACDM15", l_text_212, 45, "Tahoma Narrow", l_color_48);
   ObjectSet("SSignalMACDM15", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACDM15", OBJPROP_XDISTANCE, gi_536 + 90);
   ObjectSet("SSignalMACDM15", OBJPROP_YDISTANCE, gi_532 + 2);
   ObjectDelete("SSignalMACDM30");
   ObjectCreate("SSignalMACDM30", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACDM30", l_text_220, 45, "Tahoma Narrow", l_color_52);
   ObjectSet("SSignalMACDM30", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACDM30", OBJPROP_XDISTANCE, gi_536 + 70);
   ObjectSet("SSignalMACDM30", OBJPROP_YDISTANCE, gi_532 + 2);
   ObjectDelete("SSignalMACDH1");
   ObjectCreate("SSignalMACDH1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACDH1", l_text_180, 45, "Tahoma Narrow", l_color_32);
   ObjectSet("SSignalMACDH1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACDH1", OBJPROP_XDISTANCE, gi_536 + 50);
   ObjectSet("SSignalMACDH1", OBJPROP_YDISTANCE, gi_532 + 2);
   ObjectDelete("SSignalMACDH4");
   ObjectCreate("SSignalMACDH4", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACDH4", l_text_188, 45, "Tahoma Narrow", l_color_36);
   ObjectSet("SSignalMACDH4", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACDH4", OBJPROP_XDISTANCE, gi_536 + 30);
   ObjectSet("SSignalMACDH4", OBJPROP_YDISTANCE, gi_532 + 2);
   ObjectDelete("SSignalMACDD1");
   ObjectCreate("SSignalMACDD1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalMACDD1", l_text_172, 45, "Tahoma Narrow", l_color_28);
   ObjectSet("SSignalMACDD1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalMACDD1", OBJPROP_XDISTANCE, gi_536 + 10);
   ObjectSet("SSignalMACDD1", OBJPROP_YDISTANCE, gi_532 + 2);
   double l_irsi_356 = iRSI(NULL, g_timeframe_516, g_period_684, g_applied_price_688, 0);
   double l_irsi_364 = iRSI(NULL, g_timeframe_512, g_period_684, g_applied_price_688, 0);
   double l_irsi_372 = iRSI(NULL, g_timeframe_508, g_period_684, g_applied_price_688, 0);
   double l_irsi_380 = iRSI(NULL, g_timeframe_504, g_period_684, g_applied_price_688, 0);
   double l_irsi_388 = iRSI(NULL, g_timeframe_500, g_period_684, g_applied_price_688, 0);
   double l_irsi_396 = iRSI(NULL, g_timeframe_496, g_period_684, g_applied_price_688, 0);
   double l_irsi_404 = iRSI(NULL, g_timeframe_492, g_period_684, g_applied_price_688, 0);
   double l_istochastic_412 = iStochastic(NULL, g_timeframe_516, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, 0, MODE_MAIN, 0);
   double l_istochastic_420 = iStochastic(NULL, g_timeframe_512, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, 0, MODE_MAIN, 0);
   double l_istochastic_428 = iStochastic(NULL, g_timeframe_508, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, 0, MODE_MAIN, 0);
   double l_istochastic_436 = iStochastic(NULL, g_timeframe_504, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, 0, MODE_MAIN, 0);
   double l_istochastic_444 = iStochastic(NULL, g_timeframe_500, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, 0, MODE_MAIN, 0);
   double l_istochastic_452 = iStochastic(NULL, g_timeframe_496, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, 0, MODE_MAIN, 0);
   double l_istochastic_460 = iStochastic(NULL, g_timeframe_492, g_period_716, g_period_720, g_slowing_724, g_ma_method_728, 0, MODE_MAIN, 0);
   double l_icci_468 = iCCI(NULL, g_timeframe_516, g_period_700, g_applied_price_704, 0);
   double l_icci_476 = iCCI(NULL, g_timeframe_512, g_period_700, g_applied_price_704, 0);
   double l_icci_484 = iCCI(NULL, g_timeframe_508, g_period_700, g_applied_price_704, 0);
   double l_icci_492 = iCCI(NULL, g_timeframe_504, g_period_700, g_applied_price_704, 0);
   double l_icci_500 = iCCI(NULL, g_timeframe_500, g_period_700, g_applied_price_704, 0);
   double l_icci_508 = iCCI(NULL, g_timeframe_496, g_period_700, g_applied_price_704, 0);
   double l_icci_516 = iCCI(NULL, g_timeframe_492, g_period_700, g_applied_price_704, 0);
   string l_text_524 = "";
   string l_text_532 = "";
   string l_text_540 = "";
   string l_text_548 = "";
   string l_text_556 = "";
   string l_text_564 = "";
   string l_text_572 = "";
   string ls_unused_580 = "";
   string ls_unused_588 = "";
   l_text_572 = "-";
   color l_color_596 = gi_748;
   l_text_556 = "-";
   color l_color_600 = gi_748;
   l_text_524 = "-";
   color l_color_604 = gi_748;
   l_text_564 = "-";
   color l_color_608 = gi_748;
   l_text_532 = "-";
   color l_color_612 = gi_748;
   l_text_540 = "-";
   color l_color_616 = gi_748;
   l_text_548 = "-";
   color l_color_620 = gi_748;
   if (l_irsi_356 > 50.0 && l_istochastic_412 > 40.0 && l_icci_468 > 0.0) {
      l_text_572 = "-";
      l_color_596 = gi_740;
   }
   if (l_irsi_364 > 50.0 && l_istochastic_420 > 40.0 && l_icci_476 > 0.0) {
      l_text_556 = "-";
      l_color_600 = gi_740;
   }
   if (l_irsi_372 > 50.0 && l_istochastic_428 > 40.0 && l_icci_484 > 0.0) {
      l_text_524 = "-";
      l_color_604 = gi_740;
   }
   if (l_irsi_380 > 50.0 && l_istochastic_436 > 40.0 && l_icci_492 > 0.0) {
      l_text_564 = "-";
      l_color_608 = gi_740;
   }
   if (l_irsi_388 > 50.0 && l_istochastic_444 > 40.0 && l_icci_500 > 0.0) {
      l_text_532 = "-";
      l_color_612 = gi_740;
   }
   if (l_irsi_396 > 50.0 && l_istochastic_452 > 40.0 && l_icci_508 > 0.0) {
      l_text_540 = "-";
      l_color_616 = gi_740;
   }
   if (l_irsi_404 > 50.0 && l_istochastic_460 > 40.0 && l_icci_516 > 0.0) {
      l_text_548 = "-";
      l_color_620 = gi_740;
   }
   if (l_irsi_356 < 50.0 && l_istochastic_412 < 60.0 && l_icci_468 < 0.0) {
      l_text_572 = "-";
      l_color_596 = gi_744;
   }
   if (l_irsi_364 < 50.0 && l_istochastic_420 < 60.0 && l_icci_476 < 0.0) {
      l_text_556 = "-";
      l_color_600 = gi_744;
   }
   if (l_irsi_372 < 50.0 && l_istochastic_428 < 60.0 && l_icci_484 < 0.0) {
      l_text_524 = "-";
      l_color_604 = gi_744;
   }
   if (l_irsi_380 < 50.0 && l_istochastic_436 < 60.0 && l_icci_492 < 0.0) {
      l_text_564 = "-";
      l_color_608 = gi_744;
   }
   if (l_irsi_388 < 50.0 && l_istochastic_444 < 60.0 && l_icci_500 < 0.0) {
      l_text_532 = "-";
      l_color_612 = gi_744;
   }
   if (l_irsi_396 < 50.0 && l_istochastic_452 < 60.0 && l_icci_508 < 0.0) {
      l_text_540 = "-";
      l_color_616 = gi_744;
   }
   if (l_irsi_404 < 50.0 && l_istochastic_460 < 60.0 && l_icci_516 < 0.0) {
      l_text_548 = "-";
      l_color_620 = gi_744;
   }
   ObjectDelete("SSignalSTR_TEXT");
   ObjectCreate("SSignalSTR_TEXT", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SSignalSTR_TEXT", "STR", 6, "Tahoma Narrow", g_color_568);
   ObjectSet("SSignalSTR_TEXT", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SSignalSTR_TEXT", OBJPROP_XDISTANCE, gi_536 + 153);
   ObjectSet("SSignalSTR_TEXT", OBJPROP_YDISTANCE, gi_532 + 43);
   ObjectDelete("SignalSTRM1");
   ObjectCreate("SignalSTRM1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalSTRM1", l_text_548, 45, "Tahoma Narrow", l_color_620);
   ObjectSet("SignalSTRM1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalSTRM1", OBJPROP_XDISTANCE, gi_536 + 130);
   ObjectSet("SignalSTRM1", OBJPROP_YDISTANCE, gi_532 + 10);
   ObjectDelete("SignalSTRM5");
   ObjectCreate("SignalSTRM5", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalSTRM5", l_text_540, 45, "Tahoma Narrow", l_color_616);
   ObjectSet("SignalSTRM5", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalSTRM5", OBJPROP_XDISTANCE, gi_536 + 110);
   ObjectSet("SignalSTRM5", OBJPROP_YDISTANCE, gi_532 + 10);
   ObjectDelete("SignalSTRM15");
   ObjectCreate("SignalSTRM15", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalSTRM15", l_text_532, 45, "Tahoma Narrow", l_color_612);
   ObjectSet("SignalSTRM15", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalSTRM15", OBJPROP_XDISTANCE, gi_536 + 90);
   ObjectSet("SignalSTRM15", OBJPROP_YDISTANCE, gi_532 + 10);
   ObjectDelete("SignalSTRM30");
   ObjectCreate("SignalSTRM30", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalSTRM30", l_text_564, 45, "Tahoma Narrow", l_color_608);
   ObjectSet("SignalSTRM30", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalSTRM30", OBJPROP_XDISTANCE, gi_536 + 70);
   ObjectSet("SignalSTRM30", OBJPROP_YDISTANCE, gi_532 + 10);
   ObjectDelete("SignalSTRH1");
   ObjectCreate("SignalSTRH1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalSTRH1", l_text_524, 45, "Tahoma Narrow", l_color_604);
   ObjectSet("SignalSTRH1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalSTRH1", OBJPROP_XDISTANCE, gi_536 + 50);
   ObjectSet("SignalSTRH1", OBJPROP_YDISTANCE, gi_532 + 10);
   ObjectDelete("SignalSTRH4");
   ObjectCreate("SignalSTRH4", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalSTRH4", l_text_556, 45, "Tahoma Narrow", l_color_600);
   ObjectSet("SignalSTRH4", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalSTRH4", OBJPROP_XDISTANCE, gi_536 + 30);
   ObjectSet("SignalSTRH4", OBJPROP_YDISTANCE, gi_532 + 10);
   ObjectDelete("SignalSTRD1");
   ObjectCreate("SignalSTRD1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalSTRD1", l_text_572, 45, "Tahoma Narrow", l_color_596);
   ObjectSet("SignalSTRD1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalSTRD1", OBJPROP_XDISTANCE, gi_536 + 10);
   ObjectSet("SignalSTRD1", OBJPROP_YDISTANCE, gi_532 + 10);
   double l_ima_624 = iMA(Symbol(), g_timeframe_492, g_period_760, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_632 = iMA(Symbol(), g_timeframe_492, g_period_764, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_640 = iMA(Symbol(), g_timeframe_496, g_period_760, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_648 = iMA(Symbol(), g_timeframe_496, g_period_764, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_656 = iMA(Symbol(), g_timeframe_500, g_period_760, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_664 = iMA(Symbol(), g_timeframe_500, g_period_764, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_672 = iMA(Symbol(), g_timeframe_504, g_period_760, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_680 = iMA(Symbol(), g_timeframe_504, g_period_764, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_688 = iMA(Symbol(), g_timeframe_508, g_period_760, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_696 = iMA(Symbol(), g_timeframe_508, g_period_764, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_704 = iMA(Symbol(), g_timeframe_512, g_period_760, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_712 = iMA(Symbol(), g_timeframe_512, g_period_764, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_720 = iMA(Symbol(), g_timeframe_516, g_period_760, 0, g_ma_method_768, g_applied_price_772, 0);
   double l_ima_728 = iMA(Symbol(), g_timeframe_516, g_period_764, 0, g_ma_method_768, g_applied_price_772, 0);
   string l_text_736 = "";
   string l_text_744 = "";
   string l_text_752 = "";
   string l_text_760 = "";
   string l_text_768 = "";
   string l_text_776 = "";
   string l_text_784 = "";
   string ls_unused_792 = "";
   string ls_unused_800 = "";
   if (l_ima_624 > l_ima_632) {
      l_text_736 = "-";
      l_color_64 = gi_784;
   }
   if (l_ima_624 <= l_ima_632) {
      l_text_736 = "-";
      l_color_64 = gi_788;
   }
   if (l_ima_640 > l_ima_648) {
      l_text_744 = "-";
      l_color_68 = gi_784;
   }
   if (l_ima_640 <= l_ima_648) {
      l_text_744 = "-";
      l_color_68 = gi_788;
   }
   if (l_ima_656 > l_ima_664) {
      l_text_752 = "-";
      l_color_72 = gi_784;
   }
   if (l_ima_656 <= l_ima_664) {
      l_text_752 = "-";
      l_color_72 = gi_788;
   }
   if (l_ima_672 > l_ima_680) {
      l_text_760 = "-";
      l_color_76 = gi_784;
   }
   if (l_ima_672 <= l_ima_680) {
      l_text_760 = "-";
      l_color_76 = gi_788;
   }
   if (l_ima_688 > l_ima_696) {
      l_text_768 = "-";
      l_color_80 = gi_784;
   }
   if (l_ima_688 <= l_ima_696) {
      l_text_768 = "-";
      l_color_80 = gi_788;
   }
   if (l_ima_704 > l_ima_712) {
      l_text_776 = "-";
      l_color_84 = gi_784;
   }
   if (l_ima_704 <= l_ima_712) {
      l_text_776 = "-";
      l_color_84 = gi_788;
   }
   if (l_ima_720 > l_ima_728) {
      l_text_784 = "-";
      l_color_88 = gi_784;
   }
   if (l_ima_720 <= l_ima_728) {
      l_text_784 = "-";
      l_color_88 = gi_788;
   }
   ObjectDelete("SignalEMA_TEXT");
   ObjectCreate("SignalEMA_TEXT", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMA_TEXT", "EMA", 6, "Tahoma Narrow", g_color_568);
   ObjectSet("SignalEMA_TEXT", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMA_TEXT", OBJPROP_XDISTANCE, gi_536 + 153);
   ObjectSet("SignalEMA_TEXT", OBJPROP_YDISTANCE, gi_532 + 51);
   ObjectDelete("SignalEMAM1");
   ObjectCreate("SignalEMAM1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMAM1", l_text_736, 45, "Tahoma Narrow", l_color_64);
   ObjectSet("SignalEMAM1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMAM1", OBJPROP_XDISTANCE, gi_536 + 130);
   ObjectSet("SignalEMAM1", OBJPROP_YDISTANCE, gi_532 + 18);
   ObjectDelete("SignalEMAM5");
   ObjectCreate("SignalEMAM5", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMAM5", l_text_744, 45, "Tahoma Narrow", l_color_68);
   ObjectSet("SignalEMAM5", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMAM5", OBJPROP_XDISTANCE, gi_536 + 110);
   ObjectSet("SignalEMAM5", OBJPROP_YDISTANCE, gi_532 + 18);
   ObjectDelete("SignalEMAM15");
   ObjectCreate("SignalEMAM15", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMAM15", l_text_752, 45, "Tahoma Narrow", l_color_72);
   ObjectSet("SignalEMAM15", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMAM15", OBJPROP_XDISTANCE, gi_536 + 90);
   ObjectSet("SignalEMAM15", OBJPROP_YDISTANCE, gi_532 + 18);
   ObjectDelete("SignalEMAM30");
   ObjectCreate("SignalEMAM30", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMAM30", l_text_760, 45, "Tahoma Narrow", l_color_76);
   ObjectSet("SignalEMAM30", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMAM30", OBJPROP_XDISTANCE, gi_536 + 70);
   ObjectSet("SignalEMAM30", OBJPROP_YDISTANCE, gi_532 + 18);
   ObjectDelete("SignalEMAH1");
   ObjectCreate("SignalEMAH1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMAH1", l_text_768, 45, "Tahoma Narrow", l_color_80);
   ObjectSet("SignalEMAH1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMAH1", OBJPROP_XDISTANCE, gi_536 + 50);
   ObjectSet("SignalEMAH1", OBJPROP_YDISTANCE, gi_532 + 18);
   ObjectDelete("SignalEMAH4");
   ObjectCreate("SignalEMAH4", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMAH4", l_text_776, 45, "Tahoma Narrow", l_color_84);
   ObjectSet("SignalEMAH4", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMAH4", OBJPROP_XDISTANCE, gi_536 + 30);
   ObjectSet("SignalEMAH4", OBJPROP_YDISTANCE, gi_532 + 18);
   ObjectDelete("SignalEMAD1");
   ObjectCreate("SignalEMAD1", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("SignalEMAD1", l_text_784, 45, "Tahoma Narrow", l_color_88);
   ObjectSet("SignalEMAD1", OBJPROP_CORNER, g_corner_528);
   ObjectSet("SignalEMAD1", OBJPROP_XDISTANCE, gi_536 + 10);
   ObjectSet("SignalEMAD1", OBJPROP_YDISTANCE, gi_532 + 18);
   double ld_808 = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits);
   double l_ima_816 = iMA(Symbol(), PERIOD_M1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
   string ls_unused_824 = "";
   if (l_ima_816 > ld_808) {
      ls_unused_824 = "";
      l_color_92 = gi_612;
   }
   if (l_ima_816 < ld_808) {
      ls_unused_824 = "";
      l_color_92 = gi_608;
   }
   if (l_ima_816 == ld_808) {
      ls_unused_824 = "";
      l_color_92 = gi_616;
   }
   ObjectDelete("cja");
   ObjectCreate("cja", OBJ_LABEL, g_window_540, 0, 0);
   ObjectSetText("cja", "cja", 8, "Tahoma Narrow", DimGray);
   ObjectSet("cja", OBJPROP_CORNER, g_corner_528);
   ObjectSet("cja", OBJPROP_XDISTANCE, gi_536 + 153);
   ObjectSet("cja", OBJPROP_YDISTANCE, gi_532 + 23);
   if (gi_560 == FALSE) {
      if (gi_552 == TRUE) {
         ObjectDelete("Signalprice");
         ObjectCreate("Signalprice", OBJ_LABEL, g_window_540, 0, 0);
         ObjectSetText("Signalprice", DoubleToStr(ld_808, Digits), 35, "Arial", l_color_92);
         ObjectSet("Signalprice", OBJPROP_CORNER, g_corner_528);
         ObjectSet("Signalprice", OBJPROP_XDISTANCE, gi_536 + 10);
         ObjectSet("Signalprice", OBJPROP_YDISTANCE, gi_532 + 56);
      }
   }
   if (gi_560 == TRUE) {
      if (gi_552 == TRUE) {
         ObjectDelete("Signalprice");
         ObjectCreate("Signalprice", OBJ_LABEL, g_window_540, 0, 0);
         ObjectSetText("Signalprice", DoubleToStr(ld_808, Digits), 15, "Arial", l_color_92);
         ObjectSet("Signalprice", OBJPROP_CORNER, g_corner_528);
         ObjectSet("Signalprice", OBJPROP_XDISTANCE, gi_536 + 10);
         ObjectSet("Signalprice", OBJPROP_YDISTANCE, gi_532 + 60);
      }
   }
   int li_832 = 0;
   int li_836 = 0;
   int li_840 = 0;
   int li_844 = 0;
   int li_848 = 0;
   int li_852 = 0;
   li_832 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   for (li_852 = 1; li_852 <= 5; li_852++) li_836 = li_836 + (iHigh(NULL, PERIOD_D1, li_852) - iLow(NULL, PERIOD_D1, li_852)) / Point;
   for (li_852 = 1; li_852 <= 10; li_852++) li_840 = li_840 + (iHigh(NULL, PERIOD_D1, li_852) - iLow(NULL, PERIOD_D1, li_852)) / Point;
   for (li_852 = 1; li_852 <= 20; li_852++) li_844 = li_844 + (iHigh(NULL, PERIOD_D1, li_852) - iLow(NULL, PERIOD_D1, li_852)) / Point;
   li_836 /= 5;
   li_840 /= 10;
   li_844 /= 20;
   li_848 = (li_832 + li_836 + li_840 + li_844) / 4;
   string ls_unused_856 = "";
   string ls_unused_864 = "";
   string l_dbl2str_872 = "";
   string l_dbl2str_880 = "";
   string l_dbl2str_888 = "";
   string l_dbl2str_896 = "";
   string ls_unused_904 = "";
   string ls_unused_912 = "";
   string ls_920 = "";
   double l_iopen_928 = iOpen(NULL, PERIOD_D1, 0);
   double l_iclose_936 = iClose(NULL, PERIOD_D1, 0);
   double ld_944 = (Ask - Bid) / Point;
   double l_ihigh_952 = iHigh(NULL, PERIOD_D1, 0);
   double l_ilow_960 = iLow(NULL, PERIOD_D1, 0);
   l_dbl2str_880 = DoubleToStr((l_iclose_936 - l_iopen_928) / Point, 0);
   l_dbl2str_872 = DoubleToStr(ld_944, Digits - 4);
   l_dbl2str_888 = DoubleToStr(li_848, Digits - 4);
   ls_920 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   l_dbl2str_896 = DoubleToStr((l_ihigh_952 - l_ilow_960) / Point, 0);
   if (l_iclose_936 >= l_iopen_928) {
      ls_unused_904 = "-";
      l_color_104 = gi_584;
   }
   if (l_iclose_936 < l_iopen_928) {
      ls_unused_904 = "-";
      l_color_104 = gi_588;
   }
   if (l_dbl2str_888 >= ls_920) {
      ls_unused_912 = "-";
      l_color_108 = gi_592;
   }
   if (l_dbl2str_888 < ls_920) {
      ls_unused_912 = "-";
      l_color_108 = gi_596;
   }
   
          {
            ObjectDelete("SIG_DETAIL_1");
            ObjectCreate("SIG_DETAIL_1", OBJ_LABEL, g_window_540, 0, 0);
            ObjectSetText("SIG_DETAIL_1", "Spread", 14, "Times New Roman", g_color_572);
            ObjectSet("SIG_DETAIL_1", OBJPROP_CORNER, g_corner_528);
            ObjectSet("SIG_DETAIL_1", OBJPROP_XDISTANCE, gi_536 + 65);
            ObjectSet("SIG_DETAIL_1", OBJPROP_YDISTANCE, gi_532 + 100);
            ObjectDelete("SIG_DETAIL_2");
            ObjectCreate("SIG_DETAIL_2", OBJ_LABEL, g_window_540, 0, 0);
            ObjectSetText("SIG_DETAIL_2", "" + l_dbl2str_872 + "", 14, "Times New Roman", g_color_576);
            ObjectSet("SIG_DETAIL_2", OBJPROP_CORNER, g_corner_528);
            ObjectSet("SIG_DETAIL_2", OBJPROP_XDISTANCE, gi_536 + 10);
            ObjectSet("SIG_DETAIL_2", OBJPROP_YDISTANCE, gi_532 + 100);
            ObjectDelete("SIG_DETAIL_3");
            ObjectCreate("SIG_DETAIL_3", OBJ_LABEL, g_window_540, 0, 0);
            ObjectSetText("SIG_DETAIL_3", "Volatility Ratio", 14, "Times New Roman", g_color_572);
            ObjectSet("SIG_DETAIL_3", OBJPROP_CORNER, g_corner_528);
            ObjectSet("SIG_DETAIL_3", OBJPROP_XDISTANCE, gi_536 + 65);
            ObjectSet("SIG_DETAIL_3", OBJPROP_YDISTANCE, gi_532 + 115);
            ObjectDelete("SIG_DETAIL_4");
            ObjectCreate("SIG_DETAIL_4", OBJ_LABEL, g_window_540, 0, 0);
            ObjectSetText("SIG_DETAIL_4", "" + l_dbl2str_880 + "", 14, "Times New Roman", l_color_104);
            ObjectSet("SIG_DETAIL_4", OBJPROP_CORNER, g_corner_528);
            ObjectSet("SIG_DETAIL_4", OBJPROP_XDISTANCE, gi_536 + 10);
            ObjectSet("SIG_DETAIL_4", OBJPROP_YDISTANCE, gi_532 + 115);
            ObjectDelete("SIG_DETAIL_5");
            ObjectCreate("SIG_DETAIL_5", OBJ_LABEL, g_window_540, 0, 0);
            ObjectSetText("SIG_DETAIL_5", "Ilan-Combi V2.1    ", 14, "Times New Roman", g_color_572);// подпись
            ObjectSet("SIG_DETAIL_5", OBJPROP_CORNER, g_corner_528);
            ObjectSet("SIG_DETAIL_5", OBJPROP_XDISTANCE, gi_536 + 45);
            ObjectSet("SIG_DETAIL_5", OBJPROP_YDISTANCE, gi_532 + 130);
            ObjectDelete("SIG_DETAIL_6");
            ObjectCreate("SIG_DETAIL_6", OBJ_LABEL, g_window_540, 0, 0);
            ObjectSetText("SIG_DETAIL_6", " Online", 14, "Times New Roman", LimeGreen);
            ObjectSet("SIG_DETAIL_6", OBJPROP_CORNER, g_corner_528);
            ObjectSet("SIG_DETAIL_6", OBJPROP_XDISTANCE, gi_536 + 10);
            ObjectSet("SIG_DETAIL_6", OBJPROP_YDISTANCE, gi_532 + 130);
           
   }
}
//===================
//if (Lots > 10) Lots = 10; //ограничение лотов
//===================
{
    Comment(""            //коментарии
         + "\n" 
         + "Ilan-Combi V 2.1" 
         + "\n" 
         + "________________________________"  
         + "\n" 
         + "Брокер:         " + AccountCompany()
         + "\n"
         + "Время брокера:  " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS)
         + "\n"        
         + "________________________________"  
         + "\n" 
         + "Счёт:             " + AccountName() 
         + "\n" 
         + "Номер счёт        " + AccountNumber()
         + "\n" 
         + "Валюта счёта:   " + AccountCurrency()   
         + "\n"
         + "Плечо:        1:" + DoubleToStr(AccountLeverage(), 0)
         + "\n"          
         + "_______________________________"
         + "\n"
         + "Всего ордеров                  :" + OrdersTotal()
         + "\n"
         + "_______________________________"
         + "\n"           
         + "Баланс:                       " + DoubleToStr(AccountBalance(), 2)          
         + "\n" 
         + "Свободные средства:   " + DoubleToStr(AccountEquity(), 2)
         + "\n"      
         + "_______________________________");
  //=======================
  
  //=======================
   
   }
   
   //===================
   //=================== First 
   double PrevCl_H;
   double CurrCl_H;
   //=======================
     //Step_H = /*(1 + 0.1 * NumOfTrades_H);*/NormalizeDouble((iATR(NULL,0,PeriodATR,0)*ATR),4); //привязка пипстеп к АТР
     //Step_G = /*(1 + 0.1 * gi_368_G);*/NormalizeDouble((iATR(NULL,0,PeriodATR,0)*ATR),4);      //привязка пипстеп к АТР
     
   //=======================
   //double Step_HLot = NormalizeDouble((iATR(NULL,0,PeriodATR,0)*ATRLot),4); //привязка лота к АТР
   //double Step_HLot = NormalizeDouble((1+2*iDeMarker(NULL, 0, PeriodDeM, 1)),2);
    double Step_HLot = NormalizeDouble((iDeMarker(NULL, 0, PeriodDeM, 1)),2)/3;
   //=======================
     if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000)  // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
    {Lots_H = MinLots *100* Step_HLot;
     }  
     else
     {Lots_H = NormalizeDouble(0.00001 * MathCeil(AccountBalance ()) * Step_HLot,2);
     }
    }
     else Lots_H = MinLots *100* Step_HLot;
//=================== Second
   double l_ord_lots_8_G;
   double l_ord_lots_16_G;
   double l_iclose_24_G;
   double l_iclose_32_G;
//=================== First
   if (UseTrailingStop_H) TrailingAlls_H(TrailStart_H, TrailStop_H, AveragePrice_H);
   if (UseTimeOut_H) {
      if (TimeCurrent() >= expiration_H) {
         CloseThisSymbolAll_H();
         Print("Closed All due to TimeOut");
      }
   }
   if (timeprev_H == Time[0]) return (0);
   timeprev_H = Time[0];
   double CurrentPairProfit_H = CalculateProfit_H();
   if (UseEquityStop_H) {
      if (CurrentPairProfit_H < 0.0 && MathAbs(CurrentPairProfit_H) > TotalEquityRisk_H / 100.0 * AccountEquityHigh_H()) {
         CloseThisSymbolAll_H();
         Print("Closed All due to Stop Out");
         NewOrdersPlaced_H = FALSE;
      }
   }
   total_H = CountTrades_H();
   if (total_H == 0) flag_H = FALSE;
   for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
      OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
         if (OrderType() == OP_BUY) {
            LongTrade_H = TRUE;
            ShortTrade_H = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
         if (OrderType() == OP_SELL) {
            LongTrade_H = FALSE;
            ShortTrade_H = TRUE;
            break;
         }
      }
   }
   if (total_H > 0 && total_H <= MaxTrades_H) {
      RefreshRates();
      LastBuyPrice_H = FindLastBuyPrice_H();
      LastSellPrice_H = FindLastSellPrice_H();
      if (LongTrade_H && LastBuyPrice_H - Ask >= PipStep_H /** Step_H*/ * Point) TradeNow_H = TRUE;  //расчёт колен
      if (ShortTrade_H && Bid - LastSellPrice_H >= PipStep_H /** Step_H*/ * Point) TradeNow_H = TRUE; //расчёт колен
   }
   if (total_H < 1) {
      ShortTrade_H = FALSE;
      LongTrade_H = FALSE;
      TradeNow_H = TRUE;
      StartEquity_H = AccountEquity();
   }
   if (TradeNow_H) {
      LastBuyPrice_H = FindLastBuyPrice_H();
      LastSellPrice_H = FindLastSellPrice_H();
      if (ShortTrade_H) {
         NumOfTrades_H = total_H;
         iLots_H = NormalizeDouble(Lots_H * MathPow(LotExponent_H, NumOfTrades_H), lotdecimal_H);
         RefreshRates();
         ticket_H = OpenPendingOrder_H(1, iLots_H, Bid, slip_H, Ask, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, HotPink);
         if (ticket_H < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         LastSellPrice_H = FindLastSellPrice_H();
         TradeNow_H = FALSE;
         NewOrdersPlaced_H = TRUE;
      } else {
         if (LongTrade_H) {
            NumOfTrades_H = total_H;
            iLots_H = NormalizeDouble(Lots_H * MathPow(LotExponent_H, NumOfTrades_H), lotdecimal_H);
            ticket_H = OpenPendingOrder_H(0, iLots_H, Ask, slip_H, Bid, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, Lime);
            if (ticket_H < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            LastBuyPrice_H = FindLastBuyPrice_H();
            TradeNow_H = FALSE;
            NewOrdersPlaced_H = TRUE;
         }
      }
   }
   if (TradeNow_H && total_H < 1) {
      PrevCl_H = iHigh(Symbol(), 0, 1);
      CurrCl_H =  iLow(Symbol(), 0, 2);
      SellLimit_H = Bid;
      BuyLimit_H = Ask;
      if (!ShortTrade_H && !LongTrade_H) {
         NumOfTrades_H = total_H;
         iLots_H = NormalizeDouble(Lots_H * MathPow(LotExponent_H, NumOfTrades_H), lotdecimal_H);
         if (PrevCl_H > CurrCl_H) {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~~HHHHHHHHH~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               ticket_H = OpenPendingOrder_H(1, iLots_H, SellLimit_H, slip_H, SellLimit_H, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, HotPink);
               if (ticket_H < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastBuyPrice_H = FindLastBuyPrice_H();
               NewOrdersPlaced_H = TRUE;
            }
         } else {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~HHHHHHHHHH~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               ticket_H = OpenPendingOrder_H(0, iLots_H, BuyLimit_H, slip_H, BuyLimit_H, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, Lime);
               if (ticket_H < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastSellPrice_H = FindLastSellPrice_H();
               NewOrdersPlaced_H = TRUE;
            }
         }
//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
if (ticket_H > 0) expiration_H = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_H);
TradeNow_H = FALSE;
}
}
total_H = CountTrades_H();
AveragePrice_H = 0;
double Count_H = 0;
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
AveragePrice_H += OrderOpenPrice() * OrderLots();
Count_H += OrderLots();
}
}
}
if (total_H > 0) AveragePrice_H = NormalizeDouble(AveragePrice_H / Count_H, Digits);
if (NewOrdersPlaced_H) {
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY) {
PriceTarget_H = AveragePrice_H + TakeProfit_H * Point;
BuyTarget_H = PriceTarget_H;
Stopper_H = AveragePrice_H - Stoploss_H * Point;
flag_H = TRUE;
}
}
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_SELL) {
PriceTarget_H = AveragePrice_H - TakeProfit_H * Point;
SellTarget_H = PriceTarget_H;
Stopper_H = AveragePrice_H + Stoploss_H * Point;
flag_H = TRUE;
}
}
}
}
if (NewOrdersPlaced_H) {
if (flag_H == TRUE) {
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) OrderModify(OrderTicket(), AveragePrice_H, OrderStopLoss(), PriceTarget_H, 0, Yellow);
NewOrdersPlaced_H = FALSE;
}
}
}
//=========Second
   if (UseTrailing_G) TrailingAlls_G(TrailStart_G, TrailStop_G, g_price_292_G);
   
   if (gi_220_G) {
      if (TimeCurrent() >= gi_364_G) {
         CloseThisSymbolAll_G();
         Print("Closed All due to TimeOut");
      }
   }
   if (g_time_360_G == Time[0]) return (0);
   g_time_360_G = Time[0];
   double ld_0_G = CalculateProfit_G();
   if (SafeEquity_G) {
      if (ld_0_G < 0.0 && MathAbs(ld_0_G) > SafeEquityRisk_G / 100.0 * AccountEquityHigh_G()) {
         CloseThisSymbolAll_G();
         Print("Closed All due to Stop Out");
         gi_412_G = FALSE;
      }
   }
   gi_384_G = CountTrades_G();
   if (gi_384_G == 0) gi_348_G = FALSE;
   for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
      OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
         if (OrderType() == OP_BUY) {
            gi_400_G = TRUE;
            gi_404_G = FALSE;
            l_ord_lots_8_G = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
         if (OrderType() == OP_SELL) {
            gi_400_G = FALSE;
            gi_404_G = TRUE;
            l_ord_lots_16_G = OrderLots();
            break;
         }
      }
   }
   if (gi_384_G > 0 && gi_384_G <= MaxCountOrders_G) {
      RefreshRates();
      gd_316_G = FindLastBuyPrice_G();
      gd_324_G = FindLastSellPrice_G();
      if (gi_400_G && gd_316_G - Ask >= StepLots_G /** Step_G */* Point) gi_396_G = TRUE; //расчёт колен
      if (gi_404_G && Bid - gd_324_G >= StepLots_G /** Step_G */* Point) gi_396_G = TRUE;  //расчёт колен
   }
   if (gi_384_G < 1) {
      gi_404_G = FALSE;
      gi_400_G = FALSE;
      gi_396_G = TRUE;
      gd_268_G = AccountEquity();
   }
   if (gi_396_G) {
      gd_316_G = FindLastBuyPrice_G();
      gd_324_G = FindLastSellPrice_G();
      if (gi_404_G) {
         if (gi_252_G) {
            fOrderCloseMarket_G(0, 1);
            gd_372_G = NormalizeDouble(MultiLotsFactor_G * l_ord_lots_16_G, gd_240_G);
         } else gd_372_G = fGetLots_G(OP_SELL);
         if (gi_248_G) {
            gi_368_G = gi_384_G;
            if (gd_372_G > 0.0) {
               RefreshRates();
               gi_408_G = OpenPendingOrder_G(1, gd_372_G, Bid, slippage_G, Ask, 0, 0, gs_352_G + "-" + gi_368_G, MagicNumber_G, 0, HotPink);
               if (gi_408_G < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_324_G = FindLastSellPrice_G();
               gi_396_G = FALSE;
               gi_412_G = TRUE;
            }
         }
      } else {
         if (gi_400_G) {
            if (gi_252_G) {
               fOrderCloseMarket_G(1, 0);
               gd_372_G = NormalizeDouble(MultiLotsFactor_G * l_ord_lots_8_G, gd_240_G);
            } else gd_372_G = fGetLots_G(OP_BUY);
            if (gi_248_G) {
               gi_368_G = gi_384_G;
               if (gd_372_G > 0.0) {
                  gi_408_G = OpenPendingOrder_G(0, gd_372_G, Ask, slippage_G, Bid, 0, 0, gs_352_G + "-" + gi_368_G, MagicNumber_G, 0, Lime);
                  if (gi_408_G < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  gd_316_G = FindLastBuyPrice_G();
                  gi_396_G = FALSE;
                  gi_412_G = TRUE;
               }
            }
         }
      }
   }
   if (gi_396_G && gi_384_G < 1) {
      l_iclose_24_G = iClose(Symbol(), 0, 2);
      l_iclose_32_G = iClose(Symbol(), 0, 1);
      g_bid_300_G = Bid;
      g_ask_308_G = Ask;
      if (!gi_404_G && !gi_400_G) {
         gi_368_G = gi_384_G;
         if (l_iclose_24_G > l_iclose_32_G) {
            gd_372_G = fGetLots_G(OP_SELL);
            if (gd_372_G > 0.0) {
               gi_408_G = OpenPendingOrder_G(1, gd_372_G, g_bid_300_G, slippage_G, g_bid_300_G, 0, 0, gs_352_G + " " + MagicNumber_G + "-" + gi_368_G, MagicNumber_G, 0, HotPink);
               if (gi_408_G < 0) {
                  Print(gd_372_G, "Error: ", GetLastError());
                  return (0);
               }
               gd_316_G = FindLastBuyPrice_G();
               gi_412_G = TRUE;
            }
         } else {
            gd_372_G = fGetLots_G(OP_BUY);
            if (gd_372_G > 0.0) {
               gi_408_G = OpenPendingOrder_G(0, gd_372_G, g_ask_308_G, slippage_G, g_ask_308_G, 0, 0, gs_352_G + " " + MagicNumber_G + "-" + gi_368_G, MagicNumber_G, 0, Lime);
               if (gi_408_G < 0) {
                  Print(gd_372_G, "Error: ", GetLastError());
                  return (0);
               }
               gd_324_G = FindLastSellPrice_G();
               gi_412_G = TRUE;
            }
         }
      }
      if (gi_408_G > 0) gi_364_G = TimeCurrent() + 60.0 * (60.0 * gd_224_G);
      gi_396_G = FALSE;
   }
   gi_384_G = CountTrades_G();
   g_price_292_G = 0;
   double ld_40_G = 0;
   for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
      OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_292_G += OrderOpenPrice() * OrderLots();
            ld_40_G += OrderLots();
         }
      }
}
   if (gi_384_G > 0) g_price_292_G = NormalizeDouble(g_price_292_G / ld_40_G, Digits);
   if (gi_412_G) {
      for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
         OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_BUY) {
               g_price_260_G = g_price_292_G + TakeProfit_G * Point;
               gd_unused_276_G = g_price_260_G;
               gd_388_G = g_price_292_G - g_pips_232_G * Point;
               gi_348_G = TRUE;
}
}
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_SELL) {
               g_price_260_G = g_price_292_G - TakeProfit_G * Point;
               gd_unused_284_G = g_price_260_G;
               gd_388_G = g_price_292_G + g_pips_232_G * Point;
               gi_348_G = TRUE;
}
}
}
}
   if (gi_412_G) {
      if (gi_348_G == TRUE) {
         for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
            OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) OrderModify(OrderTicket(), g_price_292_G, OrderStopLoss(), g_price_260_G, 0, Yellow);
            gi_412_G = FALSE;
}
}
}
return (0);
}

//===================
//пользовательские ф-ции First
//===================

int CountTrades_H() {
int count_H = 0;
for (int trade_H = OrdersTotal() - 1; trade_H >= 0; trade_H--) {
OrderSelect(trade_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H)
if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_H++;
}
return (count_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

void CloseThisSymbolAll_H() {
for (int trade_H = OrdersTotal() - 1; trade_H >= 0; trade_H--) {
OrderSelect(trade_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() == Symbol()) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_H, Blue);
if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_H, Red);
}
Sleep(1000);
}
}
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

int OpenPendingOrder_H(int pType_H, double pLots_H, double pPrice_H, int pSlippage_H, double pr_H, int sl_H, int tp_H, string pComment_H, int pMagic_H, int pDatetime_H, color pColor_H) {
int ticket_H = 0;
int err_H = 0;
int c_H = 0;
int NumberOfTries_H = 100;
switch (pType_H) {
case 2:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_BUYLIMIT, pLots_H, pPrice_H, pSlippage_H, StopLong_H(pr_H, sl_H), TakeLong_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(1000);
}
break;
case 4:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_BUYSTOP, pLots_H, pPrice_H, pSlippage_H, StopLong_H(pr_H, sl_H), TakeLong_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H== 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 0:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
RefreshRates();
ticket_H = OrderSend(Symbol(), OP_BUY, pLots_H, Ask, pSlippage_H, StopLong_H(Bid, sl_H), TakeLong_H(Ask, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 3:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_SELLLIMIT, pLots_H, pPrice_H, pSlippage_H, StopShort_H(pr_H, sl_H), TakeShort_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 5:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_SELLSTOP, pLots_H, pPrice_H, pSlippage_H, StopShort_H(pr_H, sl_H), TakeShort_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 1:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_SELL, pLots_H, Bid, pSlippage_H, StopShort_H(Ask, sl_H), TakeShort_H(Bid, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
}
return (ticket_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
double StopLong_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H - stop_H * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double StopShort_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H + stop_H * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeLong_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H + stop_H * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeShort_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H - stop_H * Point);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double CalculateProfit_H() {
double Profit_H = 0;
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H)
if (OrderType() == OP_BUY || OrderType() == OP_SELL) Profit_H += OrderProfit();
}
return (Profit_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

void TrailingAlls_H(int pType_H, int stop_H, double AvgPrice_H) {
int profit_H;
double stoptrade_H;
double stopcal_H;
if (stop_H != 0) {
for (int trade_H = OrdersTotal() - 1; trade_H >= 0; trade_H--) {
if (OrderSelect(trade_H, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY) {
profit_H = NormalizeDouble((Bid - AvgPrice_H) / Point, 0);
if (profit_H < pType_H) continue;
stoptrade_H = OrderStopLoss();
stopcal_H = Bid - stop_H * Point;
if (stoptrade_H == 0.0 || (stoptrade_H != 0.0 && stopcal_H > stoptrade_H)) OrderModify(OrderTicket(), AvgPrice_H, stopcal_H, OrderTakeProfit(), 0, Aqua);
}
if (OrderType() == OP_SELL) {
profit_H = NormalizeDouble((AvgPrice_H - Ask) / Point, 0);
if (profit_H < pType_H) continue;
stoptrade_H = OrderStopLoss();
stopcal_H = Ask + stop_H * Point;
if (stoptrade_H == 0.0 || (stoptrade_H != 0.0 && stopcal_H < stoptrade_H)) OrderModify(OrderTicket(), AvgPrice_H, stopcal_H, OrderTakeProfit(), 0, Red);
}
}
Sleep(1000);
}
}
}
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double AccountEquityHigh_H() {
if (CountTrades_H() == 0) AccountEquityHighAmt_H = AccountEquity();
if (AccountEquityHighAmt_H < PrevEquity_H) AccountEquityHighAmt_H = PrevEquity_H;
else AccountEquityHighAmt_H = AccountEquity();
PrevEquity_H = AccountEquity();
return (AccountEquityHighAmt_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastBuyPrice_H() {
double oldorderopenprice_H;
int oldticketnumber_H;
double unused_H = 0;
int ticketnumber_H = 0;
for (int cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H && OrderType() == OP_BUY) {
oldticketnumber_H = OrderTicket();
if (oldticketnumber_H > ticketnumber_H) {
oldorderopenprice_H = OrderOpenPrice();
unused_H = oldorderopenprice_H;
ticketnumber_H = oldticketnumber_H;
}
}
}
return (oldorderopenprice_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastSellPrice_H() {
double oldorderopenprice_H;
int oldticketnumber_H;
double unused_H = 0;
int ticketnumber_H = 0;
for (int cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H && OrderType() == OP_SELL) {
oldticketnumber_H = OrderTicket();
if (oldticketnumber_H > ticketnumber_H) {
oldorderopenprice_H = OrderOpenPrice();
unused_H = oldorderopenprice_H;
ticketnumber_H = oldticketnumber_H;
}
}
}
return (oldorderopenprice_H);
}

//=====================================================
//==========Second
//=====================================================
double ND_G(double ad_0_G) {
return (NormalizeDouble(ad_0_G, Digits));
}

int fOrderCloseMarket_G(bool ai_0_G = TRUE, bool ai_4_G = TRUE) {
   int li_ret_8_G = 0;
   for (int l_pos_12_G = OrdersTotal() - 1; l_pos_12_G >= 0; l_pos_12_G--) {
      if (OrderSelect(l_pos_12_G, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_BUY && ai_0_G) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND_G(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8_G = -1;
                  }
               } else {
                  if (g_datetime_416_G != iTime(NULL, 0, 0)) {
                     g_datetime_416_G = iTime(NULL, 0, 0);
                     Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4_G) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND_G(Ask), 5, CLR_NONE)) {
                     Print("Error close SELL " + OrderTicket());
                     li_ret_8_G = -1;
                  }
               } else {
                  if (g_datetime_420_G != iTime(NULL, 0, 0)) {
                     g_datetime_420_G = iTime(NULL, 0, 0);
                     Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
         }
      }
   }
   return (li_ret_8_G);
}
   //=======================
   //=======================
   double fGetLots_G(int a_cmd_0_G) {
   double l_lots_4_G;
   double l_lots_MM_G;
   int l_datetime_16_G;
    //=======================
   //double Step_GLot = NormalizeDouble((iATR(NULL,0,PeriodATR,0)*ATRLot),4); //привязка лота к АТР
   //double Step_GLot = NormalizeDouble((1+2*iDeMarker(NULL, 0, PeriodDeM, 1)),2);
    Step_GLot =(NormalizeDouble((iDeMarker(NULL, 0, PeriodDeM, 1)),2))/3;
    //=======================
    // ММ - манименеджмент
    //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000)         // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
    {l_lots_MM_G = MinLots *100* Step_GLot;
     }  
     else
     {l_lots_MM_G = NormalizeDouble(0.00001 * MathCeil(AccountBalance ()) * Step_GLot,2);
     }
    }
     else l_lots_MM_G = MinLots *100* Step_GLot;
   //=======================
   
   switch (gi_256_G) {
   case 0:
      l_lots_4_G = l_lots_MM_G;
      break;
   case 1:
      l_lots_4_G = NormalizeDouble(l_lots_MM_G * MathPow(MultiLotsFactor_G, gi_368_G), gd_240_G);
      break;
   case 2:
      l_datetime_16_G = 0;
      l_lots_4_G = l_lots_MM_G;
      for (int l_pos_20_G = OrdersHistoryTotal() - 1; l_pos_20_G >= 0; l_pos_20_G--) {
         if (OrderSelect(l_pos_20_G, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
               if (l_datetime_16_G < OrderCloseTime()) {
                  l_datetime_16_G = OrderCloseTime();
                  if (OrderProfit() < 0.0) l_lots_4_G = NormalizeDouble(OrderLots() * MultiLotsFactor_G, gd_240_G);
                  else l_lots_4_G = l_lots_MM_G;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0_G, l_lots_4_G) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (l_lots_4_G);
}

int CountTrades_G() {
   int l_count_0_G = 0;
   for (int l_pos_4_G = OrdersTotal() - 1; l_pos_4_G >= 0; l_pos_4_G--) {
      OrderSelect(l_pos_4_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0_G++;
   }
   return (l_count_0_G);
}

void CloseThisSymbolAll_G() {
   for (int l_pos_0_G = OrdersTotal() - 1; l_pos_0_G >= 0; l_pos_0_G--) {
      OrderSelect(l_pos_0_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage_G, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage_G, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder_G(int ai_0_G, double a_lots_4_G, double a_price_12_G, int a_slippage_20_G, double ad_24_G, int ai_32_G, int ai_36_G, string a_comment_40_G, int a_magic_48_G, int a_datetime_52_G, color a_color_56_G) {
   int l_ticket_60_G = 0;
   int l_error_64_G = 0;
   int l_count_68_G = 0;
   int li_72_G = 100;
   switch (ai_0_G) {
   case 2:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopLong_G(ad_24_G, ai_32_G), TakeLong_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopLong_G(ad_24_G, ai_32_G), TakeLong_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         RefreshRates();
         l_ticket_60_G = OrderSend(Symbol(), OP_BUY, a_lots_4_G, Ask, a_slippage_20_G, StopLong_G(Bid, ai_32_G), TakeLong_G(Ask, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopShort_G(ad_24_G, ai_32_G), TakeShort_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopShort_G(ad_24_G, ai_32_G), TakeShort_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_SELL, a_lots_4_G, Bid, a_slippage_20_G, StopShort_G(Ask, ai_32_G), TakeShort_G(Bid, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60_G);
}

double StopLong_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G - ai_8_G * Point);
}

double StopShort_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G + ai_8_G * Point);
}

double TakeLong_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G + ai_8_G * Point);
}

double TakeShort_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G - ai_8_G * Point);
}

double CalculateProfit_G() {
   double ld_ret_0_G = 0;
   for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
      OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0_G += OrderProfit();
   }
   return (ld_ret_0_G);
}

void TrailingAlls_G(int ai_0_G, int ai_4_G, double a_price_8_G) {
   int li_16_G;
   double l_ord_stoploss_20_G;
   double l_price_28_G;
   if (ai_4_G != 0) {
      for (int l_pos_36_G = OrdersTotal() - 1; l_pos_36_G >= 0; l_pos_36_G--) {
         if (OrderSelect(l_pos_36_G, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_G) {
               if (OrderType() == OP_BUY) {
                  li_16_G = NormalizeDouble((Bid - a_price_8_G) / Point, 0);
                  if (li_16_G < ai_0_G) continue;
                  l_ord_stoploss_20_G = OrderStopLoss();
                  l_price_28_G = Bid - ai_4_G * Point;
                  if (l_ord_stoploss_20_G == 0.0 || (l_ord_stoploss_20_G != 0.0 && l_price_28_G > l_ord_stoploss_20_G)) OrderModify(OrderTicket(), a_price_8_G, l_price_28_G, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16_G = NormalizeDouble((a_price_8_G - Ask) / Point, 0);
                  if (li_16_G < ai_0_G) continue;
                  l_ord_stoploss_20_G = OrderStopLoss();
                  l_price_28_G = Ask + ai_4_G * Point;
                  if (l_ord_stoploss_20_G == 0.0 || (l_ord_stoploss_20_G != 0.0 && l_price_28_G < l_ord_stoploss_20_G)) OrderModify(OrderTicket(), a_price_8_G, l_price_28_G, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh_G() {
   if (CountTrades_G() == 0) gd_424_G = AccountEquity();
   if (gd_424_G < gd_432_G) gd_424_G = gd_432_G;
   else gd_424_G = AccountEquity();
   gd_432_G = AccountEquity();
   return (gd_424_G);
}

double FindLastBuyPrice_G() {
   double l_ord_open_price_8_G;
   int l_ticket_24_G;
   double ld_unused_0_G = 0;
   int l_ticket_20_G = 0;
   for (int l_pos_16_G = OrdersTotal() - 1; l_pos_16_G >= 0; l_pos_16_G--) {
      OrderSelect(l_pos_16_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G && OrderType() == OP_BUY) {
         l_ticket_24_G = OrderTicket();
         if (l_ticket_24_G > l_ticket_20_G) {
            l_ord_open_price_8_G = OrderOpenPrice();
            ld_unused_0_G = l_ord_open_price_8_G;
            l_ticket_20_G = l_ticket_24_G;
         }
      }
   }
   return (l_ord_open_price_8_G);
}

double FindLastSellPrice_G() {
   double l_ord_open_price_8_G;
   int l_ticket_24_G;
   double ld_unused_0_G = 0;
   int l_ticket_20_G = 0;
   for (int l_pos_16_G = OrdersTotal() - 1; l_pos_16_G >= 0; l_pos_16_G--) {
      OrderSelect(l_pos_16_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G && OrderType() == OP_SELL) {
         l_ticket_24_G = OrderTicket();
         if (l_ticket_24_G > l_ticket_20_G) {
            l_ord_open_price_8_G = OrderOpenPrice();
            ld_unused_0_G = l_ord_open_price_8_G;
            l_ticket_20_G = l_ticket_24_G;
         }
      }
   }
   return (l_ord_open_price_8_G);
}

