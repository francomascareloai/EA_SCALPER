//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  PaleVioletRed
#property indicator_color2  LimeGreen
#property indicator_color3  PaleVioletRed
#property indicator_color4  LimeGreen
#property indicator_color5  PaleVioletRed
#property indicator_color6  LimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  3
#property indicator_width6  3

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame          = PERIOD_CURRENT;
extern int             SlowLength         = 7;
extern double          SlowPipDisplace    = 0;
extern int             FastLength         = 3;
extern double          FastPipDisplace    = 0;
extern bool            AlertsOn           = false;
extern bool            AlertsOnCurrent    = true;
extern bool            AlertsMessage      = true;
extern bool            AlertsSound        = false;
extern bool            AlertsEmail        = false;
extern bool            AlertsNotification = false;
extern bool            ShowColoredBars    = true;
extern bool            ShowLines          = true;
extern bool            ShowArrows         = true;
extern int             ArrowCodeDn        = 159;      // Arrow code down
extern int             ArrowCodeUp        = 159;      // Arrow code up
extern bool            ArrowOnFirst       = true;     // Arrow on first bars
extern bool            ShowCandles        = false;
extern int             CandleCount        = 500;
extern color           WickColor          = clrGray;
extern color           BodyUpColor        = clrLimeGreen;
extern color           BodyDownColor      = clrPaleVioletRed;
extern color           BodyNeutralColor   = clrSilver;
extern int             BodyWidth          = 4;
extern bool            DrawAsBack         = false;
extern string          UniqueID           = "ptlCandles1";
extern bool            Interpolate        = true;

double line1[];
double line2[];
double hist1[];
double hist2[];
double arrou[];
double arrod[];
double trend[];
double trena[];
string indicatorFileName;
bool   returnBars;

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
   if (ShowCandles) ShowColoredBars=false;
   int type1 = DRAW_NONE; if (ShowLines)       type1 = DRAW_LINE;
   int type2 = DRAW_NONE; if (ShowColoredBars) type2 = DRAW_HISTOGRAM;
   int type3 = DRAW_NONE; if (ShowArrows)      type3 = DRAW_ARROW;
   
   IndicatorBuffers(8);
      SetIndexBuffer(0,line1); SetIndexStyle(0,type1);
      SetIndexBuffer(1,line2); SetIndexStyle(1,type1);
      SetIndexBuffer(2,hist1); SetIndexStyle(2,type2);
      SetIndexBuffer(3,hist2); SetIndexStyle(3,type2);
      SetIndexBuffer(4,arrod); SetIndexStyle(4,type3); SetIndexArrow(4,ArrowCodeDn);
      SetIndexBuffer(5,arrou); SetIndexStyle(5,type3); SetIndexArrow(5,ArrowCodeUp);
      SetIndexBuffer(6,trend);
      SetIndexBuffer(7,trena);
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         TimeFrame         = MathMax(TimeFrame,_Period);  
   IndicatorShortName(timeFrameToString(TimeFrame)+" ptl");
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
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { line1[0] = MathMin(limit+1,Bars-1); return(0); }
         double pipMultiplier = 1; if (Digits==3 || Digits==5) pipMultiplier =10;
         int numOfCandles = MathMin(Bars,CandleCount); if (numOfCandles==0) numOfCandles=Bars-1;

   //
   //
   //
   //
   //
      
   if (TimeFrame == _Period)
   {
      for (int i = limit; i >= 0; i--)
      {   
         double thigh1 = High[iHighest(NULL, 0, MODE_HIGH,SlowLength,i)] + SlowPipDisplace*Point*pipMultiplier;
         double tlow1  = Low[iLowest(NULL, 0, MODE_LOW,   SlowLength,i)] - SlowPipDisplace*Point*pipMultiplier;
         double thigh2 = High[iHighest(NULL, 0, MODE_HIGH,FastLength,i)] + FastPipDisplace*Point*pipMultiplier;
         double tlow2  = Low[iLowest(NULL, 0, MODE_LOW,   FastLength,i)] - FastPipDisplace*Point*pipMultiplier;
            if (Close[i]>line1[i+1])
                  line1[i] = tlow1;
            else  line1[i] = thigh1;             
            if (Close[i]>line2[i+1])
                  line2[i] = tlow2;
            else  line2[i] = thigh2;             
            
            //
            //
            //
            //
            //
            
            hist1[i] = EMPTY_VALUE;
            hist2[i] = EMPTY_VALUE;
            arrou[i] = EMPTY_VALUE;
            arrod[i] = EMPTY_VALUE;
            trena[i] = trena[i+1];
            trend[i] = 0;
               if (Close[i]<line1[i] && Close[i]<line2[i]) trend[i] =  1;
               if (Close[i]>line1[i] && Close[i]>line2[i]) trend[i] = -1;
               if (line1[i]>line2[i] || trend[i] ==  1)    trena[i] =  1;
               if (line1[i]<line2[i] || trend[i] == -1)    trena[i] = -1;
               if (trend[i]== 1) { hist1[i] = High[i]; hist2[i] = Low[i]; }
               if (trend[i]==-1) { hist2[i] = High[i]; hist1[i] = Low[i]; }
               if (trena[i]!=trena[i+1])
                  if (trena[i] == 1) 
                        arrod[i] = MathMax(line1[i],line2[i]);
                  else  arrou[i] = MathMin(line1[i],line2[i]);
            if (ShowCandles && i<numOfCandles) drawCandle(i,High[i],Low[i],Close[i],Open[i],trend[i]);
      }
      manageAlerts();
      return(0);
   }      

   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/_Period));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
      int x = y;
      if (ArrowOnFirst)
            {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);          }
      else  {  if (i>0) x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
         line1[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotification,0,y);
         line2[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotification,1,y);
         trend[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotification,6,y);
         hist1[i] = EMPTY_VALUE;
         hist2[i] = EMPTY_VALUE;
         arrou[i] = EMPTY_VALUE;
         arrod[i] = EMPTY_VALUE;
      if (x!=y)
      {
         arrod[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotification,4,y);
         arrou[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotification,5,y);
      }
               if (trend[i]== 1) { hist1[i] = High[i]; hist2[i] = Low[i]; }
               if (trend[i]==-1) { hist2[i] = High[i]; hist1[i] = Low[i]; }                    
               if (ShowCandles && i<numOfCandles) drawCandle(i,High[i],Low[i],Close[i],Open[i],trend[i]);
         //
         //
         //
         //
         //

         if (!Interpolate || (i>0 &&y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;

         //
         //
         //
         //
         //

         int n,k; datetime time = iTime(NULL,TimeFrame,y);
             for(n = 1; i+n<Bars && Time[i+n] >= time; n++) continue;
             for(k = 1; i+n<Bars && i+k<Bars && k<n; k++)
             {
               line1[i+k] = line1[i] + (line1[i+n]-line1[i])*k/n;
               line2[i+k] = line2[i] + (line2[i+n]-line2[i])*k/n;
            }
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
  
void drawCandle(int i, double high, double low, double open, double close, int state)
{
   datetime time = Time[i];
   string   name = UniqueID+":"+time+":";
   
      ObjectCreate(name,OBJ_TREND,0,0,0,0,0);
         ObjectSet(name,OBJPROP_COLOR,WickColor);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,high);
         ObjectSet(name,OBJPROP_PRICE2,low);
         ObjectSet(name,OBJPROP_RAY ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
      
   //
   //
   //
   //
   //
         
   name = name+"body";
      ObjectCreate(name,OBJ_TREND,0,0,0,0,0);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,open);
         ObjectSet(name,OBJPROP_PRICE2,close);
         ObjectSet(name,OBJPROP_WIDTH,BodyWidth);
         ObjectSet(name,OBJPROP_RAY  ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
         switch (state)
         {
            case -1: ObjectSet(name,OBJPROP_COLOR,BodyUpColor);   break;
            case  1: ObjectSet(name,OBJPROP_COLOR,BodyDownColor); break;
            default: ObjectSet(name,OBJPROP_COLOR,BodyNeutralColor);
         }    
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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
   if (AlertsOn)
   {
      if (AlertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (arrod[whichBar] != EMPTY_VALUE || arrou[whichBar] != EMPTY_VALUE)
      {
         static datetime time1 = 0;
         static string   mess1 = "";
            if (arrou[whichBar] != EMPTY_VALUE) doAlert(time1,mess1," ptl trend changed to up");
            if (arrod[whichBar] != EMPTY_VALUE) doAlert(time1,mess1," ptl trend changed to down");
      }
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ptl ",doWhat);
          if (AlertsMessage)      Alert(message);
          if (AlertsEmail)        SendMail(Symbol()+" ptl",message);
          if (AlertsNotification) SendNotification(message);
          if (AlertsSound)        PlaySound("alert2.wav");
   }
}