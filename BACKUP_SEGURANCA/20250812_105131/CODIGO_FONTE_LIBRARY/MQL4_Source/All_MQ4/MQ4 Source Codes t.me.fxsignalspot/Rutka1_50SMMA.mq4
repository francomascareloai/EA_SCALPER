//+------------------------------------------------------------------+
//|                           Copyright 2005, Gordago Software Corp. |
//|                                          http://www.gordago.com/ |
//+------------------------------------------------------------------+
  
// I want to thank Michal Rutka, michal1@zonnet.nl, for helping me correct
// the mistakes that I made... Good Job!!

#property copyright "Provided by sencho, coded by don_forex"
#property link      "http://www.gordago.com"

extern int TakeProfit = 850;
extern int TrailingStop = 850;
extern int PipDifference = 25;
extern double Lots = 0.1;
extern double MaximumRisk = 10;
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
   string TradeSymbol = Symbol();
   double MA13H = MathRound(iMA(NULL,0,13,0,MODE_SMMA,PRICE_HIGH,0)/Point)*Point;
   double MA13L = MathRound(iMA(NULL,0,13,0,MODE_SMMA,PRICE_LOW,0)/Point)*Point;
   double Spread = Ask-Bid; // MarketInfo(TradeSymbol,MODE_SPREAD);
   double BuyPrice      =MA13H + Spread+PipDifference*Point;
   double BuyStopLoss   =MA13L - Point;
   double BuyTakeProfit =MA13H +(PipDifference+TakeProfit)*Point;
   double SellPrice     =MA13L -(PipDifference)*Point;
   double SellStopLoss  =MA13H + Spread+Point;
   double SellTakeProfit=MA13L - Spread-(PipDifference+TakeProfit)*Point;
   double lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/50000,1);
   double close=iClose(NULL,0,0);
   int total=OrdersTotal();
   
   bool need_long  = true;
   bool need_short = true;
   // First update existing orders.
   for(cnt=0;cnt<total;cnt++) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == 16384){
         if(OrderType() == OP_BUYSTOP){
            need_long = false;
            if (OrderStopLoss()!=BuyStopLoss){
               Print(BuyStopLoss, " ",OrderStopLoss());
               OrderModify(OrderTicket(),BuyPrice,BuyStopLoss,BuyTakeProfit,0,Green);
            }
         }
         if(OrderType() == OP_SELLSTOP){
            need_short = false;
            if (OrderStopLoss()!=SellStopLoss){
               Print(SellStopLoss, " ",OrderStopLoss());
               OrderModify(OrderTicket(),SellPrice,SellStopLoss,SellTakeProfit,0,Green);
            }
         }
         if(OrderType()==OP_BUY){
            need_long = false;
            if (OrderStopLoss()<BuyStopLoss){
               Print(BuyStopLoss, " ",OrderStopLoss());
               OrderModify(OrderTicket(),OrderOpenPrice(),BuyStopLoss,BuyTakeProfit,0,Green);
               OrderDelete(OrderTicket());
            }
            if(TrailingStop>0) {
               if(Bid-OrderOpenPrice()>Point*TrailingStop) {
                  if(OrderStopLoss()<Bid-Point*TrailingStop) {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     return(0);
                  }
               }
            }
         }
         if(OrderType()==OP_SELL){
            need_short = false;
            if (OrderStopLoss()>SellStopLoss){
               Print(SellStopLoss, " ",OrderStopLoss());
               OrderModify(OrderTicket(),OrderOpenPrice(),SellStopLoss,SellTakeProfit,0,Green);
               OrderDelete(OrderTicket());
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
      
   if(AccountFreeMargin()<(1000*lot)){
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
       
   if (close<MA13H && close>MA13L){
      if(need_long)
         ticket=OrderSend(Symbol(),OP_BUYSTOP,lot,BuyPrice,3,BuyStopLoss,BuyTakeProfit,"Binario_v3",16384,0,Green);
      if(need_short)
         ticket=OrderSend(Symbol(),OP_SELLSTOP,lot,SellPrice,3,SellStopLoss,SellTakeProfit,"Binario_v3",16384,0,Red);
   }   
}



