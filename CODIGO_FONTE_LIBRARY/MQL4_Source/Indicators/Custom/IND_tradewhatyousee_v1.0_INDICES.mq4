
//+------------------------------------------------------------------+ 
//|  _TradeWhatYouSee                                                | 
//|                                                                  | 
//|   Modified by Avery T. Horton, Jr. aka TheRumpledOne             |
//|                                                                  |
//|   PO BOX 43575, TUCSON, AZ 85733                                 |
//|                                                                  |
//|   GIFT AND DONATIONS ACCEPTED                                    | 
//|                                                                  |
//|   therumpledone@gmail.com                                        |  
//+------------------------------------------------------------------+ 

//+------------------------------------------------------------------+
//|  Trade What You See                       Trade What You See.mq4 |
//|                                                          fxfariz |
//|                                                fxfariz@gmail.com |
//+------------------------------------------------------------------+
#property copyright "fxfariz"
#property link      "fxfariz@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue  //Red  //Aqua
#property indicator_color2 Red

extern int       SSP=5;
extern double    Kmax=50.6; //24 21.6 21.6 
extern int       CountBars=1000;
extern int       myPeriod = 0 ;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtHBuffer1[];
double ExtHBuffer2[];

int xPeriod ;

//+------------------------------------------------------------------+

string TimeFrameToString(int tf)
{
   string tfs;
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN1";
   }
   return(tfs);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_HISTOGRAM,0,3);  //Red
   SetIndexBuffer(0,ExtHBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,3);  //Lime
   SetIndexBuffer(1,ExtHBuffer2);
   
   SetIndexBuffer(2,ExtMapBuffer1);
   SetIndexBuffer(3,ExtMapBuffer2);

   
   if(myPeriod==0){xPeriod=Period();} {xPeriod=myPeriod;}
   string tPeriod = TimeFrameToString(xPeriod) ;

   IndicatorShortName(tPeriod + " Trade What You see ("+SSP+")");   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
 
  if (CountBars>=Bars) CountBars=Bars;
  
   SetIndexDrawBegin(0,Bars-CountBars+SSP);
   SetIndexDrawBegin(1,Bars-CountBars+SSP);
   
  int i, counted_bars=IndicatorCounted();
  double SsMax, SsMin, smin, smax; 
  
  if(Bars<=SSP+1) return(0);

if(counted_bars<SSP+1)
   {
      for(i=1;i<=SSP;i++) ExtMapBuffer1[CountBars-i]=0.0;
      for(i=1;i<=SSP;i++) ExtMapBuffer2[CountBars-i]=0.0;
   }

for(i=CountBars-SSP;i>=0;i--) { 


  SsMax = High[Highest(NULL,xPeriod,MODE_HIGH,SSP,i-SSP+1)]; 
  SsMin = Low[Lowest(NULL,xPeriod,MODE_LOW,SSP,i-SSP+1)]; 
  
   smax = SsMax-(SsMax-SsMin)*Kmax/100;
       
   ExtMapBuffer1[i-SSP+6]=smax; 
   ExtMapBuffer2[i-SSP-1]=smax; 

}
   for(int b=CountBars-SSP;b>=0;b--)
   {
      if(ExtMapBuffer1[b]>ExtMapBuffer2[b])
      {
         ExtHBuffer1[b]=1;
         ExtHBuffer2[b]=0;
      }
      else
      {
         ExtHBuffer1[b]=0;
         ExtHBuffer2[b]=1;
      }
      
   }

return(0);
}