//+------------------------------------------------------------------+
//|                                                          aaa.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                                                  |
//| Modifiй par un6oitil (installation perceptron + SL + TP)         |                  
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
extern double StopLoss                 =0;
extern double TakeProfit               =0;
extern double step                     =25;
extern int    StepMode                 =0;
// Если StepMode = 0, то шаг между ордерами фиксированный и равен step
// Если StepMode = 1, то шаг постепенно увеличивается
extern double proffactor               =10;
extern double mult                     =1.5;
extern double lotsbuy                  =0.01;
extern double lotssell                 =0.01;  
extern double per_K                    =200;
extern double per_D                    =20;
extern double slow                     =20;
extern double zoneBUY                  =50;
extern double zoneSELL                 =50;
extern double Magicbuy                 =555;
extern double Magicsell                =556;
extern string	Parameters              = "StochasticPerceptron";
extern string	Parameters_Stochastic   = "Stochastic";
extern int       Kperiod               = 5;
extern int       Dperiod               = 3;	
extern int       slowing               = 3;
extern string	Parameters_Perceptron   = "Perceptron";
extern int       shag                  = 0;
extern int       x1                    = 0;
extern int       x2                    = 0;
extern int       x3                    = 0;
extern int       x4                    = 0;

// Internal settings
double  sl = 0;
double  tp = 0;
double openpricebuy,openpricesell,lotsbuy2,lotssell2,lastlotbuy,lastlotsell,tpb,tps,cnt,smbuy,smsell,lotstep,
ticketbuy,ticketsell,maxLot,free,balance,lotsell,lotbuy,dig,sig_buy,sig_sell,ask,bid;                           
                                int OrdersTotalMagicbuy(int Magicbuy)
 {
   int j=0;
   int r;
   for (r=0;r<OrdersTotal();r++)
   {
     if(OrderSelect(r,SELECT_BY_POS,MODE_TRADES))
     {
        if (OrderMagicNumber()==Magicbuy) j++;
     }
   }   
 return(j); 
 }

                                int OrdersTotalMagicsell(int Magicsell)
{
   int d=0;
   int n;
   for (n=0;n<OrdersTotal();n++)
   {
     if(OrderSelect(n,SELECT_BY_POS,MODE_TRADES))
     {
        if (OrderMagicNumber()==Magicsell) d++;
     }
   }    
 return(d);
  }     
                                      int orderclosebuy(int ticketbuy)
     {
string symbol = Symbol();
int cnt;
    for(cnt = OrdersTotal(); cnt >= 0; cnt--)
       {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);       
       if(OrderSymbol() == symbol && OrderMagicNumber()==Magicbuy) 
         {
         ticketbuy=OrderTicket();OrderSelect(ticketbuy, SELECT_BY_TICKET, MODE_TRADES);lotsbuy2=OrderLots() ;                         
         double bid = MarketInfo(symbol,MODE_BID); 
         RefreshRates();
         OrderClose(ticketbuy,lotsbuy2,bid,3,Magenta); 
         }
       }
       lotsbuy2=lotsbuy;return(0);
     } 
                                      int orderclosesell(int ticketsell)
     {
string symbol = Symbol();
int cnt;   
    for(cnt = OrdersTotal(); cnt >= 0; cnt--)
       {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);       
       if(OrderSymbol() == symbol && OrderMagicNumber()==Magicsell) 
         {
         ticketsell=OrderTicket();OrderSelect(ticketsell, SELECT_BY_TICKET, MODE_TRADES);lotssell2=OrderLots() ;                         
         double ask = MarketInfo(symbol,MODE_ASK); 
         RefreshRates();
         OrderClose(ticketsell,lotssell2,ask,3, Lime); 
         }
       }
       lotssell2=lotssell;return(0); 
     }
                                                 int start()
  {
//----
  double profitbuy=0;double profitsell=0;
  string symbol = OrderSymbol();
  double spread = MarketInfo(symbol,MODE_SPREAD);
  double minLot = MarketInfo(symbol,MODE_MINLOT);
  if (minLot==0.01){dig=2;maxLot=MarketInfo(symbol,MODE_MAXLOT);}
  if (minLot==0.1){dig=1;maxLot=((AccountBalance()/2)/1000);}
  if(OrdersTotalMagicbuy(Magicbuy)>0)
  {
  double smbuy;
  for (cnt=0;cnt<OrdersTotal();cnt++)
    {
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber () == Magicbuy) 
      {
      ticketbuy = OrderTicket();OrderSelect(ticketbuy,SELECT_BY_TICKET, MODE_TRADES);
      smbuy = smbuy+OrderLots();openpricebuy = OrderOpenPrice();lastlotbuy = OrderLots();
      }
    }
    {   
    if (smbuy+(NormalizeDouble((lastlotbuy*mult),dig))<maxLot)
      {     
      if(StepMode==0)
        {
        if(Ask<=openpricebuy-step*Point)
          {
          lotsbuy2=lastlotbuy*mult;
          if( StopLoss ==  0 ) sl = 0 ; else sl = Ask - (StopLoss * Point);
          if( TakeProfit ==  0 ) tp = 0 ; else tp = Ask + (TakeProfit * Point);
          RefreshRates();ticketbuy=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lotsbuy2,dig),Ask,3,sl,tp,"MartingailExpert",Magicbuy,0,Blue);
          }
        }
      if(StepMode==1)
        {
        if(Ask<=openpricebuy-(step+OrdersTotalMagicbuy(Magicbuy)+OrdersTotalMagicbuy(Magicbuy)-2)*Point)
          {
          lotsbuy2=lastlotbuy*mult;
          if( StopLoss ==  0 ) sl = 0 ; else sl = Ask - (StopLoss * Point);
          if( TakeProfit ==  0 ) tp = 0 ; else tp = Ask + (TakeProfit * Point);          
          RefreshRates();ticketbuy=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lotsbuy2,dig),Ask,3,sl,tp,"MartingailExpert",Magicbuy,0,Blue);
          } 
        }
      }
    }
  }
  if(OrdersTotalMagicsell(Magicsell)>0)
  {
  double smsell;
  for (cnt=0;cnt<OrdersTotal();cnt++)
    {
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber () == Magicsell)
      {
      ticketsell = OrderTicket();OrderSelect(ticketsell,SELECT_BY_TICKET, MODE_TRADES);
      smsell = smsell + OrderLots();openpricesell = OrderOpenPrice();lastlotsell = OrderLots();
      }     
    }
    {
    if (smsell+(NormalizeDouble((lastlotsell*mult),dig))<maxLot)
      {
      if(StepMode==0)
        {
        if(Bid>=openpricesell+step*Point)
          {
          lotssell2=lastlotsell*mult;
          if( StopLoss ==  0 ) sl = 0 ; else sl = Bid + (StopLoss * Point);
          if( TakeProfit ==  0 ) tp = 0 ; else tp = Bid - (TakeProfit * Point);
          RefreshRates();ticketsell=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lotssell2,dig),Bid,3,sl,tp,"MartingailExpert",Magicsell,0,Red);
          }
        }
      if(StepMode==1)
        {
        if(Bid>=openpricesell+(step+OrdersTotalMagicsell(Magicsell)+OrdersTotalMagicsell(Magicsell)-2)*Point)
          {
          lotssell2=lastlotsell*mult;
          if( StopLoss ==  0 ) sl = 0 ; else sl = Bid + (StopLoss * Point);
          if( TakeProfit ==  0 ) tp = 0 ; else tp = Bid - (TakeProfit * Point);          
          RefreshRates();ticketsell=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lotssell2,dig),Bid,3,sl,tp,"MartingailExpert",Magicsell,0,Red);
          }
        }
      }
    }  
  }
  if(OrdersTotalMagicbuy(Magicbuy)<1)
  { 
  if( StopLoss ==  0 ) sl = 0 ; else sl = Ask - (StopLoss * Point);
  if( TakeProfit ==  0 ) tp = 0 ; else tp = Ask + (TakeProfit * Point);          
  if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)>iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
  && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)>zoneBUY && perceptron()>0)    
  ticketbuy = OrderSend(Symbol(),OP_BUY,lotsbuy,Ask,3,sl,tp,"MartingailExpert",Magicbuy,0,Blue);
  }
  if(OrdersTotalMagicsell(Magicsell)<1)
  {  
  if( StopLoss ==  0 ) sl = 0 ; else sl = Bid + (StopLoss * Point);
  if( TakeProfit ==  0 ) tp = 0 ; else tp = Bid - (TakeProfit * Point);          
  if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)<iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
  && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)<zoneSELL && perceptron()<0)
  ticketsell = OrderSend(Symbol(),OP_SELL,lotssell,Bid,3,sl,tp,"MartingailExpert",Magicsell,0,Red);
  }
  for (cnt=0;cnt<OrdersTotal();cnt++)
  {
  OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
  if (OrderSymbol()==Symbol() && OrderMagicNumber () == Magicbuy)
    {
    ticketbuy = OrderTicket();OrderSelect(ticketbuy,SELECT_BY_TICKET, MODE_TRADES);profitbuy = profitbuy+OrderProfit() ;
    openpricebuy = OrderOpenPrice();
    }
  }  
  tpb = (OrdersTotalMagicbuy(Magicbuy)*proffactor*Point)+openpricebuy;
  double bid = MarketInfo(Symbol(),MODE_BID);
  if (profitbuy>0)
  {
  if (Bid>=tpb) orderclosebuy(ticketbuy);
  }
  for (cnt=0;cnt<OrdersTotal();cnt++)
  {   
  OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
  if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magicsell)
    {
    ticketsell = OrderTicket();OrderSelect(ticketsell,SELECT_BY_TICKET, MODE_TRADES);profitsell = profitsell+OrderProfit();
    openpricesell = OrderOpenPrice(); 
    }
  }
  tps = openpricesell-(OrdersTotalMagicsell(Magicsell)*proffactor*Point);
  double ask = MarketInfo(Symbol(),MODE_ASK);    
  if (profitsell>0)
  {
  if (Ask<=tps)orderclosesell(ticketsell);    
  }
  free = AccountFreeMargin();balance = AccountBalance();    
  for (cnt=0;cnt< OrdersTotal();cnt++)
  {   
  OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
  if (OrderSymbol()==Symbol() && OrderMagicNumber () == Magicbuy)  ticketbuy = OrderTicket();
  if (OrderSymbol()==Symbol() && OrderMagicNumber () == Magicsell) ticketsell = OrderTicket();
  }
  if (OrdersTotalMagicbuy(Magicbuy)==0)
  {
  profitbuy=0;ticketbuy=0;tpb=0;
  }
  if (OrdersTotalMagicsell(Magicsell)==0)
  {
  profitsell=0;ticketsell=0;tps=0;
  }
  Comment("FreeMargin = ",NormalizeDouble(free,0),"  Balance = ",NormalizeDouble(balance,0),"  maxLot = ",NormalizeDouble(maxLot,dig),"\n",
  "Totalbuy = ",OrdersTotalMagicbuy(Magicbuy),"  Lot = ",smbuy,"  Totalsell = ",OrdersTotalMagicsell(Magicsell),"  Lot = ",smsell,"\n",
  "---------------------------------------------------------------","\n","Profitbuy = ",profitbuy,"\n",
  "Profitsell = ",profitsell);
//----
   for(int ii=0; ii<2; ii+=2)
     {
      ObjectDelete("rect"+ii);
      ObjectCreate("rect"+ii,OBJ_HLINE, 0, 0,tps);
      ObjectSet("rect"+ii, OBJPROP_COLOR, Red);
      ObjectSet("rect"+ii, OBJPROP_WIDTH, 1);
      ObjectSet("rect"+ii, OBJPROP_RAY, False);
      }    
   for(int rr=0; rr<2; rr+=2)
      {
      ObjectDelete("rect1"+rr);
      ObjectCreate("rect1"+rr,OBJ_HLINE, 0, 0,tpb);      
      ObjectSet("rect1"+rr, OBJPROP_COLOR, Blue);
      ObjectSet("rect1"+rr, OBJPROP_WIDTH, 1);
      ObjectSet("rect1"+rr, OBJPROP_RAY, False);     
     }
   return(0);
}  
//+------------------------------------------------------------------+

double perceptron()
  
   {
    int i=0;     
         double w1 = x1 - 100;
         double w2 = x2 - 100;
         double w3 = x3 - 100;
         double w4 = x4 - 100;

         double a1 = iStochastic(NULL,0,Kperiod	,Dperiod	,slowing,MODE_SMA,0,MODE_MAIN,i)-50;
         double a2 = iStochastic(NULL,0,Kperiod ,Dperiod	,slowing,MODE_SMA,0,MODE_MAIN,i+shag)-50; 
         double a3 = iStochastic(NULL,0,Kperiod ,Dperiod	,slowing,MODE_SMA,0,MODE_MAIN,i+shag*2)-50; 
         double a4 = iStochastic(NULL,0,Kperiod ,Dperiod	,slowing,MODE_SMA,0,MODE_MAIN,i+shag*3)-50;
     
         return (w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
    }
    
//+------------------------------------------------------------------+

