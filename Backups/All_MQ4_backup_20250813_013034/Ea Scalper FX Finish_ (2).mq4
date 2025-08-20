#property copyright "==Copyright 2013"
#property link      "K-heart tho/kahar_Modif"

double Gd_unused_76 = 10973132.0;
extern string Petunjuk_LanjutTrade = "Setelah Ea Op Lalu Di ganti False= Ronde Berikut Ea OF";
extern bool LanjutTrade = TRUE;
extern string Petunjuk_Istirahat = "Jika= Di isi= 10.Ea Stop Setelah Take 10 kali";
extern int Istirahat = 100;
int Gi_108;
color G_color_112 = Lime;
int G_color_116 = Gold;
int G_color_120 = White;
int G_color_124 = Blue;
int G_color_128 = Silver;
color G_color_132 = Gold;
int G_color_136 = Red;
int G_color_140 = Gold;
int Gi_unused_144 = 65280;
int G_color_148 = Blue;
int G_color_152 = White;
extern string __JamBeroprasi__ = "Jika True Ea Akan Aktif Sesuai Jadwal";
extern bool JamTrading = FALSE;
extern int MulaiJam = 22;
extern int StopJam = 12;
extern bool CutLoss = FALSE;
extern bool Marti = TRUE;
extern int Transisi = 1;
extern double LotExponent = 1.6;
double G_slippage_196 = 5.0;
extern string __Coumpound__ = "Jika True EA Otamatis Mengubah Lots Nya";
extern bool Compound = FALSE;
extern double Pembagi = 10000.0;
extern double Lots = 0.01;
extern double LotsDigits = 2.0;
extern double TakePropit = 4.0;
extern double StopLoss = 0.0;
extern double PipsStep = 3.0;
extern int MaxTrades = 20;
extern string __Trailling__ = "Jika True EA Otamatis Mengunci StopLoss nya";
extern bool PakeTrailing = FALSE;
extern double LockPropit = 7.0;
extern double TrailingStop = 5.0;
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
extern string __Target_Harian__ = "Jika di true, akumulasi di isi modal+targetnya";
extern bool Target = FALSE;
extern double Akumulasi = 100.0;
extern bool CloseAll = FALSE;
extern int magic = 70709;
extern string Komentar = "Scalper_Forex";
double Gd_344 = 0.0;
bool Gi_352 = FALSE;
double G_price_356;
double Gd_364;
double Gd_unused_372;
double Gd_unused_380;
double G_price_388;
double G_bid_396;
double G_ask_404;
double Gd_412;
double Gd_420;
double Gd_428;
bool Gi_436;
int Gi_440 = 0;
int Gi_444;
int Gi_448 = 0;
double Gd_452;
int G_pos_460 = 0;
int Gi_464;
double Gd_468 = 0.0;
bool Gi_476 = FALSE;
bool Gi_480 = FALSE;
bool Gi_484 = FALSE;
int Gi_488;
bool Gi_492 = FALSE;
int G_datetime_496 = 0;
int G_datetime_500 = 0;
double Gd_504;
double Gd_512;
double Gd_520;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   if (Digits == 3 || Digits == 5) Gd_520 = 10.0 * Point;
   else Gd_520 = Point;
   Gd_428 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   return (0);
}
		 	      				 	  	   			 		 					 	   	 	     				 	 	    	  	 		  			   	  	 	  	 			 	 				  	   				 			  		 	   	 			   		  	 	  	 		  	    
// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectsDeleteAll();
   return (0);
}
				  			  				 	          	 	   			  	 			   	  	  	  		 		   	 		 		 		    		 	   		 	   					  	 		  		 	    			  		  		  	 					   	 		 	 			
// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double order_lots_0;
   double order_lots_8;
   double iclose_16;
   double iclose_24;
   string text_44;
   string text_52;
   if (Compound) Lots = AccountBalance() / Pembagi;
   f0_9();
   Gd_428 = MarketInfo(Symbol(), MODE_SPREAD) * Gd_520;
   Comment("");
   f0_1(3, "NAMA", AccountName());
   f0_1(4, "No. ACC", AccountNumber());
   f0_1(5, "BROKER", AccountCompany());
   f0_1(6, "LEVERAGE", "1:" + DoubleToStr(AccountLeverage(), 0));
   f0_1(7, "BALANCE", DoubleToStr(AccountBalance(), 2));
   f0_1(8, "EQUITY", DoubleToStr(AccountEquity(), 2));
   f0_1(9, "MAGIC", DoubleToStr(magic, 0));
   f0_1(11, "L O C A L", TimeToStr(TimeLocal()));
   f0_1(14, "PROPIT", DoubleToStr(AccountProfit(), 2));
   f0_1(15, "TOTAL OP", OrdersTotal());
   string Ls_32 = "2014.30.2";
   int str2time_40 = StrToTime(Ls_32);
   if (TimeCurrent() >= str2time_40) {
      text_44 = "STOP !!! SUDAH KADALUARSA";
      ObjectCreate("Masa", OBJ_LABEL, 0, 0, 1.0);
      ObjectSet("Masa", OBJPROP_CORNER, 2);
      ObjectSet("Masa", OBJPROP_XDISTANCE, 220);
      ObjectSet("Masa", OBJPROP_YDISTANCE, 10);
      return (ObjectSetText("Masa", text_44, 40, "Times New Roman", Red));
   }
   if (JamTrading) {
      if (!(Hour() >= MulaiJam && Hour() <= StopJam)) {
         f0_4();
         Comment("Blum Waktunya Trading!");
         return (0);
      }
   }
   if (Target) {
      if (AccountEquity() > Akumulasi) {
         f0_4();
         text_52 = "STOP !!! Target Sudah Tercapai";
         ObjectCreate("Target", OBJ_LABEL, 0, 0, 1.0);
         ObjectSet("Target", OBJPROP_CORNER, 2);
         ObjectSet("Target", OBJPROP_XDISTANCE, 220);
         ObjectSet("Target", OBJPROP_YDISTANCE, 10);
         ObjectSetText("Target", text_52, 40, "Times New Roman", Red);
         return (0);
      }
   }
   string text_60 = "Lagi ngedance Boss !!! ";
   ObjectCreate("news", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("news", OBJPROP_CORNER, 2);
   ObjectSet("news", OBJPROP_XDISTANCE, 220);
   ObjectSet("news", OBJPROP_YDISTANCE, 10);
   ObjectSetText("news", text_60, 40, "Times New Roman", G_color_112);
   string Ls_68 = "false";
   string Ls_76 = "false";
   if (Gi_352 == FALSE || (Gi_352 && (StopJam > MulaiJam && (Hour() >= MulaiJam && Hour() <= StopJam)) || (MulaiJam > StopJam && (!(Hour() >= StopJam && Hour() <= MulaiJam))))) Ls_68 = "true";
   if (Gi_352 && (StopJam > MulaiJam && (!(Hour() >= MulaiJam && Hour() <= StopJam))) || (MulaiJam > StopJam && (Hour() >= StopJam && Hour() <= MulaiJam))) Ls_76 = "true";
   if (PakeTrailing) f0_17(LockPropit, TrailingStop, G_price_388);
   if (CloseAll) {
      if (TimeCurrent() >= Gi_444) {
         f0_4();
         Print("Waktu_Habis");
      }
   }
   if (Gi_440 == Time[0]) return (0);
   Gi_440 = Time[0];
   double Ld_84 = f0_6();
   if (UseEquityStop) {
      if (Ld_84 < 0.0 && MathAbs(Ld_84) > TotalEquityRisk / 100.0 * f0_8()) {
         f0_4();
         Print("Beres");
         Gi_492 = FALSE;
      }
   }
   Gi_464 = f0_14();
   if (Gi_464 == 0) Gi_436 = FALSE;
   for (G_pos_460 = OrdersTotal() - 1; G_pos_460 >= 0; G_pos_460--) {
      OrderSelect(G_pos_460, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_BUY) {
            Gi_480 = TRUE;
            Gi_484 = FALSE;
            order_lots_0 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_SELL) {
            Gi_480 = FALSE;
            Gi_484 = TRUE;
            order_lots_8 = OrderLots();
            break;
         }
      }
   }
   if (Gi_464 > 0 && Gi_464 <= MaxTrades) {
      RefreshRates();
      Gd_412 = f0_3();
      Gd_420 = f0_7();
      if (Gi_480 && Gd_412 - Ask >= PipsStep * Gd_520) Gi_476 = TRUE;
      if (Gi_484 && Bid - Gd_420 >= PipsStep * Gd_520) Gi_476 = TRUE;
   }
   if (Gi_464 < 1) {
      Gi_484 = FALSE;
      Gi_480 = FALSE;
      Gi_476 = TRUE;
      Gd_364 = AccountEquity();
   }
   if (Gi_476) {
      Gd_412 = f0_3();
      Gd_420 = f0_7();
      if (Gi_484) {
         if (CutLoss || Ls_76 == "true") {
            f0_2(0);
            Gd_452 = NormalizeDouble(LotExponent * order_lots_8, LotsDigits);
         } else Gd_452 = f0_12(OP_SELL);
         if (Marti && Ls_68 == "true") {
            Gi_448 = Gi_464;
            if (Gd_452 > 0.0) {
               RefreshRates();
               Gi_488 = f0_13(1, Gd_452, Bid, G_slippage_196, Ask, 0, 0, Komentar + "-" + Gi_448, magic, 0, CLR_NONE);
               if (Gi_488 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               Gd_420 = f0_7();
               Gi_476 = FALSE;
               Gi_492 = TRUE;
            }
         }
      } else {
         if (Gi_480) {
            if (CutLoss || Ls_76 == "true") {
               f0_2(1);
               Gd_452 = NormalizeDouble(LotExponent * order_lots_0, LotsDigits);
            } else Gd_452 = f0_12(OP_BUY);
            if (Marti && Ls_68 == "true") {
               Gi_448 = Gi_464;
               if (Gd_452 > 0.0) {
                  Gi_488 = f0_13(0, Gd_452, Ask, G_slippage_196, Bid, 0, 0, Komentar + "-" + Gi_448, magic, 0, CLR_NONE);
                  if (Gi_488 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  Gd_412 = f0_3();
                  Gi_476 = FALSE;
                  Gi_492 = TRUE;
               }
            }
         }
      }
   }
   if (Gi_108 < Istirahat && LanjutTrade) {
      if (Gi_476 && Gi_464 < 1) {
         iclose_16 = iClose(Symbol(), 0, 2);
         iclose_24 = iClose(Symbol(), 0, 1);
         G_bid_396 = Bid;
         G_ask_404 = Ask;
         if ((!Gi_484) && !Gi_480 && Ls_68 == "true") {
            Gi_448 = Gi_464;
            if (iclose_16 > iclose_24) {
               Gd_452 = f0_12(OP_SELL);
               if (Gd_452 > 0.0) {
                  Gi_488 = f0_13(1, Gd_452, G_bid_396, G_slippage_196, G_bid_396, 0, 0, Komentar + "-" + Gi_448, magic, 0, CLR_NONE);
                  Gi_108++;
                  if (Gi_488 < 0) {
                     Print(Gd_452, "Error: ", GetLastError());
                     return (0);
                  }
                  Gd_412 = f0_3();
                  Gi_492 = TRUE;
               }
            } else {
               Gd_452 = f0_12(OP_BUY);
               if (Gd_452 > 0.0) {
                  Gi_488 = f0_13(0, Gd_452, G_ask_404, G_slippage_196, G_ask_404, 0, 0, Komentar + "-" + Gi_448, magic, 0, CLR_NONE);
                  Gi_108++;
                  if (Gi_488 < 0) {
                     Print(Gd_452, "Error: ", GetLastError());
                     return (0);
                  }
                  Gd_420 = f0_7();
                  Gi_492 = TRUE;
               }
            }
         }
      }
      if (Gi_488 > 0) Gi_444 = TimeCurrent() + 60.0 * (60.0 * Gd_344);
      Gi_476 = FALSE;
   }
   Gi_464 = f0_14();
   G_price_388 = 0;
   double Ld_92 = 0;
   for (G_pos_460 = OrdersTotal() - 1; G_pos_460 >= 0; G_pos_460--) {
      OrderSelect(G_pos_460, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            G_price_388 += OrderOpenPrice() * OrderLots();
            Ld_92 += OrderLots();
         }
      }
   }
   if (Gi_464 > 0) G_price_388 = NormalizeDouble(G_price_388 / Ld_92, Digits);
   if (Gi_492) {
      for (G_pos_460 = OrdersTotal() - 1; G_pos_460 >= 0; G_pos_460--) {
         OrderSelect(G_pos_460, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               G_price_356 = G_price_388 + TakePropit * Gd_520;
               Gd_unused_372 = G_price_356;
               Gd_468 = G_price_388 - StopLoss * Gd_520;
               Gi_436 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_SELL) {
               G_price_356 = G_price_388 - TakePropit * Gd_520;
               Gd_unused_380 = G_price_356;
               Gd_468 = G_price_388 + StopLoss * Gd_520;
               Gi_436 = TRUE;
            }
         }
      }
   }
   if (Gi_492) {
      if (Gi_436 == TRUE) {
         for (G_pos_460 = OrdersTotal() - 1; G_pos_460 >= 0; G_pos_460--) {
            OrderSelect(G_pos_460, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) OrderModify(OrderTicket(), G_price_388, OrderStopLoss(), G_price_356, 0, White);
            Gi_492 = FALSE;
         }
      }
   }
   return (0);
}
	 		   			 			  		    	  	 	 		   		    	 	         	 						  		  	 						   	  		  				 	 			 	 		 			 	  	  	 	 	  	    	  				 		  		  	 	  		
// 9A116C50D133C8648404081885194300
double f0_10(double Ad_0) {
   return (NormalizeDouble(Ad_0, Digits));
}
				 	  	  		  		    			   	  		 			 	 				  	 	 	  			 	 		 		  		 	 	 	      		   	 	    		     	 	 				 	 						    	 		   	 				 		  		 		  	
// 169720DB8C7DA7F48F483E787B4A2725
int f0_2(bool Ai_0 = TRUE) {
   int Ai_4 = 0;
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      if (OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY && Ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), f0_10(Bid), 5, CLR_NONE)) {
                     Print("Error Tutup BUY " + OrderTicket());
                     Ai_4 = -1;
                  }
               } else {
                  if (G_datetime_496 == iTime(NULL, 0, 0)) return (-2);
                  G_datetime_496 = iTime(NULL, 0, 0);
                  Print("Mesti Tutup BUY " + OrderTicket() + ". Trade Context Sibuk");
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && Ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!(!OrderClose(OrderTicket(), OrderLots(), f0_10(Ask), 5, CLR_NONE))) continue;
                  Print("Error Tutup SELL " + OrderTicket());
                  Ai_4 = -1;
                  continue;
               }
               if (G_datetime_500 == iTime(NULL, 0, 0)) return (-2);
               G_datetime_500 = iTime(NULL, 0, 0);
               Print("Mesti Tutup SELL " + OrderTicket() + ". Trade Context Sibuk");
               return (-2);
            }
         }
      }
   }
   return (Ai_4);
}
	 			 	 		 	 					  	  	 	 			 	  			 			 	 	 		        					     	  	  		  						   	   	 	 		  		  	 		  		  		 	 				  	 		  	 			     	   	 	
// BD1F338B493E3233DF78411E167716E8
double f0_12(int A_cmd_0) {
   double lots_4;
   int datetime_12;
   switch (Transisi) {
   case 0:
      lots_4 = Lots;
      break;
   case 1:
      lots_4 = NormalizeDouble(Lots * MathPow(LotExponent, Gi_448), LotsDigits);
      break;
   case 2:
      datetime_12 = 0;
      lots_4 = Lots;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
               if (datetime_12 < OrderCloseTime()) {
                  datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) {
                     lots_4 = NormalizeDouble(OrderLots() * LotExponent, LotsDigits);
                     continue;
                  }
                  lots_4 = Lots;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), A_cmd_0, lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (lots_4);
}
	  					 			  	  		 		  					   	  				     			 	 	  	 	 	 			 		      	 		 	 	  		    					  				        				      	 	 	   	  	   			 		    			 
// CBBD1151F6D49BC6C817A0B96D15036D
int f0_14() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}
	 			 		 	 	 		  	  	   		 			  	 			 	   	 	 	 	      	 				  		 	  	 	 	  			  	   	 			 	 						  	     		     	 			 	 	 		 	  			  		 	   		 
// 41BB59E8D36C416E4C62910D9E765220
void f0_4() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, G_slippage_196, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, G_slippage_196, Gold);
         }
         Sleep(1000);
      }
   }
}
	 			 				 	 		 		  	    	 			    			 	 	 	 	 	        						  	  	  	 			  			 		   	 	 	 	 			 		  	  	  		   	 	 			   	 		 		 			  	  	   			
// C159FD8BED695B6E6A109D3B72C199C3
int f0_13(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_unused_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch (Ai_0) {
   case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_11(Ad_24, StopLoss), f0_15(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_11(Ad_24, StopLoss), f0_15(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         RefreshRates();
         ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_11(Bid, StopLoss), f0_15(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_0(Ad_24, StopLoss), f0_5(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_0(Ad_24, StopLoss), f0_5(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_0(Ask, StopLoss), f0_5(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}
			 					     	 	  			      	    		 			 							  	 	 	 		 	 		 	 			   		  		 	 	  	   	      		  		    		  		  					 	  				  				 		 	 			 				
// A04259EF619300E271488B8ABD9DF8A9
double f0_11(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Gd_520);
}
					      	 	 	    	 			  										  	 		 	  			    	   			 	 			  		     		 	     		 	  	 	  	 	  			 	 		 		 		 		 				 			  				 	 			      
// 0D578CA46072792DE50D5B9F5F5F8784
double f0_0(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Gd_520);
}
	  	     					 	 		   						 				  	   	       		 	 	 	  	 	  	 	   			  		  	 	 		 			 						  		  				  		  		     	 		    		    	  	 	   	    
// CE75B31DDDC1519B313C4C612EF22D86
double f0_15(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Gd_520);
}
	    						 	 	 				 	   		          		 	  	 		   				 			   	 	   		  					  	 					  	 		 	 		 	 		   	 	  	  	  	  	    	   		    	 	   						
// 4347D7B92E8469B198EAA742F66BBE62
double f0_5(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Gd_520);
}
	 	   	 		  						 	   	 	   	 	  	   			 		  		   		   			       				  		 	 					 			   	  			  					 		      		 		 			  		 	  	 	       			 	 	
// 4A186EA1A04A05E39FD2E7A94BB28576
double f0_6() {
   double Ld_ret_0 = 0;
   for (G_pos_460 = OrdersTotal() - 1; G_pos_460 >= 0; G_pos_460--) {
      OrderSelect(G_pos_460, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}
	 	 	    	   	 	 	 		 				  					 	 	  	  			  		  	  	  		 	 	 	 		 		  	 			 	 	 	 		 		   	  				 			    	 		  				 		 					   	 	 	 	 		     
// FDD5E0C68EEEAC73C07299767285F173
void f0_17(int Ai_0, int Ai_4, double A_price_8) {
   int Li_16;
   double order_stoploss_20;
   double price_28;
   if (Ai_4 != 0) {
      for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
         if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == magic) {
               if (OrderType() == OP_BUY) {
                  Li_16 = NormalizeDouble((Bid - A_price_8) / Gd_520, 0);
                  if (Li_16 < Ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Bid - Ai_4 * Gd_520;
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, White);
               }
               if (OrderType() == OP_SELL) {
                  Li_16 = NormalizeDouble((A_price_8 - Ask) / Gd_520, 0);
                  if (Li_16 < Ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Ask + Ai_4 * Gd_520;
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Blue);
               }
            }
            Sleep(1000);
         }
      }
   }
}
			  		     	 		   	 	 		      				  			 			 					 			    	  	  					      	  		   		   	   	 	 	 			  	 	   	 	 			  						     		  	  							  
// 91C97865111C4DD6B44C584F4B9358BB
double f0_8() {
   if (f0_14() == 0) Gd_504 = AccountEquity();
   if (Gd_504 < Gd_512) Gd_504 = Gd_512;
   else Gd_504 = AccountEquity();
   Gd_512 = AccountEquity();
   return (Gd_504);
}
			 			 	     			  			 	    	  	 		 												 	 	 	  	 	 		   			    	  		 			  	          	   		   			  		 						 		 				   			 		   			 		 	
// 262336F736ADFEEC641C03BB3514631C
double f0_3() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}
	   			 			   								 	 		 	  	    					  					  		 	  		  		     	    					 						     		   	  	 	   		 	 		 		  		 		   		   	   		     	 		 	
// 599A26C25DF2561FBAA884F47E1B315C
double f0_7() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}
	  					 			  	  		 		  					   	  				     			 	 	  	 	 	 			 		      	 		 	 	  		    					  				        				      	 	 	   	  	   			 		    			 
// 938363B042E987609BD8B876255B9679
void f0_9() {
   if (iClose(Symbol(), PERIOD_M15, 0) > iClose(Symbol(), PERIOD_M15, 2)) G_color_132 = G_color_136;
   if (iClose(Symbol(), PERIOD_M15, 0) < iClose(Symbol(), PERIOD_M15, 2)) G_color_132 = G_color_140;
   if (iClose(Symbol(), PERIOD_M15, 0) > iClose(Symbol(), PERIOD_M15, 1)) G_color_132 = G_color_148;
   if (iClose(Symbol(), PERIOD_M15, 0) < iClose(Symbol(), PERIOD_M15, 1)) G_color_132 = G_color_152;
   if (iOpen(Symbol(), 0, 0) > iOpen(Symbol(), 0, 1)) G_color_112 = G_color_116;
   if (iOpen(Symbol(), 0, 0) < iOpen(Symbol(), 0, 1)) G_color_112 = G_color_120;
   if (iClose(Symbol(), 0, 0) > iClose(Symbol(), 0, 1)) G_color_112 = G_color_124;
   if (iClose(Symbol(), 0, 0) < iClose(Symbol(), 0, 1)) G_color_112 = G_color_128;
   string text_0 = "::: K-heart Tho 2013 :::";
   ObjectCreate("Laporan", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Laporan", text_0, 9, "Arial ", G_color_112);
   ObjectSet("Laporan", OBJPROP_CORNER, 2);
   ObjectSet("Laporan", OBJPROP_XDISTANCE, 5);
   ObjectSet("Laporan", OBJPROP_YDISTANCE, 5);
   ObjectCreate("Time", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Time", OBJPROP_CORNER, 2);
   ObjectSet("Time", OBJPROP_XDISTANCE, 5);
   ObjectSet("Time", OBJPROP_YDISTANCE, 20);
   ObjectSet("Time", OBJPROP_BACK, TRUE);
   ObjectSetText("Time", "" + TimeToStr(TimeLocal()) + "", 10, "Tahoma Bold", G_color_132);
   string text_8 = "Scalper_FX";
   ObjectCreate("text_4", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("text_4", OBJPROP_CORNER, 0);
   ObjectSet("text_4", OBJPROP_XDISTANCE, 220);
   ObjectSet("text_4", OBJPROP_YDISTANCE, 10);
   ObjectSetText("text_4", text_8, 40, "Times New Roman", G_color_132);
   string text_16 = "------------------";
   ObjectCreate("GARIS1", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("GARIS1", text_16, 11, "Arial Bold", G_color_112);
   ObjectSet("GARIS1", OBJPROP_CORNER, 1);
   ObjectSet("GARIS1", OBJPROP_XDISTANCE, 5);
   ObjectSet("GARIS1", OBJPROP_YDISTANCE, 10);
   string text_24 = "Boegies FX    ";
   ObjectCreate("NAMA", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("NAMA", text_24, 10, "Times New Roman", G_color_132);
   ObjectSet("NAMA", OBJPROP_CORNER, 1);
   ObjectSet("NAMA", OBJPROP_XDISTANCE, 5);
   ObjectSet("NAMA", OBJPROP_YDISTANCE, 20);
   string Ls_unused_32 = "-----------------";
   ObjectCreate("GARIS2", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("GARIS2", text_16, 11, "Arial Bold", G_color_112);
   ObjectSet("GARIS2", OBJPROP_CORNER, 1);
   ObjectSet("GARIS2", OBJPROP_XDISTANCE, 5);
   ObjectSet("GARIS2", OBJPROP_YDISTANCE, 30);
   string text_40 = "Balance : $ " + DoubleToStr(AccountBalance(), 2);
   ObjectCreate("Modal", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Modal", text_40, 16, "Arial Bold", G_color_132);
   ObjectSet("Modal", OBJPROP_CORNER, 3);
   ObjectSet("Modal", OBJPROP_XDISTANCE, 5);
   ObjectSet("Modal", OBJPROP_YDISTANCE, 25);
   string text_48 = "Equity    : $ " + DoubleToStr(AccountEquity(), 2);
   ObjectCreate("Equity", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Equity", text_48, 16, "Arial Bold", G_color_112);
   ObjectSet("Equity", OBJPROP_CORNER, 3);
   ObjectSet("Equity", OBJPROP_XDISTANCE, 5);
   ObjectSet("Equity", OBJPROP_YDISTANCE, 5);
   string text_56 = "-----------------------";
   ObjectCreate("GARIS", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("GARIS", text_56, 11, "Arial Bold", G_color_112);
   ObjectSet("GARIS", OBJPROP_CORNER, 0);
   ObjectSet("GARIS", OBJPROP_XDISTANCE, 5);
   ObjectSet("GARIS", OBJPROP_YDISTANCE, 10);
   string text_64 = "     Trader FX";
   ObjectCreate("NAM", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("NAM", text_64, 10, "Arial Black", G_color_132);
   ObjectSet("NAM", OBJPROP_CORNER, 0);
   ObjectSet("NAM", OBJPROP_XDISTANCE, 5);
   ObjectSet("NAM", OBJPROP_YDISTANCE, 20);
   string text_72 = "-----------------------";
   ObjectCreate("GARS2", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("GARS2", text_72, 11, "Arial Bold", G_color_112);
   ObjectSet("GARS2", OBJPROP_CORNER, 0);
   ObjectSet("GARS2", OBJPROP_XDISTANCE, 5);
   ObjectSet("GARS2", OBJPROP_YDISTANCE, 30);
}
		 				   		  		  	 		 		 			  			 					 	  							  	     			  		        	 	 		  	     	 		  	 	      	 					 	 	  	 				  	    	 			  		   		  
// 10285DBDE490577EAEDC4F9E2C224CEB
void f0_1(int Ai_0, string As_4, string As_12) {
   int Li_20;
   int Li_24;
   if ((!IsTradeAllowed()) || !IsExpertEnabled()) {
      ObjectDelete("baris0");
      return;
   }
   switch (Ai_0) {
   case 3:
      Li_20 = 100;
      Li_24 = 85;
      break;
   case 4:
      Li_20 = 100;
      Li_24 = 100;
      break;
   case 5:
      Li_20 = 100;
      Li_24 = 115;
      break;
   case 6:
      Li_20 = 100;
      Li_24 = 130;
      break;
   case 7:
      Li_20 = 100;
      Li_24 = 145;
      break;
   case 8:
      Li_20 = 100;
      Li_24 = 160;
      break;
   case 9:
      Li_20 = 100;
      Li_24 = 175;
      break;
   case 10:
      Li_20 = 100;
      Li_24 = 190;
      break;
   case 11:
      Li_20 = 100;
      Li_24 = 205;
      break;
   case 14:
      Li_20 = 100;
      Li_24 = 220;
      break;
   case 15:
      Li_20 = 100;
      Li_24 = 235;
      break;
   case 16:
      Li_20 = 100;
      Li_24 = 215;
      break;
   case 17:
      Li_20 = 100;
      Li_24 = 225;
      break;
   case 18:
      Li_20 = 100;
      Li_24 = 235;
      break;
   case 19:
      Li_20 = 100;
      Li_24 = 245;
      break;
   case 20:
      Li_20 = 100;
      Li_24 = 255;
      break;
   case 21:
      Li_20 = 100;
      Li_24 = 265;
      break;
   case 22:
      Li_20 = 100;
      Li_24 = 280;
   }
   f0_16("baris" + Ai_0, As_4, 10, Li_20, Li_24, G_color_132, 4);
   f0_16("baris_" + Ai_0, ":", 10, Li_20 + 100, Li_24, G_color_132, 4);
   if (Ai_0 != 21) f0_16("baris-" + Ai_0, As_12, 10, Li_20 + 120, Li_24, G_color_112, 4);
}
	 		 	 			 		   		   		  	 	  	   		 	  	 	  	      								 			  	 	 				      		  	 		 	 		  	 		 	 	 	  	 		 	 	       	   			 		 			  	 		 		
// DE504C9929277C86DB5B51DD1C0B0E9A
void f0_16(string A_name_0, string A_text_8, int A_fontsize_16, int A_x_20, int A_y_24, color A_color_28, int A_corner_32) {
   if (ObjectFind(A_name_0) < 0) ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet(A_name_0, OBJPROP_CORNER, A_corner_32);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_20);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_24);
   ObjectSetText(A_name_0, A_text_8, A_fontsize_16, "Arial", A_color_28);
}