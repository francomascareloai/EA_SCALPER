//+------------------------------------------------------------------+
//|                                                         OBV2.mq4 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DodgerBlue
#property indicator_color2  Gray
#property indicator_color3  Gray
#property indicator_color4  clrRed
#property indicator_color5  clrLime
#property indicator_width1  2
#property indicator_width4  3
#property indicator_width5  3
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
extern double BandDeviation      = 1.618;          // Bands deviation
extern bool   alertsOn           = true;         // Turn alerts on?
extern bool   alertsOnCurrent    = false;         // Alerts on a current bar?
extern bool   alertsMessage      = true;          // Alerts should show pop-up message?
extern bool   alertsSound        = true;         // Alerts should play alert sound?
extern bool   alertsEmail        = false;         // Alerts should send email?
extern bool   alertsMobile       = true;          // Alerts should send message to phone?
extern bool   arrowsVisible      = true;          // Arrows visible?
extern string arrowsIdentifier   = "obv 2'1 arrows"; // Arrows unique ID
extern double arrowsDisplacement = 1.0;           // Arros displacement (gap)
extern color  arrowsUpColor      = clrLimeGreen;  // Arrows up color
extern color  arrowsDnColor      = clrRed;        // Arrows down color
extern bool   Interpolate        = false;          // Interpolate in multi time frame mode?

//
//
//
//

double obv[];
double bandUp[];
double bandDn[];   double SEL[], BUY[];
double trend[];
string IndikName;
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
   IndicatorBuffers(6); 
   SetIndexBuffer(0,obv);      SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,bandUp);   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,bandDn);   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,SEL);      SetIndexStyle(3,DRAW_ARROW);   SetIndexArrow(3,167);
   SetIndexBuffer(4,BUY);      SetIndexStyle(4,DRAW_ARROW);   SetIndexArrow(4,167);
   SetIndexBuffer(5,trend); 



            IndikName = WindowExpertName();
            returnBars        = TimeFrame==-99;
            TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+": OBV 2 Bands");
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
   int CountedBars=IndicatorCounted();
      if(CountedBars<0) return(-1);
      if(CountedBars>0) CountedBars--;
         int limit = MathMin(Bars-CountedBars,Bars-1);
            if (returnBars) { obv[0] = MathMin(limit+1,Bars-1); return(0); }
            if (TimeFrame != _Period)
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,IndikName,-99,0,0)*TimeFrame/_Period));
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  int x = y;   if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);
                  if(x!=y) {
                     SEL[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsMobile,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,3,y); 
                     BUY[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsMobile,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,4,y); }
                  //---
                  obv[i]    = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsMobile,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,0,y);
                  bandUp[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsMobile,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,1,y);
                  bandDn[i] = iCustom(NULL,TimeFrame,IndikName,PERIOD_CURRENT,BandPeriod,BandDeviation,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsMobile,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,2,y);

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
      int whichBar = 1;   if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == -1) doAlert(whichBar,"DN");
         if (trend[whichBar] ==  1) doAlert(whichBar,"UP");
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

       message = timeFrameToString(_Period)+_Symbol+": OBV Bands trend changed to "+doWhat;   //" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(_Symbol+" OBV Bands ",message);
          if (alertsMobile)  SendNotification(message);
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
         if (trend[i] ==-1) { drawArrow(i,arrowsDnColor,242,true);    SEL[i]=obv[i]; }
         if (trend[i] == 1) { drawArrow(i,arrowsUpColor,241,false);   BUY[i]=obv[i]; }
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
         ObjectSet(name,OBJPROP_WIDTH,2);
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