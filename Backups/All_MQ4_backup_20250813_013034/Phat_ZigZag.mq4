//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "lowphat" 
#property link      "forextrash@yahoo.com" 

#property indicator_chart_window 
#property indicator_buffers 2 
#property indicator_color1 Lime 
#property indicator_color2 Red
//---- input parameters 
extern int ForcedZigTime=60; 
extern int ExtDepth=15; 
extern int ExtDeviation=5; 
extern int ExtBackstep=3; 
extern bool ShowSettingsOnChart=false;
//---- buffers 
double ExtMapBuffer1[]; 
double ExtMapBuffer2[]; 
datetime daytimes[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
  { 
//---- indicators 
   SetIndexStyle(0,DRAW_ARROW); 
   SetIndexArrow(0,163); 
   SetIndexBuffer(0,ExtMapBuffer1); 
   
   SetIndexStyle(1,DRAW_ARROW,EMPTY,0);
   SetIndexArrow(1, 163);   
   SetIndexBuffer(1,ExtMapBuffer2);  
   SetIndexEmptyValue(0,0.0); 
   


      IndicatorShortName("ZigZagPhat ("+ForcedZigTime+")"); 
   
  if (ShowSettingsOnChart==true()){
   Comment("\nZigZag Forced Time ("+ForcedZigTime+")\nZigZag Exit Depth ("+ExtDepth+")\nZigZag Exit Deviation ("+ExtDeviation+")\nZigZag Exit Backstep ("+ExtBackstep+")");
   
}
   

   ArrayCopySeries(daytimes,MODE_TIME,Symbol(),ForcedZigTime); 
   return(0); 
  } 
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
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
   int    limit, bigshift; 
   int    counted_bars=IndicatorCounted(); 
//---- 
   if (counted_bars<0) return(-1); 
    
   if (counted_bars>0) counted_bars--; 
    
   limit=Bars-counted_bars; 
    
   for (int i=0; i<limit; i++) 
   { 
   if(Time[i]>=daytimes[0]) bigshift=0; 
   else 
     { 
      bigshift = ArrayBsearch(daytimes,Time[i-1],WHOLE_ARRAY,0,MODE_DESCEND); 
      if(Period()<=ForcedZigTime) bigshift++; 
     } 
  ExtMapBuffer1[i]=iCustom(NULL,ForcedZigTime,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,bigshift); 
  ExtMapBuffer2[i]=iCustom(NULL,ForcedZigTime,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,1,bigshift); 
   } 

   return(0); 
  } 

