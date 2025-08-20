//https://forex-station.com/viewtopic.php?f=579496&p=1295455024#p1295455024
//+------------------------------------------------------------------+
//|                                    elliot oscillator - waves.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "www.forex-station.com"

#property indicator_separate_window
//#property indicator_height  99
#property indicator_buffers 6
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrYellow
#property indicator_color4  clrBlue
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  5
#property indicator_width4  5
#property indicator_width5  2
#property indicator_width6  2
#property strict

//
//
enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mn1 = PERIOD_MN1,     // Monthly
   tf_n1  = -1,             // First higher time frame
   tf_n2  = -2,             // Second higher time frame
   tf_n3  = -3              // Third higher time frame
};
//
//
//

extern enTimeFrames    TimeFrame        = tf_m15;            // Time frame
extern int             shortPeriod      = 4;                 // Short period
extern int             longPeriod       = 36;                // Long period 
extern ENUM_APPLIED_PRICE Price         = PRICE_CLOSE;       // Price (original should be median)
extern ENUM_MA_METHOD  MaMethod         = MODE_EMA;          // Average method to use (original should be SMA)
extern string          linesIdentifier  = "ewH1";            // Unique ID for the indicator
extern color           linesColor       = clrDarkGray;       // clrNONE; // Zigzag lines color
extern ENUM_LINE_STYLE linesStyle       = STYLE_DOT;         // Zigzag lines style
extern bool            alertsOn         = false;             // Turn alerts on?
extern bool            alertsOnCurrent  = false;             // Alerts on still opened bar?
extern bool            alertsMessage    = true;              // Alerts should display a message?
extern bool            alertsSound      = true;              // Alerts should play alert sound?
extern bool            alertsEmail      = false;             // Alerts should send email?
extern bool            alertsPush       = false;             // Alerts should send notification?
extern bool            Interpolate      = true;              // Interpolate in mtf mode?

extern string             button_note1          = "------------------------------";
extern int                btn_Subwindow         = 3;
extern ENUM_BASE_CORNER   btn_corner            = CORNER_RIGHT_UPPER;
extern string             btn_text              = "Elliot osc";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 8;                        
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = clrRed;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrDarkGray;
extern int                button_x              = 75;                                   
extern int                button_y              = 0;                                   
extern int                btn_Width             = 65;                                
extern int                btn_Height            = 20;                               
extern string             button_note2          = "------------------------------";

bool show_data = true;
bool recalc    = true;

string IndicatorName, IndicatorObjPrefix,buttonId;

double ellBuffer[],ellUBuffer[],ellDBuffer[],mauBuffer[],madBuffer[],peakUp[],peakDn[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,shortPeriod,longPeriod,Price,MaMethod,linesIdentifier,linesColor,linesStyle,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPush,Interpolate,button_note1,btn_Subwindow,btn_corner,btn_text,btn_Font,btn_FontSize,btn_text_ON_color,btn_text_OFF_color,btn_background_color,btn_border_color,button_x,button_y,btn_Width,btn_Height,button_note2,_buff,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
string GenerateIndicatorName(const string target) 
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

//
//
//
//

int OnInit()
{

  IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;
      
      
   IndicatorBuffers(9);
   SetIndexBuffer(0,ellUBuffer,INDICATOR_DATA); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ellDBuffer,INDICATOR_DATA); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,peakUp,    INDICATOR_DATA); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,peakDn,    INDICATOR_DATA); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,mauBuffer, INDICATOR_DATA); SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5,madBuffer, INDICATOR_DATA); SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,trend);
   SetIndexBuffer(7,ellBuffer); 
   SetIndexBuffer(8,count); 
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = (enTimeFrames)timeFrameValue(TimeFrame);     
   
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(TimeFrame)+" Elliot oscillator ( "+(string)shortPeriod+","+(string)longPeriod+")");
   
     ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + (btn_text);
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   
   
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   string lookFor = linesIdentifier+":";
   for (int i=ObjectsTotal(); i>=0; i--)
      {
         string name = ObjectName(i);
         if (StringFind(name,lookFor)==0) ObjectDelete(name);
      }
      ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}



//
//
//
//
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
   //   ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,WindowOnDropped(),0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
}

void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
     // start();
   }
}
void OnChartEvent(const int id, 
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
   if (id==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON)
   
    SetIndexStyle(0,DRAW_HISTOGRAM);
    SetIndexStyle(1,DRAW_HISTOGRAM);
    SetIndexStyle(2,DRAW_HISTOGRAM);
    SetIndexStyle(3,DRAW_HISTOGRAM);
    SetIndexStyle(4,DRAW_LINE);
    SetIndexStyle(5,DRAW_LINE);
     
   if (show_data)
   {
   ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_ON_color);
     
      }
      else
      {
        ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
        SetIndexStyle(0,DRAW_NONE);
    SetIndexStyle(1,DRAW_NONE);
    SetIndexStyle(2,DRAW_NONE);
    SetIndexStyle(3,DRAW_NONE);
    SetIndexStyle(4,DRAW_NONE);
    SetIndexStyle(5,DRAW_NONE);
      }     
   
}

//

int start()
{
   double alpha = 2.0/(1.0+longPeriod+ceil(shortPeriod/2.0));
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-longPeriod); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(8,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     ellUBuffer[i] = _mtfCall(0,y);
                     ellDBuffer[i] = _mtfCall(1,y);
                     peakUp[i]     = _mtfCall(2,y);
                     peakDn[i]     = _mtfCall(3,y);
                     mauBuffer[i]  = _mtfCall(4,y);
                     madBuffer[i]  = _mtfCall(5,y);
                     ellBuffer[i]  = _mtfCall(7,y);
                 
                     //
                     //
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)  
                           {
                              _interpolate(mauBuffer);
                              _interpolate(madBuffer);
                              _interpolate(ellBuffer); 
                              if (ellUBuffer[i]!= EMPTY_VALUE) ellUBuffer[i+k] = ellBuffer[i+k];
  	                           if (ellDBuffer[i]!= EMPTY_VALUE) ellDBuffer[i+k] = ellBuffer[i+k];
  	                           if (peakUp[i]!= EMPTY_VALUE)     peakUp[i+k]     = ellBuffer[i+k];
  	                           if (peakDn[i]!= EMPTY_VALUE)     peakDn[i+k]     = ellBuffer[i+k];
                           }
                                                      
        }   
   return(0);
   }
       
   //
   //
   //
   //
   //

      int      tcount        = 0;
      int      direction     = 0;   
      int      startFrom     = 0;
      double   lastPeakPrice = 0;
      datetime lastPeakTime  = 0;
           for (;limit<(Bars-longPeriod); limit++)
               {
                  if (peakDn[limit]!=EMPTY_VALUE) { if (tcount==0) { tcount ++; continue; } direction=-1; startFrom = limit; break; }
                  if (peakUp[limit]!=EMPTY_VALUE) { if (tcount==0) { tcount ++; continue; } direction= 1; startFrom = limit; break; }
               }

   //
   //
   //
   //
   //
   
   for(i = limit; i >= 0; i--)
   {
      ellBuffer[i]  = iMA(NULL,0,shortPeriod,0,MaMethod,Price,i)-iMA(NULL,0,longPeriod,0,MaMethod,Price,i);
      ellUBuffer[i] = ellDBuffer[i] = EMPTY_VALUE;

         if (mauBuffer[i+1]==EMPTY_VALUE) if (ellBuffer[i]>0) mauBuffer[i+1] = ellBuffer[i]; else  mauBuffer[i+1] = 0;
         if (madBuffer[i+1]==EMPTY_VALUE) if (ellBuffer[i]<0) madBuffer[i+1] = ellBuffer[i]; else  madBuffer[i+1] = 0;
            
      madBuffer[i] = madBuffer[i+1];
      mauBuffer[i] = mauBuffer[i+1];
      trend[i]     = trend[i+1];
      peakUp[i]    = peakDn[i] = EMPTY_VALUE;
         
      //
      //
      //
      //
      //
         
      if (ellBuffer[i] < 0) { madBuffer[i] = madBuffer[i+1]+alpha*(ellBuffer[i]-madBuffer[i+1]); ellDBuffer[i] = ellBuffer[i]; }
      if (ellBuffer[i] > 0) { mauBuffer[i] = mauBuffer[i+1]+alpha*(ellBuffer[i]-mauBuffer[i+1]); ellUBuffer[i] = ellBuffer[i]; }
         
         
         //
         //
         //
         //
         //
         
         ObjectDelete(linesIdentifier+":"+(string)Time[i]);
         if (ellBuffer[i] > 0 && ellBuffer[i]>mauBuffer[i])
         {
            if (direction < 0) { markLow(i,startFrom,lastPeakPrice,lastPeakTime); startFrom = i; }
                direction = 1; trend[i] = 1;
         }
         if (ellBuffer[i] < 0 && ellBuffer[i]<madBuffer[i])
         {
            if (direction > 0) { markHigh(i,startFrom,lastPeakPrice,lastPeakTime); startFrom = i; }
                direction = -1;  trend[i] = -1;
         }
   }
   if (direction > 0) markHigh(0,startFrom,lastPeakPrice,lastPeakTime); 
   if (direction < 0) markLow (0,startFrom,lastPeakPrice,lastPeakTime); 
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,DoubleToStr(mauBuffer[whichBar],5)+" crossed up");
         if (trend[whichBar] ==-1) doAlert(whichBar,DoubleToStr(madBuffer[whichBar],5)+" crossed down");
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

void markLow(int tstart, int end, double& lastPeakPrice, datetime& lastPeakTime)
{
   while (ellBuffer[tstart+1]>0 && tstart<Bars) tstart++;
   while (ellBuffer[end+1]   <0 && end   <Bars) end++;
   int peakAt = ArrayMinimum(Low,end-tstart+1,tstart); peakDn[peakAt] = ellBuffer[peakAt];
   
   //
   //
   //
   //
   //
   
   if (lastPeakPrice!=0) drawLine(lastPeakPrice,lastPeakTime,Low[peakAt],Time[peakAt]);
       lastPeakPrice = Low[peakAt];
       lastPeakTime  = Time[peakAt];
}
void markHigh(int tstart, int end, double& lastPeakPrice, datetime& lastPeakTime)
{
   while (ellBuffer[tstart+1]<0 && tstart<Bars) tstart++;
   while (ellBuffer[end+1]   >0 && end   <Bars) end++;
   int peakAt = ArrayMaximum(High,end-tstart+1,tstart); peakUp[peakAt] = ellBuffer[peakAt];
   
   //
   //
   //
   //
   //
   
   if (lastPeakPrice!=0) drawLine(lastPeakPrice,lastPeakTime,High[peakAt],Time[peakAt]);
       lastPeakPrice = High[peakAt];
       lastPeakTime  = Time[peakAt];
}

//
//
//
//
//

void drawLine(double startPrice, datetime startTime, double endPrice, datetime endTime)
{
   string name = linesIdentifier+":"+(string)startTime;
      ObjectCreate(name,OBJ_TREND,0,startTime,startPrice,endTime,endPrice);
         ObjectSet(name,OBJPROP_STYLE,linesStyle);
         ObjectSet(name,OBJPROP_COLOR,linesColor);
         ObjectSet(name,OBJPROP_RAY,false);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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

        message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Elliot oscillator level "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(_Symbol+" Elliot oscillator ",message);
          if (alertsPush)    SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
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
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : MathAbs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)MathMin(i+add,size-1)]);
}