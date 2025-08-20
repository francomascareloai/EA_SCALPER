//+------------------------------------------------------------------+
//|                                                         T3MA.mq4 |
//|                                     Copyright © 2005, Nick Bilak |
//|                                        http://www.forex-tsd.com/ |
//|                                modified for VolumeFactor by: ben |
//|                                                  thanks to Bilak |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Nick Bilak"
#property link      "http://www.forex-tsd.com/"

#define vers    "08.Feb.2008"
#define major   1
#define minor   1

// --- Release Notes ----
// 08-Feb-08 - original work T3MA by Nick Bilak, Modified to a MTF version by Tim Hyder

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 1
#property  indicator_color1  Yellow
#property  indicator_width1  2

//---- indicator parameters
extern string NOTE1 = " --- T3MA MTF Settings ---";
extern string NOTE2 = "Enter 0 to display current TF";
extern int TimeFrame = 0;
extern string NOTE3 = "Increase by 1 for each indicator loaded";
extern int Unique = 1;
extern int MaxBars = 500;

extern string NOTE4 = "Moving Average";
extern int Periods         = 3; //12 
extern double VolumeFactor = 0.7; //0.8
extern string note5 = "change color in the Colors area too";
extern color MAcolor1 = Yellow;
extern string note6 = "Display the info in what corner?";
extern string note7 = "Upper left=0; Upper right=1";
extern string note8 = "Lower left=2; Lower right=3";
extern int    WhatCorner=0;
extern string note9 = "Y distance - Positions description label";
extern int    ydistance1=10;

//---- indicator buffers
double e1[];
double e2[];
double e3[];
double e4[];
double e5[];
double e6[];
double e7[];
double e8[];
string objectma1;
int TFrame;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IntToStr(int X)
  {
    return (DoubleToStr(X, 0));
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(8);
   //---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexEmptyValue(0,0.0);
   SetIndexDrawBegin(0,Periods);

   if(
   	!SetIndexBuffer(0,e8) &&
   	!SetIndexBuffer(1,e7) &&
      !SetIndexBuffer(2,e2) &&
      !SetIndexBuffer(3,e3) &&
      !SetIndexBuffer(4,e4) &&
      !SetIndexBuffer(5,e5) &&
      !SetIndexBuffer(6,e6) &&
   	!SetIndexBuffer(7,e1)
      )
      Print("cannot set indicator buffers!");
      
   //Verify Time Values entered are good
   TFrame = CheckTimeFrame(TimeFrame);
  
   //---- initialization done
   if ((WhatCorner == 2) || (WhatCorner == 3)) ydistance1 = 15+ydistance1;
   
   ydistance1 = ydistance1 + (Unique*15);
   objectma1 = "MTFT3"+IntToStr(Periods)+Unique; 
    
   ObjectCreate(objectma1, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(objectma1, "MTF T3 ("+Periods+"), TF: " + TF2Str(TFrame), 8, "Arial", MAcolor1);
   ObjectSet(objectma1, OBJPROP_CORNER, WhatCorner); 
   ObjectSet(objectma1, OBJPROP_XDISTANCE, 4);
   ObjectSet(objectma1, OBJPROP_YDISTANCE, ydistance1);
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MTFT3("+Periods+") " + Unique);
   return(0);  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
  ObjectDelete(objectma1);  
  return(0);
  }
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
//+------------------------------------------------------------------+
int start()
  {
   int i,limit,y=0;
   datetime TimeArray[];
   
   int counted_bars=IndicatorCounted();
   //---- check for possible errors
   if (counted_bars < 0) return(-1);
   //---- the last counted bar will be recounted
   if (counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
   limit = MathMin(limit, MaxBars);   
  //-------------------------------1----------------------------------------   
  
   // Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   for(i=0,y=0;i<limit;i++)
   {
      if (Time[i]<TimeArray[y]) y++;

      /***********************************************************   
         Add your main indicator loop below.  You can reference an existing
         indicator with its iName  or iCustom.
         Rule 1:  Add extern inputs above for all neccesary values   
         Rule 2:  Use 'TFrame' for the indicator time frame
         Rule 3:  Use 'y' for your indicator's shift value
       **********************************************************/  
       e8[i] = MTFT3(TimeFrame,y,limit);
   }

   //---- done
   return(0);
  }
  
double MTFT3(int TF, int Bar, int BarCount)
{
   int i;
   //---- main loop
   for(i=BarCount; i>=Bar; i--) 
   {
   	e1[i]=iMA(NULL,TF,Periods,0,MODE_EMA,PRICE_CLOSE,i);
   }
   for(i=BarCount; i>=Bar; i--) 
   {
   	e2[i]=iMAOnArray(e1,0,Periods,0,MODE_EMA,i);
   }
   for(i=BarCount; i>=Bar; i--) 
   {
   	e3[i]=iMAOnArray(e2,0,Periods,0,MODE_EMA,i);
   }
   for(i=BarCount; i>=Bar; i--) 
   {
   	e4[i]=iMAOnArray(e3,0,Periods,0,MODE_EMA,i);
   }
   for(i=BarCount; i>=Bar; i--) 
   {
   	e5[i]=iMAOnArray(e4,0,Periods,0,MODE_EMA,i);
   }
   
	double a= VolumeFactor; //0.8;
	double c1=-a*a*a;
	double c2=3*a*a+3*a*a*a;
	double c3=-6*a*a-3*a-3*a*a*a;
	double c4=1+3*a+a*a*a+3*a*a;
	//T3MA=c1*e6+c2*e5+c3*e4+c4*e3;
   for(i=BarCount; i>=Bar; i--) 
   {
   	e6[i]=iMAOnArray(e5,0,Periods,0,MODE_EMA,i);
   	e7[i]=c1*e6[i]+c2*e5[i]+c3*e4[i]+c4*e3[i];
   }
   return(e7[Bar]);
}
 
  
string TF2Str(int period) 
{
  switch (period) 
  {
    case PERIOD_M1: return("M1");
    case PERIOD_M5: return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1: return("H1");
    case PERIOD_H4: return("H4");
    case PERIOD_D1: return("D1");
    case PERIOD_W1: return("W1");
    case PERIOD_MN1: return("MN");
  }
  return (Period());
} 

int CheckTimeFrame(int TimeFrame)
{
   int result;

   //If first time frame = 0 then default to currently displayed time frame
   if (TimeFrame == 0 || TimeFrame < Period())
      result = Period();   
   else
   {
      switch(TimeFrame) 
      {
         case 1    : result = PERIOD_M1;  break; 
         case 5    : result = PERIOD_M5;  break;
         case 15   : result = PERIOD_M15; break;
         case 30   : result = PERIOD_M30; break;
         case 60   : result = PERIOD_H1;  break;
         case 240  : result = PERIOD_H4;  break;
         case 1440 : result = PERIOD_D1;  break;
         case 7200 : result = PERIOD_W1;  break;
         case 28800: result = PERIOD_MN1; break;
         default  : result = Period(); break; //Error so return current period
      }
   }
   return(result);
}

