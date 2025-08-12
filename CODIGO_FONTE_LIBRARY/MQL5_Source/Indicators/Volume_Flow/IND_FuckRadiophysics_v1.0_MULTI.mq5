//+------------------------------------------------------------------+
//|                                             FuckRadiophysics.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_type1  DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_color1 clrBlue
input ushort iPeriod=24;
input uchar FontSize=12;
input color ClrFont=clrGray;
input short CoordX=250,
            CoordY=10;
input ENUM_BASE_CORNER Corner=CORNER_RIGHT_UPPER;
input ENUM_ANCHOR_POINT Anchor=ANCHOR_LEFT_UPPER;
int period,entropy[][2],cnt=1;
double center,array[][2],buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   ArraySetAsSeries(buffer,true);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   period=MathMax(3,iPeriod);
   ArrayResize(array,period);

   center=0.5*(period-1);

   ArrayResize(entropy,cnt,100);
   ArrayInitialize(entropy,0);

   LabelCreate("FuckRadiophysics");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,"FuckRadiophysics",-1,-1);
//---
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
   ArraySetAsSeries(close,true);

   int bars=prev_calculated>0? rates_total-prev_calculated:rates_total-period-1;

   for(int i=bars; i>=0; i--)
     {
      for(int j=0; j<period; j++)
        {
         array[j][0]=close[i+j];
         array[j][1]=j;
        }
      ArraySort(array);

      double sum=0,denom=0;
      for(int j=0; j<period; j++)
        {
         double a=1-MathAbs(center-array[j][1])/period,
                b=1-(double)j/period,
                k=MathSqrt(a*a+b*b);
         sum=sum+k*array[j][0];
         denom=denom+k;
        }
      double res=sum/denom;

      buffer[i]=res;

      if(i>0)
        {
         int diff=(int)MathRound((close[i]-res)/_Point),
             ind=ArrayBsearch(entropy,diff);
         if(entropy[ind][0]==diff)
            entropy[ind][1]++;
         else
           {
            ArrayResize(entropy,cnt+1);
            entropy[cnt][0]=diff;
            entropy[cnt][1]=1;
            ArraySort(entropy);
            cnt++;
           }
        }
      else
        {
         int diff=(int)MathRound((close[0]-res)/_Point),
             ind=ArrayBsearch(entropy,diff),
             prob=entropy[ind][1];
         if(prob>0)
           {
            int val=(int)MathRound(prob*MathLog(prob));
            ObjectSetString(0,"FuckRadiophysics",OBJPROP_TEXT,"Cur.Entropy = "+IntegerToString(val));
           }

        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LabelCreate(string name)
  {
//---
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,ClrFont);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,CoordX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,CoordY);
   ObjectSetInteger(0,name,OBJPROP_CORNER,Corner);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,Anchor);
//---
  }
//+------------------------------------------------------------------+
