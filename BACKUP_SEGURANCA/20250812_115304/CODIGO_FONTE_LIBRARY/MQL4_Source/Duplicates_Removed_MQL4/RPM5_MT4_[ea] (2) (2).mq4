//+-------------------------------------------------------------------------+
//| RPM5_MT4_[ea].mq4                                                       |
//| Copyright © 2005,yahoo.com/group/MetaTrader_Experts_and_Indicators/                                                       |
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/|
//+-------------------------------------------------------------------------+
#property copyright "Copyright © 2005,yahoo.com/group/MetaTrader_Experts_and_Indicators/"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

extern int BullBearPeriod=5;
extern double lots         = 1.0;           // 
extern double TrailingStop = 15;            // trail stop in points
extern double takeProfit   = 150;            // recomended  no more than 150
extern double stopLoss     = 45;             // do not use s/l
extern double slippage     = 3;

extern string nameEA       = "DayTrading";  // EA identifier. Allows for several co-existing EA with different values

double bull,bear;
double PrevBBE,CurrentBBE;
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
//Comment("bull+bear= ",bull + bear);
  CurrentBBE             = iCustom(NULL, 0, "BullsBearsEyes",13,0,0.5,300,0,0);
  PrevBBE                = iCustom(NULL, 0, "BullsBearsEyes",13,0,0.5,300,0,1);
   
  
   b = ((1 * Point) + (iATR(NULL,0,5,1) * 1.5));
   s = ((1 * Point) + (iATR(NULL,0,5,1) * 1.5));
   // Check for BUY, SELL, and CLOSE signal   
   //isBuying  = (bull+bear>0);
   //isSelling = (bull+bear<0);
   isBuying  = (CurrentBBE>0.50);
   isSelling = (CurrentBBE<0.50);

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