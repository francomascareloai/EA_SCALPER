//+-----------------------------------------------------------------------------+
//|                                                       EURUSD breakout v0.20 |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// If there was a small range during the EU session then there is a trading opportunity during the US session.
//
//01010100 01110010 01100001 01100100 01100101 01110010 01010011 01100101 01110110 01100101 01101110 
//----------------------- USER INPUT
extern int Local_start_hour_EU_session = 6;
extern int Local_end_hour_EU_session = 12;
extern int Local_start_hour_US_session = 12;
extern int Local_end_hour_US_session = 16;
extern int Trade_on_Monday = 0;
extern int TakeProfit=15;
extern int Lots=1;
//----------------------- MAIN PROGRAM LOOP
int start()
{
int slip=3;
int Stoploss=Point(12);
if(Day()>1 || Trade_on_Monday==1) // Skip Mondays?
  {
  if(Hour()>=Local_start_hour_US_session && Hour()<Local_start_hour_EU_session+6) // Within US session hours?
    {
    // Calculate EU session range
    int h=TimeHour(CurTime());
    int m=TimeMinute(CurTime());
    int BarsBack =(h-Local_start_hour_EU_session)*4;// 4 -> 4 M15 bars in an hour
    BarsBack=BarsBack+m/15; // add some completed M15 bars   
    double TopRange=High[Highest(NULL,0,MODE_HIGH,(BarsBack-24),24)]; // 24 M15 bars during EU session
    double LowRange=High[Lowest(NULL,0,MODE_LOW,(BarsBack-24),24)]; // 24 M15 bars during EU session
    if(Point(TopRange-LowRange<31))// Narrow EU range so look for entry point in US session
      {
      if(h>Local_start_hour_EU_session+5 && m>14 && h<Local_start_hour_EU_session+10)//at least one US session bar should be completed
        {
        if(Low[1]>TopRange+Point(3))OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
        if(High[1]<LowRange-Point(3))OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
        }
      }
    }
  }
}