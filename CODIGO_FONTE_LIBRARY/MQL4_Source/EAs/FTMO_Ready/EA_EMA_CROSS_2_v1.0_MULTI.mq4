//+------------------------------------------------------------------+
//|                                                    EMA_CROSS.mq4 |
//|                                                      Coders Guru |
//|                                         http://www.forex-tsd.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| TODO: Add Money Management routine                               |
//+------------------------------------------------------------------+

#property copyright "Coders Guru"
#property link      "http://www.forex-tsd.com"
//---- input parameters
extern double TakeProfit = 20;
extern double StopLoss = 30;
extern double Lots = 2;
extern double TrailingStop = 50;
extern int ShortEma = 5;
extern int LongEma = 60;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Crossed (double line1 , double line2)
  {
    static int last_direction = 0;
    static int current_direction = 0;
    //Don't work in the first load, wait for the first cross!
    static bool first_time = true;
    if(first_time == true)
      {
        first_time = false;
        return (0);
      }
//----
    if(line1 > line2)
        current_direction = 1;  //up
    if(line1 < line2)
        current_direction = 2;  //down
//----
    if(current_direction != last_direction)  //changed 
      {
        last_direction = current_direction;
        return(last_direction);
      }
    else
      {
        return (0);  //not changed
      }
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
    int cnt, ticket, total;
    double SEma, LEma;
//----
    if(Bars < 100)
      {
        Print("bars less than 100");
        return(0);  
      }
//----
    if(TakeProfit < 10)
      {
        Print("TakeProfit less than 10");
        return(0);  // check TakeProfit
      }
//----
    SEma = iMA(NULL, 0, ShortEma, 0, MODE_EMA, PRICE_CLOSE, 0);
    LEma = iMA(NULL, 0, LongEma, 0, MODE_EMA, PRICE_CLOSE, 0);
//----
    static int isCrossed  = 0;
    isCrossed = Crossed (LEma, SEma);
//----
    total  = OrdersTotal(); 
    if(total < 1) 
      {
        if(isCrossed == 1)
          {
            ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, Ask - StopLoss*Point, 
                               Ask + TakeProfit*Point, "EMA_CROSS", 12345, 0, Green);
            if(ticket > 0)
              {
                if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                    Print("BUY order opened : ",OrderOpenPrice());
              }
            else 
                Print("Error opening BUY order : ", GetLastError()); 
            return(0);
          }
        if(isCrossed == 2)
          {
            ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, Bid + StopLoss*Point, 
                               Bid - TakeProfit*Point, "EMA_CROSS", 12345, 0, Red);
            if(ticket > 0)
              {
                if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                    Print("SELL order opened : ", OrderOpenPrice());
              }
            else 
                Print("Error opening SELL order : ",GetLastError()); 
            return(0);
          }
        return(0);
      } 
//----
    for(cnt = 0; cnt < total; cnt++)
      {
        OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if(OrderType() <= OP_SELL && OrderSymbol() == Symbol())
          {
            if(OrderType() == OP_BUY)   // long position is opened
              {
                // check for trailing stop
                if(TrailingStop > 0)  
                  {                 
                    if(Bid - OrderOpenPrice() > Point*TrailingStop)
                      {
                        if(OrderStopLoss() < Bid - Point*TrailingStop)
                          {
                            OrderModify(OrderTicket(), OrderOpenPrice(), 
                                        Bid - Point*TrailingStop, 
                                        OrderTakeProfit(), 0, Green);
                            return(0);
                          }
                      }
                  }
              }
            else // go to short position
              {
                // check for trailing stop
                if(TrailingStop > 0)  
                  {                 
                    if((OrderOpenPrice() - Ask) > (Point*TrailingStop))
                      {
                        if((OrderStopLoss() > (Ask + Point*TrailingStop)) || 
                           (OrderStopLoss() == 0))
                          {
                            OrderModify(OrderTicket(), OrderOpenPrice(), 
                                        Ask + Point*TrailingStop,
                                        OrderTakeProfit(), 0, Red);
                            return(0);
                          }
                      }
                  }
              }
          }
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+