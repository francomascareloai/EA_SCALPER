//+------------------------------------------------------------------+
//|                                                       DIDI Index |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_width3 2

extern string  TimeFrame         = "Current time frame";
extern int     Curta_Length      = 3;
extern int     Media_Length      = 8;
extern int     Longa_Length      = 20;
extern int     Method            = 1;   // 0 - SMA// 1 - EMA// 2 - SMMA// 3 - LWMA
extern int     Price             = 0;   // Applied price// 0 - Close// 1 - Open// 2 - High// 3 - Low// 4 - Median// 5 - Typical// 6 - Weighted  
extern bool    alertsOn          = true;
extern bool    alertsOnCurrent   = true;
extern bool    alertsMessage     = true;
extern bool    alertsSound       = false;
extern bool    alertsNotify      = true;
extern bool    alertsEmail       = true;
extern string  soundFile         = "alert2.wav"; 
extern bool    ShowLines         = false;
extern string  LinesIdentifier   = "didiLines1";
extern color   LinesColorForUp   = LimeGreen;
extern color   LinesColorForDown = Red;
extern int     LinesStyle        = STYLE_DOT;

double Curta[], Media[], Longa[], trend[];
string indicatorFileName;
bool   returnBars;
int    timeFrame;

int init()
{
 IndicatorBuffers(4);
 SetIndexBuffer(0,Curta);
 SetIndexBuffer(1,Media);
 SetIndexBuffer(2,Longa);
 SetIndexBuffer(3,trend);
 
 indicatorFileName = WindowExpertName();
 returnBars        = TimeFrame == "returnBars";     if (returnBars)     return(0);
 timeFrame         = stringToTimeFrame(TimeFrame);
 
 IndicatorShortName(timeFrameToString(timeFrame)+" Didi index");
 return(0);
}

int deinit()
{
   int lookForLength = StringLen(LinesIdentifier);
   for (int i=ObjectsTotal(); i>=0; i--)
      {
         string name = ObjectName(i);
         if (StringSubstr(name,0,lookForLength)==LinesIdentifier) ObjectDelete(name);
      }
   return(0);
}


int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { Curta[0] = limit+1; return(0); }
             if (timeFrame!=Period())
             {
               limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
               for (int i=limit; i>=0; i--)
               {
                   int y = iBarShift(NULL,timeFrame,Time[i]);               
                      Curta[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Curta_Length,Media_Length,Longa_Length,Method,Price,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,LinesIdentifier,LinesColorForUp,LinesColorForDown,LinesStyle,0,y);
                      Media[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Curta_Length,Media_Length,Longa_Length,Method,Price,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,LinesIdentifier,LinesColorForUp,LinesColorForDown,LinesStyle,1,y);
                      Longa[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Curta_Length,Media_Length,Longa_Length,Method,Price,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowLines,LinesIdentifier,LinesColorForUp,LinesColorForDown,LinesStyle,2,y);
               }      
            return(0);
            }
            
           for (i=limit; i>=0; i--)
            {
               double M_MA = iMA(NULL, 0, Media_Length, 0, Method, Price,i);
               if (M_MA>0)
                 Curta[i] = iMA(NULL, 0, Curta_Length, 0, Method, Price, i)/M_MA;
                 Media[i] = 1;
                 Longa[i] = iMA(NULL, 0, Longa_Length, 0, Method, Price, i)/M_MA;
                 trend[i] = trend[i+1];
                    if (Curta[i]>Longa[i]) trend[i] = 1; 
                    if (Curta[i]<Longa[i]) trend[i] =-1; 
              
              if (ShowLines)
              {
                deleteLine(i);
                if (trend[i]!=trend[i+1])
                if (trend[i]==1)
                      drawLine(i,LinesColorForUp);
                else  drawLine(i,LinesColorForDown);
              } 
              
              
   }
   
  if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("up");
      else  doAlert("down");       
   }
 
 return(0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
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


string stringUpperCase(string str)
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          message =  StringConcatenate(timeFrameToString(timeFrame)+" "+Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Didi_index trend changed to ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," Didi_index " +" "+message));
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Didi_index "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
void deleteLine(int i)
{
   ObjectDelete(LinesIdentifier+":"+Time[i]);
}
void drawLine(int i, color theColor)
{
   string name = LinesIdentifier+":"+Time[i];
   if (ObjectFind(name)<0)
       ObjectCreate(name,OBJ_VLINE,0,Time[i],0);
       ObjectSet(name,OBJPROP_COLOR,theColor);
       ObjectSet(name,OBJPROP_BACK,true);
       ObjectSet(name,OBJPROP_STYLE,LinesStyle);
}