//+------------------------------------------------------------------+
//| candleTest5.mq4 |
//| Ruokh |
//+------------------------------------------------------------------+
#property copyright "Ruokh"
#property version "1.00"
#property description "LambertCandles:"
#property description "This indicator draws, Bullish Inside, Trend and Engulfing Candles"
#property description "or Bearish, Inside, Trend and Engulfing Candles"
#property strict
#property indicator_chart_window
#property indicator_buffers 8

double BullishInsideCandleWickHigh[];
double BullishInsideCandleWickLow [];
double BullishInsideCandleBodyHigh[];
double BullishInsideCandleBodyLow [];
double BearishInsideCandleWickHigh[];
double BearishInsideCandleWickLow [];
double BearishInsideCandleBodyHigh[];
double BearishInsideCandleBodyLow [];

//bool BullishInsideCandleMarker[];
//bool BearishInsideCandleMarker[];

extern color BullishInsideCandle = clrPaleGreen;
extern color BearishInsideCandle = clrLightPink;


int input WickWidth = 1;
int input BodyWidth = 2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
//IndicatorShortName ("LambertCandles");

//--- indicator buffers mapping
SetIndexBuffer(0,BullishInsideCandleWickHigh);
SetIndexStyle (0,DRAW_HISTOGRAM,STYLE_SOLID,WickWidth,BullishInsideCandle);
SetIndexLabel (0,"BullishInsideCandleWickHigh");

SetIndexBuffer(1,BullishInsideCandleWickLow);
SetIndexStyle (1,DRAW_HISTOGRAM,STYLE_SOLID,WickWidth,BullishInsideCandle);
SetIndexLabel (1,"BullishInsideCandleWickLow");

SetIndexBuffer(2,BullishInsideCandleBodyHigh);
SetIndexStyle (2,DRAW_HISTOGRAM,STYLE_SOLID,BodyWidth,BullishInsideCandle);
SetIndexLabel (2,"BullishInsideCandleBodyHigh");

SetIndexBuffer(3,BullishInsideCandleBodyLow);
SetIndexStyle (3,DRAW_HISTOGRAM,STYLE_SOLID,BodyWidth,BullishInsideCandle);
SetIndexLabel (3,"BullishInsideCandleBodyLow");



SetIndexBuffer(4,BearishInsideCandleWickHigh);
SetIndexStyle (4,DRAW_HISTOGRAM,STYLE_SOLID,WickWidth,BearishInsideCandle);
SetIndexLabel (4,"BearishInsideCandleWickHigh");

SetIndexBuffer(5,BearishInsideCandleWickLow);
SetIndexStyle (5,DRAW_HISTOGRAM,STYLE_SOLID,WickWidth,BearishInsideCandle);
SetIndexLabel (5,"BearishInsideCandleWickLow");

SetIndexBuffer(6,BearishInsideCandleBodyHigh);
SetIndexStyle (6,DRAW_HISTOGRAM,STYLE_SOLID,BodyWidth,BearishInsideCandle);
SetIndexLabel (6,"BearishInsideCandleBodyHigh");

SetIndexBuffer(7,BearishInsideCandleBodyLow);
SetIndexStyle (7,DRAW_HISTOGRAM,STYLE_SOLID,BodyWidth,BearishInsideCandle);
SetIndexLabel (7,"BearishInsideCandleBodyLow");



//---
return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function |
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

//for (int i = Bars - 2; i>=0; i--)//this will run the whole history(-2 bars) on every tick (every tick triggers the OnCalculate)
if(prev_calculated<0)return(-1);//history error
int lookback = 1;//if you need to read the prev bar first, start 1 bar late
int limit = MathMax(Bars-1-lookback-prev_calculated,0);//first loading prev_calculated is 0, then prev_calculated is equal to bars, so mathmax(bars-2-0,0) then mathmax(bars-2-bars,0)
for(int i=limit; i>=0; i--)//first run will be from Bars-1-lookback -> 0, after will be from 0 to 0
{
   //Print("i=",i);//this will show the value of i used, on loading you'll see the countdown from Bars-2 to 0, after it'll just be the 0 bar
   double hi = High[i];
   double lo = Low[i];
   double previousHi = High[i+1];
   double previousLo = Low[i+1];
   double bodyHigh = MathMax (Close[i], Open[i]);
   double bodyLow = MathMin (Close[i], Open[i]);
   
   if(hi <= previousHi && lo >= previousLo)//check candle is engulfed first
   {
      if(Close[i+1]>Open[i+1]){//if prev candle was bearish
         BullishInsideCandleWickHigh[i] = hi;
         BullishInsideCandleWickLow [i] = lo;
         BullishInsideCandleBodyHigh[i] = bodyHigh;
         BullishInsideCandleBodyLow [i] = bodyLow;
      }
      else if(Close[i+1]<Open[i+1]){//if prev candle was bullish
         BearishInsideCandleWickHigh[i] = hi;
         BearishInsideCandleWickLow [i] = lo;
         BearishInsideCandleBodyHigh[i] = bodyHigh;
         BearishInsideCandleBodyLow [i] = bodyLow;
      }
   }
   else{//no more engulfing, undraw anything drawn
      BullishInsideCandleWickHigh[i] = EMPTY_VALUE;
      BullishInsideCandleWickLow [i] = EMPTY_VALUE;
      BullishInsideCandleBodyHigh[i] = EMPTY_VALUE;
      BullishInsideCandleBodyLow [i] = EMPTY_VALUE;

      BearishInsideCandleWickHigh[i] = EMPTY_VALUE;
      BearishInsideCandleWickLow [i] = EMPTY_VALUE;
      BearishInsideCandleBodyHigh[i] = EMPTY_VALUE;
      BearishInsideCandleBodyLow [i] = EMPTY_VALUE;
   }

}//end main i loop


return(rates_total);
}
//+------------------------------------------------------------------+