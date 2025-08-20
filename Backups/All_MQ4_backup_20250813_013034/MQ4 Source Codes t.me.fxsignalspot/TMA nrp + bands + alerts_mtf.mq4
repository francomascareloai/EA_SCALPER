#property copyright "mladen"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  DeepSkyBlue
#property indicator_color2  PaleVioletRed
#property indicator_color3  PaleVioletRed
#property indicator_color4  Lime
#property indicator_color5  Red
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_style4  STYLE_DOT
#property indicator_style5  STYLE_DOT

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame        = PERIOD_CURRENT;
extern int                TmaPeriod        = 20;
extern ENUM_APPLIED_PRICE TmaPrice         = PRICE_CLOSE;
extern double             ATRMultiplier    = 2.0;
extern int                ATRPeriod        = 12;
extern int                Shift            = 0;
extern bool               alertsOn         = false;
extern bool               alertsOnCurrent  = true;
extern bool               alertsMessage    = true;
extern bool               alertsSound      = false;
extern bool               alertsNotify     = false;
extern bool               alertsEmail      = false;
extern string             soundFile        = "alert2.wav";

extern bool               MultiColor       = true;

//
//
//
//
//

double tma[];
double tmaDa[];
double tmaDb[];
double bandUp[];
double bandDn[];
double slope[];
double trend[];

string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(7);
      SetIndexBuffer(0,tma);
      SetIndexBuffer(1,tmaDa);
      SetIndexBuffer(2,tmaDb);
      SetIndexBuffer(3,bandUp);   
      SetIndexBuffer(4,bandDn);   
      SetIndexBuffer(5,slope);
      SetIndexBuffer(6,trend);
      //
      //
      //
      //
      //
         
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         TimeFrame         = MathMax(TimeFrame,_Period);
         SetIndexShift(0,Shift * TimeFrame/Period());  
         SetIndexShift(1,Shift * TimeFrame/Period());  
         SetIndexShift(2,Shift * TimeFrame/Period());  
         SetIndexShift(3,Shift * TimeFrame/Period());  
         SetIndexShift(4,Shift * TimeFrame/Period()); 
   
      //
      //
      //
      //
      //
      
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
         if (returnBars) { tma[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
     if (MultiColor && slope[limit]==-1) CleanPoint(limit,tmaDa,tmaDb);
     for(i=limit; i>=0; i--)
     {
        tma[i]       = iTma(iMA(NULL,0,1,0,MODE_SMA,TmaPrice,i),TmaPeriod,i,0);
        double range = iATR(NULL,0,ATRPeriod,i+10)*ATRMultiplier;
        bandUp[i]    = tma[i]+range;
        bandDn[i]    = tma[i]-range;
        
        //
        //
        //
        //
        //
        
        tmaDa[i] = EMPTY_VALUE;
        tmaDb[i] = EMPTY_VALUE;
        slope[i] = slope[i+1];
        trend[i] = trend[i+1];

           if (tma[i]<tma[i+1])    slope[i] = -1;
           if (tma[i]>tma[i+1])    slope[i] =  1;
           if (Close[i]>bandUp[i]) trend[i] = -1;
           if (Close[i]<bandDn[i]) trend[i] =  1;
           if (MultiColor && slope[i] == -1) PlotPoint(i,tmaDa,tmaDb,tma);
     }
     
   //
   //
   //
   //
   //
 
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1)   doAlert(whichBar,"price crossing lower band");
         if (trend[whichBar] ==-1)   doAlert(whichBar,"price crossing upper band");
      }         
   }
     return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (MultiColor && slope[limit]==-1) CleanPoint(limit,tmaDa,tmaDb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         tma[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,TmaPeriod,TmaPrice,ATRMultiplier,ATRPeriod,Shift,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,0,y);
         bandUp[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,TmaPeriod,TmaPrice,ATRMultiplier,ATRPeriod,Shift,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,3,y);
         bandDn[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,TmaPeriod,TmaPrice,ATRMultiplier,ATRPeriod,Shift,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,4,y);
         slope[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,TmaPeriod,TmaPrice,ATRMultiplier,ATRPeriod,Shift,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,5,y);
         tmaDa[i]  = EMPTY_VALUE;
         tmaDb[i]  = EMPTY_VALUE;     
   }
   for (i=limit;i>=0;i--) if (MultiColor && slope[i] == -1) PlotPoint(i,tmaDa,tmaDb,tma);   
return(0);        
}

//
//
//
//
//

double workTma[][1];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTma,0)!= Bars) ArrayResize(workTma,Bars); r=Bars-r-1;
   
   //
   //
   //
   //
   //
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
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

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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

           message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," TMA nrp + bands ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " TMA nrp + bands "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}