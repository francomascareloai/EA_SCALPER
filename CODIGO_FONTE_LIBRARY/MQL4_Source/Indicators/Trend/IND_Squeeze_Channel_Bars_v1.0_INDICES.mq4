//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color5  Red
#property indicator_color6  LimeGreen
#property indicator_color7  Ivory
#property indicator_color8  Ivory
#property indicator_style7  STYLE_DASH
#property indicator_style8  STYLE_DASH


extern int    DrawBars        = 0;
extern int    BBPeriod        = 20;
extern int    BBPrice         = 0;
extern double BBDeviations    = 2;
extern int    AtrPeriod       = 10;
extern double AtrMultiplier   = 1.5;
extern color  WickColor       = Honeydew;
extern color  BodyUpColor     = LimeGreen;
extern color  BodyDownColor   = Red;
extern int    BodyWidth       = 3;
extern bool   DrawAsBack      = false;
extern string UniqueID        = "BB Sqz bars 1";

extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;
extern string soundfile       = "alert2.wav";

//
//
//
//
//

double open[];
double close[];
double high[];
double low[];
double bandUp[];
double bandDn[];
double keltUp[];
double keltDn[];
double trend[];
int    window;
double tolerance;

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
   SetIndexBuffer(0,open);  SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,close); SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(2,high);  SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(3,low);   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(4,bandUp);
   SetIndexBuffer(5,bandDn);
   SetIndexBuffer(6,keltUp);
   SetIndexBuffer(7,keltDn);
	IndicatorShortName(UniqueID); 
   return(0);
}

//
//
//
//
//

int deinit()
{
   string lookFor       = UniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i); if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int start()
{
   int i,r,countedBars = IndicatorCounted();
      if (countedBars<0) return(-1);
      if (countedBars>0) countedBars--;
         int drawBars = DrawBars; if (drawBars<1) drawBars = Bars;
         int limit = MathMin(MathMin(Bars-countedBars,Bars-1),drawBars);
            window = WindowFind(UniqueID);

   //
   //
   //
   //
   //
   
   if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);
   for(i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      double udeviation = iStdDev(NULL,0,BBPeriod,0,0,0,i);
      double ddeviation = iStdDev(NULL,0,BBPeriod,0,0,0,i);
      double atr        = iATR(NULL,0,AtrPeriod,i);
      double ma         = iMA(NULL,0,BBPeriod,0,MODE_SMA,BBPrice,i);
         bandUp[i] =  BBDeviations *udeviation;
         bandDn[i] = -BBDeviations *ddeviation;
         keltUp[i] =  AtrMultiplier*atr;
         keltDn[i] = -AtrMultiplier*atr;
         open[i]   = Open[i] -ma;
         close[i]  = Close[i]-ma;
         high[i]   = High[i] -ma;
         low[i]    = Low[i]  -ma;
         trend[r]  = trend[r-1];
         if (bandUp[i] < keltUp[i] && bandDn[i] > keltDn[i]) trend[r] = 1;
         if (bandUp[i] > keltUp[i] && bandDn[i] < keltDn[i]) trend[r] =-1;
         drawCandle(i);
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
     if (alertsOnCurrent)
          int whichBar = 0;
     else     whichBar = 1; whichBar = Bars-iBarShift(NULL,0,iTime(NULL,0,whichBar))-1;   
     if (trend[whichBar] != trend[whichBar-1])
     if (trend[whichBar] == 1)
           doAlert("Squeeze");
     else  doAlert("Breakout");       
   }
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

void drawCandle(int i)
{
   datetime time = Time[i];
   string   name = UniqueID+":"+time+":";
   
      ObjectCreate(name,OBJ_TREND,window,0,0,0,0);
         ObjectSet(name,OBJPROP_COLOR,WickColor);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,MathMax(high[i],MathMin(close[i],open[i])));
         ObjectSet(name,OBJPROP_PRICE2,MathMin(low[i] ,MathMax(close[i],open[i])));
         ObjectSet(name,OBJPROP_RAY ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
      
   //
   //
   //
   //
   //
         
   name = name+"body";
      ObjectCreate(name,OBJ_TREND,window,0,0,0,0);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,open[i]);
         ObjectSet(name,OBJPROP_PRICE2,close[i]);
         ObjectSet(name,OBJPROP_WIDTH,BodyWidth);
         ObjectSet(name,OBJPROP_RAY  ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
         if (open[i]<close[i])
               ObjectSet(name,OBJPROP_COLOR,BodyUpColor);
         else  ObjectSet(name,OBJPROP_COLOR,BodyDownColor);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Squeeze Channel Bars ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Squeeze Channel Bars "),message);
             if (alertsSound)   PlaySound(soundfile);
      }
}
      
          