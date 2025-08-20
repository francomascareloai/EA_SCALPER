//+------------------------------------------------------------------+
//|                                              Scalper-Fractal.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 DodgerBlue

extern int Sensetive = 2;

extern string pus1 = "";
extern string p_set = "Picks style";
extern int Arrow_code = 119;
extern int Arrow_width = 2;
extern color Arrow_color1 = Red;
extern color Arrow_color2 = DodgerBlue;
extern int Dot_from_candle = 0;

extern string pus2 = "";
extern string l_set = "Lines style";
extern int Line_code = 0;
extern int Line_width = 1;
extern color Line_color1 = Red;
extern color Line_color2 = DodgerBlue;
extern bool use_lines = true;


double buf_92[];
double buf_93[];
int time = 0;
bool draw_up_down_dot = FALSE;

double high_11 = 0.0;
double high_13 = 0.0;
double low_12 = 0.0;
double low_14 = 0.0;


datetime ut1=0;
double   up1=0;
datetime dt1=0;
double   dp1=0;

double point;

int init() {
point=Point;
if(Digits==3||Digits==5) point*=10;

   SetIndexStyle(0, DRAW_ARROW,0,Arrow_width,Arrow_color1);
   SetIndexArrow(0, Arrow_code);
   SetIndexBuffer(0, buf_92);
   SetIndexEmptyValue(0, 0.0);
   
   SetIndexStyle(1, DRAW_ARROW,0,Arrow_width,Arrow_color2);
   SetIndexArrow(1, Arrow_code);
   SetIndexBuffer(1, buf_93);
   SetIndexEmptyValue(1, 0.0);

  if(use_lines)
   {
   ObjectCreate("UpLine",OBJ_TREND,0,0,0,0,0);
   ObjectCreate("DownLine",OBJ_TREND,0,0,0,0,0);

   ObjectSet("UpLine",OBJPROP_COLOR,Line_color1);
   ObjectSet("UpLine",OBJPROP_WIDTH,Line_width);
   ObjectSet("UpLine",OBJPROP_STYLE,Line_code);

   ObjectSet("DownLine",OBJPROP_COLOR,Line_color2);
   ObjectSet("DownLine",OBJPROP_WIDTH,Line_width);
   ObjectSet("DownLine",OBJPROP_STYLE,Line_code);
   }
   
   return (0);
}

int deinit() {
   ObjectDelete("UpLine");
   ObjectDelete("DownLine");
   return (0);
}

int start() {
   int indicator_count = IndicatorCounted();
   if (indicator_count < 0) return (-1);
   if (indicator_count > 0) indicator_count--;
   int bars_count = Bars - indicator_count;
   
   for (int i = bars_count - 1; i > 0; i--) {
      if (bars_count == Bars) {buf_92[i] = 0;buf_93[i] = 0;}
      if (draw_up_down_dot == FALSE) {
         if (High[i + 1] < High[i + 2] && time == 0) {
            time = Time[i + 2];
            high_11 = High[i + 2];
            low_12 = Low[i + 1];
         }
         if (High[i] > high_11) {
            time = 0;
            high_11 = 0;
            low_12 = 0;
         }
         if (Close[i] < low_12-Sensetive*point && time != 0) {
            time = iBarShift(NULL, 0, time);
            draw_up_down_dot = TRUE;
            buf_92[time] = High[time] + Dot_from_candle*point;

           if(use_lines)
           {
            if(ut1>0)
               ObjectMove("UpLine",0,ut1,up1);
            ObjectMove("UpLine",1,Time[time],High[time] + Dot_from_candle*point);

            ut1=Time[time];
            up1=High[time] + Dot_from_candle*point;
            }
            
            time = 0;
         }
      }
      if (draw_up_down_dot == TRUE) {
         if (Low[i + 1] > Low[i + 2] && time == 0) {
            time = Time[i + 2];
            low_14 = Low[i + 2];
            high_13 = High[i + 1];
         }
         if (Low[i] < low_14) {
            time = 0;
            low_14 = 0;
            high_13 = 0;
         }
         if (Close[i] > high_13+Sensetive*point && time != 0) {
            time = iBarShift(NULL, 0, time);
            draw_up_down_dot = FALSE;
            buf_93[time] = Low[time] - Dot_from_candle*point;
            
           if(use_lines)
           {
            if(dt1>0)
               ObjectMove("DownLine",0,dt1,dp1);
            ObjectMove("DownLine",1,Time[time],Low[time] - Dot_from_candle*point);

            dt1=Time[time];
            dp1=Low[time] - Dot_from_candle*point;
            }
            
            time = 0;
         }
      }
   }
   
   
   return (0);
}
//+------------------------------------------------------------------+
