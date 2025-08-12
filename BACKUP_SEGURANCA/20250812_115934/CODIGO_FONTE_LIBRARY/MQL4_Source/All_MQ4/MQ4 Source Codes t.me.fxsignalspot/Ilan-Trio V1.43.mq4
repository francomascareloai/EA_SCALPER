//+------------------------------------------------------------------+
//|                                              Ilan-Trio V1.43.mq4 |
//|                                                            Night |
//|                                          http://alfonius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Night"
#property link      "http://alfonius@mail.ru"


//===================================================================
//-------------------Hilo_RSI--------------------------------------//
//===================================================================
extern string t1 = "Общие настройки";
extern double Lots = 0.01;              // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
extern double LotExponent = 1.59;       // умножение лотов в серии по експоненте для вывода в безубыток. первый лот 0.1, серия: 0.15, 0.26, 0.43 ...
int    lotdecimal = 2;                  // 2 - микролоты 0.01, 1 - мини лоты 0.1, 0 - нормальные лоты 1.0
extern double MaxLots = 5;              // ограничение макс лота
extern bool   MM =true;                 // ММ - манименеджмент
extern double TakeProfit = 10.0;        // тейк профит
extern bool UseEquityStop = FALSE;      // использовать риск в процентах
extern double TotalEquityRisk = 20.0;   // риск в процентах от депозита
//===================================================================
extern string t2 = "Настройки эксперта Ilan_Hilo";
double Lots_Hilo;                       // задание всех лотов через 1 переменную
double LotExponent_Hilo;       
int lotdecimal_Hilo;            
double TakeProfit_Hilo;                 // тейк профит
extern int MaxTrades_Hilo = 10;         // максимально количество одновременно открытых ордеров
bool UseEquityStop_Hilo;                // использовать риск в процентах
double TotalEquityRisk_Hilo;            // риск в процентах от депозита
//===================================================================
extern double PipStep_Hilo = 30.0;      // шаг колена- был 30
double slip_Hilo = 3.0;                 // проскальзывание
extern int MagicNumber_Hilo = 11111;           // магик
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool UseTimeOut_Hilo = FALSE;           // использовать анулирование ордеров по времени
double MaxTradeOpenHours_Hilo = 48.0;   // через колько часов анулировать висячие ордера
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern bool UseTrailingStop_Hilo = FALSE;      // использовать трейлинг стоп
double Stoploss_Hilo = 500.0;           // Эти параметра не работают!!!
extern double TrailStart_Hilo = 10.0;
extern double TrailStop_Hilo = 5.0;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double PriceTarget_Hilo, StartEquity_Hilo, BuyTarget_Hilo, SellTarget_Hilo ;
double AveragePrice_Hilo, SellLimit_Hilo, BuyLimit_Hilo ;
double LastBuyPrice_Hilo, LastSellPrice_Hilo, Spread_Hilo;
bool flag_Hilo;
string EAName_Hilo = "Ilan_HiLo_RSI";
int timeprev_Hilo = 0, expiration_Hilo;
int NumOfTrades_Hilo = 0;
double iLots_Hilo;
int cnt_Hilo = 0, total_Hilo;
double Stopper_Hilo = 0.0;
bool TradeNow_Hilo = FALSE, LongTrade_Hilo = FALSE, ShortTrade_Hilo = FALSE;
int ticket_Hilo;
bool NewOrdersPlaced_Hilo = FALSE;
double AccountEquityHighAmt_Hilo, PrevEquity_Hilo;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//            ILAN 1.5                       //
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern string t3 = "Настройки эксперта Ilan 1.5";
double LotExponent_15;
double Lots_15;
int lotdecimal_15;
double TakeProfit_15;
bool UseEquityStop_15;                   // использовать риск в процентах
double TotalEquityRisk_15;               // риск в процентах от депозита
extern int MaxTrades_15 = 10;
int OpenNewTF_15 = 60;
int gi_unused_88_15;
//===============================================
extern bool UseTrailingStop_15 = FALSE;   // использовать трейлинг стоп
double Stoploss_15 = 500.0;              // Эти параметры  не работают!!!
extern double TrailStart_15 = 10.0;
extern double TrailStop_15 = 5.0;
//==============================================
bool UseTimeOut_15 = FALSE;              // использовать анулирование ордеров по времени
double MaxTradeOpenHours_15 = 48.0;      // через колько часов анулировать висячие ордера
//===============================================
double slip_15 = 3.0;
extern double PipStep_15 = 30.0; //30
extern int g_magic_176_15 = 12324;
//===============================================
double g_price_180_15;
double gd_188_15;
double gd_unused_196_15;
double gd_unused_204_15;
double g_price_212_15;
double g_bid_220_15;
double g_ask_228_15;
double gd_236_15;
double gd_244_15;
double gd_260_15;
bool gi_268_15;
string gs_ilan_272_15 = "Ilan 1.5";
int gi_280_15 = 0;
int gi_284_15;
int gi_288_15 = 0;
double gd_292_15;
int g_pos_300_15 = 0;
int gi_304_15;
double gd_308_15 = 0.0;
bool gi_316_15 = FALSE;
bool gi_320_15 = FALSE;
bool gi_324_15 = FALSE;
int gi_328_15;
bool gi_332_15 = FALSE;
double gd_336_15;
double gd_344_15;
datetime time_15=1;
//========================================================================
//                 ILAN 1.6                                             //
//========================================================================
extern string t4 = "Настройки эксперта Ilan 1.6";
double LotExponent_16;
double Lots_16;
int lotdecimal_16;
double TakeProfit_16;
extern int MaxTrades_16 = 10;
bool UseEquityStop_16;      // использовать риск в процентах
double TotalEquityRisk_16;  // риск в процентах от депозита
int OpenNewTF_16 = 1;
//=========================================================
extern bool UseTrailingStop_16 = FALSE;
double Stoploss_16 = 500.0;               // Эти три параметра не работают!!!
extern double TrailStart_16 = 10.0;
extern double TrailStop_16 = 5.0;
//=========================================================
bool UseTimeOut_16 = FALSE;
double MaxTradeOpenHours_16 = 48.0;
//=========================================================
double slip_16 = 3.0;
extern double PipStep_16 = 30.0;//30
extern int g_magic_176_16 = 16794;
//=========================================================
double g_price_180_16;
double gd_188_16;
double gd_unused_196_16;
double gd_unused_204_16;
double g_price_212_16;
double g_bid_220_16;
double g_ask_228_16;
double gd_236_16;
double gd_244_16;
double gd_260_16;
bool gi_268_16;
string gs_ilan_272_16 = "Ilan 1.6";
int gi_280_16 = 0;
int gi_284_16;
int gi_288_16 = 0;
double gd_292_16;
int g_pos_300_16 = 0;
int gi_304_16;
double gd_308_16 = 0.0;
bool gi_316_16 = FALSE;
bool gi_320_16 = FALSE;
bool gi_324_16 = FALSE;
int gi_328_16;
bool gi_332_16 = FALSE;
double gd_336_16;
double gd_344_16;
datetime time_16=1;

//==============================
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
//=======================================================================
string    txt,txt1;

//=======================================================================
int init() 

{
//=======================
   Spread_Hilo = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gd_260_15 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gd_260_16 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
//------------------------   
   ObjectCreate("Lable1",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 2);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 21);
   txt1="Ilan-Trio 1.43";
   ObjectSetText("Lable1",txt1,16,"Times New Roman",Aqua);
//-------------------------
ObjectCreate("Lable",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable", OBJPROP_CORNER, 2);
   ObjectSet("Lable", OBJPROP_XDISTANCE, 3);
   ObjectSet("Lable", OBJPROP_YDISTANCE, 1);
   txt="Night "+CharToStr(174)+" alfonius@yandex.ru";
   ObjectSetText("Lable",txt,16,"Times New Roman",DeepSkyBlue);
//-------------------------   
return (0); 
}
int deinit() {
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
  }
   return (0);
}
//========================================================================
//========================================================================
int start()
 {int    counted_bars=IndicatorCounted();

 if (Lots > MaxLots) Lots = MaxLots; //ограничение лотов
    {
    Comment("" 
         + "\n" 
         + "Ilan-Trio V 1.43" 
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
         + "_______________________________"
         + "\n"
         + "Всего ордеров                  :" + OrdersTotal()
         + "\n"
         + "_______________________________"
         + "\n"           
         + "Баланс:                    " + DoubleToStr(AccountBalance(), 2)          
         + "\n" 
         + "Свободные средства:   " + DoubleToStr(AccountEquity(), 2)
         + "\n"      
         + "_______________________________");
   }
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
            ObjectSetText("SIG_DETAIL_5", "Ilan-Trio V1.43    ", 14, "Times New Roman", g_color_572);// подпись
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
//=======================================================================//
//                 Программный код Ilan_Hilo_RSI                         //
//=======================================================================//
  {double PrevCl_Hilo; //глоб переменная Hilo
   double CurrCl_Hilo; //глоб переменная Hilo
   double l_iclose_8;  //глоб переменная Ilan_1.5
   double l_iclose_16; //глоб переменная Ilan_1.6
   //=======================
   double LotExponent_Hilo = LotExponent;
   int lotdecimal_Hilo = lotdecimal;
   double TakeProfit_Hilo = TakeProfit;
   bool UseEquityStop_Hilo = UseEquityStop;        
   double TotalEquityRisk_Hilo = TotalEquityRisk;   // риск в процентах от депозита

   //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000)         // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
    { double Lots_Hilo = Lots;
     }  
     else
     {Lots_Hilo = 0.00001 * MathCeil(AccountBalance ());
     }
    }
     else Lots_Hilo = Lots;
   //=======================
  
   if (UseTrailingStop_Hilo) TrailingAlls_Hilo(TrailStart_Hilo, TrailStop_Hilo, AveragePrice_Hilo);
   if (UseTimeOut_Hilo) {
      if (TimeCurrent() >= expiration_Hilo) {
         CloseThisSymbolAll_Hilo();
         Print("Closed All due_Hilo to TimeOut");
      }
   }
   if (timeprev_Hilo == Time[0]) return (0);
   timeprev_Hilo = Time[0];
   double CurrentPairProfit_Hilo = CalculateProfit_Hilo();
   if (UseEquityStop_Hilo) {
      if (CurrentPairProfit_Hilo < 0.0 && MathAbs(CurrentPairProfit_Hilo) > TotalEquityRisk_Hilo / 100.0 * AccountEquityHigh_Hilo()) {
         CloseThisSymbolAll_Hilo();
         Print("Closed All due_Hilo to Stop Out");
         NewOrdersPlaced_Hilo = FALSE;
      }
   }
   total_Hilo = CountTrades_Hilo();
   if (total_Hilo == 0) flag_Hilo = FALSE;
   for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
      OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
         if (OrderType() == OP_BUY) {
            LongTrade_Hilo = TRUE;
            ShortTrade_Hilo = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
         if (OrderType() == OP_SELL) {
            LongTrade_Hilo = FALSE;
            ShortTrade_Hilo = TRUE;
            break;
         }
      }
   }
   if (total_Hilo > 0 && total_Hilo <= MaxTrades_Hilo) {
      RefreshRates();
      LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
      LastSellPrice_Hilo = FindLastSellPrice_Hilo();
      if (LongTrade_Hilo && LastBuyPrice_Hilo - Ask >= PipStep_Hilo * Point) TradeNow_Hilo = TRUE;
      if (ShortTrade_Hilo && Bid - LastSellPrice_Hilo >= PipStep_Hilo * Point) TradeNow_Hilo = TRUE;
   }
   if (total_Hilo < 1) {
      ShortTrade_Hilo = FALSE;
      LongTrade_Hilo = FALSE;
      TradeNow_Hilo = TRUE;
      StartEquity_Hilo = AccountEquity();
   }
   if (TradeNow_Hilo) {
      LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
      LastSellPrice_Hilo = FindLastSellPrice_Hilo();
      if (ShortTrade_Hilo) {
         NumOfTrades_Hilo = total_Hilo;
         iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
         RefreshRates();
         ticket_Hilo = OpenPendingOrder_Hilo(1, iLots_Hilo, Bid, slip_Hilo, Ask, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, HotPink);
         if (ticket_Hilo < 0) 
         {
            Print("Error: ", GetLastError());
            return (0);
         }
         LastSellPrice_Hilo = FindLastSellPrice_Hilo();
         TradeNow_Hilo = FALSE;
         NewOrdersPlaced_Hilo = TRUE;
      } else {
         if (LongTrade_Hilo) {
            NumOfTrades_Hilo = total_Hilo;
            iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
            ticket_Hilo = OpenPendingOrder_Hilo(0, iLots_Hilo, Ask, slip_Hilo, Bid, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, Lime);
            if (ticket_Hilo < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
            TradeNow_Hilo = FALSE;
            NewOrdersPlaced_Hilo = TRUE;
         }
      }
   }
   if (TradeNow_Hilo && total_Hilo < 1) {
      PrevCl_Hilo = iHigh(Symbol(), 0, 1);
      CurrCl_Hilo =  iLow(Symbol(), 0, 2);
      SellLimit_Hilo = Bid;
      BuyLimit_Hilo = Ask;
      if (!ShortTrade_Hilo && !LongTrade_Hilo) {
         NumOfTrades_Hilo = total_Hilo;
         iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
         if (PrevCl_Hilo > CurrCl_Hilo) {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~~HHHHHHHHH~~~~~~~~~~~~~~~//       
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               ticket_Hilo = OpenPendingOrder_Hilo(1, iLots_Hilo, SellLimit_Hilo, slip_Hilo, SellLimit_Hilo, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, HotPink);
               if (ticket_Hilo < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
               NewOrdersPlaced_Hilo = TRUE;
            }
         } else {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~HHHHHHHHHH~~~~~~~~~~~~~~~~~
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               ticket_Hilo = OpenPendingOrder_Hilo(0, iLots_Hilo, BuyLimit_Hilo, slip_Hilo, BuyLimit_Hilo, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, Lime);
               if (ticket_Hilo < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastSellPrice_Hilo = FindLastSellPrice_Hilo();
               NewOrdersPlaced_Hilo = TRUE;
            }
         }
//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
if (ticket_Hilo > 0) expiration_Hilo = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_Hilo);
TradeNow_Hilo = FALSE;
}
}
total_Hilo = CountTrades_Hilo();
AveragePrice_Hilo = 0;
double Count_Hilo = 0;
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
AveragePrice_Hilo += OrderOpenPrice() * OrderLots();
Count_Hilo += OrderLots();
}
}
}
if (total_Hilo > 0) AveragePrice_Hilo = NormalizeDouble(AveragePrice_Hilo / Count_Hilo, Digits);
if (NewOrdersPlaced_Hilo) {
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY) {
PriceTarget_Hilo = AveragePrice_Hilo + TakeProfit_Hilo * Point;
BuyTarget_Hilo = PriceTarget_Hilo;
Stopper_Hilo = AveragePrice_Hilo - Stoploss_Hilo * Point;
flag_Hilo = TRUE;
}
}
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_SELL) {
PriceTarget_Hilo = AveragePrice_Hilo - TakeProfit_Hilo * Point;
SellTarget_Hilo = PriceTarget_Hilo;
Stopper_Hilo = AveragePrice_Hilo + Stoploss_Hilo * Point;
flag_Hilo = TRUE;
}
}
}
}
if (NewOrdersPlaced_Hilo) {
if (flag_Hilo == TRUE) {
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) OrderModify(OrderTicket(), AveragePrice_Hilo, OrderStopLoss(), PriceTarget_Hilo, 0, Yellow);
NewOrdersPlaced_Hilo = FALSE;
}
}
}

//========================================================================//
//                       ПРОГРАМНЫЙ КОД Ilan 1.5                          //
//========================================================================//
   //double l_iclose_8;
   //double l_iclose_16;
   //=======================
   double LotExponent_15 = LotExponent;
   int lotdecimal_15 = lotdecimal;
   double TakeProfit_15 = TakeProfit;
   bool UseEquityStop_15 = UseEquityStop;        
   double TotalEquityRisk_15 = TotalEquityRisk;            // риск в процентах от депозита
   //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000) // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
     { double Lots_15 = Lots;
     }  
     else
     {Lots_15 = 0.00001 * MathCeil(AccountBalance ());
     }
    }
     else Lots_15 = Lots;
   //=======================
   if (UseTrailingStop_15) TrailingAlls_15(TrailStart_15, TrailStop_15, g_price_212_15);
   if (UseTimeOut_15) {
      if (TimeCurrent() >= gi_284_15) {
         CloseThisSymbolAll_15();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_280_15 != Time[0])
   {
   gi_280_15 = Time[0];
   double ld_0_15 = CalculateProfit_15();
   if (UseEquityStop_15) {
      if (ld_0_15 < 0.0 && MathAbs(ld_0_15) > TotalEquityRisk_15 / 100.0 * AccountEquityHigh_15()) {
         CloseThisSymbolAll_15();
         Print("Closed All due to Stop Out");
         gi_332_15 = FALSE;
      }
   }
   gi_304_15 = CountTrades_15();
   if (gi_304_15 == 0) gi_268_15 = FALSE;
   for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
      OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
         if (OrderType() == OP_BUY) {
            gi_320_15 = TRUE;
            gi_324_15 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
         if (OrderType() == OP_SELL) {
            gi_320_15 = FALSE;
            gi_324_15 = TRUE;
            break;
         }
      }
   }
   if (gi_304_15 > 0 && gi_304_15 <= MaxTrades_15) {
      RefreshRates();
      gd_236_15 = FindLastBuyPrice_15();
      gd_244_15 = FindLastSellPrice_15();
      if (gi_320_15 && gd_236_15 - Ask >= PipStep_15 * Point) gi_316_15 = TRUE;
      if (gi_324_15 && Bid - gd_244_15 >= PipStep_15 * Point) gi_316_15 = TRUE;
   }
   if (gi_304_15 < 1) {
      gi_324_15 = FALSE;
      gi_320_15 = FALSE;
      gi_316_15 = TRUE;
      gd_188_15 = AccountEquity();
   }
   if (gi_316_15) {
      gd_236_15 = FindLastBuyPrice_15();
      gd_244_15 = FindLastSellPrice_15();
      if (gi_324_15) {
         gi_288_15 = gi_304_15;
         gd_292_15 = NormalizeDouble(Lots_15 * MathPow(LotExponent_15, gi_288_15), lotdecimal_15);
         RefreshRates();
         gi_328_15 = OpenPendingOrder_15(1, gd_292_15, Bid, slip_15, Ask, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, HotPink);
         if (gi_328_15 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_244_15 = FindLastSellPrice_15();
         gi_316_15 = FALSE;
         gi_332_15 = TRUE;
      } else {
         if (gi_320_15) {
            gi_288_15 = gi_304_15;
            gd_292_15 = NormalizeDouble(Lots_15 * MathPow(LotExponent_15, gi_288_15), lotdecimal_15);
            gi_328_15 = OpenPendingOrder_15(0, gd_292_15, Ask, slip_15, Bid, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, Lime);
            if (gi_328_15 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236_15 = FindLastBuyPrice_15();
            gi_316_15 = FALSE;
            gi_332_15 = TRUE;
         }
      }
   }
   }
   if(time_15!=iTime(NULL,OpenNewTF_15,0))
   {
   int totals_15=OrdersTotal();
   int orders_15=0;
   for(int total_15=totals_15; total_15>=1; total_15--)
   {
   OrderSelect(total_15-1,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
     orders_15++;
   }
   }
          
   if (totals_15==0 || orders_15 < 1) {
      l_iclose_8 = iClose(Symbol(), 0, 2);
      l_iclose_16 = iClose(Symbol(), 0, 1);
      g_bid_220_15 = Bid;
      g_ask_228_15 = Ask;
//      if (!gi_324 && !gi_320) {
         gi_288_15 = gi_304_15;
         gd_292_15 = /*NormalizeDouble(*/Lots_15/* * MathPow(LotExponent, gi_288), lotdecimal)*/;
         if (l_iclose_8 > l_iclose_16) {
            gi_328_15 = OpenPendingOrder_15(1, gd_292_15, g_bid_220_15, slip_15, g_bid_220_15, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, HotPink);
            if (gi_328_15 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236_15 = FindLastBuyPrice_15();
            gi_332_15 = TRUE;
         } else {
            gi_328_15 = OpenPendingOrder_15(0, gd_292_15, g_ask_228_15, slip_15, g_ask_228_15, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, Lime);
            if (gi_328_15 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_244_15 = FindLastSellPrice_15();
            gi_332_15 = TRUE;
         }
         if (gi_328_15 > 0) gi_284_15 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_15);
         gi_316_15 = FALSE;
//      }
   }
   time_15=iTime(NULL,OpenNewTF_15,0);
   }
   gi_304_15 = CountTrades_15();
   g_price_212_15 = 0;
   double ld_24_15 = 0;
   for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
      OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_212_15 += OrderOpenPrice() * OrderLots();
            ld_24_15 += OrderLots();
         }
      }
   }
   if (gi_304_15 > 0) g_price_212_15 = NormalizeDouble(g_price_212_15 / ld_24_15, Digits);
   if (gi_332_15) {
      for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
         OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_BUY) {
               g_price_180_15 = g_price_212_15 + TakeProfit_15 * Point;
               gd_unused_196_15 = g_price_180_15;
               gd_308_15 = g_price_212_15 - Stoploss_15 * Point;
               gi_268_15 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_SELL) {
               g_price_180_15 = g_price_212_15 - TakeProfit_15 * Point;
               gd_unused_204_15 = g_price_180_15;
               gd_308_15 = g_price_212_15 + Stoploss_15 * Point;
               gi_268_15 = TRUE;
            }
         }
      }
   }
   if (gi_332_15) {
      if (gi_268_15 == TRUE) {
         for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
            OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) OrderModify(OrderTicket(), g_price_212_15, OrderStopLoss(), g_price_180_15, 0, Yellow);
            gi_332_15 = FALSE;
         }
      }
   }
//========================================================================//
//                       ПРОГРАМНЫЙ КОД Ilan 1.6                          //
//========================================================================//
//   double l_iclose_8;
//   double l_iclose_16;
   //=======================
   double LotExponent_16 = LotExponent;
   int lotdecimal_16 = lotdecimal;
   double TakeProfit_16 = TakeProfit;
   bool UseEquityStop_16 = UseEquityStop;
   double TotalEquityRisk_16 = TotalEquityRisk;            // риск в процентах от депозита
   //=======================
   // манименеджмент      //
   //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000) // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
     { double Lots_16 = Lots;
     }  
     else
     {Lots_16 = 0.00001 * MathCeil(AccountBalance ());
     }
    }
     else Lots_Hilo = Lots;

   //=======================
   if (UseTrailingStop_16) TrailingAlls_16(TrailStart_16, TrailStop_16, g_price_212_16);
   if (UseTimeOut_16) {
      if (TimeCurrent() >= gi_284_16) {
         CloseThisSymbolAll_16();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_280_16 != Time[0])
   {
   gi_280_16 = Time[0];
   double ld_0_16 = CalculateProfit_16();
   if (UseEquityStop_16) {
      if (ld_0_16 < 0.0 && MathAbs(ld_0_16) > TotalEquityRisk_16 / 100.0 * AccountEquityHigh_16()) {
         CloseThisSymbolAll_16();
         Print("Closed All due to Stop Out");
         gi_332_16 = FALSE;
      }
   }
   gi_304_16 = CountTrades_16();
   if (gi_304_16 == 0) gi_268_16 = FALSE;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_BUY) {
            gi_320_16 = TRUE;
            gi_324_16 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_SELL) {
            gi_320_16 = FALSE;
            gi_324_16 = TRUE;
            break;
         }
      }
   }
   if (gi_304_16 > 0 && gi_304_16 <= MaxTrades_16) {
      RefreshRates();
      gd_236_16 = FindLastBuyPrice_16();
      gd_244_16 = FindLastSellPrice_16();
      if (gi_320_16 && gd_236_16 - Ask >= PipStep_16 * Point) gi_316_16 = TRUE;
      if (gi_324_16 && Bid - gd_244_16 >= PipStep_16 * Point) gi_316_16 = TRUE;
   }
   if (gi_304_16 < 1) {
      gi_324_16 = FALSE;
      gi_320_16 = FALSE;
//      gi_316_16 = TRUE;
      gd_188_16 = AccountEquity();
   }
   if (gi_316_16) {
      gd_236_16 = FindLastBuyPrice_16();
      gd_244_16 = FindLastSellPrice_16();
      if (gi_324_16) {
         gi_288_16 = gi_304_16;
         gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
         RefreshRates();
         gi_328_16 = OpenPendingOrder_16(1, gd_292_16, Bid, slip_16, Ask, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, HotPink);
         if (gi_328_16 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_244_16 = FindLastSellPrice_16();
         gi_316_16 = FALSE;
         gi_332_16 = TRUE;
      } else {
         if (gi_320_16) {
            gi_288_16 = gi_304_16;
            gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
            gi_328_16 = OpenPendingOrder_16(0, gd_292_16, Ask, slip_16, Bid, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, Lime);
            if (gi_328_16 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236_16 = FindLastBuyPrice_16();
            gi_316_16 = FALSE;
            gi_332_16 = TRUE;
         }
      }
   }
   }
   if(time_16!=iTime(NULL,OpenNewTF_16,0))
   {
   int totals_16=OrdersTotal();
   int orders_16=0;
   for(int total_16=totals_16; total_16>=1; total_16--)
   {
   OrderSelect(total_16-1,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
     orders_16++;
   }
   }
   if (totals_16==0 || orders_16 < 1) {
      l_iclose_8/*_16*/ = iClose(Symbol(), 0, 2);
      l_iclose_16/*_16*/ = iClose(Symbol(), 0, 1);
      g_bid_220_16 = Bid;
      g_ask_228_16 = Ask;
//      if (!gi_324_16 && !gi_320_16) {
         gi_288_16 = gi_304_16;
         gd_292_16 =/* NormalizeDouble(*/Lots_16/* * MathPow(LotExponent_16, gi_288_16), lotdecimal_16)*/;
         if (l_iclose_8/*_16*/ > l_iclose_16/*_16*/) {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               gi_328_16 = OpenPendingOrder_16(1, gd_292_16, g_bid_220_16, slip_16, g_bid_220_16, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, HotPink);
               if (gi_328_16 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_236_16 = FindLastBuyPrice_16();
               gi_332_16 = TRUE;
            }
         } else {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               gi_328_16 = OpenPendingOrder_16(0, gd_292_16, g_ask_228_16, slip_16, g_ask_228_16, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, Lime);
               if (gi_328_16 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_244_16 = FindLastSellPrice_16();
               gi_332_16 = TRUE;
            }
         }
         if (gi_328_16 > 0) gi_284_16 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_16);
         gi_316_16 = FALSE;
//      }
   }
   time_16=iTime(NULL,OpenNewTF_16,0);
   }
   gi_304_16 = CountTrades_16();
   g_price_212_16 = 0;
   double ld_24_16 = 0;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_212_16 += OrderOpenPrice() * OrderLots();
            ld_24_16 += OrderLots();
         }
      }
   }
   if (gi_304_16 > 0) g_price_212_16 = NormalizeDouble(g_price_212_16 / ld_24_16, Digits);
   if (gi_332_16) {
      for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
         OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) {
               g_price_180_16 = g_price_212_16 + TakeProfit_16 * Point;
               gd_unused_196_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 - Stoploss_16 * Point;
               gi_268_16 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_SELL) {
               g_price_180_16 = g_price_212_16 - TakeProfit_16 * Point;
               gd_unused_204_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 + Stoploss_16 * Point;
               gi_268_16 = TRUE;
            }
         }
      }
   }
   if (gi_332_16) {
      if (gi_268_16 == TRUE) {
         for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
            OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) OrderModify(OrderTicket(), g_price_212_16, OrderStopLoss(), g_price_180_16, 0, Yellow);
            gi_332_16 = FALSE;
         }
      }
   }
}
}
//=============================
//=============================
return (0);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

int CountTrades_Hilo() {
int count_Hilo = 0;
for (int trade_Hilo = OrdersTotal() - 1; trade_Hilo >= 0; trade_Hilo--) {
OrderSelect(trade_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_Hilo++;
}
return (count_Hilo);
}

//ппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

void CloseThisSymbolAll_Hilo() {
for (int trade_Hilo = OrdersTotal() - 1; trade_Hilo >= 0; trade_Hilo--) {
OrderSelect(trade_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() == Symbol()) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_Hilo, Blue);
if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_Hilo, Red);
}
Sleep(1000);
}
}
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
int OpenPendingOrder_Hilo(int pType_Hilo, double pLots_Hilo, double pPrice_Hilo, int pSlippage_Hilo, double pr_Hilo, int sl_Hilo, int tp_Hilo, string pComment_Hilo, int pMagic_Hilo, int pDatetime_Hilo, color pColor_Hilo) {
int ticket_Hilo = 0;
int err_Hilo = 0;
int c_Hilo = 0;
int NumberOfTries_Hilo = 100;
switch (pType_Hilo) {
case 2:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_BUYLIMIT, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopLong_Hilo(pr_Hilo, sl_Hilo), TakeLong_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(1000);
}
break;
case 4:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_BUYSTOP, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopLong_Hilo(pr_Hilo, sl_Hilo), TakeLong_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 0:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
RefreshRates();
ticket_Hilo = OrderSend(Symbol(), OP_BUY, pLots_Hilo, Ask, pSlippage_Hilo, StopLong_Hilo(Bid, sl_Hilo), TakeLong_Hilo(Ask, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 3:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_SELLLIMIT, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopShort_Hilo(pr_Hilo, sl_Hilo), TakeShort_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 5:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_SELLSTOP, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopShort_Hilo(pr_Hilo, sl_Hilo), TakeShort_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 1:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_SELL, pLots_Hilo, Bid, pSlippage_Hilo, StopShort_Hilo(Ask, sl_Hilo), TakeShort_Hilo(Bid, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
}
return (ticket_Hilo);
}

//пппппппппппппппппппппппппппппппппппппппппппп
double StopLong_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo - stop_Hilo * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double StopShort_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo + stop_Hilo * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeLong_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo + stop_Hilo * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeShort_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo - stop_Hilo * Point);
}

//пппппппппппппппппппппппппппппппппппппппппппп
double CalculateProfit_Hilo() {
double Profit_Hilo = 0;
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
if (OrderType() == OP_BUY || OrderType() == OP_SELL) Profit_Hilo += OrderProfit();
}
return (Profit_Hilo);
}

//ппппппппппппппппппппппппппппппппппппппппппппп

void TrailingAlls_Hilo(int pType_Hilo, int stop_Hilo, double AvgPrice_Hilo) {
int profit_Hilo;
double stoptrade_Hilo;
double stopcal_Hilo;
if (stop_Hilo != 0) {
for (int trade_Hilo = OrdersTotal() - 1; trade_Hilo >= 0; trade_Hilo--) {
if (OrderSelect(trade_Hilo, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY) {
profit_Hilo = NormalizeDouble((Bid - AvgPrice_Hilo) / Point, 0);
if (profit_Hilo < pType_Hilo) continue;
stoptrade_Hilo = OrderStopLoss();
stopcal_Hilo = Bid - stop_Hilo * Point;
if (stoptrade_Hilo == 0.0 || (stoptrade_Hilo != 0.0 && stopcal_Hilo > stoptrade_Hilo)) OrderModify(OrderTicket(), AvgPrice_Hilo, stopcal_Hilo, OrderTakeProfit(), 0, Aqua);
}
if (OrderType() == OP_SELL) {
profit_Hilo = NormalizeDouble((AvgPrice_Hilo - Ask) / Point, 0);
if (profit_Hilo < pType_Hilo) continue;
stoptrade_Hilo = OrderStopLoss();
stopcal_Hilo = Ask + stop_Hilo * Point;
if (stoptrade_Hilo == 0.0 || (stoptrade_Hilo != 0.0 && stopcal_Hilo < stoptrade_Hilo)) OrderModify(OrderTicket(), AvgPrice_Hilo, stopcal_Hilo, OrderTakeProfit(), 0, Red);
}
}
Sleep(1000);
}
}
}
}

//ппппппппппппппппппппппппппппппппппппппппппппппппп
double AccountEquityHigh_Hilo() {
if (CountTrades_Hilo() == 0) AccountEquityHighAmt_Hilo = AccountEquity();
if (AccountEquityHighAmt_Hilo < PrevEquity_Hilo) AccountEquityHighAmt_Hilo = PrevEquity_Hilo;
else AccountEquityHighAmt_Hilo = AccountEquity();
PrevEquity_Hilo = AccountEquity();
return (AccountEquityHighAmt_Hilo);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastBuyPrice_Hilo() {
double oldorderopenprice_Hilo;
int oldticketnumber_Hilo;
double unused_Hilo = 0;
int ticketnumber_Hilo = 0;
for (int cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_BUY) {
oldticketnumber_Hilo = OrderTicket();
if (oldticketnumber_Hilo > ticketnumber_Hilo) {
oldorderopenprice_Hilo = OrderOpenPrice();
unused_Hilo = oldorderopenprice_Hilo;
ticketnumber_Hilo = oldticketnumber_Hilo;
}
}
}
return (oldorderopenprice_Hilo);
}

//ппппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastSellPrice_Hilo() {
double oldorderopenprice_Hilo;
int oldticketnumber_Hilo;
double unused_Hilo = 0;
int ticketnumber_Hilo = 0;
for (int cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_SELL) {
oldticketnumber_Hilo = OrderTicket();
if (oldticketnumber_Hilo > ticketnumber_Hilo) {
oldorderopenprice_Hilo = OrderOpenPrice();
unused_Hilo = oldorderopenprice_Hilo;
ticketnumber_Hilo = oldticketnumber_Hilo;
}
}
}
return (oldorderopenprice_Hilo);
}

//==========================================================================
//                   пользовательские ф-ции 1.5_1.6                       //
//==========================================================================

//========================================================================//
//=========================CountTrades_15=================================//
//========================================================================//
int CountTrades_15() {
   int l_count_0_15 = 0;
   for (int l_pos_4_15 = OrdersTotal() - 1; l_pos_4_15 >= 0; l_pos_4_15--) {
      OrderSelect(l_pos_4_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0_15++;
   }
   return (l_count_0_15);
}

void CloseThisSymbolAll_15() {
   for (int l_pos_0_15 = OrdersTotal() - 1; l_pos_0_15 >= 0; l_pos_0_15--) {
      OrderSelect(l_pos_0_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_15, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_15, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder_15(int ai_0_15, double a_lots_4_15, double a_price_12_15, int a_slippage_20_15, double ad_24_15, int ai_32_15, int ai_36_15, string a_comment_40_15, int a_magic_48_15, int a_datetime_52_15, color a_color_56_15) {
   int l_ticket_60_15 = 0;
   int l_error_64_15 = 0;
   int l_count_68_15 = 0;
   int li_72_15 = 100;
   switch (ai_0_15) {
   case 2:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopLong_15(ad_24_15, ai_32_15), TakeLong_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopLong_15(ad_24_15, ai_32_15), TakeLong_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         RefreshRates();
         l_ticket_60_15 = OrderSend(Symbol(), OP_BUY, a_lots_4_15, Ask, a_slippage_20_15, StopLong_15(Bid, ai_32_15), TakeLong_15(Ask, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopShort_15(ad_24_15, ai_32_15), TakeShort_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopShort_15(ad_24_15, ai_32_15), TakeShort_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_SELL, a_lots_4_15, Bid, a_slippage_20_15, StopShort_15(Ask, ai_32_15), TakeShort_15(Bid, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60_15);
}

double StopLong_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 - ai_8_15 * Point);
}

double StopShort_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 + ai_8_15 * Point);
}

double TakeLong_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 + ai_8_15 * Point);
}

double TakeShort_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 - ai_8_15 * Point);
}

double CalculateProfit_15() {
   double ld_ret_0_15 = 0;
   for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
      OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0_15 += OrderProfit();
   }
   return (ld_ret_0_15);
}

void TrailingAlls_15(int ai_0_15, int ai_4_15, double a_price_8_15) {
   int l_ticket_16_15;
   double l_ord_stoploss_20_15;
   double l_price_28_15;
   if (ai_4_15 != 0) {
      for (int l_pos_36_15 = OrdersTotal() - 1; l_pos_36_15 >= 0; l_pos_36_15--) {
         if (OrderSelect(l_pos_36_15, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176_15) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16_15 = NormalizeDouble((Bid - a_price_8_15) / Point, 0);
                  if (l_ticket_16_15 < ai_0_15) continue;
                  l_ord_stoploss_20_15 = OrderStopLoss();
                  l_price_28_15 = Bid - ai_4_15 * Point;
                  if (l_ord_stoploss_20_15 == 0.0 || (l_ord_stoploss_20_15 != 0.0 && l_price_28_15 > l_ord_stoploss_20_15)) OrderModify(OrderTicket(), a_price_8_15, l_price_28_15, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16_15 = NormalizeDouble((a_price_8_15 - Ask) / Point, 0);
                  if (l_ticket_16_15 < ai_0_15) continue;
                  l_ord_stoploss_20_15 = OrderStopLoss();
                  l_price_28_15 = Ask + ai_4_15 * Point;
                  if (l_ord_stoploss_20_15 == 0.0 || (l_ord_stoploss_20_15 != 0.0 && l_price_28_15 < l_ord_stoploss_20_15)) OrderModify(OrderTicket(), a_price_8_15, l_price_28_15, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh_15() {
   if (CountTrades_15() == 0) gd_336_15 = AccountEquity();
   if (gd_336_15 < gd_344_15) gd_336_15 = gd_344_15;
   else gd_336_15 = AccountEquity();
   gd_344_15 = AccountEquity();
   return (gd_336_15);
}

double FindLastBuyPrice_15() {
   double l_ord_open_price_8_15;
   int l_ticket_24_15;
   double ld_unused_0_15 = 0;
   int l_ticket_20_15 = 0;
   for (int l_pos_16_15 = OrdersTotal() - 1; l_pos_16_15 >= 0; l_pos_16_15--) {
      OrderSelect(l_pos_16_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15 && OrderType() == OP_BUY) {
         l_ticket_24_15 = OrderTicket();
         if (l_ticket_24_15 > l_ticket_20_15) {
            l_ord_open_price_8_15 = OrderOpenPrice();
            ld_unused_0_15 = l_ord_open_price_8_15;
            l_ticket_20_15 = l_ticket_24_15;
         }
      }
   }
   return (l_ord_open_price_8_15);
}

double FindLastSellPrice_15() {
   double l_ord_open_price_8_15;
   int l_ticket_24_15;
   double ld_unused_0_15 = 0;
   int l_ticket_20_15 = 0;
   for (int l_pos_16_15 = OrdersTotal() - 1; l_pos_16_15 >= 0; l_pos_16_15--) {
      OrderSelect(l_pos_16_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15 && OrderType() == OP_SELL) {
         l_ticket_24_15 = OrderTicket();
         if (l_ticket_24_15 > l_ticket_20_15) {
            l_ord_open_price_8_15 = OrderOpenPrice();
            ld_unused_0_15 = l_ord_open_price_8_15;
            l_ticket_20_15 = l_ticket_24_15;
         }
      }
   }
   return (l_ord_open_price_8_15);
}
//============================================================//
//======================CountTrades_16========================//
//============================================================//
int CountTrades_16() {
   int l_count_0_16 = 0;
   for (int l_pos_4_16 = OrdersTotal() - 1; l_pos_4_16 >= 0; l_pos_4_16--) {
      OrderSelect(l_pos_4_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0_16++;
   }
   return (l_count_0_16);
}

void CloseThisSymbolAll_16() {
   for (int l_pos_0_16 = OrdersTotal() - 1; l_pos_0_16 >= 0; l_pos_0_16--) {
      OrderSelect(l_pos_0_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_16, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_16, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder_16(int ai_0_16, double a_lots_4_16, double a_price_12_16, int a_slippage_20_16, double ad_24_16, int ai_32_16, int ai_36_16, string a_comment_40_16, int a_magic_48_16, int a_datetime_52_16, color a_color_56_16) {
   int l_ticket_60_16 = 0;
   int l_error_64_16 = 0;
   int l_count_68_16 = 0;
   int li_72_16 = 100;
   switch (ai_0_16) {
   case 2:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopLong_16(ad_24_16, ai_32_16), TakeLong_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopLong_16(ad_24_16, ai_32_16), TakeLong_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         RefreshRates();
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUY, a_lots_4_16, Ask, a_slippage_20_16, StopLong_16(Bid, ai_32_16), TakeLong_16(Ask, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopShort_16(ad_24_16, ai_32_16), TakeShort_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopShort_16(ad_24_16, ai_32_16), TakeShort_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELL, a_lots_4_16, Bid, a_slippage_20_16, StopShort_16(Ask, ai_32_16), TakeShort_16(Bid, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60_16);
}

double StopLong_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 - ai_8_16 * Point);
}

double StopShort_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 + ai_8_16 * Point);
}

double TakeLong_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 + ai_8_16 * Point);
}

double TakeShort_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 - ai_8_16 * Point);
}

double CalculateProfit_16() {
   double ld_ret_0_16 = 0;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0_16 += OrderProfit();
   }
   return (ld_ret_0_16);
}

void TrailingAlls_16(int ai_0_16, int ai_4_16, double a_price_8_16) {
   int l_ticket_16_16;
   double l_ord_stoploss_20_16;
   double l_price_28_16;
   if (ai_4_16 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176_16) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16_16 = NormalizeDouble((Bid - a_price_8_16) / Point, 0);
                  if (l_ticket_16_16 < ai_0_16) continue;
                  l_ord_stoploss_20_16 = OrderStopLoss();
                  l_price_28_16 = Bid - ai_4_16 * Point;
                  if (l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 > l_ord_stoploss_20_16)) OrderModify(OrderTicket(), a_price_8_16, l_price_28_16, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16_16 = NormalizeDouble((a_price_8_16 - Ask) / Point, 0);
                  if (l_ticket_16_16 < ai_0_16) continue;
                  l_ord_stoploss_20_16 = OrderStopLoss();
                  l_price_28_16 = Ask + ai_4_16 * Point;
                  if (l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 < l_ord_stoploss_20_16)) OrderModify(OrderTicket(), a_price_8_16, l_price_28_16, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh_16() {
   if (CountTrades_16() == 0) gd_336_16 = AccountEquity();
   if (gd_336_16 < gd_344_16) gd_336_16 = gd_344_16;
   else gd_336_16 = AccountEquity();
   gd_344_16 = AccountEquity();
   return (gd_336_16);
}

double FindLastBuyPrice_16() {
   double l_ord_open_price_8_16;
   int l_ticket_24_16;
   double ld_unused_0_16 = 0;
   int l_ticket_20_16 = 0;
   for (int l_pos_16_16 = OrdersTotal() - 1; l_pos_16_16 >= 0; l_pos_16_16--) {
      OrderSelect(l_pos_16_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_BUY) {
         l_ticket_24_16 = OrderTicket();
         if (l_ticket_24_16 > l_ticket_20_16) {
            l_ord_open_price_8_16 = OrderOpenPrice();
            ld_unused_0_16 = l_ord_open_price_8_16;
            l_ticket_20_16 = l_ticket_24_16;
         }
      }
   }
   return (l_ord_open_price_8_16);
}

double FindLastSellPrice_16() {
   double l_ord_open_price_8_16;
   int l_ticket_24_16;
   double ld_unused_0_16 = 0;
   int l_ticket_20_16 = 0;
   for (int l_pos_16_16 = OrdersTotal() - 1; l_pos_16_16 >= 0; l_pos_16_16--) {
      OrderSelect(l_pos_16_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_SELL) {
         l_ticket_24_16 = OrderTicket();
         if (l_ticket_24_16 > l_ticket_20_16) {
            l_ord_open_price_8_16 = OrderOpenPrice();
            ld_unused_0_16 = l_ord_open_price_8_16;
            l_ticket_20_16 = l_ticket_24_16;
         }
      }
   }
   return (l_ord_open_price_8_16);
}