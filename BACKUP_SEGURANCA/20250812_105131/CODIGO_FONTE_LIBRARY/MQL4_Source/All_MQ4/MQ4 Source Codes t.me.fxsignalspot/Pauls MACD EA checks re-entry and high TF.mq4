//+------------------------------------------------------------------+
//|                                               SWB with Pauls MACD|
//|                                                totom sukopratomo |
//|                                            forexengine@gmail.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+----- belum punya account fxopen? --------------------------------+
//+----- buka di http://fxind.com?agent=123621 ----------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+----- ingin bisa scalping dengan real tp 3 pips? -----------------+
//+----- ingin dapat bonus $30 dengan deposit awal $100? ------------+
//+----- buka account di http://instaforex.com/index.php?x=NQW ------+
//+------------------------------------------------------------------+

#property copyright ""
#property link      ""
#define buy -2
#define sell 2
//---- input parameters

extern double    tp_in_money=1.0;
extern double    range=40;
extern double    fastEMA=10;
extern double    slowEMA=20;
extern double    macdSMA=7;
extern double    UpperMACd_Filter=0.0010;
extern double    LowerMACd_Filter=-0.0010;
extern double    Higher_timeframe=1440;


extern double    start_lot=0.01;
extern bool      lot_multiplier=False;
extern double    multiplier=2.0;
extern double    increament=0.01;
extern bool      use_daily_target=false;
extern double    daily_target=100;
extern bool      EachTickMode = false;
extern bool      trade_in_fri=true;
extern int       magic=1;
extern int       level=10;

extern bool      use_sl_and_tp=false;
extern double    sl=60;
extern double    tp=30;

extern bool      stealth_mode=true;

double pt;
double minlot;
double stoplevel;
int prec=0;
int a=0;
int ticket=0; 



int BarCount;
int Current;
bool TickCheck = False;



//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
   
   BarCount = Bars;
   if (EachTickMode) Current = 0; else Current = 1;



   if(Digits==3 || Digits==5) pt=10*Point;
   else                          pt=Point;
   minlot   =   MarketInfo(Symbol(),MODE_MINLOT);
   stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(start_lot<minlot)      Print("lotsize is to small.");
   if(sl<stoplevel)   Print("stoploss is to tight.");
   if(tp<stoplevel) Print("takeprofit is to tight.");
   if(minlot==0.01) prec=2;
   if(minlot==0.1)  prec=1;
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
   if(use_daily_target && dailyprofit()>=daily_target)
   {
     Comment("\ndaily target achieved.");
     return(0);
   }
   if(!trade_in_fri && DayOfWeek()==5 && total()==0)
   {
     Comment("\nstop trading in Friday.");
     return(0);
   }
   if(total()==0 && a==0)
   {
     if(signal()==buy)
     {
        if(stealth_mode)
        {
          if(use_sl_and_tp) ticket=OrderSend(Symbol(),0,start_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue);
          else              ticket=OrderSend(Symbol(),0,start_lot,Ask,3,        0,        0,"",magic,0,Blue);
        }
        else
        {
          if(use_sl_and_tp) 
          {
             if(OrderSend(Symbol(),0,start_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue)>0)
             {
                for(int i=1; i<level; i++)
                {
                    if(lot_multiplier) ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Ask,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,"",magic,0,Blue);
                    else               ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot+increament*i,prec)         ,Ask,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,"",magic,0,Blue);
                }
             }
          }
          else
          {
             if(OrderSend(Symbol(),0,start_lot,Ask,3,0,0,"",magic,0,Blue)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier && signal()==buy) ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Ask,3,0,0,"",magic,0,Blue);
                    else  if (signal()==buy)            ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot+increament*i,prec)         ,Ask,3,0,0,"",magic,0,Blue);
                }
             }
          }
        }
     }
     if(signal()==sell)
     {
        if(stealth_mode)
        {
          if(use_sl_and_tp) ticket=OrderSend(Symbol(),1,start_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red);
          else              ticket=OrderSend(Symbol(),1,start_lot,Bid,3,        0,        0,"",magic,0,Red);
        }
        else
        {
          if(use_sl_and_tp) 
          {
             if(OrderSend(Symbol(),1,start_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier) ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,"",magic,0,Red);
                    else               ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot+increament*i,prec)         ,Bid,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,"",magic,0,Red);
                }
             }
          }
          else
          {
             if(OrderSend(Symbol(),1,start_lot,Bid,3,0,0,"",magic,0,Red)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier) ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid ,3,0,0,"",magic,0,Red);
                    else               ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot+increament*i,prec)         ,Bid ,3,0,0,"",magic,0,Red);
                }
             }
          }
        }
     } 
   }
   
   //// TOTAL >  0  ///////////////////////////////////////////////////////
   
  
   
    if(stealth_mode && total()>0 && total()<level)
    
     {
     int type; double op, lastlot; 
     for(i=0; i<OrdersTotal(); i++)
     {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         type=OrderType();
         op=OrderOpenPrice();
         lastlot=OrderLots();
     }
     
     if(signal2()==buy)
       
     if(type==0 && Ask<=op-range*pt) 
     
     if(type==0) 
     
     {
        if(use_sl_and_tp)
        {
           if(lot_multiplier) ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot*multiplier,prec),Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue);
           else               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot+increament,prec),Ask,3,Ask-sl*pt,Ask+tp*pt,"",magic,0,Blue);
        }
        else
        {
           if(lot_multiplier) ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot*multiplier,prec),Ask,3,0,0,"",magic,0,Blue);
           else               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot+increament,prec),Ask,3,0,0,"",magic,0,Blue);
        }
     }
     
  // 
  
     if(signal2()==sell)
     
     if(type==1 && Bid>=op+range*pt)
     
     if(type==1)
     {
        if(use_sl_and_tp)
        {
           if(lot_multiplier) ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot*multiplier,prec),Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red);
           else               ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot+increament,prec),Bid,3,Bid+sl*pt,Bid-tp*pt,"",magic,0,Red);
        }
        else
        {
           if(lot_multiplier) ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot*multiplier,prec),Bid,3,0,0,"",magic,0,Red);
           else               ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot+increament,prec),Bid,3,0,0,"",magic,0,Red);
        }
     }
   }
   if(use_sl_and_tp && total()>1)
   {
     double s_l, t_p;
     for(i=0; i<OrdersTotal(); i++)
     {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1) continue;
         type=OrderType();
         s_l=OrderStopLoss();
         t_p=OrderTakeProfit();
     }
     for(i=OrdersTotal()-1; i>=0; i--)
     {
       OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
       if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1) continue;
       if(OrderType()==type)
       {
          if(OrderStopLoss()!=s_l || OrderTakeProfit()!=t_p)
          {
             OrderModify(OrderTicket(),OrderOpenPrice(),s_l,t_p,0,CLR_NONE);
          }
       }
     }
   }
   double profit=0;
   for(i=0; i<OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1) continue;
      profit+=OrderProfit();
   }
   if(profit>=tp_in_money || a>0) 
   {
      closeall();
      closeall();
      closeall();
      a++;
      if(total()==0) a=0;
   }
   if(!stealth_mode && use_sl_and_tp && total()<level) closeall();
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
double dailyprofit()
{
  int day=Day(); double res=0;
  for(int i=0; i<OrdersHistoryTotal(); i++)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
      if(TimeDay(OrderOpenTime())==day) res+=OrderProfit();
  }
  return(res);
}
//+------------------------------------------------------------------+
int total()
{
  int total=0;
  for(int i=0; i<OrdersTotal(); i++)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
      total++;
  }
  return(total);
}
//+------------------------------------------------------------------+
int signal()
{

 double macB = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_OPEN, MODE_MAIN, 0);
 double macC = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA , PRICE_OPEN, MODE_MAIN, 0);


 double Buy1_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_OPEN, MODE_MAIN, Current + 0);
 double Buy1_2 = 0;
 double Buy2_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Buy2_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 2);
 double Buy3_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Buy3_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 1);
 double Buy4_1 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Buy4_2 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_SIGNAL, Current + 1);
 double Buy5_1 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Buy5_2 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_MAIN, Current + 1);

 double Sell1_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_OPEN, MODE_MAIN, Current + 0);
 double Sell1_2 = 0;
 double Sell2_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Sell2_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 2);
 double Sell3_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Sell3_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 1);
 double Sell4_1 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Sell4_2 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_SIGNAL, Current + 1);
 double Sell5_1 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Sell5_2 = iMACD(NULL, Higher_timeframe, fastEMA, slowEMA, macdSMA, PRICE_CLOSE, MODE_MAIN, Current + 1);

   if (Buy1_1 < Buy1_2 && Buy2_1 < Buy2_2 && Buy3_1 > Buy3_2 && macB < LowerMACd_Filter && Buy4_1 > Buy4_2 && Buy5_1 < Buy5_2 && macC < 0) return(buy);

   if (Sell1_1 > Sell1_2 && Sell2_1 > Sell2_2 && Sell3_1 < Sell3_2 && macB > UpperMACd_Filter && Sell4_1 < Sell4_2 && Sell5_1 > Sell5_2 && macC > 0) return(sell);
  
  
  }
  return(0);




//+------------------------------------------------------------------+
int signal2()
{

 double macB = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_OPEN, MODE_MAIN, 0);


 double Buy1_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_OPEN, MODE_MAIN, Current + 0);
 double Buy1_2 = 0;
 double Buy2_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Buy2_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 2);
 double Buy3_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Buy3_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 1);

 double Sell1_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_OPEN, MODE_MAIN, Current + 0);
 double Sell1_2 = 0;
 double Sell2_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 2);
 double Sell2_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 2);
 double Sell3_1 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_MAIN, Current + 1);
 double Sell3_2 = iMACD(NULL, 0, fastEMA, slowEMA, macdSMA , PRICE_CLOSE, MODE_SIGNAL, Current + 1);


   if (Buy1_1 < Buy1_2 && Buy2_1 < Buy2_2 && Buy3_1 > Buy3_2) return(buy);

   if (Sell1_1 > Sell1_2 && Sell2_1 > Sell2_2 && Sell3_1 < Sell3_2) return(sell);
  
  
  }
  return(0);



//+------------------------------------------------------------------+



void closeall()
{
  for(int i=OrdersTotal()-1; i>=0; i--)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
      if(OrderType()>1) OrderDelete(OrderTicket());
      else
      {
        if(OrderType()==0) OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
        else               OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
      }
  }
}