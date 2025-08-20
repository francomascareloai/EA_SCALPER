
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 1

extern int   tenkan     = 9;
extern int   kijun      = 26;
extern int   senkou     = 56;
//extern int   Weight     = 100;
extern int   TFrame     = 0;
//extern int    

extern int    Nbar=10000;
extern int    Weight=2;
extern bool   ShowSignal = true;
extern int    gap = 20;
extern bool   use233 = FALSE;

double ArrowUp[], ArrowDn[]; 
datetime key; 
//+------------------------------------------------------------------+
int init()  
{
  SetIndexBuffer(0,ArrowUp);       SetIndexStyle(0,DRAW_ARROW,0,Weight);    SetIndexLabel(0,"Up");   SetIndexArrow(0,233);
  SetIndexBuffer(1,ArrowDn);       SetIndexStyle(1,DRAW_ARROW,0,Weight);    SetIndexLabel(1,"Dn");   SetIndexArrow(1,234);
  IndicatorShortName ("MY 911 MTF ");
   return(0);
}
//+------------------------------------------------------------------+
int deinit()  {   return(0);  }
//+------------------------------------------------------------------+
int start()  
{
   int limit;
   double Kidjun, SpanA, SpanB, Chiko, Tenka, ma233;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(limit>Nbar) limit=Nbar;
   
   if(key!=Time[0])  
   {
     for(int i=limit;i>0;i--) 
     {
       ArrowUp[i] = 0;
       ArrowDn[i] = 0;
       Kidjun = iIchimoku(NULL,TFrame,tenkan,kijun,senkou,MODE_KIJUNSEN,   i);
       SpanA  = iIchimoku(NULL,TFrame,tenkan,kijun,senkou,MODE_SENKOUSPANA,i);
       SpanB  = iIchimoku(NULL,TFrame,tenkan,kijun,senkou,MODE_SENKOUSPANB,i);
       Chiko  = iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_CHIKOUSPAN, i+26);
       Tenka  = iIchimoku(NULL,TFrame,tenkan,kijun,senkou,MODE_TENKANSEN,  i);
       
       ma233  = iMA(NULL,TFrame,233,3,1,0,i);
       
       if(use233)  
       {
         if((iClose(NULL,TFrame,i) >= Kidjun  && 
             iClose(NULL,TFrame,i) >= SpanA   &&
             iClose(NULL,TFrame,i) >= SpanB   &&
             iClose(NULL,TFrame,i) >= ma233)   &&
             //Tenka  >= Kidjun)  &&
             
            (Kidjun > SpanA-TFrame*_Point ||
             Kidjun > SpanB-TFrame*_Point) &&
             
            (
             (iOpen(NULL,TFrame,i)   < SpanA ||
              iOpen(NULL,TFrame,i)   < SpanB)
            )
           )
             
              
            // iOpen(NULL,TFrame,i) < ma233
             
             
             
            if (ArrowUp[i+1]==0) ArrowUp[i] = High[i] + gap*_Point;

         if((iClose(NULL,TFrame,i) <= Kidjun  && 
             iClose(NULL,TFrame,i) <= SpanA   &&
             iClose(NULL,TFrame,i) <= SpanB   &&
             iClose(NULL,TFrame,i) <= ma233)   &&
             //Tenka  <= Kidjun)  &&
             
            (Kidjun < SpanA+TFrame*_Point ||
             Kidjun < SpanB+TFrame*_Point) &&
             
            (
             (iOpen(NULL,TFrame,i)   > SpanA   ||
              iOpen(NULL,TFrame,i)   > SpanB)
            )
           )
             
              
           //  iOpen(NULL,TFrame,i) > ma233))
             
             
             
             if (ArrowDn[i+1]==0) ArrowDn[i] = Low[i] - gap*_Point;
       }
       else  
       {
         if((iClose(NULL,TFrame,i) >= Kidjun  && 
             iClose(NULL,TFrame,i) >= SpanA   &&
             iClose(NULL,TFrame,i) >= SpanB   &&
             //SpanA-SpanB>_Period*5*_Point &&
             iClose(NULL,TFrame,i) > iOpen(NULL,TFrame,i)
             )  &&
             
            (Kidjun > SpanA-TFrame*_Point ||
             Kidjun > SpanB-TFrame*_Point) &&
             
            (
             (iLow(NULL,TFrame,i)   < SpanA ||
              iLow(NULL,TFrame,i+1) < SpanA ||
              iLow(NULL,TFrame,i)   < SpanB ||
              iLow(NULL,TFrame,i+1) < SpanB 
             ) 
              
              
            )
           )
             
             if (ArrowUp[i+1]==0) ArrowUp[i] = High[i] + _Period*_Point;

         if((iClose(NULL,TFrame,i) <= Kidjun  && 
             iClose(NULL,TFrame,i) <= SpanA   &&
             iClose(NULL,TFrame,i) <= SpanB   &&
             //SpanB-SpanA>_Period*5*_Point &&
             iClose(NULL,TFrame,i) < iOpen(NULL,TFrame,i)
             )  &&
             
            (Kidjun < SpanA+TFrame*_Point ||
             Kidjun < SpanB+TFrame*_Point) &&
             
            (
             (iHigh(NULL,TFrame,i)   > SpanA ||
              iHigh(NULL,TFrame,i+1) > SpanA || 
              iHigh(NULL,TFrame,i)   > SpanB ||
              iHigh(NULL,TFrame,i+1) > SpanB 
             
             )
              
              
            )
           ) 
             
             if (ArrowDn[i+1]==0) ArrowDn[i] = Low[i] - _Period*_Point;
       }
     
       if(i==1)  
       {
         if(ArrowUp[i]>0)  Alert(Symbol(),"   ", _Period, "   Покупка на 911");  
         if(ArrowDn[i]>0)  Alert(Symbol(),"   ", _Period, "   Продажа на 911"); 
       }
     }
     key=Time[0]; 
   }
   return(0);
}
//+------------------------------------------------------------------+
