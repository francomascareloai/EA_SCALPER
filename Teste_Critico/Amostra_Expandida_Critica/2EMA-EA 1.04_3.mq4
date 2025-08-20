#property copyright "Copyright Matt Todorovski 2025"
#property version   "1.05"
#property strict

extern int Magic = 12345;
extern string Comment = "HF_MA_EA";
extern double Lotsize = 0.01;
extern int MaxBuySell = 35;
extern double TrailDistance = 210.0;
extern double CompressionFactor = 0.9;
extern double MinimumProfit = 10.0;
extern double BreakevenProfitPips = 70.0;
extern double BreakevenLevelPips = 10.0;

int lastBuyTicket, lastSellTicket;
datetime lastBuyAttempt, lastSellAttempt;
double hiddenBuyTrailStop, hiddenSellTrailStop;
bool buyTrailActivated, sellTrailActivated;
double buyTrailDistance, sellTrailDistance;
bool prevEmaCrossState;
int firstOrderDirection = -1;

double GetATR(int period=14) {return iATR(Symbol(), PERIOD_CURRENT, period, 0);}
int OnInit() {
   lastBuyTicket = LastOpenOrderTicket(OP_BUY);
   lastSellTicket = LastOpenOrderTicket(OP_SELL);
   buyTrailDistance = TrailDistance * Point;
   sellTrailDistance = TrailDistance * Point;
   return INIT_SUCCEEDED;
}

void OnTick() {
   double EMA3 = iMA(_Symbol, PERIOD_M1, 3, 0, MODE_EMA, PRICE_OPEN, 0);
   double EMA12 = iMA(_Symbol, PERIOD_M1, 12, 0, MODE_EMA, PRICE_CLOSE, 0);
   int ordersBuyCount = CountOrdersByType(OP_BUY);
   int ordersSellCount = CountOrdersByType(OP_SELL);
   double gradientEMA3 = (EMA3 - iMA(_Symbol, PERIOD_M1, 3, 0, MODE_EMA, PRICE_OPEN, 1)) / Point;
   double gradientEMA12 = (EMA12 - iMA(_Symbol, PERIOD_M1, 12, 0, MODE_EMA, PRICE_CLOSE, 1)) / Point;

   bool emaCrossDown = EMA3 < (EMA12 - 150 * Point) && !prevEmaCrossState;
   bool emaCrossUp = EMA3 > (EMA12 + 150 * Point) && prevEmaCrossState;
   prevEmaCrossState = EMA3 > EMA12;

   ManageHiddenTrailingStop();
   if(emaCrossDown && ordersBuyCount > 0) CloseAllOrders(OP_BUY, "[EMA cross close] Buy orders closed. Trigger: EMA3 < EMA12 - 150pips");
   if(emaCrossUp && ordersSellCount > 0) CloseAllOrders(OP_SELL, "[EMA cross close] Sell orders closed. Trigger: EMA3 > EMA12 + 150pips");
   CheckBreakeven();

   if(ordersBuyCount < MaxBuySell) {
      if(ordersBuyCount == 0 && ordersSellCount == 0) {
         if(gradientEMA3 > 1) {
            int ticket = OpenOrder(OP_BUY, Ask, Lotsize, EMA12);
            if(ticket > 0) {
               lastBuyTicket = ticket;
               firstOrderDirection = 1;
               Print("[Open Buy] First order. Trigger: EMA3 Gradient=", gradientEMA3);
            }
         }
      } else if(lastBuyTicket > 0 && Ask >= OrderPrice(lastBuyTicket) + 15 * Point && firstOrderDirection == 1) {
         if(gradientEMA3 >= 0.04 && gradientEMA12 >= 0.04) {
            int ticket = OpenOrder(OP_BUY, Ask, Lotsize, EMA12);
            if(ticket > 0) {
               lastBuyTicket = ticket;
               Print("[Open Buy] Subsequent order. Trigger: Price +15pips, Gradients: EMA3=", gradientEMA3, ", EMA12=", gradientEMA12);
            }
         }
      }
   }

   if(ordersSellCount < MaxBuySell) {
      if(ordersBuyCount == 0 && ordersSellCount == 0) {
         if(gradientEMA3 < 1) {
            int ticket = OpenOrder(OP_SELL, Bid, Lotsize, EMA12);
            if(ticket > 0) {
               lastSellTicket = ticket;
               firstOrderDirection = 0;
               Print("[Open Sell] First order. Trigger: EMA3 Gradient=", gradientEMA3);
            }
         }
      } else if(lastSellTicket > 0 && Bid <= OrderPrice(lastSellTicket) - 15 * Point && firstOrderDirection == 0) {
         if(gradientEMA3 <= -0.04 && gradientEMA12 <= -0.04) {
            int ticket = OpenOrder(OP_SELL, Bid, Lotsize, EMA12);
            if(ticket > 0) {
               lastSellTicket = ticket;
               Print("[Open Sell] Subsequent order. Trigger: Price -15pips, Gradients: EMA3=", gradientEMA3, ", EMA12=", gradientEMA12);
            }
         }
      }
   }

   if(OrdersTotal() > 0) {
      for(int i = 0; i < OrdersTotal(); i++) {
         if(OrderSelect(i, SELECT_BY_POS)) {
            double prevOpen = iOpen(NULL, 0, 1);
            double prevClose = iClose(NULL, 0, 1);
            if(OrderType() == OP_BUY && Bid <= MathMax(prevOpen, prevClose) && OrderProfit() >= MinimumProfit) {
               if(OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed))
                  Print("[Min profit close] Buy closed. Trigger: Bid <= ", MathMax(prevOpen, prevClose), ", Profit: ", OrderProfit());
            }
            if(OrderType() == OP_SELL && Ask >= MathMin(prevOpen, prevClose) && OrderProfit() >= MinimumProfit) {
               if(OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed))
                  Print("[Min profit close] Sell closed. Trigger: Ask >= ", MathMin(prevOpen, prevClose), ", Profit: ", OrderProfit());
            }
         }
      }
   }
}

void ManageHiddenTrailingStop() {
   int buyCount = CountOrdersByType(OP_BUY);
   int sellCount = CountOrdersByType(OP_SELL);

   if(buyCount > 0) {
      double lowestPrice = GetLowestOrderOpenPrice(OP_BUY);
      if(!buyTrailActivated && Bid - lowestPrice >= buyTrailDistance) {
         hiddenBuyTrailStop = Bid - buyTrailDistance;
         buyTrailActivated = true;
      } else if(buyTrailActivated) {
         hiddenBuyTrailStop = MathMax(hiddenBuyTrailStop, Bid - buyTrailDistance);
         if(Bid <= hiddenBuyTrailStop) {
            CloseAllOrders(OP_BUY, "[Hidden trail stop] Buy closed. Trigger: Bid <= " + DoubleToString(hiddenBuyTrailStop, _Digits));
            buyTrailActivated = false;
            firstOrderDirection = -1;
         }
      }
   } else buyTrailActivated = false;

   if(sellCount > 0) {
      double highestPrice = GetHighestOrderOpenPrice(OP_SELL);
      if(!sellTrailActivated && highestPrice - Ask >= sellTrailDistance) {
         hiddenSellTrailStop = Ask + sellTrailDistance;
         sellTrailActivated = true;
      } else if(sellTrailActivated) {
         hiddenSellTrailStop = MathMin(hiddenSellTrailStop, Ask + sellTrailDistance);
         if(Ask >= hiddenSellTrailStop) {
            CloseAllOrders(OP_SELL, "[Hidden trail stop] Sell closed. Trigger: Ask >= " + DoubleToString(hiddenSellTrailStop, _Digits));
            sellTrailActivated = false;
            firstOrderDirection = -1;
         }
      }
   } else sellTrailActivated = false;

   if(buyCount == 0 && sellCount == 0) firstOrderDirection = -1;
}

void CheckBreakeven() {
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         double profitPips = (OrderType() == OP_BUY) ? (Bid - OrderOpenPrice()) / Point : (OrderOpenPrice() - Ask) / Point;
         if(profitPips >= BreakevenProfitPips) {
            double breakeven = (OrderType() == OP_BUY) ? OrderOpenPrice() + BreakevenLevelPips * Point : OrderOpenPrice() - BreakevenLevelPips * Point;
            if((OrderType() == OP_BUY && OrderStopLoss() < breakeven) || (OrderType() == OP_SELL && OrderStopLoss() > breakeven)) {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), breakeven, OrderTakeProfit(), 0, clrNONE))
                  Print("[Breakeven] Modified to ", breakeven);
            }
         }
      }
   }
}

void CloseAllOrders(int type, string message) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
         int retries = 0;
         while(retries < 3) {
            if(OrderClose(OrderTicket(), OrderLots(), (type == OP_BUY) ? Bid : Ask, 30, (type == OP_BUY) ? clrRed : clrGreen)) {
               Print(message);
               break;
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

int OpenOrder(int type, double price, double lots, double slowEMA) {
   double priceNorm = NormalizeDouble(price, _Digits);
   double lotsNorm = CheckVolume(Symbol(), lots);
   double sl = (type == OP_BUY) ? slowEMA : slowEMA;
   int ticket = -1;
   int retries = 0;
   while(retries < 3) {
      ticket = OrderSend(Symbol(), type, lotsNorm, priceNorm, 30, sl, 0, Comment, Magic, 0, (type == OP_BUY) ? clrGreen : clrRed);
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
   double minVol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxVol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double stepVol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   return NormalizeDouble(MathMax(minVol, MathMin(maxVol, MathRound(volume / stepVol) * stepVol)), (stepVol >= 0.1) ? 1 : 2);
}