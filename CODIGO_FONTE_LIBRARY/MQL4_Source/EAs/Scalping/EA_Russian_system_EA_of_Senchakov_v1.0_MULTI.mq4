//+------------------------------------------------------------------+
//|                                  Russian system of Senchakov.mq4 |
//+------------------------------------------------------------------+
extern double percent_lot=3;//%
extern double percent_profit=2.2;//%
extern int Step=8;//Ўаг
extern int magic=092341;

double lots;//первый лот
double sizelot=0;
int Ticket=-1;
double pp;

int init()
  {
      if (Digits < 4) 
      {
      pp = 0.01;
      } else 
      {
      pp = 0.0001;
      }   
   return(0);
  }

int deinit()
  {
   close_reserved();
   return(0);
  }

void OpenGrid()
{
  //расчет первого лота
  //внимательна€ установка трендовой сетки
  //внимательна€ установка откатной сетки
 double Free_margin = AccountFreeMargin();
 double One_Lot_cost = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
 double Step_lot = MarketInfo(Symbol(),MODE_LOTSTEP);
 double lots = MathFloor(Free_margin*percent_lot/100/One_Lot_cost/Step_lot)*Step_lot;  
   
  int i;
  int Step_tmp;
  int n;
  for (i=1;i<=20;i++)
  {
    
    if (i==1) {sizelot=lots;Step_tmp=Step;} else {sizelot=sizelot+lots;Step_tmp=Step_tmp+Step;}
    n=3;
    Ticket=-1;
    
    while (Ticket<0 && n>0)
    {
      Ticket=OrderSend(Symbol(),OP_BUYSTOP,sizelot,NormalizeDouble(Bid+Step_tmp*pp,Digits),3,0,0,"buy RS :"+TimeToStr(TimeCurrent(),TIME_MINUTES),magic,0,Blue);
      n--;
    }     
    
    n=3;
    Ticket=-1;
    
    while (Ticket<0 && n>0)
    {    
      Ticket=OrderSend(Symbol(),OP_SELLSTOP,sizelot,NormalizeDouble(Ask-Step_tmp*pp,Digits),3,0,0,"sell RS :"+TimeToStr(TimeCurrent(),TIME_MINUTES),magic,0,Red); 
      n--;
    }     
  }
//==================================================
  for (i=1;i<=10;i++)
  {
    
    if (i==1) {sizelot=lots;Step_tmp=Step*2;} else {sizelot=sizelot+lots;Step_tmp=Step_tmp+Step*2;}
    n=3;
    Ticket=-1;
    
    while (Ticket<0 && n>0)
    {
      Ticket=OrderSend(Symbol(),OP_BUYLIMIT,sizelot,NormalizeDouble(Bid-Step_tmp*pp,Digits),3,0,0,"buy RS :"+TimeToStr(TimeCurrent(),TIME_MINUTES),magic,0,Blue);
      n--;
    }     
    
    n=3;
    Ticket=-1;
    
    while (Ticket<0 && n>0)
    {    
      Ticket=OrderSend(Symbol(),OP_SELLLIMIT,sizelot,NormalizeDouble(Ask+Step_tmp*pp,Digits),3,0,0,"sell RS :"+TimeToStr(TimeCurrent(),TIME_MINUTES),magic,0,Red); 
      n--;
    }     
  }
}
//
void close_reserved()
{
   //здесь удал€ютс€ все отложенные ордера, поставленные ранее ботом
  int total = OrdersTotal() - 1;   
  for (int i = total; i >= 0; i--) 
  { //--- —четчик открытых ордеров
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
    {
        if (OrderMagicNumber() == magic)
        {
            if (OrderType() == OP_BUYLIMIT) OrderDelete(OrderTicket());
            if (OrderType() == OP_BUYSTOP)  OrderDelete(OrderTicket());
            if (OrderType() == OP_SELLLIMIT)OrderDelete(OrderTicket());
            if (OrderType() == OP_SELLSTOP) OrderDelete(OrderTicket());           
        }    
    }    
  } 
}
//
double value_profit()
{
   double ld_0 = 0;
   int l_ord_total_8 = OrdersTotal();
   if (l_ord_total_8 > 0) 
   {
      for (int l_pos_12 = l_ord_total_8 - 1; l_pos_12 >= 0; l_pos_12--) 
      {
         if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES))
         {
          if (OrderMagicNumber() == magic)
          ld_0 += OrderProfit() + OrderSwap();
         } 
      }
   }
  return(ld_0);
}
//
void CloseAll()
{
  int total = OrdersTotal() - 1;   
  for (int i = total; i >= 0; i--) 
  { //--- —четчик открытых ордеров
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
    {
        if (OrderMagicNumber() == magic)
        {
            if (OrderType() == OP_SELL)
            OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 20, Yellow);
            else
            if (OrderType() == OP_BUY)
            OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 20, Yellow);
            
        }    
    }    
  }
}
void close_()
{
  CloseAll();
  close_reserved();
}
//
int start()
  {
   //close 2.2%
   if (OrdersTotal()>0)
   {
    double profit=0;
    if (value_profit()>0)
    profit=(value_profit()*100)/AccountBalance();//%  
    
    if (profit>=percent_profit) close_();//закрываем все и всЄ.
   }  
  
   if (OrdersTotal()==0)
   OpenGrid();//установка сетки


   
   return(0);
  }
//+------------------------------------------------------------------+