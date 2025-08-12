//+------------------------------------------------------------------+
//|                                                        Clock.mq4 |
//|                                                           Jerome |
//|                                                4xCoder@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Jerome"
#property link      "4xCoder@gmail.com"

#import "kernel32.dll"
void GetLocalTime(int& TimeArray[]);
void GetSystemTime(int& TimeArray[]);
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import

//------------------------------------------------------------------
// Instructions
//    This Version requires Allow DLL Imports be set in Common Tab when you add this to a chart.
//    You can also enable this by default in the Options>Expert Advisors Tab, but you may want
//    to turn off "Confirm DLL Function Calls"
//
//    ShowLocal - Set to tru to show your local time zone
//    corner    - 0 = top left, 1 = top right, 2 = bottom left, 3 = bottom right
//    topOff    - pixels from top to show the clock
//    labelColor- Color of label
//    clockColor- Color of clock
//    show12HourTime - true show 12 hour time, false, show 24 hour time
//
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red


//---- input parameters
extern bool         ShowLocal=false;
extern int          corner=1;
extern int          topOff=120;
extern color        labelColor=DarkGreen;
extern color        clockColor=MediumBlue;
extern bool         show12HourTime=false;
extern bool 		  ShowTokyo=true;
extern bool 		  ShowLondon=true;
extern bool 		  ShowNewYork=true;
extern bool 		  ShowGMT=true;

//---- buffers
double ExtMapBuffer1[];
int LondonTZ = 0;
int TokyoTZ = 9;
int NewYorkTZ = -5;

string TimeToStringCustom( datetime when ) {
   if ( !show12HourTime )
      return (TimeToStr( when, TIME_MINUTES ));
      
   int hour = TimeHour( when );
   int minute = TimeMinute( when );
   
   string ampm = " AM";
   
   string timeStr;
   if ( hour >= 12 ) {
      hour = hour - 12;
      ampm = " PM";
   }
      
   if ( hour == 0 )
      hour = 12;
   timeStr = DoubleToStr( hour, 0 ) + ":";
   if ( minute < 10 )
      timeStr = timeStr + "0";
   timeStr = timeStr + DoubleToStr( minute, 0 );
   timeStr = timeStr + ampm;
   
   return (timeStr);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  if ( !IsDllsAllowed() ) {
      Alert( "Clock V1_2: DLLs are disabled.  To enable tick the checkbox in the Common Tab of indicator" );
      return(0);
  }
   int    counted_bars=IndicatorCounted();
//----
      
   int    TimeArray[4];
   int    TZInfoArray[43];
   int    nYear,nMonth,nDay,nHour,nMin,nSec,nMilliSec;
   
   
   GetLocalTime(TimeArray);
//---- parse date and time from array
   nYear=TimeArray[0]&0x0000FFFF;
   nMonth=TimeArray[0]>>16;
   nDay=TimeArray[1]>>16;
   nHour=TimeArray[2]&0x0000FFFF;
   nMin=TimeArray[2]>>16;
   nSec=TimeArray[3]&0x0000FFFF;
   nMilliSec=TimeArray[3]>>16;
   string LocalTimeS = FormatDateTime(nYear,nMonth,nDay,nHour,nMin,nSec);
   datetime localTime = StrToTime( LocalTimeS );

   int gmt_shift=0;
   int dst=GetTimeZoneInformation(TZInfoArray);
   if(dst!=0) gmt_shift=TZInfoArray[0];
   //Print("Difference between your local time and GMT is: ",gmt_shift," minutes");
   if(dst==2) gmt_shift+=TZInfoArray[42];
   

   datetime brokerTime = CurTime();
   datetime GMT = localTime + gmt_shift * 60;
   datetime london = GMT + (LondonTZ + (dst - 1)) * 3600;
   datetime tokyo = GMT + (TokyoTZ) * 3600;
   datetime newyork = GMT + (NewYorkTZ + (dst - 1)) * 3600;
   
   //Print( brokerTime, " ", GMT, " ", local, " ", london, " ", tokyo, " ", newyork  );
   string GMTs = TimeToStringCustom( GMT );
   string locals = TimeToStringCustom( localTime  );
   string londons = TimeToStringCustom( london  );
   string tokyos = TimeToStringCustom( tokyo  );
   string newyorks = TimeToStringCustom( newyork  );
   string brokers = TimeToStringCustom( CurTime() );
   string bars = TimeToStr( CurTime() - Time[0], TIME_MINUTES );
   
   if ( ShowLocal ) {
      ObjectSetText( "locl", "Local:", 10, "Arial", labelColor );
      ObjectSetText( "loct", locals, 10, "Arial", clockColor );
   }
   if(ShowGMT)
   {
   	ObjectSetText( "gmtl", "GMT", 10, "Arial", labelColor );
   	ObjectSetText( "gmtt", GMTs, 10, "Arial", clockColor );
   }
   if(ShowNewYork)
   {
	   ObjectSetText( "nyl", "New York:", 10, "Arial", labelColor );
   	ObjectSetText( "nyt", newyorks, 10, "Arial", clockColor );
   }
   if(ShowLondon)
   {
   	ObjectSetText( "lonl", "London:", 10, "Arial", labelColor );
   	ObjectSetText( "lont", londons, 10, "Arial", clockColor );
   }
   if(ShowTokyo)
   {
   	ObjectSetText( "tokl", "Tokyo:", 10, "Arial", labelColor );
   	ObjectSetText( "tokt", tokyos, 10, "Arial", clockColor );
   }
   ObjectSetText( "brol", "Broker:", 10, "Arial", labelColor );
   ObjectSetText( "brot", brokers, 10, "Arial", clockColor );
   ObjectSetText( "barl", "Bar:", 10, "Arial", labelColor );
   ObjectSetText( "bart", bars, 10, "Arial", clockColor );
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void ObjectMakeLabel( string n, int xoff, int yoff ) {
   ObjectCreate( n, OBJ_LABEL, 0, 0, 0 );
   ObjectSet( n, OBJPROP_CORNER, corner );
   ObjectSet( n, OBJPROP_XDISTANCE, xoff );
   ObjectSet( n, OBJPROP_YDISTANCE, yoff );
   ObjectSet( n, OBJPROP_BACK, true );
}

string FormatDateTime(int nYear,int nMonth,int nDay,int nHour,int nMin,int nSec)
  {
   string sMonth,sDay,sHour,sMin,sSec;
//----
   sMonth=(string)(100+nMonth);
   sMonth=StringSubstr(sMonth,1);
   sDay=(string)(100+nDay);
   sDay=StringSubstr(sDay,1);
   sHour=(string)(100+nHour);
   sHour=StringSubstr(sHour,1);
   sMin=(string)(100+nMin);
   sMin=StringSubstr(sMin,1);
   sSec=(string)(100+nSec);
   sSec=StringSubstr(sSec,1);
//----
   return(StringConcatenate(nYear,".",sMonth,".",sDay," ",sHour,":",sMin,":",sSec));
  }

int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   int top=topOff;
   int left = 90;
   if ( show12HourTime )
      left = 102;
   if ( ShowLocal ) {
      ObjectMakeLabel( "locl", left, top );
      ObjectMakeLabel( "loct", 45, top );
   }
   int offset=15;
   if(ShowGMT)
   {
   	ObjectMakeLabel( "gmtl", left, top-offset );
   	ObjectMakeLabel( "gmtt", 45, top-offset );
   	offset+=15;
   }
   if(ShowNewYork)
   {
	   ObjectMakeLabel( "nyl", left, top-offset );
   	ObjectMakeLabel( "nyt", 45, top-offset );
   	offset+=15;
   }
   if(ShowLondon)
   {
	   ObjectMakeLabel( "lonl", left, top-offset );
   	ObjectMakeLabel( "lont", 45, top-offset );
   	offset+=15;
   }
   if(ShowTokyo)
   {
   	ObjectMakeLabel( "tokl", left, top-offset );
   	ObjectMakeLabel( "tokt", 45, top-offset );
   	offset+=15;
   }
   ObjectMakeLabel( "brol", left, top-offset );
   ObjectMakeLabel( "brot", 45, top-offset );
  	offset+=15;
   ObjectMakeLabel( "barl", left, top-offset );
   ObjectMakeLabel( "bart", 45, top-offset );
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete( "locl" );
   ObjectDelete( "loct" );
   if(ShowNewYork)
   {
   	ObjectDelete( "nyl" );
   	ObjectDelete( "nyt" );
   }
   if(ShowGMT)
   {
	   ObjectDelete( "gmtl" );
   	ObjectDelete( "gmtt" );
   }
   if(ShowLondon)
   {
   	ObjectDelete( "lonl" );
   	ObjectDelete( "lont" );
   }
   if(ShowTokyo)
   {
	   ObjectDelete( "tokl" );
   	ObjectDelete( "tokt" );
   }
   ObjectDelete( "brol" );
   ObjectDelete( "brot" );
   ObjectDelete( "barl" );
   ObjectDelete( "bart" );
//----
   return(0);
  }

