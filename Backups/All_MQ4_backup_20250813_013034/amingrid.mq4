//+------------------------------------------------------------------+
//|                                                   wpr.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://t.me/amin1softco"
#property version   "1.00"
#property strict

extern int    Magic=123456;     

extern double Lot         =0.01;
extern double LotFor1000 = 0; 
extern int    bdiff = 30; 
extern int    sdiff = 30; 
extern int    maxopenorders = 1000; 
extern int    maxlevel = 1000; 
extern int    dollar = 10; 
extern int    lossdollar = 30; 
extern string Cmt = "grid";
extern bool   CloseOnExpiration = true;
extern int    expirationDays = 7;

extern bool openbuy=true;
extern bool opensell = true;
extern double multiplier = 2.0;
double MinLot, MaxLot, LotDigits, cA = 0; ;
 int    total;
 double prec= 0.0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
double Lot()
 {
  if (LotFor1000 != 0) Lot = AccountFreeMargin() / 1000.0 * LotFor1000;
  return(NormalizeDouble(MathMin(MathMax(MinLot, Lot), MaxLot), LotDigits));
 }

int init(){

    
  LotDigits = MathLog(MarketInfo(_Symbol, MODE_LOTSTEP)) / MathLog(0.1);
  MinLot = MarketInfo(_Symbol, MODE_MINLOT); MaxLot = MarketInfo(_Symbol, MODE_MAXLOT);
      return(INIT_SUCCEEDED);
}

double lastsellprice =0.0;
double lastbuyprice =0.0;
int countbuy=0;
int countsell=0;



  int Count(int type){
  int counter =0;
   for(int order = 0; order < OrdersTotal(); order++)
   {
      //bool result = OrderSelect(order,SELECT_BY_POS);
      if(!OrderSelect(order,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol() == Symbol()  && OrderMagicNumber() == Magic && OrderType()==type)
      counter++; 
   }
   return counter;
  }

 double ordersprofit(int type){
  double counter =0;
   for(int order = 0; order < OrdersTotal(); order++)
   {
      //bool result = OrderSelect(order,SELECT_BY_POS);
      if(!OrderSelect(order,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol() == Symbol()  && OrderMagicNumber() == Magic && OrderType()==type){
      counter+=OrderProfit()+OrderCommission()+OrderSwap(); 
      }
   }
   return counter;
  }
  
    void Closeorders(int type){
  int counter =0;
     for (int i = OrdersTotal(); i >= 0; i--) {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))continue;
      if (OrderSymbol() == Symbol()  && OrderMagicNumber() == Magic && OrderType() == type) 
        OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
    
   
   }
  }
void OnTick(void)
  {
  //if (High[0]-Low[0]>iATR(NULL,0,30,0)*diff)return;
 
  
   int    cnt,ticket,total;
   double sl=0.0;
//---
// initial data checks
// it is important to make sure that the expert works with a normal
// chart and the user did not make any mistakes setting external 
// variables (Lots, StopLoss, TakeProfit, 
// TrailingStop) in our case, we check TakeProfit
// on a chart of less than 100 bars
//---
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
 if( CloseOnExpiration == true)
    for (int i = OrdersTotal(); i >= 0; i--) {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))continue;
      if (OrderSymbol() == Symbol()  && OrderMagicNumber() == Magic && TimeCurrent()-OrderOpenTime() > expirationDays *24 *3600) {
      if (OrderType() == OP_BUY || OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5, CLR_NONE);
      if (OrderType() != OP_BUY && OrderType() != OP_SELL) OrderDelete(OrderTicket());
    
   }
   }
   
   

   
   if (ordersprofit(OP_BUY)+ordersprofit(OP_SELL)>dollar){
   Closeorders(OP_BUY);
   Closeorders(OP_SELL);
   }
      if(ordersprofit(OP_BUY)>dollar)Closeorders(OP_BUY);
   if(ordersprofit(OP_SELL)>dollar)Closeorders(OP_SELL);
  // if(ordersprofit(OP_BUY)<-lossdollar)Closeorders(OP_BUY);
  // if(ordersprofit(OP_SELL)<-lossdollar)Closeorders(OP_SELL);
 //  if(!IsTesting()){ Print("I am for testing now!"); return ;}
//--- to simplify the coding and speed up access data are put into internal variables

   ;

   total=OrdersTotal();
  

   
   
      //--- no opened orders identified
      if(AccountFreeMargin()<(1000*Lot()))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
        
      //--- check for long position (BUY) possibility
      if(openbuy)
      if(Count(OP_BUY)<maxopenorders && (Count(OP_BUY)==0||Ask-lastbuyprice>bdiff*Point))
        {
        double lotb=Lot();
        if(Count(OP_BUY)!=0)lotb*=Count(OP_BUY)*multiplier;
        if (Count(OP_BUY)>=maxlevel)lotb =Lot()*maxlevel;
    lastbuyprice=Ask;
         ticket=OrderSend(Symbol(),OP_BUY,lotb,Ask,3,0,0,Cmt,Magic,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening BUY order : ",GetLastError());
        // return;
        }
      //--- check for short p*?osition (SELL) possibility

  if(opensell)
      if( Count(OP_SELL)<maxopenorders&& (Count(OP_SELL)==0||Bid-lastsellprice>sdiff*Point))
        {
        double lots=Lot();
        
        if(Count(OP_SELL)!=0)lots*=Count(OP_SELL)*multiplier;
        if (Count(OP_SELL)>=maxlevel)lots =Lot()*maxlevel;
   lastsellprice=Bid;
         ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,3,0,0,Cmt,Magic,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("SELL order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening SELL order : ",GetLastError());
        }
      //--- exit from the "no opened orders" block

//---
  }
  
