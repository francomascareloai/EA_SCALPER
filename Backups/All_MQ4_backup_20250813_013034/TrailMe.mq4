//+-----------------------------------------------------------------------------+
//|                                                                 TrailMe.mq4 |
//|                                                    Copyright © 2006, Yannis |
//|                                                            jsfero@otenet.gr |
//|                  Special Thanks to Todd Geiger for the Ticket and ADR Code  |
//+-----------------------------------------------------------------------------+

//+----------------------User interface-----------------------------------------+
extern string  SL_TP_Trail_Options="--------------------------";
extern int     StopLoss.Pips=30;                                 // Initial s/l. Used by procedure CheckInitialSLTP if manual trade has no initial S/L.
                                                                 // Overridden after that if Use.Adr.for.sl.pips = true
extern int     TakeProfit.Pips=60;                               // Initial take profit - also used by CheckInitialSLTP if manual trade has no T/P
extern int     Trail.Pips=0;                                     // trail.pips. Unused if Use.Adr.for.sl.pips=true or if value=0
extern bool    Trail.Starts.After.BreakEven=false;               // if true trailing will start after a profit of "Move.To.BreakEven.at.pips" is made
extern int     Move.To.BreakEven.at.pips=0;                      // trades in profit will move to entry price + Move.To.BreakEven.Lock.pips as soon as trade is at entry price + Move.To.BreakEven.at.pips
extern int     Move.To.BreakEven.Lock.pips=1;
extern int     Move.Trail.Every.xx.Pips=0;                       // If > 0 then ALL other s/l are dropped and trail will only move by Trail.Pips amount for every "Move.Trail.Every.Pips" in profit
extern bool    Use.ADR.for.SL.pips=false;                        // if true s/l and trail according to average daily range and tsl.divisor
extern double  tsl.divisor=0.40;

//+---------------------- Global Variables Definition --------------------------------------+
int b.ticket, s.ticket,slip, TodaysRange;
string DR, DR1, comment=" TrailMe",ScreenComment="TrailMe";
double avg.rng, rng, sum.rng, x;
bool TradingEnabled, LongTradeEnabled, ShortTradeEnabled, ShortTradeShouldClose, LongTradeShouldClose;
double TPPrice;

int init()
{  slip=(Ask-Bid)/Point;
   return(0);
}

int deinit()
{  return(0);
}

int start()
{  x=NormalizeDouble(Daily.Range()*tsl.divisor,Digits);
   TodaysRange=MathAbs(iHigh(Symbol(),PERIOD_D1,0)-iLow(Symbol(),PERIOD_D1,0))/Point;

   if (Use.ADR.for.SL.pips)
   {  StopLoss.Pips=NormalizeDouble(Daily.Range()/Point,Digits);  // prepare S/L if it is based on daily average range
   }

   PosCounter          ();                                        // check for open positions. Sets b.ticket, s.ticket

   if (s.ticket>0 || b.ticket>0)
   {  CheckInitialSLTP    ();                                     // If no s/l t/p is defined in your manual entry,
                                                                  // then the defaults will be immediately entered

      if (Move.To.BreakEven.at.pips!=0) MoveToBreakEven();        // Check if must secure position

      Trail.Stop();                                               // Check trailing methods
   }

   comments();
   return(0);
}

void PosCounter()
{  b.ticket=0;s.ticket=0;
   for (int cnt=0;cnt<=OrdersTotal();cnt++)
   {  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol())
      {  if (OrderType()==OP_SELL)
         {  s.ticket=OrderTicket();
         }
         if (OrderType()==OP_BUY)
         {  b.ticket=OrderTicket();
         }
      }
   }
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

void CheckInitialSLTP()
{  int sl,tp;
   if (b.ticket>0)
   {  OrderSelect(b.ticket,SELECT_BY_TICKET);
      if (OrderStopLoss()==0 || OrderTakeProfit()==0)
      {  if (OrderStopLoss  ()==0)  {sl=StopLoss.Pips;}
         if (OrderTakeProfit()==0)  {tp=TakeProfit.Pips;}
         if ((sl>0 && OrderStopLoss()==0) || (tp>0 && OrderTakeProfit()==0))
         {  OrderModify(b.ticket, OrderOpenPrice(), OrderOpenPrice()-sl*Point,OrderOpenPrice()+tp*Point,OrderExpiration(),MediumSpringGreen);
            if (OrderSelect(b.ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Initial SL or TP is Set for Long Entry");
            else Print("Error setting initial SL or TP for Long Entry");
         }
      }
   }
   if (s.ticket > 0)
   {  OrderSelect(s.ticket,SELECT_BY_TICKET);
      if (OrderStopLoss()==0 || OrderTakeProfit()==0)
      {  if (OrderStopLoss  ()==0)  {sl=StopLoss.Pips;}
         if (OrderTakeProfit()==0)  {tp=TakeProfit.Pips;}
         if ((sl>0 && OrderStopLoss()==0) || (tp>0 && OrderTakeProfit()==0))
         {  OrderModify(s.ticket, OrderOpenPrice(), OrderOpenPrice()+sl*Point,OrderOpenPrice()-tp*Point,OrderExpiration(),MediumVioletRed);
            if (OrderSelect(s.ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("Initial SL or TP is Set for Short Entry");
            else Print("Error setting initial SL or TP for Short Entry");
         }
      }
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
   if (Move.To.BreakEven.at.pips>0) s1="s/l will move to b/e after: "+Move.To.BreakEven.at.pips+" pips   and lock: "+Move.To.BreakEven.Lock.pips+" pips"+"\n\n";
   else                             s1="";
   Comment( ScreenComment,"\n",
            "Today\'s Range: ",TodaysRange,"\n",
            "s/l: ",StopLoss.Pips,"  tp:",TakeProfit.Pips,"  trail:",Trail.Pips,"\n",
            s1
          );
}


