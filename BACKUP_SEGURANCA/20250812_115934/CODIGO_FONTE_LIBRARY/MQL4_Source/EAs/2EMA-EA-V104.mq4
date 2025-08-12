//+------------------------------------------------------------------+
//| 2EMA Crossover Trading Expert Advisor                            |
//| Copyright "FreeWare" - Improved Version                          |
//+------------------------------------------------------------------+
#property copyright "FreeWare"
#property link      ""
#property version   "2.00"
#property strict

//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+
sinput string EAHeader; // *** EA Settings ***
input int MaxTrades = 5; // Max Trades (0 for unlimited)
input double LotSize = 0.01; // Fixed Lot Size per trade
input int distanceMultiplier = 5; // Distance multiplier (2-10)
input bool TradeOnlyBetterPrices = false; // Trade only better prices
input double KeepFreeMargin = 20.0; // Min free margin to keep [% from the acc balance]
input int Magic = 12345; // Magic number
input string TradeCommentBuy = "2EMA-Buy"; // Trade comment Buy
input string TradeCommentSell = "2EMA-Sell"; // Trade comment Sell

sinput string RiskHeader; // *** Risk Management ***
input bool UseStopLoss = true; // Use Stop Loss
input int StopLossPips = 50; // Stop Loss in pips
input bool UseTakeProfit = true; // Use Take Profit
input int TakeProfitPips = 100; // Take Profit in pips
input bool UseTrailingStop = false; // Use Trailing Stop
input int TrailingStopPips = 30; // Trailing Stop in pips
input int TrailingStopStart = 50; // Start Trailing after pips in profit

sinput string EMAHeader; // *** EMA Settings ***
input int EMA_FAST_PERIOD = 5; // EMA Fast Period
input int EMA_SLOW_PERIOD = 10; // EMA Slow Period
input ENUM_TIMEFRAMES EMA_TIMEFRAME = PERIOD_H1; // EMA TimeFrame
input ENUM_APPLIED_PRICE EMA_PRICE_TYPE = PRICE_WEIGHTED; // EMA Price Type

sinput string CloseHeader; // *** Close Settings ***
input bool CloseOnCrossover = true; // Close positions on EMA crossover
input bool UseMinLossThreshold = true; // Use minimum loss threshold for closing
input double LossThresholdMultiplier = 10.0; // Loss threshold multiplier

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
datetime newtime;
double spreadDistance;
double pipValue;
int lastBuyTicket;
int lastSellTicket;
int digits;
double minLossThreshold;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   newtime = 0;
   digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   pipValue = (digits == 3 || digits == 5) ? Point * 10 : Point;
   lastBuyTicket = LastOpenOrderTicket(OP_BUY);
   lastSellTicket = LastOpenOrderTicket(OP_SELL);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Shutdown function                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // Nothing to do here
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if(newtime == 0) {
      newtime = Time[0];
   } else {
      if(newtime != Time[0]) {
         newtime = Time[0];
         // At every new bar open (current timeframe):
         spreadDistance = MarketInfo(Symbol(), MODE_SPREAD) * Point;
         minLossThreshold = LossThresholdMultiplier * spreadDistance;
         
         // Update last ticket information
         lastBuyTicket = LastOpenOrderTicket(OP_BUY);
         lastSellTicket = LastOpenOrderTicket(OP_SELL);
         
         // Count orders
         int orders_count = CountOrders();
         int buy_orders_count = CountOrdersByType(OP_BUY);
         int sell_orders_count = CountOrdersByType(OP_SELL);
         
         // Get last order prices
         double lastBuyPrice = OrderPrice(lastBuyTicket);
         double lastSellPrice = OrderPrice(lastSellTicket);
         
         // Check if there's enough distance for new orders
         bool enoughDistanceForNewBuy = false;
         bool enoughDistanceForNewSell = false;
         
         if(TradeOnlyBetterPrices) {
            // Buy/sell only if the current price is better than the price of the last trade
            enoughDistanceForNewBuy = (lastBuyPrice > 0) && (Ask < (lastBuyPrice - spreadDistance * distanceMultiplier));
            enoughDistanceForNewSell = (lastSellPrice > 0) && (Bid > (lastSellPrice + spreadDistance * distanceMultiplier)); // Fixed bug here
         } else {
            // Buy/sell if the current price is in any direction at required distance from the price of the last trade
            enoughDistanceForNewBuy = (lastBuyPrice <= 0) || (MathAbs(lastBuyPrice - Ask) >= spreadDistance * distanceMultiplier);
            enoughDistanceForNewSell = (lastSellPrice <= 0) || (MathAbs(lastSellPrice - Bid) >= spreadDistance * distanceMultiplier);
         }
         
         // Get EMA values
         double emaFast = iMA(Symbol(), EMA_TIMEFRAME, EMA_FAST_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 1);
         double emaSlow = iMA(Symbol(), EMA_TIMEFRAME, EMA_SLOW_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 1);
         double emaFastPrev = iMA(Symbol(), EMA_TIMEFRAME, EMA_FAST_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 2);
         double emaSlowPrev = iMA(Symbol(), EMA_TIMEFRAME, EMA_SLOW_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 2);
         
         // Check for EMA crossover events
         bool emaCrossDn = emaFast < emaSlow && emaFastPrev >= emaSlowPrev;
         bool emaCrossUp = emaFast > emaSlow && emaFastPrev <= emaSlowPrev;
         
         // Apply trailing stop to existing orders
         if(UseTrailingStop) {
            ManageTrailingStop();
         }
         
         // Check for close conditions first
         if(CloseOnCrossover) {
            if(emaCrossDn && buy_orders_count > 0) {
               if(UseMinLossThreshold) {
                  CloseOrdersByTypeWithThreshold(OP_BUY, minLossThreshold);
               } else {
                  CloseOrdersByType(OP_BUY);
               }
               lastBuyTicket = LastOpenOrderTicket(OP_BUY);
            }
            
            if(emaCrossUp && sell_orders_count > 0) {
               if(UseMinLossThreshold) {
                  CloseOrdersByTypeWithThreshold(OP_SELL, minLossThreshold);
               } else {
                  CloseOrdersByType(OP_SELL);
               }
               lastSellTicket = LastOpenOrderTicket(OP_SELL);
            }
         }
         
         // Check for open new order conditions
         if(MaxTrades == 0 || (MaxTrades != 0 && orders_count < MaxTrades)) {
            // BUY condition
            if((emaFast > emaSlow) && enoughDistanceForNewBuy) {
               if(AccountFreeMarginCheck(Symbol(), OP_BUY, LotSize) < AccountBalance() * KeepFreeMargin * 0.01) {
                  Print("ERROR: Insufficient funds to open a BUY trade with this lot size!");
               } else {
                  double sl = UseStopLoss ? NormalizeDouble(Ask - StopLossPips * pipValue, digits) : 0;
                  double tp = UseTakeProfit ? NormalizeDouble(Ask + TakeProfitPips * pipValue, digits) : 0;
                  int t = OpenOrder(OP_BUY, Ask, LotSize, sl, tp, TradeCommentBuy);
                  if(t > 0) lastBuyTicket = t;
               }
            }
            // SELL condition
            else if((emaFast < emaSlow) && enoughDistanceForNewSell) {
               if(AccountFreeMarginCheck(Symbol(), OP_SELL, LotSize) < AccountBalance() * KeepFreeMargin * 0.01) {
                  Print("ERROR: Insufficient funds to open a SELL trade with this lot size!");
               } else {
                  double sl = UseStopLoss ? NormalizeDouble(Bid + StopLossPips * pipValue, digits) : 0;
                  double tp = UseTakeProfit ? NormalizeDouble(Bid - TakeProfitPips * pipValue, digits) : 0;
                  int t = OpenOrder(OP_SELL, Bid, LotSize, sl, tp, TradeCommentSell);
                  if(t > 0) lastSellTicket = t;
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Returns the price of an order by ticket                          |
//+------------------------------------------------------------------+
double OrderPrice(int ticket) {
   double price = 0;
   if(ticket <= 0) return price;
   if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
      price = OrderOpenPrice();
   }
   return price;
}

//+------------------------------------------------------------------+
//| Count all orders with our Magic number and Symbol                |
//+------------------------------------------------------------------+
int CountOrders() {
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Count orders by type with our Magic number and Symbol            |
//+------------------------------------------------------------------+
int CountOrdersByType(int type) {
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Check and adjust volume according to broker limits               |
//+------------------------------------------------------------------+
double CheckVolume(string pSymbol, double pVolume) {
   double minVolume = MarketInfo(pSymbol, MODE_MINLOT);
   double maxVolume = MarketInfo(pSymbol, MODE_MAXLOT);
   double stepVolume = MarketInfo(pSymbol, MODE_LOTSTEP);
   double tradeSize;
   
   if(pVolume < minVolume) {
      tradeSize = minVolume;
   } else if(pVolume > maxVolume) {
      tradeSize = maxVolume;
   } else {
      tradeSize = MathFloor(pVolume / stepVolume) * stepVolume;
   }
   
   if(stepVolume >= 0.1) {
      tradeSize = NormalizeDouble(tradeSize, 1);
   } else {
      tradeSize = NormalizeDouble(tradeSize, 2);
   }
   
   return tradeSize;
}

//+------------------------------------------------------------------+
//| Open a new order with SL and TP                                  |
//+------------------------------------------------------------------+
int OpenOrder(int type, double price, double lots, double stopLoss, double takeProfit, string comment) {
   double priceN = NormalizeDouble(price, digits);
   double lotsN = CheckVolume(Symbol(), lots);
   int ticket = OrderSend(Symbol(), type, lotsN, priceN, 3, stopLoss, takeProfit, comment, Magic, 0, (type == OP_BUY) ? clrGreen : clrRed);
   
   if(ticket < 0) {
      int error = GetLastError();
      Print("Order open error: ", error, " - ", ErrorDescription(error));
   } else {
      Print("Order opened successfully: Ticket #", ticket, " Type: ", type == OP_BUY ? "BUY" : "SELL", " at ", priceN, " with lots ", lotsN);
   }
   
   return ticket;
}

//+------------------------------------------------------------------+
//| Close all orders of specified type                               |
//+------------------------------------------------------------------+
void CloseOrdersByType(int type) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            bool result = false;
            if(type == OP_BUY) {
               result = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrBlue);
            } else if(type == OP_SELL) {
               result = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
            }
            
            if(!result) {
               int error = GetLastError();
               Print("Error closing order #", OrderTicket(), ": ", error, " - ", ErrorDescription(error));
            } else {
               Print("Order #", OrderTicket(), " closed successfully");
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Close orders of specified type only if loss exceeds threshold    |
//+------------------------------------------------------------------+
void CloseOrdersByTypeWithThreshold(int type, double threshold) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            double currentProfit = OrderProfit();
            if(currentProfit < 0 && MathAbs(currentProfit) > threshold) {
               bool result = false;
               if(type == OP_BUY) {
                  result = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrBlue);
               } else if(type == OP_SELL) {
                  result = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
               }
               
               if(!result) {
                  int error = GetLastError();
                  Print("Error closing order #", OrderTicket(), ": ", error, " - ", ErrorDescription(error));
               } else {
                  Print("Order #", OrderTicket(), " closed successfully (Loss threshold exceeded)");
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Return the ticket of the last open order of specified type       |
//+------------------------------------------------------------------+
int LastOpenOrderTicket(int type = -1) {
   int ticket = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) {
            continue;
         }
         if((OrderType() == OP_BUY && (type == OP_BUY || type == -1)) || 
            (OrderType() == OP_SELL && (type == OP_SELL || type == -1))) {
            ticket = OrderTicket();
            break;
         }
      }
   }
   return ticket;
}

//+------------------------------------------------------------------+
//| Manage trailing stop for all open orders                         |
//+------------------------------------------------------------------+
void ManageTrailingStop() {
   for(int i = 0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
            // For BUY orders
            if(OrderType() == OP_BUY) {
               double profit = Bid - OrderOpenPrice();
               if(profit >= TrailingStopStart * pipValue) {
                  double newSL = NormalizeDouble(Bid - TrailingStopPips * pipValue, digits);
                  if(OrderStopLoss() < newSL || OrderStopLoss() == 0) {
                     bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen);
                     if(!result) {
                        int error = GetLastError();
                        if(error != 130) { // Exclude "Invalid stops" error, which occurs when SL is too close
                           Print("Error modifying BUY order trailing stop: ", error, " - ", ErrorDescription(error));
                        }
                     }
                  }
               }
            }
            // For SELL orders
            else if(OrderType() == OP_SELL) {
               double profit = OrderOpenPrice() - Ask;
               if(profit >= TrailingStopStart * pipValue) {
                  double newSL = NormalizeDouble(Ask + TrailingStopPips * pipValue, digits);
                  if(OrderStopLoss() > newSL || OrderStopLoss() == 0) {
                     bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrRed);
                     if(!result) {
                        int error = GetLastError();
                        if(error != 130) { // Exclude "Invalid stops" error
                           Print("Error modifying SELL order trailing stop: ", error, " - ", ErrorDescription(error));
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Return error description for given error code                    |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code) {
   string error_string;
   switch(error_code) {
      case 0:   error_string = "No error";                                                   break;
      case 1:   error_string = "No error, but the result is unknown";                        break;
      case 2:   error_string = "Common error";                                               break;
      case 3:   error_string = "Invalid trade parameters";                                   break;
      case 4:   error_string = "Trade server is busy";                                       break;
      case 5:   error_string = "Old version of the client terminal";                         break;
      case 6:   error_string = "No connection with trade server";                            break;
      case 7:   error_string = "Not enough rights";                                          break;
      case 8:   error_string = "Too frequent requests";                                      break;
      case 9:   error_string = "Malfunctional trade operation";                              break;
      case 64:  error_string = "Account disabled";                                           break;
      case 65:  error_string = "Invalid account";                                            break;
      case 128: error_string = "Trade timeout";                                              break;
      case 129: error_string = "Invalid price";                                              break;
      case 130: error_string = "Invalid stops";                                              break;
      case 131: error_string = "Invalid trade volume";                                       break;
      case 132: error_string = "Market is closed";                                           break;
      case 133: error_string = "Trade is disabled";                                          break;
      case 134: error_string = "Not enough money";                                           break;
      case 135: error_string = "Price changed";                                              break;
      case 136: error_string = "Off quotes";                                                 break;
      case 137: error_string = "Broker is busy";                                             break;
      case 138: error_string = "Requote";                                                    break;
      case 139: error_string = "Order is locked";                                            break;
      case 140: error_string = "Long positions only allowed";                                break;
      case 141: error_string = "Too many requests";                                          break;
      case 145: error_string = "Modification denied because order is too close to market";   break;
      case 146: error_string = "Trade context is busy";                                      break;
      case 147: error_string = "Expirations are denied by broker";                           break;
      case 148: error_string = "Amount of open and pending orders has reached the limit";    break;
      case 149: error_string = "Hedging is prohibited";                                      break;
      case 150: error_string = "Prohibited by FIFO rules";                                   break;
      default:  error_string = "Unknown error";
   }
   return error_string;
}