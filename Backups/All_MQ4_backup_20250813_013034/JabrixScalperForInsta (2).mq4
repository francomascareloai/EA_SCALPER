
#property copyright "koingFx"
#property link      ""

extern int StopLoss = 3;
extern int trailling = 4;
extern double timediffer = 7.0;
extern double MaxSpread = 4.0;
extern double ManualLotsize = 0.1;
extern bool InstaRule = true;

extern double CloseAfter = 3;
extern bool MoneyManagement = false;
extern int Risk = 5;
extern bool SafetyMode = FALSE;
extern int Magic = 06101987;
double price;
int ticket,currentTime;
int order_total;
bool Gi_168;
int count;
int count_1,PL,bar,bars;
int datetime_1;
int datetime_2;
bool Gi_188;
bool Gi_192;
double SellPrice;
double Gd_208;
double pips = 1.0;
double StopLvl;
double Spread;
int iPoint;
double slBuyPips;
double slSellPips;


int init() 
{
   bar=Bars;
   if (Digits == 3 || Digits == 5) iPoint = 10;
   else iPoint = 1;
   StopLvl = MarketInfo(Symbol(), MODE_STOPLEVEL);
   StopLoss = MathMax(StopLoss, StopLvl / iPoint);
   trailling = MathMax(trailling, StopLvl / iPoint);
   if (SafetyMode) pips = 2;
   else pips = 1;
   return (0);
}
		      	 	 		 					  	 		 		 			 	    	  	  	 	 	 				     	    			 			 		   					 	 	 	 	 				   			 	 			   					 		 	 					  			 	 							   
int deinit() {
   return (0);
}
	   			 			   			 				  	  	 	 				 				 		 	 		   	     	   		   			  	  	 		 		 	  	  			    	 	 	  		  							 			   				      			 			 		  	  

int start() 
{
   bars=Bars;
   currentTime=TimeCurrent();
   double ask = MarketInfo(Symbol(), MODE_ASK);
   double bid = MarketInfo(Symbol(), MODE_BID);
   Spread = (ask - bid) / Point / iPoint;
   order_total = OrdersTotal();
      int buys=0,sells=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
            if (OrderSymbol()==Symbol()&&OrderMagicNumber()==Magic)
               {
                  if(OrderType()==OP_BUY)  buys++;
                  if(OrderType()==OP_SELL) sells++;
               }
        }
     }
   
   ShowComment();
   
   //if (buys+sells < 1) 
     // {
         if (slBuyPips > 0.0 || slSellPips > 0.0) 
            {
               slBuyPips = 0;
               slSellPips = 0;
            }
         if (SellPrice < Ask - pips * Point) 
            {
               count++;
               SellPrice = NormalizeDouble(Ask, Digits);
               if (Gi_188 == FALSE) 
                  {
                     datetime_1 = TimeCurrent();
                     Gi_188 = TRUE;
                  }
            } 
         else 
            {
               SellPrice = 0;
               count = 0;
               Gi_188 = FALSE;
               datetime_1 = 0;
            }
         if (Gd_208 > Ask + pips * Point) 
            {
               count_1++;
               Gd_208 = NormalizeDouble(Ask, Digits);
               if (Gi_192 == FALSE) 
                  {
                     datetime_2 = TimeCurrent();
                     Gi_192 = TRUE;
                  }
            } 
         else 
            {
               Gd_208 = 0;
               count_1 = 0;
               Gi_192 = FALSE;
               datetime_2 = 0;
            }
         if (count == pips * iPoint || count_1 == pips * iPoint && Spread > MaxSpread) Print("Spread too large for ");
         if (count == pips * iPoint || count_1 == pips * iPoint && Spread <= MaxSpread) 
            {
               Gi_168 = FALSE;
               if (count < count_1) 
                  {
                     if (TimeCurrent() - datetime_2 == timediffer&&sells-buys<1) 
                        {
                           RefreshRates();
                           ticket = OrderSend(Symbol(), OP_SELL, f0_3(), Bid, 10, 0, 0, "", Magic, 0, Red);
                           if (ticket > 0) 
                              {
                                 if (StopLoss * iPoint > StopLvl) 
                                    {
                                       if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                                          {
                                             while (!IsTradeAllowed()) Sleep(500);
                                             RefreshRates();
                                             price = 0;
                                             if (StopLoss * iPoint > StopLvl) price = NormalizeDouble(Ask + StopLoss * Point * iPoint, Digits);
                                             if (!OrderModify(OrderTicket(), OrderOpenPrice(), price, 0, 0, Red)) Gi_168 = TRUE;
                                          }
                                    }
                              }
                        }
                  } 
               else 
                  {
                     if (TimeCurrent() - datetime_1 == timediffer&&buys-sells<1) 
                        {
                           RefreshRates();
                           ticket = OrderSend(Symbol(), OP_BUY, f0_3(), Ask, 10, 0, 0, "", Magic, 0, Green);
                           if (ticket > 0) 
                              {
                                 if (StopLoss * iPoint > StopLvl) 
                                    {
                                       if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                                          {
                                             while (!IsTradeAllowed()) Sleep(500);
                                             RefreshRates();
                                             price = 0;
                                             if (StopLoss * iPoint > StopLvl) price = NormalizeDouble(Bid - StopLoss * Point * iPoint, Digits);
                                             if (!OrderModify(OrderTicket(), OrderOpenPrice(), price, 0, 0, Green)) Gi_168 = TRUE;
                                          }
                                    }
                              }
                        }
                  }
         
               SellPrice = 0;
               Gd_208 = 0;
               count = 0;
               count_1 = 0;
               Gi_188 = FALSE;
               Gi_192 = FALSE;
               datetime_1 = 0;
               datetime_2 = 0;
            }
         if (SellPrice == 0.0) SellPrice = NormalizeDouble(Ask, Digits);
         if (Gd_208 == 0.0) Gd_208 = NormalizeDouble(Ask, Digits);
         
      //} 
   if (InstaRule)
      {
         if (CloseAfter>0)
            {
               for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) 
                  {
                     OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) 
                        {
                           if (currentTime - OrderOpenTime() >= CloseAfter*60)
                           f0_0();
                        }
                  }
               return (0.0);
            }
      }
   else f0_0();
   
   return (0);
}
	 		  				 				 	      		 	 	   		 	  	  	 	 		   	 		 	 				 		     	     	    	  		  			 			   		 			       	 	    	 			  		 	     		 	   				 

void ShowComment() {
   Comment("\n     :: Server Date Time: ", Year(), ".", Month(), ".", Day(), "   ", TimeToStr(TimeCurrent(), TIME_SECONDS), 
      "\n\n\n    ------------------------------------------------------------", 
      "\n\n      :: Broker   :   ", TerminalCompany(), 
      "\n      :: Acc. Name  :  ", AccountName(), 
      "\n      :: Acc, Number   :   ", AccountNumber(), 
      "\n      :: Acc. Leverage:   1 : ", AccountLeverage(), 
      "\n      :: Equity   :   ", AccountEquity(), 
      "\n\n    ------------------------------------------------------------", 
      "\n\n     :: StopLevel  :   ", DoubleToStr(StopLvl / iPoint, 1), " pips", 
      "\n     :: Spread  :   ", DoubleToStr(Spread, 1), " pips", 
   "\n     :: Next Lots  :   ", DoubleToStr(f0_3(), 2));
   f0_1("z3JS" + Symbol() + "1", 15, 41, "   J        S", 14, "Arial Bold", Red, 0);
   f0_1("z3JS" + Symbol() + "2", 15, 42, "**    abrix     calper EA **", 12, "Arial", DodgerBlue, 0);
}
	 					  	 	  		    		    	  	 	 	 							 		 			 	     				 		 	   	  		  			 	   	 	   	 	   				   			   				    	    	      	   	 		      	 	

double f0_3() {
   
   double Ld_0;
   int Li_8;
   double Ld_12;
   double iopen_20 = 0;
   string str_concat_28 = "";
   int str_len_36 = StringLen(Symbol());
   int Li_40 = StringFind(Symbol(), "USD");
   double lotstep_44 = MarketInfo(Symbol(), MODE_LOTSTEP);
   double Ld_52 = MarketInfo(Symbol(), MODE_MAXLOT);
   double Ld_60 = MarketInfo(Symbol(), MODE_MINLOT);
   if (lotstep_44 == 1.0) Li_8 = 0;
   if (lotstep_44 == 0.1) Li_8 = 1;
   if (lotstep_44 == 0.01) Li_8 = 2;
   if (Li_40 >= 3) Ld_12 = MathMin(MarketInfo(Symbol(), MODE_MAXLOT), AccountFreeMargin() * AccountLeverage() / Bid / MarketInfo(Symbol(), MODE_LOTSIZE));
   if (Li_40 == 0) Ld_12 = MathMin(MarketInfo(Symbol(), MODE_MAXLOT), AccountFreeMargin() * AccountLeverage() / MarketInfo(Symbol(), MODE_LOTSIZE));
   if (Li_40 < 0) {
      if (str_len_36 > 6) str_concat_28 = StringConcatenate(StringSubstr(Symbol(), 0, 3), "USD" + StringSubstr(Symbol(), 6, str_len_36));
      else str_concat_28 = StringConcatenate(StringSubstr(Symbol(), 0, 3), "USD");
      iopen_20 = iOpen(str_concat_28, PERIOD_H1, 0);
      if (iopen_20 <= 0.0) {
         if (str_len_36 > 6) str_concat_28 = StringConcatenate("USD", StringSubstr(Symbol(), 3, 3) + StringSubstr(Symbol(), 6, str_len_36));
         else str_concat_28 = StringConcatenate("USD", StringSubstr(Symbol(), 3, 3));
         iopen_20 = iOpen(str_concat_28, PERIOD_H1, 0);
         Ld_12 = AccountFreeMargin() * AccountLeverage() / iopen_20 / MarketInfo(Symbol(), MODE_LOTSIZE);
      } else Ld_12 = MathMin(MarketInfo(Symbol(), MODE_MAXLOT), AccountFreeMargin() * AccountLeverage() / iopen_20 / MarketInfo(Symbol(), MODE_LOTSIZE));
   }
   Ld_12 = 0.75 * Ld_12;
   if (MoneyManagement) {
      Ld_0 = NormalizeDouble(AccountEquity(), Li_8) * Risk / 102.0 / 100.0;
      if (Ld_0 > Ld_12) Ld_0 = Ld_12;
      if (Ld_0 < Ld_60) Ld_0 = Ld_60;
      if (Ld_0 > Ld_52) Ld_0 = Ld_52;
   } 

   else Ld_0 = ManualLotsize;

   return (NormalizeDouble(Ld_0, Li_8));
}
	 	 		 			      	  						 		 		 		  		   	  	     		  		 		  	 	   		 	     			 	    					    	  			       			  	  		 				 	  		   		   	  	   	 

void f0_0() {
   
   double bid_0;
   double ask_8;
   double order_open_price_16;
   double Ld_24;
   double Ld_32;
   int magic_40;
   double point_44 = MarketInfo(Symbol(), MODE_POINT);
   int Li_52 = 1;
   if (trailling * iPoint <= StopLvl) Li_52 = -1;
   for (int pos_56 = OrdersTotal() - 1; pos_56 >= 0; pos_56--) {
      if (OrderSelect(pos_56, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol()) {
         magic_40 = OrderMagicNumber();
         if (magic_40 == Magic) {
            if (OrderType() == OP_BUY) {
               if (StopLoss * iPoint <= StopLvl || Gi_168 == TRUE) {
                  if (OrderStopLoss() == 0.0)
                     if (slBuyPips == 0.0) slBuyPips = OrderOpenPrice() - StopLoss * iPoint * point_44;
                  if (OrderOpenPrice() - Ask >= StopLoss * iPoint * point_44) OrderClose(OrderTicket(), OrderLots(), Bid, 5 * iPoint, Blue);
               }
               if (Li_52 == -1) {
                  order_open_price_16 = OrderOpenPrice();
                  while (!IsTradeAllowed()) Sleep(500);
                  RefreshRates();
                  bid_0 = Bid;
                  if (slBuyPips == 0.0)
                     if (bid_0 - trailling * iPoint * point_44 > order_open_price_16) slBuyPips = bid_0 - trailling * iPoint * point_44;
                  if (slBuyPips > 0.0) {
                     if (bid_0 < slBuyPips)
                        if (OrderClose(OrderTicket(), OrderLots(), Bid, 5 * iPoint, Blue)) break;
                     if (bid_0 - trailling * iPoint * point_44 > order_open_price_16 && bid_0 - trailling * iPoint * point_44 > slBuyPips) slBuyPips = bid_0 - trailling * iPoint * point_44;
                  }
               }
               if (Li_52 == 1) {
                  order_open_price_16 = OrderOpenPrice();
                  Ld_24 = OrderStopLoss();
                  Ld_32 = Ld_24;
                  while (!IsTradeAllowed()) Sleep(500);
                  RefreshRates();
                  bid_0 = Bid;
                  if (bid_0 - trailling * iPoint * point_44 > order_open_price_16) Ld_32 = bid_0 - trailling * iPoint * point_44;
                  if (Ld_32 > Ld_24 && Ld_32 > order_open_price_16 && bid_0 - Ld_32 > StopLvl * point_44) {
                     if (!OrderModify(OrderTicket(), order_open_price_16, NormalizeDouble(Ld_32, Digits), OrderTakeProfit(), 0)) Print("Error Occured :  ", GetLastError());
                     else {
                        slBuyPips = 0;
                        slSellPips = 0;
                     }
                  }
               }
            }
            if (OrderType() == OP_SELL) {
               if (StopLoss * iPoint <= StopLvl || Gi_168 == TRUE) {
                  if (OrderStopLoss() == 0.0)
                     if (slSellPips == 0.0) slSellPips = OrderOpenPrice() + StopLoss * iPoint * point_44;
                  if (Bid - OrderOpenPrice() >= StopLoss * iPoint * point_44) OrderClose(OrderTicket(), OrderLots(), Ask, 5 * iPoint, Red);
               }
               if (Li_52 == -1) {
                  order_open_price_16 = OrderOpenPrice();
                  while (!IsTradeAllowed()) Sleep(500);
                  RefreshRates();
                  ask_8 = Ask;
                  if (slSellPips == 0.0)
                     if (order_open_price_16 - ask_8 > trailling * iPoint * point_44) slSellPips = order_open_price_16 + trailling * iPoint * point_44;
                  if (slSellPips > 0.0) {
                     if (ask_8 > slSellPips)
                        if (OrderClose(OrderTicket(), OrderLots(), Ask, 5 * iPoint, Blue)) break;
                     if (order_open_price_16 - ask_8 > trailling * iPoint * point_44 && ask_8 + trailling * iPoint * point_44 < slSellPips) slSellPips = ask_8 + trailling * iPoint * point_44;
                  }
               }
               if (Li_52 == 1) {
                  order_open_price_16 = OrderOpenPrice();
                  Ld_24 = OrderStopLoss();
                  Ld_32 = Ld_24;
                  while (!IsTradeAllowed()) Sleep(500);
                  RefreshRates();
                  ask_8 = Ask;
                  if (order_open_price_16 - ask_8 > trailling * iPoint * point_44 && Ld_24 > ask_8 + trailling * iPoint * point_44 || Ld_24 == 0.0) Ld_32 = ask_8 + trailling * iPoint * point_44;
                  if (Ld_32 < Ld_24 || Ld_24 == 0.0 && Ld_32 < order_open_price_16 && Ld_32 - ask_8 > StopLvl * point_44) {
                     if (!OrderModify(OrderTicket(), order_open_price_16, NormalizeDouble(Ld_32, Digits), OrderTakeProfit(), 0)) {
                        Print("Error Occured : ", GetLastError());
                        continue;
                     }
                     slBuyPips = 0;
                     slSellPips = 0;
                  }
               }
            }
         }
      }
   }
}
	 	      	  		 	   	  	   			 		 	     			   	 		 					 			 	   	  	 				     		    	 	  	  										 		  	   	   	 		  	 				 	  	 	 	   			  	

int f0_1(string A_name_0, int A_x_8, int A_y_12, string A_text_16, int A_fontsize_24, string A_fontname_28, color A_color_36, int A_window_40) {
   ObjectCreate(A_name_0, OBJ_LABEL, A_window_40, 0, 0);
   ObjectSet(A_name_0, OBJPROP_CORNER, 0);
   ObjectSet(A_name_0, OBJPROP_COLOR, A_color_36);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_8);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_12);
   ObjectSet(A_name_0, OBJPROP_BACK, FALSE);
   ObjectSetText(A_name_0, A_text_16, A_fontsize_24, A_fontname_28, A_color_36);
   return (0);
}