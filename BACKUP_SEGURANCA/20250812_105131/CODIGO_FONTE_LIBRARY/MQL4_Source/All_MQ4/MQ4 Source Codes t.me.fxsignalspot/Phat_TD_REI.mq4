//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "lowphat" 
#property link      "forextrash@yahoo.com" 
#property indicator_separate_window
//#property indicator_chart_window 
#property indicator_buffers 4 
#property indicator_color1 Lime 
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 White
//---- input parameters 

extern int NeutralZone = 45;
extern int Level = 8;

//---- buffers 
double main[]; 
double green[]; 
double red[];
double white[];
datetime daytimes[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
  { 
//---- indicators 
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexArrow(0,158); 
   SetIndexBuffer(0,main); 
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexArrow(2, 250);   
   SetIndexBuffer(2,green);  
   SetIndexEmptyValue(0,0.0); 
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexArrow(1, 250);   
   SetIndexBuffer(1,red);  
   SetIndexEmptyValue(0,0.0); 
   
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexArrow(3, 250);   
   SetIndexBuffer(3,white);  
   SetIndexEmptyValue(0,0.0); 
  
   IndicatorShortName("||-Phat TD_REI-||-Zone(+/-"+NeutralZone+")-||-Level(+/-"+Level+")-||"); 
      return(0); 
  } 
      int deinit() 
  { 
      return(0); 
  } 
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
     main[i]=iCustom(NULL,0,"TD_REI",Level,0,i); 

      if (main[i] >= NeutralZone )
     green[i] = main[i];
      else
     green[i] = 0;
      if (main[i] < NeutralZone && main[i] > -NeutralZone )
     white[i] = main[i];
      else
     white[i] = 0;   
      if (main[i] < -NeutralZone )
     red[i] = main[i];
      else
     red[i]=0; 
        }
   return(0); 
  } 