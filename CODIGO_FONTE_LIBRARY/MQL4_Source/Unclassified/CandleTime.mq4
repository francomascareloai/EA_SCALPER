//+---------------------------------------------------------------------+
//|                                               P4L CandleTime.mq4    |
//| Revised: v1_1 2008-10-02 by pips4life, a user at forexfactory.com   |
//|                                                                     |
//| Previous names: b-Clock.mq4, CandleTime.mq4...                      |
//|                                     Core time code by Nick Bilak    |
//|        http://metatrader.50webs.com/         beluck[at]gmail.com    |
//|                                  modified by adoleh2000 and dwt5    | 
//|                                                                     | 
//|                               Показывает время до закрытия свечи    |
//+---------------------------------------------------------------------+

// Version History: 
// v1_1 2008-10-02 by pips4life, a user at forexfactory.com
//   For H4 and above, display #hours:MM:SS left for the bar. W1 and MN
//   bar times are not accurate though because the weekend hours are included, and
//   Period() does not report an accurate number of seconds/week or seconds/month.
// v1_0 2008-09-24 by pips4life, a user at forexfactory.com
//   A rewrite of CandleTime.mq4 to improve display of MM:SS

// Instructions
//    Copy this file to:  C:\Program Files\--your-MT4-directory-here---\experts\indicators
//    Review the "extern" variable settings below. Change as desired, then restart MT4 or do "Compile" in MetaEditor.
//    
//    Open a chart and add this indicator.


//#property copyright "Copyright © 2005, Nick Bilak" // previous author
//#property link      "http://metatrader.50webs.com/"
#property copyright "pips4life"
#property link      "pips4life, a user at forexfactory.com"
#property indicator_chart_window

extern color  TextColor = Chocolate;
extern int    FontSize  = 9;
extern string FontName = "Verdana";
extern bool   DisplayTimeByTheBar = true ;
extern bool   DisplayTimeComment  = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() 
  {
   ObjectDelete("time");
   return(0);
  } 
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   static datetime last_timecurrent;
   if (TimeCurrent() - last_timecurrent == 0) return; // Little value in processing more than 1 tick per second, but the text position may lag slightly.
   last_timecurrent = TimeCurrent();
   
   int secondsleft = Time[0]+Period()*60-TimeCurrent();
   
   //Print("Time[0]=",Time[0], "  Period()=",Period(),"  TimeCurrent()=",TimeCurrent(),"  secondsleft=",secondsleft);
   int h,m,s;
   s=secondsleft%60;
   m=((secondsleft-s)/60)%60;
   h=(secondsleft-s-m*60)/3600;
   
   if( DisplayTimeComment) 
     {
      if (h!=0) Comment( h + " hours " + m + " minutes " + s + " seconds left to bar end");
      else Comment( m + " minutes " + s + " seconds left to bar end");
     }
	
	ObjectDelete("time"); // The only reason to delete every time, AFAIK, is to unselect the object in case it was selected by accident.
   
   string displaystr;
   // Note, the prefix of spaces below is intentional and necessary to keep the top-middle-anchored text off of Bar[0]!
   if (secondsleft >= 0 && h==0) 
     {
      displaystr = StringConcatenate("                      <--",StringSubstr(TimeToStr(secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else if (secondsleft >= 0 && h>0) 
     {
      displaystr = StringConcatenate("                            <--",h,":",StringSubstr(TimeToStr(secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else if (h==0)
     {// When 1 bar is complete, before a new bar is formed the old version displayed hard-to-read negative values. This is very explicit
      // FYI, max of ~62 characters
      displaystr = StringConcatenate("                                        <--WAIT4BAR:-",StringSubstr(TimeToStr(-1*secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   else //h!=0 and I think always h<0
     {// When 1 bar is complete, before a new bar is formed the old version displayed hard-to-read negative values. This is very explicit
      // FYI, max of ~62 characters
      displaystr = StringConcatenate("                                               <--WAIT4BAR:-",-1*h,":",StringSubstr(TimeToStr(-1*secondsleft,TIME_MINUTES|TIME_SECONDS),3));
     }
   
   
   if(DisplayTimeByTheBar && ObjectFind("time") < 0) // -1 is < 0 if object does not exist.
     {
      ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0]+ 0.0005);
      ObjectSetText("time", displaystr, FontSize, FontName, TextColor);
     }
   else if (DisplayTimeByTheBar && ObjectFind("time") == 0)
     {
      ObjectMove("time", 0, Time[0], Close[0]+0.0005);
      ObjectSetText("time", displaystr, FontSize, FontName, TextColor);
     }


   return(0);
  }
//+------------------------------------------------------------------+


