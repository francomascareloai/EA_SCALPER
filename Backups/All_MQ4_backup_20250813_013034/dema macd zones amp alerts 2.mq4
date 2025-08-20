//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 0

extern string TimeFrame = "current time frame";
extern int    FastEMA   = 12;
extern int    SlowEMA   = 26;
extern int    SignalEMA =  9;
extern int    Price     = PRICE_CLOSE;
extern string UniqueID  = "MACD zones";
extern color  ColorUp          = C'7,71,49';
extern color  ColorNeutralUp   = C'85,22,17';
extern color  ColorDown        = C'98,26,19';
extern color  ColorNeutralDown = C'6,55,38';
extern double MaxValue          = 200;
extern bool   alertsOn          = false;
extern bool   alertsOnCurrent   = true;
extern bool   alertsMessage     = true;
extern bool   alertsSound       = false;
extern bool   alertsEmail       = false;
extern double Dummy     = -1;

double macd[];
double signal[];
double colors[];
double times[];

int    timeFrame;
string indicatorFileName;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,macd);
   SetIndexBuffer(1,signal);
   SetIndexBuffer(2,colors);
   SetIndexBuffer(3,times);
      timeFrame         = stringToTimeFrame(TimeFrame);
      indicatorFileName = WindowExpertName();
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
{
   string lookFor       = UniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

         if (timeFrame!=Period()) 
         { 
            iCustom(NULL,timeFrame,indicatorFileName,"",FastEMA,SlowEMA,SignalEMA,Price,UniqueID,ColorUp,ColorNeutralUp,ColorDown,ColorNeutralDown,MaxValue,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,Time[0],0,0); 
            return(0); 
         }
         else if (Dummy<=Time[0]) Dummy = Time[0];
         static bool secondTime=false;
         if (secondTime)
         {
            for (;limit<Bars; limit++) if (colors[limit]!=colors[limit+1]) break;
         }
         else secondTime=true;

      for(i = limit; i>=0 ; i--)
      {
         double price = iMA(NULL,0,1,0,MODE_SMA,Price,i);
         if (i>Bars-2)
         {
            macd[i]    = 0;
            signal[i]  = 0;
            continue;
         }

         macd[i]    = iDema(price,FastEMA,i,0)-iDema(price,SlowEMA,i,1);
         signal[i]  = iDema(macd[i],SignalEMA,i,2);
         colors[i]  = colors[i+1];
         times[i]   = times[i+1];
         string name = UniqueID+":"+Time[i];
            ObjectDelete(name);
            
            if (macd[i]>signal[i] && macd[i]> 0) colors[i] =  1;
            if (macd[i]>signal[i] && macd[i]< 0) colors[i] =  2;
            if (macd[i]<signal[i] && macd[i]< 0) colors[i] =  3;
            if (macd[i]<signal[i] && macd[i]> 0) colors[i] =  4;
            if (colors[i]!=colors[i+1] || i==0)
            {
               times[i]= Time[i];
               if (times[i+1]<Time[0])
               {
                  datetime lastTime = Time[i]; if (i==0) lastTime = Dummy;
                  ObjectCreate(name,OBJ_RECTANGLE,0,times[i+1],0,lastTime,MaxValue);
                     ObjectSet(name,OBJPROP_BACK,true);
                     int clr = colors[i];
                     switch (clr)
                     {
                        case  3 : ObjectSet(name,OBJPROP_COLOR,ColorDown);        break;
                        case  4 : ObjectSet(name,OBJPROP_COLOR,ColorNeutralDown); break;
                        case  1 : ObjectSet(name,OBJPROP_COLOR,ColorUp);          break;
                        default : ObjectSet(name,OBJPROP_COLOR,ColorNeutralUp);   break;
                     }                        
               }                     
            }                     
   }
   manageAlerts();
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
      if (colors[whichBar] != colors[whichBar+1])
      {
         if (colors[whichBar] ==  1) doAlert(whichBar,"up and MACD > 0");
         if (colors[whichBar] ==  2) doAlert(whichBar,"up and MACD < 0");
         if (colors[whichBar] == -1) doAlert(whichBar,"down and MACD < 0");
         if (colors[whichBar] == -2) doAlert(whichBar,"down and MACD > 0");
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message = timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" DEMA MACD trend changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," DEMA MACD zones "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}
//+------------------------------------------------------------------+
double workDema[][6];
#define _ema1 0
#define _ema2 1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= Bars) ArrayResize(workDema,Bars); instanceNo*=2; r = Bars-r-1;
 
   double alpha = 2.0 / (1.0+period);
          workDema[r][_ema1+instanceNo] = workDema[r-1][_ema1+instanceNo]+alpha*(price                        -workDema[r-1][_ema1+instanceNo]);
          workDema[r][_ema2+instanceNo] = workDema[r-1][_ema2+instanceNo]+alpha*(workDema[r][_ema1+instanceNo]-workDema[r-1][_ema2+instanceNo]);
   return(workDema[r][_ema1+instanceNo]*2.0-workDema[r][_ema2+instanceNo]);
}
//+------------------------------------------------------------------+
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int chars = StringGetChar(s, length);
         if((chars > 96 && chars < 123) || (chars > 223 && chars < 256))
                     s = StringSetChar(s, length, chars - 32);
         else if(chars > -33 && chars < 0)
                     s = StringSetChar(s, length, chars + 224);
   }
   return(s);
}
//+------------------------------------------------------------------+