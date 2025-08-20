//+------------------------------------------------------------------+
//|                MA Cross Arrows.mq4                               |
//|                Copyright © 2006  Scorpion@fxfisherman.com        |
//+------------------------------------------------------------------+
#property copyright "FxFisherman.com"
#property link      "http://www.fxfisherman.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 White
#property indicator_color3 Red

extern int Crossed_Pips = 15;
extern int MA_Period = 34;
extern int MA_Type = 0;
extern int Shift_Bars=0;
extern int Bars_Count= 1000;

//---- buffers
double v1[];
double v2[];
double v3[];
  
int init()
  {

   IndicatorBuffers(3);
   SetIndexArrow(0,217);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexDrawBegin(0,-1);
   SetIndexBuffer(0, v1);
   SetIndexLabel(0,"Buy");
   
   SetIndexArrow(1,218);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexDrawBegin(1,-1);
   SetIndexBuffer(1, v2);
   SetIndexLabel(1,"Sell");
   
 
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   SetIndexDrawBegin(2,-1);
   SetIndexBuffer(2, v3);
   SetIndexLabel(2,"MA");
   
   watermark();
 
   return(0);
  }

int start()
 {
  double ma;
  int previous;
  int i;
  int shift;
  bool crossed_up, crossed_down;
  int counted_bars = IndicatorCounted();
  if (counted_bars > 0) counted_bars--;
  if (Bars_Count > 0 && Bars_Count <= Bars)
  {
    i = Bars_Count - counted_bars;
  }else{
    i = Bars - counted_bars;
  }
  
  while(i>=0)
   {
    shift = i + Shift_Bars;
    ma = iMA(Symbol(), Period(), MA_Period, 0, MA_Type, PRICE_CLOSE, shift);
    Comment(ma); 
    crossed_up = High[shift] >= (ma + (Crossed_Pips * Point));
    crossed_down = Low[shift] <= (ma - (Crossed_Pips * Point));
    
    v3[i] = ma;
    if (crossed_up && previous != 1) {
      v1[i] = ma + (Crossed_Pips * Point);
      previous = 1;
    }else if(crossed_down && previous != 2){
      v2[i] = ma - (Crossed_Pips * Point);
      previous = 2;
    }
    
    i--;
   }   
  return(0);
 }
 
//+------------------------------------------------------------------+

void watermark()
  {
   ObjectCreate("fxfisherman", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("fxfisherman", "fxfisherman.com", 11, "Lucida Handwriting", RoyalBlue);
   ObjectSet("fxfisherman", OBJPROP_CORNER, 2);
   ObjectSet("fxfisherman", OBJPROP_XDISTANCE, 5);
   ObjectSet("fxfisherman", OBJPROP_YDISTANCE, 10);
   return(0);
  }