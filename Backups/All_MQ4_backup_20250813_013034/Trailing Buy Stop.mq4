//+------------------------------------------------------------------+
//|                                            Trailing Buy Stop.mq4 |
//+------------------------------------------------------------------+
#property copyright    "R. Syam"
#property description  "Berbagi Strategi Forex Trading II"
#property description  "https://www.facebook.com/groups/397846790402999/"
#property description  "Empower Your Heart. Think Positively"
#property description  "Empower Your Life. Give Generously"

//--- input parameters
extern int       Distance     = 7;
extern double    Lots         = 0.01;
extern int       StopLoss     = 200;
extern int       TrailingStop = 100;
extern int       TakeProfit   = 100;
extern int       Slipage      = 30;
extern double    Magic        = 123456;

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
    int i,cnt,ticketShort,ticketLong;
    double targetLong,targetShort,_sl,_tp;
    cnt = OrdersTotal();
    ticketShort   = 0;
    ticketLong    = 0;
    targetLong    = 0;
    targetShort   = 0;
    if (Distance != 0) targetLong=Bid+Distance*Point;
    
       
    for (i=0;i<cnt;i++)
    {
       if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
       {
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
          { 
            if (OrderType() == OP_BUY)
            {
              if (TrailingStop != 0 && OrderProfit() > 0)
              {
                     _sl = Ask-TrailingStop*Point;
                    if (OrderStopLoss() < _sl)
                    ticketLong = OrderModify(OrderTicket(),OrderOpenPrice(),_sl,OrderTakeProfit(),OrderExpiration(),CLR_NONE);
              }
               ticketLong = -1; // running order, do not make new one
            }
            if (OrderType() == OP_SELL)
            {
              if (TrailingStop != 0 && OrderProfit() > 0)
              {
                     _sl = Bid+TrailingStop*Point;
                    if (OrderStopLoss() > _sl)
                    ticketShort = OrderModify(OrderTicket(),OrderOpenPrice(),_sl,OrderTakeProfit(),OrderExpiration(),CLR_NONE);
              }
               ticketShort = -1; // running order, do not make new one
            }
            if (OrderType() == OP_SELLSTOP)
            {
               ticketShort = OrderTicket();
               
            }
            
            if (OrderType() == OP_BUYSTOP)
            {
                ticketLong = OrderTicket();
            
           }
         }
       }
    }
    
    //Print("Ticket Long = "+ticketLong+" ticketShort="+ticketShort);
   // Print("Target="+target+" ticket="+ticket);
    _tp = 0;
   if (Distance != 0)
   {
      if (ticketLong == 0)
      {
           _sl = targetLong-StopLoss*Point;
           if (TakeProfit != 0) _tp = targetLong+TakeProfit*Point;     
           Print("OrderSend BUY STOP: price="+targetLong+" SL="+_sl+" tp="+_tp);
           ticketLong = OrderSend(Symbol(),OP_BUYSTOP,Lots,targetLong,Slipage,_sl,_tp,"Follow",Magic,0,CLR_NONE);
           if (ticketLong < 0) Print("Order Failed with ");
       }
      if (ticketLong != -1)
      {
       if (targetLong < OrderOpenPrice())
       {
           _sl = targetLong-StopLoss*Point;
           if (TakeProfit != 0) _tp = targetLong+TakeProfit*Point;     
           Print("Modify BUY STOP: price="+targetLong+" SL="+_sl+" tp="+_tp);
           ticketLong = OrderModify(ticketLong,targetLong,_sl,_tp,OrderExpiration(),CLR_NONE);
           if (ticketLong < 0) Print("Order Failed with ");
       }
      }
       
    }
    
    //Print("Profit = "+totalProfit      
//----
   return(0);
  }
//+------------------------------------------------------------------+