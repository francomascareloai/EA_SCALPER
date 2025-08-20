//+-----------------------------------------------------------------------------+
//|                                               EURUSD session breakout v0.26 |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven/Matt Kennel"
#property link      "TraderSeven@gmx.net"
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Run on EUR/USD M15 
// If there was a small range during the EU session then there is a trading opportunity during the US session.
//All time are chart times.
//----------------------- HISTORY
// v0.10 Initial release.
// v0.20 Debugging and additional code by Matt Kennel ("Doctor Chaos").
// v0.25 Made EA more optimizeble and (hopefully) improved readabilty. Avoid NFP days. Added on screen comments.
// v0.26 Some minor stuff and added a pip filter to reduce bad trades.
//----------------------- TODO
// Lots of testing and optimizing
// The logic of the EA needs to be checked against the original idea.
// Trailing stop.
// Only allow the EA to work on M15 charts.
// Fix bug: Doesn't always close trades at end of session. (Only on backtesting?)
// Fix bug: Sometimes closes a trade instantly after it was opened. (Only on backtesting?)
  
extern int US_session_start_hour = 13;
extern int Range_lookback_hours = 6;
extern int Close_position_after_hours = 3;
extern int Max_Range_during_lookback_hours = 35; 
extern int Pip_filter=10;
extern bool Trade_on_Monday = false;
extern int TakeProfit=55;
extern int Stoploss=20;
extern int Slippage=3;
extern double Lots=1;
//----------------------- MAIN PROGRAM LOOP
int start()
{
static double TopRange,LowRange;
static bool bought,sold,smallsession,sessionfound;  
// static variables will be retained over calls. 

if (Hour() ==0) {
      //reset for a new day at midnight. 
      TopRange = 0;
      LowRange = 0;
      bought = false; // we allow only one buy and one sell per day. 
      sold = false; 
      sessionfound = false; 
}

bool TradeDayOK = (DayOfWeek() >= 1) && (DayOfWeek() <= 5); // M-F, not sat or sun.
if ((DayOfWeek() == 1) && (Trade_on_Monday==false)) TradeDayOK = false; 
if(DayOfWeek()==4 && Day()<8)TradeDayOK = false; //Avoid NFP days, first thursday in any month.
if(TradeDayOK == false) Comment("No trading today. (Weekend, Monday, NFP day)"); 
if(TradeDayOK) {
   if ((sessionfound == false) && (Hour() == US_session_start_hour)) {
     // first time through, compute EU session highs and lows.
     TopRange=High[Highest(NULL,0,MODE_HIGH,Range_lookback_hours*4,1)]; // Range_lookback_hours*4 M15 bars during EU session
     LowRange=Low[Lowest(NULL,0,MODE_LOW,Range_lookback_hours*4,1)];  // Range_lookback_hours*4 M15 bars during EU session
     if ((TopRange-LowRange) <= Max_Range_during_lookback_hours*Point) 
       smallsession = true;
      else
      {
       smallsession = false; 
       Comment("No trading today because EU session range was to big.");
      }
   
     sessionfound = true;
     Print("Identified new EU session + ["+LowRange+","+TopRange+"]"+" DayOfYear()="+DayOfYear()+" small? "+smallsession); 
   }    
      
        
   if(sessionfound && smallsession && (Hour()>=US_session_start_hour) && (Hour()<US_session_start_hour+Close_position_after_hours)) // Within US session hours?
    {
    Comment("Now trading in US session until ",US_session_start_hour+Close_position_after_hours,":00 chart time. EU session range was ",(TopRange-LowRange)/Point);
  //  Print("Am in US session... smallsession, bought, sold = " + smallsession+bought+sold); 
  //  Print("TopRange = "+ TopRange + "LowRange = " + LowRange); 
    int h=TimeHour(CurTime());
    int m=TimeMinute(CurTime());
    
    if(((h==US_session_start_hour && m>14)|| h>US_session_start_hour) && h<(US_session_start_hour+Close_position_after_hours)) {//at least one US session bar should be completed
     
   //     Print("Could be buying/selling..."+h+":"+m); 
        if ((bought == false) && (Low[1]-Pip_filter*Point> (TopRange+Point*3) )) {
         
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
         bought = true;
        }
         
        if ((sold == false) && (High[1]+Pip_filter*Point< (LowRange-Point*3) )) {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
         sold = true;        
        }
    } // end if in 2nd US time. 
   }// end if small session
  }
}