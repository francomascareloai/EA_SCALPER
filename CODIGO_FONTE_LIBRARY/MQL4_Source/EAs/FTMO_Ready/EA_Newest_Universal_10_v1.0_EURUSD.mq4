//=============================================================================================
//Decompiled by lptuyen at www.forexisbiz.com (FIB Forum)
//Profile: http://www.forexisbiz.com/member.php/11057-lptuyen?tab=aboutme#aboutme
//Email: Lptuyen_fx@yahoo.com
//Another forum: lptuyen at WWI
//Profile: http://worldwide-invest.org/members/48543-lptuyen?tab=aboutme#aboutme
//=============================================================================================

//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import "SaxoLib.dll"
   void GetRatesSaxoByCode(string a0, string a1);
   void GetRatesGTByCode(string a0, string a1);
   void initialize();
#import

string G_text_76 = "www.westernpips.com || Newest Universal 10 : Global Trade Station 2, Saxo Bank";
extern string settings1 = "Настройка валютной пары";
extern string symbol1 = "EURUSD";
extern double MinimumLevel = 4.0;
extern int sdvig_bid = 0;
extern int Magic = 401;
extern double Slippage = 1.0;
extern string settings2 = "Мани менеджмент";
extern int RiskPercent = 0;
extern double Lots = 0.1;
extern double max_Lots = 99.9;
extern int StopLoss = 15;
int Gi_156;
extern int TakeProfit = 50;
extern double FixTP = 1.0;
extern double FixSL = 7.0;
extern bool useSLTP = TRUE;
extern int NTrades = 3;
extern string settings3 = "Настройка режима хеджирования позиций";
extern bool UseHedge = TRUE;
extern int TimeRem = 240;
extern string settings4 = "Настройка режима ручной торговли";
extern bool HandOperate = TRUE;
extern int MarketOrInstant = 1;
extern string settings5 = "Выбор источников котировок";
extern bool UseGTS2 = FALSE;
extern bool UseSaxoTrader = TRUE;
double Gd_236;
int Gi_244 = 0;
int Gi_248 = 0;
bool Gi_252 = TRUE;
bool Gi_256 = TRUE;
bool Gi_260 = TRUE;
bool Gi_264 = FALSE;
int Gi_unused_268 = 1;
string G_symbol_272 = "";
string Gs_unused_280 = "";
string Gs_dummy_288;
string Gs_dummy_296;
string Gs_304;
string Gs_dummy_312;
string G_symbol_320;
string G_text_328;
string Gs_dummy_336;
string Gs_dummy_344;
int Gi_352 = 3;
int Gi_356 = 300;
int Gi_360 = 1;
int Gi_364;
int G_fontsize_368;
int G_fontsize_372;
int G_digits_376;
int Gi_380;
int G_ticket_392;
int G_pos_396;
int G_count_400;
int Gi_unused_404;
double Gd_408 = 0.0;
double G_point_440;
double Gd_448;
double Gd_456;
double Gd_464;
double Gd_472;
double Gd_480;
double Gd_496;
double Gd_504;
double Gd_512;
double Gd_520;
double Gd_528;
double Gd_552;
double G_bid_560;
double G_ask_568;
double G_marginrequired_576;
double G_lotstep_584;
double Gd_592;
double Gd_600;
int G_color_608 = Green;
double Gd_612;
double Gd_620;
string Gs_644 = "111111111111111111111111111111111111111111111111111111111111111111111111111111";
bool Gi_652;
bool Gi_656;
bool Gi_660;
bool Gi_664;
bool Gi_668;
bool Gi_672;
int Gi_676;
int Gi_680;
int Gi_684;
int Gi_688;
int Gi_692;
int Gi_696;
int Gi_700;
int Gi_704;
int Gi_708;
int Gi_712;
int Gi_716;
int Gi_720;
double Gd_724;
double Gd_732;
double Gd_740;

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectDelete("RMTGL");
   ObjectDelete("bid_saxo");
   ObjectDelete("bid_label");
   ObjectDelete("ask_label");
   ObjectDelete("ask_saxo");
   ObjectsDeleteAll();
   Comment("");
   return (0);
}
	 	 	 	  	   			 	  		 	  	    	 	 	 	    	 	    	    		  				  	 		  	 	   		 			 	 					 		 									   			 									 	 						 	  		  					 		 
// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double price_24;
   double price_32;
   double Ld_40;
   double Ld_48;
   string Ls_unused_56;
   string Ls_unused_68;
   string Ls_76;
   G_symbol_320 = "";
   Gi_unused_404 = 0;
   int Li_4 = GetTickCount();
   if (HandOperate) Magic = 0;
   G_marginrequired_576 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   G_lotstep_584 = MarketInfo(Symbol(), MODE_LOTSTEP);
   Gd_592 = MarketInfo(Symbol(), MODE_MINLOT);
   Gd_600 = MarketInfo(Symbol(), MODE_MAXLOT);
   bool Li_64 = TRUE;
   while (IsStopped() == FALSE) {
      if (AccountEquity() != 0.0 && Li_64 == TRUE) {
         f0_14();
         f0_13();
         Li_64 = FALSE;
      }
      Gd_480 = 0;
      G_text_328 = "";
      G_symbol_320 = Symbol();
      RefreshRates();
      G_bid_560 = MarketInfo(G_symbol_320, MODE_BID);
      G_ask_568 = MarketInfo(G_symbol_320, MODE_ASK);
      G_digits_376 = MarketInfo(G_symbol_320, MODE_DIGITS);
      if (G_digits_376 == 3) {
         G_digits_376 = 2;
         Slippage = 10.0 * Slippage;
      }
      if (G_digits_376 == 5) {
         G_digits_376 = 4;
         Slippage = 10.0 * Slippage;
      }
      G_point_440 = MarketInfo(G_symbol_320, MODE_POINT);
      if (G_point_440 == 0.001) G_point_440 = 0.01;
      if (G_point_440 == 0.00001) G_point_440 = 0.0001;
      if (G_digits_376 == 0 && G_point_440 == 0.0) {
         G_text_328 = G_text_328 + G_symbol_320 + " not present" 
         + "\n";
         return (0);
      }
      if (UseGTS2) GetRatesGTByCode(StringSubstr(symbol1, 0, 6), Gs_644);
      if (UseSaxoTrader) GetRatesSaxoByCode(StringSubstr(symbol1, 0, 6), Gs_644);
      Gd_612 = f0_2(Gs_644, 0);
      Gd_620 = f0_2(Gs_644, 1);
      Gd_472 = Gd_612 + sdvig_bid * G_point_440;
      Gd_472 = NormalizeDouble(Gd_472, MarketInfo(G_symbol_320, MODE_DIGITS));
      Gd_504 = Gd_472;
      Gd_496 = Gd_620 + sdvig_bid * G_point_440;
      Gd_496 = NormalizeDouble(Gd_496, MarketInfo(G_symbol_320, MODE_DIGITS));
      GlobalVariableSet(G_symbol_320 + "_bid", Gd_472);
      GlobalVariableSet(G_symbol_320 + "_ask", Gd_496);
      Gd_456 = (NormalizeDouble(G_ask_568, MarketInfo(G_symbol_320, MODE_DIGITS)) - NormalizeDouble(G_bid_560, MarketInfo(G_symbol_320, MODE_DIGITS))) / G_point_440;
      if (Gi_248 > 0) Gd_456 = Gi_248;
      Gd_480 = (Gd_472 - NormalizeDouble(G_bid_560, MarketInfo(G_symbol_320, MODE_DIGITS))) / G_point_440;
      Gd_408 = (Gd_496 - Gd_472) / G_point_440;
      f0_15();
      if (MathAbs(Gd_480) >= Gi_356) Gd_480 = 0;
      Gi_156 = StopLoss + Gd_456;
      Gd_236 = FixSL + Gd_456;
      Ld_40 = TakeProfit;
      Ld_48 = Gi_156;
      if (HandOperate) Magic = 0;
      if (G_digits_376 == 0 && G_point_440 == 0.0) continue;
      f0_1();
      TakeProfit = Ld_40;
      Gi_156 = Ld_48;
      if (Gd_504 > 0.0) {
         G_count_400 = 0;
         if (OrdersTotal() > 0) {
            for (G_pos_396 = 0; G_pos_396 < OrdersTotal(); G_pos_396++) {
               OrderSelect(G_pos_396, SELECT_BY_POS, MODE_TRADES);
               if (OrderSymbol() == G_symbol_320 && OrderMagicNumber() == Magic) G_count_400++;
            }
         }
         if (G_count_400 < NTrades && MathAbs(Gd_480) >= Gd_448 + Gd_456 && GetTickCount() - Gi_364 >= 5000) {
            Gi_364 = GetTickCount();
            G_symbol_272 = G_symbol_320;
            price_24 = 0;
            price_32 = 0;
            f0_13();
            if (Gd_480 >= Gd_448) {
               if (useSLTP != TRUE && TakeProfit > 0) price_24 = G_ask_568 + TakeProfit * G_point_440;
               if (useSLTP != TRUE && Gi_156 > 0) price_32 = G_bid_560 - Gi_156 * G_point_440;
               if (!(AccountFreeMarginCheck(G_symbol_320, OP_BUY, Lots) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */)) {
                  G_ticket_392 = OrderSend(G_symbol_320, OP_BUY, Lots, G_ask_568 - Gi_244 * G_point_440, Slippage, price_32, price_24, "WP BUY" + DoubleToStr(Gd_480, 2), Magic, 0,
                     MediumBlue);
               }
               if (G_ticket_392 > 0) {
                  if (OrderSelect(G_ticket_392, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY ", G_symbol_320, " @ ", OrderOpenPrice());
                  else Print("BUY ", G_symbol_320, " error: ", ErrorDescription(GetLastError()));
               }
            }
            if (Gd_480 <= -Gd_448) {
               if (useSLTP != TRUE && TakeProfit > 0) price_24 = G_bid_560 - TakeProfit * G_point_440;
               if (useSLTP != TRUE && Gi_156 > 0) price_32 = G_ask_568 + Gi_156 * G_point_440;
               if (!(AccountFreeMarginCheck(G_symbol_320, OP_SELL, Lots) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */)) {
                  G_ticket_392 = OrderSend(G_symbol_320, OP_SELL, Lots, G_bid_560 + Gi_244 * G_point_440, Slippage, price_32, price_24, "WP SELL" + DoubleToStr(Gd_480, 2), Magic, 0,
                     Red);
               }
               if (G_ticket_392 > 0) {
                  if (OrderSelect(G_ticket_392, SELECT_BY_TICKET, MODE_TRADES)) Print("SELL ", G_symbol_320, " @ ", OrderOpenPrice());
                  else Print("SELL ", G_symbol_320, " error: ", ErrorDescription(GetLastError()));
               }
            }
            if (useSLTP == TRUE && Gi_156 > 0) {
               f0_0();
               f0_7();
            }
            if (useSLTP == TRUE && TakeProfit > 0) {
               f0_10();
               f0_9();
            }
         }
         if (UseHedge == FALSE) {
            if (FixTP != 0.0)
               if (MathAbs(Gd_480) <= (G_ask_568 - G_bid_560) / G_point_440) f0_6();
            if (Gd_236 != 0.0)
               if (MathAbs(Gd_480) < Gd_456) f0_3();
         }
         if (UseHedge == TRUE) {
            if (FixTP != 0.0)
               if (MathAbs(Gd_480) <= (G_ask_568 - G_bid_560) / G_point_440) f0_5();
            if (Gd_236 != 0.0)
               if (MathAbs(Gd_480) < Gd_456) f0_12();
         }
         Gi_380++;
         if (Gi_256 && Symbol() == G_symbol_320) {
            G_fontsize_368 = 14;
            G_fontsize_372 = 8;
            G_color_608 = Red;
            if (MathAbs(Gd_480) >= Gd_448 + Gd_456) {
               G_fontsize_368 = 26;
               G_fontsize_372 = 16;
               G_color_608 = Lime;
            }
            if (Gd_612 > 0.0) f0_4();
         }
      }
      ObjectCreate("1", OBJ_LABEL, 0, 0, 0);
      ObjectSet("1", OBJPROP_CORNER, 1);
      ObjectSet("1", OBJPROP_XDISTANCE, 20);
      ObjectSet("1", OBJPROP_YDISTANCE, 35);
      ObjectSetText("1", G_text_76, 8, "Arial", White);
      ObjectCreate("2", OBJ_LABEL, 0, 0, 0);
      ObjectSet("2", OBJPROP_CORNER, 1);
      ObjectSet("2", OBJPROP_XDISTANCE, 20);
      ObjectSet("2", OBJPROP_YDISTANCE, 50);
      ObjectSetText("2", "Last query -- " + DoubleToStr((GetTickCount() - Gi_364) / 1000, 0) + " s ago on " + G_symbol_272 
      + "\n\n", 8, "Arial", White);
      ObjectCreate("3", OBJ_LABEL, 0, 0, 0);
      ObjectSet("3", OBJPROP_CORNER, 1);
      ObjectSet("3", OBJPROP_XDISTANCE, 20);
      ObjectSet("3", OBJPROP_YDISTANCE, 65);
      ObjectSetText("3", "MinimumLevel=" + DoubleToStr(MinimumLevel, 1) 
      + "\n", 8, "Arial", White);
      ObjectCreate("4", OBJ_LABEL, 0, 0, 0);
      ObjectSet("4", OBJPROP_CORNER, 1);
      ObjectSet("4", OBJPROP_XDISTANCE, 20);
      ObjectSet("4", OBJPROP_YDISTANCE, 80);
      ObjectSetText("4", "RigidSL=" + DoubleToStr(Gi_156, 0) + ", RigidTP=" + DoubleToStr(TakeProfit, 0), 8, "Arial", White);
      if (UseGTS2) {
         ObjectCreate("5", OBJ_LABEL, 0, 0, 0);
         ObjectSet("5", OBJPROP_CORNER, 1);
         ObjectSet("5", OBJPROP_XDISTANCE, 20);
         ObjectSet("5", OBJPROP_YDISTANCE, 95);
         ObjectSetText("5", "Импорт из GTS2", 8, "Arial", Lime);
      }
      if (UseSaxoTrader) {
         ObjectCreate("5", OBJ_LABEL, 0, 0, 0);
         ObjectSet("5", OBJPROP_CORNER, 1);
         ObjectSet("5", OBJPROP_XDISTANCE, 20);
         ObjectSet("5", OBJPROP_YDISTANCE, 95);
         ObjectSetText("5", "Импорт из Saxo", 8, "Arial", Lime);
      }
      ObjectCreate("7", OBJ_LABEL, 0, 0, 0);
      ObjectSet("7", OBJPROP_CORNER, 1);
      ObjectSet("7", OBJPROP_XDISTANCE, 20);
      ObjectSet("7", OBJPROP_YDISTANCE, 125);
      ObjectSetText("7", "ScriptSL=" + DoubleToStr(Gd_236, 1) + ", ScriptTP=" + DoubleToStr(Gd_552, 1), 8, "Arial", White);
      ObjectCreate("8", OBJ_LABEL, 0, 0, 0);
      ObjectSet("8", OBJPROP_CORNER, 1);
      ObjectSet("8", OBJPROP_XDISTANCE, 20);
      ObjectSet("8", OBJPROP_YDISTANCE, 140);
      ObjectSetText("8", "RiskPercent=" + DoubleToStr(RiskPercent, 1) + ", Working lotsize=" + DoubleToStr(Lots, 2), 8, "Arial", White);
      if (UseHedge) {
         ObjectCreate("9", OBJ_LABEL, 0, 0, 0);
         ObjectSet("9", OBJPROP_CORNER, 1);
         ObjectSet("9", OBJPROP_XDISTANCE, 20);
         ObjectSet("9", OBJPROP_YDISTANCE, 155);
         ObjectSetText("9", "Используется режим HEADGE", 8, "Arial", Lime);
      } else {
         ObjectCreate("9", OBJ_LABEL, 0, 0, 0);
         ObjectSet("9", OBJPROP_CORNER, 1);
         ObjectSet("9", OBJPROP_XDISTANCE, 20);
         ObjectSet("9", OBJPROP_YDISTANCE, 155);
         ObjectSetText("9", "Режим HEADGE отключен", 8, "Arial", White);
      }
      if (HandOperate) {
         if (MarketOrInstant == 1) Ls_76 = "Instant Execution";
         if (MarketOrInstant == 0) Ls_76 = "Market Execution";
         ObjectCreate("10", OBJ_LABEL, 0, 0, 0);
         ObjectSet("10", OBJPROP_CORNER, 1);
         ObjectSet("10", OBJPROP_XDISTANCE, 20);
         ObjectSet("10", OBJPROP_YDISTANCE, 170);
         ObjectSetText("10", "Ручной режим включен" + " " + "||" + " " + Ls_76, 8, "Arial", Red);
      }
      if (Gd_612 == 0.0) ObjectsDeleteAll();
      if (Gd_612 > 0.0) {
         ObjectCreate("6", OBJ_LABEL, 0, 0, 0);
         ObjectSet("6", OBJPROP_CORNER, 1);
         ObjectSet("6", OBJPROP_XDISTANCE, 20);
         ObjectSet("6", OBJPROP_YDISTANCE, 110);
         ObjectSetText("6", G_text_328, 8, "Arial", White);
      }
      if (Gd_612 == 0.0 || Gd_612 > 1000.0) {
         ObjectCreate("6", OBJ_LABEL, 0, 0, 0);
         ObjectSet("6", OBJPROP_CORNER, 1);
         ObjectSet("6", OBJPROP_XDISTANCE, 20);
         ObjectSet("6", OBJPROP_YDISTANCE, 110);
         ObjectSetText("6", "Программа Uni-Quotes v1.0 НЕ НАЙДЕНА", 16, "Arial", Red);
      }
      if (Gd_612 == 0.0 || Gd_612 > 1000.0) {
         ObjectCreate("11", OBJ_LABEL, 0, 0, 0);
         ObjectSet("11", OBJPROP_CORNER, 1);
         ObjectSet("11", OBJPROP_XDISTANCE, 20);
         ObjectSet("11", OBJPROP_YDISTANCE, 130);
         ObjectSetText("11", "Обратитесь к разработчику", 16, "Arial", Red);
      }
      if (Gd_612 == 0.0 || Gd_612 > 1000.0) {
         ObjectCreate("12", OBJ_LABEL, 0, 0, 0);
         ObjectSet("12", OBJPROP_CORNER, 1);
         ObjectSet("12", OBJPROP_XDISTANCE, 20);
         ObjectSet("12", OBJPROP_YDISTANCE, 150);
         ObjectSetText("12", " www.westernpips.com", 16, "Arial", Red);
      }
      if (Gd_612 > 0.0) {
         ObjectDelete("11");
         ObjectDelete("12");
      }
      Gs_304 = Gs_304 + " " 
      + "\n";
      Comment(Gs_304);
      Gs_304 = "";
      Sleep(100);
   }
   return (0);
}
		 	  		  					   		 	   	 		     	 		 	 	 	   	  			 	  	   	 			  	 						 	  	 	 			 	 	   	 	    			 	    	 	    					   		   		 	 		     	  
// 2D70DA379B3FFB56BD104B348BA21C55
double f0_2(string As_0, int Ai_8) {
   double str2dbl_20;
   int Li_16 = StringFind(As_0, "!", 0);
   string Ls_28 = StringSubstr(As_0, Li_16 + 1);
   int Li_36 = StringFind(Ls_28, ",", 0);
   if (Li_36 > 0) Ls_28 = StringSetChar(Ls_28, Li_36, '.');
   Li_36 = StringFind(Ls_28, ",", 0);
   if (Li_36 > 0) Ls_28 = StringSetChar(Ls_28, Li_36, '.');
   Li_16 = StringFind(Ls_28, "!", 0);
   if (Ai_8 == 0) str2dbl_20 = StrToDouble(StringSubstr(Ls_28, 0, Li_16));
   else str2dbl_20 = StrToDouble(StringSubstr(Ls_28, Li_16 + 1, 7));
   return (str2dbl_20);
}
			 	 		     		     		   		        	 	 	 		 	  	      	  					 					  				  		  	  	 		 	  		 	 	 						 				 	 	 													     		 		 			 	  
// CA94D06264E6E12ADE176CD9EF33F89E
int f0_13() {
   double Ld_0;
   double Ld_8;
   double Ld_16;
   int Li_24;
   if (RiskPercent > 0) {
      Ld_0 = NormalizeDouble(NormalizeDouble(AccountEquity() / G_marginrequired_576, 2) * RiskPercent / 100.0, 2);
      Ld_8 = Ld_0;
      Li_24 = Ld_8 / G_lotstep_584;
      Ld_16 = Li_24 * G_lotstep_584;
      Gd_464 = Ld_16;
      if (Gd_464 < Gd_592) Gd_464 = Gd_592;
      if (Gd_464 > Gd_600) Gd_464 = Gd_600;
      Lots = Gd_464;
   }
   if (Lots > max_Lots) Lots = max_Lots;
   return (0);
}
						  	  	   		  		 						 				     	 							 	  	 	 				 	 	  		  	   	 		 		       	    		 	  	 	   			 		 	  	 	    		 	  		  		 	   	 		 		
// 9A2D793774C5C8094678898A3EA3E26D
int f0_10() {
   double price_4;
   if (OrdersTotal() > 0) {
      for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
         OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY) {
            if (OrderMagicNumber() == Magic) {
               price_4 = NormalizeDouble(OrderOpenPrice(), G_digits_376) + TakeProfit * G_point_440;
               if (NormalizeDouble(OrderTakeProfit(), G_digits_376) != price_4) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_4, 0, Red);
            }
         }
      }
   }
   return (0);
}
			 	  	     	      			  		   	    	 			 		 	 		         											   			  			 	  	 	  	  		   	 				 	 				   	 				 							      					 			    
// 8F84BBD29696AA3F0FECF7277445ADC1
int f0_9() {
   double price_4;
   if (OrdersTotal() > 0) {
      for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
         OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_SELL) {
            if (OrderMagicNumber() == Magic) {
               price_4 = NormalizeDouble(OrderOpenPrice(), G_digits_376) - TakeProfit * G_point_440;
               if (NormalizeDouble(OrderTakeProfit(), G_digits_376) != price_4) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_4, 0, Red);
            }
         }
      }
   }
   return (0);
}
	     	 			 							  	 		   	  							  	       			 	 			  	 	     		 	   	  	 	 							 			  		 	 	 		 	  	  		 	 	 		    	 						  	   	 	  			
// 1C5B70EF1C364E17D5B3030051898E78
int f0_0() {
   double price_4;
   if (OrdersTotal() > 0) {
      for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
         OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY) {
            if (OrderMagicNumber() == Magic) {
               price_4 = NormalizeDouble(OrderOpenPrice(), G_digits_376) - Gi_156 * G_point_440;
               if (NormalizeDouble(OrderStopLoss(), G_digits_376) != price_4) OrderModify(OrderTicket(), OrderOpenPrice(), price_4, OrderTakeProfit(), 0, Red);
            }
         }
      }
   }
   return (0);
}
	 		   	 	 			   	 	 		   			 	  	  				  		  		 	 		     	  				 	 	  		  	 		 		  		  		      			  	 	  	     			  	 		 	  	   	 	 						      
// 57C2581CEB81ED5C608C590596561472
int f0_7() {
   double price_4;
   if (OrdersTotal() > 0) {
      for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
         OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_SELL) {
            if (OrderMagicNumber() == Magic) {
               price_4 = NormalizeDouble(OrderOpenPrice(), G_digits_376) + Gi_156 * G_point_440;
               if (NormalizeDouble(OrderStopLoss(), G_digits_376) != price_4) OrderModify(OrderTicket(), OrderOpenPrice(), price_4, OrderTakeProfit(), 0, Red);
            }
         }
      }
   }
   return (0);
}
			  		 	   	 			      				 		 		  		   			  	  	   								     						  	     	   		 		   	 			  		  	 				 			  		  	  			  			         		 				
// 5681F3288DB688D43C03CC73B75970A3
void f0_6() {
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == G_symbol_320 && OrderMagicNumber() == Magic) {
            if (TimeCurrent() - OrderOpenTime() >= Gi_360) {
               if (OrderType() == OP_BUY) {
                  Gd_512 = MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice();
                  Gd_528 = Gd_552 * G_point_440;
                  Gd_528 = NormalizeDouble(Gd_528, G_digits_376);
                  if (Gd_512 >= Gd_528) {
                     OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID) + Gi_244 * G_point_440, Slippage);
                     f0_11();
                     return;
                  }
               }
               if (OrderType() == OP_SELL) {
                  Gd_520 = OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_ASK);
                  Gd_528 = Gd_552 * G_point_440;
                  Gd_528 = NormalizeDouble(Gd_528, G_digits_376);
                  if (Gd_520 >= Gd_528) {
                     OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK) - Gi_244 * G_point_440, Slippage);
                     f0_11();
                     return;
                  }
               }
            }
         }
      }
   }
}
			   		    			      	   		 	      			 	 		    	    	 	  			 	 						 				   	  	  				 	  	  	 	 		 			 			  	 	 		 							 		      	 		 		  	  
// 30D5655D01E1EB80F4482A408F5C9EAB
void f0_3() {
   for (int pos_16 = 0; pos_16 < OrdersTotal(); pos_16++) {
      if (OrderSelect(pos_16, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == G_symbol_320 && OrderMagicNumber() == Magic) {
            if (TimeCurrent() - OrderOpenTime() >= Gi_360) {
               if (OrderType() == OP_BUY) {
                  Gd_512 = OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_BID);
                  Gd_512 = NormalizeDouble(Gd_512, G_digits_376);
                  Gd_528 = Gd_236 * G_point_440;
                  Gd_528 = NormalizeDouble(Gd_528, G_digits_376);
                  if (Gd_512 >= Gd_528) {
                     OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID) + Gi_244 * G_point_440, Slippage);
                     f0_11();
                     return;
                  }
               }
               if (OrderType() == OP_SELL) {
                  Gd_520 = MarketInfo(OrderSymbol(), MODE_ASK) - OrderOpenPrice();
                  Gd_520 = NormalizeDouble(Gd_520, G_digits_376);
                  Gd_528 = Gd_236 * G_point_440;
                  Gd_528 = NormalizeDouble(Gd_528, G_digits_376);
                  if (Gd_520 >= Gd_528) {
                     OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK) - Gi_244 * G_point_440, Slippage);
                     f0_11();
                     return;
                  }
               }
            }
         }
      }
   }
}
	  	   							  				 		 	  		 	 			 					  	  							   	    			    	  	  		 		  		 		   		      	   	 		        	   	 	     	  				 			 	      	
// AAF9ED605D0193362321BA0DEF15C9B7
void f0_11() {
   string Ls_0;
   if (OrderType() == OP_BUY) Ls_0 = "BUY";
   if (OrderType() == OP_SELL) Ls_0 = "SELL";
   string str_concat_8 = StringConcatenate(AccountNumber(), " update");
   string str_concat_16 = StringConcatenate("OrderProfit ", DoubleToStr(OrderProfit(), 2), ", Balance ", DoubleToStr(AccountBalance(), 2), ", Equity ", DoubleToStr(AccountEquity(), 2), 
      "\n\n", "#", OrderTicket(), " ", Ls_0, " ", DoubleToStr(OrderLots(), 2), " ", G_symbol_320, " @ ", DoubleToStr(OrderOpenPrice(), G_digits_376), " close @ ", DoubleToStr(OrderClosePrice(), G_digits_376), 
   "\n\n", G_text_76);
   SendMail(str_concat_8, str_concat_16);
}
	 	 			 		    				  	  		 	  	 			 	    	 	 		  		   				 			     		 		     	  	 	 	  		 	 					 				 	 	 						 				 	   			 				  	    								
// 20259362CCDF54B0904EA564E702C7E0
int f0_1() {
   Gd_448 = MinimumLevel;
   if (Gi_252) {
      if (Gd_408 > 4.0) {
         if (Gd_408 > Gd_456) Gd_448 = MinimumLevel + (Gd_408 - Gd_456) / 2.0;
         if (2.0 * MathAbs(Gd_456) < MathAbs(Gd_408)) Gd_448 = MinimumLevel + (Gd_408 - Gd_456);
      }
   }
   Gd_552 = FixTP;
   if (Gd_456 < MathAbs(Gd_480)) Gd_552 = TakeProfit;
   if (Gd_448 < MinimumLevel) Gd_448 = MinimumLevel;
   G_text_328 = G_symbol_320 + " bid=" + DoubleToStr(Gd_472, 5) + " " + "(" + DoubleToStr(Gd_480, 1) + ") " + DoubleToStr(Gd_448 + Gd_456, 1) + " spread=" + DoubleToStr(Gd_408, 1) + " " + "(" + DoubleToStr(Gd_456, 1) + ")" 
   + "\n";
   return (0);
}
	 	 	   		   	 			  					 	   				 	 		 	 	 	 	 		     		 					   		        				 	 	 	 	 	 		  	 					  	 			  	 					    				 			  			  				  		
// DF6B9DB7C359D7510664659222237505
int f0_15() {
   double global_var_0 = GlobalVariableGet("proverka_bid_" + G_symbol_320);
   double global_var_8 = GlobalVariableGet("proverka_ask_" + G_symbol_320);
   double global_var_16 = GlobalVariableGet("proverka_tik_" + AccountNumber());
   if (Gd_472 == global_var_0 && Gd_496 == global_var_8) {
      if (GetTickCount() - global_var_16 > 1000 * Gi_352) {
         Gd_480 = 0;
         if (Gi_264) {
            Gs_304 = Gs_304 + G_symbol_320 + "Datafeed broke " + DoubleToStr((GetTickCount() - global_var_16) / 1000.0, 0) + " s ago" 
            + "\n";
         }
      }
   } else {
      GlobalVariableSet("proverka_bid_" + G_symbol_320, Gd_472);
      GlobalVariableSet("proverka_ask_" + G_symbol_320, Gd_496);
      GlobalVariableSet("proverka_tik_" + AccountNumber(), GetTickCount());
   }
   if (GetTickCount() - GlobalVariableGet("proverka_zapusk_") < 1000 * (Gi_352 * 2)) {
      Gd_480 = 0;
      if (Gd_612 > 0.0 && Gd_612 < 100.0) {
         Gs_304 = "==========" 
         + "\n";
         Gs_304 = Gs_304 + "ETA >> " + DoubleToStr((1000 * (Gi_352 * 2) - (GetTickCount() - GlobalVariableGet("proverka_zapusk_"))) / 1000.0, 0) + " seconds" 
         + "\n";
         Gs_304 = Gs_304 + "==========" 
         + "\n";
      }
   }
   return (0);
}
				  			  				 	  	 	  					   	   		 					   		  		 	 			  	 	 		 	 		 	 	 	      			       	   	  						   	   	  			 		  		 	  	 	 	  	   	 	
// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   initialize();
   Gs_304 = "";
   GlobalVariableSet("proverka_zapusk_", GetTickCount());
   Gi_364 = GetTickCount();
   double Ld_0 = NormalizeDouble(Bid, 2) - 0.02;
   G_symbol_272 = "no currency";
   return (0);
}
			   			   			 	    	  			 	   	  			 				    		   	 	 				 	 	 				 		 	   	     				    	  	   		 							  	   		 			 			 		 	    	 	  		  	 	
// 3ACA4AEDC82351568345A79B39A76820
int f0_4() {
   string Ls_unused_16;
   if (ObjectFind("bid_saxo") == -1) {
      ObjectCreate("bid_saxo", OBJ_HLINE, 0, TimeCurrent(), Gd_472);
      ObjectSet("bid_saxo", OBJPROP_COLOR, Yellow);
      ObjectSet("bid_saxo", OBJPROP_STYLE, STYLE_SOLID);
   }
   ObjectMove("bid_saxo", 0, TimeCurrent(), Gd_472);
   if (Gi_260)
      if (ObjectFind("bid label") == -1) ObjectCreate("bid label", OBJ_TEXT, 0, Time[0], Low[0] - 2.0 * G_point_440);
   if (Gd_480 >= 0.0) ObjectSetText("bid label", DoubleToStr(Gd_480, 1), G_fontsize_372, "Arial", Lime);
   else ObjectSetText("bid label", DoubleToStr(Gd_480, 1), G_fontsize_372, "Arial", Red);
   ObjectMove("bid label", 0, Time[0], Low[0] - 2.0 * G_point_440);
   if (ObjectFind("ask label") == -1) ObjectCreate("ask label", OBJ_TEXT, 0, Time[0], High[0] + 2.0 * G_point_440);
   ObjectSetText("ask label", DoubleToStr((Ask - Bid) / G_point_440, 1), 8, "Arial", Red);
   ObjectMove("ask label", 0, Time[0], High[0] + 2.0 * G_point_440);
   if (ObjectFind("RMTGL") == -1) {
      ObjectCreate("RMTGL", OBJ_LABEL, 0, 0, 0);
      ObjectSet("RMTGL", OBJPROP_CORNER, 1);
      ObjectSet("RMTGL", OBJPROP_XDISTANCE, 20);
      ObjectSet("RMTGL", OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText("RMTGL", DoubleToStr(Gd_480, 1), G_fontsize_368, "Arial", G_color_608);
   if (ObjectFind("ask_saxo") == -1) {
      ObjectCreate("ask_saxo", OBJ_HLINE, 0, TimeCurrent(), Gd_496);
      ObjectSet("ask_saxo", OBJPROP_COLOR, Red);
      ObjectSet("ask_saxo", OBJPROP_STYLE, STYLE_SOLID);
   }
   ObjectMove("ask_saxo", 0, TimeCurrent(), Gd_496);
   WindowRedraw();
   return (0);
}
	 			   		 	 	 			 						 		  				   		 	 			 	 		 	   		 	 			   	        					 	   	 	 	  	  	 		 		  	 	 	  	 		 		    	 		 			 				  		 	  		
// D9394066970E44AE252FD0347E58C03E
int f0_14() {
   G_marginrequired_576 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   G_lotstep_584 = MarketInfo(Symbol(), MODE_LOTSTEP);
   Gd_592 = MarketInfo(Symbol(), MODE_MINLOT);
   Gd_600 = MarketInfo(Symbol(), MODE_MAXLOT);
   if (G_marginrequired_576 == 0.0) {
      G_marginrequired_576 = 1000;
      Print("MODE_MARGINREQUIRED error");
   }
   if (G_lotstep_584 == 0.0) {
      G_lotstep_584 = 0.1;
      Print("MODE_LOTSTEP error");
   }
   if (Gd_592 == 0.0) {
      Gd_592 = 0.1;
      Print("MODE_MINLOT error");
   }
   if (Gd_600 == 0.0) {
      Gd_600 = 1000;
      Print("MODE_MAXLOT error");
   }
   return (0);
}
		 		 			 		 		 	 				  		 	    	 	  	 			 		  		 		  	 		  		 	 	    		 					    	  		   	 	 	     						  	 	     				 	  			 	 				 	    	 	 	
// 48276AF84C564EB7AAEB31D3FEA7228A
void f0_5() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == G_symbol_320 && OrderMagicNumber() == Magic) {
            if (OrderTicket() == Gi_676 || OrderTicket() == Gi_684 || OrderTicket() == Gi_692 || OrderTicket() == Gi_700 || OrderTicket() == Gi_708 || OrderTicket() == Gi_716) {
               if (OrderOpenTime() + TimeRem > TimeCurrent()) continue;
               if (OrderTicket() == Gi_676 && Gi_652 == TRUE) {
                  Print("Пара 1");
                  if (OrderCloseBy(Gi_676, Gi_680, White) == FALSE) break;
                  Gi_652 = FALSE;
                  Gi_676 = -1;
                  Gi_680 = -1;
               }
               if (OrderTicket() == Gi_684 && Gi_656 == TRUE) {
                  Print("Пара 2");
                  if (OrderCloseBy(Gi_684, Gi_688, White) == FALSE) break;
                  Gi_656 = FALSE;
                  Gi_684 = -1;
                  Gi_688 = -1;
               }
               if (OrderTicket() == Gi_692 && Gi_660 == TRUE) {
                  Print("Пара 3");
                  if (OrderCloseBy(Gi_692, Gi_696, White) == FALSE) break;
                  Gi_660 = FALSE;
                  Gi_692 = -1;
                  Gi_696 = -1;
               }
               if (OrderTicket() == Gi_700 && Gi_664 == TRUE) {
                  Print("Пара 4");
                  if (OrderCloseBy(Gi_700, Gi_704, White) == FALSE) break;
                  Gi_664 = FALSE;
                  Gi_700 = -1;
                  Gi_704 = -1;
               }
               if (OrderTicket() == Gi_708 && Gi_668 == TRUE) {
                  Print("Пара 5");
                  if (OrderCloseBy(Gi_708, Gi_712, White) == FALSE) break;
                  Gi_668 = FALSE;
                  Gi_708 = -1;
                  Gi_712 = -1;
               }
               if (!(OrderTicket() == Gi_716 && Gi_672 == TRUE)) continue;
               Print("Пара 6");
               if (OrderCloseBy(Gi_716, Gi_720, White) == FALSE) continue;
               Gi_672 = FALSE;
               Gi_716 = -1;
               Gi_720 = -1;
               continue;
            }
            if (OrderType() == OP_BUY) {
               Gd_724 = MarketInfo(OrderSymbol(), MODE_BID) - OrderOpenPrice();
               Gd_732 = Gd_552 * G_point_440;
               Gd_732 = NormalizeDouble(Gd_732, G_digits_376);
               if (Gd_724 >= Gd_732) {
                  Print(StringConcatenate("Лакируем ордер: ", OrderTicket(), " валюта: ", OrderSymbol()));
                  if (OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, Green) != TRUE) break;
                  if (Gi_652 == FALSE) {
                     while (true) {
                        Gi_652 = TRUE;
                        Gi_676 = OrderTicket();
                        Gi_680 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_680 > 0) {
                           OrderSelect(Gi_680, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_656 == FALSE) {
                     while (true) {
                        Gi_656 = TRUE;
                        Gi_684 = OrderTicket();
                        Gi_688 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_688 > 0) {
                           OrderSelect(Gi_688, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_660 == FALSE) {
                     while (true) {
                        Gi_660 = TRUE;
                        Gi_692 = OrderTicket();
                        Gi_696 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_696 > 0) {
                           OrderSelect(Gi_696, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_664 == FALSE) {
                     while (true) {
                        Gi_664 = TRUE;
                        Gi_700 = OrderTicket();
                        Gi_704 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_704 > 0) {
                           OrderSelect(Gi_704, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_668 == FALSE) {
                     while (true) {
                        Gi_668 = TRUE;
                        Gi_708 = OrderTicket();
                        Gi_712 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_712 > 0) {
                           OrderSelect(Gi_712, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_672 != FALSE) break;
                  while (true) {
                     Gi_672 = TRUE;
                     Gi_716 = OrderTicket();
                     Gi_720 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                     if (Gi_720 > 0) {
                        OrderSelect(Gi_720, SELECT_BY_TICKET, MODE_TRADES);
                        Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                        return;
                     }
                     if (f0_8(GetLastError()) == 1) continue;
                     break;
                  }
                  return;
               }
            }
            if (OrderType() == OP_SELL) {
               Gd_740 = OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_ASK);
               Gd_732 = Gd_552 * G_point_440;
               Gd_732 = NormalizeDouble(Gd_732, G_digits_376);
               if (Gd_740 >= Gd_732) {
                  Print(StringConcatenate("Лакируем ордер: ", OrderTicket(), " валюта: ", OrderSymbol()));
                  if (OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, Green) == TRUE) {
                     if (Gi_652 == FALSE) {
                        while (true) {
                           Gi_652 = TRUE;
                           Gi_676 = OrderTicket();
                           Gi_680 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_680 > 0) {
                              OrderSelect(Gi_680, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_656 == FALSE) {
                        while (true) {
                           Gi_656 = TRUE;
                           Gi_684 = OrderTicket();
                           Gi_688 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_688 > 0) {
                              OrderSelect(Gi_688, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_660 == FALSE) {
                        while (true) {
                           Gi_660 = TRUE;
                           Gi_692 = OrderTicket();
                           Gi_696 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_696 > 0) {
                              OrderSelect(Gi_696, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_664 == FALSE) {
                        while (true) {
                           Gi_664 = TRUE;
                           Gi_700 = OrderTicket();
                           Gi_704 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_704 > 0) {
                              OrderSelect(Gi_704, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_668 == FALSE) {
                        while (true) {
                           Gi_668 = TRUE;
                           Gi_708 = OrderTicket();
                           Gi_712 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_712 > 0) {
                              OrderSelect(Gi_712, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_672 == FALSE) {
                        while (true) {
                           Gi_672 = TRUE;
                           Gi_716 = OrderTicket();
                           Gi_720 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_720 > 0) {
                              OrderSelect(Gi_720, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        return;
                     }
                  }
               }
            }
         }
      }
   }
}
			 				      	     	    		  	     	   	 		 		 	     		  				  					 					  	   	  	  	 	  				 	 			 		 						 	 			 							 	     	  		 					  
// CA85900799069B7D247F5ADAD5BE4A02
void f0_12() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == G_symbol_320 && OrderMagicNumber() == Magic) {
            if (OrderTicket() == Gi_676 || OrderTicket() == Gi_684 || OrderTicket() == Gi_692 || OrderTicket() == Gi_700 || OrderTicket() == Gi_708 || OrderTicket() == Gi_716) {
               if (OrderOpenTime() + TimeRem > TimeCurrent()) continue;
               if (OrderTicket() == Gi_676 && Gi_652 == TRUE) {
                  Print("Пара 1");
                  if (OrderCloseBy(Gi_676, Gi_680, White) == FALSE) break;
                  Gi_652 = FALSE;
                  Gi_676 = -1;
                  Gi_680 = -1;
               }
               if (OrderTicket() == Gi_684 && Gi_656 == TRUE) {
                  Print("Пара 2");
                  if (OrderCloseBy(Gi_684, Gi_688, White) == FALSE) break;
                  Gi_656 = FALSE;
                  Gi_684 = -1;
                  Gi_688 = -1;
               }
               if (OrderTicket() == Gi_692 && Gi_660 == TRUE) {
                  Print("Пара 3");
                  if (OrderCloseBy(Gi_692, Gi_696, White) == FALSE) break;
                  Gi_660 = FALSE;
                  Gi_692 = -1;
                  Gi_696 = -1;
               }
               if (OrderTicket() == Gi_700 && Gi_664 == TRUE) {
                  Print("Пара 4");
                  if (OrderCloseBy(Gi_700, Gi_704, White) == FALSE) break;
                  Gi_664 = FALSE;
                  Gi_700 = -1;
                  Gi_704 = -1;
               }
               if (OrderTicket() == Gi_708 && Gi_668 == TRUE) {
                  Print("Пара 5");
                  if (OrderCloseBy(Gi_708, Gi_712, White) == FALSE) break;
                  Gi_668 = FALSE;
                  Gi_708 = -1;
                  Gi_712 = -1;
               }
               if (!(OrderTicket() == Gi_716 && Gi_672 == TRUE)) continue;
               Print("Пара 6");
               if (OrderCloseBy(Gi_716, Gi_720, White) == FALSE) continue;
               Gi_672 = FALSE;
               Gi_716 = -1;
               Gi_720 = -1;
               continue;
            }
            if (OrderType() == OP_BUY) {
               Gd_724 = OrderOpenPrice() - MarketInfo(OrderSymbol(), MODE_BID);
               Gd_724 = NormalizeDouble(Gd_724, G_digits_376);
               Gd_732 = Gd_236 * G_point_440;
               Gd_732 = NormalizeDouble(Gd_732, G_digits_376);
               if (Gd_724 >= Gd_732) {
                  Print(StringConcatenate("Лакируем ордер: ", OrderTicket(), " валюта: ", OrderSymbol()));
                  if (OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, Green) != TRUE) break;
                  if (Gi_652 == FALSE) {
                     while (true) {
                        Gi_652 = TRUE;
                        Gi_676 = OrderTicket();
                        Gi_680 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_680 > 0) {
                           OrderSelect(Gi_680, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_656 == FALSE) {
                     while (true) {
                        Gi_656 = TRUE;
                        Gi_684 = OrderTicket();
                        Gi_688 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_688 > 0) {
                           OrderSelect(Gi_688, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_660 == FALSE) {
                     while (true) {
                        Gi_660 = TRUE;
                        Gi_692 = OrderTicket();
                        Gi_696 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_696 > 0) {
                           OrderSelect(Gi_696, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_664 == FALSE) {
                     while (true) {
                        Gi_664 = TRUE;
                        Gi_700 = OrderTicket();
                        Gi_704 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_704 > 0) {
                           OrderSelect(Gi_704, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_668 == FALSE) {
                     while (true) {
                        Gi_668 = TRUE;
                        Gi_708 = OrderTicket();
                        Gi_712 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                        if (Gi_712 > 0) {
                           OrderSelect(Gi_712, SELECT_BY_TICKET, MODE_TRADES);
                           Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                           return;
                        }
                        if (f0_8(GetLastError()) == 1) continue;
                        break;
                     }
                     return;
                  }
                  if (Gi_672 != FALSE) break;
                  while (true) {
                     Gi_672 = TRUE;
                     Gi_716 = OrderTicket();
                     Gi_720 = OrderSend(G_symbol_320, OP_SELL, OrderLots(), MarketInfo(G_symbol_320, MODE_BID), 30, 0, 0, 0, Magic + 1, 0, Red);
                     if (Gi_720 > 0) {
                        OrderSelect(Gi_720, SELECT_BY_TICKET, MODE_TRADES);
                        Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                        return;
                     }
                     if (f0_8(GetLastError()) == 1) continue;
                     break;
                  }
                  return;
               }
            }
            if (OrderType() == OP_SELL) {
               Gd_740 = MarketInfo(OrderSymbol(), MODE_ASK) - OrderOpenPrice();
               Gd_740 = NormalizeDouble(Gd_740, G_digits_376);
               Gd_732 = Gd_236 * G_point_440;
               Gd_732 = NormalizeDouble(Gd_732, G_digits_376);
               if (Gd_740 >= Gd_732) {
                  Print(StringConcatenate("Лакируем ордер: ", OrderTicket(), " валюта: ", OrderSymbol()));
                  if (OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, Green) == TRUE) {
                     if (Gi_652 == FALSE) {
                        while (true) {
                           Gi_652 = TRUE;
                           Gi_676 = OrderTicket();
                           Gi_680 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_680 > 0) {
                              OrderSelect(Gi_680, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_656 == FALSE) {
                        while (true) {
                           Gi_656 = TRUE;
                           Gi_684 = OrderTicket();
                           Gi_688 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_688 > 0) {
                              OrderSelect(Gi_688, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_660 == FALSE) {
                        while (true) {
                           Gi_660 = TRUE;
                           Gi_692 = OrderTicket();
                           Gi_696 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_696 > 0) {
                              OrderSelect(Gi_696, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_664 == FALSE) {
                        while (true) {
                           Gi_664 = TRUE;
                           Gi_700 = OrderTicket();
                           Gi_704 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_704 > 0) {
                              OrderSelect(Gi_704, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_668 == FALSE) {
                        while (true) {
                           Gi_668 = TRUE;
                           Gi_708 = OrderTicket();
                           Gi_712 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_712 > 0) {
                              OrderSelect(Gi_712, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        continue;
                     }
                     if (Gi_672 == FALSE) {
                        while (true) {
                           Gi_672 = TRUE;
                           Gi_716 = OrderTicket();
                           Gi_720 = OrderSend(G_symbol_320, OP_BUY, OrderLots(), MarketInfo(G_symbol_320, MODE_ASK), 30, 0, 0, 0, Magic + 1, 0, Blue);
                           if (Gi_720 > 0) {
                              OrderSelect(Gi_720, SELECT_BY_TICKET, MODE_TRADES);
                              Print(StringConcatenate("Ордером ", OrderTicket(), " валюта: ", OrderSymbol()));
                              return;
                           }
                           if (f0_8(GetLastError()) == 1) continue;
                           break;
                        }
                        return;
                     }
                  }
               }
            }
         }
      }
   }
}
	 	    	 	  		   	   		   	 	 	  	 					  	   		 	  	     		 				 			  		    		 		 			  		 	    				 	 	  		    				 	 		 		 	   	   							     
// 87992A5CFB97515ED70257532FB1495D
int f0_8(int Ai_0) {
   switch (Ai_0) {
   case 4:
      Alert("Торговый сервер занят. Пробуем ещё раз..");
      Sleep(3000);
      return (1);
   case 129:
      Alert("Неправильная цена");
      RefreshRates();
      return (1);
   case 135:
      Alert("Цена изменилась. Пробуем ещё раз..");
      RefreshRates();
      return (1);
   case 136:
      Alert("Нет цен. Ждём новый тик..");
      while (RefreshRates() == FALSE) Sleep(1);
      return (1);
   case 137:
      Alert("Брокер занят. Пробуем ещё раз..");
      Sleep(3000);
      return (1);
   case 138:
      Alert("Ошибка цен");
      Sleep(3000);
      RefreshRates();
      return (1);
   case 146:
      Alert("Подсистема торговли занята. Пробуем ещё..");
      Sleep(500);
      return (1);
   case 2:
      Alert("Общая ошибка.");
      return (0);
   case 5:
      Alert("Старая версия терминала.");
      return (0);
   case 64:
      Alert("Счет заблокирован.");
      return (0);
   case 133:
      Alert("Торговля запрещена.");
      return (0);
   case 134:
      Alert("Недостаточно денег для совершения операции.");
      return (0);
   }
   Alert("Возникла ошибка ", Ai_0);
   return (0);
}