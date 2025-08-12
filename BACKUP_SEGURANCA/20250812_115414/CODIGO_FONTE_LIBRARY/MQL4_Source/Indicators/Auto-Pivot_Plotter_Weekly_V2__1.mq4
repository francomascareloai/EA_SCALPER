//+------------------------------------------------------------------+
//|                              Auto-Pivot Plotter Weekly V1-00.mq4 |
//|                                  Copyright © 2007, BundyRaider   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, BundyRaider"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 RoyalBlue
#property indicator_color2 RoyalBlue
#property indicator_color3 RoyalBlue
#property indicator_color4 Green
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 LimeGreen

#property indicator_width4 3

//---- input parameters
extern bool ChangeToFibonacci = True;
extern bool ShowPopup = true;
extern bool SendEMail = true;
extern bool SendNotify = true;

//---- buffers
double Res3[];
double Res2[];
double Res1[];
double Pivot[];
double Supp1[];
double Supp2[];
double Supp3[];
double Extra1[];
datetime lastAlertP, lastAlertR1, lastAlertR2, lastAlertR3, lastAlertS1, lastAlertS2, lastAlertS3;
string lbl = "WeeklyPivot.";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID); SetIndexBuffer(0,Res3); SetIndexLabel(0,"R3");
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID); SetIndexBuffer(1,Res2); SetIndexLabel(1,"R2");
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID); SetIndexBuffer(2,Res1); SetIndexLabel(2,"R1");
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID); SetIndexBuffer(3,Pivot); SetIndexLabel(3,"Pivot");
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID); SetIndexBuffer(4,Supp1); SetIndexLabel(4,"S1");
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID); SetIndexBuffer(5,Supp2); SetIndexLabel(5,"S2");
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID); SetIndexBuffer(6,Supp3); SetIndexLabel(6,"S1");
   SetIndexStyle(7,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(7,Extra1);
   
   IndicatorDigits(Digits);
   lbl = lbl + Symbol() + ".";
   lastAlertP = GlobalVariableGet(lbl+"Pivot");
   lastAlertR1 = GlobalVariableGet(lbl+"R1"); lastAlertR2 = GlobalVariableGet(lbl+"R2"); lastAlertR3 = GlobalVariableGet(lbl+"R3");
   lastAlertS1 = GlobalVariableGet(lbl+"S1"); lastAlertS2 = GlobalVariableGet(lbl+"S2"); lastAlertS3 = GlobalVariableGet(lbl+"S3");
//----
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
   int    counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   int limit=Bars-counted_bars;
//****************************
   
   for(int i=0; i<limit; i++)
   { 

      // *****************************************************
      //    Find previous day's opening and closing bars.
      // *****************************************************
      
      //Find Our Week date.

      datetime WeekDate    =  Time[i];
      int    WeeklyBar     =  iBarShift(NULL, PERIOD_W1, WeekDate, false)+1; 
      double PreviousHigh  =  iHigh(NULL, PERIOD_W1,WeeklyBar);
      double PreviousLow   =  iLow(NULL, PERIOD_W1,WeeklyBar);
      double PreviousClose =  iClose(NULL, PERIOD_W1,WeeklyBar);

      // ************************************************************************
      //    Calculate Pivot lines and map into indicator buffers.
      // ************************************************************************
      
      if(ChangeToFibonacci==False)
        {
         double P =  (PreviousHigh+PreviousLow+PreviousClose)/3;
         double R1 = (2*P)-PreviousLow;
         double S1 = (2*P)-PreviousHigh;
         double R2 =  P+(PreviousHigh - PreviousLow);
         double S2 =  P-(PreviousHigh - PreviousLow);
         double R3 = (2*P)+(PreviousHigh-(2*PreviousLow));
         double S3 = (2*P)-((2* PreviousHigh)-PreviousLow); 
         //NormalizeDouble( P, Digits); 
        }
      else
        {
         P  =  (PreviousHigh+PreviousLow+PreviousClose)/3;
         R1 = P + ((PreviousHigh-PreviousLow) * 0.382);
         S1 = P - ((PreviousHigh-PreviousLow) * 0.382);
         R2 = P + ((PreviousHigh-PreviousLow) * 0.618);
         S2 = P - ((PreviousHigh-PreviousLow) * 0.618);
         R3 = P + ((PreviousHigh-PreviousLow) * 1.000);
         S3 = P - ((PreviousHigh-PreviousLow) * 1.000);

         //NormalizeDouble( P, Digits); 
        } 
     
      Pivot[i] = NormalizeDouble(P, Digits); 
      Res1[i]  = R1;    
      Res2[i]  = R2;  
      Res3[i]  = R3;  
      Supp1[i] = S1;   
      Supp2[i] = S2;  
      Supp3[i] = S3;

   }   
   // ***************************************************************************************
   //                            End of Main Loop
   // ***************************************************************************************
   static double LastBid = 0; string msg;
   if (LastBid == 0) LastBid = Bid;
   else
   {
     if (lastAlertP != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Pivot[0],_Digits)<0 && NormalizeDouble(Bid-Pivot[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Pivot[0],_Digits)>0 && NormalizeDouble(Bid-Pivot[0],_Digits)<=0))
       {
         lastAlertP = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"Pivot", lastAlertP);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" weekly pivot line touched on "+Symbol();
         if (ShowPopup) Alert(msg);
         if (SendEMail) SendMail(msg, msg);
         if (SendNotify) SendNotification(msg);
       }
     }  
     if (lastAlertR1 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res1[0],_Digits)<0 && NormalizeDouble(Bid-Res1[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res1[0],_Digits)>0 && NormalizeDouble(Bid-Res1[0],_Digits)<=0))
       {
         lastAlertR1 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R1", lastAlertR1);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R1 pivot line touched on "+Symbol();
         if (ShowPopup) Alert(msg);
         if (SendEMail) SendMail(msg, msg);
         if (SendNotify) SendNotification(msg);
       }
     }  
     if (lastAlertR2 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res2[0],_Digits)<0 && NormalizeDouble(Bid-Res2[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res2[0],_Digits)>0 && NormalizeDouble(Bid-Res2[0],_Digits)<=0))
       {
         lastAlertR2 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R2", lastAlertR2);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R2 pivot line touched on "+Symbol();
         if (ShowPopup) Alert(msg);
         if (SendEMail) SendMail(msg, msg);
         if (SendNotify) SendNotification(msg);
       }
     }  
     if (lastAlertR3 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res3[0],_Digits)<0 && NormalizeDouble(Bid-Res3[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res3[0],_Digits)>0 && NormalizeDouble(Bid-Res3[0],_Digits)<=0))
       {
         lastAlertR3 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R3", lastAlertR3);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R3 pivot line touched on "+Symbol();
         if (ShowPopup) Alert(msg);
         if (SendEMail) SendMail(msg, msg);
         if (SendNotify) SendNotification(msg);
       }
     }  
     if (lastAlertS1 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp1[0],_Digits)<0 && NormalizeDouble(Bid-Supp1[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp1[0],_Digits)>0 && NormalizeDouble(Bid-Supp1[0],_Digits)<=0))
       {
         lastAlertS1 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S1", lastAlertS1);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S1 pivot line touched on "+Symbol();
         if (ShowPopup) Alert(msg);
         if (SendEMail) SendMail(msg, msg);
         if (SendNotify) SendNotification(msg);
       }
     }  
     if (lastAlertS2 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp2[0],_Digits)<0 && NormalizeDouble(Bid-Supp2[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp2[0],_Digits)>0 && NormalizeDouble(Bid-Supp2[0],_Digits)<=0))
       {
         lastAlertS2 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S2", lastAlertS2);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S2 pivot line touched on "+Symbol();
         if (ShowPopup) Alert(msg);
         if (SendEMail) SendMail(msg, msg);
         if (SendNotify) SendNotification(msg);
       }
     }  
     if (lastAlertS3 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp3[0],_Digits)<0 && NormalizeDouble(Bid-Supp3[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp3[0],_Digits)>0 && NormalizeDouble(Bid-Supp3[0],_Digits)<=0))
       {
         lastAlertS3 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S3", lastAlertS3);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S3 pivot line touched on "+Symbol();
         if (ShowPopup) Alert(msg);
         if (SendEMail) SendMail(msg, msg);
         if (SendNotify) SendNotification(msg);
       }
     }  
   }

   // *****************************************
   //    Return from Start() (Main Routine)
   return(0);
  }
//+-------------------------------------------------------------------------------------------------------+
//  END Custom indicator iteration function
//+-------------------------------------------------------------------------------------------------------+


// *****************************************************************************************
// *****************************************************************************************
// -----------------------------------------------------------------------------------------
//    The following routine will use "StartingBar"'s time and use it to find the 
//    general area that SHOULD contain the bar that matches "TimeToLookFor"
// -----------------------------------------------------------------------------------------


