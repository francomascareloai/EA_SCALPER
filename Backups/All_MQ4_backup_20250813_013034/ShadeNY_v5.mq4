//+------------------------------------------------------------------+
//|                                                   ShadeNY_v5.mq4 |
//|                                         Copyright © 2006, sx ted |
//| Purpose: shade New York or other sessions for chart time frames  |
//|          M1 to H4 (at a push).                                   |
//| Notes..: To change chart time frame from M5 to M15 for example,  |
//|          click on M15, M5 and M15 again to force a chart refresh.|
//|          Modify the values of MAX_DAYS_TO_SHADE, SESSION_OPEN_HH,|
//|          SESSION_OPEN_MM, SESSION_CLOSE_HH and SESSION_CLOSE_MM  |
//|          to suit ***** THE LOCAL TIMES AT THE EXCHANGE *****.    |
//|          The values for SERVER_TIME_ZONE and EXCHANGE_TIME_ZONE  |
//|          are to be edited for DST when applicable.               |
//| version: 2 - enhanced for speed but with MT4 beeing so fast no   |
//|              difference will be noticed, all the sessions are    |
//|              shaded in the init(), last session if it is current |
//|              is widened in the start() in lieu of repainting all.|
//|          3 - 2006.03.22 added "SetImmediacyON" input parameter   |
//|              which forces shading after first tick is received   |
//|              in the new session. Corrected case where bar is not |
//|              complete and session starts, and case when session  |
//|              covers two days when in Moscow (GMT+3 and greater). |
//|          4 - 2006.03.29 corrected for not taking into account the|
//|              difference between Local time and Server time.      |
//|          5 - 2006.04.03 corrected for Server time change, open   |
//|              and close times of exchange are now expressed in    |
//|              local times of the exchange.                        |
//|              Added new SERVER_TIME_ZONE and EXCHANGE_TIME_ZONE in|
//|              the #define section. Finally learnt about GMT time! |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2006, sx ted"
#property link      ""

#property indicator_chart_window

//---- input parameters
extern color     ShadeColor=Yellow;
extern bool      SetImmediacyON=true;  // if set ON forces shading after first tick in new session

#define MAX_DAYS_TO_SHADE   15          // maximum number of days back from last chart date to be shaded

#define SERVER_TIME_ZONE   +1          // MetaTrader server time zone, compare CurTime() with Greenwich GMT
#define EXCHANGE_TIME_ZONE -5          // Exchange time zone, example New York -4 GMT
#define SESSION_OPEN_HH    12          // session open hour (in local time at the exchange)
#define SESSION_OPEN_MM    00          // session open minutes (in local time at the exchange)
#define SESSION_CLOSE_HH   21          // session close hour (in local time at the exchange)
#define SESSION_CLOSE_MM   00          // session close minutes (in local time at the exchange)

//---- global variables to program
string  obj[];                         // array of object names

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if(Period() > PERIOD_H4) return(0); // no shading required
   // comment out or delete the following line when no longer required
   Alert( "ServerTime at ", ServerAddress(), " is ", TimeToStr( CurTime(),TIME_MINUTES ), "\nAdjust #define SERVER_TIME_ZONE if required" );
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i=0; i < ArraySize(obj); i++)
     {
      if(ObjectFind(obj[i]) > -1) ObjectDelete(obj[i]); // tidy up
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(Period() > PERIOD_H4) return(0); // no shading required
   int    i, iCount, iAdjust,          // counters
          iStart, iEnd;                // x co-ordinates of object (index)
   double dLow, dHigh;                 // y co-ordinates of object   
   string sName;                       // name for the object
   int    iSessionDuration;            // session duration in seconds
   bool   ok;
   // adjust for difference between Server time and Local time at the exchange (in minutes)
   iAdjust=(SERVER_TIME_ZONE - EXCHANGE_TIME_ZONE) * 60;
   // determine open time of first bar in the session matching chart time frame in format " hh:mi"
   iStart=SESSION_OPEN_HH*60+SESSION_OPEN_MM+iAdjust;
   if(iStart > 24*60) iStart-=24*60;
   string sStart=" "+TimeToStr(StrToTime("2006.3.22")+(MathFloor(iStart/Period()) * Period() ) * 60, TIME_MINUTES);
   // calculate session duration in seconds, check if session covers two days (cater for GMT+3 and above)
   if(SESSION_OPEN_HH*60+SESSION_OPEN_MM >= SESSION_CLOSE_HH*60+SESSION_CLOSE_MM) iSessionDuration = ((23-SESSION_OPEN_HH+SESSION_CLOSE_HH)*60+59-SESSION_OPEN_MM+SESSION_CLOSE_MM+1)*60;
   else iSessionDuration = ( (SESSION_CLOSE_HH*60+SESSION_CLOSE_MM) - (SESSION_OPEN_HH*60+SESSION_OPEN_MM) )*60;
   // round session duration to suit an open time of chart time frame
   datetime tStart =StrToTime(TimeToStr(Time[0], TIME_DATE)+sStart);
   datetime tEnd   =StrToTime(TimeToStr(Time[0], TIME_DATE)+" "+DoubleToStr(SESSION_OPEN_HH ,0)+":"+DoubleToStr(SESSION_OPEN_MM ,0))+iSessionDuration+iAdjust*60;
   iSessionDuration=MathCeil((tEnd-tStart)/Period())*Period();
   // clear previous objects
   for(i=0; i < ArraySize(obj); i++)
     {
      if(ObjectFind(obj[i]) > -1) ObjectDelete(obj[i]);
     }
   for(i=MAX_DAYS_TO_SHADE; i >= 0; i--)
     {
      tStart=StrToTime(TimeToStr(iTime(NULL, PERIOD_D1, i), TIME_DATE)+sStart);
      tEnd  =tStart+iSessionDuration;
      iStart=iBarShift(NULL, 0, tStart, false);
      ok=(iStart > 0 && iStart < Bars-1 && TimeDayOfYear(tStart) == TimeDayOfYear(Time[iStart]));
      if(!ok && SetImmediacyON && CurTime() >= tStart && CurTime() < tEnd)
        {
         ok=true;
         iStart=1;
        }
      if(ok)  
        {
         iEnd=iBarShift(NULL, 0, tEnd, false);
         if(iEnd >= Bars-1) iEnd=0; // end not found, therefore current session
         while(iEnd < iStart && Time[iEnd] > tEnd) iEnd++; // cater for earlier close on Friday
         dLow =Low[Lowest(NULL,0,MODE_LOW,iStart-iEnd,iEnd)];
         dHigh=High[Highest(NULL,0,MODE_HIGH,iStart-iEnd,iEnd)];
         sName="Session_"+TimeToStr(iTime(NULL, PERIOD_D1, i), TIME_DATE);
         ObjectCreate(sName,OBJ_RECTANGLE,0,Time[iStart],dLow-Point,Time[iEnd],dHigh+Point);
         ObjectSet(sName,OBJPROP_COLOR,ShadeColor);
         // keep track of object names for tidying up upon exit
         iCount=ArraySize(obj);
         ArrayResize(obj, iCount+1);
         obj[iCount]=sName;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+