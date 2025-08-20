//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrRed
#property indicator_color3  clrRed
#property indicator_color4  clrLimeGreen
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrSilver
#property indicator_color7  clrSilver
#property indicator_style6  STYLE_DOT
#property indicator_style7  STYLE_DOT
#property strict

//
//
//
//
//

#define _disLin 1
#define _disBar 2
#define _disDot 4

enum enDisplay
{
   en_lin = _disLin,                  // Display line
   en_his = _disBar,                  // Display colored bars
   en_all = _disLin+_disBar,          // Display colored lines and bars
   en_lid = _disLin+_disDot,          // Display lines with dots
   en_hid = _disBar+_disDot,          // Display colored bars with dots
   en_ald = _disLin+_disBar+_disDot,  // Display colored lines and bars with dots
   en_dot = _disDot                   // Display dots
};

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;   // Time frame to use
extern int             HighLowPeriod   = 10;               // High low period
extern int             ClosePeriod     =  0;               // Close period
extern double          Hot             = 0.7;              // T3 Hot
extern bool            OriginalT3      = false;            // T3 Original
extern enDisplay       DisplayType     = en_lin;           // Display type
extern int             LinesWidth      = 3;                // Lines width (when lines are included in display)
extern int             BarsWidth       = 1;                // Bars width (when bars are included in display)
extern bool            alertsOn        = false;            // Turn alerts on?
extern bool            alertsOnCurrent = true;             // Alerts on current (still opened) bar?
extern bool            alertsMessage   = true;             // Alerts should show pop-up message?
extern bool            alertsSound     = false;            // Alerts should play alert sound?
extern bool            alertsPushNotif = false;            // Alerts should send push notification?
extern bool            alertsEmail     = false;            // Alerts should send email?
extern double          UpPips          = 0;                // Upper band in pips (<= 0 - no band)
extern double          DnPips          = 0;                // Lower band in pips (<= 0 - no band)
extern int             UpArrowSize     = 2;                // Up Arrow size
extern int             DnArrowSize     = 2;                // Down Arrow size
extern color           UpArrowColor    = clrLimeGreen;     // Up Arrow Color
extern color           DnArrowColor    = clrRed;           // Down Arrow Color
extern int             ArrowCodeUp     = 159;              // Arrow code up
extern int             ArrowCodeDn     = 159;              // Arrow code down
extern double          ArrowGapUp      = 0.5;              // Gap for arrow up        
extern double          ArrowGapDn      = 0.5;              // Gap for arrow down
extern bool            ArrowOnFirst    = true;             // Arrow on first bars
extern bool            Interpolate     = true;             // Interpolate in multi time frame mode?

double histou[],histod[],hla[],hlda[],hldb[],bandUp[],bandDn[],arrowu[],arrowd[],Hlv[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HighLowPeriod,ClosePeriod,Hot,OriginalT3,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,UpPips,DnPips,UpArrowSize,DnArrowSize,UpArrowColor,DnArrowColor,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowOnFirst,_buff,_ind)

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
   IndicatorBuffers(11);
   int lstyle = DRAW_LINE;      if ((DisplayType&_disLin)==0) lstyle = DRAW_NONE;
   int hstyle = DRAW_HISTOGRAM; if ((DisplayType&_disBar)==0) hstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;     if ((DisplayType&_disDot)==0) astyle = DRAW_NONE;
   SetIndexBuffer(0, histou);  SetIndexStyle(0,hstyle,EMPTY,BarsWidth);
   SetIndexBuffer(1, histod);  SetIndexStyle(1,hstyle,EMPTY,BarsWidth);
   SetIndexBuffer(2, hla);     SetIndexStyle(2,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(3, hlda);    SetIndexStyle(3,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(4, hldb);    SetIndexStyle(4,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(5, bandUp);
   SetIndexBuffer(6, bandDn);
   SetIndexBuffer(7, arrowu);  SetIndexStyle(7,astyle,0,UpArrowSize,UpArrowColor); SetIndexArrow(7,ArrowCodeUp);
   SetIndexBuffer(8, arrowd);  SetIndexStyle(8,astyle,0,DnArrowSize,DnArrowColor); SetIndexArrow(8,ArrowCodeDn);
   SetIndexBuffer(9, Hlv);
   SetIndexBuffer(10,count);
      HighLowPeriod = fmax(HighLowPeriod,1);
      if (ClosePeriod == 0)
          ClosePeriod = HighLowPeriod;
          ClosePeriod = fmax(ClosePeriod,1);
          
     indicatorFileName = WindowExpertName();
     TimeFrame         = fmax(TimeFrame,_Period); 
      
   IndicatorShortName(timeFrameToString(TimeFrame)+" Gann T3 high-low activator");     
   return(0);
}
int deinit() { return(0); }       
          
//
//
//
//
//

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(10,0)*TimeFrame/_Period));
               if (Hlv[limit]==1) CleanPoint(limit,hlda,hldb);
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  int x = y;
                  if (ArrowOnFirst)
                        {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);               }
                  else  {  if (i>0)      x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
                     hla[i]    = _mtfCall(2,y);
                     bandUp[i] = _mtfCall(5,y);
                     bandDn[i] = _mtfCall(6,y);
                     Hlv[i]    = _mtfCall(9,y);
                     hlda[i]    = EMPTY_VALUE;
                     hldb[i]    = EMPTY_VALUE;
                     arrowu[i]  = EMPTY_VALUE;
                     arrowd[i]  = EMPTY_VALUE;
                     histou[i]  = EMPTY_VALUE;
                     histod[i]  = EMPTY_VALUE;
                     if (x!=y)
                     {
                       arrowu[i] = _mtfCall(7,y);
                       arrowd[i] = _mtfCall(8,y);
                     }
                     if (Hlv[i]==-1) { histou[i] = Low[i]; histod[i] = High[i]; }
                     if (Hlv[i]== 1) { histod[i] = Low[i]; histou[i] = High[i]; }

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
                             _interpolate(hla);    
                             _interpolate(bandUp);   
                             _interpolate(bandDn);    
                         }                                  
                  }
                  for (i=limit;i>=0;i--) if (Hlv[i] == 1) PlotPoint(i,hlda,hldb,hla);
     return(0);
     }
     
     //
     //
     //
     //
     //
     
     if (Hlv[limit]==1) CleanPoint(limit,hlda,hldb);
     for (i=limit; i>=0; i--)
     {
       if (i<Bars-1)
       {
          double cl = iT3(Close[i] ,ClosePeriod,  Hot,OriginalT3,i,0);
          double hi = iT3(High[i+1],HighLowPeriod,Hot,OriginalT3,i,1);
          double lo = iT3(Low[i+1] ,HighLowPeriod,Hot,OriginalT3,i,2);
          hlda[i]   = EMPTY_VALUE;
          hldb[i]   = EMPTY_VALUE;
          arrowu[i] = EMPTY_VALUE;
          arrowd[i] = EMPTY_VALUE;
          histou[i] = EMPTY_VALUE;
          histod[i] = EMPTY_VALUE;
       
          Hlv[i] = (i<Bars-1) ? (cl>hi)  ? 1 : (cl<lo) ? -1 : Hlv[i+1] : 0;
          if (Hlv[i] ==-1) { hla[i] = hi;}
          if (Hlv[i] == 1) { hla[i] = lo;  PlotPoint(i,hlda,hldb,hla); } 
          if (Hlv[i]==-1) { histou[i] = Low[i]; histod[i] = High[i]; }
          if (Hlv[i]== 1) { histod[i] = Low[i]; histou[i] = High[i]; }
          if (UpPips>0) bandUp[i] = hla[i]+UpPips*_Point*MathPow(10,_Digits%2);    
          if (DnPips>0) bandDn[i] = hla[i]-DnPips*_Point*MathPow(10,_Digits%2);    
          if (i<Bars-1 && Hlv[i]!= Hlv[i+1])
          {
             if (Hlv[i] ==  1) arrowu[i] = MathMin(hla[i],Low[i] )-iATR(NULL,0,15,i)*ArrowGapUp;
             if (Hlv[i] == -1) arrowd[i] = MathMax(hla[i],High[i])+iATR(NULL,0,15,i)*ArrowGapDn;
          }
       }     
   }
   manageAlerts();
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

#define t3Instances 3
double workT3[][t3Instances*6];
double workT3Coeffs[][6];
#define _tperiod 0
#define _c1      1
#define _c2      2
#define _c3      3
#define _c4      4
#define _alpha   5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int tinstanceNo=0)
{
   if (ArrayRange(workT3,0) != Bars)                 ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (tinstanceNo+1)) ArrayResize(workT3Coeffs,tinstanceNo+1);

   if (workT3Coeffs[tinstanceNo][_tperiod] != period)
   {
     workT3Coeffs[tinstanceNo][_tperiod] = period;
        double a = hot;
            workT3Coeffs[tinstanceNo][_c1] = -a*a*a;
            workT3Coeffs[tinstanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[tinstanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[tinstanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[tinstanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[tinstanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int instanceNo = tinstanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+instanceNo] = price;
         workT3[r][1+instanceNo] = price;
         workT3[r][2+instanceNo] = price;
         workT3[r][3+instanceNo] = price;
         workT3[r][4+instanceNo] = price;
         workT3[r][5+instanceNo] = price;
      }
   else
      {
         workT3[r][0+instanceNo] = workT3[r-1][0+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(price                  -workT3[r-1][0+instanceNo]);
         workT3[r][1+instanceNo] = workT3[r-1][1+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][0+instanceNo]-workT3[r-1][1+instanceNo]);
         workT3[r][2+instanceNo] = workT3[r-1][2+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][1+instanceNo]-workT3[r-1][2+instanceNo]);
         workT3[r][3+instanceNo] = workT3[r-1][3+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][2+instanceNo]-workT3[r-1][3+instanceNo]);
         workT3[r][4+instanceNo] = workT3[r-1][4+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][3+instanceNo]-workT3[r-1][4+instanceNo]);
         workT3[r][5+instanceNo] = workT3[r-1][5+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][4+instanceNo]-workT3[r-1][5+instanceNo]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[tinstanceNo][_c1]*workT3[r][5+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c2]*workT3[r][4+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c3]*workT3[r][3+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c4]*workT3[r][2+instanceNo]);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
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
      if (Hlv[whichBar] != Hlv[whichBar+1])
      {
         if (Hlv[whichBar] ==  1) doAlert(whichBar,"up");
         if (Hlv[whichBar] == -1) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," T3 high-low activator slope changed to ",doWhat);
          if (alertsMessage)   Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," T3 high-low activator "),message);
          if (alertsPushNotif) SendNotification(message);
          if (alertsSound)     PlaySound("alert2.wav");
   }
}