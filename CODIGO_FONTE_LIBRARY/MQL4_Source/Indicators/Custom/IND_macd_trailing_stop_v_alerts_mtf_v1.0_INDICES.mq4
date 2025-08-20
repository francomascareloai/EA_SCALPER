#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  DarkGray
#property indicator_color2  DeepSkyBlue
#property indicator_color3  Red
#property indicator_style1  STYLE_DOT
#property indicator_width2  3
#property indicator_width3  3

extern string TimeFrame          = "Current time frame";
extern int    FastEMA            = 12;
extern int    SlowEMA            = 26;
extern int    Price              = PRICE_CLOSE;
extern int    AtrPeriod          = 20;
extern double AtrMultiplier      = 2;
extern bool   alertsOn           = false;
extern bool   alertsOnCurrent    = true;
extern bool   alertsMessage      = true;
extern bool   alertsNotification = false;
extern bool   alertsSound        = false;
extern bool   alertsEmail        = false;

double stop[];
double stopdu[];
double stopdd[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;
 
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,stop);
   SetIndexBuffer(1,stopdu); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159);
   SetIndexBuffer(2,stopdd); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,159);

      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame == "returnBars";     if (returnBars)     return(0);
      calculateValue    = TimeFrame == "calculateValue"; if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
   return(0); 
}
int deinit()
{
   return(0); 
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { stop[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      for(int i=limit; i>=0; i--)
      {
         double macd  = iMA(NULL,0,FastEMA,0,MODE_EMA,Price,i)  -iMA(NULL,0,SlowEMA,0,MODE_EMA,Price,i);
         double macdp = iMA(NULL,0,FastEMA,0,MODE_EMA,Price,i+1)-iMA(NULL,0,SlowEMA,0,MODE_EMA,Price,i+1);
            stop[i]   = stop[i+1];
            stopdu[i] = EMPTY_VALUE;
            stopdd[i] = EMPTY_VALUE;
            if (macd*macdp>=0)
            {
               if (macd>0) stop[i] = MathMax(stop[i],Low[i] -iATR(NULL,0,AtrPeriod,i)*AtrMultiplier);
               if (macd<0) stop[i] = MathMin(stop[i],High[i]+iATR(NULL,0,AtrPeriod,i)*AtrMultiplier);
            }
            else
            {
               if (macd>0) { stop[i] = Low[i] -iATR(NULL,0,AtrPeriod,i)*AtrMultiplier; stopdu[i] = stop[i]; }
               if (macd<0) { stop[i] = High[i]+iATR(NULL,0,AtrPeriod,i)*AtrMultiplier; stopdd[i] = stop[i]; }
            }            
      }  
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
       int y = iBarShift(NULL,timeFrame,Time[i]);               
       int x = iBarShift(NULL,timeFrame,Time[i+1]);               
          stop[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastEMA,SlowEMA,Price,AtrPeriod,AtrMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,0,y);
          stopdu[i] = EMPTY_VALUE;
          stopdd[i] = EMPTY_VALUE;
          if (x!=y)
          {
             stopdu[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastEMA,SlowEMA,Price,AtrPeriod,AtrMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,1,y);
             stopdd[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastEMA,SlowEMA,Price,AtrPeriod,AtrMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,2,y);
          }
   }          
   return(0);         
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (stopdu[whichBar] != EMPTY_VALUE || stopdd[whichBar] != EMPTY_VALUE)
      {
         if (stopdu[whichBar] != EMPTY_VALUE) doAlert(whichBar,"up");
         if (stopdd[whichBar] != EMPTY_VALUE) doAlert(whichBar,"down");
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

       message =  timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" MACD trailing trend changed to "+doWhat;
          if (alertsMessage)      Alert(message);
          if (alertsNotification) SendNotification(message);
          if (alertsEmail)        SendMail(Symbol()+" MACD trailing",message);
          if (alertsSound)        PlaySound("alert2.wav");
   }
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
   StringToUpper(tfs);
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