//+-----------------------------------------------------------------------------+
//|                                                           NY breakout v0.10 |
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
//----------------------- TODO
// Test other pairs and timeframes.
// Trailing stop
  
extern int Trading_Hour = 1;
extern int Setup_valid_for_X_minutes = 50;// Between 15 and 59 mintes.
if(Setup_valid_for_X_minutes>59) Setup_valid_for_X_minutes=59;
if(Setup_valid_for_X_minutes<15) Setup_valid_for_X_minutes=15;
extern int TakeProfit = 40;
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
    OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Ask-Low[1],Ask+(TakeProfit*Point),0,0,Blue);
    OpenOrderFlag=true;
    }
  
  if(Bid<=Low[1] && OpenOrderFlag==false)
    { // Go short and set profit target and stoploss
    OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid+High[1],Bid-(TakeProfit*Point),0,0,Red);
    OpenOrderFlag=true;
    }  
  }
  if(h!=Trading_Hour) OpenOrderFlag=false;

//---------------------- CALCULATE FORCED CLOSING TIME/DATE
int days =Force_Close_after_X_hours/24; //number of whole days the position is allowed to stay open.
int hours = Force_Close_after_X_hours-days*24; // remaining hours.
if(Trading_Hour+hours>=24) // move overflowing hours to days.
  {
  days = days+1;
  hours= hours-24;
  }
//days+huidige dag v/h jaar
//check nieuwjaar
//setup exact closing date/time
  
//----------------------- FORCE CLOSING OPEN/PENDING TRADES  
}