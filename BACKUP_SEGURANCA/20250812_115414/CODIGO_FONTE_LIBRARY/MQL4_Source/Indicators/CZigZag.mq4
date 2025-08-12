//+------------------------------------------------------------------+
//|                                                      CZigZag.mq4 |
//|                                         Copyright © 2006, Candid |
//|                                                   likh@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Candid"
#property link      "likh@yandex.ru"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Navy

//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=5;
//extern int ExtBackstep=3;

int    shift;
double res=0;
int i;
double CurMax,CurMin;
int CurMaxPos,CurMinPos;
int CurMaxBar,CurMinBar;
double hPoint;
double mhPoint;
double EDev;
int MaxDist,MinDist;
bool FirstRun;
bool AfterMax,AfterMin;
int BarTime;

//---- indicator buffers
double ZigZag[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
//---- indicators
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ZigZag);
   SetIndexEmptyValue(0,0.0);
//---- indicator short name
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+")");
   
   FirstRun = true;
//----
  return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
//----
   
//----
  return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int counted_bars=IndicatorCounted();
  int fBar;
  
  if (FirstRun) {
    hPoint = 0.5*Point;
    mhPoint = -hPoint;
    EDev = (ExtDeviation+0.5)*Point;
    AfterMax = true;
    AfterMin = true;
    fBar = Bars-1;
    CurMax = High[fBar];
    CurMaxBar = 1;
    CurMin = Low[fBar];
    CurMinBar = 1;
    MaxDist = 0;
    MinDist = 0;
    BarTime = 0;
    FirstRun = false;
  }


//----
  fBar = Bars-counted_bars-1;
  if (fBar > Bars-2) fBar = Bars-2;
  for(shift=fBar; shift>=0; shift--) {
    if (BarTime!=Time[shift]) {
      BarTime=Time[shift];
      if (res > hPoint ) {
        MaxDist = Bars-CurMaxBar-shift+1;
        MinDist = Bars-CurMinBar-shift+1;
        if ((MaxDist>ExtDepth && MinDist>ExtDepth) || res > EDev) {
          if (AfterMax) {
            AfterMax = false;
            AfterMin = true;
            CurMaxBar = CurMinBar+1;
            CurMaxPos = Bars-CurMaxBar;
            CurMax = High[CurMaxPos];
            for (i=CurMaxPos-1;i>=shift;i--) {
              if (High[i] > CurMax+hPoint) {
                CurMaxBar = Bars-i;
                CurMax = High[i];
              }
            }  //  for (i=CurMaxPos-1;i>=shift;i--)
            ZigZag[Bars-CurMaxBar] = CurMax;
          } else {  //  if (AfterMax)
            AfterMin = false;
            AfterMax = true;
            CurMinBar = CurMaxBar+1;
            CurMinPos = Bars-CurMinBar;
            CurMin = Low[CurMinPos];
            for (i=CurMinPos-1;i>=shift;i--) {
              if (Low[i] < CurMin-hPoint) {
                CurMinBar = Bars-i;
                CurMin = Low[i];
              }
            }  //  for (i=CurMinPos-1;i>=shift;i--)
            ZigZag[Bars-CurMinBar] = CurMin;
          }  //  else if (AfterMax)    
        }  //  if ((MaxDist>ExtDepth && MinDist>ExtDepth) || res > EDev)
      }  //  if (res > hPoint )
    }  //  if (BarTime!=Time[0])
    if (AfterMax) {
      res = Low[shift]-CurMin;
      if (res < mhPoint) {
        ZigZag[Bars-CurMinBar] = 0;
        CurMin = Low[shift];
        CurMinBar = Bars-shift; 
        ZigZag[Bars-CurMinBar] = CurMin;
      }  //  if (res < mhPoint)
    }  //  if (AfterMax) 
    if (AfterMin) {
      res = CurMax-High[shift];
      if (res < mhPoint) {
        ZigZag[Bars-CurMaxBar] = 0;
        CurMax = High[shift];
        CurMaxBar = Bars-shift; 
        ZigZag[Bars-CurMaxBar] = CurMax;
      }  //  if (res < mhPoint)
    }  //  if (AfterMin) 
  }  //  for(shift=fBar; shift>=0; shift--)
//----
  return(0);
}
//+------------------------------------------------------------------+