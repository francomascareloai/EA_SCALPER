//+-----------------------------------------------------------+
//| MT4 CUSTOM INDICATOR                   123PatternsV6.MQ4  |
//| copy to [experts\\indicators] and recompile or restart MT4 |
//+-----------------------------------------------------------+
//| Free software for personal non-commercial use only.       |
//| No guarantees are expressed or implied.                   |
//| Feedback welcome via Forex Factory private message.       |
//+-----------------------------------------------------------+
#property copyright "Copyright © 2010 Robert Dee"
#property link      "www.forexfactory.com/robdee"

#define INDICATOR_VERSION    20101105       // VERSION 6
#define INDICATOR_NAME       "123PatternsV6"
#define RELEASE_LEVEL        "Public"
#define MT4_BUILD            226

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1  DodgerBlue   // UpperLine
#property indicator_color2  OrangeRed    // LowerLine
#property indicator_color3  LimeGreen    // Target1
#property indicator_color4  LimeGreen    // Target2
#property indicator_color5  DodgerBlue   // BuyArrow
#property indicator_color6  OrangeRed    // SellArrow
#property indicator_color7  DodgerBlue   // BullDot
#property indicator_color8  OrangeRed    // BearDot
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  3  // BuyArrow
#property indicator_width6  3  // SellArrow
#property indicator_width7  3  // BullDot
#property indicator_width8  3  // BearDot

extern string Notes           = "15pip RangeBars Basic Setup";
extern int    ZigZagDepth     = 12;
extern double RetraceDepthMin = 0.4;
extern double RetraceDepthMax = 1.0;
extern bool   ShowAllLines    = True;
extern bool   ShowAllBreaks   = True;
extern bool   ShowTargets     = False;
extern double Target1Multiply = 1.5;
extern double Target2Multiply = 3.0;
extern bool   HideTransitions = True;

// indicator buffers
double UpperLine[];
double LowerLine[];
double Target1[];
double Target2[];
double BuyArrow[];
double SellArrow[];
double BullDot[];
double BearDot[];

double   firsthigh, firstlow, lasthigh, lastlow, prevhigh, prevlow, signalprice, brokenline;
datetime firsthightime, firstlowtime, lasthightime, lastlowtime, prevhightime, prevlowtime, signaltime;
datetime redrawtime;  // remember when the indicator was redrawn

int     signal;
#define NOSIG   0
#define BUYSIG  1
#define SELLSIG 2

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{

int i;
for(i=0; i<=7; i++) SetIndexEmptyValue(i,EMPTY_VALUE);
if(ShowAllLines == True) SetIndexStyle(0,DRAW_LINE); else SetIndexStyle(0,DRAW_NONE);
if(ShowAllLines == True) SetIndexStyle(1,DRAW_LINE); else SetIndexStyle(1,DRAW_NONE);
if(ShowTargets == True) SetIndexStyle(2,DRAW_LINE); else SetIndexStyle(2,DRAW_NONE);
if(ShowTargets == True) SetIndexStyle(3,DRAW_LINE); else SetIndexStyle(3,DRAW_NONE);


SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,SYMBOL_ARROWUP);
SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,SYMBOL_ARROWDOWN);
SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159); // BullDot (WingDings character)
SetIndexStyle(7,DRAW_ARROW); SetIndexArrow(7,159); // BearDot (WingDings character)
SetIndexBuffer(0,UpperLine);
SetIndexBuffer(1,LowerLine);
SetIndexBuffer(2,Target1);
SetIndexBuffer(3,Target2);
SetIndexBuffer(4,BuyArrow);
SetIndexBuffer(5,SellArrow);
SetIndexBuffer(6,BullDot);
SetIndexBuffer(7,BearDot);
IndicatorShortName(INDICATOR_NAME);
IndicatorDigits(Digits);
if(ShowAllLines == True) SetIndexLabel(0,"UpperLine"); else SetIndexLabel(0,"");
if(ShowAllLines == True) SetIndexLabel(1,"LowerLine"); else SetIndexLabel(1,"");
if(ShowTargets == True) SetIndexLabel(2,"Target1"); else SetIndexLabel(2,"");
if(ShowTargets == True) SetIndexLabel(3,"Target2"); else SetIndexLabel(3,"");
SetIndexLabel(4,"BuyArrow");
SetIndexLabel(5,"SellArrow");
SetIndexLabel(6,"");
SetIndexLabel(7,"");
// cleanup display buffers

for(i=0; i<Bars; i++)
   {
   UpperLine[i] = EMPTY_VALUE;
   LowerLine[i] = EMPTY_VALUE;
   Target1[i] = EMPTY_VALUE;
   Target2[i] = EMPTY_VALUE;
   BuyArrow[i] = EMPTY_VALUE;
   SellArrow[i] = EMPTY_VALUE;
   BullDot[i] = EMPTY_VALUE;
   BearDot[i] = EMPTY_VALUE;
   }
// message to the experts log (shows in reverse order)
if(IsTesting() == False)
   {
   Print("Copyright © 2010 Robert Dee, All Rights Reserved");   
   Print("Free software for personal non-commercial use only. No guarantees are expressed or implied.");
   Print(INDICATOR_NAME+" indicator version "+INDICATOR_VERSION+" for "+RELEASE_LEVEL+" release, compiled with MetaTrader4 Build "+MT4_BUILD);
   }
Print("Init OK");
   
return(0);   
} // end of init()

//+------------------------------------------------------------------+
//| Status Message prints below OHLC upper left of chart window
//+------------------------------------------------------------------+
void StatusMessage()
   {
   if(IsTesting() == True) return; // do no more
   double multi = MathPow(10,Digits);
   string msg = INDICATOR_NAME+"  "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"  ";
   if(signal == NOSIG) msg = msg + "NOSIG  ";
   if(signal == BUYSIG) msg = msg + "BUYSIG  "+ TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
   if(signal == SELLSIG) msg = msg + "SELLSIG  "+ TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
   msg = msg + "ZigZagDepth="+ZigZagDepth+"  ";
   //msg = msg + "RetraceDepth="+DoubleToStr(RetraceDepthMin,2)+" "+DoubleToStr(RetraceDepthMax,2)+"  ";
   //msg = msg + "Target1="+DoubleToStr(Target1Multiply,2)+"  ";
   //msg = msg + "Target2="+DoubleToStr(Target2Multiply,2)+"  ";
   msg = msg + "Spread="+DoubleToStr((Ask-Bid)*multi,0)+"  ";
   msg = msg + "Range="+DoubleToStr((High[0]-Low[0])*multi,0)+"  ";
   Comment(msg);
   }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
// REDRAW ONLY ONE TIME PER CANDLE
if(redrawtime == Time[0]) {StatusMessage(); return(0);} // if already redrawn on this candle then do no more
else redrawtime = Time[0];                              // remember when the indicator was redrawn

double   zigzag, range, retracedepth, one, two, three;
datetime onetime, twotime, threetime;
int      shift = Bars-1;
while(shift >= 0)
   {
   // UPPERLINES and LOWERLINES based on ZIGZAG
   UpperLine[shift] = UpperLine[shift+1];
   LowerLine[shift] = LowerLine[shift+1];
   Target1[shift] = Target1[shift+1];
   Target2[shift] = Target2[shift+1];
   //BuyArrow[shift] = EMPTY_VALUE;
   //SellArrow[shift] = EMPTY_VALUE;
   BullDot[shift] = EMPTY_VALUE;
   BearDot[shift] = EMPTY_VALUE;
   zigzag = iCustom(NULL,0,"ZigZag",ZigZagDepth,5,3,0,shift);
   if(zigzag == High[shift])
      {
      UpperLine[shift] = High[shift];
      firsthigh = prevhigh; firsthightime = prevhightime;
      prevhigh = lasthigh;  prevhightime = lasthightime;
      lasthigh = zigzag;    lasthightime = Time[shift];
      }
   if(zigzag == Low[shift])
      {
      LowerLine[shift] = Low[shift];
      firstlow = prevlow; firstlowtime = prevlowtime;
      prevlow = lastlow;  prevlowtime = lastlowtime;
      lastlow = zigzag;   lastlowtime = Time[shift];
      }

   ///////////////////////////
   // BULLISH BREAK ABOVE #2
   one = prevlow; onetime = prevlowtime;
   two = lasthigh; twotime = lasthightime; if(twotime == Time[shift]){two = prevhigh; twotime = prevhightime;}
   three = lastlow; threetime = lastlowtime;
   if(one - two != 0) retracedepth = (three - two) / (one - two);  // retrace depth
   // signal rules
   if(shift > 0)
   if(retracedepth > RetraceDepthMin)                  // minimum retrace depth for 123 pattern
   if(retracedepth < RetraceDepthMax)                  // maximum retrace depth for 123 pattern
   if(brokenline != UpperLine[shift])                  // if this line has not already been broken
   if(Low[shift] < UpperLine[shift])                   // low of rangebar is below the line
   if(Close[shift] > UpperLine[shift])                 // close of rangebar body is above the line (break)
      {
      range = MathAbs(two - three);                    // range is the distance between two and three
      Target1[shift] = two+(range*Target1Multiply);
      Target2[shift] = two+(range*Target2Multiply);
      BuyArrow[shift] = Low[shift]-(High[shift]-Low[shift])/3;
      BullDot[iBarShift(NULL,0,onetime)] = one;        // ONE
      BullDot[iBarShift(NULL,0,twotime)] = two;        // TWO
      BullDot[iBarShift(NULL,0,threetime)] = three;    // THREE
      signal = BUYSIG;
      signaltime = Time[shift];
      signalprice = BuyArrow[shift];
      brokenline = UpperLine[shift];
      }

   /////////////////////////////////////////////
   // BULLISH BREAK OF UPPERLINE (NOT 123 SETUP)
   // signal rules
   if(shift > 0)
   if(ShowAllBreaks == True)
   if(brokenline != UpperLine[shift])                  // if this line has not already been broken
   if(Low[shift] < UpperLine[shift])                   // low of rangebar is below the line
   if(Close[shift] > UpperLine[shift])                 // close of rangebar body is above the line (break)
      {
      range = UpperLine[shift]-LowerLine[shift];
      Target1[shift] = UpperLine[shift]+(range*Target1Multiply);
      Target2[shift] = UpperLine[shift]+(range*Target2Multiply);
      BuyArrow[shift] = Low[shift]-(High[shift]-Low[shift])/3;
      signal = BUYSIG;
      signaltime = Time[shift];
      signalprice = BuyArrow[shift];
      brokenline = UpperLine[shift];
      }

   ///////////////////////////
   // BEARISH BREAK BELOW #2
   one = prevhigh; onetime = prevhightime;
   two = lastlow; twotime = lastlowtime; if(twotime == Time[shift]){two = prevlow; twotime = prevlowtime;}
   three = lasthigh; threetime = lasthightime;
   if(one - two != 0) retracedepth = (three - two) / (one - two);  // retrace depth
   // signal rules
   if(shift > 0)
   if(retracedepth > RetraceDepthMin)                  // minimum retrace depth for 123 pattern
   if(retracedepth < RetraceDepthMax)                  // maximum retrace depth for 123 pattern
   if(brokenline != LowerLine[shift])                  // if this line has not already been broken
   if(High[shift] > LowerLine[shift])                  // high of rangebar is above the line
   if(Close[shift] < LowerLine[shift])                 // close of rangebar is below the line (break)
      {
      range = MathAbs(two - three);                    // range is the distance between two and three
      Target1[shift] = two-(range*Target1Multiply);
      Target2[shift] = two-(range*Target2Multiply);
      SellArrow[shift] = High[shift]+(High[shift]-Low[shift])/3;
      BearDot[iBarShift(NULL,0,onetime)] = one;        // ONE
      BearDot[iBarShift(NULL,0,twotime)] = two;        // TWO
      BearDot[iBarShift(NULL,0,threetime)] = three;    // THREE
      signal = SELLSIG;
      signaltime = Time[shift];
      signalprice = SellArrow[shift];
      brokenline = LowerLine[shift];
      }

   /////////////////////////////////////////////
   // BEARISH BREAK OF LOWERLINE (NOT 123 SETUP)
   // signal rules
   if(shift > 0)
   if(ShowAllBreaks == True)
   if(brokenline != LowerLine[shift])                  // if this line has not already been broken
   if(High[shift] > LowerLine[shift])                  // high of rangebar is above the line
   if(Close[shift] < LowerLine[shift])                 // close of rangebar is below the line (break)
      {
      range = UpperLine[shift]-LowerLine[shift];
      Target1[shift] = LowerLine[shift]-(range*Target1Multiply);
      Target2[shift] = LowerLine[shift]-(range*Target2Multiply);
      SellArrow[shift] = High[shift]+(High[shift]-Low[shift])/3; 
      signal = SELLSIG;
      signaltime = Time[shift];
      signalprice = SellArrow[shift];
      brokenline = LowerLine[shift];
      }

   // TARGET LINE RULES
   if(signal == BUYSIG)
      {
      if(Low[shift] > Target1[shift]) Target1[shift] = EMPTY_VALUE;
      if(Low[shift] > Target2[shift]) Target2[shift] = EMPTY_VALUE;
      }
   if(signal == SELLSIG)
      {
      if(High[shift] < Target1[shift]) Target1[shift] = EMPTY_VALUE;
      if(High[shift] < Target2[shift]) Target2[shift] = EMPTY_VALUE;
      }

   // HIDE LINE TRANSITIONS
   if(HideTransitions == True)
      {
      if(UpperLine[shift] != UpperLine[shift+1]) UpperLine[shift+1] = EMPTY_VALUE;
      if(LowerLine[shift] != LowerLine[shift+1]) LowerLine[shift+1] = EMPTY_VALUE;
      if(Target1[shift] != Target1[shift+1]) Target1[shift+1] = EMPTY_VALUE;
      if(Target2[shift] != Target2[shift+1]) Target2[shift+1] = EMPTY_VALUE;
      }

   shift--; // move ahead one candle
   }

// update the status display
   StatusMessage();
   return(0);
}// end of start()

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
// cleanup display buffers
for(int i=0; i<Bars; i++)
   {
   UpperLine[i] = EMPTY_VALUE;
   LowerLine[i] = EMPTY_VALUE;
   Target1[i] = EMPTY_VALUE;
   Target2[i] = EMPTY_VALUE;
   BuyArrow[i] = EMPTY_VALUE;
   SellArrow[i] = EMPTY_VALUE;
   BullDot[i] = EMPTY_VALUE;
   BearDot[i] = EMPTY_VALUE;
   }
Comment("");   
return(0);
}// end of deinit()


