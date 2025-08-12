#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_width1 3
#property indicator_color2 Red
#property indicator_width2 3

extern int     Direction = 4;
extern int     TrendInd  = 4;
extern int     Accuracy  = 2;
extern int     Accuracy2 = 2;
extern int     Locating  = 55;
extern double  UpperLine = -80;
extern double  LowerLine = -20;
extern double  Distance  = 0.3;
extern int     Right     = 0;
extern int     Left      = 0;
extern bool    Nadpis    = true;

double Instrument[];
double Instruments[];
double Stoping[];

int init()
{

if (Nadpis)
  {
   ObjectCreate("signal",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("signal",OBJPROP_XDISTANCE,50);
   ObjectSet("signal",OBJPROP_YDISTANCE,50);
   ObjectSetText("signal","PROFIT 99%",15,"Tahoma",White);
   }

   IndicatorBuffers(3);

   SetIndexBuffer(0,Instrument);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 108);
   
   SetIndexBuffer(1,Instruments);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 108);
   
   SetIndexBuffer(2,Stoping);

   return(0);
}

int deinit()
{
   DeleteLabels();
   ObjectDelete("signal");
   
   return(0);
}

int start()
{
   int i,counted_bars = IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit = MathMin(Bars-counted_bars,Bars-1);

   for(i=limit; i>=0; i--)
   {
      double ADXMain   = iADX(NULL,0,Direction,PRICE_CLOSE,MODE_MAIN,i+1); double DMIPlus0  = iADX(NULL,0,Direction,Left,MODE_PLUSDI,i); double DMIPlus1  = iADX(NULL,0,Direction,Right,MODE_PLUSDI,i+1);
      double DMIMinus0 = iADX(NULL,0,Direction,Right,MODE_MINUSDI,i); double DMIMinus1 = iADX(NULL,0,Direction,Left,MODE_MINUSDI,i+1); double DeMark    = iDeMarker(NULL,0,TrendInd,i+1);
      double MFIBuf    = iMFI(NULL,0,Accuracy,i+1); double WPRBuf1   = iWPR(NULL,0,Accuracy2,i+1); double WPRBuf2   = iWPR(NULL,0,Accuracy2,i+2);

      if      ((DMIPlus1<DMIMinus1 && DMIPlus0>DMIMinus0) && DeMark == 0 && MFIBuf ==   0 && (WPRBuf2 > UpperLine  || WPRBuf1 > UpperLine)  && ADXMain > Locating) Stoping[i] =  1;
      else if ((DMIPlus1>DMIMinus1 && DMIPlus0<DMIMinus0) && DeMark == 1 && MFIBuf == 100 && (WPRBuf2 < LowerLine || WPRBuf1 < LowerLine) && ADXMain > Locating) Stoping[i] = -1;
      else Stoping[i] = EMPTY_VALUE;

      double gap  = iATR(NULL,0,100,i); double high = High[i] + gap * Distance; double low  = Low[i]  - gap * Distance;

      Instrument[i]  = EMPTY_VALUE; Instruments[i] = EMPTY_VALUE;

      if      (Stoping[i] ==  1)
      {
         Instrument[i]  = low;
      }
      else if (Stoping[i] == -1)
      {
         Instruments[i] = high;
      }
   }

   return(0);
}

string TimeFrameToString(int tf)
{
   string tfs;
   switch(tf)
   {
      case PERIOD_M1:     tfs = "M1"; break;
      case PERIOD_M5:     tfs = "M5"; break;
      case PERIOD_M15:    tfs = "M15"; break;
      case PERIOD_M30:    tfs = "M30"; break;
      case PERIOD_H1:     tfs = "H1"; break;
      case PERIOD_H4:     tfs = "H4"; break;
      case PERIOD_D1:     tfs = "D1"; break;
      case PERIOD_W1:     tfs = "W1"; break;
      case PERIOD_MN1:    tfs = "MN1";
      default: tfs = "" + DoubleToStr(tf,0);
   }
   return(tfs);
}

void DeleteLabels()
{

}