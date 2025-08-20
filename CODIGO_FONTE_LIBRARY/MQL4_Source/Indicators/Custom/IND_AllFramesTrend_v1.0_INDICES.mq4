#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 3
#property indicator_width2 3

//extern int period = 5;
extern int method = 3;
extern int price = 5;
extern int M1 = 0;
extern int M1_per = 5;
extern int M5 = 1;
extern int M5_per = 5;
extern int M15 = 1;
extern int M15_per = 5;
extern int M30 = 1;
extern int M30_per = 5;
extern int H1 = 0;
extern int H1_per = 5;
extern int H4 = 0;
extern int H4_per = 5;
extern int D1 = 0;
extern int D1_per = 5;

double buffer0[];
double buffer1[];
double current;
int ExtCountedBars = 0;

int init()
{
  IndicatorShortName("AllFramesTrend");
  SetIndexStyle(0, DRAW_LINE);
  SetIndexStyle(1, DRAW_LINE);
  SetIndexDrawBegin(0, 1);
  SetIndexDrawBegin(1, 1);
  SetIndexBuffer(0, buffer0);
  SetIndexBuffer(1, buffer1);
  return(0);
}

int start()
{
  ExtCountedBars = IndicatorCounted();
  if (ExtCountedBars < 0) return(-1);
  if (ExtCountedBars > 0) ExtCountedBars--;
  
  int pos = Bars - 1;
  if(ExtCountedBars > 2) pos = Bars - ExtCountedBars - 1;
  double M1_cur, M1_prev, M5_cur, M5_prev, M15_cur, M15_prev, M30_cur, M30_prev, H1_cur, H1_prev, H4_cur, H4_prev, D1_cur, D1_prev;
  int shift;
  
  while(pos >= 0)
  {
    if(M1 == 1)
    {
      shift = iBarShift(NULL, PERIOD_M1, Time[pos])+1;
      M1_cur = iMA(NULL, PERIOD_M1, M1_per, 0, method, price, shift);
      M1_prev = iMA(NULL, PERIOD_M1, M1_per, 0, method, price, shift+1);
    }
    if(M5 == 1)
    {
      shift = iBarShift(NULL, PERIOD_M5, Time[pos])+1;
      M5_cur = iMA(NULL, PERIOD_M5, M5_per, 0, method, price, shift);
      M5_prev = iMA(NULL, PERIOD_M5, M5_per, 0, method, price, shift+1);
    }
    if(M15 == 1)
    {
      shift = iBarShift(NULL, PERIOD_M15, Time[pos])+1;
      M15_cur = iMA(NULL, PERIOD_M15, M15_per, 0, method, price, shift);
      M15_prev = iMA(NULL, PERIOD_M15, M15_per, 0, method, price, shift+1);
    }
    if(M30 == 1)
    {
      shift = iBarShift(NULL, PERIOD_M30, Time[pos])+1;
      M30_cur = iMA(NULL, PERIOD_M30, M30_per, 0, method, price, shift);
      M30_prev = iMA(NULL, PERIOD_M30, M30_per, 0, method, price, shift+1);
    }
    if(H1 == 1)
    {
      shift = iBarShift(NULL, PERIOD_H1, Time[pos])+1;
      H1_cur = iMA(NULL, PERIOD_H1, H1_per, 0, method, price, shift);
      H1_prev = iMA(NULL, PERIOD_H1, H1_per, 0, method, price, shift+1);
    }
    if(H4 == 1)
    {
      shift = iBarShift(NULL, PERIOD_H4, Time[pos])+1;
      H4_cur = iMA(NULL, PERIOD_H4, H4_per, 0, method, price, shift);
      H4_prev = iMA(NULL, PERIOD_H4, H4_per, 0, method, price, shift+1);
    }
    if(D1 == 1)
    {
      shift = iBarShift(NULL, PERIOD_D1, Time[pos])+1;
      D1_cur = iMA(NULL, PERIOD_D1, D1_per, 0, method, price, shift);
      D1_prev = iMA(NULL, PERIOD_D1, D1_per, 0, method, price, shift+1);      
    }
    
    shift = iBarShift(NULL, 0, Time[pos]);
    if(Period() == 1) current = iMA(NULL, 0, M1_per, 0, method, price, shift);
    if(Period() == 5) current = iMA(NULL, 0, M5_per, 0, method, price, shift);
    if(Period() == 15) current = iMA(NULL, 0, M15_per, 0, method, price, shift);
    if(Period() == 30) current = iMA(NULL, 0, M30_per, 0, method, price, shift);
    if(Period() == 60) current = iMA(NULL, 0, H1_per, 0, method, price, shift);
    if(Period() == 240) current = iMA(NULL, 0, H4_per, 0, method, price, shift);
    if(Period() == 1440) current = iMA(NULL, 0, D1_per, 0, method, price, shift);
    //current = iMA(NULL, 0, "M" + Period() + "_per", 0, method, price, shift);
    
    if(((M1_cur > M1_prev) || M1 == 0) && ((M5_cur > M5_prev) || M5 == 0) && ((M15_cur > M15_prev) || M15 == 0) && ((M30_cur > M30_prev) || M30 == 0) && ((H1_cur > H1_prev) || H1 == 0) && ((H4_cur > H4_prev) || H4 == 0) && ((D1_cur > D1_prev) || D1 == 0)) buffer0[pos] = current;
    if(((M1_cur < M1_prev) || M1 == 0) && ((M5_cur < M5_prev) || M5 == 0) && ((M15_cur < M15_prev) || M15 == 0) && ((M30_cur < M30_prev) || M30 == 0) && ((H1_cur < H1_prev) || H1 == 0) && ((H4_cur < H4_prev) || H4 == 0) && ((D1_cur < D1_prev) || D1 == 0)) buffer1[pos] = current;
    pos--;
  }
  return(0);
}