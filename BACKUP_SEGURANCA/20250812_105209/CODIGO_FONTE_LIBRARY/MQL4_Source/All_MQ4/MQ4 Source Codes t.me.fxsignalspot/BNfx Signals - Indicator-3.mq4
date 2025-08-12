//$------------------------------------------------------------------$
//|                                       BNFX Signals - Indicator.mq4 |
//|                                        
//$------------------------------------------------------------------$

#property version   "1.00"
// this is a merging process of two idnicators with full respect to orignal coders

#property indicator_chart_window
#property indicator_buffers 13
#property indicator_color1  clrSandyBrown
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrSandyBrown
#property indicator_color4  clrDodgerBlue
#property indicator_color5  clrLime
#property indicator_color6  clrRed
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_type7   DRAW_NONE
//--- plot BuyArrow
#property indicator_label8  "BuyArrow"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrGreen
#property indicator_style8  STYLE_SOLID
#property indicator_width8  2
//--- plot SellArrow
#property indicator_label9  "SellArrow"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrRed
#property indicator_style9  STYLE_SOLID
#property indicator_width9  2
#property indicator_type10   DRAW_NONE
#property indicator_type11   DRAW_NONE
//--- plot BullishPinBar
#property indicator_label12  "BullishPinBar"
#property indicator_type12   DRAW_ARROW
#property indicator_color12  clrLime
#property indicator_style12  STYLE_SOLID
#property indicator_width12  1
//--- plot BearishPinBar
#property indicator_label13  "BearishPinBar"
#property indicator_type13   DRAW_ARROW
#property indicator_color13  clrDeepPink
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1
//
//
//

enum maType
  {
   ma_sma,  // Simple moving average
   ma_ema,  // Exponential moving average
   ma_smma, // Smoothed moving average
   ma_lwma, // Linear weighted moving average
   ma_t3    // T3
  };

input string Setting_1=" Heiken Ashi Ma T3 new ";
extern int    MaPeriod        = 5;
extern maType MaMetod         = ma_t3;
extern int    Step            = 0;
extern bool   BetterFormula   = true;
extern double T3Hot           = 1.00;
extern bool   T3Original      = false;
extern bool   SortedValues    = true;



bool   ShowArrows      = true;
bool   alertsOn        = false;
bool   alertsOnCurrent = false;
bool   alertsMessage   = false;
bool   alertsSound     = false;
bool   alertsEmail     = false;

//
//
//
input string Setting_2=" PinBar Logic ";
input double   WickRatioToBody=2;//Wick Ratio To Body (2 mean Wick is two times longer than Body)
input double   WickRatioToOpiiteWick=2.5;//Wick Ratio to the Opiite Wick
input int      LongestBarinLast=0;//Longest Bar in Last Certain Number of Bars
input bool     PinBarMonetum=true;//Pin Bar Body Momentum
//


//


double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double UpArrow[];
double DnArrow[];
double trend[];

//--- indicator buffers
double         BuyArrowBuffer[];
double         SellArrowBuffer[];
double         ATR[];
double         ATR_Max[];
double         BullishPinBarBuffer[];
double         BearishPinBarBuffer[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(13);
   int style = DRAW_NONE;
   if(ShowArrows)
      style = DRAW_ARROW;
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2, Buffer3);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3, Buffer4);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4, UpArrow);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexStyle(4,style);
   SetIndexArrow(4,217);
   SetIndexBuffer(5, DnArrow);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexStyle(5,style);
   SetIndexArrow(5,218);
   SetIndexBuffer(6, trend);
   SetIndexEmptyValue(6, EMPTY_VALUE);
   MaPeriod = MathMax(1,MaPeriod);


//---
   SetIndexBuffer(7,BuyArrowBuffer);
   SetIndexEmptyValue(7, EMPTY_VALUE);
   SetIndexBuffer(8,SellArrowBuffer);
   SetIndexEmptyValue(8, EMPTY_VALUE);
   SetIndexBuffer(9,ATR);
   SetIndexEmptyValue(9, EMPTY_VALUE);
   SetIndexBuffer(10,ATR_Max);
   SetIndexEmptyValue(10, EMPTY_VALUE);
   SetIndexBuffer(11,BullishPinBarBuffer);
   SetIndexEmptyValue(11, EMPTY_VALUE);
   SetIndexBuffer(12,BearishPinBarBuffer);
   SetIndexEmptyValue(12, EMPTY_VALUE);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexArrow(7,233);
   SetIndexArrow(8,234);
   SetIndexArrow(11,159);
   SetIndexArrow(12,159);
//---


   return(0);
  }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//--- global variables
string sym=Symbol();
ENUM_TIMEFRAMES per=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0)
      return(-1);
   if(counted_bars>0)
      counted_bars--;
   int limit=MathMin(Bars-counted_bars,Bars-1);
   int pointModifier = 1;
   if(Digits==3 || Digits==5)
      pointModifier = 10;

//
//
//
//
//

   for(int i=limit; i >= 1; i--)
     {
      if(MaMetod==ma_t3)
        {
         double maOpen  = iT3(Open[i],MaPeriod,T3Hot,T3Original,i,0);
         double maClose = iT3(Close[i],MaPeriod,T3Hot,T3Original,i,1);
         double maLow   = iT3(Low[i],MaPeriod,T3Hot,T3Original,i,2);
         double maHigh  = iT3(High[i],MaPeriod,T3Hot,T3Original,i,3);
        }
      else
        {
         maOpen  = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_OPEN,i);
         maClose = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_CLOSE,i);
         maLow   = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_LOW,i);
         maHigh  = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_HIGH,i);
        }
      if(SortedValues)
        {
         double sort[4];
         sort[0] = maOpen;
         sort[1] = maClose;
         sort[2] = maLow;
         sort[3] = maHigh;
         ArraySort(sort);
         maLow  = sort[0];
         maHigh = sort[3];
         if(Open[i]>Close[i])
           { maOpen = sort[2]; maClose = sort[1]; }
         else
           {
            maOpen = sort[1];
            maClose = sort[2];
           }
        }

      //
      //
      //
      //
      //

      if(BetterFormula)
        {
         if(maHigh!=maLow)
            double haClose  = (maOpen+maClose)/2+(((maClose-maOpen)/(maHigh-maLow))*MathAbs((maClose-maOpen)/2));
         else
            haClose   = (maOpen+maClose)/2;
        }
      else
         haClose   = (maOpen+maHigh+maLow+maClose)/4;
      double haOpen   = (Buffer3[i+1]+Buffer4[i+1])/2;
      double haHigh   = MathMax(maHigh, MathMax(haOpen,haClose));
      double haLow    = MathMin(maLow,  MathMin(haOpen,haClose));

      if(haOpen<haClose)
        {
         Buffer1[i]=haLow;
         Buffer2[i]=haHigh;
        }
      else
        {
         Buffer1[i]=haHigh;
         Buffer2[i]=haLow;
        }
      Buffer3[i]=haOpen;
      Buffer4[i]=haClose;

      //
      //
      //
      //
      //

      if(Step>0)
        {
         if(MathAbs(Buffer1[i]-Buffer1[i+1]) < Step*pointModifier*Point)
            Buffer1[i]=Buffer1[i+1];
         if(MathAbs(Buffer2[i]-Buffer2[i+1]) < Step*pointModifier*Point)
            Buffer2[i]=Buffer2[i+1];
         if(MathAbs(Buffer3[i]-Buffer3[i+1]) < Step*pointModifier*Point)
            Buffer3[i]=Buffer3[i+1];
         if(MathAbs(Buffer4[i]-Buffer4[i+1]) < Step*pointModifier*Point)
            Buffer4[i]=Buffer4[i+1];
        }
      trend[i] = trend[i+1];
      if(Buffer3[i] < Buffer4[i])
         trend[i] =  1;
      if(Buffer3[i] > Buffer4[i])
         trend[i] = -1;
      if(ShowArrows)
        {
         UpArrow[i] = EMPTY_VALUE;
         DnArrow[i] = EMPTY_VALUE;
         if(trend[i]!=trend[i+1])
           {
            if(trend[i]== 1)
               UpArrow[i] = Low[i]  - 1.8* iATR(NULL,0,20,i)/2.0;
            if(trend[i]==-1)
               DnArrow[i] = High[i] + 1.8* iATR(NULL,0,20,i)/2.0;
           }
        }
      //---
      //---
      ATR[i]=iATR(sym,per,1,i);
      ATR_Max[i]=iATR(sym,per,1,ArrayMaximum(ATR,LongestBarinLast,i));
      //---

      if
      (
         (LowerWick(i) > WickRatioToBody*Body(i) || WickRatioToBody==0)
         && (LowerWick(i) > WickRatioToOpiiteWick*UpperWick(i) || WickRatioToOpiiteWick==0)
         && (ATR[i] >= ATR_Max[i] || LongestBarinLast==0)
         && (PinBarMonetum==false || BodyBottom(i) >= BodyBottom(i+1))
         && trend[i]==1
      )
        {
         //BuyArrowBuffer[i]=L(i)-2*R(i);
         BullishPinBarBuffer[i]=L(i);
        }
      if
      (
         (UpperWick(i) > WickRatioToBody*Body(i) || WickRatioToBody==0)
         && (UpperWick(i) > WickRatioToOpiiteWick*LowerWick(i) || WickRatioToOpiiteWick==0)
         && (ATR[i] >= ATR_Max[i] || LongestBarinLast==0)
         && (PinBarMonetum==false || BodyTop(i) <= BodyTop(i+1))
         && trend[i]==-1
      )
        {
         //SellArrowBuffer[i]=H(i)+2*R(i);
         BearishPinBarBuffer[i]=H(i);
        }
      //---
      if
      (
      BullishPinBarBuffer[i+1]!=EMPTY_VALUE
      && C(i) > O(i)
      )
        {
         BuyArrowBuffer[i]=L(i)-2*R(i);
        }
      if
      (
      BearishPinBarBuffer[i+1]!=EMPTY_VALUE
      && C(i) < O(i)
      )
        {
         SellArrowBuffer[i]=H(i)+2*R(i);
        }
      //---
     }
   manageAlerts();
   ChartRedraw(0);
   return(0);
  }


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageAlerts()
  {
   if(alertsOn)
     {
      if(alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;
      whichBar = iBarShift(NULL,0,iTime(NULL,0,whichBar));
      if(trend[whichBar] != trend[whichBar+1])
        {
         if(trend[whichBar] == 1)
            doAlert(whichBar,"up");
         if(trend[whichBar] ==-1)
            doAlert(whichBar,"down");
        }
     }
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;

   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];

      //
      //
      //
      //
      //

      message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS),"  trend changed - ",doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(),"HAMA "),message);
      if(alertsSound)
         PlaySound("alert2.wav");
     }
  }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workT3[][24];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
  {
   if(ArrayRange(workT3,0) !=Bars)
      ArrayResize(workT3,Bars);
   if(ArrayRange(workT3Coeffs,0) < (instanceNo+1))
      ArrayResize(workT3Coeffs,instanceNo+1);

   if(workT3Coeffs[instanceNo][_period] != period)
     {
      workT3Coeffs[instanceNo][_period] = period;
      double a = hot;
      workT3Coeffs[instanceNo][_c1] = -a*a*a;
      workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
      workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
      workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
      if(original)
         workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
      else
         workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
     }

//
//
//
//
//

   int buffer = instanceNo*6;
   int r = Bars-i-1;
   if(r == 0)
     {
      workT3[r][0+buffer] = price;
      workT3[r][1+buffer] = price;
      workT3[r][2+buffer] = price;
      workT3[r][3+buffer] = price;
      workT3[r][4+buffer] = price;
      workT3[r][5+buffer] = price;
     }
   else
     {
      workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
      workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
      workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
      workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
      workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
      workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
     }

//
//
//
//
//

   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] +
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] +
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] +
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
  }
//+------------------------------------------------------------------+


//OHLCV
double O(int I_Open) {return(iOpen(_Symbol,_Period,I_Open));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double H(int I_High) {return(iHigh(_Symbol,_Period,I_High));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double L(int I_Low) {return(iLow(_Symbol,_Period,I_Low));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double C(int I_Close) {return(iClose(_Symbol,_Period,I_Close));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double R(int I_ATR) {return(0.25*iATR(_Symbol,_Period,50,I_ATR));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double M(int I_Median) {return((H(I_Median)+L(I_Median))/2);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double T(int I_Typical) {return((H(I_Typical)+L(I_Typical)+C(I_Typical))/3);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long   V(int I_Volume) {return(iVolume(_Symbol,_Period,I_Volume));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double Value,int Precision) {return(NormalizeDouble(Value,Precision));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DTS(double Value,int Precision) {return(DoubleToStr(Value,Precision));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMa(int period,int shift,ENUM_MA_METHOD mode,ENUM_APPLIED_PRICE price, int index) {return(iMA(Symbol(),Period(),period,shift,mode,price,index));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Range(int iRange) {return((H(iRange)-L(iRange)));}
//double AR(int iRV){return(iATR(_Symbol,_Period,ATR,iRV));}
double Body(int iBody) {return(MathMax(O(iBody),C(iBody))-MathMin(O(iBody),C(iBody)));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double UpperWick(int iWick) {return(H(iWick)-MathMax(O(iWick),C(iWick)));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LowerWick(int iWick) {return(MathMin(O(iWick),C(iWick))-L(iWick));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BodyTop(int i)    {return(MathMax(C(i),O(i)));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BodyBottom(int i) {return(MathMin(C(i),O(i)));}
//+------------------------------------------------------------------+
