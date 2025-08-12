//+------------------------------------------------------------------+
//|                                  Simple_Signal_Arrows_Alerts.mq4 |
//|                           Copyright 2023, MetaQuotes Software Corp. |
//|                                                https://www.mql5.com |
//+---------------------------------------------------------------------+
#property copyright "GURU 2024"
#property link      "TELEGRAM CONTACT @Zabi197"
#property strict
#property description "===================================="
#property description "Telegram Support t.me/BinaryGuruTrading"
#property indicator_chart_window
#property indicator_buffers 22
#property indicator_color1 clrWhite
#property indicator_color2 clrWhite
#property indicator_color3 clrWhite
#property indicator_color4 clrWhite
#property indicator_color5 clrLime
#property indicator_color6 clrRed
#property indicator_color12 clrRed
#property indicator_color13 clrRed
#property description "KING IN MQL4"
#property indicator_buffers 2

enum enScenario{
WithCandleDirection,
CounterCandleDirection,
};
//---- input parameters
extern enScenario     WhichDirection  = WithCandleDirection;  
extern int            ArrowSize       = 0;            // Arrow size
extern bool           alertsOn        = true;        // Turn alerts on?
extern bool           alertsOnCurrent = true;         // Alerts on current (still opened) bar?
extern bool           alertsMessage   = true;         // Alerts should show pop-up message?
extern bool           alertsSound     = true;        // Alerts should play alert sound?
extern bool           alertsPush      = true;        // Alerts should send push notification?
extern bool           alertsEmail     = true;        // Alerts should send email?
extern string         soundFile       = "alert2.wav"; // Sound file
extern color          UpArrowsColor   = clrLimeGreen;
extern color          DnArrowsColor   = clrRed;
extern int            ArrowCodeUp     = 233;          // Arrow code up
extern int            ArrowCodeDn     = 234;          // Arrow code down
extern double         ArrowGapUp      = 0.5;          // Gap for arrow up        
extern double         ArrowGapDn      = 0.5;          // Gap for arrow down
//---- buffers
double upArr[],dnArr[],trend[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(3);
   SetIndexBuffer(0,upArr);  SetIndexStyle(0,DRAW_ARROW,0,ArrowSize,UpArrowsColor); SetIndexArrow(0,ArrowCodeUp);
   SetIndexBuffer(1,dnArr);  SetIndexStyle(1,DRAW_ARROW,0,ArrowSize,DnArrowsColor); SetIndexArrow(1,ArrowCodeDn);
   SetIndexBuffer(2,trend);
return(0);
}
//+------------------------------------------------------------------+
int start()
{
    
   int i,counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
   
   //
   //
   //
   
   for (i=limit; i>=0; i--)
   {
      if (i<Bars-1)
      {
        trend[i] = 0;
        if(WhichDirection==CounterCandleDirection)
        {
           if(Close[i]<Low[i+1])  trend[i] = 1;
           if(Close[i]>High[i+1]) trend[i] =-1;
        } 
        if(WhichDirection==WithCandleDirection)
        {
          if(Close[i]>High[i+1]) trend[i] = 1;
          if(Close[i]<Low[i+1])  trend[i] =-1;
        }
     }
       upArr[i] = dnArr[i] = EMPTY_VALUE;
       if (i<Bars-1 && trend[i]!=trend[i+1])
       {
          if (trend[i] ==  1) upArr[i] = Low[i] -iATR(NULL,0,15,i)*ArrowGapUp;
          if (trend[i] == -1) dnArr[i] = High[i]+iATR(NULL,0,15,i)*ArrowGapDn;
       }
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (trend[whichBar] != trend[whichBar+1])
      {
            if (trend[whichBar] == 1) doAlert(" BINARY GURU TRADING up");
            if (trend[whichBar] ==-1) doAlert(" BINARY GURU TRADING down");       
      }         
    }        
return(0);
}

//------------------------------------------------------------------
//
//----------------------------------------------------------------

void doAlert(string doWhat)
{
   static string   previousAlert="Yes";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Simple signal  "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsPush)    SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" Simple BINARY GURU TRADING signal ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

