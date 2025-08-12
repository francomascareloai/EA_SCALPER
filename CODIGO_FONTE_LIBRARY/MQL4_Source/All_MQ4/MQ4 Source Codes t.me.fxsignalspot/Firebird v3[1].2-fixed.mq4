//+-----------------------------------------------------------------------------+
//|                          Firebird v3.2 - MA envelope exhaustion system |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Firebird calculates a X day SMA and then shifts it up and down X % to form a channel.
// For the calculation of this SMA either close (more trades) or Hi+Lo (safer trades) is used.
// When the price breaks a band a postion in the opposite of the current trend is taken.
// If the position goes against us we simply open an extra position to average.
// 50% of the trades last a day. 45% 2-6 days 5% longer or just fail.
//
//01010100 01110010 01100001 01100100 01100101 01110010 01010011 01100101 01110110 01100101 01101110 
// Credits fly to:
// Vooch for the backtesting fix.
// Hugues Du Bois for the multi currency code.
// Jackie Griffin for some debugging.
// Many people in the MT forum for testing and feedback
// Ron added [2006 03 08 (Mar 08)]
//   maxDrawDown and maxOrders to track DD and number of open orders 
//   Divergence to protect from trends

// Fixed By FiFtHeLeMeNt for crazy days on 5th day of months

//----------------------- USER INPUT
extern bool    UseEquityProtection = false; // Close all orders when negative Float is excessive.
extern double  FloatPercent   = 30;    // Percent of Balance for max Float level.
extern int     MA_length      = 10;    // Used in Moving Average iMA(). Number of periods to scan.
extern int     MA_timeframe   = 15;    // Timeframe reference for Moving Average iMA().
extern int     MAtype         = 0;     // 0=close, 1=High Low (0 is perferred setting).		 
extern double  Percent        = 0.1;   // Used to calculate iMA() channel (envelope) width.
int            TradeOnFriday  = 1;     // >0 trades on friday.
extern int     slip           = 100;   // exits only.
extern bool    UseMM          = 1;     // Money Management - 1 = true & 0 = false.
extern double  Risk           = 5;     // Percent of account equity to risk per trade.
extern double  Lots           = 0.1;  
extern double  TakeProfit     = 50;
extern double  Stoploss       = 300;
extern int     PipStep        = 40;    //if position goes this amount of pips against you add another.
extern double  TrailingStop   = 15;
extern int     MaxOpenOrders  = 5;     // Sets maximum number of open orders at same time.
extern double  MinMarginLevel = 250;   // Below this Minimum Margin Level percent % trading stops.
extern int     CloseDays      = 10;     // Number of days order is open before auto closing.
extern int     LossLevel      = 120;    // Loss amount before auto closing after CloseDays.
extern bool    UseHedge       = true;  // Places reverse order with PipStep order.
extern int     HedgeLotFactor = 3;     // Hedge order Lots will be increase by this factor.
extern int     HedgeTakeProfit= 30;
extern int     HedgeStoploss  = 300;
extern bool    AutoCal        = false; // True = iRSI() auto calculation of TakeProfit, StopLoss, PipStep

// Ron added for iFXAnalyzer
extern int     Fast_Period    = 23;
extern int     Fast_Price     = PRICE_OPEN;
extern int     Slow_Period    = 84;
extern int     Slow_Price     = PRICE_OPEN;
extern double  DivergenceLimit= 0.002;
extern bool    Use_V63D_Divergence = 1;   // 0 - Use original method for divergence, 1 - use in iFXAnalyzer
extern double IncreasementType = 0;//0=just add every PipStep,  >0 =OrdersToal()^x *Pipstep
extern bool    UseTradeScheduler = 1;

/*
Each "Trading Time" zone 1 through 4 has a Start and an End. 
To trade all day , set "day"...Start1=0 and "day"...End4=24. This is needed for each trading day.
To skip a full day, set "day"...Start1=0 and "day"...End4=0.
Note: EA is coded to use your Local PC Time.

Here is a Monday example. 

MonTradeHourStart1 = 0; - (Trading Time  zone 1 start)
MonTradeHourEnd1 = 8; - (Trading Time zone 1 end)   
MonTradeHourStart2 = 10; 
MonTradeHourEnd2 = 16;
MonTradeHourStart3 = 18; 
MonTradeHourEnd3 = 20;
MonTradeHourStart4 = 22; 
MonTradeHourEnd4 = 24; 

In above schedule, EA trades from 00:00 (midnight) to 08:00, then from 10:00 to 16:00, then from 18:00 to 20:00, then from 22:00 to 24:00.

Non-Trading Time is from 08:00 to 10:00, then from 16:00 to 18:00, then from 20:00 to 22:00.
*/

extern int SunTradeHourStart1 = 0; // 4 trading zones per day. To bypass a day, all zeros (=0)for that day.
extern int SunTradeHourEnd1 = 0; 
extern int SunTradeHourStart2 = 0; 
extern int SunTradeHourEnd2 = 0;
extern int SunTradeHourStart3 = 0; 
extern int SunTradeHourEnd3 = 0;
extern int SunTradeHourStart4 = 0; 
extern int SunTradeHourEnd4 = 24; 
extern int MonTradeHourStart1 = 0;
extern int MonTradeHourEnd1 = 0; 
extern int MonTradeHourStart2 = 0; 
extern int MonTradeHourEnd2 = 0;
extern int MonTradeHourStart3 = 0; 
extern int MonTradeHourEnd3 = 0;
extern int MonTradeHourStart4 = 0; 
extern int MonTradeHourEnd4 = 24;
extern int TueTradeHourStart1 = 0;
extern int TueTradeHourEnd1 = 0; 
extern int TueTradeHourStart2 = 0; 
extern int TueTradeHourEnd2 = 0;
extern int TueTradeHourStart3 = 0; 
extern int TueTradeHourEnd3 = 0;
extern int TueTradeHourStart4 = 0; 
extern int TueTradeHourEnd4 = 24;
extern int WedTradeHourStart1 = 0;
extern int WedTradeHourEnd1 = 0; 
extern int WedTradeHourStart2 = 0; 
extern int WedTradeHourEnd2 = 0;
extern int WedTradeHourStart3 = 0; 
extern int WedTradeHourEnd3 = 0;
extern int WedTradeHourStart4 = 0; 
extern int WedTradeHourEnd4 = 24;
extern int ThurTradeHourStart1 = 0;
extern int ThurTradeHourEnd1 = 0; 
extern int ThurTradeHourStart2 = 0; 
extern int ThurTradeHourEnd2 = 0;
extern int ThurTradeHourStart3 = 0; 
extern int ThurTradeHourEnd3 = 0;
extern int ThurTradeHourStart4 = 0; 
extern int ThurTradeHourEnd4 = 24;
extern int FriTradeHourStart1 = 0;
extern int FriTradeHourEnd1 = 0; 
extern int FriTradeHourStart2 = 0; 
extern int FriTradeHourEnd2 = 0;
extern int FriTradeHourStart3 = 0; 
extern int FriTradeHourEnd3 = 0;
extern int FriTradeHourStart4 = 0; 
extern int FriTradeHourEnd4 = 24;

double Stopper=0;
double KeepStopLoss=0;
double KeepAverage;
double dummy;
double spread=0;
double CurrentPipStep;
int    OrderWatcher=0;

// Ron Adds
int maxDD=0;
int maxOO=0;

extern int DVLimit = 10; // included by Renato
color clOpenBuy = DodgerBlue; // included by Renato
color clModiBuy = DodgerBlue; // included by Renato
color clCloseBuy = DodgerBlue; // included by Renato
color clOpenSell = Red; // included by Renato
color clModiSell = Red; // included by Renato
color clCloseSell = Red; // included by Renato
color clDelete = White; // included by Renato
string Name_Expert = "Firebird v3.2"; // included by Renato
string NameFileSound = "expert.wav"; // included by Renato
int MODE_DIV=0; // included by Renato
int MODE_SLOPE=1; // included by Renato
int MODE_ACEL=2; // included by Renato

extern int writelog = 0;

string text="";
double RVI0_RVI1     =0;

// MrPip adds
int MagicNumber;  // Made a global variable to aid in modularizing expert code
int Direction;    //1=long, 11=avoid long, 2=short, 22=avoid short
double LastPrice;
double PriceTarget;
double AveragePrice;

int iFXA=0;

int init() {
  LogWrite(Symbol()+",M"+Period());
}

//----------------------- MAIN PROGRAM LOOP
int start()
{
   int flag, retval, total, myTotal, value;
   
LogWrite(TimeToStr(TimeCurrent())+" - "+"Bid="+Bid);

MagicNumber=MagicfromSymbol(); 
Comment(MagicNumber);

//SetupGlobalVariables();



//         ====== Money Management for Lot Size routine ======  
  
   
    if(UseMM) 
      {
         Lots=AccountEquity()* Risk/100/1000;
         if( Lots>=0.1)
            {
               Lots=NormalizeDouble(Lots,1); 
            }
               else 
               Lots=NormalizeDouble(Lots,2);
      }

   if(MyOrdersTotal()>0)
      {
         Lots=Lots * MyOrdersTotal();
      }   
    
    double value1 = iATR(NULL,PERIOD_D1,21,0);
    if(AutoCal==True)
    {
      if(Point == 0.01)   value1 = value1*100;
      if(Point == 0.0001) value1 = value1*10000;
      TakeProfit = value1*2/10;
      Stoploss = value1*2;
      PipStep = value1/10;
   }       
   
//Comment("Percent=",Percent); // included by Renato

int OpeningDay;


//Ron Adds
double diverge;
if(AccountBalance()-AccountEquity() > maxDD) maxDD=AccountBalance()-AccountEquity();
if(MyOrdersTotal()>maxOO) maxOO=MyOrdersTotal(); //modified by Renato
diverge=divergence(Fast_Period,Slow_Period,Fast_Price,Slow_Price,0);
Comment("maxDrawDown = ",maxDD,"\nOpen Orders = ",MyOrdersTotal(),"   Total Orders = ",OrdersTotal(),
"\nRVI = ",RVI0_RVI1,"\n",text);

text="";

//----------------------- CALCULATE THE NEW PIPSTEP
CurrentPipStep=PipStep;
if(IncreasementType>0)
  {
  CurrentPipStep=MathSqrt(MyOrdersTotal())*PipStep; // modified by Renato
  CurrentPipStep=MathPow(MyOrdersTotal(),IncreasementType)*PipStep; // modified by Renato
  } 
LogWrite("CurrentPipStep="+CurrentPipStep);

//----------------------- 
 Direction=0;//1=long, 11=avoid long, 2=short, 22=avoid short
if (DayOfWeek()!=5 || TradeOnFriday >0)
{
   total=OrdersTotal(); 
   myTotal = MyOrdersTotal();
   LogWrite("OrdersTotal="+total);
   LogWrite("MyOrdersTotal="+myTotal);
   if(myTotal==0) OpeningDay=DayOfYear(); // modified by Renato
   
   if (myTotal > 0)
    LastPrice = GetPreviousOpenPrice();
   else
    
          
LogWrite("LastPrice="+LastPrice);

flag = CheckJustClosedOrder();

if(flag!=1) 
{   
   
//----------------------- PREVIOUS OPEN PRICE

OrderWatcher=0;
LastPrice = GetPreviousOpenPrice();

LogWrite("LastPrice="+LastPrice);

//Print("ordersymbol = ", OrderSymbol(), " OrderOpenPrice= ", DoubleToStr(OrderOpenPrice(), 10), " lastprice= ",DoubleToStr(LastPrice, 10 ));
iFXA=0;
// Ron added divergence check
if(MathAbs(diverge)<=DivergenceLimit) {


if ( (iFXAnalyser(0,MODE_DIV,0)>DVLimit*Point
      && iFXAnalyser(0,MODE_SLOPE,0)>0 ) ) { iFXA=1; text="trending market up!";} else {// included by Renato
}

if (  (iFXAnalyser(0,MODE_DIV,0)<-DVLimit*Point
      && iFXAnalyser(0,MODE_SLOPE,0)<0 ) ) { iFXA=-1; text="trending market down!";} else {// included by Renato
}

//----------------------- ENTER POSITION BASED ON OPEN
if(MAtype==0)
{
  retval = EnterPositionBasedOnOpen();
  if (retval == 1)   // Opened Short position
  {
      OrderWatcher=1;
      Direction=2;
  }
  if (retval == 2)   // Opened Long Position
  {
      OrderWatcher=1;
      Direction=1;
  }
  
}
   
        
//----------------------- ENTER POSITION BASED ON HIGH/LOW
if(MAtype==1)
{
  retval = EnterPositionBasedOnHL();
  if (retval == 1)
  {
      OrderWatcher=1;
      Direction=2;
  }
  if (retval == 2)
  {
      OrderWatcher=1;
      Direction=1;
  }
}

} // included by Ron
} // end of flag test                  
//----------------------- CALCULATE AVERAGE OPENING PRICE 

myTotal = MyOrdersTotal();

if (myTotal>0 && OrderWatcher==1)
{

   AveragePrice = CalculateAverageOpeningPrice(myTotal);
   Comment("AveragePrice: ",AveragePrice,"  myTotal: ",myTotal); // modified by Renato 
}

//----------------------- IF NEEDED CHANGE ALL OPEN ORDERS TO THE NEWLY CALCULATED PROFIT TARGET    
if(OrderWatcher==1 && myTotal>1)// check if average has really changed
  { 
    ChangeOpenOrders(false, myTotal, AveragePrice);
  }
//----------------------- KEEP TRACK OF STOPLOSS TO AVOID RUNAWAY MARKETS
    
if (myTotal > 0) KeepTrackOfStopLoss(AveragePrice);
  
}
}


// Modules moved using cut/paste and modified by MrPip

double GetPreviousOpenPrice()
{
   int cnt;
   double LstPrice;
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--){
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
//   Print("ordersymbol = ", OrderSymbol(), " OrderOpenPrice= ", DoubleToStr(OrderOpenPrice(), 10));
      if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) && (OrderComment()==GetCommentForOrder()) )  // hdb - only symbol and magic  // modified by Renato
      {
           LstPrice=OrderOpenPrice();
//           Comment("LastPrice= ",DoubleToStr(LastPrice, 10));
//           Print("cnt= ", cnt, " ordersymbol = ", OrderSymbol(), " OrderOpenPrice= ", DoubleToStr(OrderOpenPrice(), 10), " lastprice= ",DoubleToStr(LastPrice, 10 ));
           break;
      } 
   }
   return(LstPrice);
}

/////////////////////////////////////////////////////////////////////////////////////////
// BACKTESTER FIX:  DO NOT PLACE AN ORDER IF WE JUST CLOSED
// AN ORDER WITHIN Period() MINUTES AGO
/////////////////////////////////////////////////////////////////////////////////////////
int CheckJustClosedOrder()
{
int cnt;
datetime orderclosetime;
string   rightnow;
int      rightnow2;
int      TheHistoryTotal=HistoryTotal();
int      difference;
int      flag=0;
   for(cnt=0;cnt<TheHistoryTotal;cnt++) 
    {
    if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)==true)
       {
        if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) && (OrderComment()==GetCommentForOrder()) )       // hdb - only symbol and magic  // modified by Renato
            {
               orderclosetime=OrderCloseTime();
               rightnow=Year()+"-"+Month()+"-"+Day()+" "+Hour()+":"+Minute()+":"+Seconds();
               rightnow2=StrToTime(rightnow);
               difference=rightnow2-orderclosetime;
               if(Period()*60*2>difference) 
                  { // At least 2 periods away!
                   flag=1;   // Throw a flag
                   break;
                  }
              }
         }
     }
     return(flag);
}



//----------------------- ENTER POSITION BASED ON OPEN
int EnterPositionBasedOnOpen()
{
   int ret;
   double myMA =iMA(NULL,MA_timeframe,MA_length,0,MODE_SMA,PRICE_OPEN,0);
   double RVI=iRVI(NULL,0,10,MODE_MAIN,0)-iRVI(NULL,0,10,MODE_MAIN,1); // included by Renato
   RVI0_RVI1=RVI;
//   Print(" Top, Bid ",myMA*(1+Percent/100),"  ",Bid);
//   if((myMA*(1+Percent/100))<Bid) Print(" Top, Bid ",myMA*(1+Percent/100),"  ",Bid);
   
   CloseTheseTrades();
   if(UseEquityProtection) EquityProtection();
   
   if(MyOrdersTotal()<MaxOpenOrders && AccountEquity()/(AccountMargin()+0.0001)>(MinMarginLevel/100))
   {
      int h=TimeHour(TimeLocal());
      int trade=0;
      trade=0;
      

      if(UseTradeScheduler==true)
         {
        if( (DayOfWeek()==0 && ((h >= SunTradeHourStart1) && (h <= (SunTradeHourEnd1-1))) || ((h >= SunTradeHourStart2) && (h <= (SunTradeHourEnd2-1))) || ((h >= SunTradeHourStart3) && (h <=(SunTradeHourEnd3-1))) || ((h >= SunTradeHourStart4) && (h <= (SunTradeHourEnd4-1)))) || 
            (DayOfWeek()==1 && ((h >= MonTradeHourStart1) && (h <= (MonTradeHourEnd1-1))) || ((h >= MonTradeHourStart2) && (h <= (MonTradeHourEnd2-1))) || ((h >= MonTradeHourStart3) && (h <=(MonTradeHourEnd3-1))) || ((h >= MonTradeHourStart4) && (h <= (MonTradeHourEnd4-1)))) || 
            (DayOfWeek()==2 && ((h >= TueTradeHourStart1) && (h <= (TueTradeHourEnd1-1))) || ((h >= TueTradeHourStart2) && (h <= (TueTradeHourEnd2-1))) || ((h >= TueTradeHourStart3) && (h <=(TueTradeHourEnd3-1))) || ((h >= TueTradeHourStart4) && (h <= (TueTradeHourEnd4-1)))) || 
            (DayOfWeek()==3 && ((h >= WedTradeHourStart1) && (h <= (WedTradeHourEnd1-1))) || ((h >= WedTradeHourStart2) && (h <= (WedTradeHourEnd2-1))) || ((h >= WedTradeHourStart3) && (h <=(WedTradeHourEnd3-1))) || ((h >= WedTradeHourStart4) && (h <= (WedTradeHourEnd4-1)))) || 
            (DayOfWeek()==4 && ((h >= ThurTradeHourStart1) && (h <= (ThurTradeHourEnd1-1))) || ((h >= ThurTradeHourStart2) && (h <= (ThurTradeHourEnd2-1))) || ((h >= ThurTradeHourStart3) && (h <=(ThurTradeHourEnd3-1))) || ((h >= ThurTradeHourStart4) && (h <= (ThurTradeHourEnd4-1)))) || 
            (DayOfWeek()==5 && ((h >= FriTradeHourStart1) && (h <= (FriTradeHourEnd1-1))) || ((h >= FriTradeHourStart2) && (h <= (FriTradeHourEnd2-1))) || ((h >= FriTradeHourStart3) && (h <=(FriTradeHourEnd3-1))) || ((h >= FriTradeHourStart4) && (h <= (FriTradeHourEnd4-1))))) 
          {
            trade=1;
          }
        } 
      if(UseTradeScheduler==false) trade=1;  
      if(trade==0)text="Non-Trading Time";

   // Go SHORT -> Only sell if >= 30 pips above previous position entry 
   if( trade==1 && (myMA*(1+Percent/100))<Bid && Direction!=22 && (Bid>=(LastPrice+(CurrentPipStep*Point)) || MyOrdersTotal()==0) && RVI<0 && iFXA==0 ) // modified by Renato
 	  {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),GetCommentForOrder(),MagicNumber,0,clOpenSell);  // modified by Renato
      ret = 1;
      if(UseHedge==true && MyOrdersTotal()>=2 && MyOrdersTotal()<MaxOpenOrders && ret==1)
         {  
            OrderSend(Symbol(),OP_BUY,Lots*HedgeLotFactor,Ask,slip,Ask-HedgeStoploss*Point,Ask+HedgeTakeProfit*Point,GetCommentForOrder(),MagicNumber,0,clOpenBuy);
         }
      
      PlaySound("ricochet.wav");
     }   
   if( trade==1 && (myMA*(1-Percent/100))>Ask && Direction!=11 && (Ask<=(LastPrice-(CurrentPipStep*Point)) || MyOrdersTotal()==0) && RVI>0 && iFXA==0) // Go LONG -> Only buy if >= 30 pips below previous position entry // modified by Renato
     {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),GetCommentForOrder(),MagicNumber,0,clOpenBuy);  // modified by Renato
      ret = 2;
      if(UseHedge==true && MyOrdersTotal()>=2 && MyOrdersTotal()<MaxOpenOrders && ret==2)
         {
            OrderSend(Symbol(),OP_SELL,Lots*HedgeLotFactor,Bid,slip,Bid+HedgeStoploss*Point,Bid-HedgeTakeProfit*Point,GetCommentForOrder(),MagicNumber,0,clOpenSell);
         }
      
      PlaySound("ricochet.wav");
     }
    } 
     
     
//=============== TRAILING STOP ROUTINE
       
   int cnt, total;
   total=OrdersTotal(); 
   for(cnt=0;cnt<total;cnt++)
      {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) && (OrderComment()==GetCommentForOrder()) )
         {
         if(OrderType() == OP_BUY)
            {
            if(TrailingStop > 0)
               {
               if((Bid-OrderOpenPrice()) > (Point*TrailingStop))
                  {
                  if((OrderStopLoss()) < (Bid-Point*TrailingStop))
                     {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(Point*5),OrderTakeProfit(),0,GreenYellow);
                     return(0);
                     }
                  } 
               }                  
             }

            if(OrderType() == OP_SELL)
               {
               if(TrailingStop > 0)
                  {
                  if(OrderOpenPrice()-Ask>Point*TrailingStop)
                     {
                     if(OrderStopLoss()>Ask+Point*TrailingStop)
                        {
                        OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(Point*5),OrderTakeProfit(),0,Red);
                        return(0);              
                        }
                     }     
                  }
                }
             }
          }
     return(ret); 
}


//----------------------- ENTER POSITION BASED ON HIGH/LOW
int EnterPositionBasedOnHL()
{
   int ret;
   if((iMA(NULL,MA_timeframe,MA_length,0,MODE_SMA,PRICE_HIGH,0)*(1+Percent/100))<Bid && Direction!=22 && (Bid>=(LastPrice+(CurrentPipStep*Point)) || MyOrdersTotal()==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	// modified by Renato
 	     {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),GetCommentForOrder(),MagicNumber,0,clOpenSell);  // modified by Renato
      ret = 1;
      PlaySound("ricochet.wav");
     }   
   if((iMA(NULL,MA_timeframe,MA_length,0,MODE_SMA,PRICE_LOW,0)*(1-Percent/100))>Ask && Direction!=11 && (Ask<=(LastPrice-(CurrentPipStep*Point)) || MyOrdersTotal()==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 // modified by Renato
        {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),GetCommentForOrder(),MagicNumber,0,clOpenBuy);  // modified by Renato
      ret = 2;
      PlaySound("ricochet.wav");
     }
     return(ret); 
} 

 

//----------------------- CALCULATE AVERAGE OPENING PRICE 
double CalculateAverageOpeningPrice(int myTot)
{
   int cnt;
   double AvePrice;

   AvePrice=0;  

     for(cnt=OrdersTotal() - 1;cnt>=0;cnt--)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

       if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) && (OrderComment()==GetCommentForOrder()) )  // hdb - only symbol and magic // modified by Renato
        {
          AvePrice=AvePrice+OrderOpenPrice();
        }
     }
   AvePrice=AvePrice/MathMax(myTot,1);        // hdb myTotal
   return(AvePrice);
}



//----------------------- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE
//----------------------- IF NEEDED CHANGE ALL OPEN ORDERS TO THE NEWLY CALCULATED PROFIT TARGET    
void ChangeOpenOrders(bool ChangeIt, int myTot, double AvePrice)
{
   int cnt, total;
   
   total=OrdersTotal(); 
   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);  
      if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) && (OrderComment()==GetCommentForOrder()) )  // hdb - only symbol and magic // modified by Renato
      {
         if(OrderType()==OP_BUY )  // Calculate profit/stop target for long // modified by Renato
         {
           PriceTarget=AvePrice+(TakeProfit*Point);
           Stopper=AvePrice-(((Stoploss*Point)/myTot)); 
         }
         if(OrderType()==OP_SELL ) // Calculate profit/stop target for short // modified by Renato
         {
           PriceTarget=AvePrice-(TakeProfit*Point);
           Stopper=AvePrice+(((Stoploss*Point)/myTot)); 
         }
         if (ChangeIt) OrderModify(OrderTicket(),0,Stopper,PriceTarget,0,Yellow);//set all positions to averaged levels
      } 
   }
}

//----------------------- KEEP TRACK OF STOPLOSS TO AVOID RUNAWAY MARKETS
// Sometimes the market keeps trending so strongly the system never reaches it's target.
// This means huge drawdown. After stopping out it falls in the same trap over and over.
// The code below avoids this by only accepting a signal in teh opposite direction after a SL was hit.
// After that all signals are taken again. Luckily this seems to happen rarely. 
void KeepTrackOfStopLoss(double AvePrice)
{
   int myOrderType, total, cnt;
   
   myOrderType = -1;                // hdb
   total=OrdersTotal(); 
   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);            
      if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) && (OrderComment()==GetCommentForOrder()) )  // hdb - only symbol and magic // modified by Renato
      {
         KeepStopLoss=OrderStopLoss();
         myOrderType = OrderType();           // hdb - keep order type   
      }
   }
   
   KeepAverage=AvePrice;
   Direction =0;
   if(myOrderType==OP_BUY) 
      { Direction=1;  } //long 
     else 
      { if (myOrderType==OP_SELL) Direction=2;  }//short

   if(KeepStopLoss!=0)
   {
     spread=MathAbs(KeepAverage-KeepStopLoss)/2;
     dummy=(Bid+Ask)/2;
     if (KeepStopLoss<(dummy+spread) && KeepStopLoss>(dummy-spread))
     {
     // a stoploss was hit
        if(Direction==1) Direction=11;// no more longs
        if(Direction==2) Direction=22;// no more shorts
     }
     KeepStopLoss=0;
   }
}


int MagicfromSymbol() { // included by Renato 
   int MagicNumber=0;  
   for (int i=0; i<5; i++) {  
      MagicNumber=MagicNumber*3+StringGetChar(Symbol(),i);  
   }  
   MagicNumber=MagicNumber*3+Period();  
   return(MagicNumber);  
}  



void CloseTheseTrades() { // included by Renato
   for (int i=0; i<OrdersTotal(); i++) {  
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {  
         if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicfromSymbol()) && (OrderComment()==GetCommentForOrder()) ) {  
            if (OrderType()==OP_BUY)  
               if ( TimeCurrent()-OrderOpenTime()>= ( CloseDays * 24 * 3600)  && OrderProfit()< -LossLevel )  
                 OrderClose(OrderTicket(),OrderLots(),Bid,GetSlippage(),clCloseBuy); 
            if (OrderType()==OP_SELL)  
               if ( TimeCurrent()-OrderOpenTime()>= ( CloseDays * 24 * 3600)  && OrderProfit()< -LossLevel )  
                 OrderClose(OrderTicket(),OrderLots(),Ask,GetSlippage(),clCloseSell); 
         } 
      } 
   } 
} 

void EquityProtection() { // included by Renato
   for (int i=0; i<OrdersTotal(); i++) {  
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {  
         if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicfromSymbol()) && (OrderComment()==GetCommentForOrder()) ) {  
            if (OrderType()==OP_BUY)  
               if ( AccountBalance() - AccountEquity() >= AccountBalance() * FloatPercent/100 )  
                 OrderClose(OrderTicket(),OrderLots(),Bid,GetSlippage(),clCloseBuy); 
            if (OrderType()==OP_SELL)  
               if ( AccountBalance() - AccountEquity() >= AccountBalance() * FloatPercent/100 )  
                 OrderClose(OrderTicket(),OrderLots(),Ask,GetSlippage(),clCloseSell); 
         } 
      } 
   } 
} 

double iFXAnalyser(int FXA_Period, int mode, int shift)// Made local function by MrPip
{
  double ind_buffer0, ind_buffer1, ind_buffer2;
 
   switch(mode)
   {
// MODE_DIV
      case 0 : ind_buffer0=iMA(NULL,FXA_Period,Fast_Period,0,MODE_SMA,Fast_Price,shift)
                          -iMA(NULL,FXA_Period,Slow_Period,0,MODE_SMA,Slow_Price,shift);
                     return (ind_buffer0);
                     break;

//---- Shaun's Slope counted in the 2-nd buffer
// MODE_SLOPE
      case 1 : ind_buffer1=(iMA(NULL,FXA_Period,Fast_Period,0,MODE_SMA,Fast_Price,shift)
                           -iMA(NULL,FXA_Period,Slow_Period,0,MODE_SMA,Slow_Price,shift))
                           -(iMA(NULL,FXA_Period,Fast_Period,0,MODE_SMA,Fast_Price,shift+1)
                            -iMA(NULL,FXA_Period,Slow_Period,0,MODE_SMA,Slow_Price,shift+1));
                       return (ind_buffer1);
                       break;
                       
//---- Shaun's Slope of Slope counted in the 3-3d buffer
// MODE_ACEL
      case 2 : ind_buffer2=((iMA(NULL,FXA_Period,Fast_Period,0,MODE_SMA,Fast_Price,shift)
                            -iMA(NULL,FXA_Period,Slow_Period,0,MODE_SMA,Slow_Price,shift))
                           -(iMA(NULL,FXA_Period,Fast_Period,0,MODE_SMA,Fast_Price,shift+1)
                            -iMA(NULL,FXA_Period,Slow_Period,0,MODE_SMA,Slow_Price,shift+1))
                           -(iMA(NULL,FXA_Period,Fast_Period,0,MODE_SMA,Fast_Price,shift+1)
                            -iMA(NULL,FXA_Period,Slow_Period,0,MODE_SMA,Slow_Price,shift+1))
                           -(iMA(NULL,FXA_Period,Fast_Period,0,MODE_SMA,Fast_Price,shift+2)
                            -iMA(NULL,FXA_Period,Slow_Period,0,MODE_SMA,Slow_Price,shift+2)));
                        return (ind_buffer2);
                        break;
       }
}

// Ron added for divergence filter
double divergence(int F_Period, int S_Period, int F_Price, int S_Price, int mypos)
  {
   int i;
   double maF1, maF2, maS1, maS2;
   double dv1, dv2;
   maF1=iMA(Symbol(),0,F_Period,0,MODE_SMA,F_Price,mypos);
   maS1=iMA(Symbol(),0,S_Period,0,MODE_SMA,S_Price,mypos);
   dv1=maF1-maS1;
   maF2=iMA(Symbol(),0,F_Period,0,MODE_SMA,F_Price,mypos+1);
   maS2=iMA(Symbol(),0,S_Period,0,MODE_SMA,S_Price,mypos+1);
   if (Use_V63D_Divergence)
      {
         dv2=((maF1-maS1)-(maF2-maS2));
      }
         else
   {
      dv2=maF2-maS2;
   }
   if ((Symbol()=="EURJPY") || (Symbol()=="EURJPYm") || // FIXED BY SKYLINE ON 11 Aug 2006
      (Symbol()=="USDJPY")  || (Symbol()=="USDJPYm") ||
      (Symbol()=="CHFJPY")  || (Symbol()=="CHFJPYm") ||
      (Symbol()=="AUDJPY")  || (Symbol()=="AUDJPYm") ||     
      (Symbol()=="CADJPY")  || (Symbol()=="CADJPYm") ||
      (Symbol()=="NZDJPY")  || (Symbol()=="NZDJPYm") ||
      (Symbol()=="GBPJPY")  || (Symbol()=="GBPJPYm") ||
      (Symbol()=="SGDJPY")  || (Symbol()=="SGDJPYm"))           
    {
      return((dv1-dv2)/100);
    } 
      else 
    {
      return(dv1-dv2);
    } 
  }

void LogWrite(string content) {
  if (writelog==1) {
    int handle = FileOpen(Name_Expert+".log",FILE_CSV|FILE_WRITE,";");  
    FileSeek(handle,0,SEEK_END);
    FileWrite(handle,content);  
    FileFlush(handle);
    FileClose(handle); 
  }
}

int MyOrdersTotal() { // included by Renato
   int Mytotal=0; 
   for (int i=0; i<OrdersTotal(); i++) { 
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
       if ( (OrderSymbol()==Symbol()) ) 
          Mytotal++; 
   }  
   return(Mytotal); 
} 

string GetCommentForOrder() { return(Name_Expert); }  // included by Renato
//double GetSizeLot() { return(Lots);}  // included by Renato
double GetSlippage() { return((Ask-Bid)/Point); } // included by Renato

//----------------------- TO DO LIST
// 1st days profit target is the 30 pip line *not* 30 pips below average as usually. -----> Day()
// Trailing stop -> trailing or S/R or pivot target
// Realistic stop loss
// Avoid overly big positions
// EUR/USD  30 pips / use same value as CurrentPipStep
// GBP/CHF  50 pips / use same value as CurrentPipStep 
// USD/CAD  35 pips / use same value as CurrentPipStep 

//----------------------- OBSERVATIONS
// GBPUSD not suited for this system due to not reversing exhaustions. Maybe use other types of MA
// EURGBP often sharp reversals-> good for trailing stops?
// EURJPY deep pockets needed.