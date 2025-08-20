//+------------------------------------------------------------------+
//|                                          Hodrick Prescott MA.mq4 |
//|                                               Yuriy Tokman (YTG) |
//|                                               https://ytg.com.ua |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "https://ytg.com.ua"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_color2 clrGold
#property indicator_width1 2
#property indicator_width2 2

input int Shift    = 5;
input int Filter_1 = 999;
input int Filter_2 = 1599;

double B0[];
double B1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string short_name = "Hodrick Prescott MA";
   IndicatorShortName(short_name);
   SetIndexLabel(1,short_name+" slow");
   SetIndexLabel(0,short_name+" fast");   
//--- indicator buffers mapping
   SetIndexBuffer(0,B0);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,Shift);

   SetIndexBuffer(1,B1);
   SetIndexStyle(1,DRAW_LINE);   
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
   Hodrick_Prescott_Filter(Filter_1,Filter_2,B0);
   Hodrick_Prescott_Filter(Filter_1,Filter_2,B1);   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void Hodrick_Prescott_Filter(int filtr1,int filtr2,double &buff[])
  {
   double a[],b[],c[],variable1=0,variable2=0,variable3=0,variable4=0,variable5=0,variable6,variable7=0,
   variable8=0,variable9=0,variable10,variable11,variable12;
   ArrayResize(a,filtr1);
   ArrayResize(b,filtr1);
   ArrayResize(c,filtr1);
   for(int i=0;i<filtr1;i++) buff[i]=Close[i];

   a[0]=1.0+filtr2;
   b[0]=-2.0*filtr2;
   c[0]=filtr2;
   for(int i=1;i<filtr1-2;i++)
     {
      a[i]=6.0*filtr2+1.0;
      b[i]=-4.0*filtr2;
      c[i]=filtr2;
     }
   a[1]=5.0*filtr2+1;
   a[filtr1-1]=1.0+filtr2;
   a[filtr1-2]=5.0*filtr2+1.0;
   b[filtr1-2]=-2.0*filtr2;
   b[filtr1-1]=0.0;
   c[filtr1-2]=0.0;
   c[filtr1-1]=0.0;

   for(int i=0;i<filtr1;i++)
     {
      variable12=a[i]-variable4*variable1-variable9*variable7;
      variable10=b[i];
      variable6=variable1;
      variable1=(variable10-variable4*variable2)/variable12;
      b[i]=variable1;
      variable11=c[i];
      variable7=variable2;
      variable2=variable11/variable12;
      c[i]=variable2;
      a[i]=(buff[i]-variable8*variable9-variable3*variable4)/variable12;
      variable8=variable3;
      variable3=a[i];
      variable4=variable10-variable5*variable6;
      variable9=variable5;
      variable5=variable11;
     }

   variable2=0;
   variable1=a[filtr1-1];
   buff[filtr1-1]=variable1;
   for(int i=filtr1-2;i>=0;i--)
     {
      buff[i]=a[i]-b[i]*variable1-c[i]*variable2;
      variable2=variable1;
      variable1=buff[i];
     }
  }
//----

