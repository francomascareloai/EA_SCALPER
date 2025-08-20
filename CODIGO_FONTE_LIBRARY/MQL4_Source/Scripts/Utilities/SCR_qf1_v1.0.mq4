//+------------------------------------------------------------------+
//|                                                           õ1.mq4 |
//|                                                            ÅÂÃÅÍ |
//|                                                  z_e_e_d@mail.ru |
//+------------------------------------------------------------------+
#property copyright "ÅÂÃÅÍ"
#property link      "z_e_e_d@mail.ru"
extern double my_profit=27.00;
extern double order_profit=150.00;

  int max_buy,max_sell,buy,sell,pos,tiket1,tiket2;
  double balans,my_lot;
  bool work,go;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
  balans=0;
  work=true;
  go=false;
  tiket1=0;
  tiket2=0;
  my_lot=0.1;
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
int total=OrdersTotal(); 
//----------- 
 if(balans==0)
  balans=AccountBalance();
//------------------------------------------------------------------- 
  double profit=AccountEquity()- balans;
  if(my_lot==0)
  my_lot=0.1;
//----------- 
if(total!=0) 
{
if (OrderSelect(tiket1, SELECT_BY_TICKET, MODE_TRADES) == true)
         {
         if (OrderCloseTime()!=0)
             go=true; 
                      
             }
       else
           Print("Îøèáêà ", GetLastError(), " ïðè âûáîðå îðäåðà tiket ", tiket1);
           
if (OrderSelect(tiket2, SELECT_BY_TICKET, MODE_TRADES) == true)
         {
         if (OrderCloseTime()!=0)
             go=true;          
             }
       else
           Print("Îøèáêà ", GetLastError(), " ïðè âûáîðå îðäåðà tiket ", tiket2);           
           
}             
//-----------
   if(work==true && (total==0 ||go==true))
   {
   tiket1 = OrderSend(Symbol(),OP_BUY,my_lot,Ask,3,0,Ask+order_profit*Point,NULL,0,0,CLR_NONE);
   if(tiket1>0)
   Print("tiket1=",tiket1);
   else
   {
   Print("tiket1<0-ÏÐÎÈÇÎØËÀ ÎØÈÁÊÀ-",GetLastError());
   return(0);
   }
//-----------   
   tiket2 = OrderSend(Symbol(),OP_SELL,my_lot,Bid,3,0,Bid-order_profit*Point,NULL,0,0,CLR_NONE);
   if(tiket2>0)
   {
   Print("tiket2=",tiket2);
   go=false;
   my_lot=my_lot-0.01;
   }
   else
   {
   Print("tiket2<0-ÏÐÎÈÇÎØËÀ ÎØÈÁÊÀ-",GetLastError());
   return(0);
   }
   }
//-----------------------------------------------------
if(profit>=my_profit||GetLastError()==148)
work=false;
//-----------------------------------------------------  
   if(work==false)
     { 
    for ( pos = 0; pos<total; pos++ )
     {
       if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == true)
         {
         double price;
         if (OrderType()==OP_SELL) 
             price = MarketInfo(OrderSymbol(), MODE_ASK);
         else
             price = MarketInfo(OrderSymbol(), MODE_BID);     
         if (OrderClose(OrderTicket(), OrderLots(), price, 3)==true)
          Print("çàêðûòà ïîçèöèÿ", OrderTicket());
          else
          Print("Îøèáêà ", GetLastError()," ïðè çàêðûòèè ïîçèöèè ", OrderTicket());         
          }
       else
           Print("Îøèáêà ", GetLastError(), " ïðè âûáîðå îðäåðà íîìåð ", pos);
           }
  balans=0;
  tiket1=0;
  tiket2=0; 
  go=false;
  my_lot=0.1;
   }
   if(work==false && total==0)
   work=true;
   Print(" profit=",profit);
   Print("my_lot=",my_lot);
//----
   return(0);
  }
//+------------------------------------------------------------------+