//+------------------------------------------------------------------+
//|                              RobotPowerM5_meta4V12 (RobotBB).mq4 |
//|                                        Copyright © 2005, Company |
//|                                             http://www.funds.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005"
#property link      "http://www.funds.com"

// A reliable expert, use it on 5 min charts (GBP is best) with 
// 150/pips profit limit. 
// No worries, check the results. 
extern int BullBearPeriod=5;
extern double lots         = 1.0;
extern double trailingStop = 15;   // trail stop in points
extern double takeProfit   = 150;  // recomended  no more than 150
extern double stopLoss     = 45;   // do not use s/l
extern double slippage     = 3;
// EA identifier. Allows for several co-existing EA with different values.
extern string nameEA       = "Soultrading";
//----
double bull, bear;
double realTP, realSL, b, s, sl, tp;
bool isBuying = false, isSelling = false, isClosing = false;
int cnt, ticket;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() 
  {
   return(0);
//----
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() 
  {
   return(0);
//----
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() 
  {
// Check for invalid bars and takeprofit
   if(Bars < 200) 
     {
       Print("Not enough bars for this strategy - ", nameEA);
       return(-1);
     }
// Calculate indicators' value 
   calculateIndicators();   
// Control open trades
   int totalOrders = OrdersTotal();
   int numPos = 0;
// scan all orders and positions...
   for(cnt = 0; cnt < totalOrders; cnt++) 
     {
       // the next line will check for ONLY market trades, not entry orders
       OrderSelect(cnt, SELECT_BY_POS);
       // only look for this symbol, and only orders from this EA      
       if(OrderSymbol() == Symbol() && OrderType() <= OP_SELL ) 
         {
           numPos++;
           // Check for close signal for bought trade
           if(OrderType() == OP_BUY) 
             {
               // Check trailing stop
               if(trailingStop > 0) 
                 {
                   if(Bid - OrderOpenPrice() > trailingStop*Point) 
                     {
                       if(OrderStopLoss() < (Bid - trailingStop*Point))
                           OrderModify(OrderTicket(), OrderOpenPrice(), 
                                       Bid - trailingStop*Point, OrderTakeProfit(), 0, Blue);
                     }
                 }
             } 
           else 
             // Check sold trade for close signal
             {
               // Control trailing stop
               if(trailingStop > 0) 
                 {
                   if(OrderOpenPrice() - Ask > trailingStop*Point)
                     {
                       if(OrderStopLoss() == 0 || OrderStopLoss() > Ask + trailingStop*Point)
                           OrderModify(OrderTicket(), OrderOpenPrice(), 
                                       Ask + trailingStop*Point, OrderTakeProfit(), 0, Red);
                     }           
                 } 
             }
         }
     }
   // If there is no open trade for this pair and this EA
   if(numPos < 1) 
     {   
       if(AccountFreeMargin() < 1000*lots) 
         {
           Print("Not enough money to trade ", lots, " lots. Strategy:", nameEA);
           return(0);
         }
       // Check for BUY entry signal
       if(isBuying && !isSelling && !isClosing) 
         {
           sl = Ask - stopLoss * Point;
           tp = Bid + takeProfit * Point;
           OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, sl, tp, nameEA + CurTime(), 
                     0, 0, Green);
           Comment(sl);
           if(ticket < 0)
               Print("OrderSend (", nameEA, ") failed with error #", GetLastError());
           prtAlert("Day Trading: Buying"); 
         }
       // Check for SELL entry signal
       if(isSelling && !isBuying && !isClosing) 
         {
           sl = Bid + stopLoss * Point;
           tp = Ask - takeProfit * Point;
           OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, sl, tp, nameEA + CurTime(), 
                     0, 0, Red);
           if(ticket < 0)
               Print("OrderSend (", nameEA, ") failed with error #", GetLastError());
           prtAlert("Day Trading: Selling"); 
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|  Calculate indicators' value                                     |
//+------------------------------------------------------------------+
void calculateIndicators() 
  {       
   bull = iBullsPower(NULL, 0, BullBearPeriod, PRICE_CLOSE, 1);
   bear = iBearsPower(NULL, 0, BullBearPeriod, PRICE_CLOSE, 1);
   Comment("bull+bear= ", bull + bear);
   //sarCurrent          = iSAR(NULL,0,0.02,0.2,0);           // Parabolic Sar Current
   //sarPrevious         = iSAR(NULL,0,0.02,0.2,1);           // Parabolic Sar Previuos
   //momCurrent          = iMomentum(NULL,0,14,PRICE_OPEN,0); // Momentum Current
   // momPrevious         = iMomentum(NULL,0,14,PRICE_OPEN,1); // Momentum Previous
   b = 1 * Point + iATR(NULL, 0, 5, 1)*1.5;
   s = 1 * Point + iATR(NULL, 0, 5, 1)*1.5;
   // Check for BUY, SELL, and CLOSE signal
   // isBuying  = (sarCurrent <= Ask && sarPrevious>sarCurrent && momCurrent < 100 && 
                   // macdHistCurrent < macdSignalCurrent && stochHistCurrent < 35);
   // isSelling = (sarCurrent >= Bid && sarPrevious < sarCurrent && momCurrent > 100 && 
                   // macdHistCurrent > macdSignalCurrent && stochHistCurrent > 60);
   isBuying  = (bull+bear > 0);
   isSelling = (bull+bear < 0);
   isClosing = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prtAlert(string str = "") 
  {
   Print(str);
   Alert(str);
  }
//+------------------------------------------------------------------+