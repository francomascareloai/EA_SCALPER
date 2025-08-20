
#property copyright "http://penaklukforex.com "
#property link      "http://penaklukforex.com "

extern string _EA = "________EA BP6097183_______";
extern int Magic = 19572411;
extern double Lots_OP_1 = 0.01;
extern double Lots_OP_2 = 0.03;
extern double Lots_OP_3 = 0.09;
extern double Lots_OP_4 = 0.27;
extern double Lots_OP_5 = 0.81;
extern double Lots_OP_6 = 2.43;
extern double Lots_OP_7 = 7.29;
extern double Lots_OP_8 = 21.87;
extern double Lots_OP_9 = 65.61;
extern double Lots_OP_10 = 196.83;
extern int TakeProfit_1 = 10;
extern int TakeProfit_2 = 30;
extern int TakeProfit_3 = 30;
extern int TakeProfit_4 = 30;
extern int TakeProfit_5 = 30;
extern int TakeProfit_6 = 30;
extern int TakeProfit_7 = 30;
extern int TakeProfit_8 = 30;
extern int TakeProfit_9 = 30;
extern int TakeProfit_10 = 30;
extern int Step_2 = 25;
extern int Step_3 = 30;
extern int Step_4 = 35;
extern int Step_5 = 40;
extern int Step_6 = 45;
extern int Step_7 = 50;
extern int Step_8 = 55;
extern int Step_9 = 60;
extern int Step_10 = 70;
extern int Max_Level = 10;
string gs_unused_248 = "________TP SL MONEY_______";
double gd_256 = 0.0;
double gd_264 = 0.0;
extern string _TIMEFILTER = "_______ TIME FILTER BROKER TIME _______";
extern bool Use_TimeFilter = FALSE;
extern int StartHour = 0;
extern int EndHour = 24;
int gi_292;
int gi_296;
int gi_300;
string gs_unused_304;
int gi_312 = 0;
double gd_316;
double gd_324;
double g_minlot_332;
int gi_356;
int gi_360;
int g_slippage_364 = 10;
int gi_368;
int gi_372;
double g_order_lots_376;
double g_order_open_price_384;
double g_order_lots_392;
double g_order_open_price_400;
double g_order_open_price_408;
double g_order_lots_416;
int g_cmd_424;
int g_count_428;
int g_count_432;
int g_order_total_436;
int g_count_440;
int g_count_444;
bool g_is_closed_448;
bool g_is_deleted_452;
int g_datetime_456;
double gd_476;
int gi_unused_484 = 0;
int g_count_488;
double g_order_takeprofit_492;
double g_order_takeprofit_500;
int gi_508;

int init() {
   if (!IsExpertEnabled()) Alert("EA BELUM AKTIF, KLIK TOMBOL AKTIVASI EA");
   if (!IsTradeAllowed()) Alert("EA BELUM AKTIF, CENTANG PADA ALLOW LIVE TRADING");
   return (0);
}
	 	  	 	 	  	      	  	  			       	 			 	    	 		   	  		 	 	  		 	 		 			 				  			 			 	   		 	 		 			 	     				   	 	 	 	 							    			  		
int deinit() {
   return (0);
}
						     	   	 	  	 		  	 	  	 	  			    		 			  			 		   		 		   					 		 		  		   	 					 	       	 					  		 	 	       		  	 	  	 	 		     	
int start() {
   
//   int acc_number_0;
//  int acc_number_4;
  bool bool_8 = IsDemo();
/*
  if (!bool_8) {
      acc_number_0 = 60623044 ;
      acc_number_4 = AccountNumber();
      if (acc_number_4 != acc_number_0 && acc_number_4 != 0) {
         Alert("No Akun :  (" + DoubleToStr(acc_number_4, 0) + ")No akun belum terdaftar ");
         return (0);
      }
   }
*/   
   
   g_minlot_332 = MarketInfo(Symbol(), MODE_MINLOT);
   if (g_minlot_332 / 0.01 == 1.0) gi_356 = 2;
   else gi_356 = 1;
   if (10.0 * MarketInfo(Symbol(), MODE_LOTSTEP) < 1.0) gi_356 = 2;
   else gi_356 = 1;
   if (Digits == 5 || Digits == 3 || Symbol() == "GOLD" || Symbol() == "GOLD." || Symbol() == "GOLDm") {
      gi_360 = 10;
      g_slippage_364 = 100;
   } else gi_360 = 1;
   gd_316 = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), gi_356);
   gd_324 = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), gi_356);
   gi_372 = NormalizeDouble(MarketInfo(Symbol(), MODE_STOPLEVEL), 2);
   gi_368 = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), 2);
   if (gi_312 * gi_360 < gi_372 + gi_368 && gi_312 != 0) gi_312 = (gi_372 + gi_368) / gi_360;
   f0_2();
   if (g_count_432 == 0 && g_count_428 > 0) {
      f0_0(4);
      f0_0(5);
   }
   if (gd_256 != 0.0 && f0_1() >= gd_256 && g_count_432 > 0) {
      f0_0(7);
      Alert("TP IN MONEY");
   }
   if (gd_264 != 0.0 && f0_1() <= (-gd_264) && g_count_432 > 0) {
      f0_0(7);
      Alert("SL IN MONEY");
   }
   f0_2();
   if (g_count_488 < 2) {
      f0_2();
      if (gi_508 > g_count_432) f0_0(7);
      f0_2();
      gi_508 = g_count_432;
   }
   f0_2();
   if (g_count_432 == 0 && g_count_428 == 0 && f0_9()) {
      for (int count_0 = 0; count_0 < 100; count_0++) {
         f0_2();
         RefreshRates();
         if (g_count_440 > 0 && g_count_444 > 0) break;
         if (g_count_440 == 0) {
            if (f0_7(Symbol(), OP_BUY, Blue, f0_6(0), g_slippage_364, Ask, 0, 0, f0_5(0), "01", Magic)) g_datetime_456 = iTime(Symbol(), 0, 0);
            else Sleep(1000);
         }
         if (g_count_444 == 0) {
            if (f0_7(Symbol(), OP_SELL, Red, f0_6(0), g_slippage_364, Bid, 0, 0, f0_5(0), "01", Magic)) {
               g_datetime_456 = iTime(Symbol(), 0, 0);
               continue;
            }
            Sleep(1000);
         }
      }
   }
   f0_2();
   if (g_count_488 < 2 && g_count_432 > 0 && g_count_432 < Max_Level && g_count_428 == 0) {
      gd_476 = g_order_open_price_408 - f0_4(g_count_432) * gi_360 * Point;
      if (g_cmd_424 == OP_BUY && Ask - gd_476 > gi_372 * Point)
         if (f0_7(Symbol(), OP_SELLSTOP, Red, f0_6(g_count_432), g_slippage_364, gd_476, 0, 0, f0_5(g_count_432), "", Magic)) g_datetime_456 = iTime(Symbol(), 0, 0);
      if (g_cmd_424 == OP_BUY && Bid <= gd_476)
         if (f0_7(Symbol(), OP_SELL, Red, f0_6(g_count_432), g_slippage_364, Bid, 0, 0, f0_5(g_count_432), "", Magic)) g_datetime_456 = iTime(Symbol(), 0, 0);
      gd_476 = g_order_open_price_408 + f0_4(g_count_432) * gi_360 * Point;
      if (g_cmd_424 == OP_SELL && gd_476 - Bid > gi_372 * Point)
         if (f0_7(Symbol(), OP_BUYSTOP, Blue, f0_6(g_count_432), g_slippage_364, gd_476, 0, 0, f0_5(g_count_432), "", Magic)) g_datetime_456 = iTime(Symbol(), 0, 0);
      if (g_cmd_424 == OP_SELL && Ask >= gd_476)
         if (f0_7(Symbol(), OP_BUY, Red, f0_6(g_count_432), g_slippage_364, Bid, 0, 0, f0_5(g_count_432), "", Magic)) g_datetime_456 = iTime(Symbol(), 0, 0);
   }
   f0_2();
   if (g_count_488 < 2) {
      if (g_count_440 > 0) f0_11(OP_BUY, g_order_takeprofit_492);
      if (g_count_444 > 0) f0_11(OP_SELL, g_order_takeprofit_500);
      if (g_count_444 > 0) f0_3(OP_BUY, g_order_takeprofit_500 - gi_368 * Point);
      if (g_count_440 > 0) f0_3(OP_SELL, g_order_takeprofit_492 + gi_368 * Point);
      f0_2();
      if (gi_508 > g_count_432) f0_0(7);
      f0_2();
      gi_508 = g_count_432;
   }
   f0_8(1, "MAGIC", DoubleToStr(Magic, 0));
   f0_8(2, "NAMA", AccountName());
   f0_8(3, "No. ACC", AccountNumber());
   f0_8(4, "BROKER", AccountCompany());
   f0_8(5, "LEVERAGE", "1:" + DoubleToStr(AccountLeverage(), 0));
   f0_8(6, "BALANCE", DoubleToStr(AccountBalance(), 2));
   f0_8(7, "EQUITY", DoubleToStr(AccountEquity(), 2));
   return (0);
}
		 				   		  		 		 	  	    	 		 		 		    			  		 							 	 					 	 		 		  	 	   	      		 		     	     		 		 			   	 	   	 			 	    			 	    	 	
void f0_11(int a_cmd_0, double ad_4) {
   for (g_order_total_436 = OrdersTotal(); g_order_total_436 >= 0; g_order_total_436--) {
      if(!OrderSelect(g_order_total_436, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == a_cmd_0)
         if (NormalizeDouble(OrderTakeProfit(), Digits) != NormalizeDouble(ad_4, Digits)) 
         bool Ord_modi=OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(ad_4, Digits), 0, CLR_NONE);
   }
}
		  		    	    	 				 		   		  	 						   	 	 			 	 		 		 				 		 							    		  	 	  	 		  	 	   		  	 		  	  		  		     				  	  	 	 	 	 	    	
void f0_3(int a_cmd_0, double ad_4) {
   for (g_order_total_436 = OrdersTotal(); g_order_total_436 >= 0; g_order_total_436--) {
      if(!OrderSelect(g_order_total_436, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == a_cmd_0)
         if (NormalizeDouble(OrderStopLoss(), Digits) != NormalizeDouble(ad_4, Digits)) 
         bool Ord_modi=OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(ad_4, Digits), OrderTakeProfit(), 0, CLR_NONE);
   }
}
			 	  	     	   	 				   				   	 		 		    			 	   	   	  		   	  		 	 	 	   		 			 						 				   	 						 		  	 				 	   		  		 		     			 	 		
double f0_1() {
   double ld_ret_0 = 0;
   for (g_order_total_436 = 0; g_order_total_436 < OrdersTotal(); g_order_total_436++) {
      if(!OrderSelect(g_order_total_436, SELECT_BY_POS, MODE_TRADES)) continue;
      if ((OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY) || OrderType() == OP_SELL) ld_ret_0 = ld_ret_0 + OrderProfit() + OrderSwap() + OrderCommission();
   }
   return (ld_ret_0);
}
		 			    		   	 		 	 		    	  	 		 			   			 			 				 		 	 		 		 	 					  	 		  	    	 		 		 	   	   	 		 		  		   	     	 		  	    	 	 	      	
double f0_6(int ai_0) {
   double ld_4 = Lots_OP_10;
   switch (ai_0) {
   case 0:
      ld_4 = Lots_OP_1;
      break;
   case 1:
      ld_4 = Lots_OP_2;
      break;
   case 2:
      ld_4 = Lots_OP_3;
      break;
   case 3:
      ld_4 = Lots_OP_4;
      break;
   case 4:
      ld_4 = Lots_OP_5;
      break;
   case 5:
      ld_4 = Lots_OP_6;
      break;
   case 6:
      ld_4 = Lots_OP_7;
      break;
   case 7:
      ld_4 = Lots_OP_8;
      break;
   case 8:
      ld_4 = Lots_OP_9;
      break;
   case 9:
      ld_4 = Lots_OP_10;
   }
   gd_316 = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), gi_356);
   gd_324 = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), gi_356);
   if (ld_4 < gd_316) ld_4 = gd_316;
   if (ld_4 > gd_324) ld_4 = gd_324;
   ld_4 = NormalizeDouble(ld_4, gi_356);
   return (ld_4);
}
	 		 					 		 	 	       			   	 	    	 			 	     	 	 		  	   		  	   	   					 		 	 	  	  		   			  	  	  		  	  		   				   			 		 			 	 	 	 		 
double f0_5(int ai_0) {
   double ld_ret_4 = TakeProfit_10;
   switch (ai_0) {
   case 0:
      ld_ret_4 = TakeProfit_1;
      break;
   case 1:
      ld_ret_4 = TakeProfit_2;
      break;
   case 2:
      ld_ret_4 = TakeProfit_3;
      break;
   case 3:
      ld_ret_4 = TakeProfit_4;
      break;
   case 4:
      ld_ret_4 = TakeProfit_5;
      break;
   case 5:
      ld_ret_4 = TakeProfit_6;
      break;
   case 6:
      ld_ret_4 = TakeProfit_7;
      break;
   case 7:
      ld_ret_4 = TakeProfit_8;
      break;
   case 8:
      ld_ret_4 = TakeProfit_9;
      break;
   case 9:
      ld_ret_4 = TakeProfit_10;
   }
   if (ld_ret_4 * gi_360 < gi_372 && ld_ret_4 != 0.0) ld_ret_4 = gi_372 / gi_360;
   return (ld_ret_4);
}
	  		 	 				 				 	 		 			  					 	 	   						 	 				 		 		 	 		 		 	  	 	 	    	    	     			  			  	     					 	  			 			 	 	  	    			    		  
double f0_4(int ai_0) {
   double ld_ret_4 = Step_10;
   switch (ai_0) {
   case 1:
      ld_ret_4 = Step_2;
      break;
   case 2:
      ld_ret_4 = Step_3;
      break;
   case 3:
      ld_ret_4 = Step_4;
      break;
   case 4:
      ld_ret_4 = Step_5;
      break;
   case 5:
      ld_ret_4 = Step_6;
      break;
   case 6:
      ld_ret_4 = Step_7;
      break;
   case 7:
      ld_ret_4 = Step_8;
      break;
   case 8:
      ld_ret_4 = Step_9;
      break;
   case 9:
      ld_ret_4 = Step_10;
   }
   if (ld_ret_4 * gi_360 < gi_372 && ld_ret_4 != 0.0) ld_ret_4 = gi_372 / gi_360;
   return (ld_ret_4);
}
	 				  		 	   		   	 					 	  		   			 		 		 		 	 			 	 	  		 	 	  				 			 		 	 	   	   			 	 		    	   			  	 		 	   		  		   		  	 		 	      
void f0_8(int ai_0, string as_4, string as_12) {
   int li_20;
   int li_24;
   if ((!IsTradeAllowed()) || !IsExpertEnabled()) {
      ObjectDelete("baris0");
      return;
   }
   switch (ai_0) {
   case 1:
      li_20 = 40;
      li_24 = 60;
      break;
   case 2:
      li_20 = 40;
      li_24 = 75;
      break;
   case 3:
      li_20 = 40;
      li_24 = 90;
      break;
   case 4:
      li_20 = 40;
      li_24 = 105;
      break;
   case 5:
      li_20 = 40;
      li_24 = 120;
      break;
   case 6:
      li_20 = 40;
      li_24 = 135;
      break;
   case 7:
      li_20 = 40;
      li_24 = 150;
      break;
   case 8:
      li_20 = 40;
      li_24 = 165;
      break;
   case 9:
      li_20 = 40;
      li_24 = 180;
      break;
   case 10:
      li_20 = 40;
      li_24 = 195;
      break;
   case 11:
      li_20 = 40;
      li_24 = 210;
      break;
   case 12:
      li_20 = 40;
      li_24 = 225;
      break;
   case 13:
      li_20 = 40;
      li_24 = 240;
      break;
   case 14:
      li_20 = 40;
      li_24 = 255;
      break;
   case 15:
      li_20 = 40;
      li_24 = 270;
      break;
   case 16:
      li_20 = 40;
      li_24 = 285;
      break;
   case 17:
      li_20 = 40;
      li_24 = 300;
   }
   f0_10("baris0", WindowExpertName() + " IS RUNNING", 10, 40, 20, Yellow, 0);
   f0_10("baris00", "", 8, 40, 10, Yellow, 2);
   f0_10("baris" + ai_0, as_4, 8, li_20, li_24, Yellow, 0);
   f0_10("baris_" + ai_0, ":", 8, li_20 + 150, li_24, Yellow, 0);
   f0_10("baris-" + ai_0, as_12, 8, li_20 + 160, li_24, Yellow, 0);
}
	   			  		   		  			  	 	 		 		  				   		 	  				 																		 			   	     	    	   	    			    	   	 				 		 	  						 		 	 			   	  	 	
void f0_10(string a_name_0, string a_text_8, int a_fontsize_16, int a_x_20, int a_y_24, color a_color_28, int a_corner_32) {
   if (ObjectFind(a_name_0) < 0) ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_32);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_20);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_24);
   ObjectSetText(a_name_0, a_text_8, a_fontsize_16, "Tahoma", a_color_28);
}
	 	 		   	     	   		 		 				  	   				  	  	 				  		 			 			 			 								  		   		  	 	 	 	 	  	 	  	 	 	 	  						    	 			  				 	 	  		    	
int f0_7(string a_symbol_0, int a_cmd_8, color a_color_12, double a_lots_16, double a_slippage_24, double a_price_32, int ai_40, double ad_44, double ad_52, string a_comment_60, int a_magic_68) {
   double price_72;
   double price_80;
   bool bool_92;
   int ticket_88 = 0;
   RefreshRates();
   RefreshRates();
   if (a_cmd_8 == OP_BUY) a_price_32 = Ask;
   if (a_cmd_8 == OP_SELL) a_price_32 = Bid;
   gi_372 = NormalizeDouble(MarketInfo(Symbol(), MODE_STOPLEVEL), 0);
   gi_368 = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), 0);
   ticket_88 = OrderSend(a_symbol_0, a_cmd_8, a_lots_16, a_price_32, a_slippage_24, 0, 0, a_comment_60, a_magic_68, 0, a_color_12);
   if (ticket_88 < 0) Sleep(1000);
   else {
      if (!(OrderSelect(ticket_88, SELECT_BY_TICKET, MODE_TRADES))) return (1);
      if (a_cmd_8 == OP_BUY || a_cmd_8 == OP_BUYLIMIT || a_cmd_8 == OP_BUYSTOP) {
         if (ad_52 * gi_360 > gi_372 && (!ai_40)) price_72 = OrderOpenPrice() + ad_52 * gi_360 * Point;
         else price_72 = 0;
         if (ad_44 * gi_360 > gi_372 + gi_368 && (!ai_40)) price_80 = OrderOpenPrice() - ad_44 * gi_360 * Point;
         else price_80 = 0;
         if (ad_52 == 0.0) price_72 = 0;
         if (ad_44 == 0.0) price_80 = 0;
      }
      if (a_cmd_8 == OP_SELL || a_cmd_8 == OP_SELLLIMIT || a_cmd_8 == OP_SELLSTOP) {
         if (ad_52 * gi_360 > gi_372 && (!ai_40)) price_72 = OrderOpenPrice() - ad_52 * gi_360 * Point;
         else price_72 = 0;
         if (ad_44 * gi_360 > gi_372 + gi_368 && (!ai_40)) price_80 = OrderOpenPrice() + ad_44 * gi_360 * Point;
         else price_80 = 0;
         if (ad_52 == 0.0) price_72 = 0;
         if (ad_44 == 0.0) price_80 = 0;
      }
      while (bool_92 == FALSE && price_80 != 0.0 && price_72 != 0.0) {
         bool_92 = OrderModify(ticket_88, OrderOpenPrice(), price_80, price_72, 0, CLR_NONE);
         if (bool_92 == FALSE) Sleep(1000);
      }
      while (bool_92 == FALSE && price_80 != 0.0 && price_72 == 0.0) {
         bool_92 = OrderModify(ticket_88, OrderOpenPrice(), price_80, OrderTakeProfit(), 0, CLR_NONE);
         if (bool_92 == FALSE) Sleep(1000);
      }
      while (bool_92 == FALSE && price_80 == 0.0 && price_72 != 0.0) {
         bool_92 = OrderModify(ticket_88, OrderOpenPrice(), OrderStopLoss(), price_72, 0, CLR_NONE);
         if (bool_92 == FALSE) Sleep(1000);
      }
      bool_92 = FALSE;
      return (1);
   }
   return (0);
}
			 	 	      			 	 			 	  						 	 		       		 		   	 			  		 			  		  		 	      			 	  			 		     	 	  			 					 					    		 	 	 		  		 			 		 	
int f0_9() {
   gi_292 = EndHour + gi_300;
   gi_296 = StartHour + gi_300;
   if (StartHour + gi_300 < 0) gi_296 = StartHour + gi_300 + 24;
   if (EndHour + gi_300 < 0) gi_292 = EndHour + gi_300 + 24;
   if (StartHour + gi_300 > 24) gi_296 = StartHour + gi_300 - 24;
   if (EndHour + gi_300 > 24) gi_292 = EndHour + gi_300 - 24;
   if (Use_TimeFilter == FALSE) {
      gs_unused_304 = "";
      return (1);
   }
   if (gi_296 < gi_292) {
      if (Hour() >= gi_296 && Hour() < gi_292) {
         gs_unused_304 = "";
         return (1);
      }
      gs_unused_304 = "WARNING: Trading diluar Time Filter, No Open Position\n";
      return (0);
   }
   if (gi_296 > gi_292) {
      if (Hour() >= gi_296 || Hour() < gi_292) {
         gs_unused_304 = "";
         return (1);
      }
      gs_unused_304 = "WARNING: Trading diluar Time Filter, No Open Position\n";
      return (0);
   }
   return (0);
}
			 		 	         	 		 	   			    	 					    	 	 	   		  	  			  	  				 	 	  			 			  					 	 		   	  					 	   	 			  	   			 		 		 	   			   		
void f0_2() {
   g_count_432 = 0;
   g_count_440 = 0;
   g_count_444 = 0;
   g_count_428 = 0;
   g_count_488 = 0;
   for (g_order_total_436 = 0; g_order_total_436 < OrdersTotal(); g_order_total_436++) {
      if(!OrderSelect(g_order_total_436, SELECT_BY_POS, MODE_TRADES)) continue;
      if ((OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY) || OrderType() == OP_SELL) {
         g_count_432++;
         g_order_open_price_408 = OrderOpenPrice();
         g_order_lots_416 = OrderLots();
         g_cmd_424 = OrderType();
      }
      if ((OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderComment() == "01" && OrderType() == OP_BUY) || OrderType() == OP_SELL) g_count_488++;
      if ((OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUYLIMIT) || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT) g_count_428++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY) {
         g_count_440++;
         g_order_open_price_400 = OrderOpenPrice();
         g_order_lots_392 = OrderLots();
         g_order_takeprofit_492 = OrderTakeProfit();
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELL) {
         g_count_444++;
         g_order_open_price_384 = OrderOpenPrice();
         g_order_lots_376 = OrderLots();
         g_order_takeprofit_500 = OrderTakeProfit();
      }
   }
}
			  	 		   	   		 	  	 	 		    		 	 				     	      	     	 	     	 		   	 									 		 		   			  		 		 		       		   		  	 	 	  				  					  	 
void f0_0(int ai_0) {
   int count_4;
   g_is_closed_448 = FALSE;
   g_is_deleted_452 = FALSE;
   for (g_order_total_436 = OrdersTotal(); g_order_total_436 >= 0; g_order_total_436--) {
      if(!OrderSelect(g_order_total_436, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if ((OrderType() == OP_BUY && ai_0 == 0) || ai_0 == 7) {
            count_4 = 0;
            while (g_is_closed_448 == 0) {
               RefreshRates();
               g_is_closed_448 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), g_slippage_364, Blue);
               if (g_is_closed_448 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) g_is_closed_448 = TRUE;
            }
            g_is_closed_448 = FALSE;
         }
         if ((OrderType() == OP_SELL && ai_0 == 1) || ai_0 == 7) {
            count_4 = 0;
            while (g_is_closed_448 == 0) {
               RefreshRates();
               g_is_closed_448 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), g_slippage_364, Red);
               if (g_is_closed_448 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) g_is_closed_448 = TRUE;
            }
            g_is_closed_448 = FALSE;
         }
      }
   }
   for (g_order_total_436 = OrdersTotal(); g_order_total_436 >= 0; g_order_total_436--) {
      if(!OrderSelect(g_order_total_436, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if ((OrderType() == OP_BUYLIMIT && ai_0 == 2) || ai_0 == 7) {
            count_4 = 0;
            while (g_is_deleted_452 == 0) {
               RefreshRates();
               g_is_deleted_452 = OrderDelete(OrderTicket());
               if (g_is_deleted_452 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) g_is_deleted_452 = TRUE;
            }
            g_is_deleted_452 = FALSE;
         }
         if ((OrderType() == OP_SELLLIMIT && ai_0 == 3) || ai_0 == 7) {
            count_4 = 0;
            while (g_is_deleted_452 == 0) {
               RefreshRates();
               g_is_deleted_452 = OrderDelete(OrderTicket());
               if (g_is_deleted_452 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) g_is_deleted_452 = TRUE;
            }
            g_is_deleted_452 = FALSE;
         }
         if ((OrderType() == OP_BUYSTOP && ai_0 == 4) || ai_0 == 7) {
            count_4 = 0;
            while (g_is_deleted_452 == 0) {
               RefreshRates();
               g_is_deleted_452 = OrderDelete(OrderTicket());
               if (g_is_deleted_452 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) g_is_deleted_452 = TRUE;
            }
            g_is_deleted_452 = FALSE;
         }
         if ((OrderType() == OP_SELLSTOP && ai_0 == 5) || ai_0 == 7) {
            count_4 = 0;
            while (g_is_deleted_452 == 0) {
               RefreshRates();
               g_is_deleted_452 = OrderDelete(OrderTicket());
               if (g_is_deleted_452 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) g_is_deleted_452 = TRUE;
            }
            g_is_deleted_452 = FALSE;
         }
      }
   }
}