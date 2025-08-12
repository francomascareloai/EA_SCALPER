//+------------------------------------------------------------------+
//|                           Copyright 2005, Gordago Software Corp. |
//|                                          http://www.gordago.com/ |
//+------------------------------------------------------------------+

#property copyright "Pegasys by don_forex"
//#property link      "http://www.gordago.com"

extern double StopLoss = 20;
extern double TakeProfit = 50;
extern double TrailingStop = 15;
extern double Lots = 0.1;
extern double SMA = 55;
extern double LWMA = 55;
extern double StdDev = 55;
extern double StdDevValue = 0.028;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start(){
   int cnt, ticket;
   if(Bars<100){
      Print("bars less than 100");
      return(0);
   }
   if(TakeProfit<10){
      Print("TakeProfit less than 10");
      return(0);
   }
   if(TakeProfit<10){
      Print("TakeProfit less than 10");
      return(0);
   }

   double diSMA=iMA(NULL,0,SMA,8,MODE_SMA,PRICE_CLOSE,0);
   double diLWMA=iMA(NULL,0,LWMA,0,MODE_LWMA,PRICE_CLOSE,0);
   double diStdDev=iStdDev(NULL,0,StdDev,MODE_LWMA,0,PRICE_CLOSE,0); 
   int total=OrdersTotal();
   if(total<1){
      if(AccountFreeMargin()<(1000*Lots)){
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);
      }

      if ((diSMA<diLWMA && diStdDev > StdDevValue)){
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point, "Pegasus",16384,0,Green);
         if(ticket>0){
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
         }
         else Print("Error opening BUY order : ",GetLastError());
         return(0);
      }

      if ((diSMA>diLWMA && diStdDev > StdDevValue)){
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"Pegasus",16384,0,Red);
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

            if ((diSMA>diLWMA && diStdDev > StdDevValue)){
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
               return(0);
            }
            
            if(TrailingStop>0) {
               if(Bid-OrderOpenPrice()>Point*TrailingStop) {
                  if(OrderStopLoss()<Bid-Point*TrailingStop) {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     return(0);
                  }
               }
            }
         }else{

            if ((diSMA<diLWMA && diStdDev > StdDevValue)){
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet);
               return(0);
            }
            if(TrailingStop>0) {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop)) {
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