//+------------------------------------------------------------------+
//|                                                         OBV2.mq4 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  DodgerBlue
#property indicator_color2  Gray
#property indicator_color3  Gray
#property indicator_width1  2
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;// Time frame to use
extern int    BandPeriod         = 20;            // Bands period
extern double BandDeviation      = 3.00;          // Bands deviation
extern bool   alertsOn           = false;         // Turn alerts on?
extern bool   alertsOnCurrent    = false;         // Alerts on a current bar?
extern bool   alertsMessage      = true;          // Alerts should show pop-up message?
extern bool   alertsSound        = false;         // Alerts should play alert sound?
extern bool   alertsEmail        = false;         // Alerts should send email?
extern bool   arrowsVisible      = true;          // Arrows visible?
extern string arrowsIdentifier   = "obv arrows1"; // Arrows unique ID
extern double arrowsDisplacement = 1.0;           // Arros displacement (gap)
extern color  arrowsUpColor      = clrLimeGreen;  // Arrows up color
extern color  arrowsDnColor      = clrRed;        // Arrows down color
extern bool   Interpolate        = true;          // Interpolate in multi time frame mode?

//
//
//
//

double obv[];
double bandUp[];
double bandDn[];
double trend[];
string indicatorFileName;
bool   returnBars;

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(4); 
   SetIndexBuffer(0,obv);
   SetIndexBuffer(1,bandUp);
   SetIndexBuffer(2,bandDn);
   SetIndexBuffer(3,trend);
            indicatorFileName = WindowExpertName();
            returnBars        = TimeFrame==-99;
            TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" obv2 bands");
   return(0);
}

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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
            if (returnBars) { obv[0] = MathMin(limit+1,Bars-1); return(0); }
            if (TimeFrame != _Period)
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  obv[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,0,y);
                  bandUp[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,1,y);
                  bandDn[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,2,y);

                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  int n,k; datetime time = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                     for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                     {
                           obv[i+k]    = obv[i]    + (obv[i+n]    - obv[i]   ) * k/n;
                           bandUp[i+k] = bandUp[i] + (bandUp[i+n] - bandUp[i]) * k/n;
                           bandDn[i+k] = bandDn[i] + (bandDn[i+n] - bandDn[i]) * k/n;
                     }                           
               }
               return(0);
            }

   //
   //
   //
   //
   //

   for (int i=limit; i>=0; i--)
   {
      if (i==(Bars-1))                                                                     { obv[i] = (double)Volume[i]; }
      else  { if((High[i] == Low[i]) || (Open[i] == Close[i]) || (Close[i] == Close[i+1])) { obv[i] = obv[i+1];  }
      
      else  { if (Close[i] > Open[i])   
                   obv[i] = obv[i+1] + (Volume[i] * (Close[i] - Open[i]) / (High[i] - Low[i]));
              else obv[i] = obv[i+1] - (Volume[i] * (Open[i] - Close[i]) / (High[i] - Low[i])); } }
   }
   for (int i=limit; i>=0; i--)
   {
      bandUp[i] = iBandsOnArray(obv,0,BandPeriod,BandDeviation,0,MODE_UPPER,i);
      bandDn[i] = iBandsOnArray(obv,0,BandPeriod,BandDeviation,0,MODE_LOWER,i);
      if (i<(Bars-1))
      trend[i] = trend[i+1];
         if (obv[i] < bandDn[i]) trend[i] =-1;
         if (obv[i] > bandUp[i]) trend[i] = 1; 
         manageArrow(i);            
   }
   manageAlerts();
   return( 0 );
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
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
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

       message = timeFrameToString(_Period)+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" obv bands trend changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" obv bands ",message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//
//
//
//
//

void manageArrow(int i)
{
   if (arrowsVisible)
   {
      string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);
      if (i<(Bars-1) && trend[i]!=trend[i+1])
      {
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,241,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,242,true);
      }
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
  
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsDisplacement * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsDisplacement * gap);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}