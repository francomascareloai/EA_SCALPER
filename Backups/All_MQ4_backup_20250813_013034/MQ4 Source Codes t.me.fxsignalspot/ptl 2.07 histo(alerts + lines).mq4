//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_minimum 0
#property indicator_maximum 1
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame             = PERIOD_CURRENT;   // Time frame
extern int             SlowLength            = 7;                // Slow length
extern double          SlowPipDisplace       = 0;                // Slow pip displace
extern int             FastLength            = 3;                // Fast length
extern double          FastPipDisplace       = 0;                // Fast pip displace
extern bool            AlertsOn              = false;            // Turn alerts on?
extern bool            AlertsOnCurrent       = true;             // Alerts on current bar?
extern bool            AlertsMessage         = true;             // Alerts message?
extern bool            AlertsSound           = false;            // Alerts sound?
extern bool            AlertsEmail           = false;            // Alerts email?
extern bool            AlertsNotification    = false;            // Alerts push notification?
extern int             HistoWidth            = 3;                // Histogram bars width
extern color           UpHistoColor          = clrLimeGreen;     // Up histogram color
extern color           DnHistoColor          = clrRed;           // Down histogram color
extern bool            verticalLinesVisible  = false;            // Show vertical lines
extern bool            linesOnNewest         = false;            // Vertical lines drawn on newest bar of higher time frame bar?
extern string          verticalLinesID       = "ptl Lines";      // Lines ID
extern color           verticalLinesUpColor  = clrDeepSkyBlue;   // Lines up color 
extern color           verticalLinesDnColor  = clrPaleVioletRed; // Lines down color
extern ENUM_LINE_STYLE verticalLinesStyle    = STYLE_DOT;        // Lines style
extern int             verticalLinesWidth    = 0;                // lines width


double line1[],line2[],hist1[],hist2[],trend[],trena[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotification,0,UpHistoColor,DnHistoColor,verticalLinesVisible,linesOnNewest,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesStyle,verticalLinesWidth,_buff,_ind)

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
   IndicatorBuffers(7);
      SetIndexBuffer(0,hist1); SetIndexStyle(0, DRAW_HISTOGRAM,EMPTY,HistoWidth,UpHistoColor);
      SetIndexBuffer(1,hist2); SetIndexStyle(1, DRAW_HISTOGRAM,EMPTY,HistoWidth,DnHistoColor); 
      SetIndexBuffer(2,trend);
      SetIndexBuffer(3,trena); 
      SetIndexBuffer(4,line1);
      SetIndexBuffer(5,line2);
      SetIndexBuffer(6,count);
         indicatorFileName = WindowExpertName();
         TimeFrame         = fmax(TimeFrame,_Period);  
   IndicatorShortName(timeFrameToString(TimeFrame)+" ptl histo");
   return(0);
}

//
//
//
//
//

int deinit() 
{ 
   string tlookFor       = verticalLinesID+":";
   int    tlookForLength = StringLen(tlookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,tlookForLength) == tlookFor) ObjectDelete(objectName);
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
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame != _Period)
         {
            limit = (int)MathMax(limit,fmin(Bars-1,_mtfCall(6,0)*TimeFrame/_Period));
            for (int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
               hist1[i] = _mtfCall(0,y);
               hist2[i] = _mtfCall(1,y);
            }
   return(0);
   }            

   //
   //
   //
   //
   //
      
   double pipMultiplier = Point*MathPow(10,Digits%2);
      for (int i = limit; i >= 0; i--)
      {   
         double thigh1 = High[iHighest(NULL, 0, MODE_HIGH,SlowLength,i)] + SlowPipDisplace*pipMultiplier;
         double tlow1  = Low[iLowest(NULL,   0, MODE_LOW, SlowLength,i)] - SlowPipDisplace*pipMultiplier;
         double thigh2 = High[iHighest(NULL, 0, MODE_HIGH,FastLength,i)] + FastPipDisplace*pipMultiplier;
         double tlow2  = Low[iLowest(NULL,   0, MODE_LOW, FastLength,i)] - FastPipDisplace*pipMultiplier;
            if (i<Bars-1 && Close[i]>line1[i+1])
                  line1[i] = tlow1;
            else  line1[i] = thigh1;             
            if (i<Bars-1 && Close[i]>line2[i+1])
                  line2[i] = tlow2;
            else  line2[i] = thigh2;             
            
            //
            //
            //
            //
            //
            
            hist1[i] = EMPTY_VALUE;
            hist2[i] = EMPTY_VALUE;
            trena[i] = i<Bars-1 ? trena[i+1] : 0;
            trend[i] = 0;
               if (Close[i]<line1[i] && Close[i]<line2[i]) trend[i] =  1;
               if (Close[i]>line1[i] && Close[i]>line2[i]) trend[i] = -1;
               if (line1[i]>line2[i] || trend[i] ==  1)    trena[i] =  1;
               if (line1[i]<line2[i] || trend[i] == -1)    trena[i] = -1;
               if (trena[i]== 1) hist2[i] = 1;
               if (trena[i]==-1) hist1[i] = 1;
            
            //
            //
            //
            //
            //
         
            if (verticalLinesVisible)
            {
               string tlookFor = verticalLinesID+":"+(string)Time[i]; ObjectDelete(tlookFor);  
               if (i<Bars-1 && trena[i]!=trena[i+1])
               {
                  if (trena[i] ==-1) drawLine(i,verticalLinesUpColor);
                  if (trena[i] == 1) drawLine(i,verticalLinesDnColor);
               }
             }   
             
      }
      manageAlerts();
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
      int whichBar = (AlertsOnCurrent) ? 0 : 1;
      if (hist1[whichBar] != EMPTY_VALUE || hist2[whichBar] != EMPTY_VALUE)
      {
         static datetime time1 = 0;
         static string   mess1 = "";
            if (hist1[whichBar] != EMPTY_VALUE) doAlert(time1,mess1," ptl trend changed to up");
            if (hist2[whichBar] != EMPTY_VALUE) doAlert(time1,mess1," ptl trend changed to down");
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

       message = _Symbol+" "+timeFrameToString(_Period)+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" ptl "+doWhat;
          if (AlertsMessage)      Alert(message);
          if (AlertsEmail)        SendMail(Symbol()+" ptl",message);
          if (AlertsNotification) SendNotification(message);
          if (AlertsSound)        PlaySound("alert2.wav");
   }
}

//
//
//
//
//

void drawLine(int i,color theColor)
{
      string name = verticalLinesID+":"+(string)Time[i];
   
      //
      //
      //
      //
      //
         
      datetime time = Time[i]; if (linesOnNewest) time += _Period*60-1;    
      ObjectCreate(name,OBJ_VLINE,0,time,0);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_STYLE,verticalLinesStyle);
         ObjectSet(name,OBJPROP_WIDTH,verticalLinesWidth);
         ObjectSet(name,OBJPROP_BACK,true);
}
