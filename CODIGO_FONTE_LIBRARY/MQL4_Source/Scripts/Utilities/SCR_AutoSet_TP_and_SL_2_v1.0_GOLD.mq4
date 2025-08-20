//+------------------------------------------------------------------+
//|                                            AutoSet TP and SL.mq4 |
//|                                   Copyright 2019, Catalin Zachiu |
//|                      https://www.mql5.com/en/users/catalinzachiu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Catalin Zachiu"
#property link      "https://www.mql5.com/en/users/catalinzachiu"
#property version   "1.00"
#property strict
 #property show_inputs

input double Set_TP_At = 0;
input double Set_SL_At = 0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
      int total = OrdersTotal();
  for(int b=total-1;b>=0;b--)
  {
     if(OrderSelect(b, SELECT_BY_POS)==false) break;
     if(OrderCloseTime()!=0 || OrderSymbol()!=Symbol()) continue;
     
     if(OrderType()==OP_BUY)
       if(Set_TP_At>0 && Set_TP_At>Ask)
         if(OrderTakeProfit()>=0)
                 {
                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),Set_TP_At,0,clrNONE))
                        Print("Take Profit Updated TO New Level ",OrderTicket());
                     
                    }
                  
         if(Set_SL_At>0 && Set_SL_At<Bid)
         if(OrderStopLoss()>=0)
                 {
                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),Set_SL_At,OrderTakeProfit(),0,clrNONE))
                        Print("Stop Loss Updated TO New Level ",OrderTicket());
                     
                    }
                    
      if(OrderType()==OP_SELL)
       if(Set_TP_At>0 && Set_TP_At<Bid)
         if(OrderTakeProfit()>=0)
                 {
                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),Set_TP_At,0,clrNONE))
                        Print("Take Profit Updated TO New Level ",OrderTicket());
                     
                    }
                  
         if(Set_SL_At>0 && Set_SL_At>Ask)
         if(OrderStopLoss()>=0)
                 {
                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),Set_SL_At,OrderTakeProfit(),0,clrNONE))
                        Print("Stop Loss Updated TO New Level ",OrderTicket());
                     
                    }
  }
//---
   
  }
//+------------------------------------------------------------------+
