//+------------------------------------------------------------------+
//|                                          Support and Resistance  |
//|                                  Copyright © 2004 Barry Stander  |
//|                           Arrows added by Lennoi Anderson, 2015  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004 Barry Stander; Arrow alerts by Lennoi Anderson, 2015."
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Magenta
#property indicator_width3 2
#property indicator_width4 2

extern bool RSICCI_Filter = FALSE;
extern double RSIPeriod = 14;
extern double RSIOverbought = 75;
extern double RSIOversold = 25;
extern double CCIPeriod = 14;
extern double CCIBuyLevel = 50;
extern double CCISellLevel = -50;
extern bool HighLow = FALSE;
extern int SignalDots = 3;
extern bool Alerts = TRUE;
extern bool AlertOnClose = TRUE;
extern int BarCount = 10000; 

bool HighBreakout = FALSE;
bool HighBreakPending = FALSE;        
bool LowBreakout = FALSE;
bool LowBreakPending = FALSE; 
double LastResistance = 0;
double LastSupport = 0;
double AlertBar = 0;
//---- buffers
double v1[];
double v2[];
double BreakUp[];
double BreakDown[];
double val1;
double val2;
int counter1;
int counter2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
//---- drawing settings
   SetIndexArrow(0, 119);
   SetIndexArrow(1, 119);
//----  
   SetIndexStyle(0, DRAW_ARROW, STYLE_DOT, 0, Red);
   //SetIndexDrawBegin(0, i-1);
   SetIndexBuffer(0, v1);
   SetIndexLabel(0, "Resistance");
//----    
   SetIndexStyle(1, DRAW_ARROW, STYLE_DOT, 0, Blue);
   //SetIndexDrawBegin(1, i-1);
   SetIndexBuffer(1, v2);
   SetIndexLabel(1, "Support");
//---- 
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(2, 233);
   SetIndexBuffer(2, BreakUp);
//----   
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(3, 234);
   SetIndexBuffer(3, BreakDown);
   return(0);
}
//+------------------------------------------------------------------+
int start()
{   
//----
   for(int i = BarCount; i >=0; i--)
   {   
       val1 = iFractals(NULL, 0, MODE_UPPER, i);
       //----
       if(val1 > 0)
       { 
           v1[i] = High[i];
           counter1 = 1;          
       }
       else
       {
           v1[i] = v1[i+1];
           counter1++;           
       }
       val2 = iFractals(NULL, 0, MODE_LOWER, i);
       //----
       if(val2 > 0)
       { 
           v2[i] = Low[i];
           counter2 = 1;     
       }
       else
       {
           v2[i] = v2[i+1];
           counter2++;        
       }
                    
       if (v1[i] != LastResistance) { HighBreakPending = True; LastResistance = v1[i]; }
       if (v2[i] != LastSupport) { LowBreakPending = True; LastSupport = v2[i]; }  
       
       if (HighLow) double BPrice=High[i]; else BPrice=Close[i];            
       if (HighBreakPending && BPrice > v1[i] && (!RSICCI_Filter || (RSICCI_Filter && iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, i) < RSIOverbought && 
           iCCI(Symbol(), NULL, CCIPeriod, PRICE_CLOSE, i) > CCIBuyLevel)) && counter1 >= SignalDots) HighBreakout = TRUE;
       if (HighLow) BPrice=Low[i]; else BPrice=Close[i];    
       if (LowBreakPending && BPrice < v2[i] && (!RSICCI_Filter || (RSICCI_Filter && iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, i) > RSIOversold && 
           iCCI(Symbol(), NULL, CCIPeriod, PRICE_CLOSE, i) < CCISellLevel)) && counter2 >= SignalDots) LowBreakout = TRUE; 
           
       if (AlertOnClose) int AlertCandle = 1; else AlertCandle = 0;         
       
       if (HighBreakout) 
       {          
         if (i >= AlertCandle) BreakUp[i] = Low[i]-10*Point;
         if (Alerts && i == AlertCandle && Bars > AlertBar) 
         { 
           Alert(Symbol(), " M", Period(), ": Resistance Breakout: BUY");
           AlertBar = Bars;
         } 
         HighBreakout = False; 
         HighBreakPending = False;
       } else
       if (LowBreakout) 
       { 
         if (i >= AlertCandle) BreakDown[i] = High[i]+10*Point;              
         if (Alerts && i==AlertCandle && Bars>AlertBar)
         {  
           Alert(Symbol(), " M", Period(), ": Support Breakout: SELL");
           AlertBar = Bars;
         }
         LowBreakout = False;
         LowBreakPending = False;
       }    
   }  
   return(0);
}