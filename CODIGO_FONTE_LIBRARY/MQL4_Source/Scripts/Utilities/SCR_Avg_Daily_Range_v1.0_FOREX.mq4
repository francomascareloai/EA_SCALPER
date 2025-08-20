//+------------------------------------------------------------------+
//|                                                   TSR_Ranges.mq4 |
//|                                         Copyright © 2006, Ogeima |
//|                                             ph_bresson@yahoo.com |
//| made for FXiGoR for the TSR Trend Slope Retracement method       |
//| modified to the DYNAMIC Daily Range Breakout System             |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Ogeima"
#property link      "ph_bresson@yahoo.com"

#property indicator_chart_window
//---- input parameters
extern double  Risk_to_Reward_ratio =  3.0;
int nDigits;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(Symbol()=="GBPJPY" || Symbol()=="EURJPY" || Symbol()=="USDJPY" || Symbol()=="GOLD")  nDigits = 2;
   else nDigits = 4;

   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   //----
   string PIPS="";
   int R1=0,MR25=0,WR25=0,R25=0,R40=0,RAvg=0;
   int Prevday=0,Prevwk=0,Prevmthy=0;
   int Curday=0,Curwk=0,Curmthy=0;
   int RoomUp=0,RoomDown=0,StopLoss_Long=0,StopLoss_Short=0,today_range=0;
   double   SL_Long=0,SL_Short=0;
   double   low0=0,high0=0;
   string   Text="";
   int i=0;
   double OPEN = iOpen(NULL,1440,0);
   double CLOSE = iClose(NULL,1440,0);
   PIPS =  DoubleToStr((CLOSE-OPEN)/Point,0);
      
   R1 =  (iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1))/Point;
   
   for(i=1;i<=25;i++)
      R25   =    R25 +  (iHigh(NULL,PERIOD_D1,i)-iLow(NULL,PERIOD_D1,i))/Point;
   for(i=1;i<=25;i++)
      WR25   =    WR25 +  (iHigh(NULL,PERIOD_W1,i)-iLow(NULL,PERIOD_W1,i))/Point;
   for(i=1;i<=25;i++)
      MR25   =    MR25 +  (iHigh(NULL,PERIOD_MN1,i)-iLow(NULL,PERIOD_MN1,i))/Point;

Prevday =  (iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1))/Point;
Prevwk =  (iHigh(NULL,PERIOD_W1,1)-iLow(NULL,PERIOD_W1,1))/Point;
Prevmthy =  (iHigh(NULL,PERIOD_MN1,1)-iLow(NULL,PERIOD_MN1,1))/Point;

Curday =  (iHigh(NULL,PERIOD_D1,0)-iLow(NULL,PERIOD_D1,0))/Point;
Curwk =  (iHigh(NULL,PERIOD_W1,0)-iLow(NULL,PERIOD_W1,0))/Point;
Curmthy = (iHigh(NULL,PERIOD_MN1,0)-iLow(NULL,PERIOD_MN1,0))/Point;

   
   R25 = R25/25;
   WR25 = WR25/25;
   MR25 = MR25/25;
   
   low0  =  iLow(NULL,PERIOD_D1,0);
   high0 =  iHigh(NULL,PERIOD_D1,0);
   RoomUp   =  RAvg - (Bid - low0)/Point;
   RoomDown =  RAvg - (high0 - Bid)/Point;
   StopLoss_Long  =  RoomUp/Risk_to_Reward_ratio;
   SL_Long        =  Bid - StopLoss_Long*Point;
   StopLoss_Short =  RoomDown/Risk_to_Reward_ratio;
   SL_Short       =  Bid + StopLoss_Short*Point;

   today_range = (iHigh(NULL,PERIOD_D1,0)) - (iLow(NULL,PERIOD_D1,0));

   Text =   "Avg 25  Days Range: " +  R25  + "\n" +
            "Avg 25  Weeks Range: " +  WR25  + "\n" +
            "Avg 25  Months Range: " +  MR25  + "\n\n" +
            "Prev  Days Range: " +  Prevday  + "\n" +
            "Prev  Week Range: " +  Prevwk  + "\n" +
            "Prev  Month Range: " +  Prevmthy  + "\n\n" +
            "Current  Day Range: " +  Curday  + "\n" +
            "Current  Week Range: " +  Curwk  + "\n" +
            "Current  Month Range: " +  Curmthy  + "\n";
            //"Today Range: " +  today_range  + "\n";
  
   Comment(Text);

   return(0);
  }
//+------------------------------------------------------------------+