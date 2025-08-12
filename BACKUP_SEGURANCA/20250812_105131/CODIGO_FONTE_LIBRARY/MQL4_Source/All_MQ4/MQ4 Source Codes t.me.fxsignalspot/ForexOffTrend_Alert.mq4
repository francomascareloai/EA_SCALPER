//+------------------------------------------------------------------+
//| Filename changed to ForexOFFTrend.mq4 by CrazyChart              |
//|                                                 SilverTrend .mq4 |
//|                             SilverTrend  rewritten by CrazyChart |
//|                                                 http://viac.ru/  |
//+------------------------------------------------------------------+

#property copyright "SilverTrend  rewritten by CrazyChart"
#property link      "http://viac.ru/ "

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue  
#property indicator_color2 Red

//---- input parameters
extern int        CountBars=400;
extern int        SSP=5;
extern double     Kmin=1.6;
extern double     Kmax=50.6; 
extern bool       gAlert=False;            // Switch to allow alerts

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

bool     gSellAlertGiven=false;           // Used to stop constant alerts
bool     gBuyAlertGiven=false;            // Used to stop constant alerts

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
   //---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE,0,4,Blue);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE,0,4,Red);
   SetIndexBuffer(1,ExtMapBuffer2);
   
   return(0); 
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+

int deinit()
{

   return(0);
   
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
 
   int      i,
            i2,
            loopbegin,
            counted_bars=IndicatorCounted();
            
   double   SsMax,
            SsMin,
            K,
            val1,
            val2,
            smin,
            smax,
            price; 
  
   if (CountBars>=Bars){
      CountBars=Bars;
   }
   
   SetIndexDrawBegin(0,Bars-CountBars+SSP);
   SetIndexDrawBegin(1,Bars-CountBars+SSP);
   
   if(Bars<=SSP+1){
      return(0);
   }
   
   if(Bars<=SSP+1){
      return(0);
   }
  
   //---- initial zero
   
   if(counted_bars<SSP+1){
      for(i=1;i<=SSP;i++) ExtMapBuffer1[CountBars-i]=0.0;
      for(i=1;i<=SSP;i++) ExtMapBuffer2[CountBars-i]=0.0;
   }
   
   //+++++++-SSP

   for(i=CountBars-SSP;i>=0;i--) { 

      SsMax = High[Highest(NULL,0,MODE_HIGH,SSP,i-SSP+1)]; 
      SsMin = Low[Lowest(NULL,0,MODE_LOW,SSP,i-SSP+1)]; 
      smin = SsMin-(SsMax-SsMin)*Kmin/100; 
      smax = SsMax-(SsMax-SsMin)*Kmax/100;  
      ExtMapBuffer1[i-SSP+6]=smax; 
      ExtMapBuffer2[i-SSP-1]=smax; 
      val1 = ExtMapBuffer1[0]; 
      val2 = ExtMapBuffer2[0]; 
      
      if (val1 > val2){
         Comment("покупка buy ",val1);
         if( gAlert==true && gBuyAlertGiven==false){
            PlaySound("alert.wav");
            Alert("Buy signal at " + DoubleToStr(val1, 4) + " on " + Period() + " minute chart");
            gBuyAlertGiven=true;
            gSellAlertGiven=false;
         }     
      }

      if (val1 < val2){
         Comment("продажа sell ",val2);
         if(gAlert==true && gSellAlertGiven==false){
            PlaySound("alert.wav");
            Alert("Sell signal at " + DoubleToStr(val2, 4) + " on " + Period()+ " minute chart");
            gBuyAlertGiven=false;
            gSellAlertGiven=true;
         }     
      }
   }

   return(0);
}


/////////////////////////////////////////////////////////////////////////////
// History
/////////////////////////////////////////////////////////////////////////////
/*

22 September 2005 by Varus

variables added:

gAlert                  External switch to allow alerts.
gBuyAlertGiven          Global to stop the alerts being displayed more than once.
gSellAlertGiven         Global to stop the alerts being displayed more than once.

An alert was added to alert the trader when the indicator changes from a long signal
to a short or the other way round.

The value of CountBars was changed to 400 from 300 to give a longer display of previous
performance on the price chart.

Version number v1.01 added to filename.

*/


