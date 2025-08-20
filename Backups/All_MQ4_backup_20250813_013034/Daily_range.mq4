//+------------------------------------------------------------------+
//|                                                  Daily range.mq4 |
//|                                                         mishanya |
//|                                           www.fxtradercenter.com |
//+------------------------------------------------------------------+
#property copyright "mishanya"
#property link      "www.fxtradercenter.com"
#property indicator_chart_window
//----
extern int StepBack=0;
//----
double X,rates_d1[][6],sup,res;
int timeshift=0, timeshifts=0, beginner=0,d;
int periods;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   ObjectDelete("DSup line");
   ObjectDelete("DRes line");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//---- TODO: add your code here
   d=1+StepBack;
   switch(Period())
     {
      case PERIOD_M1:  {timeshifts=60; beginner=Hour()*60;} break;
      case PERIOD_M5:  {timeshifts=300; beginner=Hour()*12;} break;
      case PERIOD_M15: {timeshifts=900; beginner=Hour()*4;} break;
      case PERIOD_M30: {timeshifts=1800; beginner=Hour()*2;} break;
      case PERIOD_H1:  {timeshifts=3600; beginner=Hour()*1;} break;
      case PERIOD_H4:  {timeshifts=14400; beginner=Hour()*0.25;} break;
      case PERIOD_D1:  {timeshifts=86400; beginner=Hour()*0;} break;
     }
   timeshift=timeshifts*24;
//----
   if(Period() > 86400)
     {
      Print("Error - Chart period is greater than 1 day.");
      return(-1); // then exit
     }
   ArrayCopyRates(rates_d1, Symbol(), PERIOD_D1);
//----   
   if (rates_d1[d][4]<rates_d1[d][1]) X=(rates_d1[d][3]+rates_d1[d][2]+rates_d1[d][4]+rates_d1[d][2])/2;
   if (rates_d1[d][4]>rates_d1[d][1]) X=(rates_d1[d][3]+rates_d1[d][2]+rates_d1[d][4]+rates_d1[d][3])/2;
   if (rates_d1[d][4]==rates_d1[d][1]) X=(rates_d1[d][3]+rates_d1[d][2]+rates_d1[d][4]+rates_d1[d][4])/2;
//----
   sup=X - rates_d1[d][3];
   res=X - rates_d1[d][2];
   if (ObjectFind("DRes Line")!=0)
     {
      ObjectCreate("DRes line",OBJ_HLINE,0,Time[0],res);
      ObjectSet("DRes line",OBJPROP_COLOR,Red);
      ObjectSet("DRes line",OBJPROP_WIDTH,2);
     }
   else
     {
      ObjectMove("DRes line", 0,Time[0],res);
     }
   if (ObjectFind("DSup Line")!=0)
     {
      ObjectCreate("DSup line",OBJ_HLINE,0,Time[0],sup);
      ObjectSet("DSup line",OBJPROP_COLOR,Red);
      ObjectSet("DSup line",OBJPROP_WIDTH,2);
     }
   else
     {
      ObjectMove("DSup line", 0,Time[0],sup);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+