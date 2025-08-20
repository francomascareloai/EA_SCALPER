//+-----------------------------------------------------------------------------+
//|                                                      TradeStarTrend[EA].mq4 |
//|                                                    Copyright © 2006, Yannis |
//|                                                         All rights reserved |
//| Special Thanks to :                                                         |
//|    Todd Geiger for the initial version of star trend ea         (atp.1.mq4) |
//|    Geir Laastad for his help on gls-startrend           (GLS-StarTrend.ex4) |
//|    Shimodax, Mr Pip and Perky for std deviation limit code          (juice) |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2006, Yannis"
#property link      "jsfero@otenet.gr"
//+-----------------------------------------------------------------------------+
//|                       TradeStarTrend[EA] v1.10                              |
//+-----------------------------------------------------------------------------+

//+----------------------User interface-----------------------------------------+
extern string  Star_Trend_Options="--------------------------";
extern int     Trigger.Period=60;                                 // gls-startrend trigger time frame
extern int     Filter.Period.1=240;                               // gls-startrend first filter time frame.
                                                                  //     If set = to Trigger.Period the ea trades on 1 indicator only
extern int     Filter.Period.2=1440;                              // gls-startrend second filter time frame - can be optional
extern bool    Entry.On.Yellow=true;                              // enter a position if yellow appears on any t/f
extern bool    Exit.On.Yellow=true;                               // exit a position if yellow appears on t/f specified below and all t/f above that
extern int     Exit.On.Yellow.Period=60;                          // t/f for yellow change exit
extern bool    Use.Only.First2.Indicators=false;                  // if true, entries and exits will be based on trigger.period and filter.period.1 only
extern string  SL_TP_Trail_Options="--------------------------";
extern int     StopLoss.Pips=80;                                  // static, initial s/l. Unused if Use.Adr.for.sl.pips = true
extern int     TakeProfit.Pips=300;                               // static, initial take profit
extern int     Trail.Pips=50;                                     // trail.pips. Unused if Use.Adr.for.sl.pips=true or if value=0
extern bool    Trail.Starts.After.BreakEven=false;                // if true trailing will start after a profit of "Move.To.BreakEven.at.pips" is made
extern int     Move.To.BreakEven.at.pips=35;                      // trades in profit will move to entry price + Move.To.BreakEven.Lock.pips
                                                                  // as soon as trade is at entry price + Move.To.BreakEven.at.pips
extern int     Move.To.BreakEven.Lock.pips=1;
extern int     Move.Trail.Every.xx.Pips=0;                        // If > 0 then ALL other s/l are dropped and trail will only move by
                                                                  // Trail.Pips amount for every "Move.Trail.Every.Pips" in profit

extern bool    Use.ADR.for.SL.pips=false;                         // if true s/l and trail according to average daily range and tsl.divisor
extern double  tsl.divisor=0.40;
extern string  Lot_Money_Management="--------------------------";
extern bool    Use.Money.Management=false;
extern double  Minimum.Lot=0.1;
extern double  MaximumRisk=0.03;
extern int     Lot.Margin=50;
extern int     Magic=2006;
extern string  Trading_Hours_Options="--------------------------";
extern bool    Use.Trading.Hours.Restriction = false;             // time filter. if true, expert will open new orders only between
extern int     Start.Trading.Hour.Begin=0;                        // Start.Trading.Hour.Begin and Start.Trading.Hour.End
extern int     Start.Trading.Hour.End=24;
extern string  Juice_Options="--------------------------";
extern bool    Use.Juice=false;                                   // if true, std deviation limit will be used as filter (know as Juice indicator)
extern int     Juice.TimeFrame=5;                                 // time frame for juice. Should be in accordance with trigger.period
extern int     Juice.Period=7;                                    // Juice Period
extern int     Juice.Level=4;                                     // Juice Threshold level used for the filtering
extern string  ADX_Option="--------------------------";
extern bool    Use.Adx= false;                                    // if true, Avereage Directional Movement Index (ADX) MAIN LINE will be used as filter
extern int     Adx.TimeFrame= 5;                                  // time frame on which to evaluate ADX
extern int     Adx.Period=14;                                     // ADX Period
extern int     Adx.Threshold=20;                                  // ADX Main Line threshold value used for the filtering

//+---------------------- Global Variables Definition --------------------------------------+
int b.ticket, s.ticket,slip, TodaysRange;
string DR, DR1, comment=" TST v1.10",ScreenComment="TradeStarTrend[EA] v1.10";
double avg.rng, rng, sum.rng, x;
int Trig_1_Green, Trig_1_MediumSeaGreen, Trig_1_Red, Trig_1_LightCoral, Trig_1_Yellow;
int Trig_2_Green, Trig_2_MediumSeaGreen, Trig_2_Red, Trig_2_LightCoral, Trig_2_Yellow;
int Per1_1_Green, Per1_1_MediumSeaGreen, Per1_1_Red, Per1_1_LightCoral, Per1_1_Yellow;
int Per1_2_Green, Per1_2_MediumSeaGreen, Per1_2_Red, Per1_2_LightCoral, Per1_2_Yellow;
int Per2_1_Green, Per2_1_MediumSeaGreen, Per2_1_Red, Per2_1_LightCoral, Per2_1_Yellow;
int Per2_2_Green, Per2_2_MediumSeaGreen, Per2_2_Red, Per2_2_LightCoral, Per2_2_Yellow;
bool TradingEnabled, LongTradeEnabled, ShortTradeEnabled, ShortTradeShouldClose, LongTradeShouldClose;
double ADXMain1, PlusDI1, MinusDI1, ADXMain2, PlusDI2, MinusDI2, CurrentJuice, TPPrice;


int init()
{  //HideTestIndicators(true);
   slip=(Ask-Bid)/Point;
   return(0);
}

int deinit()
{  return(0);
}

int start()
{  if (TakeProfit.Pips==0) TakeProfit.Pips=999;
   if (StopLoss.Pips  ==0) StopLoss.Pips  =999;
   if (Use.ADR.for.SL.pips)
   {  StopLoss.Pips=NormalizeDouble(Daily.Range()/Point,Digits);
   }
   x=NormalizeDouble(Daily.Range()*tsl.divisor,Digits);

   TodaysRange=MathAbs(iHigh(Symbol(),PERIOD_D1,0)-iLow(Symbol(),PERIOD_D1,0))/Point;

//+---------------------- Main Code Start ---------------------------+
   Indicator.Values    ();                      // Check gls-startrend values
   Filter.Values       ();                      // check values for other indicators / filters used
   PosCounter          ();                      // check for open positions. Sets b.ticket, s.ticket

   if (Move.To.BreakEven.at.pips!=0 && (s.ticket>0 || b.ticket>0))
   {    MoveToBreakEven();                      // Check if condition are met to move to breakeven only if have a position
   }
   if (s.ticket>0 || b.ticket>0)
   {         Trail.Stop();                      // Check if we can trail our stops if we have a position
   }
   comments();                                  // print comments on Screen

   // for CheckForOrderClosing we dont evaluate s.ticket or b.ticket as we always want this to execute
   CheckForOrderClosing();                      // Check if conditions for closing any open order based on exit rules
                                                // also sets LongTradeShouldClose and ShortTradeShouldClose that will be checked
                                                // to avoid conflict on yellow color that results in opening and closing trades at the same time

   Mail();                                      // check mail routine

   TradingEnabled=CheckIfConditionsAllowEntry();// Check if conditions are met for opening a new trade
                                                // returns 0 if no trading conditions according to filters and indicators
                                                // returns 1 if conditions for Long are met
                                                // returns 2 if conditions for Short are met

   if (TradingEnabled==1)
   {  TPPrice=NormalizeDouble(Ask+Point*TakeProfit.Pips,Digits);
   }
   else if (TradingEnabled==2)
   {  TPPrice=NormalizeDouble(Bid-Point*TakeProfit.Pips,Digits);
   }
   if (TradingEnabled==1 && !LongTradeShouldClose)
   {  b.ticket=OrderSend(Symbol(),
      OP_BUY,
      LotCalc(),
      NormalizeDouble(Ask,Digits),
      slip,
      NormalizeDouble(Ask-Point*StopLoss.Pips,Digits),
      NormalizeDouble(TPPrice,Digits),
      Period()+" min"+comment,
      Magic,0,Cyan);
      if(b.ticket>0)
      {  if(OrderSelect(b.ticket,SELECT_BY_TICKET,MODE_TRADES))
         {  Print(b.ticket);
         }
         else Print("Error Opening Buy Order: ",GetLastError());
         return(0);
      }
   }
   else if (TradingEnabled==1 && LongTradeShouldClose)
   {  // yellow indicator's value evaluation problem. We have ok for Long but at same time ok to close
      // todo => inform the user by message or display of this problem
   }
   else if (TradingEnabled==2 && !ShortTradeShouldClose)
   {  s.ticket=OrderSend(Symbol(),
      OP_SELL,
      LotCalc(),
      NormalizeDouble(Bid,Digits),
      slip,
      NormalizeDouble(Bid+Point*StopLoss.Pips,Digits),
      NormalizeDouble(TPPrice,Digits),
      Period()+" min"+comment,
      Magic,0,Magenta);
      if(s.ticket>0)
      {  if(OrderSelect(s.ticket,SELECT_BY_TICKET,MODE_TRADES))
         {  Print(s.ticket);
         }
         else Print("Error Opening Sell Order: ",GetLastError());
         return(0);
      }
   }
   else if (TradingEnabled==2 && ShortTradeShouldClose)
   {  // yellow indicator's value evaluation problem. We have ok for Short but at same time ok to close
      // todo => inform the user by message or display of this problem
   }
   return(0);
} // start
//+---------------------- Main Code End -----------------------------+



//+------------ Function and Procedures called in Main Code ---------+
void Indicator.Values()
{  Trig_1_Green            =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 0, 1); //Green.
   Trig_1_MediumSeaGreen   =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 1, 1); //MediumSeaGreen.
   Trig_1_Red              =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 2, 1); //Red.
   Trig_1_LightCoral       =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 3, 1); //LightCoral.
   Trig_1_Yellow           =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 4, 1); //Neutral Yellow.

   Trig_2_Green            =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 0, 2); //Green.
   Trig_2_MediumSeaGreen   =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 1, 2); //MediumSeaGreen.
   Trig_2_Red              =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 2, 2); //Red.
   Trig_2_LightCoral       =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 3, 2); //LightCoral.
   Trig_2_Yellow           =iCustom(NULL,Trigger.Period, "GLS-StarTrend", 4, 2); //Neutral Yellow.

   Per1_1_Green            =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 0, 1); //Green.
   Per1_1_MediumSeaGreen   =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 1, 1); //MediumSeaGreen.
   Per1_1_Red              =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 2, 1); //Red.
   Per1_1_LightCoral       =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 3, 1); //LightCoral.
   Per1_1_Yellow           =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 4, 1); //Neutral Yellow.

   Per1_2_Green            =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 0, 2); //Green.
   Per1_2_MediumSeaGreen   =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 1, 2); //MediumSeaGreen.
   Per1_2_Red              =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 2, 2); //Red.
   Per1_2_LightCoral       =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 3, 2); //LightCoral.
   Per1_2_Yellow           =iCustom(NULL,Filter.Period.1, "GLS-StarTrend", 4, 2); //Neutral Yellow.

   Per2_1_Green            =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 0, 1); //Green.
   Per2_1_MediumSeaGreen   =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 1, 1); //MediumSeaGreen.
   Per2_1_Red              =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 2, 1); //Red.
   Per2_1_LightCoral       =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 3, 1); //LightCoral.
   Per2_1_Yellow           =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 4, 1); //Neutral Yellow.

   Per2_2_Green            =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 0, 2); //Green.
   Per2_2_MediumSeaGreen   =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 1, 2); //MediumSeaGreen.
   Per2_2_Red              =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 2, 2); //Red.
   Per2_2_LightCoral       =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 3, 2); //LightCoral.
   Per2_2_Yellow           =iCustom(NULL,Filter.Period.2, "GLS-StarTrend", 4, 2); //Neutral Yellow.
}

void Filter.Values()
{  if (Use.Adx)
   {  ADXMain1=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MAIN,1);
      //MinusDI1=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MINUSDI,1);
      //PlusDI1 =iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_PLUSDI,1);
      ADXMain2=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MAIN,2);
      //MinusDI2=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MINUSDI,2);
      //PlusDI2 =iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_PLUSDI,2);
   }
   if (Use.Juice)
   {  CurrentJuice = Juice(1, Juice.Period, Juice.Level,Juice.TimeFrame);
   }
}

double Daily.Range()
{  if (DR==TimeToStr(CurTime(),TIME_DATE))
   {  return(NormalizeDouble(avg.rng,Digits));
   }
   rng=0;sum.rng=0;avg.rng=0;
   for (int i=0;i<iBars(Symbol(),1440);i++)
   {  rng=(iHigh(Symbol(),PERIOD_D1,i)-iLow(Symbol(),PERIOD_D1,i));
      sum.rng+=rng;
   }
   double db=iBars(Symbol(),1440);
   avg.rng=sum.rng/db;
   DR=TimeToStr(CurTime(),TIME_DATE);
   return (NormalizeDouble(avg.rng,Digits));
}

void PosCounter()
{  b.ticket=0;s.ticket=0;
   for (int cnt=0;cnt<=OrdersTotal();cnt++)
   {  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
      {  if (OrderType()==OP_SELL)
         {  s.ticket=OrderTicket();
         }
         if (OrderType()==OP_BUY)
         {  b.ticket=OrderTicket();
         }
      }
   }
}

double LotCalc()
{  double lot;
   if (Use.Money.Management)
   {  //lot=AccountFreeMargin()*(MaximumRisk/Lot.Margin);
      lot=NormalizeDouble((AccountFreeMargin()*MaximumRisk)/(MarketInfo(Symbol(),MODE_TICKVALUE)*StopLoss.Pips),2);
   }
   if (!Use.Money.Management) {lot=Minimum.Lot;}
   return(lot);
}

void comments()
{  string s0="", s1="", s2="", s3="", swap="", sCombo="", sStr ;
   int PipsProfit;
   double AmountProfit;
   PipsProfit=0; AmountProfit=0;
   PosCounter();
   if (b.ticket>0) 
   {  OrderSelect(b.ticket,SELECT_BY_TICKET);
      PipsProfit=NormalizeDouble(((Bid - OrderOpenPrice())/Point),Digits);
      AmountProfit=OrderProfit();
   }
   else if (s.ticket>0) 
   {  OrderSelect(s.ticket,SELECT_BY_TICKET);
      PipsProfit=NormalizeDouble(((OrderOpenPrice()-Ask)/Point),Digits);
      AmountProfit=OrderProfit();
   }
   if (Exit.On.Yellow)              s0="Exit if Yellow on "+Exit.On.Yellow.Period+" min";
   else                             s0="";
   if (Move.To.BreakEven.at.pips>0) s1="s/l will move to b/e after: "+Move.To.BreakEven.at.pips+" pips   and lock: "+Move.To.BreakEven.Lock.pips+" pips"+"\n\n";
   else                             s1="";
   if (Use.Juice)                   s2="Use Juice: Yes  Juice.TimeFrame: "+Juice.TimeFrame+"\n";
   else                             s2="Use Juice: No";
   if (Use.Adx)                     s3="Use ADX: Yes    ADX TimeFrame:"+Adx.TimeFrame +"    Adx Threshold: "+Adx.Threshold+"\n";
   else                             s3="Use ADX: No";
   if (Use.Only.First2.Indicators) sCombo=Trigger.Period+"/"+Filter.Period.1;
   else sCombo=Trigger.Period+"/"+Filter.Period.1+"/"+Filter.Period.2;
   Comment( ScreenComment,"\n",
            "Today\'s Range: ",TodaysRange,"\n",
            "Combo Used: ",sCombo,"  ",s0,"\n",
            "s/l: ",StopLoss.Pips,"  tp:",TakeProfit.Pips,"  trail:",Trail.Pips,"\n",
            s1,
            s2,"\n",
            s3,"\n",
            "\n", "Pips: ",PipsProfit,"  /  $ ", AmountProfit,
          );
}

void Trail.With.ADR(int AfterBE)
{  double bsl, b.tsl, ssl, s.tsl;
   PosCounter();
   // x=Minimum Wave Range of Average Daily Range Trailing Stop Calculation
   if (AfterBE==0) // Trail Starts immediately
   {  if(b.ticket>0)
      {  bsl=NormalizeDouble(x,Digits);
         b.tsl=0;
         OrderSelect(b.ticket,SELECT_BY_TICKET);
         //if stoploss is less than minimum wave range, set bsl to current SL
         if (OrderStopLoss()<OrderOpenPrice() && OrderOpenPrice()-OrderStopLoss()<x)
         {  bsl=OrderOpenPrice()-OrderStopLoss();
         }
         //if stoploss is equal to, or greater than minimum wave range, set bsl to minimum wave range
         if (OrderStopLoss()<OrderOpenPrice() && OrderOpenPrice()-OrderStopLoss()>=x)
         {  bsl=NormalizeDouble(x,Digits);
         }
         //determine if stoploss should be modified
         if (Bid>(OrderOpenPrice()+bsl) && OrderStopLoss()<(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl))))
         {  b.tsl=NormalizeDouble(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl)),Digits);
            Print("b.tsl ",b.tsl);
            if (OrderStopLoss()<b.tsl)
            {  OrderModify(b.ticket,OrderOpenPrice(),b.tsl,OrderTakeProfit(),OrderExpiration(),MediumSpringGreen);
            }
         }
      }
      if(s.ticket>0)
      {  ssl=NormalizeDouble(x,Digits);
         s.tsl=0;
         OrderSelect(s.ticket,SELECT_BY_TICKET);
         //if stoploss is less than minimum wave range, set ssl to current SL
         if (OrderStopLoss()>OrderOpenPrice() && OrderStopLoss()-OrderOpenPrice()<x)
         {  ssl=OrderStopLoss()-OrderOpenPrice();
         }
         //if stoploss is equal to, or greater than minimum wave range, set bsl to minimum wave range
         if (OrderStopLoss()>OrderOpenPrice() && OrderStopLoss()-OrderOpenPrice()>=x)
         {  ssl=NormalizeDouble(x,Digits);
         }
         //determine if stoploss should be modified
         if (Ask<(OrderOpenPrice()-ssl) && OrderStopLoss()>(OrderOpenPrice()-(OrderOpenPrice()-ssl)-Ask))
         {  s.tsl=NormalizeDouble(OrderOpenPrice()-((OrderOpenPrice()-ssl)-Ask),Digits);
            Print("s.tsl ",s.tsl);
            if(OrderStopLoss()>s.tsl)
            {  OrderModify(s.ticket,OrderOpenPrice(),s.tsl,OrderTakeProfit(),OrderExpiration(),MediumVioletRed);
            }
         }
      }
   }
   else // If Trail.Starts.After.BreakEven
   {  if (b.ticket>0)
      {  bsl=NormalizeDouble(x,Digits);
         b.tsl=0;
         OrderSelect(b.ticket,SELECT_BY_TICKET);
         if (Bid>=(OrderOpenPrice()+(Move.To.BreakEven.at.pips*Point)))
         {  //if stoploss is less than minimum wave range, set bsl to current SL
            if (OrderStopLoss()<OrderOpenPrice() && OrderOpenPrice()-OrderStopLoss()<x)
            {  bsl=OrderOpenPrice()-OrderStopLoss();
            }
            //if stoploss is equal to, or greater than minimum wave range, set bsl to minimum wave range
            if (OrderStopLoss()<OrderOpenPrice() && OrderOpenPrice()-OrderStopLoss()>=x)
            {  bsl=NormalizeDouble(x,Digits);
            }
            //determine if stoploss should be modified
            if (Bid>(OrderOpenPrice()+bsl) && OrderStopLoss()<(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl))))
            {  b.tsl=NormalizeDouble(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl)),Digits);
               Print("b.tsl ",b.tsl);
               if (OrderStopLoss()<b.tsl)
               {  OrderModify(b.ticket,OrderOpenPrice(),b.tsl,OrderTakeProfit(),OrderExpiration(),MediumSpringGreen);
               }
            }
         }
      }
      if (s.ticket>0)
      {  ssl=NormalizeDouble(x,Digits);
         s.tsl=0;
         OrderSelect(s.ticket,SELECT_BY_TICKET);
         if (Ask<=(OrderOpenPrice()-(Move.To.BreakEven.at.pips*Point)))
         {  //if stoploss is less than minimum wave range, set ssl to current SL
            if(OrderStopLoss()>OrderOpenPrice() && OrderStopLoss()-OrderOpenPrice()<x)
            {  ssl=OrderStopLoss()-OrderOpenPrice();
            }
            //if stoploss is equal to, or greater than minimum wave range, set bsl to minimum wave range
            if(OrderStopLoss()>OrderOpenPrice() && OrderStopLoss()-OrderOpenPrice()>=x)
            {  ssl=NormalizeDouble(x,Digits);
            }
            //determine if stoploss should be modified
            if(Ask<(OrderOpenPrice()-ssl) && OrderStopLoss()>(OrderOpenPrice()-(OrderOpenPrice()-ssl)-Ask))
            {  s.tsl=NormalizeDouble(OrderOpenPrice()-((OrderOpenPrice()-ssl)-Ask),Digits);
               Print("s.tsl ",s.tsl);
               if(OrderStopLoss()>s.tsl)
               {  OrderModify(s.ticket,OrderOpenPrice(),s.tsl,OrderTakeProfit(),OrderExpiration(),MediumVioletRed);
               }
            }
         }
      }
   }
}

void Trail.With.Standard.Trailing(int AfterBE)
{  double bsl, b.tsl, ssl, s.tsl;
   PosCounter();
   if (AfterBE==0)
   {  if (b.ticket>0)
      {  bsl=Trail.Pips*Point;
         OrderSelect(b.ticket,SELECT_BY_TICKET);
         //determine if stoploss should be modified
         if(Bid>(OrderOpenPrice()+bsl) && OrderStopLoss()<(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl))))
         {  b.tsl=NormalizeDouble(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl)),Digits);
            Print("b.tsl ",b.tsl);
            if (OrderStopLoss()<b.tsl)
            {  OrderModify(b.ticket,OrderOpenPrice(),b.tsl,OrderTakeProfit(),OrderExpiration(),MediumSpringGreen);
            }
         }
      }
      if(s.ticket>0)
      {  ssl=Trail.Pips*Point;
         //determine if stoploss should be modified
         OrderSelect(s.ticket,SELECT_BY_TICKET);
         if (Ask<(OrderOpenPrice()-ssl) && OrderStopLoss()>(OrderOpenPrice()-(OrderOpenPrice()-ssl)-Ask))
         {  s.tsl=NormalizeDouble(OrderOpenPrice()-((OrderOpenPrice()-ssl)-Ask),Digits);
            Print("s.tsl ",s.tsl);
            if (OrderStopLoss()>s.tsl)
            {  OrderModify(s.ticket,OrderOpenPrice(),s.tsl,OrderTakeProfit(),OrderExpiration(),MediumVioletRed);
            }
         }
      }
   }
   else // If Trail.Starts.After.BreakEven
   {  if (b.ticket>0)
      {  OrderSelect(b.ticket,SELECT_BY_TICKET);
         if (Bid>=(OrderOpenPrice()+(Move.To.BreakEven.at.pips*Point)))
         {  bsl=Trail.Pips*Point;
            if (Bid>(OrderOpenPrice()+bsl) && OrderStopLoss()<(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl))))
            {  b.tsl=NormalizeDouble(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl)),Digits);
               Print("b.tsl ",b.tsl);
               if (OrderStopLoss()<b.tsl)
               {  OrderModify(b.ticket,OrderOpenPrice(),b.tsl,OrderTakeProfit(),OrderExpiration(),MediumSpringGreen);
               }
            }
         }
      }
      if(s.ticket>0)
      {  OrderSelect(s.ticket,SELECT_BY_TICKET);
         if (Ask<=(OrderOpenPrice()-(Move.To.BreakEven.at.pips*Point)))
         {  ssl=Trail.Pips*Point;
            //determine if stoploss should be modified
            if(Ask<(OrderOpenPrice()-ssl) && OrderStopLoss()>(OrderOpenPrice()-(OrderOpenPrice()-ssl)-Ask))
            {  s.tsl=NormalizeDouble(OrderOpenPrice()-((OrderOpenPrice()-ssl)-Ask),Digits);
               Print("s.tsl ",s.tsl);
               if(OrderStopLoss()>s.tsl)
               {  OrderModify(s.ticket,OrderOpenPrice(),s.tsl,OrderTakeProfit(),OrderExpiration(),MediumVioletRed);
               }
            }
         }
      }
   }
}


void Trail.With.Every.xx.Pips()
{  double bsl, b.tsl, ssl, s.tsl, CurrProfit;
   int Factor;
   PosCounter();
   if (b.ticket>0)
   {  OrderSelect(b.ticket,SELECT_BY_TICKET);
      CurrProfit=((Bid-OrderOpenPrice())/Point);
      if (CurrProfit>=Move.Trail.Every.xx.Pips)
      {  Factor=MathFloor(CurrProfit/Move.Trail.Every.xx.Pips);
         bsl=Factor*Trail.Pips*Point;
         //determine if stoploss should be modified
         if(Bid>(OrderOpenPrice()+bsl) && OrderStopLoss()<(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl))))
         {  b.tsl=NormalizeDouble(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl)),Digits);
            Print("b.tsl ",b.tsl);
            if (OrderStopLoss()<b.tsl)
            {  OrderModify(b.ticket,OrderOpenPrice(),b.tsl,OrderTakeProfit(),OrderExpiration(),MediumSpringGreen);
            }
         }
      }
   }
   if(s.ticket>0)
   {  OrderSelect(s.ticket,SELECT_BY_TICKET);
      CurrProfit=((OrderOpenPrice()-Ask)/Point);
      if (CurrProfit>=Move.Trail.Every.xx.Pips)
      {  Factor=MathFloor(CurrProfit/Move.Trail.Every.xx.Pips);
         ssl=Factor*Trail.Pips*Point;
         //determine if stoploss should be modified
         if (Ask<(OrderOpenPrice()-ssl) && OrderStopLoss()>(OrderOpenPrice()-(OrderOpenPrice()-ssl)-Ask))
         {  s.tsl=NormalizeDouble(OrderOpenPrice()-((OrderOpenPrice()-ssl)-Ask),Digits);
            Print("s.tsl ",s.tsl);
            if (OrderStopLoss()>s.tsl)
            {  OrderModify(s.ticket,OrderOpenPrice(),s.tsl,OrderTakeProfit(),OrderExpiration(),MediumVioletRed);
            }
         }
      }
   }
}

void Trail.Stop()
{  if (Move.Trail.Every.xx.Pips>0 && Trail.Pips>0)
   {  Trail.With.Every.xx.Pips();
   }
   else
   {  if (Use.ADR.for.SL.pips)
      {  if (Trail.Starts.After.BreakEven)   Trail.With.ADR(1);
         else                                Trail.With.ADR(0);
      }
      else if (Trail.Pips>0)
      {  if (Trail.Starts.After.BreakEven)   Trail.With.Standard.Trailing(1);
         else                                Trail.With.Standard.Trailing(0);
      }
   }
}

void Mail()
{  OrderSelect(b.ticket,SELECT_BY_TICKET);
   if(OrderCloseTime()>0)
   {  SendMail(Symbol()+" "+OrderComment(),"Buy Order Closed, $"+DoubleToStr(OrderProfit(),2)+" "+DoubleToStr(Bid,Digits)+"/"+DoubleToStr(Ask,Digits));
   }
   OrderSelect(s.ticket,SELECT_BY_TICKET);
   if(OrderCloseTime()>0)
   {  SendMail(Symbol()+" "+OrderComment(),"Sell Order Closed, $"+DoubleToStr(OrderProfit(),2)+" "+DoubleToStr(Bid,Digits)+"/"+DoubleToStr(Ask,Digits));
   }
}

void MoveToBreakEven()
{  PosCounter();
   if (b.ticket > 0)
   {  OrderSelect(b.ticket,SELECT_BY_TICKET);
      if (OrderStopLoss()<OrderOpenPrice())
      {  if (Bid >((Move.To.BreakEven.at.pips*Point) +OrderOpenPrice()))
         {  OrderModify(b.ticket, OrderOpenPrice(), (OrderOpenPrice()+(Move.To.BreakEven.Lock.pips*Point)),OrderTakeProfit(),OrderExpiration(),MediumSpringGreen);
            if (OrderSelect(b.ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Long StopLoss Moved to BE at : ",OrderStopLoss());
            else Print("Error moving Long StopLoss to BE: ",GetLastError());
         }
      }
   }
   if (s.ticket > 0)
   {  OrderSelect(s.ticket,SELECT_BY_TICKET);
      if (OrderStopLoss()>OrderOpenPrice())
      {  if ( Ask < (OrderOpenPrice()-(Move.To.BreakEven.at.pips*Point)))
         {  OrderModify(OrderTicket(), OrderOpenPrice(), (OrderOpenPrice()-(Move.To.BreakEven.Lock.pips*Point)),OrderTakeProfit(),OrderExpiration(),MediumVioletRed);
            if(OrderSelect(s.ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Short StopLoss Moved to BE at : ",OrderStopLoss());
            else Print("Error moving Short StopLoss to BE: ",GetLastError());
         }
      }
   }
}

double Juice(int shift, int period, int level, int jtimeframe)
{  double osma= 0;
   osma= iStdDev(NULL,jtimeframe, period, MODE_EMA, 0, PRICE_CLOSE,shift) - level*Point;
   return (osma);
}

int CheckIfConditionsAllowEntry() // 0=no entry 1=ok for long 2=ok for short
{  bool StarTrendIsOK;
   bool AdxIsOK;
   PosCounter(); // Check if current orders running.
   //General Conditions / Filtering
        if (!(b.ticket==0 && s.ticket==0))                                                                        return (0); // if a position is open, skip checking
   else if (Use.Trading.Hours.Restriction && (Hour()<Start.Trading.Hour.Begin || Hour()>Start.Trading.Hour.End))  return (0); // Check Time Filter
   else if (Use.Juice && CurrentJuice<=0)                                                                         return (0); // check Juice
   else if (Use.Adx && (!(ADXMain1>=ADXMain2 && ADXMain1>=Adx.Threshold)))                                        return (0); // Check Adx rising and above threshold

   // Conditions for Long
   StarTrendIsOK=false;
   // Check Star Trend
   if (Entry.On.Yellow) // if Entry.On.Yellow = true
   {  if (!Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (red or light coral or yellow) to (green or mediumseagreen)
                  // and 15 and 60 are (green or mediumseagreen)
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Trig_2_Red==1   || Trig_2_LightCoral==1 || Trig_2_Yellow==1) &&
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1) && (Per2_1_Green==1 || Per2_1_MediumSeaGreen==1)
               )
               || // OR
               (  // If 15 turns from (red or light coral or yellow) to (green or mediumseagreen)
                  // and 5 and 60 are (green or mediumseagreen)
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1) && (Per1_2_Red==1   || Per1_2_LightCoral==1 || Per1_2_Yellow==1) &&
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Per2_1_Green==1 || Per2_1_MediumSeaGreen==1)
               )
               || // OR
               (  // If 60 turns from (red or light coral or yellow) to (green or mediumseagreen)
                  // and 5 and 15 are (green or mediumseagreen)
                (Per2_1_Green==1 || Per2_1_MediumSeaGreen==1) && (Per2_2_Red==1   || Per2_2_LightCoral==1 || Per2_2_Yellow==1) &&
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1)
               )
            )
          ) {StarTrendIsOK=True;}
      else
      if (Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (red or light coral or yellow) to (green or mediumseagreen)
                  // and 15 is (green or mediumseagreen)
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Trig_2_Red==1   || Trig_2_LightCoral==1 || Trig_2_Yellow==1) &&
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1)
               )
               || // OR
               (  // If 15 turns from (red or light coral or yellow) to (green or mediumseagreen)
                  // and 5 is (green or mediumseagreen)
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1) && (Per1_2_Red==1   || Per1_2_LightCoral==1 || Per1_2_Yellow==1) &&
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1)
               )
            )
         ) {StarTrendIsOK=True;}
   }
   else // if Entry.On.Yellow = false
   {  if (!Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (red or light coral) to (green or mediumseagreen)
                  // and 15 and 60 are (green or mediumseagreen)
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Trig_2_Red==1   || Trig_2_LightCoral==1) &&
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1) && (Per2_1_Green==1 || Per2_1_MediumSeaGreen==1)
               )
               || // OR
               (  // If 15 turns from (red or light coral) to (green or mediumseagreen)
                  // and 5 and 60 are (green or mediumseagreen)
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1) && (Per1_2_Red==1   || Per1_2_LightCoral==1) &&
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Per2_1_Green==1 || Per2_1_MediumSeaGreen==1)
               )
               || // OR
               (  // If 60 turns from (red or light coral) to (green or mediumseagreen)
                  // and 5 and 15 are (green or mediumseagreen)
                (Per2_1_Green==1 || Per2_1_MediumSeaGreen==1) && (Per2_2_Red==1   || Per2_2_LightCoral==1) &&
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1)
               )
            )
          ) {StarTrendIsOK=True;}
      else
      if (Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (red or light coral) to (green or mediumseagreen)
                  // and 15 is (green or mediumseagreen)
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1) && (Trig_2_Red==1   || Trig_2_LightCoral==1) &&
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1)
               )
               || // OR
               (  // If 15 turns from (red or light coral) to (green or mediumseagreen)
                  // and 5 is (green or mediumseagreen)
                (Per1_1_Green==1 || Per1_1_MediumSeaGreen==1) && (Per1_2_Red==1   || Per1_2_LightCoral==1) &&
                (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1)
               )
            )
         ) {StarTrendIsOK=True;}
   }
   if (StarTrendIsOK) return(1);


   // Conditions for Short
   StarTrendIsOK=false;

   // Check Star Trend
   if (Entry.On.Yellow)
   {  // if Entry.On.Yellow = true
      if (!Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (green or mediumseagreen or yellow) to (red or lightcoral)
                  // and 15 and 60 are (red or lightcoral)
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Trig_2_Green==1 || Trig_2_MediumSeaGreen==1 || Trig_2_Yellow==1) &&
                (Per1_1_Red==1 || Per1_1_LightCoral==1) && (Per2_1_Red  ==1 || Per2_1_LightCoral==1)
               )
               || // OR
               (  // If 15 turns from (green or mediumseagreen or yellow) to (red or lightcoral)
                  // and 5 and 60 are (red or lightcoral)
                (Per1_1_Red==1 || Per1_1_LightCoral==1) && (Per1_2_Green==1 || Per1_2_MediumSeaGreen==1 || Per1_2_Yellow==1) &&
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Per2_1_Red  ==1 || Per2_1_LightCoral==1)
               )
               || // OR
               (  // If 60 turns from (green or mediumseagreen or yellow) to (red or lightcoral)
                  // and 5 and 15 are (red or lightcoral)
                (Per2_1_Red==1 || Per2_1_LightCoral==1) && (Per2_2_Green==1 || Per2_2_MediumSeaGreen==1 || Per2_2_Yellow==1) &&
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Per1_1_Red  ==1 || Per1_1_LightCoral==1)
               )
            )
          ) {StarTrendIsOK=True;}
      else
      if (Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (green or mediumseagreen or yellow) to (red or lightcoral)
                  // and 15 is (red or lightcoral)
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Trig_2_Green==1 || Trig_2_MediumSeaGreen==1 || Trig_2_Yellow==1) &&
                (Per1_1_Red==1 || Per1_1_LightCoral==1)
               )
               || // OR
               (  // If 15 turns from (green or mediumseagreen or yellow) to (red or lightcoral)
                  // and 5 is (red or lightcoral)
                (Per1_1_Red==1 || Per1_1_LightCoral==1) && (Per1_2_Green==1 || Per1_2_MediumSeaGreen==1 || Per1_2_Yellow==1) &&
                (Trig_1_Red==1 || Trig_1_LightCoral==1)
               )
            )
         ) {StarTrendIsOK=True;}
   }
   else
   {  // if Entry.On.Yellow = false
      if (!Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (green or mediumseagreen) to (red or lightcoral)
                  // and 15 and 60 are (red or lightcoral)
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Trig_2_Green==1 || Trig_2_MediumSeaGreen==1) &&
                (Per1_1_Red==1 || Per1_1_LightCoral==1) && (Per2_1_Red  ==1 || Per2_1_LightCoral==1)
               )
               || // OR
               (  // If 15 turns from (green or mediumseagreen) to (red or lightcoral)
                  // and 5 and 60 are (red or lightcoral)
                (Per1_1_Red==1 || Per1_1_LightCoral==1) && (Per1_2_Green==1 || Per1_2_MediumSeaGreen==1) &&
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Per2_1_Red  ==1 || Per2_1_LightCoral==1)
               )
               || // OR
               (  // If 60 turns from (green or mediumseagreen) to (red or lightcoral)
                  // and 5 and 15 are (red or lightcoral)
                (Per2_1_Red==1 || Per2_1_LightCoral==1) && (Per2_2_Green==1 || Per2_2_MediumSeaGreen==1) &&
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Per1_1_Red  ==1 || Per1_1_LightCoral==1)
               )
            )
          ) {StarTrendIsOK=True;}
      else
      if (Use.Only.First2.Indicators &&
            (  (  // If 5 turns from (green or mediumseagreen) to (red or lightcoral)
                  // and 15 is (red or lightcoral)
                (Trig_1_Red==1 || Trig_1_LightCoral==1) && (Trig_2_Green==1 || Trig_2_MediumSeaGreen==1) &&
                (Per1_1_Red==1 || Per1_1_LightCoral==1)
               )
               || // OR
               (  // If 15 turns from (green or mediumseagreen) to (red or lightcoral)
                  // and 5 is (red or lightcoral)
                (Per1_1_Red==1 || Per1_1_LightCoral==1) && (Per1_2_Green==1 || Per1_2_MediumSeaGreen==1) &&
                (Trig_1_Red==1 || Trig_1_LightCoral==1)
               )
            )
         ) {StarTrendIsOK=True;}
   }

   if (StarTrendIsOK) return(2);
   return(0);
}

void CheckForOrderClosing()
{  bool iShouldExit=false;
   PosCounter(); // Check if current orders running.
   iShouldExit=false;
   ShortTradeShouldClose=false;
   LongTradeShouldClose=false;

   // --------------------------------
   // Check Exit Conditions for Longs
   // --------------------------------
  if (!Exit.On.Yellow) // Yellow is ignored
   {  if (!Use.Only.First2.Indicators) // if user choose all 3 time frames
      {  // if we have a change of colour in any time frame from (green or mediumseagreen) to (red or lightcoral) exit longs
         if (Trig_1_Red==1 || Trig_1_LightCoral==1 || Per1_1_Red==1 || Per1_1_LightCoral==1 || Per2_1_Red==1 || Per2_1_LightCoral==1)
         {iShouldExit=true;}
      }
      else // if we have a change of colour only in the first 2 time frames from (green or mediumseagreen) to (red or lightcoral) exit longs
      {  if (Trig_1_Red==1 || Trig_1_LightCoral==1 || Per1_1_Red==1 || Per1_1_LightCoral==1)
         {iShouldExit=true;}
      }
   }
   else // use yellow for exit
   {  if (!Use.Only.First2.Indicators) // if user choose all 3 time frames
      {  if (Exit.On.Yellow.Period==Trigger.Period &&
               (Trig_1_Red==1 || Trig_1_LightCoral==1 || Trig_1_Yellow==1 ||
                Per1_1_Red==1 || Per1_1_LightCoral==1 || Per1_1_Yellow==1 ||
                Per2_1_Red==1 || Per2_1_LightCoral==1 || Per2_1_Yellow==1)
            ) {iShouldExit=true;}
         if (Exit.On.Yellow.Period==Filter.Period.1 &&
               (Trig_1_Red==1 || Trig_1_LightCoral==1                     ||
                Per1_1_Red==1 || Per1_1_LightCoral==1 || Per1_1_Yellow==1 ||
                Per2_1_Red==1 || Per2_1_LightCoral==1 || Per2_1_Yellow==1)
            ) {iShouldExit=true;}
         if (Exit.On.Yellow.Period==Filter.Period.2 &&
               (Trig_1_Red==1 || Trig_1_LightCoral==1                     ||
                Per1_1_Red==1 || Per1_1_LightCoral==1                     ||
                Per2_1_Red==1 || Per2_1_LightCoral==1 || Per2_1_Yellow==1)
            ) {iShouldExit=true;}
      }
      else // if user choose only the first 2 time frames
      {  if (Exit.On.Yellow.Period==Trigger.Period &&
               (Trig_1_Red==1 || Trig_1_LightCoral==1 || Trig_1_Yellow==1 ||
                Per1_1_Red==1 || Per1_1_LightCoral==1 || Per1_1_Yellow==1)
            ) {iShouldExit=true;}
         if (Exit.On.Yellow.Period==Filter.Period.1 &&
               (Trig_1_Red==1 || Trig_1_LightCoral==1                     ||
                Per1_1_Red==1 || Per1_1_LightCoral==1 || Per1_1_Yellow==1)
            ) {iShouldExit=true;}
      }
   }
   if (iShouldExit)
   {  LongTradeShouldClose=true;
      if (b.ticket>0)
      {  OrderSelect(b.ticket,SELECT_BY_TICKET);
         OrderClose(OrderTicket(),OrderLots(),Bid,slip,Blue);
      }
   }

   // --------------------------------
   // Check Exit Conditions for Shorts
   // --------------------------------
   iShouldExit=false;
   if (!Exit.On.Yellow) // Yellow is ignored
   {  if (!Use.Only.First2.Indicators) // if user choose all 3 time frames
      {  // if we have a change of colour in any time frame from (red or lightcoral) to (green or mediumseagreen) exit shorts
         if (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1 || Per1_1_Green==1 || Per1_1_MediumSeaGreen==1 || Per2_1_Green==1 || Per2_1_MediumSeaGreen==1)
            {iShouldExit=true;}
      }
      else // if we have a change of colour only in the first 2 time frames from (red or lightcoral) to (green or mediumseagreen) exit shorts
      {  if (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1 || Per1_1_Green==1 || Per1_1_MediumSeaGreen==1)
            {iShouldExit=true;}
      }
   }
   else // use of yellow for exit
   {  if (!Use.Only.First2.Indicators) // if user choose all 3 time frames
      {  if (Exit.On.Yellow.Period==Trigger.Period &&
               (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1 || Trig_1_Yellow==1 ||
                Per1_1_Green==1 || Per1_1_MediumSeaGreen==1 || Per1_1_Yellow==1 ||
                Per2_1_Green==1 || Per2_1_MediumSeaGreen==1 || Per2_1_Yellow==1)
            ) {iShouldExit=true;}
         if (Exit.On.Yellow.Period==Filter.Period.1 &&
               (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1                     ||
                Per1_1_Green==1 || Per1_1_MediumSeaGreen==1 || Per1_1_Yellow==1 ||
                Per2_1_Green==1 || Per2_1_MediumSeaGreen==1 || Per2_1_Yellow==1)
            ) {iShouldExit=true;}
         if (Exit.On.Yellow.Period==Filter.Period.2 &&
               (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1                     ||
                Per1_1_Green==1 || Per1_1_MediumSeaGreen==1                     ||
                Per2_1_Green==1 || Per2_1_MediumSeaGreen==1 || Per2_1_Yellow==1)
            ) {iShouldExit=true;}
      }
      else //if user choose only the first 2 time frames
      {  if (Exit.On.Yellow.Period==Trigger.Period &&
               (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1 || Trig_1_Yellow==1 ||
                Per1_1_Green==1 || Per1_1_MediumSeaGreen==1 || Per1_1_Yellow==1)
            ) {iShouldExit=true;}
         if (Exit.On.Yellow.Period==Filter.Period.1 &&
               (Trig_1_Green==1 || Trig_1_MediumSeaGreen==1                     ||
                Per1_1_Green==1 || Per1_1_MediumSeaGreen==1 || Per1_1_Yellow==1)
            ) {iShouldExit=true;}
      }
   }
   if (iShouldExit)
   {  ShortTradeShouldClose=true;
      if (s.ticket>0)
      {  OrderSelect(s.ticket,SELECT_BY_TICKET);
         OrderClose(OrderTicket(),OrderLots(),Ask,slip,Red);
      }
   }
}

