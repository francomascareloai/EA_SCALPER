//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
  
// I want to thank Michal Rutka, michal1@zonnet.nl, for helping me correct
// the mistakes that I made... Good Job!!

#property copyright "Provided by sencho, coded by don_forex, modified by TR"

extern int TakeProfit = 999;
extern int TrailingStop = 999;
extern int PipDifference = 25;
extern bool EnableMM? = false;
extern double LotsIfNoMM = 0.1;
extern double MaximumRiskIfMM = 10;


double LastLogTime,NoTouchBarLong,NoTouchBarShort;

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
   double MA144H = MathRound(iMA(NULL,0,144,0,MODE_EMA,PRICE_HIGH,1)/Point)*Point;
   double MA144L = MathRound(iMA(NULL,0,144,0,MODE_EMA,PRICE_LOW,1)/Point)*Point;
   double Spread = Ask-Bid; // MarketInfo(TradeSymbol,MODE_SPREAD);
   double BuyPrice      = MA144H + Spread+PipDifference*Point;
   double BuyStopLoss   = MA144L - Point;
   double BuyTakeProfit = MA144H +(PipDifference+TakeProfit)*Point;
   double SellPrice     = MA144L -(PipDifference)*Point;
   double SellStopLoss  = MA144H + Spread+Point;
   double SellTakeProfit= MA144L - Spread-(PipDifference+TakeProfit)*Point;
   double lot;
   double close=iClose(NULL,0,1);
   int total=OrdersTotal();
   
   if (EnableMM?) lot=NormalizeDouble(AccountFreeMargin()*MaximumRiskIfMM/50000,1);
      else lot=LotsIfNoMM;
   
   bool need_long  = true;
   bool need_short = true;
   // First update existing orders.
   for(cnt=0;cnt<total;cnt++) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == 16384){
         if(OrderType() == OP_BUYSTOP){
            need_long = false;
            NoTouchBarLong=iTime(NULL,0,0);
            if (OrderStopLoss()!=BuyStopLoss){
               Print(BuyStopLoss, " ",OrderStopLoss());
               //if (BuyPrice<High[1]+Spread+PipDifference*Point) BuyPrice=High[1]+Spread+PipDifference*Point;
               OrderModify(OrderTicket(),BuyPrice,BuyStopLoss,BuyTakeProfit,0,Green);
            }
         }
         if(OrderType() == OP_SELLSTOP){
            need_short = false;
            NoTouchBarShort=iTime(NULL,0,0);
            if (OrderStopLoss()!=SellStopLoss){
               Print(SellStopLoss, " ",OrderStopLoss());
               OrderModify(OrderTicket(),SellPrice,SellStopLoss,SellTakeProfit,0,Green);
            }
         }
         if(OrderType()==OP_BUY){
         
            if (IsTesting() && LastLogTime != iTime(NULL,PERIOD_H1,1)) 
            {
               LastLogTime=iTime(NULL,PERIOD_H1,1);
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()+Point*1,0,Cyan);
            }

            need_long = false;
            NoTouchBarLong=iTime(NULL,0,0);
            if (OrderStopLoss()<BuyStopLoss){
               Print(BuyStopLoss, " ",OrderStopLoss());
               OrderModify(OrderTicket(),OrderOpenPrice(),BuyStopLoss,BuyTakeProfit,0,Green);
               //OrderDelete(OrderTicket());
            }
            if(TrailingStop>0) {
               if(Bid-OrderOpenPrice()>Point*TrailingStop) {
                  if(OrderStopLoss()<Bid-Point*TrailingStop) {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     //return(0);
                  }
               }
            }
         }
         if(OrderType()==OP_SELL){

            if (IsTesting() && LastLogTime != iTime(NULL,PERIOD_H1,1)) 
            {
               LastLogTime=iTime(NULL,PERIOD_H1,1);
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit()-Point*1,0,Cyan);
            }

            need_short = false;
            NoTouchBarShort=iTime(NULL,0,0);
            if (OrderStopLoss()>SellStopLoss){
               Print(SellStopLoss, " ",OrderStopLoss());
               OrderModify(OrderTicket(),OrderOpenPrice(),SellStopLoss,SellTakeProfit,0,Green);
               //OrderDelete(OrderTicket());
            }
            if(TrailingStop>0) {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop)) {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0)) {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                     //return(0);
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
       
   //if (Low[1]<MA144H && High[1]>MA144L){
      if(need_long && iTime(NULL,0,0)!=NoTouchBarLong)
         {
         if (BuyPrice<Bid+Point*10) 
            ticket=OrderSend(Symbol(),OP_BUY,lot,Ask,10,BuyStopLoss,BuyTakeProfit,"Binario_v3",16384,0,Green);
           else
            ticket=OrderSend(Symbol(),OP_BUYSTOP,lot,BuyPrice,3,BuyStopLoss,BuyTakeProfit,"Binario_v3",16384,0,Green);
         }
      if(need_short && iTime(NULL,0,0)!=NoTouchBarShort)
         {
         if (SellPrice>Ask-Point*10) 
            ticket=OrderSend(Symbol(),OP_SELL,lot,Bid,10,SellStopLoss,SellTakeProfit,"Binario_v3",16384,0,Red);
           else 
            ticket=OrderSend(Symbol(),OP_SELLSTOP,lot,SellPrice,3,SellStopLoss,SellTakeProfit,"Binario_v3",16384,0,Red);
         }
   //}   
}



