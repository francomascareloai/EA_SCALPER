//+------------------------------------------------------------------+
//|                                               TS_ADXAlertV01.mq4 |
//|                                                   Manfred Uschan |
//|                                     http://www.tradingschule.com |
//+------------------------------------------------------------------+
#property copyright "Manfred Uschan"
#property link      "http://www.tradingschule.com"
//---------------------------------------------
#property indicator_separate_window
#include <stdlib.mqh>
#property indicator_minimum -100
#property indicator_maximum 100
#property indicator_buffers 7
//---------------------------------------------
#property indicator_color1 clrRoyalBlue
#property indicator_color2 clrCrimson
#property indicator_color3 DimGray
#property indicator_color4 Navy
#property indicator_color5 clrCrimson
#property indicator_color6 clrRoyalBlue
#property indicator_color7 Yellow
//---------------------------------------------
#property indicator_width1 5
#property indicator_width2 5
#property indicator_width3 5
#property indicator_width4 2
#property indicator_width5 2 
#property indicator_width6 2
#property indicator_width7 2
#property indicator_level1 0.0
//---------------------------------------------
extern int     ADXPeriod = 28;
extern int      ADXLevel = 24;
extern int FastEmaPeriod = 12;
extern int SlowEmaPeriod = 26;
extern int  SignalPeriod = 9;
extern int         limit = 300;
extern bool       Spread = false;
extern int        Corner = 3;
input color	 ColorSpread = clrYellow;
//---- progvars
double buf_adxplusdi[], buf_adxplusdival[];
double buf_adxminusdi[], buf_adxminusdival[];
double buf_adx[], buf_adxval[];
double buf_adxdifference[];
double buf_linedi[];
double buf_adxinactive[];
double buf_adxstrengthbar[];
double buf_entry[];
double buf_macdmain[];
double buf_macdsignal[];
double buf_null[];
double Poin;
int n_digits = 0;
double divider = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,5);
   SetIndexBuffer(0,buf_adxplusdi);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,5);
   SetIndexBuffer(1,buf_adxminusdi);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,5);
   SetIndexBuffer(2,buf_adxinactive);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(3,buf_null);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(4,buf_macdmain);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(5,buf_macdsignal);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(6,buf_entry);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){ObjectDelete("Spread");return(0);}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int dig = 1;
   if (Digits == 5)  {dig = 10;}
   if(Spread)
   {
   showSpread();
   }   
//----
   if(counted_bars<0) return(-1);
   //---- the last counted bar will be recounted
   if(counted_bars>0) counted_bars--;  
   for(int i=0; i < limit; i++)
	{
	   double adxplusdi =  iADX(NULL,0,ADXPeriod,PRICE_CLOSE,MODE_PLUSDI,i);
      double adxminusdi =  -iADX(NULL,0,ADXPeriod,PRICE_CLOSE,MODE_MINUSDI,i);
      double adxval =  iADX(NULL,0,ADXPeriod,PRICE_CLOSE,MODE_MAIN,i);       
      double macdmain = iMACD(NULL,0,FastEmaPeriod,SlowEmaPeriod,SignalPeriod,PRICE_CLOSE, MODE_MAIN, i);
      double macdsignal = iMACD(NULL,0,FastEmaPeriod,SlowEmaPeriod,SignalPeriod,PRICE_CLOSE, MODE_SIGNAL, i);           
      buf_adxplusdival[i] = adxplusdi;
      buf_adxplusdi[i] = adxplusdi;     
      buf_adxminusdival[i] = adxminusdi;
      buf_adxminusdi[i] = adxminusdi;     
      buf_adxval[i] = adxval;           
      //buf_adxstrengthbar
      if (adxval > ADXLevel && -adxminusdi > adxplusdi) {buf_adxstrengthbar[i] = -10;}
      if (adxval > ADXLevel && -adxminusdi < adxplusdi) {buf_adxstrengthbar[i] = 10;}
      //buf_line
      if (buf_adxplusdi[i] < -buf_adxminusdi[i]) {buf_linedi[i] = buf_adxdifference[i];}
      if (buf_adxplusdi[i] > -buf_adxminusdi[i]) {buf_linedi[i] = buf_adxdifference[i];}
      //buf_adxinactive
      if (buf_adxplusdi[i] < -buf_adxminusdi[i]) {buf_adxinactive[i] = buf_adxplusdi[i];}
      if (buf_adxplusdi[i] > -buf_adxminusdi[i]) {buf_adxinactive[i] = buf_adxminusdi[i];}      
	   //MACD   
	   if (macdmain > 0 && macdsignal > macdmain) {buf_macdmain[i] = 90; buf_macdsignal[i] = 70;}
	   if (macdmain > 0 && macdsignal < macdmain) {buf_macdmain[i] = 70; buf_macdsignal[i] = 90;}
      if (macdmain < 0 && macdsignal < macdmain) {buf_macdmain[i] = -90; buf_macdsignal[i] = -70;}
	   if (macdmain < 0 && macdsignal > macdmain) {buf_macdmain[i] = -70; buf_macdsignal[i] = -90;}
	  } 
//----
   return(0);
  }
void showSpread()
 {
   //Checking for unconvetional Point digits number
   if (Point == 0.00001) Poin = 0.0001; //5 digits
   else if (Point == 0.001) Poin = 0.01; //3 digits
   else Poin = Point; //Normal   
   ObjectCreate("Spread", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Spread", OBJPROP_CORNER, Corner);
   ObjectSet("Spread", OBJPROP_XDISTANCE, 10);
   ObjectSet("Spread", OBJPROP_YDISTANCE, 30);
   double spread = MarketInfo(Symbol(), MODE_SPREAD);   
   if ((Poin > Point) && (true))
   {
      divider = 10.0;
      n_digits = 1;
   }   
   ObjectSetText("Spread", "Spread: " + DoubleToStr(NormalizeDouble(spread / divider, 1), n_digits), 12, "Arial", ColorSpread);
}