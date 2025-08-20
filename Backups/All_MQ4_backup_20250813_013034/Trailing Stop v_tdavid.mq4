//+------------------------------------------------------------------+
//|                                       Trailing Stop v_tdavid.mq4 |
//|                              transport_david , David W Honeywell |
//|                                        transport.david@gmail.com |
//+------------------------------------------------------------------+
#property copyright "transport_david , David W Honeywell"
#property link      "transport.david@gmail.com"

extern int MagicNumber  = 123;
extern int TrailingStop =  15;

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
   
   int cnt,total=OrdersTotal();
   
   for(cnt = total-1; cnt >= 0; cnt--)
    {
     RefreshRates();
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if ((OrderSymbol() == Symbol()) && (OrderProfit() > 0.00)   ) //&& (OrderMagicNumber() == MagicNumber))
      {
       if ((TrailingStop > 0) && (MathAbs(OrderClosePrice() - OrderOpenPrice()) > TrailingStop*Point))
        {
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderClosePrice()-TrailingStop*Point,OrderTakeProfit(),0,White);
        }
      }
    }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+