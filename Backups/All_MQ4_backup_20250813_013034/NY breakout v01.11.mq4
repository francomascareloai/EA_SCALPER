//+-----------------------------------------------------------------------------+
//|                                                           NY breakout v0.11 |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Run on EUR/USD H1 
// At a certain time a small breakout often occurs.
//
//----------------------- HISTORY
// v0.10 Initial release.
// v0.11 Bug fixed. Stoploss added.
//----------------------- TODO
// Test other pairs and timeframes.
// Trailing stop
// Allow only 1 open trade!!!!!!!!!
  
extern int Trading_Hour = 1;
extern int Setup_valid_for_X_minutes = 50;// Between 15 and 59 mintes.
if(Setup_valid_for_X_minutes>59) Setup_valid_for_X_minutes=59;
if(Setup_valid_for_X_minutes<15) Setup_valid_for_X_minutes=15;
extern int TakeProfit = 40;
extern int Stoploss_pips_outside_bar =1; // put stoploss at High[1]+X and Low[1]-X
extern int Force_Close_after_X_hours =99;
extern double Lots=1;
extern int Slippage=3;
bool OpenOrderFlag=false;
//----------------------- MAIN PROGRAM LOOP
int start()
{ 
int h=TimeHour(CurTime());
int m=TimeMinute(CurTime());
if(Trading_Hour==h && m<=Setup_valid_for_X_minutes && OpenOrderFlag==false) //Within trading bar
  {
  if(Ask>=High[1] && OpenOrderFlag==false)
    { // Go long and set profit target and stoploss
    OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Low[1]-Stoploss_pips_outside_bar*Point,Ask+(TakeProfit*Point),0,0,Blue);
    OpenOrderFlag=true;
    }
  
  if(Bid<=Low[1] && OpenOrderFlag==false)
    { // Go short and set profit target and stoploss
    OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,High[1]+Stoploss_pips_outside_bar*Point,Bid-(TakeProfit*Point),0,0,Red);
    OpenOrderFlag=true;
    }  
  }
  if(h!=Trading_Hour) OpenOrderFlag=false;

//---------------------- CALCULATE FORCED CLOSING TIME/DATE
int days =Force_Close_after_X_hours/24; //number of whole days the position is allowed to stay open.
int Closing_Hour = Force_Close_after_X_hours-days*24; // remaining hours.
if(Trading_Hour+Closing_Hour>=24) // move overflowing hours to days.
  {
  days = days+1;
  Closing_Hour= Closing_Hour-24;
  }
int CloseDay=days+DayOfYear();
int CloseYear=Year();
if(CloseDay>364)
  {
  CloseYear=CloseYear+1;
  CloseDay=CloseDay-364;
  }
int CloseTime=Closing_Hour;

//----------------------- FORCE CLOSING OPEN/PENDING TRADES 

// Get date info from pending open OrderSelect
// What about multiple open orders?
 
}