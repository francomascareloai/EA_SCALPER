//+------------------------------------------------------------------+
//|                                                 Weekly_HILO_Shj  |
//|                                                                  |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, "
#property link      "http://"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Tomato
#property indicator_color2 DeepSkyBlue
#property indicator_color3 LimeGreen
#property indicator_width1 2
#property indicator_width2 2
//---- input parameters
//---- buffers
extern int space=44;
double PrevWeekHiBuffer[];
double PrevWeekLoBuffer[];
double PrevWeekMidBuffer[];
int fontsize=10;
double x;
double PrevWeekHi, PrevWeekLo, LastWeekHi, LastWeekLo,PrevWeekMid;
string Space;
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("PrevWeekHi");
   ObjectDelete("PrevWeekLo");
   ObjectDelete("PrevWeekMid");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   int y;
//----
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(0, PrevWeekHiBuffer);
   SetIndexBuffer(1, PrevWeekLoBuffer);
   SetIndexBuffer(2, PrevWeekMidBuffer);
   short_name="Prev Hi-Lo levels";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   SetIndexDrawBegin(0,1);
//----
   for(y=0;y<=space;y++)
     {
      Space=Space+" ";
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   int limit, i;
   if (counted_bars==0)
     {
      x=Period();
      if (x>240) return(-1);
      ObjectCreate("PrevWeekHi", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("PrevWeekHi", Space+"HIGH minggu lalu",fontsize,"Arial", Tomato);
      ObjectCreate("PrevWeekLo", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("PrevWeekLo", Space+"LOW minggu lalu",fontsize,"Arial", DeepSkyBlue);
      ObjectCreate("PrevWeekMid", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("PrevWeekMid", Space+"50% hi-low ",fontsize,"Arial", LimeGreen);
     }
   if(counted_bars > 0)  counted_bars--;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;
   
   for(i=limit; i>=0;i--)
     {
      if (High[i+1]>LastWeekHi) LastWeekHi=High[i+1];
      if (Low [i+1]<LastWeekLo) LastWeekLo=Low [i+1];
      if (TimeDay(Time[i])!=TimeDay(Time[i+1]))
        {
         if(TimeDayOfWeek(Time[i])==1)
           {
            PrevWeekHi =LastWeekHi;
            PrevWeekLo =LastWeekLo;
            LastWeekHi =Open[i];
            LastWeekLo =Open[i];
            PrevWeekMid=(PrevWeekHi + PrevWeekLo)/2;
           }
        }
      PrevWeekHiBuffer [i]=PrevWeekHi;
      PrevWeekLoBuffer [i]=PrevWeekLo;
      PrevWeekMidBuffer[i]=PrevWeekMid;
//----
      ObjectMove("PrevWeekHi" , 0, Time[i], PrevWeekHi);
      ObjectMove("PrevWeekLo" , 0, Time[i], PrevWeekLo);
      ObjectMove("PrevWeekMid", 0, Time[i], PrevWeekMid);
     }

   return(0);
  }
//+------------------------------------------------------------------+