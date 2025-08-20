//------------------------------------------------------------------
#property copyright "www.forex-tsd.com" 
#property link      "www.forex-tsd.com" 
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  LimeGreen
#property indicator_color2  Red
#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1


//
//
//
//
//

extern string TimeFrame        = "Current time frame";
extern double AccStep          = 0.01;
extern double AccLimit         = 0.1;
extern int    PriceHigh        = PRICE_HIGH;
extern int    PriceLow         = PRICE_LOW;
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsNotify     = true;
extern bool   alertsEmail      = true;
extern string soundFile        = "alert2.wav"; 

extern bool   ShowArrows       = true;
extern string arrowsIdentifier = "sar Arrows";
extern double arrowsUpperGap   = 1.0;
extern double arrowsLowerGap   = 1.0;

extern color  arrowsUpColor    = LimeGreen;
extern color  arrowsDnColor    = Red;
extern color  arrowsNuColor    = Gray;
extern int    arrowsUpCode     = 241;
extern int    arrowsDnCode     = 242;

double sarUp[];
double sarDn[];
double saraUp[];
double saraDn[];
double trend[];
int    timeFrame;

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
    IndicatorBuffers(5);
    SetIndexBuffer(0,sarUp);  SetIndexStyle(0,DRAW_HISTOGRAM);
    SetIndexBuffer(1,sarDn);  SetIndexStyle(1,DRAW_HISTOGRAM);
    SetIndexBuffer(2,saraUp); 
    SetIndexBuffer(3,saraDn); 
    SetIndexBuffer(4,trend);
    
    timeFrame = stringToTimeFrame(TimeFrame);
    IndicatorShortName(timeFrameToString(timeFrame)+" Parabolic SAR Histo");
return(0);
}
int deinit()
{
   deleteArrows();
  
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
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit=MathMax(Bars-counted_bars,3*timeFrame/Period());

   //
   //
   //
   //
   //
    
   for(int i = limit; i >= 0; i--)
   {
      double sarClose;
      double sarOpen;
      double sarPosition;
      double sarChange;
      int y = iBarShift(NULL,timeFrame,Time[i]);
      double pHigh = iMA(NULL,timeFrame,1,0,MODE_SMA,PriceHigh,y);
      double pLow  = iMA(NULL,timeFrame,1,0,MODE_SMA,PriceLow ,y);
         iParabolic(MathMax(pHigh,pLow),MathMin(pHigh,pLow),AccStep,AccLimit,sarClose,sarOpen,sarPosition,sarChange,i);
         sarUp[i]  = EMPTY_VALUE;
         sarDn[i]  = EMPTY_VALUE;
         saraUp[i] = EMPTY_VALUE;
         saraDn[i] = EMPTY_VALUE;
         if (sarPosition==1)
               sarUp[i] = sarClose;
         else  sarDn[i] = sarClose;
         if (sarChange!=0)
            if (sarChange==1)
                  saraUp[i] = sarClose;
            else  saraDn[i] = sarClose;
            trend[i] = trend[i+1];
              if (sarUp[i] !=  EMPTY_VALUE) trend[i] = 1;
              if (sarDn[i] !=  EMPTY_VALUE) trend[i] =-1;
              if (trend[i] == 1) sarUp[i] = 1;
              if (trend[i] ==-1) sarDn[i] = 1;
              manageArrow(i);
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

double workSar[][7];
#define _high     0
#define _low      1
#define _ohigh    2
#define _olow     3
#define _open     4
#define _position 5
#define _af       6

void iParabolic(double high, double low, double step, double limit, double& pClose, double& pOpen, double& pPosition, double& pChange, int i)
{
   if (ArrayRange(workSar,0)!=Bars) ArrayResize(workSar,Bars); i = Bars-i-1;
   
   //
   //
   //
   //
   //
   
      pChange = 0;
         workSar[i][_ohigh] = high;
         workSar[i][_olow]  = low;
            if (i<1)
               {
                  workSar[i][_high]     = high;
                  workSar[i][_low]      = low;
                  workSar[i][_open]     = high;
                  workSar[i][_position] = -1;
                  return;
               }
         workSar[i][_open]     = workSar[i-1][_open];
         workSar[i][_af]       = workSar[i-1][_af];
         workSar[i][_position] = workSar[i-1][_position];
         workSar[i][_high]     = MathMax(workSar[i-1][_high],high);
         workSar[i][_low]      = MathMin(workSar[i-1][_low] ,low );
      
   //
   //
   //
   //
   //
            
   if (workSar[i][_position] == 1)
      if (low<=workSar[i][_open])
         {
            workSar[i][_position] = -1;
               pChange = -1;
               pClose  = workSar[i][_high];
                         workSar[i][_high] = high;
                         workSar[i][_low]  = low;
                         workSar[i][_af]   = step;
                         workSar[i][_open] = pClose + workSar[i][_af]*(workSar[i][_low]-pClose);
                            if (workSar[i][_open]<workSar[i  ][_ohigh]) workSar[i][_open] = workSar[i  ][_ohigh];
                            if (workSar[i][_open]<workSar[i-1][_ohigh]) workSar[i][_open] = workSar[i-1][_ohigh];
         }
      else
         {
               pClose = workSar[i][_open];
                    if (workSar[i][_high]>workSar[i-1][_high] && workSar[i][_af]<limit) workSar[i][_af] = MathMin(workSar[i][_af]+step,limit);
                        workSar[i][_open] = pClose + workSar[i][_af]*(workSar[i][_high]-pClose);
                            if (workSar[i][_open]>workSar[i  ][_olow]) workSar[i][_open] = workSar[i  ][_olow];
                            if (workSar[i][_open]>workSar[i-1][_olow]) workSar[i][_open] = workSar[i-1][_olow];
         }
   else
      if (high>=workSar[i][_open])
         {
            workSar[i][_position] = 1;
               pChange = 1;
               pClose  = workSar[i][_low];
                         workSar[i][_low]  = low;
                         workSar[i][_high] = high;
                         workSar[i][_af]   = step;
                         workSar[i][_open] = pClose + workSar[i][_af]*(workSar[i][_high]-pClose);
                            if (workSar[i][_open]>workSar[i  ][_olow]) workSar[i][_open] = workSar[i  ][_olow];
                            if (workSar[i][_open]>workSar[i-1][_olow]) workSar[i][_open] = workSar[i-1][_olow];
         }
      else
         {
               pClose = workSar[i][_open];
               if (workSar[i][_low]<workSar[i-1][_low] && workSar[i][_af]<limit) workSar[i][_af] = MathMin(workSar[i][_af]+step,limit);
                   workSar[i][_open] = pClose + workSar[i][_af]*(workSar[i][_low]-pClose);
                            if (workSar[i][_open]<workSar[i  ][_ohigh]) workSar[i][_open] = workSar[i  ][_ohigh];
                            if (workSar[i][_open]<workSar[i-1][_ohigh]) workSar[i][_open] = workSar[i-1][_ohigh];
         }

   //
   //
   //
   //
   //
   
   pOpen     = workSar[i][_open];
   pPosition = workSar[i][_position];
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
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Parabolic Sar trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," parabolic sar " +" "+message));
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"parabolic sar"),message);
          if (alertsSound)   PlaySound(soundFile);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageArrow(int i)
{
   if (ShowArrows)
   {
      deleteArrow(Time[i]);
      if (trend[i] != trend[i+1])
      {
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
      }
   }
}               

//
//
//
//
//

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
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
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
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

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
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

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

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