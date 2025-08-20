//+------------------------------------------------------------------+
//|                                                  NonLagMA_v5.mq4 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Orange
#property indicator_width1 2
#property indicator_color2 Blue
#property indicator_width2 2
#property indicator_color3 Red
#property indicator_width3 2
//---- input parameters
extern int     Price          = 0;  // Apply to Price(0-Close;1-Open;
                                    // 2-High;3-Low;4-Median price;
                                    // 5-Typical price;6-Weighted Close) 
extern int     Length         = 9;  // Period of NonLagMA
extern int     Displace       = 0;  // DispLace or Shift 
extern int     Filter         = 0;  // Static filter in points
extern int     Color          = 1;  // Switch of Color mode (1-color)  
extern int     ColorBarBack   = 1;  // Bar back for color mode
extern double  Deviation      = 0;  // Up/down deviation        
//---- indicator buffers
double MABuffer[];
double UpBuffer[];
double DnBuffer[];
double trend[];
//----
double alfa[];
int i, Phase, Len, Cycle = 4;
double Coeff, beta, t, Sum, Weight, g;
double pi = 3.1415926535;    
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, MABuffer);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, UpBuffer);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, DnBuffer);
   SetIndexBuffer(3, trend);
   string short_name;
//---- name for DataWindow and indicator subwindow label
   short_name = "NonLagMA(" + Length + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, "NonLagMA");
   SetIndexLabel(1, "Up");
   SetIndexLabel(2, "Dn");
//----
   SetIndexShift(0, Displace);
   SetIndexShift(1, Displace);
   SetIndexShift(2, Displace);
//----   
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexEmptyValue(2, EMPTY_VALUE);
//----   
   SetIndexDrawBegin(0, Length*Cycle + Length);
   SetIndexDrawBegin(1, Length*Cycle + Length);
   SetIndexDrawBegin(2, Length*Cycle + Length);
//---- 
   Coeff =  3*pi;
   Phase = Length-1;
   Len = Length*Cycle + Phase;  
   ArrayResize(alfa,Len);
   Weight=0;          
   for(i = 0; i < Len - 1; i++)
     {
       if(i <= Phase - 1) 
           t = 1.0*i / (Phase - 1);
       else 
           t = 1.0 + (i - Phase+1)*(2.0*Cycle - 1.0) / (Cycle*Length - 1.0); 
       beta = MathCos(pi*t);
       g = 1.0 / (Coeff*t+1);   
       if(t <= 0.5 ) 
           g = 1;
       alfa[i] = g * beta;
       Weight += alfa[i];
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| NonLagMA_v5                                                      |
//+------------------------------------------------------------------+
int start()
  {
   int    i, shift, counted_bars = IndicatorCounted(), limit;
   double price;      
   if(counted_bars > 0)  
       limit = Bars - counted_bars;
   if(counted_bars < 0)  
       return(0);
   if(counted_bars ==0)  
       limit = Bars - Len - 1; 
   if(counted_bars < 1) 
       for(i = 1; i < Length*Cycle + Length; i++) 
         {
           MABuffer[Bars-i] = 0;    
           UpBuffer[Bars-i] = 0;  
           DnBuffer[Bars-i] = 0;  
         }
   for(shift = limit; shift >= 0; shift--) 
     {	
       Sum = 0;
       for(i = 0; i <= Len - 1; i++)
	        { 
           price = iMA(NULL, 0, 1, 0, 3, Price, i + shift);      
           Sum += alfa[i]*price;
         }  
	      if(Weight > 0) 
	          MABuffer[shift] = (1.0 + Deviation / 100)*Sum / Weight;
       if(Filter > 0)
         {
           if(MathAbs(MABuffer[shift] - MABuffer[shift+1]) < Filter*Point) 
               MABuffer[shift] = MABuffer[shift+1];
         }
       if(Color>0)
         {
           trend[shift] = trend[shift+1];
           if(MABuffer[shift] - MABuffer[shift+1] > Filter*Point) 
               trend[shift] = 1; 
           if(MABuffer[shift+1] - MABuffer[shift] > Filter*Point) 
               trend[shift] = -1; 
           if(trend[shift] > 0)
             {  
               UpBuffer[shift] = MABuffer[shift];
               if(trend[shift+ColorBarBack] < 0) 
                   UpBuffer[shift+ColorBarBack] = MABuffer[shift+ColorBarBack];
               DnBuffer[shift] = EMPTY_VALUE;
             }
           if(trend[shift] < 0) 
             {
               DnBuffer[shift] = MABuffer[shift];
               if(trend[shift+ColorBarBack] > 0) 
                   DnBuffer[shift+ColorBarBack] = MABuffer[shift+ColorBarBack];
               UpBuffer[shift] = EMPTY_VALUE;
             }
         }
     }
	  return(0);	
  }
//+------------------------------------------------------------------+