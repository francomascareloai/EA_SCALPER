//+------------------------------------------------------------------+
//|                                                   ÌîÿÑèñòåìà.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net"
// ÈÑÏÎËÜÇÎÂÀÒÜ ÍÀ 15 ÌÈÍÓÒÊÀÕ
// Ñ ÝÒÈÌÈ ÏÀÐÀÌÅÒÐÀÌÈ ÍÀ EURUSD
//---- input parameters
extern double TakeProfit = 86;
extern double Lots = 8.3;
extern double StopLoss = 60;
extern double TrailingStop = 10;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int start()
  {
   double pos1pre, pos2cur, hzbul1, hzbul2, hzbear1, hzbear2;
   int cnt, ticket, total, TotalOpenOrders;
   hzbul1 = iBullsPower(NULL, 0, 13, PRICE_WEIGHTED, 1);
   hzbul2 = iBullsPower(NULL, 0, 13, PRICE_CLOSE, 0);
   hzbear1 = iBearsPower(NULL, 0, 13, PRICE_WEIGHTED, 1);
   hzbear2 = iBearsPower(NULL, 0, 13, PRICE_CLOSE, 0);
   pos1pre = ((hzbear1 + hzbul1) / 2);
   pos2cur = ((hzbear2 + hzbul2) / 2);
   total = OrdersTotal();
   if(pos1pre > pos2cur)
     {
       for(cnt = 0; cnt < total; cnt++)
         {
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           if(OrderType() <= OP_BUY && OrderSymbol()==Symbol())
             {
               if(Bid > (OrderSelect(cnt, OrderOpenPrice(), MODE_TRADES) + TrailingStop*Point))
                 {
                   OrderClose(OrderSelect(cnt, Symbol()), Lots, Bid, 3, Violet);
                 }
             }
         }
     }
   if(pos2cur < 0)
     {
       for(cnt = 0; cnt < total; cnt++)
         {
           OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
           if(OrderType() <= OP_SELL && OrderSymbol() == Symbol())
             {
               if(Ask > (OrderSelect(cnt, OrderOpenPrice(), MODE_TRADES) - TrailingStop*Point))
                 {
                   OrderClose(OrderSelect(cnt, Symbol()), Lots, Ask, 3, Violet);
                 }
             }
         }
     }
   for(cnt = 0; cnt < total; cnt++)
     {
       if(OrderSymbol() == Symbol())
         {
           TotalOpenOrders = TotalOpenOrders + 1;
         }
     }
   if(OrdersTotal() < 1)
     {
       if(pos1pre > pos2cur && pos2cur > 0)
         {
           OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, Bid + StopLoss*Point, 
                     Bid - TakeProfit*Point, NULL, 0, 0, Red);
         }
       if(pos2cur < 0)
         {
           OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, Ask - StopLoss*Point, 
                     Ask + TakeProfit*Point, NULL, 0, 0, Red);
           TotalOpenOrders = 1;
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+