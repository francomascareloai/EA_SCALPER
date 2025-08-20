//+------------------------------------------------------------------+
//|                                             # BuySell_Filter.mq4 |
//|                                        Copyright © 2008, masemus |
//|                                                 Gresik@Indonesia |
//+------------------------------------------------------------------+
#property copyright "masemus"
#property link      "masemus@yahoo.com"

#property indicator_separate_window
#property indicator_maximum 1
#property indicator_minimum 0
#property indicator_buffers 7
#property indicator_color1 C'255,206,215'
#property indicator_color2 C'255,234,238'
#property indicator_color3 C'220,250,220'
#property indicator_color4 C'180,245,180'
#property indicator_color5 DeepPink
#property indicator_color6 LimeGreen
#property indicator_color7 DarkGray

#property indicator_width1 5
#property indicator_width2 5
#property indicator_width3 5
#property indicator_width4 5

//---- input parameters
extern int MA1Period      = 4;
extern int MA1_Shift      = 0;
extern int MA1_Method     = 0;
extern int MA1_Price_Type = 0;
extern int MA2Period      = 4;
extern int MA2_Shift      = 0;
extern int MA2_Method     = 0;
extern int MA2_Price_Type = 1;

extern int MA3Period      = 20;
extern int MA3_Shift      = 0;
extern int MA3_Method     = 0;
extern int MA3_Price_Type = 0;
extern int MA4Period      = 20;
extern int MA4_Shift      = 0;
extern int MA4_Method     = 0;
extern int MA4_Price_Type = 1;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double UpBuffer1[];
double DnBuffer1[];
double SwBuffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexBuffer(0,ExtMapBuffer1);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexBuffer(1,ExtMapBuffer2);
  SetIndexStyle(2,DRAW_HISTOGRAM);
  SetIndexBuffer(2,ExtMapBuffer3);
  SetIndexStyle(3,DRAW_HISTOGRAM);
  SetIndexBuffer(3,ExtMapBuffer4);

  SetIndexStyle(4,DRAW_ARROW);
  SetIndexStyle(5,DRAW_ARROW);
  SetIndexStyle(6,DRAW_ARROW);
  SetIndexBuffer(4,DnBuffer1);
  SetIndexBuffer(5,UpBuffer1);
  SetIndexBuffer(6,SwBuffer1);
  SetIndexArrow(4,108);
  SetIndexArrow(5,108);
  SetIndexArrow(6,108);

  SetIndexLabel(0,NULL); SetIndexLabel(1,NULL); SetIndexLabel(2,NULL);
  SetIndexLabel(3,NULL); SetIndexLabel(4,NULL); SetIndexLabel(5,NULL);
  SetIndexLabel(6,NULL);

   IndicatorShortName("BuySell :: ");  

 
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
   int      i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
  
     limit = Bars-counted_bars;

   for( i=limit; i>=0; i--)
   {
   
   ExtMapBuffer1[i]=0.0;
   ExtMapBuffer2[i]=0.0;
   ExtMapBuffer3[i]=0.0;
   ExtMapBuffer4[i]=0.0;
   
   double MA1 = iMA(Symbol(),0,MA1Period,MA1_Shift,MA1_Method,MA1_Price_Type,i);
   double MA2 = iMA(Symbol(),0,MA2Period,MA2_Shift,MA2_Method,MA2_Price_Type,i);
   double MA3 = iMA(Symbol(),0,MA3Period,MA3_Shift,MA3_Method,MA3_Price_Type,i);
   double MA4 = iMA(Symbol(),0,MA4Period,MA4_Shift,MA4_Method,MA4_Price_Type,i);

   double pMA1 = iMA(Symbol(),0,MA1Period,MA1_Shift,MA1_Method,MA1_Price_Type,i+1);

   if(MA1>MA2 && MA1>MA3)ExtMapBuffer4[i] = 1;
   if(MA1<=MA2 && MA1>MA3){ExtMapBuffer2[i] = 1;}
   if(MA1>=MA2 && MA1<MA3)ExtMapBuffer3[i] = 1;
   if(MA1<MA2 && MA1<MA3){ExtMapBuffer1[i] = 1;}

   if (MA1 < pMA1) {DnBuffer1[i] = 0.5;}
   else if (MA1 > pMA1) {UpBuffer1[i] = 0.5;}
        else {SwBuffer1[i] = 0.5;}

  }
 
 
 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+