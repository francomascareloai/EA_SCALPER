#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Aqua
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_color5 Yellow
#property indicator_color6 Yellow
#property indicator_color7 Magenta
//---- input parameters
extern int Days=35; // колличество дней для расчёта

int AllBars,DW;
double F[7],Level;
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
 SetIndexBuffer(0, ExtMapBuffer1);
 SetIndexStyle(0, DRAW_LINE, 0, 2);
 SetIndexLabel(0,"Уровень 100%");
 SetIndexBuffer(1, ExtMapBuffer2);
 SetIndexStyle(1, DRAW_LINE, 0, 1);
 SetIndexLabel(1,"Уровень 76.0%");
 SetIndexBuffer(2, ExtMapBuffer3);
 SetIndexStyle(2, DRAW_LINE, 0, 1);
 SetIndexLabel(2,"Уровень 61.8%");
 SetIndexBuffer(3, ExtMapBuffer4);
 SetIndexStyle(3, DRAW_LINE, 0, 1);
 SetIndexLabel(3,"Уровень 50.0%");
 SetIndexBuffer(4, ExtMapBuffer5);
 SetIndexStyle(4, DRAW_LINE, 0, 1);
 SetIndexLabel(4,"Уровень 38.2%");
 SetIndexBuffer(5, ExtMapBuffer6);
 SetIndexStyle(5, DRAW_LINE, 0, 1);
 SetIndexLabel(5,"Уровень 23.6%");
 SetIndexBuffer(6, ExtMapBuffer7);
 SetIndexStyle(6, DRAW_LINE, 0, 2);
 SetIndexLabel(6,"Уровень 0.0%");
 ObjectCreate("F0",OBJ_TEXT,0,Time[0]+180*Period(),0);
 ObjectSetText("F0","100%",8,"Arial",indicator_color1);
 ObjectCreate("F1",OBJ_TEXT,0,Time[0]+180*Period(),0);
 ObjectSetText("F1","76.0%",8,"Arial",indicator_color2);
 ObjectCreate("F2",OBJ_TEXT,0,Time[0]+180*Period(),0);
 ObjectSetText("F2","61.8%",8,"Arial",indicator_color3);
 ObjectCreate("F3",OBJ_TEXT,0,Time[0]+180*Period(),0);
 ObjectSetText("F3","50.0%",8,"Arial",indicator_color4);
 ObjectCreate("F4",OBJ_TEXT,0,Time[0]+180*Period(),0);
 ObjectSetText("F4","38.2%",8,"Arial",indicator_color5);
 ObjectCreate("F5",OBJ_TEXT,0,Time[0]+180*Period(),0);
 ObjectSetText("F5","23.6%",8,"Arial",indicator_color6);
 ObjectCreate("F6",OBJ_TEXT,0,Time[0]+180*Period(),0);
 ObjectSetText("F6","0.0%",8,"Arial",indicator_color7);
 //---- indicator short name
 IndicatorShortName("Fibo_auto ("+Days+" days)");
 return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
 Comment("");
 for (int i=0;i<7;i++) if (ObjectFind("F"+i)!=-1) ObjectDelete("F"+i);
 return(0);
}

int start()
{
 if (Period()>PERIOD_D1)
 {
  Comment("WARNING: Invalid timeframe! Valid value < W1.");
  return(0);
 }
 
 if (TimeDayOfWeek(Time[0])!=DW)
 {
  int bar_high,bar_low,bar_end;
  double day_high;
  double day_low;
  int bars=Days*(PERIOD_D1/Period());
  
  bar_high=iHighest(NULL,0,MODE_HIGH,bars,0);
  day_high=High[bar_high];
  bar_low=iLowest(NULL,0,MODE_LOW,bars,0);
  day_low=Low[bar_low];
  if (bar_high<bar_low)
  {
   bar_end=bar_low;
   F[0]=day_low;
   F[1]=day_high-0.76*(day_high-day_low);
   F[2]=day_high-0.618*(day_high-day_low);
   F[3]=day_high-0.5*(day_high-day_low);
   F[4]=day_high-0.382*(day_high-day_low);
   F[5]=day_high-0.236*(day_high-day_low);
   F[6]=day_high;
  }
  else
  {
   bar_end=bar_high;
   F[0]=day_high;
   F[1]=day_low+0.76*(day_high-day_low);
   F[2]=day_low+0.618*(day_high-day_low);
   F[3]=day_low+0.5*(day_high-day_low);
   F[4]=day_low+0.382*(day_high-day_low);
   F[5]=day_low+0.236*(day_high-day_low);
   F[6]=day_low;
  }
  DW=TimeDayOfWeek(Time[0]);
 }
 int i,Limit;
 int counted_bars=IndicatorCounted();
 if (counted_bars>0) Limit=Bars-counted_bars-1; else Limit=bar_end;
 for (i=Limit;i>=0;i--)
 {
  ExtMapBuffer1[i]=NormalizeDouble(F[0],Digits);
  ExtMapBuffer2[i]=NormalizeDouble(F[1],Digits);
  ExtMapBuffer3[i]=NormalizeDouble(F[2],Digits);
  ExtMapBuffer4[i]=NormalizeDouble(F[3],Digits);
  ExtMapBuffer5[i]=NormalizeDouble(F[4],Digits);
  ExtMapBuffer6[i]=NormalizeDouble(F[5],Digits);
  ExtMapBuffer7[i]=NormalizeDouble(F[6],Digits);
 }
 if (AllBars!=Bars) 
 {
  for (i=0;i<7;i++) ObjectMove("F"+i,0,Time[0]+180*Period(),F[i]);
  AllBars=Bars;
 } 
 for (i=0;i<7;i++) if (High[0]>=F[i] && Low[0]<=F[i] && Level!=F[i])
 {
  Alert("Пересечение уровня ",ObjectDescription("F"+i)," - ",F[i]);
  Level=F[i];
 } 
}
//+------------------------------------------------------------------+