//+------------------------------------------------------------------+
//|                                                           VQ.mq4 |
//|                                               Volatility Quality |
//|                                                by raff1410@o2.pl |
//+------------------------------------------------------------------+

#property  indicator_separate_window
#property  indicator_buffers 5
#property  indicator_color1  Yellow
#property  indicator_color2  Green
#property  indicator_color3  Red
#property  indicator_color4  Yellow
#property  indicator_color5  Cyan
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2

extern   bool     Crash = false;

extern   int      TimeFrame = 0;
extern   int      Length = 8;
extern   int      Method = 3;
extern   int      Smoothing = 1;
extern   int      Filter = 5;

extern   bool     RealTime = false;
extern   bool     Steady  = false;
extern   bool     Color = true;
extern   bool     Alerts = true;
extern   bool     EmailON = false;
extern   bool     SignalPrice = true;
extern   color    SignalPriceBUY = Yellow;
extern   color    SignalPriceSELL = Aqua;
extern   int      CountBars = 10000;


double   VQ[];
double   SumVQ[];
double   SumVQ_MTF[];
double   DIR[];
double   UpBuffer[];
double   DnBuffer[];
double   UpArrow[];
double   DnArrow[];

bool     TurnedUp = false;
bool     TurnedDn = false;
datetime timeprev1=0;
datetime timeprev2=0;
int p=0;
//+------------------------------------------------------------------+

int init()
{
IndicatorBuffers(8);
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(0,SumVQ);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(1,UpBuffer);
SetIndexStyle(2,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(2,DnBuffer);
SetIndexStyle(3,DRAW_ARROW);
SetIndexArrow(3,233);
SetIndexBuffer(3,UpArrow);
SetIndexStyle(4,DRAW_ARROW);
SetIndexArrow(4,234);
SetIndexBuffer(4,DnArrow);
SetIndexBuffer(5,VQ);
SetIndexBuffer(6,DIR);
SetIndexBuffer(7,SumVQ_MTF);

if (Length < 2) Length = 2;
if (Method < 0) Method = 0;
if (Method > 3) Method = 3;
if (Smoothing < 0) Smoothing = 0;
if (Filter < 0) Filter = 0;

if ((TimeFrame < Period()) && (TimeFrame != 0)) TimeFrame = Period();
switch(TimeFrame)
   {
   case 1:     string TimeFrameStr = "M1"; break;
   case 5:            TimeFrameStr = "M5"; break;
   case 15:           TimeFrameStr = "M15"; break;
   case 30:           TimeFrameStr = "M30"; break;
   case 60:           TimeFrameStr = "H1"; break;
   case 240:          TimeFrameStr = "H4"; break;
   case 1440:         TimeFrameStr = "D1"; break;
   case 10080:        TimeFrameStr = "W1"; break;
   case 43200:        TimeFrameStr = "MN1"; break;
   default:           TimeFrameStr = "";
   }

string short_name = "VQ" + TimeFrameStr + " |  " + Length + " , " + Method + " , " + Smoothing + " , " + Filter + "  | ";
IndicatorShortName(short_name);

return(0);
}

//+------------------------------------------------------------------+

int start()
{
if (Bars < 100) {IndicatorShortName("Bars less than 100"); return(0);}

if(timeprev1<iTime(NULL,TimeFrame,0)) {TurnedDn = false; TurnedUp = false; timeprev1=iTime(NULL,TimeFrame,0);}

if (!RealTime)
{
   if(timeprev2==iTime(NULL,TimeFrame,0)) return(0);
   timeprev2=iTime(NULL,TimeFrame,0);
   p=TimeFrame/Period()+1; if (p==0) p=1;
}

double TR = 0, MH = 0, ML = 0, MO = 0, MC = 0, MC1 = 0;

if (CountBars>iBars(NULL,TimeFrame) || CountBars>Bars-Length-1) CountBars=MathMin(Bars-Length-1,iBars(NULL,TimeFrame)-Length-1);
if (Crash && CountBars>0){CountBars=CountBars-10; IndicatorShortName("Crash: "+CountBars+"     ");}
if (Crash && CountBars<0) IndicatorShortName("Crash");

int i = CountBars;
SumVQ[i + 1] = Close[i + 1];
SumVQ_MTF[i + 1] = Close[i + 1];
while (i >= 0)
   {
   MH = iMA(NULL,TimeFrame,Length,0,Method,PRICE_HIGH,i);
   ML = iMA(NULL,TimeFrame,Length,0,Method,PRICE_LOW,i);
   MO = iMA(NULL,TimeFrame,Length,0,Method,PRICE_OPEN,i);
   MC = iMA(NULL,TimeFrame,Length,0,Method,PRICE_CLOSE,i);
   MC1 = iMA(NULL,TimeFrame,Length,0,Method,PRICE_CLOSE,i + Smoothing);
   if (Steady==true) {MC=iMA(NULL,TimeFrame,Length,0,Method,PRICE_MEDIAN,i); MC1=iMA(NULL,TimeFrame,Length,0,Method,PRICE_MEDIAN,i+Smoothing);}
   VQ[i] = MathAbs(((MC - MC1) / MathMax(MH - ML,MathMax(MH - MC1,MC1 - ML)) + (MC - MO) / (MH - ML)) * 0.5) * ((MC - MC1 + (MC - MO)) * 0.5);
   SumVQ[i] = SumVQ[i + 1] + VQ[i];
   if (Filter > 0) if (MathAbs(SumVQ[i] - SumVQ[i + 1]) < Filter * Point) SumVQ[i] = SumVQ[i + 1];
   if (TimeFrame > Period()) SumVQ_MTF[i] = SumVQ[i];
   i--;
   }

   if (TimeFrame>Period())
   {
     datetime TimeArray1[]; 
     ArrayCopySeries(TimeArray1,MODE_TIME,Symbol(),TimeFrame); 
     int limit=CountBars+TimeFrame/Period();
     for(i=0, int y=0;i<limit;i++) {if (Time[i]<TimeArray1[y]) y++;  SumVQ[i]=SumVQ_MTF[y];}
   }


for (i = CountBars; i >= 0; i--)
   {
   DIR[i] = DIR[i + 1];
   if (SumVQ[i] - SumVQ[i + 1] > 0) DIR[i] = 1;
   if (SumVQ[i + 1] - SumVQ[i] > 0) DIR[i] = -1;
   if (Color == true)
      {
      if (DIR[i] > 0)
         {
         UpBuffer[i] = SumVQ[i];
         if (DIR[i + 1] < 0) UpBuffer[i + 1] = SumVQ[i + 1];
         DnBuffer[i] = EMPTY_VALUE;
         }
         else
         {
         if (DIR[i] < 0)
            {
            DnBuffer[i] = SumVQ[i];
            if (DIR[i + 1] > 0) DnBuffer[i + 1] = SumVQ[i + 1];
            UpBuffer[i] = EMPTY_VALUE;
            }
         }
      }
   if (Alerts == true)
      {
      UpArrow[i] = EMPTY_VALUE; DnArrow[i] = EMPTY_VALUE;
      if ((DIR[i] == 1) && (DIR[i + 1] == -1)) UpArrow[i] = SumVQ[i + 1] - (Ask - Bid);
      if ((DIR[i] == -1) && (DIR[i + 1] == 1)) DnArrow[i] = SumVQ[i + 1] + (Ask - Bid);
      }
   }
   
   
if (Alerts == true)
{
   string AlertTXT;
   if (UpArrow[0+p]!=EMPTY_VALUE && TurnedUp==false)
      {
        AlertTXT="VQ BUY:  "+Symbol()+" - "+Period()+"  at  "+ DoubleToStr(Close[0],Digits)+ "  -  "+ TimeToStr(CurTime(),TIME_SECONDS);
        Alert(AlertTXT); if (EmailON) SendMail(AlertTXT,AlertTXT);
        if (SignalPrice == true)
        {
          ObjectCreate("BUY SIGNAL: " + DoubleToStr(Time[0],0),OBJ_ARROW,0,Time[0],Close[0]);
          ObjectSet("BUY SIGNAL: " + DoubleToStr(Time[0],0),OBJPROP_ARROWCODE,5);
          ObjectSet("BUY SIGNAL: " + DoubleToStr(Time[0],0),OBJPROP_COLOR,SignalPriceBUY);
        }
        TurnedDn = false; TurnedUp = true;
      }
   if (DnArrow[0+p]!=EMPTY_VALUE && TurnedDn==false)
      {
        AlertTXT="VQ SELL:  "+Symbol()+" - "+Period()+"  at  "+ DoubleToStr(Close[0],Digits)+ "  -  "+ TimeToStr(CurTime(),TIME_SECONDS);
        Alert(AlertTXT); if (EmailON) SendMail(AlertTXT,AlertTXT);
        if (SignalPrice == true)
        {
          ObjectCreate("SELL SIGNAL: " + DoubleToStr(Time[0],0),OBJ_ARROW,0,Time[0],Close[0]);
          ObjectSet("SELL SIGNAL: " + DoubleToStr(Time[0],0),OBJPROP_ARROWCODE,5);
          ObjectSet("SELL SIGNAL: " + DoubleToStr(Time[0],0),OBJPROP_COLOR,SignalPriceSELL);
        }
        TurnedUp = false; TurnedDn = true;
   }
}
         
         
return(0);
}