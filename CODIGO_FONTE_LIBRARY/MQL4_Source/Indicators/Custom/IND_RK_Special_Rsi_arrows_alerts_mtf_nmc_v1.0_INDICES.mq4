//+------------------------------------------------------------------+
//|                                            Special_RSI_ARROW.mq4 |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  Green
#property indicator_color2  Blue
#property indicator_color3  LimeGreen
#property indicator_color4  Red
#property indicator_width1  2
#property indicator_width2  2
#property indicator_level1  2
#property indicator_level2 -2
#property indicator_level3  4  
#property indicator_level4 -4
#property indicator_level5  0
#property indicator_levelcolor Peru  



//
//
//
//
//

extern string TimeFrame  = "Current time frame";
extern int    RSIPeriod1 =  14;
extern int    RSIPeriod2 =  28;
extern int    Cross1     =  10;
extern double difference = 2.0;
extern bool   UseDifferenceCrosses = false;

extern string note             = "turn on Alert = true; turn off = false";
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = true;
extern bool   alertsEmail      = false;
extern bool   Interpolate      = true;

//
//
//
//
//

double   ind_buffer1[];
double   Cross[];
double   UpArrow[];
double   DnArrow[];
double   trend[];

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
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0, ind_buffer1);
      SetIndexBuffer(1, Cross);
      SetIndexBuffer(2, UpArrow);  SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2, 233);
      SetIndexBuffer(3, DnArrow);  SetIndexStyle(3, DRAW_ARROW); SetIndexArrow(3, 234);
      SetIndexBuffer(4, trend);

      //
      //
      //
      //
      //

         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);

      //
      //
      //
      //
      //
      
   IndicatorShortName(timeFrameToString(timeFrame)+" RK-Special RSI ARROW");
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
   int i,limit;
   int counted_bars=IndicatorCounted();
   if (counted_bars>0) counted_bars--;
            limit=MathMin(Bars-counted_bars,Bars-1);
            if (returnBars) { ind_buffer1[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
 
   if (calculateValue || timeFrame == Period())
   {
      double alpha1 = 2.0 / (1.0+14.0);   // replace 14 with any other smoothing period for EMA smoothing
      double alpha2 = 2.0 / (1.0+Cross1);

      //
      //
      //
      //
      //
         
      for(i=limit; i>=0; i--) 
      {
         double rsiDiff = (iRSI(NULL, 0, RSIPeriod1, PRICE_CLOSE, i)-iRSI(NULL, 0, RSIPeriod2,PRICE_CLOSE,i));
         ind_buffer1[i] = ind_buffer1[i+1]+alpha1*(rsiDiff-ind_buffer1[i+1]);   
         Cross[i]       = Cross[i+1]      +alpha2*(ind_buffer1[i]-Cross[i+1]);
         trend[i]       = trend[i+1];
         UpArrow[i]     = EMPTY_VALUE;
         DnArrow[i]     = EMPTY_VALUE;
         
         //
         //
         //
         //
         //
            
         if (UseDifferenceCrosses)
         {
            if(Cross[i]>(Cross[i+1]+(difference/1000))) if(trend[i]< 1) trend[i] =  1;
            if(Cross[i]<(Cross[i+1]-(difference/1000))) if(trend[i]>-1) trend[i] = -1;
         }
         else               
         {
            if (Cross[i]<ind_buffer1[i]) trend[i] =  1;
            if (Cross[i]>ind_buffer1[i]) trend[i] = -1;
         }               
         if (trend[i]!=trend[i+1])
         if (trend[i] == 1)
               UpArrow[i] = Cross[i];
         else  DnArrow[i] = Cross[i];
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
         ind_buffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RSIPeriod1,RSIPeriod2,Cross1,difference,UseDifferenceCrosses,0,y);
         Cross[i]       = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RSIPeriod1,RSIPeriod2,Cross1,difference,UseDifferenceCrosses,1,y);
         trend[i]       = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RSIPeriod1,RSIPeriod2,Cross1,difference,UseDifferenceCrosses,4,y);
         UpArrow[i]     = EMPTY_VALUE;
         DnArrow[i]     = EMPTY_VALUE;

            if (trend[i]!=trend[i+1])
            if (trend[i] == 1)
                  UpArrow[i] = Cross[i];
            else  DnArrow[i] = Cross[i];

         //
         //
         //
         //
         //
      
            if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
            if (!Interpolate) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
            {
               ind_buffer1[i+k] = ind_buffer1[i] + (ind_buffer1[i+n]-ind_buffer1[i])*k/n;
               Cross[i+k]       = Cross[i]       + (Cross[i+n]      -Cross[i]      )*k/n;
            }
   }
   manageAlerts();

   //
   //
   //
   //
   //
   
   return(0);
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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

         //
         //
         //
         //
         //
         
         if (trend[whichBar] != trend[whichBar+1])
         if (trend[whichBar] == 1)
               doAlert(whichBar, "uptrend");
         else  doAlert(whichBar, "downtrend");       
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

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," Ask = ",DoubleToStr(Ask,4)," Bid = ",DoubleToStr(Bid,4),
                                 " at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Special RSI Arrow ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Special RSI Arrow "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
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
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}