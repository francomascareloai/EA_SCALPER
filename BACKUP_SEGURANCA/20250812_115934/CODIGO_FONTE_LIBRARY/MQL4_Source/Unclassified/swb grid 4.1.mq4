//+------------------------------------------------------------------+
//|                                                  swb grid 4 .mq4 |
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

#property copyright "totom sukopratomo"
#property link      "forexengine@gmail.com"
#define buy -2
#define sell 2
//---- input parameters
extern bool      use_daily_target=false;
extern double    daily_target=100;
extern bool      trade_in_fri=true;
extern int       magic=1;
extern double    start_lot=0.1;
extern double    range=25;
extern int       level=10;
extern bool      lot_multiplier=true;
extern double    multiplier=2.0;
extern double    increament=0.1;
extern bool      use_sl_and_tp=false;
extern double    sl=60;
extern double    tp=30;
extern double    tp_in_money=5.0;
extern bool      stealth_mode=true;
extern bool      use_bb=true;
extern int       bb_period=20;
extern int       bb_deviation=2;
extern int       bb_shift=0;
extern bool      use_stoch=true;
extern int       k=5;
extern int       d=3;
extern int       slowing=3;
extern int       price_field=0;
extern int       stoch_shift=0;
extern int       lo_level=30;
extern int       up_level=70;
extern bool      use_rsi=true;
extern int       rsi_period=12;
extern int       rsi_shift=0;
extern int       lower=30;
extern int       upper=70;
double pt;
double minlot;
double stoplevel;
int prec=0;
int a=0;
int ticket=0; 
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
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
                    if(lot_multiplier) ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Ask-(range*i)*pt,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,"",magic,0,Blue);
                    else               ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot+increament*i,prec)         ,Ask-(range*i)*pt,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,"",magic,0,Blue);
                }
             }
          }
          else
          {
             if(OrderSend(Symbol(),0,start_lot,Ask,3,0,0,"",magic,0,Blue)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier) ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Ask-(range*i)*pt,3,0,0,"",magic,0,Blue);
                    else               ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot+increament*i,prec)         ,Ask-(range*i)*pt,3,0,0,"",magic,0,Blue);
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
                    if(lot_multiplier) ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid+(range*i)*pt,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,"",magic,0,Red);
                    else               ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot+increament*i,prec)         ,Bid+(range*i)*pt,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,"",magic,0,Red);
                }
             }
          }
          else
          {
             if(OrderSend(Symbol(),1,start_lot,Bid,3,0,0,"",magic,0,Red)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier) ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid+(range*i)*pt,3,0,0,"",magic,0,Red);
                    else               ticket=OrderSend(Symbol(),3,NormalizeDouble(start_lot+increament*i,prec)         ,Bid+(range*i)*pt,3,0,0,"",magic,0,Red);
                }
             }
          }
        }
     } 
   }
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
     if(type==0 && Ask<=op-range*pt) 
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
     if(type==1 && Bid>=op+range*pt) 
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
  double upBB=iBands(Symbol(),0,bb_period,bb_deviation,0,PRICE_CLOSE,MODE_UPPER,bb_shift);
  double loBB=iBands(Symbol(),0,bb_period,bb_deviation,0,PRICE_CLOSE,MODE_LOWER,bb_shift);
  double stoch=iStochastic(Symbol(),0,k,d,slowing,MODE_SMA,price_field,MODE_SIGNAL,stoch_shift);
  double rsi=iRSI(Symbol(),0,rsi_period,PRICE_CLOSE,rsi_shift);
  if(use_bb && use_stoch && use_rsi)
  {
     if(High[bb_shift]>upBB && stoch>up_level && rsi>upper) return(sell);
     if(Low[bb_shift]<loBB && stoch<lo_level && rsi<lower)   return(buy);
  }
  if(use_bb && use_stoch && !use_rsi)
  {
     if(High[bb_shift]>upBB && stoch>up_level) return(sell);
     if(Low[bb_shift]<loBB && stoch<lo_level)   return(buy);
  }
  if(use_bb && !use_stoch && !use_rsi)
  {
     if(High[bb_shift]>upBB) return(sell);
     if(Low[bb_shift]<loBB)   return(buy);
  }
  if(!use_bb && use_stoch && use_rsi)
  {
     if(stoch>up_level && rsi>upper) return(sell);
     if(stoch<lo_level && rsi<lower)   return(buy);
  }
  if(!use_bb && use_stoch && !use_rsi)
  {
     if(stoch>up_level) return(sell);
     if(stoch<lo_level)  return(buy);
  }
  if(use_bb && !use_stoch && use_rsi)
  {
     if(High[bb_shift]>upBB && rsi>upper) return(sell);
     if(Low[bb_shift]<loBB && rsi<lower)   return(buy);
  }
  if(!use_bb && !use_stoch && use_rsi)
  {
     if(rsi>upper) return(sell);
     if(rsi<lower)  return(buy);
  }
  return(0);
}
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