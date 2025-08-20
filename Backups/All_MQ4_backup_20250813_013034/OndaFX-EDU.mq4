/*
   2013-07-01 by Capella at http://worldwide-invest.org/
	- No need for DLL or autothentication (unused code commented out)
*/
#property copyright "Copyright © 2013, Andrea Salvatore"
#property link      "http://www.pimpmyea.com"

//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A

/*	
#import "Cerbero.dll"
   double aaa(int a0, double a1, double a2);
   double aaaa(int a0, double a1, double a2, double a3);
   double aaaaa(int a0, double a1, double a2, double a3, double a4);
   double bbb(int a0, double a1, double a2);
   double ccc(int a0, double a1, double a2);
   double cccc(int a0, double a1, double a2, double a3);
   double ccccc(int a0, double a1, double a2, double a3, double a4);
   double ddd(int a0, double a1, double a2);
   string eee(int a0, string a1, string a2);
   string eeee(int a0, string a1, string a2, string a3);
   string eeeee(int a0, string a1, string a2, string a3, string a4);
   int xxx(int a0);
   double test_aaa(int a0, double a1, double a2);
#import "wininet.dll"
   int InternetOpenA(string a0, int a1, string a2, string a3, int a4);
   int InternetOpenUrlA(int a0, string a1, string a2, int a3, int a4, int a5);
   int InternetReadFile(int a0, string a1, int a2, int& a3[]);
   int InternetCloseHandle(int a0);
#import
*/

string Gsa_76[12];
int Gia_80[12];
string Gsa_108[100];
int Gia_112[100];
int Gi_116 = 0;
int Gi_120 = 2000;
int Gi_124 = 60000;
int Gi_128 = 0;
int Gi_132 = 0;
int Gi_136 = 0;
bool Gi_140 = FALSE;
bool Gi_144 = FALSE;
bool Gi_148 = TRUE;
bool Gi_156 = FALSE;
int G_datetime_160 = 0;
int G_datetime_164 = 0;
bool Gi_168 = FALSE;
double Gd_172 = 0.0;
int Gi_180 = 86400;
string Gs_184 = "update.html";
string Gs_dummy_196;
int Gi_208 = 1;
string Gs_dummy_212;
int Gi_220 = 0;
int Gi_224 = 0;
int G_count_228 = 0;
string Gs_232;
int Gia_240[1];
//string Gs_248 = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
int Gia_256[64] = {65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47};
datetime G_time_264;
int Gi_268 = 16711680;
int Gi_272 = 255;
//extern string e_mail = "";
extern int timeframe = 60;
extern int bb_period = 20;
extern double bb_deviation = 2.0;
extern int bb_method = 0;
extern int bb_price = 0;
extern int atr_period = 20;
extern double lot_size_1 = 0.01;
extern double lot_size_2 = 0.01;
extern double lot_size_3 = 0.02;
extern double lot_size_4 = 0.0;
extern double lot_size_5 = 0.0;
extern double lot_size_6 = 0.0;
extern double lot_size_7 = 0.0;
extern double lot_size_8 = 0.0;
extern int entry_rule = 1;
extern int re_entry_rule = 7;
extern int median_period = 20;
extern int filter_sma = 0;
extern bool atr_take_profit = TRUE;
extern double take_profit_1 = 3.0;
extern double take_profit_2 = -1.0;
extern double take_profit_3 = -1.0;
extern double take_profit_4 = 0.0;
extern double take_profit_5 = 0.0;
extern double take_profit_6 = 0.0;
extern double take_profit_7 = 0.0;
extern double take_profit_8 = 0.0;
extern bool atr_stop_loss = FALSE;
extern double stop_loss = 0.0;
extern bool atr_step_pips = TRUE;
extern double step_pips = 1.0;
extern int slippage = 5;
extern int magic_buy = 1234;
extern int magic_sell = 1235;
extern string comment = "OndaFX";
extern bool text_interface = TRUE;
extern color background_color = Teal;
double G_point_512;
double Gda_524[8];
double Gda_528[8];
double Gd_532;
int Gia_540[2];
int Gia_544[2];
bool Gi_548 = FALSE;
int Gi_552 = 3600000;
double Gd_556 = 0.0;
double Gd_564 = 0.0;
double Gd_580;
string Gs_588;
bool Gi_596 = TRUE;
string G_str_concat_608;
double Gd_616;
string Gs_624;
double Gd_632 = 1.0;

// DD3DB597DF009D42822D6E053AFA76B8
void f0_35(int Ai_0) {
   Gi_148 = Ai_0;
}
			 					     	 		 	  	 	  	 	 	 	 						      					 		 	 			      			  	  			 		 		 	  		 	  			  	  		  	 				 				   			 	  				 	 	 		 	   	 
// 890E0EC4DD2253F2CDC4F67B8D9E1BCA
void f0_24() {
   if (Gi_144 == FALSE) {
      for (int index_0 = 0; index_0 < 12; index_0++) {
         Gsa_76[index_0] = "";
         Gia_80[index_0] = 0;
      }
      for (index_0 = 0; index_0 < 100; index_0++) {
         Gsa_108[index_0] = "";
         Gia_112[index_0] = 0;
      }
      Gi_144 = TRUE;
   }
}
	 			    	 	 	 	     	 	 	    	 	   	    	 	 		   	    	 		 						  	 		 	  	 	  		   		     	   	   	  					   	 	 				  					   				 	     		 	
// CA90F199FAD943ECA9B31C7C06A2D1FB
void f0_31(string As_0, string As_8 = "", string As_16 = "", string As_24 = "", string As_32 = "", string As_40 = "", string As_48 = "", string As_56 = "", string As_64 = "", string As_72 = "", string As_80 = "", string As_88 = "", string As_96 = "", string As_104 = "", string As_112 = "", string As_120 = "", string As_128 = "", string As_136 = "", string As_144 = "", string As_152 = "", string As_160 = "", string As_168 = "", string As_176 = "", string As_184 = "", string As_192 = "", string As_200 = "", string As_208 = "", string As_216 = "", string As_224 = "", string As_232 = "", string As_240 = "", string As_248 = "", string As_256 = "", string As_264 = "", string As_272 = "", string As_280 = "", string As_288 = "", string As_296 = "", string As_304 = "", string As_312 = "", string As_320 = "", string As_328 = "", string As_336 = "", string As_344 = "", string As_352 = "", string As_360 = "", string As_368 = "", string As_376 = "", string As_384 = "", string As_392 = "", string As_400 = "", string As_408 = "", string As_416 = "", string As_424 = "", string As_432 = "", string As_440 = "", string As_448 = "", string As_456 = "", string As_464 = "", string As_472 = "", string As_480 = "", string As_488 = "") {
   int Li_496;
   string Ls_500;
   int Li_508;
   bool bool_512;
   int Li_516;
   bool bool_520;
   if (Gi_148 != FALSE) {
      f0_24();
      Li_496 = GetTickCount();
      if (Gi_140) Gi_132++;
      Ls_500 = As_0 + As_8 + As_16 + As_24 + As_32 + As_40 + As_48 + As_56 + As_64 + As_72 + As_80 + As_88 + As_96 + As_104 + As_112 + As_120 + As_128 + As_136 + As_144 +
         As_152 + As_160 + As_168 + As_176 + As_184 + As_192 + As_200 + As_208 + As_216 + As_224 + As_232 + As_240 + As_248 + As_256 + As_264 + As_272 + As_280 + As_288 + As_296 +
         As_304 + As_312 + As_320 + As_328 + As_336 + As_344 + As_352 + As_360 + As_368 + As_376 + As_384 + As_392 + As_400 + As_408 + As_416 + As_424 + As_432 + As_440 + As_448 +
         As_456 + As_464 + As_472 + As_480 + As_488;
      Li_508 = f0_14(Ls_500);
      bool_512 = Li_508 == -1 || Li_496 >= Li_508 + Gi_120;
      Li_516 = f0_8();
      bool_520 = Li_516 == 0 || Li_496 >= Li_516 + Gi_124;
      if (bool_512 == FALSE && Li_496 >= Gi_128) {
         Gi_128 = Li_496 + Gi_120;
         if (Gi_140) Print("########## Filter1: UPDATED SP_time_next = ", TimeToStr(Gi_128 / 1000, TIME_SECONDS), "; counter = ", Gi_132);
      }
      if (bool_520 == FALSE && Li_496 >= Gi_128) {
         Gi_128 = Li_496 + Gi_124;
         if (Gi_140) Print("########## Filter2: UPDATED SP_time_next = ", TimeToStr(Gi_128 / 1000, TIME_SECONDS), "; counter = ", Gi_132);
      }
      if (Li_496 >= Gi_128) {
         if (Gi_140) {
            Gi_136++;
            Print("SP_time_now = ", TimeToStr(Li_496 / 1000, TIME_SECONDS), "; SP_time_next = ", TimeToStr(Gi_128 / 1000, TIME_SECONDS), "; counter = ", Gi_132, "; counter2 = ",
               Gi_136);
         }
         Gi_116 = (Gi_116 + 1) % 100;
         Gsa_108[Gi_116] = Ls_500;
         Gia_112[Gi_116] = Li_496;
         Print(Ls_500);
      }
   }
}
	   				 		   	   		  	  			 	 		 						 		    	   	 		  	 		   						   					 	 	 	 	    		  		 			  				  					  		       	  	    	 	   		   		
// 57ED0000B9C8B25915AEA86CEFE80A52
int f0_14(string As_0) {
   int Li_12;
   int Li_ret_8 = -1;
   for (int count_16 = 0; count_16 < 100; count_16++) {
      Li_12 = (Gi_116 + 100 - count_16) % 100;
      if (As_0 == Gsa_108[Li_12]) return (Gia_112[Li_12]);
   }
   return (Li_ret_8);
}
		    		  	 			  						   			  					  		  	 		 	 	 		 	    	 	  	 		      		   	   		    							  							     				 	 	   	   	 	 	   		  					 		
// 42B02693A1A7707B7E33810EB75E1ECD
int f0_8() {
   return (Gia_112[(Gi_116 + 1) % 100]);
}
	 		  		 	 				     			  	  	  		     		 	 			 	  	 	 	  		  	  		       	     	 		 	       				 	  								  			 	  	    		 	 	  		 		     		 		
// CC7BCB519C24D9B518E44B9452589DB0
int f0_32(string A_symbol_0, int A_cmd_8, double A_lots_12, double A_price_20, int A_slippage_28, double Ad_32, double Ad_40, string A_comment_48 = "", int A_magic_56 = 0, int A_datetime_60 = 0, color A_color_64 = -1) {
   int ticket_68;
   int error_72;
   f0_31("orderSendReliable(" + A_symbol_0 + "," + A_cmd_8 + "," + A_lots_12 + "," + A_price_20 + "," + A_slippage_28 + "," + Ad_32 + "," + Ad_40 + "," + A_comment_48 +
      "," + A_magic_56 + "," + A_datetime_60 + "," + A_color_64 + ")");
   while (true) {
      if (IsStopped()) {
         f0_31("orderSendReliable(): Trading is stopped!");
         return (-1);
      }
      RefreshRates();
      if (A_cmd_8 == OP_BUY) A_price_20 = Ask;
      if (A_cmd_8 == OP_SELL) A_price_20 = Bid;
      if (!IsTradeContextBusy()) {
         ticket_68 = OrderSend(A_symbol_0, A_cmd_8, A_lots_12, NormalizeDouble(A_price_20, MarketInfo(A_symbol_0, MODE_DIGITS)), A_slippage_28, NormalizeDouble(Ad_32, MarketInfo(A_symbol_0,
            MODE_DIGITS)), NormalizeDouble(Ad_40, MarketInfo(A_symbol_0, MODE_DIGITS)), A_comment_48, A_magic_56, A_datetime_60, A_color_64);
         if (ticket_68 > 0) {
            f0_31("orderSendReliable(): Success! Ticket: " + ticket_68);
            return (ticket_68);
         }
         error_72 = GetLastError();
         if (f0_28(error_72) == TRUE) f0_31("orderSendReliable(): Temporary Error: " + error_72 + " " + ErrorDescription(error_72) + ". waiting.");
         else {
            f0_31("orderSendReliable(): Permanent Error: " + error_72 + " " + ErrorDescription(error_72) + ". giving up.");
            return (-1);
         }
      } else f0_31("orderSendReliable(): Must wait for trade context");
      Sleep(MathRand() / 10);
   }
   return /*(WARN)*/;
}
		    	   	 				 							  			   				  	   	 		   	 		 		   	 	 		 		   	  		       		  	 						   					 	     	 		 	 	 	 	   	   	   			 					  	
// 7F9D690F5900BF2302A8515E54A2A5E6
int f0_21(int A_ticket_0, double A_lots_4, double A_price_12, int A_slippage_20, color A_color_24 = -1) {
   bool is_closed_28;
   int error_32;
   f0_31("orderCloseReliable(" + A_ticket_0 + ")");
   OrderSelect(A_ticket_0, SELECT_BY_TICKET, MODE_TRADES);
   while (true) {
      if (IsStopped()) {
         f0_31("orderCloseReliable(" + A_ticket_0 + "): Trading is stopped!");
         return (0);
      }
      RefreshRates();
      if (OrderType() == OP_BUY) A_price_12 = Bid;
      if (OrderType() == OP_SELL) A_price_12 = Ask;
      if (!IsTradeContextBusy()) {
         is_closed_28 = OrderClose(A_ticket_0, A_lots_4, NormalizeDouble(A_price_12, MarketInfo(OrderSymbol(), MODE_DIGITS)), A_slippage_20, A_color_24);
         if (is_closed_28) {
            f0_31("orderCloseReliable(" + A_ticket_0 + "): Success!");
            return (1);
         }
         error_32 = GetLastError();
         if (f0_28(error_32) == TRUE) f0_31("orderCloseReliable(" + A_ticket_0 + "): Temporary Error: " + error_32 + " " + ErrorDescription(error_32) + ". waiting.");
         else {
            f0_31("orderCloseReliable(" + A_ticket_0 + "): Permanent Error: " + error_32 + " " + ErrorDescription(error_32) + ". giving up.");
            return (0);
         }
      } else f0_31("orderCloseReliable(" + A_ticket_0 + "): Must wait for trade context");
      Sleep(MathRand() / 10);
   }
   return /*(WARN)*/;
}
	 	     		  		 		  			 			 		 	    	    		  			 	 			  					 			 	 	  				 	  	 					 			  			  		 			   		       		 				 	  		 	 	  	 		  				  
// B805B6CC986BBED9EDB59296A5C8F329
int f0_28(int Ai_0) {
   return (Ai_0 == 0 || Ai_0 == 2 || Ai_0 == 4 || Ai_0 == 6 || Ai_0 == 132 || Ai_0 == 135 || Ai_0 == 129 || Ai_0 == 136 || Ai_0 == 137 || Ai_0 == 138 || Ai_0 == 128 ||
      Ai_0 == 146);
}
		    		  	 			  						   			  					  		  	 		 	 	 		 	    	 	  	 		      		   	   		    							  							     				 	 	   	   	 	 	   		  					 		
/*
void f0_40(int Ai_0) {
   Gi_unused_152 = Ai_0;
}
	 				 			 	    	       		   			    		 			 	  			 	  	  			 	 	  	  			 		  							  		 	      			     	 					 	  	 	 	 	 			 			 			   	     		 
// 6FA691D2C07BEA6AE78B7022C80E9D20
string f0_17(string As_0, string As_8, string As_16) {
   string Ls_24;
   string Ls_unused_32;
   f0_20(As_16, Ls_24);
   return (f0_7(f0_37(As_0 + As_8 + "/" + Ls_24 + ".html")));
}
	      	 		 		    				   				 			 		   	 		 				   		    	 	 		 				  	  			  		 	 		 	   				 	 					 			     		  	 		      			     	    							
// 44504ECAC82D4E436FB04675A765970E
string f0_9(string As_0, string As_8, string As_16) {
   string Ls_unused_24;
   return (f0_7(f0_37(As_0 + As_8 + "/" + As_16)));
}
	  	   							  	 	 		  			 	 		  	    										   	   		   		  		   	 			   				  	 	 	 	 		 				 		 	 	 	   	     		 	  	 				  	 	  	 	 				 
// 7DB31A08ED28D42C407F1660B6BF04F5
void f0_20(string As_0, string &As_8) {
   int Li_28;
   int Li_32;
   int Li_36;
   int Li_40;
   int Li_44;
   int Li_48;
   int Li_52;
   int Li_16 = 0;
   int Li_20 = 0;
   int str_len_24 = StringLen(As_0);
   while (Li_16 < str_len_24) {
      Li_36 = StringGetChar(As_0, Li_16);
      Li_16++;
      if (Li_16 >= str_len_24) {
         Li_32 = 0;
         Li_28 = 0;
         Li_20 = 2;
      } else {
         Li_32 = StringGetChar(As_0, Li_16);
         Li_16++;
         if (Li_16 >= str_len_24) {
            Li_28 = 0;
            Li_20 = 1;
         } else {
            Li_28 = StringGetChar(As_0, Li_16);
            Li_16++;
         }
      }
      Li_40 = Li_36 >> 2;
      Li_44 = (Li_36 & 3 * 16) | Li_32 >> 4;
      Li_48 = (Li_32 & 15 * 4) | Li_28 >> 6;
      Li_52 = Li_28 & 63;
      As_8 = As_8 + CharToStr(Gia_256[Li_40]);
      As_8 = As_8 + CharToStr(Gia_256[Li_44]);
      switch (Li_20) {
      case 0:
         As_8 = As_8 + CharToStr(Gia_256[Li_48]);
         As_8 = As_8 + CharToStr(Gia_256[Li_52]);
         break;
      case 1:
         As_8 = As_8 + CharToStr(Gia_256[Li_48]);
         As_8 = As_8 + "=";
         break;
      case 2:
         As_8 = As_8 + "==";
      }
   }
}
	  					 			  	   	   	  		  	 		 	 				 			   	     		  	  	   			 		   		 		 	 	   	    	   		 		   				 						   	      		  	   		 	   	    		
// E08E0DF7D9824CBC970AD8B50DDD423B
string f0_37(string As_0) {
   string Ls_12;
   string Ls_20;
   for (int Li_8 = StringFind(As_0, " "); Li_8 != -1; Li_8 = StringFind(As_0, " ")) {
      Ls_12 = StringTrimLeft(StringTrimRight(StringSubstr(As_0, 0, StringFind(As_0, " ", 0))));
      Ls_20 = StringTrimLeft(StringTrimRight(StringSubstr(As_0, StringFind(As_0, " ", 0))));
      As_0 = Ls_12 + "%20" + Ls_20;
   }
   return (As_0);
}
			 		  	      			 	   		  	 		  	 			  	     	 				 	 		 			 		   						  				 	 		 					 	    	  	      	 		   				 					 	 	 			 	  			 	  	  
string f0_7(string As_0) {
   G_count_228 = 0;
   for (Gi_220 = FALSE; G_count_228 < 3 && Gi_220 == FALSE; G_count_228++) {
      if (Gi_224 != 0) Gi_220 = InternetOpenUrlA(Gi_224, As_0, 0, 0, -2079850240, 0);
      if (Gi_220 == FALSE) {
         InternetCloseHandle(Gi_224);
         Gi_224 = InternetOpenA("mymt4InetSession", Gi_208, 0, 0, 0);
      }
   }
   Gs_232 = "";
   Gia_240[0] = 1;
   while (Gia_240[0] > 0) {
      InternetReadFile(Gi_220, Gs_248, 200, Gia_240);
      if (Gia_240[0] > 0) Gs_232 = Gs_232 + StringSubstr(Gs_248, 0, Gia_240[0]);
   }
   InternetCloseHandle(Gi_220);
   return (Gs_232);
}
		 			    		   	 		    	  	  		 			 		    		  	  	   	 	    	 			 	 				  	 			      			 		       	     	  			  		  	 		 	 		 	  	 		  	 		   	 	
// 3346294235049C7D247C9D4E85FE4ACB
string f0_6(string As_0) {
   int Li_8;
   for (int Li_12 = 0; Li_12 < StringLen(As_0); Li_12++) {
      Li_8 = StringGetChar(As_0, Li_12);
      if (Li_8 >= 'A' && Li_8 <= 'Z') As_0 = StringSetChar(As_0, Li_12, Li_8 + 32);
   }
   return (As_0);
}
	  		 						 		 	 	  		 			    	  	 	 						 	 		     	 		  		   		 	   			 	  			      	 	  						  			 	 		 		    		  	  			 		  				 	 	  	 	 
// C55F233C1991A7FA05479098FC827EEC
int f0_30(string As_0, string As_8, string &Asa_16[], int Ai_20 = 0) {
   int Li_24;
   int Li_28;
   int Li_32;
   if (StringFind(As_0, As_8) < 0) {
      ArrayResize(Asa_16, 1);
      Asa_16[0] = As_0;
   } else {
      Li_24 = 0;
      Li_28 = 0;
      Li_32 = 0;
      while (Li_28 > -1) {
         Li_32++;
         Li_28 = StringFind(As_0, As_8, Li_24);
         ArrayResize(Asa_16, Li_32);
         if (Li_28 > -1) {
            if (Li_28 - Li_24 > 0) Asa_16[Li_32 - 1] = StringSubstr(As_0, Li_24, Li_28 - Li_24);
         } else Asa_16[Li_32 - 1] = StringSubstr(As_0, Li_24, 0);
         Li_24 = Li_28 + 1;
      }
   }
   if (Ai_20 == 0 || Ai_20 == ArraySize(Asa_16)) return (1);
   return (0);
}
	 		   			 			  	   		  		  	 		       			 						 	 	   			  		  	    	 		    					 	 	 	   		 			  		 	 			   	  	  		 	 		 				 		 	  	   				 
// 54DCAF81D765EE239998DC5F1EF9A9FF
void f0_13(double Ad_0, string As_8 = "update.html") {
   Gd_172 = Ad_0;
   Gs_184 = As_8;
}
	   		 				     	 		    				 			  				 				   			  	 	  		 		 	  						 										 	 		 	 		   					   	 	  		 	   		 	 	   	 			   	   	 		  		 
int f0_11(string As_0, string As_8, string As_16, int Ai_24) {
   string Ls_32;
   string Ls_40;
   int str2int_48;
   string Ls_52;
   string Lsa_60[];
   double str2dbl_64;
   string Ls_72;
   int Li_28 = 60;
   if (Gi_156) Li_28 = 86400;
   if (TimeCurrent() >= G_datetime_160 + Li_28) 
	{
      G_datetime_160 = TimeCurrent();
      Ls_32 = f0_6(As_0);
      if (Ai_24 == 1 && IsDemo() == FALSE) Ls_32 = Ls_32 + "@" + AccountNumber();
      Print("authorization = ", Ls_32);
      Ls_40 = f0_17(As_8, As_16, Ls_32);
      str2int_48 = StrToInteger(Ls_40);
      if (xxx(str2int_48) == 1) {
         Gi_156 = TRUE;
         f0_40(str2int_48);
         Print("Authenticated");
      } else {
         Gi_156 = FALSE;
         Print("NOT Authenticated");
         Comment("\n Authorization Failed.\n Please contact us\n at support@pimpmyea.com\n or on http://www.pimpmyea.com");
      }
   }
   if (Gi_156 && TimeCurrent() >= G_datetime_164 + Gi_180) {
      G_datetime_164 = TimeCurrent();
      Ls_52 = f0_9(As_8, As_16, Gs_184);
      if (f0_30(Ls_52, "#", Lsa_60, 2)) {
         str2dbl_64 = StrToDouble(Lsa_60[0]);
         Ls_72 = Lsa_60[1];
         if (Gd_172 > 0.0 && str2dbl_64 > Gd_172) Alert(WindowExpertName(), ": ", Ls_72);
      }
   }
   return (Gi_156);
}
		 	  	 	 									 					 	 	    		   	 	 				  		  	 			    	 	  	    		 	     	   	  				 			 	 	 			    	  	  	   	 			 	 	  		 	 						 		   
// B213B93F78E4323640FE5DDC9938C595
void f0_26() {
   G_datetime_160 = 0;
}
*/
	  	  	 									 	 							 	     	   	 						  	   	 				   	 	 		    				     		  	  		 	 			 			 			  	 	  	      	 		  	 	  	  	 				 	 		   
// 16299D7A8EEA25FE62FC48C14B3643B5
int f0_2() {
   if (G_time_264 == Time[0]) return (0);
   G_time_264 = Time[0];
   return (1);
}
	
/*	 					 		 	  			     				   	      			 		 	    	 	  						 	  	 	  		 			  		  			  	 		     	 		    	  						   	 	  		 			   	 			 			        
// 4489E3F07583E6F5FAB55D727C362633
string f0_10(string As_0) {
   string Ls_12;
   int Li_8 = GlobalVariablesTotal();
   for (int count_20 = 0; count_20 < Li_8; count_20++) {
      Ls_12 = GlobalVariableName(count_20);
      if (StringSubstr(Ls_12, 0, StringLen(As_0)) == As_0) return (StringSubstr(Ls_12, StringLen(As_0) + 1));
   }
   return ("");
}
*/
		  		 		 	     				    	 		 			 					 		 	   				 	 	  	  		 	   					 	 							  	 		 				   		 		   	    		 	 	 		 	 		  	 				  	   				  		 
// E37F0136AA3FFAF149B351F6A4C948E9
int init() 
{
/*
   if (IsTesting() == FALSE) 
	{
      f0_13(1.0);
      f0_26();
      Gs_588 = e_mail;
      if (StringLen(Gs_588) == 0) Gs_588 = f0_10("AUTH_ONDAFX");
      if (StringLen(Gs_588) == 0) Gs_588 = f0_10("AUTH_PIMPMYEA");
      if (f0_11(Gs_588, "http://www.pimpmyea.com/auth/", "OndaFX", 1) == 0) return (0);
   }
   GlobalVariableSet(StringConcatenate("AUTH_ONDAFX", "=", Gs_588), 0.0);
*/   
	f0_3();
   Gi_168 = TRUE;
   return (0);	
}
	  		  	 			 	    	  	   		   			 	 	  	 			 			         	  			 			 	 	  		 	 		 	    	   	  	 	 		  	 			 		  		   			    					   			    	  				
// 1C86E8D4535299BB79FDC73CA04439CC
int f0_3() {
   HideTestIndicators(TRUE);
   G_point_512 = Point;
   if (G_point_512 == 0.00001) G_point_512 = 0.0001;
   if (G_point_512 == 0.001) G_point_512 = 0.01;
   Gda_524[0] = lot_size_1;
   Gda_524[1] = lot_size_2;
   Gda_524[2] = lot_size_3;
   Gda_524[3] = lot_size_4;
   Gda_524[4] = lot_size_5;
   Gda_524[5] = lot_size_6;
   Gda_524[6] = lot_size_7;
   Gda_524[7] = lot_size_8;
   Gda_528[0] = take_profit_1;
   Gda_528[1] = take_profit_2;
   Gda_528[2] = take_profit_3;
   Gda_528[3] = take_profit_4;
   Gda_528[4] = take_profit_5;
   Gda_528[5] = take_profit_6;
   Gda_528[6] = take_profit_7;
   Gda_528[7] = take_profit_8;
   f0_4();
   f0_5();
   Gia_540[0] = magic_buy;
   Gia_540[1] = magic_sell;
   Gia_544[0] = f0_39(Gia_540[0]);
   Gia_544[1] = f0_39(Gia_540[1]);
   if (IsTesting() && Gi_548) f0_29();
   G_str_concat_608 = StringConcatenate("ondafx_", Symbol(), "_", DoubleToStr(magic_buy, 0), "_", DoubleToStr(magic_sell, 0));
   if (GlobalVariableCheck(G_str_concat_608)) Gd_616 = GlobalVariableGet(G_str_concat_608);
   else {
      GlobalVariableSet(G_str_concat_608, 0.0);
      Gd_616 = 0.0;
   }
   Gs_624 = StringSubstr(Symbol(), 6, 0);
   if (AccountCurrency() == "EUR") Gd_632 = 1.0 / MarketInfo("EURUSD" + Gs_624, MODE_BID);
   if (AccountCurrency() == "GBP") Gd_632 = 1.0 / MarketInfo("GBPUSD" + Gs_624, MODE_BID);
   if (AccountCurrency() == "CHF") Gd_632 = MarketInfo("USDCHF" + Gs_624, MODE_BID);
   if (AccountCurrency() == "JPY") Gd_632 = MarketInfo("USDJPY" + Gs_624, MODE_BID);
   Print("atr_currency_factor = ", Gd_632);
   f0_0();
   return (0);
}
		  	  	  	  	   			 	    		  							  	  	  			 	 	       				 	 			 	   			 		   	  	  			 	 	  		 	 		   	  			 				  	  				 	  		   			 				
// B9C2148E2C8B62CD3FCAF4AC8EECB976
void f0_29() {
   Gd_580 = MarketInfo(Symbol(), MODE_TICKVALUE);
   if (Point == 0.00001) Gd_580 = 10.0 * Gd_580;
   ObjectCreate("onda", OBJ_LABEL, 0, 0, 0, 0, 0, 0);
   ObjectSet("onda", OBJPROP_XDISTANCE, 250);
   ObjectSet("onda", OBJPROP_YDISTANCE, 0);
   ObjectSet("onda", OBJPROP_BACK, TRUE);
   ObjectSetText("onda", "OndaFX v1.0", 20, "Comic Sans MS", Red);
   ObjectCreate("pimp", OBJ_LABEL, 0, 0, 0, 0, 0, 0);
   ObjectSet("pimp", OBJPROP_XDISTANCE, 250);
   ObjectSet("pimp", OBJPROP_YDISTANCE, 30);
   ObjectSet("pimp", OBJPROP_BACK, TRUE);
   ObjectSetText("pimp", "PimpMyEA.com", 20, "Comic Sans MS", Red);
   f0_36();
}
		     	  	 		   					    			 						   	  	 				 	 		      	 		 	 		  	   		  		   		 	  					 	  				 		      			 	 		  	   			 	   	   								
// 52D46093050F38C27267BCE42543EF60
int deinit() {
   Comment("");
   int Li_0 = 20;
   for (int count_4 = 0; count_4 < 10; count_4++) {
      for (int count_8 = 0; count_8 < Li_0; count_8++) {
         ObjectDelete("background" + count_4 + count_8);
         ObjectDelete("background" + count_4 + ((count_8 + 1)));
         ObjectDelete("background" + count_4 + ((count_8 + 2)));
      }
   }
   return (0);
}
	   	 					  		 	 		 		 				   	  			 					  	 		  	  	 		 			   				   					  			 	    	 		 							 			 	  	 		   			  	   		 		   			 	 		 	 	 
// EA2B2676C28C0DB26D39331A336C6B92
int start() 
{
/*
   if (IsTesting() == FALSE)
      if (f0_11(Gs_588, "http://www.pimpmyea.com/auth/", "OndaFX", 1) == 0) return (0);
*/
	if (!Gi_168) {
      f0_3();
      Gi_168 = TRUE;
   }
   f0_33();
   return (0);
}
	  	   							  	 	 		  			 	 		  	    										   	   		   		  		   	 			   				  	 	 	 	 		 				 		 	 	 	   	     		 	  	 				  	 	  	 	 				 
// CE950C824EB925C8055E76804B523700
int f0_33() {
   int Li_0;
   double ima_8;
   double ima_16;
   double ima_24;
   double ima_32;
   double istddev_40;
   double istddev_48;
   double istddev_56;
   double istddev_64;
   double Ld_72;
   double Ld_80;
   double Ld_88;
   double Ld_96;
   double Ld_104;
   double Ld_112;
   double Ld_120;
   double Ld_128;
   double Ld_144;
   double Ld_160;
   bool Li_168;
   bool Li_172;
   bool Li_176;
   f0_35(0);
   Gia_544[0] = f0_39(Gia_540[0]);
   Gia_544[1] = f0_39(Gia_540[1]);
   f0_22(0);
   f0_22(1);
   if (f0_2() == TRUE) {
      if (IsTesting() && Gi_548) {
         Li_0 = 0;
         for (int count_4 = 0; count_4 < Gi_552; count_4++) Li_0 += count_4;
         f0_36();
      }
      f0_4();
      f0_5();
      ima_8 = iMA(NULL, timeframe, bb_period, 0, bb_method, bb_price, 1);
      ima_16 = iMA(NULL, timeframe, bb_period, 0, bb_method, bb_price, 2);
      ima_24 = iMA(NULL, timeframe, bb_period, 0, bb_method, bb_price, 3);
      ima_32 = iMA(NULL, timeframe, bb_period, 0, bb_method, bb_price, 4);
      istddev_40 = iStdDev(NULL, timeframe, bb_period, 0, bb_method, bb_price, 1);
      istddev_48 = iStdDev(NULL, timeframe, bb_period, 0, bb_method, bb_price, 2);
      istddev_56 = iStdDev(NULL, timeframe, bb_period, 0, bb_method, bb_price, 3);
      istddev_64 = iStdDev(NULL, timeframe, bb_period, 0, bb_method, bb_price, 4);
      Ld_72 = ima_8 - bb_deviation * istddev_40;
      Ld_80 = ima_8 + bb_deviation * istddev_40;
      Ld_88 = ima_16 - bb_deviation * istddev_48;
      Ld_96 = ima_16 + bb_deviation * istddev_48;
      Ld_104 = ima_24 - bb_deviation * istddev_56;
      Ld_112 = ima_24 + bb_deviation * istddev_56;
      Ld_120 = ima_32 - bb_deviation * istddev_64;
      Ld_128 = ima_32 + bb_deviation * istddev_64;
      Ld_144 = step_pips;
      if (atr_step_pips) Ld_144 = iATR(NULL, timeframe, atr_period, 1) / G_point_512 * step_pips;
      Ld_160 = Gda_524[Gia_544[0]];
      Li_168 = TRUE;
      Li_172 = TRUE;
      if (filter_sma > 0) {
         if (iMA(NULL, timeframe, filter_sma, 0, MODE_SMA, PRICE_CLOSE, 1) < iMA(NULL, timeframe, filter_sma, 0, MODE_SMA, PRICE_CLOSE, 2)) Li_168 = FALSE;
         else Li_172 = FALSE;
      }
      Li_176 = FALSE;
      if (Ld_160 > 0.0) {
         if (Gia_544[0] == 0 && Li_168) {
            Li_176 = FALSE;
            switch (entry_rule) {
            case 1:
               if (!(Close[1] < Ld_72 || (Open[0] < Close[1] && Open[0] < Ld_72))) break;
               Li_176 = TRUE;
               break;
            case 2:
               if (!(Close[1] < Ld_72 && Close[2] < Ld_88)) break;
               Li_176 = TRUE;
               break;
            case 3:
               if (!(Close[1] < Ld_72 && Close[2] < Ld_88 && Close[3] < Ld_104)) break;
               Li_176 = TRUE;
               break;
            case 4:
               if (!(Close[1] > Ld_72 && Close[2] < Ld_88)) break;
               Li_176 = TRUE;
               break;
            case 5:
               if (!(Close[1] > Ld_72 && Close[2] < Ld_88 && Close[3] < Ld_104)) break;
               Li_176 = TRUE;
               break;
            case 6:
               if (!(Close[1] > Ld_72 && Close[2] < Ld_88 && Close[3] < Ld_104 && Close[4] < Ld_120)) break;
               Li_176 = TRUE;
            }
            if (Li_176) f0_32(Symbol(), OP_BUY, Ld_160, Ask, slippage, 0, 0, comment, Gia_540[0], 0, Gi_268);
         }
         if (Gia_544[0] > 0 && Gia_544[0] < 8 && f0_25(Gia_540[0], 0) > Ld_144) {
            Li_176 = FALSE;
            switch (re_entry_rule) {
            case 1:
               if (!(Close[1] < Ld_72 || (Open[0] < Close[1] && Open[0] < Ld_72))) break;
               Li_176 = TRUE;
               break;
            case 2:
               if (!(Close[1] < Ld_72 && Close[2] < Ld_88)) break;
               Li_176 = TRUE;
               break;
            case 3:
               if (!(Close[1] < Ld_72 && Close[2] < Ld_88 && Close[3] < Ld_104)) break;
               Li_176 = TRUE;
               break;
            case 4:
               if (!(Close[1] > Ld_72 && Close[2] < Ld_88)) break;
               Li_176 = TRUE;
               break;
            case 5:
               if (!(Close[1] > Ld_72 && Close[2] < Ld_88 && Close[3] < Ld_104)) break;
               Li_176 = TRUE;
               break;
            case 6:
               if (!(Close[1] < Ld_72 && Close[2] < Ld_88 && Close[3] < Ld_104 && Close[4] < Ld_120)) break;
               Li_176 = TRUE;
               break;
            case 7:
               if (Close[1] <= iMA(NULL, timeframe, median_period, 0, MODE_SMA, PRICE_CLOSE, 1)) break;
               Li_176 = TRUE;
            }
            if (Li_176) f0_32(Symbol(), OP_BUY, Ld_160, Ask, slippage, 0, 0, comment, Gia_540[0], 0, Gi_268);
         }
      }
      Ld_160 = Gda_524[Gia_544[1]];
      if (Ld_160 > 0.0) {
         if (Gia_544[1] == 0 && Li_172) {
            Li_176 = FALSE;
            switch (entry_rule) {
            case 1:
               if (!(Close[1] > Ld_80 || (Open[0] > Close[1] && Open[0] > Ld_80))) break;
               Li_176 = TRUE;
               break;
            case 2:
               if (!(Close[1] > Ld_80 && Close[2] > Ld_96)) break;
               Li_176 = TRUE;
               break;
            case 3:
               if (!(Close[1] > Ld_80 && Close[2] > Ld_96 && Close[3] > Ld_112)) break;
               Li_176 = TRUE;
               break;
            case 4:
               if (!(Close[1] < Ld_80 && Close[2] > Ld_96)) break;
               Li_176 = TRUE;
               break;
            case 5:
               if (!(Close[1] < Ld_80 && Close[2] > Ld_96 && Close[3] > Ld_112)) break;
               Li_176 = TRUE;
               break;
            case 6:
               if (!(Close[1] < Ld_80 && Close[2] > Ld_96 && Close[3] > Ld_112 && Close[4] > Ld_128)) break;
               Li_176 = TRUE;
            }
            if (Li_176) f0_32(Symbol(), OP_SELL, Ld_160, Bid, slippage, 0, 0, comment, Gia_540[1], 0, Gi_272);
         }
         if (Gia_544[1] > 0 && Gia_544[1] < 8 && f0_25(Gia_540[1], 1) > Ld_144) {
            Li_176 = FALSE;
            switch (re_entry_rule) {
            case 1:
               if (!(Close[1] > Ld_80 || (Open[0] > Close[1] && Open[0] > Ld_80))) break;
               Li_176 = TRUE;
               break;
            case 2:
               if (!(Close[1] > Ld_80 && Close[2] > Ld_96)) break;
               Li_176 = TRUE;
               break;
            case 3:
               if (!(Close[1] > Ld_80 && Close[2] > Ld_96 && Close[3] > Ld_112)) break;
               Li_176 = TRUE;
               break;
            case 4:
               if (!(Close[1] < Ld_80 && Close[2] > Ld_96)) break;
               Li_176 = TRUE;
               break;
            case 5:
               if (!(Close[1] < Ld_80 && Close[2] > Ld_96 && Close[3] > Ld_112)) break;
               Li_176 = TRUE;
               break;
            case 6:
               if (!(Close[1] < Ld_80 && Close[2] > Ld_96 && Close[3] > Ld_112 && Close[4] > Ld_128)) break;
               Li_176 = TRUE;
               break;
            case 7:
               if (Close[1] >= iMA(NULL, timeframe, median_period, 0, MODE_SMA, PRICE_CLOSE, 1)) break;
               Li_176 = TRUE;
            }
            if (Li_176) f0_32(Symbol(), OP_SELL, Ld_160, Bid, slippage, 0, 0, comment, Gia_540[1], 0, Gi_272);
         }
      }
   }
   f0_0();
   return (0);
}
		 	    	 				 				 		 		 	 	 	  		     	 					 		  	  		    			  	   			 	   	 	   	 					 		  	 	 		     	     	   					 	 		 		 	 	 				 			  
// 25FF18AD06673BD783691BD3BA272776
void f0_4() {
   double Ld_0;
   double Ld_8;
   if (atr_take_profit) {
      Ld_0 = iATR(NULL, timeframe, atr_period, 1) / G_point_512;
      if (AccountCurrency() == "EUR") Gd_632 = 1.0 / MarketInfo("EURUSD" + Gs_624, MODE_BID);
      if (AccountCurrency() == "GBP") Gd_632 = 1.0 / MarketInfo("GBPUSD" + Gs_624, MODE_BID);
      if (AccountCurrency() == "CHF") Gd_632 = MarketInfo("USDCHF" + Gs_624, MODE_BID);
      if (AccountCurrency() == "JPY") Gd_632 = MarketInfo("USDJPY" + Gs_624, MODE_BID);
      Ld_8 = Ld_0 * Gd_632 * lot_size_1 / 0.1;
      Gda_528[0] = Ld_8 * take_profit_1;
      Gda_528[1] = Ld_8 * take_profit_2;
      Gda_528[2] = Ld_8 * take_profit_3;
      Gda_528[3] = Ld_8 * take_profit_4;
      Gda_528[4] = Ld_8 * take_profit_5;
      Gda_528[5] = Ld_8 * take_profit_6;
      Gda_528[6] = Ld_8 * take_profit_7;
      Gda_528[7] = Ld_8 * take_profit_8;
   }
}
	  	     					 	  	 		 	 		 	 	 	 	      						     	  	 	   						   		 		   	  	  	 		  	 		   		 		  		 	    	    			   	 		    	 	 	  	 			 	
// 2CB6B0B58445BF5D5521DCF593BFC45E
void f0_5() {
   double Ld_0;
   double Ld_8;
   if (atr_stop_loss) {
      Ld_0 = iATR(NULL, timeframe, atr_period, 1) / G_point_512;
      if (AccountCurrency() == "EUR") Gd_632 = 1.0 / MarketInfo("EURUSD" + Gs_624, MODE_BID);
      if (AccountCurrency() == "GBP") Gd_632 = 1.0 / MarketInfo("GBPUSD" + Gs_624, MODE_BID);
      if (AccountCurrency() == "CHF") Gd_632 = MarketInfo("USDCHF" + Gs_624, MODE_BID);
      if (AccountCurrency() == "JPY") Gd_632 = MarketInfo("USDJPY" + Gs_624, MODE_BID);
      Ld_8 = Ld_0 * Gd_632 * lot_size_1 / 0.1;
      Gd_532 = Ld_8 * stop_loss;
   }
}
	   		   		    	  		   	 			 		 	 				   		   	    	 	 	 	 		 										 						  	 	 			  		     			    		  		  	  		 		    	 	     	  	  		  	 	
// 833A6645A328657B848FF0DE82EE9964
void f0_22(int Ai_0) {
   double Ld_4;
   if (Gia_544[Ai_0] > 0) {
      Ld_4 = f0_41(Gia_540[Ai_0]);
      if (Ld_4 >= Gda_528[Gia_544[Ai_0] - 1]) f0_18(Gia_540[Ai_0]);
      if (stop_loss > 0.0 && Ld_4 < (-Gd_532)) f0_18(Gia_540[Ai_0]);
   }
}
	 	  	 			  	   	  		   		 					   	 	 			  	 			 				  				  	  	 	 		 		 	 										 	  		  			 		  	 		  	 	  		  	 	 	   			 	     	  		 		 
// F997BF1F9F382070CE6267D360D03781
double f0_41(int A_magic_0) {
   double Ld_ret_4 = 0;
   int order_total_12 = OrdersTotal();
   string dbl2str_16 = DoubleToStr(A_magic_0, 0);
   if (order_total_12 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_12; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == A_magic_0 || OrderComment() == dbl2str_16) Ld_ret_4 += OrderProfit() + OrderSwap() + OrderCommission();
      }
      return (Ld_ret_4);
   }
   return (0.0);
}
	  			   			   	  	    	 		  		 	 	 		   			  	      	 	 	  	 					 				 		 			  	   			  	      		     		 			  	   	 		   		 	    		  	  	   	 	
// 716F6B30598BA30945D84485E61C1027
void f0_18(int A_magic_0) {
   string dbl2str_4 = DoubleToStr(A_magic_0, 0);
   if (OrdersTotal() > 0) {
      for (int order_total_12 = OrdersTotal(); order_total_12 >= 0; order_total_12--) {
         OrderSelect(order_total_12, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == A_magic_0 || OrderComment() == dbl2str_4) {
            if (OrderType() == OP_BUY) f0_21(OrderTicket(), OrderLots(), Bid, slippage, Blue);
            if (OrderType() == OP_SELL) f0_21(OrderTicket(), OrderLots(), Ask, slippage, Red);
         }
      }
   }
}
			 			 	     				 	  			  	 	   	 				 	       				 				 			  	   			 		  			  	 		 	 			 	  	 	  	  	   	 			  				  				 	   			 	 				 	     
// E2942A04780E223B215EB8B663CF5353
int f0_39(int A_magic_0) {
   int count_4 = 0;
   int order_total_8 = OrdersTotal();
   string dbl2str_12 = DoubleToStr(A_magic_0, 0);
   if (order_total_8 > 0) {
      for (int pos_20 = 0; pos_20 < order_total_8; pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == A_magic_0 || OrderComment() == dbl2str_12) count_4++;
      }
      return (count_4);
   }
   return (0);
}
	   	  	 		  	    		 	   			  			 			  	 		  			   	     	 				 					 	  				 		 	 	  	   		 	 	 			 	 			  	  		  				     				    		    		 				
// A74EC9C5B6882F79E32A8FBD8DA90C1B
double f0_25(int Ai_0, int Ai_4) {
   double Ld_8 = f0_34(Ai_0);
   if (Ai_4 == 0) return ((Ld_8 - Ask) / G_point_512);
   if (Ai_4 == 1) return ((Bid - Ld_8) / G_point_512);
   return (0.0);
}
	      	 		 		    				   				 			 		   	 		 				   		    	 	 		 				  	  			  		 	 		 	   				 	 					 			     		  	 		      			     	    							
// D4D37C4938CB842ADF67803655D8FA59
double f0_34(int A_magic_0) {
   double order_open_price_12;
   string dbl2str_4 = DoubleToStr(A_magic_0, 0);
   if (OrdersTotal() > 0) {
      for (int pos_20 = 0; pos_20 < OrdersTotal(); pos_20++) {
         OrderSelect(pos_20, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == A_magic_0 || OrderComment() == dbl2str_4) order_open_price_12 = OrderOpenPrice();
      }
   }
   return (order_open_price_12);
}
	      	 		 		    				   				 			 		   	 		 				   		    	 	 		 				  	  			  		 	 		 	   				 	 					 			     		  	 		      			     	    							
// DEE3378F7ACD69CEE7C6A5B8791192B6
void f0_36() {
   color color_0 = Yellow;
   color color_4 = Yellow;
   Gd_556 = f0_19(0.1);
   string Ls_8 = "";
   if (Gd_556 > 0.0) Ls_8 = "+";
   if (Gd_556 < 0.0) {
      Ls_8 = "-";
      color_0 = Red;
   }
   ObjectCreate("floating_pips", OBJ_LABEL, 0, 0, 0, 0, 0, 0);
   ObjectSet("floating_pips", OBJPROP_XDISTANCE, 740);
   ObjectSet("floating_pips", OBJPROP_YDISTANCE, 445);
   ObjectSet("floating_pips", OBJPROP_BACK, TRUE);
   ObjectSetText("floating_pips", StringConcatenate("Floating PL = ", Ls_8, DoubleToStr(MathAbs(Gd_556), 0), " Pips"), 14, "Comic Sans MS", color_0);
   Gd_564 = f0_12(0.1);
   string Ls_16 = "";
   if (Gd_564 > 0.0) Ls_16 = "+";
   if (Gd_564 < 0.0) {
      Ls_16 = "-";
      color_4 = Red;
   }
   ObjectCreate("closed_pips", OBJ_LABEL, 0, 0, 0, 0, 0, 0);
   ObjectSet("closed_pips", OBJPROP_XDISTANCE, 740);
   ObjectSet("closed_pips", OBJPROP_YDISTANCE, 467);
   ObjectSet("closed_pips", OBJPROP_BACK, TRUE);
   ObjectSetText("closed_pips", StringConcatenate("Closed PL = ", Ls_16, DoubleToStr(MathAbs(Gd_564), 0), " Pips"), 14, "Comic Sans MS", color_4);
}
				       			 	 	  		 	    	 	 		         				  		 	  	  	  				     		      	   	 	 		 	  		      		  	 		    			  			 			 		  			 	 	 	  			 	
// 7775F560800EB0F570ECE298CB084C8F
double f0_19(double Ad_0) {
   double Ld_ret_8 = 0;
   double Ld_16 = 0;
   int order_total_24 = OrdersTotal();
   for (int pos_28 = 0; pos_28 < order_total_24; pos_28++) {
      if (OrderSelect(pos_28, SELECT_BY_POS)) {
         if (f0_27(OrderMagicNumber()) || f0_15(OrderComment()) && OrderSymbol() == Symbol()) {
            Ld_16 = OrderProfit() + OrderSwap() + OrderCommission();
            Ld_16 /= Ad_0 * Gd_580;
            Ld_ret_8 += Ld_16;
         }
      }
   }
   return (Ld_ret_8);
}
	 	  	 	 	  	      		    	 						  	 	 	 	  	 		  				   			  	 		 	 		  	 	 			 						    		  	 	 		  				  	 		 		  	   	   		  	        		 			
// 4F1FF660AD8CAEB792435D2E6D07EC2A
double f0_12(double Ad_0) {
   double Ld_ret_8 = 0;
   double Ld_16 = 0;
   int hist_total_24 = OrdersHistoryTotal();
   for (int pos_28 = 0; pos_28 < hist_total_24; pos_28++) {
      if (OrderSelect(pos_28, SELECT_BY_POS, MODE_HISTORY)) {
         if (f0_27(OrderMagicNumber()) || f0_15(OrderComment()) && OrderSymbol() == Symbol()) {
            Ld_16 = OrderProfit() + OrderSwap() + OrderCommission();
            Ld_16 /= Ad_0 * Gd_580;
            Ld_ret_8 += Ld_16;
         }
      }
   }
   return (Ld_ret_8);
}
	 	 	 		 	   		    	 		  	 	   		  		 		 	   	 	  		  	  					  		 		    	 		  	 			       	 			 	 	 						 	 			 				    	 		 	  	 			    	 	 		
// B3E8E7C500163979ECE20A13A730E94E
int f0_27(int Ai_0) {
   if (Ai_0 == Gia_540[0]) return (1);
   if (Ai_0 == Gia_540[1]) return (1);
   return (0);
}
	  			   			   	  	    	 		  		 	 	 		   			  	      	 	 	  	 					 				 		 			  	   			  	      		     		 			  	   	 		   		 	    		  	  	   	 	
// 5D7949AD7BEDF822FD712B79BF94F6DF
int f0_15(string As_0) {
   if (As_0 == DoubleToStr(Gia_540[0], 0)) return (1);
   if (As_0 == DoubleToStr(Gia_540[1], 0)) return (1);
   return (0);
}
		   	 		 	 	   					   	 						 			 	 		 	 	 				 			  	  	  	   		 		 	 		 				  				 					  		 			  	     	 	 	 	  	 		    				      					 		 
// 0021B962A6B2F5C54E9D820A33FBD187
void f0_0() {
   double Ld_0;
   double Ld_8;
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   double Ld_48;
   double Ld_56;
   string Ls_64;
   string Ls_72;
   int Li_84;
   if (text_interface) {
      Ld_0 = f0_16(magic_buy) + f0_16(magic_sell);
      Ld_8 = 0.0;
      if (Gia_544[0] > 0) Ld_8 = Gda_528[Gia_544[0] - 1];
      Ld_16 = 0.0;
      if (Gia_544[1] > 0) Ld_16 = Gda_528[Gia_544[1] - 1];
      Ld_24 = f0_41(magic_buy);
      Ld_32 = f0_41(magic_sell);
      Ld_40 = Ld_24 + Ld_32;
      Ld_48 = f0_1(magic_buy);
      Ld_56 = f0_1(magic_sell);
      if (Ld_40 < Gd_616) {
         Gd_616 = Ld_40;
         GlobalVariableSet(G_str_concat_608, Gd_616);
      }
      Ls_64 = "==========================\n";
      Ls_64 = Ls_64 + "               " + "OndaFX v1.00" 
      + "\n";
      Ls_64 = Ls_64 + "              www.pimpmyea.com\n";
      Ls_64 = Ls_64 + "==========================\n";
      for (int count_80 = 0; count_80 <= MathMod(Seconds(), 20); count_80++) Ls_72 = Ls_72 + "|";
      Ls_64 = Ls_64 + "  Status: RUNNING " + Ls_72 
      + "\n";
      Ls_64 = Ls_64 + "==========================\n";
      Ls_64 = Ls_64 + "  Closed Orders Profit: $ " + DoubleToStr(Ld_0, 2) 
      + "\n";
      Ls_64 = Ls_64 + "==========================\n";
      Ls_64 = Ls_64 + "  BUY Orders: " + f0_39(magic_buy) + " (" + DoubleToStr(f0_23(magic_buy), 2) + " lots)\n";
      Ls_64 = Ls_64 + "  SELL Orders: " + f0_39(magic_sell) + " (" + DoubleToStr(f0_23(magic_sell), 2) + " lots)\n";
      Ls_64 = Ls_64 + "  BUY Target: $ " + DoubleToStr(Ld_8, 2) 
      + "\n";
      Ls_64 = Ls_64 + "  SELL Target: $ " + DoubleToStr(Ld_16, 2) 
      + "\n";
      Ls_64 = Ls_64 + "  BUY Orders Value: $ " + DoubleToStr(Ld_24, 2) 
      + "\n";
      Ls_64 = Ls_64 + "  SELL Orders Value: $ " + DoubleToStr(Ld_32, 2) 
      + "\n";
      Ls_64 = Ls_64 + "  TOTAL Open Orders Value: $ " + DoubleToStr(Ld_40, 2) 
      + "\n";
      Ls_64 = Ls_64 + "  MAX Floating DD: $ " + DoubleToStr(Gd_616, 2) 
      + "\n";
      Ls_64 = Ls_64 + "  BUY Breakeven Level @ " + DoubleToStr(Ld_48, Digits) 
      + "\n";
      Ls_64 = Ls_64 + "  SELL Breakeven Level @ " + DoubleToStr(Ld_56, Digits) 
      + "\n";
      Ls_64 = Ls_64 + "==========================\n";
      Ls_64 = Ls_64 + "  Base Lot Size: " + DoubleToStr(Gda_524[0], 2) + " lots\n";
      Ls_64 = Ls_64 + "  Slippage: " + DoubleToStr(slippage, 2) + " pips\n";
      Ls_64 = Ls_64 + "==========================\n";
      Comment(Ls_64);
      f0_38("Breakeven_buy", Ld_48, Green, "Breakeven Line");
      f0_38("Breakeven_sell", Ld_56, Red, "Breakeven Line");
      Li_84 = 11;
      if (Gi_596 || Seconds() % 5 == 0) {
         Gi_596 = FALSE;
         for (int count_88 = 0; count_88 < 9; count_88++) {
            for (int count_92 = 0; count_92 < Li_84; count_92++) {
               ObjectDelete("background" + count_88 + count_92);
               ObjectDelete("background" + count_88 + ((count_92 + 1)));
               ObjectDelete("background" + count_88 + ((count_92 + 2)));
               ObjectCreate("background" + count_88 + count_92, OBJ_LABEL, 0, 0, 0);
               ObjectSetText("background" + count_88 + count_92, "n", 30, "Wingdings", background_color);
               ObjectSet("background" + count_88 + count_92, OBJPROP_XDISTANCE, 20 * count_88);
               ObjectSet("background" + count_88 + count_92, OBJPROP_YDISTANCE, 23 * count_92 + 9);
            }
         }
      }
   }
}
	 				 			 	    	       		   			    		 			 	  			 	  	  			 	 	  	  			 		  							  		 	      			     	 					 	  	 	 	 	 			 			 			   	     		 
// 5DD01D070EC813C0626C05E74A2FCD6D
double f0_16(int A_magic_0) {
   double Ld_ret_4 = 0;
   string dbl2str_12 = DoubleToStr(A_magic_0, 0);
   int hist_total_20 = OrdersHistoryTotal();
   if (hist_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < hist_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_HISTORY);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == A_magic_0 || OrderComment() == dbl2str_12) Ld_ret_4 += OrderProfit() + OrderSwap() + OrderCommission();
      }
      return (Ld_ret_4);
   }
   return (0.0);
}
	      				 		  	 				  					 		  		   				 					  		   		 	 		  			  	 				  				 		 	 	 				 							 	 	     	   	 		 	    				    	  	 						 
// 868C5332B7AE9CFAA2B7E30368FF2FB6
double f0_23(int A_magic_0) {
   double Ld_ret_4;
   string dbl2str_12 = DoubleToStr(A_magic_0, 0);
   int hist_total_20 = OrdersHistoryTotal();
   if (hist_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < hist_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == A_magic_0 || OrderComment() == dbl2str_12) Ld_ret_4 += OrderLots();
      }
   }
   return (Ld_ret_4);
}
	   				 		   	   		  	  			 	 		 						 		    	   	 		  	 		   						   					 	 	 	 	    		  		 			  				  					  		       	  	    	 	   		   		
// 020061EF10F0ABCDAC97861ADBC957F1
double f0_1(int A_magic_0) {
   double Ld_4 = f0_23(A_magic_0);
   if (Ld_4 == 0.0) return (0);
   double Ld_ret_12 = 0;
   string dbl2str_20 = DoubleToStr(A_magic_0, 0);
   int order_total_28 = OrdersTotal();
   for (int pos_32 = 0; pos_32 < order_total_28; pos_32++) {
      OrderSelect(pos_32, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == A_magic_0 || OrderComment() == dbl2str_20) Ld_ret_12 += OrderOpenPrice() * OrderLots() / Ld_4;
   }
   return (Ld_ret_12);
}
			 	        	 	 	 	 	 	   	  	 		 		        		  			   	  							  		 		   		 	   		  		 	 	 	     	 	  	 	 	   								 		 			  		 		 	 	 	 		 	
// E17F10504B516B2F05B14321D7FFFCBB
string f0_38(string A_name_0, double A_price_8, color A_color_16 = 255, string A_text_20 = "") {
   if (!IsOptimization()) {
      if (A_name_0 == "") A_name_0 = "line_" + Time[0];
      if (ObjectFind(A_name_0) == -1) ObjectCreate(A_name_0, OBJ_HLINE, 0, 0, A_price_8);
      else ObjectSet(A_name_0, OBJPROP_PRICE1, A_price_8);
      ObjectSet(A_name_0, OBJPROP_COLOR, A_color_16);
      ObjectSetText(A_name_0, A_text_20);
   }
   return (A_name_0);
}