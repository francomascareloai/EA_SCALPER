//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 4

#property indicator_label1  "Level"
#property indicator_color1  clrDimGray
#property indicator_style1  STYLE_DOT

#property indicator_label2  "Trend trigger factor"
#property indicator_color2  clrDimGray
#property indicator_width2  2

#property indicator_label3  "Up signal"
#property indicator_color3  clrDeepSkyBlue
#property indicator_width3  2

#property indicator_label4  "Down signal"
#property indicator_color4  clrPaleVioletRed
#property indicator_width4  2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame    = PERIOD_CURRENT;     // Time frame
input int     TTFbars               = 15;                 // Trend trigger factor bars
input int     topLine               = 100;                // Upper level
input int     btmLine               = -100;               // Lower level
input double  t3Period              = 3;                  // T3 smoothing period
input double  t3Hot                 = 0.7;                // T3 Hot
input bool    t3Original            = false;              // T3 original Tim Tillson calculation
input bool    ShowTopBtmLevels      = true;               // Show top and bottom levels true/false?
input bool    showSignals           = true;               // Show colored signals true/false?
input bool    alertsOn              = true;               // Alerts on true/false?
input bool    alertsOnCurrent       = false;              // Alerts on current open bar true/false?
input bool    alertsMessage         = true;               // Alerts pop-up message true/false?
input bool    alertsSound           = false;              // Alerts sound true/false?
input bool    alertsEmail           = false;              // Alerts email true/false?
input bool    alertsNotify          = false;              // Alerts push notification true/false?
input bool    arrowsVisible         = false;              // Show arrows true/false? 
input bool    arrowsOnNewest        = true;               // Arrows newest higher time frame bar true/false?
input double  arrowsUpperGap        = 0.5;                // Upper arrow gap
input double  arrowsLowerGap        = 0.5;                // Lower arrow gap
input string  arrowsIdentifier      = "TS Arrows1";       // Arrows ID
input bool    arrowsOnZeroCross     = false;              // Arrows on zero cross true/false?
input bool    arrowsOnLevelsBreak   = true;               // Arrows on levels break true/false? 
input bool    arrowsOnLevelsRetrace = false;              // Arrows on levels retrace true/false?
input color   arrowsUpColor         = clrDeepSkyBlue;     // Arrows up color
input color   arrowsDnColor         = clrRed;             // Arrows down color
input bool    Interpolate           = true;               // Interpolate in multi time frame true/false?

double ttf[],lev[],sigu[],sigd[],trend[],trends[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,TTFbars,topLine,btmLine,t3Period,t3Hot,t3Original,ShowTopBtmLevels,showSignals,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,arrowsVisible,arrowsOnNewest,arrowsUpperGap,arrowsLowerGap,arrowsIdentifier,arrowsOnZeroCross,arrowsOnLevelsBreak,arrowsOnLevelsRetrace,arrowsUpColor,arrowsDnColor,_buff,_ind)

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,lev,   INDICATOR_DATA); SetIndexStyle(0,DRAW_LINE);
      SetIndexBuffer(1,ttf,   INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE);
      SetIndexBuffer(2,sigu,  INDICATOR_DATA); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,159); 
      SetIndexBuffer(3,sigd,  INDICATOR_DATA); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159); 
      SetIndexBuffer(4,trend, INDICATOR_CALCULATIONS);
      SetIndexBuffer(5,trends,INDICATOR_CALCULATIONS);
      SetIndexBuffer(6,count, INDICATOR_CALCULATIONS);
      
      IndicatorSetInteger(INDICATOR_LEVELS,1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0);
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DOT);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMediumOrchid);
      
      indicatorFileName = WindowExpertName();
      TimeFrame         = fmax(TimeFrame,_Period);
      
      IndicatorShortName(timeFrameToString(TimeFrame)+" Trend scalp ("+(string)TTFbars+","+(string)t3Period+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{ 
    string lookFor       = arrowsIdentifier+":";
    int    lookForLength = StringLen(lookFor);
    for (int i=ObjectsTotal()-1; i>=0; i--)
    {
       string objectName = ObjectName(i);
       if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
    }
}


//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
{
   int i,counted_bars=prev_calculated;
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(rates_total-counted_bars,rates_total-2); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(6,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     lev[i]    = _mtfCall(0,y);
                     ttf[i]    = _mtfCall(1,y);
                     trend[i]  = _mtfCall(4,y);
                     trends[i] = _mtfCall(5,y);
                     
                     if (i<rates_total-1)
                     {
                       if (ShowTopBtmLevels)
                       {
                          trend[i] = trend[i+1];
                          if (ttf[i] > 0) trend[i] =  1;
                          if (ttf[i] < 0) trend[i] = -1;
                          if (trend[i]== 1) lev[i] = topLine;
                          if (trend[i]==-1) lev[i] = btmLine;
                       }
                       if (showSignals)
                       {
                          trends[i] = 0;
                          if (ttf[i] > topLine) trends[i] =  1;
                          if (ttf[i] < btmLine) trends[i] = -1;
                          if (trends[i]== 1) sigu[i] = topLine;
                          if (trends[i]==-1) sigd[i] = btmLine;
                       }
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<rates_total && Time[i+n] >= btime; n++) continue;	
                        for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) _interpolate(ttf);
                 }
            }       
   return(rates_total);
   }               

   //
   //
   //
   //
   //
   
   for(i=limit; i >= 0; i--)
   {
      double hhr = high[i]; double hho = High[iHighest(NULL,0,MODE_HIGH,TTFbars,(int)fmin(rates_total-1,i+1))];
      double llr = low[i];  double llo =  Low[iLowest( NULL,0,MODE_LOW, TTFbars,(int)fmin(rates_total-1,i+1))];
      double bp = hhr-llo;
      double sp = hho-llr;
            ttf[i]    = iT3((bp-sp)/(0.5*(bp+sp))*100.0,t3Period,t3Hot,t3Original,i,rates_total);
            
            if (ShowTopBtmLevels)
            {
               trend[i] = trend[i+1];
                  if (ttf[i] > 0) trend[i] =  1;
                  if (ttf[i] < 0) trend[i] = -1;
                  if (trend[i]== 1) lev[i] = topLine;
                  if (trend[i]==-1) lev[i] = btmLine;
            }
      
            if (showSignals)
            {
               sigu[i] = EMPTY_VALUE;
               sigd[i] = EMPTY_VALUE;
               trends[i] = 0;
                  if (ttf[i] > topLine) trends[i] =  1;
                  if (ttf[i] < btmLine) trends[i] = -1;
                  if (trends[i]== 1) sigu[i] = topLine;
                  if (trends[i]==-1) sigd[i] = btmLine;
            }
            
            //
            //
            //
            //
            //
            
            if (arrowsVisible)
            {
               ObjectDelete(arrowsIdentifier+":1:"+(string)Time[i]);
               ObjectDelete(arrowsIdentifier+":2:"+(string)Time[i]);
               string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);
               if (i<(rates_total-1) && arrowsOnZeroCross && trend[i] != trend[i+1])
               {
                  if (trend[i] ==  1) drawArrow("1",0.5,i,arrowsUpColor,241,false);
                  if (trend[i] == -1) drawArrow("1",0.5,i,arrowsDnColor,242,true);
               }
               if (arrowsOnLevelsBreak || arrowsOnLevelsRetrace)
               if (i<(rates_total-1) && trends[i]!=trends[i+1])
               {
                  if (arrowsOnLevelsBreak   && trends[i] == 1)                      drawArrow("2",1,i,arrowsUpColor,241,false);
                  if (arrowsOnLevelsBreak   && trends[i] ==-1)                      drawArrow("2",1,i,arrowsDnColor,242,true);
                  if (arrowsOnLevelsRetrace && trends[i] != 1 && trends[i+1] ==  1) drawArrow("2",1,i,arrowsDnColor,242,true);
                  if (arrowsOnLevelsRetrace && trends[i] !=-1 && trends[i+1] == -1) drawArrow("2",1,i,arrowsUpColor,241,false);
               }   
            }
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define t3Instances 1
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

double iT3(double price, double period, double hot, bool original, int i, int bars, int tinstanceNo=0)
{
   if (ArrayRange(workT3,0) != bars)                 ArrayResize(workT3,bars);
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
   int r = bars-i-1;
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

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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

        message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" trend scalp "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" trend scalp ",message);
             if (alertsSound)   PlaySound("alert2.wav");
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

void drawArrow(string nameAdd, double gapMul, int i, color theColor, int theCode, bool up)
{
   string name = arrowsIdentifier+":"+nameAdd+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i)*gapMul;   

   
      //
      //
      //
      //
      //

      datetime time = Time[i]; if (arrowsOnNewest) time += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
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


