//+------------------------------------------------------------------+
//|                                    swb grid 4.1_revised_05_D.mq4 |
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
extern string  separator_01="----  General  Settings  ----";
extern bool      use_daily_target=false;
extern double    daily_target=100;
extern bool      trade_in_fri=true;
extern int       magic=22;
extern double    start_lot=0.1;
extern double    range=25;
extern bool      rge_multiplier=false;
extern double    r_multiplier=1.5;
extern int       level=10;
extern string  separator_02="----  Lot & TP  Settings  ----";
extern bool      lot_multiplier=true;
extern double    l_multiplier=2.0;
extern double    increment=0.1;
extern bool      power_lots=true;
extern bool      tp_by_level=true;
extern double    tp_1=25;
extern double    tp_2=0;
extern bool      use_sl_and_tp=false;
extern double    sl_std=60;
extern double    tp_std=30;
extern double    tp_in_money=5.0;
extern bool      stealth_mode=true;
extern string  separator_03="----  Hedge  Settings  ----";
extern bool      hedge=true;
extern int       h_level=3;
extern int       h_top_level=100;
extern double    h_tp=80;
extern double    h_sl=25;
extern double    b_even_set=10;
extern double    h_offset=20;
extern double    h_factor=1.05;
extern bool      level_limit=false;
extern string  separator_04="----  Indicator  Settings  ----";
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
extern string  separator_00="----  RSI - Foward  Trend   ----";
extern bool      forward_trend=false;
extern int       rsi_period_1=30;
extern int       rsi_shift_1=0;
extern int       lower_min=35;
extern int       lower_max=33;
extern int       upper_min=65;
extern int       upper_max=67;
extern bool      use_velocity=true;
extern int       fv_period=10;
extern int       fv_offset=20;
extern string  separator_05="----  RSI - Hedge  Entry   ----";
extern bool      h_rsi_entry=true;
extern int       rsi_period_2=14;
extern int       rsi_shift_2=0;
extern int       lower_2=25;
extern int       upper_2=75;
extern bool      h_velocity=false;
extern bool      use_h_rsi=false;
extern int       vel_period=13;
extern int       vel_offset=50;
extern string  separator_06="----  RSI - Hedge  Exit   ----";
extern bool      h_rsi_exit=true;
extern int       rsi_period_3=14;
extern int       rsi_shift_3=0;
extern int       lower_3=50;
extern int       upper_3=50;
extern double    sl_threshold=0;
extern string  separator_07="----  RSI - TP  Override   ----";
extern bool      tp_override=true;
extern int       rsi_period_4=14;
extern int       rsi_shift_4=0;
extern int       lower_4=25;
extern int       upper_4=75;
extern string  separator_08="----  Additional  ----";
extern string  separator_09="----  Trading  Sessions  ----";
extern bool      use_trading_sessions=false;
extern bool      asian_session=true;  //  0:00 -  8:00 GMT
extern bool      euro_session=true;   //  6:00 - 16:00 GMT
extern bool      ny_session=true;     // 12:00 - 21:00 GMT
extern int       gmt_shift=1;
extern bool      daylight_savings=false;
extern string  separator_10="----  Asian  Daily  /  GMT  ----";
extern bool      asian_daily=true;
extern int       sun_asian_open=0, sun_asian_close=8;
extern int       mon_asian_open=0, mon_asian_close=8;
extern int       tue_asian_open=0, tue_asian_close=8;
extern int       wed_asian_open=0, wed_asian_close=8;
extern int       thu_asian_open=0, thu_asian_close=8;
extern int       fri_asian_open=0, fri_asian_close=8;
extern string  separator_11="----  European  Daily  /  GMT  ----";
extern bool      euro_daily=true;
extern int       sun_euro_open=6,  sun_euro_close=16;
extern int       mon_euro_open=6,  mon_euro_close=16;
extern int       tue_euro_open=6,  tue_euro_close=16;
extern int       wed_euro_open=6,  wed_euro_close=16;
extern int       thu_euro_open=6,  thu_euro_close=16;
extern int       fri_euro_open=6,  fri_euro_close=16;
extern string  separator_12="----  New  York  Daily  /  GMT  ----";
extern bool      ny_daily=true;
extern int       sun_ny_open=12,   sun_ny_close=21;
extern int       mon_ny_open=12,   mon_ny_close=21;
extern int       tue_ny_open=12,   tue_ny_close=21;
extern int       wed_ny_open=12,   wed_ny_close=21;
extern int       thu_ny_open=12,   thu_ny_close=21;
extern int       fri_ny_open=12,   fri_ny_close=21;

bool t_day[5];
datetime mtd_time;

double pt;
double minlot;
double stoplevel;
double std=0.1;
double rge;
double balance;
double bal_2=0;
double b_hedge;
double s_hedge;
double p_lot;
double pl_bal=0;
double st_lot;
double pl_factor;
double t_profit=0;
int prec=0;
int b_cnt;
int s_cnt;
int h_cnt;
int m;
int end_cycle;
bool e_cycle_set;
bool closeall;
bool h_b_e;
datetime get_time;
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
   if(sl_std<stoplevel)   Print("stoploss is to tight.");
   if(tp_std<stoplevel) Print("takeprofit is to tight.");
   if(minlot==0.01){ prec=2; std=10.0; }
   if(minlot==0.1) { prec=1; std=1.0;  }
//----
   range*=pt;
   rge=range;
   sl_std*=pt;
   tp_std*=pt;
   tp_1*=pt;
   tp_2*=pt;
   h_tp*=pt;
   h_sl*=pt;
   h_offset*=pt;
   b_even_set*=pt;
   sl_threshold*=pt;
   if(h_velocity) h_level=1;
   if(hedge && level_limit) level=h_level;
//----
   if(use_sl_and_tp) stealth_mode=false;
//----
   if(!GlobalVariableGet("bal_2"+Symbol()+magic)) GlobalVariableSet("bal_2"+Symbol()+magic,0);
   if(GlobalVariableGet("bal_2"+Symbol()+magic)>0) bal_2=GlobalVariableGet("bal_2"+Symbol()+magic);
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
   if(use_daily_target && dailyprofit()>=daily_target)
   {
     Comment("\ndaily target achieved.");
     return(0);
   }
   if(!trade_in_fri && DayOfWeek()==5 && T()==0)
   {
     Comment("\nstop trading in Friday.");
     return(0);
   }
//+------------------------------------------------------------------+
//| start of ecTrage mod - ramble_32@yahoo.com                       |
//+------------------------------------------------------------------+
   h_cnt=0; b_cnt=0; s_cnt=0;  double LOOP, lot2, h2_lot;
   for(int i=0; i<OrdersTotal(); i++) // additional
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
//----
      if(OT2()=="H"){ h_cnt++; } else {
      if(cmd()<2) if(cmd()==0) b_cnt++; if(cmd()==1) s_cnt++; }
   }
   if(h_cnt==0) h_b_e=false;
//+------------------------------------------------------------------+
   double AE=AccountEquity();
   if(power_lots)
   {
      if(pl_bal==0){ pl_bal=AE; st_lot=start_lot; }
      if(T()==0){ pl_factor=AE/pl_bal; st_lot=start_lot*pl_factor; }
   }
//+------------------------------------------------------------------+
   if(lot_multiplier) lot2=NormalizeDouble(st_lot*MathPow(l_multiplier,T()),prec);
   else               lot2=NormalizeDouble(st_lot+(increment*T()),          prec);
   if(rge_multiplier) rge=range*MathPow(r_multiplier,T());
//+------------------------------------------------------------------+
   int o_send=2; if(use_trading_sessions){ o_send=order_send(); } else {
   if(signal()==buy) o_send=0; if(signal()==sell) o_send=1; }
//----
   if(e_cycle_set) end_cycle++; if(end_cycle>1){ e_cycle_set=false; end_cycle=0; }
   if(T()==0){ closeall=false; get_time=TimeCurrent(); }
//----
   if(!closeall && end_cycle==0 && h_cnt==0) // additional
   {
      if(T()<level)
      {
         if(o_send==0 || (b_cnt>0 && Ask<=LOOP()-rge))                         // BUY
         {
            if(hedge && T()==0) s_hedge=Bid-rge;
            OrderSend(Symbol(),0,lot2,Ask,3,0,0,"L"+(b_cnt+1),magic,0,Blue);
         }
         if(o_send==1 || (s_cnt>0 && Bid>=LOOP()+rge))                         // SELL
         {
            if(hedge && T()==0) b_hedge=Ask+rge;
            OrderSend(Symbol(),1,lot2,Bid,3,0,0,"L"+(s_cnt+1),magic,0,Red);
         }
      }
//----
      if(hedge() && h_rsi_entry)                                               // HEDGE
      {
         if(h_velocity)
         {
            if(s_cnt>0 && Ask>=b_hedge && ((!use_h_rsi && h_velo()>vel_offset)
            || (use_h_rsi && h_entry()>upper_2)))
            OrderSend(Symbol(),0,h_lot(),Ask,3,0,0,"H"+(s_cnt+1),magic,0,Blue);
            //----
            if(b_cnt>0 && Bid<=s_hedge && ((!use_h_rsi && h_velo()<-vel_offset)
            || (use_h_rsi && h_entry()<lower_2)))
            OrderSend(Symbol(),1,h_lot(),Bid,3,0,0,"H"+(b_cnt+1),magic,0,Red);
         }
         if(!h_velocity)
         {
            if(s_cnt>0 && Ask>=LOOP() && Ask<=LOOP()+h_offset && h_entry()>upper_2)
            OrderSend(Symbol(),0,h_lot(), Ask,3,0,0,"H"+(s_cnt+1),magic,0,Blue);
            //----
            if(b_cnt>0 && Bid<=LOOP() && Bid>=LOOP()-h_offset && h_entry()<lower_2)
            OrderSend(Symbol(),1,h_lot(), Bid,3,0,0,"H"+(b_cnt+1),magic,0,Red);
         }
      }
   }
//+------------------------------------------------------------------+
   double OOP, OSL, OTP, sl_0=sl_std, tp_0=tp_std, h2_tp=h_tp;
   for(i=0; i<OrdersTotal(); i++) // additional
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || cmd()>1) continue;
      OOP=OrderOpenPrice();
      if(OT2()=="H")
      {
         if(cmd()==0)
         {
            if(tp_override && h_tp_over()>upper_4) h2_tp=0;
            OSL=OOP()-h_sl; if(h_sl==0) OSL=0; OTP=OOP()+h2_tp; if(h2_tp==0) OTP=0;
            if(Ask>=OOP()+b_even_set) h_b_e=true; if(h_b_e) OSL=OOP()+(2*pt);
            OrderModify(OrderTicket(),0,OSL,OTP,0,CLR_NONE);
         }
         if(cmd()==1)
         {
            if(tp_override && h_tp_over()<lower_4) h2_tp=0;
            OSL=OOP()+h_sl; if(h_sl==0) OSL=0; OTP=OOP()-h2_tp; if(h2_tp==0) OTP=0;
            if(Bid<=OOP()-b_even_set) h_b_e=true; if(h_b_e) OSL=OOP()-(2*pt);
            OrderModify(OrderTicket(),0,OSL,OTP,0,CLR_NONE);
         }
//----
         if(h_rsi_exit)
         {
            if((cmd()==0 && Ask>OOP()-sl_threshold && h_exit()<lower_3)
            || (cmd()==1 && Bid<OOP()+sl_threshold && h_exit()>upper_3))
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,CLR_NONE);
         }
      }
   }
//+------------------------------------------------------------------+
   double deviate=0, h_dev=0; sl_0=sl_std; tp_0=tp_std;
   for(i=0; i<OrdersTotal(); i++) // additional
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || cmd()>1) continue;
      OOP=OrderOpenPrice(); OTP=OrderOpenPrice();
      if(LCT()==1)
      {
         if(cmd()==0 && Ask<=OOP()) deviate=OOP()-Ask;
         if(cmd()==1 && Bid>=OOP()) deviate=Bid-OOP();
      }
      if(OT2()=="H")
      {
         if(cmd()==0 &&Ask<=OOP()) h_dev=OOP()-Ask;
         if(cmd()==1 &&Bid>=OOP()) h_dev=Bid-OOP();
      }
      if(tp_by_level){ tp_0=tp_1; if(LCT()>1) tp_0=tp_2; }
      if((!stealth_mode || tp_by_level) && OT2()!="H")
      {
         if(cmd()==1){ sl_0*=-1; tp_0*=-1; }
         if(use_sl_and_tp) OSL=OOP-sl_0;
         OTP=OOP+tp_0; if(tp_0==0) OTP=0; if(sl_0==0) OSL=0;
         if(OrderTakeProfit()==0) OrderModify(OrderTicket(),0,OSL,OTP,0,CLR_NONE);
      }
   }
//+------------------------------------------------------------------+
//| end of ecTrage mod - ramble_32@yahoo.com                         |
//+------------------------------------------------------------------+
   if(use_sl_and_tp && T()>1)
   {
     int type; double s_l, t_p;
     for(i=0; i<OrdersTotal(); i++)
     {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || cmd()>1) continue;
         type=OrderType();
         s_l=OrderStopLoss();
         t_p=OrderTakeProfit();
     }
//----
     for(i=OrdersTotal()-1; i>=0; i--)
     {
       OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
       if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || cmd()>1) continue;
       if(OrderType()==type)
       {
          if(OrderStopLoss()!=s_l || OrderTakeProfit()!=t_p)
          {
             OrderModify(OrderTicket(),OrderOpenPrice(),s_l,t_p,0,CLR_NONE);
          }
       }
     }
   }
//+------------------------------------------------------------------+
   double profit=0;
   for(i=0; i<OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || cmd()>1) continue;
      profit+=OrderProfit();
   }
//+------------------------------------------------------------------+
   double h2_loss=0; balance=0;
   for(i=0; i<OrdersHistoryTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || cmd()>1) continue;
      balance+=OrderProfit();
   }
//----
   if(T()==0 || bal_2==0)
   {
      GlobalVariableSet("bal_2"+Symbol()+magic,balance);
      bal_2=GlobalVariableGet("bal_2"+Symbol()+magic);
   }
   double tp_m=tp_in_money*pl_factor, tp_m2=balance-bal_2+profit;
   if(tp_m2>=tp_m){ closeall(); closeall=true; e_cycle_set=true; }
//+------------------------------------------------------------------+
   string OT="--", h2_factor="0 %", v_dsp="N", trend="Counter", t_dsp=" / RSI";
   if(b_cnt>0) OT="B"; if(s_cnt>0) OT="S";
   if(hedge) h2_factor=DoubleToStr(h_factor*100,0)+"%";
   if(h_velocity) v_dsp="Y"; if(forward_trend) trend="Forward";
   if(use_velocity) t_dsp=" / V / "+fv_period+" / "+fv_offset;
   double h_lot=0, t_lot=h_lot()*(1/h_factor); if(h_cnt>0) h_lot=h_lot();
   if(t_profit==0 || balance+profit>t_profit) t_profit=balance+profit;
//----
   string line_1="Level = "+T()+" / "+level+" / "+OT+"  |  Equity = "+DoubleToStr(AE,2)+"  |  Profit = "+DoubleToStr(balance+profit,2)+" / "+DoubleToStr(t_profit,2)+"  |  Target = "+DoubleToStr(tp_m2,2)+" / "+DoubleToStr(tp_m,2)+"\n";
   string line_2="Hedge = "+h2_factor+" / "+h_cnt+" / "+h_level+"  |  H Lot = "+DoubleToStr(h_lot,2)+" / "+DoubleToStr(t_lot,2)+"  |  Spread = "+DoubleToStr((Ask-Bid)/pt,2)+"  |  Deviation = "+DoubleToStr(deviate/pt,0)+" / "+DoubleToStr(h_dev/pt,0)+"\n";
   string line_3="Trend = "+trend+t_dsp+"  |  Velocity = "+v_dsp+" / "+DoubleToStr(h_velo(),0)+" / "+vel_offset;
//----
   Comment(line_1, line_2, line_3);
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
int T() // modified
{
  int T=0;
  for(int i=0; i<OrdersTotal(); i++)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
      if(OT2()!="H") T++;
  }
  return(T);
}
//+------------------------------------------------------------------+
double h_lot() // additional
{
  double h_lot=0;
  for(int i=0; i<OrdersTotal(); i++)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
      if(OT2()!="H") h_lot+=OrderLots();
  }
  h_lot=NormalizeDouble(h_lot*h_factor, prec);
  return(h_lot);
}
//+------------------------------------------------------------------+
double LOOP() // additional
{
  double LOOP; int t_cnt=0;
  for(int i=0; i<OrdersTotal(); i++)
  {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || cmd()>1) continue;
     if(cmd()==0){ t_cnt++; if(t_cnt==1 || (t_cnt>1 && OOP()<LOOP)) LOOP=OOP(); }
     if(cmd()==1){ t_cnt++; if(t_cnt==1 || (t_cnt>1 && OOP()>LOOP)) LOOP=OOP(); }
  }
  return(LOOP);
}
//+------------------------------------------------------------------+
int cmd() // additional
{
  int cmd=OrderType();
  return(cmd);
}
double OOP() // additional
{
  double OOP=OrderOpenPrice();
  return(OOP);
}
string OT2() // additional
{
  string OT2=StringSubstr(OrderComment(),0,1);
  return(OT2);
}
int LCT()
{
  int LCT=StrToInteger(StringSubstr(OrderComment(),1,3));
  return(LCT);
}
bool hedge() // additional
{
  bool hedge_2=false;
  if(hedge && T()>=h_level && T()<=h_top_level) hedge_2=true;
  return(hedge_2);
}
//+------------------------------------------------------------------+
double h_entry() // additional
{
  double rsi_1;
  if(hedge() && h_cnt==0){
  if(h_rsi_entry) rsi_1=iRSI(Symbol(),0,rsi_period_2,PRICE_CLOSE,rsi_shift_2); }
  return(rsi_1);
}
double h_exit() // additional
{
  double rsi_2;
  if(hedge() && h_cnt>0){
  if(h_rsi_exit) rsi_2=iRSI(Symbol(),0,rsi_period_3,PRICE_CLOSE,rsi_shift_3); }
  return(rsi_2);
}
double h_tp_over() // additional
{
  double rsi_3;
  if(hedge() && h_cnt>0){
  if(tp_override) rsi_3=iRSI(Symbol(),0,rsi_period_4,PRICE_CLOSE,rsi_shift_4); }
  return(rsi_3);
}
double h_velo()
{
  double velo; // additional
  if(hedge && h_cnt==0){
  if(h_rsi_entry && h_velocity) velo=iCustom(NULL,0,"J_TPO_Velocity",vel_period,0,0); }
  return(velo);
}
//+------------------------------------------------------------------+
int order_send()
{
  if(use_trading_sessions)
  {
     int total_shift=gmt_shift;
     if(daylight_savings) total_shift=gmt_shift+1;
     int asian_open=0+total_shift, asian_close=8 +total_shift;
     int euro_open=6 +total_shift, euro_close=16 +total_shift;
     int ny_open=12  +total_shift, ny_close=21   +total_shift;
//----
     if(DayOfWeek()==0) // sunday
     {
        if(asian_daily){ asian_open=sun_asian_open; asian_close=sun_asian_close; }
        if(euro_daily) { euro_open=sun_euro_open;   euro_close=sun_euro_close; }
        if(ny_daily)   { ny_open=sun_ny_open;       ny_close=sun_ny_close; }
//---
        if(!t_day[0]){ t_day[0]=true; mtd_time=TimeCurrent(); t_day[5]=false; }
     }
     if(DayOfWeek()==1) // monday
     {
        if(asian_daily){ asian_open=mon_asian_open; asian_close=mon_asian_close; }
        if(euro_daily) { euro_open=mon_euro_open;   euro_close=mon_euro_close; }
        if(ny_daily)   { ny_open=mon_ny_open;       ny_close=mon_ny_close; }
//---
        if(!t_day[1]){ t_day[1]=true; mtd_time=TimeCurrent(); t_day[0]=false; }
     }
     if(DayOfWeek()==2) // tuesday
     {
        if(asian_daily){ asian_open=tue_asian_open; asian_close=tue_asian_close; }
        if(euro_daily) { euro_open=tue_euro_open;   euro_close=tue_euro_close; }
        if(ny_daily)   { ny_open=tue_ny_open;       ny_close=tue_ny_close; }
//---
        if(!t_day[2]){ t_day[2]=true; mtd_time=TimeCurrent(); t_day[1]=false; }
     }
     if(DayOfWeek()==3) // wednesday
     {
        if(asian_daily){ asian_open=wed_asian_open; asian_close=wed_asian_close; }
        if(euro_daily) { euro_open=wed_euro_open;   euro_close=wed_euro_close; }
        if(ny_daily)   { ny_open=wed_ny_open;       ny_close=wed_ny_close; }
//---
        if(!t_day[3]){ t_day[3]=true; mtd_time=TimeCurrent(); t_day[2]=false; }
     }
     if(DayOfWeek()==4) // thursday
     {
        if(asian_daily){ asian_open=thu_asian_open; asian_close=thu_asian_close; }
        if(euro_daily) { euro_open=thu_euro_open;   euro_close=thu_euro_close; }
        if(ny_daily)   { ny_open=thu_ny_open;       ny_close=thu_ny_close; }
//---
        if(!t_day[4]){ t_day[4]=true; mtd_time=TimeCurrent(); t_day[3]=false; }
     }
     if(DayOfWeek()==5) // friday
     {
        if(asian_daily){ asian_open=fri_asian_open; asian_close=fri_asian_close; }
        if(euro_daily) { euro_open=fri_euro_open;   euro_close=fri_euro_close; }
        if(ny_daily)   { ny_open=fri_ny_open;       ny_close=fri_ny_close; }
//---
        if(!t_day[5]){ t_day[5]=true; mtd_time=TimeCurrent(); t_day[4]=false; }
     }
//----
     bool o_time=false;
     if(asian_session && Hour()>=asian_open && Hour()<=asian_close) o_time=true;
     if(euro_session  && Hour()>=euro_open  && Hour()<=euro_close)  o_time=true;
     if(ny_session    && Hour()>=ny_open    && Hour()<=ny_close)    o_time=true;
//----
     int o_send=2;
     if(o_time){ if(signal()==buy) o_send=0; if(signal()==sell) o_send=1; }
  }
  return(o_send);
}
//+------------------------------------------------------------------+
int signal()
{
  if(T()==0) // additional
  {
     if(forward_trend)
     {
        if(!use_velocity)
        {
           double rsi_1=iRSI(Symbol(),0,rsi_period_1,PRICE_CLOSE,rsi_shift_1);
           if(rsi_1>upper_min && rsi_1<upper_max) return(buy);
           if(rsi_1<lower_min && rsi_1>lower_max) return(sell);
        }
        if(use_velocity)
        {
           double velo=iCustom(NULL,0,"J_TPO_Velocity",fv_period,0,0);
           if(velo>vel_offset)  return(buy);
           if(velo<-vel_offset) return(sell);
        }
     }
     if(!forward_trend)
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
     }
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
      if(cmd()>1) OrderDelete(OrderTicket());
      else
      {
        if(cmd()==0) OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
        else         OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
      }
  }
}