//+------------------------------------------------------------------+
//|                                            Vasily Pip Sniper.mq4 |
//|                                                            By: E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "By: E"

//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1


extern ENUM_TIMEFRAMES     TimeFrame = 0;
extern ENUM_APPLIED_PRICE  Price     = 0;
extern ENUM_MA_METHOD      Method    = 1;
extern string estr      = "If UseUserVariables set to false, variables are automatically chosen";
extern bool   UseUserVariables = True;
extern int    FastPeriod = 1;
extern int    SlowPeriod = 6;
extern bool   arrowsVisible    = false;             // Arrows visible?
extern string arrowsIdentifier = "vasily1";         // Unique ID for arrows
extern double arrowsUpperGap   = 0.5;               // Upper arrow gap
extern double arrowsLowerGap   = 0.5;               // Lower arrow gap
extern color  arrowsUpColor    = clrDodgerBlue;     // Up arrow color
extern color  arrowsDnColor    = clrRed;            // Down arrow color
extern int    arrowsUpCode     = 225;               // Up arrow code
extern int    arrowsDnCode     = 226;               // Down arrow code
extern int    arrowsSize       = 0;                 // Arrows size
extern bool   alertsOn         = false;             // Turn alerts on?
extern bool   alertsOnCurrent  = false;             // Alerts on current (still opened) bar?
extern bool   alertsMessage    = true;              // Alerts should show pop-up message?
extern bool   alertsSound      = false;             // Alerts should play alert sound?
extern bool   alertsPushNotif  = false;             // Alerts should send push notification?
extern bool   alertsEmail      = false;             // Alerts should send email?
extern bool   Interpolate = true;
//---- parameters



int per1, per2;
//---- buffers
double up[];
double dn[];
double WorkBuffer[];
double WorkBuffer2[],arrows[];
string indicatorFileName;
bool   returnBars;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
if (!UseUserVariables)
{
// for monthly
int mn_per = 12;
int mn_fast = 3;
// for weekly
int w_per = 9;
int w_fast = 3;
// for daily
int d_per = 5;
int d_fast = 3;
// for H4
int h4_per = 12;
int h4_fast = 2;
// for H1
int h1_per = 24;
int h1_fast = 8;
// for M30
int m30_per = 16;
int m30_fast = 2;
// for M15
int m15_per = 16;
int m15_fast = 4;
// for M5
int m5_per = 12;
int m5_fast = 3;
// for M1
int m1_per = 30;
int m1_fast = 10;
//----
}  
//---- 
     if (UseUserVariables)
     {
     per1=SlowPeriod;
     per2=FastPeriod;
     }
     else
     {
      switch(Period())
     {
       case 1:     per1 = m1_per;  per2 = m1_fast;  break;
       case 5:     per1 = m5_per;  per2 = m5_fast;  break;
       case 15:    per1 = m15_per; per2 = m15_fast; break;
       case 30:    per1 = m30_per; per2 = m30_fast; break;
       case 60:    per1 = h1_per;  per2 = h1_fast;  break;
       case 240:   per1 = h4_per;  per2 = h4_fast;  break;
       case 1440:  per1 = d_per;   per2 = d_fast;   break;
       case 10080: per1 = w_per;   per2 = w_fast;   break;
       case 43200: per1 = mn_per;  per2 = mn_fast;  break;
     } 
     }
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         TimeFrame         = MathMax(TimeFrame,_Period);
   
   //
   //
   //
   //
   //
   
   IndicatorBuffers(5);
   SetIndexBuffer(0, up);
   SetIndexBuffer(1, dn); 
   SetIndexBuffer(2, WorkBuffer);
   SetIndexBuffer(3, WorkBuffer2);
   SetIndexBuffer(4, arrows);
   
   SetIndexDrawBegin(0, per1 + per2);
   SetIndexDrawBegin(1, per1 + per2);

   IndicatorShortName(timeFrameToString(TimeFrame)+" Vasily Pip Sniper ZL ("+(string)per1+","+(string)per2+")");
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { up[0] = limit+1; return(0); }
         if (TimeFrame!=_Period)
         {
            limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
            for (int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);               
                  up[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,Method,"",UseUserVariables,FastPeriod,SlowPeriod,arrowsVisible,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsSize,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,0,y);
                  dn[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,Method,"",UseUserVariables,FastPeriod,SlowPeriod,arrowsVisible,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsSize,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,1,y);
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  int n,j; datetime time = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                     for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++)
                     {
                        up[i+j] = up[i] + (up[i+n]-up[i])*j/n;
                        dn[i+j] = dn[i] + (dn[i+n]-dn[i])*j/n;
                     }
            }
            return(0);
         }            
         

   for(i = limit; i>=0; i--)
   {
       WorkBuffer[i] = iMA(NULL, TimeFrame, per1, 0, Method, Price, i);
       WorkBuffer2[i]= iMA(NULL, TimeFrame, per2, 0, Method, Price, i);
   }
   for(i = limit; i>=0; i--)
   {
       double wMA = iMAOnArray(WorkBuffer, 0, per1, 0, Method, i);
       double lMA = WorkBuffer[i] + WorkBuffer[i] - wMA;
     
       double wMA2 = iMAOnArray(WorkBuffer2, 0, per2, 0, Method, i);
       double sMA = WorkBuffer2[i] + WorkBuffer2[i] - wMA2;
       
       up[i]=sMA-lMA;
       dn[i]=lMA-sMA;
       arrows[i]=0;
         if (dn[i]>up[i]) arrows[i] = -1;
         if (dn[i]<up[i]) arrows[i] =  1;
         if (arrowsVisible)
         {
            string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
            if (arrows[i] != arrows[i+1])
            {
               if (arrows[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
               if (arrows[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
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

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (arrows[whichBar] != arrows[whichBar+1])
      {
         if (arrows[whichBar] ==  1) doAlert(whichBar,"up");
         if (arrows[whichBar] == -1) doAlert(whichBar,"down");
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

       message =  _Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" vasily pip sniper "+doWhat;
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(_Symbol+"vasily pip sniper",message);
          if (alertsPushNotif) SendNotification(message);
          if (alertsSound)     PlaySound("alert2.wav");
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

void drawArrow(int i,color theColor,int theCode,bool tup)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime time = Time[i];
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_WIDTH,arrowsSize);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (tup)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}