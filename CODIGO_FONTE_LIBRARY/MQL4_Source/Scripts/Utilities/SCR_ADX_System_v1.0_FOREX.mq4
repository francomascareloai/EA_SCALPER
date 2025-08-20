//+------------------------------------------------------------------+
//|                                                   ADX_System.mq4 |
//|                                                           System |
//|                                                   work_a@ukr.net |
//+------------------------------------------------------------------+
#property copyright "System"
#property link      "work_a@ukr.net"

extern double TakeProfit = 100;
extern double Lots =1;
extern double TrailingStop = 0;
extern double StopLoss = 30;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
    double ADXP, ADXC, ADXDIPP;
    double ADXDIPC, ADXDIMP, ADXDIMC;
    int cnt, ticket, total;
    if(Bars < 100)
      {
        Print("bars less than 100");
        return(0);  
      }
    if(TakeProfit < 10)
      {
        Print("TakeProfit less than 10");
        return(0);  // check TakeProfit
      }
    ADXP = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, 2);
    ADXC = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, 1);
    ADXDIPP = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_PLUSDI, 2);
    ADXDIPC = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_PLUSDI, 1);  
    ADXDIMP = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MINUSDI, 2);
    ADXDIMC = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MINUSDI, 1);  
    total = OrdersTotal();
    if(total < 1) 
      {
        // no opened orders identified
        if(AccountFreeMargin() < (1000*Lots))
          {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);  
          }
        // check for long position (BUY) possibility
        if((ADXP < ADXC) && (ADXDIPP < ADXP) && (ADXDIPC > ADXC))
          {
            ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, Bid - StopLoss*Point, 
                               Ask + TakeProfit*Point, "adx sample", 16384, 0, Green);
            if(ticket > 0)
              {
                if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
                    Print("BUY order opened : ", OrderOpenPrice());
              }
            else 
                Print("Error opening BUY order : ",GetLastError()); 
            return(0); 
          }
        // check for short position (SELL) possibility
        if((ADXP < ADXC) && (ADXDIMP < ADXP) && (ADXDIMC > ADXC))
          {
            ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, Ask + StopLoss*Point, 
                               Bid - TakeProfit*Point, "adx sample", 16384, 0, Red);
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
    for(cnt = 0; cnt < total; cnt++)
      {
        OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if(OrderType() <= OP_SELL &&   // check for opened position 
           OrderSymbol()==Symbol())  // check for symbol
          {
            if(OrderType() == OP_BUY)   // long position is opened
              {
                if(ADXP > ADXC && ADXDIPP > ADXP && ADXDIPC < ADXC)
                  {
                    OrderClose(OrderTicket(), OrderLots(), Bid, 3, Violet); // close position
                      return(0); // exit
                  }
                if(TrailingStop > 0)  
                  {                 
                    if(Bid - OrderOpenPrice() > Point*TrailingStop)
                      {
                        if(OrderStopLoss() < Bid - Point*TrailingStop)
                          {
                            OrderModify(OrderTicket(), OrderOpenPrice(), 
                                        Bid - Point*TrailingStop, OrderTakeProfit(), 
                                        0, Green);
                            return(0);
                          }
                      }
                  }
              }
            else 
              {
                if(ADXP > ADXC && ADXDIMP > ADXP && ADXDIMC < ADXC)
                  {
                    OrderClose(OrderTicket(), OrderLots(), Ask, 3, Violet); // close position
                    return(0); // exit
                  }
                if(TrailingStop > 0)  
                  {                 
                    if((OrderOpenPrice() - Ask) > (Point*TrailingStop))
                      {
                        if((OrderStopLoss() > (Ask + Point*TrailingStop)) || 
                           (OrderStopLoss() == 0))
                          {
                            OrderModify(OrderTicket(), OrderOpenPrice(), 
                                        Ask + Point*TrailingStop, OrderTakeProfit(), 
                                        0,Red);
                            return(0);
                          }
                      }
                  }
              }
          }
      }
    return(0);
  }
//+------------------------------------------------------------------+

