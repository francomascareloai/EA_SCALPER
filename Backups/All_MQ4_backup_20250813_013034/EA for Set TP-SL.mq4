//+------------------------------------------------------------------+
//|                                             EA for Set TP-SL.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

int order_total;
int cb = 0;
int cs = 0;
int cbs = 0;
int css = 0;
int ticket_b;
int ticket_s;
double op_b;
double op_s;
extern int SL = 29;
extern int TP = 10;

int init()
  {
   if(MarketInfo("EURUSD",MODE_DIGITS)==5){
      SL = SL*10;
      TP = TP*10;
   }
   return(0);
  }

int start()
  {
   order_total = OrdersTotal();
   cb = false;
   cs = false;
   cbs = false;
   css = false;
   for(int i = order_total; i >= 0; i--){
      if(OrderSelect(i,SELECT_BY_POS) == true && OrderSymbol() == Symbol()){
         if(OrderType() == OP_BUY){
            cb = true;
            ticket_b = OrderTicket();
            op_b = NormalizeDouble(OrderOpenPrice(), Digits);
            Modify_order();
         }
         if(OrderType() == OP_SELL){
            cs = true;
            ticket_s = OrderTicket();
            op_s = NormalizeDouble(OrderOpenPrice(), Digits);
            Modify_order();
         }
      }
   }
   
   return(0);
  }
  
void Modify_order() {
   if (cb == TRUE) {
      if(OrderStopLoss()==0 && OrderTakeProfit()==0){
         OrderModify(ticket_b, 0, op_b-SL*Point, op_b+TP*Point, 0, 0);
      }
   }
   if (cs == TRUE) {
      if(OrderStopLoss()==0 && OrderTakeProfit()==0){
         OrderModify(ticket_s, 0, op_s+SL*Point, op_s-TP*Point, 0, 0);
      }
   }
}

