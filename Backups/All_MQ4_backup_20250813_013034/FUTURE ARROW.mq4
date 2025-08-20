//+------------------------------------------------------------------+
//|                                                       Future.mq4 |
//|                                              Copyright 2019, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property  indicator_buffers 2

input int count=111;
input int shift=1;

//--- indicator buffers
double  up[];
double  dn[];

input string i1="Night_Walker_V2_Pro_fix";
input string i2="Future Volume_fix";
input int volume_index=3;
input int filter1=3;
input int filter2=3;
input int filter3=5;
input int filter4=30;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0,DRAW_ARROW,0,4,Aqua);
   SetIndexStyle(1,DRAW_ARROW,0,4,Yellow);
   SetIndexBuffer(0,up);
   SetIndexBuffer(1,dn);
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   Comment("");
//---
   return(INIT_SUCCEEDED);
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
//---

   for(int i=1;i<count;i++)
     {
      double i1buy=iCustom(NULL,0,i1,0,i);
      double i1sell=iCustom(NULL,0,i1,1,i);

      double i2buy=iCustom(NULL,0,i2,volume_index,filter1,filter2,filter3,filter4,0,i);
      double i2sell=iCustom(NULL,0,i2,volume_index,filter1,filter2,filter3,filter4,1,i);

      if(i1buy>0  &&  i2buy<1000)  {up[i]=low[i];Alert(Symbol(), (" M"), Period(), "  FUTURE ARROW : BUY!");}
      if(i1sell>0 &&  i2sell<1000) {dn[i]=high[i];Alert(Symbol(), (" M"), Period(), "  FUTURE ARROW : SELL!");}
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
