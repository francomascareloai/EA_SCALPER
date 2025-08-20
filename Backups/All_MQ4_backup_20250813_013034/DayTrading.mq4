//+------------------------------------------------------------------+
//|                                                   DayTrading.mq4 |
//|                               Copyright © 2005, NazFunds Company |
//|                                          http://www.nazfunds.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, NazFunds Company"
#property link      "http://www.nazfunds.com"
// A reliable expert, use it on 5 min charts with 20/pips profit limit. 
// Do not place any stop loss. No worries, check the results 
extern double lots         = 1.0;           
extern double trailingStop = 15;            // trail stop in points
extern double takeProfit   = 20;            // recomended  no more than 20
extern double stopLoss     = 0;             // do not use s/l
extern double slippage     = 3;
// EA identifier. Allows for several co-existing EA with different values
extern string nameEA       = "DayTrading";  
//----
double macdHistCurrent, macdHistPrevious, macdSignalCurrent, macdSignalPrevious;
double stochHistCurrent, stochHistPrevious, stochSignalCurrent, stochSignalPrevious;
double sarCurrent, sarPrevious, momCurrent, momPrevious;
double realTP, realSL;
bool isBuying = false, isSelling = false, isClosing = false;
int cnt, ticket;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() 
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() 
  {
   return(0);
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
       if(OrderSymbol() == Symbol() && OrderType() <= OP_SELL && OrderComment() == nameEA) 
         {   
           numPos++;
           // Check for close signal for bought trade
           if(OrderType() == OP_BUY)  
             {           
               if(isSelling || isClosing) 
                 {
                   // Close bought trade
                   OrderClose(OrderTicket(),OrderLots(),Bid,slippage,Violet);   
                   prtAlert("Day Trading: Closing BUY order");
                 }         
               // Check trailing stop
               if(trailingStop > 0) 
                 {             
                   if(Bid-OrderOpenPrice() > trailingStop*Point) 
                     {
                       if(OrderStopLoss() < (Bid - trailingStop*Point))
                           OrderModify(OrderTicket(), OrderOpenPrice(), 
                                       Bid-trailingStop*Point,OrderTakeProfit(),0,Blue);
                     }
                 }
             } 
           else 
             // Check sold trade for close signal
             {                              
               if(isBuying || isClosing) 
                 {
                   OrderClose(OrderTicket(), OrderLots(), Ask, slippage, Violet);
                   prtAlert("Day Trading: Closing SELL order");
                 } 
               if(trailingStop > 0) 
                 // Control trailing stop
                 {             
                   if(OrderOpenPrice() - Ask > trailingStop*Point) 
                     {
                       if(OrderStopLoss() == 0 || OrderStopLoss() > Ask + trailingStop*Point)
                           OrderModify(OrderTicket(), OrderOpenPrice(), 
                                       Ask + trailingStop*Point, OrderTakeProfit(),
                                       0, Red);
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
           if(stopLoss > 0)
               realSL = Ask - stopLoss * Point;
           if(takeProfit > 0)
               realTP = Ask + takeProfit * Point;
           // Buy
           ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, slippage, realSL, realTP, 
                    nameEA, 16384,0,Red);  
           if(ticket < 0)
               Print("OrderSend (",nameEA,") failed with error #", GetLastError());
           prtAlert("Day Trading: Buying"); 
         }
       // Check for SELL entry signal
       if(isSelling && !isBuying && !isClosing) 
         {  
           if(stopLoss > 0)
               realSL = Bid + stopLoss * Point;
           if(takeProfit > 0)
               realTP = Bid - takeProfit * Point;
           // Sell
           ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, slippage, realSL, realTP, 
                              nameEA, 16384, 0, Red); 
           if(ticket < 0)
               Print("OrderSend (",nameEA,") failed with error #", GetLastError());
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
   macdHistCurrent     = iMACD(NULL, 0, 12, 26, 9, PRICE_OPEN, MODE_MAIN, 0);   
   macdHistPrevious    = iMACD(NULL, 0, 12, 26, 9, PRICE_OPEN, MODE_MAIN, 1);   
   macdSignalCurrent   = iMACD(NULL, 0, 12, 26, 9, PRICE_OPEN, MODE_SIGNAL, 0); 
   macdSignalPrevious  = iMACD(NULL, 0, 12, 26, 9, PRICE_OPEN, MODE_SIGNAL, 1); 
   stochHistCurrent    = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
   stochHistPrevious   = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
   stochSignalCurrent  = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
   stochSignalPrevious = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
   // Parabolic Sar Current
   sarCurrent          = iSAR(NULL, 0, 0.02, 0.2, 0);
   // Parabolic Sar Previuos           
   sarPrevious         = iSAR(NULL, 0, 0.02, 0.2, 1);
   // Momentum Current           
   momCurrent          = iMomentum(NULL, 0, 14, PRICE_OPEN, 0);
   // Momentum Previous 
   momPrevious         = iMomentum(NULL, 0, 14, PRICE_OPEN, 1); 
   // Check for BUY, SELL, and CLOSE signal
   isBuying  = (sarCurrent <= Ask && sarPrevious>sarCurrent && momCurrent < 100 && 
                macdHistCurrent < macdSignalCurrent && stochHistCurrent < 35);
   isSelling = (sarCurrent >= Bid && sarPrevious<sarCurrent && momCurrent > 100 && 
                macdHistCurrent > macdSignalCurrent && stochHistCurrent > 60);
   isClosing = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prtAlert(string str = "") 
  {
   Print(str);
   Alert(str);
//   SpeechText(str,SPEECH_ENGLISH);
//   SendMail("Subject EA",str);
  }
//+------------------------------------------------------------------+