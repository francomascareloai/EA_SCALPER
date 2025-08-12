#property copyright "Copyright Matt Todorovski 2025"
#property version   "1.09"
#property strict

extern int Magic = 12345;
extern string Comment = "HF_MA_EA";
extern double Lotsize = 0.01;
extern int MaxBuySell = 35;

int lastBuyTicket, lastSellTicket;
datetime lastBuyAttempt, lastSellAttempt;
double hiddenBuyTrailStop, hiddenSellTrailStop;
bool buyTrailActivated, sellTrailActivated;
double buyTrailDistance, sellTrailDistance;
int buyOrderCount, sellOrderCount;
bool buyCloseConditionActive, sellCloseConditionActive; // Flags for 20-pip close condition
double maxEMADiff, minEMADiff; // Track max/min EMA3-EMA12 differences

double GetATR(int period=14) {return iATR(Symbol(), PERIOD_CURRENT, period, 0);}
int OnInit() {
   lastBuyTicket = LastOpenOrderTicket(OP_BUY);
   lastSellTicket = LastOpenOrderTicket(OP_SELL);
   buyTrailDistance = 21 * 10 * Point; // 21 pips (2.1 on XAUUSD)
   sellTrailDistance = 21 * 10 * Point; // 21 pips (2.1 on XAUUSD)
   buyOrderCount = CountOrdersByType(OP_BUY);
   sellOrderCount = CountOrdersByType(OP_SELL);
   buyCloseConditionActive = false; // Initialize as inactive
   sellCloseConditionActive = false; // Initialize as inactive
   maxEMADiff = -DBL_MAX; // Initialize to lowest possible for Buys
   minEMADiff = DBL_MAX; // Initialize to highest possible for Sells
   if(buyOrderCount > 0) {
      double highestPrice = GetHighestOrderOpenPrice(OP_BUY);
      if(Bid - highestPrice >= buyTrailDistance) {
         hiddenBuyTrailStop = Bid - buyTrailDistance;
         buyTrailActivated = true;
         Print("[Init] Buy trail activated for existing orders. Bid=", Bid, ", HighestPrice=", highestPrice, ", HiddenBuyTrailStop=", hiddenBuyTrailStop);
      }
   }
   if(sellOrderCount > 0) {
      double lowestPrice = GetLowestOrderOpenPrice(OP_SELL);
      if(lowestPrice - Ask >= sellTrailDistance) {
         hiddenSellTrailStop = Ask + sellTrailDistance;
         sellTrailActivated = true;
         Print("[Init] Sell trail activated for existing orders. Ask=", Ask, ", LowestPrice=", lowestPrice, ", HiddenSellTrailStop=", hiddenSellTrailStop);
      }
   }
   return INIT_SUCCEEDED;
}

void OnTick() {
   double EMA3 = iMA(Symbol(), PERIOD_M1, 3, 0, MODE_EMA, PRICE_OPEN, 0); // 3EMA based on current Open Price
   double EMA12 = iMA(Symbol(), PERIOD_M1, 12, 0, MODE_EMA, PRICE_CLOSE, 0); // 12EMA based on current Close Price
   double prevClose = iClose(Symbol(), PERIOD_M1, 1); // Close price of previous complete candle
   buyOrderCount = CountOrdersByType(OP_BUY);
   sellOrderCount = CountOrdersByType(OP_SELL);
   double gradientEMA3 = (EMA3 - iMA(Symbol(), PERIOD_M1, 3, 0, MODE_EMA, PRICE_OPEN, 1)) / Point;
   double gradientEMA12 = (EMA12 - iMA(Symbol(), PERIOD_M1, 12, 0, MODE_EMA, PRICE_CLOSE, 1)) / Point;
   double emaDifferencePips = (EMA3 - EMA12) / (10 * Point); // EMA3-EMA12 in pips

   // Enhanced logging with EMA3, EMA12, and prevClose when orders exist
   if(buyOrderCount > 0 || sellOrderCount > 0) {
      Print("[Tick] EMA3=", EMA3, ", EMA12=", EMA12, ", EMA3-EMA12=", emaDifferencePips, ", PrevClose=", prevClose, ", BuyCount=", buyOrderCount, ", SellCount=", sellOrderCount);
   }

   // Update max/min EMA differences and check new close condition
   if(buyOrderCount > 0) {
      maxEMADiff = MathMax(maxEMADiff, emaDifferencePips);
      if(emaDifferencePips <= maxEMADiff - 1.5) { // Close Buys if EMA3-EMA12 falls by 1.5 pips or more
         string buyMessage = "[EMA Diff] Buy orders closed. Trigger: EMA3-EMA12 fell by 1.5+ from max. Max=" + DoubleToString(maxEMADiff, 2) + ", Current=" + DoubleToString(emaDifferencePips, 2);
         CloseAllOrders(OP_BUY, buyMessage);
         buyOrderCount = CountOrdersByType(OP_BUY); // Recount after closure
      }
   } else {
      maxEMADiff = -DBL_MAX; // Reset when no Buy orders
   }

   if(sellOrderCount > 0) {
      minEMADiff = MathMin(minEMADiff, emaDifferencePips);
      if(emaDifferencePips >= minEMADiff + 1.5) { // Close Sells if EMA3-EMA12 rises by 1.5 pips or more
         string sellMessage = "[EMA Diff] Sell orders closed. Trigger: EMA3-EMA12 rose by 1.5+ from min. Min=" + DoubleToString(minEMADiff, 2) + ", Current=" + DoubleToString(emaDifferencePips, 2);
         CloseAllOrders(OP_SELL, sellMessage);
         sellOrderCount = CountOrdersByType(OP_SELL); // Recount after closure
      }
   } else {
      minEMADiff = DBL_MAX; // Reset when no Sell orders
   }

   // EMA-based closure conditions (real-time, checked every tick)
   if(EMA3 > EMA12) {
      if(sellOrderCount > 0) {
         CloseAllOrders(OP_SELL, "[EMA condition] Sell orders closed. Trigger: EMA3 > EMA12");
         sellOrderCount = CountOrdersByType(OP_SELL); // Recount after closure
      }
   } else if(EMA3 < EMA12) {
      if(buyOrderCount > 0) {
         CloseAllOrders(OP_BUY, "[EMA condition] Buy orders closed. Trigger: EMA3 < EMA12");
         buyOrderCount = CountOrdersByType(OP_BUY); // Recount after closure
      }
   }

   // Activate previous close condition after 20-pip move
   if(buyOrderCount > 0) {
      if(Bid > prevClose + 20 * 10 * Point) { // 20 pips = 2.0 on XAUUSD
         buyCloseConditionActive = true;
         Print("[Buy] Close condition activated. Bid=", Bid, ", PrevClose=", prevClose);
      }
      if(buyCloseConditionActive && Bid <= prevClose) {
         CloseAllOrders(OP_BUY, "[Prev Close] Buy orders closed. Trigger: Bid <= " + DoubleToString(prevClose, Digits));
         buyOrderCount = CountOrdersByType(OP_BUY); // Recount after closure
      }
   } else {
      buyCloseConditionActive = false; // Reset when no Buy orders
   }

   if(sellOrderCount > 0) {
      if(Ask < prevClose - 20 * 10 * Point) { // 20 pips = 2.0 on XAUUSD
         sellCloseConditionActive = true;
         Print("[Sell] Close condition activated. Ask=", Ask, ", PrevClose=", prevClose);
      }
      if(sellCloseConditionActive && Ask >= prevClose) {
         CloseAllOrders(OP_SELL, "[Prev Close] Sell orders closed. Trigger: Ask >= " + DoubleToString(prevClose, Digits));
         sellOrderCount = CountOrdersByType(OP_SELL); // Recount after closure
      }
   } else {
      sellCloseConditionActive = false; // Reset when no Sell orders
   }

   ManageHiddenTrailingStop();
   buyOrderCount = CountOrdersByType(OP_BUY); // Recount after trailing stop
   sellOrderCount = CountOrdersByType(OP_SELL);

   if(buyOrderCount < MaxBuySell && EMA3 > EMA12) { // Open Buys if EMA3 > EMA12
      if(buyOrderCount == 0 && sellOrderCount == 0) {
         if(gradientEMA3 > 5) {
            int ticket = OpenOrder(OP_BUY, Ask, Lotsize);
            if(ticket > 0) {
               lastBuyTicket = ticket;
               buyOrderCount = CountOrdersByType(OP_BUY);
               Print("[Open Buy] First order #", buyOrderCount, ". Trigger: EMA3 Gradient=", gradientEMA3);
               ManageHiddenTrailingStop();
               if(buyTrailActivated) {
                  for(int i = 0; i < OrdersTotal(); i++) {
                     if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), hiddenBuyTrailStop, OrderTakeProfit(), 0, clrNONE)) {
                           Print("[Error] Failed to modify Buy order #", OrderTicket(), " to hiddenBuyTrailStop=", hiddenBuyTrailStop, ". Error code: ", GetLastError());
                        }
                     }
                  }
               }
            }
         }
      } else if(lastBuyTicket > 0 && Ask >= OrderPrice(lastBuyTicket) + 15 * Point) {
         if(gradientEMA3 >= 0.04 && gradientEMA12 >= 0.04) {
            int ticket = OpenOrder(OP_BUY, Ask, Lotsize);
            if(ticket > 0) {
               lastBuyTicket = ticket;
               buyOrderCount = CountOrdersByType(OP_BUY);
               Print("[Open Buy] Order #", buyOrderCount, ". Trigger: Price +15pips, Gradients: EMA3=", gradientEMA3, ", EMA12=", gradientEMA12);
               ManageHiddenTrailingStop();
               if(buyTrailActivated) {
                  for(int i = 0; i < OrdersTotal(); i++) {
                     if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), hiddenBuyTrailStop, OrderTakeProfit(), 0, clrNONE)) {
                           Print("[Error] Failed to modify Buy order #", OrderTicket(), " to hiddenBuyTrailStop=", hiddenBuyTrailStop, ". Error code: ", GetLastError());
                        }
                     }
                  }
               }
            }
         }
      }
   }

   if(sellOrderCount < MaxBuySell && EMA3 < EMA12) { // Open Sells if EMA3 < EMA12
      if(buyOrderCount == 0 && sellOrderCount == 0) {
         if(gradientEMA3 < -5) {
            int ticket = OpenOrder(OP_SELL, Bid, Lotsize);
            if(ticket > 0) {
               lastSellTicket = ticket;
               sellOrderCount = CountOrdersByType(OP_SELL);
               Print("[Open Sell] First order #", sellOrderCount, ". Trigger: EMA3 Gradient=", gradientEMA3);
               ManageHiddenTrailingStop();
               if(sellTrailActivated) {
                  for(int i = 0; i < OrdersTotal(); i++) {
                     if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), hiddenSellTrailStop, OrderTakeProfit(), 0, clrNONE)) {
                           Print("[Error] Failed to modify Sell order #", OrderTicket(), " to hiddenSellTrailStop=", hiddenSellTrailStop, ". Error code: ", GetLastError());
                        }
                     }
                  }
               }
            }
         }
      } else if(lastSellTicket > 0 && Bid <= OrderPrice(lastSellTicket) - 15 * Point) {
         if(gradientEMA3 <= -0.04 && gradientEMA12 <= -0.04) {
            int ticket = OpenOrder(OP_SELL, Bid, Lotsize);
            if(ticket > 0) {
               lastSellTicket = ticket;
               sellOrderCount = CountOrdersByType(OP_SELL);
               Print("[Open Sell] Order #", sellOrderCount, ". Trigger: Price -15pips, Gradients: EMA3=", gradientEMA3, ", EMA12=", gradientEMA12);
               ManageHiddenTrailingStop();
               if(sellTrailActivated) {
                  for(int i = 0; i < OrdersTotal(); i++) {
                     if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
                        if(!OrderModify(OrderTicket(), OrderOpenPrice(), hiddenSellTrailStop, OrderTakeProfit(), 0, clrNONE)) {
                           Print("[Error] Failed to modify Sell order #", OrderTicket(), " to hiddenSellTrailStop=", hiddenSellTrailStop, ". Error code: ", GetLastError());
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

void ManageHiddenTrailingStop() {
   int buyCount = CountOrdersByType(OP_BUY);
   int sellCount = CountOrdersByType(OP_SELL);

   if(buyCount > 0) {
      double highestPrice = GetHighestOrderOpenPrice(OP_BUY);
      if(!buyTrailActivated && Bid - highestPrice >= buyTrailDistance) {
         hiddenBuyTrailStop = Bid - buyTrailDistance;
         buyTrailActivated = true;
         Print("[Hidden Trail] Buy activated. Bid=", Bid, ", HighestPrice=", highestPrice, ", HiddenBuyTrailStop=", hiddenBuyTrailStop);
      } else if(buyTrailActivated) {
         double prevHiddenBuyTrailStop = hiddenBuyTrailStop;
         hiddenBuyTrailStop = MathMax(hiddenBuyTrailStop, Bid - buyTrailDistance);
         if(prevHiddenBuyTrailStop != hiddenBuyTrailStop) {
            Print("[Hidden Trail] Buy updated. Bid=", Bid, ", HighestPrice=", highestPrice, ", HiddenBuyTrailStop=", hiddenBuyTrailStop);
         }
         if(Bid <= hiddenBuyTrailStop) {
            CloseAllOrders(OP_BUY, "[Hidden trail stop] Buy closed. Trigger: Bid <= " + DoubleToString(hiddenBuyTrailStop, Digits));
            buyTrailActivated = false;
         }
      }
   } else buyTrailActivated = false;

   if(sellCount > 0) {
      double lowestPrice = GetLowestOrderOpenPrice(OP_SELL);
      if(!sellTrailActivated && lowestPrice - Ask >= sellTrailDistance) {
         hiddenSellTrailStop = Ask + sellTrailDistance;
         sellTrailActivated = true;
         Print("[Hidden Trail] Sell activated. Ask=", Ask, ", LowestPrice=", lowestPrice, ", HiddenSellTrailStop=", hiddenSellTrailStop);
      } else if(sellTrailActivated) {
         double prevHiddenSellTrailStop = hiddenSellTrailStop;
         hiddenSellTrailStop = MathMin(hiddenSellTrailStop, Ask + sellTrailDistance);
         if(prevHiddenSellTrailStop != hiddenSellTrailStop) {
            Print("[Hidden Trail] Sell updated. Ask=", Ask, ", LowestPrice=", lowestPrice, ", HiddenSellTrailStop=", hiddenSellTrailStop);
         }
         if(Ask >= hiddenSellTrailStop) {
            CloseAllOrders(OP_SELL, "[Hidden trail stop] Sell closed. Trigger: Ask >= " + DoubleToString(hiddenSellTrailStop, Digits));
            sellTrailActivated = false;
         }
      }
   } else sellTrailActivated = false;
}

void CloseAllOrders(int type, string message) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
         int retries = 0;
         double closePrice = (type == OP_BUY) ? Bid : Ask;
         while(retries < 3) {
            if(OrderClose(OrderTicket(), OrderLots(), closePrice, 30, (type == OP_BUY) ? clrRed : clrGreen)) {
               Print(message, " Ticket #", OrderTicket(), " Closed at ", DoubleToString(closePrice, Digits));
               break;
            } else {
               Print("[Error] Failed to close order #", OrderTicket(), ". Error code: ", GetLastError());
            }
            retries++;
            Sleep(1000);
         }
      }
   }
}

double GetLowestOrderOpenPrice(int type) {
   double lowest = DBL_MAX;
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type)
         lowest = MathMin(lowest, OrderOpenPrice());
   }
   return lowest;
}

double GetHighestOrderOpenPrice(int type) {
   double highest = 0;
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type)
         highest = MathMax(highest, OrderOpenPrice());
   }
   return highest;
}

int OpenOrder(int type, double price, double lots) {
   double priceNormalized = NormalizeDouble(price, Digits);
   double lotsNormalized = CheckVolume(Symbol(), lots);
   int ticket = -1;
   int retries = 0;
   while(retries < 3) {
      ticket = OrderSend(Symbol(), type, lotsNormalized, priceNormalized, 30, 0, 0, Comment, Magic, 0, (type == OP_BUY) ? clrGreen : clrRed);
      if(ticket >= 0) break;
      retries++;
      Sleep(1000);
   }
   return ticket;
}

int LastOpenOrderTicket(int type) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == type)
         return OrderTicket();
   }
   return 0;
}

double OrderPrice(int ticket) {
   if(ticket <= 0 || !OrderSelect(ticket, SELECT_BY_TICKET)) return 0;
   return OrderOpenPrice();
}

int CountOrdersByType(int type) {
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type)
         count++;
   }
   return count;
}

double CheckVolume(string symbol, double volume) {
   double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double stepVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   return NormalizeDouble(MathMax(minVolume, MathMin(maxVolume, MathRound(volume / stepVolume) * stepVolume)), (stepVolume >= 0.1) ? 1 : 2);
}