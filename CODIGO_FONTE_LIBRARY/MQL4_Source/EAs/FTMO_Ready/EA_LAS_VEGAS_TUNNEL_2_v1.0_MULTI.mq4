///
//+------------------------------------------------------------------+
//|                                   Copyright 2005, Chris Battles. |
//|                                              cbattles@neo.rr.com |
//+------------------------------------------------------------------+


#property copyright "Copyright 2005, Chris Battles."
#property link      "cbattles@neo.rr.com"

extern double TrailingStop = 30;
extern double TrailingStopTrigger = 20;
extern double StopLoss = 25;
extern double TakeProfit = 230;
extern double Lots = 1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start(){
   int cnt, ticket;
   if(Bars<100){
      Print("bars less than 100");
      return(0);
   }

   double ema1a=iMA(NULL,60,169,0,MODE_EMA,PRICE_CLOSE,0);
   double ema2a=iMA(NULL,60,144,0,MODE_EMA,PRICE_CLOSE,0);
   double ema3a=iMA(NULL,60,12,0,MODE_EMA,PRICE_CLOSE,0);
   double ema1b=iMA(NULL,60,169,0,MODE_EMA,PRICE_CLOSE,1);
   double ema2b=iMA(NULL,60,144,0,MODE_EMA,PRICE_CLOSE,1);
   double ema3b=iMA(NULL,60,12,0,MODE_EMA,PRICE_CLOSE,1);

   int total=OrdersTotal();
   if(total<1){
      if(AccountFreeMargin()<(1000*Lots)){
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);
      }
 
 //    if (ema3b<ema1b && ema3a>ema1a){
 
       if (iClose(Symbol(),0,1)>ema1a){
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point, NULL,16384,0,Green);
         if(ticket>0){
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
         }
         else Print("Error opening BUY order : ",GetLastError());
         return(0);
      }

 //     if (ema3b>ema2b && ema3a<ema2a){
      
      if (iClose(Symbol(),0,1)<ema1b){
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point, NULL,16384,0,Red);
         if(ticket>0) {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
         }
         else Print("Error opening SELL order : ",GetLastError());
         return(0);
      }
   }
   for(cnt=0;cnt<total;cnt++) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol()) {
         if(OrderType()==OP_BUY){
            if(TrailingStop>0) {
               if(Bid-OrderOpenPrice()>Point*TrailingStopTrigger) {
                  if(OrderStopLoss()<Bid-Point*TrailingStop) {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     return(0);
                  }
               }
            }
         }else{
            if(TrailingStop>0) {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStopTrigger)) {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0)) {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
}