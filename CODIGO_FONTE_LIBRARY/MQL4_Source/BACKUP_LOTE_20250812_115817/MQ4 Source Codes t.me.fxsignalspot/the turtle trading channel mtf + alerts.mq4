//+------------------------------------------------------------------+
//| TheTurtleTradingChannelmq4
//| original by Pointzero-indicator.com
//| this version mladen (www.forex-station.com)
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 DarkSlateGray
#property indicator_color4 DarkSlateGray
#property indicator_color5 DodgerBlue
#property indicator_color6 Red
#property indicator_color7 DodgerBlue
#property indicator_color8 Red
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT

extern string TimeFrame          = "Current time frame";
extern int    TradePeriod        = 11;
extern int    StopPeriod         = 6;
extern bool   alertsOn           = False;
extern bool   alertsOnCurrentBar = true;
extern bool   alertsMessage      = true;
extern bool   alertsSound        = false;
extern bool   alertsEmail        = false;


double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double dotTup[];
double dotTdn[];
double dotSup[];
double dotSdn[];

string indicatorFileName;
bool   returnBars;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
   SetIndexBuffer(0,ExtMapBuffer1); SetIndexLabel(0,"Upper Channel");
   SetIndexBuffer(1,ExtMapBuffer2); SetIndexLabel(1,"Lower Channel");
   SetIndexBuffer(2,ExtMapBuffer3); SetIndexLabel(2,"Phantom Up Channel");
   SetIndexBuffer(3,ExtMapBuffer4); SetIndexLabel(3,"Phantom Down Channel");
   SetIndexBuffer(4,dotTup); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,159);
   SetIndexBuffer(5,dotTdn); SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,159);
   SetIndexBuffer(6,dotSup); SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159);
   SetIndexBuffer(7,dotSdn); SetIndexStyle(7,DRAW_ARROW); SetIndexArrow(7,159);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
      timeFrame         = stringToTimeFrame(TimeFrame);
   IndicatorShortName("Turtle Channel ("+ TradePeriod +")");
   return(0);
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
double trend[];
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { ExtMapBuffer1[0] = MathMin(limit+1,Bars-1); return(0); }
           if (timeFrame!=Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
           if (ArraySize(trend)!=Bars) ArrayResize(trend,Bars);

   //
   //
   //
   //
   //

      for(i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         int y = iBarShift(NULL,timeFrame,Time[i]);
         double rhigh = iHigh(NULL,timeFrame,iHighest(NULL,timeFrame,MODE_HIGH,TradePeriod,y+1));
         double shigh = iHigh(NULL,timeFrame,iHighest(NULL,timeFrame,MODE_HIGH,StopPeriod ,y+1));
         double rlow  = iLow(NULL,timeFrame,iLowest(NULL,timeFrame,MODE_LOW,TradePeriod,y+1));
         double slow  = iLow(NULL,timeFrame,iLowest(NULL,timeFrame,MODE_LOW,StopPeriod ,y+1));
         double close = iClose(NULL,timeFrame,y);
       
         trend[r] = trend[r-1];  
            if(close > rhigh) trend[r] =  1;
            if(close < rlow)  trend[r] = -1;
      
            ExtMapBuffer1[i] = EMPTY_VALUE;
            ExtMapBuffer2[i] = EMPTY_VALUE;
            ExtMapBuffer3[i] = EMPTY_VALUE;
            ExtMapBuffer4[i] = EMPTY_VALUE;
            dotTup[i]        = EMPTY_VALUE;
            dotTdn[i]        = EMPTY_VALUE;
            dotSup[i]        = EMPTY_VALUE;
            dotSdn[i]        = EMPTY_VALUE;
         
            if(trend[r] == 1) 
            {
               ExtMapBuffer1[i] = rlow;
               ExtMapBuffer3[i] = slow;
               if (trend[r]!=trend[r-1])
               {
                  dotTup[i] = rlow;
                  dotSup[i] = slow;
               }
            }               
            if(trend[r] == -1) 
            {
               ExtMapBuffer2[i] = rhigh;
               ExtMapBuffer4[i] = shigh;
               if (trend[r]!=trend[r-1])
               {
                  dotTdn[i] = rhigh;
                  dotSdn[i] = shigh;
               }
            }
     }
   manageAlerts();     
   return(0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrentBar)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (dotSup[whichBar] != EMPTY_VALUE || dotSdn[whichBar])
      {
         if (dotSup[whichBar] != EMPTY_VALUE) doAlert(whichBar,"up");
         if (dotSdn[whichBar] != EMPTY_VALUE) doAlert(whichBar,"down");
      }         
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  timeFrameToString(timeFrame)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" TTC signal changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Trurtle trading channel "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

