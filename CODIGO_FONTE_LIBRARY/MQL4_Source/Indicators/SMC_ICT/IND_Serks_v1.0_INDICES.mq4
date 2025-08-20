//+------------------------------------------------------------------+
//|                                                        Serks.mq4 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1  DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_color1 clrBlue
//---
input ENUM_APPLIED_PRICE iPrice=PRICE_CLOSE;
input ushort Shift=1;
double buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   ArraySetAsSeries(buffer,true);
   SetIndexEmptyValue(0,EMPTY_VALUE);

   if(Shift==0)
     {
      Alert("Wow!");
      return(INIT_FAILED);
     }
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
   if(rates_total>prev_calculated)
     {
      //---
      ArraySetAsSeries(open,true);
      ArraySetAsSeries(high,true);
      ArraySetAsSeries(low,true);
      ArraySetAsSeries(close,true);

      int bars=prev_calculated>0?rates_total-prev_calculated-1:rates_total-2*Shift-5;
      if(bars<0)
         return(0);

      for(int i=bars; i>=0; i--)
        {
         int p1=(int)MathRound(price(open[i+1],high[i+1],low[i+1],close[i+1])/_Point),
             p2=(int)MathRound(price(open[i+2],high[i+2],low[i+2],close[i+2])/_Point),
             p3=(int)MathRound(price(open[i+3],high[i+3],low[i+3],close[i+3])/_Point),
             p4=(int)MathRound(price(open[i+4],high[i+4],low[i+4],close[i+4])/_Point),
             p0s1=(int)MathRound(price(open[i+Shift],high[i+Shift],low[i+Shift],close[i+Shift])/_Point),
             p0s2=(int)MathRound(price(open[i+2*Shift],high[i+2*Shift],low[i+2*Shift],close[i+2*Shift])/_Point),
             p1s1=(int)MathRound(price(open[i+Shift+1],high[i+Shift+1],low[i+Shift+1],close[i+Shift+1])/_Point),
             p1s2=(int)MathRound(price(open[i+2*Shift+1],high[i+2*Shift+1],low[i+2*Shift+1],close[i+2*Shift+1])/_Point),
             p2s1=(int)MathRound(price(open[i+Shift+2],high[i+Shift+2],low[i+Shift+2],close[i+Shift+2])/_Point),
             p2s2=(int)MathRound(price(open[i+2*Shift+2],high[i+2*Shift+2],low[i+2*Shift+2],close[i+2*Shift+2])/_Point),
             p3s1=(int)MathRound(price(open[i+Shift+3],high[i+Shift+3],low[i+Shift+3],close[i+Shift+3])/_Point),
             p3s2=(int)MathRound(price(open[i+2*Shift+3],high[i+2*Shift+3],low[i+2*Shift+3],close[i+2*Shift+3])/_Point),
             p4s1=(int)MathRound(price(open[i+Shift+4],high[i+Shift+4],low[i+Shift+4],close[i+Shift+4])/_Point),
             p4s2=(int)MathRound(price(open[i+2*Shift+4],high[i+2*Shift+4],low[i+2*Shift+4],close[i+2*Shift+4])/_Point),
             denom=(p1s1-p2s1)*(p2s1-p3s1)*(p1s1-p3s1)*(p4s1-p3s1)*(p4s1-p2s1)*(p4s1-p1s1);

         if(denom!=0)
           {
            int k012=p0s1*p0s1,k013=k012*p0s1,k112=p1s1*p1s1,k113=k112*p1s1,k212=p2s1*p2s1,k213=k212*p2s1,k312=p3s1*p3s1,k313=k312*p3s1,k412=p4s1*p4s1,
                k413=k412*p4s1,v1=k012*k113,v2=k012*k213,v3=k012*k313,v4=k012*k413,v5=k013*k112,v6=k013*k212,v7=k013*k312,v8=k013*k412,v9=k112*k213,
                v10=k112*k313,v11=k112*k413,v12=k113*k212,v13=k113*k312,v14=k113*k412,v15=k212*k313,v16=k212*k413,v17=k213*k312,v18=k213*k412,v19=k312*k413,
                v20=k313*k412,r1=p4s2-p3+p4-p3s2,r2=p2-p4s2-p4+p2s2,r3=p2-p3+p2s2-p3s2,r4=p1-p4s2-p4+p1s2,r5=p1-p3+p1s2-p3s2,r6=p4s2-p2+p4-p2s2,
                r7=p1-p2+p1s2-p2s2,r8=p3s2-p2+p3-p2s2,r9=p3-p4+p3s2-p4s2,r10=p4-p0s2+p4s2,r11=p3-p0s2+p3s2,r12=p2-p0s2+p2s2,r13=p1-p0s2+p1s2;

            buffer[i]=1.0*(-(r1*p2s1+r2*p3s1-r3*p4s1)*v1+(r1*p1s1+r4*p3s1-p4s1*r5)*v2-(r6*p1s1+r4*p2s1-p4s1*r7)*v3+(r8*p1s1+r5*p2s1-p3s1*r7)*v4+
                           (r1*p2s1+r2*p3s1-p4s1*r3)*v5-(r1*p1s1+r4*p3s1-p4s1*r5)*v6+(r6*p1s1+r4*p2s1-p4s1*r7)*v7-(r8*p1s1+r5*p2s1-p3s1*r7)*v8+
                           (r9*p0s1+r10*p3s1-p4s1*r11)*v9-(r2*p0s1+r10*p2s1-p4s1*r12)*v10+(r3*p0s1+r11*p2s1-p3s1*r12)*v11-(r9*p0s1+r10*p3s1-p4s1*r11)*v12+
                           (r2*p0s1+r10*p2s1-p4s1*r12)*v13-(r3*p0s1+r11*p2s1-p3s1*r12)*v14+(r4*p0s1+r10*p1s1-p4s1*r13)*v15-(r5*p0s1+r11*p1s1-p3s1*r13)*v16-
                           (r4*p0s1+r10*p1s1-p4s1*r13)*v17+(r5*p0s1+r11*p1s1-p3s1*r13)*v18+(r7*p0s1+r12*p1s1-p2s1*r13)*v19-(r7*p0s1+r12*p1s1-p2s1*r13)*v20)
                      /denom;
           }
        }
      //---
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double price(double open,double high,double low,double close)
  {
//---
   if(iPrice==PRICE_CLOSE)
      return(close);
   if(iPrice==PRICE_OPEN)
      return(open);
   if(iPrice==PRICE_HIGH)
      return(high);
   if(iPrice==PRICE_LOW)
      return(low);
   if(iPrice==PRICE_MEDIAN)
      return((high+low)/2);
   if(iPrice==PRICE_TYPICAL)
      return((high+low+close)/3);
   return((high+low+2*close)/4);
//---
  }
//+------------------------------------------------------------------+
