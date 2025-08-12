//+------------------------------------------------------------------+
//|                                             T3_Price_Overlay.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+


#property indicator_buffers 10
#property indicator_chart_window

/* Candles */
#property indicator_color1 clrLime
#property indicator_color2 clrLime
#property indicator_color3 clrLime
#property indicator_color4 clrLime
#property indicator_color5 clrRed
#property indicator_color6 clrRed
#property indicator_color7 clrRed
#property indicator_color8 clrRed
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3

/* T3 Lines */
#property indicator_color9 clrRed
#property indicator_style9 STYLE_SOLID
#property indicator_width9 2
#property indicator_color10 clrRed
#property indicator_style10 STYLE_SOLID
#property indicator_width10 2

extern int    Periods       = 20;
extern double Volume_Factor = 0.7;

double Up_High[];
double Up_Low[];
double Up_Open[];
double Up_Close[];
double Dn_High[];
double Dn_Low[];
double Dn_Open[];
double Dn_Close[];

double T3_High[];
double T3_Low[];

double e1=0;
double e2=0;
double e3=0;
double e4=0;
double e5=0;
double e6=0;

double c1,c2,c3,c4;
double b2,b3;

int Bullish = 1;
int Bearish = -1;
int Neutral = 0;

int init(){
   
   IndicatorShortName("T3 Price Overlay");
   IndicatorBuffers(10);
   
   SetIndexBuffer(0,Up_High);
   SetIndexBuffer(1,Up_Low);
   SetIndexBuffer(2,Up_Open);
   SetIndexBuffer(3,Up_Close);
   SetIndexBuffer(4,Dn_High);
   SetIndexBuffer(5,Dn_Low);
   SetIndexBuffer(6,Dn_Open);
   SetIndexBuffer(7,Dn_Close);
   
   for (int i=0; i<8; i++){
      SetIndexStyle(i,DRAW_HISTOGRAM);
   }
   
   SetIndexStyle(8,DRAW_LINE);
   SetIndexBuffer(8,T3_High);
   SetIndexLabel(8,"T3 High");
   
   SetIndexStyle(9,DRAW_LINE);
   SetIndexBuffer(9,T3_Low);
   SetIndexLabel(9,"T3 High");
   
   b2=0; b3=0;

   b2=Volume_Factor*Volume_Factor;
   b3=b2*Volume_Factor;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+Volume_Factor+b3);
   c4=(1+3*Volume_Factor+b3+3*b2);
   
   return(0);
}

int start()
  {
   
   int i, bias;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double n  = 1 + 0.5*(Periods-1);
   double w1 = 2 / (n + 1);
   double w2 = 1 - w1;
   
   for(i=limit; i>=0; i--){
      
      e1 = w1*High[i] + w2*e1;
      e2 = w1*e1 + w2*e2;
      e3 = w1*e2 + w2*e3;
      e4 = w1*e3 + w2*e4;
      e5 = w1*e4 + w2*e5;
      e6 = w1*e5 + w2*e6;
      T3_High[i] = (c1*e6) + (c2*e5) + (c3*e4) + (c4*e3);
      
   }
   
   for(i=limit; i>=0; i--){
      
      e1 = w1*Low[i] + w2*e1;
      e2 = w1*e1 + w2*e2;
      e3 = w1*e2 + w2*e3;
      e4 = w1*e3 + w2*e4;
      e5 = w1*e4 + w2*e5;
      e6 = w1*e5 + w2*e6;
      T3_Low[i] = (c1*e6) + (c2*e5) + (c3*e4) + (c4*e3);
      
   }
   
   for(i=limit; i>=0; i--){
   
      bias=ColorCandle(T3_High[i], T3_Low[i], Close[i]);
   
      if(bias>0){
         
         Up_High[i]  = iHigh(NULL,0,i);
         Up_Low[i]   = iLow(NULL,0,i);  
         Up_Open[i]  = iOpen(NULL,0,i);
         Up_Close[i] = iClose(NULL,0,i);  
      
      }
      else if(bias<0){
         
         Dn_High[i]  = iHigh(NULL,0,i);
         Dn_Low[i]   = iLow(NULL,0,i);  
         Dn_Open[i]  = iOpen(NULL,0,i);
         Dn_Close[i] = iClose(NULL,0,i);
      
      }
      
   }
   
//----
   return(0);
}

int ColorCandle(double high_value, double low_value, double close_value){
 
 if (close_value > high_value)
   
   return (Bullish);
 
 else if (close_value < low_value)
   
   return (Bearish);
 
 else
   
   return (Neutral);

}