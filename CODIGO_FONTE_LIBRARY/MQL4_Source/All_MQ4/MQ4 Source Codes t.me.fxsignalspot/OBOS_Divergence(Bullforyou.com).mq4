//+------------------------------------------------------------------+
//|                                       Magix Trigger on Grid .mq4 |
//|                                                totom sukopratomo |
//|                                                    Variant OF SWB|
//+------------------------------------------------------------------+


//This is a remake of the original SWB by Totom Sukopratomo.

//There is always risk in trading market through the use of automated 
//traders, so use should always be monitored for account safety and 
//use only if you have funds that you can afford to lose.

//This is a trade strategy automated trader and was meant for others
//to use the same selected indicators used in this EA for educational
//puroses.  Use as a live trading robot may prove to be profitable
//but may also drain your account.

//Have fun with this tool, and Happy Pips!

//Magix



#define buy -2
#define sell 2
//---- input parameters
bool      use_daily_target=false;
double    daily_target=100;
bool      EachTickMode = True;
bool      trade_in_fri=true;
extern int       magic=248;
extern string    Comments = "OBOS Divergence";

extern string     Trade_Lot_Settings = "Money Management";
extern double     start_lot=0.01;
extern double     range=25;
extern int        level=5;
bool              lot_multiplier=false;
double            multiplier=2.0;
extern double     increment=0.01;
bool              use_sl_and_tp=false;
double            sl=60;
double            tp=30;
extern double     tp_in_money=1.0;
bool              stealth_mode=true;
extern string    Envelope = "Set The Channel";
extern int        EnvelopePeriod    =36;    //moving average length
extern int        EnvMaMethod       =0;      //0=sma,1=ema,2=smma,3=lwma.
extern int        Shift           =0;      //shift relative to current bar indicator data is posted
extern double     EnvelopeDeviation =0.05;    //envelope width
extern string    Moving_Average = "Set The Breakout";
extern int       MAPeriod=16;//
extern int       MAMethod=0;//
extern int       MAShift=0;
int              MAPrice=0;
extern string    Derivative_Oscillator_Settings= "Set The Trigger";
extern double     RSIDer=14;

extern bool      hedge=false;
extern int       hedge_start=1;
extern double    h_lot_factor=0.5;
extern double    h_tp_factor=1.0;
extern double    lot_multiplier_2=1.5;
extern int       lot_multi_2_level=3;

double pt;
double minlot;
double stoplevel;
int prec=0;
int a=0;
int ticket=0;
//----
double s_lot,s_lot2,hf,h_tp,lm_1,lm_2,lm_2_level,O_equity;
bool Close_All; // Part of Close_All Inhibit ...
int O_rst=0;
string opt="NULL";


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
   s_lot=start_lot; if(hedge==false){ hedge_start=0; } hf=h_lot_factor; h_tp=h_tp_factor*range*pt;
   lm_1=multiplier; lm_2=lot_multiplier_2; lm_2_level=lot_multi_2_level; O_equity=AccountEquity();
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
//+------------------------------------------------------------------+
   int T_cnt=0,b_cnt=0,s_cnt=0,h_cnt,O_cnt=0,OOT,FOOT; // Close_All Inhibit ...
   bool s_hedge=false,b_hedge=false; string FOT="0";
   for(int cnt=0; cnt<=OrdersTotal(); cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()<2)
      {
         T_cnt+=1; OOT=OrderOpenTime();
         if(OrderType()==0){ b_cnt+=1; } if(OrderType()==1){ s_cnt+=1; }
         if(T_cnt==1 || OOT<FOOT){ FOOT=OOT; FOT="B"; if(OrderType()==1){ FOT="S"; } }
      }
   }
//----
   if(FOT=="B")
   {
      O_cnt=b_cnt; h_cnt=s_cnt; opt="BUY";  if(hedge==true && b_cnt>=hedge_start-1){ s_hedge=true; }
   }
   if(FOT=="S")
   {
      O_cnt=s_cnt; h_cnt=b_cnt; opt="SELL"; if(hedge==true && s_cnt>=hedge_start-1){ b_hedge=true; }
   }
//----
   multiplier=lm_1; if(lm_2>0 && O_cnt>=lm_2_level-1){ multiplier=lm_2; }
//----
   if(T_cnt==0){ Close_All=false; }
//+------------------------------------------------------------------+
   if(O_cnt==0 && a==0 && h_cnt==0) // substituted total() with O_cnt ...
   {
     if(signal()==buy /*&& Close_All==false*/) // added close_all and hedge
     {
        if(stealth_mode)
        {
          if(use_sl_and_tp){ s_lot=start_lot; ticket=OrderSend(Symbol(),0,s_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,Comments,magic,0,Blue); }
          else             { s_lot=start_lot; ticket=OrderSend(Symbol(),0,s_lot,Ask,3,        0,        0,Comments,magic,0,Blue); }
        }
        else
        {
          if(use_sl_and_tp) 
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),0,start_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,Comments,magic,0,Blue)>0)
             {
                for(int i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,Comments,magic,0,Blue); }
                    else              { s_lot=NormalizeDouble(start_lot+increment*i,prec);          ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,Comments,magic,0,Blue); }
                }
             }
          }
          else
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),0,start_lot,Ask,3,0,0,Comments,magic,0,Blue)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,0,0,Comments,magic,0,Blue); }
                    else              { s_lot=NormalizeDouble(start_lot+increment*i,prec);          ticket=OrderSend(Symbol(),2,s_lot,Ask-(range*i)*pt,3,0,0,Comments,magic,0,Blue); }
                }
             }
          }
        }
        if(s_hedge==true){ ticket=OrderSend(Symbol(),1,s_lot*hf,Bid,3,0,Bid-h_tp,"Hedge",magic,0,Red); }
     }
//+------------------------------------------------------------------+
     if(signal()==sell /*&& Close_All==false*/) // added close_all and hedge
     {
        if(stealth_mode)
        {
          if(use_sl_and_tp){ s_lot=start_lot; ticket=OrderSend(Symbol(),1,s_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,Comments,magic,0,Red); }
          else             { s_lot=start_lot; ticket=OrderSend(Symbol(),1,s_lot,Bid,3,        0,        0,Comments,magic,0,Red); }
        }
        else
        {
          if(use_sl_and_tp) 
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),1,start_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,Comments,magic,0,Red)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,Comments,magic,0,Red); }
                    else              { s_lot=NormalizeDouble(start_lot+increment*i,prec);          ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,Comments,magic,0,Red); }
                }
             }
          }
          else
          {
             s_lot=start_lot;
             if(OrderSend(Symbol(),1,start_lot,Bid,3,0,0,Comments,magic,0,Red)>0)
             {
                for(i=1; i<level; i++)
                {
                    if(lot_multiplier){ s_lot=NormalizeDouble(start_lot*MathPow(multiplier,i),prec); ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,0,0,Comments,magic,0,Red); }
                    else              { s_lot=NormalizeDouble(start_lot+increment*i,prec);          ticket=OrderSend(Symbol(),3,s_lot,Bid+(range*i)*pt,3,0,0,Comments,magic,0,Red); }
                }
             }
          }
        }
        if(b_hedge==true){ ticket=OrderSend(Symbol(),0,s_lot*hf,Ask,3,0,Ask+h_tp,"Hedge",magic,0,Blue); }
     } 
   }
//+------------------------------------------------------------------+
   if(stealth_mode && O_cnt>0 && O_cnt<level && h_cnt==0) // substituted total() with O_cnt ...
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
     if(type==0  && signal()==buy && Ask<=op-range*pt && Close_All==false) // added close_all and hedge
     {
        if(use_sl_and_tp)
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,Comments,magic,0,Blue); }
           else              { s_lot=NormalizeDouble(lastlot+increment,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,Comments,magic,0,Blue); }
        }
        else
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,0,0,Comments,magic,0,Blue); }
           else              { s_lot=NormalizeDouble(lastlot+increment,prec); ticket=OrderSend(Symbol(),0,s_lot,Ask,3,0,0,Comments,magic,0,Blue); }
        }
        if(s_hedge==true){ ticket=OrderSend(Symbol(),1,s_lot*hf,Bid,3,0,Bid-h_tp,"Hedge",magic,0,Red); }
     }
     if(type==1 && signal()==sell && Bid>=op+range*pt && Close_All==false) // added close_all and hedge
     {
        if(use_sl_and_tp)
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,Comments,magic,0,Red); }
           else              { s_lot=NormalizeDouble(lastlot+increment,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,Comments,magic,0,Red); }
        }
        else
        {
           if(lot_multiplier){ s_lot=NormalizeDouble(lastlot*multiplier,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,0,0,Comments,magic,0,Red); }
           else              { s_lot=NormalizeDouble(lastlot+increment,prec); ticket=OrderSend(Symbol(),1,s_lot,Bid,3,0,0,Comments,magic,0,Red); }
        }
        if(b_hedge==true){ ticket=OrderSend(Symbol(),0,s_lot*hf,Ask,3,0,Ask+h_tp,"Hedge",magic,0,Blue); }
     }
   }
//+------------------------------------------------------------------+
   double st_lots=0,h_lots,t_lots,n_lots; cnt=0; // Close_All Inhibit ...
   for(cnt=0; cnt<=OrdersTotal(); cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()<2)
      {
         if((FOT=="B" && OrderType()==1) || (FOT=="S" && OrderType()==0)){ h_lots+=OrderLots(); }
         t_lots+=OrderLots(); st_lots=t_lots-h_lots; n_lots=st_lots-h_lots;
      }
   }
//+------------------------------------------------------------------+
   double AE=AccountEquity(),a_profit=AE-O_equity,b_profit; if(a_profit>b_profit){ b_profit=a_profit; }
   Comment("OPT = ",opt,"  /  LEVEL = ",O_cnt,"  /  Hedge Start = ",hedge_start,"  |  Standard Lots = ",DoubleToStr(st_lots,2),
   "  /  Hedge Lots = ",DoubleToStr(h_lots,2),"  /  Net Lots = ",DoubleToStr(n_lots,2),"\n","Account Equity = ",DoubleToStr(AE,2),"  /  Account Profit = ",DoubleToStr(a_profit,2));
//+------------------------------------------------------------------+
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
   double bline=iEnvelopes(NULL,0,EnvelopePeriod,EnvMaMethod,0,PRICE_CLOSE,EnvelopeDeviation,MODE_UPPER,Shift+2);
   double bline1=iEnvelopes(NULL,0,EnvelopePeriod,EnvMaMethod,0,PRICE_CLOSE,EnvelopeDeviation,MODE_UPPER,Shift+1);
   double sline=iEnvelopes(NULL,0,EnvelopePeriod,EnvMaMethod,0,PRICE_CLOSE,EnvelopeDeviation,MODE_LOWER,Shift+2);
   double sline1=iEnvelopes(NULL,0,EnvelopePeriod,EnvMaMethod,0,PRICE_CLOSE,EnvelopeDeviation,MODE_LOWER,Shift+1);
      double MAP=iMA(Symbol(),0,MAPeriod,0,MAMethod,MAPrice,MAShift+2);
         double DO1=iCustom(Symbol(),0,"Derivative_Oscillator",RSIDer,0,1);
         double DO2=iCustom(Symbol(),0,"Derivative_Oscillator",RSIDer,0,2);
  
            if (MAP<sline&&DO2<0&&DO1>DO2) return (buy);
            if (MAP>bline&&DO2>0&&DO1<DO2) return (sell);

  
  return(0);
}
//+------------------------------------------------------------------+
void closeall()
{
  for(int i=OrdersTotal()-1; i>=0; i--)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue; Close_All=true; // Close_All Inhibit ...
      if(OrderType()>1) OrderDelete(OrderTicket());
      else
      {
        if(OrderType()==0) OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
        else               OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
      }
  }
} 