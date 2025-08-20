//+------------------------------------------------------------------+
//|                                                          RRD.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, File45"
#property link      "http://codebase.mql4.com/en/author/file45"
#property version   "1.00"
#property strict
#property indicator_chart_window

extern string Text = "Renko";
extern color Font_Color = DodgerBlue;
extern int Font_Size = 11;
extern bool Font_Bold = true;
extern int Left_Right = 25;
extern int Up_Down = 150;
extern int Corner = 1;

string The_Font;
double Pointz;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Pointz=Point;
// 1, 3 & 5 digits pricing
   if(Point==0.1) Pointz=1;
   if((Point==0.00001) || (Point==0.001)) Pointz*=10;

   if(Font_Bold==true)
     {
      The_Font="Arial Bold";
     }
   else
     {
      The_Font="Arial";
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinit                   
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("RNK");
//ObjectDelete(name_rnk);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   string name_rnk,Renko_Range;
   name_rnk="RNK";
   Renko_Range=DoubleToStr(MathAbs((Open[1]-Close[1])/Pointz),1);

   if(ObjectFind(name_rnk)!=-1) ObjectDelete(name_rnk);
   ObjectCreate(0,name_rnk,OBJ_LABEL,0,0,0);
   ObjectSetText(name_rnk,Text+" "+Renko_Range,Font_Size,The_Font,Font_Color);
   ObjectCreate(name_rnk,OBJ_LABEL,0,0,0);
   ObjectSet(name_rnk,OBJPROP_CORNER,1);
   ObjectSet(name_rnk,OBJPROP_XDISTANCE,Left_Right);
   ObjectSet(name_rnk,OBJPROP_YDISTANCE,Up_Down);//}

   return(rates_total);
  }
//+------------------------------------------------------------------+
