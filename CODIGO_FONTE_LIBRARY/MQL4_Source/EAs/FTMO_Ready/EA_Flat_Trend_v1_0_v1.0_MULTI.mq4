//+------------------------------------------------------------------+
//| Special Thanks to :                                              |
//|    Todd Geiger for the initial start trend ea                    |
//|    Shimodax, Mr Pip and Perky for the Juice indicator            |
//|    Kirk Sloan for Flat Trend 2 indicator                         |
//+------------------------------------------------------------------+

extern int     Trigger.Period=5;
extern int     Filter.Period.1=15;
extern int     Filter.Period.2=60;
extern bool    Ignore.Light.Colors.For.Entry=false;
extern bool    Ignore.Light.Colors.For.Exit=true;

extern double  tsl.divisor=0.40;
extern int     stoploss.pips=40;
extern bool    Use.ADR.for.SL.pips?=true;

extern bool    Use.Money.Management?=false;//if false, lot=Minimum.Lot
extern double  Minimum.Lot=1;
extern double  MaximumRisk=0.03;
extern int     Lot.Margin=100;
extern int     Magic=1801;
extern string  comment=" Flat.Trend.v1.0[EA]";
extern string  sep1="----------------";
extern bool    Use.Only.First2.Indicators=false;
extern bool    Use.Trading.Hours.Restriction = false;
extern int     Start.Trading.Hour.Begin = 0;
extern int     Start.Trading.Hour.End   = 24;
//extern bool    Use.ADR.Tightening =false;
extern string  sep2="----------------";
extern bool    Use.Juice=true;
extern int     Juice.TimeFrame= 5;
extern int     Juice.Period= 7;
extern int     Juice.Level = 4;
extern string  sep3="----------------";
extern bool    Use.Adx   = true;
extern int     Adx.TimeFrame   = 5;
extern int     Adx.Period   = 14;
extern int     Adx.Threshold   = 20;
extern bool    Use.Plus.Minus.DI   = true;
extern string  sep4="----------------";
extern int     Move.To.BreakEven.at.pips=20;
extern int     Move.To.BreakEven.Lock.pips=1;

int b.ticket, s.ticket, slip;
string DR, DR1;
double avg.rng, rng, sum.rng, x, Year.ADR, ADR.AddOn=1.40;
int t0c, t1c, t2c, t3c, t0p, t1p, t2p, t3p;
int f10c, f11c, f12c, f13c, f10p, f11p, f12p, f13p;
int f20c, f21c, f22c, f23c, f20p, f21p, f22p, f23p;

bool TradingEnabled, LongTradeEnabled, ShortTradeEnabled;
double ADXMain1, PlusDI1, MinusDI1, ADXMain2, PlusDI2, MinusDI2, CurrentJuice;


int init(){HideTestIndicators(true); slip=(Ask-Bid)/Point; return(0);}
int deinit(){return(0);}
int start(){

Mail();
Filter.Values();
Indicator.Values();
PosCounter();
Year.Avg.ADR();

if (Use.ADR.for.SL.pips?) {stoploss.pips=NormalizeDouble(Daily.Range()/Point,Digits);}
x=NormalizeDouble(Daily.Range()*tsl.divisor,Digits);


CheckForOrderClosing();                       // Check if conditions for closing any open order based on exit rules
TradingEnabled=CheckIfConditionsAllowEntry(); // Check if conditions for opening a new trade
                                              // returns 0 if no trading conditions according to filters and indicators
                                              // returns 1 if conditions for Long are met 
                                              // returns 2 if conditions for Short are met
if (TradingEnabled==1)
{  b.ticket=OrderSend(Symbol(),
      OP_BUY,
      LotCalc(),
      NormalizeDouble(Ask,Digits),
      slip,
      NormalizeDouble(Ask-Point*stoploss.pips,Digits),
      0,
      Period()+" min "+comment,
      Magic,0,Cyan);
      if(b.ticket>0)   
      {  if(OrderSelect(b.ticket,SELECT_BY_TICKET,MODE_TRADES))
         {  Print(b.ticket);   
         }
         else Print("Error Opening Buy Order: ",GetLastError());
         return(0);
      }
}
else if (TradingEnabled==2)
{  s.ticket=OrderSend(Symbol(),
      OP_SELL,
      LotCalc(),
      NormalizeDouble(Bid,Digits),
      slip,
      NormalizeDouble(Bid+Point*stoploss.pips,Digits),
      0,
      Period()+" min "+comment,
      Magic,0,Magenta);
      if(s.ticket>0)   
      {  if(OrderSelect(s.ticket,SELECT_BY_TICKET,MODE_TRADES))
         {  Print(s.ticket);
         }
         else Print("Error Opening Sell Order: ",GetLastError());
         return(0);
      }
}
if (Move.To.BreakEven.at.pips!=0) {{MoveToBreakEven();}  // Check if condition are met to move to breakeven
Trail.Stop();                                            // Check if we can trail our stops  
comments();
Mail();
return(0);}
}


//+------------------------------------------------------------------+
void Indicator.Values() 
{  t0c=iCustom(NULL,Trigger.Period, "FlatTrend V2", 3, 1); //LightGreen.
   t1c=iCustom(NULL,Trigger.Period, "FlatTrend V2", 1, 1); //Lime.
   t2c=iCustom(NULL,Trigger.Period, "FlatTrend V2", 2, 1); //Salmon.
   t3c=iCustom(NULL,Trigger.Period, "FlatTrend V2", 0, 1); //Red.

   t0p=iCustom(NULL,Trigger.Period, "FlatTrend V2", 3, 2); //LightGreen.
   t1p=iCustom(NULL,Trigger.Period, "FlatTrend V2", 1, 2); //Lime.
   t2p=iCustom(NULL,Trigger.Period, "FlatTrend V2", 2, 2); //Salmon.
   t3p=iCustom(NULL,Trigger.Period, "FlatTrend V2", 0, 2); //Red.

   f10c=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 3, 1); //LightGreen.
   f11c=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 1, 1); //Lime.
   f12c=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 2, 1); //Salmon.
   f13c=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 0, 1); //Red.

   f10p=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 3, 2); //LightGreen.
   f11p=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 1, 2); //Lime.
   f12p=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 2, 2); //Salmon.
   f13p=iCustom(NULL,Filter.Period.1, "FlatTrend V2", 0, 2); //Red.

   f20c=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 3, 1); //LightGreen.
   f21c=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 1, 1); //Lime.
   f22c=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 2, 1); //Salmon.
   f23c=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 0, 1); //Red.

   f20p=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 3, 2); //LightGreen.
   f21p=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 1, 2); //Lime.
   f22p=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 2, 2); //Salmon.
   f23p=iCustom(NULL,Filter.Period.2, "FlatTrend V2", 0, 2); //Red.
}

void Filter.Values()
{  ADXMain1=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MAIN,1);
   MinusDI1=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MINUSDI,1);
   PlusDI1 =iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_PLUSDI,1);
   ADXMain2=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MAIN,2);
   MinusDI2=iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_MINUSDI,2);
   PlusDI2 =iADX(NULL,Adx.TimeFrame,Adx.Period,PRICE_CLOSE,MODE_PLUSDI,2);
   CurrentJuice = Juice(1, Juice.Period, Juice.Level,Juice.TimeFrame);
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

double Year.Avg.ADR() 
{  if (DR1==TimeToStr(CurTime(),TIME_DATE)) 
   {  return(NormalizeDouble(Year.ADR,Digits));
   }
   Year.ADR=0;
   // Last 6 months ADR: 26 weeks = 26 x 5 trading days = 130 days + 'sunday' bars (they mess things up) ==> approx  150 daily bars
   for (int i=1;i<151;i++) 
   {  Year.ADR=+(iHigh(Symbol(),PERIOD_D1,i)-iLow(Symbol(),PERIOD_D1,i));
   }
   Year.ADR=(Year.ADR*ADR.AddOn)/150;
   DR1=TimeToStr(CurTime(),TIME_DATE);
   return (NormalizeDouble(Year.ADR,Digits));
}

void PosCounter() 
{  b.ticket=0;s.ticket=0;
   for (int cnt=0;cnt<=OrdersTotal();cnt++)   
   {  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()==Magic) 
      {  if (OrderType()==OP_SELL) {s.ticket=OrderTicket();}
         if (OrderType()==OP_BUY)  {b.ticket=OrderTicket();} 
      }
   }
}

double LotCalc() 
{  double lot;
   if (Use.Money.Management?)   
   {  //lot=AccountFreeMargin()*(MaximumRisk/Lot.Margin);
      lot=NormalizeDouble((AccountFreeMargin()*MaximumRisk)/(MarketInfo(Symbol(),MODE_TICKVALUE)*stoploss.pips),2);
   }
   if (!Use.Money.Management?) {lot=Minimum.Lot;}
   return(lot);
}

void comments()   {
if(MarketInfo(Symbol(),MODE_SWAPLONG)>0) string swap="longs.";
else swap="shorts.";
if(MarketInfo(Symbol(),MODE_SWAPLONG)<0 && MarketInfo(Symbol(),MODE_SWAPSHORT)<0) swap="your broker. :(";
Comment("Last Tick: ",TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS),"\n",
           //"Swap favors ",swap,"\n",
           "Average Daily Range: ",Daily.Range(),"\n",
           "Trailing Stop: ",x,"\n",
           "Open Long/Short Ticket #","\'","s: ",b.ticket," ",s.ticket,"  Profit: ",OrderProfit());  }

void Trail.Stop() 
{  PosCounter();
   //--Long TSL calc...
   //x=minimum wave range
   if(b.ticket>0) 
   {  double bsl=NormalizeDouble(x,Digits);double b.tsl=0;
      OrderSelect(b.ticket,SELECT_BY_TICKET);
      //if stoploss is less than minimum wave range, set bsl to current SL
      if(OrderStopLoss()<OrderOpenPrice() && OrderOpenPrice()-OrderStopLoss()<x) 
      {  bsl=OrderOpenPrice()-OrderStopLoss();
      }
      //if stoploss is equal to, or greater than minimum wave range, set bsl to minimum wave range
      if(OrderStopLoss()<OrderOpenPrice() && OrderOpenPrice()-OrderStopLoss()>=x) 
      {  bsl=NormalizeDouble(x,Digits);
      }
      //determine if stoploss should be modified
      if(Bid>(OrderOpenPrice()+bsl) && OrderStopLoss()<(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl))))   
      {  b.tsl=NormalizeDouble(OrderOpenPrice()+(Bid-(OrderOpenPrice()+bsl)),Digits);
         Print("b.tsl ",b.tsl);
         if(OrderStopLoss()<b.tsl)  
         {  OrderModify(b.ticket,OrderOpenPrice(),b.tsl,OrderTakeProfit(),OrderExpiration(),MediumSpringGreen);
         }
      }
   }
   //--Short TSL calc...
   if(s.ticket>0) 
   {  double ssl=NormalizeDouble(x,Digits);double s.tsl=0;
      OrderSelect(s.ticket,SELECT_BY_TICKET);
      //if stoploss is less than minimum wave range, set ssl to current SL
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
}//end Trail.Stop

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

//+------------------------------------------------------------------+
//| Juice (std deviation limit) indicator                            |
//| by Shimodax, based on  "Juice.mq4 by Perky"                      |
//| original link "http://fxovereasy.atspace.com/index"              |
//| Modified by MrPip to only calculate current value                |
//+------------------------------------------------------------------+
double Juice(int shift, int period, int level, int jtimeframe)
{  double osma= 0;
   osma= iStdDev(NULL,jtimeframe, period, MODE_EMA, 0, PRICE_CLOSE,shift) - level*Point;
   return (osma);
}

int CheckIfConditionsAllowEntry() // 0=no entry 1=ok for long 2=ok for short
{  bool FlatTrendIsOK;
   bool AdxIsOK;
   PosCounter(); // Check if current orders running.
   //General Conditions / Filtering
        if (!(b.ticket==0 && s.ticket==0))                                                                        return (0); // if a position is open, skip checking
   else if (Use.Trading.Hours.Restriction && (Hour()<Start.Trading.Hour.Begin || Hour()>Start.Trading.Hour.End))  return (0); // Check Time Filter
   else if (Use.Juice && CurrentJuice<=0)                                                                         return (0); // check Juice
   else if (Use.Adx && (!(ADXMain1>=ADXMain2 && ADXMain1>=Adx.Threshold)))                                        return (0); // Check Adx rising and above threshold
   
   // Conditions for Long
   FlatTrendIsOK=false;
   AdxIsOK=false;  
   // Check Star Trend
   if (!Use.Only.First2.Indicators && !Ignore.Light.Colors.For.Entry &&
         (  ((t2p==1 || t3p==1) && (t0c==1  || t1c==1)  && (f10c==1 || f11c==1) && (f20c==1 && f21c==1))  || 
            ((t0c==1 || t1c==1) && (f10c==1 || f11c==1) && (f22p==1 || f23p==1) && (f20c==1 || f21c==1))  || 
            ((t0c==1 || t1c==1) && (f12p==1 || f13p==1) && (f10c==1 || f11c==1) && (f20c==1 || f21c==1))
         )
       ) {FlatTrendIsOK=True;}
   else 
   if (!Use.Only.First2.Indicators && Ignore.Light.Colors.For.Entry &&
         (  (t3p==1 && t1c==1  && f11c==1 && f21c==1)  || 
            (t1c==1 && f11c==1 && f23p==1 && f21c==1)  || 
            (t1c==1 && f13p==1 && f11c==1 && f21c==1)
         )
       ) {FlatTrendIsOK=True;}
   else 
   if (Use.Only.First2.Indicators && !Ignore.Light.Colors.For.Entry &&
         (  ((t2p==1 || t3p==1) && (t0c==1  || t1c==1) && (f10c==1 || f11c==1))    || 
            ((t0c==1 || t1c==1) && (f10c==1 || f11c==1))                           || 
            ((t0c==1 || t1c==1) && (f12p==1 || f13p==1) && (f10c==1 || f11c==1))
         )
      ) {FlatTrendIsOK=True;}   
   else 
   if (Use.Only.First2.Indicators && Ignore.Light.Colors.For.Entry &&
         (  (t3p==1 && t1c==1 && f11c==1)    || 
            (t1c==1 && f11c==1)              || 
            (t1c==1 && f13p==1 && f11c==1)
         )
      ) {FlatTrendIsOK=True;}   


   // Check ADX
   if (!Use.Plus.Minus.DI || (Use.Plus.Minus.DI && PlusDI1>=MinusDI1 && PlusDI1>=PlusDI2)) {AdxIsOK=true;}
   // Check All Filters   
   if (FlatTrendIsOK && AdxIsOK) return(1);   
         
   
   // Conditions for Short
   FlatTrendIsOK=false;
   AdxIsOK=false;  
   // Check Star Trend
   if (!Use.Only.First2.Indicators && !Ignore.Light.Colors.For.Entry &&
         (  ((t0p==1 || t1p==1) && (t2c==1  || t3c==1)  && (f12c==1 || f13c==1) && (f22c==1 || f23c==1)) || 
            ((t2c==1 || t3c==1) && (f12c==1 || f13c==1) && (f20p==1 || f21p==1) && (f22c==1 || f23c==1)) ||
            ((t2c==1 || t3c==1) && (f10p==1 || f11p==1) && (f12c==1 || f13c==1) && (f22c==1 || f23c==1))
         )
      ) {FlatTrendIsOK=True;} 
   else 
   if (!Use.Only.First2.Indicators && Ignore.Light.Colors.For.Entry &&
         (  (t1p==1 && t3c==1  && f13c==1 && f23c==1)  || 
            (t3c==1 && f13c==1 && f21p==1 && f23c==1)  ||
            (t3c==1 && f11p==1 && f13c==1 && f23c==1)
         )
      ) {FlatTrendIsOK=True;} 
   else 
   if (Use.Only.First2.Indicators && !Ignore.Light.Colors.For.Entry &&
         (  ((t0p==1 || t1p==1) && (t2c==1  || t3c==1)  && (f12c==1 || f13c==1))  || 
            ((t2c==1 || t3c==1) && (f12c==1 || f13c==1))                          || 
            ((t2c==1 || t3c==1) && (f10p==1 || f11p==1) && (f12c==1 || f13c==1))
         )
      ) {FlatTrendIsOK=True;}
   else 
   if (Use.Only.First2.Indicators && Ignore.Light.Colors.For.Entry &&
         (  (t1p==1 && t3c==1  && f13c==1)  || 
            (t3c==1 && f13c==1)             || 
            (t3c==1 && f11p==1 && f13c==1)
         )
      ) {FlatTrendIsOK=True;}
   
   // Check ADX
   if ((!Use.Plus.Minus.DI) || (Use.Plus.Minus.DI && MinusDI1>=PlusDI1 && MinusDI1>=MinusDI2)) {AdxIsOK=true;}
   // Check All Filters   
   if (FlatTrendIsOK && AdxIsOK) return(2);   
   return(0);
}

void CheckForOrderClosing()
{  bool iShouldExit=false;
   PosCounter(); // Check if current orders running.
   iShouldExit=false;
   // Conditions for closing Longs
   if (b.ticket>0)
   {  if (!Ignore.Light.Colors.For.Exit && ((t2c==1 || t3c==1) && (t0p==1 || t1p==1))) {iShouldExit=true;} 
      else if (Ignore.Light.Colors.For.Exit && t3c==1 && t1p==1) {iShouldExit=true;} 
      if (iShouldExit) 
      {  OrderSelect(b.ticket,SELECT_BY_TICKET);
         OrderClose(OrderTicket(),OrderLots(),Bid,slip,Red);
      }
   }
   if (s.ticket>0)
   {  if (!Ignore.Light.Colors.For.Exit && ((t0c==1 || t1c==1) && (t2p==1 || t3p==1))) {iShouldExit=true;}
      else if (Ignore.Light.Colors.For.Exit && t1c==1 && t3p==1) {iShouldExit=true;}
      if (iShouldExit) 
      {  OrderSelect(s.ticket,SELECT_BY_TICKET);
         OrderClose(OrderTicket(),OrderLots(),Ask,slip,LightBlue);
      }
   }
}
         