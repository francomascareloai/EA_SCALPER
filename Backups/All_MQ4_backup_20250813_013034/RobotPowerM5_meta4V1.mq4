//+------------------------------------------------------------------+
//|                                                      RobotBB.mq4 |
//|                               Copyright © 2005,          Company |
//|                                          http://                 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005"
#property link      "http://www.funds.com"

// A reliable expert, use it on 5 min charts (GBP is best) with 150/pips profit limit. 
// . No worries, check the results 
extern int BullBearPeriod=5;
extern double lots         = 1.0;           // 
extern double TrailingStop = 15;            // trail stop in points
extern double takeProfit   = 150;            // recomended  no more than 150
extern double stopLoss     = 45;             // do not use s/l
extern double slippage     = 3;

extern string nameEA       = "DayTrading";  // EA identifier. Allows for several co-existing EA with different values

double bull,bear;
//double stochHistCurrent, stochHistPrevious, stochSignalCurrent, stochSignalPrevious;
//double sarCurrent, sarPrevious, momCurrent, momPrevious;
double realTP, realSL,b,s,sl,tp;
bool isBuying = false, isSelling = false, isClosing = false;
int cnt, ticket;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
   return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
   // Check for invalid bars and takeprofit
   if(Bars < 200) {
      Print("Not enough bars for this strategy - ", nameEA);
      return(-1);
   }
   calculateIndicators();                      // Calculate indicators' value   
   
   // Control open trades
   int totalOrders = OrdersTotal();
   int numPos = 0;
   for(cnt=0; cnt<totalOrders; cnt++) {        // scan all orders and positions...
      OrderSelect(cnt, SELECT_BY_POS);         // the next line will check for ONLY market trades, not entry orders
      if(OrderSymbol() == Symbol() && OrderType() <= OP_SELL ) {   // only look for this symbol, and only orders from this EA      
         numPos++;
         if(OrderType() == OP_BUY) {           // Check for close signal for bought trade
               
            if(TrailingStop > 0) {             // Check trailing stop
               if(Bid-OrderOpenPrice() > TrailingStop*Point)
                {
                  if(OrderStopLoss() < (Bid - TrailingStop*Point))
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*Point,OrderTakeProfit(),0,Blue);
               }
            }
         } else {                              // Check sold trade for close signal
            
            if(TrailingStop > 0) {             // Control trailing stop
               if(OrderOpenPrice() - Ask > TrailingStop*Point)
                {
                  if(OrderStopLoss() == 0 || OrderStopLoss() > Ask + TrailingStop*Point)
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*Point,OrderTakeProfit(),0,Red);
               }           
            } 
         }
      }
   }
   
   // If there is no open trade for this pair and this EA
   if(numPos < 1) {   
      if(AccountFreeMargin() < 1000*lots) {
         Print("Not enough money to trade ", lots, " lots. Strategy:", nameEA);
         return(0);
      }
      if(isBuying && !isSelling && !isClosing) {  // Check for BUY entry signal
         sl = Ask - stopLoss * Point;
         tp = Bid + takeProfit * Point;
         
        // ticket = OrderSend(OP_BUY,lots,Ask,slippage,realSL,realTP,nameEA,16384,0,Red);  // Buy
         //OrderSend(OP_BUY,lots,Ask,slippage,realSL,realTP,0,0,Red);
         OrderSend(Symbol(),OP_BUY,lots,Ask,slippage,sl,tp,nameEA+CurTime(),0,0,Green);
         Comment(sl);
         if(ticket < 0)
            Print("OrderSend (",nameEA,") failed with error #", GetLastError());
        
      }
      if(isSelling && !isBuying && !isClosing) {  // Check for SELL entry signal
          sl = Bid + stopLoss * Point;
          tp = Ask - takeProfit * Point;
        // ticket = OrderSend(NULL,OP_SELL,lots,Bid,slippage,realSL,realTP,nameEA,16384,0,Red); // Sell
         OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,sl,tp,nameEA+CurTime(),0,0,Red);
         if(ticket < 0)
            Print("OrderSend (",nameEA,") failed with error #", GetLastError());
        
      }
   }
   return(0);
}

void calculateIndicators() {    // Calculate indicators' value   
 

   bull = iBullsPower(NULL,0,BullBearPeriod,PRICE_CLOSE,1);
   bear = iBearsPower(NULL,0,BullBearPeriod,PRICE_CLOSE,1);
Comment("bull+bear= ",bull + bear);
   //sarCurrent          = iSAR(NULL,0,0.02,0.2,0);           // Parabolic Sar Current
   //sarPrevious         = iSAR(NULL,0,0.02,0.2,1);           // Parabolic Sar Previuos
   //momCurrent          = iMomentum(NULL,0,14,PRICE_OPEN,0); // Momentum Current
  // momPrevious         = iMomentum(NULL,0,14,PRICE_OPEN,1); // Momentum Previous
   
  
   b = 1 * Point + iATR(NULL,0,5,1) * 1.5;
   s = 1 * Point + iATR(NULL,0,5,1) * 1.5;
   // Check for BUY, SELL, and CLOSE signal
  // isBuying  = (sarCurrent<=Ask && sarPrevious>sarCurrent && momCurrent<100 && macdHistCurrent<macdSignalCurrent && stochHistCurrent<35);
  // isSelling = (sarCurrent>=Bid && sarPrevious<sarCurrent && momCurrent>100 && macdHistCurrent>macdSignalCurrent && stochHistCurrent>60);
    isBuying  = (bull+bear>0);
    isSelling = (bull+bear<0);

   isClosing = false;

 for (int i = 0; i < OrdersTotal(); i++) 
 {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if (OrderType() == OP_BUY)
       {
     TrailingStop=b;
        
      if (Bid - OrderOpenPrice() > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
        {
           if (OrderStopLoss() < Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
               {
               OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
            }
         }
      } else if (OrderType() == OP_SELL) 
      {
      TrailingStop=s;
         if (OrderOpenPrice() - Ask > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
          {
            if ((OrderStopLoss() > Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) || 
                  (OrderStopLoss() == 0)) {
               OrderModify(OrderTicket(), OrderOpenPrice(),
                  Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
            }
         }
     }
 } 
    
return(0);
   
}

//+------------------------------------------------------------------+