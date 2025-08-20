#property copyright "Copyright © 2010, Xaphod"
#property link      "http://forexwhiz.appspot.com"
/*-------------------------------------------------------------------
   Name: Xi-AsianSession.mq4
   Copyright ©2010, Xaphod, http://forexwhiz.appspot.com
   
   Description: 
     Draws the Asian session channel on the chart.
     Optional alert when the channel range goes above a set threshold.
     Optional range value displayed under upper channel line.
     Optional vertical lines at beginning and end of channel.
     Known quirks: OpenHour and CloseHour must be at least 2 hours apart
   History:
   2010-04-16 - Xaphod
     Release v0.90
   2010-04-20 - Xaphod
     Fixed CloseVLineStyle type was wrong
     Release v0.91
-------------------------------------------------------------------*/
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 PaleGoldenrod
#property indicator_color2 PaleGoldenrod
#property indicator_style1 3
#property indicator_style2 3


#define INDI_OBJ_NAME "Xi-AsianSession"

// Indicator parameters
extern string    Info1="<< Asian Session >>";
extern int       OpenHour=00;        // Session opening hour. 
extern int       CloseHour=08;       // Session closing hour. NOTE: Session closes 1 min before this hour.
extern bool      RangeAlarm=True;    // Alarm for when the range exceeds the range thresholdvalue
extern int       RangeThreshold=40;  // Range alarm threshold 
extern bool      RangeShow=true;     // Show label with current channel range
extern color     RangeTextColor=PaleGoldenrod;// Show label with current channel range
extern int       NrOfDays=5;         // Nr of past days to draw the session channel for
//extern bool      EnableDST=false;    // Daylight savings time. Add 1 hour to the open & close hours

extern string    Info2="<< Vertical line marking the open >>";
extern bool      OpenVLineShow=true;   // Draw a vertical line to show the session open time
extern color     OpenVLineColor=Gold;  // Color of the session open time line
extern int       OpenVLineStyle=2;     // Style of the session open time line. Value 0-4
extern int       OpenVLineWidth=1;     // Width of the session open time line
extern string    OpenVLinelabel="Asian Session Open"; // Label for session open time line. 

extern string    Info3="<< Vertical line marking close >>";
extern bool      CloseVLineShow=true;   // Draw a vertical line to show the session close time
extern color     CloseVLineColor=Gold; // Color of the session close time line
extern int       CloseVLineStyle=2;     // Style of the session close time line. Value 0-4
extern int       CloseVLineWidth=1;     // Width of the session close time line
extern string    CloseVLinelabel="Asian Session Close";  // Label for session close time line. 

// Indicator buffers
double miaHiBuffer[];
double miaLoBuffer[];

// Indicator data
string msIndicatorName;
string msVersion = "v0.91";

bool mbRunOnce;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,miaHiBuffer);
   SetIndexLabel(0,"Asian Session High");
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,miaLoBuffer);
   SetIndexLabel(1, "Asian Session Low");
   SetIndexEmptyValue(1,EMPTY_VALUE);
      
   //---- Set Indicator Name
   msIndicatorName = "Xi-AsianSession "+msVersion;
   IndicatorShortName(msIndicatorName);
   
   mbRunOnce=false;
   
   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  // Clear objects
  for(int i=ObjectsTotal()-1; i>-1; i--)
    if (StringFind(ObjectName(i),INDI_OBJ_NAME)>=0)  ObjectDelete(ObjectName(i));
  return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int iNewTicks;
  int iCountedBars;   
 
  // Get unprocessed ticks
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1);
  iNewTicks=Bars-iCountedBars;
  
  // Draw old sessions
  if (mbRunOnce==false) {
    DrawPreviousSessions();    
    mbRunOnce=true;
  } //endif
  
  // Draw current session
  DrawCurrentSession(iNewTicks);
  
  // Exit
  return(0);
} //endfunction
//+------------------------------------------------------------------+

//-----------------------------------------------------------------------------
// function: GetSessionBars()
// Description: Get nr of bars for the session. There can be bars missing!
//-----------------------------------------------------------------------------
int GetSessionBars(int iSessionOpen, int iSessionClose, int iShift) {
  int i;
  int iNrOfBars=0;
  
  // Check DST
  // if (EnableDST==true) { 
  //   iSessionOpen=iSessionOpen+1;
  //   iSessionClose=iSessionClose+1;
  // }
  
  // Get nr of bars for the session.
  for (i=iShift; i<(Bars-iShift); i++) {    
    // Check for beginning hour
    if (TimeHour(Time[i])==iSessionOpen && TimeMinute(Time[i])==0)  {
      return(iNrOfBars);
    }
    
    // Double check to account for missing bars and weekends
    if (IsSessionActive(iSessionOpen,iSessionClose,Time[i])==false) {
      iNrOfBars--; // Break in data. Remove last bar.
      return(iNrOfBars);
    }
    
    iNrOfBars++;
  } // endfor
  // Unable to complete. Return 0.
  return(0);
}


//-----------------------------------------------------------------------------
// function: DrawCurrentSession()
// Description: Draw lines for current session.
//-----------------------------------------------------------------------------
void DrawCurrentSession(int iNewTicks) {
  int i,j;
  int iNrOfBars;
  double dSessionHigh;
  double dSessionLow;
  static int iRange=0;
  static bool bRangeAlarm=false;
 
  if (IsSessionActive(OpenHour,CloseHour-1,Time[0])==true) {
    
    // Get nr of bars for the session. There can be bars missing!
    iNrOfBars=GetSessionBars(OpenHour,CloseHour-1,0);
    
    // Find the highest and lowest data for specified nr of bars
    dSessionHigh=High[iHighest(NULL,0,MODE_HIGH,iNrOfBars+1,0)];
    dSessionLow=Low[iLowest(NULL,0,MODE_LOW,iNrOfBars+1,0)];

    // Draw session lines
    for(i=0; i<=iNrOfBars; i++) {
      miaHiBuffer[i]=dSessionHigh;
      miaLoBuffer[i]=dSessionLow;
    } //endfor
    
    // Draw lines
    if (OpenVLineShow==true) {
      DrawLine(Time[iNrOfBars],OpenVLineStyle,OpenVLineWidth,OpenVLineColor,"Open");
      if (StringLen(OpenVLinelabel)>0)
        DrawTextLabel(Time[iNrOfBars],OpenVLinelabel,OpenVLineColor);
    }
     
    // Draw range text label 
    if (RangeShow==true) { 
      DrawRangeValue(PriceToPips(dSessionHigh-dSessionLow),Time[iNrOfBars/2],dSessionHigh,RangeTextColor);
    }
    
    // Range alert
    iRange=PriceToPips(dSessionHigh-dSessionLow);
    if (iRange>RangeThreshold && RangeAlarm==true) {
      if (bRangeAlarm==false) {
        Alert(msIndicatorName,", ",Symbol(),", Range: ",iRange);
        bRangeAlarm=true;
      } //endif
    } 
    else {
      bRangeAlarm=false;  
    } //endif
  } //endif
  else {
    if (CloseVLineShow==true && ObjectFind(INDI_OBJ_NAME+"Close"+"_"+TimeToStr(Time[0],TIME_DATE ))<0 ) {
      DrawLine(Time[i]-Period()*60,CloseVLineStyle,CloseVLineWidth,CloseVLineColor,"Close");
      if (StringLen(CloseVLinelabel)>0)
        DrawTextLabel(Time[i]-Period()*60,CloseVLinelabel,CloseVLineColor);
    }
  }
} //endfunction


//-----------------------------------------------------------------------------
// function: DrawPreviousSessions()
// Description: Draw lines for previous days sessions in chart.
//-----------------------------------------------------------------------------
void DrawPreviousSessions() {
  int i,j;
  int iNrOfBars;
  double dSessionHigh;
  double dSessionLow;
  int iNrOfDays=0;
  string sLineId;
  string sRange;
  
  // Clear the indicator buffers
  for (i=0; i<Bars; i++) {
    miaHiBuffer[j]=EMPTY_VALUE;
    miaLoBuffer[j]=EMPTY_VALUE;   
  }
 
  // Draw asian session for old data
  i=0;
  while (i<Bars && iNrOfDays<NrOfDays) {
    if (TimeHour(Time[i])==CloseHour && TimeMinute(Time[i])==0) {
        
      // Get nr of bars for the session. There can be bars missing!
      iNrOfBars=GetSessionBars(OpenHour,CloseHour,i);
              
      // Find the highest and lowest data for specified nr of bars
      dSessionHigh=High[iHighest(NULL,0,MODE_HIGH,iNrOfBars,i+1)];
      dSessionLow=Low[iLowest(NULL,0,MODE_LOW,iNrOfBars,i+1)];
      
      // Draw session lines
      for(j=i+1; j<=i+iNrOfBars; j++) {    
        miaHiBuffer[j]=dSessionHigh;
        miaLoBuffer[j]=dSessionLow;    
      } //endfor    
      
      // Draw lines
      if (OpenVLineShow==true) {
        DrawLine(Time[i+iNrOfBars],OpenVLineStyle,OpenVLineWidth,OpenVLineColor,"Open");
        if (StringLen(OpenVLinelabel)>0)
          DrawTextLabel(Time[i+iNrOfBars],OpenVLinelabel,OpenVLineColor);
      }
      if (CloseVLineShow==true) {
        DrawLine(Time[i]-Period()*60,CloseVLineStyle,CloseVLineWidth,CloseVLineColor,"Close");
        if (StringLen(CloseVLinelabel)>0)
          DrawTextLabel(Time[i]-Period()*60,CloseVLinelabel,CloseVLineColor);
      }
      
      // Draw range text label 
      if (RangeShow==true) { 
        DrawRangeValue(PriceToPips(dSessionHigh-dSessionLow),Time[i+iNrOfBars/2],dSessionHigh,RangeTextColor);
      }
      
      iNrOfDays++;  
    } //endif
  i++;
  } //end while
}


//-----------------------------------------------------------------------------
// function: DrawRangeValue()
// Description: Draw range text label below the high channel line
//-----------------------------------------------------------------------------
int DrawRangeValue(double dRange, double tTime, double dPrice, color cTextColor) {
  double tTextPos=0;
  string sLineId;
  string sRange;
  
  sRange=DoubleToStr(dRange,PipDigits());
  sLineId=INDI_OBJ_NAME+"_Range_"+TimeToStr(tTime,TIME_DATE );
  
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);      
  ObjectCreate(sLineId, OBJ_TEXT, 0, tTime, dPrice); 
  ObjectSet(sLineId, OBJPROP_BACK, false);
  ObjectSetText(sLineId, sRange , 8, "Arial", cTextColor);
  return(0);
}


//-----------------------------------------------------------------------------
// function: IsSessionActive()
// Description: Check if session is open. If DST is enabled add 1hr to the market time
//-----------------------------------------------------------------------------
int IsSessionActive(int iSessionOpen, int iSessionClose, datetime dBarTime) {
   int iBarHour; 
   int iBarMinute;
   bool bResult;
   iBarHour = TimeHour(dBarTime);
   iBarMinute = TimeMinute(dBarTime);
   
   // Check DST
   //if (EnableDST==true) { 
   //  iSessionOpen=iSessionOpen+1;
   //  iSessionClose=iSessionClose+1;
   //}
   
   // Check if market is open.
   if (iSessionOpen<iSessionClose) { 
      if (iBarHour>=iSessionOpen && iBarHour<=iSessionClose) 
        bResult=true; // Open & close before midnight
      else 
        bResult=false;
   }   
   else {  
     if (iBarHour>=iSessionOpen || iBarHour<=iSessionClose) 
       bResult=true; // Open before midnight and close after midnight
     else 
       bResult=false;
   }
   return(bResult);     
}

//-----------------------------------------------------------------------------
// function: DrawLine()
// Description: Draw a horizontal line at specific price
//----------------------------------------------------------------------------- 
int DrawLine(double tTime, int iLineStyle, int iLineWidth, color cLineColor, string sId) {
  string sLineId;
  
  // Set Line object ID  
  sLineId=INDI_OBJ_NAME+sId+"_"+TimeToStr(tTime,TIME_DATE );
  
  // Draw line
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);
  ObjectCreate(sLineId, OBJ_TREND, 0, tTime, 0, tTime, 10); 
  //ObjectCreate(sLineId, OBJ_VLINE, 0, tTime, 0); 
  ObjectSet(sLineId, OBJPROP_STYLE, iLineStyle);     
  ObjectSet(sLineId, OBJPROP_WIDTH, iLineWidth);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSet(sLineId, OBJPROP_COLOR, cLineColor);    
  return(0);
}

//-----------------------------------------------------------------------------
// function: DrawTextLabel()
// Description: Draw a text label for a line
//-----------------------------------------------------------------------------
int DrawTextLabel(double tTime, string sLabel, color cLineColor) {
  double tTextPos=0;
  string sLineLabel="";
  string sLineId;
  color cTextColor;
  
  // Set Line object ID  
  sLineId=INDI_OBJ_NAME+sLabel+"_"+TimeToStr(tTime,TIME_DATE );
  
  //Set position of text label
  tTextPos=WindowPriceMin()+(WindowPriceMax()-WindowPriceMin())/2;
  //PrintD("tTextPos: "+tTextPos);
  // Draw or text label  
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);      
  ObjectCreate(sLineId, OBJ_TEXT, 0, tTime, tTextPos);    
  ObjectSet(sLineId, OBJPROP_ANGLE, 90);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSetText(sLineId, sLabel , 8, "Arial", cLineColor);
 
  return(0);
}


//-----------------------------------------------------------------------------
// function: PriceToPips()
// Description: Convert a proce difference to pips.
//-----------------------------------------------------------------------------
double PriceToPips(double dPrice) {

  if (Digits==2 || Digits==3) 
    return(dPrice/0.01); 
  else if (Digits==4 || Digits==5) 
    return(dPrice/0.0001); 
  else
    return(dPrice);            
} // end funcion()


//-----------------------------------------------------------------------------
// function: PipDigits()
// Description: Digits of the pips
//-----------------------------------------------------------------------------
double PipDigits() {

 if (Digits==3 || Digits==5) 
    return(1); 
  else if (Digits==2 || Digits==4) 
    return(0); 
  else
    return(0);            
} // end funcion()

