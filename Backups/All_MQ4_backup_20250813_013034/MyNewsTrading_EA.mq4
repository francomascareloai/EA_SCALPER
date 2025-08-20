//+------------------------------------------------------------------+
//|                                                  Straddle_EA.mq4 |
//|                                                           branac |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "branac"
#property link      "http://www.metaquotes.net"

//---- input parameters
extern double    Lots=0.1;
extern double    TPB=10;
extern double    SLB=10;
extern double    TPS=10;
extern double    SLS=10;
extern bool      Buy=true;
extern bool      Sell=true;
extern datetime  _Date=D'2010.02.12 08:00';
//extern datetime expiration=D'2006.08.02 03:25';
  int    buy_orders=0;
  int    sell_orders=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
  int ticket;
  // The spread is included in the sl and tp calculations
  double buy_price = Ask*Point;
  double sell_price = Bid*Point;
  double stoploss_buy = SLB*Point;
  double takeprofit_buy = TPB*Point;
  double stoploss_sell = SLS*Point ;
  double takeprofit_sell= TPS*Point;
    
 
  if(LocalTime()>=_Date)
       {
         // Buy order
         if ( (Buy == true) && (buy_orders == 0) )
         {
            ticket=OrderSend(Symbol(),OP_BUY,Lots,buy_price,2,stoploss_buy,takeprofit_buy,"Buy order ",00001,0,CLR_NONE);
            buy_orders = buy_orders + 1;
            if(ticket<0)
            {
               Print("OrderSend failed with error #",GetLastError());
               return(0);
            }
         }
         // Sell order
         if ( (Sell == true) && (sell_orders == 0) )
         {
            ticket=OrderSend(Symbol(),OP_SELL,Lots,sell_price,2,stoploss_sell,takeprofit_sell,"Buy order ",00002,0,CLR_NONE);
            sell_orders++;
            if(ticket<0)
            {
               Print("OrderSend failed with error #",GetLastError());
               return(0);
            }
         }
         }
  

//----
   return(0);
  }
//+------------------------------------------------------------------+