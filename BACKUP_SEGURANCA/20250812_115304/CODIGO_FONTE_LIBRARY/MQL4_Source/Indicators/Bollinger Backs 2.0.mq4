#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  White
#property indicator_color2  Crimson
#property indicator_color3  DodgerBlue
#property indicator_color4  DodgerBlue
#property indicator_color5  Crimson

extern string TimeFrame         = "current time frame";
extern int    BandsLength       = 20;
extern double BandsDeviation    = 2.0; 
extern int    AppliedPrice      = 0;
extern int    BandsMaMode       = 0;

input color colorUpper = DarkOrchid;
input color colorMiddle = Indigo;
input color colorLower = DarkOrchid;

extern string note              = "turn on Alert = true; turn off = false";
extern bool   alertsOn          = false;
extern bool   alertsOnCurrent   = true;
extern bool   alertsMessage     = true;
extern bool   alertsSound       = true;
extern bool   alertsNotify      = false;
extern bool   alertsEmail       = false;
extern string soundFile         = "alert2.wav";

extern int    arrowthickness     = 1;

double Ma[];
double UpMa[];
double DnMa[];
double CrossUp[];
double CrossDn[];
double trend[];

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

int init()
{
  IndicatorBuffers(6);
  IndicatorDigits(Digits);
   SetIndexBuffer(0,Ma); SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 0, colorMiddle);
   SetIndexBuffer(1,UpMa); SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 0, colorUpper);
   SetIndexBuffer(2,DnMa); SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 0, colorLower);
   SetIndexBuffer(3,CrossUp); SetIndexStyle(3,DRAW_ARROW,0,arrowthickness); SetIndexArrow(3,233);
   SetIndexBuffer(4,CrossDn ); SetIndexStyle(4,DRAW_ARROW,0,arrowthickness); SetIndexArrow(4,234);
   SetIndexBuffer(5,trend);
   
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame=="returnBars";     if (returnBars)     return(0);
      calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      
  IndicatorShortName(timeFrameToString(timeFrame)+" Bollinger Bands Alerts Arrows");    
return(0);
}

int deinit() { return(0); }

int start()
  {
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-1,Bars-counted_bars-1);
           if (returnBars)  { Ma[0] = limit+1; return(0); }

   
   if (calculateValue || timeFrame==Period())
   {       
     for (i = limit; i >= 0; i--)
     {
         double StdDev  = iStdDev(NULL,0,BandsLength,0,BandsMaMode,AppliedPrice,i); 
                Ma[i]   = iMA(NULL,0,BandsLength,0,BandsMaMode,AppliedPrice,i);
                UpMa[i] = Ma[i] + (StdDev*BandsDeviation);
                DnMa[i] = Ma[i] - (StdDev*BandsDeviation);
                trend[i] = 0;
                if (Close[i]>UpMa[i]) trend[i] = 1;
                if (Close[i]<DnMa[i]) trend[i] =-1; 
                
                //
                //
                //
                //
                //
                
                CrossUp[i] = EMPTY_VALUE;
                CrossDn[i] = EMPTY_VALUE;
                if (trend[i]!= trend[i+1])
                  if (trend[i+1] ==  1 && trend[i] != 1) CrossDn[i] = High[i] + iATR(NULL,0,20,i)/2;
                  if (trend[i+1] == -1 && trend[i] !=-1) CrossUp[i] = Low[i]  - iATR(NULL,0,20,i)/2;
            
         }  
      manageAlerts();
    return(0);
    }

      
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Ma[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",BandsLength,BandsDeviation,AppliedPrice,BandsMaMode,0,y);
         UpMa[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",BandsLength,BandsDeviation,AppliedPrice,BandsMaMode,1,y);
         DnMa[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",BandsLength,BandsDeviation,AppliedPrice,BandsMaMode,2,y);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",BandsLength,BandsDeviation,AppliedPrice,BandsMaMode,5,y);
         CrossUp[i] = EMPTY_VALUE;
         CrossDn[i] = EMPTY_VALUE;
         if (trend[i]!= trend[i+1])
            if (trend[i+1] ==  1 && trend[i] != 1) CrossDn[i] = High[i] + iATR(NULL,0,20,i)/2;
            if (trend[i+1] == -1 && trend[i] !=-1) CrossUp[i] = Low[i]  - iATR(NULL,0,20,i)/2;
    }
    manageAlerts();         
return(0);            
}


void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar+1] ==  1 && trend[whichBar] != 1) doAlert(whichBar,"sell");
         if (trend[whichBar+1] == -1 && trend[whichBar] !=-1) doAlert(whichBar,"buy");
      }         
   }
}   


void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(Period())+" Bollinger Bands ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Bollinger Bands "),message);
          if (alertsSound)   PlaySound(soundFile);
   }
}


string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}