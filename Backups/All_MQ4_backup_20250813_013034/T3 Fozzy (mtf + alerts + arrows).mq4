//+------------------------------------------------------------------+
//|                Fozzy Daily Indicator                           |
//|                Programmed by Aidrian O'Connor                  |
//|                http://www.unitone.org            |
//+------------------------------------------------------------------+
#property copyright "Fozzy"
#property link      "http://"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrAqua
#property indicator_color2  clrRed
#property indicator_color3  clrMediumSeaGreen
#property indicator_color4  clrMediumSeaGreen
#property indicator_color5  clrMediumSeaGreen
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_style5  STYLE_DOT
#property strict

extern ENUM_TIMEFRAMES TimeFrame               = PERIOD_CURRENT;    // Time frame to use
input int              RSIPeriod               = 8;                    // Rsi period
extern int             T3Period                = 8;                    // T3 period
extern double          T3Hot                   = 0.63;                 // T3 hot
extern bool            T3Original              = false;                // T3 original
input int              BandsPeriod             = 20;                   // Bands period
input int              BandsShift              = 0;                    // Bands shift
input double           BandsDeviations         = 2.0;                  // Bands deviations
input string           note                    = "turn on Alert = true; turn off = false";
input bool             alertsOn                = false;                 // Turn alerts on?
input bool             alertsOnCurrent         = true;                  // Alerts on current bar?
input bool             alertsMessage           = true;                  // Alerts message?
input bool             alertsSound             = false;                 // Alerts sound?
input bool             alertsEmail             = false;                 // Alerts email?
input bool             alertsNotify            = false;                 // Alerts push notification true/false?
input string           soundFile               = "alert2.wav";          // Sound file
input bool             arrowsVisible           = false;                 // Arrows visible true/false?
input bool             arrowsOnNewest          = false;                 // Arrows drawn on newest bar of higher time frame bar true/false?
input string           arrowsIdentifier        = "eco Arrows1";         // Unique ID for arrows
input double           arrowsUpperGap          = 0.5;                   // Upper arrow gap
input double           arrowsLowerGap          = 0.5;                   // Lower arrow gap
input color            arrowsUpColor           = clrBlue;               // Up arrow color
input color            arrowsDnColor           = clrCrimson;            // Down arrow color
input int              arrowsUpCode            = 233;                   // Up arrow code
input int              arrowsDnCode            = 234;                   // Down arrow code
input int              arrowsUpSize            = 2;                     // Up arrow size
input int              arrowsDnSize            = 2;                     // Down arrow size
input bool             Interpolate             = true;                  // Interpolate in multi time frame mode?

//---- buffers
double RSI[],RSIMA[],BBMid[],BBUp[],BBDn[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RSIPeriod,T3Period,T3Hot,T3Original,BandsPeriod,BandsShift,BandsDeviations,"",alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,_buff,_ind)
  
int OnInit()
{
   IndicatorBuffers(7);
   SetIndexBuffer(0,RSI,  INDICATOR_DATA); SetIndexStyle(0,DRAW_LINE); SetIndexLabel(0,"RSI");
   SetIndexBuffer(1,RSIMA,INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE); SetIndexLabel(1,"RSI-MA");
   SetIndexBuffer(2,BBMid,INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE); SetIndexLabel(2,"BB-Mid");
   SetIndexBuffer(3,BBUp, INDICATOR_DATA); SetIndexStyle(3,DRAW_LINE); SetIndexLabel(3,"BB-Up");
   SetIndexBuffer(4,BBDn, INDICATOR_DATA); SetIndexStyle(4,DRAW_LINE); SetIndexLabel(4,"BB-Dn");
   SetIndexBuffer(5,trend);
   SetIndexBuffer(6,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(TimeFrame)+" T3 Fozzy");
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

//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i,limit=fmin(rates_total-prev_calculated+1,rates_total-1); count[0]=limit;
      if (TimeFrame!=_Period)
      {
         limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(6,0)*TimeFrame/_Period));
         for (i=limit;i>=0 && !_StopFlag; i--)
         {
            int y = iBarShift(NULL,TimeFrame,time[i]);
               RSI[i]   = _mtfCall(0,y);
               RSIMA[i] = _mtfCall(1,y);
               BBMid[i] = _mtfCall(2,y);
               BBUp[i]  = _mtfCall(3,y);
               BBDn[i]  = _mtfCall(4,y);
                 
               //
               //
               //
               //
               //
                     
               if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                  #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                  int n,k; datetime dtime = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<rates_total && time[i+n] >= dtime; n++) continue;	
                     for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                     {
                        _interpolate(RSI); 
                        _interpolate(RSIMA); 
                        _interpolate(BBMid); 
                        _interpolate(BBUp); 
                        _interpolate(BBDn); 
                     }                                                 
          }  
   return(rates_total);
   }    
      
   //
   //
   //
   //
   //
       
   for(i=limit; i>=0; i--)
   {
      RSI[i]   = iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i);
      RSIMA[i] = iT3(RSI[i],T3Period,T3Hot,T3Original,i,rates_total);
      BBMid[i] = iMAOnArray(RSIMA,rates_total,BandsPeriod,BandsShift,MODE_SMA,i);
      BBUp[i]  = iBandsOnArray(RSIMA,rates_total,BandsPeriod,BandsDeviations,BandsShift,MODE_UPPER,i);
      BBDn[i]  = iBandsOnArray(RSIMA,rates_total,BandsPeriod,BandsDeviations,BandsShift,MODE_LOWER,i);
      trend[i] = (RSI[i]>RSIMA[i]) ? 1 : (RSI[i]<RSIMA[i]) ? -1 : (i<rates_total-1) ? trend[i+1] : 0;
      
      //
      //
      //
      //
      //
      
      if (arrowsVisible)
      {
        string lookFor = arrowsIdentifier+":"+(string)time[i]; ObjectDelete(lookFor);            
         if (i<(rates_total-1) && trend[i] != trend[i+1])
         {
            if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
            if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
         }
      }        
      
      
   }
   
   if (alertsOn)
   {
     int whichBar = (alertsOnCurrent) ? 0 : 1;
     if (trend[whichBar] != trend[whichBar+1])
     if (trend[whichBar] == 1)
           doAlert("Buy");
     else  doAlert("Sell");       
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Fozzy "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" Fozzy ",message);
             if (alertsSound)   PlaySound(soundFile);
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

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime atime = Time[i]; //if (arrowsOnNewest) atime += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,atime,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize);
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

           