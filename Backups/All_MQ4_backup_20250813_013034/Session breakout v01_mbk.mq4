//+-----------------------------------------------------------------------------+
//|                                                       EURUSD breakout v0.30 |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven/Matt Kennel"
#property link      "TraderSeven@gmx.net"
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Run on EUR/USD M15 
//
// If there was a small range during the EU session then there is a trading opportunity during the US session.
//
//----------------------- USER INPUT
//
// --- Numerous programming problems fixed by Matt Kennel ("Doctor Chaos"), now executes trades
//     Not yet profitable.  

extern int Local_start_hour_EU_session = 6;
extern int Local_end_hour_EU_session = 12;
extern int Local_start_hour_US_session = 12;
extern int Local_end_hour_US_session = 16;
extern int SmallEUSessionPips = 30; 
extern bool Trade_on_Monday = false;
extern int TakeProfit=15;
extern int Lots=1;
//----------------------- MAIN PROGRAM LOOP
int start()
{
int slip=3;
int Stoploss=12; // in pips

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
// it may be a good idea to also avoid NFP days, first thursday in any month. 


if(TradeDayOK) {
   if ((sessionfound == false) && (Hour() == Local_start_hour_US_session)) {
     // first time through, compute EU session highs and lows.
     TopRange=High[Highest(NULL,0,MODE_HIGH,24,1)]; // 24 M15 bars during EU session
     LowRange=Low[Lowest(NULL,0,MODE_LOW,24,1)];  // 24 M15 bars during EU session
     if ((TopRange-LowRange) <= SmallEUSessionPips*Point) 
       smallsession = true;
      else
       smallsession = false; 
   
     sessionfound = true;
     Print("Identified new EU session + ["+LowRange+","+TopRange+"]"+" DayOfYear()="+DayOfYear()+" small? "+smallsession); 
   }    
      
        
   if(sessionfound && smallsession && (Hour()>=Local_start_hour_US_session) && (Hour()<Local_end_hour_US_session)) // Within US session hours?
    {
    // Calculate EU session range
  //  Print("Am in US session... smallsession, bought, sold = " + smallsession+bought+sold); 
  //  Print("TopRange = "+ TopRange + "LowRange = " + LowRange); 
    int h=TimeHour(CurTime());
    int m=TimeMinute(CurTime());
    
    if(h>Local_start_hour_EU_session+5 && h<Local_start_hour_EU_session+10) {//at least one US session bar should be completed
   //     Print("Could be buying/selling..."+h+":"+m); 
        if ((bought == false) && (Low[1]> (TopRange+Point*3) )) {
         
         OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
         bought = true;
        }
         
        if ((sold == false) && (High[1]< (LowRange-Point*3) )) {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
         sold = true;        
        }
    } // end if in 2nd US time. 
   }// end if small session
  }
}