//+------------------------------------------------------------------+
//|                                              Trailing Stop 5.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
extern double TakeProfit = 0;
extern double StopLoss = 15;
extern double Lots = 1;
extern double TrailingStop = 5;

int init()
  {
//---- TODO: Add your code here.
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int pos3pre = 1;
int pos4cur = 0;
int cnt = 0;
int openpozprice = 0;
int mode = 0;
int deinit()
  {
//---- TODO: Add your code here.
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  for (int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if (OrderType() == OP_BUY) {
         //if (Bid > (OrderValue(cnt,VAL_OPENPRICE) + TrailingStop * Point)) {
         //   OrderClose(OrderTicket(), OrderLots(), Bid, 3, Violet);
         //   break;
         //}
         if (Bid - OrderOpenPrice() > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) {
            if (OrderStopLoss() < Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) {
               OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
            }
         }
      } else if (OrderType() == OP_SELL) {
         if (OrderOpenPrice() - Ask > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) {
            if ((OrderStopLoss() > Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) || 
                  (OrderStopLoss() == 0)) {
               OrderModify(OrderTicket(), OrderOpenPrice(),
                  Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), Red);
            }
         }
      }
	}

//---- TODO: Add your code here.
   
//----
   return(0);
  }
//+------------------------------------------------------------------+