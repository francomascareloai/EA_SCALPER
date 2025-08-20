//+------------------------------------------------------------------+
//|                                                      STIX_v1.mq4 |
//+------------------------------------------------------------------+
#property copyright "FREE EA, Indicators > ForexCracked.com"
#property link      "http://forexcracked.com"

#property indicator_separate_window
#property indicator_buffers   2
#property indicator_color1    LightBlue
#property indicator_width1    2 
#property indicator_color2    Orange
#property indicator_width2    1
#property indicator_style2    2
#property indicator_level1    50
#property indicator_maximum   100
#property indicator_minimum   0
//---- input parameters
extern int       Length = 10; // Period of evaluation
extern int       Smooth =  5; // Period of smoothing
extern int       ModeMA =  1; // Mode of Moving Average
//---- buffers
double STIX[];
double AvgSTIX[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,STIX);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,AvgSTIX);
//---- name for DataWindow and indicator subwindow label
   string short_name="STIX("+Length+","+Smooth+","+ModeMA+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"STIX");
   SetIndexLabel(1,"AvgSTIX");
//----
   SetIndexDrawBegin(0,Length+Smooth);
   SetIndexDrawBegin(1,Length+Smooth);

   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int      shift, limit, counted_bars=IndicatorCounted();
   double   Price1, Price2;
//---- 
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars ==0 ) limit=Bars-1;
   if ( counted_bars < 1 ) 
   for(int i=1;i<Length+Smooth;i++) 
   {
   STIX[Bars-i]=0;    
   AvgSTIX[Bars-i]=0;  
   }
   
   if(counted_bars>0) limit=Bars-counted_bars;
   limit--;
   
   for( shift=limit; shift>=0; shift--)
   {
   double bull=0, bear=0;   
      for (i=0;i<=Length-1;i++)
      {
      if(Close[shift+i]>Close[shift+i+1]) bull += 1;
      if(Close[shift+i]<Close[shift+i+1]) bear += 1;
      }
   if(bull+bear != 0) STIX[shift] = 100*bull/(bull+bear);
   }

   for( shift=limit; shift>=0; shift--)
   AvgSTIX[shift]=iMAOnArray(STIX,0,Smooth,0,ModeMA,shift);     
   
//----
   return(0);
  }
//+------------------------------------------------------------------+