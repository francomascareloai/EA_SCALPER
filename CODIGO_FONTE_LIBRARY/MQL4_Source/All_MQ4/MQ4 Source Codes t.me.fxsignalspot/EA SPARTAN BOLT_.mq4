/*
   G e n e r a t e d  by ex4-to-mq4 decompiler 4.0.500.8
   E-mail : puR E be AM@ G M Ail . C Om
*/

string Gs_76 = "EA SPARTAN BOLT V1.1";
extern int magic = 1234;
extern bool closeall = FALSE;
extern bool closelosses = FALSE;
extern double minlosses = 100.0;
extern string moneymanagement = "Money Management";
extern double lots = 0.1;
extern bool mm = FALSE;
extern double risk = 1.0;
extern double minlot = 0.01;
extern double maxlot = 100.0;
extern double lotdigits = 2.0;
extern bool basketpercent = FALSE;
extern double profit = 10.0;
extern double loss = 30.0;
extern string ordersmanagement = "Order Management";
extern bool isbrokerecn = FALSE;
extern bool timeout = FALSE;
extern double timeminutes = 60.0;
extern double maxorders = 200.0;
extern bool maxtradesperpair = FALSE;
extern double maxtradespercent = 50.0;
extern double pipstep = 0.0;
extern bool hidesl = FALSE;
extern bool hidetp = FALSE;
extern double lstoploss = 0.0;
extern double sstoploss = 0.0;
extern bool dynamicsl = FALSE;
extern int atrperiod = 14;
extern double atrmultiple = 1.0;
extern int atrtimeframe = 1440;
extern int atrshift = 1;
extern double ltakeprofit = 10.0;
extern double stakeprofit = 10.0;
extern double ltrailingstop = 20.0;
extern double strailingstop = 10.0;
extern int slippage = 1;
extern string entrylogics = "Entry Logics";
extern int closetimeframe = 5;
extern int closeshift = 0;
extern int matimeframe = 5;
extern int maperiod1 = 5;
extern int maperiod2 = 4;
extern int mamethod = 0;
extern int maprice = 1;
extern int mashift = 1;
extern bool sleeping = FALSE;
extern int sleepingminutes = 10;
extern string trendfilters = "Trend Filters";
extern bool enforceall = FALSE;
extern bool oppositeclose = FALSE;
extern bool reverseontrend = FALSE;
extern bool tradetrendsonly = FALSE;
extern int trendmaperiod = 14;
extern bool mafilter = FALSE;
extern int mafiltertimeframe = 0;
extern int mafilterperiod = 100;
extern int mafiltermethod = 0;
extern int mafilterprice = 0;
extern int mafiltershift = 1;
extern bool damianifilter = FALSE;
extern int damianitimeframe = 0;
extern int visatr = 13;
extern int visstd = 20;
extern int sedatr = 40;
extern int sedstd = 100;
extern double thresholdlevel = 1.4;
extern int damianishift = 1;
extern string carmen = "Carmen Settings";
extern bool usecarmen = FALSE;
extern string Warning = "GBP/USD vs EUR/USD";
extern int average = 3;
extern double space = 1.0;
extern bool try_again = FALSE;
extern bool Display_TakeProfit = TRUE;
extern string SetOne = "**********************Set_One_Settings***************";
extern double Main_expand_rate_1 = 75.0;
extern double LineOne_expand_rate_1 = 20.0;
extern double LineTwo_expand_rate_1 = 10.0;
extern string SetTwo = "**********************Set_Two_Settings***************";
extern double start_at_pips_profit_2 = 50.0;
extern double Main_expand_rate_2 = 65.0;
extern double LineOne_expand_rate_2 = 40.0;
extern double LineTwo_expand_rate_2 = 20.0;
extern string SetThree = "**********************Set_Three_Settings***********";
extern double start_at_pips_profit_3 = 100.0;
extern double Main_expand_rate_3 = 50.0;
extern double LineOne_expand_rate_3 = 25.0;
extern double LineTwo_expand_rate_3 = 15.0;
extern string SetFour = "**********************Set_Four_Settings***********";
extern double start_at_pips_profit_4 = 150.0;
extern double Main_expand_rate_4 = 35.0;
extern double LineOne_expand_rate_4 = 15.0;
extern double LineTwo_expand_rate_4 = 10.0;
extern int carmenshift = 1;
extern string timefilter = "Time Filter";
extern int summergmtshift = 2;
extern int wintergmtshift = 1;
extern bool generalfilter1 = FALSE;
extern int starthour1 = 7;
extern int startminutes1 = 0;
extern int endhour1 = 21;
extern int endminutes1 = 0;
extern bool generalfilter2 = FALSE;
extern int starthour2 = 7;
extern int startminutes2 = 0;
extern int endhour2 = 21;
extern int endminutes2 = 0;
extern bool generalfilter3 = FALSE;
extern int starthour3 = 7;
extern int startminutes3 = 0;
extern int endhour3 = 21;
extern int endminutes3 = 0;
extern bool tradesunday = TRUE;
extern bool fridayfilter = FALSE;
extern int fridayhour = 21;
extern int fridayminutes = 0;
int Gi_736;
int Gi_740;
int Gi_744;
int Gi_748;
string Gs_752;
string Gs_760;
string Gs_768;
string Gs_776;
string Gs_784;
string Gs_792;
int G_str2time_800;
int G_str2time_804;
int G_str2time_808;
int Gi_812;
int Gi_816;
string Gs_820;
string Gs_828;
string Gs_836;
string Gs_844;
int G_str2time_852;
int G_str2time_856;
int Gi_860;
int Gi_864;
string Gs_868;
string Gs_876;
string Gs_884;
string Gs_892;
int G_str2time_900;
int G_str2time_904;
bool Gi_unused_908 = FALSE;
string Gs_unused_912 = "Alert.wav";
color G_color_920 = Green;
int Gi_unused_924 = 16776960;
color G_color_928 = Red;
int Gi_unused_932 = 15631086;
int Gi_unused_936 = 16711680;
int Gi_unused_940 = 255;
int G_order_total_944;
int G_pos_948;
int Gi_952;
double G_order_open_price_956;
double G_order_open_price_964;
double G_order_open_price_972;
double G_order_open_price_980;
double G_order_open_price_988;
double G_order_open_price_996;
double Gda_1004[14];
double Gda_1008[14];
double Gd_1012;
double Gd_1020;
int G_digits_1028;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   G_digits_1028 = Digits;
   if (G_digits_1028 == 3 || G_digits_1028 == 5) {
      Gd_1012 = 10.0 * Point;
      Gd_1020 = 10;
   } else {
      Gd_1012 = Point;
      Gd_1020 = 1;
   }
   return (0);
}
		 			  	 		   				 	 			   	  				 			 	 			 		  				 	  	 		 	  	 				   	 		 		    	  	 		 	 	 	   	  	 		  	    	   	 	 		       	 			       
// 52D46093050F38C27267BCE42543EF60
void deinit() {
   Comment("");
}
				  	 	  							   	 		 	  					      	  	 	 	   	  		      		       	  			   			 		   			 	  	   		   			 			  	  		 	     	   	 	 					 			  
// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double iatr_0;
   double ima_8;
   double icustom_16;
   double icustom_24;
   double icustom_32;
   double icustom_40;
   double icustom_48;
   double icustom_56;
   double icustom_64;
   double icustom_72;
   bool Li_80;
   bool Li_84;
   bool Li_88;
   bool Li_92;
   bool Li_96;
   bool Li_100;
   string Ls_104 = "2035.03.20";
   int str2time_112 = StrToTime(Ls_104);
   if (TimeCurrent() >= str2time_112) return (0);
   if (closeall) {
      f0_7();
      f0_11();
   }
   if (closelosses) {
      f0_0();
      f0_18();
   }
   if (basketpercent) f0_9(profit, loss);
   if (timeout) {
      f0_22();
      f0_25();
   }
   if (hidetp || hidesl) {
      f0_3();
      f0_5();
   }
   f0_1(ltrailingstop);
   f0_14(strailingstop);
   if (TimeCurrent() < Gda_1004[TimeYear(TimeCurrent()) - 1999] && TimeCurrent() > Gda_1008[TimeYear(TimeCurrent()) - 1999]) Gi_748 = summergmtshift;
   else Gi_748 = wintergmtshift;
   string Ls_unused_116 = "";
   string Ls_124 = Year() + "." + Month() + "." + Day();
   if (generalfilter1) {
      Gi_736 = starthour1 + Gi_748;
      if (Gi_736 > 23) Gi_736 -= 24;
      if (Gi_736 < 10) Gs_752 = "0" + Gi_736;
      if (Gi_736 > 9) Gs_752 = Gi_736;
      if (startminutes1 < 10) Gs_760 = "0" + startminutes1;
      if (startminutes1 > 9) Gs_760 = startminutes1;
      G_str2time_800 = StrToTime(Ls_124 + " " + Gs_752 + ":" + Gs_760);
      Gi_740 = endhour1 + Gi_748;
      if (Gi_740 > 23) Gi_740 -= 24;
      if (endhour1 < 10) Gs_768 = "0" + Gi_740;
      if (endhour1 > 9) Gs_768 = Gi_740;
      if (endminutes1 < 10) Gs_776 = "0" + endminutes1;
      if (endminutes1 > 9) Gs_776 = endminutes1;
      G_str2time_804 = StrToTime(Ls_124 + " " + Gs_768 + ":" + Gs_776);
   }
   if (generalfilter2) {
      Gi_812 = starthour2 + Gi_748;
      if (Gi_812 > 23) Gi_812 -= 24;
      Gi_812 = starthour2 + Gi_748;
      if (Gi_812 > 23) Gi_812 -= 24;
      if (Gi_812 < 10) Gs_820 = "0" + Gi_812;
      if (Gi_812 > 9) Gs_820 = Gi_812;
      if (startminutes2 < 10) Gs_828 = "0" + startminutes2;
      if (startminutes2 > 9) Gs_828 = startminutes2;
      G_str2time_852 = StrToTime(Ls_124 + " " + Gs_820 + ":" + Gs_828);
      Gi_816 = endhour2 + Gi_748;
      if (Gi_816 > 23) Gi_816 -= 24;
      if (endhour2 < 10) Gs_836 = "0" + Gi_816;
      if (endhour2 > 9) Gs_836 = Gi_816;
      if (endminutes2 < 10) Gs_844 = "0" + endminutes2;
      if (endminutes2 > 9) Gs_844 = endminutes2;
      G_str2time_856 = StrToTime(Ls_124 + " " + Gs_836 + ":" + Gs_844);
   }
   if (generalfilter3) {
      Gi_860 = starthour3 + Gi_748;
      if (Gi_860 > 23) Gi_860 -= 24;
      Gi_860 = starthour3 + Gi_748;
      if (Gi_860 > 23) Gi_860 -= 24;
      if (Gi_860 < 10) Gs_868 = "0" + Gi_860;
      if (Gi_860 > 9) Gs_868 = Gi_860;
      if (startminutes3 < 10) Gs_876 = "0" + startminutes3;
      if (startminutes3 > 9) Gs_876 = startminutes3;
      G_str2time_900 = StrToTime(Ls_124 + " " + Gs_868 + ":" + Gs_876);
      Gi_864 = endhour3 + Gi_748;
      if (Gi_864 > 23) Gi_864 -= 24;
      if (endhour3 < 10) Gs_884 = "0" + Gi_864;
      if (endhour3 > 9) Gs_884 = Gi_864;
      if (endminutes3 < 10) Gs_892 = "0" + endminutes3;
      if (endminutes3 > 9) Gs_892 = endminutes3;
      G_str2time_904 = StrToTime(Ls_124 + " " + Gs_884 + ":" + Gs_892);
   }
   if (fridayfilter) {
      Gi_744 = fridayhour + Gi_748;
      if (Gi_744 > 23) Gi_744 -= 24;
      if (Gi_744 < 10) Gs_784 = "0" + Gi_744;
      if (Gi_744 > 9) Gs_784 = Gi_744;
      if (fridayminutes < 10) Gs_792 = "0" + fridayminutes;
      if (fridayminutes > 9) Gs_792 = fridayminutes;
      G_str2time_808 = StrToTime(Ls_124 + " " + Gs_784 + ":" + Gs_792);
   }
   bool Li_132 = TRUE;
   if (generalfilter1 && (Gi_736 <= Gi_740 && TimeCurrent() < G_str2time_800 || TimeCurrent() > G_str2time_804) || (Gi_736 > Gi_740 && TimeCurrent() < G_str2time_800 &&
      TimeCurrent() > G_str2time_804)) Li_132 = FALSE;
   bool Li_136 = TRUE;
   if (generalfilter2 && (Gi_812 <= Gi_816 && TimeCurrent() < G_str2time_852 || TimeCurrent() > G_str2time_856) || (Gi_812 > Gi_816 && TimeCurrent() < G_str2time_852 &&
      TimeCurrent() > G_str2time_856)) Li_136 = FALSE;
   bool Li_140 = TRUE;
   if (generalfilter3 && (Gi_860 <= Gi_864 && TimeCurrent() < G_str2time_900 || TimeCurrent() > G_str2time_904) || (Gi_860 > Gi_864 && TimeCurrent() < G_str2time_900 &&
      TimeCurrent() > G_str2time_904)) Li_140 = FALSE;
   bool Li_144 = TRUE;
   if (tradesunday == FALSE && DayOfWeek() == 0) Li_144 = FALSE;
   bool Li_148 = TRUE;
   if (fridayfilter && Li_132 == TRUE || Li_136 == TRUE || Li_140 == TRUE && DayOfWeek() == 5 && TimeCurrent() > G_str2time_808) Li_148 = FALSE;
   double iclose_152 = iClose(NULL, closetimeframe, closeshift);
   double ima_160 = iMA(NULL, matimeframe, maperiod1, 0, mamethod, maprice, mashift);
   double ima_168 = iMA(NULL, matimeframe, maperiod2, 0, mamethod, maprice, mashift);
   double ima_176 = iMA(NULL, 0, trendmaperiod, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ima_184 = iMA(NULL, 0, trendmaperiod, 0, MODE_SMA, PRICE_CLOSE, 2);
   if (dynamicsl) {
      iatr_0 = iATR(NULL, atrtimeframe, atrperiod, atrshift);
      lstoploss = iatr_0 * atrmultiple / Point / Gd_1020;
      sstoploss = iatr_0 * atrmultiple / Point / Gd_1020;
   }
   if (mafilter) ima_8 = iMA(NULL, mafiltertimeframe, mafilterperiod, 0, mafiltermethod, mafilterprice, mafiltershift);
   if (damianifilter) {
      icustom_16 = iCustom(NULL, damianitimeframe, "Damiani_volatmeter v3.2", visatr, visstd, sedatr, sedstd, thresholdlevel, 0, damianishift);
      icustom_24 = iCustom(NULL, damianitimeframe, "Damiani_volatmeter v3.2", visatr, visstd, sedatr, sedstd, thresholdlevel, 2, damianishift);
   }
   if (usecarmen) {
      icustom_32 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 0, carmenshift);
      icustom_40 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 3, carmenshift);
      icustom_48 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 4, carmenshift);
      icustom_56 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 0, carmenshift + 1);
      icustom_64 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 3, carmenshift + 1);
      icustom_72 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 4, carmenshift + 1);
   }
   G_order_open_price_964 = 0;
   G_order_open_price_972 = 0;
   G_order_open_price_988 = 0;
   G_order_open_price_996 = 0;
   if (OrdersTotal() > 0) {
      for (G_pos_948 = 0; G_pos_948 < OrdersTotal(); G_pos_948++) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderCloseTime() == 0) {
            if (OrderType() == OP_BUY) {
               G_order_open_price_956 = OrderOpenPrice();
               if (G_order_open_price_956 > G_order_open_price_964) G_order_open_price_964 = G_order_open_price_956;
               if (G_order_open_price_972 == 0.0 || G_order_open_price_956 < G_order_open_price_972) G_order_open_price_972 = G_order_open_price_956;
            }
            if (OrderType() == OP_SELL) {
               G_order_open_price_980 = OrderOpenPrice();
               if (G_order_open_price_980 > G_order_open_price_988) G_order_open_price_988 = G_order_open_price_980;
               if (G_order_open_price_996 == 0.0 || G_order_open_price_980 < G_order_open_price_996) G_order_open_price_996 = G_order_open_price_980;
            }
         }
      }
   }
   bool Li_192 = FALSE;
   bool Li_196 = FALSE;
   if (enforceall) {
      Li_80 = TRUE;
      Li_84 = TRUE;
      Li_88 = TRUE;
      Li_92 = TRUE;
      Li_96 = TRUE;
      Li_100 = TRUE;
      if (mafilter && (!Ask > ima_8 && ima_176 > ima_184)) Li_80 = FALSE;
      if (mafilter && (!Bid < ima_8 && ima_176 < ima_184)) Li_92 = FALSE;
      if (damianifilter && (!icustom_16 < icustom_24 && ima_176 > ima_184)) Li_84 = FALSE;
      if (damianifilter && (!icustom_16 < icustom_24 && ima_176 < ima_184)) Li_96 = FALSE;
      if (usecarmen && (!icustom_32 > icustom_40 && icustom_32 > icustom_48 && (!icustom_56 > icustom_64 && icustom_56 > icustom_72) && ima_176 > ima_184)) Li_88 = FALSE;
      if (usecarmen && (!icustom_32 < icustom_40 && icustom_32 < icustom_48 && (!icustom_56 < icustom_64 && icustom_56 < icustom_72) && ima_176 < ima_184)) Li_100 = FALSE;
      if (Li_80 && Li_84 && Li_88 && mafilter || damianifilter || usecarmen) {
         Li_192 = TRUE;
         if (oppositeclose) f0_11();
      }
      if (Li_92 && Li_96 && Li_100 && mafilter || damianifilter || usecarmen) {
         Li_196 = TRUE;
         if (oppositeclose) f0_7();
      }
   } else {
      if ((mafilter && Ask > ima_8 && ima_176 > ima_184) || (damianifilter && icustom_16 < icustom_24 && ima_176 > ima_184) || (usecarmen && icustom_32 > icustom_40 && icustom_32 > icustom_48 &&
         (!icustom_56 > icustom_64 && icustom_56 > icustom_72) && ima_176 > ima_184)) {
         Li_192 = TRUE;
         if (oppositeclose) f0_11();
      }
      if ((mafilter && Bid < ima_8 && ima_176 < ima_184) || (damianifilter && icustom_16 < icustom_24 && ima_176 < ima_184) || (usecarmen && icustom_32 < icustom_40 && icustom_32 < icustom_48 &&
         (!icustom_56 < icustom_64 && icustom_56 < icustom_72) && ima_176 < ima_184)) {
         Li_196 = TRUE;
         if (oppositeclose) f0_7();
      }
   }
   if (mm) lots = f0_20();
   if ((!f0_16()) && Li_148 == TRUE && Li_144 == TRUE && Li_132 == TRUE || Li_136 == TRUE || Li_140 == TRUE) {
      if ((Li_192 && reverseontrend) || (iclose_152 < ima_160 && Li_196 == FALSE && tradetrendsonly == FALSE)) {
         if (!G_order_open_price_972 - Ask >= pipstep * Gd_1012 || Ask - G_order_open_price_964 >= pipstep * Gd_1012) return (0);
         f0_13();
         return (0);
      }
      if ((Li_196 && reverseontrend) || (iclose_152 > ima_168 && Li_192 == FALSE && tradetrendsonly == FALSE)) {
         if (!Bid - G_order_open_price_988 >= pipstep * Gd_1012 || G_order_open_price_996 - Bid >= pipstep * Gd_1012) return (0);
         f0_10();
         return (0);
      }
   }
   return (0);
}
					  		  	 	  		  			 	 	 		  		  	 			  				    		       	       	 	   		  					  			 								    			 					    	 		 		   	  	  	     			  	 	 
// A9B24A824F70CC1232D1C2BA27039E8D
int f0_19(int A_cmd_0) {
   int count_4 = 0;
   if (OrdersTotal() > 0) {
      for (G_pos_948 = OrdersTotal(); G_pos_948 >= 0; G_pos_948--) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == A_cmd_0 && OrderMagicNumber() == magic) count_4++;
      }
      return (count_4);
   }
   return (0);
}
		 	 		   			 		 		    	      		 		  	    		   		 		 				 	  				 	  	 		  			   	  	   		 	      	 	   		 	  			     	   	  		 	   				 	  	 	 	
// AA5EA51BFAC7B64E723BF276E0075513
double f0_20() {
   double lots_0;
   if (mm == TRUE) lots_0 = NormalizeDouble(AccountFreeMargin() / (100.0 * (NormalizeDouble(MarketInfo(Symbol(), MODE_MARGINREQUIRED), 4) + 5.0) / risk) - 0.05, lotdigits);
   else lots_0 = lots;
   return (lots_0);
}
		   	 		 	 	   				  	 	  	    				 				 	   	   	  	    		 	    		 		     						 		 		 	    			 			 		 	         	   		 		 	 	   			  		 		  	 
// 9ED55815FB278759298B6BAF50BEC3C8
bool f0_16() {
   for (int pos_0 = maxorders; pos_0 < OrdersTotal(); pos_0++) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == Symbol()) return (TRUE);
   }
   return (FALSE);
}
	 		 	  		 		  		     					    		    		 		 	  		 	 	 	 	 	   	 	 	   			 						 	 	 	 	   		  	 		  	 	   		   	 		     		   	   		 		 		 	 	    
// 2230DA82D7FAFF3EA8CD4CFC92DE64E8
void f0_1(int Ai_0) {
   for (int pos_4 = maxorders; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (Bid - OrderOpenPrice() > Ai_0 * Gd_1012)
                  if (OrderStopLoss() < Bid - Ai_0 * Gd_1012) f0_4(Bid - Ai_0 * Gd_1012);
            }
         }
      }
   }
}
	   	 	  		  			  				 	 	 					  			    		 		 				 	 							 							  			         	 	  	   		   			 	  	   						 				  				 	 		 	  		   	 		 	
// 945D754CB0DC06D04243FCBA25FC0802
void f0_14(int Ai_0) {
   for (int pos_4 = maxorders; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_SELL) {
               if (OrderOpenPrice() - Ask > Ai_0 * Gd_1012)
                  if (OrderStopLoss() > Ask + Ai_0 * Gd_1012 || OrderStopLoss() == 0.0) f0_4(Ask + Ai_0 * Gd_1012);
            }
         }
      }
   }
}
	    	   		 	  	  		  		 	 	   	  		 		  		   					  	 					 	 					 					  			    		 	 	     	  				 	 	      			 	     			 	  		 			 	   		   	
// 2FC9212C93C86A99B2C376C96453D3A4
void f0_4(double A_price_0) {
   bool bool_8 = OrderModify(OrderTicket(), OrderOpenPrice(), A_price_0, OrderTakeProfit(), 0, CLR_NONE);
}
	 	 	 				   		 	  			  							 	  		  			  		   	  	 	  	 		 	  	 		    		    		 		 	 	  	 		 			 	 	 	  	 			  									 		 		 			  	 	 		 			 
// 78BAA8FAE18F93570467778F2E829047
void f0_13() {
   double price_0;
   double price_8;
   double lots_16 = f0_6();
   if (lstoploss > 0.0 && hidesl == FALSE) price_0 = f0_24();
   else price_0 = 0;
   if (ltakeprofit > 0.0 && hidetp == FALSE) price_8 = f0_27();
   else price_8 = 0;
   string comment_24 = f0_12();
   if (maxtradesperpair == FALSE || (maxtradesperpair && f0_19(OP_BUY) < NormalizeDouble(maxorders * maxtradespercent / 100.0, 0))) {
      if (isbrokerecn == FALSE) OrderSend(Symbol(), OP_BUY, lots_16, Ask, slippage * Gd_1020, price_0, price_8, comment_24, magic, 0, G_color_920);
      if (isbrokerecn) OrderSend(Symbol(), OP_BUY, lots_16, Ask, slippage * Gd_1020, 0, 0, comment_24, magic, 0, G_color_920);
   }
   if (isbrokerecn) {
      f0_17(lstoploss);
      f0_2(ltakeprofit);
   }
}
		 				 	 		  					 	  		   	 					 		  	 			  	  						  	 				  	 		 	   	 	  		       	 		   	 	      	 		 		    	 	 	 	 			      					    	  
// 667DC3F4F5B9C0B70229F573988AC7C0
void f0_10() {
   double price_0;
   double price_8;
   double lots_16 = f0_6();
   if (sstoploss > 0.0 && hidesl == FALSE) price_0 = f0_15();
   else price_0 = 0;
   if (stakeprofit > 0.0 && hidetp == FALSE) price_8 = f0_21();
   else price_8 = 0;
   string comment_24 = f0_12();
   if (maxtradesperpair == FALSE || (maxtradesperpair && f0_19(OP_SELL) < NormalizeDouble(maxorders * maxtradespercent / 100.0, 0))) {
      if (isbrokerecn == FALSE) OrderSend(Symbol(), OP_SELL, lots_16, Bid, slippage * Gd_1020, price_0, price_8, comment_24, magic, 0, G_color_928);
      if (isbrokerecn) OrderSend(Symbol(), OP_SELL, lots_16, Bid, slippage * Gd_1020, 0, 0, comment_24, magic, 0, G_color_928);
   }
   if (isbrokerecn) {
      f0_8(sstoploss);
      f0_26(stakeprofit);
   }
}
	  					 			  	   	 	    	  	 	   	 		 	 				   							 			 			 			 		  		 	 	 	       		  		  	 		    		  		 	 		  	 		 		 						   		       			
// D362D41CFF235C066CFB390D52F4EB13
void f0_23(int A_cmd_0) {
   if (OrdersTotal() > 0) {
      for (G_pos_948 = OrdersTotal(); G_pos_948 >= 0; G_pos_948--) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == A_cmd_0) OrderDelete(OrderTicket());
      }
   }
}
			 	  	     	   	 				   				   	 		 		    			 	   	   	  		   	  		 	 	 	   		 			 						 				   	 						 		  	 				 	   		  		 		     			 	 		
// 6ABA3523C7A75AAEA41CC0DEC7953CC5
string f0_12() {
   return (Gs_76);
}
	 						 	 	  	     	    		 	 	     		 	 	 		   		 				 		  			 		  		  				 	 	  	    		 			  	 	     		 			 	 			 	 		 	  							  		   	   			
// 50257C26C4E5E915F022247BABD914FE
double f0_6() {
   return (lots);
}
			 			       		 	 		  	  			 		 	 			      	  		   					  						  			 		 	  	   			    			 	      	    			 	 			 			 	    				 	 		 			 			  	 	
// F4F2EE5CE6F3F7678B6B3F2A5D4685D7
double f0_24() {
   return (Ask - lstoploss * Gd_1012);
}
		   	    	 	  	 			  		   	   	 			 		   	   			 	  	 		 		 	 		 		 				   			  	 		 	 		    	   			 	 		     		  	      		 	  	  			 	 	 		   	
// 9B1AEE847CFB597942D106A4135D4FE6
double f0_15() {
   return (Bid + sstoploss * Gd_1012);
}
	  	    						 		 	  					   	 		 	   	 				 			 			   	 		    	 		   		 	 		 	 	   			    	 		 			 			    	 	 	 	   	  			      	  	  		   		   
// FD4055E1AC0A7D690C66D37B2C70E529
double f0_27() {
   return (Ask + ltakeprofit * Gd_1012);
}
	  			   			   	  	 	 		 	  	  	  	 			  				 								 				 		 				 						 	 		       	 	  		 	  		   	 	  		  			  	    		 		  		   	 	        	
// C23BD2D05F1A927B2825264A247F4626
double f0_21() {
   return (Bid - stakeprofit * Gd_1012);
}
		 		 	 	 		 						 		 		   							 	   	 				 	  			 		  	 	 		  	 	  	   	    		   	   	 			  	 	  	   	 					    			 	 	 	 	       				   		  
// 632A6309D71E99A017FD9D3CE1A19C24
void f0_9(double Ad_0, double Ad_8) {
   double Ld_16 = Ad_0 * (AccountBalance() / 100.0);
   double Ld_24 = Ad_8 * (AccountBalance() / 100.0);
   Gi_952 = AccountEquity() - AccountBalance();
   if (Gi_952 >= Ld_16 || Gi_952 <= (-1.0 * Ld_24)) {
      f0_7();
      f0_11();
      f0_23(OP_BUYSTOP);
      f0_23(OP_SELLSTOP);
      f0_23(OP_BUYLIMIT);
      f0_23(OP_SELLLIMIT);
      return;
   }
}
	 		 	 	 	 		         	  		          			 	 	  	 		 	 	  		   	  		   		 								  	 	 			 		  		 	  	 			 		    			    	 	   	 				 		    	 	  		
// 3180D254E1C24E987439E4F62708F6A2
void f0_5() {
   if (OrdersTotal() > 0) {
      for (G_pos_948 = OrdersTotal(); G_pos_948 >= 0; G_pos_948--) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && (hidesl && lstoploss > 0.0 && OrderProfit() <= (-1.0 * lstoploss) * OrderLots() - MarketInfo(Symbol(),
            MODE_SPREAD) * OrderLots()) || (hidetp && ltakeprofit > 0.0 && OrderProfit() >= ltakeprofit * OrderLots())) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * Gd_1020);
      }
   }
}
		  	  		 	  	  							 	  			  					 			 	 			   	 	     			     			 	       				 	 			 	  					 		 			 	  		     			 		 			  	   	    		 	 	 	 
// 28EFB830D150E70A8BB0F12BAC76EF35
void f0_3() {
   if (OrdersTotal() > 0) {
      for (G_pos_948 = OrdersTotal(); G_pos_948 >= 0; G_pos_948--) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && (hidesl && sstoploss > 0.0 && OrderProfit() <= (-1.0 * sstoploss) * OrderLots() - MarketInfo(Symbol(),
            MODE_SPREAD) * OrderLots()) || (hidetp && stakeprofit > 0.0 && OrderProfit() >= stakeprofit * OrderLots())) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * Gd_1020);
      }
   }
}
	 	 	 		 	   		    			   						    		  	 	  		  		  	 	 		 		 	 		 		   			    	  		 	 		 	 		 	 	 	 	 		 	 			 								 	 		 						  	   		 				
// 5710F6E623305B2C1458238C9757193B
void f0_7() {
   G_order_total_944 = OrdersTotal();
   if (G_order_total_944 > 0) {
      for (G_pos_948 = 0; G_pos_948 < G_order_total_944; G_pos_948++) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * Gd_1020);
      }
   }
}
			     	   		 			 	 				 		 	 			 	  	 	    			       	   	   	   	  		  	 	 	 							  		  		 	  				  		  	 	  		 	  	  	      			  							   
// 689C35E4872BA754D7230B8ADAA28E48
void f0_11() {
   G_order_total_944 = OrdersTotal();
   if (G_order_total_944 > 0) {
      for (G_pos_948 = 0; G_pos_948 < G_order_total_944; G_pos_948++) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * Gd_1020);
      }
   }
}
	 		    		 			 		    						  	 		     	 		 	 			 	 	   	 	     	 	    		 				 	 	 	 			   		 		 		  			   		 	 	 		  	  		       		 	  		 	 		   
// 09CBB5F5CE12C31A043D5C81BF20AA4A
void f0_0() {
   G_order_total_944 = OrdersTotal();
   if (G_order_total_944 > 0) {
      for (G_pos_948 = 0; G_pos_948 < G_order_total_944; G_pos_948++) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && OrderProfit() <= (-1.0 * minlosses)) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * Gd_1020);
      }
   }
}
	 	    	 	  		     	 		  			 	     	  		 	   		 		      		 	    		 	  	 			 	 		  							 	  			 	 						 	  	  				 	 	 	 	   						     				 		
// A0F6E6535C856D4495BA899376567E48
void f0_18() {
   G_order_total_944 = OrdersTotal();
   if (G_order_total_944 > 0) {
      for (G_pos_948 = 0; G_pos_948 < G_order_total_944; G_pos_948++) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && OrderProfit() <= (-1.0 * minlosses)) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * Gd_1020);
      }
   }
}
			  	  	   	  			 	  			 		   			 	 		 	     		     	 	   	 	 	   	 			  	 			 					 	  		   	 	  		 	  		    	  		    	  	 	    				 						    
// D1DDCE31F1A86B3140880F6B1877CBF8
void f0_22() {
   G_order_total_944 = OrdersTotal();
   if (G_order_total_944 > 0) {
      for (G_pos_948 = 0; G_pos_948 < G_order_total_944; G_pos_948++) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 60.0 * timeminutes) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * Gd_1020);
      }
   }
}
	 	 		  		     		  		 							  		  				 		  	 		 	  		 	 	 			 	 	 					 		  		 	 		  	   	 	 	 		 	  	   	 	  	 				   		 			   			 	 		 		     
// F7B1F0AA13347699EFAE0D924298CB02
void f0_25() {
   G_order_total_944 = OrdersTotal();
   if (G_order_total_944 > 0) {
      for (G_pos_948 = 0; G_pos_948 < G_order_total_944; G_pos_948++) {
         OrderSelect(G_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 60.0 * timeminutes) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * Gd_1020);
      }
   }
}
	 	 	 	  	   			   			 	 							   		    	  		 			  	 				 		 				 		  				       		 	  	 	 		   	 	 	  	 	 											  	 		 	 				  		  		 		 	
// 9FDC179C742334D485A77A8B241EC55C
void f0_17(int Ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(ask_4 - Ai_0 * Gd_1012, G_digits_1028), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}
	 			 				 	 		 	   		  			 			 	   	  			 			   	 		 	  	  	 	  	  	    			   		 	  	 	  				 			   	 	  					  		 						  	 		 		   	 	 	  			 
// 58B0897F29A3AD862616D6CBF39536ED
void f0_8(int Ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_SELL) {
               if (OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(bid_12 + Ai_0 * Gd_1012, G_digits_1028), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}
				  		   				  	   	    	  		  	     	   	 	  	  	  	 	     	 	       	 			  	 		 		 					 	 	    		 					 		 	 	  			      			 	 	 	  		 					
// 2569208C5E61CB15E209FFE323DB48B7
void f0_2(int Ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (OrderTakeProfit() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(ask_4 + Ai_0 * Gd_1012, G_digits_1028), 0, Red);
                  return;
               }
            }
         }
      }
   }
}
			   	     				 	 	 	 	  		 			 	 	         	 		     			  	  			  	   		 	 	    					  			  	     			  			  				 		 		    	  	 	 			 		 						 	
// F8058EB0D24E6949E44CCCFC53A38CBD
void f0_26(int Ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_SELL) {
               if (OrderTakeProfit() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(bid_12 - Ai_0 * Gd_1012, G_digits_1028), 0, Red);
                  return;
               }
            }
         }
      }
   }
}
