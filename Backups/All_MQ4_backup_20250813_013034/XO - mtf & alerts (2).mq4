//+------------------------------------------------------------------+
//|                                                               XO |
//|                                                           mladen | 
//+------------------------------------------------------------------+
#property link      "www.forex-tsd.com"
#property copyright "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  DeepSkyBlue
#property indicator_color2  PaleVioletRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_level1  0

//
//
//
//
//

extern string TimeFrame        = "Current time frame";
extern double BoxSize          = 6.5;
extern bool   ShowArrows       = true;
extern string arrowsIdentifier = "XOarrows";
extern color  arrowsUpColor    = DeepSkyBlue;
extern color  arrowsDnColor    = PaleVioletRed;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;

//
//
//
//
//

double Hi[];
double Lo[];
double no[];
double kr[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   IndicatorBuffers(5);   
      SetIndexBuffer(0,kr); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,no); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,Hi);
      SetIndexBuffer(3,Lo);
      SetIndexBuffer(4,trend);

      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="CalculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);

      //
      //
      //
      //
      //
      
   IndicatorShortName(timeFrameToString(timeFrame)+" XO ("+DoubleToStr(BoxSize,2)+")");
   return(0);
}
int deinit()
{
   if (!calculateValue && ShowArrows) deleteArrows();
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { kr[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //
    
   if (calculateValue || timeFrame == Period())
   {
      double pipModifier = 1; if (Digits==3 || Digits==5) pipModifier=10;
      for(i=limit; i>=0; i--)
      {         
         if (i>=(Bars-2)) { Hi[i+1]=Close[i]; Lo[i+1]=Close[i]; continue; }

         //
         //
         //
         //
         //
      
         double cur = Close[i];
         Hi[i]    = Hi[i+1];
         Lo[i]    = Lo[i+1];
         no[i]    = no[i+1];
         kr[i]    = kr[i+1];
         trend[i] = trend[i+1];

            if (cur > (Hi[i]+BoxSize*pipModifier*Point)) { Hi[i] = cur; Lo[i] = cur-BoxSize*pipModifier*Point; kr[i] += 1; no[i] = 0; }
            if (cur < (Lo[i]-BoxSize*pipModifier*Point)) { Lo[i] = cur; Hi[i] = cur+BoxSize*pipModifier*Point; no[i] -= 1; kr[i] = 0; }
               if (kr[i] > 0) trend[i]= 1;
               if (no[i] < 0) trend[i]=-1;
            manageArrow(i);
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         kr[i]    = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",BoxSize,0,y);
         no[i]    = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",BoxSize,1,y);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",BoxSize,4,y);
         manageArrow(i);
   }
   manageAlerts();
   return(0);         
}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
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

       message =  StringConcatenate(timeFrameToString(timeFrame)+" "+Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," XO trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"XO "),message);
          if (alertsSound)   PlaySound("alert2.wav");
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
   if (!calculateValue && ShowArrows)
   {
      deleteArrow(Time[i]);
      if (trend[i]!=trend[i+1])
      {
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,139,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,139,true);
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
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
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
      int chr = StringGetChar(s, length);
         if((chr > 96 && chr < 123) || (chr > 223 && chr < 256))
                     s = StringSetChar(s, length, chr - 32);
         else if(chr > -33 && chr < 0)
                     s = StringSetChar(s, length, chr + 224);
   }
   return(s);
}