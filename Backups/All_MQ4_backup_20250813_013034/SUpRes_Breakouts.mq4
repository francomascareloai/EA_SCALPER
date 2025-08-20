//+------------------------------------------------------------------+
//|                                                   ADXcrosses.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1
//---- input parameters
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double trend[];
//----
double bs,br;
int    nShift,up,dn;   
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(3);
   SetIndexBuffer(0, ExtMapBuffer1); SetIndexStyle(0, DRAW_ARROW);  SetIndexArrow(0, 233);
   SetIndexBuffer(1, ExtMapBuffer2); SetIndexStyle(1, DRAW_ARROW);  SetIndexArrow(1, 234);
   SetIndexBuffer(2, trend);

//---- name for DataWindow and indicator subwindow label
    IndicatorShortName("Break in Sup/res");
    SetIndexLabel(0, "supup");
    SetIndexLabel(1, "supdn"); 
//----
    switch(Period())
      {
        case     1: nShift = 1;   break;    
        case     5: nShift = 3;   break; 
        case    15: nShift = 5;   break; 
        case    30: nShift = 10;  break; 
        case    60: nShift = 15;  break; 
        case   240: nShift = 20;  break; 
        case  1440: nShift = 80;  break; 
        case 10080: nShift = 100; break; 
        case 43200: nShift = 200; break;               
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
   int limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   
   for(int i = limit; i>=0; i--)
   {
      br=iCustom(NULL,0,"support and resistance (barry)1",0,i);
      bs=iCustom(NULL,0,"support and resistance (barry)1",1,i);
       
      ExtMapBuffer1[i]=EMPTY_VALUE;
      ExtMapBuffer2[i]=EMPTY_VALUE;
      trend[i]        =trend[i+1];
      
      if(Open[i]>br && Open[i]>bs ) trend[i]= 1;
      if(Open[i]<br && Open[i]<bs ) trend[i]=-1;
      if (trend[i]!=trend[i+1])
      if (trend[i]==1)
            ExtMapBuffer1[i] = Low[i]  - nShift*Point;
      else  ExtMapBuffer2[i] = High[i] + nShift*Point;
   }
   return(0);
}


