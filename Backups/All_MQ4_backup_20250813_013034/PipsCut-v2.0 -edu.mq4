/*
   2013-04-21 by Capella at http://worldwide-invest.org/
	- Restriction to Demo account overruled
*/
#property copyright "@2012"
#property link      "http://www.pipscut.com/"

extern string t1 = "SETTINGS";
extern double Lots = 0.01;
extern double LotExponent = 1.1;
extern int lotdecimal = 2;
extern double PipStep = 30.0;
extern double MaxLots = 100.0;
extern bool MM = FALSE;
extern double TakeProfit = 50.0;
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
extern bool UseTrailingStop = TRUE;
extern double TrailStart = 13.0;
extern double TrailStop = 3.0;
extern double slip = 5.0;
extern string t3 = "SETTINGS for Group (A)";
extern int MaxTrades_Hilo = 10;
bool gi_224 = FALSE;
double gd_228 = 48.0;
double gd_240 = 40.0;
double gd_272;
extern int MagicNumber_Hilo = 10278;
double gd_284;
double gd_292;
double gd_300;
double gd_308;
double gd_316;
double gd_324;
double gd_332;
double gd_340;
double gd_348;
double gd_356;
double gd_364;
double gd_372;
bool gi_380;
string gs_384 = "PipsCut-v2.0";
int gi_392 = 0;
int gi_396;
int gi_400 = 0;
double gd_404;
int gi_412 = 0;
int gi_416;
double gd_420 = 0.0;
bool gi_428 = FALSE;
bool gi_432 = FALSE;
bool gi_436 = FALSE;
int gi_440;
bool gi_444 = FALSE;
double gd_448;
double gd_456;
extern string t4 = "SETTINGS for Group (B)";
extern int MaxTrades_15 = 10;
int gi_516 = PERIOD_H1;
double gd_528 = 40.0;
bool gi_552 = FALSE;
double gd_556 = 48.0;
double gd_572;
extern int g_magic_176_15 = 22324;
double gd_584;
double gd_592;
double gd_600;
double gd_608;
double gd_616;
double gd_624;
double gd_632;
double gd_640;
double gd_648;
double gd_656;
bool gi_664;
string gs_668 = "PipsCut-v2.0";
int gi_676 = 0;
int gi_680;
int gi_684 = 0;
double gd_688;
int gi_696 = 0;
int gi_700;
double gd_704 = 0.0;
bool gi_712 = FALSE;
bool gi_716 = FALSE;
bool gi_720 = FALSE;
int gi_724;
bool gi_728 = FALSE;
double gd_732;
double gd_740;
int gi_748 = 1;
extern string t5 = "SETTINGS for Group (C)";
extern int MaxTrades_16 = 10;
int gi_804 = PERIOD_M1;
double gd_812 = 40.0;
bool gi_836 = FALSE;
double gd_840 = 48.0;
double gd_856;
extern int g_magic_176_16 = 23794;
double gd_868;
double gd_876;
double gd_884;
double gd_892;
double gd_900;
double gd_908;
double gd_916;
double gd_924;
double gd_932;
double gd_940;
bool gi_948;
string gs_952 = "PipsCut-v2.0";
int gi_960 = 0;
int gi_964;
int gi_968 = 0;
double gd_972;
int gi_980 = 0;
int gi_984;
double gd_988 = 0.0;
bool gi_996 = FALSE;
bool gi_1000 = FALSE;
bool gi_1004 = FALSE;
int gi_1008;
bool gi_1012 = FALSE;
double gd_1016;
double gd_1024;
int gi_1032 = 1;
int gi_1044 = PERIOD_M1;
int gi_1048 = PERIOD_M5;
int gi_1052 = PERIOD_M15;
int gi_1056 = PERIOD_M30;
int gi_1060 = PERIOD_H1;
int gi_1064 = PERIOD_H4;
int gi_1068 = PERIOD_D1;
bool gi_1072 = TRUE;
int gi_1076 = 0;
int gi_1080 = 10;
int gi_1084 = 0;
bool gi_1088 = TRUE;
bool gi_1092 = TRUE;
bool gi_1096 = FALSE;
int gi_1100 = Gray;
int gi_1104 = Gray;
int gi_1108 = Gray;
int gi_1112 = DarkOrange;
int gi_1116 = 36095;
int gi_1120 = Lime;
int gi_1124 = OrangeRed;
int gi_1128 = 65280;
int gi_1132 = 17919;
int gi_1136 = Lime;
int gi_1140 = Red;
int gi_1144 = Orange;
int gi_1148 = 8;
int gi_1152 = 17;
int gi_1156 = 9;
int gi_1160 = PRICE_CLOSE;
int gi_1164 = Lime;
int gi_1168 = Tomato;
int gi_1172 = Green;
int gi_1176 = Red;
string gs_1180 = "<<<< STR Indicator Settings >>>>>>>>>>>>>";
string gs_1188 = "<<<< RSI Settings >>>>>>>>>>>>>";
int gi_1196 = 9;
int gi_1200 = PRICE_CLOSE;
string gs_1204 = "<<<< CCI Settings >>>>>>>>>>>>>>";
int gi_1212 = 13;
int gi_1216 = PRICE_CLOSE;
string gs_1220 = "<<<< STOCH Settings >>>>>>>>>>>";
int gi_1228 = 5;
int gi_1232 = 3;
int gi_1236 = 3;
int gi_1240 = MODE_EMA;
string gs_1244 = "<<<< STR Colors >>>>>>>>>>>>>>>>";
int gi_1252 = Lime;
int gi_1256 = Red;
int gi_1260 = Orange;
string gs_1264 = "<<<< MA Settings >>>>>>>>>>>>>>";
int gi_1272 = 5;
int gi_1276 = 9;
int gi_1280 = MODE_EMA;
int gi_1284 = PRICE_CLOSE;
string gs_1288 = "<<<< MA Colors >>>>>>>>>>>>>>";
int gi_1296 = Lime;
int gi_1300 = Red;
string gs_1312;
string gs_1484;
string gs_1492;
string gs_1500 = "";
string gs_1508 = "";
int gi_1516 = ForestGreen;

int init() {
   gd_372 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gd_656 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gd_940 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   ObjectCreate("Lable1", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 2);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 21);
   gs_1492 = "PipsCut v2.0";
   ObjectSetText("Lable1", gs_1492, 16, "Times New Roman", Aqua);
   ObjectCreate("Lable", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("Lable", OBJPROP_CORNER, 2);
   ObjectSet("Lable", OBJPROP_XDISTANCE, 3);
   ObjectSet("Lable", OBJPROP_YDISTANCE, 1);
   gs_1484 = " HotLine 01190-251329";
   ObjectSetText("Lable", gs_1484, 16, "Times New Roman", DeepSkyBlue);
   return (0);
}
	 	     		  		 		  			 			 		 	    	    		  			 	 			  					 			 	 	  				 	  	 					 			  			  		 			   		       		 				 	  		 	 	  	 		  				  
int deinit() {
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
   ObjectDelete("Lable");
   ObjectDelete("Lable1");
   ObjectDelete("Lable2");
   ObjectDelete("Lable3");
   return (0);
}
		  		  	 	    					   		 		 		  					  	 	   	 		 	 	 		  		 		  							 					 	  	 							    	 		        		   	 		 				  	 	 		  	  					  	  
int start() {
   int li_8;
   int li_12;
   int li_16;
   int li_20;
   int li_24;
   int li_28;
   int li_32;
   color li_36;
   color li_40;
   color li_44;
   color li_48;
   color li_52;
   color li_56;
   color li_60;
   string ls_64;
   color li_72;
   color li_76;
   color li_80;
   color li_84;
   color li_88;
   color li_92;
   color li_96;
   color li_100;
   string ls_104;
   color li_112;
   int li_116;
   double ld_1132;
   double ld_1140;
   double ld_1148;
   double ld_1156;
   double ld_1232;
   double ld_1324;
   double ld_1332;
   int li_1340;
   int li_1344;
   double ld_1428;
   double ld_1436;
   int li_1444;
   int li_1448;
/*
   bool li_0 = IsDemo();
   if (!li_0) {
      Alert("You can not use the program with a real account!");
      return (0);
   }
*/
   int li_4 = IndicatorCounted();
   if (Lots > MaxLots) Lots = MaxLots;
   Comment("www.PipsCut.com" 
      + "\n" 
      + "PipsCut-v2.0" 
      + "\n" 
      + "________________________________" 
      + "\n" 
      + "Your Broker:         " + AccountCompany() 
      + "\n" 
      + "Your Brokers Time:  " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) 
      + "\n" 
      + "________________________________" 
      + "\n" 
      + "Full Name:             " + AccountName() 
      + "\n" 
      + "Your Account Number        " + AccountNumber() 
      + "\n" 
      + "Currency Type :   " + AccountCurrency() 
      + "\n" 
      + "_______________________________" 
      + "\n" 
      + "Group (A) Open Orders :   " + f0_4() 
      + "\n" 
      + "Group (B) Open Orders :   " + f0_5() 
      + "\n" 
      + "Group (c) Open Orders :   " + f0_12() 
      + "\n" 
      + "Total Orders:               " + OrdersTotal() 
      + "\n" 
      + "_______________________________" 
      + "\n" 
      + "Current Balance :     " + DoubleToStr(AccountBalance(), 2) 
      + "\n" 
      + "Current Equity :      " + DoubleToStr(AccountEquity(), 2) 
      + "\n" 
   + "Stay With Us !!!");
   gd_316 = NormalizeDouble(AccountBalance(), 2);
   gd_324 = NormalizeDouble(AccountEquity(), 2);
   if (gd_324 >= 5.0 * (gd_316 / 6.0)) gi_1516 = DodgerBlue;
   if (gd_324 >= 4.0 * (gd_316 / 6.0) && gd_324 < 5.0 * (gd_316 / 6.0)) gi_1516 = DeepSkyBlue;
   if (gd_324 >= 3.0 * (gd_316 / 6.0) && gd_324 < 4.0 * (gd_316 / 6.0)) gi_1516 = Gold;
   if (gd_324 >= 2.0 * (gd_316 / 6.0) && gd_324 < 3.0 * (gd_316 / 6.0)) gi_1516 = OrangeRed;
   if (gd_324 >= gd_316 / 6.0 && gd_324 < 2.0 * (gd_316 / 6.0)) gi_1516 = Crimson;
   if (gd_324 < gd_316 / 5.0) gi_1516 = Red;
   ObjectDelete("Lable2");
   ObjectCreate("Lable2", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("Lable2", OBJPROP_CORNER, 3);
   ObjectSet("Lable2", OBJPROP_XDISTANCE, 153);
   ObjectSet("Lable2", OBJPROP_YDISTANCE, 31);
   gs_1500 = DoubleToStr(AccountBalance(), 2);
   ObjectSetText("Lable2", "Current Balance:  " + gs_1500 + "", 16, "Times New Roman", DodgerBlue);
   ObjectDelete("Lable3");
   ObjectCreate("Lable3", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("Lable3", OBJPROP_CORNER, 3);
   ObjectSet("Lable3", OBJPROP_XDISTANCE, 153);
   ObjectSet("Lable3", OBJPROP_YDISTANCE, 11);
   gs_1508 = DoubleToStr(AccountEquity(), 2);
   ObjectSetText("Lable3", "Current Equity:    " + gs_1508 + "", 16, "Times New Roman", gi_1516);
   int li_276 = IndicatorCounted();
   string ls_280 = "";
   string ls_288 = "";
   string ls_296 = "";
   string ls_304 = "";
   string ls_312 = "";
   string ls_320 = "";
   string ls_328 = "";
   if (gi_1044 == PERIOD_M1) ls_280 = "M1";
   if (gi_1044 == PERIOD_M5) ls_280 = "M5";
   if (gi_1044 == PERIOD_M15) ls_280 = "M15";
   if (gi_1044 == PERIOD_M30) ls_280 = "M30";
   if (gi_1044 == PERIOD_H1) ls_280 = "H1";
   if (gi_1044 == PERIOD_H4) ls_280 = "H4";
   if (gi_1044 == PERIOD_D1) ls_280 = "D1";
   if (gi_1044 == PERIOD_W1) ls_280 = "W1";
   if (gi_1044 == PERIOD_MN1) ls_280 = "MN";
   if (gi_1048 == PERIOD_M1) ls_288 = "M1";
   if (gi_1048 == PERIOD_M5) ls_288 = "M5";
   if (gi_1048 == PERIOD_M15) ls_288 = "M15";
   if (gi_1048 == PERIOD_M30) ls_288 = "M30";
   if (gi_1048 == PERIOD_H1) ls_288 = "H1";
   if (gi_1048 == PERIOD_H4) ls_288 = "H4";
   if (gi_1048 == PERIOD_D1) ls_288 = "D1";
   if (gi_1048 == PERIOD_W1) ls_288 = "W1";
   if (gi_1048 == PERIOD_MN1) ls_288 = "MN";
   if (gi_1052 == PERIOD_M1) ls_296 = "M1";
   if (gi_1052 == PERIOD_M5) ls_296 = "M5";
   if (gi_1052 == PERIOD_M15) ls_296 = "M15";
   if (gi_1052 == PERIOD_M30) ls_296 = "M30";
   if (gi_1052 == PERIOD_H1) ls_296 = "H1";
   if (gi_1052 == PERIOD_H4) ls_296 = "H4";
   if (gi_1052 == PERIOD_D1) ls_296 = "D1";
   if (gi_1052 == PERIOD_W1) ls_296 = "W1";
   if (gi_1052 == PERIOD_MN1) ls_296 = "MN";
   if (gi_1056 == PERIOD_M1) ls_304 = "M1";
   if (gi_1056 == PERIOD_M5) ls_304 = "M5";
   if (gi_1056 == PERIOD_M15) ls_304 = "M15";
   if (gi_1056 == PERIOD_M30) ls_304 = "M30";
   if (gi_1056 == PERIOD_H1) ls_304 = "H1";
   if (gi_1056 == PERIOD_H4) ls_304 = "H4";
   if (gi_1056 == PERIOD_D1) ls_304 = "D1";
   if (gi_1056 == PERIOD_W1) ls_304 = "W1";
   if (gi_1056 == PERIOD_MN1) ls_304 = "MN";
   if (gi_1060 == PERIOD_M1) ls_312 = "M1";
   if (gi_1060 == PERIOD_M5) ls_312 = "M5";
   if (gi_1060 == PERIOD_M15) ls_312 = "M15";
   if (gi_1060 == PERIOD_M30) ls_312 = "M30";
   if (gi_1060 == PERIOD_H1) ls_312 = "H1";
   if (gi_1060 == PERIOD_H4) ls_312 = "H4";
   if (gi_1060 == PERIOD_D1) ls_312 = "D1";
   if (gi_1060 == PERIOD_W1) ls_312 = "W1";
   if (gi_1060 == PERIOD_MN1) ls_312 = "MN";
   if (gi_1064 == PERIOD_M1) ls_320 = "M1";
   if (gi_1064 == PERIOD_M5) ls_320 = "M5";
   if (gi_1064 == PERIOD_M15) ls_320 = "M15";
   if (gi_1064 == PERIOD_M30) ls_320 = "M30";
   if (gi_1064 == PERIOD_H1) ls_320 = "H1";
   if (gi_1064 == PERIOD_H4) ls_320 = "H4";
   if (gi_1064 == PERIOD_D1) ls_320 = "D1";
   if (gi_1064 == PERIOD_W1) ls_320 = "W1";
   if (gi_1064 == PERIOD_MN1) ls_320 = "MN";
   if (gi_1068 == PERIOD_M1) ls_328 = "M1";
   if (gi_1068 == PERIOD_M5) ls_328 = "M5";
   if (gi_1068 == PERIOD_M15) ls_328 = "M15";
   if (gi_1068 == PERIOD_M30) ls_328 = "M30";
   if (gi_1068 == PERIOD_H1) ls_328 = "H1";
   if (gi_1068 == PERIOD_H4) ls_328 = "H4";
   if (gi_1068 == PERIOD_D1) ls_328 = "D1";
   if (gi_1068 == PERIOD_W1) ls_328 = "W1";
   if (gi_1068 == PERIOD_MN1) ls_328 = "MN";
   if (gi_1044 == PERIOD_M15) li_8 = -2;
   if (gi_1044 == PERIOD_M30) li_8 = -2;
   if (gi_1048 == PERIOD_M15) li_12 = -2;
   if (gi_1048 == PERIOD_M30) li_12 = -2;
   if (gi_1052 == PERIOD_M15) li_16 = -2;
   if (gi_1052 == PERIOD_M30) li_16 = -2;
   if (gi_1056 == PERIOD_M15) li_20 = -2;
   if (gi_1056 == PERIOD_M30) li_20 = -2;
   if (gi_1060 == PERIOD_M15) li_24 = -2;
   if (gi_1060 == PERIOD_M30) li_24 = -2;
   if (gi_1064 == PERIOD_M15) li_28 = -2;
   if (gi_1064 == PERIOD_M30) li_28 = -2;
   if (gi_1068 == PERIOD_M15) li_32 = -2;
   if (gi_1064 == PERIOD_M30) li_32 = -2;
   if (gi_1076 < 0) return (0);
   ObjectDelete("SIG_BARS_TF1");
   ObjectCreate("SIG_BARS_TF1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_BARS_TF1", ls_280, 7, "Arial Bold", gi_1100);
   ObjectSet("SIG_BARS_TF1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_BARS_TF1", OBJPROP_XDISTANCE, gi_1080 + 134 + li_8);
   ObjectSet("SIG_BARS_TF1", OBJPROP_YDISTANCE, gi_1076 + 25);
   ObjectDelete("SIG_BARS_TF2");
   ObjectCreate("SIG_BARS_TF2", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_BARS_TF2", ls_288, 7, "Arial Bold", gi_1100);
   ObjectSet("SIG_BARS_TF2", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_BARS_TF2", OBJPROP_XDISTANCE, gi_1080 + 114 + li_12);
   ObjectSet("SIG_BARS_TF2", OBJPROP_YDISTANCE, gi_1076 + 25);
   ObjectDelete("SIG_BARS_TF3");
   ObjectCreate("SIG_BARS_TF3", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_BARS_TF3", ls_296, 7, "Arial Bold", gi_1100);
   ObjectSet("SIG_BARS_TF3", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_BARS_TF3", OBJPROP_XDISTANCE, gi_1080 + 94 + li_16);
   ObjectSet("SIG_BARS_TF3", OBJPROP_YDISTANCE, gi_1076 + 25);
   ObjectDelete("SIG_BARS_TF4");
   ObjectCreate("SIG_BARS_TF4", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_BARS_TF4", ls_304, 7, "Arial Bold", gi_1100);
   ObjectSet("SIG_BARS_TF4", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_BARS_TF4", OBJPROP_XDISTANCE, gi_1080 + 74 + li_20);
   ObjectSet("SIG_BARS_TF4", OBJPROP_YDISTANCE, gi_1076 + 25);
   ObjectDelete("SIG_BARS_TF5");
   ObjectCreate("SIG_BARS_TF5", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_BARS_TF5", ls_312, 7, "Arial Bold", gi_1100);
   ObjectSet("SIG_BARS_TF5", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_BARS_TF5", OBJPROP_XDISTANCE, gi_1080 + 54 + li_24);
   ObjectSet("SIG_BARS_TF5", OBJPROP_YDISTANCE, gi_1076 + 25);
   ObjectDelete("SIG_BARS_TF6");
   ObjectCreate("SIG_BARS_TF6", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_BARS_TF6", ls_320, 7, "Arial Bold", gi_1100);
   ObjectSet("SIG_BARS_TF6", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_BARS_TF6", OBJPROP_XDISTANCE, gi_1080 + 34 + li_28);
   ObjectSet("SIG_BARS_TF6", OBJPROP_YDISTANCE, gi_1076 + 25);
   ObjectDelete("SIG_BARS_TF7");
   ObjectCreate("SIG_BARS_TF7", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_BARS_TF7", ls_328, 7, "Arial Bold", gi_1100);
   ObjectSet("SIG_BARS_TF7", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_BARS_TF7", OBJPROP_XDISTANCE, gi_1080 + 14 + li_32);
   ObjectSet("SIG_BARS_TF7", OBJPROP_YDISTANCE, gi_1076 + 25);
   string ls_336 = "";
   string ls_344 = "";
   string ls_352 = "";
   string ls_360 = "";
   string ls_368 = "";
   string ls_376 = "";
   string ls_384 = "";
   string ls_392 = "";
   string ls_400 = "";
   double ld_408 = iMACD(NULL, gi_1044, gi_1148, gi_1152, gi_1156, gi_1160, MODE_MAIN, 0);
   double ld_416 = iMACD(NULL, gi_1044, gi_1148, gi_1152, gi_1156, gi_1160, MODE_SIGNAL, 0);
   double ld_424 = iMACD(NULL, gi_1048, gi_1148, gi_1152, gi_1156, gi_1160, MODE_MAIN, 0);
   double ld_432 = iMACD(NULL, gi_1048, gi_1148, gi_1152, gi_1156, gi_1160, MODE_SIGNAL, 0);
   double ld_440 = iMACD(NULL, gi_1052, gi_1148, gi_1152, gi_1156, gi_1160, MODE_MAIN, 0);
   double ld_448 = iMACD(NULL, gi_1052, gi_1148, gi_1152, gi_1156, gi_1160, MODE_SIGNAL, 0);
   double ld_456 = iMACD(NULL, gi_1056, gi_1148, gi_1152, gi_1156, gi_1160, MODE_MAIN, 0);
   double ld_464 = iMACD(NULL, gi_1056, gi_1148, gi_1152, gi_1156, gi_1160, MODE_SIGNAL, 0);
   double ld_472 = iMACD(NULL, gi_1060, gi_1148, gi_1152, gi_1156, gi_1160, MODE_MAIN, 0);
   double ld_480 = iMACD(NULL, gi_1060, gi_1148, gi_1152, gi_1156, gi_1160, MODE_SIGNAL, 0);
   double ld_488 = iMACD(NULL, gi_1064, gi_1148, gi_1152, gi_1156, gi_1160, MODE_MAIN, 0);
   double ld_496 = iMACD(NULL, gi_1064, gi_1148, gi_1152, gi_1156, gi_1160, MODE_SIGNAL, 0);
   double ld_504 = iMACD(NULL, gi_1068, gi_1148, gi_1152, gi_1156, gi_1160, MODE_MAIN, 0);
   double ld_512 = iMACD(NULL, gi_1068, gi_1148, gi_1152, gi_1156, gi_1160, MODE_SIGNAL, 0);
   if (ld_408 > ld_416) {
      ls_360 = "-";
      li_48 = gi_1172;
   }
   if (ld_408 <= ld_416) {
      ls_360 = "-";
      li_48 = gi_1168;
   }
   if (ld_408 > ld_416 && ld_408 > 0.0) {
      ls_360 = "-";
      li_48 = gi_1164;
   }
   if (ld_408 <= ld_416 && ld_408 < 0.0) {
      ls_360 = "-";
      li_48 = gi_1176;
   }
   if (ld_424 > ld_432) {
      ls_368 = "-";
      li_52 = gi_1172;
   }
   if (ld_424 <= ld_432) {
      ls_368 = "-";
      li_52 = gi_1168;
   }
   if (ld_424 > ld_432 && ld_424 > 0.0) {
      ls_368 = "-";
      li_52 = gi_1164;
   }
   if (ld_424 <= ld_432 && ld_424 < 0.0) {
      ls_368 = "-";
      li_52 = gi_1176;
   }
   if (ld_440 > ld_448) {
      ls_376 = "-";
      li_56 = gi_1172;
   }
   if (ld_440 <= ld_448) {
      ls_376 = "-";
      li_56 = gi_1168;
   }
   if (ld_440 > ld_448 && ld_440 > 0.0) {
      ls_376 = "-";
      li_56 = gi_1164;
   }
   if (ld_440 <= ld_448 && ld_440 < 0.0) {
      ls_376 = "-";
      li_56 = gi_1176;
   }
   if (ld_456 > ld_464) {
      ls_384 = "-";
      li_60 = gi_1172;
   }
   if (ld_456 <= ld_464) {
      ls_384 = "-";
      li_60 = gi_1168;
   }
   if (ld_456 > ld_464 && ld_456 > 0.0) {
      ls_384 = "-";
      li_60 = gi_1164;
   }
   if (ld_456 <= ld_464 && ld_456 < 0.0) {
      ls_384 = "-";
      li_60 = gi_1176;
   }
   if (ld_472 > ld_480) {
      ls_344 = "-";
      li_40 = gi_1172;
   }
   if (ld_472 <= ld_480) {
      ls_344 = "-";
      li_40 = gi_1168;
   }
   if (ld_472 > ld_480 && ld_472 > 0.0) {
      ls_344 = "-";
      li_40 = gi_1164;
   }
   if (ld_472 <= ld_480 && ld_472 < 0.0) {
      ls_344 = "-";
      li_40 = gi_1176;
   }
   if (ld_488 > ld_496) {
      ls_352 = "-";
      li_44 = gi_1172;
   }
   if (ld_488 <= ld_496) {
      ls_352 = "-";
      li_44 = gi_1168;
   }
   if (ld_488 > ld_496 && ld_488 > 0.0) {
      ls_352 = "-";
      li_44 = gi_1164;
   }
   if (ld_488 <= ld_496 && ld_488 < 0.0) {
      ls_352 = "-";
      li_44 = gi_1176;
   }
   if (ld_504 > ld_512) {
      ls_336 = "-";
      li_36 = gi_1172;
   }
   if (ld_504 <= ld_512) {
      ls_336 = "-";
      li_36 = gi_1168;
   }
   if (ld_504 > ld_512 && ld_504 > 0.0) {
      ls_336 = "-";
      li_36 = gi_1164;
   }
   if (ld_504 <= ld_512 && ld_504 < 0.0) {
      ls_336 = "-";
      li_36 = gi_1176;
   }
   ObjectDelete("SSignalMACD_TEXT");
   ObjectCreate("SSignalMACD_TEXT", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACD_TEXT", "MACD", 6, "Tahoma Narrow", gi_1104);
   ObjectSet("SSignalMACD_TEXT", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACD_TEXT", OBJPROP_XDISTANCE, gi_1080 + 153);
   ObjectSet("SSignalMACD_TEXT", OBJPROP_YDISTANCE, gi_1076 + 35);
   ObjectDelete("SSignalMACDM1");
   ObjectCreate("SSignalMACDM1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACDM1", ls_360, 45, "Tahoma Narrow", li_48);
   ObjectSet("SSignalMACDM1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACDM1", OBJPROP_XDISTANCE, gi_1080 + 130);
   ObjectSet("SSignalMACDM1", OBJPROP_YDISTANCE, gi_1076 + 2);
   ObjectDelete("SSignalMACDM5");
   ObjectCreate("SSignalMACDM5", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACDM5", ls_368, 45, "Tahoma Narrow", li_52);
   ObjectSet("SSignalMACDM5", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACDM5", OBJPROP_XDISTANCE, gi_1080 + 110);
   ObjectSet("SSignalMACDM5", OBJPROP_YDISTANCE, gi_1076 + 2);
   ObjectDelete("SSignalMACDM15");
   ObjectCreate("SSignalMACDM15", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACDM15", ls_376, 45, "Tahoma Narrow", li_56);
   ObjectSet("SSignalMACDM15", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACDM15", OBJPROP_XDISTANCE, gi_1080 + 90);
   ObjectSet("SSignalMACDM15", OBJPROP_YDISTANCE, gi_1076 + 2);
   ObjectDelete("SSignalMACDM30");
   ObjectCreate("SSignalMACDM30", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACDM30", ls_384, 45, "Tahoma Narrow", li_60);
   ObjectSet("SSignalMACDM30", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACDM30", OBJPROP_XDISTANCE, gi_1080 + 70);
   ObjectSet("SSignalMACDM30", OBJPROP_YDISTANCE, gi_1076 + 2);
   ObjectDelete("SSignalMACDH1");
   ObjectCreate("SSignalMACDH1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACDH1", ls_344, 45, "Tahoma Narrow", li_40);
   ObjectSet("SSignalMACDH1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACDH1", OBJPROP_XDISTANCE, gi_1080 + 50);
   ObjectSet("SSignalMACDH1", OBJPROP_YDISTANCE, gi_1076 + 2);
   ObjectDelete("SSignalMACDH4");
   ObjectCreate("SSignalMACDH4", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACDH4", ls_352, 45, "Tahoma Narrow", li_44);
   ObjectSet("SSignalMACDH4", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACDH4", OBJPROP_XDISTANCE, gi_1080 + 30);
   ObjectSet("SSignalMACDH4", OBJPROP_YDISTANCE, gi_1076 + 2);
   ObjectDelete("SSignalMACDD1");
   ObjectCreate("SSignalMACDD1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalMACDD1", ls_336, 45, "Tahoma Narrow", li_36);
   ObjectSet("SSignalMACDD1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalMACDD1", OBJPROP_XDISTANCE, gi_1080 + 10);
   ObjectSet("SSignalMACDD1", OBJPROP_YDISTANCE, gi_1076 + 2);
   double ld_520 = iRSI(NULL, gi_1068, gi_1196, gi_1200, 0);
   double ld_528 = iRSI(NULL, gi_1064, gi_1196, gi_1200, 0);
   double ld_536 = iRSI(NULL, gi_1060, gi_1196, gi_1200, 0);
   double ld_544 = iRSI(NULL, gi_1056, gi_1196, gi_1200, 0);
   double ld_552 = iRSI(NULL, gi_1052, gi_1196, gi_1200, 0);
   double ld_560 = iRSI(NULL, gi_1048, gi_1196, gi_1200, 0);
   double ld_568 = iRSI(NULL, gi_1044, gi_1196, gi_1200, 0);
   double ld_576 = iStochastic(NULL, gi_1068, gi_1228, gi_1232, gi_1236, gi_1240, 0, MODE_MAIN, 0);
   double ld_584 = iStochastic(NULL, gi_1064, gi_1228, gi_1232, gi_1236, gi_1240, 0, MODE_MAIN, 0);
   double ld_592 = iStochastic(NULL, gi_1060, gi_1228, gi_1232, gi_1236, gi_1240, 0, MODE_MAIN, 0);
   double ld_600 = iStochastic(NULL, gi_1056, gi_1228, gi_1232, gi_1236, gi_1240, 0, MODE_MAIN, 0);
   double ld_608 = iStochastic(NULL, gi_1052, gi_1228, gi_1232, gi_1236, gi_1240, 0, MODE_MAIN, 0);
   double ld_616 = iStochastic(NULL, gi_1048, gi_1228, gi_1232, gi_1236, gi_1240, 0, MODE_MAIN, 0);
   double ld_624 = iStochastic(NULL, gi_1044, gi_1228, gi_1232, gi_1236, gi_1240, 0, MODE_MAIN, 0);
   double ld_632 = iCCI(NULL, gi_1068, gi_1212, gi_1216, 0);
   double ld_640 = iCCI(NULL, gi_1064, gi_1212, gi_1216, 0);
   double ld_648 = iCCI(NULL, gi_1060, gi_1212, gi_1216, 0);
   double ld_656 = iCCI(NULL, gi_1056, gi_1212, gi_1216, 0);
   double ld_664 = iCCI(NULL, gi_1052, gi_1212, gi_1216, 0);
   double ld_672 = iCCI(NULL, gi_1048, gi_1212, gi_1216, 0);
   double ld_680 = iCCI(NULL, gi_1044, gi_1212, gi_1216, 0);
   string ls_688 = "";
   string ls_696 = "";
   string ls_704 = "";
   string ls_712 = "";
   string ls_720 = "";
   string ls_728 = "";
   string ls_736 = "";
   string ls_744 = "";
   string ls_752 = "";
   ls_736 = "-";
   color li_760 = gi_1260;
   ls_720 = "-";
   color li_764 = gi_1260;
   ls_688 = "-";
   color li_768 = gi_1260;
   ls_728 = "-";
   color li_772 = gi_1260;
   ls_696 = "-";
   color li_776 = gi_1260;
   ls_704 = "-";
   color li_780 = gi_1260;
   ls_712 = "-";
   color li_784 = gi_1260;
   if (ld_520 > 50.0 && ld_576 > 40.0 && ld_632 > 0.0) {
      ls_736 = "-";
      li_760 = gi_1252;
   }
   if (ld_528 > 50.0 && ld_584 > 40.0 && ld_640 > 0.0) {
      ls_720 = "-";
      li_764 = gi_1252;
   }
   if (ld_536 > 50.0 && ld_592 > 40.0 && ld_648 > 0.0) {
      ls_688 = "-";
      li_768 = gi_1252;
   }
   if (ld_544 > 50.0 && ld_600 > 40.0 && ld_656 > 0.0) {
      ls_728 = "-";
      li_772 = gi_1252;
   }
   if (ld_552 > 50.0 && ld_608 > 40.0 && ld_664 > 0.0) {
      ls_696 = "-";
      li_776 = gi_1252;
   }
   if (ld_560 > 50.0 && ld_616 > 40.0 && ld_672 > 0.0) {
      ls_704 = "-";
      li_780 = gi_1252;
   }
   if (ld_568 > 50.0 && ld_624 > 40.0 && ld_680 > 0.0) {
      ls_712 = "-";
      li_784 = gi_1252;
   }
   if (ld_520 < 50.0 && ld_576 < 60.0 && ld_632 < 0.0) {
      ls_736 = "-";
      li_760 = gi_1256;
   }
   if (ld_528 < 50.0 && ld_584 < 60.0 && ld_640 < 0.0) {
      ls_720 = "-";
      li_764 = gi_1256;
   }
   if (ld_536 < 50.0 && ld_592 < 60.0 && ld_648 < 0.0) {
      ls_688 = "-";
      li_768 = gi_1256;
   }
   if (ld_544 < 50.0 && ld_600 < 60.0 && ld_656 < 0.0) {
      ls_728 = "-";
      li_772 = gi_1256;
   }
   if (ld_552 < 50.0 && ld_608 < 60.0 && ld_664 < 0.0) {
      ls_696 = "-";
      li_776 = gi_1256;
   }
   if (ld_560 < 50.0 && ld_616 < 60.0 && ld_672 < 0.0) {
      ls_704 = "-";
      li_780 = gi_1256;
   }
   if (ld_568 < 50.0 && ld_624 < 60.0 && ld_680 < 0.0) {
      ls_712 = "-";
      li_784 = gi_1256;
   }
   ObjectDelete("SSignalSTR_TEXT");
   ObjectCreate("SSignalSTR_TEXT", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SSignalSTR_TEXT", "STR", 6, "Tahoma Narrow", gi_1104);
   ObjectSet("SSignalSTR_TEXT", OBJPROP_CORNER, gi_1072);
   ObjectSet("SSignalSTR_TEXT", OBJPROP_XDISTANCE, gi_1080 + 153);
   ObjectSet("SSignalSTR_TEXT", OBJPROP_YDISTANCE, gi_1076 + 43);
   ObjectDelete("SignalSTRM1");
   ObjectCreate("SignalSTRM1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalSTRM1", ls_712, 45, "Tahoma Narrow", li_784);
   ObjectSet("SignalSTRM1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalSTRM1", OBJPROP_XDISTANCE, gi_1080 + 130);
   ObjectSet("SignalSTRM1", OBJPROP_YDISTANCE, gi_1076 + 10);
   ObjectDelete("SignalSTRM5");
   ObjectCreate("SignalSTRM5", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalSTRM5", ls_704, 45, "Tahoma Narrow", li_780);
   ObjectSet("SignalSTRM5", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalSTRM5", OBJPROP_XDISTANCE, gi_1080 + 110);
   ObjectSet("SignalSTRM5", OBJPROP_YDISTANCE, gi_1076 + 10);
   ObjectDelete("SignalSTRM15");
   ObjectCreate("SignalSTRM15", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalSTRM15", ls_696, 45, "Tahoma Narrow", li_776);
   ObjectSet("SignalSTRM15", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalSTRM15", OBJPROP_XDISTANCE, gi_1080 + 90);
   ObjectSet("SignalSTRM15", OBJPROP_YDISTANCE, gi_1076 + 10);
   ObjectDelete("SignalSTRM30");
   ObjectCreate("SignalSTRM30", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalSTRM30", ls_728, 45, "Tahoma Narrow", li_772);
   ObjectSet("SignalSTRM30", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalSTRM30", OBJPROP_XDISTANCE, gi_1080 + 70);
   ObjectSet("SignalSTRM30", OBJPROP_YDISTANCE, gi_1076 + 10);
   ObjectDelete("SignalSTRH1");
   ObjectCreate("SignalSTRH1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalSTRH1", ls_688, 45, "Tahoma Narrow", li_768);
   ObjectSet("SignalSTRH1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalSTRH1", OBJPROP_XDISTANCE, gi_1080 + 50);
   ObjectSet("SignalSTRH1", OBJPROP_YDISTANCE, gi_1076 + 10);
   ObjectDelete("SignalSTRH4");
   ObjectCreate("SignalSTRH4", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalSTRH4", ls_720, 45, "Tahoma Narrow", li_764);
   ObjectSet("SignalSTRH4", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalSTRH4", OBJPROP_XDISTANCE, gi_1080 + 30);
   ObjectSet("SignalSTRH4", OBJPROP_YDISTANCE, gi_1076 + 10);
   ObjectDelete("SignalSTRD1");
   ObjectCreate("SignalSTRD1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalSTRD1", ls_736, 45, "Tahoma Narrow", li_760);
   ObjectSet("SignalSTRD1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalSTRD1", OBJPROP_XDISTANCE, gi_1080 + 10);
   ObjectSet("SignalSTRD1", OBJPROP_YDISTANCE, gi_1076 + 10);
   double ld_788 = iMA(Symbol(), gi_1044, gi_1272, 0, gi_1280, gi_1284, 0);
   double ld_796 = iMA(Symbol(), gi_1044, gi_1276, 0, gi_1280, gi_1284, 0);
   double ld_804 = iMA(Symbol(), gi_1048, gi_1272, 0, gi_1280, gi_1284, 0);
   double ld_812 = iMA(Symbol(), gi_1048, gi_1276, 0, gi_1280, gi_1284, 0);
   double ld_820 = iMA(Symbol(), gi_1052, gi_1272, 0, gi_1280, gi_1284, 0);
   double ld_828 = iMA(Symbol(), gi_1052, gi_1276, 0, gi_1280, gi_1284, 0);
   double ld_836 = iMA(Symbol(), gi_1056, gi_1272, 0, gi_1280, gi_1284, 0);
   double ld_844 = iMA(Symbol(), gi_1056, gi_1276, 0, gi_1280, gi_1284, 0);
   double ld_852 = iMA(Symbol(), gi_1060, gi_1272, 0, gi_1280, gi_1284, 0);
   double ld_860 = iMA(Symbol(), gi_1060, gi_1276, 0, gi_1280, gi_1284, 0);
   double ld_868 = iMA(Symbol(), gi_1064, gi_1272, 0, gi_1280, gi_1284, 0);
   double ld_876 = iMA(Symbol(), gi_1064, gi_1276, 0, gi_1280, gi_1284, 0);
   double ld_884 = iMA(Symbol(), gi_1068, gi_1272, 0, gi_1280, gi_1284, 0);
   double ld_892 = iMA(Symbol(), gi_1068, gi_1276, 0, gi_1280, gi_1284, 0);
   string ls_900 = "";
   string ls_908 = "";
   string ls_916 = "";
   string ls_924 = "";
   string ls_932 = "";
   string ls_940 = "";
   string ls_948 = "";
   string ls_956 = "";
   string ls_964 = "";
   if (ld_788 > ld_796) {
      ls_900 = "-";
      li_72 = gi_1296;
   }
   if (ld_788 <= ld_796) {
      ls_900 = "-";
      li_72 = gi_1300;
   }
   if (ld_804 > ld_812) {
      ls_908 = "-";
      li_76 = gi_1296;
   }
   if (ld_804 <= ld_812) {
      ls_908 = "-";
      li_76 = gi_1300;
   }
   if (ld_820 > ld_828) {
      ls_916 = "-";
      li_80 = gi_1296;
   }
   if (ld_820 <= ld_828) {
      ls_916 = "-";
      li_80 = gi_1300;
   }
   if (ld_836 > ld_844) {
      ls_924 = "-";
      li_84 = gi_1296;
   }
   if (ld_836 <= ld_844) {
      ls_924 = "-";
      li_84 = gi_1300;
   }
   if (ld_852 > ld_860) {
      ls_932 = "-";
      li_88 = gi_1296;
   }
   if (ld_852 <= ld_860) {
      ls_932 = "-";
      li_88 = gi_1300;
   }
   if (ld_868 > ld_876) {
      ls_940 = "-";
      li_92 = gi_1296;
   }
   if (ld_868 <= ld_876) {
      ls_940 = "-";
      li_92 = gi_1300;
   }
   if (ld_884 > ld_892) {
      ls_948 = "-";
      li_96 = gi_1296;
   }
   if (ld_884 <= ld_892) {
      ls_948 = "-";
      li_96 = gi_1300;
   }
   ObjectDelete("SignalEMA_TEXT");
   ObjectCreate("SignalEMA_TEXT", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMA_TEXT", "EMA", 6, "Tahoma Narrow", gi_1104);
   ObjectSet("SignalEMA_TEXT", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMA_TEXT", OBJPROP_XDISTANCE, gi_1080 + 153);
   ObjectSet("SignalEMA_TEXT", OBJPROP_YDISTANCE, gi_1076 + 51);
   ObjectDelete("SignalEMAM1");
   ObjectCreate("SignalEMAM1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMAM1", ls_900, 45, "Tahoma Narrow", li_72);
   ObjectSet("SignalEMAM1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMAM1", OBJPROP_XDISTANCE, gi_1080 + 130);
   ObjectSet("SignalEMAM1", OBJPROP_YDISTANCE, gi_1076 + 18);
   ObjectDelete("SignalEMAM5");
   ObjectCreate("SignalEMAM5", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMAM5", ls_908, 45, "Tahoma Narrow", li_76);
   ObjectSet("SignalEMAM5", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMAM5", OBJPROP_XDISTANCE, gi_1080 + 110);
   ObjectSet("SignalEMAM5", OBJPROP_YDISTANCE, gi_1076 + 18);
   ObjectDelete("SignalEMAM15");
   ObjectCreate("SignalEMAM15", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMAM15", ls_916, 45, "Tahoma Narrow", li_80);
   ObjectSet("SignalEMAM15", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMAM15", OBJPROP_XDISTANCE, gi_1080 + 90);
   ObjectSet("SignalEMAM15", OBJPROP_YDISTANCE, gi_1076 + 18);
   ObjectDelete("SignalEMAM30");
   ObjectCreate("SignalEMAM30", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMAM30", ls_924, 45, "Tahoma Narrow", li_84);
   ObjectSet("SignalEMAM30", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMAM30", OBJPROP_XDISTANCE, gi_1080 + 70);
   ObjectSet("SignalEMAM30", OBJPROP_YDISTANCE, gi_1076 + 18);
   ObjectDelete("SignalEMAH1");
   ObjectCreate("SignalEMAH1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMAH1", ls_932, 45, "Tahoma Narrow", li_88);
   ObjectSet("SignalEMAH1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMAH1", OBJPROP_XDISTANCE, gi_1080 + 50);
   ObjectSet("SignalEMAH1", OBJPROP_YDISTANCE, gi_1076 + 18);
   ObjectDelete("SignalEMAH4");
   ObjectCreate("SignalEMAH4", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMAH4", ls_940, 45, "Tahoma Narrow", li_92);
   ObjectSet("SignalEMAH4", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMAH4", OBJPROP_XDISTANCE, gi_1080 + 30);
   ObjectSet("SignalEMAH4", OBJPROP_YDISTANCE, gi_1076 + 18);
   ObjectDelete("SignalEMAD1");
   ObjectCreate("SignalEMAD1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SignalEMAD1", ls_948, 45, "Tahoma Narrow", li_96);
   ObjectSet("SignalEMAD1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SignalEMAD1", OBJPROP_XDISTANCE, gi_1080 + 10);
   ObjectSet("SignalEMAD1", OBJPROP_YDISTANCE, gi_1076 + 18);
   double ld_972 = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits);
   double ld_980 = iMA(Symbol(), PERIOD_M1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
   string ls_988 = "";
   if (ld_980 > ld_972) {
      ls_988 = "";
      li_100 = gi_1140;
   }
   if (ld_980 < ld_972) {
      ls_988 = "";
      li_100 = gi_1136;
   }
   if (ld_980 == ld_972) {
      ls_988 = "";
      li_100 = gi_1144;
   }
   ObjectDelete("cja");
   ObjectCreate("cja", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("cja", "cja", 8, "Tahoma Narrow", DimGray);
   ObjectSet("cja", OBJPROP_CORNER, gi_1072);
   ObjectSet("cja", OBJPROP_XDISTANCE, gi_1080 + 153);
   ObjectSet("cja", OBJPROP_YDISTANCE, gi_1076 + 23);
   if (gi_1096 == FALSE) {
      if (gi_1088 == TRUE) {
         ObjectDelete("Signalprice");
         ObjectCreate("Signalprice", OBJ_LABEL, gi_1084, 0, 0);
         ObjectSetText("Signalprice", DoubleToStr(ld_972, Digits), 35, "Arial", li_100);
         ObjectSet("Signalprice", OBJPROP_CORNER, gi_1072);
         ObjectSet("Signalprice", OBJPROP_XDISTANCE, gi_1080 + 10);
         ObjectSet("Signalprice", OBJPROP_YDISTANCE, gi_1076 + 56);
      }
   }
   if (gi_1096 == TRUE) {
      if (gi_1088 == TRUE) {
         ObjectDelete("Signalprice");
         ObjectCreate("Signalprice", OBJ_LABEL, gi_1084, 0, 0);
         ObjectSetText("Signalprice", DoubleToStr(ld_972, Digits), 15, "Arial", li_100);
         ObjectSet("Signalprice", OBJPROP_CORNER, gi_1072);
         ObjectSet("Signalprice", OBJPROP_XDISTANCE, gi_1080 + 10);
         ObjectSet("Signalprice", OBJPROP_YDISTANCE, gi_1076 + 60);
      }
   }
   int li_996 = 0;
   int li_1000 = 0;
   int li_1004 = 0;
   int li_1008 = 0;
   int li_1012 = 0;
   int li_1016 = 0;
   li_996 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   for (li_1016 = 1; li_1016 <= 5; li_1016++) li_1000 = li_1000 + (iHigh(NULL, PERIOD_D1, li_1016) - iLow(NULL, PERIOD_D1, li_1016)) / Point;
   for (li_1016 = 1; li_1016 <= 10; li_1016++) li_1004 = li_1004 + (iHigh(NULL, PERIOD_D1, li_1016) - iLow(NULL, PERIOD_D1, li_1016)) / Point;
   for (li_1016 = 1; li_1016 <= 20; li_1016++) li_1008 = li_1008 + (iHigh(NULL, PERIOD_D1, li_1016) - iLow(NULL, PERIOD_D1, li_1016)) / Point;
   li_1000 /= 5;
   li_1004 /= 10;
   li_1008 /= 20;
   li_1012 = (li_996 + li_1000 + li_1004 + li_1008) / 4;
   string ls_1020 = "";
   string ls_1028 = "";
   string ls_1036 = "";
   string ls_1044 = "";
   string ls_1052 = "";
   string ls_1060 = "";
   string ls_1068 = "";
   string ls_1076 = "";
   string ls_1084 = "";
   double ld_1092 = iOpen(NULL, PERIOD_D1, 0);
   double ld_1100 = iClose(NULL, PERIOD_D1, 0);
   double ld_1108 = (Ask - Bid) / Point;
   double ld_1116 = iHigh(NULL, PERIOD_D1, 0);
   double ld_1124 = iLow(NULL, PERIOD_D1, 0);
   ls_1044 = DoubleToStr((ld_1100 - ld_1092) / Point, 0);
   ls_1036 = DoubleToStr(ld_1108, Digits - 4);
   ls_1052 = DoubleToStr(li_1012, Digits - 4);
   ls_1084 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   ls_1060 = DoubleToStr((ld_1116 - ld_1124) / Point, 0);
   if (ld_1100 >= ld_1092) {
      ls_1068 = "-";
      li_112 = gi_1120;
   }
   if (ld_1100 < ld_1092) {
      ls_1068 = "-";
      li_112 = gi_1124;
   }
   if (ls_1052 >= ls_1084) {
      ls_1076 = "-";
      li_116 = gi_1128;
   }
   if (ls_1052 < ls_1084) {
      ls_1076 = "-";
      li_116 = gi_1132;
   }
   ObjectDelete("SIG_DETAIL_1");
   ObjectCreate("SIG_DETAIL_1", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_DETAIL_1", "Spread", 14, "Times New Roman", gi_1108);
   ObjectSet("SIG_DETAIL_1", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_DETAIL_1", OBJPROP_XDISTANCE, gi_1080 + 65);
   ObjectSet("SIG_DETAIL_1", OBJPROP_YDISTANCE, gi_1076 + 100);
   ObjectDelete("SIG_DETAIL_2");
   ObjectCreate("SIG_DETAIL_2", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_DETAIL_2", "" + ls_1036 + "", 14, "Times New Roman", gi_1112);
   ObjectSet("SIG_DETAIL_2", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_DETAIL_2", OBJPROP_XDISTANCE, gi_1080 + 10);
   ObjectSet("SIG_DETAIL_2", OBJPROP_YDISTANCE, gi_1076 + 100);
   ObjectDelete("SIG_DETAIL_3");
   ObjectCreate("SIG_DETAIL_3", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_DETAIL_3", "Volatility Ratio", 14, "Times New Roman", gi_1108);
   ObjectSet("SIG_DETAIL_3", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_DETAIL_3", OBJPROP_XDISTANCE, gi_1080 + 65);
   ObjectSet("SIG_DETAIL_3", OBJPROP_YDISTANCE, gi_1076 + 115);
   ObjectDelete("SIG_DETAIL_4");
   ObjectCreate("SIG_DETAIL_4", OBJ_LABEL, gi_1084, 0, 0);
   ObjectSetText("SIG_DETAIL_4", "" + ls_1044 + "", 14, "Times New Roman", li_112);
   ObjectSet("SIG_DETAIL_4", OBJPROP_CORNER, gi_1072);
   ObjectSet("SIG_DETAIL_4", OBJPROP_XDISTANCE, gi_1080 + 10);
   ObjectSet("SIG_DETAIL_4", OBJPROP_YDISTANCE, gi_1076 + 115);
   double ld_1164 = LotExponent;
   int li_1172 = lotdecimal;
   double ld_1176 = TakeProfit;
   bool li_1184 = UseEquityStop;
   double ld_1188 = TotalEquityRisk;
   bool li_1196 = UseTrailingStop;
   double ld_1200 = TrailStart;
   double ld_1208 = TrailStop;
   double ld_1216 = PipStep;
   double ld_1224 = slip;
   if (MM == TRUE) {
      if (MathCeil(AccountBalance()) < 200000.0) ld_1232 = Lots;
      else ld_1232 = 0.00001 * MathCeil(AccountBalance());
   } else ld_1232 = Lots;
   if (li_1196) f0_34(ld_1200, ld_1208, gd_332);
   if (gi_224) {
      if (TimeCurrent() >= gi_396) {
         f0_23();
         Print("Closed All due_Hilo to TimeOut");
      }
   }
   if (gi_392 == Time[0]) return (0);
   gi_392 = Time[0];
   double ld_1240 = f0_30();
   if (li_1184) {
      if (ld_1240 < 0.0 && MathAbs(ld_1240) > ld_1188 / 100.0 * f0_7()) {
         f0_23();
         Print("Closed All due_Hilo to Stop Out");
         gi_444 = FALSE;
      }
   }
   gi_416 = f0_4();
   if (gi_416 == 0) gi_380 = FALSE;
   for (gi_412 = OrdersTotal() - 1; gi_412 >= 0; gi_412--) {
      OrderSelect(gi_412, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
         if (OrderType() == OP_BUY) {
            gi_432 = TRUE;
            gi_436 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
         if (OrderType() == OP_SELL) {
            gi_432 = FALSE;
            gi_436 = TRUE;
            break;
         }
      }
   }
   if (gi_416 > 0 && gi_416 <= MaxTrades_Hilo) {
      RefreshRates();
      gd_356 = f0_31();
      gd_364 = f0_19();
      if (gi_432 && gd_356 - Ask >= ld_1216 * Point) gi_428 = TRUE;
      if (gi_436 && Bid - gd_364 >= ld_1216 * Point) gi_428 = TRUE;
   }
   if (gi_416 < 1) {
      gi_436 = FALSE;
      gi_432 = FALSE;
      gi_428 = TRUE;
      gd_292 = AccountEquity();
   }
   if (gi_428) {
      gd_356 = f0_31();
      gd_364 = f0_19();
      if (gi_436) {
         gi_400 = gi_416;
         gd_404 = NormalizeDouble(ld_1232 * MathPow(ld_1164, gi_400), li_1172);
         RefreshRates();
         gi_440 = f0_3(1, gd_404, Bid, ld_1224, Ask, 0, 0, gs_384 + "-" + gi_400, MagicNumber_Hilo, 0, HotPink);
         if (gi_440 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_364 = f0_19();
         gi_428 = FALSE;
         gi_444 = TRUE;
      } else {
         if (gi_432) {
            gi_400 = gi_416;
            gd_404 = NormalizeDouble(ld_1232 * MathPow(ld_1164, gi_400), li_1172);
            gi_440 = f0_3(0, gd_404, Ask, ld_1224, Bid, 0, 0, gs_384 + "-" + gi_400, MagicNumber_Hilo, 0, Lime);
            if (gi_440 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_356 = f0_31();
            gi_428 = FALSE;
            gi_444 = TRUE;
         }
      }
   }
   if (gi_428 && gi_416 < 1) {
      ld_1132 = iHigh(Symbol(), 0, 1);
      ld_1140 = iLow(Symbol(), 0, 2);
      gd_340 = Bid;
      gd_348 = Ask;
      if ((!gi_436) && !gi_432) {
         gi_400 = gi_416;
         gd_404 = NormalizeDouble(ld_1232 * MathPow(ld_1164, gi_400), li_1172);
         if (ld_1132 > ld_1140) {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               gi_440 = f0_3(1, gd_404, gd_340, ld_1224, gd_340, 0, 0, gs_384 + "-" + gi_400, MagicNumber_Hilo, 0, HotPink);
               if (gi_440 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_356 = f0_31();
               gi_444 = TRUE;
            }
         } else {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               gi_440 = f0_3(0, gd_404, gd_348, ld_1224, gd_348, 0, 0, gs_384 + "-" + gi_400, MagicNumber_Hilo, 0, Lime);
               if (gi_440 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_364 = f0_19();
               gi_444 = TRUE;
            }
         }
         if (gi_440 > 0) gi_396 = TimeCurrent() + 60.0 * (60.0 * gd_228);
         gi_428 = FALSE;
      }
   }
   gi_416 = f0_4();
   gd_332 = 0;
   double ld_1248 = 0;
   for (gi_412 = OrdersTotal() - 1; gi_412 >= 0; gi_412--) {
      OrderSelect(gi_412, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            gd_332 += OrderOpenPrice() * OrderLots();
            ld_1248 += OrderLots();
         }
      }
   }
   if (gi_416 > 0) gd_332 = NormalizeDouble(gd_332 / ld_1248, Digits);
   if (gi_444) {
      for (gi_412 = OrdersTotal() - 1; gi_412 >= 0; gi_412--) {
         OrderSelect(gi_412, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
            if (OrderType() == OP_BUY) {
               gd_284 = gd_332 + ld_1176 * Point;
               gd_300 = gd_284;
               gd_420 = gd_332 - gd_240 * Point;
               gi_380 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
            if (OrderType() == OP_SELL) {
               gd_284 = gd_332 - ld_1176 * Point;
               gd_308 = gd_284;
               gd_420 = gd_332 + gd_240 * Point;
               gi_380 = TRUE;
            }
         }
      }
   }
   if (gi_444) {
      if (gi_380 == TRUE) {
         for (gi_412 = OrdersTotal() - 1; gi_412 >= 0; gi_412--) {
            OrderSelect(gi_412, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
               while (!OrderModify(OrderTicket(), gd_332, OrderStopLoss(), gd_284, 0, Yellow)) {
                  Sleep(1000);
                  RefreshRates();
               }
            }
            gi_444 = FALSE;
         }
      }
   }
   double ld_1256 = LotExponent;
   int li_1264 = lotdecimal;
   double ld_1268 = TakeProfit;
   bool li_1276 = UseEquityStop;
   double ld_1280 = TotalEquityRisk;
   bool li_1288 = UseTrailingStop;
   double ld_1292 = TrailStart;
   double ld_1300 = TrailStop;
   double ld_1308 = PipStep;
   double ld_1316 = slip;
   if (MM == TRUE) {
      if (MathCeil(AccountBalance()) < 200000.0) ld_1324 = Lots;
      else ld_1324 = 0.00001 * MathCeil(AccountBalance());
   } else ld_1324 = Lots;
   if (li_1288) f0_20(ld_1292, ld_1300, gd_616);
   if (gi_552) {
      if (TimeCurrent() >= gi_680) {
         f0_17();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_676 != Time[0]) {
      gi_676 = Time[0];
      ld_1332 = f0_28();
      if (li_1276) {
         if (ld_1332 < 0.0 && MathAbs(ld_1332) > ld_1280 / 100.0 * f0_15()) {
            f0_17();
            Print("Closed All due to Stop Out");
            gi_728 = FALSE;
         }
      }
      gi_700 = f0_5();
      if (gi_700 == 0) gi_664 = FALSE;
      for (gi_696 = OrdersTotal() - 1; gi_696 >= 0; gi_696--) {
         OrderSelect(gi_696, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_BUY) {
               gi_716 = TRUE;
               gi_720 = FALSE;
               break;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_SELL) {
               gi_716 = FALSE;
               gi_720 = TRUE;
               break;
            }
         }
      }
      if (gi_700 > 0 && gi_700 <= MaxTrades_15) {
         RefreshRates();
         gd_640 = f0_35();
         gd_648 = f0_27();
         if (gi_716 && gd_640 - Ask >= ld_1308 * Point) gi_712 = TRUE;
         if (gi_720 && Bid - gd_648 >= ld_1308 * Point) gi_712 = TRUE;
      }
      if (gi_700 < 1) {
         gi_720 = FALSE;
         gi_716 = FALSE;
         gi_712 = TRUE;
         gd_592 = AccountEquity();
      }
      if (gi_712) {
         gd_640 = f0_35();
         gd_648 = f0_27();
         if (gi_720) {
            gi_684 = gi_700;
            gd_688 = NormalizeDouble(ld_1324 * MathPow(ld_1256, gi_684), li_1264);
            RefreshRates();
            gi_724 = f0_2(1, gd_688, Bid, ld_1316, Ask, 0, 0, gs_668 + "-" + gi_684, g_magic_176_15, 0, HotPink);
            if (gi_724 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_648 = f0_27();
            gi_712 = FALSE;
            gi_728 = TRUE;
         } else {
            if (gi_716) {
               gi_684 = gi_700;
               gd_688 = NormalizeDouble(ld_1324 * MathPow(ld_1256, gi_684), li_1264);
               gi_724 = f0_2(0, gd_688, Ask, ld_1316, Bid, 0, 0, gs_668 + "-" + gi_684, g_magic_176_15, 0, Lime);
               if (gi_724 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_640 = f0_35();
               gi_712 = FALSE;
               gi_728 = TRUE;
            }
         }
      }
   }
   if (gi_748 != iTime(NULL, gi_516, 0)) {
      li_1340 = OrdersTotal();
      li_1344 = 0;
      for (int li_1348 = li_1340; li_1348 >= 1; li_1348--) {
         OrderSelect(li_1348 - 1, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) li_1344++;
      }
      if (li_1340 == 0 || li_1344 < 1) {
         ld_1148 = iClose(Symbol(), 0, 2);
         ld_1156 = iClose(Symbol(), 0, 1);
         gd_624 = Bid;
         gd_632 = Ask;
         gi_684 = gi_700;
         gd_688 = ld_1324;
         if (ld_1148 > ld_1156) {
            gi_724 = f0_2(1, gd_688, gd_624, ld_1316, gd_624, 0, 0, gs_668 + "-" + gi_684, g_magic_176_15, 0, HotPink);
            if (gi_724 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_640 = f0_35();
            gi_728 = TRUE;
         } else {
            gi_724 = f0_2(0, gd_688, gd_632, ld_1316, gd_632, 0, 0, gs_668 + "-" + gi_684, g_magic_176_15, 0, Lime);
            if (gi_724 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_648 = f0_27();
            gi_728 = TRUE;
         }
         if (gi_724 > 0) gi_680 = TimeCurrent() + 60.0 * (60.0 * gd_556);
         gi_712 = FALSE;
      }
      gi_748 = iTime(NULL, gi_516, 0);
   }
   gi_700 = f0_5();
   gd_616 = 0;
   double ld_1352 = 0;
   for (gi_696 = OrdersTotal() - 1; gi_696 >= 0; gi_696--) {
      OrderSelect(gi_696, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            gd_616 += OrderOpenPrice() * OrderLots();
            ld_1352 += OrderLots();
         }
      }
   }
   if (gi_700 > 0) gd_616 = NormalizeDouble(gd_616 / ld_1352, Digits);
   if (gi_728) {
      for (gi_696 = OrdersTotal() - 1; gi_696 >= 0; gi_696--) {
         OrderSelect(gi_696, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_BUY) {
               gd_584 = gd_616 + ld_1268 * Point;
               gd_600 = gd_584;
               gd_704 = gd_616 - gd_528 * Point;
               gi_664 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_SELL) {
               gd_584 = gd_616 - ld_1268 * Point;
               gd_608 = gd_584;
               gd_704 = gd_616 + gd_528 * Point;
               gi_664 = TRUE;
            }
         }
      }
   }
   if (gi_728) {
      if (gi_664 == TRUE) {
         for (gi_696 = OrdersTotal() - 1; gi_696 >= 0; gi_696--) {
            OrderSelect(gi_696, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
               while (!OrderModify(OrderTicket(), gd_616, OrderStopLoss(), gd_584, 0, Yellow)) {
                  Sleep(1000);
                  RefreshRates();
               }
            }
            gi_728 = FALSE;
         }
      }
   }
   double ld_1360 = LotExponent;
   int li_1368 = lotdecimal;
   double ld_1372 = TakeProfit;
   bool li_1380 = UseEquityStop;
   double ld_1384 = TotalEquityRisk;
   bool li_1392 = UseTrailingStop;
   double ld_1396 = TrailStart;
   double ld_1404 = TrailStop;
   double ld_1412 = PipStep;
   double ld_1420 = slip;
   if (MM == TRUE) {
      if (MathCeil(AccountBalance()) < 200000.0) ld_1428 = Lots;
      else ld_1428 = 0.00001 * MathCeil(AccountBalance());
   } else ld_1428 = Lots;
   if (li_1392) f0_33(ld_1396, ld_1404, gd_900);
   if (gi_836) {
      if (TimeCurrent() >= gi_964) {
         f0_0();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_960 != Time[0]) {
      gi_960 = Time[0];
      ld_1436 = f0_8();
      if (li_1380) {
         if (ld_1436 < 0.0 && MathAbs(ld_1436) > ld_1384 / 100.0 * f0_29()) {
            f0_0();
            Print("Closed All due to Stop Out");
            gi_1012 = FALSE;
         }
      }
      gi_984 = f0_12();
      if (gi_984 == 0) gi_948 = FALSE;
      for (gi_980 = OrdersTotal() - 1; gi_980 >= 0; gi_980--) {
         OrderSelect(gi_980, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) {
               gi_1000 = TRUE;
               gi_1004 = FALSE;
               break;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_SELL) {
               gi_1000 = FALSE;
               gi_1004 = TRUE;
               break;
            }
         }
      }
      if (gi_984 > 0 && gi_984 <= MaxTrades_16) {
         RefreshRates();
         gd_924 = f0_16();
         gd_932 = f0_26();
         if (gi_1000 && gd_924 - Ask >= ld_1412 * Point) gi_996 = TRUE;
         if (gi_1004 && Bid - gd_932 >= ld_1412 * Point) gi_996 = TRUE;
      }
      if (gi_984 < 1) {
         gi_1004 = FALSE;
         gi_1000 = FALSE;
         gd_876 = AccountEquity();
      }
      if (gi_996) {
         gd_924 = f0_16();
         gd_932 = f0_26();
         if (gi_1004) {
            gi_968 = gi_984;
            gd_972 = NormalizeDouble(ld_1428 * MathPow(ld_1360, gi_968), li_1368);
            RefreshRates();
            gi_1008 = f0_6(1, gd_972, Bid, ld_1420, Ask, 0, 0, gs_952 + "-" + gi_968, g_magic_176_16, 0, HotPink);
            if (gi_1008 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_932 = f0_26();
            gi_996 = FALSE;
            gi_1012 = TRUE;
         } else {
            if (gi_1000) {
               gi_968 = gi_984;
               gd_972 = NormalizeDouble(ld_1428 * MathPow(ld_1360, gi_968), li_1368);
               gi_1008 = f0_6(0, gd_972, Ask, ld_1420, Bid, 0, 0, gs_952 + "-" + gi_968, g_magic_176_16, 0, Lime);
               if (gi_1008 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_924 = f0_16();
               gi_996 = FALSE;
               gi_1012 = TRUE;
            }
         }
      }
   }
   if (gi_1032 != iTime(NULL, gi_804, 0)) {
      li_1444 = OrdersTotal();
      li_1448 = 0;
      for (int li_1452 = li_1444; li_1452 >= 1; li_1452--) {
         OrderSelect(li_1452 - 1, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) li_1448++;
      }
      if (li_1444 == 0 || li_1448 < 1) {
         ld_1148 = iClose(Symbol(), 0, 2);
         ld_1156 = iClose(Symbol(), 0, 1);
         gd_908 = Bid;
         gd_916 = Ask;
         gi_968 = gi_984;
         gd_972 = ld_1428;
         if (ld_1148 > ld_1156) {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               gi_1008 = f0_6(1, gd_972, gd_908, ld_1420, gd_908, 0, 0, gs_952 + "-" + gi_968, g_magic_176_16, 0, HotPink);
               if (gi_1008 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_924 = f0_16();
               gi_1012 = TRUE;
            }
         } else {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               gi_1008 = f0_6(0, gd_972, gd_916, ld_1420, gd_916, 0, 0, gs_952 + "-" + gi_968, g_magic_176_16, 0, Lime);
               if (gi_1008 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_932 = f0_26();
               gi_1012 = TRUE;
            }
         }
         if (gi_1008 > 0) gi_964 = TimeCurrent() + 60.0 * (60.0 * gd_840);
         gi_996 = FALSE;
      }
      gi_1032 = iTime(NULL, gi_804, 0);
   }
   gi_984 = f0_12();
   gd_900 = 0;
   double ld_1456 = 0;
   for (gi_980 = OrdersTotal() - 1; gi_980 >= 0; gi_980--) {
      OrderSelect(gi_980, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            gd_900 += OrderOpenPrice() * OrderLots();
            ld_1456 += OrderLots();
         }
      }
   }
   if (gi_984 > 0) gd_900 = NormalizeDouble(gd_900 / ld_1456, Digits);
   if (gi_1012) {
      for (gi_980 = OrdersTotal() - 1; gi_980 >= 0; gi_980--) {
         OrderSelect(gi_980, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) {
               gd_868 = gd_900 + ld_1372 * Point;
               gd_884 = gd_868;
               gd_988 = gd_900 - gd_812 * Point;
               gi_948 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_SELL) {
               gd_868 = gd_900 - ld_1372 * Point;
               gd_892 = gd_868;
               gd_988 = gd_900 + gd_812 * Point;
               gi_948 = TRUE;
            }
         }
      }
   }
   if (gi_1012) {
      if (gi_948 == TRUE) {
         for (gi_980 = OrdersTotal() - 1; gi_980 >= 0; gi_980--) {
            OrderSelect(gi_980, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
               while (!OrderModify(OrderTicket(), gd_900, OrderStopLoss(), gd_868, 0, Yellow)) {
                  Sleep(1000);
                  RefreshRates();
               }
            }
            gi_1012 = FALSE;
         }
      }
   }
   return (0);
}
	 	 				 	    	    	  	  	 	 	 		  					 	     	  		 		  				   		 			   	 			 	 			 	     	  		 	 	  					 					 			     	 	  	  	 	 	    	   		
int f0_4() {
   int li_0 = 0;
   for (int li_4 = OrdersTotal() - 1; li_4 >= 0; li_4--) {
      OrderSelect(li_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) li_0++;
   }
   return (li_0);
}
	 	  	 			  	   	  		   		 					   	 	 			  	 			 				  				  	  	 	 		 		 	 										 	  		  			 		  	 		  	 	  		  	 	 	   			 	     	  		 		 
void f0_23() {
   for (int li_0 = OrdersTotal() - 1; li_0 >= 0; li_0--) {
      OrderSelect(li_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, gd_272, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, gd_272, Red);
         }
         Sleep(1000);
      }
   }
}
		  	 			 	  		 				 		 	 		   	 				 			 	  	 			 	  	 	  			    			   	 			  		  	    				 				 		 			    	 		 	 			  		  		 			  			 				 	 	 
int f0_3(int ai_0, double ad_4, double ad_12, int ai_20, double ad_24, int ai_32, int ai_36, string as_40, int ai_48, int ai_52, color ai_56) {
   int li_60 = 0;
   int li_64 = 0;
   int li_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 0:
      for (li_68 = 0; li_68 < li_72; li_68++) {
         RefreshRates();
         li_60 = OrderSend(Symbol(), OP_BUY, ad_4, Ask, ai_20, f0_21(Bid, ai_32), f0_18(Ask, ai_36), as_40, ai_48, ai_52, ai_56);
         li_64 = GetLastError();
         if (li_64 == 0/* NO_ERROR */) break;
         if (!((li_64 == 4/* SERVER_BUSY */ || li_64 == 137/* BROKER_BUSY */ || li_64 == 146/* TRADE_CONTEXT_BUSY */ || li_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (li_68 = 0; li_68 < li_72; li_68++) {
         li_60 = OrderSend(Symbol(), OP_SELL, ad_4, Bid, ai_20, f0_11(Ask, ai_32), f0_1(Bid, ai_36), as_40, ai_48, ai_52, ai_56);
         li_64 = GetLastError();
         if (li_64 == 0/* NO_ERROR */) break;
         if (!((li_64 == 4/* SERVER_BUSY */ || li_64 == 137/* BROKER_BUSY */ || li_64 == 146/* TRADE_CONTEXT_BUSY */ || li_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (li_60);
}
	   	 	  		  			  		 			 			    	 			 	  		  	     	  		 	 			 						  	 				    	 	   	  		 		  			 		 		  	 	 	  			 	    		      				  		 	  	
double f0_21(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
				   	   			   	  		      	 				     	   					 		 	     	  		 	     	       		  	 	 	  	  		 	    		 		 		   				  		  			 			 			 	   	  					
double f0_11(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
			         		 	 	 			 	   		 	 		 	        			  				  	  		 				  	  		   	  	   			 		 	 			     			  	 	     				 			 		  		  		  	 	 	 				 	
double f0_18(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
	     	  		 				  						 				   	 		  	  		 		     		 		 	 	 	 					   	 			     	 		  	  					  						 		    	 	  	 	 	     	       			  				  	
double f0_1(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
	 		 					 		 	 	   	 	 		  		 	     					 		  		 	 			 			      	   	  		   	 				 		  	   	 				  	 		 			 			  	     	 		   		 		  	 	   	  	 
double f0_30() {
   double ld_0 = 0;
   for (gi_412 = OrdersTotal() - 1; gi_412 >= 0; gi_412--) {
      OrderSelect(gi_412, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_0 += OrderProfit();
   }
   return (ld_0);
}
		      	 	 		 							 		 			 	  			    	 	 			 		 		  		  	 			  		  			 		  	 	  		 								  	 				           	 	 					   		 		   	 								  
void f0_34(int ai_0, int ai_4, double ad_8) {
   int li_16;
   double ld_20;
   double ld_28;
   if (ai_4 != 0) {
      for (int li_36 = OrdersTotal() - 1; li_36 >= 0; li_36--) {
         if (OrderSelect(li_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_Hilo) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - ad_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  ld_20 = OrderStopLoss();
                  ld_28 = Bid - ai_4 * Point;
                  if (ld_20 == 0.0 || (ld_20 != 0.0 && ld_28 > ld_20)) OrderModify(OrderTicket(), ad_8, ld_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((ad_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  ld_20 = OrderStopLoss();
                  ld_28 = Ask + ai_4 * Point;
                  if (ld_20 == 0.0 || (ld_20 != 0.0 && ld_28 < ld_20)) OrderModify(OrderTicket(), ad_8, ld_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}
	  		 						 		 	 	  		 			    	  	 	 						 	 		     	 		  		   		 	   			 	  			      	 	  						  			 	 		 		    		  	  			 		  				 	 	  	 	 
double f0_7() {
   if (f0_4() == 0) gd_448 = AccountEquity();
   if (gd_448 < gd_456) gd_448 = gd_456;
   else gd_448 = AccountEquity();
   gd_456 = AccountEquity();
   return (gd_448);
}
	 	   		 	  			    				  	 		  		  	  		 	  		 	  			 	  			 	  		 	     	 	   	 				      					 	 								   			 		 	    	  	 	  	  		    			 		
double f0_31() {
   double ld_0;
   int li_8;
   double ld_12 = 0;
   int li_20 = 0;
   for (int li_24 = OrdersTotal() - 1; li_24 >= 0; li_24--) {
      OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_BUY) {
         li_8 = OrderTicket();
         if (li_8 > li_20) {
            ld_0 = OrderOpenPrice();
            ld_12 = ld_0;
            li_20 = li_8;
         }
      }
   }
   return (ld_0);
}
			  		     	 		 	 		 		   			  		 	 		     	    							  		   		  	 	 	   	 	    				 	 	 		 	    		 	 	 	  		 				   	 		      		   		 	 		   	
double f0_19() {
   double ld_0;
   int li_8;
   double ld_12 = 0;
   int li_20 = 0;
   for (int li_24 = OrdersTotal() - 1; li_24 >= 0; li_24--) {
      OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_SELL) {
         li_8 = OrderTicket();
         if (li_8 > li_20) {
            ld_0 = OrderOpenPrice();
            ld_12 = ld_0;
            li_20 = li_8;
         }
      }
   }
   return (ld_0);
}
	 			    	 	 	 	     	 	 	    	 	   	    	 	 		   	    	 		 						  	 		 	  	 	  		   		     	   	   	  					   	 	 				  					   				 	     		 	
int f0_5() {
   int li_0 = 0;
   for (int li_4 = OrdersTotal() - 1; li_4 >= 0; li_4--) {
      OrderSelect(li_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) li_0++;
   }
   return (li_0);
}
		 				   		  		 		   		  	  	  			 			   		     	   			    	  		 	 		 	  	 		       	 	 		   	   	   	 	  				 		  	  	 	 		    	 		 		 		     	
void f0_17() {
   for (int li_0 = OrdersTotal() - 1; li_0 >= 0; li_0--) {
      OrderSelect(li_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, gd_572, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, gd_572, Red);
         }
         Sleep(1000);
      }
   }
}
	 	 	    	   	 	   	 	 	 	 	  	 	  		    	   		   		   	 									 		 		 	 		 	  			  		   	 	   	 	 	  			 	   	 						  	 			   	 		 	   	 		 	
int f0_2(int ai_0, double ad_4, double ad_12, int ai_20, double ad_24, int ai_32, int ai_36, string as_40, int ai_48, int ai_52, color ai_56) {
   int li_60 = 0;
   int li_64 = 0;
   int li_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 0:
      for (li_68 = 0; li_68 < li_72; li_68++) {
         RefreshRates();
         li_60 = OrderSend(Symbol(), OP_BUY, ad_4, Ask, ai_20, f0_13(Bid, ai_32), f0_24(Ask, ai_36), as_40, ai_48, ai_52, ai_56);
         li_64 = GetLastError();
         if (li_64 == 0/* NO_ERROR */) break;
         if (!((li_64 == 4/* SERVER_BUSY */ || li_64 == 137/* BROKER_BUSY */ || li_64 == 146/* TRADE_CONTEXT_BUSY */ || li_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (li_68 = 0; li_68 < li_72; li_68++) {
         li_60 = OrderSend(Symbol(), OP_SELL, ad_4, Bid, ai_20, f0_32(Ask, ai_32), f0_25(Bid, ai_36), as_40, ai_48, ai_52, ai_56);
         li_64 = GetLastError();
         if (li_64 == 0/* NO_ERROR */) break;
         if (!((li_64 == 4/* SERVER_BUSY */ || li_64 == 137/* BROKER_BUSY */ || li_64 == 146/* TRADE_CONTEXT_BUSY */ || li_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (li_60);
}
		  	  	  	  	   			 	    		  							  	  	  			 	 	       				 	 			 	   			 		   	  	  			 	 	  		 	 		   	  			 				  	  				 	  		   			 				
double f0_13(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
		  		 		 	     				    	 		 			 					 		 	   				 	 	  	  		 	   					 	 							  	 		 				   		 		   	    		 	 	 		 	 		  	 				  	   				  		 
double f0_32(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
			 		 	         	 	       	 					 			 	      		 			 	    			 	 	  				    					  		 		  	 	   	   	   		 	 		 						 	  		 	 		 		 	    	 	  			
double f0_24(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
	 			  			 	 	  	    	  		    		    	  			 	 				 	     			 			  	  	 	 		  	 					   	 	    	 			   	 	 				  	  	 			 	 							 				  	    			 
double f0_25(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
			 		         	 	 	   	   	 		 		 			        	  			 	 	  			 			  					   				   		 			 	 	       	    	 	 		  					 		 		 	 	  		 	  	 	 	  	 	
double f0_28() {
   double ld_0 = 0;
   for (gi_696 = OrdersTotal() - 1; gi_696 >= 0; gi_696--) {
      OrderSelect(gi_696, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_0 += OrderProfit();
   }
   return (ld_0);
}
		 	  	   						 		 				  	 	   			   	   				   	  	 		     	 		 	    	  	         	  	 		 			   	 			 	  	  	 		   	 	 	 	 	   	 	 			 		 		  	
void f0_20(int ai_0, int ai_4, double ad_8) {
   int li_16;
   double ld_20;
   double ld_28;
   if (ai_4 != 0) {
      for (int li_36 = OrdersTotal() - 1; li_36 >= 0; li_36--) {
         if (OrderSelect(li_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176_15) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - ad_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  ld_20 = OrderStopLoss();
                  ld_28 = Bid - ai_4 * Point;
                  if (ld_20 == 0.0 || (ld_20 != 0.0 && ld_28 > ld_20)) OrderModify(OrderTicket(), ad_8, ld_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((ad_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  ld_20 = OrderStopLoss();
                  ld_28 = Ask + ai_4 * Point;
                  if (ld_20 == 0.0 || (ld_20 != 0.0 && ld_28 < ld_20)) OrderModify(OrderTicket(), ad_8, ld_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}
	 			  	 	 	 	       	   	    			   	  	 	 	 			  	      		 			 		  	 	  	  	 		 		   	      	 	 	   	 						  		 	 			   						  				       				
double f0_15() {
   if (f0_5() == 0) gd_732 = AccountEquity();
   if (gd_732 < gd_740) gd_732 = gd_740;
   else gd_732 = AccountEquity();
   gd_740 = AccountEquity();
   return (gd_732);
}
	 	    			  		  	  			  		 		 		   	   			  					 			   				 		  	 	  	 		 	  							 	 	  			 			 			 	 		    	  		 		 	 	  				 	  	  	  					 
double f0_35() {
   double ld_0;
   int li_8;
   double ld_12 = 0;
   int li_20 = 0;
   for (int li_24 = OrdersTotal() - 1; li_24 >= 0; li_24--) {
      OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15 && OrderType() == OP_BUY) {
         li_8 = OrderTicket();
         if (li_8 > li_20) {
            ld_0 = OrderOpenPrice();
            ld_12 = ld_0;
            li_20 = li_8;
         }
      }
   }
   return (ld_0);
}
		  				  	   	  			  	   		 	 									  	    	 	 	 		    		   	 				    				 	   	 	   			  		  		  			   						 		    	  	  	 	  	 	  			   		
double f0_27() {
   double ld_0;
   int li_8;
   double ld_12 = 0;
   int li_20 = 0;
   for (int li_24 = OrdersTotal() - 1; li_24 >= 0; li_24--) {
      OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15 && OrderType() == OP_SELL) {
         li_8 = OrderTicket();
         if (li_8 > li_20) {
            ld_0 = OrderOpenPrice();
            ld_12 = ld_0;
            li_20 = li_8;
         }
      }
   }
   return (ld_0);
}
		 	  	 	 									 					 	 	    		   	 	 				  		  	 			    	 	  	    		 	     	   	  				 			 	 	 			    	  	  	   	 			 	 	  		 	 						 		   
int f0_12() {
   int li_0 = 0;
   for (int li_4 = OrdersTotal() - 1; li_4 >= 0; li_4--) {
      OrderSelect(li_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) li_0++;
   }
   return (li_0);
}
	 	 	    	   	 	   	 	 	 	 	  	 	  		    	   		   		   	 									 		 		 	 		 	  			  		   	 	   	 	 	  			 	   	 						  	 			   	 		 	   	 		 	
void f0_0() {
   for (int li_0 = OrdersTotal() - 1; li_0 >= 0; li_0--) {
      OrderSelect(li_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, gd_856, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, gd_856, Red);
         }
         Sleep(1000);
      }
   }
}
	  		 						 		 	 	  		 			    	  	 	 						 	 		     	 		  		   		 	   			 	  			      	 	  						  			 	 		 		    		  	  			 		  				 	 	  	 	 
int f0_6(int ai_0, double ad_4, double ad_12, int ai_20, double ad_24, int ai_32, int ai_36, string as_40, int ai_48, int ai_52, color ai_56) {
   int li_60 = 0;
   int li_64 = 0;
   int li_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 0:
      for (li_68 = 0; li_68 < li_72; li_68++) {
         RefreshRates();
         li_60 = OrderSend(Symbol(), OP_BUY, ad_4, Ask, ai_20, f0_14(Bid, ai_32), f0_9(Ask, ai_36), as_40, ai_48, ai_52, ai_56);
         li_64 = GetLastError();
         if (li_64 == 0/* NO_ERROR */) break;
         if (!((li_64 == 4/* SERVER_BUSY */ || li_64 == 137/* BROKER_BUSY */ || li_64 == 146/* TRADE_CONTEXT_BUSY */ || li_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (li_68 = 0; li_68 < li_72; li_68++) {
         li_60 = OrderSend(Symbol(), OP_SELL, ad_4, Bid, ai_20, f0_22(Ask, ai_32), f0_10(Bid, ai_36), as_40, ai_48, ai_52, ai_56);
         li_64 = GetLastError();
         if (li_64 == 0/* NO_ERROR */) break;
         if (!((li_64 == 4/* SERVER_BUSY */ || li_64 == 137/* BROKER_BUSY */ || li_64 == 146/* TRADE_CONTEXT_BUSY */ || li_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (li_60);
}
			         		 	 	 			 	   		 	 		 	        			  				  	  		 				  	  		   	  	   			 		 	 			     			  	 	     				 			 		  		  		  	 	 	 				 	
double f0_14(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
		 				   		  		 		   		  	  	  			 			   		     	   			    	  		 	 		 	  	 		       	 	 		   	   	   	 	  				 		  	  	 	 		    	 		 		 		     	
double f0_22(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
	 						 	 	  	       	  	   	 		   				 	 	   	  	  		  		 	   		  		   	  		 	 		  	        		 	    											 	 	     			  	  			 	        		
double f0_9(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
	    		 			 	 			 			 								    		 		 			 	   	  							 	   	 			 	 					 	  		 			 		 			 	 					 	  	   		    	   		       	     			 			    
double f0_10(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
		 	 	 	  			    		 	     	 							  	 	  			 		 	  		        	 	 	  		   	  			    			  		 	  	  	 	  		  	 	 			    	  	 	  		 	 	     		 	 			
double f0_8() {
   double ld_0 = 0;
   for (gi_980 = OrdersTotal() - 1; gi_980 >= 0; gi_980--) {
      OrderSelect(gi_980, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_0 += OrderProfit();
   }
   return (ld_0);
}
	 	   	  	  				   					 	 		   	  	  	  	  		    			 		 			 	 			 	   	 	 	     				  	   				  	 				 			   	 	 		 	 	  	  	    	  			   			  	
void f0_33(int ai_0, int ai_4, double ad_8) {
   int li_16;
   double ld_20;
   double ld_28;
   if (ai_4 != 0) {
      for (int li_36 = OrdersTotal() - 1; li_36 >= 0; li_36--) {
         if (OrderSelect(li_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176_16) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - ad_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  ld_20 = OrderStopLoss();
                  ld_28 = Bid - ai_4 * Point;
                  if (ld_20 == 0.0 || (ld_20 != 0.0 && ld_28 > ld_20)) OrderModify(OrderTicket(), ad_8, ld_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((ad_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  ld_20 = OrderStopLoss();
                  ld_28 = Ask + ai_4 * Point;
                  if (ld_20 == 0.0 || (ld_20 != 0.0 && ld_28 < ld_20)) OrderModify(OrderTicket(), ad_8, ld_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}
	 	 	 	 		   				  	 					 	       		 	 		   	  	 		  								 	 	 		  			 		   				   		  	 		 		 	 		  		 	 	   				 		 	 		  	 	 					  	 	   
double f0_29() {
   if (f0_12() == 0) gd_1016 = AccountEquity();
   if (gd_1016 < gd_1024) gd_1016 = gd_1024;
   else gd_1016 = AccountEquity();
   gd_1024 = AccountEquity();
   return (gd_1016);
}
					  		  	 	  		   	  	     		 	  	  		  	 						     	 	 			     	 	 	   	 			 	   	 		   	 		    	 	  			  	 		 			 														  		   			 
double f0_16() {
   double ld_0;
   int li_8;
   double ld_12 = 0;
   int li_20 = 0;
   for (int li_24 = OrdersTotal() - 1; li_24 >= 0; li_24--) {
      OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_BUY) {
         li_8 = OrderTicket();
         if (li_8 > li_20) {
            ld_0 = OrderOpenPrice();
            ld_12 = ld_0;
            li_20 = li_8;
         }
      }
   }
   return (ld_0);
}
			  	 		   	   		 		   	  					 	 	 	 		   	 								  	 		  	    	 		 	  	 				 					 		 		  		  		  	  	  	 	 			  	 			   					     		 		 		 
double f0_26() {
   double ld_0;
   int li_8;
   double ld_12 = 0;
   int li_20 = 0;
   for (int li_24 = OrdersTotal() - 1; li_24 >= 0; li_24--) {
      OrderSelect(li_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_SELL) {
         li_8 = OrderTicket();
         if (li_8 > li_20) {
            ld_0 = OrderOpenPrice();
            ld_12 = ld_0;
            li_20 = li_8;
         }
      }
   }
   return (ld_0);
}
