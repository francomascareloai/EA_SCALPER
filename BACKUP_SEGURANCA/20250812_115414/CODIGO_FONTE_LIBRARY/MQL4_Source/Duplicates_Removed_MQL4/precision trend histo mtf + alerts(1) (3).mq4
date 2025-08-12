//+------------------------------------------------------------------+
//|                                              precision trend.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers  2
#property indicator_color1   clrGreen
#property indicator_color2   clrRed
#property indicator_width1   2
#property indicator_width2   2
#property indicator_minimum  0
#property indicator_maximum  1
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;   // Time frame
extern int             avgPeriod        = 30;               // Average period
extern double          sensitivity      = 3;                // Sensitivity
extern bool            alertsOn         = true;             // Turn alerts on?
extern bool            alertsOnCurrent  = false;            // Alerts on current (still opened) bar?
extern bool            alertsMessage    = true;             // Alerts showing a pop-up message?
extern bool            alertsPushNotif  = false;            // Alerts sending a push notification?
extern bool            alertsSound      = false;            // Alerts playing sound?
extern bool            alertsEmail      = false;            // Alerts sending email?
extern bool            alertsNotify     = false;            // Alerts send notification?
extern string          soundFile        = "alert2.wav";     // Alerts Sound File to use

double upBuffer[],dnBuffer[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,avgPeriod,sensitivity,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,alertsNotify,soundFile,_buff,_ind)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{ 
   IndicatorBuffers(3);
   SetIndexBuffer(0,upBuffer); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dnBuffer); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,count);
     
     indicatorFileName = WindowExpertName();
     TimeFrame         = MathMax(TimeFrame,_Period);
      IndicatorShortName(timeFrameToString(TimeFrame)+"  precision trend histo"); 
   return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double wrkBuffer[][7];
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(3,0)*TimeFrame/_Period));
               for (int i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     upBuffer[i] = _mtfCall(0,y);
                     dnBuffer[i] = _mtfCall(1,y);            
               }      
              return(0);
              }         
   //
   //
   //
   //
   //
   
    if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);        
   for(int i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      upBuffer[i]     = EMPTY_VALUE;
      dnBuffer[i]     = EMPTY_VALUE;
      wrkBuffer[r][0] = High[i]-Low[i];
      wrkBuffer[r][2] = wrkBuffer[r][0];
      int k=1; for (; k<avgPeriod && (r-k)>=0; k++) wrkBuffer[r][2] += wrkBuffer[r-k][0];
                                                    wrkBuffer[r][2] /= k;
                                                    wrkBuffer[r][2] *= sensitivity;
   
         //
         //
         //
         //
         //
         
         if (i==(Bars-1))
         {
            wrkBuffer[r][1] = 0;
            wrkBuffer[r][3] = Close[i]-wrkBuffer[r][2];
            wrkBuffer[r][4] = Close[i]+wrkBuffer[r][2];
            wrkBuffer[r][5] = Close[i];
            wrkBuffer[r][6] = Close[i];
            continue;
         }
         else
         {
            wrkBuffer[r][1] = wrkBuffer[r-1][1];
            wrkBuffer[r][3] = wrkBuffer[r-1][3];
            wrkBuffer[r][4] = wrkBuffer[r-1][4];
            wrkBuffer[r][5] = wrkBuffer[r-1][5];
            wrkBuffer[r][6] = wrkBuffer[r-1][6];
         }
         
         //
         //
         //
         //
         //

         if (wrkBuffer[r][1] == 0)
         {
            if (Close[i] > wrkBuffer[r-1][4])
            {
               wrkBuffer[r][5] = Close[i];
               wrkBuffer[r][3] = Close[i]-wrkBuffer[r][2];
               wrkBuffer[r][1] =  1;
            }
            if (Close[i] < wrkBuffer[r-1][3])
            {
               wrkBuffer[r][6] = Close[i];
               wrkBuffer[r][4] = Close[i]+wrkBuffer[r][2];
               wrkBuffer[r][1] = -1;
            }
         }            

         if (wrkBuffer[r-1][1] == 1)
         {
            wrkBuffer[r][3] = wrkBuffer[r-1][5] - wrkBuffer[r][2];
               if (Close[i] > wrkBuffer[r-1][5])  wrkBuffer[r][5] = Close[i];
               if (Close[i] < wrkBuffer[r-1][3])
               {
                  wrkBuffer[r][6] = Close[i];
                  wrkBuffer[r][4] = Close[i]+wrkBuffer[r][2];
                  wrkBuffer[r][1] = -1;
            }
         }            

         if (wrkBuffer[r-1][1] == -1)
         {
            wrkBuffer[r][4] = wrkBuffer[r-1][6] + wrkBuffer[r][2];
               if (Close[i] < wrkBuffer[r-1][6])  wrkBuffer[r][6] = Close[i];
               if (Close[i] > wrkBuffer[r-1][4])
               {
                  wrkBuffer[r][5] = Close[i];
                  wrkBuffer[r][3] = Close[i]-wrkBuffer[r][2];
                  wrkBuffer[r][1] = 1;
               }
         }
         
         //
         //
         //
         //
         //
                     
         if (wrkBuffer[r][1] == 1)
         {
            upBuffer[i] = 1; dnBuffer[i] = EMPTY_VALUE;
         }
         if (wrkBuffer[r][1] == -1)
         {
            dnBuffer[i] = 1; upBuffer[i] = EMPTY_VALUE;
         }            
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (upBuffer[whichBar+1] == EMPTY_VALUE && upBuffer[whichBar] != EMPTY_VALUE) doAlert(whichBar,"up signal");
      if (dnBuffer[whichBar+1] == EMPTY_VALUE && dnBuffer[whichBar] != EMPTY_VALUE) doAlert(whichBar,"down signal");  
   }       
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",timeFrameToString(_Period)+" precision trend ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " precision trend "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}
